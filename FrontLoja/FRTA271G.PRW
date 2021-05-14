#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA271G.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FRTDEF.CH"

#DEFINE	 FRT_SEPARATOR		"---------------------------------------"

// Indices do Array aItens
// Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
#DEFINE AIT_ITEM			 	1
#DEFINE AIT_COD			    	2
#DEFINE AIT_CODBAR				3
#DEFINE AIT_DESCRI				4
#DEFINE AIT_QUANT				5
#DEFINE AIT_VRUNIT				6
#DEFINE AIT_VLRITEM				7
#DEFINE AIT_VALDESC		   		8
#DEFINE AIT_ALIQUOTA			9
#DEFINE AIT_VALIPI				10
#DEFINE AIT_CANCELADO			11
#DEFINE AIT_VALSOL   			12
#DEFINE AIT_DEDICMS   			13          // Deducao de ICMS
#DEFINE AIT_ITIMP   			14          		// Numero do item na Impressora
#DEFINE AIT_PBM		   			15          		// Define se o produto e PBM

#DEFINE _FORMATEF			   "CC;CD"     // Formas de pagamento que utilizam operação TEF para validação
#DEFINE CRLF                   Chr(13)+Chr(10)  //Pula linha

Static cGetCliDir      					// Guarda o caminho do rootPath
Static cProfStr1       					// Guarda o Retorno da Funcao GetPvProfString
Static lEmitNfce	:= ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe()			// Sinaliza se utiliza NFC-e
Static lMFE			:= IIF( ExistFunc("LjUsaMfe"), LjUsaMfe(), .F. )			//Se utiliza MFE
Static lLjRspFisc	:= ExistFunc("LjRspFisc")								//Comando da resposta fiscal MFe
Static lLjEnvPgto	:= ExistFunc("LjEnvPgto")								//Comando de enviar pagamento MFe
Static aIdPgtoMfe	:= {} 														//Array para armazenamento dos id's de pagamento enviados ao Integrador Fiscal MFe
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271GEnce³ Autor ³ Vendas Clientes       ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finalizacao da Venda (F9) (Total)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Total por forma de pagamento  					  ³±±
±±³          ³ ExpC2 - Forma de pagamento             					  ³±±
±±³          ³ ExpN3 - Valor juros financeiro       					  ³±±
±±³          ³ ExpL4 - Controla se encerra o Cupom    					  ³±±
±±³          ³ ExpN5 - Valor do desconto financeiro   					  ³±±
±±³          ³ ExpO6 - Objeto da tela de parcelas   					  ³±±
±±³          ³ ExpL7 - Controle se operacao TEF esta pendente   		  ³±±
±±³          ³ ExpA8 - Controle de multiplas transacoes TEF       	      ³±±
±±³          ³ ExpC9 - Numeracao do cartao fidelidade 	    			  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271GEncerra(	aFormPag	, cItemForma	, nTmpJuros		, lEncerra		,;
                       	nTmpDesc	, oFimVenda		, lTEFPendRec	, aRecTEFMult	,;
                       	cNCartao	, oHora			, cHora			, oDoc			,;
						cDoc		, oCupom		, cCupom		, nVlrPercIT	,;
						nLastTotal	, nVlrTotal		, nLastItem		, nTotItens		,;
						nVlrBruto	, oDesconto		, oTotItens		, oVlrTotal		,;
						oFotoProd	, nMoedaCor		, cSimbCor		, oTemp3		,;
						oTemp4		, oTemp5		, nTaxaMoeda	, oTaxaMoeda	,;
						nMoedaCor	, cMoeda		, oMoedaCor		, cCodProd		,;
						cProduto	, nTmpQuant		, nQuant		, cUnidade		,;
						nVlrUnit	, nVlrItem		, oProduto		, oQuant		,;
						oUnidade	, oVlrUnit		, oVlrItem		, lF7			,;
						oPgtos		, oPgtosSint	, cOrcam		, aPgtos		,;
						cPDV		, aPgtosSint	, lTefPendCS	, aTefBKPCS		,;
						nEntrada	, cCliente		, cLojaCli		, cVendLoja		,;
						lOcioso		, lRecebe		, lLocked		, lCXAberto		,;
						aTefDados	, nVlrFSD		, lDescIT		, nVlrDescTot	,;
						nValIPI		, aItens		, nVlrMerc		, aParcOrc		,;
						lAltVend	, lFechaCup		, aTpAdmsTmp	, cUsrSessionID	,;
						cContrato	, aCrdCliente	, aContratos	, aRecCrd		,;
						aTEFPend	, aBckTEFMult	, cCodConv		, cLojConv		,;
						cNumCartConv, uCliTPL		, uProdTPL		, aVidaLinkD	,;
						aVidaLinkc 	, nVidaLink 	, cCdPgtoOrc	, cCdDescOrc	,;
						nValTPis	, nValTCof		, nValTCsl		, lOrigOrcam	,;
						lVerTEFPend	, nTotDedIcms	, lImpOrc		, nVlrPercTot	,;
						nVlrPercAcr	, nVlrAcreTot	, nVlrDescCPg	, nVlrPercOri	,;
						nQtdeItOri	, nNumParcs		, aMoeda		, aSimbs		,;
					   	cRecCart	, cRecCPF		, cRecCont		, aImpsSL1		,;
						aImpsSL2	, aImpsProd		, aImpVarDup	, aTotVen		,;
						nTotalAcrs 	, aCols			, aHeader		, aDadosJur		,;
						aCProva		, aFormCtrl		, nTroco		, nTroco2		,;
						lDescCond	, nDesconto		, aDadosCH		, cItemCond		,;
						lCondNegF5	, aTefMult		, aTitulo		, lConfLJRec	,;
						aTitImp		, aParcelas		, oPgtosAna		, nTxJuros		,;
						lVendaRapida, nValorBase	, oMensagem		, oFntGet		,;
						cCodDEP		, cNomeDep		, cTipoCli		, cEntrega		,;
						aReserva	, lReserva		, lAbreCup		, nValor		,;
						oTimer      , lResume		, aValePre		, aRegTEF		,;
						lRecarEfet	, lCancItRec	, cNumDAV		, cCliCGC		,;
						cMensagem   , nVlrDescIT	, aTxJurAdm		, cDocFo		,;
						nArredondar , lSelTefManu, nDescItens		,nDescToP)
						
Local aTotForm
Local uRet
Local nRet
Local cRet			 	:= ""
Local aSL1
Local aSL4
Local nTamSXG
Local lCartao 		 	:= .F.
Local lRet    		 	:= .F.
Local lImpDesc 		 	:= .F.
Local nI
Local nJ
Local nX
Local nY
Local nValRec        	:= 0
Local nPos           	:= 0
Local aAux           	:= {}
Local aKey			 	:= {}
Local aTroco         	:= {}
Local cMsgCupom			:= ""										// Mensagem do cupom fiscal
Local cAuxMsgCup		:= ""											// Auxiliar de Mensagem
Local aTpAdms        	:= {}
Local aAreaSAE       	:= {}
Local lTrocoPad      	:= .F.
Local aAreaSFB       	:= {}
Local nTotImp        	:= 0
Local nTotImpNCM		:= 0
Local nTotVLRNCM		:= 0
Local nTotVLRFED		:= 0
Local nTotVLREST		:= 0
Local nTotVLRMUN		:= 0
Local nTotImpFED		:= 0
Local nTotImpEST		:= 0
Local nTotImpMUN		:= 0
Local nTmpDescFED		:= 0
Local nTmpDescEST		:= 0
Local nTmpDescMUN		:= 0

Local lSubTot        	:= .F.
Local aCheques		 	:= {}
Local nPosAdm        	:= 0
Local lRetTef		 	:= .F.
Local aDadosCrd 	 	:= {}                                       // Dados do cliente para o web service da analise de credito
Local aParcCrd		 	:= {}                                       // Parcelas do SIGACRD
Local aProdCrd       	:= {}                                       // Produtos da venda para integracao com SIGACRD
Local aCrdAdm 		 	:= {}										// Relacao das administradoras (SAE)
Local aRetCrd		 	:= { 0, 0, 0, "" }                         	// Retorno da integracao com SIGACRD
Local lTransCrd		 	:= .F.										// Indicacao da transacao de credito com sucesso ou nao
Local aTmpCliCrd     	:= {}
Local nMv_LjChVst	 	:= SuperGetMV("MV_LJCHVST", ,-1)			// Quantos dias considera um cheque a vista. Se for -1 nao trata o parametro
Local cTotRecNFis    	:= FR271GProfStr()
Local lTefMult		 	:= SuperGetMV("MV_TEFMULT", ,.F.)			// Identifica se o cliente utiliza múltiplas transações TEF
Local cAdminis		 	:= ""										// Administradora a ser conferida
Local lErrCupTEF     	:= .F.										// Erro na impressao do cupom
Local lForcada		 	:= .F.										// Indica se a venda foi off-line ou on-line. SIGACRD.
Local cVinculado	 	:= "0"										// Se eh venda com vinculado
Local cRespForcada   	:= ""                                		// Responsavel pela venda forcada
Local cMV_TEFPEND    	:= SuperGetMV("MV_TEFPEND",,"0")    		// Define o tratamento a ser realizado quando uma ou mais transacoes TEF ficam pendentes
                                                          			// "0" - cancela a transacao
                                                          			// "1" - permite modificar a parcela rejeitada
                                                          			// "2" - pergunta
Local cEOF			    := CHR(10)+CHR(13)
Local cSeqTrans		 	:= ""										// Sequencia da transacao TEF
Local cNumCupFis		:= Space(TamSX3("L1_DOC")[1])				// Tamanho do campo L1_NUMCFIS
Local lCancCup	   		:= .F.										// Indica se deverá cancelar o Cupom Fiscal em caso de erro no Fechamento da Venda

Local aRetPR         	:= {}
Local aParcVda       	:= {}                                 		// Parcelas da venda - integracao com SIGACRD
Local nPosCli		 	:= 0										// posicao do campo A1_COD no array a clientes
Local nPosLoja		 	:= 0										// posicao do campo A1_LOJA no array a clientes
Local lNovoCliente	 	:= .T.										// Variavel que indica se cria ou nao um novo registro no SA1
Local lCheque        	:= .F.                      	          	// Indica se a parcela eh cheque
Local nPosTEF		 	:= 0										// Posicao da primeira parcela referente ao TEF
Local nVlrEntrada	 	:= 0										// Valor de entrada no parcelamento do TEF
Local nCont			 	:= 0										// Contador de For
Local nTpVenda       	:= 1                               		    // 1-Venda Normal 2-Venda forcada
Local nMoedaParc     	:= 1                               		    // Moeda da parcela
Local nPosTEFDados   	:= 0 										// Posicao correspondente do registro do array aTEFMult no array aParcTEF
Local nPosParcelas   	:= 0                                		// Posicao correspondente da parcela TEF no array aParcelas
Local nNumParc       	:= 0                    	             	// Posicao da parcela correspondente no array aParcelas
Local lTrocoAux		 	:= .T.										// Se existe troco
Local lCancelaTEF    	:= .T.										// Controla se deve cancelar todas as transacoes TEF se alguma transacao foi reprovada
Local lTemTEFPend   	:= .F.                     		           	// Controla se tem transacao TEF jah realizada e pendente
Local lAbandonaTEF   	:= .F.  									// Controla se foi selecionada a opcao para nao prosseguir com a operacao TEF
Local aBckParcTEF    	:= {}                   	            	// Backup do array aParcTEF
Local aRegsSA1		 	:= {}										// Utilizada no WSCrdConscli para trazer o cliente para o PDV
Local cIdCartao			:= ""										// Identificacao do cartao
Local cFormaCart		:= ""										// Forma de pagamento do cartao (CD/CC)
Local nPosaPgtos		:= 0
Local lTefManual    	:= .F.			// Controla se TEF sera feito no P.O.S.

Local lDroVLVent	 	:= ExistTemplate("DroVLVen")  				// verifica se existe o PONTO DE ENTRADA DroVLVen
Local lDroVLImpt	 	:= ExistTemplate("DroVLImp")				// verifica se existe o PONTO DE ENTRADA DroVLImp
Local lFRTEntregt	 	:= ExistTemplate('FRTEntreg')				// verifica se existe o PONTO DE ENTRADA FRTEntreg
Local nPosFormPg     	:= 0										// Guarda o valor do comando ascan
Local nZ             	:= 0										// Variavel utilizada para posicionar aMultTef
Local nTotDescont    	:= 0                	            		// Total do desconto(cond. pagto + desc. total + ded. ICMS)
Local lCpoAcres		 	:= .F.										// Verifica campo do SE4
Local lVerEmpres     	:= Lj950Acres(SM0->M0_CGC)					// Verifica as filiais da trabalharam com acrescimento separado
Local lExecVenda	 	:= .T.										// Se executa o final da venda com orcamento
Local lSemRede		 	:= .F.										// Variavel que retorna se a rede selecioda no TEF existe na base
Local nLjpagto       	:= SuperGetMV("MV_LJPAGTO")					// Parametro que retorna como deve aparecer a forma de pagamento.
Local nTotAcres		 	:= 0										// Total de Acrescimo
Local aRetAdm			:= {}
Local lTouch			:= If( LJGetStation("TIPTELA") == "2", .T., .F. ) // Retorna se Interface eh Touch ou Padrao
Local oOrigBtns     	:= Nil
Local cSimbCheq   		:= AllTrim(MVCHEQUE)
Local lMV_LJSLFin  		:= SuperGetMV("MV_LJSLFIN", ,.T.)
Local nDecimais  		:= MsDecimais(nMoedaCor)
Local nDinheiro	 		:= 0
Local lDinheiro	 		:= .F.
Local nCheques	 		:= 0
Local nCartao		 	:= 0
Local nFinanciado	 	:= 0
Local nConvenio	 		:= 0
Local nVales		 	:= 0
Local nValorDebi	 	:= 0
Local nOutros		 	:= 0
Local lCheck		 	:= .T.										// Usada na LjxDGetCh
Local nDinMoedaCor 		:= 0
Local cForma			:= ""
Local cCartao     		:= Space(3)
Local cOrcamen    		:= cOrcam
Local lMVTELAFIN	 	:= SuperGetMV("MV_TELAFIN",,.T.)      		// Define de onde pega a ADM financeira
Local lRetPbm		    := .F.								   		// Retorno da PBM
Local cFormaSub 	 	:= SuperGetMV("MV_LJFSUB", Nil, "CO")   		// Verifica a forma utilizada para subsidio, se nao encontrar o default e CO
Local nfor				:= 0
Local nA				:= 0
Local cFormTef 			:= ""
local nReserTroco   	:= 0 						// Valor pago no cupom fiscal de troco
Local nVlrPagCF			:= 0							// Valor pago no cupom fiscal em não Tef
Local nVlrTefCF			:= 0							// Valor pago no cupom fiscal em Tef
Local nCupTEf			:= 0							// Valor pago no cupom TEF
Local nPosRtTef		:= 0						//posição no array de retorno do TEF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay 	 	:= !Empty(LjGetStation("DISPLAY"))
Local nValCredito    	:= 0                        					// Valor de Credito para o cliente (Display)
Local nVlrTMsg       	:= 0                        					// Valor total da venda (Display)
Local aRetCNF		 	:= {.F., {"", ""}} 							// Array com o retorno da funcao Lj7ImpCNF()
Local cImpFisc		 	:= LjGetStation( "LG_IMPFISC" )				// Retorna a impressora fiscal
Local nIT			 	:= 0
Local nVlrPagto		 	:= 0
Local n271AFatRes	 	:= 0
Local lFrontNCC		 	:= ExistFunc("FRT060NCC")					// Verifica se as funcoes de NCC para o Front estao compiladas
Local cParmDoc 	  	 	:= ""	  					 					// Numero documento
Local cParmSer 	  	 	:= ""						 					// Numero serie
Local cItemAjuste	 	:= 0											//Variavel Utilizada no Ajuste do Contador de Itens da SL2
Local nItemAjuste	 	:= 0											//Contador do numero de itens
Local lImpNFiscal	 	:= .F.											//Define se ira ou nao imprimir comprovante nao fiscal
Local lFrtTroco      	:= ExistBlock("FRTTROCO")       				// P.E. executado na tela de troco padrao (cPais == "BRA").
Local lGerTroco      	:= .T.
Local lCupAberto 	 	:= .T.
Local lVendaOK       	:= .F.                         				// Controla se a venda ou pedido foi gravado com sucesso ("00")
Local lPergNov		 	:= .T.
Local nContPerg		 	:= 0
Local cPegCOO		 	:= ""
Local cUltimoCOO	 	:= ""
Local nW			 	:= 0						   					// Variavel p/ controle de Loop
Local nIndChq		 	:= 1											// Indica item do aDadosCh
Local cFotoProd		 	:= "LOJAWIN"									// Foto padrão do produto
Local nValMin		 	:= (1 / (10 ^ nDecimais))     				// Valor minimo para registrar uma forma de pagamento
Local lImpCpfNpj	 	:= IIF(ExistFunc("FRTAImpCpf"),FRTAImpCpf(),.T.)
Local lCenVenda		 	:= SuperGetMv("MV_LJCNVDA",,.F.) 				// Indica se a integracao com o cenario de vendas esta ativa
Local lPreVenda		 	:= SuperGetMv("MV_LJPRVEN",,.F.)				// Indica se a integracao com o cenario de vendas esta ativa
Local cTabPad  		 	:= AllTrim(SuperGetMv("MV_TABPAD"))			// Tabela de preco padrao
Local cContOnf       	:= ""                               			// Contador Geral de Operação Não Fiscal
Local cContRg        	:= ""                               			// Contador Geral de Relatório Gerencial
Local cContCdc       	:= ""                               			// Contador de Comprovante de Crédito ou Débito
Local lRelGer        	:= .F.                              			// Indica se houve relatorio Gerencial
Local aGrupTrib		 	:= {}
Local nPercTot		 	:= 0
Local nMaior 		 	:= 1
Local nPosIt		 	:= 0
Local nValMaior		 	:= 0
Local nDifGrupo		 	:= 0
Local lHabNovoArred  	:= !lEmitNfce .AND. GetPvProfString("Arredondamento","Habilita","0",GetClientDir() + "SIGALOJA.INI") == "1" //Novo arredondamento - Bematech /Daruma / Sweda
Local nDiffIT 		 	:= 0											// Diferenca entre os itens
Local nPosAux		 	:= 0 											// Posicao do iten no aitens
Local nTotAliqs		 	:= 0 											// Total de aliquotas tributadas
Local nBasMAliq		 	:= 0											// Total de Base
Local nCtd           	:= 0                                			// Variavel contador
Local lMvLjTroco     	:= SuperGetMV("MV_LJTROCO", ,.F. )		 	// Verifica se utiliza troco nas diferentes formas de pagamento
Local lMvLjTrDin     	:= SuperGetMV("MV_LJTRDIN", ,0   )		 	// Determina se utiliza troco para diferentes formas de pagamento
Local nTotReceb      	:= 0                                			// Valor total dos recebimentos
Local cTMPnCupom     	:= "0"								// Numero do cupom fiscal, utilizado inicialmente com PBM Vidalink (template Drogaria)
Local aNumPed		 	:= {}											// Recebe o numero do cupom e a serie
Local lImp			 	:= .F.											// Indica se foi feita a correta impressora do comprovante da venda para PTG e ANG
Local cMsgNCM		 	:= ""								// Mensagem do cupom fiscal de olho no Imposto
Local nTPCompNCC     	:= SuperGetMV("MV_LJCPNCC",,1)					// Tratamento para compensacao de NCC 1 - INCLUSAO DE NOVO TITULO | 2 - ALTERACAO DO SALDO | 3 - BAIXA TOTAL DA NCC | 4 - SALDO DA NCC COM TROCO
Local lSelAdm        	:= SuperGetMv("MV_LJADMFI",,.F.)   			// Parametro que desabilita a escolha das administradoras de cartoes
Local aDescNCC		 	:= {}											// Array com informacoes dos Produtos do Desconto na Proxima Compra.
Local lAtivaMn		 	:= SuperGetMV("MV_LJMULTN", , .F.) // Ativa cenario de Vendas
Local cImpRGer  	 	:= SuperGetMV("MV_RELGART",,"U_LOJR600A") 		// Nome do MD5
Local cMvLjTGar		 	:= SuperGetMV("MV_LJTPGAR",,"GE")             	// Chama a user function
Local cCodProdRG	 	:= ""                                         	// Codigo produto relatorio gerencial
Local cDescPrdRG	 	:= ""                                         	// Descrição produto relatorio gerencial
Local nVlrItemRG	 	:= 0                                          	// Vlr do produto
Local cVlrItemRG	 	:= ""                                         	// Vlr do produto
Local cNSerieRG      	:= ""                                         	// NSerie
Local nRG			 	:= 0                                          	// Numero Relatorio gerencial
Local aRelGer		 	:= {}                                         	// Rel. gerencial
Local aRelGar		 	:= {}                                         	// Rel. garantia estendida
Local cItem			 	:= ""                                         	// Numeração de item de produto
Local cPicture       	:= PesqPict("SL2","L2_VLRITEM")   				// Picture
Local nForRel		 	:= 0											// Variavel para saber a quantidade de contratos necessarios imprimir
Local nXCount		 	:= 0											// Varival de lacos
Local lLjDespa		 	:= SuperGetMv("MV_LJDESPA",NIL,.F.)			// Habilita desconto por Adm e banco
Local lMvLJurCc		 	:= SuperGetMv("MV_LJJURCC",NIL,.F.)			// Parametro para habilitar ou nao o uso de juros sobre cartao de credito
Local nAcres		 	:= 0
Local nPercProduto	 	:= 0
Local nVlUnit		 	:= 0
Local nValIPIUnit	 	:= 0
Local nVlrNCCUnit	 	:= 0
Local nSomaAux		 	:= 0
Local nVlrSomAcr	 	:= 0
Local nDecVrUnit	 	:= TamSx3("L2_VRUNIT")[2]
Local aFatRes			:= {}								// Recebe o array com os dados da venda com reserva
Local nTotSemRes		:= 0								// Total da venda sem reserva
Local lGE			 	:= ExistFunc("LjUP104OK") .AND. LjUP104ok(.T.) 			// Validação do Conceito Garantia Estendida								// Varival de lacos
Local lRetiraPos		:= .F.								// .F. se o tipo de entrega do item for "2" ou " ". - Retira

/*Release 11.5 - Cartao Fidelidade*/
Local lLjcFid 			:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()			//Indica se a recarga de cartao fidelidade esta ativa

/*Release 11.5 - Controle de Formularios ³
Paises:Chile/Colombia - F1CHI	      */
Local lCFolLocR5		:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL" .AND. !lFiscal
Local nQtdeNotas 		:= 1                                      	//Quantidade de Notas
Local nMaxItens			:= 0										//Numero maximo de itens por nota
Local cSerieFo			:= ""										//Serie do controle de formulario
Local aBreakNota		:= {}										//Notas geradas a partir da venda quando o numero de itens de venda exceder o limite - Release 11.5 - Controle de Formularios
Local aItensBrk 		:= {}										//Itens das notas geradas a partir da venda quando o numero de itens de venda exceder o limite - Release 11.5 - Controle de Formularios
Local nVlrLiqAux		:= 0										//Valor Liquido - Auxiliar
Local nVlrBrutAux		:= 0										//Valor Bruto - Auxiliar
Local nVlrAcrFin		:= 0										//Valor Acrescimo Financeiro
Local aRetPgto			:= {}										//Parcelas da condicao de pagamento
Local cLojaNF			:= AllTrim(SuperGetMV("MV_LOJANF"))			//Serie Padrao da Nota Fiscal
Local nTamSerie			:= TamSX3("L1_SERIE")[1]					//Tamanho do campo L1_SERIE
Local aAreaSL2			:= {}										//Area da tabela SL2
Local lImpCNFLoc		:= .F.										//Indica se sera impresso um comprovante nao fiscal - Release 11.5 - Localizacoes - F2CHI
Local aItProdGar		:= {}										// Array com item Garantia Estendida
Local aDadosVend		:= {}									// Array com os dados do vendedor com 4 posições: {SA3->A3_COD,SA3->A3_COMIS,SA3->A3_GEREN,SA3->A3_SUPER}
Local oPbm 				:= LjGetOPBM()
Local lCpoAcresSL2 		:= SL2->(ColumnPos("L2_VALACRS")) > 0  // Verifica a existencia do campo de Acrescimo Financeiro no L2
Local nVlrFrete     	:= 0                                    // Valor de Frete(L1_FRETE).
Local nVlrSeguro		:= 0						            // Valor de Seguro(L1_SEGURO).
Local nVlrDespesa 		:= 0 				                    // Valor de Despesa (L1_DESPESA).
Local nOutrAcres		:= 0 								    // Outros acrescimos decorrentes de frete , seguro ou despesas.
Local lTentarNovamente 	:= .T.								// Controle de nova tentativa de envio de comando ao ECF
Local lFechouCupom 		:= .F.									// Controle que verifica se o cupom foi fechado

Local lMVLJPRDSV   		:= SuperGetMv("MV_LJPRDSV",.F.,.F.) 	// Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local nVlrItServ		:= 0 									// Valor dos itens de "Servico" (Referente a implementacao de Venda com Produto x Servico (RPS) MV_LJPRDSV)
Local cMsgAux 			:= ""
Local lTemServic 		:= .F. 								// Indica se tem itens de Servico na venda
Local aItServico 		:= {}									// Array com os Itens de Servico
Local cSerieRPS			:= AllTrim(SuperGetMv("MV_LOJARPS",,"RPS")) // Serie da NF de Servico RPS configurada no parametro MV_LOJARPS
Local lLj7Arred     	:= ExistFunc("Lj7Arred")          		// Verifica a existencia da função lj7arred que esta no LOJa701C
Local lTemGrpTrb 		:= .F. 								  	// Variavel para controlar se jah foi alimentado o array aGrupTrib
Local nResiduoIT 		:= 0								  	// Variavel auxiliar para ajuste de residuo de acrescimo ou desconto proporcionalizado no item
Local nResiduAux 		:= 0								  	// Variavel auxiliar para ajuste de residuo de acrescimo ou desconto
Local nDesTotReg		:= 0								  	// Valor do Desconto registrado no Cupom Fiscal
Local nAcrTotReg		:= 0								  	// Valor do Acrescimo registrado no Cupom Fiscal
Local nPercEfet 		:= 0 								  	// Percentual efetivo do Desconto ou do Acrescimo (para uso na regra de arredondamento da impressora)
Local nTotXAux			:= 0								  	// Variavel auxiliar (para uso na regra de arredondamento da impressora)
Local nVrDcAcTrb 		:= 0 								  	// Variavel armazena o valor do Desconto ou do Acrescimo calculado por tributacao
Local nVrDcAcIte 		:= 0 								  	// Variavel armazena o valor do Desconto ou do Acrescimo calculado para o Item
Local nPosItMenor 		:= 0 								  // Variavel armazena o menor valor dentro do array de grupo de tributação
Local nPosItMaior 		:= 0 								  // Variavel armazena o maior valor dentro do array de grupo de tributação
Local nValAtual 		:= 0
Local nDif      		:= 0
Local lL2VALEPRE 		:= SL2->(ColumnPos("L2_VALEPRE")) > 0 	//Verifica se existe o campo Vale Presente
Local nPosGe			:= 0
Local nVlrTotRe			:= 0								// Total de reserva na venda
Local lTemItemCF 		:= .F.
Local aDTEFPend			:= {}								//Transacoes Pendentes Direcao
Local nPosDTEF			:= 0 								//Posicao de D TEF pendente
Local nL2Totimp			:= 0 // Calculo do valor a ser gravado no total de juros
Local nTotDesp			:= 0 // Total de despesas para calculo de imposto Lei da transparencia
Local nValDescGar		:= 0
Local nValAcresGar		:= 0
Local nTotICMS			:= 0								//acumula valor de icms dos produtos
Local nTotISS			:= 0								//acumula valor de iss dos produtos
Local lIcmjr			:= cPaisLoc == "BRA" .And. SuperGetMV("MV_LJMULTN",,.F.) .And. SuperGetMV("MV_LJICMJR",,.F.) //Juros de acrescimo fin. separado da parcela
Local nVlAcrMultNeg 	:= 0
Local cTickForm			:= ""								//Texto para cupom não-fiscal para Instituto Arredondar
Local lIsVendaVP 		:= .F.	 							// Indica se eh venda de Vale Presente
Local aItValePre 		:= {}								// Array com os Itens de Vale Presente
Local nComprovNF		:= 1  								// Comprovante Nao-Fiscal a ser impresso [1=Pedido; 2=RPS (Recibo Provisorio de Servico); 3=Comprovante do Vale Presente]
Local nVlrGar			:= 0
Local nAcresImp			:= 0
Local aSubPgto			:= {}		// Array com as formas que serao enviadas para a impressora na venda com entrega e retira
Local nSubTPag			:= 0		// Valor total do pagamento quando retira e entrega
Local nDifPag			:= 0		// Diferenca de pagamento
Local nDecEcf 			:= Iif(ExistFunc("lj7DecECF") ,	Val(lj7DecECF('2')) , 2 )  // 1 = Grava ini , 2 = Recupera informacao ini
Local cKeyNfce			:= ""								// Chave da NFC-e
Local aNotas			:= {}								//Numero da nota fiscal da NFC-e
Local nItem				:= 0
Local aAuxStr			:= ""
Local lReenviaNFce		:= .F.								//Verifica se deve reenviar em contigencia a nfc-e em caso de nao comunicação
Local oLjNFCEPag		:= Nil								//Objeto de NFC-e para vendas com mais de uma modalidade.
Local nValorFSD 		:= 0
Local nFreteFat 		:= 0
Local nVlrNccCF 		:= 0			//valor da Ncc
Local lVendMis 			:= .F.		//Venda entrega e retira
Local lUseSAT 			:= .F.		//Utiliza SAT
Local cPass 			:= ""		//Chave de ativação SAT
Local aRetSAT			:= ""		//Retorno SAT
Local cXML				:= ""		//xml venda SAT
Local aSatSL1			:= {}		//chave de venda SAT
Local cDocSat 			:= ""		//numero de documento da venda SAT
Local cSerieSat			:= ""		//numero de serie do equipamento SAT
Local cIdAtual    		:= ""
Local cIdAnterior 		:= ""
Local cAuxNumCup		:= ""
Local nFreteProp		:= 0 		//Valor proporcional de frete L2
Local nTotEntrega		:= 0 		//Total itens Entrega
Local nBaseICMS			:= 0
Local nValICMS			:= 0
Local nValPag			:=	0
Local lTelaTroco		:= .F.
Local lRetVp			:= .F.
Local nValFecp			:= 0
Local lAEREDEAUT		:= SAE->(ColumnPos("AE_REDEAUT")) > 0
Local cBandSITEF		:= ""
Local cDesBandMDE 		:= ""
Local cRedeSITEF		:= ""
Local cDesRedeMDE 		:= ""
Local nParcDe			:= 0
Local nParcAte			:= 0
Local nTamCODSIT 		:= If(lSelAdm,TamSX3("MDE_CODSIT")[1],0)
Local cFormPagto		:= ""
Local nVlrIt			:= 0	//variavel auxiliar contendo o valor do item com o desconto no total aplicado (proporcionalizado)
Local nAux				:= 0
Local aSubPag			:={}
Local cMV_LJPGTRO		:= AllTrim(SuperGetMV("MV_LJPGTRO",,"R$"))
Local lLJPGTRO			:= !Empty(cMV_LJPGTRO)
Local cFormaPagto		:= ""
Local cMoedaTroc		:= ""
Local lTrocDin2			:= .F.    											//Usa a moeda default para troco
Local nPosDin			:= 0
Local lMultNeg 			:= SuperGetMV("MV_LJMULTN", , .F.)
Local lLjxDCGC			:= ExistFunc("LjxDCGC")
Local lLj950ImpCpf		:= ExistFunc("Lj950ImpCpf")
Local lLjInfDocCli		:= ExistFunc("LjInfDocCli")
Local aRetInfDocCli		:= {}
Local cCpfCli			:= ""
Local aNSUVndTef		:= {}
Local cNSUVndTef		:= ""
Local cFormTR			:= ""	//Recebe a forma de pagamento de troco   
Local nVlrTotCF			:= 0	//Valor somente da venda fiscal (sem desconto sem frete)
Local nVlrDescCF		:= 0	//Valor somente do desconto fiscal
Local aMDJ				:= {}	//Informações da NCC temporaria para caso houver uma queda no meio da venda.
Local aMDK				:= {}
Local nRecMdj			:= 0  	//Recno da NCC temporaria na MDJ
Local aSATDoc			:= {}
Local lTentaNova 		:= .F.
Local cMsgErro			:= ""	//Mensagem de Erro
Local aNFCeICMST 		:= Array(2) //Array de impostos da nfce
Local nId				:= 1 //contador
Local nFrete			:= 0
Local nSeguro			:= 0
Local nDespesa			:= 0
Local nRetMfe			:= 0 //posição do array de retorno do MFE
Local lL2FECP		:= SL2->( FieldPos("L2_ALQFECP") > 0 .AND. FieldPos("L2_VALFECP") > 0 )
Local nVlItFCP		:= 0 //valor do FECP no item
Local nAlqFECP		:= 0 //aliquota do FECP
	
//Variaveis utilizadas na consulta do TEF
DEFAULT lTEFPendRec 	:= .F.               							// Controla se tem transacao TEF jah realizada e pendente
DEFAULT aRecTEFMult 	:= {}
DEFAULT lF7				:= .F.
DEFAULT cCodDEP     	:= ""											// Codigo do dependente
DEFAULT cNomeDep    	:= ""               							// Nome do dependente
DEFAULT cTipoCli		:= ""
DEFAULT cEntrega		:= ""
DEFAULT aReserva		:= {}
DEFAULT lReserva		:= .F.
DEFAULT lAbreCup		:= .F.
DEFAULT lResume			:= .F.
DEFAULT nValor			:= 0
DEFAULT aValePre		:= {}
DEFAULT aRegTEF			:= {}
DEFAULT lRecarEfet		:= .F.
DEFAULT lCancItRec		:= .F.
DEFAULT cNumDAV			:= ""
DEFAULT cCliCGC			:= ""
DEFAULT cMensagem		:= ""
DEFAULT nVlrDescIT  	:= 0                                			// Valor do desconto no item
DEFAULT aTxJurAdm		:= {0,0,0}
DEFAULT lSelTefManu 	:= .F.
DEFAULT nDescItens		:= 0
DEFAULT nDescToP		:= 0

/*Release 11.5 - Controle de Formularios ³
  Paises:Chile/Colombia - F1CHI	     */
DEFAULT cDocFo			:= ""
DEFAULT	nArredondar 	:= 0											// doação para o Instituto Arredondar

// Verifica se utiliza SAT
lUseSAT 	:= IIF(ExistFunc("LjUseSat"),LjUseSat(),.F.)

//Codigo de ativação SAT
If SLG->(ColumnPos("LG_CODSAT"))>0
	cPass		:= IIF(LJGetStation("CODSAT",.F.) == Nil,"",LJGetStation("CODSAT",.F.))
EndIf

aTefMult  	:= {}								   					// Nova array utilizada nas multiplas transações

// Para os cenarios de vendas com troco importadas
If ( ntroco <= 0 )
	ntroco := SL1->L1_TROCO1
EndIf

LjLogFront(FRT_SEPARATOR)
LjLogFront("FRT271G - PRESSIONOU F9 PARA FINALIZAR A VENDA FRT271GENCERRA")
LjLogFront("FRT271G - VARIAVEIS LOGADAS")
LjLogFront("FRT271G - NUMERO DOC",cDoc)
LjLogFront("FRT271G - CUPOM",cCupom)
LjLogFront("FRT271G - VALOR TOTAL",nVlrTotal)
LjLogFront("FRT271G - TOTAL DE MERCADORIAS",nVlrMerc)
LjLogFront("FRT271G - TOTAL DE ITENS",nTotItens)
LjLogFront("FRT271G - ITENS DA VENDA",aItens)
LjLogFront("FRT271G - PAGAMENTOS",aPgtos)
LjLogFront("FRT271G - PERCENTUAL DO ITEM",nVlrPercIT)
LjLogFront("FRT271G - DESCONTO NO TOTAL",nVlrDescTot)
LjLogFront("FRT271G - DESCONTO ITEM",nVlrDescIT)
LjLogFront("FRT271G - DESCONTO ",nDesconto)
LjLogFront("FRT271G - VENDA RECUPERADA",lResume)
LjLogFront("FRT271G - DESCONTO NA CONDICAO DE PG",nVlrDescCPg)
LjLogFront("FRT271G - ACRESCIMO NO TOTAL",nVlrAcreTot)
LjLogFront("FRT271G - RESERVAS",aReserva)

//Somente considera ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas, se a venda nao for com "Reserva"
lMVLJPRDSV := lMVLJPRDSV .And. Len(aReserva) == 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a Venda com Produto x Servicos (RPS) em Notas separadas esta ativa.       ³
//³Realiza o carregamento dos itens de Servico que foram lancados no Orcamento Importado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMVLJPRDSV
	aItServico := FrtGetItSv()

	//Verifica se tem itens de servico
	If ( lTemServic := lMVLJPRDSV .And. Len(aItServico) > 0 )
		//Acumula o valor dos itens de Servico
		AEval(aItServico,{|x,y| nVlrItServ += aItServico[y][8]})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa Array que vem da Funcao FrtGetItSv para nao influenciar na Proxima Venda   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FrtSetItSv()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o carregamento dos itens de Vale Presente caso seja venda de Vale Presente.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("Lj7VPNew") .And. Lj7VPNew() .And. Lj7VPYesNo() == "S"
	aItValePre := FrtGetItVP()
	lIsVendaVP := .T. //Indica que eh uma venda de Vale Presente

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa Array que vem da Funcao FrtGetItSv para nao influenciar na Proxima Venda   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FrtSetItVP()
EndIf

// Apresentar as formas de pagamento no display caso a estacao esteja configurada
F271FPgtDp(aPgtosSint)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Garantia Estendida está Ativa             ³
//³Realiza o carregamento dos itens de Garantia Estendida³
//³que foram lançados no Orçamento Importado para que    ³
//³seja verificado no momento de impressão logo abaixo.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGE .AND. ExistFunc("GetProdGar") .AND.  SuperGetMv("MV_LJIMPGF",,.F.)
	aItProdGar := GetProdGar()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zera Array que vem da Função GetProdGar para ³
	//³não influenciar na Proxima Venda             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetProdGar()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se pode finalizar a Venda do Orcamento Importado.                                  ³
//³Para garantir que outro PDV nao tenha finalizado a Venda do mesmo orcamento simultaneamente.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpOrc .And. !FR271HRPCImpOrc(cOrcam, .T.)
	Return .F.
EndIf

//Quando venda nao tem origem de um orcamento importado (DAV/PV), limpa numeracao que pode estar em memoria
If !lImpOrc
	cNumDav := ""
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Soma o juros da adm financeira a variavel nTmpJuros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTxJurAdm) > 0
	If (lMvLJurCc) .AND. (aTxJurAdm[2] > 0)
		nTmpJuros += aTxJurAdm[2]
	EndIf
Endif

//Bloqueia a finalizacao da venda quando a transacao da recarga foi desfeita e o operador nao cancelou o item.
lCancItRec := FrtRetStc()
If lCancItRec
	MsgAlert(STR0057) //"Não é possível finalizar a venda, existe um item de recarga de celular que precisa ser cancelado porque sua transação foi desfeita."
	Return .F.
EndIf

If Len(aPgtos) > 0 .AND. aScan(aPgtos, {|x| x[3] == "DT" }) > 0 .AND. oTEF:aRetDotz == Nil //Pagamento Dotz 
	MsgAlert(STR0113) //"Foi informado pagamento com a forma Dotz mas a transação TEF não foi realizada. Refaça o pagamento com Dotz para continuar."
	Return .F.
EndIf

If lFrontNCC
	If Frt060Ret("NCC_USADA") <= 0
		If (nVlrTotal+nTroco) <= 0
			Return (.T.)
		EndIf
	EndIf
Else
	If (nVlrTotal+nTroco) <= 0
		Return (.T.)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()
lCancelaTEF   := IIf(lTEFMult,(cMV_TEFPEND == "0"),.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a origem do orcamento for financiada³
//³(dentro dos CNPJS cadastrados no LOJA950),      ³
//³eh necessario preparar a condicao novamente.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOrigOrcam
     For nI := 1 To Len(aPgtos)
		If AllTrim(aPgtos[nI][3]) == "FI" .AND. (aPgtos[nI][13] == 0 .OR. Empty(aPgtos[nI][13]))
			lExecVenda := .F.
		EndIf
	Next nI
	lOrigOrcam := .F.
	If !lExecVenda
		//"Este orçamento possui condição de pagamento com acréscimo financeiro, porém, não calculado. Por favor, confirme novamente a condição, pressionando <ESC>, <F9> e <F5>"
		//"Condicao de Pgamento : "
		MsgAlert(STR0023 + Chr(10) + STR0024 + AllTrim(cCdPgtoOrc) + " (" + Alltrim(cCdDescOrc) + ")",STR0002)
		Return .F.
	EndIf
EndIf
//Verifica se existe alguma forma de pgto que possui administradora porem a mesma nao foi informada nas parcelas geradas para pagamento
For nI := 1 To Len(aPgtos)
	//Caso seja cheque , dinheiro ou cartao fidelidade,a verificação não precisa ser efetuada
	If IsMoney(aPgtos[nI][03]) .OR. (aPgtos[nI][03] $ IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE) ) ;
		.OR. (aPgtos[nI][03] == "CR") .OR. ( aPgtos[nI][01] == Ctod("  /  /  ") .AND. Empty(aPgtos[nI][03])) .OR. AllTrim(aPgtos[nI][03]) == "FID"
		Loop
	Else
		//Monta array com os tipos de administradoras existentes no cadastro de administradoras financeiras
		If Empty(aTpAdms)
			aAreaSAE := SAE->(GetArea())
			SAE->(DbSetOrder(1))
			SAE->(DbSeek(xFilial("SAE")))
			aTpAdmsTmp := {}
			While SAE->(!Eof()) .AND. (SAE->AE_FILIAL == xFilial("SAE"))
				If !lTouch
					If lSelAdm
						If aScan(aTpAdms,{|x| Trim(x[2])==SAE->AE_COD + " - " + SAE->AE_DESC}) == 0

							nParcDe		:= If(SAE->AE_PARCDE==0,1,SAE->AE_PARCDE)
							nParcAte	:= If(SAE->AE_PARCATE==0,999,SAE->AE_PARCATE)

							DbSelectArea("MDE")
							MDE->(DbSetOrder(1))
							If !Empty(SAE->AE_ADMCART) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_ADMCART))
								cBandSITEF	:= MDE->MDE_CODSIT 	//Codigo da Bandeira (Retornado pelo SITEF)
								cDesBandMDE := AllTrim(MDE->MDE_DESC)	//Descricao da Bandeira
							Else
								cBandSITEF	:= Space(nTamCODSIT)
								cDesBandMDE := ""
							EndIf

							If lAEREDEAUT //Controle pela Rede que autorizou a transacao TEF
								If !Empty(SAE->AE_REDEAUT) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_REDEAUT))
									cRedeSITEF	:= MDE->MDE_CODSIT //Codigo da Rede autorizadora da transação TEF (Retornado pelo SITEF)
									cDesRedeMDE := AllTrim(MDE->MDE_DESC)
								Else
									cRedeSITEF	:= Space(nTamCODSIT)
									cDesRedeMDE := ""
								EndIf
							Else
								cRedeSITEF	:= Space(nTamCODSIT)
							EndIf

							AAdd(aTpAdms, {	SAE->AE_TIPO						,; //01-Tipo (CC,CD,...)
											SAE->AE_COD+ " - " +SAE->AE_DESC	,; //02-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
											nParcDe								,; //03-Parcela Inicial
											nParcAte							,; //04-Parce Final
											SAE->AE_ADMCART						,; //05-Codigo Relacionado a tabela MDE para a Bandeira
											cDesBandMDE							,; //06-Descricao da Bandeira (campo MDE_DESC)
											cBandSITEF							,; //07-Codigo da Bandeira (campo MDE_CODSIT)
											SAE->(Recno())						,; //08-Recno SAE
											cRedeSITEF							,; //09-Codigo da Rede (Campo MDE_CODSIT)
											cDesRedeMDE 						}) //10-Descricao da Rede (campo MDE_DESC)
						EndIf
					Else
						If aScan(aTpAdms,{|x| Trim(x[1])==Trim(SAE->AE_TIPO)}) == 0
							AAdd(aTpAdms, {SAE->AE_TIPO	, SAE->AE_COD + " - " + SAE->AE_DESC	, 0				, 0				,;
											""			, ""									, ""			, SAE->(Recno()) })
						EndIf
					EndIf
				Else
					If Alltrim(aPgtos[nI][03]) == AllTrim(SAE->AE_TIPO)
						AAdd( aTpAdmsTmp, {AllTrim(SAE->AE_TIPO), SAE->AE_COD + " - " + SAE->AE_DESC} )
						AAdd( aTpAdms, {SAE->AE_TIPO	, SAE->AE_COD + " - " + SAE->AE_DESC	, 0				, 0				,;
											""			, ""									, ""			, SAE->(Recno()) })
					EndIf
				EndIf
				SAE->(dbSkip())
			End
			RestArea(aAreaSAE)
		EndIf
		If !lTouch
			//Verifica se a administradora nao foi informada
			nPosAdm := Ascan(aTpAdms,{|x| Trim(x[1])==Trim(aPgtos[nI][03])})

			If Len(aTpAdms) == 0 .OR. nPosAdm == 0
				lRet := .F.
				//"E necessário que haja ao menos uma administradora financeira cadastrada para a forma de pagamento selecionada.", "Atenção"
				HELP(' ',1,'FRT038')
            ElseIf (Empty(aPgtos[nI][04]) .AND. Alltrim(aPgtos[nI,03])$_FORMATEF .AND. lUsaTef) .OR. ;
       				   (Empty(aPgtos[nI][04]) .AND. Alltrim(aPgtos[nI,03]) $ cFormaSub)
				//Adiciono a primeira forma cadastrada nos casos de TEF pois o sistema altera automaticamente na leitura do cartão
				//Adiciona a administradora automaticamente para a forma subsidio da PBM.
				aPgtos[nI][04] := aTpAdms[nPosAdm][2]
				lRet := .T.
				//Adiciono a primeira forma para que nao seja necessario a intervencao do caixa.
		   	ElseIf (Empty(aPgtos[nI][04]) .AND. Alltrim(aPgtos[nI,03])$ "BOL|FI" .AND. lUsaTef) .And. ;
					lMultNeg .And. cPaisLoc == "BRA" .And. !Empty(SL1->L1_CODMNEG)
					aPgtos[nI][04] := aTpAdms[nPosAdm][2]
					lRet := .T.
			ElseIf (Empty(aPgtos[nI][04]) .AND. !Alltrim(aPgtos[nI,03]) $ _FORMATEF) .OR. ;
            		(Empty(aPgtos[nI][04]) .AND. Alltrim(aPgtos[nI,03]) $ _FORMATEF .AND. !lUsaTef)
				lRet := .F.
				//"Por favor, selecione uma administradora financeira valida antes de encerrar a venda.", "Atenção"
				HELP(' ',1,'FRT037')
			Else
				lRet := .T.
			EndIf
		Else
			// Colocada aqui chamada de funcao para usuario escolher a Admin. de Cartao
			// utilizando a Grid do Mauro, caso o usuario escolha

			If lUsaTef .AND. cTipTef == TEF_CLISITEF .AND. aPgtos[nI][3] $ _FORMATEF
				lRet := .T.
			Else
				aRetAdm := Fr271IQualAdm(	aTpAdms	,aPgtos	, nI	, @aTpAdmsTmp) // Passa o Vetor ja com as Administradoras e Recebe a Administradora selecionada

				If Len(aTpAdms) == 0 .OR. Empty(aRetAdm)
					//"E necessário que haja ao menos uma administradora financeira cadastrada para a forma de pagamento selecionada.", "Atenção"
					HELP(' ',1,'FRT038')
	            ElseIf Empty(aPgtos[nI][04])
					//Adiciono a primeira forma cadastrada nos casos de TEF pois o sistema altera automaticamente na leitura do cartão
					aPgtos[nI][04] := aRetAdm[2]
					lRet := .T.
				Else
					lRet := .T.
				EndIf
			EndIf

			aTpAdms := {} // Zerando quando for Touch, pois filtramos o Grid conforme o Tipo da Administradora

		EndIf
	EndIf
	If !lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return(.F.)
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade                 ³
//³Verificar se o numero do cartao nao foi informado³
//³antes de ser gravado na SL4.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjcFid
	For nI := 1 To Len(aPgtos)
		If AllTrim(aPgtos[nI][03]) == "FID" .AND. Empty(Fa271FgFid())
			MsgStop (STR0066) //"Numero do cartão fidelidade não informado, verifique !"
		    Return (.F.)
		EndIf
	Next NI
EndIf

If !FR271HVlPar(	@nVlrTotal	, @aPgtos	, @nMoedaCor	,;
					@nDecimais	,nTaxaMoeda )
	//Verifica se o valor total das parcelas nao ficou inferior ao total da venda
	//devido a uma diferenca de "cambio", no momento de converter o valor da parcela
	//para todas as moedas...
	If cPaisLoc <> "BRA" .AND. Len(aPgtos) > 0
		lRet := ((nPos := aScan(aCProva,{|x| x[5]})) == 0)
		If !lRet
			MsgAlert(STR0012+aCProva[nPos][4]+STR0013)	//"O valor em "+aCProva[nPos][4]+" esta incorreto. Depois de acertar o valor tente finalizar a venda."
		    FRTSetKey(aKey)
		    Return(.F.)
        EndIf
    Else
    	lRet := .F.
    EndIf

	If !lRet
		// "A soma do valor das parcelas está menor que o valor total da venda.", "Atenção"
		HELP(' ',1,'FRT039')
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return(.F.)
	EndIf

EndIf

oCupom:AppendText((STR0005+Trans(nVlrTotal,PesqPict("SL1", "L1_VLRTOT", 13,nMoedaCor)))+ chr(10) + chr(13))  //"     S U B T O T A L      "//IMPRIMIR apenas no momento da finalização da venda


// Ponto de Entrada para a finalização da venda
If ExistBlock("FRTFINVEN")

	aRetPE := ExecBlock("FRTFINVEN", .F., .F., {nTotDedIcms, aItens, cCliente, cLojaCli,;
												 aPgtos, cItemCond })

	If !aRetPE[01]
		FRTSetKey(aKey)
		Return .F.
	EndIf

	If Len(aRetPE) > 1 .AND. ValType(aRetPE[02]) == "N" .AND. aRetPE[02] > 0

		// Soma o valor do segundo retorno para o valor total da venda e dá um refresh no objeto.
		nVlrTotal += aRetPE[02]
		If !lTouch
			oVlrTotal:Refresh()
		Endif
		// dá um refresh nas formas de pagamento.
		oPgtos:Refresh()

	EndIf

EndIf

LjLogFront("FRT271G - TOTAL DEPOIS DO FRTFINVEN",nVlrTotal)

If Len(aReserva) > 0		// Carrega o valor total de itens com reserva
	lReserva := .T.
	For nX := 1 To Len(aReserva)
		nVlrTotRe += aReserva[nX][8]
	Next nX
Else
	lReserva := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limitacao de 10.000,00 - Legislacao Paulista 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRecebe .AND. !Lj950SP10OK(nVlrTotal+(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA"))- nVlrTotRe, 1, cCliente, cLojaCli)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

nRet := IFStatus(nHdlECF, "2", @cRet)		// Verifico o Status do ECF

// Caso a data do sistema seja divergente da ddatabase forço o problema de erro 
If lEmitnfce .And. ExistFunc("Fr271aVlDt") .And. !Fr271aVlDt(lRecebe) 	
	nRet := -1  
EndIf

If nRet <> 0
	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	If !lEmitnfce 
		HELP(' ',1,'FRT011')
	Else
		MsgAlert(STR0114 + CRLF + STR0115)  // "A Data do dia é diferente da data do movimento" ... "Favor inicializar o sistema para atualizar com data atual."
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
	//³ Release 11.5 - Reinicializa variaveis de cartao fidelidade	  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
	If lLjcFid .AND. Fa271aGrcf ()
		LaFunhDelS ()
		Fa271aSrcf (.F.)
		Fa271aSpfw (.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Controle de Formularios ³
	//³Zerar RECNO da especie de documento    ³
	//³fiscal escolhida no inicio da venda.   ³
	//³Paises:Chile/Colombia - F1CHI		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCFolLocR5
		FaZerRecFo()
		cDoc := ""
	EndIf

	Return(.F.)
EndIf

aTotForm := Array(Len(aFormPag))
AFill(aTotForm, 0)
For nI := 1 To Len(aPgtos)

	If !( aPgtos[nI][01] == Ctod("  /  /  ") .AND. Empty(aPgtos[nI][03]) )

		cForma := aPgtos[nI][3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O parametro MV_LJPAGTO retorna um valor inteiro. Pode ser      ³
		//³1 que irá indicar que a descrição da forma de pagto será a da  ³
		//³tabela 24 do SX5 ou 2, que será do cadastro de administradoras ³
		//³(SAE).                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (IsMoney(cForma) .OR. cForma == cSimbCheq) .OR. nLjpagto==1
			aTotForm[AScan(aFormPag, {|x| AllTrim(x[2])==AllTrim(cForma)})] += Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],;
			                                                         nMoedaCor,dDataBase,;
			                                                         nDecimais+1,,nTaxaMoeda),nDecimais)
		Else

			If ( cForma $ _FORMATEF .AND. ! lMV_LJSLFIN )
				// Se o parâmetro for falso, joga tudo na primeira forma de pagamento que ele achou (CC/CD)
				aTotForm[aScan(aFormPag, { |x| AllTrim(x[2]) == AllTrim(aPgtos[nI,03]) })] += Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],;
	                                                                             nMoedaCor,dDataBase,;
	                                                                             nDecimais+1,,nTaxaMoeda),nDecimais)
			Else
				aTotForm[AScan(aFormPag, {|x| PadR(x[1],30)==PadR(Substr(aPgtos[nI][4],7),30)})] += Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],;
				                                                                                             nMoedaCor,dDataBase,;
				                                                                                             nDecimais+1,,nTaxaMoeda),nDecimais)
			EndIf

		EndIf

	EndIf

Next nI

lCFrete := .F.				// limpa a variavel que indica se o Frete já foi cobrado na Venda

/* Retorna a forma de pagamento que gerou o troco
 Quando o parametro MV_LJPGTRO está em branco só a forma $ pode dar troco
 portanto só altero se o param estiver preenchido */ 	
If lLJPGTRO .And. !IsMoney(cMV_LJPGTRO)
	// Reordena os arrays aFormPag, @aTotForm
	F271GReord("",@aFormPag,@aTotForm)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aParcelas (ARRAY com as formas e parcelas de pagto)³
//³ 01 - Data de Pagamento 							   ³
//³ 02 - Valor 										   ³
//³ 03 - Forma de Pgto (R$,CC)						   ³
//³ 04 - Administradora 	ou Banco				   ³
//³ 05 - Numero do Cartao 	ou Cheque				   ³
//³ 06 - Agencia do Cheque	 						   ³
//³ 07 - Conta do Cheque 							   ³
//³ 08 - Rg do Cheque 						   		   ³
//³ 09 - Telefone do Cheque 						   ³
//³ 10 - Valor lógico   					  	       ³
//³ 11 - Moeda da parcela (Localizações)   	           ³
//| 12 - Digitos do cartao para TEFMULT                |
//| 13 - Acrescimo financeiro 						   |
//| 14 - CPF/CNPJ do cheque				               |
//| 15 - Nome do Emitente do Cheque		               |
//| 18 - Compensacao, usado na tela do TEF (aDados)
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o Array PRIVATE aParcelas com as parcelas a pagar aForma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aParcelas  := AClone(aPgtos)
nParcelas  := Len(aPgtos)
aCheques   := {}
aTEFCH     := {}
aTEFCC     := {}
aTEFCD     := {}
lGetCheque := .F.
nEntrada   := 0
lVoltar    := .F.

//³Se trabalha com conceito de acrescimo separado,³
//³Exibir o valor do acrescimo separado da parcela³
If (lVerEmpres .AND. !lMultNeg) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA" .AND. !lMultNeg)
	For nX := 1 to Len(aParcelas)
		If aParcelas[nX][13] > 0 .AND. aParcelas[nX][3] <> "FI"
			If aParcelas[nX][1] <> dDataBase
				MsgAlert(STR0025) 	//"Nao sera possivel retirar os juros de uma parcela diferente de financiamento."
				FRTSetKey(aKey)
				Return(.F.)
			EndIf
		Endif
	Next nX
Endif
For nJ := 1 to Len(aParcelas)
	If aParcelas[nJ][3] == cSimbCheq
		If !lGetCheque																				// Processa somente uma vez,
			lGetCheque := .T.																		// Pegando todos os Cheques
			For nI := 1 to Len(aParcelas)
				If AllTrim(aParcelas[nI][3]) == cSimbCheq
					AAdd(aCheques,{aParcelas[nI][1], aParcelas[nI][2], aParcelas[nI][3],;
								   aParcelas[nI][4], aParcelas[nI][5], aParcelas[nI][6],;
								   aParcelas[nI][7], aParcelas[nI][8], aParcelas[nI][9]})
				EndIf
			Next nI
			If SuperGetMV("MV_INFCHEQ")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alteracao especifica para atender a legislacao do SEFAZ ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !LjAnalisaLeg(4)[1]
					aDadosCh   := LjxDGetCh(	GetWndDefault()	, @cDoc			, @aCheques		, @cCliente	,;
												@cLojaCli		, @aParcelas	, @lUsaDisplay	)
				EndIf
				If !aDadosCh[1][1]  // Caso esta posicao estiver falsa da um loop
				    If LjAnalisaLeg(4)[1]
						aDadosCh   := LjxDGetCh(	GetWndDefault()	, @cDoc			, @aCheques		, @cCliente	,;
													@cLojaCli		, @aParcelas	, @lUsaDisplay	)
					EndIf
					lVoltar := .T.	// Controla a volta para atela anterior
					Exit
				EndIf

				For nW	:= 1 to Len(aPgtos)
					If aPgtos[nW][3] $ MVCHEQUE
						If ValType(aPgtos[nW][4]) == "A"
							nIndChq ++
						ElseIf Len(aDadosCh) >= nIndChq
							aPgtos[nW][4] := {}
							AAdd(aPgtos[nW][4],aPgtos[nW][2]) 			//1 - Valor
							AAdd(aPgtos[nW][4],aPgtos[nW][1]) 			//2 - Data
							AAdd(aPgtos[nW][4],"")						//3 -
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][2])	//4 - Banco
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][4])	//5 - Agencia
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][5])	//6 - Conta
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][3])	//7 - Numero
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][9])	//8 - Compensacao
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][6])	//9 - RG
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][7])	//10 - Telefone
							AAdd(aPgtos[nW][4],"")						//11 -
							AAdd(aPgtos[nW][4],aDadosCh[nIndChq][8])	//12 - Chq Terceiro
							AAdd(aPgtos[nW][4],0)						//13 - Acrescimo financeiro
							If Len(aDadosCh[nIndChq]) >= 10
								AAdd(aPgtos[nW][4],aDadosCh[nIndChq][10])	//14 - Cpf/Cnpj do Cliente
							Endif

							// Verifica se o cheque eh de Terceiros
							If aDadosCh[nIndChq][8] .And. Len(aDadosCh[nIndChq]) >= 11
								AAdd(aPgtos[nW][4],aDadosCh[nIndChq][11])	//15 - Nome Emitente Cheque
							Endif

							nIndChq ++
						EndIf
					EndIf
				Next nW

				If (aPgtos[nJ][3] <> "CH") .AND. (Len(aDadosCh) == 0)
					aPgtos[nJ][4] := {}
					AAdd(aPgtos[nJ][4],aParcelas[nJ][2]) //1 - Valor
					AAdd(aPgtos[nJ][4],aParcelas[nJ][1]) //2 - Data
					AAdd(aPgtos[nJ][4],"")				//3 -
					AAdd(aPgtos[nJ][4],"")				//4 - Banco
					AAdd(aPgtos[nJ][4],"")				//5 - Agencia
					AAdd(aPgtos[nJ][4],"")				//6 - Conta
					AAdd(aPgtos[nJ][4],"")				//7 - Numero
					AAdd(aPgtos[nJ][4],"")				//8 - Compensacao
					AAdd(aPgtos[nJ][4],"")				//9 - RG
					AAdd(aPgtos[nJ][4],"")				//10 - Telefone
					AAdd(aPgtos[nJ][4],"")				//11 -
					AAdd(aPgtos[nJ][4],"")				//12 - Chq Terceiro
					AAdd(aPgtos[nJ][4],0)				//13 - Acrescimo financeiro
					AAdd(aPgtos[nJ][4],"")		   		//14 - Cpf/Cnpj do Cliente
					AAdd(aPgtos[nJ][4],"")		   		//15 - Nome Emitente Cheque
				EndIf
				nCh := 1
				For nI := 1 to Len(aParcelas)
					If Alltrim(aParcelas[nI][3]) == cSimbCheq
						aParcelas[nI][4] := aDadosCh[nCh][2]	// Repassa o aParcelas
						aParcelas[nI][5] := aDadosCh[nCh][3]	// com os dados do cheque.
						aParcelas[nI][6] := aDadosCh[nCh][4]
						aParcelas[nI][7] := aDadosCh[nCh][5]
						aParcelas[nI][8] := aDadosCh[nCh][6]
						aParcelas[nI][9] := aDadosCh[nCh][7]
						If Len(aDadosCh[nCh]) >= 10
							aParcelas[nI][14] := aDadosCh[nCh][10]
						EndIf

						aParcelas[nI][10] := aDadosCh[1][8]   // Cheque de Terceiro .T. / .F.
						If aParcelas[nI][10] .And. Len(aDadosCh[nCh]) >= 11
						    If Len(aParcelas[nI]) == 14
								Aadd(aParcelas[nI],aDadosCh[nCh][11])
							Else
								aParcelas[nI][15] := aDadosCh[nCh][11]
							Endif
						EndIf

						If Len(aParcelas[nI]) == 17  // acrescentara a posicao 18
							aAdd(aParcelas[nI], aDadosCh[nCh][9])  //Compensacao, usado na tela do TEF (aDados)
						EndIf

						nCh ++
					EndIf
				Next nI
			Else
				aPgtos[nJ][4] := {}
				AAdd(aPgtos[nJ][4],aParcelas[nJ][2]) //1 - Valor
				AAdd(aPgtos[nJ][4],aParcelas[nJ][1]) //2 - Data
				AAdd(aPgtos[nJ][4],"")				//3 -
				AAdd(aPgtos[nJ][4],"")				//4 - Banco
				AAdd(aPgtos[nJ][4],"")				//5 - Agencia
				AAdd(aPgtos[nJ][4],"")				//6 - Conta
				AAdd(aPgtos[nJ][4],"")				//7 - Numero
				AAdd(aPgtos[nJ][4],"")				//8 - Compensacao
				AAdd(aPgtos[nJ][4],"")				//9 - RG
				AAdd(aPgtos[nJ][4],"")				//10 - Telefone
				AAdd(aPgtos[nJ][4],"")				//11 -
				AAdd(aPgtos[nJ][4],.F.)			//12 - Chq Terceiro
				AAdd(aPgtos[nJ][4],0)				//13 - Acrescimo financeiro
				AAdd(aPgtos[nJ][4],"")				//14 - Cpf/Cnpj
				AAdd(aPgtos[nJ][4],"")				//15 - Nome Emitente Cheque
			EndIf
		EndIf
		nCheques += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		AAdd(aTefCH,aParcelas[nJ])													// TEF Cheque
	ElseIf aParcelas[nJ][3] == "CC"
		nCartao += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		AAdd(aTefCC,aParcelas[nJ])													// TEF Cartao de Credito
	ElseIf aParcelas[nJ][3] == "CO"
		nConvenio += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	ElseIf aParcelas[nJ][3] == "VA"
		nVales += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	ElseIf aParcelas[nJ][3] == "VP"
		// Pela tecla de atalho, o array chega aqui preenchido, pois ja foram informados os vales a serem selecionados
		// Quando orcamento importado, e chamada aqui a funcao de escolha dos vales.
		If Len(aValePre) == 0
		   	lRetVp := FR271GVlVP( nVlrTotal, @aValePre, @nValor )
   			If !lRetVp .or. Empty(aValePre) .or. nValor == 0
				Return(.F.)
			Endif
		Endif
		aAux := aClone( aParcelas[nJ] )
		aParcelas[nJ][2] := aValePre[1][2]
		aParcelas[nJ][5] := aValePre[1][1]
		nVales += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)

		For nI := 2 to Len( aValePre )
			aAdd( aParcelas, aClone(aAux) )
			aParcelas[Len(aParcelas)][2] := aValePre[nI][2]
			aParcelas[Len(aParcelas)][5] := aValePre[nI][1]
			nVales += xMoeda(aParcelas[Len(aParcelas)][2],aParcelas[Len(aParcelas)][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		Next nI
	ElseIf IsMoney(aParcelas[nJ][3])
		nDinheiro += Round(xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)
		lDinheiro := .T.
		If (cPaisLoc <> "BRA") .AND. (aParcelas[nJ][11] == nMoedaCor)
			lTrocoPad   := .T.
			nDinMoedaCor += aParcelas[nJ][2]
		EndIf
	ElseIf aParcelas[nJ][3] == "FI"
		nFinanciado += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		If aScan( aCrdAdm, Substr(aParcelas[nJ][4],1,TamSx3("AE_COD")[1]) ) == 0
			SAE->(DbSetOrder(1))
			If SAE->(DbSeek( xFilial("SAE")+Substr(aParcelas[nJ][4],1,TamSx3("AE_COD")[1]) ))
				If SAE->AE_PLABEL == "1"
					aAdd( aCrdAdm, { Substr(aParcelas[nJ][4],1,TamSx3("AE_COD")[1]),;
									 Substr(aParcelas[nJ][4], AT("-",aParcelas[nJ][4])+2,Len(aParcelas[nJ][4])) } )
				Endif
			Endif
		Endif
	ElseIf aParcelas[nJ][3] == "CD"
		nValorDebi += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
		aAdd(aTefCD,aParcelas[nJ])													// TEF Cartao de Debito
	Else
		nOutros += xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	EndIf
	If aParcelas[nJ][1] == dDatabase .AND. !(aParcelas[nJ][3] $ SuperGetMV("MV_ENTEXCE"))
		nEntrada += Round(xMoeda(aParcelas[nJ][2],aParcelas[nJ][11],nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)
	EndIf
Next nJ

// Apos alimentar o array aParcelas com o retorno da funcao FR271GVlVP, o array aValePre e inicializado
aValePre := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se escolheu voltar na getcheques ³
//³ retornar a tela anterior                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVoltar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

LjLogFront("FRT271G - aPgtos e aParcelas DEPOIS DE MONTADOS")
LjLogFront("FRT271G - aPgtos",aPgtos)
LjLogFront("FRT271G - aParcelas",aParcelas)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se estah integrado com o sistema de credito SIGACRD       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CrdxInt() .or.  (Len(aParcelas)>=1 .and. aParcelas[1][3]=="FI")

	//³Limpa a indicacao do cliente caso a venda tenha sido rejeitada para o   ³
	//³caso de utilizar outro cartao na finalizacao da venda                   ³
	If (lVerEmpres) .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1))
		If SE4->(DbSeek(xFilial("SE4") + cItemCond))
			If SE4->E4_AGRACRS == "2"
				lCpoAcres := .T.
			EndIf
		EndIf
    EndIf

	//³Monta os dados com as a venda para o sistema de credito fazer a³
	//³checagem do credito e a liberacao da venda                     ³
	aParcCrd := {}
	For nI := 1 To Len(aParcelas)
	   lCheque     := AllTrim(aParcelas[nI][3])=="CH"
	   nMoedaParc  := IIf(cPaisLoc == "BRA", 1, aParcelas[nI][11])
	   Aadd(aParcVda,{aParcelas[nI][1],;                									  	// Data de vencimento
		              IIf(!lCpoAcres,aParcelas[nI][2],aParcelas[nI][2]+aParcelas[nI][13]),;	// Valor da parcela
		     		  aParcelas[nI][3],;                										// Forma de pagamento
		     		  aParcelas[nI][4],;                										// Codigo da administradora ou numero do banco
		     		  aParcelas[nI][5],;                										// Numero do cartao ou cheque
		              IIf(lCheque,aPgtos[nI][6],""),;  										// Agencia do cheque
			 		  IIf(lCheque,aPgtos[nI][7],""),;  										// Conta do cheque
			 		  IIf(lCheque,aPgtos[nI][8],""),;  										// RG do cheque
			 		  IIf(lCheque,aPgtos[nI][9],""),;  										// Telefone do portador do cheque
		     		  .F.,;                             										//
			 		  nMoedaParc })	                    										// Moeda da parcela
		If lCpoAcres
			nTotAcres += aParcelas[nI][13]
		Endif
	Next nI

	aProdCrd := {}

	SL2->( DbSetOrder( 1 ))
	SL2->( DbSeek( xFilial("SL2") + cOrcam) )
	While SL2->( !Eof() ) .AND. SL2->(xFilial("SL2") + cOrcam == L2_FILIAL+L2_NUM )
		AAdd( aProdCrd, { SL2->L2_ITEM,;      //Item do Produto
		                  SL2->L2_PRODUTO,;   //Codigo do Produto
		                  SL2->L2_DESCRI,;    //Descricao do Produto
		                  SL2->L2_QUANT,;     //Quantidade de pecas vendidas
		                  SL2->L2_VRUNIT,;    //Valor unitario do produto
		                  SL2->L2_VLRITEM} )  //Valor total da venda do item

		SL2->( dbSkip() )
		Loop
	End

	If Len(aParcVda) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura da array aDadosCrd                                   ³
		//³[1] - Numero do cartao                                         ³
		//³[2] - Numero do CPF                                            ³
		//³[3] - Valor da venda (valor liquido)                           ³
		//³[4] - Juros da venda (%)                                       ³
		//³[5] - Numeros de parcelas                                      ³
		//³[6] - Venda forcada (1-Venda Normal 2-Venda forcada)           ³
		//³[7] - Responsavel pela venda forcada                           ³
		//³[8] - Array com as parcelas para o financiamento               ³
		//³      [1] - Data de vencto                                     ³
		//³      [2] - Valor da parcela                                   ³
		//³      [3] - Forma de pagto                                     ³
		//³      [4] - Administradora financeira                          ³
		//³[9] - Loja que solicitou a transacao                           ³
		//³[10] - Numero do PDV que solicitou a transacao                 ³
		//³[11] - Caixa que solicitou a transacao                         ³
		//³[12] - Numero do Orcamento selecionado                         ³
		//³[13] - Produtos contido na venda atual.                        ³
		//³      [1] - Item do produto                                    ³
		//³      [2] - Codigo do produto                                  ³
		//³      [3] - Descricao do produto                               ³
		//³      [4] - Quantidade de pecas                                ³
		//³      [5] - Valor unitario do produto                          ³
		//³      [6] - Valor total do item do produto                     ³
		//³[14] - Parcelas de uma venda.                                  ³
		//³      [1] - Data de vencto                                     ³
		//³      [2] - Valor da parcela                                   ³
		//³      [3] - Forma de pagto                                     ³
		//³      [4] - Administradora                                     ³
		//³      [5] - Numero do cartao / cheque                          ³
		//³      [6] - Agencia - Cheque                                   ³
		//³      [7] - Conta - Cheque                                     ³
		//³      [8] - Rg - Cheque                                        ³
		//³      [9] - Telefone - Cheque                                  ³
		//³      [10] - Valor logico                                      ³
		//³      [11] - Moeda da parcela (localizacoes)                   ³
		//³      [12] - ID para identif.da forma de pagto na operação TEF |
		//³      [13] - Acrescimo financeiro 							  |
		//³      [14] - Cpf/Cnpj do Cliente				                  ³
		//³[15] - Filial do Caixa que esta sendo utilizado.               ³
		//³[16] - Codigo do cliente                                       ³
		//³[17] - Loja do cliente                                         ³
		//³[18] - Nome do usuario                                         ³
		//³[19] - Condicao de Pagamento                                   ³
		//³[20] - Modulo que chamou a avaliacao de credito                ³
		//³[21] - Codigo do vendedor                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosCrd := {}
		aAdd( aDadosCrd, aCrdCliente[2] )													// 01 Numero do cartao
		aAdd( aDadosCrd, aCrdCliente[1] )													// 02 CNPJ/CPF
		aAdd( aDadosCrd, nVlrTotal+ nTotAcres )												// 03 Valor da venda
		aAdd( aDadosCrd, (nVlrAcreTot * 100 / (nVlrTotal-nVlrAcreTot)) )					// 04 Juros da venda
		aAdd( aDadosCrd, Len(aParcVda) )													// 05 Numero de parcelas
		aAdd( aDadosCrd, nTpVenda )															// 06 Venda forcada
		aAdd( aDadosCrd, cRespForcada )														// 07 Responsavel pela venda forcada
		aAdd( aDadosCrd, aClone(aParcCrd) )													// 08 Dados das parcelas [n,1]=Data vencto [n,2]=Valor da parcela [n,3]=Forma de pagto
		aAdd( aDadosCrd, SM0->M0_CODIGO+"-"+FWGETCODFILIAL+"-"+Alltrim(SM0->M0_NOME)  )	// 09 Loja da venda
		aAdd( aDadosCrd, LjGetStation("LG_PDV"))											// 10 PDV
		aAdd( aDadosCrd, xNumCaixa() )														// 11 Caixa
		aAdd( aDadosCrd, cOrcam )															// 12 Num. do orcamento
		aAdd( aDadosCrd, aClone(aProdCrd) )													// 13 Produtos selecionados numa venda
		aAdd( aDadosCrd, aClone(aParcVda) )													// 14 Parcelas de uma venda
		aAdd( aDadosCrd, FWGETCODFILIAL )													// 15 Filial do Caixa que esta sendo utilizado
		aAdd( aDadosCrd, cCliente )															// 16 Codigo do cliente
		aAdd( aDadosCrd, cLojaCli )															// 17 Loja do cliente
		aAdd( aDadosCrd, cUserName )														// 18 Nome do usuario
		aAdd( aDadosCrd, cItemCond )												  		// 19 Condicao de Pagamento
		aAdd( aDadosCrd, "FRT"     )												  		// 20 Modulo chamador
		aAdd( aDadosCrd, cVendLoja )												  		// 21 Codigo do vendedor

		aRetCrd := aClone(CrdxVenda( "1"   	,@aDadosCrd  	, Nil   , .T.  ,;
		                              Nil   ,"43" 			, Nil	, @aRecCrd))

		//Verifica se eh venda financiada
		If Len(aDadosCrd[8]) > 0
           //O array recebe as parcelas que foram financiadas
		   aParcCrd:= aClone(aDadosCrd[8])
		   If !aRetCrd[5]
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³A liberacao do credito foi confirmada                                   ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  lVoltar 	  := .F.
			  lTransCrd   := .T.
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³Alimenta as variaveis referente aos dados do cliente                    ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  // Verifica se a venda foi off-line
			  If aRetCrd[1] == 2
				 lForcada   := .T.
				 If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
				  	If Empty(cCliente + cLojaCli)
				 		cCliente	:= SuperGetMV("MV_CLIPAD")
				 		cLojaCli	:= SuperGetMV("MV_LOJAPAD")
				 	EndIf
				 Else
				 	cCliente	:= SuperGetMV("MV_CLIPAD")
				 	cLojaCli	:= SuperGetMV("MV_LOJAPAD")
				 EndIf
			  Else
				 cCliente	:= aDadosCrd[16]
				 cLojaCli	:= aDadosCrd[17]
			  EndIf
		   Else
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³A liberacao do credito nao foi confirmada                               ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		      cCliente	   := aDadosCrd[16]
			  cLojaCli	   := aDadosCrd[17]
			  lVoltar 	   := .T.
			  lTransCrd    := .F.
		   EndIf

		   //[1]-CPF [2]-Numero do Cartao Private Label
		   aCrdCliente[1]  := aDadosCrd[2]
		   aCrdCliente[2]  := aDadosCrd[1]
		   cContrato 	   := aRetCrd[4]
		   If !Empty(cContrato) .AND. Ascan(aContratos,{|x| Trim(x) == Trim(cContrato)}) == 0
		      Aadd(aContratos,cContrato)
		   EndIf
		Else
           cContrato    := Space(TamSx3("MAH_CONTRA")[1])
		EndIf
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a transacao TEF                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lUsaTef .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF+";"+TEF_CENTROPAG) .AND. ;
    (!CrdxInt() .OR. (CrdxInt() .AND. (aRetCrd[1] == 0 .OR. aRetCrd[1] == 2)))
	lTefOk 		:= .F.
	lRet   		:= (nRet = 0)
	aParcTef 	:= {}

	//ATENCAO VERIFICAR O SIGACRD
	If cTipTef == TEF_CLISITEF .OR. cTipTef == TEF_CENTROPAG
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponte de Entrada de Templates para a rotina do PBM Vidalink.  ³
	//³Informa ao VidaLink os produto e quantidades vendidas.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDroVLVent
			/*
				Busca o numero do documento fiscal
			*/
			If !ExistFunc("LjPbmNumDoc")
			
				If lEmitNFCe
					//retorna o conteúdo do campo X5_DESCRI	da tabela SX5
					cTMPnCupom := Tabela( '01', LjGetStation("SERIE") )
					//a transação PBM somente suporte 6 caracteres para o número do cupom fiscal
					cTMPnCupom := Right( cTMPnCupom, 6 )
				Else
					cTMPnCupom := FR271PegNuCup()
				EndIf
			Else
				cTMPnCupom := LjPbmNumDoc(6, LjGetStation("SERIE"),.F.)
			EndIf	
			LjLogFront( ProcName(0) + " NUMERO DO DOCUMENTO OBTIDO: ", cTMPnCupom )

			aRet := ExecTemplate("DroVLVen",.F.,.F.,{nVidaLink,aVidaLinkC,aVidaLinkD,cTMPnCupom})
			nVidaLink  := aRet[1]
			aVidaLinkC := aClone(aRet[2])
			aVidaLinkD := aClone(aRet[3])
		EndIf
		//Pegando os dados totalizados de cartões a serem enviados para a transacao TEF
		For nJ := 1 To Len(aPgtosSint)
			If AllTrim(aPgtosSint[nJ][1]) $ _FORMATEF

				//Verifica o valor da primeira parcela a ser enviada para a transação TEF
				nPosTEF 	:= Ascan(aParcelas,{|x| AllTrim(x[3])+AllTrim(x[12]) == AllTrim(aPgtosSint[nJ][1])+AllTrim(aPgtosSint[nJ][4]) } )
				nVlrEntrada := If(nPosTEF>0,aParcelas[nPosTEF][2],0)
				If nJ = 1 .AND. nArredondar > 0
					nVlrEntrada := nVlrEntrada + nArredondar
				EndIf

		        Aadd(aParcTEF,{ aPgtosSint[nJ][5],;											//Data
			        		    (Val(StrTran(StrTran(aPgtosSint[nJ][3],",",""),".",""))/100)+iif(nJ=1,nArredondar,0),;	//Valor
			        		    aPgtosSint[nJ][1],;											//Forma
			        		    aPgtosSint[nJ][4],;											//ID para identificação da forma de pagamento na operação TEF
			        		    aPgtosSint[nJ][2],;											//Qtde de Parcelas
								nVlrEntrada,;												//Valor Entrada
								{Space(03),Space(3),Space(04),Space(10),Space(07),Space(15),Space(15)} , ; // //Dados do Cheque
								aPgtosSint[nJ][6][5]})

				lCartao := .T.
				//verifica se já houve autorização do TEF de alguma transação dentro do array. Se sim ,não permite a chamada do TEF novamente.
				If ValType(oTef:aRetCartao) <> "U"
					nPosRtTef := Ascan( oTef:aRetCartao,{|x| AllTrim(x:cForma) == Alltrim(aPgtosSint[nJ][1]) .And. AllTrim(x:cIDCart) == AllTrim(aPgtosSint[nJ][4]) .And.;
					(Val(StrTran(StrTran(aPgtosSint[nJ][3],",",""),".",""))/100)+iif(nJ=1,nArredondar,0) == x:nVlrTrans })
					
					If nPosRtTef > 0
						If !Empty(Alltrim(oTef:aRetCartao[nPosRtTef]:cAutoriza))						
							lCartao := .F.
							lTefOk	:= oTef:lTefOk
						Endif
					Endif	
				EndIf
								
			EndIf
		Next nJ
		//Se a estação utilizar consulta de cheques pegar os dados analíticos de todos os cheques a serem consultados
		If At("S",LjGetStation("TEFCONS")) <> 0
			For nJ := 1 To Len(aParcelas)
				If AllTrim(aParcelas[nJ][3]) == cSimbCheq
			        Aadd(aParcTEF,{ aParcelas[nJ][1],;										//Data
				        		    aParcelas[nJ][2],;										//Valor
				        		    aParcelas[nJ][3],;										//Forma
				        		    aParcelas[nJ][12],;										//ID para identificação da forma de pagamento na operação TEF
									Len(aCheques),;									//Qtde de parcelas
									0,;
		    	    		    	{Space(03),aParcelas[nJ][4],aParcelas[nJ][6],aParcelas[nJ][7],aParcelas[nJ][5],IIf(Len(aParcelas[nJ])==18,aParcelas[nJ][18],Space(15)),Space(15)}})	//Dados do Cheque
					lCartao := .T.
				EndIf
			Next nJ
	    EndIf
	Else
		For nJ := 1 To Len(aParcelas)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver integracao com o SigaCrd verifica se a parcela jah foi enviada ³
			//³ para o financiamento (se estah no array aParcCrd)                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CrdXInt()
				If aScan( aParcCrd, {|x| x[1]==aParcelas[nJ][1] .AND. x[2]==aParcelas[nJ][2] .AND. x[3]==aParcelas[nJ][3] .AND. x[4]==aParcelas[nJ][4] } ) == 0
					If AllTrim(aParcelas[nJ][3]) $ _FORMATEF .OR. (AllTrim(aParcelas[nJ][3]) == cSimbCheq .AND. At("S",LjGetStation("TEFCONS")) <> 0)
						If lUsaTef .AND. Iif(AllTrim(aParcelas[nJ][3]) $ _FORMATEF, lTefMult, .T.)
							If Alltrim(aParcelas[nJ][3]) == cSimbCheq
								Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][5], aParcelas[nJ][4], aParcelas[nJ][6], aParcelas[nJ][7], nJ})
												//Data Pgto     , Valor          , Forma          , Nº do Cheque   , Banco    	   , Agencia        , Conta          ,Posição no array aParcelas
							Else
								Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][4], nJ, aParcelas[nJ][12] })
												//Data Pgto     , Valor          , Forma          , Adm ou Banco   , Posicao , ID para TEFMULT
												//																	  array
							EndIf
						Else
							aadd(aParcTef,aParcelas[nJ])
						EndIf
						lCartao := .T.
					EndIf
				Endif
			Else
				If AllTrim(aParcelas[nJ][3]) $ _FORMATEF .OR. (AllTrim(aParcelas[nJ][3]) == cSimbCheq .AND. At("S",LjGetStation("TEFCONS"))<>0)
					If lUsaTef .AND. Iif(AllTrim(aParcelas[nJ][3]) $ _FORMATEF, lTefMult, .T.)
						If Alltrim(aParcelas[nJ][3]) == cSimbCheq
							Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][5], aParcelas[nJ][4], aParcelas[nJ][6], aParcelas[nJ][7], nJ})
							               //Data Pgto     , Valor           , Forma           , Nº do Cheque    , Banco    	   , Agencia        , Conta          ,Posição no array aParcelas
						Else
							Aadd(aParcTEF, {aParcelas[nJ][1], aParcelas[nJ][2], aParcelas[nJ][3], aParcelas[nJ][4], nJ, aParcelas[nJ][12] })
										  //Data Pgto       , Valor          , Forma           , Adm ou Banco   , Posicao , ID para TEFMULT
										  //																	   array
						EndIf
					Else
						Aadd(aParcTef,aParcelas[nJ])
					EndIf
					lCartao := .T.
				EndIf
			Endif
		Next nJ
	EndIf

	If lUsaTef .AND. lCartao

		If cTipTef == TEF_CLISITEF
			//Pega o numero do cupom para inicializar a transacao de tef
			cSeqTrans := StrZero(Val(FR271PegNuCup()), TamSx3("LG_COO") [1], 0)

			If ( Empty(cSeqTrans) .Or. Val(cSeqTrans) == 0 ) .And. ExistFunc("F271TefNum")
				cSeqTrans := F271TefNum()
			EndIf

			LjGrvLog(Nil, "FRT271G - Chave da trans. TEF: " + cSeqTrans)

			//Verifica se a impressora retornou o numero do cupom
			If Empty(cSeqTrans)
				FRTSetKey(aKey)
				//"A impressora não retornou o número do cupom para inicializar a transação de tef."
				//"Por favor, tente finalizar a venda novamente."
				Alert(STR0058 + Chr(10) + Chr(13) + STR0059)
				Return .F.
			EndIf

			LjLogFront("FRT271G - VAI REALIZAR A OPERACAO DE TEF")

			If lMFE .And. lLjEnvPgto
				aIdPgtoMfe := {}			
				For nX := 1 To Len(aParcTEF)
					If AllTrim(aParcTEF[nX][3]) $ _FORMATEF
						nRetMfe ++					
						LjMsgRun("Enviando pagamento para o VFP-e..." ,,{ || aAdd(aIdPgtoMfe,LjEnvPgto(cValToChar(aParcTEF[nX][2]),.T.)) })
						If Len(aIdPgtoMfe[nRetMfe]) <= 0	//Tratamento para não prosseguir com a venda caso não houver resposta do MFE
							LjCleanFile()
							Return .F.
						EndIf						
					EndIf	
				Next nX	
			EndIf			

			oTEF:Operacoes( "V"      , aParcTef , @lTEFPendCS, @aTefBKPCS ,;
						    cSeqTrans, @aFormCtrl, @aPgtos   , @aPgtosSint,;
						    @oPgtos  , @oPgtosSint)
			LJTEFConfRW( cGetCliDir + "CLISITEF."+StrZero(oTEF:nIDTermina,3), .T., oTEF:cCupom, oTEF:cData,;
						 oTEF:cHora )

            // Atualiza as variaveis de controle conforme operacao TEF.
			lTefOk	:= oTef:lTefOk
			lRet	:= oTef:lTefOk

			LjLogFront("FRT271G - RETORNO DO TEF",lRet)

			If !lTefMult
				lTefPendCS 	:= lTefOK
			EndIf
			If lTefOk
				If !lMVTELAFIN .AND. !lSelAdm
					For nX := 1 To Len(oTef:aRetCartao)
						If !Empty(oTef:aRetCartao[nX]:cHoraTrans)
							nPosaPgtos := Ascan( aPgtos,{|x| AllTrim(x[3]) == AllTrim(oTef:aRetCartao[nX]:cForma) .And. AllTrim(x[12]) == AllTrim(oTef:aRetCartao[nX]:cIDCart) })
							cAdminis := LJ7ConfAdm( aPgtos[nPosaPgtos][4], oTef:aRetCartao[nX]:cDescAdm, @lSemrede, aPgtos[nPosaPgtos][3], oTef:aRetCartao[nX]:cIDCart )
							lSemrede := lSemrede .And. Empty(cAdminis) //Caso nao seja identificada a rede e nao possu uma padrao (pre-selecionada)

							If Empty( cAdminis )
								HELP( " ", 1, "SEMINSTITU" )
								// ### "Administradora: " ### ". Efetue o cadastro da Administradora no arquivo SAE e salve esta venda como Orçamento."
									MsgInfo(STR0026 + TRIM(oTef:aRetCartao[nX]:cDescAdm) + STR0027)
									lVldTef := .T.
							Else
								cIdCartao := aPgtos[nPosaPgtos][12]
								cFormaCart:= aPgtos[nPosaPgtos][3]
								//Executa o Laco para atualiza todas as parcelas do Cartao e ID em questao
								For nI:=1 To Len(aPgtos)
									If aPgtos[nI][12] == cIdCartao .AND. aPgtos[nI][3] $ _FORMATEF .And. aPgtos[nI][3] == cFormaCart
										aPgtos[nI][4]:= cAdminis
									EndIf
								Next nI
							Endif
						Endif
					Next
					If lSemRede
						oTEF:FinalTrn(0)
					EndIf
				EndIf
				If !lTefMult
					If lSemRede .AND. lTefPendCS
						lTefPendCS := .F.
						aTefBKP := {}
						lVoltar := .T.
					EndIf
				Else
					lVoltar := lSemRede
				EndIf
			EndIf
		ElseIf cTipTEF == TEF_CENTROPAG .AND. cPaisLoc == "MEX"
			oTef:Operacoes(aParcTef)
			lTefOk := oTef:lTefOk
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui do array aParcTEF as transacoes que jah foram realizadas e estao   ³
			//³ pendentes no servidor TEF, procedimento adotado quando rejeita a segunda  ³
			//³ transacao TEF  															  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lTemTEFPend  := .F.
			If lTefMult .AND. cMV_TEFPEND $ "1|2"
			   aBckParcTEF  := AClone(aParcTEF)
		       For nX := 1 to LEN(aTEFPend)
		          nPosTEFDados  := FR271ISeekParc( nX  ,aTEFPend )
			      If nPosTEFDados > 0
			         ADEL(aParcTef, nPosTEFDados)
			         ASIZE(aParcTef, LEN(aParcTef) - 1)
			         lTemTEFPend  := .T.
		          EndIf
		       Next nX
		    EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama a funcao LOJA010T apenas se houver transacao que ainda nao foi rea- ³
			//³ lizada. Se MV_TEFPEND = "0", entra nesta condicao porque lTemTEFPend = .F.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If !lTemTEFPend .OR. LEN(aParcTEF) > 0
			lTefOk := 	LOJA010T(	"V"				, NIL		, aParcTef    	, NIL         	,;
			   						NIL				, NIL		, @lTemTEFPend	, @lAbandonaTEF	,;
			                       	Nil 			, Nil		, Nil			, @lSemRede		,;
			                       	@cOrcamen	 	,			,				,				,;
			                       					,			,				)



			   // Se tiver Tef pendente segue normalmente,
			   // isso significa que conseguiu fazer a primeira transação.
               lRet := lTemTEFPend

			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³Acrescentar a transacao anteriomente aprovada no array aTEFMult³
			   //³para que seja confirmada posteriormente. Deve ser colocado na  ³
			   //³ordem em que foi realizada a transacao						 ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   If lTefOk .AND. lTemTEFPend .AND. lTefMult
			      For nX := 1 to LEN(aBckTEFMult)
	                 aAdd(aTEFMult,{})
					 aIns(aTEFMult,nX)
					 aTEFMult[nX] := Array(11)
					 For nY := 1 to LEN(aBckTEFMult[nX])
					    If ValType(aBckTEFMult[nX][nY]) <> "A"
					       aTEFMult[nX][nY] := aBckTEFMult[nX][nY]
					    Else
					       aTEFMult[nX][nY] := AClone(aBckTEFMult[nX][nY])
					    EndIf
					 Next nY
			      Next nX
			   EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se ha transacao TEF pendente(lTemTEFPend = .T.) e a transacao reprovada   ³
			//³ foi substituida por uma parcela que nao use TEF(dinheiro, cheque etc.)    ³
			//³ volta o backup em aTefMult e aParcTEF para que a transacao aprovada seja  ³
			//³ confirmada																  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ElseIf lTefMult .AND. cMV_TEFPEND $ "1|2"
			   lTefOk  := .T.
			   aTEFMult  := AClone(aBckTEFMult)
			   aParcTEF  := AClone(aBckParcTEF)
			EndIf
		EndIf

		If !Valtype(lTefOk ) == "L"
			lTefOk := .F.
		ElseIf !lTefOk
			If cTipTef <> TEF_CLISITEF

				If cMV_TEFPEND $ "1|2"
					//Foi colocado um parâmetro para determinar se o cliente utiliza ou não esta pergunta
					If !SuperGetMV("MV_TEFMANU", ,.T.)
						lRet 	:= .F.
					Else
						If lSemrede
							lRet := .F.
						Else
							//"Continua Manualmente?"
							If lUsaDisplay
								LjLimpDisp()
								DisplayEnv(StatDisplay(), "1E" + STR0006)		// ### "Continua Manualmente?"
								DisplayEnv(StatDisplay(), "2E" + STR0106)		// ### "<ENTER> - Continuar"
								DisplayEnv(StatDisplay(), "3E" + STR0107)		// ### "<ESC> - Cancelar"
							Endif

							//"Continua Manualmente?"
							If ( lRet := LojaOk(STR0006) )
								LjLogFront("FRT271G - CONTINUA MANUALMENTE COMO SIM 01")
								lCancelaTEF  := .F.
								lVerTEFPend  := .T.
								lSelTefManu	 := .T.
							EndIf

							// Limpar as mensagens do display
							LjLimpDisp()
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Permite a selecao de nova forma de pagamento ou cancela todas caso alguma³
				//³transacao TEF tenha sido reprovada                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If lTefMult .AND. cMV_TEFPEND $ "1|2" .AND. !lAbandonaTEF .AND. lTemTEFPend 	//1 = Digita nova forma de pagamento; 2 = Pergunta ao Caixa
			        If IIf(cMV_TEFPEND == "2",Aviso(STR0002,STR0014 + CRLF + ; 				//"Atenção", "Selecione a opção desejada:"
			                                        STR0028 + CRLF + ;							//"Modificar - altera a parcela atual"
			                                        STR0029,;									//"Cancelar - cancela todas as transações TEF desta venda"
			                                        {STR0030,STR0031}) == 1,.T.)				//"Modificar", "Cancelar"

			           lCancelaTEF  := .F.
			           lVerTEFPend  := .T.
			           For nX := 1 to Len(aTEFMult)
			              nPosTEFDados  := 0
						  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  //³[8] - Resultado da transacao -> Verifica se foi reprovada³
						  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			              If !aTEFMult[nX][8]
			                 nPosTEFDados  := FR271ISeekParc( nX  ,aTEFMult )
			                 If nPosTEFDados > 0
			                    nPosParcelas  := 0
			                    If LEN(aParcTEF[nPosTEFDados]) == 6       //Cartao
			                       nPosParcelas  := aParcTEF[nPosTEFDados][5]  //Posicao no array aParcelas
			                    ElseIf LEN(aParcTEF[nPosTEFDados]) == 8   //Cheque
			                       nPosParcelas  := aParcTEF[nPosTEFDados][8]  //Posicao no array aParcelas
			                    EndIf
			                    If nPosParcelas > 0
			                    	If !lRet
				                    	FR271INovoPgto( nPosParcelas	, @oFimVenda	, @oPgtos		, @oPgtosSint	,;
				                    				 	@aPgtos	 		, @aPgtosSint	, @aBckTEFMult	, @nMoedaCor	,;
				                    				 	@aFormCtrl		, @aTefMult		, @aParcelas	, @oPgtosAna	,;
				                    				 	@nTxJuros		, @aMoeda		, @lVendaRapida	, @nValorBase	,;
				                    				 	@nTaxaMoeda	 )
				                    EndIf
			                       Exit
			                    EndIf
			                 EndIf
			              Else
						     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						     //³Alimenta com as transacoes realizadas mas pendentes, que devem ser confirmadas posteriormente³
						     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						     If Ascan(aTEFPend,{|x| x[1] == aTEFMult[nX][1] .AND. x[2] == aTEFMult[nX][2]}) == 0
			                    AADD(aTEFPend,{aTEFMult[nX][1], aTEFMult[nX][2]})

			                    AADD(aBckTEFMult,{aTEFMult[nX][1], aTEFMult[nX][2], aTEFMult[nX][3], ;
 			                                      aTEFMult[nX][4], aTEFMult[nX][5], aTEFMult[nX][6], ;
			                                      aTEFMult[nX][7], aTEFMult[nX][8], aTEFMult[nX][9], ;
			                                      aTEFMult[nX][10], aTEFMult[nX][11] })
			                 EndIf
			              EndIf
			           Next nX
			        Else
			           lCancelaTEF   := .T.
			        EndIf
			    EndIf
			    If lCancelaTEF
					//HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef
					If TEF_lEnvDF()
						If LOJA010T("F"   			, "D"   	, NIL   		, NIL	,;
						            NIL   			, NIL   	, NIL   		, NIL	,;
						            Nil				, NIL		, NIL			, NIL	,;
						            @cOrcamen	)

							MsgAlert(STR0015) 	//"Transação TEF cancelada!"
						EndIf
						//Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef
					ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00") .OR. lTefMult
						If LOJA010T("F"    			, "N"   	, NIL   		, NIL	,;	//Antigamente esta função nao retornava verdadeiro ou falso
						             NIL   			, NIL   	, NIL   		, NIL	,;
						             Nil			, NIL		, NIL			, NIL	,;
						             @cOrcamen	)

							MsgAlert(STR0015) 	//"Transação TEF cancelada!"
						EndIf
					EndIf
			    EndIf
			Endif
		EndIf

		If !lTefOk
			If cMV_TEFPEND == "0" .OR. cTipTEF == TEF_CLISITEF
				//Foi colocado um parâmetro para determinar se o cliente utiliza ou não esta pergunta
				If !SuperGetMV("MV_TEFMANU",,.T.)
					lRet 	:= .F.
				Else
					If lSemRede
						lRet := .F.
					Else
						//"Continua Manualmente?"
						If lUsaDisplay
							LjLimpDisp()

							DisplayEnv(StatDisplay(), "1E" + STR0006)		// ### "Continua Manualmente?"
							DisplayEnv(StatDisplay(), "2E" + STR0106)		// ### "<ENTER> - Continuar"
							DisplayEnv(StatDisplay(), "3E" + STR0107)		// ### "<ESC> - Cancelar"
						Endif

						//"Continua Manualmente?"
						lRet := LojaOk(STR0006)
						LjLogFront("FRT271G - CONTINUA TEF MANUALMENTE COMO ",lRet)
						lTefManual := lRet
						lSelTefManu:= lRet

						// Limpar as mensagens do display
						LjLimpDisp()
					EndIf
				EndIf
			Else
				If cTipTef <> TEF_CLISITEF
					lTefOk := .T.
				EndIf
			EndIf

			If lUsaDisplay
				If lRet
					DisplayEnv(StatDisplay(), "1C" + STR0016 )         //"Encerrando Venda"
					DisplayEnv(StatDisplay(), "2C" + " ")
				Else
					DisplayEnv(StatDisplay(), "1E"  + STR0017 + Str(nVlrTotal,8,2) + " " + STR0019 + " 0,00"  )         //"Total: "    ""Saldo: ""
					DisplayEnv(StatDisplay(), "2C"  + STR0018 )         //"PRESSIONE <F9> P/ FECHAR A VENDA"
				EndIf
			EndIf

			lVoltar := !lRet
		EndIf

		//Funcao de tratamento do retorno do SITEF para identificacao das administradoras utilizadas (bandeiras)
		If lSelAdm .AND. (lTefOk .OR. lTefManual) .AND. cTipTEF == TEF_CLISITEF
			FR271AdmFin(@aPgtos,@aParcelas,@aTpAdms,@oTEF,;
						@nMoedaCor, /* aTefInf */, lTefManual, lSelTefManu )
			LjLogFront("FRT271G - DEPOIS DE SELECIONAR AS ADM",aPgtos)
		EndIf
	Else
		If lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo()))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela transacoes pendentes do MultiTEF Discado (se existir)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aDTEFPend := LJLoadDTEF()

			If Len(aDTEFPend) > 0
				//Incluído o tratamento para recarga de celular
				LOJA010T("F"   			, "D"   	, NIL   		, NIL	,;
				         NIL   			, NIL   	, NIL   		, NIL	,;
				         Nil			, NIL		, NIL			, NIL	,;
				         @cOrcamen	)
			EndIf
		EndIf
		
		If lUsaTef .AND. cTipTef == TEF_CLISITEF .AND. ValType(oTef:lTefOk) == "L" .AND. oTef:nCodFuncao == 838 //Valida pagameto somente com Dotz
			lTefOk := oTef:lTefOk 
		EndIf
		
	EndIf
EndIf

If lVoltar
	//³ Restaura os SetKey's do Fechamento da Venda ³
	FRTSetKey(aKey)
	Return(.F.)
EndIf

If lSelTefManu .And. ExistFunc("LjxTelaNSU")//Nao precisa fazer outras validações pois a variavel só vem .T. caso venda com cartao e Tef Manual
	For nI := 1 To Len(aParcelas)
		If Alltrim(aParcelas[nI][3]) $ _FORMATEF .AND. lUsaTef
			
			nCont := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aParcelas[nI][3])+aParcelas[nI][12]}) //Forma + ID
			
			If nCont > 0
				aNSUVndTef[nCont][3] += aParcelas[nI][2]
			Else
				Aadd(aNSUVndTef,{AllTrim(aParcelas[nI][3]),aParcelas[nI][12],aParcelas[nI][2],""}) //Forma , ID , Valor , NSU digitada
			EndIf
		EndIf
	Next nI
	
	If Len(aNSUVndTef) > 0
		For nI := 1 to Len(aNSUVndTef)
			LjGrvLog(Nil, "FR271GEncerra - Chamada da Tela para Digitação da NSU - TEF Manual")
			LjxTelaNSU(@aNSUVndTef[nI])
			LjGrvLog(Nil, "FR271GEncerra - Chamada da Tela para Digitação da NSU - Retorno:" , aNSUVndTef)
		Next nI
	EndIf
EndIf

//O tratamento de troco, para paises outros paise, é realizado através da
//função LjCalcTrc, pois devem ser consideradas múltiplas moedas
If (cPaisLoc <> "BRA") .AND. SuperGetMV("MV_LJTRLOC",,.F.)
	//PE que retorna para quais formas de pagamento pode ser gerado troco.
 	If ExistBlock("FORMSTRC")
		aAux := ExecBlock("FORMSTRC",.F.,.F.)
	Else
		//Caso nao exista o PE FORMSTRC podera ser gerado troco para todas
		//as moedas mais cheque
	    aAux := {SuperGetMV("MV_SIMB1")}
	    For nI := 2 To MoedFin()
	    	Aadd(aAux,&("MV_SIMB"+STR(nI,1)))
	    Next nI
	   	Aadd(aAux,cSimbCheq)
	EndIf

	For nI := 1 To Len(aParcelas)
		If Ascan(aAux,{|x| Trim(x) == Trim(aParcelas[nI][3])}) > 0
			nValRec += Round(xMoeda(aParcelas[nI][2],aParcelas[nI][11],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
		EndIf
	Next nI
	//So executa a rotina de troco localizada caso tenha ocorrido recebimento em
	//alguma forma valida para calculo do troco...
	If nValRec > 0
	   //Se apenas uma moeda esta ativa e o parametro MV_LJTRAUT esta setado para .T.
	   //preenche o troco automaticamente sem mostrar a tela de troco ao usuario
	   If Len(aMoeda) == 1 .AND. SuperGetMV("MV_LJTRAUT",,.T.)
	      nTroco 	:= Round(Abs(nValRec-nVlrBruto),nDecimais)
	      lTrocoPad := If(nTroco > 0,.F.,lTrocoPad)
	      aTroco 	:= {{nTroco,nTroco,0,nMoedaCor}}
	   Else
		  aTroco := LjCalcTrc("FRONT"	,nValRec,nVlrBruto	,NIL 	,;
		  						NIL		, NIL	, NIL 		,aDadosJur)
	      If ValType(aTroco) == "L"
		     If !aTroco
			    If lDinheiro
				   nDinheiro := 0
			    Else
				   nVales:= 0
			    EndIf

			    cRetorno := ' '
			    If IFStatus(nHdlECF, '5', @cRetorno ) == 7	// Verifica se tem cupom aberto.
				   lVoltar := .T.
			    EndIf
		     EndIf
	      Else
		     AEval(aTroco,{|x,y| nTroco += xMoeda(	aTroco[y][02],	aTroco[y][04],	nMoedaCor,	dDataBase,;
		     										MsDecimais(	aTroco[y][04])+1	,	,nTaxaMoeda)})
		     nTroco		:= Round(nTroco,nDecimais)
		     nEntrada	-= nTroco
             If nTroco > 0
             	lTrocoPad := .F.
             EndIf
	      EndIf
	   EndIf
	Else
	   For nI := 1 To MoedFin()
		  AAdd(aTroco,{0,0,0,nI})
	   Next nI
	   nTroco  := 0
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houver integracao com o CRD e a venda tiver sido bloqueada,³
//³ volta para a tela da venda, sem finalizar.		    		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CrdxInt()
	If !lTransCrd .AND. lVoltar
		FRTSetKey(aKey)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
		//³ Release 11.5 - Reinicializa variaveis de cartao fidelidade	  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
		If lLjcFid .AND. Fa271aGrcf ()
			LaFunhDelS ()
			Fa271aSrcf (.F.)
			Fa271aSpfw (.F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Controle de Formularios ³
		//³Zerar RECNO da especie de documento    ³
		//³fiscal escolhida no inicio da venda.   ³
		//³Paises:Chile/Colombia - F1CHI		  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCFolLocR5
			FaZerRecFo()
			cDoc := ""
		EndIf

		Return(.F.)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso tenha escolhido Dinheiro Solicita a digitacao do Troco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lDinheiro .OR. nVales > 0)  .AND. Iif(cPaisLoc <> "BRA",lTrocoPad .AND. ValType(aTroco) <> "L",.T.)
	If nTroco == 0  .OR. (nTroco > 0 .AND. lMvLjTroco )
	    // PE que retorna para quais formas de pagamento pode ser gerado troco.
		If lFrtTroco
			lGerTroco := ExecBlock("FRTTROCO", .F.,.F., {lDinheiro, nVales, aPgtos})
			If ValType(lGerTroco) <> "L" // Garante que o P.E. retornou um valor logico.
				lGerTroco := .T.
			EndIf
		Endif

	    If lGerTroco
			uRet :=  LjxDGetTroco(	GetWndDefault()	, lDinheiro	, nDinMoedaCor	, nDinheiro	,;
									nVales			, nTroco	, lUsaDisplay, @nArredondar )
			If ValType(uRet) == "L"
				If !uRet
					If lDinheiro
						nDinheiro := 0
					Else
						nVales:= 0
					EndIf
					cRetorno := ' '
					lVoltar := .T.
				EndIf
			Else
				If nTroco == 0
					lTelaTroco := .T.
				EndIf
				If 	nTroco  != uRet
					lTrocDin2 := .T.
				EndIf
				nTroco   := uRet
				If ExistFunc("Frt272Get")
					cMoedaTroc := Frt272Get()
				EndIf
				If nTroco > 0 .And. Empty(cMoedaTroc) .And. ExistFunc("Frt272Send")
					cMoedaTroc := cSimbCor 
					Frt272Send(cMoedaTroc +"|"+ AllTrim(Str(nDinheiro + nTroco)) )
				EndIf	
				If !lTrocDin2 .And. (!lMvLjTroco .Or. (lMvLjTroco .And. lMvLjTrDin == 1 .And. (Empty(cMoedaTroc) .Or. cSimbCor $ cMoedaTroc) ))
					nEntrada -= nTroco
				EndIf
				If !lTrocDin2 .And. (!lMvLjTroco .Or. (lMvLjTroco .And. lMvLjTrDin == 1 .And. (Empty(cMoedaTroc) .Or. cSimbCor $ cMoedaTroc) ))
					nDinheiro -= nTroco
				EndIf
			EndIf
		Endif
	Else
		If !lMvLjTroco
			nEntrada -= nTroco
			nDinheiro -= nTroco
		EndIf
	EndIf
EndIf

If lVoltar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso possua Troco, eh adicionado ao valor da respectiva moeda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	lTrocoAux := lTrocoPad
Else
	lTrocoAux := .T.
Endif

If (cPaisLoc == "BRA") .OR. !(SuperGetMV("MV_LJTRLOC",,.F.)) .OR. lTrocoAux

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le as formas de pagamento da venda efetuada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont := 1 To Len(aFormPag)
		If aTotForm[nCont] > 0
			If lMvLjTroco .And. lTrocDin2 .And. AFormPag[nCont][2] == cSimbCor
				//Atualiza os arrays e variaveis de pagamentos

				nPosDin := aScan(aPgtos,{|x| IsMoney(x[3])})				//Atualiza aPgtos
				If nPosDin > 0
					aPgtos[nPosDin][2] += nTroco
					nPosDin := aScan(aParcelas, {|x| IsMoney(x[3]) })  	//Atualiza aParcelas
					If nPosDin > 0
						aParcelas[nPosDin][2] += nTroco
					EndIf
				EndIf
				// Caso a forma de pagamento que carrega o troco seja dinheiro, somar o valor do troco nas variaveis relevantes
				If lMvLjTrDin == 0 .And. (IsMoney(aFormPag[nCont][2]))
					nDinheiro	+= nTroco
					nEntrada	+= nTroco
				EndIf
				aTotForm[nCont] += nTroco
			ElseIf aFormPag[nCont][2] == "VA" // Vales

				//³A agregacao do troco ao valor total da condicao de pagamento³
				//³so podera ser feita caso seja diferente de Dinheiro, o campo³
				//³L1_TROCO1 nao esteja cadastro na base de dados e o          ³
				//³parametro MV_LJTROCO esteja com F (false)                   ³
				If !lDinheiro .AND. !( SuperGetMV( "MV_LJTROCO", ,.F. ) )
					aTotForm[nCont] += nTroco
				Endif
			Endif
		Endif
	Next nCont
Endif

/* Retorna a forma de pagamento que gerou o troco
 Quando o parametro MV_LJPGTRO está em branco só a forma $ pode dar troco
 portanto só altero se o param estiver preenchido */
If lLJPGTRO .And. !IsMoney(cMV_LJPGTRO)  			
	cMoedaTroc :=  F271GReord("",aFormPag,aTotForm,cMV_LJPGTRO)	
Else
	cMoedaTroc :=  cSimbCor
EndIf 

If !lTouch
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe a imagem FRTWIN , caso nao possua apresenta a LOJAWIN³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oFotoProd:ExistBmp("FRTWIN")
		cFotoProd := "FRTWIN"
	EndIf
	If oFotoProd:cBMPFile <> cFotoProd
		ShowBitMap(oFotoProd,cFotoProd)
	EndIf

Endif

//Tratamento para impressão de acrescimo quando não incide juros sobre ICMS na multinegociação no cupom virtual
lIcmjr := lIcmjr .And. Len(aParcOrc) > 0 .And. ValType(aParcOrc[1,13]) == "N"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esta utilizando NCC na venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFrontNCC
	LjLogFront("FRT271G - VALOR PAGO EM NCC",nValCredito)
 	If Frt060Ret("NCC_USADA") > 0
		oCupom:AppendText((STR0032 + Trans(abs(Frt060Ret("NCC_USADA")),PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13)) // "   A B A T. C R E D I T O"
 		nValCredito	:= Abs(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA"))
 		nVlrTMsg := (nVlrTotal + nValCredito )
	Else
   		nVlrTMsg := nVlrTotal
	EndIf
Else
	nVlrTMsg := nVlrTotal
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma o Juros da Administradora ao array aDadosJur[1]  ³
//³Esse array e utilizado para impressao do acrescimo qdo³
//³nao for Brasil                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTxJurAdm) > 0
	If (lMvLJurCc) .AND. (aTxJurAdm[1] > 0) .AND. (cPaisLoc <> "BRA")
		aDadosJur[1] += aTxJurAdm[3]
	EndIf
EndIf

If nVlrTMsg > (nVlrBruto + nValCredito)
	oCupom :AppendText((STR0007+Trans(If(cPaisLoc=="BRA",nVlrTMsg-nVlrBruto,aDadosJur[1]),PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13))	// "     A C R E S C I M O   "
	lSubTot := .T.
ElseIf nVlrTMsg < nVlrBruto .AND. !Frt060Ret("NCC_MENOR")
	oCupom:AppendText((STR0008+Trans(If(cPaisLoc=="BRA",nVlrBruto-nVlrTMsg,aDadosJur[9]),PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	+ chr(10) + chr(13)) // "     D E S C O N T O     "
	lSubTot := .T.
EndIf

If lSubTot .AND. (cPaisLoc <> "BRA")
	AEval(aImpsSL1,{|x,y| nTotImp += aImpsSl1[y][3]})
	oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
	oCupom:AppendText((STR0005+Trans(nVlrTotal-nTotImp,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))) + chr(10) + chr(13))  //"     S U B T O T A L      "
	aAreaSFB := SFB->(GetArea())
	SFB->(DbSetOrder(1))
	For nI := 1 To Len(aImpsSL1)
		SFB->(DbSeek(xFilial("SFB")+aImpsSL1[nI][1]))
		oCupom:AppendText((Space(05)+SubStr(SFB->FB_DESCR,1,10)+Space(11)+Trans(aImpsSL1[nI][3],PesqPict("SL1",aImpsSL1[nI][2],13,nMoedaCor))) + chr(10) + chr(13))
	Next nI
	RestArea(aAreaSFB)
	nTotImp := 0
EndIf
oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
If Frt060Ret("NCC_MENOR")
 	oCupom:AppendText((STR0009+Trans(nVlrTMsg,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13))	// "     T O T A L           "
Else
	oCupom:AppendText((STR0009+Trans(nVlrTotal,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13))	// "     T O T A L           "
Endif

nX	:= 0

For nI := 1 To Len(aFormPag)
	If aTotForm[nI] > 0
		cFormPagto := IIF(nLjpagto == 1, aFormPag[nI, 3], aFormPag[nI, 1])
		If lUsaTef .AND. cTipTef == TEF_CLISITEF
			If !(Upper(aFormPag[nI, 2]) $ _FORMATEF) .OR. !lTefOk .OR. !lUsaTef
				oCupom:AppendText(("     "+PadR(cFormPagto, 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor))) + chr(10) + chr(13))
			Else
				++nX
				If nLjPagto == 1
					oCupom:AppendText(("     "+PadR(AllTrim(Upper(RetDescri(oTef:aRetCartao[nX]:cForma))) ,20)+Trans(oTef:ARETCARTAO[nX]:NVLRTRANS,PesqPict("SE1","E1_VALOR",14,nMoedaCor))) + chr(10) + chr(13))
			    Else
					oCupom:AppendText(("     "+PadR(oTef:aRetCartao[nX]:cDescadm, 20)+Trans(oTef:ARETCARTAO[nX]:NVLRTRANS,PesqPict("SE1","E1_VALOR",14,nMoedaCor))) + chr(10) + chr(13))
				EndIf
			EndIf
		Else
			If !(Upper(aFormPag[nI, 2]) $ _FORMATEF) .OR. !lTefOk .OR. !lUsaTef
				oCupom :AppendText(("     "+PadR(cFormPagto, 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor))) + chr(10) + chr(13))
			Else
				++nX
				If nLjpagto==1
					oCupom:AppendText(("     "+PadR(Upper(aFormPag[nI][3]),20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor))) + chr(10) + chr(13))
				Else
					If lTefMult .And. (Len(aTefMult) > 0)
						oCupom:AppendText(("     "+PadR(aTefMult[nI][7][1][8], 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor))) + chr(10) + chr(13))
					Else
						oCupom:AppendText(("     "+PadR(aTefDados[nX][8], 20)+Trans(aTotForm[nI],PesqPict("SE1","E1_VALOR",14,nMoedaCor))) + chr(10) + chr(13))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nI

// Realiza o calculo do troco para as diferentes condicoes de pagamento F5
If lMvLjTroco .AND. cItemCond <> "CN" .Or. lLJPGTRO
	For nCtd := 1 to Len(aPgtos)
		nTotReceb +=  aPgtos[nCtd][2]
	Next nCtd
	If nTotReceb > nVlrTotal
		nTroco  := nTotReceb - nVlrTotal
		nTroco2 := nTroco
	EndIf
EndIf
// Array aReserva esta no if para garantir cenario do cliente, sendo que o orcamento tera que ter item reservado
If lMvLjTroco .And. nTroco > 0 .And. nTroco2 == 0 .And. Len(aReserva) > 0
	nTroco2 := nTroco
Endif

oCupom :AppendText((chr(10) + chr(13)))
If lFrontNCC .AND. Frt060Ret("NCC_MENOR")
	If (cPaisLoc == "BRA") .OR. If(cPaisLoc <> "BRA",lTrocoPad,.T.)
		oCupom:AppendText((STR0010+Trans(nVlrTMsg+nTroco,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13)) 	// "     VALOR RECEBIDO      "
	ElseIf (cPaisLoc <> "BRA") .AND. SuperGetMV("MV_LJTRLOC",,.F.)
		nPos := AScan(aTroco, {|x| x[4]==nMoedaCor})
		oCupom:AppendText((STR0010+Trans(nVlrTMsg+aTroco[nPos][01],PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13))	// "     VALOR RECEBIDO      "
	EndIf
Else
	If (cPaisLoc == "BRA") .OR. If(cPaisLoc <> "BRA",lTrocoPad,.T.)
		oCupom:AppendText((STR0010+Trans(nVlrTotal+nTroco,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))	 + chr(10) + chr(13)) // "     VALOR RECEBIDO      "
	ElseIf (cPaisLoc <> "BRA") .AND. SuperGetMV("MV_LJTRLOC",,.F.)
		nPos := AScan(aTroco, {|x| x[4]==nMoedaCor})
		oCupom:AppendText((STR0010+Trans(nVlrTotal+aTroco[nPos][01],PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))+ chr(10) + chr(13))	// "     VALOR RECEBIDO      "
	EndIf
Endif

If nTPCompNCC  == 4 .AND. Abs(Frt060Ret("NCC_USADA")) > nVlrTotal
	nTroco  := nTroco2 := Abs(Frt060Ret("NCC_USADA")) - (nVlrTotal + ( Abs(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA") ) ) )
EndIf
If nTroco > 0
	oCupom:AppendText((STR0011+Transform(nTroco,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13))	// "          TROCO          "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibir Mensagem de Troco no Display ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgDisplay(7, {nTroco})
EndIf

//Tratamento para impressão de acrescimo quando não incide juros sobre ICMS na multinegociação no cupom virtual
If lIcmjr
	nVlrTotal -= nVlAcrMultNeg
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes		                                                     ³
//³                                                                                      ³
//³Validar o numero/serie do formulario escolhido pelo usuario no inicio da venda.  	 ³
//³Caso o usuario nao tenha feito, utilizar a serie informada no parametro MV_LOJANF.    ³
//³Se o parametro estiver vazio, exibir a tela para que usuario escolha a serie desejada ³
//³direto da tabela 01(Series de notas fiscais) do SX5.                                  ³
//³                                                                                      ³
//³Paises: Chile/Colombia - F1CHI/F2CHI                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc$"CHI|COL"

	LjxDadosFo (FaGetRecFo(),NIL,NIL,NIL,@cSerieFo)

	If Empty(cSerieFo)
		cSerieFo := PadR(If(SubStr(cLojaNF,1,1)=="&",&(SubStr(cLojaNF,2,Len(cLojaNF))),cLojaNF), nTamSerie)
	EndIf

	nMaxItens := SuperGetMv("MV_SER"+cSerieFo,.F.,SuperGetMv("MV_NUMITEN"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula a quantidade de notas a serem geradas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotItens > nMaxItens
		nQtdeNotas := Int(nTotItens / nMaxItens) + If(Mod(nTotItens,nMaxItens) > 0,1,0)
	Else
		nQtdeNotas := 1
	EndIf

	If LjxDNota(cSerieFo	,2		,.F.	,nQtdeNotas,;
				@aNumPed	,cDoc 	, NIL	, NIL, ;
              		NIL     ,NIL    , NIL   , .F., ;
              		NIL		,NIL	, cDocFo)

		cDoc := aNumPed[1][2]


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizando o SL2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nItens := 0
		DbSelectArea("SL2")
		If DbSeek(xFilial("SL2")+SL1->L1_NUM)
			While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. !SL2->(EOF())
				aSL2 := {	{	"L2_DOC"	, SL1->L1_DOC     },;
							{	"L2_SERIE"	, SL1->L1_SERIE   }}
				FR271BGeraSL("SL2", aSL2, .F.)
				SL2->(DbSkip())
			End
	    EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluir nota e serie no array aBreakNota para controle de quebra de nota ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SL2")
		If DbSeek(xFilial("SL2")+SL1->L1_NUM)
			nX:= 1
			While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. !SL2->(EOF())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se ja atingiu o numero maximo de itens, pula para a proxima factura³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nX <= Len(aNumPed)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Adicionar no array aBreakNota as facturas que serao impressas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					LjAddBrkNF (@aBreakNota	,@aItensBrk	,SL2->L2_ENTREGA	,aNumPed[nX][2],;
									aNumPed[nX][1])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Adicionar no array aItensBrk os respectivos itens de cada factura³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					LjAddBrkIt (@aBreakNota	,@aItensBrk	,SL2->L2_ENTREGA	,aNumPed[nX][2],;
			        				aNumPed[nX][1]	,SL2->(Recno()))
			   		nItens++
			   		If nItens >= nMaxItens
						nX++
						nItens := 0
					EndIf
			   	EndIf

			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar os itens que serao incluidos   	³
				//³no comprovante de acordo com  tipo de entrega³
				//³especifico parra cada localizacao 			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   		Do Case
					Case cPaisLoc == "CHI"
						If SL2->L2_ENTREGA == "1"
							//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Comprovante³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
							lImpCNFLoc := .T.
						Else
					   		//ÚÄÄÄÄÄÄÄÄÄ¿
							//³ Factura ³
							//ÀÄÄÄÄÄÄÄÄÄÙ
							aSL1 := {{"L1_DOC",aNumPed[1][2]},;
					 					{"L1_SERIE",aNumPed[1][1]}}

							FR271BGeraSL("SL1", aSL1, .F.)
						EndIf
					Case cPaisLoc == "COL"
						If SL2->L2_ENTREGA $ "1|3"
							lImpCNFLoc := .T.
						Else
							//ÚÄÄÄÄÄÄÄÄÄ¿
							//³ Factura ³
							//ÀÄÄÄÄÄÄÄÄÄÙ
							aSL1 := {{"L1_DOC",aNumPed[1][2]},;
					 					{"L1_SERIE",aNumPed[1][1]}}

							FR271BGeraSL("SL1", aSL1, .F.)

						EndIf
				EndCase

			   SL2->(DbSkip())
			End
		EndIf

	Else
		// "Ocorreu um erro ao recuperar a série da Nota Fiscal, verificar os parâmetros da série (MV_LOJANF), (MV_SERIE). A NF não será gravada.", "Atenção"
		HELP(' ',1,'ERROSERIE')
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return (.F.)
	EndIf
EndIf

/*            Lei de Olho no Imposto / Transparencia 12741              */
dbSelectArea("SL2")
SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
While SL2->( !Eof() ) .AND. SL2->(xFilial("SL2") + SL1->L1_NUM == L2_FILIAL+L2_NUM )

	nTotImpNCM 		+=SL2->L2_TOTIMP
	nTotVLRNCM 		+=SL2->L2_VLRITEM  //total dos itens

	//gravacao dos valores lei dod impostos por ente tributario
	nTotImpFED		+=SL2->L2_TOTFED
	nTotImpEST		+=SL2->L2_TOTEST
	nTotImpMUN		+=SL2->L2_TOTMUN

	SL2->(dbSkip())
End

nTotDesp := SL1->L1_DESPESA + SL1->L1_SEGURO

// Tratamento Desconto no Total
If nVlrPercTot > 0
	nTotImpNCM -= Round((nVlrPercTot * nTotImpNCM)/100,nDecimais)
	IF nTotVLRNCM >= nVlrDesctot
		nTotVLRNCM-= nVlrDesctot
	EndIf

	nTotImpFED -= Round((nVlrPercTot * nTotImpFED)/100,nDecimais)
	IF nTotVLRFED >= nVlrDesctot
		nTotVLRFED-= nVlrDesctot
	EndIF

	nTotImpEST -= Round((nVlrPercTot * nTotImpEST)/100,nDecimais)
	IF nTotVLREST >= nVlrDesctot
		nTotVLREST-= nVlrDesctot
	EndIF

	nTotImpMUN -= Round((nVlrPercTot * nTotImpMUN)/100,nDecimais)
	IF nTotVLRMUN >= nVlrDesctot
		nTotVLRMUN-= nVlrDesctot
	EndIF
EndIf

// Tratamento Acrescimo Financeiro
If nTmpJuros > 0
	nTotImpNCM += Round((nTmpJuros * nTotImpNCM)/100,nDecimais)
	nTotVLRNCM += nVlrAcreTot - IIf(nTotDesp > 0 ,nTotDesp ,0)  // retira o frete porque na importação o frete esta no valor de acrescimo

	nTotImpFED += Round((nTmpJuros * nTotImpFED)/100,nDecimais)
	nTotVLRFED += nVlrAcreTot - IIf(nTotDesp > 0 ,nTotDesp ,0)  // retira o frete porque na importação o frete esta no valor de acrescimo

	nTotImpEST += Round((nTmpJuros * nTotImpEST)/100,nDecimais)
	nTotVLREST += nVlrAcreTot - IIf(nTotDesp > 0 ,nTotDesp ,0)  // retira o frete porque na importação o frete esta no valor de acrescimo

	nTotImpMUN += Round((nTmpJuros * nTotImpMUN)/100,nDecimais)
	nTotVLRMUN += nVlrAcreTot - IIf(nTotDesp > 0 ,nTotDesp ,0)  // retira o frete porque na importação o frete esta no valor de acrescimo
EndIf

// Tratamento Desconto Financeiro
If nVlrDescCpg > 0
	If lImporc .AND. nTmpDesc ==0
		nTmpDesc :=  Round((nVlrDescCpg+ IIf(nTotDesp > 0 ,nTotDesp ,0))/nTotVLRNCM ,ndecimais) * 100

		//reparticionado em ente tributario
		nTmpDescFED:=  Round((nVlrDescCpg+ IIf(nTotDesp > 0 ,nTotDesp ,0))/nTotVLRFED ,ndecimais) * 100
		nTmpDescEST:=  Round((nVlrDescCpg+ IIf(nTotDesp > 0 ,nTotDesp ,0))/nTotVLREST ,ndecimais) * 100
		nTmpDescMUN:=  Round((nVlrDescCpg+ IIf(nTotDesp > 0 ,nTotDesp ,0))/nTotVLRMUN ,ndecimais) * 100
	ENdIf

	nTotImpNCM -= Round((nTmpDesc * nTotImpNCM)/100,nDecimais)
	nTotVLRNCM -= nVlrDescCpg+  IIf(nTotDesp> 0 ,nTotDesp ,0)  // Adiciona o frete porque na importação o frete nao esta no valor de desconto
	nTotVLRFED -= nVlrDescCpg+  IIf(nTotDesp> 0 ,nTotDesp ,0)  // Adiciona o frete porque na importação o frete nao esta no valor de desconto
	nTotVLREST -= nVlrDescCpg+  IIf(nTotDesp> 0 ,nTotDesp ,0)  // Adiciona o frete porque na importação o frete nao esta no valor de desconto
	nTotVLRMUN -= nVlrDescCpg+  IIf(nTotDesp> 0 ,nTotDesp ,0)  // Adiciona o frete porque na importação o frete nao esta no valor de desconto
EndIf

// Tratamento Frete
If SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA > 0
	nTotImpNCM += Round( (nTotDesp/nTotVLRNCM )*nTotImpNCM ,nDecimais)
	nTotVLRNCM +=  nTotDesp
	nTotVLRFED += Round( (nTotDesp/nTotVLRFED )*nTotImpNCM ,nDecimais)
	nTotVLREST += Round( (nTotDesp/nTotVLREST )*nTotImpNCM ,nDecimais)
	nTotVLRMUN += Round( (nTotDesp/nTotVLRMUN )*nTotImpNCM ,nDecimais)
EndIf


nValFecp := F271GFECP( cCliente, cLojaCli, cTipoCli, nVlrDesctot, nVlrAcreTot, lUseSAT )

//************************************************************************************************************/
//HOMOLOGACAO PAF-ECF 2013
//a Ordem das Mensagens Impressas deve ser:
// 1 - MD5 ; 2 - Msg do TPL PCL ou DAV/PRE-VENDA XXXXX ; 3 - Msgs dos Estados (Minas Legal, etc.)
// 4 - mensagens adicionais
//************************************************************************************************************/
If LjNfPafEcf(SM0->M0_CGC) .AND. !Empty(cNumDAV)
	If lPreVenda
		cMsgCupom := "PV"+AllTrim(cNumDAV)+CRLF
	Else
		cMsgCupom := "DAV"+AllTrim(cNumDAV)+CRLF
	EndIf
EndIf

//Verifica se deve imprimir mensagem "MINAS LEGAL" de Minas Gerais
cMsgCupom	+=	Lj950MinasL(nVlrTotal,nDecimais)

//Verifica se deve imprimir mensagem "PARAIBA LEGAL" da Paraíba
cMsgCupom	+=	Lj950PBLeg(nVlrTotal,nDecimais,cCliCGC)

//Verifica se deve imprimir mensagem "Nota Legal" do Distrito Federal para evitar looping desnecessario no aItens
If LJAnalisaLeg(62)[1]
	nTotICMS	:= 0								//acumula valor de icms dos produtos
	nTotISS		:= 0								//acumula valor de iss dos produtos

	For nX := 1 to Len( aItens )
		If Substr(aItens[nX][AIT_ALIQUOTA],1,1) == "T"
			nTotICMS  += aItens[nX][AIT_VLRITEM] * ( Val(Substr(aItens[nX][AIT_ALIQUOTA],2,Len(aItens[nX][AIT_ALIQUOTA]))) / 100 )
		ElseIf Substr(aItens[nX][AIT_ALIQUOTA],1,1) == "S"
			nTotISS  += aItens[nX][AIT_VLRITEM] * ( Val(Substr(aItens[nX][AIT_ALIQUOTA],2,Len(aItens[nX][AIT_ALIQUOTA]))) / 100 )
		EndIf
	Next nX

	cMsgCupom	+= IIF(Empty(AllTrim(cMsgCupom)),"", cEOF) + Lj950NotaL( nTotICMS , nTotISS , nDecimais )
EndIf

//Verifica deve imprimir mensagem "de Olho no Imposto"
cMsgNCM	:=	Lj950ImpNC(nTotVLRNCM,nTotImpNCM,nDecimais,/*lNFCe*/,nTotImpFED,nTotImpEST,nTotImpMUN)

If ExistBlock("LJ7078")
	cMsgNCM  := SubStr( ExecBlock("LJ7078",.F.,.F.,{nTotVLRNCM,nTotImpNCM,nTotImpFED,nTotImpEST,nTotImpMUN}),1,56)
EndIf

cMsgCupom	+=	cMsgNCM

// Impressao da mensagem referente ao FECP
If ExistFunc("Lj950FECP")
	cAuxMsgCup := AllTrim(Lj950FECP(nValFecp))
	If !Empty(cAuxMsgCup)
		cMsgCupom	+= cAuxMsgCup + Chr(10)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um sinal de & (macro substituicao), dessa forma³
//³possibilita ao usuario montar um parametro o qual seja executada  ³
//³uma condicional.                                                  ³
//³Foi necessario fazer dessa forma, pois caso contrario acarretaria ³
//³erro na base de clientes ja implantada.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAuxMsgCup := AllTrim(SuperGetMV("MV_LJFISMS",,""))
If Empty(AllTrim(cAuxMsgCup))
	cAuxMsgCup := AllTrim(SLG->LG_MSGCUP) + cEOF
EndIf

cAuxMsgCup	:= If( Substr(cAuxMsgCup,1,1)=="&", &(Substr(cAuxMsgCup,2,Len(cAuxMsgCup))) + cEOF, cAuxMsgCup)
cMsgCupom	+= cAuxMsgCup

//Efetua backup e remocao das tags para mostrar o texto normalmente e evitar problemas de visualizacao
cAuxMsgCup := cMsgCupom

If ExistFunc("RemoveTags")
	cAuxMsgCup := RemoveTags(cAuxMsgCup)
EndIf

aMensagem	:= Fr271IMsgTela(cAuxMsgCup)

oCupom:AppendText((chr(10) + chr(13)))
oCupom:AppendText((chr(10) + chr(13)))
For nI := 1 to Len(aMensagem)
    oCupom :AppendText((aMensagem[nI]) + chr(10) + chr(13))
Next nI
oCupom:AppendText((chr(10) + chr(13)))
oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0003+PadR(cPDV,4)+STR0004+cDoc) + chr(10) + chr(13))	// "  PDV:" "   COD:"
oCupom:AppendText((chr(10) + chr(13)))

If lEmitNfce .And. !lUseSAT
	oCupom:AppendText((STR0112) + chr(10) + chr(13)) // "NFC-E Transmitida com Sucesso!"
EndIf

oCupom:AppendText(("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^") + chr(10) + chr(13))
oCupom:GoEnd()
oCupom:Refresh()

nX := 0
cFormaPagto := ""

If lGE
	nVlrGar := F271GGEc(@aItens, @nPosGe)
	LjLogFront("FRT271G - VENDA COM GARANTIA ")
	LjLogFront("FRT271G - VALOR DA GARANTIA",nVlrGar)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³				                 FRETE								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SL1->L1_TPFRET <> "S" .AND. (SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA) > 0
	nFrete		:= SL1->L1_FRETE
	nSeguro		:= SL1->L1_SEGURO
	nDespesa	:= SL1->L1_DESPESA
	nValorFSD	:= nFrete + nSeguro + nDespesa
	nFreteFat 	:= (nValorFSD / nVlrTotRe)
	
	If nVlrAcreTot > 0 .And. Len(aReserva) > 0
		nVlrAcreTot -= nValorFSD
	EndIf
EndIf

//Tratamento para identificar proporção do valor de desconto do item nao fiscal 
If nVlrDescTot > 0 .And. nDescToP == 0 .And. Len(aReserva) > 0
	nDescToP := nVlrDescTot * (nVlrTotRe / (nVlrTotal + nValCredito + nVlrDescTot - nValorFSD))	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta FORMAS DE PAGAMENTO que serão enviadas para a impressora.³
//³No caso do CR tem que ser enviado primeiro para imrpessora	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFrontNCC
	If Frt060Ret("NCC_USADA") > 0
		//	Proteção para os casos em que os descontos deixam somente o frete para ser pago pela Ncc,
		//	a Variavel nVlrDescTot, vem zerada e para correção das impressões populamos ela com o valor correto.
		If (nVlrDescTot <= 0 )
			nVlrDescTot := Frt060RET("060_VLRDESC")
		EndIf
		If nVlrTotal > 0 .OR. (nVlrTotal = 0 .AND. Len(aReserva) > 0 )
			cFormaPagto += AllTrim(Tabela("24","CR",.F.)) + '|' + AllTrim(Str(Round( nValCredito*A271FatRes(aReserva, ((nVlrTotal + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1] ,nDecimais),14,2)) + '|'  				
		Else
			cFormaPagto += AllTrim(Tabela("24","CR",.F.)) + '|' + AllTrim(Str(nValCredito,14,2)) + '|'
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Proporcinaliza o desconto no item de garantia para uso        .³
//³nos calculos de pagamento                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aItProdGar)
	aItProdGar[nX][4] := Val(aItProdGar[nX][3])/(nVlrTotal + nValCredito + nVlrDescTot)  // Valor que representa esta garantia no Total d venda
	aItProdGar[nX][5] := (nVlrDescCPg + nVlrDescTot + nTotDedIcms) * aItProdGar[nX][4]  // Valor que representa o desconto desta garantia no Total d venda

	nValDescGar += aItProdGar[nx][5]
	nValAcresGar+= aItProdGar[nx][6]

Next nX

nX := 0 

/*   Para o troco não ser impresso no cupom fiscal em vendas com retira e entrega
   Antes de se montar a string que se envia  os pagamentos a impressora		*/
If nTroco > 0 .And. cMoedaTroc == aFormPag[Len(aTotForm), 2]  .And. (!lMvLjTroco .or. (lMvLjTroco .And. Len(aReserva) > 0))
	aTotForm[Len(aFormPag)] -= Iif(lMvLjTrDin == 1,0,ntroco) //Deduz o valor de troco para não imrimir no cupom fiscal 
EndIf

/* Utilizado na homologação do Tef Discado, para obrigar que a forma
de pagamento CARTAO saia impressa por ultimo no cupom fiscal.    */
nAux:= 0

If lUsaTef .AND. cTipTef == TEF_DISCADO
	nI	:= Len(aFormPag)

	While nI >= 1
		If aTotForm[nI] > 0
			If !(Upper(aFormPag[nI, 2]) $ _FORMATEF) .OR. !lTefOk .OR. !lUsaTef

				cFormPagto := IIF(nLjpagto == 1, aFormPag[nI, 3], aFormPag[nI, 1])

				If Len(aReserva) > 0
	   				cFormaPagto += cFormPagto + "|" + AllTrim(Str(Round((aTotForm[nI] )*A271FatRes(aReserva, (nVlrTotal- nValorFSD + nValCredito + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,,nValorFSD)[1] , nDecimais),14,2)) + '|'
	   			ElseIf lTemServic
	   				cFormaPagto += cFormPagto + "|" + AllTrim(Str(Round((aTotForm[nI] )*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,,nValorFSD)[1] , nDecimais),14,2)) + '|'
				Else
					cFormaPagto += cFormPagto + "|" + AllTrim(Str(aTotForm[nI],14,2)) + '|'
				EndIf
			Else
				++nX
				If nLjpagto == 1
					If Len(aReserva) > 0
						cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(Round((aTotForm[nI] )*A271FatRes(aReserva, (nVlrTotal- nValorFSD  + nValCredito + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,,nValorFSD)[1] , nDecimais),14,2)) + '|'
					ElseIf lTemServic
						cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(NoRound((aTotForm[nI] )*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1] , nDecimais),14,2)) + '|'
					Else
						cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
					EndIf
				Else
					If lTefMult .And. (Len(aTefMult) > 0 )
						If Len(aReserva) > 0
							cFormaPagto += aTefMult[nX][7][1][8] + '|' + AllTrim(Str(Round((aTotForm[nI] )*A271FatRes(aReserva, (nVlrTotal- nValorFSD  + nValCredito + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,,nValorFSD)[1], nDecimais),14,2)) + '|'
						ElseIf lTemServic
							cFormaPagto += aTefMult[nX][7][1][8] + '|' + AllTrim(Str(NoRound((aTotForm[nI] )*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1], nDecimais),14,2)) + '|'
						Else
							cFormaPagto += aTefMult[nX][7][1][8] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
						EndIf
					Else
					    nAux += 1
						If Len(aReserva) > 0
							cFormaPagto += aTefDados[nAux, 8] + '|' + AllTrim(Str(Round((aTotForm[nI])*A271FatRes(aReserva, (nVlrTotal- nValorFSD  + nValCredito + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,,nValorFSD)[1], nDecimais),14,2)) + '|'
						ElseIf lTemServic
							cFormaPagto += aTefDados[nAux, 8] + '|' + AllTrim(Str(NoRound((aTotForm[nI])*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1], nDecimais),14,2)) + '|'
						Else
							cFormaPagto += aTefDados[nAux, 8] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
						EndiF
					EndIf
				EndIf
			EndIf
		EndIf
		nI := nI - 1
	End
Else
	For nI := 1 To Len(aFormPag)
		If aTotForm[nI] > 0
			If cTipTef == TEF_CLISITEF
				If !(Upper(aFormPag[nI, 2]) $ _FORMATEF)  .OR. !lTefOk .OR. !lUsaTef

					cFormPagto := IIF(nLjpagto == 1, aFormPag[nI, 3], aFormPag[nI, 1])

					If Len(aReserva) > 0
						If nValorFSD > 0 .And. nVlrDescTot > 0	// Vendas com Desconto no total, Reserva e frete
   							cFormaPagto += cFormPagto + "|" + AllTrim(Str(Max(Round((aTotForm[nI])*A271FatRes(aReserva, ((nVlrTotal  + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1] , nDecimais),nValMin),14,2)) + '|' 			
						Else
   							cFormaPagto += cFormPagto + "|" + AllTrim(Str(Max(Round((aTotForm[nI])*A271FatRes(aReserva, (nVlrTotal- nValorFSD  + nValCredito + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,,0)[1] , nDecimais),nValMin),14,2)) + '|'
						EndIf   								   					
	   				ElseIf lTemServic
	   					cFormaPagto += cFormPagto + "|" + AllTrim(Str(Max(Round((aTotForm[nI] )*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1] , nDecimais),nValMin),14,2)) + '|'
	   				Else
						cFormaPagto += cFormPagto + "|" + AllTrim(Str(aTotForm[nI],14,2)) + '|'
	   				EndIf
	            Else
					++nX
					If nLjpagto==1
						If Len(aReserva) > 0
		 					cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(Max(Round((aTotForm[nI])*A271FatRes(aReserva, ((nVlrTotal  + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1]  , nDecimais),nValMin),14,2)) + '|'
						ElseIf lTemServic
							cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(Max(Round((aTotForm[nI])*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1] , nDecimais),nValMin),14,2)) + '|'
						Else
							cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
						EndIf
					Else
						If Len(aReserva) > 0
							cFormaPagto += oTef:aRetCartao[nX]:cDescadm + '|' + AllTrim(Str(Max(Round((aTotForm[nI] )*A271FatRes(aReserva, ((nVlrTotal  + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1]  , nDecimais),nValMin),14,2)) + '|'
						ElseIf lTemServic
							cFormaPagto += oTef:aRetCartao[nX]:cDescadm + '|' + AllTrim(Str(Max(Round((aTotForm[nI] )*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1] , nDecimais),nValMin),14,2)) + '|'
						Else
							cFormaPagto += oTef:aRetCartao[nX]:cDescadm + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
						Endif
					EndIf
				EndIf
			Else
				If !(Upper(aFormPag[nI, 2]) $ _FORMATEF) .OR. !lTefOk .OR. !lUsaTef
					cFormPagto := IIF(nLjpagto == 1, aFormPag[nI, 3], aFormPag[nI, 1])
					If Len(aReserva) > 0
						If lLj7Arred
							cFormaPagto += cFormPagto + "|" + AllTrim(Str(Max(Lj7Arred(1,4, aTotForm[nI]*A271FatRes(aReserva, ((nVlrTotal  + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1] ),nValMin),14,2)) + '|' 
						Else
							cFormaPagto += cFormPagto + "|" + AllTrim(Str(Max(NoRound(aTotForm[nI]*A271FatRes(aReserva, (nVlrTotal - nValorFSD  + nValCredito + nVlrDescTot) - nVlrAcreTot,nVlrTotRe,,nValorFSD)[1] , nDecimais),nValMin),14,2)) + '|'
						EndIf
					ElseIf lTemServic
						cFormaPagto += cFormPagto + "|" + AllTrim(Str(Max(NoRound((aTotForm[nI]- nValorFSD )*A271FatSrv(nVlrItServ, (nVlrTotal - nValorFSD  + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1] , nDecimais),nValMin),14,2)) + '|'
					Else
						cFormaPagto += cFormPagto + "|" + AllTrim(Str(aTotForm[nI],14,2)) + '|'
					EndIf
			    Else
					++nX
					If nLjpagto == 1
						If Len(aReserva) > 0
							cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(Max(Round(aTotForm[nI]*A271FatRes(aReserva, ((nVlrTotal  + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1] , nDecimais),nValMin),14,2)) + '|' 
						ElseIf lTemServic
							cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(Max(NoRound((aTotForm[nI] )*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1] , nDecimais),nValMin),14,2)) + '|'
						Else
							cFormaPagto += aFormPag[nI][3] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
						EndIf
					Else
						If lTefMult
							If Len(aReserva) > 0
								cFormaPagto += aTefMult[nX][7][1][8] + '|' + AllTrim(Str(Max(Round((aTotForm[nI] )*A271FatRes(aReserva, ((nVlrTotal  + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1], nDecimais),nValMin),14,2)) + '|'
							ElseIf lTemServic
								cFormaPagto += aTefMult[nX][7][1][8] + '|' + AllTrim(Str(Max(NoRound((aTotForm[nI] )*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1], nDecimais),nValMin),14,2)) + '|'
							Else
								cFormaPagto += aTefMult[nX][7][1][8] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
							EndIf
						Else
						    nAux += 1
							If Len(aReserva) > 0
								cFormaPagto += aTefDados[nAux, 8] + '|' + AllTrim(Str(Max(Round((aTotForm[nI])*A271FatRes(aReserva, ((nVlrTotal  + nValCredito )-nVlrAcreTot),((nVlrTotRe - nDescToP) + nValorFSD),,0)[1], nDecimais),nValMin),14,2)) + '|'
							ElseIf lTemServic
								cFormaPagto += aTefDados[nAux, 8] + '|' + AllTrim(Str(Max(NoRound((aTotForm[nI])*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot),nVlrTotRe,,nValorFSD)[1], nDecimais),nValMin),14,2)) + '|'
							Else
								cFormaPagto += aTefDados[nAux, 8] + '|' + AllTrim(Str(aTotForm[nI],14,2)) + '|'
							EndiF
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta as variaveis com os valores pagos no cupom fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAbreCup .Or. lEmitNfce // Caso tenha itens no cupom fiscal.
	// Tef		
	For nI := 1 To Len(aFormPag)
		If aTotForm[nI] > 0	// Separa o valor das formas que sao TEF 
			If Len(aReserva) > 0
				nValPag := Val(AllTrim(Str(Round((aTotForm[nI])*A271FatRes(aReserva, (nVlrTotal + nValCredito )-nVlrAcreTot,((nVlrTotRe - nDescToP) + nValorFSD))[1]-(nValDescGar * aTotForm[nI]) , nDecimais),14,2)))
			Else
				nValPag := Val(AllTrim(Str(Round((aTotForm[nI])*A271FatRes(aReserva, (nVlrTotal- nValorFSD + nValCredito  + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,,nValorFSD)[1]-(nValDescGar * aTotForm[nI]) , nDecimais),14,2)))
			EndIf
			If aFormPag[nI][2] $_FORMATEF
				nVlrTefCF	+= nValPag 
			Else
				nVlrPagCF 	+= nValPag
			Endif	
		EndIf
	Next
	LjLogFront("FRT271G - Valores pagamento cupom fiscal",nVlrPagCF)
	
	//Soma as Nccs somente se existir valor de cupom fiscal, pois se nao existir o valor será total de credito para o 
	//cupom fiscal (sendo que nao houve) impressao de CF
	If A271FatRes(aReserva, (nVlrTotal + nValCredito - nVlrAcreTot), (nVlrTotRe - nDescToP + nValorFSD),,0)[3] > 0
		nVlrNccCF := Val(AllTrim(Str(Round(nValCredito * (A271FatRes(aReserva, (nVlrTotal + nValCredito - nVlrAcreTot), (nVlrTotRe - nDescToP + nValorFSD),,0)[1]) , nDecimais),14,2))) 
		nVlrPagCF += nVlrNccCF
	EndIf
	LjLogFront("FRT271G - Valores pagamento cupom fiscal Ncc",nVlrNccCF)
	
	//Como lAbreCup eh verdadeiro, se tiver reserva tb a venda eh mista
	lVendMis 		:=  lReserva 
	LjLogFront("FRT271G - Venda Mista Entrega/Retira ",lVendMis)	
EndIf		

nRet := IFStatus(nHdlECF, "2", @cRet)		// Verifico o Status do ECF
If nRet <> 0
	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	HELP(' ',1,'FRT011')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(.F.)
EndIf

If !lRecebe
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ No caso da NCC deve atualizar esses campos para a gravacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValCredito > 0
		nVlrTotal   += nValCredito
		LjLogFront("FRT271G - ATUALIZA O VLRTOTAL COM NCC",nVlrTotal)
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Cliente escolhido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+cCliente+cLojaCli)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Vendedor escolhido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA3")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA3")+cVendLoja)	//Verifica se o vendedor existe no PDV
		AAdd(aDadosVend , cVendLoja)
		AAdd(aDadosVend , 0	)
		If !Empty(SL1->L1_VEND2)
			AAdd(aDadosVend , SL1->L1_VEND2)
		Else
			AAdd(aDadosVend , "")
		EndIf
		AAdd(aDadosVend , "")
	Else
		AAdd(aDadosVend , SA3->A3_COD)
		AAdd(aDadosVend , SA3->A3_COMIS)
		If !Empty(SL1->L1_VEND2)
			AAdd(aDadosVend , SL1->L1_VEND2)
		Else
			AAdd(aDadosVend , SA3->A3_SUPER)
		EndIf
		If !Empty(SL1->L1_VEND3)
			AAdd(aDadosVend , SL1->L1_VEND2)
		Else
			AAdd(aDadosVend , SA3->A3_GEREN)
		EndIf
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Controle de Formularios ³
	//³Paises:Chile/Colombia - F1CHI	      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCFolLocR5
		If LjProfile(28)
			cImprimeL1 := "4S"
		Else
			cImprimeL1 := "2S"
		EndIf
	Else
		cImprimeL1 :="1S"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Localizacoes                                               ³
	//³Valor liquido inicialmente igual ao valor bruto, porem sera corrigido     ³
	//³adiante quando serao abatidos os impostos para obter o valor liquido final³
	//³Paises : Chile/Colombia - F1CHI                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc $ "CHI|COL"
		nVlrLiqAux := nVlrBruto
		aRetPgto := LJ7CalcPgt(	nVlrBruto	,cItemCond	,NIL,	Nil			,;
								NIL			,NIL		,NIL,	Nil			,;
								Nil			,NIL		,NIL,	@nVlrAcrFin)

		nVlrBrutAux:= nVlrBruto + nVlrAcrFin
	Else
		nVlrLiqAux  := nVlrTotal
		nVlrBrutAux := nVlrBruto
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Encerramento do Cupom - Finaliza o SL1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSL1 := {{"L1_VEND"		,	aDadosVend[1]	}, ;
			 {"L1_COMIS"	,	aDadosVend[2]	}, ;
			 {"L1_VEND2"	,	aDadosVend[3]	}, ;
			 {"L1_VEND3"	,	aDadosVend[4]	}, ;
			 {"L1_CLIENTE"	,	cCliente		}, ;
			 {"L1_TIPOCLI"	, 	cTipoCli		}, ;
			 {"L1_LOJA"		,	cLojaCli		}, ;
			 {"L1_TIPO"		,	"V"				}, ;
			 {"L1_HORA"		,	cHora			}, ;
			 {"L1_VLRTOT"	,	nVlrTotaL		}, ;
			 {"L1_DESCONT"	,	nVlrDescTot		}, ;
			 {"L1_VLRLIQ"	,	nVlrTotal		}, ;
			 {"L1_VALBRUT"	,	IIf( nValCredito > 0, nVlrTotal, nVlrBruto )		}, ;
			 {"L1_VALMERC"	,	If(nVlrMerc==0,nVlrBruto,nVlrMerc)}, ;
			 {"L1_DESCNF"	,	nVlrPercTot		}, ;
			 {"L1_DINHEIR"	,	nDinheiro		}, ;
			 {"L1_CHEQUES"	,	nCheques		}, ;
			 {"L1_CARTAO"	,	nCartao			}, ;
			 {"L1_CONVENI"	,	nConvenio		}, ;
			 {"L1_VALES"	,	nVales			}, ;
			 {"L1_FINANC"	,	nFinanciado		}, ;
			 {"L1_VLRDEBI"	,	nValorDebi		}, ;
			 {"L1_OUTROS"	,	nOutros			}, ;
			 {"L1_ENTRADA"	,	nEntrada		}, ;
			 {"L1_JUROS"	,	nTmpJuros		}, ;
			 {"L1_PARCELA"	,	nParcelas		}, ;
			 {"L1_TXDESC"	,	0				}, ;
			 {"L1_CONDPG"	,	cItemCond		}, ;
			 {"L1_FORMPG"	,   Fr271tuFORMPG( cItemCond, lCondNegF5, aParcOrc, aFormCtrl, aPgtos) },;
			 {"L1_INTERV"	,	If((cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0),If(Len(aFormCtrl)>1,aFormCtrl[2][6],0),0)},;
	         {"L1_CREDITO"	, 0					}, ;
	         {"L1_CONFVEN"	,	"SSSSSSSSNSSS"	}, ;
			 {"L1_IMPRIME"	,	cImprimeL1		}, ;
			 {"L1_NUMMOV"	,	LjNumMov()		}, ;
			 {"L1_SITUA"	,	"09"}}						// "09" - Encerrado SL1 (Nao gerado SL4)

	Aadd(aSL1,{"L1_DESCFIN", nVlrDescCPg})

	If nVlrBruto >= nVlrDescTot
		 Aadd(aSL1,{"L1_DESCONT", nVlrDescTot})
		 Aadd(aSL1,{"L1_DESCNF"	, nVlrPercTot})
	EndIf

	If AllTrim(Str(SuperGetMv("MV_LJRGMID",,0))) $ "1|2"
	     Aadd(aSL1,{"L1_MIDIA"	, M->L1_MIDIA})
	Endif

	If lCenVenda
		aAdd( aSL1, { "L1_TABELA", 	cTabPad  } )
	EndIf

	If SL1->(ColumnPos("L1_VLRARR")) > 0
		aAdd( aSL1, { "L1_VLRARR", 	LjxDInsArrTax( nArredondar, aParcelas, 2 ) } )
	EndIf

	If LjNfPafEcf(SM0->M0_CGC)
		/*Dados do orcamento (pre-venda ou DAV)*/
		If !Empty(cNumDAV)
			aAdd( aSL1, { "L1_NUMORC", 	cNumDAV  } )
			If lPreVenda
				aAdd( aSL1, { "L1_TPORC" , 	"P"  } )
			Else
				aAdd( aSL1, { "L1_TPORC" , 	"D"  } )
			EndIf
		EndIf

	ElseIf lEmitNFCe

		aAdd( aSL1, {"L1_TPORC", "E"} )

		/*Tela para informar o CPF / CNPJ do cliente, quando for NFC-e*/
		If !IsBlind()
			If Empty(cCliCGC)
				If SL1->(ColumnPos("L1_CGCCLI")) > 0
					If lLjxDCGC
						If lLj950ImpCpf .OR. (lLjInfDocCli .And. LjInfDocCli() >= 0)
							aRetInfDocCli	:= LjxDCGC(SL1->L1_CLIENTE,SL1->L1_LOJA, Nil , , nVlrTotaL )
							cCliCGC			:= aRetInfDocCli[1]
						EndIf
					Else
						cCliCGC := LjxDInfCGC(SL1->L1_CLIENTE,SL1->L1_LOJA,Nil)
					EndIf

					aAdd( aSL1, {"L1_CGCCLI", Alltrim(cCliCGC) } )
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetuando gravação dos dados do TEF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefOk

		Aadd(aSL1,{"L1_VENDTEF","S"})

		If cTipTef $ TEF_CLISITEF+";"+TEF_CENTROPAG

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a alteracao das datas e conf. de ADM informadas durante o processamento do TEF		           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjTEFAceParc(@aParcelas)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gerando os dados do TEF para a tabela SL1													   		   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSL1 := LjTEFGeraSL(aSL1,"SL1")

		Else
			Aadd(aSL1,{"L1_FORMPG"	, Fr271tuFORMPG( cItemCond, lCondNegF5, aParcOrc, aFormCtrl,;
												     aPgtos) })
			Aadd(aSL1,{"L1_DATATEF"	, aTefDados[1][2]})
			Aadd(aSL1,{"L1_HORATEF"	, aTefDados[1][3]})
			Aadd(aSL1,{"L1_DOCTEF"	, aTefDados[1][4]})
			Aadd(aSL1,{"L1_AUTORIZ"	, aTefDados[1][5]})
			Aadd(aSL1,{"L1_INSTITU"	, aTefDados[1][8]})
			Aadd(aSL1,{"L1_DOCCANC"	, aTefDados[1][6]})
			Aadd(aSL1,{"L1_HORCANC"	, aTefDados[1][7]})
			Aadd(aSL1,{"L1_NSUTEF"	, aTefDados[1][9]})
			Aadd(aSL1,{"L1_TIPCART"	, aTefDados[1][10]})
			//Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas
			Aadd(aSL1,{"L1_PARCTEF"	, aTefDados[1][16]+aTefDados[1][17]})
			Aadd(aSL1,{"L1_TEFBAND"	, aTefDados[1][18]})
		EndIf
	Else
		If Len(aNSUVndTef) > 0
			cNSUVndTef := aNSUVndTef[1][4] //pego o primeiro conteudo do array, pois o importante mesmo é o SL4
			If !Empty(AllTrim(cNSUVndTef))
				aAdd( aSL1, { "L1_VENDTEF", "S"})
				aAdd( aSL1, { "L1_DOCTEF" , cNSUVndTef } )
				aAdd( aSL1, { "L1_NSUTEF" , Right(cNSUVndTef,6) } )
				aAdd( aSL1, { "L1_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )
			Else
				LjGrvLog(Nil,"Atenção: Tela de NSU foi aberta porem não foi " +;
							 "digitado um numero de transacao. SL1 será gravada sem dados de TEF Manual")
			EndIf		
		EndIf
	EndIf

	If CrdXInt()
	  //Controlar se a venda foi off-line (1) ou uma venda on-line (2) - WebService
	  If lForcada
		 aAdd( aSL1, {"L1_FORCADA", "1" } )
		// Grava no campo L1_CGCCART o Numero do CGC/CPF ou Numero do Cartao do Cliente, o que tiver sido
		// informado.
		AADD( aSL1, {"L1_CGCCART", If(!Empty(aDadosCrd[1]), aDadosCrd[1], aDadosCrd[2]) } )

	  Else
		 aAdd( aSL1, {"L1_FORCADA", "2" } )
	  Endif

	   aAdd( aSL1, {"L1_CONTRA", cContrato } )
	Endif

	If cPaisLoc <> "BRA"
		//Realiza a gravacao do troco em sua respectiva moeda...
		For nI := 1 TO Len(aTroco)
			If (aScan(aTroco,{|x| x[4]==nI}) > 0)
				nPos := AScan(aTroco,{|x| x[4]==nI})
		     	Aadd(aSL1,{"L1_TROCO"+Alltrim(STR(nI)),aTroco[nPos][2]}) //Valor do Troco
			EndIf
		Next nI

		For nI := 1 to Len(aImpsSL1)
	    	Aadd(aSL1,{aImpsSL1[nI][2],aImpsSL1[nI][3]})   //Valor do imposto
	    	Aadd(aSL1,{aImpsSL1[nI][4],aImpsSL1[nI][5]})   //Base do imposto

			//Acerta o valor liquido abatendo o valor dos impostos...
	      	If aImpsSL1[nI][06] == "1"
				aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRLIQ"})][2] -= aImpsSL1[nI][3]
		  	EndIf

	  	Next nI

		//Acerta o valor da mercadoria com base no valor liquido da venda...
		aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VALMERC"})][2] := aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRLIQ"})][2]

		//Caso tenha juros ou desconto financeiro eh necessario somar ao
		//valor total e ao valor bruto da venda os impostos...
	  	If (nTmpJuros > 0) .OR. (nTmpDesc > 0)
	    	aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VLRTOT"})][2] := nVlrTotal
	   	  	aSL1[Ascan(aSL1,{|x| Trim(x[1]) == "L1_VALBRUT"})][2]:= nVlrTotal
	  	EndIf
	Else
        //Para o caso do Brasil, existe apenas a gravacao do Troco em 1 moeda
		If ExistFunc("Frt272Get")
			cFormTR := Frt272Get()
		EndIf		
		If lMvLjTroco .And. (lMvLjTrDin == 0 .Or. !cSimbCor $ cFormTR ) 
			If	nTroco2 > 0
				AAdd( aSL1, {"L1_TROCO1", nTroco2 } )
			ElseIf nTroco > 0
				AAdd( aSL1, {"L1_TROCO1", nTroco } )
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se existir o campo do PIS, tem tratamento para os impostos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aSL1, {"L1_VALPIS" , nValTPis } )
		AAdd( aSL1, {"L1_VALCOFI", nValTCof } )
		AAdd( aSL1, {"L1_VALCSLL", nValTCsl } )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando importacao de orcamento, o nValor esta alimentado     ³
	//³ com o "Valor Liquido",  mas os tratamentos abaixo consideram ³
	//³ ele como "Valor Bruto".                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpOrc
		If (nVlrBruto = 0 .AND. nValCredito > 0 .AND. nVlrDescTot > 0 .AND. !Frt060Ret("NCC_MENOR"))
			nValor := nVlrBruto + nValCredito + nVlrDescTot
		Else
			nValor := nVlrBruto + nValCredito
			LjLogFront("FRT271G - NVALCREDITO - NCC ",nValCredito)
		EndIf
		LjLogFront("FRT271G - CASO IMPORTACAO NVALOR ",nValor)
		LjLogFront("FRT271G - VALOR BRUTO ",nVlrBruto)

		nVlrSeguro	:= SL1->L1_SEGURO                       // Valor de Seguro
		nVlrDespesa	:= SL1->L1_DESPESA                      // Valor de Despesa
		nOutrAcres  := nVlrSeguro + nVlrDespesa // Soma dos demais acrescimos
	EndIf

	//No caso de localizacoes os tratamentos referentes a acrescimo ou
	//desconto ja foram realizados anteriormente, no recalculo dos
	//impostos variaveis...
	If cPaisLoc == "BRA"
		If lLj7Arred
			Lj7Arred(1) // limpa array statico da função de arredondamento
		EndIf
		// Caso houve acrescimo pela condicao de pagamento
		If ( (nVlrTotal - nValIPI - nValorFSD  - nOutrAcres) + nVlrDescTot ) > nValor
			nAcres := ( ( (nVlrTotal - nValIPI - nValorFSD  - nOutrAcres) + nVlrDescTot ) - nValor ) / ( nValor - nVlrDescTot - nValCredito )
			If lHabNovoArred  //Novo arredondamento - Considera regra de arredondamento da impressora
				nAcresImp	:= NoRound(( ( nVlrTotal - nValorFSD + nVlrDescTot ) - nValor ) / ( nValor - nVlrDescTot - nValCredito )*100,2)
			EndIf
			LjLogFront("FRT271G - ACRESCIMO ",nAcres)
			LjLogFront("FRT271G - ACRESCIMO IMP",nAcresImp)
			LjLogFront("FRT271G - VALOR TOTAL LÍQUIDO ",nValor)
		EndIf
		If nAcres > 0 .Or. nValorFSD > 0
			nDiffIT := 0
			SL2->(DbSetOrder(1))
			For nI := 1 To Len(aItens)
				If !aItens[nI][AIT_CANCELADO]

					SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+FR271BPegaIT(aItens[nI][AIT_ITEM])))

					// Sessao [Arredondamento] no SIGALOJA.INI
					// Habilita =0 -> forma atual  , Habilita = 1  ->  forma nova
					If lHabNovoArred .And. !(AllTrim(SL2->L2_ENTREGA) $ "1|3")  //Novo arredondamento - Considera regra de arredondamento da impressora

						nPosAux := aScan(aGrupTrib,{|x| AllTrim(x[1]) == AllTrim(aItens[nI][AIT_ALIQUOTA])})

						//1o. Passo: Agrupa por aliquotas no array aGrupTrib, todos os valores dos itens.
						If nPosAux == 0
							lTemGrpTrb := .T.
							aAdd(aGrupTrib, {})
							nPosAux := Len(aGrupTrib)
							aAdd (aGrupTrib[nPosAux], aItens[nI][AIT_ALIQUOTA]	)	 	   			//01 - Tipo Tributacao
							aAdd (aGrupTrib[nPosAux], aItens[nI][AIT_VLRITEM]	)	 	   			//02 - Valor da Soma dos itens desta Tributacao
							aAdd (aGrupTrib[nPosAux], {nI}						)	 	  		 	//03 - Posicao do item de Maior Valor
							aAdd (aGrupTrib[nPosAux], aItens[nI][AIT_VLRITEM]	)	 	   			//04 - Valor Maior
							aAdd (aGrupTrib[nPosAux], {{nI,aItens[nI][AIT_VLRITEM],0}}) 			//05 - Posicao do Item ; Valor dos itens desta Tributacao SEM descontos ou acrescimos proporcionalizados ; L2_ITEM jah COM descontos ou acrescimos proporcionalizados
							aAdd (aGrupTrib[nPosAux], 0   )	   							   			//06 - Valor de Desconto ou Acrescimo relacionado a esta Tributacao (de acordo com a regra de rateio da impressora)
						Else
							If aItens[nI][AIT_VLRITEM] == aGrupTrib[nPosAux][04] //Item de mesmo valor, adiciona item para depois distribur o residuo entre os itens
								aAdd( aGrupTrib[nPosAux][03], nI )
							ElseIf aItens[nI][AIT_VLRITEM] > aGrupTrib[nPosAux][04]
								aGrupTrib[nPosAux][03] := {nI}
								aGrupTrib[nPosAux][04] := aItens[nI][AIT_VLRITEM]
							EndIf
							aGrupTrib[nPosAux][02] += aItens[nI][AIT_VLRITEM]
							aAdd( aGrupTrib[nPosAux][05], {nI,aItens[nI][AIT_VLRITEM],0} )
						EndIf
					EndIf

					nPercProduto := (aItens[nI][AIT_VLRITEM] / (nValor-nValorFSD)) * 100
					nVlUnit := ( aItens[nI][AIT_VLRITEM] - ((nVlrDescTot * nPercProduto) / 100) ) / aItens[nI][AIT_QUANT]
					nValIPIUnit := (aItens[nI][AIT_VALIPI] / aItens[nI][AIT_QUANT])
					nVlrNCCUnit := Round((nValCredito * nPercProduto) / 100, nDecVrUnit)
					If !(aItens[nI][AIT_CANCELADO]) 
					If lLj7Arred
						nAcresIT := Lj7Arred(2,3, ((((nVlUnit + nValIPIUnit) - (nVlrNCCUnit/aItens[nI][AIT_QUANT])) * aItens[nI][AIT_QUANT]) * nAcres) )
					Else
						nAcresIT := NoRound(((((nVlUnit + nValIPIUnit) - (nVlrNCCUnit/aItens[nI][AIT_QUANT])) * aItens[nI][AIT_QUANT]) * nAcres), nDecVrUnit)
					EndIf
					EndIf
					If lHabNovoArred .And. !(AllTrim(SL2->L2_ENTREGA) $ "1|3")
					    // Verifica o desconto/acrescimo efetivo no total do grupo de tributação para gravar no array
					    // truncando em duas casas, seguindo a regra da impressora                                                                                    
						If !(aItens[nI][AIT_CANCELADO]) 
							nAcresIT := NoRound(((((aItens[nI][AIT_VLRITEM] + aItens[nI][AIT_VALIPI]) - nVlrNCCUnit) * (nAcresImp/100))), 2 )
						EndIf 
						If aGrupTrib[nPosAux][06] == 0
							aGrupTrib[nPosAux][06]+= nAcresIT
                		Else
					    	// sempre verifica se o acrescimo do grupo esta batendo com a soma do acrescimo por item (dentro do grupo) ,
					    	// e caso haja diferença, é aplicada no item
							nPercEfet := Noround( aGrupTrib[1][2] * (nAcresImp / 100) ,2 )
							nValAtual := aGrupTrib[nPosAux][06] + nAcresIT
							nDif      := nPercEfet - nValAtual
							If nDif  > 0 .AND. nDif <= 1/10**nDecimais
								nAcresIT += nDif
							EndIf
                		Endif

						aItens[nI][AIT_VLRITEM] += nAcresIT
						nVlUnit := aItens[nI][AIT_VLRITEM] /aItens[nI][AIT_QUANT]

					Else
						nVlUnit += NoRound( (( ((nVlUnit + nValIPIUnit) - (nVlrNCCUnit/aItens[nI][AIT_QUANT])) * nAcres )), nDecVrUnit )
						aItens[nI][AIT_VLRITEM] += nAcresIT
					EndIf

					aSL2 := {{"L2_VRUNIT",nVlUnit},;
							 {"L2_VLRITEM",	aItens[nI][AIT_VLRITEM]}}
					If lCpoAcresSL2
						aAdd(aSL2,{"L2_VALACRS",nAcresIT})
					EndIf
					FR271BGeraSL("SL2", aSL2, .F.)
					LjLogFront("FRT271G - ITEM "+Alltrim(STR(nI))+" APOS RATEIO ACRES",aSL2)

					If lHabNovoArred .And. !(AllTrim(SL2->L2_ENTREGA) $ "1|3")
						//Alimenta posicao do array com valor do item  jah com acrescimo proporcionalizado
						aGrupTrib[nPosAux][05][Len(aGrupTrib[nPosAux][05])][03] := SL2->L2_VLRITEM
					EndIf

					nSomaAux += nAcresIT
					nVlUnit := 0

					If !Empty(SL2->L2_RESERVA) .And. SL2->L2_ENTREGA $ "1|3"
						nTotEntrega += SL2->L2_VLRITEM
					EndIf
				EndIf
			Next nI
			nVlrSomAcr := ( nVlrTotal + nVlrDescTot - nValor)  - nSomaAux
			If Abs(nVlrSomAcr) <= (1/(10 ** nDecimais)) .AND. !lHabNovoArred
				aItens[Len(aItens)][AIT_VLRITEM] := NoRound( ( aItens[Len(aItens)][AIT_VLRITEM] + nVlrSomAcr ), nDecimais )
				If lCpoAcresSL2
					aAdd(aSL2,{"L2_VALACRS",nAcresIT+nVlrSomAcr})
					FR271BGeraSL("SL2", aSL2, .F.)
				EndIf
			EndIf
		EndIf

		// Se Houver Desconto no Total, o Mesmo Devera Ser Aplicado nos Itens, ³
		// Mantendo a Compatibilidade com a Venda Balcao.
  		If nVlrDescTot + nVlrDescCPg - nVlrAcreTot - nValorFSD <> 0
			nDiffIT := 0
			SL2->(DbSetOrder(1))

			If lGE
				nVlrGar := F271GGEc(@aItens, @nPosGe)
				If nVlrGar > 0
					nValor -= nVlrGar
					LjLogFront("FRT271G - SUBTRAIU O VALOR DA GARANTIA",nValor)
				EndIf
			EndIf
			For nI := 1 To Len(aItens)
				If !aItens[nI][AIT_CANCELADO]

					SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+FR271BPegaIT(aItens[nI][AIT_ITEM])))
					
					// Sessao [Arredondamento] no SIGALOJA.INI
					// Habilita =0 -> forma atual  , Habilita = 1  ->  forma nova
					If lHabNovoArred  .And. !(AllTrim(SL2->L2_ENTREGA) $ "1|3") //Novo arredondamento - Considera regra de arredondamento da impressora

						nPosAux := aScan(aGrupTrib,{|x| AllTrim(x[1]) == AllTrim(aItens[nI][AIT_ALIQUOTA])})

						//1o. Passo: Agrupa por aliquotas no array aGrupTrib, todos os valores dos itens.
						If !lTemGrpTrb
							If nPosAux == 0
								aAdd(aGrupTrib, {})
								nPosAux := Len(aGrupTrib)
								aAdd (aGrupTrib[nPosAux], aItens[nI][AIT_ALIQUOTA]	)	 	   	//01 - Tipo Tributacao 
								aAdd (aGrupTrib[nPosAux], aItens[nI][AIT_VLRITEM]	)	 	   	//02 - Valor da Soma dos itens desta Tributacao
								aAdd (aGrupTrib[nPosAux], {nI}						)	 	   		//03 - Posicao do item de Maior Valor
								aAdd (aGrupTrib[nPosAux], aItens[nI][AIT_VLRITEM]	)	 	   	//04 - Valor Maior
								aAdd (aGrupTrib[nPosAux], {{nI,aItens[nI][AIT_VLRITEM],0}})		//05 - Posicao do Item ; Valor dos itens desta Tributacao SEM descontos ou acrescimos proporcionalizados ; L2_ITEM jah COM descontos ou acrescimos proporcionalizados; tipo do item
								aAdd (aGrupTrib[nPosAux], 0   )	   							   		//06 - Valor de Desconto ou Acrescimo relacionado a esta Tributacao (de acordo com a regra de rateio da impressora)
							Else
								If aItens[nI][AIT_VLRITEM] == aGrupTrib[nPosAux][04] //Item de mesmo valor, adiciona item para depois distribur o residuo entre os itens
									aAdd( aGrupTrib[nPosAux][03], nI )
								ElseIf aItens[nI][AIT_VLRITEM] > aGrupTrib[nPosAux][04]
									aGrupTrib[nPosAux][03] := {nI}
									aGrupTrib[nPosAux][04] := aItens[nI][AIT_VLRITEM]
								EndIf
								aGrupTrib[nPosAux][02] += aItens[nI][AIT_VLRITEM]
								aAdd( aGrupTrib[nPosAux][05], {nI,aItens[nI][AIT_VLRITEM],0} )
							EndIf
						EndIf
					EndIf

					nPercProduto := ( ((aItens[nI][AIT_VRUNIT] - aItens[nI][AIT_VALDESC]) * aItens[nI][AIT_QUANT]) / nValor ) * 100
					If aItens[nI][AIT_VALIPI] > 0
						nPercIPI := aItens[nI][AIT_VALIPI] / aItens[nI][AIT_VLRITEM]
					Else
						nPercIPI := 0
					EndIf

					//nDescIT: soma de ambas as variaveis que concedem desconto financeiro (condicao de pagamento e ato da venda)
					If nAcres > 0
						If lLj7Arred
							nDescIT  := Lj7Arred(2,1, ( ( (nVlrDescTot+nVlrDescCPg) * nPercProduto ) / 100 ) )
						Else
							nDescIT  := NoRound( ( ( (nVlrDescTot+nVlrDescCPg) * nPercProduto ) / 100 ), nDecVrUnit )
						EndIf
					Else
						If nVlrBruto >= nVlrDescTot
							If Len(aReserva) > 0

								// se tem reserva, o frete só vai ser aplicado para os itens reservados
								If aScan(aReserva,{|x|, x[1] == aItens[nI][AIT_ITEM]}) > 0
									If lLj7Arred
										nFreteProp := Lj7Arred( 5, 5, (nFrete * (aItens[nI][AIT_VLRITEM] / nTotEntrega)) )
									Else
										nFreteProp := Round( nFrete * (aItens[nI][AIT_VLRITEM] / nTotEntrega) , nDecimais )
									EndIf
								Else
									nFreteProp := 0 //zera valor de frete
								EndIf
							Else
								// se nao tem reserva, o rateio do frete é feito para todos os itens
								nFreteProp := SL2->L2_VALFRE
							EndIf

							If lLj7Arred
								//Obs.: O valor de frete nao pode entrar no calculo do desconto por item, pois mudaria o fator do produto. O calculo so deve ter valores 
								//de somatoria de itens (sem acrescimo / sem desconto e sem frete). 
								nDescIT  := Lj7Arred(2,1, (nVlrDescTot+nVlrDescCPg) * (aItens[nI][AIT_VLRITEM]  / (nVlrBruto - nValorFSD + nValCredito)) ) 
							Else
								nDescIT  := NoRound((nVlrDescTot+nVlrDescCPg) * ((aItens[nI][AIT_VLRITEM] + nFreteProp) / (nVlrBruto + nValCredito)), nDecimais)
							EndIf
						Else
							If lLj7Arred
								nDescIT  := Lj7Arred(2,1, (nVlrDescTot+nVlrDescCPg) * (aItens[nI][AIT_VLRITEM] / (nValCredito  + nVlrDescTot)) )
							Else
								nDescIT  := NoRound((nVlrDescTot+nVlrDescCPg) * (aItens[nI][AIT_VLRITEM] / (nValCredito  + nVlrDescTot)), nDecimais)
							EndIf
						EndIf
					EndIf

					nVlrIT   := aItens[nI][AIT_VLRITEM] - nDescIT

					// Se for importação de orçamento com Multinegociação
					// soma o valor do acréscimo no valor do item
					If lImpOrc .And. lMultNeg
						nVlrIT += SL2->L2_VALACRS
					EndIf
					aSL2 := {	{"L2_VRUNIT"	, nVlrIT/aItens[nI][AIT_QUANT]	},;
								{"L2_VLRITEM"	, nVlrIT						},;
								{"L2_DESCPRO"	, nDescIT						},;
							 	{"L2_VALIPI"	, NoRound(nVlrIT * nPercIPI, 2)	},;
							 	{"L2_VALFRE"	, nFreteProp					} }


					If lEmitNFCe

					   MaFisIni(	cCliente	,cLojaCli	, "C"	,"S"	,;
									cTipoCli	,NIL		, NIL	,.F.	,;
									"SBI"		,NIL		, "01"	,NIL	,;
									NIL			,NIL		, NIL	,NIL	,;
									NIL			,NIL		, .F.	)
					   
						/*
						O retorno abaixo da MatxFis, tera sempre 1 como referencia de item , porque
						é utilizado o MafisAdd temporariamente no produto inserido ,e depois e
						inutilizado as informacoes da Matxfis (MafisEnd())
						*/
						MaFisAdd(	SL2->L2_PRODUTO										, SL2->L2_TES	, SL2->L2_QUANT	, SL2->L2_PRCTAB,;
							 		SL2->L2_VALDESC + nDescIt - SL2->L2_VALACRS			, ""	 		, ""    		,				,;
							 		nFreteProp /*Frete*/   								, 0 /*Despesa*/	, 0 /*Seguro*/	, 0				,;
							 		SL2->L2_VLRITEM	+ SL2->L2_VALDESC - SL2->L2_VALACRS	, 0	 	)

						nValICMS	:= MaFisRet(1,"IT_VALICM" )
						nBaseICMS	:= MaFisRet(1,"IT_BASEICM")

						aAdd( aSL2, { "L2_VALICM"	, nValICMS		} )
						aAdd( aSL2, { "L2_BASEICM"	, nBaseICMS 	} )
						If lL2FECP
							nVlItFCP	:= MaFisRet(1,"IT_VALFECP" )
							nAlqFECP	:= MaFisRet(1, "IT_ALIQFECP")
							
							aAdd( aSL2, { "L2_VALFECP"	, nVlItFCP } )
							aAdd( aSL2, { "L2_ALQFECP"	, nAlqFECP } )
						EndIf
						//Recalcula os valores do array nfce
							
						aNFCeICMST := Array(2) 
						aNFCeICMST[1] := SL2->L2_ITEM
						aNFCeICMST[2] := {}
				
						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_MARGEM")	)
						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_PREDST")	)
						Aadd( aNFCeICMST[2], MaFisRet(1,"IT_BASESOL")   )
						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_ALIQSOL")	)
						Aadd( aNFCeICMST[2], MaFisRet(1, "IT_VALSOL" ) 	)
						Aadd( aNFCeICMST[2], nValFecp	)
						
						nValFecp := 0
						//Zera o array a FECP para não recalcular novamente
						
						LjGrvLog("FRTA271G", "Acerto no array de itens da NFC-e aNFCeICMST", aNFCeICMST)
						
						//Atualiza o array estatico (aICMSST) do LOJNFCE.PRW
						LjSetICMST( aNFCeICMST, 1 )		//Alteração

						MafisEnd()

					EndIf

					If !Empty(SL2->L2_VALPS2)
						AAdd( aSL2 , {"L2_BASEPS2", nVlrIT })
						AAdd( aSL2 , {"L2_VALPS2" ,(nVlrIT * SL2->L2_ALIQPS2) / 100 })
					EndIf

					If !Empty(SL2->L2_VALCF2)
						AAdd( aSL2 , {"L2_BASECF2", nVlrIT })
						AAdd( aSL2 , {"L2_VALCF2" ,(nVlrIT * SL2->L2_ALIQCF2) / 100 })
					EndIf

					//Frete
					AAdd( aSL2 , {"L2_VALFRE", nFreteProp })

					FR271BGeraSL("SL2", aSL2, .F.)
					LjLogFront("FRT271G - ITEM "+Alltrim(STR(nI))+" APOS RATEIO DESC",aSL2)

					If lHabNovoArred .And. !(AllTrim(SL2->L2_ENTREGA) $ "1|3")
						//Alimenta posicao do array com valor do item  jah com desconto e acrescimo proporcionalizado
						aGrupTrib[nPosAux][05][Len(aGrupTrib[nPosAux][05])][03] := SL2->L2_VLRITEM
					EndIf

					nDiffIT  += SL2->L2_DESCPRO
				EndIf
			Next nI

			LjLogFront("FRT271G - DIF P/ AJUST ANTES ",nDiffIT)
			nDiffIT := nVlrDescTot+nVlrDescCPg - nDiffIT
			LjLogFront("FRT271G - DIF 2 P/ AJUST NO ULT ITEM",nDiffIT)

			SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
			While ! nDiffIT == 0 .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. ! EOF()
				Reclock( "SL2" ,.F.)
				If NoRound((SL2->L2_VLRITEM - nDiffIT) / SL2->L2_QUANT, 2) < 1/10**nDecimais
					// Se o valor do item e' pequeno faz o ajuste deixando 1 centavo no VrUnit
					SL2->L2_VRUNIT := 1/10**nDecimais
					// Subtrai da variavel somente a diferenca que sera ajustada aqui.
					nDiffIT -= (SL2->L2_VLRITEM - (L2_VRUNIT * L2_QUANT))
					// Adiciona ao desconto proporcional a diferenca que foi utilizada aqui.
					If nVlrDescTot <> 0
						SL2->L2_DESCPRO += (SL2->L2_VLRITEM - (SL2->L2_VRUNIT * SL2->L2_QUANT))
					EndIf
					// Recalcula o valor total do item de acordo com o VrUnit*Qtd
					SL2->L2_VLRITEM := (SL2->L2_VRUNIT * SL2->L2_QUANT)
				Else
					// Se o valor do item permite entao faz o ajuste total
					// Soma a diferenca no desconto desse item porque o ajuste sera feito aqui
					If nVlrDescTot <> 0
						SL2->L2_DESCPRO += nDiffIT
					EndIf
					// Se aumentou o desconto entao diminui o valor do item na mesma proporcao
					SL2->L2_VLRITEM -= nDiffIT
					// Recalcula o valor unitario do item de acordo com o VrTotItem/Qtd
					SL2->L2_VRUNIT  := NoRound(SL2->L2_VLRITEM / SL2->L2_QUANT, 4)
					// Como toda a diferenca foi utilizada entao zera a variavel para sair do laco (while).
					nDiffIT := 0
				EndIf
				MsUnlock()
				dbSkip()
			End

		EndIf
	EndIf

	FR271BGeraSL("SL1", aSL1, .F.)

	If Frt060Ret("NCC_USADA") > 0

		If Empty(SL1->L1_DOC)
			cParmDoc := SL1->L1_DOCPED
		Else
			cParmDoc := SL1->L1_DOC
		Endif

		If Empty(SL1->L1_SERIE)
			If lTemServic
				cParmSer := SL1->L1_SERRPS
			Else
				cParmSer := SL1->L1_SERPED
			EndIf
		Else
			cParmSer := SL1->L1_SERIE
		Endif

		// Grava as NCCs para uma baixa automatica posteriormente
		Aadd(aMDJ,{"MDJ_FILIAL"	,xFilial("MDJ")})
		Aadd(aMDJ,{"MDJ_DOC"		,cParmDoc})
		Aadd(aMDJ,{"MDJ_SERIE"	,SL1->L1_SERIE})
		Aadd(aMDJ,{"MDJ_CLIENT"	,cCliente})
		Aadd(aMDJ,{"MDJ_LOJA"	,cLojaCli})
		Aadd(aMDJ,{"MDJ_OPERAD"	,SL1->L1_OPERADO})
		Aadd(aMDJ,{"MDJ_EMIS"	,SL1->L1_EMISNF})
		Aadd(aMDJ,{"MDJ_NCCUSA"	,Frt060Ret("NCC_USADA")})
		Aadd(aMDJ,{"MDJ_NCCGER"	,0})
		Aadd(aMDJ,{"MDJ_CREDIT"	,Abs(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA"))})
		Aadd(aMDJ,{"MDJ_NUMORC"	,SL1->L1_NUM})
		Aadd(aMDJ,{"MDJ_OPER"	,"B"})
		Aadd(aMDJ,{"MDJ_SITUA"	,"TP"})

		aMDK:= aClone(Frt060Ret("NCC_ITENS"))

		Frt060GrvNcc(aMDJ, aMDK, 1) //Efetua a gravação das tabelas de modo temporario "TP"
		nRecMdj := MDJ->(Recno())
	EndIf

	//Baixa o status dos Vales Presentes vendidos
	If lL2VALEPRE .Or. (lAbreCup .And. Len(aReserva) > 0) .Or. lEmitNfce
		SL2->(DbSetOrder(1))
		For nI := 1 To Len(aItens)
			If !aItens[nI][AIT_CANCELADO]
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+FRTPegaIT(aItens[nI][AIT_ITEM])))

				//Verifica se tem pelo menos 1 item registrado no Cupom Fiscal ou se todos os itens do Cupom Fiscal foram cancelados
				If SL2->L2_ENTREGA == "2" .Or. Empty(SL2->L2_ENTREGA) .AND. Empty( SL2->L2_VALEPRE )
					If lEmitNfce
						If !lTemServic .OR. !(iIf(ExistFunc("LjIsTesISS"), LjIsTesISS(SL1->L1_NUM,SL2->L2_TES), SL2->L2_VALISS > 0)) //Item de "servico"
							lTemItemCF := .T.
						EndIf
					Else
						lTemItemCF := .T.
					EndIf
				EndIf

				If lL2VALEPRE
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Baixa o status dos Vales Presentes vendidos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( SL2->L2_VALEPRE )
						LjGrVVlPre( SL2->L2_VALEPRE	, SL1->L1_VEND	, SL2->L2_DOC	, SL1->L1_ESTACAO,;
						 			SL2->L2_PDV		, SL1->L1_EMISNF, SL1->L1_HORA	, SL1->L1_CLIENTE,;
						 			SL1->L1_LOJA 	, SL2->L2_SERIE )
					EndIf
				EndIf
			EndIf
		Next nI
	EndIf

	If cTipTEF == TEF_DISCADO  .AND. L010IsDirecao(L010GetGPAtivo())
		aDTEFPend :=  LJLoadDTEF()
	EndIf

	//Se cupom fiscal tiver aberto e nao tiver nenhum item registrado, cancela o Cupom Fiscal, pois os itens de auto-servico foram cancelados
	If lAbreCup .And. !lTemItemCF .And. Len(aReserva) > 0
		//Cancela o Cupom Fiscal, pois os itens registrados no cupom fiscal foram cancelados
		IFCancCup( nHdlECF )
		lAbreCup := .F.
		nVlrPagCF:=0
	EndIf

	For nI := 1 To Len(aParcelas)
		aSL4 := {	{ "L4_FILIAL"	,	xFilial("SL4")		}, ;
				 	{ "L4_NUM"     	,	SL1->L1_NUM			}, ;
				 	{ "L4_DATA"		,	aParcelas[nI][ 1]	}, ;
				 	{ "L4_FORMA"	,	aParcelas[nI][ 3]	}, ;
				 	{ "L4_ADMINIS"	,	aParcelas[nI][ 4]	}, ;
				 	{ "L4_NUMCART"	,	aParcelas[nI][ 5]	}, ;
					{ "L4_AGENCIA"	,	aParcelas[nI][ 6]	}, ;
				 	{ "L4_CONTA"	,	aParcelas[nI][ 7]	}, ;
				 	{ "L4_RG"		,	aParcelas[nI][ 8]	}, ;
				 	{ "L4_TELEFON"	,	aParcelas[nI][ 9]	}, ;
				 	{ "L4_TERCEIR"	,	aParcelas[nI][10]	}, ;
					{ "L4_OBS"		,	""					}, ;
					{ "L4_FORMAID"	,	aParcelas[nI][12]	} }

		If nTroco > 0
			If lMvLjTroco
				If aParcelas[nI][3] == cMoedaTroc				// Forma de pagamento que gerou o troco
					aAdd( aSL4, { "L4_TROCO", nTroco		 			   })
					If lMvLjTrDin == 1 .And. aParcelas[nI][3] == cSimbCor
						aAdd( aSL4, { "L4_VALOR", aParcelas[nI][2] - nTroco   })
					Else
						aAdd( aSL4, { "L4_VALOR", aParcelas[nI][2]  })
					EndIf
				Else
					aAdd( aSL4, { "L4_VALOR", aParcelas[nI][2]  })
				EndIf
			Else
				If aParcelas[nI][3] == cMoedaTroc	// Forma de pagamento que gerou o troco
					aAdd( aSL4, { "L4_VALOR", aParcelas[nI][2] - iIf(lTelaTroco,0,nTroco)   })
				Else
					aAdd( aSL4, { "L4_VALOR", aParcelas[nI][2]  })
				EndIf
			EndIf
		Else
			aAdd( aSL4, { "L4_VALOR", aParcelas[nI][2]   })
		EndIf

  		If Alltrim(aParcelas[nI][3]) $ "CC|CD"
	  		If lLjDespa
				If aParcelas[nI][16] .AND. aParcelas[nI][15] > 0
					aAdd( aSL4, { "L4_DESPRC",aParcelas[nI][15]})
				EndIF
				aAdd( aSL4, { "L4_BANPRC",aParcelas[nI][17]})
			EndIf
		EndIf
		
		If AllTrim(aParcelas[nI][3]) == "DT" //Pagamento Dotz 
			If lUsaTef .AND. lTefOk .AND.  oTEF:aRetDotz <> NIL .AND. Len(oTef:aRetDotz) > 0
				aAdd( aSL4, { "L4_VENDTEF", "S"} )
				aAdd( aSL4, { "L4_DOCTEF" , Right(oTEF:aRetDotz[1]:cNsuAutor,9) } )
				aAdd( aSL4, { "L4_NSUTEF" , Right(oTEF:aRetDotz[1]:cNsuSitef,6) } )
				aAdd( aSL4, { "L4_DATATEF", DTOS(oTEF:aRetDotz[1]:dDataTrans) } )				
				aAdd( aSL4, { "L4_HORATEF", oTEF:aRetDotz[1]:cHoraTrans} )
				aAdd( aSL4, { "L4_AUTORIZ", oTEF:aRetDotz[1]:cAutoriza } )		
			EndIf
		EndIf
		
		If Len(aParcelas[nI]) > 13
			aAdd(aSL4,{ "L4_CGC"		,	aParcelas[nI][14]} )
		EndIf

		If aParcelas[nI][3] $ "CH" .And. aParcelas[nI][10] .And. Len(aParcelas[nI]) >= 15
			aAdd(aSL4,{ "L4_NOMECLI"	,	aParcelas[nI][15]} )
		Endif

	    If Len(aParcelas[nI]) >= 18 .And. !Empty(aParcelas[nI][18])
	    	aAdd(aSL4,{ "L4_COMP"	,	aParcelas[nI][18]} )
	    EndIf  
		If LjNfPafEcf(SM0->M0_CGC)
			aAdd( aSL4, { "L4_SERPDV",LJGetStation("SERPDV")})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se estivermos utilizando múltiplas transações Tef, deveremos gravar³
		//³todos os retornos.                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUsaTef .AND. ( lTefOk .OR. Len( aTefBKPCS ) > 0 ) .AND. Alltrim(aParcelas[nI][3]) $ _FORMATEF

			If cTipTEF == TEF_CLISITEF
				nX := 1
				cIdCartao := aParcelas[nI][12]

				While nX <= Len(aPgtos)
					If aPgtos[nX][12] == cIdCartao
						cAdminis := aPgtos[nX][4]
					EndIf

					++nX
				End

				If lMFE .And. Len(aIdPgtoMfe) > 0 
					aAdd( aSL4, { "L4_IDPGVFP", aIdPgtoMfe[nId][1]})
					If !(aParcelas[nI][12] == aParcTEF[nId][4])	//caso o ID do cartão das parcelas regitradas mude, incremento variável do ID
						nId++
					EndIf	
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gerando os dados do TEF para a tabela SL4													   		   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSL4 := LjTEFGeraSL( 	aSL4				,"SL4"				, aParcelas[nI][1], aParcelas[nI][3], ;
										aParcelas[nI][12]	,aParcelas[nI][4]	, aParcelas[nI][6], aParcelas[nI][5], ;
										aParcelas[nI][4]	,nI 				, @cAdminis )

			ElseIf cTipTEF == TEF_DISCADO .AND. aParcelas[nI][3] $ _FORMATEF

				If lTEFMult
					cIdCartao := Alltrim( aParcelas[nI][12] )
				Else
					cIdCartao := Alltrim( aParcelas[nI][06] )
				EndIf

				nPosTefDados := aScan(aTefDados,{|x|,Alltrim(x[19]) == cIdCartao})
				If nPosTefDados > 0 .AND. Len(aTEFDados) >= 1 .AND. Len(aTEFDados[nPosTefDados]) >= 15
					aAdd( aSL4, { "L4_VENDTEF","S"})
					aAdd( aSL4, { "L4_DATATEF",aTefDados[nPosTefDados][2]})
					aAdd( aSL4, { "L4_HORATEF",aTefDados[nPosTefDados][3]})
					aAdd( aSL4, { "L4_AUTORIZ",aTefDados[nPosTefDados][5]})
					aAdd( aSL4, { "L4_INSTITU",aTefDados[nPosTefDados][8]})
					aAdd( aSL4, { "L4_DOCCANC",aTefDados[nPosTefDados][6]})
					aAdd( aSL4, { "L4_DATCANC",aTefDados[nPosTefDados][12]})
					aAdd( aSL4, { "L4_HORCANC",aTefDados[nPosTefDados][7]})

					If  L010IsDirecao(L010GetGPAtivo())
						aAdd( aSL4, { "L4_NSUTEF" ,Right(aTefDados[nPosTefDados][9],6)})
						aAdd( aSL4, { "L4_DOCTEF" ,aTefDados[nPosTefDados][5]})
					Else
						aAdd( aSL4, { "L4_NSUTEF" ,aTefDados[nPosTefDados][9]})
						aAdd( aSL4, { "L4_DOCTEF" ,aTefDados[nPosTefDados][4]})
					EndIf

					aAdd( aSL4, { "L4_TIPCART",aTefDados[nPosTefDados][10]})

					If Empty(aTefDados[nPosTefDados][15])
						aAdd( aSL4, { "L4_FORMPG",If((cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0),If(Len(aFormCtrl)>1,aFormCtrl[2][1],aFormCtrl[1][1]),aParcelas[nPosTefDados][3]) })
					Else
						aAdd( aSL4, { "L4_FORMPG",aTefDados[1][15]})
					EndIf

					aAdd( aSL4, { "L4_NOMECLI",	"RD: " + Upper(Alltrim(aTefDados[nPosTefDados][8])) + " / BD: " + Upper(Alltrim(aTefDados[nPosTefDados][18])) } )
				EndIf

			EndIf
		Else
			If Len(aNSUVndTef) > 0
				nPosAux := Ascan(aNSUVndTef, {|x| AllTrim(x[1])+x[2] == AllTrim(aParcelas[nI][3])+aParcelas[nI][12]}) //Forma + ID											
				cNSUVndTef := IIf( nPosAux > 0 , aNSUVndTef[nPosAux][4], "")
				If !Empty(AllTrim(cNSUVndTef))
					aAdd( aSL4, { "L4_VENDTEF", "S"})
					aAdd( aSL4, { "L4_DOCTEF" , cNSUVndTef } )
					aAdd( aSL4, { "L4_NSUTEF" , Right(cNSUVndTef,6) } )
					aAdd( aSL4, { "L4_DATATEF", Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2) } )
				EndIf
			EndIf
        EndIf

		/*Se trabalha com conceito de acrescimo separado,
		Exibir o valor do acrescimo separado da parcela*/
		If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
	    	If ValType(aParcelas[nI][13]) == "N"
				aAdd( aSL4, { "L4_ACRSFIN",aParcelas[nI][13]})
			Endif
		Endif

		If SL4->(ColumnPos("L4_DESCMN")) > 0 .AND. Len(aParcelas[nI])>= 15 .and. ValType(aParcelas[nI][15]) == "N"
			aAdd( aSL4, { "L4_DESCMN",aParcelas[nI][15]})
			LjGrvLog("Multineg", Chr(10) + Chr(13) + "L4_DESCMN - Adicionando o Conteudo no aSL4 L4_DESCMN ", aParcelas[nI][15]  )
		Endif
			
		If cPaisLoc <> "BRA"
		   Aadd(aSL4,{"L4_MOEDA",aParcelas[nI][11]})
		EndIf

		If ExistBlock("FRTGRSL4")
			LjGrvLog(Nil, "Ponto de Entrada FRTGRSL4 - Parâmetros:" , {aSL4,nI})
			aSL4 := ExecBlock("FRTGRSL4",.F.,.F.,{aSL4,nI})
			LjGrvLog(Nil, "Ponto de Entrada FRTGRSL4 - Retorno",aSL4)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Cartao Fidelidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLjcFid
			If (aPgtos[nI][ 2] > 0) .AND. (AllTrim(aPgtos[nI][3]) = "FID")
				If !Empty(Fa271FgFid())
					aAdd( aSL4, { "L4_NUMCFID",	Fa271FgFid() } )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Recarga do cartao fidelidade processada: ³
					//³B - Via processo batch (LJGRVBATCH)      ³
					//³W - Via WebService(LJCCARFID) 		    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Ca280CkWs ()
						//W - Via WebService(LJCCARFID)
						aAdd( aSL4, { "L4_PROCFID", 	"W"} )
						Fa271aSpfw(.T.)
					Else
						//B - Via processo batch (LJGRVBATCH)
						aAdd( aSL4, { "L4_PROCFID", 	"B"} )
						Fa271aSpfw(.F.)
					Endif
				Endif
			EndIf
		EndIf

		If Frt060Ret("NCC_MENOR")  // Se a NCC for maior ou igual ao valor total da venda, nao gera SL4.
			FR271BGeraSL("SL4", aSL4, .T.)
	    Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o status de recebido no vale presente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim(aParcelas[nI][3]) == "VP"
			LjGrRVlPre( aParcelas[nI][5], SL1->L1_OPERADO	, SL1->L1_DOC	, SL1->L1_ESTACAO,;
						SL1->L1_PDV		, SL1->L1_EMISNF	, SL1->L1_HORA	, SL1->L1_CLIENTE,;
						SL1->L1_LOJA 	, SL1->L1_SERIE		)
		EndIf
	Next nI
	aSL1 := {{"L1_SITUA",	"10"}}						// "10" - Encerrado a Venda
	FR271BGeraSL("SL1", aSL1, .F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Compensacao da NCC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFrontNCC
		If Frt060Ret("NCC_USADA") > 0
			nValCredito	:= Abs(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA"))

			aSL1 := {{"L1_CREDITO"	, nValCredito }	}
			FRTGeraSL("SL1", aSL1, .F.)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LjAnalisaLeg(4)[1]
		If lGaveta
			If (!Empty(LJGetStation("PORTGAV"))) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
				GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
			Else
				IFGaveta(nHdlECF)
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha desconto ou desconto financeiro no total do cupom             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotDescont := nVlrDescCPg + nVlrDescTot + nTotDedIcms
	LjLogFront("FRT271G - VARIAVEIS DE DESCONTO")
	LjLogFront("FRT271G - nVlrDescCPg",nVlrDescCPg)
	LjLogFront("FRT271G - nVlrDescTot",nVlrDescTot)
	LjLogFront("FRT271G - nTotDedIcms",nTotDedIcms)
	LjLogFront("FRT271G - nVlrGar",nVlrGar)

	If !lEmitNfce .and. lAbreCup
		IFStatus(nHdlECF, "42", @cRet) // Captura o Subtotal da impressora
		nVlrTotCF := Val( SubStr(cRet,1,Len(cRet)-2) + "." + SubStr(cRet, Len(cRet)-1) )
	EndIf
	
	If nTotDescont > 0

		lImpDesc := .T.
		If cPaisLoc == "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe acrescimo financeiro. Caso exista subtrai do desconto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            nRet := 0
			//So da o desconto se o cupom fiscal estiver aberto e so verifica se estiver importando orcamento
			nRet := IFStatus(0, "5", "")				// Verifica Cupom Aberto
			If	nRet <> 7
				lCupAberto := .F.
				nRet := 0
			EndIf
            If nVlrAcreTot > 0
            	If nVlrAcreTot > nTotDescont
            		nVlrAcreTot -= nTotDescont
            		lImpDesc := .F.
            		nRet	 := 0
            	Else
            		nTotDescont -= nVlrAcreTot
            	EndIf
            EndIf

            If lImpDesc
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alteracao especifica para atender a legislacao do SEFAZ ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If LjAnalisaLeg(14)[1]
					If nVlrDescCPg > 0 .AND. cItemCond<>"CN" .OR. (cItemCond=="CN" .AND. lCondNegF5)
						If Len(aReserva) > 0
							If lAbreCup .AND. lCupAberto
								//Valor do Desconto a ser registrado no Cupom Fiscal
								nDesTotReg := nVlrDescCPg*A271FatRes(aReserva, (nVlrTotal + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,,nValorFSD)[1]   
								nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg,14,2)))
							Else
								nRet := 0
							EndIf
						ElseIf lTemServic
							If lAbreCup .AND. lCupAberto
								//Valor do Desconto a ser registrado no Cupom Fiscal
								nDesTotReg := nVlrDescCPg*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot))[1]
								nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg,14,2)))
							Else
								nRet := 0
							EndIf
						Else
							If lCupAberto
								//Valor do Desconto a ser registrado no Cupom Fiscal
								nDesTotReg := nVlrDescCPg
								nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg- nVlrGar,14,2)))
							Else
								nRet := 0
							EndIf
						EndIf
					Else
              			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               			//³BOPS 107985: O tratamento abaixo tem efeito quando se     ³
                        //³carrega um orcamento do Sigaloja (Venda Assistida), que,  ³
                        //³quando gravado (em aberto), teve desconto. Antes desta    ³
                        //³correcao, o desconto era impresso no cupom fiscal como    ³
                        //³troco ou a primeira forma de pagamento encontrada no ECF. ³
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aReserva) > 0
							If lAbreCup .AND. lCupAberto
								//Valor do Desconto a ser registrado no Cupom Fiscal
								nDesTotReg := nTotDescont*A271FatRes(aReserva, (nVlrTotal - nVlrGar + nVlrDescTot)-nVlrAcreTot,nVlrTotRe,nVlrGar )[1]       
							    nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg,14,2)))
							Else
								nRet := 0
						    EndIf
						ElseIf lTemServic
							If lAbreCup .AND. lCupAberto
								//Valor do Desconto a ser registrado no Cupom Fiscal
								nDesTotReg := nTotDescont*A271FatSrv(nVlrItServ, (nVlrTotal + nValCredito + nVlrDescTot))[1]
							    nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg,14,2)))
							Else
								nRet := 0
						    EndIf
						Else
					    	If lCupAberto
								//Valor do Desconto a ser registrado no Cupom Fiscal
								nDesTotReg := nTotDescont
					    		nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg - nVlrGar,14,2)))
							Else
								nRet := 0
							EndIf
						EndIf
					    If nRet <> 0
					        nRet := 0 //Zera nRet, significando que o desconto ja' foi concedido anteriormente
					    EndIf
					EndIf
				Else
					If Len(aReserva) > 0
						If lAbreCup .and. lCupAberto
							//Valor do Desconto a ser registrado no Cupom Fiscal Retirado o valcredito na soma
							nDesTotReg := nTotDescont*A271FatRes(aReserva, (nVlrTotal - nValorFSD  + nVlrDescTot)-nVlrAcreTot,nVlrTotRe)[1]
							nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg,14,2)))
							LjLogFront("FRT271G - 1-COMANDO IMP DESC ",nDesTotReg)
						Else
							nRet := 0
						EndIf
					ElseIf lTemServic
						If lAbreCup .and. lCupAberto
							//Valor do Desconto a ser registrado no Cupom Fiscal
							nDesTotReg := nTotDescont*A271FatSrv(nVlrItServ, (nVlrTotal + nVlrDescTot))[1]
							nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg,14,2)))
						Else
							nRet := 0
						EndIf
					Else
						If lCupAberto
							//Valor do Desconto a ser registrado no Cupom Fiscal
							nDesTotReg := nTotDescont
							nRet := IFDescTot(nHdlECF, AllTrim(Str(nDesTotReg - nVlrGar,14,2)))
							LjLogFront("FRT271G - 2-COMANDO ENV DE DESC ",nDesTotReg)
						Else
							nRet := 0
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			nRet := IFDescTot(nHdlECF, AllTrim(Str(aDadosJur[9] - nVlrGar,TAMSX3("L1_VLRTOT")[1],TAMSX3("L1_VLRTOT")[2])),;
					AllTrim(Str(nVlrTotal - nVlrGar,TAMSX3("L1_VLRTOT")[1],TAMSX3("L1_VLRTOT")[2])))
			LjLogFront("FRT271G - 3-COMANDO ENV DE DESC ",nDesTotReg)
		EndIf
		If nRet <> 0
			// "Não foi possível registrar o Desconto no Total do Cupom. Operação não efetuada.", "Atenção"
			HELP(' ',1,'FRT033')
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha acrescimo no total do cupom                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Somente condicoes de pagamento do SE4 ou Orcamentos Importados da Retaguarda tem acrescimo
	If nVlrAcreTot > 0 .AND. (cItemCond<>"CN" .OR. (cItemCond=="CN" .AND. lCondNegF5) .OR. lImpOrc)
		If cPaisLoc == "BRA"
			If !lImpDesc
				If Len(aReserva) > 0
					If lAbreCup
						//Valor do Acrescimo a ser registrado no Cupom Fiscal
						If lLj7Arred
							nAcrTotReg := Lj7Arred(1,2, nVlrAcreTot*A271FatRes(aReserva, SL1->L1_VLRTOT -nVlrAcreTot,nVlrTotRe, nVlrGar>0,,nValorFSD )[1] )
						Else
							nAcrTotReg	:= NoRound(nVlrAcreTot*A271FatRes(aReserva, SL1->L1_VLRTOT -nVlrAcreTot,nVlrTotRe, nVlrGar>0,,nValorFSD )[1], nDecimais)
						EndIf

						nRet := IFAcresTot( nHdlECF, Str(nAcrTotReg,14,2) )
					EndIf
				ElseIf lTemServic
					If lAbreCup
						//Valor do Acrescimo a ser registrado no Cupom Fiscal
						nAcrTotReg := NoRound(nVlrAcreTot*A271FatSrv(nVlrItServ, SL1->L1_VLRTOT)[1], nDecimais)
						nRet := IFAcresTot( nHdlECF, Str(nAcrTotReg,14,2) )
					EndIf
				Else
					//Valor do Acrescimo a ser registrado no Cupom Fiscal
					nAcrTotReg := nVlrAcreTot
					nRet := IFAcresTot( nHdlECF, Str(nAcrTotReg - nVlrGar,14,2) )
				EndIf
			Else
				nRet := 0
			EndIf
		Else
			nRet := IFAcresTot( nHdlECF, Str(aDadosJur[1] - nVlrGar,TAMSX3("L1_VLRTOT")[1],TAMSX3("L1_VLRTOT")[2]) )
		EndIf
		If nRet <> 0
			// "Não foi possível registrar o Acréscimo no Total do Cupom. Operação não efetuada."
			HELP(' ',1,'FRT040')
		EndIf
	ElseIf lMvLJurCc .AND. Len(aTxJurAdm) > 0 .AND. aTxJurAdm[3] > 0
		//³ Caso exista juros da administradora sendo o parametro MV_LJJURCC = .T. ³
		//Valor do Acrescimo a ser registrado no Cupom Fiscal
		nAcrTotReg := aTxJurAdm[3]
		nRet := IFAcresTot( nHdlECF, Str(nAcrTotReg,14,2) )
	EndIf

	If cPaisLoc == "BRA" .And. !lEmitNfce 
		//Tratamento quando venda com nao fiscal e fiscal
		If Len(aReserva) > 0
			nVlrDescCF	:= nDesTotReg
		Else
			nVlrDescCF	:= nTotDescont
			nVlrTotCF	:= nValor
		EndIf
		
		//Novo arredondamento - Bematech /Daruma / Sweda
		//Faz ajustes nos valores dos itens de acordo com a regra de arredondamento da impressora
		If lHabNovoArred .And. Len(aGrupTrib) > 1  //Apenas se existir mais do que uma Tributacao diferente no array aGrupTrib
			//1o. Passo: Ja foi feito. Foi agrupado no array aGrupTrib, todos os valores por aliquotas.

			//2o. Passo: Calcula o Percentual efetivo do Desconto ou do Acrescimo (truncado conforme regra da impressora, funcao Lj7DecECf() )
			If nVlrDescCF > 0
				nPercEfet := NoRound( ((nVlrDescCF / nVlrTotCF) * 100), nDecEcf) / 100
			ElseIf nVlrAcreTot > 0
				nPercEfet := NoRound( ((nVlrAcreTot / nValor) * 100), nDecEcf) / 100
			EndIf

			LjLogFront("FRT271G - VAI INICIALIZAR O RATEIO DA IMPRESSORA FISC")
			LjLogFront("FRT271G - nVlrDescCF",nVlrDescCF)
			LjLogFront("FRT271G - nPercEfet",nPercEfet)

			If nPercEfet > 0
				If lLj7Arred
					Lj7Arred(1) // limpa array statico da função de arredondamento
				EndIf

				DbSelectArea("SL2")
				SL2->(DbSetOrder(1))
				//Este laco faz o acerto dos valores dos Itens
				For nX := 1 To Len(aGrupTrib)

					//3o. Passo: Calcula o valor de Desconto ou Acrescimo para cada grupo de Tributacao (truncado em duas casas decimais)
					aGrupTrib[nX][06] := NoRound( aGrupTrib[nX][02] * nPercEfet, 2 )
					nVrDcAcTrb 	:= aGrupTrib[nX][06]
					nTotXAux 	+= nVrDcAcTrb //Acumula o total de Desconto ou Acrescimo

					//Percorre todos os itens deste grupo de Tributacao para acertar os valores de Desconto ou Acrescimo de cada item
					For nY := 1 To Len(aGrupTrib[nX][05])

	  					//Calcula a proporcionalizacao de Acrescimo ou Desconto para este item
	  					nPercProduto := aGrupTrib[nX][05][nY][02] / aGrupTrib[nX][02]

	  					//Calcula o valor de Acrescimo ou Desconto para este item
						nVrDcAcIte := Lj7Arred(2,3,nVrDcAcTrb * nPercProduto  )

	  					nPosIt := aGrupTrib[nX][05][nY][01]

	  					If SL2->( DbSeek(xFilial("SL2")+SL1->L1_NUM+FR271BPegaIT(aItens[nPosIt][AIT_ITEM])) )

		  					//Ajusta o Valor do Item
							If nVlrDescCF > 0
								nVlrIT 		:= aGrupTrib[nX][05][nY][02] - nVrDcAcIte
								nResiduAux 	:= nVlrIT - SL2->L2_VLRITEM
								nVlrIT		:= SL2->L2_VLRITEM + nResiduAux
								aSL2 := {{"L2_VRUNIT" ,	nVlrIT/aItens[nPosIt][AIT_QUANT]},;
				   						 {"L2_VLRITEM",	nVlrIT},;
				   						 {"L2_DESCPRO", SL2->L2_DESCPRO - nResiduAux }}
				   				// Atualiza o valor do item com o desconto
								aGrupTrib[nX][05][nY][03] := nVlrIT
							ElseIf nVlrAcreTot > 0
								nVlrIT 		:= aGrupTrib[nX][05][nY][02] + nVrDcAcIte
								nResiduAux 	:= nVlrIT - SL2->L2_VLRITEM
								nVlrIT		:= SL2->L2_VLRITEM + nResiduAux
								aSL2 := {{"L2_VRUNIT" ,	nVlrIT/aItens[nPosIt][AIT_QUANT]},;
										 {"L2_VLRITEM",	nVlrIT}}
				   				// Atualiza o valor do item com o Acrescimo
				   				aGrupTrib[nX][05][nY][03] := nVlrIT
								If lCpoAcresSL2
									aAdd(aSL2,{"L2_VALACRS",SL2->L2_VALACRS + nResiduAux})
								EndIf
							EndIf

			   				FR271BGeraSL("SL2", aSL2, .F.)
							LjLogFront("FRT271G - AJUSTE NO RATEIO FISCAL ITEM "+SL2->L2_ITEM)
							LjLogFront("FRT271G - SL2 alterado",aSL2)
				   		EndIf
					Next nY

				Next nX

				//4o. Passo: Calculo do residuo
				nResiduAux := 0
				If nVlrDescCF > 0
					nResiduAux := nVlrDescCF - nTotXAux
				ElseIf nVlrAcreTot > 0
					nResiduAux := nVlrAcreTot - nTotXAux
				EndIf

				//5o. Passo: Verifica se existe algum residuo para ser somando no produto de maior valor pertencente ao grupo de aliquota de maior valor
				//Obs.: Se existir valores iguais em grupos de aliquotas diferentes, o residuo ira sempre para a maior aliquota.
				If nResiduAux > 0

					//Inicializa as variaves com o primeiro grupo de aliquotas
					nMaior 		:= 1
					nValMaior   := aGrupTrib[1][2]
					nBasMAliq 	:= 0
					nTotAliqs	:= 0

					For nI := 1 to ( Len(aGrupTrib) - 1 )
						If nValMaior == aGrupTrib[nI + 1][2] //Se os valores dos grupos de aliquota forem iguais, o residuo ira sempre para a maior aliquota.
							If Val(Substr(aGrupTrib[nI][1],2,2)) < Val(Substr(aGrupTrib[nI+1][1],2,2))
								nMaior 		:= nI + 1
								nValMaior	:= aGrupTrib[nI + 1][2]
							EndIf
						ElseIf nValMaior < aGrupTrib[nI + 1][2]
							nMaior 		:= nI + 1
							nValMaior   := aGrupTrib[nI + 1][2]
						EndIf
				    Next nI
	  				DbSelectArea("SL2")
	  				DbSetOrder(1)
	  				If Len(aGrupTrib[nMaior][3]) > 1
	  					//Se existir mais de um produto com o mesmo valor no mesmo grupo de aliquota, distribui o residuo entre esses produtos (de 1 em 1 centavo)
	  					nResiduoIT := If( nResiduAux < 0, -0.01, 0.01 )
	  				Else
						nResiduoIT := nResiduAux
	  				EndIf
	  				nI := 0
	  				While Abs(nResiduAux) >= 0.01
	  					nI++
	  					nPosIt := aGrupTrib[nMaior][3][nI]

	  					// Ordena em ordem crescente os valores dos itens dentro do grupo de tributação
	  					ASORT(aGrupTrib[nMaior][5], , , { | x,y | x[3] < y[3] } )
 						nPosItMenor :=  aGrupTrib[nMaior][5][1][1]
  						nPosItMaior :=  aGrupTrib[nMaior][5][Len(aGrupTrib[nMaior][5])][1]

                        // regra para quando houver desconto , tirar do item de maior valor e
                        // quando houver acrescimo , acrescentar a diferença no item de menor valor
						If nVlrDescCF > 0
							nPosIt := nPosItMaior
						ElseIf nVlrAcreTot > 0
							nPosIt := nPosItMenor
					    EndIf

	  					nResiduAux -= nResiduoIT
				   		If SL2->( DbSeek(xFilial("SL2")+SL1->L1_NUM+FR271BPegaIT(aItens[nPosIt][AIT_ITEM])) )
							If nVlrDescCF > 0
								nVlrIT := SL2->L2_VLRITEM - nResiduoIT
								aItens[nPosIt][AIT_VLRITEM] := nVlrIT

								aSL2 := {{"L2_VRUNIT",	nVlrIT/aItens[nPosIt][AIT_QUANT]},;
				   						 {"L2_VLRITEM",	nVlrIT}}

								nDescIT := SL2->L2_DESCPRO + nResiduoIT
								aAdd(aSL2,{"L2_DESCPRO",nDescIT})
							ElseIf nVlrAcreTot > 0
								nVlrIT := SL2->L2_VLRITEM + nResiduoIT
								aItens[nPosIt][AIT_VLRITEM] := nVlrIT

								aSL2 := {{"L2_VRUNIT",	nVlrIT/aItens[nPosIt][AIT_QUANT]},;
				   						 {"L2_VLRITEM",	nVlrIT}}

						   		If lCpoAcresSL2
									nAcresIT := SL2->L2_VALACRS + nResiduoIT
									aAdd(aSL2,{"L2_VALACRS",nAcresIT})
								EndIf
							EndIf
				 			FR271BGeraSL("SL2", aSL2, .F.)
							LjLogFront("FRT271G - RESIDO DO ITEM"+SL2->L2_ITEM)
							LjLogFront("FRT271G - SL2 GRAVADO",aSL2)
				 		EndIf
		  				If nI == Len(aGrupTrib[nMaior][3])
			  				nI := 0
			  			EndIf
					End
				EndIf

			EndIf

		EndIf
	EndIf

	lEncerra := .F.
	// Alteracao especifica para atender a legislacao do SEFAZ. Exclusivo para o
	// estado do Amazonas
	LjLogFront("FRT271G - PAGAMENTO ENVIADO",cFormaPagto)
	If LjAnalisaLeg(4)[1] .AND. cItemCond=="CN" .AND. !lCondNegF5
		nRet := 0
	Else
		// Indica que sera emitido um cupom vinculado ao cupom fiscal emitido.
		// Especifico para impressora Urano versao 3.00
		If lUsaTef .AND. lTefOk .AND. (nCartao + nValorDebi + nCheques) > 0 .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_CLISITEF // Sem Client / Com Client / Discado
			cVinculado := "1"
		EndIf
		If Len(aReserva) > 0
			If nTotDescont > 0
				nVlrPagto	:=	NoRound((nVlrTotal - nValorFSD)*A271FatRes(aReserva, (nVlrTotal-nValorFSD +nTotDescont+nValCredito),nVlrTotRe,,nValorFSD)[1] , nDecimais)
			ElseIf nVlrAcreTot > 0
				nVlrPagto	:=	NoRound((nVlrTotal - nValorFSD)*A271FatRes(aReserva, ((nVlrTotal-nValorFSD +nValCredito+nVlrDescTot)-nVlrAcreTot),nVlrTotRe,,nValorFSD)[1] , nDecimais)
			Else
				nVlrPagto	:=	A271FatRes(aReserva, (nVlrTotal-nValorFSD +nValCredito+nVlrDescTot),nVlrTotRe,,nValorFSD)
			EndIf
		ElseIf lTemServic
			If nTotDescont > 0
				nVlrPagto	:=	NoRound(nVlrTotal*A271FatSrv(nVlrItServ, (nVlrTotal+nTotDescont+nValCredito))[1], nDecimais)
			ElseIf nVlrAcreTot > 0
				nVlrPagto	:=	NoRound(nVlrTotal*A271FatSrv(nVlrItServ, ((nVlrTotal+nValCredito+nVlrDescTot)-nVlrAcreTot))[1] , nDecimais)
			Else
				nVlrPagto	:=	NoRound(nVlrTotal*A271FatSrv(nVlrItServ, (nVlrTotal+nValCredito+nVlrDescTot))[1], nDecimais)
			EndIf
		EndIf

		// Emite os pagamentos ao ECF
		lTentarNovamente := .T.
		While lTentarNovamente
			If Len(aReserva) > 0 .Or. lTemServic .Or. lIsVendaVP

				If lTemItemCF .AND. lEmitNFCe .And. ExistFunc("LjNFCeSetObj")

					aAuxStr := StrTokArr( cFormaPagto, "|" )
					For nI := 1 to Len(aAuxStr) step 2
						oLjNFCEPag := LJNFCEPAG():New(aAuxStr[nI], aAuxStr[nI+1])
						//Alimenta o objeto estatico oNFCe (LOJNFCE.PRW)
						LjNFCeSetObj(oLjNFCEPag)
					Next
				EndIf

				If lAbreCup
					// Tratamento realizado para ajustar as formas de pg do sistema com o valor q ta no ECF
					aSubPgto 	:= StrToKarr(cFormaPagto ,"|")          		// Array com as formas q vao para o ecf]
					nSubTPag	:= 0
					For nX := 1 To Len(aSubPgto)
						nSubTPag += Val(aSubPgto[nX]) 							// Soma as formas de pagamento que vao para ecf
					Next nX
					IFStatus(nHdlECF, "42", @cRet)								// Captura o Subtotal da impressora
					nDifPag := Val(SubStr(cRet,1,len(cRet)-2)+"."+SubStr(cRet,len(cRet)-1))

					If nDifPag > 0	.AND. nSubTPag > 0 // Subtotal da impressora (pois algumas nao retornam o comando)
						nDifPag := nDifPag - nSubTPag							// Calcula a diff entre ecf e sistema
						If nDifPag <> 0 .AND. Abs(nDifPag) < 0.05 // Mais de 5 centavos foge do intuito da funcao e nao deve ajustar
							LjLogFront("FRT271G - DIF NO PAGAMENTO ",nDifPag)
							If nDifPag > 0
								If Len(aSubPgto) > 1 .AND. Val (aSubPgto[2]) > 0
									aSubPgto[2] := Str(Val(aSubPgto[2]) + Abs(nDifPag)) // Vai sempre jogar a diff na primeira forma

									//Verifica se forma de pagamento credito para ajustar a diferenca no Nao-Fiscal
									If AllTrim(aSubPgto[1]) == AllTrim(Tabela("24","CR",.F.))
										nVlrNccCF += Abs(nDifPag)
									EndIf
								EndIf
							ElseIf nDifPag < 0
								If Len(aSubPgto) > 1 .AND. Val (aSubPgto[2]) > 0
									aSubPgto[2] := Str(Val(aSubPgto[2]) - Abs(nDifPag)) // Vai sempre jogar a diff na primeira forma

									//Verifica se forma de pagamento credito para ajustar a diferenca no Nao-Fiscal
									If AllTrim(aSubPgto[1]) == AllTrim(Tabela("24","CR",.F.))
										nVlrNccCF -= Abs(nDifPag)
									EndIf
								EndIf
							EndIf
							cFormaPagto := ""                                   // Refaz a string para enviar p/ ecf
							For nX := 1 To Len(aSubPgto)
								cFormaPagto += Alltrim(aSubPgto[nX])+"|"		// Preenche a string com as formas de pagamento
							Next
						EndIf
					EndIf

		   			nRet := IFPagto(nHdlECF, cFormaPagto, cVinculado, nVlrPagto,;
									nDecimais, NIL, aImpsSL1)
					LjLogFront("FRT271G - VLRPG ENV NO PAG",nVlrPagto)
				EndIf
			ElseIf !lEmitNFCe
				//Ordena as formas de pagamento do valor menor para o maior para que o troco seja impresso
				cFormaPagto := F271GReord(@cFormaPagto)			//Ordena Formas de Pagament
				nRet := IFPagto(nHdlECF, cFormaPagto, cVinculado, nVlrTotal,;
								nDecimais, NIL, aImpsSL1)
				LjLogFront("FRT271G - VLRTOT ENV NO PAG",nVlrTotal)
			EndIf
			LjLogFront("FRT271G - RETORNO DO PAGAMENTO ENVIADO",nRet)

			lTentarNovamente := nRet <> 0 .AND. lAbreCup .AND. MsgYesNo(STR0067) //"Problema com a impressão do pagamento. Tentar novamente?"

		End
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a troca automatica da serie do checkout de acordo com a tabela SL6.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjAltSerie( cEstacao, cDoc )

	If nRet == 0
		// Verifica se tem cupom reduzido
		If lUsaTef .AND. cTipTef == TEF_CLISITEF .AND. lCartao
			If oTef:CupomReduz()
				If !Empty(oTef:cCupomRedu)
					cMsgCupom := oTef:cCupomRedu + CHR(10) +  cMsgCupom
					cMsgCupom := StrTran(cMsgCupom, ",", ".")
				EndIf
			EndIf
		EndIf

		//Caso o ECF tenha a impressão do cliente na finalização do cupom deve-se enviar os dados
		//não valida o LjAnalisaLeg pois esta configuração e parametrizavel
		If	!lEmitNFCe .And. !lUseSAT .And. (SL1->(ColumnPos("L1_CGCCLI")) > 0) .And. lLjxDCGC .And.;
			(lLjInfDocCli .Or. lLj950ImpCpf)

			aRetInfDocCli	:= {}

			If !lImpCpfNpj .And. ((lLj950ImpCpf) .and. (lLjInfDocCli .And. LjInfDocCli() > 1))
				aRetInfDocCli := LjxDCGC(Nil,Nil,@lImpCpfNpj,@cMsgCupom,nVlrTotal)
				cCpfCli := aRetInfDocCli[1]
			EndIf

			If 	Len(aRetInfDocCli) > 0 .And.;
			 	!(Empty(aRetInfDocCli[1]) .And. Empty(aRetInfDocCli[2]) .And. Empty(aRetInfDocCli[3]))

				aSL1 := {}
				Aadd( aSL1 , {"L1_CGCCLI", aRetInfDocCli[1] })
				FR271BGeraSL("SL1", aSL1, .F.)

				nRet := IFIdCliente(nHdlECF , @lImpCpfNpj , aRetInfDocCli)
			EndIf
		EndIf
				
		//Verifica se existe um sinal de & (macro substituicao), dessa forma
		//possibilita ao usuario montar um parametro o qual seja executada uma condicional.
		//Foi necessario fazer dessa forma, pois caso contrario acarretaria
		//erro na base de clientes ja implantada.
		lTentarNovamente := .T.
		While lTentarNovamente 
			If lFechouCupom
				lTentarNovamente := .F.
			Else
				If lTemItemCF .AND. (lEmitNFCe .OR. lUseSAT)
					aNotas := {}
					If !lUseSAT
						//confirma a utilizacao do numero da nota fiscal
						LjxDNota(LJGetStation("SERIE"),3,.F.,1, @aNotas)

						If Empty(aNotas) //Serie nao cadastrada no SX5
							nRet := -1
							Exit
						EndIf
						cDoc := aNotas[1][2]
					Else
						cDoc := ""
					EndIf

					aSL1 := {{"L1_DOC", cDoc},;
							  {"L1_HORA", Time()}}
					FRTGeraSL("SL1", aSL1, .F.)

					If ExistFunc("Lj7AjstSLX")
						//Ajusta o campo LX_CUPOM com o numero do DOC utilizado na venda.
						Lj7AjstSLX(SL1->L1_DOC, SL1->L1_NUM)
					EndIf
					
					nItem := 0
					
					For nI := 1 To Len(aItens)
						If !aItens[nI][AIT_CANCELADO]
							nItem++
							If SL2->( MsSeek(xFilial("SL2") + SL1->L1_NUM + FR271BPegaIT(aItens[nI][AIT_ITEM])) )
								aSL2 := {	{"L2_DOC"	, cDoc					},;
											{"L2_ITEM"	, FR271BPegaIT(nItem)}}
								FR271BGeraSL("SL2", aSL2, .F.)					
							EndIf
						EndIf
					Next nI

					If !lUseSAT
						LjMsgRun( "Aguarde... Processando NFC-e Orcamento: " + SL1->L1_NUM + " - Doc.: " + SL1->L1_DOC,, {|| nRet := LjNFCeGera(SL1->L1_FILIAL,SL1->L1_NUM, @cKeyNfce, Nil, Nil, @cMsgErro)})
					Else
						
						cXML := LjSATXml()  // Gera XML
						
						LjGrvLog( SL1->L1_NUM, "SAT - Gerado XML ")
						
						LjMsgRun( StrTran(STR0111,"SAT", cSiglaSat),, {|| aRetSAT := LJSATComando({"12","EnviarDadosVenda",LJSATnSessao(),cPass,cXML})}) //"Aguarde... Processando envio do SAT"

						aSATDoc := {}

						If Len(aRetSAT) >= 5 .And. Val(aRetSAT[2]) == 6000 //retorno de sucesso
							aSL1 := {}

							If ExistFunc("LJSATRetDoc")
								aSATDoc := LJSATRetDoc(Decode64(aRetSAT[5]))  //retorna o doc e serie gerado no SAT

								cDoc := cDocSat	:= aSATDoc[1] 
								cSerieSat			:= aSATDoc[2]

								LjGrvLog( SL1->L1_NUM, "SAT - Numeração do Doc e Serie do SAT", aSATDoc )

								aAdd( aSL1, { "L1_HORA", Transform(SubStr(aRetSAT[6],9,Len(aRetSAT[6])),"@R 99:99:99") } )
								aAdd( aSL1, { "L1_DOC" , cDoc } )
								Aadd( aSL1, {"L1_ESPECIE", "SATCE" } )
								//Numero de série do SAT 
								If SL1->(ColumnPos("L1_SERSAT")) > 0
									aAdd( aSL1, { "L1_SERSAT" , cSerieSat } )
								EndIf
								//Grava chave da venda SAT 
								If Len(aRetSAT[6]) > 6
									aAdd( aSL1, { "L1_KEYNFCE" , SubStr(aRetSAT[7],4,Len(aRetSAT[7])) } )
								EndIf
								FR271BGeraSL("SL1", aSL1, .F.)
								aSL1 := {}
							EndIf
							
							LjGrvLog( SL1->L1_NUM, "SAT - Venda com sucesso " )

							LojSATImprimir(Decode64(aRetSAT[5]), cXML, SL1->L1_SERIE, @cDocSat, @cSerieSat) //impressao do SAT

							nRet := 1

							cDoc := cDocSat

							LjGrvLog( SL1->L1_NUM, "L1_DOC ", cDoc )

							Aadd( aSL1, {"L1_DOC", cDoc } )
							Aadd( aSL1, {"L1_ESPECIE", "SATCE" } )
							FR271BGeraSL("SL1", aSL1, .F.)

							DbSelectArea("SL2")
							If DbSeek(xFilial("SL2")+SL1->L1_NUM)
								While SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM .AND. !SL2->(EOF())
									aSL2 := {	{	"L2_DOC"	, cDoc     } }
									FR271BGeraSL("SL2", aSL2, .F.)
									SL2->(DbSkip())
								End
						    EndIf

							LjGrvLog( SL1->L1_NUM, "L2_DOC ", cDoc )

						Else

							nRet := -1
							
							//O tratamento para gravar a MH2 foi incluido dentro da função de envio do SAT
							//Desta forma este trecho deve ser retirado para nao chamar novamten a gravação do MH2
							//<Retirar depois de um tempo>
							If ExistFunc("LjGrvLogSAT") .And. !ExistFunc("SATValidCanc")
								//Log SAT
								LjGrvLogSAT(;
										/*serie da venda*/,;
										/*numero da venda*/,;
										/*chave da venda*/,;
										cXML,;
										/*xml retorno*/,;
										"VENDA",;
										"ERRO",;
										IIf( Len(aRetSAT) > 1 , aRetSAT[2], "Erro inesperado") + "-" + ;
										IIf( Len(aRetSAT) > 3 .And. Type(aRetSAT[4])=="C", DecodeUTF8(aRetSAT[4]), "Erro inesperado"))
							EndIf	
											
							LjGrvLog( SL1->L1_NUM, "SAT - Erro ",aRetSAT)
							//	aRet[2] - Codigo 
			        		//	aRet[4] - Descrição
							//Não foi colocado em STFMESSAGE porque a mensagem pode ser grande e não será exibida por completo
							MsgAlert(cSiglaSat + " - Venda não realizada: "  + ;
							IIf( Len(aRetSAT) > 1 , aRetSAT[2], "Erro inesperado") + "-" +; 
							IIf( Len(aRetSAT) > 3 .And. Type(aRetSAT[4])=="C", DecodeUTF8(aRetSAT[4]), "Erro inesperado"))// Código de erro retornado pelo SAT						
						EndIf

						If ExistFunc("LjSetTriSat")
							LjSetTriSat() //Limpa variavel de tributação dos produtos
						EndIf

					EndIf

					lReenviaNFce := .F.
					If nRet <> 1 .And. !lUseSAT
						lReenviaNFce := .T.
					EndIf

					If !lUseSAT
						aAdd( aSL1, {"L1_KEYNFCE", StrTran(cKeyNfce,"NFe")} )
					ElseIf Len(aRetSAT) > 0 .AND. Len(aRetSAT) > 1 .AND. Val(aRetSAT[2]) == 6000

						cDoc := cDocSat

						aAdd( aSL1, { "L1_DOC" , cDoc } )

						//Numero de série do SAT
						aAdd( aSL1, { "L1_SERSAT" , cSerieSat } )

						//Grava chave da venda SAT
						aAdd( aSL1, { "L1_KEYNFCE" , SubStr(aRetSAT[7],4,Len(aRetSAT[7])) } )
					EndIf
					FRTGeraSL("SL1", aSL1, .F.)

					//Tratamento para reenvio da nfc-e por motivo de rejeição ou não-comunicação com o Sefaz.
					If lReenviaNFce
						lTentarNovamente := F271GNfceReenvia(nRet, cMsgErro) 
						If !lTentarNovamente .AND. !LJProFile(8,,,,, .T. )
							lTentarNovamente := .T.
						EndIf
					Else
						lTentarNovamente := .F.
					EndIf

					//Limpa a variavel com a mensagem de falha na transmissao, seja comunicacao ou rejeicao
					cMsgErro := ""

					If !lTentarNovamente .And. ExistFunc("LjNFCeFree")
						LjNFCeFree() //Limpa objeto static que controla a impressão da NFC-e
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Situacoes nRet:																					³
					//³	 1  -> NFC-e processada com sucesso																³
					//³	 0 	-> NFC-e enviada para o TSS sem Rejeicao, mas não houve sucesso na comunicacao TSS->Sefaz	³
					//³	-1 	-> NFC-e rejeitada																			³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nRet == 1
						nRet := 0
					Else
						nRet := -1
					EndIf

				Else
					If Len(aReserva) > 0 .OR. lTemServic .OR. lIsVendaVP
						If lAbreCup
			   				nRet := IFFechaCup(nHdlECF, cMsgCupom , Nil , nVlrPagto )
						EndIf
					Else
						nRet := IFFechaCup(nHdlECF, cMsgCupom , Nil , nVlrTotal )
					EndIf
				EndIf

				lFechouCupom := (nRet == 0)
				If !lEmitNFCe
					lTentarNovamente := lAbreCup .AND. !lFechouCupom .AND. MsgYesNo("Tentar fechar o cupom fiscal novamente?")
				EndIf

			EndIf
		End
		LjLogFront("FRT271G - RETORNO DO FECHAMENTO NA IMPRESSORA",nRet)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³PTG,ANG,CHI,COL - Nao Utilizara ECF       	  		³
		//³Recebe o numero do cupom para grava no L1_DOC. 		³
		//³Faz a impressao do comprovante de venda		  		³
		//³												  		³
		//³Release 11.5 - Controle de Formularios - F2CHI 		³
		//³A funcao Lj7ImpCNF sera executada apenas p/obter o	³
		//³nro do comprovante de venda.A impressao acontecera 	³
		//³no final do processo de venda pela funcao Lj7ImpLoc	³
		//³apos validar o tipo de entrega dos itens da venda.   ³
		//³Paises: Chile/Colombia                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LjNfPtgNEcf(SM0->M0_CGC) .AND. !lCFolLocR5
			aNumPed := Lj7ImpCNF( .F. )
			If Len(aNumPed[2]) == 0
				nRet := -1
			Else
				RecLock("SL1",.F.)
				cDoc 			:= aNumPed[2][1]
				SL1->L1_DOC 	:= cDoc
				MsUnLock()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faz a Impressao do comprovante.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjMsgRun( STR0060,, { || lImp := LojR110( SL1->L1_DOC, SL1->L1_SERIE, /*aDadosTefNf*/ ) } )	 //"Aguarde... Imprimindo."

				If ValType(lImp) == "L"
					If !lImp
						nRet := -1
					EndIf
				EndIf
			EndIf
		EndIf


		If nRet == 0
			lEncerra := .T.
			lFechaCup := .T.
			If lUsaDisplay
				DisplayEnv(StatDisplay(), "1C"  + STR0020 )         //"Venda Finalizada."
				DisplayEnv(StatDisplay(), "2C"  + " " )
			EndIf
			If oPbm <> Nil
			
				LjGrvLog( SL1->L1_NUM, "LjFinVend - Enviando confirmação da venda Pbm ", SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_KEYNFCE)
				lRetPbm := LjFinVend(SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_KEYNFCE)
				If !lRetPbm
					lCancCup := .T.
					oPbm:ConfVend( .F. )
				EndIf
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exigencia de homologacao da TEF-Direcao: omitir esta mensagem de erro, pois sera exibida mensagem de cancelamento da transacao posteriormente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo())))
				HELP(' ',1,'FRT041')
			EndIf

	   		lFechaCup := .F.
			lCancCup  := .T.
		EndIf
	Else
		// "Não foi possível registrar as formas de pagamento. Operação não efetuada."
		HELP(' ',1,'FRT042')
		lFechaCup := .F.
		lCancCup  := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³					Deduz os valores pagos no cupom fiscal						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVlrTotal >= (nVlrTefCF + nVlrPagCF)
		nVlrTotal -= (nVlrTefCF + nVlrPagCF)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do ECF                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := (nRet == 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a confirmacao ou desfazimento da transacao TEF                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF+";"+TEF_CENTROPAG
		If lTefOk .OR. lRetPbm .OR. Len(aRegTEF) > 0 .OR. Len( aTefBKPCS ) > 0 			// Transação preparada para ser finalizada
			If cTipTef == TEF_CLISITEF													// Se é CLISITEF
				If lRet .And. !lCancCup       				                    		// Fechamento do cupom Fiscal efetuado com sucesso
					If oTef:lTefOk
						If lMFE .And. lLjRspFisc .And. Len(oTef:aRetCartao) > 0
							LjRspFisc(oTef:aRetCartao,.F.,aIdPgtoMfe)
							aIdPgtoMfe := {}
						EndIf	
					EndIf
					oTEF:ImpCupTef ( nVlrTotal, @lRelGer ,nVlrTotRe,nVlrTefCF,nVlrPagCF,lReserva,@nCupTEf,lVendMis)     			    // Imprime Cupom TEF
					lErrCupTEF 	:= !oTef:lImprimiu											// Se houve erro ao imprimir o Cupom TEF
					lTefOk 		:= oTEF:lTefOk												// Se a transação TEF está OK
					LjLogFront("FRT271G - IMPRESSAO DO TEF",lTefOk)
					If nVidaLink <> 99 .And. nVidaLink <> 0
						oTEF:aRetVidaLink := Nil
						aVidaLinkD := {}
						aVidaLinkc := {}
						nVidaLink  := 0
					EndIf
					If lTefOk
                    	If !(lErrCupTEF)
                    		nRet := IFPegCupom( nHdlECF, @cPegCOO)

                    		If nRet == 0
	                    		cUltimoCOO := cPegCOO

	                    		If LjNfPafEcf(SM0->M0_CGC)
	                   				// Retorna o Contador Geral de Operação Não Fiscal
	  								nRet := IFStatus(nHdlECF, "36", @cContOnf)

									// Retorna o Contador de Comprovante de Credito ou Debito
									nRet := IFStatus(nHdlECF, "38", @cContCdc)

									If lRelGer
									    // Retorna o Contador Geral de Relatório Gerencial
										nRet := IFStatus(nHdlECF, "37", @cContRg)
									EndIf
								EndIf

                    		EndIf
                    	EndIf
					EndIf

					//Apos a impressao do comprovante limpa o array de transacoes
					//de recarga de celular
					If oTef:nCodFuncao == 300 .OR. oTef:nCodFuncao == 301
						aRegTEF     := {}                                                        // Zera a Variavel usada na Vidalink
					EndIf
					
					//Apos a impressao do comprovante limpa o obj de transacoes Dotz
					If oTef:nCodFuncao == 837 .OR. oTef:nCodFuncao == 838 .AND. oTEF:aRetDotz <> NIL
						oTEF:aRetDotz := Nil
					EndIf	
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para Recarga de Celular finalizada em CARTAO TEF ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lErrCupTEF
						If Len(aRegTEF) > 0 .AND. oTef:nCodFuncao == 0
						    oTef:nCodFuncao := 301
							oTef:ImpCupTef(nVlrTotal) 										// Imprime Cupom TEF
							lErrCupTEF 	:= !oTef:lImprimiu									// Se houve erro ao imprimir o Cupom TEF
							lTefOk 		:= oTef:lTefOk										// Se a transação TEF está OK
							aRegTEF     := {}
						EndIf
					EndIf
					If lErrCupTEF															// Se houve erro na impressão do Comprovante TEF, tenta cancelar o Cupom Fiscal
						nRet := IFPegCupom( nHdlECF, @cNumCupFis)							// Pega o número do COO da impressora
						If nRet==0 .AND. ( Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis) )	// Se conseguiu pegar o número do COO e ele não foi incrementado
							lRetTef := FR271FCancCup(	.T.				, @oHora		, @cHora		, @oDoc			,;
														@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
														@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
														@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
														@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
														@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
														@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
														@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
														@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
														@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
														@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
														@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
														@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
														@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
														@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
														@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
														@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
														@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
														@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
														@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
														@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet		,;
														NIL				, NIL			, NIL			, NIL			,;
														NIL				, @aRegTEF		, @lRecarEfet	, Nil			,;
														Nil				, @cMensagem)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se o produto de vendas estiver amarrado a um ³
							//³produto de garantia                          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lGE .AND. ExistFunc(cImpRGer) .AND. Len(LjGetGarant()) > 0 .AND. !lCancCup
								aRelGer := LjGetGarant()
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Realiza a busca no aRelGer para saber a quantidade de       ³
								//³vias necessarias imprimir do Contrato de Garantia Estendida.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aSort(aRelGer, , , { | a, b | a[5] < b[5]}) //Ordena os Itens pelo item do Orçamento Original
								nForRel := Len(aRelGer) - 1
							    For nCont := 1 to nForRel Step 2
										cRet := chr(16) + &cImpRGer.(aRelGer[nCont][1],aRelGer[nCont][2],aRelGer[nCont][3],aRelGer[nCont][4],;
							        		                      aRelGer[nCont+1][1],aRelGer[nCont+1][2],aRelGer[nCont+1][3],SA1->A1_NOME,;
							        		                      nMoedaCor)
								Next nCont
								// Zera garantia
								If ExistFunc("LjZGarant")
									LjZGarant()
								Else
									Conout("Versão do programa Frta271a não atualizada - LjZGarant()")
								EndIf
							EndIf

							If !lRetTef														// Consegui cancelar o Cupom Fiscal
								Help(' ',1,'FRT046') 										// "Transação TEF cancelada devido à falha ao imprimir o comprovante TEF. O cupom fiscal será cancelado, pois o número seqüencial do Emissor do Cupom Fiscal não foi incrementado."
							EndIf
						Else
							lRetTef := .T. 													// Será necessário reter o Cupom, pois o COO não é o mesmo da Venda.
						EndIf
					Else
						lTemTEFPend := .F.
						aTefBKP     := {}
					EndIf
				Else 																		// Ocorreu um erro no registro do pagamento do ECF, ou na finalização da Venda
					oTEF:FinalTrn(0)														// Finaliza a TRN com parametro confirma = 1
					
					//Impressão do comprovante de cancelamento
					If ExistFunc("LjPrtTEFCan")
						LjPrtTEFCan(oTef,cPDV,cDoc)
					EndIf

					//Limpo o conteudo da propriedade aRETCARTAO que armazena o retorno do cartão
					If Type("oTef") <> "U"
						oTEF:aRETCARTAO := {}
					EndIf 

					IF lCancCup																// Deverá ser cancelado o Cupom Fiscal pois ocorreu um erro no comando do Fechamento do Cupom Fiscal
						nRet := IFPegCupom( nHdlECF, @cNumCupFis)							// Pego o número do cupom atual
						IF nRet==0 .AND. (lEmitNfce .or. ( Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis) )	) // Se conseguiu pegar o número do COO e ele não foi incrementado
							Help(' ',1,'FRT043')											// "A operacao de TEF não foi concluída com sucesso.
							lRetTef := FR271FCancCup(	.T.				, @oHora		, @cHora		, @oDoc			,;
														@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
														@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
														@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
														@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
														@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
														@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
														@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
														@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
														@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
														@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
														@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
														@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
														@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
														@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
														@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
														@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
														@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
														@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
														@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
														@aCProva		, @lCXAberto	, @oMensagem 	, @oFntGet 		,;
														NIL				, NIL			, NIL			, NIL			,;
														NIL				, @aRegTEF		, @lRecarEfet	, NIL			,;
														Nil				, @cMensagem	, NIL			, NIL			,;
														NIL				, NIL			, .T. /*lTEFCanceled*/)
						EndIf
					Else 																	// Ocorreu um erro ao registrar o pagamento no ECF. Não é preciso cancelar o Cupom, apenas deve-se retornar a Venda
						Help(' ',1,'FRT047')												// "Transação TEF cancelada devido a impossibilidade de registrar a forma de pagamento no ECF."
																							// "Por favor, realize novamente a operação TEF, ou escolha uma nova forma de pagamento."
					Endif
				EndIf
			ElseIf cTipTef == TEF_CENTROPAG .AND. cPaisLoc == "MEX" .AND. lRet
				oTEF:ImpCupTef( NIL , @lRelGer)
				lTefOk := oTef:lTefOk
			Else 																			// TEF diferente de CLISITEF
				If lRet 																	// Fechamento do cupom Fiscal efetuado com sucesso
					lTefOk := LOJA010T( "I"  			, "V"		, NIL         	, NIL	,;
					                    NIL  			, NIL		, lTemTEFPend	, NIL	,;
					                    Nil				, NIL		, NIL			, NIL	,;
					                    @cOrcamen       , @lRelGer	, cMsgCupom 	, nVlrTotal)
					If !lTefOk
						If !(lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo())))
							nRet := IFPegCupom( nHdlECF, @cNumCupFis)
						EndIf

						If (lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo()))) .OR. ; 	// Usa MultiTEF Discado
						   (nRet == 0 .AND. (Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis))	)  																								// Se conseguiu pegar o número do COO e ele não foi incrementado

							Help(' ',1,'FRT043')											// "A operacao de TEF não foi concluída com sucesso. O cupom será cancelado."
							lErrCupTEF	:= .T.												// Indica que houve erro na Transacao TEF
							lRetTef := FR271FCancCup(	.T.				, @oHora		, @cHora		, @oDoc			,;
														@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
														@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
														@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
														@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
														@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
														@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
														@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
														@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
														@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
														@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
														@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
														@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
														@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
														@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
														@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
														@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
														@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
														@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
														@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
														@aCProva		, @lCXAberto	, @oMensagem 	, @oFntGet 		,;
														NIL				, NIL			, NIL			, NIL			,;
														NIL				, @aRegTEF		, @lRecarEfet	, NIL			,;
														NIL				, @cMensagem)
							If lRetTef														// Não consegui cancelar o Cupom Fiscal
								Help(' ',1,'FRT034')										// "Erro com a Impressora Fiscal. Operação não efetuada.", "É necessário efetuar Nota de Devolução."
								lErrCupTEF := .T.											// Seta que há erro na impressão do Cupom TEF
							EndIf
						Else
							lRetTef := .T.													// Será necessário reter o Cupom, pois o COO não é o mesmo da Venda.
							lErrCupTEF := .T.												// Seta que há erro na impressão do Cupom TEF
						EndIf

					Else

						If LjNfPafEcf(SM0->M0_CGC)
	          				// Retorna o Contador Geral de Operação Não Fiscal
							nRet := IFStatus(nHdlECF, "36", @cContOnf)

							// Retorna o Contador de Comprovante de Credito ou Debito
							nRet := IFStatus(nHdlECF, "38", @cContCdc)

							If lRelGer
							    // Retorna o Contador Geral de Relatório Gerencial
								nRet := IFStatus(nHdlECF, "37", @cContRg)
							EndIf
						EndIf

					EndIf
				Else 																		// Ocorreu um erro ou registro do pagamento do ECF, ou na finalização da Venda
					lTefOk := LOJA010T( "F"    			, "N"		, NIL			, NIL	,;
									     NIL   			, NIL		, NIL			, NIL	,;
									     Nil			, NIL		, NIL  			, NIL	,;
									     @cOrcamen	)
					IF lCancCup 															// Deverá ser cancelado o Cupom Fiscal pois ocorreu um erro no comando do Fechamento do Cupom Fiscal
						If !(lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo())))
							nRet := IFPegCupom( nHdlECF, @cNumCupFis)						// Pego o número do cupom atual
						EndIf

						IF (lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo()))) .OR. ;	// Usa MultiTEF Discado
						   (nRet==0 .AND. ( Alltrim(SL1->L1_DOC) == Alltrim(cNumCupFis) ))																								// Se conseguiu pegar o número do COO e ele não foi incrementado

							Help(' ',1,'FRT043')											// "A operacao de TEF não foi concluída com sucesso. O cupom será cancelado."
							lRetTef := FR271FCancCup(	.T.				, @oHora		, @cHora		, @oDoc			,;
														@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
														@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
														@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
														@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
														@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
														@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
														@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
														@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
														@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
														@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
														@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
														@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
														@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
														@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
														@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
														@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
														@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
														@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
														@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
														@aCProva		, @lCXAberto	, @oMensagem 	, @oFntGet 		,;
														NIL				, NIL			, NIL			, NIL			,;
														NIL				, @aRegTEF		, @lRecarEfet	, NIL			,;
														NIL				, @cMensagem)
						Endif
					Else 																	// Ocorreu um erro ao registrar o pagamento no ECF. Não é preciso cancelar o Cupom, apenas deve-se retornar a Venda
						Help(' ',1,'FRT048')												// "Transação TEF cancelada devido à falha ao registrar a forma de pagamento no ECF."
																							// "Por favor, realize novamente a operação TEF, ou escolha uma nova forma de pagamento."
					Endif
				EndIf
			EndIf
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Se houver alguma transacao TEF pendente, deve cancelar no SiTef³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    ElseIf lVerTEFPend .AND. lTefMult .AND. cMV_TEFPEND $ "1|2"
	    	aTefMult  := AClone(aBckTEFMult)
	    	If LEN(aTefMult) > 0
		    	//HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef
				If TEF_lEnvDF()
			    	If LOJA010T(	"F"   			, "D"		, NIL			, NIL	,;
			        	          	NIL   			, NIL		, NIL			, NIL	,;
			        	          	Nil				, NIL		, NIL			, NIL	,;
			        	          	@cOrcamen	)
				    	MsgAlert(STR0015) 	//"Transação TEF cancelada!"
				 	EndIf
				 	//Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef
		      	ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00") .OR. lTefMult
					If LOJA010T( "F"   			, "N"		, NIL			, NIL   ,;	//Antigamente esta função nao retornava verdadeiro ou falso
				    		      NIL   		, NIL		, NIL			, NIL	,;
				    		      Nil			, NIL		, NIL			, NIL	,;
				    		      @cOrcamen	)
				    	MsgAlert(STR0015) 	//"Transação TEF cancelada!"
		         	EndIf
		      	EndIf
	      	EndIf
	      	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz cancelamento do cupom pois ocorreu um erro na finalização da Venda                    ³
			//³Como não houve uma impressão do Comprovante TEF, pode ser cancelado normalmente           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCancCup
				Help(' ',1,'FRT049')	// "O cupom fiscal será cancelado devido ao erro na finalização da venda."
				lRetTef := FR271FCancCup(	.T.				, @oHora		, @cHora		, @oDoc			,;
											@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
											@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
											@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
											@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
											@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
											@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
											@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
											@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
											@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
											@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
											@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
											@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
											@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
											@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
											@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
											@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
											@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
											@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
											@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
											@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,;
											NIL				, NIL			, NIL			, NIL			,;
											NIL				, @aRegTEF		, @lRecarEfet	, NIL			,;
											NIL				, @cMensagem)
			Endif
	    Else // Usuário esta habilitado para usar o TEF, mas a Venda envolve outra modalidade de pagamento
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³Ponte de Entrada de Templates para a rotina do PBM Vidalink.                           ³
		    //³Imprime comprov. venda Vidalink. Comando oTEF:ImpCupTef().Se nao existir pagto c/TEF   ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		If lDroVLImpt
				aRet := ExecTemplate("DroVLImp",.F.,.F.,{nVidaLink})
				nVidaLink := aRet[1]
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz cancelamento do cupom pois ocorreu um erro na finalização da Venda                    ³
			//³Como não houve uma impressão do Comprovante TEF, pode ser cancelado normalmente           ³									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCancCup
				Help(' ',1,'FRT049')	// "O cupom fiscal será cancelado devido ao erro na finalização da venda."
				lRetTef := FR271FCancCup(	.T.				, @oHora		, @cHora		, @oDoc			,;
											@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
											@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
											@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
											@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
											@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
											@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
											@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
											@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
											@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
											@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
											@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
											@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
											@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
											@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
											@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
											@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
											@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
											@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
											@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
											@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,;
											NIL				, NIL			, NIL			, NIL			,;
											NIL				, @aRegTEF		, @lRecarEfet	, NIL			,;
											NIL				, @cMensagem)
			Endif
	    EndIf
	Else // Usuário não é TEF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz cancelamento do cupom pois ocorreu um erro na finalização da Venda                    ³
		//³ para caixas que não utilizam TEF                     									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCancCup
			Help(' ',1,'FRT049')	// "O cupom fiscal será cancelado devido ao erro na finalização da venda."
			FR271FCancCup(	.T.				, @oHora		, @cHora		, @oDoc			,;
							@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
							@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
							@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
							@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,;
							@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
							@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
							@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
							@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
							@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
							@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
							@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
							@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
							@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
							@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
							@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
							@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
							@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
							@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
							@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
							@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,;
							NIL				, NIL			, NIL			, NIL			,;
							NIL				, @aRegTEF		, @lRecarEfet	, NIL			,;
							NIL 			, @cMensagem)
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o produto de vendas estiver amarrado a um ³
	//³produto de garantia                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGE .AND. ExistFunc(cImpRGer) .AND. Len(LjGetGarant()) > 0  .AND. !lCancCup
		aRelGer := LjGetGarant()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a busca no aRelGer para saber a quantidade de       ³
		//³vias necessarias imprimir do Contrato de Garantia Estendida.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSort(aRelGer, , , { | a, b | a[5] < b[5]}) //Ordena os Itens pelo item do Orçamento Original
		nForRel := Len(aRelGer) - 1
	    For nCont := 1 to nForRel Step 2
			cRet := chr(16) + &cImpRGer.(aRelGer[nCont][1],aRelGer[nCont][2],aRelGer[nCont][3],aRelGer[nCont][4],;
	        		                     aRelGer[nCont+1][1],aRelGer[nCont+1][2],aRelGer[nCont+1][3],SA1->A1_NOME,;
	        		                     nMoedaCor)
		Next nCont
		// Zera garantia
		If ExistFunc("LjZGarant")
			LjZGarant()
		Else
			Conout("Versão do programa Frta271a não atualizada - LjZGarant()")
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a confirmacao ou desfazimento da transacao de credito (SIGACRD)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CrdXInt()
	   If !Empty(cContrato)
          If lTransCrd
			 aTmpCliCrd := {}
			 aAdd( aTmpCliCrd, aCrdCliente[2] )     // Numero do cartao
			 aAdd( aTmpCliCrd, aCrdCliente[1] )		// CPF
			 aAdd( aTmpCliCrd, nVlrTotal )			// Valor da venda
			 aAdd( aTmpCliCrd, (nVlrAcreTot * 100 / (nVlrTotal-nVlrAcreTot)) )	// Juros da venda
			 aAdd( aTmpCliCrd, Len(aParcCrd) )		// Numero de parcelas
			 aAdd( aTmpCliCrd, 1 )					// Venda forcada
			 aAdd( aTmpCliCrd, "" )					// Responsavel pela venda forcada
			 aAdd( aTmpCliCrd, aClone(aParcCrd) )		// Dados das parcelas [n,1]=Data vencto [n,2]=Valor da parcela [n,3]=Forma de pagto
			 aAdd( aTmpCliCrd, SM0->M0_CODIGO+"-"+FWGETCODFILIAL+"-"+Alltrim(SM0->M0_NOME)  )		// Loja da venda
			 aAdd( aTmpCliCrd, SL1->L1_PDV )			// PDV
			 aAdd( aTmpCliCrd, xNumCaixa() )			// Caixa
			 aAdd( aTmpCliCrd, cOrcam )              // Num. do orcamento
			 aAdd( aTmpCliCrd, aClone(aProdCrd))     // Produtos selecionados numa venda
			 aAdd( aTmpCliCrd, aClone(aPgtos)  )     // Parcelas de uma venda
	         aAdd( aTmpCliCrd, FWGETCODFILIAL  )     // Filial do Caixa que esta sendo utilizado
	         aAdd( aTmpCliCrd, SL1->L1_CLIENTE )     // Cliente
	         aAdd( aTmpCliCrd, SL1->L1_LOJA    )     // Loja

			 If !( lRet ) .OR. ((lUsaTef .AND. lCartao .AND. !lTefOk) .AND. aScan(aPgtos,{|x| Alltrim(x[3])$"CD,CC" })>0 )
			    // Faz o desfazimento da transacao de credito
			    aRetCrd := CrdxVenda( "3"   ,aTmpCliCrd   ,cContrato   ,.T.   ,;
			                           NIL  ,NIL )
			 Else
			    // Confirma a transacao de credito
			    aRetCrd := CrdxVenda( "2" 	 ,aTmpCliCrd   	,cContrato  ,.T.   ,;
			                          Nil  	 ,Nil			,Nil		,aRecCrd)
			 EndIf
	      Else
             aDadosCrd := {}
		     aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
		     aAdd( aDadosCrd, aCrdCliente[1] )		// CPF
			 // Faz o desfazimento da transacao de credito
		     aRetCrd := CrdxVenda( "3"   ,aDadosCrd   ,cContrato   ,.T.   ,;
		                            NIL  ,NIL )
	      EndIf
	   ElseIf lForcada
	      CrdCpvFin()
	   EndIf
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³Se tiver algum contrato pendente gerado na venda atual, cancela   ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If Len(aContratos) > 0
	      aDadosCrd := {}
		  aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
		  aAdd( aDadosCrd, aCrdCliente[1] )		    // CPF
	      For nI := 1 to Len(aContratos)
	         If aContratos[nI] == cContrato        //Ignora se for o contrato da propria venda
	            Loop
	         EndIf
		     aRetCrd := CrdxVenda( "3"   ,aDadosCrd   ,aContratos[nI]   ,.T.   ,;
		                            NIL   ,NIL )
	      Next nI
	   EndIf
	EndIf

	// (Encerrou o cupom)
	If lEncerra
		// (Erro no Cupom TEF)
		If lErrCupTEF
			// (Nao conseguiu cancelar o cupom fiscal)
			If lRetTef .AND. lAbreCup .And. lTemItemCF
				LjLogFront("FRT271G - ERRO NO COMPROVANTE TEF")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso ocorra erro na transacao TEF, continua a gravacao do cupom, ³
				//³ pois o mesmo nao pode ser cancelado no ECF.                      ³
				//³ Neste caso sera necessario realizar uma NOTA DE DEVOLUCAO.       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSL1 := {{"L1_SITUA"	, "00"	}, ;						// "00" - Venda Efetuada Com Sucesso
						 {"L1_STATUS"	, "T"	}, ; 						// Indica que houve erro na Transacao TEF
			    	     {"L1_VENDTEF"	, "N"	}, ;
						 {"L1_FORMPG"	, Fr271tuFORMPG( cItemCond, lCondNegF5, aParcOrc, aFormCtrl,;
												         aPgtos) }, ;
			    	     {"L1_DATATEF"	, ""	}, ;
			    	     {"L1_HORATEF"	, ""	}, ;
				         {"L1_DOCTEF"	, ""	}, ;
				         {"L1_AUTORIZ"	, ""	}, ;
		    		     {"L1_INSTITU"	, ""	}, ;
			        	 {"L1_DOCCANC"	, ""	}, ;
				         {"L1_DATCANC"	, ""	}, ;
				         {"L1_HORCANC"	, ""	}, ;
		    		     {"L1_NSUTEF"	, ""	}, ;
	    	    		 {"L1_TIPCART"	, ""	} }
						 aReserva := {}

				FR271BGeraSL("SL1", aSL1, .F.)
				If lImpOrc
				   FR271HRPCImpOrc(SL1->L1_NUM)
				EndIf
			EndIf
		Else
			If Len(aReserva) == 0
			    lVendaOK  := .F.
			    If !lIsVendaVP
					If 	!Empty(SL1->L1_DOCPED) .Or. !Empty(SL1->L1_DOC)
						aSL1 := {{"L1_SITUA", "00"}}						// "00" - Venda Efetuada Com Sucesso
						lVendaOK  := .T.
					ElseIf lTemServic
						aSL1 := {{"L1_SITUA", "00"}}						// "00" - Venda Efetuada Com Sucesso
						lVendaOK  := .T.
					Else
						aSL1 := {{"L1_SITUA", "ER"}}						// "ER" - Erro no Orçamento
					EndIf
				EndIf
			EndIf
			If !lAbrecup .AND. !lCFolLocR5
				If lResume .OR. (lEmitNFCe .And. lTemItemCF)
					Aadd(aSL1,{"L1_DOC"		,cDoc					})
					Aadd(aSL1,{"L1_SERIE"	,LJGetStation("SERIE")	})
					Aadd(aSL1,{"L1_NUMCFIS"	,cDoc					})
				Else
					Aadd(aSL1,{"L1_DOC"		,""	})
					Aadd(aSL1,{"L1_SERIE"	,""	})
					Aadd(aSL1,{"L1_NUMCFIS"	,""	})
				EndIf
		        If lTemServic
					aAdd( aSL1, { "L1_SERRPS", cSerieRPS } ) // Numero de serie da nota fiscal de servico (RPS)
				EndIf
			EndIf

	  		If !lUseSat
				aAdd( aSL1, { "L1_KEYNFCE" , cKeyNFCe } )
			EndIf

			LjLogFront("FRT271G - GRAVOU COMO 00 ",cDoc)

			If LjNfPafEcf(SM0->M0_CGC)
		  		// Contador Geral de Operação Não Fiscal
				aAdd( aSL1, { "L1_CONTONF" , AllTrim(cContOnf) } )

				// Contador de Comprovante de Credito ou Debito
				aAdd( aSL1, { "L1_CONTCDC" , AllTrim(cContCdc) } )

			   	// Contador Geral de Relatório Gerencial
			   	aAdd( aSL1, { "L1_CONTRG" , AllTrim(cContRg) } )

			   	aAdd( aSL1,  {'L1_PAFMD5', LjxPafMD5("SL1")})
			EndIf

			FR271BGeraSL("SL1", aSL1, .F.)
			If Len(aReserva) == 0 .AND. lImpOrc .AND. lVendaOK .AND. ExistFunc("FR271HRPCImpOrc")
				FR271HRPCImpOrc(SL1->L1_NUM)
			EndIf
		EndIf

		// (Nao teve Erro no Cupom TEF) .OR. ((Erro no Cupom TEF) .AND. (nao conseguiu cancelar o cupom fiscal))
		If !lErrCupTEF .OR. (lErrCupTEF .AND. lRetTEF)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a Impressao do Cheque. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(LjGetStation("IMPCHQ")) .AND. !Empty(LjGetStation("PORTCHQ"))
				FR271HImpCH(@aParcelas)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Localizazoes - F2CHI   						³
			//³Impressao da Factura/Boleta/Comprovante de Venda (Nao Fiscal)³
			//³Paises:Chile/Colombia 										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCFolLocR5 .AND. !LjProfile(28)
				If lImpCNFLoc
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se houver itens de venda que obrigue a impressao de um³
					//³comprovante de venda, executar a funcao Lj7ImpCnf     ³
					//³para retornar o numero do pedido.                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRetCNF := Lj7ImpCNF( lTefOk, n271AFatRes, lAbrecup,cOrcam)
				EndIf
				Lj7ImpLoc (aBreakNota,aRetCNF,NIL,lImpCNFLoc)

				If aRetCNF[1] .AND. Len(aRetCNF[2]) > 0
					aSL1 := {{"L1_DOCPED", aRetCNF[2][1]		}, ;										// Numero do cupom nao fiscal (pedido)
							 {"L1_SERPED", If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE"))},;	// Numero do serie do cupom nao fiscal (pedido)
							 {"L1_SITUA" , IIF(!Empty(aRetCNF[2][1]),"00","ER")}}							// "00" - Venda Efetuada Com Sucesso
					FR271BGeraSL("SL1", aSL1, .F.)
				EndIf

				If lImpOrc
				   FR271HRPCImpOrc(SL1->L1_NUM)
				EndIf

			Else
				For nI := 1 To Len(aItens)
					If !aItens[nI][AIT_CANCELADO]
						SL2->(DbSetOrder(1))
						If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+FR271BPegaIT(aItens[nI][AIT_ITEM])))
							If !Empty(SL2->L2_RESERVA) .AND. SL2->L2_ENTREGA <> "2" // RETIRA POSTERIOR ou ENTREGA
								lImpNFiscal := .T.

							ElseIf lGE .AND. SuperGetMv("MV_LJIMPGF",,.F.) .AND. Len(aReserva) > 0 .AND. Len(aItProdGar) > 0 .AND.;
								aScan(aItProdGar,{|x| AllTrim(x[1])==AllTrim(SL2->L2_PRODUTO)}) > 0
								lImpNFiscal := .T.
							ElseIf lRetiraPos // RETIRA POSTERIOR ou ENTREGA
								lImpNFiscal := .T.
			 					Exit
							Endif
						ElseIf SL2->(DbSeek(xFilial("SL2") + cOrcam + FR271BPegaIT(aItens[nI][AIT_ITEM])))
							If lExTpRetira
								lRetiraPos := !Empty(SL2->L2_RESERVA) .AND. !LJXTpRetira(SL2->L2_ENTREGA)
							Else
								lRetiraPos := !Empty(SL2->L2_RESERVA) .AND. SL2->L2_ENTREGA <> "2"
							EndIf

						If lGE .AND. SuperGetMv("MV_LJIMPGF",,.F.) .AND. Len(aReserva) > 0 .AND. Len(aItProdGar) > 0 .AND.;
							aScan(aItProdGar,{|x| AllTrim(x[1])==AllTrim(SL2->L2_PRODUTO)}) > 0
							lImpNFiscal := .T.
						ElseIf lRetiraPos // RETIRA POSTERIOR ou ENTREGA
							lImpNFiscal := .T.
				   			Exit
						Endif
					Endif
				Endif
			Next nI

				If lTemServic
					//Seta variavel para imprimir cupom nao-fiscal quando existir itens de servico na venda (Referente a implementacao de Venda com Produto x Servico (RPS) MV_LJPRDSV)
					lImpNFiscal := .T.
					aReserva := aClone(aItServico) //Adiciona os itens de Servico no array de Reservas, pois o tratamento para impressao do cupom eh igual
				ElseIf lIsVendaVP
					//Seta variavel para imprimir cupom nao-fiscal quando for uma venda de Vale Presente
					lImpNFiscal := .T.
					aReserva := aClone(aItValePre) //Adiciona os itens de Vale Presente no array de Reservas, pois o tratamento para impressao do cupom eh igual
				EndIf

				If Len(aReserva) > 0 .AND. !(lErrCupTEF) .AND. !(lRetTef)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz a impressao do cupom nao fiscal (comprovante da venda) e se houver impressora configurada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lImpNFiscal
						If !aRetCNF[1] .AND. !Empty( cImpFisc )
				            If lGE
								nVlrGar := F271GGEc(@aItens, @nPosGe)
							Else
								nVlrGar := 0
							EndIf

							If 	nVlrGar > 0           //Rateio do Desconto no Comprovante não-fiscal
								n271AFatRes := (nVlrTotRe)/ ((SL1->L1_VLRTOT - nValorFSD + nVlrDescTot)-nVlrAcreTot)
							   	nTotSemRes	:=  (SL1->L1_VLRTOT - nValorFSD - nVlrAcreTot + nVlrDescTot) -(nVlrTotRe )
							Else					// Foram somadas as variaveis dos valores do cupom fiscal
								/*
								>> ATENCAO <<
								Calculo para identificar o FATOR da venda NÃO FISCAL (quando venda mista). 
								O valor de frete somente é atribuido ao valor da venda não fiscal (quando mista). Ou seja, 
								o frete NÃO entra no calculo da venda fiscal. 
								Este calculo é especifico para a impressao dos valores nao fiscais no ECF:
								Para a função A271FatRes deve ser passdo: (TOTAL DA VENDA LIQUIDA), (TOTAL DA VENDA NAO FISCAL LIQUIDA)
								*/
								aFatRes		:=	A271FatRes(aReserva, (nVlrTotal + nVlrTefCF + nVlrPagCF - nVlrAcreTot),(nVlrTotRe - nDescToP + nValorFSD))							
								n271AFatRes	:= aFatRes[2]
								nTotSemRes		:= aFatRes[3]
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Acrescenta o troco no valor do cupom não fiscal para correta Redução Z³
							//	Valor de troco não entra no cupom fiscal									³
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							nReserTroco := (nVlrTotal-(nVlrTotRe+nValorFSD))						// calcula o valor do cupom fiscal
							If nReserTroco > 0													// caso haja pagamento no cupom fiscal
	   							nReserTroco := ((nVlrPagCF + nVlrTefCF) - nReserTroco )   	// calcula o troco
	   							nVlrPagCF -= nReserTroco 										// deduz o troco do valor pago no cupom fiscal
							EndIF
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//							Totaliza o valor pago no Tef						³
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							nVlrTefCF += nCupTEf  //pagamento do cupom fiscal + pagamento do cupom TEF

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//							³Acrescenta o Frete									³
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							nTotSemRes += nValorFSD


							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Tenta ate 5 vezes fazer a impressao do cupom nao fiscal ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							While (!aRetCNF[1] .AND. lPergNov .AND. nContPerg <= 5) .Or. lTentaNova
								If lTemServic
									nComprovNF := 2 //2=RPS (Recibo Provisorio de Servico)
								ElseIf lIsVendaVP
									nComprovNF := 3 //3=Comprovante do Vale Presente
								Else
									nComprovNF := 1 //1=Comprovante do Pedido
								EndIf
								aRetCNF := Lj7ImpCNF(	lTefOk		, n271AFatRes,	lAbrecup	, cOrcam 	,;
													  	nTotSemRes	, nMoedaCor	 , 	nComprovNF	, aItProdGar,;
														aReserva, 		nVlrPagCF,		nVlrTefCF,		nVlrNccCF,;
														lVendMis,	nCupTEf ) //"Aguarde ... imprimindo o comprovante de venda ...."
 								If lEmitNfce  .And. nComprovNF = 2  //Somente para RPS
									aRetCNF := LjSerNfRPS()
								EndIf

 								nContPerg := nContPerg + 1

								If aRetCNF[1] .AND. !(Empty(aRetCNF[2][1])) .Or. lEmitNfce
									lPergNov := .F.
									lTentaNova := .F.
									If lEmitNfce .And. !aRetCNF[1] .And. ExistFunc("LjAskImp")
										lTentaNova := LjAskImp(-1)
									EndIf
								Else
									LjLogFront("FRT271G - ERRO NA IMPRESSAO DA RESERVA")
									If lTemServic
										MsgAlert(STR0068) //"Erro na Impressão do Documento Não Fiscal de Serviço. Verifique a conexão com a impressora e/ou falta de papel. Em seguida, confirme."
									ElseIf lIsVendaVP
										MsgAlert(STR0091) //"Erro na Impressão do Documento Não Fiscal de Vale Presente. Verifique a conexão com a impressora e/ou falta de papel. Em seguida, confirme."
									Else
										MsgAlert(STR0035)//"Erro na Impressão do Documento Não Fiscal do Pedido. Verifique a conexão com a impressora e/ou falta de papel. Em seguida, confirme."
									EndIf
								EndIf
							End
						Endif
						If lPergNov
							// Para entrar aqui ocorreram problemas na impressao do nao fiscal , nesse caso se tiver o COO do TEF na variavel ultimo COO
							// vai subir a venda,pois como ja imprimiu o cliente pode ja ter ido embora.
							If !Empty(cUltimoCOO) .OR. !Empty(SL1->L1_DOC)
								lPergNov := .F.
								If !Empty(cUltimoCOO)
									aRetCNF[2][1] := Alltrim(cUltimoCOO)
								ElseIf !Empty(SL1->L1_DOC)
									If lEmitNfce
										aAdd(aRetCNF[2], Alltrim(SL1->L1_DOC))
										aAdd(aRetCNF[2], cPdv)
									Else
										aRetCNF[2][1] := Alltrim(SL1->L1_DOC)
									EndIf
								EndIf
							ElseIf lImpOrc
								//libera o arquivo para permitir importacao
								FR271HRPCImpOrc(SL1->L1_NUM, .F.,.T.)
								oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0003+PadR(aRetCNF[2][2],4)+STR0004+StrZero(Val(aRetCNF[2][1])+1,TamSX3("L1_DOC")[1])) + chr(10) + chr(13))	// "  PDV:" "   COD:"
								oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
								oCupom:AppendText((chr(10) + chr(13)))
								oCupom:AppendText((PADC( STR0037 ,40))+ chr(10) + chr(13))	// "     C U P O M   N Ã O   F I S C A L    "
								oCupom:AppendText((chr(10) + chr(13)))
								oCupom:AppendText((STR0039) + chr(10) + chr(13))			// " Erro na emissão do Cupom Não fiscal"
								oCupom:AppendText((STR0040) + chr(10) + chr(13))         	// "									"
								oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
								oCupom:GoEnd()
								oCupom:Refresh()
								aSL1 := {{"L1_SITUA", "07"}}						// "07" - Venda Cancelada
								FR271BGeraSL("SL1", aSL1, .F.)
								LjLogFront("FRT271G - Problemas na impressao do comprovante nao fiscal")
							EndIf
						EndIf

						If !lPergNov
							If lTemServic
								aSL1 := {{"L1_SERRPS", cSerieRPS}}	// Numero de serie da nota fiscal de servico (RPS)
							Else
								If lIsVendaVP //Venda de Vale Presente
									aSL1 := {{"L1_DOC", aRetCNF[2][1]		}, ;										// Numero do cupom nao fiscal (pedido)
											 {"L1_SERIE", If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE"))},;	// Numero do serie do cupom nao fiscal (pedido)
											 {"L1_SITUA" , IIF(!Empty(aRetCNF[2][1]),"00","ER")}}							// "00" - Venda Efetuada Com Sucesso
								Else
									aSL1 := {{"L1_DOCPED", aRetCNF[2][1]		}, ;										// Numero do cupom nao fiscal (pedido)
											 {"L1_SERPED", If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE"))},;	// Numero do serie do cupom nao fiscal (pedido)
											 {"L1_SITUA" , IIF(!Empty(aRetCNF[2][1]),"00","ER")}}							// "00" - Venda Efetuada Com Sucesso
								EndIf
							EndIf
							FR271BGeraSL("SL1", aSL1, .F.)
							LjLogFront("FRT271G - GRAVOU O DOCPED",aRetCNF[2][1])

							If lImpOrc
							   FR271HRPCImpOrc(SL1->L1_NUM)
							EndIf
							If ExistBlock("FRTCLICHE")
								aFRTCliche := ExecBlock("FRTCLICHE", .F., .F.)
				                For nX := 1 To Len(aFRTCliche)
				          	    	oCupom:AppendText(aFRTCliche[nX])
				                Next nX
							Else
								oCupom:AppendText((chr(10) + chr(13)))
								oCupom:AppendText((STR0053) + chr(10) + chr(13))	// "        TOTVS  S / A          "
								oCupom:AppendText((STR0054) + chr(10) + chr(13))	// "    Av. Braz Leme, 1399 - São Paulo     "
								oCupom:AppendText((STR0055) + chr(10) + chr(13))	// "          www.microsiga.com.br          "
							EndIf
								oCupom:AppendText((DToC(dDatabase)+" "+Time()+" PDV:"+PadR(aRetCNF[2][2],4)+" COD:"+StrZero(Val(aRetCNF[2][1])+1,TamSX3("L1_DOC")[1])) + chr(10) + chr(13))	// "  PDV:" "   COD:"
								oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
								oCupom:AppendText((PADC(STR0051,40) + chr(10) + chr(13)))			// "     C U P O M   N Ã O   F I S C A L    "
								oCupom:AppendText((chr(10) + chr(13))	)
								oCupom:AppendText((STR0050) + chr(10) + chr(13))					// "ITEM   CÓDIGO           DESCRIÇãO       "
								oCupom:AppendText((STR0049 + "("+cSimbCor+")" + chr(10) + chr(13))) // "      QTDxUNITARIO    ST     VALOR( SIMBOLO ) "
								oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
								oCupom:GoEnd()

							nVlrTotal := SL1->L1_VLRTOT // Restaura o valor padrão da variavel de valor total para apresentar no cupom virtual

							For nIT := 1 To Len(aReserva)
								oCupom:AppendText(( StrZero(aReserva[nIT][1],3)+" "+Left(aReserva[nIT][2],13)+" "+Left(aReserva[nIT][4],21) )+ chr(10) + chr(13))
								If cPaisLoc == "BRA"
										oCupom:AppendText(( aReserva[nIT][5]+"x"+aReserva[nIT][6]+PadR(aReserva[nIT][7],6)+"%"+Transform(aReserva[nIT][8],PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor)) ) + chr(10) + chr(13))
									If !Empty(aReserva[nIT][9]) .And. Alltrim(aReserva[nIT][9]) != "0.00%"
										oCupom:AppendText((STR0052+aReserva[nIT][9]) + chr(10) + chr(13))  // "Desconto de :  "
									Endif
								Else
									oCupom:AppendText(( aReserva[nIT][5]+"x"+aReserva[nIT][6]+Space(06)+Transform(aReserva[nIT][8],PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor)) ) + chr(10) + chr(13))
								EndIf

								oCupom:GoEnd()
							    oCupom:Refresh()
							Next nIT

							If nVlrTotal > nVlrBruto + nValCredito
								oCupom:AppendText((STR0007 + Trans(If(cPaisLoc=="BRA",(nVlrBruto-nVlrTotal)*A271FatRes(aReserva, SL1->L1_VLRTOT-nVlrAcreTot,nVlrTotRe,,nValorFSD)[2],aDadosJur[1]),PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13))	// "     A C R E S C I M O   "
								lSubTot := .T.
							ElseIf nVlrTotal < nVlrBruto + nValCredito
								oCupom:AppendText((STR0008 + Trans(If(cPaisLoc=="BRA",Round((nVlrBruto+nValCredito-nVlrTotal)*A271FatRes(aReserva, (nVlrBruto+nValCredito-nValorFSD),nVlrTotRe,,0)[2], nDecimais),aDadosJur[9]),PesqPict("SL1","L1_DESCONT",14,nMoedaCor))) + chr(10) + chr(13))	// "     D E S C O N T O     " 
								lSubTot := .T.
							EndIf
							
							If nValorFSD > 0 .And. cPaisLoc == "BRA"
								oCupom:AppendText(("     F R E T E           " + Trans(nValorFSD,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor))) + chr(10) + chr(13))	// "     F R E T E           "
							EndIf

							oCupom:AppendText((FRT_SEPARATOR))
							If nVlrTotal > nVlrBruto + nValCredito
								oCupom:AppendText(PadR(STR0009 + Trans(nVlrTotal*A271FatRes(aReserva, SL1->L1_VLRTOT-nVlrAcreTot,nVlrTotRe,,nValorFSD)[2],PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)),39) + chr(10) + chr(13))	// "     T O T A L           "
								lSubTot := .T.
							Else
								oCupom:AppendText(PadR(STR0009 + Trans(nVlrTotal*Min(A271FatRes(aReserva, SL1->L1_VLRTOT,(nVlrTotRe-nDescToP+nValorFSD))[2],1),PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)),39) + chr(10) + chr(13)) 	// "     T O T A L           " 
								lSubTot := .T.
							EndIf

							//Verifica se existe um sinal de & (macro substituicao), dessa forma
							//possibilita ao usuario montar um parametro o qual seja executada uma condicional.
							//Foi necessario fazer dessa forma, pois caso contrario acarretaria
							//erro na base de clientes ja implantada.
							cMsgCupom := AllTrim(SuperGetMV("MV_LJFISMS"))
							If Empty(cMsgCupom)
								cMsgCupom := Rtrim(SLG->LG_MSGCUP)
							EndIf
							cMsgCupom := If( Substr(cMsgCupom,1,1)=="&", &(Substr(cMsgCupom,2,Len(cMsgCupom))), cMsgCupom )
							aMensagem:=Fr271IMsgTela(cMsgCupom)
								oCupom:AppendText((chr(10) + chr(13)))
								oCupom:AppendText((chr(10) + chr(13)))
							For nI := 1 to Len(aMensagem)
								    oCupom:AppendText((aMensagem[nI]) + chr(10) + chr(13))
							Next nI
								oCupom:AppendText((chr(10) + chr(13)))
								oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0003+PadR(aRetCNF[2][2],4)+STR0004+aRetCNF[2][1])	+ chr(10) + chr(13)) // "  PDV:" "   COD:"
								oCupom:AppendText((chr(10) + chr(13)))
								oCupom:AppendText(("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^") + chr(10) + chr(13))
						EndIf
						aReserva	:= {}		//Limpa a reserva para o proximo orçamento
	                Endif
	            ElseIf Len(aReserva) > 0
					oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0003+PadR(aRetCNF[2][2],4)+STR0004+StrZero(Val(aRetCNF[2][1])+1,TamSX3("L1_DOC")[1])) + chr(10) + chr(13))	// "  PDV:" "   COD:"
					oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
					oCupom:AppendText((chr(10) + chr(13)))
					oCupom:AppendText((PADC( STR0037 ,40))+ chr(10) + chr(13))	// "     C U P O M   N Ã O   F I S C A L    "
					oCupom:AppendText((chr(10) + chr(13)))
					oCupom:AppendText((STR0039) + chr(10) + chr(13))			// " Erro na emissão do Cupom Não fiscal"
					oCupom:AppendText((STR0040) + chr(10) + chr(13))         	// "									"
					oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
					oCupom:GoEnd()
					oCupom:Refresh()
					aSL1 := {{"L1_SITUA", "07"}}						// "07" - Venda Cancelada
					FR271BGeraSL("SL1", aSL1, .F.)
					LjLogFront("FRT271G - Problemas na impressao do TEF")
	     		EndIf

				//Atualizar dados do pedido na SL2
				If aRetCNF[1]
					SL2->(DbSetOrder(1))
					For nI := 1 To Len(aItens)
						If !aItens[nI][AIT_CANCELADO]
							If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM+FR271BPegaIT(aItens[nI][AIT_ITEM])))
								If !lTemServic
									If !Empty(SL2->L2_RESERVA) .AND. SL2->L2_ENTREGA <> "2" .AND.; // RETIRA POSTERIOR ou ENTREGA
										!lIsVendaVP
										aSL2 := {{"L2_PDV", aRetCNF[2][2]},;	// Numero do PDV
												 {"L2_DOCPED",	aRetCNF[2][1]},;	// Numero do cupom nao fiscal (pedido) L2_DOCPED
												 {"L2_SERPED",	If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE")) }} // Numero do serie do cupom nao fiscal (pedido) L2_SERPED
										FR271BGeraSL("SL2", aSL2, .F.)
										LjLogFront("FRT271G - GRAVOU NOVAMENT O DOCPED",aRetCNF[2][1])
									ElseIf lIsVendaVP .AND. lL2VALEPRE .AND. !Empty( SL2->L2_VALEPRE )
										aSL2 := {{"L2_PDV", aRetCNF[2][2]},;	// Numero do PDV
												 {"L2_DOC",	aRetCNF[2][1]},;	// Numero do cupom nao fiscal (pedido) L2_DOCPED
												 {"L2_SERIE",	If(Len(aRetCNF[2])==3,aRetCNF[2][3],LjGetStation("LG_SERIE")) }} // Numero do serie do cupom nao fiscal (pedido) L2_SERPED
										FR271BGeraSL("SL2", aSL2, .F.)									
									EndIf
								EndIf
	                        EndIf
						EndIf
					Next nI
	            EndIf
			Endif

			//Ajusta a sequancia dos itens na SL2			
		    DbSelectArea("SL2")
		    SL2->(DbSetOrder(1))
		    If SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))
				nItemAjuste := 0
		    	While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == SL1->L1_FILIAL + SL1->L1_NUM
   					nItemAjuste++
					cItemAjuste := FR271BPegaIT(nItemAjuste)	// Retorna a sequencia correta do item
		    		aSL2 := {{"L2_ITEM", cItemAjuste}}

		    		/*Trata lei dos impostos*/
					nTotDesp := nValorFSD  + SL1->L1_DESPESA + SL1->L1_SEGURO

					nL2Totimp := SL2->L2_TOTIMP
					// Tratamento Desconto Total
					If nVlrPercTot > 0
						nL2Totimp := nL2Totimp- Round((nVlrPercTot * nL2Totimp)/100,nDecimais)
					EndIf

					// Tratamento Acrescimo Financeiro
					If nTmpJuros > 0
						nL2Totimp := nL2Totimp+ Round((nTmpJuros * nL2Totimp)/100,nDecimais)
					EndIf

					// Tratamento Desconto Financeiro
					If nTmpDesc > 0
						nL2Totimp := nL2Totimp- Round((nTmpDesc * nL2Totimp)/100,nDecimais)
					EndIf

					// Tratamento Frete
					If nValorFSD  > 0
						nL2Totimp := nL2Totimp+ Round(( (nValorFSD /(SL1->L1_VLRTOT-nValorFSD ) ) * nL2Totimp),nDecimais)
					EndIf

				 	AAdd( aSL2 ,{"L2_TOTIMP",nL2Totimp})

					FRTGeraSL("SL2", aSL2, .F.)
					//Atualiza L2_DOC e L2_SERIE Dos vales-presentes vendidos
					If lL2VALEPRE .AND. !Empty( SL2->L2_VALEPRE )
						LjGrVVlPre( SL2->L2_VALEPRE	, SL1->L1_VEND	, SL2->L2_DOC	, SL1->L1_ESTACAO,;
						 			SL2->L2_PDV		, SL1->L1_EMISNF, SL1->L1_HORA	, SL1->L1_CLIENTE,;
						 			SL1->L1_LOJA 	, SL2->L2_SERIE )
					
					EndIf
					SL2->(DbSkip())
		   		End
		    Endif

			/*Template Function após o fechamento do cupom fiscal*/
		 	If lFRTEntregt
				ExecTemplate('FRTEntreg', .F., .F., { 	cNCartao , cCodDEP , cNomeDEP  , aPgtos			,;
														nDinheiro, nCheques, nCartao   , nFinanciado	,;
														nConvenio, nVales  , nValorDebi, nOutros	    ,;
														aTefDados })
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizando os valores da variaveis³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodDEP  := ""
			cNomeDEP := ""
			cMensagem := STR0001 //"   Protheus Front Loja"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada após o fechamento do cupom fiscal³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	If ExistBlock("FRTEntreg")
				ExecBlock("FRTEntreg", .F., .F., { aCrdCliente, cCodDEP , cNomeDEP  , aPgtos		,;
													nDinheiro, nCheques, nCartao   , nFinanciado	,;
													nConvenio, nVales  , nValorDebi, nOutros	    ,;
													aTefDados })
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alteracao especifica para atender a legislacao do SEFAZ ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LjAnalisaLeg(4)[1]
				If lGaveta
					If (!Empty(LJGetStation("PORTGAV"))) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
						GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
					Else
						IFGaveta(nHdlECF)
					EndIf
				EndIf
			EndIf
			LjLogFront(" ")
			LjLogFront("FRT271G - VENDA ENCERRADA , SITUA "+SL1->L1_SITUA)
			LjLogFront(" ")
			LjLogFront(FRT_SEPARATOR)
			LjLogFront(" ")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Informar a Retaguarda o Status Atual do Check-Out. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FR271BGerSLI(cEstacao, "CON", " |" + Alltrim(cPDV) + ;
						"|"    + AllTrim(cDoc) + "|" + 	AllTrim(Str(nVlrTotal,14,2))+;
						"|"    + AllTrim(Str(nTotItens)), "SOBREPOE" )

			aKey := FR271GLock( aKey, @lLocked, @oTimer )

			FR271GRefr( @cCliente		, @cLojaCli		, @aItens		, @aTEFPend		,;
						@aBckTEFMult	, @lOcioso		, @lVerTEFPend	, @lAltVend		,;
						@nVlrPercIT		, @nLastTotal	, @nLastItem	, @nTotItens	,;
						@nVlrTotal		, @nValIPI		, @nVlrBruto	, @nVlrMerc		,;
						@nTotDedIcms	, @lImpOrc		, @oDesconto	, @oTotItens	,;
						@oVlrTotal		, @uCliTPL		, @uProdTPL		, @cCodConv		,;
						@cLojConv		, @cNumCartConv	, @nMoedaCor	, @cSimbCor		,;
						@oTemp3			, @oTemp4		, @oTemp5		, @nTaxaMoeda 	,;
						@oTaxaMoeda		, @cMoeda		, @oMoedaCor	, @aTotVen		,;
						@oMensagem		, @aImpsSL1		, @aImpsSL2		, @aImpVarDup	,;
						@aImpsProd		, @aCols		, @aHeader		, @aCProva		,;
						@aDadosJur		, @nVlrFSD		, @nTotalAcrs	, @nVlrDescTot	,;
						@nVlrPercTot	, @nVlrPercAcr	, @nNumParcs	, @nVlrPercOri	,;
						@nQtdeItOri		, oFntGet		, @cCliCGC		, @nVlrDescIT	,;
						@cNumDav        , @cOrcam 		, @lResume		)

			FR271AInitIT(	.T.,		@lF7, 		@cCodProd, 	@cProduto,;
							@nTmpQuant,	@nQuant,	@cUnidade,	@nVlrUnit,;
							@nVlrItem,	@oProduto,	@oQuant,	@oUnidade,;
							@oVlrUnit,	@oVlrItem,	@oDesconto,	@cCliente,;
							@cLojaCli)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibir Mensagem de Finalizacao do Cupom no Display ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgDisplay(8)

		EndIf

		If Frt060Ret("NCC_USADA") > 0

			nValCredito	:= Abs(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA"))

			aSL1 := {{"L1_CREDITO"	, nValCredito }	}
			FRTGeraSL("SL1", aSL1, .F.)

			nValCredito	:= Frt060Ret("NCC_USADA")

			If Empty(SL1->L1_DOC)
				cParmDoc := SL1->L1_DOCPED
			Else
				cParmDoc := SL1->L1_DOC
			Endif

			If Empty(SL1->L1_SERIE)
				If lTemServic
					cParmSer := SL1->L1_SERRPS
				Else
					cParmSer := SL1->L1_SERPED
				EndIf
			Else
				cParmSer := SL1->L1_SERIE
			Endif

			//Excluindo a MDJ e MDK temporarias utilizadas na recuperação da venda
			FrtGCtrlNCC(nRecMdJ)

			Frt060BxNCC(	cParmDoc			, cParmSer		, SL1->L1_OPERADO	, SL1->L1_EMISNF	,;
							SL1->L1_CLIENTE	, SL1->L1_LOJA, nValCredito		, oVlrTotal		,;
							nVlrTotal	)

        EndIf

		/*Criação de  NCC com os valores dos Descontos concedidos³
		   pelo Cenario de vendas ativo/regras de Desconto.  ³
		   Somente com Release 11.5 ativo			  */
   	    If lCenVenda .AND. ExistFunc("LjGetCVar")
			aDescNCC := LjGetCVar()
			If Len(aDescNCC) > 0
				//³Execulta Funcao LJSELINCNCC que Gera NCC e verifica se³
				//³execulta via WebService.                              ³
        		LJSelIncTit( aDescNCC,"SL1")
            EndIf
        EndIf

	ElseIf lCancCup // Cupom Fiscal Cancelado, venda deletada

		aKey := FR271GLock( aKey, @lLocked, @oTimer ) // Libera variável lLocked

		FR271GRefr( @cCliente		, @cLojaCli		, @aItens		, @aTEFPend		,;
					@aBckTEFMult	, @lOcioso		, @lVerTEFPend	, @lAltVend		,;
					@nVlrPercIT		, @nLastTotal	, @nLastItem	, @nTotItens	,;
					@nVlrTotal		, @nValIPI		, @nVlrBruto	, @nVlrMerc		,;
					@nTotDedIcms	, @lImpOrc		, @oDesconto	, @oTotItens	,;
					@oVlrTotal		, @uCliTPL		, @uProdTPL		, @cCodConv		,;
					@cLojConv		, @cNumCartConv	, @nMoedaCor	, @cSimbCor		,;
					@oTemp3			, @oTemp4		, @oTemp5		, @nTaxaMoeda 	,;
					@oTaxaMoeda		, @cMoeda		, @oMoedaCor	, @aTotVen		,;
					@oMensagem		, @aImpsSL1		, @aImpsSL2		, @aImpVarDup	,;
					@aImpsProd		, @aCols		, @aHeader		, @aCProva		,;
					@aDadosJur		, @nVlrFSD		, @nTotalAcrs	, @nVlrDescTot	,;
					@nVlrPercTot	, @nVlrPercAcr	, @nNumParcs	, @nVlrPercOri	,;
					@nQtdeItOri		, oFntGet		, @cCliCGC		, @nVlrDescIT	,;
					@cNumDav        , @cOrcam 		, @lResume		)

		FR271AInitIT(	.T.,		@lF7, 		@cCodProd, 	@cProduto,;
						@nTmpQuant,	@nQuant,	@cUnidade,	@nVlrUnit,;
						@nVlrItem,	@oProduto,	@oQuant,	@oUnidade,;
						@oVlrUnit,	@oVlrItem,	@oDesconto,	@cCliente,;
						@cLojaCli)

	Else
		FR271HRollB04()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return(.F.)
	EndIf
Else
	If !Empty(cRecCart) .OR. !Empty(cRecCPF) .OR. !Empty(cRecCont)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Puxa o cadastro do cliente do servidor                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRegsSA1 := aClone( WSCrdConsCli( @cRecCart, @cRecCPF, @cRecCont ) )

		For nX := 1 to Len( aRegsSA1 )

			aCliente := aClone( aRegsSA1[nX] )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Se Registro do SA1 no front nao existir ou conteudo de algum campo for diferente da retaguarda atualiza registro |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CrdSa1Alte( aCliente )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Checa se a chave primaria jah existe no check-out          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosCli 	:= aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_COD" } )
				nPosLoja := aScan( aCliente, { |x| Alltrim(Upper(x[1])) == "A1_LOJA" } )
				If nPosCli <> 0 .AND. nPosLoja <> 0
					cCliente 	:= aCliente[nPosCli][2]
					cLojaCli	:= aCliente[nPosLoja][2]
					lCliente 	:= .F.						// Não chama a tela padrão para selecionar o cliente
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Faz a gravacao do cadastro do cliente no check-out         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lNovoCliente := .T.
					DbSelectArea("SA1")
					DbSetOrder(1)	// Filial + Cod + Loja
					If DbSeek(xFilial("SA1")+cCliente+cLojaCli)
						lNovoCliente := .F.
					Endif
					FR271BGeraSL( "SA1", aCliente, lNovoCliente )	// Grava o cadastro do cliente na estacao
					cCliente := SA1->A1_COD
					cLojaCli := SA1->A1_LOJA
				Endif
			Endif
		Next nX
	Endif

	// Atribuicao do valor ao array para a impressao do recebimento nao fiscal na rotina LJGRVREC
	// Esta variavel é declarada como private na rotina FR271IReceb
	aTitImp := aClone(aTitulo)

    lTEFPendRec  := lTemTEFPend
    If LEN(aTEFMult) > 0
       aRecTEFMult  := AClone(aTEFMult)
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define cliente com o padrao do parametro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
	cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
	nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
	cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)

	aItens	 := {}
	aTEFPend := {}
	lOcioso	 := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera o valor e o percentual de desconto do item       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAltVend   := .F.
	nVlrPercIT := 0
	nVlrDescIT := 0
	nLastTotal := nVlrTotal
	nLastItem  := nTotItens
	nTotItens  := 0
	nVlrTotal  := 0
	nValIPI    := 0
	nVlrBruto  := 0
	nVlrMerc   := 0
	oDesconto:Refresh()
	oTotItens:Refresh()
	If !lTouch
		oVlrTotal:Refresh()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reinicializa as variáveis de Templates                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	uCliTPL := Nil
	uProdTPL:= Nil
	cCodConv:= ""
	cLojConv:= ""
    cNumCartConv := ""
	FR271AInitIT(	.T.			, @lF7		, @cCodProd		, @cProduto	,;
					@nTmpQuant	, @nQuant	, @cUnidade		, @nVlrUnit	,;
					@nVlrItem	, @oProduto	, @oQuant		, @oUnidade	,;
					@oVlrUnit	, @oVlrItem	, @oDesconto	, @cCliente	,;
					@cLojaCli)

	//Apos o Recebimento, Limpa as variveis de cheque
	If  ExistFunc("LJLIMPACHQ")
		LJLIMPACHQ()
	EndIf

    //Quando tem operacao TEF, verifica se foi realizada com sucesso
	If lUsaTef .AND. lCartao
	   lConfLJRec := (lTefOk .OR. lTefManual)
	Else
	   lConfLJRec := .T.
	EndIf
	lRecebe    := .F.
	lEncerra   := .T.

EndIf

If lUsaDisplay
	DisplayEnv(StatDisplay(), "2E"+ STR0022)
	DisplayEnv(StatDisplay(), "1E"+ " ")
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressão de Cupom Não-Fiscal                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEncerra .AND. (nArredondar > 0)
	If ExistFunc("Lj950ImpIA")
		Lj950ImpIA(nArredondar, SL1->L1_SERIE, cDoc, cCliente,;
			 									cLojaCli,SL1->L1_CGCCLI,cForma)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa a variavel nValor              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValor 		:= 0
nVlrTotal	:= 0
nVlrDescCPg	:= 0
nValTPis 	:= 0
nValTCof	:= 0
nValTCsl 	:= 0

lAbreCup	:= .F.		//Atualiza a variavel para o proximo orçamento

If LjGetOPBM() <> Nil
	LjSetOPBM(Nil)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa variáveis de TEF pendente para novo oraçamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTefPendCS	:= .F.
aTefBKPCS	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa as variaveis staticas que controlam a analise de credito feita pelo sigacrd³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CrdxInt()
	Fr271ICrdSet(@cContrato	, @aCrdCliente	,  @aContratos	,@aRecCrd)
Endif
If lTouch
	FR271BBGrp( @oOrigBtns )
	FRT273CBtn( oOrigBtns	, "A"			, .T.			, Nil		,;
				Nil			, Nil			, @cCliente		, @cLojaCli	,;
				@cVendLoja	, @lOcioso		, @lRecebe		, @lLocked	,;
				@lCXAberto	, @lDescIT		, @nVlrDescTot	, @aMoeda	,;
				@aSimbs  ) // Retorno ao Menu Principal
Endif

//³Zera Objeto no fonte Frta0271A
If lAtivaMn
	FRT27AMuNe(0)
EndIf

//Chamo a função para limpar a variavel estatica do troco
If ExistFunc("Frt272Send")
	Frt272Send(" ")
EndIf

If ExistFunc("Lj64ZMul")
	Lj64ZMul()
EndIf
// Indica se o item atual teve desconto - Necessário para que nao seja informado o
// desconto quando nao houver item
lDescIT := .T.

//------------------------------------------------------------------
//Limpa as variaveis de controle referente a venda de Vale Presente
//------------------------------------------------------------------
If ExistFunc("Lj7VPNew") .And. Lj7VPNew()
	Lj7VPVdaVP(0)
	FrtSetItVP()
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ FR271GLock   ³ Autor ³ Vendas Clientes      ³ Data ³ 17/09/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a base de dados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com os detalhes das teclas de atalho              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Array com os detalhes das teclas de atalho               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FR271GLock( aKey, lLocked, oTimer )

If lLocked
	oTimer:Deactivate()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguardando a Thread Processar Atualizacao da Base de Dados. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Conout(STR0034) // "Aguarde. Atualizando a base de dados..."
	lLocked := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	oTimer:Activate()
EndIf

Return (aKey)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FR271GRefr   ³ Autor ³ Vendas Clientes      ³ Data ³ 17/09/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reinicializa as variáveis Staticas e Privates, preparando assim ³±±
±±³          ³ para a próxima Venda.                             			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codido da condicao de pagamento                          ³±±
±±³          ³ExpL2 - .T. / .F.                                                ³±±
±±³          ³ExpA3 - Array com as parcelas                                    ³±±
±±³          ³ExpA4 - Controle das Formas de Pagamento Solicitadas             ³±±
±±³          ³ExpA5 - Informacoes do pagamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Valor que servira para o campo L1_FORMPG                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data   ³Bops  ³Manutencao Efetuada                      	       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³        ³      ³                                                 º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FR271GRefr( cCliente	, cLojaCli		, aItens		, aTEFPend		,;
							aBckTEFMult	, lOcioso		, lVerTEFPend	, lAltVend		,;
							nVlrPercIT	, nLastTotal	, nLastItem		, nTotItens		,;
							nVlrTotal	, nValIPI		, nVlrBruto		, nVlrMerc		,;
							nTotDedIcms	, lImpOrc		, oDesconto		, oTotItens		,;
							oVlrTotal	, uCliTPL		, uProdTPL		, cCodConv		,;
							cLojConv	, cNumCartConv	, nMoedaCor		, cSimbCor		,;
							oTemp3		, oTemp4		, oTemp5		, nTaxaMoeda 	,;
							oTaxaMoeda	, cMoeda		, oMoedaCor		, aTotVen		,;
							oMensagem	, aImpsSL1		, aImpsSL2		, aImpVarDup	,;
							aImpsProd	, aCols			, aHeader		, aCProva		,;
							aDadosJur	, nVlrFSD		, nTotalAcrs	, nVlrDescTot	,;
							nVlrPercTot	, nVlrPercAcr 	, nNumParcs		, nVlrPercOri	,;
							nQtdeItOri	, oFntGet		, cCliCGC		, nVlrDescIT	,;
							cNumDav     , cOrcam 		, lResume		, aVidaLinkD    ,;
							aVidaLinkc  , nVidaLink)

Local nTamSXG	:= 0
Local nCount	:= 0
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. ) // Retorna se Interface eh Touch ou Padrao

DEFAULT cCliCGC		:= ""
DEFAULT nVlrDescIT 	:= 0
DEFAULT cNumDav		:= ""
DEFAULT cOrcam  	:= ""
DEFAULT aVidaLinkD 	:= {}
DEFAULT aVidaLinkc 	:= {}
DEFAULT nVidaLink  	:= 0

//³ Limpa a variavel do registro de midia
If AllTrim(Str(SuperGetMv("MV_LJRGMID",,0))) $ "1|2"
	M->L1_MIDIA  := Space(TamSX3("UH_MIDIA")[1])	// Codigo da Midia
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define cliente com o padrao do parametro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
cCliCGC	 := ""

aItens	 		:= {}
aTEFPend 		:= {}
aBckTEFMult 	:= {}
lOcioso			:= .T.
lVerTEFPend  	:= .F.
lResume		    := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera o valor e o percentual de desconto do item       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAltVend   := .F.
nVlrPercIT := 0
nVlrDescIT := 0
nLastTotal := nVlrTotal
nLastItem  := nTotItens
nTotItens  := 0
nVlrTotal  := 0
nValIPI    := 0
nVlrBruto  := 0
nVlrMerc   := 0
nTotDedIcms  := 0
lImpOrc    := .F.
If !lTouch
	oDesconto:Refresh()
	oTotItens:Refresh()
EndIf
oVlrTotal:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa as variáveis de Templates                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
uCliTPL := Nil
uProdTPL:= Nil

cCodConv:= ""
cLojConv:= ""
cNumCartConv := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializa como .T. para Regra de Desconto - opção Acumulativa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc( "LJSETRACUMUL" )
	LjSetRAcumul(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reinicializa a variavel LOGTEF na inicializacao da nova venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LJVerifSLG() .AND. !Empty(SLG->LG_LOGTEF)
	RecLock("SLG",.F.)
	REPLACE SLG->LG_LOGTEF WITH ""
	SLG->(MsUnLock())
Else
	If lUsaTEF .AND. cTipTEF == TEF_CLISITEF
		If File(GetClientDir() + "CLISITEF." + StrZero(oTEF:nIDTermina, 3) )
			FErase( GetClientDir() + "CLISITEF." + StrZero(oTEF:nIDTermina, 3) )
		EndIf
	EndIf
Endif

//Restaura as variaveis referentes a moeda para a moeda 1
If cPaisLoc <> "BRA"
	If nMoedaCor <> 1
		cSimbCor  := AllTrim(SuperGetMV("MV_SIMB1"))
		oTemp3:Refresh()
		oTemp4:Refresh()
		oTemp5:Refresh()

		nTaxaMoeda := 1
		oTaxaMoeda:Refresh()

		nMoedaCor := 1
		cMoeda    := AllTrim(SuperGetMV("MV_MOEDA1"))
		oMoedaCor:Refresh()
	EndIf

	//Realiza a gravacao da saida do troco, no arquivo SE5, na base local.
	//Isso foi realizado devido o fato de o usuario querer utilizar a consulta
	//de saldo de caixa no Front. So sera feita a gravacao do SE5 local
	//caso esteja sendo utilizado o troco localizado.
	If SuperGetMV("MV_LJTRLOC",,.F.)
		For nCount := 1 To MoedFin()
			AtuaTroco(&("SL1->L1_TROCO"+Alltrim(Str(nCount))),nCount)
		Next nCount
	EndIf

	//Restaura a exibicao da mensagem padrao...
	AEval(aTotVen, {|x,y| (aTotVen[y][3]:=0,aTotVen[y][4]:=.F.)})
	oMensagem:cCaption := STR0001   //"   Protheus Front Loja"
	oMensagem:cTitle   := STR0001   //"   Protheus Front Loja"
	oMensagem:oFont    := oFntGet
	oMensagem:Refresh()

	aImpsSL1    := {}
	aImpsSL2    := {}
	aImpVarDup  := {}
	aImpsProd   := {}
	aCols       := {}
	aHeader     := {}
	aCProva     := {}
	aDadosJur   := {0,0,0,0,0,0,0,0,0}
	nVlrFSD     := 0
	nTotalAcrs  := 0
	nVlrDescTot	:= 0
	nVlrPercTot	:= 0
	nVlrPercAcr	:= 0
	nNumParcs   := 0
	nVlrPercOri := 0
	nQtdeItOri  := 0
Else
	//Realiza a gravacao da saida do troco, no arquivo SE5, na base local.
	//Isso foi realizado devido o fato de o usuario querer utilizar a consulta
	//de saldo de caixa no Front. So sera feita a gravacao do SE5 local
	//caso esteja sendo utilizado o troco
	If SL1->L1_TROCO1 > 0
		AtuaTroco( SL1->L1_TROCO1 , 1 )
	EndIf
EndIf

// Variaveis de Orcamento
cNumDav	:= ""
cOrcam  := ""
If LjGetOPBM() <> Nil
	LjSetOPBM(Nil)
EndIf

// VAriaveis VidaLink
If lUsaTEF .AND. cTipTEF == TEF_CLISITEF
	oTEF:aRetVidaLink 	:= Nil
	aVidaLinkD 			:= {}
	aVidaLinkc 			:= {}
	nVidaLink  			:= 0
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Fr271tuFORMPG ³ Autor ³ Vendas Clientes      ³ Data ³ 15/10/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o valor do campo L1_FORMPG                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Codido da condicao de pagamento                          ³±±
±±³          ³ExpL2 - .T. / .F.                                                ³±±
±±³          ³ExpA3 - Array com as parcelas                                    ³±±
±±³          ³ExpA4 - Controle das Formas de Pagamento Solicitadas             ³±±
±±³          ³ExpA5 - Informacoes do pagamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet = Valor que servira para o campo L1_FORMPG                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data   ³Bops  ³Manutencao Efetuada                      	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fr271tuFORMPG( cItemCond, lCondNegF5, aParcOrc, aFormCtrl,;
					    aPgtos )
Local cRet := ""	//Retorno da funcao

If cItemCond == "CN" .AND. !lCondNegF5 .AND. Len(aParcOrc) == 0
	If Len(aFormCtrl) > 1
		cRet := aFormCtrl[2][1]
	Else
		If Len(aFormCtrl) > 0
			cRet := aFormCtrl[1][1]
		Endif
	Endif
Else
	If Len(aPgtos) > 0
		cRet := aPgtos[1][3]
	Endif
Endif

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A271FatRes    ³ Autor ³ Vendas Clientes      ³ Data ³ 30/06/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fator para calculo do valor total da venda                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array com informacoes de reserva						   ³±±
±±³          ³ExpN2 - Valor total                                              ³±±
±±³          ³ExpN3 - Total de itens com reserva                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet = Array com fator da venda e fator da reserva              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A271FatRes(aReserva, nVlrTotal,nVlrTotRe,lVlrGar,nFrete)
Local nLoop		:=	0 		//Controle de loop
Local nFatorRes	:=	0 		//Fator reserva
Local nFatorVen	:=	0		//Fator venda
Local aRet 		:= {}		//Retorno da funcao
Local nTotCF	:= 0		//Total de Itens com emissão de Cupom Fiscal

DEFAULT nVlrTotRe := 0
DEFAULT	lVlrGar 	:= .T. // Valor de Garantia
DEFAULT nFrete := 0

If nVlrTotRe == 0 .AND. Len(aReserva) > 0 .AND. lVlrGar
	For nLoop := 1 To Len(aReserva)
		nVlrTotRe += aReserva[nLoop][8]
	Next nLoop
EndIf
nVlrTotRe += nFrete
nVlrTotal += nFrete
nFatorRes 	:= (nVlrTotRe/nVlrTotal)
nFatorVen 	:= (1-nFatorRes)
nTotCF		:= nVlrTotal - nVlrTotRe

If nFatorVen == 0
	aRet := {1, nFatorRes,nTotCF}
Else
	aRet := {nFatorVen, nFatorRes,nTotCF}
Endif


Return (aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271GProfStr³ Autor³ Vendas Clientes       ³ Data³04/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravao o Diretorio do RootPath na variavel cGetCliDir, e o   ³±±
±±³          ³Retorno da Fucao GetPvProfString p/ nao executa-la novamente.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FR271GProfStr()
If cGetCliDir == NIL
	cGetCliDir:= GetClientDir()
EndIf
If cProfStr1 == NIL
   cProfStr1 := GetPvProfString("Recebimento Titulos", "Totalizadores", "01", cGetCliDir +"SIGALOJA.INI")
EndIf
Return(cProfStr1)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271GVlVPºAutor  ³ Vendas Cliente     º Data ³  30/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Captura os codigos de vales presentes utilizados como forma º±±
±±º          ³de pagamento no FrontLoja                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271GVlVP( nValor, aRet, nValVales )

Local lRet		:= .F.						// Variavel de retorno
Local oDlgVlPre								// Objeto Dialog
Local oGrp									// Objeto group
Local oLbValePre							// Objeto label "Vale Presente"
Local oOk									// Botao Ok
Local oCancelar								// Botao Cancelar
Local nSoma		:= 0						// Somatoria dos vales informados

Static oValePre								// Objeto get para o codigo do 'nte

aHeader	:= {}
aCols	:= {}

oDlgVlPre 			:= MSDIALOG():Create()
oDlgVlPre:cName 	:= "oDlgVlPre"
oDlgVlPre:cCaption 	:= "Vale Presente"
oDlgVlPre:nLeft 	:= 0
oDlgVlPre:nTop 		:= 0
oDlgVlPre:nWidth 	:= 320
oDlgVlPre:nHeight	:= 218
oDlgVlPre:lShowHint := .F.
oDlgVlPre:lCentered := .T.

oGrp 				:= TGROUP():Create(oDlgVlPre)
oGrp:cName 			:= "oGrp"
oGrp:nLeft 			:= 10
oGrp:nTop 			:= 10
oGrp:nWidth 		:= 300
oGrp:nHeight 		:= 146
oGrp:lShowHint 		:= .F.
oGrp:lReadOnly 		:= .F.
oGrp:Align 			:= 0
oGrp:lVisibleControl:= .T.

oLbValePre 					:= TSAY():Create(oDlgVlPre)
oLbValePre:cName 			:= "oLbValePre"
oLbValePre:cCaption 		:= STR0038
oLbValePre:nLeft			:= 18
oLbValePre:nTop 			:= 18
oLbValePre:nWidth 			:= 79
oLbValePre:nHeight 			:= 17
oLbValePre:lShowHint		:= .F.
oLbValePre:lReadOnly		:= .F.
oLbValePre:Align 			:= 0
oLbValePre:lVisibleControl 	:= .T.
oLbValePre:lWordWrap 		:= .F.
oLbValePre:lTransparent 	:= .F.

SX3->( dbSetOrder(2) )
SX3->( dbSeek( "MDD_CODIGO" ) )
SX3->( aAdd( aHeader,{		X3TITULO()		,;	//01 Titulo
							X3_CAMPO		,;	//02 Campo
							X3_PICTURE		,;	//03 Picture
							X3_TAMANHO		,;	//04 Tamanho
							X3_DECIMAL		,;	//05 Decimal
							"FR271GRVP()"	,;	//06 Valid
							Nil				,;	//07 Usado
							X3_TIPO			,;	//08 Tipo
							""				,;	//09 F3
							X3_CONTEXT		,;	//10 Contexto
							X3_CBOX			,;	//11 CBOX
							""				,;	//12 Relaxao
							".T."			,;	//
							" "				,;	//14 Visual
							" "				,;	//15 VldUser
							X3_PICTVAR		}))	//16 PictVar

SX3->( dbSeek( "MDD_VALOR" ) )
SX3->( aAdd( aHeader,{		X3TITULO()		,;	//01 Titulo
							X3_CAMPO		,;	//02 Campo
							X3_PICTURE		,;	//03 Picture
							X3_TAMANHO		,;	//04 Tamanho
							X3_DECIMAL		,;	//05 Decimal
							" "				,;	//06 Valid
							Nil				,;	//07 Usado
							X3_TIPO			,;	//08 Tipo
							""				,;	//09 F3
							X3_CONTEXT		,;	//10 Contexto
							X3_CBOX			,;	//11 CBOX
							"0"				,;	//12 Relaxao
							".T."			,;	//
							"V"				,;	//14 Visual
							" "				,;	//15 VldUser
							X3_PICTVAR		}))//16 PictVar

aCols := {}
aAdd( aCols, { Space(TamSX3("MDD_CODIGO")[1]), 0, .F. } )

oValePre := MsNewGetDados():New(	38/2, 18/2, 150/2, 300/2, ;
									GD_INSERT + GD_DELETE + GD_UPDATE,;
									"AllwaysTrue"	,;
									"AllwaysTrue"	,;
									Nil				,;
									Nil				,;
									NIL				,;
									99				,;
									NIL				,;
									NIL				,;
									NIL				,;
									oDlgVlPre		,;
									aHeader			,;
									aCols 			)

oOk 		  		:= SBUTTON():Create(oDlgVlPre)
oOk:cName 	  		:= "oOk"
oOk:cCaption 		:= "Ok"
oOk:nLeft 	   		:= 195
oOk:nTop 	   		:= 162
oOk:nWidth 	   		:= 52
oOk:nHeight    		:= 22
oOk:lShowHint  		:= .F.
oOk:lReadOnly  		:= .F.
oOk:Align 			:= 0
oOk:lVisibleControl := .T.
oOk:nType 			:= 1
oOk:bAction 		:= {|| If( FR271GVldOkVP( oValePre:aCols, nValor, @nValVales ), ( lRet := .T., aCols := aClone( oValePre:aCols ), oDlgVlPre:End() ), nil ) }

oCancelar 		   			:= SBUTTON():Create(oDlgVlPre)
oCancelar:cName    			:= "oCancelar"
oCancelar:cCaption 			:= "Cancelar"
oCancelar:nLeft    			:= 256
oCancelar:nTop 	   			:= 162
oCancelar:nWidth   			:= 52
oCancelar:nHeight  			:= 22
oCancelar:lShowHint 		:= .F.
oCancelar:lReadOnly 		:= .F.
oCancelar:Align 			:= 0
oCancelar:lVisibleControl 	:= .T.
oCancelar:nType 			:= 2
oCancelar:bAction 			:= {|| oDlgVlPre:End() }

oDlgVlPre:Activate()

If lRet
	aRet := {}
	aEval( aCols, {|x| If( !x[Len(x)], aAdd( aRet, { x[1], x[2] } ), nil ) } )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271GVldOºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o valor dos vales informados                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA271G                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR271GVldOkVP( aCols, nValor, nValVales )

Local lRet		:= .T.
Local nSomaVP 	:= 0	//SOMA DOS VALES PRESENTES
Local lLj7094	:= ExistBlock("LJ7094")
Local cPicture	:= "@E 999,999.99"

//faz a soma de todos os vales presentes digitados
aEval( aCols, {|x| nSomaVP += If( !x[Len(x)], x[2], 0 ) } )

If Empty(aCols[1][1])//Posicao do codigo do Vale Presente informado
	lRet := .F.
	Aviso(STR0002, STR0110, {"Ok"} )//"Não foi informado nenhum Vale Presente! Favor informar um código válido."
EndIf

If lRet

	If nSomaVP > nValor	//So aciona PE se o VALOR DO VALE PRESENTE for MAIOR que o VALOR DA VENDA
 
		If lLj7094	//LJ7094: Possibilita ou nao uma venda onde o vale presente é maior que o valor da venda
			lRet := ExecBlock( "LJ7094",.F.,.F.,{aCols,nValor,nSomaVP} )		
			If ValType(lRet) <> "L"
				lRet := .F.
			EndIf
		Else
			lRet := .F.
	
			Aviso(	STR0002, STR0041 + AllTrim(Transform(nSomaVP, cPicture)) + STR0042+;		//"O valor dos vales presentes informados (" //") é diferente "
					STR0043 + AllTrim(Transform(nValor, cPicture))+")." + Chr(13) +;			//"do valor informado na forma de pagamento ("
					STR0044, {"Ok"} )	//"Corrija as informações antes de prosseguir."
		EndIf

	Else
  		nValVales := nSomaVP 					 
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FR271GRVP ºAutor  ³ Vendas Clientes    º Data ³  29/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o codigo do vale presente digitado                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271GRVP()
Local oSvc					// WebService
Local lRet		 := .T.		// Variavel de retorno
Local cMsg		 := ""		// Mensagem de erro
Local nFor		 := 0		// Variavel de laco
Local nPosValor  := aScan(aHeader, {|x| AllTrim(x[02]) == "MDD_VALOR"})
Local nValorVale := 0

// Verifica duplicidade de codigos
For nFor := 1 to Len( aCols )
	If nFor <> n .AND. aCols[nFor][1] == &(ReadVar())
		cMsg := STR0045 //"Vale presente já informado."
		lRet := .F.
	EndIf
Next nFor

If lRet
	oSvc      					:= WSFRTValePre():New()
	oSvc:_URL 					:= "http://"+LJGetStation("WSSRV")+"/FRTValePre.apw"
	oSvc:oWSVALEPRE				:= FRTVALEPRE_WSVALEPRE():New()
	oSvc:oWSVALEPRE:cCODIGO		:= &(ReadVar())
	oSvc:oWSVALEPRE:cPRODUTO	:= ""
	oSvc:oWSVALEPRE:nVALOR		:= 0
	oSvc:oWSVALEPRE:nOPERACAO	:= 2

	lRet := oSvc:VldVale(nil,cEmpAnt,cFilAnt)

	If !lRet
		cMsg := STR0046+;    						//"A consulta do vale-presente não pode ser realizada. "
				STR0047+Chr(13)+Chr(13)+GetWSCError()//"Não será possível prosseguir com a venda deste item."
	Else
		cMsg := oSvc:cVLDVALERESULT
	EndIf

	If Empty( cMsg )
		oSvc      					:= WSFRTValePre():New()
		oSvc:_URL 					:= "http://"+LJGetStation("WSSRV")+"/FRTValePre.apw"
		oSvc:oWSVALEPRE				:= FRTVALEPRE_WSVALEPRE():New()
		oSvc:oWSVALEPRE:cCODIGO		:= &(ReadVar())
		oSvc:oWSVALEPRE:cPRODUTO	:= ""
		oSvc:oWSVALEPRE:nVALOR		:= 0
		oSvc:oWSVALEPRE:nOPERACAO	:= 2
		lRet := oSvc:ValorVale(nil,cEmpAnt,cFilAnt)

		If !lRet
			cMsg := STR0048+; 							  //"A consulta do vale-presente não pode ser realizada. "
					STR0049+Chr(13)+Chr(13)+GetWSCError() //"Não será possível prosseguir com a venda deste item."
		Else
			nValorVale := oSvc:nVALORVALERESULT

			aCols[n][nPosValor] := nValorVale
			If nModulo == 23
				oValePre:Refresh()
			EndIf
		Endif
	EndIf

EndIf

If !Empty( cMsg )
	Aviso( STR0002, cMsg, {"Ok"} )
EndIf

lRet := Empty( cMsg ) 

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FR271AdmFinºAutor  ³ Vendas Clientes    º Data ³  07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de tratamento do retorno do TEF quando parametro     º±±
±±º          ³ de inibir a tela de escolha das Adms. financeiras estiver   º±±
±±º          ³ configurado como TRUE                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271AdmFin(aPgtos		, aParcelas	, aTpAdms	, oTEF	,;
					 nMoedaCor	, aTefInf 	, lTefManual, lSelTefManu)
Local nRefAdms      := 0  //Controle da posicao da administradora no LOOP
Local nPosAdmSitef  := 0  //Controle da posicao da administradora no LOOP porem com o codigo da adm. do SITEF
Local nPosVetPagto  := 0  //Controle de backup do vetor original aPagtos
Local nRefSiTef     := 0  //Controle do De/Para do Sitef
Local aPgtosBkp     := {}  //Array de backup do aPagtos antes de recria-lo
Local aParcBkp      := {}  //Backup das parcelas de cada forma de pagamento
Local nParcCCCD     := 0   //Controle do Looping
Local aListFilt		:= {}
Local aListAdms     := {}  //Vetor do listbos das administradoras cadastradas
Local lTefManu		:= .F.
Local nLoopAdm      := 0  //Variavel de controle no AEval()
Local lSelAdm       := SuperGetMv("MV_LJADMFI",,.F.) //Parametro que indica se o recurso de inibir a tela de adm. esta concluido
Local cRet			:= ""
Local nLenTef		:= 0
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.) 	// Identifica se o cliente utiliza múltiplas transações TEF
Local cIdCartao		:= " "								// Identificacao do cartao
Local dDtVencAE		:= CtoD("")
Local loTef			:= ValType(oTEF) == "O"
Local nPosRetCart	:= 0
Local nPosData		:= 0									// Posicao da
Local dDataTrans	:= CtoD("")								// Data da transacao
Local nValorTrans	:= 0									// Valor total da transacao
Local nPosTrans		:= 0									// Posicao do numero da transacao
Local nPos			:= 0									// Posicao do contador
Local nScanList		:= 0									// Posicao de retorno do aScan
Local aIDCart		:= {}									// Array com o ID dos cartoes
Local nPosParc		:= 0									// Posicao do aCols
Local nProtecao		:= 2									// Variavel para proteger o loop infinito e contador das parcelas
Local nIntervalo	:= SuperGetMV("MV_LJINTER")  			// Define o intervalo(em dias) DEFAULT entre as parcelas
Local dDtVencCD		:= CtoD("")								// Primeira data de vencimento do cartao de debito
Local cCodRede 		:= ""
Local cFunction 	:= "AttIsMemberOf"
Local lRetorRede 	:= If(loTef,&cFunction.(oTef:aRetCartao[1],"cCodRede"),.F.) //Verifica se trata o Retorno da Rede que Autorizou a Transacao TEF (Verifica se o atributo cCodRede existe no objeto oTef:aRetCartao)
Local lPesqRede 	:= .F.									//Indica se considera a informacao da Rede que autorizou a transacao para fazer a pesquisa.
Local nTamCODSIT 	:= TamSX3("MDE_CODSIT")[1]

DEFAULT aPgtos		:= {}
DEFAULT aParcelas	:= {}
DEFAULT nMoedaCor	:= 1
DEFAULT aTefInf		:= {{.F.,"","","","","",""}}
DEFAULT lTefManual 	:= .F.
DEFAULT lSelTefManu	:= .F.

lMLoja := aTefInf[1][1]	// Chamado da Interface Venda Assistida

If !lMLoja
	//Retira do vetor de pagamentos, as informacoes do cartao, para prevalecer o que veio de retorno do CliSitef
	aPgtosBkp := {}
	For nRefAdms := 1 To Len(aPgtos)
		If !(aPgtos[nRefAdms,3] $ _FORMATEF)
			AAdd(aPgtosBkp,aPgtos[nRefAdms])
		ElseIf loTef
		    // Esse trecho vai verificar se quais cartoes que foram transacionados (que tem data/valor/NSU) se nao tiver quer dizer que continuou manualmente
			nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nRefAdms][12]  .AND. x:CFORMA == aPgtos[nRefAdms][3] }),1)
			If nPosRetCart > 0
				// Procura pela data conforme condicao de pagamento/parcelamento (se for parcelado, procura pela data do vencimento da parcela)
				nPosData   	:= aScan(oTef:aRetcartao[nPosRetCart]:aDatas, {|x| x == aPgtos[nRefAdms][1]})
				// Procura pelo valor da transacao (se for parcelado, procura pelo valor da parcela)
				nPosTrans	:= aScan(oTef:aRetcartao[nPosRetCart]:aValores, {|x| x == aPgtos[nRefAdms][2] } )
				If nPosData > 0 .And. nPosTrans > 0
					dDataTrans 	:= oTef:aRetcartao[nPosRetCart]:aDatas[nPosData]
					nValorTrans := oTef:aRetcartao[nPosRetCart]:aValores[nPosTrans]
					If  dDataTrans == aPgtos[nRefAdms][1] .AND. nValorTrans == aPgtos[nRefAdms][2]
						If EmpTy(oTef:aRetcartao[nPosRetCart]:CNSUSITEF)
							AAdd(aPgtosBkp,aPgtos[nRefAdms])
							lTefManu	:= .T.
						EndIf
					ElseIf Empty(dDataTrans) .AND. Empty(nValorTrans)
						If EmpTy(oTef:aRetcartao[nPosRetCart]:CNSUSITEF)
							AAdd(aPgtosBkp,aPgtos[nRefAdms])
							lTefManu	:= .T.
						EndIf
					EndIf
				Else
					If EmpTy(oTef:aRetcartao[nPosRetCart]:CNSUSITEF)
						AAdd(aPgtosBkp,aPgtos[nRefAdms])
						lTefManu	:= .T.
					EndIf
				EndIf
			Else
				AAdd(aPgtosBkp,aPgtos[nRefAdms])
				lTefManu	:= .T.
			EndIf
		EndIf
	Next nRefAdms

	aPgtos      := AClone(aPgtosBkp)
	aParcBkp    := {}
	For nRefAdms := 1 To Len(aParcelas)
		If !(aParcelas[nRefAdms,3] $ _FORMATEF)
			AAdd(aParcBkp,aParcelas[nRefAdms])
		Else
			// Se possuir no aPgtos nao remove do aParcelas
			nPosRetCart := Iif(lTefMult,aScan(aPgtos,{|x| x[12] == aParcelas[nRefAdms,12]}),1) // ID CART
			nPosData	:= aScan(aPgtos,{|x| x[1]  == aParcelas[nRefAdms,1]})	// Data
			nValorTrans := aScan(aPgtos,{|x| x[2]  == aParcelas[nRefAdms,2]})	// Valor
			nPosForm 	:= aScan(aPgtos,{|x| x[3]  == aParcelas[nRefAdms,3]})	// Forma
			If nValorTrans > 0 .AND. nPosData > 0 .AND. nPosRetCart > 0
				AAdd(aParcBkp,aParcelas[nRefAdms])
			EndIf
		EndIf
	Next nRefAdms
	aParcelas := AClone(aParcBkp)
EndIf

If Len(aTpAdms) > 0		//Monta Vetor com as Administradoras
	nLoopAdm := 0
	aListAdms := {}
	lPesqRede 	:= Len(aTpAdms[1]) > 8

    // Loop para separar por formas
	For nPos := 1 To Len(aTpAdms)
	    nScanList := AScan(aListFilt,{|x| x[1] == aTpAdms[nPos,1]})
		If nScanList > 0
			AAdd(aListFilt[nScanList][2], {	.F.												,; //01-Selecao
											aTpAdms[nPos,1]									,; //02-Tipo (CC,CD,...)
											aTpAdms[nPos,2]									,; //03-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
											aTpAdms[nPos,8]									,; //04-Recno SAE
											aTpAdms[nPos,3]									,; //05-Parcela Inicial
											aTpAdms[nPos,4]									,; //06-Parcela Final
											aTpAdms[nPos,7]									,; //07-Codigo da Bandeira (campo MDE_CODSIT)
											If(lPesqRede,aTpAdms[nPos,9],Space(nTamCODSIT)) }) //08-Codigo da Rede (Campo MDE_CODSIT)
		Else
			AAdd(aListFilt,{aTpAdms[nPos,1],{}})
			AAdd(aListFilt[len(aListFilt)][2], 	{	.F.												,; //01-Selecao
													aTpAdms[nPos,1]									,; //02-Tipo (CC,CD,...)
													aTpAdms[nPos,2]									,; //03-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
													aTpAdms[nPos,8]									,; //04-Recno SAE
													aTpAdms[nPos,3]									,; //05-Parcela Inicial
													aTpAdms[nPos,4]									,; //06-Parcela Final
													aTpAdms[nPos,7] 								,; //07-Codigo da Bandeira (campo MDE_CODSIT)
													If(lPesqRede,aTpAdms[nPos,9],Space(nTamCODSIT)) }) //08-Codigo da Rede (Campo MDE_CODSIT)
		Endif
	Next nPos
EndIf

If lMLoja
	nLenTef := 1	// No caso do SIGALOJA sempre faz 1 por cartao
	lRetorRede := Len(aTefInf[1]) > 6
Else
	// Loop para as vendas que foram NAO processadas no SITEF
	If lTefManu
		For nRefAdms := 1 To Len(aPgtos)
			If aPgtos[nRefAdms,3] $ _FORMATEF

				// oTef:aRetCartao > 1 quando venda com multiplos cartoes
				nPosRetCart := Iif(lTefMult, aScan(aIDCart, {|x| x == aPgtos[nRefAdms][12]+aPgtos[nRefAdms][3]}),0 )

				If nPosRetCart = 0
					nScanList := AScan(aListFilt,{|x| Alltrim(x[1]) == Alltrim(aPgtos[nRefAdms,3]) } )
					If nScanList > 0
						//Tela Adm
						nPosAdmSitef := FRgTelaSAE(aListFilt[nScanList][2], "", .T., Alltrim(aPgtos[nRefAdms,12]) ) //"Com o ID "

						If nPosAdmSitef > 0

							dDtVencAE := aPgtos[nRefAdms][1]	// Data de Vencimento DEFAULT
							If AllTrim(aListFilt[nScanList,2,nPosAdmSitef,2]) == "CD"
								DbSelectArea("SAE")				// Atualiza a data no caso de Debit
								DbGoTo(aListFilt[nScanList,2,nPosAdmSitef,4])
								dDtVencAE	:= LJCalcVenc(.T., dDatabase)
							EndIf


							//Atualiza o vetor aPagtos com os dados dos cartoes
							aPgtos[nRefAdms][1]	:= dDtVencAE									//Data Vencimento
							aPgtos[nRefAdms][4] := aListFilt[nScanList,2,nPosAdmSitef,3]		//Codigo e Descricao da Admistrador

							nPos := AScan(aParcelas,{|x| x[12] == aPgtos[nRefAdms][12] .AND.;	//ID
														 x[2]  == aPgtos[nRefAdms][2]	.AND.;     	// Valor
														 x[3]  == aPgtos[nRefAdms][3] })       	// Forma

							If nPos > 0 //Atualiza o vetor aPagtos com os dados dos cartoes
								aParcelas[nPos][1] := dDtVencAE									//Data Vencimento
								aParcelas[nPos][4] := aPgtos[nRefAdms][4]						//Codigo e Descricao da Admistrador
							EndIf

							If lTefMult
								nProtecao := 2	// Sempre inicializa na segunda parcela,pois a primeira ja foi alterado acima
								// Vai atualizar para o mesmo ID se tem mais de uma parcela
								While (nPos := aScan(aPgtos, {|x| x[12] == aPgtos[nRefAdms][12] .AND. x[3] == aPgtos[nRefAdms,3] .AND.;
																  x[4] <> aPgtos[nRefAdms][4] })) > 0 .AND. nProtecao < 100

									aPgtos[nPos][4] := aListFilt[nScanList,2,nPosAdmSitef,3]	//Codigo e Descricao da Admistrador
									nPosParc := AScan(aParcelas,{|x| x[12] == aPgtos[nPos][12] 	.AND.;
															 	 x[1]  == aPgtos[nPos][1]  		.AND.;
																 x[2]  == aPgtos[nPos][2]		})

									//Atualiza o vetor aParcelas com os dados dos cartoes
									If nPosParc > 0
										aParcelas[nPosParc][4] := aPgtos[nPos][4]				// Codigo e Descricao da Admistrador
										If AllTrim(aPgtos[nPos,3]) == "CD"                      // Para CD Atualiza as datas tb
											aPgtos[nPos][1]			:= dDtVencAE + nIntervalo*(nProtecao - 1)
											aParcelas[nPosParc][1] 	:= aPgtos[nPos][1]			// Codigo e Descricao da Admistrador
										EndIf
									EndIf
									nProtecao++ 												// Contra loop Infinito
								End
							EndIf
							AAdd(aIDCart,aPgtos[nRefAdms][12]+aPgtos[nRefAdms][3])
							aListFilt[nScanList,2,nPosAdmSitef,1] := .F. 						//limpa o array selecionado

							If ExistBlock("LJ7079") // Ponto de Entrada apos a escolha da administradora Manualmente
								ExecBlock("LJ7079", .F.,.F., {nRefAdms,aPgtos})
							EndIf
						EndIf
					EndIf
				EndIf
		     EndIf
		Next nRefAdms
	EndIf

	nLenTef := Len(oTEF:aRetCartao)
EndIf

// Loop para as vendas que foram processadas no SITEF
For nRefAdms := 1 To nLenTef
    If lMLoja
	    cTipoCart := Alltrim( aTefInf[1][2] )
	    cDescAdm  := Alltrim( aTefInf[1][3] )
	    cForma    := Alltrim( aTefInf[1][4] )
	    nParcTef  := aTefInf[1][5]
	    cCodRede  := If(lRetorRede, aTefInf[1][7], "")
	Else
		cTipoCart := AllTrim(Upper(oTEF:aRetCartao[nRefAdms]:cTipCart))
		cDescAdm  := AllTrim(Upper(oTEF:aRetCartao[nRefAdms]:cDescAdm))
		cForma    := AllTrim(Upper(oTEF:aRetCartao[nRefAdms]:cForma))
		nParcTef  := oTEF:aRetCartao[nRefAdms]:nParcelas
		cCodRede  := If(lRetorRede, oTef:aRetCartao[nRefAdms]:cCodRede, "")
	EndIf

	cCodRede  := PadR(cCodRede,nTamCODSIT)

	// Verifica se possui o retorno do TEF
	If lMLoja .OR. Len(oTEF:aRetCartao[nRefAdms]:aDatas) > 0

		nScanList := AScan(aListFilt,{|x| AllTrim(x[1]) == cForma })
		If nScanList > 0

			//-------------------------------------------------------------------------------------------------------------------
			//1a.Tentativa de Busca: Tenta buscar considerando o Codigo de Retorno da "Bandeira" e o Codigo de Retorno da "Rede"
			//-------------------------------------------------------------------------------------------------------------------
			nPosAdmSitef := AScan(aListFilt[nScanList][2],{|x| 	AllTrim(Upper(x[7])) == cTipoCart .AND. ;
																nParcTef >= x[5] .AND. nParcTef <= x[6] .AND. ;
																cForma == Upper(AllTrim(x[2])) .And. ;
																AllTrim(x[8]) == cCodRede })

			//-------------------------------------------------------------------------------------------------------------------------------------
			//2a.Tentativa de Busca: Tenta buscar considerando o Codigo de Retorno da "Bandeira" e O Codigo de "Rede" em branco na SAE (AE_REDEAUT)
			//-------------------------------------------------------------------------------------------------------------------------------------
			If nPosAdmSitef == 0
				nPosAdmSitef := AScan(aListFilt[nScanList][2],{|x| 	AllTrim(Upper(x[7])) == cTipoCart .AND. ;
																	nParcTef >= x[5] .AND. nParcTef <= x[6] .AND. ;
																	cForma == Upper(AllTrim(x[2])) .And. ;
																	x[8] == Space(nTamCODSIT) })
			EndIf

			If nPosAdmSitef == 0 .Or. (lTefManual .And. lSelTefManu)//lTefManual: Se o usuario concordou em continuar a operacao manual (quando MV_TEFMANU ativo)
				// Tela para selecionar a ADM
				nPosAdmSitef := FRgTelaSAE(aListFilt[nScanList][2], cDescAdm, lTefManual, aTefInf[1][6])
			EndIf

			If nPosAdmSitef > 0

				If lMLoja
					cRet := aListFilt[nScanList,2,nPosAdmSitef,3]
				Else
					For nParcCCCD := 1 To Len(oTEF:aRetCartao[nRefAdms]:aDatas)

						dDtVencAE := oTEF:aRetCartao[nRefAdms]:aDatas[nParcCCCD]

						If AllTrim(oTEF:aRetCartao[nRefAdms]:cForma) == "CD"
							If nParcCCCD == 1
								DbSelectArea("SAE")
								SAE->(DbGoTo(aListFilt[nScanList,2,nPosAdmSitef,4]))
								dDtVencCD := LJCalcVenc(.T., dDatabase)
								dDtVencAE := dDtVencCD
							Else
								dDtVencAE := dDtVencCD + nIntervalo*(nParcCCCD - 1)            // Calcula as demais parcelas
							EndIf
						EndIf
						//Recria o vetor aPagtos com os dados dos cartoes
						Aadd(aPgtos,{	dDtVencAE,; 											//Data Vencimento
										oTEF:aRetCartao[nRefAdms]:aValores[nParcCCCD],;		//Valor da Parcela
										aListFilt[nScanList,2,nPosAdmSitef,2],;				//Tipo: Cartao de Credito ou Debito
										aListFilt[nScanList,2,nPosAdmSitef,3],;				//Codigo e Descricao da Admistradora
										"","","","","",.F.,1,;
										oTEF:aRetCartao[nRefAdms]:cIdCart,;
										0 })
						//Recria o vetor aParcelas com os dados dos cartoes
						Aadd(aParcelas,{	dDtVencAE,; 										//Data de Pagamento/Credito
											oTEF:aRetCartao[nRefAdms]:aValores[nParcCCCD],;		//Valor do Pagamento
											aListFilt[nScanList,2,nPosAdmSitef,2],;				//Tipo: Cartao de Credito ou Debito
											aListFilt[nScanList,2,nPosAdmSitef,3],;				//Codigo e Descricao da Admistradora
											"",;												//Numero do Cartao
											"",;												//Agencia do Cheque (NAO UTILIZADO EM TEF)
											"",;												//Conta do Cheque 	(NAO UTILIZADO EM TEF)
											"",;												//RG do Cheque 		(NAO UTILIZADO EM TEF)
											"",;												//Telefone do Cheque(NAO UTILIZADO EM TEF)
											.F.,;												//Campo LOGICO
											nMoedaCor,;											//Moeda Corrente
											oTEF:aRetCartao[nRefAdms]:cIdCart,; 				//Digitos do Cartao
											"" })												//NAO UTILIZADO
					Next nParcCCCD
					aListFilt[nScanList,2,nPosAdmSitef,1] := .F. //limpa o array selecionado
				EndIf
			EndIf
        EndIf
    EndIf
Next nRefAdms

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRgTelaSAE   ºAutor  ³ Varejo    			º Data ³  21/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para a escolha da Adm Financeira que nao identif autom.  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRgTelaSAE(aListAdms,cDescAdm,lSelManual,cIdCard)

Local nPosAdmSitef	:= 0
Local aCoordAdms    := MsAdvSize(.T.)  //Vetor com as coordenadas da tela
Local oDlgAdms      := Nil  //Objeto com a tela de escolha das Administradoras
Local oListAdms     := Nil  //Listbox com as administradoras cadastradas
Local cMsgTela 		:= ""

DEFAULT	aListAdms	:= {}
DEFAULT	cDescAdm	:= ""

cMsgTela := STR0062 + cDescAdm //"Identifique qual administradora do sistema é a administradora identificada a seguir: "

If lSelManual //Modifica a mensagem da tela
	If !Empty(cIdCard)
		cMsgTela := STR0094 + STR0087 + cIdCard //"Selecione a administradora do cartão: " ### "Com o ID: "
	Else
		cMsgTela := STR0094 //"Selecione a administradora do cartão: "
	EndIf
EndIf

//Se nao foi identificada a Administradora, obriga que usuario selecione uma das administradoras validas
While nPosAdmSitef <= 0
	oDlgAdms := TDialog():New(000,000,aCoordAdms[6]/2,aCoordAdms[5]/2,OemToAnsi(STR0061),,,,,,,,oMainWnd,.T.) //"Seleção da Administrador de Cartão de Crédito/Débito"
		TSay():New(005,003,{|| cMsgTela },oDlgAdms,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,oDlgAdms:nClientWidth/2-7,008) //"Identifique qual administradora do sistema é a administradora identificada a seguir: "
		TGroup():New(015,003,oDlgAdms:nClientHeight/2-30,oDlgAdms:nClientWidth/2-7,STR0063,oDlgAdms,,,.T.,.F. ) //"Lista das Administradoras Cadastradas"
			oListAdms := TWBrowse():New(025,005,oDlgAdms:nClientWidth/2-15,oDlgAdms:nClientHeight/2-58,,{" ",STR0064,STR0065,},,oDlgAdms,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Tipo"#"Administradora"
				oListAdms:SetArray(aListAdms)
				oListAdms:bLDblClick := {||	FR271LblClick(@oListAdms,@aListAdms,@nPosAdmSitef) }

				oListAdms:bLine := {||{ IIf(aListAdms[oListAdms:nAt][1],LoadBitmap( GetResources(), "CHECKED" ),LoadBitmap( GetResources(), "UNCHECKED" )),;
										aListAdms[oListAdms:nAt][2],;
										aListAdms[oListAdms:nAt][3] }}
		TButton():New(oDlgAdms:nClientHeight/2-27,003,OemToAnsi("&Ok"),oDlgAdms,{|| oDlgAdms:End() },040,010,,,,.T.,,,,{|| })
	oDlgAdms:Activate(,,,.T.)
EndDo

Return nPosAdmSitef
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271LblClickºAutor  ³ Vendas Clientes    º Data ³  07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao com a expressao do CODEBLOCK do Duplo-Clique do listboxº±±
±±º          ³ da tela de selecao das administradoras financeiras            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR271LblClick(oListAdms,aListAdms,nPosAdmSitef)
Local nI := 0

aListAdms[oListAdms:nAt,1] := !aListAdms[oListAdms:nAt,1]

For nI := 1 To Len(aListAdms)
	If nI <> oListAdms:nAt
		aListAdms[nI,1] := .F.
	EndIf
Next nI

nPosAdmSitef := oListAdms:nAt
oListAdms:Refresh()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A271FatSrv    ³ Autor ³ Vendas Clientes      ³ Data ³ 17/04/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fator para calculo do valor total da venda                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Valor total dos itens de servico						   ³±±
±±³          ³ExpN2 - Valor total                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet = Fator de Itens de Produto e fator de itens de Servico.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A271FatSrv(nValorServ, nVlrTotal)
Local nFatorServ	:= 0 		//Fator de Itens de Servico
Local nFatorProd	:= 0		//Fator de itens de produto
Local aRet 			:= {}		//Retorno da funcao
Local nTotCF		:= 0		//Total de Itens com emissão de Cupom Fiscal

nFatorServ 	:= (nValorServ/nVlrTotal)
nFatorProd 	:= (1-nFatorServ)
nTotCF		:= nVlrTotal - nValorServ

If nFatorProd == 0
	aRet := {1, nFatorServ,nTotCF}
Else
	aRet := {nFatorProd, nFatorServ,nTotCF}
Endif

Return aRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F271GGEc	ºAutor  ³ Vendas Clientes    º Data ³  07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Caucula valores para nes CODEBLOCK do Duplo-Clique do listboxº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F271GGEc(aItens, nPosGe)

Local nI := 1													// Contador de Itens
Local nVlrGar := 0											// Valor da Garantia
Local cMvLjTGar	    := SuperGetMV("MV_LJTPGAR",,"GE") 	// Tipo de Garantia

Default aItens := {}
Default nPosGe := 0

DbSelectArea("SBI")
DbSetOrder(1)


For nI := 1 To Len(aItens)
	Aadd(aItens[nI], "")
	If DbSeek(xFilial("SBI")+ aItens[nI][AIT_COD]) .AND. SBI->BI_TIPO == cMvLjTGar
		aItens[nI][Len(aItens[nI])]:= "S"
		nVlrGar +=  aItens[nI][AIT_VLRITEM]
	EndIf
Next
If Len(aItens) > 0
	nPosGe := Len(aItens[Len(aItens)])
EndIf

Return(nVlrGar)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjLogFront   ºAutor  ³ VAREJO    			º Data ³  21/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Logs do Front Loja para dectar acoes no final da venda        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Preparada somente para PDV,pois nao separa por filal/pdv 	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjLogFront( cLogVar , xVar )

Local nHandle 	:= 0
Local cTexto  	:= ""
Local cArq		:= ""

Static cDirOrcLog := NIL

If cDirOrcLog = NIL	// Busca o caminho 1 vez soh
	cDirOrcLog := LjxLogOrc()
EndIf

If cDirOrcLog <> ""
	cArq := AllTrim(cDirOrcLog)+"LOG"+dtoS(dDataBase)+".TXT"

	If xVar <> NIL	// Caso venha uma variavel vai logar ela atraves do VarInfo
		cLogVar := cLogVar + VarInfo("",xVar,NIL,.F.,.F.)
	EndIf

	If !File( cArq )	// Se nao possuir cria a pasta
		MakeDir( "\AUTOCOM")
		MakeDir( "\AUTOCOM\ORCLOG")
		nHandle := FCreate( cArq )
		FClose( nHandle )
	Endif
	If File( cArq )	// Caso ja tenha apenas adiciona o texto
		nHandle := FOpen( cArq, 2 )
		FSeek ( nHandle, 0, 2 )			// Posiciona no final do arquivo.
		cTexto := Time() + " " + cLogVar
		FWrite( nHandle, cTexto + CRLF, Len(cTexto) + 2 )
		FClose( nHandle )
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxLogOrc    ºAutor  ³ VAREJO    			º Data ³  21/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apenas retorna o caminho que sera gerado o log do PDV         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjxLogOrc()

Local cLogTef  		:= ""      // Recebe o path do log
Local cProfStr1		:= ""
Local cGetCliDir	:= ""

cGetCliDir := GetClientDir()
cProfStr1   := GetPvProfString( "ORCLOG","Habilita","1",cGetCliDir + "SIGALOJA.INI" )

If cProfStr1 == "1"
	cLogTef    := "\AUTOCOM\ORCLOG\"
EndIf

Return(cLogTef)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F271GCopyVenda  ºAutor  ³Varejo        º Data ³  16/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsável por copiar o registro NFc-e que foi      º±±
±±º          ³rejeitado e criar um novo para reenvio.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA271G/LOJA701C                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F271GCopyVenda(cChaveOrig, aSL1Info, aSL2Info, aSL4Info)
Local cNum			:= GetSxENum("SL1","L1_NUM")
Local nNewRecno		:= 0

Default cChaveOrig	:= SL1->(L1_FILIAL+L1_NUM)
Default aSL1Info	:= {}
Default aSL2Info	:= {}
Default aSL4Info	:= {}

//Copiando SL1...
aAdd(aSL1Info, {"L1_NUM" , cNum   })
aAdd(aSL1Info, {"L1_HORA", Time() })

If (nNewRecno := F271GCopyReg("SL1", aSL1Info ,"L1_NUM/")) > 0

	If __lSX8
		ConfirmSX8()
	Endif

	//Copiando SL2...
	aAdd(aSL2Info, {"L2_NUM", cNum})

	SL2->(DBSetOrder(1)) //FILIAL + NUM
	If SL2->(DBSeek(cChaveOrig))

		While SL2->(!EOF()) .And. cChaveOrig == SL2->(L2_FILIAL+L2_NUM)
			nRecLoop := SL2->(RECNO())
			F271GCopyReg("SL2", aSL2Info, "L2_NUM/")
			SL2->(DBGoTo(nRecLoop))
			SL2->(DBSkip())
		End
	EndIf

	//Copiando SL4...
	aAdd(aSL4Info, {"L4_NUM", cNum})

	SL4->(DBSetOrder(1)) //FILIAL + NUM
	If SL4->(DBSeek(cChaveOrig))

		While SL4->(!EOF()) .And. cChaveOrig == SL4->(L4_FILIAL+L4_NUM)
			nRecLoop := SL4->(RECNO())
			F271GCopyReg("SL4",aSL4Info, "L4_NUM/" )
			SL4->(DBGoTo(nRecLoop))
			SL4->(DBSkip())
		End
	EndIf

EndIf

Return nNewRecno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F271GCopyReg  ºAutor  ³Varejo          º Data ³  16/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsável por copiar um unico registro da tabela   º±±
±±º          ³passada por parametro (DBF).                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.:     ³O registro a ser copiado deve estar posicionado.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA271G                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F271GCopyReg(cAlias, aNewInfos, cSkipFields)
Local aNovoReg		:= {}  		// [1] - Nome do campo / [2] - Informação do campo
Local cCampo		:= ""		// Nome do campo a ser copiado para o novo registro
Local lNewInfo		:= .F.		// Verificador de novos informações a serem add no novo registro
Local nI			:= 1   		// Contador do loop
Local nReg			:= 0   		// Numero de Recno do novo registro
Local xInfo						// Informação a ser adcionada no novo registro

Default cAlias		:= Alias()	// Alias ativa
Default aNewInfos	:= {}		// Novas informações [1]- Nome do Campo [2]- Nova informação
Default cSkipFields	:= ""		// Conjunto de campos que não serão copiados

//Tratamento para guardar informação e campo a ser copiado para o novo registro
For nI := 1 To (cAlias)->(FCount())

	cCampo	:= Upper(AllTrim((cAlias)->(Field(nI))))
	xInfo	:= (cAlias)->(FieldGet(nI))

	//Verifica se o campo deve ser ignorado
	If !(cCampo $ Upper(cSkipFields))
		aAdd(aNovoReg, {cCampo, xInfo})
	EndIf
Next nI

//Tratamento para criar o novo registro na tabela
If (cAlias)->(RecLock(cAlias, .T.))

	lNewInfo := Len(aNewInfos) > 0

	For nI := 1 To Len(aNovoReg)

		// Verifica a existencia de nova informação a ser preenchida e prioriza
		If lNewInfo .And. (nPos := aScan(aNewInfos, {|x| x[1] == Upper(AllTrim(aNovoReg[nI,1])) }) ) > 0
			xInfo := aNewInfos[nPos,2]
			aDel(aNewInfos,nPos)
			aSize(aNewInfos,Len(aNewInfos)-1)
		Else
			xInfo := aNovoReg[nI][2]
		EndIf

		(cAlias)->(FieldPut( (cAlias)->(ColumnPos(aNovoReg[nI,1])) ,xInfo))

	Next nI

	For nI := 1 To Len(aNewInfos)
		(cAlias)->(FieldPut( (cAlias)->(ColumnPos(aNewInfos[nI,1])) ,aNewInfos[nI,2]))
	Next nI

	(cAlias)->(MsUnlock())

	nReg := (cAlias)->(RecNo())

EndIf

Return nReg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F271GCancNfce  ºAutor  ³Varejo         º Data ³  16/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsável alterar o status para cancelar a nfc-e   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.:     ³O registro a ser cancelado deve estar posicionado.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA271G                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F271GCancNfce()
Local aSL1 := {}

FR271BCancela()

aAdd( aSL1, { "L1_STORC" , "A"  } )
aAdd( aSL1, { "L1_SITUA" , "00" } )

FRTGeraSL("SL1", aSL1, .F.)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F271GNfceReenvia  ºAutor  ³Varejo      º Data ³  16/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsável por reenviar a NFC-e em contigencia      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.:     ³O registro original deve estar posicionado.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA271G                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F271GNfceReenvia(nRetTss, cMsgErro)
Local lRet			:= .F.
Local aOldSl1		:= {}
Local aOldSl2		:= {}
Local aOldSl4		:= {}
Local aSL1			:= {}
Local cMsg			:= ""
Local nSl1RecnoDel	:= 0
Local lInutSLX 		:= ExistFunc("Lj7SLXDocE") .And. SLX->(ColumnPos("LX_MODDOC")) > 0 //Verifica se o controle de inutilizacao de NFC-e sera pela tabela (SLX) ou sera pelo antigo tratamento (SL1)
Local cCaixa 		:= ""
Local cSupervisor   := ""
Local lAutoriza     := .F.
Local lAutorSup     := SuperGetMV("MV_LJNGSUP",,.F.)  // Verifica a utilização de senha do Supervisor

Default cMsgErro		:= ""		//Mensagem de Erro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Situacoes nRet:																					³
//³	 1  -> NFC-e processada com sucesso																³
//³	 0 	-> NFC-e enviada para o TSS sem Rejeicao, mas não houve sucesso na comunicacao TSS->Sefaz	³
//³	-1 	-> NFC-e rejeitada																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRetTss == 0
	cMsg := STR0095	+ CHR(10)+CHR(13)+; //"Não foi possível o envio da NFC-e por motivo desconhecido ou o TSS não pode estabelecer comunicação com o SEFAZ."
			STR0096	+ Replic(CHR(10) + CHR(13),2)+; //"Deseja tentar envia-la novamente em modo de contingência?"
			STR0097 //"Importante: Para esta operação, favor verificar se o parâmetro 'MV_MODNFCE' está configurado corretamente no TSS conforme boletim técnico."
Else
	cMsg := STR0098	+ CHR(10)+CHR(13) +; //"A NFC-e foi rejeitada pelo SEFAZ."
			STR0099	+ CHR(10)+CHR(13) //"Deseja tentar envia-la novamente?"
EndIf

//Novo tratamento de cancelamento/inutilizacao (atraves do SLX)
If lInutSLX
	If lAutorSup
		While lAutoriza == .F.
			lAutoriza := LJProFile(8,@cSupervisor,,,, .T. )			
		End
	EndIf	
	//Envia o DOCUMENTO para Inutilizacao
	F271GInuti(cMsgErro,cSupervisor)
EndIf

If MsgYesNo( cMsg , STR0002) //"Atenção"

	If !lInutSLX
		//Antigo tratamento de cancelamento/inutilizacao (atraves do SL1)
		aOldSl1	:= SL1->(GetArea())
		aOldSl2	:= SL2->(GetArea())
		aOldSl4	:= SL4->(GetArea())

		aAdd(aSL1, {"L1_STORC", ""})
		FRTGeraSL("SL1", aSL1, .F.)

		//Replicar informação do banco
		nSl1RecnoDel := F271GCopyVenda(SL1->(L1_FILIAL+L1_NUM))
		SL1->(DBGoTo(nSl1RecnoDel))

		//Cancelar NFC-e (nota) atual que foi rejeitada
		F271GCancNfce()

		RestArea(aOldSl1)
		RestArea(aOldSl2)
		RestArea(aOldSl4)
	EndIf

	lRet := .T.
EndIf

Return lRet


//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F271FPgtDp
Funcao para apresentar no display as formas de pagamento
@author	Vendas Cliente
@param     aPgtosSint Array com as formas de pagamento selecionadas pelo usuario
@return    Nil
@version	P10
@since	08/01/2014
/*/
//------------------------------------------------------------------------------------------------------------------
Function F271FPgtDp(aPgtosSint)

Local nQtdSint	:= 0									// Quantidade de pagamentos no parametro aPgtosSint
Local lUsaDisplay	:= !Empty(LjGetStation("DISPLAY"))	// Verifica se a estacao possui Display
Local nCntFormPg	:= 0									// Contador para contar as formas de pagamento 3 a 3
Local cMsgLin		:= 0									// String para armazenar a linha de a ser descarregada no display
Local cMsgTela	:= ""									// A msg de todas as linhas que preencheram o visor e serao apresentadas no MsgInfo no monitor
Local nI			:= 0									// Contador para loops for

DEFAULT aPgtosSint := {}

If !lUsaDisplay
	Return Nil
Endif

nQtdSint := LEN(aPgtosSint)

// Limpar a tela do display
LjLimpDisp()

nCntFormPg := 1

// Validar se o array tem todas as posicoes necessarias e evitar erro de Array Out Of Bounds
If nQtdSint == 0 .OR. LEN(aPgtosSint[1]) < 5
	Return Nil
Endif

// Apresentar cada uma das formas de pagamento selecionadas pelo operador
For nI := 1 to nQtdSint

	// Cabecalho da mensagem no display
	If nCntFormPg == 1
		cMsgLin := PADR(STR0100, 9) + PADR(STR0101, 6) + PADR(STR0102, 9) + PADR(STR0103, 8)	// ### "Data" ### "Forma" ### "Valor" ### "Parcelas"
		DisplayEnv(StatDisplay(),  ALLTRIM(cValToChar(nCntFormPg)) + "E " + StrTran(cMsgLin, ",", "."))

		cMsgTela := cMsgTela + cMsgLin + CHR(13) + CHR(10)

		cMsgLin := ""
		nCntFormPg++

	Endif

	// Impressao da linha com a forma de pagamento
	cMsgLin :=	PADR(ALLTRIM(STR(Day(aPgtosSint[nI][5]))) + "/" + ALLTRIM(STR(Month(aPgtosSint[nI][5]))) + "/" + RIGHT(ALLTRIM(STR(Year(aPgtosSint[nI][5]))),2), 9) +;
				PADR(ALLTRIM(cValToChar(aPgtosSint[nI][1])), 6) ;
				+ PADR(ALLTRIM(cValToChar(aPgtosSint[nI][3])), 9) + PADL(ALLTRIM(cValToChar(aPgtosSint[nI][2])), 8)

	DisplayEnv(StatDisplay(),  ALLTRIM(cValToChar(nCntFormPg)) + "E " + StrTran(cMsgLin, ",", "."))

	cMsgTela := cMsgTela + cMsgLin + CHR(13) + CHR(10)

	nCntFormPg++

	// Paginacao no display
	If nCntFormPg == 4 .OR. nI == nQtdSint
		nCntFormPg := 1

		cMsgLin := STR0104		// ### "<ENTER> - Para continuar. "
		cMsgTela += cMsgLin + CRLF

		DisplayEnv(StatDisplay(),  "4E " + cMsgLin)
		MsgInfo(cMsgTela, STR0105)		// ### "Parcelas Pagto"

		cMsgTela := ""

		// Limpar a tela do display
		LjLimpDisp()

	Endif

Next nI

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F271GFECP         |Autor³Eduardo.Sales º Data ³  09/03/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função responsável por calcular o valor do fecp na matxfis  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.:     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA271G                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F271GFECP(cCliente, cLojaCli, cTipoCli, nVlrDesctot, nVlrAcreTot, lUseSAT)

Local nValFecp	:= 0
Local nX 		:= 0
Local aSATTrib	:= IIF(ExistFunc("LjGetTriSat"),LjGetTriSat(),{})		//Tributação produto SAT
Local nPosBPS2  := 0													//Base de calculo do PIS
Local nPosBCF2  := 0													//Base de calculo da Cofins
Local nItens	:= 0													//Quantidade de itens na venda
Local nQtdElm	:= 0													//Quantidade de elementos pertencente ao array aSATTrib

Default cCliente		:= AllTrim(SuperGetMv("MV_CLIPAD"))				// Cliente padrao
Default cLojaCli		:= AllTrim(SuperGetMv("MV_LOJAPAD"))			// Loja padrao
Default cTipoCli		:= ""
Default nVlrDesctot		:= 0
Default nVlrAcreTot		:= 0
Default lUseSAT			:= .F.


If LJAnalisaLeg(74)[1] .OR. (nVlrDesctot > 0 .AND. lUseSAT)

	MaFisIni(	cCliente	, cLojaCli		, "C"		, "S"	,;
				cTipoCli	, NIL			, NIL		, .F.	,;
				"SBI"		, NIL			, "01"		, NIL	,;
				NIL			, NIL			, NIL		, NIL	,;
				NIL			, NIL			, .F.		)

	dbSelectArea("SL2")

	SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))

	While SL2->(!EOF()) .And. SL1->(L1_FILIAL+L1_NUM) == SL2->(L2_FILIAL+L2_NUM)

		MaFisAdd(	SL2->L2_PRODUTO	, SL2->L2_TES	, SL2->L2_QUANT	, SL2->L2_PRCTAB	,;
			 		SL2->L2_VALDESC	, ""	 		, ""    			,	       		,;
			 		0           	, 0	 			, 0     			, 0				,;
			 		SL2->L2_VLRITEM	, 0	 			)

		SL2->(DbSkip())
		nItens++
	End

	MaFisAlt("NF_DESCONTO", MaFisRet(Nil, "NF_DESCONTO") +  nVlrDesctot - nVlrAcreTot)

	nValFecp := MaFisRet(Nil, "NF_VALFECP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acerto da base PIS/COFINS quando concedido desconto no total da venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	nX		:= 1
	nQtdElm	:= len(aSATTrib) / nItens
	While MaFisFound("IT", nX)
		nPosBPS2 := aScan(aSATTrib, {|x| Alltrim(Upper(x[2])) == "IT_BASEPS2" } ,((nQtdElm*(nX-1))+1))
		nPosBCF2 := aScan(aSATTrib, {|x| Alltrim(Upper(x[2])) == "IT_BASECF2" } ,((nQtdElm*(nX-1))+3))

		If nPosBPS2 > 0
			aSATTrib[nPosBPS2][3] := MaFisRet(nX,'IT_BASEPS2')
		EndIf
		
		If nPosBCF2 > 0
			aSATTrib[nPosBCF2][3] := MaFisRet(nX,'IT_BASECF2')
		EndIf
		
		nX++
	End

	If ExistFunc("LjSetTriSat")
		LjSetTriSat(aSATTrib)
	EndIf

	MaFisEnd()

EndIf

Return nValFecp

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F271GReord
Funcao para apresentar no display as formas de pagamento
@author	yuri.porto
@type 		Function
@param     cFormaPagto , caracter ,string  das formas de pagamento que serão enviadas a ECF
@return    cFormaPagto , caracter , string das formas de pagamento que serão enviadas a ECF (ordenadas do valor menor para o maior)
@param     aFormPag + aTotForm	- Arrays das formas de pagamento
@return    cFormaPagto 			- Forma de pagamento que gerou troco
@since	10/03/2016
/*/
//------------------------------------------------------------------------------------------------------------------
Function F271GReord(cFormaPagto,aFormPag,aTotForm,cMV_LJPGTRO)
Local aSubPgto		:= {}
Local aSubPag		:= {}
Local nX			:= 0
Local nCont			:= 0
Local lDinh         := .F. 
Local aFormTroco    := {}
Local cFormTroco    := ""
Local lfontTroc     := ExistFunc("Frt272Get")

Default cFormaPagto	:= ""
Default aFormPag	:= {}
Default aTotForm	:= {}
Default cMV_LJPGTRO := ""

//Ordena a string dos pagamentos enviados a impressora, do menor para o maior valor, evitando erros na impressão
If !Empty(cFormaPagto)
	aSubPgto 	:= StrToKarr(cFormaPagto ,"|")          		// Array com as formas q vao para o ecf
	For nX := 1 To Len(aSubPgto)
		Aadd(aSubPag,{aSubPgto[nX] ,Val(aSubPgto[nX+1])} )
		nX +=1
	Next nX
	aSubPgto := AClone(aSubPag)
	aSubPgto := ASORT(aSubPag, , , { | x,y | x[2] < y[2] } )
	cFormaPagto := ""
	For nX := 1 To Len(aSubPgto)
		cFormaPagto += aSubPag[nX][1] + "|"+ Alltrim(STR(aSubPag[nX][2],,2)) + "|"
	Next nX					
Else // Retorna a forma de pagamento que gerou o troco
	If Len(aTotForm) = Len(aFormPag)
		lDinh := aScan(aFormPag,{|x|upper(x[2]) == "R$" }) > 0
		For nX:= 1 To Len(aTotForm)
			//Reorneda o Array
			Aadd(aSubPag, {aFormPag[nX][1],;
							aFormPag[nX][2],;
							aFormPag[nX][3],;
							aFormPag[nX][4],;
							aTotForm[nX]};
							)			
			//	Retorna a forma de pagamento que gerou o troco
			If lfontTroc
				If empty(cFormTroco)
					cFormTroco := Frt272Get()
					aFormTroco := Separa (cFormTroco, "|")
				EndIf	
				If !Empty(cFormTroco) .And. AllTrim(aFormPag[nX][2]) == AllTrim(aFormTroco[1]) .AND. aTotForm[nX] == Val(aFormTroco[2])
					cFormaPagto := 	aFormTroco[1]
				EndIf
			ElseIf nCont < aTotForm[nX] 
				nCont		:= aTotForm[nX]
				cFormaPagto := aFormPag[nX][2]
			EndIf
		Next nX

		aSubPgto := ASORT(aSubPag, , , { | x,y | x[5] < y[5] } )
		For nx:= 1 to Len(aSubPag)
			aFormPag[nX][1]	:=	aSubPgto[nX][1]
			aFormPag[nX][2]	:=	aSubPgto[nX][2]
			aFormPag[nX][3]	:=	aSubPgto[nX][3]
			aFormPag[nX][4]	:=	aSubPgto[nX][4]
			aTotForm[nX]	:=	aSubPgto[nX][5]
		Next
	EndIf
EndIf

Return cFormaPagto

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F271GInuti
Funcao para realizar inutilizacao de numero de NFC-e (atraves do SLX)
@type 		Function
@author	   	Varejo
@return		NIL
@since		07/07/2016
/*/
//------------------------------------------------------------------------------------------------------------------
Function F271GInuti(cMsgErro,cSupervisor)
Local lInutSLX := ExistFunc("Lj7SLXDocE") .And. SLX->(ColumnPos("LX_MODDOC")) > 0 //Verifica se esta implementado no ambiente o controle de inutilizacao de NFC-e pela tabela (SLX)

Default cMsgErro	:= ""		//Mensagem de Erro
Default cSupervisor := ""

//Novo tratamento de inutilizacao (atraves do SLX)
If lInutSLX
	//Deve estar posicionado na SL1
	If !Empty(SL1->L1_DOC) .And. !Empty(SL1->L1_SERIE)
		//Inclui o DOCUMENTO na SLX para ser inutilizado
		Lj7SLXDocE("65", SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_PDV, SL1->L1_OPERADO, Nil, cMsgErro,cSupervisor)

		//Reseta os campos
		RecLock("SL1",.F.)
		SL1->L1_DOC 	:= "NFCe"
		SL1->L1_KEYNFCE	:= ""
		SL1->(MsUnLock())

		cCaixa := xNumCaixa()

		//Grava SLI para posteriormente o FRTA020 enviar o registro da SLX para retaguarda.
		FRTGeraSLI( cCaixa, "LOG", Str(SLX->(Recno()),17,0), "NOVO" )
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FrtGCtrlNCC
Funcao responsável por apagar os registros temporarios da tabela 
MDJ e MDK que servem de controle para em caso de restauração de venda 
pago em NCC
@author	Varejo
@param		nRecMDJ - numero do recno da MDJ criada
@return	Nil
@since		21/10/2016
/*/
//-------------------------------------------------------------------
Static Function FrtGCtrlNCC(nRecMDJ)

Default nRecMDJ  := 0 

If nRecMDJ > 0

	MDJ->(DBGoTo(nRecMDJ))

	MDK->(DbSetOrder(1))	//MDK_FILIAL + MDK_DOC + MDK_SERIE + MDK_CLIENTE + MDK_LOJA + MDK_SITUA
	If MDK->(DbSeek( MDJ->(MDJ_FILIAL + MDJ_DOC + MDJ_SERIE + MDJ_CLIENT + MDJ_LOJA) ))

		While !MDK->(EOF()) .And.	MDK->(MDK_FILIAL+MDK_DOC+MDK_SERIE+MDK_CLIENTE+MDK_LOJA) == ;
										MDJ->(MDJ_FILIAL+MDJ_DOC+MDJ_SERIE+MDJ_CLIENTE+MDJ_LOJA)

			If MDK->(RecLock("MDK",.F.))
				MDK->(DBDelete())
				MDK->(MSUnlock())
			EndIf

			MDK->(DBSkip())
		End
	EndIf

	If MDJ->(RecLock("MDJ",.F.))
		MDJ->(DBDelete())
		MDJ->(MSUnlock())
	EndIf
EndIf

Return Nil
