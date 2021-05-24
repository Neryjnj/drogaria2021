#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   
#INCLUDE "STBPAYMENT.CH"

Static cMvEntExce	:= IIF(!Empty(SuperGetMV("MV_ENTEXCE",.F.,'')), "|"+SuperGetMV("MV_ENTEXCE",.F.,'')+"|", '|CC|CD|CH|FI|VA|VP|CO|FID|' )  // Formas de pagamento nao consideradas como entrada (N„o ser· gravado L1_ENTRADA)
Static nEntrada		:= 0 								// Valor de entrada
Static nArredondar	:= 0								// Valor de doaÁ„o para o Instituto Arredondar
Static nDArredondar	:= 0								// Valor de doaÁ„o para o Instituto Arredondar com desconto da taxa adm. se houver
Static nVLBF		:= 0								// Valor da bonificacao 
Static aTotal		:= {}                              	// Array contendo o resumo de pagamento   
Static nContCheque	:= 0								// Contador que controla informaÁ„o do cheque
Static aFormasImp	:= {}								// Formas de pagamentos do orÁamento importado
Static lMFE			:= IIF( ExistFunc("LjUsaMfe"), LjUsaMfe(), .F. )		//Se utiliza MFE
Static lLjRspFisc	:= ExistFunc("LjRspFisc")
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRetCup
Retorna o numero do cupom

@author  	Varejo
@version 	P11.8
@since   	20/02/2013
@return  	cCupom - Numero do cupom	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRetCup()

Local aDados 	:= {Space(6), Nil}
Local cCupom	:= ""   
Local cSerie :=  ""
Local aAreaSL1 := {} 
Local cDoc := 0
Local cFilSl1	:= ""
Local nTamDoc  := 0

If	STFGetCfg("lUseECF")
	
	aRet := STFFireEvent(ProcName(0), "STGetReceipt", aDaDos)
				
	If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) < 1     
		STFMessage("STIPayment","STOP",STR0014) //"Falha na obtenÁ„o do cupom!"
		STFShowMessage("STIPayment")    
	Else
		cCupom := aDados[1]
	EndIf
Else
	cCupom := STDGPBasket( "SL1" , "L1_DOC" )
	
	
	If AllTrim(cCupom) == "NFCE"
	
		//Busca o ˙ltimo documento emitido
		aAreaSL1 := SL1->(GetArea())
		
		cFilSl1	:=  xFilial("SL1")
		nTamDoc  := SL1->(TamSx3("L1_DOC"))[1]
		cSerie :=   STDGPBasket("SL1", "L1_SERIE")
		cDoc := Replicate("Z",nTamDoc)
		cCupom := StrZero(0, nTamDoc)

		DbSelectArea("SL1")
		SL1->(DbSetOrder(2)) //L1_FILIAL + L1_SERIE + L1_DOC + L1_PDV
		SL1->(DbSeek(cFilSl1 + cSerie + cDoc, .T.)) 
		
		If !SL1->(Eof())
			SL1->(DbSkip(-1))
			Do While  !SL1->(Eof()) .AND.  SL1->(L1_FILIAL+L1_SERIE) == cFilSl1+cSerie .AND. AllTrim(SL1->L1_DOC) == "NFCE"
				SL1->(DbSkip(-1))
			EndDo
			cCupom := SL1->L1_DOC 
			LjGrvLog("", "STBRetCup - Ultimo documento encontrado", {cCupom, cSerie})
		EndIf
		 
		nTamDoc := Len(AllTrim( cCupom )) 

		cCupom := StrZero( Val(cCupom) + 1 , nTamDoc) 
		
		RestArea(aAreaSL1) 
		//cCupom := StrZero(Randomize(1,999999),6,0)
		LjGrvLog("", "STBRetCup - Numero temporario de documento ", cCupom)
	Else
	
		If Empty( cCupom )
			cCupom := AllTrim( STDGPBasket("SL1", "L1_NUM") + STDGPBasket("SL1", "L1_PDV") )
		EndIf
	EndIf

EndIf

Return cCupom

//-------------------------------------------------------------------
/*/{Protheus.doc} STBConfPay
Confirmacao dos pagamentos

@param   	oMdlGrd - Grid do Model 
@param   	aPaym	- Array de pagamentos
@param   	oMdlPaym - Grid do Model de Pagamentos
@author  	Varejo
@version 	P11.8
@since   	06/02/2013
@return  	lRet - Se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBConfPay(oMdlGrd, aPaym,oMdlPaym)

Local oTotal		:= STFGetTot() 											//Recebe o objeto do model para recuperar os valores
Local lRet 			:= .T.													//Variavel de retorno
Local nI			:= 0													//Variavel de loop
Local oTEF20		:= IIF(ValType(STBGetTef()) == 'O', STBGetTef(), STBGetChkRet())//Objeto do TEF ativo
Local lRecebTitle	:= STIGetRecTit()										//Retorna se e recebimento de titulo ou nao
Local oWFReceipt	:= STIRetObjTit()										//Retorna o objeto da classe do recebimento de titulo
Local aValPre		:= IIF(FindFunction("STBGetCodVP"),STBGetCodVP(), {}) 	//Carrega o codigo do vale presente
Local uResult		:= Nil													//Retorno do STBRemoteExecute de vale presente
Local lRetSTConfVen := .T.													//Retorno do ponto de entrada
Local lFinServ    	:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.) 	//Define se habilita o controle de servicos financeiros
Local lPrintServ	:= .F.													//Verifica se imprime servicos financeiros
Local lRMS 			:= SuperGetMv("MV_LJRMS",,.F.)							//Integracao com RMS 
Local aMdlParc		:= {} 
Local cDoc			:= ""													//numero do documento
Local cSerie		:= ""													//serie do pdv
Local cEstacao		:= ""													//numero da estaÁ„o
Local cPDV			:= AllTrim(STDGPBasket("SL1" , "L1_PDV"))				//Numero do pdv
Local cHora			:= ""													//hora da venda
Local cVend			:= ""													//codigo da venda
Local cCliente		:= ""													//codigo do cliente
Local cLoja			:= ""													//codigo da loja
Local dData			:= cToD("  /  /  ")										//data da venda
Local nCount		:= 0													//contador
Local cTextScrPed	:= "" 													//Texto Relatorio gerencial
Local lVendTpCard	:= .F.  												//ValidaÁ„o venda com cart„o
Local aCupom		:= {Space(6), Nil}										// Retorno Evento GetCupom
Local cCupom		:= ""													// Retorno n˙mero do Cupom   
Local aPrinter		:= {}													// Armazena Retorno da impressora
Local lIsImpOrc 	:= If(FindFunction("STBIsImpOrc"),STBIsImpOrc(),(!(Empty(STDGPBasket("SL1","L1_NUMORIG"))))) //Verifica se È importaÁ„o de orÁamento
Local lMVLJPRDSV   	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) 					// Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas (RPS)
Local lRPS 			:= lMVLJPRDSV .And. lIsImpOrc .And. STBTemServ() .and. !STBTemEntr() // Verifica se tem item de "Servico" e nao tem item de Pedido (Caso tenha item de pedido desconsidera o tratamento para RPS)
Local cL1_SEND		:= ""
Local nSendOn		:= SuperGetMV("MV_LJSENDO",,0) 							//Retorno como sera a integracao da venda - 0 - via job - 1 online - 2 startjob
Local lEmitNfce		:= LjEmitNFCe()										 	//Sinaliza se utiliza NFC-e
Local lTefOk		:= .F. 													//ValidaÁ„o se o Tef foi aprovado
Local lFinish		:= .F. 													//ValidaÁ„o se a venda foi finalizada com sucesso
Local aMdlHeader	:= {}													//Variavel aHeader para o Ponto de entrada STConfSale
Local cNumOrig		:= AllTrim(STDGPBasket( "SL1" , "L1_NUMORIG" ))			//Numero de origem do orcamento
Local aRetFile		:= {}
Local cMoedaSimb    := SuperGetMV( "MV_SIMB"+Str(STBGetCurrency(), 1) )		//Simbolo da moeda corrente
Local lPendSale		:= .F.													//Se FinishSale retornar .F., indica se a venda fica em aberto
Local cDocCliSL1	:= ""													//Retorna o L1_CGCCLI
Local aCustomer		:= {}													//Carrega informacoes do cliente Nome/Cpf 
Local nCallCPF		:= SuperGetMV("MV_LJDCCLI",,0)							//O momento onde ser· mostrado o CPF na tela
Local lRetImpTef 	:= .T.													//Variavel de retorno impressao TEF
Local aDocSerie		:= {}													//Armazeno o doc e sÈrie apÛs processar o STWFinishSale()
Local cL1_Filial	:= ""
Local aNotas        := {}
Local lLGSerNFis    := SLG->(ColumnPos("LG_SERNFIS")) > 0
Local aPayment		:= {}   												//array com os pagamentos informados
Local nX			:= 0   													//contador
Local nY			:= 0   													//contador
Local lVendPed 		:= .F.													//Varialvel de controle para gravaÁ„o do L1_doc ou DOCPED
Local lIsValePres	:= .F.													//Verifica se vale presente
Local cTextCred		:= ""													//Texto comprovante de credito
Local lImpCompCred  := SuperGetMV("MV_LJIMPCR",,0) == 1						//Define se Imprime comprovante de credito
Local lSTConfRec	:= ExistBlock("STConfRec")								//Verifica se existe o ponto de entrada STConfRec
Local lSTConfSale	:= ExistBlock("STConfSale")								//Verifica se existe o ponto de entrada STConfSale
Local lExistSer 	:= .F. 													//Verifica se existe a Serie N„o Fiscal
Local lIntegrador 	:= IIF( ExistFunc("LjUsaIntgr"),LjUsaIntgr(), .T.)		//Se utiliza MFe com Integrador
Local lUseSat		:= LjUseSat()											//Verifica se È SAT
Local aParamsImp	:= {}													// Par‚metros para impress„o do comprovante
Local aParams		:= {}													// Par‚metros para a o RDMake de impress„o
Local lLjVpCnf		:= SuperGetMV("MV_LJVPCNF",,.F.) 						//verifica se imprime vale presente no cupom fiscal													// Par‚metros para a o RDMake de impress„o
Local aDadosCli		:= Iif(ExistFunc("STBGetCrdIdent"),STBGetCrdIdent(),{}) //Dados do Cart„o/CPF do cliente (IntegraÁ„o CRD)

Default oMdlGrd		:= Nil
Default aPaym		:= {}
Default oMdlPaym	:= Nil

If lSTConfSale .OR. lSTConfRec

	If oMdlGrd <> NIL
		aMdlParc	:= STBRPayaCols(oMdlGrd)		//Parametro com o aCols do Grid
		aMdlHeader	:= oMdlGrd:GetOldData()[1]	// Parametro com o aHeader do Grid
	EndIf 	

	If oMdlPaym <> Nil .And. Len(aMdlHeader) > 0
		For nX := 1 to oMdlPaym:Length()
			oMdlPaym:GoLine(nX)
			If lRecebTitle 
				If nX == oMdlPaym:Length()
					STBGrvTroco(oMdlPaym,nX, .T.)
				Else
					STDSPBasket("SL4","L4_TROCO",0,nX)
					oMdlPaym:LoadValue("L4_TROCO",0)
				EndIf
			EndIf

			aAdd( aPayment, {} )
			For nY := 1 to Len(aMdlHeader)
				aAdd( aPayment[nX],{aMdlHeader[nY][2], oMdlPaym:GetValue(aMdlHeader[nY][2])} )
			Next nY	
		Next nX	
	EndIf

	If lSTConfSale
		LjGrvLog( NIL , "Antes da execuÁ„o do PE STConfSale",{aMdlParc,aMdlHeader,lRecebTitle,oWFReceipt,aPayment})
		lRetSTConfVen := ExecBlock("STConfSale",.F.,.F.,{aMdlParc,aMdlHeader,lRecebTitle,oWFReceipt,aPayment})
		LjGrvLog( NIL , "Depois da execuÁ„o do PE STConfSale",lRetSTConfVen)
	EndIf
EndIf

If lRetSTConfVen .And. !Empty(cNumOrig) //Verifica se o orÁamento ja foi importado
	//Verifica se o arquivo j· existe na retaguarda
	aRetFile := STBCtrImpOrc( cNumOrig , cPdv , .T., .T. )

	//se existir, nao permite finaliza-lo
	If Len(aRetFile) > 0  
		If aRetFile[1]
			STFMessage("STBPayment","STOP", STR0023) //"N„o È possÌvel finalizar a venda, este orÁamento j· foi finalizado por outro PDV." 
			STFShowMessage("STBPayment")
			lRetSTConfVen := .F.
		EndIf
	EndIf

EndIf

If ValType(lRetSTConfVen) == 'L' .AND. lRetSTConfVen

	If !lRecebTitle

		/* Seta para .F. a variavel que controla se È P.O.S */
		STISetContTef(.F.)
		/*
			Verifica se Todos os Itens do Cupom Fiscal foram cancelados. Caso afirmativo cancela o CF
		*/
		lRet := STBCheckFiscalItens()
		
		//ImplementaÁ„o antiga da rotina - retornava nil
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf
		
		If lRet
		
			/*
				Imprime os cheques
			*/
			If STBGetCheck()
			
				STWPayCheck()
				
			EndIf
			
			/* 
				Verificar se o cliente deseja doar para o Instituto Arredondar
				
			*/
			If oMdlGrd:GetValue('L4_FORMA') = cMoedaSimb	//Moeda corrente
				STBInsArredondar(AllTrim(oMdlGrd:GetValue('L4_FORMA')))
			EndIf
			
			/* 
				Atualiza a cesta com os pagamentos 
			*/
			STIUpdBask()
			
			//Se existir integracao com a RMS em CRM, executa as funcoes de Set dos pagamentos
			If lRMS .AND. FindFunction("STFSetAuto")
				STFSetAuto()
			EndIf
		
			//Verifico se o L1_CGCCLI est· gravado no objeto, e se escolheu o cliente.
			If lEmitNfce .AND. nCallCPF = 0 .AND. !STIGInfCPF()	//Quando n„o chama o CPF para digitaÁ„o (MV_LJDCCLI=0), gravar· o L1_CGCCLI a partir do A1_CGC escolhido. A funÁ„o STIGInfCPF() garante que passou da tela do CPF ou n„o.
				cDocCliSL1 := STDGPBasket("SL1","L1_CGCCLI")
				If Empty(cDocCliSL1) 
					aCustomer	:= IIF(FindFunction('STDFindCust'),STDFindCust(),{}) //Carrega informacoes do cliente Nome/Cpf				
					If Len(aCustomer) >= 2 .AND. !Empty(aCustomer[2])
						STDSPBasket("SL1","L1_CGCCLI",aCustomer[2])
					EndIf
				EndIf
			EndIf 
			
		EndIf
		
		/*
			Aplica Descontos do TEF
		*/
		
		lVendTpCard := STIGetCard()
		
		If lRet .AND. lVendTpCard
			lRet := STBDescTEF(oMdlGrd, oTEF20, aPaym)	
		EndIf
		
		/*
			Imprime Desconto e AcrÈscimo
		*/
		If lRet
			STBDiscIncrease()							
		EndIf
		
		/* Reorganiza o L2_ITEM */
		STBOrgL2Item()
		
		/*
			Imprime as formas de pagamento
		*/
		If lRet
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Imprime as formas de pagamento" )  //Gera LOG
			lRet := STBPrintPay(oMdlGrd, oTEF20, aPaym)	
		EndIf
		
		/*
			Totalizando e fechando o cupom
		*/
		If lRet
			lRet := STBCloseCup(oTEF20, oTotal)
			
			If lRet
				/*
					Antes de chamar a impressao do pagamento, o L1_SITUA sera mudado para '10' para possibilitar a recuperacao da venda
					caso haja alguma falha (de energia por exemplo) durante a impressao dos pagamentos e comprovante TEF.
					Caso ja esteja com situa = 10 n„o chama novamente para n„o duplicar a SL4
				*/
				If AllTrim(STDGPBasket("SL1","L1_SITUA")) <> "10"
					STDSPBasket( "SL1" , "L1_SITUA", "10" )
					STDSaveSale()
				Else
					LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Situa j· foi definido para 10. Chamada Repetida. " )	
				EndIf	
			EndIf
		EndIf		
		
		If lRet
			/*
				Se a forma de pagamento for VP entao atualiza o status do VP na retaguarda
			*/
			STBBaixaVP(oMdlGrd)
		EndIf
		
		
		If !lRet
			/*/
				Cancela a venda
			/*/
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "ForÁa cancelamento da venda" )  //Gera LOG
			
			STWCancelSale( .T. ) // ForÁa cancelamento 
		Else
			
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Abre a gaveta" )  //Gera LOG
			
			/* Abre a gaveta */
			STBOpenDrawer()
		EndIf
		
		
		If lRet
			
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Cupom n„o fiscal" )  //Gera LOG
			
			/*
				Cupom n„o fiscal
			*/
			
			/* N„o imprime Cupom n„o fiscal antes da execuÁ„o do TEF */ 
			If !lVendTpCard
				lPrintServ := STBPrintNotFiscal()[1]
				If !lPrintServ
					STFMessage("STBPayment","STOP",STR0026) //"Erro na impress„o de comprovante n„o fiscal! "
					STFShowMessage("STBPayment")
					LjGrvLog("L1_NUM: "+cL1_SEND, STR0026 + " -1", cSerie)//"Erro na impress„o de comprovante n„o fiscal! "
					lRet:= .F. 	
				Endif
			EndIf	
			
			/*
				Impressao de comprovante TEF
			*/
			If lRet .AND. (lVendTpCard .OR. STBGetCheck())
				LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Impressao de comprovante TEF" )  //Gera LOG				
		
				/*Pega o numero do Comprovante Nao Fiscal, quando nao possui TEF, DOCPED È atualizado na rotina STBPrintNotFiscal()*/				
				If STBExistNItemFiscal() 
					If !STFGetCfg("lUseECF") //Nao utiliza ECF
					   If lRPS
                            cSerie := SuperGetMv("MV_LOJARPS",,"RPS")
                        Else
                            If lLGSerNFis
                                cSerie := STFGetStation("SERNFIS")
                            Else
                                cSerie := STFGetStation("SERIE")
                            EndIf                                                
                        EndIf
                                                                    
						lExistSer:=	LjxDNota( cSerie, 3, .F., 1, @aNotas )  
						If lExistSer
							cCupom := aNotas[1][2]
						Else
							lRet := .F.
							STFMessage("STBPayment","STOP",STR0024) //"Falha na obtenÁ„o da sÈrie n„o fiscal!"
							STFShowMessage("STBPayment")
							LjGrvLog("L1_NUM: "+cL1_SEND, STR0024 + " -2", cSerie)		//"Falha na obtenÁ„o da sÈrie n„o fiscal!"
						EndIf
				    ElseIf STFUseFiscalPrinter() //Utiliza impressora fiscal
						aPrinter := STFFireEvent( ProcName(0) , "STGetReceipt" , aCupom )		
						If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aCupom) < 1     
							MsgStop(STR0017)	 //"Erro ao pegar o n˙mero do cupom antes da impress„o do comprovante. Verifique o ECF."
						Else
							cCupom := aCupom[1]
							cCupom := StrZero( Val(cCupom)+1, Len(AllTrim(cCupom)) , 0 )														
    						If lRPS
                                cSerie := SuperGetMv("MV_LOJARPS",,"RPS")
                            Else
                                cSerie := STFGetStation("SERIE")
                            EndIf    						    																				
    					EndIf    					    					
					EndIf
					
					If !STBExistItemFiscal()
                        STDSPBasket( "SL1", "L1_DOC", "" )
                        STDSPBasket( "SL1", "L1_SERIE", "" )
                    EndIf
					If lRPS //Tem item de "Servico" (RPS)				          				 						 						 		
				 		STDSPBasket( "SL1" , "L1_DOCRPS", cCupom )
				 		STDSPBasket( "SL1" , "L1_SERRPS", cSerie )
					Else				        				 		
				 		STDSPBasket( "SL1" , "L1_DOCPED", cCupom )
				 		STDSPBasket( "SL1" , "L1_SERPED", cSerie )				        									
			 		EndIf			 					 					 		                   
				EndIf
				
				If lEmitNfce .And. FindFunction("STWFinishValid")
					lTefOk := .T.				
				Else
					lRetImpTef := STWPrintComp(oTEF20)	
					//Se n„o imprimiu TEF, Zera Pagamentos se for apenas nao fiscal	
					If !lRetImpTef .AND. !STBExistItemFiscal() .AND. STBExistNItemFiscal()
						STIZeraPay()
						lRet := .F.						
					EndIf      
				EndIf
			EndIf
			
			/* Imprime RelatÛrio Gerencial caso a venda seja feita com cart„o e possua itens n„o fiscais */
			If lRet .AND. STBExistNItemFiscal() .AND. lVendTpCard

				If lRPS // Tem item de "Servico" (RPS)

					If ExistFunc("LJSCRPS")
						cTextScrPed := LJSCRPS( {"",STBFactor()[2]} )
						STWManagReportPrint(cTextScrPed,1)
					ElseIf ExistBlock("SCRRPS")
						cTextScrPed := ExecBlock("SCRRPS", .F., .F. , {"",STBFactor()[2]} )
						STWManagReportPrint(cTextScrPed,1)
					EndIf

				Else

					If ExistFunc("LJSCRPED")
						cTextScrPed := LJSCRPED( {"",STBFactor()[2] } )
						STWManagReportPrint(cTextScrPed,1)
					ElseIf ExistBlock("SCRPED")
						cTextScrPed := ExecBlock("SCRPED", .F., .F. , {"",STBFactor()[2]} )    
						STWManagReportPrint(cTextScrPed,1)
					EndIf

				EndIf	
				
				lPrintServ := .T.			 			
			EndIf 
			
			/*
				Impressao de relatorio gerencial Garantia Estendida
			*/
			If lRet .AND. lPrintServ .AND. ExistFunc("STWPrintGarEst")
			
				LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Impressao de relatorio gerencial Garantia Estendida" )  //Gera LOG
				
				STWPrintGarEst() 

			EndIf

			/*
				Impressao de relatorio gerencial servicos financeiros
			*/
			If lRet .AND. lFinServ .AND. lPrintServ 
				
				LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Impressao de relatorio gerencial servicos financeiros" )  //Gera LOG
				
				STWPrintServ() 
			
			EndIf
			
			/*
				Verifico se um ShopCard esta sendo utilizado na venda e atualizo o saldo do mesmo.	
			*/
			If lRet .AND. STIShopCard()
			
				For nI := 1 To oMdlGrd:Length()
					If AllTrim(oMdlGrd:GetValue("L4_FORMA")) == "FID"
						lRet := STDUpdShopCardFunds(oMdlGrd,nI)
					EndIf
					If !lRet
						STFMessage(ProcName(),"STOP",STR0001+CRLF+STR0002) //"Nao foi possivel abater do saldo do cartao fidelidade" //"A venda nao podera ser finalizada"
						STFShowMessage(ProcName())	
						STFCleanMessage(ProcName())
						Exit
					EndIf
				Next nI
				
			EndIf
			
			/*
				Impressao do comprovante Brinde
			*/
			If lRet .AND. AliasInDic("MGC")
				STBPrintBrinde()
			Endif
			
			//Impressao do comprovante de crÈdito NCC pela funÁ„o LJRUNSCRCD
			If lRet .AND. lImpCompCred .AND. STDGPBasket("SL1", "L1_CREDITO") > 0  .AND. ( ExistBlock("SCRCRED") .OR. ExistFunc("LJSCRCRED") )

				aParams := {STDGPBasket("SL1", "L1_CREDITO"), STDGetNCCs("1") ,STDGetNCCs("2") , ; 
							STDGPBasket("SL1", "L1_CLIENTE"),STDGPBasket("SL1", "L1_LOJA") }

				If ExistFunc("LJSCRCRED")
					LjGrvLog("LJSCRCRED","Ser· impresso o comprovante de crÈdito do cliente.")
					cTextCred := LJSCRCRED( aParams ) 
				Else
					LjGrvLog("SCRCRED","Ser· impresso o comprovante de crÈdito do cliente.")
					cTextCred := ExecBlock("SCRCRED", .F., .F. , aParams )  
				EndIf						

				If !Empty(cTextCred)
					STWManagReportPrint(cTextCred,1)
				EndIf	
			Endif

			If lRet
				/* Baixa o vale presente */
				If Len(aValPre) > 0

					//Verifico se atualizo o L1_DOC ou o L1_DOCPED
					If Empty(STDGPBasket( "SL1" , "L1_DOC"))
						If !Empty(STDGPBasket( "SL1" , "L1_DOCPED"))
							lVendPed := .T.
						EndIf
					EndIf
										
					If lLjVpCnf //verifica se imprime vale presente no cupom fiscal
						/*Recupera os campos para serem atualizados na retaguarda*/
						//numero do documento
						cDoc 		:= STDGPBasket( "SL1" , "L1_DOC")
						cDoc		:= IIF(!Empty(cDoc) , cDoc, STDGPBasket( "SL1" , "L1_DOCPED"))
						
						//serie do pdv
						cSerie		:= STDGPBasket( "SL1" , "L1_SERIE" 	)
						cSerie		:= IIF(!Empty(cSerie),cSerie, STDGPBasket( "SL1" , "L1_SERPED"))

					Else
						//Verifica se È vale presente:
		 				lIsValePres := IIf(ExistFunc("STDExistVP"),STDExistVP(),.F.) 
						
						If lLGSerNFis
							//Resgato a Serie e numero do DOC atual
							cSerie := STFGetStation("SERNFIS")														
							
							If lIsValePres
								cDoc   := STDGPBasket("SL1", "L1_DOCPED")
								cSerie := IIF(!Empty(cSerie),cSerie, STDGPBasket( "SL1" , "L1_SERPED"))
							EndIf
							
							//Se nao encontrou Doc, busca nova numeracao
							If Empty(cDoc)
								lExistSer:=	LjxDNota( cSerie, 3, .F., 1, @aNotas )  
								If lExistSer
									cDoc := aNotas[1][2]
								Else
									lRet := .F.
									STFMessage("STBPayment","STOP",STR0024) //"Falha na obtenÁ„o da sÈrie n„o fiscal!"
									STFShowMessage("STBPayment")
									LjGrvLog("L1_NUM: "+cL1_SEND, STR0024 + " -3", cSerie)		//"Falha na obtenÁ„o da sÈrie n„o fiscal!"
								EndIf
							EndIf
						Else
							/*Recupera os campos para serem atualizados na retaguarda*/
							//numero do documento
							cDoc 		:= STDGPBasket( "SL1" , "L1_DOC")
							cDoc		:= IIF(!Empty(cDoc) , cDoc, STDGPBasket( "SL1" , "L1_DOCPED"))
							
							//serie do pdv
							cSerie		:= STDGPBasket( "SL1" , "L1_SERIE" 	)
							cSerie		:= IIF(!Empty(cSerie),cSerie, STDGPBasket( "SL1" , "L1_SERPED"))
						EndIf
					EndIf
					
					If lRet
						//Atualizo a cesta 
						If lVendPed .Or. lIsValePres 
				
							STDSPBasket("SL1","L1_SERPED",cSerie)
							STDSPBasket("SL1","L1_DOCPED",cDoc)
							
							If lIsValePres .AND. !lLjVpCnf
								For nX := 1 To STDPBLength("SL2")
									STDSPBasket( "SL2" , "L2_DOCPED" , cDoc , nX)
									STDSPBasket( "SL2" , "L2_SERPED" , cSerie , nX)			
									STDSPBasket( "SL2" , "L2_DOC" , cDoc , nX)
									STDSPBasket( "SL2" , "L2_SERIE" , cSerie , nX)								
									STDSaveSale(nX)
								Next nX
							Endif 
				
						EndIf
						STDSPBasket("SL1","L1_SERIE",cSerie)
						STDSPBasket("SL1","L1_DOC",cDoc)
					
						cEstacao	:= STDGPBasket( "SL1" , "L1_ESTACAO" 	)//numero da estacao
						cPDV		:= STDGPBasket( "SL1" , "L1_PDV" 		)//numero do pdv
						dData		:= STDGPBasket( "SL1" , "L1_EMISNF"	)//data da venda
						cHora		:= SUBSTR(TIME(), 1, 5)//hora da venda
						cVend		:= STDGPBasket( "SL1" , "L1_VEND"		)//numero da venda
						cCliente	:= STDGPBasket( "SL1" , "L1_CLIENTE"	)//codigo do cliente
						cLoja		:= STDGPBasket( "SL1" , "L1_LOJA"		)//codigo da loja
			
						FOR nCount := 1 To Len(aValPre)
							/*Da baixa no vale presente na retaguarda */
							MsgRun(STR0020,STR0021,{|| ; //"Executando as devidas configuraÁıes do Vale Presente/CrÈdito na retaguarda" ##"Aguarde....."
								STBRemoteExecute("STBBaixaPr" ,{	aValPre[nCount] 	, STBGetVlrVP()	, cDoc		, cSerie,;
										  							cEstacao			, cPDV			, dData		, cHora	,;
										  							cVend				, cCliente		, cLoja		}, NIL,.T.,@uResult)})
						NEXT nCount
								  							
						//Zera array codigos vale presentes
						If ExistFunc("STBSetCodVP")
							STBSetCodVP()					
						EndIf
						//Zera array dos valores vale presentes
						If ExistFunc("STBSetVlrVP")
							STBSetVlrVP()
						EndIf
					EndIf						
				EndIf				
				
				If lRet .AND. lUseSat
					STBGrvSatT()		//Prepara as informaÁıes de impostos PIS, Cofins, CST etc. para XML SAT
				EndIf

				If lRet
					LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Finaliza venda" )  //Gera LOG
					
					cL1_Filial	:= STDGPBasket('SL1','L1_FILIAL')       //Numero L1 para envio online para retaguarda
					cL1_SEND 	:= STDGPBasket('SL1','L1_NUM')       //Numero L1 para envio online para retaguarda
					cEstacao	:= STDGPBasket( "SL1" , "L1_ESTACAO")//numero da estacao para envio online para retaguarda 
					
					/*
						Finaliza a venda
					*/
					lFinish := STWFinishSale(@lPendSale)
					cDoc	:= ""
					cSerie 	:= ""
					If FindFunction("STWGetDocSerie")
						aDocSerie := STWGetDocSerie()
						If Len(aDocSerie) >= 2
							cDoc 		:= aDocSerie[1]
							cSerie		:= aDocSerie[2]
						EndIf
					EndIf
	
					If lFinish
						//cria o arquivo no host superior (retaguarda ou central) para que o orcamento nao seja importado novamente
						STBCtrImpOrc( cNumOrig , cPdv )
					Else
						// indica se a venda ficara pendente (aguardando ser finalizada)
						If lPendSale
							lRet := .F.
						EndIf
					Endif
	
					//Imprime o TEF
					If ValType(lFinish) == "L" .AND. lFinish .AND. lTEFOk .AND. lEmitNFCe
						//Resposta fiscal para o validador fiscal do MFe
						If lMFE .And. lIntegrador .And. lLjRspFisc .And. ExistFunc("STWGetIdPgto")
							LjRspFisc(oTEF20,.F.,STWGetIdPgto())
							STWZeraIdPgto() //Limpa variavel que armazena os Id's dos pagamentos enviados ao MFe
						EndIf	
	
						STWPrintComp(oTEF20)
					EndIf
	
		           //Transmite a venda para retaguarda                
					If !lPendSale .AND. nSendOn == 1
		   				MsgRun(STR0019,'Aguarde...',{||STDSendSale(cL1_SEND,cEstacao,.F.,cEmpAnt,cFilAnt)})  // "Transmitindo venda"
					ElseIf !lPendSale .AND. nSendOn == 2
						StartJob("STDSendSale", GetEnvServer(), .F., cL1_SEND,cEstacao,.T.,cEmpAnt,cFilAnt)
					EndIf
					
					//Seta a quantidade de cartoes na venda
					//para 0 apos a finalizacao. Usado na homologacao do TEF
					Iif(!lPendSale, STIsetUsedCard(), Nil)
					
					If !lPendSale
						If ExistBlock("STFinishSale")
							LjGrvLog( "L1_NUM: "+cL1_SEND, "Antes P.E STFinishSale | L1_SITUA: " + STDGPBasket('SL1','L1_SITUA') )
							ExecBlock("STFinishSale",.F.,.F.,;
									{cL1_Filial,cL1_SEND,cDoc,cSerie,aDadosCli}) //Filial, n˙mero do orÁamento, doc, sÈrie e Dados Cliente CRD
							LjGrvLog( "L1_NUM: "+cL1_SEND, "Depois P.E STFinishSale | L1_SITUA: " + STDGPBasket('SL1','L1_SITUA') )
						EndIf
					EndIf
					If FindFunction("STWSetDocSerie")
						STWSetDocSerie("","")		//Limpa os campos de Doc e SÈrie apÛs o uso do Ponto de Entrada STFinishSale()
					EndIf
				
				EndIf
			EndIf
					
		EndIf
	Else
		If ValType(oWFReceipt) == 'O'
			STFMessage(ProcName(0), "STOP", STR0022 ) //"Aguarde. Efetuando baixa do tÌtulo." 
			STFShowMessage(ProcName(0))
			If oWFReceipt:DropTitles(oMdlGrd,STIGetIsCont())
				oWFReceipt:Print(oMdlGrd)
				If lSTConfRec
					ExecBlock("STConfRec",.F.,.F.,{oWFReceipt,aPayment})
				EndIf
				If ChkFile("MHJ") .AND. ChkFile("MHK")
					STBIncMHX(oWFReceipt,oMdlGrd)
				EndIf 
				lRet := .T. 
				STFSetTot( 'L1_VLRTOT' , 0 )
				STISetRecTit(.F.) // Depois de finalizar, seta que nao eh mais recebimento
			Else
				lRet := .F.
			EndIf

			If lRet
				STISetRecTit(.F.)
				STFRestart()
			EndIf	
		EndIf
	EndIf
Else
	lRet := .F.
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBDescTEF
Aplica desconto concedido no TEF na venda
@param   	oMdlGrd - Grid do Model 
@param		oTEF20 - Objeto do TEF
@param   	aPaym	- Array de pagamentos	
@author  	Varejo
@version 	P11.8
@since   	28/06/2013
@return  	lRet - Se executou corretamente 	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDescTEF(oMdlGrd, oTEF20, aPaym)

Local oForma			:= Nil		//Objeto de forma formas de pagamento do tef
Local lRet 			:= .T.		//Variavel de retorno
Local nI 				:= 0		//Variavel de Loop
Local nConta			:= 1		//Contador das formas de pagamento do TEF
Local nVlrDescTEF	:= 0		//Valor de desconto do TEF

Default oMdlGrd  	:= Nil
Default oTEF20 		:= Nil
Default aPaym 		:= {}

oForma := IIF(STIGetCard(),oTEF20:Cupom():RetornarFormas("V",oTEF20:Cartao():GetTotalizador(), "C"),Nil)

For nI := 1 To oMdlGrd:Length() 

	oMdlGrd:GoLine(nI)
	
	/* Se for cartao e o L4_TEF == .T. */	
	If oMdlGrd:GetValue( "L4_TEF" )
	
		/* 
			Enquanto as formas retornadas pelo oForma n„o forem todas impressas, fica no Loop  
		*/
		If oForma:Count() >= nConta
					
			// Pega os valores de desconto da venda, obs: pegar apenas 1 vez ja esta acumulado
			nVlrDescTEF	:=	oForma:Elements(nConta):nVlrDescTEF
		Else
			// Final do oForma:Count(), entao forca a saida do loop
			Exit
		EndIf
		
		nConta++
		
	EndIf
	
	/*
		Se teve desconto do TEF, aplica na venda antes
		de imprimir os pagamentos 
	*/
	If nVlrDescTEF > 0	
		STWTotDisc( nVlrDescTEF , "V" , "Desc. TEF" , .T. )	
	EndIf

Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBPrintPay
Envia para a impressora as formas de pagamento utilizadas na venda

@param   	oMdlGrd - Grid do Model 
@param		oTEF20 - Objeto do TEF
@param   	aPaym	- Array de pagamentos	
@author  	Varejo
@version 	P11.8
@since   	21/02/2013
@return  	lRet - Se executou corretamente 	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPrintPay(oMdlGrd, oTEF20, aPaym)

Local oForma		:= Nil																//Objeto de forma formas de pagamento do tef
Local nI 			:= 0																//Variavel de Loop
Local cForma		:= ""																//Forma de pagamento
Local nValForma 	:= 0																//Valor da forma de pagamento
Local lRet 		:= .F.																	//Variavel de retorno
Local nVlTotal		:= 0																//Variavel de total do pagamento Somado com valor de saque
Local lTroco		   := SuperGetMv("MV_LJTROCO",, .F.)
Local lItemNFiscal  := .F.
Local cDescForma	:= ""
Local cVlrForma		:= ""
Local aImpForma		:= {}
Local nPosForma		:= 0
Local lIsTef		:= .F.
Local oTotal	 	:= STFGetTot() 														// Totalizador
Local nSaldoAtual	:= 0		  														// Variavel de controle para valor 
Local nSaldoTotal	:= STBRoundCurrency(oTotal:GetValue("L1_VLRTOT") * STBFactor()[1])	//Armazena o Total Fiscal da venda

Default oMdlGrd  	:= Nil
Default oTEF20 		:= Nil
Default aPaym 		:= {}

If STFGetCfg("lUseSAT",.F.)
	STFMessage("STIPayment","STOP", cSiglaSat + " - Transmitindo venda" ) //"SAT - Transmitindo venda ..."
    STFShowMessage("STIPayment")    
Else
   	STFMessage("STIPayment","STOP", STR0010 ) //"Imprimindo/Preparando Documento Fiscal..."
    STFShowMessage("STIPayment") 	
EndIf

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), STR0010 ) //"Imprimindo/Preparando Documento Fiscal..."

ParamType 0 Var   	oMdlGrd		As Object		Default Nil
ParamType 2 Var     aPaym		As Array		Default 	{} 

oForma := IIF(STIGetCard(),oTEF20:Cupom():RetornarFormas("V",oTEF20:Cartao():GetTotalizador(), "C"),Nil) 

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Quantidade de Formas de Pagamento", oMdlGrd:Length() )  //Gera LOG

//Passa a primeira vez para impressao das formas em cartao.
//Pois as mesmas devem ser impressas primeiro que as demais formas de pagamento
For nI := 1 To oMdlGrd:Length()

	oMdlGrd:GoLine(nI)

	/*	
	Se houver transaÁ„o TEF na venda E o campo L4_TEF da parcela for True OU
	n„o h· transaÁ„o TEF E a forma de pagamento da parcela È igual CC ou CD (caixa sem permiss„o para usar TEF)
	*/
	cForma	 := AllTrim(oMdlGrd:GetValue( "L4_FORMA" ))

	If cForma $ "CC/CD"

		nVlTotal	:= oMdlGrd:GetValue( "L4_VALOR" )
		lIsTef		:= oMdlGrd:GetValue( "L4_TEF" )

		//Proporcionaliza por Tipo de Cupom (Fiscal e N„o fiscal)
		nValForma := nVlTotal * STBFactor()[1] 

		//Array de controle de formas de pagamentos CC e CD
		If (nPosForma := Ascan(aImpForma, {|x|  AllTrim(Upper(x[1])) == cForma })) == 0
			cDescForma	:= Tabela("24",cForma)  
			aAdd(aImpForma, {cForma,;				//1 - Tipo da forma (CC ou CD)
							 cDescForma,;			//2 - DescriÁ„o da forma
							 nValForma,;			//3 - Valor total da forma
							 iIf(lIsTef,"1","0")})	//4 - … TEF?
		Else
			aImpForma[nPosForma][3] += nValForma
		EndIf

	EndIf

Next nI

//Faz a impress„o das formas aglutinadas por tipo
For nI := 1 To Len(aImpForma)
	
	cTef		:= aImpForma[nI][4]
	cVlrForma	:= AllTrim(Str(STBRoundCurrency(aImpForma[nI][3]),14,2))
	cForma		:= AllTrim(aImpForma[nI][2]) + "|" + cVlrForma + "|"	
	
	/*
		Chamando o evento para impressao das formas de pagamento
	*/
	If STWGetIsOpenReceipt() .AND. !Empty(cForma)
		
		aRet := STFFireEvent(ProcName(0), "STPayment", {cForma, cTef, cVlrForma, Nil, Nil, Nil})
		
		While Len(aRet) == 0 .OR. aRet[1] <> 0  
			
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Impressora n„o responde." )  //Gera LOG
			
			If MsgYesNo(STR0018)		//"Impressora n„o responde. Deseja tentar novamente?"
				aRet := STFFireEvent(ProcName(0), "STPayment",{cForma, cTef, cVlrForma, Nil, Nil, Nil})
			Else
				Return .F.
				cForma := ""
			EndIf
		End

		If Len(aRet) > 0 .OR. aRet[1] == 0  
   			cForma := ""
			lRet := .T.
		EndIf

	ElseIf !Empty(cForma)
		If !STFGetCfg("lUseECF") // Nao Utiliza impressora fiscal
			lRet := .T.
		EndIf
	EndIf

Next nI


lItemNFiscal := STBExistNItemFiscal() //Verifica se tem item nao fiscal na venda.

//Formas que nao sao Cartao devem ser impressas por ultimo
For nI := 1 To oMdlGrd:Length()  

	cForma := ""
		
	oMdlGrd:GoLine(nI)
	
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "L4_FORMA", AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) )  //Gera LOG
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "L4_VALOR", oMdlGrd:GetValue( "L4_VALOR" ) )  //Gera LOG
	
	/*
		Se NAO for uma transaÁ„o TEF ( caso seja uma venda com CC ou CD 
		e o Caixa N√O tem permiss„o de Usar TEF, È caracterizado uma transaÁ„o N√O TEF )
	*/
	If !(AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) $ "CC/CD")

		/*
			Verifica se ser· necessario ajuste no troco, ajusta troco com total para diferenÁas menores que 0.05 centavos
		*/

		If AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) == "CR"
			nSaldoAtual += STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1])
		Else
			If AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) == "BF"
				nSaldoAtual += STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ))
			ElseIf AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) == "R$"
				If lTroco .And. !lItemNFiscal
					nSaldoAtual += STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1])
				Else
					nSaldoAtual += STBRoundCurrency(( oMdlGrd:GetValue( "L4_VALOR" ) - STBGetTroco()) * STBFactor()[1])
				EndIf
			Else
				nSaldoAtual += STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1])
			EndIf
		EndIf
		
		If nI  ==  oMdlGrd:Length()		
			If  nSaldoAtual > nSaldoTotal
				nSaldoAtual := Abs(nSaldoTotal - nSaldoAtual )
				If nSaldoAtual < 0.05 
					oMdlGrd:LoadValue( "L4_VALOR", oMdlGrd:GetValue( "L4_VALOR" ) - nSaldoAtual  )
				EndIf
			EndIf
			If  nSaldoAtual < nSaldoTotal
				nSaldoAtual := Abs(nSaldoTotal - nSaldoAtual )
				If nSaldoAtual < 0.05 
					oMdlGrd:LoadValue( "L4_VALOR", oMdlGrd:GetValue( "L4_VALOR" ) + nSaldoAtual  )
				EndIf
			EndIf
		EndIf
		
		/* 
			Imprime as formas que n„o fazem parte do TEF 
		*/				
		If AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) == "CR"
			// NCCs devem ser tratadas de forma diferente pois n„o faz parte das formas de pagamento, portanto nao est· em aPaym.
			cForma := "CREDITO|" + AllTrim(Str(STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1]),14,2)) + "|"															
		Else
			If AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) == "BF"
				cForma := "BONIFICACAO|" + AllTrim(Str(STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" )),14,2)) + "|"			
			ElseIf AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) == "R$"	
				//Tratamento para exibicao de troco em dinheiro
				If lTroco .And. !lItemNFiscal
					cForma := AllTrim(aPaym[Ascan(aPaym,{|x| x[1] == AllTrim(oMdlGrd:GetValue( "L4_FORMA" ))})][3]) ;
								+ "|" + AllTrim(Str(STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1]),14,2)) + "|"
				Else
					cForma := AllTrim(aPaym[Ascan(aPaym,{|x| x[1] == AllTrim(oMdlGrd:GetValue( "L4_FORMA" ))})][3]) ;
								+ "|" + AllTrim(Str(STBRoundCurrency((oMdlGrd:GetValue( "L4_VALOR" ) - STBGetTroco()) * STBFactor()[1]),14,2)) + "|"								
				EndIf
			Else
				cForma := AllTrim(aPaym[Ascan(aPaym,{|x| x[1] == AllTrim(oMdlGrd:GetValue( "L4_FORMA" ))})][3]) ;
							+ "|" + AllTrim(Str(STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1]),14,2)) + "|"			
			EndIf			
		EndIf
		
		
		//Tratamento dinheiro
		If AllTrim(oMdlGrd:GetValue( "L4_FORMA" )) == "R$"
			//Exibe Troco
			If lTroco .And. !lItemNFiscal
				nValForma	:= oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1]
			Else
				nValForma	:= (oMdlGrd:GetValue( "L4_VALOR" ) - STBGetTroco()) * STBFactor()[1]
			EndIf
		Else
			nValForma	:= oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1]
		EndIf 
		
	EndIf

	/*
		Chamando o evento para impressao das formas de pagamento
	*/
	If STWGetIsOpenReceipt() .AND. !Empty(cForma) .AND. STBRoundCurrency(oMdlGrd:GetValue( "L4_VALOR" ) * STBFactor()[1]) > 0.01

		aRet := STFFireEvent(ProcName(0), "STPayment", {cForma, IIF(oMdlGrd:GetValue("L4_TEF"),"1","0"), AllTrim(Str(nValForma,14,2)), Nil, Nil, Nil})
		
		While Len(aRet) == 0 .OR. aRet[1] <> 0  
				
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Impressora n„o responde" )  //Gera LOG
			
			If MsgYesNo(STR0018)		//"Impressora n„o responde. Deseja tentar novamente?"				
				aRet := STFFireEvent(ProcName(0), "STPayment", {cForma, IIF(oMdlGrd:GetValue("L4_TEF"),"1","0"), AllTrim(Str(nValForma,14,2)), Nil, Nil, Nil})					
			Else				
				Return .F.	
				cForma := ""							
			EndIf

		End
		
		If Len(aRet) > 0 .OR. aRet[1] == 0       
			lRet := .T.
			cForma := ""
		EndIf
	ElseIf !STWGetIsOpenReceipt()
		//Para impressoes nao fiscais
		lRet := .T.	
	EndIf
	
Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCloseCup
Totalizando e fechando o cupom fiscal

@param1   	oTEF20 - Objeto TEF
@param2   	oTotal - Objeto TOTAL
@author  	Varejo
@version 	P11.8
@since   	21/02/2013
@return  	lRet - Se executou corretamente   	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCloseCup(oTEF20, oTotal)

Local cReturn		:= ""		//Retorno do comprovante TEF
Local lRet			:= .F.		//Retorno da funcao
Local nOpt 			:= 2        //OpÁ„o selecionada pelo usu·rio
Local lTentaTiva 	:= .T.      //controle de tentativa de impressao
Local cEOF		:= CHR(10)+CHR(13)
Local cMsgCupom	:= ""    
Local cNumDAV   := ""  
Local nVlrTotal	:= 0
Local nDecimais := MsDecimais(STBGetCurrency()) 

Local nTotICMS	:= 0
Local nTotISS	:= 0 
Local cAuxMsgCup := ""
Local lEmitNfce		:= Iif(ExistFunc("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e
	
Default oTEF20  	:= Nil
Default oTotal 		:= Nil


cNumDAV := STDGPBasket("SL1","L1_NUMORC")
/*
 HOMOLOGACAO PAF-ECF 2013
 a Ordem das Mensagens Impressas deve ser:
 1 - MD5 ; 2 - Msg do TPL PCL ou DAV/PRE-VENDA XXXXX ; 3 - Msgs dos Estados (Minas Legal, etc.)
 4 - mensagens adicionais
*/
If STBIsPAF() .AND. !Empty(cNumDAV) //L1_NUMORC
	If SuperGetMv("MV_LJPRVEN",,.F.)
		cMsgCupom := "PV"+AllTrim(cNumDAV)+CRLF
	Else
		cMsgCupom := "DAV"+AllTrim(cNumDAV)+CRLF
	EndIf
EndIf

nVlrTotal := STDGPBasket("SL1","L1_VLRTOT")

If 	!lEmitNfce // Se estiver com NFCE n„o executa legislaÁıes referente a cupom fiscal.

	//Verifica se deve imprimir mensagem "MINAS LEGAL" de Minas Gerais
	cMsgCupom	+=	Lj950MinasL(nVlrTotal,nDecimais) //L1_VLRTOT - nao precisa alterar
		
	//Verifica se deve imprimir mensagem "PARAIBA LEGAL" da ParaÌba
	cMsgCupom	+=	Lj950PBLeg(nVlrTotal,nDecimais,STDGPBasket("SL1","L1_DOC"))    //L1_VLRTOT Lj950PBLeg(nVlrTotal, nDecimais , cCooCup) //lpos e objeto de cliente
EndIf	

//Verifica se deve imprimir mensagem "Nota Legal" do Distrito Federal para evitar looping desnecessario no aItens
If LJAnalisaLeg(62)[1]
								//acumula valor de iss dos produtos
	nTotICMS := oTotal:GetValue("L1_VALICM") 

	nTotISS  := oTotal:GetValue("L1_VALISS") 
	
 	cMsgCupom	+=  Lj950NotaL( nTotICMS , nTotISS , nDecimais, STDGPBasket("SL1","L1_CGCCLI") )  //sem parametros
EndIf 

cAuxMsgCup := AllTrim(SuperGetMV("MV_LJFISMS",,""))

If Substr(cAuxMsgCup,1,1)=="&"
	cAuxMsgCup := &( Substr(cAuxMsgCup,2,Len(cAuxMsgCup)) )
EndIf

If Empty(AllTrim(cAuxMsgCup))
	cAuxMsgCup := STFGetStation("MSGCUP") + cEOF
Else
	cAuxMsgCup += cEOF
EndIf
		
cMsgCupom	+= cAuxMsgCup

// Impressao da mensagem referente ao FECP
If ExistFunc("Lj950FECP")
	nValFECP	:= STBTaxRet(Nil ,"NF_VALFECP")
	cAuxMsgCup	:= AllTrim(Lj950FECP(nValFECP))
	If !Empty(cAuxMsgCup)
		cMsgCupom	+= cAuxMsgCup + cEOF
	EndIf
EndIf

/*
  Para Homologacao TEF eh preciso esperar um tempo
  para enviar o fechamento do cupom apos o envio do pagamento
  pois eles fazem um teste de desligamento, e se nao esperar ele 
  confirma que fechou o cupom mesmo sem ter impresso o fechamento
*/
If SuperGetMV("MV_LJHMTEF", ,.F.)
	Sleep(5000)
EndIf	

If STIGetCard()
	cReturn := oTEF20:Cupom():CupomReduzido(.T., cMsgCupom + STR0003, "V" + oTEF20:Cartao():GetTotalizador() + "C") //"Obrigado e volte sempre" 
	If Empty(cReturn)
		cReturn :=  cMsgCupom
	EndIf
Else
	cReturn := cMsgCupom
EndIf

If STWGetIsOpenReceipt()		
	
	IF (ExistFunc("Lj950ImpCpf") .And. Lj950ImpCpf(nVlrTotal)) .Or. (ExistFunc("LjInfDocCli") .And. LjInfDocCli() > 1)
		lTentaTiva := .T.
		cAuxMsgCup := "" //No modelo bematech a n˙mero do CPF È no comando de fechamento portanto mando essa vari·vel
		STWIdCliente(@lTentaTiva,@cAuxMsgCup)
		
		If !Empty(AllTrim(cAuxMsgCup)) 
			cReturn := cAuxMsgCup + cReturn //J· vem com a quebra de linha, por isso somente concatena
		EndIf
		
		lTentaTiva := .T. //Retorna o conteudo da variavel para prosseguimento do programa
	EndIf

	aRet := STFFireEvent(ProcName(0), "STCloseReceipt", {cReturn,;
	 						(oTotal:GetValue("L1_VLRTOT") + oTotal:GetValue("L1_DESCONT")) - oTotal:GetVaLue("L1_NOTFISCAL"), Nil})

	If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impress„o

		While lTentaTiva 
						
			STFMessage("TEFImprime", "YESNO", STR0006 + " " + STR0007) //"Impressora n„o responde."#"Deseja imprimir novamente?"
			nOpt := If(STFShowMessage("TEFImprime"),2,0) 
			
			//2=SIM
			If nOpt == 2
			
				Sleep(5000)					
				aRet := STFFireEvent(ProcName(0), "STCloseReceipt", {cReturn,;
				 						(oTotal:GetValue("L1_VLRTOT") + oTotal:GetValue("L1_DESCONT")) - oTotal:GetVaLue("L1_NOTFISCAL"), Nil})
			
				If Valtype(aRet) == "A" .AND. Len(aRet) > 0 .AND. aRet[1] <> 0 //Erro na impress„o				
					lTentaTiva := .T.
					lRet := .F.
				Else
					lTentaTiva := .F.	
					lRet := .T.
				EndIf
			
			Else				
				lTentaTiva := .F.		
				lRet := .F.
				
				/*/
					Desfazimento TransaÁ„o TEF
				/*/
				oTEF20 := STBGetTef() 
				If ValType(oTEF20) == 'O'
					oTEF20:Desfazer() 
					STFMessage("TEF", "POPUP",STR0008)//"TransaÁ„o n„o foi efetuada. Favor reter o cupom."
					STFShowMessage( "TEF") 
				EndIf	
						
			EndIf	

		EndDo		
	
		
	Else
		lRet := .T.	
	EndIf
	                                 
	//se fechou o cupom
	If lRet	
		STWSetIsOpenReceipt( .F. )	
	EndIf
	
Else
	
	lRet := .T.	

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCalcSald
Saldo restante do pagamento

@param1   	cType - Tipo de pagamento
@param2   	nValue - Valor do pagamento
@author  	Varejo
@version 	P11.8
@since   	21/02/2013
@return  	uRet - Saldo restante do pagamento  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCalcSald(cType, nValue,aResPay)
Local uRet 	:= Nil				//Total do saldo
Local oTotal	:= STFGetTot() 	//Recebe o objeto do model para recuperar os valores
Local nTotal    := 0			//Acumulador

Default cType  		:= ""
Default nValue 		:= 0
Default aResPay		:= {}

ParamType 0 Var 	cType 		As Character	Default 	""
ParamType 1 Var 	nValue 	As Numeric		Default 	0
If nVLBF <> 0    
	nTotal := nVLBF
Else
	nTotal := STIGetTotal()
Endif	

If nTotal < 0 //Bonificacao 
	nTotal:= -1 * nTotal
Endif

Do Case
	Case cType == "1"
		uRet := IIF((oTotal:GetValue("L1_VLRTOT") - STIGetTotal()) <= 0, 0, oTotal:GetValue("L1_VLRTOT") - STIGetTotal()) 
	Case cType == "2"
		uRet := ( (STIGetTotal() + nValue) >= oTotal:GetValue("L1_VLRTOT") )
EndCase

Return uRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBUpdPaym
Atualiza o model com todas as parcelas a serem gravadas na SL4

@param   	oMdl - Model das parcelas do pagamento
@author  	Varejo
@version 	P11.8
@since   	13/03/2013
@return  	lRet - Se executou corretamente   	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBUpdPaym(oMdl)

Local oMdlGrd		:= oMdl:GetModel("PARCELAS")		//Seta o model do grid
Local oMdlPaym		:= oMdl:GetModel("APAYMENTS")		//Seta o model do grid
Local aFieldsGrd	:= oMdlGrd:GetStruct():GetFields()	//Estrutura do model
Local nJ			:= 0								//Variavel de loop
Local nPosIni		:= 1
Local lTemDin		:= .F.								//Ja existe dinheiro nos pagamentos?
Local cForma		:= ""

Default oMdl  		:= Nil

ParamType 0 Var   	oMdl 	As Object		Default Nil

	cForma := AllTrim(oMdlGrd:GetValue('L4_FORMA')) //Forma de pagamento

	/* Tratamento para somar v·rios pagamentos em dinheiro */
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "01 Forma de Pagamento." + cForma+"." )  
	If cForma == 'R$'
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "02 Forma de Pagamento." + oMdlGrd:GetValue('L4_FORMA')+"." )  		
		//O metodo SeekLine substitui o aScan no acols (que nao esta sendo mais utilizado para a versao 12)
		//Se retornar .T. È que foi encontrado a busca e automaticamente ja esta sendo posicionada na linha desejada.
		If oMdlPaym:SeekLine({{"L4_FORMA", 'R$'}})
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Pagamento em R$" )  //Gera LOG		    
			lTemDin := .T.		
		Else
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "N„o tem dinheiro lTemDin" )  
	    Endif
	Endif

	//So adiciona o registro caso o primeiro esteja vazio, para nao duplicar o objeto
	If !(lTemDin .Or. (oMdlPaym:Length() == 1 .And. Empty(oMdlPaym:GetValue("L4_FORMA")) .And. Empty(oMdlPaym:GetValue("L4_VALOR"))))
		oMdlPaym:AddLine(.T.)
	EndIf 
	
	If !(cForma $ 'CR')
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "L4_FORMA != CR" )  //Gera LOG

		If  !IsMoney(cForma) .AND. !(cForma $ 'CC|CD|CH|FI|VA|VP|CO|FID')
			//Entra nesse IF quando o cliente customiza alguma forma de pagamento na SX5 tabela 24
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Chama STBGerParc" )  //Gera LOG
			oMdlPaym := STBGerParc(oMdlGrd, oMdlPaym, aFieldsGrd, nPosIni)
		Else
			If  !(cForma $ 'CC|CD|CH|FI|CO') .and. !(ProcName(2) == 'STIFICONFPAY') 
				
				For nJ := 1 To Len(aFieldsGrd)
					oMdlPaym:LoadValue(aFieldsGrd[nJ][3], oMdlGrd:GetValue(aFieldsGrd[nJ][3]))
				Next nJ

				LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Formas de pgto nao consideradas como entrada:", cMvEntExce )
				If !Empty(cForma) .And. oMdlGrd:GetValue("L4_DATA") == dDataBase .And.  !("|"+cForma+"|" $ cMvEntExce) 
					nEntrada += oMdlGrd:GetValue("L4_VALOR")
				EndIf
				
			Else
				LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Chama STBGerParc" )  //Gera LOG
				oMdlPaym := STBGerParc(oMdlGrd, oMdlPaym, aFieldsGrd, nPosIni)
			EndIf
		EndIf
		
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGerParc
Geracao das parcelas para os tipos CD,CC e CH

@param   	
@author  	Varejo
@version 	P11.8
@since   	15/03/2013
@return  	oMdlPaym - Model de Pagamentos
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGerParc( oMdlGrd, oMdlPaym, aFieldsGrd , nPos )

Local nI			:= 0 							//Variavel de loop
Local nJ			:= 0 							//Variavel de loop
Local nIntervalo	:= SuperGetMV("MV_LJINTER") //Intervalo das parcelas
Local nDiferenca	:= 0							//Diferenca
Local aParcelas		:= STBGetParc()				//Recebe as parcelas da condicao de pagamento
Local nTotParc		:= Len(aParcelas)			//Total de parcelas
Local aRetCheck		:= STWGetCkRet()				//Dados do cheque
Local lFormaImp 	:= ExistFunc("STBGFormImp") .And. STBIsImpOrc()
Local aFormasImp	:= {}
Local nPosImp		:= 0
Local dData			:= Nil
Local nValor		:= 0
Local lGFIAltImp 	:= ExistFunc("STIGFiAltImp")
Local lVldForm      := .F. //Valida as formas de pagamento 

Default oMdlGrd 		:= Nil
Default oMdlPaym		:= Nil
Default aFieldsGrd 	:= {}
Default nPos			:= 0

ParamType 0 Var   	oMdlGrd 		As Object		Default Nil
ParamType 1 Var   	oMdlPaym 		As Object		Default Nil
ParamType 2 Var   	aFieldsGrd 		As Array		Default {}
ParamType 3 Var 	nPos 			As Numeric		Default 0

If nTotParc > 0

	/* Lancar as parcelas para cartao e cheque */
	For nI := 1 To nTotParc
		
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Total de Parcelas (nTotParc): " + STR(nTotParc) )  //Gera LOG
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Parcela: " + Str(nI) + " de " + STR(nTotParc) )  //Gera LOG

		IIF(nPos == 1 .AND. nI == 1, Nil, oMdlPaym:AddLine(.T.))
		
		For nJ := 1 To Len(aFieldsGrd)
		
			If AllTrim(aFieldsGrd[nJ][3]) == "L4_DATA"
			
				oMdlPaym:LoadValue("L4_DATA", aParcelas[nI][1] )
				
			ElseIf AllTrim(aFieldsGrd[nJ][3]) == "L4_VALOR"
			
				oMdlPaym:LoadValue("L4_VALOR", aParcelas[nI][2] )
							
			Else
			
				oMdlPaym:LoadValue(aFieldsGrd[nJ][3], oMdlGrd:GetValue(aFieldsGrd[nJ][3]))
				
			EndIf
			
		Next nJ
						
	Next nI	

Else

	nDiferenca := STBRound( oMdlGrd:GetValue("L4_VALOR") - (( STBRound( oMdlGrd:GetValue("L4_VALOR") / oMdlGrd:GetValue("L4_PARC"),2) ) * oMdlGrd:GetValue("L4_PARC")), 2)  
	
	If	AllTrim(oMdlGrd:GetValue('L4_FORMA')) == 'CH'
		nContCheque++
	EndIf	

	If lFormaImp 
		lVldForm := STBVldForm(oMdlGrd,STBGFormImp())
	EndIf

	For nI := 1 To oMdlGrd:GetValue("L4_PARC")

		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "(ELSE) Total de Parcelas (nTotParc): " + STR(oMdlGrd:GetValue("L4_PARC")) )  //Gera LOG
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "(ELSE) Parcela: " + Str(nI) + " de " + STR(oMdlGrd:GetValue("L4_PARC")) )  //Gera LOG
		
		IIF(nPos == 1 .AND. nI == 1, Nil, oMdlPaym:AddLine(.T.))

		nValor	:= 0
		dData	:= cToD("  /  /   ")
		If lFormaImp .And. lVldForm
			aFormasImp := STBGFormImp()
			If Len(aFormasImp) > 0 .AND. ( lGFIAltImp .AND. !STIGFiAltImp())
				If (nPosImp := aScan(aFormasImp, {|x| AllTrim(x[1])==AllTrim(oMdlGrd:GetValue('L4_FORMA')) .And. x[4]==nI .And. (oMdlGrd:GetValue('L4_FORMAID')==x[5] .Or. AllTrim(x[5])=='') })) > 0				
					nValor := aFormasImp[nPosImp][2] 		//Valor do cheque
					dData	:= SToD(aFormasImp[nPosImp][3])	//Vencimento do cheque
				EndIf
			EndIf
		Endif
		
		For nJ := 1 To Len(aFieldsGrd)
		
			Do Case
				Case AllTrim(aFieldsGrd[nJ][3]) == "L4_DATA"
					LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Forma" + oMdlGrd:GetValue('L4_FORMA') )  //Gera LOG

					If AllTrim(oMdlGrd:GetValue('L4_FORMA')) == 'CH' .AND. ValType(aRetCheck[1][1][1]) == 'A' .AND. Len(aRetCheck) > 0 .AND. Len(aRetCheck[nContCheque][nI][1]) >= 11 .AND. aRetCheck[nContCheque][nI][1][10] <> Nil
						oMdlPaym:LoadValue("L4_DATA",aRetCheck[nContCheque][nI][1][10])
					ElseIf AllTrim(oMdlGrd:GetValue('L4_FORMA')) == 'CH' .AND. ValType(aRetCheck) == 'A' .AND. Len(aRetCheck) > 0 .AND. Len(aRetCheck[1][1]) >= 11
						oMdlPaym:LoadValue("L4_DATA",aRetCheck[nI][1][10])
					Else
						If Empty(dData)
							dData := oMdlGrd:GetValue(aFieldsGrd[nJ][3]) + IIf(nI = 1, 0, nIntervalo*(nI-1))
						EndIf
						oMdlPaym:LoadValue("L4_DATA", dData )
					EndIf

				Case AllTrim(aFieldsGrd[nJ][3]) == "L4_VALOR"
					If AllTrim(oMdlGrd:GetValue('L4_FORMA')) == 'CH' .AND. ValType(aRetCheck[1][1][1]) == 'A' .AND. Len(aRetCheck) > 0 .AND. Len(aRetCheck[nContCheque][nI][1]) >= 11
						oMdlPaym:LoadValue("L4_VALOR", aRetCheck[nContCheque][nI][1][11] )
					ElseIf AllTrim(oMdlGrd:GetValue('L4_FORMA')) == 'CH' .AND. ValType(aRetCheck) == 'A' .AND. Len(aRetCheck) > 0 .AND. Len(aRetCheck[1][1]) >= 11
						oMdlPaym:LoadValue("L4_VALOR", aRetCheck[nI][1][11] )
					Else						
						If nValor == 0
							nValor := STBRound( oMdlGrd:GetValue(aFieldsGrd[nJ][3]) / oMdlGrd:GetValue('L4_PARC'), 2 )
						EndIf
						oMdlPaym:LoadValue("L4_VALOR", nValor )
						
						If nI == oMdlGrd:GetValue('L4_PARC') .AND. !lVldForm
							oMdlPaym:LoadValue("L4_VALOR", STBRound( oMdlPaym:GetValue("L4_VALOR") + nDiferenca, 2 ))
						EndIf
					Endif
																				
					If oMdlPaym:GetValue("L4_DATA") == dDataBase .AND. !(("|"+ Alltrim(oMdlGrd:GetValue('L4_FORMA'))+"|") $ cMvEntExce)
						nEntrada += oMdlPaym:GetValue("L4_VALOR")
					EndIf
					
				Case AllTrim(aFieldsGrd[nJ][3]) == "L4_ACRSFIN"
				
					oMdlPaym:LoadValue("L4_ACRSFIN", STBRound( oMdlGrd:GetValue(aFieldsGrd[nJ][3]) / oMdlGrd:GetValue('L4_PARC'), 2 ) )				 				
															
				Case ValType(aRetCheck) == 'A' .AND. Len(aRetCheck) > 0 .AND. AllTrim(oMdlGrd:GetValue('L4_FORMA')) == 'CH' .AND. PadR(aFieldsGrd[nJ][3], 10) $ "L4_ADMINIS|L4_NUMCART|L4_AGENCIA|L4_CONTA  |L4_RG     |L4_TELEFON|L4_TERCEIR|L4_NOMECLI"
					
					If ValType(aRetCheck[1][1][1]) == 'A' .AND. Len(aRetCheck[nContCheque][nI][1]) >= 10 
						Do Case
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_ADMINIS"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][1])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_NUMCART"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][2])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_AGENCIA"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][3])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_CONTA"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][4])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_RG"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][8])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_TELEFON"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][7])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_TERCEIR"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][9])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_NOMECLI"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nContCheque][nI][1][6])
						EndCase
					Else
						Do Case
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_ADMINIS"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][1])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_NUMCART"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][2])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_AGENCIA"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][3])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_CONTA"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][4])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_RG"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][8])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_TELEFON"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][7])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_TERCEIR"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][9])
							Case AllTrim(aFieldsGrd[nJ][3]) == "L4_NOMECLI"
								oMdlPaym:LoadValue(aFieldsGrd[nJ][3], aRetCheck[nI][1][6])
						EndCase 					
					EndIf
					
				OtherWise
			
					oMdlPaym:LoadValue(aFieldsGrd[nJ][3], oMdlGrd:GetValue(aFieldsGrd[nJ][3]))
				
			EndCase
			
		Next nJ
						
	Next nI
	
	aRetCheck := {}
	
EndIf

//Volta ao estado original da variavel que indica se houve alteraÁ„o em alguma informaÁ„o do orÁamento do tipo FI
If ExistFunc("STISFiAltImp")
	STISFiAltImp()
EndIf	

Return oMdlPaym


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetEnt
Retorna o valor de entrada

@param   	
@author  	Varejo
@version 	P11.8
@since   	03/04/2013
@return  	nEntrada - Valor de entrada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetEnt()
Return nEntrada


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetEnt
Set na variavel nEntrada

@param   	
@author  	Varejo
@version 	P11.8
@since   	03/04/2013
@return  	lRet - Se executou corretamente  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetEnt()
nEntrada := 0
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBOpenDrawer
Abre a gaveta

@param   	
@author  	Varejo
@version 	P11.8
@since   	03/04/2013
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBOpenDrawer()

Local aRet := {}

aRet := STFFireEvent( ProcName(0), "STOpDrawer", {} )				

If Len(aRet) == 0 .OR. aRet[1] <> 0

	STFMessage("STOpDrawer ", "STOP", STR0004)//"Erro ao abrir gaveta"  
	STFShowMessage("STOpDrawer ")

EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBUpdResPg
Atualiza o list box do resumo de pagamento

@param   	oListTpPaym - Envio o objeto para que seja possivel bloquear as aÁıes dele ate que seja concluido ou cancelado a forma de pagamento atual.	
@author  	Varejo
@version 	P11.8
@since   	03/04/2013
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBUpdResPg(nAjustCols, lFirstPay,nVLBonif,oListTpPaym)

Local oMdl 				:= STISetMdlPay()								//Get no objeto oModel
Local oModel			:= oMdl:GetModel('PARCELAS')					//Get no model parcelas
Local nX				:= 0											//Variavel de loop
Local aRet				:= {}											//Variavel de retorno
Local oMdlCdPg			:= Nil											//Model da condicao de pagamento
Local oCondPgModel		:= Nil											//Recebe o set do model CDPGDETAILS  
Local nTotalNCCs		:= STDGetNCCs("2")								//Valor total das NCCs utilizada na venda
Local aOrc				:= {}											//Orcamento
Local nI				:= 0											//Variavel de loop
Local lPayImport		:= STIGetPayImp()								//Variavel que controla para nao passar duas vezes pelo pagamento no orcamento
Local aCallAdm			:= {}											//Armazena formas de pagamento a serem chamadas interface para informar Adm. Fin.
Local nContCard			:= 0											//Contador
Local cFormPgto			:= ""											//Armazena a forma de pagamento de acordo com o ValType do aOrc
Local oTotal			:= STFGetTot()									//Total da venda
Local lZeraPayImport	:= IIf(ExistFunc("STiGetZrPg"),STiGetZrPg(),.F.)//Variavel de controle que indica se consider· ou n„o os pagamentos do orÁamento

Default nAjustCols 	:= 0
Default lFirstPay	:= .F.
Default nVLBonif    := 0
Default oListTpPaym	:= Nil							//Objeto da lista de formas de pagamento

If Empty(nVLBF)
	nVLBF := nVLBonif
Endif	

If Empty( STDGPBasket( "SL1" , "L1_NUMORIG" ) )
	If lFirstPay .AND. nTotalNCCs == 0 .AND. nVLBF == 0
		/* Criacao do model da cond de pagamento */
		ModelCdPg()

		/* Add as Cond pgtos no model */
		STIAddCPg( Nil , .T. )

		/* Marca no model a condicao de pagamento a ser considerada */
		STISelectCP()

		/* Chama o workflow para lancar a condicao de pagamento */
		oMdlCdPg 		:= STIGetMdlCpPg()
		oCondPgModel	:= oMdlCdPg:GetModel("CDPGDETAILS")
		STWPayCdPg(oCondPgModel)
	EndIf
Else
	If !lPayImport .AND. nVLBF == 0

		STISetPayImp(.T.) //Apenas alimenta a variavel lPayImport como .T.
		
		If oTotal:GetValue( "L1_VLRTOT" ) >= nTotalNCCs .AND. !lZeraPayImport
			
			If Valtype(oListTpPaym) == "O"
				oListTpPaym:BWHEN := {|| .F. }
			Endif 

			aOrc := STBFormatOrcs()
			
			For nI := 1 To Len(aOrc)
		
				If Valtype(aOrc[nI][1]) == "A"
					cFormPgto := aOrc[nI][1][3]
				Else
					cFormPgto := aOrc[nI][3]
				EndIf
				
				If cFormPgto <> Nil 
				
					Do Case
						Case IsMoney(cFormPgto)						
							STICSOrc(	STOD(aOrc[nI][2])	,;	//Data
										aOrc[nI][1]			)	//Valor																				
						
						Case cFormPgto == 'CH'
							STICheckOrc(	STOD(aOrc[nI][2])	,; 	//Data
											aOrc[nI][1]			,;	//Valor
											aOrc[nI][4]			)	//Parcelas
						
						Case cFormPgto $ 'CC|CD'
							/*
							retiramos o trecho que faz a chamada da tela do TEF, pois ao importar um orÁamento
							que possuia TEF com Clisitef, a tela do TEF j· era chamada, n„o permitindo que o Caixa
							editasse o orÁamento, ao menos que ele cancelasse a tela do TEF manualmente
							*/						
							If Valtype(aOrc[nI][1]) == "A"
								For nContCard := 1 To Len(aOrc[nI])
									AADD( aCallADM , { STOD(aOrc[nI][nContCard][2]) , aOrc[nI][nContCard][1] , aOrc[nI][nContCard][4] , '' , aOrc[nI][nContCard][3] , .F. } ) //Preenche  o aCallADM para importaÁ„o de orÁamento com mais de um Id de Cart„o 
								Next nContCard
							Else
								AADD( aCallADM , { STOD(aOrc[nI][2]) , aOrc[nI][1] , aOrc[nI][4] , '' , aOrc[nI][3] , .F. } ) //Chamar preencher ADM para importaÁ„o
							EndIf
							
							STISetaCallADM(aCallADM)
																			
						Case cFormPgto == 'FI'	
							AADD( aCallADM , { STOD(aOrc[nI][2]) , aOrc[nI][1] , aOrc[nI][4] , '' , aOrc[nI][3] , .F. } ) //Chamar preencher ADM para importaÁ„o
							STISetaCallADM(aCallADM)

						OtherWise
							AADD( aCallADM , { STOD(aOrc[nI][2]) , aOrc[nI][1] , aOrc[nI][4] , '' , aOrc[nI][3] , .F. } ) //Chamar preencher ADM para importaÁ„o
							STISetaCallADM(aCallADM)

					EndCase
	
		

				EndIf

			Next nI

			// FunÁ„o presente no Fonte STFTotalUpdate, responsavel por realizar o Back-Up de valores dos totalizadores do RodapÈ 
			If ExistFunc("STFBkpTot")
				STFBkpTot()
			EndIf

		EndIf
	EndIf
EndIf

For nX := 1 To oModel:Length()
	oModel:GoLine(nX)
	Aadd(aRet, oModel:GetValue('L4_FORMA') + Space(nAjustCols * 0.055) + Str(oModel:GetValue('L4_VALOR'),10,2) + Space(nAjustCols * 0.095) + AllTrim(Str(oModel:GetValue('L4_PARC'))))
	If !Empty(oModel:GetValue('L4_FORMA'))  
	  	Aadd(aTotal, {oModel:GetValue('L4_FORMA') ,oModel:GetValue('L4_VALOR')})				
	Endif
Next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetTroco
Retorna o troco

@param   	
@author  	Varejo
@version 	P11.8
@since   	03/04/2013
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetTroco()

Local nTroco 	:= 0 				//Valor do troco
Local oTotal	:= Nil 	//Recebe o objeto do model para recuperar os valores
Local nTotal	:= STIGetTotal() //Total da nota 
Local lRecebTitle	:= STIGetRecTit()									//Retorna se e recebimento de titulo ou nao


If !lRecebTitle
	oTotal := STFGetTot() 	//Recebe o objeto do model para recuperar os valores
	If nTotal < 0 
		nTotal := -1 * nTotal //Bonificacao
	Endif
	
	If STBCalcSald("1") <= 0
		nTroco := nTotal - oTotal:GetValue("L1_VLRTOT")
	EndIf 
Else
	oTotal := STIRetObjTit()
	If oTotal:GetTotal() > 0
		nTroco := nTotal - oTotal:GetTotal()
	EndIf
EndIf

If nTroco < 0
	nTroco := 0 
Endif

Return nTroco


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRetCoD
Retorna o numero do Contador de Documento

@param   	
@author  	Varejo
@version 	P11.8
@since   	20/02/2013
@return  	cCupom - Numero do cupom	
@obs     
@sample
/*/
//-------------------------------------------------------------------...
Function STBRetCoD()

Local aDados 	:= {"35", Space(6)}
Local cContDoc	:= ""   

aRet := STFFireEvent(ProcName(0), "STPrinterStatus", aDaDos)
			
If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) < 1     
	STFMessage("STIPayment","STOP",STR0009) //"Falha na obtenÁ„o do Contador de Documento!"
	STFShowMessage("STIPayment")    
Else
	cContDoc := aDados[2]
EndIf

Return cContDoc


//-------------------------------------------------------------------
/*/{Protheus.doc} STBInsArredondar
Aparecer· uma pergunta se o cliente deseja doar para o Instituto Arredondar

@param   	
@author  	Varejo
@version 	P11.8
@since   	25/10/2013
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBInsArredondar( cForma )

Local nAux 		:= 0										// Pergunta - valor que ir· doar
Local lArredondar := SuperGetMV( "MV_LJINSAR",,.F. )		// Par‚metro para habilitar doaÁ„o ao Inst. Arredondar
Local nRet 		:= 0										// Par‚metro de SaÌda - valor da doaÁ„o

Default cForma := "R$"										// Forma de Pagamento

// Se ativado a doaÁ„o para o Instituto Arredondar
IF lArredondar
	
	If IsMoney(cForma) 		// Pagamento em Dinheiro
 		nAux	:= STBGetTroco()
		nAux	:= nAux-NoRound(nAux,0)
 	Elseif cForma $ "CC.CD"			// Pagamento em Cart„o de DÈbito/CrÈdito
		nAux	:= STDGPBasket( "SL1" , "L1_VLRTOT" ) 	// Total da nota
 		nAux	:= nAux-NoRound(nAux,0)			// Retiro o inteiro, ficam os centavos
 		nAux	:= iif(nAux>0,1-nAux,nAux)  	// Converter em Troco
 	Else
 		//N„o ir· passar pela pergunta, sÛ ir· perguntar se duas condiÁıes acima combinam. 
 		//(1 È dinheiro e 2 È Tef CD/CC).
 		Return(STBGetInsArr()) 
 	EndIf
 
	If nAux > 0
		If MsgNoYes(STR0013 + Alltrim( Transform( nAux, "@E 999.99" ) ) ;
				+ STR0011, STR0012)		//"Deseja doar 999.99 para o Instituto Arredondar?"#"AtenÁ„o"
			nRet	:= nAux
		EndIf
	EndIf
	
EndIf	

Return STBSetInsArr(nRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetInsArr
Retorna o valor que o cliente fez doaÁ„o ao Instituto Arredondar
@param   	
@author  	Varejo
@version 	P11.8
@since   	25/10/2013
@return  	nArredondar  - Retorna o valor que o cliente fez doaÁ„o ao Instituto Arredondar
@obs     
@sample
/*/
*/
//-------------------------------------------------------------------
Function STBGetInsArr()
Return nArredondar


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetInsArr
Atribui o valor que o cliente fez doaÁ„o ao Instituto Arredondar

@param   	nValor
@author  	Varejo
@version 	P11.8
@since   	25/10/2013
@return  	Nil  	
@obs     
@sample
/*/
*/
//-------------------------------------------------------------------
Function STBSetInsArr( nValor )

Default nValor := 0

nArredondar := nValor

// Se zero o nArredondar, reinicializo tambÈm o nDArredondar
// nArredondar = DoaÁ„o sem desconto da taxa administrativa do cart„o crÈdito
// nDArredondar = DoaÁ„o COM desconto da taxa administrativa do cart„o crÈdito
If nValor = 0
	nDArredondar := nArredondar
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBOrgL2Item
Reorganiza o L2_Item para nao gerar erro no momento de executar o GrvBatch

@param   	
@author  	Varejo
@version 	P11.8
@since   	03/04/2013
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBOrgL2Item()

Local nX		:= 0								//Variavel de loop
Local oMdl 	:= STDGPBModel() 					//Recupera o Model
Local oMdlIte	:= oMdl:GetModel('SL2DETAIL') 	//Model da SL2
Local cL2Item	:= ''								//Valor que sera gravado no L2_ITEM
Local nCont	:= 0								//Contador
Local cL1Num	:= STDGPBasket( 'SL1' , 'L1_NUM' )	//L1_NUM da venda
Local lFinServ := AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Define se habilita o controle de servicos financeiros

For nX := 1 To oMdlIte:Length()
	oMdlIte:GoLine(nX)
	If !oMdlIte:IsDeleted() 
		If SL2->(DbSeek(xFilial('SL2')+cL1Num+STDGPBasket( 'SL2' , 'L2_ITEM', nX )))
			nCont += 1
			
			If Len(AllTrim(Str(nCont))) == 1
				cL2Item := '0' + AllTrim(Str(nCont))
			Else
				cL2Item := AllTrim(Str(nCont))
			EndIf			
			
			If Val(cL2Item) > 99
				cL2Item := STBPegaIT(Val(cL2Item))
			EndIf
						
			RecLock("SL2",.F.)
			SL2->L2_ITEM := cL2Item
			MsUnLock() 

			STDSPBasket( 'SL2' , 'L2_ITEM', cL2Item, nX )
		EndIf  		
	EndIf
	
	//Tratamento para adicionar cobertura Servico Financeiro na importacao de Orcamentos
	If lFinServ .And. STBIsFinService(SL2->L2_PRODUTO)
		MBF->(dbSetOrder(1))
		
		//Verifica se Produto Financeiro vinculado e sem amarracao
		If MBF->(dbSeek(xFilial("MBF") + SL2->L2_PRODUTO)) .And. Empty(SL2->L2_PRDCOBE)
			STDFinVinc(oMdlIte, nX)
		EndIf
	EndIf
	
Next nX

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSumImp
Soma o tatal dos impostos da lei dos impostos

@param   	
@author  	Varejo
@version 	P11.8
@since   	03/04/2013
@return  	nTotImp
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSumImp()

Local nX		:= 0								//Variavel de loop
Local oMdl 	:= STDGPBModel() 					//Recupera o Model
Local oMdlIte	:= oMdl:GetModel('SL2DETAIL') 	//Model da SL2
Local nTotImp	:= 0								//Total de Impostos
Local nTotFED	:= 0								//Total de Impostos Federais
Local nTotEST	:= 0								//Total de Impostos Estaduais
Local nTotMUN	:= 0								//Total de Impostos Municipais
Local lCpoImpEnt 	:=	SL2->(FieldPos("L2_TOTFED")) > 0 .AND. ;
						SL2->(FieldPos("L2_TOTEST")) > 0 .AND. ;
						SL2->(FieldPos("L2_TOTMUN")) > 0 // Verifica a existencia do campo de Total de Imposto NCM/NBS

For nX := 1 To oMdlIte:Length()
	oMdlIte:GoLine(nX)
	If !oMdlIte:IsDeleted()
		nTotImp += oMdlIte:GetValue('L2_TOTIMP')
		If lCpoImpEnt
			nTotFED += oMdlIte:GetValue('L2_TOTFED')
			nTotEST += oMdlIte:GetValue('L2_TOTEST')
			nTotMUN += oMdlIte:GetValue('L2_TOTMUN')
		EndIf
	EndIf
Next nX

Return Iif(!lCpoImpEnt,nTotImp,{nTotImp,nTotFED,nTotEST,nTotMUN})


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STBGetResPgto
Retorna o valor total do resumo de pagamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	01/07/2014
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STBGetResPgto()
Local nVLTotal := 0					// Resultado
Local nX       := 0					// Contador

If !Empty(aTotal)
	For nX:= 1 to len(aTotal)
		If aTotal[nX][2] < 0
			nVLTotal := -1 * aTotal[nX][2]
		Else
			nVLTotal :=  nVLTotal + aTotal[nX][2]	
		Endif 	
	Next
Endif	

Return nVLTotal


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRmsCheck
Retorna os dados do cheque para integraÁ„o de CRM com a RMS

@author	Varejo
@since		16/08/2014
@version	11
/*/
//-------------------------------------------------------------------
Function STBRmsCheck()

Local aRms := Array(14) //Variavel de retorno 

aRms[1] := Val(STDGPBasket("SL1", "L1_FILIAL"))
aRms[2] := Val(STDGPBasket("SL1", "L1_ESTACAO"))
aRms[3] := Val(STDGPBasket("SL1", "L1_DOC"))
aRms[4] := STDGPBasket("SL1", "L1_OPERADO")
aRms[5] := SubStr(DToC(STDGPBasket("SL4", "L4_DATA")),Len(DToC(STDGPBasket("SL4", "L4_DATA")))-3,4) + "-"+SubStr(DToC(STDGPBasket("SL4", "L4_DATA")),Len(DToC(STDGPBasket("SL4", "L4_DATA")))-6,2)+"-"+SubStr(DToC(STDGPBasket("SL4", "L4_DATA")),1,2) 
aRms[6] := STDGPBasket("SL4", "L4_ADMINIS")
aRms[7] := STDGPBasket("SL4", "L4_AGENCIA")
aRms[8] := STDGPBasket("SL4", "L4_CONTA")
aRms[9] := STDGPBasket("SL4", "L4_NUMCART")
aRms[10] := STDGPBasket("SL4", "L4_CODCRM") 
aRms[11] := STFCpfCli()
aRms[12] := STDGPBasket("SL4", "L4_VALOR")
aRms[13] := ""
aRms[14] := "0"

Return aRms


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRmsConv
Retorna os dados do convenio para integraÁ„o de CRM com a RMS

@author	Varejo
@since		16/08/2014
@version	11
/*/
//-------------------------------------------------------------------
Function STBRmsConv()

Local aRms := Array(9) //Variavel de retorno 

aRms[1] := Val(STDGPBasket("SL1", "L1_FILIAL"))
aRms[2] := Val(STDGPBasket("SL1", "L1_ESTACAO"))
aRms[3] := Val(STDGPBasket("SL1", "L1_DOC"))
aRms[4] := STDGPBasket("SL1", "L1_OPERADO")
aRms[5] := STDGPBasket("SL4", "L4_CODCRM")
aRms[6] := IIF(!Empty(STDGPBasket("SL4", "L4_NUMCART")),2,1)
aRms[7] := IIF(!Empty(STDGPBasket("SL4", "L4_NUMCART")),STDGPBasket("SL4", "L4_NUMCART"),STFCpfCli()) //STDGPBasket("SL4", "L4_NUMCART")
aRms[8] := STDGPBasket("SL4", "L4_VALOR")
aRms[9] := "0"

Return aRms


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetDInsArr
Retorna o valor que o cliente fez doaÁ„o ao Instituto Arredondar
@author  	Varejo
@version 	P11.8
@since   	04/11/2014
@return  	nDArredondar  - Retorna o valor que o cliente fez doaÁ„o ao Instituto Arredondar com a taxa adm. descontada
@obs     
@sample
/*/
*/
//-------------------------------------------------------------------
Function STBGetDInsArr()
Local nRet	:= 0

If nDArredondar == 0
	nRet := nArredondar
Else 
	nRet := nDArredondar
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetDInsArr
Atribui o valor que o cliente fez doaÁ„o ao Instituto Arredondar

@param1   	nValor
@author  	Varejo
@version 	P11.8
@since   	04/11/2014
@return  	Nil  	
@obs     
@sample
/*/
*/
//-------------------------------------------------------------------
Function STBSetDInsArr( nValor )

Default nValor := 0

nDArredondar := nValor

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBAdjustingPay
Soma os valores referentes as formas realizadas manualmente

@param   	nVlTotal, cForma, oMdlGrd
@author  	Varejo
@version 	P11.8
@since   	28/04/2015
@return  	Nil  	
@obs     
@sample
/*/
*/
//-------------------------------------------------------------------

Function STBAdjustingPay(nVlTotal,cForma)

Local aArea 		:= GetArea()
Local nValorTot 	:= 0
Local nX 			:= 0
Local cFormaTEF		:= ""
Local lPOS			:= FindFunction("STFIsPOS") .AND. STFIsPOS()
Local oModel		:= Nil 
Local oMdlGrd		:= Nil

If lPOS
	oModel	:= STISetMdlPay()
	If ValType(oModel) <> "U"
		oMdlGrd	:= oModel:GetModel("PARCELAS")	//Seta o model do grid
	EndIf	
EndIf

If oMdlGrd <>  Nil

	DbSelectArea("SX5")
	DbSeek(xFilial("SX5") + "24")
	//Procura a forma na tabela 24
	While !Eof() .AND. SX5->X5_FILIAL == xFilial("SX5") .AND. SX5->X5_TABELA == "24"
    	//Verifica se encontrou a forma TEF recebida na funcao
		If Upper(AllTrim(SX5->X5_DESCRI)) == Upper(Alltrim(cForma))
			//Guarda o tipo da forma TEF
			cFormaTEF := Alltrim(SX5->X5_CHAVE)
			Exit
		EndIf	
		DbSkip()
	End			
			
	// Soma forma passada para funcao
	// No array oMdlGrd:aCols n„o existe forma CC ou CD e sim a descricao da forma
	For nX := 1 to Len(oMdlGrd:aCols)
		oMdlGrd:GoLine(nX)
		If Alltrim(oMdlGrd:aCols[nX][4]) == cFormaTEF  
			nValorTot 	+= oMdlGrd:aCols[nX][3]			
		Endif
	Next

	RestArea(aArea)
EndIf
	
Return(nValorTot)			



//-------------------------------------------------------------------
/*/{Protheus.doc} STBValFormPay
Executa validaÁ„o do bot„o OK das formas de pagamento

@param1   	cTipoForma - Tipo da forma de pagamento
@param2		nValor - Valor da forma de pagamento
@param3		nParc - Quantidade de parcelas
@author  	Varejo
@version 	P11.8
@since   	28/04/2015
@return  	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValFormPay(cTipoForma,nValor,nParc)
Local lRet			:= .T.
Local lSTValFormPay	:= ExistBlock("STValFormPay")

Default cTipoForma	:= ""
Default nValor		:= 0
Default nParc		:= 1

//Parcela tem que ser 1 - mesmo se for a vista
If nParc < 1
	nParc := 1
EndIf

If lSTValFormPay
	lRet := ExecBlock("STValFormPay",.F.,.F.,{cTipoForma,nValor,nParc})
EndIf

If lRet .AND. ExistFunc('STBValParc')
	lRet := STBValParc(nParc,nValor)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBLDsAcFin
Limpa o desconto financeiro, acrescimo financeiro e o desconto na 
multi negociaÁ„o

@author  	Varejo
@version 	P11.8
@since   	03/08/2015
@return  	Nil  	
/*/
//-------------------------------------------------------------------
Function STBLDsAcFin()
Local oTotal		:= STFGetTot() //Totalizador
Local cCondicao		:= "" 		//CondiÁao de pagamento
Local lExistSE4		:= .F.
Local lSTIDescMltN  := ExistFunc("STIDescMltNeg") .And. STIDescMltNeg()
Local lDesTot		:= ExistFunc("STBCDPGDes") .And. STBCDPGDes()

//Busca a condiÁao de pagamento
cCondicao := STBGetCdPg()
	
/* Limpa o desconto financeiro e desconto na multinegociaÁ„o */
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
lExistSE4 := SE4->(DbSeek(xFilial("SE4")+ cCondicao))
If ( lExistSE4 .AND. (SE4->(E4_DESCFIN + E4_ACRSFIN) > 0) ) .OR. lSTIDescMltN
	
	//Zera descontos
	STIClearDisc()

	/* Limpa o acrescimo e o desconto financeiro */
	STFSetTot( "L1_VLRTOT", oTotal:GetValue("L1_VLRTOT") - oTotal:GetValue("L1_ACRSFIN") - oTotal:GetValue("L1_DESCFIN"))
	STFSetTot( "L1_ACRSFIN", 0 )
	STFSetTot( "L1_JUROS", 0 )
	STFSetTot( "L1_VLRJUR", 0 )

	If lDesTot
		STFSetTot("L1_DESCFIN",0)
		STFSetTot("L1_DESCNF",0)
	EndIf

	/* Necess·rio limpar e atualizar os valores de impostos e totais da Matxfis pois sistema n„o
	estava zerando os valores apÛs selecionar uma condiÁ„o de pagamento com acrescimo. */

	//Altera os valores de impostos e bases do item	
	STBTaxAlt( "NF_ACRESCI"	, 0	)

	//Atualiza os valores de totais da MatxFis
	STFRefTot()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGrvTroco
Efetua a gravaÁ„o dos campos de Valor e Troco da forma de pagamento dinheiro

@param   	oMdlGrd - Objeto com os pagamentos
@param   	nX - linha da forma de pagamento
@author  	Varejo
@version 	P11.8
@since   	16/02/2016
@return  	Nil  	
@obs     
@sample
/*/

//-------------------------------------------------------------------
Function STBGrvTroco(oMdlGrd,nX, lAtuModel)
Local lMvLjTroco	:= SuperGetMV("MV_LJTROCO", ,.F.)	// Verifica se utiliza troco nas diferentes formas de pagamento
Local nMvLjTrDin	:= SuperGetMV("MV_LJTRDIN", , 0 )	// Determina se utiliza troco para diferentes formas de pagamento
Local nTroco		:= STBGetTroco()					// Valor de troco
Local nValor		:= oMdlGrd:GetValue("L4_VALOR")		// Valor total da venda

Default lAtuModel := .f.
If lMvLjTroco
	nValor := nValor - IIf(nMvLjTrDin == 0,0,nTroco)
Else
	nValor := nValor - nTroco
	nTroco := 0
EndIf

STDSPBasket("SL4","L4_VALOR",nValor,nX)
STDSPBasket("SL4","L4_TROCO",nTroco,nX)
If lAtuModel
	oMdlGrd:LoadValue("L4_VALOR",nValor)
	oMdlGrd:LoadValue("L4_TROCO",nTroco)
EndIf


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBClearCk
Limpar count estatica referente aos cheques

@param   	
@author  	Varejo
@version 	P11.8
@since   	06/04/2016
@return  	Nil  	
@obs     
@sample
/*/

//-------------------------------------------------------------------
Function STBClearCk()

nContCheque := 0	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGFormImp
Retorna o array com as formas de pagamento do orÁamento importado

@param   	
@author  	Varejo
@version 	P11.8
@since   	15/04/2016
@return  	Nil  	
@obs     
@sample
/*/

//-------------------------------------------------------------------
Function STBGFormImp()
Return aFormasImp

//-------------------------------------------------------------------
/*/{Protheus.doc} STSSFormImp
Seta o array com as formas de pagamento do orÁamento importado

@param   	aForma - Forma de pagamento a ser adicionada (
			aForma[1] - "C" - Forma (R$/CC/CD/CH...)
			aForma[2] - "N" - Valor
			aForma[3] - "C" - Data
			aForma[4] - "N" - Parcela
@author  	Varejo
@version 	P11.8
@since   	15/04/2016
@return  	.T.  	
@obs     
@sample
/*/

//-------------------------------------------------------------------
Function STBSFormImp(aForma)

Default aForma := {}

If Len(aForma) > 0
	aAdd(aFormasImp, aForma )
Else
	aFormasImp := {}
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBClearPay
FunÁ„o respons·vel por limpar todos os arrays estaticos do pagamento
Obs.: Nao existia uma unica funÁ„o que faÁa isso, e as funÁ„o de Zera pagamento 
e restart/start da venda fica chamando as mesmas funÁıes.
Favor centralizar aqui caso seja uma forma de pagamento que deve ser zerada no Zerar Pagmento
e no restart ou start da venda.

@param   	
@author  	Varejo
@version 	P11.8
@since   	15/04/2016
@return  	Nil  	
@obs     
@sample
/*/

//-------------------------------------------------------------------
Function STBClearPay()

STBSFormImp() //Limpar array de formas de pagamentos da importaÁ„o do orÁamento.

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRPayaCols
FunÁ„o respons·vel montar o acols dos pagamentos. Fez-se necessario
esta funÁ„o pois o metodo GetOldData() n„o retorna corretamente 
o aCols. 

@param   	oMdlGrd - Objeto de grid dos pagamentos.
@author  	Varejo
@version 	P11.8
@since   	15/06/2016
@return  	aRetaCols - Array com as formas de pagamento  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRPayaCols(oMdlGrd) 
Local aRetaCols	:= {}
Local aData		:= {}
Local nI 			:= 0

Default oMdlGrd	:= Nil

If oMdlGrd <> NIL

	aData := oMdlGrd:GetData()

	For nI := 1 To Len(aData)
		aAdd(aRetaCols, aClone(aData[nI][1][1]))
	Next nI
EndIf

Return aRetaCols

//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldForm
FunÁ„o respons·vel por validar se o usuario alterou tanto a quantidade de parcelas ou
valor do que foi negociado na pre-venda.
Caso a quantidade ou valor tenha sido alterado, vamos considerar que o PDV ira recalcular o
valor das parcelas e a data de vencimento.

@param   	oMdlGrd - Model com as parcelas
@param   	aFormasImp - Array com as formas negociadas na retaguarda
@author  	Varejo
@version 	P12
@since   	20/02/2018
@return  	lRet	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBVldForm(oMdlGrd,aFormasImp)
Local lRet := .F. //Variavel de retorno
Local nX := 0 //Variavel de loop
Local nContador := 0 //Contador das formas de pagamento
Local nValor := 0 //Valor das parcelas

For nX := 1 To Len(aFormasImp)
	If 	AllTrim(aFormasImp[nX][1]) == AllTrim(oMdlGrd:GetValue('L4_FORMA')) .And.;
	 	aFormasImp[nX][5] == oMdlGrd:GetValue('L4_FORMAID')
		
		nContador++
		nValor += aFormasImp[nX][2]
	EndIf
Next nX

If nContador == oMdlGrd:GetValue('L4_PARC') .And. nValor == oMdlGrd:GetValue('L4_VALOR')
	lRet := .T.
Else
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), ;
		"Houve alteraÁ„o do valor ou das parcelas pelo usuario," +;
		" neste caso tanto as datas e o valor serao recalculados pelo PDV." )  //Gera LOG
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIncMHX
FunÁ„o responsavel por realizar a preparaÁ„o dos dados para a gravaÁ„o nas tabelas MHJ e MHK

@param   	oMdlGrd - Model com as parcelas
@param   	oWFReceipt - Objeto com as informaÁıes referente ao recebimento realizado
@author  	Lucas Novais (lnovais)
@version 	P12
@since   	25/06/2018
@return  		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBIncMHX(oWFReceipt,oMdlGrd)
Local nX 		 := 0						//Variavel para for 
Local nI 		 := 0						//Variavel para for 
local aMHJ		 := {}						//Array para gravaÁ„o da tabela
local aMHK		 := {}						//Array para gravaÁ„o da tabela
Local cNumMHJ 	 := ""						//Variavel de incremental
Local cNumMHK 	 := ""						//Variavel de incremental
Local cLoteMHJ 	 := ""						//Variavel de incremental
local cMovimento := AllTrim(STDNumMov())	//Numero do movimento atual
Local dMovimento := dDataBase 				//Data do movimento

cLoteMHJ := GetSxeNum("MHJ","MHJ_LOTE","MHJ_LOTE" + xFilial("MHJ") )
ConfirmSx8()

For nX := 1 To len(oWFReceipt:aListTitles[4]) //Pego a lista de titulos baixados
	
	If oWFReceipt:aListTitles[4][nX][1]

		cNumMHJ := GetSxeNum("MHJ","MHJ_NUM")
		ConfirmSx8()

		aAdd( aMHJ,{} )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_FILIAL", xFilial("MHJ")					 } )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_NUM"	 , cNumMHJ							 } )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_PRXTIT", oWFReceipt:aListTitles[4][nX][2]  } )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_NUMTIT", oWFReceipt:aListTitles[4][nX][3]  } )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_PARTIT", oWFReceipt:aListTitles[4][nX][4]  } )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_LOTE"  , cLoteMHJ						 	 } )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_VALOR" , oWFReceipt:aListTitles[4][nX][10] } )
		aAdd( aMHJ[len(aMHJ)], { "MHJ_SITUA" , "00" 							 } )
		
	EndIf

Next Nx

For nI := 1 To oMdlGrd:Length() 

	oMdlGrd:GoLine(nI)

	cNumMHK	:= GetSxeNum("MHK","MHK_NUM")
	ConfirmSx8()
		
	aAdd( aMHK, {} )
	aAdd( aMHK[len(aMHK)], { "MHK_FILIAL",  xFilial("MHK")			        		   } )
	aAdd( aMHK[len(aMHK)], { "MHK_NUM"   ,	cNumMHK						    		   } )
	aAdd( aMHK[len(aMHK)], { "MHK_LOTE"  ,  cLoteMHJ		 			 			   } )
	aAdd( aMHK[len(aMHK)], { "MHK_NUMMOV",  cMovimento			 					   } )
	aAdd( aMHK[len(aMHK)], { "MHK_BANCO" ,	xNumCaixa()					 			   } )
	aAdd( aMHK[len(aMHK)], { "MHK_DATMOV",	dMovimento					 			   } )
	aAdd( aMHK[len(aMHK)], { "MHK_TIPOPG",	oMdlGrd:getvalue("L4_FORMA") 			   } )
	aAdd( aMHK[len(aMHK)], { "MHK_CODADM",	SUBSTR(oMdlGrd:getvalue("L4_ADMINIS"),1,3) } )
	aAdd( aMHK[len(aMHK)], { "MHK_DESADM",	SUBSTR(oMdlGrd:getvalue("L4_ADMINIS"),6,20)} )
	aAdd( aMHK[len(aMHK)], { "MHK_VALOR" , 	oMdlGrd:getvalue("L4_VALOR")			   } )
	aAdd( aMHK[len(aMHK)], { "MHK_SITUA" , 	"00" 									   } )
		
Next nI

If ExistFunc("STDGrvMHX")
	STDGrvMHX(aMHJ,aMHK)
Else 
	LjGrvLog("STBIncMHX","FunÁ„o STDGrvMHX n„o existe no RPO, a ausencia desta funÁ„o implicara na conferÍncia  de caixa n„o listando os recebimentos realizados.")
EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCancPay
FunÁ„o responsavel por avaliar se o caixa tem a permiss„o para cancelar as formas de pagamento definida no orÁamento 

@author  	Lucas Novais (lnovais)
@version 	P12
@since   	10/10/2018
@return		lRet - indica se o usuario tem permiss„o para alterar as formas de pagamento	
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STBCancPay()
Local lRet 			:= .T.										 // Variavel para retorno 
Local lImport		:= !Empty(STDGPBasket("SL1" , "L1_NUMORIG")) // Variavel de controle que identifica se È importaÁ„o de orÁamento

If lImport .AND. !STFProfile(41)[1]
	lRet := .F.
	STFMessage(ProcName(),"STOP",STR0025) //"Usuario sem permiss„o para alterar a negociaÁ„o do orÁamento."
	STFShowMessage(ProcName())
Endif 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGrvSatT
Prepara as informaÁıes de impostos PIS, Cofins, CST etc. para XML SAT

@author  	Marisa Cruz
@version 	P12
@since   	02/04/2020
@param		nil
@return		nil	
@obs     	PrÈ-requisito: SAT validado
@sample
/*/
//-------------------------------------------------------------------
Function STBGrvSatT()

Local lExistGetTriSat := ExistFunc("LjGetTriSat") .AND. ExistFunc("LjSetTriSat")
Local nX			:= 0
Local aSATTrib		:= {}													//TributaÁ„o produto SAT
Local nItAux		:= 0													//Tratamento aSATTrib
Local nItAnt		:= 0													//Tratamento aSATTrib
Local nItAtual		:= 0													//Tratamento aSATTrib

If lExistGetTriSat						//Somente SAT

	//aSatTrib: … um conjunto de elementos, lido pelo MatxFis, e gravado em XML Sat sem alterar qualquer elemento armazenado em Matxfis.
	//Para o TOTVS PDV e SAT, sua matriz È composta de itens que n„o foram deletados. Os deletados previamente n„o constam em alguma linha de array.
	aSATTrib		:= LjGetTriSat()	//TributaÁ„o produto SAT

	//aSATTrib[x][1] Numero do item real, contando os deletados. Aqui n„o constam mais os itens deletados.
	//aSATTrib[x][2] Campo a ser pesquisado
	//aSATTrib[x][3] Valor do campo
	//aSATTrib[x][4] Numero do item SEM CONTAR OS DELETADOS, apÛs novo filtro antes do envio XML SAT (Somente TOTVS PDV)

	//Exemplo:
	//ITEM 1 - DELETADO - n„o consta mais no array aSATTrib
	//ITEM 2 - DELETADO - n„o consta mais no array aSATTrib
	//ITEM 3 - ABERTO
	//ITEM 4 - DELETADO - n„o consta mais no array aSATTrib
	//ITEM 5 - ABERTO

	//ApÛs o tratamento abaixo, gravar· no elemento 4 o item 1 no item 3 e o item 2 no item 5.
	//3 - IT_BASECOF - 3,00 - 1
	//5 - IT_BASECOF - 3,00 - 2
	//O resultado È lido no XML SAT a partir do elemento 4.

	nItAux := 0
	nItAtual := 0
	For nX := 1 to Len(aSatTrib)
		nItAnt := aSatTrib[nX][1]
		If nItAnt <> nItAux
			nItAtual++					//Recontagem do n˙mero de itens e atribuo mais tarde no elemento 4
		EndIf
		nItAux := nItAnt
		aSatTrib[nX][4] := nItAtual		//Atualizo o n˙mero do item a ser passado pelo XML SAT
	Next
	LjSetTriSat(aSATTrib)
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBFiltPay
Filtra os meios de pagamento que ficar„o disponÌveis para seleÁ„o na interface.

@author  	Alberto Deviciente
@version 	P12.1.27
@since   	17/03/2021

@param		aGetSX5Pay, Array, RelaÁ„o dos meios de pagamentos disponÌveis para uso.
@param		lOmitePgto, LÛgico, Determina se deve omitir formas de pagamento conforme regra da template function "FRTALTPG" (Drogaria)

@return		aRet, Array, Meios de pagamento que ficar„o disponÌveis para seleÁ„o na interface.
/*/
//-------------------------------------------------------------------
Function STBFiltPay(aGetSX5Pay,lOmitePgto)
Local aRet 	 	:= {}
Local lPayOk    := .F.
Local cFormaPag := ""
Local nX        := 0
Local aFormPgOk := {"CP"} //Meios de pagamento que n„o podem ser retiradas da tela de seleÁ„o (CP=CondiÁ„o de Pagamento)

If lOmitePgto
    //Percorre as formas de pagamento para filtar apenas as formas permitidas na template function "FRTALTPG" (Template de Drogaria)
    For nX:=1 To Len(aGetSX5Pay[2])
        cFormaPag := aGetSX5Pay[2][nX][1]

        If aScan( aFormPgOk, cFormaPag ) == 0
			//Template Function utilizada para omitir formas de pagamento.
            lPayOk := ExecTemplate("FRTALTPG",.F.,.F., { Nil, cFormaPag, Nil, Nil } )
        Else
            lPayOk := .T.
        EndIf

        If lPayOk
            aAdd( aRet, aGetSX5Pay[1][nX] )
        EndIF
    Next nX
Else
	aRet := aClone(aGetSX5Pay[1])
EndIf

Return aRet