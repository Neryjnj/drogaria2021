#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO009 ; Return  // "dummy" function - Internal Use 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |DROCParTRadMenu บAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse componentizada para a criacao de objeto TRadMenu()   	 	บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 		                 	บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Class DROCParTRadMenu		//Parametros para o TRadMenu

	Data nLinha   				//Dimensionamento da tela (linha) 
	Data nColuna  				//Dimensionamento da tela (coluna)
	Data oDLG					//Objeto tela principal
	Data aOpcoes       	   		//Array com informacoes disponiveis para a marcacao
	Data nOpcoes				//Opcao a ser escolhida
	Method ParTRadMenu()		//Metodo Construtor

EndClass  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |CompTGroup   บAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe  DROCParTRadMenu				  	 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1  - Dimensionamento da tela (linha)		              	 บฑฑ
ฑฑบ          ณExpN2  - Dimensionamento da tela (coluna)			          	 บฑฑ
ฑฑบ          ณExpO3  - Objeto tela principal                              	 บฑฑ
ฑฑบ          ณExpA4  - Array com informacoes disponiveis para a marcacao  	 บฑฑ
ฑฑบ          ณExpN5  - Opcao a ser escolhida                              	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณSELF                                                        	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 		                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
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