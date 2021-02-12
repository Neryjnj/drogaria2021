#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO006 ; Return  // "dummy" function - Internal Use 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |DROCParTGroupบAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCLASSE DROCParTGroup()									   	 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 		                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class DROCParTGroup		//Parametros para o TGroup

	Data nLinhaIni		//Linha inicial
	Data nColunaIni		//Coluna Inicial
	Data nLinhaFim		//Linha Final
	Data nColunaFim		//Coluna Final
	Data cTitulo		//Titulo
	Data oDLG			//Objeto Tela origem
   	Method ParTGroup()		//Metodo Construtor

EndClass 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |ParTGroup    บAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe DROCParTGroup					   	 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1  - Dimensionamento da tela (linha inicial)           	 บฑฑ
ฑฑบ          ณExpN2  - Dimensionamento da tela (coluna inicial)           	 บฑฑ
ฑฑบ          ณExpN3  - Dimensionamento da tela (linha final)              	 บฑฑ
ฑฑบ          ณExpN4  - Dimensionamento da tela (coluna final)            	 บฑฑ
ฑฑบ          ณExpC5  - Texto para criacao do Group                      	 บฑฑ
ฑฑบ          ณExpO6  - Objeto tela principal                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณSELF													         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 		                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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