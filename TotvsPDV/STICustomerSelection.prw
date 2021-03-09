#Include 'Protheus.ch'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STICUSTOMERSELECTION.CH"

Static aRecno 			:= {}
Static oGetSearch		:= Nil	//TGet Cancelamento de Item
Static aCartaoMA6		:= {}	//Para tabela de Cartões - MA6	(Integração TOTVSPDV x SIGACRD)
Static lPosCrd			:= Nil	//Ativa Integração com SIGACRD
Static aDataCustomers 	:= {}	//Dados solicitados dos clientes utilizados na gravação.

//-------------------------------------------------------------------
/*{Protheus.doc} STICustomerSelection
Funcao responsavel por chamar a troca do painel atual pelo painel de selecao de clientes.

@author Vendas CRM
@since 26/04/2013
@version 11.80

*/
//-------------------------------------------------------------------

Function STICustomerSelection()
Local oTotal  		:= STFGetTot() 					// Recebe o Objeto totalizador
Local nTotalVend	:= oTotal:GetValue("L1_VLRTOT") // Valor total da venda
Local lContinua 	:= .T.

If nTotalVend > 0
	lContinua := .F.
	STFMessage(ProcName(),"STOP",STR0005)       // "Não será possivel alterar o cliente pois a venda já foi iniciada."
	STFShowMessage(ProcName())
EndIf

//Tratativa para LGPD
If lContinua .And. ExistFunc("LjPDAcesso")
	lContinua := LjPDAcesso({"L1_NOMCLI"}) //Verifica se o usuário pode acessar uma determinada rotina devido a regra de proteção de dados.
EndIf

If lContinua
	STIChangeCssBtn('oBtnClient')
	STIExchangePanel( { || STIPanCustomerSelection() } )
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanCustomerSelection
Funcao responsavel pela criacao do Painel de selecao de clientes.

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------

Function STIPanCustomerSelection()
Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de clientes sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta
Local oLblCab			:= Nil							// Objeto do label "Seleção de Cliente"
Local oLblHelpGet		:= Nil 							// Objeto do label Help

/*/
	Get Combo de Busca
/*/
Local oLblList			:= Nil
Local oGetList			:= Nil							// TComboBox Escolha do campo a ser utilizado na busca
Local cGetList			:= ""							// Variável do Get
/*/
	Get de Busca
/*/
Local oLblSearch		:= Nil							// Label do ComboBox
Local cGetCustomer		:= Space(40)					// Variável do Get
Local cGetCrdCart		:= Space(16)					// Variável do Get para Cartão para Sigacrd
Local cGetMatric		:= Space(15)					// Variável do Get para campo de Matricula (Template Drogaria)
Local oLblCrdCart		:= Nil							// Label do Cartão para Sigacrd
Local oGetCrdCart		:= Nil							// Objeto do Cartão para Sigacrd
Local noLblListVert 	:= 0							// Posição Vertical em oLblList
Local nOGetListVert 	:= 0							// Posição Vertical em oGetList
Local noGetListAlt		:= 0							// Altura em oGetList
Local oLblMatric		:= Nil							// Label do campo de Matricula (Template Drogaria)
Local oGetMatric		:= Nil							// Objeto Get do campo de Matricula (Template Drogaria)

/*/
	Botão "Selecionar Cliente"
/*/
Local oButton			:= Nil							// Botao "Selecionar Cliente"
Local lBusca			:= .F.							// Variavel de Habilitacao de Busca. - .F. não efetuou pesquisa de busca. - .T. efetuou pesquisa de busca
Local oListFont 		:= TFont():New("Courier New") 	// Fonte utilizada no listbox
Local bConfirm			:= { || IIF(lBusca, STIFilCustomerData(oGetList),Nil)}
Local oButPesq			:= Nil 							//Botao pesquisar 
Local oButCan			:= Nil 							//Botao cancelar 
Local lMobile 			:= STFGetCfg("lMobile", .F.)	//Smart Client Mobile
Local bFind				:= { || Iif(!Empty(AllTrim(cGetCustomer)) .AND. STIAddFilter(cGetCustomer, oGetList, @lBusca, "", 1, ""),(cGetCrdCart := Space(Len(cGetCrdCart)), cGetMatric := Space(Len(cGetMatric)), oGetList:SetFocus()),Nil)}

/*/
Variaveis do PE
/*/
Local aFields			:= STDWhatFields()				//Campos que serão importados
Local lSTIALTC			:= ExistBlock("STIALTC") 		//Verifica se existe o ponto de entrada STIALTC na seleção do cliente
Local aCustomers		:= {}							//Dados dos clientes buscado no PE

If lSTIALTC
	oGetList := TListBox():Create(oMainPanel, nOGetListVert, POSHOR_1, {|u| If(PCount()>0,cGetList:=u,cGetList)}, , LARG_LIST_CONSULT , noGetListAlt,,,,,.T.,,bConfirm,oListFont)
	oGetList:SetCSS( POSCSS (GetClassName(oGetList), CSS_LISTBOX )) 

	LjGrvLog( NIL, "Antes da execução do PE STIALTC")
	aRet := ExecBlock("STIALTC",.F.,.F.,{aFields})
	
	aCustomers := aRet[1]
	aDataCustomers := aRet[2]
	lBusca := .T.

	oGetList:SetArray(aCustomers)
	oGetList:Select(1)
	STIFilCustomerData(oGetList)

	LjGrvLog( NIL, "Depois da execução do PE STIALTC")
Else
	/*/
		Objetos
	/*/
	oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oMainPanel,,,,,,.T.,,,,)       // Seleção de Cliente
	oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

	oLblSearch := TSay():New(POSVERT_LABEL1,POSHOR_1, {|| STR0006 }, oMainPanel,,,,,,.T.)  // "Pesquisar Cliente:  Código / Nome / Loja / CPF/CNPJ"

	oGetSearch:= TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,(lBusca := .F., cGetCustomer:=u),cGetCustomer)},;
							oMainPanel,120 ,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetCustomer")

	oLblHelpGet:= TSay():New(POSVERT_GET1 + 2.5 ,POSHOR_1 + 123 ,{||STR0025},oMainPanel,,,,,,.T.,,,,)       //"Para busca de palavras contidas utilize *"
	oLblHelpGet:SetCSS( POSCSS (GetClassName(oLblCab), CSS_LABEL_NORMAL )) 
							
	//Botao pesquisar para versao mobile
	If ValType(lMobile) == "L" .AND. lMobile
		oButPesq	:= TButton():New(	POSVERT_GET1,POSHOR_1+130,"",oMainPanel,, ;
										20,20,,,,.T.,,,,{||.T.})
		oButPesq:SetCSS( POSCSS (GetClassName(oButPesq), CSS_BTN_LUPA )) 
	Else

		oGetSearch:bLostFocus := bFind
		
	EndIf							
							
	oGetSearch:SetCSS( POSCSS (GetClassName(oGetSearch), CSS_GET_NORMAL )) 
	oGetSearch:bLostFocus := bFind 							

	oLblSearch:SetCSS( POSCSS (GetClassName(oLblSearch), CSS_LABEL_FOCAL )) 

	If lPosCrd == nil .AND. ExistFunc("STBSetCrdIdent") .AND. ExistFunc("STBGetCrd")
		lPosCrd	:= CrdxInt(.F.,.F.) // Integração com SIGACRD
	EndIf

	If lPosCrd	//Se integração com CRD habilitado

		//Inicialização de variáveis CRD
		aCartaoMA6 := {}
		STBSetCrdIdent("","","","","")

		//Informe o Número do Cartão / Informe a Validade
		oLblCrdCart := TSay():New(POSVERT_LABEL2,POSHOR_1, {||STR0024}, oMainPanel,,,,,,.T.)       // "Ou Informe o Número do Cartão"
		oLblCrdCart:SetCSS( POSCSS (GetClassName(oLblCrdCart), CSS_LABEL_FOCAL ))

		oGetCrdCart := TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,(lBusca := .F., cGetCrdCart:=u),cGetCrdCart)},;
								oMainPanel,120 ,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetCrdCart")
		oGetCrdCart:SetCSS( POSCSS (GetClassName(oGetCrdCart), CSS_GET_NORMAL )) 
		oGetCrdCart:bLostFocus := { || IIF( !lBusca .AND. !Empty(cGetCrdCart) .AND. STIAddFilter("",oGetList, @lBusca, cGetCrdCart, 2, ""),(cGetCustomer := Space(Len(cGetCustomer)), cGetMatric := Space(Len(cGetMatric)), oGetList:SetFocus()),Nil)}
		
		//Informe a Matricula (Integração com CRD habilitado + Template Drogaria)
		If ExistFunc("LJIsDro") .And. LJIsDro() //Verifica se usa o Template de Drogaria
			oLblMatric := TSay():New(POSVERT_LABEL2,POSHOR_2, {||"Ou Informe a Matrícula"}, oMainPanel,,,,,,.T.)  // "Ou Informe a matrícula"
			oLblMatric:SetCSS( POSCSS (GetClassName(oLblMatric), CSS_LABEL_FOCAL ))

			oGetMatric := TGet():New(POSVERT_GET2,POSHOR_2,{|u| If(PCount()>0,(lBusca := .F., cGetMatric:=u),cGetMatric)},;
									oMainPanel,120 ,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cGetMatric")
			oGetMatric:SetCSS( POSCSS (GetClassName(oGetMatric), CSS_GET_NORMAL )) 
			oGetMatric:bLostFocus := { || IIF( !lBusca .AND. !Empty(cGetMatric) .AND. STIAddFilter("",oGetList, @lBusca, "", 3, cGetMatric),(cGetCustomer := Space(Len(cGetCustomer)), cGetCrdCart := Space(Len(cGetCrdCart)), oGetList:SetFocus()),Nil)}
		EndIf
		
		noLblListVert := POSVERT_LABEL3
		nOGetListVert := POSVERT_GET3
		noGetListAlt  := oPanelMVC:nHeight/(4.4865+2)
					
	Else

		noLblListVert := POSVERT_LABEL2
		nOGetListVert := POSVERT_GET2
		noGetListAlt  := ALT_LIST_CONSULT
		
	EndIf

	oLblList := TSay():New(noLblListVert,POSHOR_1, {||IIF(lPosCrd,STR0029,STR0007)}, oMainPanel,,,,,,.T.)       // Nome / Código / Loja / CPF/CNPJ / Cartão
	oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_LABEL_FOCAL )) 

	oGetList := TListBox():Create(oMainPanel, nOGetListVert, POSHOR_1, {|u| If(PCount()>0,cGetList:=u,cGetList)}, , LARG_LIST_CONSULT , noGetListAlt,,,,,.T.,,bConfirm,oListFont)
	oGetList:SetCSS( POSCSS (GetClassName(oGetList), CSS_LISTBOX )) 

	oButton	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0004,oMainPanel,bConfirm, ;   // Selecionar Cliente
								LARGBTN,ALTURABTN,,,,.T.)

	oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL ))  

	oButCan	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0022,oMainPanel,{|| STIRegItemInterface() }, ;  //"Cancelar"
								LARGBTN,ALTURABTN,,,,.T.,,,,{||.T.})
	oButCan:SetCSS( POSCSS (GetClassName(oButCan), CSS_BTN_NORMAL )) 							
EndIf

Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STIAddFilter
Responsavel por capturar os dados dos clienes conforme enviado pelo usuario. 

@author Lucas Novais (lnovias)
@since 11/11/2019
@version 12.1.25
@param 	cGetCustomer, Caracter, String digitada pelo usuario utilizada para pesquisar o cliente.
@param 	oGetList, objeto, Campo que será utilizado para pesquisa.
@param 	lBusca, Logico,Ativar busca
@param 	cGetCartao, Caracter,Digitar cartão para pesquisa integração SIGACRD
@param	nTipo, Numerico,1-Só tela CNPJ, 2-Tela integração SIGACRD com busca por cartao, 3-Tela com campo de matricula também (Template Drogaria)
@param 	cGetMatric, Caracter, Número de matrícula para pesquisa do cliente (Template Drogaria)

@return	Logico, indica se o processo foi concluido com sucesso.
*/
//-------------------------------------------------------------------

Static Function STIAddFilter(cGetCustomer, oGetList, lBusca, cGetCartao, nTipo, cGetMatric)
Local lBuscaLike  		:= .F.							// -- Indica se devera realizar a busca like
Local lRet				:= .F.							// -- Retorno da função
Local aCustomers		:= {}							// -- Dados dos clientes buscado
Local nLimitRegs 		:= SuperGetMV("MV_LJQTDPL",,20) // -- Limite de clientes na busca 		
Local aFields			:= STDWhatFields()				// -- Campos que serão importados
Local lIntCRD			:= .F.							// -- Indica se é integração CRD
Local nMV_LJPEATU 		:= 0							// -- Define aonde será buscado o cliente (0=Pesquisa Local, 1=Pesquisa preferencialmente Local se falar pesquisa na retaguarda, 2=Pesquisa somente na retaguarda)
Local nSec1, nSec2		:= 0							// -- Utilizado para 
Local aParam			:= {}							// -- Parametros utilizados para busca na retaguarda
Local uResult			:= Nil							// -- Resultado da busca na retaguarda
Local aRet				:= {}							// -- Retorno da função

Default cGetCustomer	:= ""							// -- Busca do cliente
Default cGetCartao		:= ""							// -- Cartão private label CRM
Default nTipo			:= 1							// -- 1-Só tela CNPJ, 2-Tela integração SIGACRD, 3-Tela com campo de matricula também (Template Drogaria)
Default cGetMatric		:= ""							// -- Matricula do cliente (Convênio) - Template Drogaria

nSec1 := Seconds()
aRecno := {}

cGetCustomer 	:= AllTrim(cGetCustomer)
cGetCartao 		:= AllTrim(cGetCartao)
cGetMatric		:= AllTrim(cGetMatric)

// -- Caso esteja com a integração CRD ativa (nTipo == 2), ou template Drogaria (nTipo == 3), a consulta deverá ser sempre na retaguarda. (nMV_LJPEATU = 2)
If nTipo == 2 .Or. nTipo == 3 
	lIntCRD		:= .T.
	nMV_LJPEATU := 2 
Else 
	nMV_LJPEATU := SuperGetMV("MV_LJPEATU",,0)
EndIf 

// -- É necessario que seja digitado pelomenos 3 letras para a busca, ou caso inicie com numero ignora o minimo para casos aonde é realizado a busca por codigo do cliente ex.: "1" ou "12" Etc..
If (Len(cGetCustomer) >= 3 .Or. Len(cGetCartao) > 3 .Or. Len(cGetMatric) > 3 ) .OR. ( Len(cGetCustomer) < 3 .AND. SubStr(cGetCustomer,1,1) $ "0123456789" )
	
	lRet := .T.
	// -- Identifica se é busca Like ou convencional. 
	If "*" $ cGetCustomer 
		lBuscaLike := .T.
		cGetCustomer := Replace(cGetCustomer,"*","")
	EndIf

	If nMV_LJPEATU == 0		// -- Pesquisa Somente local
		LjGrvLog( ProcName(),"Parametro MV_LJPEATU = 0, as busca serão realizadas apenas no PDV")
		
		STFMessage(ProcName(), "RUN", STR0020  ,{ || aRet := STDSearchCostumer(cGetCustomer,nLimitRegs,lBuscaLike,Nil,aFields) })
		STFShowMessage(ProcName())
		
		aCustomers 		:= aRet[1]
		aDataCustomers	:= aRet[2]

		If Len(aCustomers) == 0
			LjGrvLog( ProcName(),"Nenhum cliente encontrado.")
			STFMessage(ProcName(),"STOP",STR0009) //Nenhum cliente encontrado.
			STFShowMessage(ProcName())
			oGetList:SetFocus()
		EndIf

	ElseIf nMV_LJPEATU == 2 // -- Pesquisa Somente na retaguarda
		LjGrvLog( ProcName(),"Parametro MV_LJPEATU = 2, as busca serão realizadas apenas na Retaguarda")
		
		aParam := {cGetCustomer,nLimitRegs,.T.,Nil,aFields,lIntCRD,cGetCartao,cGetMatric}

		STFMessage(ProcName(), "RUN", STR0020  ,{ || lRet := STBRemoteExecute("STDSearchCostumer", aParam,,, @uResult) })
		STFShowMessage(ProcName())
		
		If lRet
			aCustomers 		:= uResult[1]
			aDataCustomers	:= uResult[2]
			aCartaoMA6		:= uResult[3]
		Else
			LjGrvLog( ProcName(),"Sem comunicação com o servidor.")
			STFMessage(ProcName(),"STOP",STR0028) //"Sem comunicação com o servidor."
			STFShowMessage(ProcName())
		EndIf 

		If Len(aCustomers) == 0
			LjGrvLog( ProcName(),"Nenhum cliente encontrado.")
			STFMessage(ProcName(),"STOP",STR0009) //Nenhum cliente encontrado.
			STFShowMessage(ProcName())
			oGetList:SetFocus()
		EndIf
	Else

		LjGrvLog( ProcName(),"Parametro MV_LJPEATU = 1, as busca serão realizadas no PDV e caso nenhum cliente seja encontrado será realizada uma nova busca na retaguarda")
		
		STFMessage(ProcName(), "RUN", STR0020  ,{ || aRet := STDSearchCostumer(cGetCustomer,nLimitRegs,lBuscaLike,Nil,aFields) })
		STFShowMessage(ProcName())
		
		aCustomers 		:= aRet[1]
		aDataCustomers	:= aRet[2]

		If Len(aCustomers) == 0 
			
			// -- Se não encontrou nenhum cliente realiza a busca na retaguarda.
			STFMessage(ProcName(),"YESNO",STR0018) //Cliente não encontrado na base local. Deseja realizar a busca no servidor?
			
			LjGrvLog( ProcName(),"Nenhum cliente encontrado nas busca no PDV.")
			
			If STFShowMessage(ProcName())
				LjGrvLog( ProcName(),"Usuario optou por realizar nova busca na retaguarda")
				
				aParam := {cGetCustomer,nLimitRegs,.T.,Nil,aFields,lIntCRD,cGetCartao,cGetMatric}
				
				STFMessage(ProcName(), "RUN", STR0020  ,{ || lRet := STBRemoteExecute("STDSearchCostumer", aParam,,, @uResult) })
				STFShowMessage(ProcName())
				
				If lRet
					aCustomers 		:= uResult[1]
					aDataCustomers	:= uResult[2]
					aCartaoMA6		:= uResult[3]
				Else
					LjGrvLog( ProcName(),"Sem comunicação com o servidor.")
					STFMessage(ProcName(),"STOP",STR0028) //"Sem comunicação com o servidor."
					STFShowMessage(ProcName())
				EndIf 

				If Len(aCustomers) == 0
					LjGrvLog( ProcName(),"Nenhum cliente encontrado.")
					STFMessage(ProcName(),"STOP",STR0009) //Nenhum cliente encontrado.
					STFShowMessage(ProcName())
					oGetList:SetFocus()
				EndIf
			Else
				oGetList:SetFocus()
				LjGrvLog( ProcName(),"Nenhum cliente encontrado nas busca no PDV e o usuario optou por não realizar buscas na retaguarda.")
			EndIf 
		EndIf 

	EndIf 

	If Len(aCustomers) = 0
		lRet := .F.
		oGetList:Reset()
	Else 
		lBusca := .T.
		oGetList:SetArray(aCustomers)
	EndIf 

Else
	LjGrvLog( ProcName(),"É necessário digitar pelo menos 3 caracteres.")
	STFMessage(ProcName(),"STOP",STR0008) //É necessário digitar pelo menos 3 caracteres.
	STFShowMessage(ProcName())
	oGetList:SetFocus()
EndIf 

nSec2 := Seconds()-nSec1

Conout("-------------------------------------------------------------------")
ConOut(Str(nSec2))
Conout("Tempo de espera na pesquisa de clientes: " + AllTrim(Str(nSec2)))
LjGrvLog( "Cliente",  "Tempo de espera na pesquisa de clientes: " + AllTrim(Str(nSec2)) )	
Conout("-------------------------------------------------------------------")

Return lRet

//-------------------------------------------------------------------
/* {Protheus.doc} STIFilCustomerData
Funcao responsavel por setar os dados do cliente selecionado na tabela SL1, além de carregar um model com as informações do cliente

@author leandro.dourado
@since 26/04/2013
@version 11.80
*/
//-------------------------------------------------------------------
Function STIFilCustomerData(oGetList)

Local oModelCli 	:= Nil		// Model do cliente selecionado
Local nPos			:= oGetList:GetPos()
Local nRecno		:= IIF(Len(aRecno) > 0, aRecno[nPos], 0)
Local cCNPJ 		:= ""		//Cnpj do cliente
Local cNome 		:= ""		//Nome do cliente
Local cEnd  		:= ""		//Endereco do cliente
Local nCallCPF		:= SuperGetMV("MV_LJDCCLI",,0)	//O momento onde será mostrado o CPF na tela
Local lUtilizaCPF	:= .F.		//Faz a pergunta se utiliza CPF caso não for NFC-e
Local cCartaoMA6	:= ""		//Cartão MA6
Local nCustomer		:= 0		//Variavel utilizada para For
Local aCampos		:= {}		//Campos que serão gravados
Local aDados		:= {}		//Dados dos campos que serão gravados.
Local lRet 			:= .T. 		//Retorno da função do PE STValidCli
Local cMatricula	:= ""		//Matricula do cliente no caso de Convênio (Template Drogaria)
Local aFRT010CL 	:= {}		//Retorno da Template Function FRT010CL

//Cadastra o cliete selecionado caso não exista localmente
If  nPos > 0 .AND. nPos <= Len(aDataCustomers) 
 	nRecno := STDVerfCadCli(aDataCustomers[nPos][2][2] + aDataCustomers[nPos][3][2])[2]
	If nRecno == 0
		aADD(aDados,{})	
		For  nCustomer := 1 To len(aDataCustomers[nPos]) 
			aADD(aCampos,aDataCustomers[nPos][nCustomer][1])
			aADD(aDados[Len(aDados)] ,aDataCustomers[nPos][nCustomer][2])
		Next

		STIConfCus(	aDataCustomers[nPos][2][2]	,aDataCustomers[nPos][3][2]	,aDataCustomers[nPos][1][2]	,aDataCustomers[nPos][5][2]	,;
					aDataCustomers[nPos][6][2]	,aDataCustomers[nPos][4][2]	,aDataCustomers[nPos][7][2]	,aDataCustomers[nPos][8][2]	,;
					aDataCustomers[nPos][9][2]	,aDataCustomers[nPos][10][2],.T.			  			,.F.						,;
					aDataCustomers[nPos][11][2]	,aDataCustomers[nPos][12][2],aDataCustomers[nPos][13][2],aCampos					,;
					aDados						,.F. 						, "TX" ) //Cadastra Cliente 

		//Apos o cadastro Pega o numero do recno. 
		nRecno := STDVerfCadCli(aDataCustomers[nPos][2][2] + aDataCustomers[nPos][3][2])[2]
	EndIf

EndIF 

If nPos > 0 .AND. !Empty(nRecno)
 
	SA1->(DbGoTo(nRecno))

	If ExistBlock("STValidCli")
		lRet := ExecBlock("STValidCli",.F.,.F.,{SA1->A1_COD,SA1->A1_LOJA})
	EndIf

	If lRet
		// Integração SIGACRD x TOTVSPDV
		If lPosCrd
			If Len(aCartaoMA6) >= nPos
				cCartaoMA6	:= aCartaoMA6[nPos]
			EndIf
		EndIf
		
		If ExistFunc("LJIsDro") .And. LJIsDro() //Verifica se usa o Template de Drogaria
			cMatricula := AllTrim(SA1->A1_MATRICU)
			
			//Abre a tela para seleção do Plano de Fidelização (Template Drogaria)
			If ExistTemplate("FRT010CL")
				aFRT010CL := ExecTemplate( "FRT010CL", .F., .F., { {}, Nil, SA1->A1_COD, SA1->A1_LOJA, cCartaoMA6, .T., .T.} )
				If ValType(aFRT010CL) == "A" .AND. Len(aFRT010CL) <> 2
					lRet := aFRT010CL[1]
					If lRet
						If ExistFunc("STBDroVars")
							//Seta o (Código do Plano) na variável estática usada nos Fontes do Template de Drogaria
							STBDroVars(.F., .T., aFRT010CL[2], Nil)
						EndIf
					Else
						STFMessage(ProcName(),"STOP","Cliente " + SA1->A1_COD + " não validado - TPL Drogaria")  // "Cliente Selecionado"
						STFShowMessage(ProcName())
					EndIf
				EndIf
			EndIf
		EndIf

		// Integração SIGACRD x TOTVSPDV
		If lRet .And. lPosCrd
			STBSetCrdIdent(cCartaoMA6,AllTrim(SA1->A1_CGC),AllTrim(SA1->A1_COD),AllTrim(SA1->A1_LOJA),cMatricula)
		EndIf
	EndIf
		
	If lRet 
		oModelCli := STWCustomerSelection(SA1->A1_COD+SA1->A1_LOJA)
		STDSPBasket("SL1","L1_CLIENTE"	,oModelCli:GetValue("SA1MASTER","A1_COD"))
		STDSPBasket("SL1","L1_LOJA"		,oModelCli:GetValue("SA1MASTER","A1_LOJA"))
		STDSPBasket("SL1","L1_TIPOCLI"	,oModelCli:GetValue("SA1MASTER","A1_TIPO"))
			
		cCNPJ := oModelCli:GetValue("SA1MASTER","A1_CGC")
		cNome := oModelCli:GetValue("SA1MASTER","A1_NOME")
		cEnd  := oModelCli:GetValue("SA1MASTER","A1_END")
		
		STISCnpjRec( cCNPJ ) //Seta o Cpf/CNPJ do cliente para ser utilizado no Panel de Recebimento de Titulo
		
		//Responsável por setar codigo do cliente e codigo da loja para o recebimento de titulo
		STWSCliLoj(oModelCli:GetValue("SA1MASTER","A1_COD"), oModelCli:GetValue("SA1MASTER","A1_LOJA"))
		
		STFMessage(ProcName(),"STOP",STR0015)  // "Cliente Selecionado"
		STFShowMessage(ProcName())
		aRecno := {}
		
		If !( STIPosGOpc() $ "10|11" )
			If (nCallCPF = 0 .OR. nCallCPF = 1)	//O CPF mostrará antes do lancto. dos itens
				If !Empty(cCNPJ)
					STFMessage("STICLICNPJ", "YESNO", STR0017 ) //"Deseja utilizar o CPF do cliente selecionado para impressão do Comprovante de Venda?"
					lUtilizaCPF := STFShowMessage("STICLICNPJ")
				EndIf
				If !lUtilizaCPF		//Se não utilizar o CPF, limpo também o nome e o endereço
					cCNPJ 	:= ""
					cNome	:= ""
					cEnd	:= ""
				EndIf
				STD7CPFOverReceipt(cCNPJ,cNome,cEnd)		//Armazeno nas variáveis de impressão do Cupom Fiscal
			EndIf
			STDSPBasket("SL1","L1_CGCCLI",cCNPJ)			//Guarda CPF do cliente, permite alterar/limpa na tela padrão de CPF
		EndIf
		
		If STIPosGOpc() == "10" .Or. STIPosGOpc() == "11"
			If STIPosGOpc() == "10"
				STIPanelReceb('R') //"Recebimento de Titulo"
			ElseIf STIPosGOpc() == "11"
				STIPanelReceb('E') //"Estorno de Titulo"
			EndIf
		Else
			STIRegItemInterface()
		EndIf

	Endif 
Else
	STFMessage(ProcName(),"STOP",STR0016)  // "Nenhum cliente foi selecionado."
	STFShowMessage(ProcName())
	oGetSearch:SetFocus()
EndIf

Return