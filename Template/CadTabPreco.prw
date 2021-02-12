#Include "Protheus.ch"
#Include "Rwmake.ch"
#INCLUDE "CADTABPRECO.CH"

#DEFINE MAXGETDAD 99999
#DEFINE MAXSAVERESULT 99999
 
Static aUltResult

/////////////////////////////////////////////////////////
// Rotina: CatTabPreco                                 //
//-----------------------------------------------------//
// Rotina para manutencao da tabela de precos          //
/////////////////////////////////////////////////////////    

Template Function CadTabPreco()

Local aCores     := {}
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
Private aRotina := {{ "Pesquisar","AxPesqui",0,1},;//"Pesquisar"
					{ "Visualizar","T_Oms010Tab('DA0', 1, 2)",0,2},;	//"Visualizar"
					{ "Incluir","T_Oms010Tab",0,3},;	//"Incluir"
					{ "Alterar","T_Oms010Tab",0,4},;	//"Alterar"
					{ "Excluir","T_Oms010Tab",0,5},;	//"Excluir"
					{ "Copiar","T_Oms010Tab",0,4},;   //"Copiar"
					{ "Copiar","T_Oms010PFor",0,3},;  //"Copiar"		
					{ "Reajuste","T_Oms010Rej",0,5},;   //"Reajuste"
					{ "Legenda","T_Oms010Leg",0,2} }   //"Legenda"
cCadastro := "Manutencao da Tabela de Precos"	//"Manutencao da Tabela de Precos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as cores da MBrowse                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCores,{"Dtos(DA0_DATATE) < Dtos(dDataBase).And. !Empty(Dtos(DA0_DATATE))","DISABLE"}) //inativa
Aadd(aCores,{"(Dtos(DA0_DATATE) >= Dtos(dDataBase) .Or. Empty(Dtos(DA0_DATATE))).And.DA0_ATIVO =='1'","ENABLE"})    //Ativa simples
Aadd(aCores,{"(Dtos(DA0_DATATE) >= Dtos(dDataBase) .Or. Empty(Dtos(DA0_DATATE))) .And.DA0_ATIVO =='2'","BR_LARANJA"}) //Ativa especial

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilita as perguntas da Rotina                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	AjustaSx1()
EndIf

Pergunte("OMS010",.F.)
SetKey(VK_F12,{|| Pergunte("OMS010",.T.)})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereca para a funcao MBrowse                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DA0")
dbSetOrder(1)
MsSeek(xFilial("DA0"))
mBrowse(06,01,22,75,"DA0",,,,,,aCores)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade da Rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DA0")
dbSetOrder(1)
dbClearFilter()
SetKey(VK_F12,Nil)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³Oms010Tab ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Manutencao da Tabela de Preco                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Tab()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function Oms010Tab(cAlias,nReg,nOpc,lConsulta)
Local aArea     := GetArea()
Local aCampos   := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aButtons  := { { "S4WB011N"   , { || GdSeek(oGetDad,"Busca produto na tabela") }, "Busca produto na tabela", "Busca" } } 
Local aRecno    := {}
Local aButtonUsr:= {}
Local aStruDA1  := {}
Local nOrderDA1 := 3
Local nUsado    := 0
Local nX        := 0
Local nOpcA     := 0
Local nCntFor   := 0
Local nSaveSx8  := GetSx8Len()                      
Local nI        := 0
Local bSavKey   := SetKey(VK_F12,Nil)
Local bWhile    := {|| !Eof()}
Local cKeyDA1   := ""
Local cProduto  := ""
Local cDescricao:= ""
Local cCadastro := "Manutencao da Tabela de Precos"	//"Manutencao da Tabela de Precos"
Local cQuery    := ""        
Local cAliasDA1 := "DA1"
Local lCopia    := nOpc==6
Local lAltera   := nOpc==4              // Somente a Alteracao pode ser feita atraves do F12 por produto
Local lGrava	:= .F.
Local lContinua := .T.
Local lQuery    := .F.
Local lMemo     := .F.
Local cAliasFiliais := ""

Local oDlg
Local oGetD

Private aHeader := {}
Private aCols   := {}
Private aTELA[0][0],aGETS[0]                             
Private oGetDad

DEFAULT INCLUI := .F.
DEFAULT lConsulta:= .F.

Pergunte("OMS010",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se outro programa estiver consultando a tabela de precos a visualizacao podera ser feita atraves do produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(lConsulta) == "L"
	If lConsulta
		If !lAltera
			lAltera := .T.
		Endif
	Endif	
Endif		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui botoes de usuario  na enchoicebar                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("OS010BTN")
	aButtonUsr := ExecBlock("OS010BTN",.F.,.F.)
	If ValType(aButtonUsr) == "A"
		For nI   := 1  To  Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nI]))
		Next nI
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os parametros da rotina                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lCopia
	mv_par01 := 1 
Endif	

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manutencao por Tabela                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case MV_PAR01 == 1 .Or. INCLUI

	If nOpc == 5
		lContinua := Os010CanDel(DA0->DA0_CODTAB)
	Endif	
	
	If lContinua

		MV_PAR01 := 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as variaveis da Enchoice                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If INCLUI .Or. lCopia
			RegToMemory( "DA0", .T., .F. )
		EndIf
		If !INCLUI .Or. lCopia		 
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se eh alteracao ou exclusao                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If aRotina[nOpc][4] == 4 .Or. aRotina[nOpc][4] == 5
				lContinua :=  SoftLock("DA0")
			Endif	
		
			If lCopia .Or. lContinua
				If !lCopia
					RegToMemory( "DA0", .F., .F. )
				EndIf
				
				#IFDEF TOP
				
					dbSelectArea("DA1")
					dbSetOrder(3)
				
					If TcSrvType() <> "AS/400" .And. !lMemo
	
						cAliasDA1 := "DA1"
						lQuery    := .T.
						aStruDA1  := DA1->(dbStruct())
				
						cQuery := "SELECT DA1.*,DA1.R_E_C_N_O_ DA1RECNO FROM "						
						cQuery += RetSqlName("DA1")+ " DA1 "
						cQuery += "WHERE "
						cQuery += "DA1_FILIAL = '"+xFilial("DA1")+"' AND "
						cQuery += "DA1_CODTAB = '"+DA0->DA0_CODTAB+"' AND "
						cQuery += "DA1.D_E_L_E_T_ = ' '"
						cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))
						
					    cQuery := ChangeQuery(cQuery)
					    
					    DA1->(dbCloseArea())
					    
					    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)
			    
						For nCntFor := 1 To Len(aStruDA1)
							If ( aStruDA1[nCntFor,2]<>"C" )
								TcSetField(cAliasDA1,aStruDA1[nCntFor,1],aStruDA1[nCntFor,2],aStruDA1[nCntFor,3],aStruDA1[nCntFor,4])
							EndIf
						Next nCntFor
	
						bWhile := { || (cAliasDA1)->(!Eof()) }
						
					Else	
				#ENDIF
						nOrderDA1 := 3
						cKeyDA1   := xFilial("DA1")+DA0->DA0_CODTAB
						bWhile    := {|| !Eof() .And. DA1->DA1_FILIAL==xFilial("DA1") .And. DA1->DA1_CODTAB == DA0->DA0_CODTAB }
	
				#IFDEF TOP
					Endif			
				#ENDIF
				
			Else
				lContinua := .F.		
			EndIf
		EndIf
	Else
		Help(" ",1,"NODELETA")
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manutencao por Produto                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
Case MV_PAR01 == 2

	cProduto := MV_PAR02
	SB1->(dbSetOrder(1))
	If SB1->(!MsSeek(xFilial()+cProduto))
		Help(" ",1,"OMS010TP2")
		lContinua := .F.
	Else
		cDescricao := SB1->B1_DESC	
	EndIf
	nOrderDA1 := 2
	cKeyDA1 := xFilial("DA1")+cProduto
	bWhile    := {|| !Eof() .And. DA1->DA1_FILIAL==xFilial("DA1") .And. DA1->DA1_CODPRO == cProduto }

EndCase

If lContinua

	aCampos := Iif(mv_par01 == 1,{"DA1_CODTAB","DA1_DESTAB"},{"DA1_CODPRO","DA1_DESCRI","DA1_ITEM","DA1_CODTAB"})
	
	dbSelectArea("SX3")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par01 == 2
		SX3->(dbSetOrder(2))
		If SX3->(MsSeek("DA1_CODTAB"))
			Aadd(aHeader, {   AllTrim(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"T_Oms010Vld()",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )                        
				nUsado++										
		Endif
		
		SX3->(dbSetOrder(2))
		If SX3->(MsSeek("DA1_ITEM"))
			Aadd(aHeader, {   AllTrim(X3Titulo()),;
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
	Endif
	
	SX3->(dbSetOrder(1))
	SX3->(MsSeek("DA1"))
	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "DA1"
		If Ascan(aCampos,AllTrim(SX3->X3_CAMPO)) == 0 .And. X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			Aadd(aHeader, {   AllTrim(X3Titulo()),;
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
		EndIf
		
		If SX3->X3_TIPO == "M"
			lMemo := .T.
		Endif	

		SX3->(dbSkip())
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aCols.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !INCLUI
		
		If !lQuery
			dbSelectArea(cAliasDA1)
			dbSetOrder(nOrderDA1)
			MsSeek(cKeyDA1)
		Endif
			
		While Eval(bWhile)
			Aadd(aCols,Array(nUsado+1))

			If !lCopia
				If !lQuery
					aadd(aRecno,(cAliasDA1)->(Recno()))				
				Else	
					aadd(aRecno,(cAliasDA1)->DA1RECNO)					
				Endif	                             
			Endif
				
			For nX := 1 To nUsado
				If ( aHeader[nX,10] !=  "V" )
					aCOLS[Len(aCols)][nX] := (cAliasDA1)->(FieldGet(ColumnPos(aHeader[nX,2])))
				Else
					aCOLS[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
				EndIf
			Next nX
			aCols[Len(aCols)][nUsado+1] := .F.
			dbSelectArea(cAliasDA1)
			dbSkip()
		EndDo
		
		If lQuery
			dbSelectArea(cAliasDA1)
			dbCloseArea()
			ChkFile("DA1",.F.)
			dbSelectArea("DA0")
		EndIf	
Endif		
	
	If Empty(aCols)
		Aadd(aCols,Array(nUsado+1))
		For nX := 1 To nUsado
			If AllTrim(aHeader[nX,2]) == "DA1_ITEM"
				aCOLS[Len(aCols)][nX] := StrZero(1,Len((cAliasDA1)->DA1_ITEM))
			Else
				aCOLS[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
			EndIf
		Next nX
		aCols[Len(aCols)][nUsado+1] := .F.
	EndIf
	
	dbSelectArea("DA0")
	
	Do Case
	Case MV_PAR01 == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize()
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 200, 200, .T., .T. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj 	:= MsObjSize( aInfo, aObjects,.T.)

		DA1->(dbGoto(0))
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( "DA0", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.T. )	
		oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"T_Oms010LOk()","T_Oms010TOk()","+DA1_ITEM",.T.,,1,,MAXGETDAD)
		oGetDad := oGetD
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(oGetd:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},,aButtons )
	Case MV_PAR01 == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize()
		AAdd( aObjects, { 100, 020, .T., .F. } )
		AAdd( aObjects, { 300, 200, .T., .T. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ],2,2}
		aPosObj := MsObjSize( aInfo, aObjects)

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
		@ aPosObj[1,1],aPosObj[1,2]+005 SAY RetTitle("DA1_CODPRO") SIZE 035,009 OF oDlg PIXEL	//"Produto"
		@ aPosObj[1,1],aPosObj[1,2]+040 MSGET oGet1 VAR cProduto	PICTURE "@!" WHEN .F.	SIZE 085,009 OF oDlg PIXEL
		@ aPosObj[1,1],aPosObj[1,2]+140 MSGET oGet2 VAR cDescricao	PICTURE "@!" WHEN .F.	SIZE 150,009 OF oDlg PIXEL
		dbSelectArea("DA1")		
		oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"T_Oms010LOk()","T_Oms010TOk()",,.T.,,,,MAXGETDAD)						
		oGetDad := oGetD
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()},,aButtons)
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina de Gravacao da Tabela de preco                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1 .And. nOpc <> 2
	    lGrava := .T.
		If nOpc == 6
			lGrava := SelFiliais()
		EndIf
		If lGrava
			Oms010Grv(nOpc-2,MV_PAR01,cProduto,aRecno)
			While (GetSx8Len() > nSaveSx8 )
				ConfirmSx8()
			EndDo
			EvalTrigger()
		EndIf
	Else
		If nOpc <> 2                   
			While (GetSx8Len() > nSaveSx8 )		
				RollBackSx8()	
			Enddo		
		Endif				
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a entrada da Rotina                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsUnLockAll()
FreeUsedCode()
SetKey(VK_F12,bSavKey)
RestArea(aArea)
Return nOpcA

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010For ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de geracao de tabela a partit do cadastro de produtos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Tab()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010For(cAlias,nReg,nOpc)

Local aCampos   := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aButtons  := {}
Local aButtonUsr:= {}  
Local aArea     := GetArea()
Local aRecno    := {}

Local bSavKey   := SetKey(VK_F12,Nil)

Local cAliasSB1 := "SB1"      
Local cCondicao := ""
Local cArqInd   := ""
Local cProduto  := ""

Local lQuery    := .F.
Local lExcLine  := ExistBlock("OS010LCO")
Local lOs010Col := ExistBlock("OS010COL")

Local nIndex    := 0
Local nUsado    := 0
Local nOpcA     := 0
Local nItem     := 0
Local nSaveSx8  := GetSx8Len()
Local nX        := 0
Local nI        := 0

Local oDlg
Local oGetD

Private aHeader := {}
Private aCols   := {}
Private aTELA[0][0],aGETS[0]
Private oGetDad

INCLUI := .T.
ALTERA := .F.

If ExistBlock("OS010BTN")
	aButtonUsr := ExecBlock("OS010BTN",.F.,.F.)
	If ValType(aButtonUsr) == "A"
		For nI   := 1  To  Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nI]))
		Next nI
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os parametros da rotina                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de parametrizacao de lancamentos    ³
//³                                                      ³
//³ MV_PAR01 Produto inicial?                            ³
//³ MV_PAR02 Produto final  ?                            ³
//³ MV_PAR03 Grupo inicial  ?                            ³
//³ MV_PAR04 Grupo final    ?                            ³
//³ MV_PAR05 Tipo inicial   ?                            ³
//³ MV_PAR06 Tipo final     ?                            ³
//³ MV_PAR07 Tabela Inicial ?                            ³
//³ MV_PAR08 Tabela final   ?                            ³
//³ MV_PAR09 Fator          ?                            ³
//³ MV_PAR10 Numero decimais?                            ³
//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
//³ MV_PAR12 Reaplicar fator?                            ³
//³ MV_PAR13 Planilha       ?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Pergunte("OMS10A",.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa as variaveis da Enchoice                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RegToMemory( "DA0", .T., .F. )

	aCampos := {"DA1_CODTAB","DA1_DESTAB"}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("DA1")
	While !Eof() .And. SX3->X3_ARQUIVO == "DA1"
		If Ascan(aCampos,AllTrim(SX3->X3_CAMPO)) == 0 .And. X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			Aadd(aHeader, {   AllTrim(X3Titulo()),;
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
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aCols.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	#IFDEF TOP
	
		If TcSrvType() <> "AS/400"
	
		    lQuery    := .T.
		    cAliasSB1 := "QRYSB1"
		    
		    cQuery := "SELECT B1_COD,B1_DESC,B1_PRV1 "
		    cQuery += "FROM "+RetSqlName("SB1")+ " SB1 "
		    cQuery += "WHERE "
		    cQuery += "B1_FILIAL ='"+xFilial("SB1")+"' AND "
		    cQuery += "B1_COD >= '"+mv_par01+"' AND "
		    cQuery += "B1_COD <= '"+mv_par02+"' AND "
		    cQuery += "B1_GRUPO >= '"+mv_par03+"' AND "
		    cQuery += "B1_GRUPO <= '"+mv_par04+"' AND "
		    cQuery += "B1_TIPO >= '"+mv_par05+"' AND "
		    cQuery += "B1_TIPO <= '"+mv_par06+"' AND "
		    cQuery += "SB1.D_E_L_E_T_ = ' '"
		    cQuery += "ORDER BY "+SqlOrder(SB1->(IndexKey()))
		    
		    cQuery := ChangeQuery(cQuery)
		    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
		    
			TcSetField(cAliasSB1,"B1_PRV1","N",TamSx3("B1_PRV1")[1],TamSx3("B1_PRV1")[2])
		    
		Else	
	#ENDIF
    		cAliasSB1 := "SB1"
			cArqInd   := CriaTrab(,.F.)    		
    		
    		cCondicao := 'B1_FILIAL == "'+xFilial("SB1")+'" .And.'
    		cCondicao += 'B1_COD >= "'+mv_par01+'" .And. B1_COD <= "'+mv_par02+'" .And. '
    		cCondicao += 'B1_GRUPO >= "'+mv_par03+'" .And. B1_GRUPO <= "'+mv_par04+'" .And. '
    		cCondicao += 'B1_TIPO >= "'+mv_par05+'" .And. B1_TIPO <= "'+mv_par06+'" '
			IndRegua(cAliasSB1,cArqInd,IndexKey(),,cCondicao)

			nIndex := RetIndex("SB1")		
			#IFNDEF TOP		
				dbSetIndex(cArqInd+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndex+1)   
			dbGotop()

	#IFDEF TOP    		
		Endif
	#ENDIF			

	While (cAliasSB1)->(!Eof())
	
   		Aadd(aCols,Array(nUsado+1))
		nItem++   		
		
		For nX := 1 To nUsado
		
			If ( aHeader[nX,10] !=  "V" )
			
				Do Case           
					Case Alltrim(aHeader[nX][2]) == "DA1_ITEM"
						aCOLS[Len(aCols)][nX] := StrZero(nItem,4)
					Case Alltrim(aHeader[nX][2]) == "DA1_CODPRO"
						aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(ColumnPos("B1_COD")))
					Case Alltrim(aHeader[nX][2]) == "DA1_DATVIG"
						aCOLS[Len(aCols)][nX] := mv_par07
					Case Alltrim(aHeader[nX][2]) == "DA1_PRCVEN"                     
						aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(ColumnPos("B1_PRV1")))					
					OtherWise
						aCols[Len(aCols)][nX] := Criavar(aHeader[nX][2],.T.)
				EndCAse						
			Else       
			
    			Do Case
					Case  Alltrim(aHeader[nX][2]) == "DA1_DESCRI"				
						aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(ColumnPos("B1_DESC")))					
					Case Alltrim(aHeader[nX][2]) == "DA1_PRCBAS"                     
						aCOLS[Len(aCols)][nX] := (cAliasSB1)->(FieldGet(ColumnPos("B1_PRV1")))					
					OtherWise				
						aCOLS[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
				EndCase									
				
			EndIf
			
		Next nX
		aCols[Len(aCols)][nUsado+1] := .F.
		
		If lExcLine
			aCols[Len(aCols)] := ExecBlock("OS010LCO",.F.,.F.,{aHeader,aCols[Len(aCols)]})
		Endif	

		If lOs010Col
			aCols := ExecBlock("OS010COL",.F.,.F.,{aHeader,aCols})
		Endif	
		
		dbSelectArea(cAliasSB1)
		dbSkip()
	EndDo

	If Empty(aCols)
		Aadd(aCols,Array(nUsado+1))
		For nX := 1 To nUsado
			If AllTrim(aHeader[nX,2]) == "DA1_ITEM"
				aCOLS[Len(aCols)][nX] := StrZero(1,Len(DA1->DA1_ITEM))
			Else
				aCOLS[Len(aCols)][nX] := CriaVar(aHeader[nX,2],.T.)
			EndIf
		Next nX
		aCols[Len(aCols)][nUsado+1] := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 200, 200, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( "DA0", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.T. )	
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"T_Oms010LOk()","T_Oms010TOk()","+DA1_ITEM",.T.,,1,,MAXGETDAD)
	oGetDad := oGetD
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(oGetd:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},,aButtons )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina de Gravacao da Tabela de preco                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1 .And. nOpc <> 2
		Oms010Grv(nOpc-2,1,,aRecno)		
		While ( GetSx8Len() > nSaveSx8 )
			ConfirmSx8()
		EndDo
		EvalTrigger()
	Else
		If nOpc <> 2
			While ( GetSx8Len() > nSaveSx8 )
				RollBackSx8()
			EndDo
		Endif			
	EndIf                                                             

	If lQuery
		dbSelectArea(cAliasSB1)
		dbCloseArea()
		dbselectArea("DA0")
	Else
		dbSelectArea("SB1")
		dbClearFilter()
		RetIndex("SB1")
		Ferase(cArqInd+OrdBagExt())
		dbselectArea("DA0")		
	Endif		
	
	MsUnLockAll()
	FreeUsedCode()
	SetKey(VK_F12,bSavKey)
	RestArea(aArea)
	
Endif	

If Inclui
	Inclui := !Inclui
Endif	
	
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010Grv ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Gravacao da Tabela de Preco                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Grv                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opcao da Gravacao sendo:                               ³±±
±±³          ³       [1] Inclusao                                           ³±±
±±³          ³       [2] Alteracao                                          ³±±
±±³          ³       [3] Exclusao                                           ³±±
±±³          ³ExpN2: Tipo de Gravacao sendo:                                ³±±
±±³          ³       [1] Tabela                                             ³±±
±±³          ³       [2] Produto                                            ³±±
±±³          ³ExpC3: Codigo do Produto para gravacao por produto            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Grv(nOpcao,nTipo,cProduto,aRecno)

Local aArea    	:= GetArea()
Local cAliasFil	:= Alias()
Local cSavRecno
Local aCodFil	:= {}
Local cSavAlias := ""
Local aTabDel   := {}
Local aRegNo    := {}
Local aDadosDA0
Local aUsrMemo  := If( ExistBlock( "OM010MEM" ), ExecBlock( "OM010MEM", .F.,.F. ), {} ) 
Local aMemoDA0  := {}
Local aMemoDA1  := {}
Local lGravou   := .F.
Local lTravou   := .T.   
Local lEntryDA1 := ExistBlock("OM010DA1")
Local lEntryEnd := ExistBlock("OS010END")
Local nX        := 0
Local nY        := 0
Local nA		:= 0
Local nB		:= 0
Local nCntfor   := 0
Local nUsado    := Len(aHeader)
Local nPosTabela:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_CODTAB"})
Local nPItem    := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_ITEM"})
Local nLoop     := 0
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local cItem     := Repl("0",Len(DA1->DA1_ITEM))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa buffer                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aUltResult := Nil   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega campos memo de usuario mas se nao for copia          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( aUsrMemo ) == "A" .And. Len( aUsrMemo ) > 0 .And. nOpcao <> 4
	For nLoop := 1 to Len( aUsrMemo ) 
		If aUsrMemo[ nLoop, 1 ] == "DA0"			
			AAdd( aMemoDA0, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } ) 		                                
		ElseIf aUsrMemo[ nLoop, 1 ] == "DA1"
			AAdd( aMemoDA1, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } ) 		                                
		Endif	
	Next nLoop 
EndIf 	

Do Case
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao por Tabela                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case nTipo == 1 .And. nOpcao <> 3

	nA := 1
	nX := 1
    
 	Begin Transaction
          
	While nX <= Len(aCols)

		If ExistBlock( "OS010MAN")
			ExecBlock( "OS010MAN", .F., .F. ) 
		EndIf
		dbSelectArea("DA0")
		dbSetOrder(1)

		If nOpcao == 4
			If nA == 1 .And. nX == 1
			    cSavAlias := Alias()
			    cSavRecno := Recno()
			    DbSelectArea(cAliasFil)
			    DbGoTop()
			    While !EOF()
			    	If Marked("MARCA")
				    	Aadd(aCodFil, (cAliasFil)->CODFIL)
			    	EndIf
			     	DbSkip()
			    EndDo
			    DbSelectArea(cSavAlias)
			    DbGoto(cSavRecno)
			    aDadosDA0 := {}
				For nB := 1 To FCount()
					Aadd(aDadosDA0, M->&(EVAL(bCampo, nB)))
				Next nB
			Else
				If nX == 1
					RecLock("DA0", .T.)
					For nB := 1 To FCount()
						&(Field(nB)) := aDadosDA0[nB]
					Next nB
					If nA == 1
						DA0->DA0_FILIAL := xFilial("DA0") // Acresentar a Filial Seguinte
					Else
						DA0->DA0_FILIAL := aCodFil[nA - 1]
					EndIf
					DA0->DA0_CODTAB := GETSXENUM("DA0", "DA0_CODTAB")
					MsUnLock("DA0")
				EndIf
			EndIf
		EndIf
	 
		If nX == 1 .And. nA == 1
			If MsSeek(xFilial("DA0")+M->DA0_CODTAB)
				RecLock("DA0",.F.)
			Else
 				RecLock("DA0",.T.)
			EndIf
			For nCntFor := 1 TO FCount()
				FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
			Next nCntFor

			DA0->DA0_FILIAL := xFilial("DA0")
			
			For nLoop := 1 To Len( aMemoDA0 ) 
				MSMM( DA0->( FieldGet( ColumnPos(aMemoDA0[nLoop,1] ) ) ),,, M->&( aMemoDA0[nLoop,2] ),1,,,"DA0",aMemoDA0[nLoop,1])
			Next nLoop 
			
			MsUnLock()
		Endif
		
		lTravou := .F.
		If nX <= Len(aRecNo)		
			dbSelectArea("DA1")
			dbGoto(aRecNo[nX])
			RecLock("DA1")
			lTravou := .T.
		EndIf
			
		If ( !aCols[nX][nUsado+1] )
			If !lTravou 
				RecLock("DA1",.T.)			
			EndIf
			For nY := 1 to Len(aHeader)
				If aHeader[nY][10] <> "V"
					DA1->(FieldPut(ColumnPos(aHeader[nY][2]),aCols[nX][nY]))
				EndIf
			Next nY
			cItem := Soma1(cItem,Len(DA1->DA1_ITEM))
			If nA == 1
				DA1->DA1_FILIAL := xFilial("DA1")
			Else
				DA1->DA1_FILIAL := aCodFil[nA - 1]
			EndIf
			DA1->DA1_CODTAB := DA0->DA0_CODTAB
			DA1->DA1_ITEM   := cItem
			DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,18,2)
			
			For nLoop := 1 To Len( aMemoDA1 ) 
				MSMM( DA1->( FieldGet( ColumnPos( aMemoDA1[nLoop,1] ) ) ),,,GDFieldGet( aMemoDA1[nLoop,2], nX ),1,,,"DA1",aMemoDA1[nLoop,1])
			Next nLoop 
			
			MsUnLock()                   
			
			If lEntryDA1
				ExecBlock("OM010DA1",.F.,.F.,{nTipo,nOpcao})
			Endif	
			
			lGravou := .T.
		Else
			If lTravou        
				RecLock("DA1")
				DA1->(dbDelete())

				For nLoop := 1 To Len( aMemoDA1) 
					MSMM( DA1->( FieldGet( ColumnPos( aMemoDA1[ nLoop, 1 ] ) ) ),,,,2)
				Next nLoop 
				
			Endif				
		EndIf
		MsUnLock()

		If lEntryEnd
			ExecBlock("OS010END",.F.,.F.,{nTipo,nOpcao})
		Endif
		
		If nOpcao == 4
		  If nX == Len(aCols) .And. nA <= Len(aCodFil)
			nA++
		    nX := 1
		    cItem := Repl("0", Len(DA1->DA1_ITEM))
		    Loop
		  Else
		    nX++
		  EndIf
		Else
		  nX++
		EndIf
		
	EndDo
	
	End Transaction
	
	If !lGravou
		dbSelectArea("DA0")
		dbSetOrder(1)
		If MsSeek(xFilial("DA0")+M->DA0_CODTAB)
			RecLock("DA0")
			dbDelete()

			For nLoop := 1 To Len( aMemoDA0 ) 
				MSMM( DA0->( FieldGet( ColumnPos( aMemoDA0[ nLoop, 1 ] ) ) ),,,,2)
			Next nLoop 
			
			MsUnLock()
		EndIf
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclusao por Tabela                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case  nTipo == 1 .And. nOpcao == 3

	Begin Transaction

		If ExistBlock( "OS010EXT" )
			ExecBlock( "OS010EXT", .F., .F. ) 
		EndIf                                  

		dbSelectArea("DA1")
		dbSetOrder(1)
		MsSeek(xFilial("DA1")+M->DA0_CODTAB)
		While ( !Eof() .And. xFilial("DA1") == DA1->DA1_FILIAL .And. M->DA0_CODTAB == DA1->DA1_CODTAB )
			
			RecLock("DA1")
				dbDelete()

				For nLoop := 1 To Len( aMemoDA1 ) 
					MSMM( DA1->( FieldGet( ColumnPos( aMemoDA1[ nLoop, 1 ] ) ) ),,,,2)
				Next nLoop 
			
			MsUnLock()

			If lEntryDA1
				ExecBlock("OM010DA1",.F.,.F.,{nTipo,nOpcao})
			Endif	
		
			dbSelectArea("DA1")
			dbSkip()
		EndDo
	
		dbSelectArea("DA0")
		dbSetOrder(1)
		If MsSeek(xFilial("DA0")+M->DA0_CODTAB)
			RecLock("DA0",.F.)
				dbDelete()
				For nLoop := 1 To Len( aMemoDA0 ) 
					MSMM( DA0->( FieldGet( ColumnPos( aMemoDA0[ nLoop, 1 ] ) ) ),,,,2)
				Next nLoop 
			MsUnLock()
		EndIf
	End Transaction

	If lEntryEnd
		ExecBlock("OS010END",.F.,.F.,{nTipo,nOpcao})
	Endif	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao por Produto                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Case  nTipo == 2 .And. nOpcao <> 3

	Begin Transaction

		If ExistBlock( "OS010MNP" )
			ExecBlock("OS010MNP",.f.,.f., cProduto )
		EndIf 

		For nX := 1 To Len(aCols)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava DA1                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lTravou := .F.
			If nX <= Len(aRecNo)
				dbSelectArea("DA1")
				dbGoto(aRecNo[nX])
				RecLock("DA1")
				lTravou := .T.
			EndIf

			If ( !aCols[nX][nUsado+1] )
				If !lTravou 
					RecLock("DA1",.T.)			
				EndIf
			
				For nY := 1 To nUsado
					If ( aHeader[nY][10] != "V" )
						DA1->(FieldPut(ColumnPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				DA1->DA1_FILIAL := xFilial("DA1")
				DA1->DA1_CODPRO := cProduto
				DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,18,2)
				MsUnlock()
				
				If lEntryDA1
					ExecBlock("OM010DA1",.F.,.F.,{nTipo,nOpcao})
				Endif	
				
			Else
				If lTravou
					dbSelectArea("DA1")
					dbSetOrder(2)
					MsSeek(xFilial()+cProduto+aCols[nX][nPosTabela]+aCols[nX][nPItem])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se delecao armazena para verificar se deleta cabecalho       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Ascan(aTabDel,aCols[nX][nPosTabela]) == 0					
						Aadd(aTabDel,aCols[nX][nPosTabela])
					Endif	
					
					RecLock("DA1",.F.)					
						dbDelete()
					MsUnlock()	
				Endif	
			Endif	
			
		Next nX
                                                	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Analisa se deleta cabecalho de acordo com os deletados       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY := 1 to Len(aTabDel)
			DA1->(dbSetOrder(3))
			If !DA1->(MsSeek(xFilial("DA1")+aTabDel[nY]))
				DA0->(DBSetOrder(1))
				If DA0->(MsSeek(xFilial("DA0")+aTabDel[nY]))				
					RecLock("DA0",.F.)					
						dbDelete()
					MsUnlock()	
				Endif
			Endif		
		Next

		If lEntryEnd
			ExecBlock("OS010END",.F.,.F.,{nTipo,nOpcao})
		Endif	
		
	End Transaction		

EndCase

RestArea(aArea)

Return(lGravou)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010Calc³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de calculo do fator de acrescimo/descrescimo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Calc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function Oms010Calc()

Local aArea     := GetArea()
Local cCampo    := ReadVar()
Local nRetorno  := 0
Local nPrecoOri := 0
Local nPosPreco := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PRCVEN"})
Local nPosProd  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_CODPRO"})
Local nPMoeda   := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_MOEDA"})
Local nPPrcTab  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PRCBAS"})
Local nPVlrDes  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_VLRDES"})
Local nPPerDes  := Ascan(aHeader,{|x| Alltrim(x[2])=="DA1_PERDES"})

Do Case
Case cCampo == "M->DA1_VLRDES"

    If aCols[n,nPMoeda] <= MoedFin()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametro que indica qual sera a moeda do preco base na tabela de precos³
		//³                             1-Moeda 1 (DEFAULT)                        ³		
		//³                             2-Moeda da linha de itens da tabela        ³				
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SuperGetMv("MV_MPRCBAS",.F.,"1") == "1"
			nPrecoOri := xMoeda(aCols[n,nPPrcTab],1,aCols[n,nPMoeda])
		Else
			nPrecoOri := aCols[n,nPPrcTab]
		Endif	

		If ( ( nPrecoOri - M->DA1_VLRDES ) > 0 )
			aCols[n][nPosPreco] := NoRound(nPrecoOri - M->DA1_VLRDES )
			aCols[n][nPPerDes]  := NoRound((aCols[n][nPosPreco]/nPrecoOri))		
			nRetorno := M->DA1_VLRDES
		Else	
			nRetorno := 0
		EndIf
	Endif		
Case cCampo =="M->DA1_PERDES"

    If aCols[n,nPMoeda] <= MoedFin()              

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametro que indica qual sera a moeda do preco base na tabela de precos³
		//³                             1-Moeda 1 (DEFAULT)                        ³		
		//³                             2-Moeda da linha de itens da tabela        ³				
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		If SuperGetMv("MV_MPRCBAS",.F.,"1") == "1"
			nPrecoOri := xMoeda(aCols[n,nPPrcTab],1,aCols[n,nPMoeda])   		
		Else	
			nPrecoOri := aCols[n,nPPrcTab]
		Endif
			
		aCols[n][nPosPreco] := NoRound(nPrecoOri * If(M->DA1_PERDES == 0,1,M->DA1_PERDES),aHeader[nPosPreco][5])
		nRetorno := M->DA1_PERDES
		If nPVlrDes<>0
			aCols[n][nPVlrDes]   := 0
		EndIf
	Endif		
Case cCampo =="M->DA1_MOEDA"
	aCols[n,nPosPreco] := 0
	aCols[n,nPVlrDes ] := 0
	aCols[n,nPPerDes ] := 0
EndCase
Return(nRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010LOk ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da linha Ok                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Lok())                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function Oms010Lok()

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_CODPRO"})
Local nPosFaixa := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_QTDLOT"})
Local nPosPrcVen:= aScan(aHeader,{|x| AllTrim(x[2])=="DA1_PRCVEN"})
Local nPosTab   := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_CODTAB"})
Local nPosUF    := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_ESTADO"})
Local nPosTpOpe := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_TPOPER"})
Local nPosDtVig := aScan(aHeader,{|x| AllTrim(x[2])=="DA1_DATVIG"})
Local nUsado    := Len(aHeader)
Local nX        := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os campos obrigatorios                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][nUsado+1]
	Do Case
	Case nPosFaixa == 0 .Or. nPosPrcVen == 0
		lRetorno := .F.
		Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODPRO")+","+RetTitle("DA1_QTDLOT")+","+RetTitle("DA1_PRCVEN"),4)
	Case nPosProd > 0 .And. Empty(aCols[n][nPosProd])
		lRetorno := .F.
		Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODPRO"),4)
	Case Empty(aCols[n][nPosFaixa])
		lRetorno := .F.
		Help(" ",1,"OBRIGAT",,RetTitle("DA1_QTDLOT"),4)
	Case nPosTab > 0
		If Empty(aCols[n][nPosTab])
			lRetorno := .F.
			Help(" ",1,"OBRIGAT",,RetTitle("DA1_CODTAB"),4)
		Endif
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nao ha valores duplicados                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If nPosTab == 0
			For nX := 1 To Len(aCols)
				If nX <> N .And. !aCols[nX][nUsado+1]		
					If ( nPosProd == 0 .Or. aCols[nX][nPosProd] == aCols[N][nPosProd]) .And.;
							aCols[nX][nPosFaixa] == aCols[N][nPosFaixa] .And.;
							IIf(nPosTpOpe<>0,aCols[nX][nPosTpOpe] == aCols[N][nPosTpOpe],.F.) .And.;
							IIf(nPosUf<>0,aCols[nX][nPosUf] == aCols[N][nPosUf],.F.) .And.;
							Iif(nPosDtVig<>0,aCols[nX][nPosDtVig] == aCols[N][nPosDtVig],.F.)
						lRetorno := .F.
						Help(" ",1,"JAGRAVADO")
					EndIf
				EndIf
			Next nX
		Else
			For nX := 1 To Len(aCols)
				If nX <> N .And. !aCols[nX][nUsado+1]		
					If ( nPosProd==0 .Or. aCols[nX][nPosProd] == aCols[N][nPosProd]) .And.;
							aCols[nX][nPosFaixa] == aCols[N][nPosFaixa] .And.;
							aCols[nX][nPosTab] == aCols[N][nPosTab] .And.;
							IIf(nPosTpOpe<>0,aCols[nX][nPosTpOpe] == aCols[N][nPosTpOpe],.F.) .And.;
							IIf(nPosUf<>0,aCols[nX][nPosUf] == aCols[N][nPosUf],.F.) .And.;
							Iif(nPosDtVig<>0,aCols[nX][nPosDtVig] == aCols[N][nPosDtVig],.F.)							
						lRetorno := .F.
						Help(" ",1,"JAGRAVADO")
					EndIf
				EndIf
			Next nX	
		EndIf
	EndIf
EndIf

If lRetorno
	If ExistTemplate("OM010LOK")
		lRetorno := ExecTemplate("OM010LOK",.F.,.F.)                                
	Endif
Endif		

RestArea(aArea)
Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010TOk ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Validacao da confirmacao da tabela                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Tok())                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function Oms010Tok()

Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validacao da confirmacao da tabela de preco       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("OM010TOK")
	lRet := ExecBlock("OM010TOK",.F.,.F.)
Endif	

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Rej  ³ Autor ³Eduardo Riera          ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Reajuste das tabelas de precos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                     ³±±
±±³          ³ExpN2: Numero do Registro                                   ³±±
±±³          ³ExpN3: Opcao do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function Oms010Rej(cAlias,nReg,nOpc)

Local aArea := GetArea()
Local nOpcA := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de parametrizacao de lancamentos    ³
//³                                                      ³
//³ MV_PAR01 Produto inicial?                            ³
//³ MV_PAR02 Produto final  ?                            ³
//³ MV_PAR03 Grupo inicial  ?                            ³
//³ MV_PAR04 Grupo final    ?                            ³
//³ MV_PAR05 Tipo inicial   ?                            ³
//³ MV_PAR06 Tipo final     ?                            ³
//³ MV_PAR07 Tabela inicial ?                            ³
//³ MV_PAR08 Tabela final   ?                            ³
//³ MV_PAR09 Fator          ?                            ³
//³ MV_PAR10 Numero decimais?                            ³
//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
//³ MV_PAR12 Reaplicar fator?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetKey(VK_F12,{|| Nil })

Pergunte("OMS011",.F.)
FormBatch(OemToAnsi(STR0008),{OemToAnsi(STR0009),OemToAnsi(STR0010)},;
				{{5,.T.,{|o| Pergunte("OMS011",.T.) }},;
				{1,.T.,{|o| nOpcA:=1,o:oWnd:End()}  },;
				{2,.T.,{|o| o:oWnd:End() }}})
If ( nOpcA == 1 )
	Processa({|| Oms010Proc()})
EndIf                   

SetKey(VK_F12,{|| Pergunte("OMS010",.T.)})

RestArea(aArea)
Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Proc ³ Autor ³Eduardo Riera          ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento da tabela de preco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Oms010Proc()

Local aArea     := GetArea()
Local aParam    := {}

Local cQuery    := ""
Local cArqInd   := ""
Local cCursor   := "DA1"
Local cCursorSC6:= "SC6"
Local cCursorSCK:= "SCK"
Local cUltProc  := ""

Local lQuery    := .F.
Local lContinua := .F.
Local lAtualiza := .F.
Local nIndex    := 0
Local nLoop     := 0
Local nPPrUnit  := 0
Local nPPrcVen  := 0
Local nPValDesc := 0
Local nPDesc    := 0
Local nPValor   := 0

PRIVATE aHeader := {}
PRIVATE aCols   := {}
PRIVATE N       := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de parametrizacao de lancamentos    ³
//³                                                      ³
//³ MV_PAR01 Produto inicial?                            ³
//³ MV_PAR02 Produto final  ?                            ³
//³ MV_PAR03 Grupo inicial  ?                            ³
//³ MV_PAR04 Grupo final    ?                            ³
//³ MV_PAR05 Tipo inicial   ?                            ³
//³ MV_PAR06 Tipo final     ?                            ³
//³ MV_PAR07 Tabela inicial ?                            ³
//³ MV_PAR08 Tabela final   ?                            ³
//³ MV_PAR09 Fator          ?                            ³
//³ MV_PAR10 Numero decimais?                            ³
//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
//³ MV_PAR12 Reaplicar fator?                            ³
//³ MV_PAR13 Planilha       ?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva parametros da rotina                            ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aParam := {}
For nLoop := 1 To 20 
	AAdd( aParam, &( "MV_PAR" + StrZero( nLoop, 2 ) ) )
Next nLoop
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa a atualizacao da tabela de preco             ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DA1")
dbSetOrder(1)
#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cCursor:= "T_Oms010Rej"
		lQuery := .T.
		cQuery := "SELECT * "
		cQuery += "FROM "+RetSqlName("DA1")+" DA1,"
		cQuery += RetSqlName("SB1")+" SB1 "
		cQuery += "WHERE DA1.DA1_FILIAL='"+xFilial("DA1")+"' AND "
		cQuery += "DA1.DA1_CODPRO >= '"+MV_PAR01+"' AND "
		cQuery += "DA1.DA1_CODPRO <= '"+MV_PAR02+"' AND "
		cQuery += "DA1.DA1_CODTAB >= '"+MV_PAR07+"' AND "
		cQuery += "DA1.DA1_CODTAB <= '"+MV_PAR08+"' AND "
		cQuery += "DA1.D_E_L_E_T_=' ' AND "
		cQuery += "SB1.B1_COD = DA1.DA1_CODPRO AND "		
		cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		cQuery += "SB1.B1_GRUPO>='"+MV_PAR03+"' AND "
		cQuery += "SB1.B1_GRUPO<='"+MV_PAR04+"' AND "	
		cQuery += "SB1.B1_TIPO>='"+MV_PAR05+"' AND "
		cQuery += "SB1.B1_TIPO<='"+MV_PAR06+"' AND "
		cQuery += "SB1.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursor,.T.,.T.)
		
	Else
#ENDIF
		cArqInd := CriaTrab(,.F.)
		
		cQuery := "DA1_FILIAL=='"+xFilial("DA1")+"' .AND. "
		cQuery += "DA1_CODPRO>='"+MV_PAR01+"' .AND. "
		cQuery += "DA1_CODPRO<='"+MV_PAR02+"' .AND. "
		cQuery += "DA1_CODTAB>='"+MV_PAR07+"' .AND. "
		cQuery += "DA1_CODTAB<='"+MV_PAR08+"'"
		
		IndRegua("DA1",cArqInd,IndexKey(),,cQuery)	
		nIndex := RetIndex("DA1")		
		#IFNDEF TOP		
			dbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGotop()
#IFDEF TOP
	EndIf
#ENDIF
ProcRegua(DA1->(LastRec()))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis de parametrizacao de lancamentos    ³
//³                                                      ³
//³ MV_PAR01 Produto inicial?                            ³
//³ MV_PAR02 Produto final  ?                            ³
//³ MV_PAR03 Grupo inicial  ?                            ³
//³ MV_PAR04 Grupo final    ?                            ³
//³ MV_PAR05 Tipo inicial   ?                            ³
//³ MV_PAR06 Tipo final     ?                            ³
//³ MV_PAR07 Tabela inicial ?                            ³
//³ MV_PAR08 Tabela final   ?                            ³
//³ MV_PAR09 Fator          ?                            ³
//³ MV_PAR10 Numero decimais?                            ³
//³ MV_PAR11 Pedido em Carteira? Sim/Nao                 ³
//³ MV_PAR12 Reaplicar fator?                            ³
//³ MV_PAR13 Planilha       ?                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva parametros da rotina                            ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aParam := {}
For nLoop := 1 To 20 
	AAdd( aParam, &( "MV_PAR" + StrZero( nLoop, 2 ) ) )
Next nLoop

dbSelectArea(cCursor)
While ( !Eof() )
	lContinua := .F.
	If !lQuery
		If 	(cCursor)->DA1_CODPRO >= aParam[1] .And.;
			(cCursor)->DA1_CODPRO <= aParam[2] .And.;
			(cCursor)->DA1_CODTAB >= aParam[7] .And.;
			(cCursor)->DA1_CODTAB <= aPAram[8]

			dbSelectArea("SB1")
			dbSetOrder(1)
			If MsSeek(xFilial("SB1")+(cCursor)->DA1_CODPRO)
				If 	SB1->B1_GRUPO >= aParam[3] .And. ;
					SB1->B1_GRUPO <= aParam[4] .And. ;
					SB1->B1_TIPO >= aParam[5] .And. ;
					SB1->B1_TIPO <= aParam[6]
				
					lContinua := .T.
				EndIf
			EndIf		
		EndIf
	Else
		lContinua := .T.
	EndIf
	If lContinua
		If (cCursor)->DA1_CODTAB+(cCursor)->DA1_CODPRO==cUltProc
			lContinua := .F.
		EndIf
	EndIf
	If lContinua 
		MaRejTabPrc((cCursor)->DA1_CODTAB,(cCursor)->DA1_CODPRO,aParam[9],aParam[10],aParam[12]==1, aParam[13])
		lAtualiza := .T.
	EndIf	
	cUltProc := (cCursor)->DA1_CODTAB+(cCursor)->DA1_CODPRO
	dbSelectArea(cCursor)
	dbSkip()
	IncProc(OemtoAnsi(STR0011)+": "+(cCursor)->DA1_CODTAB)
EndDo
If lQuery
	dbSelectarea(cCursor)
	dbCloseArea()
	dbSelectArea("DA1")
Else
	dbSelectArea("DA1")
	RetIndex("DA1")
	Ferase(cArqInd+OrdBagExt())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa a atualizacao dos pedidos de venda           ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aParam[11] == 1 .And. lAtualiza	
	ProcRegua(SC6->(LastRec()))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do aHeader para utilizacao da funcoes do PV  ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC6")
	While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
		If ( X3USO(SX3->X3_USADO) .And.;
				!(	Trim(SX3->X3_CAMPO) == "C6_NUM" ) 	.And.;
				Trim(SX3->X3_CAMPO) <> "C6_QTDEMP" 	.And.;
				Trim(SX3->X3_CAMPO) <> "C6_QTDENT" 	.And.;
				cNivel >= SX3->X3_NIVEL )
			Aadd(aHeader,{ TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	
	dbSelectArea("SC6")
	dbSetOrder(1)
	#IFDEF TOP
		lQuery := .T.
		cCursorSC6 := "T_OMS010REJ"
		cQuery := "SELECT SC6.C6_NUM,SC6.C6_FILIAL,SC6.R_E_C_N_O_ SC6RECNO,SC5.R_E_C_N_O_ SC5RECNO "
		cQuery += "FROM "+RetSqlName("SC6")+" SC6, "
		cQuery += RetSqlName("SB1")+" SB1, "		
		cQuery += RetSqlName("SC5")+" SC5  "
		cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
		cQuery += "SC6.C6_QTDVEN-SC6.C6_QTDENT>0 AND "
		cQuery += "SC6.C6_BLQ NOT IN ('R ') AND "
		cQuery += "SC6.C6_PRUNIT <> 0 AND "
		cQuery += "SC6.C6_PRODUTO>='"+aParam[01]+"' AND "
		cQuery += "SC6.C6_PRODUTO<='"+aParam[02]+"' AND "		
		cQuery += "SC6.D_E_L_E_T_ = ' ' AND "
		cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "	
		cQuery += "SB1.B1_COD = SC6.C6_PRODUTO AND "
		cQuery += "SB1.B1_GRUPO>='"+aParam[03]+"' AND "
		cQuery += "SB1.B1_GRUPO<='"+aParam[04]+"' AND "
		cQuery += "SB1.B1_TIPO>='"+aParam[05]+"' AND "
		cQuery += "SB1.B1_TIPO<='"+aParam[06]+"' AND "
		cQuery += "SB1.D_E_L_E_T_ = ' ' AND "
		cQuery += "SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "	
		cQuery += "SC5.C5_NUM = SC6.C6_NUM AND "
		cQuery += "SC5.C5_TABELA>='"+aParam[07]+"' AND "
		cQuery += "SC5.C5_TABELA<='"+aParam[08]+"' AND "		
		cQuery += "SC5.C5_TIPO NOT IN ('C','I','P') AND "
		cQuery += "SC5.D_E_L_E_T_ = ' ' "
			
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursorSC6)		
	#ELSE
		MsSeek(xFilial("SC6"))
	#ENDIF
	While !Eof() .And. xFilial("SC6") == (cCursorSC6)->C6_FILIAL
		lAtualiza := .F.
		If !lQuery
			If (cCursorSC6)->C6_BLQ <> 'R  ' .And.;
				(cCursorSC6)->C6_PRUNIT <> 0 .And.;
				(cCursorSC6)->C6_QTDVEN-(cCursorSC6)->C6_QTDENT > 0 .And.;
				(cCursorSC6)->C6_PRODUTO >= aParam[01] .And.;
				(cCursorSC6)->C6_PRODUTO <= aParam[02]
				SB1->(dbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1")+(cCurSorSC6)->C6_PRODUTO))					
				SC5->(dbSetOrder(1))
				SC5->(MsSeek(xFilial("SC5")+(cCurSorSC6)->C6_NUM))	
				If !SC5->C5_TIPO $ "CIP" .And.;
					SB1->B1_GRUPO >= aParam[03] .And.;
					SB1->B1_GRUPO <= aParam[04] .And.;
					SB1->B1_TIPO >= aParam[05] .And.;
					SB1->B1_TIPO <= aParam[06] .And.;				
					SC5->C5_TABELA >= aParam[07] .And.;
					SC5->C5_TABELA <= aParam[08]
					lAtualiza := .T.
				EndIf
			EndIf
		Else
			SC5->(MsGoto((cCursorSC6)->SC5RECNO))
			SC6->(MsGoto((cCursorSC6)->SC6RECNO))
			lAtualiza := .T.
		EndIf
	 	If lAtualiza
	 		Begin Transaction
	 		If RecLock("SC5")
	 			RegToMemory("SC5",.F.,.F.)
	 			If RecLock("SC6")
	 				aCols := {}
	 				aadd(aCols,Array(Len(aHeader)+1))
	 				aCols[1][Len(aHeader)+1] := .F.
	 				For nLoop := 1 To Len(aHeader)
		 					Do Case
	 							Case AllTrim(aHeader[nLoop][2]) == "C6_PRUNIT"
	 								nPPrUnit := nLoop
	 							Case AllTrim(aHeader[nLoop][2]) == "C6_PRCVEN"
	 								nPPrcVen := nLoop
	 							Case AllTrim(aHeader[nLoop][2]) == "C6_VALDESC"
	 								nPValDesc := nLoop
	 							Case AllTrim(aHeader[nLoop][2]) == "C6_DESCONT"
		 							nPDesc := nLoop
	 							Case AllTrim(aHeader[nLoop][2]) == "C6_VALOR"
		 							nPValor:= nLoop
		 					EndCase	   
		 					If aHeader[nLoop][10] <> "V"					
		 						aCols[1][nLoop] := SC6->(FieldGet(ColumnPos(aHeader[nLoop][2])))
		 					Endif	
	 					Next nLoop
	 				M->C6_PRUNIT := MaTabPrVen(SC5->C5_TABELA,SC6->C6_PRODUTO,1,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_MOEDA,SC5->C5_EMISSAO)
					A410MultT("C6_PRUNIT",M->C6_PRUNIT)
	 				aCols[1][nPPrunit] := M->C6_PRUNIT
	 				SC6->C6_PRUNIT     := aCols[1][nPPrUnit]
	 				SC6->C6_PRCVEN     := aCols[1][nPPrcVen]
	 				SC6->C6_VALDESC    := aCols[1][nPValDesc]
	 				SC6->C6_DESCONT    := aCols[1][nPDesc]
	 				SC6->C6_VALOR      := aCols[1][nPValor]	 				
				EndIf				
			EndIf
			End Transaction
	 	EndIf
		dbSelectArea(cCursorSC6)
		dbSkip()
		IncProc(OemtoAnsi(STR0014)+": "+(cCursorSC6)->C6_NUM) //"Pedido"
	EndDo	
	If lQuery
		dbSelectArea(cCursorSC6)
		dbCloseArea()
		dbSelectArea("SC6")
	EndIf
	
	If mv_Parxx == "3"

		dbSelectArea("SCK")
		dbSetOrder(1)
		#IFDEF TOP
			lQuery := .T.
			cCursorSCK := "T_OMS010REJ"
			cQuery := "SELECT SCK.CK_NUM,SCK.CK_FILIAL,SCK.R_E_C_N_O_ SCKRECNO,SCJ.R_E_C_N_O_ SCJRECNO "
			cQuery += "FROM "+RetSqlName("SCK")+" SCK, "
			cQuery += RetSqlName("SB1")+" SB1, "		
			cQuery += RetSqlName("SCJ")+" SCJ  "
			cQuery += "WHERE SCK.CK_FILIAL='"+xFilial("SCK")+"' AND "
			cQuery += "SCK.CK_PRUNIT <> 0 AND "
			cQuery += "SCK.CK_PRODUTO>='"+aParam[01]+"' AND "
			cQuery += "SCK.CK_PRODUTO<='"+aParam[02]+"' AND "		
			cQuery += "SCK.D_E_L_E_T_ = ' ' AND "
			cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "	
			cQuery += "SB1.B1_COD = SCK.CK_PRODUTO AND "
			cQuery += "SB1.B1_GRUPO>='"+aParam[03]+"' AND "
			cQuery += "SB1.B1_GRUPO<='"+aParam[04]+"' AND "
			cQuery += "SB1.B1_TIPO>='"+aParam[05]+"' AND "
			cQuery += "SB1.B1_TIPO<='"+aParam[06]+"' AND "
			cQuery += "SB1.D_E_L_E_T_ = ' ' AND "
			cQuery += "SCJ.CJ_FILIAL='"+xFilial("SCJ")+"' AND "	
			cQuery += "SC5.CJ_NUM = SCK.CK_NUM AND "
			cQuery += "SCJ.CJ_TABELA>='"+aParam[07]+"' AND "
			cQuery += "SCJ.CJ_TABELA<='"+aParam[08]+"' AND "		
			cQuery += "SCJ.CJ_TIPO NOT IN ('B','E') AND "
			cQuery += "SCJ.D_E_L_E_T_ = ' ' "
				
			cQuery := ChangeQuery(cQuery)
	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCursorSCK)		
		#ELSE
			MsSeek(xFilial("SCJ"))
		#ENDIF

		While !Eof() .And. xFilial("SCJ") == (cCursorSCK)->CK_FILIAL

			lAtualiza := .F.
			If !lQuery
				If 	(cCursorSCK)->CK_PRUNIT <> 0 .And.;
					(cCursorSCK)->CK_QTDVEN > 0 .And.;
					(cCursorSCK)->CK_PRODUTO >= aParam[01] .And.;
					(cCursorSCK)->CK_PRODUTO <= aParam[02]

					SB1->(dbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+(cCurSorSCK)->CK_PRODUTO))					
					SCK->(dbSetOrder(1))
					SCK->(MsSeek(xFilial("SCK")+(cCurSorSCK)->CK_NUM))	
					If !SCK->CK_TIPO $ "CIP" .And.;
						SB1->B1_GRUPO >= aParam[03] .And.;
						SB1->B1_GRUPO <= aParam[04] .And.;
						SB1->B1_TIPO >= aParam[05] .And.;
						SB1->B1_TIPO <= aParam[06] .And.;				
						SCK->CK_TABELA >= aParam[07] .And.;
						SCK->CK_TABELA <= aParam[08]
						lAtualiza := .T.
					EndIf
	
	
				Endif
			Endif	

			dbSelectArea(cCursorSCK)
			dbSkip()
			IncProc(OemtoAnsi(STR0014)+": "+(cCursorSCK)->CK_NUM) //"Pedido"
			
		Enddo	
	
	Endif
	
	
EndIf
RestArea(aArea)    
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaRejTabPrc³ Autor ³ Eduardo Riera         ³ Data ³07.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de reajuste da tabela de preco                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Numerico (Preco de Venda)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tabela de Preco                                      ³±±
±±³          ³ExpC2: Codigo do Produto                                    ³±±
±±³          ³ExpN3: Fator                                                ³±±
±±³          ³ExpN4: Decimais a serem consideradas                        ³±±
±±³          ³ExpL5: Aplica fator no preco base para calculo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaRejTabPrc(cCodTab,cCodPro,nFator,nDecimais,lFator,cPlanilha)

Local aArea    := GetArea()
Local aAreaDA0 := DA0->(GetArea())
Local aAreaDA1 := DA1->(GetArea())
Local nBase    := 0
Local nPrcAnt  := 0
Local lPReaj   := ExistBlock("OS010REJ")


DEFAULT nDecimais := TamSx3("DA1_PRCVEN")[2]
DEFAULT lFator    := .F.
DEFAULT cPlanilha := ""

If !Empty(cPlanilha)                                             
	Pergunte("MTC010",.F.)
Endif	

dbSelectArea("DA1")
dbSetOrder(1)
If MsSeek(xFilial("DA1")+cCodTab+cCodPro)

	While !Eof() .And. DA1->DA1_FILIAL == xFilial("DA1") .And.;
		DA1->DA1_CODTAB == cCodTab .And. DA1->DA1_CODPRO == cCodPro

		Begin Transaction

		nBase   := DA1->DA1_PRCVEN                         
		nPrcAnt := DA1->DA1_PRCVEN					
		
		If lFator
			dbSelectArea("SB1")
			dbSetOrder(1)
			If MsSeek(xFilial("SB1")+cCodPro)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza pela planilha de formacao de precos          ³ 
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cPlanilha)
				 	nBase := MaPrcPlan(cCodPro,cPlanilha,cCodTab)				 	
				Else
					nBase := SB1->B1_PRV1
				EndIf
					
					If DA1->DA1_PERDES > 0
				nFator*= DA1->DA1_PERDES
		    EndIf
											
			    EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza pela planilha de formacao de precos          ³ 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cPlanilha)
				nBase := MaPrcPlan(cCodPro,cPlanilha,cCodTab)				
			EndIf
		EndIf
		
        RecLock("DA1")
	        DA1->DA1_PRCVEN := If(nFator > 0, NoRound(nBase * nFator,nDecimais), nBase )
        MsUnLock()
        
		End Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para atualizacao de precos           ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPReaj
			ExecBlock("OS010REJ",.F.,.F.,{nPrcAnt, DA1->DA1_PRCVEN})
		Endif	
        
		dbSelectArea("DA1")
		dbSkip()
	EndDo

EndIf

If !Empty(cPlanilha)                                             
	Pergunte("OMS010",.F.)
Endif	

RestArea(aAreaDA1)
RestArea(aAreaDA0)
RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaPrcPlan  ³ Autor ³Henry Fila             ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca preco de acordo com a planilha de precos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Produto                                              ³±±
±±³          ³ExpC2: Planilha                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Preco                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MaPrcPlan(cProduto,cPlanilha,cCodTab)

Local nPreco := 0
Local aArray := {}
Local nX     := 0

Private cArqMemo   := cPlanilha
Private lDirecao   := .T.  
Private nQualCusto := 1
Private cProg      := "R430"

If !Empty(cPlanilha)
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		cArqMemo := cPlanilha
		aArray   := MC010Forma("SB1",SB1->(RecNo()),98)
	Endif	
Endif		

If ValType(aArray) <> "A"
	aArray := {}
Endif	

For nX := 1 To Len(aArray)
	nPos := At("#"+cCodTab,aArray[nX][3])	
	If nPos > 0
		nPreco := aArray[nX][6]
		Exit		
	EndIf
Next nX

Return(nPreco)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MATABPRVEN ³ Autor ³ Henry Fila            ³ Data ³ 20.04.00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para trazer preco de venda de acordo com a qtde      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Numerico (Preco de Venda)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tabela de Preco                                      ³±±
±±³          ³ExpC2: Codigo do Produto                                    ³±±
±±³          ³ExpN3: Quantidade                                           ³±±
±±³          ³ExpC4: Cliente                                              ³±±
±±³          ³ExpC5: Loja                                                 ³±±
±±³          ³ExpN6: Moeda a ser retornada                                ³±±
±±³          ³ExpN7: Tipo                                                 ³±±
±±³          ³       1 = Preco (Default)                                  ³±±
±±³          ³       2 = Fator de acrescimo ou desconto                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaTabPrVen(cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,dDataVld,nTipo,lExec)

Static cMvEstado
Static cMvNorte

Local aArea     := GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local aStruDA1  := {}

Local cTpOper   := ""
Local cQuery    := ""
Local cAliasDA1 := "DA1"
                              
Local nPrcVen   := 0
Local nResult   := 0
Local nMoedaTab := 1
Local nScan     := 0
Local nY        := 0
Local cMascara  := SuperGetMv("MV_MASCGRD")      
Local nTamProd  := Len(SB1->B1_COD)
Local nFator    := 0

Local lUltResult:= .T.
Local lQuery    := .F.
Local lProcessa := .F.
Local lGrade    := MaGrade()
Local lGradeReal:= .F.
Local lPrcDA1   := .F.

DEFAULT cMvEstado := GetMv("MV_ESTADO")
DEFAULT cMvNorte  := GetMv("MV_NORTE")
DEFAULT nMoeda    := 1
DEFAULT aUltResult:= {}                                                    
DEFAULT dDataVld  := dDataBase
DEFAULT nTipo     := 1
DEFAULT lExec     := .T.

If lGrade .And.	MatGrdPrrf(@cProduto)
	nTamProd := Val(Substr(cMascara,1,2))
	lGradeReal:= .T.	
Endif

If ExistBlock("OM010PRC") .And. lExec
	nResult := ExecBlock("OM010PRC",.F.,.F.,{cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,dDataVld,nTipo})
Else

	nScan := aScan(aUltResult,{|x| x[1] == cTabPreco .And.;
		x[2] == cProduto .And.;
		x[3] == nQtde .And.;
		x[4] == cCliente .And.;
		x[5] == cLoja .And.;
		x[6] == nMoeda .And.;
		x[7] == cFilAnt})
	
	If nScan == 0
	
		If !(Empty(cCliente) .And. nQtde == 0 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Acho o tipo de operacao para busca do preco de venda³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA1")
			dbSetOrder(1)
			If MsSeek(xFilial("SA1")+cCliente+cLoja)
				Do Case
					Case SA1->A1_EST == cMvEstado
						cTpOper := "1"
					Case SA1->A1_EST != cMvEstado
						If (SA1->A1_EST $ cMvNorte) .And. !(cMvEstado $ cMvNorte)
							cTpOper := "3"
						Else
							cTpOper := "2"
						EndIf						
				EndCase					
			EndIf												
		Endif	
	
		dbSelectarea("DA1")
		dbSetOrder(1)
	
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				lQuery    := .T.
				cAliasDA1 := "QRYDA1"
				aStruDA1  := DA1->(dbStruct())
				
				cQuery := "SELECT * "
				cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
				cQuery += "WHERE "
				cQuery += "DA1_FILIAL = '"+xFilial("DA1")+"' AND "
				cQuery += "DA1_CODTAB = '"+cTabPreco+"' AND "
	
				If lGradeReal
					cQuery += "DA1_CODPRO LIKE '"+cProduto+"%' AND "
				Else 
					cQuery += "DA1_CODPRO = '"+cProduto+"' AND "			
				Endif	                                 
	
				cQuery += "DA1_QTDLOT >= "+Str(nQtde,18,8)+" AND "
				cQuery += "DA1_ATIVO = '1' AND  "			
				
	    		cQuery += "( DA1_DATVIG <= '"+DtoS(dDataVld)+ "' OR DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) AND "
				
				If !(nQtde == 0 .And. Empty(cCliente))
					cQuery += "( DA1_TPOPER = '"+cTpOper+"' OR DA1_TPOPER = '4' ) AND "
				Endif                     
				
				cQuery += "DA1.D_E_L_E_T_ = ' ' "
				cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))
				
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)
				
				For nY := 1 To Len(aStruDA1)
					If aStruDA1[nY][2]<>"C"
						TcSetField(cAliasDA1,aStruDA1[nY][1],aStruDA1[nY][2],aStruDA1[nY][3],aStruDA1[nY][4])
					EndIf
				Next nY
	
				If (cAliasDA1)->(!Eof())
					lProcessa := .T.
				Endif				
			
			Else
		#ENDIF
				dbSelectarea("DA1")
				dbSetOrder(1)
				If MsSeek(xFilial("DA1")+ cTabPreco + cProduto)   
					lProcessa := .T.
				Endif				
				
		#IFDEF TOP
			Endif
		#ENDIF
								
	   	If lProcessa
		
			If nQtde == 0 .And. Empty(cCliente)
				nPrcVen   := (cAliasDA1)->DA1_PRCVEN
				nMoedaTab := (cAliasDA1)->DA1_MOEDA
				nFator    := (cAliasDA1)->DA1_PERDES
				
				lPrcDA1   := .T.
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco o preco e analiso a qtde de acordo com a faixa³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasDA1)
				While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
									(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
									Left((cAliasDA1)->DA1_CODPRO,nTamProd) ==  cProduto
	
					If nQtde <= (cAliasDA1)->DA1_QTDLOT .And. (cAliasDA1)->DA1_ATIVO == "1"
					
						If Empty((cAliasDA1)->DA1_ESTADO) .And. ((cAliasDA1)->DA1_TPOPER == cTpOper .Or. (cAliasDA1)->DA1_TPOPER == "4")				
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica a vigencia do item                                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							nQtdLote := (cAliasDA1)->DA1_QTDLOT
							
							While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
																(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
																Left((cAliasDA1)->DA1_CODPRO,nTamProd) ==  cProduto .And.;
																(cAliasDA1)->DA1_QTDLOT == nQtdLote .And.;
																(cAliasDA1)->DA1_DATVIG <= dDataVld .And. !lPrcDA1
								If nQtde <= (cAliasDA1)->DA1_QTDLOT															
									
									nPrcVen   := (cAliasDA1)->DA1_PRCVEN
									nMoedaTab := (cAliasDA1)->DA1_MOEDA 
									nFator    := (cAliasDA1)->DA1_PERDES
	
									lPrcDA1   := .T.
									Exit
	       						Endif
												
								dbSelectArea(cAliasDA1)
								dbSkip()
					        Enddo
	
						ElseIf !Empty((cAliasDA1)->DA1_ESTADO) .And. ( SA1->A1_EST == (cAliasDA1)->DA1_ESTADO )
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica a vigencia do item                                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							nQtdLote := (cAliasDA1)->DA1_QTDLOT
							
							While (cAliasDA1)->(!Eof()) .And. (cAliasDA1)->DA1_FILIAL == xFilial("DA1") .And.;
																	(cAliasDA1)->DA1_CODTAB == cTabPreco .And.;
																	Left((cAliasDA1)->DA1_CODPRO,nTamProd) ==  cProduto .And.;
																	(cAliasDA1)->DA1_QTDLOT == nQtdLote .And.;																
																	(cAliasDA1)->DA1_DATVIG <= dDataVld 
								If nQtde <= (cAliasDA1)->DA1_QTDLOT
		
									nPrcVen   := (cAliasDA1)->DA1_PRCVEN
									nMoedaTab := (cAliasDA1)->DA1_MOEDA
									nFator    := (cAliasDA1)->DA1_PERDES
		
									lPrcDA1   := .T.
									
									Exit
								Endif									
									
								dbSelectArea(cAliasDA1)
								dbSkip()
					        Enddo
	
							If lPrcDA1
								Exit
							Endif	 
							
						EndIf									
					EndIf						
					dbSelectArea(cAliasDA1)
					dbSkip()
				Enddo	     
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente atualiza com o SB1 caso nao tenha achado nenhuma tabela    ³
				//³caso contrario retornara o preco zerado                            ³			
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			                                  
				If nTipo == 1
					If nPrcVen == 0 .And. !lPrcDA1
						dbSelectArea("SB1")
						dbSetOrder(1)
						If MsSeek(xFilial("SB1")+cProduto)
							nPrcVen := SB1->B1_PRV1
						EndIf
						lUltResult := .F.
					Endif				
				Endif
				
			EndIf
		Else                     
			If nTipo == 1	
				dbSelectArea("SB1")
				dbSetOrder(1)
				If MsSeek(xFilial("SB1")+cProduto)
					nPrcVen := SB1->B1_PRV1
				EndIf
			Endif	
			lUltResult := .F.
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o tipo for para trazer preco converte para a moeda    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		nFator := Iif( nFator == 0, 1, nFator )	
		
		If nTipo == 1
			nResult := xMoeda(nPrcVen,nMoedaTab,nMoeda,,TamSx3("D2_PRCVEN")[2])
		Else 
			nResult	:= nFator
		Endif
		
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guarda os ultimos resultados                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUltResult
			aadd(aUltResult,{cTabPreco,cProduto,nQtde,cCliente,cLoja,nMoeda,cFilAnt,nResult,nFator})
			If Len(aUltResult) > MAXSAVERESULT
				aUltResult := aDel(aUltResult,1)
				aUltResult := aSize(aUltResult,MAXSAVERESULT)
			EndIf
		EndIf
	Else
	
		If nTipo == 1
			nResult := aUltResult[nScan][8]
		Else                               
			nResult := aUltResult[nScan][9]	
		Endif	
	EndIf                                           
Endif	
If lQuery
	dbSelectArea(cAliasDA1)
	dbCloseArea()
	dbSelectArea("DA1")
Endif	

RestArea(aAreaSB1)
RestArea(aArea)
Return(nResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MaVldTabPrc³ Autor ³Eduardo Riera          ³ Data ³03.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da tabela de precos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Tabela valida                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tabela de Preco                                      ³±±
±±³          ³ExpC2: Condicao de Pagamento                                ³±±
±±³          ³ExpN3: Help                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                     
/*
Static Function MaVldTabPrc(cCodTab,cCondPag,cHelp,dDataVld)

Local aArea   := GetArea()
Local lValido := .T.                                
Local lTabLoja:= cPaisLoc != "BRA" .And. nModulo == 12

DEFAULT dDataVld := dDataBase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a vigencia da tabela de precos                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DA0")
dbSetOrder(1)
If MsSeek(xFilial("DA0")+cCodTab)
	If !( SubtHoras(dDataVld,Time(),If(Empty(DA0->DA0_DATATE),dDataVld,DA0->DA0_DATATE),DA0->DA0_HORATE) > 0 .And.;
		SubtHoras(DA0->DA0_DATDE,DA0->DA0_HORADE,dDataVld,Time()) > 0 ) .Or.DA0->DA0_ATIVO == "2"
		If Empty(cHelp)
			Help(" ",1,"OMSTABPRC1")
		Else
			cHelp := "OMSTABPRC1"
		EndIf
		lValido := .F.
	Else
		If !Empty(cCondPag) .And. !Empty(DA0->DA0_CONDPG) .And. cCondPag <> DA0->DA0_CONDPG
			If Empty(cHelp)
				Help(" ",1,"OMSTABPRC2")
			Else
				cHelp := "OMSTABPRC2"
			EndIf
			lValido := .F.
		EndIf
	EndIf
ElseIf !lTabLoja
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a tabela nao esta em branco e nao e' tabela 1              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cCodTab) .And. cCodTab <> PadR( "1", Len( DA0->DA0_CODTAB ) )  
		If Empty(cHelp)
			Help(" ",1,"REGNOIS")
		Else
			cHelp := "REGNOIS"
		EndIf
		lValido := .F.		
	EndIf
EndIf
RestArea(aArea)
Return(lValido)
  */
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Leg  ³ Autor ³Henry Fila             ³ Data ³30.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda das tabelas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function Oms010Leg()

Local aLegenda := { { "BR_VERMELHO"  , OemToAnsi( STR0016 ) },; 
					{ "BR_VERDE"    , OemToAnsi( STR0017) },;  
					{ "BR_LARANJA"  , OemToAnsi( STR0018) } }

BrwLegenda( cCadastro, OemToAnsi( "Status" ), aLegenda  ) //"Somente faturada e nao acertada"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010Hora ³ Autor ³Henry Fila             ³ Data ³30.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao das horas no cabecalho da tabela de precos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
/*
Static Function Oms010Hora()

Local lRet := .T.

If !Empty( M->DA0_DATATE ) .And. ( M->DA0_DATDE == M->DA0_DATATE ) .And.;
    !Empty(M->DA0_HORATE)
	
	If M->DA0_HORATE < M->DA0_HORADE
		Help(" ",1,"OMS010HORA")
		lRet := .F.
	Endif	
Endif

Return(lRet)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MaReleTabPrcºAutor  ³Marcelo Kotaki    º Data ³  11/26/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Essa funcao limpa o conteudo do array com os precos da      º±±
±±º          ³ultima tabela de preco                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Static Function MaReleTabPrc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa buffer                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aUltResult := Nil

Return(.T.)
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os010CanDel³ Autor ³Henry Fila             ³ Data ³07.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a tabela de precos pode ser excluida            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. (pode ser excluida) ou .F. (nao pode                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo da tabela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Os010CanDel(cCodTab)


Local cAliasACO := "ACO"
Local cAliasACQ := "ACQ"
Local cAliasACT := "ACT"

Local lRet      := .T.

#IFDEF TOP
	Local cQuery    := ""
#ENDIF	

#IFDEF TOP  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de desconto                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           
	lQuery    := .T.
	cAliasACO := "QRYACO"

	cQuery    := "SELECT COUNT(*) QTDREC FROM "  
	cQuery    += RetSqlName("ACO")+ " ACO "
	cQuery    += " WHERE "
	cQuery    += "( ACO_FILIAL ='"+xFilial("ACO")+"' AND "
	cQuery    += "ACO_CODTAB = '"+cCodTab+"' AND "
	cQuery    += "ACO.D_E_L_E_T_ = ' ' ) "

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACO,.T.,.T.)
    
    If (cAliasACO)->QTDREC > 0
    	lRet := .F.
    Endif

	(cAliasACO)->(dbCloseArea())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de bonificacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lRet

		cAliasACQ := "QRYACQ"
	
		cQuery    := "SELECT COUNT(*) QTDREC FROM "  
		cQuery    += RetSqlName("ACQ")+ " ACQ "
		cQuery    += " WHERE "
		cQuery    += "( ACQ_FILIAL ='"+xFilial("ACQ")+"' AND "
		cQuery    += "ACQ_CODTAB = '"+cCodTab+"' AND "
		cQuery    += "ACQ.D_E_L_E_T_ = ' ' ) "
	
	    cQuery := ChangeQuery(cQuery)
	    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACQ,.T.,.T.)
	    
	    If (cAliasACQ)->QTDREC > 0
	    	lRet := .F.
	    Endif                    
	    
    	(cAliasACQ)->(dbCloseArea())
	
	Endif    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de negocio                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		cAliasACT := "QRYACT"
	
		cQuery    := "SELECT COUNT(*) QTDREC FROM "  
		cQuery    += RetSqlName("ACT")+ " ACT "
		cQuery    += " WHERE "
		cQuery    += "( ACT_FILIAL ='"+xFilial("ACT")+"' AND "
		cQuery    += "ACT_CODTAB = '"+cCodTab+"' AND "
		cQuery    += "ACT.D_E_L_E_T_ = ' ' ) "
	
	    cQuery := ChangeQuery(cQuery)
	    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACT,.T.,.T.)
	    
	    If (cAliasACT)->QTDREC > 0
	    	lRet := .F.
	    Endif                    
	    
    	(cAliasACT)->(dbCloseArea())
	
	Endif    


#ELSE             

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de desconto                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	(cAliasACO)->(dbSetOrder(1))
	(cAliasACO)->(MsSeek(xFilial("ACO")))
	
	While (cAliasACO)->(!Eof()) .And. (cAliasACO)->ACO_FILIAL == xFilial("ACO") .And. lRet
		
	
		If (cAliasACO)->ACO_CODTAB == cCodTab
			lRet := .F.
		Endif	
	     
		ACO->(dbSkip())
		
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de bonificacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		(cAliasACQ)->(dbSetOrder(1))
		(cAliasACQ)->(MsSeek(xFilial("ACQ")))
		
		While (cAliasACQ)->(!Eof()) .And. (cAliasACQ)->ACQ_FILIAL == xFilial("ACQ") .And. lRet
			
		
			If (cAliasACQ)->ACQ_CODTAB == cCodTab
				lRet := .F.
			Endif	
		     
			ACQ->(dbSkip())
			
		EndDo
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica regras de negocio                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		(cAliasACT)->(dbSetOrder(1))
		(cAliasACT)->(MsSeek(xFilial("ACT")))
		
		While (cAliasACT)->(!Eof()) .And. (cAliasACT)->ACT_FILIAL == xFilial("ACT") .And. lRet
			
		
			If (cAliasACT)->ACT_CODTAB == cCodTab
				lRet := .F.
			Endif	
		     
			ACT->(dbSkip())
			
		EndDo
		
	Endif

	
#ENDIF

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Oms010Vld ³ Autor ³ Henry Fila            ³ Data ³ 01/04/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da tabela quando for por produto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Oms010Vld()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function Oms010Vld()

Local aArea      := GetArea()
Local aAreaDA1   := DA1->(GetArea())
Local aAreaDA0   := DA0->(GetArea())
Local aItens     := {}

Local cItem      := ""

Local nX         := 0
Local nPosCod    := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_CODTAB"})
Local nPosTabela := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_DESTAB"})
Local nPosItem   := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_ITEM"})
Local nPosPrc    := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA1_PRCBAS"})
Local lRet       := .T. 

SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+mv_par02))    
	aCols[n][nPosPrc] := SB1->B1_PRV1
Endif	

DA0->(dbsetOrder(1))
If DA0->(MsSeek(xFilial("DA0")+M->DA1_CODTAB))
	aCols[n][nPosTabela] := DA0->DA0_DESCRI   
	
	DA1->(dbSetORder(3))
	DA1->(MsSeek(xFilial("DA1")+M->DA1_CODTAB+"ZZZZ",.T.))
	dbSkip(-1)	  
	cItem := Soma1(DA1->DA1_ITEM)

	If aScan(aCols,{|x| Upper(Alltrim(x[nPosCod])) == M->DA1_CODTAB})	> 0
	
		For nX := 1 to Len(aCols)                     
			If !aCols[nX][Len(aHeader)+1]
				If aCols[nX][nPosCod] == M->DA1_CODTAB .And. n <> nX
				
					DA1->(dbSetORder(3))
					If !DA1->(MsSeek(xFilial("DA1")+M->DA1_CODTAB+aCols[nX][nPosItem],.T.))
						cItem := Soma1(cItem)
					Endif	
				Endif
			Endif		
		Next nX
	         
	Endif	

	aCols[n][nPosItem] := cItem

Else
	Help(" ",1,"REGNOIS")
	lRet := .F.	
Endif	

RestArea(aAreaDA0)               
RestArea(aAreaDA1)
RestArea(aArea)

Return(lRet)
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Oms010PFor³ Autor ³ Henry Fila            ³ Data ³17/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara a funcao de copia para evitar que seja chamada a   ³±±
±±³          ³ janela de filiais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do cabecalho do pedido de venda                ³±±
±±³          ³ExpN2: Recno do cabecalho do pedido de venda                ³±±
±±³          ³ExpN3: Opcao do arotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function Oms010PFor(cAlias,nReg,nOpc)

Local aRotBkp := aClone(aRotina)

aRotina := {{ OemToAnsi(STR0013),"T_Oms010For",0,3}}

Oms010For(calias,nReg,1)

aRotina := aClone(aRotBkp)

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

AjTpDroSx1('OMS010','01','Demonstrar por ?','¿Mostrar por  ?','Show by  ?','mv_ch1','N', 1,0,0,'C','',''   ,'','','mv_par01','Tabela','Tabla','Table','','Produto','Producto','Product','','','','','','','','','')
AjTpDroSx1('OMS010','02','Produto        ?','¿Producto     ?','Product  ?','mv_ch2','C',15,0,0,'G','','SB1','','','mv_par02',''      ,''     ,''     ,'',''       ,''        ,''       ,'','','','','','','','','')

Return Nil
//pegar este cara                             
                                                       

//********************************************//
// Função: SelFiliais()                       //
//--------------------------------------------//
// Rotina para a montagem da tela de seleção  //
// das filiais                                //
//********************************************//
Static Function SelFiliais()
Local aStru   		:= {}
Local aCampos 		:= {}
Local cFilialAtiva	:= ""
Local cAliasFiliais := ""
Local lGrava 		:= .F.
Local nRecno		:= 0

	aStru := { { "MARCA" ,"C",02,02 } ,;
	           { "CODEMP","C",02,02 } ,;           
	           { "CODFIL","C",02,02 } ,;
		       { "NOMEMP","C",30,30 } ,; 
	           { "NOMFIL","C",30,30 } }
	           
	AAdd(aCampos,{"MARCA" ,""            ,""   })
	AAdd(aCampos,{"CODEMP","Cod. Empresa","@!" })
	AAdd(aCampos,{"CODFIL","Cod. Filial ","@!" })
	AAdd(aCampos,{"NOMEMP","Nome Empresa","@!" })
	AAdd(aCampos,{"NOMFIL","Nome Filial ","@!" })
	                      
	cMarca     	  := GetMark()
	cArqTrb	      := CriaTrab(aStru,.T.)
	cAliasFiliais := "TRB"+Substr(Time(),4,2)+Substr(Time(),7,2)	
	dbUseArea(.T.,,cArqTrb,cAliasFiliais,.F.)
	                              
	DbSelectArea("DA0")
	cFilialAtiva := xFilial("DA0")
	
	DbSelectArea("SM0") 
	nRecno := SM0->(Recno())
	SM0->(DbSetOrder(1))
	SM0->(DbGoTop())       
	SM0->(DbSeek(CEMPANT))
	While !SM0->(EOF()) .And. (CEMPANT == SM0->M0_CODIGO)
		If cFilialAtiva <> SM0->M0_CODFIL
			RecLock(cAliasFiliais,.T.)
	
			(cAliasFiliais)->MARCA  := cMarca
			(cAliasFiliais)->CODEMP := SM0->M0_CODIGO
			(cAliasFiliais)->CODFIL := SM0->M0_CODFIL
			(cAliasFiliais)->NOMEMP := SM0->M0_NOME
			(cAliasFiliais)->NOMFIL := SM0->M0_FILIAL
			
			(cAliasFiliais)->(MsUnLock())
		EndIf
		SM0->(DbSkip())
	EndDo            
	
	SM0->(DbGoTo(nRecno))
	
	DbSelectArea(cAliasFiliais)
	(cAliasFiliais)->(DbGoTop())
	
	lGrava := .F.
	
	@ 00,00 TO 340,405 DIALOG oDlg TITLE "Escolha as Filiais"
	@ 05,05 SAY "Escolha as Filiais que também receberão uma cópia da Tabela de Preços:"
	@ 17,05 TO 150,200 BROWSE cAliasFiliais FIELDS aCampos MARK "MARCA"
	@ 155,140 BMPBUTTON TYPE 01 ACTION lGrava := GrvFiliais(oDlg,cArqTrb)
	@ 155,170 BMPBUTTON TYPE 02 ACTION (CloseTab(cArqTrb) , Close(oDlg) )
	
	ACTIVATE DIALOG oDlg CENTERED

Return lGrava


//***************************************************//
// Rotina: GrvFiliais()                              //
//---------------------------------------------------//
// Parâmetros:                                       //
//    oDlg -> Objeto diálogo criado para selecionar  //
//            as Filiais                             //
//                                                   //
//---------------------------------------------------//
// Rotina para confirmação da gravação da cópia da   //
// tabela de preços para as Filiais                  //
//***************************************************//
Static Function GrvFiliais(oDlg,cArqTrb)

CloseTab(cArqTrb) 
Close(oDlg)

Return .T.

//-------------------------------------------
/*/{Protheus.doc} CloseTab
Fecha tabelas temporarias
@type		function
@author  	julio.nery
@version 	P12
@since   	16/02/2017
@return  	Nil
/*/
//-------------------------------------------
Static Function CloseTab(cArqTrb)

FErase(cArqTrb)

Return .T.

