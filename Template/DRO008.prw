#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO008 ; Return  // "dummy" function - Internal Use 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |DROCParTCheckBoxบAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse componentizada para a criacao de objeto TCheckBox()   	 	บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 		                 	บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/     
Class DROCParTCheckBox		//Parametros para o TCheckBox

	Data nLinha   				//Dimensionamento da tela (linha) 
	Data nColuna  				//Dimensionamento da tela (coluna)
	Data oDLG					//Objeto tela principal
	Data lMarcado       		//Controle de marca e desmarca
	Data cString				//Texto que sera' visualizado para CheckBox
	Data nTamanho       		//Tamanho do texto que sera' visualizado
	Method ParTCheckBox()		//Metodo Construtor

EndClass   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |CompTGroup   บAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe  DROCParTCheckBox				  	 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1  - Dimensionamento da tela (linha)           			 บฑฑ
ฑฑบ          ณExpN2  - Dimensionamento da tela (coluna)  		         	 บฑฑ
ฑฑบ          ณExpO3  - Objeto tela principal                             	 บฑฑ
ฑฑบ          ณExpL4  - Controle de marca e desmarca                      	 บฑฑ
ฑฑบ          ณExpC5  - Texto que sera' visualizado para CheckBox        	 บฑฑ
ฑฑบ          ณExpN6  - Tamanho do texto que sera' visualizado       	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณSELF                                                        	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 		                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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