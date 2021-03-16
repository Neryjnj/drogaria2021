#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1945 ; Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบClasse    ณLJCDadosTransacaoPBM บAutor  ณVendas Clientes     บ Data ณ  11/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDados da transacao de PBM				     							 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class LJCDadosTransacaoPBM From LJADadosTransacao
	   			
	Method New(nValor, nCupom, dData, cHora, lUltimaTrn,;
				 cRede, cTpDoc, cOperador, cCodAut,	cCodProd)	//Metodo construtor
	
EndClass

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  11/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCDadosTransacaoPBM.		    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nValor) - Valor da transacao   				 		 บฑฑ
ฑฑบ			 ณEXPN2 (2 - nCupom) - Numero de identificacao da transacao   		 บฑฑ
ฑฑบ			 ณEXPD1 (3 - dData) - Data da transacao   							 บฑฑ
ฑฑบ			 ณEXPC1 (4 - cHora) - Hora da transacao				   				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method New(nValor, nCupom, dData, cHora, lUltimaTrn, cRede, cTpDoc, cOperador, cCodAut,	cCodProd) Class LJCDadosTransacaoPBM
    
	_Super:New(nValor, nCupom, dData, cHora, _PBM, lUltimaTrn,;
				 cRede, cTpDoc, cOperador, cCodAut,	cCodProd)
   	
Return Self