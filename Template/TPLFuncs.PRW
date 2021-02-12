#INCLUDE "TOTVS.CH"
#INCLUDE "TPLFuncs.ch"
#xcommand DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => ;
    <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]
 
#INCLUDE "rwmake.ch"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa  ≥TplCadLX5 ∫ Autor ≥Carlos A. Gomes Jr. ∫ Data ≥  31/03/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Cadastro de Tabelas especificas de Templates. (LX5)        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Templates                                                  ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Template Function TplALX5
 
Private cCadastro := STR0001 //"Cadastro de Tabelas Templates"
Private aRotina   := MenuDef()

Private cDelFunc := ".T."
Private cString := "LX5"

DbSelectArea("LX5")
DbSetOrder(1)
mBrowse( 6,1,22,75,cString)

Return

/*⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunÁ„o    ≥ MenuDef  ≥ Autor ≥ Conrado Q. Gomes      ≥ Data ≥ 11.12.06 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ DefiniÁ„o do aRotina (Menu funcional)                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ MenuDef()                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ TPLFUNCS                                                   ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function MenuDef()
	Local aRotina := {	{STR0002	,"AxPesqui" 	,0	,1	,0	,.F.	}	,;	//"Pesquisar"
						{STR0003	,"T_TelaLx5"	,0	,2	,0	,.T.	}	,;	//"Visualizar"
						{STR0004	,"T_TelaLx5"	,0	,3	,0	,.T.	}	,;	//"Incluir"
                       	{STR0005	,"T_TelaLx5"	,0	,4	,0	,.T.	}	,;	//"Alterar"
                       	{STR0006	,"T_TelaLx5"	,0	,5	,0	,.T.	}	,;	//"Excluir"
                       	{STR0007	,"T_TelaLXB"	,0	,6	,0	,.T.	}	}	//"Campos F3"
Return aRotina

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa  ≥Tela LX5  ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  31/03/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Tela de Cadastro / Consulta / Delecao LX5                  ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Template Function TelaLx5(cArq,nReg,nOpcx)
Local lNewReg    := .T.
Local aOldCols   := {}
Local aOldDel    := {}
Local aTempx     := {}
Local _nX

Private cTabela  := Space(2)
Private cDescri  := Space(55)
Private aHeader  := {}
Private aCols    := {}
Private aC       := {}
Private aR       := {}
Private nLinGetD := 0
Private cTitulo  := ""
Private aCGD     := {44,5,118,315}
Private n        := 1

If nOpcx != 3
	If nReg == 0
		MsgAlert(STR0008) //"Inclua um item primeiro!"
		Return
	Else
		If LX5->LX5_TABELA != "00"
			LX5->(DbSeek(xFilial() + "00" + LX5->LX5_TABELA))
		EndIf
		cTabela := Left(LX5->LX5_CHAVE,2)
		cTitulo := LX5->LX5_DESCRI
	EndIf
EndIf

Aadd(aHeader,{STR0009, "LX5_CHAVE" ,"@!",06,0,"!Empty(M->LX5_CHAVE) .AND. T_VLDLX5(M->LX5_CHAVE)",,"C","LX5","R"}) //"Chave"
Aadd(aHeader,{STR0010, "LX5_DESCRI","@!",55,0,                      ,,"C","LX5","R"}) //"Desc. Port."
Aadd(aHeader,{STR0011, "LX5_DESCSP","@!",55,0,                      ,,"C","LX5","R"}) //"Desc. Esp."
Aadd(aHeader,{STR0012, "LX5_DESCEN","@!",55,0,                      ,,"C","LX5","R"}) //"Desc. Ing."

If nOpcx == 3
	Aadd(aCols,{Space(6),Space(55),Space(55),Space(55),.F.})
Else
	cChave  := LX5->LX5_CHAVE
	cDescri := LX5->LX5_DESCRI
	If LX5->( DbSeek( xFilial() + cTabela ) )
		Do While xFilial("LX5") + cTabela == LX5->LX5_FILIAL + LX5->LX5_TABELA
			Aadd(aCols,{LX5->LX5_CHAVE,LX5->LX5_DESCRI,LX5->LX5_DESCSP,LX5->LX5_DESCEN,.F.})
			LX5->(DbSkip())
		EndDo
	Else
		Aadd(aCols,{Space(6),Space(55),Space(55),Space(55),.F.})
	EndIf
EndIf

If nOpcx == 4
	aOldCols := AClone(aCols)
EndIf

AADD(aC, {"cTabela", {20,05}, STR0013, "@!", " ", "", nOpcx == 3}) //"Tabela "
AADD(aC, {"cDescri", {20,40}, " "      , "@!S30", " ", "", nOpcx == 3})

cLinhaOk := "!Empty(aCols[n,1]) .Or. aCols[n,Len(aHeader)+1]"
cTudoOk  := "AllwaysTrue() .And. T_DelTelaLX5()"

If Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk) .And. nOpcx != 2

	If nOpcx == 5 .And. MsgYesNo(STR0014 + cTitulo ) //"Deseja excluir toda a tabela "
		LXB->(DbSetOrder(2))
		If LXB->(DbSeek(xFilial()+cTabela))
			MsgAlert(STR0015) //"Exclua o relacionamento com campos F3 antes de excluir a tabela"
			Return
		EndIf
		LX5->(DbGoto(nReg))
		RecLock("LX5",.F.)
		DbDelete()
		MsUnLock()
		Do While LX5->(DbSeek(xFilial()+cTabela))
			RecLock("LX5",.F.)
			DbDelete()
			MsUnLock()
		EndDo
	Else
		If nOpcx == 3
			RecLock("LX5",.T.)
			LX5->LX5_FILIAL := xFilial("LX5")
			LX5->LX5_TABELA := "00"
			LX5->LX5_CHAVE  := cTabela
			LX5->LX5_DESCRI := cDescri
			MsUnLock()
		EndIf

		For _nX := 1 To Len(aCols)
			lNewReg := !(LX5->(DbSeek(xFilial()+cTabela+aCols[_nX,1])))
			If aCols[_nX,5] .And. !lNewReg
				RecLock("LX5",.F.)
				DbDelete()
				MsUnLock()
			Elseif !aCols[_nX,5]
				RecLock("LX5",lNewReg)
				LX5->LX5_FILIAL := xFilial("LX5")
				LX5->LX5_TABELA := cTabela
				LX5->LX5_CHAVE  := aCols[_nX,1]
				LX5->LX5_DESCRI := aCols[_nX,2]
				LX5->LX5_DESCSP := aCols[_nX,3]
				LX5->LX5_DESCEN := aCols[_nX,4]
				MsUnLock()
			EndIf
		Next
        
        n := _nX
        		
		If nOpcx == 4
			AEval(aOldCols,{|x,y| aTempx := AClone(x), If( AScan(aCols,{|a| a[1] ==  aTempx[1] })== 0 , AAdd(aOldDel,aClone(aTempx)) , ) })
			If Len(aOldDel) > 0
				For _nX := 1 To Len(aOldDel)
					If LX5->(DbSeek(xFilial()+cTabela+aOldDel[_nX,1]))
						RecLock("LX5",.F.)
						DbDelete()
						MsUnLock()
					EndIf
				Next
				n := _nX
			EndIf
		EndIf
	EndIf			
	DbCommitAll()
Endif

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa  ≥TPLConPad ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao de pesquisa de dados na tabela especial.            ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Template Function TPLConPad(cCampo)

Local oTplCon, oBtn1, oBtn2, oBtn3, oBtn4, oBtn5, oBrw
Local cTabela	:= Space(2)
Local cReturn	:= &(ReadVar())
Local cFind		:= Space(55)
Local cTitulo	:= Space(55)
Local cOrdem	:= "Chave"
Local aColsLXB	:= {}
Local aHeadLXB	:= {}
Local cSeek		:= ""
Local cWhile	:= ""
Local cBline	:= ""
Local aRet		:= {}
Local aCab		:= {}
Local aLin		:= {}
Local aTam		:= {}
Local aCpo		:= {}
Local cFiltro	:= ""
Local cFiltro2	:= Space(60)
Local lBotInc	:= .F.
Local nI		:= 0

Default cCampo := AllTrim( Substr(ReadVar(),4) )

/*
	alimenta LXB e LX5
*/
T_ChkLXBLX5()

LXB->( DbSetOrder(1) )
If !(LXB->(DbSeek(xFilial()+cCampo)))
	MsgAlert(STR0016 + cCampo + STR0017) //"Pesquisa para o campo "###" n„o relacionada no LXB."
	Return cReturn
EndIf

cTabela := LXB->LXB_TABELA
cFiltro := Iif(!Empty(LXB->LXB_FILTRO),".And. (" + LXB->LXB_FILTRO + ")","")
lBotInc := (LXB->LXB_INCLUI == "1")

If LX5->( DbSeek( xFilial() + "00" + cTabela ) )
	cTitulo := LX5->LX5_DESCRI
	If !LX5->( DbSeek( xFilial() + cTabela ) )
		MsgAlert(STR0013 + cTabela + STR0018) //"Tabela "###" n„o possui conte˙do!"
		Return cReturn
	EndIf
Else
	MsgAlert(STR0013 + cTabela + STR0019) //"Tabela "###" n„o cadastrada!"
	Return cReturn
EndIf

cSeek   := '"' + xFilial("LX5") + cTabela + '"'
cWhile  := '!EOF() .And. LX5_FILIAL=="' + xFilial("LX5") + '" .And. LX5_TABELA=="' + cTabela + '"' + cFiltro
aRet    := LocxGrid("LX5",cWhile,,,,cSeek,1,,{"LX5_FILIAL","LX5_TABELA"})
aCpo    := AClone(aRet[1])
aCab    := AClone(aRet[3])
aTam    := AClone(aRet[4])
aLin    := AClone(aRet[5])

For nI:=1 to Len(aCpo)
	If !Empty(aCpo[nI,3])
		cBLine  += IIf(Empty(cBLine),"{",", ") + " Transform(oBrw:aArray[oBrw:nAT][" + alltrim(Str(nI))+ "], '" + aCpo[nI,3] + "')"
	Else
		cBLine  += IIf(Empty(cBLine),"{",", ") + "oBrw:aArray[oBrw:nAT][" + alltrim(Str(nI))+ "]"
	EndIf
Next nI

DEFINE MSDIALOG oTplCon TITLE STR0020+cTitulo FROM 4,3 TO 20,60 //"Consulta Template - "

oBrw := TWBrowse():New( 12, 12, 170, 70,,aCab,aTam,oTPLCon,,,,,,,,,,,,,,.T.)
oBrw:SetArray(aLin)
oBrw:bLine:=&("{ ||" + cBLine + "} }")
oBrw:bLDblClick :={|| cReturn := ConRet(oBrw,aLin), oTplCon:End() }

oBtn1  := SButton():New(10,190, 1, {|| cReturn := ConRet(oBrw,aLin), oTplCon:End() },,)
oBtn2  := SButton():New(23,190, 2, {|| oTplCon:End() },,)
oBtn3  := SButton():New(36,190, 4, {|| LX5->(DbSeek(xFilial()+"00"+cTabela)), T_TelaLx5(,,4) },,lBotInc)
oBtn4  := SButton():New(49,190,15, {|| LX5->(DbSeek(xFilial()+"00"+cTabela)), T_TelaLx5(,,2) },,)
oBtn5  := SButton():New(62,190,17, {|| .T. },,.F.)

oCbox  := TComboBox():New(7,6,,{STR0009,STR0021}, 130, 10, oTplCon) //"Chave"###"DescriÁ„o"
oCbox:bSetGet := {|u| If(PCount()>0,cOrdem:=u,cOrdem) }
oCbox:bChange:={|| Ordena(cOrdem,@oBrw,aLin) }

oSay1  := IW_Say( 92,12,STR0022,,,,,) //"Pesquisa por:"
oSay2  := IW_Say(104,12,STR0023,,,,,) //"Localizar"
oGet1  := IW_Edit(104,48,cFind,"@!",130,10,,,,,,{|x| Iif(PCount()>0,cFind := x,cFind)} )
oGet1:bChange := {|| ConPesq(@oBrw,cFind,aLin,cOrdem) }

ACTIVATE MSDIALOG oTplCon

Return cReturn

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥DelTelaLX5∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Verifica se h· no minimo um acols valido                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Template Function DelTelaLX5()

Local lRet := .T.

If AScan(aCols,{|x| !(x[5]) }) == 0 .And. nOpcx != 5
	MsgAlert(STR0024) //"Para deletar uma tabela inteira entre na opÁ„o EXCLUIR"
	lRet := .F.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Ordena    ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Reordena o vetor                                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Ordena(cOrdem,oBrw,aLin)
If cOrdem == "Chave"
	ASort(aLin,,,{|x,y| x[1] < y[1]})
	ASort(oBrw:aArray,,,{|x,y| x[1] < y[1]})
Else
	ASort(aLin,,,{|x,y| x[2] < y[2]})
	ASort(oBrw:aArray,,,{|x,y| x[2] < y[2]})
EndIf
oBrw:Refresh()
Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ConRet    ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Atualiza o retorno da pesquisa                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function ConRet(oBrw,aLin)

Local cReturn := aLin[oBrw:NAT][1]

Return cReturn

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ConPesq   ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Atualiza o retorno da pesquisa                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ConPesq(oBrw,cFind,aLin,cOrdem)

Local nOrdem := Iif(cOrdem == "Chave",1,2)
Local nNat   := 1

If (nNat := AScan(aLin, {|x| AllTrim(cFind) $ AllTrim(x[nOrdem]) }) ) != 0
	oBrw:NAT := nNat
	oBrw:Refresh()
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TelaLXB   ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Permite a inclusao de pesquisas em campos.                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Template Function TelaLXB

Local aRet       := {}
Local aCampos    := {}
Local cSeek      := ""
Local cWhile     := ""
Local aCampo     := ""

Private aCGD     := {44,5,118,315}
Private aC       := {}
Private aR       := {}
Private aHeader  := {}
Private aCols    := {}
Private cTabela  := Iif(!LX5->(Eof()),Iif(LX5->LX5_TABELA=="00",Left(LX5->LX5_CHAVE,2),LX5->LX5_TABELA),"")
Private cLinhaOk := "!Empty(aCols[n,1]) .Or. aCols[n,Len(aHeader)+1]"
Private cTudoOk  := "AllwaysTrue()"
Private cDescri  := Iif(!Empty(cTabela),Posicione("LX5",1,xFilial("LX5")+"00"+cTabela,"LX5_DESCRI"),"")

cSeek      := '"' + xFilial("LXB") + cTabela + '"'
cWhile     := '!EOF() .And. LXB_FILIAL=="' + xFilial("LXB") + '" .And. LXB_TABELA=="' + cTabela + '"'

If Empty(cTabela)
	MsgAlert(STR0025) //"Cadatre uma tabela Primeiro"
	Return
EndIf

If !(cUserName == STR0026) //"Administrador"
	MsgAlert(STR0027) //"Somente o Administrador pode cadastrar consultas!"
	Return
EndIf

AADD(aC, {"cTabela", {20,05}, STR0013, "@!", " ", "", .F. }) //"Tabela "
AADD(aC, {"cDescri", {20,40}, " "      , "@!S30", " ", "", .F. })

aRet    := LocxGrid("LXB",cWhile,,,,cSeek,2,,{"LXB_FILIAL","LXB_TABELA"})
aHeader := AClone(aRet[1])
aCampos := AClone(aRet[3])
aCols   := AClone(aRet[5])

If Modelo2(STR0028, aC, aR, aCGD, 4, cLinhaOk, cTudoOk) //"Campos de Pesquisa com F3."
	AEval(aCols, {|x,y| aCampo := AClone(x), GravaLXB(cTabela,aCampo) })
	AEval(aRet[5], {|x,y| aCampo := AClone(x) , If(AScan(aCols,{|a| AllTrim(aCampo[1]) == AllTrim(a[1])}) == 0, GravaLXB(cTabela,aCampo,.F.) , ) })
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GravaLXB  ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Grava dados no LXB                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function GravaLXB(cTabela,aVetor,lLXB)

Local lNew := .T.
Default lLXB := .T.

LXB->(DbSetOrder(2))
lNew := !(LXB->(DbSeek(xFilial()+cTabela+aVetor[1])))

If lLXB .And. !aVetor[4]
	If lNew
		SX3->(DbSetorder(2))
		If SX3->(DbSeek(aVetor[1]))
			If Empty(SX3->X3_F3) .Or. MsgYesNo(STR0029 + aVetor[1] + STR0030 + SX3->X3_F3 + "!"+Chr(10)+Chr(13) + ; //"O Campo "###" ja pesquisa a tabela "
			STR0031 + cTabela + "?" ) //"Deseja realmente substituir pela tabela "
				RecLock("SX3",.F.)
				SX3->X3_F3 := "LX5"
				MsUnLock()
			Else
				MsgAlert(STR0032 + SX3->X3_F3 + STR0033) //"VocÍ optou por manter a pesquisa "###". Esse registro n„o ser· gravado."
				Return
			EndIf
		Else
			MsgAlert(STR0034 + aVetor[1] + STR0035) //"Campo "###" n„o existe. Registro n„o cadastrado!"
			Return
		EndIf
	EndIf
	RecLock("LXB",lNew)
	LXB->LXB_FILIAL := xFilial("LXB")
	LXB->LXB_TABELA := cTabela
	LXB->LXB_CAMPO  := aVetor[1]
	LXB->LXB_FILTRO := aVetor[2]
	LXB->LXB_INCLUI := aVetor[3]
	MsUnLock()

ElseIf !lNew

	RecLock("LXB",.F.)
	DbDelete()
	MsUnLock()

	SX3->(DbSetorder(2))
	If SX3->(DbSeek(aVetor[1]))
		RecLock("SX3",.F.)
		SX3->X3_F3 := ""
		MsUnLock()
	EndIf

EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥VLDLX5    ∫Autor  ≥Carlos A. Gomes Jr. ∫ Data ≥  01/04/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Validacao do campo chave                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function VLDLX5(cCampo)

If !(AScan(aCols,{|x| x[1] == cCampo }) == 0)
	MsgAlert(STR0036) //"Chave j· cadastrada"
	Return .F.
EndIf

Return .T.


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ ChkLXBLX5   ≥ Autor ≥ Vendas Clientes      ≥ Data ≥ 02/03/10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Verifica o conteudo da tabel LXB E LX5, caso esteja em branco≥±±
±±≥			 ≥ adiciona o conteudo dessas tabelas      		    			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ 										                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ Drovldfuncs                   							    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/  

Template Function ChkLXBLX5()

Local nI		:= 0   // variavel para controle do for
Local aDados	:= {}
Local aArea		:= GetArea()
Local cLXxFilial:= ""

cLXxFilial := Space(TamSx3("LXB_FILIAL")[1])  // Tamanho da filial da tabela LXB E LX5

/* LXB */
SX2->( DbGoTop() )
If SX2->( DbSeek("LXB") )
    DbSelectArea("LXB")
    LXB->( DbSeek(cLXxFilial, .T.) )
    If LXB->( Eof() )
		For nI := 1 to 7
	       	aDados := RecbDad(nI,1)
	       	Reclock("LXB",.T.)
			REPLACE LXB_FILIAL	WITH aDados[1]
			REPLACE LXB_CAMPO	WITH aDados[2]
			REPLACE LXB_TABELA	WITH aDados[3]
			REPLACE LXB_FILTRO	WITH aDados[4]
			REPLACE LXB_INCLUI	WITH aDados[5]
			LKB->( MsUnLock() )
		Next nI
		LKB->( DbCommit() )
	EndIf
EndIf

/* LX5 */
cLXxFilial := Space( TamSx3("LX5_FILIAL")[1] )
SX2->( DbGoTop() )
If SX2->( DbSeek("LX5") )
	DbSelectArea("LX5")
	LX5->( DbSeek(cLXxFilial, .T.) )
	If LX5->( EoF() )
		aDados := RecbDad(,2)
		For nI := 1 to Len(aDados)			
			Reclock("LX5",.T.)		 	
			REPLACE LX5_FILIAL	WITH aDados[nI][1]
			REPLACE LX5_TABELA	WITH aDados[nI][2]
			REPLACE LX5_CHAVE	WITH aDados[nI][3]
			REPLACE LX5_DESCRI	WITH aDados[nI][4]
			REPLACE LX5_DESCSP	WITH aDados[nI][5]
			REPLACE LX5_DESCEN	WITH aDados[nI][6]
			LX5->( MsUnLock() )
		Next
		LX5->( DbCommit() )		
	EndIf
EndIf

RestArea(aArea)

aSize(aDados,0)
aDados := Nil

Return Nil

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥ RecbDad     ≥ Autor ≥ Vendas Clientes      ≥ Data ≥ 02/03/10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Monta o array com dados para gravacao das tabelas LXB E LX5. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ PARAM01 - Numero do Registro			                        ≥±±
±±≥          ≥ PARAM02 - controla da Tabela			                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso		 ≥ Drovldfuncs                  							    ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function RecbDad(nVal,nTipo)
Local aRet		:= {}	// Valores para serem gravados no LXB

Default nVal	:= 0
Default nTipo	:= 0

If nVal > 0 .AND. nTipo == 1

	Do case 
   		case nVal == 1
        	aRet := {"","LK9_CONPRO","T3","","1" }
   		case nVal == 2
	        aRet := {"","LK9_MTVPER","T6","","1" }
   		case nVal == 3              
		    aRet := {"","LK9_ORGEXP","T5","","1" }
		case nVal == 4                      		
			aRet := {"","LK9_TIPOID","T4","","1" }
		case nVal == 5              
			aRet := {"","LK9_TIPREC","T1","","1" }	
		case nVal == 6              
			aRet := {"","LK9_TIPUSO","T2","","1" }
	   	case nVal == 7                     
			aRet := {"","LKA_CONPRO","T3","","1" }
	EndCase

ElseIf nTipo == 2

	aAdd( aRet, {"", "00", "T1"		,"TIPOS DE RECEITUARIO","","" })
	aAdd( aRet, {"", "T1", "1"		,"RECEITA DE CONTROLE ESPECIAL EM 2 VIAS (RECEITA BRANCA)","RECEITA DE CONTROLE ESPECIAL EM 2 VIAS (RECEITA BRANCA)","RECEITA DE CONTROLE ESPECIAL EM 2 VIAS (RECEITA BRANCA)"})
	aAdd( aRet, {"", "T1", "2"		,"NOTIFICACAO DE RECEITA B (NOTIFICACAO AZUL)","NOTIFICACAO DE RECEITA B (NOTIFICACAO AZUL)","NOTIFICACAO DE RECEITA B (NOTIFICACAO AZUL)" })
	aAdd( aRet, {"", "T1", "3"		,"NOTIFICACAO DE RECEITA ESPECIAL (NOTIFICACAO BRANCA)","NOTIFICACAO DE RECEITA ESPECIAL (NOTIFICACAO BRANCA)","NOTIFICACAO DE RECEITA ESPECIAL (NOTIFICACAO BRANCA)" })
	aAdd( aRet, {"", "T1", "4"		,"NOTIFICACAO DE RECEITA A (NOTIFICACAO AMARELA)","NOTIFICACAO DE RECEITA A (NOTIFICACAO AMARELA)","NOTIFICACAO DE RECEITA A (NOTIFICACAO AMARELA)" })
	aAdd( aRet, {"", "T1", "5"		,"RECEITA ANTIMICROBIANO EM 2 VIAS","RECEITA ANTIMICROBIANO EM 2 VIAS","RECEITA ANTIMICROBIANO EM 2 VIAS" })

	aAdd( aRet, {"", "00", "T2"		,"TIPOS DE USO DE MEDICAMENTOS","","" })
	aAdd( aRet, {"", "T2", "1"		,"HUMANO","HUMANO","HUMANO" })
	aAdd( aRet, {"", "T2", "2"		,"VETERINARIO","VETERINARIO","VETERINARIO" })

	aAdd( aRet, {"", "00", "T3"		,"CONSELHO PROFISSONAL","",""})
	aAdd( aRet, {"", "T3", "COREN"	,"CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM" })
	aAdd( aRet, {"", "T3", "CRM"	,"CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA" })
	aAdd( aRet, {"", "T3", "CRMV"	,"CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA" })
	aAdd( aRet, {"", "T3", "CRO"	,"CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA" })

	aAdd( aRet, {"", "00", "T4"		,"TIPOS DE DOCUMENTO","",""})
	aAdd( aRet, {"", "T4", "1"		,"CARTEIRA DE REGISTRO PROFISSIONAL","CARTEIRA DE REGISTRO PROFISSIONAL","CARTEIRA DE REGISTRO PROFISSIONAL" })
	aAdd( aRet, {"", "T4", "2"		,"CARTEIRA DE IDENTIDADE","CARTEIRA DE IDENTIDADE","CARTEIRA DE IDENTIDADE" })
	aAdd( aRet, {"", "T4", "4"		,"PEDIDO DE AUTORIZACAO DE TRABALHO","PEDIDO DE AUTORIZACAO DE TRABALHO","PEDIDO DE AUTORIZACAO DE TRABALHO" })
	aAdd( aRet, {"", "T4", "5"		,"CERTIDAO DE NASCIMENTO","CERTIDAO DE NASCIMENTO","CERTIDAO DE NASCIMENTO"})
	aAdd( aRet, {"", "T4", "6"		,"CERTIDAO DE CASAMENTO","CERTIDAO DE CASAMENTO","CERTIDAO DE CASAMENTO" })
	aAdd( aRet, {"", "T4", "7"		,"CERTIFICADO DE RESERVISTA","CERTIFICADO DE RESERVISTA","CERTIFICADO DE RESERVISTA" })
	aAdd( aRet, {"", "T4", "8"		,"CARTA PATENTE","CARTA PATENTE","CARTA PATENTE" })
	aAdd( aRet, {"", "T4", "10"		,"CERTIFICADO DE DISPENSA DE INCORPORACAO","CERTIFICADO DE DISPENSA DE INCORPORACAO","CERTIFICADO DE DISPENSA DE INCORPORACAO" })
	aAdd( aRet, {"", "T4", "11"		,"CARTEIRA DE IDENTIDADE DO ESTRANGEIRO","CARTEIRA DE IDENTIDADE DO ESTRANGEIRO","CARTEIRA DE IDENTIDADE DO ESTRANGEIRO"})
	aAdd( aRet, {"", "T4", "19"		,"INSCRICAO ESTADUAL","INSCRICAO ESTADUAL","INSCRICAO ESTADUAL" })
	aAdd( aRet, {"", "T4", "38"		,"AUTORIZACAO DE FUNCIONAMENTO DE EMPRESA","AUTORIZACAO DE FUNCIONAMENTO DE EMPRESA","AUTORIZACAO DE FUNCIONAMENTO DE EMPRESA" })
	aAdd( aRet, {"", "T4", "39"		,"AUTORIZACAO ESPECIAL DE FUNCIONAMENTO","AUTORIZACAO ESPECIAL DE FUNCIONAMENTO","AUTORIZACAO ESPECIAL DE FUNCIONAMENTO" })
	aAdd( aRet, {"", "T4", "40"		,"AUTORIZACAO ESPECIAL SIMPLIFICADA","AUTORIZACAO ESPECIAL SIMPLIFICADA","AUTORIZACAO ESPECIAL SIMPLIFICADA" } )
	aAdd( aRet, {"", "T4", "13"		,"PASSAPORTE","PASSAPORTE","PASSAPORTE" })
	aAdd( aRet, {"", "T4", "14"		,"PROTOCOLO DA POLICIA FEDERAL","PROTOCOLO DA POLICIA FEDERAL","PROTOCOLO DA POLICIA FEDERAL" })
	aAdd( aRet, {"", "T4", "20"		,"INSCRICAO MUNICIPAL","INSCRICAO MUNICIPAL","INSCRICAO MUNICIPAL" })
	aAdd( aRet, {"", "T4", "21"		,"ALVARA / LICENSA SANITARIA MUNICIPAL","ALVARA / LICENSA SANITARIA MUNICIPAL","ALVARA / LICENSA SANITARIA MUNICIPAL"})
	aAdd( aRet, {"", "T4", "22"		,"ALVARA / LICENSA SANITARIA ESTADUAL","ALVARA / LICENSA SANITARIA ESTADUAL","ALVARA / LICENSA SANITARIA ESTADUAL" })
	aAdd( aRet, {"", "T4", "50"		,"CARTEIRA DE TRABALHO E PREVIDENCIA SOLCIAL","CARTEIRA DE TRABALHO E PREVIDENCIA SOLCIAL","CARTEIRA DE TRABALHO E PREVIDENCIA SOLCIAL" })

	aAdd( aRet, {"", "00", "T5"		,"ORGAO EXPEDIDOR","","" })
	aAdd( aRet, {"", "T5", "CRA"	,"CONSELHO REGIONAL DE ADMINISTRACAO","CONSELHO REGIONAL DE ADMINISTRACAO","CONSELHO REGIONAL DE ADMINISTRACAO" })
	aAdd( aRet, {"", "T5", "CRE"	,"CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA" })
	aAdd( aRet, {"", "T5", "CREA"	,"CONSELHO REGIONAL DE ENGENHARIA ARQUITETURA E AGRONOMIA","CONSELHO REGIONAL DE ENGENHARIA ARQUITETURA E AGRONOMIA","CONSELHO REGIONAL DE ENGENHARIA ARQUITETURA E AGRONOMIA" })
	aAdd( aRet, {"", "T5", "CRF"	,"CONSELHO REGIONAL DE FARMACIA","CONSELHO REGIONAL DE FARMACIA","CONSELHO REGIONAL DE FARMACIA" })
	aAdd( aRet, {"", "T5", "DGPC"	,"DIRETORIA GERAL DA POLICIA CIVIL","DIRETORIA GERAL DA POLICIA CIVIL","DIRETORIA GERAL DA POLICIA CIVIL" })
	aAdd( aRet, {"", "T5", "DPF"	,"DEPARTAMENTO DA POLICIA FEDERAL","DEPARTAMENTO DA POLICIA FEDERAL","DEPARTAMENTO DA POLICIA FEDERAL" })
	aAdd( aRet, {"", "T5", "IDAMP"	,"INSTITUTO IDENT. AROLDO MENDES PAIVA","INSTITUTO IDENT. AROLDO MENDES PAIVA","INSTITUTO IDENT. AROLDO MENDES PAIVA" }	)
	aAdd( aRet, {"", "T5", "IFP"	,"INSTITUTO FELIX PACHECO","INSTITUTO FELIX PACHECO","INSTITUTO FELIX PACHECO" })
	aAdd( aRet, {"", "T5", "IN"		,"IMPRENSA NACIONAL","IMPRENSA NACIONAL","IMPRENSA NACIONAL" })
	aAdd( aRet, {"", "T5", "JUNTA"	,"JUNTA","JUNTA","JUNTA" })
	aAdd( aRet, {"", "T5", "MAER"	,"MINISTERIO DA AERONAUTICA","MINISTERIO DA AERONAUTICA","MINISTERIO DA AERONAUTICA" })
	aAdd( aRet, {"", "T5", "MEX"	,"MINISTERIO DO EXERCITO","MINISTERIO DO EXERCITO","MINISTERIO DO EXERCITO"})
	aAdd( aRet, {"", "T5", "MM"		,"MINISTERIO DA MARINHA","MINISTERIO DA MARINHA","MINISTERIO DA MARINHA" })
	aAdd( aRet, {"", "T5", "OAB"	,"ORDEM DOS ADVOGADOS DO BRASIL","ORDEM DOS ADVOGADOS DO BRASIL","ORDEM DOS ADVOGADOS DO BRASIL" }	)
	aAdd( aRet, {"", "T5", "SEJSP"	,"SECRETARIA DE EST. DA JUSTICA E SEG. PUB","SECRETARIA DE EST. DA JUSTICA E SEG. PUB","SECRETARIA DE EST. DA JUSTICA E SEG. PUB" })
	aAdd( aRet, {"", "T5", "SES"	,"SECRETARIA DO ESTADO E DA SEGURANCA","SECRETARIA DO ESTADO E DA SEGURANCA","SECRETARIA DO ESTADO E DA SEGURANCA" })
	aAdd( aRet, {"", "T5", "SESP"	,"SECRETARIA DO ESTADO SEG. PUBLICA","SECRETARIA DO ESTADO SEG. PUBLICA","SECRETARIA DO ESTADO SEG. PUBLICA" })
	aAdd( aRet, {"", "T5", "SJS"	,"SECRETARIA DA JUSTICA E DA SEGURANCA","SECRETARIA DA JUSTICA E DA SEGURANCA","SECRETARIA DA JUSTICA E DA SEGURANCA" })
	aAdd( aRet, {"", "T5", "SJTC"	,"SECRETARIA DA JUSTICA DO TRABALHO E DA CIDADANIA","SECRETARIA DA JUSTICA DO TRABALHO E DA CIDADANIA","SECRETARIA DA JUSTICA DO TRABALHO E DA CIDADANIA" })
	aAdd( aRet, {"", "T5", "SSIPT"	,"SECR. DE SEG. E INFORM. POLICIA TECNICA","SECR. DE SEG. E INFORM. POLICIA TECNICA","SECR. DE SEG. E INFORM. POLICIA TECNICA"})
	aAdd( aRet, {"", "T5", "SSP"	,"SECRETARIA DE SEGURANCA PUBLICA","SECRETARIA DE SEGURANCA PUBLICA","SECRETARIA DE SEGURANCA PUBLICA" })
	aAdd( aRet, {"", "T5", "VACIV"	,"VARA CIVIL","VARA CIVIL","VARA CIVIL" })
	aAdd( aRet, {"", "T5", "VAMEM"	,"VARA DE MENORES","VARA DE MENORES","VARA DE MENORES" })
	aAdd( aRet, {"", "T5", "PM"		,"POLICIA MILITAR","POLICIA MILITAR","POLICIA MILITAR" })
	aAdd( aRet, {"", "T5", "ITB"	,"INSTITUTO TAVARES BURIL","INSTITUTO TAVARES BURIL","INSTITUTO TAVARES BURIL" })
	aAdd( aRet, {"", "T5", "CRM"	,"CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA","CONSELHO REGIONAL DE MEDICINA" })
	aAdd( aRet, {"", "T5", "CBM"	,"CORPO DE BOMBEIRO MILITAR","CORPO DE BOMBEIRO MILITAR","CORPO DE BOMBEIRO MILITAR" })
	aAdd( aRet, {"", "T5", "DIC"	,"DETRAN - DIRETORIA DE IDENTIFICACAO CIVIL","DETRAN - DIRETORIA DE IDENTIFICACAO CIVIL","DETRAN - DIRETORIA DE IDENTIFICACAO CIVIL" }	)
	aAdd( aRet, {"", "T5", "CPF"	,"CONSELHO FEDERAL DE PSICOLOGIA","CONSELHO FEDERAL DE PSICOLOGIA","CONSELHO FEDERAL DE PSICOLOGIA" })
	aAdd( aRet, {"", "T5", "CRO"	,"CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA","CONSELHO REGIONAL DE ODONTOLOGIA" })
	aAdd( aRet, {"", "T5", "COREN"	,"CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM","CONSELHO REGIONAL DE ENFERMAGEM" })
	aAdd( aRet, {"", "T5", "CFN"	,"CONSELHO REGIONAL DE NUTRICIONISTAS","CONSELHO REGIONAL DE NUTRICIONISTAS","CONSELHO REGIONAL DE NUTRICIONISTAS" })
	aAdd( aRet, {"", "T5", "MRE"	,"MINISTERIO DAS RELACOES EXTERIORES","MINISTERIO DAS RELACOES EXTERIORES","MINISTERIO DAS RELACOES EXTERIORES" })
	aAdd( aRet, {"", "T5", "CRCI"	,"CONSELHO REGIONAL DE CORRETORES DE IMOVEIS","CONSELHO REGIONAL DE CORRETORES DE IMOVEIS","CONSELHO REGIONAL DE CORRETORES DE IMOVEIS" })
	aAdd( aRet, {"", "T5", "CRB"	,"CONSELHO REGIONAL DE BIOLOGIA","CONSELHO REGIONAL DE BIOLOGIA","CONSELHO REGIONAL DE BIOLOGIA" })
	aAdd( aRet, {"", "T5", "CRN"	,"CONSELHO REGIONAL DE NUTRICAO","CONSELHO REGIONAL DE NUTRICAO","CONSELHO REGIONAL DE NUTRICAO" })
	aAdd( aRet, {"", "T5", "CFE"	,"CONSELHO FEDERAL DE ENFERMAGEM","CONSELHO FEDERAL DE ENFERMAGEM","CONSELHO FEDERAL DE ENFERMAGEM" })
	aAdd( aRet, {"", "T5", "CRC"	,"CONSELHO REGIONAL DE CONTABILIDADE","CONSELHO REGIONAL DE CONTABILIDADE","CONSELHO REGIONAL DE CONTABILIDADE" })
          
	aAdd( aRet, {"", "T5", "CRP"	,"CONSELHO REGIONAL DE PSICOLOGIA","CONSELHO REGIONAL DE PSICOLOGIA","CONSELHO REGIONAL DE PSICOLOGIA" })
	aAdd( aRet, {"", "T5", "CRQ"	,"CONSELHO REGIONAL DE QUIMICA","CONSELHO REGIONAL DE QUIMICA","CONSELHO REGIONAL DE QUIMICA" })
	aAdd( aRet, {"", "T5", "ANVISA"	,"AGENCIA NACIONAL DE VIGILANCIA SANITARIA","AGENCIA NACIONAL DE VIGILANCIA SANITARIA","AGENCIA NACIONAL DE VIGILANCIA SANITARIA" })
	aAdd( aRet, {"", "T5", "GOVEST"	,"GOVERNO DO ESTADO","GOVERNO DO ESTADO","GOVERNO DO ESTADO" })
	aAdd( aRet, {"", "T5", "PREF"	,"PREFEITURA","PREFEITURA","PREFEITURA" })
	aAdd( aRet, {"", "T5", "CRBM"	,"CONSELHO REGIONAL DE BIOMEDICINA","CONSELHO REGIONAL DE BIOMEDICINA","CONSELHO REGIONAL DE BIOMEDICINA" })
	aAdd( aRet, {"", "T5", "IPF"	,"INSTITUTO PEREIRA FAUSTINO","INSTITUTO PEREIRA FAUSTINO","INSTITUTO PEREIRA FAUSTINO" })
	aAdd( aRet, {"", "T5", "CREFIT"	,"CONSELHO REGIONAL DE FISIOTERAPIA E TERAPIA OCUPACIONAL","CONSELHO REGIONAL DE FISIOTERAPIA E TERAPIA OCUPACIONAL","CONSELHO REGIONAL DE FISIOTERAPIA E TERAPIA OCUPACIONAL" })
	aAdd( aRet, {"", "T5", "CRMV"	,"CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA","CONSELHO REGIONAL DE MEDICINA VETERINARIA" })
	aAdd( aRet, {"", "T5", "MTE"	,"MINISTERIO DO TRABALHO E EMPREGO","MINISTERIO DO TRABALHO E EMPREGO","MINISTERIO DO TRABALHO E EMPREGO" })
	aAdd( aRet, {"", "T5", "CRFA"	,"CONSELHO REGIONAL DE FONOUDIOLOGIA","CONSELHO REGIONAL DE FONOUDIOLOGIA","CONSELHO REGIONAL DE FONOUDIOLOGIA" })
	aAdd( aRet, {"", "T5", "CORENC"	,"CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA","CONSELHO REGIONAL DE ECONOMIA" })

	aAdd( aRet, {"", "00", "T6"		,"MOTIVO DA PERDA","","" })
	aAdd( aRet, {"", "T6", "1"		,"FURTO / ROUBO","FURTO / ROUBO","FURTO / ROUBO" })
	aAdd( aRet, {"", "T6", "2"		,"AVARIA","AVARIA","AVARIA"})
	aAdd( aRet, {"", "T6", "3"		,"VENCIMENTO","VENCIMENTO","VENCIMENTO" })
	aAdd( aRet, {"", "T6", "4"		,"APREENSAO / RECOLHIMENTO PELA VISA","APREENSAO / RECOLHIMENTO PELA VISA","APREENSAO / RECOLHIMENTO PELA VISA"})
	aAdd( aRet, {"", "T6", "5"		,"PERDA NO PROCESSO","PERDA NO PROCESSO","PERDA NO PROCESSO" }	)
	aAdd( aRet, {"", "T6", "6"		,"COLETA PARA CONTROLE DE QUALIDADE","COLETA PARA CONTROLE DE QUALIDADE","COLETA PARA CONTROLE DE QUALIDADE" })
	aAdd( aRet, {"", "T6", "7"		,"PERDA DE EXCLUSAO DA PORTARIA 344","PERDA DE EXCLUSAO DA PORTARIA 344","PERDA DE EXCLUSAO DA PORTARIA 344" })
	aAdd( aRet, {"", "T6", "8"		,"POR DESVIO DE QUALIDADE","POR DESVIO DE QUALIDADE","POR DESVIO DE QUALIDADE"})
	aAdd( aRet, {"", "T6", "9"		,"RECOLHIMENTO DO FABRICANTE","RECOLHIMENTO DO FABRICANTE","RECOLHIMENTO DO FABRICANTE"})
          
	aAdd( aRet, {"", "T7" ,"1"		,"ANTIBACTERIANO","ANTIBACTERIANO","ANTIBACTERIANO"})
	aAdd( aRet, {"", "T7" ,"2"		,"ANESTESICOS","ANESTESICOS","ANESTESICOS" })
	aAdd( aRet, {"", "T7" ,"3"		,"CARDIOVASCULAR","CARDIOVASCULAR","CARDIOVASCULAR"})
	aAdd( aRet, {"", "T7" ,"4"		,"ANTI-HEMORRAGICOS","ANTI-HEMORRAGICOS","ANTI-HEMORRAGICOS"})
	aAdd( aRet, {"", "T7" ,"5"		,"ANTITUSSICOS E EXPECTORANTE","ANTITUSSICOS E EXPECTORANTE","ANTITUSSICOS E EXPECTORANTE"})
	aAdd( aRet, {"", "T7" ,"6"		,"APARELHO DIGESTIVO","APARELHO DIGESTIVO","APARELHO DIGESTIVO"})
	aAdd( aRet, {"", "T7" ,"7"		,"APARELHO GENITURINARIIO","APARELHO GENITURINARIIO","APARELHO GENITURINARIIO"})
	aAdd( aRet, {"", "T7" ,"8"		,"DOENCAS ENDOCRINAS","DOENCAS ENDOCRINAS","DOENCAS ENDOCRINAS"})
	aAdd( aRet, {"", "T7" ,"9"		,"APARELHO LOCOMOTOR","APARELHO LOCOMOTOR","APARELHO LOCOMOTOR"})
	aAdd( aRet, {"", "T7" ,"10"		,"MEDICAO ANTIALERGICA","MEDICAO ANTIALERGICA","MEDICAO ANTIALERGICA"})
	aAdd( aRet, {"", "T7" ,"11"		,"NUTRICAO","NUTRICAO","NUTRICAO"})
	aAdd( aRet, {"", "T7" ,"12"		,"HIDROELECTROLITICAS E EQUILIBRIO ACID-BASE","HIDROELECTROLITICAS E EQUILIBRIO ACID-BASE","HIDROELECTROLITICAS E EQUILIBRIO ACID-BASE"})
	aAdd( aRet, {"", "T7" ,"13"		,"AFECCOES CUTANEAS","AFECCOES CUTANEAS","AFECCOES CUTANEAS"})
	aAdd( aRet, {"", "T7" ,"14"		,"AFECCOES OTORRINOLARINGOLOGAS","AFECCOES OTORRINOLARINGOLOGAS","AFECCOES OTORRINOLARINGOLOGAS"})
	aAdd( aRet, {"", "T7" ,"15"		,"OFTAMOLOGIA","OFTAMOLOGIA","OFTAMOLOGIA"})
	aAdd( aRet, {"", "T7" ,"16"		,"MEDICAMENTOS ANTINEOPLASICOS E IMUNOMODULADORES","MEDICAMENTOS ANTINEOPLASICOS E IMUNOMODULADORES","MEDICAMENTOS ANTINEOPLASICOS E IMUNOMODULADORES"})
	aAdd( aRet, {"", "T7" ,"17"		,"MEDICAMENTOS USADOS NO TRATAMENTO DAS INTOXICACOES","MEDICAMENTOS USADOS NO TRATAMENTO DAS INTOXICACOES","MEDICAMENTOS USADOS NO TRATAMENTO DAS INTOXICACOES"})
	aAdd( aRet, {"", "T7" ,"18"		,"VACINAS E IMUNOGLOBULINAS","VACINAS E IMUNOGLOBULINAS","VACINAS E IMUNOGLOBULINAS"})
	aAdd( aRet, {"", "T7" ,"19"		,"MEIOS DE DIAGNOSTICO","MEIOS DE DIAGNOSTICO","MEIOS DE DIAGNOSTICO"})
	aAdd( aRet, {"", "T7" ,"20"		,"OUTROS PRODUTOS","OUTROS PRODUTOS","OUTROS PRODUTOS"})

	aAdd( aRet, {"", "T8" ,"A1"		,"LISTA DAS SUBST¬NCIAS ENTORPECENTES","LISTA DAS SUBST¬NCIAS ENTORPECENTES","LISTA DAS SUBST¬NCIAS ENTORPECENTES"})
	aAdd( aRet, {"", "T8" ,"A2"		,"LISTA DAS SUBST¬NCIAS ENTORPECENTES","LISTA DAS SUBST¬NCIAS ENTORPECENTES","LISTA DAS SUBST¬NCIAS ENTORPECENTES"})
	aAdd( aRet, {"", "T8" ,"A3"		,"LISTA DAS SUBST¬NCIAS PSICOTR”PICAS","LISTA DAS SUBST¬NCIAS PSICOTR”PICAS","LISTA DAS SUBST¬NCIAS PSICOTR”PICAS"})
	aAdd( aRet, {"", "T8" ,"B1"		,"LISTA DAS SUBST¬NCIAS PSICOTR”PICAS","LISTA DAS SUBST¬NCIAS PSICOTR”PICAS","LISTA DAS SUBST¬NCIAS PSICOTR”PICAS"})
	aAdd( aRet, {"", "T8" ,"B2"		,"LISTA DAS SUBST¬NCIAS PSICOTR”PICAS ANOREXÕGENAS","LISTA DAS SUBST¬NCIAS PSICOTR”PICAS ANOREXÕGENAS","LISTA DAS SUBST¬NCIAS PSICOTR”PICAS ANOREXÕGENAS"})
	aAdd( aRet, {"", "T8" ,"C1"		,"LISTA DAS OUTRAS SUBST¬NCIAS SUJEITAS A CONTROLE ESPECIAL","LISTA DAS OUTRAS SUBST¬NCIAS SUJEITAS A CONTROLE ESPECIAL","LISTA DAS OUTRAS SUBST¬NCIAS SUJEITAS A CONTROLE ESPECIAL"})
	aAdd( aRet, {"", "T8" ,"C2"		,"LISTA DE SUBST¬NCIAS RETIN”ICAS","LISTA DE SUBST¬NCIAS RETIN”ICAS","LISTA DE SUBST¬NCIAS RETIN”ICAS"})
	aAdd( aRet, {"", "T8" ,"C3"		,"LISTA DE SUBST¬NCIAS IMUNOSSUPRESSORAS","LISTA DE SUBST¬NCIAS IMUNOSSUPRESSORAS","LISTA DE SUBST¬NCIAS IMUNOSSUPRESSORAS"})
	aAdd( aRet, {"", "T8" ,"C4"		,"LISTA DAS SUBST¬NCIAS ANTI-RETROVIRAIS","LISTA DAS SUBST¬NCIAS ANTI-RETROVIRAIS","LISTA DAS SUBST¬NCIAS ANTI-RETROVIRAIS"})
	aAdd( aRet, {"", "T8" ,"C5"		,"LISTA DAS SUBST¬NCIAS ANABOLIZANTES","LISTA DAS SUBST¬NCIAS ANABOLIZANTES","LISTA DAS SUBST¬NCIAS ANABOLIZANTES"})

EndIf

Return aRet