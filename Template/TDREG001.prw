#INCLUDE "PROTHEUS.CH"

#DEFINE SIGALOJA  12
#DEFINE FRONTLOJA 23

/*���������������������������������������������������������������������������
���Programa  � TDREG001 � Autor � ANDRE MELO         � Data � 29.03.04    ���
�������������������������������������������������������������������������͹��
���Objetivo  � Atualiza a GetDados do orcamento (SL1/SL2) com base        ��� 
���          � Estrutura do Kit de venda                                  ���
�������������������������������������������������������������������������͹��
���Observ.   � EXECBLOCK CHAMADO PELO GATILHO L2_PRODUTO                  ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Fernando F�27.03.07�124579� Adaptacoes para a rotina de consulta de    ���
���			 �		  �      � Precos para diferenciar o que eh usado     ���
���			 �		  �      � no SIGALOJA (Venda Assistida), e o que eh  ���
���			 �		  �      � usado no FRONTLOJA (Consulta de Precos).   ���
���          �        �      � Alterado Tambem chamada da Variavel cTabPad���
���			 �		  �		 � Que eh uma variavel Private usada somente  ���	
���			 �		  �		 � no SIGALOJA.								  ���
���			 �		  �		 � Chamada para a Rotina T_ConsPrProd()		  ���
���			 �		  �		 � Gatilho para o Produto quando nao estiver  ���
���			 �		  �		 � Pl.Fidelidade e nem Regras 	 			  ���
���			 �		  �		 � Alterado o Conteudo da Variavel _cCodComp  ���
���			 �		  �		 � para trazer posicionado corretamente o     ���
���			 �		  �		 � Codigo do Produto.                         ���
��������������������������������������������������������������������������ٱ�
���Uso       � TEMPLATE DROGARIA - DRO                                    ���
���������������������������������������������������������������������������*/
Template Function TDREG001(oGetDados)
Local _lPrimeiraVez:= .T.
Local nTamItem     := TamSx3("LR_ITEM")[1]
Local _nPosIt      := aScan(aHeader,{|_x| Upper(Alltrim(_x[2])) == "LR_ITEM"})
Local nPosVlUnit   := aScan(aHeader,{|_x| Upper(Alltrim(_x[2])) == "LR_VRUNIT"})
Local nPosPDesc    := aScan(aHeader,{|_x| Upper(Alltrim(_x[2])) == "LR_DESC"}) 
Local nPosValDesc  := aScan(aHeader,{|_x| Upper(Alltrim(_x[2])) == "LR_VALDESC"})
Local _nPosComp    := aScan(aHeader,{|_x| Upper(Alltrim(_x[2])) == "LR_PRODUTO"})
Local _nPosDesc    := aScan(aHeader,{|_x| Upper(Alltrim(_x[2])) == "LR_DESCRI"})
Local _nPosQuant   := aScan(aHeader,{|_x| Upper(Alltrim(_x[2])) == "LR_QUANT"})
Local _cCodComp    := If(Empty(M->LR_PRODUTO),aCols[n][_nPosComp],M->LR_PRODUTO)
Local _aArea 	   := GetArea()
Local aAreaMHD     := {}
Local aAreaMHE     := {}
Local aAreaSB1     := {}
Local aAreaSBI	   := {}
Local cTabelaPad   := If(Type('cTabPad') == 'U', GetMv("MV_TABPAD"),cTabPad )

DEFAULT oGetDados  := NIL

Private cString   := ""
Private _cProduto := ""
Private _cDescComp:= ""

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

dbSelectArea("MHD") //Cadastro Kit do Produto
aAreaMHD := GetArea()
MHD->(dbSetOrder(1))
If MHD->(DbSeek(xFilial("MHD")+_cCodComp)) 
    If Len(aCols) > n 
    	MsgInfo("O Produto informado � um Kit. Para incluir um Kit, inclua uma linha em branco e posteriormente informe o c�digo do produto")
		RestArea(aAreaMHD)       		// Restaura a area do arquivo MHD
		RestArea(_aArea)         		// Restaura a area original
		Return(.F.)
	EndIf    	
  	_cProduto := MHD->MHD_PRODUT
	dbSelectArea("MHE") //Itens do Kit do Produto.
	If Empty(aAreaMHE)
		aAreaMHE := GetArea()
	EndIf
	MHE->(dbSetOrder(1))
   	MHE->(dbSeek(xFilial("MHE")+_cProduto))
    While MHE->(!Eof()) .And. (xFilial() == MHE->MHE_FILIAL) .And. (_cProduto == MHE->MHE_PRODUT)
	    If !_lPrimeiraVez
	         AAdd(aCols,Array(Len(aHeader)+1))
	         AEval(aHeader,{|x,y| aCols[Len(aCols)][y]:=Criavar(x[2])})
	         aCols[Len(aCols),Len(aHeader)+1] := .F.
	         n := Len(aCols)
	   	     aCols[Len(aCols),_nPosIt] := StrZero(n,nTamItem)
	
	   	     If nModulo == SIGALOJA
			       oGetVA:oBrowse:nAt 	 := n
			 ElseIf nModulo == FRONTLOJA 
			 	   oGetDados:oBrowse:nAt := n	
		     EndIf    
	    Else
	        _cCodComp := MHE->MHE_CODCOM
	    Endif
       	
       	_lPrimeiraVez:=.F.
		&(ReadVar())       := MHE->MHE_CODCOM
       	aCols[n,_nPosComp] := MHE->MHE_CODCOM
       
     	dbSelectArea("SB1")  
       	If Empty(aAreaSB1)
	       	aAreaSB1 := GetArea()
	 	EndIf
		// Preenchimento da Descricao do Produto para quando for Front Loja ou para Quando for SigaLoja.	 	
	 	If nModulo == SIGALOJA
		 	
		   	SB1->(dbSetOrder(1))
	       	If SB1->(dbSeek(xFilial("SB1")+MHE->MHE_CODCOM))
	        	aCols[n,_nPosDesc] := SB1->B1_DESC
	       	Else
	        	aCols[n,_nPosDesc] := ""
	       	EndIf   
	       	acols[n][nPosVlUnit] := Posicione("SB0",1,xFilial("SB0")+(&(ReadVar())),"SB0->B0_PRV"+cTabelaPad)
	 	ElseIf nModulo == FRONTLOJA  						// Preenchimento da Descricao do Produto para quando for ForntLoja.
				 	
	        dbSelectArea("SBI")
	        SBI->(dbSetOrder(1))
	        aAreaSBI :=SBI->(GetArea())
	       	If SBI->(dbSeek(xFilial("SBI")+MHE->MHE_CODCOM))
	        	aCols[n,_nPosDesc] := SBI->BI_DESC 
	       	Else
	        	aCols[n,_nPosDesc] := ""
	       	EndIf   
			acols[n][nPosVlUnit] := SBI->BI_PRV
		EndIf	
		aCols[n][nPosPDesc]  := 0
		aCols[n][nPosValDesc]:= 0
       	aCols[n][_nPosQuant] := MHE->MHE_QUANT      

        If nModulo ==SIGALOJA
			Lj7Prod( .T. ) 										// Executa fun��o padr�o para incluir ou alterar o produto
		ElseIf nModulo ==FRONTLOJA
			T_TDREA011(1, ,  ,If(nModulo==23,oGetDados,Nil) ) // Executa fun��o que aplica as Regras de Desconto X Plano de Fidelidade
		EndIf	
       	MHE->(dbSkip())
	EndDo  
Else
	If nModulo == FRONTLOJA
		T_ConsPrProd(oGetDados)								   // Gatilho para o Produto quando nao estiver Pl.Fidelidade e nem Regras de Desconto.
    EndIf
EndIf

If nModulo == FRONTLOJA
	aCols[n][_nPosQuant] := If(Empty(aCols[n][_nPosQuant]),01,aCols[n][_nPosQuant]) // Forcando Valor inicial da Quantidade.
	T_DrocCalcTot("TDREG001",n) 													  //  Rotina de Atualizacao dos Totais do Rodape.
EndIf

RestArea(aAreaMHD) 		// Restaura a area do arquivo MHD
If !Empty(aAreaMHE)
	RestArea(aAreaMHE) 	// Restaura a area do arquivo MHE
EndIf
If !Empty(aAreaSB1)
	RestArea(aAreaSB1) 	// Restaura a area do arquivo SB1
EndIf                                   
If !Empty(aAreaSBI)
	RestArea(aAreaSBI) 	// Restaura a area do arquivo SB1
EndIf              
RestArea(_aArea)		// Restaura area original

Return .T.
