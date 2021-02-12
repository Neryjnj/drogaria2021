#include "Protheus.ch"

/*�����������������������������������������������������������������������������������
���Programa  � DroRel01	�Autor	�Totvs                       � Data �  22/07/08	  ���
���������������������������������������������������������������������������������͹��
���Desc.	 � Emissao de relatorio para os itens nao atendidos pelo EDI.         ���
���������������������������������������������������������������������������������͹��
���Uso		 � Template Drogaria												  ���
�����������������������������������������������������������������������������������*/
Template Function DroRel01( aRelat )
Local   aOrd 		  := {}
Local   cDesc1		  := "Este programa tem como objetivo imprimir os itens "
Local   cDesc2		  := "do pedido de compra nao atendidos pela prioridade."
Local   cDesc3		  := ""
Local   titulo		  := "ITENS NAO ATENDIDOS"
Local   Cabec1		  := "Nro PC  Produto" + Space(60) + "Qtde"
Local   Cabec2		  := ""
Local   nLin 		  := 80

DEFAULT aRelat		  := {}

Private lEnd 		  := .F.
Private lAbortPrint	  := .F. 
Private CbTxt		  := ""
Private limite		  := 80 		// 80, 132 ou 220
Private tamanho		  := "P"		//	P,	 M ou	G
Private nomeprog 	  := "DROREDI"	// Nome do programa para impressao no cabecalho
Private nTipo		  := 18 		// 18 normal, 15 comprimido
Private aReturn		  := { "Zebrado", 1, "Administra��o", 2, 2, 1, "", 1 }
Private nLastKey 	  := 0
Private cbcont		  := 00
Private CONTFL		  := 01
Private m_pag		  := 01
Private wnrel		  := "DROREDI1" // nome do arquivo usado para impressao em disco

Pergunte( "", .F. )
wnrel := SetPrint( nil, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T. )
If nLastKey == 27
	Return
EndIf

SetDefault( aReturn, "" )

If nLastKey == 27
	Return
EndIf

//�����������������������������������������������������������Ŀ
//� Monta a janela com a regua de processamento.              �
//�������������������������������������������������������������
RptStatus( {|| RunReport( Cabec1, Cabec2, Titulo, nLin, aRelat ) }, Titulo )

Return

/*�����������������������������������������������������������������������������������
���Programa  �RunReport �Autor	�Totvs                       � Data �  22/07/08	  ���
���������������������������������������������������������������������������������͹��
���Desc.	 � Processamento do relatorio                                         ���
���������������������������������������������������������������������������������͹��
���Uso		 � Template Drogaria												  ���
�����������������������������������������������������������������������������������*/
Static Function RunReport( Cabec1, Cabec2, Titulo, nLin, aRelat )
Local nInc		:= 0			// Contador para leitura do array aRelat
Local cProdDesc	:= ""			// Descricao do produto

SetRegua( Len( aRelat ) )
For nInc := 1 To Len( aRelat )
	cProdDesc := ""

	//�����������������������������������������������������������Ŀ
	//� Verifica o cancelamento pelo usuario...                   �
	//�������������������������������������������������������������
	If lAbortPrint
		@nLin, 00 PSAY "*** CANCELADO PELO OPERADOR ***"
		EXIT
	EndIf

	//�����������������������������������������������������������Ŀ
	//� Impressao do cabecalho do relatorio...                    �
	//�������������������������������������������������������������
	If nLin > 55 // Salto de P�gina. Neste caso o Formulario tem 55 linhas...
		Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		nLin := 8
	EndIf

	DbSelectArea( "SB1" )
	DbSetOrder( 1 )
	If SB1->( DbSeek( xFilial( "SB1" ) + aRelat[nInc][2] ) )
		cProdDesc := SB1->B1_DESC
	EndIf

	@nLin, 00 PSAY aRelat[nInc][1]
	@nLin, 08 PSAY aRelat[nInc][2] + IIf( !Empty( cProdDesc ), "-" + cProdDesc, "" )
	@nLin, 71 PSAY Transform( aRelat[nInc][3], "@e 99,999.99" )
	nLin++
Next nInc

//�����������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                       �
//�������������������������������������������������������������
SET DEVICE TO SCREEN

//�����������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenicador de impressao   �
//�������������������������������������������������������������
If aReturn[5] == 1
  SET PRINTER TO
  OurSpool( wnrel )
EndIf

MS_FLUSH() 

Return
//���������������������������������������������������������������������������������Ŀ
//�Nro PC  Produto                                                            Qtde  �
//�999999  999999999999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       99,999.99 �
//�012345678901234567890123456789012345678901234567890123456789012345678901234567890|
//�          1         2         3         4         5         6         7         8|
//�����������������������������������������������������������������������������������