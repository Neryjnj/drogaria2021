#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "STBBatchProcess.CH"

/*
	aTableInfo structure:
*/
#DEFINE TABLE              1
#DEFINE UNIQUE_INDEX       2
#DEFINE STATUS_INDEX       3
#DEFINE STATUS_FIELD       4
#DEFINE ERROR_FIELD        5	// Optional
#DEFINE STATE_TOPROCESS    6
#DEFINE STATE_PROCESSING   7
#DEFINE STATE_PROCESSED    8
#DEFINE STATE_ERROR        9

Static aBadRecno := {}

//-------------------------------------------------------------------
/*{Protheus.doc} STBBatchProcess
Inicia o processo do GrvBatch multi-thread. Pode ser chamado via Job ou Schedule.

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBBatchProcess(xParam,cFil,nThreads,nLotSize)
Local nSecondsBetweenRetry	:= -1
Local nX					:= 0
Local aFiliais				:= {}
Local cTitle                := STR0001 // "Processador de pedidos"
Local cText                 := STR0002 // "As vendas pendentes de processamento serao processadas."
Local aTableInfo            := {}

DEFAULT xParam				:= {}
DEFAULT	cFil				:= ""
DEFAULT nThreads			:= 2
DEFAULT	nLotSize			:= 10

RPCSetType(3)

aTableInfo	:= {	"SL1"						,;	// TABLE
					1							,;	// UNIQUE_INDEX
					16							,;	// STATUS_INDEX
					"L1_STBATCH"				,;	// STATUS_FIELD
					"L1_ERROBTC"				,;	// ERROR_FIELD
					"1"							,;	// STATE_TOPROCESS
					"2"							,;	// STATE_PROCESSING
					"3"							,;	// STATE_PROCESSED
					"4"							}	// STATE_ERROR

If ValType(xParam) == "A"
	If Len(xParam) > 2
		RpcSetEnv(xParam[1],xParam[2])
		STFBatchProcess(xParam[1], xParam[2], "STBGrvBatch", nThreads, nLotSize, , , nSecondsBetweenRetry, cTitle, cText, aTableInfo )

		RESET ENVIRONMENT
	EndIf
ElseIf !Empty(xParam) .AND. !Empty(cFil)

	aFiliais := STBCreateFilArray(cFil)

	For nX := 1 To Len(aFiliais)
		RpcSetEnv(xParam,aFiliais[nX])
		STFBatchProcess( xParam, aFiliais[nX], "STBGrvBatch", nThreads, nLotSize, , , nSecondsBetweenRetry, cTitle, cText, aTableInfo )

		RESET ENVIRONMENT
	Next nX

EndIf

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*{Protheus.doc} STBGrvBatch
Novo GrvBatch, preparado para ser executado em multi-thread.

@param
@author  	Vendas & CRM
@version 	P12
@since   	15/05/2012
@return
@obs
@sample
*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STBGrvBatch(cAlias,lMultFil,cKey,lTotvsPDV)
Local aFiles        := {}                                          	// Arquivos
Local nIntervalo    := 0                                           	// Intervalo para o Loop
Local nTimes        := 0                                           	// Numero de loop antes de entrar no while
Local lContinua     := .T.                                         	// Indica se a rotina deve continuar seu processamento.
Local aBadRecno  	:= {}			   			   				   	// Recnos
Local cFileName	:= cEmpAnt+cFilAnt	   			   				    // Nome do arquivo
Local nHandle		:= (MSFCreate("LJGR"+cFileName+".WRK") >= 0	)   // Indica se o arquivo foi criado
Local nCount 		:= 1						   				    // Contador
Local cTemp			:= ""			   			   				    // Temporario
Local lTemReserva	:= .F.                                       	// Verifica se existe algum item com reserva
Local lProcessou	:= .F.                                          // Verifica se processou as vendas na Retaguarda.
Local bOldError                                                    	// Bloco de tratamento de erro
Local lLJ7051		:= FindFunction("U_LJ7051")                   	// Verifica se a funcao LJ7051 esta compilada
Local lExProc 		:= .T.                                          // Controla o while do Killapp
Local lCriouAmb	    := .T.                                          // Verifica se o PREPARE ENVIRONMENT foi executado
Local nSleep		:= 0                                            // Utilizado para atribuicao na variavel nIntervalo
Local aAreaSL1		:= {}			   			   				    // Guarda a Area do SL1
Local nRecSL1		:= 0                                            // Guarda o Recno do SL1
Local lGerInt 		:= SuperGetMv("MV_LJGRINT",.F.,.F.)             // Verifica se a integracao esta habilitada
Local aRecFail		:= {}                                           // Registros que nao conseguiram ser travados
Local oLJCLocker 	:= Nil
Local lLj7064     	:= ExistBlock("LJ7064") 	   				    // Verifica se existe o ponto de entrada LJ7064
Local nOpcProc		:= 0                                            // Opcao de processamento
Local lLstPresAt	:= SuperGetMV("MV_LJLSPRE",.F.,.F.)             // SuperGetMV("MV_LJLSPRE",.F.,.F.) .AND. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)	//Lista de presente ativa?
Local lMvLjGrvBt	:= SuperGetMv("MV_LJGRVBT",.F.,.F.)             // Parametro que define se utilizara o indice "14" para priorizar a integracao dos orcamentos com reserva.
Local lFTVD7051		:= FindFunction("U_FTVD7051")                 	// Verifica se a funcao LJ7051 esta compilada
Local lFtvdVer12	:= FindFunction("LjFTvd") .AND. LjFTVD()      	// Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701")          // Nome da Rotina
Local lLj843GrvMv	:= .T.
Local lTPLOtica 	:= .F.
Local lLj7AtuInte 	:= .T.
Local lMvLjOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)
Local lUsaInd14 	:= lMvLjGrvBt                                // Indica se usa o indice 14 da tabela SL1 para priorizar os orcamentos com pedido.
Local lGrvEstorn	:= AliasInDic("MBZ")                        // Indica se a tabela MBZ e funcao de gravacao de estorno existem na base
Local lLOJA0051		:= .T.
Local cMvLJILJLO 	:= SuperGetMV( "MV_LJILJLO",,"2" )
Local cCliPad		:= SuperGetMV("MV_CLIPAD")                  // Cliente Padrao
Local cLojaPad		:= SuperGetMV("MV_LOJAPAD")                 // Loja Padrao
Local nMinReproc	:= 0                                        // Utilizado para atribuicao na variavel cMinReproc
Local nMinFalha		:= 0                                        // Tempo da ultima falha de processamento
Local lReproc		:= .T.                                      // Sinaliza se deve marcar como registro ja reprocessado, somente quando utiliza cMinReproc

Private nMoedaCor := 1

DEFAULT lMultFil 		:= .F.                                  // Verifica se e' passado mais de uma filial no parametro
DEFAULT lTotvsPDV	:= .F. 										// Parametro acrescentado para identificar chamada via Totvs PDV

If ( nPos := ASCAN( aBadRecno, SL1->( Recno() ) ) ) > 0
	While SL1->L1_FILIAL == xFilial("SL1") .AND. SL1->L1_SITUA == "RX" .AND. ;
		( ASCAN( aBadRecno, SL1->( Recno() ) ) > 0 )
		RecLock("SL1", .F.)
		REPLACE SL1->L1_STBATCH WITH "4"
		MsUnlock()
		lContinua := .F.
		SL1->( DbSkip() )
	End
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Protejo situação de todos os orcamentos "RX" estarem em aBadRecno, neste    ³
	//³ caso não devo processar o proximo (que eh eof), mas sim abandonar o Loop    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Processo Totvs PDV geracao de dados fiscais para NFe
	If !lTotvsPDV .and. ( SL1->(Eof()) .OR. SL1->L1_SITUA <> 'RX' )
		RecLock("SL1", .F.)
		REPLACE SL1->L1_STBATCH WITH "4"
		MsUnlock()
		lContinua := .F.
	EndIf

	If lContinua

		nOpcProc := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento de lista de presentes  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLstPresAt .And. lLj843GrvMv
			nOpcProc := Lj843GrvMv(SL1->L1_NUM)
			//Caso a rotina tenha identificado que existem itens de entrega, alterar a variavel identificadora de reserva
			If nOpcProc == 1
				lTemReserva := .T.
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se os itens foram gravados corretamente³
		//³Não grava como reserva, quando Template Otica   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcProc == 0
			lTemReserva := .F.
			SL2->( DbSetOrder( 1 ) )
			If SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ) ) .AND. !lTPLOtica
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe item com Reserva na venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + SL1->L1_NUM
					If !Empty(SL2->L2_RESERVA) .AND. SL2->L2_ENTREGA <> "2"	//RETIRA
						lTemReserva := .T.
						nOpcProc := 1	//LJ7PEDIDO
						Exit
					Endif
					SL2->(DbSkip())
				EndDo
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando orçamento(filho) possui outro orçamento com reserva,     ³
		//³Limpa L1_Status para salvar como venda e não gerar nova reserva.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTemReserva .AND. !Empty(SL1->L1_ORCRES)
			lTemReserva := .F.
			If nOpcProc == 1
				nOpcProc := 2
			Endif
			RecLock("SL1", .F.)
			REPLACE SL1->L1_STATUS WITH ""
			MsUnlock()
		EndIf

		cEstacao  := SL1->L1_ESTACAO
		aAreaSL1  := SL1->(GetArea())
		nRecSL1	  := SL1->(Recno())

		//Caso nao seja processamento de pedido (entrega) e lista de presentes do tipo credito, processar o LjGrvTudo
		If nOpcProc == 0
			nOpcProc := 2
		Endif
		
		//Ajuste de messagem no padrao Totvs PDV
		if lTotvsPDV
			STFMessage(ProcName(), "ALERT", "Aguarde, Processando Orc: " + SL1->L1_NUM + " ref. NF-e:" + SL1->L1_DOC)
			STFShowMessage( ProcName() )
		endif

		ConOut("LJGrvBatch: nOpcProc = " + cValToChar(nOpcProc))
		Do Case
			//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
			//³LJ7PEDIDO  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nOpcProc == 1 // Tem reserva
				Begin Transaction
					bOldError := ErrorBlock( {|x| LjVerPedErro(x,lProcessou,cFilAnt/*aFiliais[nCount][1]*/,nRecSL1) } ) // muda code-block de erro
					Begin Sequence
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Transforma o orcamento para pedido   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lProcessou := LJ7Pedido(	{} , 2, NIL, .F.,;
													{} , .T. )

						If !lProcessou
							UserException("LJGrvBatch: "+ STR0003+ cFilAnt + ". "+STR0004 )// "Filial " ### ". " "Problemas na geração do Pedido"
						EndIf
					End Sequence
					ErrorBlock( bOldError )
				End Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
			//³LJGRVTUDO  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nOpcProc == 2 // Nao tem reserva
				lProcessou := LjGrvTudo(.F. /*_lScreen*/	,/*lFinanceiro*/	,/*nNccUsada*/	,/*aNccItens*/	,;
                    /*nNccGerada*/	,/*aImpCheque*/		,/*nMoedaCor*/	,/*aRecSE1*/	,;
                    /*aVlrAcres*/	,/*aSL1*/			,/*aSL2*/		,/*cDoc*/		,;
                    /*lVendaCup*/	,/*nNumItens*/		,/*nFrete*/		,/*nSeguro*/	,;
                    /*nDespesa*/	,/*cLQFrete*/		,/*aAcrFin*/	,/*lPedFin*/ 	,;
                    /*cCgcCli*/		,/*cNomeCli*/		,/*lNfManual*/	,/*lExistNF*/   ,;
                    /*cDescErro*/   ,/*cEspecNf*/		,/*cDocFo*/		,/*aBreakNota*/ ,;
                    /*aNewNCC*/		,/*cTpGeraGdp*/		,/*nOpc*/		,/*nArredondar*/,;
                    /*lErroNFe*/	,/*lTefNsuDigit*/	,/*cLojaNF*/, lTotvsPDV) //Parametro lTotvsPDV para indicar requisição via Totvs PDV

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³LJGRVFIN - LISTA DE PRESENTES EXCLUSIVA DE CREDITO  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nOpcProc == 3
				//Como o SL1 esta posicionado, basta chamar a funcao de gravacao
				lProcessou := LjGrvFin(.F./*Interface*/,.T./*Gera fin.*/,/*nNccUsada*/,/*aNccItens*/,/*nNccGerada*/,/*aVendedor*/,/*aReceb*/,/*aRecSE1*/,;
					/*nValPIS*/,/*nValCSLL*/,/*Valor COFIN*/,/*nBaseDup*/,/*aImpCheque*/,/*nMoedaCor*/,/*lOriFun*/,.T.,Nil,/*Lista presente de credito*/)

				If lProcessou
					//Alterar o L1_SITUA para OK
					RecLock("SL1",.F.)
					SL1->L1_SITUA := "OK"
					SL1->(MsUnlock())
				Endif
		EndCase
		RestArea(aAreaSL1)

		If lProcessou
			If lMvLjOffLn .AND. lLj7AtuInte
				Lj7AtuInte(Nil, SL1->L1_NUM, SL1->L1_FILIAL, .T.)
			Endif

			Lj7PesqAltMot( SL1->L1_SERIE, SL1->L1_DOC , SL1->L1_NUM ) // Pesquisa se existe algum motivo de desconto cadastrado para a venda

			If lGerInt .And. !lTemReserva
				LjProIntVe()
			EndIf
			FRTProcSZ()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLJ7051
				bOldError := ErrorBlock( {|x| LjVerifErro(x) } ) // muda code-block de erro
				Begin Sequence
					U_LJ7051()
				Recover
					ConOut(STR0005)//"Nao conformidades na execucao do ponto de entrada LJ7051"
				End Sequence
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura rotina de erro anterior³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ErrorBlock( bOldError )
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclusao de chamada - Especifico Template  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistTemplate("LJ7002")
				ExecTemplate( "LJ7002", .F., .F., { 2, Nil, 2 } )
			EndIf
			If ExistBlock("LJ7002")
				ExecBlock( "LJ7002", .F., .F., { 2, Nil, 2 } )
			EndIf

			If ( nTimes > 30 ) .OR. ( nIntervalo == nSleep )

				If File("LJGR"+cFileName+".FIM")

					ConOut("            "+STR0006) 	//"Solicitacao para finalizar gravacao batch atendida..."

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Somente apaga o arquivo quando existir³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					FErase("LJGR"+cFileName+".FIM")
					lExProc := .F.
					lContinua := .F.
				EndIf
				nTimes := 0
			EndIf

			If lContinua
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente apaga o arquivo de orcamentos quando existir³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjxCDelArq( SL1->L1_NUM )

				nIntervalo := 0
				nTimes++
			EndIf

		Else

			LjGravaErr()
			ConOut("LJGrvBatch: "+ STR0003 + cFilAnt+ ". "+STR0007) // "Filial " ### ". " "Ocorreu algum erro no processo de gravacao batch..."
			AADD(aBadRecno, SL1->(Recno()) )

		EndIf

		If lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza o indice L1_FILIAL+L1_SITUA+L1_STATUS para priorizar os orcamentos com pedido. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaInd14
				SL1->(DbSetOrder(14)) //L1_FILIAL+L1_SITUA+L1_STATUS
				If !SL1->(DbSeek(xFilial("SL1")+"RX"+"F"))
					SL1->(DbSetOrder(9))
					SL1->(DbSeek(xFilial("SL1")+"RX"))
				EndIf
			Else
				SL1->(DbSetOrder(9))
				SL1->(DbSeek(xFilial("SL1")+"RX"))
			EndIf
		EndIf
	EndIf
EndIf

//Ajuste para retornar na SL1 que estava posicionada
//Processo Totvs PDV geracao de dados fiscais para NFe
if lTotvsPDV
	RestArea(aAreaSL1)
endif
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STBCreateFilArray
Transforma uma string com as filiais em um array

@param
@author  Varejo
@version P12
@since   11/09/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STBCreateFilArray( cFil )
Local nCount				:= 1
Local cTemp					:= ""
Local aFiliais				:= {}

DEFAULT cFil := ""

While nCount <= Len( cFil )

	cTemp := ""
	While SubStr( cFil, nCount, 1 ) <> "," .AND. nCount <= Len( cFil )
		cTemp += SubStr( cFil, nCount, 1 )
		nCount++
	End

	AADD( aFiliais, cTemp )
	nCount++

End

Return aFiliais