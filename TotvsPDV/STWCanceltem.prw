#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#include "TOTVS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "STWCANCELTEM.CH"

//-------------------------------------------------------------------
/* {Protheus.doc} STWChkCancel
Avalia qual a forma de cancelamento.
Sendo possivel excluir qualquer item ou apenas o ultimo registrado.
@author  Varejo
@version P11.8
@since   01/06/2012
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWChkCancel()

Local lRet	:= .F.
Local nOpc 	:= STBCnAllItem()		// Opcao de cancelamento

If nOpc == 1 
	//Quando apenas o ultimo item puder ser cancelado 
	//e ele ja estiver cancelado, retorna a funcao de registro de item.
	STFMessage(ProcName(),"STOP","O último item já está cancelado!")
	STFShowMessage(ProcName())	
ElseIf nOpc == 2
	//Cancela o ultimo item
	lRet := STIExchangePanel( { || STILastItCancel() } )
	STIChangeCssBtn('oBtnCancItem')
ElseIf nOpc == 3
	//Cancela item por parametro
	lRet := STIExchangePanel( { || STIPanItCancel() } )
	STIChangeCssBtn('oBtnCancItem')
EndIf

If lRet
	STIRegItemInterface()
EndIf

STIGridCupRefresh()

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} STWItemCancel
Realiza o cancelamento do Item

@param   cGetProd		    Produto
@param   oReasons			Objeto motivo venda perdida
@author  Varejo
@version P11.8
@since   01/06/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWItemCancel(cGetProd , oReasons,lCancel)

Local nItem				:= 0
Local oModelCesta 		:= STDGPBModel()							// Model da cesta
Local lCancelado  		:= .F.										// Item Cancelado?
Local aProfile    		:= STFProFile(7)							// Array de permissoes de cancelamento
Local nX				:= 1										// Variavel de controle
Local aItensCan			:= {}										// Armazena o(s) item(s) a sere(m) cancelado(s) 
Local lMotVen			:= SuperGetMV( "MV_LJMVPE", Nil, .F. ) 		// Motivo de venda perdida
Local lIsSelect			:= .T.										// Variavel que controla se o motivo para cancelamento esta selecionado
Local lStCancIt			:= ExistBlock("STCancIt") //Verifica se existe o ponto de entrada StCancIt no cancelamento do item
Local lRetPe			:= .T. //Retorno do ponto de entrada STCancIt

DEFAULT cGetProd := ""
DEFAULT oReasons := Nil
DEFAULT lCancel	 := .F.									// indica que eh cancelamento para a pesquisa de produto, assim a pesquisa de produto nao pedira peso para produto balanca  

If lMotVen .AND. ValType(oReasons) == "O" .AND. oReasons:NAT == 0 
	lIsSelect := .F.
	STFMessage(ProcName(),STR0006)  //"É necessário selecionar o motivo de cancelamento."
	STFShowMessage(ProcName())	
EndIf 

If lIsSelect
	If !Empty(cGetProd)
		nItem := STBCnFindItem( cGetProd , lCancel)
		If nItem > 0
			oModelCesta := oModelCesta:GetModel("SL2DETAIL")
			
			//Verifico se existe itens ralacionado ao item que sera cancelado 
			If SL2->(ColumnPos("L2_IDITREL")) > 0 .AND. !Empty(STDGPBasket("SL2","L2_IDITREL",nItem))
				If MsgYesNo(STR0005)//"O Item selecionado para o cancelamento possui itens relacionados a ele, caso opte pelo cancelamento todos os itens relacionados serão cancelados."
					aItensCan := STWListaRel(nItem)
				Else
					aItensCan := {}
				EndIf
			Else 
				AADD( aItensCan, nItem )
			EndIf

			If !Empty(aItensCan)
				//Verifica Permissao para Cancelamento Item
				If aProfile[1]

					If lStCancIt
						LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Antes de executar o ponto de entrada STCancIt")
						lRetPe := ExecBlock("STCancIt",.F.,.F.,{oModelCesta,aItensCan})
						LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Depois de executar o ponto de entrada STCancIt")
						If !(ValType(lRetPe) == "L")
							LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "O ponto de entrada STCancIt nao retornou um valor logico e por conta disso o item nao sera cancelado")
							lRetPe := .F.
						EndIf
					EndIf

					If lRetPe
						For nX := 1 to Len(aItensCan)
							nItem := aItensCan[nX]
							If nItem > 0
								
								lCancelado := STWCancelProcess(nItem , oReasons , aProfile[2])   // aProfile[2] = usuario supervisor
								
								If lCancelado
									LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Número do item a ser cancelado", nItem ) //Grava Log =====================================================================
									LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "ID usuário superior", aProfile[2] ) //Grava Log ===================================================================== 
								EndIf			
								
								If lCancelado .AND. oModelCesta:GetValue( "L2_BONIFICADOR", nItem )
									STWCancelProcess(nItem+1 , oReasons)
								EndIf				
						
							Else
								STFMessage("STCancelItem","STOP",STR0001) //"Item não registrado na venda"
								STFShowMessage("STCancelItem")
							EndIf
							
							If lCancelado
								STFMessage("STCancelItem","STOP",STR0002) //"Item cancelado com sucesso"
								STFShowMessage("STCancelItem")
							Else
								STFMessage("STCancelItem","STOP",STR0003) //"Não foi possível cancelar o item"
								STFShowMessage("STCancelItem")
							EndIf
						Next
					Else
						LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Item nao foi cancelado devido ao retorno do ponto de entrada STCancIt")
					EndIf
				Else
					//Se nao tem permissao para cancelar o item add mensagem 
					STFMessage("STCancelItem","STOP",STR0004) //Usuario sem permissão para cancelar itens"
				EndIf
				STFShowMessage("STCancelItem")
			EndIf
		Else
			STFMessage("STCancelItem","STOP",STR0001) //"Item não registrado na venda"
			STFShowMessage("STCancelItem")
		Endif	
	EndIf				
	
	STIGridCupRefresh()
Endif
				
Return lCancelado


//-------------------------------------------------------------------
/*{Protheus.doc} STWLastCancel
Realiza o cancelamento do ultimo item registrado apenas, conforme a configuracao da impressora.

@param   nItem				Numero do item na venda
@param   cItemCode			Codigo do Item
@author  Varejo
@version P11.8
@since   01/06/2012
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STWLastCancel(lImportSale)

Local oModelCesta 		:= STDGPBModel()		// Model da cesta
Local nItem       		:= 0					// Numero do item
Local lCancelado  		:= .F.					// Item Foi cancelado

Default lImportSale		:= .F.					// Controla se houve importação de orçamento

oModelCesta := oModelCesta:GetModel("SL2DETAIL")
oModelCesta:GoLine(oModelCesta:Length())

If !oModelCesta:IsDeleted()
	nItem := Val(oModelCesta:GetValue("L2_ITEM"))
	
	If !Empty(nItem)	
		
		lCancelado := STWCancelProcess(nItem,,,lImportSale)	
		STIGridCupRefresh()
		
		If lCancelado
			STFMessage("STCancelItem","STOP",STR0002) //"Item cancelado com sucesso"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
		Else
			STFMessage("STCancelItem","STOP",STR0003) //"Não foi possível cancelar o item"
		EndIf		
	EndIf
EndIf

STFShowMessage("STCancelItem")	

Return lCancelado


//-------------------------------------------------------------------
/*{Protheus.doc} STWCancelProcess
Processo de cancelamento, realizado tanto quando e permitido cancelar qualquer item 
quanto quando e permitido cancelar apenas o ultimo.

@param   nItem					Numero do item na venda
@param   oReasons					Objeto Motivo de venda perdida
@author  Varejo
@version P11.8
@since   01/06/2012
@return  lRet - Retorna se cancelou item
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STWCancelProcess( nItem , oReasons , cSuper, lImportSale)

Local lRet       	:= .T.								// Continua rotina?
Local cSupervisor 	:= ""			 					// Supervisor
Local aTPLCODB2		:= {}
Local aSTBDroVar	:= {}
Local aRet		  	:= {}								// Array retorno
Local aAux			:= {}
Local oModelMaster	:= STDGPBModel()
Local oModelCesta 	:= STDGPBModel()
Local lFinServ	   	:= SuperGetMv("MV_LJCSF",,.F.) 		// Define se habilita o controle de servicos financeiros
Local lServFin		:= .F.
Local lEmitNfce		:= LjEmitNFCe()						//Sinaliza se utiliza NFC-e
Local lItFiscNFi 	:= .F.								//Verifica se existe o item fiscal e não fiscal para cancelamento no ECF (FieldPos)
Local aEstrItNFisc  := {}								//Estrutura do Contador do Item Fiscal (FieldPos)
Local aEstrItSF	  	:= {}								//Estrutura do Contador Servico Financeiro (FieldPos)
Local uItem			:= "" 								//Item a ser cancelado
Local cItemAtu		:= ""								//Item do produto deletado
Local nI			:= 0								//Contador
Local cPrdCobe		:= ""								//Produto Cobertura
Local cItemCob		:= ""								//Item do Produto Cobertura
Local lLjLsPre		:= SuperGetMv("MV_LJLSPRE",, .F.) 	//Funcionalidade de Lista de Presente Ativa
Local lLisPres		:= .F.
Local lSaveOrc		:= IIF( ValType(STFGetCfg( "lSaveOrc" , .F. )) == "L" , STFGetCfg( "lSaveOrc" , .F. )  , .F. )   //Salva venda como orcamento
Local lItemFiscal   := .T. 								//Valida se item fiscal
Local lIsTPLDro		:= (ExistFunc("LjIsDro") .And. LjIsDro())
Local lL2_ITPBM		:= .F.

Default nItem		:=	0
Default oReasons	:=	Nil
Default cSuper		:= ""
Default lImportSale := .F.					//Controla se houve importação de orçamento.

If !(lImportSale .AND. STBIsPAF())			//Se for orçamento importado e ambiente PAF, não pede a autorização novamente.
	If Empty(cSuper)
		cSupervisor := STFProFile(7)[2] 	// Supervisor, aqui chamara a tela de supervisor
	Else
		cSupervisor := cSuper 				// Supervisor vindo da rotina STWItemCancel.Protecao para nao chamar a tela supervisor duas vezes
	EndIf		
Endif

oModelMaster := oModelMaster:GetModel("SL1MASTER")

oModelCesta := oModelCesta:GetModel("SL2DETAIL")
oModelCesta:GoLine(nItem)

/*
Valida na regra de negocio se pode realizar o cancelamento
*/
If lRet	
	lRet := STBValCnItem( nItem, oModelCesta )
EndIf

//Valida item fiscal
If lRet .AND.	Empty( oModelCesta:GetValue("L2_ITFISC") )
	lItemFiscal := .F.
EndIf

/* Verifica se produto Servico Financeiro avulso */	
If lFinServ
	If STBIsFinService(oModelCesta:GetValue("L2_PRODUTO"))
		lServFin := .T.
	EndIf 
EndIf

/* Verifica se produto é da lista de presente */	
If lLjLsPre
	If !Empty(oModelCesta:GetValue("L2_CODLPRE")) .AND. AllTrim(oModelCesta:GetValue("L2_ENTREGA")) == "3"
		lLisPres := .T.
		
		/* Subtrai valor nao fiscal no totalizador */
		STBSubNotFiscal( oModelCesta:GetValue("L2_VRUNIT") )		
	EndIf
	
EndIf

If !lItemFiscal .AND. !lFinServ .AND. !lLisPres .AND. ExistFunc("STBSubNotFiscal") //Servico financeira e lista d epresente ja retira de outra forma
	// Subtrai valor nao fiscal no totalizador
	STBSubNotFiscal(oModelCesta:GetValue("L2_VRUNIT") )		
EndIf

/*
Valida se e possivel cancelar todos ou so o ultimo item
*/	   
If lRet .AND. !lServFin .AND. !lEmitNFCE .AND. !lLisPres .AND. !lSaveOrc .AND. lItemFiscal
	
	//verifica se existe o item fiscal e não fiscal para cancelamento de item no ECF
	aEstrItNFisc := STDGetProperty( "L2_ITFISC" )
	
	lItFiscNFi	:= Len(aEstrItNFisc) > 0	
	
	//verifica se existe o item Servico Financeiro para cancelamento de item no ECF
	aEstrItSF := STDGetProperty( "L2_ITEMREA" )

	STCIRetUit(oModelCesta,lFinServ,lItFiscNFi,aEstrItSF,@uItem)
	
	// Inicia Evento 	
	aRet := 	STFFireEvent(	ProcName(0)												,;		// Nome do processo
								"STCancelItem"											,;		// Nome do evento
								{AllTrim(Str(uItem)) 			,;		// 01 - Numero do Item
								AllTrim(oModelCesta:GetValue("L2_PRODUTO")) 			,; 		// 02 - Codigo do Item
								AllTrim(oModelCesta:GetValue("L2_DESCRI"))			,;		// 03 - Descricao do Item
								StrZero(oModelCesta:GetValue("L2_QUANT"),8,3)		,;		// 04 - Quantidade do Item	
				 				AllTrim(Str(oModelCesta:GetValue("L2_VRUNIT")))		,;		// 05 - Valor do Item
				 				AllTrim(Str(oModelCesta:GetValue("L2_VALDESC"))) 	,;		// 06 - Valor Desconto
				 				AllTrim(oModelCesta:GetValue("L2_SITTRIB"))			,;		// 07 - Situacao tributaria do Item
				 				AllTrim(cSupervisor)										,;		// 08 - Supervisor
				 				Nil 														}) 		
			 												 											
	lRet := ValType(aRet[1]) == "U" .OR. (ValType(aRet[1]) == "N" .AND. 	aRet[1] == 0)
		
EndIf	  

/*/
	Exclui o item nas funcoes fiscais e dependentes
/*/
If lRet

	//	Limpa Motivo de desconto caso exista	
	STDDelReason( nItem )
	
	//STFLogCanc( "cSupervisor" , nItem ) // TODO: Log nao subira na 1 fase
			
	oModelCesta:LoadValue("L2_SITUA","05")
	
	aAux := {"","",""}
	aAux[3] := AllTrim(oModelCesta:GetValue("L2_CODBAR"))
	If lIsTPLDro /* Tratamento para o Template de Drogarias*/
		If ExistTemplate("FRTCODB2")
		
			STCIRetUit(oModelCesta,lFinServ,lItFiscNFi,aEstrItSF,@uItem)
			aTPLCODB2 := {nItem, AllTrim(oModelCesta:GetValue("L2_PRODUTO")), AllTrim(oModelCesta:GetValue("L2_CODBAR")), "",;
							"", "", "", "", "", "", .F.,/*Valor de Solidário*/}
			aSTBDroVar := STBDroVars(.F.)
			Aadd(aTPLCODB2, aSTBDroVar[2]) 	//Produto TPL
			Aadd(aTPLCODB2, aSTBDroVar[1]) 	//Cliente TPL
			Aadd(aTPLCODB2, oModelCesta) 	//Model para poder acessar e ler o conteudo de SL2
			Aadd(aTPLCODB2, nItem) 			//Item do model 
			aTPLCODB2 := ExecTemplate("FRTCODB2",.F.,.F.,{aTPLCODB2,aSTBDroVar[2],aSTBDroVar[1]})
			
			aAux[3] := PadR(aTPLCODB2[3],TamSX3("B1_CODBAR")[1])

			If ValType( aTPLCODB2[13] ) == "A" //uProdTPL
				aAux[2] := aClone(aTPLCODB2[13])
			Else
				aAux[2] := aTPLCODB2[13]
			Endif

			If ValType( aTPLCODB2[14] ) == "A" //uCliTPL
				aAux[1]  := aClone(aTPLCODB2[14])
			Else
				aAux[1]  := aTPLCODB2[14]
			Endif
			STBDroVars(.F.,.T.,aAux[1],aAux[2])
		EndIf

		//JULIOOOOOO - inserir uma validação como no front, que pergunta se o produto
		//é de PBM mesm juntamente se esta numa venda PBM
		/* Tratamento para a venda PBM*/
		lL2_ITPBM := oModelCesta:HasField("L2_ITPBM")
		If ExistFunc("STBIsVnPBM") .And. STBIsVnPBM() .And. lL2_ITPBM .And. oModelCesta:GetValue("L2_ITPBM")
			STCnProPBM(aAux[3],oModelCesta:GetValue("L2_QUANT"))
		EndIf

		If ExistTemplate("FRTCancela")
			aSTBDroVar := STBDroVars(.F.)
			aSTBDroVar[2] := ExecTemplate("FRTCancela",.F.,.F.,{1,cSupervisor,nItem,aSTBDroVar[2]})
			STBDroVars(.F.,.T.,aSTBDroVar[1],aSTBDroVar[2])
		EndIf
	EndIf	

	oModelCesta:LoadValue("L2_VENDIDO","N")
	oModelCesta:DeleteLine(Nil ,.T.)
	
	// Deleta Item das funcoes fiscais
	STBTaxDel(	nItem	, .T. )
						
	// Chamada Motivo de Venda Perdida
	STWRsnLtSl( nItem , oReasons )
	
	// Salva a venda (tabelas SL1 e SL2)
	STDSaveSale(nItem,.T.)
	
	// Se um item for cancelado, o Caixa poderá alterar as parcelas, independentemente da permissão, já que o valor da venda foi alterado
	If ExistFunc("STISetPayRO")
		STISetPayRO(-1)	//permite editar os pagamentos
	EndIf	
	
	//Gera SLX
	STDLogCanc(.T., nItem, cSuper, lImportSale)
EndIf 

/*/
	Marca item como deletado em Servicos Financeiros
/*/
If lFinServ .AND. lRet			
	/* Verifica se Cliente Padrao */	
	If STWValidService( 3,,, oModelMaster:GetValue("L1_CLIENTE"), oModelMaster:GetValue("L1_LOJA") ) 
		/* Se item Servico Financeiro atualiza totalizador */
		If lServFin
			/* Subtrai valor nao fiscal no totalizador */
			STBSubNotFiscal( oModelCesta:GetValue("L2_VRUNIT") )		
						
			/* Marca itens Servico Financeiro como deletados */
			STBDelServFin(oModelCesta:GetValue("L2_PRODUTO"), nItem, lServFin)
		Else
			/* Deleta Servicos Financeiros vinculados se existirem*/
			cItemAtu := oModelCesta:GetValue("L2_ITEM")
			cPrdCobe := oModelCesta:GetValue("L2_PRODUTO")
						
			For nI := 1 To oModelCesta:Length()
				If nI <> nItem
					oModelCesta:GoLine(nI)
										
					cItemCob := Posicione("SL2", 1, xFilial("SL2") + oModelCesta:GetValue("L2_NUM") + oModelCesta:GetValue("L2_ITEM") + oModelCesta:GetValue("L2_PRODUTO"), "L2_ITEMCOB")  						
					
					If cItemCob == cItemAtu .And. !oModelCesta:IsDeleted()
						//	Limpa Motivo de desconto caso exista	
						STDDelReason( nI )												
								
						oModelCesta:LoadValue("L2_SITUA","05")
						oModelCesta:LoadValue("L2_VENDIDO","N")
						oModelCesta:DeleteLine(Nil ,.T.)
						
						// Deleta Item das funcoes fiscais
						STBTaxDel(	nI	, .T. )
											
						// Chamada Motivo de Venda Perdida
						STWRsnLtSl( nI , oReasons )
						
						// Salva a venda (tabelas SL1 e SL2)
						STDSaveSale(nI,.T.)
						
						/* Subtrai valor nao fiscal no totalizador */
						STBSubNotFiscal( oModelCesta:GetValue("L2_VRUNIT") )	
						
						/* Marca itens Servico Financeiro como deletados */
						STBDelServFin(cPrdCobe, nItem, lServFin)					
					EndIf
				EndIf
			Next nI
		
			oModelCesta:GoLine(nItem)
		EndIf						
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} STWListaRel
Esta função retorna os itens relacionados ao produto que será cancelado, exemplo o KIT, todos os itens do kit são relacionados entre si.

Exemplo pratico
Ex.: Uma venda de um kit que possui mais de um produto, e por vender um kit fechado aplico um desconto sobre esse kit.
Os itens da venda do Kit são relacionados através do campo L2_IDITREL, com isso caso o operador tente cancelar apenas um dos itens, os demais relacionados ao Kit também serão cancelados.

@param   nItem					Numero do item na venda
@author  Lucas Novais (lnovais)
@version P12.1.17
@since   27/12/2017
@return  aItensRel - Retorna um array com os itens relacionados ao produto que deseja cancelar
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function STWListaRel(nItem)

local nX 			:= 1				// Variavel de controle para For
local nItRelIni 	:= 0				// Variavel que armazena o primeiro item relacionado.
Local aItensRel		:= {}				// Array que armazena os itens que serão cancelados/retornados 
Local oModelCesta 	:= STDGPBModel()	// Model da cesta

Default  nItem := 0

oModelCesta := oModelCesta:GetModel("SL2DETAIL")

//Localizo o primeiro item do conjunto relacionado
For nX := nItem to 1 Step -1
	If STDGPBasket("SL2","L2_IDITREL",nX) == STDGPBasket("SL2","L2_IDITREL",nItem)
		nItRelIni := Val(STDGPBasket("SL2","L2_ITEM",nX))
	Else
		Exit
	EndIf
Next nX

//A partir do primeiro salvos os próximos itens relacionados
For nX := nItRelIni to oModelCesta:Length()
	If STDGPBasket("SL2","L2_IDITREL",nX) == STDGPBasket("SL2","L2_IDITREL",nItem)
		AADD( aItensRel, nX )
	Else
		Exit
	EndIf
Next nX 

Return aItensRel


/*/{Protheus.doc} STCIRetUit
	Retorna o item da venda
	@type  Function
	@author Julio.Nery
	@since 26/02/2021
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
 Static Function STCIRetUit(oModelCesta,lFinServ,lItFiscNFi,aEstrItSF,uItem)

 //Compatibilizado para cancelar item maior que 99
If lFinServ .And. Len(aEstrItSF) > 0
	uItem := STBPegaIT(oModelCesta:GetValue("L2_ITEMREA"))
ElseIf !lItFiscNFi   		    			 		   			   		
	uItem := STBPegaIT(oModelCesta:GetValue("L2_ITEM"))	   		
Else
	uItem := STBPegaIT(oModelCesta:GetValue("L2_ITFISC"))
EndIf

If ValType(uItem) <> "N" .OR. uItem == 0	
	uItem := Val(oModelCesta:GetValue("L2_ITEM"))
EndIf

Return uItem