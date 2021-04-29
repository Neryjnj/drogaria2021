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
	Data nCupom								//Numero do Cupom
	Data dData
	Data cHora
	Data lCancTotal							//Cancelamento total ? Senao parcial - VIDALINK

	Method DadosSitef()						//Metodo construtor
	Method IniDadoSitef(nRetorno, nRedeDest, nFuncSitef, nOffSetCar,;
					cDadosTx, nTaDadosTx, cDadosRx,nTaDadosRx,;
					nCodResp,nTempEspRx, cCupomFisc, cDataFisc,;
					cHorario,cOperador, nTpTrans, cCodAut,;
					cCodProd, aVDLink, cRestri, nValor,;
					nCupom)

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
	::nCupom			:= 0
	::dData				:= CTOD("")
	::cHora				:= ""
	::lCancTotal		:= .T.

Return Self

/*/{Protheus.doc} IniDadoSitef
	Metodo para inicializa็ใo com valores do objeto da classe	
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method IniDadoSitef(nRetorno, nRedeDest, nFuncSitef, nOffSetCar,;
					cDadosTx, nTaDadosTx, cDadosRx,nTaDadosRx,;
					nCodResp,nTempEspRx, cCupomFisc, cDataFisc,;
					cHorario,cOperador, nTpTrans, cCodAut,;
					cCodProd, aVDLink, cRestri, nValor,;
					nCupom, lCancTotal) Class LJCDadosSitefDireto

Default nRetorno 	:= 0
Default nRedeDest 	:= 0
Default nFuncSitef 	:= 0
Default nOffSetCar	:= 0
Default cDadosTx	:= ""
Default nTaDadosTx	:= 0
Default cDadosRx	:= ""
Default nTaDadosRx	:= 0
Default nCodResp	:= 0
Default nTempEspRx	:= 0
Default cCupomFisc	:= ""
Default cDataFisc	:= ""
Default cHorario	:= ""
Default cOperador	:= ""
Default nTpTrans	:= 0
Default cCodAut		:= ""
Default cCodProd	:= ""
Default aVDLink		:= {}
Default cRestri		:= ""
Default nValor		:= 0
Default nCupom		:= 0
Default lCancTotal  := .T.

::nRetorno			:= nRetorno
::nRedeDest 		:= nRedeDest
::nFuncSitef 		:= nFuncSitef
::nOffSetCar		:= nOffSetCar
::cDadosTx			:= cDadosTX
::nTaDadosTx		:= nTaDadosTx
::cDadosRx			:= cDadosRx
::nTaDadosRx		:= nTaDadosRx
::nCodResp			:= nCodResp
::nTempEspRx		:= nTempEspRx
::cCupomFisc		:= cCupomFisc
::cDataFisc			:= cDataFisc
::cHorario			:= cHorario
::cOperador			:= cOperador
::nTpTrans			:= nTpTrans
::cCodAut			:= cCodAut
::cCodProd			:= cCodProd
::aVDLink			:= aVDLink
::cRestri			:= cRestri
::nValor			:= nValor

If ValType(nCupom) <> "N" .And. !Empty(AllTrim(cCupomFisc))
	::nCupom := Val(cCupomFisc)
Else
	::nCupom := nCupom
EndIf

::dData	:= CTOD(AllTrim(cDataFisc))
::cHora	:= AllTrim(StrTran(cHorario,":"))
::lCancTotal := lCancTotal
Return Self