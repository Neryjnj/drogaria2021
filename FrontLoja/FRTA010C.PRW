#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FRTA010C.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTLoadOrc³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega um orcamento aberto na retaguarda para finalizacao ³±±
±±³          ³ no FrontLoja. E solicitado que digite o Numero do Orcamento³±±
±±³          ³ ou pesquise os abertos. Esta solicitacao sera recebida e   ³±±
±±³          ³ processada pelo FRTA020 (Atraves do SLI Tipo "FV ") e      ³±±
±±³          ³ gravada no arquivo "LOADORC.FRT" para a sua leitura.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTLoadOrc()
Local oDlg 									// Objeto Dialog
Local aArray								// Array com informacoes
Local oNumOrc								// Obj numero do orcamento
Local oSim									// Obj Sim
Local oNao									// Obj Nao
Local oBtnPesq								// Obj Pesquisa
Local oBtnOK								// Obj Botao Ok
Local cNumOrc:=Space(TamSX3("L1_NUM")[1])	// Obj Numero do Orcamento
Local aKey									// Chaves

If ! CheckCaixa(@lCXAberto, @lUsaDisplay )		// Verifica se o Caixa Esta Aberto
	Return(NIL)									// E exibe Mensagem Caso Esteja Fechado
EndIf

If ! lOcioso
	// "Para carregar um Orçamento, é necessário Fechar a Venda ou Cancelar este Cupom Fiscal.", "Atenção"
	MsgStop(STR0014, STR0002)
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

If !FRTSemaStat("CON", cEstacao)
	//"No momento, não será possível Carregar um Orçamento pois o FrontLoja não está conectado à Retaguarda...", "Atenção"
	MsgStop(STR0001, STR0002)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
	Return(NIL)
EndIf

aArray := {{.F.,"",""}}
oSim   := LoadBitmap(GetResources(), "BR_VERDE")
oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")

DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 235,213 PIXEL	// "Carregamento de Orçamentos"

	@ 06,02 SAY STR0004 PIXEL	// "Orçamento:"
	@ 05,40 GET oNumOrc VAR cNumOrc SIZE 15,7 PIXEL PICTURE PesqPict("SL1","L1_NUM")
	DEFINE SBUTTON oBtnPesq FROM 03,78 PIXEL TYPE 14 ENABLE ONSTOP STR0005 ;	// "Pesquisar..."
		ACTION FRTPesqOrc(@oOrcamentos, @aArray, @oNumOrc, @cNumOrc)

	@ 18,02 TO 105,105.5 LABEL STR0006 PIXEL	// "Resultado da Pesquisa"
	@ 25,04 LISTBOX oOrcamentos FIELDS HEADER "",STR0007,STR0008 FIELDSIZES 7,30,70 SIZE 99,77.5 PIXEL	// "Orçamento","Cliente"
	oOrcamentos:SetArray(aArray)
	oOrcamentos:bLine := {|| {If(aArray[oOrcamentos:nAt,1],oSim,oNao),aArray[oOrcamentos:nAt,2],aArray[oOrcamentos:nAt,3]} }
	oOrcamentos:bLDblClick := {|| FRTNumClik(@oOrcamentos,@aArray,@oNumOrc,@cNumOrc)}
	oOrcamentos:Disable()

	DEFINE SBUTTON oBtnOK FROM 105,48 PIXEL TYPE 1 ENABLE ACTION If(!Empty(cNumOrc),FRTCarrega(@oDlg,cNumOrc),)
	DEFINE SBUTTON FROM 105,78 PIXEL TYPE 2 ENABLE ACTION oDlg:End()

ACTIVATE DIALOG oDlg CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTPesqOrc³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisar os Orcamentos em Aberto no Server da Retaguarda  ³±±
±±³          ³ e Exibi-los Para a Selecao.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTPesqOrc(oOrcamentos, aArray, oNumOrc, cNumOrc)
Local cNumero	:= ""		// Numero
Local cCliente	:= ""		// Cliente
Local cOrc		:= ""		// Orcamento
Local aRet					// Retorno

If Empty(cNumOrc)
	// "Pesquisar os Orçamentos em aberto poderá levar alguns segundos."+Chr(13)+;
	// "Caso você já saiba o Número do Orçamento, digite-o e clique em Ok. Prosseguir com a pesquisa?"+Chr(13)+;
	// "Prosseguir com a pesquisa?", "Pesquisar Orçamentos em Aberto"
	If !MsgYesNo(STR0009+Chr(13)+STR0010+Chr(13)+STR0011, STR0012)
		Return(NIL)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Orcamentos         ? (1-Data Atual 2-Todos)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte("FRT10C",.T.)
	Return(NIL)
EndIf

LJMsgRun(STR0013,,{|| aRet := FRTMyCall("FRTRPCOrc", {"SL1"}, MV_PAR01)})	// "Aguarde. Pesquisando os orçamentos em aberto..."
cOrc := aRet[2]
If Empty(cOrc)
	// "Não foi encontrado nenhum Orçamento em aberto para ser carregado!", "Atenção"
	MsgStop(STR0015, STR0002)
ElseIf Left(cOrc,4)=="ERRO"
	// "Erro ao pesquisar os Orçamentos em aberto. Tente novamente.", "Atenção"
	MsgStop(STR0016, STR0002)
Else
	aArray := {}												// Carrega os Orcamentos
	SA1->(DbSetOrder(1))
	While !Empty(cOrc)
		cNumero  := Left(cOrc, Len(SL1->L1_NUM))
		cOrc     := Substr(cOrc, Len(SL1->L1_NUM)+1)
		cCliente := Left(cOrc, Len(SL1->L1_CLIENTE))
		SA1->(DbSeek(xFilial("SA1")+cCliente))
		cOrc     := Substr(cOrc, Len(SL1->L1_CLIENTE)+1)
		AAdd(aArray, {.F., cNumero, SA1->A1_NOME})
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as Informacoes na Tela... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumOrc := Space(TamSX3("L1_NUM")[1])
	oNumOrc:Refresh()
	oOrcamentos:aArray := aArray
	oOrcamentos:Refresh()
	oOrcamentos:Enable()
	oOrcamentos:SetFocus()
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTNumClik³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marcar o Orcamento a Ser Finalizado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTNumClik(oOrcamentos, aArray, oNumOrc, cNumOrc)

If aArray[oOrcamentos:nAt,1]
	cNumOrc := Space(TamSX3("L1_NUM")[1])
	aArray[oOrcamentos:nAt,1] := .F.
Else
	AEval(aArray, {|x| x[1]:=.F.})
	aArray[oOrcamentos:nAt,1] := .T.
	cNumOrc := aArray[oOrcamentos:nAt,2]
	oOrcamentos:Refresh()
EndIf
oNumOrc:Refresh()

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRTRPCOrc³ Autor ³ Vendas Clientes       ³ Data ³30/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisar os Orcamentos em Aberto no Server da Retaguarda  ³±±
±±³          ³ Via RPC Pelo FRTA020.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ FRTA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTRPCOrc(nTipo)
Local cRet		:= ""
Local lFRTL1RPC := ExistBlock( "FRTL1RPC" )		// Ponto de entrada para filtrar o SL1 na consulta dos orcamentos
Local lUsaSL1	:= .T.							// Retorno do ponto de entrada FRTL1RPC
Local cSL1TEMP	:= GetNextAlias()				// Pega o proximo Alias Disponivel
Local cPart  	:= ""							// Dependendo do escolha filtra pelo dia							
Local cOrderBy	:= ""  							// Ordem da Query
Local lQuery	:= .F.

#IFDEF TOP  
	If TcSrvType() <> "AS/400"					// Verifica a possibilidade da utilizacao da query
		lQuery := .T.	
	EndIf	
#ENDIF

If lQuery
  	If nTipo == 1
		cPart := "%L1_EMISSAO	= '"+ DTOS(dDataBase)+"'	 AND%"
	Else
		cPart := "%%" 
	EndIf 	
	cOrderBy := "%L1_NUM , L1_CLIENTE%"        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para filtrar todos os dados necessarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BeginSql alias cSL1TEMP
		SELECT	L1_NUM ,L1_CLIENTE	 
	
		FROM %table:SL1% 
		WHERE	L1_FILIAL	=	%xfilial:SL1%			AND	
				L1_DTLIM 	>= 	%exp:DTOS(dDataBase)%	AND
				L1_SERIE    =  " "						AND
				L1_DOC      =  " "   	                AND
				L1_PDV      =  " "       	           	AND
				%exp:cPart%
				%notDel%
							
		ORDER BY %exp:cOrderBy%
	EndSql        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Forma a String de retorno concatenado o resultado da query ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cSL1TEMP)->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para fazer o filtro no SL1 se entra ou nao na       ³
		//³ consulta do caixa.                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFRTL1RPC
			lUsaSL1 := ExecBlock( "FRTL1RPC", .F., .F.,{cSL1TEMP} )
			If ValType( lUsaSL1 ) == "L"
				If !lUsaSL1
					(cSL1TEMP)->(dbSkip())
					Loop
				Endif
			Endif
  		Endif
		cRet	+= (cSL1TEMP)->L1_NUM + (cSL1TEMP)->L1_CLIENTE
		(cSL1TEMP)->(dbSkip())                        
	End	
Else   
	DbSelectArea("SL1")
	DbSetOrder(2)
	DbSeek(xFilial())
	While Empty(L1_SERIE+L1_DOC+L1_PDV) .AND. !EOF() .AND. (Len(cRet)+Len(L1_NUM)+Len(L1_CLIENTE) <= 300)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Orcamentos(nTipo): ³
		//³ 1 - Data Atual     ³
		//³ 2 - Todos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipo=1 .AND. L1_EMISSAO!=dDataBase
			DbSkip()
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contemplar Somente Orcamentos Nao Expirados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If L1_DTLIM < dDataBase
			DbSkip()
			Loop
		EndIf
		   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para fazer o filtro no SL1 se entra ou nao na       ³
		//³ consulta do caixa.                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFRTL1RPC
			lUsaSL1 := ExecBlock( "FRTL1RPC", .F., .F.,{"SL1"} )
			If ValType( lUsaSL1 ) == "L"
				If !lUsaSL1
					DbSkip()
					Loop
				Endif
			Endif
		Endif
		
		cRet += L1_NUM+L1_CLIENTE
		DbSkip()
	End
EndIf
Return({"OK", cRet})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTRPCLoad³ Autor ³ Vendas Clientes       ³ Data ³31/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gerar uma string com o Orcamento selecionado e retornar    ³±±
±±³          ³ Via RPC Pelo FRTA020.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ FRTA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Lay-out da String
//Tamanho Conteudo  Descricao
//2       Binario   Tamanho do Header (SL1)
//x       Caracter  Campos do Header (Separados por Chr(1))
//2       Binario   Quantidade de Registros (SL2)
// 2      Binario   Tamanho do Registro (SL2)
// x      Caracter  Campos do Registro (Separados por Chr(1))
//2       Binario   Quantidade de Registros (SL4)
// 2      Binario   Tamanho do Registro (SL4)
// x      Caracter  Campos do Registro (Separados por Chr(1))
Function FRTRPCLoad(cNumOrc)
Local i
Local aRet := {"",""}
Local cSL1 := ""
Local cSL2 := ""
Local cSL4 := ""
Local aSA1 := {}

DbSelectArea("SL1")
DbSetOrder(1)          

If FindFunction("U_FRTNUMORC")
	cNumOrc := U_FRTNUMORC(cNumOrc)
EndIf

If DbSeek(xFilial()+cNumOrc)
	If !Empty(L1_DOC)
		aRet := {"VENDIDO",""}
	Else
		If L1_DTLIM < dDataBase
			aRet := {"EXPIRADO",""}
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a String do SL1 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEstru := dbStruct()
			cSL1 := FRTDBF2Str(aEstru)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a String do SL2 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL2")
			DbSetOrder(1)
			aEstru := dbStruct()
			i := 0
			DbSeek(xFilial()+SL1->L1_NUM)
			While L2_FILIAL+L2_NUM == xFilial()+SL1->L1_NUM
				i++
				cSL2 += FRTDBF2Str(aEstru)
				DbSkip()
			End
			cSL2 := I2Bin(i)+cSL2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a String do SL4 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL4")
			DbSetOrder(1)
			aEstru := dbStruct()
			i := 0
			DbSeek(xFilial()+SL1->L1_NUM)
			While L4_FILIAL+L4_NUM == xFilial()+SL1->L1_NUM
				i++
				cSL4 += FRTDBF2Str(aEstru)
				DbSkip()
			End
			cSL4 := I2Bin(i)+cSL4
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o Array do SA1  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SA1")
			If DbSeek(xFilial()+SL1->L1_CLIENTE+SL1->L1_LOJA)
				For i := 1 To FCount()
					// Envia somente os campos nao vazios...
					If !Empty(FieldGet(i))
						AAdd(aSA1, {FieldName(i), FieldGet(i)})
					EndIf
				Next i
			EndIf			
			aRet := {"OK", cSL1+cSL2+cSL4, aSA1}
		EndIf
	EndIf
Else
	aRet := {"NOTFOUND", ""}
EndIf

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTDBF2Str³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pega Conteudo do Registro e Gera uma String com Chr(1)     ³±±
±±³          ³ Separando os Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRTDBF2Str(aEstru)
Local i
Local cRet   := ""
Local xField

For i := 1 To Len(aEstru)
	xField := FieldGet(i)
	If aEstru[i][2]="N"
		If xField==0
			cRet += Chr(1)
		Else
			cRet += Chr(1)+LTrim(Str(xField,aEstru[i][3],aEstru[i][4]))
		EndIf
	ElseIf aEstru[i][2]="D"
		cRet += Chr(1)+RTrim(DToS(xField))
	ElseIf aEstru[i][2]="L"
		cRet += Chr(1)+If(xField,"T","F")
	Else
		cRet += Chr(1)+RTrim(xField)
	EndIf
Next i
cRet := I2Bin(Len(cRet)-1)+Substr(cRet,2)
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³FRTAField ³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extrai o Conteudo do Campo na String.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTAField(cString, cField, nNumItem)
Local i
Local xRet
Local nField
Local nTamHeader
Local nStart
Local nLen:=0
Local nTamSL2
Local nTamSL4

Default nNumItem := 0

nTamHeader := Bin2I(Left(cString,2))
If Left(cField,2)=="L1"
	nField := SL1->(FieldPos(cField))
	cType  := ValType(SL1->(FieldGet(nField)))
	If cType == "C"
		nLen := Len(SL1->(FieldGet(nField)))
	EndIf
	xRet   := PegaField(cString, 3, nTamHeader, nField, cType, nLen)
ElseIf Left(cField,2)=="L2"
	nField := SL2->(FieldPos(cField))
	cType  := ValType(SL2->(FieldGet(nField)))
	If cType == "C"
		nLen := Len(SL2->(FieldGet(nField)))
	EndIf
	nItems := Bin2I(Substr(cString, nTamHeader+3, 2))
	nStart := nTamHeader+5
	For i := 1 To nNumItem
		nTamSL2 := Bin2I(Substr(cString, nStart, 2))
		If i == nNumItem
			xRet := PegaField(cString, nStart+2, nTamSL2, nField, cType, nLen)
		EndIf
		nStart += nTamSL2 + 2
	Next i
ElseIf Left(cField,2)=="L4"
	nField := SL4->(FieldPos(cField))
	cType  := ValType(SL4->(FieldGet(nField)))
	If cType == "C"
		nLen := Len(SL4->(FieldGet(nField)))
	EndIf
	nItems := Bin2I(Substr(cString, nTamHeader+3, 2))
	nStart := nTamHeader+5
	For i := 1 To nItems
		nTamSL2 := Bin2I(Substr(cString, nStart, 2))
		nStart += nTamSL2 + 2
	Next i
	nItems := Bin2I(Substr(cString, nStart, 2))
	nStart := nStart+2
	For i := 1 To nNumItem
		nTamSL4 := Bin2I(Substr(cString, nStart, 2))
		If i == nNumItem
			xRet := PegaField(cString, nStart+2, nTamSL4, nField, cType, nLen)
		EndIf
		nStart += nTamSL4 + 2
	Next i
EndIf
Return(xRet)
  
Static Function PegaField(cString, nPos, nTam, nField, cType, nLen)
Local i:=0, nAt, xRet
cString := Substr(cString, nPos, nTam)+Chr(1)
nAt := At(Chr(1), cString)
While nAt != 0
	i++
	xRet := Substr(cString, 1, nAt-1)
	If i == nField
		Exit
	EndIf
	cString := Substr(cString, nAt+1)
	nAt := At(Chr(1), cString)
End
If cType == "N"
	xRet := Val(xRet)
ElseIf cType == "L"
	xRet := xRet=="T"
ElseIf cType == "D"
	xRet := SToD(xRet)
ElseIf cType == "C"
	xRet := PadR(xRet, nLen)
EndIf
Return(xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTQtdSL2 ³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Quantos Items Existem no Orcamento.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTQtdSL2(cString)
Local nTamHeader
Local nItems

nTamHeader := Bin2I(Left(cString,2))
nItems     := Bin2I(Substr(cString, nTamHeader+3, 2))

Return(nItems)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTQtdSL4 ³ Autor ³ Vendas Clientes       ³ Data ³31/01/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Quantos Items Existem no SL4.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTQtdSL4(cString)
Local i
Local nTamHeader
Local nItems
Local nTamSL2

nTamHeader := Bin2I(Left(cString,2))
nItems     := Bin2I(Substr(cString, nTamHeader+3, 2))
nStart     := nTamHeader+5
For i := 1 To nItems
	nTamSL2 := Bin2I(Substr(cString, nStart, 2))
	nStart += nTamSL2 + 2
Next i

nItems := Bin2I(Substr(cString, nStart, 2))   

Return(nItems)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTMyCall ³ Autor ³ Vendas Clientes       ³ Data ³02/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza RPC para retornar o Orcamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTMyCall(	cFuncao, aFiles , uParm1 , uParm2 ,;
					uParm3 , uParm4 , uParm5 , uParm6 ,;
					uParm7 , uParm8 , uParm9 , uParm10,;
					uParm11, uParm12, uParm13, uParm14,;
					uParm15 )
Local oRPCServer
Local cRPCServer
Local nRPCPort
Local cRPCEnv
Local cRPCEmp
Local cRPCFilial
Local aAux
Local aRet
Local lRet

aAux		:= LjGetStation({"RPCSRV", "RPCPORT", "RPCENV", "RPCEMP", "RPCFIL"})
cRPCServer	:= aAux[1]
nRPCPort	:= Val(aAux[2])
cRPCEnv		:= aAux[3]
cRPCEmp		:= aAux[4]
cRPCFilial	:= aAux[5]

If cFuncao$"FRTRPCOrc/FRTRPCLoad"
	aAux := LjGetStation({"ORCSRV", "ORCPORT", "ORCENV", "ORCEMP", "ORCFIL"})
	If !Empty(aAux[1]) .AND. !Empty(aAux[2]) .AND. !Empty(aAux[3]) .AND. !Empty(aAux[4]) .AND. !Empty(aAux[5])
		cRPCServer	:= aAux[1]
		nRPCPort	:= Val(aAux[2])
		cRPCEnv		:= aAux[3]
		cRPCEmp		:= aAux[4]
		cRPCFilial	:= aAux[5]
	EndIf
EndIf

oRPCServer := TRPC():New( cRpcEnv )
If oRPCServer:Connect( cRPCServer, nRPCPort )
	If cFuncao == "GeraA1"
		oRPCServer:CallProc("RPCSetType", 3 )
		lRet := oRPCServer:CallProc("RPCSetEnv", cRPCEmp, cRPCFilial,,,,, aFiles)
		If ValType(lRet) == "L"
			If lRet
				aRet := oRPCServer:CallProc("GeraA1", uParm1)
				If ValType(aRet)=="A"
					If Left(aRet[1],2)=="OK"
						lRet := oRPCServer:CallProc("ConfA1", aRet[2])
						If ValType(lRet)=="L"
							cCod  := uParm1[AScan(uParm1,{|x|x[1]=="A1_COD"})][2]
							cLoja := uParm1[AScan(uParm1,{|x|x[1]=="A1_LOJA"})][2]
							// Se o Codigo gravado na Retaguarda foi diferente da base local, faz a correcao.
							If aRet[3] <> cCod
								FRTGeraSL("SA1", {{"A1_COD", aRet[3]}}, .F.)
							EndIf
							aRet := {"OK", "T"}
						Else
							aRet := {"ERRO", ""}
						EndIf
					Else
						aRet := {"ERRO", ""}
					EndIf
				Else
					aRet := {"ERRO", ""}
				EndIf
			Else
				aRet := {"ERRO", ""}
			EndIf
		Else
			aRet := {"ERRO", ""}
		EndIf
	Else
		aRet := oRPCServer:CallProc("FRTRPC", cFuncao, aFiles, cRPCEmp, cRPCFilial, uParm1, uParm2, uParm3, uParm4, uParm5, uParm6, uParm7, uParm8, uParm9, uParm10, uParm11, uParm12, uParm13, uParm14, uParm15)
	EndIf
	If ValType(aRet) == "A"
		oRPCServer:Disconnect()
	Else
		aRet := {"ERRO", ""}
	EndIf
Else
	aRet := {"ERRO", ""}
EndIf
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ RPCMyOrc ³ Autor ³ Vendas Clientes       ³ Data ³02/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza RPC para retornar o Orcamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTRPC( cFuncao, aFiles , cCodEmp, cCodFil,;
				 uParm1 , uParm2 , uParm3 , uParm4 ,;
				 uParm5 , uParm6 , uParm7 , uParm8 ,;
				 uParm9 , uParm10, uParm11, uParm12,;
				 uParm13, uParm14, uParm15 )
				 
Local cDrvX2 := "DBFCDX"
Local cArqX2 := "SX2" + cCodEmp + "0"
Local cDriver := "DBFCDX"
Local i
Local aRet
#IFDEF TOP
Local cAlias
Local cServer
Local cConType
Local cHasMapper
Local cProtect
Local nPort
Local __nConecta 
Local __cLastConn
Local xConnect
Local cDataBase
Local cIniFile := GetAdv97()
#ENDIF
Private dDataBase := MSDate()
Private cArqTab := ""
Private cEmpAnt := cCodEmp
Private cFilAnt := cCodFil

SET DELETED ON

#IFDEF WAXS
	cDrvX2 := "DBFCDXAX"
#ENDIF
#IFDEF WCODB
	cDrvX2 := "DBFCDXTTS"
#ENDIF

USE &(cArqX2) ALIAS "SX2" SHARED NEW VIA cDrvX2
If NetErr()
	UserException("SX2 Open Failed")
EndIf
DbSetOrder(1)
If Empty(IndexKey())
	UserException("SX2 Open Index Failed")
EndIf

#IFDEF TOP
	xConnect := GetGlbValue("MYTOPCONNECT")
	If Empty(xConnect)
		cDataBase := GetPvProfString("TopConnect","DataBase","ERROR",cInIfile )
		cAlias	  := GetPvProfString("TopConnect","Alias","ERROR",cInIfile )
		cServer	  := GetPvProfString("TopConnect","Server","ERROR",cInIfile )

		cConType  := Upper(GetPvProfString("TopConnect","Contype","TCPIP",cInIfile ))
		cHasMapper:= Upper(GetPvProfString("TopConnect","Mapper","ON",cInIfile ))
		cProtect  := GetPvProfString("TopConnect","ProtheusOnly","0",cInIfile )
		nPort     := Val(GetPvProfString("TopConnect","Port","0",cInIfile ))

		// Ajuste pelo Environment do Server
		cDataBase := GetSrvProfString("DBDataBase",cDataBase)
		cAlias	  := GetSrvProfString("DBAlias",cAlias)
		cServer	  := GetSrvProfString("DBServer",cServer)

		cConType  := Upper(GetSrvProfString("TopContype",cConType))
		cHasMapper:= Upper(GetSrvProfString("TopMapper",cHasMapper))
		cProtect  := GetSrvProfString("TopProtheusOnly",cProtect)
		nPort     := Val(GetSrvProfString("TopPort",StrZero(nPort,4,0)))   //Soh Para Conexao TCPIP

		xConnect := AllTrim(cDataBase) + "#" + AllTrim(cAlias) + "#" + AllTrim(cServer) + "#" + ;
					AllTrim(cConType) + "#" + AllTrim(cHasMapper) + "#" + AllTrim(cProtect) + "#" + ;
					StrZero(nPort,4,0)
				
		PutGlbValue("MYTOPCONNECT",xConnect)
	Else
		xConnect  := StrTokArr(xConnect,"#")
		cDataBase := xConnect[1]
		cAlias	  := xConnect[2]
		cServer	  := xConnect[3]
		cConType  := xConnect[4]
		cHasMapper:= xConnect[5]
		cProtect  := xConnect[6]
		nPort     := Val(xConnect[7])
	EndIf

	If !(AllTrim(cContype)$"TCPIP/NPIPE")
		UserException("Invalid ConType")
	EndIf

	If "ERROR" $ cDataBase+cAlias+cServer
		UserException("Configuration Error in .INI File")
	EndIf

	IF cProtect == "1"
		cProtect := "@@__@@"    //Assinatura para o TOP
	Else
		cProtect := ""
	Endif

	__cLastConn := cDatabase+";"+cAlias+";"+cServer

	TCConType(cConType)
	//__lHasMapper := (cHasMapper != "OFF")

	If (("AS" $ cAlias) .AND. ("400" $ cAlias))
		__nConecta := TCLink(cDataBase,cServer,nPort)
	Else
		__nConecta := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias,cServer,nPort)  // Nao Comer Licenca do Top
		IF __nConecta < 0
			ConOut("O erro de Conexao acima eh controlado, nao se Preocupe !!!!")
			ConOut("Para Elimina-lo atualize o TopConnect")
			__nConecta := TCLink(cProtect+cDataBase+"/"+cAlias,cServer,nPort)
		Endif
	EndIf

	If (__nConecta < 0)
		IF Empty(cProtect)
			UserException("TOPCONN Connection Failed - Error ("+Str(__nConecta,4,0)+")"+__cLastConn)
		Else
			UserException("TOPProtect Connection Failed - Error ("+Str(__nConecta,4,0)+")"+__cLastConn)
		Endif
	EndIf
	TcInternal( 8, "RPC->"+cFuncao )
	cDriver := "TOPCONN"
	TcSetDummy(.T.)
#ENDIF                 
#IFDEF AXS
	cDriver := "DBFCDXAX"
#ENDIF
#IFDEF CTREE
	cDriver := "CTREECDX"
#ENDIF                 
#IFDEF BTV
	cDriver := "BTVCDX"
#ENDIF

For i := 1 To Len(aFiles)
	OpenFile(aFiles[i], cDriver)
Next i

#ifdef TOP
	TcSetDummy(.F.)
#endif      

aRet := &cFuncao.(uParm1, uParm2, uParm3, uParm4, uParm5, uParm6, uParm7, uParm8, uParm9, uParm10, uParm11, uParm12, uParm13, uParm14, uParm15)

SET DELETED OFF

dbCloseAll()
#IFDEF TOP
	TCQUIT()
#ENDIF

Return aRet

Static Function OpenFile(cAlias, cDriver)
Local cArquivo

DbSelectArea("SX2")
DbSetOrder(1)
If DbSeek(cAlias)
	#ifdef TOP
		cArquivo := AllTrim(SX2->X2_ARQUIVO)
	#else
		cArquivo := AllTrim(SX2->X2_PATH) + AllTrim(SX2->X2_ARQUIVO)
	#endif
	
	USE &(cArquivo) ALIAS &(cAlias) SHARED NEW VIA cDriver
	If NetErr()
		UserException(cAlias + " Open Failed")
	EndIf                           
	cArqTab += cAlias+SX2->X2_MODO
	#ifdef TOP
		DbSetIndex(cArquivo + "1")
		If cAlias == "SL1"
			DbSetIndex(cArquivo + "2")
		EndIf
		If cAlias == "SD2"
			DbSetIndex(cArquivo + "2")
			DbSetIndex(cArquivo + "3")
		EndIf		
	#endif
	DbSetOrder(1)
	If Empty(IndexKey())
		UserException(cAlias + " Open Index Failed")
	EndIf
Else
	UserException(cAlias + " Not Found in SX2")
EndIf
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FRTCliente³ Autor ³ Vendas Clientes       ³ Data ³ 04/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastramento de Clientes diretamente no Check-Out         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTCliente
Local i
Local nGravado
Local aSA1 := {}
Local lBscCliON := SuperGetMV("MV_LJCLION", ,.F.) //Identifica se o Front ira se conectar com a Retaguarda

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SA1")
aCamposInc := {}
While !EOF() .AND. X3_ARQUIVO=="SA1"
	If X3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL
		If AllTrim(X3_CAMPO)!="A1_SITUA"
			AAdd(aCamposInc, X3_CAMPO)
		EndIf
	EndIf
	DbSkip()
End

If ExistBlock("FRTCPSA1")
	aCamposInc := ExecBlock("FRTCPSA1", .F., .F., aCamposInc)
EndIf

DbSelectArea("SA1")
nGravado := AXInclui("SA1", Recno(), 3, aCamposInc,,,"FRTCliOK()")
If nGravado == 1
	If ExistBlock("FRTGRSA1")
		aSA1 := ExecBlock("FRTGRSA1", .F., .F., aSA1)
	EndIf
	// Grava o A1_SITUA local como "00" - Gravado com Sucesso
	AAdd(aSA1, {"A1_SITUA", "00"})
	FRTGeraSL("SA1", aSA1)

	If !lBscCliON
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o SA1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSA1 := Array(FCount())
		For i := 1 To FCount()
			aSA1[i] := {FieldName(i), FieldGet(i)}
		Next i
		LJMsgRun(STR0017,, {|| FRTProcSA1(aSA1)})	// "Aguarde. Atualizando o Cliente na Retaguarda..."		
	EndIf
	
EndIf
Return(NIL)

Function FRTProcSA1(aSA1)
// Se estiver conectado a Retaguarda
If FRTSemaStat("CON", cEstacao)
	// Se gravou na Retaguarda
	If FRTMyCall("GeraA1", {"SA1"}, aSA1)[2] == "T"
		// Grava o A1_SITUA local com "TX" - Enviado
		aSA1 := {{"A1_SITUA", "TX"}}
		FRTGeraSL("SA1", aSA1)
	Else
		// Informar ao FRTA020 que tem SA1 para ser gravado na Retaguarda
		FRTGeraSLI("    ", "SA1", Str(Recno(),17,0), "NOVO")
		// "Inclusão de Clientes" ### "Não foi possível atualizar este Cliente na Retaguarda. Ele será atualizado posteriormente."
		Aviso(STR0018, STR0019, {"Ok"})
 		EndIf
Else
	// Informar ao FRTA020 que tem SA1 para ser gravado na Retaguarda
	FRTGeraSLI("    ", "SA1", Str(Recno(),17,0), "NOVO")
	// "Inclusão de Clientes" ### "Não foi possível atualizar este Cliente na Retaguarda. Ele será atualizado posteriormente."
	Aviso(STR0018, STR0019, {"Ok"})
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRTCliOk ³ Autor ³ Vendas Clientes       ³ Data ³ 04/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Cliente Via RPC na Retaguarda                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTCliOk
Local lExistSA1 := .F.  

If FRTSemaStat("CON", cEstacao)

	lExistSA1	:= (FR271CMyCall("FRTRPCCLOk", {"SA1"} , M->A1_COD+M->A1_LOJA)[2] == "T")
	If lExistSA1
		// "Inclusão de Clientes" ### "Este código de cliente já foi utilizado na Retaguarda. Por favor, informe um outro código válido."
		Aviso(STR0018, STR0020, {"Ok"})
	EndIf
Else
	// "Inclusão de Clientes" ### "Não é possível validar este código de cliente, pois não há conexão com a Retaguarda. Este código será validado posteriormente."
	Aviso(STR0018, STR0021, {"Ok"})
EndIf
Return (!lExistSA1)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FRTRPCCLOk³ Autor ³ Vendas Clientes       ³ Data ³ 04/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se cliente existe na retaguarda                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTRPCCLOk(cChave)
Local aRet := {"OK", "F"}

If SA1->(DbSeek(xFilial()+cChave))
	aRet := {"OK", "T"}
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FRTPGlobal³ Autor ³ Vendas Clientes       ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica o cupom a ser deletado pertence a uma factura     ³±± 
±±³          ³ global.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTPGlobal(cNumNota, cSerNota, cCliente, cLoja)
Local cMsg		 := ""					// Mensagem que serah apresentada ao usuario
Local lRet		 := ""					// Retorno, se permite prosseguir ou nao com o cancelamento do cupom
Local cNfOri	 := ""					// Conteudo do campo SF2->F2_NFORI
Local cSerOri	 := ""					// Conteudo do campo SF2->F2_SERIORI
Local aRet		 := {}					// Array com o retorno da funcao
Local nTamF2_DOC := Len(cNumNota)		// Tamanho do campo F2_DOC 

cNumNota := PadR(cNumNota,nTamF2_DOC)                               

DbSelectArea("SF2")
DbSetOrder(1)
If DbSeek( xFilial( "SF2" ) + cNumNota + cSerNota )
	If Empty( SF2->F2_NFORI )
		cMsg := "OK"
		lRet := .T.
	Else
		cNfOri := SF2->F2_NFORI
		cSerOri:= SF2->F2_SERIORI
		If DbSeek( xFilial( "SF2" ) + cNfOri + cSerOri )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for Mexico valida o conteudo do campo F2_GLOBAL³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "MEX"
				If FieldPos("F2_GLOBAL") > 0
					If AllTrim(SF2->F2_GLOBAL) <> "1"			
						cMsg := "OK"
						lRet := .T.
					Else
						cMsg := "GLOBAL"
						lRet := .F.			
					EndIf
				Else
					cMsg := "OK"
					lRet := .T.
				EndIf
			Endif
		Endif
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o campo NFCUPOM estah preenchido  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMsg == "OK"
		If DbSeek( xFilial( "SF2" ) + cNumNota + cSerNota )
			If FieldPos("F2_NFCUPOM") > 0
				If !Empty(SF2->F2_NFCUPOM)
					cMsg := "NFCUPOM"
					lRet := .F.
				Endif
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existem itens devolvidos para essa venda.³
		//³Se houver, não permite a exclusao.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet 
			DbSelectArea("SD2")
			DbSetOrder(3)      
			If DbSeek( xFilial("SD2") + cNumNota + cSerNota + cCliente + cLoja )
				While !Eof() .AND.	(	xFilial("SD2")	== SD2->D2_FILIAL) 	.AND. ;
									(	SD2->D2_DOC 	== cNumNota 		.AND. ;
										SD2->D2_SERIE 	== cSerNota			.AND. ;
										SD2->D2_CLIENTE	== cCliente			.AND. ;
										SD2->D2_LOJA 	== cLoja			.AND. ;
										lRet	)	
					If SD2->D2_QTDEDEV > 0
						cMsg := "QTDEDEV"
						lRet := .F.
					EndIf
					DbSkip()
					Loop
				End
			EndIf
 		EndIf
	Endif
Else
	cMsg := "OK"
	lRet := .T.	
EndIf          

aRet := {cMsg,lRet}

Return(aRet)