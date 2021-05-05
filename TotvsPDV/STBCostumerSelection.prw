#INCLUDE 'Protheus.ch'
#INCLUDE 'STBCOSTUMERSELECTION.CH'

Static aCliCrd := {"","","","",""}

//-------------------------------------------------------------------
/*{Protheus.doc} STBCadCli
Cadastro de cliente não localizado localmente mediante a busca de orçamento

@param		aOrcImp, array, Array com o orçamento importado
@author 	Varejo
@since 	23/01/2015
@version 	11.80
@return	Nil, Nulo

*/
//-------------------------------------------------------------------
Function STBCadCli(aOrcImp) 

Local aCustomer 	:= {}	// -- Dados do codigo do cliente e loja
Local cKey			:= ""	// -- Chave para busca (Cliente + Loja)
Local cCod 			:= "" 	// -- Codigo do cliente
Local cLoja			:= ""	// -- Codigo da loja

Local aDataCustomers:= {}	// -- Dados para a gravação do cliente
Local aCampos		:= {}	// -- Campos a ser gravados
Local aDados		:= {}	// -- Valor dos campos a ser gravados
Local nCustomer		:= 0	// -- Variavel para repetição
Local uResult		:= Nil	// -- Variavel com o resultado da consulta na retaguarda
Local lRet			:= .F.  // -- Retorno da consulta na retaguarda				
Local aParam		:= {}   // -- Parametros a ser enviado para a função que será executada na retaguarda

Default aOrcImp 	:= {}	// -- Dados do orçamento 

If Len(aOrcImp) > 0
	// Pega o orcamento importado os campos chaves de cliente e loja
	cCod 	:= aOrcImp[1][1][aScan(aOrcImp[1][1], { |x| x[1] == "L1_CLIENTE"})][2]
	cLoja 	:= aOrcImp[1][1][aScan(aOrcImp[1][1], { |x| x[1] == "L1_LOJA"})][2]
		
	If ValType(cCod) <> "C" .OR. ValType(cLoja) <> "C"
		cCod 	:= ""
		cLoja	:= ""
	EndIf	
	
	cKey := cCod + cLoja
	
	//Verifica se o cliente existe na base local
	If !Empty(cKey) .AND. !STDVerfCadCli(cKey)[1]
		
		aFields		:= STDWhatfields()
		aCustomer 	:= {cCod,cLoja}

		//pega dados do cliente na retaguarda

		aParam := {Nil,1,.F.,aCustomer,aFields}
		
		STFMessage(ProcName(), "RUN", STR0002  ,{ || lRet := STBRemoteExecute("STDSearchCostumer", aParam,,, @uResult) })
		STFShowMessage(ProcName())
		
		aDataCustomers := uResult[2]
			
		If lRet .AND. Len(aDataCustomers) > 0

			aADD(aDados,{})	
			For  nCustomer := 1 To len(aDataCustomers[1]) 
				aADD(aCampos,aDataCustomers[1][nCustomer][1])
				aADD(aDados[Len(aDados)] ,aDataCustomers[1][nCustomer][2])
			Next	

			STIConfCus(	aDataCustomers[1][2][2]	,aDataCustomers[1][3][2]	,aDataCustomers[1][1][2]	,aDataCustomers[1][5][2],;
					aDataCustomers[1][6][2]		,aDataCustomers[1][4][2]	,aDataCustomers[1][7][2]	,aDataCustomers[1][8][2],;
					aDataCustomers[1][9][2]		,aDataCustomers[1][10][2]	,.T.			  			,.F.					,;
					aDataCustomers[1][11][2]	,aDataCustomers[1][12][2]	,aDataCustomers[1][13][2]	,aCampos				,;
					aDados			,.F. , "TX" ) //Cadastra Cliente 
		Else 

			LjGrvLog(ProcName(),"Não foi possivel incluir o cliente Cod: " + cCod + " Loja: " + cLoja )

		EndIf					
	EndIf
EndIf	

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STBGetCust
Funcao responsavel pela busca de clientes no banco de dados da Retaguarda (Base TOP).

@param		cFil 		Filial a ser realizada a busca.
@param		cNome  		Nome do Cliente a ser pesquisado.
@param		nLimitRegs	Quantidade Limite de registros que se deseja pesquisar. 
@author 	Varejo
@since 		07/05/2015
@version 	11.80
*/
//-------------------------------------------------------------------
Function STBGetCust(cFil, cNome, nLimitRegs)
Local uDados	       	:= {}
Local aParam          	:= {}
Local uResult         	:= Nil
Local aFields 			:= {}
Local aTables 			:= {} 
Local cWhere 				:= ""
Local cOrderBy 			:= ""
Local cPesqNoLike			:= "" //Pesquisa nao like

Default cFil := ""
Default cNome := ""
Default nLimitRegs := 20

cNome := AllTrim(cNome)
cPesqNoLike := cNome

If At(cNome,'*') == 0
	cNome := '*' + cNome + '*'
EndIf

cNome := Replace(cNome,"*","%")

//Monta os campos da query
aFields := {"A1_COD", "A1_LOJA", "A1_NOME", "A1_MSBLQL", "A1_CGC"}

//Tabela da Query
aTables := {"SA1"}

//Monta a Cláusula Where da query
cWhere := "A1_FILIAL = '"+cFil+"' AND "
cWhere += "(A1_NOME LIKE '" + cNome + ;
		   "' OR A1_COD LIKE '" + cNome + ; 
		   "' OR A1_CGC = '" + cPesqNoLike + "') AND " 
cWhere += "D_E_L_E_T_ = ' ' AND A1_MSBLQL <> '1'"

//Monta a Cláusula Order By da query
cOrderBy := "A1_NOME"

// Busca de Clientes via STBRemoteExecute
aParam 	:= {	aFields,;
				aTables,;
				cWhere,;
				cOrderBy,;
				nLimitRegs;
			}
			
If !STBRemoteExecute("STDQueryDB", aParam,,, @uResult)
	// Tratamento do erro de conexao
	uDados := .F.
Else
	uDados := uResult
EndIf 

Return uDados

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetCrd
Funcao responsavel pela busca de clientes e cartão para SIGACRD no banco de dados da Retaguarda (Base TOP).
Baseado na função WebService WSCRD013 em WSCRD010.prw
@type function

@author Marisa V. N. Cruz
@since 13/03/2017
@version P12

@param		cCartao		, caracter, Cartão Fidelidade
@param		cCPF		, caracter, CPF ou CNPJ do Cliente
@param		nLimitRegs	, numérico, Limite de Registros a ser mostrado no componente

@return lógico ou array , Conteúdo em array do SA1 ou False
/*/
//-------------------------------------------------------------------

Function STBGetCrd( cCPF, cCartao, nLimitRegs )
Local aRet	 			:= { 0, "", "", {}, {"",""} }		// Retorno da funcao
Local nX 				:= 0 						// Variavel de looping
Local nY 				:= 0 						// Variavel de looping
Local lContinua			:= .T.						// Variavel para nao continuar o processamento
Local cChaveSA1			:= "" 						// Chave do SA1. Utilizada para buscar mais de 1 ocorrencia no SA1
Local cChaveBusca		:= "" 						// Chave de busca no SA1. Utilizada para buscar mais de 1 ocorrencia no SA1
Local nOrdemSA1 		:= 0						// Order de busca no SA1.
Local lPesqMatricula	:= .F.						// Pesquisa pela matricula
Local nRecnoSA1			:= 0 						// Guarda o recno do cliente posicionado na SA1

Local uDados	       	:= { 0, "", "", {}, {"",""} }		// Retorno da funcao
Local aParam          	:= {}
Local uResult         	:= Nil
Local aFields 			:= {}
Local aTables 			:= {} 
Local cWhere 				:= ""
Local cOrderBy 			:= ""
Local cPesqNoLike		:= "" 						//Pesquisa nao like
Local aAreaSA1			:= {}						//Area SA1
Local lRet				:= .T.

Default	cCartao			:= ""
Default cCPF			:= ""
Default nLimitRegs 		:= 20

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa o cadastro do cliente                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Monta os campos da query
aFields := {"MA6_CODCLI", "MA6_LOJA", "A1_NOME", "A1_MSBLQL", "MA6_NUM" ,"MA6_CODDEP", "MA6_SITUA", "A1_COD", "A1_LOJA", "A1_CGC"}

//Tabela da Query
aTables := {"MA6","SA1"}

//Monta a Cláusula Where da query
cWhere := "MA6_FILIAL = '"+xFilial("MA6")+"' AND "
If !Empty(cCartao)
	cWhere += "MA6_NUM = '"+cCartao+"' AND "
ElseIf !Empty(cCpf)
	cWhere += "A1_CGC = '"+cCpf+"' AND "
EndIf
cWhere += "MA6_CODCLI = A1_COD AND "
cWhere += "MA6_LOJA = A1_LOJA AND "
cWhere += "A1_FILIAL = '"+xFilial("SA1")+"' AND "
cWhere += "MA6.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND MA6_SITUA = '1'"	//Se cartão ativo

//Monta a Cláusula Order By da query
cOrderBy := "A1_COD,A1_LOJA"

// Busca de Clientes via STBRemoteExecute
aParam 	:= {	aFields,;
				aTables,;
				cWhere,;
				cOrderBy,;
				nLimitRegs;
			}

If !STBRemoteExecute("STDQueryDB", aParam,,, @uResult)
	uDados := .F.
Else
	LjGrvLog("StbGetCrd",cCpf + " encontrado via STBRemoteExecute!")
	uDados := uResult
EndIf

If ValType(uDados) = "L" .AND. !uDados
	// Tratamento do erro de conexao
	STFMessage(ProcName(), "ALERT", STR0001 )  //Por falta de comunicação com o Back-Office, será selecionado o cliente padrão.
	STFShowMessage(ProcName())
	LjGrvLog("StbGetCrd",STR0001)
	If !Empty(cCpf)					//Tratamento do erro de conexao: Caso não encontrar o cartão, pesquiso localmente na SA1.
		aAreaSA1 := SA1->(GetArea())
		SA1->(DbSetOrder(3))		//A1_FILIAL+A1_CGC
		If SA1->( DbSeek(xFilial("SA1")+cCpf))
			LjGrvLog("StbGetCrd",cCpf + " encontrado na base local!")
			uDados := {{SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,SA1->A1_MSBLQL,"","","",SA1->A1_COD,SA1->A1_LOJA,SA1->A1_CGC}}
		Else
			LjGrvLog("StbGetCrd",cCpf + " NÃO encontrado na base local!")
			uDados := .F.
		EndIf
		RestArea(aAreaSA1)
	Else
		uDados := .F.
	EndIf							
EndIf

Return uDados


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetCrdIdent
Gravo os dados do cartão, CPF/CNPJ, código do cliente e loja do cliente
@type function

@author Marisa V. N. Cruz
@since 14/03/2017
@version P12

@param		cCartao		, caracter, Cartão Fidelidade
@param		cCPF		, caracter, CPF ou CNPJ do Cliente
@param		cCliente	, caracter, Código do Cliente
@param		cLoja		, caracter, Loja do Cliente 
@param		cMatricula	, caracter, Matricula do cliente no caso de Convênio (Template Drogaria)

@return array {Cartão Fidelidade, CPF ou CNPJ do Cliente, Código do Cliente, Loja do Cliente}
/*/
//-------------------------------------------------------------------
Function STBSetCrdIdent( cCartao, cCPF, cCliente, cLoja, cMatricula )

Local nCompCartao 	:= TamSX3("MA6_NUM")[1]
Local nCompCPF		:= TamSX3("A1_CGC")[1]

Default cCartao 	:= ""
Default cCPF		:= ""
Default cCliente 	:= ""
Default cLoja		:= ""
Default cMatricula  := ""

aCliCrd := { 	PadR(cCartao,nCompCartao),;
				PadR(cCPF,nCompCPF),;
				cCliente,;
				cLoja,;
                cMatricula }

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetCrdIdent
Leio os dados do cartão, CPF/CNPJ, código do cliente e loja do cliente
@type function

@author Marisa V. N. Cruz
@since 14/03/2017
@version P12

@param nil

@return array {Cartão Fidelidade, CPF ou CNPJ do Cliente, Código do Cliente, Loja do Cliente}
/*/
//-------------------------------------------------------------------
Function STBGetCrdIdent()

Return aCliCrd

/*/{Protheus.doc} STBPlanFid
    Tela para seleção do Plano de Fidelização (Template Drogaria). Precisa estar posicionado na SA1.
    @type  Function
    @author Alberto Deviciente
    @since 05/2021
    @version 12
    @param cCartaoMA6, Caracter, Número do Cartao CRD
	@param cMatricula, Caracter, Matricula do cliente (A1_MATRICU)
    @return lRet, lógico, Finalizou a Venda ?
/*/
Function STBPlanFid(cCartaoMA6, cMatricula)
Local lRet      := .T.
Local aFRT010CL := {}
Local cCliPad	:= ""
Local cLojaPad	:= ""

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
			cCliPad		:= PadR(SuperGetMV("MV_CLIPAD",, ""),TamSx3("A1_COD")[1])
			cLojaPad	:= PadR(SuperGetMV("MV_LOJAPAD",, ""),TamSx3("A1_LOJA")[1])
			If (SA1->A1_COD <> cCliPad .OR. SA1->A1_LOJA <> cLojaPad)
				STFMessage(ProcName(),"YESNO", "Pesquisa cancelada. Deseja manter o Cliente :" + AllTrim(SA1->A1_COD) + " Loja :" + SA1->A1_LOJA ;
						 + " atual da venda?  Em caso negativo, será alterado para o cliente padrão." )
				lRet := STFShowMessage(ProcName())
				If !lRet
					DbSelectArea( "SA1" )
					SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
					lRet := SA1->(DbSeek(xFilial("SA1")+cCliPad+cLojaPad)) //A1_FILIAL+A1_COD+A1_LOJA
					//Limpa os campos de Cartao e Matricula, pois será considerado o Cliente Padrão para  avenda
					cCartaoMA6 := ""
					cMatricula := ""
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet