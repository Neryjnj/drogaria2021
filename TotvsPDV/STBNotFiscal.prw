#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "STBNOTFISCAL.CH"
#INCLUDE "AUTODEF.CH"  

#DEFINE ARQLJINI GetClientDir()+"SIGALOJA.INI"		// caminho do ini do SIGALOJA

//-------------------------------------------------------------------
/* {Protheus.doc} STBSumNotFiscal
Adiciona valor no totalizador não fiscal

@param   nValue				Valor
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBSumNotFiscal( nValue )

Local oTotal := STFGetTot()		// Totalizador

Default nValue  	:= 0	

ParamType 0 Var  nValue As Numeric	 Default 0

oTotal:SetValue( "L1_NOTFISCAL" , nValue + oTotal:GetValue("L1_NOTFISCAL") )

Return Nil                                                                      


//-------------------------------------------------------------------
/*/ {Protheus.doc} STBFactor
Calcula fatores Fiscal e Não-Fiscal

@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet - Fatores fiscais e nao fiscais
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBFactor(lUseServ)

Local nFiscalFactor		:= 0								// Fator Fiscal
Local nNotFiscalFactor	:= 0								// Fator Não Fiscal
Local nTotFiscal		:= 0								// Total Fiscal
Local oTotal	 		:= STFGetTot() 						// Totalizador
Local nTotNaoFisc		:= oTotal:GetVaLue("L1_NOTFISCAL")	// Totalizador Nao Fiscal
Local lItEntrega		:= STBTemEntr()						// Indica se a venda tem item de entrega

Default lUseServ 		:= .T. 								// Controla se considera servicos no totalizador nao fiscal

/*------------------------------------------------------------------------------------- 
 Adiciona os valores de Frete + Seguro + Despesa no total não-fiscal quando existir 
 item de entrega na venda, para o fator fiscal e não-fiscal ficarem corretos.
-------------------------------------------------------------------------------------*/
If lItEntrega
	nTotNaoFisc := nTotNaoFisc + oTotal:GetValue("L1_FRETE") + oTotal:GetValue("L1_SEGURO") + oTotal:GetValue("L1_DESPESA")
EndIf	

//Se nao considera servicos no totalizador nao fiscal, armazena os valores de servicos
If !lUseServ
	nTotNaoFisc -= STFTotalServ()
EndIf

nNotFiscalFactor	:= (nTotNaoFisc / (oTotal:GetValue("L1_VLRTOT") + oTotal:GetValue("L1_DESCONT") - oTotal:GetValue("L1_ACRSFIN")))
nFiscalFactor 		:= (1 - nNotFiscalFactor)  
nTotFiscal			:= (oTotal:GetValue("L1_VLRTOT") + oTotal:GetValue("L1_DESCONT") - oTotal:GetValue("L1_ACRSFIN")) - nTotNaoFisc

If nFiscalFactor == 0
	aRet := { 1 				, nNotFiscalFactor , nTotFiscal }
Else
	aRet := { nFiscalFactor 	, nNotFiscalFactor , nTotFiscal } 
Endif

Return aRet
            
//-------------------------------------------------------------------
/*/ {Protheus.doc} STBPrintNotFiscal
Imprime cupom nao fiscal

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1] -  Retorna se executou corretamente 
@return  aRet[2] -  Numero do cupom
@return  aRet[3] -  Numero do PDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPrintNotFiscal()

Local aRet			:= { .T. , "" , "" }				// Retrono Função
Local oTotal		:= STFGetTot()						// Totalizador
Local aPrinter		:= {}			   					// Armazena Retorno da impressora
Local cText			:= ""			   					// Texto para impressão
Local cValue		:= ""			  					// Valor para impressão
Local lContinue		:= .T.			  					// Fluxo funcao
Local aCupom 		:= {Space(6), Nil} 					// Retorno Evento GetCupom
Local aPDV			:= {""}			   					// Retorno evento pegar PDV
Local cCupom		:= ""			  					// Retorno número do Cupom   
Local cPDV			:= ""			  					// Armazena PDV
Local cUseTef		:= ""			 					// Indica se utiliza tef. "S" ou "N"
Local cPayTef		:= ""			 					// Condição de pagamento TEF
Local lGuil			:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina 
Local lIsImpOrc 	:= If(FindFunction("STBIsImpOrc"),STBIsImpOrc(),(!(Empty(STDGPBasket("SL1","L1_NUMORIG"))))) //Verifica se é importação de orçamento
Local lMVLJPRDSV   	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) // Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas (RPS)
Local cSerieRPS		:= SuperGetMv("MV_LOJARPS",,"RPS") 	// Serie da NF de Servico RPS configurada no parametro MV_LOJARPS
Local lPedido 		:= STBTemEntr()						// Verifica se tem item de "Entrega" ou "Retira Posterior".
Local lRPS 			:= lMVLJPRDSV .And. lIsImpOrc .And. STBTemServ()	// Verifica se tem item de "Servico".
Local aNotas		:= {}
Local lLGSerNFis	:= SLG->(FieldPos("LG_SERNFIS")) > 0
Local lTemItProd	:= .F.								// item fiscal
Local lTemItServ	:= .F.								// item de servico
Local lIsValePres	:= .F. 								//Verifica se é vale presente
Local lExistSer 	:= .F.								// verifica se existe a Serie Não Fiscal
Local lSFinanc      :=  AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.) //Se .T. indica que o Serviço financeiro esta ativo
local lFindExist	:= Iif(ExistFunc("LjFindServ"),Iif(LjFindServ(STDGPBasket("SL1","L1_NUM")),.T.,.F.),.F. ) //Verifico se a função LjFindServ existe e se existe verifico se todos os itens são serviço
Local lLjVpCnf		:= SuperGetMV("MV_LJVPCNF",,.F.) 	//verifica se imprime vale presente no cupom fiscal
Local lScritpImp	:= .F.								// Indica a existência do script de impressão

cSerieRPS := PadR(cSerieRPS , TamSX3("L1_SERRPS")[1])

If !STFGetCfg("lUseECF") .AND. STBExistNItemFiscal() 

		If lRPS //RPS (Recibo Provisorio de Servico)

			If ExistFunc("LJSCRPS")			
				cText := LJSCRPS( {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal         	
				lScritpImp := .T.
			ElseIf ExistBlock("SCRRPS")			
				cText := ExecBlock( "SCRRPS" , .F., .F., {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal
				lScritpImp := .T.
			EndIf

		Else

			If ExistFunc("LJSCRPED")			
				cText := LJSCRPED( {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal         	
				lScritpImp := .T.
			ElseIf ExistBlock("SCRPED")			
				cText := ExecBlock( "SCRPED" , .F., .F., {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal         	
				lScritpImp := .T.
			EndIf

		EndIf

		If lScritpImp
		
			cText := StrTran( cText, ',', '.' )                                    
			
			cValue := Str(( oTotal:GetValue("L1_VLRLIQ") * STBFactor()[2] ) , 15 , 2 )		
					
			If !Empty(cText) 
	
				If STWPrintTextNotFiscal(cText) == 0
				
					//Verifica se é vale presente:
		 			lIsValePres := iIf(FindFunction("STDExistVP"),STDExistVP(),.F.)

					If lPedido .Or. lIsValePres  //Pedido ou Vale presente
						If lLGSerNFis
							cSerie := STFGetStation("SERNFIS")
						Else
							cSerie := STFGetStation("SERIE")
						EndIf

						lExistSer:=	LjxDNota( cSerie, 3, .F., 1, @aNotas )  
						If lExistSer
							cCupom := aNotas[1][2]
	
				 			STDSPBasket( "SL1" , "L1_DOCPED"	, cCupom   				)
				 			STDSPBasket( "SL1" , "L1_SERPED"	, cSerie				)
				 			STDSPBasket( "SL1" , "L1_SITUA"		, "00"					)
							/*	Se o campo L1_DOC estiver vazio, entao deve-se limpar o campo L1_SERIE
				 				melhoria: o campo L1_SERIE só deve ser preenchido quando a venda for fiscal	*/
				 			If lPedido .Or. (lIsValePres .And. !lLjVpCnf)				 				
				 				If !STBExistItemFiscal() 
				 					STDSPBasket( "SL1", "L1_DOC", "" )
				 					STDSPBasket( "SL1", "L1_SERIE", "" )
				 				EndIf
				 			EndIf
						Else
							aRet			:= { .F. , "" , "" }
						Endif
					ElseIf lRPS //RPS (Recibo Provisorio de Servico)
						cSerie := SuperGetMv("MV_LOJARPS",,"RPS") 	// Serie da NF de Servico RPS configurada no parametro MV_LOJARPS
	
						STDSPBasket( "SL1" , "L1_SERRPS"	, cSerie				) // Numero de serie da nota fiscal de servico (RPS)
				 		STDSPBasket( "SL1" , "L1_SITUA"		, "00"					)
						
						LjCheckRPS(STDGPBasket("SL1","L1_NUM"),@lTemItProd,@lTemItServ)
						lOnlyServ := lTemItServ .And. !lTemItProd .And. !Empty(cSerie)	 //Se a variavel "cSerRPS" nao esta vazia eh pq a venda possui apenas itens de "servico"
						If lOnlyServ
							LjxDNota( cSerie, 3, .F., 1, @aNotas )  
							cCupom := aNotas[1][2]						
							STDSPBasket( "SL1" , "L1_DOC"	, ""				)
							STDSPBasket( "SL1" , "L1_SERIE"	, ""				)
							STDSPBasket( "SL1" , "L1_DOCRPS", cCupom				)
						ElseIf Empty(STDGPBasket( "SL1" , "L1_DOC")) //Se DOC estiver vazio é porque na venda só tem produtos de servico (RPS)
							STDSPBasket( "SL1" , "L1_DOC"	, cCupom				)
							STDSPBasket( "SL1" , "L1_SERIE"	, cSerie				)
							STDSPBasket( "SL1" , "L1_DOCRPS", cCupom				)					 	
						EndIf
												
					EndIf			 		

					If aRet[1]
						aRet := { .T. , cCupom , STFGetStation("PDV") }
					EndIf
				EndIf
					
				If lGuil
					cText := Replic(CHR(10)+CHR(13),6)
					cText += TAG_GUIL_INI+TAG_GUIL_FIM		//Corte de Papel								
					STWPrintTextNotFiscal(cText)
				EndIf	
		
			EndIf

		Else
			STFMessage("STBPrintNotFiscal", "STOPPOPUP",STR0011) //"O rdmake SCRRPS.PRW não está compilado e não será possível imprimir o comprovante RPS (Recibo Provisório de Serviço). Informe essa mensagem ao administrador do sistema."
			STFShowMessage("STBPrintNotFiscal")
			aRet := { .F. , "" , "" }
		EndIf
		
ElseIf STFUseFiscalPrinter() .AND. oTotal:GetValue("L1_NOTFISCAL") > 0 // Utiliza impressora fiscal e possui itens não fiscais

	If STBValPrintNotFiscal(If(lPedido,"PED",If(lRPS,"RPS","")))
		
		If lPedido  //Pedido

			If ExistFunc("LJSCRPED")			
				cText := LJSCRPED( {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal         	
			ElseIf ExistBlock("SCRPED")			
				cText := ExecBlock( "SCRPED" , .F., .F., {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal         	
			EndIf

		ElseIf lRPS //RPS (Recibo Provisorio de Servico)

			If ExistFunc("LJSCRPS")			
				cText := LJSCRPS( {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal
			ElseIf ExistBlock("SCRRPS")			
				cText := ExecBlock("SCRRPS", .F., .F., {"",STBFactor()[2]} ) //No array, elem. 2, fator do comprovante não-fiscal
			EndIf

		EndIf
		
		cText := StrTran( cText, ',', '.' )                                    
		
		// Se não tiver item fiscal na venda não multiplica total (L1_VLRLIQ) pelo fator fiscal/não-fiscal
		If Empty(STDGPBasket( "SL1" , "L1_DOC"))
			cValue := Str(( oTotal:GetValue("L1_VLRTOT")) , 15 , 2 )
		Else
			cValue := Str(( oTotal:GetValue("L1_VLRTOT") * STBFactor()[2] ) , 15 , 2 )
		EndIf
			
		/*/
			Imprime Não Fiscal
		/*/                                                                                                        
		aPrinter := STFFireEvent(	ProcName(0)				, ;
										"STSalesOrder" 			, ; 
										{	cUseTef				, ;
											cText					, ;
											cValue					, ;
											cPayTef				} )
											
		If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 
			lContinue := .F.		
		EndIf							
					
		/*/
			Pega o numero do Comprovante Nao Fiscal
		/*/
		If lContinue		
			aPrinter := STFFireEvent( ProcName(0) , "STGetReceipt" , aCupom )		
			If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aCupom) < 1
				If lPedido  //Pedido
					MsgStop(STR0001) // "Erro ao pegar o número do cupom após a impressão do pedido. Verifique o ECF."
				ElseIf lRPS //RPS (Recibo Provisorio de Servico)
					MsgStop(STR0009) // "Erro ao pegar o número do cupom após a impressão do comprovante RPS (Recibo Provisório de Serviço). Verifique o ECF."
				EndIf
				lContinue 	:= .F.
			Else
				cCupom := aCupom[1]
			EndIf 
		EndIf 
		
		//------------------------------------------------------------------------------------------------------
		cCupom := StrZero( Val(cCupom) - 1 , Len(AllTrim(cCupom)) , 0 )
		
		//Se a impressão do comprovante não foi um relatório gerencial, então pode-se alterar                  
		//a variável cNumCupom. Sem esta validação, poderá causar um erro de chave duplicada no Banco de Dados,
		//pois o número título financeiro poderá se repetir.                                                   
		
		// TODO: Verificar
		/*
		If !lRelGer .OR. Val(cValor) == 0
			If STFGetCfg("lEcfArg")
				cNumCupom:=StrZero(Val(cNumCupom)-1,Len(AllTrim(cNumCupom)) ,0)
			EndIf
		EndIf
		*/      
		//--------------------------------------------------------------------------------------------------------
		
		/*/
			Get PDV
		/*/
		If lContinue
			aPrinter := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )		
			If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aPDV) < 1     
				If lPedido  //Pedido
					MsgStop(STR0002) // "Erro ao pegar o número do PDV após a impressão do pedido. Verifique o ECF."
				ElseIf lRPS //RPS (Recibo Provisorio de Servico)
					MsgStop(STR0010) // "Erro ao pegar o número do PDV após a impressão do comprovante RPS (Recibo Provisório de Serviço). Verifique o ECF."
				EndIf
				lContinue 	:= .F.
			Else
				cPDV := aPDV[1]
			EndIf 
		EndIf
		
		If lContinue
			
			aRet := { .T. , cCupom , cPDV }
		 	
		 	//Verifica se é vale presente:
		 	lIsValePres := iIf(FindFunction("STDExistVP"),STDExistVP(),.F.)
		 	
		 	/*/
		 		Atualiza Cesta
		 	/*/
			If lPedido .Or. lIsValePres  //Pedido
			 	cSerie := STFGetStat("SERIE")

			 	STDSPBasket( "SL1" , "L1_DOCPED"	, cCupom	)
			 	STDSPBasket( "SL1" , "L1_SERPED"	, cSerie	)
			 	STDSPBasket( "SL1" , "L1_SITUA"		, "00"		)
			 	/* 	Se o campo L1_DOC estiver vazio, entao deve-se limpar o campo L1_SERIE
			 		melhoria: o campo L1_SERIE só deve ser preenchido quando a venda for fiscal	*/
			 	If lPedido .AND. !STBExistItemFiscal()
			 		STDSPBasket( "SL1", "L1_DOC", "" )
			 		STDSPBasket( "SL1", "L1_SERIE", "" )
			 	EndIf
			ElseIf lSFinanc .AND. lFindExist //Serviço Financeiro a avulso
				cSerie := STFGetStat("SERIE")
				
			 	STDSPBasket( "SL1" , "L1_DOCRPS", cCupom	)
			 	STDSPBasket( "SL1" , "L1_SERRPS", cSerie	)
			 	STDSPBasket( "SL1" , "L1_SITUA"	, "00"		)
			 	 	
			ElseIf lRPS  //RPS (Recibo Provisorio de Servico)
			 	cSerie := SuperGetMv("MV_LOJARPS",,"RPS")			// Serie da NF de Servico RPS configurada no parametro MV_LOJARPS

			 	STDSPBasket( "SL1" , "L1_SERRPS"	, cSerie	)	// Numero de serie da nota fiscal de servico (RPS)
			 	STDSPBasket( "SL1" , "L1_SITUA"		, "00"		)
			 	
				LjCheckRPS(STDGPBasket("SL1","L1_NUM"),@lTemItProd,@lTemItServ)
				lOnlyServ := lTemItServ .And. !lTemItProd .And. !Empty(cSerie)	 //Se a variavel "cSerRPS" nao esta vazia eh pq a venda possui apenas itens de "servico"			 	
			 	If lOnlyServ 
					STDSPBasket( "SL1" , "L1_DOC"	, ""				)
					STDSPBasket( "SL1" , "L1_SERIE"	, ""				)
					STDSPBasket( "SL1" , "L1_DOCRPS", cCupom			)			 	
			 	ElseIf Empty(STDGPBasket( "SL1" , "L1_DOC")) 			//Se DOC estiver vazio é porque na venda só tem produtos de servico (RPS)
					STDSPBasket( "SL1" , "L1_DOC"	, cCupom	)
					STDSPBasket( "SL1" , "L1_SERIE"	, cSerie	)
					STDSPBasket( "SL1" , "L1_DOCRPS", cCupom	)
			 	EndIf
			EndIf
			
		 Else
		 	aRet := { .F. , "" , "" }
		 EndIf
		
	Else	
	   	aRet := { .F. , "" , "" }	   	
   	EndIf		

Else	
	aRet := { .T. , "" , "" }		
EndIf
	        	
Return aRet


//-------------------------------------------------------------------
/* {Protheus.doc} STBValPrintNotFiscal
Adiciona valor no totalizador não fiscal

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet			Retorna se pode imprimir o cupom nao fiscal
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBValPrintNotFiscal(cOpc)
                                                                     
Local lRet	   			:= .T.				// Retorno da função
Local aRet				:= {}				// Armazena Retorno da impressora
Local aIsOpenReceipt   	:= { "5" , "" }		// Armazena retorno se o cupom está aberto

Default cOpc 			:= ""


/*/
	Valida Data/Hora
/*/
aRet := STFFireEvent( 	ProcName(0)	   		,; // Nome do processo
   							"STCheckDate"			,; // Nome do evento
							{} 			   			)	
												
If Len(aRet) > 0 .AND. ValType(aRet[1]) == "L" .AND. aRet[1]
	lRet := .T.
Else
	lRet := .F.
	MsgStop(STR0003)	// TODO //"Impossível continuar impressão. Ajustar Data/Hora da impressora."
EndIf
 

/*/
	Verifica cupom aberto
/*/	
If lRet
	aRet := STFFireEvent( 	ProcName(0)					   		,; // Nome do processo
   								"STPrinterStatus"						,; // Nome do evento
					   			aIsOpenReceipt	  					)
					
	If Len(aIsOpenReceipt) >= 2 .AND. ValType(aIsOpenReceipt[2]) == "N"						    
		If aIsOpenReceipt[2] == 7
	 		nRet := IFCancCup( nHdlECF ) // TODO: Criar evento cancelamento
			If Lj7VerCmd( nRet ) // TODO: Mudar para <> 0
				/*/
					Espera um tempo para a impressora fazer a impressao do cancelamento
				/*/
				Inkey(8)
			EndIf
		EndIf
	EndIf
EndIf


/*/
	Valida RdMake Impressao
/*/
If lRet
	If Empty(cOpc) .Or. cOpc == "PED" 
		If !ExistBlock("SCRPED") .AND. !ExistFunc("LJSCRPED")
			MsgStop(STR0004) //"O rdmake SCRPED.PRW não está compilado e não será possível imprimir o comprovante de venda. Informe essa mensagem ao administrador do sistema."	  
			lRet := .F.
		EndIf
	ElseIf cOpc == "RPS"
		If !ExistBlock("SCRRPS") .AND. !ExistFunc("LJSCRPS")
			MsgStop(STR0011) //"O rdmake SCRRPS.PRW não está compilado e não será possível imprimir o comprovante RPS (Recibo Provisório de Serviço). Informe essa mensagem ao administrador do sistema."	  
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCheckFiscalItens
Verifia se cupom fiscal está aberto e se eistem itens fiscais para o cupom.
Se o cupom estiver aberto mas não existir itens, cancela o cupom.

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet - Successful Check
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCheckFiscalItens()

Local oTotal		:= STFGetTot() 	// Totalizador
Local cNumDoc		:= "" 			//Numero do CF
Local cSupervisor 	:= ""
Local lRet 			:= .T. 			//Execução com sucesso  - realiza o prosseguimento da venda

If STWGetIsOpenReceipt() .AND. !( STBExistItemFiscal(.F.) )	.AND. ( oTotal:GetVaLue("L1_NOTFISCAL") > 0 )
	/*/
		Cancela o Cupom Fiscal, pois os itens registrados no cupom fiscal foram cancelados
	/*/

	//Envia o comando de cancelamento do cupom fiscal
	
	cNumDoc := STDGPBasket( "SL1" , "L1_DOC")	
	
	
	lRet := STBCSCancCupPrint( cSupervisor , cNumDoc )
	
	If lRet
		STWSetIsOpenReceipt( .F. )
	EndIf
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBExistItemFiscal
Verifia se existe item fiscal na venda

@param	  lDeleted - Não Verifica registros deletados (.t.)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lExist				Retorna se existe item fiscal na venda
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBExistItemFiscal(lDeleted)

Local lExist			:= .F.									// Retorno função
Local aLines      := FwSaveRows()	
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

Default lDeleted := .T. //Considera registros deletados (default)

For nI := 1 To oModelItens:Length()

	oModelItens:GoLine(nI)

	If (!oModelItens:IsDeleted()  .or. lDeleted) .AND. oModelItens:GetValue("L2_FISCAL")

		lExist := .T.
		Exit

	EndIf

Next nI

FwRestRows(aLines)

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} STBExistNItemFiscal
Verifia se existe item não-fiscal na venda

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lExist				Retorna se existe item não-fiscal
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBExistNItemFiscal()

Local lExist			:= .F.									// Retorno função
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

For nI := 1 To oModelItens:Length()

	If !oModelItens:GetValue( "L2_FISCAL" , nI )

		lExist := .T.
		Exit

	EndIf

Next nI

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIANotFiscal
Imprime Cupom não-fiscal de Doação
@param nDoacao		Total da doação
@param
@author  Varejo
@version P11.8
@since   25/10/2013
@return
@obs     
@sample
/*/
*/
//-------------------------------------------------------------------
Function STBIANotFiscal( nDoacao, cSerie, cDoc, cCliente,;
									 cLojaCli, cCPFCli, cFormPg )

Local cTickForm									// Texto do cupom não-fiscal
Local cFormaPgto 	 := ""							// Ler qual cond. pagto. no Sigaloja.ini
Local cTotalizNFis := ""							// Ler qual totalizador no Sigaloja.ini
Local lRetorno     := .T.                    // Retorna se a impressão foi efetuada com sucesso
Local lRecNaoFis := (nModulo == 5 .OR. nModulo == 6) .OR.;	//Recebimento pelo Venda Direta
			 		((nModulo == 12 .OR. nModulo == 23) .AND. ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe())	//Recebimento pelo Loja/Front com NFC-e
			 															//Sinaliza recebimento por modulo não fiscal(sem ECF) *NFC-e, Venda Direta
Local cMsgComprovante	:= ""					//Mensagem para Comprovante, se NFC-e ou SAT
Local lGuil				:= ""					//Ativa guilhotina

Default nDoacao := 0								//Parâmetro do valor da doação
Default cSerie	:= ""							//Serie
Default cDoc		:= ""							//Documento
Default cCliente	:= ""							//Código do Cliente
Default cLojaCli	:= ""							//Loja do Cliente
Default cCPFCli	:= ""							//CPF/CNPJ do Cliente
Default cFormPg	:= ""							//Forma de Pagamento

If lRecNaoFis		//Se NFC-e ou SAT

	lGuil				:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
	cMsgComprovante := Lj950TxtIA(nDoacao, cSerie, cDoc, cCliente,;
											 cLojaCli, cCPFCli, cFormPg)	
	nRet := STWPrintTextNotFiscal(cMsgComprovante)
	lRetorno := (nRet = 0)
		
	If lGuil .AND. lRetorno
		STWPrintTextNotFiscal(TAG_GUIL_INI+TAG_GUIL_FIM)
	EndIf

Else		//Se ECF, entrará no STBIAPrinReceipt(), com funçoes específicas somente para o SIGAFRT.

	cFormaPgto 	 := GetPvProfString("Instituto Arredondar", "FormaPgto", " ", ARQLJINI )	// Ler qual cond. pagto. no Sigaloja.ini
	cTotalizNFis := GetPvProfString("Instituto Arredondar", "Totalizador", "01", ARQLJINI )  // Ler qual totalizador no Sigaloja.ini
	// cTickform é a descrição do texto.
	cTickForm := STR0012 + chr(10) + chr(13);	//"DOAÇÃO - INSTITUTO ARREDONDAR"
					+ STR0013 + chr(10) + chr(13);	//"CNPJ 14.416.996/0001-25"
					+ STR0014							//"www.arredondar.org.br"
					
	/*
		A impressora deverá estar cadastrada como:
		Forma de Pagamento: A VISTA ou RECEBER, ou o código cadastrado de um deles
		Totalizador não-fiscal: DOACAO
	*/
	lRetorno := STBIAPrinReceipt( cFormaPgto, nDoacao, cTotalizNFis, cTickform )

EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIAPrinReceipt
Imprime o Cupom não-fiscal.

@param  cFormaPagto , Caractere , Forma de Pagamento cadastrado no ECF.
@param  nValor      , Numérico  , Valor.
@param  cTotalizador, Caractere , Totalizador cadastrado no ECF para cupom não-fiscal.
@param  cTexto      , Caractere , Texto informativo livre.
@param  nParcelas   , Numérico  , Número de Parcelas

@author  Varejo
@version P11.8
@since   25/10/2013

@return lImprimiu, Lógico, Retorna se imprimiu com sucesso (.T.) ou não (.F.)
/*/
//-------------------------------------------------------------------
Function STBIAPrinReceipt(cFormaPgto, nValor, cTotalizador, cTexto, nParcelas)

Local lContinua     := .F. //Laco de continuidade do processo
Local lReimprime    := .F. //Indicação de reimpressão do comprovante 
Local lImprimiu     := .F. //Impressão do comprovante com sucesso?
Local aRet	        := {}  //Retorno do ECF
	
Default cFormaPgto  := ""
Default nValor      := 0
Default cTotalizador:= ""
Default cTexto      := ""
Default nParcelas   := Nil
	
lContinua := .T.
Do While lContinua  

	//Abre cupom fiscal não vinculado
	
	aRet :=	STFFireEvent(	ProcName(0)	,;		         // Nome do processo
				            "STOpenNotFiscalReceipt",;
				            {cFormaPgto,;
					        Alltrim(Str(nValor,14,2)),;  //totalizar nformas de pagamento
					        cTotalizador,;
					        cTexto,;
					        nParcelas} )
					
	If !STBIAVerifyPrint(aRet, @lReimprime ) 
	//Erro de Impressao e pode reimprimir OU USUÁRIO NÃO TEM PERMISSÃO PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
						
		If lReimprime
			Loop
		Else
			lContinua := .F.    
		EndIf

	EndIf 
					
	If !lContinua
		Loop
	Endif
					
	//bufferizar as linhas do comprovante e enviar conforme contador   
	aRet := STBIAPrinTxtFisc(@cTexto)
					
	If !STBIAVerifyPrint(aRet, @lReimprime ) 
	//Erro de Impressao e pode reimprimir OU USUÁRIO NÃO TEM PERMISSÃO PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
						
		If lReimprime
			Loop
		Else
			lContinua := .F. 
		EndIf
								                
	EndIf 
					
	If !lContinua
		Loop
	Endif
	InKey(2)
			
	aRet := 	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
				  		"STCloseNotFiscalReceipt",;
						{})
										
	If !STBIAVerifyPrint(aRet, @lReimprime ) 
		//Erro de Impressao e pode reimprimir OU USUÁRIO NÃO TEM PERMISSÃO PARA CANCELAR  //LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !LjSenSupTEF())
		If lReimprime
			Loop
		Else
			lContinua := .F. 
		EndIf
	Else 
		lImprimiu := .T.
		lContinua := .F. 
	EndIf 
					
	If !lContinua
		Loop
	EndIf

End
	
Return lImprimiu   

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIAVerifyPrint
Verifica o status da impressão
@param 	aRet			Retorno do Array
@param 	lReimprime		Permissão de reimpressão 
@author  Varejo
@version P11.8
@since   25/10/2013
return  lImprime
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIAVerifyPrint(aRet, lReimprime )

Local lImprime 		:= .T.      //Impressão com sucesso?
Local nOpt 			:= 2        //Opção selecionada pelo usuário
Local lTentaTiva 	:= .T.      //controle de tentativa

Default lReimprime := .F.    //Reimprime o cupom?
	
If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impressão  
	
	//Erro na Impressão - Trata a mensagem
	lImprime := .F.

	While lTentaTiva 
							
		STFMessage("IA_Imprime", "YESNO", STR0005 + " " + STR0006) //"Impressora não responde."#"Deseja imprimir novamente?"
		nOpt := If(STFShowMessage("IA_Imprime"),2,0) 
			
		//2=SIM
		If nOpt == 2
			
			Sleep(1000)
				
			aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
										"STCloseNotFiscalReceipt"													,;		// Nome do evento
										{""} )  
			
			If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impressão				
				lTentaTiva := .T.
			Else
				lTentaTiva := .F.	
				lReimprime := .F.
			EndIf
			
		Else				
			lTentaTiva := .F.					
		EndIf	
	
	EndDo
										
	If nOpt == 2 // .OR. !Self:ReimpSenSup()  //Superior não digitou senha para desfazer a transacao
		lReimprime := .T. 
		STFMessage("IA", "RUN", STR0007)  //"Aguarde a impressão do comprovante não fiscal...." 
		STFShowMessage("IA")
	EndIf

Else
	If ValType(aRet) <> "A"
		STFMessage("IA_Imprime", "ALERT", STR0008)  //"Problemas com a Impressora Fiscal"
		STFShowMessage("IA_Imprime") 				
	EndIf
EndIf
	
Return lImprime 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIAPrinTxtFisc
Retorna o texto do cupom não fiscal
@param	cTexto					Texto Informativo
@author  Varejo
@version P11.8
@since   25/10/2013
@return  aRet
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIAPrinTxtFisc(cTexto)

Local aRet := {0}  //Array de Retorno

Default cTexto := ""			// Texto livre
	
aRet := STFFireEvent(	ProcName(0)				,;		// Nome do processo
							"STTxtNotFiscalReceipt",;
							{cTexto,;
									 1})	   

Return aRet       

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTemEntr
Verifia se tem item de "Entrega" ou "Retira Posterior".

@param
@author  Varejo
@version P11.8
@since   25/08/2015
@return  lExist				Retorna se tem item de "Entrega" ou "Retira Posterior".
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBTemEntr()
Local lExist			:= .F.									// Retorno função
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

For nI := 1 To oModelItens:Length()
	
	If !oModelItens:IsDeleted()
		If (!Empty( oModelItens:GetValue("L2_RESERVA", nI) ) .And. oModelItens:GetValue("L2_ENTREGA", nI) <> "2") .OR.;//2=Retira
			(Empty( oModelItens:GetValue("L2_RESERVA", nI) ) .And. oModelItens:GetValue("L2_ENTREGA", nI) == "5") // 5= ENTREGA C/ PEDIDO S/ RESERVA
			lExist := .T.
			Exit
	
		EndIf
	EndIf

Next nI

Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTemServ
Verifia se tem item de "Servico".

@param
@author  Varejo
@version P11.8
@since   25/08/2015
@return  lExist				Retorna se tem item de "Servico".
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBTemServ()
Local lExist			:= .F.									// Retorno função
Local oModelCesta		:= STDGPBModel()						// Armazena model da cesta
Local oModelItens		:= oModelCesta:GetModel("SL2DETAIL")	// Model Itens
Local nI				:= 0									// Contador

For nI := 1 To oModelItens:Length()
	
	If !oModelItens:IsDeleted()
		If oModelItens:GetValue("L2_ENTREGA", nI) == "2" .And. ; //2=Retira
			LjIsTesISS( oModelItens:GetValue("L2_NUM", nI), oModelItens:GetValue("L2_TES", nI) ) //Verifica se eh item de servico
			
			lExist := .T.
			Exit
			
		EndIf
	EndIf

Next nI

Return lExist
