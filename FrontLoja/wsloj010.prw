#INCLUDE "WSLOJ010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#DEFINE _FORMATEF				 "CC;CD" //Formas de pagamento que utilizam opera็ใo TEF para valida็ใo
 
Function WSLOJ010	
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjFinaCel บAutor  ณVendas Clientes     บ Data ณ  19/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Webservices de inclusao de titulo na retaguarda para re-   บฑฑ
ฑฑบ          ณ carga de celular                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
WSSERVICE LjFinaCel DESCRIPTION STR0001 		// "Servi็o de inclusao de titulo para recarga de celular (<b>Automa็ใo Comercial</b>)"

	WSMETHOD IncluiTit DESCRIPTION STR0002 		// "Inclui os valores da recarga em dinheiro"
    WSMETHOD Conecta   DESCRIPTION STR0003 		// "Verifica se o WebService esta Conectado"

	WSDATA cPref 		As String 
	WSDATA cNumTit		As String 
	WSDATA cParcela		As String 
	WSDATA cTipo		As String 
	WSDATA cNatureza	As String
	WSDATA cCliente		As String 
	WSDATA cLoja		As String 
	WSDATA dEmiss		As Date
	WSDATA dVencto		As Date
	WSDATA cHist		As String
	WSDATA nMoeda		As Float
	WSDATA cRotina		As String
	WSDATA nValtit		As Float
	WSDATA cPortado		As String
	WSDATA lRet 		As Boolean
	WSDATA cBanco		As String
	WSDATA cAgencia		As String
	WSDATA cConta		As String
	WSDATA cNumChq		As String
	WSDATA cCompensa	As String
	WSDATA cRg			As String
	WSDATA cTel			As String
	WSDATA lTerceiro	As Boolean
	WSDATA EmpPdv   	AS String     OPTIONAL    
	WSDATA FilPdv   	AS String     OPTIONAL    
	WSDATA MvLjPdvPa   	AS Boolean    OPTIONAL
	WSDATA cValor		As String OPTIONAL
	WSDATA cNsuSiTef	As String OPTIONAL
	WSDATA lDirecao		As Boolean OPTIONAL  	    
	WSDATA cNsuCart  	As String OPTIONAL  
	WSDATA cCodAdm		As String OPTIONAL
	WSDATA lIsCartao	AS Boolean OPTIONAL	
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncluiTit บAutor  ณMicrosiga           บ Data ณ  02/19/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo que inclui um titulo baixado                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSMETHOD IncluiTit WSRECEIVE	cPref		, cNumTit	, cParcela	, cTipo		,;
								cNatureza	, cCliente	, cLoja		, dEmiss	,;
								dVencto		, cHist		, nMoeda	, cRotina	,;
								nValtit 	, cPortado	, cBanco	, cAgencia	,;
								cConta		, cNumChq	, cCompensa , cRg 		,;
								cTel		, lTerceiro , EmpPdv	, FilPdv	,;
								MvLjPdvPa	, cNsuSiTef	, cNsuCart	, cCodAdm	,;
								lIsCartao 	WSSEND lRet WSSERVICE LjFinaCel

//ATENCAO !!! Nenhum acesso ao Dicionario de Dados (SX's) ou Banco de Dados deve ser feito antes de executar essa funcao LjPreparaWs
If !Empty(EmpPdv) .And. !Empty(FilPdv)
	LjPreparaWs(EmpPdv,FilPdv)
EndIf

//lRet eh o atributo de retorno desse Web Service
lRet := IncTitRCel(	cPref		, cNumTit	, cParcela	, cTipo		,;
					cNatureza	, cCliente	, cLoja		, dEmiss	,;
					dVencto		, cHist		, nMoeda	, cRotina	,;
					nValtit 	, cPortado	, cBanco	, cAgencia	,;
					cConta		, cNumChq	, cCompensa , cRg 		,;
					cTel		, lTerceiro , cNsuSiTef	, cNsuCart	,;
					cCodAdm		, lIsCartao	)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConecta   บAutor  ณMicrosiga           บ Data ณ  16/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o WS esta conectado					          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSMETHOD Conecta WSRECEIVE cValor WSSEND lRet WSSERVICE LjFinaCel

lRet := .T.

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณIncTitRCelบAutor  ณMicrosiga           บ Data ณ  07/05/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao responsavel em criar e baixar um titulo referente	บฑฑ
ฑฑบ          ณ a Recarga de Celular										บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMetodo IncluiTit / LjGrvBaixaCel (LOJXTEF)				บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function IncTitRCel(   	cPref		, cNumTit	, cParcela	, cTipo		,;
						cNatureza	, cCliente	, cLoja		, dEmiss	,;
						dVencto		, cHist		, nMoeda	, cRotina	,;
						nValtit 	, cPortado	, cBanco	, cAgencia	,;
						cConta		, cNumChq	, cCompensa , cRg 		,;
						cTel		, lTerceiro , cNsuSiTef	, cNsuCart	,;
						cCodAdm		, lIsCartao	)

Local aDados		:= {}			//Campos do SE1 que necessitam ser enviados
Local aArea	    	:= GetArea() 
Local nDias			:= 0			//Dias de Vencimento do Cart]ao
Local nTaxa			:= 0 			//Taxa da Adm do Cartao  
Local cDescAdm		:= "" 			//Nome da administradora
Local lRet			:= .T.			//Retorno da funcao
Local aDadosCH		:= {}
Local cErro			:= ""
Local aDadosSE2		:= {}
Local lGeraTaxa 	:= SuperGetMV("MV_LJGERTX",,.F.)	// Verifica se ira gerar um Contas a Pagar quando existir taxa na admistradora do cartao.
Local cNumSA2		:= ""		   						// Numero do fornecedor (SE2)
Local nValSE1		:= 0

DEFAULT lIsCartao 	:= .F.  
DEFAULT cNsuSiTef 	:= ""
DEFAULT	cNsuCart 	:= ""
DEFAULT cCodAdm		:= ""

Private lMsErroAuto := .F.

//Valor do titulo financeiro que sera gerado
nValSE1 := nValTit

If lIsCartao .AND. !Empty(AllTrim(cCodAdm))
	WLj010Adm(	@cCodAdm,	@cLoja,	@cDescAdm,	@nDias,;
				@nTaxa, @cCliente	)
EndIf

If lIsCartao
	If cTipo == "CC"
		cNatureza := "MV_NATCART"
	Else
		cNatureza := "MV_NATTEF"
	EndIf
	
	cNatureza := LjMExeParam(cNatureza)
	
	// Caso o parametro MV_LJGERTX = T gera o valor bruto na SE1 e grava o valor da taxa na SE2
	If !lGeraTaxa
		nValSE1 := (nValTit - ((nValTit * nTaxa)/100))
	EndIf
	
ElseIf cTipo == "CH"
	cNatureza := "MV_NATCHEQ"
	cNatureza := LjMExeParam(cNatureza)
ElseIf Empty(AllTrim(cNatureza))
	cNatureza := SuperGetMv("MV_NATRC",,"")
EndIf

aDados := {	{ "E1_PREFIXO"	, cPref						,Nil} ,;
			{ "E1_NUM"	  	, cNumTit 					,Nil} ,;
			{ "E1_PARCELA" 	, cParcela					,Nil} ,;
			{ "E1_TIPO"	 	, cTipo						,Nil} ,;
			{ "E1_NATUREZ" 	, cNatureza					,Nil} ,;
	      	{ "E1_CLIENTE" 	, cCliente					,Nil} ,;
	      	{ "E1_LOJA"	  	, cLoja						,Nil} ,;
			{ "E1_EMISSAO" 	, dEmiss 					,Nil} ,;
	       	{ "E1_VENCTO"  	, dVencto+nDias				,Nil} ,;
	       	{ "E1_VENCREA" 	, DataValida(dVencto+nDias)	,Nil} ,;
	       	{ "E1_VENCORI" 	, dVencto+nDias				,Nil} ,;	       	
	       	{ "E1_HIST" 	, cHist						,Nil} ,;
	       	{ "E1_MOEDA" 	, nMoeda					,Nil} ,;
			{ "E1_ORIGEM"	, cRotina					,Nil} ,;
			{ "E1_FLUXO"	, "S"						,Nil} ,;
		   	{ "E1_VALOR"	, nValSE1					,Nil} ,;
		   	{ "E1_PORTADO"	, cPortado					,Nil} }

If cTipo == "CH"
	aAdd( aDados, { "E1_BCOCHQ"	,cBanco						,Nil} )
	aAdd( aDados, { "E1_AGECHQ" ,cAgencia					,Nil} )
	aAdd( aDados, { "E1_CTACHQ"	,cConta						,Nil} )
EndIf

If lIsCartao
	aAdd( aDados, {"E1_VLRREAL"	, nValTit	, Nil} )
	aAdd( aDados, {"E1_DOCTEF"	, cNsuSiTef	, Nil} )
	aAdd( aDados, {"E1_NSUTEF"  , cNsuCart  , Nil} )
EndIf

//MsExecAuto para inclusao do titulo
LjGrvLog(Nil,"Grava็ใo da recarga - Antes da ExecAuto FINA040 ",aDados)
MSExecAuto( { |x,y| Fina040( x, y ) }, aDados, 3 ) //Inclusao
LjGrvLog(Nil,"Grava็ใo da recarga - Depois da ExecAuto FINA040")

If !lMsErroAuto	//verifica se o execauto de inclusao do titulo foi executado com sucesso
	
	If lGeraTaxa .And. lIsCartao
		
		//-----------------------------------------------------
		// Inclui o Fornecedor caso nao tenha sido cadastrado,
		// e retorna com o codigo para gerar SE2              
		//-----------------------------------------------------
		cNumSA2 := L070IncSA2()	
		
		aDadosSE2 := {	{"E2_PREFIXO"	, SE1->E1_PREFIXO			,Nil},;
						{"E2_NUM"	   	, SE1->E1_NUM    			,Nil},;
						{"E2_PARCELA"	, SE1->E1_PARCELA			,Nil},;
						{"E2_TIPO"		, SE1->E1_TIPO   			,Nil},;		
						{"E2_NATUREZ"	, SE1->E1_NATUREZ			,Nil},;
						{"E2_FORNECE"	, cNumSA2	 				,Nil},;
						{"E2_LOJA"		, SE1->E1_LOJA   			,Nil},; 
						{"E2_EMISSAO"	, dDataBase      			,NIL},;
						{"E2_VENCTO"	, SE1->E1_VENCTO 			,NIL},;				 
						{"E2_VENCREA"	, SE1->E1_VENCREA			,NIL},;				 					
						{"E2_VALOR"		, (nValTit * (nTaxa / 100))	,NIL},; 
						{"E2_HIST"		, AllTrim(SE1->E1_NUM)		,NIL} }  														
		             
		lMsErroAuto := .F.  	 	
		
		//------------------------------------------------
		// Faz a inclusao do contas a pagar via ExecAuto 
		//------------------------------------------------
		LjGrvLog(Nil,"Grava็ใo da recarga - Antes da ExecAuto FINA050 ",aDadosSE2)
		MSExecAuto({|x,y,z| Fina050(x,y,z)},aDadosSE2,,3) 
		LjGrvLog(Nil,"Grava็ใo da recarga - Depois da ExecAuto FINA050")
	
	EndIf
	
	aDadosCH := {}
	Aadd(aDadosCH , {	cBanco  , cAgencia 	, cConta	, cNumChq	,;
	 					nValTit , dEmiss   	, cCompensa	, cRg    	,;
	 					cTel    , lTerceiro	, cPref	  	, cNumTit	,;
	 					cParcela})
	    			
	lRet := WLj010FimGrv(	"WSLOJ010"	,cTipo		, cDescAdm	,	cHist	,;
				 			cCliente	,cNumTit	, @aDadosCH				)	
Else
	cErro := MostraErro()
	LjGrvLog(Nil, cErro)
	Conout(cErro)
	DisarmTransaction()
	lRet := .F.
EndIf

RestArea( aArea )

Return lRet


//----------------------------------------------------------------
/*/{Protheus.doc} WLj010Adm
Pesquisa de Adm Financeira 

@param  cIndice , string , Indice da tabela MDK e MDJ
@param  aMDK, array , retono que contem a tabela MDK
@author  Varejo
@version P11
@since   29/11/2016
@return  aMDK	
/*/
//----------------------------------------------------------------
Function WLj010Adm(	cCodAdm,	cLoja,	cDescAdm,	nDias,;
					nTaxa, cCliente	)

Local aSA1Area	:= {}
Local aSAEArea	:= {}
Local aRetTp	:= {}
Local lAdmProp	:= .F.
Local lAchouAdm	:= .F.

Default cCodAdm := ""
Default cCliente := ""

If !Empty(AllTrim(cCodAdm))
	DbSelectArea("SAE")
	aSAEArea := SAE->(GetArea())
	
	SAE->( DbSetOrder(1) )	//AE_FILIAL + AE_COD
	If SAE->( DbSeek(xFilial("SAE") + PadR(cCodAdm,TamSx3("AE_COD")[1])))
		aRetTp	:= LjGrvTpFin( SAE->AE_FINPRO, SAE->AE_AGLPARC )
		lAdmProp:= aRetTp[2] 
	
		If !lAdmProp

            If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                cCliente := SAE->AE_CODCLI
                cLoja	 := SAE->AE_LOJCLI
            Else

                aSA1Area := SA1->( GetArea() )
                
                cCliente := SAE->AE_CODCLI

                SA1->( DbSetOrder(1) )
                If SA1->( DbSeek( xFilial('SA1') + cCliente) ) .And.;
                    Upper( AllTrim(SA1->A1_NOME) ) == Upper( AllTrim(SAE->AE_DESC) )
                    
                    cLoja	:=  SA1->A1_LOJA
                EndIf

                RestArea(aSA1Area)
            EndIf

            cCliente := PadR(cCliente, TamSX3("E1_CLIENTE")[1])
            cLoja	 := PadR(cLoja   , TamSX3("E1_LOJA")[1]   )
			cDescAdm :=  SAE->AE_DESC
		Else
			nDias    := SAE->AE_DIAS
		EndIf
	
		nTaxa	:= SAE->AE_TAXA
		lAchouAdm:= .T.
	EndIf
	
	RestArea(aSAEArea)
EndIf

Return lAchouAdm

//----------------------------------------------------------------
/*/{Protheus.doc} WLj010FimGrv
Finaliza grava็ใo das tabelas para a recarga 

ATENวรO: SE1 jแ virแ posicionado

@param  cIndice , string , Indice da tabela MDK e MDJ
@param  aMDK, array , retono que contem a tabela MDK
@author  Varejo
@version P11
@since   29/11/2016
@return  aMDK	
/*/
//----------------------------------------------------------------
Function WLj010FimGrv(	cOrigem		, 	cTipo 	,	cDescAdm, cHist,;
						cCliente	,	cNumTit	,	aDadosCH)
Local lRet		:= .T.
Local aVetor	:= {}
Local cErro		:= ""

Default cOrigem := ""
Default cTipo 	:= ""
Default cDescAdm:= ""
Default cHist	:= ""
Default cCliente:= ""
Default cNumTit := ""
Default aDadosCH:= {}

cTipo := AllTrim(cTipo)

If cOrigem == "WSLOJ010"
	If cTipo $ _FORMATEF
		If !Empty(cDescAdm)
			RecLock("SE1", .F.)
			Replace SE1->E1_NOMCLI With cDescAdm
			SE1->( MsUnLock() )
		EndIf
		
		If AliasInDic("MEP")
			RecLock("MEP", .T.)
				REPLACE MEP->MEP_FILIAL WITH xFilial("MEP")
				REPLACE MEP->MEP_PREFIX WITH SE1->E1_PREFIXO
				REPLACE MEP->MEP_NUM 	WITH SE1->E1_NUM
				REPLACE MEP->MEP_PARCEL WITH SE1->E1_PARCELA
				REPLACE MEP->MEP_TIPO   WITH SE1->E1_TIPO
				REPLACE MEP->MEP_PARTEF WITH StrZero(1, TamSX3("MEP_PARTEF")[1])
			MEP->( MsUnLock() )
		EndIf
	EndIf
	
	If cTipo == "CH"
		LjGrvLog(Nil, "Grava็ใo Recarga em cheque - dados:", aDadosCH)
		If Len(aDadosCH) > 0
			LjGrvLog(Nil, "Grava็ใo Recarga em cheque - Antes da fun็ใo LjRecGrvCH")
			LJRecGrvCH( aDadosCH[1][1] /*cBanco*/  , aDadosCH[1][2]/*cAgencia*/ 	, aDadosCH[1][3]/*cConta*/	, aDadosCH[1][4]/*cNumChq*/	,;
						aDadosCH[1][5]/*nValTit*/ , aDadosCH[1][6]/*dEmiss*/   	, aDadosCH[1][7]/*cCompensa*/	, aDadosCH[1][8]/*cRG*/    	,;
						aDadosCH[1][9]/*cTel*/    , aDadosCH[1][10]/*lTerceiro*/	, aDadosCH[1][11]/*cPref*/	  	, cNumTit	,;
						aDadosCH[1][13], cTipo  	)
			LjGrvLog(Nil, "Grava็ใo Recarga em cheque - Depois da fun็ใo LjRecGrvCH")
		EndIf
		
		LjGrvLog(Nil, "Grava็ใo Recarga em cheque - Antes da altera็ใo SEF")
	 	RecLock("SEF", .F.)
		 	REPLACE SEF->EF_CLIENTE WITH cCliente
		 	REPLACE SEF->EF_LOJACLI WITH SA1->A1_LOJA
		 	REPLACE SEF->EF_EMITENT	WITH SA1->A1_NOME
		 	REPLACE SEF->EF_NUMNOTA	WITH cNumTit		 	
		 	REPLACE SEF->EF_SERIE	WITH IIf( Len(aDadosCH) > 0, aDadosCH[1][11], "" )
	 	SEF->( MsUnlock() )
	 	LjGrvLog(Nil, "Grava็ใo Recarga em cheque - Depois da altera็ใo SEF")
	EndIf
EndIf
	
If cTipo == SuperGetMV("MV_SIMB1")
	LjGrvLog(Nil, "Grava็ใo Recarga em dinheiro - titulo serแ baixado")
	aVetor := {	{ "E1_PREFIXO" 	,SE1->E1_PREFIXO			, Nil},	;	// 01
				{ "E1_NUM"     	,SE1->E1_NUM				, Nil},	;	// 02
				{ "E1_PARCELA" 	,SE1->E1_PARCELA			, Nil},	;	// 03
				{ "E1_TIPO"    	,SE1->E1_TIPO				, Nil},	;	// 04
				{ "E1_MOEDA"    ,SE1->E1_MOEDA				, Nil},	;	// 05
				{ "E1_TXMOEDA"	,SE1->E1_TXMOEDA			, Nil},	;	// 06
				{ "E1_ORIGEM"	,SE1->E1_ORIGEM				, Nil},	;	// 07
				{ "AUTVALREC"	,SE1->E1_VALOR  			, Nil},	;	// 06
				{ "AUTMOTBX"  	,"NOR"						, Nil},	;	// 07
				{ "AUTDTBAIXA"	,dDataBase					, Nil},	;	// 08
				{ "AUTDTCREDITO",dDataBase					, Nil},	;	// 09
				{ "AUTHIST"   	,cHist						, Nil}, ;	// 13
				{ "AUTTIPODOC" 	,"LJ"						, Nil}, ;	
				{ "AUTBANCO"   	,SE1->E1_PORTADO			, Nil}, ;	
				{ "AUTAGENCIA" 	,SE1->E1_AGEDEP				, Nil}, ;	
				{ "AUTCONTA"   	,SE1->E1_CONTA				, Nil}	}	
				
	//ExecAuto para baixar o titulo
	LjGrvLog(Nil, "Grava็ใo Recarga em dinheiro - Antes da ExecAuto - FINA070")
	MsExecAuto( { |x,y| FINA070( x, y ) }, aVetor, 3 )
	LjGrvLog(Nil, "Grava็ใo Recarga em dinheiro - Depois da ExecAuto - FINA070")
	
	If lMsErroAuto
		LjGrvLog(Nil, "Grava็ใo Recarga em dinheiro - Erro de execAuto - FINA070")
		If cOrigem == "WSLOJ010"
			cErro := MOSTRAERRO()
			LjGrvLog(Nil, cErro )	
			Conout( cErro )
			DisarmTransaction()
		EndIf
		lRet := .F.
	EndIf
EndIf

Return lRet
