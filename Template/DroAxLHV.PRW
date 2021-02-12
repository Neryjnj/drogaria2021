#DEFINE GPI_GRAUS 9999
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DroAxLHV  º Autor ³ Geronimo B Alves   º Data ³  28/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grupo de Fornecedores a processarem pela rotina automatica º±±
±±º          ³ o EDI do retorno do P.C.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogarias                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 11.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template Drogaria                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()
Local aRotina := {	{"Pesquisar"	,"AxPesqui"	,0	,1	,0	,.F.}	,;
						{"Visualizar"	,"GPI020G"	,0	,2	,0	,.T.}	,;
						{"Incluir"		,"GPI020G"	,0	,3	,0	,.T.}	,;
						{"Alterar"		,"GPI020G"	,0	,4	,0	,.T.}	,;
						{"Excluir"		,"GPI020G"	,0	,5	,0	,.T.}	}
Return aRotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GPI020G    ºAutor ³Geronimo B. Alves   º Data ³  28/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao / Alteracao / Exclusao.                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Inclui Plano de Fidelidade	    	    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Altera Plano de Fidelidade	    	    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Exclui Plano de Fidelidade	    	    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ LhvLinok     ³ Por: Geronimo B. Alves              ³ Data ³ 28/05/05 ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LhvAllOk  ºAutor  ³Geronimo B. Alves   º Data ³  28/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe pelo menos um  fornecedor no grupo      º±±
±±º          ³ no momento de confirmar alguma alteracao					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function LhvAllOk()
LOCAL nDel := Len(aHeader)+1

IF AScan(aCols,{|x| x[nDel] == .F. }) == 0
	//Help("",1,"OBRIGAT")
	MsgAlert("Deve existir pelo menos um Fornecedor cadastrado neste grupo")
	Return .F.
ENDIF

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LhvVldAcols ºAutor  ³Geronimo B. Alves   º Data ³  28/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o valor digitado no campo Cod. Fornecedor        º±±
±±º          ³ (LJG_FORNEC) ja existe									    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function LhvVldAcols(cCod,cLoja) //pega o valor que o usuário ira digitar no campo(LJG_FORNEC)
Local lRet	:= .T. 
Local _nI	:= 0 
Local nPos	:= 0

For _nI := 1 to len(acols)
	if !aCols[ n ,Len(aHeader)+1]  // Se a Linha esta deletada ela não é validada
		if !aCols[_nI,Len(aHeader)+1]
			if AllTrim(Upper(aCols[_nI,1])) == Alltrim(Upper(cCod)) .and. AllTrim(Upper(aCols[_nI,2])) == Alltrim(Upper(cLoja)) .and. n <> _nI
				nPos := _nI
				Exit
			endif
		Endif
	Endif
Next

IF nPos > 0
	MsgAlert("Já existe um registro relacionado a este código e loja de Fornecedor na linha " + alltrim(str(_nI)) + " .")
	lRet := .F.
ENDIF

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LhvCanc   ºAutor  ³Geronimo B. Alves   º Data ³  28/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna SX8 (se necessario) no cancelamento da manutencao  º±±
±±º          ³				                           					  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LhvCanc(nOpcx)

If nOpcx == 3  //Incluir
	If __lSX8
		While (GetSX8Len() > nSaveSx8)
			RollbackSX8()
		End
	EndIf
EndIf

Return .T.