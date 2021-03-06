#DEFINE GPI_GRAUS 9999
 
/*���������������������������������������������������������������������������
���Programa  �DroAxLHV  � Autor � Geronimo B Alves   � Data �  28/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Grupo de Fornecedores a processarem pela rotina automatica ���
���          � o EDI do retorno do P.C.                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogarias                                         ���
���������������������������������������������������������������������������*/

Template Function DroAxLHV()

Private bRefresh    := {|| GPI020TOT() }
Private __lSX8		:= .f.
Private aRotina := MenuDef()

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

dbSelectArea("LHV")
dbSetOrder(1)

mBrowse( 6,1,22,75,"LHV")

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
��� Uso      � Template Drogaria                                          ���
���������������������������������������������������������������������������*/

Static Function MenuDef()
Local aRotina := {	{"Pesquisar"	,"AxPesqui"	,0	,1	,0	,.F.}	,;
						{"Visualizar"	,"GPI020G"	,0	,2	,0	,.T.}	,;
						{"Incluir"		,"GPI020G"	,0	,3	,0	,.T.}	,;
						{"Alterar"		,"GPI020G"	,0	,4	,0	,.T.}	,;
						{"Excluir"		,"GPI020G"	,0	,5	,0	,.T.}	}
Return aRotina

/*���������������������������������������������������������������������������
���Programa  �GPI020G    �Autor �Geronimo B. Alves   � Data �  28/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inclusao / Alteracao / Exclusao.                           ���
���������������������������������������������������������������������������*/

Function GPI020G(cAlias,nReg,nOpcx)
Local cSeek     := NIL
Local cWhile    := NIL

Private lInclui := (nOpcx == 3)
Private Inclui := (nOpcx == 3)
Private nSaveSx8 := GetSx8Len()

If nOpcx != 3
	LHV->(DbSetOrder(1))
	cSeek     := "'" + xFilial("LHV") + LHV->LHV_CODGRP + "'"
	cWhile    := "!EOF() .And. LJG->LJG_FILIAL + LJG->LJG_CODGRP == " + cSeek
EndIf

// DEFINES REFERENTES AOS PARAMETROS QUE SERAO PASSADOS PARA A LOCXGRID
//   1         2       3        4        5       6      7       8    9   10    11     12      13     14     15        16        17      18     19      20     21         22       23      24      25       26       27    28     29
//locxMod(aParHead,aCposCab,aParRod,aCposRod,aParGrid,aCpos,cTitulo,aCordW,lGD,aCGD,aCSbx,nOpcx,cFldOK,cLineOk,cAllOk,__cFunOk,__cFunCanc,cIniLin,aGetsGD,nMax,lDelGetD,__aBotoes,__aTeclas,aObjs,__cDelOk,cOnInit,lEnchBar,lEndWnd,aOrditem)

LocxMod({"LHV"},,,,{"LJG",cWhile,,,,cSeek},,,,,,,nOpcx,,"T_LhvLinok()","T_LhvAllOk()","LhvFimOk(__nOpcx,aRecnos)","LhvCanc(__nOpcx)",,,GPI_GRAUS,.T.,,,,,,.T.,.T.)

Return

/******************************************************************************************************/
/******************************************************************************************************/
Function LhvFimOk(nOpcx,aRecnos)
Local lRet    := .T.
Local aCpos   := {}
Local nI      := 0
Local lNew    := .T.
Local cTmpLog := Dtos(Date())+Time()
Local nPosCod := AScan(aHeader,{|x| x[2] == "LJG_CODGRP" })

If nOpcx <= 2
	Return lRet
EndIf

/*
���������������������������������������Ŀ
�Inclui Plano de Fidelidade	    	    �
�����������������������������������������
*/
If nOpcx == 3
	Reclock("LHV",.T.)
	aCpos      := GeraCampos("LHV")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	LHV_FILIAL := xFilial("LHV")
	MsUnlock()
	
	For nI := 1 To Len(aCols)
		If !(aCols[nI][Len(aCols[nI])])
			If RecLock("LJG",.T.)
				LJG->LJG_FILIAL := xFilial("LJG")
				LJG->LJG_CODGRP := LHV->LHV_CODGRP
				AEval(aHeader,{|x,y| If( ColumnPos(x[2])> 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
				MsUnlock()
			EndIf
		EndIf
	Next nI
	
	Return
	
	/*
	���������������������������������������Ŀ
	�Altera Plano de Fidelidade	    	    �
	�����������������������������������������
	*/
ElseIf nOpcx == 4
	Reclock("LHV",.F.)
	aCpos      := GeraCampos("LHV")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	MsUnlock()
	
	Do While LJG->(DbSeek(xFilial("LJG")+M->LHV_CODGRPO))
		RecLock("LJG",.F.)
		LJG-> ( DbDelete() )
		MsUnLock()
	EndDo
	
	For nI := 1 To Len(aCols)
		
		If !aCols[nI][Len(aHeader)+1]
			RecLock("LJG",.T.)
			LJG->LJG_FILIAL := xFilial("LJG")
			LJG->LJG_CODGRP := M->LHV_CODGRP
			AEval(aHeader,{|x,y| If( ColumnPos(x[2]) > 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
			MsUnlock()
		EndIf
		
	Next nI
	/*
	���������������������������������������Ŀ
	�Exclui Plano de Fidelidade	    	    �
	�����������������������������������������
	*/
ElseIf nOpcx == 5
	Reclock("LHV",.F.)
	DbDelete()
	MsUnlock()
	For nI := 1 To Len(aRecnos)
		LJG->(DbGoto(aRecnos[nI]))
		RecLock("LJG",.F.)
		DbDelete()
		MsUnlock()
	Next nI
EndIf

Return lRet

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Funcao� LhvLinok     � Por: Geronimo B. Alves              � Data � 28/05/05 ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/

Template Function LhvLinok()
Local lRet := .T.
Local nPosFornec	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LJG_FORNEC" })
Local nPosLoja		:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LJG_LOJA" })
Local nPosNomFor	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LJG_NOMFOR" })

If ( Empty(aCols[n,nPosFornec]) .or. Empty(aCols[n,nPosLoja]) ) .and. !aCols[n,Len(aHeader)+1]
	Help("",1,"OBRIGAT")
	lRet := .F.
EndIf

If lRet
	lRet := T_LhvVldAcols(aCols[n,nPosFornec], aCols[n,nPosLoja] ) //Valida se Fornecedor ja foi incluido em outra linha
Endif

if lRet
	aCols[n,nPosLoja]	:= Posicione("SA2",1,xFilial("SA2")+aCols[n,nPosFornec] + aCols[n,nPosLoja] ,"A2_LOJA")
	aCols[n,nPosNomFor]	:= Posicione("SA2",1,xFilial("SA2")+aCols[n,nPosFornec] + aCols[n,nPosLoja] ,"A2_NOME")
endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LhvAllOk  �Autor  �Geronimo B. Alves   � Data �  28/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se existe pelo menos um  fornecedor no grupo      ���
���          � no momento de confirmar alguma alteracao					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function LhvAllOk()
LOCAL nDel := Len(aHeader)+1

IF AScan(aCols,{|x| x[nDel] == .F. }) == 0
	//Help("",1,"OBRIGAT")
	MsgAlert("Deve existir pelo menos um Fornecedor cadastrado neste grupo")
	Return .F.
ENDIF

Return .T.

/*�����������������������������������������������������������������������������
���Programa  �LhvVldAcols �Autor  �Geronimo B. Alves   � Data �  28/05/05   ���
���������������������������������������������������������������������������͹��
���Desc.     � Verifica se o valor digitado no campo Cod. Fornecedor        ���
���          � (LJG_FORNEC) ja existe									    ���
�����������������������������������������������������������������������������*/
Template Function LhvVldAcols(cCod,cLoja) //pega o valor que o usu�rio ira digitar no campo(LJG_FORNEC)
Local lRet	:= .T. 
Local _nI	:= 0 
Local nPos	:= 0

For _nI := 1 to len(acols)
	if !aCols[ n ,Len(aHeader)+1]  // Se a Linha esta deletada ela n�o � validada
		if !aCols[_nI,Len(aHeader)+1]
			if AllTrim(Upper(aCols[_nI,1])) == Alltrim(Upper(cCod)) .and. AllTrim(Upper(aCols[_nI,2])) == Alltrim(Upper(cLoja)) .and. n <> _nI
				nPos := _nI
				Exit
			endif
		Endif
	Endif
Next

IF nPos > 0
	MsgAlert("J� existe um registro relacionado a este c�digo e loja de Fornecedor na linha " + alltrim(str(_nI)) + " .")
	lRet := .F.
ENDIF

Return lRet

/*���������������������������������������������������������������������������
���Programa  �LhvCanc   �Autor  �Geronimo B. Alves   � Data �  28/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna SX8 (se necessario) no cancelamento da manutencao  ���
���          �				                           					  ���
���������������������������������������������������������������������������*/
Function LhvCanc(nOpcx)

If nOpcx == 3  //Incluir
	If __lSX8
		While (GetSX8Len() > nSaveSx8)
			RollbackSX8()
		End
	EndIf
EndIf

Return .T.