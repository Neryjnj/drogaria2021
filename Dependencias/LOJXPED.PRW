#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXPED.CH"

#DEFINE _MOEDA						6				//Posicao do campo Moeda no array aPgtos(Localizacoes)
#DEFINE TEF_SEMCLIENT_DEDICADO  	"2"				//Utiliza TEF Dedicado Troca de Arquivos
#DEFINE TEF_COMCLIENT_DEDICADO  	"3"				//Utiliza TEF Dedicado com o Client
#DEFINE TEF_DISCADO             	"4"				//Utiliza TEF Discado
#DEFINE TEF_CLISITEF				"6"				//Utiliza a DLL CLISITEF
#DEFINE _FORMATEF					"CC;CD"			//Formas de pagamento que utilizam operação TEF para validação
#DEFINE GDP_NO						"0" 			//Nao sera gerada guia de despacho.Quando a venda não tem item reservado com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI
#DEFINE GDP_PARCIAL    				"1"				//Sera gerada guia de despacho parcial.Quando a venda possui pelo menos um item reservado com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI
#DEFINE GDP_TOTAL					"2"				//Sera gerada guia de despacho total.Quando todos os itens da venda estao reservados e com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI

//Este DEFINE deve ser obrigatoriamente o ultimo a ser declarado pois se for declarado
//antes dos outros os demais nao sao identIficados. ***VerIficar com a Tecnologia***
//Este Log é um recurso a ser habilitado pelo departamento de desenvolvimento para averiguação 
//de possíveis problemas de transações TEF.
#DEFINE LOG_TEF  Lj7GetLog()

//------------------------------------------------
/*/{Protheus.doc} Lj7Pedido
Função responsavel por fazer as gravacoes no SL1 e SL2 que transforma o orcamento em pedido  
@type Function
@author  Varejo
@version P12.1.17
@since   24/09/2002
@return	 
/*/
//------------------------------------------------
Function Lj7Pedido( aDadosCF	, nTipo		, nHandle	, lTemTefPend	,;
					aTefBKP 	, lJob		, nFatorRes	, nFatorVen		,;
					lAlterOrc	, aProdAlter, cEspDoc	, cDocFo		,;
					nOpc		, cDocPed	, cSeriePed	, lTefManuPed	,;
					lDscCupTef	, aBkpTable	, lEmiteNF	, cTxtNFis		,;
					aDocReti	, nVlrAcrsFi, cMsgErro )
Local lRet 			:= .T.											// Retorno da Funcao
Local aRetCNF		:= {.T., {"", ""}} 								// Array com o retorno da funcao Lj7ImpCNF()
Local aArquivos 	:= {}											// Array com o retorno da funcao Lj7GeraOrc()
Local aArqAux2		:= {}											// Array auxiliar
Local aOrcRetira	:= {}											// Array com Orcamentos Retira
Local nX 			:= 0											// Auxiliar do For
Local nSize			:= 0											// Tamanho da linha do LOG txt
Local cRBuffer		:= ""											// Buffer com conteudo da linha do log txt
Local cNumPai    	:= 0											// Numero do registro no SL1 do "pedido"
Local cSerie		:= LjGetStation( "LG_SERIE" )					// Serie que estah cadastrada na estacao
Local lCartao 		:= .F.											// Flag de controle se as parcelas sao TEF
Local lTefOk		:= .F.											// Flag de controle do TEF
Local lLog1       	:= SubStr(LJGetProfile("LOGERRO"),1,1) == "S"	// Tem Log de Erro
Local lLog4         := SubStr(LJGetProfile("LOGERRO"),4,1) == "S"	// Log de Recuperacao, grava as parcelas
Local cSeqTrans		:= ""											// Tratamento da sequencia do TEF
Local cLojaLocal	:= ""											// Loja local no Cadastro de Lojas
Local aAuxaPgtos	:= {}											// Array auxiliar baseado no aPgtos
Local nAuxNcc		:= 0											// NCC
Local aAuxNcc		:= 0											// Array com os item NCC
Local nNccAux    	:= 0											// NCC usada
Local aAreaL1Pai	:= {}											// Pega a Area posicionada no Orcamento Pai do SL1
Local aAreaL2Pai	:= {}											// Pega a Area posicionada no Orcamento Pai do SL2
Local aAreaL4Pai	:= {}											// Pega a Area posicionada no Orcamento Pai do SL4
Local aAreaL1Filhos	:= {}											// Pega a Area apos geracao dos Filhos do SL1
Local aAreaL2Filhos	:= {}											// Pega a Area apos geracao dos Filhos do SL2
Local aAreaL4Filhos	:= {}											// Pega a Area apos geracao dos Filhos do SL4
Local lVendErro		:= .F.											// Indica se ocorreu algum erro na Venda
Local lLJ7058		:= ExistBlock("LJ7058")							// Se existe o PE LJ7058. Esse ponto de entrada tem como objetivo permitir que o cliente crie uma única OS para todo o pedido, evitando a quebra da OS pelo parâmetro MV_LJTPPED
Local nValRes		:= 0											// Valor dos itens com reserva
Local lCalcIPI      := .T.											// Verifica se calcula valor de IPI
Local cTpGeraGdp	:= GDP_NO						              	// Informa como sera gerada Guia de Despacho a partir do pedido de venda.
Local cDocPai 		:= ""											// Numero do documento do orcamento pai
Local cSeriePai		:= ""											// Serie do documento do orcamento pai
Local lImpCNFLoc	:= .F.											// Indica que sera impresso o comprovante nao fiscal
Local aRelGar 		:= {}              								// Array do Relatório de Garantia
Local aRelGer 		:= {}               							// Array do Relatório Gerencial
Local cImpRGer  	:= SuperGetMV("MV_RELGART",,"U_LOJR600A") 		// Nome do funcao que imprime relatorio gerencial
Local lAvCred		:= .T. 											// Variavel que controla analise de credito para o pedido.
Local nValPIS		:= 0											// Valor total do PIS
Local nValCSLL		:= 0											// Valor total do CSLL
Local nValCOFI		:= 0											// Valor total do COFINS
Local nValINSS		:= 0											// Valor total do INSS
Local nValIRRF		:= 0											// Valor total do IRRF
Local nBasePIS    	:= 0											// Base de calculo do PIS
Local nBaseCSLL   	:= 0											// Base de calculo do CSLL
Local nBaseCOFI   	:= 0											// Base de calculo do COFINS
Local nBaseINSS   	:= 0											// Base de calculo do INSS
Local nBaseIRRF   	:= 0											// Base de calculo do IRRF
Local lTefAbort		:= .F.											// Se o Tef foi cancelado dentro da lj7Pedido. Verificação p/ não chamar TEF pela segunda vez .
Local aArea1		:= {}
Local aArea2		:= {}
Local aArea3		:= {}
Local nFrete		:=	0											// VALOR DO FRETE
Local aRecnoFin		:= {} 											// Guarda o Recno dos registros financeiros gerados da venda.
Local cNumTit 		:= ""
Local cE1NumPE 		:= ""
Local aNSUVndTef	:= {}
Local aRetMFilhos	:= {}											// Retorno da função responsável por montar array com os orçamentos filhos
Local aRetTef		:= {}											//Retorno da função responsável por efetuar o TEF
Local aTaxJuros 	:= {0,0,0,0}
Local cB1M996		:= "" 											// Informacao do Campo do Cadastro de Produtos (Configurado no parametro MV_B1M996) utilizado para identificar PIS/Cofins para pessoa juridica de direito Publico. Art. 7, Lei 9718(SRF).
Local cSitua		:= ""
Local aPedidos		:= {}											// Informações dos pedidos a serem gerados
Local nSeconds 		:= 0 											// Armazena segundos inicial
Local nRetImp		:= 0											// Controle Impressao
Local lIntegDef	    := Lj701GtInD() 								//Venda Origem Integração
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()										//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lEmitNfce	    := LjEmitNFCe()									//Sinaliza se utiliza NFC-e
Local aRetPbm       := {}											//Retorno das informações retornadas do PBM Funcional Card
Local aPbmImp       := {}											//Informações da impressão do PBM
Local nVFunrural	:= 0 											//Valor do FUNRURAL
Local lNSUDigitado	:= .F.              							//Cotrola se já foi digitado o NSU do Cartão .T. -Já digitado / .F. -Não digitado 
Local nComisAux	    := 0 											//Auxiliar para calculo comissao
Local nPosVend		:= 0                							//Guarda Posição do Vendedor no array aVendedor
Local aVendedor		:= {}											//Vendedores utilizados no SL2, para gravacao no financeiro
Local lVenSuper 	:= .F.											//Guarda se o Vendedor é um dos Superiores (gerente/Supervisor) 
Local lTemPagDig    := .F.											//Controla se na venda tem Pagamento Digital
Local lPagDigOk	    := .F.											//Valida se o Pagamento Digital foi OK
Local lL1VLRPGDG 	:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 			//Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital
Local lL1VLRPGPX 	:= SL1->(ColumnPos("L1_VLRPGPX")) > 0 			//Verifica se existe o campo onde é gravado o valor da venda paga em PIX

Default nHandle 	:= -1											// Handle do arquivo
Default lJob		:= .F.											// IdentIfica se a rotina e' chamada via JOB ou nao
Default nFatorRes	:= 1
Default nFatorVen	:= 1
Default lTefManuPed	:= .F.
Default lAlterOrc   := .F.
Default aProdAlter  := {}
Default cDocFo		:= ""
Default nOpc		:= 3
Default cDocPed		:= ""
Default cSeriePed  	:= ""
Default lDscCupTef	:= .F.
Default aBkpTable	:= {}
Default	lEmiteNF	:= .F.
Default	cTxtNFis 	:= ""
Default aDocReti	:= {}
Default nVlrAcrsFi  := 0 
Default cMsgErro 	:= ""

LjGrvLog("LJ7PEDIDO" , "ID_INICIO")

/* Fluxo da Rotina LJ7Pedido  

Pedido Início
	
	01 - Realiza a operação TEF	
	
	02 - Monta os orçamentos filhos	
			
	03 - Recalcula impostos, descontos, rateios ,arredondamentos

	04 - Atualiza as informações do SL1/SL2 e SL4 do registro pai	
	
		Início Transação 1
		|
	05 -  | Grava orçamentos filhos	
		|
		Fim Transação 1	
			
		Início Transação 2
		|
	06 -  | Grava/finaliza/Imprime Orçamentos retira	
		|
		Fim Transação 2	
		 
	07 - Realiza a impressão dos comprovantes não fiscais e pega numeração do pedido 
	
	08 - Atualiza numeração dos pedidos nos registro Pai e filhos	 
	
		 Início Transação 3
		 |
	09 -   | Geração dos pedidos de vendas		
	10 -   | Geração do financeiro da venda pedido
		 |
		 Fim Transação 3
	
	11 -  | Realiza estorno da rotina no caso de erro em algum dos processos.	

Pedido Fim
		
*/

//Exibição da tela para consulta dos produtos reservados pela Funcional Card
If ExistTemplate("DroVLVen")
	aRetPbm := LJGDadosVL()
	If Len(aRetPbm) > 2 .And. Len(aRetPbm[2]) > 0
		ExecTemplate("DroVLVen",.F.,.F.,{aRetPbm[3],aRetPbm[2],aRetPbm[1],SL1->L1_NUM})
		LJ7DadosVL() 
	EndIf	
EndIf	

LjStAdmTef() //realiza o set da variável aRetAdmTef

cNumPai		:= SL1->L1_NUM //Grava os dados da reserva antes da impressao do cupom fiscal

//Se não for recuperação do Pedido/Financeiro "P3|P4|P5" 
If  !(AllTrim(SL1->L1_NSO) $ "P3|P4|P5")

	//Chile - Guia de Despacho - F2CHI Verificar no orcamento PAI como sera gerada a Guia	
	//De Despacho, de acordo com o tipo de entrega de cada item da venda.	
	If LjGtCFolLoc() .AND. cPaisLoc == "CHI"	
		cTpGeraGdp := Lj7ChkGdp( IIf( lJob , SL1->L1_NUM , M->LQ_NUM) , lJob )
	EndIf
	
	nFrete := SL1->L1_FRETE+SL1->L1_DESPESA+SL1->L1_SEGURO // Caso venha do Front
	
	If lJob				
		cSeqTrans := SL1->L1_NUM
		
		lCalcIPI  := .F.
		
		//Quando for o JOB INTEGRACAO_ERP, a array aAuxaPgots   
		//devera ser alimentado atraves da tabela SL4           
		LJ7aAuxPgtos( @aAuxaPgtos)
		aPgtos 	   := aClone(aAuxaPgtos)
		nAuxNcc    := 0
		aAuxNcc	   := {}
	    nNccAux	   := 0
	Else
		cSeqTrans  := M->LQ_NUM
		nAuxNcc	   := nNccUsada
		aAuxNcc	   := aNccItens
		nNccAux	   := nNccGerada
	EndIf
	
	// Abre a tela para para pedir os dados dos cheque / financiadora
	If !Lj7InfPgtos( nTipo		, NIL, NIL, lJob,;
					 aAuxaPgtos,@aTaxJuros )
	
		If !lJob
			If !Empty(LOG_TEF)
				LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', STR0001) //'Transf. Orçamento em Pedido - N'
			EndIf
		EndIf
		LjStRtTlTef(.T.)
		Return .F.
	EndIf
	
	//Se o ponto de entrada LJ7058 existir, significa que o cliente irá criar a ordem  
	//de serviço para todo o pedido. Essa criação não pode ser feita pelo módulo padrão,   
	//pois entregas e montagens em endereços diferentes não pode ser agendado no field service.
	//Esse ponto de entrada foi criado específicamente para a Etna, pois ela trata o agendamento da OS de modo customizado. 
	If lLJ7058 .AND. !lFtvdVer12
		LjGrvLog("ORC_PAI_" + AllTrim(SL1->L1_NUM),"Antes da execução do P.E. LJ7058")
		ExecBlock( "LJ7058", .F., .F. )
		LjGrvLog("ORC_PAI_" + AllTrim(SL1->L1_NUM),"Depois da execução do P.E. LJ7058")
	EndIf
	
	//Limpamos o L1_SITUA, pois o orcamento pai somente pode ser "T1" ate a geracao dos filhos.
	//Ja que se houver qualquer erro nessa funcao, a transacao sera desarmada, o pai continuara como "T1",
	//pois o orcamento ficara em aberto e nenhum orcamento filho sera gerado
	If (lEmitNFCe .Or. LjGtPafNfce()) .AND. SL1->L1_SITUA $ "T1|T2|T3"
		cSitua := ""
	Else
		cSitua := SL1->L1_SITUA
	EndIf
	
	If SL1->(Reclock( "SL1", .F. ))
		Replace SL1->L1_TIPO with "P"
		Replace SL1->L1_SITUA with cSitua
		SL1->( MsUnlock() )
		IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
	EndIf
	
	//Verifica se a Venda é Originada de Integração
	If SL1->L1_ORIGEM == "N"
		lIntegDef := .T.
	Endif 
	
	//Verifica se o Pedido não foi finalizado orretamente para fazer estorno
	If AllTrim(SL1->L1_NSO) $ "P0|P1|P2" .AND. Len(LjGtDelOrc()) > 0
		Lj7DelOrc(LjGtDelOrc())
		 
		LjStDelOrc() //realiza o set da variável aOrcFilDel
	EndIf

	Lj7GeraSL("SL1",{{"L1_NSO",""}},.F.)
	
	// 1 - Realiza a operação TEF
	If lRet .AND. !lJob
		aRetTef := Lj7PedTEF(	@aTefBKP		, @lTemTefPend	, @lTefAbort	, @aNSUVndTef,;
								@lTefManuPed	, @lCartao )
		lTefOk := aRetTef[1]	//TEF realizado com sucesso?
		If !aRetTef[2]	//Continua o processo da função LJ7Pedido
			lRet := .F.
		EndIf

		//-----------------------------------------
		// Processa Transação de Pagamento Digital
		//-----------------------------------------
		If lRet .And. ExistFunc("LjPgtoDig") .And. STWChkTef("PD")
			lPagDigOk := LjPgtoDig(@lTemPagDig)
			If lTemPagDig
				lRet := lPagDigOk
			EndIf
		EndIf

	EndIf
	
	nSeconds := Seconds() // Armazena segundos inicial apos o TEF
	
	// 2 - Monta os orçamentos filhos
	If lRet
		aRetMFilhos := LJ7MFilhos(	@cLojaLocal	, lJob			, @aRelGer		, @aRelGar	,;
									@cB1M996	, @cImpRGer		, aProdAlter	, lAlterOrc	,;
									@nValRes	, cTpGeraGdp	, @lImpCNFLoc	, @aBkpTable,;
									aAuxaPgtos	, @nFatorVen	, @nFatorRes	, @lVendErro,;
									aTaxJuros	, nFrete		)
		If aRetMFilhos[1]
			aArqAux2 := aClone(aRetMFilhos[2])
		Else	
			lRet := .F.
		EndIf
	EndIf
	
	//Guarda area registro Pai
	aAreaL1Pai	:= SL1->(GetArea())
	aAreaL2Pai	:= SL2->(GetArea())
	aAreaL4Pai	:= SL4->(GetArea())
	
	//P0 - Antes do início das Transações
	Lj7GeraSL("SL1",{{"L1_NSO","P0"}},.F.)
	
	// 4 - Atualiza as informações do SL1 / SL2 e SL4 do registro Pai
	If lRet
		Lj7AtuPed(	lJob		, aRetCNF	, @cDocPed	, @cSeriePed	,;
					cTpGeraGdp	, @cDocPai	, @cSeriePai, lTefOk		,;
					aNSUVndTef	, @lAvCred	, cLojaLocal, lTefManuPed)
	EndIf			
	
	//P1 - Transação 1
	Lj7GeraSL("SL1",{{"L1_NSO","P1"}},.F.)	
	If lRet
		LjGrvLog(cNumPai,"Início transação 1")
	
		// 5 - Grava orçamentos filhos	
		LjGrvLog(cNumPai,"Gravando orcamentos filhos")
		
		Begin Transaction 
			bOldError := ErrorBlock( {|x| LjVerIfErro(x) } ) 
			Begin Sequence
				lRet := LJ7GrvFilh( aArqAux2	, @aArquivos, @lJob		, cTpGeraGdp,;
									cDocPai		, cSeriePai	, aRetCNF	, cImpRGer	,;
									lVendErro	, lAlterOrc	, cNumPai	, lAvCred	,;
									@aOrcRetira	, @aPedidos	, cLojaLocal, cDocPed	,;						
                        			cSeriePed)			
			Recover
				lRet := .F. 
				DisarmTransaction()
			End Sequence
			ErrorBlock( bOldError )						
		End Transaction
		LjGrvLog(cNumPai,"Fim transação 1 RETORNO : ",lRet)
		//Guarda Area apos geracao dos Filhos
		aAreaL1Filhos	:= SL1->(GetArea())
		aAreaL2Filhos	:= SL2->(GetArea())
		aAreaL4Filhos	:= SL4->(GetArea())
	EndIf	
		
	// 6 - Pega Numeração dos pedidos
	If lRet
		//Restauro a area da venda original(Pai)
		RestArea(aAreaL1Pai)
		RestArea(aAreaL2Pai)
		RestArea(aAreaL4Pai)	
	
		aRetCNF := lj7ImpPed(	lTefOk	, lJob		, nFatorRes	, lImpCNFLoc,;
							nOpc 	, @cTxtNFis	)
							
		LjGrvLog(cNumPai,"Depois da impressao do comprovante ",aRetCNF)
		
		If lLog1 .AND. lLog4 .AND. nHandle >= 0
			nSize 		:= FSeek( nHandle, 0, 2 )
			cRBuffer 	:= Space( nSize )
		
			FSeek( nHandle, 0, 0 )
			FRead( nHandle, @cRBuffer, nSize )
		
			cRBuffer := Encript( cRBuffer, 1 )
			If !("#DADOSOK#" $ cRBuffer)
				cRBuffer := cRBuffer + "#DADOSOK#"
			EndIf
		
			FSeek( nHandle, 0, 0 )
			FWrite( nHandle, Encript( cRBuffer, 0 ) )
		
			LjGrLogT(	SL1->L1_NUM     , aRetCNF[2][1]		, xNumCaixa()		, NIL				,;
						SL1->L1_DINHEIR , SL1->L1_CHEQUES	, SL1->L1_CARTAO	, SL1->L1_VLRDEBI	,;
						SL1->L1_CONVENI	, SL1->L1_VALES		, SL1->L1_FINANC	, SL1->L1_OUTROS	,;
						SL1->L1_DESCONT	, SL1->L1_DESCNF	, aRetCNF[2][2]		, cSerie )
		EndIf
	
		If !aRetCNF[1]
			Aviso( STR0002, STR0003, {STR0004} ) //"Atenção"###"Houve erros na impressão do comprovante de venda. VerIfique a impressora."###"Ok"
			LjGrvLog(M->LQ_NUM, 'Erro na impressao do comprovante de venda.' )
			Return .F.
		EndIf
		
		If lJob
			aRetCNF[2][1] := SL1->L1_DOCPED
			aRetCNF[2][2] := SL1->L1_PDV
		EndIf
		cDocPed := aRetCNF[2][1]
		
		If cPaisLoc <> 'BRA' .AND. Empty(aRetCNF[2][2])
			aSequencia	:= {}
		 	LjxDNota(LjGetStation("LG_SERIE"), 1, .F., 1, @aSequencia, nil, nil, 1, 999, .F., "", Nil)
			cDocPed		:= aSequencia[1][2]
		EndIf
	
	EndIf	
	
	If lRet
		//P2 - Transação 2 
		//Restauro a area da venda original(Pai)
		RestArea(aAreaL1Pai)
		RestArea(aAreaL2Pai)
		RestArea(aAreaL4Pai)	
		LjGrvLog(cNumPai,"Início transação 2 fator :", nFatorVen)
		Lj7GeraSL("SL1", { {"L1_NSO" , "P2"	} } , .F.)
		
		//Restauro a area da venda filho
		RestArea(aAreaL1Filhos)
		RestArea(aAreaL2Filhos)
		RestArea(aAreaL4Filhos)
	
		// 8 - Grava/finaliza Orcamentos retira	
		bOldError := ErrorBlock( {|x| LjVerIfErro(x) } ) 

		If Len(aNSUVndTef) > 0
			lNSUDigitado := !Empty(aNSUVndTef[1][4]) 
		EndIf	

		Begin Sequence
			lRet := LJ7GrvReti( aOrcRetira 	, lJob 		 	, lEmiteNF    		,cNumPai   	,;
								aDadosCF	, nHandle 	 	, @lTemTEFPend 	,nFatorRes 	,;
								nFatorVen   , lTefOk     	, @lDscCupTef  	,lTefAbort 	,;
								nValRes     , aAreaL1Pai 	, aAreaL1Filhos  	,cTpGeraGdp ,;
								cEspDoc     , cDocFo     	, aArquivos		,@aDocReti  ,; 
								lCartao     , lNSUDigitado	, @cMsgErro )

			
			//Guarda Area apos geracao do Filho Retira
			aAreaL1Filhos	:= SL1->(GetArea())
			aAreaL2Filhos	:= SL2->(GetArea())
			aAreaL4Filhos	:= SL4->(GetArea())
			
			//Restauro a area do SL1, SL2, SL4 da venda original(Pai), necessario para geracao do SE1
			RestArea(aAreaL1Pai)
			RestArea(aAreaL2Pai)
			RestArea(aAreaL4Pai)	
								
			If lRet				
				// 7 - Atualiza numeracao pedido registro Pai e filhos
				Lj7GeraSL("SL1",{{"L1_SITUA","P3"}},.F.)
				IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit("","P3"), NIL)
				
				Lj7GeraSL("SL1",{{"L1_NSO","P3"}},.F.)
			
				Lj7AtuNum(	lJob 		, aRetCNF 	, @cDocPed , @cSeriePed , ;
							aOrcRetira	, aPedidos	) 
							
				RestArea(aAreaL1Pai)
				RestArea(aAreaL2Pai)
				RestArea(aAreaL4Pai)				
			EndIf						
		Recover
			lRet := .F. 
		End Sequence
		ErrorBlock( bOldError )						
	
		LjGrvLog(cNumPai,"Fim transação 2 , retorno : ",lRet)								
	EndIf
	
	// 9 - Impressão TEF
	//Se for TEF_DISCADO, verificamos o conteudo da variavel lDscCupTef,
	//pois o comprovante TEF ja pode ter sido impresso na funcao Lj7GrvVenda
	If lRet .AND. !lJob .AND. lUsaTef .AND. !lDscCupTef
		//Caso utilize o PBM executa rotina de impressão do Template
		If ExistTemplate("DroVLImp") .And. cTipTef == TEF_CLISITEF .And. Len(aRetPbm) > 2 .And. aRetPbm[3] == 2
	   
			aPbmImp := ExecTemplate("DroVLImp",.F.,.F.,{2})
			LJ7DadosVL({aRetPbm[1],aRetPbm[2],0}) 
			
			If Len( aPbmImp) > 0 .And. aPbmImp[1] == 0
				oTEF:FinalTrn(1)
			EndIf				
		
		ElseIf LJXVERTEF(.F.)	
			Lj701ImpTr(nHandle,@lTemTEFPend) //Aguarde... Impressão do Tef
			LjGrvLog(cNumPai,"Impressao do comprovante TEF ",lTemTEFPend)
			Lj7GeraSL("SL1",{{"L1_NSO","P4"}},.F.)
		Endif

		If ExistFunc("LjImprimPD") .And. lTemPagDig .And. lPagDigOk
			//Imprime o comprovante de Pagamento Digital
			LjImprimPD()
		EndIf
			
	EndIf

	
	// 6 - Realiza a impressão dos comprovantes dos Pedidos
	If lRet
		// Imprime
		If !Empty(cTxtNFis)
			nRetImp := 1
			While nRetImp <> 0
				nRetImp := INFTexto(cTxtNFis)
		
				If nRetImp <> 0
					If !MsgYesNo(STR0005) //"Não foi possível imprimir o comprovante, tentar novamente?"
						nRetImp := 0
					EndIf
				Else
					cTxtNFis := ""	
				EndIf
			End
		EndIf
		Lj7GeraSL("SL1",{{"L1_NSO","P5"}},.F.)		
	EndIf	
	
	//Restauro a area do SL1, SL2, SL4 da venda original(Pai)
	RestArea(aAreaL1Pai)
	RestArea(aAreaL2Pai)
	RestArea(aAreaL4Pai)	
	
	//Em caso de Erro Estorna Pedidos caso tenha efetuado alguma gravação, quando não for integração
    If !lRet .And. !lIntegDef
		Lj7EstPed(	cNumPai , lJob , aOrcRetira	, aPedidos	, ; 
					lTefOk 	)
	EndIf
Else	
	//Guarda area registro Pai
	aAreaL1Pai	:= SL1->(GetArea())
	aAreaL2Pai	:= SL2->(GetArea())
	aAreaL4Pai	:= SL4->(GetArea())
	
	//Guarda Area apos geracao do Filho Retira
	aAreaL1Filhos	:= SL1->(GetArea())
	aAreaL2Filhos	:= SL2->(GetArea())
	aAreaL4Filhos	:= SL4->(GetArea())
	
	Lj7GeraSL("SL1",{{"L1_SITUA","P3"}},.F.)
	IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit("","P3"), NIL)
	
	//Reimpressão TEF
	If  AllTrim(SL1->L1_NSO) $ "P3"
		If lRet .AND. !lJob .AND. LJXVERTEF(.F.) .AND. lUsaTef .AND. !lDscCupTef
			MsgAlert(STR0006) //"Será aberta a Rotina Administrativa do TEF para reimpressão do conprovante."
			If GetAPOInfo("LOJXTEF.PRW")[4] >= Ctod("30/06/2017")
				IF(LJProfile(17), oTEF:Operacoes("REIMP_MENU",{}),)
			Else
				IF(LJProfile(17), oTEF:Operacoes("GERENCIAIS",{}),)
			EndIf
		EndIf
	EndIf	
	
	
	If  AllTrim(SL1->L1_NSO) $ "P3P4"
	
		aRetCNF := lj7ImpPed(	lTefOk	, lJob		, nFatorRes	, lImpCNFLoc,;
								nOpc 	, @cTxtNFis	)
	
		// Realiza a impressão dos comprovantes dos Pedidos
		If lRet
			// Imprime
			If !Empty(cTxtNFis)
				nRetImp := 1
				While nRetImp <> 0
					nRetImp := INFTexto(cTxtNFis)
			
					If nRetImp <> 0
						If !MsgYesNo(STR0005) //"Não foi possível imprimir o comprovante, tentar novamente?"
							nRetImp := 0
						EndIf
					Else
						cTxtNFis := ""	
					EndIf
				End
			EndIf
			
		EndIf
		
	EndIf	
	
	Lj7GeraSL("SL1",{{"L1_NSO","P5"}},.F.)
	
	aAuxNcc := {}
	
	aPedidos := Lj7RecupPed(cNumPai , @nAuxNcc , @aAuxNcc , @nNccAux)
	aNccItens := aAuxNcc
	lRet := .T.

EndIf

//P3 - Transação 3
If lRet
	LjGrvLog(cNumPai,"Início transação 3")
	Begin Transaction
		bOldError := ErrorBlock( {|x| LjVerIfErro(x) } )
		Begin Sequence
			
			// 10 - Geração dos pedidos de vendas	
			If lRet
				lRet := LJ7GPedVen(aPedidos)
			EndIf
		
			// 11 - Geracao do financeiro da venda pedido 
			LjGrvLog(cNumPai,"Antes da geracao do financeiro da venda pedido")
			If lRet
			
				If !lJob
					LjGrvLog( M->LQ_NUM ,'Gera SE1 / SE5')
				EndIf
			
				If !LjGtBGtPaf() 
					//Restauro a area do SL1, SL2, SL4 da venda original, necessario para geracao do SE1
					RestArea(aAreaL1Pai)
					RestArea(aAreaL2Pai)
					RestArea(aAreaL4Pai)
				EndIf
				If !(lVendErro) .AND. !(LjGtBGtPaf()) 
			
					If cPaisLoc == "BRA" .And. MaFisFound("NF")
						//Valor do CSLL/IRRF
						If lIntegDef //Integracao mantem valor de impostos enviados no xml				
							//Valor total do PIS / COFINS / CSLL
							nValPIS  := IIF(ValType(M->LQ_VALPIS) == "N", M->LQ_VALPIS, 0)	 		
							nValCOFI := IIF(ValType(M->LQ_VALCOFI) == "N", M->LQ_VALCOFI, 0)
							
							nValCSLL := IIF(ValType(M->LQ_VALCSLL) == "N", M->LQ_VALCSLL, 0)
							nValIRRF := IIF(ValType(M->LQ_VALIRRF) == "N", M->LQ_VALIRRF, 0)
							
							//Base de calculo do PIS / COFINS / CSLL
							nBasePIS  := nBasePis
							nBaseCOFI := nBaseCofi
							nBaseCSLL := nBaseCsll
							nBaseIRRF := nBaseIrrf 
						Else			
							//Valor total do PIS / COFINS / CSLL
							nValPIS  := MaFisRet(Nil, "NF_VALPIS")
							nValCSLL := MaFisRet(Nil, "NF_VALCSL")
							nValCOFI := MaFisRet(Nil, "NF_VALCOF")
			
							//Base de calculo do PIS / COFINS / CSLL
							nBasePIS  := MaFisRet(Nil, "NF_BASEPIS")
							nBaseCOFI := MaFisRet(Nil, "NF_BASECOF")
							nBaseCSLL := MaFisRet(Nil, "NF_BASECSL")
						
							//Valor do IRRF
							nValIRRF  := MaFisRet(Nil, "NF_VALIRR")
							nBaseIRRF := MaFisRet(Nil, "NF_BASEIRR")

							nVFunrural := MaFisRet(Nil,"NF_FUNRURAL")
						EndIf
						
						//Valor do INSS
						nValINSS  := MaFisRet(Nil, "NF_VALINS")
						nBaseINSS := MaFisRet(Nil, "NF_BASEINS")
					EndIf

					// Aqui irá verificar se o vendedor tem superiores configurados(Gerente/Supervisor)
					// Caso atenda as condições, irá adicionar no array aVendedores e gerar as respectivas comissões.
					If cPaisLoc == "BRA"
						For nX := 1 To 5 //Maximo de 5 vendedores	 				
							If SL1->(FieldPos("L1_VEND" + AllTrim(Str(nX)))) > 0 .And. !Empty(&("SL1->L1_VEND" + AllTrim(Str(nX))))												
								If !lVenSuper
									// Posição do SL1_VEND - Vendedor	
									// Aqui se tem Superiores, adiciona o Vendedor também, pois neste ponto aVendedores está vazio
									nComisAux := Posicione("SA3", 1, xFilial("SA3") + &("SL1->L1_VEND" ), "A3_COMIS") //Armazena percentual de comissao								
									nPosVend := Ascan( aVendedor, { |x| x[1] = &("SL1->L1_VEND") } )									

									If nComisAux > 0 .AND. nPosVend == 0
										Aadd(aVendedor, {&("SL1->L1_VEND"), nComisAux, SL1->L1_VLRTOT, ((SL1->L1_VLRTOT * nComisAux) / 100), 1})
									EndIf
									// Seta lVenSuper = .T., para não tentar adicionar novamente o Vendedor no array aVendedres
									lVenSuper := .T.
								EndIf	

								nComisAux := Posicione("SA3", 1, xFilial("SA3") + &("SL1->L1_VEND" + AllTrim(Str(nX))), "A3_COMIS") //Armazena percentual de comissao
								nPosVend := Ascan( aVendedor, { |x| x[1] = &("SL1->L1_VEND" + AllTrim(Str(nX))) } )									

								//Se possui percentual de comissao, efetua calculo
								If nComisAux > 0 .AND. nPosVend == 0				
									Aadd(aVendedor, {&("SL1->L1_VEND" + AllTrim(Str(nX) )), nComisAux, SL1->L1_VLRTOT, ((SL1->L1_VLRTOT * nComisAux) / 100), 1})
								EndIf
							EndIf					
						Next nX		
					EndIf			

					lRet := LjGrvFin( !lJob 	, NIL		, nAuxNcc	, aAuxNcc	,;
				    	     	      nNccAux	, aVendedor	, Nil 		, Nil		,;
				    	     	      nValPIS	, nValCSLL	, nValCOFI	, Nil 		,;
				    	     	      Nil		, Nil		, Nil		, Nil 		,;
				    	     	      Nil		, nBasePIS 	, nBaseCOFI , nBaseCSLL ,;
				    	     	      Nil 	 	, Nil 		, cB1M996   , nValINSS  ,;
				    	     	      nValIRRF  , nBaseINSS , nBaseIRRF , Nil		,;
				    	     	      Nil       , Nil       , @aRecnoFin, Len(aNSUVndTef) > 0,;
									  nVFunrural )
				    	     
				     LjGrvLog(cNumPai,"Depois da geracao do financeiro da venda pedido")
			    EndIF
				
				//Restauro a area do SL1, SL2, SL4 da geracao dos pedidos, para continuar o processo
				If !LjGtBGtPaf() 
					RestArea(aAreaL1Filhos)
					RestArea(aAreaL2Filhos)
					RestArea(aAreaL4Filhos)
				EndIf
				LjGrvLog(cNumPai,"Filhos gerados com sucesso")
			
			EndIf
		
			If lRet
				//Verifica se tem o Ponto de Entrada que permite modificar a numeracao do tiulo da venda
				If ExistBlock("LJNumTit") .And. Len(aRecnoFin) > 0
					aArea1 := GetArea()
					aArea2 := SE1->(GetArea())
					aArea3 := SEF->(GetArea())
			
					cNumTit 	:= aRecnoFin[1][2]
					
					LjGrvLog("LJ7PEDIDO" , "Antes da Chamada do Ponto de Entrada: LJNumTit",{ SuperGetMV("MV_LJE1NUM",,"1"), cNumTit })
					cE1NumPE 	:= ExecBlock( "LJNumTit", .F., .F., { SuperGetMV("MV_LJE1NUM",,"1"), cNumTit } )
					LjGrvLog("LJ7PEDIDO" , "Apos a Chamada do Ponto de Entrada:LJNumTit")
					
					If !Empty(cE1NumPE)
						cE1NumPE := PadR(cE1NumPE,TamSX3("E1_NUM")[1])
					Else
						cE1NumPE := cNumTit
					EndIf
					
					If cNumTit <> cE1NumPE
						For nX := 1 To Len(aRecnoFin)
							If aRecnoFin[nX][1] == "SE1
								SE1->(DbGoTo(aRecnoFin[nX][3]))
								RecLock("SE1",.F.)
								SE1->E1_NUM := cE1NumPE
								SE1->(MsUnLock())
							ElseIf aRecnoFin[nX][1] == "SEF
								SEF->(DbGoTo(aRecnoFin[nX][3]))
								RecLock("SEF",.F.)
								SEF->EF_TITULO := cE1NumPE
								SEF->(MsUnLock())
							EndIf
						Next nX
					EndIf
					
					RestArea(aArea3)
					RestArea(aArea2)
					RestArea(aArea1)
				EndIf
			EndIf

		Recover
			lRet := .F.
			DisarmTransaction()
		End Sequence
		ErrorBlock( bOldError )	
	End Transaction
	LjGrvLog(cNumPai,"Fim transação 3")
	
	//Vai p orcamento Pai para gravar Status final
	RestArea(aAreaL1Pai)
	If lRet
		Lj7GeraSL("SL1", { {"L1_NSO", "POK"} }, .F.)

		If LjGtBGtPaf() 
			Lj7GeraSL("SL1", { {"L1_SITUA", "00"}, {"L1_ERGRVBT", ""} }, .F.)
			IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit("", "00"), NIL)
		Else
			Lj7GeraSL("SL1", { {"L1_SITUA", "FR"}, {"L1_ERGRVBT", ""} }, .F.)
			IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit("", "FR"), NIL)
		EndIf
	Else
		Lj7GeraSL("SL1", { {"L1_SITUA" , "ER"},{"L1_ERGRVBT" , "Lj7Pedido - Erro geração Pedido/Financeiro. Venda já finalizada."} } , .F.)
		IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit("","ER"), NIL)
				
		If !lJob
			//Retorna True pois o erro foi no pedido/financeiro e a venda já foi finalizada fica ER para correcao manual nesta estapa do projeto.
			//apenas se não for job pois o Job ainda tem o controle de transacao habilitado
            LjxjMsgErr( I18n(STR0015, {"L1_SITUA = ER"}), I18n(STR0016, {"LJGRVBATCH"}) )  //"Não foi possível gerar Pedido\Financeiro, a venda será finalizada e ficará com #1, para correção manual."   "Corrija a venda e coloque para reprocessar pelo #1."
			lRet := .T.			
		EndIf
	EndIf
	
	//VOLTA AREA FILHOS
	RestArea(aAreaL1Filhos)
	RestArea(aAreaL2Filhos)
	RestArea(aAreaL4Filhos)

EndIf	

LjGrvLog(cNumPai,'Finalização da Geração do Pedido - ' + If( lRet, 'S', 'N' ) )
LjGrvLog("LJ7PEDIDO" , "Tempo total geração do pedido: " + AllTrim(Str(Seconds() - nSeconds) ) + " segundos.")
LjGrvLog("LJ7PEDIDO" , "ID_FIM")

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} Lj7ChkGdp()
Verificar no orcamento PAI se sera gerada a Guia de Despacho, de acordo com o tipo de entrega de cada item da venda.             
@author  Varejo
@param	 ExpC1 - Numero do Orcamento
		 ExpL2 - Indica se a execucao eh via JOB
@version P12.1.17
@since   10/06/2011
@return  cTipo Tipo da Guia de Despacho
/*/
//--------------------------------------------------------
Function Lj7ChkGdp (cNumOrc,lJob)

Local cTipo 	:= GDP_NO   //Tipo da Guia de Despacho
Local nItensGdp := 0        //Contador de itens da Guia de Despacho
Local nItens	:= 0       	//Contador de itens da venda

Default cNumOrc	:= M->LQ_NUM
Default lJob		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Chile - Guia de Despacho - F2CHI     			³
//³Verificar no orcamento PAI se sera gerada a Guia de Despacho ³
//³de acordo com o tipo de entrega de cada item da venda.      	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjGtCFolLoc() .AND. cPaisLoc == "CHI"
	aAreaSL2:=SL2->(GetArea())
	DbSelectArea("SL2")
	DbSeek(xFilial("SL1")+cNumOrc)
	While !SL2->(Eof()) .AND. xFilial("SL1") + cNumOrc == SL2->L2_FILIAL + SL2->L2_NUM
		If SL2->L2_ENTREGA == "3" .AND. !Empty(SL2->L2_RESERVA)
			nItensGdp++
		Endif
		nItens++
		SL2->(DbSkip())
  	End

	SL2->(RestArea(aAreaSL2))
	If nItensGdp == 0
		cTipo:=GDP_NO
	ElseIf nItensGdp==nItens
		cTipo:=GDP_TOTAL
	Else
		cTipo:=GDP_PARCIAL
	EndIf
EndIf

Return cTipo

//--------------------------------------------------------
/*/{Protheus.doc} LJ7aAuxPgtos()
Preenchimento do array aAuxaPgtos que sera' utilizado quando a funcao LJ7Pedido() for acionada atraves do JOB de integracao ERP
@author  Varejo
@param	 ExpA1 - Array de pagamentos
@version P12.1.17
@since   14/08/2008
@return  
/*/
//--------------------------------------------------------
Function LJ7aAuxPgtos(aAuxaPgtos)
Local nLinha 	:= 0		//	Numero de parcelas
Local aAuxiliar := {}		//	Array auxiliar que armazena informacoes de pagamento

aAuxaPgtos := {}

DbSelectArea("SL4")
DbSetOrder(1) //L4_FILIAL, L4_NUM, L4_ORIGEM
DbSeek( xFilial("SL4") + SL1->L1_NUM)
While SL4->(!Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM .AND. Empty(AllTrim(SL4->L4_ORIGEM))
	nLinha++
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dinheiro						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IsMoney(SL4->L4_FORMA)
		aAdd( aAuxaPgtos, {	SL4->L4_DATA							,;	//01 Data do orcamento
							SL4->L4_VALOR							,;	//02 Valor
							SL4->L4_FORMA							,;	//03 Forma de pagamento
							{}										,;	//04 Array de parcelas
							NIL										,;	//05 Data base
							IIf(cPaisLoc<>"BRA",SL4->L4_MOEDA,NIL)	,;	//06 Moeda
			               	IIf(cPaisLoc<>"BRA",SL4->L4_DATA,NIL)	,;	//07 Data
			               	If(If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.),SL4->L4_FORMAID,Space(01))} )	//08 FormID
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cheque						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf AllTrim(SL4->L4_FORMA) == AllTrim(MVCHEQUE)
		aAdd( aAuxaPgtos, {	SL4->L4_DATA							,;	//01 Data do orcamento
							SL4->L4_VALOR							,;	//02 Valor
							SL4->L4_FORMA							,;	//03 Forma de pagamento
							{}										,;	//04 Array de parcelas
							NIL										,;	//05 Data base
							IIf(cPaisLoc<>"BRA",SL4->L4_MOEDA,NIL)	,;	//06 Moeda
			               	IIf(cPaisLoc<>"BRA",SL4->L4_DATA,NIL)	,;	//07 Data
			               	If(If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.),SL4->L4_FORMAID,Space(01))} )	//08 FormID

		aAuxiliar := Array(14)
		aAuxiliar[1]  := SL4->L4_VALOR
		aAuxiliar[2]  := SL4->L4_DATA
		aAuxiliar[3]  := "01"
		aAuxiliar[4]  := SL4->L4_ADMINIS
		aAuxiliar[5]  := SL4->L4_AGENCIA
		aAuxiliar[6]  := SL4->L4_CONTA
		aAuxiliar[7]  := SL4->L4_NUMCART
		aAuxiliar[8]  := SL4->L4_COMP
		aAuxiliar[9]  := SL4->L4_RG
		aAuxiliar[10] := SL4->L4_TELEFON
		aAuxiliar[11] := .T.
		aAuxiliar[12] := .F.
		aAuxiliar[13] := SuperGetMV("MV_SIMB1")
		aAuxiliar[14] := ""

		aAuxaPgtos[nLinha][4] := aClone(aAuxiliar)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cartao de credito/debito/outros	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		aAdd( aAuxaPgtos, {	SL4->L4_DATA							,;	//01 Data do orcamento
							SL4->L4_VALOR							,;	//02 Valor
							SL4->L4_FORMA							,;	//03 Forma de pagamento
							{}										,;	//04 Array de parcelas
							NIL										,;	//05 Data base
							IIf(cPaisLoc<>"BRA",SL4->L4_MOEDA,NIL)	,;	//06 Moeda
			               	IIf(cPaisLoc<>"BRA",SL4->L4_DATA,NIL)	,;	//07 Data
			               	If(If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.),SL4->L4_FORMAID,Space(01))} )	//08 FormID

		aAuxiliar := Array(7)
		aAuxiliar[1]  := SL4->L4_VALOR
		aAuxiliar[2]  := SL4->L4_DATA
		aAuxiliar[3]  := "01"
		aAuxiliar[4]  := ""
		aAuxiliar[5]  := SL4->L4_ADMINIS
		aAuxiliar[6]  := .T.
		aAuxiliar[7]  := ""

		aAuxaPgtos[nLinha][4] := aClone(aAuxiliar)

	EndIf
	SL4->(DbSkip())
End

If Len(aAuxaPgtos) == 0
	AAdd( aAuxaPgtos, { Ctod("  /  /  "), 0 , "" , "", "", "", "", "", "", .F., 1, Space(04), 0 })
EndIf
Return

//----------------------------------------------------------
/*/{Protheus.doc} Lj7PedTEF
Função responsável por executar a transação TEF quando venda 
com item do tipo entrega.

@type		function
@param		aTefBKP		: Backup das informações do TEF
			lTemTefPend	: Possui TEF pendente 
			lTefAbort	: Se não pergunta ou realiza o TEF apos a LJ7Pedido
			aNSUVndTef	: Informações das transições TEF 
			lTefManuPed	: Se utiliza TEF Manual e se sera 
			executado cancelamento da venda qdo pedido
@author		felipe.martinez
@version	P12.1.14
@since		20/02/2017
@return 	aRet:	[1] - TEF realizado com sucesso?
					[2] - Continua a processar a função LJ7Pedido?
/*/
//----------------------------------------------------------
Static Function Lj7PedTEF(	aTefBKP		,lTemTefPend	,lTefAbort	,aNSUVndTef	,;
							lTefManuPed , lCartao )
Local aRet			:= {.F.,.F.}				//[1]-TEF ok?, [2]-Continua o processamento da lj7Pedido?
Local lTefOk		:= .F.						//Transação TEF realizada com sucesso.
Local lCont7Ped		:= .T.						//Se o processo do LJ7Pedido será executado apos o TEF (para nao dar Returno no meio do fonte)
Local lSemRede		:= .F.
Local nX			:= 0
Local nY			:= 0
Local aReb			:= {}
Local cNumPai		:= SL1->L1_NUM
Local lAutomato		:= If(Type("lAutomatoX") <> "L",.F.,lAutomatoX)
Local lSelTefManu   := .F.	//Valida se foi selecionado o TEF Manual
Local cNumNSU		:= ""

Default aTefBKP		:= {}
Default lTemTefPend	:= .F.
Default lTefAbort	:= .F.
Default aNSUVndTef	:= {}
Default lTefManuPed	:= .F.
Default lCartao		:= .F.

lCartao	:= LJXVERTEF(.F.)

If lUsaTef .AND. lCartao .AND. cTipTEF $	TEF_SEMCLIENT_DEDICADO 	+ ";" + ;
											TEF_COMCLIENT_DEDICADO 	+ ";" + ;
											TEF_DISCADO 			+ ";" + ;
											TEF_CLISITEF
	
	aParcTef := {} // Array private declarado no fonte LOJA701
	//Monta os array's para validação do tef
	LjMnReb(@aReb, @aParcTef)
	LjGrvLog(cNumPai,"Vai realizar a transacao TEF do PEDIDO ",aPgtos)
	If cTipTef == TEF_CLISITEF
		oTEF:Operacoes("V"			, aReb			, @lTemTefPend	, @aTefBKP		,;
						cNumPai		, NIL			, @aPgtos		, @aPgtosSint	,;
						@oPgtos		, @oPgtosSint	)

		lTefOk := oTef:lTefOk
		lSelTefManu := !lTefOk
		If !SuperGetMv("MV_TELAFIN",,.T.)
			If !LJVERADM( @lSemRede, lTefOk ) .And. SuperGetMV("MV_TEFPEND",,"0") == "0"
				LjCancTEF()
				lTefOk := .F.
				LjGrvLog(cNumPai,"transacao Tef Cancelada",lTefOk)
			EndIf
		EndIf
	Else
		lTefOk := LOJA010T( "V" , ,aReb,,,,,,,,,,,,,,,,,,,, aParcTef )
	EndIf

	LjGrvLog(cNumPai,"RETORNO DA TRANSACAO TEF ",lTefOk)
	If Valtype(lTefOk) <> "L"
		lTefOk := .F.
	Else
		LjGrvLog(cNumPai,"Objeto oTef",oTef)
	EndIf

	If !lTefOk
		If cTipTef <> TEF_CLISITEF
			//HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef
			If TEF_lEnvDF()
				If LOJA010T("F","D")
					MsgAlert(STR0007) 	//"Transação TEF não efetuada!"
				EndIf
			//Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef
			ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00")
				If LOJA010T("F","N")	//Antigamente esta função nao retornava verdadeiro ou falso
					MsgAlert(STR0007) 	//"Transação TEF não efetuada!"
				EndIf
			EndIf
		EndIf

		If !SuperGetMV("MV_TEFMANU",,.T.) .OR. lSemRede
			LjStRtTlTef(.T.)
			lCont7Ped	:= .F.
		Else
			If !LojaOk(STR0011) //"Continua Manualmente?"
				LjGrvLog(cNumPai,"Continua Manualmente igual a 'Nao'")
				LjStRtTlTef(.T.)
				lTefManuPed := .F.
				lCont7Ped	:= .F.
			EndIf
			If lCont7Ped //Mantendo integridade, onde antes havia um 'Return' meio do fonte
				LjGrvLog(cNumPai,"Continua Manualmente igual a 'Sim'")
				//Não é necessário chamar o tef ou efetuar a pergunta de continua manualmente novamente, pois ja foi perguntado agora
				lTefAbort := .T.
				For nX := 1 To Len(aPgtos)
					If Alltrim(aPgtos[nX][3]) $ _FORMATEF .AND. lUsaTef
						cNumNSU := ""
						If cTipTef == TEF_CLISITEF .And. Len(aTefBKP) > 0
							If ( nY := aScan( aTefBKP, { |x|  x:CFORMA == aPgtos[nX][3] .And. x:CIDCART == aPgtos[nX][8] } ) ) > 0 .And. !Empty(aTefBKP[nY]:CAUTORIZA)
								cNumNSU := aTefBKP[nY]:CNSUSITEF
							EndIf
						EndIf
						nY := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID
						If nY > 0
							aNSUVndTef[nY][3] += aPgtos[nX][2]
						Else
							Aadd(aNSUVndTef,{AllTrim(aPgtos[nX][3]),aPgtos[nX][8],aPgtos[nX][2],cNumNSU}) //Forma , ID , Valor , NSU digitada
						EndIf
					EndIf
				Next nX
				If Len(aNSUVndTef) > 0
					For nX := 1 to Len(aNSUVndTef)
						If Empty(aNSUVndTef[nX][4])
							LjGrvLog(cNumPai, "Lj7Pedido - Chamada da Tela para Digitação da NSU - TEF Manual")
							LjxTelaNSU(@aNSUVndTef[nX])
							LjGrvLog(cNumPai, "Lj7Pedido - Chamada da Tela para Digitação da NSU - Retorno:" , aNSUVndTef)
						EndIf
					Next nX
				EndIf
			EndIf
		EndIf		
	EndIf	
ElseIF  cTipTEF == "1"
	If lCont7Ped
		For nX := 1 To Len(aPgtos)
			If Alltrim(aPgtos[nX][3]) $ _FORMATEF
				nY := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID
				If nY > 0
					aNSUVndTef[nY][3] += aPgtos[nX][2]
				Else
					Aadd(aNSUVndTef,{AllTrim(aPgtos[nX][3]),aPgtos[nX][8],aPgtos[nX][2],""}) //Forma , ID , Valor , NSU digitada
				EndIf 
			EndIf
		Next nX
		If Len(aNSUVndTef) > 0
			For nX := 1 to Len(aNSUVndTef)
				LjGrvLog(cNumPai, "Lj7Pedido - Chamada da Tela para Digitação da NSU - TEF Manual")
				
				If !lAutomato
					LjxTelaNSU(@aNSUVndTef[nX])
				Else
					aNSUVndTef[nX][4] := "1" //Para teste automatizado simula que foi informado um NSU//
				EndIf

				LjGrvLog(cNumPai, "Lj7Pedido - Chamada da Tela para Digitação da NSU - Retorno:" , aNSUVndTef)
			Next nX
		EndIf
	EndIf
EndIf

If lCont7Ped
	LjGuardaTef(cNumPai)
EndIf

aRet := {lTefOk,lCont7Ped}

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} LJ7MFilhos
Função responsável gerar array com os orçamentos filhos

@type		function
@author		felipe.martinez
@version	P12.1.14
@since		02/03/2017
@return 	aRet:	[1] - Continua a processar a função LJ7Pedido?
					[2] - Array com os orçamentos filhos
/*/
//----------------------------------------------------------
Static Function LJ7MFilhos(	cLojaLocal	,lJob		,aRelGer	, aRelGar	,;
							cB1M996		,cImpRGer	,aProdAlter	, lAlterOrc	,;
							nValRes		,cTpGeraGdp	,lImpCNFLoc	, aBkpTable	,;
							aAuxaPgtos	,nFatorVen	, nFatorRes	, lVendErro	,;
							aTaxJuros	,nFrete		)
Local aRet			:= {}
Local aLojas		:= {}											// Ajusta o array com as informacoes dos orcamentos das outras lojas
Local aBkpLoja		:= {}											// Guarda uma copia do aLojas caso ocorra algum erro no PE LJ7049
Local aAuxLoja		:= {}
Local aSL2			:= {}
Local aArquivos 	:= {}											// Array com o retorno da funcao Lj7GeraOrc()
Local aSL4Total		:= {} 											// Totalizador Forma de Pagamento
Local aArqAux2		:= {}
Local aBkpSL2		:= {}
Local lFecVenLst	:= .F. 											// Variavel que fecha a venda da lista de presentes sem SLJ cadastrado
Local lVerLojLst    := .F.											// Variavel que verifica se existe loja cadastrada.
Local lAchou        := .F.                                         	// Variavel de Controle para alt. orçamento
Local lContinua     := .T.											// Variavel verificação de comparação para alt. orçamento
Local lLj7TudoOK	:= .T.											// Responsável por informar se irá continuar o LJ7Pedido ou encerrar devido a erro
Local lSB1Posic		:= .F.											// Foi posicionado corretamente o SB1
Local lLastOrc		:= .F. 											// Validacao de ultimo orcamento
Local cLojaRes 		:= ""											// Loja da Reserva
Local cQuebra		:= ""											// Quebra para geracao dos Pedidos de Venda
Local cTurno		:= ""
Local cFdtEntr 		:= Space(8)
Local cFdtMont 		:= Space(8)
Local cCodCont		:= ""											// Codigo do Contato
Local nPos			:= 0
Local nA            := 0                                           	// Variavel auxiliar
Local nX			:= 0
Local nSLJRecno		:= 0
Local nCredito 		:= 0 											// Total de Credito
Local nDecsAux		:= 0											// Numerio de casas decimais
Local uLJPERet		:= Nil											// Retorno do PE LJ7049
Local lLstPre		:= SuperGetMV("MV_LJLSPRE",,.F.) .AND. LjUpd78Ok()	// Lista de Presentes - Ativa
Local lGE			:= SuperGetMv("MV_LJIMPGF",,.F.) .AND. LjUP104OK() 	// Validação do Conceito Garantia Estendida
Local cMvLjTGar		:= SuperGetMV("MV_LJTPGAR",,"GE")              	// Define se é tipo GE
Local cMvLjTSF		:= SuperGetMV("MV_LJTPSF",,"SF")				// Tipo servico financeiro
Local cTpQuebra		:= SuperGetMV("MV_LJTPPED",, "1")				// Define o Tipo de Quebra para os Pedidos de Venda:
Local cMV_B1M996	:= GetNewPar("MV_B1M996", "")					// Campo da tabela SB1 que identifica venda para Orgaos Publicos. Tratamento Apuração de PIS/COF.
Local lB1M996		:= SB1->(ColumnPos(cMV_B1M996)) > 0				// Identifica se o campo configurado no parametro "MV_B1M996" existe na tabela SB1.
Local lAutoExC		:= IsBlind()									// Verifica se a rotina sera executada via execauto ou nao
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()										// Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lEmitNfce		:= LjEmitNFCe()									// Sinaliza se utiliza NFC-e
Local cTpEntrega	:= ""											// Tipo de Entrega
Local cCodLstPre	:= "" 											// Codigo Lista de Presente

Default cLojaLocal	:= ""
Default lJob		:= .F.
Default aRelGer		:= {}											// Array do Relatório Gerencial
Default aRelGar 	:= {}											// Array do Relatório de Garantia
Default cB1M996		:= ""
Default cImpRGer	:= ""
Default aProdAlter	:= {}
Default lAlterOrc	:= .F.
Default nValRes		:= 0
Default cTpGeraGdp	:= GDP_NO
Default lImpCNFLoc	:= .F.											// Indica que sera impresso o comprovante nao fiscal
Default aBkpTable	:= {}
Default aAuxaPgtos	:= {}
Default nFatorVen	:= 0
Default nFatorRes	:= 0
Default lVendErro	:= .F.	

nDecsAux := iif(lJob,MsDecimais(1),nDecimais)

DbSelectArea("SLJ")
SLJ->(DbSetOrder(3))	//Filial + Empresa + Filial
If SLJ->(DbSeek(xFilial("SLJ") + cEmpAnt + cFilAnt))
	cLojaLocal	:= SLJ->LJ_CODIGO
	nSLJRecno	:= SLJ->(Recno())
Else
	//Verificação Lista de Presentes se estiver vendendo um item da Lista de Presentes
	//sem a Identificação de Lojas Cadastrada (SLJ) a venda nao sera concluida.
	If lLstPre .AND. !lJob
    	lVerLojLst := .T.
    EndIf
EndIf
//Seleciona o indice para pesquisa dentro do Loop
SLJ->(DbSetOrder(1))	//"LJ_FILIAL+LJ_CODIGO"
SB1->(dbSetOrder(1))	//"B1_FILIAL+B1_COD"
DbSelectArea("SL2")
SL2->(DbSetOrder(1))	//"L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO"
SL2->(DbSeek( xFilial("SL2") + SL1->L1_NUM ))
While !SL2->(Eof()) .AND. (SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM)
	
	lSB1Posic := SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))
	
	//Se o produto de vendas estiver amarrado a um
	//produto de garantia add para imprimir Relatorio gerencial
	If lGE 
	 	If !Empty(SL2->L2_GARANT)
	 		aRelGer := LjxGetRGer()
			AADD(aRelGer, {SL2->L2_PRODUTO,SL2->L2_DESCRI,Str(a410Arred(SL2->L2_VRUNIT * SL2->L2_QUANT,"L2_VLRITEM"), TamSX3("L2_VLRITEM")[1],nDecsAux),SL2->L2_NSERIE})
			LjxSetRGer( aRelGer )

		ElseIf lSB1Posic .And. SB1->B1_TIPO == cMvLjTGar
			aRelGar := LjxGetRGar()
			AADD(aRelGar, {SL2->L2_PRODUTO,SL2->L2_DESCRI,Str(a410Arred(SL2->L2_VRUNIT * SL2->L2_QUANT,"L2_VLRITEM"), TamSX3("L2_VLRITEM")[1],nDecsAux),SL2->L2_NSERIE})
			LjxSetRGar( aRelGar )
		EndIf
	EndIf

	//Verifica configuracao do produto referente a Venda para Orgaos Publicos
	If lB1M996 .And. lSB1Posic .And. cB1M996 <> "1" 
		cB1M996	:=	SB1->(FieldGet(ColumnPos(cMV_B1M996)))
	EndIf

	If LjGtMVLJCSF() .AND. cMvLjTSF == SB1->B1_TIPO
		MG8->(DbSetOrder(2))
		If MG8->(DbSeek(xFilial("MG8")+SL2->L2_PRODUTO))
			If !Empty(MG8->MG8_RDMAKE)
				cImpRGer:=MG8->MG8_RDMAKE
			EndIf
		EndIf
	EndIf

	If Len(aProdAlter) > 0 .AND. lAlterOrc
		For nA := 1 To Len(aProdAlter)
			If !(lAchou)
				If (aProdAlter[nA][1] + aProdAlter[nA][2] == SL2->L2_ITEM + SL2->L2_PRODUTO)
					lAchou    := .T.
					lContinua := .T.
				Else
					lContinua := .F.
				EndIf
			EndIf
		Next nA
		lAchou := .F.
	EndIf

    If lContinua
		If Empty(SL2->L2_LOJARES)
			cLojaRes	:= cLojaLocal
		Else
			cLojaRes	:= SL2->L2_LOJARES
		EndIf
		//Inclui a Loja na Chave de Pesquisa
		cQuebra := cLojaRes
		//Quebra por lista de presentes
		If SL2->L2_ENTREGA <> "2"
			cCodLstPre 	:= Alltrim(SL2->L2_CODLPRE)
			cQuebra 	+= cCodLstPre
		Else
			cCodLstPre := ""
		Endif

		cFdtEntr 	:= Space(8)
		cFdtMont 	:= Space(8)
		cTurno	 	:= ""
		
		If Empty(SL2->L2_ENTREGA)
			cTpEntrega 	:= "2" //2=Retira
		Else
			cTpEntrega 	:= SL2->L2_ENTREGA
			If cTpEntrega <> "2"
				cFdtEntr := DtoS(SL2->L2_FDTENTR)
				cFdtMont := DtoS(SL2->L2_FDTMONT)
				cTurno	 := SL2->L2_TURNO
			EndIf
		EndIf
		cQuebra += cTpEntrega

		IF !Empty(SL2->L2_CODCONT)
			cCodCont	:= SL2->L2_CODCONT
		Else
			If Empty(Alltrim(SL2->L2_CLIENT + SL2->L2_CLILOJA))
				cCodCont	:= Left(SL1->L1_CLIENTE,TamSX3("L2_CLIENT")[1]) + SL1->L1_LOJA
			Else
				cCodCont	:= SL2->L2_CLIENT + SL2->L2_CLILOJA
			EndIf
		Endif
		// Loja + Tipo de Entrega + Contato
		If cTpQuebra == "2"
	        cQuebra += cCodCont
			nPos := Ascan(aLojas, {|x| x[3] + x[12] + x[6] + x[8] == cQuebra})

		//Loja + Tipo de Entrega + Data Entrega
		ElseIf cTpQuebra == "3"
			//Inclui a Data de Entrega
			cQuebra	+= cFdtEntr
			nPos := Ascan(aLojas, {|x| x[3] + x[12] + x[6] + x[7] == cQuebra})

		//Loja + Tipo de Entrega + Contato + Data Entrega
		ElseIf cTpQuebra == "4"
			//Inclui a Data de Entrega + o Codigo do Contato
			cQuebra	+= cFdtEntr + cCodCont
			nPos	:= Ascan(aLojas, {|x| x[3] + x[12] + x[6] + x[7] + x[8] == cQuebra})

		//Loja + Tipo de Entrega + Data Montagem
		ElseIf cTpQuebra == "5"
			//Inclui a Data de Montagem
			cQuebra	+= cFdtMont
			nPos	:= Ascan(aLojas, {|x| x[3] + x[12] + x[6] + x[10] == cQuebra})

		//Loja + Tipo de Montagem + Contato + Data Montagem
		ElseIf cTpQuebra == "6"
			//Inclui a Data de Montagem + o Codigo do Contato
			cQuebra	+= cFdtMont + cCodCont
			nPos	:= Ascan(aLojas, {|x| x[3] + x[12] + x[6] + x[10] + x[8] == cQuebra})

		//Loja + Tipo de Entrega + Contato + Data de entrega + Data Montagem
		ElseIf cTpQuebra == "7"
			//Inclui Codigo do Contato + Data de entrega + Data de Montagem
			cQuebra	+= cFdtEntr + cFdtMont + cCodCont
			nPos	:= Ascan(aLojas, {|x| x[3] + x[12] + x[6] + x[7] + x[10] + x[8] == cQuebra})

		//Loja + Tipo de Entrega + Contato + Data Entrega + Turno
		ElseIf cTpQuebra == "8"
			//Inclui a Data de Entrega + o Codigo do Contato + Turno
			cQuebra	+= cFdtEntr + cCodCont + cTurno
			nPos	:= Ascan(aLojas, {|x| x[3] + x[12] + x[6] + x[7] + x[8] + x[11] == cQuebra})

		//Loja + Tipo de Entrega
		Else
			nPos	:= Ascan(aLojas, {|x| x[3] + x[12] + x[6] == cQuebra})
		EndIf

		//Posiciona na Loja da Reserva
		If !SLJ->(DbSeek(xFilial("SLJ") + cLojaRes))
			//Verificação Lista de Presentes. Se estiver vendendo um item da Lista de Presentes
			//sem a Identificação de Lojas Cadastrada (SLJ) a venda nao sera concluida
			If lLstPre .AND. !lJob
    			lVerLojLst := .T.
            EndIf
            
            If nSLJRecno > 0 //Reposiciona no registro do inicio caso nao encontre
            	SLJ->(DBGoto(nSLJRecno))
            EndIf
        EndIf

		If nPos == 0
			Aadd( aLojas,{	SL1->L1_FILIAL	,;											// 01- Filial do orcamento original
							SL1->L1_NUM		,;											// 02- Numero do orcamento original
							cLojaRes		,;											// 03- Codigo da loja da reserva (SLJ)
							SLJ->LJ_RPCFIL	,;											// 04- Codigo da filial da reserva
							{SL2->L2_ITEM}	,;											// 05- Array com os itens de cada loja (filial)
							cTpEntrega		,;											// 06- Tipo de Entrega
							cFdtEntr		,;											// 07- Data Entrega
							cCodCont		,;											// 08- Codigo do Contato
							SL2->L2_RESERVA	,;											// 09- Reserva
							cFdtMont		,;											// 10- Data Montagem
							cTurno			,;											// 11- Turno de Entrega
							cCodLstPre		,;											// 12- Lista de Presente
							SLJ->LJ_RPCFIL })											// 13- Codigo da filial de entrega onde sera gerado o pedido e o orcamento filho
		Else
			If Len(aProdAlter) == 0
				Aadd(aLojas[nPos][5], SL2->L2_ITEM)
			EndIF
		EndIf

		If ( SL2->L2_ENTREGA $ "1|3" )  .OR. (SL2->L2_ENTREGA == "2"	.AND. IIf(!Empty(SLJ->LJ_RPCFIL), SLJ->LJ_RPCFIL <> xFilial("SL1"),.F.)) // Armazena o valor dos itens de reserva
			nValRes += SL2->L2_VLRITEM
		EndIf

		aSL2 := {}
		If nPos == 0
			nPos := Len(aLojas)
		EndIf
		aAdd( aSL2, { "L2_FILRES"	, aLojas[nPos][4] } )
		aAdd( aSL2, { "L2_RESERVA"	, SL2->L2_RESERVA} )

		//Release 11.5 - Chile - Guia de Despacho - F2CHI
		//Limpar L2_DOC e L2_SERIE dos itens do orcamento pai,
		//pois os dados da factura com os itens de venda em que o
		//tipo de entrega seja 3 serao atualizados no orcamento filho.
		If LjGtCFolLoc() .AND. cPaisLoc == "CHI"  .AND. (cTpGeraGdp $ GDP_PARCIAL + ";" + GDP_TOTAL)
			aAdd( aSL2, { "L2_DOC"	, "" } )
			aAdd( aSL2, { "L2_SERIE", "" } )
		EndIf

		If (lEmitNfce .Or. LjGtPafNfce())
			If !Empty(SL2->L2_ORIGEM)
				aAdd( aSL2, { "L2_ORIGEM", SL2->L2_ORIGEM} )
			EndIf

			If !Empty(SL2->L2_MODBC)
				aAdd( aSL2, { "L2_MODBC", SL2->L2_MODBC} )
			EndIf

			If !Empty(SL2->L2_POSIPI)
				aAdd( aSL2, { "L2_POSIPI", SL2->L2_POSIPI} )
			EndIf
		EndIf

		If !Empty(SL2->L2_CODISS)
			aAdd( aSL2, { "L2_CODISS", SL2->L2_CODISS} )
		EndIf

		Lj7GeraSL( "SL2", aSL2 )

	EndIf

	//Release 11.5 - Controle de Formularios - F2CHI
	//Verificar quais os tipos de entrega sao validos para impressao de comprovante de venda para cada pais localizado.
	//Paises: Chile/Colombia
	If LjGtCFolLoc() .AND. !lJob
		Do Case
		Case cPaisLoc == "COL"
			If SL2->L2_ENTREGA $ "1|3"
				lImpCNFLoc := .T.
			EndIf
		Case cPaisLoc == "CHI"
			If SL2->L2_ENTREGA ==  "1"
				lImpCNFLoc := .T.
			EndIf
		EndCase
	EndIf

	//Verificação Lista de Presentes. Se estiver vendendo um item da Lista de Presentes sem a 
	//Identificação de Lojas Cadastrada (SLJ) a venda nao sera concluida
	If lVerLojLst .AND. !lJob .AND. !Empty(SL2->L2_CODLPRE)
		lFecVenLst := .T.
	EndIf

	//Nos casos de PDV offline, faz o backup de cada registro, pois se houver algum erro,
	//o registro poderá ser recuperado através da função, pois em DBF não há Controle de Transação
	If LjGtBGtPaf() 
		Aadd( aBkpSL2, LjBkpReg("SL2") )
	EndIf

	SL2->( DbSkip() )
End

If LjGtBGtPaf() 
	Aadd(aBkpTable, {"SL2", aBkpSL2} )
EndIf

//Lista de Presentes
//Caso tenha encontrado algum produto que seja de Lista de Presentes e não tenha identificacao de lojas cadastrada.
//Exibe mensagem ao usuário e Finaliza operacao sem completar a Venda.
If lFecVenLst
	If !lAutoExC
		MsgStop(STR0012) //"Necessario cadastrar Identificação de Lojas para realizar Vendas com Itens da Lista de Presentes"
	Else
    	Conout(STR0012) //"Necessario cadastrar Identificação de Lojas para realizar Vendas com Itens da Lista de Presentes"
    	Help( " ", 1, "Help",, STR0012, 1, 0 ) //"Necessario cadastrar Identificação de Lojas para realizar Vendas com Itens da Lista de Presentes"
 	Endif
	LjGrvLog(SL1->L1_NUM,STR0012)
    lLj7TudoOK := .F.
EndIf

If lLj7TudoOK
	Begin Sequence
		//Ponto de Entrada para geracao de quebras nos Orcamentos Filho
		If ExistBlock("LJ7049") .AND. !lFtvdVer12
			aBkpLoja	:= aClone(aLojas)
			uLJPERet	:= U_LJ7049(aLojas)
			If ValType(uLJPERet) == "A"
				aLojas	:= aClone(uLJPERet)
			EndIf
		EndIf
	
		If ExistBlock("FTVD7049") .AND. lFtvdVer12
			aBkpLoja	:= aClone(aLojas)
			uLJPERet	:= U_FTVD7049(aLojas)
			If ValType(uLJPERet) == "A"
				aLojas	:= aClone(uLJPERet)
			EndIf
		EndIf
	
	Recover
		aLojas := aClone(aBkpLoja)
	End Sequence
	
	//Caso L1_DOCPED em branco
	If Len(aLojas) > 0
		If Empty(SL1->L1_DOCPED) .AND. lJob
			
			aAuxLoja := {}
			 
			For nX := 1 to Len(aLojas)
				If !Empty(aLojas[nX][9]) .AND. aLojas[nX][6] <> "2"
					lVendErro := .T.
				EndIf
				
				If lVendErro .And. aLojas[nX][6] == "2" .And. SL1->L1_VENDTEF == "N"
					aAdd(aAuxLoja,aLojas[nX])
				EndIf
			Next nX
	
			If lVendErro .AND. SL1->L1_VENDTEF == "N"
	
				Reclock( "SL1", .F. )
				REPLACE SL1->L1_STATUS 	WITH "T"
				SL1->( MsUnlock() )
	
				aBkpLoja := aClone(aAuxLoja)
	
				If Len(aBkpLoja) > 0
					aLojas := {}
					aLojas := aClone(aBkpLoja)
				EndIf
			EndIf
		EndIf
	EndIf


	// 3 - Recalcula impostos, descontos, rateios ,arredondamentos	
	If cPaisLoc == "BRA"
		//Executa o recalculo das tributacoes da venda (aqui serao utilizados os arrays aSL1 e aSL2
		Lj7RecTrib(	NIL		,	NIL,	nFrete	, NIL	,;
					lJob	,	NIL, 	NIL		, NIL	,;
					@nValRes,	NIL,	NIL		, aTaxJuros	)
	EndIf
		
	LjGrvLog(SL1->L1_NUM,"GERACAO DOS PEDIDOS LJRECTRIB ")
		
	//Trata os valores com reserva
	If nValRes > 0
		nFatorVen := Lj7FatRes(nValRes, SL1->L1_VLRLIQ,nFrete)[1]
		nFatorRes := Lj7FatRes(nValRes, SL1->L1_VLRLIQ,nFrete)[2]
	EndIf

	//Gera os arrays depois do recalculo dos valores (aqui sera utilizado o
	//array aSL4 e os aSL1 e aSL2 para gravacao do orcamento na loja onde originou o orcamento
	LjGrvLog(Nil,'Geração das tabelas filhas do pedido')
	For nX := 1 to Len(aLojas)
		//Marca se ultimo orcamento
		If nX == Len(aLojas)
			lLastOrc := .T.
		Else
			lLastOrc := .F.
		EndIf

		//Posiciona o orcamento no original
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
		SL1->(DbSeek(aLojas[nX][1]+aLojas[nX][2]))

		//Gera os arrays (aSL1, aSL2 e aSL4) com os dados de cada orcamento
		aArquivos := Lj7GeraOrc(aLojas[nX][5]	, lJob		, aAuxaPgtos, aLojas[nX][6]	,;
								lAlterOrc		, nFatorVen	, nFatorRes	, lLastOrc		,;
								@nCredito		, aSL4Total )

		aAdd( aArqAux2, { aClone(aLojas[nX]), aArquivos } )
	
	Next nX
	LjGrvLog(Nil,'Final Geração das tabelas filhas do pedido')
EndIf

aRet := {lLj7TudoOK, aClone(aArqAux2)}

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} Lj7AtuPed
Função responsável por atualizar informacoes do orcamento original 
da venda (pai).

@type		function
@author		felipe.martinez
@version	P12.1.14
@since		02/03/2017
@return 	Nil
/*/
//----------------------------------------------------------
Static Function Lj7AtuPed(	lJob		, aRetCNF	, cDocPed	, cSeriePed	,;
							cTpGeraGdp	, cDocPai	, cSeriePai	, lTefOk	,;
							aNSUVndTef	, lAvCred	, cLojaLocal, lTefManuPed)
Local lHVerao		:= SuperGetMv("MV_HVERAO",,.F.)					// Se o local fisico do servidor está em Horário de Verão(.F.->Não/.T.->Sim)
Local cHoraRMT		:= SuperGetMv("MV_HORARMT",,"2")
Local lECommerce	:= SuperGetMV("MV_LJECOMM",,.F.) .And. SL1->L1_ECFLAG == "1" // Tratamento para eCommerce
Local cNSUVndTef	:= ""
Local nX			:= 0
Local nPosDTEF		:= 0
Local nCont			:= 0
Local aArea2		:= {}
Local aAreaSM0		:= {}
Local aTimeUf		:= {}
Local aSL1			:= {}
Local aSL4			:= {}
Local aDTEFPend		:= {}											// Transacoes Pendentes Direcao
Local lIsDiscado	:= L010IsDirecao(L010GetGPAtivo())
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)				    	// Verifica as filiais da trabalharam com acrescimento separado
Local cL1NSUTEF		:= ""
Local cL4NSUTEF		:= ""
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.)				// Identifica se o cliente utiliza múltiplas transacoes TEF
Local nMVLjTrDin	:= SuperGetMv("MV_LJTRDIN",,0)					// Se o local fisico do servidor está em Horário de Verão(.F.->Não/.T.->Sim)
Local lMVLjTroco	:= SuperGetMv("MV_LJTROCO",,.F.)				// Determina se utiliza troco para diferentes formas de Pagamento
Local lIntegDef     := SL1->L1_ORIGEM == "N"

Default lJob		:= .F.
Default aRetCNF		:= {.F., {"", ""}}
Default cDocPed		:= ""
Default cSeriePed	:= ""
Default cTpGeraGdp	:= GDP_NO						              	// Informa como sera gerada Guia de Despacho a partir do pedido de venda.
Default cDocPai		:= ""
Default cSeriePai	:= ""
Default lTefOk		:= .F.
Default aNSUVndTef	:= {}
Default lAvCred		:= .F.
Default cLojaLocal	:= ""
Default lTefManuPed :=.F. 											// Verifica se utiliza TEF Manual e se será executado o cancelamento da venda qdo pedido.

If ValType(cHoraRMT) == "L"
	If cHoraRMT
		cHoraRMT := "1"
	Else
		cHoraRMT := "2"
	EndIf
Else
	If cHoraRMT == NIL
		cHoraRMT := "2"
	EndIf
EndIf

//Faz a gravacao do SL1
IF !lJob
	If cHoraRMT == "3" .And. cPaisLoc == "BRA" // Data de Emissao do pedido
		aArea2		:= GetArea()
		dbSelectArea("SM0")
		aAreaSM0	:= GetArea()
		dbSetOrder(1)
		If dbSeek(cEmpAnt+cFilAnt)
			aTimeUf	:= FwTimeUF(SM0->M0_ESTENT,,lHVerao)
		EndIf
		RestArea(aAreaSM0)
		RestArea(aArea2)
		aAdd( aSL1, { "L1_EMISNF", STOD(aTimeUf[1]) } )
	Else
		aAdd( aSL1, { "L1_EMISNF", dDatabase } )
	EndIf
	aAdd( aSL1, {"L1_NUMMOV", LJNumMov()} )					// Num do Mov para considerar no resumo de caixa
EndIf

aAdd( aSL1, {"L1_TIPO"		, "P"} )						// Indica que tem reserva
aAdd( aSL1, {"L1_RESERVA"	, "S"} )						// Indica que tem reserva
aAdd( aSL1, {"L1_OPERADO"	, IIf(!lJob,xNumCaixa(),SL1->L1_OPERADO)} )	// Operador
aAdd( aSL1, {"L1_PDV"		, aRetCNF[2][2]	} )				// Numero do PDV

If !Empty(cDocPed)
	aAdd( aSL1, {"L1_DOCPED"	, cDocPed } )					// Numero do cupom nao fiscal (pedido)
EndIf	

cDocPed := aRetCNF[2][1]

If  lECommerce
	aAdd( aSL1, {"L1_SERPED",  SL1->L1_SERPED} )  //Ja gravado anteriormente

ElseIf LjGtCFolLoc() .AND. !Empty(SuperGetMV("MV_LOJAPED"))
	//Paises: Chile/Colombia - Controle de Formularios
	//Obter numero do documento e serie informados no parametro MV_LOJAPED.
	// Numero do serie do cupom nao fiscal (pedido)
	aAdd( aSL1, {"L1_SERPED", If(Len(aRetCNF[2])==3 .AND. !Empty(aRetCNF[2]),aRetCNF[2][3],SuperGetMV("MV_LOJAPED"))} )
ElseIf !lJob
	aAdd( aSL1, {"L1_SERPED", If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE"))} )	// Numero do serie do cupom nao fiscal (pedido)
	cSeriePed := If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE"))
EndIf

If lJob
	aAdd( aSL1, {"L1_NUMFRT"	, SL1->L1_NUMFRT} )
	aAdd( aSL1, {"L1_SITUA"		, "FR"} )
	IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit("","FR"), NIL)

	//Chile - Guia de Despacho - F2CHI
	//Quando o job estiver em execucao subindo a venda de um item com entrega do tipo 3 , guardar L1_DOC e L1_SERIE do orcamento
	//pai pois estes de dados serao utilizados na geracao do orcamento filho.
	If LjGtCFolLoc() .AND. cPaisLoc == "CHI" .AND. (cTpGeraGdp $ GDP_PARCIAL + ";" + GDP_TOTAL)
		cDocPai 	:= SL1->L1_DOC
		cSeriePai	:= SL1->L1_SERIE
		aAdd( aSL1, {"L1_DOC"		, ""} )
		aAdd( aSL1, {"L1_SERIE"		, ""} )
		aAdd( aSL1, {"L1_IMPRIME"	, "1N"} )
	EndIf
EndIf

//Limpamos os campos L1_DOC e L1_SERIE, pois quando uma venda com itens reservados era enviado a retaguarda, os campos L1_DOC
//e L1_DOCPED do orcamento pai estavam preenchidos, sendo que soh o campo L1_DOCPED deveria, ja que se trata de um CNF.
//Isso impactava na geracao do SPED, pois ele trazia vendas repetidas, pelo fato do L1_DOC aparecer em mais de uma venda.
If cPaisLoc == "BRA" .AND. !Empty( SL1->L1_DOCPED )
	aAdd( aSL1, {"L1_DOC"	, ""} )
	aAdd( aSL1, {"L1_SERIE"	, ""} )
EndIf

If lUsaTef .AND. lTefOk
	If cTipTef == TEF_CLISITEF
	
		//Efetua a alteracao das datas e conf. de ADM informadas durante o processamento do TEF
		LjTEFAceParc()


		//Gerando os dados do TEF para a tabela SL1
		aSL1 := LjTEFGeraSL(aSL1,"SL1")

	ElseIf cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + TEF_DISCADO
		aAdd( aSL1, { "L1_VENDTEF","S"})
		aAdd( aSL1, { "L1_DATATEF",aTefDados[1][2]})
		aAdd( aSL1, { "L1_HORATEF",aTefDados[1][3]})
		aAdd( aSL1, { "L1_DOCTEF" ,aTefDados[1][4]})
		aAdd( aSL1, { "L1_AUTORIZ",aTefDados[1][5]})
		aAdd( aSL1, { "L1_INSTITU",aTefDados[1][8]})
		aAdd( aSL1, { "L1_DOCCANC",aTefDados[1][6]})
		aAdd( aSL1, { "L1_DATCANC",aTefDados[1][12]})
		aAdd( aSL1, { "L1_HORCANC",aTefDados[1][7]})
		aAdd( aSL1, { "L1_NSUTEF" ,aTefDados[1][9]})
		aAdd( aSL1, { "L1_TIPCART",aTefDados[1][10]})
		If !Empty(aTefDados[1][15])
			aAdd( aSL1, { "L1_FORMPG",aTefDados[1][15]})
		EndIf
		
		aAdd(aSL1,{"L1_TEFBAND"	, aTefDados[1][18]})
	EndIf
Else
	If Len(aNSUVndTef) > 0
		cNSUVndTef	:= aNSUVndTef[1][4]
		If !Empty(AllTrim(cNSUVndTef))
			cL1NSUTEF := cNSUVndTef
			aAdd( aSL1, { "L1_VENDTEF", "S"})
			aAdd( aSL1, { "L1_DOCTEF" , cNSUVndTef } )
			aAdd( aSL1, { "L1_NSUTEF" , cL1NSUTEF } )
			aAdd( aSL1, { "L1_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )
		Else
			LjGrvLog(Nil,"Atenção: Tela de NSU foi aberta porem não foi digitado um numero de transacao. SL1 será gravada sem dados de TEF Manual")
		EndIf
	EndIf
EndIf

If !lJob
	LjGrvLog( M->LQ_NUM ,'Gera SL1', aSL1)
EndIf

Lj7GeraSL( "SL1", aSL1, .F., .F. )

If !lJob
	LjGrvLog( M->LQ_NUM ,'Gera SL4')
EndIf

//Faz a gravacao do SL4
If cTipTEF == TEF_DISCADO  .AND. lIsDiscado
	aDTEFPend :=  LJLoadDTEF()
EndIf

For nX := 1 to Len( aPgtos )
	aAdd( aSL4, {} )
	aAdd( aSL4[nX], { "L4_FILIAL"	, xFilial("SL4") } )
	aAdd( aSL4[nX], { "L4_NUM"		, SL1->L1_NUM	} )
	aAdd( aSL4[nX], { "L4_DATA"		, aPgtos[nX][1] } )
	
	If nMVLjTrDin == 0 .AND. lMVLjTroco	.or. lIntegDef
		aAdd( aSL4[nX], { "L4_VALOR"	, aPgtos[nX][2] } )
	Else	
		aAdd( aSL4[nX], { "L4_VALOR"	, aPgtos[nX][2] - Lj7T_Troco(2)} )
	EndIf
	
	aAdd( aSL4[nX], { "L4_FORMA"	, aPgtos[nX][3] } )

	If !IsMoney(aPgtos[nX][3]) .AND. !lLayAway
		If Trim(aPgtos[nX][3]) == "CH"
			aAdd( aSL4[nX], { "L4_ADMINIS"	, aPgtos[nX][4][04] } )
			aAdd( aSL4[nX], { "L4_NUMCART"	, aPgtos[nX][4][07] } )
			aAdd( aSL4[nX], { "L4_AGENCIA"	, aPgtos[nX][4][05] } )
			aAdd( aSL4[nX], { "L4_CONTA"	, aPgtos[nX][4][06] } )
			aAdd( aSL4[nX], { "L4_RG"		, aPgtos[nX][4][09] } )
			aAdd( aSL4[nX], { "L4_TELEFON"	, aPgtos[nX][4][10] } )
			aAdd( aSL4[nX], { "L4_COMP"   	, aPgtos[nX][4][08] } )
			aAdd( aSL4[nX], { "L4_TERCEIR"	, aPgtos[nX][4][12] } )
			aAdd( aSL4[nX], { "L4_NOMECLI"	, aPgtos[nX][4][14] } )
		Else
			If Len(aPgtos[nX][4]) >= 5 .AND. cTipTEF <> TEF_DISCADO
				aAdd( aSL4[nX], { "L4_ADMINIS"	, aPgtos[nX][4][05] } )
				aAdd( aSL4[nX], { "L4_NUMCART"	, aPgtos[nX][4][04] } )
			EndIf
		EndIf
	EndIf

	//Grava o valor do acrescimo separado da parcela
	If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
    	If Len(aPgtos[nX][4]) >= 13 .AND. ValType(aPgtos[nX][4][13]) == "N"
			aAdd( aSL4[nX], { "L4_ACRSFIN"	, aPgtos[nX][4][13] } )
		Endif
	Endif

	// ALTERACAO PARA GRAVACAO DOS DADOS DO TEF NO SL4
	aAdd( aSL4[nX], { "L4_VENDTEF","N" })

	If lUsaTef .AND. lTefOk
		If cTipTef == TEF_CLISITEF

			//³Gerando os dados do TEF para a tabela SL4
			aSL4 := LjTEFGeraSL( 	aSL4			, "SL4"	, Nil, aPgtos[nX, 3]	, ;
									aPgtos[nX, 8]	, Nil	, Nil, Nil				, ;
									Nil				, nX )

		ElseIf cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + TEF_DISCADO

			If (nPos := Ascan( aTefMult,{|x| Ascan(x[10],StrZero(nX,2))>0 }) ) <> 0
				If Len( aTefMult[nPos][7] ) > 0
					aTefDados:=aClone(aTefMult[nPos][7])
					aAdd( aSL4[nX], { "L4_VENDTEF","S"})
					aAdd( aSL4[nX], { "L4_DATATEF",aTefDados[1][2]})
					aAdd( aSL4[nX], { "L4_HORATEF",aTefDados[1][3]})
					aAdd( aSL4[nX], { "L4_DOCTEF" ,aTefDados[1][4]})
					aAdd( aSL4[nX], { "L4_AUTORIZ",aTefDados[1][5]})
					aAdd( aSL4[nX], { "L4_INSTITU",aTefDados[1][8]})
					aAdd( aSL4[nX], { "L4_DOCCANC",aTefDados[1][6]})
					aAdd( aSL4[nX], { "L4_DATCANC",aTefDados[1][12]})
					aAdd( aSL4[nX], { "L4_HORCANC",aTefDados[1][7]})
					aAdd( aSL4[nX], { "L4_NSUTEF" ,aTefDados[1][9]})
					aAdd( aSL4[nX], { "L4_TIPCART",aTefDados[1][10]})
					If !Empty(aTefDados[1][15])
						aAdd( aSL4[nX], { "L4_FORMPG",aTefDados[1][15]})
					EndIf
				EndIf
			ElseIf cTipTEF == TEF_DISCADO  .AND. lIsDiscado  .AND.;
			 		Trim(aPgtos[nX][3]) $ _FORMATEF .AND. Len(aDTEFPend) > 12
			 		
				nPosDTEF := aScan(aDTEFPend, {|t| t[14] == aPgtos[nX, 8] })
				If nPosDTEF > 0  //5
					aAdd(aSL4[nX], { "L4_VENDTEF","S"})
					aAdd(aSL4[nX], { "L4_DATATEF",aDTEFPend[nPosDTEF][10]})
					aAdd(aSL4[nX], { "L4_HORATEF",aDTEFPend[nPosDTEF][11]})
					aAdd(aSL4[nX], { "L4_DOCTEF" ,aDTEFPend[nPosDTEF][13]})
					aAdd(aSL4[nX], { "L4_AUTORIZ",aDTEFPend[nPosDTEF][13]})
					aAdd(aSL4[nX], { "L4_NSUTEF" ,Right(aDTEFPend[nPosDTEF][7],6)})
				EndIf

			ElseIf cTipTEF == TEF_DISCADO .AND. Alltrim(aPgtos[nX][3]) $ _FORMATEF
				If lTefMult
					nPosTefDados := aScan(aTefDados,{|x|,Alltrim(x[20])== Alltrim(aPgtos[nX][3]) .AND. Alltrim(x[19]) == Alltrim(aPgtos[nX][8])})
					If Len(aTEFDados) >= 1 .AND. Len(aTEFDados[1]) >= 15
						aAdd( aSL4[nX], { "L4_VENDTEF","S"})
						aAdd( aSL4[nX], { "L4_DATATEF",aTefDados[nPosTefDados][2]})
						aAdd( aSL4[nX], { "L4_HORATEF",aTefDados[nPosTefDados][3]})
						aAdd( aSL4[nX], { "L4_AUTORIZ",aTefDados[nPosTefDados][5]})
						aAdd( aSL4[nX], { "L4_INSTITU",aTefDados[nPosTefDados][8]})
						aAdd( aSL4[nX], { "L4_DOCCANC",aTefDados[nPosTefDados][6]})
						aAdd( aSL4[nX], { "L4_DATCANC",aTefDados[nPosTefDados][12]})
						aAdd( aSL4[nX], { "L4_HORCANC",aTefDados[nPosTefDados][7]})
						If lIsDiscado
							aAdd( aSL4[nX], { "L4_NSUTEF" ,Right(aTefDados[nPosTefDados][9],6)})
							aAdd( aSL4[nX], { "L4_DOCTEF" ,aTefDados[nPosTefDados][5]})
						Else
							aAdd( aSL4[nX], { "L4_NSUTEF" ,aTefDados[nPosTefDados][9]})
							aAdd( aSL4[nX], { "L4_DOCTEF" ,aTefDados[nPosTefDados][4]})
						EndIf
						aAdd( aSL4[nX], { "L4_TIPCART",aTefDados[nPosTefDados][10]})
						If !Empty(aTefDados[1][15])
							aAdd( aSL4[nX], { "L4_FORMPG",aTefDados[nPosTefDados][20]})
						EndIf
						aAdd( aSL4[nX], { "L4_ADMINIS"	, aPgtos[nX][4][05] } )
					EndIf
				Else
					// Se estiver usando Pay&Go e MV_TEFMULT = .F. faz tratamento para preencher a array aSL4 a partir do aTefDados
					If Len(aTEFDados) >= 1 .AND. Len(aTEFDados[1]) >= 15
						aAdd( aSL4[nX], { "L4_VENDTEF","S"})
						aAdd( aSL4[nX], { "L4_DATATEF",alltrim(aTefDados[1][2])})
						aAdd( aSL4[nX], { "L4_HORATEF",alltrim(aTefDados[1][3])})
						aAdd( aSL4[nX], { "L4_AUTORIZ",alltrim(aTefDados[1][5])})
						aAdd( aSL4[nX], { "L4_INSTITU",alltrim(aTefDados[1][8])})
						aAdd( aSL4[nX], { "L4_DOCCANC",alltrim(aTefDados[1][6])})
						aAdd( aSL4[nX], { "L4_DATCANC",alltrim(aTefDados[1][12])})
						aAdd( aSL4[nX], { "L4_HORCANC",alltrim(aTefDados[1][7])})
	
						If lIsDiscado
							aAdd( aSL4[nX], { "L4_NSUTEF" ,alltrim(aTefDados[1][9])})
							aAdd( aSL4[nX], { "L4_DOCTEF" ,alltrim(aTefDados[1][5])})
						Else
							aAdd( aSL4[nX], { "L4_NSUTEF" ,alltrim(aTefDados[1][9])})
							aAdd( aSL4[nX], { "L4_DOCTEF" ,alltrim(aTefDados[1][4])})
						EndIf
						aAdd( aSL4[nX], { "L4_TIPCART",alltrim(aTefDados[1][12])})
						If !Empty(aTefDados[1][15])
							aAdd( aSL4[nX], { "L4_FORMPG",alltrim(aTefDados[1][20])})
						EndIf
						aAdd( aSL4[nX], { "L4_ADMINIS"	,aPgtos[nX][4][05] } )
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If AllTrim(aPgtos[nX][3]) $ _FORMATEF .And. Len(aNSUVndTef) > 0
			nY := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID
			cNSUVndTef := IIf( nY > 0 , aNSUVndTef[nY][4], "")

			If (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. cTipTef == TEF_CLISITEF .AND. lUsaTEF
				// Chama a LjVerAdm para ajustar o array aPgtos na posicao referente ao Cod Adm Financeira
				LjVerAdm(.F.,.T.,lTefManuPed,nX,lTefManuPed)
			Endif

			cL4NSUTEF := cNSUVndTef
			aAdd( aSL4[nX], { "L4_VENDTEF", "S"})
			aAdd( aSL4[nX], { "L4_DOCTEF" , cNSUVndTef } )
			aAdd( aSL4[nX], { "L4_NSUTEF" , cL4NSUTEF } )
			aAdd( aSL4[nX], { "L4_AUTORIZ", cNSUVndTef } )
			aAdd( aSL4[nX], { "L4_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )
			aAdd( aSL4[nX], { "L4_ADMINIS", aPgtos[nX][4][05] } )
		EndIf
	EndIf
	
	If cPaisLoc <> "BRA"
	   aAdd( aSL4[nX], { "L4_MOEDA", aPgtos[nX][_MOEDA] } )
	EndIf
	//FIM DA ALTERACAO PARA GRAVACAO DOS DADOS DO TEF NO SL4
Next nX

nCont := 1
DbSelectArea("SL4")
SL4->(DbSetOrder(1)) //"L4_FILIAL+L4_NUM+L4_ORIGEM"
SL4->(DbSeek( xFilial("SL4") + SL1->L1_NUM ))
While !SL4->(Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM .AND. Empty( SL4->L4_ORIGEM )
	If nCont <= Len( aSL4 )
    	Lj7GeraSL( "SL4", aSL4[nCont] )
 	Else
 		RecLock("SL4",.F.)
 		SL4->(DbDelete())
 		SL4->(MsUnlock())
 	EndIf

	// Variavel que controla analise de credito para o pedido.
	If IsMoney(SL4->L4_FORMA) .OR. AllTrim(SL4->L4_FORMA) $ _FORMATEF
		lAvCred := .T. // Alteração temporária, pois verificamos que passando como falso está bloqueando o credito.
	EndIf

   	SL4->(DbSkip())
	nCont ++
End

For nX := nCont To Len( aSL4 )
	Lj7GeraSL( "SL4", aSL4[nCont], .T. )
Next nX

Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} LJ7GrvFilh
Função responsável por gravar os orcamento filhos e gerar o 
pedido de venda

@type		function
@author		felipe.martinez
@version	P12.1.14
@since		02/03/2017
@return 	Nil
/*/
//----------------------------------------------------------
Static Function LJ7GrvFilh(	aArqAux2	, aArquivos	, lJob		, cTpGeraGdp,;
							cDocPai		, cSeriePai	, aRetCNF	, cImpRGer	,;
							lVendErro	, lAlterOrc	, cNumPai	, lAvCred	,;
							aOrcRetira	, aPedidos	, cLojaLocal, cDocPed	,;
							cSeriePed)
Local lRet			:= .T.
Local lSemFrete 	:= .F.			// Define se o item tem frete ou não
Local lItemNormal 	:= .F.          // Valida o item que não seja Reserva, garantia ou serviço
Local lItLstPresC	:= .F.			// Item de lista de presente de CREDITO
Local lExistVfe		:= .F.			// Verifica se cenario contempla VFE
Local lValidVfe		:= .T. 			// PE para validar se executa VFE
Local nX			:= 0
Local nI			:= 0
Local nY			:= 0
Local nPos			:= 0
Local nPos1			:= 0
Local nPos2			:= 0
Local nConta		:= 0
Local nTamOrc		:= 0			// Tamanho do campo de orcamento (LQ_NUMORC)
Local nCont			:= 0 
Local aLojas		:= {}
Local aRelGer		:= {}
Local aRelGar		:= {}
Local aRet			:= {}
Local aSL2			:= {}
Local cCodProd      := ""			// Codigo do produto
Local cCodReserv  	:= ""           // Codigo da reserva
Local cRetRelG		:= ""			// Retorno do relatorio gerencial
Local cTipoLista	:= ""			// Tipo da lisya de presente
Local cCliente		:= "" 			// Codigo do Cliente
Local cLojaCli		:= "" 			// Loja do Cliente
Local cCliEnt		:= "" 			// Cliente de Entrega
Local cLojEnt		:= "" 			// Loja do Cliente de Entrega
Local cUFCli		:= ""
Local cUfCD			:= ""
Local cCodCdLocal	:= ""			// Codigo de Identificacao do CD Local
Local cFilLoc		:= "" 			// Loja em que foi feita a Reserva
Local cFilRES 		:= "" 			// Filial em que foi feita a Reserva
Local cSerOrc		:= ""			// Série do orçamento
Local lAutoExC 		:= IsBlind()
Local lGE		 	:= LjUP104OK() .And. SuperGetMv("MV_LJIMPGF",,.F.)	                    //Validação do Conceito Garantia Estendida
Local lCentroDL		:= SuperGetMv("MV_LJCDL",, .F.)						                    //Parametro de controle VFE
Local lCen1VFE	 	:= LjAnalisaLeg(69)[1] .And. SuperGetMv("MV_LJC1VFE", Nil, .F.)	        //Especifico para Minas Gerais = Cenario 1 - Loja da Venda
Local lLJ7058		:= ExistBlock("LJ7058")                                                 //Se existe o PE LJ7058. Esse ponto de entrada tem como objetivo permitir que o cliente crie uma única OS para todo o pedido, evitando a quebra da OS pelo parâmetro MV_LJTPPED
Local lLjInTec    	:= SuperGetMV("MV_LJINTEC",,'2') == '1'			                        //Define se existe integracao com Field Service
Local cTipoGE		:= SuperGetMV("MV_LJTPGAR",,"GE")                                       //Define se o Produto é GE
Local cTipoSF		:= SuperGetMV("MV_LJTPSF",,"SF")                                        //Define se o Produto é SF
Local lVldGESF		:= .T.							                                        //Variavel de controle:  existe GE ou  SF? 
Local lRegInteg		:= Posicione("SL1", 1, xFilial("SL1") + cNumPai, "L1_ORIGEM") == "N"    //Define se o registro sendo processo é da integração
Local aAuxSL1		:= {}
Local aAuxSL2		:= {}
Local aAuxSL4		:= {}
Local nPosProdut 	:= 0
Local nPosEntreg 	:= 0
Local lIntegDef     := .F.          // Venda Origem de Integração

Default aArqAux2	:= {}
Default aArquivos	:= {}
Default lJob		:= .F.
Default cTpGeraGdp	:= GDP_NO		// Informa como sera gerada Guia de Despacho a partir do pedido de venda.
Default cDocPai		:= ""
Default cSeriePai	:= ""
Default aRetCNF		:= {}
Default cImpRGer	:= ""
Default lVendErro	:= .F.
Default lAlterOrc	:= .F.
Default cNumPai		:= ""
Default lAvCred		:= .F.
Default aOrcRetira	:= {}
Default aPedidos	:= {}			// Array para geração do Pedido de venda
Default cLojaLocal	:= ""
Default cDocPed		:= ""
Default cSeriePed 	:= ""

//Faz a gravacao dos orcamentos nas filiais correspondentes
For nX := 1 To Len( aArqAux2 )
	aLojas := aClone(aArqAux2[nX][1])
	lSemFrete := .F.
	
	aArquivos := aClone(aArqAux2[nX][2])

	aAuxSL1 := aClone(aArquivos[1])
	aAuxSL2 := aClone(aArquivos[2])
	aAuxSL4 := aClone(aArquivos[3])

	//LIMPA INFORMACOES DO CAMPO L1_ORIGEM NO ORC. FILHO PARA INTEGRACOES
	nPos1 := Ascan(aAuxSL1,{|x| Alltrim(Upper(x[1])) == "L1_ORIGEM"})
	If Alltrim(aAuxSL1[nPos1][2]) == "N"
		aAuxSL1[nPos1][2] := ""
        lIntegDef := .T.
	Endif

	If Len(aAuxSL2) > 0
		nPosProdut := Ascan(aAuxSL2[1],{|x| Alltrim(Upper(x[1])) == "L2_PRODUTO"})
		nPosEntreg := Ascan(aAuxSL2[1],{|x| Alltrim(Upper(x[1])) == "L2_ENTREGA"})
	EndIf

	For nConta = 1 to Len(aAuxSL2)
		//Verifica se todos os itens da SL2 são GE ou SF, caso seja, a variavel lVldGESF retorna .T. e  ALTERA o L1_RESERVA pra " " apos a gravação da SL1
		if lVldGESF 
			cCodProd := aAuxSL2[nConta][nPosProdut][2]			
			SB1-> ( DbSetOrder(1)) //B1_FILIAL+B1_COD                                                                                                                                             
			If SB1-> ( DbSeek(xFilial("SB1") + cCodProd) )					
				If  SB1->B1_TIPO == cTipoGE .OR. SB1->B1_TIPO == cTipoSF
					lVldGESF := .T.
				Else
					lVldGESF := .F.
				EndIf
			EndIf
		Endif
		
		//Atribui o Valor Unitario e o Valor Item calculados nos itens apos a proporcao
		If !lJob .OR. lIntegDef 
			// Caso L2_ENTREGA não for do tipo ENTREGA, preenche lSemFrete como True
			If aAuxSL2[nConta][nPosEntreg][2] $ "1|2|4|5"
				lSemFrete  := .T.
			EndIf
		EndIf

		//Release 11.5 - Chile - Guia de Despacho - F2CHI
		//Atualiza L1_DOC,L1_SERIE,L2_DOC e L2_SERIE do novo orcamento
		//que sera gerado.Estes dados atualizados indicam que sera gerada
		//a Factura para os itens de venda com entrega tipo 3 e que
		//os mesmos serao incluidos na Guia de Despacho pelo SIGAFAT
		If LjGtCFolLoc() .AND. lJob .AND. cPaisLoc == "CHI" .AND. cTpGeraGdp $ GDP_PARCIAL + ";" + GDP_TOTAL
			nPos1 := Ascan(aAuxSL2[nConta],{|x| Alltrim(Upper(x[1])) 	== "L2_ENTREGA"})
			If aAuxSL2[nConta][nPos1][2] <> "1"
				//SL2
				nPos2 := Ascan(aAuxSL2[nConta],{|x| Alltrim(Upper(x[1])) 	== "L2_DOC"})
			    aAuxSL2[nConta][nPos2][2] := cDocPai

			    nPos2 := Ascan(aAuxSL2[nConta],{|x| Alltrim(Upper(x[1])) 	== "L2_SERIE"})
			    aAuxSL2[nConta][nPos2][2] := cSeriePai

				//SL1
				nPos1 := aScan( aAuxSL1, {|x| Alltrim(Upper(x[1]))=="L1_DOC"} )
				aAuxSL1[nPos1][2] := cDocPai

				nPos1 := aScan( aAuxSL1, {|x| Alltrim(Upper(x[1]))=="L1_SERIE"} )
				aAuxSL1[nPos1][2] := cSeriePai
			Else
				//SL1
				nPos1 := aScan( aAuxSL1, {|x| Alltrim(Upper(x[1]))=="L1_DOC"} )
				aAuxSL1[nPos1][2] := ""

				nPos1 := aScan( aAuxSL1, {|x| Alltrim(Upper(x[1]))=="L1_SERIE"} )
				aAuxSL1[nPos1][2] := ""
			EndIf
		EndIf
		// Procura se tem itens de impressao que nao sejam garantia
		If SuperGetMv("MV_LJIMPGF",,.F.)
			cCodProd 	:= aAuxSL2[nConta][nPosProdut][2]
			cCodReserv 	:= aAuxSL2[nConta][nPosEntreg][2]

			If !(cCodReserv $ "3|4|5") .And. !(Posicione("SB1",1,xFilial("SB1")+cCodProd, "B1_TIPO") == SuperGetMV("MV_LJTPGAR",,"GE") ) //3=Entrega; 4=Retira Posterior c/ Nota; 5=Gera Pedido Sem Reserva
				lItemNormal := .T.
			EndIf
		Else
			lItemNormal := .T. //A venda possui itens de impressao fiscal
		EndIf
	Next nConta
	// Atualiza o L1_TPFRET para 'Sem Frete' caso o item não for do tipo ENTREGA
	If lSemFrete
		nPos1 = Ascan(aAuxSL1,{|x| Alltrim(Upper(x[1])) == "L1_TPFRET"})
		aAuxSL1[nPos1][2] := "S"	// Sem Frete
	EndIf
	//Ajustes para a tabela SL4	
	//- trecho importante para imprimir o TagCard na finalização de retira posterior em ambiente NFC-e
    LjGrvLog(Nil,"Ajuste das tabelas de SL4 para a Reserva")
    nI	:= 1
	SL4->(DbSetOrder(1)) //L4_FILIAL + L4_NUM + L4_ORIGEM
	SL4->(DbSeek(aLojas[1] + aLojas[2]))
    While !SL4->(Eof()) .And. (SL4->(L4_FILIAL+L4_NUM) == aLojas[1] + aLojas[2]) .And. Empty(AllTrim(SL4->L4_ORIGEM))
    	
        nPos := aScan( aAuxSL4[nI], {|x| Alltrim(Upper(x[1])) == "L4_FORMA" } )

	    If AllTrim(aAuxSL4[nI][nPos][2]) $ _FORMATEF
    		aAdd( aAuxSL4[nI], { "L4_VENDTEF"	, "S" } )
			aAdd( aAuxSL4[nI], { "L4_DATATEF"	, SL4->L4_DATATEF	} )
			aAdd( aAuxSL4[nI], { "L4_HORATEF"	, SL4->L4_HORATEF	} )
			aAdd( aAuxSL4[nI], { "L4_DOCTEF"	, SL4->L4_DOCTEF	} )
			aAdd( aAuxSL4[nI], { "L4_AUTORIZ"	, SL4->L4_AUTORIZ	} )
			aAdd( aAuxSL4[nI], { "L4_INSTITU"	, SL4->L4_INSTITU	} )
			aAdd( aAuxSL4[nI], { "L4_TIPCART"	, SL4->L4_TIPCART	} )

			//Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas
			aAdd( aAuxSL4[nI], {"L4_PARCTEF"	, SL4->L4_PARCTEF	} )
			aAdd( aAuxSL4[nI], { "L4_FORMAID"	, SL4->L4_FORMAID	} )

			//Codigo da Bandeira que foi utilizada
			aAdd( aAuxSL4[nI], { "L4_BANDEIR"	, SL4->L4_BANDEIR	} )

			//Codigo da Rede que foi utilizada
			aAdd( aAuxSL4[nI], { "L4_REDEAUT"	, SL4->L4_REDEAUT	} )
			aAdd( aAuxSL4[nI], { "L4_NOMECLI"	, SL4->L4_NOMECLI	} )
			aAdd( aAuxSL4[nI], { "L4_ADMINIS"	, SL4->L4_ADMINIS	} )
    	EndIf

        //Na integração, este campo pode ser utilizado por formas de pagamento que não tenham TEF, atualmente caso do MarketPlace e-Commerce
        If AllTrim(aAuxSL4[nI][nPos][2]) $ _FORMATEF .Or. lRegInteg
            aAdd( aAuxSL4[nI], { "L4_NSUTEF"	, SL4->L4_NSUTEF	} )
        EndIf

    	nPos := aScan( aAuxSL4[nI], {|x| Alltrim(Upper(x[1])) == "L4_OBS" } )
	    If nPos == 0
	    	aAdd( aAuxSL4[nI], { "L4_OBS", STR0013 + aRetCNF[2][1] + STR0014 + aRetCNF[2][2] } ) //"COO:"###" PDV:"
	    Else
	        aAuxSL4[nI][nPos][2] := STR0013 + aRetCNF[2][1] + STR0014 + aRetCNF[2][2] //"COO:"###" PDV:"
	    EndIf    	
    	
    	nI++
		SL4->(DbSkip())
    End
	LjGrvLog(Nil,"Fim dos ajuste das tabelas de SL4 para a Reserva")
	
	//Posiciona o orcamento no original
	SL1->( DbSeek( aLojas[1] + aLojas[2] ) )
	//Insere informação do TEF nos orçamentos filhos
	nPos1 := Ascan(aAuxSL1,{|x| Alltrim(Upper(x[1])) == "L1_VENDTEF"})
	If nPos1 == 0
		Aadd(aAuxSL1, {"L1_VENDTEF", SL1->L1_VENDTEF})
	Else
		aAuxSL1[nPos1][2] := SL1->L1_VENDTEF
	EndIf

	//Verifica se deve gerar um novo numero de Orcamento,
	//³ou se utiliza o numero gerado pela rotina de Reserva Off Line.
	If LjGetOffLN() //lAmbOff
		nPos := Ascan(aAuxSL1, {|x| AllTrim(x[01]) == "L1_NUM"})
		If nPos > 0
			lCriaOrc := Empty(aAuxSL1[nPos][02])
		Else
			lCriaOrc := .T.
		EndIf
	EndIf
	//Chama a funcao para gravar os arrays gerando SL1, SL2 e SL4
	If !LjGtBGtPaf() 
		LjGrvLog(Nil,"Filial SM0 - Antes da LJ7GrvOrc"		, SM0->M0_CODFIL)
		LjGrvLog(Nil,"Filial cFilAnt - Antes da LJ7GrvOrc"	, cFilAnt)
		aRet := LJ7GrvOrc( aAuxSL1, aAuxSL2, aAuxSL4, !lAutoExC, .T., aLojas[13], lJob )
		LjGrvLog(Nil,"Filial SM0 - Depois da LJ7GrvOrc"		,SM0->M0_CODFIL)
		LjGrvLog(Nil,"Filial cFilAnt - Depois da LJ7GrvOrc"	,cFilAnt)

		If lVldGESF
			Reclock( "SL1", .F. )
			SL1->L1_RESERVA	:= " "
			SL1->( MsUnlock() )		
		Else
			lVldGESF := .T.	
		EndIf
				
		If !lJob .AND. lGE .AND. !lItemNormal
			aRelGer := LjxGetRGer()
			aRelGar := LjxGetRGar()

			If Len(aRelGer) > 0 .AND. Len(aRelGer) == Len(aRelGar)
				For nCont :=1 To Len(aRelGer)
					cRetRelG := chr(16) + &cImpRGer.(	aRelGer[nCont][1]	,aRelGer[nCont][2]	,aRelGer[nCont][3]	,aRelGer[nCont][4]		,;
														aRelGar[nCont][1]	,aRelGar[nCont][2]	,aRelGar[nCont][3]	,SA1->A1_NOME,nMoedaCor	)
				Next nCont
			EndIf
			aRelGer := {}
			aRelGar := {}
			//Zera variaveis estaticas
			LjxSetRGer( aRelGer )
			LjxSetRGar( aRelGar )
		EndIf

		If lVendErro .AND. aRet[1]
			Reclock( "SL1", .F. )
			REPLACE SL1->L1_STATUS 	WITH "D"
			SL1->( MsUnlock() )
		EndIf
		
		//Validar se os itens do orcamento nao sao de lista de presente do tipo CREDITO, que nao devem gerar
		//PEDIDO DE VENDA e/ou DOC. DE SAIDA.
		//(Apenas para processos JOB)
		lItLstPresC := .F.
		If !Empty(aLojas[12])
			cTipoLista := GetAdvfVal("ME1","ME1_TIPO",xFilial("ME1") + SL2->L2_CODLPRE,2)
			//Verificar se o tipo da lista eh de credito
			If !Empty(cTipoLista) .And. AllTrim(AllToChar(cTipoLista)) == "1"				
				lItLstPresC := .T.
				//Se for lista do tipo credito é gravado alguns campos para que a legenda fique correta.
				Lj7GeraSL( "SL1",{	{"L1_DOCPED"	,cDocPed	},;
									{"L1_SERIE"		,cSeriePed	},;
									{"L1_RESERVA"	,"S"		}}, .F., .F. )
			Endif
			ConOut(STR0008 + cValToChar(lItLstPresC)) //"Lista de presente de credito - "
		Endif

		//Faz a gravação do Pedido de Venda.
		If !lItLstPresC
			If !Empty(SL2->L2_RESERVA)
				DbSelectArea("SC0")
				SC0->(dbSetOrder(1)) //"C0_FILIAL+C0_NUM+C0_PRODUTO+C0_LOCAL"
				If SC0->(DbSeek(aLojas[4]+SL2->L2_RESERVA))
				    cFilRES := SC0->C0_FILRES
		    		cFilLoc := SC0->C0_LOCAL
		   	    Endif
	        Endif

			If (aLojas[6] == "3" .Or. aLojas[6] == "4" .Or. aLojas[6] == "5" ) .AND. aRet[1] .AND. !(LjGtBGtPaf())	//3=Entrega; 4=Retira Posterior c/ Nota; 5=Gera Pedido sem Reserva

				//Tratamento VFE - Verifica se funcionalidade esta habilitada
	       		If lCentroDL
	       			//Inicializa Flags VFE
					lExistVfe := .F. //Verifica se cenario contempla VFE
			   		lValidVfe := .T. //PE para validar se executa VFE

	       			//Ponto de Entrada para verificar se gera VFE
				    If ExistBlock("LJ7096")
				    	lValidVfe := ExecBlock("LJ7096",.F., .F., {aArquivos, aLojas})

				    	//Tratamento para retorno do PE LJ7096
				    	If ValType(lValidVfe) <> "L"
				    		lValidVfe := .F.
				    	EndIf
				    EndIf

	       			If lValidVfe
		       			//Inicializa variaveis VFE
						cCliente  	:= SL1->L1_CLIENTE 	//Codigo do Cliente
						cLojaCli	:= SL1->L1_LOJA 	//Loja do Cliente
						cCliEnt   	:= SL2->L2_CLIENT	//Cliente de Entrega
						cLojEnt		:= SL2->L2_CLILOJA	//Loja do Cliente de Entrega
						//Se cliente de Entrega nao informado, assume cliente da venda
						If Empty(cCliEnt) .Or. Empty(cLojEnt)
							cCliEnt := cCliente
							cLojEnt := cLojaCli
						EndIf
						//Busca Estado do CD Matriz para verificar se VFE
						SLJ->(dbSetOrder(1)) //"LJ_FILIAL+LJ_CODIGO"
						SLJ->(dbSeek(xFilial("SLJ")))
						//Posiciona na Identificacao de Loja do CD Matriz
						While SLJ->(!Eof()) .And. SLJ->LJ_FILIAL == xFilial("SLJ")
							If AllTrim(SLJ->LJ_RPCEMP) == AllTrim(cEmpAnt) .And.;
								AllTrim(SLJ->LJ_RPCFIL) == AllTrim(aLojas[4]) .And. SLJ->LJ_TPCD == "0" //CD Matriz
								cUfCD := SLJ->LJ_ESTADO
								Exit
							EndIf
							SLJ->(dbSkip())
						EndDo

						SA1->(dbSetOrder(1)) //"A1_FILIAL+A1_COD+A1_LOJA"
						If SA1->(DbSeek(xFilial("SA1") + cCliEnt + cLojEnt))
							cUFCli := IIF(!Empty(SA1->A1_ESTE), SA1->A1_ESTE, SA1->A1_EST)

							//Se Estado do CD diferente do Estado do Cliente, entao Venda Fora do Estado
							If !Empty(cUfCD) .And. cUfCD <> cUFCli
								//Se a Loja da Venda Cenario 1, verifica se cliente tambem Cenario 1
								If lCen1VFE
									//Verifica cenario de venda VFE para o cliente
									lCen1VFE := LjAnalisaLeg(69, cUFCli)[1] .And. SuperGetMv("MV_LJC1VFE", Nil, .F.) //Especifico para Minas Gerais = Cenario 1 - Cliente
								EndIf

								SLJ->(dbSetOrder(3)) //"LJ_FILIAL+LJ_RPCEMP+LJ_RPCFIL"
								//Posiciona na Identificacao da Loja da Venda
								cCodCdLocal := "" //Inicializa Codigo de Identificacao do CD Local
								If SLJ->(dbSeek(xFilial("SLJ") + cEmpAnt + cFilAnt))
									cCodCdLocal := SLJ->LJ_CDLOCAL
								EndIf

								SLJ->(dbSetOrder(1))//"LJ_FILIAL+LJ_CODIGO"
								//Verifica se existe CD Local especifico para a Loja
								If !Empty(cCodCdLocal) .And. SLJ->(dbSeek(xFilial("SLJ") + cCodCdLocal)) .And. SLJ->LJ_ESTADO == cUFCli
									lExistVfe := .T. //Marca ocorrencia de VFE
									cCliente  := SLJ->LJ_CLIENTE
									cLojaCli  := SLJ->LJ_LOJCLI

								Else//Busca CD Local para as Lojas do Estado
									//Necessario para alterar o cliente apontando para o CD Loja
									SLJ->(dbSeek(xFilial("SLJ")))
									//Busca Identificacao de Loja do CD Local
									While SLJ->(!Eof()) .And. SLJ->LJ_FILIAL == xFilial("SLJ")
									   If SLJ->LJ_ESTADO == cUFCli .And. SLJ->LJ_TPCD == "1" //CD Local
											lExistVfe := .T. //Marca ocorrencia de VFE
											cCliente  := SLJ->LJ_CLIENTE
											cLojaCli  := SLJ->LJ_LOJCLI
											Exit
									   EndIf
									   SLJ->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
					EndIf
	         	EndIf
				aAdd(aPedidos,{	aClone(aAuxSL1), aClone(aAuxSL2)	, aLojas[13], aRet[2]	,;
								lJob				, lAlterOrc				, cFilLoc	, aLojas[4]	,;
								cCliente			, cLojaCli				, lExistVfe	, cNumPai	,;
								lAvCred				, lCen1VFE				, cFilRes	})
			EndIf
    	EndIf

		//Gera número de DAV para orçamento que possui item Retira Posterior
		//aLojas[6]: 1-Retira Posterior, 2-Retira, 3-Entrega
		If aLojas[6] == "1" .AND. aRet[1] .AND. !LjGtBGtPaf() .And. LjNfPafEcf(SM0->M0_CGC) 
			aSequencia	:= {}
			nTamOrc		:= TamSX3("LQ_NUMORC")[1]
		    If SuperGetMv("MV_LJPRVEN",,.T.)
		    	cSerOrc := SuperGetMv("MV_LJSERPRE",,"PRE")
		    Else
		    	cSerOrc := SuperGetMv("MV_LJSERDAV",,"DAV")
		    EndIf
	    	LjxDNota(	cSerOrc		, 1				, .T.	, 1		,;
	    			 	@aSequencia	, Space(nTamOrc), Nil	, 1		,;
	    			 	999			, .F.			, ""	, Nil	,;
	    			 	nTamOrc		, .T.			)
			If Len(aSequencia) > 0 .And. Reclock( "SL1", .F. )
				REPLACE SL1->L1_NUMORC	WITH aSequencia[1][2]
				REPLACE SL1->L1_SERIE	WITH ""
				SL1->( MsUnlock() )
			EndIf
		EndIf

		//Gera a ordem de serviço desse orçamento.
		If !lLJ7058 .And. lLjInTec .And. Lj7HasDtEM()
			Lj7CriaEntrMont(aLojas[5], cNumPai)
		EndIf

		If aRet[1]
			aSL2 := {}
			DbSelectArea("SL2")
			SL2->(DbSetOrder(1)) // filial + num + item + produto
			For nY := 1 to Len( aLojas[5] )
				If SL2->(DbSeek( xFilial("SL2") + cNumPai + aLojas[5][nY] ))
					aAdd( aSL2, { "L2_ORCRES", aRet[2] 		} )
					aAdd( aSL2, { "L2_FILRES", aLojas[4]	} )
					
					Lj7GeraSL( "SL2", aSL2 )
				EndIf
			Next nY

			//Ponto de controle para gerar arquivo de Log, para monitorar a impressao de cupons fiscais indevidos
			If ((aLojas[3] == cLojaLocal .AND. (aLojas[6] == "2" .OR. Empty(aLojas[6]))) .OR. ;
				(aLojas[3] == cLojaLocal .AND. If(SL2->(ColumnPos("L2_ENTREGA"))>0,(aLojas[6] == "3"),.T.) .AND. (SuperGetMV("MV_LJFINEN",,.F.))))  .AND. lItemNormal
				If !LjGtBGtPaf() .And. aLojas[1] == aLojas[4] 
	 				aAdd( aOrcRetira, aRet[2] )
	 			ElseIf LjGtBGtPaf()
					aAdd( aOrcRetira, cNumPai )
	 			EndIf
			ElseIf LjGtBGtPaf() .And. ((aLojas[6] == "2" .Or. Empty(aLojas[6])) .Or. aLojas[6] == "1")
		 			aAdd( aOrcRetira, cNumPai )
			EndIf
		Else
			lRet := .F.
			Exit
		EndIf
	Else
		aAdd( aOrcRetira, cNumPai )
	EndIf
Next nX

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} Lj7ImpPed
Função responsável imprimir o comprovante nao fiscal quando venda
com item entrega

@type		function
@author		felipe.martinez
@version	P12.1.14
@since		02/03/2017
@return 	aRetCNF:[1] - Impresso com sucesso
					[2,1] - Numero do Documento
					[2,2] - Numero do PDV  
/*/
//----------------------------------------------------------
Static Function Lj7ImpPed(	lTefOk	, lJob		, nFatorRes	, lImpCNFLoc	,;
							nOpc 	, cTxtNFis	)
Local aRetCNF		:= {.T., {"", ""}}					// Array com o retorno da funcao Lj7ImpCNF()
Local lAutoExC 		:= IsBlind()						// Verifica se a rotina sera executada via execauto ou nao
Local cImpFisc		:= LjGetStation( "LG_IMPFISC" )		// Retorna a impressora fiscal
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida


Default lTefOk		:= .F.
Default lJob		:= .F.
Default nFatorRes	:= 0
Default lImpCNFLoc	:= .F.
Default nOpc		:= 0

If LjGtCFolLoc()
	//Paises: Chile/Colombia - Controle de Formularios - F2CHI 
	//Imprime comprovante de venda para as localizacoes mesmo sem a obrigacao de ter uma impressora fiscal configurada.
	If !lJob .And. aRetCNF[1] 
		aRetCNF := Lj7ImpCNF( lTefOk, nFatorRes )
		If lImpCNFLoc .And. !LjProfile(28)
			If !Lj7ImpLoc (NIL,aRetCNF,nOpc,lImpCNFLoc)
				If !lAutoExC
					Aviso( STR0002, STR0003, {STR0004} ) //"Atenção"###"Houve erros na impressão do comprovante de venda. VerIfique a impressora."###"Ok"
				Else
					Conout( STR0002 + " - " +STR0003 ) //"Atenção"###"Houve erros na impressão do comprovante de venda. VerIfique a impressora."###"Ok"
				Endif
				aRetCNF := {.F., {"", ""}}  
			EndIf
		EndIf
	EndIf

ElseIf !lJob .And. aRetCNF[1] .And. !Empty( cImpFisc ) 
	//Faz a impressao do cupom nao fiscal (comprovante da venda) e se houver impressora configurada
	If !lAutoExC
		LjMsgRun( STR0009,, {|| (aRetCNF := Lj7ImpCNF( lTefOk, nFatorRes , NIL		, NIL ,;
		 											  	NIL  , NIL		 , NIL		, NIL ,;
		 											  	NIL  , NIL		 , NIL		, NIL ,;
		 											  	NIL  , NIL		 , @cTxtNFis )) } ) //"Aguarde ... imprimindo o comprovante de venda ...."
	Else
		aRetCNF := Lj7ImpCNF( lTefOk, nFatorRes )
	EndIf

ElseIf 	lFtvdVer12
	//Gerar Pedido de Venda -  Valido somente p/ modulo SIGAFAT
	If aRetCNF[1] .AND. !lJob .AND. nModulo == 5
		If Type("lAutoExec") <> "L" .OR. !lAutoExec
			LjMsgRun( STR0010,, {|| (aRetCNF := Lj7ImpCNF( lTefOk )) } ) //"Aguarde ... gerando pedido de venda ...."
		Else
			aRetCNF := Lj7ImpCNF( lTefOk )
		EndIf
	EndIf
EndIf

Return aClone(aRetCNF)

//----------------------------------------------------------
/*/{Protheus.doc} LJ7GrvReti
Função responsável por gravar orcamentos filhos Retira

@param		aPedidos = Array com os pedidos a serem gerados
@type		function
@author		rafael.pessoa
@version	P12.1.16
@since		08/03/2017
@return 	lRet = Gravou com sucesso
/*/
//----------------------------------------------------------
Static Function LJ7GrvReti( aOrcRetira 	, lJob 		 	, lEmiteNF    		,cNumPai   	,;
							aDadosCF	, nHandle 	 	, lTemTEFPend 		,nFatorRes 	,;
							nFatorVen   , lTefOk     	, lDscCupTef  		,lTefAbort 	,;
							nValRes     , aAreaL1Pai 	, aAreaL1Filhos  	,cTpGeraGdp ,;
							cEspDoc     , cDocFo     	, aArquivos   		,aDocReti	,; 
							lCartao     , lNSUDigitado	, cMsgErro )
							
							
Local lRet 			:= .T.
Local nX 			:= 0
Local lCalcIPI      := .T.		// Verifica se calcula valor de IPI
Local cTpFrete 		:= "" 		// Tipo do Frete
Local nDescOrc		:= 0 		// Desconto do Orcamento
Local nCont			:= 0		// Contador utilizado contagem do SL2
Local lErroNFCe		:= .F.		// Sinaliza erro ao transmitir a NFC-e
Local lAcresFin 	:= SL2->(ColumnPos("L2_VALACRS")) > 0
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg	:= Iif(lFtvdVer12,"FATA701","LOJA701")	//Nome da Rotina
Local lEmitNfce	:= LjEmitNFCe()		// Sinaliza se utiliza NFC-e

Default	aOrcRetira 	:= {}
Default	lJob		:= .F.
Default	lEmiteNF	:= .F.
Default	cNumPai		:= ""
Default	aDadosCF 	:= {}
Default	nHandle		:= -1
Default	lTemTEFPend	:= .F.
Default	nFatorRes	:= 1
Default	nFatorVen	:= 1
Default	lTefOk		:= .T. 
Default	lDscCupTef	:= .F.
Default	lTefAbort	:= .F. 
Default	nValRes		:= 0
Default	aAreaL1Pai 	:= {}
Default	aAreaL1Filhos := {} 
Default	cTpGeraGdp	:= GDP_NO 	
Default	cEspDoc		:= ""    
Default	cDocFo		:= ""     
Default	aArquivos 	:= {}
Default	aDocReti 	:= {}
Default lCartao		:= .F.
Default lNSUDigitado := .F.
Default cMsgErro 	:= ""

If Len( aOrcRetira ) > 0
	For nX := 1 to Len( aOrcRetira )
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
		If SL1->(DbSeek( xFilial("SL1") + aOrcRetira[nX] )) .And. IIf (lJob, !Empty( SL1->L1_DOC ), Empty( SL1->L1_DOC ) .And. IIF( !(LjGtBGtPaf()), Empty( SL1->L1_DOCPED ),.T.))
				If MaFisFound("NF")
					MaFisEnd()
				EndIf
				If !lJob
				   lCalcIPI    := Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALIPI"})	 > 0
				EndIf
				cTpFrete := Lj7TpFrete(SL1->L1_CLIENTE,SL1->L1_LOJA)
				cTpFrete	:= IIf( Empty(cTpFrete) .And. SL1->L1_TPFRET == "S" , "S", cTpFrete)

				MaFisIni( SL1->L1_CLIENTE	, SL1->L1_LOJA	, "C" 		, "S"		,;
				          Nil				, Nil			, Nil 		, .F.		,;
				          "SB1"				, cNomeProg		, Nil 		, Nil		,;
				          Nil				, Nil			, Nil 		, Nil 		,;
						  NIL			  	, NIL			, lEmiteNF	, lCalcIPI 	,;
						  NIL             	, NIL        	, NIL 		, NIL		,;
						  NIL             	, cTpFrete )

				LjSatMxFis()

				DbSelectArea( "SL2" )
				SL2->(DbSetOrder(1))
				SL2->(DbSeek( xFilial("SL1") + aOrcRetira[nX] ))

				//Inicializa a variavel que acumula o desconto
				nDescOrc := 0
				If lFtvdVer12
					nCont	 := 0
				EndIf
				
				nVlrAcrsFi := 0 // Zero o Valor do Acrescimo para somatoria ser adicionado por item

				While !SL2->(Eof()) .AND. xFilial("SL1") + aOrcRetira[nX] == SL2->L2_FILIAL + SL2->L2_NUM
					If lAcresFin 
						nVlrAcrsFi += SL2->L2_VALACRS
					EndIf
					
					If !lFtvdVer12
						If MaFisFound("NF")
							MaFisAdd( SL2->L2_PRODUTO	,;	// Produto
									  SL2->L2_TES   	,;	// Tes
									  SL2->L2_QUANT 	,;	// Quantidade
									  SL2->L2_PRCTAB	,;	// Preco unitario
									  SL2->L2_VALDESC	,;	// Valor do desconto
									  ""				,; 	// Numero da NF original
									  ""				,; 	// Serie da NF original
									   0				,;	// Recno da NF original
									   0				,; 	// Valor do frete do item
									   0				,; 	// Valor da despesa do item
									   0				,; 	// Valor do seguro do item
									   0				,;  // Valor do frete autonomo
									   SL2->L2_VALDESC	,;  // Valor da mercadoria
									   0 				)	// Valor da embalagem
							nDescOrc += SL2->L2_DESCPRO
						EndIf

						DbSelectArea( "SL2" )
						SL2->(DbSkip())

					ElseIf lFtvdVer12

						nCont	+= 1
						If MaFisFound("NF")
							SB1->(DbSetOrder(1))
							SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))

							SF4->(DbSetOrder(1))
							SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))

							MaFisIniLoad(nCont, ;
										{SL2->L2_PRODUTO,;	//IT_PRODUTO
										SL2->L2_TES,; 		//IT_TES
										Alltrim(MaSBCampo("CODISS")),; 	//IT_CODISS
										SL2->L2_QUANT,;		//IT_QUANT
										"",; 				//IT_NFORI
										"",; 				//IT_SERIORI
										SB1->(RecNo()),;	//IT_RECNOSB1
										SF4->(RecNo()),;	//IT_RECNOSF4
										0  }) 				//IT_RECORI

							MaFisLoad("IT_VALMERC"	,SL2->L2_VLRITEM,nCont)
							MaFisLoad("IT_PRCUNI"	,SL2->L2_PRCTAB	,nCont)
							MaFisLoad("IT_DESCONTO"	,SL2->L2_VALDESC,nCont)
							MaFisLoad("IT_FRETE"	,0,nCont)
							MaFisLoad("IT_SEGURO"	,0,nCont)
							MaFisLoad("IT_DESPESA"	,0,nCont)

							MaFisRecal("",nCont)

							MaFisEndLoad(nCont,2)
							nDescOrc += SL2->L2_DESCPRO
						EndIf
						DbSelectArea( "SL2" )
						SL2->(DbSkip())

					EndIf
				End

				If SL1->L1_TPFRET $ "FCTRD"  // CIF FOB
					MaFisAlt( "NF_FRETE"	, SL1->L1_FRETE )
					MaFisAlt( "NF_SEGURO"	, SL1->L1_SEGURO )
					MaFisAlt( "NF_DESPESA"	, SL1->L1_DESPESA )
				EndIf

			DbSelectArea( "SL1" )

			LjGrvLog(cNumPai,"VAI GRAVAR E TRANSMITIR O FILHO "+SL1->L1_NUM)

			If lJob
				lRet := LjGrvTudo( .F. ,NIL,NIL,NIL,;
                   					NIL,NIL,NIL,NIL,;
                   					NIL,NIL,NIL,NIL,;
                   					NIL,NIL,NIL,NIL,;
                   					NIL,NIL,NIL,.T. )
			Else
				lRet := LJ7GrvVenda( 	.F.										, !LjGtBGtPaf()	, aDadosCF	, nHandle	,;
										IIf(lFtvdVer12 .OR. lEmiteNF,.T.,Nil)	, NIL			, NIL		, @lTemTefPend,;
										NIL										, nDescOrc		, ""      	, lJob		,;
										nVlrAcrsFi								, NIL			, NIL     	, NIL		,;
										Nil 									, nFatorRes 	, nFatorVen , lTefOk	,;
										Nil 									, NIL			, NIL    	, NIL		,;
										@lDscCupTef								, Nil			, Nil		, Nil		,;
										@lErroNFCe								, lTefAbort		, Nil		, Nil		,;
										nValRes									, Nil			, Nil		, lCartao   ,;
										lNSUDigitado)

				If (lEmitNFCe .Or. LjGtPafNfce()) .AND. lErroNFCe
					lRet := .F.
				EndIf
			EndIf
			LjGrvLog(cNumPai,"RETORNO DO FILHO RETIRA "+SL1->L1_NUM, lRet)
			aDocReti := { SL1->L1_DOC , SL1->L1_SERIE , SL1->L1_PDV , SL1->L1_OPERADO , LJGetStation("LG_LOGTEF") }
		EndIf
	Next nX
Else
	
	//Gera SE5 para o troco pela função AtuaTroco (LOCXFUN) quando
	//venda com apenas Itens-Pedido ou apenas Itens-Retira Posterior
	If	cPaisLoc == "BRA" .AND.;
		( SuperGetMV( "MV_LJTROCO", ,.F. ) .And. SuperGetMv("MV_LJTRDIN",,0) == 0 ) .AND.;
		SL1->L1_TROCO1 > 0
		RestArea(aAreaL1Pai)
		If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
			lRet :=  LjTrocoInc(SL1->L1_TROCO1	, 1 			 , 2    		, dDatabase		 ,;
								SL1->L1_OPERADO	, Nil			 , Nil			, SE1->E1_PREFIXO,;
								SE1->E1_NUM		, SE1->E1_PARCELA, @cMsgErro	, Nil )
		Else
			AtuaTroco( 	SL1->L1_TROCO1	, 1				, 2					, SL1->L1_CLIENTE, ;
						SL1->L1_LOJA	, /*aTitulo*/	, SL1->L1_OPERADO )
		EndIf
		RestArea(aAreaL1Filhos)
	EndIf
	
EndIf
	    
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} Lj7AtuNum
Função responsável por atualizar Numeracao nos orcamentos Pai e Filhos 

@type		function
@author		rafael.pessoa
@version	P12.1.16
@since		02/03/2017
@return 	Nil
/*/
//----------------------------------------------------------
Static Function Lj7AtuNum(	lJob 		, aRetCNF , cDocPed , cSeriePed ,;
							aOrcRetira	, aPedidos	)

Local nX			:= 0
Local aSL1			:= {}
Local lECommerce	:= SuperGetMV("MV_LJECOMM",,.F.) .And. SL1->L1_ECFLAG == "1" // Tratamento para eCommerce

Default lJob		:= .F.
Default aRetCNF		:= {.F., {"", ""}}
Default cDocPed		:= ""
Default cSeriePed	:= ""
Default aOrcRetira	:= {}
Default aPedidos	:= {}

cDocPed := aRetCNF[2][1]

aAdd( aSL1, {"L1_DOCPED"	, cDocPed } )					// Numero do cupom nao fiscal (pedido)


// Numero do serie do cupom nao fiscal (pedido)
If  lECommerce
	cSeriePed :=   SL1->L1_SERPED  //Ja gravado anteriormente
ElseIf LjGtCFolLoc() .AND. !Empty(SuperGetMV("MV_LOJAPED"))
	// Chile/Colombia - Controle de Formularios obtem numero serie do MV_LOJAPED	
	cSeriePed := If(Len(aRetCNF[2])==3 .AND. !Empty(aRetCNF[2]),aRetCNF[2][3],SuperGetMV("MV_LOJAPED"))
ElseIf !lJob
    cSeriePed := If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE")) 
EndIf

If !Empty(cSeriePed)
	aAdd( aSL1, {"L1_SERPED",  cSeriePed } )
EndIf	  

If Len(aSL1) > 0
	Lj7GeraSL( "SL1", aSL1, .F., .F. )
EndIf	

//Atualiza Orcamentos Retira
For nX := 1 to Len( aOrcRetira )

	DbSelectArea("SL4")
	SL4->(DbSetOrder(1)) //"L4_FILIAL+L4_NUM+L4_ORIGEM"
	If SL4->(DbSeek( xFilial("SL4") + aOrcRetira[nX] ))
		While !SL4->(Eof()) .AND. (SL4->L4_FILIAL + SL4->L4_NUM ) == (xFilial("SL4") + aOrcRetira[nX] )
	
			RecLock("SL4",.F.)
			SL4->L4_OBS := STR0013 + cDocPed + STR0014 + cSeriePed //"COO:"###" PDV:"
			SL4->(MSUNLOCK())
		   	SL4->(DbSkip())
	
		End
	EndIf

Next nX

//Atualiza Pedidos
For nX := 1 to Len( aPedidos )

	DbSelectArea("SL4")
	SL4->(DbSetOrder(1)) //"L4_FILIAL+L4_NUM+L4_ORIGEM"
	If SL4->(DbSeek( xFilial("SL4") + aPedidos[nX][4] ))
		While !SL4->(Eof()) .AND. (SL4->L4_FILIAL + SL4->L4_NUM ) == (xFilial("SL4") + aPedidos[nX][4] )

			RecLock("SL4",.F.)
			SL4->L4_OBS := STR0013 + cDocPed + STR0014 + cSeriePed //"COO:"###" PDV:"
			SL4->(MSUNLOCK())
		   	SL4->(DbSkip())
	
		End
	EndIf

Next nX

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj701ImpTr()
Rotina analizadora do erro
@author  Varejo
@param	 ExpN1 - Handle do arquivo
		 ExpL1 - TEF Pendente?
@version P12.1.17
@since   22/09/2006
@return  
/*/
//--------------------------------------------------------
Static Function Lj701ImpTr (nHandle,lTemTEFPend)
Local lLog1       	:= SubStr(LJGetProfile("LOGERRO"),1,1) == "S" 				// Tem Log de Erro
Local lLog4         := SubStr(LJGetProfile("LOGERRO"),4,1) == "S" 				// Log de Recuperacao, grava as parcelas
Local nSize         := 0														// Tamanho do arquivo de LOG de recuperacao
Local cRBuffer      := ""														// Buffer com conteudo da linha do log txt
Local lImpTefok		:= .F.														// Variavel para transacao TEF
Local lTefCanc		:= .F.														// Variavel para transacao TEF

If cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF
	If lLog1 .AND. lLog4 .AND. nHandle >= 0
		nSize 		:= FSeek( nHandle, 0, 2 )
		cRBuffer 	:= Space( nSize )

		FSeek( nHandle, 0, 0 )
		FRead( nHandle, @cRBuffer, nSize )

		cRBuffer := Encript( cRBuffer, 1 )
		If !("#TEF#" $ cRBuffer)
			cRBuffer := cRBuffer + "#TEF#"
		EndIf

		FSeek( nHandle, 0, 0 )
		FWrite( nHandle, Encript( cRBuffer, 0 ) )
	EndIf


	If cTipTEF == TEF_CLISITEF
		oTEF:ImpCupTef()
		If oTef:lImprimiu
			lImpTefok := .T.
			lTemTEFPend := .F.
		EndIf
	Else
		If LOJA010T( "I", "V" )
			LJ701AtCartao()
			lImpTefok := .T.
		EndIf
	EndIf

	If lImpTefok

		If lLog1 .AND. lLog4 .AND. nHandle >= 0
			nSize 		:= FSeek( nHandle, 0, 2 )
			cRBuffer 	:= Space( nSize )

			FSeek( nHandle, 0, 0 )
			FRead( nHandle, @cRBuffer, nSize )

			cRBuffer := Encript( cRBuffer, 1 )
			If !("#TEFOK#" $ cRBuffer)
				cRBuffer := cRBuffer + "#TEFOK#"
			EndIf

			FSeek( nHandle, 0, 0 )
			FWrite( nHandle, Encript( cRBuffer, 0 ) )
		EndIf
	EndIf

Else
	If cTipTEF == TEF_CLISITEF
		oTEF:FinalTrn(0) //Finaliza a TRN com parametro confirma = 1
		MsgInfo(STR0011) //"Transação TEF não efetuada, favor reter o cupom!"
	Else
		lTefCanc := LOJA010T( "F", "N" )
		If lTefCanc
			MsgInfo(STR0011) //"Transação TEF não efetuada, favor reter o cupom!"
		EndIf
	EndIf
EndIf
Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj7GeraOrc()
Monta os arrays para a gravacao do orcamento
@author  Varejo
@param	         
@version P12.1.17
@since   24/09/2002
@return  aRet
/*/
//--------------------------------------------------------
Function Lj7GeraOrc( aItens		, lJob		, aAuxaPgtos	, cEntrega	,;
					 lAlterOrc	, nFatorVen	, nFatorRes		, lLastOrc	,;
					 nCredito	, aSL4Total	)

Local aArea			:= Lj7GetArea({"SL1","SL2","SL4"})			// GetArea
Local aRet 			:= {}										// Array com retorno
Local aSL1			:= {}										// Campos SL1
Local aSL2			:= {}										// Campos SL2
Local aSL4			:= {}										// Campos SL4
Local aSL4Aux		:= {}										// Auxiliar para o array aSL4
Local nX 			:= 0										// Contador de For
Local nY			:= 0										// Contador de For
Local nVlrFSD		:= 0										// Valor
Local nVlrTotSl4	:= 0										// Valor total do SL4
Local nVlrOrcam 	:= 0 										// Valor do orcamento
Local nValMerc		:= 0										// Valor da Mercadoria
Local nValorTotal	:= 0										// Valor total
Local nVlrBrIcms	:= 0										// Valor ICM
Local nVlrIcmsRet	:= 0										// Valor retencao
Local nVlrTIcmsRet	:= 0										// Valor total retencao
Local nVlrIcms		:= 0										// ICMS
Local nVlrIpi		:= 0										// Valor IPI
Local nVlrIss		:= 0										// Valor ISS
Local nVlrDescPro	:= 0										// Valor produto
Local lGravaImps	:= .F.										// Grava imposto
Local nTamNumOrc	:= TamSx3("L1_NUM")[1]
Local nTamLojRes	:= TamSx3("L2_LOJARES")[1]
Local cNumDoc	    := Space(TamSx3("L1_DOC")[1])				// L1_DOC
Local cNum 		    := Space(nTamNumOrc)						// L1_NUM
Local cStatus	    := Space(TamSx3("L1_STATUS")[1])			// L1_STATUS
Local cL2_TRANSP	:= ""
Local nAuxRotina	:= 0										// Rotina
Local nAuxNcc		:= 0										// NCC
Local nDecsAux		:= 2										// Numero de casas decimais
Local cMvSimb1		:= SuperGetMv("MV_SIMB1")					// Simbolo da moeda principal
Local nVlrFre		:= 0
Local nVlrSeg		:= 0
Local nVlrDes		:= 0
Local nVlrTotDes	:= 0         								// Valor total do desconto
Local aTesImpInf	:= {} 										// Dados da TES
Local nImp			:= 0                                        // Contador
Local lECommerce	:= SuperGetMV("MV_LJECOMM",,.F.) .And. (SL1->L1_ECFLAG == "1")
Local aIcmJr		:= {}
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)				    // Verifica as filiais da trabalharam com acrescimento separado
Local nPropItem		:= 0										// Variavel que leva o fator da proporção do valor do item no total da venda.
Local nTotal		:= SL1->L1_VLRTOT + SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA	// Total da Venda
Local nPosSL4		:= 0										// Posicao Forma de Pagamento
Local nTotOrc		:= 0										// Total do Orçamento/Venda a ser rateado
Local nTotSL4		:= 0										// Total dos Pagamentos
Local nDifSL4		:= 0										// Diferença entre Orçamento/Venda e pagamentos
Local nNccProp		:= 0    									// Valor da NCC proporcional ao valor do orçamento filho
Local nL1_TRANSP	:= 0

//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lEmitNfce		:= LjEmitNFCe()								// Sinaliza se utiliza NFC-e
Local aAreaSL1 		:= {} 										// variável para armazenar a área original da SL1
Local nVlrTroco		:= 0										// Valor do troco
Local lL1VLRPGDG 	:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 		//Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital
Local lL1VLRPGPX 	:= SL1->(ColumnPos("L1_VLRPGPX")) > 0 		//Verifica se existe o campo onde é gravado o valor da venda paga em PIX
Local lL2_TRANSP	:= SL2->(ColumnPos("L2_TRANSP")) > 0
Local lIntegDef		:= .F.
Local nDescFid      := 0

Default lJob			:= .F.
Default aAuxaPgtos  	:= {}
Default cEntrega  		:= ""									// 1=Retira Posterior / <branco> ou 2=Retira / 3=Entrega
Default lAlterOrc   	:= .F.
Default nFatorVen		:=	1 									// Fator reserva
Default nFatorRes		:=	1 									// Fator reserva
Default lLastOrc		:= .F.									// Flag ultimo Orcamento
Default nCredito		:= 0									// Totalizador Credito
Default aSL4Total		:= {}									// Totalizador Pagamentos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo L2_ENTREGA vazio é item de Retira ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cEntrega)
	cEntrega := "2"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o array aSL1                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAreaSL1 := SL1->(GetArea()) //solução de contorno para resolver o problema do cliente até que o Frame tenha uma solução definitiva.

If SELECT("SL1") > 0
	SL1->(DbCloseArea())
EndIf
DbSelectArea("SL1")
RestArea(aAreaSL1)

For nX := 1 to FCount()
	aAdd( aSL1, { Trim(FieldName(nX)), FieldGet(nX) } )
Next nX

aSL1[aScan(aSL1,{|x|x[1]=="L1_FILRES" })][2]	:= cFilAnt
aSL1[aScan(aSL1,{|x|x[1]=="L1_ORCRES" })][2]	:= SL1->L1_NUM
aSL1[aScan(aSL1,{|x|x[1]=="L1_NUM"    })][2]	:= cNum
aSL1[aScan(aSL1,{|x|x[1]=="L1_DINHEIR"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_CHEQUES"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_CARTAO" })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRDEBI"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_CONVENI"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_VALES"  })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_FINANC" })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_OUTROS" })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_ENTRADA"})][2]	:= 0

If lL1VLRPGDG
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRPGDG"})][2]	:= 0
EndIf
If lL1VLRPGPX
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRPGPX"})][2]	:= 0
EndIf

aSL1[aScan(aSL1,{|x|x[1]=="L1_DOCPED" })][2]	:= cNumDoc
aSL1[aScan(aSL1,{|x|x[1]=="L1_STATUS" })][2]	:= cStatus

If cEntrega <> "2"
	aSL1[aScan(aSL1,{|x|x[1]== "L1_DOC"		})][2]	:= cNumDoc
	If lEmitNFCe .Or. LjGtPafNfce()
		/* Limpamos o L1_SITUA, pois orcamentos filhos nao podem ser "T1" (gravacao do orcamento),
		pois eles somente sao gerados se a venda for finalizada com sucesso */
		aSL1[aScan(aSL1,{|x|x[1] == "L1_SITUA"})][2] := ""
		IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit("","(em branco)"), NIL)
	EndIf
ElseIf cEntrega == "2"	
	aSL1[aScan(aSL1,{|x|x[1]=="L1_TROCO1" })][2]	:= SL1->L1_TROCO1
	nVlrTroco :=  SL1->L1_TROCO1
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando carrega os dados para aSl1 os campos estao preenchidos             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAlterOrc
	aSL1[aScan(aSL1,{|x|x[1]=="L1_PDV" })][2]	:= ""
	aSL1[aScan(aSL1,{|x|x[1]=="L1_OPERADO" })][2]	:= ""
EndIf

lIntegDef := SL1->L1_ORIGEM == "N"
nL1_TRANSP := aScan(aSL1,{|x|x[1]=="L1_TRANSP"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o SL2 para gerar o array aSL2                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL2")
SL2->(DbSetOrder(1))
For nX := 1 to Len( aItens )
	If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+aItens[nX]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SF4                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o tratamento dos campos do SL2                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aSL2, {} )
		For nY := 1 to FCount()
			aAdd( aSL2[Len(aSL2)], { FieldName(nY), FieldGet(nY) } )
		Next nY

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula as variaveis para a gravacao do SL1                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nVlrOrcam	+= SL2->L2_VALIPI
        nVlrBrIcms 	+= SL2->L2_BRICMS
		nVlrIcmsRet	+= SL2->L2_ICMSRET
		nVlrIss		+= SL2->L2_VALISS
		nVlrIpi		+= SL2->L2_VALIPI
		nVlrIcms	+= SL2->L2_VALICM
		
        //VerIfica se agrega solidario. (Se o valor do imposto incide ou nao no total da venda)
		If SF4->F4_INCSOL <> "N"
            nVlrTIcmsRet += SL2->L2_ICMSRET
            nVlrOrcam    += SL2->L2_VLRITEM + SL2->L2_ICMSRET
        Else
			nVlrOrcam 	 += SL2->L2_VLRITEM            
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Localizacoes - F2CHI                   ³
		//³Somar o total de impostos quando for executado via Job³
		//³Paises: Chile / Colombia                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc$"CHI|COL" .AND. lJob
			nTotImpIt	:= 0
			aTesImpInf  := TesImpInf(SL2->L2_TES)
		   	For nImp := 1 to Len(aTesImpInf)
		    	If aTesImpInf[nX][3] == "1"  //Incide na NF
		     		nTotImpIt  += SL2->(FieldGet(ColumnPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))
		      	EndIf
		   	Next nX
			nVlrOrcam 	+= nTotImpIt
		EndIf

		nValorTotal	+= SL2->L2_VLRITEM
		nValMerc	+= SL2->L2_PRCTAB * SL2->L2_QUANT
		nVlrDescPro	+= SL2->L2_DESCPRO
		nVlrFre		+= SL2->L2_VALFRE
		nVlrSeg		+= SL2->L2_SEGURO
		nVlrDes		+= SL2->L2_DESPESA

		//Vincula o item do pedido filho ao item do PAI
		aSL2[nX][aScan(aSL2[nX],{|x|x[1]=="L2_ITESC6"})][2]   := SL2->L2_ITEM

		//Na integração, a transportadora deve ser a mesma em todos os itens, portanto pego somente 1 vez
		If lIntegDef .And. lL2_TRANSP .And. Empty(cL2_TRANSP)
			cL2_TRANSP := AllTrim(SL2->L2_TRANSP)
		EndIf
    EndIf
Next nX

LjGrvLog(SL1->L1_NUM,"LOGFRET - Total Frete+Seguro+Despesa",nVlrFre+nVlrSeg+nVlrDes)

If !lJob
	nVlrTotDes := nVlrDescPro
ElseIf  lECommerce
	nVlrDescPro := SL1->L1_DESCONT
	nVlrOrcam -= nVlrDescPro
EndIf

IF SuperGetMv("MV_LJTDESI", , 0) == 1 //Parametro para controlar o tipo de desconto na integração 0 = desligado padrao, 1 = desconto no valor bruto IPI(cabeçalho) 
    nVlrDescPro := SL1->L1_DESCONT
EndIf

// Alterando os valores especIficos para a loja destino
nVlrFSD := IIf (!LjGtBGtPaf()  .Or. lECommerce, nVlrFre + nVlrSeg + nVlrDes, SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA)

aSL1[aScan(aSL1,{|x|x[1]=="L1_FILRES" })][2]	:= cFilAnt
aSL1[aScan(aSL1,{|x|x[1]=="L1_ORCRES" })][2]	:= SL1->L1_NUM
aSL1[aScan(aSL1,{|x|x[1]=="L1_NUM"    })][2]	:= Space(nTamNumOrc)
aSL1[aScan(aSL1,{|x|x[1]=="L1_DINHEIR"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_CHEQUES"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_CARTAO" })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRDEBI"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_CONVENI"})][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_VALES"  })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_FINANC" })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_OUTROS" })][2]	:= 0
aSL1[aScan(aSL1,{|x|x[1]=="L1_ENTRADA"})][2]	:= 0

If lL1VLRPGDG
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRPGDG"})][2]	:= 0
EndIf
If lL1VLRPGPX
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRPGPX"})][2]	:= 0
EndIf

aSL1[aScan(aSL1,{|x|x[1]=="L1_DESCONT"})][2]	:= nVlrDescPro
aSL1[aScan(aSL1,{|x|x[1]=="L1_FRETE" })][2]		:= nVlrFre
aSL1[aScan(aSL1,{|x|x[1]=="L1_SEGURO"})][2]		:= nVlrSeg
aSL1[aScan(aSL1,{|x|x[1]=="L1_DESPESA"})][2]	:= nVlrDes
		
If lJob
	nFatorVen := nVlrOrcam / SL1->L1_VLRLIQ
	nFatorRes := nVlrOrcam / SL1->L1_VLRLIQ

	nAuxRotina 	:= 3
	nDecsAux   	:= MsDecimais(1)
	aPgtos     	:= aClone(aAuxaPgtos)
	If !Empty(SL2->L2_ENTREGA) .And. AllTrim(SL2->L2_ENTREGA) $ "1|3"
		nAuxNcc	   := 	Round((SL1->L1_CREDITO * nFatorRes), nDecsAux )
	Else
		nAuxNcc	   := 	Round((SL1->L1_CREDITO * nFatorVen), nDecsAux )
	EndIf
	aSL1[aScan(aSL1,{|x|x[1]=="L1_CREDITO"})][2] := nAuxNcc
Else
	nAuxRotina	:= nRotina
	nAuxNcc		:= nNccUsada
	nDecsAux	:= nDecimais
EndIf

//Incrementa totalizador de credito para conferencia
nCredito += nAuxNcc

//Verifica se necessario arredondar Credito
If cPaisLoc == "BRA" .And. lJob .And. lLastOrc
	If SL1->L1_CREDITO > nCredito
		aSL1[aScan(aSL1,{|x|x[1]=="L1_CREDITO"})][2]	+= (SL1->L1_CREDITO - nCredito)
	ElseIf nCredito > SL1->L1_CREDITO
		aSL1[aScan(aSL1,{|x|x[1]=="L1_CREDITO"})][2]	-= (nCredito - SL1->L1_CREDITO)
	EndIf
EndIf

If cPaisLoc <> "BRA" .AND. !(nAuxRotina == 4 .AND. !Empty(SL1->L1_ORCRES)) .And. MaFisFound("NF") 
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRTOT" })][2]	:=	If(!lJob,( MaFisRet(,"NF_TOTAL") - Lj7T_DescV(2) - nVlrFSD) ,SL1->L1_VLRTOT)
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VALBRUT"})][2]	:=	If(!lJob,( MaFisRet(,"NF_TOTAL") - Lj7T_DescV(2) - nVlrFSD ),SL1->L1_VALBRUT)
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRLIQ" })][2]	:=  If(!lJob,nValorTotal + nVlrFSD - nVlrTotDes + nVlrTIcmsRet,SL1->L1_VLRLIQ)
	lGravaImps := .T.
EndIf

If cPaisLoc = "BRA"
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRTOT" })][2]	:= nValorTotal + nVlrTIcmsRet + nVlrIpi
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRLIQ" })][2]	:= nValorTotal + nVlrFSD + nVlrTIcmsRet + nVlrIpi
	aSL1[aScan(aSL1,{|x|x[1]=="L1_VALBRUT"})][2]	:= nValorTotal + nVlrFSD + nVlrTIcmsRet + nVlrIpi
Endif

//Proporcionaliza o valor de desconto da fidelização este desconto já esta composto no campo L1_DESCONT
If ExistFunc("LjxRaasInt") .And. LjxRaasInt() .And. SL1->L1_FIDCORE

    //Tratamento para quando só existir o desconto de fidelização no L1_DESCONT
    If SL1->L1_DESCONT == SL1->L1_DESCFID
        nDescFid := aSL1[aScan(aSL1,{|x|x[1]=="L1_DESCONT"})][2]
    Else
        nDescFid := aSL1[aScan(aSL1,{|x|x[1]=="L1_VLRTOT"})][2] * 100 
        nDescFid := nDescFid / SL1->L1_VLRTOT
        nDescFid := SL1->L1_DESCFID * ( nDescFid / 100)
    EndIf

    aSL1[aScan(aSL1,{|x|x[1]=="L1_DESCFID"})][2] := nDescFid
EndIf

aSL1[aScan(aSL1,{|x|x[1]=="L1_VALMERC"})][2]	:= nValMerc
aSL1[aScan(aSL1,{|x|x[1]=="L1_VALICM" })][2]	:= nVlrIcms
aSL1[aScan(aSL1,{|x|x[1]=="L1_VALIPI" })][2]	:= nVlrIpi
aSL1[aScan(aSL1,{|x|x[1]=="L1_VALISS" })][2] 	:= nVlrIss
aSL1[aScan(aSL1,{|x|x[1]=="L1_BRICMS" })][2] 	:= nVlrBrIcms
aSL1[aScan(aSL1,{|x|x[1]=="L1_ICMSRET"})][2] 	:= nVlrIcmsRet

If !Empty(cL2_TRANSP) .And. (nL1_TRANSP > 0) //Insere o Código da Transportadora
	aSL1[nL1_TRANSP][2] := cL2_TRANSP
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alterando os valores especIficos para a loja destino                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( aSL2 )
	aSL2[nX][aScan(aSL2[nX],{|x|x[1]=="L2_NUM"})][2]    := Space(nTamNumOrc)
	aSL2[nX][aScan(aSL2[nX],{|x|x[1]=="L2_ITEM"})][2]   := FR271BPegaIT(nX)
	aSL2[nX][aScan(aSL2[nX],{|x|x[1]=="L2_LOJARES"})][2]:= Space(nTamLojRes)
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aSL4  /  Faz o rateio dos valores das parcelas             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL4")
SL4->(DbSetOrder(1))
SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
While !SL4->(Eof()) .AND. SL4->L4_FILIAL+SL4->L4_NUM  == xFilial("SL4")+SL1->L1_NUM .AND. Empty(SL4->L4_ORIGEM)
	Aadd(aSL4Aux , Array(6) )
	nX	:= Len(aSL4Aux)
	aSL4Aux[nX][1] := SL4->L4_DATA
	aSL4Aux[nX][2] := SL4->L4_VALOR
	aSL4Aux[nX][3] := SL4->L4_FORMA
	aSL4Aux[nX][4] := 0 
	aSL4Aux[nX][5] := 0

	If cPaisLoc == "BRA"
		aSL4Aux[nX][6] := NIL
		
		//Armazena array totalizador
		If lJob
			If aScan(aSL4Total, {|x| x[1] == SL4->L4_FORMA}) == 0
				aAdd(aSL4Total, {SL4->L4_FORMA, SL4->L4_VALOR, 0})
			EndIf
		EndIf
	Else
		aSL4Aux[nX][6] := SL4->L4_MOEDA
	EndIf

	//Grava o valor do acrescimo separado da parcela
	If (lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA"))
		aAdd(aIcmJr ,{ "L4_ACRSFIN", SL4->L4_ACRSFIN})
	Endif

	nVlrTotSl4 += SL4->L4_VALOR
	SL4->(DbSkip())
End

// Adiciona o valor do frete para a correta impressao do cupom fiscal quando for venda com Retira e Reserva e não for PDVPAF
nVlrOrcam += IIf ((!LjGtBGtPaf() .AND. !lJob)  .Or. lECommerce, nVlrFSD,0)

// Adiciona o valor do frete para a correta impressao do cupom fiscal quando for venda com Retira e Reserva vindo do Front
If lJob .And. (SL2->L2_ENTREGA $ "1|3")
	nVlrOrcam += (nVlrFre + nVlrSeg + nVlrDes)
EndIf

//Variavel que leva o fator da proporção do valor do item no total da venda.
nPropItem := (SL2->L2_VLRITEM + SL2->(L2_VALFRE+L2_SEGURO+L2_DESPESA)/SL1->L1_VLRTOT)

//Calcula o Total da Venda para calcular arredontamento
If !lJob
	If !lGravaImps
		nTotOrc := nVlrOrcam  //Total do Orçamento/Venda a ser rateado
	Else
		nTotOrc := MaFisRet(,"NF_TOTAL")
	EndIf
	
	nNccProp := Round( (nAuxNcc / nTotal) * nVlrOrcam , nDecsAux )
EndIf

// Proporcionaliza os valores
For nX := 1 to Len(aSL4Aux)
	If !lJob
		aSL4Aux[nX][4] := NoRound( aSL4Aux[nX][2] / nTotal, 18 ) // FATOR DA FORMA DE PAGAMENTO
		If !lGravaImps
			aSL4Aux[nX][5] := Round( nVlrOrcam * aSL4Aux[nX][4], nDecsAux )
		Else
			aSL4Aux[nX][5] := NoRound( MaFisRet(,"NF_TOTAL") * aSL4Aux[nX][4], nDecsAux )
		EndIf
		nTotSL4 += aSL4Aux[nX][5]//Sumariza o Total dos Pagamentos
	Else
		// Caso venha do Front
		If !lGravaImps
			//Recalcula Fatores do Orcamento novamente
			nFatorVen := nVlrOrcam / SL1->L1_VLRLIQ 
			nFatorRes := nVlrOrcam / SL1->L1_VLRLIQ 

			If !Empty(SL2->L2_ENTREGA) .And. AllTrim(SL2->L2_ENTREGA) $ "1|3"
				aSL4Aux[nX][5] := Round( aSL4Aux[nX][2] * nFatorRes, nDecsAux )
			Else
				aSL4Aux[nX][5] := Round( aSL4Aux[nX][2] * nFatorVen, nDecsAux )
			EndIf

			//Incrementa totalizador
			If cPaisLoc == "BRA" .And. lJob
				nPosSL4 := aScan(aSL4Total,{|x| x[1] == aSL4Aux[nX][3]})

				If nPosSL4 > 0
					aSL4Total[nPosSL4][3] += Round( aSL4Aux[nX][2] * nFatorRes, nDecsAux )
				EndIf
			EndIf
		Else
			aSL4Aux[nX][5] := NoRound( MaFisRet(,"NF_TOTAL") * aSL4Aux[nX][4], nDecsAux )
		EndIf
	EndIf
Next nX

If nTotOrc > nNccProp  // Caso a NCC seja maior que a venda não deve haver calculo de diferenca
	//Verifica se eh necessario fazer arredondamento
	If cPaisLoc == "BRA" .And. lJob .And. lLastOrc
		For nX := 1 To Len(aSL4Total)
			If aSL4Total[nX][2] > aSL4Total[nX][3]
				aSL4Aux[nX][5] += aSL4Total[nX][2] - aSL4Total[nX][3]
			ElseIf aSL4Total[nX][3] > aSL4Total[nX][2]
				If aSL4Aux[nX][5] > ( aSL4Total[nX][3] - aSL4Total[nX][2] ) //Tratamento para não gerar valor negativo
					aSL4Aux[nX][5] -= aSL4Total[nX][3] - aSL4Total[nX][2]
				EndIf
			EndIf
		Next nX
	ElseIf !lJob .AND. ABS( nTotOrc - (nTotSL4 + nNccProp) ) >= (1/(10**nDecsAux)) //Arredondamento para Venda Assistida
		nX := Len(aSL4Aux)
		nDifSL4 := nTotOrc - nTotSL4 - nNccProp
		//Verifica uma parcela válida para lançar diferença se for desconto
		If  nDifSL4 < 0
			Do While nX >= 1
					nDifSL4 := nTotOrc - nTotSL4 - nNccProp
					If !lGravaImps .and. aSL4Aux[nX][5] > Abs( Round(nDifSL4, nDecsAux  ))
						Exit
					ElseIf aSL4Aux[nX][5] > Abs( NoRound( nDifSL4, nDecsAux ) )
						Exit
					EndIf
				nX--
			EndDo
		EndIf

		If nX < 1  //Caso não atenda nenhuma das condiçoes acima jogo a diferenca na ultima parcela.
			nX := Len(aSL4Aux) 
		EndIf

		If !lGravaImps
			aSL4Aux[nX][5] += Round( nDifSL4, nDecsAux ) + nVlrTroco
		Else
			aSL4Aux[nX][5] += NoRound( nDifSL4, nDecsAux ) + nVlrTroco
		EndIf
	EndIf	
EndIf 

If nTotOrc  < nNccProp  // Caso a NCC seja maior que os valor dos itens O Valor a ser gravado devera ser o valor dos itens para nao gerar erro no NFCE
	nNccProp := nTotOrc 
EndIf

// Grava os valores do aSL4
If Len(aSL4Aux) > 0
	For nX := 1 to Len(aSL4Aux)
		aAdd( aSL4, {} )
		aAdd( aSL4[Len(aSL4)], { "L4_FILIAL"  ,xFilial("SL4") } )
		aAdd( aSL4[Len(aSL4)], { "L4_DATA"    ,aSL4Aux[nX][1] } )
		aAdd( aSL4[Len(aSL4)], { "L4_VALOR"   ,aSL4Aux[nX][5] } )
		aAdd( aSL4[Len(aSL4)], { "L4_FORMA"   ,aSL4Aux[nX][3] } )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a gravacao desses campos direto do aPgtos pois a funcao Lj7GeraOrc   ³
		//³ foi chamada antes da gravação desses campos no SL4                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !IsMoney(aPgtos[Len(aSL4)][3])
			If Trim(aPgtos[Len(aSL4)][3]) == "CH"
				aAdd( aSL4[Len(aSL4)], { "L4_ADMINIS"	, aPgtos[Len(aSL4)][4][04] } )
				aAdd( aSL4[Len(aSL4)], { "L4_NUMCART"	, aPgtos[Len(aSL4)][4][07] } )
				aAdd( aSL4[Len(aSL4)], { "L4_AGENCIA"	, aPgtos[Len(aSL4)][4][05] } )
				aAdd( aSL4[Len(aSL4)], { "L4_CONTA"		, aPgtos[Len(aSL4)][4][06] } )
				aAdd( aSL4[Len(aSL4)], { "L4_RG"		, aPgtos[Len(aSL4)][4][09] } )
				aAdd( aSL4[Len(aSL4)], { "L4_TELEFON"	, aPgtos[Len(aSL4)][4][10] } )
				aAdd( aSL4[Len(aSL4)], { "L4_COMP"		, aPgtos[Len(aSL4)][4][08] } )
				aAdd( aSL4[Len(aSL4)], { "L4_TERCEIR"	, aPgtos[Len(aSL4)][4][12] } )
				aAdd( aSL4[Len(aSL4)], { "L4_NOMECLI"	, aPgtos[Len(aSL4)][4][14] } )
			Else
				If Len(aPgtos[Len(aSL4)][4]) >= 5
					aAdd( aSL4[Len(aSL4)], { "L4_ADMINIS"	, aPgtos[Len(aSL4)][4][05] } )
					aAdd( aSL4[Len(aSL4)], { "L4_NUMCART"	, aPgtos[Len(aSL4)][4][04] } )
				EndIf
			EndIf
		EndIf
		If cPaisLoc <> "BRA"
		   aAdd( aSL4[Len(aSL4)], { "L4_MOEDA"   ,aSL4Aux[nX][_MOEDA] } )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o valor do acrescimo separado da parcela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA"))
			aAdd( aSL4[Len(aSL4)], aIcmJr[nX] )
		EndIf

		If SL1->L1_TROCO1 > 0 .AND. nVlrTroco > 0 .AND. cEntrega == "2"
			aAdd( aSL4[Len(aSL4)], { "L4_TROCO"	, nVlrTroco } )
		EndIf

	Next nX
Else
	aAdd( aSL4, {} )
	aAdd( aSL4[Len(aSL4)], { "L4_FILIAL"  ,xFilial("SL4") } )
	aAdd( aSL4[Len(aSL4)], { "L4_DATA"    ,dDataBase } )
	aAdd( aSL4[Len(aSL4)], { "L4_VALOR"   ,0 } )
	aAdd( aSL4[Len(aSL4)], { "L4_FORMA"   ,cMVSimb1 } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa DAV de orçamento filho  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lJob .AND. SL1->(ColumnPos("L1_NUMORC")) > 0
	aSL1[aScan(aSL1,{|x|x[1]=="L1_NUMORC"})][2] := ''
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ gravação do valor de credito proporcionalizado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob .AND. SL1->(ColumnPos("L1_CREDITO")) > 0
	aSL1[aScan(aSL1,{|x|x[1]=="L1_CREDITO"})][2] := nNccProp
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array de retorno      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := { aSL1, aSL2, aSL4 }

Lj7RestArea( aArea )
Return aRet

/*/{Protheus.doc} Lj7CriaEntrMont
Planeja a entrega e montagem dos produtos informado. 
@param	aItens	 Array de tamanho n, sendo: 
		aItens[n]: O número do item na venda. 
		cNumPai  Número do orçamento pai da venda. 
@author  Varejo
@version P11
@since   18/10/2009
@return  lRetorno
/*/
Static Function Lj7CriaEntrMont( aItens, cNumPai )
	Local cOcorMontagem	:= GetNewPar( "MV_TECOCOM", "" )
	Local cOcorEntrega	:= GetNewPar( "MV_TECOCOA", "" )
	Local cCondPag		:= SuperGetMV( "MV_CONDPAD",, "" )
	Local lLJ7056		:= ExistBlock("LJ7056")							// Ponto de entrada executado logo após a criação da ordem de serviço. Inicialmente criado para que o cliente possa agendar ou controlar o agendamento da ordem de serviço logo após a criação da mesma
	Local lLJ7059		:= ExistBlock("LJ7059")							// Se existe o PE LJ7059. Esse ponto de entrada tem como objetivo permitir que o cliente crie número de série para cada produto informado, possibilitando assim a criação da OS.
	Local lRetorno		:= .T.
	Local cNumOs		:= ""
	Local aOSInfo		:= {}
	Local cErro			:= ""
	Local nRegs       	:= 1
	Local lMultiplos  	:= .F.
	Local nI          	:= 0
	Local nCount		:= 0
	Local aNrsSerie		:= {}
	Local aAreaSB1		:= {}
	Local lFTVD7056		:= ExistBlock("FTVD7056")							// Ponto de entrada executado logo após a criação da ordem de serviço. Inicialmente criado para que o cliente possa agendar ou controlar o agendamento da ordem de serviço logo após a criação da mesma
	Local lFTVD7059		:= ExistBlock("FTVD7059")							// Se existe o PE FTVD7059. Esse ponto de entrada tem como objetivo permitir que o cliente crie número de série para cada produto informado, possibilitando assim a criação da OS.
	//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
	Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida


	// Se não estiver configurado os parâmetros com as informações dos serviços, cancela a criação da OS
	If cOcorMontagem == "" .AND. cOcorEntrega == ""
		lRetorno := .F.
	EndIf

	// Se não estiver configurado a condição de pagamento padrão, cancela a criação da OS
	If Empty(cCondPag)
		lRetorno := .F.
	EndIf

	If lRetorno
		For nCount := 1 To Len( aItens )
			nRegs		:= 1
			lMultiplos	:= .F.
			If SL2->( DbSeek( xFilial("SL2") + cNumPai + aItens[nCount] ) )
				aAreaSB1 := SB1->(GetArea())
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SL2->L2_PRODUTO))
				// Produto principal eh configurado como garantia SB1->B1_GARANT = 1 porem Tipo diferente de Garantia
				// Eh passado para funcao somente os produtos configurados conforme Boletim
				// Tirada a consistencia SB1->B1_GARANT<>"1", pois o produto nao precisa ser de Garantia para ser Montagem
			    If (SB1->B1_TIPO == "GE" .And. !Empty(SB1->B1_ADMIN) .And. SB1->B1_GARANT=="1")
			       Loop
			    Endif
				RestArea(aAreaSB1)
				// Se o número de série não estiver preenchido e existir o PE LJ7059 pega os números de série vindos do PE. Verifique que nesse caso é possível haver vários números de série para cada produto, isso é possível, pois o PE possibilita informa um número de série para cada quantidade informada.
				If (Empty( SL2->L2_NSERIE ) .AND. (lLJ7059 .AND. !lFtvdVer12)) .OR. (Empty( SL2->L2_NSERIE ) .And. (lFTVD7059 .AND. lFtvdVer12))
					If !lFtvdVer12
						aNrsSerie := ExecBlock( "LJ7059", .F., .F. )
					ElseIf lFtvdVer12
						aNrsSerie := ExecBlock( "FTVD7059", .F., .F. )
					EndIf

					If ValType(aNrsSerie) != "A" .AND. Len(aNrsSerie) <= 0
						Loop
					Else
						lMultiplos  := .T.
						nRegs       := Len(aNrsSerie)
					EndIf
				ElseIf !Empty(SL2->L2_NSERIE)
					Aadd(aNrsSerie,SL2->L2_NSERIE)
				Endif

				If Len(aNrsSerie) > 0
					// Cria a base instalada para o produto, ou para cada número de série informado no PE
					Lj7BaseInstalada( aNrsSerie )

					// Para cada produto ou para cada número de série informado no PE, adiciona o item da OS que deverá ser criado.
					For nI := 1 to nRegs
						// Se tiver data de entrega, cria um item para entrega
						If SL2->L2_FDTENTR != CToD("//") .AND. !Empty(cOcorEntrega)
								aAdd( aOSInfo, { SL2->L2_PRODUTO, If(lMultiplos, aNrsSerie[nI], SL2->L2_NSERIE), cOcorEntrega, SL2->L2_CODCONT } )
						EndIf

						// Se tiver data de montagem, cria um item para montagem
						If SL2->L2_FDTMONT != CToD("//") .AND. !Empty(cOcorMontagem)
								aAdd( aOSInfo, { SL2->L2_PRODUTO, If(lMultiplos, aNrsSerie[nI], SL2->L2_NSERIE), cOcorMontagem, SL2->L2_CODCONT } )
						EndIf
					Next
					// Zera array apos processo
					aNrsSerie	:= {}
				Endif
			Endif
		Next

		If Len( aItens ) > 0 .AND. Len( aOSInfo ) > 0
			If !LjCriaOS( cNumOS, SL1->L1_CLIENTE, SL1->L1_LOJA, cCondPag, SL1->L1_NUM, aOSInfo, cErro )
				lRetorno := .F.
			Else
			If lLJ7056 .AND. !lFtvdVer12
					ExecBlock( "LJ7056", .F., .F., { cNumOS } )
				EndIf

			If lFTVD7056 .AND. lFtvdVer12
				ExecBlock( "FTVD7056", .F., .F., { cNumOS } )
			EndIf

			EndIf
		EndIf
	EndIf
Return lRetorno

/*/{Protheus.doc} LjBkpReg
Faz a cópia dos valores e do R_E_C_N_O_ do registro, para que em casos de erro,
seja feita a restauração do mesmo, já que em DBF não há Controle de Transação
@param	 cAlias	 Indica o Alias do registro, o qual será feita a cópia
@author  Varejo
@version P11
@since   25/04/2015
@return  aReg - [1]vetor com os valores e o [2]R_E_C_N_O_ do registro
/*/
Static Function LjBkpReg(cAlias)

Local nTotCampo := 0	//totais de campo do registro
Local nCampo 	:= 0	//contador de campo
Local xValor			//valor do campo
Local aRet		:= {}	//vetor com os [1]vetor de valores dso campos e [2]R_E_C_N_O_ do registro
Local aCampos	:= {}	//vetor com os valores de cada campo

Default cAlias	:= Alias()

nTotCampo := (cAlias)->( FCount() )

For nCampo := 1 to nTotCampo
	xValor := (cAlias)->( FieldGet(nCampo) )
	Aadd( aCampos, xValor )
Next

aRet := { aCampos, (cAlias)->(Recno()) }

Return aRet
