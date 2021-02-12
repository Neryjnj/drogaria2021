#INCLUDE 'PROTHEUS.CH'
#INCLUDE "MSOBJECT.CH"
 
User Function DRO007 ; Return  // "dummy" function - Internal Use 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |DROCParTWBrowseบAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCLASSE DROCParTWBrowse()										   บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 	 	                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  |ParTWBrose   บAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe TWBrowse   						 บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpN1  - Dimensionamento da tela (linha inicial)            	 บฑฑ
ฑฑบ          ณExpN2  - Dimensionamento da tela (coluna inicial)            	 บฑฑ
ฑฑบ          ณExpN3  - Dimensionamento da tela (linha final)               	 บฑฑ
ฑฑบ          ณExpN4  - Dimensionamento da tela (coluna final)              	 บฑฑ
ฑฑบ          ณExpO5  - Objeto tela principal                               	 บฑฑ
ฑฑบ          ณExpC6  - Nome do objeto que sera' atualizado                 	 บฑฑ
ฑฑบ          ณExpA7  - Array com informacoes de cabecalho                  	 บฑฑ
ฑฑบ          ณExpA8  - Arrya com os titulos do cabecalho                   	 บฑฑ
ฑฑบ          ณExpA9  - Array com o tamanho dos campos                      	 บฑฑ
ฑฑบ          ณExpA10 - Array com o conteudo a ser visualizado              	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ														         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras) 		                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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