#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWPAYCARD.CH"

static lIsPaf 		:= STBIsPAF()
Static aIdPgtoMfe	:= {}												//Id's de pagamento enviados ao Validador Fiscal MFe
Static lMFE			:= IIF( ExistFunc("LjUsaMfe"), LjUsaMfe(), .F. )	//Se utiliza MFE
Static lLjEnvPgto	:= ExistFunc("LjEnvPgto")
Static lIntegrador 	:= IIF( ExistFunc("LjUsaIntgr"),LjUsaIntgr(), .T.)	//Se utiliza MFe com Integrador

//--------------------------------------------------------------------
/*/{Protheus.doc} STWTypeTran
Verifica em qual qual o tipo de transação deve ser executada

@param
@author  Varejo
@version P11.8
@since   	20/02/2013
@return  	lRet - Se executou corretamente
@obs
@sample
/*/
//--------------------------------------------------------------------
Function STWTypeTran(oMdlMst, oTEF20, cTypeCard, nParc, lContTef)

Local oDados 		:= Nil		//Dados para a transacao
Local oRetTran		:= Nil		//Retorno da transacao
Local lRet 			:= .F.		//Retorno da funcao
Local cCupom		:= "" 		//Armazena o numero do cupom
Local lUltTran		:= IIF(ValType(oMdlMst) == 'O', STBCalcSald("2", oMdlMst:GetValue("L4_VALOR")), .T.) 	//'E ultima tansacao?
Local oTotal		:= STFGetTot()																			//Objeto total
Local nTotal		:= oTotal:GetValue("L1_VLRTOT")															//Valor total da venda
Local nValor		:= IIF(ValType(oMdlMst) == 'O', oMdlMst:GetValue("L4_VALOR"), nTotal)+STBGetInsArr()	//Valor da transacao
Local lTefManu		:= SuperGetMv('MV_TEFMANU',,.F.) 	//Se utiliza POS no lugar do TEF quando ocorrer algum problema
Local lFinVendaAut	:= SuperGetMv('MV_LJFCVDA',,1) == 1 //Se finaliza venda automaticamente caso saldo esteja zerado
Local oPanPayment   := STIGetPan()    					//Gera uma copia do oPanPayment original
Local aPayment		:= {}			  					//Armazena informações sobre pagamento, Ex.: Valor e parcela
Local aLtt			:= {.T.,""}

Default oMdlMst 	:= Nil
Default oTEF20	:= Nil
Default cTypeCard	:= ""
Default nParc		:= 1
Default lContTef	:= .F.

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Inicio STWTypeTran. Chamada por: " + ProcName(1) )
//Parcela tem que ser 1 - mesmo se for a vista
If nParc < 1
	nParc := 1
EndIf

If nValor > 0

	If !lContTef .AND. ((STWChkTef("CC") .AND. cTypeCard == "CC") .OR. (STWChkTef("CD") .AND. cTypeCard == "CD")) .OR. ( STWChkTef("PD") .AND. IsPDOrPix(cTypeCard) )
	
		If !Empty(cCupom := STBRetCup())
			
			If ExistFunc("STGetLTT") 
				aLtt := STGetLTT()
			EndIf

			If aLtt[1]
				nParc := IIF(ValType(oMdlMst) == 'O', oMdlMst:GetValue("L4_PARC"), nParc)

				If lMFE .And. lIntegrador .And. lLjEnvPgto
					LjMsgRun("Enviando pagamento para o VFP-e..." ,,{ || aAdd(aIdPgtoMfe,LjEnvPgto(nValor,.T.)) })
				EndIf				
		
				Do Case
		
					// Cartao de Credito (A vista e Parcelado)
					Case cTypeCard == "CC"
						oDados 		:= LJCDadosTransacaoCredito():New(nValor, Val(cCupom), Date(), Time(), "CC", "", "", .F., Nil, lUltTran)   					
						
						If nParc > 1						
						oDados:nParcela := nParc
						oRetTran := oTEF20:Cartao():Credito(oDados)
						else
						oRetTran := oTEF20:Cartao():Credito(oDados)
						nParc := oDados:nParcela  
						EndIf
						
					// Cartao de debito (A vista, Parcelado, Pre-datado)
					Case cTypeCard == "CD"
						oDados 	:= LJCDadosTransacaoDebito():New(nValor, Val(cCupom), Date(), Time(), "CD", "", "", .F., 1, lUltTran)
						oRetTran 	:= oTEF20:Cartao():Debito(oDados)

					// Pagamentos digitais 
					Case cTypeCard == "PD"
						/* 	Inicia a classe LJDadosTransacaoPgtoDigitais para alimentar as propriedades de valor e
							codigo da forma de pagamento que serao utilizadas posteriormente ao chamar a classe PagamentosDigitais  */
						oDados 				:= LJDadosTransacaoPgtoDigitais():New(nValor, "PD")
						oRetTran 	:= oTEF20:PgtoDigital():Digitais(oDados)		
					Case cTypeCard == "PX"
						oDados   := LJDadosTransacaoPgtoDigitais():New(nValor, "PX")
						oRetTran := oTEF20:PgtoDigital():Digitais(oDados)
				EndCase
		
				If oRetTran:oRetorno:nParcs < 1
					oRetTran:oRetorno:nParcs := nParc
				EndIf
		
				If (lRet := STBRetTef(oRetTran, oTEF20))
					nParc := oRetTran:oRetorno:nParcs
					
					//Parcela tem que ser 1 - mesmo se for a vista
					If nParc < 1
						nParc := 1
					EndIf
					STISetCard(.T.)
					STISetTef(oTEF20)
					STBCalcJur()
					
					STIAddPay(cTypeCard, oMdlMst, nParc, .T., /*cCodVp*/, nValor)
		
				Else
					LjGrvLog( "L1_NUM: "+ STDGPBasket('SL1','L1_NUM'), "TEF Retornou .F. | Operação não realizada." )
					If  AttIsMemberOf( oRetTran:oRetorno, "cErrorReason", .T.) .AND. !(Empty(oRetTran:oRetorno:cErrorReason))
						STFMessage("ErrorReason", "STOPPOPUP", STR0014 + oRetTran:oRetorno:cErrorReason) // "Não foi possivel continuar, motivo: "
						STFShowMessage( "ErrorReason")
					EndIf 
				EndIf
			Else 
				STFMessage("TEF", "STOPPOPUP", aLtt[2]) 
				STFShowMessage( "TEF")
			EndIf 

			If !lRet .AND. lTefManu .AND. !IsPDOrPix(cTypeCard)
				If MsgNoYes(STR0007,STR0008) //"Não foi possivel efetuar a transação com TEF, deseja continuar manualmente?" # "Atenção" 
					STISetContTef(.T.)
					LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "TEF MANUAL - SIM." )
					
					aPayment := {nValor , IIF(nParc<1,1,nParc)} 
					
					STIAddNewPan( oPanPayment, ,cTypeCard,aPayment)

				Else
					STISetContTef(.F.)
					LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "TEF MANUAL - NÃO." )
				EndIf				
			Else
				STISetContTef(.F.)
			EndIf
	
		Else
	
			STFMessage("STWPayCard","STOP",STR0001) //"Falha para obter o número do cupom fiscal!"
			STFShowMessage("STWPayCard")
	
		EndIf
	
	Else
		STBCalcJur()
		STIAddPay(cTypeCard, oMdlMst, IIF(ValType(oMdlMst) == 'O', oMdlMst:GetValue("L4_PARC"),nParc)) 
				
		If !STBIsImpOrc() 
			STISetContTef(.F.)
		EndIf
		
		lRet := .T.
	EndIf

Else

	STFMessage("STWPayCard","STOP", STR0002 + AllTrim(Str(nValor,10,2))) //"Valor inválido."
	STFShowMessage("STWPayCard")
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Valor inválido." )
EndIf

If lFinVendaAut .AND. lRet .And. STBCalcSald("1") == 0
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Chama Finalização da venda após TEF" )
	STIConfPay()
EndIf

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Retorno: " + IIF(lRet,".T.",".F.") )

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} STWPrintComp
Imprissao do comprovante TEF

@param   	oTEF20 - Objeto do TEF
@author  Varejo
@version P11.8
@since   	21/02/2013
@return  	lRet - Retorna se imprimiu corretamente
@obs
@sample
/*/
//--------------------------------------------------------------------
Function STWPrintComp(oTEF20)

Local lRelGer	:= .F.
Local cContGer	:= ""
Local cContCDC	:= ""
Local cContONF	:= ""
Local aDados	:= {}
Local aRet		:= {}
Local lRet				:= .T.    						//retorna se imprimiu comprovante

Default oTEF20 := Nil

ParamType 0 Var     oTEF20        As Object	Default Nil

If ValType(oTEF20) == 'O'

	If oTEF20:Cupom():Imprimir(Nil)
		/*
			Se a impressao for OK, confirma a transacao
		*/
		oTEF20:Confirmar(@lRelGer)

			// Retorna o Contador Geral de Operação Não Fiscal	
		If  lIsPAF
			aDados 	:= {"36", Space(6)}   

			aRet := STFFireEvent(ProcName(0), "STPrinterStatus", aDados)
						
			If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) < 1     
				STFMessage("STWPrintComp","STOP",STR0003) //"Falha na obtenção do Contador de Operação Nao Fiscal"
				STFShowMessage("STWPrintComp")    
			Else
				cContONF := aDados[2]
			EndIf
					
			// Retorna o Contador de Comprovante de Credito ou Debito		
			aDados 	:= {"38", Space(6)}   

			aRet := STFFireEvent(ProcName(0), "STPrinterStatus", aDados)
						
			If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) < 1     
				STFMessage("STWPrintComp","STOP",STR0004) //"Falha na obtenção do Contador de CDC"
				STFShowMessage("STWPrintComp")    
			Else
				cContCDC := aDados[2]
			EndIf
		
			If lRelGer 
			    // Retorna o Contador Geral de Relatório Gerencial	
				aDados 	:= {"38", Space(6)}   
	
				aRet := STFFireEvent(ProcName(0), "STPrinterStatus", aDados)
							
				If Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) < 1     
					STFMessage("STWPrintComp","STOP",STR0005) //"Falha na obtenção do Contador de Relatorio Gerencial"
					STFShowMessage("STWPrintComp")    
				Else
					cContGer := aDados[2]
				EndIf
			EndIf
			

			STDSPBasket("SL1", "L1_CONTONF", cContONF  )
			STDSPBasket("SL1", "L1_CONTCDC",  cContCDC )
			STDSPBasket("SL1", "L1_CONTRG",  cContGer)
		EndIf
	Else
		/*
			Se falho a impressao, cancela a transacao
		*/
		lRet := .F.

		oTEF20:Desfazer()
		STFMessage("TEF", "POPUP", STR0006)//"Transação não foi efetuada. Favor reter o cupom."
		STFShowMessage( "TEF")
	EndIf
EndIf

/*
	Seta a variavel lCard e lCheque para .F., além de zerar o ID dos cartões TEF
*/
STISetCard()
STBSetCheck()
If FindFunction("STBSetIDTF")
STBSetIDTF()
EndIf

Return lRet

/*/{Protheus.doc} STWGetIdPgto
	Retorna os Id's dos pagamentos enviados ao validador fiscal MFe
	@type  Function
	@author bruno.inoue
	@since 01/08/17
	@version 11.8
	@param 
	@return
/*/
Function STWGetIdPgto()
Return aIdPgtoMfe

/*/{Protheus.doc} STWZeraIdPgto
	Seta os Id's dos pagamentos enviados ao validador fiscal MFe
	@type  Function
	@author bruno.inoue
	@since 01/08/17
	@version 11.8
	@param 
	@return
/*/
Function STWZeraIdPgto(aId)
Default aId := {}
aIdPgtoMfe := aId
Return 
