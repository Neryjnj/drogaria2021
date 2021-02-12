#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO0010 ; Return  // "dummy" function - Internal Use 

/*��������������������������������������������������������������������������������
���Programa  |DROCInfoPed    �Autor  �Vendas Clientes     � Data � 21/01/08    ���
������������������������������������������������������������������������������͹��
���Desc.     �CLASSE DROCInfoPed()                                         	   ��� 
������������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 	 	                   ���
��������������������������������������������������������������������������������*/
Class DROCInfoPed 			//Informacoes referentes ao pedido de compra

	Data nMinCusto			//valor do menor custo
	Data dDtMinCusto		//Data do menor custo
	Data nMaxCusto			//Valor da maior compra
	Data dDtMaxCusto		//Data da maior compra
	Data cCodProd			//Codigo do produto
	Data cUnidProd			//Unidade de medida
	Data nUltCompra			//Valor da ultima compra
	Data dDtUltCompra		//Data da ultima compra
	Data nUltPrVenda		//Valor do ultimo preco de venda
	Data dUltDtVenda		//Data da ultima venda
	Data cNomeFabr			//Nome do fabricante
	Data nMediaAtraso		//Media atraso
	Data nVMesAtual			//Venda Mes atual
	Data nVMesAnterior		//Venda Mes anterior
	Data nMediaMes			//Media mensal
	Data nEstoqueAtual		//Estoque atual
	Method InfoPed()  		//Construtor

EndClass

/*������������������������������������������������������������������������������
���Programa  |DROInfoPed   �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe TWBrowse   						 ��� 
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/
Method InfoPed() Class DROCInfoPed

::nMinCusto		    := 0
::dDtMinCusto		:= dDatabase
::nUltCompra		:= 0
::dDtUltCompra		:= dDatabase
::nMaxCusto			:= 0
::dDtMaxCusto		:= dDatabase
::nUltPrVenda		:= 0
::dUltDtVenda		:= dDatabase
::cCodProd		    := Space(TamSX3("B1_COD")[1])
::cNomeFabr		    := Space(TamSX3("A2_NOME")[1])
::cUnidProd		    := Space(TamSX3("B1_UM")[1])
::nMediaAtraso		:= 0
::nVMesAtual		:= 0
::nVMesAnterior		:= 0
::nMediaMes		    := 0
::nEstoqueAtual		:= 0

Return Self