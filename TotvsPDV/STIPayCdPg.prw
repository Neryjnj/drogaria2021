#Include "Protheus.ch"
#Include "FWEVENTVIEWCONSTS.CH" 
#Include "FWADAPTEREAI.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"     
#INCLUDE "STIPAYCDPG.CH"
#INCLUDE "STPOS.CH"

Static oModel		:= Nil	//Carrega o model
Static oLblFont 	:= TFont():New( "Calibri"	, ;		// cName 	Caractere, opcional. Nome da fonte, o padrão é "Arial". 
									Nil				, ;		// nPar2 	Reservado.
									-14				, ;		// nHeight 	Numérico, opcional. Tamanho da fonte. O padrão é -11. 
									Nil				, ;		// lPar4 	Reservado.
									.T.				  )		// lBold 	Lógico, opcional. Se .T. o estilo da fonte será negrito.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STICondPag

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	21/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIPayCdPg(oPnlAdconal)

Local oPanelMVC		:= STIGetPanel()		// Objeto do Panel onde a interface de selecao de clientes sera criada
Local oLstCdPg 		:= Nil //Objeto listbox

Local oBtnOk		:= Nil //Objeto de button OK
Local oBtnCa		:= Nil //Objeto de button Cancel

Local nLstCpTA		:= oPnlAdconal:nHeight/7	//Tamanho: Altura do listbox
Local lReadOnly		:= FindFunction("STIGetPayRO") .AND. STIGetPayRO()	//indica se os campos de pagamento estão como Somente Leitura (permissão Alterar Parcelas do caixa)

oLstCdPg := TListBox():Create(oPnlAdconal, POSVERT_PAYGET1, POSHOR_PAYCOL1, Nil, Nil, LARG_LIST_CONSULT, nLstCpTA,,,,,.T.,,{|| STICPConfPay(oLstCdPg,oPnlAdconal) },,,,)
oLstCdPg:SetCSS( POSCSS (GetClassName(oLstCdPg), CSS_LISTBOX )) 
oLstCdPg:lReadOnly := lReadOnly

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0001,oPnlAdconal,{|| STICPConfPay(oLstCdPg,oPnlAdconal) },LARGBTN,ALTURABTN,,,,.T.) //'Efetuar Pagamento'

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,000,STR0002,oPnlAdconal,{|| IIF(ExistFunc("STBCancPay"), IIF(STBCancPay(),STIPayCancel(),NIL), STIPayCancel() ) },LARGBTN,ALTURABTN,,,,.T.) //'Cancelar'

oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL ))
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 


/* Criacao do model */
ModelCdPg()

/* Add as Cond pgtos no listbox e model */
STIAddCPg(oLstCdPg)

oLstCdPg:GoTop()
oLstCdPg:SetFocus()

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} ModelCdPg

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	22/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function ModelCdPg()

Local oStruMst 	:= Nil
Local oStruDtl 	:= Nil

If ValType(oModel) == 'O'
	oModel:DeActivate()
	oModel := Nil
EndIf

oStruMst 	:= FWFormModelStruct():New()
oStruDtl 	:= FWFormModelStruct():New()

oModel := MPFormModel():New("STIPayCdPg")
oModel:SetDescription(STR0006) //"Cond. Pg"

oStruDtl:AddTable("SL4",{"L4_FILIAL"},"Condicao")

oStruMst := STIStruMod(oStruMst, "Mst")
oModel:AddFields( 'CDPGMASTER', Nil, oStruMst)
oModel:GetModel ( 'CDPGMASTER' ):SetDescription(STR0006) //"Cond. Pg"
oModel:SetPrimaryKey({})

oStruDtl := STIStruMod(oStruDtl, "Dtl")
oModel:AddGrid('CDPGDETAILS','CDPGMASTER',oStruDtl, Nil, Nil, Nil, Nil, Nil)
oModel:GetModel( 'CDPGDETAILS' ):SetDescription(STR0006) //"Cond. Pg"
oModel:GetModel( 'CDPGDETAILS' ):SetOptional(.T.)

Return oModel


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} ViewDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	22/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function ViewDef()

Local oModel 		:= FWLoadModel( 'STIPayCdPg' )	//Modelo de Dados baseado no ModelDef do fonte informado
Local oStruGrd	:= FWFormViewStruct():New()		//Cria a estrutura dos campos que irao compor a view

oView := Nil
oView := FWFormView():New()

oView:SetModel(oModel)
oView:CreateHorizontalBox('MST1',100)

//Grid das parcelas
oStruGrd := STIStruVie(oStruGrd,'Dtl')
oView:AddGrid( 'CDPGVIEWDTL' , oStruGrd, 'CDPGDETAILS' ) 
oView:SetOwnerView('CDPGVIEWDTL','MST1')
oView:EnableTitleView('CDPGVIEWDTL',STR0003) //'Condição de Pagamento'
oView:SetOnlyView('CDPGVIEWDTL')

//Inclui as informacoes no Grid
oView:SetAfterViewActivate( { |oView| STIAddCPg(oView) } )

Return oView

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIStruMod
Estrutura do Model

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	25/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function STIStruMod(oStru, cType)

Default oStru := Nil
Default cType := ""

If cType == 'Mst'

	oStru:AddField(	STR0004		,; //[01] Titulo do campo
						STR0004		,; //[02] Desc do campo //"Filial"
						"L4_FILIAL"	,; //[03] Id do Field
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

Else
	
	oStru:AddField(	""				,; //[01] Titulo do campo
						""				,; //[02] Desc do campo
						"L4_MARCAR"	,; //[03] Id do Field
						"L"				,; //[04] Tipo do campo
						1				,; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0006	,; //[01] Titulo do campo
						STR0005	,; //[02] Desc do campo
						"L4_CODIGO",; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						TamSx3("E4_CODIGO")[1],; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0006	,; //[01] Titulo do campo
						STR0006	,; //[02] Desc do campo //"Cond. Pagto"
						"L4_CONDICAO"	,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						TamSx3("E4_COND")[1],; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0007		,; //[01] Titulo do campo
						STR0007		,; //[02] Desc do campo FORMA
						"L4_FORMA"		,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						TamSx3("E4_FORMA")[1],; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0008		,; //[01] Titulo do campo
						STR0008		,; //[02] Desc do campo //"Tipo"
						"L4_TIPO"	,; //[03] Id do Field
						"C"			,; //[04] Tipo do campo
						TamSx3("E4_TIPO")[1],; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0009		,; //[01] Titulo do campo //"Desc Fin"
						STR0009		,; //[02] Desc do campo
						"L4_DESCFIN"	,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						5				,; //[05] Tamanho do campo
						2				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0010	,; //[01] Titulo do campo
						STR0010	,; //[02] Desc do campo
						"L4_ACRSFIN"	,; //[03] Id do Field
						"N"				,; //[04] Tipo do campo
						6				,; //[05] Tamanho do campo
						2				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual

	oStru:AddField(	STR0011	,; //[01] Titulo do campo
						STR0011	,; //[02] Desc do campo
						"L4_ACRES"		,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						TamSx3("E4_ACRES")[1],; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.				)  //[14] Indica se o campo e virtual
			
EndIf		
											
Return oStru

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIStruVie
Estrutura da View

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	25/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function STIStruVie(oStru)

Default oStru	:= Nil

oStru:AddField( 	"L4_MARCAR"	,; //[01] CIDFIELD - ID DO FIELD
					"01"			,; //[02] CORDEM - ORDEM DO CAMPO
					""				,; //[03] CTITULO - TITULO DO CAMPO
					""				,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
					{}				,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
					"L"				,; //[06] CTYPE - TIPO
					""				,; //[07] CPICTURE - PICTURE DO CAMPO
					Nil				,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
					""				,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
					.T.				,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
					Nil				,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
					Nil				,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
					Nil				,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
					Nil				,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPçãO DO COMBO
					Nil				,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
					.T.				,; //[16] LVIRTUAL - INDICA SE O CAMPO é VIRTUAL
					Nil				)  //[17] CPICTVAR - PICTURE VARIAVEL
			
oStru:AddField( 	"L4_CODIGO"	,; //[01] CIDFIELD - ID DO FIELD
					"02"			,; //[02] CORDEM - ORDEM DO CAMPO
					STR0005		,; //[03] CTITULO - TITULO DO CAMPO
					STR0005		,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
					{}				,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
					"C"				,; //[06] CTYPE - TIPO
					"@!"			,; //[07] CPICTURE - PICTURE DO CAMPO
					Nil				,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
					""				,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
					.T.				,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
					Nil				,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
					Nil				,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
					Nil				,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
					Nil				,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPçãO DO COMBO
					Nil				,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
					.T.				,; //[16] LVIRTUAL - INDICA SE O CAMPO é VIRTUAL
					Nil				)  //[17] CPICTVAR - PICTURE VARIAVEL
					
oStru:AddField( 	"L4_CONDICAO"		,; //[01] CIDFIELD - ID DO FIELD
					"03"				,; //[02] CORDEM - ORDEM DO CAMPO
					STR0006	,; //[03] CTITULO - TITULO DO CAMPO
					STR0006	,; //[04] CDESCRIC - ESCRICAO COMPLETA DO CAMPO
					{}					,; //[05] AHELP - ARRAY COM O HELP DOS CAMPOS
					"C"					,; //[06] CTYPE - TIPO
					"@!"				,; //[07] CPICTURE - PICTURE DO CAMPO
					Nil					,; //[08] BPICTVAR - BLOCO DE PICTURE VAR
					""					,; //[09] CLOOKUP - CHAVE PARA SER USADO NO LOOKUP
					.T.					,; //[10] LCANCHANGE - LOGICO DIZENDO SE O CAMPO PODE SER ALTERADO
					Nil					,; //[11] CFOLDER - ID DA FOLDER ONDE O FIELD ESTA
					Nil					,; //[12] CGROUP - ID DO GROUP ONDE O FIELD ESTA
					Nil					,; //[13] ACOMBOVALUES - ARRAY COM OS VALORES DO COMBO
					Nil					,; //[14] NMAXLENCOMBO - TAMANHO MAXIMO DA MAIOR OPçãO DO COMBO
					Nil					,; //[15] CINIBROW - INICIALIZADOR DO BROWSE
					.T.					,; //[16] LVIRTUAL - INDICA SE O CAMPO é VIRTUAL
					Nil					)  //[17] CPICTVAR - PICTURE VARIAVEL
			
Return oStru


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIAddCPg
Add as condicoes de pagamento no grid para escolha do usuario

@param   	oLstCdPg
@param   	lFirstPay , Valida se primeira chamada busca apenas a Cond. padrão
@author  	Vendas & CRM
@version 	P12
@since   	25/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIAddCPg(oLstCdPg , lFirstPay)

Local oMdl 			:= oModel						//Model
Local oMdlGrd		:= oMdl:GetModel("CDPGDETAILS")	//Seta o model do grid
Local aCondicoes 	:= {}							//Recebe as condicoes de pagamento
Local nI			:= 0							//Variavel de loop
Local aCdPgs		:= {}
Local cCondPagto	:= ""
Local cCodPlano 	:= ""

Default lFirstPay	:= .F.
Default oLstCdPg 	:= Nil

If lFirstPay .AND. ExistFunc("STDCondPad")	// Sendo a primeira chamada busca apenas a padrão(performance)
	cCondPagto	:= SuperGetMv('MV_CONDPAD',.F.,'')	//Condicao de pagamento padrao
ElseIf ExistFunc("LJIsDro") .And. LJIsDro() .And. ExistTemplate("FRTCONDPAG") //Verifica se usa o Template de Drogaria
	If ExistFunc("STBDroVars")
		cCodPlano := STBDroVars(.F., .F., Nil, Nil)[1]
	EndIf
	//Abre a Tela para Escolha da Condição de Pagamento, dentre as que estão associadas ao Plano de Fidelização (MHG x LHF X SE4)
	cCondPagto := ExecTemplate( "FRTCONDPAG", .F., .F.,{ cCodPlano, STDGPBasket("SL1","L1_CLIENTE"), STDGPBasket("SL1","L1_LOJA") } )
EndIf

If !Empty(cCondPagto)
	aCondicoes 	:= STDCondPad(cCondPagto)
Else
	//Caso seja a chamada vindo do clique na opção condicao deve listar todas
	aCondicoes 	:=STDCondPg()
EndIf

oMdlGrd:DeActivate()
oMdlGrd:Activate()

For nI := 1 To Len(aCondicoes)
	IIF(nI > 1, oMdlGrd:AddLine(.T.), Nil) 
	oMdlGrd:LoadValue( "L4_MARCAR"		, .F. )
	oMdlGrd:LoadValue( "L4_CODIGO"		, aCondicoes[nI][1] )
	oMdlGrd:LoadValue( "L4_CONDICAO"	, aCondicoes[nI][2] )
	oMdlGrd:LoadValue( "L4_FORMA"		, aCondicoes[nI][3] )
	oMdlGrd:LoadValue( "L4_TIPO"		, aCondicoes[nI][4] )
	oMdlGrd:LoadValue( "L4_DESCFIN"		, aCondicoes[nI][5] )
	oMdlGrd:LoadValue( "L4_ACRSFIN"		, aCondicoes[nI][6] )
	oMdlGrd:LoadValue( "L4_ACRES"		, aCondicoes[nI][7] )
	Aadd(aCdPgs,AllTrim(aCondicoes[nI][1]) + ' - ' + AllTrim(aCondicoes[nI][2]))
Next nI

If ValType(oLstCdPg) == 'O'
	oLstCdPg:SetArray(aCdPgs)
EndIf

oMdlGrd:GoLine(1)

Return .T.


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIChkCdPg
Tratamento para seleção da condicao de pagamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	25/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIChkCdPg(oLstCdPg, oMdlGrd)

Local cCdPgChk:= AllTrim(oMdlGrd:GetValue("L4_CODIGO"))	//Guarda a Adm que o usuario acabou de marcar
Local lCdPgChk:= oMdlGrd:GetValue("L4_MARCAR")			//Guarda se o usuario marcou o desmarcou a Adm
Local nI		:= 0											//Variavel de Loop

Default oLstCdPg := Nil

For nI := 1 To oMdlGrd:Length()

	oMdlGrd:GoLine(nI)
	
	If AllTrim(oMdlGrd:GetValue("L4_CODIGO")) + ' - ' + AllTrim(oMdlGrd:GetValue("L4_CONDICAO")) == AllTrim(oLstCdPg:GetSelText())
		oMdlGrd:LoadValue( "L4_MARCAR", .T. )	
	Else
		oMdlGrd:LoadValue( "L4_MARCAR", .F. )
	EndIf
	
Next nI 

oMdlGrd:GoLine(1)

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STICPConfPay
Confirma a condicao de pagamento selecionada pelo usuario

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	26/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STICPConfPay(oLstCdPg, oPnlAdconal)

Local oMdl 	:= oModel							//Recupera o model ativo
Local oMdlGrd	:= oMdl:GetModel("CDPGDETAILS")	//Seta o model do grid
Local oListBox 	:= STIGetLstB() 	//Objeto list box da tela principal do pagamento

oPnlAdconal:Hide()

STIChkCdPg(oLstCdPg, oMdlGrd)
STWPayCdPg(oMdlGrd)

oPnlAdconal:Hide()
oListBox:SetFocus()
STIEnblPaymentOptions()

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STISelectCP
Seleciona a condicao de pagamento no model

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	26/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STISelectCP()

Local oMdl 		:= oModel								//Recupera o model ativo
Local oMdlGrd		:= oMdl:GetModel("CDPGDETAILS")		//Seta o model do grid
Local cMvCondPad	:= SuperGetMv('MV_CONDPAD',.F.,'')	//Condicao de pagamento padrao
Local lRet			:= .F.									//Variavel de retorno
Local nx			:= 0									//Variavel de loop

If !Empty(cMvCondPad) //Para nao chamar o cheque
	For nX := 1 To oMdlGrd:Length()
	
		oMdlGrd:GoLine(nX)
		If AllTrim(oMdlGrd:GetValue("L4_CODIGO")) == AllTrim(cMvCondPad)
			oMdlGrd:LoadValue( "L4_MARCAR", .T. )
			lRet := .T.
		Else
			oMdlGrd:LoadValue( "L4_MARCAR", .F. )
		EndIf
		
	Next nX
EndIf

Return lRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIGetMdlCpPg
Retorna o model da condicao de pagamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	26/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIGetMdlCpPg()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} STIAdmCdPg()
Exibe tela para selecao da Administradora Financeira para Condicao de Pagamento cujo Forma é do tipo "FI" e "CO"

@param   	
@author  	Varejo
@version 	P11.8
@since   	14/04/2015
@return  	lRet
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIAdmCdPg(aCopyPaym, oListTpPaym, oModel)
Local lRet 			:= .T.
Local aAdmFin 		:= {}
Local aRetAdm 		:= {}
Local oMdlGrd		:= oModel:GetModel("APAYMENTS")       	// Model de pagamentos
Local nX 			:= 0
Local cAdmFin 		:= ""
Local lSTDGetDias 	:= ExistFunc("STDGetDias") 			 	//Indica se a função STDGetDias existe 
Local lLJRMBAC		:= SuperGetMV("MV_LJRMBAC",,.F.)  		//Habilita a integração com RM 

// Verifica se array oListTpPaym esta vazio, caso positivo já foi gerado financeiro da venda (Item retira posterior). 
if oListTpPaym = Nil
	lRet := .T.
//Verifica se é "Condicao de Pagamento" e a Forma é do tipo "FI" e "CO"
elseIf aCopyPaym[aScan(aCopyPaym,{ |x| x[2] == AllTrim(oListTpPaym:GetSelText()) })][1] == 'CP' .And. AllTrim(oMdlGrd:GetValue("L4_FORMA")) $ "FI|CO"
	
	//Carrega as Adm. Financeiras tipo "FI" e "CO"
	aAdmFin := STDAdmFinan(AllTrim(oMdlGrd:GetValue("L4_FORMA")),"2")
	
	If Len(aAdmFin) > 0 .And. ValType(aAdmFin[1]) == "A" .And. FindFunction("STICrdSlAdm")
		//Exibe Tela para Seleção da Adm. Financeira
		aRetAdm := STICrdSlAdm(aAdmFin,Nil,Nil,.F.)
		cAdmFin := PadR( PadR(aRetAdm[1][1], TamSx3("AE_COD")[1]) + " - " + aRetAdm[1][3], TamSX3("L4_ADMINIS")[1])
		
		//Atualiza o campo L4_ADMINIS
		For nX := 1 To oMdlGrd:Length()
			oMdlGrd:GoLine(nX)

			oMdlGrd:LoadValue("L4_ADMINIS", cAdmFin )

			If lLJRMBAC .AND. lSTDGetDias .AND. !Empty(cAdmFin) .AND. AllTrim(aRetAdm[1][2]) == "CD"  
				oMdlGrd:LoadValue("L4_DATA", dDataBase + STDGetDias(SubStr(cAdmFin,1,TamSx3('L4_ADMINIS')[1])))
			EndIf 

		Next nX
	EndIf
	
EndIf

Return lRet
