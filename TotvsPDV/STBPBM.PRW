#include "TOTVS.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "FRTDEF.CH"
#include "STBDEFPBM.CH"

Static aVidaLinkD	:= {}	// array de detalhe (produto,qtde,preco) com o orcamento gerado no PBM VidaLink
Static aVidaLinkc	:= {}	// array cabecalho (Cliente,loja,etc) do orcamento gerado no PBM VidaLink
Static nVidaLink	:= 0 	// Indica se Itens veio do VidaLink. 0=Nao usa VidalInk. 1=Gravando VidaLink. 2=Gravou VidaLink
Static uCliTPL      := Nil
Static uProdTPL     := Nil
Static oTPLPBM      := NIL
Static lIsVndPBM    := .F.
Static lTemPBMAtv   := .F.

/*/{Protheus.doc} STBPbmMenu
    Chamada do Menu de PBM's
    @type  Function
    @author Julio.Nery
    @since 19/02/2021
    @version 12
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Function STBPbmMenu()
Local oDlg := NIL

DEFINE MSDIALOG oDlg TITLE "Rotinas PBM" FROM 00,00 TO 200,200 OF GetWndDefault() PIXEL	//"Rotinas PBM"

	@ 10,10 BUTTON "Venda PBM"	SIZE 80,20 OF oDlg PIXEL ACTION ( STBOPbm() , oDlg:End() )	//"Venda PBM"
	@ 30,10 BUTTON "Cancelamento PBM" SIZE 80,20 OF oDlg PIXEL ACTION ( STBCancPbm(), oDlg:End() )	    //"Cancelamento PBM"
	@ 50,10 BUTTON "&Sair"	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )	        	    //"&Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} STBOPbm
    - Esta fun��o serve para executar as op��es das PBM's que tem consulta que estavam presentes no PE TPL FRTFuncoes
    porem para adequa��o da tela colocamos todos no mesmo menu ("PBM's") no TOTVSPDV
    e a chamada da fun��o DroVLGet � feita por essa menu diretamente de acordo com a PBM selecionada no combo

    - Chama a fun��o de venda para os PBM's Epharma e TRNCentre, que � diferente a chamada
    @type  Function
    @author Julio.Nery
    @since 01/03/2021
    @version 12
    @param param, param_type, param_descr
    @return NIL
/*/
Static Function STBOPbm()
Local cDoc 		:= ""	// Retorna o numero do cupom fiscal
Local cOperador := ""	// Guada o codigo do pdv para passar para a PBM
Local cSerie	:= ""   // retorna a SERIE fiscal da esta��o
Local cTpDoc	:= "0"  //tipo de documento utilizado no pbm = 0 - ecf, 1 - nfce, 2 -sat
Local nTamCupPBM:= 6    //Tamanho do cupom PBM
Local nOpPBM    := 0
Local oTEF20    := NIL
Local oDadosPbm := NIL
Local lContinua := .T.
Local lConsulta := .F.
Local lVenda    := .F.

If lTemPBMAtv
    lContinua := .F.
    MsgAlert("Venda PBM j� foi inicializada, para que seja poss�vel utilizar outra PBM efetua nova venda")
Else
    oTEF20 := STBGetTEF()
    STBIsVnPBM(.T.,oTEF20:Pbm())
    lContinua := STBVerConVnd(@lConsulta,@lVenda,@nOpPBM)
    lTemPBMAtv := lContinua
EndIf

If lContinua
    Do Case
        Case lConsulta 
            STBIsVnPBM(.F.,NIL) //Nessas PBMs n�o pode seguir usando esse objeto
            T_DroVLGet(nOpPBM)
            lTemPBMAtv := .T.

        Case lVenda
            lTemPBMAtv := .T.            
            cOperador := STFGetStation("PDV")
            cSerie	:= STFGetStation("SERIE")
            cDoc := STBPbmNDoc(nTamCupPBM, cSerie, .T.) /* Busca o numero do documento fiscal */
            If !Empty(cDoc)
                If STFGetCfg("lUseSAT",.F.)
                    cTpDoc := "2"
                ElseIf LjEmitNFCe()
                    cTpDoc := "1"
                EndIf

                oDadosPbm := LJCDadosTransacaoPBM():New(0               , cDoc         , Date()  ,  Time(),;
                                                        /*lUltimaTrn*/  ,/*cRede*/     , cTpDoc  ,  cOperador )

                //Inicializa a venda PBM
                If oTPLPBM:IniciaVend( oDadosPbm )
                    STFMessage("ItemVendaPBM","STOP", "Venda PBM") //"Venda PBM"
                    STFShowMessage("ItemVendaPBM")
                Else
                    STBIsVnPBM(.F.,NIL)
                EndIf
            EndIf
    EndCase
EndIf

Return NIL

/*/{Protheus.doc} STBCancPbm
    Cancelamento da PBM
    @type  Function
    @author Julio.Nery
    @since 19/02/2021
    @version 12
    @param nenhum
    @return nenhum
/*/
Static Function STBCancPbm()
Local cMsg      := ""
Local oTEF20    := STBGetTEF()
Local cNomePBM  := ""
Local aRelPbm   := {}
Local cComproPBM:= ""

STBIsVnPBM(.T.,oTEF20:Pbm())

If oTPLPBM <> Nil
    If oTPLPBM:SelecPbm(@cNomePBM,.T.)
        STFMessage("STBCancPbm1", "STOP",  "Cancelamento de PBM") //"Cancela PBM"
		STFShowMessage("STBCancPbm1")
        If oTPLPBM:CancPbm()
            //Impress�o do Comprovante de Cancelamento do PBM.
            If cNomePBM $ (_EPHARMA + "|" + _TRNCENTRE)
                //Busca o relatorio a ser impresso, referente ao cancelamento do PBM
                aRelPbm     := oTPLPBM:BuscaRel()
                cComproPBM  := STBPbmCpv(aRelPbm)
                STBPrintPBM(cComproPBM)
            EndIf
            cMsg := "Venda PBM cancelada com sucesso" //"Cancela PBM"		    
        Else
            cMsg := "Venda PBM n�o cancelada"
        EndIf

        STFMessage("STBCancPbm2", "STOP", cMsg)
		STFShowMessage("STBCancPbm2")
    EndIf
EndIf

STBIsVnPBM(.F.,NIL)
	
Return Nil

/*/{Protheus.doc} STCnProPBM
    Cancelamento de item da PBM
    @type  Function
    @author Julio.Nery
    @since 26/02/2021
    @version 12
    @param cCodBarra, string, c�digo de barras do produto
    @param nQtde, integer, quantidade
    @return lRet, l�gico, produto cancelado da PBM ?
/*/
Function STCnProPBM( cCodBarra, nQtde )
Local lRet := .F.		// Retorno da funcao

If oTPLPBM:CancProd( cCodBarra, nQtde )
    lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} STCnfPrPBM
    Copia da fun��o LjConfProdPBM para venda de Produto PBM no TotvsPDV

    @type  Function
    @author user
    @since 02/03/2021
    @version 12
    @param param, param_type, param_descr
    @return lRet, l�gico, Item Validado ?
/*/
Function STCnfPrPBM( cCodBarra, nQtde, lOk, lItemPbm,;
                    nItemLine )
Local lRet      := .F.

If lItemPbm
    lRet := oTPLPBM:ConfProd( cCodBarra, nQtde, lOk )
    If lRet
       STDSPBasket("SL2","L2_ITPBM",lItemPbm,nItemLine) 
    Else
        MsgAlert("Produto n�o confirmado na PBM. Item ser� cancelado.")
        LjGrvLog(NIL,"Produto [C�digo de Barras: " + cCodBarra + " ] n�o confirmado na PBM. Item " +;
                             cValToChar(nItemLine) + " ser� cancelado.")

        //Cancela o Item Lan�ado e a PBM
        lRet := STWCancelProcess( nItemLine )
        LjGrvLog(NIL,"Produto [C�digo de Barras: " + cCodBarra + " ]  cancelado ?", lRet)
        
        STBIsVnPBM(.F.,NIL)
        LjGrvLog(NIL,"Venda PBM Cancelada, caso queira lan�ar itens PBM, efetue a chamada no Menu PBM - Venda")
        STFCleanInterfaceMessage()
        STFMessage("VendaPBM","STOP", "Venda Comum") //"Venda Comum"
        STFShowMessage("VendaPBM")
        lRet := .F.
    EndIf
Else
    lRet := .T.
EndIf
	
Return lRet

/*/{Protheus.doc} STVndPrPbm
    C�pia da fun��o LjVendProdPbm para a venda de produto PBM no TOTVSPDV
    @type  Function
    @author Julio.Nery
    @since 03/03/2021
    @version 12
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Function STVndPrPbm( cCodBar, nQuant, nVlrUnit, lItemPbm,;
                     nVlrDescIT, lPrioPbm, nVlrPercIT )
Local cMsg      := ""
Local lRet 		:= .F.	// Retorno da funcao
Local nPercDesc := 0	// Percentual de desconto
Local nValorAux := 0	// Utilizado para calcular o valor do desconto

Default nVlrDescIT 	:= 0
Default lPrioPbm 	:= .T.                                  	
Default nVlrPercIT 	:= 0
    
If nVlrDescIT > 0 .AND. nVlrPercIT == 0
    nPercDesc := (nVlrDescIT/(nVlrUnit*nQuant)) * 100
Else
    nPercDesc := nVlrPercIT
EndIf

lRet := oTPLPBM:VendProd( 	cCodBar		, nQuant	, nVlrUnit	, @nPercDesc, ;
                            @lItemPbm	, lPrioPbm	)

If lItemPbm
    nVlrPercIT := nPercDesc
    cMsg := "Registro de Item PBM"
Else
    nValorLiq := NoRound(nVlrUnit - (nVlrUnit * (nPercDesc / 100)), 2)
    nPercDesc := NoRound(((nVlrUnit - nValorLiq) * 100) / nVlrUnit, 2)
    nVlrPercIT := nPercDesc
    cMsg := "Registro de Item Comum"
EndIf

nValorAux  := NoRound((nVlrUnit * nQuant) - (((nVlrUnit * nQuant) * nPercDesc) / 100), 2)
nVlrDescIT := (nVlrUnit * nQuant) - nValorAux

LjGrvLog(NIL,"Registro de Item " + IIF(lItemPbm,"PBM", "Comum") + " -> Produto C�digo de barras [" + cCodBar + "]" + Chr(10) + Chr(13) +;
            " Valor de Desconto | Retorno ", {nVlrDescIT,lRet})

STFMessage("ITPBM","STOP", cMsg)
STFShowMessage("ITPBM")

Return lRet

/*/{Protheus.doc} STBFimVdPB
    C�pia de LjFinVend - para finalizar venda PBM
    @type  Function
    @author Julio.Nery
    @since 03/2021
    @version 12
    @param cDoc, string, numero da venda
    @param cSerie, string, s�rie da venda
    @param cKeyDoc, string, chave da venda
    @return lRet, l�gico, Finalizou a Venda ?
/*/
Function STBFimVdPB(cDoc, cSerie, cKeyDoc)
Local lRet      := .F.	// Retorno da funcao

lRet := oTPLPBM:FinalVend(cDoc, cSerie, cKeyDoc)
STFCleanInterfaceMessage()

Return lRet

/*/{Protheus.doc} STBPbmNDoc
    Numera��o da PBM
    @type  Function
    @author Julio.Nery copia de 
    @since 19/02/2021
    @version 12
    @param nTamCupPBM, integer, numero do cupom da PBM - tem que ser 6 (regra da PBM)
    @param cSerie, string, serie do documento
    @param lSomaCup, l�gico, soma numero no cupom ?
    @return cDoc, string, numero do doc
/*/
Function STBPbmNDoc(nTamCupPBM, cSerie, lSomaCup)
Local aLastSat	:= {}
Local cDoc	    := ""

Default nTamCupPBM := 6
Default cSerie     := STFGetStation("SERIE")
Default lSomaCup   := .F.

If LjEmitNFCe()
	//retorna o conte�do do campo X5_DESCRI	da tabela SX5
	If STFGetCfg("lUseSAT",.F.)
        aLastSat := LJSatNumSale()
        If Len(aLastSat) >= 1
            cDoc := aLastSat[01]
            cDoc := Right( cDoc, nTamCupPBM )
            //a transa��o PBM somente suporta 6 caracteres para o n�mero do cupom fiscal
            cDoc := PADL( Val(cDoc) + IIF(lSomaCup,1, 0), nTamCupPBM, "0" )
        EndIf
	Else
		cDoc := Tabela('01', cSerie)
		//a transa��o PBM somente suporta 6 caracteres para o n�mero do cupom fiscal
		cDoc := Right( cDoc, nTamCupPBM )
	EndIf	
Else		
	cDoc := STBCSNumPrinter()
	//+1 no numero retornado, pois ela retorna o ultimo numero utilizado
	cDoc := PADL( Val(cDoc)+ IIF(lSomaCup,1,0), nTamCupPBM, "0" )
EndIf
				
Return cDoc

/*/{Protheus.doc} STBIsVnPBM()
    Retorna se esta em uma venda PBM
    @type  Function
    @author Julio.Nery
    @since 24/02/2021
    @version 12
    @param lSet, l�gico, Seta o valor ?
    @return lRet, l�gico, Esta numa venda PBM ?
/*/
Function STBIsVnPBM(lSet,oVARPBM)
Local lRet := .F.

DEFAULT oVARPBM := NIL

If ValType(lSet) == "L"
    lIsVndPBM:= lSet
    oTPLPBM  := oVARPBM
EndIf

lRet := lIsVndPBM
Return lRet

/*/{Protheus.doc} STBGetVPBM()
    Retorna o objeto da PBM para prosseguir venda PBM
    @type  Function
    @author Julio.Nery
    @since 26/02/2021
    @version 12
    @param nenhum
    @return oRetPBM, objeto, objeto com os dados da PBM atual
/*/
Function STBGetVPBM()
Local oRetPbm := oTPLPBM
Return oRetPbm

//--------------------------------------------------------
/*/{Protheus.doc} STBPerDro
Template Drogaria - Verifica se caixa tem permiss�o para vender remedio controlado

@author  Varejo
@version P12
@since   13/10/2015
@return	lRet, l�gico, Tem permiss�o para venda de produto controlado ?
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBPerDro()
Local lRet		 := .T.
Local nX		 := 0
Local nLength    := 0
Local oModelCesta:= STDGPBModel()	//Model da cesta

oModelCesta := oModelCesta:GetModel("SL2DETAIL")
nLength := oModelCesta:Length()

If (ExistFunc("LjIsDro") .And. LjIsDro()) .And. (nLength > 0)
    // procura pelos itens controlados para pedir permissao do farmaceutico
    // se for remedio controlado verifica permissao do primeiro item controlado
	For nX := 1 To nLength
        oModelCesta:GoLine(nX)
		If T_DroVerCont(oModelCesta:GetValue("L2_PRODUTO"))
			lRet := T_DroVERPerm(4)
			Exit
		EndIf
	Next nX
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBDadosVL
@description Grava dados VidaLink PBM
@author bruno.inoue
@since 17/04/2017
@version 11.80
/*/
//-------------------------------------------------------------------
Function STBDadosVL(aVidaLink)
Default aVidaLink := {}

If Len(aVidaLink) > 2
	aVidaLinkD := aVidaLink[1]
	aVidaLinkC := aVidaLink[2] 
	nVidaLink  := aVidalink[3]
Else
	aVidaLinkD := {}
	aVidaLinkC := {} 
	If Len(aVidaLink) == 1
		nVidaLink  := aVidaLink[1]
	Else
		nVidaLink  := 2
	EndIf
EndIf	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STGDadosVL
@description Retorna dados VidaLink PBM salvo
@author bruno.inoue
@since 17/04/2017
@version 11.80
/*/
//-------------------------------------------------------------------
Function STGDadosVL()
Local aVidalink := {}
aVidalink := {aVidaLinkD,aVidaLinkC,nVidalink}
Return aVidalink

//----------------------------------------------------------
/*/{Protheus.doc} STBVldPbm
Valida se utilizou PBM Funcional Card  

@type 	 function
@author  bruno.inoue
@version P11.8
@since   27/04/2017
@return  lRet
/*/
//----------------------------------------------------------
Function STBVldPbm()
Local aRetPbm 	:= {}
Local lRet		:= .F.

If ExistTemplate("DROVLGet")
	aRetPbm := STGDadosVL()
	If Len(aRetPbm) > 0 .And. aRetPbm[3] == 2
		lRet := .T.
	EndIf
EndIf	

Return lRet

/*/{Protheus.doc} STBDroVars
    Retorna as vari�veis est�ticas usadas no TPL DRO
    @type  Function
    @author Julio.Nery
    @since 26/02/2021
    @version 12
    @param lLimpar, l�gico, Limpar variaveis?
    @return aRet, array, contem os dados atuais das vari�veis
/*/
Function STBDroVars(lLimpar, lSetVal, setUCliTPL, setUProdTPL)
Local aRet := Array(2)

Default lSetVal := .F.

If lLimpar
    uCliTPL  := Nil
    uProdTPL := Nil
EndIf

If lSetVal
    uCliTPL := setUCliTPL
    uProdTPL:= setUProdTPL
EndIf

aRet := {uCliTPL,uProdTPL}
Return aRet

/*/{Protheus.doc} STBVerConVnd
    Verifica se � uma consulta ou venda PBM para efetuar tratamentos
    @type  Function
    @author Julio Nery 
    @since 16/03/2021
    @version 12
    @param param, param_type, param_descr
    @return lRet, l�gico, Retorno ok ?
/*/
Static Function STBVerConVnd(lConsulta,lVenda,nOpcPBM)
Local lRet := .F.
Local lContinua:= .T.
Local cNomePBM := ""

Default lConsulta := .F.
Default lVenda    := .F.
Default nOpcPBM   := 0

If !oTPLPBM:SelecPbm(@cNomePBM) //Seleciona a PBM
    ConOut("Nenhuma PBM selecionada")
    STFMessage("STBVerConVnd","STOP", "Nenhuma PBM selecionada" ) //"Nenhuma PBM selecionada"
    STFShowMessage("STBVerConVnd")
    lContinua := .F.
Endif

If lContinua 

    If cNomePBM $ (_VIDALINK + "|" + _PHARMASYS + "|" + _FUNCCARD)
        if cNomePBM == _VIDALINK
            nOpcPBM := 1
        ElseIf cNomePBM == _PHARMASYS
            nOpcPBM := 541
        ElseIf cNomePBM == _FUNCCARD
            nOpcPBM := 560
        EndIf
        lRet := .T.
        lConsulta := .T.
    EndIf

    If cNomePBM $ (_EPHARMA + "|" + _TRNCENTRE)
        lRet := .T.
        lVenda:= .T.
    EndIf

EndIf

If !lRet
    STBIsVnPBM(.F.,NIL)
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STBSubsidio
Verifica se a venda PBM possui subsidio para ja levar 
automaticamente para as formas de pagamento.

@author  Varejo
@version P12.1.27
@since   16/03/2021

@param		nVSubsidio, Num�rico, Valor de subsidio da venda referente ao PBM
@param		cFormaSub, Caractere, Determina se deve omitir formas de pagamento conforme regra da template function "FRTALTPG" (Drogaria)

@return lRetorno, l�gico, Retorno se tem ou nao subsidio.
/*/
//--------------------------------------------------------
Function STBSubsidio(nVSubsidio, cFormaSub)
Local lRetorno  := .F.					//Retorno da funcao, define se tem ou nao subsidio
Local nI		:= 0
Local lContinua := .F.
Local oTEF20    := NIL

If STBIsVnPBM() .Or. (nVidalink <> 0 .AND. Len(aVidaLinkD) > 0)
    lContinua := .T.
EndIf

If lContinua
    If nVidaLink <> 0 .And. nVidaLink <> 99
        oTEF20 := STBGetTEF()
        If oTEF20:PBM():oPBM:oPBM:aVDLink[1,5] <> 560	//Se nao for Funcional Card
            For nI := 1 to Len(aVidaLinkD[VL_DETALHE])
                nVSubsidio += (aVidaLinkD[VL_DETALHE,nI, VL_PRVENDA ] - aVidaLinkD[VL_DETALHE,nI, VL_PRVISTA ]) * aVidaLinkD[VL_DETALHE,nI, VL_QUANTID]
            Next nI
        EndIf   	    
    Else
        nVSubsidio	:= oTPLPBM:BuscaSubs()
    EndIf   

    If nVSubsidio > 0
        
        //Verifica a forma de pagamento utilizada como padr�o na venda PBM com subsidio. Se n�o encontrar o default � "CO"
        cFormaSub := SuperGetMV("MV_LJFSUB", Nil, "CO")
        
        //Verifica se a forma de pagamento est� cadastrada na tabela 24
        If GenTabPos( "24", cFormaSub )
            lRetorno := .T.
        Else
            Alert("Venda PBM com subs�dio, por favor, configurar uma forma de pagamento v�lida no par�metro MV_LJFSUB.")
            nVSubsidio := 0
        EndIf
    EndIf
EndIf

Return lRetorno

/*/{Protheus.doc} STPbmRtFun
    Retorna o numero da Fun��o da PBM 
    @type  Function
    @author Julio.Nery
    @since 26/03/2021
    @version 12
    @param cOperacao, string, descri��o da opera��o
    @return nFuncao, integer, numero da fun��o
/*/
Function STPbmRtFun(cOperacao)
Local nFuncao := 0

If cOperacao == "VIDALINK_CONSULTA"
	nFuncao := 902

ElseIf cOperacao == "VIDALINK_VENDA"
	nFuncao := 903

ElseIf cOperacao == "VIDALINK_CANCELAMENTO"
	nFuncao := 904

// Cancelamento de captura da Pre-Autorizacao  (PharmaSystem)
ElseIf cOperacao == "PHARMASYSTEM_AUTORIZA"
	nFuncao := 540

ElseIf cOperacao == "PHARMASYSTEM_CONSULTA"
	nFuncao := 541

ElseIf cOperacao == "PHARMASYSTEM_VENDA"
	nFuncao := 545

ElseIf cOperacao == "PHARMASYSTEM_CANCELAMENTO"
	nFuncao := 543

ElseIf cOperacao == "FUNCARD_CONSULTA"
	nFuncao := 560

ElseIf cOperacao == "FUNCARD_VENDA"
	nFuncao := 561
EndIf

Return nFuncao

/*/{Protheus.doc} STPbmReini
    Reinicializa as vari�veis do Template
    @type  Function
    @author Julio.Nery
    @since 16/04/2021
    @version 12
    @param nenhum
    @return nenhum
/*/
Function STPbmReini()
Local aDadoVDLink := {}

//Zera as variaveis uCLiTPL e uProdTPL
STBDroVars(.T.)

//Zera a vari�vel de PBM
If oTPLPBM <> Nil
    oTPLPBM:ConfVend( .F. )
    STBIsVnPBM(.F.,NIL)
EndIf

//Zera a variavel do VidaLink
aDadoVDLink := STGDadosVL()
aDadoVDLink[1] := {}
aDadoVDLink[2] := {}
aDadoVDLink[3] := 0
STBDadosVL(aDadoVDLink)

//Limpeza para que n�o pergunte se pode inserir o mesmo registro de novo no array aANVISA
T_DroDelANVISA(.T., NIL)

//Reinicia a op��o para que seja poss�vel efetuar a venda PBM novamente
lTemPBMAtv := .F.
Return 

/*/{Protheus.doc} STBPrintPBM
    Efetua a impress�o do comprovante do PBM.
    @type  Function
    @author albertod
    @since 03/2021
    @version 12
    @param cViaCaixa, Caracter, Texto do comprovante PBM (Via do Estabelecimento)
    @param cViaCliente, Caracter, Texto do comprovante PBM (Via do Cliente)
    @return lRet, l�gico, Imprimiu o comprovante do PBM ?
/*/
Function STBPrintPBM(cViaCaixa, cViaCliente)
Local lRet          := .F.	// Retorno da funcao
Local oTEF20        := STBGetTEF()
Local oViaCaixa		:= Nil
Local oViaCliente	:= Nil

If !Empty(cViaCaixa)
    oViaCaixa := oTEF20:Pbm():oTransSitef:CarregCup(cViaCaixa)
EndIf

If !Empty(cViaCliente)
    oViaCliente := oTEF20:Pbm():oTransSitef:CarregCup(cViaCliente)
EndIf

//Insere na Cole��o o Cupom PBM que deve ser impresso
oTEF20:Cupom():Inserir("G", oViaCaixa, oViaCliente, "PBM", "", "", 1, 1, 0 )

//Efetua a impress�o do Cupom PBM
lRet := oTEF20:Cupom():Imprimir()

Return lRet

/*/{Protheus.doc} STBPbmCpv
    Monta a string do comprovante do PBM (Para os PBMs Epharma e TrnCentre).
    @type  Function
    @author albertod
    @since 03/2021
    @version 12
    @param aRelPbm, Array, Array com os dados do comprovante a ser impresso.
    @return cRet, Caracter, Texto do comprovante do PBM.
/*/
Function STBPbmCpv(aRelPbm)
Local cRet      := ""
Local nX        := 0
Local nCount    := 0

While ++nX <= Len( aRelPbm ) .AND. nCount <= 1
    cRet += aRelPbm[nX] + Chr(10)
    If nX == Len( aRelPbm )
        ++nCount
        nX := 0
        cRet += Chr(13) + Chr(10)
    EndIf
End

Return cRet