#INCLUDE "PROTHEUS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"  
#INCLUDE "STIRECECON.CH"

Static aListTitles	:= {}	//Parcelas a receber
Static cMicroView		:= ""	//Micro view
Static oWFReceipt 	:= Nil	//Objeto que recebe a instancia da classe de recebimento de titulo
Static oPrefixo		:= Nil  //Get do prefixo
Static oNumber		:= Nil  //Get do numero
Static oParcela		:= Nil	//Get da parcela
Static oCpf			:= Nil	//Get do cpf
Static oGetCartao   := Nil  //Get do Cartao Fidelidade
Static oGetContra   := Nil  //Get do Contrato
Static oModel		:= Nil	//Objeto para criacao do model
Static cTpOp		:= ""	//Tipo de operacao R-> Recebimento ou E-> Estorno
Static cCnpjReceb   := ""   //CPF/CNPJ do cliente para selecao do Recebimento de Titulo

Static cGetCpf     := ""    //CPF/CNPJ do cliente para selecao do Recebimento de Titulo
Static cGetPref    := ""    //Prefixo do Título para selecao do Recebimento de Titulo
Static cGetNumb    := ""    //Número do Título para selecao do Recebimento de Titulo
Static cGetParc    := ""    //Parcela do Título para selecao do Recebimento de Titulo
Static cGetCartao  := ""	//Número do Cartão
Static cGetContra  := ""	//Número do Contrato


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIPanelReceb

@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIPanelReceb(cType)

Default cType := 'R'

cTpOp := cType
If FindFunction("STWActivePrinter") .And. STWActivePrinter(.T.)
	STIChangeCssBtn()
	STIBtnActivate()
	STIExchangePanel( { ||  STIReceCon() } )
EndIf

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STICancelReceb
Efetua o cancelamento do recebimento em andamento
@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STICancelReceb()

If STIGetRecTit() //Ha titulos selecionados e esta na ela de pagamentos? 
	STIExchangePanel( { ||  STIPanReceCancel() } )
Else
	STFMessage(ProcName(),"STOP",STR0017)  //"Opção disponível somente durante o Recebimento de Títulos." 
	STFShowMessage(ProcName())
EndIf

Return Nil

 


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIRebCons

@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIReceCon()

Local oPanelMVC	    := STIGetPanel()			    //Painel principal
Local oPanGetRece	:= Nil						    //Objeto do painel
Local oMdl			:= Nil							//Recebe o model para ativacao
Local cLJReceb      := SuperGetMV("MV_LJRECEB")     //Determina os campos que são apresentados na interface de Recebimento de Títulos para realização da pesquisa do(s) Título(s) à Receber.
Local oSayCartao    := Nil
Local oSayContra    := Nil

//Inicializa os Gets com espaços em branco
cGetCpf     := PadR(STIGCnpjRec(),TamSX3("A1_CGC")[1])
cGetPref    := Space(TamSX3("E1_PREFIXO")[1])
cGetNumb    := Space(TamSX3("E1_NUM")[1])
cGetParc    := Space(TamSX3("E1_PARCELA")[1])
cGetCartao  := Space(TamSX3("MA6_NUM")[1]) 
cGetContra  := Space(TamSX3("MAH_CONTRA")[1])


/* Panel */
oPanGetRece := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)

/* oSay1 - Recebimentos de títulos > Consulta */
If cTpOp == 'R'
	oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetRece,,,,,,.T.,,,,) //"Recebimentos de títulos > Consulta"
Else
	oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0002},oPanGetRece,,,,,,.T.,,,,)  //"Estorno de títulos > Consulta"
EndIf
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 

/* oSay2 - CPF/CNPJ */
oSay2 := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0003},oPanGetRece,,,,,,.T.,,,,)  //"CPF/CNPJ"
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL )) 

/* Get CPF */
oCpf := TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetCpf:=u,cGetCpf)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.35,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetCpf")
oCpf:SetCSS( POSCSS (GetClassName(oCpf), CSS_GET_FOCAL )) 

//Verifica os campos que aparecerão na interface para fazer a busca dos Titulos a Receber.
//No Totvs PDV somente foi implementada a opção 3, senão serão apresentados os campos padrão como se fosse a opção MV_LJRECEB = 1
If cLJReceb == "3"
    /* oSayCartao - Cartão */
    oSayCartao := TSay():New(POSVERT_LABEL2,POSHOR_1,{||"Ou Informe o Cartão"},oPanGetRece,,,,,,.T.,,,,)  //"Cartão"
    oSayCartao:SetCSS( POSCSS (GetClassName(oSayCartao), CSS_LABEL_FOCAL ))

    /* Get Cartão */
    oGetCartao := TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,cGetCartao:=u,cGetCartao)},oPanGetRece,120,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetCartao")
    oGetCartao:SetCSS( POSCSS (GetClassName(oGetCartao), CSS_GET_FOCAL )) 

    /* oSayContra - Contrato */
    oSayContra := TSay():New(POSVERT_LABEL2,POSHOR_2,{||"Ou Informe o Contrato"},oPanGetRece,,,,,,.T.,,,,)  //"Contrato"
    oSayContra:SetCSS( POSCSS (GetClassName(oSayContra), CSS_LABEL_FOCAL )) 

    /* Get Contrato */
    oGetContra := TGet():New(POSVERT_GET2,POSHOR_2,{|u| If(PCount()>0,cGetContra:=u,cGetContra)},oPanGetRece,120,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetContra")
    oGetContra:SetCSS( POSCSS (GetClassName(oGetContra), CSS_GET_FOCAL )) 
Else //Caso contrário, considera a opção MV_LJRECEB = 1
    /* oSay3 - Prefixo */
    oSay3 := TSay():New(POSVERT_LABEL2,POSHOR_1,{||STR0004},oPanGetRece,,,,,,.T.,,,,)  //"Prefixo"
    oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_FOCAL ))

    /* Get prefixo */
    oPrefixo := TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,cGetPref:=u,cGetPref)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.15,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetPref")
    oPrefixo:SetCSS( POSCSS (GetClassName(oPrefixo), CSS_GET_FOCAL )) 

    /* oSay4 - Numero */
    oSay4 := TSay():New(POSVERT_LABEL2,POSHOR_1 * 6.7,{||STR0005},oPanGetRece,,,,,,.T.,,,,)  //"Numero"
    oSay4:SetCSS( POSCSS (GetClassName(oSay4), CSS_LABEL_FOCAL )) 

    /* Get numero */
    oNumber := TGet():New(POSVERT_GET2,POSHOR_1 * 6.7,{|u| If(PCount()>0,cGetNumb:=u,cGetNumb)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.2,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetNumb")
    oNumber:SetCSS( POSCSS (GetClassName(oNumber), CSS_GET_FOCAL )) 

    /* oSay5 - Parcela */
    oSay5 := TSay():New(POSVERT_LABEL2,POSHOR_1 * 13.4,{||STR0006},oPanGetRece,,,,,,.T.,,,,)  //"Parcela"
    oSay5:SetCSS( POSCSS (GetClassName(oSay5), CSS_LABEL_FOCAL )) 

    /* Get parcela */
    oParcela := TGet():New(POSVERT_GET2,POSHOR_1 * 13.4,{|u| If(PCount()>0,cGetParc:=u,cGetParc)},oPanGetRece,(oPanelMVC:nWidth / 2) * 0.2,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetParc")
    oParcela:SetCSS( POSCSS (GetClassName(oParcela), CSS_GET_FOCAL )) 
EndIf

/* Botao baixar titulo */
oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0007+CRLF+"(CTRL+P)",oPanGetRece,{ || STIFindCust() },LARGBTN,ALTURABTN,,,,.T.) //"Pesq. Titulo(s)"
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

SetKey(16,{|| STIFindCust() })

oCpf:SetFocus()

/* Criacao do model */
ModelReceb()

/* Ativacao do model */
oMdl := oModel:GetModel('ABMASTER')
oMdl:DeActivate()
oMdl:Activate()


Return oPanGetRece


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} ModelDef

@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function ModelReceb()

Local oStruMst := FWFormModelStruct():New()//Variavel para criar a estrutura da tabela

If ValType(oModel) == "O"
	oModel :=	FreeObj(oModel)
EndIf	

oModel := MPFormModel():New('STIReceCon')
oModel:SetDescription(STR0008)  //"Recebimento de Titulo"
DbSelectArea("SAB")	//Necessario area selecionada da tabela para objeto FWFormModelStruct, caso contrario ocorre erro no oMdl:Activate() 
oStruMst:AddTable("SAB",{"AB_FILIAL"},STR0009)  //"Recebimento" 

oStruMst := STIStruMod(oStruMst)
oModel:AddFields( 'ABMASTER', Nil, oStruMst)
oModel:GetModel ( 'ABMASTER' ):SetDescription(STR0008) //"Recebimento de Titulo"

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIStruMod
Monta a estrutura dos campos do model

@param   	oStruMst - Objeto da FormViewStruct
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function STIStruMod(oStruMst)

Local nTamCnpj := TamSX3("A1_CGC")[1] 		//Tamanho do campo CGC do cliente
Local nTamPref := TamSX3("E1_PREFIXO")[1] //Tamanho do campo prefixo do contas a receber
Local nTamNume := TamSX3("E1_NUM")[1] 		//Tamanho do campo numero do contas a receber
Local nTamParc := TamSX3("E1_PARCELA")[1]	//Tamanho do campo parcela do contas a receber

Default oStruMst := Nil

If ValType(oStruMst) == "O"

	oStruMst:AddField(	"Filial"		,; //[01] Titulo do campo
							"Filial"		,; //[02] Desc do campo
							"AB_FILIAL"	,; //[03] Id do Field
							"C"				,; //[04] Tipo do campo
							8				,; //[05] Tamanho do campo
							0				,; //[06] Decimal do campo
							Nil				,; //[07] Code-block de validacao do campo
							Nil				,; //[08] Code-block de validacao When do campo
							Nil				,; //[09] Lista de valores permitido do campo
							Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
							Nil				,; //[11] Code-block de inicializacao do campo
							Nil				,; //[12] Indica se trata-se de um campo chave
							Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
							.T.				)  //[14] Indica se o campo e virtual

	oStruMst:AddField(	"Cpf"		,; //[01] Titulo do campo
							"Cpf"		,; //[02] Desc do campo
							"AB_CPF"	,; //[03] Id do Field
							"C"			,; //[04] Tipo do campo
							nTamCnpj	,; //[05] Tamanho do campo
							0			,; //[06] Decimal do campo
							Nil			,; //[07] Code-block de validacao do campo
							Nil			,; //[08] Code-block de validacao When do campo
							Nil			,; //[09] Lista de valores permitido do campo
							Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
							Nil			,; //[11] Code-block de inicializacao do campo
							Nil			,; //[12] Indica se trata-se de um campo chave
							Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
							.T.			)  //[14] Indica se o campo e virtual

	oStruMst:AddField(	"Prefixo"		,; //[01] Titulo do campo
							"Prefixo"		,; //[02] Desc do campo
							"AB_PREFIXO"	,; //[03] Id do Field
							"C"				,; //[04] Tipo do campo
							nTamPref		,; //[05] Tamanho do campo
							0				,; //[06] Decimal do campo
							Nil				,; //[07] Code-block de validacao do campo
							Nil				,; //[08] Code-block de validacao When do campo
							Nil				,; //[09] Lista de valores permitido do campo
							Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
							Nil				,; //[11] Code-block de inicializacao do campo
							Nil				,; //[12] Indica se trata-se de um campo chave
							Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
							.T.				)  //[14] Indica se o campo e virtual

	oStruMst:AddField(	"Numero"		,; //[01] Titulo do campo
							"Numero"		,; //[02] Desc do campo
							"AB_NUMERO"	,; //[03] Id do Field
							"C"				,; //[04] Tipo do campo
							nTamNume		,; //[05] Tamanho do campo
							0				,; //[06] Decimal do campo
							Nil				,; //[07] Code-block de validacao do campo
							Nil				,; //[08] Code-block de validacao When do campo
							Nil				,; //[09] Lista de valores permitido do campo
							Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
							Nil				,; //[11] Code-block de inicializacao do campo
							Nil				,; //[12] Indica se trata-se de um campo chave
							Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
							.T.				)  //[14] Indica se o campo e virtual

	oStruMst:AddField(	"Parcela"		,; //[01] Titulo do campo
							"Parcela"		,; //[02] Desc do campo
							"AB_PARCELA"	,; //[03] Id do Field
							"C"				,; //[04] Tipo do campo
							nTamParc		,; //[05] Tamanho do campo
							0				,; //[06] Decimal do campo
							Nil				,; //[07] Code-block de validacao do campo
							Nil				,; //[08] Code-block de validacao When do campo
							Nil				,; //[09] Lista de valores permitido do campo
							Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
							Nil				,; //[11] Code-block de inicializacao do campo
							Nil				,; //[12] Indica se trata-se de um campo chave
							Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
							.T.				)  //[14] Indica se o campo e virtual
							
EndIf

Return oStruMst


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIFindTit
Pesquisa os titulos conforme o filtro informado pelo usuario

@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIFindTit( aCliLoja )

Local oMdlMst		:= oModel:GetModel('ABMASTER')	// Seta o model do grid
Local lRet			:= .F.						    // Retorno da pesquisa dos titulos
Local oModelCli 	:= Nil							// Model do cliente selecionado
Local cCliCod 		:= ""
Local cCliLoja 		:= ""

Default aCliLoja	:= {}

aListTitles := {}

If ValType(oWFReceipt) == "O"
	oWFReceipt :=	FreeObj(oWFReceipt)
EndIf
	
STFCleanMessage(ProcName())

oMdlMst:LoadValue("AB_CPF"      , cGetCpf )
oMdlMst:LoadValue("AB_PREFIXO"  , cGetPref)
oMdlMst:LoadValue("AB_NUMERO"   , cGetNumb)
oMdlMst:LoadValue("AB_PARCELA"  , cGetParc)

If Len(aCliLoja) > 0
	cCliCod	:= aCliLoja[1]
	cCliLoja:= aCliLoja[2]
EndIf

If !Empty(cCliCod) .Or. !Empty(cGetCartao) .Or. !Empty(cGetContra)
 
	oWFReceipt := STWReceiptTitle():STWReceiptTitle( cCliCod , cCliLoja, cGetCpf, cGetPref	,;
	                                            	 cGetNumb, cGetParc, Nil	, cGetCartao,;
													 cGetContra )

	If cTpOp == 'E'
		oWFReceipt:SetReverseMode(.T.)
	Else
		oWFReceipt:SetReverseMode(.F.)
	EndIf
		
	STFMessage(ProcName(0), "STOP", STR0016  ) //"Aguarde. Buscando títulos."
	STFShowMessage(ProcName(0))
	If (lRet := oWFReceipt:LoadTitles())
		aListTitles := oWFReceipt:aListTitles[4]

		If Empty(cCliCod) .And. Empty(cCliLoja)
			cCliCod 	:= aListTitles[1][TIT_CLIE]
			cCliLoja	:= aListTitles[1][TIT_LOJA]
		EndIf
		
		STIReCliMdl( oWFReceipt:CCNPJCPF, @oModelCli, .F., cCliCod, cCliLoja )
		
		STIReceLst()
		STIPnlSelRece()
	Else
		oCpf:SetFocus()
	EndIf

EndIf

//Contingencia
If !lRet
	If cTpOp <> 'E' .AND. STFProFile(45)[1]
		/* Recebimento em contingencia */
		If EMPTY(aCliLoja)
			oWFReceipt := STWReceiptTitle():STWReceiptTitle("","",cGetCpf,cGetPref,cGetNumb,cGetParc )
		EndIf 
		
		If !Empty(oWFReceipt:CCNPJCPF)
			If !STIReCliMdl( oWFReceipt:CCNPJCPF, @oModelCli, .T., "", "" )
				oCpf:SetFocus()
			Else
				STIPanelCont()
			EndIf
		Else
			STFMessage(ProcName(),"STOP", STR0019)  //"Por favor,informe o CPF do cliente"
			STFShowMessage(ProcName())
			oCpf:SetFocus()
		EndIf	
	EndIf
	
Endif

Return lRet


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIRetTitles
Retorna os titulos que foram retornados da pesquisa

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	aListTitles
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIGetTitles()
Return aListTitles

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIRetObjTit
Retorna o objeto que deu origem a instancia da classe STWReceiptTitle

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	oWFReceipt
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIRetObjTit()
Return oWFReceipt

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIGetTpOp
Retorna o tipo de operacao que esta sendo executada

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	oWFReceipt
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIGetTpOp()
Return cTpOp


//-------------------------------------------------------------------
/*/{Protheus.doc} STIGCnpjRec
Retorna o CPF/CNPJ do cliente selecionado para utilizar 
no Panel de Recebimento de Titulo.

@author Varejo
@since 09/04/2015
@return  CPF ou CNPJ do cliente selecionado para utilizar no Panel de Recebimento de Titulo.
@version 11.80
/*/
//-------------------------------------------------------------------
Function STIGCnpjRec()
Return cCnpjReceb

//-------------------------------------------------------------------
/*/{Protheus.doc} STISCnpjRec
Funcao utilizada para setar o CPF/CNPJ do cliente selecionado para utilizar 
no Panel de Recebimento de Titulo.

@param  CPF ou CNPJ do cliente
@author Varejo
@since 09/04/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function STISCnpjRec( cCpfCnpj )
cCnpjReceb := cCpfCnpj
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanReceCancel
Contexto Cancelar recebimento de titulo

@param
@author  Vendas & CRM
@version P11.8
@since   26/06/2015
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STIPanReceCancel()

Local oPanSaleCancel	:= Nil 				// Painel Cancelamento de Venda
Local oPanelMVC			:= STIGetPanel() 	// Painel Principal
Local oBtnConfirm		:= Nil				// Botao de confirmação "Cancelar Recebimento"
Local oBtnCancel		:= Nil				// Botao de confirmação "Cancelar"

oPanSaleCancel := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)

oSay1	:= TSay():New(POSVERT_CAB,POSHOR_1,{|| STR0013 },oPanSaleCancel,,,,,,.T.,,,,) //"Confirma o cancelamento do recebimento?"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 


oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0014,oPanSaleCancel,{ || (STFRestart(), STIRegItemInterface()) }, ; //"Cancelar Recebimento"
							LARGBTN,ALTURABTN,,,,.T.)

oBtnCancel := TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0015,oPanSaleCancel,{ || STIBaixaTit() }, ; //"Não Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)

oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL )) 							
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel), CSS_BTN_ATIVO ))

Return oPanSaleCancel

//-------------------------------------------------------------------
/*/{Protheus.doc} STIReCliMdl
Configura na Cesta os Dados do Cliente

@param cCPF // CPF do Cliente
@param oModelCli //Modelo do Cliente
@author  Vendas & CRM
@version P12.1.14
@since   26/01/2017
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIReCliMdl( cCPF, oModelCli, lContingency, cCodCli, cLojaCli )
Local lRetCli 	:= .F.
Local lFound	:= .F.
Local nIndex	:= 0
Local cSeek		:= ""

If !Empty(cCPF)
	nIndex 	:= 3 //A1_FILIAL + A1_CGC
	cSeek	:= xFilial("SA1") + cCPF
ElseIf !Empty(cCodCli) .And. !Empty(cLojaCli)
	cCodCli := PadR(cCodCli,TamSX3("A1_COD")[1])
	cLojaCli:= PadR(cLojaCli,TamSX3("A1_LOJA")[1])
	nIndex 	:= 1 //A1_FILIAL + A1_COD + A1_LOJA
	cSeek	:= xFilial("SA1") + cCodCli + cLojaCli
EndIf

If !Empty(cSeek)
	SA1->(DbSetOrder(nIndex))
	lFound 	:= SA1->(DbSeek(cSeek))
	lRetCli := lFound
	
	If !lFound .AND. lContingency
		lRetCli := MsgYesNo(STR0021) //"Não localizado localmente o cliente. Prosseguir com o recebimento?"
	EndIf
	
	If lRetCli
		If Empty(cCPF)
			cCPF := SA1->A1_CGC
			oWFReceipt:CCNPJCPF := cCPF
		EndIf

		oModelCli := STWCustomerSelection(SA1->A1_COD+SA1->A1_LOJA)
		STDSPBasket("SL1","L1_CLIENTE"	,oModelCli:GetValue("SA1MASTER","A1_COD"))
		STDSPBasket("SL1","L1_LOJA"		,oModelCli:GetValue("SA1MASTER","A1_LOJA"))
		STDSPBasket("SL1","L1_TIPOCLI"	,oModelCli:GetValue("SA1MASTER","A1_TIPO"))
			
		If FindFunction("STISCnpjRec")
			STISCnpjRec(cCPF)
		EndIf
		oWFReceipt:cCode	:= SA1->A1_COD			//Codigo do Cliente
		oWFReceipt:cBranch 	:= SA1->A1_LOJA	
		
		If Type("oWFReceipt:cName") == "C"
			oWFReceipt:cName := SA1->A1_NOME
		EndIf
	EndIf

EndIf

Return lRetCli


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIFindCust
Pesquisa Cliente conforme o CNPJ/CPF informado pelo usuario

@param   	
@author  	Joao Marcos Martins
@version 	12.1.17
@since   	08/03/2018
@return  	lRet
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIFindCust() 

Local lRet				:= .F.								//Retorno da pesquisa dos titulos
Local aCliLoja			:= {}
Local lSelectCust		:= ExistFunc("STDRSelCust") .AND. ExistFunc("STIPnlSelCust") .AND. ExistFunc("STDGCustTt") // Funções relacionadas a tela de seleção de cadastro caso o cliente tenha mais de uma loja cadastrada
Local cLJReceb      	:= SuperGetMV("MV_LJRECEB")
Local cMsgErro 			:= ""

If !Empty(cGetCpf)
	cGetCpf := StrTran(cGetCpf, ".", "")
	cGetCpf := StrTran(cGetCpf, "-", "")
	cGetCpf := StrTran(cGetCpf, "/", "")
EndIf

If !Empty(cGetCartao)
	cGetCartao := StrTran(cGetCartao, ".", "")
	cGetCartao := StrTran(cGetCartao, "-", "")
	cGetCartao := StrTran(cGetCartao, "/", "")
EndIf

If !Empty(cGetContra)
	cGetContra := StrTran(cGetContra, ".", "")
	cGetContra := StrTran(cGetContra, "-", "")
	cGetContra := StrTran(cGetContra, "/", "")
EndIf

If cLJReceb == "3"
	If !Empty(cGetCpf) .Or. !Empty(cGetCartao) .Or. !Empty(cGetContra)
		lRet := .T.
	Else
		lRet := .F.
		cMsgErro := STR0023 //"Por favor, informe o CPF/CNPJ ou Cartão ou Contrato."
	EndIf
Else
	If !Empty(cGetCpf)
		lRet := .T.
	Else
		lRet := .F.
		cMsgErro := STR0012 //"Por favor, preencha o campo CPF/CNPJ é obrigatório."
	EndIf
EndIf

If lRet
	
	If lSelectCust
		
		If !Empty(cGetCartao) .Or. !Empty(cGetContra)
			STIFindTit()
		Else

			aCliLoja := STDRSelCus(cGetCpf)
			
			// Se o CNPJ/CPF informado tiver mais de um cadastro chama tela de selecao de cliente
			If Len(aCliLoja) > 1
				
				STIPnlSelCust(aCliLoja)

			Else
				If Len(aCliLoja) > 0
					aCliLoja := STDGCustTt(aCliLoja[1])

					STIFindTit(aCliLoja)
				Else
					lRet 	:= .F.
					cMsgErro:= STR0022 //"CPF/CNPJ não encontrado! Caso queira acessar a retaguarda, verifique o parametro MV_LJPEATU = 1."
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lRet .And. !Empty(cMsgErro)
	STFMessage(ProcName(),"STOP",cMsgErro)
	STFShowMessage(ProcName())
	oCpf:SetFocus()
EndIf	
		
Return lRet