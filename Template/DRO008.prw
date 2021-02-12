#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO008 ; Return  // "dummy" function - Internal Use 

/*���������������������������������������������������������������������������������
���Programa  |DROCParTCheckBox�Autor  �Vendas Clientes     � Data � 21/01/08    ���
�������������������������������������������������������������������������������͹��
���Desc.     �Classe componentizada para a criacao de objeto TCheckBox()   	 	��� 
�������������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 	���
���������������������������������������������������������������������������������*/     
Class DROCParTCheckBox		//Parametros para o TCheckBox

	Data nLinha   				//Dimensionamento da tela (linha) 
	Data nColuna  				//Dimensionamento da tela (coluna)
	Data oDLG					//Objeto tela principal
	Data lMarcado       		//Controle de marca e desmarca
	Data cString				//Texto que sera' visualizado para CheckBox
	Data nTamanho       		//Tamanho do texto que sera' visualizado
	Method ParTCheckBox()		//Metodo Construtor

EndClass   

/*������������������������������������������������������������������������������
���Programa  |CompTGroup   �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe  DROCParTCheckBox				  	 ��� 
����������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Dimensionamento da tela (linha)           			 ���
���          �ExpN2  - Dimensionamento da tela (coluna)  		         	 ���
���          �ExpO3  - Objeto tela principal                             	 ���
���          �ExpL4  - Controle de marca e desmarca                      	 ���
���          �ExpC5  - Texto que sera' visualizado para CheckBox        	 ���
���          �ExpN6  - Tamanho do texto que sera' visualizado       	     ���
����������������������������������������������������������������������������͹��
���Retorno   �SELF                                                        	 ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/
Method ParTCheckBox(nLinha , nColuna, oDLG, lMarcado,;
					cString, nTamanho) Class DROCParTCheckBox

DEFAULT nLinha	 := 0   	
DEFAULT nColuna	 := 0
DEFAULT oDLG	 := NIL
DEFAULT lMarcado := .F.	
DEFAULT cString	 := ""
DEFAULT nTamanho := 0

::nLinha	:= nLinha  	
::nColuna  	:= nColuna
::oDLG		:= oDLG	
::lMarcado 	:= lMarcado      
::cString	:= cString
::nTamanho 	:= nTamanho      


Return Self