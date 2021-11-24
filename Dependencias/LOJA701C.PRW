#INCLUDE "LOJA701C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDDEF.CH"
#INCLUDE "AUTODEF.CH"

#DEFINE _MOEORIPGT					2				//Moeda origem da venda
#DEFINE _FORMAPGTO					3				//Posicao do campo Forma de Pgto no array aPgtos(Localizacoes)
#DEFINE _MOEDA						6				//Posicao do campo Moeda no array aPgtos(Localizacoes)
#DEFINE TEF_NAO_USADO				"1"				//Nao Utiliza TEF
#DEFINE TEF_SEMCLIENT_DEDICADO  	"2"				//Utiliza TEF Dedicado Troca de Arquivos
#DEFINE TEF_COMCLIENT_DEDICADO  	"3"				//Utiliza TEF Dedicado com o Client
#DEFINE TEF_DISCADO             	"4"				//Utiliza TEF Discado
#DEFINE TEF_LOTE                	"5"				//Utiliza TEF em Lote
#DEFINE TEF_CLISITEF				"6"				//Utiliza a DLL CLISITEF
#DEFINE TEF_CENTROPAG				"7"				//Utiliza a DLL CENTRO DE PAGOS
#DEFINE _FORMATEF					"CC;CD"			//Formas de pagamento que utilizam operação TEF para validação
#DEFINE _FORMATPD				 	"PD|PX" 		// Formas de pagamento que utilizam TOTVS PAGAMENTOS DIGITAIS
#DEFINE _SERNFE						"SPED;RPS"		//Tipo de especie de nota eletronica
#DEFINE CTRL 						Chr(10)+Chr(13)	//Pula linha
#DEFINE REG_DELETED					"DELETED"		//Sinaliza registro SL2 deletado
#DEFINE GDP_NO						"0" 			//Nao sera gerada guia de despacho.Quando a venda não tem item reservado com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI
#DEFINE GDP_PARCIAL    				"1"				//Sera gerada guia de despacho parcial.Quando a venda possui pelo menos um item reservado com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI
#DEFINE GDP_TOTAL					"2"				//Sera gerada guia de despacho total.Quando todos os itens da venda estao reservados e com entrega do tipo 3 - Release 11.5 -  Chile - F2CHI
#DEFINE _CONTAHTL					12				//Conta Hotelaria
#DEFINE _TEFINTEG					13				//Informacoes Tef Integracao
#DEFINE _IDCNAB						14				//Informacoes IDCNAB

Static cGetCliDir														// Guarda o caminho do rootPath
Static cProfStr1														// Guarda o Retorno da Funcao GetPvProfString
Static cprofStr2														// Guarda o Retorno da Funcao GetPvProfString
Static lHomTEF      := ExistFunc("LJHOMTEF") .AND. LJMSSM0(SM0->M0_CGC)
Static lAmbOff	 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)				// Verifica se o ambiente esta em off-line
Static lMVLJPDVPA 	:= LjxBGetPaf()[2]									// Indica se é pdv
Static aSaveDecLj	:= Array(10,2) 										// Array utilizado na função Lj7Arred(), para calculo de arredondamento
Static lCenVenda	:= SuperGetMv("MV_LJCNVDA",,.F.)					// Indica se a integracao com o cenario de vendas esta ativa
Static cSenha		:= "******"											// Variavel apagada pelo Framework
Static lUsaIntFS	:= SuperGetMV("MV_LJINTFS",,.F.) .And. LjUpd90Ok()  // Verifica se a integracao com o financial services esta habilitada
Static aRetAdmTef	:= {}												// Guarda a Adm. Financeira selecionada para cada cartao utilizado na venda
Static aParceiros	:= {}												// Armazena envio de e-mail de itens vendidos com comissao para parceros que indicam a loja

/*Release 11.5 - Controle de Formularios
Paises:Chile/Colombia - F1CHI		  */
Static lCFolLocR5	:= SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL" .AND.	!lFiscal
Static lMostraCtb
Static lAglutCtb
Static lCtbOnLine
Static lCtbCusto
Static lReajuste
Static LAtuSA7lECF
Static lSFinanc		:= SuperGetMV("MV_LJCSF",,.F.) // Valida se habilita o controle de servicos financeiros
Static aPafNotaCF	:= {} //Guarda a nota que é usada quando o PAF imprime NOTA e CUPOM - ERPAFECF 02.03
Static lIsPafNfce	:= STBPafNfce()					//Usa NFC-e com PAF ?
static aOrcFilDel	:= {} //Guarda Orcamentos Filhos que devem ser excluidos 
Static aIdPgtoMfe	:= {}													//Array com o retorno dos pagamentos enviados ao VFPe
Static lMFE			:= LjUsaMfe()					//Se utiliza MFE
Static lLjRspFisc	:= ExistFunc("LjRspFisc")
Static lLjEnvPgto	:= ExistFunc("LjEnvPgto")
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado
Static lIntegrador 	:= IIF( ExistFunc("LjUsaIntgr"),LjUsaIntgr(), .T.) 

//Este DEFINE deve ser obrigatoriamente o ultimo a ser declarado pois se for declarado
//antes dos outros os demais nao sao identIficados. ***VerIficar com a Tecnologia***
//Este Log é um recurso a ser habilitado pelo departamento de desenvolvimento para averiguação 
//de possíveis problemas de transações TEF.
#DEFINE LOG_TEF  Lj7GetLog()

//Defines para tratamento do Array aItens utilizado pela funcao LJ7RecTrib.
#DEFINE __RECNO		01
#DEFINE __ITEM		02
#DEFINE __QUANT		03
#DEFINE __VRUNIT	04
#DEFINE __VLRITEM	05
#DEFINE __DESCPRO	06
#DEFINE __DESCFIN	07
#DEFINE __ACRSFIN	08
#DEFINE __LIVRE		09 // POSICAO LIVRE PARA USO
#DEFINE __PREMIO	10
#DEFINE __PRCTAB	11
#DEFINE __TES		12
#DEFINE __PRODUTO	13
#DEFINE __DESCITEM	14
#DEFINE __VALIPI	15
#DEFINE __ENTREGA	16
#DEFINE __TOTIMP	17 // Valor de Imposto NCM / NBS
#DEFINE __NLOTE		18 // L2_NLOTE
#DEFINE __LOTECTL	19 // L2_NLOTE
#DEFINE __TOTIMPFED	20 // Valor de Imposto Federal
#DEFINE __TOTIMPEST	21 // Valor de Imposto Estadual
#DEFINE __TOTIMPMUN	22 // Valor de Imposto Municipal
#DEFINE __ARRED		23 // Posicao logica para saber se teve ou nao arredondamento
#DEFINE __FRETE		24 // Posicao Valor de Frete
#DEFINE __ABATISS	25 // Posição do valor de abatimento do ISS

Static aCrdCliente 	:= {"",""}				//Informacao do cliente p/Private Label [1]-CNPJ/CPF [2]-Numero do Cartao Private Label
Static aRecCrd     	:= {}                   //Array com as parcelas do financiamento impressas no comprovante de financiamento
Static cContrato                           	//Numero do contrato de financiamento
Static aContratos  	:= {}          			// Numero de contrato gerado pela venda. Utilizado nos casos em que deve cancelar o contrato pendente
Static lAvalBotao  	:= .F.                 	//Controla se a avaliacao de credito ja foi acionada pelo botao da toolbar
Static aContraTmp  	:= {}                  	//Array com os numeros do contrato de financiamento(temporario), utilizado para cancelar
											//um contrato caso este nao seja associado a um orcamento ou venda
Static aInfMA7  	:= {}	                //Array com dados do MA7 para controle de "backup" caso o usuario nao confirme a operacao
Static aInfMAH  	:= {}                   //Array com dados do MAH para controle de "backup" caso o usuario nao confirme a operacao
Static aInfMAL  	:= {}                   //Array com dados do MAL para controle de "backup" caso o usuario nao confirme a operacao

//Variaveis utilizada no SELF-LIQUIDATE
Static aPremio		:= {}  					// Array com os premios resgatados pelo cliente
Static nTotPremio  	:= 0					// Total a pagar de Self-Liquidate
Static aLibera      := {}					// Array com os dados do responsavel pela liberacao do premio.
Static lCupFiscal	:= .F. 					// Controla se o cupom foi impresso
Static cTextoErro   := ""					// Armazena o texto contido no objeto do error.log para ser mostrado ao usuário
Static lTelaTefPed	:= .F.					// Controla se o retorno falso da função Lj7Pedido é da tela do TEF, e assim não será mostrado ao usuário nenhum erro
Static lTefCanc 	:= .F.					// Controla se o comando de desfazimento do Tef foi feito
Static lImpTefIpdv 	:= .F. 	    	        // Controla se a impressão do Cupom Tef foi feita para a modalidade IPDV
Static lFisLivro    := (SuperGetMV("MV_LJLVFIS",,1) == 2)	// Utiliza novo conceito para geracao do SF3
Static nValSubTot   := 0    	   	        // Controla o valor do subtotal se o tef ocorreu erro.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7GravacaoºAutor  ³Vendas Clientes    º Data ³  09/23/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama das funcoes de gravacao.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³voi Lj7Gravacao( ExpN1, ExpN2, ExpN3 )                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Incica se a funcao foi chamada via                  º±±
±±º          ³      1 - Salvar como orcamento                             º±±
±±º          ³      2 - Salvar como venda                                 º±±
±±º          ³      3 - Salvar como pedido                                º±±
±±º          ³ExpN2 - Indica a opcao escolhida na rotina (aRotina)        º±±
±±º          ³ExpN3 - Controle do semaforo (SX8)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Rotina do aFuncoes via Loja701                              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7Gravacao(	nTipo	, nOpc		, nSaveSx8	, lSair			,;
						nHandle	, aDocDev   , lAtuData	, lTemTefPend	,;
						aTefBKP , lDefPagto , cLQFrete	, nVlrAcrsFi	,;
						cEspDoc	, cDocFo	, aDadosCNeg, lErroNFCe		,;
						lErroNFe )

Local lAutoExC 		:= IsBlind() 	// Verifica se a rotina sera executada via execauto ou nao
Local bProcGrv 		:= { || Nil }	// Bloco de execucao do processamento de gravacao

bProcGrv := {|| LJ7RunGrv(	nTipo		, nOpc		, nSaveSx8	, @lSair		,;
							nHandle		, aDocDev   , lAtuData	, @lTemTefPend	,;
							@aTefBKP	, lDefPagto	, cLQFrete	, nVlrAcrsFi	,;
							cEspDoc		, cDocFo	, aDadosCNeg, @lErroNFCe	,;
							@lErroNFe ) }

If !lAutoExC
	FWMsgRun( Nil , bProcGrv, STR0221, STR0222 + " " + M->LQ_NUM ) //"Processando..."###"Aguarde...Processando orcamento"
Else
	Eval(bProcGrv)
EndIf

Return Nil

/*/{Protheus.doc} LJ7RunGrv
Chama das funcoes de gravacao.
@type		Function
@author		Vendas Clientes
@since		09/23/02
@param		ExpN1 - Incica se a funcao foi chamada via
                	1 - Salvar como orcamento
                	2 - Salvar como venda
                	3 - Salvar como pedido
          	ExpN2 - Indica a opcao escolhida na rotina (aRotina)
          	ExpN3 - Controle do semaforo (SX8)
@return
@example
LJ7RunGrv( ExpN1, ExpN2, ExpN3 )
/*/
Function LJ7RunGrv(	nTipo	, nOpc		, nSaveSx8	, lSair			,;
						nHandle	, aDocDev   , lAtuData	, lTemTefPend	,;
						aTefBKP , lDefPagto , cLQFrete	, nVlrAcrsFi	,;
						cEspDoc	, cDocFo	, aDadosCNeg, lErroNFCe		,;
						lErroNFe )

Local lReserva 		:= .F.																		// Controla se eh uma venda com reserva
Local lFinalizou 	:= .F.																		// Controle para ver ser a venda foi ou nao finalizada.
Local lRet			:= .T.																		// Retorno do ponto de entrada LJ7001
Local lFinanceiro 	:= .T.																		// Indica se gera movimentacao financeira
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao da codigo do produto
Local nPosDesc		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_DESCRI"})][2]		// Posicao da Descricao do produto
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
Local nPosDtReserva	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_RESERVA"})				// Posicao do codigo da reserva
Local nPosEntrega   := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ENTREGA"})][2]
Local nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOCAL"})				// Posicao do local (armazem)
Local nPosTes		:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_TES"})					// Posicao da TES
Local nPosQtd	  	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
Local cCondPad      := SuperGetMV( "MV_CONDPAD" )												// Condicao de pagamento padrao
Local cConfCli      := SuperGetMV( "MV_CONFCLI" ) 												// Utiliza configuracoes do cliente
Local cCond         := ""                      													// Condicao de pagamento DEFAULT utilizada
Local nX 			:= 0																		// Variavel auxiliar
Local lEstNeg		:= (SuperGetMv("MV_ESTNEG") == "S")											// Indica se permite ou nao estoque negativo
Local cMsg			:= ""																		// Mensagem com o codigo e o produto
Local lTrocoLoc     := .F.																		// Valida se tem troco
Local nDecsTroco    := 0																		// Decimais do troco
Local aAreaMAD      := {}																		// Salva area do MAD
Local cMay          := ""																		// Codigo que sera utilizado para a gravacao do endereco do Consumidor Final
Local nTent			:= 0																		// Numero de tentativas, para gerar numero sequencial
Local nTotGeral     := 0																		// Soma total geral
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()																	// Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lFisNota      := (SuperGetMV("MV_FISNOTA",,.F.) .OR. lFtvdVer12)		 					// Parametro que habilita (.T.) a emissao de NF na venda
Local lEmiteNF      := .F.   																	// Flag para emissao de NF na venda
Local nDocSai       := 1     																	// Variavel para controle do documento emitido: 1=Cupom;2=Nota;3=Retorna a venda
Local nI			:= 0     																	// Variavel auxiliar
Local lUsafd      	:= SuperGetMV("MV_LJUSAFD",,.F.) 											// Utiliza Fidelizacao de cliente ??
Local cGrupoProd	:= ""																		// Grupo de produto
Local aProdCri		:= {}																		// Array com os produtos para analise de criterio de pontos
Local nPosVlItem    := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VLRITEM"})][2]	// Posicao do Valor Total do Item
Local lLog1       	:= SubStr(LJGetProfile("LOGERRO"),1,1) == "S" 								// Tem Log de Erro
Local lLog4         := SubStr(LJGetProfile("LOGERRO"),4,1) == "S" 								// Log de Recuperacao, grava as parcelas
Local nTroco		:= 0																		// Valor do troco
Local nTotPgtos		:= 0																		// Soma o total do array a Pgtos
Local lLJ7042		:= .T.																		// Retorno do ponto de entrada LJ7042()
Local lFTVD7042		:= .T.																		// Retorno do ponto de entrada FTVD7042()
Local cMvCrdForm	:= SuperGetMV("MV_CRDFORM",,"VA") 											// Forma de pagamento nao considerada na pontuacao do CRD
Local cMvSimb		:= SuperGetMV("MV_SIMB"+Alltrim(STR(nMoedaCor)))							// Variavel que recebe o parametro MV_SIMB1
Local lAutoExC 		:= IsBlind()																// Verifica se a rotina sera executada via execauto ou na
Local aDadosCF    	:= {}      																	// Dados do Cupom Fiscal
Local nUsado	  	:= 0																		// Pontos usados no resgate de premios
Local nTotPontos  	:= 0
Local cMV_CLIPAD	:= PadR(SuperGetMV("MV_CLIPAD"),TAMSX3("LQ_CLIENTE")[1])					// Cliente padrao
Local cMV_LOJAPAD	:= PadR(SuperGetMV("MV_LOJAPAD"),TAMSX3("LQ_LOJA")[1])   					// Loja do cliente padrao
Local cPgVc 		:= ""																		// Informa que houve pagamento com vale-compra
Local nPag			:= 0																		// Total de pagamento dIferente de vale-compra
Local nParamTipo    := 0                                                                        // Parametro do PE LJ7001
Local lRetPedido	:= .F.																		// IdentIfica se o pedido foi gravado corretamente
Local cDoc			:= Space(TamSx3("L1_DOC")[1])												// Numero do cupom fiscal
Local cPdv			:= Space(TamSx3("L1_PDV")[1])												// Numero do equipamento
Local cSerie 		:= ""																		// Serie do documento
Local lMsgTEF		:= .F.																		// Identifica se deve mostrar a mensagem de tef para cancelamento
Local lLibEmiteNF   := .F.                                                                  	// Controla se esta liberado para emitir apenas NF
Local nVlrParcelas	:= 0 																		// Total das parcelas
Local nTotParcs		:= 0																		// Total de parcelas convertida para a moeda corrente
Local nDIf          := 0                                                                    	// Diferenca entre o valor da venda e de parcelas
Local nTPCompNCC    := SuperGetMV("MV_LJCPNCC",,1)												// Tratamento para compensacao de NCC 1-Compensacao atual 2 - Nova Compensacao
Local lEmisNF		:= (LjEmiteNF(SM0->M0_CGC,lLibEmiteNF) .OR. lFtvdVer12) 					// Verifica se a empresa se enquadra na LjEmiteNF
Local cNumSerie 	:= Space(TamSx3("LG_SERPDV")[1])											// Numero de serie do PDV
Local nRet			:= 1																		// Retorno da funcao da dll
Local lImpNfArg		:= .F.																		// Valida se pode ser imprimir NF (Localizado Argentina)
Local cTipoCli		:= ""                                                                       // Tipo do Cliente
Local cCondSA1		:= ""                                                                       // Condicao de pagamento do Cliente
Local lUsafdOff		:= SuperGetMV("MV_FRTCRD",,.F.)                                             // Verifica se crd é off Line
Local oSWB			:= Nil																		// Faz baixa crd
Local nPontos 		:= 0 																		// Numero de pontos CRD
Local cCGCCli		:= ""																		// CGC do cliente selecionado
Local cNomeCli		:= ""																		// Nome do cliente slecionado
Local lNfManual		:= .F.																		// Nota fiscal manual
Local lImpReserva	:= .F.																		// Se irá emitir cupum de itens de reserva quando orçamento filho
Local nFatorRes		:=	1 																		// Fator reserva
Local nFatorVen		:=	1																		// Fator venda
Local nTotalCF		:= 0																		// Valor total do Cupom Fiscal (diferente da NF)
Local nFlagLegSP	:= 0																		// Flag que indica qual tipo de aviso sera dado no controle da legislacao paulista que bloqueia CF em 10.000,00
Local lTefManuPed	:= .T.																		// Verifica se utiliza TEF Manual e se será executado o cancelamento da venda qdo pedido.
Local nDescontFi    :=  0																		// Valor do Desconto Finaceiro (Configurado na condicao de pagamento)
Local lDscCupTef	:= .F.																		// Indica se o Cupom TEF Discado ja foi impresso
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)													// Verifica as filiais da trabalharam com acrescimento separado
Local lAtivaMn		:= SuperGetMV("MV_LJMULTN", , .F.)											// Ativa Multi Negociacao
Local lLjIcmJr		:= SuperGetMv("MV_LJICMJR", , .F.)											// Não incide ICMS sobre Juros
Local lRetaPaf		:= LjNfPafEcf(SM0->M0_CGC) .And. !lMvljpdvpa 								// Sinaliza Retaguarda PAF-ECF
Local cNumOrc		:= M->LQ_NUM																// Numero do orcamento
Local aParcEnviar	:= {}																		// Itens para enviar para parceiros
Local lLJ7083		:= ExistBlock("LJ7083")														// Indica se o PE LJ7083 esta compilado
Local nAux			:= 0																		// Variável numérica auxiliar
Local cDescEspFo	:= ""																		// Descricao da especie de documento fiscal selecionada no inicio da venda
Local cSigEspFo		:= ""																		// Sigla da especie de documento fiscal selecionada no inicio da venda
Local lLstPresAt    := SuperGetMV("MV_LJLSPRE",.F.,.F.) .AND. LjUpd78Ok()
Local nOpcProc		:= 0																		// Numero da Operacao
Local cDocPed		:= ""
Local cSeriePed		:= ""
Local lAlteraPrc    := .F.                                                                      // Controle de alteração das parcelas para nTipo == 4
Local lIntGC 		:= .T.
Local nTotICM		:= 0
Local nArredondar	:= 0																		// Valor para doação (Instituto Arredondar)
Local lArredondar	:= SuperGetMv("MV_LJINSAR",,.F.)											// Parâmetro para ativar o Instituto Arredondar
Local lECommerce 	:= SuperGetMV("MV_LJECOMM",,.F.) .And. LJ862ECAuto()
Local lMvLjIPEn	 	:= SuperGetMV("MV_LJIPENP",, .F.)
Local nPosDtVLIPI	:= 0  																		// Valor do IPI Calculado pelo sistema
Local nValIPI	 	:= 0  																		// Valor Residual do IPI  = Valor do IPI Calculado pelo sistema - valor do IPi descontado da tabela
Local nPrecoTab	 	:= 0  																		// Preço do Item
Local nIPIDesc  	:= 0   																		// Valor Total do IPI Descontado
Local cRet			:= " " 																		// Texto retornado pelo ECF
Local lIntegDef		:= Lj701GtInD() //Venda Origem Integração
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lEmitNFCe		:= (!lFtvdVer12 .Or. lIntegDef) .AND. LjEmitNFCe()							// Sinaliza se utiliza NFC-e
Local aBkpTable	 	:= {}
Local lIntSynt 	 	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 									// Informa se a integracao Synthesis esta ativa
Local lECiaIPI		:= LJ901AIPI() 																//Venda e-commerce CiaShop com IPI
Local lMVLJLBNT 	:= SuperGetMv("MV_LJLBNT",,0) > 0											//Habilita Finalizar Venda - Vide doc:http://tdn.totvs.com.br/display/PROT/TUXK67_DT_Disponibilizar_Emissao_Nota_Fiscal_Interestadual_Venda_Assistida
Local cLJRESER 		:= SuperGetMV("MV_LJRESER ",,"1") 											//Controla como será realizada a reserva de produtos da venda. 1=Ao pressionar o botão F11; 2=Na gravação do orçamento; 3=Na gravação da venda.
Local lTemItemRes	:= .F. 																		//Indica se tem item que necessita de reserva
Local aNotaCanc  	:= {}
Local cDocCanc 		:= ""
Local cSerieCanc 	:= ""
Local cModDoc 	 	:= ""
Local cOperador  	:= ""
Local aLJRESERV  	:= {}
Local cBkpFilAnt 	:= cFilAnt 																	//Faz Backup da Filial Atual, caso ocorrer algum erro durante a transacao, retorna para a filial corrente
Local nRecnoSM0  	:= SM0->(RecNo())															// Guarda a posicao do SM0
Local bProcessa 	:= Nil
Local cTxtNFis	 	:= ""
Local cLOGTEFBKP 	:= ""
Local nMNCC      	:= 0    																	// Posicao do Cartao de Credito no aPgtos para Mult-Negociacao
Local aRetInfDocCli := {}
Local lFretAlt		:= .F.
Local cMsgLock		:= STR0206 																	//"Usúario nao definido"
Local lULOJRREC		:= ExistBlock("LOJRRecibo")													// Relatorio de impressao de Recibo (RDMAKE)
Local lIMPLJRE		:= SuperGetMV("MV_IMPLJRE",,.F.)											// Ativa impressão de recibo de pagamento, requer UPDLO166
Local aTitBx		:= {}																		//Array contendo o título incluido para impressao do Recibo de Pagamento
Local aFormPg		:= {}																		//Array contendo a forma de pagamento RA para impressao do Recibo
Local cMvLjPref		:= SuperGetMV("MV_LJPREF")  												//Regra para gravacao do SF2->F2_PREFIXO
Local cNumDoc 		:= ""																		//Numero do documento no financeiro
Local cPrefixo		:= "" 																		//Prefixo do documento no financeiro
Local lUseSAT 		:= LjUseSat()
Local cMsgErro		:= ""																		//Mensagem de Erro vinda do Lj7GrvVenda()
Local xMvLjTxNFe 	:= 0																		//Verifica se a funcionalidade de transmissao da NF-e está habilitada
Local lPergNFCup	:= .F.																		//indica se já fez a pergunta "Nota ou Cupom"
Local aDocSaida		:= {}																		//[1] Tipo do Doc de Saida 1/2/3 [2] permite emissao de NF
Local aDocReti		:= {}																		//Guarda informacoes do orcamento retira finalizado.
Local aRetPbm		:= {}   																	//Retorno dos dados retornados do PBM Funcional Card
Local lMaFisSave	:= .F.																		//Indica se gerou backup dos arrays da MatxFis, para posteriormente restaurar o backup para poder esvaziar o array de backup da MatxFis
Local lItGeraRes 	:= .F.																		// Indica se tem itam com necessidade de gerar reserva

// --	Cancelamento / Inutilização  
Local oLOJCNFCE		:= Nil																		//Variavel responsavel por armazenar a classe LOJCNFCE				
Local dDtInutPDV	:= CtoD("05/07/2019")														//Data utilizada na validação de fontes.	
Local lInutPDV		:= Iif(ExistFunc("LOJXNFCE") .AND. ExistFunc("LOJGNFCE") .AND. ExistFunc("LOJCNFCE") ,GetApoInfo("LOJXNFCE.PRW")[4] >= dDtInutPDV .AND. GetApoInfo("LOJGNFCE.PRW")[4] >= dDtInutPDV .AND. GetApoInfo("LOJCNFCE.PRW")[4] >= dDtInutPDV,.F.)		//Validação para o uso do cancelamento / inutilização direto no PDV
Local cMVLJPVLIB	:= SuperGetMV("MV_LJPVLIB")													// Forma de geração do Pedido de Venda. 1-Gera pedido Liberado; 2=Gera pedido não Liberado
Local lOnlyServ		:= .F.																		// Variavel utilizada para indicar qdo. a venda possui apenas itens de servico

//Tratamento para efetuar o fechamento da tela
Default lSair	  	:= .F.
Default aDocDev   	:= {}
Default lDefPagto   := .F.	// Se .T. passou pela tela de definição de pagamento
Default cLQFrete    := ""	// Recebe valor do campo LQ_TPFRET 0- Sem Frete 1- CIf 2- FOB
Default cEspDoc		:= ""	//Especie do documento
Default cDocFo		:= ""
Default aDadosCNeg	:= {}
Default lErroNFCe 	:= .F.
Default lErroNFe 	:= .F.


//Validação para não gravar orçamento quando utilizar PBM Funcional Card, pois depende de informações reservadas pelo TEF.
If nTipo == 1
	aRetPbm := LJGDadosVL()
	If Len(aRetPbm) > 2 .And. aRetPbm[3] == 2 
		MsgStop(STR0211) //"A venda possui itens do PBM Funcional Card, não será possível salvar como orçamento."
		Return Nil
	EndIf
EndIf

If !lAutoExC
	SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
	SL1->(DbSeek(xFilial("SL1")+M->LQ_NUM))
EndIf

/*
- Conversao do valor do parametro MV_LJTXNFE -
A principio, esse parametro foi criado com o tipo Logico,
porem foi transformado em numerico para aumentar o numero de opcoes.
*/
xMvLjTxNFe := SuperGetMV("MV_LJTXNFE",,0)
If ValType(xMvLjTxNFe) == "L"
	If xMvLjTxNFe
		xMvLjTxNFe := 1	//Somente realiza a transmissao da NF-e
	Else
		xMvLjTxNFe := 0
	EndIf
	LjGrvLog( SL1->L1_NUM, "Houve a conversao do parametro MV_LJTXNFE", xMvLjTxNFe )
EndIf

// Quando chamado com nTipo == 4 será lAlteraPrc setada true, pois todo o tratamento será igual ao tratamento de inclusão e
// apenas na gravação será tratado de maneira diferente.
If nTipo == 4 .AND. lFtvdVer12
	nTipo := 1
	lAlteraPrc := .T.
EndIf

LjGrvLog(cNumOrc,"PRESSIONOU F5")
LjGrvLog(cNumOrc,"INICIO DE FINALIZACAO DA VENDA",nTipo)
lCupFiscal	:= .F.

//Rotinas especificas para ECF, Nfc-e trabalha com Impressora Nao Fiscal
If !lEmitNFCe .Or. lIsPafNfce
	If lFiscal .AND. cPaisLoc == "BRA"

		// Verifica se o status da impressora esta ok
		nRet := IFStatus(nHdlECF, "9", @cRet)
		If nRet <> 0
			MsgStop(STR0115)	// "Erro de comunicação com a impressora fiscal."
			Return NIL
		EndIf

		// Retorna numero de serie da impressora
		nRet := IFPegSerie(nHdlECF, @cNumSerie)

		If !AllTrim(UPPER(cNumSerie)) == AllTrim(UPPER(LJGetStation("LG_SERPDV")))
			MsgStop(STR0116)	// "O número de Série do equipamento é diferente do cadastrado na estação."
			Return NIL
		EndIf
	EndIf

	If !LjEcfXData()
		Return NIL
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o cliente esta alocado para outro usuario , caso esteja   	³
//³ nao da procedencia a finalizacao da venda .								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 2
	SA1->(DbSetOrder(1))
	If ( M->LQ_CLIENTE + M->LQ_LOJA <> cMV_CLIPAD + cMV_LOJAPAD ) .AND. SA1->( DbSeek( xFilial("SA1") + M->LQ_CLIENTE+M->LQ_LOJA ) )
		If !Empty(M->LQ_CLIENTE)
			cTipoCli := M->LQ_TIPOCLI
		Else
			cTipoCli := SA1->A1_TIPO
		EndIf
		cCondSA1 := SA1->A1_COND
		cNomeCli := SA1->A1_NOME
		cCGCCli	 := SA1->A1_CGC
		If SA1->A1_COD+SA1->A1_LOJA <> cMV_CLIPAD+cMV_LOJAPAD
			If SA1->(Rlock())
				SA1->(SoftLock('SA1'))
			Else

			  	If TCGetConn() >= 0
			    	cMsgLock := TCInternal(53)
			    	IF !Empty(cMsgLock)
			      		cMsgLock := Chr(13)+Chr(10) + StrTran(STR0181+cMsgLock,"|",Chr(13)+Chr(10)+STR0182)   //"Usuário:"  ## | //" Função:"
			    	Endif
				EndIf

				If !lAutoExC
					Aviso(STR0007+", "+STR0129, STR0130+M->LQ_CLIENTE+STR0131+M->LQ_LOJA+STR0132+":"+cMsgLock, {STR0005}) 					//"Atencao"##"Impossível Finalizar"#"O Registro do Cliente: "#" está alocado por outro usuario do sistema."#"Ok"
					Return Nil //Nao permite gravar venda
				Else
					//Quando execAuto permite
					ConOut(STR0130+M->LQ_CLIENTE+STR0131+M->LQ_LOJA+STR0132+":"+cMsgLock) // O Registro do Cliente: está alocado por outro usuario do sistema.
					Help( " ", 1, "Help",, STR0130+M->LQ_CLIENTE+STR0131+M->LQ_LOJA+STR0132+":"+cMsgLock, 1, 0 )
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lSFinanc
    For nI:= 1 To  Len(aCols)
		MG8->(DbSetOrder(2))//MG8_FILIAL+MG8_PRDSB1
		If MG8->(DbSeek(xFilial('MG8')+aCols[nI][nPosProd] ))
			If nTipo == 1
				If LJVldCliSf()
					Return Nil
				EndIf
			Else
				Aviso(STR0007,STR0183,{STR0005}) //#"Atenção" ##"A venda de Serviços Financeiros não esta habilitada para interface Venda Assistida apenas para o Novo PDV." ###"Ok"
				Return NIL
			EndIf
		EndIf
    Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando DAV eh obrigatorio informar o CPF/CNPJ do cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Se vier de lAutoexec, não é necessário checar DAV por causa da importação do uMov.me para o Sigaloja
If !lMvljpdvpa .AND. LjNfPafEcf(SM0->M0_CGC) .AND. !SuperGetMV("MV_LJPRVEN",,.F.) .AND.;
   Empty(SA1->A1_CGC) .And. !(AllTrim(SA1->A1_EST) == "EX") .AND.  !lFtvdVer12 .AND. (Type("lAutoExec") <> "L" .OR. !lAutoExec)

	If !lAutoExC
		MsgStop( STR0165 + Chr(13) + STR0166)	//"Conforme previsto no Resquisito VI(ATO COTEPE/ICMS 0608):"  //"Para realizar um DAV é necessário informar cliente com CPF/CNPJ"
	Else
		ConOut( STR0165 + STR0166)	//"Conforme previsto no Resquisito VI(ATO COTEPE/ICMS 0608):"  //"Para realizar um DAV é necessário informar cliente com CPF/CNPJ"
		Help( " ", 1, "Help",, STR0165 + STR0166, 1, 0 )
	EndIf

	Return NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Condicao de Pagto, necessario validar nesse momento caso pressione F5 durante o preenchimento da condicao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LJ7VldCond(M->LQ_CONDPG, @cDescCondPg, @oDescCondPg, @oPgtos, Nil, nOpc, @nVlrAcrsFi)
	Return NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios				 ³
//³Se for cliente padrao e a especie do formulario		 ³
//³for igual a FCT-FACTURA ou FCX-FACTURA EXENTA         ³
//³a venda sera abortada.                                ³
//³Paises:Chile/Colombia - F1CHI		  				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCFolLocR5
	nRecnoSFP := LjGRecFo()
	LjxDadosFo(nRecnoSFP,NIL,@cSigEspFo,@cDescEspFo)//Obter dados do controle/lote de formulario selecionado
	If (M->LQ_CLIENTE + M->LQ_LOJA == cMV_CLIPAD + cMV_LOJAPAD) .AND. (cSigEspFo=="FCT" .OR. cSigEspFo=="FCX") .AND. cPaisLoc == "CHI"
		If !lAutoExC
			MsgStop(STR0158 + cDescEspFo)//"Cliente padrao não permitido para documento fiscal do tipo "
		Else
			Conout(STR0158 + cDescEspFo)//"Cliente padrao não permitido para documento fiscal do tipo "
			Help( " ", 1, "Help",, STR0158 + cDescEspFo, 1, 0 )
		Endif
		Return NIL
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita SetKeys      									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Lj7SetKeys(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se eh finalizacao da venda. Se afirmativo, grava o ³
//³ status ORCMOK no arquivo de log.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLog1 .AND. lLog4 .AND. nHandle >= 0 .AND. nOpc == 4
	nSize    := FSeek( nHandle, 0, 2 )
	cRBuffer := Space( nSize )

	FSeek( nHandle, 0, 0 )
	FRead( nHandle, @cRBuffer, nSize )

	cRBuffer := Encript( cRBuffer, 1 )
	If !("#ORCMOK#" $ cRBuffer)
		cRBuffer := cRBuffer + "#ORCMOK#"
	EndIf

	FSeek( nHandle, 0, 0 )
	FWrite( nHandle, Encript( cRBuffer, 0 ) )
EndIf

//Caso for salvar como orçamento e tiver alterado o frete sem passar pela tela de pagamentos , atualiza o SL4
If nOpc == 4 .AND. nTipo == 1 .AND. GetFretAlt() .AND. !lDefPagto
	lFretAlt := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a venda seja paga com NCC cria uma linha no aPgtos soh com a  ³
//³condicao de pagamento e data (o valor fica zerado)                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFretAlt .OR. ( Len(aPgtos) == 1 .AND. IIF(Valtype(aPgtos[1][1]) == "D", aPgtos[1][1] == CtoD(Space(8)), aPgtos[1][1] == Space(8)) .AND. aPgtos[1][2] == 0 .AND. ;
Empty(aPgtos[1][3]) .AND. (nTipo == 1 .OR. nNccUsada > 0) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utiliza a condicao de pagamento DEFAULT do cliente, caso esteja habilitado para usa-lo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cConfCli == "S"
		cCond := cCondSA1
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a condicao estiver vazia, utilizar a condicao DEFAULT do parametro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cCond ) .OR. nNCCUsada > 0
		cCond := cCondPad
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizo campo de codigo de condicao de pagamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->LQ_CONDPG := cCond

	If nTipo == 1 //Gravar como Orcamento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a variavel do tipo STATIC no LOJA701B.prw³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj7lAtuCond( .T. )
	EndIf
	Lj7CondPg( 2, cCond,, ( ! nNCCUsada > 0 ))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta a variavel na tela do Troco                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7AjustaTroco()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se foi efetuada alguma reserva, não realiza quando possui orçamento origem ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(SL1->L1_ORCRES)
	For nX := 1 to Len(aCols)

        //Verifica se o registro esta ativo
		If !aCols[nX][ Len(aCols[nX]) ] 
        
            If !Empty( aCols[nX][nPosEntrega] ) .AND. aCols[nx][nPosEntrega] <> "2" .AND. !Empty( aCols[nX][nPosProd] )
                lTemItemRes := .T.
                If !Empty(aColsDet[nX][nPosDtReserva]) .OR. aCols[nx][nPosEntrega] == "5"
                    // nTipo: 1=Orçamento / 2=Venda
                    // cLJRESER: 2=Na gravação do orçamento / 3=Na gravação da venda.          
                    If (nTipo == 1 .And. cLJRESER == "2") .Or. (nTipo == 2 .And. cLJRESER == "3")
                        // Irá atribuir "lReserva := .F.", para que apresente a tela de escolha de Filiais.
                        // Com o Tipo Entrega igual à "5", a escolha da Filial é obrigatória.
                        // Com MV_LJRESER igual a "2" ou "3", ainda não foi selecionada a Filial de geração do Pedido.
                        lItGeraRes := .T.
                    EndIf
                    lReserva := .T.
                ElseIf (AllTrim( aCols[nx][nPosEntrega] ) <> "5") .AND. Empty(aColsDet[nX][nPosDtReserva])
                    lItGeraRes := .T.
                EndIf
            EndIf

        EndIf
	Next nX

	If lItGeraRes
		lReserva := .F.
	EndIf

Else
	lImpReserva := .T.
EndIf

LjGrvLog(cNumOrc,"Conteudo da variavel lTemItemRes",lTemItemRes)
LjGrvLog(cNumOrc,"Conteudo da variavel lReserva - Ponto 1",lReserva)

If lTemItemRes .And. !lReserva //Verifica se tem item que necessita de reserva e nao tenha sido ainda feito a reserva
	// nTipo: 1=Orçamento / 2=Venda
	// cLJRESER: 2=Na gravação do orçamento / 3=Na gravação da venda.          
	If (nTipo == 1 .And. cLJRESER == "2") .Or. (nTipo == 2 .And. cLJRESER == "3")
		LjGrvLog(cNumOrc,"Vai efetuar a reserva dos produtos",cLJRESER)
		If !LJ7BtnRes( 1 ) //Efetua a reserva dos produtos
			/* MICHAEL - add lReserva, pois em situações onde há uma rejeição de NFC-e, o controle de transação desarma ela, deixando o orçamento a ser finalizado novamente,
			nesse caso, o item já foi reservado na primeira tentativa (existe na SC0), entao o ponto de entrada nao vai realizar uma nova reserva */
			If ExistBlock("LJRESERV") //Se existir o Ponto de Entrada compilado, eh pq a reserva  deve ser feita pelo PE. Desta forma nao permite finalizar a venda.
				aLJRESERV := ExecBlock("LJRESERV",.F.,.F., {"3", Nil, Nil, Nil} )
				LjGrvLog(cNumOrc,"Retorno do PE LJRESERV",aLJRESERV)
				If aLJRESERV[1]
					lReserva := .T.
				Else
                    LjxjMsgErr( I18n(STR0230, {"LJRESERV"}), STR0231, "U_LJRESERV")     //"Não foi possível efetuar a reserva a partir do ponto de entrada #1."     //"Verifique a customização para encontrar o motivo."
					Return NIL
				EndIf
			EndIf
		Else
			lReserva := .T.
		EndIf
	EndIf
EndIf

LjGrvLog(cNumOrc,"Conteudo da variavel lReserva - Ponto 2",lReserva)

If cPaisLoc == "BRA"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Doação para Instituto Arredondar						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lArredondar .AND. (LJ7T_Troco(2) > 0)
		nArredondar := LjxDDoeArredondar( LJ7T_Troco(2) )
	Elseif lArredondar .AND. aPgtos[1][3] $ "CC.CD"
		nAux		:= aPgtos[1][2]-NoRound(aPgtos[1][2],0)
		nArredondar := LjxDDoeArredondar( iif(nAux>0,1-nAux,nAux) )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para emissao de NF na venda                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 2
		If !lRecebe
			If lIntegDef //Tratamento Integracao para NFCe
				If lEmitNFCe
					lEmiteNF := .F.
				EndIf
			ElseIf !lFtvdVer12
				lEmiteNF :=	(LjNFFimVd() .OR.	;
							(nModulo == 5) .OR. ;
							(LjNfNoPaf(SM0->M0_CGC)) .OR.	;
							(LjNfPafEcf(SM0->M0_CGC) .AND. lMVLJLBNT .AND. LjNFFimVd()))
			ElseIf lFtvdVer12
				lEmiteNF := .T.
			EndIf

			//==============================================
			// Limitacao de 10.000,00 - Legislacao Paulista
			//==============================================
			nTotalCF := LJXTotalCF(Nil, .T.)	 			// Recebe valor total do cupom fiscal considerando os descontos e acrescimos
			If !LjNFFimVd() .And. !Lj950SP10OK(nTotalCF, 0)
				If Lj950RegraNF(SM0->M0_CGC) .And. LjCanUseNF(SM0->M0_CGC)
					nFlagLegSP := 3							// Questiona se pode finalizar em NF
				Else
					nFlagLegSP := 1							// Bloqueia e exibe detalhes da legislacao
				EndIf
				If Lj950SP10OK(nTotalCF, nFlagLegSP)		// Pergunta se deseja prosseguir imprimindo na Nota Fiscal
					lEmiteNF := .T.			 				// Alterna variavel de controle para emitir a NF
					lEmisNF  := .T.			 				// Alterna variavel de controle para emitir a NF
				Else
					Lj7SetKeys(.T.)			  				// Retorna ao sistema
					Return Nil
				EndIf
			EndIf

			aPAFNotaCF := {}

			// Nota com Cupom Somente em Homologacao - e se a venda não for concomitante
			If LjNFPAFECF(SM0->M0_CGC) .And. STBHomolPaf() .And. !lEmiteNF .And. !(SM0->M0_ESTCOB $ "ES|BA|PB")
				
				// marca para fazer a pergunta de Nota ou Cupom
				lPergNFCup := .T.
			
				nDocSai := LjDocSaida()[1]
				If nDocSai == 2
				
					nDocSai := 1
					Aadd( aPAFNotaCF, {"S",.T.} )

					LjxDNota(	SuperGetMV("MV_LJSNCFP",,"61")	, 1							, .T.	, 1		,;
								@aPafNotaCF						, Space(TamSx3("D2_DOC")[1]), nil	, 1		,;
								999								, .F.						, ""	, Nil	,;
								TamSx3("D2_DOC")[1]				, .F.						)
			
					If Len(aPAFNotaCF) > 0
						cDoc := aPAFNotaCF[2][2]
					EndIf
				EndIf				
			
			ElseIf !lEmiteNF
					
				If !IsBlind() .AND. lMVLJLBNT .And. LjNfPafEcf(SM0->M0_CGC) .And. (!lMVLJPDVPA .Or. LjConcNota())

					If nDocSai <> 2 .And. (nDocSai := Aviso(STR0053,STR0054,{STR0055, STR0056, STR0058})) == 1 //"Documento Fiscal de Saida"##"Qual Documento Fiscal de Saida sera impresso na venda?"##"Cupom"##"Nota"##"Cancela"
						Aviso(STR0007,STR0202,{STR0005})//"Atencao"##"Em Ambiente Retaguarda PAF, concomitante ou não, a gravação de Venda via Cupom Fiscal, não será permitida."##"Ok"
						Lj7SetKeys(.T.)
						Return Nil
					ElseIf nDocSai == 3 .OR. !(lEmiteNF := LjNFFimVd(.T.,.F.,.T.,,,,,nDocSai)) //Altera para emissao de Nota Fiscal
			       		Lj7SetKeys(.T.)
						Return Nil
					EndIf
					
				EndIf					
			
				/* Se o usuario caixa nao tiver a permissao "Usuario é Fiscal", é necessário que a empresa tenha permissao de Emissao de NF) */
				If IIF( !lFISCAL, (lEmisNF .AND. !LjNFFimVd()), !LjNFFimVd() )
					
					//SIGAFAT OU
					//Permite NF no PAF-ECF OU					
					// Legislacao da UF de GO que verifica se todos os produtos sao do tipo Vacina, se SIM, permite emitir NF
					If nModulo == 5 .OR. ;
						LjNFNoPAF(SM0->M0_CGC) .OR. ;					
						lFisNota .AND. Lj950CliEmis(SM0->M0_ESTCOB, .T.) .And. !lEmitNFCe .And. !lIsPafNfce .And. !lRetaPaf

						//marca pra perguntar
						lPergNFCup := .T.
							
						//usuario faz a selecao do Documento de Saida
						aDocSaida := LjDocSaida()
		
						nDocSai := aDocSaida[1]
						lEmiteNF := aDocSaida[2]
						
						//se nao atendeu as permissoes para emissao de NF, retorna nulo
						If (nDocSai = 2 .AND. !lEmiteNF) .OR. nDocSai = 3
							Lj7SetKeys(.T.)	// Libera o uso dos botões que estao na coluna da direita
							Return Nil
						EndIf
					EndIf

				EndIf
			EndIf

			//³Emite NF³
			If lEmiteNF
				//³Nota fiscal³
				nDocSai := 2
			//³ Emite Cupom³
			Else
				//³Cupom Fiscal³
				nDocSai := 1
				If !lFiscal .AND. !lAutoExec   								// nao eh usuario fiscal
					Aviso(STR0007, STR0043, {STR0005})	//"Atencao"##"Para finalizar uma venda, e necessario que o usuario tenha permissäo para usar impressora fiscal."##"Ok"
	       			Lj7SetKeys(.T.)
	    			Return NIL
				EndIf
			EndIf
		Else
			If !lFiscal
				If !lEmisNF
					Aviso(STR0007, STR0043, {STR0005})	//"Atencao"##"Para finalizar uma venda, e necessario que o usuario tenha permissäo para usar impressora fiscal."##"Ok"
					//³ Habilita as teclas de atalho                                             ³
					Lj7SetKeys(.T.)
					Return NIL
				EndIf
			EndIf
		EndIf
	EndIf
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Estrutura do array aDadosCF     ³
   //³ 1-Numero do Doc. Cons. Final    ³
   //³ 2-Tipo do Doc. Cons. Final      ³
   //³ 3-Codigo da Provincia do Doc.   ³
   //³ Carteira de Identidade(CI)      ³
   //³ 4-Nome do cliente Cons. Final   ³
   //³ 5-Codigo do endereco            ³
   //³ 6-Endereco                      ³
   //³ 7-Venda Consumidor Final(logico)³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "ARG"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso o usuario nao seja fiscal, emite mensagem e nao³
		//³deixa finalizar a venda                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lFiscal .AND. nTipo == 2 .AND. !Lj7ImpNf(@lImpNfArg)
			Aviso(STR0007, STR0043, {STR0005})	//"Atencao"##"Para finalizar uma venda, e necessario que o usuario tenha permissäo para usar impressora fiscal."##"Ok"
			Lj7SetKeys(.T.)
			Return NIL
		EndIf

		aDadosCF  :={	Space(TamSX3("LS_DOCCF")[1]),"",Space(TamSX3("LS_TIPOCI")[1]),;
						Space(TamSX3("LS_CLIECF")[1]),GetSxeNum("MAD","MAD_CODEND"),;
						Space(TamSX3("MAD_END")[1]),.F.}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tela para indicar tipo e numero de documento quando consumidor ³
		//³final e venda maior que o determinado no parametro MV_LIMCFIS  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	nTipo == 2 .AND. cTipoCli == "F" .AND.;
			Lj7T_Total(2) >= SuperGetMV("MV_LIMCFIS")

			//Exibe a tela para indicar o tipo e numero de documento quando consumidor final e
			//venda maior que o determinado no parametro MV_LIMCFIS.
	     	If !LjGetDocCF(@aDadosCF,nSaveSx8)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Habilita as teclas de atalho                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Lj7SetKeys(.T.)
				Return Nil
	     	EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gera o codigo que sera utilizado para a gravacao do endereco do consumidor final³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMay := Alltrim( xFilial("MAD") ) + aDadosCF[5]
			FreeUsedCode()

			DbSelectArea("MAD")
			aAreaMAD := GetArea()
			DbSetOrder(1)

			While DbSeek( xFilial("MAD") + aDadosCF[5] ) .OR. !MayIUseCode( cMay )
				If ++nTent > 20
					MsgStop(STR0035)                 //"Nao foi possivel gerar numero sequencial de endereco corretamente."
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Habilita as teclas de atalho                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Lj7SetKeys(.T.)
					Return Nil
				EndIf

				While (GetSX8Len() > nSaveSx8)
					ConfirmSx8()
				End
				aDadosCF[5] := GetSxeNum("MAD","MAD_CODEND")
				FreeUsedCode()
				cMay := Alltrim( xFilial("MAD") ) + aDadosCF[5]
			End
			RestArea(aAreaMAD)
			aDadosCF[7] := .T.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se foi utilizado o troco localizado. Caso tenha sido utilizado verIfica se o troco ³
	//³foi atribuido na sua totalidade, caso contrario não permite que a venda seja encerrada    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMV("MV_LJTRLOC")
		For nX := 1 To Len( aMoedas )
			nDecsTroco := MsDecimais(aMoedas[nX][06])

			If (aMoedas[nX][02] <> 0) .AND. (Round(aMoedas[nX][02],nDecsTroco) <> Round(aMoedas[nX][05],nDecsTroco))
				MsgAlert(STR0027)  //"Para que o orcamento/venda seja concluido e necessario que o troco seja totalmente informado ou que os valores ja atribuidos sejam zerados."
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Habilita as teclas de atalho                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Lj7SetKeys(.T.)
				Return Nil
			Else

				If aMoedas[nX][02] <> 0 .AND. Lj7T_Troco(2) > 0
					MsgAlert(STR0027)  //"Para que o orcamento/venda seja concluido e necessario que o troco seja totalmente informado ou que os valores ja atribuidos sejam zerados."
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Habilita as teclas de atalho                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Lj7SetKeys(.T.)
					Return Nil
				EndIf

				If Lj7T_Troco(2) <> 0 .AND. (aMoedas[nX][03] <> 0)
					lTrocoLoc := .T.
				EndIf
			EndIf
		Next nX

		If !lTrocoLoc
			For nX := 1 To Len( aPgtos )

			    If Empty(aPgtos[nX][_FORMAPGTO])
			       Loop
			    EndIf

				If aPgtos[nX][_MOEDA] <> nMoedaCor .AND. Lj7T_Troco(2) > 0
					MsgAlert(STR0028) //"Existe uma ou mais parcelas com moeda dIferente da moeda corrente da venda. Por favor informe o valor a ser dado como troco, para que o orcamento/venda possa ser encerrado."
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Habilita as teclas de atalho                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Lj7SetKeys(.T.)
					Return Nil
				EndIf

				If !IsMoney(aPgtos[nX][_FORMAPGTO]) .AND. Lj7T_Troco(2) > 0
					MsgAlert(STR0029) //"Existe uma ou mais parcelas com forma de pagamento dIferente de dinheiro. Por favor informe o valor a ser dado como troco, para que o orcamento/venda possa ser encerrado."
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Habilita as teclas de atalho                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Lj7SetKeys(.T.)
					Return Nil
				EndIf
			Next nX
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analise de credito do cliente selecionado                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 2 .AND. !LJ7AvalCred(nTipo)[1]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita as teclas de atalho                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.T.)
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz as consistencias no aCols  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRecebe .AND. !Lj7TudOk( nTipo )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita as teclas de atalho                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.T.)
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se o caixa esta aberto, senao nao deixa finalizar a venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nTipo == 2 ) .AND. !IsBlind() .AND. ( !ljCxAberto(.T.,xNumCaixa()) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita as teclas de atalho                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.T.)
	Return Nil
EndIf

//Recalcula as parcelas
/*
 Multi Negociacao - Tratamento necessário para que não seja incidido o valor de juros da
 multinegociacao na venda (não seja impresso no cupom fiscal como acréscimo ). Porem este
 valor deve ser considerado no rodapé do Total da venda mas gravado separadamente no campo L4_ACRSFIN.
*/
If lRetaPaf .And. lAtivaMn .And. ( lVerEmpres .Or. (lLjIcmJr .And. cPaisLoc == "BRA" ) ).and. SL1->(Fieldpos("L1_CODMNEG")) > 0 .And. !Empty(SL1->L1_CODMNEG)
	For nX := 1 To Len(aPgtos)
		nVlrParcelas += aPgtos[nX][2]
		If Alltrim(Upper(aPgtos[nX][3])) == "FI"
			aPgtos[nX][2] := ( aPgtos[nX][2] - iIf(ValType(aPgtos[nX][9])=="N", aPgtos[nX][9], 0) )
		EndIf
	Next
	nMNCC := aScan(aPgtos,{|x| AllTrim(Upper(x[3])) == "CC"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Caso tenha MultNegociação e existir diferenca entre o Sub-total e o Total da venda   |
	//|essa diferenca eh o acrescimo do catao de credito que deve ser apresentado no cupom. |
	//|sub-Total     - Total da Venda                                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nMNCC > 0
		nVlrAcrsFi += nVlrParcelas - aTotais[1][2]
	EndIf
	If nNCCUsada <= Lj7T_Total( 2) 
		Lj7T_Total( 2, nVlrParcelas + nNCCUsada)
	EndIf		
Else
	aEval( aPgtos, {|x| nVlrParcelas+=x[2] })
EndIf

nPosDtVLIPI := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VALIPI"})
nValIPI := 0

If lEcommerce  .AND. lMvLjIPEn .AND. nPosDtVLIPI  > 0
	//Caso seja uma venda e-ecommerce com o valor do ipi embutido, somo o valor do IPI
	For nX := 1 to Len(aColsDet)

        	LjxeValPre(@nPrecoTab, 	aCols[nX][nPosProd], M->LQ_CLIENTE , M->LQ_LOJA,;
					nMoedaCor   , aCols[nX][nPosQtd] , , @nIPIDesc,;
					.T. )
			nIPIDesc  :=  ( nIPIDesc *  aCols[nX][nPosQtd])

	     //	Apura a diferença entre o valor do IPI calculado pelo Loja e o Valor do IPI descontado
		nValIPI += (aColsDet[nX][nPosDtVLIPI] - nIPIDesc)
	Next nX
	If nValIPI <> 0
		//ajusto o valor residual do IPI para não dar diferença entre o valor total e o total das parcelas
		Lj7T_Total( 2, Lj7T_Total( 2) -  nValIPI)
	EndIf
EndIf

Lj7T_TotPar(2, nVlrParcelas + nNCCUsada)
nDIf   := Lj7T_Total( 2 ) - Lj7T_TotPar( 2 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Converte os valores do aPgtos para a moeda corrente da          ³
//³venda. Necessario isso para posteriormente realizar a comparacao³
//³entre o total da venda com o total das parcelas                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	nTotParcs := Lj701CvPgt() + nNCCUsada
	nDIf      :=  Lj7T_Total(2) - nTotParcs
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na Integração da Gestão de Concessionarias com o Venda Direta   ³
//³não é necessaria a validação de parcela                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SuperGetMV("MV_VEICULO",,"N")) == "S" .AND. SL1->(FieldPos("L1_ORIGEM")) > 0 //esta integrado com GC
	If FindFunction("FGX_VLDATE")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//A funcao retornara .F. quando se tratar de um orçamento gerado	³
		// pelo atendimento de veiculos. Caso contrario, retornara .T.		³
		// Função FGX_VLDATE é originaria do modulo de veiculos				³
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		lIntGC := FGX_VLDATE( SL1->L1_NUM )
	EndIf
EndIf

If lIntGC .AND. !lIntegDef
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Critica se nao foi informado pagamento (qdo nao for orcamento) /   ³
	//³valida tbem as notas de credito                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cPaisLoc == "BRA" .AND. Lj7T_TotPar(2) < Lj7T_Total(2) .AND. !lECiaIPI) .OR.;
	   (cPaisLoc <> "BRA" .AND. (nDIf > 0) .AND. ;
	   nDIf > (1 / (10 ^ MsDecimais(nMoedaCor)))) .AND. !lIntSynt

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se o cliente possui abatimento de ISS na venda - pois caso possua o valor³
		//³ total sera dIferente do pago													  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !LJ220AbISS(Nil, Nil, MaFisRet(,'NF_VALISS'))
			If lAutoExC
				Conout(STR0001)		//"O total de parcelas para pagamento é menor que o valor total da venda."
				Help( " ", 1, "Help",, STR0001, 1, 0 )  //"O total de parcelas para pagamento é menor que o valor total da venda."
				LjGrvLog(  SL1->L1_NUM,  "Troco " + cValTochar(SuperGetMV( "MV_LJTROCO", ,.F. ))  + ;
				" Valor do Troco  " + AllTrim( Transform( ( Lj7T_Troco(2) ), PesqPict( "SL1", "L1_VLRTOT",, nMoedaCor ) ) ))


				LjGrvLog(  SL1->L1_NUM,  STR0001 + " valor das parcelas " + ;
						 AllTrim( Transform( ( Lj7T_TotPar(2) ), PesqPict( "SL1", "L1_VLRTOT",, nMoedaCor ) ) ) + ;
						 " Valor da venda " +  AllTrim( Transform( ( Lj7T_Total(2) ), PesqPict( "SL1", "L1_VLRTOT",, nMoedaCor ) ) ))
			Else
				//"O total de parcelas para pagamento é menor que o valor total da venda.","Total das Parcelas - Total da Venda: "
				MsgStop( 	STR0001 + Chr( 13 ) + ;
							STR0104 + cMvSimb + " " + AllTrim( Transform( ( nDIf ), PesqPict( "SL1", "L1_VLRTOT",, nMoedaCor ) ) ) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Habilita as teclas de atalho                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   			Endif
			Lj7SetKeys(.T.)
			Return Nil
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³LOG TEF                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoExC
	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'LOJ701C'+Replicate('-',40))
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verfica se nao permite vender com o estoque negativo quando nao for orcamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRecebe .AND. !lEstNeg .AND. nTipo <> 1 .AND. !lMVLJPDVPA
	cMsg := ""

	For nX := 1 to Len( aCols )
		If !aCols[nX][Len(aCols[nX])]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente verIfica o estoque caso nao tenha sido feita a reserva do produto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aColsDet[nX][nPosDtReserva]) .AND. !( aCols[nX][nPosEntrega] == "5" .AND. cMVLJPVLIB == "2" )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada antes da verificacao de estoque no final da venda³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLJ7083
					ExecBlock("LJ7083",.F., .F., {aCols[nX][nPosProd], aColsDet[nX][nPosDtLocal], aCols[nX][nPosQuant]} )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Devo passar a quantidade de cada item e nao o total do produto, pois, na            ³
				//³funcao Lj7VerEst ja estou varrendo o acols e totalizando  a quantidade do produto   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(Lj7VerEst( aCols[nX][nPosProd]	, aColsDet[nX][nPosDtLocal]	, aCols[nX][nPosQuant]	, .F.	,;
								nX					, aColsDet[nX][nPosTes] ))
					cMsg := cMsg + Alltrim(aCols[nX][nPosProd]) + "-" + Alltrim(aCols[nX][nPosDesc]) + " | "
				EndIf
			EndIf
		EndIf
	Next nX

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'VerIfica Estoque - N / N / ' + AllTrim(Str(nTipo)) + ' / ' + cMsg)
	EndIf

	If !Empty(cMsg)
		MsgStop(STR0002 + Chr(10) +; //"Não será permitido finalizar a venda pois os produtos abaixo não possuem saldo em estoque."
				Subst(cMsg,1,Len(cMsg)-3) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Habilita as teclas de atalho                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj7SetKeys(.T.)
		Return Nil
	EndIf
EndIf

nTroco := Lj7T_Troco(2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checagem do valor de credito ao cliente                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNCCUsada > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma os valores colocados na condição de pagamento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nTotGeral := 0
	aEval(aPgtos, { |x| nTotGeral += x[2] })
	nTotPgtos	:= nTotGeral
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desconta o valor total da venda e os impostos (PIS/COFINS/CSLL).³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotGeral  := ( LJ7T_Total(2) - nTotGeral - Iif(LJ220AbISS(), MaFisRet(,'NF_VALISS'),0) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se existe troco e conteudo no aPgtos, signIfica que teve pagamento em dinheiro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ao realizar o cálculo para saber o valor da nova NCC a gerar, ³
	//³considera o desconto além do troco maior que zero,            ³
	//³devido ao exemplo abaixo:                                     ³
	//³                                                              ³
	//³Primeira tela (produtos) da Venda Assistida                   ³
	//³Total de produtos 100,00                                      ³
	//³Desconto no Total 30,00                                       ³
	//³Total da venda 70,00                                          ³
	//³                                                              ³
	//³Com a alteração realizada, verIfica se o Troco é maior que    ³
	//³zero OU Desconto realizado maior que zero                     ³
	//³E total de parcelas igual a zero.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nTroco > 0 .OR. Lj7T_DescV(2) > 0 ) .AND. nTotPgtos == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a nova NCC a ser gerada. Substraindo o que ja foi usado de NCC com o que sobrou no nTotGeral.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nNCCGerada := Abs( nNCCUsada - nTotGeral )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente mostra a msg que ira restar um credito de NCC quando for     ³
	//³ finalizacao da venda (nTipo == 2). Quando for finalizacao do orcamen-³
	//³ to (nTipo ==1), faz o calculo para que o campo L1_CREDITO seja       ³
	//³ gravado apenas com o valor da NCC que sera utilizada (para o caso de ³
	//³ utilizacao parcial da NCC)                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( nNCCGerada > 0 .AND. nTipo == 2 ) .AND. ( ( nTPCompNCC <> 3 ) .AND. ( nTPCompNCC <> 4 ) ) .AND. !lMVLJPDVPA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica se pode gerar uma NCC  com o valor do saldo restante³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(SuperGetMV("MV_USACRED"),1,1) == "S"
			If !lAutoExC
				Aviso(STR0003, STR0004 + SuperGetMV("MV_SIMB1") + " " + ;
				AllTrim(Transform(nNccGerada,PesqPict("SE1","E1_VALOR"))), {STR0005}) //"Nota de Crédito ao Cliente"###"Irá restar um crédito no valor de: "###"Ok"
			Else
				ConOut(STR0004 + SuperGetMV("MV_SIMB1") + " " + AllTrim(Transform(nNccGerada,PesqPict("SE1","E1_VALOR"))))
			EndIf
		Else
			If !lAutoExC
				MsgAlert(STR0105+STR0106)    //Não é possivel gerar uma Nota de Crédito com o valor restante ## VerIficar o parâmetro MV_USACRED
			Else
				ConOut(STR0105+STR0106)
				Help( " ", 1, "Help",, STR0105+STR0106, 1, 0 )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Habilita as teclas de atalho         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj7SetKeys(.T.)
			Return Nil
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao no final da venda (antes das gravacoes)  ³
//³ Envia como parametro o nTipo (1-orcamento  2-venda  3-pedido)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de chamada de Ponto de Entrada - especIfico Template            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 2 .AND. lReserva
   nParamTipo  := 3
Else
   nParamTipo  := nTipo
EndIf

If ExistTemplate("LJ7001") .AND. !lFtvdVer12
	lRet := ExecTemplate( "LJ7001", .F., .F., {nParamTipo, aDocDev, nDocSai,nOpc} )

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'P.E. LJ7001 - ' + If( lRet, 'S', 'N' ))
	EndIf
EndIf

If lRet .AND. ExistBlock("LJ7001") .AND. !lFtvdVer12
	lRet := ExecBlock( "LJ7001", .F., .F., {nParamTipo, aDocDev, nDocSai} )

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'P.E. LJ7001 - ' + If( lRet, 'S', 'N' ))
	EndIf
EndIf

If lRet .AND. ExistTemplate("FTVD7001") .AND. lFtvdVer12
	lRet := ExecTemplate( "FTVD7001", .F., .F., {nParamTipo, aDocDev, nDocSai,nOpc} )

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'P.E. FTVD7001 - ' + If( lRet, 'S', 'N' ))
	EndIf
EndIf

If lRet .AND. ExistBlock("FTVD7001") .AND. lFtvdVer12
	lRet := ExecBlock( "FTVD7001", .F., .F., {nParamTipo, aDocDev, nDocSai} )

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'P.E. FTVD7001 - ' + If( lRet, 'S', 'N' ))
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se eh finalizacao da venda e se eh um orcamento feito por       ³
//³ outra loja. Se afirmativo fecha a venda sem gerar financeiro.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. nOpc == 4
	If !Empty(SL1->L1_ORCRES) .AND. !Empty(SL1->L1_FILRES)
		lFinanceiro := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa reserva sem estoque                   ³
//³ Para eCommerce deve gerar SC se nao houver estoque    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. !lMVLJPDVPA .AND. ( (AllTrim(Str(SuperGetMv("MV_LJGERSC",,1))) $ "2|3") .OR. lECommerce )
	If ExistFunc("LA590GerSC")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz solicitacao de compras para itens da reserva sem estoque     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := LA590GerSC()
	Endif
Endif

//Erro nas validações
If !lRet

    //Habilita as teclas de atalho
    Lj7SetKeys(.T.)
    Return Nil
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica qual o tipo de gravacao devera ser feito                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HasTemplate("OTC") .AND. nOpc == 4
	lReserva := .F.
EndIf

If nTipo == 2 .AND. lReserva .AND. lFinanceiro

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Inicio Gravação - 2 / S / S')
	EndIf

	MaFisSave() //Salva os dados da venda atual

	LjGrvLog(cNumOrc,"VENDA COM ITEM DE ENTREGA")
	LjGrvLog(cNumOrc,"TEFs PENDENTES",aTefBKP)
	LjGrvLog(cNumOrc,"POSSUI TEF PENDENTE",lTemTefPend)
	LjGrvLog(cNumOrc,"FATOR DE RESERVA",nFatorRes)

	If Lj7PrepOrc( nOpc  	, nTipo		, nHandle	, lReserva	,;
			   	   lAtuData	)

		//Quando NFC-e com item de Reserva, existe controle de transacao, o CNPJ deve ser confirmado antes
		If (lEmitNFCe .OR. lIsPafNfce) .AND. !lAutoExec .And. !lEmiteNF
		 	aRetInfDocCli := {}
		 	aRetInfDocCli := LjxDCGC(Nil,Nil, , ,Lj7T_Total(2))
		EndIf

		bOldError := ErrorBlock( {|x| LjVerIfErro(x) } ) // muda code-block de erro

		Begin Sequence
			//Transforma o orcamento para pedido
			bProcessa := {|| Lj7Pedido(	aDadosCF	, nTipo		, nHandle		, @lTemTefPend	,;
									 	@aTefBKP	, nil		, @nFatorRes	, @nFatorVen	,;
									 	NIL			, NIL		, cEspDoc		, cDocFo		,;
									 	nOpc		, @cDocPed	, @cSeriePed	, @lTefManuPed	,;
										@lDscCupTef , @aBkpTable, lEmiteNF 		, @cTxtNFis 	,;
										@aDocReti	, nVlrAcrsFi, @cMsgErro )}

			CursorWait()
			lRetPedido := Eval(bProcessa)
			CursorArrow()

			LjGrvLog(cNumOrc,"Retorno da Lj7Pedido",lRetPedido)

			If lRetPedido
				//MOTIVO DE DESCONTO
				Lj7GrvMotDesc("", "", M->LQ_NUM , "")

				//Tratamento de LISTA DE PRESENTES
				If lLstPresAt .AND. lRetPedido
					nOpcProc := Lj843GrvMv(SL1->L1_NUM,cDocPed,cSeriePed)
				Endif
			Else
				cTextoErro := cMsgErro
				
				//Volta o backup da Filial corrente.
				//No caso de ter gerado pedido em outra filial e ocorrer algum erro no meio da transacao a variaveil "cFilAnt" pode estar
				//com o seu conteudo trocado e ai o sistema retornaria com a filial diferente da filial que estava "logado" no sistema
				cFilAnt := cBkpFilAnt
				SM0->( dbGoTo(nRecnoSM0) )

				//Como não há Controle de Transação em DBF, utilizamos a função LJRLBCKDBF para que os registros sejam restaurados
				If lMVLJPDVPA
					LjRlBckDBF(aBkpTable)
					aBkpTable := {}
				Else
					// Resgata Informacoes antes de executar o "DisarmTransaction"
					If Len(aDocReti) >= 5
						cDocCanc 	:= aDocReti[1] 	//Resgata o numero da Nota
						cSerieCanc 	:= aDocReti[2] 	//Resgata o numero de serie da Nota
						cPDV 		:= aDocReti[3]
						cOperador 	:= aDocReti[4]
						cLOGTEFBKP 	:= aDocReti[5]  //Faz BackUp da informacao do campo LG_LOGTEF antes de efetuar o RollBack
					EndIf
					
					RecLock("SLG",.F.)
					SLG->LG_LOGTEF := cLOGTEFBKP //Grava o campo LG_LOGTEF
					SLG->(MSUNLOCK())
				EndIf

				If (lEmitNFCe .Or. lIsPafNfce) .And. !Empty(cDocCanc) .And. !Empty(cSerieCanc)
					//Pega o numero da NOTA para ser cancelada
					LjxDNota(cSerieCanc,3,.F.,1,@aNotaCanc)
					cDocCanc := aNotaCanc[1][2]

					If !lEmiteNF
						cModDoc := "65"
					Else
						cModDoc := "55"
					EndIf

					//Inclui na SLX a nota que ser enviada para cancelamento
					Lj7SLXDocE(	cModDoc		, cDocCanc	, cSerieCanc	, cPDV	,; 
								cOperador	, Nil		, Nil 			, Nil	,;
								cNumOrc		)
				EndIf
			EndIf

		Recover

			CursorArrow()
			SL1->(DbSkip(0)) //Executa o DbSkip(0) apenas para atualizar os dados carregados na tabela SL1, evitando assim a "leitura suja"

		End Sequence

		ErrorBlock( bOldError ) // Restaura rotina de erro anterior

		If !lRetPedido
		    If !lEmiteNF .AND. !lEmitNFCe .And. !lIsPafNfce
			    nRet := IfPegPDV( nHdlECF, @cPdv )
				If cPaisLoc <> "ARG"
					nRet := IfPegCupom( nHdlECF, @cDoc )
					cSerie 	:= LjGetStation("LG_SERIE")
				Else
					nRet :=	Lj7PegCupArg(nHdlECF, @cDoc )
				   cSerie   := Lj7SerArg()
				EndIf

			//Nota - A numeracao da Nota/Serie sera atribuida pela funcao LJGRVTUDO()
			Else
			    cPdv    := ""
			    cDoc    := ""
				cSerie  := ""
			EndIf

			lmsgTEF := .F.

			If cTipTef == TEF_CLISITEF
				For nI := 1 To Len( aPgtosSint )
					If AllTrim( aPgtosSint[nI][1] ) $ _FORMATEF
						lmsgTEF := .T.
					EndIf
				Next nI
			Else
				For nI := 1 to Len( aPgtos )
					If Alltrim( aPgtos[nI][3] ) $ _FORMATEF
						lmsgTEF := .T.
					EndIf
				Next nI
			EndIf

			If lTefManuPed
				Lj7CancVenda(STR0082, 	cDoc, 	cSerie, 	cPdv, .F., .F., Nil, cTextoErro, Nil, Nil, Nil, @aTefBKP, @lTemTEFPend)//"Erro na Gravação da Venda!"
			EndIf

		Else

			LjReAbreVA(nTipo, nOpc)
			If nOpc == 3
				While (GetSX8Len() > nSaveSx8)
					ConfirmSx8()
				End
			EndIf

			//Ajusta a variavel para indicar que finalizou a venda e chamar o ponto de entrada abaixo
			lSair	   := .T.
			lFinalizou := .T.
			nValSubTot := 0

			// Imprime
			If !Empty(cTxtNFis)
				nRet := 1
				While nRet <> 0
					nRet := INFTexto(cTxtNFis)

					If nRet <> 0
						If !MsgYesNo("Não foi possível imprimir o comprovante, tentar novamente?")
							nRet := 0
						EndIf
					EndIf
				End
			EndIf
		EndIf
	EndIf

	If !lRetPedido
		MaFisRestore() //Restaura os dados da venda atual, devido erro no processamento de gravacao. Para assim, permitir que a venda possa ser finalizada novamente.
	EndIf


ElseIf nTipo == 1

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Inicio Gravação - 1')
	EndIf

    //Limpa processo de Fidelização
    If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
        If Lj7FidDesc() > 0 
            LjxjMsgErr(STR0238, STR0239, STR0240)   //"O desconto da fidelização será desconsiderado, ao salvar como orçamento."   //"Ao finalizar a venda a regra de fidelização será aplicada novamente."     //"TOTVS Bonificações"
        EndIf
        Lj7FidLimp(.T.)
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao informou midia e for obrigatorio chama funcao para informar   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMv("MV_LJRGMID",,0) == 2 .AND. LjxValMid()
		While Empty(M->LQ_MIDIA)
			M->LQ_MIDIA:= LjxGetMid(M->LQ_MIDIA)  // Midia
		End
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salvar como orcamento                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Lj7PrepOrc( nOpc		, nTipo		, Nil		, Nil		,;
				   lAtuData , @lDefPagto,,,,,, lAlteraPrc )
		If !lAutoExC
    		lTemGeraNOrc := LjTemGeraNOrc()
 		Else
    		lTemGeraNOrc := .F.
    	EndIf

    	//Apresenta mensagem com numero de orcamento gerado quando utiliza rotina diferenciada para geracao do numero
    	If LjNfPafEcf(SM0->M0_CGC)
			If cPaisLoc == "BRA" .AND. lTemGeraNOrc
				If lAutoExC
					Conout(STR0109 + M->LQ_NUMORC)
				Else
     				LjMsgRun( STR0109 + M->LQ_NUMORC ,, { || Sleep(2000)} ) //"Gerado Orcamento "
				EndIf
			EndIf
		Else
			If LJAnalisaLeg(37)[1] .AND. lTemGeraNOrc .AND. !lAutoExC
				If lAutoExC
					Conout(STR0109 + M->LQ_NUMORC)
				Else
	   				LjMsgRun( STR0109 + M->LQ_NUM ,, { || Sleep(2000)} ) //"Gerado Orcamento "
				Endif
			EndIf
		EndIf
		LjReAbreVA(nTipo, nOpc)
		If nOpc == 3
			While (GetSX8Len() > nSaveSx8)
				ConfirmSx8()
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajusta a variavel para indicar que finalizou a venda e chamar o ponto de entrada abaixo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lSair	   := .T.
		lFinalizou := .T.
		nValSubTot := 0
	EndIf
ElseIf nTipo == 2

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Inicio Gravação - 2')
	EndIf

	LjGrvLog(cNumOrc,"VENDA DE ITENS RETIRA")
	LjGrvLog(cNumOrc,"TEFs PENDENTES",aTefBKP)
	LjGrvLog(cNumOrc,"POSSUI TEF PENDENTE",lTemTefPend)
	LjGrvLog(cNumOrc,"FATOR DE RESERVA",nFatorRes)

	If !lFtvdVer12 .OR. (LJ7VldCond(M->LQ_CONDPG, @cDescCondPg, @oDescCondPg, @oPgtos, Nil, nOpc, @nVlrAcrsFi) .AND. lFtvdVer12)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salvar como venda                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFtvdVer12
			nTotICM := 0
		EndIf

		If (lEmitNFCe .Or. lIsPafNfce) .AND. !lAutoExec .And. !lEmiteNF .And. !lRecebe
		 	aRetInfDocCli:= {}
			aRetInfDocCli:= LjxDCGC(Nil,Nil, , ,Lj7T_Total(2))
			cCNPJ		:= aRetInfDocCli[1]
		EndIf
		
		//Caso seja obrigatorio informar o CGC e o usuario pressione em cancelar, desta forma a finalização da venda sera encerrada
		If ExistFunc("LjGetlCanc")
			//Pego o retorno da variavel statica lCgcCancel que esta presente no lojxfund
			lRet := !LjGetlCanc()

			//Restauro o conteudo da variavel Statica lCgcCancel que esta presente no lojxfund
			LjReslCanc()
		EndIf

		If lRet

			If MaFisFound("NF")
				//Guarda estado atual dos valores da MatxFis, caso ocrra algum erro na gravacao da venda, os valores da MaxFis precisam ser restaurados pela funcao MaFisRestore
				MaFisSave()
				lMaFisSave := .T.
			EndIf

			lRet := Lj7PrepOrc( nOpc  	, nTipo	, Nil			, Nil		,;
							lAtuData	, Nil	, @cNomeCli		, @cCGCCli	,;
							@lNfManual	,cEspDoc, @nDescontFi	, Nil		,;
							@nTotICM)	;
							.AND.;
					Lj7GrvVenda(lFinanceiro , NIL		, aDadosCF	, nHandle 		,;
							lEmiteNF    , nOpc		, nTipo		, @lTemTefPend	,;
							@aTefBKP 	, Nil    	, cLQFrete	, lAutoExC		,;
							nVlrAcrsFi	, cCgcCli	, cNomeCli	, lNfManual		,;
							lImpReserva , nFatorRes	, nFatorVen	, Nil			,;
							cEspDoc		, cDocFo 	, Nil 		, nDescontFi	,;
							@lDscCupTef	, nTotICM 	, aDadosCNeg, nArredondar 	,;
							@lErroNFCe	, Nil		, cTipoCli  , nSaveSx8		,;
							Nil			, @lErroNFe	, @cMsgErro	, Nil			,;
							Nil			, @lOnlyServ )
		EndIf
		
		If lRet

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento de lista de presentes  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLstPresAt .And. SuperGetMv("MV_LJGRVON",,.F.)
				nOpcProc := Lj843GrvMv(SL1->L1_NUM)
			Endif

			lTemGeraNOrc := LjTemGeraNOrc()

			If LjNfPafEcf(SM0->M0_CGC)
				If nOpc == 2 .AND. cPaisLoc == "BRA" .AND. lTemGeraNOrc
					If lAutoExC
						Conout(STR0109 + M->LQ_NUMORC)
					Else
						LjMsgRun( STR0109 + M->LQ_NUMORC ,, { || Sleep(2000)} ) //"Gerado Orcamento "
					EndIf
				EndIf
			Else
				If nOpc == 2 .AND. LJAnalisaLeg(37)[1] .AND. lTemGeraNOrc
					If lAutoExC
						Conout(STR0109 + M->LQ_NUM)
					Else
						LjMsgRun( STR0109 + M->LQ_NUM ,, { || Sleep(2000)} ) //"Gerado Orcamento "
					Endif
				EndIf
			EndIf
			LjReAbreVA(nTipo, nOpc)
			If nOpc == 3 .OR. (nOpc == 4 .AND. lFtvdVer12)
				While (GetSX8Len() > nSaveSx8)
					ConfirmSx8()
				End
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ajusta a variavel para indicar que finalizou a venda e chamar o ponto de entrada abaixo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lSair	   := .T.
			lFinalizou := .T.
			nValSubTot := 0
		Else
			//------------------------------------------------------
			// Tratamento quando ocorrer algum problema na gravacao
			//------------------------------------------------------
			If (lEmitNFCe .AND. !lUseSAT) .Or. lIsPafNfce //Se utiliza NFC-e
				//-------------------------------------------------------------------------------
				// Resgata Informacoes do DOC e SERIE a ser cancelado devido ocorrencia de erro
				//-------------------------------------------------------------------------------
				cDocCanc 	:= SL1->L1_DOC 		//Resgata o numero do Documento a ser cancelado
				cSerieCanc 	:= SL1->L1_SERIE 	//Resgata o numero de Serie do Documento a ser cancelado
				cPDV 		:= SL1->L1_PDV
				cOperador 	:= SL1->L1_OPERADO

				//Inclui o DOCUMENTO na SLX para ser cancelado
				If !Empty(cDocCanc) .And. !Empty(cSerieCanc)
					If lErroNFCe .Or. !lEmiteNF
						cModDoc := "65"
					ElseIf lErroNFe .Or. lEmiteNF
						cModDoc := "55"
					EndIf

					//Inclui na SLX a nota que ser enviada para Inutilização
					Lj7SLXDocE(	cModDoc		, cDocCanc	, cSerieCanc	, cPDV	,;
								cOperador	, Nil		, cMsgErro		, Nil	,;
								cNumOrc		)

					If lInutPDV
						// -- Inicio a inutilização / Cancelamento enviando para o TSS direto pelo PDV
						oLOJCNFCE := LOJCNFCE():NEW()
						oLOJCNFCE:LjCancInut(SL1->(L1_SERIE+L1_DOC))
						If oLOJCNFCE:aResultMetodo[1]
							LjGrvLog(SL1->L1_NUM,"Inutilização / Cancelamento Realizado direto pelo PDV DOC:" + SL1->L1_DOC + " Serie: " + SL1->L1_SERIE)
						Else
							LjGrvLog(SL1->L1_NUM,"Não foi possivel Inutiliza / Cancelar a Nota direto pelo PDV, a Inutilização / Cancelamento sera realizada pelo Job de cancelamentos.")
							LjGrvLog(SL1->L1_NUM,"Motivo: " + oLOJCNFCE:aResultTSS[3])
						EndIf 
					EndIf 

					//Limpa o DOC e Serie para que fique com status de orcamento em aberto e assim permita finalizar a venda novamente
					If RecLock("SL1",.F.)
						Replace SL1->L1_DOC with ""
						Replace SL1->L1_SERIE with ""
						Replace SL1->L1_KEYNFCE with ""
						Replace SL1->L1_SITUA with ""

						SL1->( MsUnLock() )
					Else
						LjGrvLog( cNumOrc, "Falha ao alocar o registro R_E_C_N_O_", SL1->(Recno()) )
					EndIf
					
					//"Devido problema na finalização da venda, o Documento/Série: " ### " foi enviado para cancelamento." + CTRL +CTRL + "Favor, reter o comprovante caso ele tenha sido impresso e, em seguida tente finalizar a venda novamente."
					MsgAlert(STR0203 + cDocCanc + " / " + cSerieCanc + STR0204 + CTRL +CTRL + STR0205)
				EndIf

			EndIf
		EndIf
	EndIf
EndIf

LjGrvLog(cNumOrc,"Finalizando a funcao LJ7RunGrv - Sair",lSair)

//
// Transmissão de NF-e pelo SIGALOJA
// Se for Nota Fiscal(L1_IMPNF = .T.), verifica se eh NF-e e esta apta para transmissao
//

If lFinalizou .AND. SL1->L1_IMPNF .AND. xMvLjTxNFe > 0 .AND. !lOnlyServ
	LjAutoNFe( SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_CLIENTE, SL1->L1_LOJA )
EndIf

/* Trecho comentado, ele foi alterado no changeset 638342 - 
	Ponto de Entrada sendo chamado em local indevido e de forma incorreta
	Causando os erros das issues DVARLOJ4-9585 e DVARLOJ4-9628
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao LJ7002 para Pontuacao no processo de Fidelizacao       ³
//³ Envia como parametro o nTipo (1-orcamento  2-venda  3-pedido)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFinalizou .AND. ExistBlock("LJ7002")  .AND. !lFtvdVer12
	If (nTipo == 2) .AND.(lReserva)
		ExecBlock( "LJ7002", .F., .F., { 3 } )
	Else
		ExecBlock( "LJ7002", .F., .F., { nTipo } )
	EndIf
	LjGrvLog(cNumOrc,"Executou o P.E LJ7002")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao FTVD7002 para Pontuacao no processo de Fidelizacao       ³
//³ Envia como parametro o nTipo (1-orcamento  2-venda  3-pedido)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFinalizou .AND. ExistBlock("FTVD7002") .AND. lFtvdVer12
	If (nTipo == 2) .AND.(lReserva)
		ExecBlock( "FTVD7002", .F., .F., { 3 } )
	Else
		ExecBlock( "FTVD7002", .F., .F., { nTipo } )
	EndIf
EndIf
*/

If lFinalizou .AND. nTipo == 2

	//Ponto de entrada para validar o cliente, se deve ou nao pontuar
	If ExistBlock("LJ7042") .AND. !lFtvdVer12
		lLJ7042	:=	ExecBlock( "LJ7042", .F., .F., { M->LQ_CLIENTE,M->LQ_LOJA } )
		If ValType( lLJ7042 ) <> "L"
			lLJ7042 := .T.
		EndIf
	EndIf

	If ExistBlock("FTVD7042") .AND. lFtvdVer12
		lFTVD7042	:=	ExecBlock( "FTVD7042", .F., .F., { M->LQ_CLIENTE,M->LQ_LOJA } )
		If ValType( lFTVD7042 ) <> "L"
			lFTVD7042 := .T.
		EndIf
	EndIf

    //VALE COMPRA - Se o sistema estiver configurado para trabalhar com Vale Compra,
    //faz a chamada das rotinas para somar pontos e também verIfica se o cliente tem direito a resgate de Vale.
	If CrdxInt() .AND. lUsaFd .AND. (M->LQ_CLIENTE+M->LQ_LOJA <> cMV_CLIPAD+cMV_LOJAPAD )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o retorno do ponto de entrada LJ7042 for true, soma os pontos ³
		//³da venda para o cliente.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	(lLJ7042 .AND. !lFtvdVer12) .OR. (lFTVD7042 .OR. !lFtvdVer12)
			For nX := 1 to Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					cGrupoProd :=  Posicione("SB1",1,xFilial("SB1") + aCols[nX][nPosProd],"SB1->B1_GRUPO")
					AADD ( aProdCri, { aCols[nX][nPosProd], cGrupoProd , aCols[nX][nPosVlItem] , aCols[nX][nPosQtd]} )
				EndIf
			Next nX

			For nX := 1 to Len( aPremio )
				If aPremio[nX][2] == "3" .AND. aPremio[nX][5] > 0
					cGrupoProd :=  Posicione("SB1",1,xFilial("SB1") + aPremio[nX][3],"SB1->B1_GRUPO")
					AADD ( aProdCri, { aPremio[nX][3], cGrupoProd , aPremio[nX][5] } )
				EndIf
	     	Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para pagamento com vale-compra deve ser calcula pontos    ³
			//³somente sobre a dIferença. se o pagamento for integral com³
			//³vale compra nao deve pontuar.                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to Len( aPgtos )
				If Alltrim( aPgtos[nX][3] ) $ cMvCrdForm
					cPgVc := "1"
				Else
					nPag	+= aPgtos[nX][2]
				EndIf
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a chamada da funcao para calcular os pontos referente a venda.³
			//³A regra de pontuacao esta na tabela MAT.                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsafdOff

				If Len(aPremio) > 0
					oSWB := WSFRTCRDBX():New()
					oSWB :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/FRTCRDBX.apw"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cria o array dentro do metodo ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oSWB:oWSACRDVALEC:oWSVERARRBX 						:= FRTCRDBX_ARRAYOFWSCRDVABX():New()
					oSWB:oWSACRDVALEC:OWSVerArrBX:oWSWSCRDVABX 			:= Array( Len(aPremio) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Antes de chamar o metodo, atribui os valores ³
					//³as propriedades (passagem de parametros)     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 To Len(aPremio)

						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX] := FRTCRDBX_WSCRDVABX():New()

						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:NCRDPRE1			:=	aPremio[nX][1]
						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:cCRDPRE2			:=	aPremio[nX][2]
						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:cCRDPRE3			:=	aPremio[nX][3]
						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:cCRDPRE4			:=	aPremio[nX][4]
						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:nCRDPRE5			:=	aPremio[nX][5]
						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:nCRDPRE6			:=	aPremio[nX][6]
						oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:nCRDPRE7			:=	aPremio[nX][7]
						nPontos += aPremio[nX][1]
					Next nX

					If len(aLibera) > 0
						cMotivo := aLibera[nX][3]
					EndIf

					oSWB:FRTCRD02( , M->LQ_CLIENTE, M->LQ_LOJA , nPontos, cDoc, "", /*cMotivo*/ "")
				EndIf

			Else
				If	Crd240_002(	"1"				,;	//01 Tipo da operacao 1 = Venda
								M->LQ_CLIENTE	,; 	//02 Codigo do cliente
								M->LQ_LOJA		,;	//03 Loja
								aProdCri		,;	//04 Produtos da venda
							    nPag			,;	//05 Valor pago
							    SL1->L1_DOC		,;	//06 Numero do documento
							    SL1->L1_SERIE	,;	//06 Serie
							    NIL				,; 	//07 Numero da nota original (Troca/Exclusao)
								NIL				,; 	//08 Serie da nota original  (Troca/Exclusao)
								NIL				,; 	//09 Origem (Se LOJA =NULL OU TMK)
								.T.				,; 	//10 Grava pontos no MAX
								nTotPontos		,;	//11 Total de pontos
								cPgVc			,; 	//12 Indica se e pagamento com vale compra
								.F.				,; 	//13 Exclui os pontos gerados pela Troca / Devolucao
								aPremio)			//14 Indica se foi resgatado




					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava na tabela MAZ quem liberou o resgate.³
					//³Status = 1 -> Liberacao no resgate         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len( aLibera ) > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³PARAMETROS:                         ³
						//³Supervisor, Nro Vale, Motivo, Status³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nX := 1 To Len( aLibera )
							Crd240GrvMaz( aLibera[nX][1], aLibera[nX][2], aLibera[nX][3], "1" )
						Next nX
					EndIf

					If Len( aPremio ) > 0

						For nX := 1 to Len( aPremio )
							nUsado += aPremio[nX][1]
		           		Next nX

						If	Crd240FinRes(	M->LQ_CLIENTE	,;	//01 Codigo do cliente
					 						M->LQ_LOJA		,;	//02 Loja do cliente
					 						aPremio			,;	//03 Array com os premios (altera o status do vale-compra e grava may)
					 						nUsado			,;	//04 Pontos utilizados para resgatar os premios
					 						SL1->L1_DOC		,; 	//05 Nro do documento
					 						SL1->L1_SERIE)		//06 Serie do documento
					 	EndIf
					EndIf
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera o status do vale-compra para resgatado e grava os produtos³
			//³resgatados na tabela MAY                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aPremio ) > 0
				CRD240BxPr( M->LQ_CLIENTE	,;	//01 Codigo do cliente
							M->LQ_LOJA		,;	//02 Loja do cliente
							aPremio			,;	//03 Array com os premios (altera o status do vale-compra e grava may)
							SL1->L1_DOC		,;	//04 Nro do documento
							SL1->L1_SERIE)  	//05 Serie do documento
			EndIf
		EndIf
		Lj7AtuPremio(.T.)
	EndIf

    //Atualiza a ultima compra no cadastro do cliente
    //So atualiza se nao for cliente padrão para evitar concorrencia do SA1
    SA1->( dbSetOrder(1) )
    If AllTrim(M->LQ_CLIENTE) + AllTrim(M->LQ_LOJA) <> AllTrim(SuperGetMv("MV_CLIPAD",,"")) + AllTrim(SuperGetMv("MV_LOJAPAD",,""))

        If SA1->(dbSeek(xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA))
            RecLock("SA1", .F.)
            SA1->A1_ULTCOM := Iif(!Empty(SL1->L1_EMISNF), SL1->L1_EMISNF, SA1->A1_ULTCOM)
            SA1->A1_PRICOM := Iif(!Empty(SA1->A1_PRICOM), SA1->A1_PRICOM, SL1->L1_EMISNF)
            SA1->A1_MCOMPRA := Iif(SL1->L1_VLRTOT > SA1->A1_MCOMPRA, SL1->L1_VLRTOT, SA1->A1_MCOMPRA)
            SA1->(MsUnlock())
        EndIf
    EndIf

    //Chamada envio de e-mail para parceiros
    If ExistBlock("EmailParceiro")
        aParcEnviar	:= Lj7GetParceiros()
        ExecBlock( "EmailParceiro", .F., .F., { cNumorc , aParcEnviar } )
    EndIf

    //Finaliza processo de Fidelização
    If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
        Lj7FidFin( SL1->L1_ESTACAO, SL1->L1_FILIAL + SL1->L1_NUM                                                , Lj7T_Quant(2), SL1->L1_VLRTOT, M->LQ_NOMCLI ,;
                   M->LQ_NOMVEND  , IIF(SL1->L1_TIPO == "P", cDocPed + cSeriePed, SL1->L1_DOC + SL1->L1_SERIE)  )

    EndIf        
EndIf

LjGrvLog(cNumOrc,"VENDA FOI FINALIZADA ? ",lFinalizou)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao no final da venda (apos as gravacoes)    ³
//³ Envia como parametro o nTipo (1-orcamento  2-venda  3-pedido)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de chamada de Ponto de Entrada - especIfico Template            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFinalizou .AND. ExistTemplate("LJ7002") .AND. !lFtvdVer12
	ExecTemplate( "LJ7002", .F., .F., { nParamTipo, aDocDev } )
EndIf
If lFinalizou .AND. ExistBlock("LJ7002") .AND. !lFtvdVer12
	ExecBlock( "LJ7002", .F., .F., { nParamTipo, aDocDev, 1 } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao no final da venda (apos as gravacoes)    ³
//³ Envia como parametro o nTipo (1-orcamento  2-venda  3-pedido)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de chamada de Ponto de Entrada - especIfico Template            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFinalizou .AND. ExistTemplate("FTVD7002") .AND. lFtvdVer12
	ExecTemplate( "FTVD7002", .F., .F., { nParamTipo, aDocDev } )
EndIf
If lFinalizou .AND. ExistBlock("FTVD7002") .AND. lFtvdVer12
	ExecBlock( "FTVD7002", .F., .F., { nParamTipo, aDocDev } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Se usar os modulos de gestao de concessionarias chama a funcao que grava os relacionamentos.  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_VEICULO") == "S" .AND. !Empty(SL1->L1_VEICTIP) .AND. !Empty(SL1->L1_VEIPESQ)
    FG_DEVLOJA(SL1->L1_VEICTIP,SL1->L1_VEIPESQ, SL1->L1_DOC, SL1->L1_SERIE)
Endif

If lFinalizou .AND. nTipo == 2 .AND. !lRecebe .AND. !lReserva
	//Envia os dados da venda para integração
	If lAmbOff
		Lj7AtuInte()
	EndIf
	LjProIntVe()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do Status TUDOOK, apos passar pelo PE, para gravacao de campos especIficos do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLog1 .AND. lLog4 .AND. nHandle >= 0
	nSize    := FSeek( nHandle, 0, 2 )
	cRBuffer := Space( nSize )

	FSeek( nHandle, 0, 0 )
	FRead( nHandle, @cRBuffer, nSize )

	cRBuffer := Encript( cRBuffer, 1 )
	If !("#TUDOOK#" $ cRBuffer)
		cRBuffer := cRBuffer + "#TUDOOK#"
	EndIf

	FSeek( nHandle, 0, 0 )
	FWrite( nHandle, Encript( cRBuffer, 0 ) )
EndIf

If !Empty(LOG_TEF)
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'LOJ701C'+Replicate('-',40))
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Final Gravação - ' + If( lFinalizou, 'S', 'N' ))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a funcao fiscal de finalização de Calculo              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisFound("NF")
	If lMaFisSave
		//Restaura o estado anterior da MatxFis, para esvaziar o array de backup da MatxFis
		MaFisRestore()
	EndIf

	If lFinalizou
		MaFisEnd()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera o Registro do SE1   						             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe .AND. !(nModulo == 12 .AND. lMVLJPDVPA)   //Quando Recebimento de titulo via WebService(VA-PDV), nao realiza o Lock do registro
	If Len(aTitulo) > 0
		For nI := 1 To Len(aTitulo)
			UnLockByName(aTitulo[nI][21],.T.,.F.,.T. )
		Next nI
	EndIf
EndIf

// Habilita as teclas de atalho
Lj7SetKeys(.T.)

LjGrvLog(cNumOrc,"Fim da funcao LJ7RunGrv - Sair",lSair)

//Imprime o Relatorio de Impressao de Recibo
If lIMPLJRE .And. lFtvdVer12 .And. !lRecebe .AND. lFinalizou
	//Verifica se eh pedido (Tem reserva)
	If AllTrim(SL1->L1_TIPO) == "P" .AND. Empty(AllTrim(SL1->L1_FILRES)) .AND. Empty(AllTrim(SL1->L1_ORCRES))
		cNumDoc 	:= SL1->L1_DOCPED
		cSerie  	:= SL1->L1_SERPED

		If Alltrim(Upper(cMvLjPref)) == "SF2->F2_SERIE"
			cPrefixo	:= If(Empty(SL1->L1_SERIE), SL1->L1_SERPED, SL1->L1_SERIE)
		Else
			cPrefixo	:= &(cMvLjPref)
		Endif

		cNumE1 := LJ7NumTit()
	Else
		cNumDoc 	:= SL1->L1_DOC
		cSerie  	:= SL1->L1_SERIE
		cPrefixo	:= &(cMvLjPref)
		cNumE1 := LJ7NumTit()
	EndIf

	DbSelectArea("SE1")
	DbSetOrder(1)

	If DbSeek(xFilial("SE1") + cPrefixo +  cNumDoc )

		While SE1->(!EOF()) 						.AND.;
				SE1->E1_FILIAL 	== 	xFilial("SE1")	.AND.;
				SE1->E1_PREFIXO	== 	cPrefixo 		.AND.;
				SE1->E1_NUM		== 	cNumDoc

				aadd(aTitBx, {	SE1->E1_NUM				,;	//01-Nro do Titulo
								SE1->E1_PREFIXO			,;	//02-Prefixo
				       			SE1->E1_PARCELA			,;	//03-Parcela
				       			SE1->E1_TIPO			,;	//04-Tipo
				       			M->LQ_CLIENTE			,;	//5-Cliente
				       			M->LQ_LOJA				,;	//6-Loja
				       			Dtos(SE1->E1_EMISSAO)	,;	//7-Emissao
				       			Dtos(SE1->E1_VENCTO)	,;	//8-Vencimento
				       			SE1->E1_VLCRUZ			,;	//9-Valor Original
						       	SE1->E1_SALDO			,;	//10-Saldo
						       	SE1->E1_MULTA			,;	//11-Multa
						       	SE1->E1_JUROS			,;	//12-Juros
						       	SE1->E1_DESCONT			,;	//13-Desconto
						       	SE1->E1_VALLIQ			})	//14-Valor Recebido
			SE1->(DbSkip())
		End

		For nI:=1 to Len(aPgtos)

			If Alltrim(aPgtos[nI][3]) ==  "CH"
				aadd(aFormPg	,{	aPgtos[nI][3]		,;	//Forma de Pagamento
									aPgtos[nI][2]		,;	//Valor
									Dtos(aPgtos[nI][1])	,;	//Data do Pagamento
									aPgtos[nI][4][7]	,;	//Numero do Cheque
									aPgtos[nI][4][4]	,;	//Banco
									aPgtos[nI][4][5]	,;	//Agencia
									aPgtos[nI][4][6]	,;	//Conta Corrente
									""					})	//Nome do Terceiro
			Else
				aadd(aFormPg	,{	aPgtos[nI][3]		,;	//Forma de Pagamento
									aPgtos[nI][2]		,;	//Valor
									Dtos(aPgtos[nI][1])	,;	//Data do Pagamento
									""					,;	//Numero do Cheque
									""					,;	//Banco
									""					,;	//Agencia
									""					,;	//Conta Corrente
									""					})	//Nome do Terceiro
			Endif
		Next

		If lULOJRREC
			//Fonte não será mais padrao mas sim um RDMake padrão.
			U_LOJRRecibo(SE1->E1_CLIENTE, SE1->E1_LOJA, aTitBx, aFormPg)
		Else
			LOJRREC(SE1->E1_CLIENTE, SE1->E1_LOJA, aTitBx, aFormPg)
		EndIf

	Else
		ConOut(STR0207 + cPrefixo + "/" + cNumDoc + STR0208)	//"Documento "###" não encontrado na tabela SE1."
	Endif
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ7GrvOrc ºAutor  ³Vendas Clientes     º Data ³  17/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a gravacao do 'pacote' de arquivos para a rotina de     º±±
±±º          ³venda assistida                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := Lj7GrvOrc( ExpA2, ExpA3 [, ExpA4, ExpL1, ExpL2,    º±±
±±º          ³                    ExpC1 ] )                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA2 - Array com as informacoes do SL1 no formato          º±±
±±º          ³        [1] - Nome do campo                                 º±±
±±º          ³        [2] - Valor a ser gravado                           º±±
±±º          ³                                                            º±±
±±º          ³ExpA3 - Array com as informacoes do SL2 no formato          º±±
±±º          ³        [1] - Nome do campo                                 º±±
±±º          ³        [2] - Valor a ser gravado                           º±±
±±º          ³                                                            º±±
±±º          ³ExpA4 - Array com as informacoes do SL4 no formato          º±±
±±º          ³        [1] - Nome do campo                                 º±±
±±º          ³        [2] - Valor a ser gravado                           º±±
±±º          ³                                                            º±±
±±º          ³ExpL1 - Variavel que indica se a rotina ira ter tratamento  º±±
±±º          ³        de tela, isto e, se nao sera uma rotina automatica  º±±
±±º          ³        .T. - Mostra as mesnagens na tela                   º±±
±±º          ³        .F. - Nao mostra mensagens na tela                  º±±
±±º          ³                                                            º±±
±±º          ³ExpL2 - Indica se eh para gerar um numero de orcamento ou   º±±
±±º          ³        nao. (valor DEFAULT .F.). Se esse parametro for .F. º±±
±±º          ³        o campo L1_NUM devera ser informado                 º±±
±±º          ³                                                            º±±
±±º          ³ExpC1 - Codigo da filial onde sera gravado o orcamento. Se  º±±
±±º          ³        nao for informado sera grava na filial local        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array contendo:                                     º±±
±±º          ³        [1] - T / F. Indica se fez ou nao a gravacao        º±±
±±º          ³        [2] - Numero do orcamento gerado                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ7GrvOrc( aSL1		, aSL2		,	aSL4,	lTela,;
					lGeraNumOrc	, cFilOrc	, 	lJob,   lAlteraPrc )

Local aRet 			:= { .F., Space(TamSx3("L1_NUM")[1]) }		// Array com retorno da funcao, se gerou o SL e num do orcamento
Local nX			:= 0										// Variavel auxiliar do for
Local nPos 			:= 0										// Posicao dos campos no array aSL
Local nCont 		:= 0										// Contador dos itens do SL4
Local cNumOrc		:= Space(TamSX3("L1_NUM")[1])				// Numero do orcamento L1_NUM
Local cFilAux		:= ""										// Grava a filial anterior, utiliza como auxiliar
Local lOperacao		:= .T.										// Variavel que indicara se eh uma inclusao ou exclusao de um orcamento
Local lContinua		:= .T.										// Valida se continua a gravacao do SL
Local lRet 			:= .F.										// Variavel logica de retorno da funcao utilizada no array aRet
Local lAlteraFil 	:= (cFilOrc<>Nil)							// VerIfica se tem filial dIferente para gravacao o orcamento
Local nTent 		:= 0										// Tentativas para gravacao do SL1 com a numeracao do orcamento
Local cMay			:= ""										// Conteudo da filial e orcamento para nao haver duplicacao
Local nSaveSx8 		:= GetSx8Len()								// Numeracao do SX8
Local lVendaPerdida	:= SuperGetMV ("MV_LJMVPE",,.F.)			// Habilita gravacao de movimento de venda perdida
Local oMoviVp 	   												// Objeto do movimento de venda perdida
Local lNfPafEcf	  	:= LjNfPafEcf(SM0->M0_CGC)					//Se habilitado CNPJ PAF-ECF
Local nPosPafMd5	:= 0										// Posicao do PAFMD5, somente possui conteudo quando armazenado no BD
Local lGrvLogDAV	:= lNfPafEcf .And. !SuperGetMv("MV_LJPRVEN",,.T.)
Local aAreaSM0		:= SM0->(GetArea()) 						//Guarda a area da SM0
Local lIntegDef		:= Lj701GtInD() //Venda Origem Integração
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - 
//LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, 
//pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cPdv          := ""										// Numero do Pdv
Local cOperador     := ""										// Operador do caixa
Local nPosPDV		:= 0

Default aSL4 		:= {}										// Array do SL4
Default lTela		:= .T.										// Valida se existe tela na transacao
Default lGeraNumOrc	:= .F.										// VerIfica se eh para gerar numero do orcamento
Default cFilOrc		:= xFilial("SL1")							// Filial do orcamento
Default lJob		:= .F.
Default lAlteraPrc 	:= .F.                                     // Será true quando for utilizada para alterar apenas as parcelas aSL4


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for informada a filial para gravacao do orcamento troca o ³
//³ valor de cFilAnt para que os semaforos possam pegar as       ³
//³ informacoes da filial correta                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAlteraFil
	cFilAux := cFilAnt
	cFilAnt := cFilOrc
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acerta o campo filial dos arrays                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos 	:= aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_FILIAL" } )

If nPos == 0
	aAdd( aSL1, { "L1_FILIAL", cFilOrc } )
Else
	aSL1[nPos][2] := cFilOrc
EndIf

For nX := 1 to Len( aSL2 )
	nPos 	:= aScan( aSL2[nX], {|x| Alltrim( Upper( x[1] ) ) == "L2_FILIAL" } )
	If nPos == 0
		aAdd( aSL2[nX], { "L2_FILIAL", cFilOrc } )
	Else
		aSL2[nX][nPos][2] := cFilOrc
	EndIf
Next nX

For nX := 1 to Len( aSL4 )
	nPos 	:= aScan( aSL4[nX], {|x| Alltrim( Upper( x[1] ) ) == "L4_FILIAL" } )
	If nPos == 0
		aAdd( aSL4[nX], { "L4_FILIAL", cFilOrc } )
	Else
		aSL4[nX][nPos][2] := cFilOrc
	EndIf

Next nX

// preciso dessa informações pois em queda do sistema nao esta gravando essa informação.
If Empty(M->LQ_PDV) 
	cPdv := LjGetStation("LG_PDV")
Else
	cPdv := M->LQ_PDV
EndIf
If !lJob
	cOperador := xNumCaixa()
Else
	cOperador := M->LQ_OPERADO
EndIf		 

If !ExistFunc("LjGetKeyPs") .OR. ( ExistFunc("LjGetKeyPs") .AND. LjGetKeyPs() == "F5" )
	nPosPDV := Ascan(aSL1, {|x| AllTrim(upper(x[1])) == "L1_PDV"}) 
	If nPosPDV == 0
		aAdd( aSL1, { "L1_PDV", cPdv } )
	ElseIf (nPosPDV > 0 .And. Empty(Alltrim(aSL1[nPosPDV][2])))
		aSL1[nPosPDV][2] := cPdv
	EndIf

	If !Ascan(aSL1, {|x| AllTrim(upper(x[1])) == "L1_OPERADO"}) > 0
		aAdd( aSL1, { "L1_OPERADO", cOperador } )
	EndIf
EndIf
//
//Integracao Mensagem Unica adiciona informacoes da integracao
If lIntegDef
	aAdd( aSL1, { "L1_ORIGEM", "N" } )
	
	//Armazena informacoes Tef - Integracao Mensagem Unica
	aAdd( aSL1, { "L1_VENDTEF", M->LQ_VENDTEF } )
	aAdd( aSL1, { "L1_DATATEF", M->LQ_DATATEF } )
	aAdd( aSL1, { "L1_HORATEF", M->LQ_HORATEF } )
	aAdd( aSL1, { "L1_DOCTEF",  M->LQ_DOCTEF  } )
	aAdd( aSL1, { "L1_AUTORIZ", M->LQ_AUTORIZ } )
	aAdd( aSL1, { "L1_DOCCANC", M->LQ_DOCCANC } )
	aAdd( aSL1, { "L1_DATCANC", M->LQ_DATCANC } )
	aAdd( aSL1, { "L1_HORCANC", M->LQ_HORCANC } )
	aAdd( aSL1, { "L1_INSTITU", M->LQ_INSTITU } )
	aAdd( aSL1, { "L1_NSUTEF",  M->LQ_NSUTEF  } )
	aAdd( aSL1, { "L1_CGCCLI",  M->LQ_CGCCLI  } )
	
	//Lei de Transparencia 
	aAdd( aSL1, { "L1_TOTFED",  M->LQ_TOTFED  } )
	aAdd( aSL1, { "L1_TOTEST",  M->LQ_TOTEST  } )	
	aAdd( aSL1, { "L1_TOTMUN",  M->LQ_TOTMUN  } )
	aAdd( aSL1, { "L1_LTRAN",   M->LQ_LTRAN   } )		
	aAdd( aSL1, { "L1_VALMERC", M->LQ_VALMERC } )	
	
	
	//Armazena informacao de Comissao do Vendedor
	aAdd( aSL1, { "L1_VALCOMI", M->LQ_VALCOMI } )	
	
	//Armazena Documento Fiscal
	If !Empty(M->LQ_NUMCFIS)
		aAdd( aSL1, { "L1_NUMCFIS", M->LQ_NUMCFIS } )
	EndIf
Else
	//Acerta SL1 para rotina automatica quando for integração com gestão de concessionarias
	If Type("lAutoExec") == "L" .AND. lAutoExec .AND. SuperGetMV("MV_VEICULO") == "S"
		nPos 	:= aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_ORIGEM" } )	 // Execucao Automatica
		If nPos == 0
			aAdd( aSL1, { "L1_ORIGEM", "V" } )
		Else
			aSL1[nPos][2] := "V"
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checar se eh para gerar um numero de orcamento               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGeraNumOrc

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CriaVar do L1_NUM ira chamar a GetSxeNum()³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !LJTemGeraNOrc()
    	cNumOrc := CriaVar( "L1_NUM" )
    Else
    	cNumOrc := GetSxENum("SL1","L1_NUM")
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o SXE e o SXF estejam corrompidos o numero do orcamento estava se repetindo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMay := Alltrim( xFilial( "SL1" ) ) + cNumOrc
	FreeUsedCode()
	SL1->( DbSetOrder( 1 ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTent := 0
	While SL1->( DbSeek( xFilial( "SL1" ) + cNumOrc ) ) .OR. !MayIUseCode( cMay )
		If ++nTent > 20
			MsgStop(STR0006) //"Impossivel gerar número sequencial de orçamento correto. Informe ao administrador do sistema."
			Return aRet
		EndIf
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSx8()
		End
		If !LJTemGeraNOrc()
			cNumOrc := CriaVar( "L1_NUM" )
		Else
			cNumOrc := GetSxENum("SL1","L1_NUM")
		EndIf
		FreeUsedCode()
		cMay := Alltrim( xFilial( "SL1" ) ) + cNumOrc
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acerta o array aSL1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos 	:= aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_NUM" } )
	If nPos == 0
		aAdd( aSL1, { "L1_NUM", cNumOrc } )
	Else
		aSL1[nPos][2] := cNumOrc
	EndIf

	If lJob
		nPos 	:= aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_RESERVA" } )
		If nPos == 0
			aAdd( aSL1, { "L1_RESERVA", "S" } )
		Else
			aSL1[nPos][2] := "S"
		EndIf

		nPos 	:= aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_SERPED" } )
		If nPos == 0
			aAdd( aSL1, { "L1_SERPED", "" } )
		Else
			aSL1[nPos][2] := ""
		EndIf
		nPos 	:= aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_SITUA" } )
		If nPos == 0
			aAdd( aSL1, { "L1_SITUA", "" } )
		Else
			aSL1[nPos][2] := ""
		EndIf

	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acerta o array aSL2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len( aSL2 )
		nPos 	:= aScan( aSL2[nX], {|x| Alltrim( Upper( x[1] ) ) == "L2_NUM" } )
		If nPos == 0
			aAdd( aSL2[nX], { "L2_NUM", cNumOrc } )
		Else
			aSL2[nX][nPos][2] := cNumOrc
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acerta o array aSL4³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nX := 1 to Len( aSL4 )
		nPos 	:= aScan( aSL4[nX], {|x| Alltrim( Upper( x[1] ) ) == "L4_NUM" } )
		If nPos == 0
			aAdd( aSL4[nX], { "L4_NUM", cNumOrc } )
		Else
			aSL4[nX][nPos][2] := cNumOrc
		EndIf
	Next nX

EndIf
If SL1->(ColumnPos("L1_VLRJUR")) > 0 .AND. Type("aAcrescimo") == "A"
	//Inclui Valor do Juros no Array aSL1
	nPos := aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_VLRJUR" } )
	If nPos == 0
		aAdd( aSL1, { "L1_VLRJUR",A410Arred(aAcrescimo[1],"L1_VLRJUR")  } )
	Else	
		aSL1[nPos][2] := A410Arred(aAcrescimo[1],"L1_VLRJUR")
	EndIf	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica se o numero informado jah existe na base            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cNumOrc )
	nPos 	:= aScan( aSL1, {|x| Alltrim( Upper( x[1] ) ) == "L1_NUM" } )

	If nPos > 0 .AND. !Empty( aSL1[nPos][2] )
		cNumOrc	:= aSL1[nPos][2]
	EndIf
EndIf

DbSelectArea( "SL1" )
DbSetOrder( 1 )

If DbSeek( xFilial( "SL1" ) + cNumOrc )

	If Empty( SL1->L1_DOC )
		lOperacao := .F.
	Else
		If lTela
			Aviso( STR0007, STR0008 + cNumOrc + STR0009, {"Ok"} ) //"Atenção"###"O orçamento informado ("###") já está vinculado a um documento fiscal."
		Else
			Conout( STR0008 + cNumOrc + STR0009, {STR0005} ) //"O orçamento informado ("###") já está vinculado a um documento fiscal."###"Ok"
			Help( " ", 1, "Help",, STR0008 + cNumOrc + STR0009, 1, 0 )
		EndIf
		lContinua := .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se foi pedido para gerar o numero de orcamento. Tenta ateh encontrar um numero valido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGeraNumOrc
			While SL1->( DbSeek( xFilial( "SL1" ) + cNumOrc ) ) .AND. !Empty( SL1->L1_DOC )
				While ( GetSX8Len() > nSaveSx8 )
					ConfirmSx8()
				End
				If !LJTemGeraNOrc()
					cNumOrc := CriaVar( "L1_NUM" )
				Else
					cNumOrc := GetSxENum("SL1","L1_NUM")
				EndIf
			End
			lContinua := .T.
		EndIf

	EndIf
Else
	lOperacao := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a gravacao do 'pacote'³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua

	/************************
	 Faz a gravacao do SL1   
	 ************************/
	DbSelectArea("SL1")
	Lj7GeraSL( "SL1", aSL1, If(lAlteraPrc,.F.,lOperacao), If(lAlteraFil,.T.,.F.) )
	If lOperacao
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSx8()
		End
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Se for apenas alteração das parcelas do SL4 não grava SL1 nem SL2(Somente Venda Direta)	   				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lFtvdVer12 .AND. !lAlteraPrc) .OR. !lFtvdVer12
		//³ Faz a gravacao do SL2
		DbSelectArea( "SL2" )
		SL2->(DbSetOrder( 1 ))

		//PAF-ECF: Considera registros excluidos para limpar conteudo L2_PAFMD5
	   	If lNfPafEcf
			SET DELETED OFF
		EndIf

		If SL2->(MsSeek( xFilial( "SL2" ) + SL1->L1_NUM ))
		
			aOrcFilDel := {} //Zera array statico de orcamentos filhos a deletar

			/*Se for alteracao deleta o SL2 antes de fazer a gravacao*/
			While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + SL1->L1_NUM
				Begin Transaction

					//Exclui a mensagem no SYP caso exista - Mensagem da Lista de Presentes
					If SL2->(ColumnPos("L2_MSMLPRE")) > 0 .AND. !Empty(SL2->L2_MSMLPRE)
						MSMM(SL2->L2_MSMLPRE,,,,2,,,"SL2","L2_MSMLPRE")
					EndIf

					//Exclui a mensagem no SYP caso exista - Remetente da Lista de Presentes
					If SL2->(ColumnPos("L2_REMLPRE")) > 0 .AND. !Empty(SL2->L2_REMLPRE)
						MSMM(SL2->L2_REMLPRE,,,,2,,,"SL2","L2_REMLPRE")
					EndIf
					RecLock("SL2",.F.)

					//Limpa campo validador do PAF-ECF para sinalizar que registro deletado nao sera utilizado nos relatorios/importacao de orcamento
					If (lNfPafEcf .Or. lFtvdVer12)
						SL2->L2_PAFMD5 := ""
					EndIf
					
					If !Empty(SL2->L2_FILRES) .AND. !Empty(SL2->L2_ORCRES)
						AADD(aOrcFilDel,{ SL2->L2_FILRES , SL2->L2_ORCRES })
					EndIf

					SL2->(DbDelete())
					SL2->(MsUnlock())

				End Transaction
				SL2->(DbSkip())
			End
		EndIf

		//PAF-ECF: Volta valor Set Deleted
	   	If lNfPafEcf
			SET DELETED ON

			//Somente valida registro deletado na Retaguarda PAF-ECF, nao eh necessario no PDV
			If !lMVLJPDVPA .AND. !lJob .And. Type("aposCpoDet") == "A"
				nPosPafMd5	:= aScan(aposCpoDet,{|x| AllTrim(Upper(x[1]))=="LR_PAFMD5" })
			EndIf
		EndIf

		For nX := 1 to Len( aSL2 )
			//PAF-ECF: Quando registro cancelado e ainda não armazenado no BD(Banco de Dados), nao precisa armazenar no BD.
			If !( nPosPafMd5 > 0 .AND. aColsDet[nX][Len(aColsDet[nX])] .AND. aColsDet[nX][nPosPafMd5] == Nil)
				Lj7GeraSL( "SL2", aSL2[nX], .T. )
			EndIf

			//PAF-ECF: Log de alteração da DAV
			If lNfPafEcf .And. lGrvLogDAV
				LjGrLogD( "SL2", aSL2[nX])
			EndIf
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a gravacao do SL4                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCont := 1
	DbSelectArea( "SL4" )
	SL4->(DbSetOrder( 1 ))
	SL4->(DbSeek( xFilial( "SL4" ) + SL1->L1_NUM ))

	While !SL4->(Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial( "SL4" ) + SL1->L1_NUM  .AND. Empty( SL4->L4_ORIGEM )
		If !lFtvdVer12
			If nCont <= Len( aSL4 )
		    	Lj7GeraSL( "SL4", aSL4[nCont] )
		 	Else
				Begin Transaction

		 		RecLock("SL4",.F.)
		 		//Efetua marca (**) no campo L4_SITUA p/ identificar como "registro deletado" p/ que este seja desconsiderado quando mandar os dados para retaguarda,
		 		//pois na funcao GravaSL1 do fonte LjGrvWs.PRW considera todos os registros, inclusive os deletados para integrar com a retaguarda e este registro nao podera ser considerado
		 		SL4->L4_SITUA := "**"
		 		DbDelete()
		 		MsUnlock()

		 		End Transaction
		 	EndIf
	    	SL4->( DbSkip() )
			nCont ++
		ElseIf lFtvdVer12
			If lAlteraPrc // Quando lAlteraPrc = .T. apaga todo o SL4 para gerar novamente
				Begin Transaction

		 		RecLock("SL4",.F.)
		 		DbDelete()
		 		MsUnlock()

		 		End Transaction
			Else
				If nCont <= Len( aSL4 )
			    	Lj7GeraSL( "SL4", aSL4[nCont] )
			 	Else
					Begin Transaction

			 		RecLock("SL4",.F.)
			 		DbDelete()
			 		MsUnlock()

			 		End Transaction
			 	EndIf
				nCont++
			EndIf
	    	SL4->( DbSkip() )

		EndIf
	End

	For nX := nCont to Len( aSL4 )
		Lj7GeraSL( "SL4", aSL4[nX], .T. )
	Next nX

    lRet    := .T.
    cNumOrc := aSL1[aScan(aSL1,{|x|x[1]=="L1_NUM"})][2]

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava movimento de venda perdida durante a gravacao do orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lMVLJPDVPA .AND. lVendaPerdida
		oMoviVp	:= LA701GetVp() //OBTER OBJETO DE MOVIMENTO DE VENDA PERDIDA, ATIVO NO LOJA701
		If oMoviVp != NIL
			nPos := aScan( aSL1, {|x|x[1] == "L1_NUMORC"} )
			If nPos > 0
				LA701GrvVp (oMoviVp, aSL1[nPos][2])
			Else	//grava o numero do orcamento atual
				LA701GrvVp (oMoviVp, cNumOrc)
			EndIf
		EndIf
	EndIf
Else

	cNumOrc := Space( TamSX3( "L1_NUM" )[1] )
	If lGeraNumOrc
		RollBackSx8()
	EndIf

EndIf

aRet := { lRet, cNumOrc }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Volta o valor original da cFilAnt se necessario              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAlteraFil
	cFilAnt := cFilAux
	RestArea(aAreaSM0)
EndIf

Return aRet

/*/{Protheus.doc} Lj7PrepOrc
Prepara os dados para a gravacao do orcamento 
@type  Function
@author Vendas Clientes  
@since 18/08/02
@param 
@return ExpL1 - .T. se a gravacao foi concluida com exito
/*/
Function Lj7PrepOrc( nOpc     	, nTipo     , nHandle		, lReserva		,;
					 lAtuData	, lDefPagto	, cNomeCli		, cCGCCli		,;
					 lNfManual	, cEspDoc	, nDescontFi	, lAlteraPrc	,;
					 nTotICM	)
					 
Local aArea			:= GetArea()															// Guarda a area atual
Local aSL1			:= {}																	// Array com os campos do SL1
Local aSL2			:= {}																	// Array com os campos do SL2
Local aSL4			:= {}																	// Array com os campos do SL4
Local aAux 			:= {}																	// Array auxiliar
Local aCamposU		:= {}																	// Array com os campos de usuario (custom.)
Local aFormas       := {}             														// Array das formas de pagto
Local aRetCrd       := {}																	// Array de retorno com informacoes de credito do cliente(SIGACRD)
Local aCposTroco	:= {}																	// Array com os campos de troco controlados pelo sistema
Local nTotalDIfForm := 0																	// Total de dIferencas
Local nPosRet       := 0																	// Posicao retornada
Local nX	 		:= 0																	// Variav. auxiliar em For...Next
Local nY	 		:= 0																	// Variav. auxiliar em For...Next
Local nPos 			:= 0																	// Posicao dentro de um array
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]// Posicao do Codigo do produto
Local nPosDescri	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_DESCRI"})][2]	// Posicao da Descricao do produto
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade
Local nPosVrUnit	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VRUNIT"})][2]	// Posicao do Valor unitario do item
Local nPosVlrItem   := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VLRITEM"})][2]// Posicao do Valor Total do Item
Local nPosDesc		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_DESC"})][2]	// Posicao do percentual de desconto
Local nPosValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VALDESC"})][2]// Posicao do valor de desconto
Local nPosEntrega   := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ENTREGA"})][2]// Posicao da Entrega
Local nPosProvEnt	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PROVENT"})			// Posicao da provincia de entrega
Local nPosMostruario:= 0																	// FLAG se eh mostruario/Saldao/Normal
Local nPosObsMostrua:= 0																	// Observacoes do mostruario/Saldao
Local nPosGarant	:= 0																	// Posicao garantia
Local nPosVend		:= 0																	// Posicao do vendedor
Local nPosVlTroca   := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VLTROCA"})][2]
Local nPosFILPED    := 0																	// Posicao da Filial do Pedido com VFE
Local nPosCEST      := 0																	// Posicao do CEST
Local nDtEntr		:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_FDTENTR"})
Local nDtMont		:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_FDTMONT"})
Local nPContato 	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CODCONT"})
Local nPosLista		:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CODLPRE"})			// Posicao do codigo da lista de presente
Local nPosItLista	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITLPRE" })			// Posicao do item da lista de presente
Local nPosMsgLPre	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_MSGLPRE"})			// Mensagem do Comprador
Local nPosRevLPre	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_REVLPRE"})			// Mensagem do Remetente
Local nPosMsmLPre	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_MSMLPRE"})			// Codigo da mensagem do Comprador
Local nPosRemLPre	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_REMLPRE"})			// Codigo da mensagem do Remetente
Local nPosVlImpor	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VLIMPOR"})			// Posicao do Valor de Importação
Local nPosFCICod	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_FCICOD"})				// Posicao do Codigo FCI
Local nPosClasFis	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CLASFIS"})			// Classificação Fiscal do Produto
Local nPosPRedIc	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PREDIC"})				// %Redução da Base do ICMS
Local nPosDtEntr	:= 0					   												// Posicao da Data de Entrega
Local nPosDtMont	:= 0					   												// Posicao da Data de Montagem
Local nPosContato	:= 0																	// Posicao da Contato do Cliente
Local nPosDtTes		:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_TES"})				// Posicao do Codigo do TES
Local nPosDtCF		:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CF" })				// Posicao do Codigo do CF
Local nPosDtTabela	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_TABELA"})			// Posicao da Tabela de precos
Local nPosDtDProp	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_DESCPRO"})			// Posicao do Desconto proporcional
Local nPosDtPrcTab  := Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_PRCTAB"})			// Posicao do Preco de Tabela
Local nPosDtReserva	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_RESERVA"})			// Posicao do codigo da reserva
Local nPosDtLojaRes	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOJARES"})			// Posicao do codigo da reserva
Local nPosDtFilRes	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_FILRES"})			// Posicao do codigo da Filial de reserva
Local nPosDtVlFret	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALFRE"})			// Posicao do Valor do Frete do Item     
Local nPosDtVlDesp	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_DESPESA"})			// Posicao do Valor das Despesas Acessorias do Item
Local nPosNumSerie	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_NSERIE"})			// Posicao do codigo do serial
Local nPosLoteCTL 	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOTECTL"})			// Posicao do codigo do Sub Lote
Local nPosLote   	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_NLOTE"})			// Posicao do codigo numero do Lote
Local nPosLocaliz	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOCALIZ"})			// Posicao do codigo da localizacao
Local nPosDtValid	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_DTVALID"})			// Posicao da validade do lote
Local nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_LOCAL"})			// Posicao do local (armazem)
Local nPosValePre	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VALEPRE"})			// Posicao do codigo do Vale Presente
Local nPosCodReg	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_CODREG"})  		// Posicao do campo do codigo da Regra de desconto
Local nPosVlDesR	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VLDESRE"})			// Posicao do campo do valor consedido pela regra de desconto
Local nPosTurno		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_TURNO"})			// Posicao do codigo do Vale Presente
Local nPosCodLan	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_CODLAN"})			// Posicao do codigo do Codigo de Lancamento
Local nPosStTrib	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_SITTRIB"})			// Posicao do codigo do Situacao Tributaria
Local nPosEnvelo    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_ENVELO"})			// Posicao do codigo do Envelope
Local nPosKit       := Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_KIT"})			    // Posicao do campo que indica se o item eh kit
Local nPosBrinde    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_BRINDE"})			// Posicao do codigo do "Prod. Brinde
Local nPosCliEnv    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_CLIENV"})			// Posicao do codigo do Cliente do Envelope
Local nPosLojEnv   	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOJENV"})			// Posicao do codigo da Loja do Envelopre
Local nPosPa2Item   := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PA2ITEM"})			// Posicao do codigo do Item do Envelope
Local nPosCodBar	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CODBAR"})			// Codigo de barras
Local nPosECPresSN	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ECPRESN"})			// Se Pedido de Presente e-Commerce
Local nPosECSedex	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ECSEDEX"})			// Codigo Sedex do e-Commerce
Local nPosECMensPr	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ECMSGPR"})			// Mensagem do Item de Presente e-Commerce
Local lIntegDef		:= Lj701GtInD() //Venda Origem Integração
Local lIntegHtl		:= lIntegDef .And. SuperGetMv("MV_INTHTL",, .F.) 
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()																// Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lEmitNFCe		:= (!lFtvdVer12 .Or. lIntegDef) .AND. LjEmitNFCe()						// Sinaliza se utiliza NFC-e
Local nPosOrigem	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ORIGEM"})
Local nPosModbc		:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_MODBC"})			// Verifica se possui campo utilizado para otimizar processo da NFCe
Local nPosCodIss	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CODISS"})			// Verifica se possui campo utilizado para otimizar processo da NFCe
Local nPosPosIpi	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_POSIPI"})			// Verifica se possui campo utilizado para otimizar processo da NFCe
Local nPosPedSC5	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PEDSC5"}) 			// Pedido de venda do SC5 (UPDFAT14)
Local nPosIteSC6	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_ITESC6"}) 			// Iten do Pedido de venda (UPDFAT14)
Local nPosSequen	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_SEQUEN"}) 			// Sequencia do SC9 (UPDFAT14)
Local nPosCAbISS	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ABATISS"})            // Posicao do campo LR_ABATISS no array aPosCpo
Local nPosAbtIss	:= IIF(nPosCAbISS > 0, aPosCpo[nPosCAbISS][2], 0)						// Posicao do valor de abatimento do ISS
Local nDinheiro		:= 0																	// Valor em dinheiro
Local nCheque 		:= 0																	// Valor em cheque
Local nCartao 		:= 0																	// Valor em Cartao de Credito
Local nVlrDebi 		:= 0																	// Valor em Cartao de Debito
Local nConveni		:= 0																	// Valor em Convenio
Local nVales 		:= 0																	// Valor em Vales
Local nFinanc		:= 0																	// Valor em Financiamento
Local nOutros 		:= 0																	// Valor pago de outras formas
Local nVlrEntrada 	:= 0																	// Valor de Entrada
Local nVlrPagDig	:= 0																	// Valor em Pagamento Digital
Local nVlrPagPix	:= 0																	// Valor em PIX
Local nVlrFSD		:= 0																	// Valor do frete + seguro + despesas
Local nVlrTroco		:= IIF(!lIntegDef, Lj7T_Troco(2), 0) 									// Valor do troco
Local nVlrItens		:= 0																	// Valor total dos itens
Local nMoedaParc    := 1																	// Moeda corrente
Local nVlrTrcAux    := 0                              										// Troco convertido para moeda da parcela
Local nRet          := 0																	// Retorna status
Local nVlrParc      := 0                           											// Valor da parcela calculado quando troco desabilitado
Local nTrocoEnt     := 0                          											// Valor que deve ser subtraido da entrada, caso o troco nao esteja habilitado
Local nVlrDescFin	:= 0 																	// Valor referente ao desconto financeiro
Local nVlrAcreFin	:= 0 																	// Valor referente ao acrescimo financeiro
Local nPerDescFin	:= 0 																	// Valor referente ao desconto financeiro
Local nPerAcrsFin	:= 0 																	// Valor referente ao acrescimo financeiro
Local nTotAux		:= 0																	// Total do nTotPremio
Local nPrcTab		:= 0																	// Valor do Preco de Tabela do Item do SL2
Local nDIf          := 0                                									// DIferenca entre o valor da venda e de parcelas
Local nTamOrc		:= 0																	// Tamanho do campo de orcamento (LQ_NUMORC)
Local nPosLR_BICO  	:= 0
Local nPosLR_LEGCOD	:= 0
Local cNumOrc		:= Space(TamSx3("L1_NUM")[1])											// Nr. do orcamento
Local cItem			:= StrZero(0,TamSx3("L2_ITEM")[1],0)									// Item
Local cCampo		:= ""																	// Guarda o campo do SLQ
Local cCondPgto     := ""																	// Condicao de pagto
Local cMV_FormCRD   := SuperGetMV("MV_FORMCRD",,"CH/FI") 									// Formas de pagamento para as quais deve avaliar credito - SIGACRD
Local cMV_CLIPAD	:= PadR(SuperGetMV("MV_CLIPAD"),TAMSX3("LQ_CLIENTE")[1])				// Cliente padrao
Local cMV_LOJAPAD	:= PadR(SuperGetMV("MV_LOJAPAD"),TAMSX3("LQ_LOJA")[1])					// Loja do cliente padrao
Local cMV_CRDAVAL   := SuperGetMV("MV_CRDAVAL",,"13|22|43")									// Parametro que define os modulos e processos que tem analise de credito
Local cMsg          := "" 																	// Mensagem a exibir
Local cRetorno      := Space(10)															// String de retorno da DLL
Local cTabCnVda 	:= ""																	// Tabela de preco padrao
Local cTpComiss		:= SuperGetMv("MV_LJTPCOM",,"1")										// Tipo de calculo de comissao utilizado (1-Para toda a venda (padrao),2-Por item)
Local cVend			:= ""																	// Vendedor gravado no item
Local dDataOrc		:= Ctod(Space(8))														// Data do orcamento
Local dDataVal		:= Ctod(Space(8))														// Data de validade do orcam.
Local lVAssConc		:= LjVassConc()															// Indica se o cliente utiliza a Vda Assistida Concomitante
Local lCondNeg     	:= ( Trim( SL1->L1_CONDPG ) == "CN" )									// VerIfica se eh condicao negociada
Local lRet          := .F. 																	// Retorno da funcao
Local lTemParcFI    := .F.																	// Controla se tem alguma parcela financiada para avaliacao de credito
Local lHabTroco     := SuperGetMV( "MV_LJTROCO", ,.F. )   									// Determina que o controle de troco esta habilitado
Local lForcada		:= .F.																	// Indica se a venda foi off-line ou on-line quando integra com SIGACRD
Local lTemFinanc    := .F.																	// Determina se tem alguma parcela financiada para chamar a tela de Adm. Financeira na gravacao do orcamento quando SIGACRD integrado
Local lTplPCL		:= HasTemplate("PCL") .AND. ExistTemplate("TpPclImpLeg")
Local lUsafd      	:= SuperGetMV("MV_LJUSAFD",,.F.) 										// Utiliza Fidelizacao de cliente ??
Local nMoedExist    := MoedFin()															// Recebe a Quantidade de moedas cadastradas
Local nTPCompNCC    := SuperGetMV("MV_LJCPNCC",,1)											//Tratamento para compensacao de NCC 1-Compensacao atual 2 - Nova Compensacao
Local lTemGeraNOrc	:= .F.																	//Se tem funcao diferenciada para geracao de numero de orcamento
Local lObrigatorio	:= .F.																	//Se os campos obrigatórios da tela estão preenchidos
Local lLj7052		:= ExistBlock("LJ7052")													// VerIfica se existe o Ponto de Entrada
Local cFormVale		:= IIf(SuperGetMV("MV_LJVALEP",,.F.),"VA|VP","VA")						// Utiliza Vale Presente
Local lDelete       := .F.
Local lImpCupFis    := !LjNFFimVd()                                                         // Indica que eh referente ao cupom fiscal
Local nMVDtlimit    := SuperGetMV("MV_DTLIMIT")                                             // Variavel auxiliar para receber o conteudo do parametro MV_DTLIMIT
Local cBasImpCam	:= ""																	// Contem a descrição dos campos para base de impostos
Local cValImpCam	:= ""																	// Contem a descrição dos campos para valor de impostos
Local nPosSolCom    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_SOLCOM"})			// Posicao do numero da solicitacao de compra gerado para reserva sem estoque
Local nPosVldProd   := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VLGAPRO"})			// Posicao do numero de dias de validade do produto
Local nPosMesRec    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_MESREC"})			// Posicao do numero do recno da tabela MES
Local nCartFid      := 0																	// Valor em Cartao Fidelidade
Local cCampUsr      := ""                                                                   // Campo de usuario
Local nMvLjTpDes	:= SuperGetMv( "MV_LJTPDES", , 0 )										// Indica qual desconto sera' utilizado 0 - Antigo / 1 - Novo (objeto)
Local lCAT83 		:= ExistFunc("FISA023").AND. SuperGetMV("MV_CAT8309",,.F.) 				// Verifica CAT/83
Local cSitTrib		:= ""																	// Situacao Tributaria
Local nAliquota		:= 0																	// Aliquota
Local nAliqRed		:= 0											    					// Aliquota de reducao da base de calculo do produto
Local cTpSolCf		:= SuperGetMv("MV_TPSOLCF")                  							// Parametro para validacao do tipo de cliente para o calculo do solidario
Local lPreVenda		:= SuperGetMv("MV_LJPRVEN",,.T.)										// Sinaliza forma de gravacao do orcamento(DAV/PV)
Local lNfPafEcf	  	:= LjNfPafEcf(SM0->M0_CGC)												// Se habilitado CNPJ PAF-ECF
Local lGE 			:= LjUP104OK()	 														// Validação do Conceito Garantia Estendida
Local nPosFilRes    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_FILRES"})		    // Posicao da filial do numero da solicitacao de compra gerado para reserva sem estoque
Local nPosNumcFi	:= 0																    // Posicao do numero do cartao fidelidade
Local nPosDtsdFi    := 0																	// Posicao da data de validade do saldo inserido no cartao fidelidade
Local nPosVlrcFi    := 0			    													// Posicao do valor do saldo inserido no cartao fidelidade
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()							// Indica se a recarga de cartao fidelidade esta ativa
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)												// Verifica as filiais da trabalharam com acrescimento separado
Local lLocR5        :=  cPaisLoc$"CHI|COL"
Local aAreaAtiv 	:= {}
Local aMDJ 			:= {}
Local aVendDig  	:= {}  																	// Array com os vendedores digitados na SL2 quando cTpComiss == 2
Local oLjIntFSAn  	:= nil  	 															// MAN0000604-01 - Integração Protheus x Financial Service classe da analise de credito
Local lAutoExC 		:= IsBlind()
Local cMVCliPad		:= PadR(SuperGetMV("MV_CLIPAD"),TAMSX3("LQ_CLIENTE")[1])				// Cliente padrao
Local cMVLojaPad	:= PadR(SuperGetMV("MV_LOJAPAD"),TAMSX3("LQ_LOJA")[1])                  // Loja do cliente padrao
Local lFSCliPad 	:= .F. 																	// Orcamento com financiamento com o financial services do cliente padrão
Local lRetFci		:= .F. 																	// Tratamento para verificação de alteração da classificação fiscal
Local lFTVD7052		:= ExistBlock("FTVD7052")												// VerIfica se existe o Ponto de Entrada
Local lUsaFecha		:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. LjUpd70Ok()					// Utilizar conf. de fechamento
Local cTransNat		:= SuperGetMV("MV_LJTRNAT",.F.,"")										// Natureza financeira da transferencia
Local lUsaTransf	:= SuperGetMV("MV_LJTRANS",.T.,.F.) .AND. !Empty(cTransNat)
Local nL1Credito 	:= 0
Local lAbateISS		:= .F.
Local cFormaPgto    := ""																	// Forma de pagto
Local cNumDAVOSOrig := ""																	// Guarda número da DAV
Local lMvLjDAVOS 	:= lNfPafEcf .AND. !lPreVenda .AND. SuperGetMV("MV_LJDAVOS",,.F.) 		// Verifica se utiliza Ordem de Serviço
Local nNFTOTAL 		:= 0
Local cMvDescSai	:= SuperGetMV("MV_DESCSAI",,"1")										// Desconto tratamento localizacoes
Local __ljAcrescFi	:= 9 																	// Acréscimo financeiro Multinegociação
Local nPGarItem		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_ITEMGAR"})
Local cItemGar		:= ""
Local nItemGar		:= 0
Local nItem			:= 0
Local lSomaGar		:= .T.
Local lIntSiac		:= SuperGetMV("MV_SCINTEG", .F., .F.)
Local lLjNCCOr		:= SuperGetMv("MV_LJNCCOR", Nil, .F.)									// Verifica se a NCC sera mantida no orcamento (F4)
Local nPCLIENTREGA 	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CLIENT"}) 			// Cliente de entrega
Local nPLOJCLIENT	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CLILOJA"})			// Filial do cliente de entrega
Local cFciCod		:= ""
Local nVlImp		:= 0
Local aSxFci		:= LjCFciParam()
Local lFciVlImpor	:= nPosVlImpor > 0 .And. aSxFci[5] .And. aSxFci[6]
Local lFciCod		:= nPosFCICod > 0 .And. aSxFci[4] .And. aSxFci[8]
Local lMultNeg		:= SuperGetMV("MV_LJMULTN", , .F.)										// Ativa Multi Negociacao
Local lParceiros	:= .F.																	// Define se Habilita comissao para parceiros que indicam a loja
Local cParceiro		:= ""																	// Cod Parceiro que indicou a loja (Vendedor tipo "P")
Local aParc	   		:= {}																	// Armazena informações dos parceiros e itens para envio de e-mail.
Local nPosParc		:= 0																	// Posição do campo parceiro
Local nPosItem		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]	// Posicao do numero do item
Local cModBc		:= ""
Local aModBc		:= {}
Local lSFinanc		:= SuperGetMV("MV_LJCSF",,.F.)											// Valida implementação do servico financeiro
Local nPosItSer		:= 0																	// Posicao do Item do Produto Cobertura - Servico Financeiro
Local nPosPrdCob	:= 0 																	// Posicao do codigo do Produto Cobertura - Servico Financeiro
Local lEmiteNF		:= (LjNFFimVd() .OR. (nModulo == 5) .OR. LjNfNoPaf(SM0->M0_CGC))
Local aArea2		:= {}
Local aAreaSM0		:= {}
Local aTimeUf		:= {}
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) 										// Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cHoraRMT		:= ""
Local lMenNota		:= SuperGetMV("MV_LJMENNO",,.F.)										// Verifica se esta habilitado a apresentacao do campo de observacao da nota fiscal
Local lRetemPCC 	:= .F.
Local cL2Origem		:= ""
Local lUseSAT		:= LjUseSat()
Local lECommerce	:= SuperGetMV("MV_LJECOMM",,.F.) .AND. SL1->L1_ECFLAG == "1" 			// E-commerce implantado?
Local lECExec 		:= lECommerce .AND. Lj901Auto() 										// Chamada pela rotina e-commerce CiaShop?
Local lL2CEST		:= SL2->(ColumnPos("L2_CEST")) > 0
Local lL2CmpISS		:= SL2->(ColumnPos("L2_BASEISS")) > 0 .AND. SL2->(ColumnPos("L2_ALIQISS")) > 0
Local lL2CNAE		:= SL2->(ColumnPos("L2_CNAE")) > 0										// verifica existencia do campo CNAE [ usado para NFC-e com Serviço(Nota Fácil Manaus) ] 
Local cTpFrete		:= ""
Local cMV_LJPGTRO 	:= AllTrim(SuperGetMV("MV_LJPGTRO",,IIf( cPaisLoc <> "BRA","", "R$")))
Local nTrocoRat 	:= 0 																	// Troco devido
Local nPerTroco 	:= 0 																	// Percentual do troco
Local nTotParcTroc  := 0 																	// Total de Parcelas do troco
Local nDecs		    := MsDecimais(nMoedaCor) 												// Decimais do troco
Local nDiffTrc 	    := 0 																	// Diferença do troco
Local cFormTrc 	    := Lj7GetTrcForm()
Local nPosSL4 	    := 0
Local lMaFisFound	:= .F.
Local nLj7TDescV	:= 0
Local nPosECValor	:= IIF(SLR->(FieldPos("LR_ECVALOR") > 0), Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ECVALOR"}), 0) // Mensagem do Item de Presente e-Commerce
Local nPosValIcm	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALICM"}) 	 		// Valor do ICMS
Local nPosBasIcm	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASEICM"}) 		// Base do ICMS
Local nPosAliIcm	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_PICM"})    		// Aliquota do ICMS
Local nPosValIss	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALISS"})  		// Valor do ISS
Local nPosBasIss	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASEISS"}) 		// Base do ISS 
Local nPosAliIss	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALIQISS"}) 		// Aliquota do ISS
Local nPosBsCSLL	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASCSLL"}) 		// Base do CSLL
Local nPosAlCSLL	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALQCSLL"}) 		// Aliquota do CSLL
Local nPosVlCSLL	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALCSLL"}) 		// Valor do CSLL
Local nPosValPS2	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALPS2"})  		// Valor do PIS - Apuracao
Local nPosAliPS2	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALIQPS2"}) 		// Aliquota do PIS - Apuracao
Local nPosBasPS2	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASEPS2"}) 		// Base do PIS - Apuracao
Local nPosValPis	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALPIS"})  		// Valor do PIS Retencao
Local nPosBasPis	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASEPIS"}) 		// Base do PIS Retencao
Local nPosAliPis	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALIQPIS"}) 		// Aliquota do PIS - Retencao
Local nPosValCF2	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALCF2"})  		// Valor do COFINS Apuracao
Local nPosAliCF2	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALIQCF2"}) 		// Aliquota do COFINS - Apuracao
Local nPosBasCF2	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASECF2"}) 		// Base do COFINS - Apuracao
Local nPosValCof	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALCOFI"}) 		// Valor do COFINS - Retencao
Local nPosAliCof	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALIQCOF"}) 		// Aliquota do COFINS - Retencao
Local nPosBasCof	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASECOF"}) 		// Base do COFINS - Retencao
Local nPosVlIrrf	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALIRRF"}) 		// Valor do IRRF
Local nPosBasIrrf	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASIRRF"}) 		// Base do IRRF
Local nPosAliIrrf   := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALQIRRF"}) 		// Aliquota do IRRF
Local nPosCCusto	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CCUSTO"})			// Posicao do campo Centro de Custo
Local nPosItCC	    := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ITEMCC"})			// Posicao do campo Item CC
Local nPosClvl	    := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CLVL"})			// Posicao do campo Classe Valor
Local nPosBasFecp	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASFECP"}) 		// Base FECP
Local nPosValFecp	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALFECP"}) 		// Valor FECP
Local nPosAlqFecp   := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALQFECP"}) 		// Aliquota FECP
Local nPosBasSTFecp	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BSFCPST"})			// Base FECP
Local nPosValSTFecp := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VFECPST"}) 		// Valor FECP_ST
Local nPosAlqSTFecp := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALQFCST"})			// Aliquota FECP_ST
Local nPosCSTPIS    := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CSTPIS"})			// 
Local nPosCSTCOF    := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CSTCOF"})			// 
Local nPosITransp   := Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_TRANSP"})			// Posicao da Transportadora no item
Local lL2FECP		:= SL2->(ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0)
Local lL2FECPST     := SL2->(ColumnPos("L2_ALQFCST") > 0 .AND. ColumnPos("L2_VFECPST") > 0)
Local lL2BASFECP	:= SL2->(ColumnPos( "L2_BASFECP" )) > 0									// Verifica se campo existe	 
Local lL2STBASFECP	:= SL2->(ColumnPos( "L2_BSFCPST" )) > 0									// Verifica se campo Base FECP_ST existe 
Local nRecnoSB1		:= 0
Local cMD5Sb1   	:= ""
Local nL2PosVlIpi   := aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALIPI"})
Local nL2BASEIPI	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BASEIPI"})
Local nL2IPI		:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_IPI"})
Local lL2BASEIPI	:= SL2->(ColumnPos("L2_BASEIPI")) > 0
Local lL2IPI		:= SL2->(ColumnPos("L2_IPI")) > 0
Local lL2AliqSOL	:= SL2->(ColumnPos("L2_ALIQSOL")) > 0
Local nL2ICMSRET   	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ICMSRET"})
Local nL2BRICMS   	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_BRICMS"})
Local nL2ALIQSOL   	:= aScan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_ALIQSOL"})
Local nI			:= 0
Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local lIDCNAB		:= SL4->(ColumnPos("L4_IDCNAB")) > 0
Local cMvEntExce	:= IIF(!Empty(SuperGetMV("MV_ENTEXCE",.F.,'')), "|"+SuperGetMV("MV_ENTEXCE",.F.,'')+"|", '|CC|CD|CH|FI|VA|VP|CO|FID|' )  // Formas de pagamento nao consideradas como entrada (Não será gravado L1_ENTRADA)
Local nAux			:= 0
Local lLjDifal 	  	:= SuperGetMV("MV_LJINTUF",,0) > 0 	//Ativa verificação e operacoes relacionadas ao DIFAL

Default lReserva	:= .F.
Default nHandle		:= -1
Default lAtuData	:= .T.
Default lDefPagto   := .F.			// VerIfica se passou pela tela de definição de Pagamentos
Default cEspDoc		:= .T.
Default nDescontFi  := 0			// Desconto financeiro (configurado na condicao de pagamento) tabela SE4
Default lAlteraPrc  := .F.			// Será passado .T. quando for apenas alteração de SL4
Default nDescontFi  := 0			// Desconto financeiro (configurado na condicao de pagamento) tabela SE4
Default nTotICM		:= 0

//Tratamento Integracao Mensagem Unica - NFCe
If lIntegDef 
	If lEmitNFCe
		lEmiteNF := .F.
	EndIf		
EndIf

cHoraRMT := SuperGetMv("MV_HORARMT",.F.,"2")
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

// Comissao de Parceiros que indicam a loja
lParceiros := SuperGetMv("MV_LJINDPA",,.F.) 		.AND. 	; // Habilita comissao para Parceiros que indicam a loja
				SL2->(ColumnPos("L2_INDPAR")) > 0 	.AND.	;
				SLR->(ColumnPos("LR_INDPAR")) > 0	.AND.	;
				Val(GetVersao(.F.)) >= 12
If lParceiros
	nPosParc := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_INDPAR"})][2]
EndIf

If !lMVLJPDVPA .AND. (nOpc == 4) .AND. lMvLjDAVOS
	cNumDAVOSOrig := SL1->L1_NUMORC	//Número da DAV anterior a alteração
	Lj7CanDAVOS()
EndIf

// Cria proteção para campos incluidos no fonte loja701

If lGE
	If Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_GARANT"}) > 0
		nPosGarant	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_GARANT"	})				// Posicao do codigo do serial
	EndIf
EndIf

If lSFinanc
	nPosItSer 	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEMCOB"	})
	nPosPrdCob 	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRDCOBE"	})
EndIf

nPosMostruario:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VDMOST"})][2]
nPosObsMostrua:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VDOBS"})][2]

If LjPedVen(.F.)								// VerIfica se esta preparado para pedido de Venda
	nPosDtEntr	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_FDTENTR"})][2]	// Posicao da Data de Entrega
	nPosDtMont	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_FDTMONT"})][2]	// Posicao da Data de Entrega
	nPosContato	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CODCONT"})][2]	// Posicao da Contato do Cliente
EndIf

If SLR->(ColumnPos("LR_FILPED")) > 0
	nPosFILPED := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_FILPED"})][2]
EndIf
If SLR->(ColumnPos("LR_CEST")) > 0
	nI := Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_CEST"})
	nPosCEST := IIF( nI > 0, aPosCpoDet[nI][2], 0)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade                                   ³
//³Caso a funcionalidade de recarga de cartao fidelidade estiver ativa³
//³serao acrescentadas as colunas que armazenarao os dados            ³
//³da recarga informados na tela de inclusao de saldo (LOJXFUNH)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjcFid
	If SLR->( ColumnPos( "LR_NUMCFID" ) ) > 0  													// VerIfica existencia do campo
		nPosNumcFi	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_NUMCFID"})			// Posicao do numero do cartao fidelidade
	EndIf

		If SLR->( ColumnPos( "LR_DTSDFID" ) ) > 0  												// VerIfica existencia do campo
		nPosDtsdFi	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_DTSDFID"})			// Posicao da data de validade do saldo inserido no cartao fidelidade
	EndIf

	If SLR->( ColumnPos( "LR_VLRCFID" ) ) > 0  													// VerIfica existencia do campo
		nPosVlrcFi	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VLRCFID"})			// Posicao do valor do saldo inserido no cartao fidelidade
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³				    Posicao do Vendedor  				     ³
//³Criado cTpComiss = "3" para controle de comissao por Item ³
//³        e integridade de Vendedores/Usuarios              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTpComiss == "2" .OR. cTpComiss == "3"
	nPosVend := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VEND"})][2]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Permite alteração de Nome e NIT - BOLIVIA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BOL" .AND. nTipo == 2
	aAreaAtiv := GetArea()	// salva os dados relacionados a area ativa e posicionamento
	DbSelectArea("SF3")
	If SF3->(ColumnPos("F3_NIT")) > 0 .AND. SF3->(ColumnPos("F3_RAZSOC")) > 0
		If M->LQ_CLIENTE+M->LQ_LOJA == cMV_CLIPAD+cMV_LOJAPAD
			cNomeCli 	:= ""
			cCGCCli		:= ""
		EndIf
		LjNitCli(@cNomeCli,@cCGCCli,@lNfManual)
		RestArea(aAreaAtiv)
	EndIf
EndIf

lMaFisFound := MaFisFound("NF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na gravacao do orcamento, nao consideramos os valores(base de|
//| calculo, valor do ICMS) calculados pela inclusao do Frete	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1 .AND. (M->LQ_FRETE + M->LQ_SEGURO + M->LQ_DESPESA) > 0 .AND. lMaFisFound
	MaFisAlt("NF_FRETE"		,0)
	MaFisAlt("NF_SEGURO"	,0)
	MaFisAlt("NF_DESPESA"	,0)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tabela utilizara para o cenario de vendas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCenVenda
	cTabCnVda 	:= LjXETabPre(M->LQ_CLIENTE,M->LQ_LOJA)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica a obrigatoriedade dos campos da enchoice                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTemGeraNOrc := LjTemGeraNOrc()

If lNfPafEcf

	If !lMVLJPDVPA.AND. (nOpc == 4) .AND. lMvLjDAVOS
		lTemGeraNOrc := .T.
	EndIf

	If cPaisLoc <> "BRA" .OR. !lTemGeraNOrc
		lObrigatorio := lRecebe .OR. Obrigatorio( aGets, aTela )
	Else
		lObrigatorio := .T.
	EndIf
Else
	If !LJAnalisaLeg(37)[1] .OR. !lTemGeraNOrc
		lObrigatorio := lRecebe .OR. Obrigatorio( aGets, aTela )
	Else
		lObrigatorio := .T.
	EndIf
EndIf

If !lRecebe .AND. !lObrigatorio

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'VerIficação de campos obrigatórios - N / N')
	EndIf

	Return .F.
EndIf

If nDtEntr > 0
	nPosDtEntr	:= aPosCpo[nDtEntr][2]			// Posicao da Data de Entrega
EndIf

If nDtMont > 0
	nPosDtMont	:= aPosCpo[nDtMont][2]			// Posicao da Data de Entrega
EndIf
If nPContato > 0
	If !Empty(aPosCpo[nPContato][2])
   		nPosContato	:= aPosCpo[nPContato][2]		// Posicao da Contato do Cliente
 	Endif
EndIf

If nPosProvEnt > 0
	nPosProvEnt	:= aPosCpo[nPosProvEnt][2]		// Posicao da provincia de entrega
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica as variaveis do cabecalho do orcamento                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRecebe

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Geração Orçamento - N')
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta os arrays utilizados na gravacao dos impostos...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"
		Lj7PrepGrvImp()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao considerar os premios quando grava como orcamento                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CrdXint() .AND. lUsafd .AND. nTipo == 1

		If Len( aPremio ) > 0

			nTotAux := nTotPremio

			nX := 1

			While nTotAux > 0

				nDIf := aPgtos[nX][2] - nTotAux

				If nDIf > 0
					aPgtos[nX][2] := nDIf
					Exit
				ElseIf nDIf == 0
					aDel(aPgtos,nX)
					aSize(aPgtos, Len(aPgtos) - 1)
					Exit
				Else
					nTotAux := ABS( nDIf )
					aDel(aPgtos,nX)
					aSize(aPgtos, Len(aPgtos) - 1)
				EndIf
			End
			Lj7T_TotPar(2, Lj7T_TotPar(2) - Lj7AtuPremio() )
			Lj7T_Subtotal( 2, Lj7T_Subtotal(2) - Lj7AtuPremio() )
			Lj7T_Total(2, Lj7T_Total(2) - Lj7AtuPremio(.T.))
		EndIf
	EndIf

	If (!lAlteraPrc .AND. lFtvdVer12) .OR. !lFtvdVer12
		If lNfPafEcf
		    If cPaisLoc <> "BRA" .OR. !lTemGeraNOrc
				cNumOrc 	:= M->LQ_NUM
			Else
				If nOpc <> 4 .OR. (!lMVLJPDVPA .AND. lMvLjDAVOS) //Deve-se somente gerar um novo de DAV na retaguarda quando lMvLjDAVOS == .T.
					M->LQ_NUM := GetSxENum("SL1","L1_NUM")
					ConfirmSx8()
				EndIf
			EndIf
		Else
		    If !LJAnalisaLeg(37)[1] .OR. !lTemGeraNOrc
				cNumOrc 	:= M->LQ_NUM
			Else
				If nOpc <> 4
					M->LQ_NUM := GetSxENum("SL1","L1_NUM")
					ConfirmSx8()
				EndIf
			EndIf
		EndIf
	EndIf
	cNumOrc 	:= M->LQ_NUM
	dDataOrc	:= If(lAtuData .And. !lIntegDef, dDatabase, M->LQ_EMISSAO)	
	dDataVal 	:= M->LQ_DTLIM
	
	If (M->LQ_FRETE + M->LQ_SEGURO + M->LQ_DESPESA) > 0
		nVlrFSD	:= Lj7CalcFrete()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Na gravacao do orcamento, nao consideramos os valores(base de|
        //| calculo, valor do ICMS) calculados pela inclusao do Frete   ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If nTipo == 1 .And. lMaFisFound
            MaFisAlt("NF_FRETE"  , 0)
            MaFisAlt("NF_SEGURO" , 0)
            MaFisAlt("NF_DESPESA", 0)
        EndIf
	EndIf

	/*
	|| Verifica se a venda tem Frete ou Cliente de outro estado com DIFAL
	|| para carregamento dos campos referente a Cliente Entrega na SF3
	*/
	If !Empty(M->LQ_FRETE) .OR. !Empty(M->LQ_TRANSP) .OR.;
		( lLjDifal .AND. MaFisRet(Nil, "NF_VALICM") > 0 .AND. GetMV("MV_ESTADO") <> IIf(MaFisFound("NF"), MaFisRet(,"NF_UFDEST"),SA1->A1_EST) )
		MaFisLoad("NF_CLIENT" , M->LQ_CLIENTE)
		MaFisLoad("NF_LOJENT", M->LQ_LOJA)
	EndIf

	cCondPgto   := If(!lLayAway,If(Empty(M->LQ_CONDPG),"CN",M->LQ_CONDPG),"LAY")

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Geração Orçamento - N / ' + cNumOrc + ' / ' + DToC(dDataOrc))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³***                                       se ecf                se nota fiscal                               ³
	//³***cConfVenda :=  SubStr(cConfVenda,1,7)+If(nCheck==1,"S","N")+If(nCheck==2,"S","N")+SubStr(cConfVenda,10,3) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Analise de credito integrada com SIGACRD                                 ³
    //³No Finaliza Venda, a analise serah feita na rotina de gravacao da venda  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If CrdxInt()
       For nX := 1 to Len(aPgtos)
          If AllTrim(aPgtos[nX][3]) $ cMV_FormCRD
             lTemParcFI  := .T.
          EndIf
          If !IsMoney(Alltrim(aPgtos[nX][3])) .AND. AllTrim(aPgtos[nX][3]) <> AllTrim(MVCHEQUE)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VerIfica se deve analisar credito para a forma de pagamento e para o processo Orcamento do SIGALOJA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If AllTrim(aPgtos[nX][3]) $ cMV_FormCRD .AND. "11" $ cMV_CRDAVAL
                lTemFinanc  := .T.
                Exit
             EndIf
          EndIf
       Next nX
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Chama a tela para selecionar a Adm. Financeira quando grava orcamento,   ³
       //³tiver ao menos uma parcela em que avalia o credito e SIGACRD integrado   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If lTemFinanc
	      If !Lj7InfPgtos(nTipo)
			LjGrvLog(cNumOrc,"Após tela Administradora Financeira em Lj7InfPgtos(), retornou .F.")
			Return .F.
		  EndIf
       EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Se for finalizacao de venda, verIfica se ja ha algum contrato pendente.  ³
       //³Se tiver, utiliza este mesmo contrato para o cliente e atualiza os dados ³
       //³Busca os dados do cliente se tiver parcela financiada 					  ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If nOpc == 4 .AND. lTemParcFI
          If Empty(aCrdCliente[1]+aCrdCliente[2]) .AND. M->LQ_CLIENTE+M->LQ_LOJA <> cMV_CLIPAD+cMV_LOJAPAD

             Conout("1.LOJA701C - Lj7PrepOrc - Tem Parcela Financiada - " +;
             		" Orcamento: " +  M->LQ_NUM +;
             		" Cliente+LOJA : " + M->LQ_CLIENTE + M->LQ_LOJA + ;
             		"  Chama a funcao CrdInfClie(M->LQ_CLIENTE, M->LQ_LOJA) ")

             aCrdCliente   := AClone(CrdInfClie(M->LQ_CLIENTE, M->LQ_LOJA))

          Else
               	Conout("2.LOJA701C - Lj7PrepOrc - " + ;
               		"  Orcamento: " +  M->LQ_NUM +;
               		"  Cliente+Loja: " + M->LQ_CLIENTE+M->LQ_LOJA + ;
          			"  aCrdCliente[1] e [2] : " +;
          			If(Empty(aCrdCliente[1]), ";", aCrdCliente[1]) + ;
          			If(Empty(aCrdCliente[2]), ";", aCrdCliente[2]) )

          EndIf
       Else
       	   Conout("3.LOJA701C - Lj7PrepOrc - " 		+;
               	" Orcamento: " +  M->LQ_NUM 		+;
       			" nOpc = " + Alltrim(Str(nOpc)) 	+;
       			" lTemParcFI = " + If (lTemParcFI, ".T.", ".F.") )
       EndIf

	   Conout("4.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM     +;
	   			"  Contrato: " + If( Empty(cContrato), " ", cContrato )+;
	   			"  Total: " + Str( Lj7T_Total(2) ) +;
       			"  Chamada da funcao AprovaCrd: Lj7AprovCRD " )

       aRetCrd   := AClone(Lj7AprovCRD( "1"   ,@cContrato ,Lj7T_Total(2) ,NIL   ,;
                                         NIL   ,"11"       ,.F.           ))
       If Len(aRetCrd) > 1
          If aRetCrd[5]            //Venda rejeitada
	          Conout("5.LOJA701C - Lj7PrepOrc - " +;
	               " Orcamento: " +  M->LQ_NUM +;
	               " Contrato : " + If( Empty(cContrato), " ", cContrato )  +;
	      		   " VENDA REJEITADA.. Return(.F.) " )
	         Return (.F.)
	      ElseIf aRetCrd[1] == 2  //Aprovacao off-line
	      	 Conout("6.LOJA701C - Lj7PrepOrc - " +;
	      	 	   " Orcamento: " +  M->LQ_NUM +;
	      	       " Contrato : " + If( Empty(cContrato), "", cContrato ) +;
	      		   " Aprovacao OFF-LINE " )
	         lForcada  := .T.
	      Else
	      	 Conout("7.LOJA701C - Lj7PrepOrc - " +;
	      	 	   " Orcamento: " +  M->LQ_NUM +;
	      	       " Contrato : " + If( Empty(cContrato), "", cContrato ) )
	      	   	Conout(" aRetCrd[1] = " + If( Empty(aRetCrd[1]), "", Alltrim(STR(aRetCrd[1]))))
	      	 	Conout(" aRetCrd[2] = " + If( Empty(aRetCrd[2]), "", Alltrim(STR(aRetCrd[2]))))
	      	 	Conout(" aRetCrd[3] = " + If( Empty(aRetCrd[3]), "", Alltrim(STR(aRetCrd[3]))))
	      	 	Conout(" aRetCrd[4] = " + If( Empty(aRetCrd[4]), "", aRetCrd[4]) )
	      	 	Conout(" aRetCrd[5] = " + If( Empty(aRetCrd[5]), "", If(aRetCrd[5],".T.",".F.")))

	      EndIf
	   Else
	      Conout("8.LOJA701C - Lj7PrepOrc - "  +;
	      		   " Orcamento: " + M->LQ_NUM  +;
	               " Contrato : " + If( Empty(cContrato), " ", cContrato) +;
	      		   " Tamanho do array aRetCrd : " + Str(Len(aRetCrd)) )
       EndIf
    Else
    	Conout("9.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM + "  Sem Integracao com o CRD")
    EndIf

	If lUsaIntFS .AND. !lMVLJPDVPA    //Incluida a validacao da analise de credito

		For nX := 1 to Len(aPgtos)
			If AllTrim(aPgtos[nX][3]) == "FI"
				lTemParcFI  := .T.
			EndIf
		Next nX

	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	       //³Chama a tela para selecionar a Adm. Financeira quando grava orcamento,   ³
	       //³tiver ao menos uma parcela em que avalia o credito e SIGACRD integrado   ³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	lTemParcFI .AND. cMVCliPad + cMVLojaPad <> M->LQ_CLIENTE + M->LQ_LOJA

			Lj7InfPgtos(nTipo)

			Conout("8B.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM + "  Com Integracao com o Financial Service")

		ElseIf lTemParcFI .AND. cMVCliPad + cMVLojaPad == M->LQ_CLIENTE + M->LQ_LOJA

			lFSCliPad := .T.

			If !IsBlind()
				MsgAlert(STR0161) //"Para integraÇÃo com o Financial Services, o cliente do orçamento não poderá ser o padrÃo."
			Else
				Conout("8C.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM + "Para integracao com o Financial Services, o cliente do orçamento não poderá ser o padrao")
			EndIf
		EndIf
	EndIf


	//----------------------------------------------------------------------------
	//| Posiciona o SA1                                                          |
	//----------------------------------------------------------------------------
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA)

	//----------------------------------------------------------------------------
	//| Posiciona o SA3                                                          |
	//----------------------------------------------------------------------------
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+M->LQ_VEND)

	//----------------------------------------------------------------------------
	//| Gravacao do orcamento                                                    |
	//----------------------------------------------------------------------------
	//| A gravacao dos valores dos campos L1_VLRTOT, L1_DESCONT, L1_VLRLIQ,      |
	//| L1_VALBRUT, L1_VALMERC serao ajustadas na funcao LJRecTrib durante o     |
	//| fechamento da venda                                                      |
	//----------------------------------------------------------------------------
	//------------------------------------------
	//| Monta o array aSL1                     |
	//------------------------------------------
	aAdd( aSL1, { "L1_FILIAL", 		xFilial("SL1") } )
	aAdd( aSL1, { "L1_EMISSAO", 	dDataOrc } )
	If !ExistFunc("LjGetKeyPs") .OR. ( ExistFunc("LjGetKeyPs") .AND. LjGetKeyPs() == "F4" )
		aAdd( aSL1, { "L1_PDV", 	"" })
	EndIf	

	aTimeUf := { dDataBase, Time()}

	If cPaisLoc == "BRA"
		If cHoraRMT == "3" 
			aArea2	:= GetArea()
			dbSelectArea("SM0")
			aAreaSM0	:= GetArea()
			dbSetOrder(1)
			If dbSeek(cEmpAnt+cFilAnt)
				aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
				aTimeUf[1] := StoD(aTimeUf[1])
			EndIf
			RestArea(aAreaSM0)
			RestArea(aArea2)
		ElseIf cHoraRMT == "1" .AND. !IsBlind() 
			aTimeUf := { GetRmtDate(), GetRmtTime()}
		EndIf

	EndIf

	If lMVLJPDVPA .OR. ((lEmitNFCe .Or. lIsPafNfce) .And. !lEmiteNF)
		If !Empty(M->LQ_EMISNF) .AND. (lEmitNFCe .Or. lIsPafNfce)
			aAdd( aSL1, { "L1_EMISNF", 	  	M->LQ_EMISNF } )
		ElseIf nTipo <> 1 
			aAdd( aSL1, { "L1_EMISNF", 	  	aTimeUf[1] } )
		EndIf
	EndIf


	aAdd( aSL1, { "L1_NUM",	 		cNumOrc } )
	aAdd( aSL1, { "L1_COMIS",		SA3->A3_COMIS } )
	aAdd( aSL1, { "L1_VEND1",       "" })
	aAdd( aSL1, { "L1_VEND2",       SA3->A3_SUPER })	
	aAdd( aSL1, { "L1_VEND3",       SA3->A3_GEREN })
	aAdd( aSL1, { "L1_VEND4",       "" })
	aAdd( aSL1, { "L1_VEND5",       "" })
	aAdd( aSL1, { "L1_CLIENTE",		SA1->A1_COD } )
	aAdd( aSL1, { "L1_LOJA",		SA1->A1_LOJA } )

	//Importante limpar esse campo devido a reutilização de orçamento, afeta o LOJA140 posteriormente
	If SL1->(ColumnPos("L1_DOCCCF")) > 0
		aAdd( aSL1, {"L1_DOCCCF",""})
	EndIf
		
	If lAutoExC  //Tratamento para buscar o tipo do cliente informado no orcamento quando EXECAUTO esta posicionado o M->LQ_CLIENTE
		If !Empty(M->LQ_TIPOCLI) .AND. AllTrim(M->LQ_CLIENTE) == AllTrim(SA1->A1_COD)
			aAdd( aSL1, { "L1_TIPOCLI",		M->LQ_TIPOCLI } )
		Else
			aAdd( aSL1, { "L1_TIPOCLI",		SA1->A1_TIPO } )
		EndIf
	Else	//Tratamento para buscar o tipo do cliente informado no orcamento quando eh tela esta posicionado o SL1->L1_CLIENTE
		If !Empty(M->LQ_TIPOCLI) .AND. AllTrim(SL1->L1_CLIENTE) == AllTrim(SA1->A1_COD)
			aAdd( aSL1, { "L1_TIPOCLI",		M->LQ_TIPOCLI } )
		Else
			aAdd( aSL1, { "L1_TIPOCLI",		SA1->A1_TIPO } )
		EndIf
		
		//Tratamento para comissao dos demais vendedores na SL1
		If cPaisLoc == "BRA" .And. !lAutoExC //Funcionalidade apenas para Venda Assistida 
			For nX := 1 To 5 //Maximo de 5 vendedores 
				If SL1->(FieldPos("L1_VEND" + AllTrim(Str(nX)))) > 0 .And.; //Verifica se campo existe
					ValType(&("M->LQ_VEND" + AllTrim(Str(nX)))) <> Nil .And.; //Verifica se variavel de memoria existe			
					Empty(aSL1[aScan(aSL1, {|x| AllTrim(Upper(x[1])) == "L1_VEND" + AllTrim(Str(nX))})][2]) //Atualiza somente se posicao do vendedor no array está vazia
					
					aSL1[aScan(aSL1, {|x| AllTrim(Upper(x[1])) == "L1_VEND" + AllTrim(Str(nX))})][2] := &("M->LQ_VEND" + AllTrim(Str(nX))) //Armazena vendedor				
				EndIf	
			Next nX
		EndIf
	EndIf

	For nX := 1 To Len(aColsDet)
		If !Empty(aColsDet[nX][nPosDtReserva])
			lReserva := .T.
		Endif
	Next
	
	// Data limite da reserva não pode ser maior que a data limite do orçamento
	If lReserva .AND. SLJ->LJ_DIASRES > nMVDtlimit
		LjGrvLog( cNumOrc , "O valor do parâmetro MV_DTLIMIT deve ser maior ou igual ao do campo LJ_DIASRES. Valor de MV_DTLIMIT: ", nMVDtlimit )
		nMVDtlimit := SLJ->LJ_DIASRES
		LjGrvLog( cNumOrc , "Atribuindo o valor do campo LJ_DIASRES ao campo L1_DTLIM.", )
	EndIf

	aAdd( aSL1, { "L1_DESCNF",		Lj7T_DescP(2) } )
	If nOpc == 3 .AND. nMVDtlimit != 0
		aAdd( aSL1, { "L1_DTLIM",	M->LQ_EMISSAO + nMVDtlimit } ) // Data limite de validade do orcamento segundo o MV_DTLIMIT
	Else
		aAdd( aSL1, { "L1_DTLIM",	M->LQ_DTLIM } )                // Data limite de validade do orcamento
	EndIf
	aAdd( aSL1, { "L1_PARCELA",		Len(aPgtos) } )
	aAdd( aSL1, { "L1_CONDPG",		cCondPgto } )
	aAdd( aSL1, { "L1_TIPOJUR",		M->LQ_TIPOJUR } )
	If Len(aPgtos) > 0
		cFormaPgto := aPgtos[1][3]
	EndIf
	aAdd( aSL1, { "L1_FORMPG",		cFormaPgto } )
	aAdd( aSL1, { "L1_CONFVEN",		"SSSSSSSSNSSS" } )

	If SLQ->( ColumnPos( "LQ_CODMNEG" ) ) > 0 .And. SL1->( ColumnPos( "L1_CODMNEG" ) ) > 0
		aAdd( aSL1, { "L1_CODMNEG",		M->LQ_CODMNEG } )
	EndIf

	//Deve trazer no PAF a data do ECF - efetuado teste de validacao em homologacao
	//alterando a hora do computador, devendo estar no registro a hora do ECF
	If !lAutoExC .And. lNfPafEcf
		nRet := IFStatus( nHdlECF, '1', @cRetorno )
		If nRet == 0
			aAdd( aSL1, { "L1_HORA",	 SubStr(cRetorno,1,5) } )
		Else
			aAdd( aSL1, { "L1_HORA",	 Time() } )
		EndIf
	Else
		//Quando NFCe a hora eh atualizada no momento que atualiza Doc, para evitar rejeicao de diferenca de horario
		If (!lEmitNFCe .And. !lIsPafNfce) .Or. lEmiteNF .Or. lIntegDef
			If lIntegDef .OR. lUseSAT
				aAdd( aSL1, { "L1_HORA",		Time() } )
			Else
				aAdd( aSL1, { "L1_HORA",		aTimeUf[2] } )
			EndIf
			
		EndIf
	EndIf

	If M->LQ_TPFRET == "0" .Or. M->LQ_TPFRET == "S"		// Sem Frete
		cTpFrete := "S"
	ElseIf M->LQ_TPFRET == "1" .Or. M->LQ_TPFRET == "C"	// CIF
		cTpFrete := "C"
	ElseIf M->LQ_TPFRET == "2" .Or. M->LQ_TPFRET == "F"	// FOB
		cTpFrete := "F"
	ElseIf M->LQ_TPFRET == "3" .Or. M->LQ_TPFRET == "T"	// Terceiros
		cTpFrete := "T"
	ElseIf M->LQ_TPFRET == "4" .Or. M->LQ_TPFRET == "R"	// Próprio Remetente
		cTpFrete := "R"
	ElseIf M->LQ_TPFRET == "5" .Or. M->LQ_TPFRET == "D"	// Próprio Destinatário
		cTpFrete := "D"
	EndIf
	
	aAdd( aSL1, { "L1_TPFRET",		cTpFrete } )
	aAdd( aSL1, { "L1_FRETE", 		M->LQ_FRETE } )
	aAdd( aSL1, { "L1_SEGURO", 		M->LQ_SEGURO } )
	aAdd( aSL1, { "L1_DESPESA", 	M->LQ_DESPESA } )
	
	If SL1->(Columnpos("L1_INDPRES")) > 0 .AND. SLQ->(Columnpos("LQ_INDPRES")) > 0 

		// Para NF-e o padrão para o campo L1_INDPRES é 1, caso necessário outra opção, habilitar os campos na tela
		If Empty(M->LQ_INDPRES) .OR. ( !(X3Uso(GetSx3Cache("LQ_INDPRES","X3_USADO"))) .AND. M->LQ_INDPRES = "1" .AND. !lEmiteNF )
			If cTpFrete $ "C|F|T|R|D"
				M->LQ_INDPRES := "4"
			Else
				M->LQ_INDPRES := CRIAVAR("LQ_INDPRES")
			Endif		
		EndIf 

		aAdd( aSL1, { "L1_INDPRES", 	M->LQ_INDPRES } )
	EndIf 

	If SL1->(Columnpos("L1_INTERMD")) > 0 .AND.  SLQ->(Columnpos("LQ_INTERMD")) > 0 
		aAdd( aSL1, { "L1_INTERMD", 	M->LQ_INTERMD } )
	EndIf 

	//Tratamento integracao Mensagem Unica
	If lIntegDef 
		aAdd( aSL1, { "L1_ESPECIE",	 	M->LQ_ESPECIE } )
		aAdd( aSL1, { "L1_SERSAT" ,	 	M->LQ_SERSAT } )
		
		//Nota Fiscal
		If AllTrim(M->LQ_ESPECIE) == "NFM" .Or. AllTrim(M->LQ_ESPECIE) == "SPED"
			aAdd( aSL1, { "L1_IMPRIME",	 	"2N" } )
		Else
			aAdd( aSL1, { "L1_IMPRIME",	 	"1N" } )
		EndIf
	Else
		aAdd( aSL1, { "L1_IMPRIME",	 	"1N" } )
	EndIf
	
	aAdd( aSL1, { "L1_TIPODES", 	Str(aDesconto[1],1,0) } )
	aAdd( aSL1, { "L1_ESTACAO", 	cEstacao } )
	aAdd( aSL1, { "L1_FATOR",		M->LQ_FATOR } )
	aAdd( aSL1, { "L1_ADMFIN", 		M->LQ_ADMFIN } )
	If ( LjConcNota() .OR. !lFiscal ) .AND. SL1->(ColumnPos("L1_IMPNF")) > 0
		aAdd( aSL1, { "L1_IMPNF", 	LjNFFimVd() } )
	EndIf
	If cPaisLoc <> "BRA"
	   aAdd( aSL1, { "L1_MOEDA", 	nMoedaCor } )
	   aAdd( aSL1, { "L1_TXMOEDA", 	nTxMoeda  } )
		If SL1->( ColumnPos( "L1_PROVENT" ) ) > 0 .AND. SLQ->( ColumnPos( "LQ_PROVENT" ) ) > 0
			aAdd( aSL1, { "L1_PROVENT", M->LQ_PROVENT } )
		EndIf
	EndIf

	If lCenVenda
		aAdd( aSL1, { "L1_TABELA", 	cTabCnVda } )
	EndIf

	If !lEmitNfce
		aAdd( aSL1, { "L1_SERPDV", 	LjGetStation("LG_SERPDV") } )
	EndIf

	If AllTrim(Str(SuperGetMv("MV_LJRGMID",,0))) $ "1|2"
   		aAdd( aSL1, { "L1_MIDIA", M->LQ_MIDIA } )
	EndIf

	If lMvLjDAVOS
		If SL1->(ColumnPos("L1_NUMFAB")) > 0
			aAdd( aSL1, { "L1_NUMFAB", 	M->LQ_NUMFAB } )
		EndIf

		If SL1->(ColumnPos("L1_MARCVEI")) > 0
			aAdd( aSL1, { "L1_MARCVEI", M->LQ_MARCVEI } )
		EndIf

		If SL1->(ColumnPos("L1_MODEVEI")) > 0
			aAdd( aSL1, { "L1_MODEVEI", M->LQ_MODEVEI } )
		EndIf

		If SL1->(ColumnPos("L1_ANOFVEI")) > 0
			aAdd( aSL1, { "L1_ANOFVEI", M->LQ_ANOFVEI } )
		EndIf

		If SL1->(ColumnPos("L1_PLACVEI")) > 0
			aAdd( aSL1, { "L1_PLACVEI", M->LQ_PLACVEI } )
		EndIf

		If SL1->(ColumnPos("L1_RNVMVEI")) > 0
			aAdd( aSL1, { "L1_RNVMVEI",	M->LQ_RNVMVEI } )
		EndIf
	EndIf

	If (SL1->(ColumnPos("L1_VEIPESQ")) > 0) .AND. (SLQ->(ColumnPos("LQ_VEIPESQ")) > 0)
		aAdd( aSL1, {"L1_VEIPESQ", M->LQ_VEIPESQ} )
	EndIf

	If (SL1->(ColumnPos("L1_VEICTIP")) > 0) .AND. (SLQ->(ColumnPos("LQ_VEICTIP")) > 0)
		aAdd( aSL1, {"L1_VEICTIP", M->LQ_VEICTIP} )
	EndIf

	If (Type("M->LQ_ECFLAG") == "C")
		aAdd( aSL1, { "L1_ECFLAG",	M->LQ_ECFLAG } )
	EndIf

	If (Type("M->LQ_ECPEDEC") == "C")
		aAdd( aSL1, { "L1_ECPEDEC",	M->LQ_ECPEDEC } )
	EndIf

	If  SL1->(ColumnPos("L1_PEDPRS") > 0) .AND. !( Empty(M->LQ_PEDPRS) )
		aAdd( aSL1, { "L1_PEDPRS",	M->LQ_PEDPRS } )
	EndIf

	// Grava se o cliente recolhera o iss na venda
	If SL1->(ColumnPos("L1_RECISS")) > 0 .AND. !( Empty(M->LQ_RECISS) )
		aAdd( aSL1, { "L1_RECISS",	M->LQ_RECISS } )
	EndIf

	If SLQ->( ColumnPos( "LQ_UMOV" ) ) > 0 .And. SL1->( ColumnPos( "L1_UMOV" ) ) > 0
		aAdd( aSL1, { "L1_UMOV",		M->LQ_UMOV } )
	EndIf

	If SLQ->( ColumnPos( "LQ_UMOVINF" ) ) > 0 .And. SL1->( ColumnPos( "L1_UMOVINF" ) ) > 0
		aAdd( aSL1, { "L1_UMOVINF",		M->LQ_UMOVINF } )
	EndIf
	
	If	(lMenNota .Or. lIntegDef) .AND.  SL1->(ColumnPos("L1_MENNOTA")) > 0	
		aAdd( aSL1, { "L1_MENNOTA",		M->LQ_MENNOTA } )
	EndIf

	If (!lEmitNfce .Or. lIsPafNfce ) .AND. lNfPafEcf .AND. SL1->(ColumnPos("L1_NUMORC")) > 0 .AND. SL1->(ColumnPos("L1_TPORC")) > 0 .AND. !lFtvdVer12 .AND. !lIntegDef
		aSequencia	:= {}
		nTamOrc		:= TamSX3("LQ_NUMORC")[1]

		If !lMVLJPDVPA .AND. Empty(M->LQ_NUMORC)

			If lPreVenda
				LjxDNota(	SuperGetMv("MV_LJSERPRE",,"PRE")	, 1				, .T.	, 1		,;
							@aSequencia							, Space(nTamOrc), nil	, 1		,;
							999									, .F.			, ""	, Nil	,;
							nTamOrc								, .T. )
				aAdd( aSL1, { "L1_TPORC", 	"P" } )
			Else
				LjxDNota(	SuperGetMv("MV_LJSERDAV",,"DAV")	, 1				, .T.	, 1		,;
							@aSequencia							, Space(nTamOrc), nil	, 1		,;
							999									, .F.			, ""	, Nil	,;
							nTamOrc								, .T. )
				aAdd( aSL1, { "L1_TPORC", 	"D" } )
			EndIf

			If Len(aSequencia) > 0
				If Len(AllTrim(aSequencia[1][2])) < 10 .OR. Len(AllTrim(aSequencia[1][2])) > 13 // ATO COTEPE Requisito 6 Item II
					MsgAlert(STR0162 + " " + Alltrim(IIF(lPreVenda, SuperGetMv("MV_LJSERPRE",,"PRE"), SuperGetMv("MV_LJSERDAV",,"DAV"))) + " " + STR0163) // "O numero da serie" ; "da tabela SERIES DE N. FISCAIS (01) da Tabelas Genericas (SX5) deve conter 10 posicoes"
				EndIf

				M->LQ_NUMORC := aSequencia[1][2]
				aAdd( aSL1, { "L1_NUMORC", 	M->LQ_NUMORC } )
			EndIf

		ElseIf !lMVLJPDVPA .AND. lMvLjDAVOS //Deve-se somente gerar um novo de DAV na retaguarda

			LjxDNota(	SuperGetMv("MV_LJSERDAV",,"DAV")	, 1				, .T.	, 1		,;
						@aSequencia							, Space(nTamOrc), nil	, 1		,;
						999									, .F.			, ""	, Nil	,;
						nTamOrc								, .T. )

			aAdd( aSL1, { "L1_TPORC", 	"D" } )

			If Len(aSequencia) > 0
				If Len(AllTrim(aSequencia[1][2])) < 10 .OR. Len(AllTrim(aSequencia[1][2])) > 13 // ATO COTEPE Requisito 6 Item II
					MsgAlert(STR0162 + " " + Alltrim(SuperGetMv("MV_LJSERDAV",,"DAV")) + " " + STR0163) // "O numero da serie" ; "da tabela SERIES DE N. FISCAIS (01) da Tabelas Genericas (SX5) deve conter 10 posicoes"
				EndIf
				M->LQ_NUMORC := aSequencia[1][2]
				aAdd( aSL1, { "L1_NUMORC", 	M->LQ_NUMORC } )
			EndIf

			If SL1->(ColumnPos("L1_DVOSORI")) > 0
				aAdd( aSL1, { "L1_DVOSORI" , cNumDAVOSOrig } )
			EndIf

		Else
			If lIsPafNfce//Segundo ER-PAF-ECF 02.03 deve-se gerar como DAV a NFC-e com PAF
				aAdd( aSL1, { "L1_TPORC", 	"E" } )				
			Else
				If lPreVenda
					aAdd( aSL1, { "L1_TPORC", 	"P" } )
				Else
					aAdd( aSL1, { "L1_TPORC", 	"D" } )
				EndIf
			EndIf
			aAdd( aSL1, { "L1_NUMORC", 	M->LQ_NUMORC } )
		EndIf
    ElseIf lEmitNFCe .And. !lEmiteNF .And. nTipo == 2 //Somente gravar tipo E se finalizacao de venda NFC-E, se orcamento nao deve gravar por pode ser finalizado em uma estaca ECF.
		aAdd( aSL1, { "L1_TPORC", "E" } )
	EndIf
	
	//Integracao via Mensagem Unica, devera manter as informacoes do cupom enviados na integracao
 	If lIntegDef
    	aAdd(aSL1, {"L1_DOC"	, M->LQ_DOC})
    	aAdd(aSL1, {"L1_SERIE"	, M->LQ_SERIE})
    	aAdd(aSL1, {"L1_OPERADO", M->LQ_OPERADO}) 		 		
    	aAdd(aSL1, {"L1_PDV"	, M->LQ_PDV})
    	aAdd(aSL1, {"L1_EMISNF"	, M->LQ_EMISNF})
    	aAdd(aSL1, {"L1_TIPO"	, M->LQ_TIPO})
    	aAdd(aSL1, {"L1_SITUA"	, M->LQ_SITUA})
    	aAdd(aSL1, {"L1_STORC"	, M->LQ_STORC})  			
    	aAdd(aSL1, {"L1_KEYNFCE", M->LQ_KEYNFCE})
    	aAdd(aSL1, {"L1_PRONFCE", M->LQ_PRONFCE})	
    	aAdd(aSL1, {"L1_RESEHTL", M->LQ_RESEHTL})		 		 		
    	aAdd(aSL1, {"L1_DOCRPS"	, M->LQ_DOCRPS})
    	aAdd(aSL1, {"L1_SERRPS"	, M->LQ_SERRPS}) 		
    	aAdd(aSL1, {"L1_DOCPED"	, M->LQ_DOCPED})
    	aAdd(aSL1, {"L1_SERPED"	, M->LQ_SERPED}) 		
	EndIf
	
	lCondNeg := (Trim( cCondPgto ) == "CN")				// VerIfica se eh condicao negociada

	If !lCondNeg
		DbSelectArea( "SE4" )
		SE4->(DbSetOrder( 1 ))
		SE4->(DbSeek( xFilial( "SE4" ) + cCondPgto ))

		nPerDescFin   := E4_DESCFIN                                    	//Valor do desconto financeiro
		nPerAcrsFin   := E4_ACRSFIN                                    	//Valor do acrescimo financeiro
	EndIf
	If (lECExec .Or. lMultNeg) .And. M->LQ_JUROS > 0
		//Acrescimo Financiero
		nPerAcrsFin := M->LQ_JUROS
		LjGrvLog( cNumOrc , "Acrescimo Financeiro ", nPerAcrsFin)
	EndIf
	
	lMaFisFound := MaFisFound("NF")

    //Se for integração pega valor enviado
    If lIntegDef
        nNFTOTAL := M->LQ_VLRTOT
	ElseIf cCondPgto == "CN" .AND. MaFisRet(,'NF_VALISS') > 0
		nNFTOTAL := LJ7T_Subtotal(2)
    Else
        nNFTOTAL := IIf(lMaFisFound, MaFisRet(,"NF_TOTAL"), 0)
    EndIf

	If lFtvdVer12
		If lMaFisFound
			For nX := 1 To Len(aCols)
				If !aCols[nX][Len(aCols[nX])]
					nTotICM += MaFisRet(nX,"IT_DEDICM")
				EndIf
			Next nX
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso exista um desconto financeiro (apenas por condicao de pagamento)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPerDescFin > 0
        If lFtvdVer12 .AND. nOpc == 4
			Lj7T_DescV(2,0)
			Lj7T_DescP(2,0)
        EndIf
        
        nLj7TDescV	:= iif(LjNewCalSol(),0 ,Lj7T_DescV(2))

		If !lFtvdVer12
			If nMvLjTpDes <> 2
                If nNCCUsada <= (nNFTOTAL - nLj7TDescV)
    				nVlrDescFin += NoRound( ( ( nNFTOTAL - nLj7TDescV - nNCCUsada) * nPerDescFin) / 100, TamSx3("L2_VRUNIT")[2] )
                EndIf
			Else
				If nNCCUsada <= (nNFTOTAL - nLj7TDescV)
					nVlrDescFin += A410Arred( ( ( nNFTOTAL - nLj7TDescV - nNCCUsada ) * nPerDescFin) / 100, "D2_DESCON" )
				EndIf
			EndIf
       ElseIf lFtvdVer12
			If nMvLjTpDes <> 2
				nVlrDescFin += NoRound((( nNFTOTAL + nTotICM - nLj7TDescV ) * nPerDescFin) / 100, TamSx3("L2_VRUNIT")[2] )
			Else
				nVlrDescFin += A410Arred(((nNFTOTAL + nTotICM - nLj7TDescV ) * nPerDescFin) / 100, "D2_DESCON" )
			EndIf
		EndIf

		nDescontFi := nVlrDescFin
		LjGrvLog( cNumOrc , "Desconto Financeiro Valor ", nVlrDescFin)		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tira o valor do acrescimo financeiro do total porque nao deve incidir ³
	//³ impostos, pois trata-se de um acrescimo condicional (dado na condicao ³
	//³ de pagamento)                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPerAcrsFin > 0     	        
        If nTipo == 2
	     	If nMvLjTpDes <> 2  
				nVlrAcreFin += NoRound( ((nNFTotal - nVlrFSD - Lj7T_DescV(2)) * nPerAcrsFin) / 100, TamSx3("L2_VALDESC")[2] )
			Else
	          	nVlrAcreFin += A410Arred(((nNFTotal - nVlrFSD - Lj7T_DescV(2)) * nPerAcrsFin) / 100, "D2_VALACRS")
	        EndIf
	    Else
	    	If nMvLjTpDes <> 2  
				nVlrAcreFin += NoRound( ((nNFTotal - Lj7T_DescV(2)) * nPerAcrsFin) / 100, TamSx3("L2_VALDESC")[2] )
			Else
	          	nVlrAcreFin += A410Arred(((nNFTotal - Lj7T_DescV(2)) * nPerAcrsFin) / 100, "D2_VALACRS")
	        EndIf
	    
	    EndIf 
        LjGrvLog( cNumOrc , "Acrescimo Financeiro Valor ", nVlrAcreFin)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Localizacoes                      ³
	//³Somar o calculo de juros ao acrescimo financeiro.³
	//³Paises: Chile / Colombia  - F1CHI                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLocR5 .AND. lCondNeg .AND. M->LQ_JUROS > 0
		nVlrAcreFin += NoRound( (nNFTOTAL * M->LQ_JUROS) / 100, TamSx3("L2_VALDESC")[2] )
	EndIf

	If lMaFisFound .AND. !(nRotina == 4 .AND. !Empty(SL1->L1_ORCRES))
		
		If nVlrAcreFin > 0 
			MaFisAlt("NF_ACRESCI", nVlrAcreFin)
		EndIf

		If cPaisLoc <> "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³L1_DESCONT -> Desconto sobre o Total sem Desc. Fin.                                           ³
			//³L1_VLRTOT  -> Total dos Itens (com Descontos aplicados) + Acresc. Fin. - Desc. Fin. - nVlrFSD ³
			//³L1_VALBRUT -> Total dos Itens (com Descontos aplicados) + Acresc. Fin. - Desc. Fin. - nVlrFSD ³
			//³L1_VLRLIQ  -> Valor das Mercadorias com Descontos e sem Imposto                               ³
			//³L1_VALMERC -> Valor das Mercadorias com Descontos e sem Imposto                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aSL1, { "L1_DESCONT"	, Lj7T_DescV(2) } )
			aAdd( aSL1, { "L1_VLRTOT"	, A410Arred( ( nNFTOTAL + nVlrAcreFin - nVlrDescFin - nVlrFSD ), "L1_VALIMP1",nMoedaCor) } )
			aAdd( aSL1, { "L1_VALBRUT"	, A410Arred( ( nNFTOTAL + nVlrAcreFin - nVlrDescFin - nVlrFSD ), "L1_VALIMP1",nMoedaCor) } )
			aAdd( aSL1, { "L1_VLRLIQ"	, nNFTOTAL } )
			aAdd( aSL1, { "L1_VALMERC"	, nNFTOTAL } )

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajuste da gravacao dos dados do SL1 para a venda                                       ³
			//³                                                                                        ³
			//³ Exemplo de gravavao dos campos                                                         ³
			//³ Venda de 1 item de R$100,00 com:                                                       ³
			//³                          L1_VLRTOT   L1_DESCONT   L1_VLRLIQ   L1_VALBRUT   L1_VALMERC  ³
			//³ Acresc.financ de 10%        100.00         0.00      110.00      110.00       100.00   ³
			//³ Descon.financ de 10%        100.00        10.00       90.00       90.00       100.00   ³
			//³ Descon.total  de 10%         90.00        10.00       90.00       90.00       100.00   ³
			//³ Descon.item   de 10%         90.00         0.00       90.00       90.00       100.00   ³
			//³	                                                                                       ³
			//³ Obs.1: A gravacao dos campos tem como base a gravacao da Venda Balcao para mantermos   ³
			//³ o legado das customizacoes.                        ³                                   ³
			//³                                                                                        ³
			//³ Obs.2: Nao eh necessario dar um RecLock no SL1, pois esta preso desde o inicio da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLj7TDescV	:= iif(LjNewCalSol(),0 ,Lj7T_DescV(2))
			aAdd( aSL1, { "L1_VLRTOT",	nNFTOTAL - nLj7TDescV })			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se trabalhar com o conceito de acrescimo separado, ³
			//³não grava o acrescimo no valor do cupom, pois o    ³
			//³mesmo sera gravado no Contas a receber (SE1)       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVerEmpres .OR. SuperGetMV("MV_LJICMJR",,.F.)
			   	aAdd( aSL1, { "L1_VLRLIQ",	( nNFTOTAL - nLj7TDescV + nVlrFSD - nVlrDescFin) } )
		   	   	aAdd( aSL1, { "L1_VALBRUT",	( nNFTOTAL - nLj7TDescV + nVlrFSD - nVlrDescFin) } )
			Else
		   		aAdd( aSL1, { "L1_VLRLIQ",	( nNFTOTAL - nLj7TDescV + nVlrAcreFin + nVlrFSD - nVlrDescFin) } )

		   		If nOpc == 4 .And. nTipo == 2 .And. MaFisRet(,"NF_SUFRAMA")
		   			aAdd( aSL1, { "L1_VALBRUT",	( MaFisRet(,"NF_VALMERC") - nLj7TDescV + nVlrAcreFin + nVlrFSD - nVlrDescFin) } )
		   		Else
		   	    	aAdd( aSL1, { "L1_VALBRUT",	( nNFTOTAL - nLj7TDescV + nVlrAcreFin + nVlrFSD - nVlrDescFin) } )
		   	    EndIf
			Endif

			If !MaFisRet(,"NF_SUFRAMA")
				aAdd( aSL1, { "L1_VALMERC",	MaFisRet(,"NF_VALMERC") } )
			Else
				aAdd( aSL1, { "L1_VALMERC",	MaFisRet(,"NF_VALMERC") + 	MaFisRet(,"NF_DESCZF") } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconto financeiro só será lancado ao total de desconto quando for finalização da VENDA     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aSL1, { "L1_DESCONT",	Lj7T_DescV(2) + iIf(nTipo == 2,nVlrDescFin,0) } ) // Desconto sobre o Total +  desconto Financeiro

			aAdd( aSL1, { "L1_DESCFIN",	nVlrDescFin } ) // Desconto Financeiro

            //Fidelização (Fidelity Core)
            If nTipo == 2 .And. ExistFunc("LjxRaasInt") .And. LjxRaasInt()
                aAdd( aSL1, {"L1_DESCFID", Lj7FidDesc() } )

                aAdd( aSL1, {"L1_FIDCORE", Lj7FidAtv()  } )
            EndIf
			
			If lIntegDef //Tratamento de impostos - Integracao
				aAdd( aSL1, { "L1_VALICM",	IIF(ValType(M->LQ_VALICM) == "N", M->LQ_VALICM, 0)} )
				aAdd( aSL1, { "L1_VALISS",	IIF(ValType(M->LQ_VALISS) == "N", M->LQ_VALISS, 0)} )
				
				//Valores de IPI
				aAdd( aSL1, { "L1_VALIPI",  IIF(ValType(M->LQ_VALIPI) == "N", M->LQ_VALIPI, 0)} )
				If SL1->( ColumnPos( "L1_BASEIPI" ) ) > 0
					aAdd( aSL1, { "L1_BASEIPI",  IIF(Type("M->LQ_BASEIPI") == "N", M->LQ_BASEIPI, 0)} )
				EndIf
				
				//Valores de ICMS Solidario (ICMS-ST)
				aAdd( aSL1, { "L1_BRICMS",  IIF(Type("M->LQ_BRICMS") == "N", M->LQ_BRICMS, 0)} )
				aAdd( aSL1, { "L1_ICMSRET",  IIF(Type("M->LQ_ICMSRET") == "N", M->LQ_ICMSRET, 0)} )
			Else
				aAdd( aSL1, { "L1_VALICM",	MaFisRet(,"NF_VALICM" ) } )
				aAdd( aSL1, { "L1_VALISS",	MaFisRet(,"NF_VALISS" ) } )
				aAdd( aSL1, { "L1_VALIPI",  MaFisRet(,"NF_VALIPI" ) } )
				
				//Valores de ICMS Solidario (ICMS-ST)
				aAdd( aSL1, { "L1_BRICMS",	MaFisRet(,"NF_BASESOL" ) } )
				aAdd( aSL1, { "L1_ICMSRET",	MaFisRet(,"NF_VALSOL" ) } )
			EndIf

			lRetemPCC := LjRetemPCC(MaFisRet(,"NF_TOTAL"), MaFisRet(,'NF_VALPIS'), MaFisRet(,'NF_VALCOF'), MaFisRet(,'NF_VALCSL'))
			
			If lIntegDef //Tratamento de impostos PIS, COFINS e CSLL - Integracao
				aAdd(aSL1, {"L1_VALPIS" , IIF(ValType(M->LQ_VALPIS) == "N", M->LQ_VALPIS, 0)})
				aAdd(aSL1, {"L1_VALCOFI", IIF(ValType(M->LQ_VALCOFI) == "N", M->LQ_VALCOFI, 0)})
				aAdd(aSL1, {"L1_VALCSLL", IIF(ValType(M->LQ_VALCSLL) == "N", M->LQ_VALCSLL, 0)})				
			ElseIf lRetemPCC
				aAdd(aSL1, {"L1_VALPIS" , If( LJPCCRet(1) > 0, LJPCCRet(1), MaFisRet(,'NF_VALPIS') ) })
				aAdd(aSL1, {"L1_VALCOFI", If( LJPCCRet(2) > 0, LJPCCRet(2), MaFisRet(,'NF_VALCOF') ) })
				aAdd(aSL1, {"L1_VALCSLL", If( LJPCCRet(3) > 0, LJPCCRet(3), MaFisRet(,'NF_VALCSL') ) })
			Else
				aAdd(aSL1, {"L1_VALPIS" , 0 })
				aAdd(aSL1, {"L1_VALCOFI", 0 })
				aAdd(aSL1, {"L1_VALCSLL", 0 })
			EndIf
	 	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se existir o campo L1_ABTOPCC (onde é gravado o valor de abatimento de PIS/COFINS/CSLL)³
			//³ grava o valor abatido do total da venda.                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If lRetemPCC
				aAdd(aSL1, { "L1_ABTOPCC", If( LJPCCRET()>0, LJPCCRET(), MaFisRet(,'NF_VALPIS')+MaFisRet(,'NF_VALCOF')+MaFisRet(,'NF_VALCSL') ) })
			Else
				aAdd(aSL1, {"L1_ABTOPCC", 0 })
			EndIf
			
	 		aAdd(aSL1, {"L1_VALINSS", MaFisRet(,'NF_VALINS') })		 	
		 	
		 	If lIntegDef //Integracao mantem o valor do imposto IRRF enviado no xml
		 		aAdd(aSL1, {"L1_VALIRRF", IIF(ValType(M->LQ_VALIRRF) == "N", M->LQ_VALIRRF, 0)})	
		 	Else
		 		aAdd(aSL1, {"L1_VALIRRF", MaFisRet(,'NF_VALIRR') })
		 	EndIf
		 	
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valoriza os campos referentes aos impostos variáveis...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a gravacao do troco em sua respectiva moeda...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY := 1 To nMoedExist
			If ( ( nPos := aScan( aMoedas,{ |x| x[6] == nY } ) )  > 0 )
				AAdd(aSL1,{"L1_TROCO" + Alltrim(Str(nY)), aMoedas[nPos][3]})
			EndIf
		Next nY

		For nY := 1 to Len(aImpsSL1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³tratamento para clientes responsaveis inscritos, porque ³
			//³o calculo dos impostos na ecf sao feitos de maneira     ³
			//³diferente para esses clientes.	                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			nPos := Ascan(aSL1,{|x| Trim(x[1]) == aImpsSL1[nY][2]})

            If cPaisLoc == "ARG" .AND. ALLTRIM(SA1->A1_TIPO) == "I"
                If nPos > 0
					aSL1[nPos][2] += A410Arred(aImpsSL1[nY][8],"L1_VALIMP1")   //Valor do imposto
                Else
	               	Aadd(aSL1,{aImpsSL1[nY][2],A410Arred(aImpsSL1[nY][8],"L1_VALIMP1")})   //Valor do imposto
	            EndIf
            Else
                If nPos > 0
 					aSL1[nPos][2] += A410Arred(aImpsSL1[nY][3],"L1_VALIMP1",nMoedaCor)   //Valor do imposto
    	      	Else
	 		      	Aadd(aSL1,{aImpsSL1[nY][2],A410Arred(aImpsSL1[nY][3],"L1_VALIMP1",nMoedaCor)})   //Valor do imposto
 		      	EndIf
	      	EndIf

			nPos := Ascan(aSL1,{|x| Trim(x[1]) == aImpsSL1[nY][4]})
            If nPos > 0
				aSL1[nPos][2] += aImpsSL1[nY][5]   //Base do imposto
            Else
				Aadd(aSL1,{aImpsSL1[nY][4],aImpsSL1[nY][5]})   //Base do imposto
            EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acerta o valor liquido abatendo o valor dos impostos...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	  	If aImpsSL1[nY][06] == "1"
				nPos := Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRLIQ"})
				If nPos > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  		//³ Subtrai do total o valor do imposto sem arredondamento     ³
			  		//³e depois pega apenas a parte inteira para nao dar dIferenca ³
			 		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aSL1[nPos][2] -= aImpsSL1[nY][8]

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³tratamento para clientes responsaveis inscritos, porque ³
					//³o calculo dos impostos na ecf sao feitos de maneira     ³
					//³diferente para esses clientes.	                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		            If cPaisLoc == "ARG" .AND. ALLTRIM(SA1->A1_TIPO) == "I"
          				aSL1[nPos][2]:=  A410Arred(aSL1[nPos][2],"L1_VALIMP1")
                    Else
						aSL1[nPos][2]:=  NoRound(aSL1[nPos][2],TamSx3("L1_VALIMP1")[2])
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³No caso do recuperamento da Venda que foi gravada   ³
					//³como orcamento verIfica os valores (Arredondamento) ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					nDIf := 1 / (10 ^ nDecimais)
					If ( SL1->L1_VALMERC > 0 ) .AND. ABS((SL1->L1_VALMERC - aSL1[nPos][2])) <= nDIf
						aSL1[nPos][2] := SL1->L1_VALMERC
					EndIf
		  		EndIf
		  	EndIf
  		Next nI

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Implementação continua. VerIfica a existencia dos elementos na Array³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Ascan(aSL1,{|x| Trim(x[1]) == "L1_VALMERC"}) > 0 .AND. Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRLIQ"}) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acerta o valor da mercadoria com base no valor liquido da venda...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VALMERC"})][2] := aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRLIQ"})][2]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe os campos de base e valor de impostos	   ³
		//³se nao tem carregado na array aSL1 incluir zerado para nao  ³
		//³ficar sujeira quando e' modificado um orçamento ja gravado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To 9
			cValImpCam := "L1_VALIMP" + StrZero(nX,1)
			cBasImpCam := "L1_BASIMP" + StrZero(nX,1)
			If SL1->( ColumnPos( cValImpCam ) ) > 0 .AND. SL1->( ColumnPos( cBasImpCam ) ) > 0
				If Ascan(aSL1,{|x| AllTrim(x[1]) == cValImpCam}) == 0 .AND. Ascan(aSL1,{|x| AllTrim(x[1]) == cBasImpCam}) == 0
					Aadd(aSL1,{cValImpCam,0})   //Valor do imposto
					Aadd(aSL1,{cBasImpCam,0})   //Base de imposto
				EndIf
			EndIf
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria a lista de campos de troco. Essa lista é utilizada para³
		//³bloquear a adição automática desses campos no aSL1          ³
		//³pois eles são adicionados manualmente.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To nMoedExist
			aAdd( aCposTroco, "L1_TROCO" + Alltrim(Str(nX)) )
		Next nX
	Else

		If nTPCompNCC <> 4 .AND. nNCCUsada > Lj7T_Total(2)
			nVlrTroco := 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para o caso do Brasil, existe apenas a gravacao do Troco em 1 moeda³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL1->( ColumnPos( "L1_TROCO1" ) ) > 0 .AND. GetNewPar( "MV_LJTROCO", .F. ) .AND. nVlrTroco >= 0
				AAdd( aSL1, { "L1_TROCO1", nVlrTroco } )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria a lista de campos de troco. Essa lista é utilizada para³
		//³bloquear a adição automática desses campos no aSL1          ³
		//³pois eles são adicionados manualmente.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aCposTroco, "L1_TROCO1" )
	EndIf

	If CrdXInt()
		aAdd( aSL1, { "L1_CONTRA", cContrato })

		Conout("10.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM +;
               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
      		   " adiciona CONTRATO no array SL1. " )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controlar se a venda foi off-line (1) ou uma venda on-line (2) - WebService³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lForcada
		     aAdd( aSL1, {"L1_FORCADA", Str(FORCADA,1) } )
	
		     Conout("11.LOJA701C - Lj7PrepOrc - " +;
		     	   " Orcamento: " +  M->LQ_NUM +;
	               " Contrato : " + If (Empty(cContrato), "", cContrato) +;
	      		   " adiciona L1_FORCADA array SL1. " )
	
			 If SL1->(FieldPos("L1_CGCCART")) > 0
			    If Empty(aCrdCliente[1]+aCrdCliente[2]) .AND. M->LQ_CLIENTE+M->LQ_LOJA <> cMV_CLIPAD+cMV_LOJAPAD
			         aCrdCliente  := AClone(CrdInfClie(M->LQ_CLIENTE, M->LQ_LOJA))
			    EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava no campo L1_CGCCART o Numero do CGC/CPF ou Numero do Cartao do Cliente, o que tiver sido ³
				//³informado.                                                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AADD( aSL1, {"L1_CGCCART", If(!Empty(aCrdCliente[1]), aCrdCliente[1], aCrdCliente[2]) } )
	
				Conout("12.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM +;
			            " Cliente+Loja : " + M->LQ_CLIENTE+M->LQ_LOJA +;
	               		" Contrato :  " + If (Empty(cContrato), "", cContrato) +;
	               		" L1_CGCCART: " + If(!Empty(aCrdCliente[1]), aCrdCliente[1], aCrdCliente[2])+;
	               		" Preenche aSL1(L1_CGCCART) . " )
			 EndIf
		Else
	
	          Conout("13.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM +;
		            " Cliente+Loja : " + M->LQ_CLIENTE+M->LQ_LOJA +;
	           		" Contrato: " + If (Empty(cContrato), "", cContrato) +;
	  		   		" Preenche aSL1(FORCADA)=NAOFORCADA e  aSL1(CGCCART)= " )
	
		     aAdd( aSL1, {"L1_FORCADA", Str(NAOFORCADA,1) } )
			 aAdd( aSL1, {"L1_CGCCART", "" } )
		EndIf
    Else
    	Conout("14.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM + "  Sem Integracao com o CRD")
    EndIf

	aAux := {	"L1_VEND"	, "L1_JUROS"	, "L1_TIPOJUR"	, "L1_TRANSP"	,;
				"L1_ENDCOB"	, "L1_BAIRROC"	, "L1_MUNC"		, "L1_CEPC"		,;
				"L1_ESTC"	, "L1_ENDENT"	, "L1_BAIRROE"	, "L1_MUNE"		,;
				"L1_CEPE"	, "L1_ESTE"		, "L1_VOLUME"	, "L1_ESPECIE"	,;
				"L1_MARCA"	, "L1_NUMERO"	, "L1_PLIQUI"	, "L1_PBRUTO"	,;
				"L1_PLACA"	, "L1_UFPLACA"	, "L1_FRETE"	, "L1_SEGURO"	,;
				"L1_DESPESA" ,"L1_ESPECI1"}
	
	If SL1->( ColumnPos( "L1_VEICUL1" ) ) > 0
		aAdd( aAux, "L1_VEICUL1" )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta o array aSL1                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aAux)//Nao pode alterar o endereco de entrega por causa dos impostos fiscais
		cCampo := "M->LQ_"+Trim(Substr(aAux[nX],4,Len(aAux[nX])))
		aAdd( aSL1, { aAux[nX], &(cCampo) } )
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se existem campos de usuario que estao sendo utilizados para    ³
	//³ gravacao do SL1                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->(DbSetOrder(2))
	DbSelectArea("SL1")
	DbSetOrder(1)
	For nX := 1 to FCount()
		cCampo := FieldName(nX)
		If SX3->( DbSeek(PadR(cCampo,10," ")) )
			If	SX3->X3_PROPRI $ "UT" .AND. X3Uso(SX3->X3_USADO)
				If Ascan(aSL1,{|x| AllTrim(x[1]) == AllTrim(cCampo)}) == 0
					If !FieldName(nX) $ "L1_NUMORC|L1_TPORC|L1_PAFMD5"
						cCampo := "M->LQ_"+	Trim(Substr(FieldName(nX),4,Len(FieldName(nX))))
						aAdd( aSL1, { FieldName(nX), &(cCampo) } )
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX

	LjGrvLog(cNumOrc,"EMITE NFCe",lEmitNFCe)
	If LjHomolPaf()
		LjGrvLog(cNumOrc,"EMITE NFCe no PAF-ECF",lIsPafNfce)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se existem campos de usuario que estao sendo utilizados para    ³
	//³ gravacao do SL2                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->(DbSetOrder(2))
	For nX := 1 to len(aHeader)
		If SX3->(DbSeek(aHeader[nX][2]))
			If SX3->X3_PROPRI $ "UT" .AND. X3Uso(SX3->X3_USADO)
				aAdd( aCamposU, { AllTrim("L2_"+SubStr(SX3->X3_CAMPO,4)), nX } )
			EndIf
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa as proporcoes dos itens                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrItens := 0
	aEval( aCols, {|x| If(!x[Len(x)], nVlrItens += x[nPosVlrItem], Nil) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ha algum item deletado no aCols.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4	//Primeiro, para todos os países.
		If ( (AllTrim(Str(SuperGetMv("MV_LJGERSC",,1))) $ "2|3") ) //como na exclusão NF
			For nX := 1 To Len(aCols)
				If aCols[nX][Len(aCols[nX])] .AND. iif(nPosSolCom>0,!Empty(aColsDet[nX][nPosSolCom]),.F.)  //Se deletado e Número da Solicitação de Compra preenchido
					// Incluído a passagem de novos parâmetros, para proteção do Robô dentro da função LA590CncVA
   					LA590CncVA(cNumOrc, xFilial("SL1"), aColsDet[nX][nPosSolCom], IIf(nPosFilRes>0,aColsDet[nX][nPosFilRes],""), aCols, nPosProd, nPosQuant)
					// Após encontrar um item deletado, sai do "For/Next", pois o tratamento de exclusão é função LA590CncVA
					// e todas as Solitações que atendem as condições, já foram excluídas e todo array aCols percorrido
					Exit   
				EndIf
			Next nX
		Endif
	EndIf
	If nOpc == 4 .AND. cPaisLoc <> "BRA"
		For nX := 1 To Len(aCols)
			If aCols[nX][Len(aCols[nX])]
				lDelete := .T.
				Exit
			EndIf
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rateio de ISS - Final³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//Iniciamos o array usado na funcao Lj7Arred, pois usaremos ela para proporcionalizar o Acrescimo Financeiro
	Lj7Arred(1)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array aSL2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Quando PAF-ECF, deve armazenar o registro mesmo quando deletado no banco, sinalizando o cancelamento
	For nX := 1 to Len(aCols)
		//Qdo Paf-Ecf verifica se o aCols está em branco pois qdo linha deletada em branco não deve continuar
		If (!aCols[nX][Len(aCols[nX])] .OR. (lNfPafEcf .AND. !Empty(AllTrim(aCols[nX][2])))) .And. !(Empty( aCols[nX][nPosProd] ))

			If cTpComiss == "1"
				cVend := M->LQ_VEND
			Else
				cVend := aCols[nX][nPosVend]

				// Gravação dos Vendedores informados na L2 quando o parametro MV_LJTPCOM = 2  , serão gravados na SF2
			    If !Empty(cVend) .AND. aScan(aVendDig,cVend) == 0 // não pode haver vendedores repetidos no array
			        aAdd(aVendDig,cVend)
			    Endif

				// Comissao de Parceiros
				If lParceiros
					cParceiro := aCols[nX][nPosParc]
					If nX == 1
						Lj7SetParceiros({})
					EndIf
					aParc	 := Lj7GetParceiros()
					aAdd( aParc , { cParceiro , aCols[nX][nPosItem] , aCols[nX][nPosProd] , aCols[nX][nPosDescri] } )
					Lj7SetParceiros(aParc)
				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Checa se existe reserva                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aColsDet[nX][nPosDtReserva])
				lReserva := .T.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o SB1 , SF4 e SB0                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+ aCols[nX][nPosProd]))

			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+ aColsDet[nX][nPosDtTes]))

			SB0->(DbSetOrder(1))
			SB0->(DbSeek(xFilial("SB0")+ aCols[nX][nPosProd]))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua o Calculo do Preco de Tabela que sera gravado no SL2              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aColsDet[nX][nPosDtPrcTab])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se foi escolhida uma tabela zerada para alteração, grava o valor  ³
				//³ digitado no preco unitario do item.                               ³
				//³ Caso tenha o desconto no item, este deve ser somado para que o    ³
				//³ valor de preco de tabela fique correto							  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPrcTab := aCols[nX][nPosVrUnit] + (aCols[nX][nPosValDesc] / aCols[nX][nPosQuant])
			Else
				If cPaisLoc <> "BRA"
					If lCenVenda
						LjxeValPre(	@nPrcTab	, aCols[nX][nPosProd], M->LQ_CLIENTE, M->LQ_LOJA,;
									nMoedaCor	, aCols[nX][nPosQuant] )
					Else
						If SB0->(DbSeek(xFilial("SB0") + aCols[nX][nPosProd]))		//COD. PRODUTO
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Se existir o campo (B0_MOEDA + Tabela utilizada), verIfica se a ³
							//³ moeda da tabela e'a moeda corrente. Se nao for, faz a conversao ³
							//³ e grava o valor na moeda corrente.                              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    	    		If SB0->(FieldPos("B0_MOEDA" + aColsDet[nX][nPosDtTabela])) > 0
				            	If  &("SB0->B0_MOEDA" + aColsDet[nX][nPosDtTabela]) <> nMoedaCor
									nPrcTab := 	xMoeda(	aColsDet[nX][nPosDtPrcTab],;
														&("SB0->B0_MOEDA" + aColsDet[nX][nPosDtTabela]),;
														nMoedaCor,;
														dDataBase,;
														nDecimais)
		        		    	Else
									nPrcTab	:= aColsDet[nX][nPosDtPrcTab]
					    		EndIf
				    	  	Else
		        		   		nPrcTab := aColsDet[nX][nPosDtPrcTab]
				            EndIf
						Else
	        		   		nPrcTab := aColsDet[nX][nPosDtPrcTab]
						EndIf
					EndIf
				Else
					nPrcTab := aColsDet[nX][nPosDtPrcTab]
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o array aSL2                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aSL2, {} )

			//PAF-ECF: Sinaliza Registro deletado -- ultima posicao do aCols sinaliza registro marcado como deletado, quando PDV PAF nao soma na Qtde de Itens
			If lNfPafEcf .AND. aCols[nX][Len(aCols[nX])]
				aAdd( aSL2[Len(aSL2)], { REG_DELETED	, .T. } )
				If !lMVLJPDVPA
					cItem := SomaIt( cItem )
				EndIf
			Else
				cItem := SomaIt( cItem )
			EndIf

			aAdd( aSL2[Len(aSL2)], { "L2_FILIAL"	, xFilial("SL2") } )
			aAdd( aSL2[Len(aSL2)], { "L2_NUM"		, cNumOrc } )
			aAdd( aSL2[Len(aSL2)], { "L2_ITEM"		, cItem } )
			aAdd( aSL2[Len(aSL2)], { "L2_PRODUTO"	, aCols[nX][nPosProd] } )
			
			If lNfPafEcf 
				//CONVÊNIO ICMS 25, DE 8 DE ABRIL DE 2016
				aAdd( aSL2[Len(aSL2)], { "L2_DESCRI", LjDscCESCF(aCols[nX][nPosDescri],nX) } )
				
				If Empty( AllTrim( SB1->B1_IPPT )) .Or. Empty( AllTrim( SB1->B1_IAT ))
					Conout(" Campo B1_IPPT/B1_IAT em branco, por ser obrigatório no PAF-ECF preenchido com conteúdo padrão ")
					LjGrvLog( NIL ," Campo B1_IPPT/B1_IAT em branco, por ser obrigatório no PAF-ECF preenchido com conteúdo padrão")
					
					nRecnoSB1 := SB1->(Recno())
					
					RecLock("SB1",.F.)
					
					If Empty( AllTrim( SB1->B1_IPPT ))
						REPLACE SB1->B1_IPPT WITH "T"
					EndIf
					
					REPLACE SB1->B1_IAT	WITH IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" )
					SB1->(MsUnlock())
					
					cMD5Sb1 := STxPafMd5("SB1")
					
					RecLock("SB1",.F.)
					REPLACE SB1->B1_PAFMD5 WITH cMD5Sb1
					SB1->(MsUnlock())
					
					SB1->(DbGoTo(nRecnoSB1))
				EndIf

				If SL2->(ColumnPos("L2_IAT")) > 0
					aAdd( aSL2[Len(aSL2)], { "L2_IAT"		, IIf( SuperGetMV("MV_ARREFAT",,"N") == "S", "A", "T" ) })
				EndIf
				
				If SL2->(ColumnPos("L2_IPPT")) > 0
					aAdd( aSL2[Len(aSL2)], { "L2_IPPT"		, SB1->B1_IPPT })
				EndIf

				If SL2->(ColumnPos("L2_DECQTD")) > 0
					aAdd( aSL2[Len(aSL2)], { "L2_DECQTD", 	TamSX3("L2_QUANT")[2] } )
				EndIf
				
				If SL2->(ColumnPos("L2_DECVLU")) > 0
					aAdd( aSL2[Len(aSL2)], { "L2_DECVLU", 	TamSX3("L2_VRUNIT")[2] } )
				EndIf
			Else
				aAdd( aSL2[Len(aSL2)], { "L2_DESCRI", aCols[nX][nPosDescri] } )
			EndIf
			
			aAdd( aSL2[Len(aSL2)], { "L2_QUANT"	, aCols[nX][nPosQuant] } )

			If cPaisLoc <> "BRA"
				If cMvDescSai == "2"
					aAdd( aSL2[Len(aSL2)], { "L2_VRUNIT"	, NoRound(( MaFisRet(nX, "IT_VALMERC") - MaFisRet(nX, "IT_DESCONTO")) / aCols[nX][nPosQuant] ,TamSX3("D2_PRCVEN")[2] )  } )
				Else
					aAdd( aSL2[Len(aSL2)], { "L2_VRUNIT"	, MaFisRet(nX, "IT_PRCUNI")  } )
				EndIf
			Else

				If MaFisRet(,"NF_SUFRAMA")
					If (nOpc == 3 .And. nTipo <> 1) .OR. (nOpc == 4 .And. nTipo == 2)						
						aAdd( aSL2[Len(aSL2)], { "L2_VRUNIT"	, aCols[nX][nPosVrUnit] - (MaFisRet(nX, "IT_DESCZF") / aCols[nX][nPosQuant])} )
					ElseIf nOpc == 4 .Or. nTipo == 1
						aAdd( aSL2[Len(aSL2)], { "L2_VRUNIT"	, aCols[nX][nPosVrUnit]} )
					EndIf
				ElseIf lIntegDef .and. aColsDet[nX][nPosDtDProp] > 0	//Incluido desconto no valor unitario para proporcionalização no desconto no item e devido o padrão de gravação da SC5 e SC6.					
					aAdd( aSL2[Len(aSL2)], { "L2_VRUNIT", aCols[nX][nPosVrUnit] - (aColsDet[nX][nPosDtDProp] / aCols[nX][nPosQuant]) } )
				Else
					aAdd( aSL2[Len(aSL2)], { "L2_VRUNIT", aCols[nX][nPosVrUnit]})
				EndIf
			EndIf

			//Campos de itens Mostruario/Saldao
			If SL2->(ColumnPos("L2_VDMOST")) > 0 .AND. nPosMostruario > 0
				aAdd( aSL2[Len(aSL2)], { "L2_VDMOST"		, aCols[nX][nPosMostruario] } )
			EndIf

			If SL2->(ColumnPos("L2_VDOBS")) > 0 .AND. nPosObsMostrua > 0
				aAdd( aSL2[Len(aSL2)], { "L2_VDOBS"			, aCols[nX][nPosObsMostrua] } )
			EndIf

			If SL2->(ColumnPos("L2_VLTROCA")) > 0 .AND. nPosVlTroca > 0
				aAdd( aSL2[Len(aSL2)], { "L2_VLTROCA"			, aCols[nX][nPosVlTroca] } )
			EndIf

			If SL2->(ColumnPos("L2_ISVFE")) > 0
				aAdd( aSL2[Len(aSL2)], { "L2_ISVFE"			, LjRetVFE() } )
			EndIf

			If SL2->(ColumnPos("L2_FILPED")) > 0  .AND. nPosFILPED > 0
				aAdd( aSL2[Len(aSL2)], { "L2_FILPED"		, aCols[nX][nPosFILPED] } )
			EndIf

			If SL2->(ColumnPos("L2_CEST")) > 0  .AND. nPosCEST > 0 .AND. nPosCEST <= Len(aColsDet[nX])
				aAdd( aSL2[Len(aSL2)], { "L2_CEST"		, aColsDet[nX][nPosCEST] } )
			EndIf

			If cPaisLoc == "BRA"

				If !lFtvdVer12 .AND. nVlrAcreFin > 0	//proporcionamos o Acrescimo Financeiro ao salvar o orcamento
					aAdd( aSL2[Len(aSL2)], { "L2_VALACRS", Lj7Arred(2, 3, ((nVlrAcreFin*MaFisRet(nX,"IT_TOTAL"))/MaFisRet(,"NF_TOTAL"))) } )
				EndIf
                
				If lIntegDef //Tratamento Valor do Item integracao
					If aColsDet[nX][nPosDtDProp] > 0						
						aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, aCols[nX][nPosVlrItem] - aColsDet[nX][nPosDtDProp] } )
					Else
						aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, aCols[nX][nPosVlrItem]  } )
					EndIf

				ElseIf MaFisRet(,"NF_SUFRAMA")			
					If (nOpc == 3 .And. nTipo <> 1) .Or. (nOpc == 4 .And. nTipo == 2)						
						aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM" , aCols[nX][nPosVlrItem] - MaFisRet(nX, "IT_DESCZF") } )
					ElseIf nOpc == 4 .Or. nTipo == 1
						aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM", aCols[nX][nPosVlrItem]})
					EndIf

				Else
					aAdd( aSL2[Len(aSL2)], {"L2_VLRITEM"	, aCols[nX][nPosVlrItem]} )
				EndIf

			Else
				If cPaisLoc <> "BRA"
					If cMvDescSai == "2"
						aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, MaFisRet(nX, "IT_VALMERC") - MaFisRet(nX, "IT_DESCONTO") } )
					Else
						aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, MaFisRet(nX, "IT_VALMERC") } )
					EndIf
				Else
					If nOpc <> 4 .AND. aColsDet[nX][nPosDtDProp] <> 0 .OR. aDadosJur[1] <> 0
						aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, MaFisRet(nX, "IT_VALMERC")  } )
					Else
					    If (lDelete .AND. aColsDet[nX][nPosDtDProp] <> 0) .OR. (Lj7GetDescAnt() <> Lj7T_DescV(2) .AND. Lj7T_DescV(2) > 0)
						    aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, MaFisRet(nX, "IT_VALMERC")  } )
						Else
							aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, aCols[nX][nPosVlrItem]  } )
						EndIf
					EndIf
				EndIf
			EndIf

			// Quando no item da venda nao informado nenhum(BRANCO) tipo de entrega(1-Retira Posterior / 2-Retira / 3-Entrega)
			// O sistema ira considerar que o tipo de entrega sera Retira e ira gravar L2_ENTREGA igual a "2"
			aAdd( aSL2[Len(aSL2)], { "L2_ENTREGA"	, Iif(!Empty(aCols[nX][nPosEntrega]) .AND. aCols[nX][nPosEntrega]<>"2", aCols[nX][nPosEntrega], "2") } )

			If nPosDtEntr > 0
				aAdd( aSL2[Len(aSL2)], { "L2_FDTENTR"	, aCols[nX][nPosDtEntr] } )
			EndIf
			If nPosDtMont > 0
				aAdd( aSL2[Len(aSL2)], { "L2_FDTMONT"	, aCols[nX][nPosDtMont] } )
			EndIf
			If nPosContato > 0
				If !Empty(aCols[nX][nPosContato])
					aAdd( aSL2[Len(aSL2)], { "L2_CODCONT"	, aCols[nX][nPosContato] } )
				Else
					If nPCLIENTREGA > 0
						aAdd( aSL2[Len(aSL2)], { "L2_CLIENT"	, aCols[nX][nPCLIENTREGA] } )
						aAdd( aSL2[Len(aSL2)], { "L2_CLILOJA"	, aCols[nX][nPLOJCLIENT] } )
					Endif
				Endif
			EndIf
			If nPosTurno > 0 .AND. LJAnalisaLeg(47)[1]
				aAdd( aSL2[Len(aSL2)], { "L2_TURNO"	, aColsDet[nX][nPosTurno] } )
			EndIf
			
			If lIntegDef .And. !Empty(aColsDet[nX][nPosStTrib])  //Integracao mantem a tributacao informada
				Aadd(aTail(aSL2), {"L2_SITTRIB", aColsDet[nX][nPosStTrib]})
			//PAF-ECF: Quando DAV e Retaguarda PAFECF, deve armazenar SitTrib no orcamento(campo utilizado na relação de DAV´s emitidos)
			ElseIf !lPreVenda .AND. lNfPafEcf .AND. !lMVLJPDVPA .AND. SL2->(ColumnPos("L2_SITTRIB")) > 0

				Lj7Strib( @cSitTrib, @nAliquota, @nAliqRed, cTpSolCf, nX )
				Lj7AjustSt(@cSitTrib)

				Aadd( Atail(aSL2), {"L2_SITTRIB", cSitTrib} )

			ElseIf nPosStTrib > 0 .AND. (LjVassConc() .OR. lAutoExec .OR. ((lEmitNFCe .Or. lIsPafNfce) .And. !lEmiteNF))

				If lAutoExC .AND. Empty( aColsDet[nX][nPosStTrib] )
					If (lEmitNFCe .AND. !lUseSAT) .Or. lIsPafNfce
						aColsDet[nX][nPosStTrib] := AllTrim( Str(MaFisRet(nX, "IT_ALIQICM"), 5, 2) )
					Else
						aColsDet[nX][nPosStTrib] := Lj7Strib( Nil, Nil, Nil, Nil, nX )
						Lj7AjustSt( @aColsDet[nX][nPosStTrib] )
					EndIf
				ElseIf (lEmitNFCe .AND. !lUseSAT) .OR. lIsPafNfce
					aColsDet[nX][nPosStTrib] := AllTrim( Str(MaFisRet(nX, "IT_ALIQICM"), 5, 2) )
				Else
					aColsDet[nX][nPosStTrib] := Lj7Strib( Nil, Nil, Nil, Nil, nX )
					Lj7AjustSt( @aColsDet[nX][nPosStTrib] )
				EndIf

				Aadd( aTail(aSL2), {"L2_SITTRIB", aColsDet[nX][nPosStTrib]} )

			EndIf

			If nPosCodBar > 0
				aAdd( aSL2[Len(aSL2)], { "L2_CODBAR"	, aColsDet[nX][nPosCodBar] } )
			EndIf

			//Campos para otimizar geracao da NFC-e
			If (lEmitNFCe .Or. lIsPafNfce) .And. !lEmiteNF
				cL2Origem := RetFldProd(SB1->B1_COD,"B1_ORIGEM")
				aAdd( aSL2[Len(aSL2)], { "L2_ORIGEM"	, Iif(Empty(cL2Origem), SB1->B1_ORIGEM, cL2Origem) } )
			EndIf

			If lIntegDef
				aAdd( aSL2[Len(aSL2)], { "L2_POSIPI", aColsDet[nX][nPosPosIpi] } )
			Else
				aAdd( aSL2[Len(aSL2)], { "L2_POSIPI", SB1->B1_POSIPI } )
			EndIf
			
			aAdd( aSL2[Len(aSL2)], { "L2_CODISS"	, Alltrim(MaSBCampo("CODISS")) } )

			If SL2->(ColumnPos("L2_ABATISS")) > 0 .AND. nPosAbtIss > 0
				aAdd( aSL2[Len(aSL2)], { "L2_ABATISS", 	aCols[nX][nPosAbtIss] } )
			EndIf

			// para NFC-e conjugada, é necessário gravar a BASE e ALIQUOTA do ISS
			If lL2CmpISS
				aAdd( aSL2[Len(aSL2)], { "L2_BASEISS"	, MaFisRet(nX, "IT_BASEISS") } )
				aAdd( aSL2[Len(aSL2)], { "L2_ALIQISS"	, MaFisRet(nX, "IT_ALIQISS") } )
				If lL2CNAE
					aAdd( aSL2[Len(aSL2)], { "L2_CNAE"	, MaFisRet(nX, "IT_CNAE") } )
				EndIf
			Endif

			If lCAT83
				aAdd( aSL2[Len(aSL2)], { "L2_CODLAN"	, aColsDet[nX][nPosCodLan] } )
			EndIf

			aAdd( aSL2[Len(aSL2)], { "L2_LOCAL"		, aColsDet[nX][nPosDtLocal] } )
			aAdd( aSL2[Len(aSL2)], { "L2_UM"		, SB1->B1_UM } )

	   		If SL2->(ColumnPos( "L2_SEGUM" )) > 0
				aAdd( aSL2[Len(aSL2)], { "L2_SEGUM"		, SB1->B1_SEGUM } )
			EndIf

			If SL2->(ColumnPos( "L2_DTVALID" ) ) > 0 .AND. nPosDtValid > 0 .AND. !Empty( aColsDet[nX][nPosDtValid] )
				aAdd( aSL2[Len(aSL2)], { "L2_DTVALID"		, aColsDet[nX][nPosDtValid] } )
			EndIf

			If lParceiros
				aAdd( aSL2[Len(aSL2)], { "L2_INDPAR"	, cParceiro } )
			EndIf

			aAdd( aSL2[Len(aSL2)], { "L2_DESC"			, aCols[nX][nPosDesc] } )
			
			aModBc := MaFisRet(nX,"IT_SPED")
			If SL2->(ColumnPos( "L2_DESCICM" )) > 0 .And. SL2->(ColumnPos( "L2_MOTDICM" )) > 0
				
				If MaFisRet(nX,"IT_VALICM") > 0
					/* 
					-- Validação conforme a MatxFis --
					
					Conforme o link https://centraldeatendimento.totvs.com/hc/pt-br/articles/360025687693
											-MP-NFE-934-Rejeição-Não-informado-valor-do-ICMS-desonerado-ou-o-Motivo-de-desoneração
					
					o campo D2_DESCICM será gravado dependendo da forma 
					que a TES é configurada e na NF-e o valor da TAG vICMSDeson é enviada 
					pois a tabela CD2é gravada nesse momento
					
					Porem para a NFC-e, envio somente usamos o campo L2_DESCICM com isso
					o campo deve ser gravado a partir somente de qualquer configuração de TES
					
					Por isso o campo D2_DESCICM não teve sua gravação alterada no LOJXFUNC
					
					*/
					If ! Empty(AllTrim(MafisRet(nX,"LF_MOTICMS" )))
						
						aAdd( aSL2[Len(aSL2)], { "L2_MOTDICM"	, MafisRet(nX,"LF_MOTICMS") } )
						
						nAux := Len(aModBc)
						If nAux > 0
							nY := 0
							For nI := 1 to nAux
								nY += aModBc[nI][26] //Referencia SP_DESONE da MatxFis
							Next nI
							
							aAdd( aSL2[Len(aSL2)], { "L2_DESCICM"	, nY } )
						EndIf
						
						nY := 0
						nI := 0
						nAux := 0
					EndIf					
				EndIf
			EndIf

			aAdd( aSL2[Len(aSL2)], { "L2_VALDESC"	, aCols[nX][nPosValDesc] } )
			aAdd( aSL2[Len(aSL2)], { "L2_TES"		, aColsDet[nX][nPosDtTes] } )
			aAdd( aSL2[Len(aSL2)], { "L2_CF"		, aColsDet[nX][nPosDtCF] } )
			aAdd( aSL2[Len(aSL2)], { "L2_EMISSAO"	, dDataOrc } )
			aAdd( aSL2[Len(aSL2)], { "L2_GRADE"		, "N" } )
			aAdd( aSL2[Len(aSL2)], { "L2_VEND"		, cVend } )
			If !(IIf(cPaisLoc $ "MEX", lCenVenda, .F.))
				aAdd( aSL2[Len(aSL2)], { "L2_TABELA"	, aColsDet[nX][nPosDtTabela] } )
			EndIf
			aAdd( aSL2[Len(aSL2)], { "L2_RESERVA"	, aColsDet[nX][nPosDtReserva] } )
			aAdd( aSL2[Len(aSL2)], { "L2_LOJARES"	, aColsDet[nX][nPosDtLojaRes] } )
			aAdd( aSL2[Len(aSL2)], { "L2_FILRES"	, aColsDet[nX][nPosDtFilRes] } )
			aAdd( aSL2[Len(aSL2)], { "L2_NSERIE"  	, aColsDet[nX][nPosNumSerie] } )
			aAdd( aSL2[Len(aSL2)], { "L2_LOTECTL"	, aColsDet[nX][nPosLoteCTL] } )
			aAdd( aSL2[Len(aSL2)], { "L2_NLOTE"		, aColsDet[nX][nPosLote] } )
			aAdd( aSL2[Len(aSL2)], { "L2_LOCALIZ"	, aColsDet[nX][nPosLocaliz] } )

			// Cria proteção para campos incluidos no fonte loja701

	  		If lGE
				If nPosGarant > 0
					aAdd( aSL2[Len(aSL2)], { "L2_GARANT"  		, aCols[nX][nPosGarant] } )
	            EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso haja produto com garantia, e houve itens deletados , eh necessario
				//  reorganizar a relacao entre os itens de garantia e o produto
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	            If nPGarItem > 0 .AND. !Empty(aCols[nX][nPGarItem])
	            	nItem		:= Val(RETASC(cItem,2,.F.))   // Se o valor for "A0" sera retornado "100", e assim por diante
	            	nItemGar 	:= Val(RETASC(aCols[nX][nPGarItem],2,.F.))   // Se o valor for "A0" sera retornado "100", e assim por diante

	            	If nItem <> nX  // houve produtos deletados
		            	If lSomaGar
		            		nItem++
		            		nItemGar := nItem
		            		lSomaGar := .F.
		            	Else
		            		lSomaGar := .T.
		            		nItem--
		            		nItemGar := nItem
		            	Endif
					EndIf

	            	cItemGar	 := RETASC((nItemGar),2,.T.)   // Se o valor for "100" sera retornado “A0”, e assim por diante
					aAdd( aSL2[Len(aSL2)], { "L2_ITEMGAR"  , cItemGar } )
	            EndIf

	    	EndIf

			//Servico Financeiro
			If lSFinanc
				If nPosItSer > 0 .AND. nPosPrdCob > 0
					aAdd( aSL2[Len(aSL2)], { "L2_ITEMCOB"  , aCols[nX][nPosItSer] } )
					aAdd( aSL2[Len(aSL2)], { "L2_PRDCOBE"  , aCols[nX][nPosPrdCob] } )
				EndIf
			EndIf

			If SuperGetMV("MV_LJECOMM",,.F.)

				If  (nPosECPresSN > 0)
					aAdd( aSL2[Len(aSL2)], { "L2_ECPRESN" , aColsDet[nX][nPosECPresSN] } )
	            EndIf
				If  (nPosECSedex > 0)
					aAdd( aSL2[Len(aSL2)], { "L2_ECSEDEX" , aColsDet[nX][nPosECSedex] } )
	            EndIf
				If  (nPosECMensPr > 0)
					aAdd( aSL2[Len(aSL2)], { "L2_ECMSGPR" , aColsDet[nX][nPosECMensPr] } )
	            EndIf
	            If  (nPosECValor > 0)
					aAdd( aSL2[Len(aSL2)], { "L2_ECVALOR" , aColsDet[nX][nPosECValor] } )
	            EndIf
	            
	        EndIf

			If cPaisLoc <> "BRA"
				aAdd( aSL2[Len(aSL2)], { "L2_DESCPRO"	, aColsDet[nX][nPosDtDProp]} )
				If SL2->( ColumnPos( "L2_PROVENT" ) ) > 0 .AND. SLR->( ColumnPos( "LR_PROVENT" ) ) > 0 .AND. nPosProvEnt > 0
					aAdd( aSL2[Len(aSL2)], { "L2_PROVENT"	, aCols[nX][nPosProvEnt] } )
				EndIf
			EndIf

			If SL2->( ColumnPos("L2_ITEMSD1")) > 0
				aAdd( aSL2[Len(aSL2)], { "L2_ITEMSD1", "000000" } )
			EndIf
			
			If lIntegDef //Tratamento Desconto Proporcional e Preco de tabela - Integracao
				aAdd( aSL2[Len(aSL2)], { "L2_DESCPRO"	,	aColsDet[nX][nPosDtDProp]} )
				aAdd( aSL2[Len(aSL2)], { "L2_PRCTAB"	,	nPrcTab} )	
			Else
				aAdd( aSL2[Len(aSL2)], { "L2_PRCTAB"	,	nPrcTab} )
			EndIf
			
			If nPosValePre > 0
				aAdd( aSL2[Len(aSL2)], { "L2_VALEPRE", aColsDet[nX][nPosValePre]} )
			EndIf
			If SL2->( ColumnPos("L2_CODREG")) > 0
				aAdd( aSL2[Len(aSL2)], { "L2_CODREG", aColsDet[nX][nPosCodReg]} )
            EndIf
			If SL2->( ColumnPos("L2_VLDESRE")) > 0
				aAdd( aSL2[Len(aSL2)], { "L2_VLDESRE", aColsDet[nX][nPosVlDesR]} )
			EndIf

			If nPosKit > 0
				aAdd( aSL2[Len(aSL2)], {"L2_KIT", AllTrim(aCols[nX][nPosKit])} )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava campos especificos do SIGAPHOTO.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nModulo == 72
				If nPosEnvelo > 0
					aAdd( aSL2[Len(aSL2)], {"L2_ENVELO", aColsDet[nX][nPosEnvelo]} )
				EndIf

				If nPosBrinde > 0
					aAdd( aSL2[Len(aSL2)], {"L2_BRINDE", aColsDet[nX][nPosBrinde]} )
				EndIf

				If nPosCliEnv > 0
					aAdd( aSL2[Len(aSL2)], {"L2_CLIENV", aColsDet[nX][nPosCliEnv]} )
				EndIf

				If nPosLojEnv > 0
					aAdd( aSL2[Len(aSL2)], {"L2_LOJENV", aColsDet[nX][nPosLojEnv]} )
				EndIf

				If nPosPa2Item > 0
					aAdd( aSL2[Len(aSL2)], {"L2_PA2ITEM", aColsDet[nX][nPosPa2Item]} )
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava campos do Ped de Venda+Item+Sequen ³
			//³Se houver U_UPDFAT14                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SL2->(ColumnPos("L2_PEDSC5")) > 0 .and. nPosPedSC5 > 0
				aAdd( aSL2[Len(aSL2)], {"L2_PEDSC5", aColsDet[nX][nPosPedSC5]} )
				aAdd( aSL2[Len(aSL2)], {"L2_ITESC6", aColsDet[nX][nPosIteSC6]} )
				aAdd( aSL2[Len(aSL2)], {"L2_SEQUEN", aColsDet[nX][nPosSequen]} )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se usa reserva sem estoque. Se usar Grava numero da solicitacao de compra  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(Str(SuperGetMv("MV_LJGERSC",,1))) $ "2|3"
				If nPosSolCom > 0
					aAdd( aSL2[Len(aSL2)], {"L2_SOLCOM", aColsDet[nX][nPosSolCom]} )
					If nPosFilRes > 0
						aAdd( aSL2[Len(aSL2)], {"L2_FILRES", aColsDet[nX][nPosFilRes]} )		//Necessário gravar neste campo pois pode ter solicitado com outra filial
					EndIf
				EndIf
			EndIf

			If nPosMesRec > 0
				aAdd( aSL2[Len(aSL2)], {"L2_MESREC", aColsDet[nX][nPosMesRec]} )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Qtde dias da validade da garantia do produto   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	   		If lGE .AND. nPosVldProd > 0
				aAdd( aSL2[Len(aSL2)], {"L2_VLGAPRO", aColsDet[nX][nPosVldProd]} )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Cartao fidelidade				³
			//³Gravacao dos campos especificos para recarga	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLjcFid .AND. LaFunhProd(aCols[nX][nPosProd])
				If nPosNumcFi > 0
					aAdd( aSL2[Len(aSL2)], {"L2_NUMCFID", aColsDet[nX][nPosNumcFi]} )
				EndIf
				If nPosDtsdFi > 0
					aAdd( aSL2[Len(aSL2)], {"L2_DTSDFID", aColsDet[nX][nPosDtsdFi]} )
				EndIf
				If nPosVlrcFi > 0
					aAdd( aSL2[Len(aSL2)], {"L2_VLRCFID", aColsDet[nX][nPosVlrcFi]} )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Recarga do cartao fidelidade processada: ³
				//³B - Via processo batch (LJGRVBATCH)      ³
				//³W - Via WebService(LJCCARFID) 		    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa)
					If Ca280CkWs ()
						//Via WebService(LJCCARFID)
						aAdd( aSL2[Len(aSL2)], {"L2_PROCFID", "W"} )
					Else
						//Via processo batch (LJGRVBATCH)
						aAdd( aSL2[Len(aSL2)], {"L2_PROCFID", "B"} )
					EndIf
				ElseIf nModulo ==12 .AND. !lMvLjPdvPa
					//Via processo batch (LJGRVBATCH)
					aAdd( aSL2[Len(aSL2)], {"L2_PROCFID", "B"} )
				EndIf

		  	EndIf

			If nPosLista > 0
				aAdd( aSL2[Len(aSL2)], {"L2_CODLPRE", aCols[nX][nPosLista]} )
				//Se for lista do tipo credito não pode ficar com o status de reserva quando for orçamento.
				If !Empty(aColsDet[nX][nPosDtReserva]) .And. aCols[nX][nPosEntrega] == "3" .And. !Empty(aCols[nX][nPosLista]) .And.;
					GetAdvfVal("ME1","ME1_TIPO",xFilial("ME1") + aCols[nX][nPosLista],2) == "1"
					lReserva := .F.
				EndIf
			EndIf

			If nPosItLista > 0
				aAdd( aSL2[Len(aSL2)], {"L2_ITLPRE", aCols[nX][nPosItLista]} )
			EndIf

			If nPosMsgLPre > 0
				aAdd( aSL2[Len(aSL2)], {"L2_MSGLPRE", aCols[nX][nPosMsgLPre]} )
			EndIf

			If nPosRevLPre > 0
				aAdd( aSL2[Len(aSL2)], {"L2_REVLPRE", aCols[nX][nPosRevLPre]} )
			EndIf

			If nPosMsmLPre > 0
				aAdd( aSL2[Len(aSL2)], {"L2_MSMLPRE", aCols[nX][nPosMsmLPre]} )
			EndIf

			If nPosRemLPre > 0
				aAdd( aSL2[Len(aSL2)], {"L2_REMLPRE", aCols[nX][nPosRemLPre]} )
			EndIf

			If lNfPafEcf .AND. lTplPCL
				nPosLR_BICO  := Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_BICO"})
				nPosLR_LEGCOD:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_LEGCOD"})

				If nPosLR_BICO > 0
					Aadd(aSL2[Len(aSL2)], {"L2_BICO", aCols[nX][nPosLR_BICO]} )
				EndIf

				If nPosLR_LEGCOD > 0
					Aadd(aSL2[Len(aSL2)], {"L2_LEGCOD", aCols[nX][nPosLR_LEGCOD]} )
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ VerIfica a gravacao dos impostos no SL2                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MaFisFound("IT",nX) .AND. !(nRotina == 4 .AND. !Empty(SL1->L1_ORCRES))

				If cPaisLoc == "BRA"
					//Regra utilizada no MatxFis para verificar a modalidade da base de calculo
					If (lEmitNFCe .Or. lIsPafNfce) .AND. !lEmiteNF
						If Len(aModBc) > 0
							cModBc := aModBc[1][6]
						EndIf
						aAdd( aSL2[Len(aSL2)], { "L2_MODBC", cModBc } )
					EndIf
					
					If lIntegDef //Tratamento Impostos
						aAdd( aSL2[Len(aSL2)], { "L2_VALICM",	aColsDet[nX][nPosValIcm] } ) 
						aAdd( aSL2[Len(aSL2)], { "L2_PICM",		aColsDet[nX][nPosAliIcm] } )
												
						aAdd( aSL2[Len(aSL2)], { "L2_VALISS",	aColsDet[nX][nPosValIss] } )
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQISS",	aColsDet[nX][nPosAliIss] } )
						
						aAdd( aSL2[Len(aSL2)], { "L2_VALIPI", aColsDet[nX][nL2PosVlIpi] } )
						If lL2BASEIPI .And. nL2BASEIPI > 0
							aAdd( aSL2[Len(aSL2)], { "L2_BASEIPI", aColsDet[nX][nL2BASEIPI] } )
						EndIf
						If lL2IPI .And. nL2IPI > 0
							aAdd( aSL2[Len(aSL2)], { "L2_IPI", aColsDet[nX][nL2IPI] } )
						EndIf
					Else						
						aAdd( aSL2[Len(aSL2)], { "L2_VALIPI",   MaFisRet(nX,"IT_VALIPI") } )
						aAdd( aSL2[Len(aSL2)], { "L2_VALICM",	MaFisRet(nX,"IT_VALICM") } )
						aAdd( aSL2[Len(aSL2)], { "L2_VALISS",	MaFisRet(nX,"IT_VALISS") } )
					EndIf										
					
					If lIntegDef //Tratamento BaseIcm e BaseIss - Integracao 													
						aAdd( aSL2[Len(aSL2)], { "L2_BASEICM",	aColsDet[nX][nPosBasIcm] } )														
						aAdd( aSL2[Len(aSL2)], { "L2_BASEISS",	aColsDet[nX][nPosBasIss] } )					
					ElseIf !lFtvdVer12
						If cPaisLoc == "BRA" .AND. SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100 .AND. SB0->B0_ALIQRED > 0 .AND. lImpCupFis .AND. SuperGetMV("MV_MAPARES") == "N"
		   					aAdd( aSL2[Len(aSL2)], { "L2_BASEICM",	MaFisRet(nX, "IT_TOTAL") } )
						Else
		   					aAdd( aSL2[Len(aSL2)], { "L2_BASEICM",	MaFisRet(nX,"IT_BASEICM") } )
						EndIf
					ElseIf lFtvdVer12
						If cPaisLoc == "BRA" .AND. SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100 .AND. SB0->B0_ALIQRED > 0 .AND. SuperGetMV("MV_MAPARES") == "N"
	   						aAdd( aSL2[Len(aSL2)], { "L2_BASEICM",	MaFisRet(nX, "IT_TOTAL") } )
						Else
	   						aAdd( aSL2[Len(aSL2)], { "L2_BASEICM",	MaFisRet(nX,"IT_BASEICM") } )
						EndIf
					EndIf

					If lL2CEST
						aAdd( aSL2[Len(aSL2)], { "L2_CEST",	MaFisRet(nX,"IT_CEST") } )
					EndIf
					
     
                    If lIntegDef //Tratamento FECP e FECP_ST
			
						If lL2FECP .And. nPosAlqFecp > 0 .And. nPosValFecp > 0
							aAdd( aSL2[Len(aSL2)], { "L2_ALQFECP",  aColsDet[nX][nPosAlqFecp] } )
							aAdd( aSL2[Len(aSL2)], { "L2_VALFECP",  aColsDet[nX][nPosValFecp] } )
							
							If lL2BASFECP .And. nPosBasFecp > 0
								aAdd( aSL2[Len(aSL2)], { "L2_BASFECP",  aColsDet[nX][nPosBasFecp] } )
							EndIf
							
						EndIf
						
						If lL2FECPST  .And. nPosAlqSTFecp > 0 .And. nPosValSTFecp > 0
	                        aAdd( aSL2[Len(aSL2)], { "L2_ALQFCST",  aColsDet[nX][nPosAlqSTFecp] } )
	                        aAdd( aSL2[Len(aSL2)], { "L2_VFECPST",  aColsDet[nX][nPosValSTFecp] } )
	                        
	                        If lL2STBASFECP .And. nPosBasSTFecp > 0
	                       		aAdd( aSL2[Len(aSL2)], { "L2_BSFCPST",  aColsDet[nX][nPosBasSTFecp] } )
							EndIf
	                        
	                    EndIf						
						
						
					Else						
						If lL2FECP
							aAdd( aSL2[Len(aSL2)], { "L2_ALQFECP",  MaFisRet(nX, "IT_ALIQFECP") } )
							aAdd( aSL2[Len(aSL2)], { "L2_VALFECP",  MaFisRet(nX, "IT_VALFECP") } )
						EndIf
						If lL2BASFECP
							aAdd( aSL2[Len(aSL2)], { "L2_BASFECP",  MaFisRet(nX, "IT_BASFECP") } )
						EndIf

						
						If lL2FECPST
	                        aAdd( aSL2[Len(aSL2)], { "L2_ALQFCST",  MaFisRet(nX, "IT_ALFCST") } )
	                        aAdd( aSL2[Len(aSL2)], { "L2_VFECPST",  MaFisRet(nX, "IT_VFECPST") } )
	                    EndIf
                        If lL2STBASFECP
                       		aAdd( aSL2[Len(aSL2)], { "L2_BSFCPST",  MaFisRet(nX, "IT_BSFCPST") } )
						EndIf
					EndIf	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso exista os campos no Itens do orcamento, gravo seus respectivos valores³
					//³ref. a PIS/COFINS de Retencao ou Apuracao                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Regra para o cAlculo do PIS/COFINS/CSLL                                            ³
					//³=======================================                                            ³
					//³O calculo podera ser realizado de duas formas:                                     ³
					//³                                                                                   ³
					//³1) Por Apuracao: Neste caso e` rodado no faturamento um programa                   ³
					//³para fazer a apuracao dos impostos: L2_VALPS2,  L2_VALCF2 etc, onde                ³
					//³Na venda o sistema verIfica se a TES calcula PIS/COFINS/CSLL e alimenta            ³
					//³os campos referente a estes impostos na tabela SL2.                                ³
					//³                                                                                   ³
					//³2) Por Retencao: Neste caso o calculo e` realizado na emissão da nota;             ³
					//³Regra para retenção:                                                               ³
					//³====================                                                               ³
					//³Criar uma natureza que calcule PIS/COFINS/CSLL;         							  ³
					//³Amarrar esta natureza no cadastro do cliente;                                      ³
					//³Preencher um ou todos os Campos:A1_RECPIS, A1_RECCOF e A1_RECCSLL com o valor "SIM"³
					//³                                                                                   ³
					//³Importante: Para Retencao, somente sera calculado os impostos se o produto tambem  ³
					//³ Tiver retencao de PIS/COFINS/CSLL.                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calculo do PIS/COFINS/CSLL por Retencao                                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SL2->(FieldPos("L2_VALPIS")) >0 	.AND. SL2->(FieldPos("L2_VALCOFI"))>0 .AND.	;
					   SL2->(FieldPos("L2_VALCSLL"))>0 .AND. SL2->(FieldPos("L2_VALPS2")) >0 .AND.	;
					   SL2->(FieldPos("L2_BASEPS2"))>0	.AND. SL2->(FieldPos("L2_ALIQPS2"))>0 .AND.	;
					   SL2->(FieldPos("L2_VALCF2")) >0	.AND. SL2->(FieldPos("L2_BASECF2"))>0 .AND.	;
					   SL2->(FieldPos("L2_ALIQCF2"))>0	.AND. ;
					   ( SA1->A1_RECPIS == "S" .OR. SA1->A1_RECCOFI == "S" .OR. SA1->A1_RECCSLL == "S" )

						aAdd( aSL2[Len(aSL2)], { "L2_VALPIS ", MaFisRet(nX,"IT_VALPIS") } )  //Valor PIS Retencao
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQPIS", MaFisRet(nX,"IT_ALIQPIS") } ) //Aliquota PIS - Retencao
						aAdd( aSL2[Len(aSL2)], { "L2_BASEPIS", MaFisRet(nX,"IT_BASEPIS") } ) //Base PIS - Retencao	

						aAdd( aSL2[Len(aSL2)], { "L2_VALCOFI", MaFisRet(nX,"IT_VALCOF") } )  //Valor COFINS - Retencao	
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQCOF", MaFisRet(nX,"IT_ALIQCOF") } ) //Aliquota COFINS - Retencao	
						aAdd( aSL2[Len(aSL2)], { "L2_BASECOF", MaFisRet(nX,"IT_BASECOF") } ) //Base COFINS - Retencao

						aAdd( aSL2[Len(aSL2)], { "L2_VALCSLL" , MaFisRet(nX,"IT_VALCSL") } ) //Valor para CSLL 	
						aAdd( aSL2[Len(aSL2)], { "L2_ALQCSLL" , MaFisRet(nX,"IT_ALIQCSL") } ) //Aliquota para CSLL
						aAdd( aSL2[Len(aSL2)], { "L2_BASCSLL" , MaFisRet(nX,"IT_BASECSL") } ) //Base para CSLL
						
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula PIS/COFINS/CSLL por Apuracao, onde o sistema verIfica se  ³
					//³a TES calcula os impostos                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lIntegDef //Tratamento Pis / Cofins / CSLL / IRRF - Integracao Mensagem Unica
						aAdd( aSL2[Len(aSL2)], { "L2_VALPS2 ", aColsDet[nX][nPosValPS2] } ) //Valor PIS - Apuracao
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQPS2", aColsDet[nX][nPosAliPS2] } ) //Aliquota PIS - Apuracao
						aAdd( aSL2[Len(aSL2)], { "L2_BASEPS2", aColsDet[nX][nPosBasPS2] } ) //Base PIS - Apuracao												 
						
						aAdd( aSL2[Len(aSL2)], { "L2_VALPIS ", aColsDet[nX][nPosValPis] } ) //Tratamento para PIS Retencao
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQPIS", aColsDet[nX][nPosAliPis] } ) //Aliquota PIS - Retencao
						aAdd( aSL2[Len(aSL2)], { "L2_BASEPIS", aColsDet[nX][nPosBasPis] } ) //Base PIS - Retencao		
						
						aAdd( aSL2[Len(aSL2)], { "L2_VALCOFI", aColsDet[nX][nPosValCof] } ) //Valor COFINS - Retencao	
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQCOF", aColsDet[nX][nPosAliCof] } ) //Aliquota COFINS - Retencao	
						aAdd( aSL2[Len(aSL2)], { "L2_BASECOF", aColsDet[nX][nPosBasCof] } ) //Base COFINS - Retencao				
												
						aAdd( aSL2[Len(aSL2)], { "L2_VALCF2" , aColsDet[nX][nPosValCF2] } ) //Valor COFINS - Apuracao
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQCF2", aColsDet[nX][nPosAliCF2] } ) //Aliquota COFINS - Apuracao
						aAdd( aSL2[Len(aSL2)], { "L2_BASECF2", aColsDet[nX][nPosBasCF2] } ) //Base COFINS - Apuracao						
																								
						aAdd( aSL2[Len(aSL2)], { "L2_VALCSLL", aColsDet[nX][nPosVlCSLL] } ) //Valor para CSLL 	
						aAdd( aSL2[Len(aSL2)], { "L2_BASCSLL", aColsDet[nX][nPosBsCSLL] } ) //Base para CSLL
						aAdd( aSL2[Len(aSL2)], { "L2_ALQCSLL", aColsDet[nX][nPosAlCSLL] } ) //Aliquota para CSLL
						
						aAdd( aSL2[Len(aSL2)], { "L2_VALIRRF", aColsDet[nX][nPosVlIrrf] } ) //Valor para IRRF																													
						aAdd( aSL2[Len(aSL2)], { "L2_BASIRRF", aColsDet[nX][nPosBasIrrf] } ) //Base para IRRF																
						aAdd( aSL2[Len(aSL2)], { "L2_ALQIRRF", aColsDet[nX][nPosAliIrrf] } ) //Aliquota para IRRF

						If nL2ICMSRET > 0 
							aAdd( aSL2[Len(aSL2)], { "L2_ICMSRET" , aColsDet[nX][nL2ICMSRET] } )//Valor para ICMS Solidario (ICMS-ST)
						EndIf
						If nL2BRICMS > 0																													
							aAdd( aSL2[Len(aSL2)], { "L2_BRICMS", aColsDet[nX][nL2BRICMS] } ) 	//Base para ICMS Solidario (ICMS-ST)
						EndIf
						If lL2AliqSOL .And. nL2ALIQSOL > 0																
							aAdd( aSL2[Len(aSL2)], { "L2_ALIQSOL", aColsDet[nX][nL2ALIQSOL] } ) //Aliquota para ICMS Solidario (ICMS-ST)
						EndIf
						If nPosCSTPIS > 0
							aAdd( aSL2[Len(aSL2)], { "L2_CSTPIS", aColsDet[nX][nPosCSTPIS] } ) 
						EndIf
						If nPosCSTCOF > 0
							aAdd( aSL2[Len(aSL2)], { "L2_CSTCOF", aColsDet[nX][nPosCSTCOF] } ) 
						EndIf												
					Else
						aAdd( aSL2[Len(aSL2)], { "L2_BASEPS2", MaFisRet(nX,"IT_BASEPS2") } )
						aAdd( aSL2[Len(aSL2)], { "L2_BASECF2", MaFisRet(nX,"IT_BASECF2") } )
	
						aAdd( aSL2[Len(aSL2)], { "L2_VALPS2" , MaFisRet(nX,"IT_VALPS2") } )
						aAdd( aSL2[Len(aSL2)], { "L2_VALCF2" , MaFisRet(nX,"IT_VALCF2") } )
	
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQPS2", MaFisRet(nX,"IT_ALIQPS2") } )
						aAdd( aSL2[Len(aSL2)], { "L2_ALIQCF2", MaFisRet(nX,"IT_ALIQCF2") } )
	
						aAdd( aSL2[Len(aSL2)], { "L2_BRICMS", 	MaFisRet(nX,"IT_BASESOL") } )
						aAdd( aSL2[Len(aSL2)], { "L2_ICMSRET",	MaFisRet(nX,"IT_VALSOL") } )
					EndIf

				EndIf

				If lIntegDef
					aAdd( aSL2[Len(aSL2)], { "L2_VALFRE",	aColsDet[nX][nPosDtVlFret] } )
					aAdd( aSL2[Len(aSL2)], { "L2_DESPESA",  aColsDet[nX][nPosDtVlDesp] } )
				Else
					aAdd( aSL2[Len(aSL2)], { "L2_VALFRE" , MaFisRet(nX,"IT_FRETE") } )
					aAdd( aSL2[Len(aSL2)], { "L2_DESPESA", MaFisRet(nX,"IT_DESPESA") } )
				Endif
				
				aAdd( aSL2[Len(aSL2)], { "L2_SEGURO" , MaFisRet(nX,"IT_SEGURO") } )
				
			ElseIf lEmitNFCe .Or. lIsPafNfce

				If nPosOrigem > 0
					aAdd( aSL2[Len(aSL2)], {"L2_ORIGEM", aColsDet[nX][nPosOrigem]} )
				EndIf

				If nPosModbc > 0
					aAdd( aSL2[Len(aSL2)], {"L2_MODBC",  aColsDet[nX][nPosModbc]} )
				EndIf

				If nPosPosIpi > 0
					aAdd( aSL2[Len(aSL2)], {"L2_POSIPI", aColsDet[nX][nPosPosIpi]} )
				EndIf

			EndIf

           If nPosCodIss > 0
				aAdd( aSL2[Len(aSL2)], {"L2_CODISS", aColsDet[nX][nPosCodIss]} )
			EndIf

			If cPaisLoc <> "BRA"
		        For nY := 1 To Len(aImpsSL2[nX][3])
		        	If aImpsSL2[nX][3][nY][3] > 0
			        	Aadd(aSL2[Len(aSL2)],{aImpsSL2[nX][3][nY][6],aImpsSL2[nX][3][nY][4]})   //Valor do imposto
		                Aadd(aSL2[Len(aSL2)],{aImpsSL2[nX][3][nY][7],aImpsSL2[nX][3][nY][3]})   //Base do imposto
		                Aadd(aSL2[Len(aSL2)],{"L2_ALQIMP"+Substr(aImpsSL2[nX][3][nY][7],10,1),MaFisRet(nX,"IT_ALIQIV"+Substr(aImpsSL2[nX][3][nY][7],10,1))})
	            	EndIf
	            Next nY
	        EndIf

			/*
			O array aSxFci é carregado no inicio da função para funcionalidade da FCI
			aSxFci ->	[1] - MV_FISFRAS
						[2] - MV_FCIMOD
						[3] - AliasInDic("CFD")
						[4] - SD2->(FieldPos("D2_FCICOD") ) > 0
						[5] - SD2->(FieldPos("D2_VLIMPOR")) > 0
						[6] - SLR->(FieldPos("LR_VLIMPOR")) > 0 .And. SL2->(FieldPos("L2_VLIMPOR")) > 0
						[7] - SD1->(FieldPos("D1_FCICOD") ) > 0
						[8] - SLR->(FieldPos("LR_FCICOD") ) > 0 .And. SL2->(FieldPos("L2_FCICOD")) > 0
						[9] - MV_FISAUCF
			*/
		  	If lFciVlImpor .AND. nPosVlImpor > 0
				nVlimp := aCols[nX][nPosVlImpor]
			EndIf

			If lFciCod .AND. nPosFCICod > 0
				cFciCod := aCols[nX][nPosFCICod]
			EndIf

			If aSxFci[1] .And. aSxFci[9] .And. (lFciVlImpor .Or. lFciCod) .And. nPosClasFis > 0
				lRetFci := LjCRetFci(aCols[nX][nPosProd], aColsDet[nX][nPosLote], aColsDet[nX][nPosLoteCTL], @nVlImp, @cFciCod, aCols[nX][nPosClasFis], nX)
			EndIf

			If lFciVlImpor
				aAdd( aSL2[Len(aSL2)], { "L2_VLIMPOR", nVlimp } )
			EndIf

			If lFciCod
				aAdd( aSL2[Len(aSL2)], { "L2_FCICOD", cFciCod } )
			EndIf

			If nPosClasFis > 0
				If lRetFci//Caso em branco, o cClasFisc é zerado dentro o SpedRastro2
			   		aAdd( aSL2[Len(aSL2)], { "L2_CLASFIS", MaFisRet(nX,"IT_CLASFIS") } )
			   	Else
			   		aAdd( aSL2[Len(aSL2)], { "L2_CLASFIS", aCols[nX][nPosClasFis] } )
			   	EndIf
			EndIf

			//%Redução da Base do ICMS
			If nPosPRedIc > 0 .And. SL2->(ColumnPos("L2_PREDIC")) > 0 .And. SLR->(ColumnPos("LR_PREDIC")) > 0
			   	aAdd( aSL2[Len(aSL2)], { "L2_PREDIC", aCols[nX][nPosPRedIc] } )
			EndIf
			
			//Integracao via Mensagem Unica, devera manter as informacoes do cupom enviados
		 	If lIntegDef
		 		aAdd(aSL2[Len(aSL2)], {"L2_DOC"		, M->LQ_DOC})	
		 		aAdd(aSL2[Len(aSL2)], {"L2_SERIE"	, M->LQ_SERIE})	
		 		aAdd(aSL2[Len(aSL2)], {"L2_PDV"		, M->LQ_PDV})	
		 		aAdd(aSL2[Len(aSL2)], {"L2_VENDIDO", "S"})
		 		
		 		If lIntegHtl //Integracao Hotelaria
			 		aAdd(aSL2[Len(aSL2)], {"L2_CCUSTO"	, aColsDet[nX][nPosCCusto]}) 
			 		aAdd(aSL2[Len(aSL2)], {"L2_ITEMCC"	, aColsDet[nX][nPosItCC]}) 
			 		aAdd(aSL2[Len(aSL2)], {"L2_CLVL"	, aColsDet[nX][nPosClvl]}) 
				EndIf		 			
		 	EndIf

            If lIntegDef .and. SL2->(ColumnPos("L2_TRANSP")) > 0 .And. SLR->(ColumnPos("LR_TRANSP")) > 0
                aAdd( aSL2[Len(aSL2)], {"L2_TRANSP",  aColsDet[nX][nPosITransp]} )
            EndIF 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VerIfica os campos de usuario ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY := 1 to Len(aCamposU)
				cCampUsr 	:= aCamposU[nY][1]
				nPos 		:= aCamposU[nY][2]
				aAdd( aSL2[Len(aSL2)],{ cCampUsr , aCols[nX][nPos] } )
			Next nY
		EndIf
	Next nX
Else
	If (lNfPafEcf .AND. lTemGeraNOrc) .OR. (LJAnalisaLeg(37)[1] .AND. lTemGeraNOrc)
		If !lRecebe
			M->LQ_NUM := GetSxENum("SL1","L1_NUM")
			ConfirmSx8()
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se existe condicoes de pagamento que geram troco.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoExC .Or. nOpc == 4
	For nX := 1 To Len( aPgtos )
		If ( Empty(cFormTrc) .AND. (IsMoney(aPgtos[nX][3]) .OR. Trim(aPgtos[nX][3]) == "VA"  .OR. aPgtos[nX][3] $ cMV_LJPGTRO) ) .OR.;
			( !Empty(cFormTrc) .AND. cFormTrc = aPgtos[nX][3] )
			If Empty( aFormas ) .OR. (nPosSL4 := aScan( aFormas, {|ExpA1| ExpA1[1] == aPgtos[nX][3] .AND. aPgtos[nX][1] == ExpA1[4] }) ) == 0
				If cPaisLoc == "BRA"
					AAdd( aFormas , { aPgtos[nX][3] , 0 ,  , aPgtos[nX][1], aPgtos[nX][2]})
				Else
					AAdd( aFormas , { aPgtos[nX][3] , 0, aPgtos[nX][6], aPgtos[nX][1], aPgtos[nX][2] } )
				EndIf
				nTotParcTroc += aPgtos[nX][2]
			ElseIf nPosSL4 > 0
				aFormas[nPosSL4, 05] +=  aPgtos[nX][2]
				nTotParcTroc += aPgtos[nX][2]
			EndIf
		EndIf
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o Rateio dos valores para geracao do troco por forma de pgto. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotalDIfForm := Lj7AjustaTroco(.T.,Nil,cFormaPgto)
Lj7SetTrcForm("")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SignIfica que o usuário utilizou o troco localizado, por isso nao deve ser realizado nenhum tipo de ³
//³acerto nos totais da venda.                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA" .AND. nTotalDIfForm == 0
	nVlrTroco := 0
EndIf
For nX := 1 To Len( aFormas )
	If nTotalDIfForm > 0
		If cPaisLoc == "BRA"
			If nX < Len(aFormas)
				nPerTroco := ((aFormas[nX][5] * 100)/nTotParcTroc)
				nTrocoRat := Round(((nTotalDIfForm * nPerTroco)/100),nDecs)
				nDiffTrc += nTrocoRat
			Else
				nTrocoRat := nTotalDIfForm - nDiffTrc
				nTotalDIfForm -= nTotalDIfForm
			EndIf
			aFormas[nX][2] := nTrocoRat

		Else
			aFormas[nX][2] := Round(xMoeda(nTotalDIfForm	, nMoedaCor	, aFormas[nX][3]	, dDatabase	,;
											MsDecimais(aFormas[nX][3])+1),MsDecimais(aFormas[nX][3]))
			nTotalDIfForm -= nTotalDIfForm
		EndIf

	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o array aSL4         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrEntrada := 0
For nX := 1 to Len(aPgtos)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o valor da parcela quando o troco nao esta habilitado. Nao permite gerar parcela com valor zero³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHabTroco .Or. lIntegDef
	   nVlrParc  := aPgtos[nX][2]
	Else
	   nVlrParc  := Round(Max(aPgtos[nX][2] - IIf(aPgtos[nX][6] <> nMoedaCor, xMoeda( nVlrTroco, nMoedaCor, aPgtos[nX][6], dDatabase ), nVlrTroco), 0), MsDecimais(aPgtos[nX][6]))
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Considera a linha zerada quando for pagto com nota de credito³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (aPgtos[nX][2] <> 0 .AND. nVlrParc <> 0 ) .OR. ( aPgtos[nX][2] == 0 .AND. Len(aPgtos) == 1 .AND. nNCCUsada > 0 )
		If !lRecebe
			aAdd( aSL4, {} )
			aAdd( aSL4[Len(aSL4)], { "L4_FILIAL"	, xFilial("SL4") } )
			aAdd( aSL4[Len(aSL4)], { "L4_NUM"		, cNumOrc	} )
			aAdd( aSL4[Len(aSL4)], { "L4_DATA"		, aPgtos[nX][1] } )
		EndIf
		If ValType(aPgtos[nX][4]) == "A" .AND. Len(aPgtos[nX][4]) > 0  .AND. ( AllTrim(aPgtos[nX][3]) $ "CC|CO|CD|FI" .Or. lMultNeg ).AND. Len(aSL4)>0
			aAdd( aSL4[Len(aSL4)], { "L4_ADMINIS"		, aPgtos[nX][4][5] } )
		ElseIf !lRecebe
			/*  Aqui foi inclusa esta proteção, devido via ExecAuto, para geração do orçamento com forma igual "CH".
			    Devido a possibilidade de utilizar o PE LJ7054, que serve para retornar os dados do Cheque, no momento da finalização/gravação da venda e
				não exibir a tela do Cheque, é necessário que não limpe o campo L4_ADMINIS, quando Alltrim(aPgtos[nX][3])=="CH"
				A implementação inicial, ocoreu na ChangeSet 640903, para atender uma necessidade da NT006, onde em casos com Fornmas de Pagamentos
				customizadas, o campo L4_ADMINIS, necessitava ser limpo.
			*/	
			If Alltrim(aPgtos[nX][3]) <> Alltrim(MVCHEQUE)			
				aAdd( aSL4[Len(aSL4)], { "L4_ADMINIS"		, ""} )
			EndIf
		EndIf
		If (IsMoney(aPgtos[nX][3]) .OR. aPgtos[nX][3] == "VA") .And. (!lAutoExC .Or. nOpc == 4)
			If !lRecebe
				If cPaisLoc == "BRA"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Utilizado para a gravacao de troco em qualquer            |
					//³ numerario. Se for NCC nao deixa o L4_VALOR ficar negativo |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd( aSL4[Len( aSL4 )], { "L4_VALOR", nVlrParc } )
				Else
					nVlrTrcAux := Round(xMoeda(nVlrTroco	, nMoedaCor	, aPgtos[nX][6]	, dDatabase	,;
										MsDecimais(aPgtos[nX][6])+1),MsDecimais(aPgtos[nX][6]))
					aAdd( aSL4[Len(aSL4)], { "L4_VALOR", 	aPgtos[nX][2] - nVlrTrcAux } )
				EndIf
								
				If !lIntegDef //Integracao Mensagem Unica nao considera troco
					nVlrTroco -= If( nVlrTroco > 0, Lj7T_Troco( 2 ), 0 )
				EndIf
			EndIf

			If cPaisLoc == "BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Utilizado para a gravacao de troco em qualquer	          |
				//³ numerario.                                                |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lHabTroco
					nVlrParcela := aPgtos[nX][2]
				Else
					nVlrParcela := aPgtos[nX][2] - nVlrTroco
				EndIf
			Else
				nVlrParcela := aPgtos[nX][2] - nVlrTrcAux
			EndIf

			If nVlrTroco > 0
				nVlrTroco   -= LJ7T_Troco( 2 )
			EndIf
		Else
			If !lRecebe
				aAdd( aSL4[Len(aSL4)], { "L4_VALOR", 	aPgtos[nX][2] } )
			EndIf
			nVlrParcela := aPgtos[nX][2]
		EndIf
		If !lRecebe
			aAdd( aSL4[Len(aSL4)], { "L4_FORMA",		aPgtos[nX][3] } )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Guarda o valor do troco caso o campo exista na base³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( aFormas )
				If cPaisLoc == "BRA"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Utilizado para a gravacao de troco em qualquer	|
					//³ numerario se este estiver habilitado	        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lHabTroco
						nPosRet := aScan( aFormas, { |ExpA1| ExpA1[1] == aPgtos[nX][3] .AND. ExpA1[4] == aPgtos[nX][1] } )

						If nPosRet > 0
							AAdd( aSL4[Len( aSL4 )], { "L4_TROCO", aFormas[nPosRet][2] } )
							aFormas[nPosRet][2] := 0
						EndIf
					EndIf
				Else
					nPosRet := aScan( aFormas, { |ExpA1| ExpA1[1] == aPgtos[nX][3] .AND. ExpA1[4] == aPgtos[nX][1]} )

					If nPosRet > 0
						AAdd( aSL4[Len( aSL4 )], { "L4_TROCO", aFormas[nPosRet][2] } )
						aFormas[nPosRet][2] := 0
					EndIf
				EndIf
			Else
				AAdd( aSL4[Len(aSL4)], { "L4_TROCO", 0 } )
			EndIf

			If cPaisLoc <> "BRA"
			   aAdd( aSL4[Len(aSL4)], { "L4_MOEDA",		aPgtos[nX][_MOEDA] } )
		       nMoedaParc  := aPgtos[nX][_MOEDA]
			EndIf

			If lMultNeg .And. Len(aPgtos[nX]) > 10 .And. SL4->(ColumnPos("L4_DESCMN")) > 0
				aAdd( aSL4[Len(aSL4)], { "L4_DESCMN",		aPgtos[nX][11] } )
			EndIf
			AAdd( aSL4[Len(aSL4)], { "L4_ACRSFIN", Iif(Len(aPgtos[nX]) >= __ljAcrescFi .And. ValType(aPgtos[nX][__ljAcrescFi])=="N",aPgtos[nX][__ljAcrescFi],0) } )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Novo tratamento de visualização sintetizada e para quando nao for recebimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVisuSint
				aAdd( aSL4[Len(aSL4)], { "L4_FORMAID",	aPgtos[nX][8] } )
			EndIf

			If cPaisLoc == "ARG" .AND. (SL4->(FieldPos("L4_CHEQID")) > 0)
				aAdd( aSL4[Len(aSL4)], { "L4_CHEQID",	aPgtos[nX][9] } )
			EndIf

			If cPaisLoc == "ARG" .AND. (SL4->(FieldPos("L4_VLMOED1")) > 0)
				aAdd( aSL4[Len(aSL4)], { "L4_VLMOED1",	aPgtos[nX][10] } )
			EndIf
			
			//Integracao Mensagem Unica
			If lIntegDef 								
				If Trim(aPgtos[nX][3]) == "CH"
					aAdd( aSL4[Len(aSL4)], { "L4_ADMINIS"	, aPgtos[nX][4][04] } )
					aAdd( aSL4[Len(aSL4)], { "L4_NUMCART"	, aPgtos[nX][4][07] } )
					aAdd( aSL4[Len(aSL4)], { "L4_AGENCIA"	, aPgtos[nX][4][05] } )
					aAdd( aSL4[Len(aSL4)], { "L4_CONTA"		, aPgtos[nX][4][06] } )
					aAdd( aSL4[Len(aSL4)], { "L4_RG"		, aPgtos[nX][4][09] } )
					aAdd( aSL4[Len(aSL4)], { "L4_TELEFON"	, aPgtos[nX][4][10] } )
					aAdd( aSL4[Len(aSL4)], { "L4_COMP"   	, aPgtos[nX][4][08] } )
				EndIf	
			EndIf

			If lIDCNAB .And. Len(aPgtos[nX]) >= _IDCNAB
				aAdd( aSL4[Len(aSL4)], { "L4_IDCNAB"   	, aPgtos[nX][_IDCNAB] } )
			EndIf

			If Type("lAutoExec") == "L" .And. lAutoExec .And. !lFtvdVer12 .AND. !lECommerce .And. !lAutomato .And. Len(aPgtos[nX]) >= _TEFINTEG

				aAdd( aSL4[Len(aSL4)], { "L4_CONHTL"	, aPgtos[nX][_CONTAHTL] } )
				
				//Armazena informacoes do TEF
				If Len(aPgtos[nX][_TEFINTEG]) > 0
				aAdd( aSL4[Len(aSL4)], { "L4_VENDTEF"	, aPgtos[nX][_TEFINTEG][1] } )
				aAdd( aSL4[Len(aSL4)], { "L4_DATATEF" 	, aPgtos[nX][_TEFINTEG][2] } )
				aAdd( aSL4[Len(aSL4)], { "L4_HORATEF" 	, aPgtos[nX][_TEFINTEG][3] } )
				aAdd( aSL4[Len(aSL4)], { "L4_DOCTEF"	, aPgtos[nX][_TEFINTEG][4] } )
				aAdd( aSL4[Len(aSL4)], { "L4_AUTORIZ"	, aPgtos[nX][_TEFINTEG][5] } )
				aAdd( aSL4[Len(aSL4)], { "L4_DATCANC"	, aPgtos[nX][_TEFINTEG][6] } )
				aAdd( aSL4[Len(aSL4)], { "L4_HORCANC"	, aPgtos[nX][_TEFINTEG][7] } )
				aAdd( aSL4[Len(aSL4)], { "L4_DOCCANC"	, aPgtos[nX][_TEFINTEG][8] } )
				aAdd( aSL4[Len(aSL4)], { "L4_INSTITU"	, aPgtos[nX][_TEFINTEG][9] } )
				aAdd( aSL4[Len(aSL4)], { "L4_NSUTEF"	, aPgtos[nX][_TEFINTEG][10]} )
				aAdd( aSL4[Len(aSL4)], { "L4_PARCTEF"	, aPgtos[nX][_TEFINTEG][11]} )	
				EndIf
			EndIf
		EndIf
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checa os numerarios        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IsMoney(aPgtos[nX][3])
			nDinheiro += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
								nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) == Alltrim(MVCHEQUE)
			nCheque += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
							nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) == "CC"
			nCartao += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
							nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) == "CD"
			nVlrDebi += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
							nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) == "CO"
			nConveni += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
							nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) $ cFormVale
			nVales += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
							nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) == "FI"
			nFinanc += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
										nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf lLjcFid .AND. Alltrim(aPgtos[nX][3]) == "FID"
			nCartFid	+= Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
							nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) == "PD"
			nVlrPagDig += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
										nDecimais+1,,nTxMoeda),nDecimais)
		ElseIf Alltrim(aPgtos[nX][3]) == "PX"
			nVlrPagPix += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
										nDecimais+1,,nTxMoeda),nDecimais)
		Else
			nOutros += Round(xMoeda(aPgtos[nX][2]	, nMoedaParc	, nMoedaCor	, dDatabase	,;
							nDecimais+1,,nTxMoeda),nDecimais)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o array aSL4         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IIF(Valtype(aPgtos[nX][1]) == "D", aPgtos[nX][1] == dDatabase, CTod(aPgtos[nX][1]) == dDatabase)  .and. !("|"+Alltrim(aPgtos[nX][3])+"|" $ cMvEntExce) 
			
			nVlrEntrada += Round(xMoeda(nVlrParcela	, nMoedaParc	, nMoedaCor	, dDatabase	,;
								nDecimais+1,,nTxMoeda),nDecimais)
			
		EndIf
	ElseIf !lIntegDef .AND. ( Empty(cFormTrc) .AND. (IsMoney(aPgtos[nX][3]) .OR. Trim(aPgtos[nX][3]) == "VA"  .OR. aPgtos[nX][3] $ cMV_LJPGTRO )) .OR. ;
			( !Empty(cFormTrc) .AND. cFormTrc = aPgtos[nX][3] )
	   nVlrTroco -= If( nVlrTroco > 0, Lj7T_Troco( 2 ), 0 )
	EndIf
Next nX

LjGrvLog(cNumOrc,"PAGAMENTOS",aSL4)

If !lRecebe
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajusta o SL1. VerIfica se eh ou nao um orcamento gerado atraves da rotina de     ³
	//³reserva. Caso afirmativo nao grava os valores no SL1 para nao gerar financeiro   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpc <> 4) .OR. (nOpc == 4 .AND. Empty(SL1->L1_ORCRES) .AND. Empty(SL1->L1_FILRES))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o troco estiver desabilitado, os campos L1_DINHEIR e L1_ENTRADA nao devem ³
		//³considerar o valor recebido a mais(troco)									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrTroco           := 0
		If cPaisLoc == "BRA" .AND. !lHabTroco .AND. !lIntegDef
	       nVlrTroco		:= Lj7T_Troco(2)
	    EndIf
	    If nVlrEntrada > 0
	       nVlrEntrada  := nVlrEntrada
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se tem parcela em Dinheiro, atualiza o valor da entrada ³
			//³considerar o valor recebido a mais(troco)									³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       If cPaisLoc == "BRA" .AND. !lHabTroco
	          If nDinheiro - nVlrTroco >= 0
	             nTrocoEnt  := nVlrTroco
	          Else
	             nTrocoEnt  := nDinheiro
	          EndIf
	          nVlrEntrada  := MAX(nVlrEntrada - nTrocoEnt,0)
	       EndIf
	    EndIf

		//Especie utilizada na geração de Nota Fiscal sobre Cupom Fiscal
	    if Len(aPafNotaCF) > 0
	    	aAdd( aSL1, { "L1_ESPECIE"  ,"NFCF" } )
	    EndIf

		aAdd( aSL1, { "L1_DINHEIR" ,MAX(nDinheiro - nVlrTroco, 0) } )
		aAdd( aSL1, { "L1_CHEQUES" ,nCheque } )
		aAdd( aSL1, { "L1_CARTAO"  ,nCartao } )
		aAdd( aSL1, { "L1_VLRDEBI" ,nVlrDebi } )
		aAdd( aSL1, { "L1_CONVENI" ,nConveni } )
		aAdd( aSL1, { "L1_VALES"   ,nVales } )
		aAdd( aSL1, { "L1_FINANC"  ,nFinanc } )
		aAdd( aSL1, { "L1_OUTROS"  ,nOutros } )

		If SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0
			aAdd( aSL1, { "L1_VLRPGDG"  ,nVlrPagDig } )
			aAdd( aSL1, { "L1_VLRPGPX"  ,nVlrPagPix } )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso seja Release 11.5                                        ³
		//³Caso seja Cartão Fidelidade Ativo                             ³
		//³Inclui a opção de Cartão Fidelidade no Array para contabilizar³
		//³as operações por Cartão Fidelidade.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLjcFid
			aAdd( aSL1, { "L1_CARTFID" ,nCartFid } )
		EndIf
		
		If lAutoExC .And. M->LQ_ENTRADA > 0 
			aAdd( aSL1, { "L1_ENTRADA", M->LQ_ENTRADA })	
		Else 
			aAdd( aSL1, { "L1_ENTRADA", nVlrEntrada })	
		EndIf

		//Verifica se o valor do ISS deve ser abatido no valor total da venda.
		lAbateISS := LJ220AbISS(Nil, Nil, SL1->L1_VALISS)

		If nNCCUsada - (LJ7T_Total(2) - ( LJPCCRet() + If(lAbateISS, SL1->L1_VALISS, 0) - nNCCGerada )) > 0
			nL1Credito := (LJ7T_Total(2) - ( LJPCCRet() + If(lAbateISS, SL1->L1_VALISS, 0) - nNCCGerada ))
		Else
			nL1Credito := nNCCUsada - nNCCGerada
		EndIf
		aAdd( aSL1, { "L1_CREDITO" ,  nL1Credito } )
		aAdd( aSL1, { "L1_RESERVA" ,If(lReserva,"S","") } )
	ElseIf (nOpc == 4) .AND. lReserva .AND. Empty(SL1->L1_DOCPED)
		aAdd( aSL1, { "L1_CREDITO" , (nNCCUsada-nNCCGerada) } ) // Aqui se zerado, na finalização ocorre erro na função LjBaixaNCC.
	EndIf														// Pois a mesma, passa o campo L1_CREDITO como parâmetro na função FrtIncluiCR
																// e se estiver zerado, ocorrerá erro na inclusão da tabela SE1.	
	If lFtvdVer12
		//-------------------------------------------------------
		//|Tratamento dos campos de transferencia de portador e |
		//|carteira automatico (FRA)                            |
		//-------------------------------------------------------
		If SL1->(ColumnPos("L1_TRCXGER")) > 0
			If lUsaFecha .AND. lUsaTransf
				aAdd(aSL1,{"L1_TRCXGER",.T.})
			Else
				aAdd(aSL1,{"L1_TRCXGER",.F.})
			Endif
		Endif
		If SL1->(ColumnPos("L1_TREFETI")) > 0
			aAdd(aSL1,{"L1_TREFETI",.F.})
		Endif
	EndIf

	//----------------------------------------------------------------------------
	//| Gravação dos Vendores informados na L2 quando o parametro MV_LJTPCOM = 2 |
	//----------------------------------------------------------------------------
	For nX := 1 To Len(aVendDig)
		If SL1->(ColumnPos("L1_VEND" + Alltrim(Str(nX)) )) > 0
			aAdd( aSL1, { "L1_VEND" + Alltrim(Str(nX))  , aVendDig[nX] })
		EndIf
	Next nX

	If lUsaIntFS 
		If lMVLJPDVPA
			aAdd( aSL1, { "L1_IFSANST"  , M->LQ_IFSANST })
			aAdd( aSL1, { "L1_HRST"  	, M->LQ_HRST })
			aAdd( aSL1, { "L1_USRST"  	, M->LQ_USRST})
			aAdd( aSL1, { "L1_DTST"  	, M->LQ_DTST })
		Else	 
			//Se tiver integracao com o financial services
			//e o orcamento não possuir financiamento, atualiza o campo em branco
			If  nOpc == 4 .AND. !Empty(M->LQ_IFSANST) .AND. lTemParcFI   //Finalização de venda
				aAdd( aSL1, { "L1_IFSANST"  , M->LQ_IFSANST })
				aAdd( aSL1, { "L1_HRST"  	, M->LQ_HRST })
				aAdd( aSL1, { "L1_USRST"  	, M->LQ_USRST})
				aAdd( aSL1, { "L1_DTST"  	, M->LQ_DTST })
			Else
				If lTemParcFI
					aAdd( aSL1, { "L1_IFSANST"  , IIF( !lFSCliPad , "9", "0") })
				Else
					aAdd( aSL1, { "L1_IFSANST"  , space(TamSX3("L1_IFSANST")[1]) })
				EndIf
				aAdd( aSL1, { "L1_USRST"  		, space(TamSX3("L1_USRST")[1]) })
				aAdd( aSL1, { "L1_HRST"  		, space(TamSX3("L1_HRST")[1]) })
				aAdd( aSL1, { "L1_DTST"  		, CtoD("") })
			EndIf
		EndIf
	EndIf

	If cPaisLoc == "ARG" .And. SL1->(ColumnPos("L1_ADIC5")) > 0 .And. SLQ->(ColumnPos("LQ_ADIC5")) > 0
		aAdd( aSL1, {"L1_ADIC5", M->LQ_ADIC5 } )
	EndIf

	//-------------------------------
	//|Chama as rotinas de gravacao |
	//-------------------------------
	If lFtvdVer12
		lGrava := Lj7GrvOrc( aSL1, aSL2, aSL4, NIL, NIL, NIL, NIL, lAlteraPrc )[1]
	Else
		lGrava := Lj7GrvOrc( aSL1, aSL2, aSL4 )[1]
	EndIf

    //Cria semaforo com orçamento gerado, para não recuperar o mesmo orçamento caso alguem acesse com a mesma estação
    If nOpc == 3 .And. lGrava
        Lj7XSL1("C", .F.)
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a Integracao Protheus x SIAC estiver ativa,       |
	//³ou se for mantida a NCC na gravacao do orcamento,    |
	//³Carregamos o array aMDJ para que a NCC utilizada seja|
	//³ relacionada ao orcamento aberto.					|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (lIntSiac .OR. lLjNCCOr ) .AND. Ascan( aNCCItens,{|x| x[1] == .T.} ) > 0
		// Grava as NCCs para que na subida da venda elas sejam baixadas.
		Aadd(aMDJ,{"MDJ_FILIAL"  	,xFilial("MDJ")		})
		Aadd(aMDJ,{"MDJ_DOC"  	 	,SL1->L1_DOC	 	})
		Aadd(aMDJ,{"MDJ_SERIE"   	,SL1->L1_SERIE	 	})
		Aadd(aMDJ,{"MDJ_CLIENT" 	,SL1->L1_CLIENTE 	})
		Aadd(aMDJ,{"MDJ_LOJA"  	 	,SL1->L1_LOJA		})
		Aadd(aMDJ,{"MDJ_OPERAD" 	,SL1->L1_OPERADO	})
		Aadd(aMDJ,{"MDJ_EMIS"   	,SL1->L1_EMISSAO	})
		Aadd(aMDJ,{"MDJ_NCCUSA"  	,nNCCUsada			})
		Aadd(aMDJ,{"MDJ_NCCGER" 	,nNCCGerada			})
		Aadd(aMDJ,{"MDJ_CREDIT"  	,SL1->L1_CREDITO	})
		Aadd(aMDJ,{"MDJ_NUMORC" 	,SL1->L1_NUM		})
		Aadd(aMDJ,{"MDJ_OPER"  		,"B"				})
		Aadd(aMDJ,{"MDJ_SITUA" 		,Iif(lLjNCCOr,"OR","NP")})

		Frt060GrvNcc( aMDJ , aNCCItens , 1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apos confirmar a gravacao do Orcamento pergunta               ³
	//³Se o usuario deseja cancelar o cupom                          ³
 	//³ Faz o cancelamento do Cupom quando for concomitante qdo sair ³
	//³ da venda. Nao faz essa verIficacao qdo eh visualizacao       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGrava .AND. nTipo == 1 .AND. lVAssConc .AND. !lEmitNFCe .And. !lIsPafNfce
       /* VerIfica se ha um cupom em aberto. Caso afirmativo, faz o    
	   //³ cancelamento antes da abertura de outro                      
	   //³ .T. pergunta antes de cancelar o cupom                   */
	   nRet := IfStatus( nHdlECF, '5', @cRetorno )
       If nRet == 7
          cMsg := STR0079 // "Existe um Cupom Fiscal em aberto, deseja efetuar o cancelamento e abandonar a venda ?"
          lRet := MsgYesNo( cMsg, STR0007 )	 //###'Atenção'
       	  If lRet
	       	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Validação de superior³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       	 If LjProfile(8)
	       	 	nRet	:= IfCancCup( nHdlECF )
		        lGrava	:= .T.
				//³dá um tempo para a impressora fazer a impressao do cancelamento³
		        Inkey(8)
		     Else
		        lGrava := .F.
		     EndIf
		  Else
  			 lGrava := .F.
          EndIf
       EndIf
	EndIf

	If CrdxInt() .AND. nTipo == 1 .AND. lGrava
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Cancela o contrato caso nao seja associado ao orcamento           ³
	   //³Se tiver alguma parcela financiada, nao verIfica se deve cancelar ³
	   //³o contrato, caso contrario, verIfica para nao deixar contrato pen-³
	   //³dente															    ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If Len(aContraTmp) > 0

 	      Conout("15.LOJA701C - Lj7PrepOrc - "  +;
	      		   " Orcamento: " + M->LQ_NUM  +;
	               " Contrato : " + If( Empty(cContrato), " ", cContrato) +;
	      		   " If Len(aContraTmp) executa CrdAtuPend : " )

	      CrdAtuPend( "SL1"   ,10    ,aContraTmp   ,lTemParcFI   ,;
	                  .F.     )
	   Else
	   		Conout("16.LOJA701C - Lj7PrepOrc - "  +;
	      		   " Orcamento: " + M->LQ_NUM  +;
	               " Contrato : " + If( Empty(cContrato), " ", cContrato) +;
	      		   " If Len(aContraTmp) <= 0 " )
	   EndIf
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Se for gravacao de orcamento, inicializa aCrdCliente e cContrato	³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Lj7SetCRDClie(.T.)

       Conout("17.LOJA701C - Lj7PrepOrc - "  +;
	   		   " Orcamento: " + M->LQ_NUM  +;
	           " Contrato : " + If( Empty(cContrato), " ", cContrato) +;
	     	   " Executa Lj7SetCRDClie " )
    Else
    	Conout("18.LOJA701C - Lj7PrepOrc - Orcamento: " +  M->LQ_NUM + "  Sem Integracao com o CRD")
	EndIf

	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
	//³MAN0000604-01 - Integração Protheus x Financial Service classe da analise de credito³
	//³Verifica se o orçamento deverá ser enviada a análise de crédito                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
	ENDDOC*/

	If lUsaIntFS .and. lGrava .and. lTemParcFI  .AND. !lMVLJPDVPA .AND. !lFSCliPad
		oLjIntFSAn := LjClInFSAn():New(SL1->L1_FILIAL, SL1->L1_NUM)
  		If !(nTipo == 2 .AND.  !Empty(SL1->L1_USRST))
  			oLjIntFSAn:EnviarAnal("E")
  			Conout("17.LOJA701C - Lj7PrepOrc - "  +;
	   		   " Orcamento: " + M->LQ_NUM  +;
	   		   " Executa  LjClInFSAn:EnviarAnal() - Analise de credito" )

			oLjIntFSAn:ExibirResp(!lAutoExC)
		EndIf
		If nTipo == 2   //Se for finalização da venda, não permite o prosseguinto da gravacao
			lGrava := oLjIntFSAn:LiberarOrc()
	   	EndIf

	   	If oLjIntFSAn <> Nil
	   		FreeObj(oLjIntFSAn)
	   		oLjIntFSAn := nil
	   	EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a funcao fiscal de finalização de Calculo              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(MaFisFound("NF"))
		MaFisEnd()
	EndIf
Else
	lGrava := .T.
EndIf

If !lMVLJPDVPA .AND. (nTipo == 1) .AND. lGrava // Só grava o motivo na geração do orçamento se não for PDV e se orçamento (nTipo = 1 - Orçamento)
	Lj7GrvMotDesc("", "", cNumOrc , "O") // (cSerie, cDoc , cNumOrc, cTipo ) - Grava o motivo de desconto qdo geração de orçamento
EndIf

LjGrvLog(cNumOrc,"GRAVADO O ORCAMENTO",lGrava)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada que possibilita efetuar gravacoes de campos no momento ³
//³ de finalizacao do orcamento ou quando ocorre algum erro de comunicacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLj7052 .AND. !lFtvdVer12
	U_LJ7052( nOpc , nTipo , lGrava)
EndIf

If lFTVD7052 .AND. lFtvdVer12
	U_FTVD7052( nOpc , nTipo , lGrava)
EndIf

If !Empty(LOG_TEF)
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Finalização Geração Orçamento - ' + If( lGrava, 'S', 'N' ))
EndIf

If nTipo == 2 .AND. lGrava .AND. (lEmitNFCe .Or. lIsPafNfce) .AND. !IsBlind() .AND. !lRecebe 
	RecLock("SL1", .F.)
	Replace SL1->L1_SITUA with "T1" //T1 - Orcamento Gravado
	SL1->( MsUnLock() )
EndIf

//Apos a gravacao do orcamento ou finalizacao da
//venda, preciso limpar a variavel cCodIss para iniciar um proximo orcamento
If lGrava .AND. ExistFunc("Lj7SetIss")
	Lj7SetIss()
EndIf
RestArea( aArea )
Return lGrava

/*/{Protheus.doc} Lj7GrvVenda
Faz a efetivacao da venda e a impressao do cupom fiscal
@type		Function
@author		Vendas Clientes
@since		20/08/02
@param 		ExpL2 - lFinanceiro - Indica se eh para gerar a movimentacao financeira ao gravar a venda
±±º         ExpL3 - lRecTrib - Chama a funcao de recalculo das tributacoes.
±±º         ExpA4 - Array com os dados do consumidor Final(Loc. Arg)
±±º         ExpN5 - Handle do arquivo de log
±±º         ExpL6 - .T. Emite NF/.F. Emite Cupom
±±º         ExpN7 - Opcao do aRotina
±±º         ExpN8 - Tipo da operacao: 1-orcamento;2-venda	
@return 	ExpL1 - Indica se conseguiu ou nao fazer a gravacao
@example
Lj7GrvVenda( ExpL2, ExpL3, ExpA4, ExpN5, ExpL6, ExpN7, ExpN8)  
/*/

Function Lj7GrvVenda(	lFinanceiro , lRecTrib  , aDadosCF	, nHandle		,;
						lEmiteNF    , nOpc      , nTipo		, lTemTefPend	,;
						aTefBKP		, nDescOrc  , cLQFrete	, lJob			,;
						nVlrAcrsFi 	, cCgcCli   , cNomeCli	, lNfManual		,;
						lImpReserva	, nFatorRes , nFatorVen	, lTefPed		,;
						cEspFo		, cDocFo	, cTpGeraGdp, nDescontFi	,;
						lDscCupTef	, nTotICM	, aDadosCNeg, nArredondar	,;
						lErroNFCe	, lTefAbort , cTipoCli 	, nSaveSx8 		,;
						nValRes		, lErroNFe	, cMsgErro  , lCartao       ,;
						lNSUDigitado, lOnlyServ )

Local aArea			:= Lj7GetArea( {"SL1","SL2","SL4"} )		// Salva area do SL1, SL2 e SL4
Local aRet          := {.T.,'',''}				// Array com retorno do TEF, Cupom e numero do orcamento
Local lRet 			:= .F.						// Retorno da funcao
Local lConfCRD      := .F.						// Controla se houve confirmacao da transacao do SIGACRD
Local cDoc			:= ""						// Numero do cupom
Local cPdv 			:= ""						// Numero do PDV
Local cSerie 		:= ""						// Serie do documento
Local cMV_CLIPAD	:= PadR(SuperGetMV("MV_CLIPAD"),TAMSX3("LQ_CLIENTE")[1])		// Cliente padrao
Local cMV_LOJAPAD	:= PadR(SuperGetMV("MV_LOJAPAD"),TAMSX3("LQ_LOJA")[1])			// Loja do cliente padrao
Local aSL1			:= {}						// Array com os dados do SL1 a serem gravados no arquivo
Local aSL2			:= {}						// Array com os dados do SL2 a serem gravados no arquivo
Local aSL4			:= {}						// Array com os dados do SL4 a serem gravados no arquivo
Local aSLS          := {}						// Array com os dados do SLS a serem gravados no arquivo (Loc. Argentina)
Local aMAD          := {}						// Array com os dados do MAD a serem gravados no arquivo (endereco)
Local aReservas	 	:= {}						// Array com os dado da reserva
Local aNumLay       := {}						// Numero do Lay-Away para baixa (Loc. Porto Rico)
Local aRetCrd       := {}						// Array de retorno com informacoes de credito do cliente(SIGACRD)
Local aDadosTefNF	:= {}						// Array com informacoes do TEF enviados para impressao de NF
Local nI, nX 		:= 0						// Controle de loop
Local nCont 		:= 0						// Contador
Local nVlrTroco 	:= 0						// Valor do troco
Local nVlrAux 		:= 0						// Valor auxiliar, utilizado para as NCCs
Local nPosLay       := 0						// Posicao do numero do Lay-Away
Local nPosItLay     := 0						// Posicao do item do Lay-Away
Local nRecnoSL2     := 1						// Recno do SL2
Local nOutros       := 0						// Conteudo do L1_OUTROS
Local nPosVlItem    := 0						// Posicao do Valor Total do Item
Local nPosProd		:= 0						// Posicao da codigo do produto
Local nPosQtd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade
Local nPosStTrib	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_SITTRIB"})		   	// Posicao do codigo do Vale Presente
Local nTotalItem    := 0						// Totalizador do item
Local nTotalLay     := 0						// Retorno da funcao a800Total()
Local nVlrTrcAux    := 0						// Troco convertido para a moeda da parcela
Local lTefOk	    := .F.						// Valida se o TEF foi OK
Local lTEFFat       := .F.						// Uso do TEF dentro do modulo Faturamento
Local lCompensa     := .F.						// Compensacao do Lay-Away(Loc. POR|EUA)
Local lLayTotal     := .T.						// Valida se o nTotalItem eh igual nTotalLay ou se MV_LWPARC esta Falso
Local lImpNF		:= .T.						// Indica se a NF foi impressa corretamente
Local cTotRecNFis   := ""
Local cNumCupom     := Space(TamSx3("L1_DOC")[1])	// Numero do cupom fiscal
Local cNumPdv 		:= Space(TamSx3("L1_PDV")[1])	// Numero do PDV
Local lErroCF		:= .F.						// Valida se houve erro na impressao do cupom fiscal / envio da NFC-e
Local lLj7019       := ExistBlock("LJ7019")		// VerIfica se existe o PE LJ7019
Local xRet										// Retorno do Execblock LJ7019
Local lErrCupTEF	:= .F.						// Valida se houve erro no cupom TEF
Local lGaveta       := ( ! Empty(LJGetStation("GAVETA")) )	// Valida se a estacao utiliza gaveta
Local lAbtoAll      := .F.						// Valida se houve abatimento de PIS / COFINS
Local cMvSimb1		:= SuperGetMv("MV_SIMB1")	// Simbolo da moeda principal
Local cAdminis		:= Space(TamSX3("L4_ADMINIS")[1])// Variavel com a administradora financeira
Local cStatus       := ""						// Status do contrato
Local lLog1       	:= SubStr(LJGetProfile("LOGERRO"),1,1) == "S" // Tem Log de Erro
Local lLog4         := SubStr(LJGetProfile("LOGERRO"),4,1) == "S" // Log de Recuperacao, grava as parcelas
Local lForcada		:= .F.						// Indica se a venda foi off-line ou on-line quando integra com SIGACRD
Local lHabTroco     := SuperGetMV( "MV_LJTROCO", ,.F. )   //Determina que o controle de troco esta habilitado
Local nSize         := 0						// Tamanho do arquivo de LOG de recuperacao
Local cRBuffer      := ""						// Buffer com conteudo da linha do log txt
Local nPos			:= 0						// Posicao do campo no array
Local nVlrEntrada	:= 0						// Valor de entrada
Local nVlrParc      := 0						// Valor da parcela calculado quando troco desabilitado
Local cMV_CRDAVAL   := SuperGetMV("MV_CRDAVAL",,"13|22|43")		// Parametro que define os modulos e processos que tem analise de credito
Local aImpCheque    := {}						// Controla se os cheques da venda foram impressos
Local lGrvPon		:= .F.						// Valida se grava pontos
Local cMsgResg   	:= ""						// Imprime no Rodape do cupom os vales resgatados
Local aProdCri		:= {}						// Array com os produtos para analise de criterio de pontos
Local cGrupoProd	:= ""						// Variavel com o grupo do produto
Local lUsafd      	:= SuperGetMV("MV_LJUSAFD",,.F.)	// Parametro que define se o cliente utiliza Vale Compra
Local aVlrAcres		:= {}						// Array para incremento do acrescimo por item
Local nTamE1_NUM	:= TamSX3("E1_NUM")[1]		// Tamanho do campo E1_NUM - performance
Local lVAssConc	    := LjVassConc()				//Indica se o cliente utiliza a Venda Assistida Concomitante
Local lLj7040       := ExistBlock("LJ7040")		// VerIfica se existe o PE LJ7040
Local cMvCrdForm	:= SuperGetMV("MV_CRDFORM",,"VA") 		// Forma de pagamento nao considerada na pontuacao do CRD
Local nTamF2Esp     := TamSX3("F2_ESPECIE")[1]              // Tamanho no SX3 da especie do documento
Local lLojR860A		:= ExistBlock("LOJR860A") .And. SuperGetMv("MV_LJLOCNC",.F.,.F.)	// Verifica a utilização do ponto de entrada para a impressão da NCC // Roberto
Local cMvLjTGar		:= SuperGetMV("MV_LJTPGAR",,"GE")		//  Define se é tipo GE
Local aProdGar		:= {}                  		// Variável para identificação do produto Garantia
Local lAvalPremio   := .F.									// VerIfica se deve fazer analise de pontuacao do cliente
Local nTotPontos    := 0  									// Total de pontos
Local cPgVc 		:= ""									// Informa que houve pagamento com vale-compra
Local nPag			:= 0									// Total de pagamento dIferente de vale-compra
Local aRecnoSE1     := {}                                  // Array com os recnos do SE1 para compensacao do Lay-Away
Local cRetorno		:= ""									// Retorno da Impressora
Local lAterSl2		:= .F.									// Se altera SL2
Local lSemRede		:= .F.									// Variavel que retorna se a rede selecioda no TEF existe na base
Local lMVTELAFIN	:= SuperGetMv("MV_TELAFIN",,.T.)		// Define se mostra a tela de administradora
Local lVendaCup		:= .T.									// Se a venda eh proveniente de Cupom ou Nota Fiscal
Local nFrete		:= MaFisRet(, "NF_FRETE") 				//Valor do frete na venda
Local nSeguro		:= MaFisRet(, "NF_SEGURO")				//Valor do Seguro na venda
Local nDespesa		:= MaFisRet(, "NF_DESPESA")				//valor das despesas na venda
Local nNumItens		:= 0 									//Total de itens da venda
Local cSeqTrans		:= ""									//Tratamento da sequencia do TEF
Local nFreDesSeg	:= 0				                    // Soma Frete despesas e seguro
Local cMvTmkLoj     := SuperGetMV("MV_TMKLOJ",, "N") 		// verIfica se ha integracao com o Callcenter
Local nY			:= 1									// Contador de for...
Local aAreaJob  	:= {}
Local aAcrFin		:= {}									// Array para armazenar o acrescimo financeiro proporcional por item
Local cContDoc      := ""              					    // Contador de Cupom Fiscal
Local lProcBaixa 	:= .T.									// Verifica se procura baixa
Local cValidRec		:= "1"
Local lPergGrCFD	:= (SuperGetMv("MV_CFDUSO" , ,"0") == "1")			// Indica se deve perguntar pela geracao do CFD.
Local lGrvPCFD		:= .T.									// indica se Grava CFD quando
Local aMsgCert		:= {}
Local lLOGTEF       := SLG->(ColumnPos("LG_LOGTEF"))>0				// Verifica se existe o campo LG_LOGTEF
Local lAchouSLG     := .F.
Local cPath         := ""
Local lUsafdOff		:= SuperGetMV("MV_FRTCRD",,.F.) 				// verifica se usa crd(fidelizacao) por Ws
Local cMsg          := ""
Local nMvLjTpDes	:= SuperGetMv( "MV_LJTPDES", , 0 )													// Indica qual desconto sera' utilizado 0 - Antigo / 1 - Novo (objeto)
Local aAreaSA1		:= {}
Local oLJCLocker := If( SuperGetMV( "MV_LJILVLO",,"2" ) == "1", LJCGlobalLocker():New(), )
Local cNumCart		:= "" 									//Armazena numero do cartao conforme padrao de seguranca PCI(6 primeiros + 4 ultimos numeros do cartao)
Local aVales		:= {}						// Vale Compra
Local lExistNF		:= .F.									//Verifica a existencia de nota fiscal duplicada
Local cDescErro		:= ""									//Descricao do erro ocorrido
Local lSped         := .F.                                 	// Verifica se a especie eh SPED
Local cEspecie      := Space(nTamF2Esp)       				// Especie do documento
Local cEspecNf      := Space(nTamF2Esp)       				// Especie do documento
Local dData			:= dDatabase							// Data para atualiza L4_data com dias de vencimento do sar
Local oWSV													// Objeto webservice de atualizacao do status do Vale Compra
Local lVendaPerdida	:= SuperGetMV ("MV_LJMVPE",,.F.)		// Habilita gravacao de movimento de venda perdida
Local aDescNCC		:= {}                                   // Itens da NCC
Local lTemImpressao := .T.									//Quando PAF-ECF, verifica se possui item sem reserva.
Local aAreaSL2		:= {}									//Salva area SL2
Local aSitTrib		:= {}									// Array com a situacao trib dos itens
Local aNewNCC		:= {}									// Array referente a NCC que será gerada. Roberto
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)				// Verifica as filiais da trabalharam com acrescimento separado
Local lAutoExC 		:= IsBlind()	   						// Verifica se a rotina sera executada via execauto ou nao
Local lUsaFecha		:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. LjUpd70Ok()	//Utilizar conf. de fechamento
Local cTransNat		:= SuperGetMV("MV_LJTRNAT",.F.,"")															//Natureza financeira da transferencia
Local lUsaTransf	:= SuperGetMV("MV_LJTRANS",.T.,.F.) .AND. !Empty(cTransNat) 								//Verifica se a transferencia de caixa esta ativa
Local cMV_LJIMPFA	:= AllTrim(SuperGetMV("MV_LJIMPFA",.F.,"1"))		// Conteudo do parâmetro MV_LJ : 1 - Pergunta se Imprime/2 - Imprime direto/3-Não imprime e não pergunta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt() 	   			//Indica se a recarga de cartao fidelidade esta ativa
Local cNumFid		:= ""									//Numero do cartao fidelidade
Local cLojaFid		:= ""									//Loja da recarga/venda (cartão fidelidade)
Local dDataFid		:= ""									//Data de validade da recarga do cartao fidelidade
Local nValFid		:= 0									//Valor de venda com cartao fidelidade
Local nValRecFid	:= 0									//Valor de recarga cartao fidelidade
Local lProcFidWs	:= .F.									//Indica se a recarga/venda (cartao fidelidade) sera processada via WebService
Local lRecFid		:= .F.									//Indica se o movimento de cartao fidelidade sera do tipo recarga
Local lLjDespa		:= SuperGetMv("MV_LJDESPA",NIL,.F.)	 	//Habilita desconto por Adm e banco
Local aTaxJuros		:= {0,0,0,0}							//Recebe a porcentagem de juros da administradora
Local lMvLjJurCC	:= SuperGetMv("MV_LJJURCC",NIL,.F.)		//Habilita o juros por administradora de cartao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios       ³
//³Paises: Chile/Colombia  - F1CHI              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aBreakNota	:= {}									//Notas geradas a partir da venda quando o numero de itens de venda exceder o limite - Release 11.5 - Chile
Local lNumcFis		:= .T. 									//Indica se grava o numero do documento no campo L1_NUMCFIS
Local lFTVD7019     := ExistBlock("FTVD7019")				// VerIfica se existe o PE FTVD7019
Local lFTVD7040     := ExistBlock("FTVD7040")				// VerIfica se existe o PE FTVD7040
Local cNfRPS		:= "" 									// Numero da NF de Servico "RPS"
Local cSerRPS		:= "" 									// Serie da NF de Servico "RPS"
Local lMVLJPRDSV   	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) 	// Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local nVlrServic	:= 0 									// Valor dos itens de "Servico"
Local nFatorServ 	:= 0 									// Fator (Itens de Servico)
Local nPosData   	:= 0									// Variavel que contem a posicao no Array oTef:aRetCartao:aDatas
Local dDataTrans	:= CtoD(Space(08))                     	// Conteudo do Array oTef:aRetCartao:aDatas
Local nPosTrans		:= 0                                 	// Variavel que contem a posicao no Array oTef:aRetCartao:aValores
Local nValorTrans 	:= 0									// Conteudo do Array oTef:aRetCartao:aValores
Local nPosRetCart   := 0                                    // Varial que contem posicao no Array oTef:aRetCartao
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.)		// Identifica se o cliente utiliza múltiplas transacoes TEF
Local lLoop			:= .T.  								// Variavel utilizada para fazer controle de loop
Local lUsaRegL2	  	:= .T.									// Se irá considerar registro do L2, quando PAF-ECF, necessário considerar registros excluídos
Local lNfPafEcf	  	:= LjNfPafEcf(SM0->M0_CGC)				// Se habilitado modo PAF-ECF
Local cVendido		:= "S"									// Sinaliza item vendido
Local lGE 			:= LjUP104OK()	// Validação do Conceito Garantia Estendida
Local nVlrGar  		:= 0   									// Valor da Garantia Estendida
Local nFatorGar 	:= 0  									// Fator da Garantia Estendida
Local cKeyNfce		:= ""	//Chave da NFCe
Local aNotas 		:= {}	//array de notas
Local nTotImpNCM	:= 0
Local nTotImpFED	:= 0
Local nTotImpEST	:= 0
Local nTotImpMUN	:= 0
Local nTotVLRNCM 	:= 0
Local lMVLJGRVON    := SuperGetMV("MV_LJGRVON",,.T.)									//Parâmetro que identifica se será utilizado o LJGRVBATCH ou trabalhara de forma síncrona
Local lMVLJGRVJB	:= SuperGetMV("MV_LJGRVJB",,.F.)
Local lIsVendaVP 	:= If(Lj7VPNew(),Lj7VPYesNo()=="S",.F.)	// Indica se eh venda de Vale Presente
Local lIsRecarCP 	:= If(Lj7CP_OK(),Lj7CPGetSt()=="S",.F.)	// Indica se eh venda de Recarga de Cartao Presente (Gift Card)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relatorio Gerencial    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRelatGere 	:= SuperGetMV("MV_LJGERRG", ,.F.)  // Gera Relatorio Gerencial
Local cTiposProd	:= SuperGetMV("MV_LJTPRG",.F.,"")  // Tipos de Produto do Relatorio Gerencial
Local cOs			:= ""   							// Armazena a OS
Local nCount		:= 0    							// Contador
Local aRelatGere	:= {}   							// Array dos itens do Relatorio Gerencial
Local nPosConju 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "LR_CONJUNT" }) // Posicao do campo Conjunto
Local nPosVenAvu 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "LR_VENDAVU" }) // Posicao do campo  Venda Avulsa
Local lMvLjImpGf	:= SuperGetMV("MV_LJIMPGF",,.T.)	//Define se imprime a GE como Comprovante Nao-Fiscal
Local nPosTefDados	:= 0								// Posicao no array aTefDados
Local aArrayTEFPos	:= {}								// Guarda o cartao ID+Forma para não chamar a funcao LJ7ConfAdm mais que uma vez quando parcelado
Local lTefManual	:= SuperGetMV("MV_TEFMANU",,.T.)  	// determina se continua manualmente apos cancelar uma operação TEF
Local lSelTefManu	:= .F.								//Valida se foi selecionado o TEF Manual
Local nAux			:= 0								//Variavel auxiliar
Local aNfceSL1		:= {}								// Guarda as informações da SL1 a serem alteradas para transmissão da NFC-e
Local aCampoSL1		:= {}								// Array utilizado para indicar campo que devem ser gravados para transmissão da NFC-e
Local nMoedaParc    := 1								// Moeda corrente
Local aPgtosBKP 	:= {}
Local aPgSintBKP 	:= {}
Local nTotParBkp 	:= 0
Local nSubTotBkp 	:= 0
Local nTotalBkp  	:= 0
Local lTemCartao	:= .F.
Local nDIfVlrAux	:= 0
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lIntegDef	    := Lj701GtInD() //Venda Origem Integração
Local lEmitNFCe	:= (!lFtvdVer12 .Or. lIntegDef) .AND. LjEmitNFCe() // Sinaliza se utiliza NFC-e 
Local aArea2		:= {}
Local aAreaSM0		:= {}
Local aTimeUf		:= {}
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) // Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cHoraRMT		:= ""
Local cNSUVndTef	:= ""								//Contem o número da NSU caso venda com TefManual
Local aNSUVndTef	:= {}								//Informacoes do TEfManual - { Forma (caracter) , ID (caracter), Valor (numerico) , NSU digitada (caracter) }
Local lUseSAT 		:= .F.		//Utiliza SAT
Local cPass 		:= ""		//Chave de ativação SAT
Local aRetSAT		:= ""		//Retorno SAT
Local cXML			:= ""		//xml venda SAT
Local aSatSL1		:= {}		//chave de venda SAT
Local cDocSat 		:= ""		//numero de documento da venda SAT
Local cSerieSat		:= ""		//numero de serie do equipamento SAT
Local nPosTefSint 	:= 0
Local cNumNotaCF	:= ""
Local lAjstaPgto	:= .F. //Responsavel pela verificação de atualização do array aPgtos no tocante a Administradora Finac.
Local lSelAdm       := SuperGetMv("MV_LJADMFI",,.F.) // Parametro que desabilita a escolha das administradoras de cartoes
Local aNFCeICMST	:= {}				//utilizado na NFC-e (contem o valores de ICMS-ST), logo sera substituido por um objeto
Local aRefFiscal	:= {}				//utilizado na NFC-e (Guarda alguns valores da MatxFis para ser utilizado no fonte LOJNFCE)
Local cItemFis		:= ""
Local cCodRede 		:= ""
Local cDescRede		:= ""
Local lAutomato	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local lMultNegoc    := SuperGetMv("MV_LJMULTN",,.F.)
Local lValeTroca    := .F.
Local aSATDoc		:= {}
Local cL4NSUTEF		:= ""
Local cL1NSUTEF		:= ""
Local aRetPbm		:= {} //Retorno das informações retornadas do PBM Funcional Card
Local aPbmImp		:= {} //Informações da impressão do PBM
Local aOrcamentos	:= {}
Local nRetMfe		:= 0 //posição do array de retorno do MFE
Local lCpoPCorte	:= SAE->(FieldPos("AE_PCORTE")) > 0
Local lMvNFCeCnj	:= SuperGetMV("MV_NFCECNJ",,.F.) //nfce conjugada
Local lShowMsgEr	:= .F. // Indica se a mensagem de erro ja foi apresentada
Local lECommerce	:= SuperGetMV("MV_LJECOMM",,.F.) .And. (SL1->L1_ECFLAG == "1")
Local lIDCNAB		:= SL4->(ColumnPos("L4_IDCNAB")) > 0 
Local lValidMsg     := SuperGetMV("MV_CFDMSG",,.T.)
Local aParcTEF		:= {}
Local aReb			:= {}
Local lRetSL4Vld	:= .F.																	//Verifica se haverá gravação do registro da SL4
Local cMV_FormCRD   := SuperGetMV("MV_FORMCRD",,"CH/FI") 									// Formas de pagamento para as quais deve avaliar credito - SIGACRD
Local lTemParcFI    := .F.																	// Controla se tem alguma parcela financiada para avaliacao de credito
Local cMVSCRNOTA	:= SuperGetMV("MV_SCRNOTA")												// Script responsável pela impressção da NF-e
Local bImpNf		:= {|| }																// Bloco para impressão do comprovante
Local lTemPagDig    := .F.	//Controla se na venda tem Pagamento Digital
Local lPagDigOk	    := .F.	//Valida se o Pagamento Digital foi OK
Local lL1VLRPGDG 	:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital e/ou PIX
Local aPagDig		:= {}
Local aPagDigPix	:= {}

Default nValRes		:= 0
Default lFinanceiro	:= .T.
Default lRecTrib 	:= .T.
Default nHandle     := -1
Default lEmiteNF	:= .F.
Default nOpc        := 3
Default nTipo       := 2
Default cLQFrete	:= ""
Default lJob 		:= .F.
Default nVlrAcrsFi	:= 0
Default cNomeCli	:= ""
Default cCgcCli		:= ""
Default lNfManual	:= .F.
Default lImpReserva := .T.
Default nFatorRes	:= 1
Default nFatorVen	:= 1
Default lTefPed		:= .F.
Default nDescontFi 	:= 0
Default cEspFo		:= ""                   //Especie do documento escolhido pelo usuario no inici da venda - Release 11.5 - Chile
Default cDocFo		:= ""					//Numero de Nota definida pelo usuário no inicio da venda - Release 11.5 - Chile
Default cTpGeraGdp	:= GDP_NO
Default lDscCupTef	:= .F.
Default nTotICM		:= 0
Default aDadosCNeg	:= {}
Default nArredondar	:= 0					//Valor para o Instituto Arredondar
Default lErroNFCe	:= .F.					//Valida se houve erro na emissao da Nfce
Default lTefAbort	:= .F.					//se o Tef foi cancelado dentro da lj7Pedido. Verificação p/ não chamar TEF pela segunda vez .
Default cTipoCli 	:= ""
Default nSaveSx8 	:= GetSx8Len()			//Numeracao do SX8
Default lErroNFe	:= .F.					//Valida se houve erro na emissao da NF-e
Default cMsgErro	:= ""					//Descrição do erro
Default lCartao     := .F.                  // Uso do TEF
Default lNSUDigitado	:= .F.
Default lOnlyServ 		:= .F. 				// Variavel utilizada para indicar qdo. a venda possui apenas itens de servico

LjGrvLog(SL1->L1_NUM,"Processo de gravacao da venda, opcao",nOpc)
LjGrvLog(SL1->L1_NUM,"EMITE NOTA FISCAL",lEmiteNF)
LjGrvLog(SL1->L1_NUM,"Tipo da Operacao ",nTipo)

// Verifica se utiliza SAT
lUseSAT 	:= LjUseSat()

//Validação para não deixar prosseguir, caso esteja efetuando venda de Vale Presente
//com NFe, NFCe ou Sat e o campo LG_SERNFIS não estiver preenchido
If lIsVendaVP .AND. (lEmitNFCe .OR. lEmiteNF .OR. lUseSAT) 
	If 	SLG->(FieldPos("LG_SERNFIS")) > 0 
		If Empty(LjGetStation("LG_SERNFIS")) 
			MsgStop(STR0219) // Não é possivel continuar! Para concluir a operação com Vale Presente, é obrigatório o preenchimento do campo 'Serie não Fiscal' no cadastro de estação (LG_SERNFIS).
			Return .F.
		Endif
	Else
		MsgStop(STR0220) // Não é possivel continuar! Para concluir a operação com Vale Presente, verifique a existência do campo 'Serie não Fiscal' no cadastro de estação (LG_SERNFIS).
		Return .F.
	Endif
Endif

If SLG->(ColumnPos("LG_CODSAT"))>0
	cPass		:= IIF(LJGetStation("CODSAT",.F.) == Nil,"",LJGetStation("CODSAT",.F.))
EndIf

cHoraRMT := SuperGetMv("MV_HORARMT",.F.,"2")
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

If !LjRecVlEmul(cValidRec) .AND. !lFtvdVer12
   Return .F.
ElseIf lFtvdVer12 .AND. !( LjRecVlEmul(cValidRec) .OR. LjValECFE() )
   Return .F.
EndIf

aRetAdmTef:= {} //Reinicializa o array

//Somente considera ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas, se a venda nao for com "Reserva" e nao for concomitante
lMVLJPRDSV := lMVLJPRDSV .And. Empty(SL1->L1_ORCRES) .And. Empty(SL1->L1_DOCPED) .And. !lVAssConc

If nNccUsada = 0 .OR. nNccUsada < Lj7T_Total(2)
	For nX := 1 To Len( aPgtos )
		If	cPaisLoc == "ARG" .AND. (aPgtos[nX][1] == CtoD(Space(8)) .OR. aPgtos[nX][2] == 0 .OR.;
		Empty(aPgtos[nX][3]))
			cMsg := STR0117		// "Para confirmar a gravação é necessário definir a forma de pagamento."
			aAreaSA1 := SA1->(GetArea())
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek( xFilial("SA1") + M->LQ_CLIENTE + M->LQ_LOJA ) .AND. !Empty(SA1->A1_COND)
				cMsg += CTRL
				cMsg += STR0140	// "Observação: A condição de pagamento padrão do cliente é: "
				cMsg += SA1->A1_COND
			EndIf
			RestArea(aAreaSA1)
			If lAutoExC
				Conout(cMsg)
				Help( " ", 1, "Help",, cMsg, 1, 0 )
			Else
				MsgInfo(cMsg)
			Endif
			Return .F.
		EndIf
	Next nX
EndIf

If !lJob
	nVlrTroco 	:= Lj7T_Troco(2)			// Valor do troco
	cSeqTrans	:= M->LQ_NUM				//Tratamento da sequencia do TEF

	nPosVlItem  := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VLRITEM"})][2]	// Posicao do Valor Total do Item
	nPosProd	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao da codigo do produto
	nPosQtd	  	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade

	If !lAutoExec
	    If cProfStr2 == NIL
			cProfStr2 := GetPvProfString("Recebimento Titulos", "Totalizadores", "01", cGetCliDir+"SIGALOJA.INI")
		EndIf
		cTotRecNFis   := cProfStr2
	EndIf
Else
	If !lIntegDef //Integracao nao considera troco
		nVlrTroco 	:= SL1->L1_TROCO1			// Valor do troco		
	EndIf
	
	cSeqTrans	:= SL1->L1_NUM				//Tratamento da sequencia do TEF
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso do recebimento de titulos de MG  eh      ³
//³necessario preencher o numero da transacao do TEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cSeqTrans) .AND. lRecebe .AND. LJAnalisaLeg(37)[1]
	If Len(aTitulo) > 0
		cSeqTrans := aTitulo[1][3]
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no registro do orcamento corrente.               ³
//³                                                           ³
//³este processo é utilizado devido a algumas vezes o registro³
//³nao estar posicionado.                                     ³
//³                                                           ³
//³este processo nao deve ser removido                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SL1->L1_TIPO <> "P" .AND. Empty(SL1->L1_ORCRES) .AND. ((SL1->L1_FILIAL + SL1->L1_NUM) <> (xFilial("SL1") + M->LQ_NUM)) //phsm
	SL1->(DbSetOrder(1))
	SL1->(DbSeek(xFilial("SL1")+M->LQ_NUM))
EndIf

If !Empty(LOG_TEF)
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Inicio Gravação da Venda')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se foram informadas as formas de pagamento. Caso negativo nao    ³
//³permite finalizar a venda.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoExec .AND. lFinanceiro .OR. lMVLJPDVPA

	If !Empty(LOG_TEF)
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Gravação da Venda - S')
	EndIf

	nVlrAux := nNCCUsada
	aEval( aPgtos, {|x| nVlrAux+=x[2] } )
	If nVlrAux == 0
		Aviso( STR0007, STR0010, {STR0005} ) //"Atenção"###"Não foram informadas as formas de pagamento. Impossível fechar a venda."###"OK"
		Return lRet
	EndIf

	If cPaisLoc <> "BRA"
		//Faz tratamento especifico caso esteja habilitada a implementacao de taxa administrativa de Cartao de credito
		If lMvLjJurCC
			aEval( aPgtosSint, {|x| If(x[1]$_FORMATEF, lTemCartao:=.T. , Nil) } ) //Verifia se tem cartao nas formas de pagamento escolhida
			If lTemCartao
				//Verifica se o valor total pago escolhido na tela (considerando todas a formas de pagamento) esta de acordo com o total da venda
				nDIfVlrAux := Lj7T_Total( 2 ) - Lj7T_TotPar( 2 )
				If nDIfVlrAux > 0
					//"O total de parcelas para pagamento é menor que o valor total da venda.","Total das Parcelas - Total da Venda: "
					MsgStop( 	STR0001 + Chr( 13 ) + ;
								STR0104 + " " + AllTrim( Transform( ( nDIfVlrAux ), PesqPict( "SL1", "L1_VLRTOT",, nMoedaCor ) ) ) )
					Return .F.
				EndIf
			EndIf
		EndIf

		//Faz backup dos arrays "aPgtos" e "aPgtosSint"
		aPgtosBKP 	:= aClone(aPgtos)
		aPgSintBKP 	:= aClone(aPgtosSint)
		//Faz backup dos totais da venda
		nTotParBkp := Lj7T_TotPar(2) //Faz backup do Total das parcelas da Venda
		nSubTotBkp := Lj7T_SubTotal(2) //Faz backup do SubTotal da Venda
		nTotalBkp  := Lj7T_Total(2) //Faz backup do Total da Venda
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se necessario abre a tela para para pedir os dados dos       ³
	//³ cheque / financiadora                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Lj7InfPgtos( nTipo	, @aVales	, NIL		, NIL,;
					 NIL	, @aTaxJuros, aTefBKP 	)

		If !Empty(LOG_TEF)
			LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Tela Digitação de Dados do Pagamento - N')
		EndIf

		Return .F.
	Else
		If cPaisLoc <> "BRA"
			/*------------------------------------------------------------------------------------------
			Abre a tela com a relacao dos valores de cartao atualizados a serem cobrados.
			Essa tela se fez necessario, devido a situacao onde existe um determinado imposto que somente eh calculado
			quando a venda atinge determinado valor, desta forma quando se utiliza o conceito de taxa de juros no cartao
			os valores a serem cobrados nos cartoes podem sofrer alteracoes quando esse determinado imposto fizer parte do calculo,
			ja que o valor a ser cobrado do cliente sera um valor maior. Entao os valores do cartao(s) a serem cobrados sofrerao
			alteracao e assim serao exibidos com os novos valores a ser cobrados.
			Valida se pode usa Taxa Administrativa por Cartão de Crédito
			------------------------------------------------------------------------------------------*/
			If lMvLjJurCC .AND. aTaxJuros[1] > 0 .And. MaFisFound("NF")
				If !LjTelaCard(@aTaxJuros, aPgtosBKP, aPgSintBKP, nTotParBkp, nSubTotBkp, nTotalBkp, aDadosCF, cTipoCli, nSaveSx8)
					Return .F.
				EndIf
			EndIf
		EndIf
	EndIf

	// Valida caso não for faturamento - venda direta
	cTipTef := LjGetStation("TIPTEF")
	If !lFtvdVer12
		If !LjNfUsaTef(SM0->M0_CGC)
			lCartao := LJXVERTEF(.F.)
		Else
	        lTefFAT	:= LJXVERTEF(.F.)
	   		lCartao := .F.
		EndIf

		If !Empty(LOG_TEF)
			LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Tem parcelas CC/CD/MH ? - ' + If( lCartao, 'S', 'N' ))
		EndIf
    ElseIf lFtvdVer12
	    lTefFAT	:= LJXVERTEF(.F.)
	   	lCartao := .F.

		If !Empty(LOG_TEF)
			LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Tem parcelas CC/CD/MH ? - ' + If( lCartao, 'S', 'N' ))
		EndIf
    EndIf

    //Analise de credito integrada com SIGACRD
    If CrdxInt()

		For nX := 1 to Len(aPgtos)		//Verifico se realmente há análise de SIGACRD
          If AllTrim(aPgtos[nX][3]) $ cMV_FormCRD
             lTemParcFI  := .T.
          EndIf
		Next nX

		If lTemParcFI 
			//O array aCrdCliente é obrigado a carregar, para ler depois na função Lj7AprovCrd()
			If Empty(aCrdCliente[1]+aCrdCliente[2]) .AND. M->LQ_CLIENTE+M->LQ_LOJA <> cMV_CLIPAD+cMV_LOJAPAD
				aCrdCliente   := AClone(CrdInfClie(M->LQ_CLIENTE, M->LQ_LOJA))
			Else
				Conout("23.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
				" Contrato: " + If (Empty(cContrato), "", cContrato)  +;
				" aCrdCliente [1] e [2]: "  + ;
				If( Empty(aCrdCliente[1]), "", aCrdCliente[1] )  +;
				If( Empty(aCrdCliente[2]), "", aCrdCliente[2] ) )
			EndIf

			//Se for a opcao Atendimento->Gravacao Venda, nao selecionou analise
			//pelo botao da toolbar e o contrato estiver pendente para ser finali
			//zado ou liberado pelo Credito, preencher cContrato para a confirma-
			//cao da transacao. Nao necessita de nova avaliacao                  
			//Se nao estiver configurado para avaliar credito no orcamento, deve
			//avaliar neste momento
			If !Empty(cContrato) .AND. nOpc == 3 .AND. "11" $ cMV_CRDAVAL 

				Conout("19.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
						" Contrato: " + If (Empty(cContrato), "", cContrato) +;
						" nOpc==3 E 11 $ MV_CRDAVAL - Chama a funcao CrdStContr " )

				//Conteudo do MAH_STATUS  ³
				cStatus    := CrdStContr(cContrato,M->LQ_CLIENTE,M->LQ_LOJA)

				Conout("20.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
						" Contrato: "+ If( Empty(cContrato), "", cContrato) +;
						" Status : " + If( Empty(cStatus), "", cStatus) )

				If !(Val(cStatus) == ST_PEND .OR. Val(cStatus) == ST_LIB)
					Conout("21.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
						" Contrato: "+If (Empty(cContrato), "", cContrato) +;
						" Status : " +If( Empty(cStatus), "", cStatus) +;
						" Status=Pendente ou Liberado " )

					cStatus    := ""
					cContrato  := Space(TamSx3("MAH_CONTRA")[1])
				EndIf
			EndIf
			If Empty(cStatus)
				//Se nao for a opcao Atendimento->Gravacao Venda ou selecionou a ana-
				//lise pelo botao da toolbar, deve re-avaliar o credito. Se ja tiver 
				//um contrato associado a um orcamento, utiliza este contrato  		
				If !Empty(cContrato)
					Conout("22.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
						" Contrato: " + If (Empty(cContrato), "", cContrato) +;
						" Contrato !empty " )
				EndIf

				Conout("24.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
						" Contrato: " + If (Empty(cContrato), "", cContrato)  +;
						" Validacao: Chamou Lj7AprovCrd CCONTRATO ")

				aRetCrd   := AClone(Lj7AprovCRD( "1"  ,@cContrato  ,Lj7T_Total(2)  ,NIL  ,;
													NIL  ,"13"        ,.F. ))
				If Len(aRetCrd) > 1
					If aRetCrd[5]
						//Venda rejeitada
						Conout("25.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
						" Contrato: " + If (Empty(cContrato), "", cContrato) +;
						" Venda Rejeitada " )

					Return (.F.)

					ElseIf aRetCrd[1] == 2
						//Aprovacao off-line
						lForcada  := .T.

						Conout("26.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
						" Contrato: " + If (Empty(cContrato), "", cContrato) +;
						" Venda Aprovada Off-Line " )
					Else
						Conout("27.LOJA701C - Lj7GrvVenda - " +;
						" Orcamento: " +  M->LQ_NUM +;
						" Contrato : " + If( Empty(cContrato), "", cContrato ) )
						Conout(" aRetCrd[1] = " + If( Empty(aRetCrd[1]), "", Alltrim(STR(aRetCrd[1]))))
						Conout(" aRetCrd[2] = " + If( Empty(aRetCrd[2]), "", Alltrim(STR(aRetCrd[2]))))
						Conout(" aRetCrd[3] = " + If( Empty(aRetCrd[3]), "", Alltrim(STR(aRetCrd[3]))))
						Conout(" aRetCrd[4] = " + If( Empty(aRetCrd[4]), "", aRetCrd[4]) )
						Conout(" aRetCrd[5] = " + If( Empty(aRetCrd[5]), "", If(aRetCrd[5],".T.",".F.")))

					EndIf
					If !lRecebe
						Reclock("SL1",.F.)
						SL1->L1_CLIENTE	:= M->LQ_CLIENTE
						SL1->L1_LOJA	:= M->LQ_LOJA
						SL1->(MsUnlock())
					Endif
				Else
					Conout("28.LOJA701C - Lj7GrvVenda - " +;
						" Orcamento: " +  M->LQ_NUM +;
						" Contrato : " + If( Empty(cContrato), "", cContrato ) +;
						" Validacao: aRetCrd =0 " )
				EndIf
			Else
				Conout("29.LOJA701C - Lj7GrvVenda - " +;
						" Orcamento: " +  M->LQ_NUM +;
						" Contrato : " + If( Empty(cContrato), "", cContrato ) +;
						" Status " + cStatus )
			EndIf
			lGrvPon := .T.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SELF-LIQUIDATE                                                ³
			//³-----------------------------                                 ³
			//³Faz a chamada da rotina para escolha dos premios que o cliente³
			//³tem direito. Inclui Brinde, Vale-Compra e Self-Liquidate      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaFd   .AND. (M->LQ_CLIENTE+M->LQ_LOJA <> cMV_CLIPAD+cMV_LOJAPAD )

				lAvalPremio := Len(aPremio) == 0

				If lAvalPremio

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monta array com os produtos comprados para  calcular os³
					//³pontos dessa Venda                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX := 1 to Len(aCols)
						If !aCols[nX][Len(aCols[nX])]
							cGrupoProd :=  Posicione("SB1",1,xFilial("SB1") + aCols[nX][nPosProd],"SB1->B1_GRUPO")
							AADD ( aProdCri, { aCols[nX][nPosProd], cGrupoProd , aCols[nX][nPosVlItem] , aCols[nX][nPosQtd]} )

						EndIf
					Next nX

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Para pagamento com vale-compra deve ser calcula pontos    ³
					//³somente sobre a dIferença. se o pagamento for integral com³
					//³vale compra nao deve pontuar.                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					For nX := 1 to Len( aPgtos )
						If Alltrim( aPgtos[nX][3] ) $ cMvCrdForm
							cPgVc	:= "1"
						Else
							nPag	+= aPgtos[nX][2]
						EndIf
					Next nX


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Faz a chamada da funcao para calcular os pontos referente a venda.³
					//³A regra de pontuacao esta na tabela MAT.                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsafdOff
						aPremio := AClone(Frt271ECrd(M->LQ_CLIENTE,M->LQ_LOJA, nTotPontos, @aLibera, Lj7T_Total(2)))
					Else
						Crd240_002(	"1"		    ,M->LQ_CLIENTE	,M->LQ_LOJA		,aProdCri		,;
								nPag			,NIL		    ,NIL            ,NIL            ,;
								NIL            ,NIL            ,.F.            ,@nTotPontos	,;
								cPgVc  )


						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Chama a rotina de resgate dos pontos. A regra que verIfica    ³
						//³quantos vales o cliente tem direito esta na tabela MAU.       ³
						//³                                                              ³
						//³Esta funcao devera retornar:							      ³
						//³ aDados:{nPontosUsados,  	  							      ³
						//³			Tipo do Premio(1-Vale,2-Brinde,3-Self-Liquidate), ³
						//³			Produto,		                                  ³
						//³			Nro Vale Compra,                                  ³
						//³			Valor,                               			  ³
						//³         % Desconto)			                              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(aCrdCliente[2])
							aPremio := AClone(Crd240Resgate( aCrdCliente[2], M->LQ_CLIENTE, M->LQ_LOJA, Nil, ;
															nTotPontos, @aLibera, Lj7T_Total(2) ))
						Else
							aPremio := AClone(Crd240Resgate( "", M->LQ_CLIENTE, M->LQ_LOJA, Nil, ;
														nTotPontos, @aLibera, Lj7T_Total(2) ))
						EndIf
					EndIf

					nTotPremio := 0


					For nX := 1 to Len(aPremio)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for Self-Liquidate soma o valor³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aPremio[nX][2] == "2" .OR. aPremio[nX][2]=="3"
							If(aPremio[nX][5]<> 0)
								nTotPremio += aPremio[nX][5]
							Else
								nTotPremio += 0.01
								aPremio[nX][5] = 0.01
							EndIf
						EndIf
					Next nX

					If nTotPremio > 0

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o Subtotal da Venda³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Lj7T_Subtotal( 2, LJ7T_Subtotal(2) + nTotPremio)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o total da venda³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Lj7T_Total(2, Lj7T_Total(2) + nTotPremio)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄ¿
						//³Atualiza Forma de pagamento³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄ--Ù
						Lj7CondPg(	2	, M->LQ_CONDPG  , Nil, 	Nil, ;
									Nil	, Nil			, Nil, 	LJ7T_Subtotal(2), ;
									nOpc, .F.    , .T.,	.T. )


						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Retorna a tela de pagamentos para selecionar nova condicao de acordo com novo valor da venda ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Return (.F.)
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gravacao dos itens do selfliquidate e Brinde no aSL2³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Lj7GrvPremio()
				EndIf
			EndIf
		Else
	    	Conout("30A.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM + "  Forma de Pagamento nao esta contida em MV_FORMCRD, por isso, nao entrara em analise do SIGACRD")
		EndIf
	Else
    	Conout("30.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM + "  Sem Integracao com o CRD")
	EndIf
ElseIf IsInCallStack("LJNFCELOT") //Necessario, pois quando ha finalização em lote de orcamentos com forma de pagamento com administradora financeira, a variavel administ deve ser inicializada

    Lj7InfPgtos( nTipo  , @aVales   , NIL       , NIL,;
                     NIL    , @aTaxJuros, aTefBKP   )   
EndIf

If !lAutoExec

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre a Gaveta de Dinheiro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGaveta
		AbreGaveta()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa antes da Trn TEF   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lCCS     := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apos ser realizado a impressao do cupom TEF, eh gerado um  |
	//³ arquivo para a sua reimpressao, exceto VISANET. Este       |
	//³ arquivo deve ser apagado sempre que iniciar uma nova venda |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	L010DelImp()
EndIf
If lLj7040 .AND. !lFtvdVer12
   ExecBlock("LJ7040",.F.,.F.)
EndIf

If lFTVD7040 .AND. lFtvdVer12
   ExecBlock("FTVD7040",.F.,.F.)
EndIf

//Exibição da tela para consulta dos produtos reservados pela Funcional Card
If ExistTemplate("DroVLVen")
	aRetPbm := LJGDadosVL()
	If Len(aRetPbm) > 2 .And. Len(aRetPbm[2]) > 0
		ExecTemplate("DroVLVen",.F.,.F.,{aRetPbm[3],aRetPbm[2],aRetPbm[1],SL1->L1_NUM})
		LJ7DadosVL() 
	EndIf	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a Transacao TEF                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LjGrvLog(SL1->L1_NUM,"Antes do inicio das trasações TEF e TPD - lAutoExec", lAutoExec )

If !lAutoExec 
	If lUsaTef .AND. (lCartao .OR. (LjNfUsaTef(SM0->M0_CGC) .AND. lTEFFat)) .AND. ;
		cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF+";"+TEF_CENTROPAG

		If !Empty(LOG_TEF)
			LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Inicio Transação TEF - S / S / ' + cTipTEF)
		EndIf
	
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Tratamento Parce                                             ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    cOrcamen := SL1->L1_NUM
		aReb     := {}
		aParcTef := {}
	
		//Monta os array's para validação do tef
		LjMnReb(@aReb, @aParcTef,nArredondar)
		LjGrvLog(SL1->L1_NUM,"Vai realizar a transacao TEF",aPgtos)

		If cTipTef == TEF_CLISITEF
			If !lTefPed .AND. !lTefAbort //lAbort controla se a operação tef foi abortada na funcao lj7Pedido, não chamado o TEF de novo

				If (lMFE .And. lIntegrador) .And. lLjEnvPgto
					LjCleanFile() 
					For nX := 1 To Len(aPgtos)
						If AllTrim(aPgtos[nX][3]) $ _FORMATEF
							nRetMfe ++
							LjMsgRun("Enviando pagamento para o VFP-e..." ,,{ || aAdd(aIdPgtoMfe,LjEnvPgto(aPgtos[nX][2],.T.)) })
							If Len(aIdPgtoMfe[nRetMfe]) <= 0	//Tratamento para não prosseguir com a venda caso não houver resposta do MFE
								LjCleanFile()
								Return .F.
							EndIf					
						EndIf	
						IF LEN(aPgtos[nX][4]) > 0
							aAdd(aIdPgtoMfe[nRetMfe],AllTrim(aPgtos[nX][4][7]))	
						ENDIF
					Next nX	
				EndIf	

				oTEF:Operacoes("V", 		aReb, 	@lTemTefPend, 	@aTefBKP, ;
								cSeqTrans, 	NIL,	@aPgtos,		@aPgtosSint, ;
								@oPgtos, 	@oPgtosSint	)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Guarda a transacao TEF, logo após sua finalização, caso ³
				//³haja algum problema será possível exttorná-la.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LJTEFConfRW(cGetCliDir + "CLISITEF."+StrZero(oTEF:nIDTermina,3), .T., oTEF:cCupom, oTEF:cData, oTEF:cHora)
				lTefOk := oTef:lTefOk

				//Tratamento para administradora financeira no caso de recebimento de títulos
				//pois sempre era atribuido o próprio cliente e também impactava quando estava habilitado
				//o paramentro MV_LJUSAFD (Vale Compra)
				If lRecebe .And. Len(aTitulo) > 0
					LJVERADM(@lSemRede, lTefOk)
				EndIf	
			Else
	   			lTefOk := lTefPed
			EndIf
		ElseIf cTipTef == TEF_CENTROPAG
			oTef:Operacoes(aReb)
			lTefOk := oTef:lTefOk
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for TEF Discado e venda com reservas, o comprovante de venda ja foi impresso	|
			//| na funcao Lj7Pedido, portanto nao sera necessario imprimi-lo novamente.			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IsInCallStack("Lj7Pedido")
				lTefOk := .T.
			Else
				lTefOk := LOJA010T(	"V", Nil, aReb	, Nil		,;
									Nil, Nil, Nil	, Nil		,;
									Nil, Nil, Nil	, @lSemRede,,,,,,,,,,, aParcTef )
			EndIf
		EndIf
	
		LjGrvLog(SL1->L1_NUM,"Retorno do TEF",lTefOk)
		If Type("oTef") <> "U" .And. !oTef:lTefOk
			LjGrvLog(SL1->L1_NUM,"Objeto oTef",oTef)
		EndIf
		
		//IMPORTANTE: NAO RETIRAR ESTE TECHO
		//Para vendas com SITEF e utilizando o MFE mas ainda não foi implementado o ajuste no SITEF
		// If lTefOk
		// 	If cTipTef == TEF_CLISITEF
		// 		LjEnvStPgto(oTef:aRetcartao)
		// 	EndIf
		// EndIf		
	
		If !lTefAbort
			LjGuardaTef(SL1->L1_NUM,aTefBKP)
		EndIf
	
		If !Empty(LOG_TEF)
			LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Venda TEF - ' + If( ValType(lTefOK) == "L", If( lTefOK, 'S', 'N' ), lTefOk ))
		EndIf
	
		If !Valtype(lTefOk ) == "L"
			lTefOk := .F.
		ElseIf !lTefOk
			If cTipTef <> TEF_CLISITEF
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If TEF_lEnvDF()
					If !Empty(LOG_TEF)
						LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Envio Desfazimento TEF')
					EndIf
	
					If LOJA010T("F","D")
	
						If !Empty(LOG_TEF)
							LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Transação TEF não efetuada!')
						EndIf
	
						MsgAlert(STR0047) 	//"Transação TEF não efetuada!"
					EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00") .OR. SuperGetMV("MV_TEFMULT",,.F.)
					If !Empty(LOG_TEF)
						LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Envio Cancelamento TEF - ' + SuperGetMV("MV_TEFVERS") + ' / ' + ;
						       If( GetNewPar("MV_TEFMULT", .F.), 'S', 'N' ))
					EndIf
					If LOJA010T("F","N")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Antigamente esta função nao retornava verdadeiro ou falso ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(LOG_TEF)
							LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Transação TEF não efetuada!')
						EndIf
						If ExistFunc("L010IsAuttar") .AND. L010IsAuttar(L010GetGPAtivo())
							MsgAlert(STR0047 + CTRL + STR0213) 	//"Transação TEF não efetuada!"###"Todas as transações TEF anteriores foram desfeitas!"
						Else
							MsgAlert(STR0047) 	//"Transação TEF não efetuada!"
						EndIf
					EndIf
				EndIf
			EndIf
	
		EndIf
	
		If !lTefOk .AND. !IsBlind()
			If cTipTef == TEF_CLISITEF
		        lAchouSLG := LJVerifSLG()								// Verifica se existe registro na tabela SLG
				If lLOGTEF .AND. lAchouSLG
					If !Empty(SLG->LG_LOGTEF)
						RecLock("SLG",.F.)
						REPLACE SLG->LG_LOGTEF WITH ""
						MsUnLock()
					Endif
				Else
				    cPath  := GetClientDir()
				    If File(cPath + "CLISITEF." + StrZero(oTEF:nIDTermina, 3) )
						FErase( cPath + "CLISITEF." + StrZero(oTEF:nIDTermina, 3) )
					EndIf
				Endif
	        Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ lTefManual -> Foi colocado um parametro para determinar se o cliente utiliza ou nao esta pergunta ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lTEFManual
				If cTipTEF == TEF_DISCADO
					lTEFOk := LJTntTefD(aReb, @lSemRede)
					aRet[1] := lTEFOk
				Else
					aRet[1]	:= .F.
				EndIf
			Else
				If !lTemTEFPend	//somente vem TRUE (nao entrara aqui) quando for SITEF ou CENTRO_PAG
					If lSemRede	//quando a instituicao nao existir no AE_DESC
						aRet[1] := .F.
					Else
						// (lTefAbort) ->  Se estiver hab. TEF manu. e houve cancelamento da operacao TEF na função lj7Pedido,
						//				nao pergunta novamente se continua manual, pois essa pergunta já foi feita na lj7Pedido.
	 					If !lTefAbort
							aRet[1] := LojaOk( STR0198 + Chr(10) + Chr(13) + STR0199,,.T.) 	// STR0198 - "Ocorreu um problema com o ultimo Cartao!!!"  //"Continuar manualmente e passar o Cartao via POS?"
							lTefManual := aRet[1]
							lSelTefManu:= aRet[1]
						Else
							lTefManual := .T.
						EndIf
	
						If lTEFManual
							If ExistBlock("LJ7074")
								aRet[1]	:= ExecBlock( "LJ7074", .F., .F., {} )
								lTEFManual := aRet[1]
							EndIf
	
							If lTEFManual .AND. cTipTef == TEF_CLISITEF
								oTEF:FinalTrn(0)
							EndIf
						ElseIf cTipTEF == TEF_DISCADO
							lTEFOk := LJTntTefD(aReb, @lSemRede)
							aRet[1] := lTEFOk
						EndIf
					EndIf
				Else
					aRet[1] 	:= .F.
					lTefManual 	:= aRet[1]
				EndIf
			EndIf
	
			If !aRet[1]
			   nValSubTot  := Lj7T_Subtotal(2)
			EndIf
	
			If !Empty(LOG_TEF)
				LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Continua Manualmente - ' + If( aRet[1], 'S', 'N' ))
			EndIf
		EndIf
	Else
		// Caso não esteja configurado o TEF, sempre irá exibir a tela para digitação do NSU nas vendas em CC e CD.
		lTefManual := .T.
		lSelTefManu:= .T.
	EndIf

	//-----------------------------------------
	// Processa Transação de Pagamento Digital
	//-----------------------------------------
	If !IsInCallStack("Lj7Pedido") .AND. !( !Empty(SL1->L1_ORCRES) .AND. nOpc == 4 )

		If aRet[1] .And. ExistFunc("LjPgtoDig") .And. !IsInCallStack("Lj7Pedido") .And. STWChkTef("PD")
			LjGrvLog(SL1->L1_NUM,"Processa Transação de Pagamento Digital - Inicio", ) 

			lPagDigOk := LjPgtoDig(@lTemPagDig,@aPagDig)

			LjGrvLog(SL1->L1_NUM,"Após Transação de Pagamento Digital - Status", lPagDigOk) 

			If lTemPagDig
				aRet[1] := lPagDigOk
				lRet 	:= lPagDigOk
			EndIf

		ElseIf aScan(aPgtos,{|x|,Alltrim(x[3]) $ "PD|PX" }) > 0

			Help(" ", 1,STR0227 , , STR0228 + CHR(13)+CHR(10) + STR0229 , 1, 0) // "Pagamentos Digitais" - "Configuração dos Pagamentos Digitais não efetuada corretamente." "Verifique com o administrador do sistema e refaça a venda, ou escolha outra forma de pagamento."
			
			LjGrvLog(SL1->L1_NUM," Transação de Pagamento Digital - Type -> oTef"				, ValType(oTef) ) 				
			LjGrvLog(SL1->L1_NUM," Transação de Pagamento Digital - aRet[1]"					, aRet[1] )						
			LjGrvLog(SL1->L1_NUM," Transação de Pagamento Digital - ExistFunc -> LjPgtoDig"		, ExistFunc("LjPgtoDig") )		
			LjGrvLog(SL1->L1_NUM," Transação de Pagamento Digital - STWChkTef -> PD "			, STWChkTef("PD") )				
			LjGrvLog(SL1->L1_NUM," Transação de Pagamento Digital - IsInCallStac -> Lj7Pedido "	, IsInCallStack("Lj7Pedido") )

			lPagDigOk := .F.	
			lRet := .F.	
			aRet[1] := .F.
		EndIf

	EndIf		

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o recalculo das tributacoes da venda nas seguintes situacoes:     ³
//³1. Caixa nao tem acesso para usar TEF									           ³
//³2. Sucesso na transacao TEF												           ³
//³3. Forma de pagamento dIferente de cartao de credito                      |
//³4. Pagamento em cartao e estacao nao utiliza TEF	- BOPS 147684			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !lUsaTef .OR. lTefOk .OR. !lCartao .OR. lTefManual .OR. ( lCartao .AND. cTipTef == TEF_NAO_USADO ) ) .AND. ( !lTemPagDig .Or. (lTemPagDig .And. lPagDigOk) )
	If !lRecebe .AND. lRecTrib 
		If cPaisLoc == "BRA"
		    nFreDesSeg := Lj7CalcFrete()
	
			//Quando existir RESERVA com RETIRA manda o valor nValRes
			nValRes := IIf ( !lJob .AND. !lMVLjPdvPa .AND. nFatorRes < 1,( Lj7T_Total(2) - nFreDesSeg ) * nFatorRes, nValRes )
	
			//Ajusta o Valor de (Frete+Seguro+Despesa) para nao gerar valor de frete para itens de "Retira" quando existir itens de "Entrega Junto" na mesma venda
			//Pois o valor de frete somente deve estar no item de "Entrega" e nao no item de "Retira"
			If nModulo == 12 .And. !lMVLJPDVPA .And. IsInCallStack("LJ7PEDIDO") .And. IsInCallStack("LOJA701") //Verifica se esta executando a finalizacao de Venda pelo Venda Assistida On-Line
				nFreDesSeg := Lj7CalcFrete(.T.,If(MaFisFound("NF"),MaFisRet(,"NF_VALSOL")>0,.F.))
			EndIf
	
			Lj7RecTrib(	@aVlrAcres	, nDescOrc   	, nFreDesSeg , cLQFrete	 ,;
						lJob		, lEmiteNf   	, nVlrAcrsFi , @aAcrFin	 ,;
						nValRes		, nDescontFi	, nOpc       , aTaxJuros ,;
						nTotICM		, aDadosCNeg	, @nTotImpNCM	, @nTotVLRNCM,;
						@nTotImpFED	, @nTotImpEST	, @nTotImpMUN, nTipo)
	
			//Percorre todos os itens da Venda
			If (lEmitNFCe .Or. lIsPafNfce) .And. !lEmiteNF
				nX := 1
				While MaFisFound("IT", nX)
					If !MaFisRet(nX, "IT_DELETED")
						
						cItemFis := MaFisRet(nX, "IT_ITEM")

						aNFCeICMST := Array(2)
						aNFCeICMST[1] := cItemFis
						aNFCeICMST[2] := {}
	
						Aadd( aNFCeICMST[2], MaFisRet(nX, "IT_MARGEM") )
						Aadd( aNFCeICMST[2], MaFisRet(nX, "IT_PREDST") )
						Aadd( aNFCeICMST[2], MaFisRet(nX, "IT_BASESOL"))
						Aadd( aNFCeICMST[2], MaFisRet(nX, "IT_ALIQSOL"))
						Aadd( aNFCeICMST[2], MaFisRet(nX, "IT_VALSOL") )
						Aadd( aNFCeICMST[2], MaFisRet(nX, "IT_VALFECP"))
	
						//alimenta o array estatico (aICMSST) do LOJNFCE.PRW
						If ExistFunc("LjSetICMST")
							LjSetICMST( aNFCeICMST )
						EndIf

						Aadd( aRefFiscal, {cItemFis, "IT_BFCANTS", MaFisRet(nX, "IT_BFCANTS")})
						Aadd( aRefFiscal, {cItemFis, "IT_PFCANTS", MaFisRet(nX, "IT_PFCANTS")})
						Aadd( aRefFiscal, {cItemFis, "IT_VFCANTS", MaFisRet(nX, "IT_VFCANTS")})
					EndIf
	
					nX++
				End

				If ExistFunc("LjSetRefFis")
					LjSetRefFis( aRefFiscal )
				EndIf
			EndIf
		Else
			Lj7LocTrib(	aTaxJuros )
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava o Log de Recuperacao, caso esteja habilitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLog1 .AND. lLog4 .AND. nHandle >= 0
	nSize 		:= FSeek( nHandle, 0, 2 )
	cRBuffer 	:= Space( nSize )

	FSeek( nHandle, 0, 0 )
	FRead( nHandle, @cRBuffer, nSize )

	cRBuffer := Encript( cRBuffer, 1 )
	If !("#TEF" $ cRBuffer)
		If lTefOk
			cRBuffer := cRBuffer + "#TEFS#"
		Else
			cRBuffer := cRBuffer + "#TEFN#"
		EndIf
	EndIf

	FSeek( nHandle, 0, 0 )
	FWrite( nHandle, Encript( cRBuffer, 0 ) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a Impressao do Cheque. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(LjGetStation("IMPCHQ")) .AND. !Empty(LjGetStation("PORTCHQ"))
	LJ7ImpCH(@aImpCheque)
EndIf

If !lRecebe
	If lMVLJPDVPA
		lTemImpressao	:= .F.
		aAreaSL2		:= SL2->(GetArea())

		DbSelectArea("SL2")
		SL2->( DbSetOrder(1) )	//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
		If SL2->( DbSeek(xFilial("SL2")+SL1->L1_NUM) )
			While !EOF() .AND. (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM) .AND. lLoop
				If (Empty(SL2->L2_ENTREGA) .OR. (SL2->L2_ENTREGA == "2"))
					If !lGE .OR. ( lGE .AND. (!lMvLjImpGf .OR. (lMvLjImpGf .AND. !LjItGE(SL2->L2_PRODUTO))) )
						lTemImpressao := .T.
					EndIf
				EndIf

				If lMVLJPRDSV //Tratamento especifico para RPS - Venda de Produto x Servicos
					If LjIsTesISS(SL1->L1_NUM,SL2->L2_TES) //Item de "servico"
						nVlrServic += SL2->L2_VLRITEM //Acumula o valor dos itens de "servico"
					EndIf
				Else
					If lTemImpressao
						lLoop := .F.
					EndIf
				EndIf
				SL2->( DbSkip() )
			End
			RestArea(aAreaSL2)
		EndIf
	ElseIf lMVLJPRDSV
		aAreaSL2 := SL2->(GetArea())
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))
		If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
			While SL2->(!EOF()) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM
				If LjIsTesISS(SL1->L1_NUM,SL2->L2_TES) //Item de "servico"
					nVlrServic += SL2->L2_VLRITEM //Acumula o valor dos itens de "servico"
				EndIf
				SL2->(DbSkip())
			End
		EndIf
		RestArea(aAreaSL2)
	EndIf

	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa L1_TIPODES para não recalcular desconto na retaguarda LJGRVBATCH	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lImpReserva .AND. ( !Empty(SL1->L1_TIPODES) .OR. (SL1->L1_TIPODES == "1"))
		RecLock("SL1",.F.)
		REPLACE SL1->L1_TIPODES WITH ""
		SL1->(MsUnLock())
    EndIf


	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando ExecAuto e informou Doc/Serie  na chamada do Loja701, mantem os valores recebidos, ³
	//³se apenas NFC-e, gera Doc antes de transmitir com controle de transacao				     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAutoExec .OR. ( ((lEmitNFCe .Or. lIsPafNfce) .And. (!lEmiteNF .OR. nVlrServic > 0 ) ) .OR. (lEmiteNF .AND. lIsVendaVP) )

		If aRet[1]
			//Numeracao da serie, quando ExecAuto pode receber conteudo
			If Empty(M->LQ_SERIE)
				If (lEmitNFCe .OR. lEmiteNF) .AND. lIsVendaVP .AND. SLG->(FieldPos("LG_SERNFIS")) > 0 
					// Venda Vale em estacao NFC-e presente pega série do campo LG_SERNFIS
					cSerie	:= LjGetStation("LG_SERNFIS") 
				Else
					cSerie	:= Padr(LjGetStation("LG_SERIE"),TamSx3("LG_SERIE")[1])
				EndIf	
			Else
				cSerie	:= M->LQ_SERIE
			EndIf

			//Controle sequencial da Nota, quando ExecAuto pode receber conteudo
			If !Empty(M->LQ_DOC)
				cDoc := M->LQ_DOC
			Else
				//Trata quando RPS e Nfc-e
				lTemItProd := .F.
				lTemItServ := .F.
				If (lEmitNFCe .Or. lIsPafNfce) .And. nVlrServic > 0
					LjCheckRPS(SL1->L1_NUM, @lTemItProd, @lTemItServ)
					If lTemItServ .And. !lTemItProd
						aNotaRPS := LjSerNfRPS(lFtvdVer12)
						If aNotaRPS[1]
							cNumCupom := aNotaRPS[2][1]
							cNfRPS	  := aNotaRPS[2][1]
							cSerRPS	  := aNotaRPS[2][2]
						EndIf
					EndIf
				EndIf
				lOnlyServ := lTemItServ .And. !lTemItProd .And. !Empty(cSerRPS)	//Se a variavel "cSerRPS" nao esta vazia eh pq a venda possui apenas itens de "servico"

				//Se for ambiente NFC-e, porém vendendo somente Serviço ou Vale Presente (qualquer comprovante nao-fiscal),
				//não se  deve obter a numeração do SX5, para que nao haja lacunas na numeração da nota
				If (lEmitNFCe .Or. lIsPafNfce) .AND. (lOnlyServ .OR. lIsVendaVP)
					cDoc := cNumCupom
				Else
					LjxDNota(cSerie,3,.F.,1,@aNotas,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,SL1->L1_NUM)
					
					If Len(aNotas) > 0
						cDoc := aNotas[1][2]										
					EndIf
				EndIf
			EndIf
			
			If (!lEmitNFCe .AND. Empty(cDoc)) .OR. ( lEmitNFCe .AND. Empty(cSerie) )//Se cDoc vazio, nao encontrou serie na SX5 para gerar sequencial de documento
				// Se regime NFC-e pega a serie nao fiscal do campo LG_SERNFIS do cadastro de estacao
				If lEmitNFCe
					aRet := { .F. , " ", STR0214 + CHR(13)+CHR(10) + STR0215 + CHR(13)+CHR(10) + STR0216 } //"Falha ao buscar a série do Documento" + "Verifique o preenchimento do campo 'Serie não Fiscal' no cadastro de estação (LG_SERNFIS)" + "Procure por :'Como configurar uma série para documentos não-fiscais para NFC-e' no TDN"
				Else
					aRet := { .F. , " ", STR0214 } //"Falha ao buscar a série do Documento"
				EndIf
			Else
				If Empty(M->LQ_PDV)
					cPdv := LjGetStation("LG_PDV")
				Else
					If lUseSat .AND. (cPdv <> M->LQ_PDV)							//Somente se for SAT, e retransmissão em outro PDV
						cPdv := LjGetStation("LG_PDV")
						cSerie := ""
						M->LQ_SERIE := ""											//Necessário para configurar a série correspondente ao PDV corrente
					Else
						cPdv := M->LQ_PDV
					EndIf
				EndIf
	
				//Quando não possui, gera numero da Nota(NFC-e) - Quando integracao via ExecAuto com PDV de terceiros, serie/nota pode estar preenchido
				If Empty(cSerie)
					cSerie	:= LjGetStation("LG_SERIE")
				EndIf
	
				aRet := { .T. , {cDoc,cPdv},'' }
			EndIf
		EndIf
	EndIf

	If lFiscal .AND. !lEmiteNF .OR. ((lEmitNFCe .Or. lIsPafNfce) .And. !lEmiteNF .AND. !lAutoExec)

		If !lEmitNFCe .And. !lIsPafNfce
			If cPaisLoc == "ARG"
			    nRet := Lj7PegCupArg(nHdlECF, @cNumCupom)
			Else
				nRet := IfPegCupom(nHdlECF, @cNumCupom)
			EndIf

		 	If !Lj7VerCmd( nRet ) .AND. lVAssConc
		       aRet[1]  := .F.
			   aRet[2]  := " "
			   aRet[3]  := STR0110   //"Falha em pegar o numero do Cupom"
		    EndIf

		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³Para venda concomitante, ja pegou o numero do cupom na inclusao ³
		    //³do primeiro item da venda									   ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVAssConc .And. !lIsVendaVP .And. !lIsRecarCP
	            cNumCupom := PadR( StrZero(Val(cNumCupom),Len(cNumCupom)) , TamSx3("L1_DOC")[1] )
	 		Else
	            cNumCupom := PadR( StrZero(Val(cNumCupom)+1,Len(cNumCupom)) , TamSx3("L1_DOC")[1] )
			EndIf

		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³ Pega o numero do PDV                                         ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    nRet := IfPegPDV( nHdlECF, @cNumPdv )
		    If !Lj7VerCmd( nRet )
		       aRet[1]  := .F.
			   aRet[2]  := " "
			   aRet[3]  := STR0072   //"Falha em pegar o numero do PDV"
		    EndIf

			If cPaisLoc <> "ARG"
			   cSerie   := Padr(LjGetStation("LG_SERIE"),TamSx3("LG_SERIE")[1])
			Else
			   cSerie   := Lj7SerArg()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica Se o Cupom Ja Foi Processado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF2->( DbSetOrder(1) )	//F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
			If SF2->( DbSeek(xFilial("SF2")+cNumCupom+cSerie) )
				aRet[1] := .F.
				aRet[2] := " "
				aRet[3] := STR0044 +SL1->L1_NUM+Chr(10)+ STR0045 +SL1->L1_DOC+SL1->L1_SERIE       //"Orcamento: " "DOC e SERIE ja existente no SF2: "
			EndIf
		EndIf

		If lEmitNFCe .Or. lIsPafNfce .OR. !SF2->(Found())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a impressao do cupom fiscal                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc <> "ARG"

				If !lMVTELAFIN .AND. aRet[1] .AND. ( (cTipTef == TEF_CLISITEF .AND. lTefOk) .OR. ( aScan(aPgtos,{|x|,Alltrim(x[3]) $ "PD|PX" }) > 0 .AND. lPagDigOk ) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ soh chamara a LJVERADM se for forma TEF. Antes a forma CH, que nao eh
					//  forma TEF , entraria na funcao por causa da habilitacao do TELECHEQUE ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aScan(aPgtos,{|x|,Alltrim(x[3]) $ _FORMATEF }) > 0
						aRet[1] := LJVERADM( @lSemRede, lTefOk, lTefManual, NIL , lSelTefManu )
					EndIf

					If !aRet[1] .AND. !( lSelTefManu .AND. lPagDigOk)
						lTefOK 	:= .F.
						lTemTEFPend := .T.
					ElseIf  lSelTefManu .AND. lPagDigOk
						aRet[1] := .T.
					EndIf
				EndIf

				If aRet[1] .AND. lTemImpressao

                    //Tratamento para impressão do termo de garantia estendida
					Lj7ImpGe(@nVlrGar,@nFatorGar,@aProdGar,@nValRes,@nFatorVen,@nFatorRes,lImpReserva,lMvLjImpGf,cMvLjTGar,lVAssConc,lEmiteNF)
					
					If lMVLJPRDSV .And. nVlrServic > 0

						nFatorServ 	:= nVlrServic / SL1->L1_VLRLIQ 	//Calcula fator (Itens de Servico)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Faz a impressao do Cupom Nao fiscal - CNF (comprovante da venda de servico) no Caso de Itens de Servico	 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						LjMsgRun( STR0013,, {|| Lj7ImpCNF( lTefOk, nFatorServ, Nil, Nil,;
															Nil  , Nil		 , 2 ) } )    //"Aguarde ... imprimindo o comprovante de venda ...."

					ElseIf lIsVendaVP //Verifica se eh venda de Vale Presente

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Faz a impressao do Cupom Nao fiscal - CNF (comprovante da venda de Vale Presente) no Caso de Venda de Vale Presente	³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						/*
							Somente retornamos o NUMERO e SERIE para uso do Vale Presente quando for NFC-e,
							caso contrario, sera usado o COO retornado do ECF
						*/
						If lEmitNFCe .Or. lIsPafNfce
							LjMsgRun( STR0013,, {|| aRet := Lj7ImpCNF( lTefOk	, 1		, Nil	, Nil	,;
																		Nil 	, Nil	, 3 	) } )
						Else
							LjMsgRun( STR0013,, {|| Lj7ImpCNF( lTefOk	, 1		, Nil	, Nil	,;
																Nil 	, Nil	, 3 	) } )	//"Aguarde ... imprimindo o comprovante de venda ...."
						EndIf

					ElseIf lIsRecarCP //Verifica se eh venda de Recarga de Cartao Presente (Gift Card)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Faz a impressao do Cupom Nao fiscal - CNF (comprovante da venda de Recarga de Cartao Presente) no Caso de Recarga de Cartao Presente (Gift Card) ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						LjMsgRun( STR0013,, {|| Lj7ImpCNF( lTefOk, 1, Nil, Nil,;
															Nil  , Nil		 , 4 ) } )    //"Aguarde ... imprimindo o comprovante de venda ...."

					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Trata os valores com reserva ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nValRes > 0 .AND. nVlrGar <= 0
						nFatorVen := Lj7FatRes(nValRes, SL1->L1_VLRLIQ + SL1->L1_DESCONT)[1]
						nFatorRes := Lj7FatRes(nValRes, SL1->L1_VLRLIQ + SL1->L1_DESCONT)[2]
					EndIf

					If !lEmitNFCe .And. !lIsPafNfce
						While .T.
 							If Len(aPafNotaCF) > 0
								cNumNotaCF := aPafNotaCF[2][2]
							Else
								cNumNotaCF := ""
							EndIf

							LjMsgRun( STR0012,, {|| (aRet := Lj7ImpCF(	lTefOk    	, cNumCupom	, cNumPdv		, cMsgResg	,;
																			aVlrAcres 	, cLQFrete  , nVlrAcrsFi	, lCartao	,;
																			@aSitTrib	, nFatorRes , nFatorVen 	, aTaxJuros ,;
																			@cNfRPS 	, @cSerRPS  , nVlrGar ,nTotImpNCM	,;
																			nTotVLRNCM	, nTotImpFED,	nTotImpEST, nTotImpMUN ,;
																			cNumNotaCF ) ) } ) 	//"Aguarde ... Imprimindo o cupom fiscal ...."

							lOnlyServ := !Empty(cSerRPS)	//Se a variavel "cSerRPS" nao esta vazia eh pq a venda possui apenas itens de "servico"

							lErroCF := !aRet[1]

							If lErroCF
								If !Empty(aRet[3])			// ""Atencao!" ### "Tentar imprimir novamente?" ### "&Sim" "&Não" ### "Impressora não responde!"
									cMsg := aRet[3] + CTRL + STR0050
								Else
									cMsg  := STR0050
								EndIf

								If Aviso(STR0031,cMsg,{STR0051,STR0052},,STR0049) == 1 // ""Atencao!" ### "Sim" ### "Nao" ### "Impressora nao responde!"
									Loop
								EndIf
							Else
								lCupFiscal := .T.
							EndIf
							Exit
						End

					EndIf

                    // Tratamento para garantia estendida com impressoa de comprovante nao fiscal
					If lGE  .AND. lVAssConc .AND. nFatorGar > 0 .AND. Len(aProdGar) > 0
						// Imprimira o comprovante nao fiscal somente apos terminar o cupom fiscal , com
						// venda concomitante
						LjMsgRun( STR0013,, {|| Lj7ImpCNF( Nil, nFatorGar , Nil, 	Nil,;
															Nil  , Nil		 , 1   , aProdGar ) } )    //"Aguarde ... imprimindo o comprovante de venda ...."
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Relatorio Gerencial ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If HasTemplate("OTC") .AND. lRelatGere

						If !Empty( M->LQ_NROPCLI)    // Verifica se a OS esta nula
							DbSelectArea("SB1")
							SB1->( DbSetOrder(1) )

							For nCount := 1 To Len(aCols)
								cOs := Stuff(ALLTRIM(M->LQ_NROPCLI),7,2,"") + StrZero(aCols[nCount][nPosConju],2)  // Ordem  de Servico

								If SB1->( DbSeek(xFilial("SB1") + aCols[nCount][2]) )
									If SB1->B1_TIPO $ cTiposProd .AND. aCols[nCount][nPosVenAvu] <> "1"
										Aadd( aRelatGere, aCols[nCount] )		// Array do Kit
										If nCount +1 > Len(aCols) .OR. aCols[nCount][nPosConju] != aCols[nCount + 1][nPosConju] // Quebra os Kits do Relatorio Gerencial
											Lj7ImpRg(nHandle,aRelatGere,cOs)	// Imprime o Relatorio Gerencial
											aRelatGere := {}
										EndIf
									EndIf
								EndIf

				 			Next nCount

						EndIf

					EndIf

				EndIf
	    	Else
				If aRet[1]
					LjMsgRun( STR0012,, {|| (aRet := Lj7ImpCFArg(aTaxJuros,aDadosCF)) } ) //"Aguarde ... imprimindo o cupom fiscal ...."
				 	lErroCF := !aRet[1]
					If lErroCF .AND. cPaisLoc == "ARG"
						cDoc := aRet[2][1]
						cPdv := aRet[2][2]
				   	EndIf
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna o Contador de Cupom Fiscal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!lEmitNFCe .AND. lCupFiscal) .Or. lIsPafNfce
			nRet := IFStatus(nHdlECF, "35", @cContDoc)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Não possui emissão de Cupom Fiscal mas precisa guardar o PDV onde finalizou o orçamento  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lMVLJPDVPA .AND. !lTemImpressao)
			aRet[2] := {"",cNumPdv}
		EndIf
	//Tratamento especifico para impressão de comprovante de Vale Presente com Documento de Saida "NOTA"
	ElseIf !lAutoExec .AND. lFiscal .AND. lIsVendaVP .AND. lEmiteNF .AND. aRet[1] .AND. lTemImpressao .AND. lEmitNFCe .AND. !lIsPafNfce
		LjMsgRun( STR0013,, {|| Lj7ImpCNF( lTefOk	, 1		, Nil	, Nil	,	Nil 	, Nil	, 3 	) } )
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza o(s) Recebimento Nao-Fiscal e a Autenticacao do(s) documento(s) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!lUsaTef) .OR. (lUsaTef .AND. !lCartao) .OR. ;
		(lUsaTef .AND. lCartao .AND. ( lTefOk .OR. lTefManual ) )

		For nI := 1 To Len(aTitulo)

			If !File( cGetCliDir+"SIGALOJA.INI" )
				WritePProString("Recebimento Titulos", "Totalizadores", "01", cGetCliDir+"SIGALOJA.INI")
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³VerIfica se existe o PE Lj7019, atraves do qual podera ser realizada³
			//³a impressão de um comprovante de pagamento do título.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLj7019 .AND. !lFtvdVer12
				xRet := ExecBlock( "LJ7019",.F.,.F.,{cTotRecNFis, aTitulo[nI][10], &(SuperGetMV("MV_NATRECE")), nI} )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso ocorra algum problema na impressão do comprovante o PE   ³
				//³poderá retornar .F. e a gravação do recebimento será abortada.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(xRet) == "L"
					lRet := xRet
				EndIf
			EndIf

			If lFTVD7019 .AND. lFtvdVer12
				xRet := ExecBlock( "FTVD7019",.F.,.F.,{cTotRecNFis, aTitulo[nI][10], &(SuperGetMV("MV_NATRECE")), nI} )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso ocorra algum problema na impressão do comprovante o PE   ³
				//³poderá retornar .F. e a gravação do recebimento será abortada.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(xRet) == "L"
					lRet := xRet
				EndIf
			EndIf
		Next nI
	EndIf
EndIf
//Tratamento para impressão do recibo não-fiscal e do termo de garantia estendida 
If !lImpReserva .And. lEmiteNF
	Lj7ImpGe(@nVlrGar,@nFatorGar,@aProdGar,@nValRes,@nFatorVen,@nFatorRes,lImpReserva,lMvLjImpGf,cMvLjTGar,lVAssConc,lEmiteNF)
EndIf 

LjGrvLog(SL1->L1_NUM,"MEIO DA GRAVACAO DA VENDA")
If aRet[1]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a gravacao dos dados (SL1, SL2 e SL4) #DADOSOK#³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRecebe
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando for recebimento via transacao TEF a gravacao so   ³
		//³ podera ser feita se a transacao foi efetuada com sucesso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUsaTef .AND. lCartao
			If lTefOk .OR. lTefManual
				LJGrvRec(aPgtos,,,,,,aTitulo,,,lSelTefManu,lTefManual,aPagDig)
			Else
				//"Transação Tef não concluída. Não será possível efetuar o Recebimento!"
				//"Atencao!"
				MsgStop(STR0075, STR0031)
			EndIf
		Else
			If LJAnalisaLeg(35)[1]
				dbSelectArea("SFI")
				SFI->(dbSetOrder(1))
				If !SFI->(dbSeek(xFilial("SFI") + DtoS(dDatabase) + LJGetStation("PDV")))
					LJGrvRec(aPgtos,,,,,,aTitulo,,,lSelTefManu,lTefManual,aPagDig)
				Else
					LJMsgLeg(LjAnalisaLeg(35))
				EndIf
			Else
				LJGrvRec(aPgtos,,,,,LJ7T_Troco(2),aTitulo,,,lSelTefManu,lTefManual,aPagDig)
			EndIf
		EndIf
		lRet := .T.
	Else
	
		LjGrvLog(SL1->L1_NUM,"GRAVACAO DO DOC DA VENDA",aRet)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Checa o numero do COO, do PDV e da Serie                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. lFiscal)

			//ÚÄÄÄÄÄ¿
			//³Cupom³
			//ÀÄÄÄÄÄÙ
		    If !lEmiteNF .AND. lTemImpressao .AND. !lFtvdVer12
				cDoc 	:= aRet[2][1]
				cPdv	:= aRet[2][2]
				If cPaisLoc <> "ARG"
					If lOnlyServ //A venda possui apenas itens de "servico"
						//Considera a serie da NF de Servico (RPS), pois a venda possui apenas itens de "servico"
						cSerie  := cSerRPS
						lNumcFis := .F.
					ElseIf (lEmitNFCe .Or. lIsPafNfce) .AND. lIsVendaVP
					   	cSerie := aRet[2][3]
					Else
					   	If lIntegDef //Integracao mantem a Serie informada
					   		cSerie := M->LQ_SERIE
					   	Else
					   		cSerie := LjGetStation("LG_SERIE")
					   	EndIf
				   	EndIf
				Else
				   cSerie   := Lj7SerArg()
				EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nota - A numeracao da Nota/Serie sera atribuida pela funcao LJGRVTUDO()³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf !lFtvdVer12 .AND. ( (!lEmitNFCe .And. !lIsPafNfce) .Or. ((lEmitNFCe .Or. lIsPafNfce) .And. lEmiteNF))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Salva PDV para sinalizar que orcamento foi importado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMVLJPDVPA
					cPdv	:= aRet[2][2]
				Else
				    cPdv    := ""
				EndIf
			    If !lIsVendaVP //Se for venda Vale Presente a cSerie já estará preenchida pelo LG_SERNFIS.
					cDoc    := ""
					cSerie  := ""
				Endif	
			ElseIf lFtvdVer12
				If cPaisLoc <> "ARG"
					If !lIntegDef //Integracao mantem dados informados no XML
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Nota - A numeracao da Nota/Serie sera atribuida pela funcao LJGRVTUDO()³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cPdv    := ""
						cDoc    := ""
						cSerie  := ""
					EndIf
				Else
					cSerie := Lj7SerArg()
				EndIf
			EndIf
		Else
			If cPaisLoc == "ARG" .AND. !lFiscal
				cSerie := Lj7SerArg()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Controle de Formularios       ³
			//³Obter numero e serie do formulario informado ³
			//³pelo usuario no inicio da venda.             ³
			//³                                             ³
			//³Paises: Chile/Colombia  - F1CHI              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCFolLocR5
				lNumcFis := .F.
				If !Empty(cDocFo) .AND. LjGRecFo() > 0
					cDoc := cDocFo
					nRecnoSFP := LjGRecFo()
   					LjxDadosFo(nRecnoSFP,NIL,NIL,NIL,@cSerie)
				EndIf
			EndIf
		EndIf

		lSelTefManu :=  (lSelTefManu .And. (cPaisLoc == "BRA"))
		
		If lSelTefManu //Nao precisa fazer outras validações pois a variavel só vem .T. caso venda com cartao e Tef Manual
			For nX := 1 To Len(aPgtos)
				If Alltrim(aPgtos[nX][3]) $ _FORMATEF

					// Se existir no aTEFDados, a transacao ja foi CONFIRMADA e sera reutilizada
					If lTEFMult .AND. Type("aTEFDados") == "A" .AND. Len(aTEFDados) > 0 .AND. Len(aTEFDados[1]) >= 20
					
						If aScan( aTEFDados, {|x| x[20]+x[19] == aPgtos[nX][3] + aPgtos[nX][8] } ) > 0	//comparacao entre FORMA + ID
							LjGrvLog( Nil, "Lj7GrvVenda - Transacao TEF reaproveitada", aPgtos[nX][3] + aPgtos[nX][8] )
							loop
						EndIf
					EndIf

					//Soma dos valores enviados para pagamento com cartão para confrontar com o pago no POS
					/*If aPgtos[nX][3] $ "CC|CD"
						nTotCart += aPgtos[nX][2]
					EndIf	*/	
					
					nAux := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID
					
					If nAux > 0
						aNSUVndTef[nAux][3] += aPgtos[nX][2]
					Else
						// Neste ponto, o aPgtos[nX] chega com 15 posições, quando uma venda com cartão selecionado na tela de pagamentos,
						// Com Multi Negociação, o aPgtos[nX] chega com 11 posições e precisa ser redimensionado,
						// pois irá precisar da 15ª para gravar o NSU digitado.
						// As posições acrescentadas no array, foram tiradas dos fontes, seguindo o mesmo padrão de criação do aPgtos,
						// ou seja, as posições adicionadas, contêm o mesmo tipo.
						If Len(aPgtos[nX]) == 11
							Aadd(aPgtos[nX], "")		// Aadd posição 12
							Aadd(aPgtos[nX], {})		// Aadd posição 13			
							Aadd(aPgtos[nX], "")		// Aadd posição 14	
							Aadd(aPgtos[nX], "")		// Aadd posição 15	
						Else
							If !Empty(Alltrim(aPgtos[nX][15]))
								lNSUDigitado := .T.
							EndIf	
						EndIf
						Aadd(aNSUVndTef,{AllTrim(aPgtos[nX][3]),aPgtos[nX][8],aPgtos[nX][2],If(lNSUDigitado,Alltrim(aPgtos[nX][15]),"")}) //Forma , ID , Valor , NSU digitada
					EndIf
				EndIf
			Next nX
			
			If Len(aNSUVndTef) > 0  .AND. !lNSUDigitado 
				For nX := 1 to Len(aNSUVndTef)
					LjGrvLog(Nil, "Lj7GrvVenda - Chamada da Tela para Digitação da NSU - TEF Manual")
					// Se já foi informado o NSU em algum momento, não chama a tela novamente
					LjxTelaNSU(@aNSUVndTef[nX],@aIdPgtoMfe)
					//IMPORTANTE: NAO RETIRAR ESTE TECHO
					//Tratamento para validação do pagamento efetuado no POS
					/*If lMFE
						aRetVldMFE := LjVldPgto(aIdPgtoMfe[nX][1])
						//aRetVldMFE := LjVldPgto(aNSUVndTef[nX][4])
						If Len(aRetVldMFE) > 0
							aNSUVndTef[nX][4] := aRetVldMFE[8][2]	//NSU do pagamento
							aAdd(aNSUVndTef[nX],aRetVldMFE)
							nTotPOS += IIf( !Empty(aRetVldMFE[9][2]), Val(aRetVldMFE[9][2]),0 )
						EndIf	
					EndIf*/	
					LjGrvLog(Nil, "Lj7GrvVenda - Chamada da Tela para Digitação da NSU - Retorno:" , aNSUVndTef)
				Next nX
				//IMPORTANTE: NAO RETIRAR ESTE TECHO
				//Tratamento para efetuar o processo de cancelamento caso o valor do pagamento no POS seja diferente da venda
				/*If lMFE .And. ( nTotPOS <> nTotCart )
					MsgAlert("O valor do pagamento efetuado no POS ("+cValToChar(nTotPOS)+") é diferente do informado para o pagamento em cartão ("+cValTochar(nTotCart)+")." + CHR(10) + CHR(13);
							  +"Favor efetuar o cancelamento no POS e defina os pagamentos novamente.";
							)

					Lj7CancVenda(	"Erro na venda"	, cDoc		, cSerie	, cPdv			,;
									.F.			, lTefOk	, @lExistNF	, @cDescErro	,;
									.T. 		,  Nil		, Nil		, @aTefBKP		,;
									@lTemTEFPend	)

					aIdPgtoMfe := {}				
					Return .F.				
							
				EndIf*/

			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a gravacao do SL1                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aSL1, { "L1_NUM"    ,SL1->L1_NUM } )

		If Len(aPafNotaCF) > 0
			cDoc	:= aPafNotaCF[2][2]
			cSerie	:= SuperGetMV("MV_LJSNCFP",,"61") //Parametro usado somente em homologacao para pegar a série desse Cupom sobre Nota
		Else
			If !Ascan(aSL1, {|x| AllTrim(upper(x[1])) == "L1_PDV"}) > 0
				aAdd( aSL1, { "L1_PDV"    ,cPdv } )
			EndIf	
		EndIf

		aAdd( aSL1, { "L1_DOC"    ,cDoc } )		
		
		If lOnlyServ .AND. lMVLJPRDSV .AND. ( lUseSAT .OR. !lMvNFCeCnj ) .AND. SL1->L1_TPORC == "E"
			//Trata se não está habilitada a funcionalidade de nfce conjugada
			aAdd( aSL1, { "L1_TPORC"    ,"" } )	
			aAdd( aSL1, { "L1_SERSAT"    ,"" } )	
		EndIf
		
		If Len(aNSUVndTef) > 0 //Insere o numero da NSU, caso tenha sido preenchido manualmente
			cNSUVndTef	:= aNSUVndTef[1][4] //pego o primeiro conteudo do array, pois o importante mesmo é o SL4
			If !Empty(AllTrim(cNSUVndTef))
				cL1NSUTEF := cNSUVndTef
								
				aAdd( aSL1, { "L1_VENDTEF", "S"})
				aAdd( aSL1, { "L1_DOCTEF" , cNSUVndTef } )
				aAdd( aSL1, { "L1_NSUTEF" , cL1NSUTEF } )
				aAdd( aSL1, { "L1_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )
			Else
				LjGrvLog(Nil,"Atenção: Tela de NSU foi aberta porem não foi " +;
							 "digitado um numero de transacao. SL1 será gravada sem dados de TEF Manual")
			EndIf
		EndIf
		
		aTimeUf := { dDataBase, Time()}

		If cPaisLoc == "BRA"
			If cHoraRMT == "3" 
				aArea2	:= GetArea()
				dbSelectArea("SM0")
				aAreaSM0	:= GetArea()
				dbSetOrder(1)
				If dbSeek(cEmpAnt+cFilAnt)
					aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
					aTimeUf[1] := StoD(aTimeUf[1])
				EndIf
				RestArea(aAreaSM0)
				RestArea(aArea2)
			ElseIf cHoraRMT == "1" .AND. !IsBlind() 
				aTimeUf := { GetRmtDate(), GetRmtTime()}
			EndIf

		EndIf
		
		//NFCe sofre rejeicao quando direnca de horario, caso tenha transacao TEF, devido a demora no processamento do TEF, pode entrar nessa condicao e ter rejeicao
		If !lEmiteNf 
			If lUseSAT
				aAdd( aSL1, { "L1_HORA", Time() } )
			EndIf
		Else
			aAdd( aSL1, { "L1_HORA", aTimeUf[2] } )
		EndIf
	
		If lIntegDef //Integracao mantem informacoes da integracao
			aAdd(aSL1, {"L1_NUMCFIS", M->LQ_NUMCFIS})		
		ElseIf lNumcFis .And. !lIsVendaVP .And. !lIsRecarCP
			If Len(aPafNotaCF) > 0
				//Devo gravar o numero do cupom fiscal para mostrar no registro do PAF
				aAdd(aSL1 , {"L1_NUMCFIS", cNumCupom})
			Else
				aAdd( aSL1, { "L1_NUMCFIS",cDoc } )
			EndIf
		EndIf
		
		If !(Len(aPafNotaCF) > 0) //Quando Emissao de Nota, não preenche o PDV
			aAdd( aSL1, { "L1_PDV"  ,cPdv } )
		EndIf
		
		If !Empty(M->LQ_SERIE) .AND. (lEmitNFCe .Or. lIsPafNfce .Or. Empty(cSerie))
			cSerie	:= M->LQ_SERIE
		EndIf

		aAdd( aSL1, { "L1_SERIE"  ,cSerie } )
		//Qdo. for PAF-ECF e a venda possui apenas itens de "servico", alimenta o campo L1_DOCRPS e L1_SERRPS com o mesmo conteudo dos campos L1_DOC e L1_SERIE.
		//Desta forma, sera possivel identificar que o numero da Nota/Serie devera ser substituida no processamento do LjGrvBatch na retaguarda.
		If lMVLJPRDSV .And. lMVLJPDVPA .And. lOnlyServ
			aAdd( aSL1, { "L1_DOCRPS"  ,cDoc } )
			aAdd( aSL1, { "L1_SERRPS"  ,cSerie } )
		EndIf
		aAdd( aSL1, { "L1_TIPO"   ,"V" } )
		
		If lIntegDef //Integracao mantem operador informado
			aAdd( aSL1, { "L1_OPERADO", M->LQ_OPERADO } )
		Else
			If !Ascan(aSL1, {|x| AllTrim(upper(x[1])) == "L1_OPERADO"}) > 0
				aAdd( aSL1, { "L1_OPERADO",xNumCaixa() } )
			EndIf	
		Endif

		If !Empty(M->LQ_EMISNF) .AND. (lEmitNFCe .Or. lIsPafNfce) .AND. !lEmiteNf
			aAdd( aSL1, { "L1_EMISNF", 		M->LQ_EMISNF } )
		ElseIf nTipo <> 1
			aAdd( aSL1, { "L1_EMISNF", 		aTimeUf[1] } )

		EndIf

		aAdd( aSL1, { "L1_LOJA" ,SL1->L1_LOJA } )
		aAdd( aSL1, { "L1_CONTDOC", cContDoc} )

		/*	Caso seja PDV PAF ou Estado de SP/SC(Joinville) ou trabalhe
			com a NF Paulista ou Venda NFC-egrava o CGC no campo L1_CGCCLI
			ou se tem o parametro MV_LJDCCLI configurado para digitar o CPF/CNPJ
		*/
		If Type("M->LQ_CGCCLI") <> "U" .AND. (LJ7DImpCpf() .Or. lMVLJPDVPA .OR. lEmitNFCe .Or. lIsPafNfce .OR. lEmiteNF )
			Aadd(aSL1,{ "L1_CGCCLI" , IIf(!Empty(M->LQ_CGCCLI) .OR. lUseSat ,M->LQ_CGCCLI ,SA1->A1_CGC) } )
		EndIf
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se Existir o Campo L1_NumMov,Grava o Numero do Ultimo Movimento do SLW ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL1->(ColumnPos("L1_NUMMOV")) > 0
			AAdd( aSL1, { "L1_NUMMOV", LJNumMov()} )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento dos campos de transferencia de portador e ³
		//³carteira automatico (FRA)                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL1->(ColumnPos("L1_TRCXGER")) > 0 .AND. !lFtvdVer12
			If lUsaFecha .AND. lUsaTransf
				aAdd(aSL1,{"L1_TRCXGER",.T.})
			Else
				aAdd(aSL1,{"L1_TRCXGER",.F.})
			EndIf
		EndIf
		If SL1->(ColumnPos("L1_TREFETI")) > 0 .AND. !lFtvdVer12
			aAdd(aSL1,{"L1_TREFETI",.F.})
		EndIf

		/*Tratamento colocado para que seja apagado as informacoes quando
		orcamento reaprovatado (cancelada no LOJA140) com TEF*/
		aAdd( aSL1, { "L1_DOCCANC" , ""	} )
		aAdd( aSL1, { "L1_DATCANC" , ""	} )
		aAdd( aSL1, { "L1_HORCANC" , ""	} )		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os campos L1_EMISSAO e L1_EMISNF     ³
		//³se a database do sistema for dIferente da data³
		//³cronologica da impressora                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lEmitNFCe .And. !lIsPafNfce .AND. lFiscal .AND. lTemImpressao
			nRet := IfStatus( nHdlECF, '2', @cRetorno )
			If nRet == 0 .AND. (CtoD(cRetorno) <> dDataBase) .OR. (SL1->L1_EMISSAO < dDataBase )
				LjGrvLog(Nil, "Lj7GrvVenda - ALTEROU L1_EMISSAO DE ", SL1->L1_EMISSAO)
				LjGrvLog(Nil, "Lj7GrvVenda - ALTEROU L1_EMISSAO PARA ", dDataBase)
				aAdd( aSL1, { "L1_EMISSAO" ,dDataBase } )
				aAdd( aSL1, { "L1_EMISNF" ,dDataBase } )
		    	lAterSl2 := .T.
		    EndIf
		EndIf

		If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. lFiscal)
		    If (lEmiteNF .AND. lTemImpressao) .Or. (Len(aPafNotaCF)> 0 .And. aPafNotaCF[1][1] == "S") 
				//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ emite NF  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd( aSL1, { "L1_IMPRIME","2S" } ) // 1-Cupom | 2-Nota | 3-Cupom de Venda | 4-Nao Imprimir | 5-Cupom Eletronico(NFCe)
		    ElseIf lEmitNFCe .Or. lIsPafNfce
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ emite NFCe  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd( aSL1, { "L1_IMPRIME","5S" } ) // 1-Cupom | 2-Nota | 3-Cupom de Venda | 4-Nao Imprimir | 5-Cupom Eletronico(NFCe)
		    Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ emite cupom  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd( aSL1, { "L1_IMPRIME","1S" } ) // 1-Cupom | 2-Nota | 3-Cupom de Venda | 4-Nao Imprimir | 5-Cupom Eletronico(NFCe)
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 Chile/ Colombia.                            ³
			//³Se LjProfile(28) == .T. então grava no campo L1_IMPRIME =³
			//³4S nao imprime.                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LjProFile(28) .AND. cPaisLoc$"CHI|COL"
				aAdd( aSL1, { "L1_IMPRIME","4S" } ) // 1-Cupom | 2-Nota | 3-Cupom de Venda | 4-Nao Imprimir | 5-Cupom Eletronico(NFCe)
		    Else
				aAdd( aSL1, { "L1_IMPRIME","2S" } ) // 1-Cupom | 2-Nota | 3-Cupom de Venda | 4-Nao Imprimir | 5-Cupom Eletronico(NFCe)
			EndIf
		EndIf

	    If CrdXInt()
	       If SL1->(ColumnPos("L1_CONTRA")) > 0
	          aAdd( aSL1, { "L1_CONTRA", cContrato })

	          Conout("31.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	      		   " adiciona CONTRATO no array SL1. " )

	       EndIf

	       If SL1->(ColumnPos("L1_FORCADA")) > 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controlar se a venda foi off-line (1) ou uma venda on-line (2) - WebService³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		      If lForcada
			     aAdd( aSL1, {"L1_FORCADA", Str(FORCADA,1) } )

			     Conout("32.LOJA701C - Lj7GrvVenda - " +;
		     	   " Orcamento: " +  M->LQ_NUM +;
	               " Contrato : " + If (Empty(cContrato), "", cContrato) +;
	      		   " adiciona L1_FORCADA array SL1. " )


			     If SL1->(ColumnPos("L1_CGCCART")) > 0
			        If Empty(aCrdCliente[1]+aCrdCliente[2]) .AND. M->LQ_CLIENTE+M->LQ_LOJA <> cMV_CLIPAD+cMV_LOJAPAD
			           aCrdCliente  := AClone(CrdInfClie(M->LQ_CLIENTE, M->LQ_LOJA))
			        EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava no campo L1_CGCCART o Numero do CGC/CPF ou Numero do Cartao do Cliente, o que tiver sido informado.  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    AADD( aSL1, {"L1_CGCCART", If(!Empty(aCrdCliente[1]), aCrdCliente[1], aCrdCliente[2]) } )

				    	Conout("33.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
 		            	" Cliente+Loja : " + M->LQ_CLIENTE+M->LQ_LOJA +;
	               		" CrdCliente : " + If (Empty(cContrato), "", cContrato) +;
	               		" L1_CGCCART: " +  If(!Empty(aCrdCliente[1]), aCrdCliente[1], aCrdCliente[2])+;
	               		" Preenche aSL1(L1_CGCCART) . " )

			     EndIf
		      Else
	    	        Conout("34.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
		            " Cliente+Loja : " + M->LQ_CLIENTE+M->LQ_LOJA +;
               		" Contrato: " + If (Empty(cContrato), "", cContrato) +;
      		   		" Preenche aSL1(FORCADA)=NAOFORCADA e  aSL1(CGCCART)= " )


			     aAdd( aSL1, {"L1_FORCADA", Str(NAOFORCADA,1) } )
			  EndIf
		   EndIf
        Else
    		Conout("35.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM + "  Sem Integracao com o CRD")
    		// Para imprimir o comprovante de recebimento
    		If (Lj950Acres(SM0->M0_CGC) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA"))
	    		ImpAcrsAux()
	    	Endif
	    EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizando os valores totais da venda, % em juros e CC      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If lMvLjJurCC .AND. (Len(aTaxJuros) > 0)
			If cPaisLoc == "BRA"
				aAdd( aSL1, {"L1_JUROS"		, aTaxJuros[1] + SL1->L1_JUROS } )
			EndIf
	    	aAdd( aSL1, {"L1_CARTAO"	, aTaxJuros[2] + SL1->L1_CARTAO } )

	    	aTaxJuros := {0,0,0,0}
	    EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizando o valor para doação - Instituto Arredondar       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SLQ->(ColumnPos("LQ_UMOV")) > 0 .AND. SL1->(ColumnPos("L1_UMOV")) > 0
	    	aAdd( aSL1, {"L1_UMOV", M->LQ_UMOV } )
		EndIf

		If SLQ->(ColumnPos("LQ_UMOVINF")) > 0 .AND. SL1->(ColumnPos("L1_UMOVINF")) > 0
	    	aAdd( aSL1, {"L1_UMOVINF", M->LQ_UMOVINF } )
		EndIf

		If cPaisLoc == "ARG" .And. SL1->(ColumnPos("L1_ADIC5")) > 0 .And. SLQ->(ColumnPos("LQ_ADIC5")) > 0
			aAdd( aSL1, {"L1_ADIC5", M->LQ_ADIC5 } )
		EndIf

		//Aqui inclui no array aSL1, para pegar posição e zerar o campo L1_CREDITO, após a validação e impressão da NF
		If SL1->L1_CREDITO > 0
			aAdd( aSL1, {"L1_CREDITO", SL1->L1_CREDITO } )		
		Endif	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a gravacao do SL2                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))
		SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))
		nRecnoSL2  := Recno()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valor para dar baixa no Lay-Away  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOutros    := SL1->L1_OUTROS
		While !SL2->(EOF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM

			aSL2 := {}
			If nPosStTrib > 0 .AND. Len(aSitTrib) > 0
				nPos := aScan( aSitTrib,{|x| x[1]== SL2->L2_ITEM+SL2->L2_PRODUTO })
				If nPos > 0
					Lj7AjustSt(@aSitTrib[nPos][2])
					aAdd( aSL2, { "L2_SITTRIB",aSitTrib[nPos][2]} )
				EndIf
            EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados da SL2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj7GeraSL( "SL2", aSL2 )

			aSL2 := {}
			aAdd( aSL2, { "L2_VENDIDO", 	"S" } )	// Gravar como "S" somente quando !Empty(L1_DOC)
			If lUseSAT
				aAdd( aSL2, { "L2_DOC",  "" } )
				aAdd( aSL2, { "L2_ESPECIE",  "SATCE" } )
			Else
				aAdd( aSL2, { "L2_DOC",  		cDoc } )
			EndIf
			aAdd( aSL2, { "L2_SERIE", 		cSerie } )
			
			If Len(aPafNotaCF) > 0
				aAdd( aSL2, { "L2_PDV", 	"" } ) //Homologacao 2017 PAF-ECF -> Gravo em branco pois o L1,F2 e D2 estão sem o PDV
			Else
				aAdd( aSL2, { "L2_PDV", 	cPdv } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os campos L2_EMISSAO e L1_EMISNF     ³
			//³se a database do sistema for dIferente da data³
			//³cronologica da impressora                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAterSl2
				aAdd( aSL2, { "L2_EMISSAO",	dDataBase } )
			EndIf

			If !Empty(SL2->L2_RESERVA) .AND. !lMVLJPDVPA
				aAdd( aReservas, { SL2->L2_RESERVA, SL2->L2_PRODUTO, SL2->L2_LOCAL } )
			EndIf

		    If AllTrim(Str(SuperGetMv("MV_LJGERSC",,1))) $ "2|3" .AND. SL2->(ColumnPos("L2_SOLCOM")) > 0
				aAdd( aSL2, { "L2_SOLCOM",	SL2->L2_SOLCOM } )
			Endif


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Cartao fidelidade 			³
			//³Gravacao dos campos especificos para	recarga ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLjcFid .AND. LaFunhProd(SL2->L2_PRODUTO)
			 	aAdd( aSL2, { "L2_PRODUTO", 	SL2->L2_PRODUTO } )
				aAdd( aSL2, { "L2_NUMCFID", 	SL2->L2_NUMCFID } )
				aAdd( aSL2, { "L2_DTSDFID", 	SL2->L2_DTSDFID } )
				aAdd( aSL2, { "L2_VLRCFID", 	SL2->L2_VLRCFID } )

				lRecFid		:= .T.
				cLojaFid	:= SL1->L1_LOJA
				cNumFid 	:= SL2->L2_NUMCFID
				dDataFid 	:= SL2->L2_DTSDFID
				nValRecFid 	:= SL2->L2_VLRCFID

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Recarga do cartao fidelidade processada: ³
				//³B - Via processo batch (LJGRVBATCH)      ³
				//³W - Via WebService(LJCCARFID) 		    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa)
					If Ca280CkWs ()
						//W - Via WebService(LJCCARFID)
						aAdd( aSL2, { "L2_PROCFID", "W" } )
						lProcFidWs := .T.
					Else
						//B - Via processo batch (LJGRVBATCH)
						aAdd( aSL2, { "L2_PROCFID", "B" } )
						lProcFidWs := .F.
					EndIf
				ElseIf nModulo ==12 .AND. !lMvLjPdvPa
					//B - Via processo batch (LJGRVBATCH)
					aAdd( aSL2, { "L2_PROCFID", "B" } )
					lProcFidWs := .F.
				EndIf
			EndIf

			// Verifico se o Item eh vale Presente.
			If SL2->( ColumnPos("L2_VLTROCA") ) > 0 .AND. SL2->L2_VLTROCA == "1" 
				lValeTroca := .T.	
			EndIf

			DbSelectArea("SL2")
			SL2->(DbSkip())
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleta as reservas qdo necessario                            ³
		//³ O SC0 esta sendo deletado aqui pq a B2AtuComD2 faz a atualiza³
		//³ cao do SB2->B2_RESERVA mas nao mata o SC0                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( aReservas ) .AND. !lMVLJPDVPA
			DbSelectArea( "SC0" )
			SC0->(DbSetOrder( 1 )) // filial + numero + produto + local

			For nX := 1 To Len( aReservas )
				If SC0->(DbSeek( xFilial( "SC0" ) + aReservas[nX][1] + aReservas[nX][2] + aReservas[nX][3] ))
					BEGIN TRANSACTION

					    RecLock( "SC0", .F. )
						SC0->(DbDelete())
						SC0->(MsUnlock())

					END TRANSACTION
				EndIf
			Next nx
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a gravacao do SL4 somente se nao for orcamento gerado de um pedido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( SL1->L1_FILRES ) .AND. Empty( SL1->L1_ORCRES )  .AND. (cTpGeraGdp == GDP_NO)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Teve abatimento total no valor da venda (PIS/COFINS/CSLL)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aPgtos ) == 1 .AND. Empty( aPgtos[01,01] ) .AND. aPgtos[01,02] == ( LJPCCRet() + If( LJ220AbISS(), MaFisRet( , 'NF_VALISS' ), 0 ) )
				lAbtoAll := .T.
			EndIf

			// Verifica se existem pagamentos em Vale Presente e adiciona mais linhas à aPgtos neste caso
			For nX := 1 to Len( aPgtos )
				If Type( "aPgtos[nX][4][4]" ) == "A"
					For nY := 2 to Len( aPgtos[nX][4][4] )
						aAdd( aPgtos, aClone( aPgtos[nX] ) )
						aPgtos[Len(aPgtos)][2]		:= aPgtos[nX][4][4][nY][2]
						aPgtos[Len(aPgtos)][4][4]	:= aPgtos[nX][4][4][nY][1]
					Next nY

					aPgtos[nX][2]		:= aPgtos[nX][4][4][1][2]
					aPgtos[nX][4][4]	:= aPgtos[nX][4][4][1][1]
				EndIf
			Next nX
			For nX := 1 to Len( aPgtos )
			    If (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. lUsaTEF
					cAdminis := aPgtos[nX][4][5]
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula o valor da parcela quando o troco nao esta habilitado. Nao permite gerar parcela com valor zero³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lHabTroco
					nVlrParc  := aPgtos[nX][2]
				Else
					nVlrParc  := Round(Max(aPgtos[nX][2] - IIf(aPgtos[nX][6] <> nMoedaCor, xMoeda( nVlrTroco, nMoedaCor, aPgtos[nX][6], dDatabase ), nVlrTroco), 0), MsDecimais(aPgtos[nX][6]))
				EndIf


				If cPaisLoc <> "BRA"
					nMoedaParc := aPgtos[nX][_MOEDA]
					If aPgtos[nX][1] == dDatabase
						nVlrEntrada += Round(xMoeda(nVlrParc	, nMoedaParc	, nMoedaCor	, dDatabase	,;
											nDecimais+1,,nTxMoeda),nDecimais)
					EndIf
				EndIf

				lRetSL4Vld := ( aPgtos[nX][2] <> 0 .AND. nVlrParc <> 0 )
				nPosTefDados	:= 0

				If lRetSL4Vld
					aAdd( aSL4, {} )
					aAdd( aSL4[Len( aSL4 )], { "L4_FILIAL",xFilial( "SL4" ) } )
					aAdd( aSL4[Len( aSL4 )], { "L4_NUM",	SL1->L1_NUM	} )
					aAdd( aSL4[Len( aSL4 )], { "L4_DATA",	If( lAbtoAll, dDataBase, aPgtos[nX][1] ) } )

					/*Tratamento colocado para que seja apagado as informacoes quando 
					orcamento reaproveitado (cancelada no LOJA140) com TEF,
					se o pagamento da venda atual for TEF, ele apaga dentro do LOJXTEF*/
					aAdd( aSL4[Len( aSL4 )], { "L4_DOCCANC" , ""	} )
					aAdd( aSL4[Len( aSL4 )], { "L4_DATCANC" , ""	} )
					aAdd( aSL4[Len( aSL4 )], { "L4_HORCANC" , ""	} )

					If IsMoney(aPgtos[nX][3]) .OR. aPgtos[nX][3] == "VA"
						If cPaisLoc == "BRA"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Utilizado para a gravacao de troco em qualquer	 |
							//³ numerario										 |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aAdd( aSL4[Len( aSL4 )], { "L4_VALOR", nVlrParc } )
						Else
							nVlrTrcAux := Round(xMoeda(nVlrTroco	, nMoedaCor	, aPgtos[nX][6]	, dDatabase	,;
												MsDecimais(aPgtos[nX][6])+1),MsDecimais(aPgtos[nX][6]))
							aAdd( aSL4[Len(aSL4)], { "L4_VALOR", 	aPgtos[nX][2] - nVlrTrcAux } )
						EndIf
						
						If !lIntegDef //Integracao nao considera troco
							nVlrTroco -= If( nVlrTroco > 0, Lj7T_Troco( 2 ), 0 )
						EndIf
					Else
						aAdd( aSL4[Len( aSL4 )], { "L4_VALOR", 	If( lAbtoAll, 0, aPgtos[nX][2] ) } )
					EndIf

					aAdd( aSL4[Len( aSL4 )], { "L4_FORMA",	If( lAbtoAll, cMVSimb1, aPgtos[nX][3] ) } )

				    lAjstaPgto := .F.
				    If (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. cTipTef == TEF_CLISITEF .AND. lUsaTEF
				    	// Chama a LjVerAdm para ajustar o array aPgtos na posicao referente ao Cod Adm Financeira
						lAjstaPgto := LjVerAdm(.F.,.T.,lTefManual,nX,lSelTefManu)
					Endif

					If !(IsMoney(aPgtos[nX][3])) .AND. Empty(SL1->L1_FILRES) .AND. Empty(SL1->L1_ORCRES) .AND.	!lLayAway

						If Trim(aPgtos[nX][3]) == "CH"
							aAdd( aSL4[Len( aSL4 )], { "L4_ADMINIS",	aPgtos[nX][4][04] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_NUMCART",	aPgtos[nX][4][07] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_AGENCIA",	aPgtos[nX][4][05] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_CONTA",		aPgtos[nX][4][06] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_RG",			aPgtos[nX][4][09] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_TELEFON",	aPgtos[nX][4][10] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_COMP",		aPgtos[nX][4][08] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_TERCEIR",	aPgtos[nX][4][12] } )
							aAdd( aSL4[Len( aSL4 )], { "L4_NOMECLI",	aPgtos[nX][4][14] } )
						Else
							If !lAbtoAll
								If Len(aPgtos[nX][4]) > 4
                                    //Não considera TEF quando execAuto, os dados ja vem preenchidos na chamada da execauto
									If !lAutoExec .AND. (Alltrim(aPgtos[nX][3]) $ _FORMATEF) .AND. (cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + TEF_DISCADO) .AND. lUsaTEF

										If Len(aArrayTEFPos) == 0 .OR. (Alltrim(aArrayTEFPos[len(aArrayTEFPos)][1])+Alltrim(aArrayTEFPos[Len(aArrayTEFPos)][2]) <> ;
																		 Alltrim(aPgtos[nX][3])+Alltrim(aPgtos[nX][8]))

											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³Primeiro faz comparacao entre administradora informada e bandeira da administradora³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  							nPosTefDados := aScan(aTefDados,{|x|,Alltrim(x[19]) == Alltrim(aPgtos[nX][8])})
                  							nPosTefSint := aScan(aPgtosSint,{|x|,Alltrim(x[04]) == Alltrim(aPgtos[nX][8])})
           									If nPosTefDados > 0

	 											cAdminis := LJ7ConfAdm( aPgtos[nX][4][5], aTefDados[nPosTefDados][18],,aTefDados[nPosTefDados][20],aTefDados[nPosTefDados][19],,aPgtosSint[nPosTefSint][2],,,,, aTefDados[nPosTefDados][8] )

 												If !( aTefDados[nPosTefDados][18] $ cAdminis )

	 												If cTipTEF <> TEF_DISCADO
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³Se retorno for diferente, faz comparacao entre administradora informada e administradora retornada³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 												cAdminis := LJ7ConfAdm( aPgtos[nX][4][5], aTefDados[nPosTefDados][8],,aTefDados[nPosTefDados][20])
													Else
	 													// Retorno da forma seleciona na tela de escolha da Adm Financeira
														aPgtos[nX][3] := aTefDados[nPosTefDados][20]
													Endif
												EndIf

											// Se for Pay&Go e MV_TEFMULT = .F.
 											Elseif (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. cTipTEF == TEF_DISCADO .AND. !lTefMult .AND. lUsaTEF 
											
												cAdminis := LJ7ConfAdm( aPgtos[nX][4][5], aTefDados[1][18],,aTefDados[1][20],aTefDados[1][19],,aPgtosSint[1][2],,,,, aTefDados[1][8] )
	 											If !( aTefDados[1][18] $ cAdminis ) 
	 												// Retorno da forma seleciona na tela de escolha da Adm Financeira
													aPgtos[nX][3] := aTefDados[1][20]
												Endif												
											Else
												If nPosTefSint > 0
													cAdminis := LJ7ConfAdm( aPgtos[nX][4][5],,,aPgtosSint[nPosTefSint][1],aPgtosSint[nPosTefSint][4],,,,,,,, aPgtosSint[nPosTefSint][3] )
												Endif
 											EndIf

											Aadd(aArrayTEFPos,{aPgtos[nX][3],aPgtos[nX][8],cAdminis})
										Else
											cAdminis := aArrayTEFPos[Len(aArrayTEFPos)][3]
										Endif
										
										If Len(aNSUVndTef) > 0 //Insere o numero da NSU, caso tenha sido preenchido manualmente
											nAux := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID											
											cNSUVndTef := IIf( nAux > 0 , aNSUVndTef[nAux][4], "")
											If !Empty(AllTrim(cNSUVndTef))
												cL4NSUTEF := cNSUVndTef
												
												aAdd( aSL4[Len( aSL4 )], { "L4_VENDTEF", "S"})
												aAdd( aSL4[Len( aSL4 )], { "L4_DOCTEF" , cNSUVndTef } )
												aAdd( aSL4[Len( aSL4 )], { "L4_NSUTEF" , cL4NSUTEF } )
												aAdd( aSL4[Len( aSL4 )], { "L4_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )

												If nPosTefDados > 0
													aTefDados[nPosTefDados][4] := cNSUVndTef
													aTefDados[nPosTefDados][9] := cL4NSUTEF
												ElseIf !lTefMult .Or. !(nPosTefDados > 0) 
													aTefDados[1][4] := cNSUVndTef
													aTefDados[1][9] := cL4NSUTEF
												EndIf
											Else
												LjGrvLog(Nil,"ATENCAO: NSU digitada não encontrada ou  " +;
															 "NSU não digitado (na tela). SL4 será gravada sem dados de TEF Manual")
											EndIf
										EndIf

									ElseIf !lAutoExec .AND. (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. cTipTef == TEF_CLISITEF .AND. lUsaTEF
										// Por estar em um For e passar pelas mesmas posicoes varias vezes,
										// as variaveis sao inicializadas novamente a cada For
										nPosData   	:= 0
										dDataTrans	:= CtoD(Space(08))
										nPosTrans	:= 0
										nValorTrans := 0
										nPosRetCart := 0

										// oTef:aRetCartao > 1 quando venda com multiplos cartoes
										nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nX][8] } ), 1)

										If nPosRetCart > 0
											// Procura pela data conforme condicao de pagamento/parcelamento (se for parcelado, procura pela data do vencimento da parcela)
											nPosData   	:= aScan(oTef:aRetcartao[nPosRetCart]:aDatas, {|x| x == aPgtos[nX][1] } )

											// Procura pelo valor da transacao (se for parcelado, procura pelo valor da parcela)
											nPosTrans	:= aScan(oTef:aRetcartao[nPosRetCart]:aValores, {|x| x == aPgtos[nX][2] } )

                                            If nPosData > 0 .And. nPosTrans > 0
                                            	dDataTrans := oTef:aRetcartao[nPosRetCart]:aDatas[nPosData]
												nValorTrans := oTef:aRetcartao[nPosRetCart]:aValores[nPosTrans]

												cCodRede 	:= oTef:aRetCartao[nPosRetCart]:cCodRede
												cDescRede 	:= oTef:aRetCartao[nPosRetCart]:cDescRede

												If  dDataTrans == aPgtos[nX][1]	 .AND. nValorTrans == aPgtos[nX][2]
													cAdminis  := LJ7ConfAdm( aPgtos[nX][4][5]											, oTef:aRetCartao[nPosRetCart]:cDescAdm , .F. 										, aPgtos[nX][_FORMAPGTO]				 ,;
																			 IIf(lTefMult,oTef:aRetCartao[nPosRetCart]:cIdCart ,NIL )	, oTef:aRetCartao[nPosRetCart]:cTipCart	, oTef:aRetCartao[nPosRetCart]:nParcelas	, oTef:aRetCartao[nPosRetCart]:cDescCart ,;
																			 Nil														, nPosRetCart							, Nil										, cDescRede								 ,;
																			 Nil														, cCodRede )
 												EndIf
 											Endif
										Endif

										//Caso o Tef Tenha sido cancelado mantem a admnistradora do aPgtos
										If Empty(AllTrim(cAdminis) ) .Or. (lAjstaPgto .And. lSelAdm)
											cAdminis  := aPgtos[nX][4][05]
										EndIf
										
										If Len(aNSUVndTef) > 0 //Insere o numero da NSU, caso tenha sido preenchido manualmente
											nAux := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID
											cNSUVndTef := IIf( nAux > 0 , aNSUVndTef[nAux][4], "")
											If !Empty(AllTrim(cNSUVndTef))
												cL4NSUTEF := cNSUVndTef
												
												aAdd( aSL4[Len( aSL4 )], { "L4_VENDTEF", "S"})
												aAdd( aSL4[Len( aSL4 )], { "L4_DOCTEF" , cNSUVndTef } )
												aAdd( aSL4[Len( aSL4 )], { "L4_NSUTEF" , cL4NSUTEF } )
												aAdd( aSL4[Len( aSL4 )], { "L4_AUTORIZ", cNSUVndTef } )
												aAdd( aSL4[Len( aSL4 )], { "L4_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )
												
												If nPosRetCart > 0 //Preciso preencher para os campos da SE1 ficarem preenchidos
													oTef:aRetcartao[nPosRetCart]:CNSUAUTOR := cNSUVndTef
													oTef:aRetcartao[nPosRetCart]:CNSUSITEF := cL4NSUTEF
													oTef:aRetcartao[nPosRetCart]:cAutoriza := cNSUVndTef
												EndIf												
											Else
												LjGrvLog(Nil,"ATENCAO: NSU digitada não encontrada ou  " +;
															 "NSU não digitado (na tela). SL4 será gravada sem dados de TEF Manual")
											EndIf
										EndIf
									Else
										cAdminis  := aPgtos[nX][4][05]
										
										// Insere o numero da NSU, caso tenha sido preenchido manualmente
										If lTefManual .And. lSelTefManu
											If Len(aNSUVndTef) > 0 
												nAux := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID
												cNSUVndTef := IIf( nAux > 0 , aNSUVndTef[nAux][4], "")
												If !Empty(AllTrim(cNSUVndTef))
													cL4NSUTEF := cNSUVndTef
													
													aAdd( aSL4[Len( aSL4 )], { "L4_VENDTEF", "S"})
													aAdd( aSL4[Len( aSL4 )], { "L4_DOCTEF" , cNSUVndTef } )
													aAdd( aSL4[Len( aSL4 )], { "L4_NSUTEF" , cL4NSUTEF } )
													aAdd( aSL4[Len( aSL4 )], { "L4_AUTORIZ", cNSUVndTef } )
													aAdd( aSL4[Len( aSL4 )], { "L4_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )
													
													If nPosRetCart > 0 //Preciso preencher para os campos da SE1 ficarem preenchidos
														oTef:aRetcartao[nPosRetCart]:CNSUAUTOR := cNSUVndTef
														oTef:aRetcartao[nPosRetCart]:CNSUSITEF := cL4NSUTEF
														oTef:aRetcartao[nPosRetCart]:cAutoriza := cNSUVndTef
													EndIf
													
													If lUsaTef .AND. cTipTef == TEF_NAO_USADO   // Caixa usa TEF e estacao nao tem TEF configurado, permite escolher a Adm Financeira
														cAdminis  := LJ7ConfAdm( aPgtos[nX][4][5], Nil, .F., aPgtos[nX][_FORMAPGTO] , aPgtos[nX][8], Nil, Nil, Nil,;
																				 lTefManual		 , Nil, Nil, Nil					, Nil		   , Nil, lSelTefManu)																		  
													Endif

													//Tratamento para POS gravar o ID do enviarPagamento ao validador fiscal
													//If lMFE .And. Len(aIdPgtoMfe) > 0
														//aAdd( aSL4[nX], { "L4_IDPGVFP", aIdPgtoMfe[nAux][1] })		
													//EndIf	

												Else
													LjGrvLog(Nil,"ATENCAO: NSU digitada não encontrada ou  " +;
																"NSU não digitado (na tela). SL4 será gravada sem dados de TEF Manual")
												EndIf
											EndIf
										EndIf
									EndIf

									If nPosTefDados > 0
										aAdd( aSL4[Len( aSL4 )], { "L4_NOMECLI",	"RD: " + Alltrim(aTefDados[nPosTefDados][8]) + " / BD: " + Alltrim(aTefDados[nPosTefDados][18]) } )
									ElseIf (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. cTipTEF == TEF_DISCADO .AND. !lTefMult .AND. lUsaTEF
										aAdd( aSL4[Len( aSL4 )], { "L4_NOMECLI",	"RD: " + Alltrim(aTefDados[1][8]) + " / BD: " + Alltrim(aTefDados[1][18]) } )
									Endif

									aAdd( aSL4[Len( aSL4 )], { "L4_ADMINIS",	cAdminis } )

									// ----------------------------------------------------------
									//  Verifica a necessidade de alteração no vencimento das
									// parcelas para o Id do cartão em associação com o aSL4
									Lj7VcDUtil( aPgtos, nX )

									If lLjDespa
										If aPgtos[nX][4][10] .AND. aPgtos[nX][4][12] > 0
											aAdd( aSL4[Len( aSL4 )], { "L4_DESPRC",	aPgtos[nX][4][12] } )
									   	EndIf
										aAdd( aSL4[Len( aSL4 )], { "L4_BANPRC",	aPgtos[nX][4][11] } )
									EndIf
								EndIf

								If lMultNegoc .And. Len(aPgtos[nX]) > 10 .And. SL4->(ColumnPos("L4_DESCMN")) > 0
									aAdd( aSL4[Len(aSL4)], { "L4_DESCMN",		aPgtos[nX][11] } )
								EndIf
						    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava o valor do acrescimo separado da parcela ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
							    	If ValType(aPgtos[nX][9]) == "N"
								   		aAdd( aSL4[Len( aSL4 )], { "L4_ACRSFIN", aPgtos[nX][9] } )
									Endif
								Endif

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Release 11.5 - Cartao Fidelidade     ³
								//³Armazenar numero do cartao fidelidade³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Len(aPgtos[nX][4]) > 0 .AND. lLjcFid .AND. AllTrim(aPgtos[nX][3]) = "FID"
									cLojaFid	:= SL1->L1_LOJA
									cNumFid		:= aPgtos[nX][4][1]
									nValFid 	:= aPgtos[nX][2]
									lRecFid		:= .F.

									aAdd( aSL4[Len( aSL4 )], { "L4_NUMCFID",	cNumFid } )
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Recarga do cartao fidelidade processada: ³
									//³B - Via processo batch (LJGRVBATCH)      ³
									//³W - Via WebService(LJCCARFID) 		    ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If  (nModulo == 23) .OR. (nModulo ==12 .AND. lMvLjPdvPa)
										If Ca280CkWs ()
											//W - Via WebService(LJCCARFID)
											aAdd( aSL4[Len( aSL4 )], { "L4_PROCFID", 	"W"} )
											lProcFidWs := .T.
										Else
											//B - Via processo batch (LJGRVBATCH)
											aAdd( aSL4[Len( aSL4 )], { "L4_PROCFID", 	"B"} )
											lProcFidWs := .F.
										Endif
									ElseIf nModulo ==12 .AND. !lMvLjPdvPa
										//B - Via processo batch (LJGRVBATCH)
										aAdd( aSL4[Len( aSL4 )], { "L4_PROCFID", 	"B"} )
										lProcFidWs := .F.
									EndIf
								EndIf

								If Len(aPgtos[nX][4]) > 3
									cNumCart := ""

									If AllTrim(aPgtos[nX][3]) == "VP"
										cNumCart := aPgtos[nX][4][04]
                                        aAdd( aSL4[ Len(aSL4) ], {"L4_CODVP", cNumCart} )

									ElseIf !Empty(aPgtos[nX][4][04])
										If Len(AllTrim(aPgtos[nX][4][04]))	>= 10
											//Armazena numero do cartao conforme permitido no padrao de seguranca PCI(6 primeiros + 4 ultimos numeros do cartao)
											cNumCart := Trim(SubStr(aPgtos[nX][4][04],1,6))

											If !Empty(SubStr(aPgtos[nX][4][04],7,Len(Trim(aPgtos[nX][4][04]))-10))
												cNumCart += EnCript( SubStr(aPgtos[nX][4][04],7,Len(Trim(aPgtos[nX][4][04]))-10),0)
											EndIf

											cNumCart += Trim(SubStr(aPgtos[nX][4][04],Len(Trim(aPgtos[nX][4][04]))-3,4))
										Else
										    cNumCart := Trim(aPgtos[nX][4][04])
										EndIf
									EndIf
                                    
									aAdd( aSL4[Len( aSL4 )], { "L4_NUMCART",	cNumCart } )
								EndIf

								//Grava o banco associado ao cartao de credito
								If cPaisLoc == "BOL" .AND. Len(aPgtos[nX][4]) >= 8 .AND. SL4->(FieldPos("L4_BCOCART")) > 0
									aAdd( aSL4[Len( aSL4 )], { "L4_BCOCART",	aPgtos[nX][4][8] } )
								EndIf

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Faz tratamento quando usa adm financeira e usa Paf para gravar no sl4³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If (Trim(aPgtos[nX][3]) $ "CC|VA|CO|CD|FI" .AND. lMVLJPDVPA) .OR.;
									(Trim(aPgtos[nX][3]) $ "VA" .AND. !lMVLJPDVPA .AND. lCpoPCorte .AND. SAE->AE_PCORTE > 0)	//Somente Vales e Período de Corte (AE_PCORTE) preenchido
									SAE->( DbSetOrder( 1 ) )
									If SAE->( DbSeek( xFilial( "SAE" ) + SubStr( aPgtos[nX][4][05],1,3 ) ) )
										nPos	:= aScan( aSL4[nX], { |x| Alltrim( Upper( x[1] ) ) == "L4_DATA" } )
										dData	:= 	LJCalcVenc(.T., aPgtos[nX][1])
										If nPos > 0
											aSL4[nX][nPos][2] := dData
										Else
											aAdd( aSL4[Len( aSL4 )], { "L4_DATA",	dData } )
										EndIf
									EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Se for Financiamento, verIfica se deve somar dias no vencimento³
								//³conforme informado no cadastro da administradora financeira    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								ElseIf Trim(aPgtos[nX][3]) == "FI"
									SAE->( DbSetOrder( 1 ) )
									If SAE->( DbSeek( xFilial( "SAE" ) + SubStr( aPgtos[nX][4][05],1,3 ) ) )
										nPos	:= aScan( aSL4[nX], { |x| Alltrim( Upper( x[1] ) ) == "L4_DATA" } )
										If nPos > 0
											aSL4[nX][nPos][2]	:= aPgtos[nX][1] + SAE->AE_VENCFIN
										Else
											aAdd( aSL4[Len( aSL4 )], { "L4_DATA",	aPgtos[nX][1] + SAE->AE_VENCFIN } )
										EndIf
									EndIf
								EndIf

							EndIf
						EndIf
					EndIf

					If cTipTEF == TEF_DISCADO
						If nPosTefDados > 0
 							aAdd( aSL4[Len( aSL4 )], { "L4_FORMA",	If( lAbtoAll, cMVSimb1, Alltrim(aTefDados[nPosTefDados][20]) ) } )
	 					ElseIf (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. cTipTEF == TEF_DISCADO .AND. !lTefMult .AND. lUsaTEF
 							aAdd( aSL4[Len( aSL4 )], { "L4_FORMA",	If( lAbtoAll, cMVSimb1, Alltrim(aTefDados[1][20]) ) } )
 						Endif
					Endif

					If cPaisLoc <> "BRA"
						aAdd( aSL4[Len( aSL4 )], { "L4_MOEDA", 	aPgtos[nX][_MOEDA] } )
					EndIf

					//Integracao Mensagem Unica
					If lIntegDef 								
						If Trim(aPgtos[nX][3]) == "CH"
							aAdd( aSL4[Len(aSL4)], { "L4_ADMINIS"	, aPgtos[nX][4][04] } )
							aAdd( aSL4[Len(aSL4)], { "L4_NUMCART"	, aPgtos[nX][4][07] } )
							aAdd( aSL4[Len(aSL4)], { "L4_AGENCIA"	, aPgtos[nX][4][05] } )
							aAdd( aSL4[Len(aSL4)], { "L4_CONTA"		, aPgtos[nX][4][06] } )
							aAdd( aSL4[Len(aSL4)], { "L4_RG"		, aPgtos[nX][4][09] } )
							aAdd( aSL4[Len(aSL4)], { "L4_TELEFON"	, aPgtos[nX][4][10] } )
							aAdd( aSL4[Len(aSL4)], { "L4_COMP"   	, aPgtos[nX][4][08] } )
						EndIf	
					EndIf

					If lIDCNAB .And. Len(aPgtos[nX]) >= _IDCNAB
						aAdd( aSL4[Len( aSL4 )], { "L4_IDCNAB", 	aPgtos[nX][_IDCNAB] } )
					EndIf

					If Type("lAutoExec") == "L" .And. lAutoExec .And. !lFtvdVer12 .AND. !lECommerce .And. !lAutomato .And. Len(aPgtos[nX]) >= _TEFINTEG

						aAdd( aSL4[Len(aSL4)], { "L4_CONHTL"	, aPgtos[nX][_CONTAHTL] } )
						
						//Armazena informacoes do TEF
						If Len(aPgtos[nX][_TEFINTEG]) > 0
						aAdd( aSL4[Len(aSL4)], { "L4_VENDTEF"	, aPgtos[nX][_TEFINTEG][1] } )
						aAdd( aSL4[Len(aSL4)], { "L4_DATATEF" 	, aPgtos[nX][_TEFINTEG][2] } )
						aAdd( aSL4[Len(aSL4)], { "L4_HORATEF" 	, aPgtos[nX][_TEFINTEG][3] } )
						aAdd( aSL4[Len(aSL4)], { "L4_DOCTEF"	, aPgtos[nX][_TEFINTEG][4] } )
						aAdd( aSL4[Len(aSL4)], { "L4_AUTORIZ"	, aPgtos[nX][_TEFINTEG][5] } )
						aAdd( aSL4[Len(aSL4)], { "L4_DATCANC"	, aPgtos[nX][_TEFINTEG][6] } )
						aAdd( aSL4[Len(aSL4)], { "L4_HORCANC"	, aPgtos[nX][_TEFINTEG][7] } )
						aAdd( aSL4[Len(aSL4)], { "L4_DOCCANC"	, aPgtos[nX][_TEFINTEG][8] } )
						aAdd( aSL4[Len(aSL4)], { "L4_INSTITU"	, aPgtos[nX][_TEFINTEG][9] } )
						aAdd( aSL4[Len(aSL4)], { "L4_NSUTEF"	, aPgtos[nX][_TEFINTEG][10]} )
						aAdd( aSL4[Len(aSL4)], { "L4_PARCTEF"	, aPgtos[nX][_TEFINTEG][11]} )	
						EndIf
					EndIf
				ElseIf !lIntegDef .AND. IsMoney(aPgtos[nX][3]) .OR. aPgtos[nX][3] == "VA"
					nVlrTroco -= If( nVlrTroco > 0, Lj7T_Troco( 2 ), 0 )
				EndIf
				If cTipTEF <> TEF_DISCADO
					cAdminis := Space(TamSX3("L4_ADMINIS")[1])
				Endif
				
			Next nX

			If nVlrEntrada > 0
				aAdd( aSL1, { "L1_ENTRADA" ,nVlrEntrada })
			EndIf

			nCont := 1
			DbSelectArea("SL4")
			DbSetOrder(1)
			DbSeek( xFilial("SL4") + SL1->L1_NUM)
			While !Eof() .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM .AND. Empty(SL4->L4_ORIGEM)
				If nCont <= Len(aSL4)
			    	Lj7GeraSL( "SL4", aSL4[nCont] )
			 	Else
 					Begin Transaction

			 		RecLock("SL4",.F.)
			 		DbDelete()
			 		MsUnlock()

			 		End Transaction
			 	EndIf
		    	SL4->(DbSkip())
				nCont ++
			End
			For nX := nCont to Len(aSL4)
				Lj7GeraSL( "SL4", aSL4[nCont], .T. )
			Next nX 
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava informações referentes ao Consumidor Final - Argentina.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "ARG" .AND. aDadosCF[7]
			aAdd( aMAD, { "MAD_FILIAL",xFilial("MAD") })
			aAdd( aMAD, { "MAD_CODEND",aDadosCF[5] })
			aAdd( aMAD, { "MAD_END"   ,aDadosCF[6] })
			Lj7GeraSL( "MAD", aMAD, .T., .T.)

			aAdd( aSLS, { "LS_FILIAL" ,xFilial("SLS") } )
			aAdd( aSLS, { "LS_SERIE"  ,cSerie } )
			aAdd( aSLS, { "LS_DOC"    ,cDoc } )
			aAdd( aSLS, { "LS_TIPO"   ,"N" } )
			aAdd( aSLS, { "LS_DOCCF"  ,aDadosCF[1] } )
			aAdd( aSLS, { "LS_TPDOCCF",aDadosCF[2] } )
			aAdd( aSLS, { "LS_TIPOCI" ,aDadosCF[3] } )
			aAdd( aSLS, { "LS_CLIECF" ,aDadosCF[4] } )
			aAdd( aSLS, { "LS_CODEND" ,aDadosCF[5] } )
			Lj7GeraSL( "SLS", aSLS, .T., .T.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Baixa o Lay-Away - POR|EUA                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cPaisLoc$"EUA|POR" .OR. cPaisLoc$"MEX|COL")  .AND. lLayAway
           nPosLay       := Ascan(aPosCpoDet,{|x| AllTrim(x[1]) == "LR_NUMLAY"}) 	// Posicao do numero do Lay-Away
           nPosItLay     := Ascan(aPosCpoDet,{|x| x[1] == "LR_ITEMLAY"})	        // Posicao do item do Lay-Away
		   SL2->(DbSetOrder(1))
		   SL2->(DbGoto(nRecnoSL2))
		   For nX := 1 to Len(aCols)
	          If (aCols[nX][Len(aCols[nX])])
		         Loop
	          EndIf
			  If nPosLay > 0 .AND. nPosItLay > 0 .AND. !Empty(aColsDet[nX][nPosLay])
				 a800BxLay(aColsDet[nX][nPosLay],aColsDet[nX][nPosItLay],nX)
				 lCompensa  := .T.
				 If Ascan(aNumLay,PadR(aColsDet[nX][nPosLay],nTamE1_NUM)) == 0
				    Aadd(aNumLay,PadR(aColsDet[nX][nPosLay],nTamE1_NUM))
				 EndIf
				 nTotalItem  += aCols[nX][nPosVlItem]
			  EndIf
	          SL2->(DbSkip())
		   Next nX
		EndIf

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz a troca automatica da serie do checkout de acordo com a tabela SL6.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LjAltSerie( cEstacao, cDoc )

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Confirmacao da transacao integrada ao SIGACRD                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CrdxInt()
	   	   If !Empty(cContrato)


     		  Conout("36.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	               " Total : " + Str(Lj7T_Total(2)) +;
	      		   "  Chama a funcao AprovCrd " )

		      aRetCrd := AClone(Lj7AprovCRD( "2"   ,cContrato  ,Lj7T_Total(2)  ,@lConfCRD  ,;
		                                      NIL   ,NIL        ,NIL            ))
	          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	          //³Se nao confirmar a transacao de credito, cancela                  ³
	          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		      If !lConfCRD

		      	   Conout("37.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	      		   " Retorno de lConfCRD = Falso " )


		         DbSelectArea("MA7")
	             DbSetOrder(1)
	             If DbSeek(xFilial("MA7")+SL1->L1_CLIENTE+SL1->L1_LOJA) .AND. (!Empty(MA7->MA7_CONTRA) .OR. !Empty(cContrato))
	                If !Empty(MA7->MA7_CONTRA)
	                   cContrato  := MA7->MA7_CONTRA
	                EndIf

            	   Conout("38.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	      		   " chama a funcao LJ7AprovCRD param1=3 " )


		            aRetCrd    := AClone(Lj7AprovCRD( "3"   ,cContrato  ,Lj7T_Total(2)  ,NIL   ,;
		         								       NIL   ,NIL       ,NIL             ))
		            MsgAlert(STR0069 + CTRL + ;   //"Nao foi possivel confirmar a transacao de credito! "
		                     STR0070 + CTRL + ;   //"Favor reter o cupom e gerar uma Nota de Devolucao ou cancelar a venda atraves da rotina "
		                     STR0071)             //"de cancelamento de cupom(LOJA140)."
		         EndIf
		      Else
		         Conout("39.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	      		   " Transacao confirmada " )

		      EndIf

		   EndIf
	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	       //³Cancela o contrato caso nao seja associado a venda                ³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       If Len(aContraTmp) > 0

 	    	  Conout("40.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	      		   " Chama a funcao CRDATUPEND " )


	          CrdAtuPend( "SL1"   ,10    ,aContraTmp,.F.    ,;
	                      .F.     )
	       else
  	    	  Conout("41.LOJA701C - Lj7GrvVenda - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	      		   " aContraTmp <= 0 " )

	       EndIf
	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	       //³Inicializar aCrdCliente e cContrato apos gravacao da venda 	³
	       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       Lj7SetCRDClie(.T.)
		Else
    		Conout("42.LOJA701C - Lj7GrvVenda - Orcamento: " +;
    		If( Empty(M->LQ_NUM), "", M->LQ_NUM) + "  Sem Integracao com o CRD")
		EndIf
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Atualiza o status do(s) Vale(s) Compra(s) caso o cliente tenha usado no pagamento³
	    //³Esta rotina funciona se o parametro para MV_LJUSAFD estiver habilitado           ³
      	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	If lUsafd .AND. !Empty(aVales)
			If lUsafdOff

				oWSV := WSFRTCRDPSVPG():New()
				oWSV :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/FRTCRDPSVPG.apw"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cria o array dentro do metodo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oWSV:oWSVALES:oWSVERARRAY					:= FRTCRDPSVPG_ARRAYOFDADVALE():New()
				oWSV:oWSVALES:oWSVERARRAY:oWSDADVALE		:= Array( Len(aVales) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Antes de chamar o metodo, atribui os valores ³
				//³as propriedades (passagem de parametros)     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aVales)

 					oWSV:oWSVALES:oWSVERARRAY:oWSDADVALE[nX]   				:= FRTCRDPSVPG_DADVALE():NEW()

					oWSV:oWSVALES:oWSVERARRAY:oWSDADVALE[nX]:cCODVALE		:=	aVales[nX][1]
					oWSV:oWSVALES:oWSVERARRAY:oWSDADVALE[nX]:nVALOR	   		:=	aVales[nX][2]
					oWSV:oWSVALES:oWSVERARRAY:oWSDADVALE[nX]:dVALIDADE		:=	aVales[nX][3]
					oWSV:oWSVALES:oWSVERARRAY:oWSDADVALE[nX]:lRET			:=	aVales[nX][4]
				Next nX

				lRet := oWSV:CRDUPDMAV()

				If !lRet
					If !lAutoExC
						Aviso( STR0007, STR0073, {"OK"} ) //"Atencao" ### "Não foi possivel atualizar a pontuação do cliente."
					Else
						Conout( STR0007 + " - " + STR0073 ) //"Atencao" ### "Não foi possivel atualizar a pontuação do cliente."
					Endif
				EndIf

 	   		Else
		  		If !Crd240UpdMAV( aVales, "3" )
					If !lAutoExC
						Aviso( STR0007, STR0073, {"OK"} )//"Atencao" ### "Não foi possivel atualizar a pontuação do cliente."
					Else
						Conout( STR0007 + " - " + STR0073 )//"Atencao" ### "Não foi possivel atualizar a pontuação do cliente."
					Endif
				Else
					For nY := 1 To Len( aVales )
						CRDA270Log( aVales[nY], "3", cDoc, cPdv, cSerie )
					Next nY
				EndIf
			EndIf
		EndIf
		If nArredondar > 0
			If SL1->(ColumnPos("L1_VLRARR")) > 0
				aAdd( aSL1, { "L1_VLRARR", 	LjxDInsArrTax( nArredondar, aSL4 ) } )
			EndIf
	    EndIf
	EndIf
Else
	If lRecebe
		LjGrvLog(SL1->L1_NUM,"aRet[1] = .F., NAO EFETUADA GRAVACAO DO RECEBIMENTO",aRet)
		MsgStop(STR0217) //"Não efetuada gravação do recebimento."
	Else
		LjGrvLog(SL1->L1_NUM,"aRet[1] = .F., NAO EFETUADA GRAVACAO DA VENDA/ORCAMENTO",aRet)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aqui podemos fazer um tratamento para cada erro encontrado. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aRet ) > 2 .AND. !Empty( aRet[3] ) .AND. !lErroCF .AND. !lShowMsgEr
			MsgStop(aRet[3])
			lShowMsgEr := .T. // Informa que mensagem ja foi apresentada
			LjGrvLog(SL1->L1_NUM,"Mensagem: ",aRet[3])
		EndIf
		If lErroCF
			MsgStop(STR0173)	//"Houve problemas na impressão do Cupom Fiscal."
			LjGrvLog(SL1->L1_NUM,STR0173)		//"Houve problemas na impressão do Cupom Fiscal."
		EndIf
	EndIf

EndIf

If lErroCF
	LjGrvLog(SL1->L1_NUM,"ERRO NA IMPRESSAO DO CUPOM ")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama a funcao LjGrvTudo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRecebe .AND. aRet[1]

	For nX := 1 to Len( aCols )
		If !aCols[nX][Len( aCols[nX] )]
			nNumItens++
		EndIf
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para inicializar as funcoes fiscais o tipo de documento deve³
	//³ser Nota e o numero de itens na venda tem que ser maior que ³
	//³o configurado para a quantidade de itens na nota.           ³
	//³Valore possiveis para Val(Left(SL1->L1_IMPRIME,1)):         ³
	//³1-Cupom Fiscal, 2-Nota Fiscal, 3-Recibo, 4-Nao Imprime      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(Left(SL1->L1_IMPRIME,1)) == 2 .AND. nNumItens > SuperGetMV( "MV_NUMITEN" ) .AND. MaFisFound()
		MaFisEnd( .T. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a funcao de gravacao do 'PACOTE'                                    ³
	//³ .T. = Mostrar as mensagens com MsgStop ou Help / .F. Mostrar com ConOut	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Quando o Primeiro .T. = Mostrar as mensagens com MsgStop ou Help / .F. Mostrar com ConOut

	If !(lMVLJPDVPA)
		// Nao sendo PAF verifica se utiliza NCC no pagamento e/ou tem reserva de produto
		lProcBaixa := nNccUsada == 0 .OR. Len(aReservas) == 0
	EndIf

	//Condicao para gravar a venda gerando apenas SL1,Sl2 e SL4, sendo necessario utilizacao do GrvBatch
	// Se utiliza Venda Assistida On-Line, MV_LJGRVON = .F. e utiliza NCC e/ou reserva de produto a venda por padrao sera gravada on-line
	// 
	If !lEmiteNF .AND. ;
	    ( 	(!lMVLJGRVON .AND. lProcBaixa) .OR. ;
            lMVLJPDVPA .OR. ;
            ((lEmitNFCe .Or. lIsPafNfce) .AND. !lMVLJGRVON) .OR. ;
            (lAutoExec .AND. !lAutomato .AND. LjNfGrvAuto(SM0->M0_CGC));
	    )

		aAreaJob := GetArea()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados da SL1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj7GeraSL( "SL1", aSL1, .F., .F. )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a gravacao do SL2                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))

		//PAF-ECF: Para o PAF-ECF, considera os registros deletados que possuem MD5
		If lNfPafEcf
			SET DELETED OFF
		EndIf

		SL2->(MsSeek(xFilial("SL2") + SL1->L1_NUM))
		nRecnoSL2  := SL2->(Recno())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valor para dar baixa no Lay-Away  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOutros    := SL1->L1_OUTROS
		While !SL2->(EOF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM

			//Verifica se registro deletado será considerado
			If lNfPafEcf
				lUsaRegL2 := !SL2->(Deleted()) .OR. ( SL2->(Deleted()) .AND. !Empty(SL2->L2_PAFMD5) )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os dados da SL2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If lUsaRegL2

				If lNfPafEcf
					cVendido := IIF(SL2->(Deleted()),"N","S")

					nPos 	:= aScan( aSL2, {|x| Alltrim( Upper( x[1] ) ) == "L2_VENDIDO" } )
					If nPos == 0
						aAdd( aSL2, { "L2_VENDIDO", cVendido } )
					Else
						aSL2[nPos][2] := cVendido
					EndIf
				EndIf

				Lj7GeraSL( "SL2", aSL2 )
			EndIf

			If !SL2->(Deleted())
				// Efetua a gravação da venda do Vale Presente
		   		If SL2->( ColumnPos("L2_VALEPRE") ) > 0 .AND. !Empty( SL2->L2_VALEPRE )
					LjGrVVlPre(	SL2->L2_VALEPRE	, SL1->L1_VEND  , SL2->L2_DOC , SL1->L1_ESTACAO,;
						   		SL2->L2_PDV		, SL1->L1_EMISNF, SL1->L1_HORA, SL1->L1_CLIENTE,;
								SL1->L1_LOJA, SL2->L2_SERIE )
				EndIf
			EndIf
			DbSelectArea("SL2")
			DbSkip()
		End

		//PAF-ECF: Para o PAF-ECF, desconsidera os registros deletados
		If lNfPafEcf
			SET DELETED ON
		EndIf

		RestArea(aAreaJob)

		lVendaCup := .T.
   		lRet := .T.

		If !lEmiteNf
			If (lEmitNFCe .Or. lIsPafNfce) .And. !lMVLJGRVON .AND. !lOnlyServ .AND. !lIsVendaVP .AND. !lUseSat .And. !lIntegDef
				lErroNFCe := !Lj701CNFCe( 	SL1->L1_FILIAL	, SL1->L1_NUM	, SL1->L1_DOC	, SL1->L1_SERIE ,;
											cPDV			, lTefOk		, @cKeyNFCe		, @cDescErro	)
				cMsgErro := cDescErro	//Atribuo a mensagem de erro da transmissão da NFC-e
				If lErroNFCe
					lRet := .F.
					aRet[1] := lRet
				Else
					//Atualiza o campo L1_HORA e L1_EMISSNF
						
					If (npos := aScan( aSL1,{ |x| x[1] == "L1_HORA"} ) ) > 0
						aSL1[npos][2] := SL1->L1_HORA
					EndIf
					
						
					If (npos := aScan( aSL1,{ |x| x[1] == "L1_EMISNF"} ) ) > 0
						aSL1[npos][2] := SL1->L1_EMISNF
					EndIf	

				EndIf

			ElseIf lUseSat .And. !lOnlyServ .AND. !lIsVendaVP
				cXML := LjSATXml() // Gera XML

				LjGrvLog( SL1->L1_NUM, "SAT - Gerado XML ")

				If At("<det",cXML) <> 0

					If lMFE
						LjCleanFile()
					EndIf		
					aRetSAT := LJSATComando({"12","EnviarDadosVenda",LJSATnSessao(),cPass,cXML})

					If Len(aRetSAT) > 1 .And. Val(aRetSAT[2]) == 6000 //retorno de sucesso

						aSATDoc := LJSATRetDoc(Decode64(aRetSAT[5]))  //retorna o doc e serie gerado no SAT

						cDoc 		:= cDocSat	:= aSATDoc[1] 
						cSerieSat	:= aSATDoc[2]

						aSatSL1 :=	{	{ "L1_DOC"		, cDoc 		},;
										{ "L1_SERIE"	, cSerie 		},;
										{ "L1_ESPECIE", "SATCE"		},;
										{ "L1_SERSAT"	, cSerieSat	},;
										{ "L1_KEYNFCE", SubStr(aRetSAT[7],4,Len(aRetSAT[7])) } }

						Lj7GeraSL("SL1", aSatSL1, .F.)
						aSatSL1 := {}

						LjGrvLog( SL1->L1_NUM, "SAT - Numeração do Doc e Serie do SAT", aSATDoc )

						LjGrvLog( SL1->L1_NUM, "SAT - Venda com sucesso " )

						If !lMVLJGRVON .AND. nNccUsada > 0
							//Efetua a baixa da(s) NCC(s) utilizada(s) na venda e gera nova NCC se necessário.
							LjBaixaNCC()
						EndIf

						LojSATImprimir(Decode64(aRetSAT[5]), cXML, cSerie, @cDocSat, @cSerieSat) //impressao do cupom

						cDoc := cDocSat

						aSatSL1 := {;
										 {"L1_DOC"	, cDoc	 },;
										 {"L1_SERIE", cSerie },;
										 {"L1_HORA"	, Time()},;
										 {"L1_KEYNFCE" , SubStr(aRetSAT[7],4,Len(aRetSAT[7]))	},;
										 {"L1_SERSAT" , cSerieSat	},;
									 	 {"L1_ESPECIE" , "SATCE"	};
									 }

						LjGrvLog( SL1->L1_NUM, "L1_DOC ", cDoc )
						npos := ASCAN( aSL1,{ |x| x[1] == "L1_DOC"} )
						aSL1[npos][2] := cDoc

						Lj7GeraSL("SL1", aSatSL1, .F.)

						DbSelectArea("SL2")
						If DbSeek(xFilial("SL2")+SL1->L1_NUM)
							While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. !SL2->(EOF())
	       						//Caso referencia ao campo ja se encontre no array aSL2, utilizo a posição encontrada
	       						If (nPos := Ascan( aSL2,{ |x| Alltrim(Upper(x[1])) == "L2_DOC"})) > 0
					        		aSL2[nPos][2] := cDoc
					       		Else
					        		aAdd(aSL2, { "L2_DOC" , cDoc })
					       		EndIf

		       					Lj7GeraSL( "SL2", aSL2, .F. )
		       					SL2->(DbSkip())
							EndDo
						EndIf

						lErroNFCe := .F.						

					Else
						lRet := .F.
						aRet[1] := lRet
						lErroNFCe := .T.

						
						//Em caso de erro na venda, retorno os dados da venda que foram gravados
						aSatSL1 := {;
										 {"L1_DOC"	, "" },;
										 {"L1_PDV"	, "" },;
										 {"L1_SERIE", "" },;
										 {"L1_TIPO",""},;
										 {"L1_NUMCFIS",""},;
										 {"L1_IMPRIME","1N"},;
										 {"L1_HORA",""},;
										 {"L1_KEYNFCE", ""	},;
										 {"L1_SERSAT" , ""	},;
									 	 {"L1_ESPECIE", ""	},;
									 	 {"L1_SITUA",""};									 	 
									 }
						
						aSL1[ASCAN( aSL1,{ |x| x[1] == "L1_DOC"} )][2] := ""

						Lj7GeraSL("SL1", aSatSL1, .F.)						

						LjGrvLog( SL1->L1_NUM, "SAT - Erro ",;
							IIf( Len(aRetSAT) > 1 , aRetSAT[2], STR0210) + "-" + IIf( Len(aRetSAT) > 3 , DecodeUTF8(EncodeUTF8(aRetSAT[4])), STR0210) ) //"Erro inesperado"

						/*
	        			aRet[2] - Codigo
	        			aRet[4] - Descrição
	        			*/
						//Não foi colocado em STFMESSAGE porque a mensagem pode ser grande e não será exibida por completo
						MsgAlert(cSiglaSat + " - Venda não realizada: "  + ;
						IIf( Len(aRetSAT) > 1 , aRetSAT[2], STR0210) + "-" + IIf( Len(aRetSAT) > 3 , DecodeUTF8(EncodeUTF8(aRetSAT[4])), STR0210) ) // Código de erro retornado pelo SAT #"Erro inesperado"
						If lMFE
							LjCleanFile()
						EndIf							
					EndIf
				EndIf				
			ElseIf lUseSat .And. lOnlyServ .AND. !lIsVendaVP
				// NF somente com itens SERVIÇO
				If !lMVLJGRVON .AND. nNccUsada > 0
					//Efetua a baixa da(s) NCC(s) utilizada(s) na venda e gera nova NCC se necessário.
					LjBaixaNCC()
				EndIf
			ElseIf !lMVLJPDVPA .And. !lMVLJGRVON .AND. nNccUsada > 0 .And. !lOnlyServ .AND. !lIsVendaVP .And. !IsInCallStack("Lj7Pedido") //Quando é ECF não PAF
				//Efetua a baixa da(s) NCC(s) utilizada(s) na venda e gera nova NCC se necessário.
				LjBaixaNCC()

			EndIf
		EndIf

	    //Efetua a baixa NCC via WebService
	    If lMVLJPDVPA .AND. nNccUsada <> 0
			Lj7BxNccWS()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³CRIACAO DE  NCC COM OS VALORES DOS DESCONTOS CONCEDIDOS³
		//³     PELO CENARIO DE VENDAS ATIVO/REGRAS DE DESCONTO.  ³
		//³				SOMENTE COM RELEASE 11.5 ATIVO			  ³
		//| 			  	PAF-ECF (SIGALOJA)			  		  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCenVenda
			aDescNcc := LJGETCVAR()
  			If Len(aDescNcc) > 0
  				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³		EXECULTA FUNCAO LJSelIncTit QUE GERA TITULO		 ³
				//³		E VERIFICA SE EXECULTA VIA WEBSERVICE.           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LJSelIncTit(aDescNcc,"SL1")
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Cartao Fidelidade  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLjcFid .AND. lMVLJPDVPA .AND. lProcFidWs

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava recarga/inclusao de saldo em cartao fidelidade neste³
			//³ponto da venda quando for identificada que a gravacao sera³
			//³via Webservice. 											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRecFid
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclusão do saldo do cartao fidelidade - Recarga³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If	!Empty(cNumFid) .AND. !Empty(dDataFid) .AND. (nValRecFid > 0)
					Ca280Exec("CA280ISLD",cNumFid,dDataFid,nValRecFid,cDoc,cSerie,cLojaFid)
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizacao do saldo do cartao fidelidade - Venda³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If	!Empty(cNumFid) .AND. (nValFid > 0)
					Ca280Exec("Ca280ASld",cNumFid,,,cDoc,cSerie,cLojaFid,,nValFid)
				Endif
			Endif

		EndIf
	Else

		If ExistBlock("FTVDGRT") .AND. lFtvdVer12
			ExecBlock( "FTVDGRT", .F., .F. )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Controle de Formularios                 							              ³
		//³Novos parametros:																	          ³
		//³cDocFo - Nro do formulario informado pelo usuario no incio da venda (Controle de Formulario)   ³
		//³aBreakNota - Notas geradas a partir da venda quando o numero de itens de venda exceder o limite³
		//³Paises:Chile/Colombia - F1CHI		 					 						              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !lEmiteNf .AND. (lEmitNFCe .Or. lIsPafNfce) .And. lMVLJGRVON .And. !lOnlyServ .AND. !lUseSAT .AND. !lIsVendaVP .And. !lIntegDef
			//Altera o registro pai para transmissão da NFC-e

			AADD( aNFCeSL1, {"L1_DOC"	, cDoc	 } )
			AADD( aNFCeSL1, {"L1_SERIE"	, cSerie } )
			AADD( aNFCeSL1, {"L1_HORA"	, Time() } )

			aCampoSL1 := {"L1_NUMCFIS", "L1_CGCCLI", "L1_TIPO", "L1_NUMMOV"}

			For nX := 1 To Len(aCampoSL1)

				nPos := Ascan( aSL1, { |x| x[1] == aCampoSL1[nX]} )
				If nPos > 0
					AADD( aNFCeSL1, {aSL1[nPos][1]	, aSL1[nPos][2] } )
				EndIf

			Next nX

			Lj7GeraSL("SL1", aNFCeSL1, .F.)

			lErroNFCe := !Lj701CNFCe( 	SL1->L1_FILIAL	, SL1->L1_NUM	, SL1->L1_DOC	, SL1->L1_SERIE	,;
										cPDV			, lTefOk		, @cKeyNFCe		, @cDescErro	)
			cMsgErro := cDescErro	//Atribuo a mensagem de erro da transmissão da NFC-e
			If lErroNFCe
				lRet := .F.
				aRet[1] := lRet
			Else
				//Atualiza o campo L1_HORA e L1_EMISSNF
					
				If (npos := aScan( aSL1,{ |x| x[1] == "L1_HORA"} ) ) > 0
					aSL1[npos][2] := SL1->L1_HORA
				EndIf
				
					
				If (npos := aScan( aSL1,{ |x| x[1] == "L1_EMISNF"} ) ) > 0
					aSL1[npos][2] := SL1->L1_EMISNF
				EndIf				
				
			EndIf

		ElseIf	 lUseSat .And. !lEmiteNf .And. !lOnlyServ
			cXML := LjSATXml()  // Gera XML

			LjGrvLog( SL1->L1_NUM, "SAT - Gerado XML ")
			If At("<det",cXML) <> 0

				Lj7GeraSL("SL1", {{"L1_SERIE", cSerie }}, .F.)

				aRetSAT := LJSATComando({"12","EnviarDadosVenda",LJSATnSessao(),cPass,cXML})

				If Len(aRetSAT) > 1 .And. Val(aRetSAT[2]) == 6000 //retorno de sucesso

					aSATDoc := LJSATRetDoc(Decode64(aRetSAT[5]))  //retorna o doc e serie gerado no SAT

					cDoc := cDocSat	:= aSATDoc[1] 
					cSerieSat			:= aSATDoc[2]

					aSatSL1 :=	{	{ "L1_DOC"		, cDoc 		},;
									{ "L1_SERIE"	, cSerie 		},;
									{ "L1_ESPECIE", "SATCE"		},;
									{ "L1_SERSAT"	, cSerieSat	},;
									{ "L1_KEYNFCE", SubStr(aRetSAT[7],4,Len(aRetSAT[7])) },;
									{ "L1_SITUA"	, "T3"			} } //Consumiu o numero de DOC e Serie

					Lj7GeraSL("SL1", aSatSL1, .F.)
					aSatSL1 := {}

					LjGrvLog( SL1->L1_NUM, "SAT - Numeração do Doc e Serie do SAT", aSATDoc )

					LjGrvLog( SL1->L1_NUM, "SAT - Venda com sucesso " )

					LojSATImprimir(Decode64(aRetSAT[5]), cXML, cSerie, @cDocSat, @cSerieSat) //impressao do cupom
			
					cDoc := cDocSat

					aSatSL1 := {;
									 {"L1_DOC"	, cDoc	 },;
									 {"L1_SERIE", cSerie },;
									 {"L1_HORA"	, Time()},;
									 {"L1_KEYNFCE" , SubStr(aRetSAT[7],4,Len(aRetSAT[7]))	},;
									 {"L1_SERSAT" , cSerieSat	},;
									 {"L1_ESPECIE" , "SATCE"	};
								 }

					LjGrvLog( SL1->L1_NUM, "L1_DOC ", cDoc )
					npos := ASCAN( aSL1,{ |x| x[1] == "L1_DOC"} )
					aSL1[npos][2] := cDoc

					Lj7GeraSL("SL1", aSatSL1, .F.)

					DbSelectArea("SL2")
					If DbSeek(xFilial("SL2")+SL1->L1_NUM)
						While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. !SL2->(EOF())
       						//Caso referencia ao campo ja se encontre no array aSL2, utilizo a posição encontrada
       						If (nPos := Ascan( aSL2,{ |x| Alltrim(Upper(x[1])) == "L2_DOC"})) > 0
				        		aSL2[nPos][2] := cDoc
				       		Else
				        		aAdd(aSL2, { "L2_DOC" , cDoc })
				       		EndIf

	       					Lj7GeraSL( "SL2", aSL2, .F. )
	       					SL2->(DbSkip())
						EndDo
					EndIf

				Else
					lRet := .F.
					aRet[1] := lRet
					lErroNFCe := .T.

					LjGrvLog( SL1->L1_NUM, "SAT - Erro ",;
						IIf( Len(aRetSAT) > 1 , aRetSAT[2], STR0210) + "-" + IIf( Len(aRetSAT) > 3 , DecodeUTF8(EncodeUTF8(aRetSAT[4])),STR0210 ) ) //"Erro inesperado."

	            /*
	            	aRet[2] - Codigo
	            	aRet[4] - Descrição
	            */
	            //Não foi colocado em STFMESSAGE porque a mensagem pode ser grande e não será exibida por completo
	            MsgAlert(cSiglaSat + " - Venda não realizada: "  + ;
       		 IIf( Len(aRetSAT) > 1 , aRetSAT[2], STR0210) + "-" + IIf( Len(aRetSAT) > 3 , DecodeUTF8(EncodeUTF8(aRetSAT[4])), STR0210) ) // Código de erro retornado pelo SAT # "Erro inesperado"
					If lMFE
						LjCleanFile()
					EndIf						
				EndIf

			EndIf
		ElseIf lEmiteNF .AND.lGE
			LjNFCeGE(3)

			//resetamos as variaveis estaticas do fonte LOJXFUNG.PRW apos a impressão do termo
			LjxSetRGer()
			LjxSetRGar()
		EndIf

		// Colocada a mesma consistência usada na atribuição da variável nNCCUSADA, onde é atribuido a informação L1_CREDITO.
		// Porém, devido acima ter sido modificada e não estar mais zerando o campo L1_CREDITO, agora, está sendo zerado, após a impressão da NF
		If nOpc == 4 .AND. SL1->L1_RESERVA == "S" .AND. !Empty(SL1->L1_FILRES) .AND. !Empty(SL1->L1_ORCRES) .AND. SL1->L1_CREDITO > 0 
			If (npos := aScan( aSL1,{ |x| x[1] == "L1_CREDITO"} ) ) > 0
				aSL1[npos][2] := 0
			EndIf	
		EndIf
		If !lErroNFCe .And. !lErroNFe
			If !lAutoExC
				LjGrvLog(SL1->L1_NUM,"CHAMADA DA GRAVACAO DA NOTA")

				lRet := LjGrvTudo( 	.T.       	,lFinanceiro			,nNCCUsada  ,aNCCItens  ,;
             					  	nNCCGerada 	,aImpCheque				,nMoedaCor  ,@aRecnoSE1 ,;
				                   	aVlrAcres  	,aSL1	        		,aSL2		, cDoc		,;
			    	               	@lVendaCup 	,nNumItens				,nFrete		,nSeguro	,;
									nDespesa  	,cLQFrete				,aAcrFin	,NIL		,;
									cCgcCli   	,cNomeCli				,lNfManual	,@lExistNF  ,;
									@cDescErro  ,@cEspecNf				,cDocFo		,@aBreakNota,;
									@aNewNCC	,cTpGeraGdp				,nOpc		,nArredondar,;
									@lErroNFe 	,Len(aNSUVndTef) > 0	,cSerie 	)

				LjGrvLog(SL1->L1_NUM,"RETORNO DA GRAVACAO DA NOTA",lRet)

				If lErroNFe
					lRet := .F.
					aRet[1] := lRet
				EndIf
			Else

				lRet := LjGrvTudo( 	.T.       	,lFinanceiro	,nNCCUsada  ,aNCCItens  ,;
				                   	nNCCGerada 	,aImpCheque		,nMoedaCor  ,@aRecnoSE1 ,;
				                   	aVlrAcres  	,aSL1	        ,aSL2		, cDoc		,;
		    		               	@lVendaCup 	,nNumItens		,nFrete		,nSeguro	,;
									nDespesa  	,cLQFrete		,aAcrFin	,NIL		,;
									cCgcCli   	,cNomeCli		,lNfManual	,@lExistNF  ,;
									@cDescErro  ,@cEspecNf		,cDocFo		,@aBreakNota,;
									@aNewNCC	,cTpGeraGdp		,nOpc		,nArredondar)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada utilizado para impressão da NCC com o valor do saldo restante   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(SuperGetMV("MV_USACRED"),1,1) == "S"
			If lLojR860A
				ExecBlock('LOJR860A',.F.,.F.,{ aNewNCC, aNCCItens , (nNCCUsada - nNCCGerada) })
			Endif
		Endif

	EndIf

	// este é um complemento do ajuste feito na ChangeSet 585161,
	// onde previa a retirada de várias chamadas da função L701DCVTImp em apenas um local.
	// Aqui foi ajustado o local da chamada da função L701DCVTImp, assim se entrar na condição !lEmiteNF, 
	// irá chamar a função e imprimir o Vale Troca.
	If lRet .AND. lValeTroca .AND. lEmitNFCe
		L701DCVTImp(Nil,SL1->L1_DOC ,.T.) // IMPRESSAO VALE TROCA
	EndIf	


	//Nota - A numeracao da Nota/Serie eh atribuida pela funcao LJGRVTUDO(), atualiza variaveis
	If lFtvdVer12 .Or. (!lFtvdVer12 .AND. ( (!lEmitNFCe .And. !lIsPafNfce) .Or. ( (lEmitNFCe .Or. lIsPafNfce) .And. lEmiteNF)))
		cSerie	:= SL1->L1_SERIE
		cDoc 	:= SL1->L1_DOC
		cPdv 	:= SL1->L1_PDV
	EndIf

	cEspecie := cEspecNf

	Lj7GrvMotDesc(cSerie , cDoc , IIf( lMVLJPDVPA .AND. (SL1->( ColumnPos( "L1_NUMORIG" ) ) > 0) , SL1->L1_NUMORIG , ""), "")  // (cSerie,cDoc,cNumOrc,cTipo)

	If nOpc == 4
		Lj7PesqAltMot( cSerie , cDoc , SL1->L1_NUM )
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tendo Integracao com o TMK atualiza os campos da tabela SUA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMvTmkLoj == "S"
		If SL1->(ColumnPos("L1_NUMATEN"))>0
			DbSelectArea("SUA")
			SUA->(DbSetOrder(1))
			If SUA->(DbSeek(xFilial("SUA")+SL1->L1_NUMATEN))
				RecLock("SUA",.F.)
				REPLACE UA_OPER 	WITH "1"
				REPLACE UA_DOC  	WITH cDoc
				If !lFtvdVer12
					REPLACE UA_STATUS   WITH "NF"
				ElseIf lFtvdVer12
					REPLACE UA_STATUS   WITH "NF."
				EndIf
				REPLACE UA_SERIE  	WITH cSerie
				REPLACE UA_EMISNF 	WITH dDatabase
				REPLACE UA_VEND		WITH SL1->L1_VEND
				SUA->(MsUnlock())
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Encerra o atendimento na lista de contatos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SU4")
			SU4->(dbSetOrder(4))	//U4_FILIAL+U4_CODLIG
			If SU4->(dbSeek(xFilial("SU4")+SL1->L1_NUMATEN)) .And. SU4->U4_STATUS <> "2"
				RecLock("SU4",.F.)
				REPLACE SU4->U4_STATUS WITH "2"	//Status de encerrado
				SU4->(MsUnlock())
			EndIf
		EndIf
	EndIf

	If !lVendaCup
		//"A emissão da Nota Fiscal foi cancelada. Será gerado um orçamento para ser finalizado posteriormente.","Emissão de Nota Fiscal Cancelada"
		MsgAlert(STR0083,STR0084)
		/*Tratamento para gravar os campos
		com os valores que tinham antes de
		passar pela função RecTrib ()  */
		
		DbSelectArea("SL2")
		DbSetOrder(1)
		DbSeek(xFilial("SL2") + cSeqTrans)
		While !Eof() .AND. xFilial("SL2") + cSeqTrans == SL2->L2_FILIAL + SL2->L2_NUM
			RecLock("SL2", .F.)
			If nMvLjTpDes <> 2
				REPLACE L2_VRUNIT  WITH L2_PRCTAB - Round((L2_VALDESC /	 L2_QUANT),MsDecimais(nMoedaCor))
			Else
				REPLACE L2_VRUNIT  WITH A410Arred(L2_PRCTAB - (L2_PRCTAB *(L2_DESC /100))  ,"LR_VLRITEM")
			EndIf
			REPLACE L2_VLRITEM WITH L2_VRUNIT * L2_QUANT
			REPLACE L2_VALPS2  WITH 0
			REPLACE L2_VALCF2  WITH 0
			REPLACE L2_BASEPS2 WITH 0
			REPLACE L2_BASECF2 WITH 0
			REPLACE L2_DESCPRO WITH 0
			REPLACE L2_VALFRE  WITH 0
			REPLACE L2_SEGURO  WITH 0
			REPLACE L2_DESPESA WITH 0
			MsUnLock()
			DbSkip()
		End
		Return .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a Gravacao da venda nao foi executada com sucesso  ³
	//³o cupom fiscal deve ser cancelado e caso exista alguma³
	//³transaçao tef deve ser desfeita                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRet
		LjGrvLog(SL1->L1_NUM,"PROBLEMA COM A GRAVACAO DA VENDA")
		If (lEmitNfce .Or. lIsPafNfce) .AND. !lEmiteNF
			cCancMsg := STR0174 //"Houve problemas na emissão da NFC-e"
		Else
			cCancMsg := STR0082 //"Erro na Gravação da Venda!"
		Endif
		Lj7CancVenda(	cCancMsg	, cDoc		, cSerie	, cPdv			,;
						.F.			, lTefOk	, @lExistNF	, @cDescErro	,;
						.T. 		,  Nil		, Nil		, @aTefBKP		,;
						@lTemTEFPend	)

		//Quando NFC-e, necessário finalizar a venda para cancelamento no TSS
		If !lEmitNFCe .And. !lIsPafNfce
			Return .F.
		EndIf
	EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava movimento de venda perdida durante a finalizacao da venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMVLJPDVPA .AND. !Empty(cDoc) .AND. !Empty(cSerie) .AND. lVendaPerdida
		oMoviVp 	:= LA701GetVp() //OBTER OBJETO DE MOVIMENTO DE VENDA PERDIDA, ATIVO NO LOJA701
		If oMoviVp	<> NIL
			LA701GrvVp (oMoviVp,SL1->L1_NUMORC,cDoc,cSerie)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a gravacao do Log depois de ter gravado todas as tabelas referentes³
	//³a venda (SL1, SL2, SL4), para que nao haja perda dos dados da gravacao ³
	//³do SL4 com relacao ao TEF. BOPS: 86536                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

		LjGrLogT(	SL1->L1_NUM     , cNumCupom			, xNumCaixa()		, aTefDados			,;
					SL1->L1_DINHEIR , SL1->L1_CHEQUES	, SL1->L1_CARTAO	, SL1->L1_VLRDEBI	,;
					SL1->L1_CONVENI	, SL1->L1_VALES		, SL1->L1_FINANC	, SL1->L1_OUTROS	,;
					SL1->L1_DESCONT	, SL1->L1_DESCNF	, cNumPdv			, cSerie			,;
					If(lL1VLRPGDG,SL1->L1_VLRPGDG,0)	, If(lL1VLRPGDG,SL1->L1_VLRPGPX,0)  	)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nota fiscal eletronica Mexico             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "MEX" .And. AliasIndic("MDL")
		If !InTransaction()
			DBSelectArea("SF2")
			DBSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If MsSeek(XFilial("SF2") + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA)
				While lGrvPCFD
					LOJXGERCFD(lFiscal , lPergGrCFD , @aMsgCert)
					If !Empty(SF2->F2_NEXTDOC)
						If MsSeek(SF2->F2_FILIAL + SF2->F2_NEXTDOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
							lGrvPCFD	:= .T.
							lPergGrCFD	:= .F.
						Else
							lGrvPCFD	:= .F.
						EndIf
					Else
						lGrvPCFD	:= .F.
					EndIf
				End
				If lValidMsg
					LJXListFol(aMsgCert)
				EndIf
			EndIf
		Else
			If !IsBlind()
				Aviso( STR0007, STR0218, {STR0005} ) //"íAtencion!" # "TES para el pedido de venta no informada, verifique los parámetros MV_LJTESPE \ MV_LJECOME y el registro de TES inteligente" # "OK" 
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama rotina para impressão da Nota Fiscal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando estiver usando o usuario manual (28) significa que não deve imprimir factura...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lRet .AND. lEmiteNF ) .OR. ( lRet .AND. cPaisLoc <> "BRA" .AND. !lFiscal .AND. !LjProfile(28) .AND. (lAutoExC .OR. (!lAutoExC .AND. ;
		IIf(	cPaisLoc $ "MEX|PER" , ;
		 		IIf(cMV_LJIMPFA == "1", MsgYesNo(STR0041), IIf(cMV_LJIMPFA == "2", .T., .F.)) , ;
		 		MsgYesNo(STR0041) ) ) ) )						// "Deseja realizar a impressão da fatura de venda?"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta array com informacoes para impressao nos detalhes da NF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosTefNf := {}

		If lTefOk .And. cTipTef == TEF_CLISITEF

			For nX := 1 to Len(oTef:aRetCartao)

				aAdd( aDadosTefNf , Array(7))

				aDadosTefNf[nX][1] := StoD(oTef:cData)				   	//"L4_DATATEF"
				aDadosTefNf[nX][2] := oTef:aRetCartao[nX]:cHoraTrans	//"L4_HORATEF"
				aDadosTefNf[nX][3] := oTef:aRetCartao[nX]:cNsuAutor	//"L4_DOCTEF"
				aDadosTefNf[nX][4] := oTef:aRetCartao[nX]:cAutoriza	//"L4_AUTORIZ"
				aDadosTefNf[nX][5] := oTef:aRetCartao[nX]:cDescAdm		//"L4_INSTITU"
				aDadosTefNf[nX][6] := oTef:aRetCartao[nX]:cNsuSitef	//"L4_NSUTEF"
				aDadosTefNf[nX][7] := oTef:aRetCartao[nX]:cTipCart		//"L4_TIPCART"

			Next nX

		EndIf

      	// Verifica se a especie do documento eh SPED
      	If AModNot(cEspecie)$"55,57" .Or. AllTrim(cEspecie) == "RPS" //RPS (Recibo Provisorio de Servico)
      		lSped := .T.
      	EndIf

		If ( cMVSCRNOTA == "LJNFISCA" .OR. cMVSCRNOTA == "LJSCNFISCA" ) .AND. ExistFunc("LJSCNFISCA")
			bImpNf := {|| LJSCNFISCA({SL1->L1_DOC,SL1->L1_SERIE,{},aDadosTefNf}) } 
		Else
			bImpNf := {|| ExecBlock(GetMV("MV_SCRNOTA"),.F.,.F.,{SL1->L1_DOC,SL1->L1_SERIE,{},aDadosTefNf })}
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta array com informacoes para impressao nos detalhes da NF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LjNfVldImp() .Or. LjNfUsaTef(SM0->M0_CGC) .Or. (lEmiteNF .And. (lEmitNFce .Or. lIsPafNfce)) //Chamada da funcao LjNfUsaTef() aqui exclusivamente p/ o cliente DALLAS RENT A CAR, p/ entrar neste IF e nao executar a impressao da Nota atraves da funcao LojR110			
			LjMsgRun(STR0074,, bImpNf ) //"Aguarde ... imprimindo nota fiscal..."
		ElseIf !(lSped) 	// nao executa quando for Nota Fiscal Eletronica
			If 	(cPaisLoc $ "CHI|COL" .OR.  INFLocaliz()) .AND. !LjProfile(28) .AND. !lJob
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Release 11.5 - Controle de Formularios e comprovante- F2CHI 			³
				//³Impresssao Localizada: Comprovante / Factura							³
				//³Paises:Chile/Colombia/Australia										³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lImpNF := Lj7ImpLoc (aBreakNota,NIL,nOpc,.F.)
			ELseIf cPaisLoc == 'PER' //RESOLUCION DE SUPERINTENDENCIA Nº 007-99-SUNAT
				LjMsgRun(STR0074,, bImpNf ) //"Aguarde ... imprimindo nota fiscal..."
			ElseIf !LjProfile(28)
				If Iif(cPaisLoc == 'MEX', !InTransaction(), .T.) 
					LjMsgRun(STR0074,,{|| lImpNF := LojR110( SL1->L1_DOC, SL1->L1_SERIE, aDadosTefNf ) } )	 	//"Aguarde ... imprimindo nota fiscal..."
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cancela a transacao TEF se a nota fiscal nao for impressa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(lImpNF) == "L"
			If !lImpNF .AND. lTefOk .AND. LjNfUsaTef(SM0->M0_CGC)
				If !lFtvdVer12
					Lj7CancVenda(STR0084, 	SL1->L1_DOC, 	SL1->L1_SERIE, 	/*cPdv*/"", .T., lTefOk) //"Emissão de Nota Fiscal Cancelada"
				ElseIf lFtvdVer12
					Lj7CancVenda(STR0084, 	SL1->L1_DOC, 	SL1->L1_SERIE, 	/*cPdv*/"", .T., lTefOk, @lExistNF	, @cDescErro)
				EndIf
			EndIf
		Else
			lImpNF := .T.
		EndIf
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compensa os titulos RA com a NF gerada na entrega - POR|EUA  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cPaisLoc$"EUA|POR" .OR. cPaisLoc$"MEX|COL") .AND. lLayAway
	   nTotalItem += Lj7T_ImpsV("1",2)
	   For nX := 1 to Len(aNumLay)
	      cNumLay    := AllTrim(aNumLay[nX])
		  nTotalLay  += a800Total(.T.)
	   Next nX
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Compara o valor da venda e do Lay-Away para verIficar se tra-³
	   //³ ta de finalizacao total do Lay-Away                          ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   lLayTotal   := nTotalItem == nTotalLay .OR. !SuperGetMV("MV_LWPARC")
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Chama a tela de compensacao quando entrega parcial ou o para-³
	   //³ metro MV_LWCPAUT = .F.(permite ou nao compensacao automatica ³
	   //³ na finalizacao do Lay-Away)                                  ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lCompensa
	      If !SuperGetMV("MV_LWCPAUT",,.T.) .OR. !lLayTotal
	         If Len(aRecnoSE1) > 0
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Posiciona no titulo NF gerado pela entrega do Lay-Away	    ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            SE1->(DbGoto(aRecnoSE1[1]))
		        a800Titulo(5,nOutros,aNumLay)
		     EndIf
		  Else
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³ Se for entrega total ja compensa os titulos de forma automatica   ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		     If !a800CompAut(aNumLay)
		        Aviso(STR0031,STR0032+chr(13)+; //"Atencao!"###"Nao foi possivel fazer a compensacao dos titulos RA "
		        	  STR0033+chr(13)+;         //"gerados pelo Lay-Away. Fazer a compensacao manualmente atraves "
		              STR0034,{STR0005})        //"da rotina Compensacao Contas a Receber."###"Ok"
		     EndIf
		  EndIf
	   EndIf
    EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aqui podemos fazer um tratamento para cada erro encontrado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aRet ) > 2 .AND. !Empty( aRet[3] ) .AND. !lErroCF .AND. !lShowMsgEr
		MsgStop( aRet[3] )
	EndIf

	If lErroCF
		// ### "Houve problemas na impressão do Cupom Fiscal."
		Lj7CancVenda(	STR0076	,	cDoc	,	cSerie	,	cPdv,;
					 	.T.		, 	lTefOk	,	Nil     ,  	Nil	,;
					 	Nil     , 	lErroCF	)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para gravar os campos   ³
		//³com os valores que tinham antes de ³
		//³passar pela funcao RecTrib ()      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			DbSelectArea( "SL1" )
			DbSetOrder( 1 )
			DbSeek( xFilial( "SL1" ) + cSeqTrans )
			If SL1->( !Eof() ) .AND. xFilial( "SL1" ) + cSeqTrans == SL1->L1_FILIAL + SL1->L1_NUM
				RecLock( "SL1", .F. )
				REPLACE L1_VALBRUT WITH Lj7T_Total(2)
				REPLACE L1_VLRLIQ  WITH Lj7T_Total(2)
				MsUnLock()
			EndIf

			DbSelectArea( "SL2" )
			DbSetOrder( 1 )
			DbSeek( xFilial( "SL2" ) + cSeqTrans )
			While SL2->( !Eof() ) .AND. xFilial( "SL2" ) + cSeqTrans == SL2->L2_FILIAL + SL2->L2_NUM
				RecLock("SL2", .F.)
				REPLACE L2_VRUNIT  WITH L2_PRCTAB - Round( ( L2_VALDESC / L2_QUANT ),MsDecimais( nMoedaCor ) )
				REPLACE L2_VLRITEM WITH L2_VRUNIT * L2_QUANT
				REPLACE L2_VALPS2  WITH 0
				REPLACE L2_VALCF2  WITH 0
				REPLACE L2_BASEPS2 WITH 0
				REPLACE L2_BASECF2 WITH 0
				MsUnLock()
				DbSkip()
			End
		EndIF
		Return .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a impressao do cupom TEF e grava as informacoes do TEF nas tabelas SL1, SL2 e SL4 #TEFOK#³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoExec .AND. !lRecebe .AND. lRet .AND. !lErroNFCe .And. !lErroNFe

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava a milhas do cupom para o cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. GetNewPar( "MV_TEFMILH", .F. ) .AND. cTipTEF $ "2;3;4"
       LOJA010T( "P", "AO", aRet )
	EndIf

	If Len(aTEFDados) > 0
		lTefOk := .T.
	Endif
	
	//Caso utilize o PBM executa rotina de impressão do Template
	If lUsaTef .And. ExistTemplate("DroVLImp") .And. Len(aRetPbm) > 2 .And. aRetPbm[3] == 2
	   
		aPbmImp := ExecTemplate("DroVLImp",.F.,.F.,{2})
		LJ7DadosVL({aRetPbm[1],aRetPbm[2],0}) 
	Else
		LjGrvImpTEF(@lTefOk		, lCartao	, aRet		, @nSize	,;
					@cRBuffer	, nHandle	, @lAbtoAll	, @cAdminis	,;
			    	@oTef		, cSerie	, lLog1		, lLog4		,;
					@lErrCupTEF	, @lDscCupTef, aTEFDados, @lTemTefPend,;
					aNSUVndTef  )
	EndIf	

	If ExistFunc("LjImprimPD") .And. lTemPagDig .And. lPagDigOk
		//Imprime o comprovante de Pagamento Digital
		LjImprimPD()
	EndIf

	// Se for faturamento e a nota foi impressa, confirma a transacao TEF
	If (!ValType(lImpNF) == "U") .AND. lImpNF .AND. LjNfUsaTef(SM0->M0_CGC) .AND. lTefOk .AND. !IsBlind() ;
		.Or. (Len( aPbmImp) > 0 .And. aPbmImp[1] == 0)

		If cTipTef == TEF_CLISITEF
			If Len( aPbmImp) > 0 .And. aPbmImp[1] == 0
				oTEF:FinalTrn(1)
			EndIf
			oTef:lImprimiu := .T.
			lTefOk := oTEF:lTefOk := .T.
		ElseIf cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + 	TEF_DISCADO
			LOJA010T(  "F"   , "S"	  	, /*aDados*/		, /*lConsulta */  	,;
                   /*lImprime*/ , /*cFPagReceb*/ 	, /*lTemTEFPend*/	, /*lAbandonaTEF*/	,;
                   /*lTitulo*/	, /*aTefTmp*/		, /*lBaixa*/		, /*lSemRede*/		,;
                   /*cOrcamen*/	, /*lRelGer*/		, /*cMsgCupom */	, /*nVlrTotal*/		,;
                   /*cId800*/	, /*oWsTrn*/		, /*aDadosTrn*/		, /*lRecCel*/		,;
				   /*lTemTEFOk*/, .T.)
			lTefOk :=  .T.
		Else
			lTefOk := .T.
        Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o campo LG_LOGTEF existe e verifica³
		//³se posicionou no registro                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LJVerifSLG()
			If !Empty(SLG->LG_LOGTEF)
				RecLock("SLG",.F.)
				REPLACE SLG->LG_LOGTEF WITH ""
				SLG->(MsUnLock())
			Endif
		Else
			If File(GetClientDir() + "CLISITEF." + StrZero(oTEF:nIDTermina, 3) ) .And. oTef:lTefOk
				FErase( GetClientDir() + "CLISITEF." + StrZero(oTEF:nIDTermina, 3) )
			EndIf
		Endif
	EndIf

ElseIf !lRet .AND. (lErroNFCe .Or. lErroNFe) .AND. (ExistFunc("LjImprimPD") .And. lTemPagDig .And. lPagDigOk )

	//Cancela transações de Pagamento Digital.
	If ExistFunc("LjPDGtPGrv") .And. ExistFunc("LjPDCanTrn")
		//Busca informações de Pagamentos Digitais gravados na venda.
		aPagDigPix	:= LjPDGtPGrv(SL1->L1_NUM, .T.)

		If Len(aPagDigPix) > 0 .And. !LjPDCanTrn(@aPagDigPix)
			Alert(STR0236) // "Falha no cancelamento do Pagamento Digital/PIX."
			LjGrvLog(SL1->L1_NUM,"Falha na emissão do documento, efetuado cancelamento da transação TOTVS Pagamentos Digitais.",lRet)	 
		Else
			Help(" ", 1, STR0234, , STR0237, 1, 0) // "Pagamento Digital" ## "Devido a falha na transmissão, a transação TOTVS Pagamentos Digitais foi cancelada."
			LjGrvLog(SL1->L1_NUM,"Falha na emissão do documento, efetuado cancelamento da transação TOTVS Pagamentos Digitais.",lRet)	
		EndIf
	EndIf


EndIf

//Envio da resposta fiscal para o integrador MFE utilizado no POS
//If lMFE .And. lLjRspFisc .And. Len(aNSUVndTef) > 0
//	LjRspFisc(aNSUVndTef,.T.,aIdPgtoMfe)
//	aIdPgtoMfe := {}
//EndIf	

//se for PAF-ECF, realiza o tratamento do troco, antes da venda subir para a retaguarda
If lMVLJPDVPA .AND. lHabTroco
	LjGrvLiq()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATENCAO: Atualizacoes que envolvem as Tabelas: SL1,SL2 e SL4 devem ser realizadas antes desse ponto				³
//³Atualiza Campo L1_SITUA para integração com Job(Loja1115/FRTA020) responsavel por subir a venda para Retaguarda	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRecebe .AND. aRet[1] .AND. !lEmiteNF .AND. cPaisLoc == "BRA"
	RecLock("SL1",.F.)
	REPLACE L1_DOC WITH cDoc

	If cPaisLoc == "ARG"
		REPLACE L1_SERIE WITH Lj7SerArg()
	Else
		If Empty(L1_SERIE)
	   		SerieNfId("SL1",1,"L1_SERIE",dDataBase,LjEspecieNF(),LjGetStation("LG_SERIE"))		
	 	EndIf
	EndIf
	
	If lIsPafNfce
		REPLACE L1_SERPDV 	WITH LjGetStation("LG_SERPDV")		//Numero de fabricação do ECF
		REPLACE L1_KEYNFCE 	WITH cKeyNfce
	Else
		If !lEmitNfce
			REPLACE L1_SERPDV 	WITH LjGetStation("LG_SERPDV")		//Numero de fabricação do ECF
		ElseIf lEmitNFCe .AND. !lUseSat 
			REPLACE L1_KEYNFCE 	WITH cKeyNfce
		EndIf
	EndIf

	// caso estive usando V.A como pdv é gravado l1_situa como '00' para subir a venda so na retaguarda
	If lMVLJPDVPA
		REPLACE L1_SITUA 	WITH "00"
		REPLACE L1_OPERACA  WITH "C"
	ElseIf !lMVLJGRVON .AND. SL1->L1_SITUA <> "OK"
		REPLACE L1_SITUA WITH "RX" //Quando Online, ou seja, conectado no server da Retaguarda, sinaliza que venda deve ser processada pelo GrvBatch
	EndIf

	// Colocada a mesma consistência usada na atribuição da variável nNCCUSADA, onde é atribuido a informação L1_CREDITO.
	// Porém, devido acima ter sido modificada e não estar mais zerando o campo L1_CREDITO, agora, está sendo zerado, após a impressão da NF
	If nOpc == 4 .AND. SL1->L1_RESERVA == "S" .AND. !Empty(SL1->L1_FILRES) .AND. !Empty(SL1->L1_ORCRES) .AND. SL1->L1_CREDITO > 0 
		REPLACE L1_CREDITO  WITH 0	
	EndIf
	
	MsUnlock()
	//Permitir "Startar" o Job após a gravação da Venda
	If !lMVLJGRVON .AND. !lMVLJPDVPA .AND. lRet
		If lMVLJGRVJB
	   		If !lAutoExec
		   		//Verifica vendas pendentes em aberto
		   		aOrcamentos := LJ7OrcPen()
		   		
		   		For nX := 1 To Len(aOrcamentos)
			   		//Executa a gravacao da venda em thread
			   		StartJob("ljGrvJob",GetEnvServer(),.F.,cEmpAnt,cFilAnt, aOrcamentos[nX])
				Next
			Else
				//Executa a gravacao da venda em thread
			   	StartJob("ljGrvJob",GetEnvServer(),.F.,cEmpAnt,cFilAnt, SL1->L1_NUM)
			EndIf 
		Else
			ConOut(STR0111)//"Deve estar configurado o job ljGrvBatch para integracao com as tabelas do ERP")
	    EndIf
    EndIf
EndIf
If !Empty(LOG_TEF)
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', 'Finalização da Gravação Venda - ' + If( lRet, 'S', 'N' ))
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controla o valor subtotal se o Tef ocorreu erro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValSubTot  := 0
EndIf

Lj7RestArea(aArea)

If( SuperGetMV( "MV_LJILVLO",,"2" ) == "1")
	oLJCLocker:ReleaseLock( "LOJA701AILLock" )
	Sleep(300)
 	If !oLJCLocker:GetLock( "LOJA701AILLock" )
	 	If ModType(nModulo) == 'L'
			FinishLoja(.T.)
		EndIf
 		nModulo := 0 // Impede que o final rode o FinishLoja novamente.
 		DbCloseAll() // Fecha todas as tabela para que a carga possa ser efetuada.
		Final(STR0141)	// "O sistema será encerrado, pois foi solicitado a carga de dados nesse terminal."
	EndIF
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7GeraSL ºAutor  ³Vendas Clientes     º Data ³  28/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a gravacao dos arquivos                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7GeraSL( cAlias, aArray, lAppend, lUnlock )
Local cOldAlias := Alias()
Local lRet	    := .T.
Local nX        := 0

//Variaveis para o tratamento dos campos memo do projeto lista de presentes
Local nPosMsmLPre	:= 0	//Codigo da mensagem do Comprador
Local nPosMsgLPre	:= 0	//Mensagem do Comprador
Local nPosRemLPre	:= 0	//Codigo da mensagem do Remetente
Local nPosRevLPre	:= 0	//Mensagem do Remetente

//Variaveis para tratamento de Registro deletado no PAF-ECF
Local lDeleted  	:= .F. 													//Sinaliza que registro deverá ser gravado como deletado, exigência da legislação PAF-ECF
Local cPafMd5		:= ""													//Chave de Validação PAF-ECF
Local lNfPafEcf	  	:= LjNfPafEcf(SM0->M0_CGC)								//Se habilitado CNPJ PAF-ECF

Default lAppend 	:= .F.
Default lUnlock 	:= .T.

DbSelectArea(cAlias)

//Variaveis para o tratamento dos campos memo do projeto lista de presentes
If cAlias == "SL2"
	nPosMsmLPre	:= aScan(aArray,{|x| Alltrim(x[1]) == "L2_MSMLPRE"})
	nPosMsgLPre	:= aScan(aArray,{|x| Alltrim(x[1]) == "L2_MSGLPRE"})
	nPosRemLPre	:= aScan(aArray,{|x| Alltrim(x[1]) == "L2_REMLPRE"})
	nPosRevLPre	:= aScan(aArray,{|x| Alltrim(x[1]) == "L2_REVLPRE"})
EndIf

Begin Transaction

lRet := RecLock(cAlias, lAppend)
If lRet
	For nX := 1 To Len(aArray)
		//As posicoes dos campos MEMO nao serao atualizados por aqui
   		If ((aArray[nX, 1]) <> REG_DELETED) .OR. !lNfPafEcf
			If nX <> nPosMsmLPre .AND. nX <> nPosMsgLPre .AND. nX <> nPosRemLPre .AND. nX <> nPosRevLPre
				&(aArray[nX, 1]) := aArray[nX, 2]
			EndIf
		Else
			lDeleted := .T.
		EndIf
	Next nX

	If cAlias == "SL1" 
		nPosSerie	:= aScan(aArray,{|x| Alltrim(x[1]) == "L1_SERIE"})	
		If nPosSerie > 0 
			SerieNfId("SL1",1,"L1_SERIE",dDataBase,LjEspecieNF(), aArray[nPosSerie, 2] )
		EndIf
	EndIf
	
	If cAlias == "SL2" 		
		nPosSerie	:= aScan(aArray,{|x| Alltrim(x[1]) == "L2_SERIE"})	
		If nPosSerie > 0 
			SerieNfId("SL2",1,"L2_SERIE",,,,SL1->L1_SERIE)			
		EndIf	
	EndIf

	//PAF-ECF: Grava deletado quando item tiver sido armazenado na base
	If lNfPafEcf
		If lDeleted

			If cAlias == "SL2"
				SL2->L2_VENDIDO := "N" //Sinaliza que item foi cancelado no momento que gerou o orçamento/dav
			EndIf

			DbDelete()
	    EndIf

	    //PAF-ECF: Gera chave de validação PAF, coloquei aqui para não precisar editar L1, o campo L1_VLRTOT só é atualizado nesse momento
	    If cAlias == "SL1"
	    	cPafMd5 		:= STxPafMd5(cAlias)
	    	SL1->L1_PAFMD5 	:= cPafMd5
	    ElseIf cAlias == "SL2"
	    	cPafMd5 		:= STxPafMd5(cAlias, SL1->L1_NUMORC)
	    	SL2->L2_PAFMD5 	:= cPafMd5
	    EndIf
	EndIf

	DbCommit()
	If lUnlock
		MsUnLock()
	EndIf
	//Atualiza os campos da mensagem do convidado
	If nPosMsmLPre > 0 .AND. nPosMsgLPre > 0
		//Caso a mensagem esteja em branco e o codigo preenchido exclui o SYP
		If Empty(aArray[nPosMsgLPre, 2]) .AND. !Empty(aArray[nPosMsmLPre,2])
			MSMM(SL2->L2_MSMLPRE,,,,2,,,"SL2","L2_MSMLPRE")
		ElseIf !Empty(aArray[nPosMsgLPre, 2])
			MSMM(SL2->L2_MSMLPRE,,,aArray[nPosMsgLPre, 2],1,,,"SL2","L2_MSMLPRE")
		EndIf
	EndIf

	//Atualiza os campos da mensagem do convidado
	If nPosRemLPre > 0 .AND. nPosRevLPre > 0
		//Caso a mensagem esteja em branco e o codigo preenchido exclui o SYP
		If Empty(aArray[nPosMsgLPre, 2]) .AND. !Empty(aArray[nPosMsmLPre,2])
			MSMM(SL2->L2_REMLPRE,,,,2,,,"SL2","L2_REMLPRE")
		ElseIf !Empty(aArray[nPosMsgLPre, 2])
			MSMM(SL2->L2_REMLPRE,,,aArray[nPosRevLPre, 2],1,,,"SL2","L2_REMLPRE")
		EndIf
	EndIf
EndIf

End Transaction

DbSelectArea(cOldAlias)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³ Fun‡„o    ³ LJ701AtCartao ³ Autor ³Vendas Clientes³ Data ³ 15/06/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Atualiza a descrição da administradora de cartões em uma  ³±±
±±³           ³ transação TEF quando é selecionado um cartão e passado    ³±±
±±³           ³ outro.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Venda Assistida.                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ701AtCartao()
Local nI 	  		:= 0		//controle de loop
Local cCartao 		:= ""
Local lFound  		:= .F.
Local xRet			:= Nil
Local lRetLJ7022 	:= .F.
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

//-- Se o array aTefMult for maior que zero não preciso fazer a alteração por aqui, pois será feito na gravação do SL4.
If Len(aTefMult) > 0
	Return .T.
EndIf

For nI := 1 To Len(aPgtos)
	If !lFtvdVer12
		If ExistBlock("LJ7022")
			lRetLJ7022 := .F.
			xRet := ExecBlock("LJ7022", .F., .F.)
			If ValType(xRet) == "L"
				lRetLJ7022 := xRet
			ElseIf ValType(xRet) == "A"
				lRetLJ7022 := xRet[1]
			EndIf
		EndIf
		If Alltrim(aPgtos[nI,03]) $ _FORMATEF .AND. ! ( If( lRetLJ7022, ;
		                                                  Upper(Alltrim(aTefDados[01,08])) $ Upper(Alltrim(SubStr(aPgtos[nI,04,05], 7))), ;
		                                                  Upper(Alltrim(SubStr(aPgtos[nI,04,05], 7))) == Upper(Alltrim(aTefDados[01,08])) ) )

			cCartao := aPgtos[nI,04,05]
			lFound  := .T.
			Exit
		EndIf
	ElseIf lFtvdVer12
		If Alltrim(aPgtos[nI,03]) $ _FORMATEF .AND. ! ( If( ExistBlock("FTVD7022") .AND. ExecBlock("FTVD7022", .F., .F.), ;
	                                                  Upper(Alltrim(aTefDados[01,08])) $ Upper(Alltrim(SubStr(aPgtos[nI,04,05], 7))), ;
	                                                  Upper(Alltrim(SubStr(aPgtos[nI,04,05], 7))) == Upper(Alltrim(aTefDados[01,08])) ) )

			cCartao := aPgtos[nI,04,05]
			lFound  := .T.
			Exit
		EndIf

	EndIf
Next nI

If lFound
	SAE->(DbSetOrder(1))
	SAE->(DbSeek(xFilial("SAE")))
	While ! SAE->(EOF())
		If Upper(Alltrim(aTefDados[01,08])) == Upper(Alltrim(Left(SAE->AE_DESC, 16)))
			Exit
		EndIf
		SAE->(DbSkip())
	End

	If ! SAE->(EOF())
		aEval(aPgtos, { |x| If( x[03] $ _FORMATEF .AND. x[04,05] == cCartao, ;
		                         x[04,05] := SAE->AE_COD + " - " + SAE->AE_DESC, .T. ) })
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7RecTribºAutor  ³Vendas Clientes     º Data ³  10/21/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recalculo dos valores totais para atualizacao do orcamento  º±±
±±º          ³e rateio dos itens                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBSERVACAO³Devido a essa funcao ser chamada para recalculo dos orcamen-º±±
±±ºIMPORTANTE³tos que sao finalizados pela funcao "Finaliza Venda" e tam- º±±
±±º          ³bem pela funcao que finaliza os orcamentos gerados pela     º±±
±±º          ³rotina de reservas/pedido, os valores como totais, descontosº±±
±±º          ³acrescimos, devem sempre ser lidos dos arquivos e nao da    º±±
±±º          ³memoria.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7RecTrib( aVlrAcres	, nDescTotal, nFreDesSeg, cLQFrete	 ,;
							lJob		, lEmiteNf	, nVlrAcrsFi, aAcrFin	 ,;
							nValRes  	, nDescontFi, nOpc      , aTaxJuros	 ,;
							nTotICM	    , aDadosCNeg, nTotImpNCM, nTotVLRNCM ,;
							nTotImpFED	, nTotImpEST, nTotImpMUN, nTipo)

Local nVlrDescTot  	:= nDescTotal									// Valor total do desconto
Local nVlrSubTot   	:= 0                                     		// Valor do Subtotal
Local lCondNeg     	:= ( Trim( SL1->L1_CONDPG ) == "CN" )    		// VerIfica se eh condicao negociada
Local nPos         	:= 0                                	    	// Posicao do produto nos itens do MatxFis
Local nPerDescFin  	:= 0                                     		// Percentual do desconto financeiro
Local nPerAcrs  	:= 0                                     		// Percentual do acrescimo financeiro
Local nPercProduto 	:= 0                                     		// Valor em percentual do produto sobre o valor total
Local nVlrNegoc    	:= 0                                     		// Valor da taxa - condicao negociada
Local nVlUnit      	:= 0					                    	// Valor do Item
Local nAcumVlRat   	:= 0                                	    	// Valor acumulado do desconto para que seja
Local nVlrTot 	   	:= 0											// Valor total da venda
Local nSomItens    	:= 0											// Valor da soma dos itens para possiveis rateios
Local aSL1 			:= {}											// Array para gravar as informacoes no SL1
Local aItens		:= {}											// Array auxiliar para controlar os arredondamentos
Local nVlrNCCUnit	:= 0											// Valor da NCC "por item"
Local nVlrDesc		:= 0 											// Valor referente ao desconto financeiro
Local nVlrAcrs		:= 0 											// Valor referente ao acrescimo financeiro
Local nVlrIPI		:= 0											// Valor referente ao IPI
Local nValIPI		:= 0											// Valida IPI
Local nDescTot		:= 0											// Valor do Desconto Total
Local nDescItens	:= 0											// Soma os descontos aplicados nos itens
Local nAuxVlrTot	:= 0											// Variavel auxiliar para o Valor Total
Local nDesct		:= 0											// Acumula desconto proporcional para testar arredondamento
Local nDIfDesc		:= 0											// DIferenca do desconto proporcional
Local nDecVrUnit 	:= TamSx3("L2_VRUNIT")[2]						// Qde de casas decimais no campo L2_VRUNIT
Local nItens		:= 0											// Quantidade de Itens para Rateio
Local nQtdItens		:= 0											// Quantidade de Itens da Venda
Local lPremio       := .F.											// Informa se o item do orcamento faz parte de algum tipo de bonIficacao
Local lDescPg		:= Val(SL1->L1_TIPODES) == 1					// Se o Desconto foi aplicado antes da Condicao de Pgto.
Local nAuxNcc		:= 0											// NCC
Local nDecsAux		:= 2											// Numero de casas decimais
Local lCalcFin		:= (SuperGetMv("MV_CALCFIN",,"M")== "F")  		// Variavel para controle do parametro MV_CALCFIN = [F]inanciado
Local lAtuDesc		:= .T.                                      	// Atauliza o valor do desconto
Local nTotItens     := 0											// Valor total dos itens
Local nSomaAux		:= 0 											// soma do acrescimo rateado
Local nVlrSomAcr	:= 0
Local nVrSomIt		:= 0
Local nMvLjTpDes	:= SuperGetMv( "MV_LJTPDES", , 0 )
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)						// Verifica as filiais da trabalharam com acrescimento separado
Local nSomAcrRnd	:= 0											// Soma acresimos arredondados
Local nSomItRnd		:= 0											// Soma itens arredondados
Local nAcrDifere	:= 0											// Diferenca dos arredondamentos do acrescimo (nSomaAux - nSomAcrRnd)
Local nItDifere		:= 0 											// Diferenca dos arredondamentos dos itens (LJ7Total() - nSomItRnd)
Local lDistrPrCi	:= .F.											// Define o modo de distribuicao da diferença nas parcelas - de cima para baixo ou ao contrario
Local lOrcFilVen   	:= .F.											// Define se o orcamento for RETIRA mas foi gerado de um orçamento PAI contendo RESERVA e RETIRA
Local nDesFinDif    := 0                                        	// Diferenca no valor do desconto financeiro
Local nSomDesFin    := 0                                        	// Soma do desconto financeiro
Local lVAssConc		:= LjVassConc()									// Indica se o cliente utiliza a Vda Assistida Concomitante
Local nValSol		:= 0											// Guarda o valor do ICMS ST do item
Local lCpoTotImp	:= SL2->(ColumnPos("L2_TOTIMP")) > 0        	// Verifica a existencia do campo de Total de Imposto NCM/NBS
Local lCpoImpEnt	:=	.F.									       	// Verifica a existencia dos campos de Impostos por Ente de Tributacao, lei 12741 lei dos impostos
Local lCpoAliqImp 	:= SB1->(ColumnPos("B1_IMPNCM")) > 0        	// Verifica a existencia do campo de Aliq. de Imposto NCM/NBS
Local lCpoAliqSBZ 	:= SBZ->(ColumnPos("BZ_IMPNCM")) > 0        	// Verifica a existencia do campo de Aliq. de Imposto NCM/NBS
Local lBImport		:= .F.
Local xB1ImpNcm		:= Nil 		   							   		// variavel que controla o retorno da função AlqLei2741
Local aAlqLeiTr		:= {}  		       							   	// array com valores da  aliquota retornado pela função fiscal (Lei transparência) 1-Aliq Total|2-Aliq Federal|3-Aliq Estadual|4-Aliq Municipal
Local aArea			:= {}
Local aGrupTrib		:= {} 											// Array para o grupo de tributação caso lHabNovoArred = .T.
Local lEmitNfce		:= LjEmitNFCe()									// Sinaliza se utiliza NFC-e
Local lAutomato 	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local lHabNovoArred := If(!lAutomato .AND. !lJob .AND. !lEmiteNf .AND. !lEmitNfce,GetPvProfString("Arredondamento","Habilita","0",GetClientDir() + "SIGALOJA.INI") == "1", .F.) //Verifica se utiliza o novo arredondamento
Local lValIgual		:= .T.
Local nPercTotal	:= 0                                        	//Percentual total do desconto
Local nVlrDescFi	:= 0											//Percentual do desconto financeiro
Local nDiferencaIt  := 0                                        	//Diferença do item
Local nDescItem 	:= 0 											//Desconto do item
Local nVlrItem 		:= 0											//Valor do Item
Local nPosAux 		:= 0
Local nDifGrupo 	:= 0
Local nMaior 		:= 0
Local nValMaior		:= 0
Local nBasMAliq 	:= 0
Local nTotAliqs		:= 0
Local nAliquota		:= 0
Local nAliqRed		:= 0
Local cSitTrib		:= ""
Local cTpSolCf 		:= ""
Local lAlqLei2741	:= ExistFunc("AlqLei2741")
Local cMvFisCTrb	:= SuperGetMV("MV_FISCTRB",,"1")              	// Define se é tipo GE
Local cMvFisAlCT	:= SuperGetMV("MV_FISALCT",,"3")              	// Define se é tipo GE
Local lMvFisFRas	:= SuperGetMV("MV_FISFRAS",,"T")              	// Define se é tipo GE
Local nNewTotIcm	:= 0
Local nRestAcres	:= 0
Local nDifAcres		:= 0
Local nItem			:= 0
Local lGE			:= LjUP104OK()									// Validação do Conceito Garantia Estendida
Local cCodProGar	:= ""                                           // Produto Garantia
Local nVlrGar 		:= 0                                  			// Valor da garantia
Local cMvLjTGar		:= SuperGetMV("MV_LJTPGAR",,"GE")               // Define se é tipo GE
Local lEntrega		:= .F.											// verifica se a venda tem alguma entrega
Local nVlrEntIt		:= 0											// valor do acrescimo por item
Local nDifValSol	:= 0											// diff do ICMS Solidario, quando ha alteracao na BC (acrescimo ou desconto)
Local nTotValSol	:= 0											// usado no calculo de diferenca da venda abaixo (nItDifere)
Local nAuxJur		:= 0											// valor auxiliar para calculo de juros
Local lMvLjJurCc	:= .F.											// Verifica se o juros da administradora esta ativo
Local cFilReserva	:= ''											//Filial de reserva, quando utilizado reserva em outra filial
Local nL1VALBRUT 	:= 0
Local nNFTotal		:= 0
Local nLj7TDescV	:= 0
Local lMaSUFRAMA	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para eCommerce       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lECommerce 	:= SuperGetMV("MV_LJECOMM",,.F.) .And. (SL1->L1_ECFLAG == "1")
Local cNumLote		:= ""                                           //LR_NRLOTE
Local cLoteCtl      := ""	                                        //LR_LOTECTL
Local nVlAcresUnit  := 0 										    // Valor de acrescimo financeiro por unidade do item .
Local nCent			:= 0.01
Local nCount		:= 0
Local lTemArred		:= .F.
Local lRatFrete		:= .F.											// Indica se há rateio de frete (somente nos casos de L2_ENTREGA ser 1,3
Local nLastDesp     := 0    										//Ultimo registro de despesas
Local nFreteSl2     := 0											//Frete SL2
Local nSegurSl2     := 0											//Seguro SL2
Local nDespeSl2     := 0    										//Despesa SL2		
Local nTotFrete     := 0    										//Totalizador frete
Local nTotSegur     := 0    										//Totalizador seguro
Local nTotDespe     := 0    										//Totalizador despesa
Local nQtdEntre     := 0    										//Quantidade entrega
Local nBaseAcr	    := 0    										//indica o valor base para calculo do acréscimo financeiro
Local nBaseAcrIt	:= 0 											// Base do calculo de acrescimo por item. 
Local lIntegDef	    := Lj701GtInD() .Or. SL1->L1_ORIGEM == "N"  	//Integracao via Mensagem Unica
Local nValAcrs    	:= 0                                        	//Valor do Acrescimo financeiro
Local lFisFound 	:= MaFisFound("NF")
Local nAcresProp    := 0
Local nDescPropT    := 0 											//Valor total do desconto proporcionalizado
Local nAItValIpi	:= 0
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()										//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lL2FECP		:= SL2->(ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0)
Local lL2FECPST     := SL2->(ColumnPos("L2_ALQFCST") > 0 .AND. ColumnPos("L2_VFECPST") > 0)
Local lIsVdaSAT 	:= .F. 											//Indica se eh venda SAT
Local nMaiorVlr 	:= 0 											//Armazena o Maior Valor de Desconto Rateado dentre os itens da venda
Local nItMaiorVl 	:= 0 											//Armazena o numero do item que tem o maior valor de Desconto Rateado dentre os itens da venda
Local nTamValDes 	:= TamSx3("L2_VALDESC")[2]
Local lAbatPNCC		:= SuperGetMV("MV_LJABNCC",,.T.)  				// Caso exista valor de NCC, prioriza o abatimento da mesma, quanto a cond. pagamento.
Local nAbatIss		:= 0											// Valor de abatimento no ISS
Local lAbatIss		:= SL2->(ColumnPos("L2_ABATISS")) > 0			// Verifica a existência do campo L2_ABATISS
Local nFreteRat		:= 0 											//Frete Rateado

Default aVlrAcres	:= {}											// Devera conter o valor do acrescimo por item (proporcionalizado)
Default cLQFrete	:= ""											// Recebe conteudo do campo LQ_TPFRETE 1- CIf 2- FOB
Default nFreDesSeg	:= 0											// Frete + Seguro + Despesas
Default lJob		:= .F.
Default lEmiteNF	:= Iif(lFtvdVer12,.T.,.F.)						// Se esta emitando nota ou cupom
Default nVlrAcrsFi  := 0 											// variavel para calculo de juros sobre valor financiado
Default aAcrFin		:= {}											// array para calculo de juros sobre valor financiado proporcional ao item
Default nValRes 	:= 0
Default nDescontFi 	:= 0
Default nOpc		:= 0											// Tipo de operacao
Default aTaxJuros	:= {0,0,0,0}									//Recebe a porcentagem de juros da administradora
Default nTotICM		:= 0
Default aDadosCNeg	:= {}
DEFAULT nTotImpNCM	:= 0
DEFAULT nTotImpFED	:= 0
DEFAULT nTotImpEST	:= 0
DEFAULT nTotImpMUN	:= 0
DEFAULT nTotVLRNCM 	:= 0
DEFAULT nTipo		:= 1 											// Como o atendimento será gravado -> 1 - Salvar como orcamento | 2 - Salvar como venda - | 3 - Salvar como pedido

//Para integração não deve fazer os recalculos, o adapter LOJI701 já faz os calculos necessários
If lIntegDef
    Return Nil
EndIf

lCpoImpEnt := SL2->(FieldPos("L2_TOTFED")) > 0 .AND. ;
				SL2->(FieldPos("L2_TOTEST")) > 0 .AND. ;
				SL2->(FieldPos("L2_TOTMUN")) > 0       // Verifica a existencia do campo de Total de Imposto NCM/NBS

//Valida se pode usa Taxa Administrativa por Cartão de Crédito
If SuperGetMv("MV_LJJURCC",NIL,.F.) .AND. (aTaxJuros[1] > 0)
	lMvLjJurCc := .T.
EndIf

If Type("nNccUsada") <> "N"
	nNccUsada := 0
Endif

If lFisFound
	lIsVdaSAT := !Empty(MaFisRet(,'NF_SERSAT')) //Verifica se eh venda SAT
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciono os registros e faco o calculo do acrescimo/desconto para     ³
//³a condicao de pagamento selecionada ou acrecimo                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCondNeg
	DbSelectArea( "SE4" )
	SE4->(DbSetOrder( 1 ))
	SE4->(DbSeek( xFilial( "SE4" ) + SL1->L1_CONDPG ))

	nPerDescFin	:= E4_DESCFIN                                    	//Valor do desconto financeiro
	nPerAcrs   	:= E4_ACRSFIN                                    	//Valor do acrescimo financeiro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se houve acrescimo por fator financeiro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SL1->L1_FATOR > 0
		nPerAcrs := ((SL1->L1_FATOR - 1) * 100)
		If nPerAcrs < 0
			nPerAcrs := 0
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se trabalhar com o conceito de acrescimo separado, ³
	//³nao grava o acrescimo no valor do cupom, pois o    ³
	//³mesmo sera gravado no Contas a receber (SE1)       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVerEmpres .OR. !ChkIncICMS()
		nPerAcrs := 0
	Endif

	//Realiza o calculo do valor do desconto Financeiro, caso existir desconto na condicao de pagamento e o valor ainda nao estiver calculado "nDescontFi"
	//Calcula o valor do Desconto Financeiro, baseando-se no percentual.
	If nPerDescFin > 0 .And. nDescontFi == 0 .And. lFisFound
		nNFTOTAL := MaFisRet(,"NF_TOTAL")
		
		If !lJob
			nLj7TDescV := iif(LjNewCalSol(),0,Lj7T_DescV(2))
		Else
			nLj7TDescV := iif(LjNewCalSol(),0,SL1->L1_DESCONT)
		EndIf
	
		If nMvLjTpDes <> 2
            If nNccUsada <= (nNFTOTAL - nLj7TDescV)
                nDescontFi := NoRound( ( ( nNFTOTAL - nLj7TDescV ) * nPerDescFin) / 100, nDecVrUnit )
            EndIf
		Else
          	If nNccUsada <= (nNFTOTAL - nLj7TDescV)
          		nDescontFi := A410Arred( ( ( nNFTOTAL - nLj7TDescV - nNccUsada ) * nPerDescFin) / 100, "D2_DESCON" )
          	EndIf
        EndIf
	EndIf
Else
	nPerAcrs	:= SL1->L1_JUROS
		If !ChkIncICMS()
			nPerAcrs	:= 0
	EndIf
EndIf

If nDescTotal == Nil
	If !lJob
		nVlrDescTot := IIf(lVAssConc, SL1->L1_DESCONT - nDescontFi, Lj7T_DescV(2))
	ElseIf lECommerce
		nVlrDescTot := IIf(lVAssConc, SL1->L1_DESCONT - nDescontFi, 0)
	Else
		nVlrDescTot := SL1->L1_DESCONT - nDescontFi
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o valor total da venda                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4
	nVlrTot	:= If(!lJob,Round(Lj7T_Total( 2 )-nDescontFi, nDecimais),SL1->L1_VLRTOT)
Else
	nVlrTot	:= If(!lJob,Round(Lj7T_Total( 2 ), nDecimais),SL1->L1_VLRTOT)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retiro o SubTotal da Venda. Se for finalizacao da venda de um orcamento³
//³filho pega o valor da funcao Lj7or finalizacao da venda de um orcamento³
//|Soma o valor do desconto ao valor total porque o desconto ja foi       |
//|aplicado ao campo L1_VLRTOT.                                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SL1->L1_ORCRES)
	nVlrSubTot   := SL1->L1_VLRTOT + SL1->L1_DESCONT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o Valor Total da Venda no caso de o aCols possuir produtos com e sem reserva ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTot		 := SL1->L1_VLRTOT + NoRound((SL1->L1_JUROS * SL1->L1_VLRTOT)/100,nDecVrUnit)
ElseIf nValSubTot > 0
	nVlrSubTot := Round(Lj7T_SubTotal( 2 ),nDecimais)
Else
	If lFisFound
		nVlrSubTot   := MaFisRet(,"NF_TOTAL")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciono no 1 item do orcamento para efetuar o rateio dos calculos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL2")
SL2->( DbSetOrder(1) )
SL2->( DbSeek(xFilial("SL2") + SL1->L1_NUM) )

nQtdItens  := 0
nTotItens  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando este orcamento nao for RESERVA mas foi gerado de um orçamento PAI contendo³
//³ RESERVA e RETIRA, deve ser tratado de forma diferenciado am alguns calculos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob .AND. !lMvLjPdvPa .AND. SL1->L1_RESERVA = 'S' .AND. ;
	!EMPTY(SL1->L1_FILRES + SL1->L1_ORCRES) .AND. EMPTY(SL1->L1_PEDRES)
    lOrcFilVen := .T.
EndIf

While !SL2->(Eof()) .AND. xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM

	lPremio		:= !Empty(SL2->L2_PREMIO)

	If lAbatIss
		nAbatIss := SL2->L2_ABATISS
	EndIf
	
   	If !Empty(SL1->L1_FRETE) 
	   	If !Empty(nVlrSubTot)
			nFreteRat := (SL2->L2_VLRITEM / (nVlrSubTot - SL1->L1_FRETE)) * SL1->L1_FRETE
		Else
			nFreteRat :=  SL2->L2_VALFRE
		Endif 
	Endif 

   	If !lPremio
		nSomItens += SL2->L2_VLRITEM + nFreteRat
		nItens ++			// Quantidade de Itens para Rateio
	EndIf

	Aadd(aItens, {	SL2->(Recno()),;          	// [01] Numero do Registro
					SL2->L2_ITEM,;             	// [02] Item da Venda
					SL2->L2_QUANT,;            	// [03] Quantidade
					SL2->L2_VRUNIT,;			// [04] Valor Unitario
					SL2->L2_VLRITEM,;			// [05] Valor do Item
					If(lJob .OR. lOrcFilVen,SL2->L2_DESCPRO,0),;							// [06] Desconto proporcional ao Item
					NoRound((nPerDescFin	*   (SL2->L2_VLRITEM - nVlrDescTot))/100, nTamValDes),;		// [07] Valor do Desconto Financeiro
					0,;							// [08] Valor do Acrescimo Financeiro
					NIL,; 	 	              	// [09] Posicao livre para suo
					lPremio,;					// [10] Premiacao?
					SL2->L2_PRCTAB,;			// [11] Preco de Tabela
					SL2->L2_TES,;				// [12] TES do produto
					SL2->L2_PRODUTO,;			// [13] Codigo do Produto
					SL2->L2_VALDESC,;			// [14] desconto Item
					SL2->L2_VALIPI ,;			// [15] Valor do IPI
					SL2->L2_ENTREGA,;			// [16] Entrega
					0,;							// [17] Total de Impostos NCM/NBS
					SL2->L2_NLOTE,;            	// [18] Lote
					SL2->L2_LOTECTL,;			// [19] LoteCtl
					0,;							// [20] Valor de Imposto Federal
					0,;							// [21] Valor de Imposto Estadual
					0,; 						// [22] Valor de Imposto Municipal
					lTemArred,;				// [23] Indica se sofreu arredondamento ou nao
					nFreteRat,;			// [24] Valor do Frete
					nAbatIss} )					// [25] Valor do abatimento da base de cálculo do ISS

	If SL2->L2_PREMIO <> "1"
		nDescItens += SL2->L2_VALDESC
	ElseIf !lJob
		nDescItens += SL2->L2_VALDESC
    EndIf

	nQtdItens := nQtdItens + 1
	nTotItens += (SL2->L2_PRCTAB * SL2->L2_QUANT) - (SL2->L2_VALDESC + SL2->L2_DESCPRO)

	SL2->(DbSkip())
End

/* Obtemos o valor base que sera usado para calculo do acrescimo financeiro.
 Isso e necessario, pois o acrescimo nao leva em 
 consideracao Frete/Despesa/Seguro/ICMS-ST entre outros*/
If lFisFound
	nBaseAcr := MaFisRet(,"NF_VALMERC") + MaFisRet(,"NF_VALIPI") - (nDescItens + nVlrDescTot)
	IF lAbatPNCC
		nBaseAcr -= nNccUsada
	EndIf 
EndIf

If lJob
	//Recalcula a funcao fiscal
	LjRecalFis(	aItens		, lJob	, lEmiteNF	, nQtdItens,;
				nTotItens	)
				
	If lFisFound .And. !MaFisRet(,"NF_SUFRAMA")
		nVlrSubTot   := MaFisRet(,"NF_TOTAL")
	EndIf
	nVlrNegoc := nVlrTot - ( nVlrSubTot - nVlrDescTot )
EndIf

If lEmitNfce	// Caso seja filho nao deve somar o valor de acrescimo pois já foi somado no pai 
	If lOrcFilVen
		nVlrTot	:= SL1->L1_VLRTOT
		If nPerAcrs > 0	
			nTotItens  += nVlrAcrsFi 	
			nBaseAcr   := nTotItens 			
		EndIf		
	EndIf	
EndIf

If lJob
	nAuxNcc	   := 0
	nDecsAux   := MsDecimais(1)
Else
	nAuxNcc	   := nNccUsada
	nDecsAux   := nDecimais
EndIf

If lFtvdVer12 .AND. nTotICM > 0
	nNFTotal := MaFisRet(,"NF_TOTAL")
EndIf

Lj7Arred(1) // limpa array statico da função de arredondamento
nDiferencaIt:= 0
aArea		:= GetArea()

LjGrvLog(SL1->L1_NUM,"VALOR DE DESCONTO NO TOTAL",nVlrDescTot )

DbSelectArea( "SB1" )
SB1->( DbSetOrder(1) )	//B1_FILIAL+B1_COD

For nPos := 1 to nQtdItens
	xB1ImpNcm := 0
	If SB1->(DbSeek(xFilial("SB1") + aItens[nPos][__PRODUTO] ))
		If lCpoTotImp .AND. lCpoAliqImp    // se existir o campo de aliquota de imposto NCM/NBS
			// nova funcionalidade disponibilizada pelo Fiscal
			If lAlqLei2741

				cNumLote := ""
				cLoteCtl := ""

				If !lJob
					cNumLote := M->LR_NLOTE
					cLoteCtl := M->LR_LOTECTL
				ElseIf Len(aItens[nPos]) > __NLOTE
					cNumLote := aItens[nPos,__NLOTE]
					cLoteCtl := aItens[nPos,__LOTECTL]
				EndIf

				If MaFisFound("IT", nPos)
					xB1ImpNcm := AlqLei2741(SB1->B1_POSIPI,SB1->B1_EX_NCM,Alltrim(MaSBCampo("CODISS")),SA1->A1_EST,SA1->A1_COD_MUN,aItens[nPos][__PRODUTO],nPos,cNumLote,cLoteCtl,cMvFisCTrb,cMvFisAlCT,lMvFisFRas)
				EndIf

			Else
				// mantem o legado Loja
				// Busca na SBZ
				If lCpoAliqSBZ
					xB1ImpNcm := RetFldProd(SB1->B1_COD,"B1_IMPNCM","SB1")
				EndIf

				If  xB1ImpNcm ==0
					xB1ImpNcm := SB1->B1_IMPNCM
				ENdIf

   				If xB1ImpNcm == 0
					If Empty(Alltrim(MaSBCampo("CODISS"))) // eh produto
	    				If !Empty(SB1->B1_POSIPI)
	    					lBImport	:= !(SB1->B1_ORIGEM $ ' 0345')	// se nao for nacional ( Manual IBPT )
	    				 	xB1ImpNcm	:= lj7BuscaImp(SB1->B1_POSIPI,.F.,lBImport,SB1->B1_EX_NCM)
	    				EndIf
	    			Else                    // eh servico
                     lBImport    := !(SB1->B1_ORIGEM $ ' 0345')  // se nao for nacional ( Manual IBPT )
                     xB1ImpNcm   := lj7BuscaImp(,.T.,lBImport,, SB1->B1_COD)
	    			EndIf
	    		EndIf
			EndIf

			If ValType(xB1ImpNcm) == "N"
				aAlqLeiTr := {xB1ImpNcm,0,0,0}
			ElseIf Len(xB1ImpNcm) == 2
               aAlqLeiTr := {xB1ImpNcm[1],0,0,0,xB1ImpNcm[2],0,0,0}	
			Else	
				aAlqLeiTr := aClone(xB1ImpNcm)
			EndIf
               		
    		If Len(aAlqLeiTr) == 4 .OR. !(cMvFisAlCT == "3" .AND. cMvFisCTrb == "2")
    		   If Len(aItens[nPos]) > 15
                  aItens[nPos][__TOTIMP]      :=  aAlqLeiTr[1]  // Soma das aliquotas Federal, Estadual e Municipal
                  aItens[nPos][__TOTIMPFED]   :=  aAlqLeiTr[2]  // Aliquota Federal
                  aItens[nPos][__TOTIMPEST]   :=  aAlqLeiTr[3]  // Aliquota Estadual
                  aItens[nPos][__TOTIMPMUN]   :=  aAlqLeiTr[4]  // Aliquota Municipal
              Else
                  aAdd(aItens[nPos], aAlqLeiTr[1]) // Soma das aliquotas Federal, Estadual e Municipal
                  aAdd(aItens[nPos], aAlqLeiTr[2]) // Aliquota Federal
                  aAdd(aItens[nPos], aAlqLeiTr[3]) // Aliquota Estadual
                  aAdd(aItens[nPos], aAlqLeiTr[4]) // Aliquota Municipal
              EndIF    		
    		ElseIf Len(aAlqLeiTr) == 8 //Por conta de alteração feita pelo Fiscal nos fontes FISXFUN e SPEDNFE, caso o array aAlqLeiTr contenha posição da 5 a 8, logo nestas posicoes ja estiram os valores dos impostos calculados 
    			If Len(aItens[nPos]) > 15
    				aItens[nPos][__TOTIMP]		:=  aAlqLeiTr[5]  // Soma das aliquotas Federal, Estadual e Municipal
    				aItens[nPos][__TOTIMPFED]	:=  aAlqLeiTr[6]  // Aliquota Federal
    				aItens[nPos][__TOTIMPEST]	:=  aAlqLeiTr[7]  // Aliquota Estadual
    				aItens[nPos][__TOTIMPMUN]	:=  aAlqLeiTr[8]  // Aliquota Municipal
    			Else
    				aAdd(aItens[nPos], aAlqLeiTr[5]) // Soma das aliquotas Federal, Estadual e Municipal
    				aAdd(aItens[nPos], aAlqLeiTr[6]) // Aliquota Federal
    				aAdd(aItens[nPos], aAlqLeiTr[7]) // Aliquota Estadual
    				aAdd(aItens[nPos], aAlqLeiTr[8]) // Aliquota Municipal
    			EndIF
    		EndIf	
		EndIf
	EndIf

	//proporcao do Item
	nPercProduto	:= ((aItens[nPos][__VLRITEM] + aItens[nPos][__FRETE]) / nSomItens) * 100
	/*
	Se for Condicao Negociada e a opcao "Calcula o Juros incluindo o valor de Entrada?"
	estiver desabilitada, rateamos o valor da entrada de acordo com o valor do item.
	*/
	If !Empty( aDadosCNeg ) .AND. !aDadosCNeg[1][7]
		nVlrEntIt := Round( (aDadosCNeg[1][3] * ((aItens[nPos][__VLRITEM]) / nSomItens)), nDecsAux )
	EndIf

	//------------------------------------------
	//Calcula o Valor de Desconto Proporcional
	//------------------------------------------
	If lJob .And. !lAutomato .AND. nTipo == 1
		nDescPropT := aItens[nPos][__DESCPRO]
	ElseIf lOrcFilVen // Se for orçamento filho considera os valores do orçamento pai
		nDescPropT := aItens[nPos][__DESCPRO]	
	ElseIf lIsVdaSAT //Se for Venda SAT
		nDescPropT := Round( ( (nVlrDescTot * nPercProduto) / 100 ), 2 )
	Else
		nDescPropT := Lj7Arred(2,1, (nVlrDescTot * nPercProduto) / 100 )
	EndIf		

	If nDescPropT > nMaiorVlr
		nMaiorVlr 	:= nDescPropT 	// Armazena o Maior Valor de Desconto Rateado dentre os itens da venda
		nItMaiorVl 	:= nPos			// Armazena o numero do item que tem o maior valor de Desconto Rateado dentre os itens da venda
	EndIf

	If	!lHabNovoArred
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica a proporcao ref. a cada item da venda                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				      
        If !lOrcFilVen
        	If nMvLjTpDes <> 2
        		nVlUnit := aItens[nPos][__PRCTAB] - Round((nDescPropT + aItens[nPos][__DESCITEM]) / aItens[nPos][__QUANT], nDecVrUnit)
        	Else
        		nVlUnit := aItens[nPos][__PRCTAB] - A410Arred((nDescPropT + aItens[nPos][__DESCITEM]) / aItens[nPos][__QUANT], "LR_VRUNIT")
        	Endif
        Else
			nVlUnit := aItens[nPos][__VRUNIT]
        Endif

		If  nVlUnit < aItens[nPos][__VRUNIT] .AND. nVlUnit <= 0  .AND. nDescPropT > 0
			nDescPropT := nDescPropT - aItens[nPos][__VLRITEM]
			nVlUnit := aItens[nPos][__VRUNIT]
		EndIf 
          
		nValIPI	:= (aItens[nPos][__VALIPI] / aItens[nPos][__QUANT])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica a proporcao ref. a NCC utilizada (a NCC nao deverah entrar no ³
		//³calculo de juros do montante restante.)                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrNCCUnit := Round((nAuxNcc * nPercProduto) / 100, nDecsAux)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checa se o desconto total foi efetuado antes ou depois de informada a  ³
		//³condicao de pagamento. Para os casos de arredontamento da venda.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !aItens[nPos][__PREMIO]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faco a proporcao do desconto no total para cada item da venda          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aItens[nPos][__DESCPRO] == 0
				aItens[nPos][__DESCPRO] := nDescPropT
			EndIf

			If !lOrcFilVen .AND. (lDescPg .OR. AllTrim(SL1->L1_TIPODES) == "0")
				nVlUnit := aItens[nPos][__PRCTAB] - (nDescPropT + aItens[nPos][__DESCITEM]) / aItens[nPos][__QUANT]
			EndIf
		EndIf

		//Incluir no array de acrescimo o item da venda
		Aadd(aVlrAcres, 0)

		If nPerDescFin > 0
			//Calcula o Desconto Financeiro que sera aplicado no Item
			aItens[nPos][__DESCFIN]	:= Lj7Arred (2,2,( ( aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT]) / nSomItens) * nDescontFi )
			nVlUnit := (((nVlUnit * aItens[nPos][__QUANT]) - aItens[nPos][__DESCFIN]) / aItens[nPos][__QUANT])
			If lFtvdVer12 .AND. nTotICM > 0		//Se existir algum item que tenha dedução de ICMS (F4_AGREG="R")
				If MaFisRet(nPos,"IT_DEDICM") > 0
					MaFisAlt("IT_DESCONTO",aItens[nPos][__DESCFIN],nPos)
					nNewTotIcm += MaFisRet(nPos,"IT_DEDICM")
				EndIf
			EndIf
		ElseIf nPerAcrs > 0 .OR. lMvLjJurCc
			If lCalcFin
				aItens[nPos][__ACRSFIN]	:= NoRound(((nVlrAcrsFi / SL1->L1_VLRTOT) * (nVlUnit * aItens[nPos][__QUANT])), nDecVrUnit)
				nVlUnit     			+= NoRound(((nVlrAcrsFi / SL1->L1_VLRTOT) * nVlUnit), nDecVrUnit)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta o array de acrescimo proporcional ao item³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aAcrFin, aItens[nPos][__ACRSFIN])
			Else
				If (SL1->L1_TIPOJUR == 1) .OR. lMvLjJurCc
					
					// -- Calcula o Valor da base de acrescimo individual de cada item
					nBaseAcrIt	:= nBaseAcr * (aItens[nPos][__VLRITEM] / Lj7T_Subtotal(2))
					
					nValAcrs := Lj7Arred(2,3,(((nBaseAcrIt + nValIPI) - nVlrEntIt) * nPerAcrs) / 100 )                                                      
                    
					aItens[nPos][__ACRSFIN] := nValAcrs
                    nVlUnit += nValAcrs / aItens[nPos][__QUANT] 

					If lMvLjJurCc
						//Incidencia da Taxa de Juros para precaver caso haja Acréscimo financeiro proveniente da forma de pagamento
						nAuxJur := NoRound(((aTaxJuros[2] / SL1->L1_VLRTOT) * (nVlUnit * aItens[nPos][__QUANT])), nDecVrUnit)

						aItens[nPos][__ACRSFIN] += nAuxJur

						//Pega o valor da variavel auxiliar pois aItens[x][8] já contem o acrescimo anterior e pode causar erro reaplicando o valor sobre nVlUnit
						nVlUnit	+= NoRound( nAuxJur / aItens[nPos][__QUANT], nDecVrUnit )

						//Soma o juros do cartão nesta variável pois se houver o acrescimo financeiro da forma haverá
						//subtração dos juros e os dados serão gravados errados.
						If nVlrAcrsFi > 0
							nVlrAcrsFi	+= nAuxJur
						EndIf
					EndIf

				ElseIf Type("aAcrescimo") == "A"
					aItens[nPos][__ACRSFIN]	:= Lj7Arred (2,3,  ( (aAcrescimo[1] * nPercProduto)  / 100))
					nVlUnit	+= ( ( aAcrescimo[1] / aItens[nPos][__QUANT] * nPercProduto ) / 100 )
					If lFtvdVer12 .AND. nTotICM > 0		//Se existir algum item que tenha dedução de ICMS (F4_AGREG="R")
						If MaFisRet(nPos,"IT_DEDICM") > 0
							MaFisAlt("IT_DESCONTO",-aItens[nPos][__ACRSFIN],nPos)
							nNewTotIcm += MaFisRet(nPos,"IT_DEDICM")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checa se o desconto total foi efetuado antes ou depois de informada a  ³
		//³condicao de pagamento. Para os casos de arredontamento da venda.       ³
		//³VerIfica tbem se ha desconto financeiro para efetuar a proporcionaliza-³
		//³cao                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Val(SL1->L1_TIPODES) == 2 .AND. (Lj7T_Subtotal(2) - Lj7T_Total(2) > 0) .AND. !aItens[nPos][__PREMIO] .And. aItens[nPos][__DESCPRO] <> nDescPropT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faco a proporcao do desconto no total para cada item da venda          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aItens[nPos][__DESCPRO] := nDescPropT
			nVlUnit := (aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT] - aItens[nPos][__DESCPRO]) / aItens[nPos][__QUANT]
		EndIf
		
		If lFisFound .And. MaFisRet(nPos, "IT_DESCZF") > 0
            nVlUnit -= MaFisRet(nPos, "IT_DESCZF") / aItens[nPos][__QUANT]
        EndIf
        
	    If nVlUnit <> aItens[nPos][__VRUNIT]

			//Atualiza o Valor Total do Item e atualiza a matriz de acrescimo
			aItens[nPos][__VLRITEM]	:= A410Arred(nVlUnit * aItens[nPos][__QUANT],"D2_TOTAL")
			
			nVlUnit := A410Arred(nVlUnit,"L2_VRUNIT")

			//Atualiza o Valor Unitario do Item
			aItens[nPos][__VRUNIT] := nVlUnit
		Else
			nVlUnit := A410Arred(nVlUnit,"L2_VRUNIT")
		EndIf

		If lFisFound .And. !lCalcFin .And. MaFisRet(nPos,"IT_VALSOL") > 0 .And.;
		 	!(Posicione("SF4", 1, xFilial("SF4") + aItens[nPos][__TES], "F4_INCSOL") $ "A,N,D")
		 	                                                                             
			nAcresProp := 0
			
            //Calcula Acrescimo proporcional do icms solidario	            
            If nVlrAcrsFi > 0 .And. nPerAcrs > 0
                nAcresProp := Lj7Arred(2, 3, MaFisRet(nPos,"IT_VALSOL") * nPerAcrs / 100)
	        EndIf
	        
	        aItens[nPos][__VLRITEM] += nAcresProp
        EndIf

		//Acumula total dos Itens
		nAcumVlRat	+= aItens[nPos][__VLRITEM]

		//Acumula total do Desconto Proporcional
		nDesct	+= aItens[nPos][__DESCPRO] + aItens[nPos][__DESCFIN]

		aVlrAcres[Len(aVlrAcres)] := aItens[nPos][__ACRSFIN]
	Else

		If nSomItens >= nVlrDescTot
			nPercTotal	:=  NoRound( ((nVlrDescTot + nDescontFi ) / nSomItens) * 100 , nDecsAux )
			nVlrDescFi	:=	Round( (( nDescontFi ) / nSomItens) * 100 , nDecsAux )
		Else
			nPercTotal	:=  NoRound( ((nVlrDescTot + nDescontFi ) / nVlrDescTot) * 100 , nDecsAux )
			nVlrDescFi	:=	Round( (( nDescontFi ) / nVlrDescTot) * 100 , nDecsAux )
		EndIf

		If !lOrcFilVen
			nDescItem	:= Lj7Arred(2,2,((aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT]) * (Lj7T_DESCP(2) /100)))  
		Else 
			nDescItem	:= Lj7Arred(2,2,(nVlrDescTot / nTotItens)  * ( aItens[nPos][__VLRITEM] + aItens[nPos][__VALIPI] - nVlrEntIt  ),"L2_DESCPRO")	 
		EndIf 
		
		nVlrDescFi	:= Round( aItens[nPos][__VLRITEM] * ( nVlrDescFi / 100 ) , nDecsAux)
		nVlUnit := aItens[nPos][__PRCTAB] - A410Arred((nDescPropT + aItens[nPos][__DESCITEM]) / aItens[nPos][__QUANT], "LR_VLRITEM")
		nValIPI		:= aItens[nPos][__VALIPI] / aItens[nPos][__QUANT]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica a proporcao ref. a NCC utilizada (a NCC nao deverah entrar no ³
		//³calculo de juros do montante restante.)                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrNCCUnit := Round((nAuxNcc * ((aItens[nPos][__VLRITEM]) / nSomItens) ), nDecsAux)

		If !aItens[nPos][__PREMIO]
			aItens[nPos][__DESCPRO]:= Lj7Arred(2,1,(nDescItem - nVlrDescFi))
			If !lOrcFilVen .AND. (lDescPg .OR. AllTrim(SL1->L1_TIPODES) == "0")
				nVlUnit := ((((aItens[nPos][__PRCTAB] - (aItens[nPos][__DESCITEM] / aItens[nPos][__QUANT])) * aItens[nPos][__QUANT]) - aItens[nPos][__DESCPRO]) / aItens[nPos][__QUANT])
			EndIf
		EndIf

		//Incluir no array de acrescimo o item da venda
		Aadd(aVlrAcres, 0)

		If nPerDescFin > 0
			//Calcula o Desconto Financeiro que sera aplicado no Item
			aItens[nPos][__DESCFIN]	:= Lj7Arred(2,2, nVlrDescFi )
			nVlUnit := (((nVlUnit * aItens[nPos][__QUANT]) - aItens[nPos][__DESCFIN]) / aItens[nPos][__QUANT])
		ElseIf nPerAcrs > 0 .OR. lMvLjJurCc
			If lCalcFin
				aItens[nPos][__ACRSFIN]	:= Round(((nVlrAcrsFi / SL1->L1_VLRTOT) * (nVlUnit * aItens[nPos][__QUANT])), nDecsAux)
				nVlUnit 				+= Round(((nVlrAcrsFi / SL1->L1_VLRTOT) * nVlUnit), nDecVrUnit)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta o array de acrescimo proporcional ao item³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aAcrFin, aItens[nPos][__ACRSFIN])
			Else
				If (SL1->L1_TIPOJUR == 1) .OR. lMvLjJurCc

					nVlAcresUnit  := ((((nVlUnit + nValIPI) - (nVlrEntIt/aItens[nPos][__QUANT])) * nPerAcrs) / 100)  
					aItens[nPos][__ACRSFIN] := A410Arred((( nVlrAcrsFi * ( aItens[nPos][__VLRITEM] + aItens[nPos][__VALIPI] - nVlrEntIt )) / (nBaseAcr-nVlrEntIt)),"L2_VALACRS") 
					nVlUnit+= nVlAcresUnit

					If lMvLjJurCc
						//Incidencia da Taxa de Juros para precaver caso haja Acréscimo financeiro proveniente da forma de pagamento
						nAuxJur := Lj7Arred (2,3,((( (nVlUnit + nValIPI) - (nVlrEntIt/aItens[nPos][__QUANT]) - (nVlrNCCUnit/aItens[nPos][__QUANT]) ) * aItens[nPos][__QUANT]) * aTaxJuros[1]) / 100)

						//Pega o valor da variavel auxiliar pois aItens[x][8] já contem o acrescimo anterior e pode causar erro reaplicando o valor sobre nVlUnit
						aItens[nPos][__ACRSFIN]	+= nAuxJur

						//Soma o juros do cartão nesta variável pois se houver o acrescimo financeiro da forma haverá
						//subtração dos juros e os dados serão gravados errados.
						If nVlrAcrsFi > 0
							nVlrAcrsFi	+= nAuxJur
						EndIf

						If  aItens[nPos][__QUANT] > 1
							nVlUnit+= Round( (((nVlUnit + nValIPI) - (nVlrEntIt/aItens[nPos][__QUANT]) - (nVlrNCCUnit/aItens[nPos][__QUANT])) * aTaxJuros[1] ) / 100 ,nDecVrUnit)
	 					Else
		 					nVlUnit += nAuxJur
		 				EndIf
		 			EndIf

				ElseIf Type("aAcrescimo") == "A"
					aItens[nPos][__ACRSFIN]	:= Lj7Arred (2,3,  ( (aAcrescimo[1] * nPercProduto)  / 100))
				   	nVlUnit	+= ((aAcrescimo[1] / aItens[nPos][__QUANT] * nPercProduto)  / 100)
				EndIf
			EndIf
		EndIf

		If nDescItem > 0
			//Faz os posicionamentos para que seja possível pegar a Situação Tributária do Item ( função lj7SitTrib )

			DbSelectArea( "SB0" )
			DbSetOrder(1)
			SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))

			DbSelectArea( "SF4" )
			DbSetOrder(1)
			SF4->(DbSeek(xFilial("SF4") + aItens[nPos][__TES] ))

			cSitTrib	:= ""	// Limpa somente cTrib pois só ela será utilizada abaixo
			Lj7Strib( @cSitTrib, @nAliquota, @nAliqRed, cTpSolCf, nPos )

			nPosAux := aScan(aGrupTrib,{|x| AllTrim(x[1]) == AllTrim(cSitTrib)})
			If nPosAux == 0
				aAdd(aGrupTrib, {})
				nPosAux :=	Len (aGrupTrib)
				aAdd (aGrupTrib[nPosAux], cSitTrib					)	 	   	// Tipo Tributacao
				aAdd (aGrupTrib[nPosAux], aItens[nPos][__VLRITEM]	)	 	   	// Valor do item
				aAdd (aGrupTrib[nPosAux], nPos						)	 	   	// Posicao do item
				aAdd (aGrupTrib[nPosAux], nVlUnit					)	 	   	// Valor Maior
				aAdd (aGrupTrib[nPosAux], nDescItem					)	 	   	// Desconto do Grupo
				aAdd (aGrupTrib[nPosAux], nDescItem					)	 	   	// Desconto somando por item
				aAdd (aGrupTrib[nPosAux], aItens[nPos][__ITEM] 	)		 	// Item do Grupo
				aAdd (aGrupTrib[nPosAux], aItens[nPos][__QUANT]	)	 	   	// Desconto somando por item
			Else
				If nVlUnit > aGrupTrib[nPosAux][4]
					aGrupTrib[nPosAux][3] := nPos
					aGrupTrib[nPosAux][4] := nVlUnit
					aGrupTrib[nPosAux][7] := aItens[nPos][__ITEM]
				EndIf
				aGrupTrib[nPosAux][2] += aItens[nPos][__VLRITEM]
				aGrupTrib[nPosAux][5] := NoRound(aGrupTrib[nPosAux][2]*(nPercTotal/100),nDecsAux)  // Desconto no grupo
				aGrupTrib[nPosAux][6] += nDescItem													// Desconto por item
			EndIf
			nDiferencaIt += nDescItem
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checa se o desconto total foi efetuado antes ou depois de informada a  ³
		//³condicao de pagamento. Para os casos de arredontamento da venda.       ³
		//³VerIfica tbem se ha desconto financeiro para efetuar a proporcionaliza-³
		//³cao                                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Val(SL1->L1_TIPODES) == 2 .AND. (Lj7T_Subtotal(2) - Lj7T_Total(2) > 0) .AND. !aItens[nPos][__PREMIO]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faco a proporcao do desconto no total para cada item da venda          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aItens[nPos][__DESCPRO]	:= Round( nDescItem - nVlrDescFi ,nDecVrUnit)
		  	nVlUnit := ((aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT]) - aItens[nPos][__DESCPRO]) / aItens[nPos][__QUANT]
		EndIf
		
		If lFisFound .And. MaFisRet(nPos, "IT_DESCZF") > 0
            nVlUnit -= MaFisRet(nPos, "IT_DESCZF") / aItens[nPos][__QUANT]
        EndIf
        
        If nMvLjTpDes == 2
            nVlUnit := A410Arred(nVlUnit,"L2_VRUNIT")
        EndIf
        
        If nVlUnit <> aItens[nPos][__VRUNIT]									
			//Atualiza o Valor Unitario do Item
			aItens[nPos][__VRUNIT] := nVlUnit
            
            If nMvLjTpDes <> 2
                //Atualiza o Valor Total do Item
                aItens[nPos][__VLRITEM]	:= A410Arred(nVlUnit * aItens[nPos][__QUANT],"L2_VLRITEM")
	        Else	    		    		    	
                //Atualiza o Valor Total do Item
                lTemArred				:= .F.
                aItens[nPos][__VLRITEM]	:= Lj7Arred (2,4, (nVlUnit * aItens[nPos][__QUANT]),@lTemArred)
                aItens[nPos][__ARRED]	:= lTemArred
            EndIf
		EndIf
			    
		//Acumula total dos Itens
		nAcumVlRat	+=	aItens[nPos][__VLRITEM]

		//Acumula total do Desconto Proporcional
		nDesct		+=	nDescItem

		// Atualiza a matriz de acrescimo.
		aVlrAcres[Len(aVlrAcres)] := aItens[nPos][__ACRSFIN]

	EndIf
Next nPos

LjGrvLog(SL1->L1_NUM,"NOVO ARREDONDAMENTO ",lHabNovoArred )

If	lHabNovoArred .AND. (nDesct > 0) .and. !lEmitNfce

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O ECF faz o calculo por grupo de aliquotas , esse loop vai comparar ³
	//³se o desconto aplicado nos itens corresponde ao grupo de aliquotas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lValIgual := .T.
	For nPos := 1 to Len(aGrupTrib)
		nDifGrupo :=  aGrupTrib[nPos][5] - aGrupTrib[nPos][6]
		If nDifGrupo > 0

			nPosAux	:= aScan(aItens,{|x| AllTrim(x[2]) == AllTrim(aGrupTrib[nPos][7])}) // Procura o item de acordo com a posição
			If nPosAux > 0

				nVlrItem  := aItens[nPosAux][__VLRITEM] - nDifGrupo
				nDescItem := aItens[nPosAux][__DESCPRO] + nDifGrupo

				aItens[nPosAux][__VRUNIT] := ( nVlrItem / aGrupTrib[nPos][8])
				aItens[nPosAux][__VLRITEM]:= nVlrItem
				aItens[nPosAux][__DESCPRO]:= nDescItem
			EndIf

			nDiferencaIt  += nDifGrupo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se todos os grupos de aliquotas sao iguais³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aGrupTrib) == 1
			lValIgual := .F.
		ElseIf Len(aGrupTrib) > nPos .AND. lValIgual
			If aGrupTrib[nPos][2] <> aGrupTrib[nPos + 1][2]
				lValIgual := .F.
			EndIf
		EndIf
	Next nPos

	nDiferencaIt := (nVlrDescTot + nDescontFi) - nDiferencaIt

	If nDiferencaIt > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaves com o primeiro grupo de aliquotas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nMaior 		:= 1
		nValMaior   := aGrupTrib[1][2]
		nBasMAliq 	:= 0
		nTotAliqs	:= 0

		If lValIgual .AND. Len(aGrupTrib) > 1
			If aScan(aGrupTrib,{|x| "T" $ x[1] }) > 0
				For nPos := 1 to Len(aGrupTrib)
					If "T" $ aGrupTrib[nPos][1]
						If Val(Substr( aGrupTrib[nPos][1] ,2,2)) > nBasMAliq
							nBasMAliq 	:= Val(Substr( aGrupTrib[nPos][1] ,2,2))
							nMaior 		:= nPos
						EndIf
						nTotAliqs++
					EndIf
				Next

				If nTotAliqs == 1
					nMaior := aScan(aGrupTrib,{|x| "T" $ x[1] })
				EndIf

			ElseIf aScan(aGrupTrib,{|x| "F" $ x[1] }) > 0
				nMaior := aScan(aGrupTrib,{|x| "F" $ x[1] })
			ElseIf aScan(aGrupTrib,{|x| "I" $ x[1] }) > 0
				nMaior := aScan(aGrupTrib,{|x| "I" $ x[1] })
			ElseIf aScan(aGrupTrib,{|x| "N" $ x[1] }) > 0
				nMaior := aScan(aGrupTrib,{|x| "N" $ x[1] })
			EndIf

		Else
			For nPos := 1 to ( Len(aGrupTrib) - 1 )
				If nValMaior < aGrupTrib[nPos + 1][2]
					nMaior 		:= nPos + 1
					nValMaior   := aGrupTrib[nPos + 1][2]
				EndIf
		    Next nI
		EndIf

	    nPosAux := aGrupTrib[nMaior][3]

		nDescItem 	:= aItens[nPosAux][__DESCPRO] + nDiferencaIt
		nVlrItem   	:= aItens[nPosAux][__VLRITEM] - nDiferencaIt

		aItens[nPosAux][__VRUNIT] := ( nVlrItem / aItens[nPosAux][__QUANT])
		aItens[nPosAux][__VLRITEM]:= nVlrItem
		aItens[nPosAux][__DESCPRO]:= nDescItem

		//Acumula total dos Itens
		nAcumVlRat	:= nAcumVlRat - nDiferencaIt

		//Acumula total do Desconto Proporcional
		nDesct	:= 0
		Aeval( aItens, { |x| nDesct+= x[__DESCPRO] } )
	EndIf
EndIf

RestArea( aArea )

For nPos := 1 to Len(aVlrAcres)
	nSomaAux += aVlrAcres[nPos]
Next nPos

If nVlrAcrsFi > 0
	If (lFtvdVer12 .AND. nTotICM == 0) .OR. !lFtvdVer12
		nVlrSomAcr := nVlrAcrsFi - nSomaAux
	ElseIf lFtvdVer12
		nVlrAcrsFi += nNewTotIcm - nTotICM
		nVlrSomAcr := nVlrAcrsFi - nSomaAux
	EndIf
Else
	If nOpc == 4
		nVlrSomAcr := NoRound(nSomaAux, nDecimais) - nSomaAux
	Else
		nVlrSomAcr := nVlrAcrsFi - nSomaAux
	EndIf
EndIf

//Soma no ultimo item, o residuo que restou do acrescimo.
If (Abs(nVlrSomAcr) <= (1/(10 ** nDecsAux))) .Or. (nVlrAcrsFi > 0 .And. nVlrSomAcr <> 0)
	aVlrAcres[Len(aVlrAcres)] += nVlrSomAcr
	aItens[Len(aItens)][__ACRSFIN] := NoRound( ( aItens[Len(aItens)][__ACRSFIN] + nVlrSomAcr ), nDecVrUnit )
	nSomaAux += nVlrSomAcr
EndIf

If nVlrAcrsFi > 0 .AND. Lj7T_DescV(2) == 0
	For nPos := 1 to Len(aItens)
		nVrSomIt += (aItens[nPos][__VLRITEM] + aItens[nPos][__VALIPI])
	Next nPos

	If nVlrAcrsFi > 0 .AND. lFisFound .AND. MaFisRet(,"NF_VALSOL") > 0
		nDifValSol := LjDifVlSol("NF_DESCONTO", -nVlrAcrsFi)
		nValSol    := Lj7IcmsSol() + nDifValSol
	EndIf

	//o valor do ICMS Solidario nao pode ser considerado como acrescimo financeiro
	nVlrSomAcr := Lj7T_Total(2) - (nVrSomIt + nValSol + Lj7CalcFrete(lJob .OR. lOrcFilVen) )

	If nVlrSomAcr <> 0				// Valor da dif entre o total na tela e o somado do rateado no aItens
		nDifAcres := nVlrSomAcr  	// Copia o valor do acrescimo
		If Abs(nVlrSomAcr) > nCent .AND. nDifAcres <= 0.10 	// Se a diferenca for maior que 1 centavo e dentro do limite de protecao de 10 cents
			If nDifAcres < 0		// Se a diferenca for para baixo tira do VlrItem
				nCent := -0.01
			EndIf

			While nDifAcres <> 0 .AND. nCount < 10 		// Tira 1 centavo de cada vez , limitado a 5(protecao)
				nPos := aScan(aItens,{|x|x[__ARRED]}) 	// Procura um item que teve arredondamento
				If nPos > 0 .AND. nDifAcres <> 0		// Se encontrou algum que teve arredondamento
					aItens[nPos][__VLRITEM] := A410Arred(aItens[nPos][__VLRITEM] +nCent,"D2_TOTAL",nMoedaCor)
					aItens[nPos][__VRUNIT]  := aItens[nPos][__VLRITEM] / aItens[nPos][__QUANT]
					aItens[nPos][__ARRED]	:= .F.
					nDifAcres := nDifAcres - nCent
				EndIf
				nCount++
			End
		EndIf
		// Se a diferenca for de 1 cent ou ainda sobrar do rateio de cima joga no ultimo item
		If nDifAcres > 0 .AND. nDifAcres <= 0.10	// Consideramos q se dif for maior q 10 cents nao deve ajustar, pois provavlemente deve ser um problema	e nao uma diferen
			nPos := aScan(aItens,{|x|x[__ARRED]}) 	// Procura algum que foi arredondado para truncar
			If nPos = 0
				nPos := Len(aItens)				// Se nao achar vai no ultimo mesmo
			EndIf
			aItens[nPos][__VLRITEM] := A410Arred( aItens[nPos][__VLRITEM] + nDifAcres,"D2_TOTAL",nMoedaCor)
			aItens[nPos][__VRUNIT]  := aItens[nPos][__VLRITEM] / aItens[nPos][__QUANT]
		EndIf
		nAcumVlRat += nVlrSomAcr
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula a dIferenca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDIfDesc := (nVlrDescTot + nDescontFi ) - nDesct

LjGrvLog(SL1->L1_NUM,"DIFERENÇA DE DESCONTO",nDIfDesc)
LjGrvLog(SL1->L1_NUM,"VALOR DE DESCONTO",nVlrDescTot)

If (nVlrDescTot == nDifDesc) .AND. nVlrDescTot > 0 .AND. lJob
	nDifDesc := 0
	lAtuDesc := .F.
	nDescTot := nVlrDescTot
EndIf

If nDIfDesc <> 0
	If lIsVdaSAT .And. nItMaiorVl > 0
		nPos := nItMaiorVl //Seta o Item que tem o maior valor de Desconto Rateado dentre os itens da venda, para que seja atribuido a diferenca do rateio do desconto total

		aItens[nPos][__DESCPRO] += nDIfDesc
		
		// Se aumentou o desconto entao diminui o valor do item na mesma proporcao
		If !(lEmitNfce .And. lOrcFilVen)
			aItens[nPos][__VLRITEM] -= nDIfDesc
			nAcumVlRat -= nDIfDesc
			
			//Recalcula o valor unitario do item de acordo com o VrTotItem/Qtd
			aItens[nPos][__VRUNIT] := NoRound(aItens[nPos][__VLRITEM] / aItens[nPos][__QUANT], nDecVrUnit)
		EndIf

	ElseIf Abs(nDIfDesc) <= (500/(10**(4)))   //Diferenças maiores de 0,05  não será rateada
		lDistrPrCi := nDIfDesc <= (2 / (10 ** nDecsAux))
		nPos := IIf (lDistrPrCi, nItens, 1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Distribui a dIferenca entre os itens ate que a mesma seja³
		//³eliminada                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (nPos > 0 .And. nPos <= nItens)
			If !aItens[nPos][__PREMIO]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o sistema esteja utilizando 2 casas decimais e a dIferença seja menor    ³
				//³do que isso (por exemplo: 0,008 nao deve proporcionalizar, pois dara dIferenca³
				//³no momento da impressao, e com isso ocorrera erro.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nDIfDesc >= (1 / (10 ** nDecsAux))
					If NoRound((aItens[nPos][__VLRITEM] - nDIfDesc) / aItens[nPos][__QUANT], nDecsAux) < (1 / (10 ** nDecsAux))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o valor do item e' pequeno faz o ajuste deixando 1 centavo no VrUnit³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__VRUNIT] := (1 / (10 ** nDecVrUnit))
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Subtrai da variavel somente a dIferenca que sera ajustada aqui.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nDIfDesc -= (aItens[nPos][__VLRITEM] - (aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT]))
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Adiciona ao desconto proporcional a dIferenca que foi utilizada aqui.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__DESCPRO] += (aItens[nPos][__VLRITEM] - (aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT]))
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Recalcula o valor total do item de acordo com o VrUnit*Qtd³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__VLRITEM] := (aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT])
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o valor do item permite entao faz o ajuste total                    ³
						//³Soma a dIferenca no desconto desse item porque o ajuste sera feito aqui³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__DESCPRO] += nDIfDesc
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se aumentou o desconto entao diminui o valor do item na mesma proporcao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !(lEmitNfce .And. lOrcFilVen)	 
							aItens[nPos][__VLRITEM] -= nDIfDesc
							nAcumVlRat -= nDIfDesc
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Recalcula o valor unitario do item de acordo com o VrTotItem/Qtd³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aItens[nPos][__VRUNIT] := NoRound(aItens[nPos][__VLRITEM] / aItens[nPos][__QUANT], nDecVrUnit)
						EndIf
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Como toda a dIferenca foi utilizada entao zera a variavel para sair do laco (while)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nDIfDesc := 0
					EndIf
				Else // Se a Diferença for negativa
					nDIfDesc := Abs(nDIfDesc) // transf. em absoluto pois o valor será diminuido do desconto e acrescido ao vlr item
	
					If NoRound((aItens[nPos][__VLRITEM] - nDIfDesc) / aItens[nPos][__QUANT], nDecsAux) < (1 / (10 ** nDecsAux))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o valor do item e' pequeno faz o ajuste deixando 1 centavo no VrUnit³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__VRUNIT] := (1 / (10 ** nDecVrUnit))
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Subtrai da variavel somente a dIferenca que sera ajustada aqui.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nDIfDesc -= (aItens[nPos][__VLRITEM] - (aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT]))
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Adiciona ao desconto proporcional a dIferenca que foi utilizada aqui.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__DESCPRO] += (aItens[nPos][__VLRITEM] - (aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT]))
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Recalcula o valor total do item de acordo com o VrUnit*Qtd³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__VLRITEM] := (aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT])
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o valor do item permite entao faz o ajuste total                    ³
						//³Soma a dIferenca no desconto desse item porque o ajuste sera feito aqui³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__DESCPRO] -= nDIfDesc    //aItens[nPos][__DESCPRO] += nDIfDesc
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se aumentou o desconto entao diminui o valor do item na mesma proporcao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__VLRITEM] += nDIfDesc    //aItens[nPos][__VLRITEM] -= nDIfDesc
						nAcumVlRat += nDIfDesc                 //nAcumVlRat -= nDIfDesc
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Recalcula o valor u'nitario do item de acordo com o VrTotItem/Qtd³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aItens[nPos][__VRUNIT] := NoRound(aItens[nPos][__VLRITEM] / aItens[nPos][__QUANT], nDecVrUnit)
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Como toda a dIferenca foi utilizada entao zera a variavel para sair do laco (while)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nDIfDesc := 0
					EndIf
				EndIf
			EndIf
			IIf (lDistrPrCi, nPos --, nPos ++)
		End
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui o valor do Frete,Seguro e Despesas na variavel nAcumVlRat       ³
//³Se lOrcFilVen for TRUE o Frete deve vir do SL1 e nao da Memoria		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAcumVlRat += Lj7CalcFrete(lJob .OR. lOrcFilVen)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui o valor do IPI na variavel nAcumVlRat                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAcumVlRat += If( lFisFound, MafisRet(,"NF_VALIPI"), 0 )
nAcumVlRat := A410Arred(nAcumVlRat,"D2_TOTAL",nMoedaCor)

If nAcumVlRat < nVlrTot
	nValSol		:= MaFisRet(,"NF_VALSOL")
	nAuxVlrTot	:= nVlrTot

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o valor acumulado for dIferente do valor total, verIfica antes no SL4 se o orcamento nao eh com reserva³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL4")
	SL4->( DbSetOrder(1) )	//L4_FILIAL+L4_NUM+L4_ORIGEM
	SL4->( DbSeek(xFilial("SL4")+SL1->L1_NUM) )
	nVlrTot := 0
	While SL4->(!Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM
		nVlrTot	+= SL4->L4_VALOR
		SL4->( DbSkip() )
	End

	//Caso haja juros da taxa administrativa soma pois ele ainda não foi somada nas parcelas com isso
	//gera a subtração do valor dos juros sobre o valor
	If lMvLjJurCc
		nVlrTot	+=	aTaxJuros[2]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o valor continuar a ser menor, mantem o valor TOTAL do retorno da funcao Lj7T_Total() ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nAcumVlRat < (nVlrTot - nValSol)
    	nVlrTot := nAuxVlrTot
    EndIf

	nDIferenca 	:= NoRound( (nVlrTot+nNccUsada - nAcumVlRat - nValSol) / nQtdItens, nDecsAux)
	nResto 		:= ( (nVlrTot+nNccUsada - nAcumVlRat - nValSol) - (nDIferenca * nQtdItens))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Compara o valor do item*qtde baseado no SL2 com o valor gerado na soma do aCols (Arredondado), ³
	//³se dIferente faz o ajuste do arredondamento.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nPos := 1 to nQtdItens
   		If !aItens[nPos][__PREMIO] .AND. aItens[nPos][__VLRITEM] <> Round(aItens[nPos][__VRUNIT] * aItens[nPos][__QUANT], nDecsAux)
			aItens[nPos][__VLRITEM] += nDIferenca
			nAcumVlRat += nDIferenca
			If nResto > 0
				aItens[nPos][__VLRITEM]	+= 0.01
				nResto 			-= 0.01
			EndIf
			aItens[nPos][__VRUNIT] := NoRound(aItens[nPos][__VLRITEM] / aItens[nPos][__QUANT], nDecVrUnit)
		EndIf
	Next nPos
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arredonda o acrescimo dos itens, do mesmo modo que sera gravado na MatxFis	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	For nPos = 1 To Len(aItens)
		nValSol := 0
		//Posiciona TES para verIficar se a apuracao eh pelo bruto ou liquido
		DbSelectArea("SF4")
		SF4->( DbSetOrder(1) )	// F4_FILIAL+F4_CODIGO
		SF4->( DbSeek(xFilial("SF4") + aItens[nPos][__TES]) )
		If !(SF4->F4_INCSOL $ "A,N,D")
			nValSol	+= MaFisRet(nPos,"IT_VALSOL")
		EndIf
		// usado no calculo de diferenca da venda abaixo (nItDifere)
		nTotValSol += nValSol

		If lFtvdVer12 .AND. nTotICM > 0 .And. aItens[nPos,__ACRSFIN] > 0
			nDifAcres  := 0
			nDifAcres  := (A410Arred(aItens[nPos,__ACRSFIN], "F3_VALOBSE") - aItens[nPos,__ACRSFIN])
			nRestAcres += nDifAcres
		EndIf
		aItens[nPos][__ACRSFIN]	:= A410Arred(aItens[nPos,__ACRSFIN], "F3_VALOBSE")
		aVlrAcres[nPos] 		:= aItens[nPos][__ACRSFIN]
		nSomAcrRnd				+= aVlrAcres[nPos]
		nAItValIpi				:= 0
		
		If MaFisRet(,"NF_SUFRAMA")
			nAItValIpi := aItens[nPos][__VALIPI]
		EndIf
		
		nSomItRnd += A410Arred(aItens[nPos,__VLRITEM], "D2_TOTAL") - MaFisRet(nPos,"IT_DEDICM") - MaFisRet(nPos,"IT_VNAGREG") + nAItValIpi
		nSomDesFin+= aItens[nPos][__DESCFIN]

		// Soma o valor da garantia
		If lGE .AND. SuperGetMv("MV_LJIMPGF",,.F.)
            If ( Posicione("SB1",1,xFilial("SB1")+aItens[nPos][__PRODUTO], "B1_TIPO") == cMvLjTGar )
   				nVlrGar += A410Arred(aItens[nPos,__VLRITEM], "D2_TOTAL") - MaFisRet(nPos,"IT_DEDICM") - MaFisRet(nPos,"IT_VNAGREG") + aItens[nPos][__VALIPI] + nValSol
   	  		EndIf

			If AllTrim(aItens[nPos,__ENTREGA]) $ "3/5"
   				lEntrega := .T.
   			EndIf
		EndIf

		If AllTrim(aItens[nPos,__ENTREGA]) $ "1/3/5"
			lRatFrete := .T.
			nLastDesp := nPos //Ultimo registro de despesas
			nQtdEntre ++
		EndIf

	Next nPos

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena a dizima do valor cheio menos o valor arredondado	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLj7TDescV	:= IIf(LjNewCalSol() ,0, Lj7T_DescV(2))
	nNFTotal:= MaFisRet(,"NF_TOTAL")	
	If nMvLjTpDes <> 2
		nAcrDifere := Round(NoRound(nSomaAux, nDecsAux) - nSomAcrRnd, nDecsAux)
	  	nDesFinDif := Round(NoRound(((nNFTOTAL - nLj7TDescV)* nPerDescFin) / 100, nDecVrUnit) - nSomDesFin, nDecVrUnit )
    Else
		If (lFtvdVer12 .AND. nTotICM == 0) .OR. !lFtvdVer12
			nAcrDifere := Round(A410Arred(nSomaAux, "D2_TOTAL") - nSomAcrRnd, nDecsAux)
		Else
			nAcrDifere := Round(A410Arred(nSomaAux + nRestAcres,"D2_TOTAL") - nSomAcrRnd, nDecsAux)
		EndIf
		If nNCCUsada <= (nNFTOTAL - nLj7TDescV)
			nDesFinDif := Round(A410Arred(((nNFTOTAL - nLj7TDescV - nNCCUsada)* nPerDescFin) / 100, "D2_DESCON" ) - nSomDesFin , nDecVrUnit)
		EndIf
	EndIf

	nItDifere := 0
	If !lOrcFilVen
		nItDifere := Round(Lj7T_Total(2) - Lj7CalcFrete(lJob) - (nSomItRnd + nTotValSol + nDifValSol), nDecsAux)
	EndIf

	LjGrvLog(SL1->L1_NUM,"VALOR DE RESERVA",nValRes)
	LjGrvLog(SL1->L1_NUM,"DIFERENÇA DO TOTAL COM A SOMA DOS ITENS",nItDifere)

	If lGE .AND. SuperGetMv("MV_LJIMPGF",,.F.) .AND. nVlrGar > 0 .AND. !lEntrega .And. lOrcFilVen
	 	/* Subtrai o Valor da Reserva + Garantia para calcular
	 	 a diferença correta quando for Orcamento Filho Retira */
   		nItDifere := (nItDifere + nVlrGar) - nValRes
	EndIf

	If lFtvdVer12 .AND. (nDesFinDif <> 0 .Or. nItDifere <> 0)
		For nItem := Len(aItens) To 1 Step -1
			If aItens[nItem][__DESCFIN] > 0
				Exit
			EndIf
		Next nItem
		If nItem == 0
			nItem := Len(aItens)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica ajuste da dizima de acrescimo ou desconto financeiro no ultimo item	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nAcrDifere <> 0 .And. ABS(nAcrDifere) < 0.05
		aItens[Len(aItens)][__ACRSFIN] 	+= nAcrDifere
		aVlrAcres[Len(aItens)] 			+= nAcrDifere
	ElseIf nDesFinDif <> 0 .And. ABS(nDesFinDif) < 0.05
        aItens[Len(aItens)][__DESCFIN] 	+= nDesFinDif
	EndIf

	LjGrvLog(SL1->L1_NUM,"DIFERENÇA NA VENDA",nItDifere)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica ajuste da dizima do valor dos itens no ultimo item	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nItDifere <> 0
		If !lFtvdVer12
			If IIf(!lOrcFilVen,ABS(nItDifere)<0.05,nItDifere<=0.05)
				aItens[Len(aItens)][__VLRITEM] 	+= nItDifere
				aItens[Len(aItens)][__VRUNIT] 	:= A410Arred(aItens[Len(aItens)][__VLRITEM] / aItens[Len(aItens)][__QUANT], "L2_VRUNIT")
			EndIf
		Else
		 	If IIf(!lOrcFilVen,ABS(nItDifere)<0.05,nItDifere<0.05)
				aItens[nItem][__VLRITEM] 	+= nItDifere
				aItens[nItem][__VRUNIT] 	:= A410Arred(aItens[nItem][__VLRITEM] / aItens[nItem][__QUANT], "D2_TOTAL")
				If nPerDescFin <> 0
					aItens[nItem][__DESCFIN] -= nItDifere
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !MaFisRet(,"NF_SUFRAMA")
	//Recalcula a funcao fiscal
	LjRecalFis(	aItens										, lJob		, lEmiteNF	, nQtdItens ,;
				IIf(!lJob,nSomItRnd+nDescontFi,nTotItens)	, lOrcFilVen, nValRes	, IIf (!lJob, nQtdEntre, nQtdItens))
EndIf
LjGrvLog(SL1->L1_NUM,"DEPOIS DO RECALCULO FISCAL")
//Inicializa nValRes para receber total de itens reserva atualizado com descontos proporcionais
nValRes := 0
Begin Transaction

DbSelectArea("SF4")
SF4->(DbSetOrder(1)) // F4_FILIAL+F4_CODIGO

DbSelectArea("SL2")

For nPos := 1 to nQtdItens
	
	SF4->(DbSeek(xFilial("SF4") + aItens[nPos][__TES])) //Posiciona TES para verIficar se a apuracao eh pelo bruto ou liquido 
	SL2->(DbGoto(aItens[nPos][__RECNO])) // Posiciona no Item da Venda

	RecLock("SL2", .F.)

	If lAtuDesc .AND. !lOrcFilVen
		REPLACE L2_VRUNIT  WITH aItens[nPos][__VRUNIT]
		REPLACE L2_VLRITEM WITH aItens[nPos][__VLRITEM]
		REPLACE L2_DESCPRO WITH aItens[nPos][__DESCPRO] + aItens[nPos][__DESCFIN]		//Desconto Total + Desconto Financeiro
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao dos campos do SL2 com o calculo dos impostos retornados   ³
	//³ pela MATXFIS                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If MaFisFound("IT", nPos)
		//Apos a atualizacao, retiro os valores de ISS, ICMS e IPI para atualizacao da base
		REPLACE L2_VALISS  WITH MaFisRet(nPos,"IT_VALISS")
		REPLACE L2_BASEICM WITH MaFisRet(nPos,"IT_BASEICM")
		REPLACE L2_VALICM  WITH MaFisRet(nPos,"IT_VALICM")
		REPLACE L2_VALIPI  WITH MaFisRet(nPos,"IT_VALIPI")
		REPLACE L2_BRICMS  WITH MaFisRet(nPos,"IT_BASESOL")
		REPLACE L2_ICMSRET WITH MaFisRet(nPos,"IT_VALSOL")
		REPLACE L2_CF 	   With MaFisRet(nPos,"IT_CF")

		If SL2->(ColumnPos("L2_ABATISS")) > 0 .AND. aItens[nPos][__ABATISS] > 0
			REPLACE L2_ABATISS WITH aItens[nPos][__ABATISS] 
		EndIf

		/*
		FRETE
		- quando a venda for somente Retira, o valor do frete sera distribuido em todos os itens da venda
		- quando a venda for do tipo mista (retira e outro tipo de entrega), o valor do frete será distribuido
		entre os itens que NAO sao do tipo Retira
		*/
		If ( lRatFrete .AND. SL2->L2_ENTREGA $ "1|3|5" ) .OR. !lRatFrete
			nFreteSl2 := MaFisRet(nPos,"IT_FRETE")   //Armazena valor frete
			nSegurSl2 := MaFisRet(nPos,"IT_SEGURO")  //Armazena valor seguro
			nDespeSl2 := MaFisRet(nPos,"IT_DESPESA") //Armazena valor despesa
			
			//Acumulador despesas
			nTotFrete += nFreteSl2
			nTotSegur += nSegurSl2
			nTotDespe += nDespeSl2
			
			//Tratamento de arredondamento das despesas, maximo para diferenca de 5 centavos
			//Ajusta apenas Venda Assistida e no ultimo registro de entrega/retira posterior
			If !lJob .And. nPos == nLastDesp									
				//Frete
				nItDifere := nTotFrete - SL1->L1_FRETE //Diferenca entre totalizador frete e SL1 
				
				If nItDifere > 0 .And. Abs(nItDifere) <= 0.05 //Acumulado de frete maior que o conteudo armazenado na SL1, necessario diminuir  
					nFreteSl2 -= Abs(nItDifere) 
				ElseIf nItDifere < 0 .And. Abs(nItDifere) <= 0.05 //Acumulado de frete menor que o conteudo armazenado na SL1, necessario aumentar
					nFreteSl2 += Abs(nItDifere)
				EndIf
			
				//Seguro
				nItDifere := nTotSegur - SL1->L1_SEGURO //Diferenca entre totalizador frete e SL1 
				
				If nItDifere > 0 .And. Abs(nItDifere) <= 0.05 //Acumulado de seguro maior que o conteudo armazenado na SL1, necessario diminuir  
					nSegurSl2 -= Abs(nItDifere) 
				ElseIf nItDifere < 0 .And. Abs(nItDifere) <= 0.05 //Acumulado de seguro menor que o conteudo armazenado na SL1, necessario aumentar
					nSegurSl2 += Abs(nItDifere)
				EndIf
			
				//Despesa
				nItDifere := nTotDespe - SL1->L1_DESPESA //Diferenca entre totalizador despesa e SL1 
				
				If nItDifere > 0 .And. Abs(nItDifere) <= 0.05 //Acumulado de seguro maior que o conteudo armazenado na SL1, necessario diminuir  
					nDespeSl2 -= Abs(nItDifere) 
				ElseIf nItDifere < 0 .And. Abs(nItDifere) <= 0.05 //Acumulado de seguro menor que o conteudo armazenado na SL1, necessario aumentar
					nDespeSl2 += Abs(nItDifere)
				EndIf
			EndIf  
			
			REPLACE L2_VALFRE  WITH nFreteSl2
			REPLACE L2_SEGURO  WITH nSegurSl2
			REPLACE L2_DESPESA WITH nDespeSl2
			LjGrvLog(SL1->L1_NUM,"LOGFRET - Soma Rectrib Frete+Seguro+Despesa",nFreteSl2+nSegurSl2+nDespeSl2)
		ElseIf !lJob
			//Se Venda Assistida, item retira e venda possui reserva, zera rateio frete, seguro e despesa dos itens retira
			REPLACE L2_VALFRE  WITH 0
			REPLACE L2_SEGURO  WITH 0
			REPLACE L2_DESPESA WITH 0
		EndIf

		REPLACE L2_VALACRS With aItens[nPos][__ACRSFIN]
		
		If Len(aAlqLeiTr) == 4 .OR. !(cMvFisAlCT == "3" .AND. cMvFisCTrb == "2")      
           If lCpoTotImp
               REPLACE L2_TOTIMP With noRound(((L2_VLRITEM +L2_VALFRE+ L2_SEGURO+ L2_DESPESA) * aItens[nPos][__TOTIMP])/100 ,nDecsAux )
               nTotImpNCM      +=SL2->L2_TOTIMP
               nTotVLRNCM      +=SL2->L2_VLRITEM +L2_VALFRE+ L2_SEGURO+ L2_DESPESA
           EndIf
          
           If lCpoImpEnt       
               REPLACE L2_TOTFED With noRound(((L2_VLRITEM +L2_VALFRE+ L2_SEGURO+ L2_DESPESA) * aItens[nPos][__TOTIMPFED])/100 ,nDecsAux )
               nTotImpFED      +=SL2->L2_TOTFED
    
               REPLACE L2_TOTEST With noRound(((L2_VLRITEM +L2_VALFRE+ L2_SEGURO+ L2_DESPESA) * aItens[nPos][__TOTIMPEST])/100 ,nDecsAux )
               nTotImpEST      +=SL2->L2_TOTEST
    
               REPLACE L2_TOTMUN With noRound(((L2_VLRITEM +L2_VALFRE+ L2_SEGURO+ L2_DESPESA) * aItens[nPos][__TOTIMPMUN])/100 ,nDecsAux )
               nTotImpMUN      +=SL2->L2_TOTMUN
           EndIf
		ElseIf Len(aAlqLeiTr) == 8
    		If lCpoTotImp
    			REPLACE L2_TOTIMP With aItens[nPos][__TOTIMP]
    			nTotImpNCM 		+=SL2->L2_TOTIMP
    			nTotVLRNCM 		+=SL2->L2_VLRITEM +L2_VALFRE+ L2_SEGURO+ L2_DESPESA
    		EndIf
    
    		If lCpoImpEnt  		
    			REPLACE L2_TOTFED With aItens[nPos][__TOTIMPFED]
    			nTotImpFED		+=SL2->L2_TOTFED
    
    			REPLACE L2_TOTEST With aItens[nPos][__TOTIMPEST]
    			nTotImpEST		+=SL2->L2_TOTEST
    
    			REPLACE L2_TOTMUN With aItens[nPos][__TOTIMPMUN]
    			nTotImpMUN		+=SL2->L2_TOTMUN
    		EndIf       
       EndIf    
       		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para o acerto de PIS e COFINS (retencao e apuracao pelo liquido), faz-se necessario alterar           ³
		//³a base de calculo atraves da funcao MAFISALT, visto que valores que sao acrescidos aos itens vendidos,³
		//³sao escolhidos apos ja' ter sido calculado o imposto.                                                 ³
		//³Acerta valores de Cofins, quando retencao ou apuracao pelo liquido                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If (SL2->(ColumnPos("L2_BASECF2"))  > 0 .AND. SL2->(ColumnPos("L2_VALCF2")) > 0);
        	.AND. (SA1->A1_RECCOFI == "S" .OR. SF4->F4_COFBRUT <> "1") .AND. SF4->F4_PISCOF <> "4"
			REPLACE L2_BASECF2 WITH MaFisRet(nPos,"IT_BASECF2")
			REPLACE L2_VALCF2  WITH MaFisRet(nPos,"IT_VALCF2")
	    EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acerta valores de Pis, quando retencao ou apuracao pelo liquido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SL2->(ColumnPos("L2_BASEPS2")) > 0 .AND. SL2->(ColumnPos("L2_VALPS2")) > 0);
			.AND. (SA1->A1_RECPIS == "S" .OR. SF4->F4_PISBRUT <> "1") .AND. SF4->F4_PISCRED <> "3"
			REPLACE L2_BASEPS2 WITH MaFisRet(nPos,"IT_BASEPS2")
			REPLACE L2_VALPS2  WITH MaFisRet(nPos,"IT_VALPS2")
        EndIf
	EndIf
	
	If lL2FECP
		REPLACE L2_ALQFECP WITH MaFisRet(nPos, "IT_ALIQFECP")
		REPLACE L2_VALFECP WITH MaFisRet(nPos, "IT_VALFECP")
	EndIf
	
	If lL2FECPST
        REPLACE L2_ALQFCST WITH MaFisRet(nPos, "IT_ALFCST")
        REPLACE L2_VFECPST WITH MaFisRet(nPos, "IT_VFECPST")	           
	EndIf
	
	SL2->(MsUnlock())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acumula os Descontos / Acrescimos para gravacao do SL1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDescTot += aItens[nPos][__DESCPRO]  					// Desconto Total
	nVlrDesc += aItens[nPos][__DESCFIN]						// Desconto Financeiro
	nVlrAcrs += aItens[nPos][__ACRSFIN]						// Acrescimo Financeiro

	cFilReserva := Posicione("SLJ",1,xFilial("SLJ")+SL2->L2_LOJARES,"LJ_RPCFIL")

	If ( SL2->L2_ENTREGA $ "1|3" ) .OR. (SL2->L2_ENTREGA == "2"	.AND. IIf(!Empty(SLJ->LJ_RPCFIL), SLJ->LJ_RPCFIL <> xFilial("SL1"),.F.)) // Armazena o valor dos itens de reserva
		nValRes += SL2->L2_VLRITEM
	EndIf

  	If lGE .AND. (SuperGetMv("MV_LJIMPGF",,.F.) .AND. !Empty(SL2->L2_GARANT)) .OR. !Empty(cCodProGar)

  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rotina Garantia Estendida para tratamento, se caso seja ³
		//³produto Garantia Estendida, soma o Valor do mesmo aos   ³
		//³totalizadores nValRes de valor de Reserva para constar  ³
		//³no Cupom Não fiscal.                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cCodProGar)
			cCodProGar := SL2->L2_GARANT
	   	ElseIf cCodProGar == SL2->L2_PRODUTO
	   		nValRes += SL2->L2_VLRITEM
	   		cCodProGar := ""
	   	EndIf
   	EndIf
   	
Next nPos

End Transaction

LjGrvLog(SL1->L1_NUM,"DEPOIS DA ATUALIZACAO DO SL2")

If lFisFound
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajuste da gravacao dos dados do SL1 para a venda                                                 ³
	//³                                                                                                  ³
	//³ Exemplo de gravavao dos campos                                                                   ³
	//³ Venda de 1 item de R$100,00 com:                                                                 ³
	//³                          L1_VLRTOT   L1_DESCONT   L1_VLRLIQ   L1_VALBRUT   L1_VALMERC  L1_JUROS  ³
	//³ Acresc.financ de 10%        100.00         0.00      110.00      110.00       100.00      10.00  ³
	//³ Descon.financ de 10%        100.00         0.00       90.00       90.00       100.00       0.00  ³
	//³ Descon.total  de 10%         90.00        10.00       90.00       90.00       100.00       0.00  ³
	//³ Descon.item   de 10%         90.00         0.00       90.00       90.00       100.00       0.00  ³
	//³	                                                                                                 ³
	//³ Obs.1: A gravacao dos campos tem como base a gravacao da Venda Balcao para mantermos             ³
	//³ o legado das customizacoes.                        ³                                             ³
	//³                                                                                                  ³
	//³ Obs.2: Nao eh necessario dar um RecLock no SL1, pois esta preso desde o inicio da rotina         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nVlrIPI     := MaFisRet(,"NF_VALIPI")
	nValSol     := IF(lJob,MaFisRet(,"NF_VALSOL"),nTotValSol)
	nNFTotal	:= MaFisRet(,"NF_TOTAL")
	nLj7TDescV	:= IIf(LjNewCalSol() ,0, nDescTot)
	lMaSUFRAMA	:= MaFisRet(,"NF_SUFRAMA")
	
	DbSelectArea( "SL1" )
	aSL1 := {}
		
	If !lMaSUFRAMA			
		/*Se trabalhar com o conceito de acrescimo separado,
		nao grava o acrescimo no valor do cupom, pois o    
		mesmo sera gravado no Contas a receber (SE1)       */
		If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
			aAdd( aSL1, { "L1_VLRTOT",      SL1->L1_VALMERC - nDescItens - nDescTot + nVlrIPI + nValSol}) 
			aAdd( aSL1, { "L1_VLRLIQ",		SL1->L1_VALMERC + nFreDesSeg - nVlrDesc - nDescTot - nDescItens + nVlrIPI + nValSol })
			nL1VALBRUT := SL1->L1_VALMERC + nFreDesSeg - nVlrDesc - nDescTot - nDescItens + nVlrIPI + nValSol
			aAdd( aSL1, { "L1_VALBRUT",		nL1VALBRUT })
		Else
			aAdd( aSL1, { "L1_VLRTOT",      SL1->L1_VALMERC - nDescItens - nDescTot + nVlrIPI + nVlrAcrs + nValSol}) 
			aAdd( aSL1, { "L1_VLRLIQ",		SL1->L1_VALMERC + nVlrAcrs + nFreDesSeg - nVlrDesc - nDescTot - nDescItens + nVlrIPI + nValSol })
			nL1VALBRUT := SL1->L1_VALMERC + nVlrAcrs + nFreDesSeg - nVlrDesc - nDescTot - nDescItens + nVlrIPI + nValSol
			aAdd( aSL1, { "L1_VALBRUT",		nL1VALBRUT })
		EndIf
		
		aAdd( aSL1, { "L1_BRICMS",  MaFisRet(,"NF_BASESOL") } )
        aAdd( aSL1, { "L1_ICMSRET", nValSol } )
	Else
        aAdd( aSL1, { "L1_VLRTOT",  nNFTotal - nDescItens - nLj7TDescV + nVlrIPI }) 
        aAdd( aSL1, { "L1_VLRLIQ",  nNFTotal + nVlrAcrs + nFreDesSeg - nVlrDesc - nLj7TDescV - nDescItens + nVlrIPI })
        nL1VALBRUT := (MaFisRet(,"NF_VALMERC")) + nVlrAcrs + nFreDesSeg - nVlrDesc - nDescTot - nDescItens + nVlrIPI            
        aAdd( aSL1, { "L1_VALBRUT",     nL1VALBRUT })       
	EndIf			
		
	If lFtvdVer12
	   aAdd( aSL1, { "L1_DESCONT", nDescTot  } )
	EndIf
	
    aAdd( aSL1, { "L1_VALIPI", MaFisRet(,"NF_VALIPI") } )
    aAdd( aSL1, { "L1_VALICM", MaFisRet(,"NF_VALICM") } )
	aAdd( aSL1, { "L1_VALISS", MaFisRet(,"NF_VALISS") } )
	
	Lj7GeraSL( "SL1", aSL1, .F., .F. )
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³L7CriaCxa ³ Autor ³ Vendas Clientes       ³ Data ³ 09/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VerIfica se caixa existe(tratamento multi-moeda).O portador³±±
±±³          ³do titulo(caixa) e definido pela moeda                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := L7CriaCxa(ExpN1,ExpC2,ExpC3,ExpC4)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Moeda do titulo                                    ³±±
±±³          ³ ExpC2 - Codigo do Caixa logado                             ³±±
±±³          ³ ExpC3 - Codigo da agencia do Caixa                         ³±±
±±³          ³ ExpC4 - Codigo da conta do Caixa                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function L7CriaCxa( nMoeda , cCodigo , cAgencia , cConta )

//retiramos o corpo dessa funcao, pois a funcao abaixo eh identica.
LjxDVerCx(nMoeda,cCodigo,cAgencia,cConta)	//LOJXFUND.PRW

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7PrepGrvºAutor  ³Vendas Clientes     º Data ³  09/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara os arrays utilizados na gravacao dos impostos      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7PrepGrvImp()
Local aDadosImps  := {}
Local aImposto    := {}
Local nPosDtTes	  := Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_TES"}) 		// Posicao do Codigo do TES
Local nPosItem		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_ITEM"})][2]		// Posicao do numero do item
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao do Codigo do produto
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
Local nPosVrUnit	:= aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VRUNIT"})][2]		// Posicao do Valor unitario do item
Local nValImp     := 0
Local nValBas     := 0
Local nTotImp     := 0
Local nX          := 0
Local nI 		  := 0
Local nE          := 0
Local nPosCpo     := 0

aImpsSL1 := {}
aImpsSL2 := {}

For nX := 1 To Len(aCols)
	If !aCols[nX][Len(aHeader)+1]
		aDadosImps := TesImpInf(aColsDet[nX][nPosDtTes])
		AAdd(aImpsSL2,{aCols[nX][nPosProd],aColsDet[nX][nPosDtTes],{}})
		For nI := 1 To Len(aDadosImps)
		  	If (nE := Ascan( aImpsSL1,{|x| x[1] == aDadosImps[nI,1]})) == 0
		       	AAdd(aImpsSL1,{aDadosImps[nI][1],"L1_"+Substr(aDadosImps[nI][6],4,7),0,"L1_"+Substr(aDadosImps[nI][8],4,7),0,aDadosImps[nI][3],aDadosImps[nI][9],0})
				nE := Len(aImpsSL1)
		  	EndIf
		    cIndImp := Substr(aDadosImps[nI][2],10,1)
		  	nPosCpo := aScan(aHeaderDet,{|x| Trim(x[2]) == "LR_VALIMP"+cIndImp})
		    nValImp := aColsDet[nX][nPosCpo]
		  	nPosCpo := aScan(aHeaderDet,{|x| Trim(x[2]) == "LR_BASIMP"+cIndImp})
		  	nValBas := aColsDet[nX][nPosCpo]

		   	Lj7GeraImp( @aImposto            , aDadosImps[nI] , nValImp , aCols[nX][nPosQuant] , ;
		   	            aCols[nX][nPosVrUnit], 1              , cIndImp , nValBas               )

		   	AAdd(aImpsSL2[Len(aImpsSL2)][3],aClone(aImposto))
		   	nTotImp += (nValImp * aImposto[10,Val(SubStr(aImposto[5],2,1))])
		   	aImpsSL1[ nE,3 ] += A410Arred(aImpsSL2[len(aImpsSL2)][3][nI][4],"L1_VALIMP1",nMoedaCor)	//Valor do imposto no cabecalho
		   	aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]										//Base do imposto no cabecalho
		   	aImpsSL1[ nE,8 ] += nValImp 				   		   										//Total sem arredondamento
		Next nI
		AAdd(aImpsSL2[Len(aImpsSL2)],aCols[nX][nPosItem])
		AAdd(aImpsSL2[Len(aImpsSL2)],.F.)
	Else
		If !Empty(aCols[nX][nPosProd])
			AAdd(aImpsSL2,{aCols[nX][nPosProd],aColsDet[nX][nPosDtTes],{}})
		EndIf
	EndIf
Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7GeraImpºAutor  ³Vendas Clientes     º Data ³  09/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o array com os dados dos impostos incidentes em um    º±±
±±º          ³ determinado produto                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7GeraImp( aImposto , aInfo, nValImp , nQuant , ;
                     nVlrUnit , nX   , cIndImp ,nValBas )

Local cCpoVlrItem := ""
Local cCpoBaseIte := ""
Local cCpoVlrCab  := ""
Local cCpoBaseCab := ""

cCpoVlrItem := "L2_"+SubStr(aInfo[2],4,7)   //Campo de gravacao do valor do imposto no item
cCpoBaseIte := "L2_"+SubStr(aInfo[7],4,7)   //Campo de gravacao da base do imposto no item
cCpoVlrCab  := "L1_"+SubStr(aInfo[6],4,7)   //Campo de gravacao do valor do imposto no cabecalho
cCpoBaseCab := "L1_"+SubStr(aInfo[8],4,7)   //Campo de gravacao da base do imposto no cabecalho

aImposto := {}                   //Limpa o array para que armazene somente os
 						         //dados do imposto que está sendo calculado

AAdd( aImposto, aInfo[1] )       							//Codigo do imposto
AAdd( aImposto, aInfo[9] )       							//Aliquota do imposto
AAdd( aImposto, nValBas )        							//Base do Imposto
AAdd( aImposto, a410Arred(nValImp,"L2_VALIMP1",nMoedaCor)) 	//Valor do imposto - F1CHI
AAdd( aImposto, aInfo[4] + aInfo[3] + aInfo[5] )   		//FC_INCDUPL/FC_INCNOTA/FC_CREDITA
AAdd( aImposto, cCpoVlrItem )
AAdd( aImposto, cCpoBaseIte )
AAdd( aImposto, cCpoVlrCab )
AAdd( aImposto, cCpoBaseCab )
AAdd( aImposto, {1,-1,0} )
AAdd( aImposto, nQuant )
AAdd( aImposto, nVlrUnit )

Return( Nil )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj7DocsCF ³ Autor ³Vendas Clientes        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para digitacao de documentos para clientes tipo Consu-³±±
±±³          ³ midor Final cuja venda seja superior ao determinado no pa- ³±±
±±³          ³ rametro MV_LIMCFIS                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj7DocsCF()                 							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Assistida (Loc. Argentina)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj7DocsCF(aDadosCF)
Local lRet      := .F.
Local cCbxTpDoc := ""
Local nPosDocCF
Local aTipoDoc  := {}
Local aTipoCI   := {}
Local aAreaSX3  := {}
Local aAreaSX5  := {}
Local aArea     := GetArea()
Local oDlgLojaDocs
Local oTipoDoc
Local oTipoCI
Local aDadosCFPE:= {}

DbSelectArea("SX3")
aAreaSX3 := GetArea()
DbSetOrder(2)
If DbSeek("LS_TPDOCCF")
   cCbxTpDoc  := X3CBox()  //O combo box pode variar de impressora para impressora
EndIf
RestArea(aAreaSx3)

While .T.
   nPosDocCF  := At(";",cCbxTpDoc)
   If !Empty(cCbxTpDoc)
      If nPosDocCF > 0  //Preenche no array aTipoDoc com as opcoes disponiveis
         Aadd(aTipoDoc,Substr(cCbxTpDoc,1,nPosDocCF-1))
      Else //Ultimo elemento
         nPosDocCF  := Len(cCbxTpDoc)
         Aadd(aTipoDoc,Substr(cCbxTpDoc,1,nPosDocCF))
         Exit
      EndIf
      cCbxTpDoc  := Substr(cCbxTpDoc,nPosDocCF+1)
   Else
      Exit
   EndIf
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca os tipos de CI na tabela "OC" do arq. SX5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX5")
aAreaSX5 := GetArea()
If DbSeek(xFilial("SX5")+"OC")
   While xFilial("SX5")+"OC" == SX5->X5_FILIAL+AllTrim(SX5->X5_TABELA)
      If Substr(X5Descri(),4,3) == "CI "
         Aadd(aTipoCI,Substr(X5Descri(),1,2)+"-"+Substr(X5Descri(),4))
      EndIf
      DbSkip()
   End
EndIf
RestArea(aAreaSX5)

DEFINE MSDIALOG oDlgLojaDocs FROM 12, 14 TO 23, 80 TITLE STR0036; //"Dados para Consumidor Final"
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgVA

@ 00.3 , 01 TO 5,31.2 OF oDlgLojaDocs

@ 01.0 , 01.5 SAY STR0037 //"Tipo do Documento"
@ 12.0 , 69.5 MSCOMBOBOX oTipoDoc VAR aDadosCF[2] ITEMS aTipoDoc OF oDlgLojaDocs SIZE 92,40 ON CHANGE Lj7TipoDoc(aDadosCF[2],oTipoCI) PIXEL

//Tipo CI
@ 12.0 , 163  MSCOMBOBOX oTipoCI VAR aDadosCF[3] ITEMS aTipoCI OF oDlgLojaDocs SIZE 82,40 PIXEL
oTipoCI:Hide()

If ExistBlock("LJDocCF")
	aDadosCFPE := {aDadosCF[2],aDadosCF[3],aDadosCF[1],aDadosCF[4],aDadosCF[6]}
	aDadosCFPE := ExecBlock( "LJDocCF", .F., .F., {aDadosCFPE, aTipoDoc, aTipoCI} )

	aDadosCF[2] := aDadosCFPE[1]
	aDadosCF[3] := aDadosCFPE[2]
	aDadosCF[1] := aDadosCFPE[3]
	aDadosCF[4] := aDadosCFPE[4]
	aDadosCF[6] := aDadosCFPE[5]

	Lj7TipoDoc(aDadosCF[2],oTipoCI) //Chama funcao para verificar se ativa ou nao o segundo ComboBox para apresentar o Tipo de Documento CI
EndIf

@ 02.0 , 01.5 SAY STR0038 //"Numero do Documento"
@ 25.0 , 69.5 MSGET aDadosCF[1] RIGHT SIZE 92,10 OF oDlgLojaDocs PIXEL PICTURE PesqPict("SLS","LS_DOCCF") VALID LjVlNumDoc(aDadosCF[1])

@ 03.0 , 01.5 SAY STR0039 //"Nome do Cliente"
@ 37.0 , 69.5 MSGET aDadosCF[4] RIGHT SIZE 175,10 OF oDlgLojaDocs PIXEL

@ 04.0 , 01.5 SAY STR0040 //"Endereco"
@ 49.0 , 69.5 MSGET aDadosCF[6] RIGHT SIZE 175,10 OF oDlgLojaDocs PIXEL


DEFINE SBUTTON FROM 70,103 TYPE 1 ACTION (If(Lj7VldCF(aDadosCF),lRet := .F.,;
(lRet:= .T.,If(aDadosCF[2]<>"6",aDadosCF[3] := "",aDadosCF[3] := Substr(aDadosCF[3],1,2));
,oDlgLojaDocs:End()))) ENABLE OF oDlgLojaDocs

DEFINE SBUTTON FROM 70,136 TYPE 2 ACTION (lRet:= .F.,oDlgLojaDocs:End()) ENABLE OF oDlgLojaDocs

ACTIVATE MSDIALOG oDlgLojaDocs

RestArea(aArea)

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj7VldCF  ³ Autor ³ Vendas Clientes       ³ Data ³ 23/01/04 ³±±
±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VerIfica se todos os dados do Cliente foram digitados na   ³±±
±±³          ³ tela quando Consumidor Final e venda > MV_LIMCFIS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj7VldCF()                 							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Assistida (Loc. Argentina)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj7VldCF(aDadosCF)
Local lRet  := .F.

If ExistBlock("LJVldCF")
	lRet := !ExecBlock( "LJVldCF", .F., .F., { aDadosCF  })
EndIf

If !lRet
	lRet := Empty(aDadosCF[2]) .OR. Empty(aDadosCF[1]) .OR. Empty(aDadosCF[4]) .OR. Empty(aDadosCF[6])
EndIf

If lRet
	lRet := LjVlNumDoc(aDadosCF[1])
EndIf

Return lRet

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj7TipoDoc³ Autor ³ Vendas Clientes       ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tratamento para tipo de documento CI                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj7TipoDoc(cTipoDocCF,oTipoCI)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Assistida (Loc. Argentina)                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj7TipoDoc(cTipoDocCF,oTipoCI)

If cTipoDocCF == "6"  //CI
   oTipoCI:Show()
Else
   oTipoCI:Hide()
EndIf
oTipoCI:Refresh()

Return .T.

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj7SerArg    ³ Autor ³ Vendas Clientes       ³Data  ³29/01/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica a serie da fatura/cupom fiscal dependendo do tipo de   ³±±
±±³          ³ cliente(Loc. Argentina)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj7SerArg()                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 := Serie                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Assistida     									         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7SerArg()
Local cTipoCli	:= ""
Local cSerieDoc	:= ""
Local lIntSynt	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 // Informa se a integracao Synthesis esta ativa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relacao Tipo de Cliente x Serie  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Tipo Cliente      ³ Serie        ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³E(Exportacao)   	 ³ E		    ³
//³F(Cons. Final)    ³ B            ³
//³M(Monotrib.)      ³ B            ³
//³N(Resp.Nao Insc.) ³ B            ³
//³S(Nap Sujeito)    ³ B            ³
//³X(Isento) 	     ³ B            ³
//³I(Inscrito)       ³ A            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("M->LQ_CLIENTE") <> "U" .AND. Type("M->LQ_LOJA") <> "U"
	cTipoCli  := Posicione( "SA1",1,xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA,"SA1->A1_TIPO" )
Else
	cTipoCli  := Posicione( "SA1",1,xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"SA1->A1_TIPO" )
EndIf

If cTipoCli == "E"
   cSerieDoc := "E"
ElseIf cTipoCli $ "F|M|N|S|X"
   cSerieDoc := "B"
Else
   cSerieDoc := "A"
EndIf

If lIntSynt .AND. !Empty(SL1->L1_SERIE)
	cSerieDoc := SL1->L1_SERIE
EndIf

LjGrvLog( "Lj7SerArg", " Integração Synt ", lIntSynt)
LjGrvLog( "Lj7SerArg", " Tipo do Cliente ", cTipoCli)
LjGrvLog( "Lj7SerArg", " Série do Documento ", cSerieDoc)

Return cSerieDoc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ LJ7ImpCH ³ Autor ³  Vendas Clientes      ³ Data ³26/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza impressao do cheque                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ7ImpCH(aImpCheque)
Local nI		:= 0		//controle de loop
Local lTemCH	:= .F.
Local cObs		:= ""
Local cVerso	:= ""
Local cFavorec
Local cCidade
Local cBanco
Local nValor
Local dEmissao
Local cAgencia
Local cConta
Local cCheque

For nI := 1 To Len(aPgtos)
	If AllTrim(aPgtos[nI][3]) == AllTrim(MVCHEQUE)
		lTemCH := .T.
		Exit
	EndIf
Next nI

If lTemCH
	// Em caso do Nome Comercial(SM0->M0_NOMECOM) estar preenchido, o mesmo sera atribuido para impressao da informacao Favorecido.
	cFavorec := If(Empty(SM0->M0_NOMECOM),SM0->M0_NOME,SM0->M0_NOMECOM)
	cCidade  := Left(SM0->M0_CIDCOB,15)
	cCidade  := If(Empty(cCidade), "Sao Paulo", cCidade)
	For nI := 1 To Len(aPgtos)
		If AllTrim(aPgtos[nI][3]) == AllTrim(MVCHEQUE)
			cBanco   := Substr(aPgtos[nI][4][4],1,3)
			nValor   := aPgtos[nI][2]
			If SuperGetMV("MV_DATCHE") == "E"
				dEmissao := dDataBase
			Else
				dEmissao := aPgtos[nI][1]
			EndIf
			cAgencia := aPgtos[nI][4][5]
			cConta   := aPgtos[nI][4][6]
			cCheque  := aPgtos[nI][4][7]
			LjImpCheque( cBanco      ,cAgencia  ,cConta   ,cCheque   ,;
			             @nValor     ,@cFavorec ,@cCidade ,@dEmissao ,;
			             @cObs       ,@cVerso   ,   .F.   ,     nI   ,;
			             @aImpCheque )
		EndIf
	Next nI
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LJ7ConfAdm  ³ Autor ³ Vendas Clientes     ³ Data ³ 16.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a descricao da adiministrada de cartos em uma     ³±±
±±³          ³ transacao TEF, qdo selecionada uma ADM <> da utilizada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA701C                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ7ConfAdm( cAdmUti	, cAdmRet	, lSemRede 	, cFormaCart ,;
					 cIdCartao 	, cTipCart	, nParcelas	, cDescCart	 ,;
					 lTefManual , nNumTrans , lGeraLog	, cRedeRet	 ,;
					 cValorForm , cCodRede  , lSelTefManu)
Local aArea 		:= GetArea()
Local cReturn 		:= ""
Local cAdmVer		:= ""
Local nPos 			:= 0
Local lAdmIgual		:= .T.
Local xRet												// Retorno do Execblock LJ7019
Local lRet			:= .T.
Local nPosAdm		:= 0
Local aTpAdms		:= {}
Local lSelAdm       := SuperGetMv("MV_LJADMFI",,.F.)	// Parametro que desabilita a escolha das administradoras de cartoes, se estiver como .T. INIBE a exibição da tela.
Local aTefInf		:= {}
Local aDadosSae		:= {}      							// Guarda os dados da Adm Financeira
Local nPosSAE		:= 1                        		// Guarda a posicao da Adm FInanceira no array aDadosSae
Local cRetPrior1	:= ""
Local cRetPrior2	:= ""
Local cAdmGeneri	:= Alltrim(SuperGetMV("MV_LJADMGN",,""))
Local lAEREDEAUT	:= SAE->(ColumnPos("AE_REDEAUT")) > 0
Local cBandSITEF	:= ""
Local cDesBandMDE 	:= ""
Local cRedeSITEF	:= ""
Local cDesRedeMDE 	:= ""
Local lPesqNome 	:= .T. 								//Indica se deve pesquisar a Adm. Financeira por nome
Local nParcDe		:= 0
Local nParcAte		:= 0
Local lContinua		:= .T.
Local cIdCard 		:= If(cIdCartao <> Nil, cIdCartao, "")
Local nTamCODSIT 	:= If(lSelAdm,TamSX3("MDE_CODSIT")[1],0)
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()							//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nS			:= 0


Default cAdmRet	:= ""
Default lSemRede := .F.      // Retorno da rede
Default cFormaCart  := ""    // Tipo de forma dos Cartos do oTef
DEFAULT cTipCart  := "" 	 // Tipo do Cartao
DEFAULT nParcelas := 1  	 // Numero de Parcelas
DEFAULT cDescCart := ""
DEFAULT lTefManual	:= .F.
DEFAULT nNumTrans	:= 0 	//Numero correspondente ao ID da transação (identificador da ordem dos cartões).
DEFAULT cRedeRet	:= ""
DEFAULT lGeraLog	:= .F.
DEFAULT cValorForm 	:= ""
DEFAULT cCodRede 	:= ""
Default lSelTefManu	:= .F.

If Type("lAutoExec") == "U"
	lAutoExec := .F.
EndIf

If Len(cAdmUti) == 3
	DbSelectArea("SAE")
	SAE->(DbSetOrder(1))
	SAE->(DbSeek(xFilial("SAE")+cAdmUti))
	cAdmUti := SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))
EndIf

LjGrvLog("", "Administ. Financ. Utilizada:", cAdmUti)
LjGrvLog("", "Administ. Financ. Retornada:", cAdmRet)
LjGrvLog("", "Codigo de retorno Sitef (Bandeira):", cTipCart)
LjGrvLog("", "Codigo de retorno Sitef (Rede):", cCodRede)
LjGrvLog("", "Rede Retornada:", cRedeRet)
LjGrvLog("", "Parcelas:", nParcelas)

If lUsaTEF
	nPosAdm := Ascan(aRetAdmTef,{|x| x[1] == cIdCard .And. x[2] == AllTrim(cFormaCart) })
	If nPosAdm > 0
		cReturn	:= aRetAdmTef[nPosAdm][3] //Retorna a Adm. Financeira ja encontrada/selecionada para este cartao
		lContinua := .F.
	EndIf
Endif

If lContinua
	
	//Tratamento para garantir a seleção correta da administradora financeira ed acordo como número de parcelas//
	If lTefManual .And. lSelTefManu .And. Type("aPgtoSsint") <> "U" .And. Len(aPgtoSsint) > 0
		LjGrvLog("", "Analisando número correto de parcelas", nParcelas)
		For nS := 1 To Len(aPgtoSsint)
			If aPgtoSsint[nS,04] == cIdCartao .And. AllTrim(cFormaCart) == AllTrim(aPgtoSsint[nS,01])   
				nParcelas := aPgtoSsint[nS,02]
				Exit 		
			EndIf
		Next nS
		LjGrvLog("","O número correto de parcelas é: ", nParcelas)
	EndIf

	lRet	:= .F.
	nPos := ( At(" - ", cAdmUti) + 3 )
	cAdmVer := AllTrim(Upper(SubStr(cAdmUti, nPos)))  //-- Administradora selecionada pelo usuário.
	cAdmRet := Alltrim(Upper(cAdmRet))                //-- Administradora retornada pelo TEF (que realmente foi utilizada).

	If ExistBlock("LJ7022") .AND. !lFtvdVer12
		xRet := ExecBlock("LJ7022", .F., .F.,{cAdmVer,cAdmRet,nNumTrans,cRedeRet,cCodRede,cFormaCart,nParcelas})                                          // PE para verificar qual sera o tipo de comparacao
		If ValType(xRet) == "L"
			lRet := xRet
		ElseIf ValType(xRet) == "A"
			lRet 		:= xRet[1]
			cAdmRet 	:= xRet[2]

			If Len(xRet) > 2
				cReturn := xRet[3]

				//Validacao para verificar se o codigo da Adm. Financ. retornada existe
				DbSelectArea("SAE")
				SAE->(DbSetOrder(1))
				If !SAE->(DbSeek(xFilial("SAE")+Left(cReturn,TamSx3("AE_COD")[1])))
					cReturn := "" //Caso nao encontre a Adm Financ. Retornada pelo P.E., limpa a variavel, para que seja feita a busca da Adm. Financ. na tabela SAE
				EndIf
			EndIf

			If Len(xRet) > 3 //Protecao, versao anterior do PE nao estava previsto posicao 4
				cRedeRet:= xRet[4]
			EndIf
		EndIf

		lAdmIgual := (cAdmRet $ cAdmVer) .AND. (cRedeRet $ cAdmVer)

	ElseIf !lFtvdVer12
		lAdmIgual := (cAdmRet $ cAdmVer) .AND. (cRedeRet $ cAdmVer)
	EndIf

	If ExistBlock("FTVD7022") .AND. lFtvdVer12
		xRet := ExecBlock("FTVD7022", .F., .F.)			// PE para verificar qual sera o tipo de comparacao
		If ValType(xRet) == "L"
			lRet := xRet
		EndIf
		If lRet
	 		lAdmIgual := (cAdmRet $ cAdmVer)
		Else
	 		lAdmIgual := (cAdmVer == cAdmRet)
	 	EndIf
	ElseIf lFtvdVer12
		lAdmIgual := (cAdmRet $ cAdmVer) .And. (cRedeRet $ cAdmVer)
	EndIf

	If !lAdmIgual .And. Empty(cReturn)
		If lSelAdm .And. cTipTef == TEF_CLISITEF //Busca pelo codigo de retorno do SITEF
		   LjGrvLog("", "Busca pelo codigo de retorno do SITEF",lSelAdm  )
			DbSelectArea("SAE")
			SAE->(DbSetOrder(1))  
			SAE->(DbSeek(xFilial("SAE")))		
			While !SAE->(Eof()) .AND. SAE->AE_FILIAL == xFilial("SAE")

				nParcDe		:= If(SAE->AE_PARCDE==0,1,SAE->AE_PARCDE)
				nParcAte	:= If(SAE->AE_PARCATE==0,999,SAE->AE_PARCATE)

				If Empty(cFormaCart) .OR. (AllTrim(SAE->AE_TIPO) == AllTrim(cFormaCart))
					If (nParcelas >= nParcDe .AND. nParcelas <= nParcAte)

						DbSelectArea("MDE")
						MDE->(DbSetOrder(1))
						If !Empty(SAE->AE_ADMCART) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_ADMCART ))
							cBandSITEF	:= MDE->MDE_CODSIT 	//Codigo da Bandeira (Retornado pelo SITEF)
							cDesBandMDE := MDE->MDE_DESC	//Descricao da Bandeira
						Else
							cBandSITEF	:= Space(nTamCODSIT)
							cDesBandMDE := ""
						EndIf

						LjGrvLog("", "Busca pelo codigo de retorno do SITEF - AE_ADMCART -cBandSITEF",cBandSITEF  )
						LjGrvLog("", "Busca pelo codigo de retorno do SITEF - AE_ADMCART -cDesBandMDE",cDesBandMDE  )

						If lAEREDEAUT //Controle pela Rede que autorizou a transacao TEF
							If !Empty(SAE->AE_REDEAUT) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_REDEAUT ))
								cRedeSITEF	:= MDE->MDE_CODSIT 	//Codigo da Rede autorizadora da transação TEF (Retornado pelo SITEF)
								cDesRedeMDE := MDE->MDE_DESC	//Descricao da Rede
							Else
								cRedeSITEF	:= Space(nTamCODSIT)
								cDesRedeMDE := ""
							EndIf
						Else
							cRedeSITEF	:= Space(nTamCODSIT)
						EndIf
						LjGrvLog("", "Busca pelo codigo de retorno do SITEF - Controle pela Rede que autorizou a transacao TEF",lAEREDEAUT  )
						LjGrvLog("", "Busca pelo codigo de retorno do SITEF - AE_REDEAUT -cRedeSITEF",cRedeSITEF  )
						LjGrvLog("", "Busca pelo codigo de retorno do SITEF - AE_REDEAUT -cDesRedeMDE",cDesRedeMDE  )

						//Verifica se a Bandeira configurada na Adm. Financeira (AE_ADMCART) esta de acordo com o Codigo da Bandeira retornada pelo SiTEF
						If !Empty(cTipCart) .And. !Empty(cBandSITEF) .And. AllTrim(cTipCart) <> AllTrim(cBandSITEF)
							//Desconsidera este registro, pois a Bandeira Retornada pelo SiTEF eh diferente da Bandeira configurada na Adm. Financeira
							SAE->(DbSkip())
							Loop
						EndIf

						//Verifica se a Rede configurada na Adm. Financeira (AE_REDEAUT) esta de acordo com o Codigo da Rede retornada pelo SiTEF
						If lAEREDEAUT .And. !Empty(cCodRede) .And. !Empty(cRedeSITEF) .And. AllTrim(cCodRede) <> AllTrim(cRedeSITEF)
							//Desconsidera este registro, pois a Rede Retornada pelo SiTEF eh diferente da Rede configurada na Adm. Financeira
							SAE->(DbSkip())
							Loop
						EndIf

						AAdd(aTpAdms, { AllTrim(SAE->AE_TIPO)							,; //01-Tipo (CC,CD,...)
										SAE->AE_COD+" - "+AllTrim(Upper(SAE->AE_DESC))	,; //02-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
										nParcDe											,; //03-Parcela Inicial
										nParcAte										,; //04-Parcela Final
										SAE->AE_ADMCART									,; //05-Codigo Relacionado a tabela MDE para a Bandeira
										cDesBandMDE										,; //06-Descricao da Bandeira (campo MDE_DESC)
										cBandSITEF										,; //07-Codigo da Bandeira(campo MDE_CODSIT)
										SAE->(Recno())									,; //08-Recno SAE
										cRedeSITEF										,; //09-Codigo da Rede (Campo MDE_CODSIT)
										cDesRedeMDE 									}) //10-Descricao da Rede (campo MDE_DESC)

						cReturn := SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))

						//Considera que achou ate este ponto (nao precisa buscar pelo nome) (lPesqNome = .F.),
						//pois pode acontecer de os campos com o código relacionado a bandeira (AE_ADMCART) ou o codigo relacionado a rede (AE_REDEAUT) nao estarem preenchidos, que eh a verificacao feita no IF abaixo
						lPesqNome := .F.

						//Verifica se encontrou a Adm. Financeira exata (Comparando a Bandeira e a Rede configurada na Adm. Financeria com a Bandeira e a Rede retornada pelo SiTEF)
						If !Empty(cTipCart) .And. AllTrim(cTipCart) == AllTrim(cBandSITEF) .And. (!lAEREDEAUT .Or. (!Empty(cCodRede) .And. AllTrim(cCodRede) == AllTrim(cRedeSITEF)))
							lContinua := .F. //Seta a variavel para indicar que nao precisa continuar a busca da Adm. Financeira, pois ja encontrou
							Exit //Se entrou aqui, eh porque encontrou a Adm. Financeira exata, entao abandona o laço
						EndIf

					EndIf

				Endif

				SAE->(DbSkip())
			End
			LjGrvLog("", "Busca pelo codigo de retorno do SITEF =",cReturn  )
		EndIf

		If lPesqNome
			LjGrvLog("", "Busca Administradora Financeira pela Descricao",lPesqNome  )
			//Busca Administradora Financeira pela "Descricao"
			DbSelectArea("SAE")
			SAE->(DbSetOrder(1))
			SAE->(DbSeek(xFilial("SAE")))
			While !SAE->(Eof()) .AND. SAE->AE_FILIAL == xFilial("SAE")
				If Empty(cFormaCart) .OR. (AllTrim(SAE->AE_TIPO) == AllTrim(cFormaCart))
					If (nParcelas >= SAE->AE_PARCDE .AND. nParcelas <= SAE->AE_PARCATE) .OR. (SAE->AE_PARCDE == 0 .AND. SAE->AE_PARCATE == 0)
						//-- Caso encontre a administradora retornada pelo TEF no cad. de administradora ela que será utilizada,
					    //-- caso contrário fica a que o usuário escolheu.
						If AllTrim(Upper(cAdmRet)) $ AllTrim(Upper(SAE->AE_DESC)) .OR. AllTrim(Upper(cAdmRet)) $ AllTrim(Upper(SAE->AE_DESCSE))
							If !Empty(cRedeRet) .AND. (Upper(cRedeRet) $ Upper(SAE->AE_DESC)) .OR. (Upper(cRedeRet) $ Upper(SAE->AE_DESCSE))
								cReturn := SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))
								cRetPrior1 := cReturn
								lAdmIgual	:= .T.
								Exit
								If cTipTEF == TEF_DISCADO
							    	AADD(aDadosSae, {SAE->AE_COD, SAE->AE_DESC } )
								EndIf
							Endif
							cReturn := SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))
							cRetPrior2 := cReturn
						ElseIf (Type("aTEFDados") == "A" .And. Len(aTefDados)>0 .AND. !lTefOk)
							If cTipTEF == TEF_DISCADO .AND. ("REDE " $ AllTrim(Upper(SAE->AE_DESC)) .OR. "CIELO" $ AllTrim(Upper(SAE->AE_DESC)))
						    	AADD(aDadosSae, {SAE->AE_COD, SAE->AE_DESC } )
						    Endif
						ElseIf lUsaTEF 
							If cTipTEF == TEF_NAO_USADO 
								AADD(aDadosSae, {SAE->AE_COD, SAE->AE_DESC } )
							Endif							
						Endif
					EndIf
	           EndIf
				SAE->(DbSkip())
			End
			LjGrvLog("", "Busca Administradora Financeira pela Descricao =",cReturn  )
		EndIf

		If lContinua
		   LjGrvLog("", "lContinua",lContinua  )
			If !Empty(cRetPrior1)
				cReturn := cRetPrior1
			ElseIf !Empty(cRetPrior2)
				cReturn := cRetPrior2
			Endif

			If lSelAdm .AND. !(cTipTEF == TEF_DISCADO .AND. !Empty(cReturn)) .AND. (cTipTEF <> TEF_NAO_USADO)  // No caso do discado nao tem tela de identificação
			    AADD(aTefInf,{.T.,cTipCart,cAdmRet,cFormaCart,nParcelas,cIdCartao,cCodRede})
				cReturn := FR271AdmFin(NIL,NIL,@aTpAdms,NIL,NIL,aTefInf,lTefManual,lSelTefManu)
			ElseIf lSelAdm .AND. cTipTEF == TEF_NAO_USADO .AND. lUsaTEF
				cReturn := LjSelecAdm(nPosSAE, aDadosSae , cReturn, cIdCartao, cFormaCart, cValorForm)				
			Else
				If cTipTEF == TEF_DISCADO .And. Empty(cRetPrior1) .And. Empty(cRetPrior2)
					If Len(aDadosSae) > 0 .AND. (Empty(cAdmRet) .OR. !lAdmIgual)
						If Empty(cAdmGeneri) .OR. (cAdmRet == "" .AND. cRedeRet =="")
							cReturn 	:= LjSelecAdm(nPosSAE, aDadosSae , cReturn, cIdCartao, cFormaCart, cValorForm)
						Else
							DbSelectArea("SAE")
							SAE->(DbSetOrder(1))  
							If SAE->(DbSeek(xFilial("SAE")+cAdmGeneri))
								cReturn	:= SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))
							EndIf
						EndIf
					ElseIf Len(aDadosSae) == 1
						cReturn := aDadosSae[1][1] + " - " + aDadosSae[1][2]
					Endif
				EndIf
	        EndIf
	        LjGrvLog("", "lContinua",cReturn  )
		EndIf
   	EndIf

	lSemRede := Empty( Alltrim(cReturn) )

	If lSemRede
		cReturn := cAdmUti
	EndIf

	AADD(aRetAdmTef,{cIdCard,AllTrim(cFormaCart),cReturn})  // Adiciona o ID e a Adm do cartao
EndIf

RestArea(aArea)
LjGrvLog("", "Retorno da funcao:", cReturn)
Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CliCRD ºAutor  ³Vendas Clientes     º Data ³  30/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Selecao do cliente para integracao com SIGACRD             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj7CliCRD()   											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Se cliente encontrado na base de dados                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CliCRD()
Local aAreaSA1      := SA1->(GetArea())   // Area do Arquivo de Cliente
Local aRetCart      := {}                 // Contem o tipo e numero do documento do cliente da venda
Local aDadosCli     := {}                 // Contem numero do cartao, CNPJ/CPF, codigo e loja do cliente selecionado
Local lCliente 		:= .T.                // Indica se o cliente foi encontrado na base
Local lRet          := .T.               // Define se prossegue a operacao
Local cTpFrete := "" //Tipo do Frete
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg	:= Iif(lFtvdVer12,"FATA701","LOJA701")	//Nome da Rotina

aDadosCli     := {Space(TamSX3("MA6_NUM")[1]),;    //Numero do cartao
                  Space(TamSX3("A1_CGC")[1]),;     //CNPJ/CPF do cliente
                  Space(TamSX3("A1_COD")[1]),;     //Codigo do cliente
                  Space(TamSX3("A1_LOJA")[1])}     //Loja do cliente


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da tela para selecao do CNPJ/CPF ou numero ³
//³do cartao Private Label                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet  := CrdIdentCli(  @aRetCart  ,@aDadosCli  ,@lCliente  ,.T.  ,;
                        NIL        ,NIL )
If lRet
	If !lCliente
		aCrdCliente[2] := aDadosCli[1]  //Numero do cartao
	 	aCrdCliente[1] := aDadosCli[2]  //CNPJ/CPF
	    M->LQ_CLIENTE  := aDadosCli[3]  //Codigo
	    M->LQ_LOJA     := aDadosCli[4]  //Loja
	  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  	//³Executa os gatilhos dos campos e as validacoes necessarias³
	 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  	If ExistTrigger("LQ_CLIENTE")
	    	RunTrigger(1,Nil,Nil,,"LQ_CLIENTE")
	  	EndIf
	  	If ExistTrigger("LQ_LOJA")
	    	RunTrigger(1,Nil,Nil,,"LQ_LOJA")
	  	EndIf
	    	Lj7ValCli(.F.)
		If !(MaFisFound("NF"))
			cTpFrete := Lj7TpFrete(M->LQ_CLIENTE,M->LQ_LOJA)
			cTpFrete	:= IIf( Empty(cTpFrete) .And. (M->LQ_TPFRET == "S" .OR. M->LQ_TPFRET == "0"), "S", cTpFrete)

	    	MaFisIni( M->LQ_CLIENTE, M->LQ_LOJA, "C", "S",;
	    			 Nil, Nil, Nil, .F.,;
	    			 "SB1", cNomeProg, NIL, NIL,;
		             NIL           , NIL         , NIL ,  NIL , ;
		             NIL           , NIL         , NIL ,  lCalcIPI ,;
		             NIL           , NIL         , NIL ,  NIL , ;
		             NIL				, cTpFrete)

			LjSatMxFis()
	  	EndIf

	Else
    	If aRetCart[1] == 3  //CPF/CNPJ
 			MsgStop(STR0059)   //"Cliente nao encontrado com o numero de documento digitado."
    	EndIf
 		RestArea(aAreaSA1)
   EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7AprovCRºAutor  ³Vendas Clientes     º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Solicitar a confirmacao e cancelamento da analise de creditoº±±
±±º          ³do cliente                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Lj7AprovCRD(ExpC1, ExpC2, ExpN3, ExpL4, ExpN5, ExpC6, ExpL7)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Tipo da transacao                                  º±±
±±º          ³ 		   "1" - solicitacao da analise de credito            º±±
±±º          ³ 		   "2" - confirmacao da transacao                     º±±
±±º          ³ 		   "3" - cancelamento da transacao                    º±±
±±º          ³ ExpC2 - Numero do contrato                                 º±±
±±º          ³ ExpN3 - Valor da venda                                     º±±
±±º          ³ ExpL4 - Confirma a transacao?                              º±±
±±º          ³ ExpN5 - Valor financiado                                   º±±
±±º          ³ ExpC6 - VerIfica se deve realizar analise de credito, consiº±±
±±º          ³dera o modulo e o processo(operacao)  					  º±±
±±º          ³ ExpL7 - Modo de consulta?                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ *** Transacao "1" ***                                      º±±
±±º          ³aRet[1] - Retorno da Funcao                                 º±±
±±º          ³              0 - Aprovado                                  º±±
±±º          ³              1 - Nao aprovado                              º±±
±±º          ³              2 - Aprovado Off-line                         º±±
±±º          ³              3 - Rejeitado                                 º±±
±±º          ³              4 - Fila crediario                            º±±
±±º          ³aRet[2] - Valor do limite de credito do cliente             º±±
±±º          ³aRet[3] - Valor dos titulos em aberto do cliente            º±±
±±º          ³aRet[4] - Numero do contrato de credito                     º±±
±±º          ³aRet[5] - Indica se a venda foi rejeitada                   º±±
±±º          ³                                                            º±±
±±º          ³ *** Transacao "2" ***                                      º±±
±±º          ³aRet[1] - 0                                                 º±±
±±º          ³aRet[2] - Array com dados do contrato de financiamento      º±±
±±º          ³                                                            º±±
±±º          ³ *** Transacao "3" ***                                      º±±
±±º          ³aRet[1] - 0                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7AprovCRD(	cTransacao,		cNumContra,		nVlrVenda,	lConfCRD,;
						nValorFin,		cModOper,		lModoCons)

Local aRetCrd     := {}                  // Retorno da funcao
Local aDadosCrd   := {}                  // Dados para a analise de credito
Local aProdCrd    := {}                  // Produtos da venda
Local aParcCrd    := {}                  // Parcelas do financiamento
Local aParcVda    := {}                  // Parcelas da venda
Local nI          := 0					 // Variavel do loop
Local nX 	      := 0                   // Variavel do loop
Local nPosItem    := GdFieldPos("LR_ITEM")		// Posicao do item no aHeader
Local nPosCod     := GdFieldPos("LR_PRODUTO")	// Posicao do codigo do produto no aHeader
Local nPosDescri  := GdFieldPos("LR_DESCRI")	// Posicao da descricao do produto no aHeader
Local nPosQuant   := GdFieldPos("LR_QUANT")		// Posicao da quantidade no aHeader
Local nPosUnit    := GdFieldPos("LR_VRUNIT")	// Posicao do valor unitario no aHeader
Local nPosTotal   := GdFieldPos("LR_VLRITEM")	// Posicao do valor do item no aHeader
Local nTamSAE     := TamSx3("AE_COD")[1] // Tamanho do campo AE_COD
Local nMoedaParc  := 1                   // Moeda da parcela
Local nTpVenda    := 1                   // 1-Venda Normal 2-Venda forcada
Local lCheque     := .F.                 // Indica se a parcela e cheque
Local cRespForcada := ""                  // Responsavel pela venda forcada
Local cMV_CLIPAD   := PadR(SuperGetMV("MV_CLIPAD"),TAMSX3("LQ_CLIENTE")[1])		// Cliente padrao
Local cMV_LOJAPAD  := PadR(SuperGetMV("MV_LOJAPAD"),TAMSX3("LQ_LOJA")[1])			// Loja do cliente padrao

Default cNumContra 	:= ""
Default lConfCRD   	:= .F.
Default nValorFin  	:= 0
Default cModOper   	:= "XX"
Default lModoCons  	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for Cliente Padrao, inicializa o array aCrdCliente para forcar a tela de identIficacao do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMV_CLIPAD+cMV_LOJAPAD == M->LQ_CLIENTE+M->LQ_LOJA
	aCrdCliente  := {"", ""}
EndIf

For nI := 1 to Len(aPgtos)
	lCheque := AllTrim(aPgtos[nI][3]) == "CH"
	If cPaisLoc == "BRA"
		nMoedaParc  := 1
	Else
		nMoedaParc  := aPgtos[nI][6]
	EndIf
	If Len(aPgtos[nI][4]) > 0
		Aadd(	aParcVda,{aPgtos[nI][1],;																				//Data de vencimento
				aPgtos[nI][2],;																							// Valor da parcela
				aPgtos[nI][3],;																							// Forma de pagamento
				If(AllTrim(aPgtos[nI][3])<> "FID",(Substr(aPgtos[nI][4][5],1,nTamSAE)),""),;							// Codigo da Administradora (Ignora se for cartao fidelidade)
				If(lCheque,aPgtos[nI][4][7],If(AllTrim(aPgtos[nI][3])== "FID",aPgtos[nI][4][1],aPgtos[nI][4][4])),;	// Numero do cartao/cheque
				If(lCheque,aPgtos[nI][4][5],""),;																		// Agencia do cheque
				If(lCheque,aPgtos[nI][4][6],""),;																		// Conta do cheque
				If(lCheque,aPgtos[nI][4][9],""),;																		// RG do cheque
				If(lCheque,aPgtos[nI][4][10],""),;																		// Telefone do portador do cheque
				.F.,;																									//
				nMoedaParc })																							// Moeda da parcela
	Else  // Dinheiro.
		Aadd(	aParcVda,{aPgtos[nI][1],;		// Data de vencimento
				aPgtos[nI][2],;					// Valor da parcela
				aPgtos[nI][3],;					// Forma de pagamento
				"",;							// Codigo da Administradora
				"",;							// Numero do cartao/cheque
				"",;							// Agencia do cheque
				"",;							// Conta do cheque
				"",;							// RG do cheque
				"",;							// Telefone do portador do cheque
				.F.,;							//
				nMoedaParc })					//Moeda da parcela
	EndIf
    Conout("43. LOJA701C -  Lj7AprovCRD -  aParcVda: nI: " + ALLTRIM(STR(nI)) +;
    			 " " + If(Empty(aParcVda[nI][3]), "", aParcVda[nI][3]) +;
    			 " " + If(Empty(aParcVda[nI][4]), "", aParcVda[nI][4]) )
Next nI

For nI := 1 to Len(aCols)
	If !(aCols[nI][Len(aCols[nI])])
		AAdd( aProdCrd, {	aCols[nI][nPosItem],;           //Item do Produto
							aCols[nI][nPosCod],;            //Codigo do Produto
							aCols[nI][nPosDescri],;         //Descricao do Produto
							aCols[nI][nPosQuant],;          //Quantidade de pecas vendidas
							aCols[nI][nPosUnit],;           //Valor unitario do produto
							aCols[nI][nPosTotal]} )         //Valor total da venda do item
	EndIf
Next nI

If Len(aParcVda) > 0
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(Substr(cEmpAnt,1,2)+cFilAnt))

    AADD( aDadosCrd, aCrdCliente[2]			)				// 1.Numero do cartao
    AADD( aDadosCrd, aCrdCliente[1]			)				// 2.CNPJ/CPF
    AADD( aDadosCrd, nVlrVenda				)				// 3.Valor da venda
    AADD( aDadosCrd, M->LQ_JUROS			)				// 4.Juros da venda(%)
    AADD( aDadosCrd, Len(aParcVda)			)				// 5.Numero de parcelas
    AADD( aDadosCrd, nTpVenda				)				// 6.Venda forcada(1-Venda Normal 2-Venda forcada)
    AADD( aDadosCrd, cRespForcada			)				// 7.Responsavel pela venda forcada
    AADD( aDadosCrd, AClone(aParcCrd)		)				// 8.Dados das parcelas
    AADD( aDadosCrd, SM0->M0_CODIGO+"-"+FWGETCODFILIAL+"-"+Alltrim(SM0->M0_NOME)  ) // 9.Filial da venda
    AADD( aDadosCrd, LjGetStation("LG_PDV")	)				// 10.PDV
    AADD( aDadosCrd, xNumCaixa()			)				// 11.Caixa
    AADD( aDadosCrd, M->LQ_NUM				)				// 12.Num. do orcamento
    AADD( aDadosCrd, aClone(aProdCrd)		)				// 13.Produtos selecionados numa venda
    AADD( aDadosCrd, aClone(aParcVda)		)				// 14.Parcelas de uma venda
    AADD( aDadosCrd, FWGETCODFILIAL			)				// 15.Filial do Caixa que esta sendo utilizado
    AADD( aDadosCrd, M->LQ_CLIENTE			)				// 16.Cliente
    AADD( aDadosCrd, M->LQ_LOJA				)				// 17.Loja
    AADD( aDadosCrd, cUserName				)				// 18.Nome do usuario
    AADD( aDadosCrd, M->LQ_CONDPG 			)				// 19.Condicao de pagamento
    AADD( aDadosCrd, "LOJ" 					)			    // 20.Modulo chamador
	AADD( aDadosCrd, M->LQ_VEND				)			    // 21.VENDEDOR

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analise de credito  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTransacao == "1"

	    Conout("44.L0JA701C - Lj7AprovCRD - Chama a funcao CrdxVenda - " +;
	    		" Orcamento: " 	+ M->LQ_NUM +;
	    		" Contrato: " 	+ If(Empty(cNumContra),"", cNumContra))

		aRetCrd   := aClone(CrdxVenda( "1"   ,@aDadosCrd  ,cNumContra  ,.F.       ,;
                                      	NIL   ,cModOper    ,lModoCons   ,@aRecCrd  ))

		Conout("45.L0JA701C - Lj7AprovCRD - Retorno da funcao CrdxVenda - " +;
	    		" Orcamento: " 	+ M->LQ_NUM +;
	    		" Contrato: " 	+ If(Empty(aRetCrd[4]),"", aRetCrd[4]) +;
	    		" aRetCrd[5]: " + If( aRetCrd[5],".T.", ".F.") )

		If !aRetCrd[5]      //Se venda nao rejeitada
			cNumContra := aRetCrd[4]
			For nX := 1 to Len(aDadosCrd[8])
				nValorFin  += aDadosCrd[8][nX][2]
			Next nX
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza aContraTmp com os contratos que jah foram gerados. Utilizado na funcao CrdAtuPend para nao    ³
		//³deixar contratos pendentes 																		      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aRetCrd[4]) .AND. Ascan(aContraTmp,{|x| Trim(x[1]) == Trim(aRetCrd[4])}) == 0
			Aadd(aContraTmp,{aRetCrd[4],aDadosCrd[16],aDadosCrd[17]})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena CNPJ/CPF e/ou numero do cartao caso a identIficacao ³
		//³tenha sido feita na CrdxVenda                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Alltrim(cModOper) != "11") .AND. Empty(aCrdCliente[1]+aCrdCliente[2]) .AND. !Empty(aDadosCrd[1]+aDadosCrd[2])
			//cModOper = "11" é quando o Orçamento foi gravado como Venda <F4>. Para <F5>, o cModOper é "13".
			aCrdCliente    := {	aDadosCrd[02],;		// CNPJ/CPF.
								aDadosCrd[01]}		// Numero do cartao.
			M->LQ_CLIENTE  :=	aDadosCrd[16]
			M->LQ_LOJA     :=	aDadosCrd[17]
			Lj7ValCli(.F.)
			Lj7T_Total(2,Lj7T_SubTotal(2) + Iif(Type("aAcrescimo") <> "U",aAcrescimo[1],0) + Lj7CalcFrete())
			
			If MaFisFound("NF")
				MaFisAlt("NF_FRETE"  , 0)
				MaFisAlt("NF_SEGURO" , 0)
				MaFisAlt("NF_DESPESA", 0)
			EndIf
		EndIf
	ElseIf cTransacao == "2"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Confirmacao da transacao de credito  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o array das parcelas de financiamento. O array aParcCrd, por ser local, esta vazio ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aDadosCrd) > 0
			aDadosCrd[8]  := AClone(aRecCrd)
		EndIf
        aRetCrd := aClone(CrdxVenda( "2"   ,aDadosCrd  ,cNumContra  ,.F.     ,;
                                     NIL    ,NIL       ,NIL          ,aRecCrd ))
		If aRetCrd[1] == 0  //Confirmacao ok
			lConfCRD    := .T.
		EndIf
	ElseIf cTransacao == "3"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cancelamento da transacao de credito ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        aRetCrd  := aClone(CrdxVenda( "3"   ,aDadosCrd  ,cNumContra  ,.F.     ,;
                                       NIL  ,NIL         ,NIL         ,aRecCrd ))
	EndIf
Else
   Conout("46. LOJA701C - Lj7AprovCRD - aParcVda vazio, orcamento " + M->LQ_NUM +;
   			 " Contrato " + If(Empty(cContrato),"",cContrato))
EndIf

Return (aRetCrd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7SetCRDCºAutor  ³Vendas Clientes     º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializar array que contem o CNPJ/CPF ou numero do cartao º±±
±±º          ³e a variavel do numero do contrato(cContrato)			      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj7SetCRDClie(EXpL1)									      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1 - controla se atualiza aContraTmp					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7SetCRDClie(lAtuTmp)

Default lAtuTmp  := .F.

Conout("47. LOJA701C -  Lj7SetCRDClie - Inicializa variaveis - " +;
		" Contrato " + If(Empty(cContrato), "", cContrato) )

aCrdCliente := {"",""}
cContrato   := Space(TamSX3("MA7_CONTRA")[1])
lAvalBotao  := .F.
aInfMA7     := {}
aInfMAH     := {}
aInfMAL     := {}
aRecCrd     := {}
If lAtuTmp
   aContraTmp  := {}
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CancCRDºAutor  ³Vendas Clientes     º Data ³  02/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desfaz a operacao de credito caso ocorra algum erro na tran-º±±
±±º          ³sacao                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj7CancCRD(ExpC1, ExpC2) 								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Codigo do cliente                                   º±±
±±º          ³ ExpC2: Loja do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CancCRD(cCodClie  ,cLoja)
Local cNumContra   := ""                     //Numero do contrato
Local aRetCrd      := {}                    //Retorno do cancelamento da transacao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desfaz a transacao de credito  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CrdxInt()
   DbSelectArea("MA7")
   DbSetOrder(1)
   If DbSeek(xFilial("MA7")+cCodClie+cLoja) .AND. (!Empty(MA7->MA7_CONTRA) .OR. !Empty(cContrato))
      If !Empty(MA7->MA7_CONTRA)
         cNumContra  := MA7->MA7_CONTRA
      Else
         cNumContra  := cContrato
      EndIf

 	  Conout("48.LOJA701C - Lj7CancCRD - Orcamento: " +  M->LQ_NUM +;
	               " Contrato: " + If (Empty(cContrato), "", cContrato) +;
	      		   " Desfas a transacao de credito: Lj7AprovCRD Param1=3 " )


	  aRetCrd     := AClone(Lj7AprovCRD( "3"  ,cNumContra  ,Lj7T_Total(2)  ,NIL   ,;
	                                      NIL  ,NIL        ,NIL ))
   EndIf
Else
	Conout("49.LOJA701C - Lj7CancCRD - Orcamento: " +  M->LQ_NUM + "  Sem Integracao com o CRD")
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CRDAvalºAutor  ³Vendas Clientes     º Data ³  20/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a analise de credito chamado pelo botao da toolbar  º±±
±±º			 ³Integracao com SIGACRD									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj7CRDAval(ExpN1)           								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - opcao do aRotina						              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Venda liberada ou bloqueada							  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7CRDAval(nOpc)
Local lRet          := .T.                       			// Controla o prosseguimento da funcao
Local lTemFinanc    := .F.                       			// Determina se tem alguma parcela financiada para chamar a tela
Local lTemParcFI    := .F.                         			// Controla se tem alguma parcela financiada para avaliacao de credito
Local nX            := 0                             			// Variavel de controle de loop
Local nValorFin     := 0                         			// Valor financiado
Local nSaldo        := 0                         			// Saldo restante para atingir limite de credito
Local cMV_FormCRD   := SuperGetMV("MV_FORMCRD",,"CH/FI") 	// Formas de pagamento para as quais deve avaliar credito - SIGACRD
Local cMsgStatus    := ""                       			// Mensagem de retorno ao Caixa
Local cMV_CLIPAD	:= PadR(SuperGetMV("MV_CLIPAD"),TAMSX3("LQ_CLIENTE")[1])					// Cliente padrao
Local cMV_LOJAPAD	:= PadR(SuperGetMV("MV_LOJAPAD"),TAMSX3("LQ_LOJA")[1])						// Loja do cliente padrao
Local aRetCrd       := {}                       			// Array de retorno com informacoes de credito do cliente(SIGACRD)
Local oMsgStatus                                			// Objeto da mensagem de retorno ao Caixa
Local oDlg                                      			// Objeto da caixa de dialogo
Local aParc    		:= {}									// Parcelas a serem analisadas pelo SIGACRD
Local nPosCpo		:= 0									// Posicao do campo FORMA de pagamento no array
Local nTipo         := 0

Conout("50. LOJA701C - Lj7CRDAval - Inicio da Rotina")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o campo L4_FORMAID nao estiver criado, as parcelas nao foram adicionadas no array aPgtosSint³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisuSint
	aParc      		:= aClone(aPgtosSint)
	nPosCpo			:= 1
Else
	aParc    		:= aClone(aPgtos)
	nPosCpo			:= 3
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se as parcelas foram selecionadas 					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aParc)
   lRet  := !Empty(aParc[nX][nPosCpo])
   If !lRet
      Exit
   EndIf
Next nX

If !lRet
   MsgAlert(STR0060)  //"Digite as parcelas antes de realizar a analise de credito."
EndIf

If lRet
   For nX := 1 to Len(aParc)
      If Empty(aParc[nX][nPosCpo])
         Loop
      EndIf
      If AllTrim(aParc[nX][nPosCpo]) $ cMV_FormCRD
         lTemParcFI  := .T.
      EndIf
      If !IsMoney(Alltrim(aParc[nX][nPosCpo])) .AND. AllTrim(aParc[nX][nPosCpo]) <> AllTrim(MVCHEQUE)
         If AllTrim(aParc[nX][nPosCpo]) $ cMV_FormCRD
            lTemFinanc  := .T.
            Exit
         EndIf
      EndIf
   Next nX

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Chama a tela para selecionar a Adm. Financeira quando grava orcamento,   ³
   //³tiver ao menos uma parcela em que avalia o credito e SIGACRD integrado   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lTemFinanc
      Lj7InfPgtos(nTipo)
   EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Se for chamada da finalizacao da venda, recupera o numero do contrato gra³
   //³vado no orcamento 													   ³
   //³Busca os dados do cliente se tiver parcela financiada 				   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If nOpc == 4 .AND. lTemParcFI
      If Empty(aCrdCliente[1]+aCrdCliente[2]) .AND. M->LQ_CLIENTE+M->LQ_LOJA <> cMV_CLIPAD+cMV_LOJAPAD
         aCrdCliente   := AClone(CrdInfClie(M->LQ_CLIENTE, M->LQ_LOJA))
      EndIf
   EndIf

   Conout("51. LOJA701C - Lj7CRDAval - Chama a funcao LJ7AprovCRD - "+;
   			" Contrato:" + If(Empty(cContrato),"", cContrato))

   aRetCrd   := AClone(Lj7AprovCRD( "1"        ,@cContrato ,Lj7T_Total(2)  ,NIL   ,;
                                     @nValorFin ,"XX"      ,.T.))
   Conout("52. LOJA701C - Lj7CRDAval - Retorno da funcao LJ7AprovCRD - "+;
   			" Contrato:" + If(Empty(cContrato),"", cContrato))

   If Len(aRetCrd) > 1
		If aRetCrd[5]  // Venda rejeitada.
			lRet := .F.
		ElseIf !Empty(aRetCrd[4])  // Se retornou o numero do contrato, credito aprovado.
	     lAvalBotao  := .T.
	     cContrato   := aRetCrd[4]
	     If aRetCrd[1] == 0
	        nSaldo     := aRetCrd[2] - (aRetCrd[3] + nValorFin)
	        //Se foi desbloqueado pelo analista de credito(saldo < 0) nao mostra mensagem de status
	        If nSaldo >= 0
					cMsgStatus := STR0063 + Transform(aRetCrd[2], PesqPict("MAL", "MAL_VALOR")) + Space(10)	// "Valor do Limite de crédito do cliente: "
					cMsgStatus += STR0064 + Transform(nSaldo, PesqPict("MAL", "MAL_VALOR")) + CRLF				// " Saldo: "
					cMsgStatus += STR0065 + Transform(aRetCrd[3], PesqPict("MAL", "MAL_VALOR"))				// "Valor dos títulos em aberto: "
					cMsgStatus += STR0066 + Transform(nValorFin, PesqPict("MAL", "MAL_VALOR"))					// " + Compra Atual: "
		    EndIf
	     EndIf
	  Else
			If aRetCrd[1] == 2   // Off-line.
	        //"A consulta nao poderá ser realizada pois o serviço se encontra indisponível no momento."
	        MsgAlert(STR0062)
	     Else
	        //"Não sera realizada a análise de crédito, a condição de pagamento selecionada nao requer sua realização."
	        MsgAlert(STR0061)
	     EndIf
	  EndIf
	  If !Empty(cMsgStatus)
		DEFINE FONT oFont NAME "Times New Roman" SIZE 9,14

		DEFINE MSDIALOG oDlg FROM 0,0 TO 130,600 TITLE STR0067 PIXEL  //"Analise de Credito"

	 	   @ 03, 002 TO  45, 297 LABEL STR0068 OF oDlg PIXEL   //"Status"
		   @ 12, 005 SAY oMsgStatus VAR cMsgStatus PIXEL FONT oFont

		   DEFINE SBUTTON FROM 50,268 TYPE 01 ACTION oDlg:End() ENABLE

		ACTIVATE MSDIALOG oDlg CENTERED
	  EndIf
   EndIf
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7SetContºAutor  ³Vendas Clientes     º Data ³  20/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza variaveis de contrato quando finalizacao de venda  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj7SetContra()           								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum 												  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7SetContra()

Conout("53.LOJA701C - Lj7SetContra, contrato " + M->LQ_CONTRA )
cContrato    := M->LQ_CONTRA
If !Empty(cContrato)
   AAdd(aContraTmp,{cContrato,M->LQ_CLIENTE,M->LQ_LOJA})
   Lj7GetInfCRD(cContrato,M->LQ_CLIENTE,M->LQ_LOJA)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7GetContºAutor  ³Vendas Clientes     º Data ³  20/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recupera o conteudo da variavel aContraTmp. Variavel utili- º±±
±±º			 ³zada para verIficar se deve cancelar contrato pendente      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj7GetContra()           								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Conteudo aContraTmp 									      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7GetContra()
Local aRet     := {}               //Conteudo da variavel aContraTmp

aRet  := AClone(aContraTmp)

Return (aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7GetInfCºAutor  ³Vendas Clientes     º Data ³  20/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Armazena os dados dos arquivos MAH e MAL se o orcamento tem º±±
±±º			 ³um contrato de financiamento associado. Sera utilizado caso º±±
±±º			 ³o usuario nao confirme a operacao, pois deve voltar o backupº±±
±±º			 ³destes arquivos para atualizar a base de dados              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj7GetInfCRD(ExpC1, ExpC2, ExpC3)					      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Numero do contrato 								  º±±
±±º          ³ExpC2 - Codigo do cliente 								  º±±
±±º          ³ExpC3 - Loja do cliente 								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum			 									      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7GetInfCRD(cNumContra, cCodClie, cLoja)
Local aArea    := GetArea()      // Area atual

DbSelectArea("MA7")
DbSetOrder(1)
If DbSeek(xFilial("MA7")+cCodClie+cLoja)
   aInfMA7    := {}
   Aadd(aInfMA7, MA7->MA7_DATABL )
   Aadd(aInfMA7, MA7->MA7_HORABL )
   Aadd(aInfMA7, MA7->MA7_USRBL  )
   Aadd(aInfMA7, MA7->MA7_MOTBL  )
   Aadd(aInfMA7, MA7->MA7_VLRBL  )
   Aadd(aInfMA7, MA7->MA7_BLOQUE )
   Aadd(aInfMA7, MA7->MA7_DTHRDS )
   Aadd(aInfMA7, MA7->MA7_LC     )
   Aadd(aInfMA7, MA7->MA7_ARQPRO )
   Aadd(aInfMA7, MA7->MA7_ARQPAR )
EndIf

DbSelectArea("MAH")
DbSetOrder(1)
If DbSeek(xFilial("MAH")+cNumContra)
   aInfMAH    := {}
   Aadd(aInfMAH, MAH->MAH_CONTRA )
   Aadd(aInfMAH, MAH->MAH_EMISSA )
   Aadd(aInfMAH, MAH->MAH_DTTRN  )
   Aadd(aInfMAH, MAH->MAH_HRTRN  )
   Aadd(aInfMAH, MAH->MAH_PDVTRN )
   Aadd(aInfMAH, MAH->MAH_CXTRN  )
   Aadd(aInfMAH, MAH->MAH_LJTRN  )
   Aadd(aInfMAH, MAH->MAH_VLRFIN )
EndIf

aInfMAL    := {}
DbSelectArea("MAL")
DbSetOrder(1)
DbSeek(xFilial("MAL")+cNumContra)
While !Eof() .AND. xFilial("MAL")+cNumContra == MAL->MAL_FILIAL+MAL->MAL_CONTRA
   Aadd(aInfMAL, { MAL->MAL_CONTRA ,;
                   MAL->MAL_PARCEL ,;
                   MAL->MAL_VENCTO ,;
                   MAL->MAL_VALOR  ,;
                   MAL->MAL_SALDO  })
   DbSkip()
End

RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7RestInfºAutor  ³Vendas Clientes     º Data ³  20/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Se usuario nao confirmou a operacao de gravacao, o sistema  º±±
±±º          ³deve verIficar se os dados do orcamento x dados do contrato º±±
±±º          ³estao integros, porque a cada analise solicitada os dados doº±±
±±º          ³contrato sao atualizados enquanto os do orcamento apenas na º±±
±±º          ³confirmacao da operacao(gravacao orcamento/venda)			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Lj7RestInfCRD()           								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum			 									      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7RestInfCRD()

If !Empty(cContrato) .AND. Len(aInfMAH) > 0 .AND. Len(aInfMAL) > 0 .AND. Len(aInfMA7) > 0
   CrdRestInfCRD(cContrato		, aInfMAH		, aInfMAL	, aInfMA7	,;
   				 M->LQ_CLIENTE	, M->LQ_LOJA	)
   aInfMA7    := {}
   aInfMAH    := {}
   aInfMAL    := {}
EndIf

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7AtuPremioºAutor  ³Vendas Clientes      º Data ³11/03/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa as variaveis de resgate de premio                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Lj7AtuPremio()              								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Retorno do valor total dos premios (brinde + self-liquidate º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7AtuPremio(lZeraPremio)
Local nRet := nTotPremio

Default lZeraPremio 	:= .F.

If lZeraPremio
	nTotPremio := 0
	aPremio	   := {}
	aLibera	   := {}
EndIf

Return (nRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7GrvPremioºAutor  ³Vendas Clientes      º Data ³11/03/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava o premio resgatado pelo cliente no arquivo SL2 pois e º±±
±±º          ³um produto da loja                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Lj7GrvPremio()              								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7GrvPremio()
Local aSL1      := {}
Local aSL2      := {}
Local nX		:=0							//Contador
Local nQtdItens :=0							//Quantidade de itens
Local nTamItem	:=TamSx3("L2_ITEM")[1]  	//Tamanho do L2_ITEM
Local cItem		:= Space(nTamItem)			//Item
Local cTes		:= ""						//Tes
Local cCampo	:= ""                 		//campo
Local nPrcTab   := 0						//Preco de tabela
Local nValDesc  := 0						//Valor do desconto
Local nItens	:= 0						//Numero do item
Local cTabPad	:= AllTrim(SuperGetMv("MV_TABPAD"))	//Tabela de preco padrao
Local nDescPer  := 0
Local lL2FECP	:= SL2->( ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0 )
Local lL2FECPST := SL2->( ColumnPos("L2_ALQFCST") > 0 .AND. ColumnPos("L2_VFECPST") > 0 )


AEval(aCols, {|x| If(!x[Len(x)], nQtdItens++,)})

cItem := StrZero( nQtdItens,nTamItem ,0)

DbSelectArea("SB1")
DbSetOrder(1)

For nX := 1 to Len(aPremio)

	// Se nao for vale compra, grava o item no SL2
	If Empty(aPremio[nX][4])

		If  DbSeek(xFilial("SB1")+aPremio[nX][3])

			cItem := Soma1(cItem)

			cTes := SB1->B1_TS
			If Empty(cTes)
				cTes:= SuperGetMv("MV_TESSAI")
			EndIf
			SF4->( DbSetOrder(1) )
			SF4->( DbSeek(xFilial("SF4")+cTes) )

	    	SB0->( DbSetOrder(1) )
			If SB0->( DbSeek(xFilial("SB0")+aPremio[nX][3]) )
				cCampo := "B0_PRV"+cTabPad
				nPrcTab := SB0->(&cCampo)
			EndIf
			nValDesc := Round( (nPrcTab * aPremio[nX][6])/100, 2)

			If aPremio[nX][5] = 0.01
				cPremio := "1"   // Brinde
			Else
				cPremio := "2"   // Self-Liquidate
			EndIf

			If MaFisFound("NF")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quando for inclusao de um novo item chama a funcao MafisAdd              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaFisAdd( aPremio[nX][3],;				// Produto
								cTes,;						// Tes
								1,;							// Quantidade
								aPremio[nX][5],;			// Preco unitario
								0,;							// Valor do desconto
								"",; 						// Numero da NF original
								"",; 						// Serie da NF original
								0,;							// Recno da NF original
								0,; 						// Valor do frete do item
								0,; 						// Valor da despesa do item
								0,; 						// Valor do seguro do item
								0,; 						// Valor do frete autonomo
								aPremio[nX][5],;			// Valor da mercadoria
								0 )							// Valor da embalagem
			EndIf

			aAdd( aSL2, {} )

			aAdd( aSL2[Len(aSL2)], { "L2_FILIAL"	, 	xFilial("SL2") } )
			aAdd( aSL2[Len(aSL2)], { "L2_NUM"		, 	M->LQ_NUM } )
			aAdd( aSL2[Len(aSL2)], { "L2_ITEM"		,	cItem } )
			aAdd( aSL2[Len(aSL2)], { "L2_PRODUTO"	,	aPremio[nX][3] } )
			aAdd( aSL2[Len(aSL2)], { "L2_DESCRI"	, 	SB1->B1_DESC } )
			aAdd( aSL2[Len(aSL2)], { "L2_QUANT"		, 	1 } )
			aAdd( aSL2[Len(aSL2)], { "L2_VRUNIT"	, 	aPremio[nX][5] } )
			aAdd( aSL2[Len(aSL2)], { "L2_VLRITEM"	, 	aPremio[nX][5] } )
			aAdd( aSL2[Len(aSL2)], { "L2_LOCAL"		, 	SB1->B1_LOCPAD } )
			aAdd( aSL2[Len(aSL2)], { "L2_UM"		, 	SB1->B1_UM } )
			aAdd( aSL2[Len(aSL2)], { "L2_DESC"		, 	aPremio[nX][6] } )
			aAdd( aSL2[Len(aSL2)], { "L2_VALDESC"	, 	nValDesc } )
			aAdd( aSL2[Len(aSL2)], { "L2_TES"		, 	cTes } )
			aAdd( aSL2[Len(aSL2)], { "L2_CF"		, 	SF4->F4_CF } )
			aAdd( aSL2[Len(aSL2)], { "L2_EMISSAO"	, 	dDatabase } )
			aAdd( aSL2[Len(aSL2)], { "L2_GRADE"		, 	"N" } )
			aAdd( aSL2[Len(aSL2)], { "L2_VEND"		,	M->LQ_VEND } )
			aAdd( aSL2[Len(aSL2)], { "L2_TABELA"	,	cTabPad } )
			aAdd( aSL2[Len(aSL2)], { "L2_PRCTAB"	, 	nPrcTab } )
			If SL2->(ColumnPos("L2_PREMIO")) > 0
				aAdd( aSL2[Len(aSL2)], { "L2_PREMIO", 	cPremio } )
			EndIf
			If SL2->(ColumnPos("L2_ITEMSD1")) > 0
				aAdd( aSL2[Len(aSL2)], { "L2_ITEMSD1"	, 	"000000" } )
			EndIf

	        nItens := nX + nQtdItens

			If MaFisFound("IT",nItens)

				aAdd( aSL2[Len(aSL2)], { "L2_VALIPI",	MaFisRet(nItens,"IT_VALIPI") } )
				aAdd( aSL2[Len(aSL2)], { "L2_VALICM",	MaFisRet(nItens,"IT_VALICM") } )
				aAdd( aSL2[Len(aSL2)], { "L2_VALISS",	MaFisRet(nItens,"IT_VALISS") } )
				aAdd( aSL2[Len(aSL2)], { "L2_BASEICM",	MaFisRet(nItens,"IT_BASEICM") } )

				If SL2->(ColumnPos("L2_ABATISS")) > 0				
					aAdd( aSL2[Len(aSL2)], { "L2_ABATISS",	MaFisRet(nItens,"IT_ABVLISS") } ) 
				EndIf

				If SL2->(ColumnPos("L2_VALPIS")) >0 .AND. SL2->(ColumnPos("L2_VALCOFI"))>0 .AND.	;
				   SL2->(ColumnPos("L2_VALCSLL"))>0 .AND. SL2->(ColumnPos("L2_VALPS2")) >0 .AND.	;
				   SL2->(ColumnPos("L2_BASEPS2"))>0	.AND. SL2->(ColumnPos("L2_ALIQPS2"))>0 .AND.	;
				   SL2->(ColumnPos("L2_VALCF2")) >0	.AND. SL2->(ColumnPos("L2_BASECF2"))>0 .AND.	;
				   SL2->(ColumnPos("L2_ALIQCF2"))>0	.AND. ;
				   ( SA1->A1_RECPIS == "S" .OR. SA1->A1_RECCOFI == "S" .OR. SA1->A1_RECCSLL == "S" )

					aAdd( aSL2[Len(aSL2)], { "L2_VALPIS ", MaFisRet(nItens,"IT_VALPIS") } )
					aAdd( aSL2[Len(aSL2)], { "L2_VALCOFI", MaFisRet(nItens,"IT_VALCOF") } )
					aAdd( aSL2[Len(aSL2)], { "L2_VALCSLL", MaFisRet(nItens,"IT_VALCSL") } )

				EndIf

				aAdd( aSL2[Len(aSL2)], { "L2_BASEPS2", MaFisRet(nItens,"IT_BASECF2") } )
				aAdd( aSL2[Len(aSL2)], { "L2_BASECF2", MaFisRet(nItens,"IT_BASECF2") } )

				aAdd( aSL2[Len(aSL2)], { "L2_VALPS2" , MaFisRet(nItens,"IT_VALPS2") } )
				aAdd( aSL2[Len(aSL2)], { "L2_VALCF2" , MaFisRet(nItens,"IT_VALCF2") } )

				aAdd( aSL2[Len(aSL2)], { "L2_ALIQPS2", MaFisRet(nItens,"IT_ALIQPS2") } )
				aAdd( aSL2[Len(aSL2)], { "L2_ALIQCF2", MaFisRet(nItens,"IT_ALIQCF2") } )

				aAdd( aSL2[Len(aSL2)], { "L2_BRICMS", 	MaFisRet(nItens,"IT_BASESOL") } )
				aAdd( aSL2[Len(aSL2)], { "L2_ICMSRET",	MaFisRet(nItens,"IT_VALSOL") } )

				aAdd( aSL2[Len(aSL2)], { "L2_VALFRE",	MaFisRet(nItens,"IT_FRETE") } )
				aAdd( aSL2[Len(aSL2)], { "L2_SEGURO",	MaFisRet(nItens,"IT_SEGURO") } )
				aAdd( aSL2[Len(aSL2)], { "L2_DESPESA",  MaFisRet(nItens,"IT_DESPESA") } )
				
				If lL2FECP
					aAdd( aSL2[Len(aSL2)], { "L2_ALQFECP",  MaFisRet(nItens, "IT_ALIQFECP") } )
					aAdd( aSL2[Len(aSL2)], { "L2_VALFECP",  MaFisRet(nItens, "IT_VALFECP") } )
				EndIf
				
				If lL2FECPST
                    aAdd( aSL2[Len(aSL2)], { "L2_ALQFCST",  MaFisRet(nItens, "IT_ALFCST") } )
                    aAdd( aSL2[Len(aSL2)], { "L2_VFECPST",  MaFisRet(nItens, "IT_VFECPST") } )
                EndIf
			EndIf
		EndIf
	EndIf
Next nX
For nX := 1 to Len( aSL2 )
   Lj7GeraSL( "SL2", aSL2[nX], .T. )
Next nX

If Lj7T_DescP(2) > 0 .AND. nTotPremio > 0
   nDescPer  := Round((Lj7T_DescV(2)/Lj7T_Total(2)) * 100,2)
EndIf

aAdd( aSL1, {} )
aAdd( aSL1[Len(aSL1)], { "L1_VALMERC", MaFisRet(,"NF_VALMERC") } )
aAdd( aSL1[Len(aSL1)], { "L1_DESCNF" , nDescPer } )
For nX := 1 to Len( aSL1 )
   Lj7GeraSL( "SL1", aSL1[nX], .F. )
Next nX

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjImpTEF   ºAutor  ³Vendas Clientes      º Data ³29/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime e Grava a Transacao tef da Venda                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjImpTEF()              								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum													  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjGrvImpTEF(lTefOk		, lCartao	, aRet		, nSize		,;
						 	cRBuffer	, nHandle	, lAbtoAll	, cAdminis	,;
						 	oTef		, cSerie	, lLog1		, lLog4		,;
						 	lErrCupTEF	, lDscCupTef, aTefDados , lTemTefPend,;
						 	aNSUVndTef)

Local nCont 		:= 0									// Contador
Local nX  			:= 0									// Contador do FOR
Local aSL1			:= {}									// Array com os campos do SL1
Local aSL4			:= {}									// Array com os campos do SL4
Local lMVTELAFIN	:= SuperGetMv("MV_TELAFIN",,.T.)		// Define se mostra a tela de administradora
Local lSemRede		:= .F.									// Variavel que retorna se a rede selecioda no TEF existe na base
Local lTEFFat       := .F.									// Uso do TEF dentro do modulo Faturamento
Local cContOnf      := "" 	    	                        // Contador Geral de Operação Não Fiscal
Local cContRg       := ""   	                            // Contador Geral de Relatório Gerencial
Local cContCdc      := ""           	                    // Contador de Comprovante de Crédito ou Débito
Local lRelGer       := .F.                                  // Indica se houve impressão de relatorio gerencial
Local nPosData   	 := 0									// Variavel que contem a posicao no Array oTef:aRetCartao:aDatas
Local dDataTrans	 := CtoD(Space(08))                     // Conteudo do Array oTef:aRetCartao:aDatas
Local nPosTrans		 := 0                                 	// Variavel que contem a posicao no Array oTef:aRetCartao:aValores
Local nValorTrans 	 := 0									// Conteudo do Array oTef:aRetCartao:aValores
Local nPosRetCart    := 0                                   // Varial que contem posicao no Array oTef:aRetCartao
Local lTefMult		 := SuperGetMV("MV_TEFMULT", ,.F.)		// Identifica se o cliente utiliza múltiplas transacoes TEF
Local aDTEFPend		 := {} 									//Array de transacoes DTEF Pendentes
Local nCountTEF		 := 0  									// Contador de pagamentos com forma TEF
Local cNroDoc 		 := ""
Local cNumPDV 		 := ""
Local cCodRede 		 := ""
Local cDescRede		 := ""
Local cNSUVndTef	 := ""
Local aRetPbm		 := {}	//Retorno das informações do PBM Funcional Card

//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	 := LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nPosMfe		 := 0	//posicao retorno MFE

Local lL1VLRPGDG 	 := SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital e PIX

Default lDscCupTef	 := .F.									//se TEF discado, indica se o comprovante TEF foi impresso
Default aNSUVndTef	 := {}

If LjNfUsaTef(SM0->M0_CGC)
	lTefFAT	:= LJXVERTEF(.F.)
	aRet[2] := {"",""}
EndIf

If (lTefOk .AND. !lFtvdVer12 .AND. lUsaTef .AND. (lCartao .OR. (LjNfUsaTef(SM0->M0_CGC) .AND. lTEFFat));
	.AND. cTipTEF $	TEF_SEMCLIENT_DEDICADO + ";" + ;
					TEF_COMCLIENT_DEDICADO + ";" + ;
					TEF_DISCADO			   + ";" + ;
					TEF_CENTROPAG		   + ";" + ;
					TEF_CLISITEF ) .OR. ;
	(lTefOk .AND. lFtvdVer12 .AND. lUsaTef .AND. (lCartao .OR. lTEFFat);
	.AND. cTipTEF $	TEF_SEMCLIENT_DEDICADO + ";" + ;
					TEF_COMCLIENT_DEDICADO + ";" + ;
					TEF_DISCADO			   + ";" + ;
					TEF_CLISITEF	)

	If !Empty( LOG_TEF )
		LjWriteLog( LOG_TEF + M->LQ_NUM + ".TXT", "Impressão do cupom tef - N / S / S / S / " + cTipTEF )
	EndIf

	If aRet[1]
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

		aSL1 := {}

		If lUsaTef .AND. lTefOk
			If cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + 	TEF_DISCADO
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Sem Client / Com Client / Discado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd( aSL1, { "L1_VENDTEF", "S" } )
				AAdd( aSL1, { "L1_DATATEF", aTefDados[1][2] } )
				AAdd( aSL1, { "L1_HORATEF", aTefDados[1][3] } )
				AAdd( aSL1, { "L1_DOCTEF" , aTefDados[1][4] } )
				AAdd( aSL1, { "L1_AUTORIZ", aTefDados[1][5] } )
				AAdd( aSL1, { "L1_INSTITU", aTefDados[1][8] } )
				AAdd( aSL1, { "L1_DOCCANC", aTefDados[1][6] } )
				AAdd( aSL1, { "L1_DATCANC", aTefDados[1][12] } )
				AAdd( aSL1, { "L1_HORCANC", aTefDados[1][7] } )
				AAdd( aSL1, { "L1_NSUTEF" , aTefDados[1][9] } )
				AAdd( aSL1, { "L1_TIPCART", aTefDados[1][10] } )

				If !Empty( aTefDados[1][15] )
					AAdd( aSL1, { "L1_FORMPG", aTefDados[1][20] } )
				EndIf

				AAdd(aSL1,{"L1_TEFBAND"	, aTefDados[1][18]})
				

				If SL1->(ColumnPos( "L1_PARCTEF" ) ) > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AAdd( aSL1, { "L1_PARCTEF", aTefDados[1][16] + aTefDados[1][17] } )
				EndIf
			Else
				If cTipTef $ TEF_CLISITEF+ ";" + TEF_CENTROPAG
					aSL1 := LjTEFGeraSL( aSL1, "SL1" )
				EndIf
			EndIf
			Lj7GeraSL( "SL1", aSL1, .F., .F. )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a gravacao do SL4 somente se nao for orcamento gerado de ³
		//³ um pedido                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( SL1->L1_FILRES ) .AND. Empty( SL1->L1_ORCRES )
			aSL4 := {}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Teve abatimento total no valor da venda (PIS/COFINS/CSLL)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aPgtos ) == 1 .AND. Empty( aPgtos[1,1] ) .AND. aPgtos[1,2] == ( LJPCCRet() + If( LJ220AbISS(), MaFisRet( , "NF_VALISS" ), 0 ) )
				lAbtoAll := .T.
			EndIf

			If cTipTEF == TEF_DISCADO  .AND. L010IsDirecao(L010GetGPAtivo())
				aDTEFPend :=  LJLoadDTEF()
			EndiF

			For nX := 1 To Len( aPgtos )
				// Contador de Formas de Pagto TEF
				If AllTrim(aPgtos[nX][3]) $ _FORMATEF
					nCountTEF := aScan(aTefDados,{|x|,Alltrim(x[19]) == Alltrim(aPgtos[nX][8])})
				Endif
				
				AAdd( aSL4, {} )
				AAdd( aSL4[nX], { "L4_VENDTEF", "N" } )
				
				If Len(aNSUVndTef) > 0
					nCont := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aPgtos[nX][3])+aPgtos[nX][8]}) //Forma + ID											
					cNSUVndTef := IIf( nCont > 0 , aNSUVndTef[nCont][4], "")
					If !Empty(AllTrim(cNSUVndTef))
						aAdd( aSL4[nX], { "L4_VENDTEF", "S"})
					EndIf
				EndIf		

				If lMFE .And. Len(aIdPgtoMfe) > 0 .And. AllTrim(aPgtos[nX][3]) $ _FORMATEF
				
					nPosMfe := aScan(aIdPgtoMfe,{|x|,Alltrim(x[2]) $ Alltrim(aPgtos[nX][8]) })

					If nPosMfe > 0 	//verifico se o ID da transação está no array do retorno do MFE
						aAdd( aSL4[nX], { "L4_IDPGVFP", aIdPgtoMfe[nPosMfe][1]})	
					EndIf	

				EndIf							

				If lUsaTef .AND. lTefOk
					If cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + 	TEF_DISCADO .AND. AllTrim(aPgtos[nX][3]) $ _FORMATEF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Sem Client / Com Client / Discado ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		                If ( nPos := AScan( aTefMult, { |x| AScan( x[10], StrZero( nX, 2 ) ) > 0 } ) ) <> 0
			                If Len( aTefMult[nPos][7] ) > 0
			    	            aTefDados := aClone( aTefMult[nPos][7] )

								AAdd( aSL4[nX], { "L4_VENDTEF", "S" } )
								AAdd( aSL4[nX], { "L4_DATATEF", aTefDados[1][2] } )
								AAdd( aSL4[nX], { "L4_HORATEF", aTefDados[1][3] } )
								AAdd( aSL4[nX], { "L4_DOCTEF" , aTefDados[1][4] } )
								AAdd( aSL4[nX], { "L4_AUTORIZ", aTefDados[1][5] } )
								AAdd( aSL4[nX], { "L4_INSTITU", aTefDados[1][8] } )
								AAdd( aSL4[nX], { "L4_DOCCANC", aTefDados[1][6] } )
								AAdd( aSL4[nX], { "L4_DATCANC", aTefDados[1][12] } )
								AAdd( aSL4[nX], { "L4_HORCANC", aTefDados[1][7] } )
								AAdd( aSL4[nX], { "L4_NSUTEF" , aTefDados[1][9] } )
								AAdd( aSL4[nX], { "L4_TIPCART", aTefDados[1][10] } )

								If !Empty( aTefDados[1][15] )
									AAdd( aSL4[nX], { "L4_FORMPG", aTefDados[1][15] } )
								EndIf

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Antes de gravar o SL4 vou verIficar se a ADM selecionada ³
								//³pelo operador e a mesma da resposta da transacao         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cAdminis := LJ7ConfAdm( aPgtos[nX][4][5], aTefDados[1][8] )

								If !Empty( cAdminis )
									AAdd( aSL4[nX], { "L4_ADMINIS", cAdminis } )
								EndIf
							EndIf
						ElseIf cTipTEF == TEF_DISCADO  .AND. L010IsDirecao(L010GetGPAtivo()) .AND. AllTrim(aPgtos[nX][3]) $ _FORMATEF .AND. Len(aDTEFPend) > 12						 
							nPosRetCart := Iif(lTefMult, aScan(aDTEFPend, {|x| x[14] == aPgtos[nX][8] } ), 1)
							If nPosRetCart > 0
								cL4NSUTEF := Right(aDTEFPend[nPosRetCart][7], Len(aDTEFPend[nPosRetCart][7] - 3))
								
								aAdd( aSL4[nX], { "L4_VENDTEF","S"})
								aAdd( aSL4[nX], { "L4_DATATEF",aDTEFPend[nPosRetCart][10]})
								aAdd( aSL4[nX], { "L4_HORATEF",aDTEFPend[nPosRetCart][11]})
								aAdd( aSL4[nX], { "L4_DOCTEF" ,aDTEFPend[nPosRetCart][13]})
								aAdd( aSL4[nX], { "L4_AUTORIZ",aDTEFPend[nPosRetCart][13]})
								aAdd( aSL4[nX], { "L4_NSUTEF" ,cL4NSUTEF})
							    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Antes de gravar o SL4 vou verIficar se a ADM selecionada ³
								//³pelo operador e a mesma da resposta da transacao         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cAdminis := LJ7ConfAdm( aPgtos[nX][4][5], aDTEFPend[nPosRetCart][06] )

								If !Empty( cAdminis )
									AAdd( aSL4[nX], { "L4_ADMINIS", cAdminis } )
								EndIf
							EndIf
						ElseIf cTipTEF == TEF_DISCADO .AND. AllTrim(aPgtos[nX][3]) $ _FORMATEF .AND. lTefMult
							If nCountTEF>0 .AND. Len(aTEFDados) >= nCountTEF .AND. Len(aTEFDados[nCountTEF]) >= 15
									AAdd( aSL4[nX], { "L4_VENDTEF", "S" } )
									AAdd( aSL4[nX], { "L4_DATATEF", aTefDados[nCountTEF][2] } )
									AAdd( aSL4[nX], { "L4_HORATEF", aTefDados[nCountTEF][3] } )
									AAdd( aSL4[nX], { "L4_AUTORIZ", aTefDados[nCountTEF][5] } )
									AAdd( aSL4[nX], { "L4_INSTITU", aTefDados[nCountTEF][8] } )
									AAdd( aSL4[nX], { "L4_DOCCANC", aTefDados[nCountTEF][6] } )
									AAdd( aSL4[nX], { "L4_DATCANC", aTefDados[nCountTEF][12] } )
									AAdd( aSL4[nX], { "L4_HORCANC", aTefDados[nCountTEF][7] } )
									If L010IsDirecao(L010GetGPAtivo())
										AAdd( aSL4[nX], { "L4_NSUTEF" , Right(aTefDados[nCountTEF][9],6) } )
										AAdd( aSL4[nX], { "L4_DOCTEF" , aTefDados[nCountTEF][5] } )
									Else
										AAdd( aSL4[nX], { "L4_NSUTEF" , aTefDados[nCountTEF][9] } )
										AAdd( aSL4[nX], { "L4_DOCTEF" , aTefDados[nCountTEF][5] } )
									EndIf
									AAdd( aSL4[nX], { "L4_TIPCART", aTefDados[nCountTEF][10] } )

									If !Empty( aTefDados[nCountTEF][15] )
										AAdd( aSL4[nX], { "L4_FORMPG", aTefDados[nCountTEF][20] } )
									EndIf

									AAdd( aSL4[nX], { "L4_FORMA"  , aTefDados[nCountTEF][20] } )
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Antes de gravar o SL4 vou verIficar se a ADM selecionada ³
									//³pelo operador e a mesma da resposta da transacao         ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

									If !Empty( cAdminis ) .AND. cTipTEF <> TEF_DISCADO
										AAdd( aSL4[nX], { "L4_ADMINIS", cAdminis } )
									EndIf
							EndIf
							// Se estiver usando Pay&Go e MV_TEFMULT = .F. faz tratamento para preencher a array aSL4 a partir do aTefDados
						ElseIf cTipTEF == TEF_DISCADO .AND. Alltrim(aPgtos[nX][3]) $ _FORMATEF .AND. !lTefMult
							If Len(aTEFDados) >= 1 .AND. Len(aTEFDados[1]) >= 15
								aAdd( aSL4[nX], { "L4_VENDTEF","S"})
								aAdd( aSL4[nX], { "L4_DATATEF",alltrim(aTefDados[1][2])})
								aAdd( aSL4[nX], { "L4_HORATEF",alltrim(aTefDados[1][3])})
								aAdd( aSL4[nX], { "L4_AUTORIZ",alltrim(aTefDados[1][5])})
								aAdd( aSL4[nX], { "L4_INSTITU",alltrim(aTefDados[1][8])})
								aAdd( aSL4[nX], { "L4_DOCCANC",alltrim(aTefDados[1][6])})
								aAdd( aSL4[nX], { "L4_DATCANC",alltrim(aTefDados[1][12])})
								aAdd( aSL4[nX], { "L4_HORCANC",alltrim(aTefDados[1][7])})
									aAdd( aSL4[nX], { "L4_NSUTEF" ,alltrim(aTefDados[1][9])})
									aAdd( aSL4[nX], { "L4_DOCTEF" ,alltrim(aTefDados[1][5])})
								aAdd( aSL4[nX], { "L4_TIPCART", alltrim(aTefDados[1][12])})
								aAdd( aSL4[nX], { "L4_FORMPG" , alltrim(aTefDados[1][20])})
								aAdd( aSL4[nX], { "L4_ADMINIS", cAdminis } )
							EndIf
						EndIf
					Else
						If (cTipTef == TEF_CENTROPAG .OR. cTipTef == TEF_CLISITEF ).AND. AllTrim(aPgtos[nX][3]) $ _FORMATEF
							If !lMVTELAFIN
								LJVERADM(@lSemRede, lTefOK)
							EndIf

							// Por estar em um For e passar pelas mesmas posicoes varias vezes,
							// as variaveis sao inicializadas novamente a cada For
							nPosData   	:= 0
							dDataTrans	:= CtoD(Space(08))
							nPosTrans	:= 0
							nValorTrans := 0
							nPosRetCart := 0

							// oTef:aRetCartao > 1 quando venda com multiplos cartoes
							nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nX][8] } ), 1)

							If nPosRetCart > 0
								// Procura pela data conforme condicao de pagamento/parcelamento (se for parcelado, procura pela data do vencimento da parcela)
								nPosData   	:= aScan(oTef:aRetcartao[nPosRetCart]:aDatas, {|x| x == aPgtos[nX][1] } )

								// Procura pelo valor da transacao (se for parcelado, procura pelo valor da parcela)
								nPosTrans	:= aScan(oTef:aRetcartao[nPosRetCart]:aValores, {|x| x == aPgtos[nX][2] } )

						        If nPosData > 0 .And. nPosTrans > 0
                                   	dDataTrans := oTef:aRetcartao[nPosRetCart]:aDatas[nPosData]
									nValorTrans := oTef:aRetcartao[nPosRetCart]:aValores[nPosTrans]

									If  dDataTrans == aPgtos[nX][1]	 .AND. nValorTrans == aPgtos[nX][2]
										cCodRede 	:= oTef:aRetCartao[nPosRetCart]:cCodRede
										cDescRede 	:= oTef:aRetCartao[nPosRetCart]:cDescRede

										cAdminis  := LJ7ConfAdm( aPgtos[nX][4][5]											, oTef:aRetCartao[nPosRetCart]:cDescAdm , .F. 									  	, aPgtos[nX][_FORMAPGTO]		   			,;
																 IIf(lTefMult,oTef:aRetCartao[nPosRetCart]:cIdCart ,NIL )	, oTef:aRetCartao[nPosRetCart]:cTipCart , oTef:aRetCartao[nPosRetCart]:nParcelas 	, oTef:aRetCartao[nPosRetCart]:cDescCart	,;
																 Nil														, nPosRetCart							 , Nil										, cDescRede								 	,;
																 Nil														, cCodRede )
									EndIf
								Endif
							Endif

							//Caso o Tef Tenha sido cancelado matem a admnistradora do aPgtos
							If Empty(AllTrim(cAdminis) )
								cAdminis  := aPgtos[nX][4][05]
							EndIf

							aSL4 := LjTEFGeraSL( 	aSL4			, "SL4"	, Nil, aPgtos[nX, 3]	, ;
													aPgtos[nX, 8]	, Nil	, Nil, Nil				, ;
													Nil				, nX )

							If !Empty( cAdminis )
								AAdd( aSL4[nX], { "L4_ADMINIS", cAdminis } )
							    If (Alltrim( aPgtos[nX][3] ) $ _FORMATEF) .AND. cTipTef == TEF_CLISITEF .AND. lUsaTEF
									cAdminis := ""
								Endif
							EndIf

						EndIf
					EndIf
				EndIf
			Next nX

			nCont := 1

			DbSelectArea( "SL4" )
			SL4->(DbSetOrder( 1 ))
			SL4->(DbSeek( xFilial( "SL4" ) + SL1->L1_NUM ))

			While !SL4->(EOF()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial( "SL4" ) + SL1->L1_NUM
				If nCont <= Len(aSL4)
			    	Lj7GeraSL( "SL4", aSL4[nCont], .F. )
			 	EndIf
		    	SL4->(DbSkip())
				nCont ++
			End
		EndIf

		LjDeLogR( SL1->L1_NUM )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ha' casos, com causa nao identificada, em que aRet nao traz o documento / pdv, na 2a. dimensao.   ³
		//³Por isso o tratamento abaixo (evita erro ao gravar  os logs da  venda)                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aRet[2]) == "C"
			cNroDoc := SL1->L1_DOC
			cNumPDV := SL1->L1_PDV
		Else
			cNroDoc := aRet[2][1]
			cNumPDV := aRet[2][2]
		EndIf
		If Empty(cNroDoc)
			cNroDoc := SL1->L1_DOC
			cNumPDV := SL1->L1_PDV
		EndIf

		LjGrLogT(	SL1->L1_NUM     , cNroDoc			, xNumCaixa()		, aTefDados			,;
					SL1->L1_DINHEIR , SL1->L1_CHEQUES	, SL1->L1_CARTAO	, SL1->L1_VLRDEBI	,;
					SL1->L1_CONVENI	, SL1->L1_VALES		, SL1->L1_FINANC	, SL1->L1_OUTROS	,;
					SL1->L1_DESCONT	, SL1->L1_DESCNF	, cNumPDV			, cSerie			,;
					If(lL1VLRPGDG,SL1->L1_VLRPGDG,0)	, If(lL1VLRPGDG,SL1->L1_VLRPGPX,0) 		)

		If cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + 	TEF_DISCADO
			If LOJA010T( "I", "V", NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, @lRelGer)
				lTefOk := LJ701AtCartao()
				lDscCupTef 	:= .T.	//se discado, indica se o comprovante TEF foi impresso

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
				lImpTefIpdv := .T.
			Else
				lErrCupTEF := .T.
			EndIf
		Else
			If (cTipTef == TEF_CENTROPAG .OR. cTipTEF == TEF_CLISITEF) //.AND. ( LjNfUsaTef(SM0->M0_CGC) .OR. lFtvdVer12 )
				If oTef:lTefOk
					If (lMFE .And. lIntegrador) .And. lLjRspFisc .And. Len(oTef:aRetCartao) > 0
						LjRspFisc(oTef:aRetCartao,.F.,aIdPgtoMfe)
						aIdPgtoMfe := {}
					EndIf	
				EndIf			
				oTEF:ImpCupTef( NIL , @lRelGer)
				lTefOk := oTef:lTefOk
				lTemTEFPend := .F.
				aTefBKP     := {}
				//Valida se já foi impresso o comprovante PBM e limpa as variáveis
				aRetPbm := LJGDadosVL() //recupera dados do pbm selecionados
				If aRetPbm[3] <> 99 .And. aRetPbm[3] <> 0
					oTEF:aRetVidaLink := Nil
					LJ7DadosVL() //zera dados pbm funcional card
				EndIf
			EndIf
		EndIf
		If lUsaTef .AND. !lTefOk
			Lj7LimpTef()
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Contadores necessarios para o PAF-ECF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjNfPafEcf(SM0->M0_CGC) .AND. !lFtvdVer12
			// Retorna o Contador Geral de Operação Não Fiscal
			nRet := IFStatus(nHdlECF, "36", @cContOnf)

			// Retorna o Contador de Comprovante de Credito ou Debito
			nRet := IFStatus(nHdlECF, "38", @cContCdc)

			If lRelGer
			    // Retorna o Contador Geral de Relatório Gerencial
				nRet := IFStatus(nHdlECF, "37", @cContRg)
			EndIf

			RecLock("SL1",.F.)
				If SL1->(ColumnPos("L1_CONTONF")) > 0
					REPLACE L1_CONTONF WITH cContOnf
				EndIf
				If SL1->(ColumnPos("L1_CONTCDC")) > 0
					REPLACE L1_CONTCDC WITH cContCdc
				EndIf
				If SL1->(ColumnPos("L1_CONTRG")) > 0
					REPLACE L1_CONTRG WITH cContRg
				EndIf
			MsUnlock()
		EndIf
	ElseIf !aRet[1]
		If cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + 	TEF_DISCADO
			lTefOk := LOJA010T( "F", "N" )
		EndIf
		If lTefOk
	  	   MsgInfo( STR0028 ) //"Transação TEF não efetuada, favor reter o cupom!"
		EndIf
	EndIf

	If !Empty( LOG_TEF )
		LjWriteLog(	LOG_TEF + M->LQ_NUM + ".TXT", "Impressão do cupom tef - " + If( aRet[1], "S", "N" ) + " / " + ;
		           	If( lTefOk, "S", "N" ) + " / " + If( lErrCupTEF, "S", "N" ) )
	EndIf

	aRetAdmTef	:= {}	// Limpa o array de retorno das AdmFinanceiras
EndIf

//Faz a impressao do comprovante de "Recarga de Celular"
If lUsaTef .And. cTipTEF == TEF_CLISITEF .And. Lj7RCImpRC()

	If oTef:lTefOk .And. oTef:nCodFuncao == 0
		oTef:nCodFuncao := 301 		//Recarga de Celular
	EndIf
	
	oTef:ImpCupTef() 			// Imprime Cupom TEF
	lTefOk 	:= oTef:lTefOk		// Se a transação TEF está OK

ElseIf lUsaTef .And. cTipTEF == TEF_CLISITEF .And. Lj7CP_OK() .And. Lj7CP_Imp()

	//-----------------------------------------------------------------------
	//Faz a impressao do comprovante de "Recarga de Cartao Presente" (Gift Card)
	//-----------------------------------------------------------------------
	If oTef:lTefOk .And. oTef:nCodFuncao == 0
		If AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "1"
			oTef:nCodFuncao := 669 		//669=Recarga de Cartão Presente (Gift Card) - (Modulo Givex)
		ElseIf AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "2"
			oTef:nCodFuncao := 264 		//264=Recarga de Cartão Presente (Gift Card) - (Modulo SQCF / Todo Cartoes)
		EndIf
	EndIf

	oTef:ImpCupTef() 			// Imprime Cupom TEF
	lTefOk 	:= oTef:lTefOk		// Se a transação TEF está OK

EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjCancCup  ºAutor  ³Vendas Clientes      º Data ³30/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela o cupom Fiscal                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjCancCup()              								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRet - Retorno se foi tudo Ok  							  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjCancCup()
Local aRet	:= {.T.,'',''}											//Retorno da funcao
Local nRet 	:= 0													//Retorno de verIficao em ECF

nRet := IfCancCup( nHdlECF )
If Lj7VerCmd( nRet )
   Inkey(8)   // dá um tempo para a impressora fazer a impressao do cancelamento
Else
   aRet[1] := .F.
   aRet[3] := STR0099 //"Falha no cancelamento do cupom"
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjCancTEF  ºAutor  ³Vendas Clientes      º Data ³30/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela a transacao Tef                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   LjCancTEF()              								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum						  							  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjCancTEF()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuário TEF e Venda com Transação Tef                    ³
//³ Verifica se o usuario e' fiscal e se o ambiente e' LINUX ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaTef .AND. LJXVERTEF(.F.)
	If lFiscal .OR. (!lFiscal .AND. GetRemoteType() <> REMOTE_LINUX )
		If cTipTef == TEF_CLISITEF
			If !oTef:lImprimiu .AND. !lTelaTefPed   // Realiza o desfazimento da Transação TEF caso não tenha sido impresso o comprovante
				oTEF:FinalTrn( 0 )
				lTefCanc :=  .T.
				MsgStop(UPPER(STR0007)+"!!!"+CTRL+STR0200+CTRL+STR0201,STR0007) //"Atenção"###"Todas as transações TEF pendentes foram canceladas!"###"Os cartões que haviam sido aprovados nesta venda, foram cancelados e deverão ser passados novamente!"###"Atenção"
			EndIf
		Else
			LOJA010t("F", "D")
			lTefCanc :=  .T.
			MsgStop(UPPER(STR0007)+"!!!"+CTRL+STR0200+CTRL+STR0201,STR0007) //"Atenção"###"Todas as transações TEF pendentes foram canceladas!"###"Os cartões que haviam sido aprovados nesta venda, foram cancelados e deverão ser passados novamente!"###"Atenção"
		EndIf
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjIncSF3   ºAutor  ³Vendas Clientes      º Data ³30/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela a transacao Tef                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjIncSF3()              								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Nenhum 													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum						  							  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj7IncSF3(	cNumNota	, cSerNota	, cCliente	, cLoja	,;
							cPdv		, lSF3		, lErroCF )

Local lProcIncSf3	:= .T.				// Se processa o SF3
Local aGetBook		:= {}
Local aLivro		:= {}
Local aImpVarSD2	:= {}
Local aAreaSL2		:= {}
Local aAreaSF4		:= {}

Default lSF3		:= .F.
Default lErroCF     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cancela NF somente se for pelo modo antigo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFisLivro
	lProcIncSf3 := SuperGetMV("MV_MAPARES") == "N"

	If cPaisLoc == "BRA" .AND. lProcIncSf3

		SF3->(dbSetOrder(4))
		IF !SF3->(DbSeek(xFilial("SF3")+Padr(cCliente, TamSX3("F3_CLIEFOR")[1])+Padr(cLoja, TamSX3("F3_LOJA")[1])+Padr(cNumNota, TamSX3("F3_NFISCAL")[1])+Padr(cSerNota, TamSX3("F3_SERIE")[1])))

			RecLock("SF3",.T.)

			REPLACE SF3->F3_FILIAL	with xFilial("SF3")
			REPLACE SF3->F3_ENTRADA	with dDatabase
			REPLACE SF3->F3_NFISCAL	with cNumNota
			REPLACE SF3->F3_SERIE  	with cSerNota
			REPLACE SF3->F3_CLIEFOR	with cCliente
			REPLACE SF3->F3_LOJA	with cLoja
			REPLACE SF3->F3_PDV     with cPDV
			REPLACE SF3->F3_EMISSAO	with dDatabase
			REPLACE SF3->F3_DTCANC	with dDatabase
			REPLACE SF3->F3_OBSERV	with "NF CANCELADA"

			MsUnLock()

		EndIf

	EndIf
EndIf

If (cPaisLoc == "ARG" .AND. lSF3) .OR. (cPaisLoc == "ARG" .AND. lErroCF)
	aAreaSL2 := SL2->( GetArea() )
	aAreaSF4 := SF4->( GetArea() )
	If SL2->( DbSeek( xFilial("SL2") + SL1->L1_NUM ) )
		While !SL2->(EOF()) .AND. ( SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM )
			SF4->( DbSeek( xFilial("SF4") + SL2->L2_TES ) )
			aImpVarSD2 := Lj010SimSD2( SL2->L2_TES )
			aLivro := GetBook( @aGetBook, aImpVarSD2, "V", SL1->L1_TXMOEDA, aLivro, "S" )
			SL2->( DbSkip() )
		End
	EndIf
	RestArea(aAreaSF4)
	RestArea(aAreaSL2)

	If Len(aLivro) > 0

		GravaLivro( @aLivro , SL1->L1_SERIE , cNumNota )

		RecLock("SF3",.F.)
		REPLACE SF3->F3_OBSERV WITH "ORC ANULADO: " + SL1->L1_FILIAL + SL1->L1_NUM
		SF3->( MsUnLock() )
		
		RecLock("SL1",.F.)
		REPLACE SL1->L1_STORC WITH "C"
		SL1->( MsUnLock() )
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7CancVendaºAutor  ³Vendas Clientes      º Data ³11/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela venda e executa os processo relacionados            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Lj7CancVenda(ExpC1)      								      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Mensagem a se apresentada							  º±±
±±º          ³ExpC2 - Numero do Cupom  									  º±±
±±º          ³ExpC3 - Serie												  º±±
±±º          ³ExpC4 - Numero do Pdv										  º±±
±±º          ³ExpL5 - so cancela caso o cupom esteja aberto				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Nenhum						  							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj7CancVenda(	cTexto		, cDoc		, cSerie	, cPdv		,;
								lSoAberto	, lTefOK	, lExistNF	, cDescErro	,;
								lSF3		, lErroCF	, lIsPedido	, aTefBKP	,;
								lTemTEFPend )

Local nRet			:= 0			// Retorno do status da impressora
Local lCancela		:= .T.			// Se deve cancelar o cupom fiscal
Local cRetorno		:= ""			// Retorno da verIficacao do status da impressora
Local aRet			:= {.T.}		// Retorno da funcao de cancelamento
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lEmitNfce	:= LjEmitNFCe()		// Sinaliza se utiliza NFC-e

Default lExistNF	:= .F.
Default cDescErro	:= ""
Default lSF3		:= .F.
Default lErroCF     := .F.
Default lIsPedido 	:= .F.
Default aTefBKP 	:= {}
Default lTemTEFPend := .F.

LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT', "Cancelamento automatico antes liberacao")

LjGrvLog(M->LQ_NUM,"Cancelamento da Venda")

If cPaisLoc <> "ARG"

	If Type("oTef") <> "U" .And. oTef:lTefOk
		aTefBKP := aClone(oTef:aRetCartao)
		lTemTEFPend := .T.
	EndIf

	LjGrvLog(M->LQ_NUM,"Configuracao do parametro MV_TEFPEND", SuperGetMV("MV_TEFPEND",,"0"))

	If SuperGetMV("MV_TEFPEND",,"0") == "0"
		LjCancTEF()
		LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT',  "tef Cancelado")
		
		If lTefCanc   // Transacao TEF foi cancelada
			lTemTEFPend := .F.  // Nao possue transacao TEF pendente
		Endif		
	EndIf
EndIf

If lSoAberto .AND. !lEmitNFCe
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se ha um cupom em aberto. Caso afirmativo, faz o    ³
	//³ cancelamento antes da abertura de outro                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet := IfStatus( nHdlECF, '5', @cRetorno )
	If nRet <> 7
		lCancela = .F.
	EndIf

EndIf

If lCancela .AND. lCupFiscal .AND. !lEmitNFCe
	aRet := LjCancCup()
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT',  "cupom Cancelado")
EndIf

//VerIfica se o comando foi executado com sucesso
If aRet[1] .OR. cPaisLoc == "ARG" .OR. lEmitNFCe .Or. lIsPafNfce
	//Inclui o registro para os livros fiscais
	Lj7IncSF3(	cDoc	, cSerie	, M->LQ_CLIENTE	, M->LQ_LOJA	,;
				cPdv	, lSF3		, lErroCF .OR. lEmitNFCe .Or. lIsPafNfce)
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT',  "SF3 Cancelamento Incluido doc->" + cDoc + " Serie->" + cSerie + " Cliente->" + M->LQ_CLIENTE + " Loja->" + M->LQ_LOJA + " Pdv->" + cPdv)
Else
	MsgStop(aRet[3])
	LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT',  "Erro no cancelamento do cupom")
EndIf

If !lEmitNFCe .And. !lIsPafNfce	//Ja possui mensagem de cancelamento da NFC-e
	MsgStop(STR0081)//"Venda cancelada devido a problema na finalização."
EndIf

LjWriteLog(LOG_TEF + M->LQ_NUM + '.TXT',  "Cancelamento Automatico liberado automatico")
Lj701Erro(aRet[1] .OR. lEmitNFCe .Or. lIsPafNfce, @lExistNF, @cDescErro)

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJVERADM  ºAutor  ³Vendas Clientes     º Data ³  09/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se achou a administradora que retornou do SITEF.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpL1 = Retorna se achou a rede                            º±±
±±º          ³ ExpL2 = Informa se TEF foi OK                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701C                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJVERADM( 	lSemRede, lTefOk, lTefManual, nLinAPgtos ,;
 							lSelTefManu)
Local nI 			:= 1 								// Variavel do For
Local nX        	:= 1								// Variavel do For
Local lRet      	:= .F.								// Retorno da Funcao
Local cAdminis  	:= ""								// Guarda o nome da administradora
Local cTipcart		:= ""								// Guarda o tipo de cartao utilizado
Local cIdCart		:= ""
Local cCodRede 		:= ""
Local cDescRede		:= ""
Local cFormCart 	:= ""
Local cDescAdm		:= ""
Local nParcelas 	:= 0
Local cDescCart		:= ""
Local nTransacoes	:= 0 								// Quantidade de Transações
Local lIsTefManu	:= .F.
Local nPosTEF 		:= 0

Default lTefManual := .F.
Default nLinAPgtos := 0
Default lSelTefManu:= .F.

If lTefOk

	lIsTefManu := lTefManual .And. nLinAPgtos > 0 .And. lSelTefManu //TEF Manual

	If lIsTefManu
		nTransacoes := 1
	Else
		nTransacoes := Len(oTef:aRetCartao)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Laco onde ira verIficar a Administradora somente³
	//³quando a forma de pagamento for Cartao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ( nX <= nTransacoes )

		If lIsTefManu
			cIdCart		:= aPgtos[nLinAPgtos][8]
			cFormCart	:= aPgtos[nLinAPgtos][3]
			nPosTEF 	:= aScan( oTef:aRetCartao, { |x|  AllTrim(x:cForma) == AllTrim(cFormCart) .And. x:cIdCart == cIdCart .And. !Empty(x:cAutoriza) } )
		Else
			cIdCart		:= oTef:aRetCartao[nX]:cIdCart
			cFormCart	:= oTef:aRetCartao[nX]:cFORMA
			nPosTEF 	:= nX
		EndIf
		
		nI := aScan( aPgtos,{ |x|, Alltrim(x[3])+AllTrim(x[8]) == Alltrim(cFormCart)+AllTrim(cIdCart) } )

		LjGrvLog( "", "Busca da cFormCart+cIdCart na aPagtos | nI",  nI )

		If nI > 0 .AND. AllTrim(aPgtos[nI][3]) $ _FORMATEF

			If nPosTEF > 0
				cDescAdm 	:= oTef:aRetCartao[nPosTEF]:cDescAdm
				cTipCart 	:= oTef:aRetCartao[nPosTEF]:cTipCart
				nParcelas	:= oTef:aRetCartao[nPosTEF]:nParcelas
				cDescCart 	:= oTef:aRetCartao[nPosTEF]:cDescCart
				cCodRede 	:= oTef:aRetCartao[nPosTEF]:cCodRede
				cDescRede 	:= oTef:aRetCartao[nPosTEF]:cDescRede
			Else
				cDescAdm 	:= ""
				cTipCart 	:= ""
				nParcelas	:= 0
				cDescCart 	:= ""
				cCodRede 	:= ""
				cDescRede 	:= ""
			EndIf

			cAdminis := LJ7ConfAdm( aPgtos[nI][4][5], cDescAdm			, @lSemrede 			, cFormCart	,;
									cIdCart			, cTipCart			, nParcelas				, cDescCart	,;
									lTefManual		, nX				, Nil					, cDescRede	,;
									Nil				, cCodRede			, lSelTefManu )

			LjGrvLog("", "ID do cartao (cIdCart)",  cIdCart )
			LjGrvLog("", "Adm. Fin retornada da funcao LJ7ConfAdm",  cAdminis )
			LjGrvLog("", "Forma de Pagamento (cFormCart)",  cFormCart )

			If Empty( cAdminis )
				HELP( " ", 1, "SEMINSTITU" )
				// ### "Administradora: " ### ". Efetue o cadastro da Administradora no arquivo SAE e salve esta venda como Orçamento."
				MsgInfo(STR0077 + TRIM(cDescAdm) + STR0078)
				lRet 		:= .F.
			Else
				//Faz o laco para atualizar a Adm. Financeira no array aPgtos caso tenha mais de uma parcela
				While ( nI <= Len(aPgtos)) .AND.(aPgtos[nI][8] == cIdCart) .AND. (AllTrim(cFormCart) == AllTrim(aPgtos[nI][3]) )
					aPgtos[nI][4][5] := cAdminis
					++nI
					LjGrvLog("", "ADMINISTRADORA QUE SERÁ GRAVADA NO L4_ADMINIS=",  cAdminis )
				End
				lRet := .T.
			EndIf
		EndIf
		nX++
	End
EndIf
Return lRet

/*/±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡…o    ³LjMnReb     ³ Autor ³ Vendas Clientes       ³ Data ³ 28/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array de recebimentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function LjMnReb(aReb, aParcTef, nArredondar)
Local nPos			:= 0					// Posição do caracter pesquisado
Local nI 			:= 0					// Contador
Local nVlrEntrada	:= 0					// Valor de Entrada
Local aCartoes		:= {}					// Array Cartões para SL4
Local cCartao 		:= ""					// Qual cartão
Local cValProt		:= ""
Default aReb 		:= {}
Default aParcTef 	:= {}
Default nArredondar := 0

If cTipTef == TEF_CLISITEF  .OR. cTipTef == TEF_CENTROPAG

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pegando os dados totalizados de cartões a serem enviados para a transacao TEF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aPgtosSint)
		If AllTrim(aPgtosSint[nI][1]) $ _FORMATEF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ VerIfica o valor da primeira parcela a ser enviada para a transação TEF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := Ascan(aPgtos,{|x| AllTrim(x[3])+AllTrim(x[8]) == AllTrim(aPgtosSint[nI][1])+AllTrim(aPgtosSint[nI][4]) } )
			nVlrEntrada := If(nPos>0,aPgtos[nPos][2],0)
			If nI = 1 .AND. nArredondar > 0
				nVlrEntrada := nVlrEntrada + nArredondar
			EndIf

			// Protecao incluida para a informacao da variavel cValProt que eh adicionada no array aReb
			If Len(aPgtosSint[nI]) > 5 .AND. Len(aPgtosSint[nI][6]) > 4
				cValProt := aPgtosSint[nI][6][5]
			Else
				cValProt := ""
			EndIf
	        Aadd(aReb,{ aPgtosSint[nI][5],;											//Data
		        	    (Val(StrTran(StrTran(aPgtosSint[nI][3],",",""),".",""))/100)+iif(nI=1,nArredondar,0),;	//Valor
		        	    aPgtosSint[nI][1],;												//Forma
		        	    aPgtosSint[nI][4],;												//ID para identIficação da forma de pagamento na operação TEF
		        	    aPgtosSint[nI][2],;												//Qtde de Parcelas
						nVlrEntrada,;													//Valor Entrada
						{Space(03),Space(3),Space(04),Space(10),Space(07),Space(15),Space(15)} , ; // //Dados do Cheque
						cValProt })
		EndIf
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a estação utilizar consulta de cheques pegar os dados analíticos de todos os cheques a serem consultados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If At("S",LjGetStation("TEFCONS")) <> 0
		For nI := 1 To Len(aPgtos)
			If Alltrim(aPgtos[nI][3]) == AllTrim(MVCHEQUE)
				Aadd(aReb,{ aPgtos[nI][1],;											//Data
							aPgtos[nI][2],;												//Valor
							aPgtos[nI][3],;												//Forma
							aPgtos[nI][8],;												//ID para identIficação da forma de pagamento na operação TEF
							1,;															//Quantidade de Parcelas
							0,;															//Valor de Entrada, para cheques podemos considerar o mesmo
							{aPgtos[nI][4][8],aPgtos[nI][4][4],aPgtos[nI][4][5],aPgtos[nI][4][6],aPgtos[nI][4][7],aPgtos[nI][4][9],aPgtos[nI][4][10]}}) //Dados do Cheque
			EndIf
		Next nI
    EndIf
Else
	For nI := 1 To Len(aPgtos)
		If AllTrim(aPgtos[nI][3]) $ _FORMATEF .OR. AllTrim(aPgtos[nI][3]) == "MH" .OR. (AllTrim(aPgtos[nI][3]) == AllTrim(MVCHEQUE) .AND. (SuperGetMV("MV_INTEEMS") .OR. At("S",LjGetStation("TEFCONS"))<>0) )
			If Alltrim(aPgtos[nI][3]) == Alltrim(MVCHEQUE)
				Aadd(aReb    , {  aPgtos[nI][1]   ,;                         //Data de vencimento
				                  aPgtos[nI][2]   ,;                         //Valor da parcela
				                  aPgtos[nI][3]   ,;                         //Forma de pagamento
				                  aPgtos[nI][4][7],;                         //Numero do cheque
				                  aPgtos[nI][4][4],;                         //Banco do cheque
				                  aPgtos[nI][4][5],;                         //Agencia do cheque
				                  aPgtos[nI][4][6],;                         //Conta do cheque
				                  nI                 })
			Else
				Aadd(aReb    , {  aPgtos[nI][1]    ,;                       //Data de vencimento
				                  aPgtos[nI][2]    ,;                       //Valor da parcela
				                  aPgtos[nI][3]    ,;                       //Forma de pagamento
				                  aPgtos[nI][4][5] ,;                       //Administradora
				                  nI               ,;                       //Parcela
				                  aPgtos[nI][4][7] }) 		           		// 4 ultimos digitos do cartao
			EndIf
			Aadd(aParcTef, {  aPgtos[nI][1]     ,;                          //Data de vencimento
			                  aPgtos[nI][2]     ,;                          //Valor da parcela
			                  aPgtos[nI][3]     ,;                          //Forma de pagamento
			                  1                 ,;
			                  aPgtos[nI][4][5]  ,;                          //Administradora
			                  aPgtos[nI][8]  	})                          //ID Cartao
		EndIf
		aCartoes := Lj010LerCartao(aPgtos[nI,3])
		If Alltrim(aPgtos[nI][3]) $ _FORMATEF .OR. AllTrim(aPgtos[nI][3]) == "MH"
			If Empty(aPgtos[nI][4][5])
				cCartao := aCartoes[1]
			Else
				cCartao := aPgtos[nI][4][5]
			EndIf
		Else
			cCartao	:= ""
		EndIf
	Next nI
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Lj7VerFretºAutor  ³ Vendas Clientes    º Data ³  27/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ IdentIfica a versao do fonte                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ??ÍÍÍ??ÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Versao do fonte para controle do calculo do frete		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7VerFret()
Local nRet := 0    		//	Armazena o controle da Versão do fonte para calculo do Frete

nRet :=	20060927 		// 27 de Setembro de 2006

Return (nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o	 |Lj701Erro   ºAutor  ³Vendas Clientes     º Data ³  02/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Tela da mensagem que controlará os erros dentro da Transação º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj701Erro(lCanCup, lExistNF, cDescErro)
Local oDlgLeg
Local oFntMsg
Local oFntTit
Local oTimer

// variaveis para o texto de detalhe

Local oBmp
Local lTelaDetalhe 	:=.F.
Local cMsgCab	 	:= ""
Local cMsgDet   	:= ""
Local cDirlog	 	:= Iif(!IsBlind(), LjLogTef(), "")
Local lErrorLock	:= .F.						//Controla se houve erro do tipo 'Error Lock Failed' ou 'Error Lock Required'
Local lUseSAT 	:= .F.						//Utiliza SAT
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lEmitNfce	:= LjEmitNFCe()		// Sinaliza se utiliza NFC-e

Default lCanCup 		:= .T. 	//Define se o cupom fiscal foi cancelado com sucesso
Default lExistNF		:= .F.
Default cDescErro		:= ""

// Verifica se utiliza SAT
lUseSAT 	:= LjUseSat()

If 'LOCK FAILED' $ Upper(cDescErro) .OR. 'LOCK REQUIRED' $ Upper(cDescErro)
	lErrorLock := .T.
EndIf

If lErrorLock
	cMsgDet := STR0112
	//"1- Verifique se o Cliente ou Produtos utilizados nesta venda estao sendo atualizados por outro usuario. A venda so podera ser concluida com acesso exclusivo ao Cliente e Produtos para atualizacao de seus dados."
ElseIf lExistNF
	cMsgDet := STR0113
	//"2- Verifique se ja nao existe um titulo a receber com o mesmo codigo na base de dados. Chave: Prefixo + Numero + Parcela + Tipo."
Else
	cMsgDet := cDescErro
EndIf

If !lTelaTefPed // Não é apenas a saída do Begin Sequence através da Tela do TEF
	If Len(cDescErro) > 0 // Se houve error.log
		cMsgDet := STR0086  + M->LQ_NUM + ".TXT" +  STR0087 + cDirlog //"O monitoramento deste tratamento pode ser analisado através do arquivo " + M->LQ_NUM +".TXT" +" no diretório: " + cDirlog
		cMsgDet +=  CTRL + cDescErro
		cMsgCab	 += STR0088 //"Ocorreu uma incosistência durante a gravação da venda. Clique em Detalhes para maiores informações."
	Else
		cMsgCab	 += STR0089 //"Ocorreu uma incosistência durante a gravação da venda." // Não existem detalhes a serem observados
	EndIf

	cMsgCab += STR0090 // "Toda a gravação contida no controle de transação foi desfeita."
	If !IsBlind()
		If LjxVerTef(.F.) .AND. lUsaTef // Se existe transação TEF e o usuário é TEF
			If cTipTef == TEF_CLISITEF // Se for Clisitef
				If !oTef:lImprimiu // Não houve impressão do comprovante TEF
					If lTefCanc // Foi possível o desfazimento, pois não houve impressão do cupom TEF
						cMsgCab += STR0091 // "O comando para desfazimento da transação TEF foi enviado com sucesso."
					EndIf
				Else
					cMsgCab += STR0092 //"Uma vez que a impressão do comprovante TEF foi efetuada, não foi possível efetuar o desfazimento. Cancele a transação TEF manualmente."
				EndIf
			ElseIf cTipTef $ TEF_SEMCLIENT_DEDICADO + ";" + TEF_COMCLIENT_DEDICADO + ";" + 	TEF_DISCADO
				If !lImpTefIpdv
					If lTefCanc // Foi possível o desfazimento, pois não houve impressão do cupom TEF
						cMsgCab += STR0093 //"O comando para desfazimento da transação TEF foi enviado com sucesso."
					EndIf
				Else
					cMsgCab += STR0092 //"Uma vez que a impressão do comprovante TEF foi efetuada, não foi possível efetuar o desfazimento. Cancele a transação TEF manualmente."
				EndIf
			EndIf
		EndIf
	EndIf
	If lCupFiscal .AND. lCanCup // Se o cupom fiscal foi cancelado com sucesso
		cMsgCab += STR0094 //"O Cupom Fiscal foi cancelado com êxito."
	EndIf

	//Quando NFC-e, deve processar e cancelar a venda
	If (lEmitNFCe .AND. !lUseSAT) .Or. lIsPafNfce
		cMsgCab += CTRL + STR0172	//"LOJA701C - Não foi possível processar NFC-e! - Venda será processada e cancelada via Job LJGRVBATCH !"
	Elseif lUseSAT
		cMsgCab += CTRL + "LOJA701C - Não foi possível processar o "+cSiglaSat+" !"	//"LOJA701C - Não foi possível processar o SAT !"
	EndIf

	If !IsBlind()

		DEFINE MSDIALOG oDlgLeg TITLE STR0095 FROM 0,0 TO 130,600 PIXEL //"Controle de Transação"
		//Adiciona Timer com 30 segundos para fechar a tela para não exceder o prazo de cancelamento de NFCE da SEFAZ (30 Minutos)
		oTimer := TTimer():New(30000, {|| oDlgLeg:End() }, oDlgLeg )
		oTimer:Activate()

		DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
		DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15

		@ 0,0  BITMAP oBmp RESNAME "LOGIN" oF oDlgLeg SIZE 100,600 NOBORDER WHEN .F. PIXEL
		@05,50 TO 45,300 PROMPT STR0096 PIXEL //"Help - Controle de Transação"
		@10,52 SAY cMsgCab PIXEL SIZE 240,200 FONT oFntMsg


		@50,200 BUTTON STR0005 PIXEL ACTION oDlgLeg:End() //"Ok"
		@50,230 BUTTON STR0097 PIXEL ACTION If(	!lTelaDetalhe,; //"Detalhes"
		(oDlgLeg:ReadClientCoors(.T.),oDlgLeg:Move(oDlgLeg:nTop,oDlgLeg:nLeft,oDlgLeg:nWidth,oDlgLeg:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
		(oDlgLeg:ReadClientCoors(.T.),oDlgLeg:Move(oDlgLeg:nTop,oDlgLeg:nLeft,oDlgLeg:nWidth,oDlgLeg:nHeight-165,,.T.),lTelaDetalhe:=.F.))

		@ 67,50 TO 140,300 PROMPT STR0098 PIXEL //"Descrição do Erro"
		@ 73,52 GET oMsgDet VAR cMsgDet FONT oFntMsg MEMO size 245,65  PIXEL

		ACTIVATE MSDIALOG oDlgLeg CENTERED

	Else
		Conout(cMsgCab,cMsgDet)
	EndIf

EndIf


//Restaura todas as variáveis Staticas que auxiliam na exibição da mensagem
lImpTefIpdv := .F.
cDescErro 	:= ""
lTelaTefPed	:= .F.
lCupFiscal 	:= .F.

Return Nil

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjVerIfErro ³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina analizadora do erro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONA010                                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjVerIfErro(e)
Local lRet := .F.
Local cNumOrc := If(Type("M->LQ_NUM")<>"U",M->LQ_NUM,SL1->L1_NUM)

If e:gencode > 0

	LjGravaLog( .T., SL1->L1_NUM, Replicate("*", 40))
	LjGravaLog( .T., SL1->L1_NUM, "DESCRIPTION:" + e:DESCRIPTION)
	LjGravaLog( .T., SL1->L1_NUM, "ERRORSTACK:" + e:ERRORSTACK)
	LjGravaLog( .T., SL1->L1_NUM, Replicate("*", 40))

    cTextoErro := "DESCRIPTION: " + e:DESCRIPTION + CTRL
    cTextoErro += "ERRORSTACK:" + CTRL
    cTextoErro += e:ERRORSTACK

	LjGrvLog(cNumOrc,"ERRO: ", cTextoErro)

    lRet:=.T.

	Break
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj701CvPgt  ³ Autor ³ Vendas Clientes       ³ Data ³ 28/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte os valores do aPgtos para a moeda a venda            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA701C                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj701CvPgt()
Local nX 		:= 0	// Contador de For
Local nTotParcs := 0	// Total de Parcelas

If Len(aPgtos) > 0
	For nX := 1 To Len(aPgtos)
		nTotParcs += Round(	xMoeda(	aPgtos[nX][_MOEORIPGT]	,	aPgtos[nX][_MOEDA]	,	nMoedaCor	,	dDataBase,;
									nDecimais+1)			,	nDecimais	)
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma a nota de credito utilizada, pis o aPgtos neste momento³
//³esta sem as notas utilizadas                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotParcs := nTotParcs + nNCCUsada

Return nTotParcs

/*/{Protheus.doc} LjRecalFis
Refaz o calculo fiscal dos produtos da venda  
@type	Function
@author	Vendas Clientes 
@since	08/07/07
@param 
@return Logico - .T.
/*/
Function LjRecalFis( aItens		, lJob		, lEmiteNF	, nQtdItens	,;
					nTotItens	, lOrcFilVen, nValRes	, nQtdEntre )

Local nConta        := 0				// Contador do For
Local nFrete        := 0				// Valor do Frete
Local nDespesa      := 0				// Valor das despesas
Local nSeguro       := 0				// Valor do seguro
Local nDescProp     := 0				// Valor de Desconto Proporcional
Local cCodIss       := ""				// Codigo do ISS utilizado
Local nAbatIss		:= 0				// Valor para abatimento no ISS - campo L2_ABATISS
Local cTipFrete  	:= "" 				// Tipo do Frete
Local nAcrPropIt 	:= 0				// Valor do Acrescimo Proporcional
Local nVlrTotIts  	:= 0				// Valor Total dos Itens
Local lCalcIPI      := .T.
Local cTpFrete 		:= ""
local nFreteProp 	:= 0
Local nDespeProp 	:= 0
Local nSegurProp 	:= 0
Local lScreen	 	:= .T.
Local aSxFci		:= LjCFciParam()
Local lFciVlImpor	:= SL2->(ColumnPos("L2_VLIMPOR")) > 0 .And. SLR->(ColumnPos("LR_VLIMPOR")) > 0 .And. aSxFci[5] .And. aSxFci[6]
Local lFciCod		:= SL2->(ColumnPos("L2_FCICOD")) > 0 .And. SLR->(ColumnPos("LR_FCICOD")) > 0 .And. aSxFci[4] .And. aSxFci[8]
Local lClasFis		:= SL2->(ColumnPos("L2_CLASFIS")) > 0 .And. SLR->(ColumnPos("LR_CLASFIS")) > 0	//Classificação Fiscal do Produto
Local nValMer		:= 0	
Local lFRTECF13  	:= ExistBlock("FRTECF13") 						// PE para indicar se o ECF faz o arredondamento (.T.) ou truncamento (.F.) dos valores.
Local lStatusImp13	:= .F.											// Pega o retorno do PE FRTECF13 para verificar arredondamento
Local lMvArrefat	:= (SuperGetMv("MV_ARREFAT") == "S")
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()								//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701")	//Nome da Rotina
Local lIsVdaSAT 	:= .F. 									//Indica se eh venda SAT
Local lAbatISS 		:= SL2->(ColumnPos("L2_ABATISS")) > 0	// Verifica se existe o campo L2_ABATISS
Local cCliEnt		:= ""									// Cliente Entrega
Local cLojEnt		:= ""									// Loja Entrega

Default lJob 		:= .F.
Default lEmiteNF 	:= .T.
Default nQtdItens 	:= Len(aItens)
Default nTotItens 	:= 0
Default lOrcFilVen 	:= .F.
Default nValRes		:= 0
Default nQtdEntre	:= nQtdItens

If MaFisFound("NF")

	// Salva dados do cliente Entrega
	If !Empty( MaFisRet(,"NF_CLIENT") )
		cCliEnt := MaFisRet(,"NF_CLIENT")
		cLojEnt := MaFisRet(,"NF_LOJENT")
	EndIf

	//Finaliza as variaveis fiscais
	MaFisEnd()
EndIf

cTpFrete := Lj7TpFrete(SL1->L1_CLIENTE,SL1->L1_LOJA)

If lJob
    lCalcIPI	:= (SL1->L1_VALIPI > 0)
    cTpFrete	:= IIf( Empty(cTpFrete) .And. SL1->L1_TPFRET == "S", SL1->L1_TPFRET, cTpFrete)

	//Inicializa as variaveis fiscais
	MaFisIni(	SL1->L1_CLIENTE	, SL1->L1_LOJA	, "C"		, "S"  		,;
				SL1->L1_TIPOCLI	, NIL	    	, NIL		, .F. 		,;
				"SB1"			, cNomeProg 	, NIL		, NIL		,;
				NIL			  	, NIL			, NIL		, cCliEnt	,;
				cLojEnt			, NIL			, lEmiteNF	, lCalcIPI	,;
				NIL             , NIL        	, NIL 		, NIL		,;
				NIL             , cTpFrete )
Else
lCalcIPI    := Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_VALIPI"})	 > 0
    cTpFrete	:= IIf( Empty(cTpFrete) .And. (M->LQ_TPFRET == "0" .or. M->LQ_TPFRET == "S" ), "S", cTpFrete)

	//Inicializa as variaveis fiscais
	MaFisIni(	M->LQ_CLIENTE	, M->LQ_LOJA	, "C"		, "S"  		,;
				M->LQ_TIPOCLI   , NIL         	, NIL		, .F. 		,;
				"SB1"         	, cNomeProg 	, NIL		, NIL		,;
				NIL			  	, NIL			, NIL		, cCliEnt	,;
				cLojEnt			, NIL			, lEmiteNF	, lCalcIPI	,;
				NIL             , NIL        	, NIL 		, NIL		,;
				NIL             , cTpFrete )
EndIf

LjSatMxFis()

lIsVdaSAT := !Empty(MaFisRet(,'NF_SERSAT')) //Verifica se eh venda SAT

If Type("nDecimais") == "U"
    nDecimais := MsDecimais(nMoedaCor)
EndIf

If lJob .OR. lOrcFilVen
	nFrete            := SL1->L1_FRETE		// Valor do Frete
	nDespesa          := SL1->L1_DESPESA	// Valor das despesas
	nSeguro           := SL1->L1_SEGURO		// Valor do seguro

	If SL1->L1_TPFRET == "S" .Or. SL1->L1_TPFRET == "0" 	// Sem Frete
		cTipFrete := "0"
	ElseIf SL1->L1_TPFRET == "C" .Or. SL1->L1_TPFRET == "1" // CIF
		cTipFrete := "1"
	ElseIf SL1->L1_TPFRET == "F" .Or. SL1->L1_TPFRET == "2" // FOB
		cTipFrete := "2"
	ElseIf SL1->L1_TPFRET == "T" .Or. SL1->L1_TPFRET == "3" // Terceiros
		cTipFrete := "3"
	ElseIf SL1->L1_TPFRET == "R" .Or. SL1->L1_TPFRET == "4" // Próprio Remetente
		cTipFrete := "4"
	ElseIf SL1->L1_TPFRET == "D" .Or. SL1->L1_TPFRET == "5" // Próprio Destinatário
		cTipFrete := "5"
	EndIf
Else
	nFrete            := M->LQ_FRETE		// Valor do Frete
	nDespesa          := M->LQ_DESPESA		// Valor das despesas
	nSeguro           := M->LQ_SEGURO		// Valor do seguro

	If M->LQ_TPFRET == "S" .Or. M->LQ_TPFRET == "0"		// Sem Frete
		cTipFrete := "0"
	ElseIf M->LQ_TPFRET == "C" .Or. M->LQ_TPFRET == "1" // CIF
		cTipFrete := "1"
	ElseIf M->LQ_TPFRET == "F" .Or. M->LQ_TPFRET == "2" // FOB
		cTipFrete := "2"
	ElseIf M->LQ_TPFRET == "T" .Or. M->LQ_TPFRET == "3" // Terceiros
		cTipFrete := "3"
	ElseIf M->LQ_TPFRET == "R" .Or. M->LQ_TPFRET == "4" // Próprio Remetente
		cTipFrete := "4"
	ElseIf M->LQ_TPFRET == "D" .Or. M->LQ_TPFRET == "5" // Próprio Destinatário
		cTipFrete := "5"
	EndIf
EndIf

If !lFtvdVer12
	nVlrTotIts := nTotItens
	
	If aItens[Len(aItens)][__ACRSFIN] > 0 .AND. cTipFrete $ "12345" // Frete FOB
		nVlrTotIts := nTotItens - nFrete - nDespesa - nSeguro
	Else
		nVlrTotIts := nTotItens
	Endif

	//Loop para incluir os itens da venda
	For nConta := 1 To nQtdItens
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desconto Proporcional do Item em relacao do desconto total  ³
		//³realizado na venda.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDescProp := aItens[nConta,__DESCPRO]
		nAcrPropIt:= aItens[nConta,__ACRSFIN]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o SL2 no item correto, para a funcao LjxPropItem()³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL2->(DbGoTo(aItens[nConta,__RECNO]))

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+aItens[nConta,__PRODUTO]))

		cCodIss := Alltrim(MaSBCampo("CODISS"))

		If LjIsTesISS(SL1->L1_NUM,SL2->L2_TES) //Item de "servico" não realiza rateio de FRETE
			nFreteProp := 0
			nDespeProp := 0
			nSegurProp := 0
			
		ElseIf nValRes > 0		// Se o item for diferente de retira e tiver valor de frete nele
			If !Empty(aItens[nConta][__ENTREGA])  .AND. !(aItens[nConta][__ENTREGA] $ "2|4") .AND. (aItens[nConta][__FRETE] > 0 .OR. !lJob )
				If nQtdEntre > 1													// proporcionar caso haja mais de um item de reserva
					nFreteProp	:= LjxPropRes(nValRes, nFrete  , lScreen) 	// Valor do frete do item
					nDespeProp	:= LjxPropRes(nValRes, nDespesa, lScreen)	// Valor da despesa do item
					nSegurProp	:= LjxPropRes(nValRes, nSeguro , lScreen)	// Valor do seguro do item
				Else
					nFreteProp := nFrete
					nDespeProp := nDespesa
					nSegurProp := nSeguro
				EndIf
			Else 																//Caso não seja item de retira posterior ou entrega
				nFreteProp := 0
				nDespeProp := 0
				nSegurProp := 0
			EndIf
		ElseIf cTipFrete $ "12345"  // CIF FOB
			If nQtdItens > 1	// proporcionar caso haja mais de um item
				nFreteProp	:= LjxPropRes(nTotItens, nFrete  , lScreen, nDescProp, nAcrPropIt ) 	// Valor do frete do item
				nDespeProp	:= LjxPropRes(nTotItens, nDespesa, lScreen, nDescProp, nAcrPropIt )	// Valor da despesa do item
				nSegurProp	:= LjxPropRes(nTotItens, nSeguro , lScreen, nDescProp, nAcrPropIt )	// Valor do seguro do item
			Else
				nFreteProp := nFrete
				nDespeProp := nDespesa
				nSegurProp := nSeguro
			EndIf
		Else																		//Caso não tenha item de retira posterior ou entrega na venda
			nFreteProp := 0
			nDespeProp := 0
			nSegurProp := 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para tratar se arredonda ou trunca o valor da mercadoria    ³
		//³ para não causar diferença de valor entre o TOTAL e a BASEICM.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIsVdaSAT //Eh Venda SAT
			//Arredondamento conforme regra do Manual do SAT
			nValMer := LjArredSat(aItens[nConta,__PRCTAB] * aItens[nConta,__QUANT], TamSx3("D2_TOTAL")[2])
		ElseIf lFRTECF13
			lStatusImp13 := ExecBlock("FRTECF13")
			If lStatusImp13
				nValMer := a410Arred((aItens[nConta,__PRCTAB] * aItens[nConta,__QUANT] ),"D2_TOTAL",nMoedaCor) 
			Else
				nValMer := NoRound(aItens[nConta,__PRCTAB] * aItens[nConta,__QUANT], nDecimais)
			EndIf
		Else
			If lMvArrefat
				nValMer := a410Arred((aItens[nConta,__PRCTAB] * aItens[nConta,__QUANT] ),"D2_TOTAL",nMoedaCor)
			Else
				nValMer := NoRound(aItens[nConta,__PRCTAB] * aItens[nConta,__QUANT], nDecimais)
			EndIf
		EndIf
		
		If SL2->(ColumnPos("L2_ABATISS")) > 0
			nAbatIss := aItens[nConta,__ABATISS]
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona as variaveis nas funcoes fiscais                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAdd(	aItens[nConta,__PRODUTO],;					// Produto
					aItens[nConta,__TES],;               		// TES
					aItens[nConta,__QUANT],;                	// Quantidade
					aItens[nConta,__VRUNIT],;            		// Preco unitario
					aItens[nConta,__DESCITEM] + aItens[nConta,__DESCFIN] + aItens[nConta,__DESCPRO],;	// Valor do desconto // retirada o acrescimo porque contabilizaria na Matxfis causando inconformidade
					"",;                                     	// Numero da NF original
					"",;                                     	// Serie da NF original
					0,;                                      	// Recno da NF original
					nFreteProp,;       							// Valor do frete do item
					nDespeProp,;      							// Valor da despesa do item
					nSegurProp,;       		 					// Valor do seguro do item
					0,;                                     	// Valor do frete autonomo
					nValMer,;  									// Valor da mercadoria
					0 ,;                                                       // Valor da embalagem
					,;	// 15-RecNo do SB1
					,;	// 16-RecNo do SF4
					,;  // 17-Item
					,;	// 18-Despesas nao tributadas - Portugal
					,;	// 19-Tara - Portugal
					,;	// 20-CFO
					,;  // 21-Array para o calculo do IVA Ajustado (opcional)
					,;	// 22-Concepto
					,;	// 23-Base Veiculo
					0,;	// 24-Lote Produto
					0,;	// 25-Sub-Lote Produto
					nAbatIss,;	// 26-Valor do Abatimento ISS - L2_ABATISS
					Iif(cCodIss==Nil , "" ,cCodIss)) // 27-Codigo ISS
					
		If aItens[nConta,__ACRSFIN] > 0
			MaFisAlt("IT_ACRESCI", aItens[nConta,__ACRSFIN], nConta) 
		EndIf

		If aSxFci[1] .And. aSxFci[9] .And. (lFciVlImpor .Or. lFciCod) .And. lClasFis
			LjCRetFci(aItens[nConta,__PRODUTO], aItens[nConta,__NLOTE], aItens[nConta,__LOTECTL],,, MaFisRet(nConta,"IT_CLASFIS"), nConta)
		EndIf

	Next nConta
ElseIf lFtvdVer12
	nVlrTotIts := nTotItens

	If aItens[Len(aItens)][__ACRSFIN] > 0 .AND. cTipFrete $ "12345" // Frete FOB
		nVlrTotIts := nTotItens - nFrete - nDespesa - nSeguro
	Else
		nVlrTotIts := nTotItens
	EndIf

	//Loop para incluir os itens da venda
	For nConta := 1 To nQtdItens
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desconto Proporcional do Item em relacao do desconto total  ³
		//³realizado na venda.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDescProp := aItens[nConta,__DESCPRO]
		nAcrPropIt:= aItens[nConta,__ACRSFIN]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o SL2 no item correto, para a funcao FTVDxPropItem()³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL2->(DbGoTo(aItens[nConta,__RECNO]))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona as variaveis nas funcoes fiscais                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+aItens[nConta,__PRODUTO]))

		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+aItens[nConta,__TES]))

		MaFisIniLoad(	nConta						,;	//Numero do Item no Acols
						{aItens[nConta,__PRODUTO]	,;	//IT_PRODUTO
						aItens[nConta,__TES]		,; 	//IT_TES
						Alltrim(MaSBCampo("CODISS")) ,; 	//IT_CODISS
						aItens[nConta,__QUANT]		,;	//IT_QUANT
						""							,; 	//IT_NFORI
						""							,; 	//IT_SERIORI
						SB1->(RecNo())				,;	//IT_RECNOSB1
						SF4->(RecNo())				,;	//IT_RECNOSF4
						0  							}) 	//IT_RECORI

		If LjIsTesISS(SL1->L1_NUM,SL2->L2_TES) //Item de "servico" não realiza rateio de FRETE
			nFreteProp := 0
			nDespeProp := 0
			nSegurProp := 0
			
		ElseIf cTipFrete $ "12345"  // CIF FOB
			If nQtdItens > 1	// proporcionar caso haja mais de um item
				nFreteProp	:= LjxPropRes(nTotItens, nFrete  , lScreen, nDescProp, nAcrPropIt ) 	// Valor do frete do item
				nDespeProp	:= LjxPropRes(nTotItens, nDespesa, lScreen, nDescProp, nAcrPropIt )	// Valor da despesa do item
				nSegurProp	:= LjxPropRes(nTotItens, nSeguro , lScreen, nDescProp, nAcrPropIt )	// Valor do seguro do item
			Else
				nFreteProp := nFrete
				nDespeProp := nDespesa
				nSegurProp := nSeguro
			EndIf

			MaFisLoad("IT_FRETE"	,nFreteProp, nConta)
			MaFisLoad("IT_DESPESA"	,nDespeProp, nConta)
			MaFisLoad("IT_SEGURO"	,nSegurProp, nConta)						
		EndIf

		// Caso tenha abatimento no calculo de ISS carrega a MatxFis
		If lAbatISS
			nAbatIss := aItens[nConta,__ABATISS]
			If nAbatIss > 0
				MaFisLoad("IT_ABVLISS"	,nAbatIss ,nConta)
			EndIf
		EndIf

		MaFisLoad("IT_VALMERC"	,a410Arred((aItens[nConta,__PRCTAB] * aItens[nConta,__QUANT] ),"D2_TOTAL") + aItens[nConta,__ACRSFIN] ,nConta)
		MaFisLoad("IT_PRCUNI"	,aItens[nConta	,__VRUNIT]															,nConta)
		MaFisLoad("IT_DESCONTO"	,aItens[nConta	,__DESCITEM] + aItens[nConta,__DESCPRO] + aItens[nConta,__DESCFIN] ,nConta)

		MaFisRecal("",nConta)

		If aSxFci[1] .And. aSxFci[9] .And. (lFciVlImpor .Or. lFciCod) .And. lClasFis
			LjCRetFci(aItens[nConta,__PRODUTO], aItens[nConta,__NLOTE], aItens[nConta,__LOTECTL],,, MaFisRet(nConta,"IT_CLASFIS"), nConta)
		EndIf

		MaFisEndLoad(nConta,2)

	Next nConta
EndIf

//Atribui o valor do Frete, Seguro, Despesa (desta forma eh rateado automaticamente nos itens pela MatxFis (IT_FRETE, IT_SEGURO, IT_DESPESA)
// Somente quando não houver itens de reserva ou retira posterior
If nValRes = 0
	If nFrete > 0
		MaFisAlt( "NF_FRETE", nFrete )
	EndIf
	If nSeguro > 0
		MaFisAlt( "NF_SEGURO", nSeguro )
	EndIf
	If nDespesa > 0
		MaFisAlt( "NF_DESPESA", nDespesa )
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7GeraEntºAutor  ³Vendas Clientes     º Data ³  14/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a gravacao do Pedido de Venda, para vendas em que a    º±±
±±º          ³ entrega e emissao de Documento Fiscal sera realizado pelo  º±±
±±º          ³ modulo de Faturamento.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7GeraEnt(aSL1		, aSL2		, cFilEnt, 	 cOrcFilho	,;
					lJob 		, lAlterOrc	, cFilLoc, 	 cFilRes	,;
					cLjCliente	, cLjLojCli	, lExistVfe, cNumPai 	,;
					lAvCred	)
Local aCabPed		:= {}											//Cabecalho das NFs
Local aItensPed		:= {}											//Itens das NFs
Local aLinhaPed		:= {}											//Itens das NFs
Local aRet			:= {}											//Retorno da Funcao
Local aRetRes		:= {}											//Retorno da Funcao de Cancelamento da Reserva
Local aReserva		:= {}											//Array com os Dados da Reserva para Cancelamento
Local aSL1Tmp		:= {}											//Array para gravacao do Pedido no Orcamento Filho
Local aSL2Tmp		:= {}											//Array para gravacao do Pedido no Orcamento Filho

Local cCondPag		:= SuperGetMV("MV_LJCONDP", NIL, "")			//Condicao de Pagamento para Emissao do Pedido de Venda
Local cTES			:= ""											//TES utilizado para a geracao do Pedido de Venda
Local cFilBkp		:= cFilAnt										//Guarda a Filial Atual
Local cPedido		:= ""											//Numero do Pedido de Venda

Local nI			:= 0											//Contador
Local nCpo			:= 0											//Contador
Local nItens		:= Len(aSL2)									//Quantidade de Itens
Local nPosItem		:= 0											//Posicao do Item no aSL2
Local nTamC6It		:= TamSx3("C6_ITEM")[1]							//Tamanho do Campo C6_ITEM
Local nPosCli		:= 0											//Posicao do Cliente no aSL1
Local nPosLoj		:= 0											//Posicao da Loja no aSL1
Local nPosTransp	:= 0											//Posicao da Transportadora no aSL1
Local nPosVeicul	:= 0											//Posicao do Veiculo no aSL1
Local nPosTipoCli	:= 0											//Posicao do Tipo do Cliente no aSL1
Local nPosEmissao	:= 0											//Posicao da Emissao no aSL1
Local nPosVend		:= 0											//Posicao do Vendedor no aSL1
Local nPosFrete		:= 0											//Posicao do Campo do Frete no aSL1
Local nPosSeguro	:= 0											//Posicao do Campo do Seguro no aSL1
Local nPosDespesa	:= 0											//Posicao do Campo da Despesa no aSL1
Local nPosTpFrete	:= 0											//Posicao do Campo do Tipo do Frete aSL1
Local nPosDescNF	:= 0											//Posicao do Percentual de Desconto no aSL1
Local nPosCabDes  	:= 0
Local nPosJuros		:= 0											//Posicao do Percentual de Juros no aSL1
Local nPosProd		:= 0											//Posicao do Produto no aSL2
Local nPosDescri	:= 0											//Posicao da Descricao do Produto no aSL2
Local nPosUM		:= 0											//Posicao da Unidade de Medida no aSL2
Local nPosQtde		:= 0											//Posicao da Quantidade no aSL2
Local nPosVrUnit	:= 0											//Posicao do Valor Unitario no aSL2
Local nPosVlrItem	:= 0											//Posicao do Valor do Item no aSL2
Local nPosLocal		:= 0											//Posicao do Armazem no aSL2
Local nPosPrcTab	:= 0											//Posicao do Preco de Tabela no aSL2
Local nPosReserv	:= 0											//Posicao da Reserva no aSL2
Local nPosTurno		:= 0											//Posicao de Turno de entrega
Local nPosSolCom	:= 0											//Posicao da Solicitacao de compras
Local nPosLoteCTL	:= 0											//Posicao do Lote
Local nPosLote		:= 0											//Posicao do SubLote
Local nPosLocaliz	:= 0											//Posicao da Localizacao no sSL2
Local nPosTpEnt		:= 0											//Posição do Tipo de Entrega no aSL2

Local nPDesc		:= 0											//Percentual de Desconto no Total
Local nVdesCab		:= 0
Local nPJuros		:= 0											//Percentual de Juros no Total

Local nQtdeSC       := 0											//Quantidade da solicitacao de compras
Local nPosOrcRes	:= 0											// Posicao do campo que indica o orcamento que esta fazendo a reserva
Local lRet			:= .T.											//Retorno da Funcao
Local lLJ7046		:= ExistBlock("LJ7046")							//VerIfica se existe o Ponto de Entrada LJ7PED
Local lLJ7065		:= ExistBlock("LJ7065")							//PE que subistitui o MATA410I chamado na geracao dos itens do pedido
Local lLJ7066		:= ExistBlock("LJ7066")							//PE que subistitui o M410STTS chamado na geracao do pedido
Local cNumSc5		:= ""											// Numero do Pedido	- Inclusao
Local cMay      	:= ""											// Variavel auxiliar
Local nY			:= 0                                         	// Contador
Local lLiber 		:= .F.											// Compatibilizacao com o SIGAFAT
Local lTransf		:= .F.                                      	// Compatibilizacao com o SIGAFAT
Local lLiberOk 		:= .T.											// Compatibilizacao com o SIGAFAT
Local lResidOk 		:= .T.											// Compatibilizacao com o SIGAFAT
Local lFaturOk 		:= .F.											// Compatibilizacao com o SIGAFAT
Local lTLVReg  		:= .F.											// Compatibilizacao com o SIGAFAT
Local cMV_LJTESPE	:= SuperGetMV("MV_LJTESPE", NIL, "501")			// TES utilizado para a geracao do Pedido de Venda
Local lExecParTES   := Substr(cMV_LJTESPE,1, 1) == "&"             	// Controla se pode macro-executar o parametro MV_LJTESPE
Local xRet  														// Retorno do parametro MV_LJTESPE, se for macro-executado
Local lTESInvalido  := .F.											// TES invalido no retorno do MV_LJTESPE (macro-execucao) ou TES inteligente
Local cTipOper		:= Padr("V",TamSx3("FM_TIPO")[1])				// Tipo de operacao entrega futura
Local nPosMostruario:= 0											//Posicao do campo MOSTRUARIO/SALDAO
Local nPosObsMostr  := 0											//Posicao da observacao do mostruario/saldao
Local lC6ItemGar	:= SC6->(ColumnPos("C6_ITEMGAR")) > 0
Local lC6OrcGar		:= SC6->(ColumnPos("C6_ORCGAR")) > 0
Local nPosItemGar	:= 0
Local nC5_Moeda     := 1                                            // Moeda do pedido de venda
Local cC5_TipLib    := SuperGetMv("MV_LJLIBPE",.F. , "1")           // Tipo de liberacao  1-Libera por item \ 2-Libera por pedido
Local cC5_TpCarga   := If(SuperGetMV("MV_LJGCOMS", NIL, .F.),'1','2')// Carga  1-Utiliza \ 2-Nao utiliza
Local cC5_GeraWMS   :="1"                                           // GERAOSWMS  1-No Pedido \ 2-Na Montagem\ 3-Na utilizacao
Local cC6_TpOp      :="F"                                           // Tipo de Operacao 1 -Firme \ 2-Prevista
Local lFTVD7046		:= ExistBlock("FTVD7046")						//VerIfica se existe o Ponto de Entrada LJ7PED
Local cCFOP			:= ""											// Variavel usada para tratar o CFOP que sera gravado no item do pedido
Local aDadosCfo		:= {}											// Array para montagem do tratamento do CFOP
/*Tratamento para eCommerce */
Local lECommerce 	:= SuperGetMV("MV_LJECOMM",,.F.) .AND. (Posicione("SL1",1,xFilial("SL1")+cOrcFilho,"L1_ECFLAG") == "1")
Local lMvLjIPEn		:= SuperGetMV("MV_LJIPENP",, .F.)

// Variáveis incluidas para atender as necessidades da integração com E-Commerce
Local aItPedPres	:= {}											//Itens das NFs Presente
Local aAxlItens		:= {}                                           //Var Generica para comportar aItens
Local nPosECPresn   := 0											//Posicao do Presente no sSL2
Local nPosECPedS	:= 0
Local nPosECMEN		:= 0
Local nCont         := 0											//Contador
Local cTESPRESN		:= SuperGetMv("MV_LJECOMC",NIL,"")             //Verifica o TES configurado como Presente
Local cManPad		:= SuperGetMv("MV_LJECOMD",NIL,"")             //Mensagem padrao para pedido de venda de presente e-Commerce
Local cPedPRESN		:= "2"											//Define se o pedido é Presente ou Nao
Local cCFOPPRES		:= ""                                           //CFOP de TES de Presente
Local cPedPai		:= ""											//Pedido Pai para amarração com o pedido presente
Local cPedFilho		:= ""											//Pedido Filho que eh gerado para Presente
Local nECVezes		:= 1
Local lMultEndEnt	:= SL2->(ColumnPos("L2_CLIENT")) > 0 .AND. SL2->(ColumnPos("L2_CLILOJA")) > 0 // Checa se existe a opcao de entrega para multi enderecos
Local nPosClEntrega := 0
Local nPosLojEntrega:= 0
Local nPosC6SolCom	:= 0										// Posição Solicitação de Compras
Local nPosC6Filial	:= 0										// Posicção da Filial tabela SC6
Local lGerSolCom	:= .F.
Local nPosL1Desc	:= 0										// Flag Gerou Solicitação Compra
Local aArea         := GetArea()
Local nIPIDesc		:= 0										//Valor de Desconto no IPI
Local nPrecoTab		:= 0										//Preco de Tabela
Local aAx2Itens		:= {}
Local cTesEnt		:= ""
Local aDadosNf		:= {}
Local cOrcPai		:= ""
Local nPosAux		:= 0
Local aBkpSl1		:= {}
Local aAreaTmp 		:= {}
Local cCliEntreg 	:= ""										//Cliente de Entrega
Local cLojEntreg 	:= ""
Local nPosCodLis 	:= 0
Local cCodLisPre 	:= "" 										//Codigo da Lista de Presente
Local nPosClasFis	:= 0										//Classificação Fiscal do Produto
Local cClasFis		:= ""										//Classificação Fiscal do Produto
Local nPosFilRes	:= 0										//Filial efetuada reserva VFE
Local nPosIsVFE		:= 0										//Se eh VFE
Local cCFOPEnt		:= 0
Local aSF4Ord		:= {}
Local nTotIPI		:= 0 										//Valor total do IPI   - MatxFis
Local nTotIPIEn     := 0 										//Valor total do Embutido
Local nCasasIPI		:= SLR->(TamSX3("LR_VALIPI")[2])			//Numero de Casas do IPI
Local lMVRNDIPI 	:= SuperGetMV("MV_RNDIPI", NIL, .F.) 			//IPI Arredondado?
Local lMVLjDtIPI 	:= SuperGetMv("MV_LJDTIPI", , .F.) 			//define se a diferença entre o IPI embutido e o calculado será lançado como desconto no total da NF
Local lCentroDL     := SuperGetMv("MV_LJCDL",, .F.)             //Ativa a VFE com Centro de Distribuicao Matriz x Local
Local aAreaSA1		:= {}											//Area de Trabalho SA1
Local cItem			:= Space(nTamC6It)
Local lC6CodLP		:= SC6->(ColumnPos("C6_CODLPRE")) > 0		//Lista de presente
Local lC6ITLtP		:= SC6->(ColumnPos("C6_ITLPRE")) > 0			//Lista de presente
Local nPosItLtPre	:= 0
Local lLstPre		:= .F.										//É lista de presente
Local cTESList		:= SuperGetMV("MV_LJLPTSV",,"")				//Tipo de Entrada/Saida padrao para o Pedido de Venda
Local cTpOperLst	:= SuperGetMV("MV_LJLPTIV",,"")	            //Tipo da Operacao para o Pedido de Venda (TES Inteligente)
Local nRecSM0Bkp 	:= 0 										//Guarda o Recno da SM0 para reposicionar depois corretamente
Local nTent 		:= 0										// Tentativas para pegar a numeracao do SC5
Local nSaveSx8 		:= GetSx8Len()								// Numeracao do SX8
Local lPosL2ITESC6	:= SL2->(ColumnPos("L2_ITESC6")) > 0
Local nPosMenNota	:= 0									//Posiçao L1_MENNOTA
Local nPosTes		:= 0										// Posicao da TES
Local nAux			:= 0									// posicao do campo temporario CONTADOR_PED protecao no retorno do PE LJ7046
Local nPosEspeci	:= 0
Local nPosVolume	:= 0
Local nPosPLiq		:= 0
Local nPosPBru		:= 0
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nPosNSerie	:= 0        //Numero de série
Local nPosDtVal		:= 0        //Validade do lote
Local lLiberou 		:= .F.
Local cClassFis		:= ''		//Código da classificação Fiscal
Local nPosPedEco    := 0        //Posição do campo L1_ECPEDEC
Local nPosIndPres   := 0        
Local nPosInterMD   := 0      
Local nPosTesC6     := 0
Local nPosCfC6      := 0
Local nPosClaC6     := 0
Local nPosQtdVen    := 0		// -- Utilizado para busca da posição do campo C6_QTDVEN no array de itens do pedido de venda
Local nPosQtdLib    := 0		// -- Utilizado para busca da posição do campo C6_QTDLIB no array de itens do pedido de venda

Local lLJTESPED		:= ExistBlock("LJTESPED")				//VerIfica se existe o Ponto de Entrada LJTESPED
Local lLJTESSFat	:= ExistBlock("LJTESSFA")				//VerIfica se existe o Ponto de Entrada LJTESSFA
Local lLJTDESI    	:= SuperGetMV("MV_LJTDESI", ,0)	== 1	//Parametro para controlar o tipo de desconto na integração 0 = desligado padrao, 1 = desconto no valor bruto IPI(cabeçalho)
Local nQtdItens		:= 0
Local nQtdeVen		:= 0

Local lMV_LJCTRES	:= SuperGetMV("MV_LJCTRES",,.F.) //Controla quantidade reservada. Não apaga a informação B2_RESERVA mesmo com o parâmetro MV_LJPVLIB=1 

If nCasasIPI = 0
	nCasasIPI := SLR->(TamSX3("LR_VRUNIT")[2])
EndIf

Default cFilEnt		:= cFilAnt										//Filial para geracao do Pedido
Default lJob		:= .F.											//IdentIfica se a rotina e' chamada via JOB ou nao

Private lMSErroAuto	:= .F.											//VerIfica se ocorreu algum erro durante a Geracao do PV

Default lAlterOrc   := .F.
Default cFilLoc     := ""
Default cFilRes     := ""
Default cLjCliente  := ""
Default cLjLojCli   := ""
Default lExistVfe	:= .F.
Default cNumPai		:= ""
Default lAvCred 	:= .T.  // Variavel que controla analise de credito para o pedido.

cTpOperLst := Padr(cTpOperLst, TamSx3("FM_TIPO")[1]) //Ajusta tamanho tipo de operação para TES Inteligente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³eCommerce: Altera a TES para a geracao do Pedido de Venda.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lECommerce
	cMV_LJTESPE	:= SuperGetMV("MV_LJECOME", NIL, cMV_LJTESPE)
EndIf

If !RTrim(cC5_TipLib) $ "1#2"
	cC5_TipLib := "1"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera a Filial para geracao na Filial Correta.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFilEnt <> cFilAnt
	nRecSM0Bkp	:= SM0->(Recno()) 	//Guarda o Recno da SM0 para reposicionar corretamente no final dessa funcao
	cFilAnt := cFilEnt
EndIf

aAx2Itens		:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checagem de Parametro de TES de Cliente.		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cTESPRESN) .And. lECommerce
	DbSelectArea("SF4")
	DbSetOrder(1)	//Filial + Codigo
	If !DbSeek(xFilial("SF4") + cTESPRESN)
		lRet := .F.
		If !lJob
			Aviso(STR0100, STR0170, {STR0005}, 2)	//"Parametro"###"Verifique o TES  Presente cadastrado no parâmetro MV_LJECOMC, pois o mesmo não foi encontrado no Cadastro de TES."##"Ok"
		Else
			Conout(STR0170)	   	   					//"Verifique o TES de Presente cadastrado no parâmetro MV_LJECOMC, pois o mesmo não foi encontrado no Cadastro de TES."
		EndIf
	Else
		cCFOPPRES	:= SF4->F4_CF
	EndIf

	RestArea(aArea)

EndIf

//Busca o Tes de entrega utilizado no caso de venda futura com emissao de documento fiscal
cTesEnt := SuperGetMV("MV_LJVFTEE",,"501") 

nPosAux := ascan(aSL1, {|x| Alltrim(Upper(x[1])) == 'L1_ORCRES' } )
If nPosAux > 0
	cOrcPai := aSL1[nPosAux][2]
Endif

If Empty( cOrcPai )
	nPosAux := ascan(aSL1, {|x| Alltrim(Upper(x[1])) == 'L1_NUM' } )
	If nPosAux > 0
		cOrcPai := aSL1[nPosAux][2]
	Endif
Endif

If !lExecParTES
	cTES  := cMV_LJTESPE

	DbSelectArea("SF4")
	DbSetOrder(1)	//Filial + Codigo
	If !Empty(cTES) .AND. !DbSeek(xFilial("SF4") + cTES)
		lRet := .F.
		If !lJob
			Aviso(STR0100, STR0101, {STR0005}, 2)	//"Parametro"###"VerIfique o TES cadastrado no parâmetro MV_LJTESPE, pois o mesmo não foi encontrado no Cadastro de TES."##"Ok"
		Else
			Conout(STR0101)	   	   					//"VerIfique o TES cadastrado no parâmetro MV_LJTESPE, pois o mesmo não foi encontrado no Cadastro de TES."
		EndIf
	EndIf
EndIf

If lRet
	DbSelectArea("SE4")
	DbSetOrder(1)	//Filial + Codigo
	If Empty(cCondPag) .OR. !DbSeek(xFilial("SE4") + cCondPag)
		lRet := .F.
		If !lJob
			Aviso(STR0100, STR0102, {STR0005}, 2)	//"Parametro"###"VerIfique a Condição de Pagamento cadastrada no parâmetro MV_LJCONDP, pois a mesma não foi encontrada no Cadastro de Condições de Pagamento."##"Ok"
		Else
			Conout(STR0102)							//"VerIfique a Condição de Pagamento cadastrada no parâmetro MV_LJCONDP, pois a mesma não foi encontrada no Cadastro de Condições de Pagamento."
		EndIf
	EndIf
EndIf

If lRet
	nPosCli		:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_CLIENTE"	})
	nPosLoj		:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_LOJA"  	})
	nPosTransp	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_TRANSP"	})
	nPosVeicul	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_VEICUL1"	})
	nPosTipoCli	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_TIPOCLI"	})
	nPosEmissao	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_EMISSAO"	})
	nPosVend	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_VEND"		})
	nPosFrete	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_FRETE"	    })
	nPosSeguro	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_SEGURO"	})
	nPosDespesa	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_DESPESA"	})
	nPosTpFrete	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_TPFRET"	})
	nPosDescNF	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_DESCNF"	})
	nPosCabDes	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_DESCONT"	}) 
	nPosJuros	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_JUROS"	    })
	nPosOrcRes	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_ORCRES"	})
	nPosL1Desc	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_DESCONT"	})
	nPosMenNota := Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_MENNOTA"	})
	nPosEspeci	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_ESPECIE"	})
	nPosVolume	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_VOLUME"	})
	nPosPLiq	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_PLIQUI"	})
	nPosPBru	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_PBRUTO"	})
    nPosPedEco	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_ECPEDEC"	})
	nPosIndPres	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_INDPRES"	})
	nPosInterMD	:= Ascan(aSL1, {|x| AllTrim(x[1]) == "L1_INTERMD"	})

    nPosCodLis 	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_CODLPRE"})

	cCliEntreg	:= aSL1[nPosCli][2]
	cLojEntreg	:= aSL1[nPosLoj][2]
	lLstPre		:= .F.

	//Se for Venda de Lista de Presente, busca o cliente de entrega
	If nPosCodLis > 0 .AND. !Empty(aSL2[1][nPosCodLis][2])
		cCodLisPre := aSL2[1][nPosCodLis][2]

		DbSelectArea("ME1")
		ME1->( DbSetOrder(2) ) //ME1_FILIAL+ME1_CODIGO+ME1_TIPO+ME1_CODCLI+ME1_LOJCLI
		If ME1->( DbSeek(xFilial("ME1")+cCodLisPre) )
			cCliEntreg := ME1->ME1_CODCLI
			cLojEntreg := ME1->ME1_LOJCLI
			lLstPre    := .T.
		EndIf
	ElseIf lECommerce .AND. MF5->(ColumnPos("MF5_CLIENT")) > 0
		If !Empty( Posicione("MF5",1,xFilial("MF5")+"SL1"+xFilial("SL1")+cOrcPai ,"MF5_CLIENT") )
			cLojEntreg := MF5->MF5_CLIENT
		EndIf
	EndIf

	If lMultEndEnt
		nPosClEntrega := Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_CLIENT"	})
		nPosLojEntrega:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_CLILOJA"	})

		// Caso os campos cliente e loja de entrega estejam vazios, lMultEndEnt é setado como falso para usar o L1_CLIENTE como cliente de entrega
		If Empty(aSL2[1,nPosClEntrega,2]) .AND.  Empty(aSL2[1,nPosLojEntrega,2])
			lMultEndEnt := .F.
		EndIf
	EndIf

	nPDesc	 := aSL1[nPosDescNF][2]
	nPJuros	 := aSL1[nPosJuros][2]
	nVdesCab := aSL1[nPosCabDes][2]

	// Validacao da Venda Fora do Estado com CD Centralizado_Matriz x Cd Local de entrega
	Aadd(aCabPed,{ "C5_FILIAL",	xFilial("SC5"),NIL })

	If lCentroDL .And. lExistVfe
		Aadd(aCabPed,{ "C5_CLIENTE", cLjCliente,NIL })
		Aadd(aCabPed,{ "C5_LOJACLI", cLjLojCli ,NIL })
		Aadd(aCabPed,{ "C5_CLIENT",  cLjCliente,NIL })
		Aadd(aCabPed,{ "C5_LOJAENT", cLjLojCli ,NIL })

		//Para VFE necessario posicionar no cliente que pode ser CD
		aAreaTmp := GetArea()
		aAreaSA1 := SA1->(GetArea())

		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1") + cLjCliente + cLjLojCli))

		Aadd(aCabPed,{ "C5_TIPOCLI", SA1->A1_TIPO, NIL})

		//Restaura areas
		RestArea(aAreaSA1)
		RestArea(aAreaTmp)
	Else
		Aadd(aCabPed,{ "C5_CLIENTE",	aSL1[nPosCli][2]	,NIL })
		Aadd(aCabPed,{ "C5_LOJACLI",	aSL1[nPosLoj][2]	,NIL })
		Aadd(aCabPed,{ "C5_CLIENT",		IIf(lMultEndEnt,aSL2[1,nPosClEntrega,2],cCliEntreg) ,NIL })
		Aadd(aCabPed,{ "C5_LOJAENT",	IIf(lMultEndEnt,aSL2[1,nPosLojEntrega,2],cLojEntreg),NIL })
		Aadd(aCabPed,{ "C5_TIPOCLI",	aSL1[nPosTipoCli][2]	,NIL })
	EndIf

	Aadd(aCabPed,{ "C5_TIPO","N",NIL })
	Aadd(aCabPed,{ "C5_TRANSP",		aSL1[nPosTransp][2]		,NIL })

	If nPosVeicul > 0
		Aadd(aCabPed,{ "C5_VEICULO",	aSL1[nPosVeicul][2]		,NIL })
	EndIf

	Aadd(aCabPed,{ "C5_EMISSAO",	aSL1[nPosEmissao][2]	,NIL })
	Aadd(aCabPed,{ "C5_VEND1",		aSL1[nPosVend][2]		,NIL })
	Aadd(aCabPed,{ "C5_CONDPAG",	cCondPag				,NIL })
	Aadd(aCabPed,{ "C5_ORCRES",		cOrcFilho				,NIL })
	Aadd(aCabPed,{ "C5_FRETE",		aSL1[nPosFrete][2]		,NIL })
	Aadd(aCabPed,{ "C5_SEGURO",		aSL1[nPosSeguro][2]		,NIL })
	Aadd(aCabPed,{ "C5_DESPESA",	aSL1[nPosDespesa][2]	,NIL })
	Aadd(aCabPed,{ "C5_TPFRETE",	aSL1[nPosTpFrete][2]	,NIL })
	
    If lLJTDESI 
        Aadd(aCabPed,{ "C5_DESCONT"	, nVdesCab				,NIL })
    ElseIf nPDesc > 0 .AND. !(lECommerce .AND. lMvLjIPEn)
		Aadd(aCabPed,{ "C5_DESC1"	, nPDesc				,NIL })
	Else
		nPDesc := 0
	EndIf
	
	Aadd(aCabPed,{ "C5_MOEDA",		nC5_Moeda				,NIL })
	Aadd(aCabPed,{ "C5_TIPLIB",	    cC5_TipLib				,NIL })
	Aadd(aCabPed,{ "C5_TPCARGA",	cC5_TpCarga				,NIL })
	Aadd(aCabPed,{ "C5_GERAWMS",	cC5_GeraWMS				,NIL })
	If  SC5->( ColumnPos("C5_ECPRESN") > 0 )
		Aadd(aCabPed,{ "C5_ECPRESN",	cPedPRESN				,NIL })
	EndIf
	Aadd(aCabPed,{ "C5_MENPAD"	,	""						,NIL })
	Aadd(aCabPed,{ "C5_MENNOTA"	,	aSL1[nPosMenNota][2]	,NIL })

	//Release 11.5 Chile/Colombia
	//Pedido de Venda / controle de formularios
	If lCFolLocR5
		Aadd(aCabPed,{ "C5_TIPOREM"	,	"0"					,NIL })
		Aadd(aCabPed,{ "C5_SERIE"	,SuperGetMV("MV_LOJAPED"),NIL })
	EndIf
	Aadd( aCabPed,{ "C5_ESPECI1", aSL1[nPosEspeci][2]	, NIL })
	Aadd( aCabPed,{ "C5_VOLUME1", aSL1[nPosVolume][2]	, NIL })
	Aadd( aCabPed,{ "C5_PESOL"	, aSL1[nPosPLiq][2]		, NIL })
	Aadd( aCabPed,{ "C5_PBRUTO"	, aSL1[nPosPBru][2]		, NIL })

    //Carrega código do pedido e-commerce
	If nPosPedEco > 0 .And. SC5->( ColumnPos("C5_PEDECOM") > 0 )
	    Aadd( aCabPed, {"C5_PEDECOM", aSL1[nPosPedEco][2], NIL} )
    EndIf

	If nPosIndPres > 0 .And. SC5->( Columnpos("C5_INDPRES") > 0 )
	    Aadd( aCabPed, {"C5_INDPRES", aSL1[nPosIndPres][2], NIL} )
    EndIf

	If nPosInterMD > 0 .And. SC5->( Columnpos("C5_CODA1U") > 0 )
	    Aadd( aCabPed, {"C5_CODA1U", aSL1[nPosInterMD][2], NIL} )
    EndIf

	LjGrvLog(cOrcPai,"Geracao de pedido - cabecalho: ",aCabPed)

	nPosECPedS	:= IIF(SC5->(FieldPos("C5_ECPRESN") > 0), Ascan(aCabPed, {|x| AllTrim(x[1]) == "C5_ECPRESN"	}), 0)
	nPosECMEN	:= Ascan(aCabPed, {|x| AllTrim(x[1]) == "C5_MENPAD"	})
	aItensPed	:= {}
	aLinhaPed	:= {}

	If lECommerce .AND. lMvLjIPEn .AND. lMVLjDtIPI
	//define se a diferença entre o IPI embutido e o calculado será lançado como desconto no total da NF

		If MaFisFound("NF")
			MaFisEnd()

		  	MaFisIni(Iif(Empty(IIf(lMultEndEnt,aSL2[1,nPosClEntrega,2],cCliEntreg)),aSL1[nPosCli][2],IIf(lMultEndEnt,aSL2[1,nPosClEntrega,2],cCliEntreg)),;
					IIf(lMultEndEnt,aSL2[1,nPosLojEntrega,2],cLojEntreg),;
					"C",;
					"N",;
					aSL1[nPosTipoCli][2],;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					"LOJA701",;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					NIL,,,,aSL1[nPosCli][2],aSL1[nPosLoj][2],,,aSL1[nPosTpFrete][2])


			If aSL1[nPosTpFrete][2] $ "CF"  // CIF FOB
				MaFisAlt( "NF_FRETE"	, aSL1[nPosFrete][2] )
				MaFisAlt( "NF_SEGURO"	, aSL1[nPosSeguro][2] )
				MaFisAlt( "NF_DESPESA"	, aSL1[nPosDespesa][2] )
			EndIf

        EndIf
    EndIf

	//Guarda a posicao dos Campos no aSL2.
	nPosProd	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_PRODUTO"	})
	nPosDescri	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_DESCRI"	})
	nPosUM		:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_UM"		})
	nPosQtde	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_QUANT"		})
	nPosVrUnit	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_VRUNIT"	})
	nPosVlrItem	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_VLRITEM"	})
	nPosLocal	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_LOCAL"		})
	nPosPrcTab	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_PRCTAB"	})
	nPosReserv	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_RESERVA"	})
	nPosEntreg	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_FDTENTR"	})
	nPosTurno	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_TURNO"		})
	nPosSolCom	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_SOLCOM"	})
	nPosMostruario := Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_VDMOST"	})
	nPosObsMostr:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_VDOBS"		})
	nPosLoteCTL	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_LOTECTL"	})
	nPosLote	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_NLOTE"		})
	nPosLocaliz := Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_LOCALIZ"	})
	nPosNSerie :=  Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_NSERIE"	})
	
	nPosDtVal :=  Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_DTVALID"	})
	nPosECPresn := IIF(SL2->(ColumnPos("L2_ECPRESN") > 0), Ascan(aSL2[1], {|x| Alltrim(x[1]) == "L2_ECPRESN" }), 0)
	nPosItemGar := Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_ITEMGAR"	})
	nPosFciCod	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_FCICOD" 	})
	nPosVlImpor	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_VLIMPOR" 	})
	nPosClasFis	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_CLASFIS" 	})
	nPosValDesc := Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_VALDESC" 	})
	nPosFilRes	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_FILPED" 	}) //Filial VFE
	nPosIsVFE	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_ISVFE" 	}) //Indica se eh VFEs
	nPosCodLis	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_CODLPRE" 	}) //Codigo da lista de presente
	nPosItLtPre	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_ITLPRE" 	}) //Item da venda na lista de presente
	nPosTes		:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_TES" 		}) // Posicao da TES
	nPosTpEnt	:= Ascan(aSL2[1], {|x| AllTrim(x[1]) == "L2_ENTREGA"	}) // Retira, Retira Post, Entrega e Retira Post. c/ Pedido

	cItem := StrZero(0,nTamC6It,0) // Inicializa a soma de itens no pedido

	For nI := 1 to nItens
		//Release 11.5 - Localizacoes - F2CHI
		//Nao incluir o item no pedido de venda se nao houver reserva.
		If lCFolLocR5		    
		    If Empty(aSL2[nI][nPosReserv][2])
				Loop
		    EndIf
		EndIf

		Iif(aSL2[nI][nPosTpEnt][2] == '4', cTipOper := "01", cTipOper := "V")//Define a operação usada na geração do pedido
		cTipOper := Padr(cTipOper,TamSx3("FM_TIPO")[1])	

		If lFtvdVer12			
			//Posiciona no TES do pedido-pai
			If nPosTES > 0
				SF4->(DbSetOrder(1)	)
				SF4->(DbSeek(xFilial("SF4") + aSL2[nI][nPosTES][2]))
			EndIf
		EndIf

		//Eleger TES utilizada atraves do parametro MV_LJTESPE (macro-executa)
		If lExecParTES
		   xRet  := &(SubStr(cMV_LJTESPE,2,Len(cMV_LJTESPE)))
		   If ValType(xRet) == "C"
		   	  cTES  := xRet
		   EndIf
		EndIf

		//Eleger TES utilizada atraves do TES INTELIGENTE ou do parametro "MV_LJTESPE"
		If !lExecParTES .OR. Empty(cTES)
			If lLstPre //TES inteligente para lista de presente
				cTes := MaTesInt( 2, cTpOperLst, IIf(Empty(cCliEntreg), aSL1[nPosCli][2], cCliEntreg),; 
				                IIf(Empty(cLojEntreg), aSL1[nPosLoj][2], cLojEntreg),; 
				                "C", aSL2[nI][nPosProd][2], NIL )
				If Empty(cTes)
					cTes := cTESList
				EndIf
			Else
				cTes := MaTesInt( 2	,cTipOper,aSL1[nPosCli][2],aSL1[nPosLoj][2],;
						 		"C",aSL2[nI][nPosProd][2],NIL)
			EndIf

			If Empty(cTes)
			   cTes	:= cMV_LJTESPE
			EndIf
		EndIf

		//Ponto de Entrada para definir a TES a ser utilizada no Item do PEDIDO
		If lLJTESPED 
			LjGrvLog( NIL, " Antes da Execução do PE LJTESPED. Código da TES:",cTES)
			cTES := ExecBlock("LJTESPED",.F.,.F.,{cTES,aSL1,aSL2,nI})
			LjGrvLog( NIL, " Depois da Execução do PE LJTESPED. Código da TES:",cTES )
		EndIf

		SF4->(DbSetOrder(1)	)
		If !SF4->(DbSeek(xFilial("SF4") + cTES))
		   lTESInvalido  := .T.
		EndIf

        // Retirada comparacao do Venda Assistida x Venda Direta.
        // Venda com entrega fora do Estado da venda, estava gravando CFOP do Estado da venda.
        // Com o retorno da funcao MaFisCfo utilizado pelo Venda Direta, esta gravando corretamente CFOP de fora do Estado.
		// Eleger TES padrao atraves dos parametros MV_LJTESPE ou MV_TESSAI
		If Empty(cTES) .OR. lTESInvalido
	    	If !lExecParTES
				cTES := SuperGetMV("MV_LJTESPE", NIL, "501")
			Else
				cTES := SuperGetMV("MV_TESSAI", NIL , "501")
			EndIf
		EndIf

		SF4->(DbSetOrder(1)	)
		SF4->(DbSeek(xFilial("SF4") + cTES))

		aAreaSA1 := SA1->(GetArea())
		SA1->(DbSetOrder(1))
		If lMultEndEnt //Leio o cliente/loja de entrega digitado no item.
			SA1->(DbSeek(xFilial("SA1")+SL2->L2_CLIENT+SL2->L2_CLILOJA))
		Else
			SA1->(DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
		EndIf
		
		aDadosCfo := {}
		Aadd(aDadosCfo,{"OPERNF"	, "S"				})
		Aadd(aDadosCfo,{"TPCLIFOR"	, SA1->A1_TIPO		})
		Aadd(aDadosCfo,{"UFDEST"	, SA1->A1_EST		})
		Aadd(aDadosCfo,{"INSCR"		, SA1->A1_INSCR		}) 

		If SA1->(ColumnPos("A1_CONTRIB")) > 0
			Aadd(aDadosCfo,{"CONTR"	, SA1->A1_CONTRIB	}) 
		EndIf

		cCFOP	:= MaFisCfo(0,SF4->F4_CF,aDadosCfo) 

		If Empty(cCFOP)
			cCFOP	:= SF4->F4_CF
		EndIf
		RestArea(aAreaSA1)

		//Tratar os desconto do Pedido no Valor do Item.
		If  lECommerce .AND. (nPDesc > 0) .AND. (aSL2[nI][nPosVrUnit][2] == aSL2[nI][nPosPrcTab][2])
			aSL2[nI][nPosVrUnit][2]  := (aSL2[nI][nPosVrUnit][2] * (1-(nPDesc/100)))
			aSL2[nI][nPosVlrItem][2] := (aSL2[nI][nPosVrUnit][2] * aSL2[nI][nPosQtde][2])
		EndIf
		
		//Posicionamento dos itens do Pedido.
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+aSL2[nI][nPosProd][2]))
		
		cItem := Soma1(cItem)

		//Grava valor liquido no Pedido de Venda.
		Aadd(aLinhaPed,{ "C6_FILIAL",	xFilial("SC5")	   				,NIL })
		Aadd(aLinhaPed,{ "C6_ITEM",		cItem							,NIL })
		Aadd(aLinhaPed,{ "C6_PRODUTO",	aSL2[nI][nPosProd][2]  			,NIL })
		Aadd(aLinhaPed,{ "C6_DESCRI",	aSL2[nI][nPosDescri][2]			,NIL })
		Aadd(aLinhaPed,{ "C6_UM",		aSL2[nI][nPosUM][2]				,NIL })
		Aadd(aLinhaPed,{ "C6_QTDVEN",	aSL2[nI][nPosQtde][2]			,NIL })

		//#VFE
		If SuperGetMv("MV_LJVFE", Nil, .F.) .AND. SC5->(FieldPos("C5_FILVFE")) > 0
			If nPosFilRes > 0 .AND. nPosIsVFE > 0 .AND. aSL2[nI][nPosIsVFE][2]
				Aadd(aCabPed,{ "C5_FILVFE",	aSL2[nI][nPosFilRes][2]	,NIL })
			EndIf
		EndIf
    	//VFE#

		//Se tiver reserva sem estoque subtrai o valor
		//da solicitacao de compras da quantidade liberada
		lGerSolCom := .F.
	    If AllTrim(Str(SuperGetMv("MV_LJGERSC",,1))) $ "2|3" .AND. nPosSolCom > 0
	    	nQtdeSC := LC701QtdSC(aSL2[nI][nPosSolCom][2], aSL2[nI][nPosProd][2])
	    	Aadd(aLinhaPed,{ "C6_SOLCOM",	aSL2[nI][nPosSolCom][2]			,NIL })
		    lGerSolCom := .T.
	    EndIf

		//Gera Pedido de Venda com a Qtde. Liberada para faturar? (MV_LJPVLIB: 1=Sim; 2=Nao) 
		//Para a opção 5 - Gera Pedido sem Reserva, sempre gera o pedido bloqueado independente do MV_LJPVLIB
	    If SuperGetMv("MV_LJPVLIB", Nil, "1") == "1" .AND. aSL2[nI][nPosTpEnt][2] <> "5"
			Aadd(aLinhaPed,{ "C6_QTDLIB",	aSL2[nI][nPosQtde][2] - nQtdeSC 	,NIL })			
			// Se controla reserva, grava quantidade reservada
			If lMV_LJCTRES
				Aadd(aLinhaPed,{ "C6_QTDRESE",	aSL2[nI][nPosQtde][2] - nQtdeSC 	,NIL })					
			EndIf 	
		Else
			Aadd(aLinhaPed,{ "C6_QTDLIB",	0 	,NIL })	
			If aSL2[nI][nPosTpEnt][2] <> "5"
				Aadd(aLinhaPed,{ "C6_QTDRESE",	aSL2[nI][nPosQtde][2] - nQtdeSC 	,NIL })	
			Else
				// Para Tipo Entrega igual "5-Pedido sem Reserva"
				Aadd(aLinhaPed,{ "C6_QTDRESE",	0 	,NIL })	
			EndIf	
		EndIf
		  
		Aadd(aLinhaPed,{ "C6_PRCVEN",	aSL2[nI][nPosVrUnit][2]			,NIL })
		Aadd(aLinhaPed,{ "C6_VALOR",	aSL2[nI][nPosVlrItem][2]		,NIL })
		Aadd(aLinhaPed,{ "C6_TES",		cTes	 						,NIL })
		// CFOP retornada da funcao MaFisCfo
		Aadd(aLinhaPed,{ "C6_CF",		cCFOP			 				,NIL })
		Aadd(aLinhaPed,{ "C6_LOCAL",	aSL2[nI][nPosLocal][2]			,NIL })
		If lCentroDL
      		Aadd(aLinhaPed,{ "C6_CLI",	cLjCliente 						,NIL })
			Aadd(aLinhaPed,{ "C6_LOJA",	cLjLojCli 						,NIL })
		Else
      		Aadd(aLinhaPed,{ "C6_CLI",	aSL1[nPosCli][2] 				,NIL })
			Aadd(aLinhaPed,{ "C6_LOJA",	aSL1[nPosLoj][2] 				,NIL })
	    Endif
		Aadd(aLinhaPed,{ "C6_PRUNIT",	aSL2[nI][nPosPrcTab][2]			,NIL })		// Preco de tabela
		Aadd(aLinhaPed,{ "C6_TPOP",		cC6_TpOp						,NIL })
		Aadd(aLinhaPed,{ "C6_LOTECTL",	aSL2[nI][nPosLoteCTL][2]       ,NIL }) 	// Lote
		Aadd(aLinhaPed,{ "C6_NLOTE",	aSL2[nI][nPosLote][2]          ,NIL }) 	// SubLote
		
		If nPosDtVal > 0
			Aadd(aLinhaPed,{ "C6_DTVALID",	aSL2[nI][nPosDtVal][2]          ,NIL }) 	// Validade do lote
		EndIf
		
		If nPosNSerie > 0
			Aadd(aLinhaPed,{ "C6_NUMSERI",	aSL2[nI][nPosNSerie][2]          ,NIL }) 	// serie
		EndIf
		
		If nPosLocaliz > 0
			Aadd(aLinhaPed,{ "C6_LOCALIZ",	aSL2[nI][nPosLocaliz][2]          ,NIL }) 	// serie
		EndIf
		
		If SC6->(ColumnPos("C6_VDMOST")) > 0 .AND. nPosMostruario > 0
			Aadd(aLinhaPed,{ "C6_VDMOST",	aSL2[nI][nPosMostruario][2]		,NIL })
		EndIf
		
		If SC6->(ColumnPos("C6_VDOBS")) > 0 .AND. nPosObsMostr > 0
			Aadd(aLinhaPed,{ "C6_VDOBS",	aSL2[nI][nPosObsMostr][2]		,NIL })
		EndIf

		If nPosEntreg > 0
			Aadd(aLinhaPed,{ "C6_ENTREG",	aSL2[nI][nPosEntreg][2]		,NIL })
		EndIf
		If nPosTurno > 0 .AND. SC6->(ColumnPos("C6_TURNO")) > 0 .AND. LJAnalisaLeg(47)[1]
			Aadd(aLinhaPed,{ "C6_TURNO",	aSL2[nI][nPosTurno][2]		,NIL })
		EndIf

		If lC6ItemGar  .AND. nPosItemGar > 0
			Aadd(aLinhaPed,{ "C6_ITEMGAR",	aSL2[nI][nPosItemGar][2]		,NIL })
		EndIf

		If lC6OrcGar .AND. nPosOrcRes > 0 .AND. nPosItemGar > 0 .AND. !Empty(aSL2[nI][nPosItemGar][2])
			Aadd(aLinhaPed,{ "C6_ORCGAR",	aSL1[nPosOrcRes][2]		,NIL })
		EndIf

		If nPosFciCod > 0 .And. SC6->(ColumnPos("C6_FCICOD")) > 0
			Aadd(aLinhaPed,{ "C6_FCICOD",	aSL2[nI][nPosFciCod][2]		,NIL })
		EndIf

		If nPosVlImpor > 0 .And. SC6->(ColumnPos("C6_VLIMPOR")) > 0
			Aadd(aLinhaPed,{ "C6_VLIMPOR",	aSL2[nI][nPosVlImpor][2]	,NIL })
		EndIf

		If (aSL2[nI][nPosTes][2] == cTes) .And. (nPosClasFis > 0 .And. !Empty(aSL2[nI][nPosClasFis][2]))
			cClasFis := aSL2[nI][nPosClasFis][2]
		Else
			cClasFis := CodSitTri()
		EndIf
		// Pega sit Trib igual ao faturamento
		Aadd(aLinhaPed,{ "C6_CLASFIS",	cClasFis						,NIL })

		//Campos referente a lista de presente
		If lC6CodLP .And. nPosCodLis > 0
			Aadd(aLinhaPed,{ "C6_CODLPRE", aSL2[nI][nPosCodLis][2]		,NIL })
		EndIf

		If lC6ITLtP .And. nPosItLtPre > 0
			Aadd(aLinhaPed,{ "C6_ITLPRE", aSL2[nI][nPosItLtPre][2]		,NIL })
		EndIf

		If lCFolLocR5 .AND. cPaisLoc == "CHI"
			//Release 11.5 - Chile - Guia de Despacho - F2CHI
			//Quando o produto pertence a um pedido de venda e sera incluido futuramente em uma 
			//Guia de Despacho, atualizar o campo C6_GERANF='N' para que nao esteja disponivel 
			//para geracao de Factura atraves da rotina MATA468N (SIGAFAT).
			Aadd(aLinhaPed,{ "C6_GERANF", "N"		,NIL })
		EndIf

		If (lECommerce .AND. lMvLjIPEn)
        	nPrecoTab := 0
        	nIPIDesc := 0
        	LjxeValPre(@nPrecoTab, 	aSL2[nI][nPosProd][2], aSL1[nPosCli][2], aSL1[nPosLoj][2],;
					nMoedaCor   , aSL2[nI][nPosQtde][2] , , @nIPIDesc,;
					.T. )
			nIPIDesc  :=  ( nIPIDesc *  aSL2[nI][nPosQtde][2])
			//Somente calcula o valor do IPI se não houve alteração na tabela de preço
 			If lMVLjDtIPI
 				//define se a diferença entre o IPI embutido e o calculado será lançado como desconto no total da NF
				If nIPIDesc > 0 .and. (aSL2[nI][nPosPrcTab][2] == nPrecoTab)
					nTotIPIEn += nIPIDesc
				Else
					nIPIDesc := Lj701CIPI(	aSL2[nI][nPosProd][2], aSL2[nI][nPosPrcTab][2], lMVRNDIPI, cMV_LJTESPE, nCasasIPI)
					nIPIDesc   := ( nIPIDesc *  aSL2[nI][nPosQtde][2])
					nTotIPIEn += nIPIDesc
				EndIf
			EndIf
		EndIf

		 //Gera Pedido de Venda com a Qtde. Liberada para faturar? (MV_LJPVLIB: 1=Sim; 2=Nao)
		If aSL2[nI][nPosTpEnt][2] == "5"
			// Opção 5 - Gera Pedido sem Reserva
			Aadd(aLinhaPed,{ "C6_RESERVA", "" ,NIL })
		ElseIf SuperGetMv("MV_LJPVLIB", Nil, "1") == "1"
			If !lMV_LJCTRES
				//Faz o cancelamento da reserva, pois os produtos
				//serao reservados pela liberacao do Pedido de Vendas.
				aReserva := {{	aSL2[nI][nPosReserv][2],;		// Numero da Reserva
								aSL1[nPosLoj][2] ,;				// Codigo da Loja
								aSL2[nI][nPosProd][2],;		// Codigo do Produto
								aSL2[nI][nPosLocal][2],;		// Local (Armazem)
								cFilEnt ,;						// Filial da Reserva
								StrZero(nI, nTamC6It)}}

				aRetRes		:= Lj7CancRes(aReserva, lJob)
				lRet		:= aRetRes[1][2]					// O tamanho do Array de retorno e' fixo
			Else
				Aadd(aLinhaPed,{ "C6_RESERVA",	aSL2[nI][nPosReserv][2] ,NIL })     // Relaciona o codigo da reserva da SC0			
			EndIf	
		Else
		 	//Neste caso, nao exclui a Reserva da SC0, pois o pedido foi incluido com o item nao liberado (C6_QTDLIB = 0)
		   	Aadd(aLinhaPed,{ "C6_RESERVA",	aSL2[nI][nPosReserv][2] ,NIL })     // Relaciona o codigo da reserva da SC0
		EndIf

		If !lRet
			If !lJob
				Aviso(STR0031, STR0103, {STR0005}, 2)	// "Atenção"###"Não foi possível efetuar o estorno da Reserva. O Pedido de Venda não será gerado."###"Ok"
				Exit
			Else
				Conout(STR0103)							// "Não foi possível efetuar o estorno da Reserva. O Pedido de Venda não será gerado."
				Exit
			EndIf
		EndIf

		Aadd(aItensPed, aLinhaPed)

        //Carrega posição dos campos que podem ser alterados
        nPosTesC6 := Ascan(aLinhaPed, {|x| x[1] == "C6_TES"     })
        nPosCfC6  := Ascan(aLinhaPed, {|x| x[1] == "C6_CF"      })
        nPosClaC6 := Ascan(aLinhaPed, {|x| x[1] == "C6_CLASFIS" })
		nPosQtdVen 	:= Ascan(aLinhaPed, {|x| x[1] == "C6_QTDVEN" })
		nPosQtdlib 	:= Ascan(aLinhaPed, {|x| x[1] == "C6_QTDLIB" })


		//Verificar se vai fazer o processo novo para MG ou não
		IF LjChkNFS(aSL2)
			aadd( aAx2Itens, aClone(aLinhaPed) )

			//Ponto de entrada para alterar a TES do pedido do simples faturamento
			If lLJTESSFat
				LjGrvLog( NIL, " Antes da Execução do PE LJTESSFA. Código da TES:",cTES)
				cTesEnt := ExecBlock("LJTESSFA",.F.,.F.,{cTES,aSL1,aSL2,nI})
				LjGrvLog( NIL, " Depois da Execução do PE LJTESSFA. Código da TES:",cTES )
			EndIf

			//Altera a TES configurada no parâmetro MV_LJVFTEE 
            If nPosTesC6 > 0               
                aAx2Itens[len(aAx2Itens)][nPosTesC6][2] := cTesEnt
			Endif
			aSF4Ord := SF4->(GetArea())

			SF4->( DbSetOrder(1) )
			SF4->( DbSeek(xFilial("SF4") + cTesEnt) )

            If nPosCfC6 > 0
				cCFOPEnt := MaFisCfo(0,SF4->F4_CF,aDadosCfo)

				If Empty(cCFOPEnt)
					cCFOPEnt := SF4->F4_CF
				EndIf

                aAx2Itens[len(aAx2Itens)][nPosCfC6][2] := cCFOPEnt
			EndIf

            If nPosClaC6 > 0
			
				cClassFis := CodSitTri()				

				If cClassFis <> aAx2Itens[len(aAx2Itens)][nPosClaC6][2]
					aAx2Itens[len(aAx2Itens)][nPosClaC6][2] := cClassFis
				EndIf
			EndIf

			If nPosQtdVen > 0 .And. nPosQtdlib > 0
				aAx2Itens[len(aAx2Itens)][nPosQtdlib][2] := aAx2Itens[len(aAx2Itens)][nPosQtdVen][2]
			EndIf 

			RestArea(aSF4Ord)

			nECVezes := 2
		Endif

		//Substitui os valores das posiçoes para gerar o Pedido de Presente
        If lECommerce .And. nPosECPresn > 0 .And. aSL2[nI][nPosECPresn][2] == "1"
		    aAxlItens:= aClone(aLinhaPed)
			Aadd(aItPedPres,aAxlItens)

   			ATail(aItPedPres)[nPosTesC6][2]	:=  cTESPRESN
        	ATail(aItPedPres)[nPosCfC6][2]	:=  cCFOPPRES

			nECVezes := 2
		EndIf

        //Valida o preenchimento da TES, feito no final porque o campo é atualizado após a inclusão
        If Empty(aLinhaPed[nPosTesC6][2])
            lRet := .F. 
            Help(" ", 1, "Lj7GeraEnt", , STR0218, 1, 0)     //"TES para o pedido de venda não informada, verifique os parâmetros MV_LJTESPE \ MV_LJECOME e o cadastro de TES inteligente"
            LjGrvLog(cOrcPai, STR0218, aLinhaPed)           //"TES para o pedido de venda não informada, verifique os parâmetros MV_LJTESPE \ MV_LJECOME e o cadastro de TES inteligente"
            Exit
        EndIf

		aLinhaPed := {}
		If lECommerce .AND. lMvLjIPEn .AND. lMVLjDtIPI
			If !lFtvdVer12
				If MaFisFound("NF")
					MaFisAdd( aSL2[nI][nPosProd][2],;	// Produto
							  cTes   ,;	// Tes
							  aSL2[nI][nPosQtde][2] ,;	// Quantidade
							  aSL2[nI][nPosPrcTab][2],;	// Preco unitario
							  0,;	// Valor do desconto
							  "",; 						// Numero da NF original
							  "",; 						// Serie da NF original
							   0,;						// Recno da NF original
							   0,; 						// Valor do frete do item
							   0,; 						// Valor da despesa do item
							   0,; 						// Valor do seguro do item
							   0,; 						// Valor do frete autonomo
							   ( aSL2[nI][nPosPrcTab][2] *  aSL2[nI][nPosQtde][2] ) ,;        // Valor da mercadoria
							   0 )						// Valor da embalagem
					MaFisRecal("",nI)

				EndIf

		   ElseIf lFtvdVer12

				If MaFisFound("NF")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+aSL2[nI][nPosProd][2]))

					SF4->(DbSetOrder(1))
					SF4->(DbSeek(xFilial("SF4")+cTes))

					MaFisIniLoad(nI, ;
								{aSL2[nI][nPosProd][2],;	//IT_PRODUTO
								cTes,; 		//IT_TES
								Alltrim(MaSBCampo("CODISS")),; 	//IT_CODISS
								aSL2[nI][nPosQtde][2],;		//IT_QUANT
								"",; 				//IT_NFORI
								"",; 				//IT_SERIORI
								SB1->(RecNo()),;	//IT_RECNOSB1
								SF4->(RecNo()),;	//IT_RECNOSF4
								0  }) 				//IT_RECORI

					MaFisLoad("IT_VALMERC"	,(  aSL2[nI][nPosPrcTab][2] *  aSL2[nI][nPosQtde][2] ) ,nI)
					MaFisLoad("IT_PRCUNI"	, aSL2[nI][nPosPrcTab][2],nI)
					MaFisLoad("IT_DESCONTO"	,0,nI)
					MaFisLoad("IT_FRETE"	,0,nI)
					MaFisLoad("IT_SEGURO"	,0,nI)
					MaFisLoad("IT_DESPESA"	,0,nI)

					MaFisRecal("",nI)

					MaFisEndLoad(nI,2)
				EndIf

			EndIf
		EndIf

		// adicionamos o contador do pedido para obter a linha exata a ser alterada no ponto de entrada LJ7046
		If lLJ7046
			aAdd( aSL2[nI], {"CONTADOR_PED", nI} )
		EndIf

	Next nI
EndIf

//define se a diferença entre o IPI embutido e o calculado será lançado como desconto no total da NF
If  lECommerce .AND. lMvLjIPEn .AND. lMVLjDtIPI .AND. nTotIPIEn > 0
	For nI := 1 to nItens
		nTotIPI += MaFisRet(nI,"IT_VALIPI")
	Next nI

	If (nTotIPI > nTotIPIEn)
		nTotIPI := Max(nTotIPI - nTotIPIEn , 0)

		If lMVRNDIPI
			nTotIPI := Round(nTotIPI,nCasasIPI)     //Trabalha com arredondamento
		Else
			nTotIPI := NoRound(nTotIPI,nCasasIPI)   //Trabalha com truncamento
		EndIf

		If nTotIPI > 0  .and. (  (nCpo := aSCan( aCabPed, { |c| c[1] ==  "C5_DESCONT" } ) )  > 0)
			aCabPed[nCpo][2] := aCabPed[nCpo][2] + nTotIPI
		EndIf
	EndIf

EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada que podera ser utilizado, para incluir outros³
	//³campos na gravacao do Pedido de Venda.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLJ7046 .AND. !lFtvdVer12
		aRet := ExecBlock("LJ7046", .F., .F., {cFilBkp , aSL1 , aSL2 })
		If ValType(aRet[1]) == "A" .And. Len(aRet[1]) > 0
			aCab7046	:= aClone(aRet[1])
			For nI := 1 to Len(aCab7046)
				Aadd(aCabPed, aCab7046[nI])
			Next nI
		EndIf

		If ValType(aRet[2]) == "A" .And. Len(aRet[2]) > 0
			aItens7046	:= aClone(aRet[2])	//retornou uma quantidade de itens superior em relacao a aItensPed
			For nI := 1 to Len(aItens7046)
				// procura pelo campo CONTADOR_PEDIDO no retorno do PE
				nAux := aScan( aItens7046[nI], {|x| x[1] == "CONTADOR_PED"} )
				If nAux > 0	// obtem o valor do campo CONTADOR_PED no retorno do PE
					nAux := aItens7046[nI][nAux][2]
				Else		//senao mantem o legado
					nAux := nI
				EndIf

				For nCpo := 1 to Len(aItens7046[nI])
					Aadd( aItensPed[nAux], aItens7046[nI][nCpo] )
					If lECommerce .AND. (nI <= Len(aItPedPres))
						Aadd( aItPedPres[nAux], aItens7046[nI][nCpo] )
					EndIf
				Next
			Next
		EndIf
		
		// apagamos o ultimo campo que foi criado para proteger o retorno do P.E.
		For nI := 1 to Len(aSL2)
			aSize( aSL2[nI], Len(aSL2[nI])-1 )
		Next
	EndIf

	If lFTVD7046 .AND. lFtvdVer12
		aRet := ExecBlock("FTVD7046", .F., .F., {cFilBkp})
		If ValType(aRet[1]) == "A" .And. Len(aRet[1]) > 0
			aCab7046	:= aClone(aRet[1])
			For nI := 1 to Len(aCab7046)
				Aadd(aCabPed, aCab7046[nI])
			Next nI
		EndIf

		If ValType(aRet[2]) == "A" .And. Len(aRet[2]) > 0
			aItens7046	:= aClone(aRet[2])
			For nI := 1 to Len(aItens7046)
				For nCpo := 1 to Len(aItens7046[nI])
					Aadd(aItensPed[nI], aItens7046[nI][nCpo])
					If lECommerce .AND. (nI <= Len(aItPedPres))
						Aadd(aItPedPres[nI],aItens7046[nI][nCpo])
					EndIf
				Next nCpo
			Next nI
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Foi substituido a execução da EXECAUTO pela gravação manual do Pedido de Venda.               ³
	//³O Motivo foi performance, pois em pedidos com mais de 50 itens a demora na execução da Execauto³
	//³inviabiliza o processo, pois fica muito lento.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAxlItens := {}
	aBkpSl1	:= aClone(aSl1)
	For nCont := 1 to nECVezes

		aSl1 := aClone( aBkpSl1 )

		If  (nCont > 1)
			If LjChkNFS(aSL2)
				aAxlItens	:= aClone(aItensPed)
				nPosAux := Ascan(aCabPed, {|x| Alltrim(Upper(x[1])) == "C5_ORCRES" })
				if nPosAux > 0
					aCabPed[nPosAux][2] := cOrcFilho
				Endif

			Else
				aAxlItens	:= aClone(aItPedPres)

				aCabPed[nPosECMEN][2]	:= cManPad
				aCabPed[nPosECPedS][2]	:= "1"
			EndIf
		Else
			If LjChkNFS(aSL2)
				aAxlItens	:= aClone(aAx2Itens)
				nPosAux := Ascan(aCabPed, {|x| Alltrim(Upper(x[1])) == "C5_ORCRES" })
				If nPosAux > 0
					aCabPed[nPosAux][2] := cOrcPai
				EndIf

				For nQtdItens := 1 To Len(aAxlItens)
					nPosAux	:= 0
					nPosAux := Ascan(aAxlItens[nQtdItens], {|x| Alltrim(Upper(x[1])) == "C6_RESERVA" }) 
					If nPosAux > 0
						aAxlItens[nQtdItens][nPosAux][2] := ""
					EndIf 
					nPosAux	:= 0
					nPosAux := Ascan(aAxlItens[nQtdItens], {|x| Alltrim(Upper(x[1])) == "C6_QTDVEN" }) 
					If nPosAux > 0
						nQtdeVen := aAxlItens[nQtdItens][nPosAux][2]
					EndIf 
					nPosAux	:= 0
					nPosAux := Ascan(aAxlItens[nQtdItens], {|x| Alltrim(Upper(x[1])) == "C6_QTDLIB" }) 
					If nPosAux > 0
						aAxlItens[nQtdItens][nPosAux][2] := nQtdeVen
					EndIf 
				Next nQtdItens
			Else

				aAxlItens	:= aClone(aItensPed)

				If  (nECVezes == 2) .AND. (nPosECMEN > 0)
					aCabPed[nPosECMEN][2]	:= cManPad
				EndIF
			Endif
		EndIF

		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) //Filial + Pedido
		cNumSC5 := CRIAVAR("C5_NUM")

		LjGrvLog(cNumPai,"Retorno de numeracao do SC5 - Empresa/Filial: " + cEmpAnt+"/"+cFilAnt ,cNumSC5)

		cMay := "SC5"+ALLTRIM(xFilial("SC5"))+cNumSC5
		FreeUsedCode()
		While SC5->(DbSeek(xFilial("SC5")+cNumSC5)) .OR. !MayIUseCode(cMay)
			If ++nTent > 20
				FreeUsedCode()
			EndIf
			If nTent > 50 //Se nao conseguir ate 50 vezes, aborta o sistema.
				FreeUsedCode()
				Final("Impossivel gerar numero sequencial de PEDIDO correto. INFORME ESSA MENSAGEM PARA O DEPARTAMENTO DE TI.")
			EndIf
			cNumSC5 := CRIAVAR("C5_NUM")
			cMay := "SC5"+ALLTRIM(xFilial("SC5"))+cNumSC5
			LjGrvLog(cNumPai,"Tentou buscar outra numeracao - Empresa/Filial: " + cEmpAnt+"/"+cFilAnt,cNumSC5)
		End
		If __lSX8
			While (GetSX8Len() > nSaveSx8)
				ConfirmSx8()
			End
		Endif

		If Len(aCabPed) > 0
			RecLock("SC5",.T.)
			SC5->C5_NUM		:=	cNumSC5
			For nI := 1 to len(aCabPed)
		 		SC5->&(aCabPed[nI][1])	:= aCabPed[nI][2]
		   	Next nI
		Endif
		FkCommit() // Commit para integridade referencial do SC5
		FreeUsedCode()

		LjGrvLog(cNumPai,"Incluiu o registro no SC5")

		// Grava o número da Solicitação de Compra no Pedido de Venda
		If lGerSolCom
			For nI := 1 to nItens
				nPosC6SolCom	:= Ascan(aItensPed[nI], {|x| AllTrim(x[1]) == "C6_SOLCOM"	})
				nPosC6Filial	:= Ascan(aItensPed[nI], {|x| AllTrim(x[1]) == "C6_FILIAL"	})
				If !Empty(aItensPed[nI][nPosC6SolCom][2])
					DbSelectArea("SC1")
					DbSetOrder(1) // Filial+Numero da SC
					// Procura a solicitação de compras
					If DbSeek(aItensPed[nI][nPosC6Filial][2] + aItensPed[nI][nPosC6SolCom][2])
						// Depois de posicionado, altero a Solicitação de compra com o numero do pedido (C5_Num)
						While ( !Eof() .AND. xFilial("SC1")+aItensPed[nI][nPosC6SolCom][2] == SC1->C1_FILIAL + SC1->C1_NUM )
							RecLock("SC1", .F.)
							REPLACE SC1->C1_PEDRES WITH SC5->C5_NUM
							MsUnlock()
							SC1->(DbSkip())
						EndDo
					EndIf
				Endif
			Next nI
		EndIf
		
		If Len(aAxlItens) > 0
			For nI := 1 to Len(aAxlItens)
				RecLock("SC6",.T.)
				SC6->C6_NUM		:=	cNumSC5
				For nY := 1 to Len(aAxlItens[nI])
					nAux := ColumnPos(aAxlItens[nI][nY][1])
					If  nAux > 0 
						SC6->( FieldPut(nAux, aAxlItens[nI][nY][2]) )
					EndIf
		 		Next nY
		 		SC6->(MsUnlock())
			   	FkCommit() // Commit para integridade referencial do SC6
			   	
			   	nAux := 0
			   	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando a função e executa direto pelo Lj7Pedido ele não tem o foco no sc6, precisando passar  ³
				//³o reclock antes de executar a função MaAvalSC6                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   	
			   	If !SC6->(EOF()) .AND. RecLock("SC6")
					MaAvalSC6("SC6",1,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,nil,nil,nil,nil,nil,lTLVReg,lAvCred)
		 			SC6->(MsUnlock())
		 			
		 			If SC6->C6_QTDLIB > 0
		 				lLiberou := .T. 
		 			EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³PE para atualizar os dados dos itens da geracao do Pedido.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLJ7065
					LjGrvLog( cNumSC5 , " Antes da Execução do PE LJ7065")
					ExecBlock("LJ7065",.F.,.F., { nI } )
					LjGrvLog( cNumSC5 , " Antes da Execução do PE LJ7065")
				EndIf
		   	Next nI
		Endif

		LjGrvLog(cNumPai,"Passou da validação dos itens na SC6")
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Parametros³ExpC1: Alias da tabela dos itens do Pedido de Venda         ³
		³          ³ExpN2: Codigo do Evento                                     ³
		³          ³       [1] Implantacao do Pedido de Venda                   ³
		³          ³       [2] Estorno  do Pedido de Venda                      ³
		³          ³       [3] Liberacao do Pedido de Venda                     ³
		³          ³       [4] Estorno da Liberacao do Pedido de Venda          ³
		³          ³       [5] Preparacao da Nota Fiscal de Saida               ³
		³          ³       [6] Estorno da Nota Fiscal de Saida                  ³
		³          ³ExpC3: Alias do SC5                                         ³
		³          ³ExpL4: Liberacao Parcial                                    ³
		³          ³ExpL5: Transfere Locais                                     ³
		³          ³ExpL6: Verifica se todos os itens foram liberados           ³
		³          ³ExpL7: Verifica os residuos do pedido de venda              ³
		³          ³ExpL8: Verifica se todos os itens foram faturados           ³
		³          ³ExpL9: Atualiza somente os acumulados                       ³
		³          ³ExpNA: Valor a ser adicionado ao limite de credito          ³
		³          ³ExpCB: Alias do SD2 ( Uso Interno para otimizacao )         ³
		³          ³ExpLC: Indica se esta o SC6 esta sendo baixado por un REMITO³
		ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		If ( cC5_TipLib=="2" .And. (lLiberou .Or. MaTesSel(SC6->C6_TES)) )
			MaAvalSC5("SC5",3,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk)
		EndIf

		MaAvalSC5("SC5",1,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk)
		SC5->(MsUnlock())

		LjGrvLog(cNumPai,"Finalizou a geracao do pedido na SC5")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³PE para atualizar os dados na finalizacao do pedido,subistitui M410STTS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLJ7066
			LjGrvLog( cNumSC5 , " Antes da Execução do PE LJ7066")
			ExecBlock("LJ7066",.F.,.F.)
			LjGrvLog( cNumSC5 , " Depois da Execução do PE LJ7066")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica se houveram erros durante a geracao do Pedido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMsErroAuto
			lRet := !lMsErroAuto
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a gravacao do Numero do ³
			//³Pedido no Orcamento Filho.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPedido   := SC5->C5_NUM
			If nCont == 1			 // Ecomerce sempre vai ter mais de 1
				cPedPai   := cPedido // O primeiro sempre eh o pedido PAI
			Else
				cPedFilho := cPedido // O segundo é o pedido presente e devera ser vinculado
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ajusta as datas da geracao do pedido com a funcao Date(), isso 	   ³
			//³ porque a variavel dDatabase guarda a data em que foi iniciado o JOB³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lJob
				DbSelectArea("SC6")
				DbSetOrder(1)
				If DbSeek(xFilial("SC6")+cPedido)    // Filial + Numero do Pedido
					While ( !Eof() .AND. xFilial("SC6")+cPedido == SC6->C6_FILIAL + SC6->C6_NUM )
						RecLock("SC6",.F.)
						REPLACE C6_SUGENTR WITH Date()
						MsUnlock()

						DbSelectArea("SC9")			// Ajusta tambem a tabela de liberacao
						DbSetOrder(1)				// Filial + Numero do Pedido + Item
						If DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
							While ( !Eof() .AND. SC9->C9_FILIAL == xFilial("SC9") .AND.;
												 SC9->C9_PEDIDO == SC6->C6_NUM 	  .AND.;
									  			 SC9->C9_ITEM   == SC6->C6_ITEM )
								RecLock("SC9",.F.)
								REPLACE C9_DATALIB WITH Date()
								MsUnlock()

								SC9->(DbSkip())
							End
						EndIf

						SC6->(DbSkip())
					End
				EndIf
			EndIf

			//Tratamento para atualizar o ME4 quando lista de presente.
			//Obs.: Este tratamento é necessário para gerar corretamente o faturamento do pedido
			//Não se reaproveitou o loop do sl2 pois em caso de venda futura (nota de simples faturamento)
			//a nota é faturada na função 'FEmiteNF' e neste momento o ME4 ja deve estar preenchido corretamente.
			If lLstPre .And. lPosL2ITESC6 .And. nPosCodLis > 0
				Lj8GrvPed(aSL2, cNumPai, cOrcFilho, cPedido )
			EndIf

			IF LjChkNFS(aSL2) .and. nCont == 1	//Função que verifica se deve habilitar ou nao o novo processo
				aSL1Tmp	:= SL1->( GetArea() )
				aAreaTmp:= GetArea()

            	aDadosNf:= FEmiteNF(aSL1[nPosCli][2],aSL1[nPosLoj][2], cPedido)		//Vai chamar a função que fatura o pedido

				DbSelectArea("SL1")
				DbSetOrder(1)
				If dbSeek( xFilial("SL1") + cOrcPai )
					RecLock("SL1", .F. )
					SL1->L1_DOCPED := aDadosNf[1]
					SL1->L1_SERPED := aDadosNf[2]
					SL1->L1_DOC    := ""
					SL1->L1_SERIE  := ""
					MsUnlock()
				Endif

				RestArea(aSL1Tmp)
				RestArea(aAreaTmp)
				aSL1Tmp := {}
				aAreaTmp := {}
			Endif
			
			DbSelectArea("SL1")
			DbSetOrder(1)	//Filial + Numero
			If  DbSeek(xFilial("SL1") + cOrcFilho)

			    If (nCont > 1) .And. SC5->(ColumnPos("C5_ECVINCU") > 0)
					Aadd(aSL1Tmp, { "L1_PEDPRS", cPedido })
					//Efetua a gravação no Ped. Presente vinculando com o pedido PAI
					SC5->( RecLock("SC5",.F.) )
					SC5->C5_ECVINCU := cPedPai
					SC5->( MsUnlock() )

				 	DbSelectArea("SC5")
					DbSetOrder(1)	//Filial + Pedido
					//Efetua a gravação no Ped.Pai , granvando o numero do filho
					If SC5->(DbSeek(xFilial("SC5")+cPedPai))
						SC5->( RecLock("SC5",.F.) )
						SC5->C5_ECVINCU := cPedFilho
						SC5->( MsUnlock() )
					EndIf
				Else
					Aadd(aSL1Tmp, { "L1_PEDRES", cPedido })
                EndIf

				Lj7GeraSL( "SL1", aSL1Tmp )

				DbSelectArea("SL2")
				DbSetOrder(1)	//Filial + Numero + Item
				For nI := 1 to Len(aSL2)
					aSL2Tmp := {}
					nPosItem	:= Ascan(aSL2[nI], {|x| AllTrim(x[1]) == "L2_ITEM"	})
					If DbSeek(xFilial("SL2") + cOrcFilho + aSL2[nI][nPosItem][2])
						Aadd(aSL2Tmp, { "L2_PEDRES", cPedido })
						Aadd(aSL2Tmp, { "L2_FILRES", cFilRes })
						Lj7GeraSL( "SL2", aSL2Tmp )
					EndIf
				Next nI
			EndIf
		EndIf

	Next nCont
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Filial de Origem.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilBkp
If nRecSM0Bkp > 0
	//Reposiciona corretamente na SM0
	SM0->(DbGoTo(nRecSM0Bkp))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno da Funcao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := { lRet, cOrcFilho }
LjGrvLog(cNumPai,"Retorno da geracao do SC5",aRet)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA701   ºAutor  ³Vendas Clientes     º Data ³  29/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que retorna o Valor do Subtotal para controle do sub-º±±
±±º          ³total quando ocorre erro ou cancela a operacao TEF 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7GetSubTot()
Local nRet  := nValSubTot

Return (nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA701   ºAutor  ³Vendas Clientes     º Data ³  29/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que altera o Valor do Subtotal para controle do sub- º±±
±±º          ³total quando ocorre erro ou cancela a operacao TEF 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7SetSubTot(nValor)

nValSubTot  := nValor

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj7SetLog   ³ Autor³ Vendas Clientes       ³ Data³04/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Diretorio do arquivo do Log_Tef                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj7GetLog()
Local cLogTef 	:= ""        	// Retorna o patch do arquivo log
Local lAutoExC	:= IsBlind()	// Verifica se a rotina sera executada via execauto ou nao

If !lAutoExC
	If cGetCliDir == NIL
		cGetCliDir := GetClientDir()
	EndIf
	If cProfStr1 == NIL
	    cProfStr1 := GetPvProfString("Logs TEF","Habilita","01",cGetCliDir + "SIGALOJA.INI")
	EndIF
	If File(cGetCliDir + "SIGALOJA.INI") .AND. cProfStr1 == "01"
		cLogTef := "\AUTOCOM\TEF"+cEmpAnt+cFilAnt+"\"
	Else
		cLogTef := ""
	EndIf
Endif

Return(cLogTef)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7BaseInstºAutor  ³Vendas Clientes     º Data ³  01/10/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a base instalada para os produtos de entrega.         º±±
±±º          ³ Recebe um array com os nos. de serie para geracao de mul-  º±±
±±º          ³ tiplos registros de base instalada.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7BaseInstalada( aNrsSerie )
Local lMultiplo := .F.   // Gera base instalada para cada produto vendido, com base no array recebido
Local aCab040   := {}    // Cabecalho do AA3
Local aItens040 := {}    // Itens AA4
Local nRegs     := 1     // No. de registros de base instalada que serao gerados
Local lRet      := .T.
Local nI

Private lMSErroAuto	:= .F.	//VerIfica se ocorreu algum erro durante a Geracao da base

// Se recebeu o array na chamada da funcao
If ValType(aNrsSerie) == "A" .AND. Len(aNrsSerie) > 0
   lMultiplo := .T.
   nRegs     := Len(aNrsSerie)
Endif

For nI := 1 to nRegs
   cSerie := If(lMultiplo, aNrsSerie[nI], SL2->L2_NSERIE)

	Aadd(aCab040, { "AA3_FILIAL"	, xFilial("AA3")	, NIL } )
	Aadd(aCab040, { "AA3_CODCLI"	, SL1->L1_CLIENTE	, NIL } )
	Aadd(aCab040, { "AA3_LOJA"	 	, SL1->L1_LOJA		, NIL } )
	Aadd(aCab040, { "AA3_CODPRO"	, SL2->L2_PRODUTO	, NIL } )
	Aadd(aCab040, { "AA3_NUMSER"	, cSerie				, NIL } )
	Aadd(aCab040, { "AA3_DTVEN"	, DATE()				, NIL } )

   DbSelectArea('AA3')
   AA3->(DbSetOrder(1))
   If !AA3->(DbSeek(xFilial('AA3') + SL1->L1_CLIENTE + SL1->L1_LOJA + SL2->L2_PRODUTO + cSerie))

      If Type("N") == "N"
         nAnt := n
         n := 1
      EndIf

		MSExecAuto( {|w,x,y,z| TECA040(w,x,y,z)}, NIL, aCab040, aItens040, 3)
      If Type("N") == "N"
         n := nAnt
      EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica se houveram erros durante a geracao da base   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMsErroAuto
			lRet := !lMsErroAuto
		Endif
   Endif

   aCab040 := {}
Next

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7AtuInteºAutor  ³Vendas Clientes     º Data ³  25/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Leva os dados da venda para integracao (Processo OffLine)  º±±
±±º          ³ L1,L2,L4,F2,D2,E1,E5,EF e C0								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7AtuInte(oDadosOff, cNumOrc, cFilProc, lProcOff)

Local oProcessOff 	:= Nil									//Objeto do tipo LJCProcessoOffLine
Local cChave 		:= ""									//Chave da tabela
Local aAreaAtual	:= ""   								//Array que ira guardar os dados do alias atual
Local aArea         := ""									//Array que ira guardar os dados do alias utilizado
Local cPrefixo		:= ""  									//Valor do prefixo
Local cNumE1		:= ""  									//Numero do Titulo
Local cMvLjPref		:= SuperGetMV("MV_LJPREF")  			//Regra para gravacao do SF2->F2_PREFIXO
Local cNumDoc		:= ""									//Numero do documento do orcamento
Local cSerie		:= ""									//Serie do orcamento
Local lTemPedido	:= .F.									//Indica se o orcamento tem pedido
Local aSB2			:= {}									//Array com as chaves do SB2
Local nCount		:= 0									//Variavel auxiliar contador
Local cAuxChave		:= ""									//Variavel auxiliar utilizada para verificar se é o mesmo produto do SL2
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline

Default oDadosOff 	:= Nil
Default cNumOrc		:= ""
Default lProcOff	:= .T.
Default cFilProc	:= ""

//Verifica se o ambiente esta operando em offline
If lAmbOffLn

	//Guarda a posicao do arquivo atual
	aAreaAtual := GetArea()

	//Instancia o objeto LJCProcessoOffLine se necessario
	If oDadosOff == Nil
		oProcessOff := LJCProcessoOffLine():New("006")
	Else
		oProcessOff := oDadosOff
	EndIf

	//Verifica se foi passado numero do orcamento
	If Empty(cNumOrc)
		cNumOrc := M->LQ_NUM
	EndIf

	//Verifica se foi passado a filial de processamento
	If Empty(cFilProc)
		cFilProc := xFilial("SL1")
	EndIf

	//Insere os dados do processo (registro da tabela) SL1
	DbSelectArea("SL1")

	DbSetOrder(1)

	If (SL1->(DbSeek(cFilProc + cNumOrc)))

		cChave := cFilProc + SL1->L1_NUM
		oProcessOff:Inserir("SL1", cChave, 1, "INSERT")

	EndIf


	//Insere os dados do processo (registro da tabela) SL2
	aArea := SL2->(GetArea())

	DbSelectArea("SL2")

	If (SL2->(DbSeek(cFilProc + SL1->L1_NUM)))

		While !SL2->(EOF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cFilProc + SL1->L1_NUM

			cChave := cFilProc + SL2->L2_NUM + SL2->L2_ITEM +SL2->L2_PRODUTO
			oProcessOff:Inserir("SL2", cChave, 1, "INSERT")
			SL2->(DbSkip())

		End

	EndIf

	RestArea(aArea)


	//Insere os dados do processo (registro da tabela) SL4
	aArea := SL4->(GetArea())

	DbSelectArea("SL4")

	If (SL4->(DbSeek(cFilProc + SL1->L1_NUM)))

		While !SL4->(EOF()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == cFilProc + SL1->L1_NUM

			cChave := cFilProc + SL4->L4_NUM + SL4->L4_ITEM
			oProcessOff:Inserir("SL4", cChave, 4, "INSERT")	 //"2"
			SL4->(DbSkip())

		End

	EndIf

	RestArea(aArea)

	//Verifica se eh pedido (Tem reserva)
	If AllTrim(SL1->L1_TIPO) == "P" .AND. Empty(AllTrim(SL1->L1_FILRES)) .AND. Empty(AllTrim(SL1->L1_ORCRES))
		cNumDoc 	:= SL1->L1_DOCPED
		cSerie  	:= SL1->L1_SERPED

		If Alltrim(Upper(cMvLjPref)) == "SF2->F2_SERIE"
			cPrefixo	:= If(Empty(SL1->L1_SERIE), SL1->L1_SERPED, SL1->L1_SERIE)
		Else
			cPrefixo	:= &(cMvLjPref)
		Endif

		cNumE1 := LJ7NumTit()
	Else
		cNumDoc 	:= SL1->L1_DOC
		cSerie  	:= SL1->L1_SERIE
		cPrefixo	:= &(cMvLjPref)
		cNumE1 := LJ7NumTit()
	EndIf

	//Insere os dados do processo (registro da tabela) SF2
	DbSelectArea("SF2")

	cChave := cFilProc + cNumDoc + cSerie + SL1->L1_CLIENTE + SL1->L1_LOJA
	oProcessOff:Inserir("SF2", cChave, 1, "INSERT")

	//Insere os dados do processo (registro da tabela) SD
	aArea := SL2->(GetArea())

	DbSelectArea("SL2")

	If (SL2->(DbSeek(cFilProc + SL1->L1_NUM)))

		While !SL2->(EOF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == cFilProc + SL1->L1_NUM

			cChave := cFilProc + cNumDoc + cSerie + SL1->L1_CLIENTE + SL1->L1_LOJA + SL2->L2_PRODUTO + SL2->L2_ITEM

			If (SD2->(DbSeek(cChave)))

				If cAuxChave != cFilProc + SL2->L2_PRODUTO + SL2->L2_LOCAL
					cAuxChave := cFilProc + SL2->L2_PRODUTO + SL2->L2_LOCAL
					AADD(aSB2, cAuxChave)
				EndIf

				oProcessOff:Inserir("SD2", cChave, 3, "INSERT")

			EndIf

			SL2->(DbSkip())

		End

	EndIf

	RestArea(aArea)

	//Insere os dados do processo (registro da tabela) SB2
	aArea := SB2->(GetArea())

	DbSelectArea("SB2")

	For nCount := 1 To Len(aSB2)
		If (SB2->(DbSeek(aSB2[nCount])))
			oProcessOff:Inserir("SB2", aSB2[nCount], 1, "UPDATE")
		EndIf
	Next

	RestArea(aArea)

	//Insere os dados do processo (registro da tabela) SE1, SE5 e SEF
	aArea := SE1->(GetArea())

	DbSelectArea("SE1")

	DbSetOrder(1)

	//E1_FILIAL + E1_PREFIXO + E1_NUM
	If DbSeek(cFilProc + cPrefixo + cNumE1)

		While !SE1->(EOF()) .AND. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM  == cFilProc + cPrefixo + cNumE1

			cChave := cFilProc + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
			oProcessOff:Inserir("SE1", cChave, 1, "INSERT")

			If AllTrim(SE1->E1_TIPO) = "R$"

				cChave := cFilProc + SE1->E1_NATUREZ + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + DTOS(dDatabase)
				oProcessOff:Inserir("SE5", cChave, 4, "INSERT")

			ElseIf AllTrim(SE1->E1_TIPO) = "CH"

				cChave := cFilProc + SE1->E1_BCOCHQ + SE1->E1_AGECHQ + SE1->E1_CTACHQ + SE1->E1_NUMCART
				oProcessOff:Inserir("SEF", cChave, 1, "INSERT")

			EndIf

			SE1->(DbSkip())

		End

	EndIf

	RestArea(aArea)

	If lTemPedido

		aArea := SL1->(GetArea())

		DbSelectArea("SL1")

		DbOrderNickName("FILORCRES") //L1_FILRES + L1_ORCRES

		If (SL1->(DbSeek(cFilProc + cNumOrc)))

			While !SL1->(EOF()) .AND. SL1->L1_FILRES + SL1->L1_ORCRES == cFilProc + cNumOrc
				//Chama o metodo por recursividade
				Lj7AtuInte(oProcessOff, SL1->L1_NUM, SL1->L1_FILIAL, .F.)
				//Vai para o proximo registro
				SL1->(DbSkip())
			End
		EndIf

		RestArea(aArea)

	EndIf

	//Verifica se eh para processar
	If lProcOff
		//Processa os dados
		oProcessOff:Processar()
	EndIf

	//Restaura a area atual
	RestArea(aAreaAtual)
EndIf


Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7StarJobºAutor  ³Vendas Clientes     º Data ³  25/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                          				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function Lj7StarJob()

	IpcGo('FRONTVENDA')

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7CaUlCup   ºAutor  ³Vendas Clientes     º Data ³  25/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                               º±±
±±º          ³                                          				     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                               º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7CaUlCup(lConfirma)

Local nRet    		:= 0
Local nTamDoc     	:= TamSX3("L1_DOC")[1]
Local cNumCup		:= Space(nTamDoc)
Local cSerie		:= Padr(LjGetStation("LG_SERIE"),TamSX3("LG_SERIE")[1] )// Tamanho da Serie
Local cPDV  		:= Space(TamSX3("L1_PDV")[1])
Local aSL1
Local cLiMsg
Local cSupervisor	:= Space(15)
Local aReserva		:= {}
Local AVALEPRE		:= {}
Local lAutoExC		:= IsBlind()						// Verifica se a rotina sera executada via execauto ou nao

//Localizacoes
Local nOrdSL1  		:= SL1->(IndexOrd())
Local lRet     		:= .T.   							// .T. - Erro no cancelamento do cupom, .F. - Cancelamento com sucesso
Local aDadosCrd		:= {}					 			// Dados do cliente para o web service

Local lFRTCancelat  := ExistTemplate("FRTCancela")		// verifica se existe o PONTO DE ENTRADA FRTCancela
Local xRet                                         		// Retorno do PE FRTCANCCF
Local lFrtCancCF    := ExistBlock("FRTCANCCF")     		// Verifica se existe o ponto de entrada FRTCancCF
Local oObj
Local cUsrSessionID := ""
Local cAntNumCup	:= ""										//Numero do cupom anterior
Local lCancPenCup	:= .F.										//Valida se exclui o penultimo cupom, quando impresso algum Comprovante de Cred. e Deb. (CCD)
Local nTamCup		:= 0										//Tamanho da variável cNumCup
Local lVendTef		:= .F.
Local lTefOk		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND.	CrdxInt() 	 //Indica se a recarga de cartao fidelidade esta ativa
Local lCancelPAF	:= .F.								//Verifica cancelamento especifico para PDV PAF-ECF, caso a venda não tenha subido para a retaguarda, aguarda subida para cancelamento efetivo

Private lExcAuto	:= .F.

DEFAULT lConfirma	:= .T.								// Verifica se pede confirmação para cancelamento, Loja140 chama rotina sem pedir confirmação

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o cupom está fechado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRet := IFPegCupom( nHdlECF,@cNumCup )
nTamCup := Len(cNumCup)
cNumCup  := PADR(cNumCup,nTamDoc) // Restaura o tamanho da variavel cNumcup para a comparação com L1_DOC
If nRet <> 0
	HELP(' ',1,'FRT011')	      // "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Valtype(aKey) = "A"		
		FRTSetKey(aKey)
	EndIf
	Return lRet
Else
	If lFrtCancCF
		xRet := ExecBlock("FRTCANCCF",.F.,.F.,{cNumCup})
		If ValType(xRet) == "C"
		   cNumCup  := xRet
		Endif
	Endif
Endif

nRet := IFPegPDV(nHdlECF, @cPDV)
cPDV := PADR(cPDV, TamSX3("L1_PDV")[1])
If nRet <> 0
	HELP(' ',1,'FRT011')	      // "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Valtype(aKey) = "A"		
		FRTSetKey(aKey)
	EndIf
	Return lRet
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o SL1 na ultima venda          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL1")
SL1->(DbSetOrder(2))
IF SL1->(DbSeek(xFilial("SL1")+cSerie+cNumCup+cPDV))
	// Caso haja a chave acima duplicada , busca a ultima venda para cancelar
	// pode haver duplicado caso troque o ecf e não altere o numero de serie.
	While  .T.
		IF SL1->L1_EMISNF == Date()
			Exit
		Else
			SL1->(DbSkip())
			If (xFilial("SL1")+cSerie+cNumCup+cPDV) <> SL1->(xFilial("SL1")+L1_SERIE+L1_DOC+L1_PDV) ;
	    		.OR. SL1->(EOF())
				SL1->(DbSkip(-1))
				Exit
			EndIf
		EndIf
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o cupom da ultima venda não for o mesmo do ECF nao faz o cancelamento     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(cNumCup) <> Alltrim(SL1->L1_DOC)
	cAntNumCup := AllTrim(cNumCup)
	cNumCup  := PADR(StrZero(Val(AllTrim(cNumCup))-1,nTamCup),nTamDoc)
	If !SL1->(DbSeek(xFilial("SL1")+cSerie+cNumCup+cPDV))
		lRet		:= .F.

		// "O último cupom do ECF não corresponde com a última venda. Não será feito o cancelamento do cupom.", "Atenção"
		HELP(' ',1,'FRT035')
	Else
		lCancPenCup := .T.
	EndIf
Else
	lRet := .T.
EndIf

If lRet
	If lConfirma
		If Len(aReserva) == 0
			lRet := MsgYesNo(STR0146 +cNumCup+STR0119, STR0147 ) // "Realiza o CANCELAMENTO do Cupom Fiscal nº " ### " ?", "Atenção"
		Else
			lRet := MsgYesNo(STR0148, STR0147 ) //"Realiza o CANCELAMENTO do Cupom não Fiscal? ""Atenção"
		EndIf
	Else
		lRet := .T.
	EndIf
Endif

//PAFECF: Valida Serie/GT para realizar o cancelamento
If lMVLJPDVPA .AND. (!LJValGT() .OR. !LjVldSerie())
	If !lAutoExC
		MsgStop(STR0164)	//"Cancelamento não realizado!"
	Else
		ConOut(STR0164)		//"Cancelamento não realizado!"
		Help( " ", 1, "Help",, STR0164, 1, 0 )
	EndIf
	lRet := .F.
EndIf

LjRegRefsh("SL1") // Caso orcamento tenha subido e alterado L1_SITUA enquanto esta cancelando

lCancelPAF := IIF(lMVLjPdvPa .AND. SL1->L1_SITUA <> "TX",.T.,.F.)

If !isBlind() .AND. SL1->L1_VENDTEF == "S" .AND. (SL1->L1_CARTAO > 0 .OR. SL1->L1_VLRDEBI > 0)
	If lUsatef
		lVendTef := .T.
	Else
		lVendTef := .F.
	EndIf
EndIf

If lRet .AND. ( !lConfirma .OR. LJProFile(8,@cSupervisor,,,, .T. ) ) //Qdo vier do Loja140 nao deve validar permissao de caixa

	If !lCancelPAF
		aSL1 := {{"L1_SITUA",	"07"}}				// "07" - Solicitado o Cancelamento do Cupom
	Else
		aSL1 := {{"L1_STORC",	"C"}}				// "C" - Sinaliza Venda Cancelada, para gerar SLI apos subir a venda para retaguarda, nesse momento não possui L1_NUMORIG
	EndIf

	FR271BGeraSL("SL1", aSL1)

	If Len(aReserva) == 0

		If lCancPenCup
			nRet := IFEstornVinc(	nHdlECF,AllTrim(SL1->L1_CGCCLI),"","",;
									"Cancelamento de Comprovante de Crédito e Débito",cAntNumCup)
			If nRet <> 0
				MsgAlert(	"Não foi possível efetuar o cancelamento do cupom vinculado. Verifique se o último " +;
							"impresso foi um relatório gerencial caso seja não é permitido o cancelamento " )

				aSL1 := {{"L1_SITUA",	"00"}}	// Retira a solicitação de cancelamento
				FR271BGeraSL("SL1", aSL1)

				// "O Cupom fiscal nº "+cNumCup+", não pode ser cancelado."
				MsgStop(STR0020+cNumCup+STR0021)

				//Restaura os SetKey's do Fechamento da Venda
				If Valtype(aKey) = "A"		
					FRTSetKey(aKey)
				EndIf
				Return lRet
			EndIf
		EndIf

		//Insere MD5 no campo pois no movimento por ECF, ao validar o MD-5 deste deletado deve trazer com ele correto
		aSL1 := {{"L1_PAFMD5", STxPafMd5("SL1")}}
		FR271BGeraSL("SL1", aSL1)
				
		/*
		Homologacao 2017 - PAF-ECF 
		Quando tenho cancelamento de CCD ele aumenta o numero de comprovantes
		fazendo com que na hora de gravar o log de cancelamento (SLX) não seja
		gravada corretamente
		*/ 
		nRet := IFCancCup(nHdlECF, cSupervisor,IIF(lCancPenCup,cNumCup,""))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cancela o TEF na Administradora³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTEF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se estiver configurado a CLISITEF, passa o objeto oTEF. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipTEF == TEF_CLISITEF
			Lj140CnAdm(.F., @lVendTef, @oTEF		, @lTefOk)
		Else
			Lj140CnAdm(.F., @lVendTef, /*@oTEF*/	, @lTefOk)
		EndIf
	EndIf

	If nRet == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso exista Integracao com o SIGACRD, cancela o Credito em aberto     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CrdXInt()
			If Empty(cUsrSessionID)
				If !lAutoExC
					LJMsgRun(STR0153,, {|| cUsrSessionID := WSCrdLogin( cUserName, cSenha ) } ) //"Aguarde... Efetuando login no servidor ..."
				Else
					cUsrSessionID := WSCrdLogin( cUserName, cSenha )
				EndIf
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa um webservice para saber qual o status da analise de credito ³
			//³do cliente. Se for diferente de 4 (fila de crediario) pode cancelar  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oObj:=WSCRDSTATUS():New()
			oObj:_URL			:= "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDSTATUS.apw"
			oObj:cCodCli		:= SL1->L1_CLIENTE
			oObj:cLoja			:= SL1->L1_LOJA
			oObj:cUsrSessionID	:= cUsrSessionID

			If oObj:GetStatus()
				If oObj:OWSGETSTATUSRESULT:CSITUACAO <> "4"	// Fila de crediario
		  			aDadosCrd := {}
					aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
					aAdd( aDadosCrd, aCrdCliente[1] )		// CNPJ/CPF

					// Faz o desfazimento da transacao de credito
					CrdxVenda( "3"   ,aDadosCrd  ,If(Empty(SL1->L1_CONTRA),cContrato,SL1->L1_CONTRA),.T.   ,;
					           NIL   ,NIL )
				EndIf
			Else
				Conout(GetWSCError())
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Limpa as variaveis staticas de controle da analise de credito³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Fr271ICrdSet( @cContrato	, @aCrdCliente	,  @aContratos	, @aRecCrd)

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega os dados do SL1 antes de deleta-lo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLiMsg := SL1->L1_NUMORIG+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se foi utilizado VP na venda como forma de pagamento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SL4")
		SL4->(DbSetOrder(1))
		If SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
			While !SL4->(Eof()) .AND. (SL4->L4_FILIAL+SL4->L4_NUM == xFilial("SL4")+SL1->L1_NUM)
				If AllTrim(SL4->L4_FORMA) == "VP"
		   			aAdd(aValePre,{AllTrim(SL4->L4_NUMCART),"2"})
				EndIf
				SL4->(DbSkip())
			End
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se foi vendido algum VP na venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))
		If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
			While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM)
				If SL2->(FieldPos("L2_VALEPRE")) > 0 .AND. !Empty(SL2->L2_VALEPRE)
		   			aAdd(aValePre,{AllTrim(SL2->L2_VALEPRE),"1"})
				EndIf
				SL2->(DbSkip())
			End
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Cartão Fidelidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLjcFid
			DbSelectArea("SL2")
			SL2->(DbSetOrder(1))
			If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM)
					If LaFunhProd(SL2->L2_PRODUTO) .AND.	!Empty(SL2->L2_NUMCFID) .AND. !Empty(SL2->L2_DTSDFID) .AND. (SL2->L2_VLRCFID > 0)
			 	   		//Cancelamento de venda de recarga de cartao fidelidade
			 			If !Ca280Exec("CA280ESLD",SL2->L2_NUMCFID,,,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,"4")
			 				aSL1 := {{"L1_SITUA",	"00"}}				// Retira a solicitação de cancelamento
							FR271BGeraSL("SL1", aSL1)
							MsgStop(STR0155 +cNumCup+ STR0156)//// "O Cupom fiscal nº "+cNumCup+", não pode ser cancelado devido a falha na atualização do saldo do cartão fidelidade."
							Return lRet
			 			EndIf
			 			Exit
			 		EndIf
			 		SL2->(DbSkip())
			 	End
			 EndIf

	 		//Cancelamento de venda com forma de pagamamento FID - Cartao fidelidade
			DbSelectArea("SL4")
			SL4->(DbSetOrder(1))
			If SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
				While SL4->(!Eof()) .AND. SL4->L4_NUM == SL1->L1_NUM
					If Alltrim(SL4->L4_FORMA) == "FID"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se a venda foi paga com cartao fidelidade, entao o ³
						//³movimento de saida sera estornado da tabela MBN    ³
						//³e o valor devolvido ao respectivo saldo.           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !(Ca280Exec("CA280ESLD",SL4->L4_NUMCFID,,,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,"3"))
							aSL1 := {{"L1_SITUA",	"00"}}				// Retira a solicitação de cancelamento
							FR271BGeraSL("SL1", aSL1)
							MsgStop(STR0155 +cNumCup+ STR0156)//// "O Cupom fiscal nº "+cNumCup+", não pode ser cancelado devido a falha na atualização do saldo do cartão fidelidade."
							Return lRet
						Endif
	 					Exit
	 				EndIf
	 				SL4->(DbSkip())
				End
			EndIf

		EndIf

		FR271BCancela()

		lFechaCup := .T.

		If Len(aValePre) > 0
			LjEstVP(aValePre)
		EndIf

		If SL1->L1_CREDITO > 0
			If Empty(SL1->L1_DOC)
				cParmDoc := SL1->L1_DOCPED
			Else
				cParmDoc := SL1->L1_DOC
			Endif

			If Empty(SL1->L1_SERIE)
				cParmSer := SL1->L1_SERPED
			Else
				cParmSer := SL1->L1_SERIE
			Endif

                        Frt060ExNCC(SL1->L1_FILIAL,cParmDoc	,cParmSer		,SL1->L1_CLIENTE,;
                        			SL1->L1_LOJA  , .F.		, SL1->L1_NUM	,SL1->L1_OPERADO,;
                        			SL1->L1_EMISNF,SL1->L1_CREDITO)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Reinicializa as variaveis estaticas p/ rotina de recebimento de NCC	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Frt060End()

		//³ Reinicializa as variáveis de Templates                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		uCliTPL := Nil
		uProdTPL:= Nil
        cCodConv:= ""
        cLojConv:= ""
		cNumCartConv := ""

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define cliente com o padrao do parametro ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
		cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
		nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
		cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera o SLI , necessario que a venda tenha subido para a retaguarda, caso nao tenha subido, gera SLI no momento que subir ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMVLjPdvPa .OR. nModulo == 23
			If !lCancelPAF
				FR271BGerSLI("    ", "CAN", cLiMsg, "NOVO")
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. Apos o Cancelamento        ³
		//³ Tipo      : 1 - Item            ³
		//³             2 - Cupom           ³
		//³ Supervisor: Senha que autorizou ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFRTCancelat
			uProdTPL := ExecTemplate("FRTCancela",.F.,.F.,{2,cSupervisor,,uProdTPL})
		EndIf
		If ExistBlock("FRTCancela")
			ExecBlock("FRTCancela",.F.,.F.,{2,cSupervisor,NIL,uProdTPL})
		EndIf

	Else
		aSL1 := {{"L1_SITUA",	"00"}}				// Retira a solicitação de cancelamento
		FR271BGeraSL("SL1", aSL1)
		// "O Cupom fiscal nº "+cNumCup+", não pode ser cancelado."
		MsgStop(STR0149+cNumCup+STR0150)
		Return lRet
	Endif
EndIf
SL1->(DbSetOrder(nOrdSL1))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7BxNccWS   ºAutor  ³Vendas Clientes     º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a baixa da NCC via WebService                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7BxNccWS(cL1Doc, cL1Serie, cParcela, aRecnoSE1, aVlrReceb)
Local nTamE1_PARCELA

Local cMvLjPref
Local cOperado := xNumCaixa()
Local lParc    := ""

Default cL1Doc   	:= If(Empty(SL1->L1_DOCPED),SL1->L1_DOC,SL1->L1_DOCPED)
Default cL1Serie 	:= If(Empty(SL1->L1_SERPED),SL1->L1_SERIE,SL1->L1_SERPED)
Default cParcela 	:= ""
Default aRecnoSE1	:= {}
Default aVlrReceb	:= {}


nTamE1_PARCELA	:= TamSX3("E1_PARCELA")[01]								// Tamanho do campo E1_PARCELA
cMvLjPref		:= SuperGetMV("MV_LJPREF")								// Regra para gravacao do SF2->F2_PREFIXO
lParc 			:=  cParcela											// Campo E1_PARCELA

cParcela := PadR(SuperGetMV("MV_1DUP"), nTamE1_PARCELA)

While SE1->(DbSeek(xFilial("SE1") + cL1Serie + cL1Doc + cParcela + "NCC"))
	cParcela := CHR(ASC(cParcela)+1)
End

While CHR(ASC(cParcela)) < CHR(ASC(lParc))
	cParcela := CHR(ASC(cParcela)+1)
End

If nModulo == 23 .And. (Type("nNccUsada") == "U" .Or. Type("nNccGerada") == "U") //23=SIGAFRT
	nNccUsada	:= Frt060Ret("NCC_USADA")
	nNccGerada 	:= Frt060Ret("NCC_GERADA")
EndIf
Frt060Alt("NCC_USADA" ,nNccUsada )
Frt060Alt("NCC_GERADA",nNccGerada)
Frt060BxNCC(cL1Doc		, cL1Serie		, cOperado	, SE1->E1_EMISSAO	,;
   			SA1->A1_COD	, SA1->A1_LOJA	, nNccUsada	, Nil				,;
   			nNccGerada	, Nil			, Nil		, cParcela			,;
   			aRecnoSE1	,aVlrReceb)
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjNitCli  ºAutor  ³Microsiga           º Data ³  14/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface para confirmacao do cliente a ser gravado nos ar- º±±
±±º          ³quivos fiscais (Especifico Bolivia)                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Nome do cliente utilizado na venda (opcional)       º±±
±±º          ³ExpC2 - NIT do cliente utilizado na venda (opcional)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701C                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjNitCli(cGetNome,cGetNit,lNfManual)
Local cPictNit	:= PesqPict("SA1","A1_CGC")
Local lRet		:= .F.
Local lInfNFMan	:= SF2->(ColumnPos("F2_MANUAL")) > 0
Local bValid	:= Nil
Local oCkhBx	:= Nil
Local oGetNit	:= Nil
Local oGetNome	:= Nil
Local oDlg		:= Nil

Default cGetNome  := ""
Default cGetNit   := ""

//Dimensiona corretamente os campos
If Len(cGetNome) == 0
	cGetNome:= Space(TamSX3("A1_NOME")[1])
EndIf
If Len(cGetNit) == 0
	cGetNit	:= Space(TamSX3("A1_CGC")[1])
EndIf

//Validacao da tela
bValid := {||If(!Empty(cGetNome).AND.!Empty(cGetNit),.T.,(MsgStop(STR0133),.F.))} //"Informe corretamente o nome e o NIT"

//Interface
DEFINE MSDIALOG oDlg TITLE STR0134 FROM 178,181 TO 311,520 PIXEL //"Identificação do cliente"

	@ 002,003 TO 052,166 LABEL STR0135 PIXEL OF oDlg //"Dados do cliente para efeitos fiscais"

	@ 013,008 Say STR0136	Size 018,008 COLOR CLR_BLACK PIXEL OF oDlg	//"Nome:"
	@ 012,034 MsGet oGetNome Var cGetNome Size 126,009 PIXEL OF oDlg

	@ 027,008 Say STR0137 	Size 018,008 COLOR CLR_BLACK PIXEL OF oDlg	//"NIT:"
	@ 026,034 MsGet oGetNit Var cGetNit Size 126,009 COLOR CLR_BLACK Picture cPictNit PIXEL OF oDlg

	If lInfNFMan
		@ 040,008 CheckBox oCkhBx Var lNfManual Prompt STR0138 Size 065,008 PIXEL OF oDlg //"Nota Fiscal manual"
	EndIf

	DEFINE SBUTTON FROM 054,108 TYPE 1 ENABLE OF oDlg Action (If(Eval(bValid),(lRet := .T.,oDlg:End()),.F.))
	DEFINE SBUTTON FROM 054,138 TYPE 2 ENABLE OF oDlg Action (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7AjustStºAutor  ³Microsiga           º Data ³  16/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta a string que vai gravar o tipo de tributacao do item º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Situacao tributaria do item                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA701C                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj7AjustSt(cSitTrib)
Local cSitSFT	:= ""
Local cAliqIcm	:= ""

DEFAULT cSitTrib := ""

//-- No caso de Tributado , tem que ser da mesma aliquota--
If "T" $ cSitTrib
	cAliqIcm:=StrTran(cSitTrib," ","")
	cSitSFT := StrTran(cAliqIcm,".","")
	cSitSFT := SubStr(cSitSFT,2,Len(cSitSFT))
	cAliqIcm:= SubStr(cAliqIcm,2,Len(cAliqIcm))
	If Len(cSitSFT) == 1 .OR. Len(SubStr(cAliqIcm,1,At(".",cAliqIcm)-1)) == 1
		cSitSFT := "0"+cSitSFT
	EndIf
	cSitTrib := "T"+PadR(cSitSFT,4,"0")
ElseIf "S" $ cSitTrib
	If SubStr(cSitTrib,1,1) $ "F#I#N" // FS1 - SN1 - IS1
		cSitTrib	:= cSitTrib
	Else
		cAliqIcm	:= StrTran(cSitTrib," ","")
		cSitSFT 	:= StrTran(cAliqIcm,".","")
		cSitSFT 	:= SubStr(cSitSFT,2,Len(cSitSFT))
		cAliqIcm	:= SubStr(cAliqIcm,2,Len(cAliqIcm))
		If Len(cSitSFT) == 1 .OR. Len(SubStr(cAliqIcm,1,At(".",cAliqIcm)-1)) == 1
			cSitSFT := "0"+cSitSFT
		EndIf
		cSitTrib := "S"+PadR( cSitSFT ,4,"0")
	EndIf
ElseIf SubStr(cSitTrib,1,Len(cSitTrib)) $ "F#I#N"
	cSitTrib += "1"
EndIf

Return cSitTrib

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LA701GrvVPºAutor  ³Leandro Nogueira    º Data ³  30/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava o movimento de venda perdida                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LA701GrvVp(oMoviVp,cNumOrc,cDoc,cSerie)
Local cNumVenPer:= 0					// Sequencial do codigo do movimento de venda perdida
Local nSaveSx8 	:= GetSx8Len()			// Numeracao do SX8
Local nY		:= oMoviVp:GetTotMov()	//Total de movimentos de venda perdida armazenados no objeto collection
Local cOldAlias := Alias()
Local nX        := 0
Local lRet		:= .T.
Local nItem		:= 0
Local nTent		:= 0

Default oMoviVp	:= NIL
Default	cNumOrc := ""
Default	cDoc	:= ""
Default	cSerie	:= ""

cNumVenPer:= GetSxENum("MBR","MBR_CODIGO")

DbSelectArea("MBR")
If oMoviVp <> NIL
	For nX := 1 to nY

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obter chave do item atraves do indice da colecao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nItem:= oMoviVp:GetNumItem (nX)

		If oMoviVp:GetAtivoVp (nItem)

			cMay := xFilial( "MBR" ) + cNumVenPer
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se dois movimentos de venda perdida iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTent := 0
			While MBR->( DbSeek( xFilial( "MBR" ) + cNumVenPer ) ) .OR. !MayIUseCode( cMay )
				If ++nTent > 20
					MsgAlert(STR0153+ CHR(10)+CHR(13)+;//"Impossivel gerar número sequencial de movimento de venda perdida."
								STR0154) //"O movimento de venda perdida nao sera registrado !"
					lRet := .F.
					Return lRet
				EndIf
				While ( GetSX8Len() > nSaveSx8 )
					ConfirmSx8()
				End
				cNumVenPer:= GetSxENum("MBR","MBR_CODIGO")
				FreeUsedCode()
				cMay := Alltrim( xFilial( "MBR" ) ) + cNumVenPer
			End

			DbSelectArea("MBR")

			Begin Transaction

			RecLock("MBR", .T.)

			REPLACE MBR_FILIAL	WITH   xFilial ("MBR")
			REPLACE MBR_CODIGO 	WITH   cNumVenPer
			REPLACE MBR_DOC 	WITH   cDoc
			SerieNfId("MBR",1,"MBR_SERIE",dDataBase,LjEspecieNF(),cSerie)								
			REPLACE MBR_MOTIVO	WITH   oMoviVp:GetCdMotVp(nItem)
			REPLACE MBR_NUMORC  WITH   cNumOrc
			REPLACE MBR_PROD	WITH   oMoviVp:GetProdVp (nItem)
			REPLACE MBR_ITEM	WITH   oMoviVp:GetItemVp (nItem)
			REPLACE MBR_QUANT	WITH   oMoviVp:GetQtdeVp (nItem)
			REPLACE MBR_JUSTIF	WITH   oMoviVp:GetJustVp (nItem)
			REPLACE MBR_AVDISP	WITH   oMoviVp:GetDispVp (nItem)
			REPLACE MBR_LOJA	WITH   oMoviVp:GetLoja	 (nItem)
			REPLACE MBR_VEND	WITH   oMoviVp:GetVend	 (nItem)
			REPLACE MBR_CODCLI	WITH   oMoviVp:GetcodCli (nItem)
			REPLACE MBR_EMISSA	WITH   oMoviVp:GetEmissao(nItem)

			DbCommit()
			MsUnLock()

			End Transaction


			LA701IntVp ()

		Else
			lRet := .F.
		EndIf
	Next nX
EndIf

DbSelectArea(cOldAlias)

ConfirmSx8()

oMoviVp := LA701KilVp ()

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LA701IntVp³ Autor ³ Leandro Nogueira		³ Data ³20/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia movimento de venda perdida para a integracao  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Assistida	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LA701IntVp ()

Static cTipo 		:= ""												//Como os dados serao integrados no processo offline
Static oProcessOff 	:= Nil												//Objeto do tipo LJCProcessoOffLine
Static lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)				//Identifica se o ambiente esta operando em offline
Static lMvLjPdvPa 	:= LjxBGetPaf()[2]// Indica se é pdv

//Verifica se o ambiente esta em off-line
If lAmbOffLn .AND. lMvLjPdvPa
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New("032")

	//Determina o tipo de operacao
	If INCLUI
		cTipo := "INSERT"
	ElseIf ALTERA
		cTipo := "UPDATE"
	Else
		cTipo := "DELETE"

		//Considera os registros deletados
		SET DELETED OFF
	EndIf

	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir("MBR", xFilial("MBR") +;
									MBR->MBR_CODIGO+;
									MBR->MBR_NUMORC+;
									MBR->MBR_DOC+;
									MBR->MBR_SERIE+;
									MBR->MBR_PROD+;
									MBR->MBR_ITEM, 1, cTipo)

		//Processa os dados
		oProcessOff:Processar()
	EndIf

	//Desconsidera os registros deletados
	SET DELETED ON
EndIf


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj7GrvMotDesc³ Autor ³ Vendas Clientes      ³ Data ³ 02/12/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o motivo de desconto 					                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Serie do documento     								   ³±±
±±³          ³ExpN2 - Número do documento                                      ³±±
±±³          ³ExpN3 - Número do orçamento                                      ³±±
±±³          ³ExpN4 - Tipo de Motivo : 'O' - Orçamento / '' - Venda            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL												               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7GrvMotDesc( cSerie , cDoc , cNumOrc, cTipo)

Local nX	   := 0

Default cSerie 	:= ""
Default cDoc   	:= ""
Default cNumOrc	:= ""
Default cTipo  	:= ""	     // cTipo : 'O'- orçamento / '' - venda   ; mais tarde o valor deste será usado como filtro no relatorio

OGrvMtoDes := Lj7GetMot()
If !OGrvMtoDes == Nil
	For nX := 1 to      OGrvMtoDes:oDadosCDes:Count()
		If OGrvMtoDes:oDadosCDes:Elements(nX):lAtivo
			DbSelectArea("MDU")
			RecLock("MDU",.T.)

			REPLACE MDU_FILIAL  WITH xFilial("MDU")
			REPLACE MDU_CODIGO  WITH OGrvMtoDes:oDadosCDes:Elements(nX):cCodigo
			REPLACE MDU_OBS  	WITH OGrvMtoDes:oDadosCDes:Elements(nX):cObs
			REPLACE MDU_PRODUT  WITH OGrvMtoDes:oDadosCDes:Elements(nX):cProduto
			SerieNfId("MDU",1,"MDU_SERIE",dDataBase,LjEspecieNF(),cSerie)					
			REPLACE MDU_DOC  	WITH cDoc
			REPLACE MDU_DATA  	WITH dDatabase

			If OGrvMtoDes:oDadosCDes:ACOLECAO[nX][1] == 99999
				REPLACE MDU_TIPO WITH STR0143	//VALOR
			Else
				REPLACE MDU_TIPO WITH STR0144	//ITEM
			EndIf

			If (MDU->(FieldPos("MDU_STATUS"))) > 0
				REPLACE MDU->MDU_STATUS WITH cTipo
			EndIf

			If (MDU->(FieldPos("MDU_NUMORC"))) > 0
				REPLACE MDU->MDU_NUMORC WITH cNumOrc
			EndIf
			MsUnlock()

			// Inicia o processo de integracao Off-Line
			LJ7MovInt()

		ElseIf (MDU->(FieldPos("MDU_NUMORC"))) > 0
			DbSelectArea("MDU")
			DbSetOrder(3)
			If DbSeek(xFilial("MDU")+cNumOrc)
				RecLock("MDU",.F.)
				SerieNfId("MDU",1,"MDU_SERIE",dDataBase,LjEspecieNF(),cSerie)
				REPLACE MDU_DOC  	WITH cDoc
				MsUnlock()
			EndIf
		EndIf
	Next

EndIf
OGrvMtoDes := Nil 		//³Zera Objeto³
Lj7SetMot(@OGrvMtoDes)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    Lj7Arred    Autor ³ Vendas Cliente         ³ Data ³10.05.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a correcao dos arredondamentos do item             ³±±
±±³          ³ Utiliza o Array aSaveDecLJ para armazenar os centesimos    ³±±
±±³          ³ que foram truncados.Função baseada na MaItArred da MatxFis ³±±
±±³ 																	  ³±±
±±³ nP     = Se vier com 1 , limpa o array Statico na posição nPos,       ³±±
±±³          mas se nPos não for passado, limpa todo o Array              ³±±
±±³                                                                       ³±±
±±³ nPos   = 1 -> Se refere a calculo de arredondamento do Desconto normal³±±
±±³          ( CTRL+B)												   	  ³±±
±±³                                                                       ³±±
±±³ nPos   = 2 -> Se refere a calculo de arredondamento do Desconto       ³±±
±±³          financeiro ( E4_DESCFIN )                                    ³±±
±±³                                                                       ³±±
±±³ nPos   = 3 -> Se refere a calculo de arredondamento do Acrescimo      ³±±
±±³          financeiro ( E4_ACRSFIN )                                    ³±±
±±³                                                                       ³±±
±±³ nPos   = 4 -> Se refere a calculo de arredondamento do Item           ³±±
±±³                                                                       ³±±
±±³ nValor = Valor a ser arredondado e seu valor centesimal guardado em   ³±±
±±³          array de diferenças                                          ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Lj7Arred(nP,nPos,nValor,lArred)

Local nDec      := 2
Local nDifItem	:= 0
Local nRndPrec  := Iif (GetNewPar("MV_RNDPREC", 10)<3, 10, GetNewPar("MV_RNDPREC", 10))	//Precisao para o arredondamento
Local nValArred := 0
Local nX        := 0
DEFAULT nValor 	:= 0
DEFAULT nP 		:= 0
DEFAULT nPos    := 0
DEFAULT lArred	:= .F.

If Len(aSaveDecLj) == 0  .OR. nP == 1
    If nPos == 0
	    aSaveDecLj := Array(10,2)
	    For nX := 1 To Len(aSaveDecLj)
			aSaveDecLj[nX][1] := nX
			aSaveDecLj[nX][2] := 0
	    Next
    Else
		aSaveDecLj[nPos] := {nPos,0}
	EndIf
EndIf

nDifItem := 0

If nValor <> 0

	nValArred := NoRound(NoRound(nValor,nRndPrec),nDec,@nDifItem,10)

	If nDifItem > 0
		aSaveDecLj[nPos][2]	+= nDifItem  // Salva a diferenca a partir da segunda casa
		If ( aSaveDecLj[nPos][2] ) >= (50/(10**(nDec + 2))) 	// Se a dif for maior que 0.005 vai somar
			nValArred 	  := nValArred + (1/10**nDec) 			// Adiciona 1 centavo ao vlr calculado
			aSaveDecLj[nPos][2] -= (1/10**nDec)
			lArred		:= .T.		// Sinaliza que esse item sofreu um arredondamento
		EndIf
	EndIf

EndIf

Return nValArred


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao Lj7CanDAVOS    Autor ³ Vendas Cliente         ³ Data ³27/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Quando utilizado o conceito de DAV-OS para Oficina de Con-  ³±±
±±³          ³serto (MV_LJDAVOS == .T.) guarda a DAV inicial e cancela a  ³±±
±±³          ³ mesma para que seja gerado um novo orçamento de acordo com ³±±
±±³			 ³Requisito XLI do Ato Cotepe								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj7CanDAVOS()

RecLock("SL1" , .F. )
REPLACE SL1->L1_STORC WITH "C" 	//Deve-se cancelar o orçamento pois este deve ser mostrado na relação de DAVs Emitidos do Menu Fiscal
MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj7ImpRG      ³ Autor ³Vendas Cliente        ³ Data ³ 12/26/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera o Relatorio Gerencial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Numero do Handle              						   ³±±
±±³          ³ExpN2 - array com os valores do conteudo                         ³±±
±±³          ³ExpN3 - Codigo da OS                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet= Retorna se o relatorio foi gerado com sucesso             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA  -  Template de Otica                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7ImpRG(nHandle,aValores,cOs)

Local lRet			:= .F.		// Recebe Retorno
Local cConteudo		:= ""		// Recebe o Conteudo
Local nVias			:= 1		// Recebe a Quantidade de Vias a serem impressas
Local nTotal		:= 0		// Recebe o Total
Local nCount 		:= 0		// Contador

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³Cabecalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
cConteudo :=  CTRL+ "Nº O.S.: "+ cOs + CTRL
cConteudo +=  "Código           DESCRIÇÃO     UN. VL UNIT R$ /VLITEM R$" + CTRL
cConteudo +=  "------------------------------------------------------------" + CTRL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Itens do Relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCount := 1 To Len(aValores)

	nTotal += aValores[nCount][6]

	cConteudo += cValToChar(aValores[nCount][2])+"  "+ PAD(aValores[nCount][3],15)+ "  "+ ;
	cValToChar(aValores[nCount][4])+cValToChar(aValores[nCount][7]) +" X "+ ;
	AllTrim(Transform(aCols[nCount][5],"@E 999,999.99")) +"   "+ ;
	AllTrim(Transform(aCols[nCount][6],"@E 999,999.99")) + CTRL

Next nCount

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Totalizador ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cConteudo +=  CTRL + "------------------------------------------------------------" + CTRL
cConteudo +=  "TOTAL R$                                          "+ AllTrim(Transform(nTotal,"@E 999,999.99"))+ CTRL

cConteudo +=  "------------------------------------------------------------" + CTRL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Relatorio Gerencial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IFRelGer(nHandle,cConteudo,nVias) == 0
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | LjCFciParam ³Autor ³ Vendas e DL			³ Data ³ 07/10/2013	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se os parametros necessários para o funcionamento da   ³±±
±±³			 |adequação a legislação sobre FCI estão corretamente configurados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= LjCFciParam()										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 = Array com os resultados da funcionalidade de FCI	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701C / LOJXFUNC											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCFciParam()
Local aRet := {}

//Retorno as validacoes de dicionarios para as funcionalidades da FCI
aRet := {	SuperGetMv( "MV_FISFRAS",, .T.)												,;
			SuperGetMv( "MV_FCIMOD" ,, "" )												,;
			AliasInDic("CFD")															,;
			SD2->(FieldPos("D2_FCICOD") ) > 0											,;
			SD2->(FieldPos("D2_VLIMPOR")) > 0											,;
			SLR->(FieldPos("LR_VLIMPOR")) > 0 .And. SL2->(FieldPos("L2_VLIMPOR")) > 0	,;
			SD1->(FieldPos("D1_FCICOD") ) > 0											,;
			SLR->(FieldPos("LR_FCICOD") ) > 0 .And. SL2->(FieldPos("L2_FCICOD")) > 0	,;
			SuperGetMv( "MV_FISAUCF",, .T.)}

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | LjCRetFci  ³Autor ³ Vendas e DL			³ Data ³ 07/10/2013	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Altera o valor de importação e codigo de FCI de acordo com a    ³±±
±±³			 |configuração do produto (com ou sem rastro), priorizando as	  ³±±
±±³			 |informações digitadas pelo usuario na tela da venda.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= LjCRetFci(cProduto,cLote,cLoteCtl,nVlImp,cFciCod)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codigo do produto 									  ³±±
±±³          ³ExpC2 - Codigo do Sub-Lote de rastro do produto				  ³±±
±±³          ³ExpC3 - Codigo do Lote de rastro do produto					  ³±±
±±³          ³ExpN4 - Valor de importação do produto para a FCI				  ³±±
±±³          ³ExpC5 - Codigo da FCI do produto 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil														 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701C														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCRetFci(cProduto,cLote,cLoteCtl,nVlImp,cFciCod,cClasFisc,nItem)

Local nNwVlImp	:= 0
Local cNwFciCod	:= ""
Local cCodOrig	:= ""
Local lRet 		:= .F.
Local aDadosFCI		:= {}
Local lUsaRstro2	:= !ExistFunc("LjDadosFCI") .Or. Empty(SuperGetMV("MV_ULTAQUI",,""))

DEFAULT cProduto 	:= ""
DEFAULT cLote		:= ""
DEFAULT cLoteCtl	:= ""
DEFAULT nVlImp		:= 0
DEFAULT cFciCod		:= ""
DEFAULT cClasFisc	:= ""
DEFAULT nItem		:= 0

If !Empty(cProduto) .AND. nItem > 0
	
	If Rastro(cProduto)
		If lUsaRstro2
			SPEDRastro2(cLote, cLoteCtl, cProduto, @nNwVlImp, 0, .T., @cNwFciCod,nil,nil ,nil,nil,@cCodOrig )
		Else
			aDadosFCI	:= LjDadosFCI(cLote, cLoteCtl, cProduto)
			nNwVlImp	:= aDadosFCI[3]
			cNwFciCod	:= AllTrim(aDadosFCI[1])
			cCodOrig	:= aDadosFCI[2]
		EndIf
	Endif

	//Se nao tiver digitado os valores na venda:
	nVlImp	:= Iif( nVlImp > 0, nVlImp, nNwVlImp )
	cFciCod	:= Iif( !Empty(cFciCod), cFciCod, cNwFciCod )

	If !Empty( cCodOrig )
		MaFisAlt("IT_CLASFIS",cCodOrig + Substr(cClasFisc,2),nItem, .T.,,,,/*lRecal*/.T.)
		lRet := .T.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7SetParceiros
Seta dados Parceiros e itens para envio de e-mail

@param   aSetParceiro				Array com dados para envio de e-mail
@author  Varejo
@version P11.8
@since   02/12/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj7SetParceiros(aSetParceiro)

Default aSetParceiro := {}

aParceiros := aSetParceiro

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj7GetParceiros
Get dados Parceiros e itens para envio de e-mail

@param   aSetParceiro				Array com dados para envio de e-mail
@author  Varejo
@version P11.8
@since   02/12/2013
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj7GetParceiros()
Return aParceiros

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    | FEmiteNF  ³Autor ³ Vendas e DL			³ Data ³ 04/12/2013	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³efetua o faturamento de um determinado pedido, que ja exista e  ³±±
±±³			 |esteja devidamente liberado para ser faturado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aNf:= FEmiteNF(cPar1, cPar2, cPar3)	  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar1 - Codigo do cliente   									  ³±±
±±³          ³ cPar2 - Codigo da loja do cliente							  ³±±
±±³          ³ cPar3 - numero do pedido a ser faturado						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Array de dois elementos									 	  ³±±
±±³     	 ³aRet[1] = numero da nota fiscal emitida 					 	  ³±±
±±³     	 ³aRet[2] = serie da nota fiscal emitida					 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701C														  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FEmiteNF(_cCliente,_cLoja,_cPedido)
Local aAreaAnt	 	:= GetArea()
Local aAreaSC5	 	:= SC5->(GetArea())
Local aAreaSC6	 	:= SC6->(GetArea())
Local aAreaSC9	 	:= SC9->(GetArea())
Local aAreaSE4	 	:= SE4->(GetArea())
Local aAreaSB1	 	:= SB1->(GetArea())
Local aAreaSB2	 	:= SB2->(GetArea())
Local aAreaSF4	 	:= SF4->(GetArea())
Local aRet			:= {"",""}
Local aPvlNfs	 	:= {}
Local _cSeek      	:= ''
Local _nPrcVen    	:= 0
Local _nRegDAK   	:= 0
Local lMostraCtb 	:= .F.
Local lAglutCtb  	:= .F.
Local lCtbOnLine 	:= .F.
Local lCtbCusto  	:= .F.
Local lReajuste  	:= .F.
Local nCalAcrs   	:= 1
Local nArredPrcLis	:= 1
Local cRot       	:= ProcName()
Local cModAtu		:= cModulo
Local nModAtu		:= nModulo
Local _cSerie		:= SuperGetMV('MV_LJVFSER',,'UNI')
Local _cNota		:= ''

If lMostraCtb == Nil
	InitStVa()
Endif

lFaturado   := .F.
cModulo 	:= 'FAT'
nModulo		:= 5

LjGrvLog( _cPedido, "Inicio - Gera Nota de Simples Faturamento -  MV_LJVFNFS. dDataBase: ",dDataBase)

dDataBase := Date() //atualiza a dt para nao ter problemas de divergencia qndo o GrvBatch nao eh reiniciado de um dia para o outro

SC5->(DbSetOrder(3)) //C5_FILIAL, C5_CLIENTE, C5_LOJACLI, C5_NUM
If SC5->(MsSeek(xFilial('SC5')+_cCliente+_cLoja+_cPedido,.F.))
	SC6->(DbSetOrder(1)) //C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO
	_cSeek := xFilial('SC6')+_cPedido
	If SC6->(MsSeek(_cSeek,.F.))
		While SC6->(!Eof()) .And. SC6->C6_FILIAL+SC6->C6_NUM == _cSeek
			SC9->(DBSetOrder(2)) //C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_ITEM
			If SC9->(MsSeek(xFilial('SC9')+_cCliente+_cLoja+SC6->C6_NUM+SC6->C6_ITEM,.F.))
				// Posiciona na condicao de pagamento
				SE4->(DBSetOrder(1))
				SE4->(MsSeek(xFilial('SE4')+SC5->C5_CONDPAG,.F.))

				// Posiciona no produto
				SB1->(DBSetOrder(1))
				SB1->(MsSeek(xFilial('SB1')+SC6->C6_PRODUTO,.F.))

				// Posiciona no saldo em estoque
				SB2->(DBSetOrder(1))
				SB2->(MsSeek(xFilial('SB2')+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))

				// Posiciona no TES
				cTes := SC6->C6_TES
				SF4->(DBSetOrder(1))
				SF4->(MsSeek(xFilial('SF4')+cTes,.F.))

				//Converte o valor unitario em Reais quando pedido em outra moeda
				_nPrcVen := SC9->C9_PRCVEN
				If (SC5->C5_MOEDA <> 1)
					DbSelectArea("SM2")
					SM2->(DbSetOrder(1))
					If SM2->(DbSeek(DTOS(dDataBase)))
						_nPrcVen := SC9->C9_PRCVEN * SM2->M2_MOEDA2
					Else
						_nPrcVen := xMoeda(_nPrcVen,SC5->C5_MOEDA,1,dDataBase)
					EndIf
				EndIf

				// Monta array para gerar a nota fiscal
				Aadd(aPvlNfs,{	SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								_nPrcVen,;
								SC9->C9_PRODUTO,;
								.F.,;
								SC9->(RecNo()),;
								SC5->(RecNo()),;
								SC6->(RecNo()),;
								SE4->(RecNo()),;
								SB1->(RecNo()),;
								SB2->(RecNo()),;
								SF4->(RecNo()),;
								SC6->C6_LOCAL,;
								_nRegDAK,;
								SC9->C9_QTDLIB2})
			EndIf
			SC6->( DBSkip() )
		EndDo
	Else
		CONOUT(STR0175 + trim(_cPedido) ) //"Não pode faturar o pedido "
		LjGrvLog(_cPedido,STR0175 + trim(_cPedido))
		Aviso(cRot,STR0176+trim(_cPedido)+STR0177+trim(_cCliente)+"/"+trim(_cLoja)+STR0178,{"&Abandonar"}) //#STR0176->"Pedido " #STR0177->" do Cliente " #STR0178->" não pode ser faturado."
	EndIf
Else
	CONOUT( STR0176 + trim(_cPedido) + STR0179 ) //#STR0176->"Pedido " #STR0179->"não localizado"
	LjGrvLog(_cPedido,STR0176 + trim(_cPedido) + STR0179)
	Aviso(cRot,STR0176+trim(_cPedido)+STR0177+trim(_cCliente)+"/"+trim(_cLoja)+STR0180,{"&Abandonar"})//#STR0176->"Pedido " #STR0177->" do Cliente " #STR0180->" não econtrado."
EndIf

If !Empty(aPvlNfs)
	LjGrvLog(_cPedido, " Antes da Execução da Função MaPvlNFS ")
	Conout(" Antes da Execução da Função MaPvlNFS - Pedido #" + _cPedido)
	
	LjGrvLog(_cPedido,	" Função MaPvlNFS = variáveis -> aPvlNfs," +;
						" _cSerie	, lMostraCtb , lAglutCtb," +;
						" lCtbOnLine, lCtbCusto	, lReajuste , nCalAcrs ," +;
						" nArredPrcLis, lAtuSA7lECF",;
						{ aPvlNfs	, _cSerie	, lMostraCtb , lAglutCtb ,;
						lCtbOnLine	, lCtbCusto	, lReajuste  , nCalAcrs  ,;
						nArredPrcLis, lAtuSA7lECF })
	
	_cNota := MaPvlNFS(	aPvlNfs		, _cSerie	, lMostraCtb , lAglutCtb ,;
						lCtbOnLine	, lCtbCusto	, lReajuste  , nCalAcrs  ,;
						nArredPrcLis, lAtuSA7lECF)
	_cNota := AllTrim(_cNota)
	
	SX6->(MSRUnlock())
	LjGrvLog(_cPedido, " Depois da Execução da Função MaPvlNFS ")
	Conout(" Depois da Execução da Função MaPvlNFS  - Nota #" + _cNota)
Else
	LjGrvLog(_cPedido, " Array necessário para geração da nota em branco")
EndIf

cModulo	:= cModAtu
nModulo	:= nModAtu

If !Empty(_cNota)
	_cNota := Padr( _cNota, TamSx3('D2_DOC')[1])
	aRet := { _cNota, _cSerie }
	LjGrvLog(_cPedido, " Nota Gerada -> aRet ", aRet)
	DbSelectArea("SF2")
	SF2->(DbSetOrder( 1 )) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(DbSeek( xFilial( "SF2" ) + _cNota + _cSerie + SL1->L1_CLIENTE + SL1->L1_LOJA ))
		RecLock("SF2", .F.)
		SF2->F2_DUPL := _cNota
		SF2->(MsUnLock())
	EndIf
Else
	LjGrvLog(_cPedido, " A nota não foi gerada. ")
EndIf

// Retorna as areas originais
RestArea(aAreaSF4)
RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aAreaSE4)
RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaAnt)

LjGrvLog( _cPedido, "Fim - Gera Nota de Simples Faturameto -  MV_LJVFNFS. dDataBase: ",dDataBase)
LjGrvLog( _cPedido, "Fim - Gera Nota de Simples Faturameto -  MV_LJVFNFS. cNota: ",_cNota)

If !Empty(_cNota)
	aRet := { Padr( _cNota, TamSx3('D2_DOC')[1]), _cSerie }
	LjGrvLog(_cPedido, " Nota Gerada -> aRet ", aRet)
Else
	LjGrvLog(_cPedido, " A nota não foi gerada. ")
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    | InitStVa  ³Autor ³ Vendas e DL			³ Data ³ 04/12/2013	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Salva o conteudo das variaveis do pergunte efetua a leitura 	  ³±±
±±³			 |do pergunte de faturamento, preparando as variaveis utilizadas  ³±±
±±³			 |na função de emissao da nota fiscal de saida, restaurando o con-³±±
±±³			 |teudo das variaveis de pergunte em seguida.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ N/A						  									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³N/A														 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701C														  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function InitStVa()

Local aPerg			:= {}
Local _nX			:= 0

Private xVar
Private cNomVar		:= ""

For _nX := 1 to 60
	cNomVar := "MV_PAR" + StrZero( _nX )
	xVar := &(cNomVar)
	aadd( aPerg, xVar )
Next _nX

Pergunte('MT460A',.F.)

lMostraCtb  := MV_PAR01 == 1
lAglutCtb   := MV_PAR02 == 1
lCtbOnLine  := MV_PAR03 == 1
lCtbCusto   := MV_PAR04 == 1
lReajuste   := MV_PAR05 == 1
LAtuSA7lECF := .F.

For _nX := 1 to 60
	cNomVar := "MV_PAR" + StrZero( _nX )
	xVar := aPerg[ -nX ]
	&(cNomVar) := xVar
Next _nX

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjVFEGeraPed ºAutor³Vendas Clientes     º Data ³  05/05/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera Pre-Nota de Entrada e Pedido de Venda Para VFE - Venda º±±
±±º          ³Fora do Estad  											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := LjVFEGeraPed( ExpA1 ) 						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Array com os pedidos					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/FrontLoja                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjVFEGeraPed( aPedido )
Local nContPed	:= 0							// Contador Pedidos
Local nI 			:= 0							// Contador
Local nJ 			:= 0							// Contador
Local nY			:= 0							// Contador
Local nPos			:= 0							// Posicao
Local aAreaSC5 	:= SC5->( GetArea() )		// AreaSC5
Local aAreaSC6 	:= SC6->( GetArea() )		// AreaSC6
Local aAreaSC9 	:= SC9->( GetArea() )		// AreaSC6
Local cFilBkp		:= cFilAnt						// Bkp Filial
Local cNumSC5		:= ""							// Numero do Pedido	- Inclusao
Local cMay			:= ""							// Verificar se nao esta utilizando a numeração
Local cNFiscal	:= ""							// Numeracao Nota Entrada
Local aCabPed		:= {}							// Cabeçalho Pedido
Local aLinhaPed	:= {}							// (1)Item Pedido
Local aItensPed	:= {}							// Itens Pedido
Local cFilSC6		:= xFilial("SC6")				// Armazena Filial SC6
Local lLiber 		:= .F.							// Compatibilizacao com o SIGAFAT
Local lTransf		:= .F.      					// Compatibilizacao com o SIGAFAT
Local lLiberOk 	:= .T.							// Compatibilizacao com o SIGAFAT
Local lResidOk 	:= .T.							// Compatibilizacao com o SIGAFAT
Local lFaturOk 	:= .F.							// Compatibilizacao com o SIGAFAT
Local lTLVReg  	:= .F.							// Compatibilizacao com o SIGAFAT
Local cMV_CLIPAD	:= PadR(SuperGetMV("MV_CLIPAD"),TamSX3("F1_FORNECE")[1])	// Cliente padrao
Local cMV_LOJAPAD	:= PadR(SuperGetMV("MV_LOJAPAD"),TAMSX3("F1_LOJA")[1])		// Loja do cliente padrao
Local cCondPad	:= PadR(SuperGetMV("MV_CONDPAD"),TamSX3("L1_CONDPG")[1])	// Condicao de pagamento padrao
Local nTent 		:= 0										// Tentativas para pegar a numeracao do SC5
Local nSaveSx8 		:= GetSx8Len()								// Numeracao do SX8

Private lMSErroAuto	:= .F.						//VerIfica se ocorreu algum erro durante a Geracao do PV
Private aXCabec:= {}
Private aXItens:= {}
Private aLinha:= {}


Default aPedido := {}

If SuperGetMv("MV_LJVFE", Nil, .F.) .AND. SC5->(ColumnPos("C5_FILVFE")) > 0

	DbSelectArea("SC5")
	DbSetOrder(1)

	For nContPed := 1 To Len(aPedido)

		If DbSeek(xFilial("SC5")+aPedido[nContPed][1])

			If !Empty(SC5->C5_FILVFE)

				/*
					Entrada
				*/
				// Troca Filial
				cFilAnt := SC5->C5_FILVFE

				cNFiscal := MA461NumNf(.T.,"",cNFiscal)

				AADD(aXCabec,{"F1_FILIAL"	, xFilial("SF1")	, Nil})
				AADD(aXCabec,{'F1_DOC'		, cNFiscal			, Nil})
				AADD(aXCabec,{'F1_SERIE'		, '1'				, Nil})
				AADD(aXCabec,{'F1_FORNECE'	, cMV_CLIPAD		, Nil})
				AADD(aXCabec,{'F1_LOJA'		, cMV_LOJAPAD		, Nil})
				AADD(aXCabec,{'F1_EMISSAO'	, dDataBase		, Nil})
				AADD(aXCabec,{'F1_COND'		, cCondPad			, Nil})

				DbSelectArea("SC6")
				DbSetOrder(1)
				If DbSeek(cFilSC6+aPedido[nContPed][1])

					While SC6->(!Eof()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == aPedido[nContPed][1]

						aLinha := {}

						AADD(aLinha,{'D1_FILIAL'		, xFilial("SD1")			, Nil})
						AADD(aLinha,{'D1_DOC'		, cNFiscal					, Nil})
						AADD(aLinha,{'D1_SERIE'		, "1"						, Nil})
						AADD(aLinha,{'D1_FORNECE'	, cMV_CLIPAD				, Nil})
						AADD(aLinha,{'D1_LOJA'		, cMV_LOJAPAD				, Nil})
						AADD(aLinha,{'D1_ITEM'		, SC6->C6_ITEM			, Nil})
						AADD(aLinha,{'D1_COD'		, SC6->C6_PRODUTO			, Nil})
						AADD(aLinha,{'D1_QUANT'		, SC6->C6_QTDVEN			, Nil})
						AADD(aLinha,{'D1_VUNIT'		, SC6->C6_PRCVEN			, Nil})
						AADD(aLinha,{'D1_TOTAL'		, SC6->C6_VALOR			, Nil})

						AADD(aXItens, aLinha)

						SC6->( DbSkip() )

					EndDo

				EndIf

				MSExecAuto({|x,y,z| MATA140(x,y,z)}, aXCabec, aXItens, 3)

				If lMsErroAuto
					mostraerro()
				EndIf

				/*
					Saída
				*/
				// Armazena Cab/SC5
				aCabPed := {}
				Aadd(aCabPed,{ "C5_FILIAL",		""						,NIL })
				Aadd(aCabPed,{ "C5_NUM",			""						,NIL })
				Aadd(aCabPed,{ "C5_TIPO",		"N"						,NIL })
				Aadd(aCabPed,{ "C5_CLIENTE",	SC5->C5_CLIENTE		,NIL })
				Aadd(aCabPed,{ "C5_LOJACLI",	SC5->C5_LOJACLI		,NIL })
				Aadd(aCabPed,{ "C5_CLIENT",		SC5->C5_CLIENT		,NIL })
				Aadd(aCabPed,{ "C5_LOJAENT",	SC5->C5_LOJAENT		,NIL })
				Aadd(aCabPed,{ "C5_TRANSP",		SC5->C5_TRANSP		,NIL })
				Aadd(aCabPed,{ "C5_VEICULO",	SC5->C5_VEICULO		,NIL })
				Aadd(aCabPed,{ "C5_TIPOCLI",	SC5->C5_TIPOCLI		,NIL })
				Aadd(aCabPed,{ "C5_EMISSAO",	SC5->C5_EMISSAO		,NIL })
				Aadd(aCabPed,{ "C5_VEND1",		SC5->C5_VEND1			,NIL })
				Aadd(aCabPed,{ "C5_CONDPAG",	SC5->C5_CONDPAG		,NIL })
				Aadd(aCabPed,{ "C5_ORCRES",		SC5->C5_ORCRES		,NIL })
				Aadd(aCabPed,{ "C5_FRETE",		SC5->C5_FRETE			,NIL })
				Aadd(aCabPed,{ "C5_SEGURO",		SC5->C5_SEGURO		,NIL })
				Aadd(aCabPed,{ "C5_DESPESA",	SC5->C5_DESPESA		,NIL })
				Aadd(aCabPed,{ "C5_TPFRETE",	SC5->C5_TPFRETE		,NIL })
				Aadd(aCabPed,{ "C5_DESC1"	, 	SC5->C5_DESC1			,NIL })
				Aadd(aCabPed,{ "C5_DESCONT"	,	SC5->C5_DESCONT		,NIL })
				Aadd(aCabPed,{ "C5_MOEDA",		SC5->C5_MOEDA			,NIL })
				Aadd(aCabPed,{ "C5_TIPLIB",		SC5->C5_TIPLIB		,NIL })
				Aadd(aCabPed,{ "C5_TPCARGA",	SC5->C5_TPCARGA		,NIL })
				Aadd(aCabPed,{ "C5_GERAWMS",	SC5->C5_GERAWMS		,NIL })
				Aadd(aCabPed,{ "C5_MENPAD"	,	SC5->C5_MENPAD		,NIL })
				If  SC5->( FieldPos("C5_ECPRESN") > 0 )
					Aadd(aCabPed,{ "C5_ECPRESN",	SC5->C5_ECPRESN	,NIL })
				EndIf


				// Troca de Filial do sistema
				cFilAnt := SC5->C5_FILVFE

				//Numeração Pedido
				cNumSC5 := CRIAVAR("C5_NUM")
				cMay := "SC5"+ALLTRIM(xFilial("SC5"))+cNumSC5
				FreeUsedCode()
				While SC5->(DbSeek(xFilial("SC5")+cNumSC5)) .OR. !MayIUseCode(cMay)
					If ++nTent > 20
						FreeUsedCode()
					EndIf
					If nTent > 50 //Se nao conseguir ate 50 vezes, aborta o sistema.
						FreeUsedCode()
						Final("Impossivel gerar numero sequencial de PEDIDO correto. INFORME ESSA MENSAGEM PARA O DEPARTAMENTO DE TI.")
					EndIf
					cNumSC5 := CRIAVAR("C5_NUM")
					cMay := "SC5"+ALLTRIM(xFilial("SC5"))+cNumSC5
				End
				If __lSX8
					While (GetSX8Len() > nSaveSx8)
						ConfirmSx8()
					End
				Endif

				//Troca Filial do pedido
				nPos := aScan( aCabPed , {|x| Alltrim(Upper(x[1])) == "C5_FILIAL"} )
				aCabPed[nPos][2] := xFilial("SC5")

				//Troca numeração
				nPos := aScan( aCabPed , {|x| Alltrim(Upper(x[1])) == "C5_NUM"} )
				aCabPed[nPos][2] := cNumSC5

				//Grava Cabeçalho Pedido de Venda
 				If Len(aCabPed) > 0
					RecLock("SC5",.T.)
					For nJ := 1 To Len(aCabPed)
				 		SC5->&(aCabPed[nJ][1])	:= aCabPed[nJ][2]
				   	Next nJ
				Endif
				FkCommit() // Commit para integridade referencial do SC5

				// Itens Pedido
				DbSelectArea("SC6")
				DbSetOrder(1)
				If DbSeek(cFilSC6+aPedido[nContPed][1])

					While SC6->(!Eof()) .AND. SC6->C6_FILIAL == cFilSC6 .AND. SC6->C6_NUM == aPedido[nContPed][1]

						aLinhaPed := {}

						Aadd(aLinhaPed,{ "C6_FILIAL",	xFilial("SC5")	   				,NIL })
						Aadd(aLinhaPed,{ "C6_NUM",		cNumSC5							,NIL })
						Aadd(aLinhaPed,{ "C6_ITEM",		SC6->C6_ITEM						,NIL })
						Aadd(aLinhaPed,{ "C6_PRODUTO",	SC6->C6_PRODUTO		  			,NIL })
						Aadd(aLinhaPed,{ "C6_DESCRI",	SC6->C6_DESCRI					,NIL })
						Aadd(aLinhaPed,{ "C6_UM",		SC6->C6_UM							,NIL })
						Aadd(aLinhaPed,{ "C6_QTDVEN",	SC6->C6_QTDVEN					,NIL })
						Aadd(aLinhaPed,{ "C6_QTDLIB",	SC6->C6_QTDLIB				 	,NIL })
						Aadd(aLinhaPed,{ "C6_PRCVEN",	SC6->C6_PRCVEN					,NIL })
						Aadd(aLinhaPed,{ "C6_VALOR",	SC6->C6_VALOR						,NIL })
						Aadd(aLinhaPed,{ "C6_TES",		SC6->C6_TES						,NIL })
						Aadd(aLinhaPed,{ "C6_CF",		SC6->C6_CF							,NIL })
						Aadd(aLinhaPed,{ "C6_LOCAL",	SC6->C6_LOCAL						,NIL })
						Aadd(aLinhaPed,{ "C6_CLI",		SC6->C6_CLI 						,NIL })
						Aadd(aLinhaPed,{ "C6_LOJA",		SC6->C6_LOJA 						,NIL })
						Aadd(aLinhaPed,{ "C6_PRUNIT",	SC6->C6_PRUNIT					,NIL })
						Aadd(aLinhaPed,{ "C6_TPOP",		SC6->C6_TPOP						,NIL })
						Aadd(aLinhaPed,{ "C6_LOTECTL",	SC6->C6_LOTECTL      			,NIL })
						Aadd(aLinhaPed,{ "C6_ENTREG",	SC6->C6_ENTREG					,NIL })
						Aadd(aLinhaPed,{ "C6_CLASFIS",	SC6->C6_CLASFIS					,NIL })
						If SC6->(FieldPos("C6_NLOTE")) > 0
							Aadd(aLinhaPed,{ "C6_NLOTE",	SC6->C6_NLOTE			 	   	,NIL })
						EndIf
						If SC6->(FieldPos("C6_VDMOST")) > 0
							Aadd(aLinhaPed,{ "C6_VDMOST",	 SC6->C6_VDMOST				,NIL })
						EndIf
						If SC6->(FieldPos("C6_VDOBS")) > 0
							Aadd(aLinhaPed,{ "C6_VDOBS",	 SC6->C6_VDOBS				,NIL })
						EndIf
						If SC6->(FieldPos("C6_TURNO")) > 0
							Aadd(aLinhaPed,{ "C6_TURNO",	SC6->C6_TURNO					,NIL })
						EndIf
						If SC6->(FieldPos("C6_ITEMGAR")) > 0
							Aadd(aLinhaPed,{ "C6_ITEMGAR",	SC6->C6_ITEMGAR				,NIL })
						EndIf
						If SC6->(FieldPos("C6_ORCGAR")) > 0
							Aadd(aLinhaPed,{ "C6_ORCGAR",	SC6->C6_ORCGAR				,NIL })
						EndIf
						If SC6->(FieldPos("C6_FCICOD")) > 0
							Aadd(aLinhaPed,{ "C6_FCICOD",	SC6->C6_FCICOD				,NIL })
						EndIf
						If SC6->(FieldPos("C6_VLIMPOR")) > 0
							Aadd(aLinhaPed,{ "C6_VLIMPOR",	SC6->C6_VLIMPOR				,NIL })
						EndIf

						Aadd(aItensPed, aLinhaPed)

						SC6->( DbSkip() )

					EndDo

					For nI := 1 To Len(aItensPed)
						RecLock("SC6",.T.)
						For nY := 1 to Len(aItensPed[nI])
							If  (FieldPos(aItensPed[nI][nY][1]) > 0)
								SC6->( FieldPut(FieldPos(aItensPed[nI][nY][1]), aItensPed[nI][nY][2]) )
							EndIf
				 		Next nY
				 		SC6->(MsUnlock())
					   	FkCommit() // Commit para integridade referencial do SC6

		   	        	RecLock("SC6",.F.)
		   	        	MaAvalSC6("SC6",1,"SC5",lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk,,,,,,lTLVReg)
						SC6->(MsUnlock())

				   	Next nI

				EndIf

				MaAvalSC5("SC5",1,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk)
				SC5->(MsUnlock())

			EndIf

		EndIf

		cFilAnt := cFilBkp

	Next nContPed

EndIf

cFilAnt := cFilBkp

RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)

Return

//------------------------
/*/{Protheus.doc} Lj701CNFCe
Efetua a transmissão da NFC-e para o TSS (TSS->Sefaz).
@Type Function
@param   cCodFil	, caracter , Filial da venda realizada
@param   cNumOrc	, caracter , Numero do orçamento
@param   cDoc		, caracter , Numero do documento Nfc-e
@param   cSerie		, caracter , Serie do documento Nfc-e
@param   cPDV		, caracter , Pdv da venda
@param   lTefOk		, lógico , Operação TEF
@param   cKeyNFCe	, caracter , Chave de acesso NFc-e TSS
@author  Varejo
@version P11
@since   07/01/2015
@return  lNFCeRet	, lógico , .T. = Sucesso na transmissão / .F. = Erro na transmissão da NFC-e
/*/
//------------------------
Static Function Lj701CNFCe(	cCodFil, cNumOrc, cDoc, cSerie,	cPDV, lTefOk, cKeyNFCe, cMsgErro )

Local nNFCeRet	:= 0
Local lNFCeRet	:= .T.
Local lLjGrvOn  := SuperGetMV("MV_LJGRVON", Nil, .T.)
Local aNfceSL1	:= {}
Local lAutoExC	:= IsBlind()	// Verifica se a rotina sera executada via execauto ou nao

Default cCodFil	:= ""
Default cNumOrc	:= ""
Default cDoc	:= ""
Default cSerie	:= ""
Default cPDV	:= ""
Default lTEFOk	:= .T.
Default cKeyNFCe:= ""
Default cMsgErro:= ""

//Processa a NFC-e
nNFCeRet := LjNFCeGera(cCodFil, cNumOrc, @cKeyNFCe, Nil, Nil, @cMsgErro)

LjGrvLog(cNumOrc,"Retorno do envio da transmissao da NFC-e ",nNFCeRet)
LjGrvLog(cNumOrc,"Chave gerada na transmissao da NFC-e ",cKeyNFCe)

aNFCeSL1 := { {"L1_KEYNFCE" , cKeyNfce	} }
Lj7GeraSL("SL1", aNfceSL1, .F.)

/*
Situacoes nNFCeRet:
( 1 ) > NFC-e processada com sucesso
( 0 ) >	NFC-e enviada para o TSS, porem nao houve resposta do TSS (TSS offline)
(-1 ) > NFC-e rejeitada
*/

If nNFCeRet <> 1

	lNFCeRet := .F.

	If !lAutoExC
		Aviso(STR0147,STR0196,,,,,,,30000)//"Atenção"//"Houve problema na transmissão da NFC-e. Por favor, efetuar as devidas alterações ou gravar este como orçamento." 
	Else
		ConOut(STR0196 + "(Orc: " + SL1->L1_NUM + " - Doc.: " + cDoc + ")") //"Houve problema na transmissão da NFC-e. Por favor, efetuar as devidas alterações ou gravar este como orçamento."
	EndIf

	LjGrvLog(cNumOrc,"NFCe ERRO :",cMsgErro)

ElseIf !lLjGrvOn .AND. nNccUsada > 0 .And. !IsInCallStack("Lj7Pedido")

	// A função LjBaixaNCC devera ser executada quando o sistema estiver configurado para emissao da NFC-e
	// Pois nesse caso, o sistema nao efetua a venda de forma sincrona, sendo assim, quando se paga uma venda com
	// uma NCC, a baixa da mesma deve ser realizada, antes do processamento da venda que eh realizado pelo LjGrvBatch

	//Efetua a baixa da(s) NCC(s) utilizada(s) na venda e gera nova NCC se necessário.
	LjBaixaNCC()
EndIf

//limpa o objeto oNFCe que é instanciado no LOJNFCE.PRW
LjNFCeFree()

Return lNFCeRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7LocTribºAutor  ³Vendas Clientes     º Data ³ 01/07/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recalculo dos valores totais para atualizacao do orcamento  º±±
±±º          ³e rateio dos itens   (Localizado)                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA (Localizado)                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj7LocTrib( aTaxJuros )
Local nPos         	:= 0
Local aSL1 			:= {}					// Array para gravar as informacoes no SL1
Local nI 			:= 0
Local lMvLjJurCc	:= .F.					// Verifica se o juros da administradora esta ativo
Local nNFTOTAL 		:= 0
Local nVlrFSD		:= 0					// Valor do frete + seguro + despesas
Local nitem 		:= 0

//Valida se pode usa Taxa Administrativa por Cartão de Crédito
If SuperGetMv("MV_LJJURCC",NIL,.F.) .AND. (aTaxJuros[1] > 0)
	lMvLjJurCc := .T.
EndIf

If MaFisFound("NF") .And. lMvLjJurCc
	nVlrFSD	:= Lj7CalcFrete()

	//Atuualiza campos da tabela SL2
	DbSelectArea("SL2")
	SL2->( DbSetOrder(1) )
	SL2->( DbSeek(xFilial("SL2") + SL1->L1_NUM) )
	While !SL2->(Eof()) .AND. xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM
		nItem++
		RecLock("SL2", .F.)

		If MaFisFound("IT", nItem)
			REPLACE L2_VALFRE  WITH MaFisRet(nItem,"IT_FRETE")
			REPLACE L2_SEGURO  WITH MaFisRet(nItem,"IT_SEGURO")
			REPLACE L2_DESPESA WITH MaFisRet(nItem,"IT_DESPESA")
			REPLACE L2_CF 	   With MaFisRet(nItem,"IT_CF")
			REPLACE L2_VLRITEM WITH MaFisRet(nItem, "IT_VALMERC") - MaFisRet(nItem, "IT_DESCONTO")
			REPLACE L2_VRUNIT  WITH NoRound( SL2->L2_VLRITEM / MaFisRet(nItem, "IT_QUANT") , TamSX3("D2_PRCVEN")[2] )
			REPLACE L2_VALACRS WITH MaFisRet(nItem,"IT_ACRESCI")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao dos campos do SL2 com o calculo dos impostos retornados   ³
		//³ pela MATXFIS                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    For nI := 1 To Len(aImpsSL2[nItem][3])
	    	If aImpsSL2[nItem][3][nI][4] > 0 .AND. aImpsSL2[nItem][3][nI][3] > 0
	        	REPLACE &(aImpsSL2[nItem][3][nI][6]) WITH aImpsSL2[nItem][3][nI][4]   //Valor do imposto
	     		REPLACE &(aImpsSL2[nItem][3][nI][7]) WITH aImpsSL2[nItem][3][nI][3]   //Base do imposto
				REPLACE &("L2_ALQIMP"+Substr(aImpsSL2[nItem][3][nI][7],10,1)) WITH MaFisRet(nItem,"IT_ALIQIV"+Substr(aImpsSL2[nItem][3][nI][7],10,1))
			EndIf
		Next nI

		SL2->( MsUnlock() )
		SL2->(DbSkip())
	End

	DbSelectArea( "SL1" )
	nNFTOTAL := MaFisRet(,"NF_TOTAL")
	aSL1 := {}
	aAdd( aSL1, { "L1_VLRTOT"	, A410Arred( ( nNFTOTAL - nVlrFSD ), "L1_VALIMP1",nMoedaCor) } )
	aAdd( aSL1, { "L1_VALBRUT"	, A410Arred( ( nNFTOTAL - nVlrFSD ), "L1_VALIMP1",nMoedaCor) } )
	aAdd( aSL1, { "L1_VLRLIQ"	, nNFTOTAL } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe os campos de base e valor de impostos	se nao tem carregado na array aSL1 incluir zerado para nao  ³
	//³ficar sujeira quando eh modificado um orçamento ja gravado                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To 9
		cValImpCam := "L1_VALIMP" + StrZero(nI,1)
		cBasImpCam := "L1_BASIMP" + StrZero(nI,1)
		If SL1->( ColumnPos( cValImpCam ) ) > 0 .AND. SL1->( ColumnPos( cBasImpCam ) ) > 0
			If Ascan(aSL1,{|x| AllTrim(x[1]) == cValImpCam}) == 0 .AND. Ascan(aSL1,{|x| AllTrim(x[1]) == cBasImpCam}) == 0
				Aadd(aSL1,{cValImpCam,0})   //Valor do imposto
				Aadd(aSL1,{cBasImpCam,0})   //Base de imposto
			EndIf
		EndIf
	Next nI

	Lj7GeraSl( "SL1", aSL1, .F., .F. )

	aSL1 := {}

	//Atualiza o valor e base dos campos de impostos (L1_VALIMP1, L1_VALIMP2, L1_VALIMP3,...L1_BASIMP1, L1_BASIMP2, L1_BASIMP2,...)
    For nI := 1 To Len(aImpsSL1)
    	If aImpsSL1[nI][3] > 0 .AND. aImpsSL1[nI][5] > 0

    		//Valor do imposto
    		nPos := Ascan(aSL1,{|x| Trim(x[1]) == aImpsSL1[nI][2]})
			If nPos > 0
				aSL1[nPos][2] += aImpsSL1[nI][3]
			Else
				Aadd(aSL1,{aImpsSL1[nI][2],aImpsSL1[nI][3]})
			EndIf

    		//Base do imposto
    		nPos := Ascan(aSL1,{|x| Trim(x[1]) == aImpsSL1[nI][4]})
			If nPos > 0
				aSL1[nPos][2] += aImpsSL1[nI][5]
			Else
				Aadd(aSL1,{aImpsSL1[nI][4],aImpsSL1[nI][5]})
			EndIf
		EndIf
	Next nI

	Lj7GeraSl( "SL1", aSL1, .F., .F. )

EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjVlNumDocºAutor  ³ VArejo             º Data ³ 15/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida numero do documento digitado.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA (Localizacao Argentina)                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjVlNumDoc(cNumDoc)
Local lRet 		:= .T.
Local cDigValid := "0123456789" //Digitos validos
Local nX 		:= 0

cNumDoc := AllTrim(cNumDoc)

If !Empty(cNumDoc)
	For nX:=1 to Len(cNumDoc)
		If !(SubStr(cNumDoc,nX,1) $ cDigValid)
			lRet := .F.
			MsgAlert(STR0184) //"Informe apenas valores numéricos"
			Exit
		EndIf
	Next nX
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjTelaCardºAutor  ³ Varejo             º Data ³ 15/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aplica o acrescimo do cartao de credito nas referencias da º±±
±±º          ³ MatxFis e efetua os recalculos para saber o valor Total da º±±
±±º          ³ venda e exibe a tela com os valores a serem cobrados no(s) º±±
±±º          ³ cartoes.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA (Localizacao)                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjTelaCard(	aTaxJuros	, aPgtosBKP	, aPgSintBKP, nTotParBkp	,;
 							nSubTotBkp	, nTotalBkp	, aDadosCF	, cTipoCli		,;
 							nSaveSx8	)
Local lRet 		:= .T.
Local aColunas	:= { {STR0185,STR0186,STR0187,STR0188,STR0189,STR0190},{30,100,40,40,25,30} } //"ID Cartão"###"Administradora"###"Forma de Pagamento"###"Data"###"Parcelas"###"Valor"
Local oDlg    	:= Nil
Local oBrowse 	:= Nil
Local aItCartoes:= {}
Local lTelaOK   := .F.
Local nitem 	:= 1
Local n_ValTotal:= 0
Local n_VlrTxJur:= 0
Local nProp 	:= 0
Local nAcrecProp:= 0
Local nX 		:= 0
Local nPos 		:= 0
Local nValImpSum:= 0 //Valor de imposto a ser somado nos cartoes
Local nTotVenda := 0
Local nProporc 	:= 0
Local nVlrProp 	:= 0
Local nQtdParc 	:= 0
Local nTotCdCc  := 0
Local aPosPgtos := {}
Local nAuxSumTot:= 0
Local nAuxSumPar:= 0
Local nVlrDif 	:= 0
Local aTaxJurBkp:= aClone(aTaxJuros)
Local n_TotalBkp:= 0
Local nDiffTotal:= 0
Local nVlCardAux:= 0
Local nRefValor := 0

//Faz Backup dos valores antes de altera-los
MaFisSave() //Faz backup da MatxFis, antes de alterar seus valores de referencia

nRefValor	:= MaFisRet(  , "NF_VALMERC" )
n_ValTotal	:= nRefValor - MaFisRet(  , "NF_DESCONTO" )
n_VlrTxJur	:= aTaxJuros[2] //insere os juros: (Juros * Valor imposto) + Valor Imposto

MaFisLoad( "NF_ACRESCI", n_VlrTxJur, Nil) //Alimenta essa referencia na MatxFis para que depois esse valor de acrescimo seja utilizado no fonte LOJXFUNC para gravar o campo F2_VALACRS

//Loop para incluir o acrescimo da taxa do cartao e recalcular os IMPOSTOS
While MaFisFound("IT",nItem)
	//Calcula o Acrescimo Proporcional
	nX := MaFisRet( nItem, "IT_DESCONTO" )
	nProp := (nRefValor - nX) / n_ValTotal
	nAcrecProp := n_VlrTxJur * nProp
	
	If nX > 0
		If nX > nAcrecProp
			nX := nX - nAcrecProp
			nAcrecProp := 0
		Else
			nAcrecProp := nAcrecProp - nX
			nX := 0
		EndIf
		MaFisAlt( "IT_DESCONTO", nX, nItem)
	EndIf
	
	MaFisAlt( "IT_ACRESCI", nAcrecProp, nItem)

	nItem++
End

MaFisReprocess(2)
n_TotalBkp := Lj7T_Total(2) + nNCCUsada //Guarda backup do total da venda para verifica se o mesmo sera modificado apos os recalculos executados no Laco abaixo pela funcao "Lj7RecalImp"

//Acerta os valores Totias (Cabecalho) da MatxFis
nX:= 1
While MaFisFound("IT",nX)
	If !MaFisRet( nX, "IT_DELETED" )
		MaFisEndLoad(nX,1)
	EndIf
	nX++
End
StaticCall( MATXFIS, MaIt2cab )

nX := 1
//Loop para incluir o acrescimo da taxa do cartao e recalcular os IMPOSTOS
While MaFisFound("IT",nX)
	//Recalcula os impostos variaveis (Localizacoes), atualiza array "aTotImpsV"
	Lj7RecalImp(nX,1,,,,,,.T.,,.T.)
	nX++
End

//Verifica se o Total da Venda foi ajustado devido arredondamentos executados no Laco anterior que chama a funcao Lj7RecalImp para todos os itens
If ( nDiffTotal := (n_TotalBkp - Lj7T_Total(2)) ) <> 0

	nAuxSumTot := 0

	//Ajusta valores de pagamento
	For nX:=1 To Len(aPgtosSint)
		If AllTrim(aPgtosSint[nX][1]) $ _FORMATEF
			aPosPgtos := {}

			nQtdParc := aPgtosSint[nX][2]

			nAuxSumTot += nDiffTotal

			//Atualiza o array aPgtosSint
			aPgtosSint[nX][6][1] -= nDiffTotal
			aPgtosSint[nX][3] := TransForm( aPgtosSint[nX][6][1], PesqPict("SL4","L4_VALOR") )

			nVlrParc := NoRound( nDiffTotal / nQtdParc, 2 ) //Calcula o valor a ser somado nas parcelas do cartao

			nAuxSumPar := 0
			nPos := 1

			//Atualiza o array aPgtos
			While ( nPos := Ascan(aPgtos, {|x| AllTrim(x[3])+AllTrim(x[8]) == AllTrim(aPgtosSint[nX][1])+AllTrim(aPgtosSint[nX][4])}, nPos ) ) > 0
				aPgtos[nPos][4] := aClone( aPgtosSint[nX][6] )
				aPgtos[nPos][2] -= nVlrParc
				nAuxSumPar += nVlrParc
				aAdd( aPosPgtos, nPos )
				nPos++
			End

			//Verifica se ficou algum residuo, soma na ultima parcela
			If nAuxSumPar <> nDiffTotal
				nVlrDif := nDiffTotal - nAuxSumPar
				nPos := aPosPgtos[Len(aPosPgtos)]
				aPgtos[nPos][2] -= nVlrDif
				nAuxSumTot += nVlrDif
			EndIf

			Exit
		EndIf
	Next nX

	Lj7T_TotPar(2, Lj7T_TotPar(2)-nDiffTotal ) //Atualiza o Total das parcelas da Venda

	//Atualiza informacoes na tela
	oPgtos:SetArray( aPgtos )
	oPgtosSint:SetArray( aPgtosSint )
	oPgtosSint:Refresh()
	oPgtos:Refresh()

	aTaxJuros[2] := aTaxJuros[2] - nDiffTotal
EndIf

//Atualiza os arrays "aImpsSL1" e "aImpsSL2" utilizados na gravacao dos impostos
Lj7PrepGrvImp()

If n_VlrTxJur > 0
	Lj7T_Subtotal(2, ( Lj7T_Total(2) - n_VlrTxJur) )
EndIf

//---------------------------------------------------------
// Faz os ajustes dos valores pagos em cartao (CD e CC)
//---------------------------------------------------------
If nValImpSum > 0 //Se existir novo valor adicional de imposto, faz o rateio deste valor

	nTotVenda := Lj7T_Total(2)
	AEval( aPgtosSint, { |x| If(AllTrim(x[1]) $ _FORMATEF, nTotCdCc+= x[6][1] , Nil) } ) //Total pago com CD e CC
	nAuxSumTot := 0

	//Rateia o valor do imposto adicional calculado devido atingir o valor minimo para calculo de determinado imposto
	//Rateia apenas para a forma de pagamento CD e CC
	For nX:=1 To Len(aPgtosSint)
		If AllTrim(aPgtosSint[nX][1]) $ _FORMATEF
			nPosSint := nX
			aPosPgtos := {}

			nQtdParc := aPgtosSint[nX][2]
			nProporc := aPgtosSint[nX][6][1] / nTotCdCc //Calcula a proporcionalidade do cartao
			nVlrProp := NoRound(nValImpSum * nProporc, 2) //Valor proporcional calculado, a ser somado no cartao

			nAuxSumTot += nVlrProp

			//Atualiza o array aPgtosSint
			aPgtosSint[nX][6][1] += nVlrProp
			aPgtosSint[nX][3] := TransForm( aPgtosSint[nX][6][1], PesqPict("SL4","L4_VALOR") )

			nVlrParc := NoRound( nVlrProp / nQtdParc, 2 ) //Calcula o valor a ser somado nas parcelas do cartao

			nAuxSumPar := 0
			nPos := 1

			//Atualiza o array aPgtos
			While ( nPos := Ascan(aPgtos, {|x| AllTrim(x[3])+AllTrim(x[8]) == AllTrim(aPgtosSint[nX][1])+AllTrim(aPgtosSint[nX][4])}, nPos ) ) > 0
				aPgtos[nPos][4] := aClone( aPgtosSint[nX][6] )
				aPgtos[nPos][2] += nVlrParc
				nAuxSumPar += nVlrParc
				aAdd( aPosPgtos, nPos )
				nPos++
			End

			//Verifica se ficou algum residuo, soma na ultima parcela
			If nAuxSumPar <> nVlrProp
				nVlrDif := nVlrProp - nAuxSumPar
				nPos := aPosPgtos[Len(aPosPgtos)]
				aPgtos[nPos][2] += nVlrDif
				nAuxSumTot += nVlrDif
			EndIf
		EndIf
	Next nX

	//Verifica se ainda ficou algum residuo, soma no ultimo cartao
	If nAuxSumTot <> nValImpSum
		nX--
		nVlrDif := nValImpSum - nAuxSumTot

		//Atualiza o array aPgtosSint
		aPgtosSint[nPosSint][6][1] += nVlrDif
		aPgtosSint[nPosSint][3] := TransForm( aPgtosSint[nX][6][1], PesqPict("SL4","L4_VALOR") )

		//Atualiza o array aPgtos
		nPos := aPosPgtos[Len(aPosPgtos)]
		aPgtos[nPos][4] := aClone( aPgtosSint[nPosSint][6] )
		aPgtos[nPos][2] += nVlrDif

		nAuxSumTot += nVlrDif
	EndIf

	Lj7T_TotPar(2, Lj7T_TotPar(2)+nValImpSum ) //Atualiza o Total das parcelas da Venda

	//Atualiza informacoes na tela
	oPgtos:SetArray( aPgtos )
	oPgtosSint:SetArray( aPgtosSint )
	oPgtosSint:Refresh()
	oPgtos:Refresh()


	aTaxJuros[2] := aTaxJuros[2] + nValImpSum

EndIf

//Monta vetor com elementos do Browse
For nX:=1 To Len(aPgtosSint)
	If AllTrim(aPgtosSint[nX][1]) $ _FORMATEF
		nVlCardAux := If( ValType(aPgtosSint[nX][6][1]) == "C", Val(Replace(aPgtosSint[nX][6][1],",",".")) , aPgtosSint[nX][6][1] )
		aAdd( aItCartoes, { 	aPgtosSint[nX][4],;			//01 - ID Cartao
							 	aPgtosSint[nX][6][5],;		//02 - Administradora
							 	aPgtosSint[nX][1],;			//03 - Forma de Pagamento
							 	aPgtosSint[nX][5],;			//04 - Data
							 	aPgtosSint[nX][6][3],;		//05 - Parcelas
							 	nVlCardAux } )				//06 - Valor
	EndIf
Next nX

DEFINE DIALOG oDlg TITLE STR0191 FROM 180,180 TO 500,800 PIXEL //"Cartão de débito e crédito"

@ 05, 05 SAY STR0192 SIZE 100, 7 OF oDlg PIXEL //"Relação de valores pagos com cartão"

oBrowse := TCBrowse():New( 15 , 05, 300, 130,,aColunas[1],aColunas[2],oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
oBrowse:SetArray(aItCartoes)
oBrowse:bLine := {||{ aItCartoes[oBrowse:nAt,01],;
                       aItCartoes[oBrowse:nAt,02],;
                       aItCartoes[oBrowse:nAt,03],;
                       aItCartoes[oBrowse:nAt,04],;
                       aItCartoes[oBrowse:nAt,05],;
                       Transform(aItCartoes[oBrowse:nAT,06],'@E 99,999,999,999.99') } }

DEFINE SBUTTON oBtnOK     FROM 150, 005 TYPE 1 ACTION (lTelaOK := .T.,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON oBtnCancel FROM 150, 050 TYPE 2 ACTION (lTelaOK := .F.,oDlg:End()) ENABLE OF oDlg

oDlg:LESCCLOSE := .F. //Desabilita a tecla ESC

ACTIVATE DIALOG oDlg CENTERED

If lTelaOK .And. cPaisLoc == "ARG"
	If cTipoCli == "F" .And. Lj7T_Total(2) >= SuperGetMV("MV_LIMCFIS") .And. !aDadosCF[7]
		//Exibe a tela para indicar o tipo e numero de documento quando consumidor final e
		//venda maior que o determinado no parametro MV_LIMCFIS.
		lTelaOK := LjGetDocCF(@aDadosCF,nSaveSx8)
	EndIf
EndIf

If !lTelaOK
	//Restaura os valores originais, quando o usuario clicar no botao "Cancelar"
	//Caso a tela seja cancelada, sao retornado os valores anteriores da MatxFis
	MaFisRestore() //Retorna o backup da MatxFis, antes de alterar seus valores de referencia

	nItem := 1
	//Loop para incluir o acrescimo da taxa do cartao e recalcular os IMPOSTOS
	While MaFisFound("IT",nItem)
		//Recalcula os impostos variaveis (Localizacoes), atualiza array "aTotImpsV"
		Lj7RecalImp(nItem,1,,,,,,.T.,,.T.)
		nItem++
	End

	//Atualiza os arrays "aImpsSL1" e "aImpsSL2" utilizados na gravacao dos impostos
	Lj7PrepGrvImp()

	//Retorna o backup dos arrays "aPgtos" e "aPgtosSint"
	aPgtos 		:= aClone(aPgtosBKP)
	aPgtosSint	:= aClone(aPgSintBKP)
	oPgtos:SetArray( aPgtos )
	oPgtosSint:SetArray( aPgtosSint )
	oPgtosSint:Refresh()
	oPgtos:Refresh()

	//Restaura os Totais da Venda
	Lj7T_TotPar(2, nTotParBkp) //Retorna o backup do Total das parcelas da Venda
	Lj7T_Subtotal(2, nSubTotBkp) //Retorna o backup do SubTotal da Venda
	Lj7T_Total(2, nTotalBkp) //Retorna o backup do Total da Venda

	aTaxJuros := aClone(aTaxJurBkp)

	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGetDocCFºAutor  ³ Varejo             º Data ³ 15/01/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a tela para indicar o tipo e numero de documento     º±±
±±º          ³ quando consumidor final e venda maior que o determinado no º±±
±±º          ³ parametro MV_LIMCFIS.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA (Localizacao Argentina)                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjGetDocCF(aDadosCF,nSaveSx8)
Local lRet 		:= .T.
Local cMay		:= "" // Codigo que sera utilizado para a gravacao do endereco do Consumidor Final
Local aAreaMAD	:= {} // Salva area do MAD
Local nTent		:= 0  // Numero de tentativas, para gerar numero sequencial

//Exibe a tela para indicar o tipo e numero de documento quando consumidor final e
//venda maior que o determinado no parametro MV_LIMCFIS.
If !Lj7DocsCF(@aDadosCF)
	lRet := .F.
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera o codigo que sera utilizado para a gravacao do endereco do consumidor final³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMay := Alltrim( xFilial("MAD") ) + aDadosCF[5]
	FreeUsedCode()

	DbSelectArea("MAD")
	aAreaMAD := GetArea()
	DbSetOrder(1)

	While DbSeek( xFilial("MAD") + aDadosCF[5] ) .OR. !MayIUseCode( cMay )
		If ++nTent > 20
			MsgStop(STR0035) //"Nao foi possivel gerar numero sequencial de endereco corretamente."
			lRet := .F.
			Exit
		EndIf

		While (GetSX8Len() > nSaveSx8)
			ConfirmSx8()
		End
		aDadosCF[5] := GetSxeNum("MAD","MAD_CODEND")
		FreeUsedCode()
		cMay := Alltrim( xFilial("MAD") ) + aDadosCF[5]
	End
	RestArea(aAreaMAD)
	If lRet
		aDadosCF[7] := .T.
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} LjRlBckDBF
Restaura os registros de um determinado Alias, de forma similar a um Rollback,
porém é necessário fazer a cópia dos registros através da função LjBkpReg.
Essa função substitui o DisarmTransaction(), pois em DBF não há controle de Transação.
@param	 aDados
@author  Varejo
@version P11
@since   25/04/2015
/*/
Static Function LjRlBckDBF(aDados)

Local nTotReg	:= 0	//total de registros que serao restaurados
Local nReg		:= 0	//contador de registro
Local nTotCampo	:= 0	//total de campos de cada registro
Local nCampo	:= 0	//contador de campo
Local nTotAlias	:= 0	//total de tabelas que serão restauradas
Local nAlias	:= 0	//contador de tabelas
Local cAlias 	:= ""	//Alias da tabela
Local aArea		:= {}

Default	aDados	:= {}

/*
ESTRUTURA DO ARRAY aDados
[][1] ALIAS DA TABELA
[][2][]	- ARRAY DE REGISTROS (valores e R_E_C_N_O_)
[][2][][1][] - ARRAY DE VALORES DE CADA CAMPO DO REGISTRO
[][2][][2] - R_E_C_N_O DO REGISTRO
*/

nTotAlias := Len(aDados)

For nAlias := 1 to nTotAlias
	cAlias := aDados[nAlias][1]	//indica o Alias que será restaurado

	aArea := (cAlias)->( GetArea() )		//armazena a area corrente da tabela que será restaurada

	nTotReg := Len( aDados[nAlias][2] )		//indica o total de registros que será restaurado

	For nReg := 1 to nTotReg

		nTotCampo := Len( aDados[nAlias][2][nReg][1] )		//indica o total de campos

		(cAlias)->( DbGoto(aDados[nAlias][2][nReg][2]) )	//posiciona no registro a ser restaurado atraves do R_E_C_N_O_
		RecLock(cAlias, .F.)
		For nCampo := 1 to nTotCampo
			(cAlias)->( FieldPut(nCampo, aDados[nAlias][2][nReg][1][nCampo]) )	//restaura o valor de cada campo
		Next
		(cAlias)->( MsUnlock() )

	Next

	RestArea(aArea)
Next

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma       ³CrdCpvFin ºAutor  ³Vendas Clientes     º Data ³  06/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.          ³ Executa a Impressao do Comprovante de Financiamento quando º±±
±±º               ³ a Retaguarda estiver inacessivel (AD Off-Line).            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso            ³Interfaces de Venda                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpAcrsAux()
Local aComprov 	    := {}                            			// Array com os dados a serem impressos no comprovante de recebimento
Local cNome			:= ""                            			// Nome do cliente a ser impresso
Local cTicket		:= ""                            			// Texto nao-fiscal enviado ao ECF
Local cMV_FORMCRD   := "FI"   									//Formas de pagamento que devem ter analise
Local nX			:= 0                             			// Controle de loop
Local aArea			:= GetArea()                     			// Area atual
Local nQtdParcel    := 0                             			// Quantidade de parcelas do recebimento
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)					// Verifica as filiais da trabalharam com acrescimento separado
Local nDiasPagto	:= 0										// Dias da condicao de pagamento
Local nValorL4 		:= 0										// Maior valor da parcela
Local nAcrsFin 		:= 0   										// % de acrescimo financeiro
Local nL4ValTot		:= 0										// Valor total financiado
Local cFormaPgto	:= Alltrim(SL1->L1_FORMPG)					// Forma de pagamento da venda
Local nRetECF		:= 0

// Verifica se o cadastro do cliente existe localmente na base de dados do Caixa
DbSelectArea("SA1")
If	DbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA)
	cNome := SA1->A1_NREDUZ
Endif

DbSelectArea("SL4")
DbSetOrder(1)
If	DbSeek(xFilial("SL4")+SL1->L1_NUM)
	While ! SL4->(Eof()) .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. SL1->L1_NUM == SL4->L4_NUM

		IF Alltrim(SL4->L4_FORMA) $ cMV_FORMCRD

			nQtdParcel ++
			cFormaPgto := SL4->L4_FORMA

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alteracao para enviar os parametros corretos para alteracao de comprovante   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA"))

				nL4ValTot += NoRound(SL4->L4_VALOR)
				nValorL4  += NoRound(SL4->L4_VALOR)
				nAcrsFin  += NoRound(SL4->L4_ACRSFIN)

		   		DbSelectArea("SE4")
		   		DbSetOrder(1)
		   		If DbSeek(xFilial("SE4") + SL1->L1_CONDPG)
	         		nDiasPagto	:= SE4->E4_LIMACRS
 	       		Endif
	   		Endif
		Endif

		SL4->(DbSkip())
	End

EndIf

If AllTrim(cFormaPgto ) == cMV_FORMCRD
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Confirguracao do comprovante de credito                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aComprov, "" )
	aAdd( aComprov, "" )
	aAdd( aComprov, "       C O M P R O V A N T E   D E  " )													//"       C O M P R O V A N T E   D E  "
	aAdd( aComprov, "        F I N A N C I A M E N T O 	" ) 													//"        F I N A N C I A M E N T O 	"
	aAdd( aComprov, "" )

	aAdd( aComprov, "" )
	aAdd( aComprov, "Data: " + Dtoc(SL1->L1_EMISSAO) + " Hora: " + IIF(!Empty(SL1->L1_HORA),SL1->L1_HORA,Time()) ) 		//"Data: "###" Hora: "
	aAdd( aComprov, "Estabel.: " + SM0->M0_CODIGO + "-" + FwCodFil() + "-" + Alltrim(SM0->M0_NOME) )	//"Estabel.: "
	aAdd( aComprov, "PDV:  " + Alltrim(SLG->LG_PDV) ) 					//"PDV:  "

	If !Empty(cNome)
		aAdd( aComprov, "Cliente : " + cNome ) 									//"Cliente : "
	Endif

	// Imprimir o CPF do cliente
	If !Empty(SL1->L1_CGCCART)
		If Len(ALLTRIM(SL1->L1_CGCCART)) <= 14
			aAdd( aComprov, "CPF     : "  + SL1->L1_CGCCART ) 					//"Cpf     : "
		Else
			// Imprimir o codigo do Cartao do cliente
			aAdd( aComprov, "Cartao  : " + SL1->L1_CGCCART ) 					//"Cartao  : "
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se trabalhar com o conceito de acrescimo separado, ³
	//³imprime comprovante de financiamneto               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nAcrsFin > 0
		nValorL4 := nValorL4 + nAcrsFin
	Endif

	aAdd( aComprov, "Forma Pgto.: " + Tabela("24",cFormaPgto,.F.) ) 		//"Parcelas: "
	If nDiasPagto == 0
		aAdd( aComprov, "            Para pagto a prazo de R$ " + Alltrim(Transform(nValorL4,PesqPict("SL2","L2_VLRITEM"))) )
		aAdd( aComprov, "            dividido em " + Alltrim(STR(nQtdParcel,0)) + " parcelas." )
	Else
		aAdd( aComprov, "            Pagto a vista em ate " + Alltrim(STR(nDiasPagto,0)) + " dias R$ " + Alltrim(Transform(nL4ValTot,PesqPict("SL1","L1_VLRTOT"))))
		aAdd( aComprov, "     ou em " + Alltrim(STR(nQtdParcel,0)) +  "parcelas de R$ " + Alltrim(Transform(nValorL4,PesqPict("SL2","L2_VLRITEM"))) )
	EndIf
	aAdd( aComprov, "" )
	aAdd( aComprov, "         Confirmo que pagarei " )													//"         Confirmo que pagarei "
	aAdd( aComprov, "          a importancia acima " )													//"          a importancia acima "
	aAdd( aComprov, "" )
	aAdd( aComprov, "" )
	aAdd( aComprov, "----------------------------------------" )
	aAdd( aComprov, "              Assinatura "  ) 													//"              Assinatura "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o comprovante nas linhas de valor total e parcelas com outro texto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aComprov, "" )
	aAdd( aComprov, Replicate( "=", 40 ) )

	For nX := 1 to Len(aComprov)
		 cTicket += aComprov[nX] + Chr(10)
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se não conseguir imprimir um cupom nao fiscal, manda um     ³
	//³Relatorio Gerencial para o ECF  (Alguns ECF, por exemplo a  ³
	//³Sweda, não permite que seja vinculado um cupom nao fiscal   ³
	//³a um outro cupom nao fiscal)                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRetECF := IFRelGer( nHdlECF, cTicket, 1 )
	If nRetECF <> 0
		// "Não foi possível imprimir o comprovante de financiamento. Verifique o ECF e solicite a re-impressão."
		MsgStop(STR0049)
	Endif
EndIf

RestArea( aArea )  //Restauro a area original

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjReAbreVA ºAutor  ³  Varejo            º Data ³  20/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Controla se abre a tela do Venda Assistida automaticamente  º±±
±±º          ³ para uma nova venda apos finalizar um atendimento.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nTipo - 1-Salvar como orcamento                              º±±
±±º          ³        2-Salvar como venda                                  º±±
±±º          ³        3-Salvar como pedido                                 º±±
±±º          ³nOpc  - nOpc da rotina (3-Atendimento; 4-Finaliza venda)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. Abre a tela automaticamente para uma nova venda.        º±±
±±º          ³ .F. Nao abre a tela automaticamente para uma nova venda.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - Venda Assistida                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjReAbreVA(nTipo, nOpc)
Local lReabreTela := .T.

If ExistBlock("LJ701Mbr")
	lReabreTela := ExecBlock( "LJ701Mbr", .F., .F., {nTipo, nOpc} )
Else
	//Por padrao somente reabre a tela para realizar uma nova venda quando for Atendimento.
	//Qdo. for Finalizacao de Venda, nao reabre a tela automaicamente.
	lReabreTela := If(nOpc==3,.T.,.F.)
EndIf

MBrChgLoop(lReabreTela)

Return

//---------------------------------------------------------------
/*/{Protheus.doc} LJDOCSAIDA
Funcao TEMPORARIA que exibe a pergunta "Cupom ou Nota" na 
finalizacao da venda, e se nota for selecionada, 
ela verifica se o sistema esta configurado para emissao.
@type function
@author  Varejo
@version P12.1.14
@since   20/01/2017
@return aRet - [1]tipo do documento [2]se permite emissao de NF
/*/
//---------------------------------------------------------------
Static Function LJDocSaida()

Local nDocSai	:= 1	//1-Cupom Fiscal 2-Nota Fiscal 3-Cancela
Local lEmiteNF	:= .F.	//Indica se é permitido emissao de Nota Fiscal
//As variáveis lEmitNfce - alimentada pela rotina LjEmitNFCe, lFtvdVer12 - alimentada pela rotina - LjFTVD() e cNomeProg - alimentada pela variável  lFtvdVer12  tiveram seu escopo alterado para variáveis locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV e essas variáveis mudam o seu valor conforme o módulo
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local aRet		:= {}	//[1]-Documento de Saida selecionado [2]-Se permitido emitir Nota Fiscal
Local lEmisNF	:= ( LjEmiteNF(SM0->M0_CGC, .F.) .OR. lFtvdVer12 )	// Verifica se a empresa se enquadra na LjEmiteNF


//se Usuario Nao Fiscal, ja atribui o doc de saida como Nota Fiscal
If lFiscal
	nDocSai := Aviso( STR0053, STR0054, {STR0055, STR0056, STR0058} )
	//"Documento Fiscal de Saida"##"Qual Documento Fiscal de Saida sera impresso na venda?"##"Cupom"##"Nota"##"Cancela"
Else
	If lEmisNF
		nDocSai := 2
	Else
		nDocSai := 1
		lEmiteNF := .F.
	EndIf
EndIf

//se o usuario selecionou Nota Fiscal, verifica se o sistema esta configurado para permitir sua emissao
If nDocSai = 2
	lEmiteNF := LjNFFimVd(	.T. /*lCria*/	, .F. /*lEmiteCF*/	, .T. /*lFinaliza*/ , /*cA1Est*/,;
							/*cA1Pessoa*/	, /*nRefLJ7087*/	, /*lLJ7087*/		, nDocSai	)
EndIf

Aadd( aRet, nDocSai)
Aadd( aRet, lEmiteNF)

Return aRet

//------------------------------------------------
/*/{Protheus.doc} lj7ImpGe
Função responsavel por alimentar as variaveis do item de garantia e o item garantido,  impressão do Termo de garantia e imprimir o relatorio não fiscal da venda com garantia
@type Static Function
@author  Lucas Novais
@version P12.1.17
@since   08/06/2018
@return	 
/*/
//------------------------------------------------
Static Function Lj7ImpGe(nVlrGar,nFatorGar,aProdGar,nValRes,nFatorVen,nFatorRes,lImpReserva,lMvLjImpGf,cMvLjTGar,lVAssConc,lEmiteNF)

Local nTmVlrItem	:= GetSX3Cache("L2_VLRITEM", "X3_TAMANHO")  //Variavel que armazena o tamanho do campo L2_VLRITEM
Local cVlrItem := ""											//Armazena o Valor a ser impresso no termo de garantia 
Local lFiscal := .F.											//Indica se é o intem fiscal (Garantido), ou não fiscal (Garantia)

If Type("nDecimais") == "U"
	nDecimais := MsDecimais(1)
EndIf

nVlrGar 	:= 0
nFatorGar 	:= 0

DbSelectArea("SL2")
SL2->( DbSetOrder(1) )
SL2->( DbSeek(xFilial("SL2") + SL1->L1_NUM) )

// Procura os itens de Garantia, guarda os valores e add no array
While SL2->( !Eof() ) .AND. ( SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM ) .AND. !Empty(SL2->L2_ITEMGAR)
	
	If !Empty(SL2->L2_GARANT)
	 	lFiscal := .T. 
	ElseIf Posicione("SB1",1,xFilial("SB1")+SL2->L2_PRODUTO, "B1_TIPO") == cMvLjTGar
		nVlrGar += SL2->L2_VLRITEM
		AAdd( aProdGar,{SL2->L2_PRODUTO, SL2->L2_GARANT, SL2->L2_VLRITEM} )
	EndIf

	If lEmiteNF
		cVlrItem := Str( a410Arred(SL2->L2_VRUNIT * SL2->L2_QUANT, "L2_VLRITEM"), nTmVlrItem,nDecimais )
		LjNFCeGE( IIF(lFiscal, 1, 2), {SL2->L2_PRODUTO, SL2->L2_DESCRI, cVlrItem, SL2->L2_NSERIE, IIF(lFiscal,SL2->L2_GARANT,Nil)} )
	Endif 

	lFiscal := .F.
	SL2->( DbSkip() )
EndDo

// Caso tenha garantia, realiza o recalculo dos fatores de venda e reserva
If Len(aProdGar) > 0 .AND. lMvLjImpGf 

	If !lImpReserva

		nValRes 	+= nVlrGar
		nFatorGar 	:= Lj7FatRes(nVlrGar, SL1->L1_VLRLIQ + SL1->L1_DESCONT)[2]

		nFatorVen := Lj7FatRes(nValRes, SL1->L1_VLRLIQ + SL1->L1_DESCONT)[1]
		nFatorRes := Lj7FatRes(nValRes, SL1->L1_VLRLIQ + SL1->L1_DESCONT)[2]

		// nao chamara o comprovante nao fiscal aqui porque cancelara o cupom fiscal
		// iniciado na importacao do orcamento concomitante, primeiro terminara o cupom fiscal
		// e depois imprimira o comprovante nao fiscal
		If !lVAssConc .OR. lEmiteNF
			LjMsgRun( STR0013,, {|| Lj7ImpCNF( Nil, nFatorGar , Nil, 	Nil,;
											Nil  , Nil		 , 1   , aProdGar ) } )    //"Aguarde ... imprimindo o comprovante de venda ...."
		EndIf
	Else

		nFatorVen := Lj7FatRes(nVlrGar, SL1->L1_VLRLIQ + SL1->L1_DESCONT)[1]
		nFatorRes := Lj7FatRes(nVlrGar, SL1->L1_VLRLIQ + SL1->L1_DESCONT)[2]

	EndIf

EndIf

Return

//--------------------------------------------------------
/*/{Protheus.doc} LjSetOffLN()
Rotina para Set que verifica se o ambiente esta em off-line             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lAmbOff  verifica se o ambiente esta em off-line                                                                            
/*/
//--------------------------------------------------------
Function LjSetOffLN(lMvLJOFFLN)

lAmbOff :=  lMvLJOFFLN

Return lAmbOff

//--------------------------------------------------------
/*/{Protheus.doc} LjGetOffLN()
Rotina de Get que verifica se o ambiente esta em off-line             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lAmbOff  verifica se o ambiente esta em off-line                                                                            
/*/
//--------------------------------------------------------
Function LjGetOffLN()

Return lAmbOff

//--------------------------------------------------------
/*/{Protheus.doc} LjStBGtPaf()
Rotina para Set que verifica se é PDV PAF             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lMVLJPDVPA  verifica se é PDV PAF                                                                             
/*/
//--------------------------------------------------------
Function LjStBGtPaf(lxBGetPaf)

lMVLJPDVPA :=  lxBGetPaf

Return lMVLJPDVPA

//--------------------------------------------------------
/*/{Protheus.doc} LjGtBGtPaf()
Rotina de Get que verifica se é PDV PAF           
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lMVLJPDVPA  verifica se é PDV PAF                                                                             
/*/
//--------------------------------------------------------
Function LjGtBGtPaf()

Return lMVLJPDVPA

//--------------------------------------------------------
/*/{Protheus.doc} LjStCFolLoc()
Rotina para Set que verifica se habilita controle de Folio - Chile/Colômbia
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lCFolLocR5  verifica se habilita controle de Folio - Chile/Colômbia                                                                            
/*/
//--------------------------------------------------------
Function LjStCFolLoc(lCFolLoc)

lCFolLocR5 :=  lCFolLoc

Return lCFolLocR5

//--------------------------------------------------------
/*/{Protheus.doc} LjGtCFolLoc()
Rotina de Get que verifica se Habilita controle de Folio - Chile/Colômbia             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lCFolLocR5  verifica se habilita controle de Folio - Chile/Colômbia                                                                            
/*/
//--------------------------------------------------------
Function LjGtCFolLoc()

Return lCFolLocR5

//--------------------------------------------------------
/*/{Protheus.doc} LjStMVLJCSF()
Rotina para Set que valida se habilita o controle de servicos financeiros            
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lSFinanc  Valida se habilita o controle de servicos financeiros                                                                            
/*/
//--------------------------------------------------------
Function LjStMVLJCSF(lMVLJCSF)

lSFinanc :=  lMVLJCSF

Return lSFinanc

//--------------------------------------------------------
/*/{Protheus.doc} LjGtMVLJCSF()
Rotina de Get que Valida se habilita o controle de servicos financeiros             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lSFinanc  Valida se habilita o controle de servicos financeiros                                                                            
/*/
//--------------------------------------------------------
Function LjGtMVLJCSF()

Return lSFinanc

//--------------------------------------------------------
/*/{Protheus.doc} LjStPafNfce()
Rotina para Set que verifica se usa NFC-e com PAF
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lIsPafNfce  verifica se usa NFC-e com PAF                                                                            
/*/
//--------------------------------------------------------
Function LjStPafNfce(lPafNfce)

lIsPafNfce :=  lPafNfce

Return lIsPafNfce

//--------------------------------------------------------
/*/{Protheus.doc} LjGtPafNfce()
Rotina de Get que verifica se usa NFC-e com PAF             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lIsPafNfce  verifica se usa NFC-e com PAF                                                                           
/*/
//--------------------------------------------------------
Function LjGtPafNfce()

Return lIsPafNfce

//--------------------------------------------------------
/*/{Protheus.doc} LjStRtTlTef()
Rotina para Set que verifica o retorno da função Lj7Pedido é da tela do TEF, e assim não será mostrado ao usuário nenhum erro
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lTelaTefPed  verifica o retorno da função Lj7Pedido é da tela do TEF, e assim não será mostrado ao usuário nenhum erro
/*/
//--------------------------------------------------------
Function LjStRtTlTef(lRetTelTef)

lTelaTefPed :=  lRetTelTef

Return lTelaTefPed

//--------------------------------------------------------
/*/{Protheus.doc} LjGtRtTlTef()
Rotina de Get que verifica o retorno da função Lj7Pedido é da tela do TEF, e assim não será mostrado ao usuário nenhum erro             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  lTelaTefPed  o retorno da função Lj7Pedido é da tela do TEF, e assim não será mostrado ao usuário nenhum erro                                                                            
/*/
//--------------------------------------------------------
Function LjGtRtTlTef()

Return lTelaTefPed

//--------------------------------------------------------
/*/{Protheus.doc} LjStDelOrc()
Rotina para Set que guarda Orcamentos Filhos que devem ser excluidos             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  aOrcFilDel  guarda Orcamentos Filhos que devem ser excluidos             
/*/
//--------------------------------------------------------
Function LjStDelOrc(aDelOrcFil)
Default aDelOrcFil := {}

aOrcFilDel :=  aDelOrcFil

Return aOrcFilDel

//--------------------------------------------------------
/*/{Protheus.doc} LjGtDelOrc()
Rotina de Get que guarda Orcamentos Filhos que devem ser excluidos           
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  aOrcFilDel  guarda Orcamentos Filhos que devem ser excluidos                                                                          
/*/
//--------------------------------------------------------
Function LjGtDelOrc()

Return aOrcFilDel

//--------------------------------------------------------
/*/{Protheus.doc} LjStAdmTef()
Rotina para Set que Guarda a Adm. Financeira selecionada para cada cartao utilizado na venda             
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  aRetAdmTef  Guarda a Adm. Financeira selecionada para cada cartao utilizado na venda
/*/
//--------------------------------------------------------
Function LjStAdmTef(aAdmTef)
Default aAdmTef := {}

aRetAdmTef :=  aAdmTef

Return aRetAdmTef

//--------------------------------------------------------
/*/{Protheus.doc} LjGtAdmTef()
Rotina de Get que Guarda a Adm. Financeira selecionada para cada cartao utilizado na venda           
@author  santos.fabio
@version P12.1.17
@since   24/12/2019
@return  aRetAdmTef  Guarda a Adm. Financeira selecionada para cada cartao utilizado na venda                                                                          
/*/
//--------------------------------------------------------
Function LjGtAdmTef()

Return aRetAdmTef
