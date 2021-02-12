#INCLUDE 'PROTHEUS.CH'            
#INCLUDE "MSOBJECT.CH"
 
//�Definicao de variavel em objeto
#XTRANSLATE bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

User Function DRO005 ; Return  // "dummy" function - Internal Use 

/*������������������������������������������������������������������������������
���Programa  |DroCCompTela �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �CLASSE DroCCompTela()											 ��� 
����������������������������������������������������������������������������͹��
���Retorno   �SELF													         ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/
Class DroCCompTela 					//Componentes de telas.
 	
 	Method CompTela()	        	//Metodo Construtor
	Method CompTGroup(oParTGroup)	
	Method CompTWBrose(oParTWBrose)
	Method CompTCheckBox(oParTCheckBox)
	Method CompTRadMenu(oParTRadMenu)
	
EndClass    

/*������������������������������������������������������������������������������
���Programa  |CompTela	   �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo constrututor da classe DroCCompTela				   	 ��� 
����������������������������������������������������������������������������͹��
���Retorno   �SELF													         ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
������������������������������������������������������������������������������*/
Method CompTela() Class DroCCompTela  
Return Self

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  |CompTGroup   �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao componentizada para a criacao de objeto TGroup()   	 ��� 
����������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Dimensionamento da tela (linha inicial)           	 ���
���          �ExpN2  - Dimensionamento da tela (coluna inicial)           	 ���
���          �ExpN3  - Dimensionamento da tela (linha final)              	 ���
���          �ExpN4  - Dimensionamento da tela (coluna final)            	 ���
���          �ExpC5  - Texto para criacao do Group                      	 ���
���          �ExpO6  - Objeto tela principal                                 ���
����������������������������������������������������������������������������͹��
���Retorno   �														         ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method CompTGroup(oParTGroup) Class DroCCompTela  
//DRO006						
TGroup():New(	oParTGroup:nLinhaIni, oParTGroup:nColunaIni	, oParTGroup:nLinhaFim	, oParTGroup:nColunaFim	,;
			 	oParTGroup:cTitulo  , oParTGroup:oDLG		, NIL	 				, NIL	  				, .T.)

Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �CompTWBrose�Autor  �Vendas Clientes     � Data � 21/01/08    ���
��������������������������������������������������������������������������͹��
���Desc.     �Funcao componentizada para a criacao de objeto TwBrowse()    ���
��������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Dimensionamento da tela (linha inicial)             ���
���          �ExpN2  - Dimensionamento da tela (coluna inicial)            ���
���          �ExpN3  - Dimensionamento da tela (linha final)               ���
���          �ExpN4  - Dimensionamento da tela (coluna final)              ���
���          �ExpO5  - Objeto tela principal                               ���
���          �ExpC6  - Nome do objeto que sera' atualizado                 ���
���          �ExpA7  - Array com informacoes de cabecalho                  ���
���          �ExpA8  - Arrya com os titulos do cabecalho                   ���
���          �ExpA9  - Array com o tamanho dos campos                      ���
���          �ExpA10 - Array com o conteudo a ser visualizado              ���
��������������������������������������������������������������������������͹��
���Retorno   �ExpO1  - Objeto instanciado a partir do TwBrowse             ���
��������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras)                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method CompTWBrose(oParTGroup) Class DroCCompTela  
//DRO007
Local oList 	//Retorno da funcao


oList := TwBrowse():New( oParTGroup:nLinhaIni, oParTGroup:nColunaIni	, oParTGroup:nLinhaFim	, oParTGroup:nColunaFim,;
                          NIL 				  , oParTGroup:aTitulo		, oParTGroup:aTamanho	, oParTGroup:oDLG		,;
                          NIL 				  , NIL 					, NIL 					, NIL       			,;
                          NIL 				  , NIL 					, NIL 					, NIL       			,;
                          NIL 				  , NIL 					, NIL 					, .F.       			,;
                          NIL 				  , .T. 					, NIL 					, .F.       			,;
                          NIL 				  , NIL 					, NIL)  

                         
oList:lColDrag	  := .T.
oList:nFreeze	  := 1
oList:SetArray(oParTGroup:aConteudo)
oList:bLine	      := LocxBLin(oParTGroup:cObj,oParTGroup:aHdr,.T.)
oList:bLDblClick  :={ || ChgMarkLb(oList,@oParTGroup:aConteudo,{|| .T. },.T.) }


Return (oList)
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CompTCheckBox�Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao componentizada para a criacao de objeto TCheckBox() 	 ���
����������������������������������������������������������������������������͹��
���Parametros�ExpO1  - Objeto com as propriedades                        	 ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpO1  - Objeto instanciado a partir do TCheckBox		         ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras)  	                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method CompTCheckBox(oParTCheckBox) Class DroCCompTela  
//DRO008
Local oChkMark				//Retorno da funcao

oChkMark := TCheckBox():New( oParTCheckBox:nLinha				, oParTCheckBox:nColuna	, oParTCheckBox:cString		,;
							  bSETGET(oParTCheckBox:lMarcado)	, oParTCheckBox:oDLG	, oParTCheckBoxd:nTamanho	,;
							  10  								, NIL  					, NIL  						,;
							  NIL 								, NIL				  	, NIL 						,;
							  NIL 		   						, NIL	   			  	, .T. 						,;
							  NIL 		  						, NIL 		  		 	, NIL )
							                                                  	
Return (oChkMark)
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CompTRadMenu �Autor  �Vendas Clientes     � Data � 21/01/08    ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao componentizada para a criacao de objeto TRadMenu()   	 ��� 
����������������������������������������������������������������������������͹��
���Parametros�ExpN1  - Dimensionamento da tela (linha)		              	 ���
����������������������������������������������������������������������������͹��
���Retorno   �ExpO1  - Objeto instanciado a partir do TRadMenu		         ���
����������������������������������������������������������������������������͹��
���Uso       �TEMPLATE - DROGARIA (Central de Compras) 		                 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Method CompTRadMenu(oParTRadMenu) Class DroCCompTela  
//DRO009						
Local oRadio 	//Retorno da funcao
                                      
oRadio := TRadMenu():New(	oParTRadMenu:nLinha , oParTRadMenu:nColuna	, oParTRadMenu:aOpcoes	, bSETGET(oParTRadMenu:nOpcoes)	,;
						   	oParTRadMenu:oDLG	, NIL 				  	, NIL    				, NIL		   					,;
						   	NIL	 				, NIL 					, .T. 					, NIL							,;
						   	40	 				, 10  					, NIL					, NIL							,;
						   	NIL	 				,.T. )
Return (oRadio)
