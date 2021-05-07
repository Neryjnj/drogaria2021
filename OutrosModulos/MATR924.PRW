#INCLUDE "MATR924.CH"
#INCLUDE "Protheus.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR924   ºAutor  ³Mary C. Hergert     º Data ³ 28/07/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio Livro Especifico para registro de movimentacoes   º±±
±±º          ³de medicamentos controlados pelo Governo.                   º±±
±±º          ³Baseado no MATR470 - Ficha Kardex do Produto                º±±
±±º          ³Apenas quantidades de entrada/saida/estoque, sem valores    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MATR924()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local WnRel
Local Tamanho	:= "G"
Local titulo	:= STR0001	//"Livro de Registro Especifico de Medicamentos"
Local cDesc1	:= STR0002	//"Este programa emitira o Livro de Registro Especifico de Medicamentos, visando o registro"
Local cDesc2	:= STR0003	//"das movimentacoes diarias de medicamentos controlados pelo Governo."
Local cDesc3	:= STR0004	//"Sera impressa uma pagina por medicamento do grupo selecionado"

Local aOrd		:= {STR0005,STR0006} // Em Ordem de: Codigo/Descricao
Local nomeprog	:= "MATR924"
Local cString	:= "SB1"
Local nTipo		:= 0
Local lEnd		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para impressao dos Termos de Abertura e Encerramento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPagina	:= ""
Local cGrupo	:= ""
Local cDtExt	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private para SIGAVEI, SIGAPEC e SIGAOFI       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE xSB1 := ""
PRIVATE xSB2 := ""
PRIVATE xSB5 := ""
PRIVATE xSD1 := ""
PRIVATE xSD2 := ""
PRIVATE xSD3 := ""
PRIVATE xSF4 := ""
PRIVATE xSF1 := ""
PRIVATE xSF2 := ""

PRIVATE aReturn:= { STR0009, 1,STR0010, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE aLinha := { },nLastKey := 0
PRIVATE cPerg  := "MTR924"
PRIVATE nPaginas:=0
PRIVATE bBloco := { |nV,nX| Trim(nV)+IIf(Valtype(nX)='C',"",Str(nX,1)) }
PRIVATE aDriver:= ReadDriver()

Static cTpProd	:= "" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTR924",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                    ³
//³ mv_par01        // Do produto                                           ³
//³ mv_par02        // Ate o produto                                        ³
//³ mv_par03        // Do Grupo                                             ³
//³ mv_par04        // Da data                                              ³
//³ mv_par05        // Ate a data                                           ³
//³ mv_par06        // Lista produtos s/movim                               ³
//³ mv_par07        // Qual Local (almoxarifado)                            ³
//³ mv_par08        // Pagina Inicial                                       ³
//³ mv_par09        // Nr do Livro                                          ³
//³ mv_par10        // Livro / Livro+Termos / Termos                        ³
//³ mv_par11        // Totaliza por Dia   Sim / Nao                         ³
//³ mv_par12        // Nome do Farmaceutico responsavel                     |
//³ mv_par13        // Quantidade de paginas por feixe                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustar o SX1 para SIGAVEI, SIGAPEC e SIGAOFI                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA("SB1")
DBSETORDER(1)
xSB1 := XFILIAL("SB1")
DBSELECTAREA("SB2")
DBSETORDER(1)
xSB2 := XFILIAL("SB2")
DBSELECTAREA("SB5")
DBSETORDER(1)
xSB5 := XFILIAL("SB5")
DBSELECTAREA("SD1")
DBSETORDER(1)
xSD1 := XFILIAL("SD1")
DBSELECTAREA("SD2")
DBSETORDER(1)
xSD2 := XFILIAL("SD2")
DBSELECTAREA("SB3")
DBSETORDER(1)
xSD3 := XFILIAL("SD3")
DBSELECTAREA("SF4")
DBSETORDER(1)
xSF4 := XFILIAL("SF4")
DBSELECTAREA("SF1")
DBSETORDER(1)
xSF1 := XFILIAL("SF1")
DBSELECTAREA("SF2")
DBSETORDER(1)
xSF2 := XFILIAL("SF2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel :="MATR924"
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)
If nLastKey = 27
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey = 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| R947Imp(@lEnd,wnRel,cString,Titulo)},titulo)  // Chamada do Relatorio

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R947Imp  ³ Autor ³ Mary C. Hergert       ³ Data ³30/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Carrega arquivo de trabalho com os movimentos de entrada,  ³±±
±±³Descricao ³ saida e estoque, conforme movimento Kardex e parametros    ³±±
±±³          ³ informados pelo usuario. Sera processado por GRUPO.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR924                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function R947Imp(lEnd,WnRel,cString,Titulo)
Local CbTxt,CbCont1
Local cProdAnt := ""
Local lFirst1  := .T.
Local aSalAtu  := {}
Local cCusto   := ""
Local nRec1    := 0
Local nSavRec,dDataIni,dDataFim
Local nD1Qt,nD2Qt,nD3Qt
Local cPicD1Qt := PesqPictQt("D1_QUANT" ,14)
Local cPicD2Qt := PesqPictQt("D2_QUANT" ,14)
Local cPicD3Qt := PesqPictQt("D3_QUANT" ,14)
Local nImpInc  := 0, aImpostos:={}
Local cDia,cPer,cProd,nSalEst,nPos:=0,aSalEst:={},aCampos:={}
Local cAlmox   := ""
Local cLocIni  := ""
Local cLocFim  := ""
Local cRetPE   := ""
Local aSalAlmo :={}
Local cTRBSD1  := CriaTrab(,.f.)
Local cTRBSD2  := Subs(cTrbSD1,1,7)+"A"
Local cTRBSD3  := Subs(cTrbSD1,1,7)+"B"
Local aInfocabec:={}
Local cTRBSeek := ""
Local lPerda   := .F.
Local nQuantPerda := 0
Local cPrAtivo := GetNewPar("MV_PRATIVO","")
Local lImpPeri := GetNewPar("MV_IMPPERI",.F.)
Local aTempDro := {'','',''}
Local lTempDro := HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())
Local nQtdePerda :=0
Local lPerdanf := .F.
Local lQuery   := .F.
Local cQuery   := ""
Local cAliasSB1:= "SB1"
Local cAliasSB5:= "SB5"
Local cAliasSBM:= "SBM"
Local cAliasSA2:= "SA2"
Local cAliasSD1:= "SD1"
Local cAliasSF1:= "SF1"
Local cAliasSD2:= "SD2"
Local cAliasSF2:= "SF2"
Local cAliasSD3:= "SD3"
Local cStr0018 := ""
Local cDtDig   := ""
Local aStruSB1 := {}
Local aStruSD1 := {}
Local aStruSD2 := {}
Local aStruSD3 := {}
Local lIMPGRUP := SB5->(FieldPos("B5_IMPGRUP")) > 0
Local nTamCod  := TamSx3("B1_COD")[1]
Local nTamGrp  := TamSx3("B1_GRUPO")[1]
Local nTamAmz  := TamSx3("B2_LOCAL")[1]
Local aPergunte:= {}
Local aArmazem := {}
Local aSaldo   := {}
Local nTam     := 0
Local nPosFin  := 0
Local nX       := 0
Local nY       := 0
Local nZ       := 0
Local nW		 := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Local para SIGAVEI, SIGAPEC e SIGAOFI         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cArq1 := ""
Local nInd1 := 0
Local cInd1 := ""
Local lT	:= .F.
Local cImp	:= ""
Local aArea := {}
Local oTempTable := NIL
Local aIndice1 :={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo PRIVATE para SIGAVEI, SIGAPEC e SIGAOFI       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCODITE:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lay-Out de Impressao do Relatorio                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aL:=Array(19)
PRIVATE aDados:=Array(14)
Private cCampImp
Private nTamHist := 31

aL[01]:=		  "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[02]:=STR0011	//"|                                                                 LIVRO DE REGISTRO ESPECIFICO                                                                                                           |"
aL[03]:=		  "|                                                                                                                                                                                                        |"
aL[04]:=STR0012	//"| EMPRESA:        #############################################                                                                                                                                          |"
aL[05]:=		  "|                                                                                                                                                                                                        |"
aL[06]:=STR0014	//"| INSCR.ESTADUAL: ################               C.N.P.J: ############               MEDICAMENTOS CONTROLADOS PSICOTRÓPICOS                                                                              |"
aL[07]:=		  "|                                                                                                                                                                                                        |"
If lImpPeri
	
	aL[08]:=STR0016 //+ Replicate(' ',10) + Replicate('#',38)	//"| FOLHA:          ####                           PERIODO: ############################ de ####                                                                                                           |"
	
Else
	aL[08]:=	  "| FOLHA:          ####                       PERIODO: ########          ######################################                                                                                 |"
EndIf
aL[09]:=		  "|                                                                                                                                                                                                        |"
cStr0018 := STR0018
cStr0018 := Stuff(cStr0018,aT("MEDICAMENTOS",cStr0018),aT("MEDICAMENTOS",cStr0018)+38,"") + "          GRUPO: ###################################                                 |"
aL[10]:=cStr0018	//"| PRODUTO:        ############################## PRINCIPIO ATIVO: ####################          GRUPO: ###################################                                                               |"
aL[11]:="| DESC.ESP:       ################################################################################                                                                                                       |"
aL[12]:=		  "|                                                                                                                                                                                                        |"
aL[13]:=		  "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
aL[14]:=STR0019	//"|         DATA          |                                 |                   MOVIMENTO                   |               |                                |                                             |"
aL[15]:=STR0020	//"|-----------------------|            HISTORICO            |-----------------------------------------------|    ESTOQUE    |  ASSINATURA DO RESP. TECNICO   |                OBSERVACOES                  |"
aL[16]:=STR0021	//"|  DIA  |  MES  |  ANO  |                                 |    ENTRADA    |     SAIDA     |    PERDAS     |               |                                |                                             |"
aL[17]:=		  "|=======+=======+=======+=================================|===============+===============+===============+===============+================================+=============================================|"
aL[18]:=		  "|  ##   |  ##   |  #### | ############################### | ############# | ############# | ############# | ############# |                                | ########################################### |"
aL[19]:=		  "|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"

If lTempDro
	aL[14]:=	  "|         DATA          |                                                     |                   MOVIMENTO                   |               |                                |                         |"
	aL[15]:=	  "|-----------------------|            HISTORICO                                |-----------------------------------------------|    ESTOQUE    |  ASSINATURA DO RESP. TECNICO   |       OBSERVACOES       |"
	aL[16]:=	  "|  DIA  |  MES  |  ANO  |                                                     |    ENTRADA    |     SAIDA     |    PERDAS     |               |                                |                         |"
	aL[17]:=	  "|=======+=======+=======+=====================================================|===============+===============+===============+===============+================================+=========================|"
	aL[18]:=   	  "|  ##   |  ##   |  #### | ################################################### | ############# | ############# | ############# | ############# |                                | ####################### |"
	nTamHist := 51
EndIf

If Empty(cPrAtivo) .Or. SB5->(FieldPos(cPrAtivo)) == 0
	cPrAtivo := ""
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li       := 80
dDataIni := mv_par04
dDataFim := mv_par05
nPaginas := IIF(mv_par08<=1,2,mv_par08)
//Substr(Alltrim(Str(Year(MV_PAR03))),3))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o codigo de caracter Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := 18
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria array para gerar arquivo de trabalho            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{ "PERIODO"	,"C",06,0 } )
AADD(aCampos,{ "PRODUTO"	,"C",nTamCod,0 } )
AADD(aCampos,{ "ESPECIE"	,"C",05,0 } )
AADD(aCampos,{ "SERIE"		,"C",03,0 } )
AADD(aCampos,{ "NUMERO"		,"C",12,0 } )
AADD(aCampos,{ "EMISSAO"	,"D",08,0 } )
AADD(aCampos,{ "DTDIGIT"	,"D",08,0 } )
AADD(aCampos,{ "DIA"		,"C",02,0 } )
AADD(aCampos,{ "CC"			,"C",15,0 } )
AADD(aCampos,{ "CF"			,"C",04,0 } )
AADD(aCampos,{ "ES"			,"C",03,0 } )
AADD(aCampos,{ "COD"		,"C",01,0 } )
AADD(aCampos,{ "QTDE"		,"N",16,3 } )
AADD(aCampos,{ "ESTOQUE"	,"N",16,3 } )
AADD(aCampos,{ "DESCRICAO"	,"C",30,0 } )
AADD(aCampos,{ "DESCESPEC"	,"C",80,0 } )
AADD(aCampos,{ "CONVDIPI"	,"N",09,4 } )
AADD(aCampos,{ "UMDIPI"		,"C",03,0 } )
AADD(aCampos,{ "UM"			,"C",02,0 } )
AADD(aCampos,{ "POSIPI"		,"C",10,0 } )
AADD(aCampos,{ "FLAG"		,"C",01,0 } )
AADD(aCampos,{ "TIPO"		,"C",02,0 } )
AADD(aCampos,{ "GRUPO"		,"C",04,0 } )
AADD(aCampos,{ "GRUPON"		,"C",30,0 } )
AADD(aCampos,{ "PRATIVO"	,"C",30,0 } )
AADD(aCampos,{ "HISTORICO"	,"C",09,0 } )
AADD(aCampos,{ "FORNECE"	,"C",40,0 } )
AADD(aCampos,{ "TABELA"		,"C",3,0})
AADD(aCampos,{ "CLIENTE"	,"C",40,0 } )
If lTempDro
	AADD(aCampos,{ "RECEITA"	,"C",10,0 } )
	AADD(aCampos,{ "ENDERECO"	,"C",20,0 } )
EndIf
AADD(aCampos,{ "TPPROD"		,"C",04,0 } )
AADD(aCampos,{ "PORTARIA"		,"C",07,0 } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                        ³
//³ O indice devera ser sempre pela DTDIGIT conforme IOB - 25/02/02 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄLarsonÄÄÙ
If aReturn[8] == 1
	//Por Codigo
	aIndice1 := {"PERIODO","PORTARIA","PRODUTO","FLAG","DTDIGIT"}
	cTRBSeek := "SB1->B1_COD"
ElseIf aReturn[8] == 2
	//Por Descricao
	aIndice1 := {"PERIODO","PORTARIA","DESCRICAO","PRODUTO","FLAG","DTDIGIT"}
	cTRBSeek := "SB1->B1_DESC"
EndIf
	
cArqTrab1 := CriaTrab(aCampos,.F.)
/*dbUseArea(.T.,"TOPCONN",cArqTrab1,"TRB")
//IndRegua("TRB",cArqTrab1,cIndice1,,,STR0012) //"Selecionando Registros..."
dbSetIndex(Left(cArqTrab1,7)+"I")
*/
oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", aIndice1)
oTempTable:Create()

#IFNDEF TOP
	dbClearIndex()
	dbSetIndex(Left(cArqTrab1,7)+"I"+OrdBagExt())
	dbSetIndex(cArqTrab1+OrdBagExt())
#ENDIF

//--> TRB : Processar sempre com ordem 1 (Por Produto)
dbSetOrder(1)
dbGoTop()

dbSelectArea("SA2")
dbSetOrder(1)
dbSelectArea("SD1")
dbSetOrder(7)
dbSelectArea("SD2")
dbSetOrder(6)
dbSelectArea("SD3")
dbSetOrder(7)
dbSelectArea("SF1")
dbSetOrder(1)
dbSelectArea("SF2")
dbSetOrder(1)
dbSelectArea("SB2")
dbSetOrder(1)
dbSelectArea("SB1")
dbSetOrder(aReturn[8])

If aReturn[8] == 1
	SB1->(dbseek(xSB1 + mv_par01,.T.))
Else
	SB1->(dbSeek(xSB1 ,.T.))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termo / Livro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case mv_par10==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
Case mv_par10==2 ; lImpLivro:=.f. ; lImpTermos:=.t.
Case mv_par10==3 ; lImpLivro:=.t. ; lImpTermos:=.t.
EndCase

nTamReg:=LastRec()
nTamReg:=IIf(nTamReg>0,nTamReg,1)
SetRegua(nTamReg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o preenchimento do GRUPO na Wizard    ³
//³ e padroniza o conteúdo preenchido na pergunta  ³
//³ do tipo range para que seja possível localizar ³
//³ grupo por grupo                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	!Empty(Alltrim(mv_par03))
	If	Substr(Alltrim(mv_par03),Len(Alltrim(mv_par03)), 1) <> ';'
		mv_par03 = Alltrim(mv_par03)+';' 
	EndIf
	nTam := Len(Alltrim(mv_par03))	
	nPos := 1
	nPosFin := AT(';',Alltrim(mv_par03))
	aPergunte := {}
	nX := 0
	nZ := 0
	nY := 0
	While nPosFin > 0
		aadd(aPergunte,{Len(aPergunte)+1, Padr(Substr(Alltrim(mv_par03),nPos,nPosFin-1),nTamGrp)})
		nPos += nPosFin
		nPosFin := AT(';',Substr(Alltrim(mv_par03),nPos,nTam))
	EndDo
	mv_par03 := ""
	For	nX:=1 to Len(aPergunte)
		If	'-' $ aPergunte[nX][2]
			nW := len(Substr(Alltrim(aPergunte[nX][2]), 1, AT('-',aPergunte[nX][2])-1))
			nZ := Val(Substr(Alltrim(aPergunte[nX][2]), 1, AT('-',aPergunte[nX][2])-1))
			nY := Val(Substr(Alltrim(aPergunte[nX][2]), AT('-',aPergunte[nX][2])+1, Len(aPergunte[nX][2])))
			For	nZ:=nZ to nY
				cGrupo := StrZero(nZ,nTamGrp)
				mv_par03 += Padr(AllTrim(StrZero(nZ,nW)), nTamGrp) + '|'
			Next
		Else
			mv_par03 += Padr(AllTrim(aPergunte[nX][2]),nTamGrp) + '|'
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o preenchimento do Tipo de Medicamento³
//³ na Wizard e padroniza o conteúdo preenchido na ³
//³ pergunta do tipo range para que seja possível  ³
//³ localizar grupo por grupo                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	!Empty(Alltrim(mv_par19))
	If	Substr(Alltrim(mv_par19),Len(Alltrim(mv_par19)), 1) <> ';'
		mv_par19 = Alltrim(mv_par19)+';'
	EndIf
	nTam := Len(Alltrim(mv_par19))
	nPos := 1
	nPosFin := AT(';',Alltrim(mv_par19))
	aPergunte := {}
	nX := 0
	nZ := 0
	nY := 0
	While nPosFin > 0
		aadd(aPergunte,{Len(aPergunte)+1, Substr(Alltrim(mv_par19),nPos,nPosFin-1)})
		nPos += nPosFin
		nPosFin := AT(';',Substr(Alltrim(mv_par19),nPos,nTam))
	EndDo
	mv_par19 := ""
	For	nX:=1 to Len(aPergunte)
		If	'-' $ aPergunte[nX][2]
			nZ := Val(Substr(Alltrim(aPergunte[nX][2]), 1, AT('-',aPergunte[nX][2])-1))
			nY := Val(Substr(Alltrim(aPergunte[nX][2]), AT('-',aPergunte[nX][2])+1, Len(aPergunte[nX][2])))
			For	nZ:=nZ to nY
				mv_par19 += Alltrim(Str(nZ)) + '|'
			Next
		Else
			mv_par19 += Alltrim(aPergunte[nX][2]) + '|'
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o preenchimento do ARMAZÉM na Wizard  ³
//³ e padroniza o conteúdo preenchido na pergunta  ³
//³ do tipo range para que seja possível localizar ³
//³ armazém por armazém                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	!Empty(Alltrim(mv_par07))
	If	Substr(Alltrim(mv_par07),Len(Alltrim(mv_par07)), 1) <> ';'
		mv_par07 = Alltrim(mv_par07)+';'
	EndIf
	nTam := Len(Alltrim(mv_par07))
	nPos := 1
	nPosFin := AT(';',Alltrim(mv_par07))
	aPergunte := {}
	cLocIni := ""
	cLocFim := ""
	nX := 0
	nZ := 0
	nY := 0
	While nPosFin > 0
		aadd(aPergunte,{Len(aPergunte)+1, Substr(Alltrim(mv_par07),nPos,nPosFin-1)})
		nPos += nPosFin
		nPosFin := AT(';',Substr(Alltrim(mv_par07),nPos,nTam))
	EndDo
	mv_par07 := ""
	For	nX :=1 to Len(aPergunte)
		If '-' $ aPergunte[nX][2]
			nZ := Val(Substr(Alltrim(aPergunte[nX][2]), 1, AT('-',aPergunte[nX][2])-1))
			nY := Val(Substr(Alltrim(aPergunte[nX][2]), AT('-',aPergunte[nX][2])+1, Len(aPergunte[nX][2])))
			For	nZ := nZ to nY
				cAlmox := StrZero(nZ,nTamAmz)
				aadd(aArmazem,{Len(aArmazem)+1, cAlmox})
				mv_par07 += cAlmox + '|'
				If nZ == 1
					cLocIni += cAlmox
				EndIf
			Next
			cLocFim := cAlmox
		Else
			cAlmox := aPergunte[nX][2]
			aadd(aArmazem,{Len(aArmazem)+1, cAlmox})
			mv_par07 += cAlmox + '|'
			cLocIni += "'" + cAlmox + "',"
		EndIf
	Next
	If Right(cLocIni,1) == ","
		cLocIni := Left(cLocIni,Len(cLocIni)-1)
	EndIf
	
EndIf

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery := .T.
	Endif
#ENDIF

If lQuery
	cAliasSB1 := "TopSB1"
	cAliasSB5 := "TopSB1"
	cAliasSBM := "TopSB1"
	aStruSB1 := SB1->(dbStruct())
	cQuery := "SELECT "
	cQuery += " CASE SB1.B1_TPPROD "
	cQuery += " 	WHEN 'A1' THEN 'LIVROA1' "
	cQuery += " 	WHEN 'A2' THEN 'LIVROA1' "
	cQuery += " 	WHEN 'A3' THEN 'LIVROB1' "
	cQuery += " 	WHEN 'B1' THEN 'LIVROB1' "
	cQuery += " 	WHEN 'B2' THEN 'LIVROB1' "
	cQuery += " 	WHEN 'C1' THEN 'LIVROC1' "
	cQuery += " 	WHEN 'C2' THEN 'LIVROC1' "
	cQuery += " 	WHEN 'C4' THEN 'LIVROC1' "
	cQuery += " 	WHEN 'C5' THEN 'LIVROC1' "
	cQuery += " 	WHEN 'C3' THEN 'LIVROC3' "
	cQuery += " 	ELSE 'outros' "
	cQuery += " 	END AS PORTARIA , "
	If !(Empty(cPrAtivo)) 
		cQuery += " " + cPrAtivo + ", "
	EndIf
	cQuery += " SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC, SB1.B1_ESPECIF, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_TPPROD, SB5.B5_CONVDIP, SB5.B5_UMDIPI, SBM.BM_DESC"+Iif(lIMPGRUP,", SB5.B5_IMPGRUP "," ")
	cQuery += " FROM "+RetSqlName("SB1")+" SB1,"+RetSqlName("SB5")+" SB5,"+RetSqlName("SBM")+" SBM WHERE "
	cQuery += " SB1.B1_FILIAL='"+xSB1+"' AND "
	cQuery += " SB1.B1_COD>='"+mv_par01+"' AND "
	cQuery += " SB1.B1_COD<='"+mv_par02+"' AND "
	cQuery += " SB1.D_E_L_E_T_ = ' ' AND "
	cQuery += " SB5.B5_FILIAL='"+xSB5+"' AND "
	cQuery += " SB5.B5_COD=SB1.B1_COD AND "
	cQuery += " SB5.D_E_L_E_T_ = ' ' AND "
	cQuery += " SBM.BM_FILIAL='"+xFilial("SBM")+"' AND "
	cQuery += " SBM.BM_GRUPO=SB1.B1_GRUPO AND "
	cQuery += " SBM.D_E_L_E_T_ = ' ' " 
	cQuery += " ORDER BY PORTARIA "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
	For nX := 1 To len(aStruSB1)
		If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
			TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
		EndIf
	Next nX
EndIf

(cAliasSB1)->(dbGoTop())
While !(cAliasSB1)->(Eof()) .And. Iif(lQuery,.T.,(cAliasSB1)->B1_FILIAL == xSB1) .and. lImpLivro
	IncRegua()
	SysRefresh()
	IF lEnd
		@PROW()+1,001 PSAY STR0023	//"CANCELADO PELO OPERADOR"
		EXIT
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra pelo intervalo do tipos e Mao de Obra   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lT := .F.
	If !lQuery .And. aReturn[8] == 1 .And. (cAliasSB1)->B1_COD > mv_par02
		Exit
	Endif

	If !lQuery
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+(cAliasSB1)->B1_GRUPO))
		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))
	EndIf

	If lIMPGRUP
		If lQuery .And. !(Empty((cAliasSB5)->B5_IMPGRUP))
			cImp := (cAliasSB5)->B5_IMPGRUP
		ElseIf !(Empty(SB5->B5_IMPGRUP))
			cImp := SB5->B5_IMPGRUP
		EndIf
	EndIf
		

	If	IIf(!Empty(mv_par03), !((cAliasSB1)->B1_GRUPO $ mv_par03),.F.) .Or. ;
		Upper(Subs((cAliasSB1)->B1_COD,1,3)) == "MOD" .Or. ;
		(cAliasSB1)->B1_COD > mv_par02 .Or. ;
		(cAliasSB1)->B1_COD < mv_par01 .Or. ;
		Alltrim(cImp) == "N" .Or. ;
		IIf(!Empty(mv_par19), !((cAliasSB1)->B1_TPPROD $ mv_par19),.F.)
		lT := .T.
	Endif

	If lT
		(cAliasSB1)->(dbSkip())
		Loop
	Endif

	If	!Empty(Alltrim(mv_par07))
		aSalAtu:={}
		For	nX:=1 to Len(aArmazem)
			cAlmox := aArmazem[nX][2]
			aSaldo := CalcEst((cAliasSB1)->B1_COD,cAlmox,mv_par04)
			If	Len(aSalAtu) > 0
				For	nZ:=1 to Len(aSaldo)
					aSalAtu[nZ] += aSaldo[nZ]
				Next
			Else
				aSalAtu := aClone(aSaldo)
			EndIf
		Next
	Else
		aSalAtu := CalcEst((cAliasSB1)->B1_COD,mv_par07,mv_par04)
	EndIf

	nPos := 0
	nX   := 0
	cProdAnt   := (cAliasSB1)->B1_COD
	aSalAtu[1] := IIF((cAliasSB5)->B5_CONVDIP > 0,aSalAtu[1] * (cAliasSB5)->B5_CONVDIP,aSalAtu[1])
	cPer       := STR(Year(dDataIni),4)+STR(Month(dDataIni),2)
	nRec1      := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Arq. de Movimentacoes.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPer := STR(Year(dDataIni),4)+StrZero(Month(dDataIni),2)
	If lQuery
		cAliasSD1 := "TopSD1"
		cAliasSF1 := "TopSD1"
		cAliasSA2 := "TopSD1"
		aStruSB1 := SD1->(dbStruct())
		cQuery := "SELECT "
		cQuery += "SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_SERIE, SD1.D1_TIPO, SD1.D1_COD, SD1.D1_LOCAL, SD1.D1_EMISSAO, SD1.D1_ORIGLAN, SD1.D1_DTDIGIT, SD1.D1_CC, SD1.D1_CF, SD1.D1_QUANT, SF1.F1_ESPECIE, SA2.A2_NOME "
		#IFDEF SHELL
		cQuery += ", D1_CANCEL "
		#ENDIF
		cQuery += "FROM "
		cQuery += RetSqlName("SD1")+" SD1,"+RetSqlName("SF1")+" SF1,"
		cQuery += RetSqlName("SA2")+" SA2,"+RetSqlName("SF4")+" SF4 WHERE "
		cQuery += "SD1.D1_FILIAL  = '"+xSD1+"' AND "
		cQuery += "SD1.D1_COD     = '"+cProdAnt+"' AND "
		If cLocIni == cLocFim
			cQuery += "SD1.D1_LOCAL   = '"+cLocIni+"' AND "
		ElseIf Empty(cLocFim)
			cQuery += "SD1.D1_LOCAL  IN ("+cLocIni+") AND "
		Else
			cQuery += "SD1.D1_LOCAL  >= '"+cLocIni+"' AND "
			cQuery += "SD1.D1_LOCAL  <= '"+cLocFim+"' AND "
		EndIf
		cQuery += "SD1.D1_DTDIGIT>= '"+dtos(dDataIni)+"' AND "
		cQuery += "SD1.D1_DTDIGIT<= '"+dtos(dDataFim)+"' AND "
		cQuery += "SD1.D_E_L_E_T_ = ' ' AND "
		cQuery += "SF1.F1_FILIAL  = '"+xSF1+"' AND "
		cQuery += "SF1.F1_DOC     =  SD1.D1_DOC AND "
		cQuery += "SF1.F1_SERIE   =  SD1.D1_SERIE AND "
		cQuery += "SF1.F1_FORNECE =  SD1.D1_FORNECE AND "
		cQuery += "SF1.F1_LOJA    =  SD1.D1_LOJA AND "
		cQuery += "SF1.D_E_L_E_T_ = ' ' AND "
		cQuery += "SA2.A2_FILIAL  = '"+xFilial("SA2")+"' AND "
		cQuery += "SA2.A2_COD     =  SD1.D1_FORNECE AND "
		cQuery += "SA2.A2_LOJA    =  SD1.D1_LOJA AND "
		cQuery += "SA2.D_E_L_E_T_ = ' ' AND "
		cQuery += "SF4.F4_FILIAL  = '"+xSF4+"' AND "
		cQuery += "SF4.F4_CODIGO  = SD1.D1_TES AND "
		cQuery += "SF4.F4_ESTOQUE = 'S' AND "
		cQuery += "SF4.D_E_L_E_T_ = ' '"
		cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		For nX := 1 To len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
	Else
		SD1->(dbSeek(xSD1+(cAliasSB1)->B1_COD+cLocIni+dtos(mv_par04),.t.))
	Endif

	dbSelectArea(cAliasSD1)
	(cAliasSD1)->(dbGoTop())
	While !(cAliasSD1)->(Eof()) .And. Iif(lQuery,.T.,(cAliasSD1)->D1_DTDIGIT >= dDataIni .And. (cAliasSD1)->D1_DTDIGIT <= dDataFim .And. (cAliasSD1)->D1_COD == cProdAnt .And. (cAliasSD1)->D1_Local <= cLocFim)
		#IFDEF SHELL
			If (cAliasSD1)->D1_CANCEL == "S"
				(cAliasSD1)->dbSkip()
				Loop
			End
		#ENDIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
		//³ e de complemento de ICMS.                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((cAliasSD1)->D1_ORIGLAN$"LF") .Or. ((cAliasSD1)->D1_TIPO=="I")
			(cAliasSD1)->(dbSkip())
			Loop
		EndIf
		nD1Qt := IIF ((cAliasSB5)->B5_CONVDIP > 0, (cAliasSD1)->D1_QUANT * (cAliasSB5)->B5_CONVDIP,(cAliasSD1)->D1_QUANT)

		If !lQuery
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF4")
			dbSeek(xSF4+SD1->D1_TES)
			dbSelectArea("SD1")
			If SF4->F4_ESTOQUE != "S"
				SD1->(dbSkip())
				Loop
			EndIf
			SF1->(dbseek(xSF1+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))) //posiciona o cabecalho da nota
			SA2->(dbSeek(xFilial("SA2")+SD1->(D1_FORNECE+D1_LOJA)))
		EndIf

		lT := .F.
		If TRB->(dbSeek(cPer + &(cTRBSeek) + If(aReturn[8] <> 1, &("SB1->B1_COD"), "") + 'S'))
			lT := .T.
		EndIf

		IF lT
			RecLock("TRB",.F.)
			TRB->FLAG := " "
		Else
			RecLock("TRB",.T.)
		EndIf
		cDtDig := Stod((cAliasSD1)->D1_DTDIGIT)
		TRB->PERIODO  := iif(lImpPeri,'',STR(Year(cDtDig),4)+StrZero(Month(cDtDig),2))
		TRB->PRODUTO  := (cAliasSD1)->D1_COD
		TRB->DESCRICAO:= (cAliasSB1)->B1_DESC
		TRB->DESCESPEC:= (cAliasSB1)->B1_ESPECIF
		TRB->PRATIVO  := (cAliasSB5)->&(cPrAtivo)
		TRB->TIPO     := (cAliasSB1)->B1_TIPO
		TRB->GRUPO    := (cAliasSB1)->B1_GRUPO
		TRB->TPPROD	:= (cAliasSB1)->B1_TPPROD
		TRB->PORTARIA	:= (cAliasSB1)->PORTARIA
		TRB->GRUPON   := (cAliasSBM)->BM_DESC
		TRB->CONVDIPI := (cAliasSB5)->B5_CONVDIP
		TRB->UMDIPI   := (cAliasSB5)->B5_UMDIPI
		TRB->UM       := (cAliasSB1)->B1_UM
		TRB->POSIPI   := (cAliasSB1)->B1_POSIPI
		TRB->ESPECIE  := (cAliasSF1)->F1_ESPECIE
		TRB->SERIE    := (cAliasSD1)->D1_SERIE
		TRB->NUMERO   := (cAliasSD1)->D1_DOC
		TRB->EMISSAO  := Stod((cAliasSD1)->D1_EMISSAO)
		TRB->DTDIGIT  := cDtDig
		TRB->CC       := (cAliasSD1)->D1_CC
		TRB->CF       := IIf(cPaisLoc=="BRA",(cAliasSD1)->D1_CF," ")
		TRB->ES       := " E "
		TRB->COD      := "1"
		TRB->QTDE     := nD1QT
		TRB->HISTORICO:= (cAliasSD1)->D1_DOC
		TRB->FORNECE  := (cAliasSA2)->A2_NOME
		aSalAtu[1] += nD1QT
		TRB->ESTOQUE := aSalAtu[1]
		TRB->TABELA	 := 'SD1'
		MsUnlock()
		nRec1++
		(cAliasSD1)->(dbSkip())
	EndDo

	If lQuery
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	EndIf

	dbSelectArea("SD3")
	If lQuery
		cAliasSD3 := "TopSD2"
		aStruSD3  := SD3->(dbStruct())
		cQuery := "SELECT SD3.D3_COD, SD3.D3_DOC, SD3.D3_TM, SD3.D3_OP, SD3.D3_LOCAL, SD3.D3_CC, SD3.D3_CF, SD3.D3_QUANT, SD3.D3_PERDA, SD3.D3_EMISSAO, D3_ESTORNO,D3_SERVIC FROM "
		cQuery += RetSqlName("SD3")+" SD3 WHERE "
		cQuery += "SD3.D3_FILIAL  = '"+xFilial("SD3")+"' AND "
		cQuery += "SD3.D3_COD     = '"+cProdAnt+"' AND "
		If cLocIni == cLocFim
			cQuery += "SD3.D3_LOCAL   = '"+cLocIni+"' AND "
		ElseIf Empty(cLocFim)
			cQuery += "SD3.D3_LOCAL  IN ("+cLocIni+") AND "
		Else
			cQuery += "SD3.D3_LOCAL  >= '"+cLocIni+"' AND "
			cQuery += "SD3.D3_LOCAL  <= '"+cLocFim+"' AND "
		EndIf
		cQuery += "SD3.D3_EMISSAO>= '"+dtos(dDataIni)+"' AND "
		cQuery += "SD3.D3_EMISSAO<= '"+dtos(dDataFim)+"' AND "
		cQuery += "SD3.D3_ESTORNO <> 'S' AND "
		cQuery += "SD3.D_E_L_E_T_ = ' '"
		cQuery += "ORDER BY "+SqlOrder(SD3->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3,.T.,.T.)
	Else
		SD3->(dbSeek(xSD3+(cAliasSB1)->B1_COD+cLocIni+dtos(mv_par04),.T.))
	EndIf

	dbSelectArea(cAliasSD3)
	(cAliasSD3)->(dbGoTop())
	While !(cAliasSD3)->(Eof()) .And. Iif(lQuery,.T.,(cAliasSD3)->(D3_EMISSAO == dDataIni .And. (cAliasSD3)->D3_EMISSAO <= dDataFim  .And. D3_COD == cProdAnt .And. D3_Local == cLocFim))
		nD3Qt := IIF ((cAliasSB5)->B5_CONVDIP > 0, (cAliasSD3)->D3_QUANT * (cAliasSB5)->B5_CONVDIP,(cAliasSD3)->D3_QUANT)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o movimento e de Perda.                                            ³
		//³Apenas para os casos de lancamentos de requisicoes que indicam perda de estoque³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lPerda      := .F.
		nQuantPerda := 0
		If Empty((cAliasSD3)->D3_OP) .And. (cAliasSD3)->D3_TM > "500" .And. (cAliasSD3)->D3_CF <> "RE4" .And. (cAliasSD3)->D3_CF <> "DE4" .And. (cAliasSD3)->D3_QUANT > 0 .And. (cAliasSD3)->D3_TM >= mv_par16 .And. (cAliasSD3)->D3_TM <= mv_par17
			lPerda      := .T.
			nQuantPerda := (cAliasSD3)->D3_QUANT
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o movimento e de Perda.                                            ³
		//³Apenas para os casos de producao com perda de material                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty((cAliasSD3)->D3_OP) .And. Substr((cAliasSD3)->D3_CF,1,2) = "PR" .And. (cAliasSD3)->D3_PERDA > 0
			lPerda      := .T.
			nQuantPerda := (cAliasSD3)->D3_PERDA
		Endif

		If !D3Valido(cAliasSD3)
			(cAliasSD3)->(dbSkip())
			Loop
		EndIf

		lT := .F.
		If TRB->(dbSeek(cPer + &(cTRBSeek) + If(aReturn[8] <> 1, &("SB1->B1_COD"), "") + 'S'))
			lT := .T.
		EndIf

		If lT
			RecLock("TRB",.F.)
			TRB->FLAG := " "
		Else
			RecLock("TRB",.T.)
		EndIf
		cDtDig := stod((cAliasSD3)->D3_EMISSAO)
		TRB->PERIODO  := iif(lImpPeri,'',STR(Year(cDtDig),4)+StrZero(Month(cDtDig),2))
		TRB->PRODUTO  := (cAliasSD3)->D3_COD
		TRB->DESCRICAO:= (cAliasSB1)->B1_DESC
		TRB->DESCESPEC:= (cAliasSB1)->B1_ESPECIF
		TRB->PRATIVO  := (cAliasSB5)->&(cPrAtivo)
		TRB->TIPO     := (cAliasSB1)->B1_TIPO
		TRB->GRUPO    := (cAliasSB1)->B1_GRUPO
		TRB->TPPROD   := (cAliasSB1)->B1_TPPROD
		TRB->PORTARIA	:= (cAliasSB1)->PORTARIA
		TRB->GRUPON   := (cAliasSBM)->BM_DESC
		TRB->CONVDIPI := (cAliasSB5)->B5_CONVDIP
		TRB->UMDIPI   := (cAliasSB5)->B5_UMDIPI
		TRB->UM       := (cAliasSB1)->B1_UM
		TRB->POSIPI   := (cAliasSB1)->B1_POSIPI
		TRB->NUMERO   := (cAliasSD3)->D3_DOC
		TRB->EMISSAO  := Stod((cAliasSD3)->D3_EMISSAO)
		TRB->DTDIGIT  := Stod((cAliasSD3)->D3_EMISSAO)
		TRB->CC       := (cAliasSD3)->D3_CC
		TRB->CF       := IIf(cPaisLoc=="BRA",(cAliasSD3)->D3_CF," ")
		TRB->ES       := IIF(lPerda," P ",IIF( Val((cAliasSD3)->D3_TM) <= 500 ," E "," S "))
		TRB->COD      := "1"
		TRB->QTDE     := nD3QT
		If (cAliasSD3)->D3_TM <= "500"	// Entradas
			aSalAtu[1] += nD3QT
		Elseif !lPerda					// Saidas
			aSalAtu[1] -= nD3QT
		Else							// Perdas
			aSalAtu[1] -= nQuantPerda
			TRB->QTDE  := nQuantPerda
		Endif
		TRB->ESTOQUE := aSalAtu[1]
		TRB->TABELA	 := 'SD3'
		TRB->HISTORICO:= IIf(!Empty((cAliasSD3)->D3_DOC), (cAliasSD3)->D3_DOC, '')
		MsUnlock()
		nRec1++
		(cAliasSD3)->(dbSkip())
	EndDo

	If lQuery
		dbSelectArea(cAliasSD3)
		dbCloseArea()
	EndIf

	dbSelectArea("SD2")
	If lQuery
		cAliasSD2 := "TopSD2"
		cAliasSF2 := "TopSD2"
		cAliasSA2 := "TopSD2"
		aStruSD2  := SD2->(dbStruct())
		cQuery := "SELECT SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_SERIE, SD2.D2_COD, SD2.D2_TIPO, SD2.D2_CF, SD2.D2_ORIGLAN, SD2.D2_QUANT, SD2.D2_EMISSAO, SF2.F2_ESPECIE,SA1.A1_NOME "
		#IFDEF SHELL
		cQuery += ", D2_CANCEL "
		#ENDIF
		cQuery += "FROM "
		cQuery += RetSqlName("SD2")+" SD2,"+RetSqlName("SF2")+" SF2,"
		cQuery += RetSqlName("SA1")+" SA1,"+RetSqlName("SF4")+" SF4 WHERE "
		cQuery += "SD2.D2_FILIAL  = '"+xSD2+"' AND "
		cQuery += "SD2.D2_COD     = '"+cProdAnt+"' AND "
		If cLocIni == cLocFim
			cQuery += "SD2.D2_LOCAL   = '"+cLocIni+"' AND "
		ElseIf Empty(cLocFim)
			cQuery += "SD2.D2_LOCAL  IN ("+cLocIni+") AND "
		Else
			cQuery += "SD2.D2_LOCAL  >= '"+cLocIni+"' AND "
			cQuery += "SD2.D2_LOCAL  <= '"+cLocFim+"' AND "
		EndIf
		cQuery += "SD2.D2_EMISSAO>= '"+dtos(dDataIni)+"' AND "
		cQuery += "SD2.D2_EMISSAO<= '"+dtos(dDataFim)+"' AND "
		cQuery += "SD2.D_E_L_E_T_ = ' ' AND "
		cQuery += "SF2.F2_FILIAL  = '"+xSF2+"' AND "
		cQuery += "SF2.F2_DOC     =  SD2.D2_DOC AND "
		cQuery += "SF2.F2_SERIE   =  SD2.D2_SERIE AND "
		cQuery += "SF2.F2_CLIENTE =  SD2.D2_CLIENTE AND "
		cQuery += "SF2.F2_LOJA    =  SD2.D2_LOJA AND "
		cQuery += "SF2.D_E_L_E_T_ = ' ' AND "
		cQuery += "SA1.A1_FILIAL  = '"+xFilial("SA1")+"' AND "
		cQuery += "SA1.A1_COD     =  SD2.D2_CLIENTE AND "
		cQuery += "SA1.A1_LOJA    =  SD2.D2_LOJA AND "
		cQuery += "SA1.D_E_L_E_T_ = ' ' AND "
		cQuery += "SF4.F4_FILIAL  = '"+xSF4+"' AND "
		cQuery += "SF4.F4_CODIGO  = SD2.D2_TES AND "
		cQuery += "SF4.F4_ESTOQUE = 'S' AND "
		cQuery += "SF4.D_E_L_E_T_ = ' '"
		cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		For nX := 1 To len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
	Else
		SD2->(dbSeek(xSD2+(cAliasSB1)->B1_COD+cLocIni+dtos(mv_par04),.T.))
	EndIf

	dbSelectArea(cAliasSD2)
	(cAliasSD2)->(dbGoTop())
	While !(cAliasSD2)->(Eof()) .And. Iif(lQuery,.T.,(cAliasSD2)->(D2_EMISSAO >= dDataIni .And. D2_EMISSAO <= dDataFim .And. D2_COD == cProdAnt .And. D2_Local >= cLocFim))
		#IFDEF SHELL
			If (cAliasSD2)->D2_CANCEL == "S"
				(cAliasSD2)->(dbSkip())
				Loop
			End
		#ENDIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
		//³ e de complementos de preco e impostos.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((cAliasSD2)->D2_ORIGLAN=="LF") .Or. ((cAliasSD2)->D2_TIPO$"CPI")
			dbSkip()
			Loop
		EndIf
		nD2Qt := IIF ((cAliasSB5)->B5_CONVDIP > 0, (cAliasSD2)->D2_QUANT * (cAliasSB5)->B5_CONVDIP, (cAliasSD2)->D2_QUANT)

		If !lQuery
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF4")
			dbSeek(xSF4+SD2->D2_TES)
			dbSelectArea("SD2")
			If SF4->F4_ESTOQUE != "S"
				dbSkip()
				Loop
			EndIf
			SF2->(dbseek(xSF2+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA))) //posiciona o cabecalho da nota
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o movimento e de Perda atraves do CFOP                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lPerdanf := .F.
		If (AllTrim((cAliasSD2)->D2_CF)$mv_par18)
			lPerdanf := .T.
			nQtdePerda  := (cAliasSD2)->D2_QUANT
		Endif

		lT := .F.
		If TRB->(dbSeek(cPer + &(cTRBSeek) + If(aReturn[8] <> 1, &("SB1->B1_COD"), "") + 'S'))
			lT := .T.
		EndIf

		If lT
			RecLock("TRB",.F.)
			TRB->FLAG := " "
		Else
			RecLock("TRB",.T.)
		EndIf
		cDtDig := Stod((cAliasSD2)->D2_EMISSAO)
		TRB->PERIODO  := iif(lImpPeri,'',STR(Year(cDtDig),4)+StrZero(Month(cDtDig),2))
		TRB->PRODUTO  := (cAliasSD2)->D2_COD
		TRB->DESCRICAO:= (cAliasSB1)->B1_DESC
		TRB->DESCESPEC:= (cAliasSB1)->B1_ESPECIF
		TRB->PRATIVO  := (cAliasSB5)->&(cPrAtivo)
		TRB->TIPO     := (cAliasSB1)->B1_TIPO
		TRB->GRUPO    := (cAliasSB1)->B1_GRUPO
		TRB->TPPROD   := (cAliasSB1)->B1_TPPROD
		TRB->PORTARIA	:= (cAliasSB1)->PORTARIA
		TRB->GRUPON   := (cAliasSBM)->BM_DESC
		TRB->CONVDIPI := (cAliasSB5)->B5_CONVDIP
		TRB->UMDIPI   := (cAliasSB5)->B5_UMDIPI
		TRB->UM       := (cAliasSB1)->B1_UM
		TRB->POSIPI   := (cAliasSB1)->B1_POSIPI
		TRB->ESPECIE  := (cAliasSF2)->F2_ESPECIE
		If lTempDro
			If (cAliasSB1)->B1_PSICOTR == "1"
				aArea := TRB->(GetArea())
				aTempDro := T_DroLK9LF((cAliasSD2)->D2_EMISSAO, (cAliasSD2)->D2_DOC, (cAliasSD2)->D2_SERIE, (cAliasSD2)->D2_COD, (cAliasSD2)->D2_QUANT)
				RestArea(aArea)
				TRB->RECEITA  := aTempDro[1]
				TRB->CLIENTE  := aTempDro[2]
				TRB->ENDERECO := aTempDro[3]
			EndIf
		Else
			TRB->CLIENTE  := (cAliasSD2)->A1_NOME
		EndIf
		TRB->SERIE    := (cAliasSD2)->D2_SERIE
		TRB->NUMERO   := (cAliasSD2)->D2_DOC
		TRB->EMISSAO  := Stod((cAliasSD2)->D2_EMISSAO)
		TRB->DTDIGIT  := Stod((cAliasSD2)->D2_EMISSAO)
		TRB->HISTORICO:= (cAliasSD2)->D2_DOC
		TRB->CF       := IIf(cPaisLoc=="BRA",(cAliasSD2)->D2_CF," ")
		TRB->ES       := IIF(lPerdanf," P "," S ")
		TRB->COD      := "1"
		TRB->QTDE     := nD2QT
		If !lPerdanf		// Saidas
			aSalAtu[1] -= nD2QT
		Else				// Perdas
			aSalAtu[1] -= nQtdePerda
			TRB->QTDE  := nQtdePerda
		Endif
		TRB->ESTOQUE := aSalAtu[1]
		TRB->TABELA	 := 'SD2'
		MsUnlock()
		nRec1++
		(cAliasSD2)->(dbSkip())
	EndDo

	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
	EndIf

	If nRec1 == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se deve ou nao listar os produtos s/movimento ³
		//³ Caso liste o produto, grava produto com TRB->FLAG = S  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	mv_par06 == 1 .Or. (aSalAtu[1] > 0 .And. mv_par12 ==1)
			lT	:= .F.
			If TRB->(dbSeek(cPer + &(cTRBSeek) + If(aReturn[8] <> 1, &("SB1->B1_COD"), "") + 'S'))
				lT := .T.
			ENDIF
			IF lT
				RecLock("TRB",.F.)
			Else
				RecLock("TRB",.T.)
				TRB->PERIODO  := iif(lImpPeri,'',cPer)
				TRB->PRODUTO  := (cAliasSB1)->B1_COD
				TRB->FLAG     := 'S'
				TRB->DESCRICAO:= (cAliasSB1)->B1_DESC
				TRB->DESCESPEC:= (cAliasSB1)->B1_ESPECIF
				TRB->PRATIVO  := (cAliasSB5)->&(cPrAtivo)
				TRB->TIPO     := (cAliasSB1)->B1_TIPO
				TRB->GRUPO    := (cAliasSB1)->B1_GRUPO
				TRB->TPPROD   := (cAliasSB1)->B1_TPPROD
				TRB->PORTARIA	:= (cAliasSB1)->PORTARIA
				TRB->GRUPON   := (cAliasSBM)->BM_DESC
				TRB->CONVDIPI := (cAliasSB5)->B5_CONVDIP
				TRB->UMDIPI   := (cAliasSB5)->B5_UMDIPI
				TRB->UM       := (cAliasSB1)->B1_UM
				TRB->POSIPI   := (cAliasSB1)->B1_POSIPI
			EndIf
			If	mv_par12 == 1
				TRB->ESTOQUE  := aSalAtu[1]
			EndIf
			MsUnlock()
		EndIf
	EndIf

	If	cPer <> (STR(Year(dDataFim),4)+STR(Month(dDataFim),2))
		nRec1 := 0
	EndIf

	(cAliasSB1)->(dbSkip())	
EndDo

If lQuery
	dbSelectArea(cAliasSB1)
	dbCloseArea()
EndIf

dbSelectArea( "TRB" )

If aReturn[8] > 1
	If aReturn[8] == 2	
		cIndice2 := "PERIODO+PORTARIA+DESCRICAO+PRODUTO+FLAG+DTOS(DTDIGIT)"
	EndIf
	cArqTrab2 := CriaTrab(Nil,.F.)
	IndRegua("TRB",cArqTrab2,cIndice2,,,STR0012) //"Selecionando Registros..."
	#IFNDEF TOP
		dbClearIndex()
		dbSetIndex(Left(cArqTrab1,7)+"I"+OrdBagExt())
		dbSetIndex(cArqTrab2+OrdBagExt())
	#ENDIF
EndIf

dbGoTop()
SetRegua(LastRec())

nEntDay :=nSaiDay:=nValEntDay:=nValSaiDay:=nIpiEntDay:=nIpiSaiDay:=nPerDay:=0
nEntPer :=nSaiPer:=nValEntPer:=nValSaiPer:=nIpiEntPer:=nIpiSaiPer:=nPerPer:=0
nSalEst :=0
aSalAtu :={}

While ( !EOF() )
	dbSelectArea( "TRB" )
	IncRegua()
	SysRefresh()

	If lEnd
		@PROW()+1,001 PSAY STR0023 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	IF li > 59
		R470Cabec(@Li,@nPaginas)
	EndIF

	lImpr:= .t.
	cDia :=StrZero(Day(TRB->DTDIGIT),2)
	cProd:=TRB->PRODUTO
	cPer :=TRB->PERIODO
	aInfoCabec:={TRB->PRODUTO+" - "+SUBS(TRB->DESCRICAO,1,30),SUBS(TRB->PRATIVO,1,30),;
				IIF(TRB->CONVDIPI > 0, TRB->UMDIPI, TRB->UM),;
				TRB->POSIPI}

	If nSalEst == 0
		dbSelectArea("SB2")
		dbSetOrder(1)
		//Busca o saldo de cada armazém selecionado na wizard
		nPos := ASCAN(aSalEst,{|x| x[1] == cProd})
		If nPos == 0
			If !Empty(Alltrim(mv_par07))
				aSaldo := {}
				aSalAtu := {}
				For	nX:=1 to Len(aArmazem)
					cAlmox := aArmazem[nX][2]
					aSaldo := CalcEst(cProd,cAlmox,mv_par04)
					If	Len(aSalAtu) > 0
						For	nZ:=1 to Len(aSaldo)
							aSalAtu[nZ] += aSaldo[nZ]
						Next
					Else
						aSalAtu := aClone(aSaldo)
					EndIf
				Next
			Else
				aSalAtu := CalcEst(cProd,mv_par07,mv_par04)
			EndIf
			dbSelectArea("SB5")
			SB5->(dbSeek(xSB5 + cProd))
			nSalEst := aSalAtu[1] := IIF(SB5->B5_CONVDIP > 0,aSalAtu[1] * SB5->B5_CONVDIP,aSalAtu[1])
		EndIf
		dbSelectArea( "TRB" )
	EndIf

	If TRB->FLAG == 'S'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha produtos sem movimentos                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDados:=Array(14)
		If mv_par12 == 1
			aDados[04]:=STR0024	//"Saldo Inicial:"
			aDados[08]:=Transform(nSalEst,cPicD1Qt)
			FmtLin(@aDados,aL[18],,,@Li)
		EndIf
		aDados[04]:=STR0027		//"<< Nao houve movimentacao para este produto >>"
		FmtLin(@aDados,aL[18],,,@Li)
		aDados := Array(14)
		If mv_par12 == 1
			aDados[04]:=STR0026	//"Total do Periodo:"
			aDados[08]:=Transform(nSalEst,cPicD1Qt)
		EndIf
		FmtLin(@aDados,aL[18],,,@Li)
		While Li<60
			FmtLin(@aDados,aL[18],,,@Li)
		End
		FmtLin(,aL[01],,,@Li)
		Li:=80
		lImpr  := .f.
		lFirst1:= .f.
	EndIF

	If lFirst1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Saldo Inicial do Produto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDados:=Array(14)
		aDados[04]:=STR0024		//"Saldo Inicial:"
		aDados[08]:=Transform(nSalEst,cPicD1Qt)
		FmtLin(@aDados,aL[18],,,@Li)
		lFirst1 := .f.
	EndIf

	If lImpr
		aDados     := Array(14) //linha 1 - imprime toda linha 
		aDados1    := Array(14) //linha 2 - imprime apenas o complemento do histórico 
		aDados2    := Array(14) //linha 3 - imprime apenas o complemento do histórico 
		aDados[01] := StrZero(Day(TRB->DTDIGIT),2)
		aDados[02] := StrZero(Month(TRB->DTDIGIT),2)
		aDados[03] := StrZero(Year(TRB->DTDIGIT),4)
		If lTempDro .AND. Empty(TRB->FORNECE) .AND. !Empty(TRB->RECEITA)
			aDados[04] := SubsTring(TRB->RECEITA+"|"+TRB->CLIENTE+"|"+TRB->ENDERECO,1,30)
		Else
			aDados[04] := SubsTring(Iif (TRB->TABELA == 'SD3', 'Doc '+TRB->HISTORICO,'NF '+TRB->HISTORICO+"|"+IIf(TRB->TABELA=='SD1', TRB->FORNECE,TRB->CLIENTE)),1,30) // Historico
		EndIf
		//Verifica se o histórico é maior que o layout e quebra a linha
		if len(alltrim(aDados[04])) > nTamHist
			aDados1[04] := substr(aDados[04],nTamHist+1,len(aDados[04]))
			aDados[04]  := substr(aDados[04],1,nTamHist)
			if len(aDados1[04]) > nTamHist
				aDados2[04] := substr(aDados1[04],nTamHist+1,nTamHist)
				aDados1[04] := substr(aDados1[04],1,nTamHist)
			endif
		endif
		aDados[05] := Iif(TRB->ES == " E ",Transform(TRB->QTDE,cPicD1Qt),"")
		aDados[06] := Iif(TRB->ES == " S ",Transform(TRB->QTDE,cPicD1Qt),"")
		aDados[07] := Iif(TRB->ES == " P ",Transform(TRB->QTDE,cPicD1Qt),"")

		// Saldo Em Estoque do Produto
		//nSalEst := TRB->ESTOQUE

		If TRB->ES == " S " 
			nSaiDay    += TRB->QTDE
			nSaiPer    += TRB->QTDE
			nSalEst	   -= TRB->QTDE
		ElseIf TRB->ES == " E "	
			nEntDay    += TRB->QTDE
			nEntPer    += TRB->QTDE
			nSalEst	   += TRB->QTDE
		ElseIf TRB->ES == " P " 
			nPerDay    += TRB->QTDE
			nPerPer    += TRB->QTDE
			nSalEst	   -= TRB->QTDE
		Endif		
		
		aDados[08] := Transform(nSalEst,cPicD1Qt)
		aDados[09] := "" // Observacoes
		FmtLin(@aDados,aL[18],,,@Li)
		//histórico linha 2
		if !empty(aDados1[4])
			FmtLin(@aDados1,aL[18],,,@Li)
		endif
		//histórico linha 3
		if !empty(aDados2[4])
			FmtLin(@aDados2,aL[18],,,@Li)
		endif
	EndIf

	dbSelectArea( "TRB" )
	dbSkip()

	// Total do Dia
	If (nEntDay+nSaiDay+nPerDay) > 0 .And. mv_par11 == 1 .And. cDia <> StrZero(Day(TRB->DTDIGIT),2)
		If li > 56
			aDados:=Array(14)
			R470Cabec(@Li,@nPaginas,aInfoCabec)
		EndIf
		aDados:=Array(14)
		FmtLin(@aDados,aL[18],,,@Li)
		aDados[04]:=STR0025+cDIA+":" //"Sub-Total do Dia "
		aDados[05]:=Transform(nEntDay,cPicD1Qt)
		aDados[06]:=Transform(nSaiDay,cPicD1Qt)
		aDados[07]:=Transform(nPerDay,cPicD1Qt)
		aDados[08]:=Transform(nSalEst,cPicD1Qt)
		FmtLin(@aDados,aL[18],,,@Li)
		nEntDay:=nSaiDay:=nValEntDay:=nValSaiDay:=nIpiEntDay:=nIpiSaiDay:=nPerDay:=0
		If Li > 56
			While Li < 60
				FmtLin(@aDados,aL[18],,,@Li)
				If Li == 60
					FmtLin(,aL[01],,,@Li)
				EndIf
			EndDo
		Else
			FmtLin(@aDados,aL[18],,,@Li)
		EndIf
	Endif

	// Total do Periodo
	If lImpPeri
		If cProd <> TRB->PRODUTO
			If lImpr
				If li > 56
					aDados:=Array(14)
					R470Cabec(@Li,@nPaginas)
				EndIF
				aDados:=Array(14)
				aDados[04]:=STR0026	//"Total do Periodo:"
				aDados[05]:=Transform(nEntPer,cPicD1Qt)
				aDados[06]:=Transform(nSaiPer,cPicD1Qt)
				aDados[07]:=Transform(nPerPer,cPicD1Qt)
				aDados[08]:=Transform(nSalEst,cPicD1Qt)
				FmtLin(@aDados,aL[18],,,@Li)
				While Li < 60
					FmtLin(@aDados,aL[18],,,@Li)
					If Li == 60
						FmtLin(,aL[01],,,@Li)
					EndIf
				End
			EndIf

			lFirst1 := .t.
			// Procurar Totais do Produto no aSalEst
			nPos := ASCAN(aSalEst,{|x| x[1] == cProd})
			If nPos == 0
				AADD(aSalEst,{cProd,nSalEst})
			Else
				// Grava Saldos do Produto Totalizado no Periodo no aSalEst
				aSalEst[nPos,2]:=nSalEst
			EndIf

			nEntDay:=nSaiDay:=nValEntDay:=nValSaiDay:=nIpiEntDay:=nIpiSaiDay:=nPerDay:=0
			nEntPer:=nSaiPer:=nValEntPer:=nValSaiPer:=nIpiEntPer:=nIpiSaiPer:=nSalEst:=nPerPer:=0

			// Procura Saldos Iniciais do Proximo Produto no aSalEst
			nPos := ASCAN(aSalEst,{|x| x[1] == TRB->PRODUTO})
			If nPos > 0
				If mv_par15 == 1 .And. nPaginas == mv_par14
					nPaginas:= IIF(mv_par08<=1,2,mv_par08)
				EndIf
				nSalEst := aSalEst[nPos,2]
			EndIf
		EndIf
	Else
		If cProd <> TRB->PRODUTO .Or. cPer <> TRB->PERIODO
			If lImpr
				If li > 56
					aDados:=Array(14)
					R470Cabec(@Li,@nPaginas)
				EndIF
				aDados:=Array(14)
				aDados[04]:=STR0026	//"Total do Periodo:"
				aDados[05]:=Transform(nEntPer,cPicD1Qt)
				aDados[06]:=Transform(nSaiPer,cPicD1Qt)
				aDados[07]:=Transform(nPerPer,cPicD1Qt)
				aDados[08]:=Transform(nSalEst,cPicD1Qt)
				FmtLin(@aDados,aL[18],,,@Li)
				While Li < 60
					FmtLin(@aDados,aL[18],,,@Li)
					If Li == 60
						FmtLin(,aL[01],,,@Li)
					EndIf
				End
			EndIf

			lFirst1 := .t.
			// Procurar Totais do Produto no aSalEst
			nPos := ASCAN(aSalEst,{|x| x[1] == cProd})
			If nPos == 0
				AADD(aSalEst,{cProd,nSalEst})
			Else
				// Grava Saldos do Produto Totalizado no Periodo no aSalEst
				aSalEst[nPos,2]:=nSalEst
			EndIf

			nEntDay:=nSaiDay:=nValEntDay:=nValSaiDay:=nIpiEntDay:=nIpiSaiDay:=nPerDay:=0
			nEntPer:=nSaiPer:=nValEntPer:=nValSaiPer:=nIpiEntPer:=nIpiSaiPer:=nSalEst:=nPerPer:=0

			// Procura Saldos Iniciais do Proximo Produto no aSalEst
			nPos := ASCAN(aSalEst,{|x| x[1] == TRB->PRODUTO})
			If nPos > 0
				If mv_par15 == 1 .And. nPaginas == mv_par14
					nPaginas:= IIF(mv_par08<=1,2,mv_par08)
				EndIf
				nSalEst := aSalEst[nPos,2]
			EndIf
		EndIf
	EndIf
EndDo

dbSelectArea("SB1")
dbClearFilter()
IF !EMPTY(cArq1) .AND. FILE(cArq1 + OrdBagExt())
	RetIndex('SB1')
	FERASE(cArq1 + OrdBagExt())
ENDIF
dbSetOrder(1)
dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

dbSelectArea("SD2")
dbSetOrder(1)

dbSelectArea("SD3")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termos Abertura e Encerramento                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpTermos // Impressao dos Termos
	cArqAbert := GetMV("MV_RMEDAB")
	cArqEncer := GetMV("MV_RMEDEN")
	SBM->(dbSelectArea("SBM"))
	SBM->(dbSetOrder(1))
	SBM->(dbSeek(xFilial("SBM")+MV_PAR03))
	Iif(!Empty(cArqAbert),RptStatus({|| ImprimeTermo(mv_par14,cArqAbert,220,cPerg,Upper(SBM->BM_DESC))},Titulo),.T.)
	Iif(!Empty(cArqEncer),RptStatus({|| ImprimeTermo(mv_par14,cArqEncer,220,cPerg,Upper(SBM->BM_DESC))},Titulo),.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Ambiente                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
EndIf

dbSelectArea( "TRB" )
dbCloseArea()
Ferase(cArqTrab1+".DBF")
Ferase(Left(cArqTrab1,7)+"I"+OrdBagExt())
If aReturn[8] > 1
	Ferase(cArqTrab2+OrdBagExt())
EndIf
MS_FLUSH()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R470Cabec³ Autor ³ Mary C. Hergert       ³ Data ³30/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cabecalho Relatorio Especifico - Medicamentos Controlados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR924                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R470Cabec(Li,nPaginas,aInfoCabec)
Local cPeriodo
Local cPicCgc
Local cLivro	:= ""
Local dDtIni	:= mv_par04
Local dDtFim	:= mv_par05
Local lImpPeri  := GetNewPar("MV_IMPPERI",.F.)
Local lPort34498	:= .F.

DEFAULT aInfoCabec:={}

If (cPaisLoc=="BRA")
	cPicCgc:="@R 99.999.999/9999-99"
Else
	cPicCgc:=PesqPict("SA1","A1_CGC")
EndIf

lPort34498 := Mt924Port() //Verifica se reinicia a numeração pela regra a Portaria 344/98 da Anvisa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicia a Numeracao das Paginas por feixe                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPaginas >= IIf(mv_par14 <= 2,500,mv_par14) .And. mv_par15 == 1) .Or. lPort34498
   nPaginas := IIF(mv_par08<=1,2,mv_par08)
Endif

If Li <= 60
	While Li<60
		FmtLin(@aDados,aL[11],,,@Li)
	End
	FmtLin(,aL[01],,,@Li)
EndIf
Li:=00
@ Li++,000 PSAY AvalImp(220)
FmtLin(,{aL[01],aL[02],aL[03]},,,@Li)
FmtLin({SM0->M0_NOMECOM},aL[04],,,@Li)
FmtLin(,aL[05],,,@Li)
FmtLin({InscrEst(),Transform(SM0->M0_CGC,cPicCgc)},aL[06],,,@Li)
FmtLin(,aL[07],,,@Li)
cLivro := Mt924Livro()
If lImpPeri
	FmtLin({StrZero(nPaginas,5),StrZero (Day(dDtIni), 2)+"/"+StrZero (Month (dDtIni), 2)+"/"+StrZero (Year (dDtIni), 4)+" - "+StrZero (Day(dDtFim), 2)+"/"+StrZero (Month (dDtFim), 2)+"/"+StrZero (Year (dDtFim), 4),cLivro},aL[08],,,@Li)
Else
	cPeriodo:=Right(TRB->PERIODO,2)+"/"+Left(TRB->PERIODO,4)
	FmtLin({StrZero(nPaginas,5),cPeriodo,cLivro},aL[08],,,@Li)
EndIf
FmtLin(,aL[09],,,@Li)
If Len(aInfocabec) = 0
	FmtLin(;
	{ AllTrim(TRB->PRODUTO) + " - " + SUBS(TRB->DESCRICAO,1,30),SUBS(TRB->PRATIVO,1,30),;
	  Alltrim(TRB->GRUPON),;
	};
	,aL[10],;
	,;
	,@Li;
	)
	FmtLin({ AllTrim(TRB->DESCESPEC)},aL[11],,,@Li)	
Else
	FmtLin(aInfoCabec,aL[10],,,@Li)
EndIf

FmtLin(,{aL[12],aL[13],aL[14],aL[15],aL[16],aL[17]},,,@Li)

NovaPg(@nPaginas,IIf(mv_par14 <= 2,500,mv_par14))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImprimeTermo³Autor³ Mary C. Hergert       ³ Data ³02/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Imprime termos de abertura e encerramento do Registro       ³±±
±±³          ³Especifico de Medicamentos                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprimeTermo(nPaginas,cArqTerm,nLargMax,cPerg,cGrupo)

Local cSvAlias  := Alias()
Local cAcentos  := "€ú\‡ú\ú\ú\…ú\†ú\„ú\ ú\ú\ˆú\Šú\‚ú\¡ú\“ú\”ú\•ú\¢ú\£ú"
Local cAcSubst  := "C,\c,\A~\A'\a`\a~\a~\a'\E'\e^\e`\e'\i'\o^\o~\o`\o'\U'"
Local aLayOut   := {}
Local aVariaveis:= {}
Local i			:= 0
Local w			:= 0
Local j			:= 0
Local cCaracter	:= ""
Local cLinha	:= ""
Local nPosAcento:= 0
Local cTexto	:= ""
Local cConteudo	:= ""
Local uConteudo

AADD(aVariaveis,{"VAR_IXB",VAR_IXB})
dbSelectArea("SM0")
For i:=1 to FCount()
	If FieldName(i)=="M0_CGC"
		AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
	ElseIf FieldName(i)=="M0_INSC"
		AADD(aVariaveis,{FieldName(i),InscrEst()})
	Else
		If FieldName(i)=="M0_NOME"
			Loop
		Endif
		AADD(aVariaveis,{FieldName(i),FieldGet(i)})
	Endif
Next

For i:= 1 to 19
	uConteudo := &("mv_Par"+Strzero(i,2,0))
	If Valtype(uConteudo)=="N"
		cConteudo := Alltrim(Str(uConteudo))
	Elseif Valtype(uConteudo)=="D"
		cConteudo := Alltrim(dToc(uConteudo))
	Else
		cConteudo := Alltrim(uConteudo)
	Endif
	AADD(aVariaveis,{Rtrim(Upper("mv_Par"+Strzero(i,2,0))),cConteudo})
Next i


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclusao de variaveis especificas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
AADD(aVariaveis,{"M_MES",MesExtenso()})
AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})
AADD(aVariaveis,{"M_GRUPO",cGrupo})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena os arrays colocando primeiro a variavel de tamanho    ³
//³ maior para que a rotina nao pegue uma variavel menor         ³
//³ primeiro ( exemplo M0_TEL e M0_TEL_IMP )                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ASort( aVariaveis,,, { |x,y| Len( x[1] ) > Len( y[1] ) } )

cTexto:=MemoRead(cArqTerm)
For w:=1 to len(aVariaveis)
	cTexto	:=	StrTran(cTexto,aVariaveis[w,1],if(valtype(aVariaveis[w,2])<>"C" .and. valtype(aVariaveis[w,2])<>"U",if(valtype(avariaveis[w,2])="D",dtoc(aVariaveis[w,2]),str(aVariaveis[w,2])),aVariaveis[w,2]))
Next
@ 0,0 PSAY AvalImp(nLargMax)

For i:=1 to Mlcount(cTexto,nLargMax)
	SysRefresh()
	cLinha	:=	MemoLine(cTexto,nLargMax,i)
	cLinha	:=	Strtran(cLinha,chr(13)+chr(10))
	For j:=1 to Len(cLinha)
		cCaracter	:=	Substr(cLinha,j,1)
		nPosAcento	:=	Rat(cAcentos,cCaracter)
		If nPosAcento>0
			cCaracter:=Substr(AcSubst,nPosAcento,2)
			@ i,j PSAY Substr(cCaracter,1,1)
			@ i,j PSAY Substr(cCaracter,2,1)
		Else
			@ i,j PSAY cCaracter
		Endif
	Next j
Next i

dbSelectArea(cSvAlias)

Return Nil

// ---------------------------------------------------------
/*/{Protheus.doc} Mt924Port
Verifica se reinicia a numeração pela regra a Portaria 344/98 da Anvisa
@author José Eulálio
@since 23/09/2017
@version 12.1.17
/*/
// ---------------------------------------------------------
Static Function Mt924Port()
Local lRet	:= .F.

If !(Empty(cTpProd)) .And. cTpProd	<> TRB->TPPROD
	//Livro Entorpecentes
	If 	( AllTrim(TRB->TPPROD) == 'A1' .And. !(AllTrim(cTpProd) $ 'A1|A2' )) .Or. ;
		( AllTrim(TRB->TPPROD) == 'A2' .And. !(AllTrim(cTpProd) $ 'A1|A2' )) 
			lRet := .T.
	//Livro Psicotrópicos
	ElseIf ( AllTrim(TRB->TPPROD) == 'A3' .And. !(AllTrim(cTpProd) $ 'A3|B1|B2') ) .Or. ;
			( AllTrim(TRB->TPPROD) == 'B1' .And. !(AllTrim(cTpProd) $ 'A3|B1|B2') ) .Or. ;
			( AllTrim(TRB->TPPROD) == 'B2' .And. !(AllTrim(cTpProd) $ 'A3|B1|B2') ) 
				lRet := .T.
	//Livro Outras Substâncias sujeitas a controle especial
	ElseIf ( AllTrim(TRB->TPPROD) == 'C1' .And. !(AllTrim(cTpProd) $ 'C1|C2|C4|C5') ) .Or. ;
			( AllTrim(TRB->TPPROD) == 'C2' .And. !(AllTrim(cTpProd) $ 'C1|C2|C4|C5') ) .Or. ;
			( AllTrim(TRB->TPPROD) == 'C4' .And. !(AllTrim(cTpProd) $ 'C1|C2|C4|C5') ) .Or. ;
			( AllTrim(TRB->TPPROD) == 'C5' .And. !(AllTrim(cTpProd) $ 'C1|C2|C4|C5') ) 
				lRet := .T.
	//Livro Imunossupressores
	ElseIf AllTrim(TRB->TPPROD) == 'C3'
		lRet := .T.
	ElseIf AllTrim(TRB->PORTARIA) == 'outros' .And. AllTrim(cTpProd) $ 'A1|A2|A3|B1|B2|C1|C2|C4|C5'
		lRet := .T.
	EndIf
EndIf

cTpProd := TRB->TPPROD

Return lRet

Static Function Mt924Livro()
Local cLivro := "Substâncias/medicamentos não classific"
//Livro Entorpecentes
If 	AllTrim(TRB->TPPROD) $ 'A1|A2' 
	cLivro := "Medicamentos Entorpecentes"
//Livro Psicotrópicos
ElseIf AllTrim(TRB->TPPROD) $ 'A3|B1|B2' 
	cLivro := "Substâncias/medicamentos psicotrópicos "
//Livro Outras Substâncias sujeitas a controle especial
ElseIf AllTrim(TRB->TPPROD) $ 'C1|C2|C4|C5' 
	cLivro := "substâncias/medicamentos controle especial"
//Livro Imunossupressores
ElseIf AllTrim(TRB->TPPROD) == 'C3'
	cLivro := "Substâncias/medicamento imunossupressoras"
EndIf

Return cLivro
