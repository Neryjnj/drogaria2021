#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"         
#INCLUDE "STDPRODUCTBASKET.CH"

Static oModelPBasket	:= NIl

//-------------------------------------------------------------------
/*/{Protheus.doc} STDProductBasket
Definicao do Modelo
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDProductBasket()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do Modelo
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  oModel - Model 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructSL1 	:= FWFormStruct(1,"SL1")
Local oStructSL2 	:= FWFormStruct(1,"SL2")
Local oStructSL4 	:= FWFormStruct(1,"SL4")
Local oStructMGC 	:= FWFormStruct(1,"MGC")
Local oModel 		:= Nil

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel := MPFormModel():New("STDProductBasket",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

// Campo L1_TOTFISC - Esse campo nao existe no dicionário
oStructSL1:AddField(                           	;
                     STR0007	 	,	; // [01] Titulo do campo # "Tot It Fis"	
                     STR0008	 	,	; // [02] Desc do campo #"Total do Item Fiscal"	
                     "L1_TOTFISC"		,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo do campo
                     8				   	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD, "0" ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual                		 

// Campo L1_TOTNFIS - Esse campo nao existe no dicionário
oStructSL1:AddField(                           	;
                     STR0009	 	,	; // [01] Titulo do campo # "It Nao Fisc"	
                     STR0010		 	,	; // [02] Desc do campo # "Total Item Nao Fiscal"
                     "L1_TOTNFIS"		,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo do campo
                     8				   	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,"0" ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual 

// Campo L1_DESCTOT - Esse campo nao existe no dicionário
oStructSL1:AddField(                           	;
                     STR0021	 			,	; // [01] Titulo do campo # "Desc.Total"	
                     STR0022		 		,	; // [02] Desc do campo # "Desconto concedido no total da venda"
                     "L1_DESCTOT"			,	; // [03] Id do Field
                     "N"             		,	; // [04] Tipo do campo
                     16				   		,	; // [05] Tamanho do campo
                     2                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,"0" ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual 

// Campo L1_BONIF - Esse campo nao existe no dicionário
oStructSL1:AddField(                           	;
                     STR0023	 			,	; // [01] Titulo do campo # "Bonif."	
                     STR0024		 		,	; // [02] Desc do campo # "Valor Tot. da Bonificação"
                     "L1_BONIF"				,	; // [03] Id do Field
                     "N"             		,	; // [04] Tipo do campo
                     16				   		,	; // [05] Tamanho do campo
                     2                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,"0" ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual 

oModel:AddFields("SL1MASTER", Nil/*cOwner*/, oStructSL1 ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

// Campo L2_FISCAL - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     STR0001  			 	,	; // [01] Titulo do campo
                     STR0001  			 	,	; // [02] Desc do campo
                     "L2_FISCAL" 	 		,	; // [03] Id do Field
                     "L"              		,	; // [04] Tipo do campo
                     1					   	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               								)	  // [14] Indica se o campo e virtual

// Campo L2_BONIFICADOR - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     "Bonificador?"		 	,	; // [01] Titulo do campo
                     "Bonificador?"		 	,	; // [02] Desc do campo
                     "L2_BONIFICADOR"		,	; // [03] Id do Field
                     "L"              		,	; // [04] Tipo do campo
                     1					   	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,".F." ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual   

// Campo L2_ITFISC - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     STR0011		 	,	; // [01] Titulo do campo#"It Fiscal"
                     STR0012	 	,	; // [02] Desc do campo #"Item Fical"	
                     "L2_ITFISC"		,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSx3("L2_ITEM")[1]					   	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,"" ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual  
               		 

// Campo L2_ITNFISC - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     STR0013	 	,	; // [01] Titulo do campo "It Nao Fisc"	
                     STR0014		 	,	; // [02] Desc do campo # "Item Nao Fiscal"
                     "L2_ITNFISC"		,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSx3("L2_ITEM")[1]					   	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,"" ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual 
               		 
// Campo L2_ITEMREA - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     "Item Real"	 			,	; // [01] Titulo do campo "It Nao Fisc"	
                     "Item Real"		 	,	; // [02] Desc do campo # "Item Nao Fiscal"
                     "L2_ITEMREA"			,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSx3("L2_ITEM")[1]	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,"" ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual 

// Campo L2_REGSLX - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     "NumReg SLX?"		 	,	; // [01] Titulo do campo
                     "NumReg SLX?"		 	,	; // [02] Desc do campo
                     "L2_REGSLX"			,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo do campo
                     10					   	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     FwBuildFeature( STRUCT_FEATURE_INIPAD,".F." ) , 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual

// Campo L2_TABPAD - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     "Tab Pad"		 		,	; // [01] Titulo do campo
                     "Tab Pad"		 		,	; // [02] Desc do campo
                     "L2_CODTAB"			,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSx3("DA0_CODTAB")[1]	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil 					, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual   

// Campo L2_ITPBM - Esse campo nao existe no dicionário
oStructSL2:AddField(                           	;
                     "Item PBM"		 		,	; // [01] Titulo do campo
                     "Item PBM"		 		,	; // [02] Desc do campo
                     "L2_ITPBM"				,	; // [03] Id do Field
                     "L"              		,	; // [04] Tipo do campo
                     1						,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil              		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil 					, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 .T.					)	  // [14] Indica se o campo e virtual   

oModel:AddGrid("SL2DETAIL","SL1MASTER"/*cOwner*/,oStructSL2,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:SetRelation("SL2DETAIL",{{"L2_FILIAL",'xFilial("SL2")'},{"L2_NUM","L1_NUM"}},SL2->(IndexKey(1)))
oModel:GetModel("SL2DETAIL"):SetOptional(.T.)
oModel:GetModel("SL2DETAIL"):SetOnlyView(.T.)

// Retira o obrigatorio de todos os campos da SL2 para nao sobrepor os itens smpre na primeira linha
oStructSL2:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)	 

oModel:AddGrid("SL4DETAIL","SL1MASTER"/*cOwner*/,oStructSL4,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
oModel:SetRelation("SL4DETAIL",{{"L4_FILIAL",'xFilial("SL4")'},{"L4_NUM","L1_NUM"}},SL4->(IndexKey(1)))
oModel:GetModel("SL4DETAIL"):SetOptional(.T.)

If AliasInDic("MGC")
	oModel:AddGrid("MGCBRINDE","SL1MASTER"/*cOwner*/,oStructMGC,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
	oModel:SetRelation("MGCBRINDE",{{"MGC_FILIAL",'xFilial("MGC")'},{"MGC_NUM","L1_NUM"}},MGC->(IndexKey(1)))
	oModel:GetModel("MGCBRINDE"):SetOptional(.T.)
EndIf
/*
Seta a descricao de todos os modelos de dados
*/
oModel:SetDescription("Cesta de Produtos")
oModel:GetModel("SL1MASTER"):SetDescription(STR0002) //"Orçamento"
oModel:GetModel("SL2DETAIL"):SetDescription(STR0003) //"Itens de Orçamento"
oModel:GetModel("SL4DETAIL"):SetDescription(STR0004) //"Condição Negociada"

If AliasInDic("MGC")
	oModel:GetModel("MGCBRINDE"):SetDescription("BRINDE")//"Brinde"
EndIf	

oStructSL1:SetProperty( "*",MODEL_FIELD_VALID,{|| .T.} )
oStructSL2:SetProperty( "*",MODEL_FIELD_VALID,{|| .T.} )
oStructSL4:SetProperty( "*",MODEL_FIELD_VALID,{|| .T.} )
If AliasInDic("MGC")
	oStructMGC:SetProperty( "*",MODEL_FIELD_VALID,{|| .T.} )
EndIf	

oModelPBasket:= oModel
oModelPBasket:SetOperation(3)
oModelPBasket:Activate()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSPBasket
Funcao utilizada para setar valores ao model da cesta de produtos.
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  lRet - Se setou valores corretamente 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSPBasket( cAlias , cField , xValue , nLine )

Local cModelID		:= ""				// ID do model de cAlias
Local cError		:= ""				// Mensagem de erro contida no objeto de tratamento de erro.
Local lRet 			:= .F.				// Retorno da funcao
Local nField		:= 0				// Retorno do aScan, que representa a posicao de cField dentro de aFields.
Local aFields		:= {}				// Array com todos os campos da estrutura do cModelID selecionado
Local aSaveLines 	:= FWSaveRows()		// array de linhas salvas
Local oViewGrid		:= Nil				// Objeto view	
Local oModelGrid	:= Nil				// Objeto model
Local bOldError		:= ErrorBlock( {|oErro|STBTratErro(oErro,@cError)} ) // Muda code-block de erro
Local cTipoxValue	:= ""				// Tipo da variavel xValue
Local cMsg			:= ""				// Mensagem auxialiar para log
Local cIdLog		:= ""				// Mensagem auxialiar para log			
Local lCancelSale	:= .F.				// Cancela venda 

Default cAlias 		:= ""
Default cField 		:= ""
Default xValue 		:= Nil
Default nLine 		:= 0

cTipoxValue	:= ValType(xValue)
cAlias		:= AllTrim(cAlias)

If cTipoxValue != "U" 
	cMsg := "GravaCesta - Tabela:["+cAlias+"] - Campo:[" + PadR(cField,10) + "] - Valor:[" + cValToChar(xValue) + "]"
Else
	cMsg := "GravaCesta - Tabela:["+cAlias+"] - Campo:[" + PadR(cField,10) + "] - Valor:[Indefinido]" 
EndIf

Do Case
	Case cAlias == "SL1"
		nLine 	:= 0
		cIdLog := "L1_Num:"+STDGPBasket('SL1','L1_NUM')
	Case cAlias == "SL2"
		cIdLog := "L2_Num:"+STDGPBasket('SL2','L2_NUM')
		cMsg 	+= " - Item Produto:" + cValToChar(nLine)
	Case cAlias == "SL4"
		cIdLog := "L4_Num:"+STDGPBasket('SL4','L4_NUM')
		cMsg 	+= " - Item Forma:" + cValToChar(nLine)
EndCase

cModelID := STDGModelID(cAlias) // Funcao que pega o ID do model da tabela passada em cAlias

If !Empty(cModelID) // Verifico se o Model passado para o set existe
	If cTipoxValue != "U"
		Begin Sequence  
			If nLine > 0
				oModelPBasket:GetModel(cModelID):GoLine(nLine)
				lRet := oModelPBasket:LoadValue(cModelID,cField,xValue)
			Else	
				lRet := oModelPBasket:LoadValue(cModelID,cField,xValue)
			EndIf
		End Sequence
	EndIf
	
	// Caso nao haja erro, eh avaliado e exibido no console o motivo do valor nao ter sido setado
	If !lRet 
	
		// Pego todos os campos da estrutura do cModelID
		aFields := oModelPBasket:GetModel(cModelID):GetStruct():GetFields()
		
		// Pego a posicao de cField em aFields, se existir
		nField := aScan(aFields,{|aCampo| aCampo[MODEL_FIELD_IDFIELD] == cField})
		
		If nField > 0
			
			cTipoxValue := ValType(xValue)
				
			Do Case
				Case cTipoxValue == "C"
					cMsg := xValue
				Case cTipoxValue == "D"
					cMsg := AllTrim( DTOS(xValue) )
				Case cTipoxValue == "N"
					cMsg := AllTrim( STR(xValue) )	
			EndCase
			
			If aFields[nField][MODEL_FIELD_TIPO] != ValType(xValue)
				ConOut("O valor: " + cMsg + " Tamanho: " + AllTrim(STR(Len(cMsg))) + " atribuido a variavel xValue Tipo: " + ValType(xValue) + " eh diferente do tipo do campo "+cField+". Tipo: " + aFields[nField][MODEL_FIELD_TIPO]  )
				LjGrvLog( "STDProductBasket", "O valor: " + cMsg + " Tamanho: " + AllTrim(STR(Len(cMsg))) + " atribuido a variavel xValue Tipo: " + ValType(xValue) + " eh diferente do tipo do campo "+cField+". Tipo: " + aFields[nField][MODEL_FIELD_TIPO] )
				ConOut("Em caso de importação de orcamentos Compare o campo " +cField+ " do PDV Local com o campo na base da retaguarda, os dois devem estar iguais." )
				LjGrvLog( "STDProductBasket", "Em caso de importação de orcamentos Compare o campo " +cField+ " do PDV Local com o campo na base da retaguarda, os dois devem estar iguais." )
			Else
				ConOut("A validacao do campo "+cField+" nao foi respeitada. Tipo: " + ValType(xValue) + " valor: " + cMsg + " Tamanho: " + AllTrim(STR(Len(cMsg))) )
				LjGrvLog( "STDProductBasket", "A validacao do campo "+cField+" nao foi respeitada. Tipo: " + ValType(xValue) + " valor: " + cMsg + " Tamanho: " + AllTrim(STR(Len(cMsg))) )
				ConOut("Verifique se o valor esta respeitando o X3_VALID, X3_VLDUSER e consta no X3_CBOX caso preenchido.")
				LjGrvLog( "STDProductBasket", "Verifique se o valor esta respeitando o X3_VALID, X3_VLDUSER e consta no X3_CBOX caso preenchido." )
				ConOut("Em caso de importação de orcamentos Compare o campo " +cField+ " do PDV Local com o campo na base da retaguarda, os dois devem estar iguais." )
				LjGrvLog( "STDProductBasket", "Em caso de importação de orcamentos Compare o campo " +cField+ " do PDV Local com o campo na base da retaguarda, os dois devem estar iguais." )
				lCancelSale := .T.
			EndIf
			
			
			If lCancelSale				
				STFMessage(ProcName(),"POPUP", STR0005 + cField + " " + ;//"Atenção. Erro ao setar valor no campo " 
							STR0017 + ValType(xValue) + STR0018 + cMsg + STR0019 + AllTrim(STR(Len(cMsg))) + ;//"Tipo: "### " Valor: "### " Tamanho: "
							STR0020 +; //" Para Importação de orçamento verifique o campo(SX3) na Base PDV x Retaguarda "
							 STR0006)//" . A venda em andamento será cancelada." 
				STFShowMessage(ProcName())
				//Cancela Venda Atual
				STWCancelSale( .T. ) 
			EndIf
			
		Else
			ConOut("O campo "+cField+" nao faz parte do modelo de dados da tabela "+cAlias+".")
			LjGrvLog( "STDProductBasket","O campo "+cField+" nao faz parte do modelo de dados da tabela "+cAlias+".")
		EndIf			
	EndIf
Else
	ConOut("O Alias passado para a função STDSPBasket não é válido.")
	LjGrvLog( "STDProductBasket","O Alias passado para a função STDSPBasket não é válido.")
EndIf

ErrorBlock(bOldError)

FWRestRows( aSaveLines )

// Limpa os vetores para melhor gerenciamento de memoria (Desaloca Memória)
aSize( aSaveLines, 0 )
aSaveLines 	:= Nil

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDGPBasket
Funcao utilizada para pegar valores do model da cesta de produtos.
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  xRet - Valor do model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGPBasket( cAlias , cField , nLine )

Local cModelID		:= "" 	// ID do model do Alias passado.
Local cError		:= "" 	// Mensagem de erro contida no objeto de tratamento de erro.
Local xRet 			:= Nil	// Retorno (Pode ser de qualquer tipo)	
Local aSaveLines 	:= FWSaveRows()	// Linhas salvas
Local bOldError		:= ErrorBlock( {|oErro| STBTratErro(oErro,@cError)} ) // Muda code-block de erro

Default cAlias 		:= ""
Default cField 		:= ""
Default nLine 		:= 0 

cAlias := AllTrim(cAlias)

cModelID := STDGModelID(cAlias) // Funcao que pega o ID do model da tabela passada em cAlias

If cAlias == "SL1"
	nLine := 0
EndIf

If !Empty(cModelID) .AND. !Empty(cField) // Verifico se o Model passado para o get existe
				
	Begin Sequence
		If nLine > 0
			oModelPBasket:GetModel(cModelID):GoLine(nLine)
			xRet := oModelPBasket:GetValue(cModelID,cField)
		Else
			xRet := oModelPBasket:GetValue(cModelID,cField)
		EndIf
	End Sequence
	
	// TO DO: Substituir o ConOut pelo componente de criacao de log
	If !Empty(AllTrim(cError))
		ConOut(cError)
		LjGrvLog( Nil, cError)
	EndIf
Else
	// TO DO: Substituir o ConOut pelo componente de criacao de log
	ConOut("O alias passado para a função STDGPBasket não é válido.")
	LjGrvLog( cAlias, "O alias passado para a função STDGPBasket não é válido.")
	LjGrvLog( cAlias, " Conteudo do cModelID", cModelID)	
	LjGrvLog( cAlias, " Conteudo do cField", cField)
EndIf

ErrorBlock(bOldError)

FWRestRows( aSaveLines )  

// Limpa o vetor para melhor gerenciamento de memoria (Desaloca Memória)
aSize( aSaveLines,0 )
aSaveLines := Nil

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDPBRestart
Funcao responsavel por reinicializar a cesta
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDPBRestart()

Local oViewGrid	:= Nil 		// Objeto View
Local oModelGrid	:= Nil 		// Objeto Model
Local oModelPri	:= Nil			// Objeto Model principal

oModelPBasket	:= Nil
oModelPBasket	:= FwLoadModel("STDProductBasket")
oModelPri		:= STIGetMdlPri()
If oModelPri <> Nil
	oModelGrid		:= oModelPri:GetModel("CUP_GRID")
	oModelGrid:ClearData()
	oModelGrid:InitLine()
EndIf	 

Return Nil
	

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGPBModel
Funcao utilizada para todo o model da cesta de produtos.
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  oModelPBasket - Model da cesta
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGPBModel()

If oModelPBasket == Nil
	oModelPBasket := FwLoadModel("STDProductBasket")
EndIf	

Return oModelPBasket


//-------------------------------------------------------------------
/*/{Protheus.doc} STDPBAddLine
Funcao utilizada para todo o model da cesta de produtos.
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDPBAddLine(cAlias)

Local cModelID 	:= ""					// ID do model
Local cCRLF		:= Chr(13) + Chr(10)	//Controle de linha

Default cAlias		:= ""

If cAlias == "SL2" .OR. cAlias == "SL4" .OR. cAlias == "MGC"
	cModelID := STDGModelID(cAlias)
	oModelPBasket:GetModel(cModelID):AddLine(.T.)
	
	If Len(oModelPBasket:GetErrorMessage()) > 0 .And. !Empty(oModelPBasket:GetErrorMessage()[6]) 
		ConOut(cCRLF + STR0016 + oModelPBasket:GetErrorMessage()[6] + cCRLF)
		LJGrvLog("L1_NUM: " + STDGPBasket("SL1", "L1_NUM"), STR0016 + oModelPBasket:GetErrorMessage()[6])
		LJGrvLog("L1_NUM: " + STDGPBasket("SL1", "L1_NUM"), STR0016 + oModelPBasket:GetErrorMessage()[4])
	EndIf
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDInitPBasket
Inicializa a cesta de produtos
@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDInitPBasket()

Local aArea			:= GetArea()		// Guarda area
Local oModel			:= Nil				// Model
Local cCliente 		:= ""				// Cliente
Local cLojaCli 		:= ""				// Loja
Local cTipoCli		:= ""				// Tipo de cliente
Local cVendLoja 		:= ""				// Vendedor

If ValType(oModelPBasket) == "U" .OR. !oModelPBasket:IsActive()	
	oModel := FwLoadModel("STDProductBasket")	
EndIf

//Confere se o Numero do Orcamento ja nao esta utilizado
STDPConfL1(STDGPBasket('SL1','L1_NUM'))	

// Abertura do Cupom - Cria o SL1 
// Se o cliente estiver vazio, coloca o cliente padrão

nTamSXG := TamSXG("001")[1] // Grupo de Cliente
cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)

nTamSXG := TamSXG("002")[1] // Grupo de Loja	
cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)

nTamSXG := Len(SA3->A3_COD)
cVendLoja := Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSXG),nTamSXG) 

DbSelectArea("SA1")
SA1->(DbSetOrder())
If DbSeek(xFilial("SA1")+cCliente+cLojaCli)
	cTipoCli := SA1->A1_TIPO
EndIf

/*
	Inicializa o model do cliente com as informacoes do cliente padrao.
*/
STWCustomerSelection(cCliente+cLojaCli)

STDSPBasket("SL1","L1_FILIAL"		,xFilial("SL1"))
STDSPBasket("SL1","L1_CLIENTE"		,cCliente)
STDSPBasket("SL1","L1_LOJA"			,cLojaCli)
STDSPBasket("SL1","L1_NOMCLI"		,Posicione("SA1",1,xFilial("SA1")+cCliente+cLojaCli,"A1_NOME"))
STDSPBasket("SL1","L1_TIPOCLI"		,cTipoCli)
STDSPBasket("SL1","L1_VEND"			,cVendLoja)
STDSPBasket("SL1","L1_COMIS"		,STDGComission( cVendLoja ))
STDSPBasket("SL1","L1_SERIE"		,STFGetStation("SERIE")) 
STDSPBasket("SL1","L1_PDV"     		,STFGetStation("PDV"))
STDSPBasket("SL1","L1_OPERADO"		,xNumCaixa())

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTratErro
Funcao de tratamento de erro.
@param 		oErro		- Objeto de tratamento de erro
@param 		cError		- Mensagem de erro. Como este parametro é passado por referencia, ele será retornado.
@author  Varejo
@version P11.8
@since   16/10/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBTratErro( oErro , cError )

Default oErro		:= Nil
Default cError		:= ""

IF oErro:gencode > 0  .AND. Empty(cError)	
	cError := oErro:DESCRIPTION + oErro:ErrorStack		
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDGModelID
Funcao que recebe um Alias e retorna o ID do model que representa 
esse alias. Apenas os alias SL1, SL2 e SL4 sao validos.
@param cAlias		- Alias que tera o ID do model retornado. Apenas os alias SL1, SL2 e SL4 sao validos.
@author  Varejo
@version P11.8
@since   16/10/2012
@return		cModelID	- ID do model desejado.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGModelID(cAlias)

Local cModelID := ""			// ID do model

Default cAlias		:= ""

If cAlias == "SL1"
	cModelID := "SL1MASTER"
ElseIf cAlias == "SL2"
	cModelID := "SL2DETAIL"
ElseIf cAlias == "SL4"
	cModelID := "SL4DETAIL"
ElseIf cAlias == "MGC"
	cModelID := "MGCBRINDE"     
EndIf

Return cModelID


//-------------------------------------------------------------------
/*/{Protheus.doc} STDPBLength
Funcao que recebe um Alias e retorna o numero de linhas do grid do alias informado. 
Apenas os alias SL2,SL4 e MGC sao validos.
@param cAlias	- Alias que tera o tamanho do grid retornado. Apenas os alias SL2 e SL4 sao validos.
@author  Varejo
@version P11.8
@since   16/10/2012
@return  nRet	- Numero de linhas do grid. Retorna 0 se o grid estiver vazio.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDPBLength(cAliasTab)

Local cModelID 		:= STDGModelID(cAliasTab)		// ID do Model
Local cField	 		:= ""							// Nome campo
Local nRet		 	:= 0							// Retorno

Default cAliasTab		:= ""

If cAliasTab == "SL2" .OR. cAliasTab == "SL4" .OR. cAliasTab == "MGC"
	If cAliasTab == "SL2"
		cField := "L2_NUM"
	Else
		If cAliasTab == "SL4"
			cField := "L4_NUM"
		Else
		   cField := "MGC_NUM"
		Endif	
	EndIf
	If oModelPBasket == Nil
		oModelPBasket := FWLoadModel("STDProductBasket")
	EnDIf
	
	// Caso o grid nao esteja vazio, adiciona a linha
	If oModelPBasket:GetModel(cModelID):Length() == 1 .AND. Empty(STDGPBasket(cAliasTab,cField,1))
		nRet := 0
	Else
		nRet := oModelPBasket:GetModel(cModelID):Length()
	EndIf
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDGetProperty
Funcao que retorna estrutura do campo
@param 		cField		- Nome do campo
@author  Varejo
@version P11.8
@since   16/10/2012
@return		aField 	- Retorna campos do model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGetProperty( cField )

Local oModel			:= Nil				// Model
Local aField			:= {}				// Array de campos
Local aStruct			:= {}				// Strutura
Local nPosition		:= 0				// Numero Posicao

Default cField		:= ""

If oModelPBasket == Nil
	oModelPBasket := STDGPBModel()
EndIf

If 	!Empty(cField)                                                           
	
	Do Case  	
		Case SubStr( cField , 1 , 2 ) == "L1"
		
			oModel		:= oModelPBasket:GetModel("SL1MASTER")
			
		Case SubStr( cField , 1 , 2 ) == "L2"
		
			oModel		:= oModelPBasket:GetModel("SL2DETAIL")
			
		Case SubStr( cField , 1 , 2 ) == "L4"                 
		
			oModel		:= oModelPBasket:GetModel("SL4DETAIL")			
		Case SubStr( cField , 1 , 2 ) == "GC"                 
			If AliasInDic("MGC")
				oModel		:= oModelPBasket:GetModel("MGCBRINDE")
			EndIf				
	EndCase
	
	If oModel <> Nil
	
		aStruct		:= oModel:GetStruct():aFields
		nPosition	:= aScan(aStruct,{|x| x[3] == cField } )
		If nPosition > 0
			aField		:= aStruct[nPosition]
		EndIf
		
	EndIf
	
EndIf	

Return aField

//-------------------------------------------------------------------
/*{Protheus.doc} STDPBIsDeleted
Funcao que retorna estrutura do campo

@param 		cField		- Nome do campo
@author  Varejo
@version P11.8
@since   16/10/2012
@return		aField 	- Retorna campos do model
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDPBIsDeleted( cAliasTable, nLine )
Local lRet        := .F.
Local aSaveLines  := FwSaveRows()
Local oModelTable := Nil

DEFAULT cAliasTable := ""
DEFAULT nLine := 0

If cAliasTable == "SL2" .OR. cAliasTable == "SL4"
	If STDPBLength( cAliasTable ) >= nLine
		oModelTable := oModelPBasket:GetModel( STDGModelID(cAliasTable) )
		oModelTable:GoLine( nLine )
		lRet := oModelTable:IsDeleted()
	Else
		lRet := .T.
	EndIf
EndIf

FwRestRows( aSaveLines )

// Limpa o vetor para melhor gerenciamento de memoria (Desaloca Memória)
aSize( aSaveLines,0 )
aSaveLines := Nil

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDLoadImg
Retorna o codigo da imagem do produto contido no repositorio de imagens

@param 		cField		- Nome do campo
@author  Varejo
@version P11.8
@since   16/10/2012
@return		aField 	- Retorna campos do model
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDLoadImg( cCodProd )
Local aArea := GetArea()
Local cRet  := ""

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
If DbSeek(xFilial("SB1")+cCodProd)
	cRet := SB1->B1_BITMAP
EndIf

If Empty(cRet)
	cRet := "SEMFOTO"
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDPConfL1
Confere se o numero gerado na inicializacao da cesta esta correto , pois pode haver casos do XE/XF ficar corrompidos e
retornavam a mesma numeracao , alterando o orçamento.
@param 		cNumOrc		- Numero do Orcamento
@author  Leandro
@version P11.8
@since   15/07/2016
*/
//-------------------------------------------------------------------
Function STDPConfL1( cNumOrc )

Local cMay			:= ""			// Conteudo da filial e orcamento para nao haver duplicacao
Local nTent 		:= 0			// Tentativas para gravacao do SL1 com a numeracao do orcamento
Local lRet			:= .T.
Local lUpdate		:= .F.
Local aSL1Area	:= {}

Default cNumOrc		:= ""

If !Empty(cNumOrc)
	aSL1Area := SL1->(GetArea())

	cMay := Alltrim(xFilial("SL1")) + cNumOrc
	FreeUsedCode()
	SL1->( DbSetOrder( 1 ) )

	// Verifica se o numero da cesta nao ja esta sendo utilizado
	While SL1->(DbSeek(xFilial("SL1")+cNumOrc)) .OR. !MayIUseCode( cMay )
		SL1->(MsUnlock())		// Caso encontrou algum que ja existe
		SL1->(ConfirmSX8())		// Confirma e libera
		If ++nTent > 20
			LjGrvLog( cNumOrc, "Impossivel gerar num seq de orc correto(STDPConfL1)" )
			lRet := .F.
			Exit
		EndIf
		LjGrvLog( cNumOrc, "Ajustou o numero do orcamento L1_NUM" )
		cNumOrc := CriaVar( "L1_NUM" )
		FreeUsedCode()
		cMay 	:= Alltrim(xFilial("SL1"))+cNumOrc
		lUpdate	:= .T.
	End

	If lRet .AND. lUpdate 
		STDSPBasket("SL1","L1_NUM"		,cNumOrc)
	EndIf
	RestArea(aSL1Area)
EndIf

Return Nil