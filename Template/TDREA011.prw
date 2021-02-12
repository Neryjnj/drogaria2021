#INCLUDE "TOTVS.CH"
#DEFINE SIGALOJA  12
#DEFINE FRONTLOJA 23

Static cCodRegGer	// C�digo do Desconto Geral
Static aDetProd		// Array que contem Pontos por Item e Desconto
Static cPlanFide	// C�digo do Plano de Fideliza��o 
Static cDescPln		// Descricao do Plano de Fidelidade
Static cCodLjCli    // C�digo + Loja do Cliente
Static lPesqDescGer // Determina que existe regra de desconto gen�rica
Static lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)

/*���������������������������������������������������������������������������
���Programa  �TDREA011  �Autor  �Vendas Clientes     � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Recalcula o valor do item e os descontos apos o             ���
���          �preenchimento do codigo do produto.                         ���
�������������������������������������������������������������������������͹��
���Uso       �Template Drogaria - SIGALOJA Venda Assistida                ���
���������������������������������������������������������������������������*/
Template Function TDREA011( nTpOp, nTpVenda, nOpc, oGetDados )
Local aAreaAtu    := GetArea()	//Area Atual                                      	
Local nI          := 0			//Controle de loop
Local nPosItem    := 0			//Posicao da coluna LR_ITEM
Local nPosProd    := If(Type("aHeader")<>"U",aScan(aHeader,{|x| Trim(x[2]) == "LR_PRODUTO"}),0) //Posicao da coluna LR_PRODUTO
Local lAlter      := .F.		//Verifica se eh alteracao ou nao
Local aAreaSA1    := {}			//Area SA1
Local aAreaSL2    := {}			//Area SL2
Local nTotPontos  := 0			//Totalizador dos pontos
Local cCodProd    := ""			//Codigo do produto  
Local lRet        := .T.

DEFAULT nTpOp 	  := 1		
DEFAULT oGetDados := NIL 	// Objeto GetDados da Tela Consulta de Precos - Front Loja.

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

// Define o Valor de n(Linha posicionada da GetDados) caso seja do FRONTLOJA
If Type('n') == 'U'
	 If nModulo ==FRONTLOJA
		 n := oGetDados:nAT 
	 EndIF
EndIf

//������������������������������������������������������Ŀ
//�Meu aHeader nao eh definido na Rotina de Cons. Precos,�
//�somente no Venda Assistida, pois eh um Array Private. �
//��������������������������������������������������������
If Type("aHeader") =='U' .AND. nModulo == FRONTLOJA
	aHeader := aClone(oGetDados:aHeader)
EndIf

//������������������������������������������������������Ŀ
//�Meu aCols nao eh definido na Rotina de Cons. Precos,	 �
//�somente no Venda Assistida, pois eh um Array Private. �
//��������������������������������������������������������
If Type("aCols") =='U' .AND. nModulo == FRONTLOJA
	aCols := aClone(oGetDados:aCols)
EndIf

If Type("aHeader")<>"U" 
	nPosProd := aScan(aHeader,{|x| Trim(x[2]) == "LR_PRODUTO"})
	nPosItem := aScan(aHeader,{|x| Trim(x[2]) == "LR_ITEM"})
EndIf

If nTpOp == 1 //Esta sendo incluido ou alterado o produto no aCols
 	If !T_TDREAISLOJ( nModulo    , nTpOp   , nOpc, lAlter,;
 					  @nTotPontos, nTpVenda ) 	// Verifica se a Rotina nao eh SigaLoja.
		If (AllTrim(ReadVar()) == "M->LR_PRODUTO")
			If Empty(M->LR_PRODUTO)
				Return(.F.)
			EndIf
		    cCodProd := M->LR_PRODUTO
		EndIf
		
		// Se o Foco estiver no Campo LR_QUANT, guarda o Codigo do Produto
		If (AllTrim(ReadVar()) == "M->LR_QUANT")
			If Type('M->LR_PRODUTO') =='U'  .AND. Empty(aCols[n][nPosProd])
				Return(.F.)
			Else	
				cCodProd := If( Type('M->LR_PRODUTO') <>'U' .AND. !Empty(M->LR_PRODUTO),M->LR_PRODUTO,aCols[n][nPosProd])
			EndIf
		EndIf		                        

		//Verifica o Cod. Produto Digitado no aCols.
		If !LJSB1SLK(@cCodProd,,.T.)
			ApMsgInfo("N�o existe produto para o c�digo Informado, favor verificar!","Aten��o!")
			Return (.F.)
		Endif
		//��������������������������������������Ŀ
		//�Realiza o calculo dos valores da venda�
		//�e dos pontos do plano de fidelidade   �
		//����������������������������������������
		T_TDROAtuAcols(n,cCodProd,M->LQ_CPLFIDE) 
		RestArea(aAreaAtu)					  // Restaura �rea original
		
	EndIf
ElseIf nTpOp == 2
 lRet := T_TDREAISLOJ( nModulo    , nTpOp   , nOpc, lAlter,;
				  @nTotPontos, nTpVenda )
ElseIf nTpOp == 3               
	If !T_TDREAISLOJ( nModulo    , nTpOp   , nOpc, lAlter,;
					  @nTotPontos, nTpVenda ) 	  // Verifica se a Rotina eh SigaLoja ou Front Loja
		If (AllTrim(cPlanFide) <> AllTrim(M->LQ_CPLFIDE)) //.AND. (Lj7T_Subtotal(2) > 0)
			cPlanFide := M->LQ_CPLFIDE
			cDescPln  := M->LQ_PLDESC
			lAlter    := .T.
	    EndIf
		If lAlter                         
			For nI := 1 To Len(aCols)
				If !Empty(aCols[nI][nPosProd])
					T_TDROAtuAcols(nI, aCols[nI][nPosProd], cPlanFide)
				EndIf
			Next nI	                     
		EndIf
    EndIf
ElseIf nTpOp == 4
	If !T_TDREAISLOJ( nModulo    , nTpOp   , nOpc, lAlter,;
					  @nTotPontos, nTpVenda ) 	   // Verifica se a Rotina eh SigaLoja ou Front Loja	
		If (nTotPontos > 0) .AND. (SL1->L1_CLIENTE+SL1->L1_LOJA <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD")) ;
			.AND. (ColumnPos("L1_CPLFIDE") > 0) .AND. (ColumnPos("L1_PONTOS") > 0)

			// Atualiza campos referentes ao plano de fidelidade
			RecLock("SL1",.F.)
			L1_CPLFIDE := cPlanFide
			L1_PLDESC  := cDescPln
			L1_PONTOS  := nTotPontos              	
			MsUnLock()
		EndIf
			
		// So realiza a grava��o qdo � VENDA.
		If (nTpVenda == 2) .AND. (SL1->L1_CLIENTE+SL1->L1_LOJA <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD"))
			// Atualiza o total de pontos acumulados do cliente
			DbSelectArea("SA1")
			aAreaSA1 := GetArea()
			If SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA <> xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA
				dbSeek(xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA)
			EndIf
			RecLock("SA1",.F.)
			A1_PONTOS += nTotPontos
			MsUnLock()	
			
			RestArea(aAreaSA1) // Restaura a Area do arquivo SA1
	
			// Grava o hist�rico da venda
			DbSelectArea("LHG")
			RecLock("LHG",.T.)
			LHG_FILIAL := xFilial("LHG")
			LHG_CODIGO := SL1->L1_CLIENTE
			LHG_LOJA   := SL1->L1_LOJA
			LHG_NOME   := Posicione("SA1",1,xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NOME")
			LHG_CARTAO := Posicione("MA6",2,xFilial("MA6")+SL1->L1_CLIENTE+SL1->L1_LOJA,"MA6_NUM")
			LHG_DATA   := SL1->L1_EMISSAO
			LHG_CUPFIS := SL1->L1_DOC
			LHG_SERIE  := SL1->L1_SERIE
			LHG_PONTOS := SL1->L1_PONTOS
			LHG_TIPMOV := "C"
			LHG_PDV    := SL1->L1_PDV
			LHG_DTVALI := dDataBase + SuperGetmv("MV_VALPTOS",,90)  
			LHG_HORA   := SL1->L1_HORA
	   		LHG_CODPLN := Posicione("MHG",3,xFilial("MHG")+SL1->L1_CPLFIDE,"MHG_CODIGO")//SL1->L1_CPLFIDE = Cod. Regra
	   		LHG_DESCPL := Posicione("MHG",1,xFilial("MHG")+LHG_CODPLN,"MHG_NOME")		
			MsUnLock()
		EndIf
		// Reinicializa todas as vari�veis est�ticas
		cCodRegGer   := Nil	
		aDetProd     := Nil	
		cPlanFide    := Nil	
		cDescPln	 := Nil
		cCodLjCli    := Nil  
		lPesqDescGer := Nil
		RestArea(aAreaAtu) // Restaura a Area Original
	EndIf

ElseIf nTpOp == 5                               

	If !T_TDREAISLOJ( nModulo    , nTpOp   , nOpc, lAlter,;
					  @nTotPontos, nTpVenda ) // Verifica se a Rotina nao eh SigaLoja 
		If ValType("cCodLjCli") == "U"
			cCodLjCli := M->LQ_CLIENTE+M->LQ_LOJA
		EndIf
		If (AllTrim(cCodLjCli) <> AllTrim(M->LQ_CLIENTE+M->LQ_LOJA)) 
			// MsgAlert("O Cliente/Loja da venda est� sendo alterado. Ser� aplicado o desconto comum a todos os clientes e produtos, caso o mesmo exista. Para que seja aplicado o desconto espec�fico do plano de fidelidade informe o respectivo c�digo.")
			cCodLjCli     := M->LQ_CLIENTE+M->LQ_LOJA	
			M->LQ_CPLFIDE := CriaVar("LQ_CPLFIDE")
			M->LQ_PLDESC  := CriaVar("LQ_PLDESC")
			cPlanFide     := M->LQ_CPLFIDE
			cDescPln	  := M->LQ_PLDESC	
			lAlter        := .T.                 
	    EndIf
		                            
	    If lAlter
			For nI := 1 To Len(aCols)
				If !Empty(aCols[nI][nPosProd])
					T_TDROAtuAcols(nI, aCols[nI][nPosProd])
				EndIf
			Next nI
		EndIf
	EndIf	

ElseIf nTpOp == 6    

	If !T_TDREAISLOJ( nModulo    , nTpOp, nOpc, lAlter,;
					  @nTotPontos, nTpVenda ) // Verifica se a Rotina eh SigaLoja ou Front Loja	
		If nOpc == 4
				DbSelectArea("SL1")
				nTotPontos := SL1->L1_PONTOS
				cPlanFide  := SL1->L1_CPLFIDE
				//cDescPln   := SL1->L1_PLDESC	
				cCodLjCli  := SL1->L1_CLIENTE+SL1->L1_LOJA		
				RestArea(aAreaAtu)	// Restaura a Area Original
		Else               
			// Reinicializa todas as vari�veis est�ticas
			cCodRegGer  := Nil	
			aDetProd    := Nil	
			cPlanFide   := Nil	
			cDescPln	:= Nil
			cCodLjCli   := Nil  
			lPesqDescGer:= Nil 
		EndIf       
	EndIf	
EndIf 

If  T_DroSendPCM()
	//��������������������������������������������������������Ŀ
	//�Devolvendo o Conteudo atualizado do aCols para o        �
	//�Objeto Getdados de Origem, caso Seja Consulta de Precos.�
	//����������������������������������������������������������
	oGetDados := If(oGetDados == Nil, oGetDados1, oGetDados)
	oGetDados:aCols := aClone(aCols)
	oGetDados:oBrowse:Refresh()
EndIf	

Return(lRet)
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TDROAtuAcols�Autor  �Vendas Clientes     � Data �  04/10/06   ���
���������������������������������������������������������������������������͹��
���Descricao �Recalcula o valor do item e os descontos apos o               ���
���          �preenchimento do codigo do produto.                           ���
���������������������������������������������������������������������������͹��
���Uso       �Template Drogaria - SIGALOJA Venda Assistida                  ���
���������������������������������������������������������������������������͹��
���Chamada   �Validacao de usuario dos campos                         	    ���
���          �LR_PRODUTO - LR_QUANT                                         ���
���          �LR_VALDESC - LR_DESC                                          ���
���������������������������������������������������������������������������͹��
���Parametros�ExpN1 - Item                            	  				    ���
���          �ExpC1 - Codigo do produto            						    ���
���          �ExpC2 - Codigo do plano de fidelidade 					    ���
���          �ExpC3 - Rotina que esta' sendo utilizada					    ���
���������������������������������������������������������������������������͹��
���Retorno   �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Template Function TDROAtuAcols( nItem, cCodProd, cCodFidel, cOrigem )
Local nPercGrp	  		:= 0					
Local nDescPer    		:= 0          			// Percentual de desconto a ser aplicado
Local nPtosProd   		:= 0				 	// Pontos de fidelidade
Local aAreaACP    		:= {}                                 
Local aAreaACO    		:= {}
Local aAreaMHG    		:= {}
Local nDecimais   		:= MsDecimais(1)
Local cCodRegra   		:= ""                	// Codigo da regra de desconto
Local cCodGrp	  		:= ""					// Codigo do grupo de produtos	                        
Local nVlrUni	  		:= 0					// Valor unitario do Produto sem desconto.     
Local nVlr		  		:= 0					// Valor visualizado no rodape (somatoria)
Local ncont		  		:= 0					// Variavel de LOOP     
Local lAchouProd  		:= .F. 					// Achou o codigo do produto na regra de desconto ?
Local nVlrDesc    		:= 0 	    			// Valor do Desconto
Local lACOPercentual	:= .F.					// Verifica se o valor do campo ACO_PERDES esta' maior que zero
Local nPosQuant	  		:= aScan(If(nModulo == SIGALOJA,aHeader,oGetDados1:aHeader), {|x| Trim(x[2]) == "LR_QUANT"  })	// Posicao da Quantidade
Local nPosVlUnit  		:= aScan(If(nModulo == SIGALOJA,aHeader,oGetDados1:aHeader),{|x| Trim(x[2]) == "LR_VRUNIT"  })  	// Posicao do Valor unitario do item
Local nPosVlItem  		:= aScan(If(nModulo == SIGALOJA,aHeader,oGetDados1:aHeader),{|x| Trim(x[2]) == "LR_VLRITEM" }) 	// Posicao do Valor do item
Local nPosDesc	  		:= aScan(If(nModulo == SIGALOJA,aHeader,oGetDados1:aHeader),{|x| Trim(x[2]) == "LR_DESC"	  })  	// Posicao do percentual de desconto
Local nPosValDesc 		:= aScan(If(nModulo == SIGALOJA,aHeader,oGetDados1:aHeader),{|x| Trim(x[2]) == "LR_VALDESC" }) 	// Posicao do valor de desconto
Local nPosPtos 	  		:= aScan(If(nModulo == SIGALOJA,aHeader,oGetDados1:aHeader),{|x| Trim(x[2]) == "LR_PONTOS"  })	// Posicao dos Pontos de Fidelidade
Local nPosDescri        := aScan(If(nModulo == SIGALOJA,aHeader,oGetDados1:aHeader),{|x| Trim(x[2]) == "LR_DESCRI"  })	// Posicao da Descricao
Local nDescObr			:= 0					// Valor do Desconto Obrigatorio            
Local lBIDescOrb		:= SBI->(ColumnPos("BI_DESCOBR") > 0)
Local lB1DescOrb		:= SB1->(ColumnPos("B1_DESCOBR") > 0)
Local lTPLDRO01			:= ExistFunc("U_TPLDRO01()")			   // Verifica se a funcao esta' compilada no rpo
Local nAuxPDesc			:= 0							           // Armazena o retorno do ponto de entrada TPLDRO01
Local nVlrUnit			:= 0							   		   // Valor unitario
Local nCount            := 0                                       // variavel para controlar o for
Local lVAssConc		 	:= LjVassConc()							   // Indica se o cliente utiliza a Vda Assistida Concomitante

DEFAULT cCodFidel 		:= ""      

//��������������������������������������������������Ŀ
//�Caso o valor de nItem seja 0 assume o  valor de n |
//���������������������������������������������������� 
If nItem == 0
	nItem := n
EndIf
                    
If nModulo == SIGALOJA .AND. (T_DroSendPCM())
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+cCodProd)
		aCols[nItem][nPosDescri] := SB1->B1_DESC 
	EndIf
EndIf
//�������������������������������������������������������������������Ŀ
//�Pegando o preco unitario do produto.                               �
//�O preco verificado no momento do desconto sempre sera' o           �
//�preco unitario do produto e nao o preco vezes a quantidade de itens�
//�na venda.                                                          �
//���������������������������������������������������������������������
If nModulo == SIGALOJA
	If lCenVenda
		LjxeValPre (@nVlrUnit, cCodProd, M->LQ_CLIENTE, M->LQ_LOJA )
	Else		
		DbselectArea("SB0")
		DbSetOrder(1)
		DbSeek(xFilial("SB0"),.T.)
		If DbSeek(xFilial("SB0")+cCodProd)
			nVlrUnit 	 := &("SB0->B0_PRV"+cTabPad)
		EndIf
	Endif	
	                    
	If lB1DescOrb  
		nDescObr := Posicione("SB1",1,xFilial("SB1")+cCodProd, "B1_DESCOBR")			
	EndIf
ElseIf nModulo == FRONTLOJA
	If lCenVenda
		LjxeValPre (@nVlrUnit, cCodProd, "", "" )
	Else			
		DbselectArea("SBI")
		DbSetOrder(1)
		If DbSeek(xFilial("SBI")+cCodProd)
			nVlrUnit 	 := SBI->BI_PRV    
		EndIf
	
		If lBIDescOrb  
			nDescObr := SBI->BI_DESCOBR
		EndIf
	Endif
EndIf

If !Empty(cCodFidel)
	cCodRegra := Posicione("MHG",1,xFilial("MHG")+cCodFidel,"MHG_CODREG")
	If !Empty(cCodRegra)
		//����������������������������������������������������������������������������������Ŀ
		//�Verifica primeiro se o campo ACO_PERDES esta' com o valor maior que zero          �
		//�caso isso seja verdadeiro, usa o percentual de desconto deste campo para todos os �
		//�produtos escolhidos na venda.                                                     �
		//������������������������������������������������������������������������������������
		DbSelectArea("ACO")
		If DbSeek(xFilial("ACO") + cCodRegra)
			If	ACO->ACO_PERDES > 0
				nDescPer := ACO->ACO_PERDES
				lACOPercentual := .T.
			Endif
		Endif
		If !lACOPercentual
			DbSelectArea("ACP")
			aAreaACP := GetArea()
			//Busca a regra pelo codigo do produto
			DbOrderNickName("ACPDRO1")
			If DbSeek(xFilial("ACP") + cCodRegra + cCodProd)
				// Determina o % de desconto do produto
				nDescPer  := ACP->ACP_PERDES
				// Determina os pontos de fideliza��o do produto
				nPtosProd := ACP->ACP_PONTOS
				lAchouProd := .T.
			Else                            
				// Determina o % de desconto do produto
				nDescPer  := 0
				// Determina os pontos de fideliza��o do produto
				nPtosProd := 0
			EndIf
		Endif	
	Endif	
EndIf

If !lACOPercentual .AND. !lAchouProd
	If nModulo = SIGALOJA
		DbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+cCodProd))
		cCodGrp := B1_GRUPO
	ElseIf nModulo == FRONTLOJA
		cCodGrp :=Posicione("SBI",1,xFilial("SBI")+cCodProd,"BI_GRUPO")		
	EndIf
	
	If Empty(cCodGrp)  // caso nao exista grupo de produto associado ao produto
		nPercGrp  := 0 // Determina o % de desconto do produto
		nPtosGrp  := 0 // Determina os pontos de fideliza��o do produto   
	Else  
		DbselectArea("ACP")
		aAreaACP := GetArea()
		DbSetOrder(2)		
		If DbSeek(xFilial("ACP")+cCodRegra+AllTrim(cCodGrp))
			If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ;
			   ( nVlrUnit >= ACP->ACP_FAIXDE .AND. nVlrUnit <= ACP->ACP_FAIATE )			
				// Determina o % de desconto do produto
				nPercGrp  := ACP->ACP_PERDES
				// Determina os pontos de fideliza��o do produto
				nPtosGrp := ACP->ACP_PONTOS				   	
			Endif   
		Else
			//�����������������������������������������������������������������Ŀ
			//�Verifica se existe o grupo pai                                   �
			//�OBS: GRUPO PAI contem somente um digito, como por exemplo:       �
			//�GRUPO MEDICAMENTOS = 1                                           �
			//�                                                                 �
			//�Grupos que sao compostos por mais de um digito, eh definido como �
			//�SUBGRUPO, como por exemplo:                                      �
			//�GRUPO MEDICAMENTOS CONTROLADOS = 1C                              �
			//�eh um SUBGRUPO do grupo "1"                                      �
			//�������������������������������������������������������������������			
			If DbSeek(xFilial("ACP")+cCodRegra+AllTrim(Left(cCodGrp,1)))		
				If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ;
				   ( nVlrUnit >= ACP->ACP_FAIXDE .AND. nVlrUnit <= ACP->ACP_FAIATE )			
					// Determina o % de desconto do produto
					nPercGrp  := ACP->ACP_PERDES
					// Determina os pontos de fideliza��o do produto
					nPtosGrp := ACP->ACP_PONTOS				   	
				Endif   				
			Endif
		Endif		
	Endif	
	If nDescPer == 0 .AND. nPercGrp > 0 			// Verifica qual he o maior desconto (Grupo ou Produto)
		nDescPer  := nPercGrp
		nPtosProd := nPtosGrp
	Endif
	// Inicializa a vari�vel
	If ValType(lPesqDescGer) == "U"
		lPesqDescGer := .F.
	EndIf

	If !lPesqDescGer
		DbSelectArea("ACO")
		aAreaACO := GetArea()
		ACO->(dbSetOrder(1))
		While ACO->(!Eof())
			// Eh uma regra de desconto gen�rica
			DbSelectArea("MHG")
			If Empty(aAreaMHG)
				aAreaMHG := MHG->(GetArea())
			EndIf
			MHG->(dbSetOrder(3))
			If MHG->(!DbSeek(xFilial("MHG")+ACO->ACO_CODREG))
				DbSelectArea("ACP")
				dbOrderNickName("ACPDRO1")
				If ACP->(DbSeek(xFilial("ACP")+ACO->ACO_CODREG+cCodProd))
					If ACP->ACP_PERDES > nDescPer
						// Determina o % de desconto do produto
						nDescPer  := ACP->ACP_PERDES
						// Determina os pontos de fideliza��o do produto
						nPtosProd := ACP->ACP_PONTOS
					EndIf
				ElseIf !Empty(cCodGrp)
					DbSelectArea("ACP")
					aAreaACP := GetArea()
					ACP->(DbSetOrder(2))
					ACP->( DbSeek(xFilial("ACP") + cCodRegra + Left(cCodGrp,Len(cCodGrp))) )
					While ACP->(!Eof()) .AND. xFilial("ACP") + cCodRegra + Left(cCodGrp,Len(cCodGrp)) == ACP->ACP_FILIAL + ACP->ACP_CODREG + Left(ACP->ACP_GRUPO,Len(ACP->ACP_GRUPO))
						If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ;
							 ( nVlrUnit >= ACP->ACP_FAIXDE .AND. nVlrUnit <= ACP->ACP_FAIATE )
							// Determina o % de desconto do produto
							nPercGrp  := ACP->ACP_PERDES
							// Determina os pontos de fideliza��o do produto
							nPtosGrp  := ACP->ACP_PONTOS
						EndIf
						ACP->(DbSkip())
					End
				EndIf
				If nPercGrp > nDescPer // Verifica qual he o maior desconto (Grupo ou Produto no Plano)
					nDescPer  := nPercGrp
					nPtosProd := nPtosGrp
				Endif			
				// Determina a Regra de Desconto Gen�rica
				cCodRegra := ACO->ACO_CODREG
				Exit
			EndIf
			DbSelectArea("ACO")
			ACO->(dbSkip())
		End
		// Vari�vel Static que Determina que j� foi pesquisada uma Regra de Desconto Gen�rica
		lPesqDescGer := .T.
	ElseIf lPesqDescGer .AND. (ValType(cCodRegra) <> "U")
		DbSelectArea("ACP")
		dbOrderNickName("ACPDRO1")
		If DbSeek(xFilial("ACP")+cCodRegra+cCodProd)
			If ACP->ACP_PERDES > nDescPer
				// Determina o % de desconto do produto
				nDescPer  := ACP->ACP_PERDES
				// Determina os pontos de fideliza��o do produto
				nPtosProd := ACP->ACP_PONTOS
			EndIf
		ElseIf !Empty(cCodGrp)
			DbSelectArea("ACP")
			aAreaACP := GetArea()
			DbSetOrder(2)
			DbSeek(xFilial("ACP") + cCodRegra + Left(cCodGrp,Len(cCodGrp)))      
			While !Eof() .AND. xFilial("ACP") + cCodRegra + Left(cCodGrp,Len(cCodGrp)) == ACP->ACP_FILIAL + ACP->ACP_CODREG+Left(ACP->ACP_GRUPO,Len(ACP->ACP_GRUPO))
				If ( ACP->ACP_FAIXDE == 0 .AND. ACP->ACP_FAIATE == 0 .AND. nPercGrp == 0 ) .OR. ; 
				   ( nVlrUnit >= ACP->ACP_FAIXDE .AND. nVlrUnit <= ACP->ACP_FAIATE )
					// Determina o % de desconto do produto
					nPercGrp  := ACP->ACP_PERDES
					// Determina os pontos de fideliza��o do produto
					nPtosGrp  := ACP->ACP_PONTOS
				EndIf
				DbSkip()
			End	
		EndIf
	EndIf        
Endif
If nDescObr > nDescPer
	 nDescPer := nDescObr
EndIf
//�������������������������������������������������������������Ŀ
//�Ponto de entrada para calculo do % de desconto a ser aplicado�
//���������������������������������������������������������������
If lTPLDRO01
	nAuxPDesc := U_TPLDRO01( cCodProd, nDescPer, cCodRegra )
	If ValType(nAuxPDesc) == "N"
		nDescPer := nAuxPDesc
	Endif
Endif

//�������������������������������������Ŀ
//�Calculo dos valores de acordo com o  �
//�foco do campo que estiver posicionado�
//���������������������������������������
Do Case
	Case AllTrim(ReadVar()) == "M->LR_PRODUTO" .OR.( T_DroSendPCM() .AND. AllTrim(ReadVar()) == "M->LR_QUANT") 
			If nModulo == SIGALOJA 
			    If T_DroSendPCM()
			    	aCols[nItem][nPosVlUnit] := nVlrUnit - (nVlrUnit * aCols[nItem][nPosDesc] / 100) 
			    	If aCols[nItem][nPosQuant] <= 0
			    		aCols[nItem][nPosQuant] :=  1.00
			    	ElseIf AllTrim(ReadVar()) == "M->LR_QUANT" 
			    	    aCols[nItem][nPosQuant] := If (&(ReadVar()) > 0 ,&(ReadVar()), 1.00) 	  			    		
			    	EndIf 
			    EndIf
				aDetProd[nItem][3] := nDescPer 	// Valoriza array com dados referentes ao desconto e aos pontos para o plano de fidelidade
				If (nDescPer > 0) .OR. (aDetProd[nItem][3] == 0 .AND. aCols[nItem][nPosDesc] > 0)                                                    
					M->LR_DESC 		:= nDescPer 		// Realiza o acerto dos campos no aCols
					aCols[nItem][nPosDesc] := nDescPer
					aCols[nItem][nPosVlUnit] := nVlrUnit - (nVlrUnit * aCols[nItem][nPosDesc] / 100)
					Lj7VlItem(5) 				// Executa funcao calculo do desconto e recalculo dos impostos
				EndIf
			ElseIf nModulo == FRONTLOJA
				// Realiza o acerto dos campos no aCols
				M->LR_DESC := nDescPer
				aCols[nItem][nPosDesc]   := nDescPer
                aCols[nItem][nPosVlUnit] := nVlrUnit // Atualizo o Valor do Preco unitario
				If Type('M->LR_QUANT') <> 'U' 		// Cursor estah sobre o campo LR_QUANT
					aCols[nItem][nPosQuant] := If(Empty(M->LR_QUANT), 1.00, M->LR_QUANT)
				ElseIf Type('M->LR_PRODUTO') <> 'U' // Cursor estah sobre o campo LR_PRODUTO
					aCols[nItem][nPosQuant] := 1.00	
				EndIf					
			EndIf

			aCols[nItem][nPosVlItem] := aCols[nItem][nPosQuant] *  aCols[nItem][nPosVlUnit]
	    	//�����������������������Ŀ
			//�Percentual do desconto �
			//�������������������������	
			aCols[nItem][nPosDesc] := nDescPer 
			//��������������������������������Ŀ
			//�Valor do Desconto a ser aplicado�
			//����������������������������������	
			nVlrDesc := Round( aCols[nItem][nPosDesc] * aCols[nItem][nPosVlItem] / 100, nDecimais )
			aCols[nItem][nPosValDesc] := nVlrDesc	

			//����������������������Ŀ
			//�Valor total do produto�
			//������������������������
			If nModulo == SIGALOJA
				aCols[nItem][nPosVlUnit] := A410ARRED(nVlrUnit - (nVlrUnit * aCols[nItem][nPosDesc] / 100), "L2_VRUNIT")
			EndIf                  
			aCols[nItem][nPosVlItem] -= nVlrDesc

			If nModulo == SIGALOJA
				//�����������������Ŀ
				//�Atualiza a Rodape�
				//�������������������
				For nCont := 1 to Len(aCols)
					If !aCols[nCont][Len(aHeader)+1]//verifica se a linha esta deletada
						nVlr += aCols[nCont][nPosVlItem]//somatoria dos valores do produtos jah com o Desconto aplicado
					Endif
				Next nCont
				//���������������������������������������������������������Ŀ
				//�Funcoes que atualizam o rodape na tela da Venda Assistida�
				//�����������������������������������������������������������
				Lj7T_SubTotal( 2, nVlr)
				Lj7T_Total( 2, Lj7T_SubTotal(2) - Lj7T_DescV(2) )
				IF nDescPer > 0
					MaFisAlt("IT_DESCONTO"	, aCols[nItem][nPosValDesc], nItem)
					MaFisAlt("IT_PRCUNI"	, aCols[nItem][nPosVlUnit], nItem)
				EndIf
				IF lVAssConc
					LJ7ImpItCC( nItem )
				EndIf
			Endif
			
	Case (AllTrim(ReadVar()) == "M->LR_QUANT")
			//���������������������������������������������������������Ŀ
			//�Funcoes que atualizam o rodape na tela da Venda Assistida�
			//�����������������������������������������������������������
			If nModulo == SIGALOJA
				If Lj7VlItem(1)      
					aCols[nItem][nPosVlUnit] := nVlrUnit - (nVlrUnit * aCols[nItem][nPosDesc] / 100) // Atualizo o Valor do Preco unitario
					//�����������������Ŀ
					//�Atualiza a Rodape�
					//�������������������
					For nCont := 1 to Len(aCols)
						If !aCols[nCont][Len(aHeader)+1]//verifica se a linha esta deletada
							nVlr += aCols[nCont][nPosVlItem]//somatoria dos valores do produtos jah com o Desconto aplicado
						Endif
					Next nCont
					//���������������������������������������������������������Ŀ
					//�Funcoes que atualizam o rodape na tela da Venda Assistida�
					//�����������������������������������������������������������
					Lj7T_SubTotal( 2, nVlr)
					Lj7T_Total( 2, Lj7T_SubTotal(2) - Lj7T_DescV(2) )
					//����������������������������������������Ŀ
					//�Verificacao para medicamento controlado.�
					//������������������������������������������
					If T_DroVerCont(M->LR_PRODUTO)
						//����������������������������������������������������������������Ŀ
						//�Atualiza a quantidade digitada apos informar o codigo do produto�
						//������������������������������������������������������������������
						T_DroLK9Quant(nItem, M->LR_QUANT)
					Endif
							
				Endif
			ElseIf nModulo == FRONTLOJA		
		    	//���������������������������Ŀ
				//�Quantidade e Valor do Item �
				//�����������������������������
				aCols[nItem][nPosQuant] := M->LR_QUANT
					// Definindo Valor para Qtde * Item
				aCols[n][nPosVlItem]    := aCols[nItem][nPosQuant] *  aCols[n][nPosVlUnit]
		    	//�����������������������Ŀ
				//�Percentual do desconto �
				//�������������������������	
				aCols[nItem][nPosDesc]  := nDescPer 
				//��������������������������������Ŀ
				//�Valor do Desconto a ser aplicado�
				//����������������������������������	
				nVlrDesc 	  			     := Round( aCols[nItem][nPosDesc] * aCols[nItem][nPosVlItem] / 100, nDecimais )
				aCols[nItem][nPosValDesc]	 := nVlrDesc	
				//����������������������Ŀ
				//�Valor total do produto�
				//������������������������
				aCols[nItem][nPosVlItem] 	-= nVlrDesc

				//�������������������������������Ŀ
				//�Atualiza a Rodape FRONTLOJA	  �
				//���������������������������������
				T_DrocCalcTot("TDREA011",n)
			EndIf                          
	Case AllTrim(ReadVar()) == "M->LR_DESC" 
	   If nModulo ==SIGALOJA
			If Lj7VlItem(3)      						  // Executa funcao calculo do desconto e recalculo dos impostos
				For nCont := 1 to Len(aCols)
					If !aCols[nCont][Len(aHeader)+1]	  // Verifica se a linha esta deletada
						nVlr += aCols[nCont][nPosVlItem] // Somatoria dos valores do produtos jah com o Desconto aplicado
					Endif
				Next nCont
				//���������������������������������������������������������Ŀ
				//�Funcoes que atualizam o rodape na tela da Venda Assistida�
				//�����������������������������������������������������������
				Lj7T_SubTotal( 2, nVlr)
				Lj7T_Total( 2, Lj7T_SubTotal(2) - Lj7T_DescV(2) )	
		    Endif
		EndIf    
	Case AllTrim(ReadVar()) == "M->LR_VALDESC" 
		//�����������������Ŀ
		//�Atualiza a Rodape�
		//�������������������
		For nCont := 1 to Len(aCols)
			If !aCols[nCont][Len(Aheader)+1]		 	   // Verifica se a linha esta deletada
				nVlr += aCols[nCont][nPosVlItem]    	   // Somatoria dos valores do produtos jah com o Desconto aplicado
			Endif
		Next nCont
		If nModulo == SIGALOJA
			//���������������������������������������������������������Ŀ
			//�Funcoes que atualizam o rodape na tela da Venda Assistida�
			//�����������������������������������������������������������
			Lj7T_SubTotal( 2, nVlr)
			Lj7T_Total( 2, Lj7T_SubTotal(2) - Lj7T_DescV(2) )	
		EndIf
EndCase

//�������������������������������������������������Ŀ
//�Alimento a minha coluna de Plano de Fidelidade   �
//�do meu aCols quando mudo De Plano de Fidelidade. �
//�Isto ocorre somente no FrontLoja.		 		�
//���������������������������������������������������
If nModulo == FRONTLOJA .AND. cOrigem == "DroConsPrc"
	If (nDescPer > 0) .OR. oGetDados1:aCols[nItem][nPosDesc] > 0 

    	//�����������������������Ŀ
		//�Percentual do desconto �
		//�������������������������
		M->LR_DESC := nDescPer
		oGetDados1:aCols[nItem][nPosDesc]   := nDescPer
    	//�����������������������Ŀ
		//�Valor Unitario         �
		//�������������������������		
		oGetDados1:aCols[nItem][nPosVlUnit]  := nVlrUnit
    	//�����������������������Ŀ
		//�Valor do Item          �
		//�������������������������
		oGetDados1:aCols[nItem][nPosVlItem]  := oGetDados1:aCols[nItem][nPosQuant] *  oGetDados1:aCols[nItem][nPosVlUnit]
		//��������������������������������Ŀ
		//�Valor do Desconto a ser aplicado�
		//����������������������������������	
		nVlrDesc := Round(oGetDados1:aCols[nItem][nPosDesc] * oGetDados1:aCols[nItem][nPosVlItem] / 100, nDecimais )
		oGetDados1:aCols[nItem][nPosValDesc] := nVlrDesc	
		//����������������������Ŀ
		//�Valor total do produto�
		//������������������������
		oGetDados1:aCols[nItem][nPosVlItem] -= nVlrDesc		
	EndIf	
EndIf

If nModulo ==SIGALOJA
//�����������������������������������������������������������������������Ŀ
//�So' considera os pontos caso o cliente seja diferente de cliente padrao�
//�������������������������������������������������������������������������
	If M->LQ_CLIENTE+M->LQ_LOJA == SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD")
		aDetProd[nItem][4] := 0
	Else
		aDetProd[nItem][4] := nPtosProd  
	EndIf
	//����������������������������������Ŀ
	//�Acerta o total de pontos para item�
	//������������������������������������
	aDetProd[nItem][5] :=  (aDetProd[nItem][4] * aCols[nItem][nPosVlItem])
	//��������������������������Ŀ
	//�Valoriza o campo de Pontos�
	//����������������������������
EndIf

If nModulo ==SIGALOJA .AND. T_DroSendPCM()
	oGetDados1:aCols := Aclone(aCols)
EndIf
//�������������������������������������Ŀ
//�Restaura area original do arquivo ACP�
//���������������������������������������
If !Empty(aAreaACP)
	RestArea(aAreaACP)
EndIf

//���������������������������������������
//�Restaura area original do arquivo ACO�
//���������������������������������������
If !Empty(aAreaACO)
	RestArea(aAreaACO)
EndIf      

//���������������������������������������
//�Restaura area original do arquivo MHG�
//���������������������������������������
If !Empty(aAreaMHG)
	RestArea(aAreaMHG)
EndIf                                     
If T_DroSendPCM()
	T_DrocCalcTot('Consulta')  
EndIf

If !T_DroSendPCM()  
	oGetVA:oBrowse:Refresh()			
EndIf	

Return

/*���������������������������������������������������������������������������
���Programa  �TDREAISLOJ�Autor  �Fernando F.         � Data �  19/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao �Valida se o fonte em execucao eh - Venda assistida, 		  ���
���          �ou Front Loja                                               ���
�������������������������������������������������������������������������͹��
���Uso       �Template Drogaria - SIGALOJA Venda Assistida                ���
�������������������������������������������������������������������������͹��
���Chamada   �                                                            ���
�������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada                      	  ���
���������������������������������������������������������������������������*/
Template Function TDREAISLOJ( nMod      , nTpOp   , nOpc, lAlter,;
							  nTotPontos, nTpVenda )

Local aAreaAtu  := GetArea()                                      
Local aAreaSA1  := {}
Local aAreaSL2  := {}
Local lRet  	:= .F.    
Local nI 		:= 0
Local nPosProd  := If(Type("aHeader")<>"U",aScan(aHeader,{|x| Trim(x[2]) == "LR_PRODUTO"}),0)	                        
Local lVAssConc	:= LjVassConc()	//verifica se a venda eh concomitante 
Local lAmbOffLn := .F.			//Identifica se o ambiente esta operando em offline
Local lScCsPreco:= .F.			//usado para Integracao Protheus x SIAC. Indica se a consulta de preco via WS esta habilitada

lAmbOffLn 		:= SuperGetMv("MV_LJOFFLN", Nil, .F.)

//usado na integracao Protheus x SIAC. Indica se o Protheus pode consultar o preco de um produto no SIAC Store via WS
lScCsPreco := SuperGetMV("MV_SCINTEG",,.F.) .AND. SuperGetMV("MV_SCCSPRC",,.F.) .AND. ExistFunc("LJSCCSPRC")

Do Case
	Case nTpOp == 1 .AND. nMod ==12 
		lRet := .T.
		If (AllTrim(ReadVar()) == "M->LR_PRODUTO")
			If Empty ( Alltrim(M->LR_PRODUTO) )
				Return(.F.)
			EndIf
			
			If ValType(aDetProd) == "U"
				aDetProd := {}
				AAdd(aDetProd,{n,M->LR_PRODUTO,0,0,0,.F.})
				nPosItem := n
			Else                       
				If Empty(aDetProd)
					AAdd(aDetProd,{n,M->LR_PRODUTO,0,0,0,.F.})
					nPosItem := n
				Else  
					nPosItem := aScan(aDetProd,{|x| x[1] == n})
					If nPosItem == 0                     
						AAdd(aDetProd,{n,M->LR_PRODUTO,0,0,0,.F.})
						nPosItem := n
					ElseIf (nPosItem > 0) .AND. (AllTrim(aDetProd[nPosItem][2]) <> AllTrim(M->LR_PRODUTO))                      
						aDetProd[nPosItem][2] := M->LR_PRODUTO
					EndIf
				EndIf
			EndIf                         
			cCodProd := M->LR_PRODUTO   
			If nPosProd > 0
				aCols[n][nPosProd] := cCodProd
			EndIf	
		Else
			nPosItem := aScan(aDetProd,{|x| x[1] == n})  
			If nPosItem == 0 
				Return(.T.)
			EndIf
		    If nPosProd > 0
				cCodProd := aCols[n][nPosProd]
			EndIf	
	    EndIf
	    
		//----------------------------------------------------------------------------------------------------
		//- Realiza o calculo dos valores da venda e dos pontos do plano de fidelidade	
		//- Se for Integracao Protheus x SIAC nao executamos essa funcao, pois senao o aCols sera recalculado,
		//anulando a funcionalidade Consulta Preco. Alem disso, os Pontos de Fidelidade nao serao usados, pois 
		//sao utilizados com Regra de Desconto e nao eh possivel utilizar Regra de Desconto com a integracao
		//----------------------------------------------------------------------------------------------------
		If !lScCsPreco
			T_TDROAtuAcols( nPosItem , cCodProd, M->LQ_CPLFIDE )
		EndIf

		// Restaura area original
		RestArea(aAreaAtu)
		
	Case nTpOp == 2 .AND. nMod ==12 
			//��������������������������������������������������Ŀ
			//�Caso a linha esteja deletada e a venda seja 		 |
			//�concomitante nao retorna a linha                  |
			//���������������������������������������������������� 
			If atail(acols[n]) .AND. lVAssConc  
				lRet:=.F.
			Else
				lRet:=.T.					
				nPosItem := aScan(aDetProd,{|x| x[1] == n}) // Determina que o item est� sendo marcado ou desmarcado da dele��o
				If nPosItem <> 0
					aDetProd[nPosItem][6] := !aDetProd[nPosItem][6]
				EndIf
			EndIf
	Case nTpOp == 3 .AND. nMod ==12 			
			lRet :=.T.
			If (AllTrim(cPlanFide) <> AllTrim(M->LQ_CPLFIDE)) .AND. (Lj7T_Subtotal(2) > 0)
				cPlanFide := M->LQ_CPLFIDE
				cDescPln  := M->LQ_PLDESC
				lAlter    := .T.
		    EndIf
			If lAlter                         
				For nI := 1 To Len(aCols)
					If !Empty(aCols[nI][nPosProd])
						T_TDROAtuAcols( nI, aCols[nI][nPosProd], cPlanFide )
					EndIf
				Next nI	                     
			EndIf
	
	Case nTpOp == 4 .AND. nMod ==12
			lRet :=.T.		

			If ValType(aDetProd) == "U"
				aDetProd := {}
				SL2->(dbSetOrder(1))
				SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
				While !SL2->(Eof()) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM
					AAdd(aDetProd,{Val(SL2->L2_ITEM),SL2->L2_PRODUTO,SL2->L2_DESC,0,SL2->L2_PONTOS,.F.,SL2->L2_NUM})		
					SL2->(dbSkip())
				End
			EndIf			

			aEval(aDetProd,{|x| nTotPontos += x[5]}) // Totaliza os pontos da venda
			
			DbSelectArea("SL1")
			If  nTotPontos > 0 .AND. ( SL1->L1_CLIENTE+SL1->L1_LOJA <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD") ) .AND. ;
				( ColumnPos("L1_CPLFIDE") > 0 .AND. ColumnPos("L1_PONTOS") > 0 )
		
				RecLock("SL1",.F.) 					  // Atualiza campos referentes ao plano de fidelidade
				L1_CPLFIDE := cPlanFide
				L1_PLDESC  := cDescPln
				L1_PONTOS  := nTotPontos              	
				MsUnLock()

			EndIf
				
			// So realiza a grava��o qdo � VENDA.
			If (nTpVenda == 2) .AND. (SL1->L1_CLIENTE+SL1->L1_LOJA <> SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD"))
				// Atualiza o total de pontos acumulados do cliente
				DbSelectArea("SA1")
				aAreaSA1 := GetArea()
				If SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA <> xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA
					dbSeek(xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA)
				EndIf
				RecLock("SA1",.F.)
				A1_PONTOS += nTotPontos
				MsUnLock()	
				RestArea(aAreaSA1)	                   // Restaura a Area do arquivo SA1    
		
				// Grava o hist�rico da venda
				DbSelectArea("LHG")
				RecLock("LHG",.T.)
				LHG_FILIAL := xFilial("LHG")
				LHG->LHG_CODIGO := SL1->L1_CLIENTE
				LHG->LHG_LOJA   := SL1->L1_LOJA
				LHG->LHG_NOME   := Posicione("SA1",1,xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NOME")
				LHG->LHG_CARTAO := Posicione("MA6",2,xFilial("MA6")+SL1->L1_CLIENTE+SL1->L1_LOJA,"MA6_NUM")
				LHG->LHG_DATA   := SL1->L1_EMISSAO
				LHG->LHG_CUPFIS := SL1->L1_DOC
				LHG->LHG_SERIE  := SL1->L1_SERIE
				LHG->LHG_PONTOS := SL1->L1_PONTOS
				LHG->LHG_TIPMOV := "C"
				LHG->LHG_PDV    := SL1->L1_PDV
				LHG->LHG_DTVALI := dDataBase + SuperGetMv("MV_VALPTOS",,90)  
				LHG->LHG_HORA   := SL1->L1_HORA
		   		LHG->LHG_CODPLN := Posicione("MHG",1,xFilial("MHG")+SL1->L1_CPLFIDE,"MHG_CODIGO")//SL1->L1_CPLFIDE = Cod. Regra
		   		LHG->LHG_DESCPL := Posicione("MHG",1,xFilial("MHG")+LHG_CODPLN,"MHG_NOME") 

				//��������������������������������������������Ŀ
				//�Sinaliza para o processo de subida Off-line �
				//����������������������������������������������		   
				If lAmbOffLn
			   		LHG->LHG_SITUA  := "00"           
			 	EndIf
		   				   		
				MsUnLock()
			EndIf
			// Reinicializa todas as vari�veis est�ticas
			cCodRegGer   := Nil	
			aDetProd     := Nil	
			cPlanFide    := Nil	
			cDescPln	 := Nil
			cCodLjCli    := Nil  
			lPesqDescGer := Nil

			RestArea(aAreaAtu)  // Restaura a Area Original

	Case nTpOp == 5 .AND. nMod ==12
			lRet :=.T.				
			If ValType("cCodLjCli") == "U"
				cCodLjCli := M->LQ_CLIENTE+M->LQ_LOJA
			EndIf
		
			If (AllTrim(cCodLjCli) <> AllTrim(M->LQ_CLIENTE+M->LQ_LOJA)) .AND. (Lj7T_Subtotal(2) > 0)  
				MsgAlert("O Cliente/Loja da venda est� sendo alterado. Ser� aplicado o desconto comum a todos os clientes e produtos, caso o mesmo exista. Para que seja aplicado o desconto espec�fico do plano de fidelidade informe o respectivo c�digo.")
		
				cCodLjCli     := M->LQ_CLIENTE+M->LQ_LOJA	
				M->LQ_CPLFIDE := CriaVar("LQ_CPLFIDE")
				M->LQ_PLDESC  := CriaVar("LQ_PLDESC")
				cPlanFide     := M->LQ_CPLFIDE
				cDescPln	  := M->LQ_PLDESC	
				lAlter        := .T.                 
		    EndIf
			                            
		    If lAlter
				For nI := 1 To Len(aCols)
					If !Empty(aCols[nI][nPosProd])
						T_TDROAtuAcols( nI, aCols[nI][nPosProd] )
					EndIf
				Next nI
			EndIf
	Case nTpOp == 6 .AND. nMod ==12
			lRet :=.T.
			If nOpc == 4
				DbSelectArea("SL2")
				aAreaSL2 := GetArea()
				If ValType(aDetProd) == "U"
					aDetProd := {}

					dbSeek(xFilial("SL2")+SL1->L1_NUM)
					While !Eof() .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM
						AAdd(aDetProd,{Val(SL2->L2_ITEM),SL2->L2_PRODUTO,SL2->L2_DESC,0,SL2->L2_PONTOS,.F.,SL2->L2_NUM})			
						dbSkip()
					End						
				EndIf
				
				DbSelectArea("SL1")
				nTotPontos := SL1->L1_PONTOS
				cPlanFide  := SL1->L1_CPLFIDE
				cCodLjCli  := SL1->L1_CLIENTE+SL1->L1_LOJA		
				
				RestArea(aAreaSL2)	 // Restaura a area original do arquivo SL2
				
				RestArea(aAreaAtu)	 // Restaura a Area Original
			Else               
				// Reinicializa todas as vari�veis est�ticas
				cCodRegGer  := Nil	
				aDetProd    := Nil	
				cPlanFide   := Nil	
				cDescPln	:= Nil
				cCodLjCli   := Nil  
				lPesqDescGer:= Nil 
			EndIf       		
EndCase 

Return lRet