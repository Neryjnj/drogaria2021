#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBSALESOPERATIONS.CH"

Static cSiglaSat	:= LjSiglaSat()				//Retorna sigla do equipamento que esta sendo utilizado
Static lLjPDAcesso 	:= ExistFunc("LjPDAcesso")

//-------------------------------------------------------------------
/*/{Protheus.doc} STBLstOperCashier
Lista operacoes de caixa disponiveis

As operacoes de caixa incluem, mas nao se limitam a:
Tarefas relativas ao inicio e encerramento de venda,
atendimento de venda e operacoes nao ligadas diretamente à venda.

@author  Varejo
@version P11.8
@since   23/07/2012
@return  aRet - Lista de Funcoes

@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBLstOperCashier()
Local aRet 			:= {}							// Array de retorno das rotinas disponiveis
Local lMobile		:= .F.							// Smart Client Mobile

lMobile := STFGetCfg("lMobile", .F.)

If (STFProFile(12,,,,,.T.)[1]) //"Acesso para acessar a tecla de funcoes"
	
	//Em versoes Mobile os menus serão especificos
	If ValType(lMobile) == "L" .AND. lMobile
		aRet := STBMenuMobile()
	Else
		//Menu para versao Desktop(Padrao)
		aRet := STBMenuDesktop()	
	EndIf
		
EndIf
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBMenuDesktop
Retorna as funcoes de menu disponiveis na versao Desktop do PDV

@author  Varejo
@version P11.8
@since   06/03/20152
@return  Ret - Lista de Funcoes

@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBMenuDesktop()
Local aRet				:= {}						// Array de retorno das rotinas disponiveis
Local lUseECF			:= STFGetCfg("lUseECF")		// Usa ECF
Local lPafEcf			:= STFGetCfg("lPafEcf")		// PAF-ECF
Local lUsaTef			:= STFGetCfg("lUsaTef")		// Usa TEF
Local nOption			:= 0						// Numero do atalho  
Local lOnlyMenuFiscal 	:= STFGetCfg( "lOnlyMenuFiscal" ) // Mostrar apenas menu fiscal PAF-ECF
Local lSTMenu	 		:= ExistBlock("STMenu")		// Ponto de entrada para add novos itens no menu 
Local lSTMenEdt			:= ExistBlock("STMenEdt")	// Ponto de entrada para edicao do Menu
Local aPEMenu			:= {}						// Array que recebe os itens do ponto de entrada
Local nI				:= 0						// Variavel de loop
Local lEmitNfce			:= LjEmitNFCe()				// Sinaliza se utiliza NFC-e
Local lUseSat			:= STFGetCfg("lUseSAT",.F.) //utiliza SAT
Local cFuncReimp		:= "STIPanReimpSale()" 		// Funcção padrao para reimpressao do SAT
Local cFuncCanc			:= ""						// Funcao de cancelamento de venda
Local cMVLOJANF			:= AllTrim( GetMV("MV_LOJANF") )
Local lMVFISNOTA		:= GetMV("MV_FISNOTA") .and. !Empty(cMVLOJANF) .and. cMVLOJANF <> "UNI"
Local oTEF20			:= NIL

If (STFProFile(12,,,,,.T.)[1]) //"Acesso para acessar a tecla de funcoes"

	AAdd( aRet , { AllTrim(STR(++nOption)) , STR0034 , "STWCash()"   			, "", "01"} ) //"Encerramento de caixa"

	AAdd( aRet , { AllTrim(STR(++nOption)) , STR0036 , "STISupplyBleeding('1')"	, "", "02"} ) //"Sangria de caixa"

	AAdd( aRet , { AllTrim(STR(++nOption)) , STR0037 , "STISupplyBleeding('2')"	, "", "03"} ) //"Suprimento de caixa"

	AAdd( aRet , { AllTrim(STR(++nOption)) , STR0039 , "iIf(STBVldPD('CADCLI'), (IIF(ExistFunc('STIConsentTerm'),STIConsentTerm(),STIIncCustomer())), Nil )", "", "04"} ) //"Cadastro de Clientes"

	AAdd( aRet , { AllTrim(STR(++nOption)) , STR0045 , "STIValPre()"			, "", "05"} ) //"Vale Presente"
	
	AAdd( aRet , { AllTrim(STR(++nOption)) , STR0047 , "STWInfoCNPJ(.T.)"		, "", "06"} ) //"Informar CPF"
	
	If lSTMenu
		aPEMenu := ExecBlock("STMenu",.F.,.F.)
		If Len(aPEMenu) > 0
			For nI := 1 To Len(aPEMenu)
				AAdd( aRet , { AllTrim(STR(++nOption)) ,  aPEMenu[nI][1],	aPEMenu[nI][2], "", ""})
			Next nI
		EndIf
	EndIf
	
	AAdd( aRet , { AllTrim(STR(++nOption))	,	STR0038 , "STISalesmanSelection()"	, "", "07"} ) // "Alterar Vendedor"
   
	cFuncCanc	:= "(" +  IIF( !lEmitNfce, "STICancelSale()", "STIGerCancel()")	+ ",STIFocoReg()" + ")"
	//Funcao de cancelamento de venda
	
	If !lUseSat
		AAdd( aRet , { AllTrim(STR(++nOption)) 	,	STR0006	, cFuncCanc, "", "08"} ) //"Cancelar Venda"

		If lEmitNfce .and. !lMVFISNOTA
			AAdd( aRet , { AllTrim(STR(++nOption)) ,  STR0077  , cFuncReimp , "", "30"} )     // "Reimprimir NFC-e"
		else	
			If lEmitNfce
				AAdd( aRet , { AllTrim(STR(++nOption)) ,  STR0077 + "/NF-e"  ,   cFuncReimp , "", "30"} )     // "Reimprimir NFC-e"
			ElseIf lMVFISNOTA
				AAdd( aRet , { AllTrim(STR(++nOption)) ,  STR0078  ,   cFuncReimp , "", "30"} )     // "Reimprimir NF-e"
			EndIf
		EndIf
	Else
		AAdd( aRet , { AllTrim(STR(++nOption)) ,  StrTran(STR0075,"SAT",cSiglaSat)   ,  cFuncCanc,"", "08"} ) // "Cancelar SAT"
		
		If lMVFISNOTA
			AAdd( aRet , { AllTrim(STR(++nOption)) ,  StrTran(STR0076+ "/NF-e","SAT",cSiglaSat) ,   cFuncReimp  , "", "30"} )     // "Reimprimir SAT" + "NF-e"
		Else
			AAdd( aRet , { AllTrim(STR(++nOption)) ,  StrTran(STR0076,"SAT",cSiglaSat)   		,   cFuncReimp  , "", "30"} )     // "Reimprimir SAT"		
		Endif
	EndIf
	
	If !SuperGetMV( "MV_VLTROCA",,.F. )
		AAdd( aRet , { AllTrim(STR(++nOption)) 	,	STR0046	, "STIValeTroca()"	, "", "09"} ) //"Vale Troca" 
	EndIf

	//Se For homologacao do Paf nao mostra tela de recebimentos 
	If !(STBHomolPaf())
		AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0009 	, "iIf(STBVldPD('RECTIT'), STIPanelReceb('R'), Nil)" , "", "10"} ) // "Recebimento de Titulo"
		AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0043	, "iIf(STBVldPD('ESTTIT'), STIPanelReceb('E'), Nil)" , "", "11"} ) // "Estorno de Titulo"
		AAdd( aRet , { AllTrim(STR(++nOption)) 		, STR0060 	, "STICancelReceb()" , "", "12"} ) //"Cancelar Recebimento"
	EndIF	

	If STFGetCfg("lMultCoin") // Usa Multimoeda

		AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0010	, "Alert("+STR0044+")" , "", "13"} ) // "Totais da Venda - Diversas Moedas"

		If SuperGetMV("MV_TRCMOED")
			AAdd( aRet , { AllTrim(STR(++nOption)) 	,  STR0011	, "Alert("+STR0044+")" , "", "14"} ) // "Troca da Moeda da Venda"
		EndIf

	EndIf

	// Registro de Midia
	If AllTrim(Str(SuperGetMv("MV_LJRGMID",,0))) $ "1|2"
		AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0040 	 , "STIMultiMedia()" , "", "15"} ) //"Registro de Midia"																,""} )     // Midia
	EndIf
	
	If STFProFile(13,,,,,.T.)[1] .AND. !Empty(STFGetStation('GAVETA'))
		AAdd( aRet , { AllTrim(STR(++nOption)) 	,  STR0016	, "STBOpenDrawer()"		, "", "16"} ) //"Abrir Gaveta"
	EndIf

	// Funcoes para ECF
  	If lUseECF

  		AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0015	, "STBOpenECF()"		, "", "17"} ) //"Abrir ECF"

  		If !lPafEcf .AND. STFProFile(21,,,,,.T.)[1]
			AAdd( aRet , { AllTrim(STR(++nOption)) 	,  STR0017	, "STBReadingX()"		, "", "18"} ) //"Leitura X"
		EndIf

		
  		If !lPafEcf .AND. STFProFile(12,,,,,.T.)	[1]
			AAdd( aRet , { AllTrim(STR(++nOption)) 	,  STR0018	, "STWZReduction(.F.)"	, "", "19"} ) //"Fechar ECF (Reducao Z)"
		EndIf

  		AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0019 	, "STWMemryFisc()"		, "", "20"} ) //"Leitura da Memoria Fiscal"

  	EndIf

  	// Funcoes associadas ao TEF
  	If lUsaTef

		AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0021	, "STBFunAdm()"			, "", "21"} ) //"TEF - Gerenciais"
		
		//Se esta habilitado	Coreespondente Sitef
		If STFGetStat( "CBSIT" , .T. ) == "1"
 			AAdd( aRet , { AllTrim(STR(++nOption)) 	,  STR0004 	, "STWCorBank()"		, "", "22"} ) //"Correspondente bancario"
  		EndIf

		//Se esta habilitado	Recarga de celular Sitef
		If STFGetStat( "RCSIT" , .T. ) == "1"
 			AAdd( aRet , {  AllTrim(STR(++nOption)) ,  STR0022 	, "STWRecMob()"			, "", "23"} ) //"Recarga de celular"
  		EndIf

	EndIf  
	
	If lPafEcf
		If SM0->M0_ESTCOB = "DF"
			AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0041 , "STBCotepe3505(.T.)"			, "M", "24"} ) //"Ato COTEPE/ICMS 35/2005
		EndIf
		
		If !lOnlyMenuFiscal
			AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0042 , "STBMenFis(.T., .T., .T.)"		, "M", "25"} ) //"Menu Fiscal"
    	
    		If STFProFile(12,,,,,.T.)	[1]
    			AAdd( aRet , { AllTrim(STR(++nOption)) 	,  STR0018 , "STWZReduction(.F.)"			, "",  "26" } ) 
        	EndIf
        Else 
 			AAdd( aRet , { AllTrim(STR(++nOption)) 		,  STR0042 , "STBMenFis(.T., .T., .F.)"		, "M", "27"} ) //"Menu Fiscal"          
 		EndIf
	EndIf
	
	// RFID
	If SuperGetMv("MV_RFID",, .F.) .AND. ExistFunc("LJRFPesqProd") .AND. SLG->(ColumnPos("LG_RFID") > 0)  .AND. STFGetStation("RFID") == "1"
		AAdd( aRet , { AllTrim(STR(++nOption)) ,  STR0048 + " - " + STR0049 	 , "MsgRun('" + STR0050 + "','',{|| LJRFPesqProd() })" , "", "28"})	  // "RFID" - "Leitura de Itens" //"Aguarde!, Realizando Leitura de Itens RFID. "
	EndIf
	  
	//Lista de Presentes
	If SuperGetMv("MV_LJLSPRE",, .F.)
		AAdd( aRet , { AllTrim(STR(++nOption)) ,  STR0051 , "STIGiftList()" , "", "29"} ) // "Lista de Presentes"
	EndIf

	If ExistFunc("LjIsDro") .And. LjIsDro() .And. ExistFunc("STBPbmMenu") .And. lUsaTef
		oTef20 := STBGetTEF()
		If oTef20:IsAtivo() .And. oTef20:oConfig:ISPBM()
			AADD(aRet, {cValToChar(++nOption), "PBM", "STBPbmMenu()","","30"})
		Else
			ConOut("Para uso de PBM é necessário ativar o TEF SITEF e ativar o uso de PBM no Cadastro de Estação(LOJA121)")
			LjGrvLog(NIL,"Para uso de PBM é necessário ativar o TEF SITEF e ativar o uso de PBM no Cadastro de Estação(LOJA121)")
		EndIf
	EndIf

	If ExistFunc("LjIsDro") .And. LjIsDro() .And. ExistTemplate("FRTFuncoes")
		aPEMenu := ExecTemplate("FRTFUNCOES",.F.,.F.,{aRet,nOption,"31"})
		If Len(aPEMenu) > 0
			aRet := aPEMenu
		EndIf
	EndIf
	
	If lSTMenEdt
		aPEMenu := ExecBlock("STMenEdt",.F.,.F.,{aRet})
		If Len(aPEMenu) > 0
			aRet := aPEMenu
		EndIf
	EndIf
	
	//Função para validação dos menus
	STBVldMenus(@aRet)
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBMenuMobile
Retorna as funcoes de menu disponiveis na versao Mobile do PDV

@author  Varejo
@version P11.8
@since   06/03/20152
@return  Ret - Lista de Funcoes

@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBMenuMobile()

Local aRet 		:= {}							// Array de retorno das rotinas disponiveis
Local nOption	:= 0							// Numero do atalho  
Local lUsaTef	:= STFGetCfg("lUsaTef")			// Usa TEF
Local lNFCETSS	:= STFGetCfg("lNFCETSS", .T.)	// NFCE COM TSS


AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0052	, 	;  //"Abertura de Caixa"
		"IIF(STBPdvFree(), STIOpenCash(), Nil)", ""})			// "Abertura de caixa"

AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0034	, 	;
		"IIF(STBPdvFree(), STWPOSCloseCash(), Nil)", ""})	// "Encerramento de caixa"

//Versao Mobile Demonstrativa 
//Somente opcoes de abertura e Fechamento de caixa
If STFGetCfg("cTypeOperation","") == "DEMONSTRACAO" 
	Return aRet
EndIf
AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0036 	, 	;
		"IIF(STBCaixaVld() .AND. STBPdvFree(), STISupplyBleeding('1',.T.), Nil)", ""}) 	// "Sangria de caixa" | Somente Dinheiro

AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0037	, 	;
		"IIF(STBCaixaVld() .AND. STBPdvFree(), STISupplyBleeding('2') , Nil)", ""})	// "Suprimento de caixa"

AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0047	,	;
		"IIF(STBCaixaVld() , (STI7InfCPF(.F.),STWInfoCNPJ()) , Nil)", ""})		//"Informar CPF"

AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0038 	,	;
		"IIF(STBCaixaVld() , STISalesmanSelection(), Nil)", ""})		//"Alterar Vendedor"


//Se estiver em venda 		-->> Cancela Cupom atual
//Se nao estiver em venda 	-->> Abre opcao para digitar o numero da venda
AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0006 	,	;
		"IIF( STBCaixaVld() , IIF( STBCaixaVld() .AND. STFSaleTotal() > 0 , STICancelSale() , STIPanSaleCancel() )  , Nil )", ""})	//"Cancelar Cupom"	

// Funcoes associadas ao TEF
If lUsaTef
	AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0021	,   ;
		"IIF(STBCaixaVld() .AND. STBPdvFree(), STBFunAdm(), Nil)", ""}) //"TEF - Gerenciais"
EndIf		

//Subida de Vendas
AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0053	, "FWMsgRun( ,{|| STWUpData(  ,  , STFGetStat('CODIGO')) } ,'"+ STR0057 +"'  , '"+STR0058+"' ) " , ""} )     // "Envio de Vendas"#'Aguarde'#Executando envio de vendas


//Carga de Dados
AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0054, "FWMsgRun( ,{|| STWDownData(  ,  , STFGetStat('CODIGO'),  5, .F. ) } , '" + STR0057 + "' , '"+ STR0059+ "' ) " , ""} )     // "Carga de Dados"#'Aguarde'#Executando carga de dados

lNFCETSS := Valtype(lNFCETSS) = "U" .OR. lNFCETSS

If !lNFCETSS
	//configurações NFCE Lib
	AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0055	, "LjDCfgNFCE()" , ""} )     // "Configurações NFC-e"    

EndIf

//Log de mensagens
AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0056	, "STFLatestMsg(.F.,.F.,.F.)" , ""} )     // "Log de Mensagens"

//Dados Cadastrais
AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0063	, "STFCadEmp()" , ""} )     // "Dados Cadastrais"  

//Configurações Gerais
AAdd( 	aRet , { AllTrim(STR(++nOption)) ,  STR0064	, "STFMobWizard()" , "" , "configuracoes.svg"} )     // "Configurações"  
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetNFCE
Valida uso da Nfc-e

@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet - Nfc-e

@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBGetNFCE()

Local lEmitNfce		:= LjEmitNFCe() // Sinaliza se utiliza NFC-e

Return lEmitNfce


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCaixaVld
Valida se o caixa está aberto e exibe mensagens caso nao esteja

@author  Varejo
@version P11.8
@since   16/03/2015
@return  lRet - Retorna se o caixa está aberto

@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBCaixaVld(cType,cFunc) 

Local lRet := .F. //Retorno

Default cType := "POPUP"	//Tipo da Mensagem, quando Mobile "POPUP", para apresentar no rodape Desktop "ALERT"
Default cFunc := ""


/*Conforme legado FrontLoja, para realizar operacoes no Front deve estar 
com o caixa aberto(ajusta todas as rotinas apos a primeira(encerramento), inclusive PEs)*/
lRet := STBOpenCash()

If !lRet
	STFMessage(ProcName(),cType,STR0062) //"Realize a Abertura do Caixa para executar esta opção."
	STFShowMessage(ProcName())
EndIf

// Se for recebimento de titulos nao permite alterar no menu
If STIGetRecTit() .AND.  !("STICancelReceb" $ cFunc)
	lRet := .F.
	STFMessage(ProcName(),cType,STR0065) //"Recebimento em andamento, finalize ou cancele o recebimento pelo Menu."
	STFShowMessage(ProcName())
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBPdvFree
Valida se o PDV esta livre. ou seja nao esta em processo de venda.
Se não estiver livre exibe mensagem informativa.

@author  Varejo
@version P11.8
@since   16/03/2015
@return  lRet - Retorna se o pdv esta livre

@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBPdvFree() 

Local lRet 			:= .F. 									//Retorno

// Se estiver zerado nao está em operacao de venda, e esta livre.
lRet := STFSaleTotal() == 0

If !lRet
	STFMessage(ProcName(),"POPUP",STR0061) //"O PDV já está em operação. Finalize a operação para executar está opção."
	STFShowMessage(ProcName())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldMenus
Função generica para validar os menus

@param	 aMenu, array, item do menu 
@author  julio.nery
@version P12
@since   03/02/2017
@return  lRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBVldMenus(aMenu)
Local nI	:= 0
Local cFunc	:= ""

For nI:= 1 To Len(aMenu)
	cFunc := aMenu[nI][3]

	//Conforme legado, não pode inserir a validação do caixa no primeiro item e
	//para o PAF não pode impedir o acesso ao menu
	If nI == 1 .Or. ("STBMENFIS" $ Upper(cFunc))
		aMenu[nI][3] :=	"IIF(STBVldTef('POPUP','"+AllTrim(aMenu[nI][2])+"')," + cFunc + ",Nil)"
	Else
		aMenu[nI][3] :=	"IIF(STBCaixaVld('ALERT','"+StrTran(cFunc,"'","")+"') .And. "+;
						"STBVldTef('POPUP','"+AllTrim(aMenu[nI][2])+"')," + cFunc + ",Nil) "
	EndIf
Next aMenu

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldTef
Valida se fez a venda com TEF assim, permitindo o acesso a função 
do menu

@param	 cType, string, tipo da mensagem (POPUP,ALERT)
@param	 cNomeMenu, string, nome do menu da tela
@author  julio.nery
@version P12
@since   03/02/2017
@return  lRet - Retorna se pode fazer a venda
/*/
//-------------------------------------------------------------------
Function STBVldTef(cType,cNomeMenu) 
Local lRet			:= .T.

Default cType := "POPUP"	//Tipo da Mensagem
Default cNomeMenu := ""

//Mantem habilitado no menu somente a opção Cancelar, 
//conforme documentação do param MV_TEFPEND ou 
//caso não esteja com o fonte atualizado
If (Upper("Cancela") $ Upper(cNomeMenu))
	lRet := .T.
Else
	lRet := STIBlqMnTef()
	If !lRet
		STIMBlPTef(cType)
	EndIf
EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} STBVldPD
Verifica se o usuário pode acessar um determinado menu caso a rotina tenha campos Pessoais/Sensíveis 
referente a Implementação de Proteção de Dados (LGPD).

@type  Function
@param cNomeMenu, Caracter, Nome de referência do Menu.
@author Alberto Deviciente
@since 30/01/2020
@version P12

@return Lógico, Retorna se o usuário tem acesso ou não a um determinado menu.
/*/
//---------------------------------------------------------------------------------------------------
Function STBVldPD(cNomeMenu) 
Local lRet		:= .T.

Do Case

	Case cNomeMenu == "CADCLI" //"Cadastro de Clientes"

		If lLjPDAcesso
			lRet := LjPDAcesso({"A1_NOME","A1_CGC","A1_PESSOA","A1_TIPO","A1_DTNASC","A1_CEP","E1_END","A1_BAIRRO","A1_EST","A1_MUN","A1_TEL","A1_EMAIL"}) //Verifica se o usuário pode acessar a rotina devido a regra de proteção de dados.
		EndIf

	Case cNomeMenu == "RECTIT" //"Recebimento de Titulo"

		If lLjPDAcesso
			lRet := LjPDAcesso({"L1_NOMCLI","L1_CGCCLI"}) //Verifica se o usuário pode acessar a rotina devido a regra de proteção de dados.
		EndIf

	Case cNomeMenu == "ESTTIT" //"Estorno de Titulo"
		
		If lLjPDAcesso
			lRet := LjPDAcesso({"L1_NOMCLI","L1_CGCCLI"}) //Verifica se o usuário pode acessar a rotina devido a regra de proteção de dados.
		EndIf
	
EndCase

Return lRet