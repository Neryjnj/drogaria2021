#include "TOTVS.CH"
#INCLUDE "DEFTEF.CH"

Static aVidaLinkD	:= {}	// array de detalhe (produto,qtde,preco) com o orcamento gerado no PBM VidaLink
Static aVidaLinkc	:= {}	// array cabecalho (Cliente,loja,etc) do orcamento gerado no PBM VidaLink
Static nVidaLink	:= 0 	// Indica se Itens veio do VidaLink. 0=Nao usa VidalInk. 1=Gravando VidaLink. 2=Gravou VidaLink
Static uCliTPL      := Nil
Static uProdTPL     := Nil
Static oTPLPBM      := NIL
Static lIsVndPBM    := .F.

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

DEFINE MSDIALOG oDlg TITLE "Rotinas PBM" FROM 00,00 TO 240,200 OF GetWndDefault() PIXEL	//"Rotinas PBM"

    @ 10,10 BUTTON "Consulta PBM"	SIZE 80,20 OF oDlg PIXEL ACTION ( STBConPbm() , oDlg:End() )	//"Venda PBM"
	@ 30,10 BUTTON "Venda PBM"	SIZE 80,20 OF oDlg PIXEL ACTION ( STBOPbm() , oDlg:End() )	//"Venda PBM"
	@ 50,10 BUTTON "Cancelamento PBM" SIZE 80,20 OF oDlg PIXEL ACTION ( STBCancPbm(), oDlg:End() )	    //"Cancelamento PBM"
	@ 70,10 BUTTON "&Sair"	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )	        	    //"&Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} STBConPbm    
    Esta fun��o serve para executar as op��es das PBM's que tem consulta que estavam presentes no PE TPL FRTFuncoes
    porem para adequa��o da tela colocamos todos no mesmo menu ("PBM's") no TOTVSPDV
    e a chamada da fun��o DroVLGet � feita por essa menu diretamente de acordo com a PBM selecionada no combo
    @type  Function
    @author Julio Nery
    @since 16/03/2021
    @version 12
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Static Function STBConPbm()
Local oTEF20    := NIL
Local lContinua := .T.
Local nOpPBM    := 0

oTEF20 := STBGetTEF()
STBIsVnPBM(.T.,oTEF20:Pbm())
lContinua := STBVerConVnd(.T.,,@nOpPBM)

If lContinua
    T_DroVLGet(nOpPBM)
EndIf

Return

/*/{Protheus.doc} STBOPbm    
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Static Function STBOPbm()
Local cDoc 		:= ""						// Retorna o numero do cupom fiscal
Local cOperador := STFGetStation("PDV")		// Guada o codigo do pdv para passar para a PBM
Local cSerie	:= STFGetStation("SERIE")	// retorna a SERIE fiscal da esta��o
Local cTpDoc	:= "0" //tipo de documento utilizado no pbm = 0 - ecf, 1 - nfce, 2 -sat
Local nTamCupPBM:= 6 //Tamanho do cupom PBM
Local oTEF20    := NIL
Local oDadosPbm := NIL
Local lContinua := .T.

/* Busca o numero do documento fiscal */	
cDoc := STBPbmNDoc(nTamCupPBM, cSerie, .T.)

//Pega o numero do cupom
If !Empty(cDoc)
    oTEF20 := STBGetTEF()
    STBIsVnPBM(.T.,oTEF20:Pbm())
    lContinua := STBVerConVnd(,.T.)

    If lContinua
        If STFGetCfg("lUseSAT",.F.)
            cTpDoc := "2"
        ElseIf LjEmitNFCe()
            cTpDoc := "1"
        EndIf

        oDadosPbm := LJCDadosTransacaoPBM():New(0               , cDoc         , Date()  ,  Time(),;
                                                /*lUltimaTrn*/  ,/*cRede*/     , cTpDoc  ,  cOperador )

        //Inicializa a venda PBM
        If oTPLPBM:IniciaVend( oDadosPbm )
            STFMessage("STBOPbm1","STOP", "Venda PBM" ) //"Venda PBM"
		    STFShowMessage("STBOPbm1")
        Else
            STBIsVnPBM(.F.,NIL)
        EndIf
    EndIf
EndIf

STFCleanInterfaceMessage()    
Return

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
Local oTEF20:= STBGetTEF()

STBIsVnPBM(.T.,oTEF20:Pbm())

If oTPLPBM <> Nil
    If oTPLPBM:SelecPbm()
        STFMessage("STBCancPbm1", "STOP", "Cancela PBM" ) //"Cancela PBM"
		STFShowMessage("STBCancPbm1")
        
        If oTPLPBM:CancPbm() .And. oTEF20:Cupom():Imprimir()
            Conout("Cancelamento de PBM efetuado com sucesso")
            STFMessage("STBCancPbm2", "STOP", "Cancelamento de PBM efetuado com sucesso") //"Cancela PBM"
		    STFShowMessage("STBCancPbm2")
        EndIf
    EndIf
EndIf

STBIsVnPBM(.F.,NIL)
oTEF20 := NIL
STFCleanInterfaceMessage()
	
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
Local lRet := .F.

If lItemPbm
    lRet := oTPLPBM:ConfProd( cCodBarra, nQtde, lOk )
    If !lRet        
        MsgAlert("Produto n�o confirmado na PBM. Cupom fiscal sera cancelado.")
        //Cancela o Cupom Fiscal e PBM
        //JULIOOOO - validar se cancela o cupom mesmo no TOTVSPDV
        //avaliando o fluxo do frontloja, o item ja foi registrado e por isso h� o cancelamento
        //no totvspdv eu consigo somente cancelar o registro do item
        FrtCancCup( .T. ) 
    Else
        STDSPBasket("SL2","L2_ITPBM",lItemPbm,nItemLine)
    EndIf
Else
    lRet := .T.
EndIf
	
Return lRet

/*/{Protheus.doc} STVndPrPbm
    C�pia da funa��o LjVendProdPbm para a venda de produto PBM no TOTVSPDV
    @type  Function
    @author Julio.Nery
    @since 03/03/2021
    @version 12
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Function STVndPrPbm( cCodBar, nQuant, nVlrUnit, lItemPbm,;
                     nVlrDescIT, lPrioPbm, nVlrPercIT )
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
Else
    nValorLiq := NoRound(nVlrUnit - (nVlrUnit * (nPercDesc / 100)), 2)
    nPercDesc := NoRound(((nVlrUnit - nValorLiq) * 100) / nVlrUnit, 2)
    nVlrPercIT := nPercDesc
EndIf

nValorAux  := NoRound((nVlrUnit * nQuant) - (((nVlrUnit * nQuant) * nPercDesc) / 100), 2)
nVlrDescIT := (nVlrUnit * nQuant) - nValorAux
		
Return lRet

/*/{Protheus.doc} STBFimVdPB
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
/*/
Function STBFimVdPB(cDoc, cSerie, cKeyDoc)
Local lRet := .F.	// Retorno da funcao

lRet := oTPLPBM:FinalVend(cDoc, cSerie, cKeyDoc)

//LjMsgRodaP (bkp_oDlgFrt, bkp_oFntGet, STR0001) //"Protheus Front Loja"

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
Local oRetPbm
oRetPbm := oTPLPBM

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
    @return return, return_type, return_description
/*/
Static Function STBVerConVnd(lConsulta,lVenda,nOpcPBM)
Local lRet := .F.
Local lContinua:= .T.
Local cNomePBM := ""

Default lConsulta := .F.
Default lVenda    := .F.
Default nOpcPBM   := 0

If !oTPLPBM:SelecPbm(@cNomePBM) //Seleciona a PBM
    If lConsulta
        ConOut("Nenhuma PBM selecionada para consulta")
        STFMessage("STBVerConVnd","STOP", "Nenhuma PBM selecionada para consulta" ) //"Nenhuma PBM selecionada para consulta"
    EndIf

    If lVenda
        ConOut("Nenhuma PBM selecionada para venda")
        STFMessage("STBVerConVnd","STOP", "Nenhuma PBM selecionada para venda" ) //"Nenhuma PBM selecionada para venda"
    EndIf

    STFShowMessage("STBVerConVnd")
    lContinua := .F.
Endif

If lContinua 
    If lConsulta 
        If cNomePBM $ (_VIDALINK + "|" + _PHARMASYS + "|" + _FUNCCARD)
            if cNomePBM == _VIDALINK
                nOpcPBM := 1
            ElseIf cNomePBM == _PHARMASYS
                nOpcPBM := 541
            ElseIf cNomePBM == _FUNCCARD
                nOpcPBM := 560
            EndIf
            lRet := .T.
        Else
            STFMessage("STBVerConVnd2","STOP", "PBM Selecionada n�o permite essa consulta" ) //"PBM Selecionada n�o permite consulta"
            STFShowMessage("STBVerConVnd2")
        EndIf
    EndIf

    If lVenda
        If cNomePBM $ (_EPHARMA + "|" + _TRNCENTRE)
            lRet := .T.
        Else
            STFMessage("STBVerConVnd2","STOP", "Venda de PBM n�o pode ser efetuada por esse menu" ) //"Venda de PBM n�o pode ser efetuada por esse menu"
            STFShowMessage("STBVerConVnd2")
        EndIf
    EndIf
EndIf

If !lRet
    STBIsVnPBM(.F.,NIL)
EndIf

Return lRet