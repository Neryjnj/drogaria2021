#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1017 ; Return  			// "dummy" function - Internal Use

/*------------------------------------------------------------------------------------
ฑฑบClasse    ณLJCDadosSitefDiretoบAutor  ณVendas Clientes     บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em armazenar os dados da transacao.               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		   บฑฑ
------------------------------------------------------------------------------------*/
Class LJCDadosSitefDireto
	
	Data nRetorno							//Ira guardar o codigo de retorno da funcao
	Data nRedeDest							//Codigo da rede de destino (provedor)
	Data nFuncSitef						    //Codigo da funcao sitef
	Data nOffSetCar							//Posicao do inicio do cartao no dados TX
	Data cDadosTx							//Dados da transacao
	Data nTaDadosTx							//Tamanho do dados TX
	Data cDadosRx							//Dados de retorno da Transacao
	Data nTaDadosRx							//Quantidade maxima de dados que podem ser colocados em dados RX
	Data nCodResp							//Codigo de resposta retornado pelo autorizador
	Data nTempEspRx							//Tempo de espera do dados RX
	Data cCupomFisc							//Numero do cupom correspondente a operacao
	Data cDataFisc							//Data fiscal no formato AAAAMMDD
	Data cHorario							//Horario fiscal no formato HHMMSS
	Data cOperador							//Identificacao do operador de caixa
	Data nTpTrans							//Indica se a transacao e apenas de consulta (valor 0) ou se e uma
											//transacao que exige uma confirmacao
	Data cCodAut							//c๓digo da autoriza็ใo VIDALINK
	Data cCodProd							//c๓digo do produto VIDALINK
	Data aVDLink							//outros dados PBM
	Data cRestri							//Restri็ใo para enviar conteudo na PBM
	Data nValor								//Valor 
	
	Method DadosSitef()						//Metodo construtor

EndClass

/*-------------------------------------------------------------------------
|Metodo    ณDadosSitefบAutor  ณVendas Clientes     บ Data ณ  04/09/07     |
---------------------------------------------------------------------------
|Desc.     ณConstrutor da classe LJCDadosSitefDireto.		              |
---------------------------------------------------------------------------
|Uso       ณSigaLoja / FrontLoja                                          |
-------------------------------------------------------------------------*/
Method DadosSitef() Class LJCDadosSitefDireto

	::nRetorno			:= 0
	::nRedeDest 		:= 0
	::nFuncSitef 		:= 0
	::nOffSetCar		:= 0
	::cDadosTx			:= ""
	::nTaDadosTx		:= 0
	::cDadosRx			:= ""
	::nTaDadosRx		:= 0
	::nCodResp			:= 0
	::nTempEspRx		:= 0
	::cCupomFisc		:= ""
	::cDataFisc			:= ""
	::cHorario			:= ""
	::cOperador			:= ""
	::nTpTrans			:= 0
	::cCodAut			:= ""
	::cCodProd			:= ""
	::aVDLink			:= {}
	::cRestri			:= ""
	::nValor			:= 0

Return Self