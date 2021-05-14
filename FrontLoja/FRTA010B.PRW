#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FRTA010B.CH"
Static __lFirst := .T.
Static aItems	:= {}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FRTGeraSL ³ Autor ³ Cesar Eduardo Valadao ³ Data ³07/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a gravacao dos campos dos arquivos.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTGeraSL(cAlias, aArray, lAppend, lUnLock)
Local cOldAlias	:=Alias()
Local lRet		:=.T.
Local nPosCpo	:= 0
Local nX		:= 0

Default lAppend := .F.
Default lUnLock := .T.

DbSelectArea(cAlias)
If !lAppend .And. !lUnLock
	lRet := MsRLock()
Else
	lRet := RecLock(cAlias, lAppend)
EndIf
If lRet
	For nX := 1 to Len(aArray)
		nPosCpo := ColumnPos(aArray[nX][1])
		
		If nPosCpo > 0
			FieldPut(nPosCpo,aArray[nX][2])
		EndIf
	Next nX
Else
	ConOut("Impossible lock on file "+cAlias+" Record:"+AllTrim(Str(Recno()))+".")
EndIf
If lRet .And. lUnLock
	dbCommit()
	MsUnLock()
EndIf
If !Empty(cOldAlias)
	dbSelectArea(cOldAlias)
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTGeraSLI³ Autor ³ Cesar Eduardo Valadao ³ Data ³07/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a gravacao dos campos do SLI.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data   ³ Bops ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.³05/04/07³122711³Alterada a utilização da chamada            ³±±
±±³          ³        ³      ³SubStr(cUsuario,7,15) por cUserName         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTGeraSLI(cEstacao, cTipo, cMsg, cDecisao, lUnLock, _cUsuario, _dData, _cHora)
Local aSLI, lRet

DEFAULT cDecisao := "ABANDONA"
DEFAULT lUnLock  := .T.
DEFAULT _cUsuario:= cUserName
DEFAULT _dData   := dDataBase
DEFAULT _cHora   := Time()

lAppend := !SLI->(dbSeek(xFilial("SLI")+PadR(cEstacao,4)+cTipo))

If !lAppend
	If Empty(SLI->LI_MSG)
		lAppend := .F.
	Else
		If cDecisao == "ABANDONA"
			Return(NIL)
		ElseIf cDecisao == "SOBREPOE"
			lAppend := .F.
		ElseIf cDecisao == "NOVO"
			lAppend := .T.
		EndIf
	EndIf
EndIf	
aSLI := {{"LI_FILIAL",	xFilial("SLI")},;
		 {"LI_ESTACAO",	cEstacao},;
		 {"LI_TIPO",	cTipo},;
		 {"LI_USUARIO",	_cUsuario},;
		 {"LI_DATA",	_dData},;
		 {"LI_HORA",	_cHora},;
		 {"LI_MSG",		cMsg}}
lRet := FRTGeraSL("SLI", aSLI, lAppend, lUnLock)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTGeraSLH³ Autor ³ Cesar Eduardo Valadao ³ Data ³15/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a gravacao dos campos do SLH.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data   ³ Bops ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.³05/04/07³122711³Alterada a utilização da chamada            ³±±
±±³          ³        ³      ³SubStr(cUsuario,7,15) por cUserName         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTGeraSLH(cAlias, cSituacao)
Static lUsaSLH, lGravaFi, aFiliais:={}
Local i, aSLH, cChave, cOldAlias:=Alias()
Local nRecnoSM0
Local lOk:=.F.
Local cAux
Local nPosFil	:= 0
Local nPosAlis  := 0
Local nPosChav	:= 0
Local nPosDtAl  := 0
Local nPosHrAl  := 0
Local nTamLHCh	:= TamSx3("LH_CHAVE")[1]

If ValType(lGravaFi) == "U"						// Controla se deve replicar o SLH para todas as filiais
	nRecnoSM0 := SM0->(Recno())
	cAux := FWModeAccess("SBI",3)
	lGravaFi := cAux != FWModeAccess("SB0",3)
	SM0->(DBEval({|| AAdd(aFiliais,FWGETCODFILIAL)}, {|| SM0->M0_CODIGO==cEmpAnt}))
	SM0->(dbGoTo(nRecnoSM0))
EndIf

lUsaSLH := FRTUsaSLH()

If lUsaSLH
	dbSelectArea(cAlias)
	cChave := &(IndexKey(1))
	If cAlias $ "SB1/SB0"
		cAlias := "SB1"										// O alias de todos os registros serah SB1.
		cChave := xFilial("SB0")+Substr(cChave,FWGETTAMFILIAL+1,999)		// A filial de todos os registros serah do SB0.
	EndIf
	aSLH := {{"LH_FILIAL",  xFilial("SLH")},;
			 {"LH_ALIAS",   cAlias},;
			 {"LH_SITUA",   cSituacao},;
			 {"LH_CHAVE",   cChave},;
			 {"LH_DTALT",   dDataBase},;
			 {"LH_HRALT",   Time()},;
			 {"LH_USUARIO", cUserName}}
	If ! (lOk := ChkFile("SLH"))
		// "Aguarde... Atualizando o Log das Modificações!!!" ### "Atenção"
		LJMsgRun(STR0003, STR0002, {|| lOk:=FRTChkFile()})
	EndIf
	
	nPosFil	 := AScan( aSLH, { |x| x[1] == "LH_FILIAL"	} )
	nPosAlis := AScan( aSLH, { |x| x[1] == "LH_ALIAS" 	} )
	nPosChav := AScan( aSLH, { |x| x[1] == "LH_CHAVE" 	} )
	nPosDtAl := AScan( aSLH, { |x| x[1] == "LH_DTALT" 	} )
	nPosHrAl := AScan( aSLH, { |x| x[1] == "LH_HRALT" 	} )

	If lOk
		If lGravaFi
			For i := 1 To Len(aFiliais)
				aSLH[1][2] := aFiliais[i]
				aSLH[4][2] := aFiliais[i]+Substr(aSLH[4][2],3)
				DbSelectArea("SLH")
				DbSetOrder(1)
				If !DbSeek(aSLH[nPosFil][2]+aSLH[nPosAlis][2]+PadR(aSLH[nPosChav][2],nTamLHCh)+DTOS(aSLH[nPosDtAl][2])+aSLH[nPosHrAl][2])
					FRTGeraSL("SLH", aSLH, .T.)
				EndIf
			Next
		Else
			DbSelectArea("SLH")
			DbSetOrder(1)
			If !DbSeek(aSLH[nPosFil][2]+aSLH[nPosAlis][2]+PadR(aSLH[nPosChav][2],nTamLHCh)+DTOS(aSLH[nPosDtAl][2])+aSLH[nPosHrAl][2])
				FRTGeraSL("SLH", aSLH, .T.)
			EndIf	
		EndIf
	Else
		// "O Arquivo de Log das Modificações (SLH) não pode ser atualizado. "
		// "As informações alteradas NÂO estarão disponíveis na próxima Carga nas Estações." ### "Atenção"
		MsgStop(STR0004+STR0005, STR0002)
	EndIf
	dbSelectArea(cOldAlias)
EndIf
Return(NIL)
    
Static Function FRTChkFile
Local i, lOk
For i := 1 To 10
	If (lOk := ChkFile("SLH"))
		Return(.T.)
	EndIf
	Sleep(1000)
Next
Return(lOk)

Static Function FRTUsaSLH
Local nHandle, lRet:=.F., cMV_DIRCFRT
cMV_DIRCFRT := GetMV("MV_DIRCFRT")
nHandle := FCreate(cMV_DIRCFRT+"TEMP.TMP")
If nHandle != -1
	lRet := .T.
	FClose(nHandle)
	FErase(cMV_DIRCFRT+"TEMP.TMP")
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTPegaIT ³ Autor ³ Cesar Eduardo Valadao ³ Data ³07/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transforma o Numero Item Para 2 Bytes.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  DATA  ³ BOPS ³Program.³ MOTIVO DA ALTERACAO                          ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/09/03³S/BOPS³Solange ³Transd. do caracter recebido em maiusculo.    ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³18/07/07³128428³Danilo  ³Tratamento para considerar a condicao do para-³±±
±±³        ³      ³Calil   ³metro MV_SOMAOLD.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTPegaIT(uItem)

Local nX		:= 0					// Contador de For
Local nY		:= 0					// Contador de For
Local aTemp 	:= {}					// Array temporario
Local nTamSd2It	:= TamSX3("D2_ITEM")[1]	//Tamanho do campo D2_ITEM
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o campo for caracter transformar em maiusculo por segurança³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(uItem) == "C"
   uItem := Upper( Right(uItem, nTamSd2It) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Array Somente uma Vez³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aItems) == 0			
	aTemp := {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
	For nX := Asc("A") To Asc("Z")
		AAdd(aTemp, Chr(nX))
	Next
	For nX := 1 To 99
		AAdd(aItems, StrZero(nX,2,0))
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para o MV_SOMAOLD³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMV("MV_SOMAOLD",NIL,.F.)
		For nX := Asc("A") To Asc("Z")
			For nY := 1 To Len(aTemp)
				AAdd(aItems, Chr(nX)+aTemp[nY])
			Next
		Next
    Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quando o MV_SOMAOLD for falso³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := Asc("A") To Asc("Z")
			AAdd(aItems, "9" + chr(nX))
		Next

		For nX := Asc("A") To Asc("Z")
			For nY := 1 To Len(aTemp)
				AAdd(aItems, Chr(nX)+aTemp[nY])
			Next
		Next
    
    EndIf
EndIf
If ValType(uItem) == "N"
	uRet := aItems[uItem]
ElseIf ValType(uItem) == "C"
	uRet := AScan(aItems, uItem)
EndIf

Return(uRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTCancela³ Autor ³ Cesar Eduardo Valadao ³ Data ³14/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o cancelamento do SL, SL2 e SL4                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTCancela(lDeletaSL1, lDeletaSL2, lDeletaSL4)

Local lOk := .T.

Default lDeletaSL1 := .T.
Default lDeletaSL2 := .T.
Default lDeletaSL4 := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Foi adicionado esta trava devido a um problema no cancelamento do cupom	³
//³ quando é enviado o pacote de gravacao.									³
//³ Quando esta sendo incluido uma venda, e assim que o pacote foi enviado,	³
//³ nao tiver dado tempo para a gravacao na retaguarda, o cancelamento		³
//³ nao e feito na retaguarda, causando problemas de sincronizacao de base.	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDeletaSL1 .AND. lDeletaSL2 .AND. lDeletaSL4
	DbSelectArea( "SL1" )

	If !RecLock( "SL1", .F. )
		lOk := .F.
		MsgStop( STR0009 ) //"Não foi possível cancelar o cupom pois está sendo utilizado no momento. Tente novamente."

	EndIf
EndIf

If lOk
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cancela as formas de pagamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDeletaSL4
		dbSelectArea("SL4")
		dbSetOrder(1)
		dbSeek(xFilial()+SL1->L1_NUM)
		While (L4_FILIAL+L4_NUM == xFilial()+SL1->L1_NUM) .And. !EOF()
			RecLock("SL4",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cancelar os Itens ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDeletaSL2
		dbSelectArea("SL2")
		dbSetOrder(1)
		dbSeek(xFilial()+SL1->L1_NUM)
		While (L2_FILIAL+L2_NUM == xFilial()+SL1->L1_NUM) .And. !EOF()
			RecLock("SL2", .F.)
			dbDelete()
			MsUnLock()
			dbSkip()
		End
	EndIf
	If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())) 
		T_DROCancANVISA()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cancelar o Cupom ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDeletaSL1
		//Eh necessario excluir os registros de troco criados no PDV...
		If cPaisLoc <> "BRA" .And. SuperGetMV("MV_LJTRLOC",,.F.)
			dbSelectArea("SE5")
			dbSetOrder(2)
			If dbSeek(xFilial("SE5")+"VL"+SL1->L1_SERIE+SL1->L1_DOC)	    	
				While !Eof() .And. xFilial("SE5")+"VL"+E5_PREFIXO+E5_NUMERO == xFilial("SE5")+"VL"+SL1->L1_SERIE+SL1->L1_DOC
					If Empty(E5_TIPO) .And. E5_MOEDA == "TC" .And. E5_RECPAG == "P" .And.;
					   E5_CLIFOR == SL1->L1_CLIENTE .And. E5_LOJA == SL1->L1_LOJA
					   
						RecLock("SE5",.F.)
						dbDelete()
						MsUnLock()					
					EndIf
				    dbSkip()
				End
			EndIf
		EndIf
		dbSelectArea("SL1")
		RecLock("SL1", .F.)
		dbDelete()
		MsUnLock()
	EndIf
EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTChkModo³ Autor ³ Cesar Eduardo Valadao ³ Data ³17/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a checagem das filiais do SB1 e SBI. Devido ao SBI ³±±
±±³          ³ uma compilacao dos campos necessarios ao FrontLoja, eh     ³±±
±±³          ³ preciso que os dois arquivos tenham a mesma filial.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTChkModo
Local cModoSB1, cModoSBI, cModoSB0, cModoSLH

cModoSB1 := FWModeAccess("SB1",3)
cModoSBI := FWModeAccess("SBI",3)
cModoSB0 := FWModeAccess("SB0",3)
cModoSLH := FWModeAccess("SLH",3)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Modos de abertura compativeis:                     ³
//³ - SB0, SB1, SBI e SLH COMPARTILHADOS,              ³
//³ - SB0, SB1, SBI e SLH EXCLUSIVOS,                  ³
//³ - SB1 e SBI COMPARTILHADOS e SB0 e SLH EXCLUSIVOS. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModoSB1 != cModoSBI
	// "Modo de abertura incompatível" ### "É necessário que as tabelas SB1 e SBI tenham o mesmo modo de abertura."
	Aviso(STR0006, STR0001, {"Ok"})
EndIf
If cModoSB0 != cModoSLH
	// "Modo de abertura incompatível" ### "É necessário que as tabelas SB0 e SLH tenham o mesmo modo de abertura."
	Aviso(STR0006, STR0007, {"Ok"})
EndIf
If cModoSB1=="E" .And. cModoSB0=="C"
	// "Modo de abertura incompatível" ### "Não é possível utilizar o modo de abertura EXCLUSIVO para a tabela SB1/SBI e COMPARTILHADO para a tabela SB0."
	Aviso(STR0006, STR0008, {"Ok"})
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTSemafor³ Autor ³ Cesar Eduardo Valadao ³ Data ³28/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria um Semaforo em Arquivo.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºAnalista  ³ Data   ³ Bops ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMauro Sano³01/08/07|129740³Feita melhoria para matar a thread caso     º±±
±±º          ³        |      ³fique presa ao ocorrer a queda do Server.	  º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTSemaforo(cTipo, cEstacao, nHandle)
Local lMVLjKillT	:= SuperGetMv( "MV_LjKillT", .F., .F. )			// Verifica conteudo do parametro para determinar o tratamento das threads
Local nId			:= ThreadId()									// Id da Thread atual
Local aThreads		:= {}											// Captura dados de todas as Threads
Local nX			:= 0											// Variavel de looping

If __lFirst
	MakeDir("\SEMAFORO\SIGAFRT\")
	__lFirst := .T.
EndIf                                                                                                  
  
If lMVLjKillT
	aThreads		:= GetUserInfoArray()
EndIf

nHandle := MSFCreate("\SEMAFORO\SIGAFRT\"+StrTran(cTipo+cFilAnt+cEstacao," ","")+".L"+StrTran(cEmpAnt," ",""))
PtInternal( 1, cTipo+cFilAnt+AllTrim(cEstacao)+".L"+cEmpAnt ) 

If nHandle < 0
	If lMVLjKillT
		For nX := 1 To Len( aThreads )                                                                     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico pelo nome da thread e pela observacao da thread³
			//³antes de finaliza-la.                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aThreads[nX,3] <> nId .AND. aThreads[nX,11] == cTipo+cFilAnt+AllTrim(cEstacao)+".L"+cEmpAnt
				KillUser( aThreads[nX,1], aThreads[nX,2], aThreads[nX,3] )  
				Sleep( 5000 )
			EndIf    
		Next nX
	Else
		Return(.F.)
	EndIf		
EndIf

FrtGeraSLI( cEstacao, "CON", "|||||", "SOBREPOE" )
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTSemaSta³ Autor ³ Cesar Eduardo Valadao ³ Data ³28/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o Status de um Semaforo em Arquivo.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTSemaStat(cTipo, cEstacao)
Local nHandle
If __lFirst
	MakeDir("\SEMAFORO\SIGAFRT\")
	__lFirst := .F.
EndIf
nHandle := MSFCreate("\SEMAFORO\SIGAFRT\"+StrTran(cTipo+cFilAnt+cEstacao," ","")+".L"+StrTran(cEmpAnt," ",""))
IF nHandle < 0
	Return(.T.)
Endif        
FClose(nHandle)
Return(.F.)
