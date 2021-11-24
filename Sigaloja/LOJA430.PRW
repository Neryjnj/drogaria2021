#INCLUDE "TCBROWSE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA430.CH" 
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LOJA430  ³ Autor ³ Vendas Clientes       ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Distribuicao de mercadoria entre as as filiais            -³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA430()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±                                               
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Loja430()
Local lRet	:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valores possiveis no Campo LM_STATUS:           ³
//³                                                ³
//³1 - Gerar Pedido                                ³
//³2 - Gerar Faturamento s/ Meio Magnético         ³
//³3 - Gerar Pedido com Meio Magnetico ( Não usado)³
//³4 - Gerar Faturamento com meio magnetico        ³
//³5 - Pedido processado                           ³
//³------------ Exclusivo Localizacoes ------------³
//³6 - Gerar Remito                                ³ 
//³7 - Gerar Remito com Meio Magnetico             ³
//³8 - Remito processado                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCores    := {}


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
PRIVATE aRotina := MenuDef()

PRIVATE cCadastro :=  STR0039   // "Distribui‡Æo de mercadoria"                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oBtnEst
Private aCpoUsrSLM 	:= {}
Private aCpoUsrSLN 	:= {}

//³Release 11.5 - SmartClient HTML³
If ExistFunc("LjChkHtml")
	If LjChkHtml()
		FwAvisoHtml()
		lRet := .F.
	EndIf
EndIf

If lRet
	If cPaisLoc == "BRA"
		aCores := {{ 'LM_STATUS=="1"' , 'ENABLE'    },;  // Pedido
		           { 'LM_STATUS=="2"' , 'BR_AZUL'   },;  // Faturamento s/ Meio Magnetico
		           { 'LM_STATUS=="3"' , 'ENABLE'    },;  // Pedido com Meio Magnetico
		           { 'LM_STATUS=="4"' , 'BR_AMARELO'},;  // Faturamento com Meio Magnetico
		           { 'LM_STATUS=="5"' , 'DISABLE'}  }    // Distribuicao processada
	Else
		aCores := {{ 'LM_STATUS=="6"' , 'BR_AZUL'   },;  // Remito s/ Meio Magnetico
		           { 'LM_STATUS=="7"' , 'BR_AMARELO'},;  // Remito com Meio Magnetico
		           { 'LM_STATUS=="8"' , 'DISABLE'}  }    // Distribuicao processada
	EndIf
	
	DbSelectArea("SLM")
	DbSetOrder(1)
	DbSeek(xFilial("SLM"))
	
	mBrowse(6, 1,22,75,"SLM",,,,,,aCores)
EndIf

Return Nil  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³12/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef() 
Local aRotina:= { 	 {STR0001, "AxPesqui", 0, 1 , , .F.},;  // Pesquisar
                     {STR0002, "AxVisual", 0, 2 , , .T.},;  // Visualizar
                     {STR0003, "Lj430INI", 0, 3 , , .T.},;  // Incluir
                     {STR0004, "Lj430INI", 0, 4 , , .T.},;  // Alterar
                     {STR0005, "Lj430Exc", 0 ,5 , , .T.},;  // Excluir
                     {STR0006, "Lj430Ger", 0, 7 , , .T.},;  // Processar
                     {STR0007, "lj430Leg", 0, 8 , , .T.} }  // Legenda
Return ARotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj430INI	³ Autor ³ Vendas Clientes       ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Browse para distribuicao dos produtos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj430INI(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - Alias enviado pelo browse                         ³±±
±±³          ³ nReg   - registro atual enviado pelo browse                ³±±
±±³          ³ nOpc   - Numero da opcao selecionada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj430INI( cAlias, nReg, nOpc )
Local aPosEnchoice					// Posicao Enchoice
Local oGroup						// Group
Local nCheck 						// Check
Local oCheck3						// Check 3
Local lCheck3 	:= .F.				// Check 3
Local oFnt1							// Fonte 1
Local oFnt3							// Fonte 3
Local aBkRotina						// Bkp das rotinas
Local cx3Valid						// Valid do X3
Local lX3Uso						// Uso no SX3
Local nSaveSx8 	:= GetSx8Len()		// Get SX8
Local oTxt 							// Objeto para texto
Local nX	   	:= 0				// Contador de For
Local aAlterGD  := {}              	// Campos que podem ser alterados

Local oPanelCab						// Objeto do tipo tPanel posicionado no cabecalho da tela 
Local oPanelCen						// Objeto do tipo tPanel posicionado no centro da tela 
Local aButtons := {}				// Array com os botoes acrescentados no EnchoiceBar
Local aSizeAut 	:= MsAdvSize()		// Tamanho da tela. 
Local aObjects 	:={}				// Posicao da Tela
Local aInfo  	:={}				// Posicao da Tela
Local aPosObj 	:={}				// Posicao da Tela
Local lLJ430BU1 := ExistBlock("LJ430BU1") //Validar a existencia do ponto de entrada "LJ430BU1"

Private oDlgLoja
                     
Private aCampos                     
Private aHeader						
Private aCols						
Private aRotina
Private aCpoEnchoice
PRIVATE aGETS   := {}
PRIVATE aTELA   := {}
Private nPosCProd					// Usado na consulta padrao do campo LN_LOTE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao das variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPosEnchoice := {3,2,48,310}
aBkRotina	 := aclone(aRotina)
nCheck   	 := 1
nOpcx    	 := 3
nUsado   	 := 0
aCampos  	 := {}
aHeader  	 := {}
aCols    	 := {}

aRotina  := {{STR0001 ,"AxPesqui", 0, 1},;    // Pesquisar
             {STR0002, "AxVisual", 0, 2},;    // Visualizar
             {STR0004, "AxAltera", 0, 4},;    // Altera
             {STR0003, "AxInclui", 0, 5}}     // Inclui

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a distribuição jah foi processada            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLM")
If LM_STATUS == '5' .AND. nOpc <> 3
   MsgInfo(STR0009) //' Distribuição já processadas'
   Return .T.
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria um array com os campos que irao aparecer na enchoice³
//³e chama um ponto de entrada para o cliente customizar    ³
//³campos de usuario.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	aCpoEnchoice := {"LM_CLIENTE","LM_LOJA","LM_NUM","LM_COND","LM_FORMA"}
Else
	aCpoEnchoice := {"LM_CLIENTE","LM_LOJA","LM_NUM"}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz o tratamento para os campos de usuario       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivo + Ordem  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSetOrder( 1 ) 	
DbSeek( "SLM" )
While !Eof() .AND. SX3->X3_ARQUIVO == "SLM"
	If SX3->X3_PROPRI == "U" .AND. X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		aAdd( aCpoEnchoice,	SX3->X3_CAMPO )
		aAdd( aCpoUsrSLM, 	SX3->X3_CAMPO )
	EndIf
	DbSelectArea("SX3")
	DbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao do array ( aHeader,aCampos ) das colunas do Browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria o aHeader e aCols pelo FillGetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJ430FillGet( nOpc )
EndIf

DbSelectArea("Sx2")
DbSeek("SLN")
DbSelectArea("Sx3")
DbSeek( "SLN" )
While !Eof() .AND. (x3_arquivo == "SLN")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O Uso do Campo LN_LOCAL Esta Fixo, Pois o Mesmo Saiu ERRADO no SX3 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lX3Uso := X3USO(X3_USADO)
	If AllTrim(X3_CAMPO) $ "LN_LOCAL|LN_ITEM"
		lX3Uso := .T.
	EndIf

	If lX3Uso .AND. cNivel >= x3_nivel 
		Aadd( aCampos, x3_campo )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definicao do array que contem os campos da getdados que      ³
		//³ poderao ser alterados                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If "LN_ITEM" <> AllTrim(SX3->X3_CAMPO)
			Aadd( aAlterGD, AllTrim(X3_CAMPO) )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Trata os campos de usuário ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SX3->X3_PROPRI == "U"
			aAdd( aCpoUsrSLN, SX3->X3_CAMPO )
		EndIf
	EndIf
	DbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usado na consulta padrao do campo LN_LOTECTL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosCProd := AScan(aHeader, {|x| AllTrim(x[2])=="LN_COD"})

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SLM")
While !Eof() .AND. (X3_ARQUIVO == "SLM")
	If X3Uso(SX3->X3_USADO) .AND. (cNivel >= SX3->X3_NIVEL)
	   M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
    EndIf
    DbSkip()
End          
//ÚÄÄÄÄÄÄÄÄÄ¿
//³Alteracao³
//ÀÄÄÄÄÄÄÄÄÄÙ
If nOpc = 4  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa as variaveis de aCols e M->LM_??? com os dados do do SLM/SLN³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Lj430AL(nReg,@lCheck3,@nCheck,nOpc) 
EndIf   

For nX := 1 To Len(aHeader)

	If Alltrim(aHeader[nX][2]) == "LN_COD"
		aHeader[nX][6]	:= "LJ430VLD()"
	ElseIf Alltrim(aHeader[nX][2]) == "LN_QUANT"
		aHeader[nX][6]	:= "LJ430QTD(0)"
	ElseIf Alltrim(aHeader[nX][2]) == "LN_LOTECTL"
		aHeader[nX][6]	:= "LJ430Rastr('LN_LOTECTL')"
	ElseIf Alltrim(aHeader[nX][2]) == "LN_NLOTE"
		aHeader[nX][6]	:= "LJ430Rastr('LN_NLOTE')"     
	ElseIf Alltrim(aHeader[nX][2]) == "LN_TES"
		aHeader[nX][6] 	+= ".AND.M->LN_TES >='501'"
	EndIf	

Next nX	

nReg:=RECNO() 	

DEFINE MSDIALOG oDlgLoja FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0008 PIXEL OF GetWndDefault() //"Distribuição para Lojas"           

DEFINE FONT oFnt1 NAME "Courrier"
DEFINE FONT oFnt3 NAME "Arial" BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Painel Cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanelCab:= tPanel():New(0,0,"",oDlgLoja,,,,,,,55)
oPanelCab:Align:= CONTROL_ALIGN_TOP

oEnchMod3:= MsMGet():New("SLM", nReg, 3,,,, aCpoEnchoice,,,5,,,,oPanelCab,,.T.)	    
oEnchMod3:oBox:Align := CONTROL_ALIGN_ALLCLIENT	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Painel Central³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanelCen:= tPanel():New(0,0,"",oDlgLoja,,,,,,,)
oPanelCen:Align:= CONTROL_ALIGN_ALLCLIENT

oGet := MSGetDados():New(0.1,0.1,98,610,3,"LJ430LIN",,"+LN_ITEM",.T.,aAlterGD,,,1000,,,,,oPanelCen)   	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Saida do Dostribução³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 100,1 GROUP oGroup TO 146,175 LABEL STR0011 OF oPanelCen PIXEL //Saida da distribuição
oGroup:SetFont(oFnt3)

If cPaisLoc == "BRA"    	
	@ 118,15 RADIO oCheck1 VAR nCheck 3D SIZE 60,20 PROMPT; 
	STR0012, STR0013 OF oPanelCen PIXEL ;			
	ON CHANGE LJ430Chg(nCheck,@oCheck3) //Gera Pedido/Gera Faturamento      
	
	@ 125,90 CHECKBOX oCheck3 VAR lCheck3 PROMPT STR0010;	// Gerar Meio Magnético
	SIZE 80,08 OF oPanelCen PIXEL 
Else
	@ 106,10 SAY oTxt VAR STR0040+; //"Clique na caixa abaixo para determinar se o Remito tambem sera "
	             STR0041+; //"gerado em meio magnetico, para futura importacao dos dados na "
	             STR0042 SIZE 160,50 OF oPanelCen PIXEL FONT oFnt1 COLOR CLR_BLUE //"Loja de destino."
	@ 134,85 CHECKBOX oCheck3 VAR lCheck3 PROMPT STR0010;	// Gerar Meio Magnético
    SIZE 80,08 OF oPanelCen PIXEL 		             
EndIf

If cPaisLoc == "BRA" .AND. nCheck == 1
   oCheck3:Disable()
EndIf   

AADD( aButtons, {NIL,{|| IIf(lLJ430BU1,;
							ExecBlock("LJ430BU1",.F.,.F.), ;
							LjxDProd( aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=='LN_COD'})],aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=='LN_LOCAL'})]);
							)},STR0034,STR0034,{|| .T.}})   // Estoques											

ACTIVATE DIALOG oDlgLoja ON INIT (EnchoiceBar(oDlgLoja,;
								{||(If( Lj430Grv(nCheck,lCheck3,nOpc,nSaveSx8),oDlgLoja:End(),.F.))},;
								{||( lj430Fim( nSaveSx8 ),oDlgLoja:End())};
								,,@aButtons))                        
	
aRotina:=aclone(aBkRotina)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LJ430Chg ³ Autor ³ Vendas Clientes       ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita/Desabilita o CheckBox de geracao em disco, caso   ³±±
±±³          ³ seja selecionado a opcao de Gerar faturamento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ430Chg(nCheck,oCheck3)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nCheck  - Opcao                                            ³±±
±±³          ³ oCheck3 - Objeto da opcao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ430Chg( nCheck, oCheck3 )
If nCheck == 1
   oCheck3:Disable()
Else
   oCheck3:Enable()
EndIf   
              		
oCheck3:Refresh()

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj430Cnd   ³ Autor ³ Vendas Clientes     ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a descricao da condicao de pagamento               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj430Cnd(cCodigo)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodigo - Codigo da condicao de pagamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs       ³ Usado no gatilho do campo LM_COND                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj430Cnd( cCodigo )
Local aArea := GetArea()
Local lRet  := .T.

DbSelectArea("SE4")
DbSetOrder(1)
If !DbSeek(xFilial("SE4")+cCodigo)
    MsgInfo(STR0014) //Condição não cadastrada
    lRet  := .F.
EndIf
M->LM_FORMA:=SE4->E4_DESCRI
RestArea( aArea )
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ Lj430Ger ³ Autor ³ Vendas Clientes       ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processas as DISTRIBUICOES                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj430Ger(nCheck,lCheck3,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao da funcao mBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj430Ger( nCheck, lCheck3, nOpc )
Local cNumSC5
Local cMay
Local lLiberOk		:= .T.
Local lResidOk		:= .T.
Local lFaturOk		:= .F.
Local lLiber    	:= .F.
Local lTransf   	:= .F.
Local lRet 		    := .T.
Local cStatus
Local cItemPC
Local nX 			:= 0
Local aNotas 		:= {}
Local cArqGerado	:= ""
Local cMsg			:= ""         
Local nSc5SaveSx8 	:= GetSx8Len()
Local aAreaAtu  	:= GetArea()
Local aAreaSLN  	:= {}
Local cPegaNota 	:= SuperGetMV("MV_TPNRNFS")			// Se pega o numero da nota do semaforo retorna "2", se for da tabela 1 do SX5 retorna "1"
Local lAvanca		:= SuperGetMV("MV_LJAVANC",,.F.)	// A variavel lAvanca define se é possivel alterar o numero da Nota sugerida dentro da NxtSX5Nota
Local cDirGrv   	:= Lj430VlDir()  	// Diretorio onde serao armazenados os arquivos magneticos
Local lGeraDist 	:= .T.
Local cSeqSC9 		:= "00"							    // Sequencia do arquivo SC9
Local lContinua     := .T.								// Continua processamento da Distribuicao
Local nSldSB2   	:= 0	                            // Recebe o saldo atual do estoque descontando as reservas efetuadas 

#IFDEF TOP
	Local aLockSX6  := {}
#ENDIF

Private cNota
Private cSerie    := AllTrim(SuperGetMV("MV_LOJANF"))	// Variavel que sera retornada da funcao SX5NUMNOTA()
Private cNumero	  := ""								// Variavel que sera retornada da funcao SX5NUMNOTA()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se cDirGrv for vazio, grava no remote (BIN).         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cDirGrv)                
	cDirGrv := GetClientDir()
EndIf
            
If Substr(cDirGrv,Len(cDirGrv), 1) <> "\"
	cDirGrv := cDirGrv + "\"
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe um sinal de & (macro substituicao), dessa forma³
//³possibilita ao usuario executar uma customizacao.                 ³
//³Foi necessario fazer dessa forma, pois caso contrario acarretaria ³
//³erro na base de clientes ja implantada.                           ³
//³Solicitado por: Projeto Kodak                                     ³
//³Incluido a funcao PadR, para que, a variavel fique com o mesmo    ³
//³tamanho do campo L1_SERIE evitando problemas com DbSeek.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSerie := PadR(If(Substr(cSerie,1,1)=="&",&(Substr(cSerie,2,Len(cSerie))),cSerie),TamSX3("L1_SERIE")[1])

DbSelectArea("SLM")
DbSetOrder(1)
If LM_STATUS$'5|8'
   MsgInfo(STR0015) // Distribuição já processadas
   Return (.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao considerar estoque negativo, valida o saldo dos produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If SuperGetMV("MV_ESTNEG",,"S") == "N"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se os produtos tem quantidade maior que o saldo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SLN")
	DbSetOrder(1)    	// LN_FILIAL + LN_NUM + LN_CLIENTE + LN_LOJA + LN_COD
	If DbSeek(xFilial('SLN') + SLM->LM_NUM + SLM->LM_CLIENTE + SLM->LM_LOJA)		
		While !Eof().AND.( xFilial('SLN') + SLM->LM_NUM + SLM->LM_CLIENTE + SLM->LM_LOJA==;
		                    SLN->LN_FILIAL + SLN->LN_NUM + SLN->LN_CLIENTE + SLN->LN_LOJA )
			DbSelectArea("SB2")
   			DbSetOrder(1)        //B2_FILIAL + B2_COD + B2_LOCAL
			If DbSeek(xFilial('SB2') + SLN->LN_COD	+ SLN->LN_LOCAL) 
				nSldSB2 := SaldoSB2()
				If nSldSB2 < SLN->LN_QUANT 
					MsgInfo( STR0049 + " " + Alltrim(SLN->LN_COD) + " "+ STR0036  + " " + Alltrim( Str( nSldSB2,14,2 ) ) ) //Produto ++ Saldo em estoque Insuficente, saldo Atual 
					Return(.F.) 
				EndIf		
			EndIf 
		    SLN->(DbSkip())
	    End
	EndIf          
EndIf              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validar se irah se efetuado o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("LJ430DIS")
	LjGrvLog( Nil, " Antes da execução do P.E. LJ430DIS")
	lGeraDist := ExecBlock("LJ430DIS",.F.,.F., {SLM->LM_NUM, SLM->LM_CLIENTE, SLM->LM_LOJA})
	LjGrvLog( Nil, " Retorno da execução do P.E. LJ430DIS -", lGeraDist)
Endif	

If lGeraDist
	If cPaisLoc == "BRA"
		// Se parametro MV_LOJANF preenchido nao abre tela para selecao da nota
		If Empty(cSerie)
			lContinua := Sx5NumNota(,cPegaNota)
		EndIf
		If lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Existe um controle especifico para o SIGALOJA dentro da      ³
			//³ MATXFUNA que permite avancar o numero do semaforo quando o   ³
			//³ usuario alterar a numeracao                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPegaNota == "2" .AND. lAvanca
				cNota   := NxtSX5Nota( cSerie,,cPegaNota,lAvanca )
				cNota   := PadR( StrZero(Val(cNota),Len(cNota)) , TamSx3("F1_DOC")[1] )				
				cNumero := cNota
			Endif
		Else
			Return (.F.)
		Endif
	EndIf
	
	Begin Transaction
	//Verifica se o registro ja foi processado...
	cStatus:= SLM->LM_STATUS
	
	// So gera pedido caso o pais seja igual a Brasil.
	If cPaisLoc == "BRA"
		DbSelectArea("SC5")
		DbSetOrder(1)
		cNumSC5 := GetSxeNum("SC5","C5_NUM")
		cMay := "SC5"+Alltrim(xFilial("SC5"))+cNumSC5
		While (DbSeek(xFilial("SC5")+cNumSC5) .OR. !MayIUseCode(cMay))
			cNumSC5 := Soma1(cNumSC5,Len(cNumSC5))
		End
		RecLock("SC5",.T.)
		Replace C5_FILIAL  With xFilial("SC5")
		Replace C5_NUM     With cNumSC5
		Replace C5_TIPO    With "N"
		Replace C5_CLIENTE With SLM->LM_CLIENTE
		Replace C5_LOJACLI With SLM->LM_LOJA
		Replace C5_LOJAENT With SLM->LM_LOJA
		Replace C5_CONDPAG With SLM->LM_COND
		Replace C5_EMISSAO With dDataBase
		Replace C5_MOEDA   With 1
		Replace C5_TRANSP  With SA1->A1_TRANSP
		Replace C5_TIPLIB  With "1"
		Replace C5_TIPOCLI With SA1->A1_TIPO
		MsUnlock()
		FkCommit()
		
		While (GetSX8Len() > nSc5SaveSx8)
			ConfirmSx8()
		End
		DbSelectArea("SLN")
		DbSetOrder(1)
		DbSeek(xFilial('SLN')+SLM->LM_NUM+SLM->LM_CLIENTE+SLM->LM_LOJA)
		cItemPC := '00'
		While SLN->(!EOF()) .AND.( xFilial('SLN')+SLM->LM_NUM+SLM->LM_CLIENTE+SLM->LM_LOJA==LN_FILIAL+LN_NUM+LN_CLIENTE+LN_LOJA )
			cItemPC := Soma1(cItemPc)
			SB1->(DbSeek(xFilial("SB1")+SLN->LN_COD))
			SF4->(DbSeek(xFilial("SF4")+SLN->LN_TES))
			RecLock("SC6",.T.)
			Replace C6_NUM      With cNumSC5
			Replace C6_FILIAL  	With xFilial("SC6")
			Replace C6_ITEM    	With cItemPC
			Replace C6_PRODUTO 	With SLN->LN_COD
			Replace C6_UM		With SLN->LN_UM
			Replace C6_QTDVEN  	With SLN->LN_QUANT
			Replace C6_TES      With SLN->LN_TES
			Replace C6_CF       With SLN->LN_CF
			Replace C6_LOCAL    With SLN->LN_LOCAL
			Replace C6_CLI      With SC5->C5_CLIENTE
			Replace C6_LOJA     With SC5->C5_LOJACLI
			Replace C6_DESCRI   With SB1->B1_DESC
			Replace C6_ITEMORI  With ""
			Replace C6_COMIS1   With SB1->B1_COMIS
			Replace C6_PRCVEN   With SLN->LN_VUNIT
			Replace C6_VALOR    With SLN->LN_TOTAL
			If !Empty(SF4->F4_SITTRIB)
				Replace C6_CLASFIS	With (SubStr(SB1->B1_ORIGEM,1,1) + SF4->F4_SITTRIB)
			Endif
			If SLN->(FieldPos("LN_LOTECTL"))>0
				Replace C6_LOTECTL With SLN->LN_LOTECTL
			EndIf
			If SLN->(FieldPos("LN_NLOTE"))>0
				Replace C6_NUMLOTE With SLN->LN_NLOTE
			EndIf
			If SLN->(FieldPos("LN_LOCALIZ"))>0
				Replace C6_LOCALIZ With SLN->LN_LOCALIZ
			EndIf
			If cStatus$'2#4'
				Replace C6_QTDLIB With SC6->C6_QTDVEN
			EndIf
			LjMsgRun(STR0016,,{|| MaAvalSC6("SC6",1,"SC5",.F.,.F.,@lLiberOk,@lResidOk,@lFaturOk)})//"Aguarde...Gravando Itens do pedido"
			MsUnlock()
			FkCommit()
			DbSelectArea('SLN')
			RecLock("SLN",.F.)
			Replace LN_PEDIDO  With cNumSC5
			Replace LN_ITEMPC  With cItemPC
			MsUnlock()
			FkCommit()               
			
			SLN->(DbSkip())
		End
	
		LjMsgRun(STR0017,,{|| MaAvalSC5("SC5",1,lLiber,lTransf,@lLiberOk,@lResidOk,@lFaturOk)}) //"Aguarde...Gerando pedido"
	Else             
		// Executa Rotina para geracao do Remito de Saida
		LjMsgRun(STR0043,,{|| lRet := Lj430RemSai(@aNotas) })  //"Aguarde... Gerando Remito"
		
	    If !lRet
			Return(lRet)
		EndIf    	
	EndIf
	
	If cPaisLoc == "BRA" .AND. cStatus$'2#4'
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia a variavel aNotas como referencia para receber os numeros e series ³
		//³das notas que foram geradas                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LjMsgRun(STR0018,,{|| IncNota(SC5->C5_NUM,cSerie,"",@aNotas)}) //"Aguarde...Gerando Nota Fiscal"

		cNota   := Padr(cNota,TamSx3("F2_DOC")[1])
		cNumero := cNota
	          
		#IFDEF TOP	
			//-- Na função IncNota tem uma chamada para a função NxtSX5Nota (MATXFUNA) onde tem um RecLock no parâmetro MV_NUMITEN,
			//-- ao voltar, por algum motivo, o lock não é retirado, em todas as outras tabelas os locks são perdidos ao finalizar com
			//-- END TRANSACTION.... a tabela SX6 continua com o registro travado dando erro em outras telas.	Esse problema só ocorre
			//-- qdo estamos utilizando o TOP CONNECT com o parâmetro MV_TTS como S.
			aLockSX6 := SX6->(DBRLockList())
	
			For nX := 1 To Len(aLockSX6)	
	
				SX6->(DBGoTo(aLockSX6[nX]))
				SX6->(MSUnLock())
			
			Next nX
	
		#ENDIF	
	EndIf
	
	DbSelectArea("SLM")
	RecLock("SLM",.F.)
	If cPaisLoc == "BRA"
		Replace LM_PEDIDO  With SC5->C5_NUM
		Replace LM_STATUS  With '5'
	Else
		If FieldPos("LM_REMITO") > 0
			Replace LM_REMITO  With aNotas[1][2]
		Endif
		If FieldPos("LM_SERIREM") > 0
			Replace LM_SERIREM With aNotas[1][1]
		Endif
		Replace LM_STATUS  With '8'
	EndIf
	MsUnlock()
	
	If cPaisLoc <> "BRA"
		DbSelectArea("SLN")  
		aAreaSLN := GetArea()
		DbSetOrder(1)
		DbSeek(xFilial('SLN')+SLM->LM_NUM+SLM->LM_CLIENTE+SLM->LM_LOJA)
		While !Eof() .AND. (xFilial('SLN')+SLM->LM_NUM+SLM->LM_CLIENTE+SLM->LM_LOJA == LN_FILIAL+LN_NUM+LN_CLIENTE+LN_LOJA)   
			RecLock("SLN",.F.)
			If FieldPos("LN_REMITO") > 0 
				Replace LN_REMITO  With aNotas[1][2]
			Endif
			If FieldPos("LN_SERIREM") > 0 
				Replace LN_SERIREM With aNotas[1][1]
			Endif
			MsUnLock()	
			DbSkip()
		End
		RestArea(aAreaSLN)
	EndIf
	
	//³Gera os arquivos com as notas fiscais
	If cStatus$'4|7'
		If cPaisLoc == "BRA"
			For nX := 1 to Len(aNotas)
				LjMsgRun(STR0019,,{|| LJ430Disk(aNotas[nX][2],aNotas[nX][1],SLM->LM_LOJA,@cArqGerado)}) //"Aguarde...Gerando meio magnético"
				If File( cDirGrv + cArqGerado)
					cMsg := cMsg + cArqGerado + Chr(10)
				EndIf   
			Next nX
		Else 
			LjMsgRun(STR0019,,{|| LJ430Disk(aNotas[1][2],aNotas[1][1],SLM->LM_LOJA,@cArqGerado)}) //"Aguarde...Gerando meio magnético"
			If File( cDirGrv + cArqGerado)
				cMsg := cMsg + cArqGerado + Chr(10)
			EndIf
		EndIf
	EndIf
	
	//³Mostra msg com os nomes dos arquivos gerados ³
	If !Empty( cMsg )
		MsgInfo( STR0026 + cDirGrv + Chr(10) + cMsg )		//'Criado arquivo de Nota em : '
	Endif
	
	END TRANSACTION
	
	If ExistBlock("LJ430NF")
		LjGrvLog( Nil, " Antes da execução do P.E. LJ430NF")
		ExecBlock("LJ430NF" ,.F.,.F.,{cNota,cSerie,SLM->LM_LOJA})
		LjGrvLog( Nil, " Retorno da execução do P.E. LJ430NF")
	EndIf   
Endif
   
// Restaura a area Original.
RestArea(aAreaAtu)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ Lj430Grv ³ Autor ³ Vendas Clientes       ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava dados da distribuicao nas tabelas SLM, SLN           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj430Grv(nCheck,lCheck3,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  nCheck  - Opcao de geracao selecionada                    ³±±
±±³          ³  lCheck3 - Flag se gera nota em disco ou nao               ³±±
±±³          ³  nOpc    - Opcao do browse selecionada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj430Grv( nCheck, lCheck3, nOpc, nSaveSx8 )
Local lFlag    := .T.  												// Define se e inclusao ou alteracao
Local nDel															// Variavel contador de arquivos deletados
Local nI       := 0	   												// Controle de loop 
Local cItem														    // Variavel que recebe numero do Item 
Local nX 	   := 0                                            		// Controle de loop 
Local nPosItem := Ascan(aHeader,{|x|Alltrim(x[2])=="LN_ITEM"})		// Posicao do item no aHeader
Local nPosCOD 	  := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_COD"		})	// Posicao do campo codigo do produto
Local nPosUM 	  := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_UM"		})	// Posicao do campo Unidade de Medida
Local nPosQUANT   := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_QUANT"		})	// Posicao do campo Quantidade
Local nPosVUNIT   := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_VUNIT"		})	// Posicao do campo Valor Unitario
Local nPosTOTAL   := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_TOTAL"		})	// Posicao do campo Valor Total
Local nPosTES 	  := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_TES"		})	// Posicao do campo TES
Local nPosCF 	  := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_CF"		})	// Posicao do campo Codigo Fiscal 
Local nPosLOCAL   := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_LOCAL"		})  // Posicao do campo Local 
Local nPosLOTECTL := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_LOTECTL" 	})  // Posicao do campo LOTE
Local nPosNLOTE   := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_NLOTE"	 	})	// Posicao do campo SUB-LOTE
Local nPosLOCALIZ := Ascan(aHeader,{|x|alltrim(x[2]) == "LN_LOCALIZ"	})	// Posicao do campo Endereco
Local lLJ430Grava := ExistBlock("LJ430GRAVA")             		// Verifica se existe o ponto de entrada U_LJ430GRAVA
Local lLJ7430VdGr := ExistBlock("LJ7430VDGR")                       // Verifica se existe o ponto de entrada LJ7430VDGR
Local lRet        := .T.                                            // Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada que permite validar o processo de gravacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLJ7430VdGr
	xRet := ExecBlock( "LJ7430VDGR", .F., .F., {nCheck, lCheck3, nOpc } ) 
	If ValType(xRet) == "L" .AND. !xRet
		lRet := xRet
		Return lRet
	EndIf
EndIf

If !Obrigatorio(aGets,aTela)
	lRet := .F.
	Return(lRet)
EndIf

For nI := 1 to Len(aCols)
    n := nI
    If !LJ430LIN()
    	lRet := .F.
    	Return(lRet)
    EndIf
Next nI

If nOpc = 4
   lFlag := .F.
EndIf

BEGIN TRANSACTION
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao nas tabelas do SIGALOJA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLM")
DbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Travando o Registro ate o final da operacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("SLM",lFlag)
Replace LM_FILIAL  With xFilial("SLM")
Replace LM_NUM     With M->LM_NUM
Replace LM_CLIENTE With M->LM_CLIENTE
Replace LM_LOJA    With M->LM_LOJA
Replace LM_COND    With M->LM_COND
Replace LM_EMISSAO With dDataBase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valores possiveis no Campo LM_STATUS:           ³
//³                                                ³
//³1 - Gerar Pedido                                ³
//³2 - Gerar Faturamento s/ Meio Magnético         ³
//³3 - Gerar Pedido com Meio Magnetico ( Não usado)³
//³4 - Gerar Faturamento com meio magnetico        ³
//³5 - Pedido processado                           ³
//³------------ Exclusivo Localizacoes ------------³
//³6 - Gerar Remito                                ³ 
//³7 - Gerar Remito com Meio Magnetico             ³
//³8 - Remito processado                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	Replace LM_STATUS With Str(nCheck+If(lCheck3,2,0),1)
Else 
	If !lCheck3
		Replace LM_STATUS With "6"   
	Else
		Replace LM_STATUS With "7"   					
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a gravação dos campos de usuário         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCpoUsrSLM)
	For nX := 1 to Len(aCpoUsrSLM)
		Replace &(aCpoUsrSLM[nX]) With &("M->"+aCpoUsrSLM[nX])
	Next nX
EndIf
          
If nOpc <> 4
   While (GetSX8Len() > nSaveSx8)
	  ConfirmSx8()
   End
EndIf

MsUnlock()
FkCommit()

DbSelectArea("SLN")
DbSetOrder(2)

//Se existir item deletado, apaga itens para garantir sequencial
If Ascan(aCols, {|x| x[Len(aHeader)+1]}) > 0
	If SLN->(dbSeek(xFilial('SLN')+M->LM_NUM))
		While SLN->(!EOF()) .AND. SLN->(LN_FILIAL+LN_NUM) == xFilial("SLN")+M->LM_NUM
			RecLock("SLN",lFlag)
			SLN->(dbDelete())
			SLN->(MsUnlock())  
			SLN->(FkCommit())
			
			SLN->(dbSkip())
		EndDo
	EndIf
EndIf

cItem := "00"
For nI:= 1 to Len(aCols)
	//Item habilitado
	If !aCols[nI,Len(aHeader)+1]		
		cItem := Soma1(cItem)	
	
		//Posiciona no registro a ser alterado
		If SLN->(dbSeek(xFilial('SLN')+M->LM_NUM+cItem))		
			lFlag := .F. //Alteracao									
		Else
			lFlag := .T. //Inclusao
		EndIf					
		        	 				
		RecLock("SLN",lFlag)	
		Replace LN_FILIAL  With xFilial("SLM")
		REPLACE LN_COD     WITH aCols[nI,nPosCOD]
		REPLACE LN_UM      WITH aCols[nI,nPosUM]
		REPLACE LN_QUANT   WITH aCols[nI,nPosQUANT]
		REPLACE LN_VUNIT   WITH aCols[nI,nPosVUNIT]
		REPLACE LN_TOTAL   WITH aCols[nI,nPosTOTAL]
		REPLACE LN_TES     WITH aCols[nI,nPosTES]
		REPLACE LN_CF      WITH aCols[nI,nPosCF]
		REPLACE LN_LOCAL   WITH aCols[nI,nPosLOCAL]
		If SLN->(FieldPos("LN_LOTECTL"))>0
			REPLACE LN_LOTECTL WITH aCols[nI,nPosLOTECTL]
		EndIf
		If SLN->(FieldPos("LN_NLOTE"))>0
			REPLACE LN_NLOTE WITH aCols[nI,nPosNLOTE]
		EndIf
		If SLN->(FieldPos("LN_LOCALIZ"))>0
			REPLACE LN_LOCALIZ WITH aCols[nI,nPosLOCALIZ]
		EndIf
		Replace LN_NUM     With M->LM_NUM
		Replace LN_CLIENTE With M->LM_CLIENTE                                        
		Replace LN_LOJA    With M->LM_LOJA
		Replace LN_EMISSAO With dDataBase
		Replace LN_ITEM    With cItem
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz a gravação dos campos de usuário         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCpoUsrSLN)
			For nX := 1 to Len(aCpoUsrSLN)				
			Replace &(aCpoUsrSLN[nX]) With aCols[nI,Ascan(aHeader,{|x|Alltrim(x[2])==Alltrim(aCpoUsrSLN[nX])})]
			Next nX
		EndIf
							
		MsUnlock()  
		FkCommit()
	EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para o template Drogaria, efetua a gravacao ³
		//³das Transferencias dos produtos controlados ³
		//³na tabela de Log's ANVISA LK9               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
			If T_DroVerCont(aCols[nI,nPosCOD])
				T_DroTransANVISA( 1	        			, lFlag			 	, M->LM_NUM			, M->LM_CLIENTE		 	,;
								  M->LM_LOJA			, aCols[nI,nPosCOD]	, aCols[nI,nPosUM]	, aCols[nI,nPosQUANT]	,;
								  aCols[nI,nPosLOTECTL]	, M->LM_EMISSAO		, aCols[nI,Len(aHeader)+1] )	 
			Endif							  
		Endif
Next nI

END TRANSACTION     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Ponto de entrada LJ430Grava³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If lLJ430Grava
   ExecBlock("LJ430GRAVA",.F.,.F.)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj430Exc	³ Autor ³ Vendas Clientes       ³ Data ³ 08/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui pedido de Distribuicao nao processado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj430Exc(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - Alias enviado pelo browse                         ³±±
±±³          ³ nReg   - registro atual enviado pelo browse                ³±±
±±³          ³ nOpc   - Numero da opcao selecionada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj430Exc( cAlias, nReg, nOpc )
Local lRet 		 :=.T.
Local cPedido    := SLM->LM_NUM
Local cCliente   := SLM->LM_CLIENTE
Local cLoja      := SLM->LM_LOJA
Local lLJ7430Exc := ExistBlock("LJ7430EXC") // Verifica se existe o ponto de entrada LJ7430EXC

DbSelectArea("SLM")
If LM_STATUS$'5|8'
   MsgInfo(STR0009) //' Distribuição já processada'
   Return .F.
EndIf   
If MsgYesNo(STR0038)
   DbSelectArea("SLN")
   DbSetOrder(2)
   DbSeek(xFilial('SLN')+cPedido )
   While !eof().AND.( xFilial('SLN')+cPedido+cCliente+cLoja==LN_FILIAL+LN_NUM+LN_CLIENTE+LN_LOJA )
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para o template Drogaria, efetua a gravacao ³
		//³das Transferencias dos produtos controlados ³
		//³na tabela de Log's ANVISA LK9               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
			If T_DroVerCont(SLN->LN_COD)
				T_DroTransANVISA( 2	 , NIL		 		, SLN->LN_NUM	, NIL,;
								  NIL, NIL				, NIL	  	   	, NIL,;
								  NIL, SLN->LN_EMISSAO	, NIL )
			Endif							  
		Endif
      RecLock("SLN",.F.)
      dbDelete()
      MsUnlock()
      DbSkip( )
   End
   DbSelectArea("SLM")
   RecLock("SLM",.F.)
   dbDelete()
   MsUnlock()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Ponto de entrada que permite realizar customizacoes apos a exclusao do registro ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lLJ7430Exc 
   		ExecBlock("LJ7430EXC", .F., .F.,{ cPedido, cCliente, cLoja })
   EndIf
EndIf     

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Lj430AL  ³ Autor ³ Vendas Clientes       ³ Data ³ 28/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recupera os dados da tabela e grava no acols qdo e alteraca³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj430Al                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj430AL( nReg, lCheck3, nCheck, nOpc )
Local cPedido  
Local cCliente 
Local cLoja    
Local nItem
Local nI

SLM->(dbGoto(nReg))
cPedido  := SLM->LM_NUM
cCliente := SLM->LM_CLIENTE
cLoja    := SLM->LM_LOJA
If SLM->LM_STATUS=='4'
   nCheck  := 2
   lCheck3 := .T.
ElseIf SLM->LM_STATUS=='2'
   nCheck  := 2
   lCheck3 := .F.
Else
   nCheck  := 1
   lCheck3 := .F.
EndIf

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SLM")
While !Eof() .AND. (X3_ARQUIVO == "SLM")
	If X3Uso(SX3->X3_USADO) .AND. (cNivel >= SX3->X3_NIVEL)
	   M->&(SX3->X3_CAMPO) :=SLM->(FieldGet(FieldPos(SX3->X3_CAMPO)))
    Endif
    DbSkip()
End
Lj430Cnd(SLM->LM_COND)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o aHeader e aCols pelo FillGetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJ430FillGet( nOpc )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ430LEG   | Autor ³ Vendas Clientes     ³ Data ³29/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe uma legenda contendo as descricoes das cores dos     ³±±
±±³          ³ status da distribicao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ430LEG()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja430                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ430LEG()
Local aLegenda := {}

If cPaisLoc == "BRA"
	aLegenda := { {"BR_VERDE"   ,STR0020},; //"Gerar Pedido"
                  {"BR_AZUL"    ,STR0021},; //'Faturamento sem Meio Magnetico'
                  {"BR_AMARELO" ,STR0022},; //"Faturamento com Meio Magnetico"
                  {"BR_VERMELHO",STR0023}}  //"Distribuição processada"
Else
	aLegenda := { {"BR_AZUL"    ,STR0044},;  //"Remito sem Meio Magnetico"
                  {"BR_AMARELO" ,STR0045},;  //"Remito com Meio Magnetico"
                  {"BR_VERMELHO",STR0023}}  //"Distribuição processada"
EndIf

BrwLegenda(STR0024,STR0025,aLegenda)		 //'Distribuição das lojas'/Legenda
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ430Disk  | Autor ³ Vendas Clientes     ³ Data ³29/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo TXT, referente a Nota fiscal de Transferen- ³±±
±±³          ³ cia, gerado pela distribuiçao com meio magnetico           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ430disk(cNota,cSerie,cLoja)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNota  - Numero da nota fiscal                             ³±±
±±³          ³ cSerie - Serie da nota fiscal                              ³±±
±±³          ³ cLoja  - Loja do cliente                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja430                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ430Disk( cNota, cSerie, cLoja, cArqGerado )
Local cFile		:= AllTrim(StrTran(cFilAnt, " ")) + cLoja + cNota + '.NFT'
Local nHandle
Local aTam		:= {}
Local cTipo		:= ' '
Local cLinha
Local nX		:= 0	//controle de loop
Local cVal
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criado o parametro MV_LJDIRGR para permitir                             ³
//³a gravacao dos arquivos magneticos em local definido pelo administrador.³
//³Se nao encontrar o paramentro grava no diretorio remote.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDirGrv   	:=	Lj430VlDir()   	// Diretorio onde serao armazenados os arquivos magneticos

Default cArqGerado 	:= ""

cNota := Padr(cNota,TamSx3("F2_DOC")[1])

If Empty(cDirGrv)
	cDirGrv := GetClientDir()
EndIf                        
     
If Substr(cDirGrv,Len(cDirGrv),1) <> "\"
	cDirGrv := cDirGrv + "\"
EndIf

DbSelectArea('SF2')
DbSetOrder(1)
If DbSeek(xFilial('SF2')+cNota+cSerie)
	// Verifica se a nota posicionada e a correta, com base na especie.
	If cPaisLoc <> "BRA"
		While !Eof() .AND. F2_FILIAL+F2_DOC+F2_SERIE == xFilial('SF2')+cNota+cSerie
			If AllTrim(F2_ESPECIE) <> "RFN"
		    	DbSkip() 
		      	Loop
		 	Else
		    	Exit
		  	EndIf
		End
	EndIf 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o arquivo no local informado            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		      
	nHandle := fCreate( cDirGrv + cFile )
	fWrite(nHandle,"SF2-NF : "+SF2->F2_DOC+'  Arquivo gerado atraves da rotina DISTRIBUICAO DE MERCADORIA'+CHR(10))
	cLinha:=''
    
    // Gravacao do nome dos campos (SF2) no TXT
	for nX:= 1 to fcount()
	   aTam   := TamSX3(FieldName(nX))
       cTipo  := TipoSX3(FieldName(nX))
	   cLinha += Subs(FieldName(nX)+space(10),1,10)+strZero(aTam[1],3)+cTipo
	Next nX
	fWrite(nHandle,'#'+cLinha+CHR(10))
	cLinha:=''

    // Gravacao dos dados (SF2) no TXT
	for nX := 1 to fcount()
		aTam := TamSX3(FieldName(nX))
		If ValType(FieldGet(nX)) == "N"
		   cVal := Strzero(FieldGet(nX),aTam[1],aTam[2])
		Elseif ValType(FieldGet(nX)) == "D"
		   cVal := DTOS(FieldGet(nX))
		Elseif ValType(FieldGet(nX)) == "L"
		   cVal := If(FieldGet(nX), ".T.", ".F.")
   		//Nao permite que um campo do tipo Memo fique com valores Nulos
		ElseIf Type(FieldName(nX)) == "M"
		   If Len(FieldGet(nX)) = 0
		   		cVal := Space(aTam[1])
			Else
				cVal := FieldGet(nX)
			EndIf
		Else
			cVal := PadR( FieldGet(nX), aTam[1] )
		Endif
        cLinha += Subs(cVal,1,aTam[1])
    Next nX
    fWrite(nHandle,'#'+cLinha+CHR(10))
	DbSelectArea('SD2')
	DbSetOrder(3)
	If DbSeek(xFilial('SD2')+cNota+cSerie)
		fWrite(nHandle,"SD2-NF : "+SD2->D2_DOC+CHR(10))
		cLinha:=''
     	for nX:= 1 to fcount()
	        aTam:=TamSX3(FieldName(nX))
            cTipo  := TipoSX3(FieldName(nX))
	        cLinha += Subs(FieldName(nX)+space(10),1,10)+strZero(aTam[1],3)+cTipo
     	Next nX
		fWrite(nHandle,'#'+cLinha+CHR(10))
	EndIf
	
	while !eof().AND.(xFilial('SD2')+cNota+cSerie)==(SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE )
		// Verifica se a nota posicionada e a correta, com base na especie.
        If cPaisLoc <> "BRA"
        	If AllTrim(SD2->D2_ESPECIE) <> "RFN"
        		DbSkip()
        		Loop
        	EndIf
        EndIf
        
        cLinha:=''
		for nX:= 1 to fcount()
			aTam:=TamSX3(FieldName(nX))
    		If ValType(FieldGet(nX)) == "N"
     		   cVal:=Strzero(FieldGet(nX),aTam[1],aTam[2])
     		Elseif ValType(FieldGet(nX)) == "D"
    		   cVal:=DTOS(FieldGet(nX))
    		Elseif ValType(FieldGet(nX)) == "L"
		   	   cVal := If(FieldGet(nX), ".T.", ".F.")
    		Else
    		   cVal:=FieldGet(nX)
    		Endif
            cLinha+=Subs(cVal,1,aTam[1])
		Next nX
		fWrite(nHandle,'#'+cLinha+CHR(10))
		DbSkip()
	End             
	fClose(nHandle)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena o nome do arquivo                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If File( cDirGrv + cFile)
		cArqGerado := cFile
	EndIf   
Endif

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TipoSX3    | Autor ³ Vendas Clientes     ³ Data ³29/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o tipo de dado do SX3 de um determinado campo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TipoSX3(cCampo)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo  - nome do campo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TipoSX3( cCampo )
Local cAlias  := Alias()
Local nOrd    := IndexOrd()
Local nordSx3 := SX3->(Indexord())
Local nRegSx3 := SX3->(Recno())
Local cTipo   :=' '

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek(cCampo)
If Found()
	cTipo := X3_TIPO
EndIf

DbSelectArea("SX3")
DbSetOrder(nOrdSx3)
DbGoTo(nRegSx3)
If !Empty(cAlias)
	DbSelectArea(cAlias)
	DbSetOrder(nOrd)
EndIf
Return cTipo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ LJ430Vld ³ Autor ³ Vendas Clientes       ³ Data ³ 08/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Inicializa o aCols da distribuicao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ430Vld( nRot )
Local nPreco	:= 0									// Preco
Local cTpSai	:= ""									// Tipo de saida
Local cTabPad 	:= Alltrim(SuperGetMV( "MV_TABPAD" ))	// Conteudo do parametro MV_TABPAD
Local cCodPro	:= ""									// Variavel com o produto para procurar no estoque
Local cLocal	:= ""									// Variavel com o local do produto para procurar no estoque
Local nQuantBar	:= 1									// Quantidade de Produtos pelo código de barra.
Local nSldSB2   := 0									// Recebe o saldo atual do estoque descontando as reservas efetuadas 
Local nPosQuant := Ascan(aHeader,{|x|alltrim(x[2])=="LN_QUANT"})			// Posicao do quantidade no aCols
Local lCenVenda := SuperGetMv("MV_LJCNVDA",,.F.)					//Integra com cenario de vendas

Default nRot	:= 0									

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

If nRot==1
   cCodPro := aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_COD"})]
Else
   cCodPro := M->LN_COD
EndIf

If aCols[n,nPosQuant] == 0
	aCols[n,nPosQuant] := 1
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura pelo código do produto e pelo código de barras - LjSB1SLK³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LjSB1SLK( cCodPro, @nQuantBar  )
	Help(" ",1,"B1PROD" )
	Return(.F.)                   
Else
	cCodPro := SB1->B1_COD 	         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a quantidade. Se retornar zero, ha tratamento para registrar 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[n,nPosQuant] := nQuantBar
EndIf

aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_LOCAL"})] := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
cLocal	:= aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_LOCAL"})]

DbSelectArea("SB2")
DbSetOrder(1)
DbSeek( xFilial("SB2") + cCodPro + cLocal )
If SuperGetMV("MV_ESTNEG") == "S" .AND. !SB2->(Found())
	Help(" ",1,"B2PROD" )
	DbSelectArea("SB1")
	Return(.F.)
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao considerar estoque negativo, valida o saldo dos produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If SuperGetMV("MV_ESTNEG",,"S") == "N"
	nSldSB2 := SaldoSB2()
	If nSldSB2 < aCols[n,nPosQuant] 
	   MsgInfo(STR0035+Str(SB2->B2_QATU,14,2 )) //'Saldo em estoque Insuficente, saldo Atual '
	   DbSelectArea("SB1")
	   aCols[n,nPosQuant] := 0
	Endif
EndIf
nPreco := 0

If lCenVenda
	LjxeValPre(@nPreco, cCodPro, M->LM_CLIENTE, M->LM_LOJA, Nil, aCols[n,nPosQuant])

	If nPreco == 0
		Help( " ", 1, "NOPRECO" )
	EndIf		
Else
	DbSelectArea( "SB0" )
	DbSetOrder( 1 )
	If DbSeek( xFilial() + cCodPro )
		If Empty(SB0->&("B0_DATA"+cTabPad)) .OR. dDatabase <= SB0->&("B0_DATA"+cTabPad)
			nPreco := (SB0->&("B0_PRV"+cTabPad))
		EndIf
	Else
		Help( " ", 1, "NOPRECO" )
	EndIf
EndIf

aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_VUNIT"})]	:= nPreco
aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_COD"})]	:= SB1->B1_COD
aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_UM"})]	:= SB1->B1_UM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloque o tipo de Saida do Produto ou do Parametro   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(RetFldProd(SB1->B1_COD,"B1_TS"))
	aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_TES"})]:=RetFldProd(SB1->B1_COD,"B1_TS")
Else
	aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_TES"})]:= SuperGetMV("MV_TESSAI")
Endif

aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_TOTAL"})] := (aCols[n,nPosQuant]*aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_VUNIT"})])

cTpSai := RetFldProd(SB1->B1_COD,"B1_TS")
If Empty(RetFldProd(SB1->B1_COD,"B1_TS"))
	cTpSai := SuperGetMV("MV_TESSAI")
Endif

DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+cTpSai)
	aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_CF"})]:=SF4->F4_CF
Endif
aCols[n,Ascan(aHeader,{|x|alltrim(x[2])=="LN_EMISSAO"})] := dDataBase

DbSelectArea("SB1")
lInclui := .T.
oGet:Refresh()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ LJ430QTD ³ Autor ³ Vendas Clientes       ³ Data ³ 08/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ valida Estoque                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ430QTD( nRot )
Local aAreaSB1	:= SB1->( GetArea() )										// Salva a area do SB1
Local aAreaSB2	:= SB2->( GetArea() )										// Salva a area do SB2
Local lRet		:= .T.														// Retorno da funcao
Local nQuant	:= 0														// Quantidade informada para distribuicao
Local nQuantTot	:= 0														// Quantidade total do produto
Local nAuxFor	:= 0														// Auxiliar do For Next
Local nPosQuant	:= aScan( aHeader,{|x| Alltrim(x[2])	== "LN_QUANT"  } )	// Posicao da Quantidade no aCols
Local nPosCodPr	:= aScan( aHeader,{|x| Alltrim(x[2])	== "LN_COD"    } )	// Posicao do Produto no aCols
Local nPosLocal	:= aScan( aHeader,{|x| Alltrim(x[2])	== "LN_LOCAL"  } )	// Posicao do Local no aCols
Local nPosTotal	:= aScan( aHeader,{|x| Alltrim(x[2])	== "LN_TOTAL"  } )	// Posicao do Total no aCols
Local nPosVrUni	:= aScan( aHeader,{|x| Alltrim(x[2])	== "LN_VUNIT"  } )	// Posicao do Valor Unitario no aCols
Local nSldSB2   := 0                                                        // Recebe o saldo atual do estoque descontando as reservas efetuadas 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica quem chamou a rotina para validar a quantidade digitada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nRot == 1
	nQuant := aCols[n,nPosQuant]
Else
	nQuant := M->LN_QUANT
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se encontrou o produto nos saldo em estoque³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SB2")
DbSetOrder(1)
If !DbSeek( xFilial("SB2") + aCols[n,nPosCodPr] + aCols[n,nPosLocal] )
	Help(" ",1,"B2PROD" )
	lRet	:= .F.
Endif

If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao considerar estoque negativo, valida o saldo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMV("MV_ESTNEG") == "N"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o valor digitado eh maior que o saldo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		nSldSB2 := SaldoSB2(NIL	,NIL 	,NIL  	    ,NIL	,; 
			                NIL	,NIL	,NIL		,NIL	,;
			                NIL)

		If nSldSB2 < nQuant
			MsgInfo(  STR0036  + " " + Alltrim( Str( nSldSB2,14,2 ) ) )		//Saldo em estoque Insuficente, saldo Atual 
			lRet := .F.
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se a quantidade de todos os itens do mesmo produto,ultrapassa o saldo em estoque ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nAuxFor := 1 to Len( aCols )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente considera os itens nao deletado do aCols³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  				If !aCols[nAuxFor][Len(aHeader) + 1]
					If aCols[n,nPosCodPr] + aCols[n,nPosLocal] == aCols[nAuxFor,nPosCodPr] + aCols[nAuxFor,nPosLocal]
						If n <> nAuxFor
							nQuantTot := nQuantTot + aCols[nAuxFor,nPosQuant]
						Else
							nQuantTot := nQuantTot + nQuant
						Endif
					Endif
				EndIf
			Next nAuxFor
			
			If nSldSB2 < nQuantTot 
				MsgInfo(  STR0036 + " " + Alltrim( Str(nSldSB2,14,2 ) ) )		//Saldo em estoque Insuficente, saldo Atual 
				lRet := .F.
			Endif
		EndIf           
	Endif

	aCols[n,nPosTotal] := nQuant * aCols[n,nPosVrUni]
	
	If lRet
		lRet := LJ430Rastr("",nQuant)
    EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a area do SB1 e SB2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aAreaSB1 )
RestArea( aAreaSB2 )
lInclui := .T.
oGet:Refresh()

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ LJ430LIN ³ Autor ³ Vendas Clientes       ³ Data ³ 08/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ validacao LinOK                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ430LIN()
Local lRet		:= .T.														// Variavel com o retorno da funcao
Local nI		:= 0														// Variavel utilizada no For... Next
Local aAreaSB1	:= SB1->( GetArea() )										// Salva a area do SB1
Local aAreaSBF	:= SBF->( GetArea() )										// Salva a area do SB1
Local nPosEnd	:= aScan( aHeader,{|x| Alltrim(x[2]) == "LN_LOCALIZ" } )	// Posicao do endereco no aCols
Local nPosProd	:= aScan( aHeader,{|x| Alltrim(x[2]) == "LN_COD" } )		// Posicao do produto no aCols
Local nPosLocal	:= aScan( aHeader,{|x| Alltrim(x[2]) == "LN_LOCAL" } )		// Posicao do produto no aCols

If aCols[n,Len(aCols[n])]
	Return(.T.)
EndIf

If !LJ430QTD(1)
	Return(.F.)
EndIf

For nI := 1 to Len(aCols[n])-3
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a validacao de campo vazio somente se a linha nao estiver deletada                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	Empty(aCols[n,nI]) .AND.;
		!(AllTrim(aHeader[nI][2]) $ "LN_LOTECTL,LN_NLOTE,LN_LOCALIZ") .AND.;
		!aCols[n,Len(aHeader)+1]
		
		MsgInfo(STR0037+chr(10)+aHeader[nI,1]) //Campo Vazio 
		lRet := .F.
		Exit
	
	EndIf 
	If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		If 	Empty(aCols[n,nI]) .AND.;
		(AllTrim(aHeader[nI][2]) == "LN_LOTECTL" .OR. AllTrim(aHeader[nI][2]) == "LN_NLOTE") .AND.;
		!aCols[n,Len(aHeader)+1]
		If T_DroVerCont(aCols[n][nPosProd])
			MsgInfo(STR0037+chr(10)+aHeader[nI,1]) //Campo Vazio 
			lRet := .F.
			Exit
		EndIf	
		EndIf
	EndIf	
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o produto tem localização e se o endereco dele foi preenchido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SB1->(DbSetOrder(1))
If SB1->(DbSeek( xFilial("SB1") + aCols[n][nPosProd]))
	If Localiza(SB1->B1_COD)
		If Empty(aCols[n][nPosEnd])
            SBF->(DbSetOrder(4))		// Ordem: PRODUTO + NUM.SERIE
			If !(SBF->(DbSeek(xFilial("SBF") + aCols[n][nPosProd])))
				MsgStop(STR0049 + " " + aCols[n][nPosProd] + " " + STR0050 + ". " + STR0052) // "O produto "+###+"nao foi encontrado no endereco "####"Verifique se o produto foi endereçado "
				lRet := .F.
			Else
				If Empty(SBF->BF_NUMSERI)
					MsgStop(STR0048 + aHeader[nPosEnd][1]) //"Este produto tem controle de endereçamento, por favor, preencha o campo "
					lRet := .F.
				EndIf
			EndIf
		Else
			SBF->( DbSetOrder(1) )		// Ordem: LOCAL + LOCALIZACAO + PRODUTO
			If !(SBF->(DbSeek(xFilial("SBF") + aCols[n][nPosLocal] + aCols[n][nPosEnd] + aCols[n][nPosProd])))
				//"Campo obrigatorio não preenchido" // "O produto "+###+"nao foi encontrado no endereco "####"Verifique se o produto foi endereçado "
				Aviso(	STR0051 , STR0049 + Alltrim(aCols[n][nPosProd]) + " " + STR0050+;
						Alltrim(aCols[n][nPosEnd]) + "-" + Alltrim(aCols[n][nPosLocal])+;
						Chr(10) + STR0052, {"Ok"})
				lRet := .F.
			Endif
		Endif
	Endif
Endif

RestArea(aAreaSB1)
RestArea(aAreaSBF)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj430Fim  ºAutor  ³Vendas Clientes     º Data ³  10/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao chamada no botao cancelar na tela de inclusao dos    º±±
±±º          ³produtos                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA430                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj430Fim( nSaveSx8 )

// Controle do semaforo
While (GetSx8Len() > nSaveSX8)
	RollBackSX8()
End

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj430RemSai ³ Autor ³ Vendas Clientes     ³ Data ³ 31/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Remito de Saida ou Factura de Saida, conforme a       ³±±
±±³          ³ escolha do usuario.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj430RemSai( aNotas )
Local aCab 		:= {}	
Local aItensTot	:= {}   
Local aAreaAtu  := GetArea()
Local aAreaSLN  := {} 
Local lRet      := .T.

Private lMsErroAuto	:= .F.   

/////////////////////////////////////////////////////////////////////////////////                                                                                 
//                           O B S E R V A C O E S                             //
//-----------------------------------------------------------------------------//
// - E obrigatorio o envio do campo F2_SERIE;                                  //
// - Nao e necessario enviar o campo F2_DOC porque a numeracao do remito deve  //
//   ser gerada de maneira automatica. Por esse movito e obrigatorio o envio   //
//   do campo F2_SERIE;                                                        //
// - Respeitar a ordem na qual os campos sao exibidos na Enchoice;             //
// - E obrigatorio o envio de todos os campos que sao exibidos como            //
//   "Obrigatorios", quando a rotina e utilizada manualmente.                  //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////

cSerie := "R"+Space(TamSx3("F2_SERIE")[1] - 1)

AADD(aCab,{"F2_CLIENTE"	,SLM->LM_CLIENTE		       				,NIL})
AADD(aCab,{"F2_LOJA"   	,SLM->LM_LOJA  		           				,NIL})
AADD(aCab,{"F2_SERIE"  	,cSerie					       				,NIL})
AADD(aCab,{"F2_NATUREZ"	,Space(TamSx3("F2_NATUREZ")[1])				,NIL})
AADD(aCab,{"F2_ESPECIE"	,"RFN"+Space(TamSx3("F2_ESPECIE")[1] - 3)	,NIL}) 
AADD(aCab,{"F2_EMISSAO"	,dDataBase  			       				,NIL})
AADD(aCab,{"F2_TXMOEDA"	,1.0000					       				,NIL})
AADD(aCab,{"F2_MOEDA"	,1						       				,NIL})
AADD(aCab,{"F2_TIPOREM"	,"0"					       				,NIL})
AADD(aCab,{"F2_TIPODOC"	,"50"					              		,NIL}) 
AADD(aCab,{"F2_TIPO"	,"N"					       				,NIL})
AADD(aCab,{"F2_COND"   	,SLM->LM_COND 			       				,NIL})
AADD(aCab,{"F2_EST"    	,Posicione("SA1",1,xFilial("SA1")+SLM->LM_CLIENTE+SLM->LM_LOJA,"A1_EST")	,NIL})
AADD(aCab,{"F2_TIPOCLI"	,Posicione("SA1",1,xFilial("SA1")+SLM->LM_CLIENTE+SLM->LM_LOJA,"A1_TIPO")	,NIL})
AADD(aCab,{"F2_FORMUL"	,"S"					       				,NIL}) 

DbSelectArea("SLN")  
aAreaSLN := GetArea()
DbSetOrder(1)
DbSeek(xFilial('SLN')+SLM->LM_NUM+SLM->LM_CLIENTE+SLM->LM_LOJA)
While !Eof() .AND. (xFilial('SLN')+SLM->LM_NUM+SLM->LM_CLIENTE+SLM->LM_LOJA == LN_FILIAL+LN_NUM+LN_CLIENTE+LN_LOJA)
	aItens   := {}		// ITENS
	AADD(aItens,{"D2_ITEM"		,SLN->LN_ITEM	,NIL})
	AADD(aItens,{"D2_COD"		,SLN->LN_COD	,NIL})
	AADD(aItens,{"D2_UM"		,SLN->LN_UM		,NIL})
	AADD(aItens,{"D2_QUANT"		,SLN->LN_QUANT	,NIL})
	AADD(aItens,{"D2_PRCVEN"	,SLN->LN_VUNIT	,NIL})
	AADD(aItens,{"D2_TOTAL"		,SLN->LN_TOTAL	,NIL}) 
	AADD(aItens,{"D2_TES"		,SLN->LN_TES	,NIL})
	AADD(aItens,{"D2_CF"		,SLN->LN_CF		,NIL}) 
	AADD(aItens,{"D2_LOCAL"		,SLN->LN_LOCAL	,NIL})

	AADD(aItensTot, aItens)	 
    DbSkip()
End
           
// Executa a rotina automatica para geracao do Remito de Saida...            
MSExecAuto({|x,y| Mata462N(x,y)},aCab,aItensTot)

If lMsErroAuto
	DisarmTransaction()
	MostraErro()     
	lRet := .F.
Else
	AAdd(aNotas,{SF2->F2_SERIE, SF2->F2_DOC})
	cNota := aNotas[1][2]
Endif                
                  
// Retorna as areas originais
RestArea(aAreaSLN)
RestArea(aAreaAtu)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj430RastrºAutor  ³Vendas Clientes      º Data ³  09/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa a validacao da rastreabilidade do produto.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ430Rastr( cCampo, nQuant )
Local lRet 		:= .T.
Local cCodPro 	:= aCols[n][AScan( 	aHeader, { |x| AllTrim( x[2] ) == "LN_COD" } )]
Local cLoteCtl
Local cNLote
Local cLocaliza
Local cLocal
Local nQtdeLote

DEFAULT nQuant := aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_QUANT" } )]
DEFAULT cCampo := ""

If !SB1->( DbSeek( xFilial( "SB1" ) + cCodPro ) )
	Return .F.
Endif

If SLN->( FieldPos( "LN_LOTECTL" ) ) > 0 .AND. SuperGetMV( "MV_RASTRO" ) == "S"
	If SB1->B1_RASTRO == "N" .OR. SB1->B1_RASTRO == " "
		aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_LOTECTL" } )] := CriaVar( "L2_LOTECTL" )
		aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_NLOTE" } )]   := CriaVar( "L2_NLOTE" )
	Else
		If cCampo == "LN_LOTECTL"
			cLoteCtl  := M->LN_LOTECTL
			cNLote    := aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_NLOTE" } )]
		ElseIf cCampo == "LN_NLOTE"
			cLoteCtl  := aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_LOTECTL" } )]
			cNLote    := M->LN_NLOTE
		Else
			cLoteCtl  := aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_LOTECTL" } )]
			cNLote    := aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_NLOTE" } )]
		Endif

		cLocaliza 	:= aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_LOCALIZ" } )]
		cLocal 		:= aCols[n][AScan( aHeader, { |x| AllTrim( x[2] ) == "LN_LOCAL" } )]

		If Empty( cLoteCtl )
			nQtdeLote := SldAtuEst( cCodPro, cLocal, nQuant )

			If nQtdeLote < nQuant
				// "Saldo Insuficiente", "Não há saldo disponível no lote " "Saldo Disponível: "
				Aviso( "Saldo Insuficiente", "Não há saldo disponível no lote " + cLoteCtl + Chr( 10 ) + "Saldo Disponível: " + AllTrim( Str( nQtdeLote ) ), { "Ok" } )
				lRet := .F.
			Endif
		Else
			If SB1->B1_RASTRO == "L"
				DbSelectArea( "SB8" )
				SB8->( DbSetOrder( 5 ) )
				SB8->( DbSeek( xFilial() + cCodPro + cLoteCtl + If( Empty( cNLote ), "", cNLote ) ) )
			Else
				DbSelectArea( "SB8" )
				SB8->( DbSetOrder( 2 ) )
				SB8->( DbSeek( xFilial() + cNLote + cLoteCtl + cCodPro ) )
			Endif

			If SB8->( EOF() )
				// "Lote não encontrado", "O lote " ###/### " não foi encontrado. Informe um lote válido."
				Aviso( "Lote não encontrado", "O lote " + cLoteCtl + "/" + cNLote + " não foi encontrado. Informe um lote válido.", { "Ok" } )
				lRet := .F.
			Else
				nQtdeLote := SldAtuEst( cCodPro, cLocal, nQuant, cLoteCtl, cNLote, cLocaliza, "", "" )

				If nQtdeLote < nQuant
					// "Saldo Insuficiente", "Não há saldo disponível no lote " "Saldo Disponível: "
					Aviso( "Saldo Insuficiente", "Não há saldo disponível no lote " + cLoteCtl + Chr( 10 ) + "Saldo Disponível: " + AllTrim( Str( nQtdeLote ) ), { "Ok" } )
					lRet := .F.
				Endif
			Endif
		Endif
	Endif
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Lj430Cfo  ºAutor  ³Vendas Clientes     º Data ³  26/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para preencher o CFOP corretamente, de acordo com o  º±±
±±º          ³produto e cliente digitados na distribuicao de mercadorias  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA430                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj430Cfo( nOpca )
Local aDadosCfo := {}			// Array para utilizacao na funcao MAFISCFO
Local cCfop		:= ""			// Retorno do CFOP

SA1->( DbSetOrder ( 1 ) )
If SA1->(  DbSeek( xFilial("SA1") + M->LM_CLIENTE + M->LM_LOJA ) )
	If nOpca == 2				// Item
		Aadd(aDadosCfo,{"OPERNF","S"})
		Aadd(aDadosCfo,{"TPCLIFOR","N"})
		Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
		Aadd(aDadosCfo,{"INSCR", SA1->A1_INSCR})
		cCfop := MaFisCfo(,SF4->F4_CF,aDadosCfo)
	Else
		If Len(aCols) > 0 .AND. !Empty(aCols[1][1])
			LjMsgRun(STR0046,,{|| Lj430PrCfo() })  //"Aguarde... Recalculando itens"
		Endif
	Endif
Endif
Return(cCfOP)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Lj430PrCfoºAutor  ³Vendas Clientes     º Data ³  27/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para recalcular o CFOP dos itens do Acols apresentan-º±±
±±º          ³do a mensagem ao usuario                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA430                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj430PrCfo()
Local nCont		:= 0			// Contador utilizado no FOR
Local aDadosCfo := {}			// Array para utilizacao na funcao MAFISCFO
Local nPosCF	:= 0			// Posicao do codigo fiscal do item

For nCont := 1 to Len(aCols)
	Aadd(aDadosCfo,{"OPERNF","S"})
	Aadd(aDadosCfo,{"TPCLIFOR","N"})
	Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
	Aadd(aDadosCfo,{"INSCR", SA1->A1_INSCR})
	nPosCF := AScan(aHeader, {|x| AllTrim(x[2])=="LN_CF"})
	If nPosCF > 0
		cCfop := MaFisCfo(,aCols[nCont][nPosCF],aDadosCfo)
		aCols[nCont][nPosCF] := cCfop
	Endif
	oGet:Refresh()
Next nCont
Return           


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ LJ430FillGetº Autor ³ Vendas Clientes   º Data ³ 10/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Montagem do aHeader e aCols pelo Protheus 9.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Void LJ430FillGet(ExpN1)	                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 = Operacao                                    		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil                                                 		   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA430                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ430FillGet( nOpc )
Local cSeek		 := NIL									// Variavel de busca
Local cWhile	 := NIL									// Enquanto
Local lInclusao	 := If(nOpc <> 3, .F. , .T. )			// Se eh inclusao
Local aHeaderAux := {}
Local nPosItem   := 0  									//Posicao do campo LN_ITEM no cabecalho

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for inclusao, nao alimenta as variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lInclusao
	cSeek := xFilial("SLN") + SLM->LM_NUM 
	cWhile := "SLN->LN_FILIAL + SLN->LN_NUM" 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem aHeader, aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aHeader) == 0 .AND. Len(aCols) == 0
	FillGetDados(	nOpc			,	"SLN"		,	2				,	cSeek			,;
					{|| &cWhile}	,	{|| .T. }	,	/*aNoFields*/	,	/*aYesFields*/	,; 
					/*lOnlyYes*/	,	/*cQuery*/	,	/*bMontCols*/	, 	lInclusao 		,;
					aHeaderAux	    , /*aColsAux*/	,	/*bAfterCols*/	, 	/*bBeforCols*/ 	,;
					/*bAfterHeader*/, /*cAliasQry*/	, 	/*bCriaVar*/	, 	/*lUserFields*/	,;
					/*aYesUsado*/ )
					
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for inclusao, inicia o campo LN_ITEM com 01³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosItem  := Ascan(aHeader,{|x| AllTrim(x[2]) == "LN_ITEM"})
	If lInclusao .AND. nPosItem > 0
		aEval(aCols,{|x| x[nPosItem]:= "01" })
	EndIf
Endif
 
Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ Lj430VlDir  º Autor ³ Vendas Clientes   º Data ³ 18/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Distribuicao de mercadoria entre as as filiais              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ Lj430VlDir()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj430VlDir()

Local cRet := "" //Retorna Valor do parametro
Local cMV_LJDIRGR := SuperGetMV("MV_LJDIRGR",,"")	   // Parametro onde grava arquivo

If Substr(cMV_LJDIRGR,1,1)=="&"
	cRet := &(Substr(cMV_LJDIRGR,2,Len(cMV_LJDIRGR)))
Else
	cRet := cMV_LJDIRGR
EndIf
Return(cRet)

