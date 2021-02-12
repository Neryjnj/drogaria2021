#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO006 ; Return  // "dummy" function - Internal Use 

/*������������������������������������������������������������������������������
���Programa  |DROCParTGroup�Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �CLASSE DROCParTGroup()									   	 ��� 
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/
Class DROCParTGroup		//Parametros para o TGroup

	Data nLinhaIni		//Linha inicial
	Data nColunaIni		//Coluna Inicial
	Data nLinhaFim		//Linha Final
	Data nColunaFim		//Coluna Final
	Data cTitulo		//Titulo
	Data oDLG			//Objeto Tela origem
   	Method ParTGroup()		//Metodo Construtor

EndClass 

/*������������������������������������������������������������������������������
���Programa  |ParTGroup    �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe DROCParTGroup					   	 ��� 
����������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Dimensionamento da tela (linha inicial)           	 ���
���          �ExpN2  - Dimensionamento da tela (coluna inicial)           	 ���
���          �ExpN3  - Dimensionamento da tela (linha final)              	 ���
���          �ExpN4  - Dimensionamento da tela (coluna final)            	 ���
���          �ExpC5  - Texto para criacao do Group                      	 ���
���          �ExpO6  - Objeto tela principal                                 ���
����������������������������������������������������������������������������͹��
���Retorno   �SELF													         ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/
Method ParTGroup(nLinIni, nColIni, nLinFim, nColFim,;
				 cTexto	, oDlg) Class DROCParTGroup

DEFAULT nLinIni	:= 0
DEFAULT nColIni	:= 0
DEFAULT nLinFim	:= 0
DEFAULT nColFim	:= 0
DEFAULT cTexto	:= ""
DEFAULT oDlg	:= NIL

::nLinhaIni		:= nLinIni
::nColunaIni	:= nColIni	
::nLinhaFim     := nLinFim
::nColunaFim    := nColFim
::cTitulo       := cTexto
::oDLG          := oDlg
	
Return Self