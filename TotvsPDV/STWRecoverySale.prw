#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"     
#INCLUDE "STWRECOVERYSALE.CH"

Static lVendaRecup := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRecoverySale
Recuperação de Venda

@param	 lEmptySale, lógico
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRecovery			Retorna se a venda foi recuperada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWRecoverySale( lEmptySale )
Local lRecovery		:= .T.				// Retorna se recuperou a venda
Local lImported		:= .F.
Local lReserve		:= .F.
Local aHasPrint		:= {}				// Armazena 1 - possui itens de reserva , 2 - possui itens de impressao	 
Local aSale			:= {}				// Armazena venda a ser recuperada
Local aSL1			:= {}				// Armazena cabecalho do aSale
Local aSL2			:= {}				// Armazena Itens do aSale
Local aSL4			:= {}				// Armazena Pagamentos do aSale
Local lNFCe			:= LjEmitNFCe()		// Sinaliza se utiliza NFC-e
Local lUseSat		:= STFGetCfg("lUseSAT",.F.) //verifica se utiliza SAT
Local lInutNFCE		:= .F.
Local lCancelSale	:= .F.

DEFAULT lEmptySale := .F.

/*/
	Busca venda a ser recuperada
/*/

LjGrvLog( Nil, "Inicio - Processo de Recuperação de Venda." )  //Gera LOG
LjGrvLog( Nil, "Verifica se existe venda a ser recuperada." )

aSale := STDRSGetSale()

Do Case
	Case Len(aSale) <= 0
		lRecovery := .F.
		lEmptySale := .T.
	Case Len(aSale[2]) <= 0 // Nenhum item adicionado
		lRecovery := .F.
	Otherwise
		aSL1 := aSale[1]
		aSL2 := aSale[2]
		aSL4 := aSale[3]
		LjGrvLog( Nil, "Existe venda à ser recuperada. L1_NUM = " + aSale[1][AScan( aSale[1], { |x| x[1] == "L1_NUM" } )][2] )  //Gera LOG
EndCase

/*/
	Verifica se pode recuperar Venda
/*/
If lRecovery
	lRecovery := STBRSCanRecovery()
EndIf

If !lRecovery .AND. !lEmptySale .AND. Len(aSale[1]) > 0
	LjGrvLog( "L1_NUM: " + aSale[1][AScan( aSale[1], { |x| x[1] == "L1_NUM" } )][2], "Realiza a deleção do SL1, SL2 e SL4 e SE5" )  //Gera LOG
	STDCSDeleteSale( aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_NUM" 	} 	)][2] )
EndIf

/*/
	Valida se eh o mesmo operador, senão fechar o POS
/*/
If lRecovery 
 
	If !( STDRSSameCash() )
		lRecovery := .F.
	EndIf		
EndIf

/*/
	Detectar Troca de ECF
/*/
If lRecovery
	cPDV := aSL1[AScan( aSL1 , { |x| x[1] == "L1_PDV" } )][2]
	If STBRSStationChange( cPDV ) 

		STDCSDeleteSale( aSL1[AScan( aSL1 , { |x| x[1] == "L1_NUM" 	} 	)][2] )
		lRecovery := .F.
		STFMessage(ProcName(),"STOP","Os itens foram impressos em outro ECF. Este cupom será cancelado.")
		STFShowMessage(ProcName())
		LjGrvLog( "L1_NUM: " + aSL1[AScan( aSL1 , { |x| x[1] == "L1_NUM" } )][2], "Os itens foram impressos em outro ECF. Este cupom será cancelado." )  //Gera LOG
	EndIf
EndIf

/*/
	Detectar Cupom Aberto
/*/
If lRecovery
	aHasPrint := STBRSHasPrint( aSL2 )
	
	If aHasPrint[2] // Tem Impressao
		// Se o cupom estiver fechado, faz tratamento e nao recupera a venda
		lRecovery := STBRSCloseCupCancel( aSale )
	EndIf
EndIf

/*/
	Caso seja Importação de Orçamento
/*/
If lRecovery
	lImported := !Empty(aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_NUMORIG" } )][2])
	lReserve  := aHasPrint[1]
	
	lCancelSale := IsInCallStack("STFPOSAUTO")

	If lReserve .OR. lImported .OR. lCancelSale // Se houver reserva ou o orçamento seja importado, o cupom deve ser cancelado. A venda, portanto, não sera recuperada
		lRecovery := .F.
		If lReserve
			STFMessage(ProcName(),"STOP","O Sistema irá finalizar o Cupom, pois existe item de reserva.") //"O Sistema irá finalizar o Cupom, pois existe item de reserva."
			LjGrvLog( "L1_NUM: "+aSale[1][AScan( aSale[1], { |x| x[1] == "L1_NUM" } )][2], "O Sistema irá finalizar o Cupom, pois existe item de reserva." )  //Gera LOG
		ElseIf lImported
			STFMessage(ProcName(),"STOP","O Sistema irá finalizar o Cupom. O orçamento deve ser importado novamente.") //"O Sistema irá finalizar o Cupom, O orçamento deve ser importado novamente"
			LjGrvLog( "L1_NUM: "+aSale[1][AScan( aSale[1], { |x| x[1] == "L1_NUM" } )][2], "O Sistema irá finalizar o Cupom. O orçamento deve ser importado novamente." )  //Gera LOG
		EndIf
		STFShowMessage(ProcName())
		
		LjGrvLog( "L1_NUM: "+aSale[1][AScan( aSale[1], { |x| x[1] == "L1_NUM" } )][2], "Realiza o cancelamento da venda." )  //Gera LOG
		STBRSCancelSale( aSale, aHasPrint[2] )
		
	EndIf
EndIf

/*/
	Realizar recuperação
/*/
If lRecovery
	LjGrvLog( "L1_NUM: "+aSale[1][AScan( aSale[1], { |x| x[1] == "L1_NUM" } )][2], "Recuperando da venda..." )  //Gera LOG
	STB7Recovered(.T.)
	STWRSVerRe( .F. , .T. )
	If !lNFCe
		STWCancelSale( 	.T. 		, /*lIsProgressSale*/ , /*cSuperior*/ 	 , /*cDoc*/	, ;
						/*cNumSale*/ 	, /*lCancVenc*/		 , /*cNFisCanc */ , aSale[1][AScan( aSale[1], { |x| x[1] == "L1_NUM" } )][2]	)
	ElseIf !lUseSat 
		lInutNFCE := STBChkInut()
	EndIf
	lRecovery := STWRSRecovery( aSale, lInutNFCE ) //Depois recupera a venda, carregando-a como uma nova venda
	STWRSVerRe( .T. )
EndIf

LjGrvLog( Nil, "Fim - Processo de Recuperação de Venda." )  //Gera LOG

Return lRecovery

//-------------------------------------------------------------------
/*{Protheus.doc} STWRSRecovery
Realiza recuperaçao da venda

@param   aSale						Venda com Cabeçalho, Itens e Pagamentos (SL1,SL2,SL4)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						 	Retorna se Realizou a Recuperação da venda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWRSRecovery( aSale, lInutNFCE )
Local lRet			:= .T.											// Retorna se Recuperou a venda
Local aSL1			:= {}											// Cabeçalho da venda
Local aSL2			:= {}											// Itens da venda
Local aSL4			:= {}											// Formas de pagamento
Local aPrinter		:= {}											// Armazena Retorno da Impressora
Local aDados		:= {}
Local nI			:= 0											// Contador
Local nPosL1Situa	:= 0											// Posicao do SL1_SITUA no array
Local cTotItens		:= ""											// Total de itens da Impressora
Local cTotal		:= ""											// Armazena o valor Total da impressora
Local cCliCode		:= ""											// Armazena codigo cliente
Local cCliStore		:= ""											// Armazena Loja Cliente
Local cCliType		:= ""											// Armazena Tipo do Cliente (A1_TIPO)
Local lNFCe			:= STFGetStat("NFCE")							// nfce
Local lUseSat		:= LjUseSat()									// Usa Sat
Local cVendedor		:= ""											// Vendedor da venda recuperada
Local nPosIDITREL	:= 0											// Posição do campo L2_IDITREL
Local lPendSale		:= .F.
Local cCliCPF		:= ""											// L1_CGCCLI  para SIGACRD
Local cCliCart		:= ""											// L1_CGCCART para SIGACRD
Local oCliModel     := Nil                                          // 
Local cMatricula	:= ""                                           // Matricula do cliente no caso de Convênio (Template Drogaria)

Default aSale		:=	{} 
Default lInutNFCE	:= .F.

aSL1 := aSale[1]
aSL2 := aSale[2]
aSL4 := aSale[3]

nPosL1Situa := AScan( aSL1 , { |x| x[1] == "L1_SITUA" }	)

If lRet
	
	/*/
		Atualiza o SL1 na Cesta
	/*/
	
	For nI := 1 To Len(aSL1)
		STDSPBasket( "SL1" , aSL1[nI,1],aSL1[nI,2] )
	Next nI
	
	cCliCode		:= aSL1[AScan( aSL1 , { |x| x[1] == "L1_CLIENTE"	} 	)][2]		// Armazena codigo cliente
	cCliStore		:= aSL1[AScan( aSL1 , { |x| x[1] == "L1_LOJA"		} 	)][2]		// Armazena Loja Cliente
	cCliType		:= aSL1[AScan( aSL1 , { |x| x[1] == "L1_TIPOCLI"	} 	)][2]		// Armazena Tipo do Cliente (A1_TIPO)
	cCliCPF			:= aSL1[AScan( aSL1 , { |x| x[1] == "L1_CGCCLI"		} 	)][2]		// CPF/CNPJ 
	cCliCart		:= aSL1[AScan( aSL1 , { |x| x[1] == "L1_CGCCART"	} 	)][2]		// Cartão SIGACRD 

	/*/
		Seta o model do cliente
	/*/
	oCliModel := STWCustomerSelection(cCliCode+cCliStore)
	
	If ExistFunc("STBSetCrdIdent")
		If ExistFunc("LJIsDro") .And. LJIsDro() //Verifica se usa o Template de Drogaria
            cMatricula := oCliModel:GetValue("SA1MASTER","A1_MATRICU")
        EndIf
		STBSetCrdIdent( cCliCart, cCliCPF, cCliCode, cCliStore, cMatricula ) // Seta SIGACRD
	EndIf
	
	/*/
		Seta o model do vendedor
	/*/
	cVendedor := aSL1[AScan( aSL1 , { |x| x[1] == "L1_VEND"	} 	)][2]		// Armazena codigo vendedor
	STWSalesmanSelection(cVendedor)

	If lInutNFCE
		If !Empty(STDGPBasket("SL1","L1_DOC"))	.AND. STDGPBasket("SL1","L1_DOC") <> "NFCE" .AND.;
			!Empty(STDGPBasket("SL1","L1_SERIE")) .AND. ;
			(Empty(STDGPBasket("SL1","L1_KEYNFCE")) .OR. ;
			(!Empty(STDGPBasket("SL1","L1_KEYNFCE")) .AND. STDGPBasket("SL1","L1_SITUA") == "65"))
			lPendSale := STWInuNFCE(STDGPBasket("SL1","L1_DOC")		, STDGPBasket("SL1","L1_SERIE"), STDGPBasket("SL1","L1_PDV"),;
											STDGPBasket("SL1","L1_OPERADO")	, STDGPBasket("SL1","L1_ESTACAO"), "" )
			If lPendSale								
				lPendSale := STWDelPay( STDGPBasket("SL1","L1_NUM") )
			EndIf
			
		Else
			//Deleta os dados do pagamento
			lPendSale := STWDelPay( STDGPBasket("SL1","L1_NUM") )
		EndIf
	EndIf
	
	/*/
		Registra os Itens
	/*/
	nPosIDITREL := AScan( aSL2[1] , { |x| x[1] == "L2_IDITREL"	} 	)
	For nI := 1 To Len(aSL2)	
		
		//Seta vendedor da venda original - Multiplos vendedroes
		If SuperGetMV("MV_LJPDVEN", ,.F.)
			STDSPBasket("SL1","L1_VEND"	, aSL2[nI][AScan( aSL2[nI] , { |x| x[1] == "L2_VEND"	} 	)][2] )
		EndIf	

		//Seta quantidade
		STBSetQuant( aSL2[nI][AScan( aSL2[nI] , { |x| x[1] == "L2_QUANT"	} 	)][2] )				

		// Registra Item
		STWItemReg( 	nI 				, aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_PRODUTO"	} 	)][2] 	, cCliCode 	, cCliStore	, ;
						STBGetCurrency(), aSL2[nI][AScan( aSL2[1] , { |x| x[1] == "L2_VALDESC"	} 	)][2] 	, "V"			, NIL	, ;
						NIL				, cCliType,,,;
						,,.T.,,;
						,,,,;
						,,,,;
						Iif(nPosIDITREL > 0,aSL2[nI][nPosIDITREL][2],""),aSL2[nI][AScan ( aSL2[1] , { |x| x[1] == "L2_VALEPRE"	})][2])

		If aSL2[nI][AScan( aSL2[nI] , { |x| x[1] == "L2_SITUA"	} 	)][2] == "05"
			STWCancelProcess( Val(aSL2[nI][AScan( aSL2[nI] , { |x| x[1] == "L2_ITEM"	} 	)][2]) )
		EndIf
	Next nI 
	
	
	If !lNFCe .And. !lUseSat
		/*/
			Verifica a impressora tem funções de total de itens e de subtotal da venda e faz a comparacao dos valores
		/*/
		// Verifica Status da Impressora - Evento STPrinterStatus
		aPrinter := STFFireEvent(ProcName(0),"STPrinterStatus",{ "12" , "" }) 
		If Len(aPrinter) > 0 .AND. ValType(aPrinter[1]) == "N" .AND. aPrinter[1] == 0 // Possui
			aDados := {""}
			
			/*/
				 Verifica o numero total de itens impressos - Evento STNumItemPrint
			/*/
			
			aPrinter := STFFireEvent(ProcName(0),"STNumItemPrint",aDados) 
			If Len(aPrinter) > 0 .AND. ValType(aPrinter[1]) == "N" .AND. aPrinter[1] == 0 .AND. Len(aDados) > 0 // Possui
				cTotItens := aDados[1]
				If Val(cTotItens) == Len(aSL2)  
					aDados := {"",""}
					
					/*/ 
						Verifica o subtotal da venda - Evento STSubTotalReceipt
					/*/
					
					aPrinter := STFFireEvent(ProcName(0),"STSubTotalReceipt",aDados) 
					If Len(aPrinter) > 0 .AND. ValType(aPrinter[1]) == "N" .AND. aPrinter[1] == 0 .AND. Len(aDados) > 0 
						cTotal := aDados[1]
						If Val(cTotal)/100 <> aSL1[AScan( aSL1 , { |x| x[1] == "L1_VALMERC"	} 	)][2] // Consistencia dos totais
							STFMessage(ProcName(),"STOP","Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.")
							STFShowMessage(ProcName())
							lRet := .F.
						EndIf
					EndIf
				Else
					STFMessage(ProcName(),"STOP","Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.")
					STFShowMessage(ProcName())
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf	
EndIf

SL1->(RollBackSx8())
STB7Recovered(lRet)
	
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STWRSVerRe
Retorna o conteúdo da variável estática lVendaRecup

@param   lReset, lógico, reseta variavel ?
@author  Varejo
@version P12
@since   14/04/2020
@return  lVendaRecup, lógico, valida se esta numa recuperada
/*/
//-------------------------------------------------------------------
Function STWRSVerRe(lReset,lVal)

Default lReset	:= .F.
Default lVal	:= NIL

If lReset
	lVendaRecup := .F.
EndIf

If ValType(lVal) == "L"
	lVendaRecup := lVal
EndIf

Return lVendaRecup
