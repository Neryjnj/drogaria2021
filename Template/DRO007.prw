#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO007 ; Return  // "dummy" function - Internal Use 

/*��������������������������������������������������������������������������������
���Programa  |DROCParTWBrowse�Autor  �Vendas Clientes     � Data � 21/01/08    ���
������������������������������������������������������������������������������͹��
���Desc.     �CLASSE DROCParTWBrowse()										   ��� 
������������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 	 	                   ���
��������������������������������������������������������������������������������*/
Class DROCParTWBrowse		//Parametros para o TWBrose

	Data nLinhaIni   		//Dimensionamento da tela (linha inicial) 
	Data nColunaIni  		//Dimensionamento da tela (coluna inicial)
	Data nLinhaFim			//Dimensionamento da tela (linha final)
	Data nColunaFim			//Dimensionamento da tela (coluna final)
	Data oDLG				//Objeto tela principal
	Data cObj               //Nome do objeto que sera' atualizado
	Data aHdr               //Array com informacoes de cabecalho
	Data aTitulo   	       	//Array com os titulos do cabecalho
	Data aTamanho			//Array com o tamanho dos campos
	Data aConteudo			//Array com o conteudo a ser visualizado 

	Method ParTWBrose()		//Metodo Construtor

EndClass 

/*������������������������������������������������������������������������������
���Programa  |ParTWBrose   �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe TWBrowse   						 ��� 
����������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Dimensionamento da tela (linha inicial)            	 ���
���          �ExpN2  - Dimensionamento da tela (coluna inicial)            	 ���
���          �ExpN3  - Dimensionamento da tela (linha final)               	 ���
���          �ExpN4  - Dimensionamento da tela (coluna final)              	 ���
���          �ExpO5  - Objeto tela principal                               	 ���
���          �ExpC6  - Nome do objeto que sera' atualizado                 	 ���
���          �ExpA7  - Array com informacoes de cabecalho                  	 ���
���          �ExpA8  - Arrya com os titulos do cabecalho                   	 ���
���          �ExpA9  - Array com o tamanho dos campos                      	 ���
���          �ExpA10 - Array com o conteudo a ser visualizado              	 ���
����������������������������������������������������������������������������͹��
���Retorno   �														         ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/
Method ParTWBrose(	nLinIni   , nColIni  , nLinFim, nColFim	,;
				 	oTelaPrinc, cObj     , aHdr   , aTitulo	,;
					aTamanho  , aConteudo) Class DROCParTWBrowse

DEFAULT nLinIni		:= 0
DEFAULT nColIni		:= 0
DEFAULT nLinFim		:= 0
DEFAULT nColFim		:= 0
DEFAULT oTelaPrinc	:= NIL
DEFAULT cObj      	:= ""
DEFAULT aHdr      	:= {}
DEFAULT aTitulo 	:= {}
DEFAULT aTamanho	:= {}
DEFAULT aConteudo	:= {}


::nLinhaIni		:= nLinIni
::nColunaIni	:= nColIni
::nLinhaFim		:= nLinFim
::nColunaFim	:= nColFim
::oDLG			:= oTelaPrinc
::cObj      	:= cObj
::aHdr      	:= aHdr
::aTitulo 		:= aTitulo
::aTamanho		:= aTamanho
::aConteudo		:= aConteudo

	
Return Self