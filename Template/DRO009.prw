#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO009 ; Return  // "dummy" function - Internal Use 

/*���������������������������������������������������������������������������������
���Programa  |DROCParTRadMenu �Autor  �Vendas Clientes     � Data � 21/01/08    ���
�������������������������������������������������������������������������������͹��
���Desc.     �Classe componentizada para a criacao de objeto TRadMenu()   	 	��� 
�������������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 	���
���������������������������������������������������������������������������������*/ 
Class DROCParTRadMenu		//Parametros para o TRadMenu

	Data nLinha   				//Dimensionamento da tela (linha) 
	Data nColuna  				//Dimensionamento da tela (coluna)
	Data oDLG					//Objeto tela principal
	Data aOpcoes       	   		//Array com informacoes disponiveis para a marcacao
	Data nOpcoes				//Opcao a ser escolhida
	Method ParTRadMenu()		//Metodo Construtor

EndClass  

/*������������������������������������������������������������������������������
���Programa  |CompTGroup   �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe  DROCParTRadMenu				  	 ��� 
����������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Dimensionamento da tela (linha)		              	 ���
���          �ExpN2  - Dimensionamento da tela (coluna)			          	 ���
���          �ExpO3  - Objeto tela principal                              	 ���
���          �ExpA4  - Array com informacoes disponiveis para a marcacao  	 ���
���          �ExpN5  - Opcao a ser escolhida                              	 ���
����������������������������������������������������������������������������͹��
���Retorno   �SELF                                                        	 ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/   
Method ParTRadMenu(nLinha , nColuna, oDLG, aOpcoes,;
				   nOpcoes) Class DROCParTRadMenu

DEFAULT nLinha	 := 0   	
DEFAULT nColuna	 := 0
DEFAULT oDLG	 := NIL
DEFAULT aOpcoes  := {}
DEFAULT nOpcoes	 := 1

::nLinha	:= nLinha  	
::nColuna  	:= nColuna
::oDLG		:= oDLG	
::aOpcoes 	:= aOpcoes      
::nOpcoes	:= nOpcoes

Return Self