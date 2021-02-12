#DEFINE GPI_GRAUS 9999
 
/*���������������������������������������������������������������������������
���Programa  �DroAxLFA  �Autor  �THIAGO HONORATO     � Data �  NOV/04     ���
�������������������������������������������������������������������������͹��
���Desc.     � Grupo de Compras								              ���
�������������������������������������������������������������������������͹��
���Uso       � TEMPLATE - DROGARIA                                        ���
���������������������������������������������������������������������������*/

Template Function DroAxLFA()
Private bRefresh    := {|| GPI020TOT() }

Private aRotina := MenuDef()

Private aAreaSM0 := SM0->(GetArea())

dbSelectArea("LFA")
LFA->(dbSetOrder(1))

mBrowse( 6,1,22,75,"LFA")

SM0->(RestArea(aAreaSM0))

Return  

/*�����������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 11.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Template Drograria                                         ���
���������������������������������������������������������������������������*/

Static Function MenuDef()
	Local aRotina := {	{"Pesquisar"	,"AxPesqui"	,0	,1	,0	,.F.	}	,;
						{"Visualizar"	,"GPI020TL"	,0	,2	,0	,.T.	}	,;
						{"Incluir"		,"GPI020TL"	,0	,3	,0	,.T.	}	,;
						{"Alterar"		,"GPI020TL"	,0	,4	,0	,.T.	}	,;
						{"Excluir"		,"GPI020TL"	,0	,5	,0	,.T.	}	}
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPIA020TEL �Autor �Carlos A. Gomes Jr. � Data �  01/17/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inclusao / Alteracao / Exclusao.                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GPI020TL(cAlias,nReg,nOpcx)
Local cSeek     := NIL
Local cWhile    := NIL

Private lInclui := (nOpcx == 3)
Private nSaveSx8 := GetSx8Len()

If nOpcx <> 3
	LFA->(DbSetOrder(1))
	cSeek     := "'" + xFilial("LFA") + LFA->LFA_CODCOM + "'"
	cWhile    := "!EOF() .And. LFU_FILIAL + LFU_CODCOM == " + cSeek
EndIf

// DEFINES REFERENTES AOS PARAMETROS QUE SERAO PASSADOS PARA A LOCXGRID
//   1         2       3        4        5       6      7       8    9   10    11     12      13     14     15        16        17      18     19      20     21         22       23      24      25       26       27    28     29
//locxMod(aParHead,aCposCab,aParRod,aCposRod,aParGrid,aCpos,cTitulo,aCordW,lGD,aCGD,aCSbx,nOpcx,cFldOK,cLineOk,cAllOk,__cFunOk,__cFunCanc,cIniLin,aGetsGD,nMax,lDelGetD,__aBotoes,__aTeclas,aObjs,__cDelOk,cOnInit,lEnchBar,lEndWnd,aOrditem)

LocxMod({"LFA"},,,,{"LFU",cWhile,,,,cSeek},,,,,,,nOpcx,,"T_TPLinok()","T_PFAlOk()","GPIUOK(__nOpcx,aRecnos)","TDREA014CANC(__nOpcx)",,,GPI_GRAUS,.T.,,,,,,.T.,.T.)

Return

/*----------------------------------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------------------------------*/
Function GPINIUF(oGetDados,nOpc)
Local nI := 0

If nOpc <> 3
	Return
EndIf
For nI :=  1 to GPI_GRAUS
	oGetDados:AddLine()
Next nI
n := 1
oGetDados:oBrowse:nAt := 1
oGetDados:oBrowse:Refresh()
Return

/*----------------------------------------------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------------------------------------------*/
Function GPIUOK(nOpcx,aRecnos)
Local lRet    := .T.
Local aCpos   := {}
Local nI      := 0
Local lNew    := .T.
Local cTmpLog := Dtos(Date())+Time()
Local nPosCod := AScan(aHeader,{|x| x[2] == "LFU_CODFIL" })

If nOpcx <= 2
	Return lRet
EndIf

/*
���������������������������������������Ŀ
�Inclui Grupo de Compras	    	    �
�����������������������������������������
*/

If nOpcx == 3
		
	Reclock("LFA",.T.)
	aCpos      := GeraCampos("LFA")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	LFA_FILIAL := xFilial("LFA")
	MsUnlock()

	For nI := 1 To Len(aCols)
		If !(aCols[nI][Len(aCols[nI])])
			If RecLock("LFU",.T.)
				LFU->LFU_FILIAL := xFilial("LFU")
				LFU->LFU_CODCOM := LFA->LFA_CODCOM
				AEval(aHeader,{|x,y| If( ColumnPos(x[2])> 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
				MsUnlock()
			EndIf
		EndIf
	Next nI

    If __lSX8
       While (GetSX8Len() > nSaveSx8)
	      ConfirmSX8()
	   End
    EndIf	     	
	                
/*
���������������������������������������Ŀ
�Altera Gupo de Compras 	    	    �
�����������������������������������������
*/
ElseIf nOpcx == 4
	Reclock("LFA",.F.)
	aCpos      := GeraCampos("LFA")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	MsUnlock()

	Do While LFU->(DbSeek(xFilial("LFU")+M->LFA_CODCOM))
		RecLock("LFU",.F.)
		DbDelete()
		MsUnLock()
	EndDo
	
	For nI := 1 To Len(aCols)

		If !aCols[nI][Len(aHeader)+1]
			RecLock("LFU",.T.)
			LFU->LFU_FILIAL := xFilial("LFU")
			LFU->LFU_CODCOM := M->LFA_CODCOM
			AEval(aHeader,{|x,y| If( ColumnPos(x[2]) > 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
			MsUnlock()
		EndIf

	Next nI

	
/*
���������������������������������������Ŀ
�Exclui Grupo de Compras 	    	    �
�����������������������������������������
*/
ElseIf nOpcx == 5
	Reclock("LFA",.F.)
	DbDelete()
	MsUnlock()
	For nI := 1 To Len(aRecnos)
		LFU->(DbGoto(aRecnos[nI]))
		RecLock("LFU",.F.)
		DbDelete()
		MsUnlock()
	Next nI
EndIf

Return lRet

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Funcao� TPLinok      � Por: Andre Melo				      � Data � 16/08/04 ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Template Function TPLinok()
Local lRet := .T.
Local nPosCod  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LFU_CODFIL" })

If Empty(aCols[n,nPosCod]) .and. !aCols[n,Len(aHeader)+1]
	Help("",1,"OBRIGAT")
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PFAlOk    �Autor  �Thiago P.Honorato   � Data �  23/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se existe pelo menos uma  "Filial" 				  ���
���          � no momento de cofirmar alguma alteracao					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function PFAlOk()
Local nDel := Len(aHeader)+1
Local lRet := .T.     

If AScan(aCols,{|x| x[nDel] == .F. }) == 0 
	MsgAlert("Deve existir pelo menos uma Filial para este Grupo de compras ")
	lRet :=  .F.
Endif

Return lRet

/*���������������������������������������������������������������������������
���Programa  �VlAcolsD  �Autor  �Thiago P.Honorato   � Data �  23/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o valor digitado no campo "Cod. Filial" 		  ���
���          � (LFU_CODFIL) ja existe									  ���
���������������������������������������������������������������������������*/
Template Function VlAcols(cCod) //pega o valor que o usu�rio ira digitar no campo(LFU_CODFIL)
Local aAreaSM0 := {}
Local lRet     := .T.
Local nPos     := aScan(aCols,{|x,y| Upper(AllTrim(x[1])) == cCod}) 
Local ctplEmp  := ""

If nPos > 0 .And. nPos <> n // Verifica se o codigo da Filial que esta sendo digitada ja existe no aCols 
	MsgAlert("J� existe um registro relacionado a este c�digo!")
	lRet := .F.
Endif

aAreaSMO := SM0->(GetArea())
ctplEmp  := SM0->M0_CODIGO 
If SM0->(!DbSeek(ctplEmp+cCod)) // verifica se o codigo da filial  existe no alias SM0
	MsgAlert("Filial n�o existe")
	lRet := .F.
Endif

//Restaurando as Areas
If !Empty(aAreaSM0)
	RestArea(aAreaSM0)
EndIf
  
Return lRet 

/*���������������������������������������������������������������������������
���Programa  �TDREA014CA�Autor  �Fernando Machima    � Data �  14/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Controle do semaforo da numeracao sequencial do codigo     ���
���������������������������������������������������������������������������*/
Function TDREA014CANC(nOpcx)

If nOpcx == 3  //Incluir
   If __lSX8
		While (GetSX8Len() > nSaveSx8)   	
			RollbackSX8()
		End
   EndIf        
EndIf

Return .T.