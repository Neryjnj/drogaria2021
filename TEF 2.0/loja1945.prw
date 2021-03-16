#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1945 ; Return

/*��������������������������������������������������������������������������������������
���Classe    �LJCDadosTransacaoPBM �Autor  �Vendas Clientes     � Data �  11/02/10   ���
������������������������������������������������������������������������������������͹��
���Desc.     �Dados da transacao de PBM				     							 ���
������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		     ���
��������������������������������������������������������������������������������������*/
Class LJCDadosTransacaoPBM From LJADadosTransacao
	   			
	Method New(nValor, nCupom, dData, cHora, lUltimaTrn,;
				 cRede, cTpDoc, cOperador, cCodAut,	cCodProd)	//Metodo construtor
	
EndClass

/*����������������������������������������������������������������������������������
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  11/02/10   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCDadosTransacaoPBM.		    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor da transacao   				 		 ���
���			 �EXPN2 (2 - nCupom) - Numero de identificacao da transacao   		 ���
���			 �EXPD1 (3 - dData) - Data da transacao   							 ���
���			 �EXPC1 (4 - cHora) - Hora da transacao				   				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method New(nValor, nCupom, dData, cHora, lUltimaTrn, cRede, cTpDoc, cOperador, cCodAut,	cCodProd) Class LJCDadosTransacaoPBM
    
	_Super:New(nValor, nCupom, dData, cHora, _PBM, lUltimaTrn,;
				 cRede, cTpDoc, cOperador, cCodAut,	cCodProd)
   	
Return Self