#xcommand DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => ;
    <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GeraCamposºAutor  ³ Carlos A. Gomes Jr.º Data ³  10/23/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria Vetor aCampos                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraCampos(cAlias,lTela)
Local	_cCampoTmp	:= "" 
Local	aCampos		:= {}
Local	lContext	:= .T.

DEFAULT	lTela 		:= .F.

If ValType(lTela) != "L"
	lTela := .F.
EndIf

SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
Do While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If !x3uso(SX3->X3_USADO)
		SX3->(DbSkip())
		Loop
	EndIf
	lContext := SX3->X3_CONTEXT	 != "V"
	_cCampoTmp	:= "M->"+SX3->X3_CAMPO
	aAdd(aCampos,{SX3->X3_CAMPO,Iif(lTela,CriaVar(SX3->X3_CAMPO),&_cCampoTmp),SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1),lContext,X3Titulo()})
	SX3->(DbSkip())
EndDo

Return aCampos