#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTDEF.CH"

#DEFINE SIGALOJA  12
#DEFINE FRONTLOJA 23 
 
Static oTimerFrt    := NIL    
Static lPrecMult    := .F.      //Indica se a Consulta esta ativa    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³DROCONSPRC³ Autor ³ Fernando Fonseca      ³ Data ³15/03/2007		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Fabr.Tradicional ³Contato ³ fernando.santos@microsiga.com.br     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina que permite a Consulta de Precos dos Produtos de Acordo    ³±±
±±³			 ³com o Cliente selecionado, levando em consideracao os planos de   ³±±
±±³			 ³Fidelidade implementados no Template de Drogarias.				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³ SigaLoja / FrontLoja                                       		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Template de Drogarias                                       		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observ.   ³ Esta Rotina eh chamada pela rotina LOJC060, o qual disponibiliza-³±±
±±³          ³ rá sua chamada atraves da verificacao HasTemplate("DRO")			³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROCONSPRC()
Local nReg		:= 1
Local nRPCInt	:= LjGetStation("RPCINT")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Area da tela para o Define da Dialog e Posicao dos objetos	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSize1 	:= MsAdvSize()						// Tamanho da tela               
Local aPosObj1	:= {}								// Area total de trabalho
Local aPosObj2	:= {}								// Toolbar direita
Local aPosObj3	:= {}								// Enchoice, Getdados, Panel
Local aPosObj4	:= {}								// Panel que contem Pagamentos
Local aPosObj5	:= {}								// Objetos dentro do painel de Totais

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis de Campos da Tela.Gets Fixos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Clientes	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodCli	 	 := Space(06)
Local oCodCli	 	 := NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Loja    	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cLoja	 	 	 := Space(04)
Local oLoja	 		 := NIL                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desc. Cliente  	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cNomeCli 		 := Space(25)
Local oNomeCli 		 := NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Plan. Fidelidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPLFidel		 := Space(15)
Local oPLFidel	 	 := NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desc.Plan. Fidelidade ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDescPLF	 	 := Space(15)
Local oDescPLF		 := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fonte para Formatar o Campo Tot. Mercadorias|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oFont			 := Nil
DEFINE FONT oFont NAME "Arial" BOLD SIZE 08,15

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor Total dos Produtos	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oSayProd 	 := NIL
Private nTotProd 	 := 0
Private cTotProd 	 := AllTrim( TRANSFORM(nTotProd,"@E 999,999,999.99") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor Total dos Produtos Com Desconto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oTotPrDesc 	 := NIL
Private nTotPrDesc 	 := 0
Private cTotPrDesc 	 := AllTrim( TRANSFORM(nTotPrDesc,"@E 999,999,999.99") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor Total do Desconto 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oTotDesc 	 := NIL
Private nTotDesc 	 := 0
Private nTotVDesc	 := 0
Private cTotDesc 	 := AllTrim( TRANSFORM(nTotProd,"@E 999,999,999.99") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³% Medio de Desconto     	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oPerMDesc 	 := NIL
Private nPerMDesc 	 := 0
Private cPerMDesc 	 := AllTrim( TRANSFORM(nTotProd,"@E 999,999,999.99") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos de Tela.         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oDlg   	   	 := Nil
Private oGetDados1 	 := Nil

lPrecMult := .T.
nRPCInt := If(nRPCInt=0, 5, nRPCInt)

DEFINE MSDIALOG oDlg TITLE "Consulta de Preços" FROM aSize1[7],0 TO aSize1[6]+20 ,aSize1[5] OF oMainWnd PIXEL  // "Consulta de Precos"

DEFINE TIMER oTimerFrt INTERVAL nRPCInt*1000 ACTION LjTimerFrt() OF oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CRIA REGTOMEMORY DA ENCHOICE                         ³
//³ True  - Traz Enchoice vazia pronta para Inclusao     ³
//³ False - Traz Enchoice com o Registro definido pela	 ³
//³ variavel nReg										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("SLQ", .T.)

DrocprGets(@oDlg 	, @oCodCli , @cCodCli , @oLoja,;
		   @cLoja	, @oNomeCli, @cNomeCli, @oPLFidel,;
		   @cPLFidel, @oDescPLF, @cDescPLF) 	 	      						// Montagem do Cabecalho da Tela.

DrocprRePos(aSize1, @aPosObj1, @aPosObj2, @aPosObj3,;
			@aPosObj4, @aPosObj5)  												// Define posicao dos objetos da Tela.

DrocprGetD( nReg, aPosObj3, @oDlg ) 					 						// Montagem Get Dados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria as Groups de Totalizadores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@aPosObj3[2,3]+4, aPosObj3[2,2] TO aPosObj3[2,3]+32, aPosObj3[2,4] LABEL "Totalizadores" COLOR CLR_BLUE PIXEL OF  oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor Total do Produto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj3[2,3]+09 , 015 SAY " Total Preço Unitário		R$    "	SIZE 0114,0128 RIGHT COLOR CLR_BLUE PIXEL OF oDlg FONT oFont 
@ aPosObj3[2,3]+09 , 034 SAY oSayProd 	 VAR  cTotProd       	SIZE 0124,0168 RIGHT COLOR CLR_BLUE PIXEL OF oDlg FONT oFont
oSayProd:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor Total do Produto c/ Desconto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj3[2,3]+20 , 007 SAY " Valor Total dos Itens        R$"  SIZE 0114,0128 RIGHT COLOR CLR_BLUE PIXEL OF oDlg FONT oFont 
@ aPosObj3[2,3]+20 , 034 SAY oTotPrDesc VAR  cTotPrDesc          SIZE 0124,0168 RIGHT COLOR CLR_BLUE PIXEL OF oDlg FONT oFont
oTotPrDesc:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desconto de    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
@ aPosObj3[2,3]+09 , 268 SAY "Total de Descontos (Valor)"  	SIZE 0124,0138 RIGHT COLOR CLR_HRED PIXEL OF oDlg FONT oFont 
@ aPosObj3[2,3]+09 , 284 SAY oTotDesc VAR  cTotDesc  		SIZE 0145,0215 RIGHT COLOR CLR_HRED PIXEL OF oDlg FONT oFont
oTotDesc:Refresh()
                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Percentual Medio de Desconto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj3[2,3]+20 , 270 SAY " % Média de Desconto		" 		SIZE 0124,0138 RIGHT COLOR CLR_HRED PIXEL OF oDlg FONT oFont 
@ aPosObj3[2,3]+20 , 275 SAY oPerMDesc  VAR  cPerMDesc   		SIZE 0145,0215 RIGHT COLOR CLR_HRED PIXEL OF oDlg FONT oFont
oPerMDesc:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Botao Cliente Padrao		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
@ 060,010 BUTTON "Cliente Padrão" SIZE 70,11 ACTION T_DroAtuCPOS("BOTAOCLIP", @oCodCli  , @cCodCli	, @oLoja	 ,;
																 @cLoja   	, @oNomeCli , @cNomeCli	, @oPLFidel  ,;
																 @cPLFidel	, @oDescPLF , @cDescPLF) OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT T_DrocGetKey( @oCodCli , @cCodCli, @oLoja, @cLoja		  ,;
													  @oNomeCli, @cNomeCli, @oPLFidel, @cPLFidel ,;
													  @oDescPLF, @cDescPLF ) VALID DroValid(@oTimerFrt)
													  									  
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³DroCPrGets()³ Autor ³ Fernando Fonseca      ³ Data ³16/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem dos Campos(Gets Fixos) na Tela                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ DroCPrGets()					                           	  ³±±
±±³           ³ oExp1  - Objeto Principal da Tela.      					  ³±±
±±³           ³ oExp2  - Objeto responsavel pela atualizacao do Codigo do     ³±±
±±³           ³		     Cliente na Tela.									  ³±±
±±³           ³ cExp3  - Variavel que recebe o Codigo do Cliente     	   	  ³±±
±±³           ³ oExp4  - Objeto responsavel pela atualizacao do Codigo da Loja³±±
±±³           ³ cExp5  - Variavel que recebe o Codigo da Loja	     	   	  ³±±
±±³           ³ oExp6  - Objeto responsavel pela atualizacao do Nome do Clien-³±±
±±³           ³ 		te.												   	  ³±±
±±³           ³ cExp7  - Variavel que recebe o Nome do Cliente	     	   	  ³±±
±±³           ³ oExp8  - Objeto responsavel pela atualizacao do Codigo do  	  ³±±
±±³           ³ 		Plano de Fidelidade.							   	  ³±±
±±³           ³ cExp9  - Variavel que recebe o Codigo do Plano de Fidelidade  ³±±
±±³           ³ oExp10 - Objeto responsavel pela atualizacao do Codigo do  	  ³±±
±±³           ³ 		Plano de Fidelidade.							   	  ³±±
±±³           ³ cExp11 - Variavel que recebe o Codigo do Plano de Fidelidade  ³±±
±±³			  ³																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao  ³ TEMPLATES DROGARIAS / FRONTLOJA 			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Template de Drogarias                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DrocprGets( oDlg    , oCodCli , cCodCli , oLoja   ,;
						    cLoja   , oNomeCli, cNomeCli, oPLFidel,;
						    cPLFidel, oDescPLF, cDescPLF ) 

@001, 004 TO 090, 490 LABEL "" COLOR CLR_BLUE PIXEL OF  oDlg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Legenda para as teclas de atalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@010, 350 TO 055, 470 LABEL "Teclas de Atalho" COLOR CLR_BLUE PIXEL OF  oDlg
@016, 380 SAY "F5  = Cliente Padrão"			SIZE 065,015 COLOR CLR_BLACK PIXEL OF oDlg 	
@025, 380 SAY "F8  = Plano de Fidelidade"		SIZE 065,015 COLOR CLR_BLACK PIXEL OF oDlg 	
@035, 380 SAY "F10 = Identificação do cliente"	SIZE 075,015 COLOR CLR_BLACK PIXEL OF oDlg 	
@045, 380 SAY "ESC = Sair da tela de consulta"	SIZE 075,015 COLOR CLR_BLACK PIXEL OF oDlg 		


@ 006,010 SAY 	"Cliente" 		SIZE 065,015 COLOR CLR_BLACK PIXEL OF oDlg 
@ 005,045 MSGET oCodCli   		VAR  cCodCli SIZE 060,005 COLOR CLR_BLACK  PICTURE "@!" WHEN .F. PIXEL OF oDlg  ;
						  		VALID	T_DroAtuCPOS("CODCLI"  , @oCodCli  , @cCodCli , @oLoja  ,;
						  						  	 @cLoja    , @oNomeCli , @cNomeCli, @oPLFidel,;
						  						  	 @cPLFidel , @oDescPLF , @cDescPLF)
									   
@ 006,198 SAY 	"Loja Cliente" SIZE 065,015 COLOR CLR_BLACK PIXEL OF oDlg
@ 005,228 MSGET oLoja  	 	   VAR  cLoja SIZE 025,005 COLOR CLR_BLACK 		PICTURE "@!"  WHEN .F. PIXEL OF oDlg

@ 018,010 SAY 	"Nome Cliente" SIZE 085,015 COLOR CLR_BLACK PIXEL OF oDlg 
@ 017,045 MSGET oNomeCli 	   VAR  cNomeCli SIZE 130,005 COLOR CLR_BLACK 	PICTURE "@!"  WHEN .F. PIXEL OF oDlg

@ 033,010 SAY 	"P.Fidelidade" SIZE  085,015 COLOR CLR_BLACK PIXEL OF oDlg 
@ 032,045 MSGET oPLFidel       VAR   cPLFidel SIZE 060,005 COLOR CLR_BLACK 	PICTURE "@!"  WHEN .F. PIXEL OF oDlg ;
							   VALID T_DroAtuCPOS("PLFIDEL"	, @oCodCli	, @cCodCli	, @oLoja	,;
						  						  @cLoja 	, @oNomeCli	, @cNomeCli	, @oPLFidel	,;
						  						  @cPLFidel	, @oDescPLF	, @cDescPLF)

@ 033,108 SAY 	"Desc. Plano"  SIZE 085,015 COLOR CLR_BLACK PIXEL OF oDlg 
@ 033,138 MSGET oDescPLF 	   VAR  cDescPLF SIZE 130,005 COLOR CLR_BLACK 	PICTURE "@!"  WHEN .F. PIXEL OF oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializo a Tela com o Cliente Padrao posicionado.³
//³                                                   ³
//³Para isto chamo a Funcao T_DroAtuCos com o primeiro³
//³parametro "BOTAOCLIP" (Mesmo parametro que a chama ³
//³da atraves do Botao Cliente Padrao).               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
T_DroAtuCPOS("BOTAOCLIP", @oCodCli  , @cCodCli	 , @oLoja	 ,;
		 	 @cLoja  	, @oNomeCli , @cNomeCli , @oPLFidel ,;
		 	 @cPLFidel	, @oDescPLF , @cDescPLF) 
	
Return Nil               

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ DroCPrRePos³ Autor ³ Fabio F. Pessoa      ³ Data ³ 29/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna posicao para criacao de objetos					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DroCPrRePos()					                           ³±±
±±³          ³ aExp1 - Array com a area total da tela					   ³±±
±±³          ³ aExp2 - Array da area de trabalho                     	   ³±±
±±³          ³ aExp3 - Array da toolbar a direita		            	   ³±±
±±³          ³ aExp4 - Array dos objetos								   ³±±
±±³          ³ aExp5 - Array dos objetos (contem a area do Panel           ³±±
±±³          ³ de Pagamentos.                                              ³±±
±±³          ³ aExp6 - Array dos objetos totais (dentro do Panel 		   ³±±
±±³          ³ de totais)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³ TEMPLATES DROGARIAS / SIGALOJA /FRONTLOJA                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Template de Drogarias                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DroCPrRePos( aSize1  , aPosObj1, aPosObj2, aPosObj3,;
							 aPosObj4, aPosObj5 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a area de trabalho da tela 							 ³
//³ Area T.Trab = Area da tela - (Area Enchoicebar+Area Toolbar) ³
//³ 															 ³
//³ Obs: O aSize1 foi definido na funcao principal 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aObjects1	:= {}								// Definicao da area dos objetos
Local aInfo1	:= {}								// Informacoes para a divisao da area

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a area dos objetos - Enchoice, Getdados e Panel		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSize3	:= {}
Local aObjects3	:= {}
Local aInfo3	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a area do objeto - Panel para Pagamentos 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSize4	:= {}
Local aObjects4	:= {}
Local aInfo4	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a area do objeto - Dentro do Panel de Totais          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aObjects5	:= {}
Local aInfo5	:= {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona objetos para calculo da area						 ³
//³ Toolbar e Enchoicebar										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects1, { 100, 100, .T., .T. } )
aAdd( aObjects1, { 010, 100, .F., .T. } )		// Reserva a toolbar lateral direita (X e sempre fixo)

aInfo1 	 := { aSize1[ 1 ], aSize1[ 2 ], aSize1[ 3 ], aSize1[ 4 ], 2, 2 }
aPosObj1 := MsObjSize( aInfo1, aObjects1, , .T. )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona objetos para calculo da area						 ³
//³ Enchoice, Getdados e Panel		 							 ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects3, { 050, 025, .T., .T. } )			// Enchoice	(Cabecalho)
aAdd( aObjects3, { 090, 040, .T., .T. } ) 			// GetDados	(Itens)
aAdd( aObjects3, { 025, 015, .T., .F., .T. } )		// Panel 1	(Totais)
aAdd( aObjects3, { 025, 010, .T., .F., .T. } )		// Panel 2	(Mensagens)

aSize3   := aPosObj1[1]
aInfo3   := { aSize3[ 2 ], aSize3[ 1 ], aSize3[ 4 ], aSize3[ 3 ], 2, 2 }
aPosObj3 := MsObjSize( aInfo3, aObjects3, .T. , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona objetos para calculo da area						 ³
//³ Enchoice, Getdados e Panel		 							 ³
//³ E feito dessa forma para identificar a area que a GetDados 	 ³
//³ ocupa. Lembrando que a diferenca entre a GetDados e o Panel  ³
//³ e que o 2o precisa estar em pixel, dai a necessidade		 ³	
//³ de repetir os objetos.										 ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects4, { 050, 025, .T., .T. } )			// Enchoice	(Cabecalho)
aAdd( aObjects4, { 080, 050, .T., .T., .T. } ) 	// Panel 3	(Pagamentos)
aAdd( aObjects4, { 025, 015, .T., .F., .T. } )		// Panel 1	(Totais)
aAdd( aObjects4, { 025, 010, .T., .F., .T. } )		// Panel 2	(Mensagens)

aSize4   := aPosObj1[1]
aInfo4   := { aSize4[ 2 ], aSize4[ 1 ], aSize4[ 4 ], aSize4[ 3 ], 2, 2 }
aPosObj4 := MsObjSize( aInfo4, aObjects4, .T. , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona objetos para calculo da area						 ³
//³ dos objetos dentro do Panel totais                           ³
//³ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ³
//³               I  M  P  O  R  T  A  N  T  E                   ³
//³ Esses objetos estao 'pendurados' no aPosObj4[3]              ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aObjects5, { 100, 030, .T., .T. } )	// Titulo do subtotal
aAdd( aObjects5, { 100, 030, .T., .T. } )	// Valor  do subtotal
aAdd( aObjects5, { 055, 030, .T., .T. } )	// Titulo do Desconto %
aAdd( aObjects5, { 055, 030, .T., .T. } )	// Valor  do Desconto %
aAdd( aObjects5, { 085, 030, .T., .T. } )	// Titulo do Desconto $
aAdd( aObjects5, { 085, 030, .T., .T. } )	// Valor  do Desconto $
aAdd( aObjects5, { 132, 030, .T., .T. } )	// Titulo do Total da venda
aAdd( aObjects5, { 132, 030, .T., .T. } )	// Valor  do Total da venda

aInfo5 := { 0, 0, aPosObj4[3,3], aPosObj3[3,4], 2, 2 }
aPosObj5 := MsObjSize( aInfo5, aObjects5, .T., .T. )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³DroCPrGetD()³ Autor ³ Fernando Fonseca       ³ Data ³16/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ DroCPrGetD()					                           	  ³±±
±±³           ³ nExp1  - Numero de Registro Posicionado na GetDados.		  ³±±
±±³           ³ aExp2  - Array contendo as Dimensoes da Tela                  ³±±
±±³           ³ oExp3  - Objeto que Contem a Tela Principal          	   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do         ³±±
±±³           ³ seu programa:                                                 ³±±             
±±³           ³ Para acessar o aCols desta MsNewGetDados:					  ³±±
±±³			  ³	oGetDados1:aCols[nX,nY]										  ³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]             ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao  ³ TEMPLATES DROGARIAS / FRONTLOJA 			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Template de Drogarias                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DrocprGetD( nReg, aPosObj3, oDlg )

Local aCpoGDa       := {"LR_ITEM"    , "LR_PRODUTO" , "LR_DESCRI", "LR_QUANT", "LR_VRUNIT"  , "LR_VLRITEM" ,  "LR_DESC" , "LR_VALDESC" } 
Local aAlter       	:= {"LR_PRODUTO" , "LR_QUANT" }
Local aHead        	:= {}
Local aCol         	:= {}
Local bTudoOk      	:= "AllwaysTrue"
Local cFieldOk     	:= "AllwaysTrue"
Local cSuperDel    	:= ""
Local cIniCpos     	:= "+LR_ITEM"
Local nOpc         	:= GD_INSERT+GD_DELETE+GD_UPDATE
Local nX			:= 0
Local nFreeze      	:= 000
Local nMax         	:= 999
Local bLinOk       	:= "AllWaysTrue"
Local bDelOk       	:= "T_DrocCalcTot('DelOK',n)"
Local oWnd         	:= oDlg
Local cValid		:= ""
Local cRelacao		:= ""

SX3->(DbSetOrder(2)) // X3_CAMPO
For nX := 1 to Len(aCpoGDa)
	If SX3->(DbSeek(aCpoGDa[nX]))
		
		cValid	 := SX3->X3_VALID
		cRelacao := SX3->X3_RELACAO
		
		If AllTrim(Upper(SX3->X3_CAMPO)) == "LR_PRODUTO"
			cValid := "T_TPLDr7Prod('LR_PRODUTO')" 
		EndIf
		
		If AllTrim(Upper(SX3->X3_CAMPO)) == "LR_QUANT"
			cValid := "T_TPLDr7Prod('LR_QUANT')" 
		EndIf
		
		If	AllTrim(Upper(SX3->X3_CAMPO)) == "LR_VALDESC" .Or.;
			AllTrim(Upper(SX3->X3_CAMPO)) == "LR_DESC" .Or.;
			AllTrim(Upper(SX3->X3_CAMPO)) == "LR_TES"
			
			cValid := ".T."
		EndIf
	
		Aadd(aHead,{ AllTrim(X3Titulo()),; 
		SX3->X3_CAMPO	,;
		SX3->X3_PICTURE ,;
		SX3->X3_TAMANHO ,;             
		SX3->X3_DECIMAL ,;
		cValid		    ,;
		SX3->X3_USADO	,;
		SX3->X3_TIPO	,;
		If(nModulo == SIGALOJA  .AND. aCpoGDa[nX] == "LR_PRODUTO", SX3->X3_F3			 ,;
		If(nModulo == FRONTLOJA .AND. aCpoGDa[nX] == "LR_PRODUTO", "FRT", SX3->X3_F3)),; // Definindo tecla F3 para chamada do SigaLoja ou FrontLoja.
		SX3->X3_CONTEXT ,;
		SX3->X3_CBOX	,;
		cRelacao		,;
		"" /*X3_WHEN */ ,; 
		"" /*X3_VISUAL*/,; 
		SX3->X3_VLDUSER ,;
		""/* X3_PICTVAR*/})
	EndIf
Next nX

aAdd(aCol,Array(Len(aHead)+1))
For nX := 1 To Len(aHead)
	If Alltrim(aHead[nX, 2]) == "LR_ITEM"
		aCol[1, nX] := "01"
	Else
		aCol[1, nX] := CriaVar(aHead[nX, 2])
	EndIf
Next nX
aCol[Len(aCol), Len(aHead)+1] := .F.

oGetDados1:= MsNewGetDados():New(aPosObj3[2,1], aPosObj3[2,2],  aPosObj3[2,3], aPosObj3[2,4]	,;
								  nOpc, bLinOk, bTudoOk, cIniCpos, aAlter,nFreeze, nMax, cFieldOk,;
								  cSuperDel, bDelOk, oWnd, aHead, aCol)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³ NwDeleted  ³ Autor ³ Fernando Fonseca      ³ Data ³16/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Verifica se a linha da NewGetDados esta Deletada.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ lRet := True = Linha Deletada / False = Nao Deletada         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwDeleted( oObjeto, nLinha )
Local nCol := Len(oObjeto:aCols[1])                                             
Local lRet := .T.                                                               

DEFAULT nLinha := oObjeto:nAt 				// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto 

lRet := oObjeto:aCols[nLinha,nCol]         // Alimenta Celula com novo Valor

Return lRet                                                                    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³DrocCalcTot³ Autor ³ Fernando Fonseca      ³ Data ³16/03/2007		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ IP	     |Contato³ fernando.santos@microsiga.com.br  		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza o Rodape que indica os Totalizadores de Produtos e Descon-|±±
±±³			 ³tos Conforme os Valores dos Produtos na NewGetDados 				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem - Indica o Evento de Tecla que disparou a Rotina.  		 ³±±
±±³			 ³ nLin    - Posicao da Linha para checar se estah ou nao marcada 	 ³±±
±±³          ³           para Delecao.											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³ TEMPLATES DROGARIAS / SIGALOJA /FRONTLOJA                   		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Template de Drogarias                                       		 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DrocCalcTot( cOrigem, nLin )
Local nI		:= 0        //Variavel do Laco For
Local nItens	:= 0     	//Variavel que Conta os Itens do aCols para Calculo posterior do Percentual Medio de Desconto.
Local lLnDel	:= .F.

DEFAULT nLin	:= 1

/*Variaveis Private Usadas:						
//³Todas as Variaveis que indicam os Totalizadores do Rodape.
//|Foi necessario Declarar Variaveis Private para Atualizar o |
//|Rodape quando eh Pressionada a Tecla Del no aCols, pois o  | 
//|evento desta tecla nao permite de forma alguma que se atua-|
//|lize o conteudo passado para ele por Funcao. 	
*/
//Verificar a Acao das Teclas
Do Case
	Case cOrigem <> "DelOK"	// Chamada da Funcao nao foi acionada pela tecla DELETE.
			nTotProd	:= 0
			nTotPrDesc	:= 0
			nTotDesc	:= 0
			nTotVDesc	:= 0
			For nI := 1 to Len(oGetDados1:aCols)
				If !NwDeleted(@oGetDados1,nI) 			// Linha nao Estah marcada para Delecao.
					DroDtACols( nI		,	@nTotProd,	@nTotPrDesc,	@nTotDesc,;
								@nItens	,	@nTotVDesc)
				EndIf
			Next nI
	Case cOrigem == "DelOK" // Pressionada a Tecla Delete.		
		/*
			O Grid é marcado como deletado após passar por essa rotina 
			portanto o comando NwDeleted(@oGetDados1,nI), não é efetivo.
			As validações devem ser a partir lLnDel e nLin(linha atual)
		*/
		nTotProd	:= 0
		nTotPrDesc  := 0
	    nTotDesc    := 0
	    nTotVDesc	:= 0
		For nI := 1 to Len(oGetDados1:aCols)
			lLnDel := oGetDados1:aCols[nI][Len(oGetDados1:aCols[nI])]
			If (lLnDel .And. (nI == nLin)) .Or. ( !lLnDel .And. !(nI == nLin))
			    DroDtACols( nI		,	@nTotProd	,	@nTotPrDesc,	@nTotDesc,;
							@nItens	,	@nTotVDesc	)
			EndIf	
		Next nI
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Percentual Medio de Desconto.				 ³
//³												 ³
//³Total da Percentual de Desconto sobre os Itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPerMDesc := ( nTotDesc / nItens )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Refresh nos Totalizadores que aparecerao na Tela.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTotProd 	:= AllTrim( TRANSFORM(nTotProd   , "@E 999,999,999.99") )
cTotPrDesc 	:= AllTrim( TRANSFORM(nTotPrDesc , "@E 999,999,999.99") )
cTotDesc 	:= AllTrim( TRANSFORM(nTotVDesc  , "@E 999,999,999.99") )
cPerMDesc	:= AllTrim( TRANSFORM(nPerMDesc  , "@E 999,999,999.99") )
oSayProd:Refresh()
oTotPrDesc:Refresh()
oTotPrDesc:Refresh()
oTotDesc:Refresh()
oPerMDesc:Refresh()
		
Return .T.

//---------------------------------------------------
/*/{Protheus.doc} DroDtACols()
Atualiza os dados do aCols

@author	julio.nery
@param     
@return   NIL
@version P12
@since	11/02/2019
/*/
//---------------------------------------------------
Static Function DroDtACols( nI		,	nLTotProd	,	nLTotPrDesc,	nLTotDesc,;
							nLItens	,	nLTotVDes	)
Local nPosQuant	  		:= aScan(oGetDados1:aHeader,{|x| Trim(x[2]) == "LR_QUANT"   }) 	// Posicao da Quantidade
Local nPosVlUnit  		:= aScan(oGetDados1:aHeader,{|x| Trim(x[2]) == "LR_VRUNIT"  })	// Posicao do Valor unitario do item
Local nPosVlrItem  		:= aScan(oGetDados1:aHeader,{|x| Trim(x[2]) == "LR_VLRITEM" }) 	// Posicao do Valor do item
Local nPosDesc	  		:= aScan(oGetDados1:aHeader,{|x| Trim(x[2]) == "LR_DESC"	}) 	// Posicao do percentual de desconto
Local nPosValDes		:= aScan(oGetDados1:aHeader,{|x| Trim(x[2]) == "LR_VALDESC"	}) 	// Posicao do valor de desconto

/*Calculo do Valor Total dos Produtos*/
nLTotProd   += oGetDados1:aCols[nI][nPosQuant] * oGetDados1:aCols[nI][nPosVlUnit] //oGetDados1:aCols[nI][nPosVlrItem]

/*Calculo do Valor dos Produtos com Desconto*/
nLTotPrDesc += (oGetDados1:aCols[nI][nPosVlrItem])

/*Total de Desconto Concedido*/
nLTotDesc   += oGetDados1:aCols[nI][nPosDesc]

nLTotVDes	+= oGetDados1:aCols[nI][nPosValDes]

/*Verificando se os itens(produtos) tem Desconto
para o Percentual Medio de Desconto*/
nLItens		+= If( oGetDados1:aCols[nI][nPosDesc] > 0.00 , 1 ,0)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³DrogAtuCPOS³ Autor ³ Fernando Fonseca      ³ Data ³16/03/2007	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao    ³ IP	      |Contato³ fernando.santos@microsiga.com.br  		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³1.Atualiza Cliente , Plano de Fidelidade ou Cliente Padrao		 ³±±
±±³			  ³Conforme especificado pelo parametro cFocus. Os parametros restan-³±±
±±³			  ³diz respeito aos campos que serao Atualizados.					 ³±±
±±³			  ³2.Esta Rotina tambem chama o(s) Plano(s) de Fidelidade de forma   |±±
±±³			  ³automatica para o Cliente. 										 |±±
±±³Parametros ³ DroAtuCPOS()					                           	  	 ³±±
±±³           ³ cExp1  - Variavel Responsavel pela Posicao do Campo posicionado	 ³±±
±±³           ³          no Momento. 				                          	 ³±±
±±³           ³ oExp2  - Objeto responsavel pela atualizacao do Codigo do    	 ³±±
±±³           ³		     Cliente na Tela.									  	 ³±±
±±³           ³ cExp3  - Variavel que recebe o Codigo do Cliente     	   	  	 ³±±
±±³           ³ oExp4  - Objeto responsavel pela atualizacao do Codigo da Loja	 ³±±
±±³           ³ cExp5  - Variavel que recebe o Codigo da Loja	     	   	  	 ³±±
±±³           ³ oExp6  - Objeto responsavel pela atualizacao do Nome do Clien- 	 ³±±
±±³           ³ 		 te.											   	  	 ³±±
±±³           ³ cExp7  - Variavel que recebe o Nome do Cliente	     	   	  	 ³±±
±±³           ³ oExp8  - Objeto responsavel pela atualizacao do Codigo do  	  	 ³±±
±±³           ³ 		 Plano de Fidelidade.							   	  	 ³±±
±±³           ³ cExp9  - Variavel que recebe o Codigo do Plano de Fidelidade  	 ³±±
±±³           ³ oExp10 - Objeto responsavel pela atualizacao da Descricao do  	 ³±±
±±³           ³ 		 Plano de Fidelidade.							   	  	 ³±±
±±³           ³ cExp11 - Variavel que recebe a Descricao do Plano de Fidelida-	 ³±±
±±³			  ³			 de.												  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao  ³ TEMPLATES DROGARIAS / SIGALOJA                             		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Template de Drogarias                                      		 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DroAtuCPOS( cFocus  , oCodCli , cCodCli , oLoja   ,;
							  cLoja   , oNomeCli, cNomeCli, oPLFidel,;
							  cPLFidel, oDescPLF, cDescPLF )

Local nTamSXG  	:= TamSXG("001")[1]		// 	Usada quando o cFocus = Botao Cliente Padrao.
Local lRet 	   	:=.F.					//	Retorno da Funcao
Local nX		:= 0					// 	Variavel para laco For - reiniciar aCols.

Do Case
	Case cFocus == "CODCLI" 
		lRet:=.T.
		If !Empty(cCodCli)
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+cCodCli))
				lRet:=.T.
				cNomeCli :=SA1->A1_NOME
				cLoja	 :=SA1->A1_LOJA
				oNomeCli:Refresh()
				oLoja:Refresh()
				oPLFidel:SetFocus()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Exibe a Tela - Plano de Fidelidade.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				T_DrogLoadPF(.T., @oPLFidel, @cPLFidel, @oDescPLF, @cDescPLF)
				M->LQ_CPLFIDE := cPLFidel 	// Atualizo o Cod. Plano de Fidelidade.
		 	EndIf
        EndIf	

	Case cFocus == "PLFIDEL"
		lRet:=.T.
		T_DrogLoadPF(.F., @oPLFidel, @cPLFidel, @oDescPLF, @cDescPLF)
		oGetDados1:Obrowse:nColPos :=2 		// Posiciona o Cursor no Campo Produto da NewGetDados
		M->LQ_CPLFIDE := cPLFidel 			// Atualizo o Cod. Plano de Fidelidade.

	Case cFocus == "BOTAOCLIP"
		lRet:=.T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza Valores dos Campos de Cabecalho da Tela  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodCli  := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
		nTamSXG  := TamSXG("002")[1]
		cLoja	 := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
		cNomeCli := SubStr(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_NOME"),1,30)
		cPLFidel := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_CODPLF1")
		cDescPLF := Posicione("MHG",1,xFilial("MHG")+cPLFidel,"MHG_NOME")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizacao dos Campos de Cabecalho da Tela.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oCodCli:Refresh()
		oLoja:Refresh()		
		oNomeCli:Refresh()
		oPLFidel:Refresh()
		oDescPLF:Refresh()
		M->LQ_CPLFIDE := cPLFidel  			// Atualizo o Cod. Plano de Fidelidade.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Como estou em um Novo Cliente, Reinicio os Valores do aCols³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If Type('oGetDados1') <> 'U'
			oGetDados1:aCols:={}
			aAdd(oGetDados1:aCols,Array(Len(oGetDados1:aHeader)+1))
			For nX := 1 To Len(oGetDados1:aHeader)
				If Alltrim(oGetDados1:aHeader[nX, 2]) == "LR_ITEM"
					oGetDados1:aCols[1, nX] := "01"
				Else
					oGetDados1:aCols[1, nX] := CriaVar(oGetDados1:aHeader[nX, 2])
				EndIf
			Next nX
			oGetDados1:aCols[Len(oGetDados1:aCols), Len(oGetDados1:aHeader)+1] := .F.
			oGetDados1:oBrowse:Refresh()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reinicio Todos os meus Totalizadores			 ³
		//³Para isso verifico se os meus objetos estao 	 ³
		//³ativos, ou seja, se jah sofreram calculos com ³
		//³Produtos no aCols.							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If Type('oSayProd')   <> 'U' .AND. ;
		   Type('oTotPrDesc') <> 'U' .AND. ;
		   Type('oTotPrDesc') <> 'U' .AND. ;
		   Type('oTotDesc')   <> 'U' .AND. ;
		   Type('oPerMDesc')  <> 'U'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Reinicio Todos os meus Totalizadores			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotProd 	:= 0.00
			nTotPrDesc 	:= 0.00
			nTotDesc 	:= 0.00
			nPerMDesc	:= 0.00
			nTotVDesc	:= 0.00
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Refresh nos Totalizadores que aparecerao na Tela.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTotProd 	:= AllTrim( TRANSFORM(nTotProd   , "@E 999,999,999.99") )
			cTotPrDesc 	:= AllTrim( TRANSFORM(nTotPrDesc , "@E 999,999,999.99") )
			cTotDesc 	:= AllTrim( TRANSFORM(nTotVDesc  , "@E 999,999,999.99") )
			cPerMDesc	:= AllTrim( TRANSFORM(nPerMDesc  , "@E 999,999,999.99") )
			oSayProd:Refresh()
			oTotPrDesc:Refresh()
			oTotPrDesc:Refresh()
			oTotDesc:Refresh()
			oPerMDesc:Refresh()		
		EndIf	
EndCase		

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³DrocGetKey³ Autor ³ Fernando Fonseca      ³ Data ³16/03/2007	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao    ³ IP		|Contato³ fernando.santos@microsiga.com.br  		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Pega a Tecla Pressionada e Chama Rotina para Executar um evento ³±±
±±³			  ³(Rotina)na Rotina de Consulta de Precos						   ³±±
±±³           ³             					                           	   ³±±
±±³Parametros ³ DrocGetKey()					                           	   ³±±
±±³           ³             					                           	   ³±±
±±³           ³ oExp1  - Objeto responsavel pela atualizacao do Codigo do      ³±±
±±³           ³		     Cliente na Tela.									   ³±±
±±³           ³ cExp2  - Variavel que recebe o Codigo do Cliente     	   	   ³±±
±±³           ³ oExp3  - Objeto responsavel pela atualizacao do Codigo da Loja ³±±
±±³           ³ cExp4  - Variavel que recebe o Codigo da Loja	     	   	   ³±±
±±³           ³ oExp5  - Objeto responsavel pela atualizacao do Nome do Clien- ³±±
±±³           ³ 		 te												   	   ³±±
±±³           ³ cExp6  - Variavel que recebe o Nome do Cliente     	   	       ³±±
±±³           ³ oExp7  - Objeto responsavel pela atualizacao do Codigo do  	   ³±±
±±³           ³ 		 Plano de Fidelidade.							   	   ³±±
±±³           ³ cExp8  - Variavel que recebe o Codigo do Plano de Fidelidade   ³±±
±±³           ³ oExp9  - Objeto responsavel pela atualizacao da Descricao do   ³±±
±±³           ³ 		 Plano de Fidelidade.							   	   ³±±
±±³           ³ cExp10 - Variavel que recebe a Descricao do Plano de Fidelida- ³±±
±±³			  ³			 de													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao  ³ TEMPLATES DROGARIAS / SIGALOJA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Template de Drogarias                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DrocGetKey( oCodCli , cCodCli	, oLoja	   , cLoja	  ,;
							  oNomeCli, cNomeCli, oPLFidel , cPLFidel,;
							  oDescPLF, cDescPLF)

SetKey( VK_F5, { || T_DrogSetKey( "F5"   	 , @oCodCli , @cCodCli , @oLoja   ,;
						   		   @cLoja	 , @oNomeCli, @cNomeCli, @oPLFidel,;
						   		   @cPLFidel , @oDescPLF, @cDescPLF ) } )	

SetKey( VK_F8, { || T_DrogSetKey( "F8"		, @oCodCli , @cCodCli , @oLoja 	  ,;
								   @cLoja  	, @oNomeCli, @cNomeCli, @oPLFidel,;
								   @cPLFidel, @oDescPLF, @cDescPLF ) } )	

SetKey( VK_F10, { || T_DrogSetKey( "F10"	 , @oCodCli , @cCodCli , @oLoja   ,;
								    @cLoja 	 , @oNomeCli, @cNomeCli, @oPLFidel,;
								    @cPLFidel, @oDescPLF, @cDescPLF ) } )
								   
oDlg:lEscClose:=.T. //tecla ESC

oTimerFrt:Activate()
								   
Return .T.                          

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa   ³DrogSetKey³ Autor ³ Fernando Fonseca      ³ Data ³16/03/2007	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao    ³ IP		 |Contato³ fernando.santos@microsiga.com.br  		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Chamada de Evento das Teclas de Atalho simulando um F3	       ³±±
±±³			  ³Dependendo da Tecla Disparada na Rotina de Consulta de Precos   ³±±
±±³			  ³Obs: Nesta Rotina foi necessario chamar uma Rotina Padrao 	   ³±±
±±³			  ³CrdIdentCli(Rotina de Identificacao do Cliente-RETAGUARDA) para ³±±
±±³			  ³Obter os Dados do Vetor aDadosCli. Neste Vetor foi colocado mais³±±
±±³		      ³um Parametro(NomeClie) para trazer o nome do Cliente. 		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ³             					                           	   ³±±
±±³Parametros ³ DrogSetKey()					                           	   ³±±
±±³           ³             					                           	   ³±±
±±³           ³ cExp1  - Variavel que Representa a Tecla Pressionada           ³±±
±±³           ³ oExp1  - Objeto responsavel pela atualizacao do Codigo do      ³±±
±±³           ³		     Cliente na Tela.									   ³±±
±±³           ³ cExp2  - Variavel que recebe o Codigo do Cliente     	   	   ³±±
±±³           ³ oExp3  - Objeto responsavel pela atualizacao do Codigo da Loja ³±±
±±³           ³ cExp4  - Variavel que recebe o Codigo da Loja	     	   	   ³±±
±±³           ³ oExp5  - Objeto responsavel pela atualizacao do Nome do Clien- ³±±
±±³           ³ 		 te												   	   ³±±
±±³           ³ cExp6  - Variavel que recebe o Nome do Cliente     	   	       ³±±
±±³           ³ oExp7  - Objeto responsavel pela atualizacao do Codigo do  	   ³±±
±±³           ³ 		 Plano de Fidelidade.							   	   ³±±
±±³           ³ cExp8  - Variavel que recebe o Codigo do Plano de Fidelidade   ³±±
±±³           ³ oExp9  - Objeto responsavel pela atualizacao da Descricao do   ³±±
±±³           ³ 		 Plano de Fidelidade.							   	   ³±±
±±³           ³ cExp10 - Variavel que recebe a Descricao do Plano de Fidelida- ³±±
±±³			  ³			 de													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao  ³ TEMPLATES DROGARIAS / SIGALOJA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ Template de Drogarias                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DrogSetKey( cTecla  , oCodCli ,  cCodCli,  oLoja	  ,;
							  cLoja   , oNomeCli, cNomeCli, oPLFidel ,;
							  cPLFidel, oDescPLF, cDescPLF )

Local aRetCart  	:= Array(1) 						// Array passado como parametro para funcao padrao.
Local aCliente  	:= {}								// Array passado como parametro para funcao padrao.
Local cPLFidelAnt	:= cPlFidel							// Plano de Fidelidade Anterior. Eh usado para quando estou
														// Mudando o Plano de Fidelidade do Cliente.
Local nPosProd 		:= aScan(oGetDados1:aHeader, {|x| Upper(AllTrim(x[2])) == "LR_PRODUTO" }) // Posicao da Coluna do Codigo do Produto.
Local nX			:= 0								// Variavel usada para reiniciar o aCols.														
Local lCliente  	:= .T.								// Variavel Logica passada como parametro para funcao padrao.
Local lConect   	:= .T.								// Variavel Logica como parametro para funcao padrao.
Local lRet			:= .T.
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com os dados do Cliente para Atualizar os ³
//³Gets(campos) da tela de Cons.Precos.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aDadosCli     := {Space(TamSX3("MA6_NUM")[1]),;  // Numero do cartao
                  		Space(TamSX3("A1_CGC" )[1]),;  // CNPJ/CPF do cliente
                  		Space(TamSX3("A1_COD" )[1]),;  // Codigo do cliente
                  		Space(TamSX3("A1_LOJA")[1]),;  // Loja do cliente
                  		Space(TamSX3("A1_NOME")[1])}   // Nome do Cliente Fernando

Local lPlano        := .F. 								// Indica se um plano foi escolhido
Local aArea			:= {}
                  		
Do Case
	Case cTecla == "F5"  		// Aciona Cliente Padrao com Respectivo Plano de Fidelidade.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descarrego a Acao das Outras Teclas,             	     ³
		//³Caso o usuario tente pressionar as teclas simultaneamente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 SetKey(VK_F8 ,  Nil)
		 SetKey(VK_F10,  Nil)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializo a Tela com o Cliente Padrao posicionado.³
		//³                                                   ³
		//³Para isto chamo a Funcao T_DroAtuCos com o primeiro³
		//³parametro "BOTAOCLIP" (Mesmo parametro que a chama ³
		//³da atraves do Botao Cliente Padrao).               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		T_DroAtuCPOS("BOTAOCLIP", @oCodCli  , @cCodCli,  @oLoja 	,;
		    		 @cLoja  	, @oNomeCli , @cNomeCli, @oPLFidel 	,;
		    		 @cPLFidel	, @oDescPLF , @cDescPLF )

	Case cTecla == "F8"      // Escolha de Plano de Fidelidade do Mesmo Cliente.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descarrego a Acao das Outras Teclas,                 ³
		//³Caso o usuario pressione as 2 teclas simultaneamente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		 SetKey(VK_F5 ,  Nil)
		 SetKey(VK_F10,  Nil)
		 oNomeCli:Refresh()
		 If !Empty(cCodCli)
			 lPlano := T_DrogLoadPF( .T.     , @oPLFidel, @cPLFidel, @oDescPLF,;
			 			  		     @cDescPLF )
		 EndIf
		 If lPlano 
			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Verifica se o Cliente mudou o Plano de Fidelidade,³
			 //³efetuando o calculo do aCols, conforme Regra do   ³
			 //³Plano de Fidelidade.                              ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 If cPLFidel <> cPLFidelAnt
			 	If Len(oGetDados1:aCols)>=1 .AND. !Empty(oGetDados1:aHeader[oGetDados1:nAT][nPosProd])
				 	M->LQ_CPLFIDE := cPLFidel
				 	For nX := 1 to Len(oGetDados1:aCols)
				 		M->LR_PRODUTO := oGetDados1:aCols[nX][nPosProd]
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o Recalculo do aCols Funcao Principal: TDREA011()³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						T_TDROAtuAcols(nX, M->LR_PRODUTO ,M->LQ_CPLFIDE, "DroConsPrc") 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o Rodape Depois do Recalculo do aCols.			  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						T_DrocCalcTot("PLFIDEL", nX)
					 	oGetDados1:oBrowse:Refresh()
					Next  	
				EndIf 	
			 EndIf
		 Endif
		 oGetDados1:Obrowse:nColPos := 2 	// Posiciona o Cursor no Campo Produto da NewGetDados

	Case cTecla == "F10"				    // Aciona a escolha de um novo Cliente
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Descarrego a Acao das Outras Teclas,                 ³
		//³Caso o usuario pressione as 2 teclas simultaneamente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		SetKey(VK_F8,  Nil)
		SetKey(VK_F5,  Nil)
		
		/****************************************************
			Chama a Rotina de Identificacao do cliente		  
			(RETAGUARDA) atraves do numero do cartao ou CNPJ/CPF									    
		*****************************************************/	
		CrdIdentCli(aRetCart, @aDadosCli, @lCliente, .T. ,;
				     		aCliente,,lConect ) 
		
		/*Alimenta os Campos com o Conteudo do Array aDadosCli.
		Soh Atualiza os valores em tela, caso o usuario nao  
		cancele a chamada da funcao.			*/		
		If !lCliente .And. !Empty(aDadosCli[3]) .AND. !Empty(aDadosCli[4]) .AND. !Empty(aDadosCli[5]) 
			cCodCli  := aDadosCli[3]
			cLoja	 := aDadosCli[4]
			cNomeCli := aDadosCli[5]
		Else			
			/* A tela posiciona o registro da SA1 conforme selecionado*/
			aArea := SA1->(GetArea())
			If T_TELACART()
				cCodCli	:= SA1->A1_COD
				cLoja	:= SA1->A1_LOJA
				cNomeCli:= SA1->A1_NOME
			Else
				lRet := .F.
			EndIf
			RestArea(aArea)
		EndIf
		
		/*Carrega a Tela de Escolha de Plano de 
		Fidelidade caso o Cliente seja Selecionado.*/		
		If lRet .And. !Empty(cCodCli)
			lPlano := T_DrogLoadPF( .T., oPLFidel, @cPLFidel, oDescPLF,;
						 		    @cDescPLF )
		EndIf
		
		If lPlano
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os Campos da Tela(Cabecalho)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oCodcli:Refresh()
			oNomeCli:Refresh()
			oLoja:Refresh()
			oPLFidel:Refresh()
			oDescPLF:Refresh()
			ProcessMessage()
			oGetDados1:Obrowse:nColPos := 2 	// Posiciona o Cursor no Campo Produto da NewGetDados
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Como estou em um Novo Cliente, Reinicio os Valores do aCols³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			oGetDados1:aCols:={}
			aAdd(oGetDados1:aCols,Array(Len(oGetDados1:aHeader)+1))
			For nX := 1 To Len(oGetDados1:aHeader)
				If Alltrim(oGetDados1:aHeader[nX, 2]) == "LR_ITEM"
					oGetDados1:aCols[1, nX] := "01"
				Else
					oGetDados1:aCols[1, nX] := CriaVar(oGetDados1:aHeader[nX, 2])
				EndIf
			Next nX
			oGetDados1:aCols[Len(oGetDados1:aCols), Len(oGetDados1:aHeader)+1] := .F.
			oGetDados1:oBrowse:Refresh()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Refresh nos Totalizadores que aparecerao na Tela.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTotProd 	:= AllTrim( TRANSFORM(0, "@E 999,999,999.99") )
			cTotPrDesc 	:= AllTrim( TRANSFORM(0, "@E 999,999,999.99") )
			cTotDesc 	:= AllTrim( TRANSFORM(0, "@E 999,999,999.99") ) 
			cPerMDesc	:= AllTrim( TRANSFORM(0, "@E 999,999,999.99") )
			oSayProd:Refresh()
			oTotPrDesc:Refresh()
			oTotPrDesc:Refresh()
			oTotDesc:Refresh()
			oPerMDesc:Refresh()		
		
		Endif        

EndCase

//Restaurando as Acoes Das Teclas.
T_DrocGetKey(@oCodCli  , @cCodCli , @oLoja   , @cLoja   ,;
		     @oNomeCli , @cNomeCli, @oPLFidel, @cPLFidel,;
		     @oDescPLF , @cDescPLF)

If lPlano
	M->LQ_CPLFIDE := cPLFidel 			// Atualizo o Cod. Plano de Fidelidade.
Endif

oGetDados1:Obrowse:nColPos := 2 	// Posiciona o Cursor no Campo Produto da NewGetDados

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³DrogSetKey³ Autor ³ Fernando Fonseca      ³ Data ³22/03/2007		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ IP		|Contato³ fernando.santos@microsiga.com.br  		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega a Tela do Plano de Fidelida apos selecionado o Cliente.   ³±±
±±³			 ³Isto so ocorre se o cliente for acionado primeiro.				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp1 - Booleano responsavel para mostrar ou nao a Tela de Plano ³±±
±±³          ³         de Fidelidade.                                           ³±±
±±³          ³ oExp2 - Objeto responsavel pela atualizacao do Codigo do  	    ³±±
±±³          ³ 		   Plano de Fidelidade.							   	        ³±±
±±³          ³ cExp3 - Variavel que recebe o Codigo do Plano de Fidelidade      ³±±
±±³          ³ oExp4 - Objeto responsavel pela atualizacao da Descricao do      ³±±
±±³          ³ 		   Plano de Fidelidade.							   	        ³±±
±±³          ³ cExp5 - Variavel que recebe a Descricao do Plano de Fidelida-    ³±±
±±³			 ³			de													    ³±±
±±³Aplicacao ³ TEMPLATES DROGARIAS / SIGALOJA                              		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Template de Drogarias                                       		³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                           
Template Function DrogLoadPF( lMostraTela, oPLFidel, cPLFidel, oDescPLF,;
							  cDescPLF )
Local lRet := .F.

cPLFidel 	:= If(lMostraTela, T_TDREA009(), Posicione("MHG",1,xFilial("MHG")+cPLFidel,"MHG_CODIGO"))
cDescPLF   	:= Posicione("MHG", 1, xFilial("MHG")+cPLFidel, "MHG_NOME")

If !Empty(AllTrim(cPLFidel))
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³ConsPrcProd Autor ³ Fernando Fonseca      ³ Data ³28/03/2007		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ IP		|Contato³ fernando.santos@microsiga.com.br  		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gatilho que Carrega um Valor para o Produto na Consulta de Precos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³ TEMPLATES DROGARIAS / SIGALOJA                              		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Template de Drogarias                                       		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamada   ³ TDREA011()			                                       		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Analista  ³ Data   ³Bops  ³Manutencao Efetuada                      	   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Thiago H. ³18.05.07³126391³Validacao quando eh digitado o codigo de barras   |±±
±±|          ³        ³      ³funcao LJSB1SLK() 								|±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                        
Template Function ConsPrProd( oGetDados )
Local nPosCodProd := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "LR_PRODUTO" })
Local nPosDesPro  := aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "LR_DESCRI"	})
Local nPosQuant	  := aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "LR_QUANT"	})
Local nPosVlrItem := aScan(aHeader, {|x| Upper(Alltrim(x[2])) == "LR_VLRITEM"	})

If nModulo == FRONTLOJA	
	If LJSB1SLK(@M->LR_PRODUTO,,.T.)	
		SBI->(DbSetOrder(1))
		If SBI->(DbSeek(xFilial("SBI")+M->LR_PRODUTO)) 
			aCols[n][nPosCodProd] 	:= M->LR_PRODUTO
			M->LR_DESCRI 			:= SBI->BI_DESC
			aCols[n][nPosDesPro]	:= M->LR_DESCRI
			aCols[n][nPosQuant] 	:= 01 
		EndIf                      
	Endif	
	/*Atualizando o Conteudo do aCols*/
	oGetDados 		 := If(oGetDados == Nil, oGetDados1, oGetDados)
	oGetDados:aCols  := aClone(aCols)
	oGetDados:oBrowse:Refresh()
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LjTimerFrt³ Autor ³ Vendas Clientes		³ Data ³ 10.03.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ativa o Timer da integracao com a retaguarda				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LjTimerFrt												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjTimerFrt()

IpcGo(WAITID)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DroValid  ³ Autor ³ Vendas Clientes		³ Data ³ 10.03.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desativa o Timer da integracao com a retaguarda			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ DroValid 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DroValid(oTimerFrt)

oTimerFrt:DeActivate()
lPrecMult := .F.

If nModulo == SIGALOJA 
	Lj7SetKeys(.T.) 
	oGetDados := Nil  
EndIf

Return .T.     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DroSendPCM³ Autor ³ Vendas Clientes		³ Data ³ 04/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica se a Consulta Preco multimidia esta ativa			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ DroSendPCM 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DroSendPCM()  
Local lSendPCM := lPrecMult   

Return lSendPCM

//---------------------------------------------
/*/{Protheus.doc} TPLDr7Prod
Usada para valida o produto do template na tela de
 Consulta de Produtos do FrontLoja
-- Valid dos campos SLR

@owner  	Varejo
@author  	julio.nery
@version 	V12
@since   	31/01/2019 
/*/
//---------------------------------------------
Template Function TPLDr7Prod(cCampo)
Local lRet		:= .T.
Local nTamProd	:= 0
Local nPosDescr	:= 0 
Local cDescricao:= ""

If cCampo == "LR_PRODUTO"
	cProd := AllTrim(M->LR_PRODUTO)
	If !Empty(cProd)
		nTamProd	:= TamSX3("LR_PRODUTO")[1]
		nPosDescr	:= aScan(oGetDados1:aHeader,{|x| Trim(x[2]) == "LR_DESCRI"})
		cDescricao	:= POSICIONE("SBI",1,XFILIAL("SBI")+PadR(cProd,nTamProd),"BI_DESC")
		
		If Empty(AllTrim(cDescricao))
			T_ConsPrProd( oGetDados1 )
		Else		
			M->LR_DESCRI := cDescricao
		EndIf
		  		
		oGetDados1:aCols[oGetDados1:nAT,nPosDescr] := M->LR_DESCRI
		oGetDados1:oBrowse:Refresh()
	EndIf
EndIf

If cCampo == "LR_QUANT"
	If M->LR_QUANT < 0
		M->LR_QUANT := 1
		Alert("Quantidade não pode ser menos que zero")
	EndIf
EndIf

Return lRet