#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "STPOS.CH"


Static oModelCli := Nil
Static oStructSA1	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSearchCostumer
Função responsavel por realizar busca de um determinado cliente atraves do conteudo informado nos campos de busca de cliente na interface do Totvs PDV.

@author  	Lucas Novais
@version 	P12.1.25
@since   	11//11/2019
@param   	cWhatSearch, Caracter, Conteudo a ser buscado
@param   	nLimitRegs, Numérico, Limite de clientes buscado
@param   	lSearchLike, Logíco, indica se fara busca Like (Apenas para Ctree, Banco de dados relacional sempre realiza busca like)
@param   	aFields, Array, Campos a serem utiliados na query e devolvidos no retorno
@param   	lIntCRD, Logico, Indica se o CRD esta ativo, controla alguns desvios na busca
@param   	cCardCrd, Caracter, Em ambientes com CRD ativo busca tambem por Cartão private label
@param   	cMatricula, Caracter, Em ambientes com CRD e Template Drogaria ativo busca tambem por Número de Matrícula do cliente (convênio)

@return		Array, Retorna informações sobre os clientes buscado		  
/*/
//-------------------------------------------------------------------

Function STDSearchCostumer(cWhatSearch,nLimitRegs,lSearchLike,aCustomer,aFields,lIntCRD,cCardCrd,cMatricula)
Local cSGBD				:= ""	// -- Banco de dados atulizado (Para embientes TOP) 			 	
Local cAliasQuery 		:= ""	// -- Alias utilizado para query
Local nCont				:= 0	// -- Contador de clientes adicionados no retorno (Para ambiente CTREE/DBF)

Local aDataCustomers	:= {}	// -- Armazenas dados dos clientes buscados (Campos solicitados atraves do parametro aFields)
Local aCustomers		:= {}	// -- Array com String a ser exibida no TOTVS PDV (NOME / CODIGO / LOJA / CPF / CARTÃO CRD) 
Local aCardMA6			:= {}	// -- Dados do cartão CRD (caso exista e esteja com o CRD ativo (lIntCRD = .T. ))

Local xData				:= Nil	// -- Conteudo do campo que esta sendo adicionado no array xData				
Local nFields			:= 0	// -- Variavel utilizada em FOR
Local nSeek				:= 0	// -- Campo de controle para SEEK, baseado no valor dele é indicado qual indice da tabela sera utilizado
Local cFilter			:= ""	// -- Filtro utilizado em busca CTREE / DBF

Local cStartQuery		:= ""	// -- Variavel para montagem de Query
Local cBodyQuery		:= ""	// -- Variavel para montagem de Query
Local cEndQuery			:= ""	// -- Variavel para montagem de Query
Local cFullQuery		:= ""	// -- Variavel para montagem de Query
Local aFieldSeek		:= {"SA1->A1_COD","SA1->A1_NOME","SA1->A1_CGC"}	// -- Campos que serão comparados baseados no valor de nSeek (Corresponde ao primeiro valor do indice)		

Default cWhatSearch 	:= ""								// -- Conteudo a ser buscado
Default nLimitRegs 		:= SuperGetMV("MV_LJQTDPL",,20) 	// -- Limite de clientes buscado (Recebe do solicitante, caso não exista busca do parametro)
Default	lSearchLike		:= .F.								// -- Indica se fara busca Like	
Default	aCustomer		:= {}								// -- Dados com codigo e loja do cliente em casos de busca especifica. 
Default aFields			:= {}								// -- Campos a serem utiliados na query e devolvidos no retorno
Default lIntCRD			:= .F.								// -- Indica se o CRD esta ativo, controla alguns desvios na busca
Default cCardCrd		:= ""								// -- Em ambientes com CRD ativo busca tambem por Cartão private label
Default cMatricula		:= ""								// -- Em ambientes com CRD + Template Drogaria permite a busca tambem por Número de Matrícula do cliente (convênio)

//Quando aCustomer esta preenhido indica que a busca deverá ser exata, buscando cliente + loja e retornando apenas 1 registro
If !lSearchLike .AND. Len(aCustomer) > 0
	nLimitRegs	:= 1
EndIf 

#IFDEF TOP

	cSGBD 		:= AllTrim(Upper(TcGetDb()))
	cAliasQuery	:= GetNextAlias()

	cStartQuery += " SELECT " 
	
	If cSGBD 		$ "MSSQL|SYBASE" 	
		cStartQuery 	+= " TOP " + AllTrim(Str(nLimitRegs))
	ElseIf cSGBD 	$ "INFORMIX"	 
		cStartQuery 	+= "FIRST " + AllTrim(Str(nLimitRegs))
	EndIf 

	If (nLenFields := Len(aFields)) > 0
		For nFields := 1 To nLenFields
			cStartQuery += aFields[nFields] + ","
		Next nFields

		If lIntCRD
			cStartQuery += " MA6_NUM,"
		EndIf 

		cStartQuery := Left(cStartQuery,Len(cStartQuery)-1)
	EndIf 

	cBodyQuery 	+= " FROM " + RetSQLName("SA1") + " SA1 "
	cBodyQuery 	+= " LEFT JOIN "+ RetSQLName("AI0") +" AI0 ON AI0.AI0_FILIAL = '" + xFilial("AI0") + "' AND SA1.A1_COD = AI0.AI0_CODCLI AND SA1.A1_LOJA = AI0.AI0_LOJA AND AI0.D_E_L_E_T_ = ' ' "
	
	If lIntCRD	
		cBodyQuery 	+= " LEFT JOIN "+ RetSQLName("MA6") +" MA6 ON MA6_FILIAL = '" + xFilial("MA6") + "' AND SA1.A1_COD = MA6_CODCLI AND SA1.A1_LOJA = MA6.MA6_LOJA AND MA6.D_E_L_E_T_ = ' ' "
	EndIf 
	
	cBodyQuery	+= " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "

	If cSGBD 		$ "ORACLE" 
		cBodyQuery 		+= " AND ROWNUM <= " + AllTrim(Str(nLimitRegs))
	ElseIf cSGBD 	$ "DB2"	
		cEndQuery 		+= "FETCH FIRST " + AllTrim(Str(nLimitRegs)) + " ROWS ONLY"
	ElseIf cSGBD 	$ "POSTGRES|MYSQL|SQLITE" 
		cEndQuery 		+= " LIMIT " + AllTrim(Str(nLimitRegs))
	EndIf

	If !Empty(cMatricula)
		cBodyQuery	+= " AND SA1.A1_MATRICU  = '" + cMatricula + "' "
	ElseIf !Empty(cCardCrd)
		cBodyQuery	+= " AND (MA6.MA6_NUM = '" + cCardCrd + "' ) "
	ElseIf !lSearchLike .AND. Len(aCustomer) > 0
		cBodyQuery	+= " AND SA1.A1_COD  = '" + aCustomer[1] + "' "
		cBodyQuery	+= " AND SA1.A1_LOJA = '" + aCustomer[2] + "' "  
	Else 
		cBodyQuery	+= " AND (SA1.A1_COD LIKE '%" + cWhatSearch + "%' OR SA1.A1_CGC LIKE '%" + cWhatSearch + "%' OR SA1.A1_NOME LIKE '%" + cWhatSearch + "%' ) "
	EndIf 

	cBodyQuery	+= " AND SA1.A1_MSBLQL <> '1' "
	cBodyQuery	+= " AND SA1.D_E_L_E_T_ = ' ' "

	cFullQuery 	:= ChangeQuery(cStartQuery + cBodyQuery + cEndQuery)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cFullQuery),cAliasQuery,.T.,.T.)

	//  -- Atualiza o tipo do campo na tabela de memoria baseado no tipo do campo no dicionario.
	For nFields := 1 To nLenFields
		aStructField := TamSX3(aFields[nFields])
		If aStructField[3] $ 'DNL' 
    		TCSetField(cAliasQuery, aFields[nFields], aStructField[3], aStructField[1], aStructField[2] )
  		Endif
	Next

	While (cAliasQuery)->(!EOF())
		
		//-- Posição 1 do retorno, String contendo NOME / CODIGO / LOJA / CPF / CARTÃO CRD
		aAdd(aCustomers, AllTrim((cAliasQuery)->A1_NOME)+" / "+AllTrim((cAliasQuery)->A1_COD)+" / "+AllTrim((cAliasQuery)->A1_LOJA)+" / "+AllTrim((cAliasQuery)->A1_CGC) + IIF(lIntCRD," / " + AllTrim((cAliasQuery)->MA6_NUM),""))
		
		// -- Posição 2 do retorno, Array contendo o conteudo dos campos solicitados
		aAdd(aDataCustomers,{})
		For nFields := 1 To nLenFields
			xData := (cAliasQuery)->&(aFields[nFields])
			If !SubStr(aFields[nFields],1,4) == "AI0_" .Or. ( SubStr(aFields[nFields],1,4) == "AI0_" .AND. !Empty(xData) )
				aAdd(aDataCustomers[Len(aDataCustomers)],{aFields[nFields],xData} )
			EndIf 
		Next 

		// -- Posição 3 do retorno, contem o numero do cartão private label CRD caso exista.
		If lIntCRD
			aAdd(aCardMA6,(cAliasQuery)->MA6_NUM)
		EndIf 

		(cAliasQuery)->(DbSkip())

	End

	(cAliasQuery)->(DbCloseArea())

#ELSE

	DbSelectArea("SA1")
	
	If lSearchLike

		cFilter := " ('" + cWhatSearch + "' $ SA1->A1_NOME .OR. '" + cWhatSearch + "' $ SA1->A1_CGC .OR. '" + cWhatSearch + "' $ SA1->A1_COD ) .AND. SA1->A1_MSBLQL <> '1' "
		
		SA1->(DbSetFilter({ || &cFilter }, cFilter))
		SA1->(DbGoTop())

		While SA1->(!EOF())

			nCont++

			//-- Posição 1 do retorno, String contendo NOME / CODIGO / LOJA / CPF / CARTÃO CRD
			aAdd(aCustomers,AllTrim(SA1->A1_NOME)+" / "+AllTrim(SA1->A1_COD)+" / "+AllTrim(SA1->A1_LOJA)+" / "+AllTrim(SA1->A1_CGC))
			
			// -- Posição 2 do retorno, Array contendo o conteudo dos campos solicitados
			aAdd(aDataCustomers,{})
			For nFields := 1 To Len(aFields)
				If SubStr(aFields[nFields],1,3) == "A1_"
					aAdd(aDataCustomers[Len(aDataCustomers)],{aFields[nFields],&("SA1->" + aFields[nFields])} )
				EndIF 
			Next 

			If nCont == nLimitRegs
				Exit
			EndIf

			SA1->(DbSkip())
		EndDo

		SA1->(DbClearFilter())
	Else

		For nSeek := 1 To Len(aFieldSeek)
			SA1->(DbSetOrder(nSeek)) // -- 1 = Filial + Cod, 2 = Filial + Nome, 3 = Filial + CGC.
			If SA1->(DbSeek(xFilial("SA1") + cWhatSearch))

				While AllTrim(cWhatSearch) $ AllTrim(&(aFieldSeek[nSeek]))
					
					If SA1->A1_MSBLQL <> '1'
						cCustomer := AllTrim(SA1->A1_NOME)+" / "+AllTrim(SA1->A1_COD)+" / "+AllTrim(SA1->A1_LOJA)+" / "+AllTrim(SA1->A1_CGC)
						
						If aScan(aCustomers,{|x| x == cCustomer}) == 0
							nCont++

							//-- Posição 1 do retorno, String contendo NOME / CODIGO / LOJA / CPF / CARTÃO CRD
							aAdd(aCustomers,cCustomer)

							// -- Posição 2 do retorno, Array contendo o conteudo dos campos solicitados
							aAdd(aDataCustomers,{})
							For nFields := 1 To Len(aFields)
								If SubStr(aFields[nFields],1,3) == "A1_"
									aAdd(aDataCustomers[Len(aDataCustomers)],{aFields[nFields],&("SA1->" + aFields[nFields])} )
								EndIF 
							Next 

							If nCont == nLimitRegs
								Exit
							EndIf
						EndIf 
					EndIf 
					SA1->(DbSkip())
				End

				If Len(aCustomers) > 0
					Exit
				EndIf 

			EndIf 
		Next 
	EndIf 

#ENDIF 

Return {aCustomers,aDataCustomers,aCardMA6}

//-------------------------------------------------------------------
/*/{Protheus.doc} STDWhatfields()
Função responsavel por determinar quais campos serão utilizados na importação

@author  	Lucas Novais
@version 	P12.1.25
@since   	11//11/2019
@return		Array, Array contendo campos a serem importados.		  
/*/
//-------------------------------------------------------------------

Function STDWhatfields()
Local aFields		:= {}	// -- Campos para a importação	
Local aRetPE		:= {}	// -- Campos do ponto de entrada		
local nI					// -- Variavel para for

aAdd(aFields,'A1_NOME')
aAdd(aFields,'A1_COD')
aAdd(aFields,'A1_LOJA')
aAdd(aFields,'A1_CGC')
aAdd(aFields,'A1_NREDUZ')
aAdd(aFields,'A1_PESSOA')
aAdd(aFields,'A1_TIPO')
aAdd(aFields,'A1_END')
aAdd(aFields,'A1_EST')
aAdd(aFields,'A1_MUN')
aAdd(aFields,'A1_BAIRRO')
aAdd(aFields,'A1_DDD')
aAdd(aFields,'A1_TEL')
aAdd(aFields,'A1_CEP')
aAdd(aFields,'A1_COD_MUN')
aAdd(aFields,'A1_MSBLQL')
aAdd(aFields,'A1_DTNASC')
aAdd(aFields,'A1_FILIAL')
aAdd(aFields,'A1_GRPVEN')
aAdd(aFields, "AI0_CLIFUN")

//Se usa o Template de Drogaria, adiciona outros campos
If ExistFunc("LJIsDro") .And. LJIsDro()
    aAdd(aFields,'A1_MATRICU')
	aAdd(aFields,'A1_VENCLC')
	aAdd(aFields,'A1_TPCONVE')
	aAdd(aFields,'A1_EMPCONV')
	aAdd(aFields,'A1_LOJCONV')
EndIf

//Ponto de entrada para retornar campos adicionais no aFields
If ExistBlock("STSELFIELD")
	aRetPE := ExecBlock("STSELFIELD",.F.,.F.,{"SA1"})
EndIf

For nI := 1 To Len(aRetPE)
	aAdd(aFields, aRetPE[nI])
Next nI									

Return aFields
//-------------------------------------------------------------------
/*/{Protheus.doc} STDCustomerData
Cria estrutura de dados do Model de clientes, sem suas validacoes.
@param  cKey		 	Chave de Pesquisa. Contém Filial, Cliente e Loja.
@param  lOffline	Pesquisa offiline 
@author  Varejo
@version P11.8
@since   19/09/2012
@return  xRet - Retorna estrutura de dados do Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCustomerData( cKey , lOffline )

Local aArea	 	:= GetArea()					// Guarda area
Local oStruct 	:= 	Nil							// Estrutura 
Local xRet 		:= 	IIF(lOffline,Nil,{})		// Se a busca for offline, sera retornado um model. Caso contrario, sera retornado um array
Local aCampos		:= {}							// Array de campos
Local nX			:= 0							// Contador

Default cKey		 	:= ""
Default lOffline		:= .F.		

	
ParamType 0 Var cKey 		AS Character	Default ""
ParamType 1 var lOffline	As Logical		Default 	.F.

/*/
	Monta estrutura de tabela de clientes
/*/
oStruct := NoVldStruct()

aCampos := oStruct:GetFields() 

If lOffline
	/*/
		Instacia Objeto
	/*/
	xRet 	:= 	MPFormModel():New( 'SA1', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	xRet:AddFields("SA1MASTER",/*cOwner*/,oStruct)
	xRet:SetDescription("Customers")
	xRet:SetOperation(3)
	xRet:DeActivate()
	xRet:Activate()
EndIf


/* 
	Preenche o Modelo de dados do cliente com as informacoes da tabela SA1
*/

DbSelectArea("SA1")
DbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA	
If 	DbSeek	( cKey )
	For nX := 1 to Len(aCampos)
		If lOffline
			xRet:SetValue('SA1MASTER', aCampos[nX][MODEL_FIELD_IDFIELD], &("SA1->"+aCampos[nX][MODEL_FIELD_IDFIELD]))				
		Else
			AAdd(xRet,{aCampos[nX][MODEL_FIELD_IDFIELD],&("SA1->"+aCampos[nX][MODEL_FIELD_IDFIELD])})
		EndIf	
	Next nX
EndIf

If lOffline
	
	If ValType(oModelCli) == 'O'
		oModelCli:DeActivate()
		oModelCli := Nil
	EndIf
	
	oModelCli := xRet
EndIf

RestArea(aArea)

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} NoVldStruct
Cria estrutura do Model de clientes, sem suas validacoes.
@param   
@author  Varejo
@version P11.8
@since   19/09/2012
@return  oStruct - retorna estrutura do Model 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function NoVldStruct() 

Local aArea	 	:= Nil
Local cAlias	:= "SA1"							// Alias que criara estrutura													
Local nCount	:= 0
Local cX2Unico  := "A1_FILIAL+A1_COD+A1_LOJA" //X2_UNICO da tabela SA1

If ValType(oStructSA1) = 'O'
	oStructSA1:Deactivate()
	oStructSA1:Activate()
Else

	oStructSA1 	:= FWFormModelStruct():New()	// Estrutura

	aArea := GetArea()	// Guarda area
	//Carrega informacoes da Tabela
	SX2->( DbSetOrder( 1 ) )
	SX2->( DbSeek( cAlias ) )
			
	If ExistFunc('FWX2Unico') 
		cX2Unico := FWX2Unico(cAlias) 
	EndIf

	oStructSA1:AddTable( 							;
				FWX2CHAVE()                			, 	;  	// [01] Alias da tabela
				StrTokArr( cX2Unico, '+' ) 			, 	;  	// [02] Array com os campos que correspondem a primary key
				FWX2Nome(cAlias) 					)		// [03] Descrição da tabela


	//Carrega informacoes de campos
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAlias))
	
	While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAlias
	
	  	nCount++
	  	If nCount > 1000
	  		Conout('NoVldStruct - Count>1000',nCount)
	  	EndIf
	
		If Upper(AllTrim(SX3->X3_TIPO)) <> "M" .AND. SX3->X3_CONTEXT <> 'V'
		  	oStructSA1:AddField(                                   		;
	                     AllTrim( X3Titulo()  )        			,	; 	// [01] Titulo do campo
	                     AllTrim( X3Descric() )         			,	; 	// [02] ToolTip do campo
	                     AllTrim( SX3->X3_CAMPO )         		,	; 	// [03] Id do Field
	                     SX3->X3_TIPO                  			,	; 	// [04] Tipo do campo
	                     SX3->X3_TAMANHO               			,	; 	// [05] Tamanho do campo
	                     SX3->X3_DECIMAL                			,	; 	// [06] Decimal do campo
	                     Nil                         				,	; 	// [07] Code-block de validacaoo do campo
	                     Nil                          				,	; 	// [08] Code-block de validacaoo When do campo
	                     StrTokArr( AllTrim( X3CBox() ),';')	, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 										,	; 	// [10] Indica se o campo tem preenchimento obrigatorio
	                     Nil                         				, 	; 	// [11] Code-block de inicializacao do campo
	                     NIL                            			, 	; 	// [12] Indica se trata-se de um campo chave
	                     NIL                            			, 	; 	// [13] Indica se o campo pode receber valor em uma operacao de update.
	                     ( SX3->X3_CONTEXT == 'V' )     			)      	// [14] Indica se o campo e virtual
		EndIf    
		 
		SX3->(DbSkip()) 
	End
	
	RestArea(aArea)
EndIf
	
Return oStructSA1


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDGCliModel
Funcao que retorna o Model do cliente preenchido.

@author Varejo
@since 16/10/2012
@version 11.8
@return oModelCli - Model do Cliente
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDGCliModel()
Return oModelCli


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDFilPBCustomerData
Funcao que retorna o Model do cliente preenchido.
@param  cCliente	Cliente
@param  cLoja			Loja 
@author Varejo
@since 16/10/2012
@version 11.8
@return Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFilPBCustomerData( cCliente , cLoja )

Default cCliente		:= ""
Default cLoja		:= "" 

ParamType 0 Var cCliente 		AS Character	Default ""
ParamType 1 var cLoja			As Character	Default ""

STDSPBasket("SL1","L1_CLIENTE"	,oModelCli:GetValue("SA1MASTER","A1_COD"))
STDSPBasket("SL1","L1_LOJA"		,oModelCli:GetValue("SA1MASTER","A1_LOJA"))
STDSPBasket("SL1","L1_TIPOCLI"	,oModelCli:GetValue("SA1MASTER","A1_TIPO")) 

Return Nil 


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDFilPBCustomerData
Funcao que retorna o Model do cliente preenchido.
@param aDados - array de dados do cliente
@author Varejo
@since 16/10/2012
@version 11.8
@return oModel - Model do cliente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFilCliData( aDados )

Local oStruct 		:= 	Nil			// Estrutura 
Local oModel 			:= 	Nil			// Model do Cliente
Local nX				:= 0			// Contador

Default aDados		 	:= {}	
	
ParamType 0 Var aDados AS Array	Default {}

/*/
	Monta estrutura de tabela de clientes
/*/
oStruct := NoVldStruct()

/*/
	Instacia Objeto
/*/
oModel 	:= 	MPFormModel():New( 'SA1', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields("SA1MASTER",/*cOwner*/,oStruct)
oModel:SetDescription("Customers")
oModel:SetOperation(3)
oModel:Activate()

For nX := 1 to Len(aDados)
	oModel:LoadValue('SA1MASTER', aDados[nX][FIELD_NAME], aDados[nX][FIELD_VALUE])		
Next nX 

oModelCli := oModel

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} STDFindCust()
Pesquisa o cliente em especifico

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDFindCust()

Local aRet 		:= {}
Local cCustomer	:= STDGPBasket("SL1","L1_CLIENTE")
Local cLoja	 	:= STDGPBasket("SL1","L1_LOJA")

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial('SA1')+cCustomer+cLoja))
If SA1->(!EOF())

	Aadd(aRet,SA1->A1_NOME)
	Aadd(aRet,SA1->A1_CGC)

EndIf 

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDCliRecCGC()
Retorna o Recno do cliente pela busca por CGC

@param	  cCGC  recebe CPF ou CNPJ
@author  Varejo
@version P11.80
@since   26/01/2015
@return  nRecno Recno da busca
@obs
@sample
*/
//-------------------------------------------------------------------
Function STDCliRecCGC(cCGC)

Local aArea	 := GetArea()// Guarda area
Local nRecno := 0 //Recno

Default cCGC := ""

DbSelectArea("SA1")
SA1->(DbSetOrder(3))	//FILIAL + CGC	
If DbSeek(xFilial("SA1")+AllTrim(cCGC))
	nRecno := SA1->(Recno())
EndIf

RestArea(aArea)
		
Return nRecno

//-------------------------------------------------------------------
/*{Protheus.doc} STDVerfCadCli()
Verificar cadastrdo do cliente 
@param	  cKey  COD + LOJA 
@version P11.80
@since   19/02/2015
@return  Array, Retorno contendo se achou e recno 
*/
//-------------------------------------------------------------------
Function STDVerfCadCli(cKey) 

Local aArea	 := GetArea()// Guarda area
Local lRet 	 := .F.
Local nRecno := 0 

Default cKey 	 := ""

DbSelectArea("SA1")
DbSetOrder(1) //FILIAL + COD + LOJA

If DbSeek( xFilial("SA1") + cKey )
	nRecno := SA1->(Recno())
	lRet := .T.
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return {lRet,nRecno}
