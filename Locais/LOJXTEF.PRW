#INCLUDE "PROTHEUS.CH"   
#INCLUDE "LOJXTEF.CH" 
#INCLUDE "AUTODEF.CH"
		
#DEFINE _FORMATEF 		"CC;CD;CV"     // Formas de pagamento que utilizam operação TEF para validação
#DEFINE TEF_CLISITEF	"6"			//Utiliza a DLL CLISITEF
#DEFINE TEF_NAO_USADO	"1"			//Nao Utiliza TEF

#DEFINE LOG_TEF LjLogTef()			// Log do TEF
#DEFINE ARQLJINI GetClientDir()+"SIGALOJA.INI"		// caminho do ini do SIGALOJA

// Se nao existir o SIGALOJA.INI mantem sempre o totalizador "01" como default porque temos um legado que sempre utilizou desta forma
STATIC cTotalizNFis	:= GetPvProfString("Comprovante TEF", "Totalizador", "01", ARQLJINI )
// Nome da Forma de Pagto utilizado no Correspondente Bancario para dinheiro
STATIC cFrmPgDi     := AllTrim(GetPvProfString("Comprovante TEF", "FormaPgDin", "", ARQLJINI ))

Static lAchouSLG 	:= LJVerifSLG()							// Verifica se existe registro na tabela SLG
Static cFormRecar	:= ""									// Forma da recarga de celular
Static oGlobal		:= LJCGlobal():Global()
Static lCanFull 	:= .F.									// Indica que todas as transacoes foram canceladas
Static nTransCH		:= 0									// Controla contador do Cheque
Static nPosCH		:= 0									// Posicao de Cheques no array das  transacao
Static cStrRet		:= ""
Static lPharmSys	:= .F.                  				//Verifica se e operacao do PBM PharmaSystem
Static lCancLJ140	:= .F.
Static aVndCLJ140	:= {}
Static cDocCLJ140	:= ""
Static lIsDocTef	:= .T. 									// Valida se o numero mandado para cancelamento é DOCTEF
Static lPendDll		:= NIL																	// Verifica se Existe transações pendentes
Static lTEFSave		:= SuperGetMV("MV_TEFSAVE",,2) == 1 //Sistema deve guardar e recuperar os dados da transação TEF realizada na venda caso ocorra algum problema antes de concluir a venda? (1=Sim;2=Não)  
Static lVldPend		:= .T.
  
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LOJXTEF  ºAutora ³Solange Zanardi     º Data ³  11/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para testes da chamada das novas rotinas TEF, estas º±±
±±º          ³ chamadas se darao na interface de vendas                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º ALTERACOES EFETUADAS EM FUNCAO DE HOMOLOGACAO NA SOFTWARE EXPRESS                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Data: 25/08/2005 - Homologação do FrontLoja Linux - Cesar Valadão                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º 1. Quando ocorrer uma queda do sistema no meio de uma transação TEF, ao reestabelecer o sistema,      º±±
±±º deve-se efetuar o cancelamento da transação que estava sendo realizada, evitando assim que a mesma    º±±
±±º fique como PENDENTE no SiTEF.                                                                         º±±
±±º 2. A CliSiTEF aceita apenas 6 dígitos no campo número do cheque.                                      º±±
±±º 3. No momento da impressão do cupom TEF, havia um AllTrim que desposicionava a impressão da           º±±
±±º primeira linha. (Detalhe: o cupom TEF não pode sofrer nenhuma alteração)                              º±±
±±º 4. Quando houver falha na impressão do cupom TEF a mensagem a ser exibida deve ser : "Deseja imprimir º±±
±±º novamente?" e "Impressora não responde"                                                               º±±
±±º 5. Quando estava sendo exibido os dados da consulta CDC ou consulta Tecban, tinha um AllTrim          º±±
±±º desposicionando a primeira linha.                                                                     º±±
±±º 6. Não estava sendo validada a data informada nos campos de data.                                     º±±
±±º 7. A data do cartão pré-datado deve ser maior que a data atual.                                       º±±
±±º 8. A fonte usada para exibir as parcelas da consulta CDC não era uma fonte de tamanho fixo.           º±±
±±º 9. Quando aparece a mensagem TRANSACAO OK, a mesma deve fechar automaticamente após 3 segundos. Ela   º±±
±±º nao deve parar o processo.                                                                            º±±
±±º 10.Implementacao dos novos processos de re-certificacao para a versao Visa 4.1                        º±±
±±º 11. Implementado a tela de solcitação de cupom fiscal no momento do cancelamento paela rotinas 		  º±±
±±º		administrativas																					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOJXTEF()
//Local aDados	:= {}
//Local i
//Local nValTot

//oTEF:Operacoes("VIDALINK_CANCELAMENTO", {})
/*
aDados := {"00000001"}
oTEF:Operacoes("VIDALINK_CONSULTA", aDados)
If oTEF:lTEFOk
	aDados  := {"00000001", {}, 0}
	nValTot := 0
	For i := 1 To oTEF:aRetVidaLink:nQtdeMed
		AAdd(aDados[2], {oTEF:aRetVidaLink:aItems[i]:nIndice,;
						 oTEF:aRetVidaLink:aItems[i]:cCodigo,;
						 oTEF:aRetVidaLink:aItems[i]:nQuantAut,;
						 oTEF:aRetVidaLink:aItems[i]:nPrecoRecomend})
		nValTot += oTEF:aRetVidaLink:aItems[i]:nQuantAut * oTEF:aRetVidaLink:aItems[i]:nPrecoRecomend
	Next
	aDados[3] := nValTot
	oTEF:Operacoes("VIDALINK_VENDA", aDados)
EndIf
oTEF:ImpCupTef()
*/
/*
aDados := {{dDataBase,;			// Data
			nValTot,;			// Valor
			"CC",;				// Forma
			"1",;				// ID Cartao
			1,;					// Parcelas
			0,;					// Valor de Entrada
			{}}}				// Array com os dados do Cheque
oTEF:Operacoes("V", aDados)
If oTEF:lTEFOk
	oTEF:ImpCupTef()			// Imprime o cupom TEF e confirma a transacao
Else
	oTEF:FinalTrn(1)			// Se nao imprimiu o cupom TEF, manda o desfazimento
EndIf

//Menu para seleção do tipo de operacao a ser efetuada
oTEF:Operacoes("",{})
If oTEF:lTEFOk
	oTEF:ImpCupTef()			// Imprime o cupom TEF e confirma a transacao
Else
	oTEF:FinalTrn(1)			// Se nao imprimiu o cupom TEF, manda o desfazimento
EndIf
*/

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Classe    ³ MSTEF       ³ Autor ³ Cesar Valadao      ³ Data ³ 09/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Criando a classe MSTEF utilizando os recurso da CLISITEF32I³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
CLASS MSTEF

	DATA lAtivo 									//Indica se o TEF foi inicializado pela abertura de terminal
	DATA aDados										//Contem os dados da venda enviados pela interface
	DATA cIPSiTEF	  								//Armazena o IP do servido SiTEF cadastrado na estação
	DATA cIDLoja									//Armazena o número da empresa do SiTEF
	DATA nIDTermina									//Armazena o número de terminal TEF cadastrado na estação
	DATA nCodFuncao									//Armazena o codigo da funcao que esta sendo executada
	DATA nCodTrans									//Codigo da transacao que esta sendo efetuada, atraves deste sabemos se é consulta CDC, etc...	
	DATA cCupom										//Cupom fiscal impresso no momento da venda
	DATA cOperador									//Operador de caixa
	DATA cData 										//Data da venda
	DATA cHora										//Hora da venda
	DATA nProxComan									//Armazena o próximo comando a ser executado 	
	DATA nTipoCampo 								//Tipo de campo a ser tratado pela automação no retorno
	DATA nTamMin									//Tamanho mínimo do campo a ser coletado pela automação
	DATA nTamMax									//Tamanho máximo do campo a ser coletado pela automação	
	DATA cBuffer									//Armazena todo o conteudo a trocado entre automacao e SiTEF
	DATA nTamMaxBuffer								//Tamanho do buffer trocado
	DATA nContNaveg									//Indica se continua o processo interativo
	DATA lRestric									//Restricoes passadas ao Sitef
	DATA nRet										//Armazena o valor retornado da funcao continua
	DATA cGet										//Variavel para controle dos dados digitados pelo operador
	DATA vGet										//Variavel para controle dos dados digitados pelo operador na coleta de campo monetário
	DATA cMsnCli									//Variavel a ser exibida somente para o cliente
	DATA cMsnOpe									//Variavel a ser exibida somente para o operador
	DATA cMsnAmbos									//Variavel a ser exibida somente para o cliente e o operador
	DATA aValid										//Array com o conteudo aceito na digitacao do operador
	DATA cCom										//Codigo da compensacao bancaria para consulta de cheques
	DATA cBco										//Banco para consulta de cheques
	DATA cAge										//Agência para consulta de cheques
	DATA cChe										//Número do cheque para consulta de cheques
	DATA cCta										//Conta Corrente para consulta de cheques	
	DATA cC1										//Controle bancario	1 para consulta de cheques
	DATA cC2										//Controle bancario 2 para consulta de cheques
	DATA cC3										//Controle bancario 3 para consulta de cheques
	DATA aRetCartao									//Array que armazena os dados de uma venda com cartao para processo de gravacao financeira
	DATA aRetRecarga								//Array que armazena os dados de uma recarga de celular para gravacao financeira
	DATA aRetCorresp								//Array que armazena os dados de um correspondente bancario para gravacao financeira
	DATA aRetVidaLink								//Array que armazena os dados de uma operacao VidaLink
	DATA aRetDotz									//Array que armazena os dados de um resgate de pontos Dotz
	DATA aAdm  										//Codificação das administradoras padrões da Software Express
	DATA aAdmCD										//Codificação das administradoras padrões da Software Express para cartao de debito
	DATA aRedes										//Codificação das Redes Autorizadas
	DATA nTrans										//Controle da transacao que esta sendo efetuada, para Multi-TEF
	DATA lTefOK										//Indica se as transações foram efetuadas com sucesso
	DATA lImprimiu									//Indica se imprimiu o Cupom TEF
	DATA nTotTrans									//Total de transações a serem efetuadas
	DATA cTitle										//Titulo a ser utilizado na tela do TEF
	DATA lHomolog									//Indica se esta sendo feita a homologacao na Software Express ou nao
	DATA lTemPbm									//Indica se a transacao da PBM ficou pendente na inicializacao do sistema
	DATA lTemPinPad									//Indica se o pinpad está cunfigurado ou presente na estacao
	DATA lLeCodBar                                  //Indica se o codigo de barras foi lido ou digitado pelo usuario   
	DATA cCupomRedu									//Guarda o cupom reduzido para ser impresso no rodape do cupom fiscal
	DATA nTransCB									//Controle da transacao CB que esta sendo efetuada, para Multiplos Pagtos
	DATA nVlrPgCB
	DATA lEstVenda	                                //Transacao é estorno de Vendas ?
	DATA aRetRecCP									//Array que armazena os dados de uma recarga de "Cartao Presente" (Gift Card) para gravacao financeira
	DATA nTransCP									//Controle da transacao de Recarga de Cartao Presente (Gift Card) que esta sendo efetuada, para controlar varias recargas na mesma venda
    DATA nTimeOut23									//timeout da Transacao 23
    Data nSecFin23									//Finalização do laço da transacao 23
    Data nTimeOutC23								//TimeOut de Confirmação da 23
    Data nSecFinC23									//Segundos da transação 23
	Data cMens23									//mensagem do campo 23
	Data cParamAdic									// parametros adicionais do Metodo SIT_CONFEX
	
	METHOD New(cIPSiTEF, cIDLoja, nIDTermina)		//Abertura do terminal TEF
	METHOD IniciaTrn()								//Inicia qualquer tipo de operação, execeto a operação TEF
	METHOD ContinTrn()								//Continua processo da interativo com a DLL, utilizado por todas as transações
	METHOD FinalTrn()								//Finaliza transação TEF quando esta necessitar de encerramento
	METHOD LeCodBar(cCMC7)                          //Le o codigo de barras com o CMC7 preenche o campo 
	METHOD ImpCupTef()								//Efetua a impressao do cupom TEF
	METHOD CorrespTrn()								//Método específico para Correspondentes Bancários, substitui a inicia neste caso
	METHOD LjGravaCB()                              //Metodo Chama a funcao de wbservices para a gravacao dos dados de correspondente bancario 
	METHOD LjEstornoCB()                            //Metodo Chama a funcao de wbservices para o estorno dos dados de correspondente bancario no SE1 e SE5 
	METHOD Operacoes()								//Abre um leque com todas as operações disponíveis no TEF
	METHOD TestaPin()								//Executa a funcao de teste do PinPad
	METHOD VidaLinkCO()								//Efetua a consulta atraves do numero de pre-autorizacao
	METHOD VidaLinkPR()								//Efetua o registro dos produtos retornados pela consulta
	METHOD VidaLinkVD()								//Efetua confirmacao dos produtos 
	METHOD VidaLinkCA()								//Efetua o cancelamento de uma transacao
	METHOD PharmSysCO()								//Efetua a consulta atraves do numero de pre-autorizacao
	METHOD PharmSysCA()								//Efetua o cancelamento de uma transacao
	METHOD FuncardCO()								//Efetua a consulta atraves do numero de pre-autorizacao
	METHOD LjRecCelProd()							//Verifica se o produto e recarga de celular
	METHOD RecargaNFiscal()							//Faz a Recarga de Celular Nao Fiscal
	METHOD CartaoPresenteGiftCard()					//Efetua Operacoes Relacionadas a Cartao Presente (Gift Card)
	METHOD LjGrvBaixaCel()							//Chama a funcao de wbservices para a gravacos dos dados da venda de recarga de celular nao fiscal
	METHOD LjRecCel()								//Verifica se esta configurado a recarga de celular
	METHOD SitefDireto(	nRedeDestino	, nFuncaoSitef	, nOffSetCartao	, cDadosTx			, ;
						nTamDadosTx		, cDadosRx		, nTamMaxDadosRx, nCodigoResposta 	, ;
						nTempoEsperaRx 	, cCupomFiscal 	, cDataFiscal	, cHorario 			, ;
						cOperador 		, nTipoTransacao )
	METHOD LeCartDir(cMensagem, cTrilha1, cTrilha2)
	METHOD LjCancPbm()								//Realiza o cancelamento da PBM
	METHOD CupomReduz()								//Verifica se tem cupom reduzido
	METHOD SetDadChq(cBufCMC7)						//Responsavel em formatar os dados do cheque de cada banco
	METHOD LjxGrvTrn()								//Gravacao do log da operacao TEF	
	METHOD GetCBVlrPgt()						    //Calcula o Valor Total Pago para CB
	METHOD LjDigCPF()								// Apresenta tela para digitação do CPF
ENDCLASS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³ MSRetCartao ³ Autora³ Solange Zanardi    ³ Data ³ 22/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Classe que armazena o retorno das transacoes de venda      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS MSRetCartao
	DATA cIDCart									//ID que identifica o cartão na interface de vendas
	DATA cForma										//Recebe a forma de pagamento processada pelo TEF
	DATA lJurLoja									//.T. -  "LOJA" ou "ADM"
	DATA cDescTipPg									//Contém o texto real da modalidade pagamento ou cancelamento que pode ser memorizado pela aplicação caso exista essa necessidade. Descreve por extenso o par xxnn fornecido em 110
	DATA cDescCupPg									//Contém o texto descritivo da modalidade de pagamento que deve ser impresso no cupon fiscal (p/ex: T.E.F., Cheque, etc...)
	DATA dDataTrans									//Data da transacao	
	DATA cHoraTrans									//Hora da transacao	
	DATA cAdiCart									//Contem dados adicionais de cartoes especificos
	DATA cAutentic									//Armazena a linha de autenticação do cheque
	DATA cCupom01									//Primeira via do cupom TEF
	DATA cCupom02									//Segunda via do cupom TEF
	DATA nVlrTroco									//Valor de troco coletado
	DATA cDescAdm									//Nome da Administradora de cartao	
	DATA cCodAdm									//Codigo da Administradora no Protheus
	DATA cTipCart									//Identificador de cartao diferenciado
	DATA cNsuSitef									//Contém o NSU do SiTEF (6 posições)
	DATA cNsuAutor									//Contém o NSU do Host autorizador (15 posições no máximo)
	DATA cAutoriza									//Contém o Código de Autorização para as transações de crédito (15 posições no máximo)
	DATA cPosCart									//Contém as 6 primeiras posições do cartão (bin)	
	DATA nParcelas									//Número de parcelas em venda parcelada
	DATA nVlrEntrada								//Valor de Entrada na Transacao TEF
	DATA nVlrTrans									//Valor total da transacao TEF
	DATA dEntrada									//Data da entrada quando a transacao utilizar
	DATA aDatas										//Contem as datas de vencimento das faturas de cartão
	DATA aValores									//Valores das parcelas
	DATA nVlrCanc									//A rotina está sendo chamada para ler o Valor a ser cancelado. Caso o aplicativo de automação possua esse valor, pode apresentá-lo para o operador e permitir que ele confirme o valor antes de passá-lo devolvê-lo para a rotina. Caso ele não possua esse valor, deve lê-lo.
	DATA cTrilha1									//Contém a Trilha 1, quando disponível, obtida na função LeCartaoInterativo
	DATA cTrilha2									//Contém a Trilha 2, quando disponível, obtida na função LeCartaoInterativo
	DATA cSenha										//Contem a senha do cliente capturada através da rotina LeSenhaInterativo e que deve ser passada a lib de segurança da Software Express personalizada para o estabelecimento comercial de forma a obter a senha aberta
	DATA cTipDoc									//Tipo do Documento a ser consultado (0 - CPF, 1 - CGC)
	DATA cNumDoc									//Numero do documento (CPF ou CGC)
	DATA cTelefone									//Número do Telefone
	DATA nTaxa										//Taxa de Serviço
	DATA lAvista									//Captura se a primeira parcela é a vista ou não (0 - Primeira a vista, 1 - caso contrário)
	DATA nIntervalo									//Intervalo em dias entre parcelas
	DATA lMesFechado								//Captura se é mês fechado (0) ou não (1)
	DATA lGarantido									//Captura se é com (0) ou sem (1) garantia no pré-datado com cartão de débito
	DATA cCartao									//Número do Cartão de Crédito Digitado
	DATA cVencCartao								//Data de vencimento do Cartão MMAA
	DATA cCegCartao									//Código de segurança do Cartão	
	DATA dDataCanRei								//Data da transação a ser cancelada (DDMMAAAA) ou a ser re-impressa
	DATA cDocCanRei									//Número do documento a ser cancelado ou a ser re-impresso
    DATA cChqCom									//Codigo da compensacao do cheque
	DATA cChqBco									//Codigo do banco utilizado no cheque
	DATA cChqAge									//Codigo da agencia utilizada no cheque
	DATA cChqC1										//Controle de digitos 01 do cheque
	DATA cChqCta									//Codigo da conta corrente do cheque
	DATA cChqC2										//Controle de digitos 02 do cheque
	DATA cChqNum									//Numero do cheque
	DATA cChqC3										//Controle de digitos 03 do cheque
	DATA cNumCarCript								//Guarda o numero do cartao criptografado (operacao de pre-autorizacao)
	DATA cDataValida                                //Guarda a data de validade (operacao de pre-autorizacao)
	DATA cDescCart	                                //Descricao do cartao que foi utilizado
	DATA cCodRede		                            //Codigo da Rede que foi utilizada
	DATA cDescRede		                            //Descricao da Rede que foi utilizada

	METHOD New()									//Inicializa o objeto
ENDCLASS

METHOD New() CLASS MSRetCartao

::cIDCart		:= ""
::cForma 		:= ""
::lJurLoja		:= .F.
::cDescTipPg	:= ""
::cDescCupPg	:= ""
::dDataTrans	:= CtoD("")
::cHoraTrans	:= ""
::cAdiCart		:= ""
::cAutentic		:= ""
::cCupom01		:= ""
::cCupom02		:= ""
::nVlrTroco		:= 0
::cDescAdm		:= ""
::cCodAdm		:= ""
::cTipCart		:= ""
::cNsuSitef		:= ""
::cNsuAutor		:= ""
::cAutoriza		:= ""
::cPosCart		:= ""
::nParcelas		:= 1
::nVlrEntrada	:= 0
::nVlrTrans		:= 0
::dEntrada		:= CtoD("")
::aDatas		:= {}
::aValores		:= {}
::nVlrCanc		:= 0
::cTrilha1		:= ""
::cTrilha2		:= ""
::cSenha		:= ""
::cTipDoc		:= ""
::cNumDoc		:= ""
::cTelefone		:= ""
::nTaxa			:= 0
::lAvista		:= .F.
::nIntervalo	:= 0
::lMesFechado	:= .F.
::lGarantido	:= .F.
::cCartao		:= ""
::cVencCartao	:= ""
::cCegCartao	:= ""
::dDataCanRei	:= CtoD("")
::cDocCanRei	:= ""
::cChqCom		:= ""
::cChqBco		:= ""
::cChqAge		:= ""
::cChqC1		:= ""
::cChqCta		:= ""
::cChqC2		:= ""
::cChqNum		:= ""
::cChqC3		:= ""
::cNumCarCript:= ""							
::cDataValida := ""
::cDescCart	:= ""
::cCodRede 	:= ""
::cDescRede 	:= ""

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³ MSRetRecarga³ Autora³ Solange Zanardi    ³ Data ³ 22/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Classe com os retornos das transacoes de recarga de celular³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS MSRetRecarga

	DATA cOpera													//Operadora de celular 
	DATA nValor                   								//Valor selecionado para a recarga
	DATA cCelular                          						//DDD + Número do celular a ser recarregado
	DATA cDigitos        										//Digito(s) verificadores
	DATA cCep													//Cep da localidade onde está o terminal no qual a operação está sendo feita	
	DATA cComprov												//Comprovante da recarga
	DATA cDescAdm												//Descricao da Operadora responsavel pela Recarga
    DATA cChqCom												//Codigo da compensacao do cheque
	DATA cChqBco												//Codigo do banco utilizado no cheque
	DATA cChqAge												//Codigo da agencia utilizada no cheque
	DATA cChqC1													//Controle de digitos 01 do cheque
	DATA cChqCta												//Codigo da conta corrente do cheque
	DATA cChqC2													//Controle de digitos 02 do cheque
	DATA cChqNum												//Numero do cheque
	DATA cChqC3													//Controle de digitos 03 do cheque

	METHOD New()												//Inicializa o objeto

ENDCLASS        

METHOD New() CLASS MSRetRecarga

::cOpera		:= ""
::nValor    	:= 0 
::cCelular  	:= ""
::cDigitos  	:= ""
::cCep			:= ""
::cComprov  	:= ""
::cDescAdm		:= ""
::cChqCom		:= ""
::cChqBco		:= ""
::cChqAge		:= ""
::cChqC1		:= ""
::cChqCta		:= ""
::cChqC2		:= ""
::cChqNum		:= ""
::cChqC3		:= ""

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³ MSRetRecCP  ³ Autora³ Vendas Clientes    ³Data³25/Jun/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Classe com os retornos das transacoes de recarga de "Cartao³±±
±±³          ³ Presente" (Gift Card).                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS MSRetRecCP

	DATA cSeqControl 											//Sequencia de controle da transacao de Recarga de Cartao Presente (Gift Card)
	DATA nValor                   								//Valor informado para a recarga
	DATA cComprov												//Comprovante da recarga
	
	METHOD New()												//Inicializa o objeto

ENDCLASS        

METHOD New() CLASS MSRetRecCP

::nValor    	:= 0 
::cComprov  	:= ""

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³ MSRetCorresp³ Autora³ Solange Zanardi    ³ Data ³ 22/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Classe com o retorno das transacoes de corresp.bancario    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS MSRetCorresp

	DATA dDataVenc												//Data de vencimento do título/convênio no formato aaaammdd
	DATA nVlrPgto												//Valor Pago
	DATA nVlrOrig 												//Valor Original		
	DATA nVlrAcre                                               //Valor Acréscimo
	DATA nVlrAbat                                               //Valor do Abatimento
	DATA dDataPgto                                              //Data Contábil do Pagamento
	DATA cCedente                                               //Nome do Cedente do Titulo. Deve ser impresso no cheque quando o pagamento for feito via essa modalidade
	DATA nOrdem													//Índice do documento, no caso do pagamento em lote, dos campos 600 a 604 que virão em seguida
	DATA cForma													//Modalidade de pagamento utilizada na função de correspondente bancário. Segue a mesma regra de formatação que o campo de número 100
	DATA nVlrLote												//Valor total dos títulos efetivamente pagos no caso de pagamento em lote
	DATA nVlrNaoPago											//Valor total dos títulos não pagos no caso de pagamento em lote
	DATA cNsuCB													//NSU Correspondente Bancário	      
	DATA cTipo													//Tipo do documento: 0 ' Arrecadação, 1 ' Titulo (Ficha de compensação) , -1 ' Ainda não foi possível definir o tipo
	DATA cNsuPg													//NSU SiTef transação de pagamento
	DATA cNsuCancCB												//NSU SiTef da transação original (transação de cancelamento)
	DATA cNsuCancPg												//NSU Correspondente Bancário da transação original (transação de cancelamento)
	DATA nVlrBenef												//Valor do Benefício
	DATA nVlrTroco												//Valor do troco a ser devolvido ao cliente no pagamento em dinheiro
	DATA cRodape												//Código impresso no rodapé do comprovante do CB e utilizado para er-impressão/cancelamento	
	DATA cBarras												//Código em barras pago. Aparece uma vez para cada índice de documento (campo 607). O formato é o mesmo utilizado para entrada do campo ou seja, 0:numero ou 1:numero
	DATA cComprov01  											//Armazena a primeira via do comprovante de pagamento do correspondente	 
	DATA cComprov02  											//Armazena a segunda via do comprovante de pagamento do correspondente	 
	DATA cDescAdm												//Descricao da Administradora responsavel pelo correspondente
    DATA cChqCom												//Codigo da compensacao do cheque
	DATA cChqBco												//Codigo do banco utilizado no cheque
	DATA cChqAge												//Codigo da agencia utilizada no cheque
	DATA cChqC1													//Controle de digitos 01 do cheque
	DATA cChqCta												//Codigo da conta corrente do cheque
	DATA cChqC2													//Controle de digitos 02 do cheque
	DATA cChqNum												//Numero do cheque
	DATA cChqC3													//Controle de digitos 03 do cheque
	DATA cChqLido                                               //Dados do cheque lido no CMC7  
	DATA lEstorno                                               //Controla se e cancelamento de pagamento   

	METHOD New()												//Inicializa o objeto

ENDCLASS

METHOD New() CLASS MSRetCorresp

::dDataVenc 	:= CtoD(" ")
::nVlrPgto		:= 0
::nVlrOrig 		:= 0
::nVlrAcre  	:= 0
::nVlrAbat  	:= 0
::dDataPgto 	:= dDataBase
::cCedente  	:= ""
::nOrdem		:= 0
::cForma		:= ""
::nVlrLote		:= 0
::nVlrNaoPago	:= 0
::cNsuCB		:= ""
::cTipo			:= "-1" 
::cNsuPg		:= ""
::cNsuCancCB	:= ""
::cNsuCancPg	:= ""
::nVlrBenef		:= 0
::nVlrTroco		:= 0
::cRodape		:= ""
::cBarras		:= ""
::cComprov01	:= ""  
::cComprov02	:= ""   
::cDescAdm		:= ""
::cChqCom		:= ""
::cChqBco		:= ""
::cChqAge		:= ""
::cChqC1		:= ""
::cChqCta		:= ""
::cChqC2		:= ""
::cChqNum		:= ""
::cChqC3		:= ""
::cChqLido      := ""    
::lEstorno      := .F.

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³MSRetVidaLink    ³ Autor ³ Cesar Valadao  ³ Data ³ 11/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Classe com o retorno das transacoes do VidaLink            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS MSRetVidaLink
	DATA nQtdeMed												//Quantidade de medicamentos retornados na consulta
	DATA nIndAtual												//Indice do medicamento que esta sendo retornado no VidaLink
	DATA cCNPJConvenio											//CNPJ do Convenio
	DATA cCodPlano												//Codigo do plano de desconto do Convenio
	DATA cCupom01												//Primeira via do cupom VIDALINK
	DATA cCupom02												//Segunda via do cupom VIDALINK
	DATA aItems													//Items da Consulta VIDALINK
	DATA cNsuAutor                                              //Numero de Autorizacao do VidaLink
	DATA cNsuSitef                                              //Numero do NSU do SiTEF 
    DATA cHoraTrans        										//Hora da transacao
    DATA cAutoriza                          					//Contém o Código de Autorização para as transações de crédito (15 posições no máximo)  
    DATA cDescAdm                                               //Nome da Administradora de cartao	
	DATA cTipCart												//Identificador de cartao diferenciado
	DATA lConfTran												//Controla a Confirmacao de Envio da Venda Do Vidalink
	DATA cNumPreAut
	DATA cNomeConveniado	
	DATA cNomEmpConv
	DATA cSaldoDisp	
	DATA cDataIni
	DATA cDataFim	
	DATA cQtdeDependentes
	DATA cCodDependente	
	DATA cNomDependente	
	
	METHOD New()												//Inicializa o objeto

ENDCLASS

METHOD New() CLASS MSRetVidaLink

::nQtdeMed			:= 0
::nIndAtual			:= 0
::cCNPJConvenio		:= ""
::cCodPlano			:= ""
::cCupom01			:= ""
::cCupom02			:= ""
::cNsuAutor	    	:= ""
::cNsuSitef         := ""
::cHoraTrans        := ""
::cAutoriza         := "" 
::cDescAdm          := "" 
::cTipCart          := ""
::lConfTran      	:= .F.
::cNumPreAut		:= ""
::cNomeConveniado := ""
::cNomEmpConv		:= ""
::cSaldoDisp		:= ""
::cDataIni			:= ""
::cDataFim			:= ""
::cQtdeDependentes := ""
::cCodDependente := ""
::cNomDependente	:= ""

Return(Nil)

//--------------------------------------------------------
/*/{Protheus.doc} MSRetDotz
Classe com o retorno das transacoes Dotz 
@type class
@author  	rafael.pessoa
@since   	27/04/2017
@version 	P12.1.16
@param 		
@return	 Nil
/*/
//--------------------------------------------------------
CLASS MSRetDotz

	DATA cCupom01												//Primeira via do cupom 
	DATA cCupom02												//Segunda via do cupom 
	DATA cNsuAutor                                              //Numero de Autorizacao
	DATA cNsuSitef                                              //Numero do NSU do SiTEF 
    DATA cHoraTrans        										//Hora da transacao
	DATA dDataTrans												//Data da transacao	
    DATA cAutoriza                          					//Contém o Código de Autorização para as transações de crédito (15 posições no máximo)  
    DATA cDescAdm                                               //Nome da Administradora de cartao	
	DATA nVlrResDotz		                        			//Valor Resgatado via Dotz
	DATA nVlrSaldoDotz		                        			//Saldo a ser pago
	
	METHOD New()												//Método Construtor

ENDCLASS

METHOD New() CLASS MSRetDotz

::cCupom01			:= ""
::cCupom02			:= ""
::cNsuAutor	    	:= ""
::cNsuSitef         := ""
::cHoraTrans        := ""
::dDataTrans		:= CtoD("")
::cAutoriza         := "" 
::cDescAdm          := ""
::nVlrResDotz       := 0  
::nVlrSaldoDotz     := 0

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Classe    ³MSRetVidaLinkItem³ Autor ³ Cesar Valadao  ³ Data ³ 11/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Classe com os items da consulta das transacoes do VidaLink ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS MSRetVidaLinkItem
	DATA nIndice												//Indice do medicamento
	DATA cCodigo												//Codigo do medicamento
	DATA nQuantAut												//Quantidade autorizada
	DATA nPrecoMax												//Preço unitário máximo de venda ao consumidor
	DATA nPrecoRecomend											//Valor unitário recomendado de venda ao consumidor
	DATA nValVendFarm											//Valor unitário de venda à farmácia. Corresponde ao Valor de venda ao consumidor + Reembolso da farmácia
	DATA nValReembFarm											//Valor unitário de reembolso da farmácia
	DATA nValReposiFarm											//Valor unitário de reposição
	DATA nValSubsidio											//Valor do subsídio do convênio
	DATA nValConsum												//Valor unitrio pagamento a vista
	DATA cStatMedic												//Status do Medicamento - PharmaSystem
    DATA nPerDesc												//% De desconto PharmaSystem
	DATA nValLiq												//Valor Liquido PharmaSystem
	DATA nValRec												//Valor a receber do cliente PharmaSystem
	DATA nValTot												//Valor Total a Pagar PharmaSystem			
	DATA cCRF													//4001	CRF
	DATA cUFCRF													//4002	UF do CRF
	DATA cTipoVen												//4003	Tipo de venda
	DATA nVlCartao												//4006	Valor cartão PBM
	DATA dDataRec												//1029	Data da receita médica
	DATA cTpBPM													//4033	Tipo de documento PBM (0 = CRM, 1 = CRO)
	DATA cCRM													//1023	CRM
	DATA cUF													//1024	UF
	DATA cTpMedic												//1040	Tipo de Medicamento PBM (01–Medicamento, 02-Manipulação, 03-Manipulação Especial, 04-Perfumaria)
	DATA cDescMedic												//1041	Descrição do Medicamento
	DATA cPrecoFun												//1042	Condição p/venda:Se 0 obrigatório utilizar preço Funcional Card (PF) Se 1 pode vender por preço inferior ao preço PF
	DATA nValorFC												//1043	Preço Funcional Card
	DATA nValorPrat												//1044	Preço praticado
	DATA nQtdReceit												//1046	Quantidade receitada
	DATA cRef													//1047	Referência
	DATA cIndPBM												//1048	Indicador da venda PBM (0-Produto venda cartão 1-Produto venda a vista)
											
	METHOD New()												//Inicializa o objeto

ENDCLASS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ New         ³ Autor ³ Cesar Valadao      ³ Data ³ 11/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as variaveis de retorno nas trns do VidaLink    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD New() CLASS MSRetVidaLinkItem

::nIndice			:= 0
::cCodigo			:= ""
::nQuantAut			:= 0
::nPrecoMax			:= 0
::nPrecoRecomend	:= 0
::nValVendFarm		:= 0
::nValReembFarm		:= 0
::nValReposiFarm	:= 0
::nValSubsidio		:= 0
::nValConsum       	:= 0      
::cStatMedic		:= ""  
::nPerDesc			:= 0
::nValLiq			:= 0
::nValRec			:= 0
::nValTot			:= 0                  
::cCRF				:= ""											
::cUFCRF			:= ""											
::cTipoVen			:= ""											
::nVlCartao			:= 0											
::dDataRec			:= ""											
::cTpBPM			:= ""											
::cCRM				:= ""												
::cUF				:= ""												
::cTpMedic			:= ""											
::cDescMedic		:= ""										
::cPrecoFun			:= ""											
::nValorFC			:= 0											
::nValorPrat		:= 0										
::nQtdReceit		:= 0										
::cRef				:= ""												
::cIndPBM			:= ""											

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFAbre ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a chamada para a abertura de terminal TEF não possuiº±±
±±º          ³ retorno pois habilita o parametro lAtivo do objeto         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFAbre()												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFAbre()
Local cIPSiTEF		:= LjGetStation("IPSITEF") 				//IP do servidor de TEF
Local cIDLoja		:= SuperGetMV("MV_EMPTEF")				//Codigo da empresa configurada no Sitef
Local nIDTermina	:= LjGetStation("TERMTEF")				//Codigo do terminal cadastrado na estacao de venda
Local _oTEF

//Inicializa o objeto TEF no momento da abertura de terminal TEF
LjTEFMsn(STR0008+" "+STR0010,{|| _oTEF:=MSTEF():New(cIPSiTEF,cIDLoja,nIDTermina) })

Return(_oTEF)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ New         ³ Autor ³ Cesar Valadao      ³ Data ³ 09/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa o objeto TEF e efetua a abertura de terminal    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
METHOD New(cIPSiTEF, cIDLoja, nIDTermina) CLASS MSTEF
Local nRet													//Controla o retorno da funcao executada através da DLL
Local aRetAbre	:= {}										//Mensagens obrigatorias em caso de erros
Local nPos													//Controle de posicao na array
Local cPADMSG	:= LJGetStation("PADMSG")					//Mensagem do PinPad
Local cMV_LJPRSIT	:= SuperGetMV("MV_LJPRSIT",,"MS")		//Prefixo do Estabelecimento
Local lConteudo		:= .F.									//Verifica se o arquivo ou conteudo do campo LG_LOGTEF existe	
Local lMV_LJCFTEF	:= SuperGetMV("MV_LJCFTEF",,.T.)		//Define se as transacoes TEF pendentes serao Confirmadas ou Canceladas
Local cMVLJTEFPD	:= LjTEFPend(1) 						//Verifica se as transacoes TEF pendentes serao "1=Confirmadas", "2=Canceladas" ou "3=Permanecem Pendentes"
Local cMsgCompl 	:= "" 									//Mensagem Complementar
Local lDelArqTef 	:= .F.
Local aPrgInfo		:= {}									//Versão do Programa
Local nTransac		:= 0									//Transacões pendente 
Local lDesfSav		:= .F.									//Desfaz transação não salva
Local lFrontL		:= !(nModulo <> 23 .Or. (FindFunction("STFIsPOS") .AND. STFIsPOS())) // Verifica se e´ FrontLoja
Local cCNPJEstb		:= SM0->M0_CGC							// CNPJ do estabelecimento
Local lMvLjPdvPa    := LjxBGetPaf()[2] //Indica se eh pdv PAF
Local aTotvsTEF		:= {.T.,""}

If Empty(cMV_LJPRSIT)
	cMV_LJPRSIT := "MS"
Else
	cMV_LJPRSIT := AllTrim(Left(cMV_LJPRSIT, 2))
	If Len(cMV_LJPRSIT) == 1
		cMV_LJPRSIT := "MS"
	EndIf
EndIf
If lPendDll == NIL
	aPrgInfo :=  GetAPOInfo("AUTOCOM.PRW")
	If Len(aPrgInfo) > 0
		lPendDll := aPrgInfo[4] >= Ctod("08/06/2017")
	EndIf
EndIf

//Iniciando variáveis definidas como objetos do TEF
::lAtivo 		:= .F.
::cIPSiTEF   	:= cIPSiTEF
::cIDLoja    	:= cIDLoja
::nIDTermina 	:= nIDTermina
::lHomolog		:= FindFunction("LJHOMTEF") .AND. LjMSSM0(SM0->M0_CGC)		// Indica que esta sendo feita homologacao na Software Express
::lTemPbm		:= .F.
::lLeCodBar     := .F.   
::lEstVenda		:= .F.   
::nTimeOut23	:= 45								//timeout da Transacao 23
::nSecFin23		:= 0							//Finalização do laço da transacao 23
::nTimeOutC23	:= 3							//TimeOut de Confirmação da 23	
::cMens23		:= ""
::nSecFinC23	:= 0
::cParamAdic	:= "[ParmsClient=1=" + cCNPJEstb + ";2=" + _CNPJTOT + "]" // 1=CNPJ do estabelecimento 2=CNPJ da Software House

//Checa no License Server se o cliente tem a licença do TOTVS TEF
If ExistFunc("LjGetLTT")
	If lMvLjPdvPa
		//Quando for PDV PAF, executa a função na retaguarda
		aTotvsTEF := FR271CMyCall( "LjGetLTT")
	Else
		aTotvsTEF := LjGetLTT()
	EndIf
EndIf

If ValType(aTotvsTEF[1]) == "L" .And. !aTotvsTEF[1]
	MsgStop(aTotvsTEF[2],"Totvs TEF")
EndIf

If AllTrim( oAutocom:SIT_VERDLL() ) >= "3.4.1.7"
	oGlobal:GravarArq():Log():Tef():Gravar("ConfiguraIntSitefInterativoEx(IP Sitef: " + ::cIPSiTEF + ", Loja: " + ::cIDLoja + ", Terminal: " + cMV_LJPRSIT + StrZero(::nIDTermina,6) + ", Reservado: " + "0, ParamAdic: " + ::cParamAdic + " )")
	nRet := oAutocom:SIT_CONFEX(::cIPSiTEF, ::cIDLoja, cMV_LJPRSIT + StrZero(::nIDTermina,6), 0, ::cParamAdic)
Else
	oGlobal:GravarArq():Log():Tef():Gravar("ConfiguraIntSitefInterativo(IP Sitef: " + ::cIPSiTEF + ", Loja: " + ::cIDLoja + ", Terminal: " + cMV_LJPRSIT + StrZero(::nIDTermina,6) + ", Reservado: " + "0)")
	nRet := oAutocom:SIT_CONF(::cIPSiTEF, ::cIDLoja, cMV_LJPRSIT + StrZero(::nIDTermina,6), 0)
EndIf

oGlobal:GravarArq():Log():Tef():Gravar("Retorno: " + AllTrim(Str(nRet)))

//Carrega mensagens de retorno consideradas na abertura de terminal
aRetAbre := LjTEFMensa("A")

If nRet <> 0
	If !AllTrim(Str(nRet)) $ "1;2;3;6;7;8"
		If ExistFunc("IsRmt64") .AND. IsRmt64()
			MsgStop(STR0211) //"Erro não previsto pela CLISITEF64I"
		Else
			MsgStop(STR0018) //"Erro não previsto pela CLISITEF32I"
		EndIf
	Else	
		nPos := Ascan(aRetAbre, {|x| x[1] == nRet } )
		MsgStop(AllTrim(Upper(aRetAbre[nPos][2])),STR0006)	//Mensagem SiTEF
	EndIf		
EndIf

::lAtivo 	:= (nRet == 0)

//--------------------------------------------------------------------
//| Quando ocorrer uma queda do sistema no meio de uma transacao TEF |
//| ao reestabelecer o sistema, deve-se efetuar o cancelamento da    |
//| transacao que estava sendo realizada, evitando assim que a mesma |
//| fique como PENDENTE no SiTEF.                                    |
//--------------------------------------------------------------------
If lAchouSLG
	If !Empty(SLG->LG_LOGTEF)
		lConteudo := .T.		
	Endif
Else
	If File(GetClientDir() + "CLISITEF."+StrZero(nIDTermina,3))
		lConteudo := .T.
	Endif
Endif

If ::lAtivo .AND. lConteudo
	cCupom	:= ""
	cData	:= ""
	cHora	:= ""
	If LJTEFConfRW(GetClientDir() + "CLISITEF."+StrZero(nIDTermina,3), .F., @cCupom, @cData, @cHora)  
		// Se não existir o arquivo .CSV para  recuperação, mesmo cMVLJTEFPD = "3",
		// a transação deverá ser cancelada, pois não irá existir arquivo para ser recuperado		
		// Na chamada da função !LjExiTEF(oTEF:cCupom), foi mantida a mesma regra do fonte LOJTEF
		// Aqui não foi incluída a variável lTEFSave, pois a intenção é realmente checar a existêcia do arquivo .CSV de recuperação
		// Desta forma, altera o conteúdo da variável lDesfSav, que vem como .F.
		If  nModulo == 12 .AND. ExistFunc("LjExiTEF")
			lDesfSav := !LjExiTEF(cCupom) 
		EndIf		
		// lDesfSav := .T. - Não existe arquivo .CSV de recuperação
		// lDesfSav := .F. - Existe arquivo .CSV de recuperação
		
		//| Detectar Registros Nao Finalizados |
		// Verifica pelo parametro(MV_LJCFTEF) se as transacoes pendentes serao CONFIRMADAS ou CANCELADAS
		If (lMV_LJCFTEF .And. Empty(cMVLJTEFPD)) .Or. cMVLJTEFPD == "1" //1=Confirma
	       	// Se na entrada do sistema existir transacoes pendentes, as mesmas serao CONFIRMADAS 
			// ### "Confirmando Transacao TEF. Aguarde..."
			oGlobal:GravarArq():Log():Tef():Gravar("Confirmando Transacao TEF pendente.")
			oGlobal:GravarArq():Log():Tef():Gravar("FinalizaTransacaoSiTefInterativo(Confirma: 1, Cupom: " + cCupom + ", Data: " + cData + ", Hora: " + cHora + ")")		
			
			cMsgCompl := STR0177 //"Todas as transacöes pendentes foram confirmadas!"
			
			// Foi modificado o tratamento,agora caso ocorra algum problema na venda anterior vai confirmar a transacao 
			// A justificativa que eh mais facil para o varejista cancelar uma compra indevida do que ele cobrar depois do cliente uma compra devida			
			// STR0176 = "Confirmando Transacao TEF. Aguarde..."
			
			LjMsgrun(STR0176,, {|| ::lAtivo := oAutocom:SIT_FINAL(1, cCupom, cData, cHora) } )
			
			lDelArqTef := .T.

		ElseIf (!lMV_LJCFTEF .And. Empty(cMVLJTEFPD)) .Or. cMVLJTEFPD == "2" //2=Cancela
			// Se na entrada do sistema existir transacoes pendentes, as mesmas serao CANCELADAS 
			// ### "Cancelando Transacao TEF. Aguarde..."
			oGlobal:GravarArq():Log():Tef():Gravar("Cancelando Transacao TEF pendente.")
			oGlobal:GravarArq():Log():Tef():Gravar("FinalizaTransacaoSiTefInterativo(Confirma: 0, Cupom: " + cCupom + ", Data: " + cData + ", Hora: " + cHora + ")")	
			
			cMsgCompl := STR0089 //"Todas as transacöes pendentes foram canceladas!"
			
            // STR0120 - "Cancelando Transacao TEF. Aguarde..."
			LjMsgrun(STR0120,, {|| ::lAtivo := oAutocom:SIT_FINAL(0, cCupom, cData, cHora) } )				
			lDelArqTef := .T.

		ElseIf cMVLJTEFPD == "3" .AND. lTEFSave .AND. !lDesfSav    	// 3=Pendente(cMVLJTEFPD=="3") + lTEFSave(MV_TEFSAVE="1") + existe arquivo .CSV de recuperação(lDesfSav=.F.)
																	// Mantém PENDENTE a transacao TEF
			// Se na entrada do sistema existir transacoes pendentes, as mesmas permanecerao PENDENTES 
			oGlobal:GravarArq():Log():Tef():Gravar("Mantendo a Transacao TEF pendente. Cupom: " + cCupom + ", Data: " + cData + ", Hora: " + cHora )
			
			cMsgCompl := "A transação TEF permanecerá PENDENTE. Comunique o departamento de TI sobre esta ocorrência."

		ElseIf lDesfSav .And. (( lFrontL .And. cMVLJTEFPD <> "4") .Or. !lFrontL)
			oGlobal:GravarArq():Log():Tef():Gravar("Cancelando Transacao TEF pendente nao recuperada.")
			oGlobal:GravarArq():Log():Tef():Gravar("FinalizaTransacaoSiTefInterativo(Confirma: 0, Cupom: " + cCupom + ", Data: " + cData + ", Hora: " + cHora + ")")	
			
			cMsgCompl := STR0197 //"Todas as transacöes pendentes não recuperadas foram canceladas!"
			           
			LjMsgrun(STR0198,, {|| ::lAtivo := oAutocom:SIT_FINAL(0, cCupom, cData, cHora) } )	 //"Cancelando Transação TEF não recuperada. Aguarde"			
			lDelArqTef := .T.
			
		Endif
		                                                                               
		MsgInfo(STR0169 + Chr(10)+ Chr(13) + cMsgCompl)	//"Pode ter ocorrido algum problema na transação de Cartão. Favor verificar a ultima venda!"
	Else
		::lAtivo := .F.
	EndIf
	If !::lAtivo
		// ### "Houve um problema com o arquivo de controle de transação TEF. O TEF permanecerá desabilitado"
		MsgStop( STR0108 )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o campo LG_LOGTEF existe e verifica³
		//³se posicionou no registro                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSLG .And. ((lFrontL .And. cMVLJTEFPD <> "4") .Or. !lFrontL)
			RecLock("SLG",.F.)
			REPLACE SLG->LG_LOGTEF WITH ""
			SLG->(MsUnLock())
		Else
			FErase(GetClientDir() + "CLISITEF."+StrZero(nIDTermina,3))
		Endif
	EndIf
EndIf

If ::lAtivo
	If lConteudo
		::LjCancPbm(cCupom, cData, cHora, lDelArqTef, lMV_LJCFTEF, cMVLJTEFPD, lDesfSav)
	Else
		cCupom	:= ""
		cData	:= ""
		cHora	:= ""
		
		::LjCancPbm(cCupom, cData, cHora, lDelArqTef, lMV_LJCFTEF, cMVLJTEFPD, lDesfSav)
	EndIf
EndIf

If ::lAtivo .And. cTipTEF <> "1"
	
	If lDelArqTef .And. ExistFunc("LjEraseTef") .And. !Empty(cCupom)
		LjEraseTef(cCupom) //Apaga o arquivo de controle dos dados da transacao TEF da venda.
	EndIf
	
	If Empty(cPADMSG)
		cPADMSG := "   MICROSIGA    |AUTOM.COMERCIAL"
	EndIf

	oGlobal:GravarArq():Log():Tef():Gravar("VerificaPresencaPinPad()")

	nRet := oAutocom:SIT_VERPIN()
	
	oGlobal:GravarArq():Log():Tef():Gravar("Retorno: " + AllTrim(Str(nRet)))
	
	If nRet == 1
		oAutocom:SIT_MSNPIN(cPADMSG)
		Self:lTemPinpad := .T.
	Else
		If cModulo != 'TMK'
			Alert(STR0121)						// "Pin-Pad não configurado. Não será possível realizar transações de Débito."
		EndIf
		Self:lTemPinpad := .F.
	EndIf
EndIf

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LJTEFConfRWºAutor ³Cesar Valadao       º Data ³  25/08/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Esta funcao eh utilizada para gravar/ler os dados de uma   º±±
±±º          ³ transacao que esta sendo executada, para evitar que em uma º±±
±±º          ³ queda do sistema, a transacao fique como PENDENTE no SiTEF º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJTEFConfRW(cFile, lWrite, cCupom, cData,;
					 cHora)
Local lRet := .F.													// Retorno da funcao
Local nHandle														// Handle de criacao do arquivo
Local nSize															// Tamanho do buffer a ser lido
Local cBuffer														// Buffer de leitura do arquivo
Local nRead															// Numero de bytes lidos
Local nData 	:= 8
Local nHora 	:= 6
Local nCupom	:= 0	

If lWrite															// Faz a gravacao do arquivo clisitef.<term>
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o campo LG_LOGTEF existe e verifica³
	//³se posicionou no registro                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchouSLG //Variaveis do tipo STATIC
		RecLock("SLG",.F.)
		oGlobal:GravarArq():Log():Tef():Gravar("Guardando dados para confirmacao/desfazimento da transacao(Cupom: " + cCupom + ", Data: " + cData + ", Hora: " + cHora + ")")
		REPLACE SLG->LG_LOGTEF WITH cCupom+cData+cHora 
		SLG->(MsUnLock())
		lRet := .T.		
    Else
		nHandle := FCreate(cFile)
		If nHandle >= 0
			FWrite(nHandle, cCupom+cData+cHora)
			FClose(nHandle)
			lRet := .T.
		EndIf
	Endif
Else																// Faz a leitura do arquivo clisitef.<term>
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o campo LG_LOGTEF existe e verifica³
	//³se posicionou no registro                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchouSLG
		cBuffer := SLG->LG_LOGTEF
	
	Else	
		nHandle	:= FOpen(cFile)
		If nHandle >= 0
			nSize := FSeek(nHandle, 0, 2)
			FSeek(nHandle, 0)
			cBuffer := Space(nSize)
			nRead 	:= FRead(nHandle, @cBuffer, nSize)
			FClose(nHandle)
		EndIf
	Endif
	
	If !Empty(cBuffer := AllTrim(cBuffer))
		nCupom  := Len(cBuffer)- (nData + nHora)
		cCupom := Left(cBuffer, nCupom)
		cData := Substr(cBuffer, nCupom+1, nData)
		cHora := Right(cBuffer, nHora)
		
		lRet := .T.
		If lAchouSLG
			oGlobal:GravarArq():Log():Tef():Gravar("Lendo dados para confirmacao/desfazimento da transacao(Cupom: " + cCupom + ", Data: " + cData + ", Hora: " + cHora + ")")
		EndIf
	EndIf
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³Operacoes ºAutora ³Solange Zanardi     º Data ³  10/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Depois que o objeto TEF estiver acionado com este metodo   º±±
±±º          ³ será possivel chamar o menu com todas as opcoes do TEF     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Tipo da operacao a ser realizada               	  º±±
±±º			 ³ ExpA1 - Array com as informacoes da transacao              º±±
±±º			 ³ ExpL1 - Indica se existe TEF Pendente                      º±±
±±º			 ³ ExpA2 - Array que guarda a transacao que foi aprovada      º±±
±±º			 ³ ExpC2 - Controla a sequencia da transacao.                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
METHOD Operacoes(	cOperacao, aDados    , lTemTEFPend, aTefBKP    , ;
					cSeqTrans, aFormCtrl , aPgtos     , aPgtosSint , ;
					oPgtos   , oPgtosSint, lRelGer	  , aCanLJ140, aCPFCli) CLASS MSTEF   

Local nFuncao  		:= 0									//Número referente a operacao de TEF a ser efetuada

//RETIRAR DO FONTE - SOMENTE PARA TESTES
Local lSai 			:= .T.									//TESTE
Local cOpc			:= "000"								//TESTE
Local cDescOpc		:= ""

DEFAULT aFormCtrl   := {}
DEFAULT aPgtos      := {}
DEFAULT aPgtosSint  := {}
DEFAULT lRelGer     := .F.
DEFAULT aCanLJ140	:= {} 
DEFAULT aCPFCli		:= {}

If Len(aCanLJ140) > 0
	lCancLJ140 := .T.
	aVndCLJ140 := aCanLJ140
	cDocCLJ140 := ""
Else
	lCancLJ140 := .F.
	aVndCLJ140 := {}
	cDocCLJ140 := ""
EndIf

lIsDocTef := .T.

cDescOpc :=	"000:Venda;"
cDescOpc += "100:TeleMarketing;"
cDescOpc += "110:Gerenciais;"
cDescOpc += "111:Teste SiTEF;"
cDescOpc += "112:Menu Re-impressão;"
cDescOpc += "113:Re-impressão Específica;"
cDescOpc += "114:Re-impressão ultimo;"
cDescOpc += "115:Pré-autorização;"
cDescOpc += "116:Captura de pre-autorização;"
cDescOpc += "200:Cancelamento Normal;"
cDescOpc += "201:Cancelamento TeleMarketing;"
cDescOpc += "202:Cancelamento Pré-autorização;"
cDescOpc += "203:Cancelamento Captura de Pré-autorização;"
cDescOpc += "204:Cancelamento Dotz;"
cDescOpc += "210:Cancelamento Venda Credito;"
cDescOpc += "211:Cancelamento Venda Debito;"
cDescOpc += "300:Recarga Celular Pré-Pago (Recarga Nao Fiscal);"						//Recarga de Celular Pre-Pago (Recarga Nao Fiscal)
cDescOpc += "301:Recarga Celular Pré-Pago (Recarga Fiscal);"							//Recarga de Celular Pre-Pago (Recarga Fiscal)
cDescOpc += "669:Cartao Presente Recarga (Modulo GIVEX);"								//Cartao Presente Recarga (Gift Card) [Modulo GIVEX]
cDescOpc += "670:Cartao Presente Cancelamento de Recarga (Modulo GIVEX);"				//Cartao Presente Cancelamento de Recarga (Gift Card) [Modulo GIVEX]
cDescOpc += "680:Cartao Presente Consulta Saldo do Cartao (Modulo GIVEX);"				//Cartao Presente Consulta Saldo do Cartao (Gift Card) [Modulo GIVEX]
cDescOpc += "264:Cartao Presente Recarga (Modulo SQCF / Todo Cartoes);"					//Cartao Presente Recarga (Gift Card) [Modulo SQCF - Todo Cartoes]
cDescOpc += "257:Cartao Presente Cancelamento da Recarga (Modulo SQCF / Todo Cartoes);"	//Cartao Presente Cancelamento da Recarga (Gift Card) [Modulo SQCF - Todo Cartoes]
cDescOpc += "600:Cartao Presente Consulta Saldo do Cartao (Modulo SQCF / Todo Cartoes);"//Cartao Presente Consulta Saldo do Cartao (Gift Card) [Modulo SQCF - Todo Cartoes]
cDescOpc += "762:Digitação de CPF;"
cDescOpc += "837:Acúmulo de Dotz;"
cDescOpc += "838:Resgate de Dotz;"
cDescOpc += "843:Resgate de Produtos Dotz;"
cDescOpc += "900:Correspondente Bancário;"
cDescOpc += "901:Testa PinPad;"
cDescOpc += "902:VidaLink Consulta;"
cDescOpc += "903:VidaLink Venda;"
cDescOpc += "904:VidaLink Cancelamento;"

//Retira o ultimo ponto e virgula (;)
cDescOpc := Left( AllTrim(cDescOpc), Len(cDescOpc)-1 )

If cOperacao == "V" .OR. cOperacao == "C"
	nFuncao := 0

// Incluida operacao TeleMarketing (08/11/05)
ElseIf cOperacao == "T"
	nFuncao := 100

ElseIf cOperacao == "RC"
	nFuncao := 300

ElseIf cOperacao == "RC1"
	nFuncao := 301

ElseIf cOperacao == "CP_RECARGA" //Recarga Cartao Presente (Gift Card)
	If AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "1" //Parametro que indica o Modulo do CliSitef configurado para usar as funcionalidades de "Cartao Presente (Gift Card)"
		nFuncao := 669 //669=Cartao Presente Recarga (Gift Card) [Modulo GIVEX]
	ElseIf AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "2" //Parametro que indica o Modulo do CliSitef configurado para usar as funcionalidades de "Cartao Presente (Gift Card)"
		nFuncao := 264 //264=Cartao Presente Recarga (Gift Card) [Modulo SQCF - Todo Cartoes]
	EndIf

ElseIf cOperacao == "CP_CANCELA" //Cancelamento de Recarga de Cartao Presente (Gift Card)
	If AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "1" //Parametro que indica o Modulo do CliSitef configurado para usar as funcionalidades de "Cartao Presente (Gift Card)"
		nFuncao := 670 //670=Cartao Presente Cancelamento de Recarga (Gift Card) [Modulo GIVEX]
	ElseIf AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "2" //Parametro que indica o Modulo do CliSitef configurado para usar as funcionalidades de "Cartao Presente (Gift Card)"
		nFuncao := 257 //257=Cartao Presente Cancelamento da Recarga (Gift Card) [Modulo SQCF - Todo Cartoes]
	EndIf

ElseIf cOperacao == "CP_CONSULTA" //Consulta Saldo de Cartao Presente (Gift Card)
	If AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "1" //Parametro que indica o Modulo do CliSitef configurado para usar as funcionalidades de "Cartao Presente (Gift Card)"
		nFuncao := 680 //680=Cartao Presente Consulta Saldo do Cartao (Gift Card) [Modulo GIVEX]
	ElseIf AllTrim(SuperGetMv("MV_LJCPMOD", ,"" )) == "2" //Parametro que indica o Modulo do CliSitef configurado para usar as funcionalidades de "Cartao Presente (Gift Card)"
		nFuncao := 600 //600=Cartao Presente Consulta Saldo do Cartao (Gift Card) [Modulo SQCF - Todo Cartoes]
	EndIf

ElseIf cOperacao == "CB"	
	nFuncao := 900

ElseIf cOperacao == "GERENCIAIS"
	nFuncao := 110

// Efetua Pre-Autorizacao
ElseIf cOperacao == "PRE_AUTORIZ"
	nFuncao := 115	

// Captura da Pre-Autorizacao
ElseIf cOperacao == "CAPTURA_PRE_AUTORIZ"
	nFuncao := 116	

// Incluir valor na Pre-Autorizacao
ElseIf cOperacao == "AJUSTA_PRE_AUTORIZ"
	nFuncao := 117	

// Alterar valor da Pre-Autorizacao
ElseIf cOperacao == "ALTERA_PRE_AUTORIZ"
	nFuncao := 913

// Pagamento via Carteira Virtual - Ex: MERCADO PAGO, ITI
ElseIf cOperacao == "CARTEIRA_VIRTUAL"
	nFuncao := 122

// Cancelamento de pagamento via Carteira Virtual
ElseIf cOperacao == "CANCEL_CARTEIRA_VIRTUAL"
	nFuncao := 123

// Cancelamento de transacao de venda (debito ou credito)
ElseIf cOperacao == "CANCEL_VENDA"
	nFuncao := 200
	
// Cancelamento de venda com Cartao de Cred. (Telemarketing)
ElseIf cOperacao == "CANCEL_TELEMARKETING"
	nFuncao := 201

// Cancelamento Pre-Autorizacao  (Telemarketing)
ElseIf cOperacao == "CANCEL_PRE_AUTORIZ"	
	nFuncao := 202
	
// Cancelamento de captura da Pre-Autorizacao  (Telemarketing)
ElseIf cOperacao == "CANCELA_CAPTURA"
	nFuncao := 203
	
ElseIf cOperacao == "CANCELA_DOTZ"
	nFuncao := 204

// Cancelamento de transacao de venda CREDITO
ElseIf cOperacao == "CANCEL_CREDITO"
	nFuncao := 210

// Cancelamento de transacao de venda DEBITO
ElseIf cOperacao == "CANCEL_DEBITO"
	nFuncao := 211

ElseIf cOperacao == "DOTZ_ACUMULO"
	nFuncao := 837
	
ElseIf cOperacao == "DOTZ_RESGATE"
	nFuncao := 838
	
ElseIf cOperacao == "DOTZ_PRODUTO"
	nFuncao := 843		

ElseIf cOperacao == "VIDALINK_CONSULTA"
	nFuncao := 902

ElseIf cOperacao == "VIDALINK_VENDA"
	nFuncao := 903

ElseIf cOperacao == "VIDALINK_CANCELAMENTO"
	nFuncao := 904

// Cancelamento de captura da Pre-Autorizacao  (PharmaSystem)
ElseIf cOperacao == "PHARMASYSTEM_AUTORIZA"
	nFuncao := 540
ElseIf cOperacao == "PHARMASYSTEM_CONSULTA"
	nFuncao := 541

ElseIf cOperacao == "PHARMASYSTEM_VENDA"
	nFuncao := 545

ElseIf cOperacao == "PHARMASYSTEM_CANCELAMENTO"
	nFuncao := 543

ElseIf cOperacao == "FUNCARD_CONSULTA"
	nFuncao := 560

ElseIf cOperacao == "FUNCARD_VENDA"
	nFuncao := 561

ElseIf Empty(cOperacao)	
	If LjTEFMenu(@cOpc,STR0007,cDescOpc,@oTef:nContNaveg)		//"Selecione a operação a ser efetuada"
		nFuncao := Val(cOpc)
		//Efetua os processos de Venda
		While lSai
			lSai := LjTEFTeste()
		End
		If !lSai
			aDados := AClone(oTEF:aDados)
		EndIf
	Else
		Return(.T.)
	EndIf
ElseIf cOperacao == "DIGITA_CPF"
	nFuncao := 762
EndIf

//Inicializa as variáveis e efetua os tratamentos de inicialização da transação TEF
LjTEFStart(	nFuncao   , aDados     , @lTemTefPend, @aTefBKP   , ;
			cSeqTrans , @aFormCtrl , @aPgtos     , @aPgtosSint, ;
			@oPgtos   , @oPgtosSint, @lRelGer, @aCPFCli ) 

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjTEFStartºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua as validacoes necessarias para efetuar a chamada de  º±±
±±º          ³uma venda, recarga, correspondente, etc.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFStart(ExpN1, ExpA1, ExpL1, ExpA2)					  º±±
±±º          ³ ExpN1 - Codigo correspondente a operacao na clisitef32     º±±
±±º          ³ ExpA1 - Informacoes da transacao TEF						  º±±
±±º          ³ ExpL1 - Indica se existe TEF Pendente					  º±±
±±º          ³ ExpA2 - Guarda informacoes da ultima transacao		      º±±
±±º          ³ ExpC1 - Sequencia da transacao TEF.                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFStart(nFuncao   , aDados    , lTemTEFPend, aTefBKP   , ;
					cSeqTrans , aFormCtrl , aPgtos     , aPgtosSint, ;
					oPgtos    , oPgtosSint, lRelGer, aCPFCli)

Local cRestric  	:= ""						//Restricoes a serem consideradas nesta transacao, não exibir no menu de selecao
Local nFor			:= 1						//Contador de laço
Local cValor		:= ""						//Valor em formato de caracter a ser enviado pela DLL
Local cBotoesCons 	:= LjGetStation("TEFCONS") 	//Verifica quais consultas de cheque a estação poderá utilizar
Local nI			:= 0						//Controle de loop
Local nTef          := 1						//Controle para multiplos cartoes
Local cSimb1        := SuperGetMV("MV_SIMB1")	//Variavel que retorna o tipo de Simbolo da Moeda.
Local aAreaL1       := SL1->(GetArea())		//Variavel que guarda a area do L1
Local aAreaF2       := SF2->(GetArea())		//Variavel que guarda a area do F2
Local aAreaL4       := SL4->(GetArea())		//Variavel que guarda a area do L4
Local aArea			:= GetArea()				//Guarda a area corrente
Local lLoopTef		:= .F.
Local nPend			:= 0
Local lPulaCH 		:= .F.
Local nValTCH		:= 0
Local nCh			:= 0
Local cMvRestTef		:=AllTrim(SuperGetMV("MV_LJRETEF",,";29;28"))
Local nTransac		:= 0  //Numero de transacoes TEF
Local cIPSiTEF		:= LjGetStation("IPSITEF")	//IP do servidor de TEF
Local cIDLoja		:= SuperGetMV("MV_EMPTEF")	//Codigo da empresa configurada no Sitef
Local nIDTermina	:= LjGetStation("TERMTEF")	//Codigo do terminal cadastrado na estacao de venda

DEFAULT cSeqTrans	:= StrZero(Randomize(1,999999),6,0)
DEFAULT	aDados		:= {}
DEFAULT aFormCtrl   := {}
DEFAULT aPgtos      := {}
DEFAULT aPgtosSint  := {}
DEFAULT lRelGer     := .F. 
DEFAULT lTemTEFPend := .F.
DEFAULT aCPFCli		:= {}

If lTemTEFPend == Nil 
	lTemTEFPend := .F.
Endif	

//Inicializar todas as variáveis do Objeto TEF
oTef:cIDLoja		:= cIDLoja
oTef:nIDTermina		:= nIDTermina
Otef:cIPSITEF		:= cIPSiTEF

oTef:aDados			:= aClone(aDados)

oTef:cCupom 		:= cSeqTrans																		// Numero do orcamento, sera utilizado para o servidor SITEF
oTef:cData 			:= Str(Year(dDataBase),4)+StrZero(Month(dDataBase),2)+StrZero(Day(dDataBase),2)	// Data para controle da transação
oTef:cHora			:= SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2)					// Hora para controle da transação
oTef:cOperador		:= AllTrim(cUserName)																		// Operador para controle da transação TEF

//Variaveis para inicializacao da Dll
oTef:nProxComan		:= 0
oTef:nTipoCampo 	:= 0
oTef:nTamMin		:= 0
oTef:nTamMax		:= 0
oTef:cBuffer		:= ""
oTef:nTamMaxBuffer	:= 0
oTef:nContNaveg		:= 0

//Controla se o sistema ira trabalhar enviando as restricoes para a DLL
oTef:lRestric		:= GetNewPar("MV_TEFREST",.T.)

//Armazena o retorno das funções executadas pela Dll
oTef:nRet			:= 0

//Variaveis para o controle da tela, gets digitados pelo operador
oTef:cGet			:= ""
oTef:vGet			:= 0
oTef:cMsnCli		:= ""
oTef:cMsnOpe		:= ""
oTef:cMsnAmbos		:= ""
oTef:aValid			:= {}
oTef:cCom			:= Space(3)
oTef:cBco			:= Space(3)
oTef:cAge			:= Space(4)
oTef:cChe			:= Space(6)						// O numero do cheque na CliSiTEF contem no maximo 6 digitos
oTef:cCta			:= Space(10)
oTef:cC1			:= Space(1)
oTef:cC2			:= Space(1)
oTef:cC3			:= Space(1)
oTef:cTitle			:= ""

	
//Armazena os dados para gravacao do financeiro
oTef:aRetCartao		:= {}
If nFuncao == 300 .OR. nFuncao == 301
	oTef:aRetRecarga	:= {}
EndIf

If nFuncao == 837 .OR. nFuncao == 838 //Resgate Dotz
	oTef:aRetDotz	:= {}
EndIf

//Recarga Cartao Presente (Gift Card)
If nFuncao == 669 .OR. nFuncao == 264 //Recarga de Gift Card (669=Modulo Givex; 264=Modulo SQCF - Todo Cartoes)
	If ValType(oTef:aRetRecCP) == "U" .Or. ( Len(oTef:aRetRecCP) > 0 .And. oTef:aRetRecCP[1]:cSeqControl <> cSeqTrans )
		oTef:aRetRecCP := {}
		oTef:nTransCP  := 0
	EndIf
EndIf

oTef:aRetCorresp	:= {}
oTef:cCupomRedu		:= "" 

//Dados fixos da especificao tecnica da Dll
oTef:aAdm  			:= LjTEFTab("ADM")
oTef:aAdmCD			:= LjTEFTab("ADMCD")
oTef:aRedes			:= LjTEFTab("RED")

//Numero da transacao que esta sendo efetuada
oTef:nTrans			:= 0

//Numero da transacao (multiplo Pagtos) que esta sendo efetuada
oTef:nTransCB       := 0                                       

//Total de transações a serem efetuadas
oTef:nTotTrans		:= Len(oTef:aDados)

//Indica se a operacao foi efetuada com sucesso
oTef:lTefOk			:= .F.

//Indica se a impressao do cupom TEF foi efetuado com sucesso para envio de confirmacao
oTef:lImprimiu		:= .F.

//Codigo da funcao utilizada pela Dll
oTef:nCodFuncao		:= nFuncao

//Codigo da transacao efetuada
oTef:nCodTrans		:= 0

If nModulo == 12 .AND. !lTEFSave
	//Se não existe transação TEF Pendente, verifica se existe transacao Pendente
	//Caso exista cancela

	If lPendDll .And. lVldPend
		lVldPend := .F.
		oGlobal:GravarArq():Log():Tef():Gravar("Consultando transação TEF Pendente.")
		nTransac := oAutocom:SIT_OBTQTR(oTef:cData, oTef:cCupom)
		oGlobal:GravarArq():Log():Tef():Gravar("ObtemQuantidadeTransacoesPendentes( Data: " + oTef:cData + ", Cupom: " + oTef:cCupom + ") - retorno " + cValToChar(nTransac))
		If nTransac > 0
			oGlobal:GravarArq():Log():Tef():Gravar("Cancelando Transacao TEF pendente nao recuperada.")
			oGlobal:GravarArq():Log():Tef():Gravar("FinalizaTransacaoSiTefInterativo(Confirma: 0, Cupom: " + oTef:cCupom + ", Data: " + oTef:cData + ", Hora: " + oTef:cHora + ")")	
		
			oAutocom:SIT_FINAL(0, oTef:cCupom, oTef:cData, oTef:cHora)
		
			MsgInfo(STR0199 + Chr(10)+ Chr(13) + STR0200)	//"Pode ter ocorrido algum problema na transação de Cartão"##"Todas as transacöes pendentes não recuperadas foram canceladas!"
		EndIf
	EndIf 
	
EndIf


//CORRESPONDENTES BANCARIOS - STATUS OK						
If oTef:nCodFuncao == 900

	//Zera as informacoes para armazenar os retornos da transacao sempre na posicao 01
	Aadd(oTef:aRetCorresp,{})
	oTef:aRetCorresp[nFor] := MSRetCorresp():New()

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	oTef:nTrans   += 1
	oTef:nTransCB += 1
	
	oTEF:CorrespTrn( oTef:cCupom , oTef:cData , oTef:cHora , oTef:cOperador , cRestric )
	
//TESTE DE PINPAD			- STATUS OK
ElseIf oTef:nCodFuncao == 901
	
	oTef:nTrans += 1
	
	oTEF:TestaPin( oTef:cCupom , oTef:cData , oTef:cHora , oTef:cOperador , cRestric )
	
//As operacoes VidaLink não são iniciadas com o comando IniciaTrn
ElseIf oTef:nCodFuncao == 902

	oTEF:aRetVidaLink := MSRetVidaLink():New()

	oTEF:VidaLinkCO( oTEF:aDados[1][1], "1", oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador )

ElseIf oTef:nCodFuncao == 903

	If Len(oTEF:aDados) >= 2
		For nI := 1 To Len(oTEF:aDados[2])
			oTEF:VidaLinkPR( oTEF:aDados[2][nI][1], oTEF:aDados[2][nI][2], oTEF:aDados[2][nI][3], Str(oTEF:aDados[2][nI][4]*100, 12, 0))
		Next nI
		oTEF:VidaLinkVD( oTEF:aDados[1][1], Len(oTEF:aDados[2]), oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador )
	EndIf	

ElseIf oTef:nCodFuncao == 904

	oTEF:VidaLinkCA( 1, oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador )
                   
ElseIf oTef:nCodFuncao == 592

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	oTef:nTrans   += 1
	oTef:nTransCB += 1


	oTEF:aRetVidaLink := MSRetVidaLink():New()      
	oTEF:PharmsysCO( "592"	, "0",oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador, cRestric  		)

                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³As operacoes PharmaSystem não são iniciadas com o comando IniciaTrn³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf oTef:nCodFuncao == 541 .OR. oTef:nCodFuncao == 540 

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	oTef:nTrans   += 1
	oTef:nTransCB += 1


	oTEF:aRetVidaLink := MSRetVidaLink():New()      
	If oTef:nCodFuncao == 541
		oTEF:PharmsysCO( 541	, "0",oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador, cRestric  		)
	Else
		oTEF:PharmsysCO( 540	, "0",oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador, cRestric  		)		
	Endif

ElseIf oTef:nCodFuncao == 545

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	oTef:nTrans   += 1
	oTef:nTransCB += 1

	oTEF:PharmsysCO( 545	, "1",oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador, cRestric  		)

ElseIf oTef:nCodFuncao == 543

	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	oTef:nTrans   += 1
	oTef:nTransCB += 1

	oTEF:PharmsysCA( 543, "0", "", "", "", "","" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³As operacoes Funcional Card - Consulta Pre autorizacao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf oTef:nCodFuncao == 560

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	oTef:nTrans   += 1
	oTef:nTransCB += 1


	oTEF:aRetVidaLink := MSRetVidaLink():New()      
	oTEF:FuncardCO( 560, "0", oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador, cRestric )
                                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³As operacoes Funcional Card - Venda Pre autorizacao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf oTef:nCodFuncao == 561

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	oTef:nTrans   += 1
	oTef:nTransCB += 1


	oTEF:aRetVidaLink := MSRetVidaLink():New()      
	oTEF:FuncardCO( 561, "0", oTEF:cCupom, oTEF:cData, oTEF:cHora, oTEF:cOperador, cRestric )


//RECARGA DE CELULAR		- STATUS OK
ElseIf oTef:nCodFuncao == 300 .Or. oTef:nCodFuncao == 301
	
	//VERIFICAR SE PRECISA MESMO MANDAR O VALOR
	cValor := AllTrim( StrTran( Str( Round( Round(0,2) , 2 ),12,2 ), ".", "," ) )

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetRecarga,{})
	oTef:aRetRecarga[nFor] := MSRetRecarga():New()

	oTef:nTrans += 1

	oTEF:IniciaTrn( oTef:nCodFuncao , cValor 			, oTef:cCupom 	, oTef:cData 	, ;
					oTef:cHora 		, oTef:cOperador 	, cRestric		, @lTemTefPend	, ;
					@aTefBKP        , @aFormCtrl        , @aPgtos      , @aPgtosSint   , ;
					@oPgtos         , @oPgtosSint       )
	
//RECARGA DE CARTAO PRESENTE (Gift Card)
ElseIf (oTef:nCodFuncao == 669 .Or. oTef:nCodFuncao == 670 .Or. oTef:nCodFuncao == 680) .Or. ; //Operacoes do Modulo (GIVEX)
	(oTef:nCodFuncao == 264 .Or. oTef:nCodFuncao == 257 .Or. oTef:nCodFuncao == 600) //Operacoes do Modulo (SQCF - Todo Cartoes)
	
	//VERIFICAR SE PRECISA MESMO MANDAR O VALOR
	cValor := AllTrim( StrTran( Str( Round( Round(0,2) , 2 ),12,2 ), ".", "," ) )

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
	
	If oTef:nCodFuncao == 669 .Or. oTef:nCodFuncao == 264 //Recarga de Gift Card (669=Modulo Givex; 264=Modulo SQCF - Todo Cartoes)
		//Adiciona uma nova posicao no array "aRetRecCP" para controlar a nova transacao de Recarga de Cartao Presente (Gift Card)
		Aadd(oTef:aRetRecCP,{})
		oTef:nTransCP := Len(oTef:aRetRecCP)
		
		oTef:aRetRecCP[oTef:nTransCP] := MSRetRecCP():New()
	EndIf
	
	oTef:nTrans += 1
	
	oTEF:IniciaTrn( oTef:nCodFuncao , cValor 			, oTef:cCupom 	, oTef:cData 	, ;
					oTef:cHora 		, oTef:cOperador 	, cRestric		, @lTemTefPend	, ;
					@aTefBKP        , @aFormCtrl        , @aPgtos      , @aPgtosSint   , ;
					@oPgtos         , @oPgtosSint       )
	
//GERENCIAIS				 - STATUS OK
ElseIf oTef:nCodFuncao == 110

	//VERIFICAR SE PRECISA MESMO MANDAR O VALOR
	cValor := AllTrim( StrTran( Str( Round( Round(0,2) , 2 ),12,2 ), ".", "," ) )

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
    If ValType (oTef:aRetCartao) == "A" 
		Aadd(oTef:aRetCartao,{})
		oTef:aRetCartao[nFor] := MSRetCartao():New()
	EndIf	

	oTef:nTrans += 1

	oTEF:IniciaTrn( oTef:nCodFuncao	, @cValor 			, @oTef:cCupom	, @oTef:cData , ;
					@oTef:cHora		, @oTef:cOperador	, cRestric 		, @lTemTefPend	, ;
					@aTefBKP	    , @aFormCtrl        , @aPgtos      , @aPgtosSint   , ;
					@oPgtos         , @oPgtosSint       )

// PROGRAMA DE PONTOS DOTZ 
ElseIf oTef:nCodFuncao == 837 .OR. oTef:nCodFuncao == 838 .OR. oTef:nCodFuncao == 843 

	//VERIFICAR SE PRECISA MESMO MANDAR O VALOR
	cValor := AllTrim( StrTran( Str( Round( Round(oTef:aDados[nFor][2],2) , 2 ),12,2 ), ".", "," ) )

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetDotz,{})
	oTef:aRetDotz[nFor] := MSRetDotz():New()

	oTef:nTrans += 1

	oTEF:IniciaTrn( oTef:nCodFuncao , cValor 			, oTef:cCupom 	, oTef:cData 	, ;
					oTef:cHora 		, oTef:cOperador 	, cRestric		, @lTemTefPend	, ;
					@aTefBKP        , @aFormCtrl        , @aPgtos      , @aPgtosSint   , ;
					@oPgtos         , @oPgtosSint       )					
					
//GERENCIAIS
ElseIf oTef:nCodFuncao > 110 .AND. oTef:nCodFuncao < 300 .AND. oTef:nCodFuncao <> 116 .AND. oTef:nCodFuncao <> 122

	//VERIFICAR SE PRECISA MESMO MANDAR O VALOR
	cValor := AllTrim( StrTran( Str( Round( Round(0,2) , 2 ),12,2 ), ".", "," ) )

	//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
	Aadd(oTef:aRetCartao,{})
	oTef:aRetCartao[nFor] := MSRetCartao():New()
    
	oTef:nTrans += 1

	oTEF:IniciaTrn( oTef:nCodFuncao	, cValor 		, oTef:cCupom	, oTef:cData , ;
					oTef:cHora 		, oTef:cOperador, cRestric 		, @lTemTefPend	, ;
					@aTefBKP        , @aFormCtrl    , @aPgtos      , @aPgtosSint   , ;
					@oPgtos         , @oPgtosSint   )

ElseIf oTef:nCodFuncao == 762

	aCPFCli := oTEF:LjDigCPF()
	
//Efetua os processos de Venda
ElseIf oTef:nCodFuncao == 0 .OR. oTef:nCodFuncao == 100 .OR. oTef:nCodFuncao == 116 .OR. oTef:nCodFuncao == 122

	If lTemTEFPend
		oTef:aRetCartao			:= aClone(aTefBKP)
		nTef 					:= 1 + Len(oTef:aRetCartao)
        oTef:lTefOk				:= .T.
		oTef:nTrans				:= Len(oTef:aRetCartao)	

                                                                                       
		
	EndIf
	//Efetuo o laco para MULTI-TEF
	For nFor := nTef To oTef:nTotTrans

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para utilizarmos operações TEF precisaremos passar uma array com as seguintes informações             		 ³
		//³                                                                                                     		 ³
		//³1 - dData                                                                                            		 ³
		//³2 - nValor                                                                                           		 ³
		//³3 - cForma                                                                                           		 ³
		//³4 - cIDCart - ID do cartão enviado pela interface                                                    		 ³
		//³5 - nParcelas - Qtde de parcelas para esta operação                                                  		 ³
		//³6 - Valor de entrada para a transacao TEF                                                            		 ³	
		//³7 - Array com os dados do Cheque qdo existir {cCompensação, cBanco, cAgência, cConta, cCheque, cRG, cTelefone}³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTemTEFPend .AND. nModulo == 23	// Tratamento nao homologado para o SIGALOJA,podera futuramente ser testado e removido o nModulo
			lLoopTef := .F.
			For nPend := 1 to Len(aTefBKP)
				If oTef:aDados[nFor][1]					 = aTefBKP[nPend]:DENTRADA	  .AND.;
					oTef:aDados[nFor][2]	    		 = aTefBKP[nPend]:NVLRTRANS	  .AND.;
					AllTrim(Upper(oTef:aDados[nFor][3])) = aTefBKP[nPend]:CFORMA	  .AND.;
					AllTrim(Upper(oTef:aDados[nFor][4])) = aTefBKP[nPend]:CIDCART	  .AND.;
					oTef:aDados[nFor][6]   				 = aTefBKP[nPend]:NVLRENTRADA .AND.;
					oTef:aDados[nFor][5]				 = aTefBKP[nPend]:NPARCELAS	 
					lLoopTef := .T.
				EndIf	
			Next nPend
			If lLoopTef
				Loop
			EndIf
		EndIf			

		//Zera os dados que irao receber os retornos da DLL para gravacao do financeiro
		Aadd(oTef:aRetCartao,{})
		oTef:aRetCartao[nFor] := MSRetCartao():New()
		oTef:aRetCartao[nFor]:dEntrada		:= oTef:aDados[nFor][1]
		oTef:aRetCartao[nFor]:nVlrTrans		:= oTef:aDados[nFor][2]
		oTef:aRetCartao[nFor]:cForma 		:= AllTrim(Upper(oTef:aDados[nFor][3]))
		oTef:aRetCartao[nFor]:cIDCart 		:= AllTrim(Upper(oTef:aDados[nFor][4]))
		oTef:aRetCartao[nFor]:nParcelas		:= oTef:aDados[nFor][5]
		oTef:aRetCartao[nFor]:nVlrEntrada 	:= oTef:aDados[nFor][6]
		
		//Transformando o valor numérico em string para enviar a DLL
		If oTef:aRetCartao[nFor]:cForma == "CH"
			//se for Ch
			//tem que mandar o total dos cheques para o TEF, senao nao finaliza
			For nCh := nFor  to   oTef:nTotTrans
				If AllTrim(Upper(oTef:aDados[nCh][3])) == "CH"
					nValTCh +=oTef:aDados[nCh][2]
					// Pega aonde inicia os cheques no
					IF nPosCH == 0
						nPosCH   := nFor
					EndIf
				EndIf
			Next
			cValor := AllTrim(StrTran(Str(Round(nValTCh,2),12,2),".",","))
		Else
			cValor := AllTrim(StrTran(Str(Round(oTef:aRetCartao[nFor]:nVlrTrans,2),12,2),".",","))
		Endif

		If oTef:aRetCartao[nFor]:cForma == "CH"
			oTef:cCom	:= PadR(oTef:aDados[nFor][7][6],3)
			oTef:cBco   := PadR(oTef:aDados[nFor][7][2],3)
			oTef:cAge   := PadR(oTef:aDados[nFor][7][3],4)
			oTef:cCta	:= PadR(oTef:aDados[nFor][7][4],10)
			oTef:cChe  	:= PadR(oTef:aDados[nFor][7][5],6)
			oTef:cC1	:= Space(01)
			oTef:cC2	:= Space(01)
			oTef:cC3	:= Space(01)
		EndIf			
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A primeira chamada do SIT_CONTIN deve enviar os dados sempre zerados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTef:nProxComan 		:= 0							//Armazena o próximo comando a ser executado 	
		oTef:nTipoCampo 		:= 0							//Tipo de campo a ser tratado pela automação no retorno
		oTef:nTamMin			:= 0							//Tamanho mínimo do campo a ser coletado pela automação
		oTef:nTamMax			:= 0							//Tamanho máximo do campo a ser coletado pela automação	
		oTef:cBuffer			:= ""							//Armazena todo o conteúdo a trocado entre automação e SiTEF
		oTef:nTamMaxBuffer		:= 0							//Tamanho do buffer trocado
		oTef:nContNaveg			:= 0							//Indica se continua o processo interativo
		oTef:nRet				:= 0							//Retorno da DLL


		//Se o sitema permite enviar restrições para que a CLISITEF não exiba todas as opções disponíveis, na homologação não poderemos utilizar
		If oTef:aRetCartao[nFor]:cForma == "CC"
			oTEF:cTitle	:= " - " + STR0066 + " " + If(Empty(oTef:aRetCartao[nFor]:cIDCart),"",AllTrim(oTef:aRetCartao[nFor]:cIDCart)) + " - "	+ cSimb1 + " " + AllTrim(cValor)		//Cartão de Crédito
			
			oTef:nCodFuncao := 0

			If oTef:lRestric
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³   C R E D I T O 			              							|
				//³25 Cartão de crédito (todas as combinações)	                      	³
				//³26 Cartão de crédito a vista	                                        ³
				//³27 Cartão de crédito parcelado com financiamento do estabelecimento	|
				//³28 Cartão de crédito parcelado com financiamento da administradora	³
				//³29 Cartão de crédito digitado	                                    ³
				//³30 Cartão de crédito magnético	                                    |
				//³34 Cartão de Crédito Pró-rata a vista	                            ³
				//³35 Cartão de Crédito Pró-rata parcelada	                            |
				//³32 Cartão Fininvest	                                              	³
				//³33 Saque com cartão Fininvest	                                    ³
				//³36 Consulta parcelas no Cartão de Crédito	                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oTEF:lHomolog
					cRestric := ""
				Else
					cRestric := "10;15;19;31;40;32;33"	//Todas transações de Crédito
					If oTef:aDados[nFor][5] > 1		//Parcelado
						//Durante a homologacao as restricoes exigidas sao diferentes
						If oTEF:lHomolog
							cRestric += ";34" 
						Else							
							/*							
							Adicionamos a restrição de "28-Parcelamento por administradora", pois ainda não foi homologado parcelamentos nesse caso,
							já que o juros pode ser retornado após a venda ter sido finalizada e hoje não há tratamento para inserção do mesmo na venda
							Se for remover essa restrição, deve-se alinhar com o líder ou coordenador de manutenção do Varejo
							26 - Cartão de crédito a vista
							28 - Cartão de crédito parcelado com financiamento da administradora
                                                        A Restrição 28 - foi condicionada ao parametro MV_LJRETEF, em virtude do chamado 171546
							36 - Consulta parcelas no Cartão de Crédito

													
							*/
							cRestric += ";26;36"
							
							//Se MV_LJRETEF tiver contéudo adicionamos a restrição 29-Cartão de Crédito digitado
							If !Empty(cMvRestTef)
								cRestric += cMvRestTef
							EndIf
						EndIf
					Else							//A Vista		
						//Durante a homologacao as restricoes exigidas sao diferentes
						If oTEF:lHomolog
							cRestric += ";35;36"
						Else
							cRestric += ";27;28;35;36"
						EndIf
					EndIf
					cRestric := "["+cRestric+"]"						
				EndIf
			EndIf				
		ElseIf oTef:aRetCartao[nFor]:cForma == "CD"
			oTEF:cTitle	:= " - " + STR0082 + " " + If(Empty(oTef:aRetCartao[nFor]:cIDCart),"",AllTrim(oTef:aRetCartao[nFor]:cIDCart)) + " - "	+ cSimb1 + " " + AllTrim(cValor)		//Cartão de Débito

			oTef:nCodFuncao := 0

			If oTef:lRestric
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³D E B I T O	                             ³
				//³15 Cartão de débito (todas as combinações)³
				//³16 Cartão de débito a vista	             ³
				//³17 Cartão de débito pré-datado            ³
				//³18 Cartão de débito parcelado	         ³
				//³19 Cartão de débito CDC	                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oTEF:lHomolog
					cRestric := ""
				Else
					cRestric := "10;25;31;32;33;36;40"  //Todas Transações de Débito
					If oTef:aDados[nFor][5] > 1		//Parcelado
						cRestric += ";16;17"
					Else                            //A Vista
						cRestric += ";18"
					EndIf
					cRestric := "["+cRestric+"]"
				EndIf
			EndIf

		ElseIf oTef:aRetCartao[nFor]:cForma == "CV"
			oTEF:cTitle	:= " - " + STR0210 + " " + If(Empty(oTef:aRetCartao[nFor]:cIDCart),"",AllTrim(oTef:aRetCartao[nFor]:cIDCart)) + " - "	+ cSimb1 + " " + AllTrim(cValor)		//Carteira Virtual

			oTef:nCodFuncao := 122

			If oTef:lRestric
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ C A R T E I R A  V I R T U A L           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oTEF:lHomolog
					cRestric := ""
				Else
					cRestric := "" 
					cRestric := "["+cRestric+"]"
				EndIf
			EndIf

		ElseIf oTef:aRetCartao[nFor]:cForma == "CH"
			oTEF:cTitle	:= " - " + STR0057 + " " + If(Empty(oTef:cChe),"",AllTrim(oTef:cChe))	+ " - "	+ cSimb1 + " " + AllTrim(cValor) 			//Cheque
			If oTef:lRestric
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³C H E Q U E S                                     ³
				//³10 Consulta ou garantia de Cheque (todos os tipos)³
				//³11 Consulta Cheque Serasa/Associação Comercial    ³
				//³12 Consulta Cheque Tecban                         ³
				//³13 Telecheque Garantido Tecban                    ³
				//³14 Garantia Cheque Papel Tecban                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				cRestric :=	"15;19;20;25;31;32;36;40"
				If Substr(cBotoesCons,1,1)<>"S"		//Serasa
					cRestric +=	";11"
				EndIf
				If Substr(cBotoesCons,7,1)<>"S"		//TecBan
					cRestric +=	";12;13;14"			
				EndIf			
				If AT("S", cBotoesCons) == 0		//Nao vai fazer nenhuma consulta de cheque
					cRestric +=	";10"
				EndIf


				cRestric := "["+cRestric+"]"
			EndIf
		EndIf

		//Contador de transacoes
		oTef:nTrans += 1

		//Verifica se a transação em questão foi processada até o final
        oTef:lTefOk				:= .F.

		// soh consulta um cheque.
		If AllTrim(Upper(oTef:aDados[nFor][3])) == "CH" .AND. lPulaCH
        	oTef:lTefOk	:= .T.
		Else
			nTransCH := nFor -1
			oTEF:IniciaTrn( oTef:nCodFuncao , cValor 		, oTef:cCupom	, oTef:cData 	, ;
							oTef:cHora 		, oTef:cOperador, cRestric		, @lTemTefPend	, ;
							@aTefBKP        , @aFormCtrl    , @aPgtos      , @aPgtosSint   , ;
							@oPgtos         , @oPgtosSint   )

			//  soh consulta um cheque.
			If AllTrim(Upper(oTef:aDados[nFor][3])) == "CH" .AND. oTef:lTefOk
				If !lPulaCH
					lPulaCH := .T.
				Endif
			EndIf
		EndIf
		
		//Se estivermos processando MULTI-TEF e uma das transações der problema abortar as próximas
		If oTef:nTrans < oTef:nTotTrans .AND. !oTef:lTefOk
			Exit
		EndIf

	Next nFor
	
EndIf

lCancLJ140 := .F.
aVndCLJ140 := {}
cDocCLJ140 := ""
lPharmSys  := .F.

RestArea(aArea)
RestArea(aAreaL1)
RestArea(aAreaF2)
RestArea(aAreaL4)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³IniciaTrn ºAutora ³Solange Zanardi     º Data ³  10/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicia qualquer tipo de operação a ser efetuada pelo TEF   º±±
±±º          ³ exceto operaçoes específicas, como correspond. bancarios   º±±
±±º          ³                                                            º±±
±±ºSintaxe   ³ ExpN1 - Codigo correspondente a operacao na clisitef32     º±±
±±º          ³ ExpN2 - Valor da transacao TEF      						  º±±
±±º          ³ ExpC1 - Numero do cupom Fiscal       					  º±±
±±º          ³ ExpD1 - Data da transacao TEF                 		      º±±
±±º          ³ ExpC2 - Hora da transacao TEF                 		      º±±
±±º          ³ Expc3 - Operador do caixa que eh nutilizado pela CLISITEF  º±±
±±º          ³ Expc4 - Restricoes para as operacoes da CLISITEF           º±±
±±º          ³ ExpL1 - Indica se tem tef pendente                 		  º±±
±±º          ³ ExpA1 - Guarda a ultima transacao, caso de problemas na    º±±
±±º          ³         proxima transacao TEF.                 		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
METHOD IniciaTrn( 	nFuncao , nValor 	, cCupom 	, dData 	 , ;
					cHora 	, cOperador , cRestric 	,lTemTefPend , ;
					aTefBKP , aFormCtrl , aPgtos    , aPgtosSint, ;
					oPgtos  , oPgtosSint ) CLASS MSTEF
Local nRet												//Controla o retorno da funcao executada na DLL
Local aRetIni 	:= {}									//Mensagens obigatorias em caso de erros	
Local nPos												//Controle de posicionamento da array	
Local xRet
Local lMvLjPdvPa    := LjxBGetPaf()[2] //Indica se eh pdv PAF
Local aTotvsTEF		:= {.T.,""}

DEFAULT aFormCtrl  := {}
DEFAULT aPgtos      := {}
DEFAULT aPgtosSint  := {}

//Checa no License Server se o cliente tem a licença do TOTVS TEF
If ExistFunc("LjGetLTT")
	If lMvLjPdvPa
		//Quando for PDV PAF, executa a função na retaguarda
		aTotvsTEF := FR271CMyCall( "LjGetLTT")
	Else
		aTotvsTEF := LjGetLTT()
	EndIf
EndIf

If ValType(aTotvsTEF[1]) == "L" .And. !aTotvsTEF[1]
	MsgStop(aTotvsTEF[2],"Totvs TEF")
Else
	If FindFunction ("P_LJTEFTRAD")
	   xRet  := P_LJTEFTRAD(cRestric)   
	   If ValType(xRet) == "C"
	      cRestric  := xRet
	   EndIf
	EndIf
	
	oGlobal:GravarArq():Log():Tef():Gravar("IniciaFuncaoSiTefInterativo(Funcao: " + AllTrim(Str(nFuncao)) + ", Valor: " + nValor + ", Cupom: " + cCupom + ", Data: " + dData + ", Horario: " + cHora + ", Operador: " + cOperador + ", Restricao: " + cRestric + ")")
	nRet := oAutocom:SIT_INICIA( nFuncao , nValor , cCupom , dData , cHora , cOperador , cRestric )
	oGlobal:GravarArq():Log():Tef():Gravar("Retorno: " + AllTrim(Str(nRet)))
	
	aRetIni := LjTEFMensa("I")
	
	If nRet == 10000  
	    If oTef:nCodFuncao <> 110 .AND. oTef:nCodFuncao <> 540
	   		LJTEFConfRW( GetClientDir() + "CLISITEF."+StrZero(oTEF:nIDTermina,3), .T., oTEF:cCupom, oTEF:cData,;
		    oTEF:cHora )
		EndIf    
		//Aciona a Tela de Operações TEF
		LjTEFTela( @lTemTefPend, @aTefBKP, @aFormCtrl , @aPgtos , ;
				   @aPgtosSint , @oPgtos , @oPgtosSint )			   
	Else
	   If nRet > 0
			MsgStop(STR0024,STR0006) //"negada pelo autorizador"
	   ElseIf nRet <= -7
			MsgStop(STR0025,STR0006) //"Erros detectados internamente pela rotina"
	   Else
			nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
			If nPos > 0
				MsgStop(aRetIni[nPos][2],STR0006)		
			EndIf
	   EndIf
	EndIf
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³CorrespTrnºAutora ³Solange Zanardi     º Data ³  10/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para início do processo de Correspondentes Bancarios º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
METHOD CorrespTrn( cCupom , dData , cHora , cOperador , cRestric ) CLASS MSTEF
Local nRet												//Controla o retorno da funcao executada na DLL
Local aRetIni := {}										//Mensagens obigatorias em caso de erros	
Local nPos												//Controle de posicionamento da array	

oGlobal:GravarArq():Log():Tef():Gravar("CorrespondenteBancarioSiTefInterativo(Cupom: " + cCupom + ", Data: " + dData + ", Horario: " + cHora + ", Operador: " + cOperador + ", Restricao: " + cRestric + ")")

nRet := oAutocom:SIT_CORRESP( cCupom , dData , cHora , cOperador , cRestric )

oGlobal:GravarArq():Log():Tef():Gravar("Retorno: " + AllTrim(Str(nRet)))

aRetIni := LjTEFMensa("I")

If nRet == 10000
	//Aciona a Tela de Operações TEF
	LjTEFTela()
Else
   If nRet > 0
	  MsgStop(STR0024)
   ElseIf nRet <= -6
	  MsgStop(STR0025)
   Else
	  MsgStop(aRetIni[nPos][2])
   EndIf
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGravaCB    ºAutor  ³Microsiga           º Data ³  08/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a funcao de wbservices para a gravacao dos dados de     º±±
±±º          ³ correspondete bancario.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LjGravaCB() CLASS MSTEF 
Local oSrc														// Objeto do Webservice
Local cPref			:= LjGetStation("SERIE")					// Prefixo
Local cNumCupFis	:= ""										// Numero do cupom fiscal
Local cParcela		:= LjParcela(1, SuperGetMV("MV_1DUP"))		// Parcela
Local cNatureza		:= ""										// Natureza da operacao
Local cCliente		:= SuperGetMV("MV_CLIPAD",, "")				// Cliente padrao
Local cLoja			:= SuperGetMV("MV_LOJAPAD",, "")			// Loja
Local dEmiss		:= dDataBase								// Data de emissao
Local dVencto		:= dDataBase								// Data de vencimento
Local cHist			:= "CORRESPONDENTE BANCARIO"				// Historico da operacao  
Local nMoeda		:= 1										// Tipo da moeda
Local cPrw			:= "LOJXTEF"								// Programa que gerou o lancamento
Local nValTit		:= (oTef:aRetCorresp[1]:nVlrPgto)		 	// Valor da transacao     
Local cPortado		:= xNumCaixa()								// Caixa que realizou a opercao
Local oDlgVA													// Objeto da tela
Local oDlgChq													// Objeto da tela
Local nVezes 		:= 0										// Parametro da Tela
Local cTipo			:= ""					   					// Sigla da forma de pagamento
Local nCont			:= 0										// Parametro da Tela
Local lBotaoOK		:= .F.										// Variavel de retorno
Local lCancela		:= .F.										// Variavel de cancelamento
Local cBanco 		:= Space(TamSX3("EF_BANCO")[1])		   	// Banco do cliente
Local cAgencia		:= Space(TamSX3("EF_AGENCIA")[1])			// Agencia
Local cConta		:= Space(TamSX3("EF_CONTA")[1])			// Conta
Local cNumChq		:= Space(TamSX3("EF_NUM")[1])				// Numero do Cheque
Local cCompensa		:= Space(TamSX3("EF_COMP")[1])				// Compensação
Local cRg			:= Space(TamSX3("EF_RG")[1]	)    			// Rg do cliente
Local cTel			:= Space(TamSX3("EF_TEL")[1])             	// Telefone
Local lTerceiro		:= .F.										// Indica se o cheque e de terceiro
Local lRet			:= .F.                                      // Controla o retorno da funcao
Local cLabelDoc     := ""                                       // Contem a string de Label quando o pagamento for com cheque
Local cNsuSitef     := oTef:aRetCorresp[oTef:nTrans]:cNsuPg    // Numero de NSU-Sitef de pagamento
Local cNumMov		:= AllTrim(LJNumMov())						//Numero do movimento de fechamento de caixa
Local lEmitNFCe 	:= FindFunction("LjEmitNFCe") .AND. LjEmitNFCe() 	//Se utiliza Nfc-e na estacao
	
	
//Retirado o bloco que capturava a Forma de Pagto utilizada via Hard Code e apontado para a informação do próprio objeto.
cTipo := AllTrim(oTef:aRetCorresp[Len(oTef:aRetCartao)]:cForma)

If oTef:nTransCB > 1
	nValTit := oTef:GetCBVlrPgt()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega a descirção da forma de pagamento no SX5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX5")
DbSeek(xFilial("SX5") + "24")
//Procura a forma na tabela 24
While !Eof() .AND. SX5->X5_FILIAL == xFilial("SX5") .AND. SX5->X5_TABELA == "24"
    //Verifica se encontrou a forma
	If AllTrim(SX5->X5_CHAVE) == cTipo
		//Guarda a descricao da forma
		cNatureza := Alltrim(SX5->X5_DESCRI)
		Exit
	EndIf	
	DbSkip()
End 
	
If cTipo == "CH"

	If (Empty( cTel ) .OR. Empty( cRg )) 
		
		// Dados do Cliente
		DEFINE MSDIALOG oDlgTel FROM	69,140 TO 243,313 TITLE STR0131 PIXEL
		
		DEFINE FONT oFont NAME "TIMES NEW ROMAN" SIZE 6,16 BOLD
			
		// &Telefone/Rg
		If cPaisLoc == "BRA"		
		   @	5,  6 TO 60, 77 LABEL STR0130 OF oDlgTel	PIXEL
		Else    
		   cLabelDoc  := STR0129+AllTrim(RetTitle("A1_RG"))  //"&Telefone/"	   	
		   @	5,  6 TO 60, 77 LABEL cLabelDoc OF oDlgTel	PIXEL		
		EndIf  
			 		   
		@ 17, 15 MSGET oTelefone VAR cTel SIZE 54, 10 OF oDlgTel PIXEL;
		PICTURE PesqPict("SA1","A1_TEL",15)
		@ 33, 15 MSGET oRg		 VAR cRG  SIZE 54, 10 OF oDlgTel PIXEL;
		PICTURE PesqPict("SA1","A1_RG",15)
			
		@ 50,8 CHECKBOX oCheckTe VAR lTerceiro PROMPT OEMTOANSI(STR0128) SIZE 66,8	OF oDlgtel FONT oFont PIXEL      //"Cheque de Terceiros"
			
		DEFINE SBUTTON FROM 70, 30 TYPE 1 ENABLE OF oDlgTel;
		ACTION (oDlgTel:End()) PIXEL
			
		ACTIVATE MSDIALOG oDlgTel CENTERED
		
	EndIf 
		
	cBanco 		:= oTef:cBco
	cAgencia	:= oTef:cAge
	cConta		:= oTef:cCta
	cNumChq		:= oTef:cChe
	cCompensa	:= oTef:cCom
	//cRg		:= cRg
	//cTel		:= cTel
	//lTerceiro	:= lTerceiro

EndIf

If cTipo == "CD"
	cNatureza := SuperGetMV("MV_NATTEF")
EndIf

If !lEmitNFCe
	IFPegCupom( nHdlECF, @cNumCupFis )	
Else
	If SLG->(FieldPos("LG_SERNFIS")) > 0
		cPref := LjGetStation("SERNFIS")
	EndIf

	If Empty(cPref)
		cPref := "CBG"
	EndIf

	cNumCupFis := GetNumSE1(cPref)	
EndIf

If nModulo == 12 //Venda Assistida
	LJMsgRun(STR0124,, { |oDlg| lRet := LjTefGrvCB(	    cPref		, cNumCupFis, cParcela	, cTipo		, ;		// Gravando Movimento
														cNatureza	, cCliente	, cLoja		, dEmiss	, ;
														dVencto		, cHist		, nMoeda	, cPrw		, ;
														nValTit		, cPortado	, cBanco 	, cAgencia	, ;
														cConta 		, cNumChq	, cCompensa , cRg 		, ;
														cTel		, lTerceiro , cNsuSitef) } )
Else
	oSrc		:= WSLJFINACB():New()
	oSrc:_URL 	:= "http://"+Alltrim(LJGetStation("WSSRV"))+"/LJFINACB.apw"
	
	LJMsgRun(STR0124,, { |oDlg| lRet := oSrc:IncluiTit(	cPref		, cNumCupFis, cParcela	, cTipo		, ;		// Gravando Movimento
															cNatureza	, cCliente	, cLoja		, dEmiss	, ;
															dVencto		, cHist		, nMoeda	, cPrw		, ;
															nValTit		, cPortado	, cBanco 	, cAgencia	, ;
															cConta 		, cNumChq	, cCompensa , cRg 		, ;
															cTel		, lTerceiro , cNsuSitef	, Nil		, ;
															Nil			, Nil	  	, cNumMov) } )

	//Gera Movimentação de Corresp. Bancario no PDV
	If lRet
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial("SA6")+xNumCaixa()+"."))
		If SE5->(Reclock("SE5",.T.))
			REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
			REPLACE SE5->E5_DATA	WITH dDataBase
			REPLACE SE5->E5_BANCO	WITH xNumCaixa()
			REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
			REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
			REPLACE SE5->E5_HISTOR	WITH cHist
			REPLACE SE5->E5_TIPO	WITH "VL"
			REPLACE SE5->E5_MOEDA	WITH StrZero(nMoeda,TAMSX3("E5_MOEDA")[1])
			REPLACE SE5->E5_VALOR	WITH nValTit
			REPLACE SE5->E5_DTDIGIT	WITH dDataBase
			REPLACE SE5->E5_DTDISPO	WITH SE5->E5_DATA
			REPLACE SE5->E5_NATUREZ	WITH cNatureza
			REPLACE SE5->E5_SITUA	WITH "TX" //Não é necessário subir para a retaguarda pois ja foi gerada anteriormente pelo WS
			If SE5->(FieldPos("E5_ORIGEM")) > 0
				REPLACE SE5->E5_ORIGEM	WITH cPrw
			EndIf
			If SE5->(FieldPos("E5_NUMMOV")) > 0
				Replace SE5->E5_NUMMOV	WITH cNumMov
			EndIf
			SE5->(MsUnLock())
		EndIf
	EndIf
EndIf	
If !lRet
   	Alert( STR0125)	// "Não foi possível gravar as infomações de correspondente bancario." 
EndIf
Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjEstornoCB  ºAutor  ³Microsiga           º Data ³  12/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a funcao de wbservices para estorno dos dados de        º±±
±±º          ³ correspondete bancario no SE1 e SE5.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LjEstornoCB() CLASS MSTEF 
Local oSrc													   		// Objeto do Webservice  
Local cNumCupFis	:= ""									   		// Numero do cupom fiscal
Local cNsuSitef     := oTef:aRetCorresp[oTef:nTrans]:cNsuCancCB		// Numero de NSU-Sitef de cancelamento
Local nValorTotal	:= oTef:aRetCorresp[1]:nVlrOrig					// Valor estornado
Local lRet			:= .F.                                         // Controla o retorno
Local cCupom		:= ""
	
oSrc		:= WSLJFINACB():New()
oSrc:_URL 	:= "http://"+Alltrim(LJGetStation("WSSRV"))+"/LJFINACB.apw"

IfPegCupom( nHdlECF, @cCupom)

nRet := IFSupr( nHdlECF, 3, Str(nValorTotal,14,2), '', '' )

cTexto := CHR(13)+CHR(10) + STR0170 + CHR(13)+CHR(10)//#"ESTORNO DE CORRESPONDENTE BANCARIO "
cTexto := STR0171 + Replicate(CHR(13)+CHR(10),2) //#"Via do Cliente"
cTexto += "NSU SITEF " + STR0172 + cNsuSitef +  CHR(13)+CHR(10)//#"ESTORNADO: "
cTexto += STR0173 + Transform(nValorTotal, PesqPict("SE5", "E5_VALOR", 13)) + CHR(13)+CHR(10) //#"VALOR DA OPERACAO: R$ "
cTexto += STR0174 + DToC(dDataBase) + "  " + Time() + CHR(13)+CHR(10) //#"DATA DE EMISSAO: "
nRet := IFRelGer( nHdlECF, cTexto, 1 )

If nRet == 0 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Verifica se ha gaveta configurada na porta COM³
    //³Caso nao tenha envia o comando pelo ECF       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	If !lGaveta
		nRet := IFGaveta( nHdlECF )
	Endif
EndIf

LJMsgRun(STR0124,, { |oDlg| lRet := oSrc:EstornaTit(cNsuSitef) } )     //"Gravando Movimento"	

If !lRet
	Alert( STR0125 )	// "Não foi possível gravar as infomações de correspondente bancario."
Else

	FRT050Grv(xNumCaixa() ,1 ,"P" , {SuperGetMV("MV_SIMB1"), nValorTotal}, {}, .F. ,cCupom)
	If Reclock("SE5",.F.)
		Replace SE5->E5_NUMMOV	WITH AllTrim(LJNumMov())		
		SE5->(MsUnLock())
	EndIf

EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³VidaLinkCOºAutor  ³Cesar Valadao       º Data ³  08/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD VidaLinkCO( cCodigoAutorizacao, cCodigoProduto, cCupomFiscal, cDataFiscal, cHorario, cOperador ) CLASS MSTEF
Local nRet												//Controla o retorno da funcao executada na DLL
Local aRetIni := {}										//Mensagens obrigatorias em caso de erros	
Local nPos												//Controle de posicionamento da array	

nRet := oAutocom:SIT_VDLCON( cCodigoAutorizacao, cCodigoProduto, cCupomFiscal, cDataFiscal, cHorario, cOperador )

aRetIni := LjTEFMensa("V")

If nRet == 10000
	//Aciona a Tela de Operações TEF
	LjTEFTela()
Else
	nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
	MsgStop(aRetIni[nPos][2])
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³VidaLinkPRºAutor  ³Cesar Valadao       º Data ³  08/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD VidaLinkPR( nIndiceProduto, cCodigoProduto, nQuantidade, cValorVenda ) CLASS MSTEF
Local nRet												//Controla o retorno da funcao executada na DLL

nRet := oAutocom:SIT_VDLPRO( nIndiceProduto, cCodigoProduto, nQuantidade, cValorVenda )
// O retorno deve ser 0

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³VidaLinkVDºAutor  ³Cesar Valadao       º Data ³  08/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD VidaLinkVD( cCodigoAutorizacao, nNumeroProdutos, cCupomFiscal, cDataFiscal, cHorario, cOperador ) CLASS MSTEF
Local nRet												//Controla o retorno da funcao executada na DLL
Local aRetIni := {}										//Mensagens obrigatorias em caso de erros	
Local nPos												//Controle de posicionamento da array	

nRet := oAutocom:SIT_VDLVEN(cCodigoAutorizacao, nNumeroProdutos, cCupomFiscal, cDataFiscal, cHorario, cOperador)

aRetIni := LjTEFMensa("V")

If nRet == 10000
	//Aciona a Tela de Operações TEF
	LjTEFTela()
Else
	nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
	MsgStop(aRetIni[nPos][2])
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³VidaLinkCAºAutor  ³Cesar Valadao       º Data ³  08/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD VidaLinkCA( nParcialTotal, cCupomFiscal, cDataFiscal, cHorario, cOperador ) CLASS MSTEF
Local nRet := 0		//Controla o retorno da funcao executada na DLL

nRet := oAutocom:SIT_VDLCAN(nParcialTotal, cCupomFiscal, cDataFiscal, cHorario, cOperador)

aRetIni := LjTEFMensa("V")

If nRet == 10000
	//Aciona a Tela de Operações TEF
	LjTEFTela()
Else
	nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
	MsgStop(aRetIni[nPos][2])
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PharmSysCOºAutor  ³Sustentacao       º Data ³  04/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

METHOD PharmSysCO( 	nFuncao	, nValor	, cCupom	, dData	,;
					cHora	, cOperador	, cRestric 	) CLASS MSTEF

Local nRet		:= 0	//Controla o retorno da funcao executada na DLL
Local aRetIni	:= {}	//Mensagens obrigatorias em caso de erros	
Local nPos				//Controle de posicionamento da array	

nRet := oAutocom:SIT_INICIA(nFuncao	, nValor	, cCupom	, dData	,;
							cHora	, cOperador	, cRestric  )

oGlobal:GravarArq():Log():Tef():Gravar(	"IniciaFuncaoSiTefInterativo(Funcao: " + AllTrim(Str(nFuncao)) + ;
										", Valor: " +  AllTrim(nValor) + ", Cupom: " + cCupom + ;
										", Data: " + dData + ", Horario: " + cHora + ", Operador: " + cOperador + ;
										", Restricao: " + cRestric + " Retorno Buffer:" + oAutocom:cBuffer  + ")")

aRetIni := LjTEFMensa("V")

If nRet == 10000
	//Aciona a Tela de Operações TEF
	LjTEFTela()
Else
	nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
	MsgStop(aRetIni[nPos][2])
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³FuncardCOºAutor  ³Sustentacao          º Data ³  04/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD FuncardCO( 	nFuncao	, nValor	, cCupom	, dData	,;
					cHora	, cOperador	, cRestric ) CLASS MSTEF

Local nRet		:= 0				//Controla o retorno da funcao executada na DLL
Local aRetIni 	:= {}				//Mensagens obrigatorias em caso de erros	
Local nPos		:= 0				//Controle de posicionamento da array	

nRet := oAutocom:SIT_INICIA(nFuncao	, nValor	, cCupom	, dData	,;
							cHora	, cOperador	, cRestric  )

oGlobal:GravarArq():Log():Tef():Gravar( "IniciaFuncaoSiTefInterativo(Funcao: " + AllTrim(Str(nFuncao)) +;
										", Valor: " +  AllTrim(nValor) + ", Cupom: " + cCupom + ", Data: " + dData +;
										", Horario: " + cHora + ", Operador: " + cOperador + ", Restricao: " + cRestric +;
										" Retorno Buffer:" + oAutocom:cBuffer  + ")")

aRetIni := LjTEFMensa("V")

If nRet == 10000
	//Aciona a Tela de Operações TEF
	LjTEFTela()
Else
	nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
	MsgStop(aRetIni[nPos][2])
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PharmSysCAºAutor  ³Sustentacao       º Data ³  04/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD PharmSysCA(  nFuncao	, nValor	, cCupom	, dData	,;
					cHora	, cOperador	, cRestric ) CLASS MSTEF
					
Local nRet 		:= 0	//Controla o retorno da funcao executada na DLL
Local aRetIni 	:= {}	//Mensagens obrigatorias em caso de erros	
Local nPos		:= 0	//Controle de posicionamento da array                   

nRet := oAutocom:SIT_INICIA(nFuncao	, nValor	, cCupom	, dData	,;
							cHora	, cOperador	, cRestric  )

oGlobal:GravarArq():Log():Tef():Gravar(	"IniciaFuncaoSiTefInterativo(Funcao: " + AllTrim(Str(nFuncao)) + ;
										", Valor: " +  AllTrim(nValor) + ", Cupom: " + cCupom + ", Data: " + dData + ;
										", Horario: " + cHora + ", Operador: " + cOperador + ", Restricao: " + cRestric + ;
										" Retorno Buffer:" + oAutocom:cBuffer  + ")")

aRetIni := LjTEFMensa("V")

If nRet == 10000
	//Aciona a Tela de Operações TEF
	LjTEFTela()
Else
	nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
	MsgStop(aRetIni[nPos][2])
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFTela ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a abertura da tela de interacao cupom TEF            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFTela( ExpL1, ExpA1 )				  		  		  º±±
±±º          ³ ExpL1 - Indica se tem tef pendente                 		  º±±
±±º          ³ ExpA1 - Guarda a ultima transacao, caso de problemas na    º±±
±±º          ³         proxima transacao TEF.                 		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFTela( lTemTefPend, aTefBKP, aFormCtrl, aPgtos , ;
					aPgtosSint , oPgtos , oPgtosSint )

Local cInf			:= ""                       			//Variavel para inicializacao do objeto de informacao 
Local cSay			:= ""									//Variavel para inicializacao do objeto da lista de opcoes
Local cListBox		:= ""									//Variavel para inicializacao do objeto ref. a mensagem de consulta CDC
Local cMens			:= STR0036								//Sitef Conectado

Local lUsaDisplay	:= !Empty(LjGetStation("DISPLAY"))		// Verifica se a estacao possui Display

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos de tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oDlgTEF                   
Private oLogoTEF
Private oFontMens
Private oFontPad
Private oFontList
Private oFontText
Private oGet
Private oGetV
Private oSay
Private oImg
Private oMens
Private oBtnC
Private oBtnV
Private oBtnE
Private oList
Private oPanChq
Private oTimer1
Private oTimer2

DEFAULT lTemTefPend := .F.
DEFAULT aTefBKP     := {}
DEFAULT aFormCtrl   := {}
DEFAULT aPgtos      := {}
DEFAULT aPgtosSint  := {}

LJTeclas( .F., .F., .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Operações Tef 							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgTEF TITLE STR0001 FROM 000,000 TO 453,637 PIXEL OF GetWndDefault() COLOR CLR_BLUE,CLR_WHITE  ;
STYLE DS_MODALFRAME STATUS //T.E.F. - Transferência Eletrônica de Fundos

DEFINE FONT oFontMens	NAME "Arial" 		SIZE 10,25 BOLD			//Mensagem do SITEF
DEFINE FONT oFontPad	NAME "Arial" 		SIZE 07,17 BOLD			//Get a ser digitado pelo operador
DEFINE FONT oFontList	NAME "Arial"	 	SIZE 09,20 BOLD			//ListBox para a exibicao da Consulta CDC
DEFINE FONT oFontText	NAME "Courier New" 	SIZE 09,20 BOLD 		//Conteudo do cupom de consulta CDC

//Desabilita o esc da tela
oDlgTEF:lEscClose := .F.	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MENSAGEM SITEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 001,001 SAY If(Empty(oTef:cTitle),STR0006,STR0006+oTef:cTitle) FONT oFontPad  COLOR CLR_GRAY 	SIZE 250,10  OF oDlgTEF PIXEL	//Mensagem Sitef
//ÚÄÄÄ¿
//³BOX³
//ÀÄÄÄÙ
@ 010,002 TO 055,318 PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MENSAGENS ENVIADAS PELA CLISITEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 028,005 SAY oMens VAR cMens FONT oFontMens COLOR CLR_GREEN 	SIZE 300,40  OF oDlgTEF PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³LOGOTIPO DO TEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 006,274 REPOSITORY oLogoTEF SIZE 82,90 PIXEL NO BORDER OF oDlgTEF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ShowBitMap(oLogoTEF,"TEF")³
//³SOLICITACAO SITEF         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 057,001 SAY STR0045 FONT oFontPad  COLOR CLR_GRAY 	SIZE 250,10  OF oDlgTEF PIXEL 	//Solicitação Sitef
//ÚÄÄÄ¿
//³BOX³
//ÀÄÄÄÙ
@ 065,002 TO 208,318 PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ENTRADA DE DADOS SOLICITADAS PELA CLISITEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 075,005 MSGET oGet 	VAR oTef:cGet		   							SIZE 070,10  OF oDlgTEF PIXEL
@ 075,005 MSGET oGetV 	VAR oTef:vGet	PICTURE	"@E 999,999.99" 		SIZE 070,10  OF oDlgTEF PIXEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³LISTA DE OPCOES ENVIADA PELA CLISITEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 090,005 SAY oSay 		VAR cSay		FONT oFontList 					SIZE 220,180 OF oDlgTEF PIXEL
//ÚÄÄÄÄÄÄ¿
//³BOTOES³
//ÀÄÄÄÄÄÄÙ
@ 210,194 BUTTON oBtnC PROMPT STR0037 	SIZE 40,15 OF oDlgTEF PIXEL ACTION (LjTEFProc("C")) //"&Continuar"
@ 210,236 BUTTON oBtnV PROMPT STR0038 	SIZE 40,15 OF oDlgTEF PIXEL ACTION (LjTEFProc("V")) //"&Voltar" 
@ 210,278 BUTTON oBtnE PROMPT STR0039 	SIZE 40,15 OF oDlgTEF PIXEL ACTION (LjTEFProc("E")) //"&Encerrar"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³LISTBOX PARA EXIBICAO DE MENSAGENS E DA CONSULTA CDC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 088,020 LISTBOX oList VAR cListBox 	SIZE 280,100 PIXEL OF oDlgTEF
oList:SetFont(oFontList)
oList:aItems:={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PAINEL PARA DIGITACAO DOS DADOS DO CHEQUE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanChq  := TPanel()		:New(070,005,"",oDlgTEF,oFontPad,.F.,.F.,NIL,NIL,310,135,.T.,.F.) //"Dados do Cheque"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMAGEM DO CHEQUE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 001,001 REPOSITORY oImg SIZE 137,90 PIXEL NOBORDER OF oPanChq
//ShowBitMap(oImg,"CHEQUE")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CONTROLA A HABILITACAO DOS OBJETOS EM TELA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LjTEFObj(.F.,"T")

If lUsaDisplay
	oBtnV:bGotFocus := {|| Iif(!IsInCallStack("LjTEFObj"), LjTEFDisp(STR0186, , , , ,  "V"), .F. )}	// ### Botao Voltar selecionado
	oBtnE:bGotFocus := {|| Iif(!IsInCallStack("LjTEFObj"), LjTEFDisp(STR0182, , , , ,  "E"), .F. )}	// ### Botao Encerrar selecionado
	
	oBtnE:bLostFocus := {|| Iif(	!IsInCallStack("LjTEFObj") .AND. !IsInCallStack("LjTEFDigi") .AND. ;
										!IsInCallStack("LjTEFSele") .AND. ;
										((oGet:lVisible .AND. oGet:lActive) .OR. (oGetV:lVisible .AND. oGetV:lActive)) ;
										,	Iif(	Empty(oSay:cCaption), ;
													LjTEFDisp(oMens:cCaption, , Iif(oGet:lVisible, oGet:cText, oGetV:cText)),	;	// Digitacao de dados
													LjTEFDisp(oMens:cCaption, oTef:cBuffer, )), .F.)}								// Selecao de opcoes
		
	// Permitir apresentacao da digicao dos dados no display											
	oGet:bGotFocus	:= {|| LjAtivDigD(.T.)}
	oGetV:bGotFocus	:= {|| LjAtivDigD(.T.)}
	
	// Bloquear apresentacao da digicao dos dados no display
	oGet:bLostFocus	:= {|| LjAtivDigD(.F.)}
	oGetV:bLostFocus	:= {|| LjAtivDigD(.F.)}

Endif

oTimer1 := TTimer():New(oTEF:nTimeOutC23*1000, {|| LjTEFProc("C")  }, oDlgTEF )
oTimer2 := TTimer():New(100, {|| LjTEFMAtu()  }, oDlgTEF )
ACTIVATE MSDIALOG oDlgTEF CENTERED ON INIT oTEF:ContinTrn() VALID(LjTEFSai(@lTemTefPend, @aTefBKP, @aFormCtrl , @aPgtos ,;
 																			@aPgtosSint, @oPgtos , @oPgtosSint))

LJTeclas( .T., .T., .T., .T. )

If lUsaDisplay
	// Deixar ativado a apresentacao da digitacao no display
	LjAtivDigD(.T.)
Endif

Return(NIL)

/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMétodo    ³LeCodBar  ºAutora ³Vendas Clientes     º Data ³  25/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Le o codigo de barras do boleto a ser pago utilizando CMC7 º±±
±±º          ³ em todas as transações TEF                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD LeCodBar(cCMC7) CLASS MSTEF     
Local nRet     := 1
Local cBufCMC7 := ""

cBufCMC7 := Space(500)
	             
	While nRet == 1       
	
		MsgRun( OemToAnsi( STR0126 ),,;     	// "Passe o documento e aguarde a leitura..."
 		{|| Sleep( 2000 ), nRet := CMC7LeD( nHdlCMC7, @cBufCMC7 ) } )
		
		If ( nRet == 1 ) .OR. Empty( cBufCMC7 )
 			If MsgYesNo( STR0127 )              // "Erro ao tentar ler o documento. Tentar ler novamente?"                
				cBufCMC7 := ""
	            cBufCMC7 := Space(1000)
				::lLeCodBar := .T.	            
			Else
				nRet := 0   
				::lLeCodBar := .F.
			EndIf
		Else
 	     	cCMC7:= ""
		    cCMC7:= cBufCMC7	
			nRet := 0 
			::lLeCodBar := .T.
        EndIf
		      
	End

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜAÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMétodo    ³ContinTrn ºAutora ³Vendas Clientes     º Data ³  10/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Continua o processo de operação TEF, utilizado praticamenteº±±
±±º          ³ em todas as transações TEF                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD ContinTrn() CLASS MSTEF
Local aRetCont			:= {}					//Mensagens obrigatórias a exibir na ocorrencia de erros na funcao
Local cConteudo			:= ""           		//Armazena o conteúdo digitado pelo operador na solicitacao da DLL
Local lInterage			:= .F.					//Verifica os pontos de saida do laço para que o operador interaja
Local lAborta			:= .F.					//Indica problemas na rotina de continuacao
Local cMsgDesfaz		:= ""					//Mensagem exibida no desfazimento das transacoes
Local cUserIDOld		:= __cUserID			// Variavel com o acesso do usuario logado no sistema
Local cBkReadVar		:= ""					// Backup da variavel __ReadVar
Local lLjFimTEF 		:= ExistBlock("LJFIMTEF")
local lRet		 		:= .T.

//Armazena as Mensagens para exibicao em tela   
aRetCont:= LjTEFMensa("I")

//Trocar a mensagem da Tela

//Desabilitar os objetos da Tela
LjTEFObj(.F.,"T")

//Executar a funcao Continua enquanto nRet == 10000
While .T.
	
	//Controla saida do laco para que o operador selecione a opcao desejada
	lInterage := .F.

	//Se estivermos processando MULTI-TEF e uma das transações der problema efetuar a finalização das anteriores evitando pendencias no Sitef
	//So cancela se nao for utilizado tef manual
	If oTef:nContNaveg == -1
		If oTef:nTotTrans > 1 .AND. !oTef:lTefOk .AND. !SuperGetMV("MV_TEFMANU", ,.F.) .AND. Len(oTef:aRetCartao) > 1
			If SuperGetMV("MV_TEFPEND",,"0") == "0"
				LjGrvLog( "", "MV_TEFPEND", SuperGetMV("MV_TEFPEND",,"0") ) 
				//Finaliza a TRN com parametro confirma = 0
				oTEF:FinalTrn(0)
				//Indica que todas as transacoes foram canceladas
				lCanFull := .T.
	
				cMsgDesfaz := STR0089 //"Todas as transações pendentes foram canceladas!"
	
				//Verifica se existe recarga na venda
				If FrtRecVend( oTEF:aRetRecarga )
					FrtCanItRe(.T.)
					cMsgDesfaz += CHR(13) + STR0155 //"Por favor, cancelar o item de recarga de celular porque a transação foi desfeita."
				EndIf
	
				MsgStop(cMsgDesfaz, STR0005)//"Atenção"
			EndIf
		EndIf
	EndIf
		    
	oGlobal:GravarArq():Log():Tef():Gravar("ContinuaFuncaoSiTefInterativo -> Envio(ProximoComando: " + Alltrim(Str(oTef:nProxComan)) + ", TipoCampo: " + Alltrim(Str(oTef:nTipoCampo)) + ", TamanhoMin: " + Alltrim(Str(oTef:nTamMin)) + ", TamanhoMax: " + Alltrim(Str(oTef:nTamMax)) + ", Buffer: " + oTef:cBuffer + ", TamMaxBuffer: " + Alltrim(Str(oTef:nTamMaxBuffer)) + ", Continua: " + Alltrim(Str(oTef:nContNaveg)) + ")")
	//Envia comandos para continuacao do processo
	oTef:nRet := oAutocom:SIT_CONTIN(	oTef:nProxComan	, oTef:nTipoCampo	, oTef:nTamMin, oTef:nTamMax, ;
										oTef:cBuffer	, oTef:nTamMaxBuffer, oTef:nContNaveg)
	
	//Efetua o tratamento do buffer
	LjTEFLeBuf(oAutocom:cBuffer)

	oGlobal:GravarArq():Log():Tef():Gravar("ContinuaFuncaoSiTefInterativo -> Retorno:" + Alltrim(Str(oTef:nRet)) + " (ProximoComando: " + Alltrim(Str(oTef:nProxComan)) + ", TipoCampo: " + Alltrim(Str(oTef:nTipoCampo)) + ", TamanhoMin: " + Alltrim(Str(oTef:nTamMin)) + ", TamanhoMax: " + Alltrim(Str(oTef:nTamMax)) + ", Buffer: " + oTef:cBuffer + ", TamMaxBuffer: " + Alltrim(Str(oTef:nTamMaxBuffer)) + ", Continua: " + Alltrim(Str(oTef:nContNaveg)) + ")")

	If oTef:nRet == 10000
	
		If !(oTef:nProxComan == 23) .AND. !Empty(::cMens23)
			::nSecFin23	:= 0
			::nSecFinC23 := 0
			oSay:cCaption := ""
			::cMens23   := ""		
		EndIf
		
		//Está devolvendo um valor para, se desejado, ser armazenado pela automação
		If oTef:nProxComan == 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua o tratamento do TipoCampo Devolvido na DLL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjTEFTrata()
			
            // Ponto de entrada de validacao do BIN do cartao
			If lLjFimTEF
				lRet := LjVldBIN(oTef:aRetCartao[oTef:nTrans]:CPOSCART, oTef:aRetCartao[oTef:nTrans]:NVLRTRANS)
				// Se o BIN for invalido nao continua com navegacao
				If !lRet                                    
					// Se o retorno do BIN for invalido, encerra a navegacao
					oTef:nContNaveg := -1
				Endif
			Endif	
			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
			
		//Mensagem para o visor do Operador
		ElseIf oTef:nProxComan == 1  						
			oTEF:cMsnOpe		:= AllTrim(oTef:cBuffer)
			oMens:cCaption 		:= oTEF:cMsnOpe
			LjTEFDisp(oMens:cCaption)

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Mensagem para do Cliente
		ElseIf oTef:nProxComan == 2
			oTEF:cMsnCli		:= AllTrim(oTef:cBuffer)
			oMens:cCaption 		:= oTEF:cMsnCli
			LjTEFDisp(oMens:cCaption)

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Mensagem para os dois visores
		ElseIf oTef:nProxComan == 3 							
			oTEF:cMsnAmbos		:= AllTrim(oTef:cBuffer)
			oMens:cCaption 		:= oTEF:cMsnAmbos
			LjTEFDisp(oMens:cCaption)

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Texto que deverá ser utilizado como cabeçalho na apresentação do menu (Comando 21)
		ElseIf oTef:nProxComan == 4 							
			oMens:cCaption		:= AllTrim(oTef:cBuffer)
			LjTEFDisp(oMens:cCaption)

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Deve remover a mensagem apresentada no visor do operador
		ElseIf oTef:nProxComan == 11    						
			oTEF:cMsnOpe		:= ""

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Deve remover a mensagem apresentada no visor do cliente
		ElseIf oTef:nProxComan == 12    						
			oTEF:cMsnCli		:= ""

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Deve remover mensagem apresentada no visor do operador e do cliente
		ElseIf oTef:nProxComan == 13    						
			oTEF:cMsnAmbos		:= ""

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Deve limpar o texto utilizado como cabeçalho na apresentação do menu
		ElseIf oTef:nProxComan == 14    						
			oMens:cCaption		:= ""
			LjTEFDisp(oMens:cCaption)
			
			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
				
		//Deve obter uma resposta do tipo SIM/NÃO. No retorno o primeiro caráter presente em Buffer deve conter 0 se confirma e 1 se cancela
		ElseIf oTef:nProxComan == 20

			If lPharmSys
				oTef:nTipoCampo		:= -1		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 1   
				oTef:cBuffer  		:= "1"
				Loop
    		Endif

			//Prepara as mensagens ou as perguntas a serem feitas ao operador
			LjTEFPerg()
							
		//Deve apresentar um menu de opções e permitir que o usuário selecione uma delas. Na chamada o parâmetro Buffer contém as opções no formato 1:texto;2:texto;...i:Texto;... A rotina da aplicação deve apresentar as opções da forma que ela desejar (não sendo necessário incluir os índices 1,2, ...) e após a seleção feita pelo usuário, retornar em Buffer o índice i escolhido pelo operador (em ASCII)
		ElseIf oTef:nProxComan == 21
             
			//Numero do Convenio
			If oTEF:nTipoCampo == 4022
				oTef:nProxComan		:= 4022	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     		:= 6
				oTef:cBuffer     		:= "1"  //oTef:aDados[1][2]
				oTef:nTamMaxBuffer	:=18     
				If !Empty(oTef:aDados[1,5])
					lPharmSys			:= .T.
					Loop		
				Endif
			Endif
             
			If lPharmSys
				oTef:nTipoCampo		:= -1		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 2   
				
				//Informado o numero do cartao do convenio
				If oTef:aDados[1,5] == 560	//Funcional card, solicita digitacao do cartao do convenio              
					oTef:cBuffer	:= "2"               				   
				ElseIf !Empty(oTef:aDados[1,3]) 
					oTef:cBuffer	:= "1"               
				//Informado o numero do CPF do cliente
				Else
					oTef:cBuffer  	:= "2"
				Endif

				oTef:nTamMaxBuffer	:=2
				Loop
    		Endif

			lInterage := .T.
			Exit

		//Deve aguardar uma tecla do operador. É utilizada quando se deseja que o operador seja avisado de alguma mensagem apresentada na tela
		ElseIf oTef:nProxComan == 22

			lInterage := .T.
			Exit

		//Este comando indica que a rotina está perguntando para a aplicação se ele deseja interromper o  processo de coleta de dados ou não. Esse código ocorre quando a CliSiTEF está acessando algum periférico e permite que a automação interrompa esse acesso (por exemplo: aguardando a passagem de um cartão pela leitora ou a digitação de senha pelo cliente)
		ElseIf oTef:nProxComan == 23							

			//Limpo o Buffer
 			oTef:cBuffer 		:= ""
			oTef:nTamMaxBuffer	:= 0
			oTef:nContNaveg 	:= 0
			If ::nSecFin23 > 0 .AND. ( Seconds() >= ::nSecFin23  .OR. Abs(::nSecFin23 - Seconds()) > ::nTimeOut23 )
				::nSecFin23	:= 0
				oSay:cCaption := ""
				::cMens23 := ""
				lInterage := .T.
				Exit				
				
			Else
				If ::nSecFin23 == 0
					::nSecFin23		:= Seconds() + 	::nTimeOut23						//Finalização do laço da transacao 23	
				EndIf
				::cMens23 		:= 	STR0202+ " " + Alltrim(Str(Int(::nSecFin23 - Seconds()))) + " " + STR0203		//"Habilitando os botões abaixo em"##"segs"		
				oSay:cCaption := ::cMens23				
			EndIf
			
			LjTEFDisp(oMens:cCaption)	
			
			
		//Deve ser lido um campo cujo tamanho está entre TamMinimo e TamMaximo. O campo lido deve ser devolvido em Buffer
		ElseIf oTef:nProxComan == 30		
			If oTEF:nTipoCampo == 1023
				oTef:nProxComan		:= 1023	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 10
				oTef:cBuffer     	:= oTef:aDados[1,6]
				oTef:nTamMaxBuffer	:= 10
				If !Empty(oTef:aDados[1,5])
					lPharmSys		:= .T.
					Loop		
				Endif
			Endif
		
			If oTEF:nTipoCampo == 1024
				oTef:nProxComan		:= 1024	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 2
				oTef:cBuffer     	:= oTef:aDados[1,7]
				oTef:nTamMaxBuffer	:= 10
				If !Empty(oTef:aDados[1,5])
					lPharmSys		:= .T.
					Loop		
				Endif
			Endif					

			If oTEF:nTipoCampo == 1025

				aAreaSBI		:= GetArea()			
				cStrRet := T_DROVLBPro(Alltrim(oTEF:cGet),.T.)
				RestArea(aAreaSBI)
				If Empty(cStrRet)
					MsgAlert("Codigo de Produto Invalido!!!")
					
					oTef:nProxComan	:= 30	
					oTef:nTipoCampo	:= 1012		
					oTef:nTamMin   	:= 1
					oTef:nTamMax     	:= 30
					//oTef:cBuffer     	:= ""						
					oTef:nTamMaxBuffer	:= 30						
											
					Loop
				Endif				
						
				oTef:nProxComan		:= 1025	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 35
				oTef:cBuffer     	:= Alltrim(Substr(cStrRet,08,35))
				oTef:nTamMaxBuffer	:= 30
				If !Empty(oTef:aDados[1,5])
					lPharmSys		:= .T.
					Loop		
				Endif
			Endif
			
			If oTEF:nTipoCampo == 1026
				// Antes de solicitar a quantidade, verifica existncia do produto
				If oTEF:nTipoCampo == 1026 .AND. oTEF:nCodFuncao == 540
					aAreaSBI		:= GetArea()			
					cStrRet := T_DROVLBPro(Alltrim(oTEF:cGet), .T.)
					RestArea(aAreaSBI)
					If Empty(cStrRet)
						MsgAlert("Codigo de Produto Invalido!!!")
						
						oTef:nProxComan	:= 30	
						oTef:nTipoCampo	:= 1012		
						oTef:nTamMin   	:= 1
						oTef:nTamMax     	:= 30
						//oTef:cBuffer     	:= ""						
						oTef:nTamMaxBuffer	:= 30						
												
						Loop
					Endif				
				Endif
						
				oTef:nProxComan		:= 1026	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 30
				oTef:cBuffer     	:= Alltrim(Substr(cStrRet,76,13))
				oTef:nTamMaxBuffer	:= 30
				If !Empty(oTef:aDados[1,5])
					lPharmSys		:= .T.
					Loop		
				Endif
			Endif									
			
			//No caso do Telecheque, não pode entrar aqui, pois tem mais telas e entrando aqui o processo era interrompido
			//Checado se uso cheque e se o Buffer pede pra que continue para que o processo do PharmSys não seja prejudicado
			If oTEF:nTipoCampo == 502 .And. Empty(AllTrim(oTef:cChe)) .And. !(AllTrim(oTEF:cBuffer) == "Forneca o numero do documento") .AND. ;
				!(AllTrim(oTEF:cBuffer) == "Forneca o numero do CPF")
				oTef:nProxComan		:= 502	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 11
				oTef:nTamMaxBuffer	:= 18
				oTef:cBuffer     	:= oTef:aDados[1,4]						
				lPharmSys			:= .T.
				Loop		
			Endif
					
            //Numero de Autorizacao PBM PharmaSystem
			If oTEF:nTipoCampo == 1030  			
				oTef:nProxComan		:= 1030	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     		:= 9
				oTef:nTamMaxBuffer	:= 18
				oTef:cBuffer     		:= oTef:aDados[1,1]						
				lPharmSys				:= .T.
				Loop		
			Endif			                                       	
			
			//Numero do Convenio
			If oTEF:nTipoCampo == 4022
				oTef:nProxComan		:= 4022	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     	:= 6
				oTef:cBuffer     	:=oTef:aDados[1][2]
				oTef:nTamMaxBuffer	:=18     
				If !Empty(oTef:aDados[1,5])
					lPharmSys			:= .T.
					Loop		
				Endif
			Endif

			If lPharmSys
				//CPF do cliente
				If oTEF:nTipoCampo == 502
					oTef:nProxComan		:= 502	
					oTef:nTipoCampo		:= 0		
					oTef:nTamMin   		:= 1
					oTef:nTamMax     	:= 11  
					oTef:cBuffer     	:= oTef:aDados[1][4]			
					oTef:nTamMaxBuffer	:=29     
					Loop						
				Endif	
	
				//Numero do Cartao	
				If oTEF:nTipoCampo == 512
					oTef:nProxComan		:= 512	
					oTef:nTipoCampo		:= 0		
					oTef:nTamMin   		:= 1
					oTef:nTamMax     	:= 2  
					oTef:cBuffer     	:=oTef:aDados[1][3]			
					oTef:nTamMaxBuffer	:=18     
					Loop						
				Endif
	    	Endif
	    	
			If oTEF:nTipoCampo <> 500 
				lInterage := .T.
				Exit
			Else  // somente sera excluida a interacao de senha do supervisor TEF

				oMens:cCaption		:= ""
				//Limpo o Buffer
	 			oTef:cBuffer 		:= ""
				oTef:nTamMaxBuffer	:= 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Volta o posicionamento da senha para o operador inicial           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cUserIDOld := __cUserID
				cBkReadVar := ReadVar()	// Backup da variavel __ReadVar, pois a qdo. chamada a funcao "FWAuthSuper" o conteudo da variavel __ReadVar eh modificado para "CUSERLOGIN"
                                
				// Se o retorno da funcao for .F. muda o valor da variavel lAborta                                                 
				lRet := LjProFile(17) // Cancelamento TEF                   
				If !lRet
				 lAborta  := .T.
				Else
				 oTef:cbuffer := __cUserId
				Endif

				oTef:nTamMaxBuffer := Len(__cUserID)					

				__cUserID := cUserIDOld
				If !Empty(cBkReadVar)
					__ReadVar := cBkReadVar //Restaura o conteudo da variavel "__Readvar"
				EndIf
				PswOrder( 2 )
				PswSeek( __cUserID )
								
			EndIf
				
		//Deve ser lido o número de um cheque. A coleta pode ser feita via leitura de CMC-7 ou pela digitação da primeira linha do cheque. No retorno deve ser devolvido em Buffer "0:" ou "1:" seguido do número coletado manualmente ou pela leitura do CMC-7, respectivamente. Quando o número for coletado manualmente o formato é o seguinte: Compensação (3), Banco (3), Agencia (4), C1 (1), ContaCorrente (10), C2 (1), Numero do Cheque (6) e C3 (1), nesta ordem. Notar que estes campos são os que estão na parte superior de um cheque e na ordem apresentada. Sugerimos que na coleta seja apresentada uma interface que permita ao operador identificar e digitar adequadamente estas informações de forma que a consulta não seja feita com dados errados, retornando como bom um cheque com problemas
		ElseIf oTef:nProxComan == 31							

			lInterage := .T.
			Exit
				
		//Deve ser lido um campo monetário ou seja, aceita o delimitador de centavos e devolvido no parâmetro Buffer
		ElseIf oTef:nProxComan == 34    						
			If oTEF:nTipoCampo == 4016		
				cStrValBrut          := StrZero(Val(StrTran(Alltrim(Str((Val(Substr(cStrRet,55,10))/100),10,2)), '.', '', 1)),7) 
				oTef:nProxComan		:= 4016	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     		:= 10
				oTef:cBuffer     		:= cStrValBrut   // Valor Bruto, pego da tabela SBI->BI_PRV
				oTef:nTamMaxBuffer	:=18     
				lPharmSys				:= .T.
				Loop				
			Endif
				
			If oTEF:nTipoCampo == 4017
				cStrValBrut          := StrZero(Val(StrTran(Alltrim(Str((Val(Substr(cStrRet,55,10))/100),10,2)), '.', '', 1)),7)			
				oTef:nProxComan		:= 4017	
				oTef:nTipoCampo		:= 0		
				oTef:nTamMin   		:= 1
				oTef:nTamMax     		:= 6
				oTef:cBuffer     		:= cStrValBrut
				oTef:nTamMaxBuffer	:=18     
				lPharmSys				:= .T.
				Loop				
			Endif				

			lInterage := .T.
			Exit

		//Deve ser lido um código em barras ou o mesmo deve ser coletado manualmente. No retorno Buffer deve conter "0:" ou "1:" seguido do código em barras coletado manualmente ou pela leitora, respectivamente. Cabe ao aplicativo decidir se a coleta será manual ou através de uma leitora. Caso seja coleta manual, recomenda-se seguir o procedimento descrito na rotina ValidaCampoCodigoEmBarras de forma a tratar um código em barras da forma mais genérica possível, deixando o aplicativo de automação independente de futuras alterações que possam surgir nos formatos em barras
		ElseIf oTef:nProxComan == 35							

			//Limpo o Buffer
			lInterage := .T.
			Exit
				
		Else

			// MsgStop(STR0026+" "+Str(oTef:nProxComan))				//"Próximo comando não previsto pela CliSiTEF32I

		EndIf
		
	//Transacao Finalizada com sucesso
	ElseIf oTef:nRet == 0
	                                    	
		If oTef:nCodFuncao == 110 //GERENCIAIS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama a funcao de impressao de cupom Tef ³
			//³ somente qdo. modulo diferente de SIGATMK ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (!(nModulo == 13) .OR. !(nModulo == 73))
				If !Empty(oTef:aRetCartao[1]:cDocCanRei) .and. !oTef:lEstVenda
					LJGRVCANCT( .T. )
				EndIf
				If nModulo <> 12 .OR. !LjNfUsaTef(SM0->M0_CGC) //12=SIGALOJA
					oTEF:ImpCupTef()		
					if !IsInCallStack("TEFSiTEfCancela")			
						oTEF:aRetCartao := {}
					EndIf
				Else 
					oTEF:FinalTrn(1, .T. )  //Confirma transações pendentes e limpa o LG_LOG
				EndIf
			Else				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se foi chamado pelo SIGATMK envia comando para finalizar ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oTEF:FinalTrn(1)	//Finaliza a TRN com parametro confirma = 1

			Endif
		EndIf			

		//Indica que a transação foi efetuada com sucesso
		oTEF:lTefOk := .T.
		Exit
	
	//Problemas na função de continuacao
	Else

		nPos := Ascan(aRetCont, {|x| x[1] == oTef:nRet } )
		If nPos > 0
			LjTEFDisp(aRetCont[nPos][2], , , , .T.)
		    MsgStop(aRetCont[nPos][2])
		Else
			LjTEFDisp(STR0025, , , , .T.)
			MsgStop(STR0025,STR0006) //"Erros detectados internamente pela rotina"
		EndIf
		
		oTEF:lTefOk := .F.
		lAborta 	:= .T.

		Exit
	EndIf
End   

If lAborta .OR. oTEF:lTefOk
	If oTEF:lTefOk .AND. !Empty(oTef:cMsnAmbos)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando ocorrer uma queda do sistema no meio de uma transacao TEF ³
		//³ ao reestabelecer o sistema, deve-se efetuar o cancelamento da    ³
		//³ transacao que estava sendo realizada, evitando assim que a mesma ³
		//³ fique como PENDENTE no SiTEF.                                    ³
		//³ O arquivo eh gravado no momento da mensagem TRANSACAO OK.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If oTef:nCodFuncao <> 110 .AND. oTef:nCodFuncao <> 540 
			LJTEFConfRW(GetClientDir() + "CLISITEF."+StrZero(oTEF:nIDTermina,3), .T., oTEF:cCupom, oTEF:cData, oTEF:cHora)
		EndIf	
		LJMsgStop(oTef:cMsnAmbos,StrTran(oTEF:cTitle," - ",""), 3)
		//Acerta as parcelas da transacao TEF
	EndIf                                    
	If oTEF:lTefOk	 // Obrigatorio passar pela funcao. Quando cartao com chip oTef:cMsnAmbos vem vazio. 
		LjTEFConfPar()
	Endif 	
	oDlgTef:End()
Else	
	If lInterage
		oGet:lPassword := .F.
		//Sai do laço para solicitar a informacao ao operador
		If oTef:nProxComan == 30 .OR. oTef:nProxComan == 34 .OR. oTef:nProxComan == 35
			//Valor de entrada já vem da interface não pode ser alterado
			If oTef:nTipoCampo == -1 .AND. AllTrim(oTef:cBuffer) == "Forneca o valor da entrada"
				nValor := oTef:aRetCartao[oTef:nTrans]:nVlrEntrada
				// Quando estiver fazendo a homologacao na Software Express, nao deve fornecer o valor ja definido na condicao de pagamento
				If oTEF:lHomolog
					nValor := 0
				EndIf
				LjTEFDigi("",nValor)
			//Data da primeira parcela CDC
			ElseIf (oTef:nTipoCampo == -1 .AND. AllTrim(oTef:cBuffer) == "Forneca a data da primeira parcela (DDMMAAAA)") .OR. oTef:nTipoCampo == 506
				If nTransCh > 0 .AND. oTef:Adados[nTransCh][3] == 'CH'
					cValor := SubStr(DtoS(oTef:aDados[nTransCh][1]),7,2)+SubStr(DtoS(oTef:aDados[nTransCh][1]),5,2)+SubStr(DtoS(oTef:aDados[nTransCh][1]),1,4)
					LjTEFDigi(cValor,0)
				Else
					cValor := SubStr(DtoS(oTef:aRetCartao[oTef:nTrans]:dEntrada),7,2)+SubStr(DtoS(oTef:aRetCartao[oTef:nTrans]:dEntrada),5,2)+SubStr(DtoS(oTef:aRetCartao[oTef:nTrans]:dEntrada),1,4)
					LjTEFDigi(cValor,0)
				EndIf
			//Número de Parcelas já vem da interface não pode ser alterado
			ElseIf oTef:nTipoCampo == 505 .OR. oTef:nTipoCampo == 511 .OR. ;
				(oTef:nTipoCampo == -1 .AND. AllTrim(oTef:cBuffer) == "Forneca o numero de parcelas")
				cValor := StrZero(oTef:aRetCartao[oTef:nTrans]:nParcelas,2)
				LjTEFDigi(cValor,0)
			 	nTransCH := nPosCH -1
			//Intervalo entre as parcelas a ser considerado
			ElseIf oTef:nTipoCampo == 508
				cValor := "30"
				LjTEFDigi(cValor,0)
			//Data da transação a ser cancelada (DDMMAAAA) ou a ser re-impressa
			ElseIf oTef:nTipoCampo == 515 .OR. (oTef:nTipoCampo == -1 .AND. AllTrim(oTef:cBuffer) == "Data da transacao (ddmmaaaa)")
				If lCancLJ140
					//Quando há um cancelamento este campo vem preenchido com a data da transação (SL4)
					cValor :=   Left(StrTran(DtoC(StoD(aVndCLJ140[3])),'/',''),4) + Str(Year(StoD(aVndCLJ140[3])),4)
				Else
					cValor := Substr(DToS(dDataBase),7,2) + Substr(DToS(dDataBase),5,2) + Substr(DToS(dDataBase),1,4)
				
				    If UPPER(AllTrim(oTef:cBuffer)) == UPPER("Data da transacao (ddmm)")
						cValor := Left( cValor , 4)
					EndIf	
				EndIf
				LjTEFDigi(cValor,0)
			
			
			//Numero do Doc
			ElseIf oTef:nTipoCampo == 516 .OR. (oTef:nTipoCampo == -1 .AND. AllTrim(oTef:cBuffer) == "Numero do Doc")
				If lCancLJ140
					/*Quando há um cancelamento este campo vem preenchido com o numero da transação (SL4)*/
					cValor := aVndCLJ140[1]
				Else
					cValor := Space(TamSX3("L4_DOCTEF")[1])
				EndIf
				LjTEFDigi(cValor,0)
			
			//Valor da Transação de Cancelamento
			ElseIf oTef:nTipoCampo == 146
				If lCancLJ140
					cValor := aVndCLJ140[2]
				Else
					cValor := 0
				EndIf
				
				LjTEFDigi(,cValor)
							
			//	Valor da Transacao Ch
			ElseIf oTef:nTipoCampo == 525
				If nTransCh > 0 .AND. oTef:Adados[nTransCh][3] == 'CH'
					LjTEFDigi('0',oTef:aDados[nTransCh][2])
				Else
					LjTEFDigi('0',0)
				EndIf
			//	Quantidade de Cheques - o campo ja esta preenchido pelo oTef:aDados
			ElseIf oTef:nTipoCampo == 526
			 	nTransCH := 0
			Else
				LjTEFDigi()
			EndIf
		ElseIf oTef:nProxComan == 21
			LjTEFSele()
		ElseIf oTef:nProxComan == 22
			LjTEFExib(oTef:cBuffer)
		
		ElseIf oTef:nProxComan == 23
			LjTEFObj(.F.,"B")
		ElseIf oTef:nProxComan == 31
			LjTEFCheq()

			If oTef:nContNaveg == 0  .AND.  oTef:nTipoCampo == 517 // botao Continua e eh cheque
				nTransCH++
				// controle para Array of bounds...as interacoes do TEF podem gerar essa não conformidade
				If 	nTransCH > 0 .AND. nTransCH <= Len( oTef:aDados)
					oTef:cBco   	:= PadR(oTef:aDados[nTransCH][7][2],3)
					oTef:cAge   	:= PadR(oTef:aDados[nTransCH][7][3],4)
					oTef:cCta	:= PadR(oTef:aDados[nTransCH][7][4],10)
					oTef:cChe  	:= PadR(oTef:aDados[nTransCH][7][5],6)
					oTef:cC3		:= Space(01)
				EndIf
			EndIf

		EndIf
	EndIf		
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³ImpCupTef ºAutora ³Vendas Clientes     º Data ³  10/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Cupom TEF                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
METHOD ImpCupTef(	nVlrTot	, lRelGer , nVlrTotRe,nVlrTefCF,;
					nVlrPagCF,lReserva,nCupTEf,lVendMis) CLASS MSTEF
                                                 	
Local cTickForm		:= ""                           //Informações retornadas no campo Cupom TEF
Local cTickBack		:= ""							//Armazenar conteúdo do cupom TEF para tratamento
Local nFor			:= 0							//Controle de laço
Local nVal			:= 0							//Controle de çaço
Local nValorTotal	:= 0							//Valor total da transação para abertura de cupom não fiscal
Local cAutentic		:= ""							//Verifica se trata-se somente de uma de autenticação de cheque	
Local nRet			:= -1							//Retorno da comunicação com o ECF	
Local nOpt			:= If(oTef:nCodFuncao==0,1,2)	//Verifica se imprime Leitura X ou Cupom Vinculado
Local lConfirma		:= .T.                          //Indica se deve ser efetuada a confirmação da transaçãp
Local oPbm			:= LjGetOPBM()					//Retorna o objeto da PBM
Local nX			:= 0							//Variavel do FOR
Local aRelPbm 		:= {}							//Cupom da pbm
Local nCount 		:= 0							//Controla a impressao do cupom da PBM
Local aTextVd		:= {}							// INFORMACOES TEF VENDA DIRETA
Local lAmbLinux		:= GetRemoteType() == REMOTE_LINUX   // Verifica Ambiente/Sistema Operacional esta sendo executado em Linux
Local lEmitNFCe 	:= ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe() 	//Se utiliza Nfc-e na estacao
Local cCaracter		:= ''
Local nTpImpTef		:= If(GetMv("MV_LJNFTEF",.T.),SuperGetMv("MV_LJNFTEF",,1),0) // Tipo de Impressao do Comprovante TEF: 1=ECF, 2=Imp. Nao Fiscal   [Considera valor (zero) caso o parametro nao exista, para tratar o legado]
Local cMVLJTEFPD	:= LjTEFPend(3) 				// Verifica se as transacoes TEF pendentes serao "1=Confirmadas", "2=Canceladas" ou "3=Permanecem Pendentes"
Local cMsgAviso 	:= ""
Local lConfTrn		:= .F.							//confirmou a transacao
Local lTEFFinal 	:= .F. 							//Transacao TEF Finalizada	

DEFAULT nVlrTot     := 0
DEFAULT lRelGer     := .F.    
DEFAULT nVlrTotRe	:= 0 						// Total de reserva do orçamento   	
DEFAULT nVlrTefCF 	:= 0						// Valor pago no cupom fiscal em Tef
DEFAULT nVlrPagCF	:= 0						// Valor pago no cupom fiscal em não Tef
DEFAULT lReserva 	:= .F.
DEFAULT nCupTEf 	:= 0						// Valor pago no cupom TEF
DEFAULT lVendMis	:= .F.

If oTEF:aRetVidaLink <> NIL
	//Quando são devolvidos os dois cupons enviar a confirmação da transação			
	If !Empty(oTef:aRetVidaLink:cCupom01) .AND. !Empty(oTef:aRetVidaLink:cCupom02)
		cTickForm += "--------------------------------" + Chr(10)
		cTickForm += oTef:aRetVidaLink:cCupom01 + Chr(10)
		cTickForm += "--------------------------------" + Chr(10)
		cTickForm += oTef:aRetVidaLink:cCupom02 + Chr(10)
		lConfirma := .T.
		If lEmitNFCe .And. nTpImpTef == 2
			aadd(aTextVd,{"--------------------------------" + Chr(10)})				
			aadd(aTextVd,{oTef:aRetVidaLink:cCupom01})
			aadd(aTextVd,{"--------------------------------" + Chr(10)})
			aadd(aTextVd,{oTef:aRetVidaLink:cCupom02})	
		EndIf
	EndIf
EndIf

If oTEF:aRetDotz <> NIL 
	//Quando são devolvidos os dois cupons enviar a confirmação da transação			
	If !Empty(oTef:aRetDotz[1]:cCupom01) .AND. !Empty(oTef:aRetDotz[1]:cCupom02)
		cTickForm += "--------------------------------" + Chr(10)
		cTickForm += oTef:aRetDotz[1]:cCupom01 + Chr(10) + TAG_GUIL_INI+TAG_GUIL_FIM
		cTickForm += "--------------------------------" + Chr(10)
		cTickForm += oTef:aRetDotz[1]:cCupom02 + Chr(10) + TAG_GUIL_INI+TAG_GUIL_FIM
		lConfirma := .T.
	EndIf
EndIf

If oTef:nCodFuncao == 900    	//CORRESPONDENTE BANCARIO
	If !Empty(oTef:aRetCorresp[1]:cComprov01) .AND. !Empty(oTef:aRetCorresp[1]:cComprov02)
		cTickForm += "--------------------------------" + Chr(10)
		cTickForm 	+= oTef:aRetCorresp[1]:cComprov01 + Chr(10)
        cTickForm 	+= oTef:aRetCorresp[1]:cComprov02 + Chr(10)		
		nValorTotal := oTef:aRetCorresp[1]:nVlrPgto
		lConfirma := .T.
		//Quando é devolvido somente uma via de cupom não enviar a confirmação pois esta trn não necessita
	ElseIf !Empty(oTef:aRetCorresp[1]:cComprov01) .AND. Empty(oTef:aRetCorresp[1]:cComprov02)
		cTickForm += oTef:aRetCorresp[1]:cComprov01 + Chr(10)
		lConfirma := .T.                                                      
	EndIf

	nValorTotal := RetVlrCB()

ElseIf oTef:nCodFuncao == 300 .OR. oTef:nCodFuncao == 301 //RECARGA DE CELULAR
	If !Empty(oTef:aRetRecarga[1]:cComprov)
		cTickForm    += "--------------------------------" + Chr(10)
		cTickForm 	 += oTef:aRetRecarga[1]:cComprov + Chr(10)
		nValorTotal  := Round(oTef:aRetRecarga[1]:nValor / 100, 2)
		cTotalizNFis := GetPvProfString("Recarga Celular", "Totalizador", "01", ARQLJINI )
		cFormRecar 	 := GetPvProfString("Recarga Celular", "FormaPgto", " ", ARQLJINI )
		
		If Empty(AllTrim(cFormRecar))
			LjGrvLog("","Verifique a configuração de impressão da Recarga de Celular no arquivo SIGALOJA.INI")
		EndIf

		// NFC-e alimenta o array aTextVd que ja eh passado como parametro para impressao
		If lEmitNFCe
			aadd(aTextVd,{"--------------------------------" + Chr(10)})				
			aadd(aTextVd,{oTef:aRetRecarga[1]:cComprov})							
		EndIf						
	EndIf		
	
ElseIf oTef:nCodFuncao == 669 .Or. oTef:nCodFuncao == 264 //Recarga de Gift Card (669=Modulo Givex; 264=Modulo SQCF - Todo Cartoes)
	For nFor := 1 To Len(oTef:aRetRecCP)
		If !Empty(oTef:aRetRecCP[nFor]:cComprov)
			If nFor > 1 .Or. !Empty(cFormRecar)
				cTickForm    += "--------------------------------" + Chr(10)
			EndIf
			cTickForm 	 += oTef:aRetRecCP[nFor]:cComprov + Chr(10)
			nValorTotal  += Round(oTef:aRetRecCP[nFor]:nValor, 2)
		EndIf
	Next nFor
Else							//TRANSACAO COM CARTAO
	If ValType(oTef:aRetCartao) == "A"		
		For nFor := 1 To Len(oTef:aRetCartao)
			//Armazena dados para efetuar a autenticação do documento
			If !Empty(oTef:aRetCartao[nFor]:cAutentic)
				cAutentic += oTef:aRetCartao[nFor]:cAutentic
			EndIf
			//Quando são devolvidos os dois cupons enviar a confirmação da transação			
			If !Empty(oTef:aRetCartao[nFor]:cCupom01) .AND. !Empty(oTef:aRetCartao[nFor]:cCupom02)
				//Verifica se tem cupom reduzido
				If ::CupomReduz() .AND. oTef:nCodFuncao != 110 
					cTickForm += oTef:aRetCartao[nFor]:cCupom02 + Chr(10)
				    
				    aadd(aTextVd,{oTef:aRetCartao[nFor]:cCupom02})				
				
				Else
					cTickForm += Chr(13) + Chr(10)
					cTickForm += oTef:aRetCartao[nFor]:cCupom01
					
					If lEmitNFCe
						//adiciona o comando de corte da guilhotina após a impressao da primeira via
						cTickForm += Replicate(Chr(13)+Chr(10),4) + TAG_GUIL_INI+TAG_GUIL_FIM
					Else
						cTickForm += Chr(10)
					EndIf
							            
		            Aadd( aTextVd, {oTef:aRetCartao[nFor]:cCupom01 + Chr(13) + Chr(10) + Chr(13) + Chr(10) + TAG_GUIL_INI+TAG_GUIL_FIM + Chr(13) + Chr(10)} )

					cTickForm += Chr(13) + Chr(10)
					cTickForm += oTef:aRetCartao[nFor]:cCupom02
					
					If lEmitNFCe .And. !(nFor = Len(oTef:aRetCartao))
						//adiciona o comando de corte da guilhotina após a impressao da primeira via
						cTickForm += Replicate(Chr(13)+Chr(10),4) + TAG_GUIL_INI+TAG_GUIL_FIM
					Else
						cTickForm += Chr(10)
					EndIf
					
					If !lEmitNFCe
						cTickForm += Chr(10)
					EndIf
					
					Aadd( aTextVd, {oTef:aRetCartao[nFor]:cCupom02} )
				EndIf
				lConfirma := .T.
			//Quando é devolvido somente uma via de cupom não enviar a confirmação pois esta trn não necessita
			ElseIf !Empty(oTef:aRetCartao[nFor]:cCupom01) .AND. Empty(oTef:aRetCartao[nFor]:cCupom02)
				cTickForm += oTef:aRetCartao[nFor]:cCupom01 + Chr(10)
				lConfirma := .F.                                  
				aadd(aTextVd,{oTef:aRetCartao[nFor]:cCupom01})
			ElseIf !Empty(oTef:aRetCartao[nFor]:cCupom02) .AND. Empty(oTef:aRetCartao[nFor]:cCupom01)
				cTickForm += oTef:aRetCartao[nFor]:cCupom02 + Chr(10)
				lConfirma := .F.                                  
				aadd(aTextVd,{oTef:aRetCartao[nFor]:cCupom02})			
			EndIf
			//Não soma se for telecheque, pois é somado junto ao dinheiro 
			IF oTef:aRetCartao[nFor]:cForma !="CH"
				nValorTotal += oTef:aRetCartao[nFor]:nVlrTrans
			EndIf
		Next nFor

		If Len(oTef:aRetCartao) > 0 .AND. (nVlrTotRe < nValorTotal) .And. !(AllTrim(Upper(FunName())) == "FRTA271")
			nValorTotal := 0      
			//Pega a ultima forma de pgto do aRetCartao para manter a compatibilidade
			//com o mesmo trecho da funcao LjTEFImpr
			//Quando for total de reserva (sem retira) nao precisa executar este trecho 
			//Ele eh executado para nao gerar erro no cupom NAO fiscal do pedido   
			cFormaPag 	:= oTef:aRetCartao[Len(oTef:aRetCartao)]:cForma 
			For nFor := 1 To Len(oTef:aRetCartao)
				If cFormaPag == oTef:aRetCartao[nFor]:cForma 
					nValorTotal += oTef:aRetCartao[nFor]:nVlrTrans			
				Endif
			Next nFor				
		Endif
				
	Else
		nValorTotal := nVlrTot				
	Endif		
EndIf

//Salvando o conteúdo a ser tratado e enviado para o ticket de impressao
cTickBack := cTickForm
cTickForm := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se na string que está tentando imprimir no ECf existe o Chr(0) em caso positivo                      ³
//³este deve ser removido pois derrubaria a execução do Sistema por ser considerado como fim de ponteiro no Delphi³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFor := 1 To Len(cTickBack)

	cCaracter :=   SubStr(cTickBack,nFor,1)
	  
	If cCaracter == Chr(0) .OR. cCaracter == ''
		cTickForm += Chr(32)
	Else
 		cTickForm +=cCaracter
	EndIf		
Next nFor
       

oTef:lImprimiu := .T.
oTef:lTefOk	:= .T.

If nValorTotal > nVlrTefCF  		  // Abate valor pago no cupom fiscal
	nValorTotal 	-= nVlrTefCF
	nCupTEf 		+= nValorTotal     //Totaliza o valor pago em tef fiscal e não fiscal
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do comprovante TEF  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cTickForm) .And. ( nModulo <> 12 .Or. !LjNfUsaTef(SM0->M0_CGC) )   	//Se não existir ticket para impressão deixar a variável como impressão ok para o processo da interface

	If nTpImpTef == 1 
		Conout("Atenção: Impressão do TEF será efetuada em Impressora Fiscal. Caso necessário altere o conteúdo do parametro MV_LJNFTEF")
		LjGrvLog(Nil, "Atenção: Impressão do TEF será efetuada em Impressora Fiscal. Caso necessário altere o conteúdo do parametro MV_LJNFTEF")
	EndIf

	If 	( SubStr(SL1->L1_IMPRIME,1,1) == "2" .And. nTpImpTef == 2 .And. !lEmitNFCe ) .OR. ; 								//Nota Fiscal
		( lEmitNFCe .And. nTpImpTef == 2 ) .OR. ; 																			//NFC-e
		( ( nModulo == 5 .OR. nModulo == 51 ) .AND. ExistFunc("FTVDGetImp") .AND. FTVDGetImp() .And. (nTpImpTef == 2 .Or. nTpImpTef == 0) ) 	//Venda Direta
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressora Nao Fiscal         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		LjMsgRun(STR0008+" "+STR0065,,{ || ImpTefEcNf(aTextVd) })  	//"Aguarde... " "Imprimindo Cupom TEF..." 	                                                      
		
	ElseIf nTpImpTef <> 3 // nTpImpTef = 3 -> não imprime
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressora Fiscal             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		LjMsgRun(STR0008+" "+STR0065,,{ || LjTEFImpr(cTickForm,nValorTotal,@lRelGer,.F.,;
												nVlrTefCF,nVlrPagCF,lReserva,lVendMis ) })  	//"Aguarde... " "Imprimindo Cupom TEF..."														
	EndIf
    
	If lAmbLinux
		// Soh chama a tela para confirmar qdo nao for Relatorio Gerencial
		If !oTEF:lTefOk .And. !lRelGer
					
			lRetSenSup := MsgNoYes(STR0164)
            // True = N Cancela  False = Cancela 		
			If lRetSenSup
				lRetSenSup := LjSenSupTEF()
	            // False = N Cancela True = Cancela
	        Else
				lRetSenSup :=.F.
			EndIf	
				
			If !lRetSenSup	// Confirma
				oTEF:FinalTrn(1) 
				lConfTrn := .T.
			    oTef:lTefOk	:= .T.				
			    lTEFFinal := .T.				
			Else            // Cancela   
				oTEF:FinalTrn(0) 												
		    	oTef:lTefOk	:= .F.  
		    	oTef:lImprimiu	:= .F.				    	
		    	lTEFFinal := .T.			    	
			Endif				
	    Else
		    If lConfirma .And. oTEF:lImprimiu
				oTEF:FinalTrn(1) 
				lConfTrn := .T.
		 	   	oTef:lTefOk	:= .T.		    
		 	   	lTEFFinal := .T.    
			Else
				oTEF:FinalTrn(0) 												
	    		oTef:lTefOk	:= .F.  
	    		lTEFFinal := .T.
		    Endif	
		Endif

	Else	

		// Diferente de ambiente Linux nao mudou nada
		If oTef:lImprimiu
			//Chamo a confirmacao
			If lConfirma
				oTEF:FinalTrn(1) 
				lConfTrn := .T.
			    oTef:lTefOk	:= .T.
			    lTEFFinal := .T.
			Else
		    	oTef:lTefOk	:= .F.
			EndIf		
		Else
			//Chamo a não confirmacao
			If lConfirma            
				// Quando ocorre na impressao do comprovante de cancelamento, nao apresenta mensagem de transacao nao efetuada
				// Quando cancelamento, o envio de confirmacao e feito antes da impressao
				If AllTrim(Upper(FunName())) <> "LOJA140"				
				    
				    cMsgAviso := "Ocorreu problema na impressão do comprovante TEF." + Chr(10) + Chr(13)
				    
					If cMVLJTEFPD == "1" //1=Confirma a transacao TEF Pendente
						cMsgAviso += "A transação TEF desta venda foi CONFIRMADA! Realize a reimpressão do comprovante TEF!"
						oTEF:FinalTrn(1)  //CONFIRMA a transacao TEF Pendente
						lConfTrn := .T.
						lTEFFinal := .T.
					ElseIf ( Empty(cMVLJTEFPD) .Or. cMVLJTEFPD == "2" ) .OR. (oTef:nCodFuncao == 300 .OR. oTef:nCodFuncao == 301 .OR. oTef:nCodFuncao  == 900 )//2=Cancela a transacao TEF Pendente 
						cMsgAviso += STR0067 + " Comunique imediatamente o departamento de TI sobre esta ocorrência!" //"Transação TEF não foi efetuada. Favor reter o Cupom!"
						oTEF:FinalTrn(0)  //CANCELA a transacao TEF Pendente (Envia o desfazimento da transacao TEF)
						lTEFFinal := .T.
					ElseIf cMVLJTEFPD == "3" //3=Deixa pendente a transacao TEF
						//Neste caso, a Transacao TEF ficara pendente para ser confirmada ou cancelada manualmente pelo Software da SiTEF.
						cMsgAviso += "A transação TEF desta venda permanecerá PENDENTE! Comunique imediatamente o departamento de TI sobre esta ocorrência!"
					EndIf
					oTef:lTefOk	:= .F.
					
					LjGrvLog("",'Mensagem exibida para o usuário: "'+cMsgAviso+'"')
					MsgAlert(cMsgAviso, STR0005 ) //###"Atenção"###"Ocorreu problema na impressão do comprovante TEF."###...
				Endif    
			Else
			    MsgStop(STR0071)					//"Impressão não Concluída. Repetir o processo."
			    oTef:lTefOk	:= .F.
			EndIf
		EndIf

	EndIf
ElseIF !Empty(cTickForm) .And. LjNfUsaTef(SM0->M0_CGC) 
	//Chamo a confirmacao
	If lConfirma
		oTEF:FinalTrn(1)
		lConfTrn := .T.
		oTef:lTefOk	:= .T.
		lTEFFinal := .T.
	Else
		oTef:lTefOk	:= .F.
	EndIf	
EndIf


If oTef:lTefOk .AND. oPbm <> NIL
	cTickForm := ""
	aRelPbm := oPbm:BuscaRel()
	
	While ++nX <= Len( aRelPbm ) .AND. nCount <= 1
		cTickForm += aRelPbm[nX] + Chr(10)
		If nX == Len( aRelPbm )
			++nCount
			nX := 0
			cTickForm += Chr(13) + Chr(10)
		EndIf
	End
	
	LjMsgRun(STR0008+" "+STR0065,,{ || LjTEFImpr(cTickForm,nValorTotal,@lRelGer, .T.,nVlrTefCF,nVlrPagCF) })  	//"Aguarde... " "Imprimindo Cupom TEF..."  
	If oTef:lImprimiu						
		//Chamo a confirmacao
		If lConfirma
			If (lTEFFinal .AND. oPBM:oPBM:cNumCupom == oTEF:cCupom)
				oPBM:oPBM:ApagArqTef()
			Else				
			oPbm:ConfVend( .T. )
			EndIf
			lConfTrn := .t.
		    oTef:lTefOk	:= .T.
		Else
	    	oTef:lTefOk	:= .F.
		EndIf		
	Else
		//Chamo a não confirmacao
		If lConfirma
			If (lTEFFinal .AND. oPBM:oPBM:cNumCupom == oTEF:cCupom)
				oPBM:oPBM:ApagArqTef()
			Else				
			oPbm:ConfVend( .F. )
			EndIf
			MsgAlert(STR0158)
		    oTef:lTefOk	:= .F.
		Else
		    MsgStop(STR0071)													//"Impressão não Concluída. Repetir o processo."
		    oTef:lTefOk	:= .F.
		EndIf
	EndIf
EndIf


cTickForm := ""
cTickBack := ""      

// Verifica se oTef:nCodFuncao <> 110 (Estorno/Cancelamento)
//Não deixa limpar o aRetCartao pois se eu fiz uma recarga nao fiscal com CC/CD preciso das informações
If oTef:nCodFuncao <> 110 .And. oTef:nCodFuncao <> 300
	oTef:aRetCartao := {{}}
	oTef:aRetCartao[1] := MSRetCartao():New()	// Reinstancia pois nesta posicao do array espera-se um Objeto.
Endif	

//Reseta totalizador e forma de pagamento quando for Recarga de Celular ou Recarga de Gift Card
If oTef:nCodFuncao == 300 .OR. oTef:nCodFuncao == 301 .OR. ; //300=Recarga Celular (Recarga Nao Fiscal);  301=Recarga Celular (Recarga Fiscal)
	oTef:nCodFuncao == 669 .OR. oTef:nCodFuncao == 264 //Recarga de Gift Card (669=Modulo Givex; 264=Modulo SQCF - Todo Cartoes)
	cTotalizNFis := GetPvProfString("Comprovante TEF", "Totalizador", "01", ARQLJINI )
	cFormRecar 	 := ""
EndIf     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo LG_LOGTEF existe e verifica³
//³se posicionou no registro                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAchouSLG
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
If !Empty(cAutentic)
	If MsgYesNo(STR0064+chr(10)+cAutentic+Chr(10)+Str(nValorTotal,14,2),STR0005)//"Posicione o documento e tecle <SIM> para autenticar."
		While .T.
			nRet := IFAutentic( nHdlECF, "1", Str(nValorTotal,14,2) , "" )
			If nRet <> 0
				If 	Aviso(STR0005,STR0069,{STR0047,STR0048},,STR0068) == 1 		//"Atenção" "Tentar autenticar novamente ?" "Sim" "Não" "Problemas com a Impressora"
					Loop
				Else
					Aviso(STR0005,STR0070,{STR0049},,STR0068)					//"Atenção" "Autenticação não pode ser efetuada!" "OK" "Problemas com a Impressora"
				EndIf
			EndIf			
			Exit
		End
	EndIf		
EndIf

//Retorna o valor padrão da variavel para que seja verificado as pendencias na proxima venda
If oTef:lTefOk
	lVldPend := .T.
EndIf 

Return lConfTrn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LjTEFImpr    ³ Autor |Vendas Clientes     ³ Data ³ 13/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime o cupom TEF 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := LjTEFImpr( ExpA1, [ ExpA2 ], [ ExpC1 ] )		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpA1 -> Ticket formatado / ExpA2 -> Promissoria formatad  ³±±
±±³			 ³ ExpC1 -> String Garantia de cheque                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorna	 ³ ExpL1 -> Venda realizada com sucesso                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA010T                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFImpr(	cTickForm	, nValorTotal	, lRelGer	, lRelPBM	,;
					nVlrTefCF	, nVlrPagCF		, lReserva	, lVendMis)
Local nOpt			:=  1   
Local nRet			:= -1
Local cFPgto    	:= ""
Local lContinua		:= .T.								// Controla a reimpressao do TEF   
Local oPbm			:= LjGetOPBM()						// Retorna o objeto da PBM
Local lAmbLinux		:= GetRemoteType() == REMOTE_LINUX	// Verifica Ambiente/Sistema Operacional esta sendo executado em Linux
Local cTotCB 		:= ""
Local aFormaPgtos   := lj7GetForm()						// Formas de pagamento TEF
Local nVias			:= 1
Local cImpEst		:= LjGetStation("LG_IMPFISC")		// Retorna a impressora da estação
Local lImpFiscal	:= .T.								// Valide se é impressora fiscal

DEFAULT lRelGer     := .F. 
DEFAULT lRelPBM		:= .F.
DEFAULT nVlrTefCF	:= 0
DEFAULT nVlrPagCF	:= 0
DEFAULT lReserva	:= .F.
DEFAULT lVendMis	:= .F.


If oTef:nCodFuncao == 0 .OR. oTef:nCodFuncao == 900
	nOpt := 1
Else 
	nOpt := 2	
EndIf

If oTEF:nCodFuncao == 903 .OR. oTEF:nCodFuncao == 545 //VIDALINK 
	cFPgto := "DINHEIRO"

ElseIf oTEF:nCodFuncao == 900  //CORRESPONDENTE BANCARIO
	//Totalizador do Correspondente Bancario:
	cTotCB := AllTrim(GetPvProfString("Correspondente Bancario", "Totalizador", "", ARQLJINI ))
	If !Empty(cTotCB)
		cTotalizNFis := cTotCB
	EndIf

	//Forma de Pagamento do Correspondente Bancaro:
	cFPgto := AllTrim(GetPvProfString("Correspondente Bancario", "FormaPgDin", "", ARQLJINI ))
	If Empty(cFPgto)
		If !Empty(cFrmPgDi)
			cFPgto := cFrmPgDi
		Else
			cFPgto := "DINHEIRO"
		EndIf
	EndIf

ElseIf lRelPBM .OR. (oPbm <> NIL .AND. oPbm:GetTpOpera() == 2 .AND. ValType(oTef:aRetCartao) == "U")   //CANCELAMENTO PBM
	nOpt	:= 2
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Recebimento de titulos esta' sendo paga ³
	//³com TEF. (Cartao de Credito ou Cartao de Debito)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
	If LjRecTef()
		cFPgto := &(SuperGetMV("MV_NATRECE"))
	Else
		//Descricao da condicao de pagamento a ser impressa no Cupom TEF, deve ser a mesma do ECF
		If SuperGetMV("MV_LJPAGTO")==1
			cFPgto := AllTrim(Upper(RetDescri(oTef:aRetCartao[Len(oTef:aRetCartao)]:cForma)))
		Else
			cFPgto := oTef:aRetCartao[Len(oTef:aRetCartao)]:cDescadm
		EndIf
	Endif
EndIf

/* Caso a venda utilize mais de uma formas de pagamento
A descrição da forma de pagamento  toma o valor da
chave sigaloja.ini/microsiga/condição    	      	*/
If lReserva .AND. Type("oTef:aRetCartao") == "A" .AND. Len(oTef:aRetCartao) > 1   		

	cFPgto := GetPvProfString("microsiga", "condicao", "A Vista", ARQLJINI )
EndIf

If oTef:nCodFuncao == 300//Recarga de Celular Não Fiscal, efetua impressão de CNF
	nOpt	:= 1
	cFPgto	:= cFormRecar
	nVias	:= 2

	LjLogFront('LOJXTEF - Verifica gaveta na venda recarga de celular')
	Abregaveta()
EndIf

//Quando Efetuo uma recarga fiscal, efetuo a impressão de um gerencial com as informações da recarga
If oTef:nCodFuncao == 301
	nOpt	:= 2
	cFPgto	:= cFormRecar
	nVias	:= 2
EndIf
	
If GetAPOInfo("LOJA121.PRW")[4] >= Ctod("16/03/2017")
	lImpFiscal := Lj121IsFisc(cImpEst)
ElseIf  FindFunction("LjEmitNFCe") 
	lImpFiscal := !(LjEmitNFCe() .or. nModulo == 5)
EndIf

While lContinua
	LjLogFront("LOJXTEF - INICIANDO IMPRESSÃO DO CUPOM NÃO FISCAL")
	Do Case
		//Abre cupom fiscal não vinculado
		Case nOpt == 1
			nRet := -1
           //Utiliza totalizador do nao fiscal do ECF, quando a venda e' finalizada em NF
           //Ou quando a venda for mista
			If oTef:nCodFuncao == 0 .And. SubStr(SL1->L1_IMPRIME,1,1) == "2" .Or. lVendMis				
		   		nRet := IFRecebNFis( nHdlECF, cTotalizNFis, nValorTotal, cFPgto )		   		
				If LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !lAmbLinux .And. !LjSenSupTEF())
					//Quando eh venda mista, forca a impressao do Totalizador nao fiscal, para registrar na impressora o valor vendido, 
					//pois neste caso, parte do valor da venda nao eh registrada o cupom fiscal entao por isso registra no Totalizador nao fiscal.
					If lVendMis
						nOpt := 1 //Forca para imprimir o Totalizador nao fiscal
					EndIf
					Loop
				Else
					If nOpt == 0
						lContinua := .F.
					EndIf
				EndIf
		EndIf
			
			If oTef:nCodFuncao == 300 .And. ("ELGIN" $ LjGetStation("IMPFISC")) //300=Recarga de Celular (nao-fiscal)
				//Primeiro imprime o Totalizador Nao Fiscal referente a recarga de celular, qdo. for impressora ELGIN
		   		If lImpFiscal
		   			nRet := IFRecebNFis( nHdlECF, cTotalizNFis, nValorTotal, cFPgto )
		   		
					If LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !lAmbLinux .And. !LjSenSupTEF())
						Loop
					Else
						If nOpt == 0
							lContinua := .F.
						EndIf
					EndIf
				EndIf
		 	EndIf

			//Se houver a funcao no loja701d, busca o valor das formas tef, para impressao correta do 
			//comprovante de credito e debito e consequente ajuste da leitura x
			If ExistFunc("lj7GetForm") .And. !(AllTrim(Upper(FunName())) == "FRTA271")
				If Len(aFormaPgtos) > 0 
					nValorTotal := 0 
					aEval( aFormaPgtos, {|x| nValorTotal+=x[2] })
					lj7SetForm()  // limpa aFormaPgtos // nao tem findfunction porque esta junto com a funcao lj7GetForm
				Endif
			EndIf
			
			If lImpFiscal

				// Impressao do COMPROVANTE CRÉDITO OU DÉBITO				
				If Len(aFormaPgtos) > 1
					nRet := IFAbrCNFis( nHdlECF, aFormaPgtos[1][1] , Str(aFormaPgtos[1][2],14,2) , cTotalizNFis ) // COMPROVANTE CRÉDITO OU DÉBITO
				Else
					nRet := IFAbrCNFis( nHdlECF, cFPgto , Str(nValorTotal,14,2) , cTotalizNFis ) // COMPROVANTE CRÉDITO OU DÉBITO
				EndIf		
				
				LjLogFront("LOJXTEF - IMPRESSÃO DO RECEBIMENTO NÃO FISCAL")
				If LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !lAmbLinux .And. !LjSenSupTEF())
					//Quando eh venda apenas de item de pedido (reserva), forca a impressao pra sair com o Totalizador nao fiscal, para registrar na impressora o valor vendido, 
					If !lVendMis .And. lReserva
						nOpt := 1 //Forca para imprimir o Totalizador nao fiscal
					EndIf
					Loop
				Else
					If nOpt == 0
						lContinua := .F.
					EndIf
				EndIf				
			EndIf

			nOpt := 1
			//Imprime o texto não fiscal
			If (nRet == 0 .And. lAmbLinux) .OR. !lAmbLinux
				nRet := -1
				// Impressao das vias do cartao				
				nRet := IFTxtNFis( nHdlECF, cTickForm , nVias, !lImpFiscal )
				If LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !lAmbLinux .And. !LjSenSupTEF())
					Loop
				Else
					If nOpt == 0
						lContinua := .F.
					EndIf
				EndIf      
				// Aguarda o retorno da impressao do Texto nao Fiscal no ECF				
				If (lAmbLinux .And. nRet == 0)	             
					Sleep(3000)
				Else	
					Sleep(2000)
				Endif	                         
            Endif
	
			nOpt := 1
			If (nRet == 0 .And. lAmbLinux) .OR. !lAmbLinux
				//Fecha o cupom não fiscal
				If lImpFiscal
					nRet := -1					
					nRet := IFFchCNFis( nHdlECF )					
					//Se cancelou a impressão TEF Posteriormente  não trata o retorno do TEF, mantém a opção do usuário: Motivo dava erro no texto do comprovante
					// o usuário selecionava NÃO era considerado Sucesso na impressão TEF
					If lContinua .AND. LjTEFAskImp(@nOpt,nRet) .OR. (nOpt == 0 .And. !lAmbLinux .And. !LjSenSupTEF())
						Loop
					Else
						If nOpt == 0
							lContinua := .F.
						EndIf
					EndIf
				EndIf
			Endif			
		Case nOpt == 2
			nOpt := 1
			//Imprime relatorio gerencial com o comprovante a ser impresso
			nRet := -1
			nRet := IFRelGer( nHdlECF, cTickForm, nVias, , !lImpFiscal )
			If nRet == 0 
				lRelGer := .T.
			EndIf      
			
			If LjTEFAskImp(@nOpt,nRet)  .OR. (nOpt == 0 .And. !lAmbLinux .And. !LjSenSupTEF())
				Loop
			Else
				If nOpt == 0
					lContinua := .F.
				EndIf
			EndIf			
	EndCase
	Exit
End	
//Verifico o status da impressora
oTef:lImprimiu	:= (nRet == 0)

Return NIL


/*
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjTEFAskImpºAutor  ³Edney S. Souza      º Data ³  28/09/00  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Solicita ao usuário confirmação para reimprimir cupom TEF. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ xOpt := Opcao escolhida (passar por referencia)            º±±
±±º          ³ xOpt := .F. - Nao faz a pergunta de tentar novamente.      º±±
±±º          ³ nRet := Resultado da ultima impressao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFAskImp(xOpt,nRet)
Local lRet := .F.
Local lAmbLinux		:= GetRemoteType() == REMOTE_LINUX   // Verifica Ambiente/Sistema Operacional esta sendo executado em Linux
Local cImpressora	:= LjGetStation("IMPFISC")

If nRet <> 0
	If ValType(xOpt) == "N"
		//Se NF com Comprovante TEF no ECF/Nao Fiscal, nao pergunta
		If SubStr(SL1->L1_IMPRIME,1,1) == "2"
			xOpt := 2 
		Else
			// "Atenção" ## "Deseja imprimir novamente?" ## Sim ## Não ## "Impressora não responde."
			xOpt := If(Aviso(STR0005,STR0090,{STR0047,STR0048},,STR0091)=1,2,0)
			If xOpt == 2
				//Tratamento especifico para BEMATECH MP-4200 (NAO FISCAL) devido problema de comunicacao
				If "BEMATECH MP-4200" $ cImpressora
					LjAskImp(-1, .F.)
				EndIf
			EndIf
		EndIf
		
		If xOpt == 0 .OR. xOpt == 2
			nRet := -1
			nRet := IFFchCNFis( nHdlECF )   
			
			If xOpt == 2
				lRet := .T.
			EndIf
			// Em ambiente Linux e forcado o retorno de lTEFok para False, pois ponto neste ja apresentou algum problema
			// Com isso, ira solicitar ao operador a confirmacao da transacao
			If lAmbLinux
				oTEF:lTEFOk := .F.			 
			Endif
		EndIf	
	Else
		xOpt := 3
		//"Atenção" ## "Problemas com a Impressora Fiscal" ## OK
		Aviso(STR0005,STR0078,{STR0049})
		lRet := .T.
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³FinalTrn  ºAutora ³Solange Zanardi     º Data ³  10/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Método a ser processado na finalização da operação TEF      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
METHOD FinalTrn(nConfirma, lLimpaLog) CLASS MSTEF

Local cTipo := ""							//Identifica se a transacao sera confirmada ou desfeita
Local lAmbLinux		:= GetRemoteType() == REMOTE_LINUX
DEFAULT lLimpaLog := .F.

If ValType(oTEF:aRetVidaLink) == "O"  
	If !oTef:aRetVidalink:lConfTran 
		oAutocom:SIT_FINAL(1,oTef:cCupom,oTef:cData,oTef:cHora)
		oTef:aRetVidalink:lConfTran := .T.
	EndIf	
Else
	oTEF:aRetVidaLink := NIL
EndIf

oTef:cCupomRedu		:= "" 
//So enviara o cancelamento quando existir venda
If !Empty(oTef:cCupom)
	cTipo := IIF(nConfirma == 1, "Confirmando transacao", "Desfazendo transacao")
	
	oGlobal:GravarArq():Log():Tef():Gravar(cTipo + "(" + oTef:cCupom + ", " + oTef:cData + ", " + oTef:cHora + ")")
	oAutocom:SIT_FINAL(nConfirma,oTef:cCupom,oTef:cData,oTef:cHora)
	
	If ExistFunc("LjEraseTef") //Apaga o arquivo de controle dos dados da transacao TEF da venda.
		LjEraseTef(If(Type("M->LQ_NUM")<>"U",+M->LQ_NUM,SL1->L1_NUM))
	EndIf
	
	If IsInCallStack("LJRotTEF") //Chamada atraves do Menu "Rotinas TEF"
		LjGrvLog( "oTef:cData: " + oTef:cData + ", oTef:cHora: " + oTef:cHora, If(nConfirma==1,"CONFIRMACAO","DESFAZIMENTO") + " da TRANSACAO TEF chamada pelo Menu: Rotinas TEF.", Nil, .T. )
	Else
		If nConfirma == 1
			LjGrvLog( If(Type("M->LQ_NUM")<>"U","Orc: "+M->LQ_NUM+" ","") + "oTef:cCupom: " + oTef:cCupom + ", oTef:cData: " + oTef:cData + ", oTef:cHora: " + oTef:cHora, "CONFIRMACAO da TRANSACAO TEF.", Nil, .F. )
		Else
			LjGrvLog( If(Type("M->LQ_NUM")<>"U","Orc: "+M->LQ_NUM+" ","") + "oTef:cCupom: " + oTef:cCupom + ", oTef:cData: " + oTef:cData + ", oTef:cHora: " + oTef:cHora, "DESFAZIMENTO da TRANSACAO TEF.", Nil, .T. )
		EndIf
	EndIf
	
	::LjxGrvTrn(nConfirma)  //so grava o log se a transacao foi confirmada

	If lLimpaLog	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o campo LG_LOGTEF existe e verifica³
		//³se posicionou no registro                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchouSLG
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
		
EndIf

If lAmbLinux .And. ValType(oTEF:aRetVidaLink) == "O" 
	oTEF:aRetVidaLink := MSRetVidaLink():New()
Endif				

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³TestaPin  ºAutora ³Solange Zanardi     º Data ³  29/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa teste de comunicacao com PINPAD                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD TestaPin( ) CLASS MSTEF
Local nRet												//Controla o retorno da funcao executada na DLL
Local aRetIni := {}										//Mensagens obigatorias em caso de erros	
Local nPos												//Controle de posicionamento da array	

oGlobal:GravarArq():Log():Tef():Gravar("VerificaPresencaPinPad()")

nRet := oAutocom:SIT_VERPIN( )

oGlobal:GravarArq():Log():Tef():Gravar("Retorno: " + AllTrim(Str(nRet)))

aRetIni := LjTEFMensa("P")

If nRet < -1 .OR. nRet > 1
	// "Erros detectados internamente pela rotina ou pela biblioteca de acesso ao PinPad" ### "Mensagem SITEF"
	MsgAlert(STR0035+Chr(10)+AllTrim(Str(nRet)), STR0006)
Else
	nPos := Ascan(aRetIni, {|x| x[1] == nRet } )
	MsgAlert(aRetIni[nPos][2],STR0006)
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFExib ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara o listbox para exibir os dados enviados e aguarda  º±±
±±º          ³ uma confirmacao do operador                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFExib()												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFExib(cBuffer,lEncerra)
Local aDadosExi		:= {}
Local nFor			:= 0	//Controle de loop
Local cString		:= ""
Local nTam			:= 0

DEFAULT lEncerra	:= .F.

LjTEFDisp(cBuffer)

cBuffer		:= StrTran(cBuffer,Chr(13),'')
nTam		:= Len(cBuffer)

For nFor := 1 To nTam
	If SubStr(cBuffer,nFor,1) == Chr(10) .OR. nFor == nTam
		If SubStr(cBuffer,nFor,1) <> Chr(10)
			cString += SubStr(cBuffer,nFor,1)
		EndIf
		Aadd(aDadosExi,cString)
		cString		:= ""
	Else
		cString += SubStr(cBuffer,nFor,1)
	EndIf
Next nFor

oList:aItems 	:= aDadosExi
oMens:cCaption	:= aDadosExi[1]

//Aciona os objetos corretamente na Tela
LjTEFObj(.F.,"L")

If oTef:nCodTrans == 60 .OR. oTef:nCodTrans == 50 
	oBtnC:SetFocus()
Else
	oBtnE:SetFocus()
EndIf	

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjTEFPerg ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara os objetos a serem exibidos em tela para selecao   º±±
±±º          ³ do operador de caixa                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFSele()												  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFPerg()
Local lOpcao := .T.

LjTEFDisp(oMens:cCaption)

//Captura se a primeira parcela é a vista ou não (0 - Primeira a vista, 1 - caso contrário)
If 	oTef:nTipoCampo ==507
	// Quando estiver fazendo a homologacao na Software Express, esta mensagem deve ser apresentada.
	// Em producao SEMPRE considerar a data da primeira parcela
	If oTEF:lHomolog
		lOpcao := MsgYesNo(STR0086, STR0005)						//"Primeira parcela a vista" ## Atenção
	Else
		lOpcao := (oTef:aRetCartao[oTef:nTrans]:dEntrada == dDataBase)
	EndIf
	oTef:aRetCartao[oTef:nTrans]:lAVista	:= lOpcao
	oTef:cBuffer							:= If(lOpcao,"0","1")
//Captura se é mês fechado (0) ou não (1)
ElseIf 	oTef:nTipoCampo ==509
	// Quando estiver fazendo a homologacao na Software Express, esta mensagem deve ser apresentada.
	// Em producao SEMPRE considerar como mes fechado (Mes de 30 dias. As parcelas cairao sempre na mesma data)
	If oTEF:lHomolog
		lOpcao := MsgYesNo(STR0088, STR0005)					//"Considera mês fechado" ## Atenção
	EndIf
	oTef:aRetCartao[oTef:nTrans]:lAVista	:= lOpcao
	oTef:cBuffer							:= If(lOpcao,"0","1")
Else 
	LJTefDisp( , , ,AllTrim(oTef:cBuffer))
	If MsgYesNo( AllTrim(oTef:cBuffer) , STR0005 ) 		//Mensagem ## Atenção
		If oTef:nProxcoman == 20 .AND. oTef:nCodFuncao == 900 ;
		   .AND. UPPER(Alltrim(SUBSTR(oTef:cBuffer,54,28))) == "DESEJA PAGAR MAIS UM BOLETO?" //Optou por multiplos Pagamentos, cria uma nova dimensão no aRetCorresp
			oTef:nTransCB += 1
			Aadd(oTef:aRetCorresp,{})
			oTef:aRetCorresp[oTef:nTransCB] := MSRetCorresp():New()
		EndIf
		oTef:cBuffer	:= "0"							//Sim
		oTef:nContNaveg	:= 0
	Else
		oTef:cBuffer	:= "1"							//Não
		oTef:nContNaveg	:= 0
	EndIf
EndIf				

oTef:nTamMaxBuffer	:= Len(Alltrim(oTef:cBuffer))

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjTEFSele ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara os objetos a serem exibidos em tela para selecao   º±±
±±º          ³ do operador de caixa                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFSele()
Local cOpcoes		:= AllTrim(oTef:cBuffer)					//Opcoes para selecao
Local cValor    	:= Space(At(":",cOpcoes))					//Inicia o campo a ser coletado no processo
Local nFor 			:= 0										//Controle de loop
Local cString		:= ""										//Controle para leitura do retorno da DLL
Local cExibir		:= ""										//Sring a ser exibida para o usuário
Local nSizeGet		:= GetTextWidth(0,Repl("M",Len(cValor)))	//Monta o tamanho exato da largura do campo para digitação
Local lUsaDisplay	:= !Empty(LjGetStation("DISPLAY"))				// Verifica se a estacao possui Display

oTef:aValid	:= {}												//Armazena as inf. válidas na digitação do operador

LjTEFDisp(oMens:cCaption, cOpcoes)

//Acertar o tamanho da Get para o limite da Tela
nSizeGet := If(nSizeGet>600,600,If(nSizeGet<20,20,nSizeGet))

//Tratando as opcoes a selecionar e suas validações
For nFor := 1 To Len(cOpcoes)
	If SubStr(cOpcoes,nFor,1) == ":"
	   Aadd(oTef:aValid,cString)
 	   cString += SubStr(cOpcoes,nFor,1)
	ElseIf SubStr(cOpcoes,nFor,1) == ";"
	   cString := ""
	Else
		cString += SubStr(cOpcoes,nFor,1)
	EndIf
Next nFor

cExibir	 := StrTran(cOpcoes,";",Chr(10))

//Habilita os objetos necessarios para o processo de selecao a partir da lista
LjTEFObj(.F.,"S")

//Tratamento para o Get da Tela
If !lUsaDisplay
	oTef:cGet		:= cValor
Else
	// Caso o usuario estiver usando o display ele jah digitou 
	oTef:cGet		:= PADR(oTef:cGet, At(":",cOpcoes))
Endif
oGet:nWidth		:= nSizeGet

//Lista de Opções para selecionamento
oSay:cCaption	:= cExibir

//Aciono o foco no objeto a ser digitado
oGet:SetFocus()

If lUsaDisplay
	// Jah digitado pelo teclado do display
	If !Empty(oGet:cText)
		LjTEFProc("C")
	Else
		// Nenhuma opcao digitada a transacao eh encerrada
		LjTEFProc("E")
	Endif
Endif

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjTEFDigi ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aciona os gets e objetos a serem exibidos para o operador  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFDigi(cValor,nValor)
Local cCaption	:= AllTrim(oTef:cBuffer)						//Informacao a ser exibido ao operador de caixa	
Local nSizeGet	:= GetTextWidth(0,Repl("M",oTef:nTamMax))		//Monta o tamanho exato da largura do campo para digitação
Local lCmc7Cb	:= SuperGetMv("MV_LJLECB",,.F.)				//Utilizado para habilitar a leitura do documento atraves do cmc7 da impressora fiscal

Default cValor	:= Space(oTef:nTamMax)							//Inicializa a variável a ser digitada
Default nValor	:= Round(0,2)

LjTEFDisp(oTef:cBuffer, ,nValor)

//Acertar o tamanho da Get para o limite da Tela
nSizeGet := If(nSizeGet>600,600,If(nSizeGet<20,20,nSizeGet))

//Aciona os objetos na tela de acordo com a funcao
LjTEFObj(.F.,"D")

//Tratamento para exibição da informacao na Tela
oMens:cCaption		:= cCaption

If oTef:nProxComan==34					//Campo com valor Monetário
	oTef:vGet		:= nValor
	oGetV:SetFocus()
ElseIf oTef:nProxComan==35 				//Coleta do Código de Barras
	oTef:cGet		:= cValor
	oGet:nWidth		:= nSizeGet
	oGet:SetFocus()           
	
    If lUsaCMC7 .AND. lCmc7Cb                       
        oTef:LeCodBar(@oTef:cGet)    
    EndIf                            
    
Else									//Campo caracter
	//Indica que o campo em questão é o código do supervisor. A automação, pode, se desejado, validar os dados coletados, deixando o fluxo da transação seguir normalmente caso seja um supervisor aceitável
	If oTEF:nTipoCampo == 500
		oGet:lPassword	:= .T.
	EndIf
	oTef:cGet		:= cValor
	oGet:Picture	:= "@X"
	oGet:nWidth		:= nSizeGet
	oGet:SetFocus()
EndIf	
                                           
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFMensaºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.	 ³ Esta função carrega as strings pré-estabelecidas pelo SiTEFº±±
±±º          ³ no retorno das funções                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFMensa(cOpc)											  º±±
±±º          ³ cOpc - Codigo da tabela a carregar (Especificacao Sitef)	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFMensa(cOpc)
Local aRet	:= {}			//Array com as mensagens disponibilizadas pela Software Express

If cOpc == "A" 		//Abertura de Terminal
	//Tabela de Retornos da Software Express
	Aadd(aRet,{0,STR0011})		//"Não ocorreu erro"
	Aadd(aRet,{1,STR0012})		//"Endereço IP inválido ou não resolvido"
	Aadd(aRet,{2,STR0013})		//"Código da loja inválido"
	Aadd(aRet,{3,STR0014})		//"Código de terminal invalido"
	Aadd(aRet,{6,STR0015})		//"Erro na inicialização do Tcp/Ip"
	Aadd(aRet,{7,STR0016})		//"Falta de memória"
	Aadd(aRet,{8,STR0017})		//"Não encontrou a CliSiTEF ou ela está com problemas"
ElseIf cOpc == "I" 	//Inicialização da transação
	//Tabela de Retornos da Software Express
	Aadd(aRet,{-1,STR0019})		//"módulo não inicializado"
	Aadd(aRet,{-2,STR0020}) 	//"operação cancelada pelo operador"
	Aadd(aRet,{-3,STR0021}) 	//"fornecida uma modalidade inválida"
	Aadd(aRet,{-4,STR0022}) 	//"falta de memória para rodar a função"
	Aadd(aRet,{-5,STR0023})		//"sem comunicação com o SiTEF"
	Aadd(aRet,{-6,STR0135})		//"Operação cancelada pelo usuário"
	// VidaLink
	Aadd(aRet,{-110,STR0040})	//"Lista de produtos desatualizada (código de autorização utilizado na consulta ao produto difere do código de autorização utilizado na chamada que obteve os produtos da Vidalink)"
	Aadd(aRet,{-111,STR0041}) 	//"Código do produto não encontrado na lista de produtos devolvida pela Vidalink"
	Aadd(aRet,{-112,STR0042}) 	//"Índice do produto inválido (zero ou maior que o índice anterior mais 1)"
ElseIf cOpc == "P"
	Aadd(aRet,{1 ,STR0032})		//Existe um PinPad operacional conectado ao micro
	Aadd(aRet,{0 ,STR0033}) 	//Não existe um PinPad conectado ao micro
	Aadd(aRet,{-1,STR0034}) 	//Biblioteca de acesso ao PinPad não encontrada
ElseIf cOpc == "V"	//VidaLink
	Aadd(aRet,{-110,STR0040})	//"Lista de produtos desatualizada (código de autorização utilizado na consulta ao produto difere do código de autorização utilizado na chamada que obteve os produtos da Vidalink)"
	Aadd(aRet,{-111,STR0041}) 	//"Código do produto não encontrado na lista de produtos devolvida pela Vidalink"
	Aadd(aRet,{-112,STR0042}) 	//"Índice do produto inválido (zero ou maior que o índice anterior mais 1)"
EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFLeBufºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Trata o buffer devolvido pela Autom.Dll                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFLeBuf(cTemp)										  º±±
±±º          ³ cExp1 - Buffer devolvido									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFLeBuf(cTemp)

//Tratando o retorno da DLL	que nos devolve sempre strings
cTemp 			:= AllTrim(oAutocom:cBuffer)
oTef:nProxComan	:= Val(Substr(cTemp,1,At(Chr(1),cTemp)-1))
cTemp 			:= Iif(At(Chr(1),cTemp)>0,Substr(cTemp,At(Chr(1),cTemp)+1,Len(cTemp)),Substr(cTemp,1,At(Chr(0),cTemp)-1))
oTef:nTipoCampo	:= Val(Substr(cTemp,1,At(Chr(1),cTemp)-1))
cTemp 			:= Iif(At(Chr(1),cTemp)>0,Substr(cTemp,At(Chr(1),cTemp)+1,Len(cTemp)),Substr(cTemp,1,At(Chr(0),cTemp)-1))
oTef:nTamMin	:= Val(Substr(cTemp,1,At(Chr(1),cTemp)-1))
cTemp 			:= Iif(At(Chr(1),cTemp)>0,Substr(cTemp,At(Chr(1),cTemp)+1,Len(cTemp)),Substr(cTemp,1,At(Chr(0),cTemp)-1))
oTef:nTamMax	:= Val(Substr(cTemp,1,At(Chr(1),cTemp)-1))
cTemp 			:= Iif(At(Chr(1),cTemp)>0,Substr(cTemp,At(Chr(1),cTemp)+1,Len(cTemp)),Substr(cTemp,1,At(Chr(0),cTemp)-1))
	
//Verificar se o último retorno é simplesmente o buffer
If At(Chr(1),cTemp)==0
	oTef:cBuffer		:= Substr(cTemp,1,At(Chr(0),cTemp)-1)
	oTef:nTamMaxBuffer	:= Len(AllTrim(oTef:cBuffer))
Else
	oTef:cBuffer		:= Substr(cTemp,1,At(Chr(1),cTemp)-1)
	cTemp 				:= Iif(At(Chr(1),cTemp)>0,Substr(cTemp,At(Chr(1),cTemp)+1,Len(cTemp)),Substr(cTemp,1,At(Chr(0),cTemp)-1))
	oTef:nTamMaxBuffer	:= Val(Substr(cTemp,1,At(Chr(1),cTemp)-1))
	cTemp 				:= Iif(At(Chr(1),cTemp)>0,Substr(cTemp,At(Chr(1),cTemp)+1,Len(cTemp)),Substr(cTemp,1,At(Chr(0),cTemp)-1))
	oTef:nContNaveg		:= Val(Substr(cTemp,1,At(Chr(1),cTemp)-1))
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFTrataºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua o tratamento das inf. devolvidas pela CLISITEF      º±±
±±º          ³ durante o processo de continucao interativa                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFTrata()

Local nI 		:= 0						//Variav. usada em lacos For..Next
Local cSimb1    := SuperGetMV("MV_SIMB1")  //Variavel que retorna o simbolo da moeda 
Local cBandTef	:= ""

//Não existem informações que podem/devem ser tratadas pela automação
If 	oTef:nTipoCampo == -1
	//Desprezar
	
//A rotina está sendo chamada para indicar que acabou de coletar os dados da transação e irá iniciar a interação com o SiTEF para obter a autorização
ElseIf 	oTef:nTipoCampo == 0
	//Desprezar
	
//Não consta na especificação técnica
ElseIf 	oTef:nTipoCampo == 1
	//Desprezar
	
//Informa qual a opção selecionada no menu de navegação de transações seguindo a mesma codificação utilizada para definir as restrições no pagamento descritas no item 5
ElseIf 	oTef:nTipoCampo>=10 .AND. oTef:nTipoCampo<=99
	oTef:nCodTrans 	:= oTef:nTipoCampo
		
//Contém a modalidade de pagamento no formato xxnn xx corresponde ao grupo da modalidade e nn ao sub-grupo. Vide tabela no final deste documento descrevendo os possíveis valores de xx e nn.
ElseIf 	oTef:nTipoCampo ==100 .OR. ;
	oTef:nTipoCampo ==110			//Contém a modalidade de cancelamento no formato xxnn xx corresponde ao grupo da modalidade e nn ao sub-grupo. Vide tabela no final deste documento descrevendo os possíveis valores de xx e nn. Retorna quando uma transação for cancelada

	If SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "00"			//Cheque
		oTef:aRetCartao[oTef:nTrans]:cForma 		:= AllTrim(MVCHEQUE)
	ElseIf SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) $ "01;03" 	//Debito ou Voucher (Visa Vale)
		oTef:aRetCartao[oTef:nTrans]:cForma 		:= "CD"
	ElseIf SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "02" 	//Credito		
		oTef:aRetCartao[oTef:nTrans]:cForma 		:= "CC"
	ElseIf SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "98" 	//Dinheiro
		oTef:aRetCartao[oTef:nTrans]:cForma 		:= cSimb1
	ElseIf SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "99" 	//Carteira Virtual
		oTef:aRetCartao[oTef:nTrans]:cForma 		:= "CV"
	Else
		oTef:aRetCartao[oTef:nTrans]:cForma 		:= "99"
	EndIf

	//Tipo de parcelamento
	oTef:aRetCartao[oTef:nTrans]:lJurLoja 			:= If(SubStr(AllTrim(Upper(oTef:cBuffer)),3,2)=="02",.T.,.F.)

//Contém o texto real da modalidade de pagamento que pode ser memorizado pela aplicação caso exista essa necessidade. Descreve por extenso o par xxnn fornecido em 100
ElseIf 	oTef:nTipoCampo ==101	.OR. ;
	oTef:nTipoCampo ==111	//Contém o texto real da modalidade de cancelamento que pode ser memorizado pela aplicação caso exista essa necessidade. Descreve por extenso o par xxnn fornecido em 110
	oTef:aRetCartao[oTef:nTrans]:cDescTipPg 		:= AllTrim(Upper(oTef:cBuffer))

//Contém o texto descritivo da modalidade de pagamento que deve ser impresso no cupon fiscal (p/ex: T.E.F., Cheque, etc...)
ElseIf 	oTef:nTipoCampo ==102
	oTef:aRetCartao[oTef:nTrans]:cDescCupPg 		:= AllTrim(Upper(oTef:cBuffer))

//Contém a data e hora da transação no formato AAAAMMDDHHMMSS
ElseIf 	oTef:nTipoCampo ==105
  	If oTef:nCodFuncao == 903
     	oTef:aRetVidaLink:cHoraTrans			        := SubStr(oTef:cBuffer,9,6) 
    ElseIf oTef:nCodFuncao == 838            //DOTZ
		oTef:aRetDotz[oTef:nTrans]:dDataTrans 		:= CtoD(SubStr(oTef:cBuffer,7,2)+"/"+SubStr(oTef:cBuffer,5,2)+"/"+SubStr(oTef:cBuffer,1,4))
   		oTef:aRetDotz[oTef:nTrans]:cHoraTrans 		:= SubStr(oTef:cBuffer,9,6)	                    
    Else
   		oTef:aRetCartao[oTef:nTrans]:dDataTrans 		:= CtoD(SubStr(oTef:cBuffer,7,2)+"/"+SubStr(oTef:cBuffer,5,2)+"/"+SubStr(oTef:cBuffer,1,4))
   		oTef:aRetCartao[oTef:nTrans]:cHoraTrans 		:= SubStr(oTef:cBuffer,9,6)
    EndIf

ElseIf 	oTef:nTipoCampo == 106 .AND. oTef:nCodFuncao == 122 // Campo utilizado quando Carteira Virtual
		oTef:aRetCartao[oTef:nTrans]:cNsuSitef	:= AllTrim(oTef:cBuffer)
		oTef:aRetCartao[oTef:nTrans]:cTipCart	:= "CARVR"

ElseIf 	oTef:nTipoCampo == 107 .AND. oTef:nCodFuncao == 122 // Campo utilizado quando Carteira Virtual
	    oTef:aRetCartao[oTef:nTrans]:cDescRede 	:=  AllTrim(oTef:cBuffer)
		oTef:aRetCartao[oTef:nTrans]:cDescAdm  	:=  AllTrim(oTef:cBuffer)

//Contém dados adicionais relativos ao cartão utilizado na operação de TEF. O formato deste campo é uma seqüência de códigos separados por ponto-e-virgula. Por enquanto o único código que retorna é a palavra EE para indicar que o cartão utilizado foi um EasyEntry ou EMV para indicar um cartão EMV. Caso tenha sido um cartão normal, esse tipo de campo não é retornado para a aplicação
ElseIf 	oTef:nTipoCampo ==112
	oTef:aRetCartao[oTef:nTrans]:cAdiCart 			:= Upper(oTef:cBuffer)

//Buffer contém a linha de autenticação do cheque para ser impresso no verso do mesmo
ElseIf 	oTef:nTipoCampo ==120
	oTef:aRetCartao[oTef:nTrans]:cAutentic 			:= oTef:cBuffer

//Buffer contém a primeira via do comprovante de pagamento (via do cliente) a ser impressa na impressora fiscal. Essa via, quando possível, é reduzida de forma a ocupar poucas linhas na impressora. Pode ser um comprovante de venda ou administrativo
ElseIf 	oTef:nTipoCampo ==121
	If oTef:nCodFuncao == 900													//CORRESPONDENTE BANCARIO
		oTef:aRetCorresp[oTef:nTrans]:cComprov01	:= AllTrim(oTef:cBuffer)
	ElseIf oTef:nCodFuncao == 838                                              //DOTZ
		oTef:aRetDotz[oTef:nTrans]:cCupom01	:= AllTrim(oTef:cBuffer)	   
	ElseIf oTef:nCodFuncao == 300 .OR. oTef:nCodFuncao == 301					//RECARGA DE CELULAR
		oTef:aRetRecarga[oTef:nTrans]:cComprov		:= AllTrim(oTef:cBuffer)
	ElseIf oTef:nCodFuncao == 669 .OR. oTef:nCodFuncao == 264 //Recarga de Gift Card (669=Modulo Givex; 264=Modulo SQCF - Todo Cartoes)
		oTef:aRetRecCP[oTef:nTransCP]:cComprov		:= AllTrim(oTef:cBuffer)
		oTef:aRetRecCP[oTef:nTransCP]:cSeqControl	:= AllTrim(oTef:cCupom)
	ElseIf 	(oTEF:nCodFuncao >= 902 .AND. oTEF:nCodFuncao <= 904 ).OR.; 			// VIDALINK
			(oTEF:nCodFuncao >= 560 .AND. oTEF:nCodFuncao <= 563 ).OR.;				// FUNCIONAL CARD	
			(oTEF:nCodFuncao >= 543 .AND. oTEF:nCodFuncao <= 545 )					// PHARMASYSTEM															
		oTEF:aRetVidaLink:cCupom01					:= AllTrim(oTef:cBuffer)
	Else																		//TRANSACAO DE CARTAO
		oTef:aRetCartao[oTef:nTrans]:cCupom01		:= oTef:cBuffer	
	EndIf			

//Buffer contém a segunda via do comprovante de pagamento (via do caixa) a ser impresso na impressora fiscal. Pode ser um comprovante de venda ou administrativo
ElseIf 	oTef:nTipoCampo ==122
	If oTef:nCodFuncao == 900 .AND. LJGetStation("TEFVIAS") == 2               //CORRESPONDENTE BANCARIO   
		oTef:aRetCorresp[oTef:nTransCB]:cComprov02	:= AllTrim(oTef:cBuffer) 
	ElseIf oTef:nCodFuncao == 838                                              //DOTZ
		oTef:aRetDotz[oTef:nTrans]:cCupom02	:= AllTrim(oTef:cBuffer)		  
	ElseIf 	(oTEF:nCodFuncao >= 902 .AND. oTEF:nCodFuncao <= 904 ).OR.; 			// VIDALINK
			(oTEF:nCodFuncao >= 560 .AND. oTEF:nCodFuncao <= 563 ).OR.;				// FUNCIONAL CARD	
			(oTEF:nCodFuncao >= 543 .AND. oTEF:nCodFuncao <= 545 )					// PHARMASYSTEM	
		oTEF:aRetVidaLink:cCupom02					:= AllTrim(oTef:cBuffer)
	ElseIf oTef:nCodFuncao == 300	.OR. oTef:nCodFuncao == 301					//RECARGA DE CELULAR
		oTef:aRetRecarga[oTef:nTrans]:cComprov		:= AllTrim(oTef:cBuffer)
	Else
		oTef:aRetCartao[oTef:nTrans]:cCupom02		:= oTef:cBuffer	
	EndIf

//Indica, na coleta, que o campo em questão é o valor do troco em dinheiro a ser devolvido para o cliente. Na devolução de resultado (Comando = 0) contém o valor efetivamente aprovado para o troco
ElseIf 	oTef:nTipoCampo ==130
	If oTEF:nCodFuncao == 900												// CORRESPONDENTE BANCARIO
		oTef:aRetCorresp[oTef:nTransCB]:nVlrTroco		:= Round(Val(oTef:cBuffer),2)
	Else
		oTef:aRetCartao[oTef:nTrans]:nVlrTroco		:= Round(Val(oTef:cBuffer),2)
	EndIf

//Contém um índice que indica qual a instituição que irá processar a transação segundo a tabela presente no final do documento (5 posições)
ElseIf 	oTef:nTipoCampo ==131
	oTef:aRetCartao[oTef:nTrans]:cCodRede 	:= AllTrim(oTef:cBuffer)
	nPos := Ascan(oTEF:aRedes, { |x| x[1]==AllTrim(oTef:cBuffer) } )
	If nPos == 0
		nPos := 1
	EndIf

	// Assume a rede como administradora financeira, pois cartao de debito nao possui esta informacao
	If oTef:nCodFuncao == 900    	//CORRESPONDENTE BANCARIO
		oTef:aRetCorresp[oTef:nTransCB]:cDescAdm	 		:= oTef:aRedes[nPos][2]
	ElseIf oTef:nCodFuncao == 838                                              //DOTZ
		oTef:aRetDotz[oTef:nTrans]:cDescAdm	:= AllTrim(oTef:cBuffer)	
	ElseIf oTef:nCodFuncao == 300   //RECARGA DE CELULAR
		oTef:aRetRecarga[oTef:nTrans]:cDescAdm	 		:= oTef:aRedes[nPos][2]
	ElseIf oTef:nCodFuncao == 903  //VIDALINK
	    oTef:aRetVidalink:cDescAdm                      := " "	
	ElseIf oTef:nCodFuncao <> 122 //TRANSACAO DE CARTAO
		oTef:aRetCartao[oTef:nTrans]:cDescRede 	:= oTef:aRedes[nPos][2]
	EndIf

//Contém um índice que indica qual o tipo do cartão quando esse tipo for identificável, segundo uma tabela a ser fornecida (5 posições)
ElseIf 	oTef:nTipoCampo ==132

	oTef:aRetCartao[oTef:nTrans]:cTipCart := AllTrim(oTef:cBuffer)

	If AllTrim(oTef:cBuffer) <> "00000"

		nPos := Ascan(oTEF:aAdm, { |x| x[1]==AllTrim(oTef:cBuffer) } )
		If nPos == 0
			nPos := 1
		EndIf
		If oTef:nCodFuncao == 900    	//CORRESPONDENTE BANCARIO
			oTef:aRetCorresp[oTef:nTransCB]:cDescAdm	 		:= oTef:aAdm[nPos][2]
		ElseIf oTef:nCodFuncao == 300   //RECARGA DE CELULAR
			oTef:aRetRecarga[oTef:nTrans]:cDescAdm	 		:= oTef:aAdm[nPos][2]
		ElseIf oTef:nCodFuncao == 903  //TRANSACAO VIDALINK
		    oTef:aRetVidalink:cDescAdm                      := " "
		Else							//TRANSACAO DE CARTAO
			cBandTef := oTef:aAdm[nPos][2]
			
			If oTef:aRetCartao[oTef:nTrans]:cForma == "CD"      // Se for debito procura no aAdmCD
				nPos := Ascan(oTef:aAdmCD, { |x| x[1]==AllTrim(oTef:cBuffer)}) 
				If nPos > 0
					cBandTef := oTef:aAdmCD[nPos][2]
				EndIf
			EndIf
			
			oTef:aRetCartao[oTef:nTrans]:cDescAdm	 		:= cBandTef
        EndIf
   EndIf

//Contém o NSU do SiTEF (6 posições)
ElseIf 	oTef:nTipoCampo ==133
	If oTef:nCodFuncao == 903 .OR. oTef:nCodFuncao == 545 
    	oTef:aRetVidaLink:cNsuSitef			            := AllTrim(oTef:cBuffer)
	ElseIf oTef:nCodFuncao == 838                                              //DOTZ
		oTef:aRetDotz[oTef:nTrans]:cNsuSitef	:= AllTrim(oTef:cBuffer)		
    Else
		oTef:aRetCartao[oTef:nTrans]:cNsuSitef 			:= AllTrim(oTef:cBuffer)
    EndIf

//Contém o NSU do Host autorizador (15 posições no máximo)
ElseIf 	oTef:nTipoCampo ==134
	If oTef:nCodFuncao == 903 .OR. oTef:nCodFuncao == 545
       oTef:aRetVidaLink:cNsuAutor			            := AllTrim(oTef:cBuffer)
    ElseIf oTef:nCodFuncao == 838                                              //DOTZ
		oTef:aRetDotz[oTef:nTrans]:cNsuAutor	:= AllTrim(oTef:cBuffer)   
    Else     
   		oTef:aRetCartao[oTef:nTrans]:cNsuAutor			:= AllTrim(oTef:cBuffer)
    EndIf 

//Contém o Código de Autorização para as transações de crédito (15 posições no máximo)
ElseIf 	oTef:nTipoCampo ==135
	If oTef:nCodFuncao == 903 .OR. oTef:nCodFuncao == 545
		oTef:aRetVidaLink:cAutoriza				        := AllTrim(oTef:cBuffer)
	ElseIf oTef:nCodFuncao == 838                                              //DOTZ
		oTef:aRetDotz[oTef:nTrans]:cAutoriza	:= AllTrim(oTef:cBuffer) 	
	Else
   		oTef:aRetCartao[oTef:nTrans]:cAutoriza			:= AllTrim(oTef:cBuffer)
    EndIf

//Contém as 6 primeiras posições do cartão (bin)
ElseIf 	oTef:nTipoCampo ==136
	oTef:aRetCartao[oTef:nTrans]:cPosCart			:= AllTrim(oTef:cBuffer)

//Saldo a pagar Dotz	
ElseIf 	oTef:nTipoCampo == 137
	oTef:aRetDotz[oTef:nTrans]:nVlrSaldoDotz	:= Val(StrTran(oTef:cBuffer,",","."))
//Valor resgatado no Dotz	
ElseIf 	oTef:nTipoCampo == 138
	oTef:aRetDotz[oTef:nTrans]:nVlrResDotz		:= Val(StrTran(oTef:cBuffer,",","."))
	
// Data da primeira parcela
ElseIf 	oTef:nTipoCampo ==140
	oTef:aRetCartao[oTef:nTrans]:DENTRADA			:= CTOD(Substr(oTef:cBuffer,1,2)+"/"+Substr(oTef:cBuffer,3,2)+"/"+Substr(oTef:cBuffer,5,4))

//Os campos 141 e 142 são chamados n vezes onde n = conteúdo do campo 140
//Data da parcela no formato aaaammdd
ElseIf	oTef:nTipoCampo ==141
	Aadd(oTef:aRetCartao[oTef:nTrans]:aDatas,CtoD(SubStr(AllTrim(oTef:cbuffer),7,2)+SubStr(AllTrim(oTef:cbuffer),5,2)+SubStr(AllTrim(oTef:cbuffer),1,4)))

//Os campos 141 e 142 são chamados n vezes onde n = conteúdo do campo 140
//Valor da parcela
ElseIf 	oTef:nTipoCampo ==142
	Aadd(oTef:aRetCartao[oTef:nTrans]:aValores,Round(Val(oTef:cBuffer),2))

//Data do Pré-datado no formato aaaammdd
ElseIf 	oTef:nTipoCampo ==145
	Aadd(oTef:aRetCartao[oTef:nTrans]:aDatas,CtoD(SubStr(AllTrim(oTef:cbuffer),7,2)+SubStr(AllTrim(oTef:cbuffer),5,2)+SubStr(AllTrim(oTef:cbuffer),1,4)))
	oTef:aRetCartao[oTef:nTrans]:dEntrada := CtoD(SubStr(AllTrim(oTef:cbuffer),7,2)+SubStr(AllTrim(oTef:cbuffer),5,2)+SubStr(AllTrim(oTef:cbuffer),1,4))

//A rotina está sendo chamada para ler o Valor a ser cancelado. Caso o aplicativo de automação possua esse valor, pode apresentá-lo para o operador e permitir que ele confirme o valor antes de passá-lo devolvê-lo para a rotina. Caso ele não possua esse valor, deve lê-lo.
ElseIf 	oTef:nTipoCampo ==146
	oTef:aRetCartao[oTef:nTrans]:nVlrCanc			:= Val(oTef:cBuffer)

//Contém a Trilha 1, quando disponível, obtida na função LeCartaoInterativo
ElseIf 	oTef:nTipoCampo ==150
	oTef:aRetCartao[oTef:nTrans]:cTrilha1			:= AllTrim(oTef:cBuffer)

//Contém a Trilha 2, quando disponível, obtida na função LeCartaoInterativo
ElseIf 	oTef:nTipoCampo ==151
	oTef:aRetCartao[oTef:nTrans]:cTrilha2			:= AllTrim(oTef:cBuffer)

//Contem a senha do cliente capturada através da rotina LeSenhaInterativo e que deve ser passada a lib de segurança da Software Express personalizada para o estabelecimento comercial de forma a obter a senha aberta
ElseIf 	oTef:nTipoCampo ==153
	oTef:aRetCartao[oTef:nTrans]:cSenha				:= AllTrim(oTef:cBuffer)

//Indica que o campo em questão é o código do supervisor. A automação, pode, se desejado, validar os dados coletados, deixando o fluxo da transação seguir normalmente caso seja um supervisor aceitável
ElseIf 	oTef:nTipoCampo ==500

//Tipo do Documento a ser consultado (0 - CPF, 1 - CGC)
ElseIf 	oTef:nTipoCampo ==501
	oTef:aRetCartao[oTef:nTrans]:cTipDoc			:= If(AllTrim(oTef:cBuffer)=="0","CPF","CGC")

ElseIf 	oTef:nTipoCampo ==156			// Retorna uma string com o nome do cartao passado no pinpad
	If ValType (oTef:aRetCartao) == "A" .AND. Len(oTef:aRetCartao) > 0  // Proteção para VidaLink
		oTef:aRetCartao[oTef:nTrans]:cDescCart			:= AllTrim(oTef:cBuffer)
	Endif	

//Numero do documento (CPF ou CGC)
ElseIf 	oTef:nTipoCampo ==502 
	oTef:aRetCartao[oTef:nTrans]:cNumDoc			:= AllTrim(oTef:cBuffer)
	
//Número do Telefone
ElseIf 	oTef:nTipoCampo ==503
	oTef:aRetCartao[oTef:nTrans]:cTelefone			:= AllTrim(oTef:cBuffer)
			
//Taxa de Serviço
ElseIf 	oTef:nTipoCampo ==504
	oTef:aRetCartao[oTef:nTrans]:nTaxa				:= Round(Val(oTef:cBuffer),2)

//Número de Parcelas
ElseIf 	oTef:nTipoCampo ==505 .AND. oTEF:nCodFuncao <> 122
	oTef:aRetCartao[oTef:nTrans]:nParcelas			:= Val(oTef:cBuffer)
	
//Data do Pré-datado
ElseIf 	oTef:nTipoCampo ==506
	Aadd(oTef:aRetCartao[oTef:nTrans]:aDatas,CtoD(SubStr(AllTrim(oTef:cbuffer),7,2)+SubStr(AllTrim(oTef:cbuffer),5,2)+SubStr(AllTrim(oTef:cbuffer),1,4)))
	oTef:aRetCartao[oTef:nTrans]:dEntrada := CtoD(SubStr(AllTrim(oTef:cbuffer),7,2)+SubStr(AllTrim(oTef:cbuffer),5,2)+SubStr(AllTrim(oTef:cbuffer),1,4))
	
//Captura se a primeira parcela é a vista ou não (0 - Primeira a vista, 1 - caso contrário)
ElseIf 	oTef:nTipoCampo ==507
	oTef:aRetCartao[oTef:nTrans]:lAvista			:= If(AllTrim(oTef:cBuffer)=="0",.T.,.F.)

//Intervalo em dias entre parcelas
ElseIf 	oTef:nTipoCampo ==508
	oTef:aRetCartao[oTef:nTrans]:nIntervalo			:= Val(oTef:cBuffer)
	
//Captura se é mês fechado (0) ou não (1)
ElseIf 	oTef:nTipoCampo ==509
	oTef:aRetCartao[oTef:nTrans]:lMesFechado		:= If(AllTrim(oTef:cBuffer)=="0",.T.,.F.)
	
//Captura se é com (0) ou sem (1) garantia no pré-datado com cartão de débito
ElseIf 	oTef:nTipoCampo ==510
	oTef:aRetCartao[oTef:nTrans]:lGarantido			:= If(AllTrim(oTef:cBuffer)=="0",.T.,.F.)
	
//Número de Parcelas CDC
ElseIf 	oTef:nTipoCampo ==511
	oTef:aRetCartao[oTef:nTrans]:nParcelas			:= Val(oTef:cBuffer)
	
//Número do Cartão de Crédito Digitado
ElseIf 	oTef:nTipoCampo ==512
	oTef:aRetCartao[oTef:nTrans]:cCartao			:= AllTrim(oTef:cBuffer)
	
//Data de vencimento do Cartão
ElseIf 	oTef:nTipoCampo ==513
	oTef:aRetCartao[oTef:nTrans]:cVencCartao		:= AllTrim(oTef:cBuffer)	

//Código de segurança do Cartão
ElseIf 	oTef:nTipoCampo ==514
	oTef:aRetCartao[oTef:nTrans]:cCegCartao			:= AllTrim(oTef:cBuffer)	
	
//Data da transação a ser cancelada (DDMMAAAA) ou a ser re-impressa
ElseIf 	oTef:nTipoCampo ==515
  	oTef:aRetCartao[oTef:nTrans]:dDataCanRei		:= CtoD(SubStr(oTef:cBuffer,7,2)+"/"+SubStr(oTef:cBuffer,5,2)+"/"+SubStr(oTef:cBuffer,1,4))
	  		
//Número do documento a ser cancelado ou a ser re-impresso
ElseIf 	oTef:nTipoCampo ==516
  	oTef:aRetCartao[oTef:nTrans]:cDocCanRei			:= AllTrim(oTef:cBuffer)
	
//A rotina está sendo chamada para ler o Número do cheque segundo o descrito no tipo de comando correspondente ao valor 31
ElseIf 	oTef:nTipoCampo ==517
	If oTef:nCodFuncao == 900    	//CORRESPONDENTE BANCARIO
		oTef:aRetCorresp[oTef:nTransCB]:cChqCom			:= SubStr(AllTrim(oTef:cBuffer),03,03)
		oTef:aRetCorresp[oTef:nTransCB]:cChqBco			:= SubStr(AllTrim(oTef:cBuffer),06,03)
		oTef:aRetCorresp[oTef:nTransCB]:cChqAge			:= SubStr(AllTrim(oTef:cBuffer),09,04)
		oTef:aRetCorresp[oTef:nTransCB]:cChqC1			:= SubStr(AllTrim(oTef:cBuffer),13,01)
		oTef:aRetCorresp[oTef:nTransCB]:cChqCta			:= SubStr(AllTrim(oTef:cBuffer),14,10)
		oTef:aRetCorresp[oTef:nTransCB]:cChqC2			:= SubStr(AllTrim(oTef:cBuffer),24,01)
		oTef:aRetCorresp[oTef:nTransCB]:cChqNum			:= SubStr(AllTrim(oTef:cBuffer),25,06)
		oTef:aRetCorresp[oTef:nTransCB]:cChqC3			:= SubStr(AllTrim(oTef:cBuffer),32,01)
	ElseIf oTef:nCodFuncao == 300   //RECARGA DE CELULAR
		oTef:aRetRecarga[oTef:nTrans]:cChqCom			:= SubStr(AllTrim(oTef:cBuffer),03,03)
		oTef:aRetRecarga[oTef:nTrans]:cChqBco			:= SubStr(AllTrim(oTef:cBuffer),06,03)
		oTef:aRetRecarga[oTef:nTrans]:cChqAge			:= SubStr(AllTrim(oTef:cBuffer),09,04)
		oTef:aRetRecarga[oTef:nTrans]:cChqC1			:= SubStr(AllTrim(oTef:cBuffer),13,01)
		oTef:aRetRecarga[oTef:nTrans]:cChqCta			:= SubStr(AllTrim(oTef:cBuffer),14,10)
		oTef:aRetRecarga[oTef:nTrans]:cChqC2			:= SubStr(AllTrim(oTef:cBuffer),24,01)
		oTef:aRetRecarga[oTef:nTrans]:cChqNum			:= SubStr(AllTrim(oTef:cBuffer),25,06)
		oTef:aRetRecarga[oTef:nTrans]:cChqC3			:= SubStr(AllTrim(oTef:cBuffer),32,01)
	Else							//TRANSACAO DE CARTAO
		oTef:aRetCartao[oTef:nTrans]:cChqCom			:= SubStr(AllTrim(oTef:cBuffer),03,03)
		oTef:aRetCartao[oTef:nTrans]:cChqBco			:= SubStr(AllTrim(oTef:cBuffer),06,03)
		oTef:aRetCartao[oTef:nTrans]:cChqAge			:= SubStr(AllTrim(oTef:cBuffer),09,04)
		oTef:aRetCartao[oTef:nTrans]:cChqC1				:= SubStr(AllTrim(oTef:cBuffer),13,01)
		oTef:aRetCartao[oTef:nTrans]:cChqCta			:= SubStr(AllTrim(oTef:cBuffer),14,10)
		oTef:aRetCartao[oTef:nTrans]:cChqC2				:= SubStr(AllTrim(oTef:cBuffer),24,01)
		oTef:aRetCartao[oTef:nTrans]:cChqNum			:= SubStr(AllTrim(oTef:cBuffer),25,06)
		oTef:aRetCartao[oTef:nTrans]:cChqC3				:= SubStr(AllTrim(oTef:cBuffer),32,01)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codificação dos campos utilizados na Recarga de Pré-pago ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
//Nome da Operadora de Celular selecionada para a operação
ElseIf 	oTef:nTipoCampo ==590
  	oTef:aRetRecarga[oTef:nTrans]:cOpera 			:= AllTrim(oTef:cBuffer)
	
//Valor selecionado para a recarga
ElseIf 	oTef:nTipoCampo ==591
  	oTef:aRetRecarga[oTef:nTrans]:nValor 			:= Round(Val(oTef:cBuffer),2)
	
//DDD + Número do celular a ser recarregado
ElseIf 	oTef:nTipoCampo ==592
  	oTef:aRetRecarga[oTef:nTrans]:cCelular 			:= AllTrim(oTef:cBuffer)
	
//Digito(s) verificadores
ElseIf 	oTef:nTipoCampo ==593
  	oTef:aRetRecarga[oTef:nTrans]:cDigitos 			:= AllTrim(oTef:cBuffer)
	
//Cep da localidade onde está o terminal no qual a operação está sendo feita
ElseIf 	oTef:nTipoCampo ==594
  	oTef:aRetRecarga[oTef:nTrans]:cCep				:= AllTrim(oTef:cBuffer)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codificação dos campos utilizados no Correspondente Bancário ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Data de vencimento do título/convênio no formato aaaammdd
ElseIf 	oTef:nTipoCampo ==600
	oTef:aRetCorresp[oTef:nTransCB]:dDataVenc			:= CtoD(SubStr(oTef:cBuffer,7,2)+"/"+SubStr(oTef:cBuffer,5,2)+"/"+SubStr(oTef:cBuffer,1,4))
	
//Valor Pago
ElseIf 	oTef:nTipoCampo ==601
	oTef:aRetCorresp[oTef:nTransCB]:nVlrPgto 			:= Round(Val(AllTrim(oTef:cBuffer))/100,2)
	
//Valor Original
ElseIf 	oTef:nTipoCampo ==602
	oTef:aRetCorresp[oTef:nTransCB]:nVlrOrig  		:= Round(Val(AllTrim(oTef:cBuffer))/100,2)
	
//Valor Acréscimo
ElseIf 	oTef:nTipoCampo ==603
	oTef:aRetCorresp[oTef:nTransCB]:nVlrAcre  		:= Round(Val(AllTrim(oTef:cBuffer))/100,2)
	
//Valor do Abatimento
ElseIf 	oTef:nTipoCampo ==604
	oTef:aRetCorresp[oTef:nTransCB]:nVlrAbat			:= Round(Val(AllTrim(oTef:cBuffer))/100,2)

//Data Contábil do Pagamento
ElseIf 	oTef:nTipoCampo ==605
	oTef:aRetCorresp[oTef:nTransCB]:dDataPgto 		:= CtoD(SubStr(oTef:cBuffer,7,2)+"/"+SubStr(oTef:cBuffer,5,2)+"/"+SubStr(oTef:cBuffer,1,4))
	oTef:aRetCorresp[oTef:nTransCB]:dDataPgto			:= If(Empty(oTef:aRetCorresp[oTef:nTransCB]:dDataPgto),dDataBase,oTef:aRetCorresp[oTef:nTransCB]:dDataPgto)

//Nome do Cedente do Titulo. Deve ser impresso no cheque quando o pagamento for feito via essa modalidade
ElseIf 	oTef:nTipoCampo ==606
	oTef:aRetCorresp[oTef:nTransCB]:cCedente 			:= AllTrim(oTef:cBuffer)
	
//Índice do documento, no caso do pagamento em lote, dos campos 600 a 604 que virão em seguida
ElseIf 	oTef:nTipoCampo ==607
	oTef:nTransCB := Val(AllTrim(oTef:cBuffer))
	oTef:aRetCorresp[oTef:nTransCB]:nOrdem   			:= Val(AllTrim(oTef:cBuffer))
	
//Modalidade de pagamento utilizada na função de correspondente bancário. Segue a mesma regra de formatação que o campo de número 100
ElseIf 	oTef:nTipoCampo ==608

	If SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "00"			//Cheque
		oTef:aRetCorresp[oTef:nTrans]:cForma 		:= AllTrim(MVCHEQUE)
	ElseIf SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "01" 	//Debito
		oTef:aRetCorresp[oTef:nTrans]:cForma 		:= "CD"
	ElseIf SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "02" 	//Credito		
		oTef:aRetCorresp[oTef:nTrans]:cForma 		:= "CC"
	ElseIf SubStr(AllTrim(Upper(oTef:cBuffer)),1,2) == "98" 	//Dinheiro
		oTef:aRetCorresp[oTef:nTrans]:cForma 		:= SuperGetMV("MV_SIMB1")
	Else
		oTef:aRetCorresp[oTef:nTrans]:cForma 		:= "99"
	EndIf
	
//Valor total dos títulos efetivamente pagos no caso de pagamento em lote
ElseIf 	oTef:nTipoCampo ==609
	oTef:aRetCorresp[oTef:nTrans]:nVlrLote 			:= Round(Val(AllTrim(oTef:cBuffer))/100,2)
	
//Valor total dos títulos não pagos no caso de pagamento em lote
ElseIf 	oTef:nTipoCampo ==610
	oTef:aRetCorresp[oTef:nTransCB]:nVlrNaoPago 		:= Round(Val(AllTrim(oTef:cBuffer))/100,2)
	
//NSU Correspondente Bancário
ElseIf 	oTef:nTipoCampo ==611
	oTef:aRetCorresp[oTef:nTransCB]:cNsuCB			:= AllTrim(oTef:cBuffer)		
	
//Tipo do documento: 0 ' Arrecadação, 1 ' Titulo (Ficha de compensação)
ElseIf 	oTef:nTipoCampo ==612
	oTef:aRetCorresp[oTef:nTrans]:cTipo				:= AllTrim(oTef:cBuffer)
	
//Contém os dados do cheque utilizado para efetuar o pagamento das contas no seguinte formato: Compensação (3), Banco (3), Agencia (4), ContaCorrente (10), e Numero do Cheque (6), nesta ordem. Notar que a ordem é a mesma presente na linha superior do cheque sem os dígitos verificadores
ElseIf 	oTef:nTipoCampo ==613
	oTef:aRetCorresp[oTef:nTrans]:cChqCom			:= SubStr(AllTrim(oTef:cBuffer),04,03)
	oTef:aRetCorresp[oTef:nTrans]:cChqBco			:= SubStr(AllTrim(oTef:cBuffer),07,03)
	oTef:aRetCorresp[oTef:nTrans]:cChqAge			:= ""
	oTef:aRetCorresp[oTef:nTrans]:cChqC1			:= ""
	oTef:aRetCorresp[oTef:nTrans]:cChqCta			:= SubStr(AllTrim(oTef:cBuffer),21,10)
	oTef:aRetCorresp[oTef:nTrans]:cChqC2			:= ""
	oTef:aRetCorresp[oTef:nTrans]:cChqNum			:= SubStr(AllTrim(oTef:cBuffer),14,06)
	oTef:aRetCorresp[oTef:nTrans]:cChqC3			:= ""
	
//NSU SiTEF transação de pagamento
ElseIf 	oTef:nTipoCampo ==614
	oTef:aRetCorresp[oTef:nTrans]:cNsuPg			:= AllTrim(oTef:cBuffer)
	
//NSU SiTEF da transação original (transação de cancelamento)
ElseIf 	oTef:nTipoCampo ==620
	oTef:aRetCorresp[oTef:nTrans]:cNsuCancCB		:= AllTrim(oTef:cBuffer)		
	
//NSU Correspondente Bancário da transação original (transação de cancelamento)
ElseIf 	oTef:nTipoCampo ==621	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ³
	oTef:aRetCorresp[oTef:nTrans]:cNsuCancPg 		:= AllTrim(oTef:cBuffer)		
	
//Valor do Benefício
ElseIf 	oTef:nTipoCampo ==622	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ³
	oTef:aRetCorresp[oTef:nTrans]:nVlrBenef 		:= Round(Val(AllTrim(oTef:cBuffer))/100,2)
	
//Código impresso no rodapé do comprovante do CB e utilizado para er-impressão/cancelamento
ElseIf 	oTef:nTipoCampo ==623	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
	oTef:aRetCorresp[oTef:nTransCB]:cRodape 			:= AllTrim(oTef:cBuffer)

//Código em barras pago. Aparece uma vez para cada índice de documento (campo 607). O formato é o mesmo utilizado para entrada do campo ou seja, 0:numero ou 1:numero
ElseIf 	oTef:nTipoCampo ==624	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
	oTef:aRetCorresp[oTef:nTransCB]:cBarras 			:= AllTrim(oTef:cBuffer)

//RETORNOS VIDALINK          

//Quantidade total de medicamentos
ElseIf 	oTEF:nTipoCampo == 1010	
	nI												:= Val(AllTrim(oTEF:cBuffer))
	oTEF:aRetVidaLink:nQtdeMed	  					:= nI
	oTEF:aRetVidaLink:aItems	  	 				:= Array(nI)
	For nI := 1 To oTEF:aRetVidaLink:nQtdeMed
		oTEF:aRetVidaLink:aItems[nI] 				:= MSRetVidaLinkItem():New()
	Next

	If oTef:nCodFuncao == 560
		oTEF:aRetVidaLink:nIndAtual					:= oTEF:aRetVidaLink:nIndAtual +1
		nI  										:= oTEF:aRetVidaLink:nIndAtual
    Endif

//Indice do medicamento
ElseIf 	oTef:nTipoCampo == 1011
	nI			  						   			:= Val(AllTrim(oTEF:cBuffer))
	oTEF:aRetVidaLink:nIndAtual 					:= nI
	oTEF:aRetVidaLink:aItems[nI]:nIndice			:= nI

//Codigo do medicamento
ElseIf 	oTef:nTipoCampo == 1012
	
	//PBM PharmaSystem
	If oTef:nCodFuncao == 541 .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:nIndAtual						:= oTEF:aRetVidaLink:nIndAtual +1
		oTEF:aRetVidaLink:nQtdeMed	  					:= oTEF:aRetVidaLink:nIndAtual

		If oTEF:aRetVidaLink:nIndAtual == 1
			oTEF:aRetVidaLink:aItems					:= {}
		Endif
		
	   	AADD( oTEF:aRetVidaLink:aItems,MSRetVidaLinkItem():New() )
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:nIndice			:= oTEF:aRetVidaLink:nIndAtual
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:cCodigo			:= AllTrim(oTef:cBuffer)
    Else
		nI			  									:= oTEF:aRetVidaLink:nIndAtual
		oTEF:aRetVidaLink:aItems[nI]:cCodigo			:= AllTrim(oTef:cBuffer)
	Endif
                                                          
//Quantidade autorizada
ElseIf 	oTef:nTipoCampo == 1013
	//PBM PharmaSystem
	If oTef:nCodFuncao == 541 .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:nQuantAut			:= Val(AllTrim(oTef:cBuffer))
	Else
		nI				  								:= oTEF:aRetVidaLink:nIndAtual
		oTEF:aRetVidaLink:aItems[nI]:nQuantAut			:= Val(AllTrim(oTef:cBuffer))
	Endif

//Preço unitário máximo de venda ao consumidor
ElseIf 	oTef:nTipoCampo == 1014
	nI												:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nPrecoMax 			:= Val(AllTrim(oTef:cBuffer))/100

//Valor unitário recomendado de venda ao consumidor
ElseIf 	oTef:nTipoCampo == 1015
	nI												:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nPrecoRecomend		:= Val(AllTrim(oTef:cBuffer))/100

//Valor unitário de venda à farmácia. Corresponde ao Valor de venda ao consumidor + Reembolso da farmácia
ElseIf 	oTef:nTipoCampo == 1016
	nI												:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValVendFarm  		:= Val(AllTrim(oTef:cBuffer))/100

//Valor unitário de reembolso da farmácia
ElseIf 	oTef:nTipoCampo == 1017
	nI			  									:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValReembFarm		:= Val(AllTrim(oTef:cBuffer))/100

//Valor unitário de reposição
ElseIf 	oTef:nTipoCampo == 1018
	nI												:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValReposiFarm		:= Val(AllTrim(oTef:cBuffer))/100

//Valor do subsídio do convênio
ElseIf 	oTef:nTipoCampo == 1019
	nI												:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValSubsidio		:= Val(AllTrim(oTef:cBuffer))/100

//CNPJ do convênio
ElseIf 	oTef:nTipoCampo == 1020
	oTEF:aRetVidaLink:cCNPJConvenio					:= AllTrim(oTef:cBuffer)

//Código do plano de desconto do Convênio
ElseIf 	oTef:nTipoCampo == 1021
	oTEF:aRetVidaLink:cCodPlano						:= AllTrim(oTef:cBuffer)

//Número do documento (retorno na venda e solicitado no cancelamento)
ElseIf 	oTef:nTipoCampo == 1022
MsgStop("TipoCampo "+Str(oTef:nTipoCampo)+"= "+AllTrim(oTef:cBuffer))

//Data da venda a ser cancelada no formato DDMMAAAA
ElseIf 	oTef:nTipoCampo == 1023
	nI			  									:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cCRM				:= AllTrim(oTef:cBuffer)

//Número do cupon fiscal original a ser cancelado
ElseIf 	oTef:nTipoCampo == 1024
	nI			  									:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cUF				:= AllTrim(oTef:cBuffer)

//Código do medicamento a ser devolvido
ElseIf 	oTef:nTipoCampo == 1025
	MsgStop("TipoCampo "+Str(oTef:nTipoCampo)+"= "+AllTrim(oTef:cBuffer))

//Quantidade do medicamento a ser devolvida
ElseIf 	oTef:nTipoCampo == 1026
	MsgStop("TipoCampo "+Str(oTef:nTipoCampo)+"= "+AllTrim(oTef:cBuffer))

//1029	Data da receita médica
ElseIf  oTef:nTipoCampo == 1029
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:dDataRec		:= AllTrim(oTef:cBuffer)

ElseIf  oTef:nTipoCampo == 1030  
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cNumPreAut					:= AllTrim(oTef:cBuffer)
	
//VidaLink Valor unitário de venda ao consumidor para pagamento à vista
ElseIf  oTef:nTipoCampo == 1033
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValConsum		:= Val(AllTrim(oTef:cBuffer))/100

//Tipo de Medicamento PBM (01–Medicamento, 02-Manipulação, 03-Manipulação Especial, 04-Perfumaria)
ElseIf  oTef:nTipoCampo == 1040
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cTpMedic		:= AllTrim(oTef:cBuffer)

//1041	Descrição do Medicamento
ElseIf  oTef:nTipoCampo == 1041
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cDescMedic		:= AllTrim(oTef:cBuffer)                                                    
	
//1042	Condição p/venda:Se 0 obrigatório utilizar preço Funcional Card (PF) Se 1 pode vender por preço inferior ao preço PF
ElseIf  oTef:nTipoCampo == 1042
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cPrecoFun		:= AllTrim(oTef:cBuffer)
	
//1043	Preço Funcional Card
ElseIf  oTef:nTipoCampo == 1043
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValorFC		:= Val(AllTrim(oTef:cBuffer))/100

//1044	Preço praticado
ElseIf  oTef:nTipoCampo == 1044
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValorPrat		:= Val(AllTrim(oTef:cBuffer))/100
	
//PharmaSystem Status do Medicamento
ElseIf  oTef:nTipoCampo == 1045
	If oTef:nCodFuncao == 541  .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:cStatMedic			:= AllTrim(oTef:cBuffer)
	Endif

//1046	Quantidade receitada
ElseIf  oTef:nTipoCampo == 1046
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nQtdReceit		:= Val(AllTrim(oTef:cBuffer))

//1047	Referência
ElseIf  oTef:nTipoCampo == 1047
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cRef			:= AllTrim(oTef:cBuffer)

//1048	Indicador da venda PBM (0-Produto venda cartão 1-Produto venda a vista)
ElseIf  oTef:nTipoCampo == 1047
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cIndPBM		:= AllTrim(oTef:cBuffer)

//4001	CRF
ElseIf  oTef:nTipoCampo == 4001
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cCRF			:= AllTrim(oTef:cBuffer)

//4002	UF do CRF
ElseIf  oTef:nTipoCampo == 4002
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cUFCRF			:= AllTrim(oTef:cBuffer)

//4003	Tipo de venda
ElseIf  oTef:nTipoCampo == 4003
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cTipoVen		:= AllTrim(oTef:cBuffer)

//PharmaSystem Valor Total
ElseIf  oTef:nTipoCampo == 4004
	If oTef:nCodFuncao == 541 .OR. oTef:nCodFuncao == 560  .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:nValTot			:= Val(AllTrim(oTef:cBuffer))/100
	Endif               

//4005	Valor a Vista
ElseIf  oTef:nTipoCampo == 4005
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nValConsum		:= Val(AllTrim(oTef:cBuffer))/100
	
//4006	Valor cartão PBM
ElseIf  oTef:nTipoCampo == 4006
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:nVlCartao		:= Val(AllTrim(oTef:cBuffer))/100

//PharmaSystem % De Desconto
ElseIf  oTef:nTipoCampo == 4008 
	If oTef:nCodFuncao == 541 .OR. oTef:nCodFuncao == 560  .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:nPerDesc			:= Val(AllTrim(oTef:cBuffer))
	Endif

	oTEF:nTipoCampo					

//PharmaSystem Preco Bruto
ElseIf  oTef:nTipoCampo == 4016

			If oTEF:nTipoCampo == 4016
				MsgAlert("LjTEFTrata - 4016")
			Endif
			
	If oTef:nCodFuncao == 541  .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:nValTot			:= Val(AllTrim(oTef:cBuffer)) /100
	Endif

//PharmaSystem Preco Liquido

ElseIf  oTef:nTipoCampo == 200
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cSaldoDisp					:= AllTrim(oTef:cBuffer)
	
ElseIf  oTef:nTipoCampo == 641
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cDataIni					:= AllTrim(oTef:cBuffer)	

ElseIf  oTef:nTipoCampo == 642
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cDataFim					:= AllTrim(oTef:cBuffer)
	
ElseIf  oTef:nTipoCampo == 4017
	If oTef:nCodFuncao == 541  .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:nValLiq			:= Val(AllTrim(oTef:cBuffer)) /100
	Endif
	
ElseIf  oTef:nTipoCampo == 4022
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cNumPreAut					:= AllTrim(oTef:cBuffer)							

ElseIf  oTef:nTipoCampo == 4023
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cNomeConveniado		:= AllTrim(oTef:cBuffer)
		
ElseIf  oTef:nTipoCampo == 4024
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cNomEmpConv		:= AllTrim(oTef:cBuffer)
			
ElseIf  oTef:nTipoCampo == 4025
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cNomeConveniado		:= AllTrim(oTef:cBuffer)
	
ElseIf  oTef:nTipoCampo == 4026
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cNomeConveniado		:= AllTrim(oTef:cBuffer)
	
ElseIf  oTef:nTipoCampo == 4027
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cNomeConveniado		:= AllTrim(oTef:cBuffer)		
		
ElseIf  oTef:nTipoCampo == 1039
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:cDescAdm					:= AllTrim(oTef:cBuffer)

//PharmaSystem Valor a Receber do Conveniado
ElseIf  oTef:nTipoCampo == 4028
	If oTef:nCodFuncao == 541  .OR. oTef:nCodFuncao == 540
		oTEF:aRetVidaLink:aItems[oTEF:aRetVidaLink:nIndAtual]:nValRec			:= Val(AllTrim(oTef:cBuffer))  /100
	Endif                                       
	
//4033	Tipo de documento PBM (0 = CRM, 1 = CRO)
ElseIf  oTef:nTipoCampo == 4033
	nI											:= oTEF:aRetVidaLink:nIndAtual
	oTEF:aRetVidaLink:aItems[nI]:cTpBPM			:= AllTrim(oTef:cBuffer)

ElseIf 	oTef:nTipoCampo == 1058
	LjInfoTEF( oTef:cBuffer )

//Numero do cartao criptografado (operacao de pre-autorizacao)           
ElseIf oTef:nTipoCampo == 2041
	oTef:aRetCartao[oTef:nTrans]:cNumCarCript 	:= AllTrim(oTef:cBuffer) 

//Data de validade (operacao de pre-autorizacao)	
ElseIf oTef:nTipoCampo == 2022
	oTef:aRetCartao[oTef:nTrans]:cDataValida 	:= AllTrim(oTef:cBuffer) 	
	
Else
	
	//MsgStop(STR0027+" "+Str(oTef:nTipoCampo)) //"TipoCampo não previsto na CliSiTEF32I"
	
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFMsn  ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para exibicao das mensagens de processamento do TEF   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFMsn(cExp1)											  º±±
±±º          ³ cExp1 - Mensagem a ser exibida na tela	   				  º±±
±±º          ³ cExp2 - Bloco de comandos a ser executado 				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFMsn( cCaption, bAction )
Local oDlgMsn											// Objeto da Tela
Local oFontMens		:= TFont():New("Arial",07,17,,.T.)	// Objeto para utilização da fonte

Private oSayMsn											//Objeto para exibicao do texto na tela
Private cSayMsn    	:= PadC(AllTrim(cCaption),103)		//Texto a ser exibido

Default bAction	:= { || Inkey( 1 ) }					//Acão a ser executada

DEFINE MSDIALOG oDlgMsn FROM 000,000 TO 050,470 TITLE STR0001 STYLE DS_MODALFRAME PIXEL
@007,000 SAY oSayMsn VAR cSayMsn FONT oFontMens COLOR CLR_BLUE Of oDlgMsn PIXEL

oDlgMsn:bStart 	:= { || Eval( bAction, oDlgMsn ), oDlgMsn:End()}
oDlgMsn:cMsg	:= cCaption

ACTIVATE DIALOG oDlgMsn CENTER

Return(oDlgMsn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFCheq ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita os objetos para digitacao dos dados do cheque      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFCheq()       
Local lCmc7 		:= IIf(oTef:nCodFuncao == 900,.T.,.F.)  	//Atualmente o cheque vem preenchido da interface eceto quando for um pagamento de correspondente bancario
Local lRet			:= .F.										//Retorno da funcao
Local lContinua		:= .T.										//Verifica se continua tentando utilizar o leitor de CMC7
Local oCom                                                      //MSGET Comp.
Local oBco														//MSGET Banco
Local oAge														//MSGET Agência
Local oChe														//MSGET Cheque
Local oCta														//MSGET Conta Corrente
Local oC1														//MSGET C1
Local oC2														//MSGET C2
Local oC3														//MSGET C3

//Controle de exibicao dos objetos
LjTEFObj(.F.,"C")

If lCmc7 .AND. lUsaCMC7 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se usa o CMC7 e faz o tratamento                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lContinua .AND. lUsaCmc7
	    //Limpa Buffers 
	    oTef:cCom := ""
	    oTef:cBco := ""
	    oTef:cAge := ""
	    oTef:cC1  := ""
	    oTef:cCta := ""
	    oTef:cC2  := ""
	    oTef:cChe := ""
	    oTef:cC3  := ""  
	    
	    If (Len(oTef:aRetCorresp) > 0)
	    	oTef:aRetCorresp[oTef:nTrans]:cChqLido := ""
	    EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua a leitura atraves do CMC7                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LjTEFCMC7()
	
	EndIf

EndIf
                        	
oMens:cCaption	:= STR0050

@40,005	SAY STR0051 FONT oFontPad COLOR CLR_BLUE 		SIZE 030,10 OF oPanChq PIXEL 		//"Comp."
@50,005	MSGET oCom VAR oTef:cCom PICTURE "999"	 		SIZE 002,10 OF oPanChq PIXEL

@40,035	SAY STR0052 FONT oFontPad COLOR CLR_BLUE 		SIZE 030,10 OF oPanChq PIXEL		//"Banco"
@50,035	MSGET oBco VAR oTef:cBco PICTURE "999"	 		SIZE 004,10 OF oPanChq PIXEL

@40,070	SAY STR0053 FONT oFontPad COLOR CLR_BLUE 		SIZE 035,10 OF oPanChq PIXEL		//"Agência"
@50,070	MSGET oAge VAR oTef:cAge PICTURE "9999"			SIZE 004,10 OF oPanChq PIXEL

@40,105 SAY STR0054	FONT oFontPad COLOR CLR_BLUE	 	SIZE 010,10 OF oPanChq PIXEL		//"C1"
@50,105	MSGET oC1  VAR oTef:cC1	 PICTURE "9"			SIZE 002,10 OF oPanChq PIXEL

@40,130	SAY STR0055 FONT oFontPad COLOR CLR_BLUE		SIZE 055,10 OF oPanChq PIXEL		//"Conta Corrente"
@50,130	MSGET oCta VAR oTef:cCta PICTURE "9999999999"	SIZE 050,10 OF oPanChq PIXEL

@40,185	SAY STR0056 FONT oFontPad COLOR CLR_BLUE		SIZE 010,10 OF oPanChq PIXEL		//"C2"
@50,185	MSGET oC2  VAR oTef:cC2	 PICTURE "9"			SIZE 002,10 OF oPanChq PIXEL

@40,210	SAY STR0057 FONT oFontPad COLOR CLR_BLUE		SIZE 025,10 OF oPanChq PIXEL		//"Cheque"
@50,210	MSGET oChe VAR oTef:cChe PICTURE "999999"		SIZE 020,10 OF oPanChq PIXEL
		
@40,250	SAY STR0058 FONT oFontPad COLOR CLR_BLUE		SIZE 010,10 OF oPanChq PIXEL		//"C3"
@50,250	MSGET oC3  VAR oTef:cC3	 PICTURE "9"			SIZE 002,10 OF oPanChq PIXEL

oCom:SetFocus()

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFCmc7 ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Leitura de cheques através do leitor de CMC7                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFCMC7()
Local cBufCMC7  := Space(200)                           //Armazema o Buffer de retorno com as informacoes do cheque
Local nRet      := 1                                    //Pega o retorno da funcao  

oTef:cCom		:= Space(03)
oTef:cBco       := Space(04)
oTef:cAge      	:= Space(04)
oTef:cCta		:= Space(10)
oTef:cChe  	  	:= Space(06)
oTef:cC1		:= Space(01)
oTef:cC2		:= Space(01)
oTef:cC3		:= Space(01)

	While nRet == 1       
	
		MsgRun( OemToAnsi( STR0132 ),,;     	// " Passe o cheque e Aguarde a leitura..."
 		{|| Sleep( 2000 ), nRet := CMC7LeD( nHdlCMC7, @cBufCMC7 ) } )
		
		If ( nRet == 1 ) .OR. Empty( cBufCMC7 )
 			If MsgYesNo( STR0030 )              // "Erro na leitura do cheque. Deseja tentar novamente?"
				cBufCMC7 := ""
	            cBufCMC7 := Space(200)
			Else
				nRet := 0   
			EndIf
		Else
                  
			If (Len(oTef:aRetCorresp) > 0)
				oTef:aRetCorresp[oTef:nTrans]:cChqLido := cBufCMC7
			EndIf
			
			oTef:SetDadChq(cBufCMC7)
			
			nRet := 0   
			
		EndIf
	End

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ExtraiListaºAutor ³Cesar Valadao       º Data ³  07/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Extrai da lista de opcoes da CliSiTEF a opcao escolhida     º±±
±±º          ³para validar a opcao                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExtraiLista(cLista, cItem)
Local cRet
cRet := Substr(cLista,At(AllTrim(cItem),cLista))					// Localizo o item
cRet := Substr(cRet, 1, At(";",cRet)-1)							// Seleciono o item
cRet := Substr(cRet, At(":",cRet)+1)								// Extraio o "XX:" do item
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFProc ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa as rotinas a serem efetuadas a partir dos botoes   º±±
±±º          ³de continuacao, voltar ou encerrar                          º±±
±±º          ³Executa a validacao dos campos da interface                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFProc( cProc )
Local lRet		:= .T.				// Controla validacao do campo digitado
Local nRet							// Retorno devolvido pela AUTOCOM.DLL
Local cUserIDOld := __cUserID		// Variavel com o acesso do usuario logado no sistema
Local xRet                          // Retorno do ponto de entrada P_LJVLDPSW
Local lLJVldPsw := FindFunction("P_LJVLDPSW")  // Verifica a existencia ou nao do ponto de entrada P_LJVLDPSW

Default cProc	:= "C"

oTimer1:DeActivate() 
oTimer2:DeActivate() 
oTEF:nSecFinC23 := 0

If cProc == "C"		//Continuar

	If oTef:nProxComan == 21
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico se o operador digitou uma numeracao de acordo com a definição da CLISITEF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Ascan(oTef:aValid,AllTrim(oTef:cGet)) == 0
			MsgStop(STR0002,STR0005) 								//"Digite uma das opções apresentadas na lista"
			oGet:SetFocus()
			lRet := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Vou verificar se o operador está selecionando a mesma transação pre-definida na interface³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf Alltrim(Upper(oMens:cCaption)) == "SELECIONE A FORMA DE PAGAMENTO" 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quando estiver homologando na Software Express, a validacao abaixo nao deve ser feita³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !oTEF:lHomolog .AND. "CHEQUE" $ Upper(oTEF:cBuffer) .AND. oTEF:nCodFuncao<>900
				If oTef:aRetCartao[oTef:nTrans]:cForma == "CH"
					If !	"CHEQUE"	$ Upper(ExtraiLista(oTEF:cBuffer, AllTrim(oTEF:cGet)))
						MsgStop(STR0079,STR0005)						//"Forma de pagamento diferente da informada na finalização da venda.")
						lRet := .F.
					EndIf
				ElseIf oTef:aRetCartao[oTef:nTrans]:cForma == "CD"
					If !(	"DEBITO"	$ Upper(ExtraiLista(oTEF:cBuffer, AllTrim(oTEF:cGet))) .OR.;
							"FININVEST"	$ Upper(ExtraiLista(oTEF:cBuffer, AllTrim(oTEF:cGet)))	)
						MsgStop(STR0079,STR0005)						//"Forma de pagamento diferente da informada na finalização da venda.")
						lRet := .F.
					EndIf
				ElseIf oTef:aRetCartao[oTef:nTrans]:cForma == "CC"
					If !	"CREDITO"	$ Upper(ExtraiLista(oTEF:cBuffer, AllTrim(oTEF:cGet)))
						MsgStop(STR0079,STR0005)						//"Forma de pagamento diferente da informada na finalização da venda.")
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		
		/*
		Ponto de Entrada que permite executar validação quando clicar no botão "Continuar" na tela do TEF.
		Este PE eh executado sempre que for clicado no botao "Continuar".
		
		Como parametro eh passado:
		1) Codigo da Função do TEF (Exemplo: 110=Abre o menu de transacoes Gerenciais) [Obs.: Veja a documentacao do SiTef com contem os Codigos das demais Funcoes do TEF]
		2) Mensagem do topo da tela enviado pelo SITEF. (Exemplo: "Selecione a opcao desejada")
		3) Valor digitado no campo (Exemplo: 2)
		
		O PE deve retornar .T. para permitir o usuário executando a opção selecionada ou .F. para não permitir prosseguir.
		*/
		If lRet .And. ExistBlock("LJTEFCON")
			lRet := ExecBlock("LJTEFCON",.F.,.F.,{oTef:nCodFuncao,oMens:cCaption,oTef:cGet} )
		EndIf
		
		If lRet
			oTef:cBuffer := AllTrim(oTef:cGet)
		Else
			oGet:SetFocus()
		EndIf

	ElseIf oTef:nProxComan == 30									//Solicitacao da Dll
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o tamanho e conteúdo do campo digitado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !("DATA" $ Upper(oTEF:cBuffer)) .AND. ( !Empty(oTef:cGet) .AND. (Len(AllTrim(oTef:cGet)) < oTef:nTamMin .OR. Len(AllTrim(oTef:cGet)) > oTef:nTamMax .Or. LjIsStone()) )
		    If oTef:nCodFuncao == 900    //CORRESPONDENTE BANCARIO 
				MsgStop(STR0133,STR0005) 								//"Data invalida!"		    
			Else 
				If lCancLJ140
					//Para fazer a troca automatica caso a numeração do doc seja invalida
					If (AllTrim(oTef:cGet) == aVndCLJ140[1]) .Or. (AllTrim(oTef:cGet) == aVndCLJ140[6])
						cDocCLJ140	:= aVndCLJ140[6]	//L4_NSUTEF
						oTef:cGet	:= cDocCLJ140
						lIsDocTef	:= .F.
						LjTEFProc("C") //Mando processar automaticamente apos trocar o numero pro correto						
					Else
						MsgInfo(STR0194 + CHR(10) +; //"A numero de documento enviado (NSU Sitef e NSU Host) para cancelamento estão inválidos"
								STR0195,STR0005) //"Por favor, digite o número do documento para cancelamento"
						cDocCLJ140 := ""
					EndIf
					
					If Empty(AllTrim(cDocCLJ140)) //Caso nenhum dos dois docs cancele a venda, abro o campo pro usuário digitar
						oTef:cGet		:= Space(oTef:nTamMax)
						oGet:cText		:= Space(oTef:nTamMax)
						oGet:lActive	:= .T.
					EndIf					
				Else
					MsgStop(STR0092,STR0005) 								//"Cartao invalido!"
				EndIf
			EndIf	
			lRet := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Data da primeira parcela ou Data do pré-datado ou Data do cancelamento da transação³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (oTef:nTipoCampo == -1 .AND. AllTrim(oTef:cBuffer) == "Forneca a data da primeira parcela (DDMMAAAA)") .OR. oTef:nTipoCampo == 506 .OR. oTef:nTipoCampo == 515 .OR. oTef:nTipoCampo == 516
			If oTef:nTipoCampo == 516
				oTef:aRetCartao[oTef:nTrans]:cDocCanRei		:= AllTrim(oTef:cGet)
			Else
				If !Empty(oTef:cGet) .AND. !Empty(CtoD(SubStr(oTef:cGet,1,2)+"/"+SubStr(oTef:cGet,3,2)+"/"+SubStr(oTef:cGet,5,4))) .AND. oTef:nTipoCampo <> 506
					// Data do pré-datado
					If CtoD(SubStr(oTef:cGet,1,2)+"/"+SubStr(oTef:cGet,3,2)+"/"+SubStr(oTef:cGet,5,4)) > dDataBase
						If oTef:nTipoCampo <> 515 .AND. oTef:aRetCartao[oTef:nTrans]:dEntrada <> CtoD(SubStr(oTef:cGet,1,2)+"/"+SubStr(oTef:cGet,3,2)+"/"+SubStr(oTef:cGet,5,4))
							oTef:aRetCartao[oTef:nTrans]:dEntrada := CtoD(SubStr(oTef:cGet,1,2)+"/"+SubStr(oTef:cGet,3,2)+"/"+SubStr(oTef:cGet,5,4))
							lRet := .T.
						EndIf
					Else
						If oTef:nTipoCampo ==515
							If !Empty(oTef:aRetCartao[oTef:nTrans]:cDocCanRei)
						  		oTef:aRetCartao[oTef:nTrans]:dDataCanRei	:= CtoD(SubStr(oTef:cGet,1,2)+"/"+SubStr(oTef:cGet,3,2)+"/"+SubStr(oTef:cGet,5,4))
						  	EndIf												  	
						EndIf
					EndIf
				EndIf
	        EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indica que o campo em questão é o código do supervisor. A automação, pode, se desejado, validar os ³
		//³dados coletados, deixando o fluxo da transação seguir normalmente caso seja um supervisor aceitável³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf oTef:nTipoCampo == 500 
		    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a validacao da senha digitada pelo usuario.                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := .F.
			If lLJVldPsw
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada utilizado para autenticacao do usuario ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				xRet := P_LJVLDPSW()
				If ValType(xRet) == "L"
					lRet := xRet
				EndIf
			ElseIf FWAuthSuper(AllTrim(oTef:cGet)) 
				lRet := .T.
			Else
					LjTEFDisp(STR0072) // "Acesso negado, senha do Superior inválida!" 					
				MsgAlert(STR0072)	// "Acesso negado, senha do Superior inválida!"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Volta o posicionamento da senha para o operador inicial           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			__cUserID := cUserIDOld
			PswOrder( 2 )
			PswSeek( __cUserID )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tipo de documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf oTef:nTipoCampo == 501
			If !oTef:cGet $ "0;1"
				MsgStop(STR0004,STR0005) 							//"Conteúdo inválido!"	### Atenção
				lRet := .F.
			EndIf                    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Número de Parcelas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf oTef:nTipoCampo == 505 .OR. oTef:nTipoCampo == 511
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A validacao de valor zero sera tratada pela retorno da DLL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Val(oTef:cGet) > 99
				MsgStop(STR0004,STR0005) 							//"Conteúdo inválido!" ### Atenção
				lRet := .F.
			ElseIf Len(oTef:aDados)>0 .AND. Val(oTef:cGet) <> oTef:aDados[oTef:nTrans][5]
			    If !oTef:lHomolog
					lRet := .T.
					LJTefDisp( STR0081 + " " + STR0184 + " " + STR0185 ) // ### //"Número de parcelas não confere com o utilizado na Finalização da Venda." ### "<ENTER> - Confirma" ### "<ESC> - Cancela"
					If !MsgYesNo(STR0081,STR0005) 					//"Número de parcelas não confere com o utilizado na Finalização da Venda." ### Atenção
						lRet := .F.
					EndIf
				Else
					lRet := .T.
				EndIf
			EndIf
			If lRet
				oTef:cGet 	:= StrZero(Val(oTef:cGet),2)
			EndIf
		EndIf

		If lRet
			oTef:cBuffer := AllTrim(oTef:cGet)
		Else
			oGet:SetFocus()
		EndIf

	ElseIf oTef:nProxComan == 31									//Dados do Cheque
		If Empty(	oTef:cCom + oTef:cBco 	+ oTef:cAge + oTef:cC1 + ;
					oTef:cCta + oTef:cC2 	+ oTef:cChe + oTef:cC3)
			MsgStop(STR0028,STR0005) 								//"Dados inválidos, verifique se todas as informações foram digitadas!"##"Atenção"
			lRet := .F.
	    Else
		    oTef:cBuffer := "0:"+StrZero(Val(oTEF:cCom),3)+StrZero(Val(oTEF:cBco),3)+StrZero(Val(oTEF:cAge),4)+StrZero(Val(oTEF:cC1),1)+StrZero(Val(oTEF:cCta),10)+StrZero(Val(oTEF:cC2),1)+StrZero(Val(oTEF:cChe),6)+StrZero(Val(oTEF:cC3),1)
  			If oTef:nCodFuncao == 900
				oTef:aRetCorresp[oTef:nTrans]:cChqCom 	:= oTef:cCom
				oTef:aRetCorresp[oTef:nTrans]:cChqBco 	:= oTef:cBco
				oTef:aRetCorresp[oTef:nTrans]:cChqAge 	:= oTef:cAge
				oTef:aRetCorresp[oTef:nTrans]:cChqCta 	:= oTef:cCta
				oTef:aRetCorresp[oTef:nTrans]:cChqNum 	:= oTef:cChe
				oTef:aRetCorresp[oTef:nTrans]:cChqC1 	:= oTef:cC1
				oTef:aRetCorresp[oTef:nTrans]:cChqC2 	:= oTef:cC2
				oTef:aRetCorresp[oTef:nTrans]:cChqC3 	:= oTef:cC3
			EndIf
		EndIf
	ElseIf oTef:nProxComan == 34        							//Valor monetario
		If oTef:vGet < 0
			MsgStop(STR0059,STR0005) 								//"Valor inválido!"##"Atenção"
			oGetV:SetFocus()
			lRet := .F.
		ElseIf oTef:nTipoCampo == -1 .AND. AllTrim(oTef:cBuffer) == STR0145 //"Forneca o valor da entrada"
			If oTef:vGet > oTef:aRetCartao[oTef:nTrans]:nVlrTrans
				MsgStop(STR0084,STR0005)							//"Valor de entrada deve ser inferior ao da transação."
				oGetV:SetFocus()
				lRet := .F.
			EndIf
		Else
			oTef:cBuffer 		:= AllTrim(StrTran(Str(oTef:vGet,12,2),".",","))
			//Valor informado para a recarga de Gift Card
			If oTef:nCodFuncao == 669 .OR. oTef:nCodFuncao == 264 //Recarga de Gift Card (669=Modulo Givex; 264=Modulo SQCF - Todo Cartoes)
			  	oTef:aRetRecCP[oTef:nTransCP]:nValor := Round(Val(Replace( oTef:cBuffer, ",", "." )),2)
			EndIf
		EndIf

	ElseIf oTef:nProxComan == 35        							//Código de Barras do Correspondente Bancário
		If !Empty(oTef:cGet)

		    If !oTef:lLeCodBar                           
				oTef:cBuffer := "0:"+AllTrim(oTef:cGet) 
				//Validar o Código de Barras
       			nRet := oAutocom:SIT_VLDBAR(AllTrim(oTef:cGet), oTef:aRetCorresp[oTef:nTrans]:cTipo) 
            Else
				oTef:cBuffer := "1:"+AllTrim(oTef:cGet)             
				//Não necessita Validar o Código de Barras porque o doc. foi lido pelo CMC7
				nRet := 0
            EndIf
			
			If nRet <> 0
				If nRet == 5
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³836100000006343700482908244311701308130604009113      ³
					//³23790516066000045476395007570104900000000000000       ³
					//³00190000090100954524300930924188327420000001592       ³
					//³34191980271337897118175844000101527620000022600       ³
					//³23790095059121136965604025039209117690000005625       ³
					//³23790.09505.91211.369656.04025.039209.1.17690000005625³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MsgStop(STR0142)//"Código de barras inconsistente."
				Else 
					MsgStop(STR0143+AllTrim(Str(nRet))+STR0144)//"Inconsistências no bloco "#" do código de barras."
				EndIf
				oGet:SetFocus()
				lRet := .F.
			EndIf
		Else
			oGet:SetFocus()
			lRet := .F.
		EndIf
	EndIf
    oTef:nContNaveg  	:= 0
ElseIf cProc == "V"	//Voltar
	oGet:Picture		:= "@X"
	oTef:cBuffer		:= ""
	oTef:nContNaveg 	:= 1
ElseIf cProc == "E"	//Encerrar
	oTef:cBuffer		:= ""
	oTef:nContNaveg 	:= -1
	If oTef:nProxComan == 23 
		oSay:cCaption := ""
	EndIf
Else 				//Encerrar
	oTef:cBuffer		:= ""
	oTef:nContNaveg 	:= -1
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tamanho do Buffer³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTef:nTamMaxBuffer 	:= Len(oTef:cBuffer)

If lRet
	If oTef:nTipoCampo == 516 .AND. !Empty(oTEF:cGet) .and. !oTef:lEstVenda
		If !LJGRVCANCT( .F. )
			oTEF:cGet := Space(oTef:nTamMax)
			lRet := .F.
		EndIf
	EndIf
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chamo a funcao de continuacao da navegacao passando os parametros solicitados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oTEF:ContinTrn()
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LjTEFObj  ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita ou Desabilita os objetos da tela principal         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFObj(lOpc)											  º±±
±±º          ³ lExp1 - .T. (Habilita) .F. (Desabilita)					  º±±
±±º          ³ cExp2 - "T" Todos objetos								  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFObj(lOpc,cOpc)

Default lOpc 	:= .F.
Default cOpc 	:= "T"

lOpc := Iif(oTef:nCodFuncao == 900 .AND. oTef:nProxComan == 22, .T., lOpc)
//Solicitacao de digitacao Sitef
oGet:lActive  	:= lOpc
oGet:lVisible	:= lOpc

//Solicitacao de digitacao Sitef - valor monetario 
oGetV:lActive  	:= lOpc
oGetV:lVisible	:= lOpc

//ListBox para exibicao das mensagens e consultas CDC
oList:lActive	:= lOpc
oList:lVisible	:= lOpc

//Botao Confirmar
oBtnC:lActive 	:= lOpc
oBtnC:lVisible 	:= .T.

//Botao Voltar
oBtnV:lActive 	:= lOpc
oBtnV:lVisible 	:= .T.
	
//Botao Encerrar
oBtnE:lActive 	:= lOpc
oBtnE:lVisible 	:= .T.

//Imagem para interação com o operador
oImg:lVisible	:= lOpc

//Painel para a digitacao dos cheques
oPanChq:lActive  := lOpc
oPanChq:lVisible := lOpc

//Mensagem exibida como lista de opcoes
oSay:cCaption	:= If(lOpc,oSay:cCaption," ")

If cOpc == "L"		//Se for o ListBox desabilitamos tudo e deixamos somente o necessario deste objeto
	If oTEF:nCodTrans==19 .OR. oTEF:nCodTrans==11 .OR. oTEF:nCodTrans==36		//Se for consulta CDC ou consulta cheque ou consulta parcelas CDC
		If Len(oList:aItems)>1						
			oList:SetFont(oFontText)
			oBtnC:lActive 	:= .T.
			oBtnE:lActive 	:= .F.
		Else
			oBtnV:lActive 	:= .T.
			oBtnE:lActive 	:= .T.
			oBtnC:lActive 	:= .T.
		EndIf
	ElseIf oTEF:nCodTrans==60 
		oBtnC:lActive 	:= .T.
	ElseIf (oTEF:nCodTrans == 50 .OR. oTEF:nCodTrans == 0) .AND. SUBSTR(oTef:cBuffer,1,5) == "Troco"  
		oBtnC:lActive 	:= .T.
		oBtnV:lActive 	:= .F.
		//Codigos de retorno Cartao SENFF        
		//oTEF:nCodTrans == 26 Confirmacao da venda a vista
		//oTEF:nCodTrans == 27 Confirmacao da venda parcelada		
		//oTEF:nCodTrans == 29 Confirmacao do cancelamento Digitando Numero do Cartao		
		//oTEF:nCodTrans == 30 Confirmacao do cancelamento passando Cartao de Credito		
	ElseIf (oTEF:nCodTrans == 16 .OR. oTEF:nCodTrans == 26 .OR. oTEF:nCodTrans == 27 .OR. oTEF:nCodTrans == 29 .OR. oTEF:nCodTrans == 30) .AND.( SUBSTR(Upper(oTef:cBuffer),1,11) == "AUTORIZADO." .OR. Upper(SUBSTR(oTef:cBuffer,1,11)) == "VOCE GANHOU" .OR. Upper(SUBSTR(oTef:cBuffer,1,20)) == "MENSAGEM AO ATENDENT")
		oBtnC:lActive 	:= .T. 
		oBtnE:lActive 	:= .F.
		oBtnV:lActive 	:= .F.
	Else
		oList:SetFont(oFontList)
		oBtnV:lActive 	:= .T.
		oBtnE:lActive 	:= .T.
	EndIf
	oList:lActive 	:= .T.
	oList:lVisible 	:= .T.
	oSay:cCaption	:= " "
ElseIf cOpc $ "SD"	//Se for digitacao ou selecao do operador desabilitamos tudo e deixamos somente os objs necessarios para esta rotina
	If oTef:nProxComan==34

		If lCancLJ140 .And. oTef:nTipoCampo == 146
			oGetV:lActive	:= .F.
		Else
			oGetV:lActive	:= .T.
		EndIf
		
		oGetV:lVisible	:= .T.
		oGet:lVisible	:= .F.
		oGet:lActive	:= .F.      

	ElseIf ((oTef:nTipoCampo==505 .OR. oTef:nTipoCampo==511) .AND. Alltrim(Upper(oTef:cBuffer))==Upper("Forneca o numero de parcelas")) .Or.;
			(lCancLJ140 .And. (oTef:nTipoCampo == 515 .Or. oTef:nTipoCampo == 516 .Or. oTef:nTipoCampo == 146))
	
		oGet:lVisible	:= .T.
		oGet:lActive	:= .F.      
		oGetV:lVisible	:= .F.
		oGetV:lActive	:= .F.      						
	Else
		oGet:lVisible	:= .T.
		oGet:lActive	:= .T.      
		oGetV:lVisible	:= .F.
		oGetV:lActive	:= .F.      
	EndIf		
	oBtnC:lActive 	:= .T.
	oBtnV:lActive 	:= .T.
	oBtnE:lActive 	:= .T.		
	oSay:cCaption	:= If(cOpc == "D" , " " , oSay:cCaption)
ElseIf cOpc $ "C"	//Se for digitacao dos dados do cheque desabilitamos tudo e deixamos somente os objs necessarios para esta rotina
	oPanChq:lActive := .T.
	oPanChq:lVisible:= .T.
	oBtnC:lActive 	:= .T.
	oBtnV:lActive 	:= .T.
	oBtnE:lActive 	:= .T.		
	oSay:cCaption	:= " "

	oImg:cResname := "CHEQUE"
	oImg:lVisible	:= .T.
ElseIf cOpc $ "B"	//Se for botão, somente habilita encerrar e continuar
	oBtnC:lActive 	:= .T.
	oBtnE:lActive 	:= .T.		
 	oTEF:nSecFinC23 := Seconds()+ oTEF:nTimeOutC23
 	oTEF:cMens23 :=  STR0204 + Str(Int(oTef:nSecFinC23 - Seconds())) + " " + STR0203 //"Continuando a Transação em "#"segs"
	oSay:cCaption := oTEF:cMens23 	
 	oTimer2:Activate() //Ativa o timer para dar refresh de 0,1 segs
 	oTimer1:Activate() //Ativa o timer para continuar em 3 segs
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFTab  ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.	 ³ Esta função carrega as strings pré-estabelecidas pelo SiTEFº±±
±±º          ³ no retorno das funções                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFTab(cOpc)   										  º±±
±±º          ³ cOpc - Codigo da tabela a carregar (Especificacao Sitef)	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFTab(cOpc)

Local aRet		:= {}								//Array com as informacoes disponibilizadas pela Software Express
Local aRetIni 	:= {}
Local nX		:= 0
Local lMVLJADMFI:= SuperGetMv("MV_LJADMFI",,.F.)
Local lAEREDEAUT:= SAE->(ColumnPos("AE_REDEAUT")) > 0

If cOpc == "ADM" 									//Administradoras Financeiras
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Bandeiras para a funcao Credito (conforme documento oficial fornecido pela SE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMVLJADMFI .And. lAEREDEAUT .And. ExistFunc("LjCodSiTEF")
		aRet := LjCodSiTEF("CC")
	EndIf
	
	If Len(aRet) == 0
		Aadd(aRet,{"00000","OUTRAS"})					//OUTRAS NAO DEFINIDAS
		Aadd(aRet,{"00001","VISA"})		
		Aadd(aRet,{"00002","MASTERCARD"})			
		Aadd(aRet,{"00003","DINERS"})			
		Aadd(aRet,{"00004","AMEX"})			
		Aadd(aRet,{"00005","SOLLO"})			
		Aadd(aRet,{"00006","SIDECARD"})					//REDECARD
		Aadd(aRet,{"00007","PRIVATE LABEL"})			//REDECARD					
		Aadd(aRet,{"00008","REDESHOP"})									
		Aadd(aRet,{"00009","PAO_ACUCAR"})									
		Aadd(aRet,{"00010","FININVEST"})									
		Aadd(aRet,{"00011","SERASA DETALHADO"})									
		Aadd(aRet,{"00012","HIPERCARD"})									
		Aadd(aRet,{"00013","AURA"})
		Aadd(aRet,{"00014","LOSANGO"})
		Aadd(aRet,{"00015","SOROCRED"})
		Aadd(aRet,{"10014","DISCOVERY"})
	EndIf

	aRetIni := LjRetINI("BANDEIRASCC")
	If Len(aRetIni) > 0
		For nX:= 1 To len(aRetIni)
			Aadd(aRet,{aRetIni[nX][1],aRetIni[nX][2]})		    	
		Next nX
	EndIf	
ElseIf cOpc == "ADMCD" 									//Administradoras Financeiras
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cartoes de debito - Inclusao realizada para atender necessidade de administradora com multi-bandeira³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMVLJADMFI .And. lAEREDEAUT .And. ExistFunc("LjCodSiTEF")
		aRet := LjCodSiTEF("CD")
	EndIf
	
	If Len(aRet) == 0 
		Aadd(aRet,{"00000","DEBITO GENERICO"})
		Aadd(aRet,{"00001","MAESTRO"})
		Aadd(aRet,{"00003","GIFT_PREPAGO"})
		Aadd(aRet,{"20001","MAESTRO"})
		Aadd(aRet,{"20002","ELECTRON"})
		Aadd(aRet,{"20003","CABALDEBIT"})
		Aadd(aRet,{"10001","TICKET"})
		Aadd(aRet,{"10002","VISAVALE"})
		Aadd(aRet,{"10003","SODEXHO"})
		Aadd(aRet,{"10004","NUTRICASH"})
		Aadd(aRet,{"10005","GREENCARD"})
		Aadd(aRet,{"10006","PLANVALE"})
		Aadd(aRet,{"10007","BANQUET"})
		Aadd(aRet,{"10008","VEROCHEQUE"})
		Aadd(aRet,{"10009","SAPORE"})
		Aadd(aRet,{"10010","BNBCLUBE"})
		Aadd(aRet,{"10011","VALECARD"})
		Aadd(aRet,{"10012","CABAL"})									
		Aadd(aRet,{"10013","ELO"})		//Cartoes Multiplos
		Aadd(aRet,{"10015","GOOD_CARD"})
		Aadd(aRet,{"10016","POLICARD"})
		Aadd(aRet,{"10017","CARD_SYSTEM"})
		Aadd(aRet,{"10018","BONUS_CBA"})
		Aadd(aRet,{"10023","ALELO CULTURA"})	
	EndIf

	aRetIni := LjRetINI("BANDEIRASCD")
	If Len(aRetIni) > 0
		For nX:= 1 To len(aRetIni)
			Aadd(aRet,{aRetIni[nX][1],aRetIni[nX][2]})		    	
		Next nX
	EndIf	
	
ElseIf cOpc == "RED" 								//Redes Autorizadas
	If lMVLJADMFI .And. lAEREDEAUT .And. ExistFunc("LjCodSiTEF")
		aRet := LjCodSiTEF("RD")
	EndIf
	
	If Len(aRet) == 0
		Aadd(aRet,{"00000","OUTRAS"})					//OUTRAS NAO DEFINIDAS
		Aadd(aRet,{"00001","TECBAN"})		
		Aadd(aRet,{"00004","VISANET"})			
		Aadd(aRet,{"00005","REDECARD"})			
		Aadd(aRet,{"00006","AMEX"})	
		Aadd(aRet,{"00021","BANRISUL"})
		Aadd(aRet,{"00125","VISA"})
		Aadd(aRet,{"00196","LIBERCARD"})	
	EndIf
EndIf
Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjTEFSai  ºAutora ³Solange Zanardi     º Data ³  12/14/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.	 ³ Efetua as validacoes para abandono de operacao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ LjTEFSai()       										  º±±
±±º          ³ ExpL1 - Indica se tem tef pendente                 		  º±±
±±º          ³ ExpA1 - Guarda a ultima transacao, caso de problemas na    º±±
±±º          ³         proxima transacao TEF.                 		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFSai( lTemTefPend, aTefBKP, aFormCtrl , aPgtos , ;
 					aPgtosSint, oPgtos , oPgtosSint)

Local lRet		:= .T.		// Retorno da funcao
Local cIdCartao := ""		// Variavel utilizada para identificar os cartoes que fazem parte da mesma transacao.
Local nI        := 0		// Variavel do FOR
Local nLenPgtos := 0		// Variavel que controla a dimensao do aPgtos
Local lIdCartao	:= .F.		// Retorna se o idcartao e igual entre as variaveis aPgtos e cIdcartao
Local lDelaCtrl := .F.		// Controla se já foi deletado a posicao da array (aFormCtrl)
Local nPosId    := 0		// Controla a posicao do IdCartao 
Local lConsCH	:= At("S",LjGetStation("TEFCONS")) <> 0 // Se esta habilitado a consulta telecheque
Local cFormDel	:= ""		// Forma que sera deletada
Local nPos		:= 0		// Posiciao de retorno do aScan	
Local nValPg	:= 0        // Valor do Pagamento
Local nX		:= 0		// Contador
local cMvTefPend	:= SuperGetMV("MV_TEFPEND",,"0") // Define qual ação caso transação TEF ja tiver sido aprovada | 0 = Cancela, 1 = Mantem aprovada, 2 = Obriga a tentar novamente

DEFAULT lTemTefPend := .F.
DEFAULT aTefBKP     := {}
DEFAULT aFormCtrl   := {}
DEFAULT aPgtos      := {}
DEFAULT aPgtosSint  := {}

If !oTef:lTefOk
	If oTef:nTotTrans == 1
		If oTEF:nRet == 10000
			LjTEFProc("E")
		EndIf
	Else
	    If oTEF:nTrans > 1
			LJTefDisp( STR0111 + " " + STR0184 + " " + STR0185 )		// ### "Houve problemas com a transação TEF. Deseja escolher outra forma de pagamento?" ### "<ENTER> - Confirma" ### "<ESC> - Cancela"

			// se MV_TEFPEND = 0 cancela as transações pendentes
			If cMvTefPend == "0"			

				LjGrvLog( "Erro TEF", "MV_TEFPEND", cMvTefPend)
				//Finaliza a TRN com parametro confirma = 0
				oTEF:FinalTrn(0)								
				//Indica que todas as transacoes foram canceladas
				lCanFull := .T.
				MsgStop(STR0089, STR0005)//"Atenção" "Todas as transações pendentes foram canceladas!"

			ElseIf nModulo == 12 .AND. cMvTefPend == "2"
				For nX := 1 To Len(aPgtosSint)
					If	AllTrim(aPgtosSint[nX][1]) == AllTrim(oTef:aRetCartao[oTef:nTrans]:cForma)	 .AND.;
						AllTrim(aPgtosSint[nX][4]) == AllTrim(oTef:aRetCartao[oTef:nTrans]:cIdCart)

						aPgtosSint[nX][6] := {} // limpa apenas o campo de administradora financeira
					EndIf
				Next nX

				aDel(oTef:aRetCartao, oTEF:nTrans )
				aSize(oTef:aRetCartao, Len(oTef:aRetCartao)-1)
				aTefBKP := aClone(oTef:aRetCartao)
				lTemTEFPend := .T.

			ElseIf cMvTefPend == "1" .AND. MsgYesNo(STR0111, STR0110)       // ### "Houve problemas com a transação TEF. Deseja escolher outra forma de pagamento?" ### "Atenção"
				If nModulo <> 23 
					nPosId := 8
				Else
					nPosId := 12
				EndIf         
				
				// Caso o parametro como 1 deleta a forma de pagamento, com o parametro 2 mantem a forma
				If cMvTefPend == "1"
					If oTEF:nTrans <= Len(aPgtos)
						cIdCartao := AllTrim(oTef:aRetCartao[oTef:nTrans]:cIdCart)
						cFormDel  := AllTrim(oTef:aRetCartao[oTef:nTrans]:cForma)
					Else
						If nModulo <> 23 .OR. Len(aFormCtrl) == 0
							cIdCartao := aPgtos[1][nPosId]
						Else
							cIdCartao := aFormCtrl[Len(aFormCtrl)][9]
						EndIf
					EndIf
					nLenPgtos := Len(aPgtos)
					While ++nI <= nLenPgtos
						If nModulo <> 23 .OR. Len(aFormCtrl) == 0
							lIdCartao := (cIdCartao == AllTrim(aPgtos[nI][nPosId]))
						Else
							// Alem de ser o mesmo ID tambem deve ser da mesma forma
							lIdCartao := (cIdCartao == AllTrim(aPgtos[nI][12]) .AND. IIF(!Empty(cFormDel),cFormDel == aPgtos[nI][3],.T.))
						EndIf
						If lIdCartao .AND. (aPgtos[nI][3] $ _FORMATEF .OR. (lConsCH .AND. aPgtos[nI][3] $ "CH"))
							If Empty(cFormDel)
								cFormDel := aPgtos[nI][3]
							EndIf	
							nValPg 		:= aPgtos[nI][2]	
							aDel(aPgtos, nI)
							aSize(aPgtos, Len(aPgtos)-1)
							// Variavel do FRONTLOJA
							If nModulo == 23 .AND. !lDelaCtrl .AND. Len(aFormCtrl) > 0
								nPos := Ascan(aFormCtrl, {|x| AllTrim(x[1]) == cFormDel  .AND.;
															  AllTrim(x[9]) == cIdCartao })
								// Somente se encontrar o msm aPgtos no aFormCtrl
								If nPos > 0
									aDel(aFormCtrl, nPos )
									aSize(aFormCtrl, Len(aFormCtrl)-1 )
									lDelaCtrl := .T.
								EndIf	
							EndIf
							--nI
						EndIf
						nLenPgtos := Len(aPgtos)
					End
					If ValType(oPgTos) == "O"
					   oPgTos:SetArray( aPgtos )
					   oPgTos:Refresh()
					EndIf
					aPgtosSint := Lj7MontPgt(@aPgtos,NIL,NIL,.T.)
					If ValType(oPgtosSint) == "O"
						oPgtosSint:SetArray( aPgtosSint )
						oPgtosSint:Refresh()
					EndIf	
	
				EndIf
					
				aDel(oTef:aRetCartao, oTEF:nTrans )
				aSize(oTef:aRetCartao, Len(oTef:aRetCartao)-1)
				aTefBKP := aClone(oTef:aRetCartao)
				lTemTEFPend := .T.
			Else
				If !SuperGetMV("MV_TEFMANU", ,.T.)
					LjTEFProc("E")
				Else
					aDel(oTef:aRetCartao, oTEF:nTrans )
					aSize(oTef:aRetCartao, Len(oTef:aRetCartao)-1)
					aTefBKP := aClone(oTef:aRetCartao)
					lTemTEFPend := .T.
				EndIf
			EndIf
		EndIf

		//Limpa o array utilizado no frta010a quando todas as transacoes forem canceladas
		//para o cupom da transacao nao ser impresso.
		If lCanFull
			aTefBKP := {}
			lCanFull := .F.
		EndIf		
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjTEFConfPar³ Autora³ Solange Zanardi     ³ Data ³ 11.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Refaz a array das as parcelas geradas pela interfaces e    ³±±
±±³          ³ alteradas em meio a transação TEF                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFConfPar() 
Local nX 		:= 0	//Controle de loop
Local nY 		:= 0 	//Controle de loop
Local aRetPgto	:= {}
Local aCondNeg  := {}

//Vou comparar se houve alteracao nas datas de retorno do TEF com o informado na interface de vendas
For nX := 1 To Len(oTef:aRetCartao)
	//Zerando a array devolvida pela CLISITEF, pois esta possui somente a data e o valor da primeira parcela
	oTef:aRetCartao[nX]:aDatas 		:= {}
	oTef:aRetCartao[nX]:aValores 	:= {}

	If oTef:aRetCartao[nX]:nParcelas > 1
		//Preparando array para recalculo de datas de vencimento do cartão para futura conciliacao bancaria
		aCondNeg  := {1,oTef:aRetCartao[nX]:dEntrada,oTef:aRetCartao[nX]:nVlrEntrada,0,oTef:aRetCartao[nX]:nParcelas,If(oTef:aRetCartao[nX]:nIntervalo>0,oTef:aRetCartao[nX]:nIntervalo,30),.F.}
		//Refazer as datas a partir da inicial
		aRetPgto  := Lj7CalcPgt(oTef:aRetCartao[nX]:nVlrTrans,"CN",aCondNeg,0,,,,0)
		For nY := 1 To Len(aRetPgto)
			Aadd(oTef:aRetCartao[nX]:aDatas,aRetPgto[nY][1])
			Aadd(oTef:aRetCartao[nX]:aValores,aRetPgto[nY][2])
		Next nY
	Else
		//Se for uma unica parcela adiciona somente a data devolvida pelo TEF
		Aadd(oTef:aRetCartao[nX]:aDatas,oTef:aRetCartao[nX]:dEntrada)
		Aadd(oTef:aRetCartao[nX]:aValores,oTef:aRetCartao[nX]:nVlrTrans)
	EndIf
	
Next nX

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjTEFAceParc³ Autora³ Solange Zanardi     ³ Data ³ 11.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Corrige as datas das parcelas na array originaria da inter-³±±
±±³          ³ face                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFAceParc( aParcelas )
Local nX 		:= 0                      				//Contador de laço
Local nY 		:= 0									//Contador de laço
Local nPos 		:= 0 									//Verifica qual posicao da array é correspondente a esta transacao TEF
Local lAltera	:= .F.

DEFAULT aParcelas := {}									//ARRAY com as formas e parcelas de pagto	 

//Se for Venda Assistida
If AllTrim(Upper(FunName())) == "LOJA701"

	//Processar todas as transacçes efetuadas e atualizar a array da interface para processamento de gravacao do financeiro
	For nX := 1 To Len(oTEF:aRetCartao)

		//Se for cartao a localizacao se da atraves da forma de pagamento e o seu respectivo ID indicado na interface de vendas
		If oTEF:aRetCartao[nX]:cForma $ "CC#CD"
			nPos := Ascan(aPgtos, {|x| AllTrim(x[8]) == AllTrim(oTEF:aRetCartao[nX]:cIDCart) } )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a venda for do Tipo CDC existe um tratamento especial                                     ³
			//³para recalculo de datas e valores, pois o operador podera alterar a data e o valor da entrada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³D E B I T O	                             ³
			//³18 Cartão de debito parcelado	         ³
			//³19 Cartão de debito CDC	                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oTef:nCodTrans == 18 .Or. oTef:nCodTrans == 19 
				If nPos > 0
					//O numero da parcela corresponde a array aDatas do retorno
					nParc 	:= 0 
					lAltera := .F.
					For nY 	:= nPos To Len(aPgtos)
						If AllTrim(aPgtos[nY][3])+AllTrim(aPgtos[nY][8]) == AllTrim(oTEF:aRetCartao[nX]:cForma)+AllTrim(oTEF:aRetCartao[nX]:cIDCart)
							nParc += 1
							aPgtos[nY][1] 	:= oTEF:aRetCartao[nX]:aDatas[nParc]
							aPgtos[nY][2]	:= oTEF:aRetCartao[nX]:aValores[nParc]
						EndIf
					Next nY
				EndIf				
		    EndIf					
			
		ElseIf oTEF:aRetCartao[nX]:cForma == "CH"
			//Os cheques serão localizados pelo Banco/Agencia/Numero
			nPos := Ascan(aPgtos, {|x| 	AllTrim(x[03])+AllTrim(x[04][04])+AllTrim(x[04][05])+AllTrim(x[04][07]) == AllTrim(oTEF:aRetCartao[nX]:cForma)+AllTrim(oTEF:aRetCartao[nX]:cChqBco)+AllTrim(oTEF:aRetCartao[nX]:cChqAge)+AllTrim(oTEF:aRetCartao[nX]:cChqNum)})
			If nPos > 0 .AND. aPgtos[nPos][1] <> oTEF:aRetCartao[nX]:aDatas[1] .AND. !Empty(oTEF:aRetCartao[nX]:aDatas[1])
				aPgtos[nPos][1] := oTEF:aRetCartao[nX]:aDatas[1]
			EndIf
		EndIf
		
	Next nX
			
//Se for Front Loja
ElseIf AllTrim(Upper(FunName())) == "FRTA010" .OR. AllTrim(Upper(FunName())) == "FRTA271"

	//Processar todas as transacçes efetuadas e atualizar a array da interface para processamento de gravacao do financeiro
	For nX := 1 To Len(oTEF:aRetCartao)

		//Se for cartao a localizacao se da atraves da forma de pagamento e o seu respectivo ID indicado na interface de vendas
		If oTEF:aRetCartao[nX]:cForma $ "CC#CD"
			nPos := Ascan(aParcelas, {|x| AllTrim(x[12]) == AllTrim(oTEF:aRetCartao[nX]:cIDCart) } )
	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se a venda for do Tipo CDC existe um tratamento especial                                     ³
			//³para recalculo de datas e valores, pois o operador podera alterar a data e o valor da entrada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³D E B I T O	                             ³
			//³18 Cartão de debito parcelado	         ³
			//³19 Cartão de debito CDC	                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oTef:nCodTrans == 18 .Or. oTef:nCodTrans == 19 
				If nPos > 0
					//O numero da parcela corresponde a array aDatas do retorno
					nParc 	:= 0 
					lAltera := .F.
					For nY 	:= nPos To Len(aParcelas)
						If AllTrim(aParcelas[nY][3])+AllTrim(aParcelas[nY][12]) == AllTrim(oTEF:aRetCartao[nX]:cForma)+AllTrim(oTEF:aRetCartao[nX]:cIDCart)
							nParc += 1
							aParcelas[nY][1] := oTEF:aRetCartao[nX]:aDatas[nParc]
							aParcelas[nY][2] := oTEF:aRetCartao[nX]:aValores[nParc]
						EndIf
					Next nY
				EndIf				
		    EndIf					
			
		ElseIf oTEF:aRetCartao[nX]:cForma == "CH"
			//Os cheques serão localizados pelo Banco/Agencia/Numero
			nPos := Ascan(aParcelas, {|x| 	AllTrim(x[03])+AllTrim(x[04])+AllTrim(x[06])+AllTrim(x[05]) == AllTrim(oTEF:aRetCartao[nX]:cForma)+AllTrim(oTEF:aRetCartao[nX]:cChqBco)+AllTrim(oTEF:aRetCartao[nX]:cChqAge)+AllTrim(oTEF:aRetCartao[nX]:cChqNum)})
			If nPos > 0 .AND. aParcelas[nPos][1] <> oTEF:aRetCartao[nX]:aDatas[1] .AND. !Empty(oTEF:aRetCartao[nX]:aDatas[1])
				aParcelas[nPos][1] := oTEF:aRetCartao[nX]:aDatas[1]
			EndIf
		EndIf
		
	Next nX

EndIf

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjTEFGeraSL ³ Autora³ Solange Zanardi     ³ Data ³ 11.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera as parcelas para as tabelas SL1 e SL4 de acordo com o ³±±
±±³          ³ padrao do Loja                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array que contem os campos da tabela               ³±±
±±³          ³ ExpC1 - Qual tabela que sera utilizada					  ³±±
±±³          ³ ExpD1 - Data da transacao                                  ³±±
±±³          ³ ExpC2 - Forma de pagamento                                 ³±±
±±³          ³ ExpC3 - ID do Cartao                                       ³±±
±±³          ³ ExpC4 - Codigo do banco                                    ³±±
±±³          ³ ExpC5 - Codigo da Agencia Bancaria                         ³±±
±±³          ³ ExpC6 - Numero do cheque                                   ³±±
±±³          ³ ExpC7 - Administradora                                     ³±±
±±³          ³ ExpN1 - Posicao da array                                   ³±±
±±³          ³ ExpC8 - Administradora do SAE                              ³±±
±±³          ³ padrao do Loja                                             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTEFGeraSL(	aArray	, cTipo		, dData	, cForma, ;
						cIDCart	, cBco		, cAge	, cChq	, ;
						cAdm	, nPosArray , cAdminis )
Local nPos			:= 0
Local nPosAdm		:= 0
Local lInibeAdm     := GetMv("MV_LJADMFI",,.F.)

Default dData 		:= CtoD("")
Default cForma		:= ""
Default cIDCart		:= ""
Default cBco		:= ""
Default cAge		:= ""
Default cChq		:= ""
Default cAdm		:= ""   
Default nPosArray	:= 1
Default cAdminis    := ""


//Na tabela SL1 grava sempre os dados da primeira transação TEF efetuada
If cTipo == "SL1"
	aAdd( aArray, { "L1_VENDTEF" , "S" } )
	aAdd( aArray, { "L1_DATATEF" , oTef:cData } )
	aAdd( aArray, { "L1_HORATEF" , oTef:aRetCartao[1]:cHoraTrans } )
	aAdd( aArray, { "L1_DOCTEF"  , oTef:aRetCartao[1]:cNsuAutor  } )
	aAdd( aArray, { "L1_AUTORIZ" , oTef:aRetCartao[1]:cAutoriza  } )
	aAdd( aArray, { "L1_INSTITU" , oTef:aRetCartao[1]:cDescAdm	 } )
	aAdd( aArray, { "L1_NSUTEF"  , oTef:aRetCartao[1]:cNsuSitef  } )
	aAdd( aArray, { "L1_TIPCART" , oTef:aRetCartao[1]:cTipCart   } )
	If !Empty(oTef:aRetCartao[1]:cDocCanRei)
		aAdd( aArray, { "L1_DOCCANC" , oTef:aRetCartao[1]:cDocCanRei	} )
		aAdd( aArray, { "L1_DATCANC" , StrTran(DToC(oTef:aRetCartao[1]:dDataCanRei),"/","") } )
		aAdd( aArray, { "L1_HORCANC" , oTef:aRetCartao[1]:cHoraTrans	} )
	Else
		/*Mando em branco pois se reutilizo um orcamento no Loja tenho problemas com esses campos preenchidos*/
		aAdd( aArray, { "L1_DOCCANC" , ""	} )
		aAdd( aArray, { "L1_DATCANC" , ""	} )
		aAdd( aArray, { "L1_HORCANC" , ""	} )
	EndIf
			
	If SL1->(ColumnPos("L1_PARCTEF"))>0
		//Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas
		AAdd(aArray, {"L1_PARCTEF", If(oTef:aRetCartao[1]:lJurLoja,"0","1")+StrZero(oTef:aRetCartao[1]:nParcelas,2) } )
	EndIf

ElseIf cTipo == "SL4"
	If AllTrim(cForma) $ "CC;CD;CV"
		nPos := Ascan(oTEF:aRetCartao, {|x| AllTrim(x:cForma)+AllTrim(x:cIDCart) == AllTrim(cForma)+AllTrim(cIDCart) } )
	ElseIf AllTrim(cForma) == "CH"
		nPos := Ascan(oTEF:aRetCartao, {|x| AllTrim(x:cForma)+AllTrim(x:cChqBco)+AllTrim(x:cChqAge)+AllTrim(x:cChqNum) == AllTrim(cForma)+AllTrim(cBco)+Alltrim(cAge)+Alltrim(cChq) } )
	EndIf

	If nPos > 0
		If 	AllTrim(Upper(FunName())) == "FRTA010" .OR. AllTrim(Upper(FunName())) == "FRTA271"
			aAdd( aArray , { "L4_VENDTEF" , "S"									} )
			aAdd( aArray , { "L4_DATATEF" , oTef:cData							} )
			aAdd( aArray , { "L4_HORATEF" , oTef:aRetCartao[nPos]:cHoraTrans	} )
			aAdd( aArray , { "L4_DOCTEF"  , oTef:aRetCartao[nPos]:cNsuAutor	} )
			aAdd( aArray , { "L4_AUTORIZ" , oTef:aRetCartao[nPos]:cAutoriza	} )
			aAdd( aArray , { "L4_INSTITU" , oTef:aRetCartao[nPos]:cDescAdm		} )
			aAdd( aArray , { "L4_NSUTEF"  , oTef:aRetCartao[nPos]:cNsuSitef	} )
			aAdd( aArray , { "L4_TIPCART" , oTef:aRetCartao[nPos]:cTipCart		} )
			
			If !Empty(oTef:aRetCartao[nPos]:cDocCanRei)
				aAdd( aArray, { "L4_DOCCANC" , oTef:aRetCartao[nPos]:cDocCanRei	} )
				aAdd( aArray, { "L4_DATCANC" , StrTran(DToC(oTef:aRetCartao[nPos]:dDataCanRei),"/","") } )
				aAdd( aArray, { "L4_HORCANC" , oTef:aRetCartao[nPos]:cHoraTrans	} )
			Else
				aAdd( aArray, { "L4_DOCCANC" , ""	} )
				aAdd( aArray, { "L4_DATCANC" , ""	} )
				aAdd( aArray, { "L4_HORCANC" , ""	} )
			EndIf
					
			If SL4->(ColumnPos("L4_PARCTEF"))>0
				//Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas
				AAdd(aArray, {"L4_PARCTEF",If(oTef:aRetCartao[nPos]:lJurLoja,"0","1")+StrZero(oTef:aRetCartao[nPos]:nParcelas,2) } )
			EndIf
			
			aAdd( aArray , { "L4_FORMAID" , cIDCart 	} )
			If SL4->(ColumnPos("L4_BANDEIR"))>0
				//Codigo da Bandeira que foi utilizada
				aAdd( aArray, { "L4_BANDEIR" , oTef:aRetCartao[nPos]:cTipCart } )
			EndIf
			If SL4->(ColumnPos("L4_REDEAUT"))>0
				//Codigo da Rede que foi utilizada
				aAdd( aArray, { "L4_REDEAUT" , oTef:aRetCartao[nPos]:cCodRede } )
			EndIf
			aAdd( aArray, { "L4_NOMECLI" , "RD: " + Alltrim(oTef:aRetCartao[nPos]:cDescRede) + " / BD: " + Alltrim(oTef:aRetCartao[nPos]:cDescAdm) } )
			
			//Alterando a Administradora selecionada
			If !lInibeAdm
				nPosAdm := Ascan(aArray, {|x| x[1]=="L4_ADMINIS"} )
				If nPosAdm > 0
					LjTEFConfADM(nPos,cAdminis, oTef:aRetCartao[nPos]:cForma)
					If Empty(oTef:aRetCartao[nPos]:cCodAdm)
						aArray[nPosAdm][2] 				:= cAdminis
						oTef:aRetCartao[nPos]:cCodAdm   := cAdminis
						cAdminis := ""
					Else
						aArray[nPosAdm][2] := oTef:aRetCartao[nPos]:cCodAdm
					EndIf
				EndIf				
			EndIf
		Else
			aAdd( aArray[nPosArray] , { "L4_VENDTEF" , "S"								} )
			aAdd( aArray[nPosArray] , { "L4_DATATEF" , oTef:cData						} )
			aAdd( aArray[nPosArray] , { "L4_HORATEF" , oTef:aRetCartao[nPos]:cHoraTrans} )
	    	If Alltrim(oTef:aRetCartao[nPos]:cDescRede)=="BANRISUL" .AND. Alltrim(oTef:aRetCartao[nPos]:cCodRede)=="00021"						
				aAdd( aArray[nPosArray] , { "L4_DOCTEF"  , Right(Alltrim(oTef:aRetCartao[nPos]:cNsuAutor),8) } )
			Else				
				aAdd( aArray[nPosArray] , { "L4_DOCTEF"  , oTef:aRetCartao[nPos]:cNsuAutor	} )				
			Endif	
			aAdd( aArray[nPosArray] , { "L4_AUTORIZ" , oTef:aRetCartao[nPos]:cAutoriza	} )
			aAdd( aArray[nPosArray] , { "L4_INSTITU" , oTef:aRetCartao[nPos]:cDescAdm	} )
			aAdd( aArray[nPosArray] , { "L4_NSUTEF"  , oTef:aRetCartao[nPos]:cNsuSitef	} )
			aAdd( aArray[nPosArray] , { "L4_TIPCART" , oTef:aRetCartao[nPos]:cTipCart	} )
			aAdd( aArray[nPosArray] , { "L4_DOCCANC" , oTef:aRetCartao[nPos]:cDocCanRei	} )
			aAdd( aArray[nPosArray] , { "L4_DATCANC" , StrTran(DToC(oTef:aRetCartao[nPos]:dDataCanRei),"/","") } )
			aAdd( aArray[nPosArray] , { "L4_HORCANC" , oTef:aRetCartao[nPos]:cHoraTrans	} )

			If SL4->(ColumnPos("L4_PARCTEF"))>0
				//Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas
				AAdd(aArray[nPosArray], {"L4_PARCTEF",If(oTef:aRetCartao[nPos]:lJurLoja,"0","1")+StrZero(oTef:aRetCartao[nPos]:nParcelas,2) } )
			EndIf

			If SL4->(ColumnPos("L4_BANDEIR"))>0
				//Codigo da Bandeira que foi utilizada
				AAdd(aArray[nPosArray], {"L4_BANDEIR",oTef:aRetCartao[nPos]:cTipCart } )
			EndIf
			If SL4->(ColumnPos("L4_REDEAUT"))>0
				//Codigo da Rede que foi utilizada
				AAdd(aArray[nPosArray], {"L4_REDEAUT",oTef:aRetCartao[nPos]:cCodRede } )
			EndIf
			AAdd(aArray[nPosArray], {"L4_NOMECLI", "RD: " + Alltrim(oTef:aRetCartao[nPos]:cDescRede) + " / BD: " + Alltrim(oTef:aRetCartao[nPos]:cDescAdm) } )			
			
			/*Mando em branco pois se reutilizo um orcamento no Loja tenho problemas com esses campos preenchidos*/
			aAdd( aArray[nPosArray], { "L4_DOCCANC" , ""	} )
			aAdd( aArray[nPosArray], { "L4_DATCANC" , "" 	} )
			aAdd( aArray[nPosArray], { "L4_HORCANC" , ""	} )			
		EndIf
	EndIf
EndIf

Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjTEFMenu ºAutora ³Solange Zanardi     º Data ³  10/06/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ TELA PARA EXIBICAO DO MENU COM TODAS AS OPCOES DO TEF      º±±
±±º          ³ UTILIZADA SOMENTE PARA TESTES INTERNOS	                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFMenu(cOpcao,cCaption,cOpcoes)
Local cValor    := Space(At(":",cOpcoes))					//Inicia o campo a ser coletado no processo
Local aValid	:= {}										//Armazena as inf. válidas na digitação do operador
Local nFor 		:= 0										//Controle de laço
Local cString	:= ""										//Controle para leitura do retorno da DLL
Local cExibir	:= ""										//Sring a ser exibida para o usuário
Local oFontMens	:= TFont():New("Arial",07,17,,.T.)			//Fonte de exibição
Local nLinhas	:= 0          								//Controle do número de linhas para calcular o tamanho dos objetos
Local nSizeGet	:= GetTextWidth(0,Repl("M",Len(cValor)))	//Monta o tamanho exato da largura do campo para digitação
Local lRet		:= .F.	 
Local oDlgMenu				

//Acertar o tamanho da Get para o limite da Tela
nSizeGet := If(nSizeGet>600,600,If(nSizeGet<20,20,nSizeGet))

//Tratando as opcoes a selecionar e suas validações
For nFor := 1 To Len(cOpcoes)
	If SubStr(cOpcoes,nFor,1) == ":"
	   Aadd(aValid,cString)
 	   cString += SubStr(cOpcoes,nFor,1)
	ElseIf SubStr(cOpcoes,nFor,1) == ";"
	   cString := ""
	Else
		cString += SubStr(cOpcoes,nFor,1)
	EndIf
Next nFor

cCaption := AllTrim(cCaption)
cExibir	 := StrTran(cOpcoes,";",Chr(10))
nLinhas  := ((Len(aValid)+0.5)*10)

DEFINE MSDIALOG oDlgMenu TITLE STR0073 FROM 00,00 TO 110+(nLinhas*2),550 PIXEL	//"Rotinas TEF"

//Monta um box com o dado a ser digitado pelo operador
@ 003,003 TO 36,230 PIXEL
@ 007,007 SAY   cCaption FONT oFontMens COLOR CLR_BLUE SIZE 200,10 OF oDlgMenu PIXEL
@ 020,007 MSGET cValor   SIZE nSizeGet,10 OF oDlgMenu PIXEL ;
					     VALID(If(Ascan(aValid,AllTrim(cValor))==0,(MsgStop(STR0002,STR0005),.F.),.T.)) //"Digite uma das opções apresentadas na lista abaixo!"

//Monta um box com as opçoes que o operador poderá selecionar
@ 040,003 TO 40+nLinhas,230 PIXEL
@ 045,007 SAY cExibir FONT oFontMens SIZE 220,(nLinhas*40) OF oDlgMenu PIXEL

@ 41+nLinhas,148 BUTTON STR0074	SIZE 40,15 OF oDlgMenu PIXEL ACTION ( ( lRet := .T. , oDlgMenu:End() ) ) //Confirma 
@ 41+nLinhas,190 BUTTON STR0075	SIZE 40,15 OF oDlgMenu PIXEL ACTION ( ( lRet := .F. , oDlgMenu:End() ) ) //Cancela

ACTIVATE MSDIALOG oDlgMenu CENTERED

//Atribui o valor a ser tratado no retorno da função
If lRet
	cOpcao := AllTrim(cValor)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ LjTEFTeste  ³ Autora³ Solange Zanardi    ³ Data ³ 01/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TELA PARA TESTES DE TRANSACAO SEM UTILIZAR INTERFACE       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFTeste()

Local oDlgTeste
Local oFontMens	:= TFont():New("Arial",07,17,,.T.)	//Fonte de exibição

// Composicao da aDados
Local cForma   	:= "CC"
Local dData    	:= dDataBase
Local cHora    	:= SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2)
Local nValor   	:= Round(10.00,2)
Local nParc    	:= 1
Local nInter   	:= 0
Local cAdm	   	:= "VISA"
Local aDados   	:= { }
Local cOperacao := " "				

DEFINE MSDIALOG oDlgTeste FROM 000,000 TO 100,470 TITLE STR0141 STYLE DS_MODALFRAME PIXEL //"TELA PARA TESTES"
@ 004,007 SAY "Forma" FONT oFontMens COLOR CLR_BLUE SIZE 50,10 OF oDlgTeste PIXEL
@ 004,050 MSGET cForma SIZE 50,10 OF oDlgTeste PIXEL

@ 016,007 SAY "Valor" FONT oFontMens COLOR CLR_BLUE SIZE 50,10 OF oDlgTeste PIXEL
@ 016,050 MSGET nValor SIZE 50,10 Picture ("999.99") OF oDlgTeste PIXEL

@ 028,007 SAY "Data" FONT oFontMens COLOR CLR_BLUE SIZE 50,10 OF oDlgTeste PIXEL
@ 028,050 MSGET dData SIZE 50,10 Picture ("@D") OF oDlgTeste PIXEL

DEFINE SBUTTON FROM 39,174 TYPE 1 ENABLE OF oDlgTeste ACTION (lRet:=.T.,oDlgTeste:End()) PIXEL
DEFINE SBUTTON FROM 39,204 TYPE 2 ENABLE OF oDlgTeste ACTION (lRet:=.F.,oDlgTeste:End()) PIXEL

ACTIVATE DIALOG oDlgTeste CENTER

If lRet
	If oTEF:lAtivo
		oTef:aDados 	:= { {dData, nValor, cForma, "1", nParc, nValor, {}} }
		oTef:cCupom 	:= StrZero(Randomize(1,999999),6,0)
		oTef:cOperador 	:= "TEF"
	EndIf
	lRet := .F.
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ LjRotTEF    ³ Autor ³ Vendas Clientes    ³ Data ³ 10/03/05 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJRotTEF
Local oDlg										//Objeto Dialog
Local cTipTEF := LJGetStation("TIPTEF")			//Indica o tipo de TEF
Local lSigaTmk:= .F.                           //Indica se esta no mod. SIGATMK ou SIGACRM
Local lFtvdVer12	:= FindFunction("LjFTvd") .AND. LjFTVD() 		//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lTmka150	:= IsInCallStack("TMKA150")

Private oPbm	:= NIL	  						// Inicializando o objeto oPbm
If nModulo == 13 .OR. nModulo == 73 .OR. cModulo =='TMK' .OR. (nModulo == 05 .AND. cTipTEF <> TEF_DISCADO)
   lSigaTmk  := .T.
EndIf

If lFtvdVer12
	OpenLoja()
EndIf

If !lUsaTef .AND. !lTmka150
	Help(" ","1","NAOTEF")
	Return(NIL)
EndIf

If lSigaTmk
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando estiver sendo chamado pelo SIGATMK, a opcao CliSitef ³
	//³ deve ser alterada para 6 ficando igual ao DEFINE do LOJA    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipTEF == "4"
		cTipTEF := "6"
	Endif
Endif

If cTipTEF == TEF_SEMCLIENT_DEDICADO

	DEFINE MSDIALOG oDlg TITLE STR0093 FROM 00,00 TO 280,200 OF GetWndDefault() PIXEL	//"Rotinas TEF"

		@ 10,10 BUTTON STR0102	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA011T(), oDlg:End() )	//"Cancelamento Manual TEF"
		@ 30,10 BUTTON STR0103 	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA012T(), oDlg:End() )	//"Consulta TEF"
		@ 50,10 BUTTON STR0104 	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA013S(), oDlg:End() )	//"Reimpressão TEF"
		@ 70,10 BUTTON STR0107 	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA024T(), oDlg:End() )	//"Reimpressão VISA"
		@ 90,10 BUTTON STR0105	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA019T(), oDlg:End() )	//"Transações Administrativas"
		@110,10 BUTTON STR0099	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )				//"&Sair"

	ACTIVATE MSDIALOG oDlg CENTERED

ElseIf cTipTEF == TEF_COMCLIENT_DEDICADO

	DEFINE MSDIALOG oDlg TITLE STR0093 FROM 00,00 TO 200,200 OF GetWndDefault() PIXEL	//"Rotinas TEF"

		@ 10,10 BUTTON STR0102	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA011T(), oDlg:End() )	//"Cancelamento Manual TEF"
		@ 30,10 BUTTON STR0103	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA012T(), oDlg:End() )	//"Consulta TEF"
		@ 50,10 BUTTON STR0105	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA019T(), oDlg:End() )	//"Transações Administrativas"
		@ 70,10 BUTTON STR0099	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )				//"&Sair"

	ACTIVATE MSDIALOG oDlg CENTERED

ElseIf cTipTEF == TEF_DISCADO

	DEFINE MSDIALOG oDlg TITLE STR0093 FROM 00,00 TO 240,200 OF GetWndDefault() PIXEL	//"Rotinas TEF"

		@ 10,10 BUTTON STR0102	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA011T(), oDlg:End() )	//"Cancelamento Manual TEF"
		@ 30,10 BUTTON STR0103	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA012T(), oDlg:End() )	//"Consulta TEF"
		@ 50,10 BUTTON STR0105	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA019T(), oDlg:End() )	//"Transações Administrativas"
		@ 70,10 BUTTON STR0104	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA013S(), oDlg:End() )	//"Reimpressão TEF"
		@ 90,10 BUTTON STR0099	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )				//"&Sair"

	ACTIVATE MSDIALOG oDlg CENTERED

ElseIf cTipTEF == TEF_LOTE

	DEFINE MSDIALOG oDlg TITLE STR0093 FROM 00,00 TO 160,200 OF GetWndDefault() PIXEL	//"Rotinas TEF"
	
		@ 10,10 BUTTON STR0101	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA017T(), oDlg:End() )	//"TEF em Lote"
		@ 30,10 BUTTON STR0101	SIZE 80,20 OF oDlg PIXEL ACTION ( LOJA018T(), oDlg:End() )	//"TEF em Lote"
		@ 50,10 BUTTON STR0099	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )				//"&Sair"
		
	ACTIVATE MSDIALOG oDlg CENTERED
	
ElseIf cTipTEF == TEF_CLISITEF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ No SIGATMK as opcoes do menu sao diferentes   	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSigaTmk
		If !lTmka150
			DEFINE MSDIALOG oDlg TITLE STR0093 FROM 00,00 TO 270,200 OF GetWndDefault() PIXEL	//"Rotinas TEF"
			
				@ 010,10 BUTTON STR0094 	SIZE 80,18 OF oDlg PIXEL ACTION ( oTEF:Operacoes("GERENCIAIS",{}),	oDlg:End() )	//"Rotinas Gerenciais"
				@ 030,10 BUTTON STR0095		SIZE 80,18 OF oDlg PIXEL ACTION ( LjCancCred()  	,oDlg:End() )					//"Estorno de Crédito"
				@ 050,10 BUTTON STR0097		SIZE 80,18 OF oDlg PIXEL ACTION ( LjCancCapt()  	,oDlg:End() )					//"Estorno de Captura Pré-Aut."
				@ 070,10 BUTTON STR0098		SIZE 80,18 OF oDlg PIXEL ACTION ( LjCancPreAut()	,oDlg:End() )					//"Estorno de Pré-Autoriz."
				@ 090,10 BUTTON STR0099	    SIZE 80,18 OF oDlg PIXEL ACTION ( oDlg:End() )										//"&Sair"
				
			ACTIVATE MSDIALOG oDlg CENTERED
		Else 
			LjCancCred()
		EndIf
	Else
			
		DEFINE MSDIALOG oDlg TITLE STR0093 FROM 00,00 TO 240,200 OF GetWndDefault() PIXEL	//"Rotinas TEF"
		
			@ 10,10 BUTTON STR0094	SIZE 80,20 OF oDlg PIXEL ACTION ( IF(LJProfile(17), oTEF:Operacoes("GERENCIAIS",{}), .F.), oDlg:End() )	//"Rotinas Gerenciais"		
			@ 30,10 BUTTON STR0100 	SIZE 80,20 OF oDlg PIXEL ACTION ( LJRotCB(), oDlg:End() )							//"Corresp. Bancário"
			@ 50,10 BUTTON STR0099	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )										//"&Sair"
			
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Endif
EndIf
If lFtvdVer12
	FinishLoja(.T.)
Endif
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LjRotCB     ³ Autor ³ Cesar Valadao      ³ Data ³ 20/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de acesso ao Correspondente Bancario                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJRotCB()
Local lOk := .F.							//Retorno da funcao LjWsCbOk
Local lConfirmado := .F.

//Verifica se o WS esta no ar #"Aguarde...Verificando comunicação com o WebService!"
If nModulo == 12 //Venda Assistida
	lOk := .T.
Else
	LjMsgRun(STR0140,, {|| lOk := LjWsCbOk()})
EndIf

//Verifica se o parametro de Forma de Pagamento Dinheiro do Correspondente Bancario esta cadastrado.
If lOk
	LjMsgRun(STR0140,, {|| lOk := LjVCadCB()})
EndIf

If lOk

	oTEF:Operacoes("CB", {})

	If oTEF:lTEFOk
		
		If ValEstCB()
			oTef:LjEstornoCB()
		Else
			lConfirmado := oTEF:ImpCupTef() 	// Imprime o cupom TEF e confirma a transacao  
			If oTEF:lImprimiu .or. lConfirmado
				oTef:LjGravaCB()  
			EndIf          	
		EndIf
	Else
		//Envia o desfazimento se a transacao nao for ok
		oTEF:FinalTrn(0)
	EndIf
EndIf
Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LjCaptPreAut ³ Autor ³ Cleber Martinez    ³ Data ³ 07/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de captura de pre-autorizacao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCaptPreAut()

oTef:Operacoes("CAPTURA_PRE_AUTORIZ",{})

If oTef:lTefOk
	oTef:FinalTrn(1)	//Finaliza a TRN com parametro confirma = 1
Endif

Return NIL
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LjCancCapt   ³ Autor ³ Cleber Martinez    ³ Data ³ 07/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de cancelamento de captura de pre-autorizacao       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCancCapt()

oTef:Operacoes("CANCELA_CAPTURA",{})

If oTef:lTefOk
	oTef:FinalTrn(1)	//Finaliza a TRN com parametro confirma = 1
Endif

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LjCancCred   ³ Autor ³ Cleber Martinez    ³ Data ³ 08/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de cancelamento de venda com cartao (Televendas)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCancCred()
oTef:Operacoes("CANCEL_TELEMARKETING",{})
If oTef:lTefOk
	oTef:FinalTrn(1)	//Finaliza a TRN com parametro confirma = 1
Endif 

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LjCancPreAut ³ Autor ³ Cleber Martinez    ³ Data ³ 08/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de cancelamento de Pre-Autorizacao  (Televendas)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjCancPreAut()
oTef:Operacoes("CANCEL_PRE_AUTORIZ",{})
If oTef:lTefOk
	oTef:FinalTrn(1)	//Finaliza a TRN com parametro confirma = 1
Endif

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LjMsgStop   ³ Autor ³ Cesar Valadao      ³ Data ³ 23/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir mensagem na tela com fechamento automatico          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjMsgStop( cCaption, cTitle, nTimeOut)
Local oDlg
Local nWidth
Local oFont
Local nRight
Local oTimer
Local nOp := 0

DEFINE FONT oFont NAME "Arial" SIZE 6,14 BOLD

DEFAULT cCaption	:= "Aguarde por favor..."
DEFAULT cTitle		:= "Siga Advanced Protheus"
Default nTimeOut	:= 5

nRight := Max( Len( cCaption ), Len( cTitle ) ) + 16

DEFINE DIALOG oDlg FROM 0,0 TO 6,nRight  TITLE cTitle STYLE DS_MODALFRAME
	oDlg:SetFont(oFont)
	nWidth := oDlg:nRight - oDlg:nLeft
	@ 3,0 Say xPadc(cCaption,nWidth) of oDlg PIXEL

	oDlg:cMsg	:= cCaption

	DEFINE TIMER oTimer INTERVAL nTimeOut*1000 ACTION oDlg:End() OF oDlg
	oTimer:Activate()

	DEFINE SBUTTON FROM 30,(nRight*3)-8 TYPE 1 ACTION ( oDlg:End(),nOp:= 1 ) ENABLE OF oDlg

ACTIVATE DIALOG oDlg CENTER

Return nOp==1

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJGRVCANCTºAutor  ³Vendas Clientes     º Data ³  13/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as informacoes de cancelamento de TEF, apos ser aprovaº±±
±±º          ³da a transacao de cancelamento.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1 - Define se realiza a gravacao das informacoes nos   º±±
±±º          ³         arquivos                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet - Retorna se achou o NSU                              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJGRVCANCT( lGrava )
Local lRet			:= .F.				// Retorno da funcao
Local nI			:= 1				// Contator do While
Local lRetIndex     := .T.				// Verifica se existem os indices necessarios para a operacao
Local cAliasCanc	:= ""				// Contem alias com dados da transacao TEF
Local lRecebSlv		:= .F.
Local cNSUDoc		:= ""
Local lLjCanPre		:= ExistFunc("P_LJTCANP")	// Cancelamento da pre venda
Local lGerSLI		:= .F.
Local xRet
Local lMvLjPdvPa    := LjxBGetPaf()[2] //Indica se eh pdv PAF
Local cMsgSLI		:= ""

If nModulo = 12 .AND. AllTrim(Upper(FunName())) == "LOJA701" .AND. Type("lRecebe") == "L"
	lRecebSlv	:= lRecebe .AND. AliasIndic("SLV")
EndIf

If LJContIndex("SL4") < 3
	MsgStop(STR0145)	//Nao existem os indices 2 e 3 na tabela SL4 (Consultar os Boletins Tecnicos referente aos Bops 118977 e 119293  )
	lRetIndex	:= .F.	
EndIf

If lRetIndex .AND. (If(oTef:nTipoCampo <> 516 .AND. oTEF:lHomolog, .F.,.T.))
	If lRecebSlv
		cAliasCanc	:= "SLV"
		nI			:= 2
	Else
		cAliasCanc	:= "SL4"	
	EndIf  
	
	DBSelectArea(cAliasCanc)
	While ++nI <= 3 .And. !lRet
		If lRecebSlv
			DBSetOrder( 3  )		
		Else
			DBSetOrder( nI )
		EndIF
		
		/*Valida se é reimpressão ou cancelamento*/
		If !Empty(oTef:aRetCartao[oTef:nTrans]:dDataCanRei)
			cNSUDoc	:= oTef:aRetCartao[oTef:nTrans]:cDocCanRei
			If Len(cNSUDoc) > 6 .AND. lRecebSlv
				cNSUDoc	:= SubStr(cNSUDoc,4,6)			
			EndIf
		
			cSeek	:=  xFilial(cAliasCanc) + IIf( lRecebSlv ,   cNSUDoc ,  DtoS(oTef:aRetCartao[oTef:nTrans]:dDataCanRei) +       cNSUDoc) 
			
			If dbSeek( cSeek )
				lRet	:= .T.
				If !lRecebSlv .And. cModulo != 'TMK' .AND. (nModulo <> 05) 
					dbSelectArea("SL1")
					SL1->(dbSetOrder(1))
					lRet := SL1->(dbSeek( xFilial("SL1") + SL4->L4_NUM )) .AND. ( (LjGetStation( "PDV" ) == Alltrim(SL1->L1_PDV) ) .OR. (Empty(SL1->L1_PDV) .AND. (!lFiscal .Or. SL1->L1_IMPNF )) ) .OR. Empty(L1_NUMCFIS)
					If !lRet
						// "PDV não localizado."
						MsgInfo( STR0116 )
						Inkey(3)
					EndIf
				EndIf
			EndIf
			If lRet .AND. lGrava
				If !lRecebSlv .And. cModulo != 'TMK'
					Reclock("SL1", .F.)
					REPLACE SL1->L1_DOCCANC With oTef:aRetCartao[1]:cNsuAutor
					REPLACE SL1->L1_DATCANC With StrTran(DToC(oTef:aRetCartao[1]:dDataCanRei),"/","")
					REPLACE SL1->L1_HORCANC With oTef:aRetCartao[1]:cHoraTrans
					SL1->(MSUnlock())
					lGerSLI := .T.					
				EndIf
				
				DbSelectArea(cAliasCanc)
				While !Eof() .AND. DtoS(oTef:aRetCartao[oTef:nTrans]:dDataCanRei) == ((cAliasCanc)->&(SubStr(cAliasCanc,2,2)+ "_DATATEF")) .AND.;
					Alltrim(oTef:aRetCartao[oTef:nTrans]:cDocCanRei) == IIf( nI == 2 , Alltrim(((cAliasCanc)->&(SubStr(cAliasCanc,2,2)+ "_DOCTEF"))) ,Alltrim(((cAliasCanc)->&(SubStr(cAliasCanc,2,2)+ "_NSUTEF"))))   // Compara o campo de acordo com o indice
					Reclock(cAliasCanc, .F.)
				  	REPLACE &(SubStr(cAliasCanc,2,2) + "_DOCCANC") With oTef:aRetCartao[1]:cNsuAutor 
				  	REPLACE &(SubStr(cAliasCanc,2,2) + "_DATCANC") With StrTran(DToC(oTef:aRetCartao[1]:dDataCanRei),"/","")
					REPLACE &(SubStr(cAliasCanc,2,2) + "_HORCANC") With oTef:aRetCartao[1]:cHoraTrans
					// Atualiza registro SL4 como Estornado
					If !lRecebSlv
					  	REPLACE &(SubStr(cAliasCanc,2,2) + "_ESTORN")  With "S"
					  	REPLACE &(SubStr(cAliasCanc,2,2) + "_OPERAES") With xNumCaixa()
					Endif
					MsUnlock()
					(cAliasCanc)->( dbSkip() )
					lGerSLI := .T.
				End
			EndIf
			
			If (lMvLjPdvPa .Or. (nModulo == 23)) .And. lGerSLI
				// Atualiza a SLI para enviar a retaguarda o cancelamento 
				cMsgSLI := SL1->L1_FILIAL + SL1->L1_SERIE + SL1->L1_DOC + SL1->L1_PDV + "|"
				cMsgSLI += oTef:aRetCartao[1]:cNsuAutor + "|" + StrTran(DToC(oTef:aRetCartao[1]:dDataCanRei),"/","") + "|" + oTef:aRetCartao[1]:cHoraTrans + "|"
				cMsgSLI += "S|" + xNumCaixa() + "|" + AllTrim(oTef:aRetCartao[oTef:nTrans]:cDocCanRei) + "|" + DtoS(oTef:aRetCartao[oTef:nTrans]:dDataCanRei)
				FR271BGerSLI(Space(TamSX3("LI_ESTACAO")[1]), "TEF", cMsgSLI, "NOVO")
			EndIf

		Else
			lRet := .T.
		EndIf
	End  
	/*No caso do cancelamento do TEF no recebimento de titulos
	  nao temos SL4 , porisso deve verificar a tabela SLV     */
	If !lRet .AND. !lRecebSlv .AND. nModulo = 12 .AND. AllTrim(Upper(FunName())) == "LJROTTEF" .AND. AliasIndic("SLV")
		DbSelectArea("SLV")									
		DbSetOrder(3) 	//LV_FILIAL+LV_NSUTEF
		If DbSeek(xFilial("SLV")+ cNSUDoc)
			lRet	:= .T.					
		Else
			DbSelectArea("SIX")
			DbSetOrder(1)
			If DbSeek("SLV"+"4")
				DbSelectArea("SLV")
				DbSetOrder(4) 	//LV_FILIAL+LV_DOCTEF
				If DbSeek(xFilial("SLV")+ cNSUDoc)
					lRet	:= .T.
				EndIf
			EndIf
	    EndIf
	EndIf
EndIf	

If (oTef:nTipoCampo == 516 .AND. (oTEF:lHomolog .OR. nModulo == 5 .OR. nModulo == 51 .OR. oTef:nCodFuncao == 670 .OR. oTef:nCodFuncao == 257) ) //670=Cancelamento de Recarga de Gift Card (Modulo GIVEX) ; 257=Cancelamento de Recarga de Gift Card (Modulo SQCF - Todo Cartoes)
	lRet := .T.
EndIf

If lLjCanPre .AND. !lRet

	xRet :=	P_LJTCANP() 	// Caso for pre venda deve permitir o cancelamento mesmo sem ter SL4	
	If ValType(xRet) == "L"
		lRet := xRet
	EndIf
    
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³SitefDiretoºAutor  ³Microsiga           º Data ³  10/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envia transacao para o Sitef                                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method SitefDireto(	nRedeDestino	, nFuncaoSitef	, nOffSetCartao	, cDadosTx			, ;
					nTamDadosTx		, cDadosRx		, nTamMaxDadosRx, nCodigoResposta 	, ;
					nTempoEsperaRx 	, cCupomFiscal 	, cDataFiscal	, cHorario 			, ;
					cOperador 		, nTipoTransacao ) Class MSTEF

Local nRet	:= 0			// Retorno da funcao

nRet := oAutocom:SIT_ENVDIR( 	nRedeDestino	, nFuncaoSitef	, nOffSetCartao	, cDadosTx			, ;
								nTamDadosTx		, cDadosRx		, nTamMaxDadosRx, nCodigoResposta 	, ;
								nTempoEsperaRx 	, cCupomFiscal 	, cDataFiscal	, cHorario 			, ;
								cOperador 		, nTipoTransacao )

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LeCartDir ºAutor  ³Microsiga           º Data ³  02/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aciona a funcao do Pin-Pad para leitura de cartao          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LeCartDir(cMensagem, cTrilha1, cTrilha2) Class MSTEF
	
Local nRet := 0		// Retorno da funcao

nRet := oAutocom:SIT_LECART( cMensagem, @cTrilha1, @cTrilha2 )

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjCancPbm ºAutor  ³Vendas Clientes     º Data ³  11/21/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela as transacoes da PBM pendentes                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LjCancPbm(cCupom, cData, cHora, lDelArqTef, lMV_LJCFTEF, cMVLJTEFPD, lDesfSav) Class MSTEF

Local oCancPBM	:= LjCGlobal():Global()			// Objeto Global
Local oArquivos									// Objeto de arquivos
Local nX		:= 0							// Variavel do FOR
Local nCount	:= 0							// Retona o numero de arquivos no diretorio
Local cArqCanc	:= ""							// Guarda a string para o cancelamento
Local oDados									// Guarda as informacoes para o cancelamento da PBM
Local cMensagem  := ""
Local cMensagem2  := ""
Local nFinalTrn := 0							//Finalização da transação TEF
Local cMenProc := ""
	
oArquivos 	:= oCancPBM:GravarArq():TransTef(Time(), DtoS(Date())):LerArqs()
    
nCount		:= oArquivos:Count()
    
If nCount > 0
   	::lTemPbm := .T.
   	

	If (lMV_LJCFTEF .And. Empty(cMVLJTEFPD)) .Or. cMVLJTEFPD == "1" //1=Confirma
	   	// Se na entrada do sistema existir transacoes pendentes, as mesmas serao CONFIRMADAS 
		cMensagem := "Confirmando Transacao PBM pendente."
		cMensagem2 := "Todas as transacöes PBM pendentes foram confirmadas!"
		nFinalTrn := 1
	ElseIf (!lMV_LJCFTEF .And. Empty(cMVLJTEFPD)) .Or. cMVLJTEFPD == "2" //2=Cancela
		// Se na entrada do sistema existir transacoes pendentes, as mesmas serao CANCELADAS 
		cMensagem := "Cancelando Transacao PBM pendente."
		cMsgCompl := "Todas as transacöes  PBM pendentes foram canceladas!"
		nFinalTrn := 0
	ElseIf cMVLJTEFPD == "3" .AND. !lDesfSav //3=Mantem a transacao pendente (para futura intervencao manual no SITEF pela equipe de TI)
		cMensagem2 := "A transação TEF permanecerá PENDENTE. Comunique o departamento de TI sobre esta ocorrência."
		nFinalTrn := -1
	ElseIf lDesfSav
		cMensagem := "Cancelando Transacao PBM pendente nao recuperada."
		cMensagem2 := "Todas as transacöes pendentes PBM não recuperadas foram canceladas!"
		nFinalTrn := 0		
	Endif 
	
	
	    
For nX := 1 To nCount
    
   	cArqCanc	:= oArquivos:Elements(nX):Dados():Elements(1):Linha()

   	oDados 		:= oCancPBM:Funcoes():Split(cArqCanc, "/")
    	
	   	If nFinalTrn <> -1
			oCancPBM:GravarArq():Log():Tef():_Gravar(cMensagem)
			If  cCupom <> oDados:Elements(1)
		
					cMenProc := "FinalizaTransacaoSiTefInterativo(Confirma:" +  Alltrim(Str(nFinalTrn)) + "Cupom: " + oDados:Elements(1) + ", Data: " + oDados:Elements(2) + ", Hora: " + oDados:Elements(3) + ")"
					oCancPBM:GravarArq():Log():Tef():Gravar(cMenProc)		
		    	
	//"Cancelando Transacao PBM. Aguarde..."
					LjMsgrun(STR0124, NIL, {|| oAutocom:SIT_FINAL(nFinalTrn, oDados:Elements(1), oDados:Elements(2), oDados:Elements(3) ) } )
					oCancPBM:GravarArq():Log():Tef():_Gravar("Transacao PBM " + IIF( nFinalTrn = 0 , "Desfeita", "Confirmada") + " (" + oDados:Elements(1) + " - " + oDados:Elements(2) + " - " + oDados:Elements(3) + ")")
	
			EndIf
		
	oArquivos:Elements(nX):Apagar()
		Else
			cMensagem := "Mantendo a Transacao PBM pendente. Cupom: " + oDados:Elements(1) + ", Data: " + oDados:Elements(2) + ", Hora: " + oDados:Elements(3)
			oCancPBM:GravarArq():Log():Tef():_Gravar(cMensagem)
		EndIf	
			
		MsgInfo("Pode ter ocorrido algum problema na transação de PBM. Favor verificar!" + Chr(10)+ Chr(13) + cMensagem2)	//"Pode ter ocorrido algum problema na transação de Cartão. Favor verificar a ultima venda!"
		
	Next nX
EndIf
		
		
    

    
Return NIL


//"TABELA DE FUNCOES DA SOFTWARE EXPRESS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³0 		A CliSiTEF permite que o operador escolha a forma de pagamento através de menus                                                                                                                         ³
//³1 a 99 	Reservado                                                                                                                                                                                               ³
//³                                                                                                                                                                                                                 ³
//³100 		Telemarketing: Inicia a coleta dos dados da transação no ponto necessário para tratar uma transação de cartão de crédito digitado                                                                       ³
//³                                                                                                                                                                                                                 ³
//³110 		Abre o leque das transações Gerenciais                                                                                                                                                                  ³
//³111 		Teste de comunicação com o SiTEF                                                                                                                                                                        ³
//³112 		Menu Re-impressão                                                                                                                                                                                       ³
//³113 		Re-impressão comprovante específico                                                                                                                                                                     ³
//³114 		Re-impressão ultimo comprovante                                                                                                                                                                         ³
//³115 		Pré-autorização                                                                                                                                                                                         ³
//³116  	Captura de pré-autorização                                                                                                                                                                              ³
//³                                                                                                                                                                                                                 ³
//³200 		Cancelamento Normal: Inicia a coleta dos dados no ponto necessário para fazer o cancelamento de uma transação de débito ou crédito, sem ser necessário passar antes pelo menu de transações admin.      ³
//³201 		Cancelamento Telemarketing: Similar a modalidade 200 só que para a função de cancelamento de transação de crédito digitado                                                                              ³
//³202  	Cancelamento Pré-autorização                                                                                                                                                                            ³
//³203  	Cancelamento da Captura da Pré-autorização                                                                                                                                                              ³
//³300 		Recarga de pré-pago                                                                                                                                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//"TABELA DE RESTRICOES DA SOFTWARE EXPRESS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|   C H E Q U E S 													|
//³10 Consulta ou garantia de Cheque (todos os tipos)					³
//³11 Consulta Cheque Serasa/Associação Comercial						³
//³12 Consulta Cheque Tecban											³
//³13 Telecheque Garantido Tecban	                                    ³
//³14 Garantia Cheque Papel Tecban	                                    ³
//|                   	 						  						|                                                                        
//|   D E B I T O														|
//³15 Cartão de débito (todas as combinações)	                        ³
//³16 Cartão de débito a vista	                                        ³
//³17 Cartão de débito pré-datado	                                    ³
//³18 Cartão de débito parcelado	                                    ³
//|                   	 						  						|                                                                        
//|   D E B I T O	C D C												|
//³19 Cartão de débito CDC	                                            ³
//|                   	 						  						|                                                                        
//|   R E F E I C A O		 											|                                                                        
//³20 Cartão Refeição Eletrônico	                                    ³
//|                   	 						  						|                                                                        
//|   C R E D I T O 			              							|                                                                        
//³25 Cartão de crédito (todas as combinações)	                      	³
//³26 Cartão de crédito a vista	                                        ³
//³27 Cartão de crédito parcelado com financiamento do estabelecimento	|
//³28 Cartão de crédito parcelado com financiamento da administradora	³
//³29 Cartão de crédito digitado	                                    ³
//³30 Cartão de crédito magnético	                                    |
//³34 Cartão de Crédito Pró-rata a vista	                            ³
//³35 Cartão de Crédito Pró-rata parcelada	                            |
//³32 Cartão Fininvest	                                              	³
//³33 Saque com cartão Fininvest	                                    ³
//³36 Consulta parcelas no Cartão de Crédito	                        ³
//|                   	 						  						|                                                                        
//|   P R E - A U T O R I Z A C A O            							|                                                                                                                                                ³
//³31 Pré-autorização	                                                ³
//|                   	 						  						|                                                                        
//|   C A N C E L A M E N T O											|                                                                        
//³40 Cancelamento de transação com cartão de crédito ou débito	40      ³
//|                   	 						  						|                                                                        
//|   C O R R E S P O N D E N T E  B A N C A R I O 						|                                                                        
//³50 Pagamento de Conta	                                            ³
//³51 Estorno de pagamento de conta	                                    ³
//³52 Re-impressão de pagamento de conta	                            ³
//³53 Pagamento de Benefício                                            ³
//³54 Estorno do Pagamento de Benefício	                                ³
//|                   	 						  						|                                                                        
//|   T R O C O        	 						  						|                                                                        
//³55 Tratamento de troco no pagamento de contas com dinheiro	      	³
//|                   	 						  						|                                                                        
//|   R E C A R G A  D E  C E L U L A R									|                                                                       
//³60 Recarga de celular com Dinheiro	                               	³
//³61 Recarga de celular com Cheque	                                    ³
//³62 Recarga de celular com cartão de débito a vista	               	³
//³63 Recarga de celular com cartão de crédito a vista	              	³
//³64 Indica o Menu para seleção da operadora de recarga	            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Código da Modalidade                    	³//³Código da Modalidade                               	³
//³(parte mais significativa: xx)			³//³(parte menos significativa: nn)	Descrição          	³
//³00	Cheque                              ³//³00	À vista                                         ³
//³01	Cartão de Débito                    ³//³01	Pré-datado                                      ³
//³02	Cartão de Crédito                   ³//³02	Parcelado com financiamento pelo estabelecimento³
//³03	Cartão tipo Voucher                 ³//³03	Parcelado com financiamento pela administradora ³
//³98	Dinheiro                            ³//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//³99	Outro tipo de cartão                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjTEFConfAdm³ Autora³ Solange Zanardi     ³ Data ³ 11.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a descricao da adiministrado de cartos em uma     ³±±
±±³          ³ transacao TEF, qdo selecionada uma ADM <> da utilizada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJXTEF                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFConfADM(nPos,cAdmSele, cFormaCart)

Local aArea 		:= GetArea()											//Area atual de trabalho
Local aDadosSae 	:= {}													//Array com os dados da SAE {SAE->AE_COD, SAE->AE_DESC, SAE->AE_TAXA}
Local xRet
Local lIncluiSae	:= .T. 
Local lLjadmTef		:= FindFunction("U_LJADMTEF")			

DEFAULT cFormaCart 	:= ""

If !(AllTrim(Upper(oTef:aRetCartao[nPos]:cDescAdm)) $ AllTrim(Upper(cAdmSele))) .AND. Empty(oTef:aRetCartao[nPos]:cCodAdm)
    
    //Seleciona o arquivo
	DbSelectArea("SAE")
	
	//Posiciona no inicio do arquivo
	DbGoTop()
	
	//Lista o arquivo inteiro
	While !Eof() .AND. AE_FILIAL == xFilial("SAE")
	  	
		If lLjadmTef
			xRet :=	U_LJADMTEF()
			If ValType(xRet) == "L"
				lIncluiSae := xRet
			EndIf
		EndIf	
		
		If lIncluiSae	
			//Verifica se a administradora retornada da transação existe no SAE
			If Empty(cFormaCart) .OR. (AllTrim(SAE->AE_TIPO) == AllTrim(cFormaCart))
				If AllTrim(Upper(oTef:aRetCartao[nPos]:cDescAdm)) $ AllTrim(Upper(SAE->AE_DESC))
			    	AADD(aDadosSae, {SAE->AE_COD, SAE->AE_DESC } )
			    EndIf
			EndIf    
		EndIf    
		
		//Vai para o proximo registro
	    DbSkip()
	End
	
	If Len(aDadosSae) > 0
	    //Exibe a tela com as administradoras encontradas
	    LjSelecAdm(nPos, aDadosSae , cAdmSele )
	Else
		//"Administradora não cadastrada. Os lançamentos serão mantidos na Financiadora pré-selecionada."
		MsgStop(AllTrim(oTef:aRetCartao[nPos]:cDescAdm)+Chr(10)+STR0076+Chr(10)+Alltrim(cAdmSele),STR0005)
	    oTef:aRetCartao[nPos]:cCodAdm := cAdmSele
	EndIf
	
ElseIf Empty(oTef:aRetCartao[nPos]:cCodAdm)
	oTef:aRetCartao[nPos]:cCodAdm := cAdmSele
EndIf

RestArea(aArea)

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjSelecAdm³ Autora³ Vendas Clientes     ³ Data ³ 07.11.08   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe uma tela para seleção da administradora SAE          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJXTEF                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjSelecAdm(nPos, aDadosSae , cAdmSele, cIdCartao, cFormaCart, cValorCart )
	
Local oDlg 	:= Nil
Local oList	:= Nil
Local cRet 	:= ""

DEFAULT cAdmSele := ""    
DEFAULT nPos	 := 1
DEFAULT cIdCartao		:= ""
DEFAULT cFormaCart	:= "" 
DEFAULT cValorCart	:= ""


If Len(aDadosSae) > 1
	//DIALOG                           "Administradora Financeira"    Desabilita fechar a tela
	DEFINE MSDIALOG oDlg FROM 34,155 TO 350,570 TITLE STR0137 + " - ID Cartao: " + cIdCartao + " - " + "Tipo: " + cFormaCart + " - " + "Valor: " + Alltrim(cValorCart) PIXEL STYLE DS_MODALFRAME

	oDlg:lEscClose := .F.    

	//ListBox							"Código" "Descrição"
	@ 05,05 LISTBOX oList FIELDS HEADER STR0138, STR0139 SIZE 198,138 OF oDlg PIXEL
	
	oList:SetArray (aDadosSae)
	oList:bLine := {|| {aDadosSae[oList:nAT,01], aDadosSae[oList:nAT,02]}}	
	oList:SetFocus()

	//Button
	DEFINE SBUTTON FROM 145, 178 TYPE 1 ENABLE OF oDlg Action (LjCapADM(nPos, oList, aDadosSae , 1, @cAdmSele  ),oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTER VALID LjCapADM(nPos, oList, aDadosSae , 2 , @cAdmSele )

	If cTipTEF == TEF_DISCADO .OR. (cTipTEF == TEF_NAO_USADO .AND. lUsaTef)
		cRet := cAdmSele
	Else	
		cRet := oTef:aRetCartao[nPos]:cCodAdm
	Endif	
Else                            
	If cTipTEF == TEF_DISCADO .OR. (cTipTEF == TEF_NAO_USADO .AND. lUsaTef)
		cRet := cAdmSele
	Else	
		cRet := aDadosSae[1][1]+" - "+AllTrim(Upper(aDadosSae[1][2]))
		oTef:aRetCartao[nPos]:cCodAdm := cRet
	Endif
EndIf	

Return(cRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjCapADM³ Autora³ Vendas Clientes     ³ Data ³ 07.11.08     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Captura do listbox a administradora selecionada SAE        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJXTEF                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjCapADM(nPos, oList, aDadosSae , nOpcao , cAdmSele )

Local lRet := .T.

DEFAULT cAdmSele	:= ""
DEFAULT nOpcao		:= 1
    
	If nOpcao == 1              
		If cTipTEF <> TEF_DISCADO .AND. cTipTEF <> TEF_NAO_USADO	
			oTef:aRetCartao[nPos]:cCodAdm := aDadosSae[olist:nAt][1] + " - " + AllTrim(Upper(aDadosSae[olist:nAt][2]))
		Else 
			cAdmSele := aDadosSae[olist:nAt][1] + " - " + AllTrim(Upper(aDadosSae[olist:nAt][2]))		
		Endif	
	Else
		If cTipTEF <> TEF_DISCADO .AND. cTipTEF <> TEF_NAO_USADO
			If Empty(oTef:aRetCartao[nPos]:cCodAdm )
				MsgStop(STR0136)//" Selecione uma Administradora "
				lRet := .F.
			EndIf	                               
		Endif	
	EndIf
	
Return lRet

/*                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJVerifSLGºAutora ³Vendas Clientes     º Data ³  07/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para posicionar no registro da tabela SLG           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJVerifSLG()
Local cCodEstacao   := LJGetStation("LG_CODIGO")	//Conteudo do campo LG_CODIGO	
Local lRet 			:= .F. 							// Retorno da funcao

DbSelectArea("SLG")	
DbSetOrder(1)
If DbSeek(xFilial("SLG")+cCodEstacao)
	lRet := .T.
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CupomReduz ºAuto  ³Vendas Clientes     º Data ³  12/08/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe cupom reduzido para ser impresso no rodapeº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method CupomReduz() CLASS MSTEF
	
	Local nCount 	:= 0										//Variavel auxiliar utilizada no for
	Local lRetorno 	:= .F.                 						//Retorno da funcao
	Local aCupom	:= {}										//Guarda as linhas do cupom reduzido
	Local cCupomRed	:= ""										//Cupom reduzido
	Local lCupomRed	:= SuperGetMV("MV_LJCUPRE",,.F.)        	//Verifica se o sitef esta parametrizado para cupom reduzido
	Local cDelimit 	:= CHR(10)									//Delimitador
	Local lLoop		:= .T.                 						//Variavel auxiliar utilizada no while
	Local nPos		:= 0				   						//Variavel auxiliar que guarda a posicao do delimitador na string
	Local cAux		:= ""										//Variavel auxiliar que guarda linha do cupom reduzido
	Local cOriginal	:= ""										//Guarda o conteudo original da variavel cCupomRed
	
	//Verifica se e array
	If ValType(oTef:aRetCartao) != "A"
		Return lRetorno
	EndIf
	
	//Verifica se esta configurado para cupom reduzido
	If lCupomRed    
        //Agrupa os cupons reduzidos de todas as transacoes
		For nCount := 1 To Len(oTef:aRetCartao)
			If !Empty(oTef:aRetCartao[nCount]:cCupom01)
				//Verifica se tem Chr 10
				If Substr(oTef:aRetCartao[nCount]:cCupom01, Len(oTef:aRetCartao[nCount]:cCupom01), 1) != CHR(10) 
					cCupomRed += oTef:aRetCartao[nCount]:cCupom01 + Chr(10)
				Else
					cCupomRed += oTef:aRetCartao[nCount]:cCupom01
				EndIf	
			EndIf
		Next nCount
				
		//Retira o delimitador do inicio da string
		If Substr(cCupomRed, 1, 1) == cDelimit
			cCupomRed := Substr(cCupomRed, 2)
		EndIf

		//Retira o delimitador do fim da string
		If Substr(cCupomRed, Len(cCupomRed), 1) == cDelimit
			cCupomRed := Substr(cCupomRed, 1, Len(cCupomRed) - 1)
		EndIf
		
		cOriginal := cCupomRed    
	
		cCupomRed := AllTrim(cCupomRed)
	    	
		While lLoop
		    //Procura o delimitador na string
			nPos := At(cDelimit, cCupomRed)
		    
		    //Verifica se encontrou o delimitador
			If nPos > 0 
				cAux := Substr(cCupomRed, 1, nPos-1)
				cCupomRed := Substr(cCupomRed, nPos + 1)
				
				If cAux != cDelimit .AND. cAux != CHR(13) .AND. !Empty(cAux)
					AADD(aCupom, cAux)
				Endif
			Else
				If !Empty(cCupomRed)
					AADD(aCupom, cCupomRed)
				EndIf
				
				lLoop := .F.
			EndIf
		End    
		
		lRetorno := (Len(aCupom) >= 1 .AND. Len(aCupom) <= 8  )
		
		If lRetorno
			oTef:cCupomRedu := cOriginal 
		EndIf
		
	EndIf
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SetDadChq  ºAuto  ³Vendas Clientes     º Data ³  12/01/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seta os dados do cheque capturados atraves do CMC7           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method SetDadChq(cBufCMC7) Class MSTEF
	
	Local cCmc7 	:= ""							//Codigo cmc7 so com caracteres numericos
	Local nCount 	:= 0							//Variavel auxiliar contador
	
	//Exemplos:
	//Itau
	//=34162252= 0180002055^ 591270040651/
	//341 62252 0180002055 591270040651
	//1   4     9  12           24
	//
	//Caixa
	//=10415648= 0219000235^ 400100867951/
	//104 15648 0219000235 400100867951
	//1   4     9  12        21
	//
	//Unibanco
	//=40908171= 0213001635^ 059711473518/
	//409 08171 0213001635 059711473518
	//1   4     9  12          23
	
	
	//Considerando so os caracteres numericos
	For nCount := 1 To Len(cBufCMC7)
		If IsDigit(Substr(cBufCMC7, nCount, 1))
			cCmc7 += Substr(cBufCMC7, nCount, 1)
		EndIf
	Next
		
	//Banco	
	oTef:cBco := Substr(cCmc7, 1, 3)
    //Agencia
	oTef:cAge := Substr(cCmc7, 4, 4)
    //Compesacao
	oTef:cCom := Substr(cCmc7, 9, 3)
    //Cheque
	oTef:cChe := Substr(cCmc7, 12, 6)
		
	Do Case
		//Banco do Brasil
		Case oTef:cBco == "001"
			oTef:cCta := Substr(cCmc7, 23, 7) 

        //Unibanco
		Case oTef:cBco == "409"
			oTef:cCta := Substr(cCmc7, 23, 7) 

        //Itau
		Case oTef:cBco == "341"
			oTef:cCta := Substr(cCmc7, 24, 6) 
        
		//Caixa Economica federal
		Case oTef:cBco == "104"
			oTef:cCta := Substr(cCmc7, 21, 9) 
        
		//Banco Frances e Brasileiro
		Case oTef:cBco == "348"
			oTef:cCta := Substr(cCmc7, 24, 6) 

   		//Benge
		Case oTef:cBco == "048"
			oTef:cCta := Substr(cCmc7, 23, 7) 
            
   		//Excel
		Case oTef:cBco == "641"
			oTef:cCta := Substr(cCmc7, 21, 9) 
            
        //Bradesco
		Case oTef:cBco == "237"
			oTef:cCta := Substr(cCmc7, 23, 6) 

		//Banestado
		Case oTef:cBco == "038"
			oTef:cCta := Substr(cCmc7, 24, 6) 

		//Sudameris
		Case oTef:cBco == "347"
			oTef:cCta := Substr(cCmc7, 20, 6) 

		//Noroeste
		Case oTef:cBco == "424"
			oTef:cCta := Substr(cCmc7, 22, 8) 

        //Panamericano
		Case oTef:cBco == "623"
			oTef:cCta := Substr(cCmc7, 23, 7) 
		
		//Santander
		Case oTef:cBco == "424"
			oTef:cCta := Substr(cCmc7, 22, 8) 

		//Nossa caixa
		Case oTef:cBco == "151"
			oTef:cCta := Substr(cCmc7, 21, 9) 

		//BankBoston
		Case oTef:cBco == "479"
			oTef:cCta := Substr(cCmc7, 22, 8) 

		//CityBank
		Case oTef:cBco == "745"
			oTef:cCta := Substr(cCmc7, 22, 8) 

		//America do Sul
		Case oTef:cBco == "215"
			oTef:cCta := Substr(cCmc7, 23, 7) 

		//Finasa
		Case oTef:cBco == "392"
			oTef:cCta := Substr(cCmc7, 22, 8) 
         
   		//Banespa
		Case oTef:cBco == "033"
			oTef:cCta := Substr(cCmc7, 22, 8) 

		//Banco Real
		Case oTef:cBco == "275"
			oTef:cCta := Substr(cCmc7, 23, 7) 

		//Bandeirantes
		Case oTef:cBco == "230"
			oTef:cCta := Substr(cCmc7, 23, 7) 

		//BMD
		Case oTef:cBco == "388"
			oTef:cCta := Substr(cCmc7, 24, 6) 

		//HSBC Bamerindus
		Case oTef:cBco == "399"
			oTef:cCta := Substr(cCmc7, 24, 6) 
        
		//Safra
		Case oTef:cBco == "422"
			oTef:cCta := Substr(cCmc7, 23, 7) 

		//BCN
		Case oTef:cBco == "291"
			oTef:cCta := Substr(cCmc7, 23, 7) 

		//Banco Holandes Unido
		Case oTef:cBco == "356"
			oTef:cCta := Substr(cCmc7, 23, 8) 
        
        //Outros
        OtherWise
        	oTef:cCta := Substr(cCmc7, 23, 7) 
				
	EndCase		

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjWsCbOk   ºAuto  ³Vendas Clientes     º Data ³  16/01/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o WS do correspondente bancario esta no ar       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjWsCbOk()

	Local oSrc		:= Nil									   		// Objeto do Webservice  
	Local lRetorno	:= .F.                                         // Retorno da funcao
	
	oSrc		:= WSLJFINACB():New()
	oSrc:_URL 	:= "http://"+Alltrim(LJGetStation("WSSRV"))+"/LJFINACB.apw"
    
	If oSrc:Conecta("")
		lRetorno := .T.
	Else
		lRetorno := .F.
		//"Não será possível efetuar o pagamento de conta. Sem comunicação com o WebService (Correspondente Bancário)!"
		//"Atenção"
		MsgStop(STR0134, STR0005)				
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRecCelProd ºAutor  ³Marcio Lopes        º Data ³  28/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o produto e recarga e                             º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LjRecCelProd( 	nVlrItem	, aParcTef, lTEFPendCS	, aTefBKPCS,;
						cSeqTrans 	, cCodProd, lTefPend ) Class MSTEF

Local lRet 		:= .F.									// Retorno da funcao
Local cMVLJPREC := SuperGetMV("MV_LJPREC", NIL, "")		// Retorna o codigo do produto para recarga

If !Empty( cMVLJPREC ) .AND. Alltrim(cCodProd) $ Alltrim(cMVLJPREC)
    oTef:Operacoes("RC1", aParcTef, @lTEFPendCS, @aTefBKPCS,;
				    cSeqTrans )
	If oTef:lTefOk
		nVlrItem	:= (oTef:aRetRecarga[Len(oTef:aRetRecarga)]:nValor/100)
		lTefPend	:= .T.
		lRet 		:= .T.
	EndIf
Else
	lRet := .T.
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RecargaNFiscalºAutor  ³Marcio Lopes        º Data ³  28/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o produto e recarga e                              º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method RecargaNFiscal() Class MSTEF

Local cRet := " "
Local cNumCaixa := xNumCaixa()
Local lINFCon := FindFunction("INFCon") //Verifica se a impressora esta ligada
Local lConfirmado := .F. //Cupom TEF Impresso e Confirmado
Local lImpNFisc 	:= FindFunction("INFIs") .AND. INFIs()
Local lCupomAberto  := .F.
Local lObrigaImp	:= .F.									//Indica se é obrigatorio a impressao do comprovante nao fiscal
Local aMensagem		:= {}									//[1] cabecalho [2] corpo [3] texto do botao da funcao Aviso
If LjCxAberto( Nil,cNumCaixa )

	If lImpNFisc
		If FindFunction("LJObgImpNF") .AND.	FindFunction("INFCon")	//LOJXFUNB.PRX e LOJXECF.PRX
			
			lObrigaImp := LjObgImpNF(2, @aMensagem)	//2-se obriga a impressao do comprovante de Recarga de Celular
			LjGrvLog("RECARGA_CELULAR", "Obriga a impressão do Comprovante de Recarga de Celular?", lObrigaImp)
			
			If lObrigaImp
				// testa comunicacao com ECNF
				lConectado := INFCon(.T.)
				LjGrvLog("RECARGA_CELULAR", "Resultado do teste de conexão", lConectado)

				If !lConectado .AND. Len(aMensagem)>0
					Aviso( aMensagem[1], aMensagem[2], {aMensagem[3]} )
				EndIf
			EndIf
		EndIf
	Else
		lCupomAberto := IFStatus(nHdlECF, "5", @cRet) == 7	//7-Cupom Aberto
		If lCupomAberto
			MsgAlert( STR0205 ) // "Cupom fiscal aberto. Não é possível realizar a Recarga de Celular!"
		EndIf
	EndIf
	If !lCupomAberto
		oTef:Operacoes( "RC" )
	
		If oTef:lTefOk
			lConfirmado := oTef:ImpCupTef()
			If oTEf:lImprimiu .OR. lConfirmado
				oTef:LjGrvBaixaCel()
			EndIf

			oTef:nCodFuncao := 0
		EndIf
	EndIf

EndIf

// destruimos o array
aSize(aMensagem,0)
aMensagem := Nil

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRetCel  ºAutor  ³Vendas Clientes     º Data ³  08/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a recarga de celular esta configurada.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LjRecCel() Class MSTEF

Local nCpoRedes	:= SLG->(FieldPos("LG_REDES"))			// Verifica se existe o campo LG_REDES
Local lRet 		:= .F.									// Retorno da funcao
		
If nCpoRedes > 0
	
	lRet := Subs( Alltrim( LjGetStation( "REDES" ) ), 3, 1 ) == "1"
		
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjGrvBaixaCelºAutor  ³Microsiga           º Data ³  20/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a funcao de wbservices para a gravacos dos dados da     º±±
±±º          ³ venda de recarga de celular nao fiscal                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method LjGrvBaixaCel() CLASS MSTEF

Local oSrc														// Objeto do Webservice
Local cPref         := ""										// Prefixo
Local cNumCupFis    := ""										// Numero do cupom fiscal
Local cParcela      := LjParcela(1, SuperGetMV("MV_1DUP"))		// Parcela
Local cNatureza     := ""										// Natureza da operacao
Local cCliente      := SuperGetMV("MV_CLIPAD",, "")				// Cliente padrao
Local cLoja         := SuperGetMV("MV_LOJAPAD",, "")			// Loja
Local dEmiss        := dDataBase								// Data de emissao
Local dVencto       := dDataBase								// Data de vencimento
Local cHist         := "RECARGA DE CELULAR"						// Historico da operacao  
Local nMoeda        := 1										// Tipo da moeda
Local cPrw	         := "LOJXTEF"								// Programa que gerou o lancamento
Local nValTit       := (oTef:aRetRecarga[1]:nValor)/100		// Valor da transacao     
Local cPortado      := xNumCaixa()								// Caixa que realizou a opercao
Local oDlgVA													// Objeto da tela
Local oDlgChq													// Objeto da tela
Local aFontes       := {}										// Array com os fontes a serem utilizados para exibicao da tela
Local aAdminist     := {}
Local aBkpAdmFin    := {}
Local aTaxJuros     := {}
Local aDadosChq     := {}
Local aAreaSAE      := {}
Local aArPagto      := {}
Local aArParce      := {}
Local nMoedaCor     := 1
Local nVezes        := 0										// Parametro da Tela
Local cTipo         := ""					   					// Sigla da forma de pagamento
Local nCont         := 0										// Parametro da Tela
Local lBotaoOK      := .F.										// Variavel de retorno
Local lCancela      := .F.										// Variavel de cancelamento
Local cBanco        := ""										// Banco do cliente
Local cAgencia      := ""										// Agencia
Local cConta        := ""										// Conta
Local cNumChq       := ""										// Numero do Cheque
Local cCompensa     := ""										// Compensação
Local cRg           := ""										// Rg do cliente
Local cTel          := ""                                      	// Codigo da Adm financeira
Local cCodAdmFin    := ""                                       // 
Local cNsuSiTef     := ""                                       //
Local cNsuCart      := ""										//Adm Financeira
Local bActionBt1												// Variavel utilizada no action do botao das administradoras qdo usa vale-compra
Local bActionBt2 												// Variavel utilizada no action do botao das administradoras qdo nao usa vale-compra
Local oBt1,oBt2									   				// Objeto do botão
Local lTerceiro     := .F.										// Indica se o cheque e de terceiro
Local lRet          := .F.
Local lMvLjPdvPa    := LjxBGetPaf()[2] //Indica se eh pdv PAF
Local lEmitNFCe     := ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe() 	//Se utiliza Nfc-e na estacao
Local lAliasMDJ     := AliasIndic("MDJ")										// Verifica existencia na base
Local lAliasMDK     := AliasIndic("MDK")
Local lGeraMDJ      := .F.
Local lMVLJADMFI    := SuperGetMv("MV_LJADMFI",,.F.)
Local lAEREDEAUT    := .T.
Local cBandSITEF    := ""
Local cDesBandMDE   := ""
Local cRedeSITEF    := ""
Local cDesRedeMDE   := ""
Local nParcDe       := 0
Local nParcAte      := 0
Local nTamCODSIT    := If(lMVLJADMFI,TamSX3("MDE_CODSIT")[1],0)
Local nDias         := 0	   //Dias de Vencimento do Cartao
Local nTaxa         := 0    //Taxa da Adm do Cartao  
Local cDescAdm      := ""   //Nome da administradora
Local cFinaProp     := ""   // Financiamento proprio AE_FINPRO
Local lMVTEFMULT    := SuperGetMV("MV_TEFMULT",,.F.)
	
LjTefFont( @aFontes )

If ValType(oTef:ARETCARTAO) == "A" .And. Len(oTef:ARETCARTAO) > 0
	cTipo := oTef:ARETCARTAO[1]:cForma
ElseIf Alltrim(oTef:cGet) == "1"
	cTipo 		:= SuperGetMV("MV_SIMB1")
ElseIf Alltrim(oTef:cGet) == "2"
	cTipo 		:= "CH"
EndIf

cNatureza	:= FrtDesForm(cTipo)

If cTipo $ _FORMATEF

	If SuperGetMV("MV_TELAFIN",,.T.) 
		aAreaSAE := SAE->(GetArea())
		SAE->(DbSetOrder(1))// AE_FILIAL + AE_COD
		SAE->(DbSeek(xFilial("SAE")))	

		If nModulo == 23
			aAdminist := {}
			While SAE->(!Eof()) .AND. (SAE->AE_FILIAL == xFilial("SAE"))
				If LJGetStation("TIPTELA") == "2"
					If lMVLJADMFI 
						If aScan(aAdminist,{|x| Trim(x[2])==SAE->AE_COD + " - " + SAE->AE_DESC}) == 0
							
							nParcDe		:= If(SAE->AE_PARCDE==0,1,SAE->AE_PARCDE)
							nParcAte	:= If(SAE->AE_PARCATE==0,999,SAE->AE_PARCATE)
							
							DbSelectArea("MDE") 
							MDE->(DbSetOrder(1))
							If !Empty(SAE->AE_ADMCART) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_ADMCART))
								cBandSITEF  := MDE->MDE_CODSIT 			//Codigo da Bandeira (Retornado pelo SITEF)
								cDesBandMDE := AllTrim(MDE->MDE_DESC)	//Descricao da Bandeira
							Else
								cBandSITEF  := Space(nTamCODSIT)
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
							
							AAdd(aAdminist, {	SAE->AE_TIPO                     ,; //01-Tipo (CC,CD,...)
												SAE->AE_COD+ " - " +SAE->AE_DESC ,; //02-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
												nParcDe                          ,; //03-Parcela Inicial
												nParcAte                         ,; //04-Parce Final
												SAE->AE_ADMCART                  ,; //05-Codigo Relacionado a tabela MDE para a Bandeira
												cDesBandMDE                      ,; //06-Descricao da Bandeira (campo MDE_DESC) 
												cBandSITEF                       ,; //07-Codigo da Bandeira (campo MDE_CODSIT)
												SAE->(Recno())                   ,; //08-Recno SAE
												cRedeSITEF                       ,; //09-Codigo da Rede (Campo MDE_CODSIT)
												cDesRedeMDE                      }) //10-Descricao da Rede (campo MDE_DESC)
							
						EndIf
					Else
						If aScan(aAdminist,{|x| Trim(x[1])==Trim(SAE->AE_TIPO)}) == 0
							AAdd(aAdminist, {SAE->AE_TIPO	, SAE->AE_COD + " - " + SAE->AE_DESC	, 0				, 0				,;
											""			, ""									, ""			, SAE->(Recno()) })
						EndIf
					EndIf
				Else
					If Alltrim(cTipo) == AllTrim(SAE->AE_TIPO)
						AAdd( aAdminist, {SAE->AE_TIPO	, SAE->AE_COD + " - " + SAE->AE_DESC	, 0				, 0				,;
											""			, ""									, ""			, SAE->(Recno()) })
					EndIf
				EndIf
				SAE->(dbSkip())
			End
			RestArea(aAreaSAE)
			
			If SuperGetMv("MV_LJADMFI",,.F.) .AND. cTipTEF == TEF_CLISITEF
				FR271AdmFin(@aArPagto,@aArParce,@aAdminist,@oTEF,@nMoedaCor)
			EndIf
			
			If Len(aArPagto) > 0
				cCodAdmFin	:= AllTrim(SubStr(aArPagto[1][4],1,At('-',aArPagto[1][4])-1))
			EndIf
			
		Else
			aDadosChq	:= { { 0,dDatabase,1,Space(TamSx3("L4_ADMINIS")[1]),Space(TamSx3("L4_NUMCART")[1]),.T.,Space(4),"",;
								0, .F., PadR( '' , TamSX3("A1_COD")[1] ),0},;
								Array(8),{ .F., .F., .F., .F., .T., .F.,.F.,.F. } }
			
			While SAE->AE_FILIAL == xFilial("SAE") .AND. !SAE->(Eof())
				If AllTrim(SAE->AE_TIPO) $ _FORMATEF
					If SX5->(DbSeek(xFilial("SX5")+"24"+AllTrim(SAE->AE_TIPO))) .AND. ( Alltrim(cTipo) == AllTrim(SAE->AE_TIPO) )
						aAdd( aBkpAdmFin, { AllTrim(SAE->AE_TIPO), SAE->AE_DESC, SAE->AE_COD } )
					EndIf
				EndIf
				SAE->(DbSkip())
			End					
			RestArea(aAreaSAE)
			
			aAdminist := {}
			aEval( aBkpAdmFin, {|x| aAdd(aAdminist, x[3] + " - " + Capital(x[2]))} )	

			LJ7TelaFin( 	.F.			, @oDlgVA	 			, @aDadosChq					, aFontes	,;
							.T.			, TamSx3("AE_COD")[1]	, NIL /*Nil, pois não uso Vale*/, @bActionBt1,;
							@bActionBt2	, NIL 					, {} 							, @lBotaoOK	,;
							oBt1		, oBt2 		 			, aAdminist 					, @lCancela	,;
							{}		   	, @aTaxJuros  			, cTipo		 					, cTipo		)
          
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Se não é Financiamento Proprio gera financeiro com o codigo de cliente da Adm. Financeira, ³
          //³da mesma forma que e feito no LOJXFUNC                                                     ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          cFinaProp := SAE->AE_FINPRO  
          If cFinaProp == 'N'
            cCliente := SAE->AE_CODCLI
            cLoja    := IIF( SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_LOJCLI), SAE->AE_LOJCLI, "01" )
          EndIf  

			If Len(aDadosChq) > 0
				cCodAdmFin	:= AllTrim(SubStr(aDadosChq[1][5],1,At('-',aDadosChq[1][5])-1))
			EndIf
		EndIf
	Else
		cCodAdmFin := LJ7ConfAdm(""	                                                                                        ,;
                                 IIf(oTef:nCodFuncao == 300 , oTef:aRetRecarga[1]:cDescAdm , oTef:aRetCartao[1]:cDescAdm)   ,;
                                 .F. 		                                                                                ,; 
                                 cTipo			                                                                            ,;
		                         IIf(lMVTEFMULT, oTef:aRetCartao[1]:cIdCart, NIL)   										,;
                                 oTef:aRetCartao[1]:cTipCart                        										,;
                                 oTef:aRetCartao[1]:nParcelas	                    										,;
                                 oTef:aRetCartao[1]:cDescCart	                    										,;
								 Nil	                                            										,;
                                 1 	                                                										,;
                                 NIL	                                            										,;
                                 NIL	                                            										,;
								 NIL	                                            										,;
                                 oTef:aRetCartao[1]:cCodRede                        										,;
                                 NIL )
	EndIf	
    
	cNsuSiTef	:= oTef:aRetCartao[1]:cNsuAutor
	cNsuCart	:= oTef:aRetCartao[1]:cNsuSitef
EndIf

If cTipo == "CH"
	aDadosChq	:= { {	0								, dDatabase						, 1							, Space(TamSx3("EF_BANCO")[1])	, ;
							Space(TamSx3("EF_AGENCIA")[1])	, Space(TamSx3("EF_CONTA")[1])	, Space(TamSx3("EF_NUM")[1]),Space(TamSx3("EF_COMP")[1])	, ;
   	                   		Space(TamSx3("L4_RG")[1])		, Space(TamSx3("L4_TELEFON")[1]),.F.,.F.,SuperGetMV("MV_SIMB1"), Space(TamSx3("EF_EMITENT")[1])},;
                       		Array(14), { 	.F., .F., .F., ;
                       						.T., .T., .T., ;
                       						.T., .F., .F., ;
                       						.F., .F., .F., ;
                       						.F., .F. },;
       	               		{ 	STR0146, STR0147, STR0148, STR0052, STR0053, STR0149, STR0150,; //"Valor do Titulo"###"Data do Vencimento"###"Parcela"###"Banco"###"Agência"###"Conta"###"Num.Cheque"
								STR0151, RetTitle("A1_RG"), STR0129, STR0152, STR0128, STR0153, STR0154 } } //"Compensação"###"RG"###"Telefone"###"Utiliza nas próximas parcelas"###"Cheque de Terceiro" //"Moeda"###"Emitente"
								
	LjTelaCheq(	@oDlgChq	, STR0149			, @oDlgVA	, @aDadosChq	, ;			// "DADOS DO CHEQUE"
				@aFontes 	, @lBotaoOK			, @lCancela , @nVezes		, ;
				@nCont )
	If Len(aDadosChq) > 0
		cBanco 		:= aDadosChq[1, 4]
		cAgencia	:= aDadosChq[1, 5]
		cConta		:= aDadosChq[1, 6]
		cNumChq		:= aDadosChq[1, 7]
		cCompensa	:= aDadosChq[1, 8]
		cRg			:= aDadosChq[1, 9]
		cTel		:= aDadosChq[1,10]
		lTerceiro	:= aDadosChq[1,12]
	EndIf
EndIf

If !lEmitNFCe 
	cPref := LjGetStation("SERIE")
	IFPegCupom( nHdlECF, @cNumCupFis )
Else 
	If SLG->(ColumnPos("LG_SERNFIS")) > 0
		cPref := LjGetStation("SERNFIS")
	EndIf 
	If Empty(cPref)
		cPref := "RCG"
	EndIf	
	cNumCupFis := GetNumSE1(cPref)
Endif	

//se for SIGALOJA online, nao incluimos o titulo via Web Service
If nModulo == 12 .AND. !lMvLjPdvPa
	LJMsgRun(STR0124,, { |oDlg| 	;	// Gravando Movimento
	lRet :=	IncTitRCel(	cPref		, cNumCupFis, cParcela	, cTipo		,;
						@cNatureza	, @cCliente	, @cLoja	, dEmiss	,;
						dVencto		, cHist		, nMoeda	, cPrw		,;
						nValTit		, cPortado	, cBanco 	, cAgencia	,;
						cConta 		, cNumChq	, cCompensa , cRg 		,;
						cTel		, lTerceiro , cNsuSiTef	, cNsuCart	,;
						cCodAdmFin	, (cTipo $ _FORMATEF) ) } )
Else

	//Gera Movimentação de Recarga de Celular no PDV
	If cTipo $ _FORMATEF
		If cTipo == "CC"
			cNatureza := "MV_NATCART"
		Else
			cNatureza := "MV_NATTEF"
		EndIf
		
		cNatureza := LjMExeParam(cNatureza)
		
	ElseIf cTipo == "CH"
		cNatureza := "MV_NATCHEQ"
		cNatureza := LjMExeParam(cNatureza)
	ElseIf Empty(AllTrim(cNatureza))
		cNatureza := SuperGetMv("MV_NATRC",,"")
	EndIF

	If lAliasMDJ //para otimizar o processo , se tiver MDJ grava em batch para nao criar o titulo na retaguarda no momento 
		DbSelectArea("MDJ")
		MDJ->(DbSetOrder(1))	//MDJ_FILIAL + MDJ_DOC + MDJ_SERIE + MDJ_CLIENTE + MDJ_LOJA + MDJ_SITUA
		If !MDJ->(DbSeek(xFilial("MDJ") + cNumCupFis + cPref + cCliente + cLoja))

			If ExistFunc("WLj010Adm")
				WLj010Adm(	@cCodAdmFin,	@cLoja,	@cDescAdm,	@nDias,;
							@nTaxa,		    @cCliente	)
			EndIf

			If MDJ->(Reclock("MDJ",.T.))
				REPLACE MDJ->MDJ_FILIAL	WITH cFilAnt
				REPLACE MDJ->MDJ_DOC  	WITH cNumCupFis
				REPLACE MDJ->MDJ_SERIE	WITH cPref
				REPLACE MDJ->MDJ_CLIENT	WITH cCliente
				REPLACE MDJ->MDJ_LOJA  	WITH cLoja
				REPLACE MDJ->MDJ_OPERAD	WITH cPortado
				REPLACE MDJ->MDJ_EMIS	WITH dEmiss+nDias
				REPLACE MDJ->MDJ_CREDIT	WITH (nValTit - ((nValTit * nTaxa)/100))
				REPLACE MDJ->MDJ_OPER  	WITH  "R"				// Recarga de Celular
				REPLACE MDJ->MDJ_SITUA 	WITH  "NP"				// Grava NP - Nao Processada
				REPLACE MDJ->MDJ_DTVAL	WITH DataValida(dEmiss+nDias)
				MDJ->(MsUnLock())
				lGeraMDJ := .T.
			Endif	
		Endif
		
		If lGeraMDJ .And. lAliasMDK
			DbSelectArea("MDK")
			If MDK->(Reclock("MDK",.T.))
				REPLACE MDK->MDK_FILIAL WITH xFilial("MDK")
				REPLACE MDK->MDK_DOC WITH cNumCupFis
				REPLACE MDK->MDK_SERIE WITH cPref
				REPLACE MDK->MDK_CLIENT WITH cCliente	
				REPLACE MDK->MDK_LOJA WITH cLoja
				REPLACE MDK->MDK_SALDO WITH (nValTit - ((nValTit * nTaxa)/100))
				REPLACE MDK->MDK_TITULO WITH ""
				REPLACE MDK->MDK_DTNCC WITH DataValida(dEmiss+nDias)
				REPLACE MDK->MDK_NUMREC WITH 0
				REPLACE MDK->MDK_SALDO2 WITH nValTit //Valor sem a taxa - caso de recarga cartão preenche o campo E1_VLRREAL
				REPLACE MDK->MDK_MVMOED WITH ""
				REPLACE MDK->MDK_MOEDA WITH nMoeda
				REPLACE MDK->MDK_PREFIX WITH ""
				REPLACE MDK->MDK_PARCEL WITH "A"
				REPLACE MDK->MDK_TIPO WITH cTipo
            	REPLACE MDK->MDK_NUMORC WITH ""
		        
		        If MDK->(ColumnPos("MDK_NSUTEF")) > 0
		        	
		        	If cTipo == SuperGetMV("MV_SIMB1")
		        		REPLACE MDK->MDK_NATUREZ WITH &(SuperGetMV("MV_NATDINH"))
		        	Else
		        		REPLACE MDK->MDK_NATUREZ WITH cNatureza
		        	EndIf
		        	
		        	If cTipo $ _FORMATEF
		        		REPLACE MDK->MDK_NSUTEF WITH cNsuCart
		        		REPLACE MDK->MDK_DOCTEF WITH cNsuSiTef
					EndIf

			        If cTipo == "CH"
			        	REPLACE MDK->MDK_BCOCHQ WITH cBanco
			        	REPLACE MDK->MDK_AGECHQ WITH cAgencia
			        	REPLACE MDK->MDK_CTACHQ WITH cConta
				    EndIf
			    EndIf
		        
				MDK->(MsUnLock())			
			EndIf
		EndIf
		
	Else
		oSrc		:= WSLJFINACEL():New()
		oSrc:_URL 	:= "http://"+Alltrim(LJGetStation("WSSRV"))+"/LJFINACEL.apw"

		LJMsgRun(STR0124,, { |oDlg| 		;	// Gravando Movimento
		lRet := oSrc:IncluiTit(	cPref		, cNumCupFis, cParcela	, cTipo		,;
								@cNatureza	, cCliente	, cLoja		, dEmiss	,;
								dVencto		, cHist		, nMoeda	, cPrw		,;
								nValTit		, cPortado	, cBanco 	, cAgencia	,;
								cConta 		, cNumChq	, cCompensa , cRg 		,;
								cTel		, lTerceiro , cEmpAnt	, cFilAnt 	,;
								lMvLjPdvPa	, cNsuSiTef , cNsuCart	, cCodAdmFin,;
								(cTipo $ _FORMATEF) ) } )
	Endif
	
	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial("SA6")+cPortado+"."))
	If SE5->(Reclock("SE5",.T.))
		REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
		REPLACE SE5->E5_DATA	WITH dEmiss
		REPLACE SE5->E5_BANCO	WITH cPortado
		REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
		REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
		REPLACE SE5->E5_HISTOR	WITH cHist
		REPLACE SE5->E5_TIPO	WITH cTipo
		REPLACE SE5->E5_TIPODOC	WITH "VL"
		REPLACE SE5->E5_MOEDA	WITH StrZero(nMoeda,TAMSX3("E5_MOEDA")[1])
		REPLACE SE5->E5_VALOR	WITH nValTit
		REPLACE SE5->E5_DTDIGIT	WITH dDataBase
		REPLACE SE5->E5_DTDISPO	WITH SE5->E5_DATA
		REPLACE SE5->E5_NATUREZ	WITH cNatureza
		REPLACE SE5->E5_SITUA	WITH "TX" //Não é necessário subir para a retaguarda pois ja foi gerada anteriormente pelo WS
		REPLACE SE5->E5_ORIGEM	WITH cPrw
		Replace SE5->E5_NUMMOV	WITH AllTrim(LJNumMov())
		SE5->(MsUnLock())
	EndIf
			
	//Ponto de Entrada para gravacao de campos adicionais na tabela SE5 do PDV
	//Neste momento o registro estah posicionado no SE5, basta fazer o Lock no registro e gravar os demais campos necessarios
	If ExistBlock("LJRCNF1")
		ExecBlock("LJRCNF1", .F., .F. )
	EndIf
EndIf	
		
// Se gravou na tabela MDJ, nao exibe mensagem 														
If !lRet .AND. !lAliasMDJ
   	Alert( STR0157 )	// "Não foi possível gravar as infomações da recarga."
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjTefFont ºAutor  ³Vendas Clientes     º Data ³  26/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define as fontes da tela.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjTefFont( aFontes )
Local oFonte1
Local oFonte2
Local oFonte3

DEFINE FONT oFonte1 NAME "Arial" BOLD
DEFINE FONT oFonte2 NAME "Arial" SIZE 08,17 BOLD
DEFINE FONT oFonte3 NAME "Courier New"

aAdd(aFontes, oFonte1)
aAdd(aFontes, oFonte2)
aAdd(aFontes, oFonte3)

Return( NIL )

/*                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJContIndexºAuto  ³Vendas Clientes     º Data ³  26/05/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para contar quantos indices existem para aquele Alias º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJContIndex(cAliasVeri)
    
Local nRet :=0			// Quantidade de Alias existentes

DEFAULT cAliasVeri := ""

If !Empty(cAliasVeri)
	DbSelectArea("SIX")		
	DbSetOrder(1)                              // INDICE + ORDEM
	If DbSeek(cAliasVeri)                      // Caso enconte o Alias faz a contagem dos indices
		While(cAliasVeri == SIX->INDICE)
			nRet++
			DbSkip()
		End
	EndIf	  
EndIf			
Return(nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVCadCB   ºAuto  ³Vendas Clientes     º Data ³  13/04/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se os Cadastros no SIGALOJA.ini foram realizados.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjVCadCB()
If Empty(cFrmPgDi)
   MsgStop(STR0161, STR0161)
   return .F.
EndIf
return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetCBVlrPgtºAuto  ³Vendas Clientes       º Data ³  07/06/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o Valor Total Pago para CB                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method GetCBVlrPgt() Class MSTEF
Local nI := 1

oTef:nVlrPgCB := 0

for nI:=1 to Len(oTef:aRetCorresp)
	oTef:nVlrPgCB += oTef:aRetCorresp[nI]:nVlrPgto
next nI   

Return oTef:nVlrPgCB

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjTefGrvCB ºAutor  ³Microsiga           º Data ³  12/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo que inclui um titulo baixado e gera moviemnto       º±±
±±º          ³ bancario para o Venda Assistida.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTefGrvCB (         	cPref		, cNumTit	, cParcela	, cTipo		, ;
								cNatureza	, cCliente	, cLoja		, dEmiss	, ;
								dVencto		, cHist		, nMoeda	, cRotina	, ;
								nValtit 	, cPortado	, cBanco	, cAgencia	, ;
								cConta		, cNumChq	, cCompensa , cRg 		, ;
								cTel		, lTerceiro , cNsuSiTef )
	
	Local aDados	:= {}			// Campos do SE1 que necessitam ser enviados
	Local aArea	    := GetArea()
	Private lMsErroAuto := .F. 
	
   	aDados  := {	{ "E1_PREFIXO"	,cPref						,Nil} ,;
					{ "E1_NUM"	  	,cNumTit 					,Nil} ,;
					{ "E1_PARCELA" 	,cParcela					,Nil} ,;
					{ "E1_TIPO"	 	,cTipo						,Nil} ,;
					{ "E1_NATUREZ" 	,cNatureza					,Nil} ,;
		          	{ "E1_CLIENTE" 	,cCliente					,Nil} ,;
	             	{ "E1_LOJA"	  	,cLoja						,Nil} ,;
		          	{ "E1_EMISSAO" 	,dEmiss 					,Nil} ,;
			       	{ "E1_VENCTO"  	,dVencto 					,Nil} ,;
			       	{ "E1_VENCREA" 	,DataValida(dVencto)		,Nil} ,;
			       	{ "E1_HIST" 	,cHist						,Nil} ,;
			       	{ "E1_MOEDA" 	,nMoeda						,Nil} ,;
					{ "E1_ORIGEM"	,cRotina					,Nil} ,;
					{ "E1_FLUXO"	,"S"						,Nil} ,;
				   	{ "E1_VALOR"	,nValTit					,Nil} ,;
				   	{ "E1_PORTADO"	,cPortado					,Nil} ,;
				   	{ "E1_BCOCHQ"	,cBanco						,Nil} ,;
				   	{ "E1_AGECHQ" 	,cAgencia					,Nil} ,;
				   	{ "E1_CTACHQ"	,cConta						,Nil} ,;
				   	{ "E1_DOCTEF"	,cNsuSiTef                  ,Nil} }
	
	MSExecAuto( { |x,y| Fina040( x, y ) }, aDados, 3 ) //Inclusao
	
	lRet := !lMsErroAuto
	
	If lRet
		If cTipo == "CH"
			LJRecGrvCH( cBanco  , cAgencia , cConta   , cNumChq	,;
	 					nValTit , dEmiss   , cCompensa, cRG    	,;
		                cTel    , lTerceiro, cPref	  , cNumTit	,;
		    			cParcela, cTipo  )
		 	RecLock("SEF", .F.)
		 	REPLACE SEF->EF_CLIENTE WITH cCliente
		 	REPLACE SEF->EF_LOJACLI WITH SA1->A1_LOJA
		 	REPLACE SEF->EF_EMITENT	WITH SA1->A1_NOME
		 	REPLACE SEF->EF_NUMNOTA	WITH cNumTit
		 	REPLACE SEF->EF_SERIE	WITH cPref
		 	MSUnlock()
		EndIf
			
		If cTipo == SuperGetMV( "MV_SIMB1" )
			aDados	:= {	{ "E1_PREFIXO" 	,E1_PREFIXO			, Nil},	;// 01
							{ "E1_NUM"     	,E1_NUM				, Nil},	;// 02
							{ "E1_PARCELA" 	,E1_PARCELA			, Nil},	;// 03
							{ "E1_TIPO"    	,E1_TIPO			, Nil},	;// 04
							{ "E1_MOEDA"    ,E1_MOEDA			, Nil},	;// 05
							{ "E1_TXMOEDA"	,E1_TXMOEDA			, Nil},	;// 06
							{ "E1_ORIGEM"	,E1_ORIGEM			, Nil},	;// 07
							{ "AUTVALREC"	,E1_VALOR  			, Nil},	;// 06
							{ "AUTMOTBX"  	,"NOR"				, Nil},	;// 07
							{ "AUTDTBAIXA"	,dDataBase			, Nil},	;// 08
							{ "AUTDTCREDITO",dDataBase			, Nil},	;// 09
							{ "AUTHIST"   	,cHist				, Nil}  }// 13
		    
			// Verifica se deu algum erro no MSExecAuto anterior
			If !lMsErroAuto
				
				MSExecAuto( { |x,y| FINA070( x, y ) }, aDados, 3 )
				
			Else
				lRet := .F.
				MostraErro()
				DisarmTransaction()
			EndIf
		Endif
			
		lRet := .T.
	Else 
		MostraErro()
	EndIf
	
	RestArea( aArea )
	
Return lRet   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJContIndexºAuto  ³Vendas Clientes     º Data ³  26/05/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para contar quantos indices existem para aquele Alias º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpTefEcNf(aTexto) 

Local nX := 1			 				//  Contor oi
Local nY := 0                         	//  Contor o2
Local aRet := {}						// Retorno
Local nRet := 0  						// Retorno
Local nLinha	:= 0
Local nSaltoLn	:= SuperGetMV("MV_FTTEFLI",		,8	) 	// Linha pula entre comprovante
Local cTextoTef	:= "" 									// Texto com comprovante TEF que sera enviado para a Impressora Nao Fiscal
Local lImpTefOk	:= .F.									// Verifica se cTextoTef foi emitido com sucesso, permite tentar novamente

Default aTexto := {}


//For nX := 1 To Len(aTexto)
While nX <= Len(aTexto)

	aRet := strtoarray(aTexto[nX][1], chr(10))
	
	aRet := {}
	
	cBk := aTexto[nX][1]
	
	While !Empty(aTexto[nX][1])
		
		cTem1 := SubStr(aTexto[nX][1], 1, At(CHR(10), aTexto[nX][1]) - 1)
		AAdd(aRet, cTem1)
		cTem2 := SubStr(aTexto[nX][1], At(CHR(10), aTexto[nX][1])+1, Len(aTexto[nX][1]))	
		aTexto[nX][1] := cTem2
	End
	
	aTexto[nX][1] := cBk

	nY := 1
	
	While nY <= Len(aRet)
		If oTEF:lHomolog
			nRet := INFTexto(aret[nY])
			If nRet < 0
				If MsgYesNo(STR0162, STR0163 ) //"Deseja imprimir novamente?" "Atenção"
					nX := 0
				    Sleep(1000)
				    Exit
				Else			
					oTef:lImprimiu := .F.
					Return()
				EndIf
			EndIF		
		Else      
			cTextoTef += aret[nY] + Chr(10)
		EndIf
			
		nY += 1
	End
	
	For nLinha := 1 To nSaltoLn
		If oTEF:lHomolog
			nRet := INFTexto("")
			If nRet < 0
				If MsgYesNo(STR0162, STR0163)  //"Deseja imprimir novamente?" "Atenção" 
					nX 		:= 0
					nLinha 	:= 100
					Sleep(1000)
					Exit
				Else			
					oTef:lImprimiu := .F.
					Return()
				EndIf
			EndIF		
		Else
			cTextoTef += "" + Chr(10)
		EndIf
	Next nLinha

nX := nX + 1
End  

If !oTEF:lHomolog 
	While !lImpTefOk
		nRet := INFTexto(cTextoTef)	
		
		If nRet < 0
			If MsgYesNo(STR0162, STR0163 ) //"Deseja imprimir novamente?" "Atenção"
			    Sleep(1000)
			    Exit
			Else			
				oTef:lImprimiu := .F.
				Return()
			EndIf
		Else
			lImpTefOk := .T.
		EndIF					
	End
EndIf

If ExistFunc("INFCutPpr")
	INFCutPpr()
Else
	INFTexto(TAG_GUIL_INI+TAG_GUIL_FIM)
EndIf

oTef:lImprimiu := .T. 

Return()

/*                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LjxGrvTrn     ºAutor ³ Vendas CRM      	   ºData  ³ 03/05/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Metodo para gravar o log das transacoes TEF                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXTEF                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD LjxGrvTrn(nConfirma) CLASS MSTEF

Local nTotTrn	    := 0		// total de transacoes
Local nX		    := 0		// contador for next
Local lLjTGrvLog	:= FindFunction("P_LJTGRVLOG")	// Verifica a existencia ou nao do ponto de entrada U_LJGRVLOG

Default nConfirma := 1

If AliasIndic("MDH") .And. LjNfUsaTef(SM0->M0_CGC) .And. nModulo <> 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Transacao com cartao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(oTef:aRetCartao) == "A"
		If Len(oTef:aRetCartao) > 0
			If oTef:nTotTrans > 0
				nTotTrn := oTef:nTotTrans
			ElseIf !Empty(oTef:aRetCartao[1]:cNSUAutor)
				nTotTrn := 1
			EndIf
			
			
			For nX := 1 to nTotTrn
				// Grava informacoes
				
				If nConfirma == 1
					RecLock("MDH", .T.)
					Replace MDH_FILIAL			With xFilial("MDH")
					Replace MDH_AUTORI			With oTef:aRetCartao[nX]:cNSUSiTef
					Replace MDH_DTTRAN			With oTef:aRetCartao[nX]:dDataTrans
					Replace MDH_HRTRAN			With oTef:aRetCartao[nX]:cHoraTrans
					Replace MDH_TPTRAN			With oTef:aRetCartao[nX]:cForma
					Replace MDH_CODTRN			With AllTrim(Str(oTef:nCodTrans))
					Replace MDH_INSTIT			With oTef:aRetCartao[nX]:cDescAdm
					Replace MDH_NSU				With oTef:aRetCartao[nX]:cNSUAutor
					Replace MDH_NSUCAN			With oTef:aRetCartao[nX]:cDocCanRei
					Replace MDH_NUMPAR			With oTef:aRetCartao[nX]:nParcelas
					Replace MDH_DOC				With oTef:cCupom
					Replace MDH_NUMCXA			With oTef:cOperador
					Replace MDH_CARTAO			With oTef:aRetCartao[nX]:cPosCart
					If MDH->(FieldPos("MDH_VLDCRT"))>0
						Replace MDH_VLDCRT			With oTef:aRetCartao[nX]:cVencCartao
					EndIf
					Replace MDH_TPCOM			With LjGetStation("TIPTEF")
					SerieNfId("MDH",1,"MDH_SERIE",dDataBase,LjEspecieNF(),LjGetStation("LG_SERIE"))
					Replace MDH_ESTAC			With LjGetStation("LG_CODIGO")
					If oTef:aRetCartao[nX]:nVlrTrans == 0
						If oTef:vGet > 0
							Replace MDH_VLTRAN	With oTef:vGet
						EndIf
					Else
						Replace MDH_VLTRAN		With oTef:aRetCartao[nX]:nVlrTrans
					EndIf
					MsUnlock()  
					
				EndIf	
				If lLjTGrvLog
					P_LJTGRVLOG(nX, nConfirma)
				EndIf
			Next nX
		EndIf
	EndIf
EndIf

Return(NIL)

/*                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRetINI	 ºAutor ³Vendas Clientes     º Data ³  14/07/12    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna todas as chaves e os conteudos de uma secao passada  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Static Function LjRetINI(cSession)

Local lNext		:= .F.
Local nPosSign 	:= 0
Local cChave	:= ""
Local cConteudo	:= ""
Local nLast 	:= 0
Local nHandle	:= 0
Local cLine		:= ""
Local aRet		:= {}
 
DEFAULT cSession := ""

nHandle := FT_FUse(ARQLJINI)	// Le o SIGALOJA.INI
	
If nHandle <> -1  				// Se houver erro de abertura abandona processamento
	FT_FGoTop()					// Posiciona na primeria linha
	nLast := FT_FLastRec() 		// Retorna o número de linhas do arquivo
	
	While !FT_FEOF()   			// Percorre todo o arquivo
		cLine  := FT_FReadLn() 	// Retorna a linha corrente  
	
		If AllTrim(Upper(cLine)) == "["+cSession+"]" 
			lNext := .T.
		Else
			If lNext .AND. ! (("[" $ cLine) .OR. Empty(cLine))
				//Adiciona todo o conteudo da sessao no array
				nPosSign 	:= Rat( "=", cLine)
				cChave		:= Substr(cLine,1,nPosSign-1)
				cConteudo	:= Substr(cLine,nPosSign+1)
				aAdd(aRet,{ AllTrim(Upper(cChave)),AllTrim(Upper(cConteudo)) })
			EndIf
			If lNext .AND. ("[" $ cLine)	// Indica que eh outra secao e nao deve continuar
				Exit
			EndIf	
		EndIf			
		FT_FSKIP()	// Pula para proxima linha  
	End
	FT_FUSE() // Fecha o Arquivo
EndIf
	
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetVlrCB	 ºAutor ³Vendas Clientes     º Data ³  14/07/12    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor do correspondente bancario quando pagamento, º±±
±±º			 ³ se estorno seu retorno é zero (0)						   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetVlrCB()
Local nRet := 0

If oTef:nTransCB > 1
	nRet := oTef:GetCBVlrPgt()
Else 
	nRet := oTef:aRetCorresp[1]:nVlrPgto
EndIf

Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValEstCB	 ºAutor ³Vendas Clientes     º Data ³  14/07/12    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³QUANDO FOR UM ESTORNO DE CORREPONDENTE BANCARIO PEGA VALOR   º±±
±±º			 ³ ORIGINAL													   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValEstCB()
Local lRet := (RetVlrCB() == 0)

If lRet
	oTef:aRetCorresp[1]:lEstorno := .T.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjVldBIN	 ºAutor ³Vendas Clientes     º Data ³  18/07/14    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida BIN do cartao passado para pagamento da compra       º±±
±±º			 ³ 															   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjVldBIN(cBINCart, nValTran)
Local lBinValido := .T.			// Variavel de controle de BIN valido
Local lRet		 := .T.			// Retorno da validade do BIN do cartao

Default cBINCart := ""  		// Bin do cartao (6 posicoes) passado pela chamada da funcao
Default nValTran := 0           // Valor da transacao passado pela chamada da funcao
        
If Alltrim(cBINCart) <> "" .AND. nValTran > 0

	// Como o padrao do retorno(SITEF) da informacao do BIN sao 6 posicoes 
	// Esta sendo passado para o PE o padrao(SITEF) 6 posicoes e se for diferente de 6 posicoes devera ser tratado dentro do PE
			                                    										 
	lBinValido := ExecBlock("LJFIMTEF", .F., .F., {cBINCart, nValTran})
								
	// Retorno do PE invalido, faz o cancelamento de todas ss transacoes
	If !lBinValido                                                     
		// Necessario depois definir mensagem (STR), coloquei somente para estar informando
		
		MsgStop(STR0092,STR0005) 								//"Cartao invalido!"
					 		 
		// Nao perde a venda
		// Altera o retorno do SITEF para falso
		lRet := .F.
	Endif				
Endif
	
Return(lRet)
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CartaoPresenteGiftCardºAutor ³Vendas Clientes     º Data ³ 13/06/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua Operacoes Relacionadas a Cartao Presente (Gift Card).         º±±
±±º          ³                                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - "Cartao Presente" (Gift Card)                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method CartaoPresenteGiftCard( 	cTpRecarga 	, nVlrItem	, aParcTef, lTEFPendCS	, ;
								 aTefBKPCS	, cSeqTrans , cCodProd, lTefPend ) Class MSTEF
								
Local cOperCP 		:= "" //Operacao a ser executada referente ao Cartao Presente (Gift Card)
Local cRetIF 		:= ""
Local lRet     		:= .T.

If cTpRecarga == "RCP" //Recarga Cartao Presente (Recarga atraves da venda do produto) na tela de atendimento
	
	cOperCP := "CP_RECARGA"
	
    oTef:Operacoes( cOperCP, aParcTef, @lTEFPendCS, @aTefBKPCS,;
				    cSeqTrans ) //Recarga de Cartao Presente (Gift Card)
    
	If oTef:lTefOk
		nVlrItem	:= oTef:aRetRecCP[oTef:nTransCP]:nValor
		lTefPend	:= .T.
		lRet 		:= .T.
	EndIf

ElseIf cTpRecarga == "OCP" //Operacao com Cartao Presente (Executa operacao de Consulta de Saldo ou Cancelamento da Recarga do Cartao Presente "Gift Card") atraves do menu da rotina na tela de atendimento

	//Resgata a operacao a ser executada referente ao Cartao Presente (Gift Card)
	cOperCP := LjCPGetOpc()
	
	If !Empty(cOperCP)
		
		If IFStatus(nHdlECF, "5", @cRetIF) == 0
			lRet := .T.
		Else
			MsgAlert( STR0206 ) // "Cupom fiscal aberto. Não é possível realizar a Recarga de Cartão Presente!"
			lRet := .F.
		EndIf
		
		If lRet
			oTef:Operacoes( cOperCP ) //Recarga de Cartao Presente (Gift Card)
		
			If oTef:lTefOk
				oTef:ImpCupTef()
				oTef:nCodFuncao := 0 
			EndIf
		EndIf
		
	EndIf
	
EndIf

Return lRet 

/*                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjCPGetOpc ºAutor ³Vendas Clientes     º Data ³ 13/06/2013   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a operacao a ser executada referente ao Cartao      º±±
±±º          ³Presente (Gift Card).                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Static Function LjCPGetOpc()
Local oDlg
Local lConfirm 		:= .F.
Local cRetOper 		:= ""
Local nOpcao 		:= 0
Local oFont 		:= TFont():New("Courier",,-15,.T.)
Local aBotoes 		:= {}
Local cCaption 		:= ""
Local cToolTip		:= ""
Local nTamTitBot	:= 0
Local nLinhaObj		:= 20
Local nColunaObj	:= 25
Local nBotLargur	:= 150
Local nBotAltura	:= 18
Local nInd 			:= 0
Local bBlocoCmd 	:= {|| Nil}
Local cOpcao 		:= Space(2)
Local nOpcoes 		:= 0

//BOTOES
// 				Titulo do botao    		ToolTip
AAdd( aBotoes, { STR0168			, "Efetua a consulta de saldo do Gift Card" 		} ) //"Consulta Saldo"
AAdd( aBotoes, { STR0167			, "Efetua o cancelamento da recarga do Gift Card" 	} ) //"Cancela Recarga"

aEval( aBotoes, { |x| nTamTitBot := If(Len(x[1])>nTamTitBot,Len(x[1]),nTamTitBot)} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a tela com as operacoes diponiveis para Cartao Presente (Gift Card).  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0165 FROM 00,00 TO 13,50 //"Cartão Presente (Gift Card)"

@ 005,005 TO 90,195 LABEL STR0166 OF oDlg PIXEL //"Escolha a operação desejada:"

For nInd:=1 To Len(aBotoes)
	cCaption 	:= StrZero(nInd,2) + "-" + PadR(aBotoes[nInd][1],nTamTitBot) //Titulo do Botao
	cToolTip 	:= aBotoes[nInd][2] //Mensagem ToolTip do botao
	bBlocoCmd	:= &("{|| (lConfirm:=.T.,cOpcao:='"+StrZero(nInd,2)+"',oDlg:End()) }") //Bloco de comando do botao
	
	//Monta o Botao
	TButton():New( nLinhaObj, nColunaObj, cCaption, oDlg, bBlocoCmd, nBotLargur, nBotAltura, , oFont, .F., .T., .F., cToolTip, .F., , , .F. )
	nLinhaObj := nLinhaObj + 20
Next nInd
nOpcoes := nInd-1

nLinhaObj := nLinhaObj + 5

@ nLinhaObj+2,nColunaObj SAY "Opção:" OF oDlg PIXEL
oGetOpc := TGet():New(nLinhaObj,nColunaObj+20,bSETGET(cOpcao),oDlg,010,010,,{|| If( Empty(cOpcao), .T., If(LjGCVldOpc(cOpcao,nOpcoes), (lConfirm:=.T.,oDlg:End()), .F.) ) },,,,,,.T.,,,,,,,.F.,,,)

oGetOpc:SetFocus()

ACTIVATE MSDIALOG oDlg CENTERED

If lConfirm
	nOpcao := Val(cOpcao)
	Do Case
	    //Consulta Saldo de Cartão Presente
		Case nOpcao == 1
			cRetOper := "CP_CONSULTA"
			
	    //Cancelamento da Recarga de Cartão Presente
		Case nOpcao == 2
			cRetOper := "CP_CANCELA"
	EndCase
EndIf

Return cRetOper

/*                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjGCVldOpc ºAutor ³Vendas Clientes     º Data ³ 13/06/2013   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a Opcao informada.                                   º±±
±±º          ³ Cartao Presente (Gift Card).                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function LjGCVldOpc(cOpcao,nOpcoes)
Local lRet 		:= .T.
Local cValidos 	:= "0123456789" //Valores Validos
Local nInd 		:= 1

cOpcao := AllTrim(cOpcao)

While nInd <= Len(cOpcao)
	If !(SubStr(cOpcao,nInd,1) $ cValidos)
		MsgAlert(STR0175) //"Opção inválida!"
		lRet := .F.
		Exit
	EndIf
	nInd++
End

If lRet
	If Val(cOpcao) < 1 .Or. Val(cOpcao) > nOpcoes
		MsgAlert(STR0175) //"Opção inválida!"
		lRet := .F.
	EndIf
EndIf

Return lRet

//----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDisp
Funcao para apresentar as mensagens da tela para displays
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param1     cMsg - Mensagem a ser apresentada no  display
@param2     cOpEscolha - Opcoes de escolha enviadas pelo TEF quando eh necessario montar a lista para usuario selecionar
@param3     nValor - Valor default quando o campo de digitacao de valores e opcoes eh liberado para o usuario
@param4     cPergunta - Texto de perguntas a serem apresentadas para o usuario confirmar ou cancelar
@param5     lPause - Parametro que indica se o pause precisa ser adicionado apos a mensagem de acordo com os comandos enviados pelo TEF
@param6     cOpcBot - Opcao do botao onde pode ser "E": Encerrar; "C": Continuar; "V": Voltar
@return    Nil
@version	P10
@since	30/12/2014
/*/
//----------------------------------------------------------------------------------------------------------------------------------
Function LjTEFDisp(cMsg, cOpEscolha, nValor, cPergunta, lPause, cOpcBot)

Local lUsaDisplay	:= !Empty(LjGetStation("DISPLAY"))		// Verifica se a estacao possui Display
Local nLinDisplay	:= 0										// Numero da linha disponivel para escrita
Local cOpcSelec	:= ""										// Opcao selecionada pelo usuario quando for mensagem de escolha

DEFAULT cMsg 			:= ""
DEFAULT cOpEscolha	:= ""
DEFAULT nValor		:= NIL
DEFAULT cPergunta		:= ""
DEFAULT lPause		:= .F.
DEFAULT cOpcBot		:= ""

If !lUsaDisplay
	Return Nil
Endif

// Precisa vir pelo menos uma mensagem ou pergunta
If Empty(cMsg) .AND. Empty(cPergunta)
	Return Nil
Endif

// Para esta opção (quantidade de parcelas) a mensagem do botao confirmar nao deve ser apresentada no display
If (oTef:nTipoCampo==505 .OR. oTef:nTipoCampo==511) .AND. Alltrim(Upper(cMsg))==Upper(STR0193)		// ### Botao Confirmar selecionado
	Return Nil
Endif

// Verificar se o pause precisa ser adicionado apos a mensagem de acordo com os comandos enviados pelo TEF
lPause := LjTEFDispP(lPause)

// Mensagens a serem exibidas no objeto oMens da tela no monitor
nLinDisplay := LjTEFDispM(cMsg, lPause)

// Apresentar as escolhas que o usuario pode digitar
If !Empty(cOpEscolha)

	cOpcSelec := LjTEFDispE(cMsg, cOpEscolha, nLinDisplay)
	
	If !Empty(cOpcSelec)
		oTef:cGet := cOpcSelec
	Endif
	
Endif

// Deixar a linha disponível para digitacao para o usuario
LjTEFDispV(nValor, nLinDisplay, cMsg)

// Apresentar as mensagem a ser apresentada na tela que nao sao 
// apresentada na dialog e sao perguntas atraves de MsgYesNo
LjTEFDispY(cPergunta, nLinDisplay)

// Apresentar as mensagens do botao selecionado
If !Empty(cOpcBot)
	LjTEFDispB(nLinDisplay, cOpcBot, cMsg)
Endif

Return Nil

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjAtivDigD
Funcao para ativar/desativar apresentacao dos dados do teclado no display 
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param1     lAtiva Indica se deve ativar a apresentacao no display do que eh digitado no teclado
@return    Nil 
@version	P10
@since	19/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Function LjAtivDigD(lAtiva)

Local lUsaDisplay	:= !Empty(LjGetStation("DISPLAY"))		// Verifica se a estacao possui Display

DEFAULT lAtiva := .T.

If !lUsaDisplay
	Return Nil
Endif

If lAtiva
	If VALTYPE(oMens) == "O" .AND. ("SENHA" $ UPPER(oMens:cCaption) .OR. "SUPERVISOR" $ UPPER(oMens:cCaption))
		// Inibe os caracteres no display para o caso de senhas e apresenta *
		DisplayEnv(StatDisplay(), "**")
	Else
		// Libera os caracteres no display
		DisplayEnv(StatDisplay(), "*")
	Endif
Else
	// Inibe a apresentacao no display do que eh digitado no teclado
	DisplayEnv(StatDisplay(), "***")
Endif


Return Nil

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjLimpDisp
Funcao para "limpar" a tela do display
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@return    Nil
@version	P10
@since	07/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Function LjLimpDisp()

Local lUsaDisplay	:= !Empty(LjGetStation("DISPLAY"))		// Verifica se a estacao possui Display

If !lUsaDisplay
	Return Nil
Endif

// Limpar o display
DisplayEnv(StatDisplay(), "1                                  ")
DisplayEnv(StatDisplay(), "2                                  ")
DisplayEnv(StatDisplay(), "3                                  ")
DisplayEnv(StatDisplay(), "4                                  ")

// Permitir apresentar os dados digitados no display
DisplayEnv(StatDisplay(), "*")

Return Nil

//---------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDispM
Funcao para apresentar as mensagens do objeto TSay oMens na tela para displays
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param     cMsg Mensagem a ser apresentada no  display
@param     lPause Parametro que indica se o pause precisa ser adicionado apos a mensagem de acordo com os comandos enviados pelo TEF
@return    nRet - numero da proxima linha a ser impressa no display
@version	P10
@since	07/01/2015
/*/
//---------------------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDispM(cMsg, lPause)

Local cMsgDisplay	:= ""						// Linha de mensagem a ser apresentada no Display 
Local cMsgOrig	:= ""						// Mensagem original a ser apresentada no display antes das tratativas
Local cMsgTela	:= ""						// Mensagem a ser apresentada na tela que eh equivalente ao do display
Local nCnt1		:= 0						// Contador para loops For
Local nPosEspaco	:= 0						// Posicao do ultimo espaco dentro dos 33 caracteres da linha 
Local nTamLinha	:= 0						// Tamanho da mensagem a ser apresentada na tela
Local nRet			:= 0						// Numero da proxima linha a ser impressa no display

DEFAULT cMsg		:= ""
DEFAULT lPause	:= .F.

cMsgOrig	:= cMsg
cMsg		:= StrTran(cMsg, ",", ".")
cMsg		:= StrTran(cMsg, CHR(10), " ") + " "

// Quebrar a mensagem para não quebrar os 33 caracteres por linha no display
While !Empty(cMsg)
	
	// Limpar o display
	LjLimpDisp()
		
	cMsgTela := ""
	
	For nCnt1 := 1 To 4
		
		// Paginacao
		If nCnt1 == 4 .AND. !Empty(cMsg)
		
			cMsgDisplay	:= STR0178		// ### <ENTER> - Para continuar
			cMsgTela 		+= cMsgDisplay												// Mensgem para a tela
			DisplayEnv(StatDisplay(), ALLTRIM(Str(nCnt1)) + "E" + cMsgDisplay)	
			
			MsgInfo(cMsgDisplay, "TEF")
			
			Exit
		
		Endif
		
		// Nao precisa paginar
		If Empty(cMsg)
			Exit
		Endif
		
		cMsgDisplay	:= LEFT(cMsg, 33)						// Pegar os primeiros 33 caracteres
		nPosEspaco		:= RAt(" ", cMsgDisplay)				// Identificar o ultimo espaco dentre desse 33 caracteres
		cMsgDisplay	:= LEFT(cMsg, nPosEspaco-1)			// Pegar o string ateh este ultimo espaco para nao quebrar palavras
		nTamLinha		:= LEN(cMsgDisplay)					// Obter a quantidade de caracteres a ser apresentados na tela para
																// retirar da mensagem e nao apresentar novamente no display
		
		cMsg 			:= Substr(cMsg, nTamLinha+1)		// Retirar da mensagem o string que vai ser apresentado no display
		cMsgTela 		+= cMsgDisplay + CRLF				// Mensgem para a tela
		
		DisplayEnv(StatDisplay(), ALLTRIM(Str(nCnt1)) + "E" + cMsgDisplay)
	
	Next nCnt1

EndDo

// Pausa na mensagem
If lPause
	
	cMsgDisplay	:= STR0178		// ### <ENTER> - Para continuar
	cMsgTela 		+= cMsgDisplay												// Mensgem para a tela
	DisplayEnv(StatDisplay(), ALLTRIM(Str(nCnt1)) + "E" + cMsgDisplay)	
	
	nCnt1++
	
	If nCnt1 > 4
		// Limpar o display e voltar para a linha 1
		LjLimpDisp()
		nCnt1 := 1
	Endif
	
Endif

nRet := nCnt1 

Return nRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDispE
Funcao para apresentar as opcoes de escolha na tela para displays e capturar a opcao escolhida pelo usuario
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param     cMsg Mensagem a ser apresentada no  display
@param     cOpEscolha Opcoes de escolha enviadas pelo TEF quando eh necessario montar a lista para usuario selecionar 
@param     nLinDisplay Numero da linha em que pode ser adicionada mensagem no display
@return    cRet Opcao escolhida pelo usuario
@version	P10
@since	07/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDispE(cMsg, cOpEscolha, nLinDisplay)

Local cRet			:= ""		// Retorno da funcao - opcao escolhida pelo usuario
Local cMsgDisplay	:= ""		// Linha de mensagem a ser apresentada no Display 
Local cMsgTela	:= ""		// Mensagem a ser apresentada na tela que eh equivalente ao do display
Local nContLin	:= 0		// Contador de linhas do display - no loop While 
Local aEscolhas	:= {}		// Array com as opcoes que o usuario poderah realizar
Local nQtdEscol	:= 0		// Quantidade de escolhas que o usuario vai ter para escolher
Local lVisDeNovo	:= .T.		// Indica se o usuario vai visualizar as opcoes novamente
Local lJaVisual	:= .F.		// Indica que as opcoes ja foram visualizadas 1 vez pelo usuario
Local nCnt1		:= 0		// Contador para loops for
Local cOpc			:= 0		// Opcao escolhida pelo usuario
Local aOpcoes		:= {}		// Lista com o codigo das opcoes que o usuario pode selecionar
Local aOpcLista	:= {}		// array com as opcoes a serem apresentadas na tela que captura os dados do teclado do display
Local aLinhas		:= {}		// lista com tudo o que estah sendo enviado para o display	


DEFAULT cOpEscolha	:= ""
DEFAULT nLinDisplay	:= 0
DEFAULT cMsg			:= ""

// Apresentar as escolhas que o usuario pode digitar
If !Empty(cOpEscolha)
	
	While lVisDeNovo
	
		If !lJaVisual
	
			cMsgDisplay	:= 	STR0178	// ### "<ENTER> - Para continuar"
			cMsgTela 		+= cMsgDisplay												// Mensgem para a tela
			DisplayEnv(StatDisplay(), ALLTRIM(Str(nLinDisplay)) + "E" + cMsgDisplay)	
			
			MsgInfo(cMsgDisplay, "TEF")
		
		Endif
	
		aEscolhas := StrToKArr(cOpEscolha,";")
	
		// Limpar o display
		LjLimpDisp()
		
		nQtdEscol := LEN(aEscolhas)
		
		// Inicializar a contagem das linhas
		nContLin := 1
				
		// Printar as escolhas na Tela
		For nCnt1 := 1 To nQtdEscol
		
			cMsgDisplay	:=	aEscolhas[nCnt1]									// Opcao
			cMsgTela 		+= cMsgDisplay 										// Mensgem para a tela
			DisplayEnv(StatDisplay(), ALLTRIM(Str(nContLin)) + "E" + cMsgDisplay)
			
			// Alimentar o array com as opcoes que o usuario pode digitar
			aAdd(aOpcoes, VAL(Substr(cMsgDisplay, 1, At(":",cMsgDisplay)-1))) 
			
			// Alimentar o array com as opcoes a serem apresentadas na tela que captura os dados do teclado do display
			aAdd(aOpcLista, cMsgDisplay)
			
			// Alimentar a lista com tudo o que estah sendo enviado para o display, para posteriormente apresentar nova-
			// mente caso o usuario digite a opcao errada
			aAdd(aLinhas, cMsgDisplay)
			
			nContLin++
			
			// Paginacao
			If nContLin == 4 .OR. nCnt1 == nQtdEscol
				
				cMsgDisplay	:=	STR0180 + " |"	// ### "Digite a opcao:"
				cMsgTela 		+= cMsgDisplay										// Mensgem para a tela
				DisplayEnv(StatDisplay(), ALLTRIM(Str(nContLin)) + "E" + cMsgDisplay)	
			
				// Alimentar a lista com tudo o que estah sendo enviado para o display, para posteriormente apresentar nova-
				// mente caso o usuario digite a opcao errada
				aAdd(aLinhas, cMsgDisplay)
				
				//MsgInfo(cMsgDisplay, "TEF")
				cOpc := LjTEFDispT(cMsg, aOpcoes, aOpcLista, aLinhas)
				
				If !Empty(cOpc)
					// Jah selecionou a opcao, nao precisa ver as demais
					Exit
				Endif
				
				// Limpar o display
				LjLimpDisp()
				
				aOpcoes := {}
				aOpcLista := {}
				aLinhas := {}
				
				// Reiniciar a contagem das linhas
				nContLin := 1	
				
			Endif
		
		Next nCnt1
		
		// Limpar o display
		LjLimpDisp()
		
		// Usuario nao selecionou nenhuma opcao ele pode ver novamente para escolher
		If Empty(cOpc) 
		
			cMsgDisplay	:=	STR0183	// ### "Ver as opcoes novamente? "
			cMsgTela 		:= cMsgDisplay										// Mensgem para a tela
			DisplayEnv(StatDisplay(), "1E" + cMsgDisplay)	
			cMsgDisplay	:=	STR0184	// ### "<ENTER> - Confirma"
			DisplayEnv(StatDisplay(), "2E" + cMsgDisplay)	
			cMsgDisplay	:=	STR0185	// ### "<ESC> - Cancela"
			DisplayEnv(StatDisplay(), "3E" + cMsgDisplay)
			
			lVisDeNovo := MsgYesNo(cMsgTela, "TEF")
			
			// Limpar o display
			LjLimpDisp()
			
			lJaVisual := .T.
			
		Else
			lVisDeNovo := .F.
		Endif
		
	EndDo	
	
	// Para nao estourar o tamanho do visor
	If nContLin == 5
	
		nContLin := 1
		
		// Limpar o display
		LjLimpDisp()
		
	Endif
	
Endif

cRet := cOpc

Return cRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDispV
Funcao para pedir a digitacao de dados/valores na tela para displays
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param     nValor Valor default quando o campo de digitacao de valores e opcoes eh liberado para o usuario
@param     cMsg Mensagem a ser apresentada no  display 
@param     nLinDisplay Numero da linha em que pode ser adicionada mensagem no display
@return    Nil
@version	P10
@since	07/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDispV(nValor, nLinDisplay, cMsg)

Local cMsgDisplay	:= ""										// Linha de mensagem a ser apresentada no Display 
Local cMsgTela	:= ""										// Mensagem a ser apresentada na tela que eh equivalente ao do display

DEFAULT nLinDisplay	:= 0
DEFAULT nValor		:= NIL

// Deixar a linha disponível para digitacao para o usuario
If !(nValor == NIL)
	
	If LjTEFDValV(cMsg)
		
		cMsgDisplay	:= STR0187		// ### "Entre com o dado:"
		DisplayEnv(StatDisplay(), ALLTRIM(Str(nLinDisplay)) + "E" + cMsgDisplay + "|")
	
	Else
	
		cMsgDisplay	:= 	STR0178	// ### "<ENTER> - Para continuar"
		cMsgTela 		+= cMsgDisplay												// Mensgem para a tela
		DisplayEnv(StatDisplay(), ALLTRIM(Str(nLinDisplay)) + "E" + cMsgDisplay)	
	
	Endif
	
Endif

Return Nil

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDispY
Funcao para apresentar as perguntas atraves de MsgYesNo na tela para displays
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param     cPergunta Texto de perguntas a serem apresentadas para o usuario confirmar ou cancelar
@return    Nil
@version	P10
@since	07/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDispY(cPergunta)

Local cMsgDisplay	:= ""										// Linha de mensagem a ser apresentada no Display 
Local cMsgTela	:= ""										// Mensagem a ser apresentada na tela que eh equivalente ao do display
Local nContLin	:= 0										// Contador de linhas do display - no loop While
Local nPosEspaco	:= 0										// Posicao do ultimo espaco dentro dos 33 caracteres da linha
Local nTamLinha	:= 0										// Tamanho da mensagem a ser apresentada na tela
Local nCnt1		:= 0										// Contador para loops For

DEFAULT cPergunta	:= ""

// Apresentar as mensagem a ser apresentada na tela que nao sao 
// apresentada na dialog e sao perguntas atraves de MsgYesNo
If !Empty(cPergunta)
	
	cPergunta := StrTran(cPergunta, ",", ".")
	aMsg := StrToKArr(cPergunta, CHR(10))

	// Limpar o display
	LjLimpDisp()
	
	nQtdMsg := LEN(aMsg)
	
	// Inicializar a contagem das linhas
	nContLin := 1
	
	cMsgDisplay	:=	STR0188	// ### "ATENCAO - MENSAGEM P/ CONFIRMAR"
	cMsgTela 		+= cMsgDisplay										// Mensgem para a tela
	DisplayEnv(StatDisplay(), ALLTRIM(Str(nContLin)) + "E" + cMsgDisplay)	
	
	nContLin++
	
	// Inicializar a variavel de mensagens
	cMsg := ""
	
	// Printar as escolhas na Tela
	For nCnt1 := 1 To nQtdMsg
	
		// Start...
		cMsg := aMsg[nCnt1] + " "
		
		While !Empty(cMsg)
		
			// Paginacao
			If nContLin == 4
				
				cMsgDisplay	:=	STR0178	// ### "<ENTER> - Para continuar"
				cMsgTela 		+= cMsgDisplay										// Mensgem para a tela
				DisplayEnv(StatDisplay(), ALLTRIM(Str(nContLin)) + "E" + cMsgDisplay)	
				
				MsgInfo(cMsgDisplay, "TEF")
					
				// Limpar o display
				LjLimpDisp()
				
				// Reiniciar a contagem das linhas
				nContLin := 1		
				
			Endif
		
			cMsgDisplay	:= LEFT(cMsg, 33)						// Pegar os primeiros 33 caracteres
			nPosEspaco		:= RAt(" ", cMsgDisplay)				// Identificar o ultimo espaco dentre desse 33 caracteres
			cMsgDisplay	:= LEFT(cMsg, nPosEspaco-1)			// Pegar o string ateh este ultimo espaco para nao quebrar palavras
			nTamLinha		:= LEN(cMsgDisplay)					// Obter a quantidade de caracteres a ser apresentados na tela para
																	// retirar da mensagem e nao apresentar novamente no display
			
			cMsg 			:= Substr(cMsg, nTamLinha+1)		// Retirar da mensagem o string que vai ser apresentado no display
			
			DisplayEnv(StatDisplay(), ALLTRIM(Str(nContLin)) + "E" + cMsgDisplay)
				
			nContLin++
			
		EndDo
		
		// Para apresentar a ultima linha da msg e deixar o usuario visualizar
		If nCnt1 == nQtdMsg
			
			// Paginacao
			If nContLin > 4
					
				// Limpar o display
				LjLimpDisp()
				
				// Reiniciar a contagem das linhas
				nContLin := 1		
				
			Endif
			
			cMsgDisplay	:=	STR0178	// ### "<ENTER> - Para continuar"
			cMsgTela 		+= cMsgDisplay										// Mensgem para a tela
			DisplayEnv(StatDisplay(), ALLTRIM(Str(nContLin)) + "E" + cMsgDisplay)	
			
			MsgInfo(cMsgDisplay, "TEF")
			
		Endif
	
	Next nCnt1
	
	// Selecao das opcoes pelo usuario
	DisplayEnv(StatDisplay(), "1E " + STR0189 )		// ### "<ENTER> - Confirmar"		
	DisplayEnv(StatDisplay(), "2E " + STR0190 )		// ### "<ESC> - Cancelar"
	
Endif

Return Nil

//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDispP
Funcao que realiza tratativas dos comandos do TEF indicando se deve ser apresentada a mensagem para o usuario
pressionar o <ENTER> no teclado quando estiver utilizando displays
@author	Vendas Cliente
@param     lPause Parametro que indica se o pause precisa ser adicionado apos a mensagem de acordo com os comandos enviados pelo TEF
@return    lRet Indica se deve ser apresentada a mensagem para o usuario pressionar o <ENTER> para continuar
@version	P10
@since	07/01/2015
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDispP(lPause)

Local lRet := .F.			// Indica se deve ser apresentada a mensagem para o usuario pressionar o <ENTER> para continuar

DEFAULT lPause := .F.

DO CASE

	CASE oTef:nProxComan == 22 .AND. IsInCallStack("LJTelaTEF")
		lPause := .T.

END CASE

lRet := lPause

Return lRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDValV
Funcao para validar as excecoes na digitacao dos dados
@author	Vendas Cliente
@param     cMsg Mensagem a ser apresentada no  display
@return    lRet Indica se deve ser apresentada as mensagens de digitacao do dados
@version	P10
@since	07/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDValV(cMsg)

Local lRet := .T.			// Indica se deve ser apresentada as mensagens de digitacao do dados

DEFAULT cMsg := ""

If (oTef:nTipoCampo==505 .OR. oTef:nTipoCampo==511) .AND. Alltrim(Upper(cMsg))==Upper("Forneca o numero de parcelas")
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDispB
Funcao para apresentar as opcoes de teclar nos botoes
@author	Vendas Cliente
@param     nLinDisplay Numero da linha em que pode ser adicionada mensagem no display
@param     cOpcBot Opcao do botao onde pode ser "E": Encerrar; "C": Continuar; "V": Voltar
@param     cMsg Mensagem a ser apresentada no  display
@return    Nil
@version	P10
@since	07/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDispB(nLinDisplay, cOpcBot, cMsg)

Local nCnt1		:= 0	// Variavel para loops For
Local cMsgDisplay	:= ""	// Mensagem a ser enviada para o Display

DEFAULT nLinDisplay	:= 0
DEFAULT cOpcBot		:= ""
DEFAULT cMsg			:= ""

// Colocar duas linhas no display
For nCnt1 := 1 To 2

	If nCnt1 == 1
		cMsgDisplay	:= STR0191	// ### <ENTER> - Acionar botao
	Else
		If cOpcBot == "E"
			cMsgDisplay	:= STR0181	// ### < -> > - Digitar novamente
		Else
			cMsgDisplay	:= STR0192	// ### <TAB> - Proximo botao
		Endi
	Endif

	DisplayEnv(StatDisplay(), ALLTRIM(STR(nLinDisplay)) + "E " + cMsgDisplay )

	nLinDisplay++
	
Next nCnt1

Return Nil

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFDispT
Funcao para interface q receber a digitação das opções oriundas do teclado do Display
@author	Vendas Cliente
@param     cMens Mensagem referente a escolha a ser realizada pelo usuario atraves do teclado com display
@param     aOpcoes Array com a lista de opcoes a serem apresentadas no display e na tela
@param     aOpcLista Array com o codigo das opcoes que o usuario pode escolher atraves da tela e do teclado com display 
@param     aLinhas Array com as linhas que jah estavam impressas no display para o caso do usuario digitar opcao incorreta
@return    cGet1 Codigo da opcao escolhida pelo usuario
@version	P10
@since	15/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------------
Static Function LjTEFDispT(cMens, aOpcoes, aOpcLista, aLinhas)

Local oDlg  := NIL		// Caixa de dialogo para interagir com as digitacoes no teclado de acordo com as mensagens do display  		
Local cGet1 := "  "		// Objeto para receber os dados a serem digitados
Local oGet1 := NIL		// Variavel para receber os dados a serem digitados
Local cGet2 := "  "		// Objeto criado para permitir executar o valid do objeto oGet1
Local oGet2 := NIL		// Variavel do objeto criado para permitir executar o valid do objeto oGet1
Local oSay  := NIL		// Objeto para apresentar a mensagem contida no parametro cMens
Local oFontOpc := NIL	// Objeto para a fonte com o texto contendo as opcoes a serem escolhidas pelo usuario
Local nCnt1 := 0			// Variavel para loops For			
Local cEscolhas := ""	// Texto com todas as opcoes de escolha que serao apresentadas na tela

DEFAULT aOpcoes := {}
DEFAULT aLinhas := {}

LjAtivDigD(.T.)

DEFINE FONT oFontMens NAME "Arial" 		SIZE 10,25 BOLD			//Mensagem do SITEF
DEFINE FONT oFontOpc	 NAME "Arial" 		SIZE 07,17 BOLD			//Get a ser digitado pelo operador

For nCnt1 := 1 To LEN(aOpcLista)
	cEscolhas += aOpcLista[nCnt1] + CRLF
Next nCnt1

oDlg := TDialog():New(180,180,330,650,'TEF',,,,,CLR_BLACK,CLR_WHITE,,,.T.)  

@ 10,10 SAY cMens FONT oFontMens COLOR CLR_GREEN 	SIZE 300,40  OF oDlg PIXEL

@ 40,10 SAY cEscolhas FONT oFontOpc COLOR CLR_BLUE 	SIZE 250,250  OF oDlg PIXEL

@ 25,10 MSGET oGet2 VAR cGet2 SIZE 10,10 OF oDlg PIXEL
@ 25,10 MSGET oGet1 VAR cGet1 SIZE 10,10 VALID LjTEFValDi(oDlg, cGet1, aOpcoes, aLinhas, oGet1) OF oDlg PIXEL 

oGet1:bGotFocus := {||LjAtivDigD(.T.)}
oGet1:bLostFocus := {||LjAtivDigD(.F.)}

oGet1:SetFocus()

// Ativa dialogo centralizado
oDlg:Activate()

// Deixar ativado a apresentacao da digitacao no display
LjAtivDigD(.T.)

Return cGet1

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTEFValDi
Funcao para validar a digitação das opções oriundas do teclado do Display através da interface da função LjTEFDispT
@author	Vendas Cliente
@param     oDlg Objeto da dialog apresentada com as opcoes a serem escolhidas pelo usuario
@param     cOpc Opcao digitada pelo usuario
@param     aOpcoes Lista de opcoes validas que o usuario pode escolher
@param     aLinhas Array com as linhas que jah estavam impressas no display para o caso do usuario digitar opcao incorreta
@param     oGet1 Objeto da caixa de texto onde o usuario digita os dados
@return    lRet Se .T. a opcao escolhida eh valida, senao eh invalida
@version	P10
@since	07/01/2015
/*/
//------------------------------------------------------------------------------------------------------------------------
Static Function LjTEFValDi(oDlg, cOpc, aOpcoes, aLinhas, oGet1)

Local lRet	:= .F.				// Variavel de retorno da funcao onde .T. a opcao eh valida e .F. opcao invalida 
Local nPos	:= 0				// Usado para receber retorno do aScan em aOpcoes
Local nCnt	:= 1				// Contador para loops for
Local nQtd	:= LEN(aLinhas)	// Qtd de itens no array aLinhas

DEFAULT oDlg		:= Nil
DEFAULT cOpc		:= ""
DEFAULT aOpcoes	:= {}
DEFAULT aLinhas	:= {}
DEFAULT oGet1		:= Nil

nPos := aScan(aOpcoes, {|x| x == VAL(ALLTRIM(cOpc))})

If !Empty(nPos) .OR. Empty(cOpc)
	// Opcao valida
	oDlg:End()
	lRet := .T.
Else
	// Opcao invalida
	LjLimpDisp()
	
	DisplayEnv(StatDisplay(), "1E " + STR0179)		// ### "Opcao invalida"
	DisplayEnv(StatDisplay(), "2E " + STR0178)		// ### "<ENTER> para continuar"
	
	MsgInfo(STR0179 + CRLF + STR0178, "TEF")		// ### "Opção inválida" ### "<ENTER> para continuar"
	
	// Reapresentar a lista de opcoes para o usuario
	For nCnt := 1 To nQtd
		DisplayEnv(StatDisplay(), ALLTRIM(cValToChar(nCnt)) + "E " + aLinhas[nCnt] )
	Next nCnt
	
	// Limpar a digitacao para digitar novamente
	oGet1:cText := "  "
	
	lRet := .F.
Endif

Return lRet

/*                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LjTEFPend ºAutor ³Vendas Clientes     º Data ³ 25/02/2016   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Determina a acao a ser tomada pelo sistema quando existir   º±±
±±º          ³ transacao TEF pendente.                                     º±±
±±º          ³                                                             º±±
±±º          ³ * OPCOES: 1=Confirma; 2=Cancela; 3=Deixa pendente           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 - Posicao do conteudo do parametro a ser considerado. º±±
±±º          ³   Posicao 1: Considera o momento que entra no sistema.      º±±
±±º          ³   Posicao 2: Considera a saida/abandono da venda.           º±±
±±º          ³   Posicao 3: Utilizado qdo. ocorre problema na impressao do º±±
±±º          ³              comprovante TEF.                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjTEFPend(nPos)
Local cRet 		:= ""
Local cMVLJTEFPD:= AllTrim(SuperGetMV("MV_LJTEFPD",,"")) //Define se as transacoes TEF pendentes serao "1=Confirmadas", "2=Canceladas" ou "3=Permanecem Pendentes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exemplos de Configuracao do parametro MV_LJTEFPD: ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
Exemplo 1: MV_LJTEFPD = 32 => Neste exemplo determina a acao 3 (DEIXA PENDENTE as transacoes) na entrada no sistema e, a acao 2 (CANCELA a transacoes pendentes) quando saida/abandonar a venda.
Exemplo 2: MV_LJTEFPD = 12 => Neste exemplo determina a acao 1 (CONFIRMA as transacoes pendentes) na entrada no sistema e, a acao 2 (CANCELA a transacoes pendentes) quando saida/abandonar a venda.
Exemplo 3: MV_LJTEFPD = 23 => Neste exemplo determina a acao 2 (CANCELA as transacoes pendentes) na entrada no sistema e, a acao 3 (DEIXA PENDENTE as transacoes) quando saida/abandonar a venda.
*/

LjGrvLog( "", "Configuracao do parametro MV_LJTEFPD", cMVLJTEFPD ) 

cRet := SubStr(cMVLJTEFPD,nPos,1)

Return cRet

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjIsStone
Funcao para validar se está na tela de cancelamento e a rede é Stone
@author	eduardo.sales
@return lRet 
@version P12
@since	22/04/2017
/*/
//------------------------------------------------------------------------------------------------------------------------
Static Function LjIsStone()

Local lRet := .F.

// Cod: 00265 -> Rede STONE
If lCancLJ140 .And. lIsDocTef .And. Len(oTef:aRetCartao) > 0 .And. oTef:nTipoCampo == 516 .And. oTef:aRetCartao[1]:cCodRede == "00265"
	lRet := .T.
EndIf

Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} LjTEFRCSPin
Utiliza recarga sem pin-pad 

@type 	 function
@author  fabiana.silva
@version P11.8
@since   19/07/2017
@return  lRet
/*/
//----------------------------------------------------------
Function LjTEFRCSPin()
Local lRet := .F.

If !IsBlind()
	lRet := GetPvProfString("RecargaCelular","TipoConfirmacaoNumeroCelular", "1", GetClientDir()+"CLISITEF.INI") <> "1"
EndIf

Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} LjTEFMAtu
Mensagem de continuação automática da transacao

@type 	 function
@author  fabiana.silva
@version P11.8
@since   24/07/2017
@return  lRet
/*/
//----------------------------------------------------------
Static Function LjTEFMAtu()

oTEF:cMens23 :=  STR0204 + Str(Max(Int(oTef:nSecFinC23 - Seconds()),0)) + " " + STR0203 //"Continuando a Transação em "#"segs"
oSay:cCaption := oTEF:cMens23

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDigCPF
Solicita digitação do CPF pelo PinPaD
@type Method

@author  	JMM
@version 	V12.1.25
@since   	30/07/2019
@return  	aRet , array de duas posições [01] = Indica se a solicitação foi efetuada [02] = Guarda o numero do CPF digitado pelo cliente
/*/
//-------------------------------------------------------------------
Method LjDigCPF() Class MSTEF
Local aRet		:= {.F.,""}														// Array de retorno, [01] = Comunicou com PinPad, [02] = CPF
Local cEntrada 	:= "011111DIGITE SEU CPF                  CONFIRME O CPF  "		// Mensagem a ser apresentada no visor do PinPad
Local cSaida	:= "011100000000000"											// Usado para retorno com o CPF digitado pelo cliente
Local nRetDLL	:= 0															// Retorno de sucesso ou não ao comando da DLL

// Verifica se PinPad esta configurado
If oAutocom:SIT_VERPIN() == 1
	// Chama o metodo para digitação do CPF
	nRetDLL :=  oAutocom:SIT_DIGCPF(cEntrada, @cSaida)

	Do Case
		Case nRetDLL == 0
			// Verifica se eh CPF ou CNPJ
			If SubStr(cSaida,12,1) == ""
				cSaida := SubStr(cSaida,1,11)
			EndIF

			If  LJXDVALCGC(@cSaida)
				aRet[01] := .T.
				aRet[02] :=	cSaida
			Else
				LjGrvLog( "LjDigCPF", "CPF Inválido!",)	
			EndIf
		Case nRetDLL == -43
			MSGAlert( STR0207)  // "Problema com o PinPad. Verifique!"
			LjGrvLog( "LjDigCPF", "Problema com o PinPad. Verifique!",)
		Case nRetDLL == -2
			MSGAlert( STR0208 ) // "Operação cancelada!"
			LjGrvLog( "LjDigCPF", "Operação cancelada!",)		
		OtherWise
			MSGAlert( STR0209 ) // "Falha no comando da DLL!"
			LjGrvLog( "LjDigCPF",  "Falha no comando da DLL!",)
	EndCase
Else
	If cModulo != 'TMK'
		LjGrvLog( "LjDigCPF", "Pin-Pad não configurado",)
	EndIf
EndIf

Return aRet
