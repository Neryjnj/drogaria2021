#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1942 ; Return                     

/*���������������������������������������������������������������������������
���Programa  �LJADadosTransacao �Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Armazena as informacoes para realizacao de uma transacao    ��� 
���          �utilizando TEF.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
���������������������������������������������������������������������������*/
Class LJADadosTransacao

	Data nValor														//Valor da transacao
   	Data nCupom														//Numero de identificacao da transacao
   	Data dData														//Data da transacao
   	Data cHora														//Hora da transacao
	Data nTipoTrans													//Tipo da transacao utilizado o DEFTEF.CH 
	Data lUltimaTrn                                                 //Ultima transacao - Utilizada para o gerenciador Direcao
	Data cRede														//Rede da Transacao
	Data oRetorno													//Objeto do tipo LJATransacaoTef
	Data nParcela													//Numero de parcelas para vendas parceladas
	Data dDataVcto  												//Data da transacao de pre-datado	
	Data cOperador													//Operador da venda
	Data cTpDoc														//tipo de documento utilizado no pbm => 0 - ecf, 1 - nfce, 2 -sat
	Data cCodAut													//c�digo da autoriza��o - VIDALINK
	Data cCodProd													//c�digo do produto - VIDALINK
	
	Method New()
	Method Retorno()

EndClass                

/*---------------------------------------------------------------------------
���Programa  �New          �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method New(	nValor		, 	nCupom		, 	dData	,	cHora, ;
			nTipoTrans	,	lUltimaTrn	,	cRede	,	cTpDoc, ;
			cOperador	, 	cCodAut		,	cCodProd			) Class LJADadosTransacao 
			
Default lUltimaTrn := .T. //Valida apenas para gerenciador Direcao
Default cTpDoc	   := "1" //Insiro padr�o NFCE
Default cCodAut	   := ""
Default cCodProd   := ""

Self:nValor		:= nValor
Self:nCupom		:= nCupom
Self:dData		:= dData
Self:cHora		:= cHora
Self:nTipoTrans	:= nTipoTrans
Self:lUltimaTrn	:= lUltimaTrn   
Self:oRetorno 	:= Nil   
Self:cRede		:= cRede
Self:nParcela	:= 0
Self:dDataVcto	:=	CtoD("  /  /  ")
Self:cOperador  := cOperador
Self:cTpDoc		:= cTpDoc //tipo de documento utilizado no pbm => 0 - ecf, 1 - nfce, 2 -sat
Self:cCodAut	:= cCodAut
Self:cCodProd	:= cCodProd

Return Self 

/*---------------------------------------------------------------------------
���Programa  �Retorno      �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Obtem o retorno da classe.                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
---------------------------------------------------------------------------*/
Method Retorno() Class LJADadosTransacao
Return Self:oRetorno