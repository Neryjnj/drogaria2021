#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STWITEMREGISTRY.CH"
#INCLUDE "STBPBM.CH"

Static lReceiptIsOpen	:= .F.		// Define se foi realizada abertura de cupom fiscal

Static cImpCodBar 	:= SuperGetMv("MV_CODBAR",,"N") 			// Indica se imprime codigo de barras no cupom ao inves do codigo do produto
Static lStValPro	:= ExistBlock("STVALPRO")
Static lLj7013		:= ExistBlock("LJ7013")				    	// Permite customizar informacoes na impressao do comprovante
Static lSumItFisc	:= ExistFunc("STBSumItem")					// Função de Soma do Contador
Static lMobile		:= IIF(STFGetCfg("lMobile", .F.) == Nil,.F.,STFGetCfg("lMobile", .F.))	//Valida versao mobile
Static lFinServ		:= SuperGetMv("MV_LJCSF",,.F.)				// Define se habilita o controle de servicos financeiros
Static lItemDel		:= .F.										// Define o controle de item deletado da MatxFis
Static lMVLJPRDSV   := SuperGetMv("MV_LJPRDSV",.F.,.F.)			// Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas (RPS)
Static cMvLjTGar	:= SuperGetMV("MV_LJTPGAR",,"GE")  			// Define se é tipo GE 
Static lStQuant  	:= ExistBlock("STQUANT")
Static lFuncGarEst 	:= ExistFunc("STBIsGarEst") .AND. ExistFunc("STDGEProdVin") .AND. ExistFunc("STWItemGarEst")
Static lFunGiftCar 	:= ExistFunc("STBIsGiftCard")
Static lFLImpItem 	:= ExistFunc("STBLImpItem")
Static l950SP10OK 	:= ExistFunc("Lj950SP10OK")

//-------------------------------------------------------------------
/*/ {Protheus.doc} STWItemReg
Function Registra Item.

@param   nItemLine		Linha do Item na Venda
@param   cItemCode		Codigo do Item
@param   cCliCode		Codigo do Cliente
@param   cCliLoja		Codigo da loja do Cliente
@param   nMoeda			Moeda Corrente
@param   nDiscount		Desconto no Produto
@param   cTypeDesc		Tipo de Desconto
@param   lAddItem		Indica se o item a ser registrado eh um item adicional
@param   cItemTES		TES que sera usado no calculo do imposto do Item
@param   cCliType		Tipo do Cliente
@param   lItemFiscal	Indica se o Item eh do tipo fiscal. Registra no cupom fiscal?
@param   nPrice			Preço do Item
@param   cTypeItem		Temos 2 tipos: "IMP" - Indica que o item vem de importação de orçamento;
											 "KIT" - Indica que o item eh um dos filhos de um kit
@param   lInfoCNPJ		Informa se o CPF/CNPJ deve ser informado na nota fiscal											 
@param   lRecovery		Informa se esta sendo chamado pela recuperacao de venda.	
@param   nSecItem			Intervalo entre itens.
@param   lServFinal		Indica finalização dos serviços na Venda.
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWItemReg(	nItemLine		,	cItemCode		, cCliCode		,	cCliLoja	,;
						nMoeda      	,	nDiscount   	, cTypeDesc 	,	lAddItem	,;
						cItemTES 		,	cCliType		, lItemFiscal	,	nPrice		,;
						cTypeItem		,   lInfoCNPJ		, lRecovery		,	nSecItem	,;
						lServFinal		,   lProdBonif		, lListProd		,	cCodList	,;
						cCodListIt		,	cCodMens		, cEntrega		,	cCodItemGar ,;
						cIdItRel		,	cValePre		, cCodProdKit )


Local lKitMaster		:= .F.														// Utiliza kit master
Local aInfoItem			:= {}														// Array de retorno da busca de item
Local lRet				:= .T.														// Retorno
Local cCodIniIT			:= cItemCode												// Armazena valor original do Codigo do Item Recebido/Digitado
Local cCodeForPrint		:=	""														// Armazena Codigo que sera usado para impressao do Item
Local nItemTotal		:= 0														// Armazena Preço * Quantidade
Local lRecShopCard		:= .F.   													// Indica que é um produto do tipo Recarga de Shop Card
Local lItemServFin		:= .F.														// Define ao serviço financeiro item NAO fiscal caso for avulso
Local aAlqLeiTr			:= {0,0,0,0,}												// array utilizado para pegar as aliquotas das lei dos impostos
Local oTotal	   		:= STFGetTot() 												// Totalizador
Local cMsgErro			:= STR0003													// "Nao foi possivel a abertura do Cupom Fiscal"
Local nVTotAfter		:= 0														// Valor total antes de passar pela rotina de calculo de imposto
Local cDscPrdPAF		:= ""														// Descrição do produto segundo legislação do PAF CONVÊNIO ICMS 25, DE 8 DE ABRIL DE 2016 
Local cITcEst			:= ""														// cEst retornado da MatxFis
Local cPosIpi			:= ""														// código NCM do produto
Local cL1Num			:= ""														// Numero do orcamento da venda em lancamento
Local aSTQuant			:= {}														// Array retorno do ponto de entrada STQUANT
Local nTamArray			:= 0
Local lItemGarEst		:= .F.														// Define a Garantia Estendida item NAO fiscal caso for avulso
Local cProdVend			:= ""														// Produto que será vinculado à Garantia Estendida
Local nPrProd			:= 0														// Preço do produto que será impresso no Cupom Gerencial de Garantia Estendida
Local nDroPrProd		:= 0														//Preço do produto segundo as verificações do TPL DRO
Local cSerieProd		:= ""														// Série do produto que será impresso no Cupom Gerencial de Garantia Estendida
Local aRetLj7013		:= {}														// Retorno do PE Lj7013 para ser adicionado a descricao do produto
Local lEmitNFCe			:= STBGetNFCE()												//valida se é NFC-e ou não
Local lUseSat			:= STFGetCfg("lUseSAT", .F.) 								//Utiliza SAT
Local cQuant 			:= ""
Local cVrUnit 			:= ""
Local cDesconto			:= ""
Local cSitTrib			:= ""
Local cVlrItem			:= ""
Local aAux 				:= {}
Local aDadoVLink		:= {}
Local aDroVLPVal		:= {}
Local aTPLFRTIT			:= {}
Local aTPLCODB2			:= {}
Local aTPLCODB3			:= {}
Local lItemPbm			:= .F.
Local lTPLDrogaria		:= ExistFunc("LjIsDro") .And. LjIsDro()
Local lPrioPBM			:= SuperGetMV("MV_PRIOPBM" , .F., .T.) 	//Priorizacao da venda por PBM
			
Default nItemLine 		:= 0				   										// Linha do Item na Venda
Default cItemCode 		:= ""														// Codigo do Item
Default cCliCode 		:= ""														// Codigo do Cliente
Default cCliLoja 		:= ""				   										// Codigo da loja do Cliente
Default nMoeda 			:= 0				   										// Moeda Corrente
Default nDiscount		:= 0														// Desconto no Produto
Default cTypeDesc		:= ""														// Tipo de Desconto
Default lAddItem		:= .F.														// Indica se o item a ser registrado eh um item adicional
Default cItemTES		:= ""				   										// TES que sera usado no calculo do imposto do Item
Default cCliType		:= ""														// Tipo do Cliente
Default lItemFiscal		:= .T.														// Indica se o Item eh do tipo fiscal. Registra no cupom fiscal?
Default nPrice			:= 0				   										// Preco do item
Default cTypeItem		:= ""														// IMP - Indica que o item vem de importação de orçamento; KIT - Indica que eh um dos filhos de um kit.
Default lInfoCNPJ		:= .T. 														// Imprime CNPJ no cupom Fiscal?
Default lRecovery		:= .F.														// A tela do POS está sendo apresentada?
Default nSecItem		:= 0														// Intervalo entre itens
Default lServFinal		:= .F.														// Indica finalização dos serviços na Venda.
Default lProdBonif      := .F.                  									// Identificacao se o produto é bonificado
Default lListProd		:= .F.														// Identifica se o item é lista
Default cCodList		:= ""														// Codigo da Lista;
Default cCodListIt		:= ""														// Codigo do Item de Lista
Default cCodMens		:= ""														// Codido da Mensagem
Default cEntrega		:= ""														// Entrega
Default cCodItemGar		:= ""														// Item de Produto com Garantia Vinculada
Default	cIdItRel		:= ""														// Id do item Relacionado
Default	cValePre		:= ""														// Vale Presente, se houver
Default cCodProdKit		:= ""														// Código do kit de produto

//Todo: Implementar na importação do DAV para cancelamento o parãmetro como .f. //PAF: Sera imprementado na segunda fase
LjGrvLog("Registra_Item", "ID_INICIO")

cL1Num	:= "L1_Num:"+STDGPBasket('SL1','L1_NUM')

LjGrvLog(cL1Num,"Inicio - Workflow Registra Item. Codigo do Item:" + cItemCode + " Tipo:"+cTypeItem )

If !lRecovery
	STFMessage("ItemRegistered","STOP",STR0007) //Registrando Item...
	STFShowMessage("ItemRegistered")
EndIf

/*Tratamento VidaLINK*/
If lTPLDrogaria .And. ExistFunc("STGDadosVL")
	aDadoVLink := STGDadosVL()
	If aDadoVLink[3] == 1
		aAux := STWFindItem( aDadoVLink[1][VL_DETALHE, nItemLine, VL_EAN], STBIsPaf(), STBHomolPaf())
		If aAux[ITEM_ENCONTRADO]
			cItemCode := aAux[ITEM_CODIGO]
		EndIf

		cCliCode := aDadoVLink[2][VL_C_CODCL] 
		cCliLoja := aDadoVLink[2][VL_C_LOJA]
		cCliType := STDGPBasket("SL1","L1_TIPOCLI")			
		
		If nItemLine == 1 //Somente quando for o primeiro item que posiciona
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+cCliente+cLojaCli))
				cCliType := SA1->A1_TIPO
			EndIf
			STDSPBasket("SL1","L1_TIPOCLI",cCliType) //Tipo do Cliente na Cesta
			STDSPBasket("SL1","L1_CLIENTE",cCliCode) //Codigo do Cliente na Cesta
			STDSPBasket("SL1","L1_LOJA",cCliLoja)	 //Loja do Cliente na Cesta
		EndIf

		If SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()
			nPrice := aDadoVLink[1][VL_DETALHE, nItemLine, VL_PRECO ]

		ElseIf !(cTypeItem == "IMP")
			nPrice := aDadoVLink[1][VDLNK_DETALHE, nItemLine, VDLNK_PRECO ]
		EndIf

		STBSetQuant( aDadoVLink[1][VL_DETALHE, nItemLine, VL_QUANTID],1 )
	EndIf
EndIf


//verifica se o item Fiscal/Não Fiscal Existe na Cesta
lSumItFisc := lSumItFisc .AND. Len(STDGetProperty( "L2_ITFISC" )) > 0

/*/
	Busca item na base de dados
/*/
aInfoItem	:= STWFindItem( cItemCode , STBIsPaf() , STBHomolPaf())

// Encontrou o item?
If aInfoItem[ITEM_ENCONTRADO] .AND. !aInfoItem[ITEM_BLOQUEADO]    

	LjGrvLog( cL1Num, "Registra Item - Item encontrado" )  //Gera LOG
	
	If lRet
		//Arredondamento
		nItemTotal := STBArred( nPrice * STBGetQuant() )
		
		//|P.E. Para Modificar a Quantidade e Valor Unitario
		If lStQuant
			LjGrvLog(cL1Num,"Antes da Chamada do Ponto de Entrada:STQUANT",{aInfoItem[ITEM_CODIGO], STBGetQuant() } )
			aSTQuant := ExecBlock( "STQUANT",.F.,.F.,{STBGetQuant(),nPrice,nItemTotal,aInfoItem[ITEM_CODIGO] } )
			LjGrvLog(cL1Num,"Apos a Chamada do Ponto de Entrada:STQUANT. Retorno:", aSTQuant )
			
			If ValType(aSTQuant) == "A" .AND. Len(aSTQuant) >= 2
				STBSetQuant(aSTQuant[1]) 
				nPrice := aSTQuant[2]
				If Len(aSTQuant) == 3 
					aInfoItem[ITEM_CODIGO] := aSTQuant[3]
				Endif
			Else
				//|Caso o Retorno do lStQuant Nao Seja Array,       |
				//|Eh Interpretado Que Devera Abandonar a Validacao |
				//|Voltando Para o Get.                             |
				lRet := .F.
			EndIf
			
			If !lRet			
				LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Ponto de Entrada STQUANT não retornou array ")
			EndIf
		EndIf
	EndIf

	//Valida quantidade 
	//Limite de qtde de 9999.99 somente para ECF
	If lRet .AND. ((!(lEmitNFCe .OR. lUseSat) .AND.STBGetQuant() > 9999.99 ) .OR. STBGetQuant() == 0)
		LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Quantidade informada não atende o limite permitido (minímo = 1, máximo = 9999.99). Quantidade Informada:",STBGetQuant())
		STFMessage("ItemRegistered","STOP",STR0008) //Quantidade inválida.
		lRet := .F.
	EndIf

	If lRet .And. lStValPro .And. !lRecovery
		LjGrvLog(Nil,"Ponto de Entrada STVALPRO Existe. Parametros:",{aInfoItem[ITEM_CODIGO], STBGetQuant() } )
		lRet := ExecBlock( "STVALPRO",.F.,.F.,{aInfoItem[ITEM_CODIGO], STBGetQuant() } )
		LjGrvLog(Nil,"Ponto de Entrada STVALPRO. Retorno <- ", lRet )
	EndIf

	//Numero maximo de itens por venda
	If lRet
		If nItemLine > 990
			LjGrvLog("L1_NUM: "+STDGPBasket('SL1','L1_NUM'),"Quantidade de itens lançados na venda ultrapassa o maximo de itens permitido no grid: " + AllTrim(Str(nItemLine)))
			STFMessage("ItemRegistered","STOP",STR0030) //"Atingido numero maximo de itens por venda. Efetue nova venda."
			lRet := .F.
		EndIf
	EndIf

	//Identifica se o item encontrado eh um Item Agrupador (Kit de Produtos),
	//onde somente seus filhos serao inclusos na venda.
	If lRet
		lRet := STWItemClustered(aInfoItem)
		If !lRet
			LjGrvLog(cL1Num,"Registro de KIT")
			lKitMaster := .T.
		EndIf
	EndIf

	If lRet .AND. nPrice == 0
		LjGrvLog(cL1Num,"Item sem Valor, sera verificado se item de Recarga (STWShopCardRecharge)")	
		lRecShopCard := STWShopCardRecharge(aInfoItem[ITEM_CODIGO])
		LjGrvLog(cL1Num,"Retorno da verificacao se Item de Recarga",lRecShopCard)

		If lRecShopCard
			LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Item nao possui preco e nao e item de recarga")
			lRet := .F.
		EndIf
	EndIf
	
	//So deixa vender com caixa aberto
	If lRet
		lRet := STBCaixaVld()			
		If !lRet
			LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Caixa Fechado")
		EndIf			
	EndIf 
	
	/*/
		Validações específicas para Garantia Estendida
		Nunca serao impressos, apenas armazenados em array para serem apresentados no final da venda
		Não será tratado a garantia quando estiver na finalização da venda.
	/*/
	If 	lRet .AND. !lKitMaster .AND. (aInfoItem[ITEM_TIPO] == cMvLjTGar) .AND. !lServFinal
		
		LjGrvLog(cL1Num,"Realiza validacoes para Item de Garantia Estendida")

		If !lFuncGarEst		
			//se tentou vender item de garantia, avisa que precisa atualizar fontes
			LjGrvLog(cL1Num,STR0033+STR0032) //"Garantia Estendida: Item do tipo Garantia(MV_LJTPGAR) não poderá ser registrado! Motivo: "###"Favor incluir os fontes STBEXTWARRANTY/STDEXTWARRANTY/STWEXTWARRANT para validar a Garantia Estendida."								
			STFMessage("ItemRegistered","STOPPOPUP",STR0033+STR0032) //"Garantia Estendida: Item do tipo Garantia(MV_LJTPGAR) não poderá ser registrado! Motivo: "###"Favor incluir os fontes STBEXTWARRANTY/STDEXTWARRANTY/STWEXTWARRANT para validar a Garantia Estendida."
			lRet := .F.
		EndIf
			
		If lRet .AND. cTypeItem <> "IMP" 
			LjGrvLog(cL1Num,STR0033+STR0027) //"Garantia Estendida: Item do tipo Garantia(MV_LJTPGAR) não poderá ser registrado! Motivo: "###"Não é possível inserir código de Garantia Estendida no TOTVS PDV."
			STFMessage("ItemRegistered","STOPPOPUP",STR0033+STR0027) //"Garantia Estendida: Item do tipo Garantia(MV_LJTPGAR) não poderá ser registrado! Motivo: "###"Não é possível inserir código de Garantia Estendida no TOTVS PDV."
			lRet := .F.
		EndIf
		
		//Armazena Itens Garantia Estendida
		If lRet
			aRet := STDGEProdVin(cItemCode,cCodItemGar)
			//aRet deverá retornar qual produto comum foi utilizado para aquela garantia.
			If Len(aRet) = 3
				cProdVend := aRet[1]
				nPrProd	:= aRet[2]
				cSerieProd := aRet[3]
				STWItemGarEst(1			,;	//Tipo do Processo (1=Set - 2=Get - 3=Clear) 
								cItemCode	,;	//Codigo Garantia Estendida		
								IIF(cTypeItem == "IMP", nPrice-nDiscount, STWFormPr( PadR(cItemCode, TamSx3("B1_COD")[1]) )),;	//Valor da Garantia Estendida					
								cProdVend	,;	//Codigo Produto Vendido			
								Val(cCodItemGar)	,; 	//Item Produto Vendido		
								cTypeItem			,;	//Tipo do Item - Usado para importacao de Orcamento
								nPrProd			,;	//Preco do Produto Vendido, que será impresso no cupom gerencial
								cSerieProd			)	//Serie do Produto Vendido
			Else
				LjGrvLog(cL1Num,STR0033+STR0034 + cItemCode + " - " + cCodItemGar)	//"Garantia Estendida: Item do tipo Garantia(MV_LJTPGAR) não poderá ser registrado! Motivo: "###"Não encontrado o produto vinculado para o produto garantia "
				STFMessage("ItemRegistered","STOPPOPUP",STR0033+STR0034) //"Garantia Estendida: Item do tipo Garantia(MV_LJTPGAR) não poderá ser registrado! Motivo: "###"Não encontrado o produto vinculado para o produto garantia "
				lRet := .F.
			EndIf
		EndIf																	
	EndIf
	
	/*/
		Validações específicas para serviços financeiros
		Nunca serao impressos, apenas armazenados em array para serem apresentados no final da venda
		Não será tratado o serviço quando estiver na finalização da venda.
	/*/
	If lRet .And. lFinServ .AND. !lKitMaster
		LjGrvLog(cL1Num,"Realiza validacoes para Servicos Financeiros(MV_LJCSF = .T.)")

		If STBIsFinService( cItemCode )		// Produto tipo Servico Financeiro						
			LjGrvLog(cL1Num,"Produto tipo Servico Financeiro (B1_TIPO = MV_LJTPSF)")						
			If !(STWValidService(3,	NIL, NIL, cCliCode, cCliLoja))		//Valida se não for Cliente Padrão								
				LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: "+STR0014) //"Venda de Serviço Financeiro não permitida para Cliente padrão."
				lRet := .F.
				STFMessage("ItemRegistered","STOP",STR0014) //"Venda de Serviço Financeiro não permitida para Cliente padrão."							
			ElseIf STBGetQuant() > 1		//Valida quantidade do Servico Financeiro
				LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: " + STR0012) //"Não é permitido alterar quantidade para Serviço Financeiro."								
				lRet := .F.
				STFMessage("ItemRegistered","STOP",STR0012) //"Não é permitido alterar quantidade para Serviço Financeiro."
			Else	// Flag Servico Financeiro
				lItemServFin := .T.
				lRet		 := .T.
				
				If !lServFinal 
					/*
						Verifica se o item é um Serviço Avulso.
					*/																	
					If STWValidService(1,aInfoItem) .Or. cTypeItem == "IMP" //Valida se o produto serviço é Avulso (.T.) ou Vinculado (.F.) ou importado					
						/* Valida Desconto no Total da Venda */
						If cTypeItem <> "IMP" .And. oTotal:GetValue("L1_DESCONT") > 0 							 														 
							lRet := .F.	
							STFMessage("ItemRegistered","STOP",STR0016) //#"Não é possível inserir Servicos Financeiros pois venda possui desconto"							
						EndIf
						
						/*
							Armazena Itens Servico Financeiro Avulso				
						*/
						If lRet
							STWItemFin(1			,;	//Tipo do Processo (1=Set - 2=Get - 3=Clear) 
										cItemCode	,;	//Codigo Servico Financeiro			
										IIF(cTypeItem == "IMP", nPrice, STWFormPr( PadR(cItemCode, TamSx3("B1_COD")[1]) )),;	//Valor do Servico Financeiro					
										""			,;	//Codigo Produto Vendido			
										0			,; 	//Item Produto Vendido		
										cTypeItem	) 	//Tipo do Item - Usado para importacao de Orcamento
						EndIf										
					Else																	
						LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: " + STR0013) //"Item de Serviço não é valido por ser Vinculado a outro produto"
						lRet := .F.	
						STFMessage("ItemRegistered","STOP",STR0013) //"Item de Serviço não é valido por ser Vinculado a outro produto" 										
					EndIf				
				EndIf			
			EndIf					
		Else
			LjGrvLog(cL1Num,"Produto nao e tipo Servico Financeiro (B1_TIPO <> MV_LJTPSF)")

			//Armazena Servicos Financeiros Vinculados ao produto se cliente nao for Padrao					
			If ( STWValidService( 	3, 			NIL, 		NIL, 		cCliCode,;
										cCliLoja ) )			
				STDServItens( PadR(cItemCode, TamSx3("B1_COD")[1]), nItemLine, cTypeItem)	//Busca Servicos Financeiros Vinculados ao produto e Armazena	
			EndIf
			
			lRet := .T.
			
		EndIf			
	
	EndIf

	If	lRet .And. !lRecovery .AND. !IsInCallStack("STISelValePresente") .And. lFunGiftCar .And. STBIsGiftCard(aInfoItem[ITEM_CODIGO])
		LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Tentou registrar item de Vale Presente. Para esse tipo de venda deve utilizar a opcao do Menu(F2)")
		lRet := .F.
		STFMessage("ItemRegistered","STOP", STR0015 ) //"Para a venda de 'Vale Presente', utilizar opção do 'Menu(F2)'."		
	EndIf

	If lRet .AND. !lKitMaster
	
		//Vale-Presente se Recovery
		If lRecovery .And. !Empty(cValePre);
				 .AND. (STDGGiftCard(cItemCode) == "1")
			cItemCode := cValePre
			STBSetCodVP(cItemCode)
			lItemFiscal := .F.
		EndIf

		/***** Busca preco do item caso nao tenha sido informada por parametro *********/
		STWItRnPrice(@nPrice, cL1Num, aInfoItem, cCliCode,cCliLoja, nMoeda, @lRet )

		// Busca TES que sera usada para calcular imposto do item
		// Caso nao tenha sido informada por parametro
		If lRet .AND. Empty( cItemTES )

			cItemTES := STBTaxTES(	2	,	"01"					,	cCliCode		,	cCliLoja 		  ,;
									"C"	,	aInfoItem[ITEM_CODIGO]	,	Nil				,  aInfoItem[ITEM_TES],;
									lListProd				)
			
			LjGrvLog(cL1Num,"Nao recebeu a TES do item para impostos, entao foi realizado consulta(STBTaxTES/MaTesInt)", cItemTES)
			
			If Empty( cItemTES )
				LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: " + STR0002) //"Atenção. TES de Saída Inválida."
				lRet := .F.
				STFMessage("ItemRegistered","STOP",STR0002) //"Atenção. TES de Saída Inválida."
			EndIf

		EndIf
		
		// Se ainda nao inicializou a venda,
		// inicializa cabecalho do controle de impostos
		If lRet 
			If !(STBTaxFoun())
				LjGrvLog(cL1Num,"Inicializa o Calculo das operacoes Fiscais(STBTaxIni/MaFisIni)")
				STBTaxIni(	cCliCode	,	cCliLoja 	,	"C"			,	"S"		,;
							.F.			,	"SB1"		,	"LOJA701" ,	.T.		,;
							cCliType	)
			EndIf

			// Salva cabecalho da venda na cesta de vendas
			If nItemLine == 1
				LjGrvLog(cL1Num,"Registro do Primeiro item, salva informacoes do cabecalho da venda (STBSaveSaleBasket)")
				STBSaveSaleBasket()
			EndIf 
		
			// Enviado via paramentro a media (Total de Segundos / Itens de Venda)
			If SL1->(ColumnPos("L1_TIMEITE")) > 0
				STDSPBasket( "SL1" , "L1_TIMEITE"	, nSecItem / nItemLine	)
			EndIf 

			//Apos encontrar o preco verifica se altera quantidade
			//com os dados do codigo de barras e o preco
			STBQtdEtq( cCodIniIT , nPrice , aInfoItem[ITEM_BALANCA] )
		EndIf

		If lRet .And. lTPLDrogaria
			nDroPrProd := nPrice
			/***** Busca preco do item caso nao tenha sido informada por parametro *********/
			aAux := STBDroVars(.F.)
			STWItRnPrice(@nDroPrProd, STDGPBasket('SL1','L1_NUM'), aInfoItem, cCliCode,cCliLoja, nMoeda, @lRet )
			
			If ExistTemplate("FRTDESCIT")
				aTPLFRTIT := { aInfoItem[ITEM_CODIGO],;
							   Iif(cTypeDesc=="P",nDiscount,0),;
							   Iif(cTypeDesc=="V",nDiscount,0),;
							   nDroPrProd,;
							   (cTypeItem == "IMP"),;
							   STDGPBasket('SL1','L1_DOC'),; //No Primeiro item não tem essa informação
							   STDGPBasket('SL1','L1_SERIE')  ; //STFGetStation("SERIE")	
							}

				aTPLFRTIT := ExecTemplate("FrtDescIT",.F.,.F.,{	;
										aTPLFRTIT[1],aTPLFRTIT[2],aTPLFRTIT[3],aTPLFRTIT[4],;
										aAux[2], aAux[1]   , STBGetQuant()	, cCliCode,;
										cCliLoja, aTPLFRTIT[5], aTPLFRTIT[6], aTPLFRTIT[7] } )
				
				//Seta falso para cancelamento da tela de PBM
				T_DrSScrExMC(.F.)

				//Caso a tela de medicamento controlado seja cancelada, aborta a emissao do item.
				If aTPLFRTIT[5]
					MsgAlert("Medicamentos Controlados necessitam de Infomações do Paciente." +chr(10)+chr(13)+;
							"Produto não será registrado") //"Medicamentos Controlados necessitam de Infomações do Paciente." ##"Produto não será registrado"
					
					//Seta se cancelou a tela da medicamento controlado para cancelar os produtos da PBM
					T_DrSScrExMC(.T.)
					lRet := .F.
				Else
					//nVlrPercIT := aTPLFRTIT[1]
					nDiscount := aTPLFRTIT[2]
					STBDroVars(.F., .T., aTPLFRTIT[4], aClone(aTPLFRTIT[3]))
				EndIf
			EndIf

			If lRet .And. ExistFunc("STBIsVnPBM") .And. STBIsVnPBM()
				If lPrioPBM .And. nDiscount > 0
					LjGrvLog(cL1Num,"Devido a configuração do parametro MV_PRIOPBM, o desconto da loja será zerado")
					nDiscount := 0
				EndiF

				If !STVndPrPbm(	aInfoItem[ITEM_CODBAR], STBGetQuant(), nDroPrProd, @lItemPbm,;
								@nDiscount, lPrioPBM, /*nVlrPercIT*/0 )
					LjGrvLog(cL1Num,"Sem sucesso no lançamento do produto PBM, o desconto da loja será zerado")
					nDiscount := 0
					lRet := .F.
				EndIf
			EndIF

			If lRet
				If Len(aDadoVLink) > 0 
					If (nDroPrProd > 0)  .And. (aDadoVLink[3] <> 1).And. (nDiscount >= nDroPrProd)
						MsgAlert("VIDALINK - O desconto será desconsiderado pois é maior ou igual ao valor do item.",;
								"Atenção") //"O desconto será desconsiderado pois é maior ou igual ao valor do item.","Atenção"
						nDiscount := 0
					EndIf

					If aDadoVLink[3] == 1
						//--------------------------------------------------------------------
						//|  Verifica se o preco do VidaLink eh maior que o preco do sistema | 
						//|  com desconto.Vale o preco menor aValPerc  						 |
						//--------------------------------------------------------------------
						aAux := STBDroVars(.F.)
						aDroVLPVal := T_DroVLPVal(	aDadoVLink[1], aDadoVLink[2], aDadoVLink[3]	, aInfoItem[ITEM_CODIGO],;
													nDiscount	 , STBGetQuant(), STBArred( nDroPrProd * STBGetQuant() ), 0/*nVlrPercIT*/,;
													nDroPrProd	 , aDadoVLink[1], nItemLine		, aAux[2],;
													aAux[1]		 , (cTypeItem == "IMP") )
						nItemTotal := aDroVLPVal[1]
						nDiscount  := aDroVLPVal[2]
						//aDroVLPVal[3] //Percentual do Desconto				
						nDroPrProd := aDroVLPVal[4]
					EndIf
				EndIf
			EndIf

			//Faz o ajuste por meio da variável do Template pois ela altera os valores
			If lRet .And. (nDroPrProd > 0)
				nPrice := nDroPrProd
			EndIf		
		EndIf
		
		// Arredondamento
		nItemTotal := STBArred( nPrice * STBGetQuant() )

		// Total da venda antes do calculo dos impostos
		nVTotAfter := oTotal:GetValue("L1_VLRTOT")
		
		/*Atualiza totalizadores da Matxfis para evitar erro de diferença de valores entre sistema e impressora fiscal.
		Necessário para quando registra um item com desconto e recebe negacao da permissão de superior ou quando 
		caixa faz alguma operação na impressora. Ex. Troca de papel, queda de luz, etc. durante a inclusão do item. */
 		If lItemDel .And. STBTaxFoun("IT_ITEM", nItemLine)
			conout("STIWtemRegister - Ajustando valor do item na MatxFis!")
			LjGrvLog(cL1Num,"Ira ajustar valor do item na Matxfis")
			STBTaxDel(nItemLine, .F. )
			STBTaxAlt("IT_PRCUNI",0,nItemLine)
			STBTaxAlt("IT_VALMERC",0,nItemLine)
			lItemDel := .F.
		EndIf
		
		// Add item para calculo do imposto
		If lRet
			STBTaxIniL(	nItemLine		,	.F.			,	aInfoItem[ITEM_CODIGO]	, cItemTES 			, ;
						STBGetQuant()	,	nPrice		, 	0						, nItemTotal			)
								
			// Atualiza o preco pois apos passar pelas funcoes fiscais
			// o preco pode ter sido alterado, arredondado etc..	devido aos impostos
			nPrice := STBTaxRet(nItemLine,"IT_PRCUNI")

			//valores de impostos por ente tributario da lei dos impostos
			 If lFLImpItem .And. (Len(aInfoItem) >= 23)
				aAlqLeiTr := STBLImpItem(aInfoItem[ITEM_POSIPI]  ,aInfoItem[ITEM_EX_NCM] ,aInfoItem[ITEM_CODISS], aInfoItem[ITEM_CODIGO]  )
				nTamArray := Len(aAlqLeiTr)
				aInfoItem[ITEM_TOTIMP] := Iif(nTamArray >= 1,aAlqLeiTr[1],0) 
				aInfoItem[ITEM_TOTFED] := Iif(nTamArray >= 2,aAlqLeiTr[2],0)
				aInfoItem[ITEM_TOTEST] := Iif(nTamArray >= 3,aAlqLeiTr[3],0)
				aInfoItem[ITEM_TOTMUN] := Iif(nTamArray >= 4,aAlqLeiTr[4],0)
			EndIf
		
			// Inicia Evento | Abertura do Cupom
			If lItemGarEst .OR. lItemServFin	//Garantia Estendida Avulso e Servico Financeiro Avulso nao registra
				lItemFiscal := .F.
			EndIf
			
			If lItemFiscal .AND. STFGetCfg("lUseECF") 
				LjGrvLog(cL1Num,"Inicia Operacao de Registro Fiscal para ECF")

				// Requisito para Alagoas
				// Verifica data e hora para registro de cada item.
				If LjAnalisaLeg(31)[1]

					//Verifica se a data do sistema eh a mesma data da impressora fiscal.
					If !STWCheckDate()
				   		LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Diferenca entre a Data/Hora do Sistema com a Impressora Fiscal.") 
						lRet := .F.
					EndIf
				EndIf
				
				//Verifica se tem desconto no Item
				If nDiscount > 0 .AND. (cTypeDesc $ "V|P")
					LjGrvLog(cL1Num,"Item possui desconto de:"+cValToChar(nDiscount))
					STWIDBefore( nDiscount , cTypeDesc )		
				EndIf
					
				STWItemDiscount( nItemLine , nDiscount , cTypeDesc , cTypeItem , lItemFiscal)
				//Busca desconto do usuario
				aDiscount := STBGetItDiscount()
				
				// Busca permissão de desconto
				If aDiscount[1] > 0				
				   	If ExistFunc("STBValidDesc")
				 		lRet := IIf(cTypeItem == "KIT",.T.,STBValidDesc())
					 	If !lRet
					 		LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Usuário não possui permissão para desconto")
					 	EndIf
					Else
						LjGrvLog(cL1Num,"Função STBValidDesc não compilada, necessário atualizar o fonte STBItemDiscount, permissão de desconto não foi verificado." ) 
					EndIf					
				EndIf	
				
				//Valida valor total da venda caso o item seja aceito	
				If lRet .And. l950SP10OK
					If !Lj950SP10OK( oTotal:GetValue("L1_VLRTOT") , 1, cCliCode , cCliLoja)
						LjGrvLog(cL1Num,"O valor deste item lançado fará com que o valor total da venda ultrapasse o total permitido por legislação.",oTotal:GetValue("L1_VLRTOT") + STBArred( nPrice * STBGetQuant() ))						
						lRet := .F.
					EndiF
				EndIf			

				//Abertura do Cupom 				
				If lRet .AND. !lReceiptIsOpen
					LjGrvLog(cL1Num,"Abertura do Cupom Fiscal - Inicio" )
				   	lRet := STBOpenReceipt(cCliCode, cCliLoja, lInfoCNPJ)
				   	LjGrvLog(cL1Num,"Abertura do Cupom Fiscal - Retorno:",lRet )

					STWSetIsOpenReceipt( lRet )

					If !lRet //Ocorreu problemas na abertura do CF

						If ExistFunc("STWGetMsgOperante")
							cMsgErro := STWGetMsgOperante()
						Else
							CONOUT(STR0017) //"Contate o seu suporte. Favor atualizar o fonte STWECFCONTROL.PRW e STWZReduction.PRW."
						EndIf

						LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Falha na Abertura de Cupom. Mensagem:"+cMsgErro)
						STFMessage("ItemRegistered","STOP",cMsgErro) //"Nao foi possivel a abertura do Cupom Fiscal"
						//Chama a função que deleta o item na MatxFis, e não somente o marca como deletado
						STBTaxDel(	nItemLine	, .T. )
					Else
						//Se Conseguiu Abrir Cupom atualiza Cesta de Venda
						LjGrvLog(cL1Num,"Abertura de Cupom Fiscal realizada com sucesso" )
						STDSPBasket( "SL1" , "L1_SITUA"			, "02" )  // "02" - Impresso a Abertura do Cupom
					EndIf
				ElseIf lReceiptIsOpen
					LjGrvLog(cL1Num,"Abertura do Cupom Fiscal já realizada" )
				EndIf


            	If lRet //Cupom Aberto com sucesso

		 			// Indica se imprime codigo de barras no cupom ao inves do codigo do produto
		 			// LjAnalisaLeg(39)[1] - A legislação exige que no cupom fiscal seja impresso o codigo EAN"
		 			If ( cImpCodBar == "S" .AND. !Empty(aInfoItem[ITEM_CODBAR]) ) .OR. LjAnalisaLeg(39)[1]
						cCodeForPrint := aInfoItem[ITEM_CODBAR]
					Else
						cCodeForPrint := aInfoItem[ITEM_CODIGO]
					EndIf

					If LjAnalisaLeg(9)[1] //- Codigo do produto preenchido com zeros(0) a esquerda
						Right('0000000000000'+Alltrim(cCodeForPrint),13)
					EndIf

					cDscPrdPAF := aInfoItem[ITEM_DESCRICAO]
					/*CONVÊNIO ICMS 25, DE 8 DE ABRIL DE 2016
					  #código CEST#NCM/SH#descrição do item*/					
					If STBIsPAF() 
						cITcEst		:= AllTrim(STBTaxRet(nItemLine,"IT_CEST"))
						cPosIpi		:= AllTrim(aInfoItem[ITEM_POSIPI])
						If !Empty(cITcEst) .And. !Empty(cPosIpi)
							cDscPrdPAF	:= "#" + cITcEst + "#" + cPosIpi + "#" + AllTrim(cDscPrdPAF)
						EndIf
					EndIf
					
					cQuant 		:= StrZero(STBGetQuant(),8,3)
					cVrUnit 	:= AllTrim(STR(nPrice))
					cDesconto	:= AllTrim(STR(STBTaxRet(nItemLine,"IT_DESCONTO"	)))
					cSitTrib	:= STBTaxSit(nItemLine)
					cVlrItem	:= AllTrim(STR(STBTaxRet(nItemLine,"IT_TOTAL"		)))
									
					//Ponto de entrada para adicionar dados na impressao da descricao do produto				
					If lLj7013
						LjGrvLog(SL1->L1_NUM,"Antes da Chamada do Ponto de Entrada:LJ7013",{cCodeForPrint, cDscPrdPAF, cQuant, cVrUnit, cDesconto, cSitTrib, cVlrItem, nItemLine})										
						aRetLj7013 := ExecBlock("LJ7013",.F.,.F.,{cCodeForPrint, cDscPrdPAF, cQuant, cVrUnit, cDesconto, cSitTrib, cVlrItem, nItemLine })
						LjGrvLog(SL1->L1_NUM,"Apos a Chamada do Ponto de Entrada:LJ7013",aRetLj7013)
										
						If ValType( aRetLj7013 ) == "A" .AND. Len( aRetLj7013 ) >= 7
							cCodeForPrint	:= aRetLj7013[1]
							cDscPrdPAF		:= aRetLj7013[2]
							cQuant 			:= aRetLj7013[3]
							cVrUnit			:= aRetLj7013[4]
							cDesconto		:= aRetLj7013[5]
							cSitTrib		:= aRetLj7013[6]
							cVlrItem		:= aRetLj7013[7]
						EndIf
					EndIf
									
					LjGrvLog(cL1Num,	"Registro do Item - Inicio"+; 
										" Codigo:"+cCodeForPrint+;
										";Descricao:"+cDscPrdPAF+;
										";Qtde:"+cQuant+;
										";ValorUnit:"+cVrUnit+;
										";Desconto:"+cDesconto+;
										";Aliq/SitTrib:"+STBTaxSit(nItemLine)+;
										";Total:"+cVlrItem+;
										";Unid.Medida:"+aInfoItem[ITEM_UNID_MEDIDA])
										
					// Inicia Evento
					aRet := STFFireEvent(	ProcName(0)					,;		// Nome do processo
								"STItemReg"								,;		// Nome do evento
								{cCodeForPrint							,;		// 01 - Codigo do Item
								cDscPrdPAF								,; 		// 02 - Descricao
								cQuant									,;		// 03 - Quantidade
								cVrUnit						   			,;		// 04 - Valor Unitario
								cDesconto								,;		// 05 - Desconto do Item
								cSitTrib	 							,;		// 06 - Situacao tributaria
								cVlrItem						   		,;		// 07 - Total do Item
								aInfoItem[ITEM_UNID_MEDIDA]				,; 		// 08 - Unidade de Medida
								"2" 									} )		// 09 - TIPO TES ( 2 - Saida )

				   lRet := Len(aRet) == 0 .Or. (ValType(aRet[1]) == "N" .AND. aRet[1] == 0)
				   LjGrvLog(cL1Num,	"Registro do Item - Retorno:",lRet)
				   If !lRet
				   		LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Não realizou o registro fiscal. aRet",aRet)		
				   EndIf

				   //Informa que a venda esta em andamento
				   STBSaleAct(.T.)

				EndIf

			Else
				LjGrvLog(cL1Num,"Inicia Operacao de Registro para item nao fiscal ou nao usuario de ECF")

				//Verifica se tem desconto no Item					
				If nDiscount > 0 .AND. (cTypeDesc $ "V|P")
					STWIDBefore( nDiscount , cTypeDesc )		
				EndIf

				STWItemDiscount( nItemLine , nDiscount , cTypeDesc , cTypeItem , lItemFiscal )

				If STFGetCfg("lUseECF") 
					// Soma valor não fiscal no totalizador
					STBSumNotFiscal( (nPrice * STBGetQuant()) - nDiscount )
				Else
					If !lItemFiscal
						STBSumNotFiscal( (nPrice * STBGetQuant()) - nDiscount )		   	
					EndIf				
				EndIf
			EndIf

		EndIf

		// Salva Item na Cesta de vendas
	 	If lRet
			
			LjGrvLog(cL1Num, "Registra Item - Salva Item na Cesta de vendas - SL2" )
			
			lRet := STBSaveItBasket( aInfoItem , nItemLine, cIdItRel)
			//seta o contador do item fiscal/não fiscal	
			If lRet .AND. lSumItFisc
				STBSumItem(lItemFiscal .AND. STFGetCfg("lUseECF"), nItemLine )
			Endif	

			If(lRet .AND. !Empty(cCodProdKit) , STDSPBasket("SL2", "L2_KIT", rtrim(cCodProdKit), nItemLine) , )

			IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_FISCAL" , lItemFiscal , nItemLine ) ,)
			
			If lRet .AND. lListProd .and. cTypeItem <> "IMP" //Lista importada do orçamento já alimenta os campos	
				
				STDSPBasket( "SL2" , "L2_CODLPRE" ,cCodList  , nItemLine )
				STDSPBasket( "SL2" , "L2_ITLPRE" , cCodListIt , nItemLine )
				STDSPBasket( "SL2" , "L2_MSMLPRE" ,cCodMens  , nItemLine )
				STDSPBasket( "SL2" , "L2_ENTREGA" ,cEntrega  , nItemLine )
				
				If !lItemFiscal .And. ; //Nao eh item fiscal
					If(lMVLJPRDSV, !LjIsTesISS( STDGPBasket('SL1','L1_NUM'), STDGPBasket("SL2","L2_TES",nItemLine) ), .T.) //Nao eh Item de Servico (ISS)
					
					STDSPBasket( "SL2" , "L2_RESERVA" , "S" , nItemLine )
				EndIf
	
		 	EndIf
		EndIf
		If lRet .AND. lProdBonif
			STDSPBasket( "SL2" , "L2_BONIF" , .T., nItemLine )
		Endif	
		
		//Tratamento de item Servico Financeiro
		If lRet .AND. lFinServ
			//Se nao for Servico Financeiro, verifica posicao real do item na Cesta de Produtos
			If !STBIsFinService( cItemCode )
				STDSPBasket( "SL2" , "L2_ITEMREA" , STWNumItem(), nItemLine )	
			Else
				STDSPBasket( "SL2" , "L2_ITEMREA" , "00", nItemLine )	
			EndIf																				
		EndIf
	EndIf

Else
	LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Item nao localizado ou indisponivel no cadastro do PDV.")
	LjGrvLog(cL1Num,"Status Codigo do Item:" + cItemCode + " - Localizado:"+IIF(aInfoItem[ITEM_ENCONTRADO],"Sim","Nao")+" - Bloqueado:"+IIF(aInfoItem[ITEM_BLOQUEADO],"Sim","Nao") + " - Tipo GE(B1_TIPO):"+ IIF(aInfoItem[ITEM_TIPO] == 'GE',"Sim","Nao") )
	lRet := .F.			// Item nao encontrado
EndIf

If !lKitMaster
	If lRet .And. lTPLDrogaria
		If ExistFunc("STBIsVnPBM") .And. STBIsVnPBM()
			If !STCnfPrPBM(AllTrim(STDGPBasket("SL2","L2_CODBAR",nItemLine)), STBGetQuant(), .T., lItemPbm, nItemLine)
				lRet := .F.
				LjGrvLog(cL1Num,"Item não confirmado na PBM, não será registrado",lRet)
				STFMessage("ItemRegistered","STOP","PBM - Produto " + AllTrim(STDGPBasket("SL2","L2_PRODUTO",nItemLine)) +;
													"Inválido - Não registrado" ) //"PBM - Produto " + + "Inválido - Não registrado"
			EndIf
		EndIf
	EndIf

	If !lRet
		//Se ocorreu problemas na Impressão do item - chama a função que deleta o item na MatxFis e não somente o marca como deletado	
		If STBTaxFoun(	"", nItemLine	)	
			STBTaxDel(	nItemLine	, .T. )
		EndIf

		// Seta controle de item deletado como True
		lItemDel := .T.
	EndIf
EndIf

If lRet

	STFMessage("ItemRegistered","STOP",STR0004) //"Item registrado"
	LjGrvLog( cL1Num, STR0004 )  //"Item registrado"

ElseIf aInfoItem[ITEM_BLOQUEADO]
	
	STFMessage("ItemRegistered","STOP",STR0009 + aInfoItem[ITEM_CODIGO] + STR0010) //"Item bloqueado"
	LjGrvLog( cL1Num, STR0010 )  //"Item bloqueado"
	
ElseIf lKitMaster

	STFMessage("ItemRegistered","STOP",STR0005) //"Item do tipo Kit registrado"
	LjGrvLog( cL1Num, STR0005 )  //"Item do tipo Kit registrado"

ElseIf !lRecShopCard

	STFMessage("ItemRegistered","STOP",STR0006) //"Nao foi possivel registrar o item"
	LjGrvLog( cL1Num, STR0006 )  //"Nao foi possivel registrar o item"

EndIf

// Limpa Objetos variaveis e restaura padrao

STBSetDefQuant()								// Seta quantidade padrao apos o registro de item
STBDefItDiscount()								// Seta desconto padrao apos registro de item

//Mostra mensagens referente ao registro de itens
If !lRecovery
	STFShowMessage("ItemRegistered")
EndIf

LjGrvLog( cL1Num, "Fim - Workflow Registra Item" )  //Gera LOG

If lRet
	If !lAddItem .AND. MsFile("ACR")
		STWBonusSales( nItemLine )
	EndIf
	LjGrvLog( cL1Num, "Faz a persistencia dos dados nas tabelas SL1, SL2 e SL4." )  //Gera LOG
	STDSaveSale(nItemLine)
	LjGrvLog("Registra_Item", "ID_FIM")
Else
	LjGrvLog("Registra_Item", "ID_ALERT")
EndIf

If lRet .And. lTPLDrogaria
	//JULIOOOOO - CONTINUAR AQUI - verificar se todos os campos estão preenchidos
	aTPLCODB2 := { ;
				nItemLine, AllTrim(STDGPBasket("SL2","L2_PRODUTO",nItemLine)),;
				AllTrim(STDGPBasket("SL2","L2_CODBAR",nItemLine)),AllTrim(STDGPBasket("SL2","L2_DESC",nItemLine)),;
				cValToChar(STDGPBasket("SL2","L2_QUANT",nItemLine)), cValToChar(STDGPBasket("SL2","L2_VRUNIT",nItemLine)),;
				"", cValToChar(STDGPBasket("SL2","L2_VLRITEM",nItemLine)),"", "", .F.,""}
	aAux := STBDroVars(.F.)
	AADD(aTPLCODB2,aAux[2]) //13- uProdCli
	AADD(aTPLCODB2,aAux[1]) //14 - uCliTPL
	AADD(aTPLCODB2,NIL) //15 - oModelCesta
	AADD(aTPLCODB2,nItemLine) //16 - nItemLine - Linha do Basket de itens
	
	aTPLCODB3 := aClone(aTPLCODB2)

	If ExistTemplate("FRTCODB2")
		aTPLCODB2 := ExecTemplate( "FRTCODB2",.F.,.F.,{aTPLCODB2, aAux[2], aAux[1] } )
		aAux := Array(2)
		If ValType( aTPLCODB2[13] ) == "A" //uProdCLI
			aAux[2] := aClone(aTPLCODB2[13])
		Else
			aAux[2] := aTPLCODB2[13]
		Endif

		If ValType( aTPLCODB2[14] ) == "A" //uCLiTPL
			aAux[1]  := aClone(aTPLCODB2[14])
		Else
			aAux[1]  := aTPLCODB2[14]
		Endif
		STBDroVars(.F.,.T.,aAux[1],aAux[2])
	EndIf

	If ExistTemplate("FRTCODB3")
		aAux := STBDroVars(.F.)
		Aadd(aTPLCODB3,nItemLine)
		aTPLCODB3 := ExecTemplate("FRTCODB3",.F.,.F.,{aTPLCODB3,aAux[2],aAux[1]})
		STBDroVars(.F., .T., aTPLCODB3[14], aClone(aTPLCODB3[13]) )
	EndIf

	If T_DroVerCont( AllTrim(STDGPBasket("SL2","L2_PRODUTO",nItemLine)) )
		T_DroAltANVISA( AllTrim(STDGPBasket("SL2","L2_PRODUTO",nItemLine)), STDGPBasket("SL2","L2_QUANT",nItemLine),;
						 STDGPBasket("SL1","L1_DOC"), STDGPBasket("SL1","L1_SERIE"), nItemLine )
	Endif
EndIf

Return lRet


//-------------------------------------------------------------------
/* {Protheus.doc} STWSetOpenedReceipt
Function Registra Item

@param   lSet			Seta se cupom está aberto ou fechado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWSetIsOpenReceipt( lSet )

Default lSet := .F.		//	Seta se cupom está aberto ou fechado

ParamType 0 var  	lSet		As Logical		Default 	.F.

lReceiptIsOpen := lSet

Return


//-------------------------------------------------------------------
/* {Protheus.doc} STWSetOpenedReceipt
Retorna se o cupom está aberto ou fechado

@author  Varejo
@version P11.8
@since   29/03/2012
@return  lReceiptIsOpen		Retorna se o cupom está aberto ou fechado
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWGetIsOpenReceipt()

Return lReceiptIsOpen

//-------------------------------------------------------------------
/* {Protheus.doc} STWSetOpenedReceipt
Retorna se o cupom está aberto ou fechado

@param   lItemFiscal Indica se é cupom fiscal ou não	
@author  Varejo
@version P11.8
@since   16/09/2014
@return  lRegistred		Retorna se o item foi registrado ou nao
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWSetRegIt(nItemLine,cCodItem,cTesPad,nTotItem,;
						lItemFiscal)

Local lRegistred	:= .T.										//Variavel que verifica se o item foi registrado
Local cCliCode		:= STDGPBasket("SL1","L1_CLIENTE")			//Codigo do Cliente na Cesta
Local cCliLoja		:= STDGPBasket("SL1","L1_LOJA")				//Loja do Cliente na Cesta
Local cCliType		:= STDGPBasket("SL1","L1_TIPOCLI")			//Tipo do Cliente na Cesta
Local nMoeda		:= 1										//Moeda Corrente
Local nPrice         := STBSearchPrice(cCodItem, cCliCode, cCliLoja  )

Default lItemFiscal := .T.

lRegistred := STWItemReg( 	nItemLine		, ;			// Item
		   						cCodItem		, ;		// Codigo Prod
		   						cCliCode 		, ;		// Codigo Cli
		   						cCliLoja		, ;		// Loja Cli
								nMoeda 			, ;		// Moeda
								Nil 			, ;		// Valor desconto
			 					Nil				, ;		// Tipo desconto ( Percentual ou Valor )
			 					Nil				, ;		// Item adicional?
		  						cTesPad			, ;		// TES
		  						cCliType 		, ;		// Tipo do cliente (A1_TIPO)
		  						lItemFiscal 	, ;		// Registra item no cupom fiscal?
		  						nPrice		   , ;		// Preço
		  						Nil				, ;		// Tipo do Item
		  						Nil				, ;		// Imprime CNPJ no cupom Fiscal
		  						Nil				, ;		// Tela do POS está sendo apresentada
		  						nTotItem		)		// Total dos segundos entre itens
					
//Funcao que zera o digitado pelo usuario no GET de Produto	  						
STISetPrd("")

If lRegistred
	STIShowProdData(nItemLine)
	STIGridCupRefresh(nItemLine,nItemLine) // Sincroniza a Cesta com a interface
	
	LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Código produto registrado", cCodItem )  			
	LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "Item Fiscal", lItemFiscal)	
Else
	LjGrvLog( "L1_Num:" + STDGPBasket("SL1","L1_NUM"), ">>>NC<<< - Falha no Registro do Item -> Código produto não registrado:" + cCodItem + "Item:"+cValToChar(nItemLine) + " - Item Fiscal:"+"Item Fiscal:"+IIF(lItemFiscal,"Sim","Nao") + " - TES:" + cTesPad)
EndIf
 
Return lRegistred 

//-------------------------------------------------------------------
/* {Protheus.doc} STWNumItem
Retorna o Item real do produto na cesta

@param   	
@author  Varejo
@version P11.8
@since   09/04/2015
@return  nItemReal		Item real do produto
@obs
@sample
*/
//-------------------------------------------------------------------
Static Function STWNumItem()

Local aArea		:= GetArea()		//Salva area
Local aSaveLines 	:= FWSaveRows()	//Array de linhas salvas
Local cItemReal 	:= "00"			//Numeracao real de item do produto
Local nI			:= 0				//Contador
Local oModel 		:= STDGPBModel()	//Model

//Verifica se produto é Servico Financeiro
For nI := 1 To oModel:GetModel("SL2DETAIL"):Length()
	//Posiciona no item
	oModel:GetModel("SL2DETAIL"):GoLine(nI)
			
	//Verifica se item ativo e nao Servico Financeiro
	If !oModel:GetModel("SL2DETAIL"):IsDeleted(nI) .And. !STBIsFinService(oModel:GetValue("SL2DETAIL" , "L2_PRODUTO"))
		cItemReal := Soma1(cItemReal)
	EndIf
Next nI

//Restaura areas
RestArea(aArea)
FWRestRows(aSaveLines)

// Limpa os vetores para melhor gerenciamento de memoria (Desaloca Memória)
aSize( aSaveLines, 0 )
aSaveLines 	:= Nil

Return cItemReal


//-------------------------------------------------------------------
/* {Protheus.doc} STWBtFimVnd
Retorna o Item real do produto na cesta

@param   	
@author  Varejo
@version P11.8
@since   07/04/2016
@return  lRet	-	Ok ou não ok?
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWBtFimVnd()
Local lFinServ	:= AliasIndic("MG8") .AND. SuperGetMv("MV_LJCSF",,.F.)
Local lRet		:= .T. 

IF lFinServ
	STWFindServ()
Else
	STWNxtTelaIt()
EndIf

Return lRet

//-------------------------------------------------------------------
/* {Protheus.doc} STWNxtTelaIt
Valida qual a proxima tela a ser mostrada no lançamento do item

@author  Varejo
@version P11.8
@since   07/04/2016
@return  lRet	-	Ok ou não ok?
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWNxtTelaIt()

Local lRet			:= .T.
Local lObrigaLJ950	:= ExistFunc("Lj950ImpCpf") .And. Lj950ImpCpf(STDGPBasket("SL1","L1_VLRTOT")) 

/*Caso exija CPF ou tenha paramterização para chamar tela de CPF no final da venda*/
If lObrigaLJ950 .Or. (ExistFunc("LjInfDocCli") .And. LjInfDocCli() > 1)
	lDadosInf := .T.
	STI7InfCPF(.F.)
	STWInfoCNPJ(,.T.,lObrigaLJ950)
Else
	STICallPayment()
EndIf

Return lRet

/*/{Protheus.doc} STWItRnPrice
	Retorna o preço do produto que esta sendo vendido
	@type  Function
	@author Julio.Nery
	@since 03/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Function STWItRnPrice(nPrice, cL1Num, aInfoItem, cCliCode,;
    				  cCliLoja, nMoeda, lRet   , cCodProd)
Local nRet := 0

Default aInfoItem := Array(ITEM_TOTAL_ARRAY)

If nPrice <= 0
	If ValType(aInfoItem[ITEM_CODIGO]) <> "C"
		aInfoItem[ITEM_CODIGO] := cCodProd
	EndIf
	LjGrvLog(cL1Num,"Item sem preco(Preco=0), sera realizado pesquisa de preco(STWFormPr).")
	nPrice 	:= STWFormPr( aInfoItem[ITEM_CODIGO], cCliCode	, Nil 	, cCliLoja	 , nMoeda , STBGetQuant() )
	LjGrvLog(cL1Num,"Preco apos pesquisa:",nPrice)

	If nPrice == -999		// Verifica se tabela de preço esta dentro da vigencia
		LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Tabela de preço fora de vigência.")
		lRet := .F.
		STFMessage("ItemRegistered","STOP", STR0035 + CHR(13)+CHR(10) + STR0036 ) //"Tabela de preço fora de vigência."  "Verifique o código da tabela contido no parâmetro MV_TABPAD"

	ElseIf nPrice <= 0		//Se nao achou preco
		LjGrvLog(cL1Num,"Item não poderá ser registrado, motivo: Nao possui preco")
		lRet := .F.
		STFMessage("ItemRegistered","STOP",STR0001) //"Preço não encontrado"
	EndIf
EndIf

nRet := nPrice
Return nRet