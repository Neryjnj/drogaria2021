#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1927 ; Return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJCRetornoSitefºAutor³VENDAS CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Armazena o retorno de uma transacao com o CliSitef        º±± 
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     
*/
Class LJCRetornoSitef  
    
	Data lTransOK														//Indica se a transacao foi efetuada
	Data nCodTrans   													//Codigo da transacao selecionada (Tabela de codigos de meios de pagamento, configuracoes e menus)
	Data cBinCartao														//Bin do cartao	
	Data cInstit														//Instituicao que ira processar a transacao
	Data cTpCartao														//Tipo do cartao da transacao
	Data cAdmFin														//Administradora financeira retornada na transacao
	Data cCodMod														//Codigo da modalidade
	Data cDescMod														//Descricao da modalidade
	Data cDesModCup														//Descricao da modalidade que deve ser impresso no cupom
	Data cDescPgto														//Descricao do pagamento
	Data lJurosLoja														//Indica se o juros he do logista
	Data cViaCliente													//Comprovante tef via do cliente
	Data cViaCaixa														//Comprovante tef via do caixa
	Data cNsuSitef														//Nsu do sitef (Transacao de cartoes, recarga de celular)
	Data cNsuAuto														//Nsu do autorizador (Transacao de cartoes, recarga de celular)
	Data cCodAuto														//Codigo da autorizacao (Transacao de cartoes, Correspondente bancario)
	Data dData															//Data da transacao
	Data cHora															//Hora da transacao
   	Data cAutentica														//Texto da autenticacao do tef
	Data nParcelas    													//Numero de parcelas
	Data cTpComprov														//Tipo do comprovante que será entregue para impressao
	Data nVlrSaque														//O valor do troco em dinheiro a ser devolvido para o cliente
	Data nVlrVndcDesc													//O valor da venda com desconto do TEF
	Data nVlrDescTEF													//O valor do desconto do TEF
	Data oDataParcs														//Data de cada parcela
	Data oValParcs                                                      //Valor de cada parcela
	Data dPrimParc														//Data da primeira parcela
	Data nValorPgto														//Valor do pagamento(Transacoes de cartoes, recarga de celular)
	Data nValorCanc														//Valor a ser cancelado
	Data cTrilha1														//Contém a Trilha 1, quando disponível, obtida na função LeCartaoInterativo
	Data cTrilha2														//Contém a Trilha 2, quando disponível, obtida na função LeCartaoInterativo
	Data cSenhaCli														//Senha do cliente capturada através da rotina LeSenhaInterativo 
	Data dPredatado														//Data do pre-datado
	Data nIntervalo														//Intervalo em dias entre parcelas
	Data dDataCanRei													//Data do cancelamento ou re-impressao
	Data cCartao														//Numero do cartao digitado
	Data cVencCartao													//Data de vencimento do cartao MMAA
	Data cSegCartao														//Codigo de seguranca do cartao
   	Data cDocCanRei														//Numero do documento do cancelamento ou re-impressao
   	Data cOperadora														//Nome da Operadora de Celular selecionada para a operação
   	Data cCelular														//DDD + Número do celular a ser recarregado
   	Data cDigitos														//Digito(s) verificadores celular
	Data cCep															//Cep da localidade onde está o terminal no qual a operação está sendo feita (Celular)
	Data cFormaCel														//Forma de pagamento utilizado na recarga de celular nao fiscal
	Data oDataVenc														//Data de vencimento do titulo/convenio - correspondente bancario
	Data oVlrOrig														//Valor original do titulo/convenio - correspondente bancario
	Data oVlrAcre														//Valor do acrescimo do titulo/convenio - correspondente bancario
	Data oVlrAbat														//Valor do abatimento do titulo/convenio - correspondente bancario
   	Data oVlrPgto														//Valor pago do titulo/convenio - correspondente bancario
   	Data nIndiceDoc														//Indice do documento titulo/convenio (Multiplas contas) - correspondente bancario 
   	Data dDataPgto														//Data do pagamento do titulo/convenio - correspondente bancario
	Data cCedente														//Nome do Cedente do titulo/convenio - correspondente bancario
	Data nVlrTotCB														//Valor total dos titulos/convenios pago - correspondente bancario
	Data nVlrNaoPago													//Valor total dos titulos/convenios nao pago - correspondente bancario
	Data nTipoDocCB														//Tipo do documento: 0 ' Arrecadacao, 1 ' Titulo (Ficha de compensacao), 2 ' Tributo - correspondente bancario
	Data nBanco															//Numero do banco
   	Data nAgencia														//Numero da agencia
   	Data nConta															//Numero da conta
   	Data nCheque														//Numero do cheque
   	Data nC1															//C1
   	Data nC2															//C2
   	Data nC3															//C3
   	Data nCompensa														//Compensacao	
	Data cNsuCancCB														//NSU SiTEF da transacao original (transacao de cancelamento) - correspondente bancario
	Data cNsuOriCan														//NSU Correspondente Bancario da transacao original (transacao de cancelamento)
	Data oCodBarras                                                     //Codigo de barras do titulo/convenio - correspondente bancario
	Data nTipoDocCh														//Tipo do Documento a ser consultado (0 - CPF, 1 - CGC)
	Data cCPFCGC														//Numero do documento (CPF ou CGC)
	Data cTelefone														//Numero do telefone
	Data nMesFechad														//Captura se eh mes fechado (0) ou nao (1)
	Data cRede															//Rede do sitef
	Data aAdmin															//Administradoras selecionadas
	Data cAdmCV															//Administradoras da Carteira Virtual CV
	Data cIDAdmCV														// ID da Administradora da Carteira Virtual
	Data aItemsPBM														//Lista com itens - PBM
	Data nQtdeMed														//Qtde de medicamentos - PBM
	Data nIndAtuMed														//Indice atual do medicamento - PBM
	Data cCNPJConvenio													//CNPJ do convenio - PBM
	Data cCodPlano														//Código do Plano - PBM
	Data cCRM															//CRM - PBM
	Data cUF															//UF - PBM
	Data cNumPreAut														//Numero PreAutorização - PBM
	Data cSaldoDisp														//Saldo - PBM
	Data cDataIni														//Data Inicial - PBM
	Data cDataFim														//Data Final - PBM
	Data cNomeConveniado												//Nome Conveniado - PBM
	Data cNomEmpConv													//Empresa do Convenio - PBM

	Method New()

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³New          ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCRetornoSitef  
	
	Self:lTransOK		:= .F.
	Self:nCodTrans		:= 0
	Self:cBinCartao		:= ""
	Self:cInstit		:= ""
	Self:cTpCartao		:= ""
	Self:cAdmFin		:= ""
	Self:cCodMod		:= 0
	Self:cDescMod		:= ""
	Self:cDesModCup		:= ""
	Self:cDescPgto		:= ""
	Self:lJurosLoja		:= .F.
	Self:cViaCliente	:= ""
	Self:cViaCaixa		:= ""
	Self:cNsuSitef		:= ""
	Self:cNsuAuto		:= ""
	Self:cCodAuto		:= ""
	Self:dData			:= CtoD("  /  /  ")
	Self:cHora			:= "00:00"
	Self:cAutentica		:= ""
	Self:nParcelas		:= 0
	Self:cTpComprov		:= ""
	Self:nVlrSaque		:= 0
	Self:nVlrVndcDesc	:= 0
	Self:nVlrDescTEF	:= 0
	Self:oDataParcs		:= LJCHashTable():New()														
	Self:oValParcs		:= LJCHashTable():New()
	Self:dPrimParc		:= CtoD("  /  /  ")     
	Self:nValorPgto		:= 0
	Self:nValorCanc		:= 0    
	Self:cTrilha1		:= ""
	Self:cTrilha2		:= ""
	Self:cSenhaCli		:= ""
	Self:dPredatado		:= CtoD("  /  /  ")
	Self:nIntervalo		:= 0
	Self:dDataCanRei	:= CtoD("  /  /  ")	
	Self:cCartao		:= ""
	Self:cVencCartao	:= ""
	Self:cSegCartao		:= ""
	Self:cDocCanRei		:= ""
	Self:cOperadora		:= ""
	Self:cCelular		:= ""
	Self:cDigitos		:= ""
	Self:cCep			:= ""
	Self:cFormaCel		:= ""
	Self:oDataVenc		:= LJCHashTable():New()	 	
	Self:oVlrOrig		:= LJCHashTable():New()	 
	Self:oVlrAcre		:= LJCHashTable():New()	 
	Self:oVlrAbat		:= LJCHashTable():New()	 
	Self:oVlrPgto		:= LJCHashTable():New()	 
	Self:nIndiceDoc		:= 0
	Self:dDataPgto		:= CtoD("  /  /  ")	
	Self:cCedente		:= ""
	Self:nVlrTotCB		:= 0
	Self:nVlrNaoPago	:= 0
	Self:nTipoDocCB		:= 0
	Self:nBanco			:= 0
   	Self:nAgencia		:= 0
   	Self:nConta			:= 0
   	Self:nCheque		:= 0
   	Self:nC1			:= 0
   	Self:nC2			:= 0
   	Self:nC3			:= 0
   	Self:nCompensa		:= 0
   	Self:cNsuCancCB		:= ""
   	Self:cNsuOriCan		:= ""
   	Self:oCodBarras		:= LJCHashTable():New()	
   	Self:nTipoDocCh		:= 0
   	Self:cCPFCGC		:= ""
   	Self:cTelefone		:= ""
   	Self:nMesFechad		:= 0     
   	Self:cRede			:= ""  
   	Self:aAdmin			:= {}
	Self:cAdmCV			:= ""
	Self:cIDAdmCV		:= ""
	Self:aItemsPBM		:= {}
	Self:nQtdeMed		:= 0
	Self:nIndAtuMed		:= 0
	Self:cCNPJConvenio  := ""
	Self:cCodPlano		:= ""
	Self:cCRM			:= ""
	Self:cUF			:= ""
	Self:cNumPreAut		:= ""
	Self:cSaldoDisp		:= ""
	Self:cDataIni		:= ""
	Self:cDataFim		:= ""
	Self:cNomeConveniado:= ""
	Self:cNomEmpConv	:= ""
			
Return Self