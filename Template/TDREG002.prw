#INCLUDE "TOTVS.CH"
#include "TDREG002.ch"    //"mata405.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ TDREG002 º Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Atualiza a GetDados do orcamento (SL1/SL2) com base        º±±
±±º          ³ Estrutura do Kit de venda                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObserv.   ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE DROGARIA - DRO                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function TDREG002()

PRIVATE aPos   		:= {35, 3, 105, 315}
Private cCadastro 	:= STR0001 //"Kit de Vendas"
Private aRotina		:= MenuDef()
                      
/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

dbSelectArea("MHD")
MHD->(dbSetOrder(1))
MHD->(dbSeek(xFilial()))
mBrowse( 6, 1,22,75,"MHD")

Return .T.

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 11.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template Drograria                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina := {	{ STR0007	,"AxPesqui"		,0	,1	,0	,.F.	}	,;	//"Pesquisar"
					{ STR0008	,"T_A004Visual"	,0	,2	,0	,.T.	}	,;	//"Visualizar"
					{ STR0009	,"T_A004Inclui"	,0	,3	,0	,.T.	}	,;	//"Incluir"
					{ STR0010	,"T_A004Altera"	,0	,4	,20	,.T.	}	,;	//"Alterar"
					{ STR0011	,"T_A004Deleta"	,0	,5	,21	,.T.	}	}	//"Excluir"
Return aRotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Visualº Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para visualizacao dos Kits de venda               º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function A004Visual(cAlias,nReg,nOpc)
Local nOpcA     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local naCols    := 0
Local oDlg
Local lContinua := .T.

Private aTela[0][0]
Private aGets[0]
Private aHeader := {}
Private aCols   := {}
Private bCampo	:= { |nField| FieldName(nField) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MHD")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader	:= {}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("MHE",.T.)

nUsado := 0
While ( !Eof() .And. SX3->X3_ARQUIVO == "MHE" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		AADD(aHeader,{ AllTrim(X3Titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,;
		SX3->X3_CONTEXT } )
		nUsado++
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:= {}
nAcols:= 0
dbSelectArea("MHE")
MHE->(dbSetOrder(1))
MHE->(dbSeek(xFilial()+MHD->MHD_PRODUT))

While (!MHE->(Eof()) .And. xFilial() == MHE->MHE_FILIAL .And. MHE->MHE_PRODUT == MHD->MHD_PRODUT )
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If (aHeader[nCntFor][10] <> "V")
			aCols[nAcols][nCntFor] := FieldGet(ColumnPos(aHeader[nCntFor][2]))
		Else
			aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	MHE->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0
dbSelectArea("MHD")
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 34,80 OF oMainWnd
	EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3)
	oGet := MSGetDados():New(111,3,182,315,nOpc,"T_A004LinOk","T_A004TudOk","",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=0,oDlg:End()},{||nOpca:=0,oDlg:End()})
DbSelectArea("MHD")

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Altera º Autor ³ ANDRE MELO         º Data ³ 29.03.04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para alteracao dos Kits de venda                  º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Template Function A004Altera(cAlias,nReg,nOpc)
Local nOpcA     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local naCols    := 0
Local oDlg
Local lContinua := .T.
Local aAltera   := {}

Private aTela[0][0]
Private aGets[0]
Private aHeader := {}
Private aCols   := {}
Private bCampo:= { |nField| FieldName(nField) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MHD")
lContinua := SoftLock("MHD")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader	:= {}
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("MHE",.T.))
nUsado := 0
While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "MHE"
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		AADD(aHeader,{ AllTrim(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT } )
		nUsado++
	Endif
	SX3->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAcols	:= 0
aCols	:= {}
dbSelectArea("MHE")
MHE->(dbSetOrder(1))
MHE->(dbSeek(xFilial()+MHD->MHD_PRODUT))

While !MHE->(Eof()) .And. (xFilial() == MHE->MHE_FILIAL) .And. (AllTrim(MHE->MHE_PRODUT) == AllTrim(MHD->MHD_PRODUT))
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] <> "V")
			aCols[nAcols][nCntFor] := FieldGet(ColumnPos(aHeader[nCntFor][2]))
		Else
			aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.

	lContinua := SoftLock("MHE")
	aadd(aAltera,MHE->(Recno()))
	MHE->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0
dbSelectArea("MHD")
If lContinua
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 34,80 OF oMainWnd
		EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3)
		oGet := MSGetDados():New(111,3,182,315,nOpc,"T_A004LinOk","T_A004TudOk","",.T.)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(T_A004Tudok() .And. Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()})
	DbSelectArea("MHD")
	dbGoto(nReg)
	If nOpcA == 1
		Begin Transaction
			If T_A004Grava(2,aAltera)
				EvalTrigger()
				If ( __lSX8 )
					ConfirmSX8()
				EndIf
			EndIf
		End Transaction
	Else
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf
EndIf
MsUnLockAll()
Return .T. 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Incluiº Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para inclusao dos Kits de venda                   º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Template Function A004Inclui(cAlias,nReg,nOpc)
Local nOpcA     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local oDlg
Local lContinua := .T.

Private aTela[0][0]
Private aGets[0]
Private aHeader := {}
Private aCols   := {}
Private bCampo  := { |nField| FieldName(nField) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MHD")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := CriaVar(FieldName(nCntFor),.T.)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("MHE",.T.)

nUsado := 0
While ( !Eof() .And. SX3->X3_ARQUIVO == "MHE" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		AADD(aHeader,{ AllTrim(X3Titulo()),;
    		SX3->X3_CAMPO,;
	    	SX3->X3_PICTURE,;
		    SX3->X3_TAMANHO,;
    		SX3->X3_DECIMAL,;
	    	SX3->X3_VALID,;
    		SX3->X3_USADO,;
	    	SX3->X3_TIPO,;
    		SX3->X3_ARQUIVO,;
	    	SX3->X3_CONTEXT } )
		    nUsado++
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := {}
aadd(aCols,Array(nUsado+1))
dbSelectArea("SX3")
dbSeek("MHE")
nUsado := 0
While ( !Eof() .And. SX3->X3_ARQUIVO == "MHE" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		nUsado++
		aCols[1][nUsado] := CriaVar(allTrim(SX3->X3_CAMPO),.T.)
	Endif
	dbSkip()
End
aCols[1][nUsado+1] := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0
dbSelectArea("MHD")
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 34,80 OF oMainWnd
	EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3)
	oGet := MSGetDados():New(111,3,182,315,nOpc,"T_A004LinOk","T_A004TudOk","",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(T_A004Tudok() .And. Obrigatorio(aGets,aTela),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()})

DbSelectArea("MHD")
MHD->(dbGoto(nReg))
If nOpcA == 1
	Begin Transaction
		If T_A004Grava(1)
			EvalTrigger()
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf
	End Transaction
Else
	If __lSX8
		RollBackSX8()
	EndIf
EndIf
Return nOpca

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Deletaº Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para Exclusao dos Kits de venda                   º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Template Function A004Deleta(cAlias,nReg,nOpc)
Local nOpcA     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local naCols    := 0
Local oDlg
Local lContinua := .T.

Private aTela[0][0]
Private aGets[0]
Private aHeader := {}
Private aCols   := {}
Private bCampo  := { |nField| FieldName(nField) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("MHD")
lContinua := SoftLock("MHD")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("MHE",.T.)
nUsado := 0
While ( !Eof() .And. SX3->X3_ARQUIVO == "MHE" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		AADD(aHeader,{ AllTrim(X3Titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,;
		SX3->X3_CONTEXT } )
		nUsado++
	Endif
	dbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAcols := 0
aCols  := {}
dbSelectArea("MHE")
dbSetOrder(1)
dbSeek(xFilial()+MHD->MHD_PRODUT)
While ( 	!Eof() .And. xFilial() == MHE->MHE_FILIAL .And. ;
	MHE->MHE_PRODUT == MHD->MHD_PRODUT )
	aadd(aCols,Array(nUsado+1))
	nAcols ++
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] <> "V")
			aCols[nAcols][nCntFor] := FieldGet(ColumnPos(aHeader[nCntFor][2]))
		Else
			aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
		EndIf
	Next nCntFor
	aCols[nAcols][nUsado+1] := .F.
	dbSelectArea("MHE")
	lContinua := SoftLock("MHE")
	dbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpcA:=0
dbSelectArea("MHD")
If ( lContinua )
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 34,80 OF oMainWnd
	EnChoice( cAlias, nReg, nOpc, , , , , aPos, , 3)
	oGet := MSGetDados():New(111,3,182,315,nOpc,"T_A004LinOk","T_A004TudOk","",.T.)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})
	DbSelectArea("MHD")
	dbGoto(nReg)
	If ( nOpcA == 1 )
		Begin Transaction
		If ( T_A004Grava(3) )
			EvalTrigger()
			If ( __lSX8 )
				ConfirmSX8()
			EndIf
		EndIf
		End Transaction
	Else
		If ( __lSX8 )
			RollBackSX8()
		EndIf
	EndIf
EndIf
MsUnLockAll()
Return nOpca

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004TudOk º Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Validacao do Getdados                                      º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Template Function A004TudOk()
Local aArea	   := GetArea()
Local lRetorno := .T.
Local nCntFor  := 0
Local nMaxFor  := 0
Local nUsado   := 0
Local nPosProd := aScan(aHeader,{|x| AllTrim(x[2]) == "MHE_CODCOM" })

nMaxFor := Len(aCols)
nUsado  := Len(aHeader)+1
For nCntFor := 1 To nMaxFor
	If ( !aCols[nCntFor][nUsado] )
		
		If ( lRetorno .And. aCols[nCntFor][nPosProd] == M->MHD_PRODUT .And.;
			!Empty(M->MHD_PRODUT) )
			Help(" ",1,"A004COMP01")
			lRetorno := .F.
		EndIf
		
		dbSelectArea("MHD")
		MHD->(dbSetOrder(1))
		MHD->(dbSeek(xFilial()+aCols[nCntFor][nPosProd]))
		If ( lRetorno .And. Found() )
			Help(" ",1,"A004COMP02")
			lRetorno := .F.
		EndIf
	Endif
Next
RestArea(aArea)

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004LinOk º Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para validacao do Getdados                        º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Template Function A004LinOk()
Local lRetorno := .T.

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Grava º Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para gravacao do Getdados                         º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Template Function A004Grava(nOpc,aAltera)
Local aArea		:= GetArea()
Local lGravou   := .F.
Local nCntFor 	:= 0
Local nCntFor2  := 0
Local nUsado    := 0
Local nSeq      := 0
Local nPosField := 0
Local nPosPrd   := 0
Local cTipoOp	:= ""    //Tipo de operacao executada no registro do item de venda,enviada para a tabela de integracao.

Private bCampo  := { |nField| FieldName(nField) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nOpc : 1 - Inclusao de Registros                     ³
//³ nOpc : 2 - Alteracao de Registros                    ³
//³ nOpc : 3 - Exclusao de Registros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado := Len(aHeader) + 1
If ( nOpc == 1 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os Itens da Sugestao de Orcamento              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSort(aCols,,,{|x,y| x[1] < y[2] })
	nSeq := 1
	dbSelectArea("MHE")
	dbSetOrder(1)
	For nCntFor := 1 To Len(aCols)
		nPosField := aScan(aHeader,{|x| Trim(x[2])=="MHE_CODCOM" })
		If ( !aCols[nCntFor][nUsado] .And. !Empty(aCols[nCntFor,nPosField]) )
			RecLock("MHE",.T.)
			For nCntFor2 := 1 To Len(aHeader)
				nPosField := ColumnPos(Trim(aHeader[nCntFor2,2]))
				If nPosField > 0
					FieldPut(nPosField,aCols[nCntFor,nCntFor2])
				EndIf
			Next nCntFor2
			MHE->MHE_FILIAL  	:= xFilial("MHE")
			MHE->MHE_PRODUT 	:= M->MHD_PRODUT
			MHE->MHE_SEQUEN 	:= StrZero(nSeq,2)
			nSeq ++
			
			T_A004RegOK ("027","MHE",M->MHD_PRODUT+MHE->MHE_CODCOM+MHE->MHE_SEQUEN,1,"INSERT")			
			
			lGravou := .T.
		EndIf
	Next nCntFor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o Cabecario da Sugestao de Orcamento           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lGravou )
		dbSelectArea("MHD")
		RecLock("MHD",.T.)
		cTipoOp := "INSERT"
		For nCntFor := 1 To FCount()
			If ("FILIAL" $ FieldName(nCntFor) )
				FieldPut(nCntFor,xFilial())
			Else
				FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
			EndIf
		Next nCntFor
	EndIf
	If ( lGravou )
		T_A004RegOK ("027","MHD",M->MHD_PRODUT,1,cTipoOp) 
	EndIf
	
EndIf
If ( nOpc == 2 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os Itens da Sugestao de Orcamento              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSeq := 1
	nPosPrd := aScan(aHeader,{|x| Trim(x[2])=="MHE_CODCOM" })
	For nCntFor := 1 To Len(aCols)
		dbSelectArea("MHE")
		dbSetOrder(1)
		//dbSeek(xFilial("MHE")+M->MHD_PRODUT+aCols[nCntFor,nPosPrd]+StrZero(nCntFor,2),.F.)
		If ( nCntFor <= Len(aAltera) )
			dbGoto(aAltera[nCntFor])
			RecLock("MHE",.F.)
			cTipoOp := "UPDATE"	 			
			
			If ( aCols[nCntFor][nUsado] .Or. Empty(aCols[nCntFor,nPosPrd]) )
				dbDelete()
				cTipoOp := "DELETE"	 			
			EndIf
		Else
			If ( !aCols[nCntFor][nUsado] .And. !Empty(aCols[nCntFor,nPosPrd]) )
				RecLock("MHE",.T.)
				cTipoOp := "INSERT"			
			EndIf
		EndIf
		If ( !aCols[nCntFor][nUsado] .And. !Empty(aCols[nCntFor,nPosPrd]) )
			For nCntFor2 := 1 To Len(aHeader)
				nPosField := ColumnPos(Trim(aHeader[nCntFor2,2]))
				FieldPut(nPosField,aCols[nCntFor,nCntFor2])
			Next nCntFor2
			MHE->MHE_FILIAL  	:= xFilial("MHE")
			MHE->MHE_PRODUT 	:= M->MHD_PRODUT
			MHE->MHE_SEQUEN 	:= StrZero(nSeq,2)
			nSeq ++
			lGravou := .T.
		EndIf
		T_A004RegOK ("027","MHE",M->MHD_PRODUT+MHE->MHE_CODCOM+MHE->MHE_SEQUEN,1,cTipoOp)  
	Next nCntFor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aqui eu reordeno a sequencia gravada fora de ordem.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lGravou )
		nSeq := 1
		dbSelectArea("MHE")
		dbSetOrder(1)
		dbSeek(xFilial("MHE")+M->MHD_PRODUT,.F.)
		While ( !Eof() .And. xFilial("MHE") == MHE->MHE_FILIAL .And.;
			M->MHD_PRODUT  == MHE->MHE_PRODUT )
			RecLock("MHE",.F.)
			MHE->MHE_SEQUEN := StrZero(nSeq,2)
			nSeq++
			lGravou := .T.
			dbSelectArea("MHE")
			dbSkip()
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o Cabecario da Sugestao de Orcamento           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lGravou )
		dbSelectArea("MHD")
		RecLock("MHD",.F.)
		cTipoOp := "UPDATE"	
		
		For nCntFor := 1 To FCount()
			If ("FILIAL" $ FieldName(nCntFor) )
				FieldPut(nCntFor,xFilial())
			Else
				FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
			EndIf
		Next
	Else
		dbSelectArea("MHD")
		RecLock("MHD",.F.)
		dbDelete()
		cTipoOp := "DELETE"
	EndIf
	
	If ( lGravou )
    	T_A004RegOK ("027","MHD",M->MHD_PRODUT,1,cTipoOp) 
	EndIf
EndIf
If ( nOpc == 3 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta os Itens da Sugestao de Orcamento             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSeq := 1
	dbSelectArea("MHE")
	dbSetOrder(1)
	dbSeek(xFilial("MHE")+M->MHD_PRODUT,.T.)
	While ( MHE->(!Eof()) .And. xFilial("MHE") == MHE->MHE_FILIAL .And.;
		MHE->MHE_PRODUT == M->MHD_PRODUT )
		RecLock("MHE")
		MHE->(dbDelete())
		T_A004RegOK ("027","MHE",M->MHD_PRODUT+MHE->MHE_CODCOM+MHE->MHE_SEQUEN,1,"DELETE")
		MHE->(dbSkip())		
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o Cabecario da Sugestao de Orcamento          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("MHD")
	RecLock("MHD")
	dbDelete()
	lGravou := .T.
		
	If ( lGravou )    
    	T_A004RegOK ("027","MHD",M->MHD_PRODUT,1,"DELETE")
	EndIf
	
EndIf
MsUnLockAll()
RestArea(aArea)
Return lGravou

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Prod  º Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para validacao do CODPROD                         º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Template Function A004Prod()
Local aArea	   := GetArea()
Local lRetorno := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Registros                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
SB1->(dbSetOrder(1) )
SB1->(dbSeek(xFilial("SB1")+M->MHD_PRODUT,.T.))
dbSelectArea("SG1")
SG1->(dbSetOrder(1))
SG1->(dbSeek(xFilial()+M->MHD_PRODUT,.T.))
If ( xFilial("SG1") == SG1->G1_FILIAL .And. M->MHD_PRODUT == SG1->G1_COD )
	Help(" ",1,"A004PROD01")
	lRetorno := .F.
Else
	M->MHD_DESCRI := SB1->B1_DESC
EndIf
RestArea(aArea)
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Comp  º Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para validacao do codigo do componente do kit     º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Template Function A004Comp()

Local aArea	   := { Alias(),IndexOrd(),Recno() }
Local lRetorno := .T.
Local nPosDesc := 0
Local nPosCmp  := 0
Local nTamanho := 0

nPosDesc := aScan(aHeader,{|x| AllTrim(x[2])=="MHE_DESCRI" })
nPosCmp  := aScan(aHeader,{|x| AllTrim(x[2])=="MHE_CODCOM" })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Registros                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//se o produto inserido no acols é igual ao do cabecalho
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+M->MHE_CODCOM,.T.)
If ( lRetorno .And. M->MHE_CODCOM == M->MHD_PRODUT )
	Help(" ",1,"A004COMP01")
	lRetorno := .F.
EndIf

//se o produto inserido no acols já existe cadastrado
dbSelectArea("MHD")
dbSetOrder(1)
dbSeek(xFilial()+M->MHE_CODCOM)
If ( lRetorno .And. Found() )
	Help(" ",1,"A004COMP02")
	lRetorno := .F.
EndIf
//
If ( lRetorno .And. ALTERA .And. M->MHE_CODCOM <> aCols[n,nPosCmp] .And.;
	!Empty(aCols[n,nPosCmp]) )
	Help(" ",1,"A004COMP03")
	lRetorno := .F.
EndIf
If ( nPosDesc <> 0 .And. lRetorno)
	nTamanho := Len(aCols[n][nPosDesc])
	aCols[n][nPosDesc] := PadL(SB1->B1_DESC,nTamanho)
EndIf
oGet:Refresh()
RestArea(aArea)
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³A004Descriº Autor ³ ANDRE MELO         º Data ³ 29.03.04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObjetivo  ³ Programa para validacao da descricao do kit                º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Template Function A004Descri(cCampo)
Local aArea		:= GetArea()
Local cRetorno  := ""

cCampo := AllTrim(cCampo)
If !Eof()
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	
	If cCampo == "MHD_DESCRI" .And. !INCLUI
		SB1->(dbSeek(xFilial()+MHD->MHD_PRODUT,.T.))
		If SB1->(Found())
			cRetorno := SB1->B1_DESC
		Endif
	EndIf
	
	If cCampo == "MHE_DESCRI" .And. !INCLUI
		SB1->(dbSeek(xFilial()+MHE->MHE_CODCOM,.T.))
		If SB1->(Found())
			cRetorno := SB1->B1_DESC
		EndIf
	EndIf
EndIf
cRetorno := PadL(cRetorno,TamSX3(cCampo)[1])
RestArea(aArea)

Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³A004RegOK ³ Autor ³ Vendas cliente		³ Data ³ 05/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os dados do KIT DE VENDA na tabela de integracao	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de produto	                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function A004RegOK(cProcess, cTabela, cChave, nOrdem, cTipo)
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline

//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New("027")
	
	//Determina o tipo de operacao 
	If cTipo = "DELETE"			
		//Considera os registros deletados
		SET DELETED OFF
	EndIf		    

	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir(cTabela, xFilial(cTabela) + cChave, nOrdem, cTipo)	
			
		//Processa os dados 
		oProcessOff:Processar()	
	EndIf
	
	//Desconsidera os registros deletados
	SET DELETED ON
EndIf
	
Return Nil