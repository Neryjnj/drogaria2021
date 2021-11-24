#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH" 
#INCLUDE "LOJA720.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE TEF_CLISITEF	"6"		//Utiliza a DLL CLISITEF

/* Fonte FinxSe5 */
#DEFINE MOVIMENTO_BCO 			1
#DEFINE BAIXAS_PAGAR 			2
#DEFINE BAIXAS_RECEBER			3
#DEFINE ATUALIZA_CHEQUE			4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Posicao do array aDevol   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _DESCMOEDA	1	// Descricao da moeda
#DEFINE _SALDO		2	// Saldo a devolver
#DEFINE _VALORDEV	3	// Valor efetivamente devolvido
#DEFINE _SOMADEV	4	// Somatorio da devolucao convertido
#DEFINE _VLRORIG	5	// Valor original da devolucao(backup)
#DEFINE _MOEDA		6	// Moeda
#DEFINE CTRL Chr(10)           	//Pula linha

Static lTroca			// Controla se a operacao eh de troca ou devolucao
Static lConfirma		// Controla se usuario confirmou a operacao
Static oGetdDEV			// Objeto da MsGetDb do panel da devolucao
Static oGetdTRC		   	// Objeto da MsGetDb do panel da troca
Static aRecnoSD2		:= {}	// Array utilizado para enviar o registro do SD2 as funcoes do SIGACUSA.PRX
Static nTamRecTrb 		:= 11	// Tamanho do campo RecNo do TRB
Static oVlrTotal
Static nVlrTotal		:= 0														// Valor total de produtos a serem trocados ou devolvidos
Static aRecValTroca     := {}
Static aRecSD2       	:= {}   // Contem a Quantidade e o Recno dos produtos na tabela SD2 que estao marcados para carregar na NewGetDados
Static lQtDeDev			:= Nil  // Libera quantidade da garantia estendida  .. por default é Falso
Static oTempTable		:= Nil	//Objeto tabela temporaria 
Static cCdFl			:= "" //Codigo da filial
Static cCdCli			:= "" //Codigo do cliente
Static cCdLj			:= "" //Codigo da loja
Static lLGPD 			:= Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LOJA720   ³ Autor ³ Vendas Cliente        ³ Data ³ 16.08.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para realizacao de troca e devolucao de mercadorias. ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LOJA720(ExpC1, ExpC2, EXpL3, EXpA4, ExpN5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Codigo do Cliente                                    ³±±
±±³          ³ ExpC2: Loja do Cliente                                      ³±±
±±³          ³ EXpL3: Indica se a rotina foi executada pela Venda Assistida³±±
±±³          ³ EXpA4: Armazena a serie, numero e cliente+loja da NF de     ³±±
±±³          ³ 		  devolucao e o tipo de operacao(1=troca;2=devolucao)  ³±± 
±±³          ³ ExpN5: Opcao selecionada                                    ³±±
±±³          ³ ExpN6: Se a chamada da rotina for da tela de pagamentos da  ³±±
±±³          ³        venda assistida nao podera ser acessada.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJA720( cCodCli, cLojaCli, lVdAssist, aDocDev, nOpc,;
 				lPanelPgto, cCodFil, lAutomato, aCabAuto, aItAuto)  			

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis locais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea			:= GetArea()  												// Salva a area atual
Local lRet			:= .T.														// Retorno da Funcao
Local cNomeCli		:= CriaVar("A1_NOME",.F.)									// Nome do Cliente
Local cNumDoc       := CriaVar("F1_DOC",.F.)									// Numero do documento quando nao eh formulario proprio para documento de entrada
Local cSerieDoc		:= CriaVar("F1_SERIE",.F.)                                	// Serie  do documento quando nao eh formulario proprio para documento de entrada
Local cNumCaixa 	:= xNumCaixa()												// Codigo do usuario ativo quando caixa
Local dDataIni		:= dDataBase										        // Data Inicial para filtrar as Notas de saida do cliente
Local dDataFim		:= dDataBase										        // Data Final para filtrar as Notas de saida do cliente
Local cAliasTRB		:= "TRB" 													// Alias do arquivo temporario
Local nTpProc		:= 1      													// Opcao selecionada. 1-Troca ou 2-Devolucao
Local nNfOrig		:= 1  														// Opcao selecionada. 1-Com NF de origem ou 2-Sem NF de origem
Local nPosProd		:= 0														// Posicao do campo Produto no aHeader
Local nPosTES		:= 0                                                     	// Posicao do campo TES no aHeader
Local aHeaderSD2	:= {}          												// aHeader obrigatorio para o objeto MsGetDB
Local aStruTRB		:= {}        												// Campos da estrutura do arquivo temporario
Local lFormul 		:= .T.														// Indica se utilizara formulario proprio para a Nota Fiscal de Entrada.                             
Local lCompCR		:= SuperGetMv( "MV_LJCMPCR", NIL, .T. )						// Indica se ira compensar o valor da NCC gerada com o titulo da nota fiscal original
Local cCad	  		:= If( Type("cCadastro") 	== "U",Nil,cCadastro) 			// Salva o cCadastro atual
Local aRots   		:= If( Type("aRotina")   	== "U",Nil,aClone(aRotina))    	// Salva o aRotinas atual	
Local aSavHead  	:= If( Type("aHeader") 		== "U",Nil,aClone(aHeader))    	// Salva o aHeader se existir
Local nBkpLin   	:= If( Type("n") 		    == "U",Nil,n)				   	// Salva o n se existir
Local nRecnoTRB                                                                	// Recno da area de trabalho
Local nFormaDev     := 1 														// Define a forma de devolucao ao cliente: 1-Dinheiro;2-NCC
Local cMV_DEVNCC    := AllTrim(SuperGetMV("MV_DEVNCC"))                        	// Define a forma de devolucao default: "1"-Dinheiro;"2"-NCC
Local cMV_LJCHGDV   := AllTrim(SuperGetMV("MV_LJCHGDV",,"1"))                  	// Define se permite ou nao modificar a forma de devolucao ao cliente("0"-nao permite;"1"-permite)
Local cMV_LJCMPNC   := AllTrim(SuperGetMV("MV_LJCMPNC",,"1"))                  	// Define se permite ou nao modificar a opcao para compensar a NCC com o titulo da NF original("0"-nao permite;"1"-permite)
Local lDevMoeda		:= .F.														// Se devolve em outra moeda
Local nTxMoedaTr 	:= 0														// Taxa da moeda
Local nMoedaCorT	:= 1														// Moeda corrente
Local aMoeda		:= {}														// Moedas validas
Local cMoeda		:= ""														// Armazena moeda na digitacao
Local nX            := 0														// Contador de For
Local nY            := 0														// Contador de For
Local nPosLote		:= 0 														// Posicao do Campo Lote no aHeader no Panel3
Local lMv_Rastro	:= (SuperGetMv( "MV_RASTRO", Nil, "N" ) == "S")			// Flag de verificacao do rastro
Local aTamNF        := {} 														// Tamanho do campo de nota fiscal.
Local aTamCupom     := {}														// Tamanho do campo de cupom.
Local cCodDia       := ""                                        // Codigo do Diario
Local cDescrDia     := ""                                        // Descricao do Diario
Local lAliasCVL     := AliasInDic( "CVL" )                       // Verifica existencia da tabela

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao dos Objetos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oWizard	   																// Objeto principal do Wizard
Local oTpProc					   												// Tipo do Processo de Troca. Troca ou Devolucao
Local oNfOrig	   				   												// Indica se possui uma nota fiscal de origem 
Local oCodCli 					   												// Codigo do Cliente
Local oLojaCli																	// Loja do Cliente
Local oNomeCli		   															// Nome do cliente
Local oDataIni																	// Data Inicial para filtro das Notas Fiscais de Saida
Local oDataFim        											             	// Data Final para filtro das Notas Fiscais de Saida
Local oNumDoc		                                                    		// Numero do documento quando nao eh formulario proprio para documento de entrada
Local oSerieDoc                                                                	// Serie do documento quando nao eh formulario proprio para documento de entrada
Local oFormaDev																	// Objeto do Radio para forma de devolucao 
Local oCompCR    																// Indica se ira compensar o valor da NCC gerada com o titulo da nota fiscal original
Local oDevMoeda																	// Se devolve em outra moeda
Local oMoeda																	// Moeda
Local oTxMoeda																	// Taxa da moeda
Local oCodDia                                                 					// Codigo do Diario (PTG)
Local oDescrDia                                               					// Descricao do Diario (PTG)
Local oLblValTroca  := Nil
Local oValTroca     := Nil
Local cValTroca     := Space(35)
Local lMotDev		:= .F.														// Motivo de Devolucao - usado para Localizado
Local oMotivo 	
Local cMotivo		:= ""                           
Local oDescMot 	
Local cDescMot  	:= Space(40) 
Local nImpostos		:= 0                                                        // Total de impostos
Local oChvNFE																	// Objeto do campo "Chave da NFE" do documento quando nao eh formulario proprio para documento de entrada
Local M->F1_CHVNFE	:= "" 						                               	// Chave da NFE do documento quando nao eh formulario proprio para documento de entrada
Local oTpEspecie																// objeto Get que armazena a especie da nota fiscal de entrada
Local cTpEspecie	:= CriaVar("F1_ESPECIE",.F.)								// armazena a Especie da nota fiscal de entrada
Local oCodFil
Local oSayFil																	// Objeto para o nome Filial
Local oDescrFil
Local cDescrFil		:= ""														// Descricao da Filial
Local nFiltroPor	:= 1  														// Opcao selecionada no filtro da busca da venda
Local oSayClient
Local oSayDtIni
Local oSayDtFim
Local oSayNumNF
Local oSaySerie
Local oCodNumNF
Local oSerieNF
Local cNumNF 		:= Space(TamSx3("F2_DOC")[1])
Local cSerieNF		:= Space(TamSx3("F2_SERIE")[1])
Local oBotaoPesq
Local cConPadCli 	:= "SA1"
Local aControls 	:= {} //Array com os objetos de controle da tela que permitem algumas configuracoes atraves do Ponto e Entrada "LJ720CTRL"
Local lLJ720CTRL 	:= ExistBlock("LJ720CTRL")
Local lDevFrete 	:= .F.														// Indica se devolve o valor de frete ou nao 
Local lAltModo		:= .T.														// Se pode alterar o modo
Local lLegMotDev	:= .F.														// verifica se a devolução se enquadra na legislação do amazonas ( LjAnalisaLeg(73) )
Local lAltFilial	:= (SuperGetMV("MV_LJDEVFI",,"0") == "0")					// Bloqueia o campo Filial dos dados da venda. 0=Desbloqueado, 1=Bloqueado

Default	cCodCli 	:= CriaVar("A1_COD",.F.)									// Codigo do Cliente
Default cLojaCli    := CriaVar("A1_LOJA",.F.) 									// Loja do Cliente
Default	lVdAssist	:= .F.														// Indica se a rotina foi executada pela venda assistida
Default aDocDev     := {}                                                       // Armazena a serie, numero e cliente+loja da NF de devolucao e o tipo de operacao(1=troca;2=devolucao)
Default nOpc        := 3                                                        // Opcao do aRotina
Default lPanelPgto	:= .F.														// Verifica se a rotina esta sendo chamada da tela de pagamento da venda assistida
Default cCodFil 	:= cFilAnt													// Codigo da Filial
Default lAutomato 	:= .F.														// Determina se a execução do programa é via robô de testes automatizados
Default aCabAuto	:= {}														// Array de parametros para execução automatizada
Default aItAuto	:= {}
LjGrvLog( "TROCA_DEVOLUCAO", "ID_INICIO")

lLGPD := Iif(ExistFunc("LjPDUse"),LjPDUse(),.F.) //Verifica se a funcionalidade de Dados Protegidos está sendo utilizada no sistema.

aRecValTroca := {} // Limpa variavel static ao iniciar a rotina.

//Array com os objetos de controle da tela que permitem algumas configuracoes atraves do Ponto e Entrada "LJ720CTRL"
//                  Nome do objeto          , Valor padrao  , Permite Editar (.T.=Sim, .F.=Nao)
aAdd( aControls, { "RadioButton " + STR0004	, nTpProc		, .T. 	} ) //01 - RadioButton "Processo"
aAdd( aControls, { "RadioButton " + STR0005	, nNfOrig		, !LjAnalisaLeg(86)[1] 	} ) //02 - RadioButton "Origem" //desabilita para estado(s) que obrigam NF referenciada
aAdd( aControls, { "RadioButton " + STR0138	, nFiltroPor	, .T. 	} ) //03 - RadioButton "Buscar venda por"
aAdd( aControls, { STR0155					, cConPadCli	, .T. 	} ) //04 - Consulta Padrao Cliente
aAdd( aControls, { "CheckBox " + STR0178	, lDevFrete	, .T. 	} ) //05 - CheckBox "Devolve o valor de Frete/Seguro/Despesa"

LjGrvLog( "TROCA_DEVOLUCAO", "Forma de devolucao padrao MV_DEVNCC", cMV_DEVNCC)
LjGrvLog( "TROCA_DEVOLUCAO", "Permite ou nao modificar a forma de devolucao ao cliente MV_LJCHGDV", cMV_LJCHGDV)
LjGrvLog( "TROCA_DEVOLUCAO", "Permite ou nao modificar a opcao para compensar a NCC MV_LJCMPNC", cMV_LJCMPNC)
LjGrvLog( "TROCA_DEVOLUCAO", "Flag de verificacao rastreabilidade dos lotes MV_RASTRO", lMv_Rastro)
LjGrvLog( "TROCA_DEVOLUCAO", "Ponto de Entrada LJ720CTRL", lLJ720CTRL)

If lLJ720CTRL
	LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:LJ720CTRL",aControls)
	aControls := ExecBlock("LJ720CTRL",.F.,.F.,aControls)
	LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:LJ720CTRL",aControls)
	nTpProc 	:= aControls[1][2]
	nNfOrig		:= aControls[2][2]
	If nNfOrig == 2
		nFiltroPor := 1
	Else
		nFiltroPor	:= aControls[3][2]
	EndIf
	cConPadCli	:= aControls[4][2]
	lDevFrete 	:= aControls[5][2]
EndIf

oVlrTotal := Nil
nVlrTotal := 0 // Valor total de produtos a serem trocados ou devolvidos

// habilita na tela o MSGet para que seja informado o motivo de devolução
If SF1->(ColumnPos("F1_MOTIVO")) > 0	
	lMotDev	:= .T.
	cMotivo	:= CriaVar("F1_MOTIVO",.F.)
EndIf

If cPaisLoc == "PTG"
   If lAliasCVL
	   cCodDia       := CriaVar("CVL_COD",.F.)                    // Codigo do Diario
	   cDescrDia     := CriaVar("CVL_DESCR",.F.)                  // Descricao do Diario
   EndIf
EndIf

If AliasInDic( "SLX" )
	aTamCupom  := TamSx3("LX_CUPOM")
	aTamNF     := TamSx3("D1_DOC")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o campo LX_CUPOM esta com o tamanho correto.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aTamCupom[1] <> aTamNF[1] .OR. aTamCupom[2] <> aTamNF[2]
		//"Corrigir o tamanho do campo LX_CUPOM para "
		MsgStop(STR0114 + "[" + AllTrim(STR(aTamNF[1])) + "," + AllTrim(STR(aTamNF[2])) + "]")
		lRet := .F.
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao habilitar a rotina quando for Visualizacao(nOpc=2).       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2 .AND. lRet  
   //"Nao e possivel acessar a rotina de troca/devolucao no modo Visualizacao."
   MsgStop(STR0074)   
   lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao habilitar a rotina quando o usuario estiver na tela de pagamento na Venda Assistida	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPanelPgto .AND. lRet  
   //"Nao e possivel acessar a rotina de troca/devolucao na tela de pagamento."
   MsgStop(STR0080)   
   lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com as moedas ativs para o Combo.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA" .AND. lRet  
	For nX := 1	To MoedFin()
		If(!(Empty(SuperGetMv("MV_MOEDA"+Ltrim(STR(nX))))))
			LjCriaSimb(nX)
			AAdd(aMoeda,SuperGetMv("MV_MOEDA"+Ltrim(STR(nX))))
		Else
			Exit
		Endif
	Next nX
EndIf

If AllTrim( FunName() ) == "LOJA701"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desabilita SetKeys da Venda Assistida						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A rotina nao podera ser executada caso o usuario nao esteja cadastrado como um caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet 
	If!IsCaixaLoja( cNumCaixa ) //se não é Caixa, pode realizar apenas devolucãões
		LjGrvLog( "TROCA_DEVOLUCAO", "Não é caixa, pode realizar apenas devoluções", cNumCaixa)
		cMV_LJCHGDV := "0"		
		cMV_DEVNCC	:= "2"
		nTpProc		:= 2
		lAltModo	:= .F.
	EndIf	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha troca pendente  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. Len(aDocDev) > 0
   If aDocDev[5] == 1  //Troca
      //"Atenção", "Há uma operação de troca pendente. Saia da rotina de venda para estornar a transação ou finalize a venda para conclui-la.", "Ok"
      Aviso(STR0033,STR0054,{STR0036})
      lRet  := .F.
   Else
      aDocDev  := {}
   Endif   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 31 verificara a permissao do usuario p/ efetuar ³
//³ ou nao uma Troca.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. ChkPsw( 31 )
	
	If !lVdAssist
		cCodCli	:= PadR(SuperGetMV("MV_CLIPAD",,""),Len(CriaVar("A1_COD",.F.)),'') 	// Cliente padrao
		cLojaCli:= PadR(SuperGetMV("MV_LOJAPAD"),Len(CriaVar("A1_LOJA",.F.)),'')		// Loja do cliente padrao
	EndIf
	
	LjGrvLog( "TROCA_DEVOLUCAO", "Cliente padrao MV_CLIPAD", SuperGetMV("MV_CLIPAD",,""))
	LjGrvLog( "TROCA_DEVOLUCAO", "Loja do cliente padrao MV_LOJAPAD", SuperGetMV("MV_LOJAPAD"))

	If !Empty(cCodCli) .AND. !Empty(cLojaCli)
		cNomeCli:= Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojaCli,"A1_NOME") 
		LjGrvLog( "TROCA_DEVOLUCAO", "Nome do CLiente caso MV_CLIPAD e MV_LOJAPAD esteja em branco - cNomeCli", cNomeCli)
	Endif
		
	Private	aRotina		:= MenuDef()  			        // Array de opcoes
	Private cCadastro	:= ""  				           // Cabecalho da tela
	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a estrutura e o arquivo temporario para a GetDados dos produtos exibida no panel 3.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj720GetStru(@aHeaderSD2,	@aStruTRB,	cAliasTRB)
	
	nPosProd  :=Ascan(aHeaderSD2, {|x| AllTrim( x[2] ) == "TRB_CODPRO"})
	nPosTES	  :=Ascan(aHeaderSD2, {|x| AllTrim( x[2] ) == "TRB_TES"}) 
	
	If lMv_Rastro
		nPosLote  := aScan(aHeaderSD2, {|x| AllTrim( x[2] ) == "TRB_LOTECT"})
	Endif	
	
	aDocDev   := {}  //Inicializar o array caso faca duas ou mais operacoes 
	lTroca    := nTpProc == 1
	lConfirma := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o parametro MV_DEVNCC estiver preenchido com "1" ou "2", assume o valor como default  ³
	//³ para a forma de devolucao																 ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If cMV_DEVNCC $ "12"
	    nFormaDev  := VAL(cMV_DEVNCC)
	Endif
	
	Private aHeader := aHeaderSD2                        // Cabecalho do grid de itens devolvidos
		
	If lAutomato//Se for execução via robô de testes não exibe wizard e carrega as variáveis através do Array recebido por parâmetro
			
		//Parametros
		nTpProc    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="nTpProc"})][2]//Tipo do processo de troca.                          
		nNfOrig    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="nNfOrig"})][2]//Origem do documento de entrada                     
		cCodCli    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cCodCli"})][2]//Codigo do cliente                                   
		cLojaCli   := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cLojaCli"})][2]//Codigo da loja                                      
		aRecSD2    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="aRecSD2"})][2]//Array com os Recnos da tabela SD2                   
		lFormul    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="lFormul"})][2]//Indica se eh formulario proprio ou nao              
		cNumDoc    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cNumDoc"})][2]//Numero do documento de entrada                      
		cSerieDoc  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cSerieDoc"})][2]//Serie do documento de entrada                       
		lCompCR    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="lCompCR"})][2]//Indica se ira compensar a NCC com o titulo da NF.   
		lVdAssist  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="lVdAssist"})][2]//Se a rotina foi executada pela venda assistida.     
		aDocDev    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="aDocDev"})][2]//Armazena a serie, numero e cliente+loja da NF de devolucao e o tipo de operacao(1=troca;2=devolucao)  
		nFormaDev  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="nFormaDev"})][2]//Forma de devolucao ao cliente: 1-Dinheiro;2-NCC     
		If aScan(aCabAuto,{|x|AllTrim(x[1])=="nVlrTotal"}) > 0
			nVlrTotal  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="nVlrTotal"})][2]//Valor total de produtos a serem trocados ou devolvidos    								      
		Endif
		lDevMoeda  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="lDevMoeda"})][2]//Devolve em varias moedas.                           
		nImpostos  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="nImpostos"})][2]//Moeda corrente                                      
		cChvNFE    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cChvNFE"})][2]//Taxa da moeda corrente                              
		cTpEspecie := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cTpEspecie"})][2] 
		cCodFil    := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cCodFil"})][2] 
		lDevFrete  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="lDevFrete"})][2]
		cMensagem  := aCabAuto[aScan(aCabAuto,{|x|AllTrim(x[1])=="cMensagem"})][2]
		
		//Atualiza a temporária de itens com os itens enviados pelo robô
		For nY := 1 to len(aItAuto)
			RecLock(cAliasTRB,.T.)
				TRB->TRB_ITEM := aItAuto[nY][aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_ITEM"})][2]
				TRB->TRB_CODPRO := aItAuto[nY][aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_CODPRO"})][2]
				TRB->TRB_QUANT := aItAuto[nY][aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_QUANT"})][2]
				TRB->TRB_PRCVEN := aItAuto[nY][aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_PRCVEN"})][2]
				If aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_VLRTOT"}) > 0
					TRB->TRB_VLRTOT := aItAuto[nY][aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_VLRTOT"})][2]
				Else
					TRB->TRB_VLRTOT := TRB->TRB_QUANT * TRB->TRB_PRCVEN
				Endif	
				TRB->TRB_UM := aItAuto[nY][aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_UM"})][2]
				TRB->TRB_TES := aItAuto[nY][aScan(aItAuto[nY],{|x|AllTrim(x[1])=="TRB_TES"})][2]
			TRB->(MsUnlock())
			If aScan(aCabAuto,{|x|AllTrim(x[1])=="nVlrTotal"}) = 0
				nVlrTotal += TRB->TRB_VLRTOT
			Endif	
		Next nY
		
		If len(aItAuto) > 0
			nRecnoTRB := 1
			Lj720GetOk( cAliasTRB, @aRecSD2, @nVlrTotal, nRecnoTRB, nNfOrig, cCodFil )
		Endif
		
		Lj720Concluir(	nTpProc		, nNfOrig	, cCodCli  		, cLojaCli	,;
						aRecSD2		, lFormul	, cNumDoc  		, cSerieDoc	,;
						lCompCR		, lVdAssist	, aDocDev   	, nFormaDev	,;
						nVlrTotal	, lDevMoeda	, nMoedaCorT	, nTxMoedaTr,;
						cCodDia		, cMotivo 	, nImpostos  	, cChvNFE	,;
						cTpEspecie 	, cCodFil 	, lDevFrete 	, cMensagem, lAutomato)
				
	Else	
			
		//ÚÄÄÄÄÄÄÄ¿
		//³Panel 1³
		//ÀÄÄÄÄÄÄÄÙ
		DEFINE WIZARD oWizard SIZE 0,0,597,800 TITLE STR0001 HEADER STR0002 ;	//"Troca e Devolução de Mercadorias" ## "Definição do Processo"
				MESSAGE STR0003; 										//"Informe os dados para o processo de troca ou devolução"
				TEXT " "; 
				NEXT {|| 	L720NextPn( oWizard:nPanel 	, nNfOrig  		, cCodCli 		, cLojaCli  ,;
										@oWizard       	, nTpProc  		, Nil			, Nil		,;
										cCodFil			, nFiltroPor 	, aRecSD2 		, lDevFrete ) .AND. ;
							Lj720GetOk( cAliasTRB, @aRecSD2, @nVlrTotal, nRecnoTRB, nNfOrig, cCodFil ).AND. LJ720LinOK(aRecSD2) } ;
				FINISH {||  .T. } NOFIRSTPANEL	PANEL
				
				oWizard:GetPanel(1)
				
				//--------------------------
				// Label "Processo"
				//--------------------------
				@ 005,010 TO 050,120 LABEL STR0004 OF oWizard:GetPanel(1) COLOR CLR_HBLUE PIXEL //"Processo"
				@ 020,015 RADIO oTpProc VAR nTpProc ITEMS STR0006,STR0007 SIZE 50,10 PIXEL OF oWizard:GetPanel(1) ;
						WHEN ( lAltModo .AND. aControls[1][3]);
						ON CHANGE ( L720ChgPrc( cAliasTRB	, @aRecSD2	, oGetdTRC  , @lFormul  , ;
												@lCompCR   	, @nRecnoTRB, nTpProc	, nNfOrig	, ;
												oWizard:nPanel ) ) //"Troca", "Devolução"
				
				//--------------------------
				// Label "Origem"
				//--------------------------
				@ 005,145 TO 050,255 LABEL STR0005 OF oWizard:GetPanel(1) COLOR CLR_HBLUE PIXEL //"Origem"
				@ 020,150 RADIO oNfOrig VAR nNfOrig ITEMS STR0008,STR0009 SIZE 80,10 PIXEL OF oWizard:GetPanel(1) ;
						WHEN (aControls[2][3]);
						ON CHANGE ( L720ChgOri( nNfOrig  	, @oDataIni		, @oDataFim		, @dDataIni  	,;
												@dDataFim	, @oCodFil   	, @cCodFil  	, @oDescrFil 	,;
												@cDescrFil	, @oFiltroPor	, @oBotaoPesq	, cAliasTRB  	,;
												@aRecSD2  	, oGetdTRC  	, @lFormul		, @lCompCR   	,;
												@nRecnoTRB	, nTpProc 		, oWizard:nPanel, @nFiltroPor 	,;
												@oSayClient	, @oCodCli		, @oLojaCli		, @oNomeCli		,;
												@oSayDtIni	, @oSayDtFim	, @oSayNumNF 	, @oCodNumNF	,;
												@oSaySerie	, @oSerieNF		, oLblValTroca  , oValTroca		,;
												@oSayFil) )//"Com Documento de Entrada" , "Sem Documento de Entrada"
				
				//--------------------------
				// Label "Buscar venda por"
				//--------------------------
				@ 005,280 TO 050,390 LABEL STR0138 OF oWizard:GetPanel(1) COLOR CLR_HBLUE PIXEL //"Buscar venda por"
				
				If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12, tera a opcao de vale-troca.
					@ 020,285 RADIO oFiltroPor VAR nFiltroPor ITEMS STR0139,STR0140,STR0158 SIZE 80,10 PIXEL OF oWizard:GetPanel(1) ; //"Cliente e Data","No. Cupom / Nota","Vale-Troca"
							WHEN (nNfOrig==1 .And. aControls[3][3]);
							ON CHANGE ( L720ChgFil( nFiltroPor	, @oSayClient	, @oCodCli		, @oLojaCli		,;
													@oNomeCli	, @oSayDtIni	, @oDataIni		, @oSayDtFim	,;
													@oDataFim	, @oSayNumNF	, @oCodNumNF	, @oSaySerie	,;
													@oSerieNF 	, cAliasTRB		, @aRecSD2		, oGetdTRC		,;
													@lFormul	, @lCompCR		, @nRecnoTRB	, nTpProc 		,;
													nNfOrig		, oWizard:nPanel, oLblValTroca  , oValTroca		,;
													@oSayFil	, @oCodFil 		, @oDescrFil) ) 
				Else
					@ 020,285 RADIO oFiltroPor VAR nFiltroPor ITEMS STR0139,STR0140 SIZE 80,10 PIXEL OF oWizard:GetPanel(1) ; //"Cliente e Data","No. Cupom / Nota"
							WHEN (nNfOrig==1 .And. aControls[3][3]);
							ON CHANGE ( L720ChgFil( nFiltroPor	, @oSayClient	, @oCodCli		, @oLojaCli		,;
													@oNomeCli	, @oSayDtIni	, @oDataIni		, @oSayDtFim	,;
													@oDataFim	, @oSayNumNF	, @oCodNumNF	, @oSaySerie	,;
													@oSerieNF 	, cAliasTRB		, @aRecSD2		, oGetdTRC		,;
													@lFormul	, @lCompCR		, @nRecnoTRB	, nTpProc 		,;
													nNfOrig		, oWizard:nPanel, oLblValTroca  , oValTroca 	,;
													@oSayFil	, @oCodFil 		, @oDescrFil) ) 
				EndIf	         						 
				
				//--------------------------
				// Label "Dados da venda"
				//--------------------------
				@ 055,010  TO 124,390 LABEL STR0141 OF oWizard:GetPanel(1) COLOR CLR_HBLUE PIXEL //"Dados da venda"
				
				
				Lj720NomFi( cCodFil, @cDescrFil, .F. )
				
				//Campo ""Filial"
				@ 067,020 SAY  oSayFil VAR STR0142 OF oWizard:GetPanel(1) PIXEL SIZE 50,9 //"Filial:" 
				@ 065,070 MSGET oCodFil	VAR cCodFil SIZE 50,10 Picture "@!" F3 "DLB" OF oWizard:GetPanel(1) ;
						VALID ( cCdFl := cCodFil, If(Lj720NomFi(cCodFil, @cDescrFil, .T.), oDescrFil:Refresh(), .F.) ) ;
						PIXEL  WHEN (!lVdAssist .And. nNfOrig==1 .And. lAltFilial)
				
				@ 065,135 MSGET oDescrFil VAR cDescrFil SIZE 200,10 Picture "@!" OF oWizard:GetPanel(1) PIXEL WHEN .F.
				
				//Campo "Cliente"
				@ 087,020 SAY oSayClient Var STR0011 OF oWizard:GetPanel(1) PIXEL SIZE 50,09 //"Cliente:"
				@ 085,070 MSGET oCodCli VAR cCodCli SIZE 40,10 Picture "@!" F3 cConPadCli OF oWizard:GetPanel(1) ;
						VALID (cCdCli := cCodCli, L720ChgCli( "CODCLI"		, cAliasTRB		, @aRecSD2	, oGetdTRC  , ;
															@lFormul  		, lCompCR   	, @nRecnoTRB, nTpProc	, ;
															nNfOrig			, oWizard:nPanel, cCodCli 	, @cLojaCli	, ;
															cCodFil			, @oLojaCli		, @oNomeCli	, @cNomeCli));
						PIXEL WHEN ( nFiltroPor==1 .And. aControls[4][3])
				
				//Campo "Loja"
				@ 085,115 MSGET oLojaCli VAR cLojaCli SIZE 10,10 Picture "@!" OF  oWizard:GetPanel(1) ;
						VALID (cCdLj := cLojaCli, L720ChgCli( "CODLOJA"		, cAliasTRB		, @aRecSD2	, oGetdTRC  , ;
															@lFormul  		, lCompCR   	, @nRecnoTRB, nTpProc	, ;
															nNfOrig			, oWizard:nPanel, cCodCli 	, @cLojaCli	, ;
															cCodFil			, @oLojaCli		, @oNomeCli	, @cNomeCli));
						PIXEL WHEN ( nFiltroPor==1 .And. aControls[4][3] )
				
				//Campo "Nome do cliente"
				@ 085,135 MSGET oNomeCli VAR cNomeCli SIZE 200,10 Picture "@!" OF oWizard:GetPanel(1) PIXEL WHEN .F.
				If lLGPD .And. LjPDCmpPrt("LQ_NOMCLI")
					LjPDOfuscar(oNomeCli, "LQ_NOMCLI")
				EndIf
				
				//Campo "Data Inicial Compra"
				@ 107,020 SAY oSayDtIni Var STR0012 OF oWizard:GetPanel(1) PIXEL SIZE 50,09 //"Data Inicial Compra:"
				@ 105,070 MSGET oDataIni VAR dDataIni SIZE 40,10 OF oWizard:GetPanel(1) VALID( If(nNfOrig == 1,!EMPTY(dDataIni),.T.) , IIf(!Empty(dDataFim),dDataFim >= dDataIni,.T.)) PIXEL 
				
				//Campo "Data Final Compra"
				@ 107,135 SAY oSayDtFim Var STR0013 OF oWizard:GetPanel(1) PIXEL SIZE 50,09 //"Data Final Compra:"
				@ 105,185 MSGET	oDataFim VAR dDataFim SIZE 40,10 OF oWizard:GetPanel(1) VALID( If(nNfOrig == 1,!EMPTY(dDataFim),.T.) ,  IIf(!Empty(dDataFim),dDataFim >= dDataIni,.T.)) PIXEL 	
				
				//Campo "No. Cupom / Nota"
				@ 107,020 SAY oSayNumNF Var STR0140+":" OF oWizard:GetPanel(1) PIXEL SIZE 50,09 //"No. Cupom / Nota":
				@ 105,070 MSGET oCodNumNF VAR cNumNF SIZE 50,10 Picture "@!" OF oWizard:GetPanel(1) PIXEL
				
				//Campo "Serie"
				@ 107,135 SAY oSaySerie Var STR0017+":" OF oWizard:GetPanel(1) PIXEL SIZE 50,09 //"Série":
				@ 105,155 MSGET oSerieNF VAR cSerieNF SIZE 15,10 Picture "@!" OF oWizard:GetPanel(1) PIXEL
				
				//Campo "Codigo do Vale-Troca"
				@ 087,020 SAY oLblValTroca Var STR0158+":" OF oWizard:GetPanel(1) PIXEL SIZE 50,09 //"Vale-Troca"
				@ 085,070 MSGET oValTroca VAR cValTroca SIZE 120,10 Picture "@!" OF oWizard:GetPanel(1) PIXEL
				
				If nFiltroPor == 1
					//Oculta campos "No. Cupom / Nota" e "Serie"
					oSayNumNF:Hide()
					oCodNumNF:Hide()
					oSaySerie:Hide()
					oSerieNF:Hide()
					oLblValTroca:Hide()
					oValTroca:Hide()
				Else
					//Oculta campos "Data Inicial Compra" e "Data Final Compra"
					oSayDtIni:Hide()
					oDataIni:Hide()
					oSayDtFim:Hide()
					oDataFim:Hide()
					oLblValTroca:Hide()
					oValTroca:Hide()
				EndIf
				
				//--------------------------
				// Botao "Pesquisar"
				//--------------------------
				@ 110,345 BUTTON oBotaoPesq PROMPT STR0037 SIZE 040,11 OF oWizard:GetPanel(1) PIXEL ;
					WHEN (nNfOrig==1);
					ACTION ( Lj720AltProc( 	cAliasTRB  , @aRecSD2  	, oGetdTRC  ,@lFormul  ,;
											@lCompCR   , @nRecnoTRB	, nTpProc ) ,;
							L720SelIte( cCodFil		, @aRecSd2	, nNfOrig	, nFiltroPor, ;
										@cCodCli	, @cLojaCli	, @cNomeCli	, oNomeCli	, ;
										dDataIni  	, dDataFim	, cAliasTRB , @nRecnoTRB, ;
										cNumNF 		, cSerieNF 	, @nVlrTotal, cValTroca , ;
										@lLegMotDev, nTpProc)) //"Pesquisar"
				
				//--------------------------
				// Label dos Itens da Venda
				//--------------------------
				@ 128,010  TO 235,390 LABEL "" OF oWizard:GetPanel(1) PIXEL
				
				DbSelectArea(cAliasTRB)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Sempre setar o indice que nao possui o campo TRB_ITEM na chave, para quando estiver    ³
				//³ em modo de edicao do objeto, seja incrementado mais um ao conteudo do campo ITEM.     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSetOrder(1)
	
				oGetdTRC := MsGetDB():New(			133		,	015		,		205		,		385		,;
													3		,"LJ720LinOK()"	,"AllwaysTrue"	,"+TRB_ITEM"	,;
													.F.		,{"TRB_QUANT","TRB_TES", "TRB_PRCVEN"}, NIL	,     .T.		,; 
													999		,cAliasTRB	        	, NIL	,	 NIL        ,;
													.T.     ,oWizard:GetPanel(1)	, NIL	,		.T.		,;
													"L720VldDel" )
				oGetdTRC:oBrowse:nColPos := GetMV("MV_LJ720FC",,1)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Consulta Padrão (F3)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oGetdTRC:aInfo[nPosProd][1]		:= "SL2"
				oGetdTRC:aInfo[nPosTES][1]		:= "SF4"		  	
				oGetdTRC:lDeleta				:= .F. 
				oGetdTRC:lNewLine				:= .F. 		
				oGetdTRC:ForceRefresh()
				
				//Campos "Moeda" e "Taxa" (ambiente diferente de Brasil)
				If cPaisLoc <> "BRA"
					//Moeda
					@ 210,015 SAY STR0088  OF oWizard:GetPanel(1) SIZE 50,9 PIXEL   			
					@ 208,040 COMBOBOX oMoeda VAR cMoeda ITEMS aMoeda ON CHANGE (nTxMoedaTr:=RecMoeda(dDataBase,oMoeda:nAt)				,;
					nMoedaAnt := nMoedaCorT																							,;
					nMoedaCorT := oMoeda:nAt 																							,;
					Lj720TrcMoed(  @nMoedaAnt,  .T.,  @nMoedaCorT,  @nTxMoedaTr,														;
									cAliasTRB , @oGetdTRC ))																			;
					VALID (RecMoeda(dDataBase,oMoeda:nAt) > 0) WHEN (If(nNfOrig == 2 .AND. !lTroca,.T.,.F.))						;
					SIZE  55, 8 OF oWizard:GetPanel(1) PIXEL
					
					//Taxa
					@ 210,110 SAY STR0089    OF oWizard:GetPanel(1) SIZE 50,9 PIXEL   			
					@ 208,130 MSGET oTxMoeda VAR nTxMoedaTr SIZE  55, 8 OF oWizard:GetPanel(1) Picture PesqPict("SL1","L1_TXMOEDA") 	;
					ON CHANGE Lj720TrcMoed(  @nMoedaAnt,  .F.,  @nMoedaCorT,  @nTxMoedaTr,												;
											cAliasTRB ,@oGetdTRC  ) WHEN .F. PIXEL
				EndIf
				
				//"Botao "Fiscais"		
				@ 208,345 BUTTON STR0024 SIZE 040,11 OF oWizard:GetPanel(1) PIXEL ACTION MsgRun(STR0055,,{||Lj720Impos(cCodCli,cLojaCli,cCodFil,lDevFrete)})  //Fiscais
				
				//CheckBox "Devolve o valor de Frete/Seguro/Despesa"
				@ 223,25  SAY STR0178 OF oWizard:GetPanel(1) PIXEL SIZE 150,9   //"Devolve o valor de Frete/Seguro/Despesa"
				@ 223,15  CHECKBOX oFrete VAR lDevFrete SIZE 8,8 PIXEL OF oWizard:GetPanel(1) WHEN aControls[5][3]
				
				//Campo "Valor Total de Mercadorias"
				@ 223,250 SAY STR0045 OF oWizard:GetPanel(1)  PIXEL							//"Valor Total de Mercadorias : "
				@ 223,325 MSGET oVlrTotal VAR nVlrTotal SIZE 60,8 Picture "@E 999,999.99" OF oWizard:GetPanel(1) PIXEL WHEN .F.
				
				If lLJ720CTRL
					//Esta funcao eh chamada aqui para que os objetos da tela sejam atualizados, caso o P.E. "LJ720CTRL" tenha sido utilizado para configurar os objetos da tela
					L720ChgOri( nNfOrig  	, @oDataIni		, @oDataFim		, @dDataIni  	,;
								@dDataFim	, @oCodFil   	, @cCodFil  	, @oDescrFil 	,;
								@cDescrFil	, @oFiltroPor	, @oBotaoPesq	, cAliasTRB  	,;
								@aRecSD2  	, oGetdTRC  	, @lFormul		, @lCompCR   	,;
								@nRecnoTRB	, nTpProc 		, oWizard:nPanel, @nFiltroPor 	,;
								@oSayClient	, @oCodCli		, @oLojaCli		, @oNomeCli		,;
								@oSayDtIni	, @oSayDtFim	, @oSayNumNF 	, @oCodNumNF	,;
								@oSaySerie	, @oSerieNF 	, oLblValTroca  , oValTroca) 
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se MV_RASTRO estiver como "S", habilita consulta do lote atraves da tecla F4.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMv_Rastro
					Set Key VK_F4 To Lj720Lote()
				EndIf
				
			//ÚÄÄÄÄÄÄÄ¿
			//³Panel 2³
			//ÀÄÄÄÄÄÄÄÙ
			CREATE PANEL oWizard  HEADER STR0014 ;  	//"Dados do Documento de Entrada"
				MESSAGE STR0143 ; 					//"Informe os dados para geração da nota de entrada"
				BACK {|| Lj720Back(cAliasTRB,nRecnoTRB,@nVlrTotal), .T.};
				NEXT {|| .F.};
				FINISH {|| If(!lFormul,!Empty(cNumDoc) .AND. !Empty(cSerieDoc) .AND. !Empty(cTpEspecie),.T.) .AND. ;
							L720NextPn( oWizard:nPanel 	, nNfOrig  		, cCodCli 		, cLojaCli  ,;
										@oWizard       	, nTpProc  		, Nil			, Nil		,;
										cCodFil			, nFiltroPor 	, aRecSD2 		, lDevFrete ) .AND. ;
							Lj720ValDev( lCompCR   ,nFormaDev  ,nTpProc  	, nNfOrig,	lFormul,	aRecSD2 )    .AND. ;
								Lj720Concluir(	nTpProc		, nNfOrig		, cCodCli   	, cLojaCli		,;
												aRecSD2		, lFormul		, cNumDoc   	, cSerieDoc		,;
												lCompCR		, lVdAssist		, @aDocDev   	, nFormaDev		,;
												nVlrTotal	, @lDevMoeda	, nMoedaCorT	, nTxMoedaTr	,; 
												cCodDia		, cMotivo 	 	, @nImpostos  	, M->F1_CHVNFE	,;
												cTpEspecie	, cCodFil		, lDevFrete )} PANEL
				
				oWizard:GetPanel(2)
				
				//------------------------------------------------
				// Label "Dados para geração da nota de entrada"
				//------------------------------------------------
				@ 005,010  	TO   070,390 LABEL STR0144	OF oWizard:GetPanel(2) COLOR CLR_HBLUE PIXEL //"Dados para geração da nota de entrada"
				@ 017,015	 	SAY  STR0011     		    OF oWizard:GetPanel(2) 	PIXEL SIZE 50,9 		//"Cliente:" 
				@ 015,090	 	MSGET 	oCodCli_1  	VAR cCodCli  	SIZE 40,10 		Picture "@!" F3 cConPadCli OF  oWizard:GetPanel(2) ;
							VALID (Lj720ValCli(cCodCli,cLojaCli),cNomeCli := Lj720VldCli(cCodCli,cLojaCli,cCodFil),oNomeCli:Refresh()) 	;
							PIXEL  WHEN If(nNfOrig == 1, .T., .F.)
				@ 015,135	MSGET 	oLojaCli_1 	VAR cLojaCli 	SIZE 10,10 	Picture "@!" 			OF  oWizard:GetPanel(2) ;
							VALID (Lj720ValCli(cCodCli,cLojaCli),cNomeCli := Lj720VldCli(cCodCli,cLojaCli,cCodFil),oNomeCli:Refresh()) 	;
							PIXEL WHEN If(nNfOrig == 1, .T., .F.)
				@ 015,165 MSGET oNomeCli_1 VAR cNomeCli SIZE 200,10 Picture "@!" OF oWizard:GetPanel(2) PIXEL WHEN .F.
				If lLGPD .And. LjPDCmpPrt("LQ_NOMCLI")
					LjPDOfuscar(oNomeCli_1, "LQ_NOMCLI")
				EndIf
				
				//Campo "Valor Total de Mercadorias"
				@ 035,015 SAY STR0045 OF oWizard:GetPanel(2)  PIXEL							//"Valor Total de Mercadorias : "
				@ 033,090 MSGET oVlrTotal_1 VAR nVlrTotal SIZE 60,9 Picture "@E 999,999.99" OF oWizard:GetPanel(2) PIXEL WHEN .F.
				
				
				// Apresenta o campo para informar o codigo do diario - Portugal
				If cPaisLoc == "PTG" .AND. lAliasCVL
					@ 052,015	 	SAY  STR0116     		    OF oWizard:GetPanel(2) 	PIXEL SIZE 50,9 		//"Codigo do Diario:"
					@ 050,090	 	MSGET 	oCodDia  	VAR cCodDia  	SIZE 40,10 		Picture "@!" F3 "CVL" OF oWizard:GetPanel(2) ;
								VALID ( Lj720ValDia( cCodDia, lAliasCVL ), cDescrDia := Lj720DescrDia( cCodDia, lAliasCVL ), oDescrDia:Refresh() ) ;
								PIXEL 
					@ 052,165 	SAY 	oDescrDia 	Var cDescrDia 	OF oWizard:GetPanel(2) COLOR CLR_BLUE PIXEL SIZE 210,9 
				EndIf
				
				
				@ 80,10  TO 190,390 		LABEL "" OF oWizard:GetPanel(2)  PIXEL
				@ 83,25  SAY STR0046 OF oWizard:GetPanel(2) PIXEL SIZE 150,9   //"Utiliza formulário próprio para documento de entrada?"
				@ 81,15  CHECKBOX oFormul VAR lFormul SIZE 8,8 PIXEL OF oWizard:GetPanel(2) ON CHANGE Lj720AltForm(lFormul,oNumDoc,oSerieDoc,@cNumDoc,@cSerieDoc,oChvNFE,@M->F1_CHVNFE, oTpEspecie, @cTpEspecie)
				
				@ 93,25  SAY STR0047  OF oWizard:GetPanel(2) PIXEL SIZE 150,9  //"Numero do Documento"
				@ 92,80  MSGET oNumDoc 		VAR cNumDoc 	SIZE 35,8 	Picture "@!" PIXEL OF oWizard:GetPanel(2) VALID IIf(!lFormul,!Empty(cNumDoc),.T.) When !lFormul
				
				@ 93,125 SAY STR0017  OF oWizard:GetPanel(2) PIXEL SIZE 150,9 	//"Série"
				@ 92,140 MSGET oSerieDoc 	VAR cSerieDoc 	SIZE 15,8 	Picture "@!" PIXEL OF oWizard:GetPanel(2) VALID IIf(!lFormul, LjSerieOk(cSerieDoc,@cTpEspecie), .T.) When !lFormul
	
				@ 93,165 SAY STR0137  OF oWizard:GetPanel(2) PIXEL SIZE 180,9 	//"Espécie"?
				@ 92,185 MSGET oTpEspecie	VAR cTpEspecie SIZE 15,8	Picture "@!" PIXEL OF oWizard:GetPanel(2) VALID IIf(!lFormul, LjEspecOk(cTpEspecie), .T.) F3 "42" When !lFormul
				
				If SF1->(ColumnPos("F1_CHVNFE")) > 0
					M->F1_CHVNFE := CriaVar("F1_CHVNFE",.F.)
					@ 107,25  SAY STR0145  OF oWizard:GetPanel(2) PIXEL SIZE 150,9  //"Chave NFe"
					@ 105,55 MSGET oChvNFE 	VAR M->F1_CHVNFE  SIZE 150,8 	Picture "@!" PIXEL OF oWizard:GetPanel(2) When !lFormul
				EndIf
	
				//"Utiliza a Nota de Crédito(NCC) da devolução para compensar com o título da Nota Fiscal original?"		
				@ 140,25  SAY STR0069  OF oWizard:GetPanel(2) PIXEL SIZE 250,9  
				@ 138,15  CHECKBOX oCompCR VAR lCompCR SIZE 8,8 PIXEL OF oWizard:GetPanel(2) ;
						WHEN nTpProc == 2 .AND. cMV_LJCMPNC == "1" .AND. nNfOrig == 1
	
				@ 150,15 GROUP oGroup TO 185,90 LABEL STR0066 OF oWizard:GetPanel(2) PIXEL   //"Forma de devolução"		
	
				@ 159,18 RADIO oFormaDev VAR nFormaDev SIZE 60,10 PROMPT STR0067, STR0068 PIXEL ;       //"Dinheiro", "Nota de Crédito" 		 		
				OF oWizard:GetPanel(2) WHEN nTpProc == 2 .AND. cMV_LJCHGDV == "1" ;
				ON CHANGE Lj720AltMd(nFormaDev,oDevMoeda)
				
				If cPaisLoc <> "BRA"
					If nNfOrig == 1
						If SL1->L1_MOEDA <> 0 .AND.  SL1->L1_MOEDA <= Len(aMoeda)
							nMoedaCorT := SL1->L1_MOEDA
							nTxMoedaTr := SL1->L1_TXMOEDA
						ElseIf SL1->L1_MOEDA == 0
							nMoedaCorT := 1
							nTxMoedaTr := 1
						Else
							//"Moeda não cadastrada"+"Atenção"
							MsgAlert(STR0090,STR0091)
						Endif
					EndIf
								
					//"Devolução em moeda diferente?"
					@ 155,110  SAY STR0092 + SuperGetMV("MV_MOEDA"+AllTrim(Str(nMoedaCorT))) + "?"  OF oWizard:GetPanel(2) PIXEL SIZE 250,9  
					@ 153,100  CHECKBOX oDevMoeda VAR lDevMoeda SIZE 8,8 PIXEL OF oWizard:GetPanel(2);
					WHEN nTpProc == 2 .AND. cMV_LJCHGDV == "1" .AND. nFormaDev == 1
					
				EndIf  
				
				//Habilita o Campo de Motivo da Devolucao
				If lMotDev
					@ 172,100  SAY  STR0121	OF oWizard:GetPanel(2) PIXEL SIZE 50,9//"Motivo:" 	
					
					If cPaisLoc <> "BRA"
						@ 170,120  MSGET 	oMotivo  VAR cMotivo  	SIZE 40,10 	Picture "@!" F3 "O1" OF oWizard:GetPanel(2) ;
						VALID ( Lj720VldMot(cMotivo, @cDescMot), oDescMot:Refresh()) PIXEL
					Else
						@ 170,120	MSGET	oMotivo  VAR cMotivo  	SIZE 250,10 	Picture "@!" OF  oWizard:GetPanel(2) PIXEL WHEN lLegMotDev 
					EndIf

					@ 172,166 SAY 	oDescMot 	Var cDescMot 	OF oWizard:GetPanel(2) COLOR CLR_RED PIXEL SIZE 180,9 
				EndIf

      
				
		If Empty(cCdFl) .OR. Empty(cCdCli) .OR. Empty(cCdLj)
			cCdFl 	:= cCodFil
			cCdCli 	:= cCodCli
			cCdLj 	:= cLojaCli
		EndIf     
				
		ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.} VALID {|| Lj720AtuTrc()}
	Endif//finaliza if de desvio robô

	If lConfirma .AND. nNfOrig == 1
		LjLogDevol(nRecnoTRB)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga os arquivos temporarios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If( ValType(oTempTable) == "O")
	  oTempTable:Delete()
	  FreeObj(oTempTable)
	  oTempTable := Nil
	EndIf	

    DbSelectArea("SD2")
    RetIndex("SD2")
    DbClearFilter()

    Lj720BkpArea(cCad, aRots, aSavHead, nBkpLin)
Endif

RestArea(aArea)

If AllTrim( FunName() ) == "LOJA701"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita SetKeys da Venda Assistida						     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.T.)  
	M->LQ_CLIENTE := cCodCli 
	M->LQ_LOJA    := cLojaCli 	
	M->LQ_NOMCLI  := Posicione( "SA1",1,FWxFilial("SA1",cCodFil)+cCodCli+cLojaCli,"SA1->A1_NOME" )	
Endif

LjGrvLog( "TROCA_DEVOLUCAO", "ID_FIM")

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Cliente        ³ Data ³27/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef() 

Local aRotina := {	{ STR0037  	,"AxPesqui" ,0 , 1 , , .F. },;		// "Pesquisar"
					{ STR0038 	,"AxVisual" ,0 , 2 , , .T. },;		// "Visualizar"
					{ STR0039  	,"AxInclui" ,0 , 3 , , .T. },;		// "Incluir"
					{ STR0040  	,"AxAltera" ,0 , 4 , , .T. } }		// "Alterar"
Return ARotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720VldCli ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Devolve o nome do cliente baseado no codigo que foi        º±±
±±º          ³ digitado.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do Cliente                                   º±±
±±º          ³ExpC2 - Loja do Cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720VldCli(cCodCli, cCodLoja, cFilCli)
Local cDesc := CRIAVAR("A1_NOME",.F.)                //Nome do cliente
Local aArea	:= GetArea()                             //Area atual para restaurar no final da funcao

cFilCli := FWxFilial("SA1",cFilCli)

If !Empty(cCodCli) .AND. !Empty(cCodLoja)
	DbSelectArea("SA1")
	If DbSeek(cFilCli+cCodCli+cCodLoja)
		cDesc := SA1->A1_NOME
	Endif	
Endif

RestArea(aArea)

Return(cDesc)                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720AltFormºAutor  ³ Vendas Cliente     º Data ³  25/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita / Desabilita a edicao dos campos Numero do documen-º±±
±±º          ³to e serie do documento para formulario proprio igual a NAO.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Indica se utiliza ou nao formulario proprio         º±±
±±º          ³ExpO2 - Objeto Numero do documento                          º±±
±±º          ³ExpO3 - Objeto Serie do documento                           º±±
±±º          ³ExpC4 - Numero do documento de entrada                      º±±
±±º          ³ExpC5 - Serie do documento de entrada                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720AltForm(	lFormul		, oNumDoc, oSerieDoc, cNumDoc	,;
								cSerieDoc	, oChvNFE, cChvNFE	, oTpEspecie,;
								cTpEspecie	)

Local lRet	:= .T.                                // Retorno da funcao

If lFormul		// Utiliza formulario proprio
	cNumDoc		:= CriaVar("F1_DOC"		,.F.)
	cSerieDoc	:= CriaVar("F1_SERIE"	,.F.)
	cTpEspecie	:= CriaVar("F1_ESPECIE"	,.F.)
	
	oNumDoc:Refresh()
	oSerieDoc:Refresh()
	oTpEspecie:Refresh()
	
	oNumDoc:Disable()
	oSerieDoc:Disable()
	oTpEspecie:Disable()

	If ValType(oChvNFE) <> "U"
		cChvNFE	:= CriaVar("F1_CHVNFE",.F.)    
		oChvNFE:Refresh()
		oChvNFE:Disable()
	EndIf
Else
	oNumDoc:Enable()
	oSerieDoc:Enable()
	oTpEspecie:Enable()
	
	If ValType(oChvNFE) <> "U"
		oChvNFE:Enable()
	EndIf
Endif	

oNumDoc:Refresh()          
oSerieDoc:Refresh()
oTpEspecie:Refresh()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720AltProc ºAutor  ³ Vendas Cliente  º Data ³  08/22/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada para tratar as seguintes situacoes:       º±±
±±º          ³1- Quando o usuario  trocar o tipo de processo (Troca ou De-º±±
±±º          ³volucao), limpa a getdados para nao exibir dados anteriores.º±±
±±º          ³2- Quando o usuario trocar a origem do processo (Com NF de  º±±
±±º          ³Origem ou Sem NF de Origem.)                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Alias do arquivo de trabalho					      º±±
±±º          ³ExpC2 - Alias do arquivo de trabalho temporario.            º±±
±±º          ³ExpO3 - Objeto da MsGetDB                                   º±±
±±º          ³ExpL4 - Formulario proprio                                  º±±
±±º          ³ExpL5 - Compensa o titulo da NF original                    º±±
±±º          ³ExpN6 - Recno da area de trabalho                           º±±
±±º          ³ExpN7 - Tipo de operacao: 1=troca;2=devolucao				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - VENDA ASSISTIDA.                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720AltProc( cAliasTRB  ,aRecSD2   ,oGetdTRC  ,lFormul  ,;
                              lCompCR    ,nRecnoTRB ,nTpProc   )
            
Local lRet	:= .T.               // Retorno da funcao
Local nX	:= 0                 // Controle de loop

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desmarca todos os produtos que foram marcados no panel de selecao de produtos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRecSD2) > 0
	For nX:= 1 to Len(aRecSD2)
		DbSelectArea("SD2")
		DbGoTo(aRecSD2[nX][2])
		RecLock("SD2",.F.)
		REPLACE	SD2->D2_OK WITH Space(Len(SD2->D2_OK))
		MsUnlock()                                                             
	Next nX
	aRecSD2:= {}
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o arquivo de trabalho quando alterar o processo de troca³
//³e sempre inclui um registro para nao ter problemas com EOF(). ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAliasTRB)
If (cAliasTRB)->(LastRec()) > 0
	(cAliasTRB)->(__dbZap())
	nVlrTotal := 0
	oVlrTotal:Refresh()
	
	RecLock(cAliasTRB,.T.)
	REPLACE	TRB->TRB_ITEM WITH StrZero(1,TamSX3("D2_ITEM")[1])
	MsUnlock()  
	oGetdTRC:nCount:=(cAliasTRB)->(LastRec())
	nRecnoTRB  := Recno()
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reinicializa as variaveis do ultimo panel que foram alteradas pelo usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lFormul	:= .T.
lCompCR	:= SuperGetMv( "MV_LJCMPCR", NIL, .T. )
lTroca  := nTpProc == 1

LjGrvLog( "TROCA_DEVOLUCAO", "Rotina alterada Troca/Devolução 1=Troca 2=Devolucao - nTpProc", nTpProc)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720FilSD2 ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza um filtro atraves da IndRegua na tabela SD2         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do Cliente                                   º±±
±±º          ³ExpC2 - Loja do Cliente                                     º±±
±±º          ³ExpD3 - Data Inicial de Compra                              º±±
±±º          ³ExpD4 - Data Final de Compra                                º±±
±±º          ³ExpO5 - Objeto Mark                                         º±±
±±º          ³ExpA6 - Array com os arquivos gravados em disco para excluirº±±
±±º          ³ExpC7 - Alias da area de trabalho							  º±±
±±º          ³ExpC8 - Nome do cliente          							  º±±
±±º          ³ExpO9 - Objeto do nome do cliente          				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - VENDA ASSISTIDA                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720FilSD2( cCodCli  , cLojaCli , dDataDe   , dDataAte ,;
							 oMark    , cAliasTRB, cNomeCli  , oNomeCli ,;
							 cCodFil  , nFiltroPor, cNumNF 	 , cSerieNF ,;
							 nNfOrig )

Local aArea  		:= GetArea()						// Guarda area de origem
Local xRet      	:= {}                  				// Retorno do PE LJ720FLT       
Local lRet			:= .T.   							// Retorno da Funcao	
Local cCond 		:= ""								// Filtro da selecao do SD2
Local cIndex    	:= ""   							// Indice da IndRegua
Local lLJ720Flt 	:= ExistBlock("LJ720FLT")  			// Controla se o PE LJ720FLT existe
Local lMVLJPRDSV	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) // Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local cDocsNot		:= "" 								// Relacao de documentos que nao devem ser trazidos no filtro do SD2
Local cFilSD2 		:= FWxFilial("SD2",cCodFil)
Local cFilSL1 		:= FWxFilial("SL1",cCodFil)
Local lCentroDL		:= SuperGetMv("MV_LJCDL",, .F.) 	// Parametro de controle VFE
Local cCliPad		:= SuperGetMV("MV_CliPad", ,"000001")
Local cLojaPAd		:= SuperGetMV("MV_LojaPad",,"01")
Local cAliasVFE		:= ""
Local lLjImpGF		:= SuperGetMv("MV_LJIMPGF",,.F.)
Local cLjTpGar		:= SuperGetMv("MV_LJTPGAR",,"GE")
Local cQuerySL1		:= ""
Local cAlSL1		:= GetNextAlias() 
Local cEol			:= CHR(13) + CHR(10)

Default nFiltroPor 	:= 1
Default cNumNF		:= ""
Default cSerieNF 	:= ""

LjGrvLog( "TROCA_DEVOLUCAO", "Venda com itens de 'produto' e itens de 'servico' em Notas Separada - MV_LJPRDSV", lMVLJPRDSV)

//Para selecao das NFs originais deve estar setado com 2
DbSelectArea(cAliasTRB)	
DbSetOrder(2)

DbSelectArea("SD2")
cIndex := CriaTrab(NIL,.F.)
cCond := "D2_FILIAL == '" + cFilSD2 + "' "
cCond += ".AND. D2_TIPO <> 'D' "
cCond += ".AND. (D2_QUANT - D2_QTDEDEV) > 0 "

If !lLjImpGF
	cCond += ".AND. D2_TP <> '" + cLjTpGar + "' "
EndIf

// Se Origem é Com Documnto de Entrada, não tras produtos do tipo MO (Mao de Obra - RPS)
If nNfOrig == 1
	cCond += ".AND. Empty(D2_CODISS) .AND. Empty(D2_ALIQISS) "
EndIf

If cPaisLoc == "BRA"
   cCond += ".AND.  SD2->D2_TOTAL > 0 "
Else
	cCond += ".AND. SD2->D2_REMITO <> 'NFCUP' "
Endif

If lLJ720Flt
	LjGrvLog( "TROCA_DEVOLUCAO", "Antes da Chamada do Ponto de Entrada:LJ720FLT",{ dDataDe, dDataAte, cCodCli, cLojaCli, nFiltroPor, cNumNF, cSerieNF })
	xRet  := ExecBlock("LJ720FLT",.F.,.F.,{ dDataDe, dDataAte, cCodCli, cLojaCli, nFiltroPor, cNumNF, cSerieNF })
	LjGrvLog( "TROCA_DEVOLUCAO", "Apos a Chamada do Ponto de Entrada:LJ720FLT xRet", xRet)
   If ValType(xRet) == "C"
      cCond  += xRet
   ElseIf ValType(xRet) == "A" .AND. LEN(xRet) == 4
      cCond     += xRet[1]
      cCodCli   := xRet[2]
	  cLojaCli  := xRet[3]
	  cNomeCli  := xRet[4]
	  oNomeCli:Refresh()
   Endif
Else
	If nFiltroPor == 1
		If !Empty(cCodCli)
		  	cCond += " .AND. D2_CLIENTE == '" + cCodCli + "' "
		Endif
		If !Empty(cLojaCli)
		  	cCond += " .AND. D2_LOJA    == '" + cLojaCli    + "' "
		Endif
		If !Empty(dDataDe)
		  	cCond += " .AND. DtoS(D2_EMISSAO) >= '" + DtoS(dDataDe)  + "'"
		Endif
		If !Empty(dDataAte)
			cCond += " .AND. DtoS(D2_EMISSAO) <= '" + DtoS(dDataAte) + "' "
		Endif
	Else
		If !Empty(cNumNF)
		  	cCond += " .AND. D2_DOC == '" + cNumNF + "' "
		Endif
		If !Empty(cSerieNF)
		  	cCond += " .AND. D2_SERIE == '" + cSerieNF + "' "
		Endif
	EndIf
Endif

If lMVLJPRDSV

	If !Empty(cCodCli) .And. !Empty(cLojaCli)

		cQuerySL1 := ""		
		cQuerySL1 += "SELECT SL1.L1_DOCRPS " + cEol
		cQuerySL1 += "FROM " + RetSQLName("SL1") + " SL1 " + cEol
		cQuerySL1 += "WHERE SL1.D_E_L_E_T_ = '' " + cEol
		cQuerySL1 += "AND SL1.L1_FILIAL = '" + cFilSL1 + "' " + cEol
		cQuerySL1 += "AND SL1.L1_CLIENTE = '" + cCodCli + "' " + cEol
		cQuerySL1 += "AND SL1.L1_LOJA = '" + cLojaCli + "' " + cEol
		cQuerySL1 += "AND SL1.L1_DOCRPS <> '' " + cEol
		cQuerySL1 += "AND SL1.L1_EMISSAO >= '" + DTOS(dDataDe) + "' " + cEol
		cQuerySL1 += "AND SL1.L1_EMISSAO <= '" + DTOS(dDataAte) + "' " + cEol

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuerySL1)),cAlSL1,.T.,.T.)

		While (cAlSL1)->(!EoF())
			cDocsNot += "|"+Alltrim((cAlSL1)->L1_DOCRPS)+"|"
			(cAlSL1)->( DbSkip() )
		End

		(cAlSL1)->(DbCloseArea())

		If !Empty(cDocsNot)
			cCond += ".AND. !(SD2->D2_DOC $ '"+cDocsNot+"') " //Desconsidera os Documentos relacionados ao RPS (Nota Fiscal de Servico)
		EndIf
	EndIf
EndIf

//Tratamento Vfe para nao mostrar Notas de Saida complementares
If lCentroDL .And. (cCodCli + cLojaCli != cClipad + cLojaPad)
	cDocsNot := "" //Limpa variavel de documentos
	
	cAliasVFE := GetNextAlias() 
	
	BeginSQL Alias cAliasVFE
	        SELECT SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_PEDIDO, SD2.D2_ITEM, SD2.D2_DOC, SC5.C5_TPCD
	        FROM %Table:SD2% SD2, %Table:SC5% SC5,%Table:SC6% SC6
	        WHERE SD2.D2_FILIAL  	=  %Exp:cFilSD2%		AND
					SD2.D2_CLIENTE 	=  %Exp:cCodCli%		AND
					SD2.D2_LOJA 		=  %Exp:cLojaCli%		AND
					SD2.D2_EMISSAO 	>= %Exp:dDataDe% 		AND
					SD2.D2_EMISSAO 	<= %Exp:dDataAte%		AND
					SC6.C6_FILIAL		=	SD2.D2_FILIAL		AND
					SC6.C6_NUM			=	SD2.D2_PEDIDO		AND
					SC6.C6_ITEM		=	SD2.D2_ITEM		AND
					SC6.C6_PRODUTO	=	SD2.D2_COD			AND
					SC5.C5_FILIAL		=	SC6.C6_FILIAL		AND
					SC5.C5_NUM			=	SC6.C6_NUM			AND				
					SD2.%NotDel%								AND
					SC5.%NotDel%								AND
					SC6.%NotDel%
	EndSQL

	DbSelectArea(cAliasVFE)
	While !(cAliasVFE)->(Eof())
		If (cAliasVFE)->C5_TPCD $ "0|1|4"
			cDocsNot += "|"+(cAliasVFE)->D2_DOC+"|"
		EndIf
		(cAliasVFE)->(dbSkip())
	EndDo
	(cAliasVFE)->(dbCloseArea())

	
	If !Empty(cDocsNot)
		cCond += ".AND. !(SD2->D2_DOC $ '"+cDocsNot+"') " //Desconsidera os Documentos relacionados ao RPS (Nota Fiscal de Servico)
	EndIf				
EndIf

DbSelectArea("SD2")
IndRegua("SD2",cIndex,"D2_DOC+D2_SERIE",,cCond)
DbGoTop()

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720Mark   ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os dados do acols de acordo com os produtos       º±±
±±º          ³ selecionados na NF de origem.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Marca do produto selecionado                        º±±
±±º          ³ExpA2 - Array com os Recnos da tabela SD2                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - VENDA ASSISTIDA                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720Mark( cMarca  ,aRecSd2, oMark, cCodFil )

Local nPosRec 		:= 0              										// Posicao do recno do SD2 no array aRecSD2 
Local nRecnoSD2 	:= SD2->(RECNO()) 										// Recno da SD2
Local aSl2Area 		:= {} 													// Amazena a area do sl2
Local aSd2Area		:= {} 													// Amazena a area do sd2
Local lGE			:= ExistFunc("LjUP104OK") .AND. LjUP104OK() 			// Indica se o release e 11.5
Local cOk			:= "" 
Local cFilSL2 		:= FWxFilial("SL2",cCodFil)
Local lVP			:= SuperGetMv("MV_LJVALEP",,.F.) .And. AliasIndic("MDD")// Vale Presente ativo
Local lGarSrv		:= .F.													// Gera o Processo apenas para a Garantia Estendida/Servico Financeiro
Local oDlg 			:= NIL 													// Opcoes para Garantia Estendida
Local ljImpGf		:= SuperGetMv("MV_LJIMPGF",,.F.)
Local cPedOri		:= ""  													// Pedido de Origem       
Local aAreaSD2		:= {}  													// WorkArea SD2
Local lPedEC		:= .F. 													// Pedido e-commerce?
Local cDocOri		:= ""  													// Documento de Origem 
Local cSerOri		:= ""  													// Serie de Origem
Local cCliOri		:= ""  													// Cliente de Origem
Local cLojOri		:= ""  													// Loja do Cliente de Origem   
Local cFilSD2		:= FWxFilial("SD2",cCodFil)   
Local lMarca		:= .T. 													// Marca o Registro? 
Local lSFinanc		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local lECCia		:= .F. 													// e-commerce CiaShop?
Local lNaoEnviouCanc:= .F.													// Verificação de L1_SITUA
Local lGrvMarca		:= .T.
Local cAliasSD2		:= ""
Local cDocSD2		:= ""
Local cSerSD2		:= ""
Local cCodSD2		:= ""
Local lGEVencida	:= .F.

Default cMarca 		:= ""

LjGrvLog( "TROCA_DEVOLUCAO", "Vale Presente Ativo - MV_LJVALEP .And. AliasIndic('MDD') ", lVP)

lQtDeDev := Lj720GetQt()
 
DbSelectArea("SD2")
RecLock("SD2",.F.)
If SD2->D2_OK <> cMarca

    If HasTemplate("OTC") .And. !T_OTC720Mark( SD2->D2_SERIE, SD2->D2_DOC, SD2->D2_COD )
	    MsgAlert(STR0118)	//"Produto com Movimentacao no Laboratorio"
	    lGrvMarca := .F.
	ElseIf (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())) .And. T_DroVerCont( SD2->D2_COD )	//se for produto controlado
	    MsgAlert(STR0211)	//"Produto controlado, não pode ser devolvido !!"
	    lGrvMarca := .F.
	EndIf
	
	If lGrvMarca
		REPLACE SD2->D2_OK WITH cMarca
	Endif 

	//Cria a tela com as opcoes quando existir Garantia Estendida
	// ljImpGf = .f. , eh porque imprimiu no cupom fiscal e esta na d2 , enta nao precisa avisar
	If ljImpGf .AND. SD2->(ColumnPos("D2_ITEMGAR") > 0 ).AND. SL2->( ColumnPos("L2_GARDEV") > 0) .OR. lSFinanc
		If !Empty(SD2->D2_ITEMGAR) .AND. SL2->( dbSetOrder(1), dbSeek(FWxFilial("SL2",cCodFil)+ SD2->D2_ORCGAR + SD2->D2_ITEMGAR) )			
			
			If SL2->L2_EMISSAO + SL2->L2_VLGAPRO < dDataBase
				MsgAlert(STR0172 + CTRL + STR0215)	//"Este item possui Garantia Estendida!" "Será realizado somente a devolução do Item pois a Garantia Estendida Expirou."
				lGEVencida := .T.
			ElseIf Empty(SL2->L2_GARDEV) .OR. If(lQtDeDev,SL2->L2_QTDEDEV < SL2->L2_QUANT,.F.) 
				Define MsDialog oDlg Title STR0171 From 000,000 To 100,290 Of oDlg Pixel  	 //"Garantia Estendida"
								
				//Tela Garantia Estendida
				@005,032 Say STR0172 Size 100,007 Pixel Of oDlg      						 //"Este item possui Garantia Estendida!"
				@015,032 Say STR0173 Size 100,007 Pixel Of oDlg     	   					 //"O que será adicionado no processo ?"
				@030,032 Button STR0174 Size 036,013 Pixel Action (lGarSrv := .T.,oDlg:End())//"&Garantia"
				@030,072 Button STR0175 Size 046,013 Pixel Action(lGarSrv := .F.,oDlg:End()) //"&Item + Garantia"
								 
				Activate MsDialog oDlg Centered
			EndIf
		ElseIf lSFinanc .AND. Len(Lj720SrvFin(cCodFil)) > 0 //Tela Servico Financeiro
			Define MsDialog oDlg Title STR0192 From 000,000 To 100,290 Of oDlg Pixel  	 //"Serviço Financeiro"
			
			//Tela Servico Financeiro
			@005,032 Say STR0179 Size 100,007 Pixel Of oDlg      							//"Este item possui Serviço Financeiro!"
			@015,032 Say STR0173 Size 100,007 Pixel Of oDlg     	   					 	//"O que será adicionado no processo ?"
			@030,015 Button STR0180 Size 050,013 Pixel Action (lGarSrv := .T.,oDlg:End()) 	//"&Serviço Financeiro"
			@030,067 Button STR0181 Size 070,013 Pixel Action(lGarSrv := .F.,oDlg:End()) 	//"&Item + Serviço Financeiro"
				
			Activate MsDialog oDlg Centered	
		EndIf	
	EndIf
Else                                                                                  
	REPLACE SD2->D2_OK WITH Space(Len(SD2->D2_OK))
Endif

MsUnlock()                                                             

lNaoEnviouCanc := Lj720L1Sit(SD2->D2_DOC,SD2->D2_SERIE,cCodFil)
If ! lNaoEnviouCanc	//Se sim, o L1_SITUA deve estar com X0,X1,X2,X3: com status de cancelamento
						//Se status ou enviou o cancelamento, não deixarei cancelar via LOJA720
	If RecLock("SD2",.F.)
		REPLACE SD2->D2_OK WITH Space(Len(SD2->D2_OK))
		SD2->(MsUnlock())
	EndIf
	oMark:oBrowse:refresh() 
	Return
EndIf

//Venda e-commerce (realiza a marcação de todos os itens)  do orçamento
//+1 venda distinta, desmarca e cancelada 
cPedOri := SD2->D2_PEDIDO
lPedEC := Lj720PedEc(cPedOri,, cCodFil, @lECCia) 

LjGrvLog( "TROCA_DEVOLUCAO", "Venda e-commerce - lPedEC", lPedEC)
LjGrvLog( "TROCA_DEVOLUCAO", "Venda ciashop - lECCia", lECCia)

If lPedEC

	If !Empty(cPedOri)    //Devolução gerada por pedido de venda
	//Se pedido e-commerce , seleciona todos os sd2, associados ao pedido 
		lMarca := !Empty(SD2->D2_OK)
		
		If lMarca 
			cOk := SD2->D2_OK  
		Else 
			cOk := space(len(SD2->D2_OK))
		EndIf
		aAreaSD2 := SD2->(GetArea())
	
		cDocOri		:= SD2->D2_DOC
		cSerOri		:= SD2->D2_SERIE
		cCliOri		:= SD2->D2_CLIENTE
		cLojOri		:= SD2->D2_LOJA
	
		SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SD2->(DbSeek(cFilSD2 + cDocOri + cSerOri + cCliOri + cLojOri))
	
		While !SD2->(Eof())				.AND.;
			SD2->D2_DOC		== cDocOri	.AND.;
			SD2->D2_SERIE	== cSerOri	.AND.;
			SD2->D2_CLIENTE	== cCliOri	.AND.;
			SD2->D2_LOJA	== cLojOri   
			
			If SD2->D2_OK  <> cOK .And. SD2->D2_PEDIDO == cPedOri .And. SD2->(Recno()) <> nRecnoSD2
				//orçamento não marcado, marca-lo e adicioná-lo no array  
				RecLock("SD2",.F.)
				

				REPLACE SD2->D2_OK WITH cOk
				MsUnlock() 
											
				nPosRec := Ascan( aRecSD2, {|x| x[2] == SD2->(Recno()) } )
				
				If lMarca
					If nPosRec = 0
						Aadd(aRecSD2,{SD2->D2_QUANT, SD2->(Recno()), .f., 0 , 0})	
					Endif  
				Else
					If nPosRec > 0
						aDel(aRecSd2, nPosRec )
						aSize(aRecSd2, Len( aRecSd2 ) - 1 )		
					Endif
				EndIf
			EndIf
			
			SD2->(DbSkip())
		End
					
		RestArea(aAreaSD2)  
		SD2->(DbGoTo(nRecnoSD2))

	ElseIf !Empty(cPedOri)  .And. Empty(SD2->D2_OK)  //Desmarcando 
	
		REPLACE SD2->D2_OK WITH Space(Len(SD2->D2_OK))

	EndIf

EndIf 

//Fim Devolucao Venda e-commerce
LjGrvLog( "TROCA_DEVOLUCAO", "Garantia Extendida - lGE", lGE)
LjGrvLog( "TROCA_DEVOLUCAO", "Serviço Financeiro - lSFinanc", lSFinanc)

If lGE .OR. lSFinanc
	aSl2Area 	:= GetArea("SL2") 
	aSd2Area	:= GetArea("SD2")

	If (SL2->(DbSetOrder(3), DbSeek( cFilSL2+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_COD ))) .And. !Empty(SL2->L2_GARANT)

		cOk := SD2->D2_OK
		SD2->(DbSkip())
		
		If SD2->(!EOF())                    
			If Empty(SD2->D2_OK)
				nPosRec := Ascan( aRecSD2, {|x| x[2] == SD2->(Recno()) } )
				If nPosRec > 0
					aDel(aRecSd2, nPosRec )
					aSize(aRecSd2, Len( aRecSd2 ) - 1 )		
				Endif			
			EndIf  	
		EndIf
	EndIf	
	RestArea(aSl2Area)
	RestArea(aSd2Area)
EndIF

If lVP .And. !Empty(SD2->D2_OK) .And. PosValePre(cCodFil) .And. MDD->MDD_STATUS >= "3"
	MsgAlert(STR0166, STR0033) //#STR0166->"Este item do tipo Vale Presente não poderá ser devolvido pois o mesmo já foi utilizado em uma venda." ##STR0033->"Atenção"
	If RecLock("SD2",.F.)
		REPLACE SD2->D2_OK WITH Space(Len(SD2->D2_OK))
		SD2->(MsUnlock())
	EndIf
EndIf

If !Empty(SD2->D2_OK)

	aSl2Area 	:= GetArea("SL2") 

	SL2->(DbSetOrder(3))
	SL2->(DbSeek(cFilSL2+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_COD))
	
	Aadd(aRecSD2,{(SL2->L2_QUANT - If(lQtDeDev,SD2->D2_QTDEDEV,0)) , SD2->(Recno()),lGarSrv, 0, 0})

	/*=============================================================
		Inclui mais uma posição no array aRecSD2 com a Garantia 
		Estendida, caso o parâmetro MV_LJIMPGF = .F. 
	=============================================================*/
	If !lGEVencida .And. !ljImpGf .And. !lGarSrv .And. !Empty(SL2->L2_GARANT) 

		cAliasSD2	:= GetNextAlias()
		cDocSD2		:= SL2->L2_DOC
		cSerSD2		:= SL2->L2_SERIE
		cCodSD2		:= SL2->L2_GARANT

		BeginSQL Alias cAliasSD2

			SELECT D2_QUANT, D2_QTDEDEV, R_E_C_N_O_ RECNOSD2
	        FROM %Table:SD2%
	        WHERE   D2_FILIAL	= %Exp:cFilSD2%	AND
	                D2_DOC		= %Exp:cDocSD2%	AND
	                D2_SERIE	= %Exp:cSerSD2%	AND
					D2_COD		= %Exp:cCodSD2%	AND
	                %NotDel%

		EndSQL		

		Aadd(aRecSD2,{((cAliasSD2)->D2_QUANT - If(lQtDeDev,(cAliasSD2)->D2_QTDEDEV,0)) , (cAliasSD2)->RECNOSD2, lGarSrv, 0, 0 })
	EndIf

	RestArea(aSl2Area)
		
Else
	nPosRec := Ascan( aRecSD2, {|x| x[2] == SD2->(Recno()) } )
	If nPosRec > 0
		aDel(aRecSd2, nPosRec )
		aSize(aRecSd2, Len( aRecSd2 ) - 1 )		
	Endif
Endif	

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720GetStruºAutor  ³ Vendas Cliente     º Data ³  17/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a GetDados dos produtos a serem lancados a partir    º±±
±±º          ³ da tabela SD2.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - aHeader necessaria para a MsGetDB                   º±±
±±º          ³ExpA2 - Array com a estrutura  da tabela temporaria         º±±
±±º          ³ExpC3 - Alias do arquivo de trabalho                        º±±
±±º          ³ExpA4 - Array com os arquivos gerados em disco para excluir.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720GetStru(aHeaderSD2,	aStruTRB,	cAliasTRB)
Local aTamD2_ITEM		:= TamSx3("D2_ITEM")			// Tamanho do campo D2_ITEM
Local aTamD2_COD		:= TamSx3("D2_COD")				// Tamanho do campo D2_COD
Local aTamB1_DESC		:= TamSx3("B1_DESC")			// Tamanho do campo B1_DESC
Local aTamD2_QTD		:= TamSx3("D2_QUANT")			// Tamanho do campo D2_QUANT
Local aTamD2_PRC		:= TamSx3("D2_PRCVEN")			// Tamanho do campo D2_PRCVEN
Local aTamD2_TOT		:= TamSx3("D2_TOTAL")			// Tamanho do campo D2_TOTAL
Local aTamD2_UM			:= TamSx3("D2_UM")				// Tamanho do campo D2_UM
Local aTamD2_TES		:= TamSx3("D2_TES")				// Tamanho do campo D2_TES
Local aTamD2_DOC		:= TamSx3("D2_DOC")				// Tamanho do campo D2_DOC
Local aTamD2_SERIE		:= TamSx3("D2_SERIE") 			// Tamanho do campo D2_SERIE
Local aTamD2_LOCAL		:= TamSx3("D2_LOCAL")			// Tamanho do campo D2_LOCAL
Local aTamD2_LOTECTL	:= TamSx3("D2_LOTECTL")			// Tamanho do campo D2_LOTECTL
Local aTamD2_NUMLOTE	:= TamSx3("D2_NUMLOTE")			// Tamanho do campo D2_NUMLOTE     
Local aTamD2_DTVALID	:= TamSx3("D2_DTVALID")			// Tamanho do campo D2_DTVALID   
Local aTamD2_FRE		:= TamSx3("D2_VALFRE")			// Tamanho do campo D2_VALFRE
Local aTamD2_SEG		:= TamSx3("D2_SEGURO")			// Tamanho do campo D2_SEGURO
Local aTamD2_DES		:= TamSx3("D2_DESPESA")			// Tamanho do campo D2_DESPESA
Local aTamL2_DSC		:= TamSx3("L2_VALDESC")			// Tamanho do campo L2_VALDESC
Local aTamL2_DCP		:= TamSx3("L2_DESCPRO")			// Tamanho do campo L2_DESCPRO
Local aTamD2_IPI		:= TamSx3("D2_VALIPI")			// Tamanho do campo D2_VALIPI
Local aTamD2_CGENE      := {}					        // Tamanho do campo D2_CODGENE  
Local lMv_Rastro		:= (SuperGetMv("MV_RASTRO", Nil, "N") == "S")		// Flag de verificacao do rastro
Local nX				:= 0
Local aTamD2_VALACRS	:= TamSx3("D2_VALACRS")			// Tamanho do campo D2_VALACRS
Local aTamD2_RET		:= TamSx3("D2_ICMSRET")			// Tamanho do campo D2_ICMSRET
Local aTamD2_PRUN		:= TamSx3("D2_PRUNIT")			// Tamanho do campo D2_PRUNIT

If Hastemplate("OTC")
	aTamD2_CGENE   := TamSx3("D2_CODGENE")
Endif

AADD(aHeaderSD2, {STR0028, "TRB_ITEM",   PesqPict("SD2","D2_ITEM"),   aTamD2_ITEM[1], aTamD2_ITEM[2], "", USADO, "C", "", " "})																					// "Item"
AADD(aHeaderSD2, {STR0019, "TRB_CODPRO", PesqPict("SD2","D2_COD"),    aTamD2_COD[1],  aTamD2_COD[2],  "NaoVazio() .AND. Lj720VldProd(M->TRB_CODPRO,TRB->TRB_QUANT)", USADO, "C", "SB1", " "})					// "Produto"
AADD(aHeaderSD2, {STR0029, "TRB_DESPRO", PesqPict("SB1","B1_DESC"),   aTamB1_DESC[1], aTamB1_DESC[2], "", USADO,"C", nil, " "})																					// "Descrição"
AADD(aHeaderSD2, {STR0020, "TRB_QUANT",  PesqPict("SD2","D2_QUANT"),  aTamD2_QTD[1],  aTamD2_QTD[2],  "NaoVazio() .AND. Positivo() .AND. Lj720Trigger('TRB_QUANT',M->TRB_QUANT)",   USADO	, "N", nil, " "})	// "Quantidade"
AADD(aHeaderSD2, {STR0021, "TRB_PRCVEN", PesqPict("SD2","D2_PRCVEN"), aTamD2_PRC[1],  aTamD2_PRC[2],  "NaoVazio() .AND. Positivo() .AND. Lj720Trigger('TRB_PRCVEN',M->TRB_PRCVEN)", USADO	, "N", nil, " "})	// "Preço Unitario"
AADD(aHeaderSD2, {STR0156, "TRB_VALACR", PesqPict("SD2","D2_VALACRS"),aTamD2_VALACRS[1],aTamD2_VALACRS[2],  "Positivo()", USADO, "N", nil, " "} )																// "Vl Acrescimo"
AADD(aHeaderSD2, {STR0022, "TRB_VLRTOT", PesqPict("SD2","D2_TOTAL"),  aTamD2_TOT[1],  aTamD2_TOT[2],  " ", USADO, "N", nil, " "} )																				// "Valor do Item"
AADD(aHeaderSD2, {STR0212, "TRB_VALIPI", PesqPict("SD2","D2_VALIPI"), aTamD2_IPI[1],  aTamD2_IPI[2],  " ", USADO, "N", Nil, " "} )																				// "Valor do IPI"
AADD(aHeaderSD2, {STR0023, "TRB_UM",     PesqPict("SD2","D2_UM"),     aTamD2_UM[1],   aTamD2_UM[2],   " ", USADO, "C", nil, " "} )																				// "Unidade"
AADD(aHeaderSD2, {STR0030, "TRB_TES",    PesqPict("SD2","D2_TES"),    aTamD2_TES[1],  aTamD2_TES[2],  "NaoVazio() .AND. ExistCpo('SF4')", USADO, "C", "SF4", " "} )												// "TES"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona campos referentes ao Walk-Trhu³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AdHeadRec( "TRB", aHeaderSD2 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver utilizando rastreablidade, mostra os campos de ³
//³controle de lote.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMv_Rastro
	AADD(aHeaderSD2,{STR0107	,"TRB_LOTECT"	,PesqPict("SD2","D2_LOTECTL")	,aTamD2_LOTECTL[1]	,aTamD2_LOTECTL[2]	," ",USADO,"C",""," "} ) 	 //"Lote"
	AADD(aHeaderSD2,{STR0108	,"TRB_NUMLOT"	,PesqPict("SD2","D2_NUMLOTE")	,aTamD2_NUMLOTE[1]	,aTamD2_NUMLOTE[2]	," ",USADO,"C",""," "} ) 	 //"Sub Lote"
	AADD(aHeaderSD2,{STR0109	,"TRB_DTVALI"	,PesqPict("SD2","D2_DTVALID")	,aTamD2_DTVALID[1]	,aTamD2_DTVALID[2]	," ",USADO,"D",""," "} )	 //"Validade do lote"	
Endif

AADD(aStruTRB,{"TRB_ITEM"		,"C",aTamD2_ITEM[1]			,aTamD2_ITEM[2]		})
AADD(aStruTRB,{"TRB_CODPRO"		,"C",aTamD2_COD[1]			,aTamD2_COD[2]		})
AADD(aStruTRB,{"TRB_DESPRO" 	,"C",aTamB1_DESC[1]			,aTamB1_DESC[2]		})
AADD(aStruTRB,{"TRB_QUANT" 		,"N",aTamD2_QTD[1]			,aTamD2_QTD[2]		})
AADD(aStruTRB,{"TRB_PRCVEN"		,"N",aTamD2_PRC[1]			,aTamD2_PRC[2]		})
AADD(aStruTRB,{"TRB_VLRTOT"		,"N",aTamD2_TOT[1]			,aTamD2_TOT[2]		})
AADD(aStruTRB,{"TRB_UM"			,"C",aTamD2_UM[1] 			,aTamD2_UM[2] 		})
AADD(aStruTRB,{"TRB_TES"   		,"C",aTamD2_TES[1]			,aTamD2_TES[2]		})
AADD(aStruTRB,{"TRB_NFORI"  	,"C",aTamD2_DOC[1]			,aTamD2_DOC[2]		})
AADD(aStruTRB,{"TRB_SERORI" 	,"C",aTamD2_SERIE[1] 		,aTamD2_SERIE[2]  	})
AADD(aStruTRB,{"TRB_LOCAL"	 	,"C",aTamD2_LOCAL[1] 		,aTamD2_LOCAL[2]  	})     
AADD(aStruTRB,{"TRB_QTDORI" 	,"N",aTamD2_QTD[1]			,aTamD2_QTD[2]		}) //Quantidade original vendida
AADD(aStruTRB,{"TRB_VFRETE"	 	,"N",aTamD2_FRE[1]			,aTamD2_FRE[2]		}) //Valor do Frete proporcional no item 
AADD(aStruTRB,{"TRB_VDESPE"	 	,"N",aTamD2_DES[1]			,aTamD2_DES[2]		}) //Valor da despesa proporcional no item
AADD(aStruTRB,{"TRB_VSEGUR"	 	,"N",aTamD2_SEG[1]			,aTamD2_SEG[2]		}) //Valor do Seguro proporcional no item
AADD(aStruTRB,{"TRB_VLRDES"	 	,"N",aTamL2_DSC[1]			,aTamL2_DSC[2]		}) //Valor do Desconto no item
AADD(aStruTRB,{"TRB_VRDESP"	 	,"N",aTamL2_DCP[1]			,aTamL2_DCP[2]		}) //Valor do Desconto proporcional do item
AADD(aStruTRB,{"TRB_VALIPI"	 	,"N",aTamD2_IPI[1]			,aTamD2_IPI[2]		})	//Valor do IPI
aAdd(aStruTRB,{"TRB_ICMSRE"		,"N",aTamD2_RET[1]			,aTamD2_RET[2]      })	//Valor do retorno de ICMS - Subst. Tributária
AADD(aStruTRB,{"TRB_PRUNIT"		,"N",aTamD2_PRUN[1]			,aTamD2_PRUN[2]		})  //Valor unitário do produto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver utilizando rastreablidade, mostra os campos de ³
//³controle de lote.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMv_Rastro
	AADD(aStruTRB,{"TRB_LOTECT" 	,"C",aTamD2_LOTECTL[1]		,aTamD2_LOTECTL[2]})  
	AADD(aStruTRB,{"TRB_NUMLOT" 	,"C",aTamD2_NUMLOTE[1]		,aTamD2_NUMLOTE[2]})   
	AADD(aStruTRB,{"TRB_DTVALI" 	,"D",aTamD2_DTVALID[1]		,aTamD2_DTVALID[2]})
	AADD(aStruTRB,{"TRB_RECNO"      ,"N",10						,0                })
	AADD(aStruTRB,{"TRB_FLAG"       ,"L",1						,0                })
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona campos referentes ao Walk-Trhu³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aStruTRB,{"TRB_REC_WT"		,"N",10						,0                })
	aAdd(aStruTRB,{"TRB_ALI_WT"		,"C",03						,0                })
	aAdd(aStruTRB,{"TRB_RECPAI"		,"N",10						,0                })
Else
	AADD(aStruTRB,{"TRB_RECNO"      ,"N",10						,0                })
	AADD(aStruTRB,{"TRB_FLAG"       ,"L",1						,0                })
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona campos referentes ao Walk-Trhu³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aStruTRB,{"TRB_REC_WT"		,"N",10						,0                })
	aAdd(aStruTRB,{"TRB_ALI_WT"		,"C",03						,0                })
	aAdd(aStruTRB,{"TRB_RECPAI"		,"N",10						,0                })
EndIf	

 If Hastemplate ("OTC")
    AADD(aStruTRB,{"TRB_CODGEN" 	,"C", aTamD2_CGENE[1]		,aTamD2_CGENE[2]  })  
    aAdd(aStruTRB,{"TRB_VALACR" 	,"N", aTamD2_VALACRS[1]		,aTamD2_VALACRS[2]})
 Else
 	aAdd(aStruTRB,{"TRB_VALACR" 	,"N", aTamD2_VALACRS[1]		,aTamD2_VALACRS[2]})
 EndIf
 
//+-------------------------------------------+
//|Ponto de Entrada para modificar a estrutura|
//+-------------------------------------------+
If ExistFunc("U_LJ720STR")
   xRet  := U_LJ720STR(aHeaderSD2, aStruTRB)
   If ValType(xRet) == "A" .AND. Len(xRet) == 2 .AND. ValType(xRet[1]) == "A" .AND. ValType(xRet[2]) == "A"
      For nX := 1 To Len(xRet[1])
      	If ValType(xRet[1, nX]) == "A" .AND. Len(xRet[1, nX]) == 10
				aAdd(aHeaderSD2, xRet[1, nX])
			EndIf
		Next
      For nX := 1 To Len(xRet[2])
      	If ValType(xRet[2, nX]) == "A" .AND. Len(xRet[2, nX]) == 5
				aAdd(aStruTRB, xRet[2, nX])
			EndIf
		Next
   Endif
EndIf 
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o tabela temporaria com base na estrutura³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable := LjCrTmpTbl(cAliasTRB, aStruTRB,{"TRB_RECNO","TRB_ITEM"})

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720GetDB  ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os dados na tabela temporaria de acordo com os    º±±
±±º          ³ produtos selecionados na NF de origem.                     º±±
±±º          ³ Executado no Next do panel 2 (MsSelect da selecao dos prod)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Array com os Recno de registros da tabela SD2       º±±
±±º          ³ExpA2 - Alias do arquivo de trabalho                        º±±
±±º          ³ExpO3 - Objeto da MsGetDB                                   º±±
±±º          ³ExpN4 - Recno da area de trabalho                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - VENDA ASSISTIDA                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720GetDB(aRecSd2, cAliasTRB, oGetdTRC, nRecnoTRB, cCodFil, nVlrTotal, lValTroca, cTesNfsR)
Local nX          := 0			// Contador do for
Local nI			:= 0			// Contador do for
Local lRet        := .T.		// Retorno da funcao
Local lSeek       := .T.		// Controle de lock na tabela de trabalho
Local cMV_LJDVACR := AllTrim(SuperGetMV("MV_LJDVACR",,""))  // Define se considera acrescimo financeiro na devolucao
Local lMv_Rastro  := (SuperGetMv( "MV_RASTRO", Nil, "N" ) == "S")		// Flag de verificacao do rastro
Local cFilSB1 	  := ""
Local lUsaGarant  := .F.		// Verifica se esta utilizando os campos obrigatorios da garantia Estendida
Local ljImpGf	  := SuperGetMv("MV_LJIMPGF",,.F.)
Local lSFinanc		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local aServFin	:= {}
Local nTotalItem	:= 0 //total do Item
Local nFrtSegDesIt	:= 0 //Frete Seguro Despesa do item
Local lNfsf			:= SuperGetMV("MV_LJVFNFS",,.F.) //Verifica se utiliza nota simples faturamento

lUsaGarant := SD2->(ColumnPos("D2_ITEMGAR") > 0 .AND. ColumnPos("D2_ORCGAR") > 0) .AND.SL2->(ColumnPos("L2_GARDEV") > 0) 


Default cCodFil   := cFilAnt
Default lValTroca := .F.

lQtDeDev := Lj720GetQt()

cFilSB1 := FWxFilial("SB1",cCodFil)

nVlrTotal := 0

DbSelectArea(cAliasTRB)
DbSetOrder(2)
DbGoTop()

(cAliasTRB)->(__dbZap())

If Len(aRecSD2) > 0
	ASort(aRecSD2,,,{|x,y| x[2]< y[2]})
Endif

For nX := 1 to Len(aRecSd2)

	DbSelectArea("SD2")
	SD2->(DbGoTo(aRecSd2[nX][2]))
	nTotalItem := 0
	nFrtSegDesIt	:= 0 
	
	If !aRecSd2[nX][3]  //Item
		RecLock(cAliasTRB,lSeek)
	
		//Posiciona no registro da tabela SL2
		Lj720PosL2(cCodFil, SD2->D2_DOC, SD2->D2_SERIE, SD2->D2_COD, SD2->D2_ITEMPV)
		
		REPLACE	TRB->TRB_CODPRO	WITH SD2->D2_COD
		REPLACE	TRB->TRB_ITEM	WITH SD2->D2_ITEM
		REPLACE	TRB->TRB_DESPRO	WITH Posicione("SB1",1,cFilSB1+SD2->D2_COD,"B1_DESC")
		REPLACE	TRB->TRB_QUANT 	WITH IIf(lValTroca,1,Max(SD2->D2_QUANT - SD2->D2_QTDEDEV, 0))
		REPLACE	TRB->TRB_QTDORI	WITH SD2->D2_QUANT
		REPLACE	TRB->TRB_VALIPI	WITH SD2->D2_VALIPI
		REPLACE	TRB->TRB_PRCVEN	WITH SD2->D2_PRCVEN //nesse campo não é feita a subtração do acréscimo, pois o acréscimo não é agregado ao valor unitário do item
		REPLACE	TRB->TRB_PRUNIT WITH SD2->D2_PRUNIT //Grava valor unitário do produto(sem acréscimo)

		LjGrvLog( "TROCA_DEVOLUCAO", "Valor Unitário Item - TRB->TRB_PRCVEN", TRB->TRB_PRCVEN)
		LjGrvLog( "TROCA_DEVOLUCAO", "Não incide ICMS sobre juros de operações financeiras - MV_LJICMJR", SuperGetMv("MV_LJICMJR",,.F.))

        //Caso for devolver a quantidade de saldo, faz a conta levando em consideração o valor já devolvido
        //Para não ter problemas de arredondamento quando utilizado mais de 2 casas decimais
        If !lValTroca
            REPLACE	TRB->TRB_VLRTOT	WITH SD2->D2_TOTAL - RetSldDev()
        Else
            REPLACE	TRB->TRB_VLRTOT	WITH A410Arred(TRB->TRB_QUANT * TRB->TRB_PRCVEN ,"D2_TOTAL")
        EndIf

		//Calculo quando o Juros esta seprado do Valor total (MV_LJICMJR):
		If cPaisLoc == "BRA" .And. SuperGetMv("MV_LJICMJR",,.F.)
		    REPLACE	TRB->TRB_PRUNIT WITH TRB->TRB_PRCVEN //Grava valor unitário do produto(sem acréscimo)		
		Else
			If SD2->D2_VALACRS > 0 
				REPLACE	TRB->TRB_VALACR	WITH SD2->D2_VALACRS
			Else
				REPLACE	TRB->TRB_VALACR	WITH A410Arred(LJ720VlAcresc(SD2->D2_SERIE+SD2->D2_DOC, (TRB->TRB_QUANT * TRB->TRB_PRCVEN),cCodFil) ,"D2_VALACRS")		
			EndIf

			If TRB->TRB_PRCVEN == TRB->TRB_PRUNIT 
            	REPLACE	TRB->TRB_VLRTOT	WITH TRB->TRB_VLRTOT + TRB->TRB_VALACR
			EndIf 	
		EndIf

		LjGrvLog( "TROCA_DEVOLUCAO", "Valor Total Item - TRB->TRB_VLRTOT", TRB->TRB_VLRTOT)
	
		REPLACE	TRB->TRB_UM    	WITH SD2->D2_UM
		REPLACE	TRB->TRB_TES   	WITH SD2->D2_TES
		REPLACE	TRB->TRB_NFORI 	WITH SD2->D2_DOC
		REPLACE	TRB->TRB_SERORI	WITH SD2->D2_SERIE

		/*
		|| Em devoluções os valores de Frete, Seguro e Despesa são somados e incluso no campo Despesa conforme definição Fiscal:
		|| https://tdn.totvs.com/pages/releaseview.action?pageId=440834321
		*/
		REPLACE	TRB->TRB_VDESPE	WITH SD2->D2_DESPESA + SD2->D2_VALFRE + SD2->D2_SEGURO

		REPLACE	TRB->TRB_VLRDES	WITH SL2->L2_VALDESC
		REPLACE	TRB->TRB_VRDESP	WITH SL2->L2_DESCPRO
	
		If lMv_Rastro
			REPLACE	TRB->TRB_LOTECT	WITH SD2->D2_LOTECTL
			REPLACE	TRB->TRB_NUMLOT	WITH SD2->D2_NUMLOTE
			REPLACE	TRB->TRB_DTVALI WITH SD2->D2_DTVALID
		EndIf
	
		REPLACE	TRB->TRB_LOCAL 	WITH SD2->D2_LOCAL
		REPLACE	TRB->TRB_RECNO 	WITH aRecSd2[nX][2] 
		REPLACE TRB->TRB_REC_WT	WITH SD2->( Recno() )
		REPLACE TRB->TRB_ALI_WT	WITH "SD2"
		If HasTemplate("OTC")
			REPLACE TRB->TRB_CODGENE WITH SD2->D2_CODGENE
		EndIf		
	   	REPLACE TRB->TRB_ICMSRE WITH SD2->D2_ICMSRET 

		MsUnlock()
		
		If !lNfSf .OR. TRB->TRB_TES <> cTesNfsR
			nVlrTotal += (TRB->TRB_VLRTOT + TRB->TRB_VALIPI)
		EndIf
		
		nTotalItem := (TRB->TRB_VLRTOT + TRB->TRB_VALIPI)

		/*
		|| Em devoluções os valores de Frete, Seguro e Despesa são somados e incluso no campo Despesa conforme definição Fiscal:
		|| https://tdn.totvs.com/pages/releaseview.action?pageId=440834321
		*/
		nFrtSegDesIt :=  ( (TRB->TRB_VDESPE / TRB->TRB_QTDORI) * TRB->TRB_QUANT)
	    
		oGetdTRC:nCount++
	EndIf
	
	 //Grantia Estendida/Servico Financeiro  
	 // ljImpGf = .f. , eh porque imprimiu no cupom fiscal e esta na d2 , enta nao precisa avisar
	If (lUsaGarant .AND. ljImpGf) .OR. lSFinanc 
		//Busca Itens Servicos Financeiros
		If lSFinanc
			aServFin := Lj720SrvFin(cCodFil)
		EndIf
		
		SL2->(dbSetOrder(1))
		
		If !Empty(SD2->D2_ITEMGAR)
			If ljImpGf .Or. aRecSd2[nX][3]						
				If(SL2->(dbSeek(FWxFilial("SL2",cCodFil)+ SD2->D2_ORCGAR + SD2->D2_ITEMGAR))) .AND. ( Empty(SL2->L2_GARDEV) .OR. If(lQtDeDev,SL2->L2_QTDEDEV < SL2->L2_QUANT,.F.))  
					RecLock(cAliasTRB,lSeek)
					
					REPLACE	TRB->TRB_CODPRO	WITH SL2->L2_PRODUTO
					REPLACE	TRB->TRB_ITEM	WITH SL2->L2_ITEM
					REPLACE	TRB->TRB_DESPRO	WITH Posicione("SB1",1,cFilSB1+SL2->L2_PRODUTO,"B1_DESC")
					REPLACE	TRB->TRB_QUANT 	WITH IIf(lValTroca,1,If(lQtDeDev,SL2->L2_QUANT-SL2->L2_QTDEDEV,1))
					REPLACE	TRB->TRB_QTDORI	WITH SL2->L2_QUANT
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se  parâmetro MV_LJDVACR=="1" Deve desconsiderar o acrescimo financeiro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cMV_LJDVACR == "1"
						REPLACE	TRB->TRB_PRCVEN	WITH SL2->L2_VRUNIT - SL2->L2_VALACRS
					Else
						REPLACE	TRB->TRB_PRCVEN	WITH SL2->L2_VRUNIT
					Endif
				
					//Calculo quando o Juros esta seprado do Valor total (MV_LJICMJR):
					If cPaisLoc == "BRA" .And. SuperGetMv("MV_LJICMJR",,.F.)
						REPLACE	TRB->TRB_VALACR	WITH A410Arred(LJ720VlAcresc(SD2->D2_SERIE+SD2->D2_DOC, (TRB->TRB_QUANT * TRB->TRB_PRCVEN),cCodFil) ,"D2_VALACRS")
						REPLACE	TRB->TRB_VLRTOT	WITH A410Arred((TRB->TRB_QUANT * TRB->TRB_PRCVEN)+TRB->TRB_VALACR ,"D2_TOTAL")
					Else
						REPLACE	TRB->TRB_VLRTOT	WITH A410Arred(TRB->TRB_QUANT * TRB->TRB_PRCVEN ,"D2_TOTAL")
					EndIf
				
					REPLACE	TRB->TRB_UM    	WITH SL2->L2_UM
					REPLACE	TRB->TRB_TES   	WITH SL2->L2_TES
					REPLACE	TRB->TRB_NFORI 	WITH SL2->L2_DOC
					REPLACE	TRB->TRB_SERORI	WITH SL2->L2_SERIE
				
					If lMv_Rastro
						REPLACE	TRB->TRB_LOTECT	WITH SL2->L2_LOTECTL
						REPLACE	TRB->TRB_NUMLOT	WITH SL2->L2_NLOTE
						REPLACE	TRB->TRB_DTVALI WITH SL2->L2_DTVALID
					EndIf
				
					REPLACE	TRB->TRB_LOCAL 	WITH SL2->L2_LOCAL
					REPLACE	TRB->TRB_RECNO 	WITH aRecSd2[nX][2]+1 
					REPLACE TRB->TRB_REC_WT	WITH SL2->( Recno() )
					REPLACE TRB->TRB_ALI_WT	WITH "SL2" 
					REPLACE TRB->TRB_RECPAI	WITH SD2->( Recno() )
					If HasTemplate("OTC")
						REPLACE TRB->TRB_CODGENE WITH SL2->L2_CODGENE
					EndIf			
					MsUnlock()
					
					nVlrTotal += TRB->TRB_VLRTOT
					nTotalItem += TRB->TRB_VLRTOT
				
					oGetdTRC:nCount++
				EndIf
			EndIf									
		ElseIf Len(aServFin) > 0
			For nI := 1 To Len(aServFin)
				If SL2->(dbSeek(FWxFilial("SL2", cCodFil) + aServFin[nI][1] + aServFin[nI][2] + aServFin[nI][3]))
					RecLock(cAliasTRB,lSeek)
				
					REPLACE	TRB->TRB_CODPRO	WITH SL2->L2_PRODUTO
					REPLACE	TRB->TRB_ITEM	WITH SL2->L2_ITEM
					REPLACE	TRB->TRB_DESPRO	WITH Posicione("SB1",1,cFilSB1+SL2->L2_PRODUTO,"B1_DESC")
					REPLACE	TRB->TRB_QUANT 	WITH IIf(lValTroca,1,If(lQtDeDev,SL2->L2_QUANT-SL2->L2_QTDEDEV,1))
					REPLACE	TRB->TRB_QTDORI	WITH SL2->L2_QUANT
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se  parâmetro MV_LJDVACR=="1" Deve desconsiderar o acrescimo financeiro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cMV_LJDVACR == "1"
						REPLACE	TRB->TRB_PRCVEN	WITH SL2->L2_VRUNIT - SL2->L2_VALACRS
					Else
						REPLACE	TRB->TRB_PRCVEN	WITH SL2->L2_VRUNIT
					EndIf
			
					//Calculo quando o Juros esta seprado do Valor total (MV_LJICMJR):
					If cPaisLoc == "BRA" .And. SuperGetMv("MV_LJICMJR",,.F.)
						REPLACE	TRB->TRB_VALACR	WITH A410Arred(LJ720VlAcresc(SD2->D2_SERIE+SD2->D2_DOC, (TRB->TRB_QUANT * TRB->TRB_PRCVEN), cCodFil) ,"D2_VALACRS")
						REPLACE	TRB->TRB_VLRTOT	WITH A410Arred((TRB->TRB_QUANT * TRB->TRB_PRCVEN)+TRB->TRB_VALACR ,"D2_TOTAL")
					Else
						REPLACE	TRB->TRB_VLRTOT	WITH A410Arred(TRB->TRB_QUANT * TRB->TRB_PRCVEN ,"D2_TOTAL")
					EndIf
			
					REPLACE	TRB->TRB_UM    	WITH SL2->L2_UM
					REPLACE	TRB->TRB_TES   	WITH SL2->L2_TES
					REPLACE	TRB->TRB_NFORI 	WITH SL2->L2_DOC
					REPLACE	TRB->TRB_SERORI	WITH SL2->L2_SERIE
			
					If lMv_Rastro
						REPLACE	TRB->TRB_LOTECT	WITH SL2->L2_LOTECTL
						REPLACE	TRB->TRB_NUMLOT	WITH SL2->L2_NLOTE
						REPLACE	TRB->TRB_DTVALI WITH SL2->L2_DTVALID
					EndIf
			
					REPLACE	TRB->TRB_LOCAL 	WITH SL2->L2_LOCAL
					REPLACE	TRB->TRB_RECNO 	WITH aRecSd2[nX][2]+1 
					REPLACE TRB->TRB_REC_WT	WITH SL2->( Recno() )
					REPLACE TRB->TRB_ALI_WT	WITH "SL2" 
					REPLACE TRB->TRB_RECPAI	WITH SD2->( Recno() )
					
					If HasTemplate("OTC")
						REPLACE TRB->TRB_CODGENE WITH SL2->L2_CODGENE
					EndIf			
					
					MsUnlock()
				
					nVlrTotal += TRB->TRB_VLRTOT
					nTotalItem += TRB->TRB_VLRTOT				
					oGetdTRC:nCount++	
				EndIf
			Next nI
		EndIf
	EndIf
	
	aRecSd2[nX][4] := nTotalItem
	aRecSd2[nX][5] := nFrtSegDesIt
Next nX

DbSelectArea(cAliasTRB)
DbSetOrder(2)
oGetdTRC:nMax:=(cAliasTRB)->(RecCount())
DbGoTop()

nRecnoTRB  := Recno()

oGetdTRC:oBrowse:Refresh()
oGetdTRC:ForceRefresh()
oGetdTRC:oBrowse:SetFocus()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj720GetOk  ºAutor  ³ Vendas Cliente   º Data ³  08/23/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os itens digitados ou selecionados no panel 3       º±±
±±º          ³que contem os produtos a serem trocados/devolvidos.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Alias do arquivo temporario.                        º±±
±±º          ³ExpA2 - Array com o Recno e a quantidade a ser devolvida    º±±
±±º          ³ExpN3 - Valor total de mercadorias.                         º±±
±±º          ³ExpN4 - Recno da area de trabalho                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj720GetOk( cAliasTRB  ,aRecSD2   ,nVlrTotal  ,nRecnoTRB,;
								nNfOrig, cCodFil  ,lCalTot  ) 

Local lRet			:= .T.       								// Retorno da funcao
Local aAreaTRB		:= (cAliasTRB)->(GetArea())   				// Guarda a area
Local cCampos		:= "TRB_UM/TRB_TES/TRB_ALI_WT/TRB_REC_WT"	// Campos que nao sao obrigatorios
Local nPos			:= 0										// Posicao do Recno.
Local nX			:= 0										// Controle do For 
Local lContinua 	:= .T.										// Se passa para a proxima tela
Local cMV_LJDVACR	:= AllTrim(SuperGetMV("MV_LJDVACR",,""))  	// Define se considera acrescimo financeiro na devolucao
Local lMv_Rastro	:= If( SuperGetMv( "MV_RASTRO", Nil, "N" ) == "S", .T., .F. )	// Flag de verificacao do rastro
Local lGE			:= ExistFunc("LjUP104OK") .AND. LjUP104OK() 			// Indica se o release e 11.5
Local lSFinanc		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local cMvLjTSF		:= SuperGetMV("MV_LJTPSF",,"SF") 					// Define se é tipo SF
Local lAtuEstoque	:= .T.												// Valida se a TES controla ou nao estoque
Local cTesNfsR		:= SuperGetMV("MV_LJTESPE",,"") 					//TES utilizada para a geracao da nota fiscal de simples Remesa
Local lNfsf			:= SuperGetMV("MV_LJVFNFS",,.F.) //Verifica se utiliza nota simples faturamento

Default lCalTot := .F.

LjGrvLog( "TROCA_DEVOLUCAO", "Define se considera acrescimo financeiro na devolucao - MV_LJDVACR", cMV_LJDVACR)
LjGrvLog( "TROCA_DEVOLUCAO", "Define se é tipo SF - MV_LJTPSF", cMvLjTSF)

If !lCalTot
	lQtDeDev := Lj720GetQt()
	
	DbSelectArea(cAliasTRB)
	DbGoTo(nRecnoTRB)
	If TRB->(Eof())
		lRet:= .F.
		MsgStop(STR0049,STR0033)//"Algum campo obrigatório não foi informado." ##"Atenção"
	Else
		DbGoTo(nRecnoTRB)
		While TRB->(!Eof()) .AND. lContinua
			If !TRB->TRB_FLAG .AND. !Empty(TRB->TRB_CODPRO)
				lContinua := .F.
			Endif
			TRB->(DbSkip())		
		End
		If lContinua 
			lRet:= .F.	
			MsgStop(STR0049,STR0033)//"Algum campo obrigatório não foi informado." ##"Atenção"
		Endif
	Endif
EndIf

If cMV_LJDVACR == "1"

	DbGoTo(nRecnoTRB)	
	While !Eof() .AND. lRet
	
		If nNfOrig == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para Devol sem doc de entrada , valida se o codigo do prod ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        	If !TRB->TRB_FLAG .AND. Empty( TRB->TRB_CODPRO ) 
				RecLock("TRB",.F.)     	
				REPLACE TRB_FLAG WITH .T.          // Marca como deletado
				MsUnlock()
			EndIf

			If !TRB->TRB_FLAG
				If !Empty(TRB->TRB_RECNO)
					nPos := Ascan( aRecSD2, {|x| x[2]  == TRB->TRB_RECNO } )  
			        If nPos > 0
			        	If aRecSD2[nPos][1] <> TRB->TRB_QUANT
							lRet := .F.
							//"O parâmetro MV_LJDVACR está habilitado. Não será possível realizar uma devolução parcial, somente total."
							MsgAlert(STR0087)
						EndIf
			        Endif
			    Endif    	
			Endif    
	    
	    Else
			If !TRB->TRB_FLAG .AND. !lCalTot
				If !Empty(TRB->TRB_RECNO)
					nPos := Ascan( aRecSD2, {|x| x[2]  == TRB->TRB_RECNO } )  
			        If nPos > 0
			        	If aRecSD2[nPos][1] <> TRB->TRB_QUANT
							lRet := .F.
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³"O parâmetro MV_LJDVACR está habilitado. Não será possível realizar uma devolução parcial, somente total."³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							MsgAlert(STR0087)
						EndIf
			        Endif
			    Endif    	
            EndIf
		EndIf
    
		DbSkip()    	
	    Loop
    End

Else

	DbGoTo(nRecnoTRB)	
	While !Eof() .AND. lRet
	    
	    If nNfOrig == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para Devol sem doc de entrada , valida se o codigo do prod ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        	If !TRB->TRB_FLAG .AND. Empty( TRB->TRB_CODPRO ) 
				RecLock("TRB",.F.)     	
				REPLACE TRB_FLAG WITH .T.		// Marca como deletado
				MsUnlock()
			EndIf
			
			If !TRB->TRB_FLAG
				If (SuperGetMv("MV_LJFNGE",,.F.) .AND. lGe .And. ExistFunc("LJ7GrvMFI") .And. AliasIndic("MFI")) .OR. lSFinanc 
					
					//Valida o valor a ser pago para o cliente com garantia estendida
					SL2->(DbSetOrder(3))			//L2_FILIAL+L2_SERIE+L2_DOC+L2_PRODUTO
					If SL2->(DbSeek(FWxFilial("SL2",cCodFil)+TRB->TRB_SERORI+TRB->TRB_NFORI+TRB->TRB_CODPRO+TRB->TRB_ITEM))
						SB1->(DbSetOrder(1))		//B1_FILIAL+B1_COD
						SB1->(DbSeek(FWxFilial("SB1", cCodFil)+TRB->TRB_CODPRO))
						//Valida se o produto eh garantia/servico financeiro
						If (lGe .AND. SB1->B1_TIPO == 'GE') .OR. (lSFinanc .AND. SB1->B1_TIPO == cMvLjTSF)
							MFI->(DbSetOrder(2))	//MFI_FILIAL+MFI_FILORI+MFI_DOC+MFI_SERIE+MFI_ITEM
							//Efetua as conficoes de vigencia para somar no valor total
							If MFI->(DbSeek(xFilial("MFI",cCodFil)+cFilAnt+TRB->TRB_NFORI+TRB->TRB_SERORI+TRB->TRB_ITEM))//verifica aqui a filial origem								
								//Valida se esta na vigencia
								If MFI->MFI_DTVIGE < dDataBase .And. dDataBase <= MFI->MFI_FIMVIG 
									nVlrTotal+=	MFI->MFI_VLRITE - ( (MFI->MFI_VLRITE/MFI->MFI_DIAGAR)*(dDataBase-MFI->MFI_DTVIGE) ) 
								ElseIf dDataBase > MFI->MFI_FIMVIG 
									nVlrTotal+= 0
								ElseIf  MFI->MFI_DTVIGE > dDataBase
									nVlrTotal+= TRB_VLRTOT	
								EndIf	
							EndIf
						EndIf
						
					EndIf			

			    EndIf
				
				//Calculo quando o Juros esta seprado do Valor total (MV_LJICMJR):
				If cPaisLoc == "BRA" .And. SuperGetMv("MV_LJICMJR",,.F.)
					nVlrTotal-=	TRB->TRB_VALACR
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza no array aRecSD2 a quantidade a ser devolvida de acordo com o que foi digitado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(TRB->TRB_RECNO)
					nPos := Ascan( aRecSD2, {|x| x[2] == TRB->TRB_RECNO } )  
			        If nPos > 0
			        	aRecSD2[nPos][1]:= TRB->TRB_QUANT
			        Endif
			    Endif    	
				
				For nX:= 1 to Len(aHeader)
			    	If Empty(&(aHeader[nX][2])) .AND. !(AllTrim(aHeader[nX][2]) $ cCampos) .AND. Rastro( TRB->TRB_CODPRO, "S" ) 
			    		lRet:= .F.
			    		MsgStop(STR0049,STR0033)//"Algum campo obrigatório não foi informado." ##"Atenção"
			    		Exit
			    	Endif	
				Next nX
				If lMv_Rastro
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se os produtos da troca/devolucao possuem controle³
					//³de lote e/ou sub-lote.                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nX:= 1 to Len(aHeader)
				    	If ( aHeader[nX][2] == "TRB_NUMLOT" .AND. Empty(&(aHeader[nX][2])) .AND.  Rastro( TRB->TRB_CODPRO, "S" ) ) .OR.; 
				    		( aHeader[nX][2] == "TRB_LOTECT" .AND. Empty(&(aHeader[nX][2])) .AND.  Rastro( TRB->TRB_CODPRO ) ) 
				    		lRet:= .F.
				    		MsgStop(STR0113,STR0033)//"Numero do lote/sub-lote nao informado." ##"Atenção"
				    		Exit
				    	Endif	 
					Next nX   
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se o produto usa Rastreabilidade, se nao usar deve³
					//³zerar o TRB->TRB_DTVALI.                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If !Rastro( TRB->TRB_CODPRO )
						RecLock("TRB",.F.)     	
						REPLACE TRB_DTVALI WITH CToD( " " ) 
						MsUnlock()
					EndIf	
				EndIf
			Endif    
		Else
			If !TRB->TRB_FLAG
				
				If !lNfSf .OR. TRB->TRB_TES <> cTesNfsR
					//Aqui, se nVlrTotal tiver valor atribuido, não será somado
					If nVlrTotal == 0
						nVlrTotal += (TRB_VLRTOT + TRB_VALIPI)
					EndIf	
				EndIf

				//Calculo quando o Juros esta seprado do Valor total (MV_LJICMJR):
				If cPaisLoc == "BRA" .And. SuperGetMv("MV_LJICMJR",,.F.)								
					If TRB->TRB_PRCVEN == TRB->TRB_PRUNIT
						nVlrTotal-=	TRB->TRB_VALACR  // Quando o acréscimo for gravado da tabela SL4 é subtraído do Valor total
					EndIf	
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza no array aRecSD2 a quantidade a ser devolvida de acordo com o que foi digitado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(TRB->TRB_RECNO) .AND. !lCalTot
					nPos := Ascan( aRecSD2, {|x| x[2] == TRB->TRB_RECNO } )  
			        If nPos > 0
			        	aRecSD2[nPos][1]:= TRB->TRB_QUANT
			        	
			        ElseIf TRB->TRB_ALI_WT == "SL2" .AND. !lQtDeDev // Nao Permite atualizar a quantidade da Garantia Estendida
		        		RecLock("TRB",.F.)
		         		TRB->TRB_QUANT := 1 
		         		MsUnlock() 
			        Endif
			        
			    Endif    	
				
				If lMV_Rastro .AND. !lCalTot .AND. Rastro(TRB->TRB_CODPRO)

					lAtuEstoque := Posicione("SF4",1,xFilial("SF4")+ TRB->TRB_TES ,"F4_ESTOQUE") == "S"

					If	lAtuEstoque			
						For nX:= 1 to Len(aHeader)
							If AllTrim(aHeader[nX][2]) == "TRB_LOTECT" .AND. Rastro(TRB->TRB_CODPRO, "L") .AND. Empty(TRB->TRB_LOTECT)
		                    	lRet := .F.
							ElseIf AllTrim(aHeader[nX][2]) == "TRB_NUMLOT" .AND. Rastro(TRB->TRB_CODPRO, "S") .AND. Empty(TRB->TRB_NUMLOT)
								lRet := .F.
					    	Endif	
							If !lRet
								Exit
							EndIf
						Next nX
					EndIf	
					If !lRet
				    	MsgStop(STR0049,STR0033)//"Algum campo obrigatório não foi informado." ##"Atenção"
					EndIf
				EndIf 
			EndIf									
		Endif    
	
		DbSkip()
	End
EndIf

RestArea(aAreaTRB)
Return (lRet)
                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720MsSelOkºAutor  ³ Vendas Cliente   º Data ³  08/23/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se os itens selecionados na MsSelect pertencem ao   º±±
±±º          ³mesmo documento de saida.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1: Array com os recnos da tabela SD2                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720MsSelOk(aRecSD2, lLegMotDev, nTpProc, cCodFil)

Local aAreaSD2	:= SD2->(GetArea())     	// Area atual do SD2
Local aAreaSF2	:= {}						// area atual da SF2
Local aLegId73	:= LjAnalisaLeg(73)
Local lRet		:= .T.                  	// Retorno da funcao
Local cDoc		:= ""                   	// Numero do documento de NF original
Local nX		:= 0                    	// Controle de loop
Local nOpcao	:= 0						// usado para verificar a escolha da função Aviso()
Local lF1Motivo	:= SF1->(ColumnPos("F1_MOTIVO")) > 0
Local lEComm	:= SuperGetMV("MV_LJECOMM",,.F.) //e-commerce habilitado?  
Local lECCia  := SuperGetMV("MV_LJECOMO",,.F.)
Local lVendaEc	:= .f. //Venda e-commerce

Default aRecSD2		:= {}
Default lLegMotDev	:= .F.
                                 
If Len(aRecSD2) > 0
	
	For nX:= 1 to Len(aRecSD2)
		        
		DbSelectArea("SD2")
		DbGoTo(aRecSD2[nX][2])
		
		If Empty(cDoc)
			cDoc:= SD2->D2_DOC	
		Endif
		If lEComm .AND.  !lVendaEc  //Verifica se não existe ainda uma venda e-commerce
			lVendaEc := Lj720PedEc( SD2->D2_PEDIDO,, cCodFil, @lECCia)
		EndIf
		LjGrvLog( "TROCA_DEVOLUCAO", "Documentos selecionados - cDoc", cDoc)	
		If !Empty(cDoc) .AND. cDoc <> SD2->D2_DOC
			If (cPaisLoc <> "BRA" .OR. nTpProc == 1 )  .OR. (lVendaEc) //se for pedido e-commerce somente permite 1 item
				MsgStop(STR0050,STR0033)//"Favor selecionar apenas mercadorias que pertençam a um mesmo documento de saída"##"Atenção"
				lRet:= .F.
				Exit
			ElseIf !MsgNoYes(STR0213+ CRLF + STR0214)//"Foi selecionado itens pertencentes a mais de um documento de saída."##"Confirma a seleção?"
				lRet:= .F.
				Exit			
			EndIf
		Endif	
				   
	Next nX
EndIf
If Len(aRecSD2) = 0
	MsgAlert(STR0154) //"Pelo menos um item deve ser selecionado."
	lRet:= .F.
Endif

/* se for AM, verificamos se é a venda é NFC-e, pois nesse caso, deve-se informar alguns dados na tag <infAdFisco> */
If lRet .AND. aLegId73[1]
	
	aAreaSF2 := SF2->( GetArea() )
	cEspecie := Posicione( "SF2", 1, SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA, "F2_ESPECIE" )
	cEspecie := AllTrim( cEspecie )
	
	If cEspecie == "NFCE"
		If lF1Motivo	//se o campo existe, ativamos a legislacao para que o MsGet do motivo seja habilitado
			lLegMotDev := .T.
		Else			
			lRet := .F.
		EndIf
	EndIf		

	//se for NFC-e e o usuario nao tem o campo, informamos a legislação e ele decide se quer continuar a operação
	If !lRet

		nOpcao := Aviso(aLegID73[3][1]								,;	// regra
						aLegID73[4] + CRLF + CRLF +					; 
						"Para informar esses dados, execute o compatibilizador UPDLOJ49 para criar o " +; 
						"campo F1_MOTIVO. Altere seu tamanho conforme necessidade"	,;	//descricao da regra e solução
						{"Continuar", "Cancelar"}					,;	// botoes
						3											)	// tamanho

		//usuario desejou continuar sem informar o motivo da devolução
		If nOpcao == 1
			lRet := .T.
		EndIf
	EndIf
	
	RestArea(aAreaSF2)
EndIf

/* restauramos a area */
RestArea(aAreaSD2)

/* matamos o array para melhor gerenciamento de memoria */
aSize(aAreaSF2, 0)
aAreaSF2 := Nil

aSize(aAreaSD2, 0) 
aAreaSD2 := Nil

aSize(aLegID73, 0) 
aLegID73 := Nil

Return lRet


/*                        
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720CfgDbºAutor  ³ Vendas Cliente     º Data ³  08/23/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera a propriedade do objeto quando for alterado o       º±±
±±º          ³processo de troca.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Origem do documento de entrada.                     º±±
±±º          ³ExpO2 - Objeto da MsGetDB                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720CfgDb(nNfOrig, oGetdTRC , nPanel , aRecSd2)

Local lMv_Rastro 	:= (SuperGetMv( "MV_RASTRO", Nil, "N" ) == "S")		// Flag de verificacao do rastro.
Local nX			:= 0
Local nCount        := 0                                                // Contador
Local lConsPadr     := .F.                                              // Verifica se possui consulta padrao

Default nPanel 		:=	0
Default aRecSd2		:=  {}

Do Case

	Case nNfOrig == 1    //Com NF de Origem
		oGetdTRC:lNewLine 		:= .F.
		oGetdTRC:lDeleta  		:= .F.
		oGetdTRC:nMax     		:= 999
		oGetdTRC:aAlter			:= {"TRB_QUANT","TRB_TES"}   //Campos que podem ser alterados
		oGetdTRC:oBrowse:aAlter	:= {"TRB_QUANT","TRB_TES"}  
	Case nNfOrig == 2  	  // Sem NF de Origem		
		oGetdTRC:lNewLine 		:= .F.
		oGetdTRC:lDeleta  		:= .T.
		oGetdTRC:nMax     		:= 999
		oGetdTRC:aAlter			:= {"TRB_CODPRO","TRB_QUANT","TRB_PRCVEN","TRB_TES"} //Campos que podem ser alterados
		oGetdTRC:oBrowse:aAlter	:= {"TRB_CODPRO","TRB_QUANT","TRB_PRCVEN","TRB_TES"} //Campos que podem ser alterados
	   
		If lMv_Rastro 
			aAdd( oGetdTRC:aAlter, "TRB_LOTECT")
			aAdd( oGetdTRC:oBrowse:aAlter, "TRB_LOTECT") 
		Endif			
Endcase

//+------------------------------------------------+
//|Ponto de Entrada para permitir edicao de colunas|
//+------------------------------------------------+
If ExistFunc("U_LJ720ALT")
	xRet  := U_LJ720ALT(@lConsPadr)
    If ValType(xRet) == "A" .AND. Len(xRet) == 2 .AND. ValType(xRet[1]) == "A" .AND. ValType(xRet[2]) == "A" .AND. !lConsPadr
	  	For nX := 1 To Len(xRet[1])
	  		If ValType(xRet[1, nX]) == "C"
				aAdd(oGetdTRC:aAlter, xRet[1, nX])
			   
	   		EndIf	  
		Next
	   	For nX := 1 To Len(xRet[2])
	   		If ValType(xRet[2, nX]) == "C"
				aAdd(oGetdTRC:oBrowse:aAlter, xRet[2, nX])
			EndIf
		Next  
	ElseIf ValType(xRet) == "A" .AND. lConsPadr    // Caso possua consulta padrao F3
		For  nCount := 1 To Len(xRet)
	  		aAdd(oGetdTRC:aAlter, xRet[nCount,1][1])
			aAdd(oGetdTRC:oBrowse:aAlter, xRet[nCount,2][1])
			oGetdTRC:aInfo[xRet[nCount,3,1]][1] := xRet[nCount,4][1]
		Next nCount
	EndIf			  
EndIf

oGetdTRC:oBrowse:Refresh()
oGetdTRC:ForceRefresh()
	
If nPanel == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desmarca todos os produtos que foram marcados no panel de selecao de produtos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRecSD2) > 0
		For nX:= 1 to Len(aRecSD2)
			DbSelectArea("SD2")
			DbGoTo(aRecSD2[nX][2])
			RecLock("SD2",.F.)
			REPLACE	SD2->D2_OK WITH Space(Len(SD2->D2_OK))
			MsUnlock()                                                             
		Next nX
		aRecSD2:= {}
	Endif
EndIf	
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720TriggerºAutor  ³ Vendas Cliente     º Data ³  08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Gatilha o campo descricao do produto, UM e TES.           º±±
±±º          ³- Executa o calculo do valor total do item baseado na       º±±
±±º          ³ quantidade e no preco unitario digitado.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Campo a ser tratado                                 º±±
±±º          ³ExpC2 - Valor referente ao campo                            º±±
±±º          ³ExpN3 - Quantidade referente ao campo                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA.                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720Trigger( cCampo  ,cValor  ,nQuant )

Local lRet			:= 	.T.								// Retorno da funcao
Local cTesSai		:= SuperGetMV("MV_TESSAI")			// Pega do parametro o TES padrao para saida
Local cTesInt		:= ""								// Codigo do Tes de saida
Local cTabPrecos    := ""                               // Tabela de preco utilizada no caso de possuir cenario de venda
Local nPrcVenda     := ""                               // Preco de venda
Local cCliente      := ""                               // Cliente 
Local cLoja      	:= ""                               // Loja 
Local nMoeda        := 1                                // Moeda definada como 1 pois o cenario de venda somente existe para o Brasil
Local nQTDEDEV  	:= 0 
Local nRecAtual		:= 0
Local nQuantPai		:= 0
Local lSFinanc		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local cMvLjTSF		:= SuperGetMV("MV_LJTPSF",,"SF") 					    // Define se é tipo SF
Local lCenVenda		:= SuperGetMv("MV_LJCNVDA",,.F.)
Local cTabDef 		:= AllTrim(SuperGetMV('MV_TABPAD',.F.,'1'))	
Local nVlIpi		:= 0                                // Valor do IPI
Local nVlrTotAux    := 0

Default nQuant  	:= 1

lQtDeDev := Lj720GetQt()
     
If TRB->TRB_FLAG //Se tiver DELETADO nao permite alterar
	MsgStop(STR0153) //"Item excluído não pode ser alterado."
	lRet:= .F.
EndIf

If lRet
	
	Do Case
	
		Case cCampo $ "TRB_CODPRO"
	
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+cValor))
			cCliente := SA1->A1_COD
			cLoja    := SA1->A1_LOJA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Parametro da funcao MaTesInt               ³
			//³ExpN1 = Documento de 1-Entrada / 2-Saida   ³
			//³ExpC1 = Tipo de Operacao Tabela "DJ" do SX5³
			//³ExpC2 = Codigo do Cliente ou Fornecedor    ³
			//³ExpC3 = Codigo do gracao E-Entrada         ³
			//³ExpC4 = Tipo de Operacao E-Entrada         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTesInt := MaTesInt( 2	,Padr("6",2)	,cCliente	,cLoja	,;
							     "C",SB1->B1_COD	,NIL)
	
			If !Empty(cTesInt)
				cTesPad := cTesInt
			Else
				If Empty( SB1->B1_TS )
					cTesPad := cTesSai
				Else
					cTesPad := SB1->B1_TS
				EndIf
			Endif
			
			If !Empty(TRB->TRB_CODPRO)
				nVlrTotal -= TRB->TRB_VLRTOT
			EndIf
			
			RecLock("TRB",.F.)
			REPLACE	TRB->TRB_CODPRO	WITH cValor
			REPLACE	TRB->TRB_DESPRO	WITH SB1->B1_DESC
			REPLACE	TRB->TRB_UM		WITH SB1->B1_UM
			REPLACE	TRB->TRB_TES	WITH cTesPad
			REPLACE	TRB->TRB_QUANT	WITH nQuant
		   	
		   	// No caso de utilizar o cenario de venda busca o preco da tabela de preco utilizada 
		   	If lCenVenda
				cTabPrecos := LjXETabPre(cCliente, cLoja) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retorna o valor da tabela de preco DA1 de acordo com a moeda utilizada.³
				//³caso nao encontre a tabela de preco retorna o valor do B0_PRV          ³
	   			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   		nPrcVenda := MaTabPrVen( cTabPrecos		,cValor		,nQuant			,cCliente	,; 
										cLoja			,nMoeda		, /*dDataVld*/	,/*nTipo*/	,;
										/*lExec*/	)
	   		Else                                                      
				nPrcVenda := Posicione("SB0",1,xFilial("SB0")+cValor,"B0_PRV"+cTabDef)
	   		EndIf 
	   		
			REPLACE	TRB->TRB_PRCVEN	WITH nPrcVenda
			REPLACE	TRB->TRB_VLRTOT	WITH A410Arred(TRB->TRB_QUANT * TRB->TRB_PRCVEN ,"D2_TOTAL")		
			MsUnlock()
			
			nVlrTotal += TRB->TRB_VLRTOT
	
		Case cCampo $ "TRB_QUANT"
	        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao permite que a quantidade seja alterada com um valor maior que o saldo a devolver existente na nota fiscal original.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(TRB->TRB_RECNO)
			    If TRB->TRB_ALI_WT = "SL2"
					DbSelectArea("SL2")
					SL2->( DbGoTo(TRB->TRB_REC_WT) )
					nQuant     := SL2->L2_QUANT
					nQTDEDEV   := If(lQtDeDev,SL2->L2_QTDEDEV,1)
                    nVlrTotAux := cValor * TRB->TRB_PRCVEN
					
					// Este trecho pega informacao para validar 
					// se esta devolvendo mais produtos que garantia , 
					nRecAtual	:= TRB->(RECNO())
					TRB->(dbSetOrder(1)) //TRB->TRB_RECNO
					TRB->(dbSeek(TRB->TRB_RECPAI))
					nQuantPai	:= TRB->TRB_QUANT
					TRB->(dbGoto(nRecAtual))
				Else
					DbSelectArea("SD2")
					SD2->( DbGoTo(TRB->TRB_REC_WT) )
					nQuant     := SD2->D2_QUANT
					nQTDEDEV   := SD2->D2_QTDEDEV

                    //Caso for devolver a quantidade de saldo, faz a conta levando em consideração o valor já devolvido
                    //Para não ter problemas de arredondamento quando utilizado mais de 2 casas decimais
                    nVlrTotAux := IIF(nQuant - nQTDEDEV == cValor, SD2->D2_TOTAL - RetSldDev(), cValor * TRB->TRB_PRCVEN)
				EndIf			 
				//nao deixa devolver mais produtos do que pode devolver
				If cValor > ( nQUANT - nQTDEDEV )
					lRet:= .F.
					MsgStop(STR0051,STR0033)//"A quantidade digitada é insuficiente de acordo com o saldo disponivel para devolução"##"Atenção"
				//nao deixa devolver menos garantia que o necessario
				ElseIf (cValor < nQuantPai  .AND. cValor < nQuant) 
					lRet:= .F.
					
					//Mensagem Garantia Estendida ou Servico Financeiro
					If lSFinanc .AND. Posicione("SB1", 1, xFilial("SB1") + SL2->L2_PRODUTO, "B1_TIPO") == cMvLjTSF 
						MsgStop(STR0186,STR0033)//"A quantidade digitada é menor que a quantidade do produto relacionado a Serviço Financeiro"##"Atenção"
					Else
						MsgStop(STR0177,STR0033)//"A quantidade digitada é menor que a quantidade do produto relacionado a Garantia"##"Atenção"
					EndIf					
				Else
					nVlrTotal -= TRB->TRB_VLRTOT

					RecLock("TRB",.F.)
					
                    REPLACE TRB->TRB_VLRTOT	WITH A410Arred(nVlrTotAux, "D2_TOTAL")
					
					If ExistFunc('LJ720AlPrd')
						nVlIpi := LJ720AlPrd()
					EndIf
					If nVlIpi > 0
						REPLACE TRB->TRB_VALIPI	WITH nVlIpi
					EndIf								

					MsUnlock()

					If nVlIpi > 0
						//Atualiza o total considerando a atualizacao do IPI
						Lj720GetOk( "TRB",{},@nVlrTotal,1,1,cCdFl,.T.  ) 
					Else
						nVlrTotal += TRB->TRB_VLRTOT
					EndIf
				Endif
			Else 		
				nVlrTotal -= TRB->TRB_VLRTOT
				RecLock("TRB",.F.)
				REPLACE	TRB->TRB_VLRTOT	WITH A410Arred(cValor * TRB->TRB_PRCVEN ,"D2_TOTAL")
				MsUnlock()
				nVlrTotal += TRB->TRB_VLRTOT
		    Endif
	
		Case cCampo $ "TRB_PRCVEN"
			
			nVlrTotal -= TRB->TRB_VLRTOT
			
			RecLock("TRB",.F.)
			REPLACE	TRB->TRB_VLRTOT	WITH A410Arred(TRB->TRB_QUANT * cValor ,"D2_TOTAL")
			MsUnlock()
	
			nVlrTotal += TRB->TRB_VLRTOT
	EndCase
	
	oVlrTotal:Refresh()
	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720concluir ºAutor  ³ Vendas Cliente  º Data ³  17/08/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Execucao da rotina que ira gerar a nota fiscal de entrada e º±±
±±º          ³chamada da rotina de venda assistida.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Tipo do processo de troca.                          º±±
±±º          ³ExpN2 - Origem do documento de entrada                      º±±
±±º          ³ExpC3 - Codigo do cliente                                   º±±
±±º          ³ExpC4 - Codigo da loja                                      º±±
±±º          ³ExpA5 - Array com os Recnos da tabela SD2                   º±±
±±º          ³ExpL6 - Indica se eh formulario proprio ou nao              º±±
±±º          ³ExpC7 - Numero do documento de entrada                      º±±
±±º          ³ExpO8 - Serie do documento de entrada                       º±±
±±º          ³ExpL9 - Indica se ira compensar a NCC com o titulo da NF.   º±±
±±º          ³ExpL10- Se a rotina foi executada pela venda assistida.     º±±
±±º          ³EXpA11: Armazena a serie, numero e cliente+loja da NF de    º±±
±±º          ³ 		  devolucao e o tipo de operacao(1=troca;2=devolucao) º±± 
±±º          ³ExpN12- Forma de devolucao ao cliente: 1-Dinheiro;2-NCC     º±±
±±º          ³ExpN13- Valor total de produtos a serem trocados ou         º±±
±±º          ³        devolvidos    								      º±±
±±º          ³ExpL14- Devolve em varias moedas.                           º±±
±±º          ³ExpN15- Moeda corrente                                      º±±
±±º          ³ExpN16- Taxa da moeda corrente                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720Concluir(	nTpProc		, nNfOrig	, cCodCli  		, cLojaCli	,;
 								aRecSD2		, lFormul	, cNumDoc  		, cSerieDoc	,;
 								lCompCR		, lVdAssist	, aDocDev   	, nFormaDev	,;
 								nVlrTotal	, lDevMoeda	, nMoedaCorT	, nTxMoedaTr,;
 								cCodDia		, cMotivo 	, nImpostos  	, cChvNFE	,;
 								cTpEspecie 	, cCodFil 	, lDevFrete 	, cMensagem, lAutomato)

Local lRet			:= .T.							   						// Retorno da funcao
Local aArea			:= GetArea()											// Armazena o posicionamento atual
Local aAreaSD2		:= SD2->(GetArea())										// Guarda a area do SD2
Local lMv_LJVLDEV   := SuperGetMv("MV_LJVLDEV")								// Indica se sera validado a existencia de saldo em dinheiro em caixa para realizar a devolucao.
Local lRestArea     := .F.                    								// Controla se deve restaurar a area da MATXFIS
Local lLj720Fim     := ExistBlock("LJ720FIM") 								// Controla se o PE LJ720FIM existe, chamado no final do processo 
Local lLojr860	    := ExistBlock("LOJR860")  								// Controla se o PE LOJR860 existe, chamado no final do processo
Local lLojr860A	    := ExistBlock("LOJR860A")  								// Controla se o PE LOJR860A existe, chamado no final do processo
Local aPosSd2		:= {}													// Guarda a posicao do SD2
Local cPrefixoEnt	:= ""													// Prefixo de entrada
Local cPrefixoSaida	:= ""													// Prefixo de Saida
Local aDevol 		:= {}													// Dados da devolucao
Local aSldItens		:= {}													// Itens da venda original
Local nPos			:= 0													// Resultado da busca no array aSldItens
Local cDocOri		:= ""													// Documento original da venda
Local cSerOri		:= ""													// Serie original da venda
Local cCliOri		:= ""													// Cliente original da venda
Local cLojOri		:= ""													// Loja original da venda
Local cFilSD2		:= FWxFilial("SD2",cCodFil)								// Filial da tabela SD2
Local cFilSL2		:= FWxFilial("SL2",cCodFil)								// Filial da tabela SL2
Local aOtcTroca     := {}													// array para guardar dados para troca de mercadoria de Otica
Local nCount		:= 0				
Local cPadrao		:= "704"												// Codigo Padrao
Local lPadrao  		:= VerPadrao(cPadrao)									// verifica padrao
Local nHdlPrv  		:= 0													// Contabilizacao
Local nTotal   		:= 0													// Contabilizacao
Local cArquivo 		:= ""													// Contabilizacao
Local lAglutina 	:= .T.									
Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")							// Cliente padrao 
Local cLojPad	 	:= SuperGetMV("MV_LOJAPAD")								// Loja do cliente padrao					
Local nX 			:= 0				
Local aNCC			:= {} 													// Array com as NCCs utilizadas na devolucao
Local lGeraOP		:= SuperGetMV("MV_GROPOTC ",.F.,.F.) 					// Parâmetro para verificar a necessidade de criar ou não Ordem de Produção para o template Otica
Local cDocSaida		:= ""													// Devolucao de Retira posterio
Local cSerieSaida	:= ""													// Devolucao de Retira posterio
Local lVP			:= SuperGetMv("MV_LJVALEP",,.F.) .And. AliasIndic("MDD")// Vale Presente ativo
Local lPrimeira 	:= .F.
Local lSegunda  	:= .F.
Local aNotas		:= {}
Local lEstNota		:= .F.
Local lVFComNF		:= .F.
Local aSav			:= {}
Local nTotalGar		:= 0 													// Recebe o total de Garantia Estendida	
Local nTotalServ	:= 0													// Recebe o total de Servico Financeiro
Local aRecGarPai    :={}													// Recebe os recnos da SD2 referentes a garantia estendida
Local nY			:= 0
Local lOrcGar 		:= SD2->(ColumnPos("D2_ORCGAR") > 0) .AND.  SD2->(ColumnPos("D2_ITEMGAR") > 0) 
Local aGarMfi       := {}                          							// Recebe os registro que devem ser atualizados na tabela MFI. 
Local lGE 			:= ExistFunc("LjUP104OK") .AND. LjUP104OK()				// Validação do Conceito Garantia Estendida
Local lPedEC		:= .F. 													// Pedido  e-commerce
Local cOrcRes		:= ""													// Orçamento de Origem
Local aAreaMF5		:= {}													// WorkArea MF5
Local cPedOri		:= ""													// Pedido de Origem
Local cFilSL1		:= FWxFilial("SL1",cCodFil)								// Filial da tabela SL1
Local aAreaSL1		:= {}
Local lEstPrimeira	:= .F. 													// Verifica se é necessário efetuar a devolução da venda futura.
Local lSFinanc		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local cMvLjTSF		:= SuperGetMV("MV_LJTPSF",,"SF") 						// Define se é tipo SF
Local cMvLjTGar		:= SuperGetMV("MV_LJTPGAR",,"GE")						// Define se é tipo Garantia Estendida
Local lECCia		:= .F. 													// e-commerce CiaShop
Local aAreaSC5		:= {} 													// WorkAreaSC5
Local aServFin		:= {} 													// Array com informacoes de Servicos Financeiros
Local aSE1Serv		:= {} 													// Array com informacoes da NCC de Servicos Financeiros
Local cFilSB1 		:= FWxFilial("SB1",cCodFil)
Local aNewNCC		:= {} 													// Array com NCCs de Servicos Financeiros para relatorio
Local aNccItens		:= {} 													// Array com NCCs de Servicos Financeiros para relatorio
Local aAreaSD1 		:= {} 													// Gurada a area da tabela de itens da Nota Fiscal de Entrada
Local aRecSD1  		:= {} 													// Array utilizado para impressão dos itens da NCC quando for selecionada troca sem documento de entrada
Local cFilSD1       := FWxFilial("SD1",cCodFil)
Local lTemImpCfg	:= IIF(!Empty(LjGetStation("IMPFISC")),.T.,.F.)  		// Sinaliza que existe impressora configurada na estacao
Local lRecNaoFis	:= LJModNFis()											// Sinaliza recebimento por modulo não fiscal(sem ECF) *NFC-e, Venda Direta
Local aDadosNCC		:= {}													// contem informações basicas da SF1
Local aDocOri		:= {}													// Array dos documentos de Origem
Local nC			:= 0 													// Variável Contadora
Local nPosDoc		:= 0
Local nTotalDev		:= 0 													// Total da devolução
Local nFrtSegDes	:= 0 													// Valor do Frete/Seguro/Despesa
Local nRetIcms		:= 0													// Retorno de ICMS - Substituição Tributária
Local lRestInclu	:= Iif(Type("INCLUI")<>"U",INCLUI,.T.)
Local lRestAlter    := Iif(Type("ALTERA")<>"U",ALTERA,.F.) 
Local aPrintNCC		:= {}													// Array com os dados da NCC a ser impressa com o codigo de barras
Local nRecSD2		:= 0
Local cChaveDOC		:= ""
Local cPedidoSd2    := ""                                                   //Numero do Pedido SD2 usado para troca

PRIVATE INCLUI 		:= .T.
PRIVATE lMsErroAuto := .F. 
                                                                           	
Default lDevMoeda  	:= .F.													// Devolve em varias moedas (localizacoes)
Default nMoedaCorT 	:= 1													// Moeda
Default nTxMoedaTr	:= 0													// Taxa da moeda
Default cCodDia    	:= ""													// Codigo do Diario
Default cMotivo		:= ""
Default nImpostos	:= 0
Default cChvNFE 	:= ""
Default cTpEspecie	:= ""
Default cMensagem	:= ""
Default lAutomato 	:= .F.

LjGrvLog( "TROCA_DEVOLUCAO", "Indica se sera validado a existencia de saldo em dinheiro em caixa para realizar a devolucao - MV_LJVLDEV", lMv_LJVLDEV)
LjGrvLog( "TROCA_DEVOLUCAO", "Parâmetro para verificar a necessidade de criar ou não Ordem de Produção para o template Otica - MV_GROPOTC", lGeraOP)
LjGrvLog( "TROCA_DEVOLUCAO", "Define se é tipo Garantia Estendida - MV_LJTPGAR", cMvLjTGar)

lQtDeDev := Lj720GetQt()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza um backup das variaveis fiscais para depois restaura-las, pois³
//³a rotina automatica reinicializa a funcao fiscal.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If MaFisFound() .AND. lVdAssist
	MafisSave()
	MafisEnd()
	lRestArea  := .T.
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa a ordem do IndRegua()³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SD2")
RetIndex("SD2")
DbClearFilter()

//Agrupa o registro por pedido/item de pedido
If (Len(aRecSd2) >= 1) .AND. (Len(aRecSd2[1]) >= 2)
	For nC := 1 to Len(aRecSd2)
		SD2->(DbGoTo(aRecSd2[nC][2]))
		If aScan(aDocOri, { |d| d[1] == SD2->D2_PEDIDO } ) == 0
			aAdd(aDocOri, { SD2->D2_PEDIDO, SD2->D2_ITEMPV, SD2->D2_FILIAL, SD2->D2_DOC})
		EndIf
		
	Next nC
	lj720CheckFat( @lVFComNF, @lPrimeira, @lSegunda, aRecSd2[1][2], @aNotas, aDocOri, cCodFil )
Endif

aDocOri := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma os produtos vendidos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aRecSd2) >= 1) .AND. (Len(aRecSd2[1]) >= 2)

	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	For nC := 1 to Len(aRecSd2)
		SD2->(DbGoTo(aRecSd2[nC][2]))
		If ( nPosDoc := aScan(aDocOri, { |d| d[1] == SD2->D2_DOC .AND. d[2] == SD2->D2_SERIE .AND. d[3] == SD2->D2_CLIENTE .AND. d[4] ==  SD2->D2_LOJA} ) ) == 0
			aAdd( aDocOri, { SD2->D2_DOC , SD2->D2_SERIE, SD2->D2_CLIENTE, SD2->D2_LOJA, 0,  aRecSd2[nC][2]})
			nPosDoc := Len(aDocOri)

			cDocOri		:= SD2->D2_DOC
			cSerOri		:= SD2->D2_SERIE
			cCliOri		:= SD2->D2_CLIENTE
			cLojOri		:= SD2->D2_LOJA

			SD2->(DbSeek(cFilSD2 + cDocOri + cSerOri + cCliOri + cLojOri))

			While !SD2->(Eof())				.AND.;
				SD2->D2_DOC		== cDocOri	.AND.;
				SD2->D2_SERIE	== cSerOri	.AND.;
				SD2->D2_CLIENTE	== cCliOri	.AND.;
				SD2->D2_LOJA	== cLojOri
		
				If (nPos := aScan( aSldItens, {|x| x[1] == SD2->D2_COD .AND. cDocOri ==  x[3] .AND.  cSerOri == x[4] })) > 0
					aSldItens[nPos][2] += (SD2->D2_QUANT - SD2->D2_QTDEDEV)
				Else
					AAdd(aSldItens,{ SD2->D2_COD, (SD2->D2_QUANT - SD2->D2_QTDEDEV) , cDocOri, cSerOri})
				EndIf	
		
				SD2->(DbSkip())
			End
		EndIf
		SD2->(DbGoTo(aRecSd2[nC][2]))
		aDocOri[nPosDoc, 05] := aDocOri[nPosDoc, 05] + (aRecSd2[nC][4]  + IIF( lDevFrete,aRecSd2[nC][5],0) )//valor total do documento
	Next

	aSort(aSldItens, , , { |x,y| x[4] <  y[4].and. x[3] < y[3]})
	LjGrvLog( "TROCA_DEVOLUCAO", "Array dos produtos para troca/devolucao - aSldItens", aSldItens)

	RestArea(aAreaSD2)
	RestArea(aArea)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cancela a ordem de serviço do produto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("Lj7HasDtEM") .And. Lj7HasDtEM()
	DbSelectArea( "SD2" )
	DbSetOrder( 1 )
	For nCount := 1 To Len( aRecSD2 )
		SD2->( DbGoTo( aRecSD2[nCount][2] ) )
		Lj7EliProdPed( SD2->D2_PEDIDO, SD2->D2_COD )
	Next
	RestArea( aAreaSD2 )
	RestArea( aArea )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa verificacao para as moedas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDevMoeda .AND. cPaisLoc <> "BRA" 
	If !Lj720VldDev(nVlrTotal,@aDevol,nMoedaCorT,nTxMoedaTr,nNfOrig)
		Return .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Geracao do documento de entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNfOrig == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma os valores de Garantia e remove eles da Temp³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   	
	DbSelectArea("TRB") 
	TRB->(DbGoTo(1))
	While !TRB->(Eof())
	    If TRB->TRB_ALI_WT = "SL2"			    
		    If !TRB->TRB_FLAG
		    	If lGE .And. Posicione("SB1", 1, cFilSB1 + TRB->TRB_CODPRO, "SB1->B1_TIPO") == cMvLjTGar
		    		nTotalGar += TRB->TRB_VLRTOT			    		
		    		AADD(aRecGarPai,{TRB->TRB_REC_WT,TRB->TRB_QUANT, TRB->TRB_VLRTOT,TRB->TRB_SERORI,TRB->TRB_NFORI})
		    	ElseIf lSFinanc .AND. Posicione("SB1", 1, cFilSB1 + TRB->TRB_CODPRO, "SB1->B1_TIPO") == cMvLjTSF
					//Tratamento Servico Financeiro
					aAdd(aServFin, {FWxFilial("SL2", cCodFil),; 
							TRB->TRB_SERORI,;
							TRB->TRB_NFORI,; 
							TRB->TRB_CODPRO,; 
							TRB->TRB_ITEM,; 
							TRB->TRB_VLRTOT})						
					
					nTotalServ += TRB->TRB_VLRTOT											
				EndIf					   					  
			EndIf
			
			RecLock( "TRB",.F.,.T.)
			TRB->(DbDelete())
			TRB->(MsUnlock())

		EndIf
	
		TRB->(DbSkip())
	End         

	aSort( aRecGarPai, , , { |x,y| x[4] < y[4]  .AND. x[5] < y[5] })    
	
	aSort( aServFin, , , { |x,y| x[2] < y[2]  .AND. x[3] < y[3] })    
	
	LjMsgRun(STR0032 ,,{||lRet:=Lj720DevSD2(	cCodCli   	, cLojaCli   	, aRecSD2  	, lFormul 		,;
												@cNumDoc  	, @cSerieDoc	, @aDocDev 	, nTpProc 		,;
												nFormaDev	, nVlrTotal  	, @aPosSd2	, @lDevMoeda	,;
												@aDevol   	, cCodDia		, cMotivo	, @nImpostos 	,;
												cChvNFE 	, cTpEspecie	, cCodFil 	, .T.			,;
												lDevFrete	, nNFOrig		, @nFrtSegDes, @nRetIcms )})  	 //"Aguarde, gerando documento de entrada..."
													
	If lRet .AND. lPadrao .AND. cPaisLoc == "MEX"
						
		nHdlPrv:=HeadProva("","LOJA720",Substr(cUsername,1,6),@cArquivo)
						
		If  nHdlPrv > 0
			nTotal+=DetProva(nHdlPrv,cPadrao,"LOJA720","")
		EndIf
								
		If  nTotal > 0
			RodaProva(nHdlPrv,nTotal)
			cA100Incl(cArquivo,nHdlPrv,3,"",.F.,lAglutina, 'N')
		EndIf				
		
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Elimina do laboratorio Registro Devolvido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If Hastemplate("OTC") 
		If nTpProc == 2  
	    	T_OtcDelDev(aDocDev)   
	    Else 
	        TRB->(DbGoTo(1))  
			While !TRB->(Eof())
	   			AADD(aOtcTroca ,{TRB->TRB_CODPRO,TRB->TRB_SERORI,TRB->TRB_NFORI,TRB->TRB_CODGEN })   
	   			TRB->(DbSkip())
			End	 
			If Len(aDocDev) > 6  
				aDocDev[7] := aClone(aOtcTroca)
			Else
		    	AADD(aDocDev , aOtcTroca) 
			EndIf
		EndIf	   	

		If lGeraOP .And. lRet 
		        TRB->(DbGoTo(1)) 
			While !TRB->(Eof())
	   			EstOPOtc(TRB->TRB_CODPRO,TRB->TRB_NFORI,TRB->TRB_SERORI,TRB->TRB_ITEM,SD2->D2_CLIENTE,SD2->D2_LOJA,5,cCodFil)
	   			TRB->(DbSkip())
			End	 
		Endif

	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula para comissao em aberto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		LJ720RecComis( aPosSd2 , nFormaDev, cCodFil, aDocOri )			
    Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deleta do temporário os arquivos selecionados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB") 
	TRB->(DbGoTo(1))
	While !TRB->(Eof())
		If TRB->TRB_FLAG
			RecLock( "TRB",.F.,.T.)
			TRB->(DbDelete())
			TRB->(MsUnlock())
		Endif                  
		TRB->(DbSkip())
	End

	If lAutomato//Caso seja execução via robô não exibe janela de "Aguarde"
		lRet:=Lj720DevTRB(	cCodCli   	, cLojaCli	, lFormul	, @cNumDoc  	,;
													@cSerieDoc	, @aDocDev	, nTpProc	, nFormaDev 	,;
													nVlrTotal	, lDevMoeda	, @aDevol	, nMoedaCorT	,;
													nTxMoedaTr	, cMotivo	, @nImpostos, cChvNFE		,;
													cTpEspecie	, @cMensagem, nNFOrig	, nFrtSegDes    ,;
													nRetIcms 	, lAutomato)	//"Aguarde, gerando documento de entrada..."
	Else
		LjMsgRun(STR0032 ,,{||lRet:=Lj720DevTRB(	cCodCli   	, cLojaCli	, lFormul	, @cNumDoc  	,;
													@cSerieDoc	, @aDocDev	, nTpProc	, nFormaDev 	,;
													nVlrTotal	, lDevMoeda	, @aDevol	, nMoedaCorT	,;
													nTxMoedaTr	, cMotivo	, @nImpostos, cChvNFE		,;
													cTpEspecie	, @cMensagem, nNFOrig	, nFrtSegDes    ,;
													nRetIcms 	, lAutomato)}	)	//"Aguarde, gerando documento de entrada..."
	Endif	
												
	If lRet .AND. lPadrao .AND. cPaisLoc == "MEX"
						
		nHdlPrv:=HeadProva(cLote,"LOJA720",Substr(cUsername,1,6),@cArquivo)
						
		If  nHdlPrv > 0
			nTotal+=DetProva(nHdlPrv,cPadrao,"LOJA720","")
		EndIf
								
		If  nTotal > 0
			RodaProva(nHdlPrv,nTotal)
			cA100Incl(cArquivo,nHdlPrv,3,"",.F.,lAglutina)
		EndIf				
		
    EndIf

Endif

If lVFComNF
	aSl2Area 	:= SL2->(GetArea()) 
	aSd2Area	:= SD2->(GetArea())
	aSF2Area	:= SF2->(GetArea())

	aSav		:= aClone(aRecSD2)

	aRecSD2		:= {} 
	SD2->(dbSetOrder(3))
	SF2->(dbSetOrder(1))

	For nX := 1 to len(aNotas)
	    lEstNota	:= .F.
		If SD2->(dbSeek( cFilSD2 + aNotas[nX][1]+aNotas[nx][2] ))
			SF2->(dbSeek(SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))		
			While SD2->( !eof() ) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) ==  cFilSD2+aNotas[nX][1]+aNotas[nx][2]
				If ascan( aSav, {|x| x[2] == SD2->(Recno()) } ) == 0
					Aadd(aRecSD2,{SD2->D2_QUANT, SD2->(Recno()), NIL, 0, 0})
					lEstNota := .T.
				Endif
				SD2->(dbSkip())
			End
		Endif
    	If lEstNota
	    	aOldDocDev := aClone(aDocDev)
			SD2->(dbSeek( SF2->( F2_FILIAL + F2_DOC + F2_SERIE) ))

			LjMsgRun(STR0032 ,,{||lRet:=Lj720DevSD2(	cCodCli   	, cLojaCli   	, aRecSD2  	, lFormul 		,;
								@cNumDoc  	, @cSerieDoc	, @aDocDev 	, nTpProc 		,;
								nFormaDev	, nVlrTotal  	, @aPosSd2	, @lDevMoeda	,;
								@aDevol   	, cCodDia		, cMotivo	, @nImpostos 	,;
								cChvNFE 	, cTpEspecie	, cCodFil	, .T.			,;
								lDevFrete	, nNFOrig		, @nFrtSegDes,@nRetIcms	)})	//"Aguarde, gerando documento de entrada..."

			lEstPrimeira := .T.
			aDocDev := aClone(aOldDocDev)
	   		Lj720DevDinh( cNumDoc , cSerieDoc, cCodCli, cLojaCli, ;
	   					nVlrTotal,.F.		, 		,			0,;
	   					xNumCaixa(), 		,		, nFrtSegDes,;
	   					nRetIcms)      //"BAIXA REF. ESTORNO DE VENDA"
        Else
        	aSL1Area	:= SL1->(GetArea())
        	
       		SD2->(dbSetOrder(3))
   			SL1->(DBSetOrder(2))
   			SD2->(dbSeek( SF2->( F2_FILIAL + F2_DOC + F2_SERIE) ))
   			SL1->(dbSeek( xFilial("SL1", cCodFil)+SD2->D2_SERIE+SD2->D2_DOC))

   			If !lEstPrimeira
	        	Lj601RePed(	xNumCaixa()	,	SD2->D2_DOC		,	SD2->D2_SERIE	,	cCodCli	,;
							cLojaCli	,	SL1->L1_NUM		,	""				,	""		,;
							0			,	SD2->D2_EMISSAO	,	.F.				,	""		,;
							""			,	{}				,	{}				,	.T.		)	
		   		Lj720DevDinh( SD2->D2_DOC , SD2->D2_SERIE, cCodCli, cLojaCli, ;
		   					nVlrTotal,				.F., 		,0			,;
		   					xNumCaixa(),				, 		, nFrtSegDes,;
		   					nRetIcms	)      //"BAIXA REF. ESTORNO DE VENDA"
			EndIf

			RestArea(aSL1Area)
        Endif
	Next nX
	aRecSD2 := aClone(aSav)
	RestArea(aSF2Area)
	RestArea(aSL2Area)
	RestArea(aSD2Area)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a funcao fiscal com base nos dados backupados anteriormente.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVdAssist .AND. lRestArea
	MafisRestore()
Endif

//Incluido verificação do Pedido na SD2 posicionado, pois na função Lj720DevSD2 o registro desposicionou
cPedidoSd2 := GetAdvFVal("SD2","D2_PEDIDO",xFilial("SD2")+cDocOri + cSerOri + cCliOri + cLojOri,3,"Erro") 

If cPedidoSd2 <> SD2->D2_PEDIDO 
    SD2->(DbSeek(cFilSD2 + cDocOri + cSerOri + cCliOri + cLojOri))
EndIf

//Verifica se a venda é e-commerce
cPedOri := SD2->D2_PEDIDO  
lPedEC :=  Lj720PedEc(cPedOri, @cOrcRes, cCodFil, @lECCia)
                               	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executar a interface da venda assistida quando a rotina for chamada pelo Menu.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet	
	If  nFormaDev == 2
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Atualiza o Saldo da NCC, quando Possuir Garantia Estendida³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTotalGar > 0  
		   dbSelectArea("SL1")
		   SL1->(dbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV 
			   If SL1->(dbSeek(xFilial("SL1", cCodFil)+ aRecGarPai[01,04]+ aRecGarPai[01,05] ))		   
		   
			 	CriaTit( cNumDoc,cSerieDoc,SL1->L1_OPERADO,SL1->L1_EMISNF,;
							 nTotalGar,SL1->L1_CLIENTE ,SL1->L1_LOJA,cSerieDoc,;
						 SL1->L1_EMISNF, "NCC", &(SuperGetMV("MV_NATNCC")) ,0 , "Lj720Concluir")   			 
		   		EndIf			
		EndIf	
		
	    //Tratamento para Servico Financeiro
		If nTotalServ	> 0
			SL1->(dbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV 
		   
			If SL1->(dbSeek(xFilial("SL1",cCodFil)+ aServFin[01,02] + aServFin[01,03] ))										   
				//Gera NCC do Servico Financeiro para o cliente
				CriaTit(cNumDoc, cSerieDoc, SL1->L1_OPERADO, SL1->L1_EMISNF,;
							 nTotalServ, SL1->L1_CLIENTE, SL1->L1_LOJA, cSerieDoc,;
						 SL1->L1_EMISNF, "NCC", &(SuperGetMV("MV_NATNCC")), 0, "Lj720Concluir")

				//Adiciona NCC para Relatorio de Servicos Financeiros
				aAdd(aNewNCC,{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_EMISSAO,;
									SE1->E1_VENCREA,SE1->E1_VALOR,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_MOEDA})

				aAdd(aNccItens, {.T. , SE1->E1_SALDO, SE1->E1_NUM, SE1->E1_EMISSAO,;
		  					  		SE1->(Recno()), SE1->E1_SALDO, SuperGetMV("MV_MOEDA1"), SE1->E1_MOEDA,;
		  					  		SE1->E1_PREFIXO, SE1->E1_PARCELA, SE1->E1_TIPO})						
						 
				//Armazena informacoes do titulo Servico Financeiro
				aAdd(aSE1Serv, SE1->E1_PREFIXO) 
				aAdd(aSE1Serv, SE1->E1_NUM) 	   			 
				aAdd(aSE1Serv, SE1->E1_PARCELA)
				aAdd(aSE1Serv, SE1->E1_TIPO)
			EndIf					
		EndIf    
  	EndIf

    //Efetua o cancelamento da fidelização
    If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
        CancFideli(cFilSD2, aDocOri)
    EndIf
	
    lConfirma := .T.
	If nTpProc == 1  .AND. !lVdAssist	//Troca De Mercadorias
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa o filtro ativo criado na tabela SD2                   ³
		//³antes de executar a rotina de Atendimento da Venda Assistida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		INCLUI := .T.
		ALTERA := .F. 

		DbSelectArea("SD2")
		RetIndex("SD2")
		DbClearFilter()

		Loja701(  .T.  ,   3   ,  cCodCli  ,  cLojaCli  ,;
				  aDocDev  )

		//-- Restaura variaveis INLCUI e ALTERA
		INCLUI := lRestInclu
		ALTERA := lRestAlter

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a funcao que compensa NCC com o titulo do documento de origem ³
	//³apenas quando for Devolucao, foi informada a nota fiscal de origem e  ³
	//³a forma de devolucao foi NCC										     ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf nTpProc == 2 .AND. nFormaDev == 2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pega o prefixo da nota de entrada para fazer a baixa da NCC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF1")
		SF1->(DbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1")+ cNumDoc + cSerieDoc + cCodCli + cLojaCli ))
			cPrefixoEnt := SF1->F1_PREFIXO
		Else
			cPrefixoEnt := cSerieDoc	
		Endif
		
		aDadosNCC := {cPrefixoEnt} //Mando esta informacao pro RdMake LOJR860, pois ao alterar o MV_2DUPREF a NCC não e encontrada
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega as NCCs utilizada na Devolucao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aNCC := Lj720aNCC(cCodCli, cLojaCli, cPrefixoEnt, cNumDoc)
		
		If nNfOrig == 1
			For nC := 1 to Len(aDocOri)
				cDocSaida	:= ""
				cSerieSaida	:= ""
				cPrefixoSaida := cSerieSaida
				If Len(aDocOri) == 1 //somente 1 documento por venda
					nTotalDev			:= nVlrTotal	
				Else
					nTotalDev			:= aDocOri[nC, 05] 
				EndIf
		
				If cPaisLoc == "BRA" .And. SuperGetMv("MV_LJICMJR",,.F.)
					Lj720NccIcmJr(aNCC, aDocOri[nC, 02] +aDocOri[nC, 01],nTotalDev, lCompCR, cCodFil)
				EndIf

				If lCompCR
					DbSelectArea("SD2")
					SD2->(DbGoTo(aDocOri[nC, 06])) //PRIMEIRO ITEM DO DOCUMENTO
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Pega o prefixo da nota de entrada para fazer a baixa do Titulo³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SF2")
					DbSetOrder(1)
					If DbSeek(FWxFilial("SF2",cCodFil)+aDocOri[nC, 01]+aDocOri[nC, 02]+cCodCli+cLojaCli)
						cPrefixoSaida := SF2->F2_PREFIXO
					ElseIf DbSeek(FWxFilial("SF2",cCodFil)+aDocOri[nC, 01]+aDocOri[nC, 02]+cCliPad+cLojPad)
						cPrefixoSaida := SF2->F2_PREFIXO
					Else
						cPrefixoSaida := SD2->D2_SERIE	
					Endif
	
					//Tratamento necessario para devolução de item "Retira Posterior"
						//Posiciona no título
					aOrdSL1 := SL1->(GetArea())
						
					SL1->(DbSetOrder(2)) //L1_SERIE + L1_DOC
					If !SL1->(DbSeek(xFilial("SL1",cCodFil)+aDocOri[nC, 02] +aDocOri[nC, 01]))
						SL1->(DbSetOrder(11)) //L1_SERPED + L1_DOCPED
						SL1->(DbSeek(xFilial("SL1",cCodFil)+aDocOri[nC, 02] +aDocOri[nC, 01]))
					EndIf
						
						
					If AllTrim(SL1->L1_TIPO) == "P" .And. ( !Empty(SL1->L1_FILRES) .And. !Empty(SL1->L1_ORCRES) .Or. !Empty(SL1->L1_DOCPED) ) //Para vendas com e sem retira posterior
						SL1->(DbSetOrder(1))
						If !Empty(SL1->L1_DOCPED) .Or. SL1->(DbSeek(xFilial("SL1",cCodFil)+SL1->L1_ORCRES))
							cDocSaida	:= SL1->L1_DOCPED
							cSerieSaida	:= SL1->L1_SERPED
							cPrefixoSaida := cSerieSaida
						EndIf
					EndIf
					RestArea(aOrdSL1)
	
					cDocSaida	:= IIf( Empty(cDocSaida)  , SD2->D2_DOC  , cDocSaida )
					cSerieSaida	:= IIf( Empty(cSerieSaida), SD2->D2_SERIE, cSerieSaida)
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Elimina residuos referente as taxas cobradas pela adm. financeira³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
						Lj720Resid(	@aSldItens	, IIF( !lECCia, SD2->D2_DOC, SL1->L1_DOCPED)	, IIF( !lECCia, SD2->D2_SERIE, SL1->L1_SERPED)	, cPrefixoSaida	,;
									nMoedaCorT	,  nTotalDev		, cCodCli		, cLojaCli 		,;
									cCodFil	)   
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Chama a funcao que ira compensar as NCCs com os titulos ja gerados pela saida somente na devolucao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lPedEC
						
						Lj720MultN (cCodFil ,cSerieSaida , cDocSaida , aNCC )
						
						Lj720Comp(	cNumDoc		, cSerieDoc		, cDocSaida		, cSerieSaida	,;
									cCodCli		, cLojaCli		, SD2->D2_PDV	, nTotalDev		,;
									cPrefixoEnt	, cPrefixoSaida	, aNCC			, cCodFil 		,;
									Len(aDocOri) == 1)
					Else 
					   //Busca os dados do orçamento de Origem - L1_docped/l1_serped
					 
					   If !lECCia 
						   aAreaSL1 := SL1->(GetArea())
						   SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
						   If SL1->(DbSeek(cFilSL1 +cOrcRes)) 
								ConOut("LOJA720 - "+ STR0185 ) //"Compensação de titulos e-commerce"    
								Lj720Comp(	cNumDoc		, cSerieDoc		, SL1->L1_DOCPED	, SL1->L1_SERPED	,;
											cCodCli		, cLojaCli		, SD2->D2_PDV	, nTotalDev		,;
											cPrefixoEnt	, SL1->L1_SERPED	, aNCC			, cCodFil 	,;
											Len(aDocOri) == 1	)
						   EndIf 
						   RestArea(aAreaSL1) 
					   Else 
							ConOut("LOJA720 - " +STR0185 + " CiaShop") //"Compensação de titulos e-commerce"
					   
							Lj720Comp(	cNumDoc		, cSerieDoc		, SL1->L1_DOCPED	, SL1->L1_SERPED	,;
											cCodCli		, cLojaCli		, SD2->D2_PDV	, nTotalDev	,;
											cPrefixoEnt	, SL1->L1_SERPED	, aNCC			, cCodFil,;
											Len(aDocOri) == 1 		)	
						EndIf	   
					EndIf
				Endif
			Next nC		
		ElseIf nNfOrig == 2
		
		  aAreaSD1 := SD1->(GetArea())
		  aRecSD1  := {}
		  SD1->(dbSetOrder(1))
          If SD1->(dbSeek( cFilSD1 + cNumDoc + cSerieDoc + cCodCli + cLojaCli  ))
		  
		      While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cFilSD1 + cNumDoc + cSerieDoc + cCodCli + cLojaCli
		          aAdd(aRecSD1,{Sd1->D1_QUANT,SD1->(Recno())} )
		          SD1->(dbSkip())
		      EndDo
		      
		  EndIf
			
		  RestArea(aAreaSD1)
		   
		Endif
		// Restaurando o status do vale presente para 1 (Ativo)
		If lVP
			Lj720VPDev(aRecSD2, cCodFil)
		EndIf

	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se usar data de validade na NCC altera data de vencimento da NCC	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJVLNCC",,.F.)
	DbSelectArea("SE1")
   	SE1->( DbSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO   	
	For nCount := 1 To Len(aNCC)
		DbGoTo(aNCC[nCount])
		RecLock( "SE1", .F. )	
		Replace SE1->E1_VENCTO With (dDataBase + SuperGetMV("MV_LJDTNCC",,0))    
		Replace SE1->E1_VENCREA With DataValida((dDataBase + SuperGetMV("MV_LJDTNCC",,0)))
		MsUnLock()
	Next nCount      
Endif

If lLj720Fim
	LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:LJ720FIM",{aDocDev})
    ExecBlock("LJ720FIM",.F.,.F.,{aDocDev})
   LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:LJ720FIM - aDocDev", aDocDev)
Endif

/*
	Monta mensagem para impressao de cupom nao fiscaladmin
	de NCC com Codigo de barras
*/
If SuperGetMv("MV_LJNCCBC", , "0" ) <> "0"

	LjGrvLog("TROCA_DEVOLUCAO","Esta habilitado o parametro MV_LJNCCBC (NCC com Código de barras)")

	//Caso tenha a impressora configurada na Estacao, faz a impressao comprovante da NCC com Codigo de Barras
	If lTemImpCfg
		If ExistBlock("Ljr860CB")
			LjGrvLog("TROCA_DEVOLUCAO","O RDMAKE Ljr860CB de impressao do comprovante da NCC com Codigo de Barras esta compilado")
			LjGrvLog("TROCA_DEVOLUCAO","Dados do Documento de Devolucao", aDocDev)
			LjGrvLog("TROCA_DEVOLUCAO","Recnos da tabela SD2", aRecSD2)
			
			aPrintNCC := ExecBlock("Ljr860CB",.F.,.F.,{aDocDev, aRecSD2, !lRecNaoFis})
			
			LjGrvLog("TROCA_DEVOLUCAO","Retorno do RDMAKE Ljr860CB", aPrintNCC)
		EndIf

		If ValType(aPrintNCC) == "A" .And. Len(aPrintNCC) > 0 .And. Len(aPrintNCC[1]) == 3
			If ExistFunc("LjPrtNccCB")
				LjPrtNccCB(aPrintNCC,!lRecNaoFis)
			EndIf
		Else
			LjGrvLog("TROCA_DEVOLUCAO","Retorno do tipo de variavel ou estrutura inválido do RDMAKE Ljr860CB. Deve ser do tipo Array.", aPrintNCC)
		EndIf
	Else
		LjGrvLog("TROCA_DEVOLUCAO","Nao existe impressora configurada na estacao para impressao do comprovante da NCC com Codigo de Barras")
	EndIf
EndIf	

If lLojr860 .AND. !lAutomato
	LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:LOJR860",{aDocDev,aRecSD2,aDadosNCC})
	ExecBlock("LOJR860",.F.,.F.,{aDocDev,aRecSD2,aDadosNCC,aRecSD1})
	LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:LOJR860 - aDocDev,aRecSD2,aDadosNCC", {aDocDev,aRecSD2,aDadosNCC})
Endif

//Imprime relatorio NCC Servicos Financeiros
If lSFinanc .And. lLojr860A .AND. !lAutomato
	If lConfirma .And. Len(aNewNCC) > 0
		LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:{aNewNCC, aNCCItens , nTotalServ}",{aNewNCC, aNCCItens , nTotalServ})
		ExecBlock("LOJR860A",.F.,.F.,{aNewNCC, aNCCItens , nTotalServ})
		LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:{aNewNCC, aNCCItens , nTotalServ} - aDocDev,aRecSD2,aDadosNCC", {aNewNCC, aNCCItens , nTotalServ})
	EndIf
EndIf			

nRecSD2 := SD2->(Recno())
aAreaSL1 := SL1->(GetArea())

SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
For nC := 1 to Len(aRecSd2)
	SD2->(DbGoTo(aRecSd2[nC][2]))

	If cChaveDOC <> FWxFilial("SL1",cCodFil)+SD2->D2_SERIE+SD2->D2_DOC
		cChaveDOC := FWxFilial("SL1",cCodFil)+SD2->D2_SERIE+SD2->D2_DOC
		If SL1->(DbSeek(cChaveDOC))
			//Verifica se é troca/devolução de uma venda cujo cancelamento da venda por algum motivo tenha sido rejeitado pela SEFAZ (X3). Se positivo, atualiza o SITUA para OK
			If SL1->L1_SITUA == "X3"
				RecLock("SL1", .F.)
				SL1->L1_SITUA	:= "OK"
				SL1->(MsunLock())
			EndIf
		EndIf
	EndIf
Next nC

RestArea(aAreaSL1)
SD2->(DbGoTo(nRecSD2))

If (lGE .OR. lSFinanc) .AND. lOrcGar  

	nRecSD2 := SD2->(Recno())
		
	For nC := 1 to Len(aDocOri)
	
		SD2->(DbGoTo(aDocOri[nC, 06])) //PRIMEIRO ITEM DO DOCUMENTO

		nPosDoc := aScan( aRecGarPai, { |g| g[4] =  aDocOri[nC, 02] .and. g[5] = aDocOri[nC, 01] })
		//Posiciona no SD2 de cada item
			
		DbSelectArea("SL2")
		SL2->( DbSetOrder(1) ) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO	
				
		DbSelectArea("SL1")
	 
		If SL1->(DbSetOrder(1), DbSeek(FWxFilial("SL1",cCodFil)+SD2->D2_ORCGAR )) .OR. SL1->(DbSetOrder(2), DbSeek(FWxFilial("SL1",cCodFil)+SD2->D2_SERIE+SD2->D2_DOC) )
		
			If !Lj720VldGA(SL1->L1_ORCRES, cCodFil)     					 
				For nX:= 1 to Len(aRecSD2)
					SD2->(DbGoTo(aRecSD2[nX][2]))
						If SD2->D2_DOC =  aDocOri[nC, 01] .AND. SD2->D2_SERIE = aDocOri[nC, 02]
				
							If SL2->(DbSeek(cFilSL2 + SD2->D2_ORCGAR + SD2->D2_ITEMGAR)) 
					
								If  SL2->(ColumnPos("L2_GARDEV") > 0) .AND. ( EMPTY(SL2->L2_GARDEV) .OR. If(lQtDeDev,SL2->L2_QTDEDEV < SL2->L2_QUANT,.F.) ) 
								
									If SL2->(DbSeek(cFilSL2 + SL1->L1_NUM + SL2->L2_ITEMGAR ) ) 
							
												Lj720Sini( 	nTpProc			, cLojaCli		, aDocOri[nC, 05]			, SD2->D2_PRUNIT	,;
									 				SD2->D2_COD		, SD2->D2_DOC	, SD2->D2_SERIE		, SL2->L2_ITEM		,;
									                SD2->D2_PDV		, SD2->D2_SERIE	, nMoedaCorT		, cNumDoc, 			;
										    	    SD2->D2_PEDIDO	, cCodFil, IIF(nPosDoc = 0, 0 , aRecGarPai[nPosDoc, 03])) //ratear ntotalgar nvrltotal
										
									EndIf
									
								EndIf
								
							EndIf
						EndIf
			
				Next nX
			EndIf
		EndIf
	Next nC 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a Data de devolucao da Garantia Estendida³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRecGarPai) > 0 
		For nY:= 1 to Len(aRecGarPai)  
						
			SL2->(DBGOTO(aRecGarPai[nY][1])) 
			
			If EMPTY(SL2->L2_GARDEV).OR. If(lQtDeDev,SL2->L2_QTDEDEV < SL2->L2_QUANT,.F.)
		   		RecLock("SL2",.F.)
		   		SL2->L2_GARDEV := dDatabase
		   		If lQtDeDev
		   			SL2->L2_QTDEDEV:= aRecGarPai[nY][2] + SL2->L2_QTDEDEV
		   		EndIf	
		   		SL2->(MsUnlock())
		   	EndIf

			If  (SuperGetMv("MV_LJFNGE",,.F.) .AND. lGE .And. ExistFunc("LJ7GrvMFI")) .OR. lSFinanc  
				Aadd(aGarMfi,{ xFilial("MFI") + cFilAnt +  SL2->L2_DOC + SL2->L2_SERIE + SL2->L2_ITEM } )  
			EndIf				
		   	
		Next nY   
		
		If Len(aGarMfi) > 0
			LJ7GrvMFI(4,aGarMfi)
		EndIf		
	EndIf     
	
	SD2->(DbGoTo(nRecSD2))	
EndIf

If lPedEC .And. !Empty(cOrcRes) .AND. !lECCia
	ConOut("Lj720Concluir - "+ STR0182)  //"Sinalizando venda para cancelamento no e-commece"
	aAreaMF5 := MF5->(GetArea()) 
	MF5->(DbSetOrder(1)) //MF5_FILIAL+MF5_ECALIA+MF5_ECVCHV  
	If MF5->(DbSeek(FWxFilial("MF5",cCodFil) + "SL1" + cFilSL1 +cOrcRes) ) 
		If RecLock("MF5", .F.)
				MF5->MF5_ECFLAG := "2"  //Inativo 
		     	MF5->MF5_ECDTEX := " "
		    	MF5->MF5_ECSTAT := "5"  // 5-Status e-commerce para cancelado		 
				MF5->(MsUnlock()) 
		Else 
				ConOut("Lj720Concluir - " + STR0183 ) //"Problemas na sinalização da devolução no e-commece
		EndIf
	Else
		ConOut("Lj720Concluir - " + STR0184) //"Nao localizada venda para devolução no e-commece" 
	EndIf
	
	RestArea(aAreaMF5)
ElseIf !Empty(cPedOri) .AND. SC5->(ColumnPos("C5_STATUS")) > 0
	ConOut("Lj720Concluir - " + STR0182 + "CiaShop")  //"Sinalizando venda para cancelamento no e-commece" 
	aAreaSC5 := SC5->(GetArea()) 
	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM 
	If SC5->(DbSeek(FWxFilial("SC5",cCodFil) + PadR(cPedOri, TamSx3("C5_NUM")[1]) ) ) 
		If RecLock("SC5", .F.)  
				SC5->C5_STATUS := "91" 
				SC5->C5_VOLTAPS := ""
				SC5->(MsUnlock()) 
				
				//Mensagem de rastreio de pedido
				If FwHasEai("MATA410B", .T., , .T.)
					FwIntegDef("MATA410B")
				EndIf
		Else 
				ConOut("Lj720Concluir - " + STR0183 + " CiaShop")  //Problemas na sinalização da devolução no e-commece 
		EndIf
	Else
		ConOut("Lj720Concluir - " + STR0184 + " CiaShop")           //"Nao localizada venda para devolução no e-commece" 
	EndIf
	
	RestArea(aAreaSC5)


EndIf

//Se Troca e cancelado pelo usuario, estorna financeiro de Servicos Financeiros
If lSFinanc .And. nFormaDev == 2
	//Gera titulo para receber da Seguradora - Servico Financeiro ou estorna a NCC de Servico Financeiro
	// se troca cancelada pelo usuario
	If lSFinanc .And. !lTroca  
		Lj720DevSF(aServFin, aSE1Serv, cCodFil)
	EndIf 
EndIf

RestArea(aAreaSD2)
RestArea(aArea)	

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720Impos³ Autor ³ Vendas Cliente        ³ Data ³22.08.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Lj720Impos()                                                 ³±±
±±³          ³Funcao de calculo dos impostos contidos na devolucao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³ExpC1 - Codigo do cliente de troca.                          ³±±
±±º          ³ExpC2 - Loja de cadastro do cliente                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao efetua os calculos de impostos (ICMS,IPI,ISS,etc)³±±
±±³          ³com base nas funcoes fiscais, a fim de possibilitar ao usua- ³±±
±±³          ³rio o valor de desembolso financeiro.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj720Impos( cCliente  ,cLoja  , cCodFil, lDevFrete )
Local aArea		:= GetArea()					//Guarda a area atual
Local aAreaSA1	:= SA1->(GetArea())			//Guarda a area do SA1
Local aAreaTRB	:= TRB->(GetArea())			//Guarda a area do TRB
Local nItem     := 0         					//Total de itens no TRB
Local cFilSB1 	:= FWxFilial("SB1",cCodFil)
Local cFilSB2 	:= FWxFilial("SB2",cCodFil)
Local cFilSF4 	:= FWxFilial("SF4",cCodFil)
Local lContinua := .T.
Local nPrcVenda 	:= 0
Local nVlrMerc 	:= 0
Local lSeekSF2   := .F.
Local nDescontos := 0
Local nItFrete   := 0
Local nItDespesa := 0
Local nItSeguro  := 0

If Empty(cCliente)
	Alert(STR0027) //"O código do cliente deve ser informado."
	lContinua := .F.
ElseIf Empty(cLoja)
	Alert(STR0122) //"O código da loja deve ser informado."
	lContinua := .F.
EndIf

SA1->(DbSetOrder(1))
If lContinua .And. SA1->(DbSeek( FWxFilial("SA1",cCodFil) + cCliente + cLoja ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()
	MaFisIni(SA1->A1_COD,;// 1-Codigo Cliente/Fornecedor
			SA1->A1_LOJA,;		// 2-Loja do Cliente/Fornecedor
			"C",;				// 3-C: 
			"D",;				// 4-Tipo da NF
			SA1->A1_TIPO,;		// 5-Tipo do Cliente/Fornecedor
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"MATA461")
	
	If cPaisLoc == "ARG"
		MaFisLoad("NF_PROVENT",SM0->M0_ESTENT) //Provincia
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DbSelectArea("TRB")
	DbGoTop()
	
	While TRB->( !Eof() )
		
		If TRB->TRB_FLAG //Se tiver deletado desconsidera
			TRB->(DbSkip())
			Loop
		EndIf
		
		nQtdPeso := 0
		If !lSeekSF2
			lSeekSF2 := .T. //Seta a variavel para nao executar o Seek novamente na SF2
			
			DbSelectArea("SF2")  
			SF2->( DbSetOrder(1) )
			SF2->( DbSeek(FWxFilial("SF2",cCodFil)+TRB->TRB_NFORI+TRB->TRB_SERORI+cCliente+cLoja) )
		EndIf          
		
		nItem++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona Registros                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(cFilSB1+TRB->TRB_CODPRO))
			nQtdPeso := TRB->TRB_QUANT*SB1->B1_PESO
		Endif

		SB2->(DbSetOrder(1))
        SB2->(DbSeek(cFilSB2+TRB->TRB_CODPRO+TRB->TRB_LOCAL))
        
		SF4->(DbSetOrder(1))
        SF4->(DbSeek(cFilSF4+TRB->TRB_TES))
        
		/*
		|| Calcula valores de Frete, Despesa e Seguro proporcional a ser devolvido
		|| Em devoluções os valores de Frete, Seguro e Despesa são somados e incluso no campo Despesa conforme definição Fiscal:
		|| https://tdn.totvs.com/pages/releaseview.action?pageId=440834321
		*/
		If lDevFrete
			nItDespesa	:= (TRB->TRB_VDESPE / TRB->TRB_QTDORI) * TRB->TRB_QUANT
	    EndIf
       
       nDescontos := ( ( (TRB->TRB_VLRDES + TRB->TRB_VRDESP) / TRB->TRB_QTDORI ) * TRB->TRB_QUANT )
       
       nVlrMerc  := ( TRB->TRB_VLRTOT + nDescontos )
       nPrcVenda := ( ( TRB->TRB_VLRTOT + nDescontos ) / TRB->TRB_QUANT )
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Agrega os itens para a funcao fiscal         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAdd(TRB->TRB_CODPRO,;  	// 01-Codigo do Produto ( Obrigatorio )
					TRB->TRB_TES,;  		// 02-Codigo do TES ( Opcional )
					TRB->TRB_QUANT,;		// 03-Quantidade ( Obrigatorio )
					nPrcVenda,;     		// 04-Preco Unitario ( Obrigatorio )
					nDescontos,;    		// 05-Valor do Desconto ( Opcional )
					"",;            		// 06-Numero da NF Original ( Devolucao/Benef )
					"",;            		// 07-Serie da NF Original ( Devolucao/Benef )
					0,;             		// 08-RecNo da NF Original no arq SD1/SD2
					nItFrete,;      		// 09-Valor do Frete do Item ( Opcional )
					nItDespesa,;    		// 10-Valor da Despesa do item ( Opcional )
					nItSeguro,;     		// 11-Valor do Seguro do item ( Opcional )
					0,;             		// 12-Valor do Frete Autonomo ( Opcional )
					nVlrMerc,;      		// 13-Valor da Mercadoria ( Obrigatorio )
					0)              		// 14-Valor da Embalagem ( Opiconal )	
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Altera peso para calcular frete              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAlt("IT_PESO",nQtdPeso,nItem)

       	TRB->(DbSkip())
       	
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a tela de exibicao dos valores fiscais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE STR0058 FROM 09,00 TO 28,80 //"Planilha Fiscal"

	MaFisRodape(1,oDlg,,{005,001,310,60},Nil,.T.)
	@ 070,005 SAY RetTitle("F2_FRETE")		SIZE 40,10 PIXEL OF oDlg
	@ 070,105 SAY RetTitle("F2_SEGURO")		SIZE 40,10 PIXEL OF oDlg
	@ 070,205 SAY RetTitle("F2_DESCONT")	SIZE 40,10 PIXEL OF oDlg
	@ 085,005 SAY RetTitle("F2_FRETAUT")	SIZE 40,10 PIXEL OF oDlg
	@ 085,105 SAY RetTitle("F2_DESPESA")	SIZE 40,10 PIXEL OF oDlg
	@ 085,205 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL OF oDlg
	@ 070,050 MSGET MaFisRet(,"NF_FRETE")		PICTURE PesqPict("SF2","F2_FRETE",16,2)		SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 070,150 MSGET MaFisRet(,"NF_SEGURO")  	PICTURE PesqPict("SF2","F2_SEGURO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 070,250 MSGET MaFisRet(,"NF_DESCONTO")	PICTURE PesqPict("SF2","F2_DESCONT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 085,050 MSGET MaFisRet(,"NF_AUTONOMO")	PICTURE PesqPict("SF2","F2_FRETAUT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 085,150 MSGET MaFisRet(,"NF_DESPESA")		PICTURE PesqPict("SF2","F2_DESPESA",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 085,250 MSGET MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 105,005 TO 106,310 PIXEL OF oDlg
	@ 110,005 SAY   STR0059   SIZE 40,10 PIXEL OF oDlg //"Total da Nota"
	@ 110,050 MSGET MaFisRet(,"NF_TOTAL")      PICTURE PesqPict("SF2","F2_VALBRUT",16,2) 	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 110,270 BUTTON STR0060			SIZE 040,11 ACTION oDlg:End() OF oDlg PIXEL		//"Sair"

	ACTIVATE MSDIALOG oDlg CENTERED
	
	MaFisEnd()
	MaFisRestore()
	
Endif

RestArea(aAreaTRB)	
RestArea(aAreaSA1)
RestArea(aArea)

Return(.T.)                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720DevSD2ºAutor  ³ Vendas Cliente    º Data ³  23/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o documento de entrada baseado na Nota fiscal de      º±±
±±ºDesc.     ³ origem existente no SD2.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Codigo do cliente                       			  º±±
±±º          ³ExpN2 - Codigo da loja                       				  º±±
±±º          ³ExpC3 - Array com os Recnos da tabela SD2                   º±±
±±º          ³ExpC4 - Indica se eh formulario proprio ou nao              º±±
±±º          ³ExpN5 - Numero do documento de entrada                      º±±
±±º          ³ExpN6 - Serie do documento de entrada                       º±±
±±º          ³EXpA7 - Armazena a serie, numero e cliente+loja da NF de    º±±
±±º          ³   	  devolucao e o tipo de operacao(1=troca;2=devolucao) º±± 
±±º          ³ExpN8 - Opcao selecionada. 1-Troca ou 2-Devolucao           º±±
±±º          ³ExpN9 - Forma de devolucao ao cliente: 1-Dinheiro;2-NCC     º±±
±±º          ³ExpN10- Valor total de produtos trocados ou devolvidos      º±±
±±º          ³ExpA11- Guarda a posicao do SD2                             º±±
±±º          ³Expl12- Devolucao em varias moedas (localizazoes)           º±±
±±º          ³ExpA13- Dados da devolucao                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720DevSD2( cCliente  	, cLoja     , aRecSD2  	,lFormul  	,;
							 cNumDoc   	, cSerieDoc	, aDocDev  	,nTpProc  	,;
							 nFormaDev	, nVlrTotal	, aPosSd2	, lDevMoeda	,;
							 aDevol    	, cCodDia	, cMotivo	, nImpostos ,;
							 cChvNFE 	, cTpEspecie, cCodFil	, lDevNF	,;
							 lDevFrete	, nNFOrig	, nFrtSegDes, nRetIcms	)

Local lRet			:= .T.		                                	// Retorno da funcao, valida rotina automatica
Local aArea     	:= GetArea()		                          	// Area corrente
Local aAreaSF2  	:= SF2->(GetArea()) 		                  	// Area do arquivo SF2
Local aCab      	:= {}                       		          	// Contem os campos e valores correspondentes para geracao da NF de devolucao
Local aItens    	:= {}		     							   	// Contem os itens do documento de entrada utilizado para a rotina automatica
Local cTipoNF   	:= ""       		                          	// Tipo do documento de entrada
Local lDevolucao	:= .T.		                                	// Controla se dados invalidos
Local lPoder3   	:= .T.                              		  	// Valida se o TES controla poder de terceiros
Local nX        	:= 0        		                          	// Controle de loop
Local cSerie    	:= PadR(SuperGetMv("MV_LJNFTRO"),3)	 		 	// Serie padrao para troca/devolucao
Local cNewDoc		:= CriaVar("F1_DOC",.F.)						// Numero do documento de entrada gerado
Local cMv_CondPad	:= SuperGetMv("MV_CONDPAD")						// Condicao de pagamento padrao
Local lUsafd      	:= SuperGetMV("MV_LJUSAFD",,.F.) 				// Parametro que define se o cliente utiliza Vale Compra
Local cNotaOri		:= ""											// Nota de origem
Local cSerieOri		:= ""						 					// Serie de origem
Local lLj720Cabec   := ExistBlock("LJ720CABEC")        			    // Verifica se o PE LJ720CABEC existe
Local cOldDoc       := TRB->TRB_NFORI                 		      	// Numero do Documento anterior de venda 
Local cGrupoProd	:= ""	 										//Grupo de produtos
Local aProdCri		:= {}											// Array com os produtos para analise de criterio de pontos
Local nTotDev		:= 0    		                                // Total devolvido para controle da pontuacao da fidelidade
Local cMV_TPNRNFS	:= LJTpNrNFS()	  								// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")    				// parametro que indica o CLIENTE PADRAO
Local cTipo			:= "2"						 					// Tipo da Operacao: 2 = devolucao
Local nPosTot		:= 0											// Posicao do total da devolucao	
Local nPosIteOri	:= 0											// Posicao do item de origem da devolucao
Local nPosProd		:= 0					   						// Posicao do produto 
Local nPosQtd		:= 0 					   						// Posicao da quantidade
Local cFormul       := ""                      			             // Formulario proprio
Local cTipoDoc      := ""                      			             // Tipo da NF
Local aRecAltSD2	:= {}									// alterada valor do SD2
Local nMoedaOri     := 1                                    // Moeda da Nota Fiscal de Origem
Local nTxMoedaOri   := 1                                    // Taxa da moeda a nota fiscal de Origem
Local cCliOri		:= ""                                   // Cliente da Nota Fiscal de Origem
Local cLojCliOri    := ""                                   // Loja da Nota fiscal de Origem
Local aVales        := {}									// Array com os vales compras utilizado na venda
Local cOper
Local aDados		:= {}
Local aRetCF		:= {}
Local aMsgCert		:= {}									// Mensagem na criação de fólios
Local nRecSF2		:= 0									// recno da SF2
Local lGeraXml		:= .F.									// valida se pode ou não gerar XML para os registros de venda
Local lContrFol     :=	SF1->(ColumnPos("F1_NUMAUT")) > 0 .And. SF1->(ColumnPos("F1_CODCTR")) > 0 .And.;
						SF2->(ColumnPos("F2_NUMAUT")) > 0 .And. SF2->(ColumnPos("F2_CODCTR")) > 0 .And.;
						SF2->(ColumnPos("F2_LIMEMIS")) > 0 .And. SF3->(ColumnPos("F3_NUMAUT")) > 0 .And.;
						SF3->(ColumnPos("F3_CODCTR")) > 0 .And. GetNewPar("MV_CTRLFOL",.F.)

Local lMotDev	:= SF1->(ColumnPos("F1_MOTIVO")) > 0
Local lQuebra		:= .F.
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI		  ³
Local lCFolLocR5	:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI" .AND. !lFiscal
Local lEmitNfce		:= ExistFunc("LjEmitNFCe") .AND.  LjEmitNFCe()								// Sinaliza se utiliza NFC-e
Local cFilDocOri 	:= "" //Filial do Documento de Origem (D2_FILIAL)
Local nFrete  		:= 0
Local nSeguro		:= 0
Local nDespesa		:= 0
Local cTpFrete		:= ""
Local lGeraCFD		:= cPaisLoc == "MEX" .AND. AliasIndic("MDL")
Local aTimeUf		:= {}
Local aArea2		:= {}
Local aAreaSM0		:= {}
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.)		// Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local cHoraRMT		:= SuperGetMv("MV_HORARMT",.F.,"2")	//Parametro MV_HORARMT habilitado pega a hora do smartclient, do servidor ou do Estado da Filial
Local l103Hora		:= ExistFunc("A103HORA")
Local cHoraNota		:= ""
Local aNotasOri		:= {} //Array com as Notas de Origem
Local aItensOri		:= {} //Array com itens e a Notas de Origem
Local nC			:= 0
Local nDocumento	:= 0 //Posicao do Documento
Local nSerie		:= 0 //Posicao da serie Serie

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

Default lFormul		:= .T.
Default cNumDoc		:= ""
Default cSerieDoc	:= ""
Default aDevol		:= {}
Default cCodDia     := ""                            
Default cMotivo		:= ""		
Default nImpostos	:= 0
Default cTpEspecie	:= CriaVar("F1_ESPECIE",.F.)
Default	lDevNF		:= .F.
Default nNFOrig		:= 1	// 1-Com documento de Entrada / 2-Sem documento de entrada
Default nFrtSegDes  := 0 //Valor do Frete/Seguro/Despesa
Default nRetIcms	:= 0	//Retorno ICMS - Substituição Tributária

LjGrvLog( "TROCA_DEVOLUCAO", "Serie padrao para troca/devolucao - MV_LJNFTRO", cSerie)
LjGrvLog( "TROCA_DEVOLUCAO", "Condicao de pagamento padrao - MV_CONDPAD", cMv_CondPad)
LjGrvLog( "TROCA_DEVOLUCAO", "Parametro que define se o cliente utiliza Vale Compra - MV_LJUSAFD", lUsafd)
LjGrvLog( "TROCA_DEVOLUCAO", "Verifica se o local fisico do servidor está em Horário de Verão - MV_HVERAO", lHVerao)
LjGrvLog( "TROCA_DEVOLUCAO", "Parametro habilitado pega a hora do smartclient, do servidor ou do Estado da Filial - MV_HORARMT", cHoraRMT)
If lFormul
   cFormul  := "S"
Else
   cFormul  := "N"
Endif   

aRecnoSD2	:= {}
lQuebra 	:= .F.
				
For nX := 1 to Len(aRecSD2)
	IF !lDevNF		//Processo original de estorno baseado no loja720
		If !aRecSD2[nX][3] //Não executa se for somente Garantia Estendida ou Servico Financeiro
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o produto foi deletado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("TRB")                                        
		    TRB->(DbSetOrder(1))
			If TRB->(DbSeek(aRecSD2[nX][2]))
				If !TRB->TRB_FLAG  
					DbSelectArea("SD2")                                        
					SD2->(DbGoTo(aRecSD2[nX][2]))
					lRet := LJ720GtD1( 	aRecSD2  	, aPosSd2   	,	@lDevolucao	,	@lPoder3   	,;
					                  	@cTipoNF 	, aRecAltSD2	,	aItens     	,	@cFilDocOri	,;
					                  	nX			, aRecnoSD2 	,	@cNotaOri  	,	@cSerieOri 	,;
					                  	@cCodFil	, @lQuebra  	,	@nFrete    	,	@nSeguro   	,;
					                  	@nDespesa	, lDevFrete 	,	nNFOrig		, 	@aNotasOri	,;
					                  	@aItensOri	, @nRetIcms)

					If cPaisLoc == "MEX"
						//Segundo a legislação quando eu tenho somente uma devolução devo usar outra série
						//e quando para essa venda tiver sido gerada a nota sobre cupom, dai devo inserir a série padrão
						If !Lj720IsFac(cCodFil , SD2->D2_DOC, SD2->D2_SERIE) 
							cSerie := PadR(SuperGetMV("MV_LJDVVND",,""),3)
							lGeraXml:= .F.
						Else
							lGeraXml:= .T.
						EndIf
					EndIf

					If lQuebra
						Exit
					Endif
				EndIf
			EndIf
		EndIf

	Else		//Processo novo para estorno de notas fiscais de venda futura	
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto foi deletado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If !aRecSD2[nX][3] //Não executa se for somente Garantia Estendida ou Servico Financeiro 
		 	DbSelectArea("SD2")                                        
			SD2->(DbSetOrder(1))
			SD2->(dbGoto( aRecSD2[nX][2] ))
			lRet := LJ720GtD1(	aRecSD2 	, aPosSd2   	,	@lDevolucao	,	@lPoder3   	,;
	                         	@cTipoNF	, aRecAltSD2	,	aItens     	,	@cFilDocOri	,;
	                         	nX      	, aRecnoSD2 	,	@cNotaOri  	,	@cSerieOri 	,;
	                         	@cCodFil	, @lQuebra  	,	@nFrete    	,	@nSeguro   	,;
	                         	@nDespesa	, lDevFrete 	,	nNFOrig		,   @aNotasOri	,;
	                         	@aItensOri	, @nRetICMS	)

			If cPaisLoc == "MEX"
				//Segundo a legislação quando eu tenho somente uma devolução devo usar outra série
				//e quando para essa venda tiver sido gerada a nota sobre cupom, dai devo inserir a série padrão
				If !Lj720IsFac(cCodFil , SD2->D2_DOC, SD2->D2_SERIE) 
					cSerie := PadR(SuperGetMV("MV_LJDVVND",,cSerie),3)
					lGeraXml:= .F.
				Else	
					lGeraXml:= .T.
				EndIf
			EndIf

			If lQuebra
				Exit
			Endif
		EndIf
	Endif	
Next nX

nFrtSegDes := nFrete+nDespesa+nSeguro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a database se a data de movimento da impressora³
//³for diferente da data cronologica da impressora         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal .AND. !lEmitNfce
	LjEcfIFData()
Endif

DbSelectArea("SD2")
If lDevolucao .AND. lRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena nas variaveis a primeira posicao do aPosSd2,³
	//³pois somente esta posicao e' utiliza para o Seek     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aPosSd2) > 0
   		cCliOri		:= aPosSd2[1][3]
   		cLojCliOri	:= aPosSd2[1][4]
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o SF2 para pegar o valor da moeda e sua taxa da NF de Origem ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))     		// FILIAL + DOCUMENTO+ SERIE + CLIENTE + LOJA
		If SF2->(DbSeek(FWxFilial("SF2",cCodFil)+cNotaOri+cSerieOri+ cCliOri+cLojCliOri))
			nMoedaOri	:= SF2->F2_MOEDA 						
			nTxMoedaOri	:= SF2->F2_TXMOEDA 
			cTpFrete:= SF2->F2_TPFRETE
    	EndIf  
    EndIf	

    If !Empty(cNumDoc) .AND. !Empty(cSerieDoc) .AND. !lFormul
		cNewDoc	:= cNumDoc
		cSerie	:= cSerieDoc
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
		//³ cMV_TPNRNFS for igual a "3"                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
		If cMV_TPNRNFS == "3"

			//se a nota fiscal vai ser transmitida, a nota/troca deverá ser vinculada a uma nota de saída
			If !LjNFeEntOk(cSerie, lFormul, nNfOrig , NIL)
				Return .F.
			EndIf
			
			cNumDoc := MA461NumNf( .T., cSerie )
		Else							    
	        If !Lj720Nota(@cSerie, @cNumDoc, lFormul, nNFOrig, NIL)
		   		Return .F.
	    	Endif
	    Endif
        cNewDoc    := cNumDoc
		cSerieDoc  := cSerie
	Endif
	
	//se formulario proprio, retornamos a especie baseada na serie padrao para Troca/Devolucao
	If lFormul
		cTpEspecie := LjEspecie(cSerie)
	EndIf

	If cTipoNF == "B"
	   cTipoDoc  := "N"
	Else   
	   cTipoDoc  := "B"
	Endif   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a serie esta valida - Controle de folios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContrFol .AND. !ChkFolURU(cFilAnt,cSerie,cNewDoc,Nil,.F.,"NCC")
		lRet := .F.
	    DisarmTransaction()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cancela a Sequencia de nota utilizada conforme configuracao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    Lj720CnSD9(cNewDoc, cSerie, cMV_TPNRNFS)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Controle de Formulario  ³
	//³Verificar se existe um formulario 	  ³
	//³valido para a serie/nota escolhida.    ³
	//³Paises:Chile/Colombia - F1CHI		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lCFolLocR5 .AND. lFormul
		If nTpProc == 2 .AND. nFormaDev == 1	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para DEVOLUCAO em dinheiro, nao importa a especie do formulario          ³
			//³vinculado a serie informada no parametro MV_LJNFTRO   					³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cListEspOp 	:= "1|2|3|4|5|6|7|8|9|A"		
		Else                 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para TROCA ou DEVOLUCAO em NCC,a especie do  		³
			//³formulario escolhido vinculado a serie informada     ³
			//³no parametro MV_LJNFTRO deve ser do tipo NCC (8)     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			cListEspOp := "8"
		EndIf

		If !ChkFolCHI(	xFilial("SFP")	,	cSerie, 	cNewDoc, 	cListEspOp,;
						NIL,		.F.)
			MsgAlert (STR0131)//"Verifique o parâmetro MV_LJNFTRO.Informe uma série de um controle de formulários válido."
			lRet := .F.
			DisarmTransaction()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cancela a Sequencia de nota utilizada conforme configuracao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Lj720CnSD9(cNewDoc, cSerie, cMV_TPNRNFS)
		EndIf	
	EndIf
	If lRet

		//Parametro MV_HORARMT habilitado pega a hora do smartclient, do servidor ou do Estado da Filial
		If cHoraRMT == "1"
			cHoraNota := SubStr(GetRmtTime(),1,8)

		ElseIf cHoraRMT == "3"
			If cPaisLoc == "BRA"
				aArea2	:= GetArea()
				dbSelectArea("SM0")
				aAreaSM0 := GetArea()
				dbSetOrder(1)
				
				If dbSeek(cEmpAnt+cFilAnt)
					If l103Hora
						aTimeUf := A103HORA()
					Else
						aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao)
					EndIf	
				EndIf
				
				RestArea(aAreaSM0)
				RestArea(aArea2)
				
				cHoraNota := SubStr(aTimeUf[2],1,8)
			Else
				cHoraNota := SubStr(GetRmtTime(),1,8)
			EndIf
		
		Else // 2- Default (data do servidor)
			cHoraNota := SubStr(Time(),1,8)
		EndIf

		/*
		BEGIN TRANSACTION
		Retirar esse comentario apos a build 20161016 do DBAccess com data de geração 20170308 estiver disponivel para cliente,
		pois ela deve corrigir o problema do FwTemporaryTable no meio de uma transacao
		*/

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFiscal .AND. cPaisLoc == "ARG" .AND. cTpEspecie $ "NCC|NDC"
			cNewDoc := GetNumCFis(cSerie,cTpEspecie)
			cNumDoc := cNewDoc
		EndIf
		AAdd( aCab, { "F1_DOC"    , cNewDoc		, Nil } )	// Numero da NF : Obrigatorio
		AAdd( aCab, { "F1_SERIE"  , cSerie		, Nil } )	// Serie da NF  : Obrigatorio
		If SF1->(ColumnPos("F1_CHVNFE")) > 0 .And. !Empty(cChvNFE)
			AAdd( aCab, { "F1_CHVNFE" , cChvNFE	, Nil } )	// Chave da NFe
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o cabecalho de acordo com o tipo da devolucao             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lPoder3
			AAdd( aCab, { "F1_TIPO"   , "D"                  	, Nil } )	// Tipo da NF   : Obrigatorio
		Else
			AAdd( aCab, { "F1_TIPO"   , cTipoDoc	              , Nil } )	// Tipo da NF   : Obrigatorio		
		Endif
		
		AAdd( aCab, { "F1_FORNECE", cCliente    					, Nil } )	// Codigo do Fornecedor : Obrigatorio
		AAdd( aCab, { "F1_LOJA"   , cLoja    	   					, Nil } )	// Loja do Fornecedor   : Obrigatorio
		AAdd( aCab, { "F1_EMISSAO", dDataBase           			, Nil } )	// Emissao da NF        : Obrigatorio
		AAdd( aCab, { "F1_FORMUL" , cFormul                     , Nil } ) 	// Formulario Proprio
		AAdd( aCab, { "F1_ESPECIE", cTpEspecie                  , Nil } )	// Especie
		AAdd( aCab, { "F1_COND"   , cMv_CondPad   	  			, Nil } )	// Condicao do Fornecedor
		AAdd( aCab, { "F1_HORA"   , cHoraNota   	  				, Nil } )	// Hora Nota de Devolução
		
		If lDevFrete
			/*
			|| Em devoluções os valores de Frete, Seguro e Despesa são somados e incluso no campo Despesa conforme definição Fiscal:
			|| https://tdn.totvs.com/pages/releaseview.action?pageId=440834321
			*/
			AAdd( aCab, { "F1_DESPESA"	, nFrtSegDes    			, Nil } )	// Frete /Seguro /Despesa
		EndIf
		AAdd( aCab, { "F1_TPFRETE"	, cTpFrete    				, Nil } )	// Tipo Frete
		
		If cPaisLoc <> "BRA" 
			AAdd( aCab, { "F1_TIPODOC" 	, "04"   	  				, Nil } )	// Tipo de documento
			AAdd( aCab, { "F1_MOEDA"   	, nMoedaOri	   	  		, Nil } )	// Numero da Moeda
			AAdd( aCab, { "F1_TXMOEDA" 	, nTxMoedaOri		   	  	, Nil } )	// Taxa da Moeda
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nota fiscal eletronica Mexico             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If lGeraXml .And. lGeraCFD .And. SA1->(ColumnPos("A1_MODCFD")) > 0
				
                nRecSF2 := SF2->(Recno())
                LOJXGERCFD(.F.,.T.,aMsgCert)
				SF2->(DbGoTo(nRecSF2))
				
				AAdd( aCab, { "F1_APROFOL" 	, SF2->F2_APROFOL  	  	, Nil } )	// Numero da aprovacao do Folio
				AAdd( aCab, { "F1_CERTFOL" 	, SF2->F2_CERTFOL  	  	, Nil } )	// Certificado folio

				//Exibe tela com dados dos CFDs (Comprovante Fiscal Digital) gerados
				LJXListFol(aMsgCert)
			EndIf
		EndIf
	
		If cPaisLoc == "ARG" .AND. lFiscal
			AAdd( aCab, { "F1_ECF" 	, "1"		   	  				, Nil } )	// Indica que ira imprimir
		EndIf
	
		If cPaisLoc == "PTG"    // Portugal
			AAdd( aCab, { "F1_DIACTB" 	, cCodDia   	  				, Nil } )	// Codigo do Diario
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para controle de Folios³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lContrFol
			
			aDados := Array(6)
		
			aDados[1] := cSerie
			aDados[2] := cTpEspecie
			aDados[3] := cNewDoc
			If Alltrim(aDados[2]) $ "NDI/NCP"
				aDados[4] := GetAdvFVal("SA2","A2_CGC",xFilial("SA1")+cCliente+cLoja,1,"")
			Else
				aDados[4] := GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+cCliente+cLoja,1,"")
			Endif
			aDados[5] := DtoS(dDataBase)
			aDados[6] := 0//Round(SL1->L1_VALBRUT,0)
			
			aRetCF := RetCF(aDados)
			
			AAdd( aCab, { "F1_NUMAUT"   , aRetCF[1]		, Nil } )
			AAdd( aCab, { "F1_CODCTR"   , aRetCF[2]		, Nil } )
		
		EndIf
		
		AAdd( aCab, { "F1_EST" 	, SF2->F2_EST  	  	, Nil } )	// Estado de Origem

		// A variavel cMotivo só é alimentado de duas formas:
		// 01 - Legislacao no AM, onde se for uma devolucao de uma NFC-e, deve-se informar a tag <infAdFisco>
		// 02 - Países localizados		
		If lMotDev
			AAdd( aCab, { "F1_MOTIVO", cMotivo, Nil } )		
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para incluir campos adicionais no cabecalho da NF de devolucao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLj720Cabec
			LjGrvLog(Nil,"Antes da Chamada do Ponto de Entrada:LJ720CABEC",{aCab, aDocDev})
		   aCab := ExecBlock("LJ720CABEC",.F.,.F.,{aCab, aDocDev})
		   LjGrvLog(Nil,"Apos a Chamada do Ponto de Entrada:LJ720CABEC - aCab", aCab)
		Endif

		// Caso o campo SF1->F1_TPVENT estiver em branco e a localidade for ARGENTINA, esta sendo atribuido "B"
		// Neste caso esta sendo considerado que a Troca/Devolucao sera de um Produto
		// Isto se deve ao fato do SigaLoja nao estar gravando este campo
		If cPaisLoc=="ARG"
			AAdd( aCab, { "F1_PROVENT" 	, SM0->M0_ESTENT   	  	, Nil } )	// Provincia		
			If SF1->(ColumnPos('F1_TPVENT'))>0
				AAdd( aCab, { "F1_TPVENT" 	, "B"   	  			, Nil } )	// Tipo de Venda
			EndIf
		Endif				
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha itens a serem devolvidos                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aItens) > 0 .AND. lRet
	
			RetIndex("SD2")	
	
			If cPaisLoc == "BRA"
				LjGrvLog( "TROCA_DEVOLUCAO", "Executando o Mata103")
				Mata103( aCab, aItens , 3)
			Else
				LjGrvLog( "TROCA_DEVOLUCAO", "Executando o Mata465n")
				Mata465n( aCab, aItens , 3)		
			EndIf

			If !lMsErroAuto
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acerta o campo de devolucao caso a filial de origem da venda seja diferente da filial de troca/devolucao (cFilAnt)  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosTot		:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_TOTAL"})
				nPosIteOri	:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_ITEMORI"})
				nPosQtd		:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_QUANT"})
			        
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se Existir o Campo F1_NumMov,Grava o Numero do Ultimo Movimento do SLW ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF1->(!EOF())
					If SF1->(ColumnPos("F1_NUMMOV"))>0
						RecLock("SF1",.F.)
						REPLACE SF1->F1_NUMMOV WITH LJNumMov()
						MsUnLock("SF1")
					Endif
				EndIf	

				If cPaisLoc == "ARG"
					cNewDoc := SD1->D1_DOC
					cSerie	:= SD1->D1_SERIE
				EndIf

		    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    	//³Analise de credito integrada com SIGACRD                           ³
		    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    	If CRDxInt() .AND. lUsafd

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Nao pontuar quando for cliente padrao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    		If AllTrim(cCliPad) <> AllTrim(cCliente)

						nDocumento	:= aScan(aItensOri[1], { |i| i[1] == "DOCUMENTO"})
		    		    nSerie		:= aScan(aItensOri[1], { |i| i[1] == "SERIE"})
		    		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Localiza a posicao do produto e do total da devolucao no array³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    	nPosTot		:= aScan(aItensOri[1], {|x| AllTrim(x[1])=="D1_TOTAL"})
						nPosProd	:= aScan(aItensOri[1], {|x| AllTrim(x[1])=="D1_COD"})
				        nPosQtd		:= aScan(aItensOri[1], {|x| AllTrim(x[1])=="D1_QUANT"})

		    		    aSort(aItensOri, , , { |x,y| x[nSerie, 02] < y[nSerie, 02 ] .AND. x[nSerie, 02] < y[nSerie, 02]})

		    		    For nC := 1 to Len(aNotasOri)

							nTotDev := 0		// resetamos a variavel totalizadora
							aSize(aProdCri,0)	// resetamoso array que sera utilizado

							For nX := 1 to Len(aItensOri)
								If aItensOri[nX][nDocumento][02] == aNotasOri[nC][01] .AND. aItensOri[nX][nSerie][02] == aNotasOri[nC][02]
									Aadd( aProdCri, {aItensOri[nX][nPosProd][2], cGrupoProd, aItensOri[nX][nPosTot][2], aItensOri[nX][nPosQtd][2]} )
									cGrupoProd := Posicione("SB1", 1, xFilial("SB1") + aItensOri[nX][nPosProd][2], "SB1->B1_GRUPO")
									nTotDev += aItensOri[nX][nPosTot][2]
								Else
									Loop
								EndIf
							Next

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Chama a funcao para devolucao dos pontos. somente e utilizada se    ³
							//³o sistema tiver integracao com o CRD.                               ³
							//³OBS: Esta rotina gera um registro no MAX com o campo saldo negativo.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Len(aProdCri) > 0 .AND. Crd240_002(	cTipo				,;	// Tipo da Operacao: 1)Venda 2)Devolucao 3)Exclusao
																	cCliente  			,;	// Codigo do cliente
																	cLoja				,;	// Loja 
																	aProdCri			,;	// Array com os produtos para analise dos pontos
																	nTotDev				,;	// Total da Venda
																	aNotasOri[nC, 01]	,;	// Numero do documento  - Trocado cNewDoc para SL1->L1_DOC
																	cSerie				,;	// Serie
																	aNotasOri[nC, 01]	,; 	// Documento da venda original
																	aNotasOri[nC, 02]	,;	// Serie da venda original 
																	Nil					,; 	// Identifica se e do Loja ou do Televendas       
																	Nil					,; 	// Indica se grava MAX ou somente calcula pontos
																	Nil					,; 	// Total de pontos							   
																	Nil					) 	// Pagamento com Vale-Compra calcular sobre a dif.	

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Volta status do vale compra utilizado na venda ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If AliasInDic("MB1")                       // Verifica existencia da tabela
									DbSelectArea("MB1")
									MB1->( DbSetOrder(2) ) // MB1_FILIAL+MB1_SERIE+MB1_NF+MB1_CODIGO
									If MB1->( DbSeek(xFilial("MB1",cCodFil) + cSerieOri + cNotaOri) )
										While !EOF() .AND. MB1->MB1_FILIAL + MB1->MB1_SERIE + MB1->MB1_NF == xFilial("MB1",cCodFil) + aNotasOri[nC, 02] + aNotasOri[nC, 01]
											If MB1->MB1_OPER == 3 .OR. MB1->MB1_OPER == 2	// Utilizado ou Resgatado
												aVales := {{MB1->MB1_CODIGO, Nil, Nil, MB1->MB1_CODIGO, .F.}}

												If MB1->MB1_OPER == 2
													cOper := "4"
												ElseIf MB1->MB1_OPER == 3
													cOper := "2"
												EndIf

												// Em caso de devolucao altera o status do vale compra
												If !Crd240UpdMAV( aVales, cOper )
													Aviso( STR0006,STR0077,{STR0048} )
												Else
													aVales := {MB1->MB1_CODIGO,Nil,Nil,MB1->MB1_CODIGO,.F.}
													CRDA270Log( aVales, cOper, cNewDoc, AllTrim( LjGetStation("LG_PDV") ), cSerie, cCliente  )			 	
												EndIf
											EndIf
											DbSelectArea("MB1")
											MB1->( DbSkip() )
										End
									EndIf
								EndIf	
							Endif							
						Next nC 
					Endif
				Endif				
			EndIf
	
			If lMsErroAuto
				/*
				DISARMTRANSACTION()
				Retirar esse comentario apos a build 20161016 do DBAccess com data de geração 20170308 estiver disponivel para cliente,
				pois ela deve corrigir o problema do FwTemporaryTable no meio de uma transacao
				*/

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cancela a Sequencia de nota utilizada conforme configuracao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    Lj720CnSD9(cNewDoc, cSerie, cMV_TPNRNFS)
			    
				If IsBlind()
					Conout("LOJA720 - SF1 - Erro na ExecAuto -> " + MOSTRAERRO() )
				Else
					MOSTRAERRO()
				EndIf
				
				lRet:= .F. 
			Else
				
				lMsHelpAuto := Nil   //Limpa as variaveis automaticas.  
				lMsErroAuto := Nil   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os campos do processo do SIGALOJA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³BOPS 108277 - Inclusao do parametro       ³
				//³nTpProc para a funcao LJ720ATUNFE.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Lj720AtuNFE( cNewDoc   	, cSerie	, cCliente	, cLoja 	, ;
				             nFormaDev 	, nTpProc	, cMotivo	, @nImpostos, ;
				             xNumCaixa(), .F.		, cFilDocOri )
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se selecionar as opcoes "Devolucao" e "Dinheiro", exclui a NCC gerada e gera registro de ³
				//³saida de numerario 																	    ³			
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nFormaDev == 1 .AND. nTpProc == 2
					LjGrvLog( "TROCA_DEVOLUCAO", "Executando devolucao em dinheiro")
				   Lj720DevDinh( cNewDoc   ,cSerie  ,cCliente  ,cLoja  ,;
				                  nVlrTotal	,@lDevMoeda	,@aDevol	,nImpostos, ;
				                  xNumCaixa(),			,			,nFrete+nSeguro+nDespesa,;
				                  nRetIcms)
				Endif
				
				aDocDev  := {cSerie,cNewDoc,cCliente, cLoja, nTpProc , cOldDoc , {} } 
			
				//Envia os dados para integracao
				If SuperGetMv("MV_LJOFFLN", Nil, .F.)
					Lj720AtInt()
				Endif
				LjImpCNfisc( aDocDev, nVlrTotal )
			Endif
		EndIf
		
		/*
		END TRANSACTION
		Retirar esse comentario apos a build 20161016 do DBAccess com data de geração 20170308 estiver disponivel para cliente,
		pois ela deve corrigir o problema do FwTemporaryTable no meio de uma transacao
		*/

		If lRet .AND.  Len(aItens) > 0
			MsgInfo(STR0053+ cNewDoc + " / " + cSerie) //"Foi gerado o documento de entrada "
		EndIf	
	Else
		Help(" ",1,"OMS320NFD") //Nota Fiscal de devolucao ja gerada
		lRet:= .F.
	Endif
Endif

RestArea( aArea )
RestArea( aAreaSF2 )

Return lRet


/* 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Lj720AtuNfe ³ Autor ³ Vendas Cliente      ³ Data ³ 16.08.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Autaliza dos dados do documento de   entrada de acordo com  ³±±
±±³          ³ os processos do loja                                        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Numero do documento                                  ³±±
±±³          ³ ExpC2: Serie do documento                                   ³±±
±±³          ³ ExpC3: Codigo do cliente                                    ³±±
±±³          ³ ExpC4: Loja do cliente                                      ³±±
±±³          ³ ExpN5: Forma de devolucao: 1-Dinheiro;2-NCC                 ³±±
±±³          ³ ExpN6: Tipo da Operacao: 1-Troca; 2-Devolucao (opcional)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720AtuNfe( 	cNewDoc   	, cSerie	, cCliente	, cLoja 	, ;
						nFormaDev 	, nTpProc	, cMotivo	, nImpostos	, ;
						cCaixa		, lEstorn	, cFilDocOri )

Local aArea         := GetArea()							//Salva ambiente
Local cPrefixoEnt	:= ""									//Prefixo da nota de entrada
Local lAchouSF1		:= .F.									//Se achou o SF1      
Local cUfDevolu		:= ""									//Uf da devolucao.
Local lMotDev		:= SF1->(ColumnPos("F1_MOTIVO")) > 0
Local aTesImp		:= {}									//Array de retorno da funcao TesImpInf()
Local nXImpostos	:= 0									//Contador que varre os impostos
Local aDadosCFO		:= {}									//Dados da CF   
Local aAreaSF4		:= SF4->(GetArea())						//WorkAreaSF4
Local cCfOpF4		:= ""									//CFOP do Item
Local cTpNfEnt		:= ""
Local aAreaSD2 		:= SD2->(GetArea())

Default nTpProc		:= 0									//1=Troca, 2=Devolucao
Default cMotivo		:= ""
Default nImpostos   := 0									//Valores dos Impostos do D1 a serem somados 
Default cCaixa 		:= xNumCaixa()
Default lEstorn 	:= .F.
Default cFilDocOri  := Nil

nImpostos := 0                         

SF4->(DbSetOrder(1)) //F4_FILIAL + F4_COD

DBSelectArea( "SA1" )
SA1->(DBSetOrder( 1 ))
If SA1->(DBSeek( xFilial("SA1") + cCliente + cLoja ))
	cUfDevolu	:= SA1->A1_EST
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca os dados do SD1 criados e atualiza com os processos do loja³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SD1")
SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
If SD1->(DbSeek( xFilial("SD1") + cNewDoc + cSerie + cCliente + cLoja ))

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(DbSeek( xFilial("SF1") + cNewDoc + cSerie + cCliente + cLoja ))
		cTpNfEnt := SF1->F1_TIPO
		RecLock("SF1", .F.)
		REPLACE	SF1->F1_ORIGLAN	With "LO"
		If lMotDev
			REPLACE SF1->F1_MOTIVO With cMotivo
		Endif
		SF1->(MsUnlock())

		lAchouSF1 := .T.
	Endif

	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->(DbSeek( FWxFilial("SE1",SD1->D1_FILORI)+SD1->D1_NFORI+SD1->D1_SERIORI ))
		//Deve ser considerado a UF da nota de Origem da venda
		cUfDevolu := Iif(cTpNfEnt $ "DB" .And. !Empty(SD2->D2_EST), SD2->D2_EST, cUfDevolu)
	EndIf
		
	While !SD1->(Eof()) .AND. SD1->D1_FILIAL  == xFilial("SD1")	.AND. ;
					    SD1->D1_DOC		== cNewDoc			.AND. ;
						SD1->D1_SERIE	== cSerie			.AND. ;
						SD1->D1_FORNECE	== cCliente			.AND. ;
						SD1->D1_LOJA	== cLoja
											
		RecLock("SD1", .F.)
		REPLACE	SD1->D1_ORIGLAN	WITH "LO"
		REPLACE	SD1->D1_NUMCQ	WITH xNumCaixa()	
		If lEstorn .and. ColumnPos("D1_OPERADO") > 0
			REPLACE	SD1->D1_OPERADO	WITH cCaixa
		EndIf	
		
		// Ajusta do CFOP
        // Devolução de Cliente fora do Estado da venda, estava gravando CFOP do Estado da venda.
        // Com o retorno da funcao MaFisCfoa, esta gravando corretamente CFOP de fora do Estado.
       	SF4->(DbSeek(xFilial("SF4") + SD1->D1_TES))
        
		aDadosCfo := {}
		Aadd(aDadosCfo,{"OPERNF"	, "E"				})
		Aadd(aDadosCfo,{"TPCLIFOR"	, SA1->A1_TIPO		})
		Aadd(aDadosCfo,{"UFORIGEM"	, cUfDevolu			})
		Aadd(aDadosCfo,{"INSCR"		, SA1->A1_INSCR		})
		
		If SA1->(ColumnPos("A1_CONTRIB")) > 0 		 	
			Aadd(aDadosCfo,{"CONTR"	, SA1->A1_CONTRIB	})
		EndIf
		
		cCfOpF4	:= MaFisCfo(,SF4->F4_CF,aDadosCfo)
			
		If !Empty(cCfOpF4)
			Replace SD1->D1_CF With cCfOpF4
		EndIf	
	
		SD1->(MsUnlock())
		
		aTesImp := TesImpInf(SD1->D1_TES)					// Carrega retorno da função no array de impostos

		For nXImpostos := 1 To Len(aTesImp)					// Le todos os impostos
			If aTesImp[nXImpostos][3] == '1'				// Verifica se o imposto sera agregado ao valor do item
				nImpostos += &(aTesImp[nXImpostos][2])		// Agrega a somatoria de impostos o valor do campo de imposto (ex: D1_VALIMP1)
			EndIf
		Next nXImpostos		
		SD1->(DbSkip())
	End										
Endif		                  

RestArea(aAreaSF4)
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca o prefixo da nota de entrada para atualizar a NCC    ³
//³Forma de devolucao: NCC    								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFormaDev == 2
	If lAchouSF1
		cPrefixoEnt := SF1->F1_PREFIXO
	Else
		cPrefixoEnt := cSerie
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o portador da Nota de Credito de acordo com o Caixa da operacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE1")
	DbSetOrder( 2 )
	If DbSeek( xFilial("SE1") + cCliente + cLoja + cPrefixoEnt + cNewDoc  )
		
		While !Eof() .AND. 	SE1->E1_FILIAL 	    == xFilial("SE1")	.AND. ;
							SE1->E1_CLIENTE		== cCliente       	.AND. ;
							SE1->E1_LOJA		== cLoja          	.AND. ;
							SE1->E1_PREFIXO		== cPrefixoEnt    	.AND. ;
							SE1->E1_NUM			== cNewDoc
			
			If (SE1->E1_TIPO $ MV_CRNEG)
				RecLock("SE1",.F.)
				REPLACE SE1->E1_PORTADO WITH cCaixa
				REPLACE SE1->E1_NATUREZ WITH &( SuperGetMV("MV_NATNCC") )
				REPLACE SE1->E1_ORIGEM	WITH "LOJA720"
				MsUnlock()
			Endif
			
			DbSkip()
		End
	Endif
Endif

Restarea( aAreaSD2 )
Restarea( aArea )

Return( .T. )



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Lj720Comp ³ Autor ³ Vendas Cliente        ³ Data ³ 16.08.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para realizacao de manutencao na NCC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Parametro do processo desejado                      ³±±
±±³          ³         1 - Exclui a NCC                                    ³±±
±±³          ³         2 - Baixa a NCC                                     ³±±
±±³          ³         3 - Exclui Titulos do contas a receber              ³±±
±±³          ³ ExpC2 : Serie da nota de Entrada                            ³±±
±±³          ³ ExpC3 : Numero do documento de saida                        ³±±
±±³          ³ ExpC4 : Serie da nota de Saida                              ³±±
±±³          ³ ExpC5 : Codigo do cliente                                   ³±±
±±³          ³ ExpC6 : Loja do cadastro do cliente                         ³±±
±±³          ³ ExpC7 : Numero do Caixa                                     ³±±  
±±³          ³ ExpC8 : Valor total de produtos trocados ou devolvidos      ³±±  
±±³          ³ ExpC9 : Prefixo de entrada                                  ³±±  
±±³          ³ ExpC10: Prefixo de Saida                                    ³±±
±±³          ³ ExpA11: NCC geradas na devolucao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj720Comp( cTitEnt		,	cSerieEnt		,	cTitSaida	,	cSerieSaida	,;
                           cCliente 	,	cLoja			,	cNumPDV		,	nVlrTotal	,;
                           cPrefixoEnt	,	cPrefixoSaida	,	aNCC		, 	cCodFil 	,;
                           lCompTitCo)

Local aSE1CPS			:= {}					// Array com os titulos do SE1
Local lRet				:= .T.					// Retorno da funcao
Local lCompensa			:= .T.					// Indica se o titulo deve ser compensado
Local cMV_CLIPAD  		:= SuperGetMV("MV_CLIPAD")			// Cliente padrao
Local cMV_LOJAPAD 		:= SuperGetMV("MV_LOJAPAD")			// Loja do cliente padrao
Local cFilSE1 			:= FWxFilial("SE1",cCodFil)
Local cFilSAE 			:= FWxFilial("SAE",cCodFil)
Local lljGerTx			:= SuperGetMV("MV_LJGERTX",,.F.) 							// indica se usa geracao de Contas a pagar para Adm. Financeira	
Local nx				:= 0  
Local aAreaSE1			:= {}

Default aNCC			:= {}     				// Array com as NCCs geradas na devolucao
Default cPrefixoEnt		:= cSerieEnt	
Default cPrefixoSaida	:= cSerieSaida
Default lCompTitCo := .T. //Compensa título completo?

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Traz os titulos do respectivo documento        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SE1->( DbSetOrder(1) ) //E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
If SE1->( DbSeek(cFilSE1 + cPrefixoSaida + cTitSaida) )	
	While SE1->(!Eof()) .AND. cFilSE1	== SE1->E1_FILIAL 	.AND.;
								SE1->E1_PREFIXO	== cPrefixoSaida 	.AND.;
								SE1->E1_NUM		== cTitSaida

		lCompensa := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o cliente e uma administradora para nao compensar titulo de outro cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (AllTrim(SE1->E1_TIPO) $ "CC/CD/CO/VA/FI" ) .AND. ( SE1->E1_CLIENTE <> cCliente )
			SAE->( DbSetOrder( 1 ) )
			If SAE->( DbSeek(cFilSAE+ SubStr( SE1->E1_CLIENTE,1,3 )) )
				lCompensa := .T.
			Endif
		Else
			If 	(SE1->E1_CLIENTE == cCliente .AND. SE1->E1_LOJA == cLoja) .OR. (cMV_CLIPAD == SE1->E1_CLIENTE .AND. cMV_LOJAPAD == SE1->E1_LOJA)
				lCompensa := .T.
			Endif
		Endif
		
		LjGrvLog( "TROCA_DEVOLUCAO", "Indica se o titulo deve ser compensado - lCompensa", lCompensa)
				
		If lCompensa
			LjGrvLog( "TROCA_DEVOLUCAO", "SE1->E1_SITUACA $ '27'", SE1->E1_SITUACA $ "27")	
			LjGrvLog( "TROCA_DEVOLUCAO", "SE1->E1_SALDO == 0", SE1->E1_SALDO == 0)	
		   	If !( SE1->E1_SITUACA $ "27" .OR. SE1->E1_SALDO == 0 )
		   		LjGrvLog( "TROCA_DEVOLUCAO", "SE1->E1_TIPO", SE1->E1_TIPO)
		   		LjGrvLog( "TROCA_DEVOLUCAO", "MV_CRNEG", MV_CRNEG)
	     		If !( SE1->E1_TIPO $ MV_CRNEG )
		   			Aadd( aSE1Cps, SE1->(Recno()) )
		   		Endif
		   		LjGrvLog( "TROCA_DEVOLUCAO", "Array com o titulo a ser compensado - aSE1Cps", aSE1Cps)	
			Endif
		Endif
	    
		SE1->(DbSkip())
	End

Endif									

MaIntBxCR(3,aSE1Cps,Nil,aClone(aNCC),;
			,      ,    ,           ,;
			,      , IIF(!lCompTitCo, nVlrTotal, nil))

If lljGerTx .and. Len(aNCC) > 0 .AND. Len(aSE1Cps) > 0 .AND. FindFunction("Lj140ExCap")
 	
	aAreaSE1 := SE1->( GetArea() )			// Guarda area de origem do SE1
	SE1->( dbGoto(aNCC[1]) )
	nValorTitNcc := SE1->E1_VALOR
	
	If nValorTitNcc == Sl1->L1_VLRTOT 
		For nx := 1 to Len(aSE1Cps)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui registro do contas a pagar (Quando usar o conceito ³
			//³ de gerar contas a receber com valor bruto e contas a      ³
			//³ pagar com a taxa adminstrativa. parametro MV_LJGERTX = .T.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE1->( dbGoto(aSE1Cps[nx]) )
			Lj140ExCap()
		Next
	EndIf
	
	RestArea(aAreaSE1)		// Guarda area de origem do SE1
	
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720DevTRBºAutor  ³ Vendas Cliente    º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o documento de entrada baseado na tabela temporaria   º±±
±±ºDesc.     ³ TRB onde foram digitados os dados para realizar a entrada. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpN1 - Codigo do cliente                       			  º±±
±±º          ³ExpN2 - Codigo da loja                       				  º±±
±±º          ³ExpC3 - Indica se utiliza formulario proprio                º±±
±±º          ³ExpN4 - Numero do documento de entrada                      º±±
±±º          ³ExpN5 - Serie do  documento de entrada                      º±±
±±º          ³ExpA6 - Armazena a serie, numero e cliente+loja da NF de    º±±
±±º          ³ 		  devolucao e o tipo de operacao(1=troca;2=devolucao) º±±
±±º          ³ExpN7 - Opcao selecionada. 1-Troca ou 2-Devolucao           º±±
±±º          ³ExpN8 - Forma de devolucao ao cliente: 1-Dinheiro;2-NCC     º±±
±±º          ³ExpN9 - Valor total de produtos trocados ou devolvidos      º±±
±±º          ³ExpL10- Devolucao em varias moedas (Localizacoes)           º±±
±±º          ³ExpA11- Dados da devolucao         (Localizacoes)           º±±
±±º          ³ExpN12- Moeda corrente             (Localizacoes)           º±±
±±º          ³ExpN13- Taxa da moeda              (Localizacoes)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720DevTRB(cCliente 	, cLoja    	, lFormul	, cNumDoc   	,;
						 	cSerieDoc	, aDocDev  	, nTpProc	, nFormaDev 	,;
						 	nVlrTotal	, lDevMoeda	, aDevol 	, nMoedaCorT	,;
						 	nTxMoedaTr	, cMotivo   , nImpostos , cChvNFE 		,;
						 	cTpEspecie	, cMensagem	, nNFOrig	, nFrtSegDes	,;
						 	nRetIcms	, lAutomato)

Local lRet			:= .T.                               	// Retorno da funcao, valida rotina automatica
Local aArea     	:= GetArea()                         	// Area corrente
Local aAreaSF2  	:= SF2->(GetArea())                 	// Area do arquivo SF2
Local aCab      	:= {}                               	// Contem os campos e valores correspondentes para geracao da NF de devolucao
Local aLinha    	:= {}                               	// Contem os itens do documento de entrada utilizado para a rotina automatica
Local aItens    	:= {}     								// Contem os itens do documento de entrada utilizado para a rotina automatica
Local cTipoNF   	:= "D"    								// Tipo do documento de entrada
Local lDevolucao	:= .T. 									// Indica se houve devolucao
Local cTesDev   	:= SuperGetMv("MV_TESTROC",.F.)  		// TES padrao para troca de mercadorias
Local cSerie    	:= Padr(SuperGetMv("MV_LJNFTRO"),3) 	// Serie padrao para o documento de entrada
Local cNewDoc		:= CriaVar("F1_DOC",.F.)				// Numero do documento de entrada gerado
Local cMV_TPNRNFS	:= LJTpNrNFS()							// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local lLj720Cabec   := ExistBlock("LJ720CABEC")    			// Verifica se o PE LJ720CABEC existe
Local lUsafd      	:= SuperGetMV("MV_LJUSAFD",,.F.) 		// Parametro que define se o cliente utiliza Vale Compra
Local cGrupoProd	:= ""									// Grupo do produtos
Local aProdCri		:= {}									// Array com os produtos para analise de criterio de pontos
Local nTotDev		:= 0                                    // Total devolvido para controle da pontuacao da fidelidade
Local cTipo			:= "2"									// Tipo da Operacao: 2 = Devolucao
Local nX        	:= 0                                    // Contador utilizado na leitura dos produtos
Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")  		// parametro que indica o CLIENTE PADRAO
Local nPosTot		:= 0									// Posicao do total da devolucao	
Local nPosProd		:= 0									// Posicao do produto 
Local nPosQtd		:= 0									// Posicao da Quantidade
Local cFormul       := ""                                   // Formulario proprio
Local lMv_Rastro	:= If( SuperGetMv( "MV_RASTRO", Nil, "N" ) == "S", .T., .F. )		// Flag de verificacao do rastro             
Local lLJ7042		:= .T.									// Retorno do Ponto de Entrada "LJ7042"
Local lContrFol     :=	SF1->(ColumnPos("F1_NUMAUT")) > 0 .And. SF1->(ColumnPos("F1_CODCTR")) > 0 .And.;
						SF2->(ColumnPos("F2_NUMAUT")) > 0 .And. SF2->(ColumnPos("F2_CODCTR")) > 0 .And.;
						SF2->(ColumnPos("F2_LIMEMIS")) > 0 .And. SF3->(ColumnPos("F3_NUMAUT")) > 0 .And.;
						SF3->(ColumnPos("F3_CODCTR")) > 0 .And. GetNewPar("MV_CTRLFOL",.F.)

Local lMotDev		:= SF1->(ColumnPos("F1_MOTIVO")) > 0

//³Release 11.5 - Controle de Formularios ³
//³Pais:Chile   - F1CHI					  ³
Local lCFolLocR5	:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI" .AND. !lFiscal
Local aLstTES		:= {}
Local cRetTesDev    := ""                                    // Retorno do Ponto de Entrada LJ720TES

Default lFormul		:= .T.                 
Default cNumDoc 	:= ""
Default cSerieDoc 	:= ""
Default aDevol		:= {}
Default cMotivo		:= ""
Default nImpostos	:= 0
Default cTpEspecie	:= CriaVar("F1_ESPECIE",.F.)
Default nNFOrig		:= 1 // 1 - Com documento / 2 - Sem documento
Default nFrtSegDes	:= 0	//Frete/Seguro/Outras Despesas
Default nRetIcms	:= 0	//Substituição Tributária 
Default lAutomato := .F.

Private lMsErroAuto	:= .F. 

If lFormul
   cFormul  := "S"
Else
   cFormul  := "N"
Endif   

//se formulario proprio, retornamos a especie baseada na serie padrao para Troca/Devolucao
If lFormul
	cTpEspecie := LjEspecie(cSerie)
EndIf

DbSelectArea("TRB")                                        
TRB->( DbGoTop() )
While TRB->( !Eof() )

	DbSelectArea("SF4")
	SF4->( DbSetOrder(1) )
	If 	SF4->( DbSeek(xFilial("SF4")+TRB->TRB_TES) )

		If !Empty(SF4->F4_TESDV)

			cTesDev := SF4->F4_TESDV

			If !(SF4->(DbSeek(xFilial("SF4")+SF4->F4_TESDV)))
				Help(" ",1,"DSNOTESDEV")
				lDevolucao := .F.
				Exit
			EndIf

		ElseIf !Empty(cTesDev)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona no TES                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSetOrder(1)
			If !DbSeek(xFilial("SF4") + cTesDev)
				lDevolucao := .F.
			Endif	

		Else

			Help(" ",1,"DSNOTESDEV")
			lDevolucao := .F.
			Exit			

		Endif

	ElseIf !Empty(cTesDev)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona no TES                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF4")
		DbSetOrder(1)
		If !DbSeek(xFilial("SF4") + cTesDev)
			lDevolucao := .F.
		Endif

	Else
		Help(" ",1,"DSNOTESDEV")
		lDevolucao := .F.
		Exit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para trocar a TES se necessario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJ720TES")
		cRetTesDev := ExecBlock( "LJ720TES",.F.,.F., {lTroca, nNFOrig} )
        If ValType(cRetTesDev) == "C" .And. !Empty(cRetTesDev)
            cTesDev := cRetTesDev            
		Endif
	Endif
	
	If aScan( aLstTES, { |x| X == AllTrim(cTesDev)}) == 0
		aAdd(aLstTES,AllTrim(cTesDev)) //Captura as TES para validar se pode efetuar devolução sem doc de entrada
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a linha de devolucao que sera gerado o SD1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aLinha := {}				
	AAdd( aLinha, { "D1_COD"    	, TRB->TRB_CODPRO 	, Nil } )
	AAdd( aLinha, { "D1_QUANT"  	, TRB->TRB_QUANT	, Nil } )					
	AAdd( aLinha, { "D1_VUNIT"  	, TRB->TRB_PRCVEN	, Nil } )					
	AAdd( aLinha, { "D1_TOTAL"  	, TRB->TRB_VLRTOT	, Nil } )
	AAdd( aLinha, { "D1_TES" 		, cTesDev 			, Nil } )
	AAdd( aLinha, { "D1_UM"     	, TRB->TRB_UM 		, Nil } )
	If lMv_Rastro
		AAdd( aLinha, { "D1_LOTECTL"  	, TRB->TRB_LOTECT          , ".T." } ) 
		AAdd( aLinha, { "D1_NUMLOTE"  	, TRB->TRB_NUMLOT          , ".T." } )   
		AAdd( aLinha, { "D1_DTVALID"  	, TRB->TRB_DTVALI          , ".T." } )
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao existe nota fiscal de saida (origem) pois a troca eh de outra loja.    ³
	//³Para gerar o documento de entrada eh necessario passar as duas informacoes.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aLinha, { "D1_NFORI"  	, "XXXXXX"          , Nil } )
	AAdd( aLinha, { "D1_SERIORI"	, "XX"         		, Nil } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para incluir campos adicionais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJ720LDV")
		aLinha := ExecBlock("LJ720LDV",.F.,.F.,{aLinha})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o item no array principal que sera levado para o Documento de entrada   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aItens, aLinha)
	DbSelectArea("TRB")
	DbSkip()

End
	
If lDevolucao        
    
    If !Empty(cNumDoc) .AND. !Empty(cSerieDoc)
		cNewDoc	:= cNumDoc
		cSerie	:= cSerieDoc
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
		//³ cMV_TPNRNFS for igual a "3"                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
		If cMV_TPNRNFS == "3"
			
			//se a nota fiscal vai ser transmitida, a nota/troca deverá ser vinculada a uma nota de saída
			If !LjNFeEntOk(cSerie, lFormul, nNfOrig, aLstTES)
				Return .F.
			EndIf

			cNumDoc := MA461NumNf( .T., cSerie )
		Else				
		    If !Lj720Nota(@cSerie, @cNumDoc, lFormul, nNFOrig,aLstTES)
			   Return .F.
		    Endif        
		Endif
        cNewDoc    := cNumDoc
		cSerieDoc  := cSerie
	Endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Controle de Formularios         ³
	//³Verificar se existe formulario do tipo NCC     ³
	//³valido para a serie/nota escolhida.            ³
	//³Paises:Chile	 - F1CHI		 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lCFolLocR5	.AND. lFormul	
		If !ChkFolCHI(	xFilial("SFP"),cSerie, cNewDoc,	"8",;
						NIL,	.F.)
			lRet := .F.
			DisarmTransaction()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cancela a Sequencia de nota utilizada conforme configuracao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Lj720CnSD9(cNewDoc, cSerie, cMV_TPNRNFS)
		EndIf	
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCab, { "F1_DOC"    , cNewDoc						, Nil } )	// Numero da NF : Obrigatorio
	AAdd( aCab, { "F1_SERIE"  , cSerie						, Nil } )	// Serie da NF  : Obrigatorio
	If SF1->(ColumnPos("F1_CHVNFE")) > 0 .And. !Empty(cChvNFE)
		AAdd( aCab, { "F1_CHVNFE" , cChvNFE					, Nil } )	// Chave da NFe
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o cabecalho de acordo com o tipo da devolucao             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aCab, { "F1_TIPO"   , cTipoNF						, Nil } )	// Tipo da NF   		: Obrigatorio
	AAdd( aCab, { "F1_FORNECE", cCliente   					, Nil } )	// Codigo do Fornecedor : Obrigatorio
	AAdd( aCab, { "F1_LOJA"   , cLoja    					, Nil } )	// Loja do Fornecedor   : Obrigatorio
	AAdd( aCab, { "F1_EMISSAO", dDataBase					, Nil } )	// Emissao da NF        : Obrigatorio
	AAdd( aCab, { "F1_FORMUL" , cFormul                    , Nil } )  // Formulario Proprio 
	AAdd( aCab, { "F1_ESPECIE", cTpEspecie               	, Nil } )  	// Especie
	AAdd( aCab, { "F1_COND"   , SuperGetMv("MV_CONDPAD")	, Nil } )					// Condicao do Fornecedor

	If cPaisLoc <> "BRA" 
		AAdd( aCab, { "F1_TIPODOC" 	, "04"   	  			, Nil } )	// Tipo de documento
		AAdd( aCab, { "F1_MOEDA"   	, nMoedaCorT   	  		, Nil } )	// Tipo de documento
		AAdd( aCab, { "F1_TXMOEDA" 	, nTxMoedaTr   	  		, Nil } )	// Tipo de documento
	EndIf
	
	If cPaisLoc=="ARG"
		AAdd( aCab, { "F1_PROVENT" 	, SM0->M0_ESTENT   	  	, Nil } )	// Provincia
		
		// Caso o campo SF1->F1_TPVENT estiver em branco e a localidade for ARGENTINA, esta sendo atribuido "B"
		// Neste caso esta sendo considerado que a Troca/Devolucao sera de um Produto
		// Isto se deve ao fato do SigaLoja nao estar gravando este campo
		If SF1->(ColumnPos('F1_TPVENT'))>0
			AAdd( aCab, { "F1_TPVENT" 	, "B"   	  			, Nil } )	// Tipo de Venda
		EndIf
	Endif		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para controle de Folios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContrFol
		
		aDados := Array(6)                                      
	
		aDados[1] := cSerie
		aDados[2] := cTpEspecie
		aDados[3] := cNewDoc
		If Alltrim(aDados[2]) $ "NDI/NCP"
			aDados[4] := GetAdvFVal("SA2","A2_CGC",xFilial("SA1")+cCliente+cLoja,1,"")
		Else
			aDados[4] := GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+cCliente+cLoja,1,"")
		Endif
		aDados[5] := DtoS(dDataBase)
		aDados[6] := 0//Round(SL1->L1_VALBRUT,0)
		
		aRetCF := RetCF(aDados)
		
		AAdd( aCab, { "F1_NUMAUT"   , aRetCF[1]		, Nil } )
		AAdd( aCab, { "F1_CODCTR"   , aRetCF[2]		, Nil } )
	
	EndIf

	// A variavel cMotivo só é alimentado de duas formas:
	// 01 - Legislacao no AM, onde se for uma devolucao de uma NFC-e, deve-se informar o motivo na tag <infAdFisco>
	// 02 - Países localizados	
	If lMotDev
		AAdd( aCab, { "F1_MOTIVO", cMotivo, Nil } )		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para incluir campos adicionais no cabecalho da NF de devolucao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLj720Cabec
	   aCab := ExecBlock("LJ720CABEC",.F.,.F.,{aCab, aDocDev})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha itens a serem devolvidos                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItens) > 0	
	    
		RetIndex("SD2")

		If cPaisLoc == "BRA"
			Mata103( aCab, aItens , 3)
		Else
			Mata465n( aCab, aItens , 3)		
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	//³Analise de credito integrada com SIGACRD                           ³
    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If CrdxInt() .AND. lUsafd                           
    	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao pontuar quando for cliente padrao.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    		If AllTrim(cCliPad) <> AllTrim(cCliente)	                                 
                                       
				For nX := 1 to Len(aItens)	             
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Localiza a posicao do produto e do total da devolucao no array³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    		    nPosTot		:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_TOTAL"})
					nPosProd	:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_COD"})	
					nPosQtd		:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_QUANT"})	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca o grupo do item no cadastro de produto³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				   	cGrupoProd :=  Posicione("SB1",1,xFilial("SB1")+aItens[nX][nPosProd][2] ,"SB1->B1_GRUPO")
				   	
				   	AADD ( aProdCri, {	aItens[nX][nPosProd][2]	,;			//Produto
				   						cGrupoProd				,;			//Grupo
				   						( aItens[nX][nPosTot][2]) ,;		//Valor da Devolvido	
				   						( aItens[nX][nPosQtd][2]) } ) 	    //Quantidade de Itens
				   	
				   	nTotDev += aItens[nX][nPosTot][2]	// Total da Devolucao			
				   	
				Next nX     
			                        
				If ExistBlock("LJ7042")
					lLJ7042	:=	ExecBlock( "LJ7042", .F., .F., { cCliente, cLoja, "D" } )
					If ValType( lLJ7042 ) <> "L"
						lLJ7042 := .T.
					Endif
				Endif
				If lLJ7042
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Chama a funcao para devolucao dos pontos. somente e utilizada se    ³
					//³o sistema tiver integracao com o CRD.                               ³
					//³OBS: Esta rotina gera um registro no MAX com o campo saldo negativo.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					If Crd240_002(	cTipo			,;	// Tipo da Operacao: 1)Venda 2)Devolucao 3)Exclusao
									cCliente		,;	// Codigo do cliente
									cLoja			,;	// Loja 
									aProdCri		,;	// Array com os produtos para analise dos pontos
									nTotDev			,;	// Total da Venda
									cNewDoc			,;	// Numero do documento 
									cSerie			,; 	// Serie
									Nil				,; 	// Documento da venda original
									Nil				,;	// Serie da venda original          
									Nil				,; 	// Identifica se e do Loja ou do Televendas       
									Nil				,; 	// Indica se grava MAX ou somente calcula pontos
									Nil				,; 	// Total de pontos							   
									Nil				) 	// Pagamento com Vale-Compra calcular sobre a dif.
					Endif
				EndIf
			Endif
		Endif
		
		If  lMsErroAuto
		    If IsBlind()				
				cMensagem := "LOJA720 - Lj720DevTRB : Erro na ExecAuto " + CHR(10) + CHR(13) + MOSTRAERRO()
				Conout( cMensagem )
			Else
				MOSTRAERRO()
			EndIf
			
		    DisarmTransaction()
			lRet:= .F. 
		Else		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os campos do processo do SIGALOJA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj720AtuNFE( cNewDoc   	, cSerie	, cCliente, cLoja , ;
			             nFormaDev	, Nil		, cMotivo	, @nImpostos, xNumCaixa(), .F.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se selecionar as opcoes "Devolucao" e "Dinheiro", exclui a NCC gerada e gera registro de ³
			//³saida de numerario 																	    ³			
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nFormaDev == 1 .AND. nTpProc == 2
			   Lj720DevDinh( cNewDoc   ,cSerie  ,cCliente  ,cLoja  ,;
			                  nVlrTotal	,@lDevMoeda	,@aDevol	,nImpostos,;
		   					xNumCaixa(), 		,		, nFrtSegDes,;
		   					nRetIcms)      //"BAIXA REF. ESTORNO DE VENDA"
			Endif
		    
			aDocDev  := { cSerie  , cNewDoc , cCliente , cLoja , ;
			              nTpProc , Space(TamSX3("D1_DOC")[1]), {} }
			If !lAutomato//Quando a execução for via robô o cupom não é impresso
				LjImpCNfisc( aDocDev, nVlrTotal )
			Endif
			
			cMensagem := STR0053+ cNewDoc + " / " + cSerie //"Foi gerado o documento de entrada "
			If IsBlind()
				Conout(cMensagem)
			Else
			    MsgInfo(cMensagem)//"Foi gerado o documento de entrada "
			EndIf
			LjGrvLog( NIL, cMensagem)
	    Endif		
	Else
		Help(" ",1,"OMS320NFD") //Nota Fiscal de devolucao ja gerada
		lRet:= .F.
	Endif
Endif

RestArea( aArea ) 
RestArea( aAreaSF2 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720BkpAreºAutor  ³ Vendas Cliente    º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recupera os valores do aRotina, aHeader, n e cCadastro apos º±±
±±º			 ³a operacao de troca ou devolucao                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Lj720BkpArea(ExpC1, ExpA2, ExpA3, ExpN4                     º±±
±±º          ³ExpC1 - descricao do cCadastro antes de entrar na rotina    º±±
±±º          ³ExpA2 - aRotina antes de entrar na rotina                   º±±
±±º          ³ExpA3 - aHeader antes de entrar na rotina                   º±±
±±º          ³ExpN4 - n(linha) antes de entrar na rotina                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720BkpArea(cCad, aRots, aSavHead, nBkpLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o aRotina, o cCadastro e o aHeader.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("cCadastro") <> "U" .AND. Type("aRotina") <> "U" 
   cCadastro	:= cCad
   aRotina  	:= AClone(aRots)
Endif
	
If Type("aHeader")  <> "U"
   aHeader   := aClone(aSavHead)
Endif

If Type("n") <> "U"
   n         := nBkpLin
Endif   

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720EstTro³ Autor ³ Vendas Cliente       ³ Data ³ 16/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Estorna a rotina de troca caso o cliente desista da operacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Lj720EstTroc(ExpA1)								          ³±±
±±³			 ³ExpA1 - Array com as informacoes:					          ³±±
±±³			 ³	[1] - Serie da NF de devolucao                            ³±±
±±³			 ³	[2] - Numero da NF de devolucao                           ³±±
±±³			 ³	[3] - codigo do cliente da NF de devolucao                ³±±
±±³			 ³	[4] - loja do cliente da NF de devolucao                  ³±±
±±³			 ³	[5] - tipo de operacao: 1 - troca;2 - devolucao           ³±±
±±³			 ³	[6] - Numero do Documento anterior de venda	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720EstTroc(aDocDev)	      
Local cSerieDev   := aDocDev[1]                        	// Serie do documento de devolucao
Local cNumDev     := aDocDev[2]                        	// Numero do documento de devolucao
Local cClienteDev := aDocDev[3]                        	// Cliente do documento de devolucao
Local cLojaDev    := aDocDev[4]                        	// Loja do cliente do documento de devolucao
Local cTipoNF     := "D"    							// Tipo do documento de entrada
Local aCab        := {}                              	// Dados do cabecalho para a rotina automatica
Local aItens      := {}                              	// Dados dos itens para a rotina automatica
Local aLinha      := {}                              	// Dados dos itens para a rotina automatica
Local lLJ720Estor := ExistBlock("LJ720ESTOR")        	// Verifica se o PE LJ720ESTOR existe
Local lLJ720ANT   := ExistBlock("LJ720ANT")          	// Verifica se o PE LJ720ANT existe
Local xRet                                            	// Retorno do PE LJ720ANT
Local lUsafd      := SuperGetMV("MV_LJUSAFD",,.F.)		// Utiliza Fidelizacao de cliente ??
Local cMV_CLIPAD  := SuperGetMV("MV_CLIPAD")			// Cliente padrao
Local cMV_LOJAPAD := SuperGetMV("MV_LOJAPAD")			// Loja do cliente padrao
Local lLJ7042     := .T.								// Retorno do Ponto de Entrada "LJ7042"
Local cPdv		  := LjGetStation( "PDV" )				// Numero do PDV
Local cNumCup	  := aDocDev[6]							// Numero do cupom 

Private lMsErroAuto := .F.
   
If lLJ720ANT
   xRet  := ExecBlock("LJ720ANT",.F.,.F.,{aDocDev})      
   If ValType(xRet) == "A" .AND. Len(xRet) > 1
      cClienteDev  := xRet[1]      
      cLojaDev     := xRet[2]            
   Endif
Endif

DbSelectArea("SD1")
DbSetOrder(1)
DbSeek(xFilial("SD1") + cNumDev + cSerieDev + cClienteDev + cLojaDev)
While !Eof() .AND.  xFilial("SD1")	== SD1->D1_FILIAL 	.AND.	;
					cNumDev 		== SD1->D1_DOC 		.AND.	;
					cSerieDev 		== SD1->D1_SERIE 	.AND.	;
					cClienteDev 	== SD1->D1_FORNECE	.AND. 	;
					cLojaDev 		== SD1->D1_LOJA

	aLinha := {}				
	AAdd( aLinha, { "D1_DOC"    	, SD1->D1_DOC 	    , Nil } )	
	AAdd( aLinha, { "D1_SERIE"    	, SD1->D1_SERIE	    , Nil } )	
	AAdd( aLinha, { "D1_FORNECE"   	, SD1->D1_FORNECE 	, Nil } )	
	AAdd( aLinha, { "D1_LOJA"    	, SD1->D1_LOJA	    , Nil } )		
	AAdd( aLinha, { "D1_COD"    	, SD1->D1_COD 	    , Nil } )
	AAdd( aLinha, { "D1_ITEM"    	, SD1->D1_ITEM 	    , Nil } )	
    AAdd( aItens, aLinha)
      
    DbSkip()      
End

AAdd( aCab, { "F1_DOC"    , cNumDev						, Nil } )	// Numero da NF : Obrigatorio
AAdd( aCab, { "F1_SERIE"  , cSerieDev					, Nil } )	// Serie da NF  : Obrigatorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho de acordo com o tipo da devolucao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCab, { "F1_FORNECE", cClienteDev					, Nil } )	// Codigo do Fornecedor : Obrigatorio
AAdd( aCab, { "F1_LOJA"   , cLojaDev   					, Nil } )	// Loja do Fornecedor   : Obrigatorio
AAdd( aCab, { "F1_TIPO"   , cTipoNF						, Nil } )	// Tipo da NF   		: Obrigatorio

If cPaisLoc <> "BRA" 
	If aDocDev[5] == 1
		AAdd( aCab, { "F1_TIPODOC" 	, "04"   	  				, Nil } )	// Tipo de documento
		AAdd( aCab, { "F1_MOEDA"   	, 1   	  					, Nil } )	// Tipo de documento
		AAdd( aCab, { "F1_TXMOEDA" 	, 1   	  					, Nil } )	// Tipo de documento	
	Else
		AAdd( aCab, { "F1_TIPODOC" 	, "04"   	  				, Nil } )	// Tipo de documento
		AAdd( aCab, { "F1_MOEDA"   	, SF2->F2_MOEDA   	  		, Nil } )	// Tipo de documento
		AAdd( aCab, { "F1_TXMOEDA" 	, SF2->F2_TXMOEDA   	  	, Nil } )	// Tipo de documento
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa filtro ativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SD2")
RetIndex("SD2")
DbClearFilter()
  
If cPaisLoc == "BRA"
	//"Aguarde...Cancelando a Nota Fiscal de Devolução."
	MsgRun(STR0061,,{||MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCab, aItens, 5)})
Else
	MsgRun(STR0061,,{||MSExecAuto({|x,y,z| MATA465N(x,y,z)}, aCab, aItens, 5)})
EndIf

If lMsErroAuto
	DisarmTransaction()
	MostraErro()
Else
	If CrdxInt() .AND. lUsaFd .AND. (cClienteDev + cLojaDev <> cMV_CLIPAD + cMV_LOJAPAD )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para validar o cliente, se deve ou nao pontuar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("LJ7042")
			lLJ7042	:=	ExecBlock( "LJ7042", .F., .F., { cClienteDev, cLojaDev, "E" } )
			If ValType( lLJ7042 ) <> "L"
				lLJ7042 := .T.
			Endif
		Endif
		If lLJ7042
	    	Crd240_002(	"3",;			//Exclusao
	    				cClienteDev,;	//Cliente
	    				cLojaDev,;		//Loja
	    				NIL,;			//Array com os Produtos
						NIL,;			//Total da Venda
						cNumDev,;		//Numero da Nota de Entrada
						cSerieDev,;		//Serie da Nota de Entrada
						NIL,;			//Numero do Cupom Original
						NIL,;			//Serie do Cupom Original
						NIL,;			//Origem
						NIL,;			//Exclui Pontos
						NIL,;			//Total de Pontos
						NIL,;			//Pagamento Vale Compras
						.T.)			//Exclui os Pontos gerados pela devolucao
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclusao do registro da tabela SLX³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AliasIndic("SLX")
		cPdv := Padr(cPdv,TamSx3("LX_PDV")[1])
		
		DbSelectArea("SLX")
		SLX->(DbSetOrder(1))
		If SLX->(DbSeek(xFilial("SLX")+cPdv+cNumCup))
			While SLX->(!EOF()) .AND. SLX->LX_FILIAL+SLX->LX_PDV+SLX->LX_CUPOM ==;
									   xFilial("SLX")+cPdv+cNumCup
	        	RecLock("SLX",.F.)   
				SLX->(DbDelete())
	        	SLX->(MsUnlock())
	        	
	        	SLX->(DbSkip())									   
			End
		Endif	
	Endif	
	
	lConfirma := .F.
	
    MsgInfo(STR0062)  //"Nota Fiscal de Devolução estornada com sucesso!"
Endif   

If lLJ720Estor
   ExecBlock("LJ720ESTOR",.F.,.F.,{aDocDev})      
Endif
		   
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720VldPro³ Autor ³ Vendas Cliente       ³ Data ³ 16/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescri‡„o ³Validacao do produto quando nao tem NF de origem   		  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj720VldProd(ExpC1, ExpN2)                                 ³±±
±±³			 ³ ExpC1 - Codigo do produto 							      ³±±
±±³			 ³ ExpN2 - Quantidade devolvida							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720VldProd(  cCodProd  ,nQuant   )
Local lRet := .T.   						//Variavel de retorno, controla se o produto foi validado

nQuant  := Max(nQuant,1)
If lRet  := LJSB1SLK(  @cCodProd  ,@nQuant   ,.F.     ) 
   lRet  := Lj720Trigger(  'TRB_CODPRO'  ,  cCodProd   ,nQuant   )  
   M->TRB_CODPRO := cCodProd
Endif   

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³lj720Nota ³ Autor ³ Vendas Cliente        ³ Data ³22/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de numeracao do documento de entrada, permitindo o ³±±
±±³			 ³controle tanto pelo SXE/SXF quanto pelo SX5				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Lj720Nota(ExpC1, ExpC2)       							  ³±±
±±³			 ³ExpC1 - Serie padrao de devolucao							  ³±±
±±³			 ³ExpC2 - Numero do documento de devolucao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Automacao Comercial										  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj720Nota(cMVSerie, cNumDoc, lFormul, nNFOrig,aLstTES)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpcA 	 := 0									// Opcao da tela de selecao da serie
Local nSaveSx8 	 := GetSx8Len()							// Controle do SXE/SXF
Local nCntErro   := 0									// Contador de tentativas de lock do registro do SX5
Local nTamNota   := TamSx3("F1_DOC")[1]					// Tamanho do campo F1_DOC
Local aSerNf     := {}									// Series e numeros respectivos cadastrados na tabela 01 do SX5
Local cCadastro  := STR0063								// Titulo da janela: "Notas"
Local cVarQ      := "  "								// Variavel da serie escolhida
Local cMV_LJNRNFS:= SuperGetMv("MV_LJNRNFS",.F.,"2")	// Parametro que controla o tipo de numeracao
														// 1 - Numeracao controla pelo SX5
														// 2 - Numeracao controla pelo SXE/SXF
														// 3 - Numeracao controla pelo SD9
Local lDone      := .F.									// Controle da tela de selecao da serie/numero
Local lAbandona  := .F.									// Controle da tela de selecao da serie/numero
Local lInterno   := .T.									// Controle da tela de selecao da serie/numero
Local lAvanca    := SuperGetMV("MV_LJAVANC")			// Controla se permite alterar o numero da NF sugerida
Local cMV_TPNRNFS:= LJTpNrNFS()							// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local aLockSX5[0]										// Matriz com os recnos dos registros travados no SX5.
Local lReturn    := .T.									// Valor que sera retornado pela funcao.
Local oQual												// Objeto do list box das series cadastradas
Local oDlg												// Objeto do dialog
Local lLj720PrxNum := ExistFunc("U_LJ720PRXNUM")    // Verifica se tem o PE LJ720PRXNUM 
Local cFilSx5		:= If(ExistFunc("LjFilSX5"),LjFilSX5(),xFilial("SX5")) // Retorna Filial SX5	

Default lFormul		:= .T.								//
Default nNFOrig		:= 1								// 1- com documento / 2 - sem documento
Default aLstTES		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz um tratamento diferenciado para o controle de NF pelo SD9 quando ³
//³ o parametro MV_TPNRNFS for igual a "3"                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMV_TPNRNFS == "3"
	If Empty( cMvSerie )
		If !Sx5NumNota( Nil, cMV_TPNRNFS )
			Return .F.
		Else
			Return .T.
		Endif
	Else
		Return .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o Parƒmetro MV_LJNFTRO estiver vazio, Desenha  ³
//³ a tela para escolha do Nota/Serie			        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJNFSXE")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o tratamento de pegar o numero da nota via semaforo ou via           ³
	//³ SX5 (tabela 01)                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a serie estiver em branco abre a tela para a escolha do usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cMvSerie)
		If !Sx5NumNota(@cMvSerie, cMV_LJNRNFS)
			Return .F.
		Endif
	Endif
	
	//se a nota fiscal vai ser transmitida, a nota/troca deverá ser vinculada a uma nota de saída
	If !LjNFeEntOk(cMvSerie, lFormul, nNFOrig,aLstTES)
		Return .F.
	EndIf
	
	cNumDoc := NxtSX5Nota( cMVSerie,,cMV_LJNRNFS,lAvanca )
	cNumDoc := PadR( cNumDoc , TamSx3("F2_DOC")[1] )	
	
	If !LjValNota(cMVSerie,cNumDoc) // Varifica se jah existe a nota
		Return .F.	
	Endif

	While (GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	End

ElseIf Empty(cMvSerie)
	DbSelectArea("SX5")
	While !lAbandona .AND. DbSeek( cFilSx5+"01",.F. ) .AND. !lDone
		lInterno := .T.
		While cFilial+"01" == X5_FILIAL+X5_TABELA .AND. !lAbandona
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se a S‚rie for CPF, n„o mostra no aChoice, pois ‚ utilizada ³
			//³ internamente para emissao de Cupom Fiscal.	   			     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (AllTrim(SX5->X5_CHAVE) == "CPF") .OR. ;
				(AllTrim(SX5->X5_CHAVE) == "CP")
			Else
				If !MsRLock()
					lInterno := .F.
					lDone    := .F.
					aSerNF   := {}
					If (++nCntErro > 10)
						lAbandona := .T.
					Endif
					Loop
				Else
					aAdd(aLockSX5, RecNo())
					
					If !lAbandona
						If !(ValType(aSerNF) == "A")
							aSerNF := {}
						Endif
						lDone := .T.
						
						If cPaisloc == "BRA" .And. Len(AllTrim(SX5->X5_DESCRI)) < Len(SF1->F1_DOC)
							nTamNota := 6
						Else
							nTamNota := Len(SF1->F1_DOC)
						EndIf
						
						AADD( aSerNF,{ Padr( X5_CHAVE, 3 ), StrZero( Val( X5Descri() ), nTamNota ) } )
					Endif
				Endif
			Endif
			DbSkip()
		End
	End
	
	If (Len(aSerNF) == 0) .OR. lAbandona
		MsUnlock()
		Help(" ",1,"A460FLOCK")
		lReturn := .F.
	Endif
	
	If lReturn
		nOpcA := 0
		While nOpcA <> 1
			DEFINE MSDIALOG oDlg TITLE cCadastro From 10,30 To 19,68 OF oMainWnd
			//"Serie"
			@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER STR0064,cCadastro SIZE 130,42 ON DBLCLICK (aSerNF:=LjxDX5Troca(oQual:nAt,aSerNF),oQual:Refresh()) NOSCROLL
			oQual:SetArray(aSerNF)
			oQual:bLine := { || {aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2]}}
			
			DEFINE SBUTTON FROM 51,109	TYPE 1 ACTION ;
			(If(LjxDANf(oQual,aSerNF,@cMVSerie,@cNumDoc),( nOpcA := 1, oDlg:End()),)) ENABLE OF oDlg
			
			ACTIVATE MSDIALOG oDlg
		End
		
		//se a nota fiscal vai ser transmitida, a nota/troca deverá ser vinculada a uma nota de saída
		If !LjNFeEntOk(cMvSerie, lFormul, nNfOrig,aLstTES)
			Return .F.
		EndIf

		DbSelectArea("SX5")
		If SX5->( DbSeek( cFilSx5 + "01" + cMVSerie,.F.) )
			MsRLock()
		    REPLACE X5_DESCRI  WITH PadR( StrZero(Val(cNumDoc)+1,Len(AllTrim(cNumDoc))) , nTamNota)
		    REPLACE X5_DESCSPA WITH PadR( StrZero(Val(cNumDoc)+1,Len(AllTrim(cNumDoc))) , nTamNota)
		    REPLACE X5_DESCENG WITH PadR( StrZero(Val(cNumDoc)+1,Len(AllTrim(cNumDoc))) , nTamNota)
			MsUnlock()
		Else
			MsUnlock()
			Return(.F.)
		Endif
	Endif
	aEval( aLockSX5, {|x| dbGoTo(x), MsUnlock() })

Else
	
	//se a nota fiscal vai ser transmitida, a nota/troca deverá ser vinculada a uma nota de saída
	If LjNFeEntOk(cMvSerie, lFormul, nNfOrig,aLstTES)
		DbSelectArea("SX5")

		If SX5->( DbSeek(cFilSx5 + "01" + cMvSerie) )			   
			cNumDoc := NxtSX5Nota( cMVSerie )

			// Quando a quantidade de digitos da NF for 6 (menor que o campo F1_DOC - 09),
	    	// preencher com espacos a direita do conteudo para efeito de pesquisa.
			cNumDoc := PadR( cNumDoc, TamSX3("F1_DOC")[1] )
		Else
			HELP(" ",1,"ERROSERIE")
			lReturn := .F.
		EndIf	
	Else
		Return .F.
	EndIf

Endif

If lLj720PrxNum 
   U_LJ720PRXNUM(@cMVSerie, @cNumDoc)
EndIf

Return lReturn

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj720DevDi³ Autor ³ Vendas Cliente        ³ Data ³27/12/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exclui a NCC gerada e gera registro de devolucao em Dinheiro³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Lj720DevDinh(ExpC1, ExpC2, ExpC3, ExpC4, ExpN5)             ³±±
±±³			 ³ExpC1 - numero do documento de entrada gerado               ³±±
±±³			 ³ExpC2 - serie do documento de entrada gerado(prefixo titulo)³±±
±±³			 ³ExpC3 - codigo do cliente								      ³±±
±±³			 ³ExpC4 - loja do cliente								      ³±±
±±³			 ³ExpN5 - valor devolvido								      ³±±
±±³			 ³ExpL6 - Devolucao em varias moedas				          ³±±
±±³			 ³ExpA7 - Dados da devolucao						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA720               									  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj720DevDinh( cNewDoc   	,cSerie  	,cCliente  	,cLoja  ,;
                       nVlrTotal	, lDevMoeda	, aDevol	, nImpostos,;
                       cCaixa		, cTipoDoc	, cHistorico, nFrtSegDes,;
                       nIcmsRet		)

Local aArea     	:= GetArea()                          	// Area inicial
Local cParcela  	:= AllTrim(SuperGetMV("MV_1DUP"))     	// Inicializacao da primeira parcela
Local cSimb1    	:= AllTrim(SuperGetMV("MV_SIMB1"))    	// Simbolo da moeda principal
Local cNatDevol 	:= AllTrim(SuperGetMV("MV_NATDEV"))   	// Natureza da devolucao
Local cPrefixoEnt	:= ""									//Prefixo da nota de entrada
Local nDecs  		:= 0									// Decimais	
Local nX 			:= 1									// Contador
Local aDadosBanc	:= {}                                   //array com dados de ag e conta CADASTRADOS NA SA6
Local cNumMov		:= LjNumMov()							// Numero do movimento

Default lDevMoeda 	:= .F.
Default aDevol 		:= {}
Default nImpostos 	:= 0
Default cCaixa 		:= xNumCaixa() 
Default cTipoDoc 	:= "DH" //DH=Dinheiro
Default cHistorico 	:= STR0065									//"BAIXA REF. DEVOL. EM DINHEIRO"
Default nFrtSegDes  := 0 	//Frete Seguro e Despesa
Default nIcmsRet	:= 0	//Retorno de ICMS - Substituição Tributária    
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o prefixo da nota de entrada para fazer a baixa da NCC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF1")
DbSetOrder(1)
If DbSeek(xFilial("SF1")+cNewDoc+cSerie+cCliente+cLoja ) 
	cPrefixoEnt := SF1->F1_PREFIXO
Else
	cPrefixoEnt := cSerie
Endif 
 
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui a Nota de Credito porque foi devolvido em dinheiro ao cliente  ³
//³ A Nota de Credito foi gerada pela rotina automatica do MATA103		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE1")
DbSetOrder( 2 )
If DbSeek( xFilial("SE1") + cCliente + cLoja + cPrefixoEnt + cNewDoc  )
	
	While !Eof() .AND. SE1->E1_FILIAL 	    == xFilial("SE1") .AND.;
	                    SE1->E1_CLIENTE		== cCliente       .AND.;
						SE1->E1_LOJA		== cLoja          .AND.;
						SE1->E1_PREFIXO		== cPrefixoEnt    .AND.;
						SE1->E1_NUM			== cNewDoc
										
       If (SE1->E1_TIPO $ MV_CRNEG) .AND. SE1->E1_VALOR == SE1->E1_SALDO
          RecLock("SE1",.F.)   
          DbDelete()
          MsUnlock()
	   Endif
	    
	   DbSkip()
	End
Endif	

aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cCaixa, 1, { ".", "."} )//³ Busca AG e conta cadastrados na SA6     ³
If !lDevMoeda
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera o registro correspondente a devolucao em dinheiro ao cliente     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SE5",.T.)
	REPLACE	SE5->E5_FILIAL	WITH xFilial("SE5")
	REPLACE	SE5->E5_PREFIXO	WITH cPrefixoEnt
	REPLACE	SE5->E5_NUMERO	WITH cNewDoc
	REPLACE	SE5->E5_PARCELA	WITH cParcela
	REPLACE	SE5->E5_CLIFOR	WITH cCliente
	REPLACE	SE5->E5_LOJA	WITH cLoja
	REPLACE	SE5->E5_DOCUMEN	WITH cSerie+cNewDoc+cParcela+cSimb1+cLoja
	REPLACE	SE5->E5_DATA	WITH dDataBase
	REPLACE	SE5->E5_AGENCIA	WITH aDadosBanc[1]
	REPLACE	SE5->E5_TIPODOC	WITH cTipoDoc
	REPLACE	SE5->E5_TIPO	WITH cSimb1
	REPLACE	SE5->E5_HISTOR	WITH cHistorico                 //"BAIXA REF. DEVOLUCAO"
	REPLACE	SE5->E5_VALOR	WITH nVlrTotal + nImpostos+nFrtSegDes+nIcmsRet
	REPLACE	SE5->E5_DTDIGIT	WITH dDataBase
	REPLACE	SE5->E5_NATUREZ	WITH &(cNatDevol)	
	REPLACE	SE5->E5_DTDISPO	WITH SE5->E5_DATA
	REPLACE	SE5->E5_BANCO	WITH cCaixa
	REPLACE	SE5->E5_CONTA	WITH aDadosBanc[2]
	REPLACE	SE5->E5_VENCTO	WITH dDataBase
	REPLACE	SE5->E5_RECPAG	WITH "P"
	REPLACE	SE5->E5_MOTBX	WITH "NOR"
	REPLACE	SE5->E5_BENEF	WITH cUserName
	REPLACE	SE5->E5_FILORIG	WITH cFilAnt
	REPLACE	SE5->E5_NUMMOV	WITH cNumMov
	REPLACE	SE5->E5_KEY	WITH SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA
	MsUnLock()
	
	/* Chamada da rotina que gera Fks do financeiro */
	
	FINXSE5(SE5->(Recno()), MOVIMENTO_BCO)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza saldo do BANCO Caixa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AtuSalBco(	SE5->E5_BANCO	, SE5->E5_AGENCIA , SE5->E5_CONTA , SE5->E5_DTDISPO ,;
			  	SE5->E5_VALOR	,	"-"	) 
Else
	If Len(aDevol) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criando registro de movimenta‡ao no SE5 para acerto do     ³
		//³ numer rio devolvido pelo Caixa, desde que nao gerou NCC    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aDevol)
			If aDevol[nX][3] > 0
			
				nDecs := MsDecimais(nX,aDevol)
			
				RecLock("SE5",.T.)
				REPLACE E5_FILIAL  	WITH xFilial("SE5")
				REPLACE E5_DATA	 	WITH dDataBase
				REPLACE E5_CLIFOR  	WITH cCliente
				REPLACE E5_LOJA	 	WITH cLoja
				REPLACE E5_AGENCIA 	WITH If (nX==1,aDadosBanc[1],SuperGetMv("MV_SIMB"+Str(nX,1)))
				REPLACE E5_TIPODOC 	WITH cTipoDoc
				REPLACE E5_TIPO	 	WITH SuperGetMv("MV_SIMB"+Str(nX,1))
				REPLACE E5_VALOR	WITH aDevol[nX][3]
				REPLACE E5_DTDIGIT 	WITH dDataBase
				REPLACE E5_DTDISPO 	WITH SE5->E5_DATA
				REPLACE E5_BANCO	WITH cCaixa
				REPLACE E5_CONTA	WITH aDadosBanc[2]
				REPLACE E5_VENCTO  	WITH dDataBase
				REPLACE E5_RECPAG  	WITH "P"
				REPLACE E5_MOTBX	WITH "NOR"
				REPLACE E5_BENEF	WITH Substr(cUsuario,7,15)
				REPLACE E5_VLMOED2 	WITH Round(xMoeda(aDevol[nX][3],nX,1,SE5->E5_DATA,nDecs+1),nDecs)
				REPLACE E5_HISTOR  	WITH cHistorico //"BAIXA REF. DEVOL. EM DINHEIRO"
				REPLACE	SE5->E5_NATUREZ	WITH &(cNatDevol)
				REPLACE	SE5->E5_NUMMOV	WITH cNumMov
			    REPLACE	SE5->E5_KEY	WITH SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA
				MsUnLock()
				
					
				/* Chamada da rotina que gera Fks do financeiro */
				
				FINXSE5(SE5->(Recno()), MOVIMENTO_BCO)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza saldo do BANCO Caixa ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AtuSalBco(	SE5->E5_BANCO	, SE5->E5_AGENCIA , SE5->E5_CONTA , SE5->E5_DTDISPO ,;
						  	SE5->E5_VALOR	,	"-"	)
			EndIf
		Next nX
	EndIf
EndIf


RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720ValDe³ Autor ³ Vendas Cliente        ³ Data ³10/01/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se as opcoes "Compensa NCC" e "Forma de devolucao"   ³±±
±±³          ³estao consistentes										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 := Lj720ValDev(ExpL2, ExpN3, ExpN4, ExpN5, ExpN6)     ³±±
±±³			 ³ExpL1 - retorna se as opcoes selecionadas sao validas       ³±±
±±³			 ³ExpL2 - indica se selecionou compensacao da NCC             ³±±
±±³			 ³ExpN3 - forma de devolucao(1-dinheiro;2-NCC)				  ³±±
±±³			 ³ExpN4 - tipo de operacao(1-troca;2-devolucao)	              ³±±
±±³			 ³ExpN5 - 1-Com NF de origem ou 2-Sem NF de origem            ³±±  
±±³			 ³ExpN6 - array que traz a posicao do registro selecionado,   ³±±
±±³			 ³		  a partir dele é possível pegar o cNumDoc e cSerieDoc³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA720               									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720ValDev( lCompCR  ,nFormaDev  ,nTpProc  ,nNfOrig ,;
							 lFormul  , aRecSD2	)

Local lRet          := .T.														// Variavel de retorno.
Local cMV_LJCHGDV   := AllTrim(SuperGetMV("MV_LJCHGDV",,"1"))                  // Define se permite ou nao modificar a forma de devolucao ao cliente("0"-nao permite;"1"-permite)
Local cMV_LJCMPNC   := AllTrim(SuperGetMV("MV_LJCMPNC",,"1"))                  // Define se permite ou nao modificar a opcao para compensar a NCC com o titulo da NF original("0"-nao permite;"1"-permite)
Local lLj720VlFin   := ExistBlock("LJ720VLFIN")                                // Verifica se existe o ponto de entrada LJ720VLFIN
Local xRet          := Nil                                                     // Retorno do ponto de entrada LJ720VLFIN

Default lFormul     	:= .F. 
Default aRecSD2		:= {}

// Ponto de entrada que valida a finalizacao do processo de troca\devolucao. 
If lLj720VlFin
	LjGrvLog(Nil,"Antes da Chamada do Ponto de Entrada:LJ720VLFIN",{ lCompCR, nFormaDev, nTpProc, nNfOrig, lFormul, aRecSD2 })
	xRet := ExecBlock("LJ720VLFIN",.F.,.F.,{ lCompCR, nFormaDev, nTpProc, nNfOrig, lFormul, aRecSD2 })
	LjGrvLog(Nil,"Apos a Chamada do Ponto de Entrada:LJ720VLFIN - xRet", xRet)
	If ValType(xRet) == "L" 
		lRet := xRet
	EndIf
EndIf	
	
If lRet .AND. nTpProc == 2   
   If lCompCR .AND. nFormaDev == 1 .AND. cMV_LJCMPNC == "1" .AND. cMV_LJCHGDV == "1" .AND. nNfOrig == 1
      //"Há uma incompatibilidade na seleção das opções. Para compensar a NCC deve ser selecionada a forma de devolução Nota de Crédito."		
      MsgStop(STR0070)   
      lRet   := .F.
   Endif
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj720GetTr³ Autor ³ Vendas Cliente        ³ Data ³31/01/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recupera o valor da variavel lTroca, que pode ser chamado de³±±
±±³          ³qualquer programa											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 := .T. = troca;.F. = devolucao		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA720               									  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj720GetTroca()
Return lTroca

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj720SetTr³ Autor ³ Vendas Cliente        ³ Data ³31/01/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o valor da variavel lTroca, que pode ser chamado de³±±
±±³          ³qualquer programa											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1-Variavel estatica lTroca(.T. = troca;.F. = devolucao) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA720               									  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj720SetTroca(lConteudo)
lTroca  := lConteudo
Return NIL

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720AtuTr³ Autor ³ Vendas Cliente        ³ Data ³08/02/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o valor da variavel lTroca quando fecha o Dialog   ³±±
±±³			 ³Se nao confirmou a operacao, deve setar para .F. uma vez que³±±
±±³			 ³foi inicializada com .T.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA720               									  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj720AtuTrc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a operacao nao foi confirmada, atualiza a variavel de Troca pois ja foi inicializada.³
//³Caso contrario,mantem o valor da variavel dependendo se foi troca(.T.) ou devolucao(.F.)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lConfirma .AND. lTroca
   lTroca  := .F.
End      

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ720RecCoºAutor  ³ Vendas Cliente     º Data ³ 26/04/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recalculo das comissoes no SE3.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Posicao no SD2     					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ720RecComis( aPosSd2, nFormaDev, cCodFil, aDocOri )
Local aArea   		:= GetArea()								//GetArea
Local aAreaL1 		:= SL1->(GetArea())							//GetArea do SL1
Local aAreaL2 		:= SL2->(GetArea())							//GetArea do SL2
Local aAreaD2		:= SD2->(GetArea())							//GetArea do SD2
Local nDecs  		:= MsDecimais( 1 )							//Decimais
Local nBaseComis    := 0										//Base da comissao
Local nBaseParCom 	:= 0										//Base da comissao para a parcela
Local cPrefixo		:= ""										//Prefixo
Local nValDevD2		:= 0										//Valor de devolucao no SD2
Local nValTotD2		:= 0										//Valor de venda no SD2
Local cNumNota		:= ""										//Armazena o numero da Nota
Local cSerie		:= ""										//Serie da nota
Local cCodCli		:= ""										//Codigo do Cliente
Local cLojCli		:= ""										//Loja do Cliente
Local cTpComiss		:= SuperGetMv("MV_LJTPCOM",,"1")			//Tipo de calculo de comissao utilizado (1-Para toda a venda (padrao),2-Por item)
Local aComissoes 	:= {} 										//Comissao de vendedores
Local cVendedor 	:= ""
Local nQtdParc 		:= 0
Local nX 			:= 0
Local nY 			:= 0
Local nVlrComis 	:= 0
Local aNotas		:= {}
Local nC			:= 0
Local cMV_LJDVACR	:= AllTrim(SuperGetMV("MV_LJDVACR",,""))  	//Define se considera acrescimo financeiro na devolucao
Local lContinua		:= .F.										//Pesquisa dupla de DbSeek em SL1
Local cOrcNum		:= ""										//L1_NUM
Local cL1Doc 		:= ""										//L1_DOC ou L1_DOCPED, para DBSeek em SE3
Local cL1Vend		:= ""										//L1_vEND
Local cL1Vend2		:= ""										//L1_VEND2 - SUPERVISOR
Local cL1Vend3		:= ""										//L1_VEND3 - GERENTE
Local cL1ConfVen	:= ""										//L1_CONFVEN
Local cFilOrig      := ""										//Filial do Orçamento de Reserva ou de Origem
Local cOrcRes		:= ""										//Orçamento de Reserva
Local nValItPed		:= 0										//Soma dos valores dos itens do pedido se cTpComiss = 2
Local nValTotPed	:= 0										//Soma dos valores dos do pedido
Local nValItDev		:= 0										//Soma da devolução dos valores dos itens do pedido se cTpComiss = 2
Local cNumPed		:= ""
Local lCheckSL1		:= .F.										//Verificação DbSeek Prévio SL1
Local aAreaL1A 		:= {}										//GetArea do SL1
Local aAreaD2A 		:= {}										//GetArea do SD2
Local aDocsPed		:= {}										//Caso não encontrar DbSeek de SL1, verifico qual L1_DOC/L1_SERIE a outra ligada ao D2_PEDIDO
Local aL1Filhos		:= {}										//Filhos ligados ao registro pai - SL1
Local nL1Filhos		:= 0										//Contador de orc. filhos
Local aRetSC6		:= {}										//Retorno da função Lj720SC6()
Local cQuerySL1		:= ""
Local cAlSL1		:= GetNextAlias() 
Local cEol			:= CHR(13) + CHR(10)

Default nFormaDev	:= 1										//Define a forma de devolucao ao cliente: 1-Dinheiro; 2-NCC
Default cCodFil 	:= cFilAnt									//Filial de origem da venda
Default aDocOri		:= {}


If  Len(aDocOri)  = 0
	aAdd(aNotas, { aPosSd2[1][1], aPosSd2[1][2], aPosSd2[1][3], aPosSd2[1][4]})
Else
	aNotas  := aClone(aDocOri) 
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena nas variaveis a primeira posicao do aNotas  ,³
//³pois somente esta posicao sera utiliza para o Seek   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nC :=  1 to Len(aNotas)


	cNumNota	:= aNotas[nC, 01]
	cSerie		:= aNotas[nC, 02]
	cCodCli		:= aNotas[nC, 03]
	cLojCli		:= aNotas[nC, 04]
	cNumNota    := PadR( cNumNota , TamSx3("D2_DOC")[1] )
	
	aDocsPed	:= {}
	cL1Doc 		:= ""
	cL1Vend		:= ""
	cL1Vend2	:= ""
	cL1Vend3	:= ""		
	cL1ConfVen	:= ""
	cOrcNum		:= ""
	cFilOrig 	:= ""
	cOrcRes  	:= ""
	cPrefixo 	:= ""
	lContinua	:= .F.
	lCheckSL1	:= .F.
	aComissoes  := {}
	aL1Filhos	:= {} 
	nL1Filhos	:= 0

	DbSelectArea("SL1")
	SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
	
	DbSelectArea("SL2")
	SL2->(DbSetOrder(3)) //L2_FILIAL+L2_SERIE+L2_DOC+L2_PRODUTO
	
	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	//cSerie e cNumNota, caso tiver mais de um faturamento parcial, é gravado sempre o último em L1_SERIE e L1_DOC.
	//Mas e se eu quiser escolher o penúltimo, ou o primeiro faturamento parcial nessa devolução parcial?
	If !(SL1->(DbSeek(FWxFilial("SL1",cCodFil)+cSerie+cNumNota)))
		cNumPed := SD2->D2_PEDIDO

		If !Empty(cNumPed)		//Para Venda Assistida com tipo 3=Entrega, gera pedido de venda
								//cNumNota/cSerie consultando D2_PEDIDO
								//Não há índice para campo L1_PEDRES, por isso, dbseek na sd2 abaixo.
			aAreaD2A := SD2->(GetArea())
			SD2->(DbSetOrder(8))	//D2_FILIAL+D2_PEDIDO+D2_ITEMPV

			//Aqui eu leio todos os itens de documento relacionado a um pedido, inclusive multiplos faturamentos parciais
			If SD2->(DbSeek(FWxFilial("SD2",cCodFil)+cNumPed))
				//Procedimento para Soma de devolução de todos os itens vinculados a aquele pedido de venda
				While SD2->(!Eof()) .AND. ;
					SD2->D2_FILIAL == FWxFilial("SD2",cCodFil) .AND.;
					SD2->D2_PEDIDO == cNumPed

					If Ascan(aDocsPed, { |x| x[1] == SD2->D2_DOC .AND. x[2] == SD2->D2_SERIE } ) = 0					
						aAdd( aDocsPed, {SD2->D2_DOC, SD2->D2_SERIE})
					EndIf

					SD2->(DbSkip())
				EndDo

				For nX := 1 to Len(aDocsPed)
					If !lCheckSL1 .AND. SL1->(DbSeek(FWxFilial("SL1",cCodFil)+aDocsPed[nX,2]+aDocsPed[nX,1]))
						lCheckSL1 := .T.
					EndIf
				Next

			EndIf

			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			RestArea(aAreaD2A)
		EndIf

	Else
		lCheckSL1 := .T.
	EndIf

	//Pesquisa Prévia, consultando o L1_TIPO
	If lCheckSL1

		If !Empty(SL1->L1_ORCRES)		//Engloba Pedidos com Entrega e Pedido de Venda Mista (Item de Retira vinculado ao Orçamento Reserva)
			cFilOrig := SL1->L1_FILRES
			cOrcRes  := SL1->L1_ORCRES
			cOrcNum	 := SL1->L1_NUM
			
			aAreaL1A := SL1->(GetArea())
			SL1->(DbSetOrder(1)) 	//L1_FILIAL+L1_NUM
			If SL1->(DbSeek(FWxFilial("SL1",cFilOrig)+cOrcRes)) .AND. SL1->L1_TIPO = "P" .AND.;
						!Empty(SL1->L1_SERPED) .AND. !Empty(SL1->L1_DOCPED)		//Efetuando consulta com Orçamento Pai utilizando filial+orçamento
				cPrefixo 	:= SL1->L1_SERPED
				cL1Doc	 	:= SL1->L1_DOCPED
				cL1Vend	 	:= SL1->L1_VEND
				cL1Vend2 	:= SL1->L1_VEND2			
				cL1Vend3	:= SL1->L1_VEND3
				cL1ConfVen 	:= SL1->L1_CONFVEN
				lContinua := .T.

				//Criando agrupamento a partir dos filhos do SL1
				//se L1_TIPO = "V", ler o total da SL2
				//se L1_TIPO = "P", ler o total da SC6 pelo L1_FILRES/L1_PEDRES (contempla eliminação de resíduo) via Lj720SC6()
				//Mudará o cCodFil, cNumNota, cSerie
				//L1_TIPO, L1_FILDOC, L1_NOTA, L1_SERIE
				//O SL1->(DbSetOrder(14)) é falho, pois L1_FILIAL+L1_ORCRES não contempla L1_FILRES+L1_ORCRES, o que deveria ser o correto.

				cQuerySL1 := ""		
				cQuerySL1 += "SELECT SL1.L1_TIPO, L1_FILIAL, L1_DOC, L1_SERIE, L1_PEDRES, L1_NUM " + cEol
				cQuerySL1 += "FROM " + RetSQLName("SL1") + " SL1 " + cEol
				cQuerySL1 += "WHERE SL1.D_E_L_E_T_ = '' " + cEol
				cQuerySL1 += "AND SL1.L1_FILRES = '" + cFilOrig + "' " + cEol
				cQuerySL1 += "AND SL1.L1_ORCRES = '" + cOrcRes  + "' " + cEol

				DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuerySL1)),cAlSL1,.T.,.T.)

				While (cAlSL1)->(!EoF())
					aAdd(aL1Filhos, { (cAlSL1)->L1_TIPO, (cAlSL1)->L1_FILIAL, (cAlSL1)->L1_DOC, (cAlSL1)->L1_SERIE,;
								 (cAlSL1)->L1_PEDRES, (cAlSL1)->L1_NUM })
					(cAlSL1)->( DbSkip() )
				End

				(cAlSL1)->(DbCloseArea())

			EndIf
			SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
			RestArea(aAreaL1A)

		Else
			cPrefixo 	:= LJPREFIXO()
			cL1Doc 		:= SL1->L1_DOC
			cL1Vend	 	:= SL1->L1_VEND
			cL1Vend2 	:= SL1->L1_VEND2
			cL1Vend3 	:= SL1->L1_VEND3						
			cL1ConfVen 	:= SL1->L1_CONFVEN
			lContinua 	:= .T.
			cFilOrig	:= SL1->L1_FILIAL
			aAdd(aL1Filhos, { SL1->L1_TIPO, SL1->L1_FILIAL, SL1->L1_DOC, cPrefixo, "", SL1->L1_NUM })
		EndIf
	EndIf

	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posicao do Parametro de Geracao de Comissao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(cL1ConfVen,11,1) <> "N"

			For nL1Filhos := 1 to Len(aL1Filhos)

				If aL1Filhos[nL1Filhos,1] = "V"   //Procedimento normal (L1_TIPO = "V")
					DbSelectArea("SD2")
					SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					If SD2->(DbSeek(FWxFilial("SD2",aL1Filhos[nL1Filhos,2]) + aL1Filhos[nL1Filhos,3] + aL1Filhos[nL1Filhos,4] + cCodCli + cLojCli))
						While SD2->(!Eof()) .AND. ;
							aL1Filhos[nL1Filhos,2] 	== SD2->D2_FILIAL	.AND. ;
							aL1Filhos[nL1Filhos,3] 	== SD2->D2_DOC 		.AND. ;
							aL1Filhos[nL1Filhos,4] 	== SD2->D2_SERIE 	.AND. ;
							cCodCli 				== SD2->D2_CLIENTE	.AND. ;
							cLojCli 				== SD2->D2_LOJA
							
							nValTotD2	:= 	SD2->D2_TOTAL
							If cMV_LJDVACR == "1"
								nValDevD2 	:=	(SD2->D2_VALDEV + SD2->D2_VALACRS) - (SD2->D2_DESCON + SD2->D2_DESCZFR)
							Else
								nValDevD2 	:=	SD2->D2_VALDEV - ((SD2->D2_QTDEDEV * (SD2->D2_DESCON/SD2->D2_QUANT)) + (SD2->D2_QTDEDEV * (SD2->D2_DESCZFR/SD2->D2_QUANT)))
							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica qual e a nova Base para o calculo da comissao³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nBaseComis := nValTotD2 - nValDevD2
							cVendedor := cL1Vend
							
							If cTpComiss == "2" //2-Comissao por item. Verifica qual eh o vendedor do item
								If SL2->(DbSeek(FWxFilial("SL2",aL1Filhos[nL1Filhos,2]) + aL1Filhos[nL1Filhos,4] + aL1Filhos[nL1Filhos,3] + SD2->D2_COD ))
									While SL2->(!EoF()) .And. (FWxFilial("SL2",aL1Filhos[nL1Filhos,2])+aL1Filhos[nL1Filhos,4]+aL1Filhos[nL1Filhos,3]+SD2->D2_COD == SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC+SL2->L2_PRODUTO)
										If SD2->D2_ITEM == SL2->L2_ITEM
											If !Empty(SL2->L2_VEND)
												cVendedor := SL2->L2_VEND
											EndIf
										EndIf
										SL2->(DbSkip())
									End
								EndIf
							EndIf

							// Se o Vendedor do L2_ITEM diferente do Vendedor SL1							
							If cL1Vend  <> cVendedor
								// Se o Vendedor for da SL2, atriui o Gerente e o Supervisor 
								If SA3->(MsSeek(xFilial("SA3")+cVendedor))
									cL1Vend2 := SA3->A3_SUPER
									cL1Vend3 := SA3->A3_GEREN
								EndIf	
							EndIf

							Lj720AtrCm(@aComissoes,cVendedor,nBaseComis)
							
							// Se o Vendedor estiver configurado com Supervisor
							// Adiciona no array aComissoes, para realizar o cáculo da Comissão
							If !Empty(cL1Vend2)
								Lj720AtrCm(@aComissoes,cL1Vend2,nBaseComis)								
							EndIf

							// Se o Vendedor estiver configurado com Gerente
							// Adiciona no array aComissoes, para realizar o cáculo da Comissão							
							If !Empty(cL1Vend3)
								Lj720AtrCm(@aComissoes,cL1Vend3,nBaseComis)								
							EndIf

							SD2->(DbSkip())
						End
					Endif
				Else		//Há pedido de venda ligado ao orçamento filho (L1_TIPO = "P")
				
					DbSelectArea("SD2")
					SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					If !Empty(aL1Filhos[nL1Filhos,3]) .AND. !Empty(aL1Filhos[nL1Filhos,4]) .AND.;
					        SD2->(DbSeek(FWxFilial("SD2",aL1Filhos[nL1Filhos,2]) + aL1Filhos[nL1Filhos,3] + aL1Filhos[nL1Filhos,4] + cCodCli + cLojCli))

						cNumPed := SD2->D2_PEDIDO
						nValDevD2 := 0
						nValTotPed := 0
						
						DbSelectArea("SL2")
						SL2->(DbSetOrder(1)) 	//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
						DbSelectArea("SD2")
						SD2->(DbSetOrder(8))	//D2_FILIAL+D2_PEDIDO+D2_ITEMPV

						//Aqui eu leio todos os itens de documento relacionado a um pedido, inclusive multiplos faturamentos parciais
						If SD2->(DbSeek(FWxFilial("SD2",aL1Filhos[nL1Filhos,2])+cNumPed))

							//Cabeçalho: Cálculo de SC6: Se Comissão por Venda, eu somo o valor total do pedido primeiro
							If cTpComiss = "1"		//Comissão por Venda
								cVendedor := cL1Vend
								//Retornará um array de somente um item
								aRetSC6 := Lj720Sc6(cTpComiss, cVendedor, aL1Filhos[nL1Filhos,2], cNumPed)
								If Len(aRetSC6) >= 1 .AND. Len(aRetSC6[1]) >= 2
									nValTotPed += aRetSc6[1, 2]
								EndIf
							EndIf

							//Procedimento para Soma de devolução de todos os itens vinculados a aquele pedido de venda
							While SD2->(!Eof()) .AND. ;
								SD2->D2_FILIAL == FWxFilial("SD2",aL1Filhos[nL1Filhos,2]) .AND.;
								SD2->D2_PEDIDO == cNumPed
								
								nValItDev := 0
								nValItPed := 0

								If cMV_LJDVACR == "1"
									nValItDev 	+=	(SD2->D2_VALDEV + SD2->D2_VALACRS) - (SD2->D2_DESCON + SD2->D2_DESCZFR)
								Else
									nValItDev 	+=	SD2->D2_VALDEV - ((SD2->D2_QTDEDEV * (SD2->D2_DESCON/SD2->D2_QUANT)) + (SD2->D2_QTDEDEV * (SD2->D2_DESCZFR/SD2->D2_QUANT)))
								EndIf

								nValDevD2 += nValItDev
								cVendedor := cL1Vend
								
								//Cálculos para Comissão por Item
								If (cTpComiss == "2")
									//Retornará um array de somente um item
									//Dentro desta função retorna o vendedor correspondente ao item no elemento 1 de aRetSC6
									aRetSC6 := Lj720Sc6(cTpComiss, cVendedor, aL1Filhos[nL1Filhos,2], SD2->D2_PEDIDO,;
												SD2->D2_ITEMPV, SD2->D2_COD, aL1Filhos[nL1Filhos,6])

									If Len(aRetSC6) >= 1 .AND. Len(aRetSC6[1]) >= 2 .AND. aRetSC6[1,2] > 0
										//Verifica qual e a nova Base para o calculo da comissao
										Lj720AtrCm(@aComissoes,aRetSC6[1,1],aRetSC6[1,2]-nValItDev)

									EndIf

								EndIf

								DbSelectArea("SD2")
								SD2->(DbSkip())
							Enddo

							//Rodapé: Calculo a base de cálculo para cada comissão
							If cTpComiss = "1"
								//Verifica qual e a nova Base para o calculo da comissao
								nBaseComis := nValTotPed - nValDevD2
								Lj720AtrCm(@aComissoes,cVendedor,nBaseComis)

								// Se o Vendedor estiver configurado com Supervisor
								// Adiciona no array aComissoes, para realizar o cáculo da Comissão
								If !Empty(cL1Vend2)
									Lj720AtrCm(@aComissoes,cL1Vend2,nBaseComis)								
								EndIf

								// Se o Vendedor estiver configurado com Gerente
								// Adiciona no array aComissoes, para realizar o cáculo da Comissão							
								If !Empty(cL1Vend3)
									Lj720AtrCm(@aComissoes,cL1Vend3,nBaseComis)								
								EndIf

							EndIf
						EndIf
					Else  //Leio somente o saldo de pedidos em SC6

						nValDevD2 := 0
						nValTotPed := 0
						cVendedor := cL1Vend
						aRetSC6 := Lj720Sc6(cTpComiss,cVendedor, aL1Filhos[nL1Filhos,2],aL1Filhos[nL1Filhos,5])

						For nX := 1 to Len(aRetSC6)
						
							If aRetSC6[nX,2] > 0
								//Verifica qual e a nova Base para o calculo da comissao
								Lj720AtrCm(@aComissoes,aRetSC6[nX,1],aRetSC6[nX,2])
							EndIf
						Next

					EndIf

				EndIf
			Next
			
			DbSelectArea("SE3")
			SE3->(DbSetOrder(2)) //E3_FILIAL+E3_VEND+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica quantas parcelas foram geradas na comissao e atualiza array "aComissoes"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX:=1 To Len(aComissoes)
				cVendedor := aComissoes[nX][1]
				If SE3->(DbSeek(FWxFilial("SE3",cFilOrig) + cVendedor + cPrefixo + cL1Doc))
					While SE3->(!Eof()) .AND. (!Empty(cL1Vend)) .AND. (cVendedor + cPrefixo + cL1Doc == SE3->E3_VEND + SE3->E3_PREFIXO + SE3->E3_NUM);
										.AND. SE3->E3_FILIAL == FWxFilial("SE3",cFilOrig)
						aComissoes[nX][3] := aComissoes[nX][3] + 1
						aAdd( aComissoes[nX][4], SE3->(Recno()) )
						SE3->(DbSkip())
					End
				EndIf
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza valores da Comissao. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX:=1 To Len(aComissoes)
				
				cVendedor 	:= aComissoes[nX][1]
				nBaseComis	:= aComissoes[nX][2]
				nQtdParc 	:= aComissoes[nX][3]
				
				For nY:=1 To Len(aComissoes[nX][4])
					SE3->(DbGoTo(aComissoes[nX][4][nY])) //Posiciona na SE3
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Nao estorna comissoes ja baixadas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( SE3->E3_DATA )
						//A comissão do vendedor já foi paga. Deverá ser revista"
						MsgInfo(STR0075)
						Loop
					Endif
					
					//Calcula o valor da Comissao referente a parcela.
					nVlrComis := Round( ( nBaseComis / nQtdParc * SE3->E3_PORC ) / 100 ,nDecs)
					
					//Calcula a base da Comissao referente a parcela.
					nBaseParCom := Round( nBaseComis / nQtdParc ,nDecs)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza‡„o de Comiss”es ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("SE3",.F.,.T.)
					
					//- Se a Base da Comissao for zero, entao deleta o registro do SE3, caso contrario, atualiza. 
					//- Se for Troca,e calculo da comissao pela baixa e for Dinheiro nao deleta o registro caso contrario deleta. 
				    If SE3->E3_BAIEMI <> "B" .OR. !lTroca .OR. (SE3->E3_BAIEMI == "B" .AND. !ISMONEY(SE3->E3_TIPO) )
				    	//Devolução em dinheiro || Comissao por Item || Dev em NCC e Permite Gerar Comissao para Devolucao
						If nFormaDev == 1  .OR. cTpComiss == "2" .Or. (nFormaDev == 2 .And. SuperGetMV("MV_COMIDEV",,.F.))
							LjGrvLog( "TROCA_DEVOLUCAO", "Vendedor             : ", SE3->E3_VEND)
							LjGrvLog( "TROCA_DEVOLUCAO", "Base  Comis. Anterior: ", Str(SE3->E3_BASE))
							LjGrvLog( "TROCA_DEVOLUCAO", "Valor Comis. Anterior: ", Str(SE3->E3_COMIS))
							If nBaseComis == 0
								SE3->(DbDelete())
								LjGrvLog( "TROCA_DEVOLUCAO", "Base  Comis. = 0 e Valor Comis = 0 - Registro deletado" )
							Else
								REPLACE SE3->E3_BASE  	WITH nBaseParCom
								REPLACE SE3->E3_COMIS	WITH nVlrComis
								LjGrvLog( "TROCA_DEVOLUCAO", "Base  Comis. Atual: ", Str(nBaseParCom))
								LjGrvLog( "TROCA_DEVOLUCAO", "Valor Comis. Atual: ", Str(nVlrComis))
							EndIf
						EndIf
					EndIf	
					SE3->(MsUnlock())
					
				Next nY
				
			Next nX
			
		Endif
	Endif
Next nC
RestArea(aAreaL1)
RestArea(aAreaL2)
RestArea(aAreaD2)
RestArea(aArea)

Return Nil
          
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj720CnSD9ºAutor  ³ Vendas Cliente     º Data ³ 11/09/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cancela a reserva do numero de nota na SD9                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Numero do documento a ser limpo 		              º±±
±±º          ³ExpC2 - Serie do documento a ser Limpo		              º±±
±±º          ³ExpC3 - Tipo de controle de geracao de documentos           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj720CnSD9(cDoc, cSerie, cMV_TPNRNFS)

Local lGrpCNPJ	 := If(ExistFunc("MaIsNumCgc"),MaIsNumCgc(),.F.) // Verifica a utilizacao da numeracao por Agrupamento por CNPJ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So devera voltar a sequencia do SD9 quando estiver configurar para que³
//³ser utilizada conforme boletim 006 - LOJA - Numeracao de NF pelo SD9  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMV_TPNRNFS == "3" .AND. SuperGetMV("MV_LJNFSXE")	

	SD9->( DbSetOrder( 2 ) )
	SD9->( DbSeek( xFilial( "SD9" ) + cSerie + cDoc ) )
	
	If !SD9->( Eof() )
		RecLock("SD9",.F.)
		REPLACE D9_DTUSO 	WITH Ctod("  /  /  ")
		REPLACE D9_HORA		WITH ""
		REPLACE D9_USUARIO 	WITH ""

		If lGrpCNPJ // Realiza a Liberacao conforme Agrupamento por CNPJ

			Replace D9_FILIAL    With ""
			Replace D9_FILORI    With ""

		Endif		
		
		SD9->(MsUnlock())
	EndIf

Endif
	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjImpCNfisc ºAutor  ³ Vendas Cliente     º Data ³  07/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime cupom nao fiscal nao vinculado quando utilizar troca  º±±
±±º          ³ou devolucao.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpA1 - Informacoes do documento de troca                    º±±
±±º          ³    [1] - Serie do documento                                  º±±
±±º          ³    [2] - Novo documento                                      º±±
±±º          ³    [3] - Cliente                                             º±±
±±º          ³    [4] - Loja                                                º±±
±±º          ³    [5] - 1) Troca  2) Devolucao                              º±±
±±º          ³ ExpN1 - Valor total a ser devolvido ou trocado               º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjImpCNfisc( aDocDev, nVlrTotal	)
Local cTickForm := ""      	// String que guarda o que sera impresso.
Local nI 		:= 0       	// Contator para o For
Local nRet		:= 0 
Local lImprime  := .T.		// Indica se imprime novamente o relatorio gerencial na impressora
Local lRetAskImp:= .F.
Local lFechImpNF:= .F.
Local lLjxImpRede:= ExistFunc("LjxImpRede")
Local lIsRede	:= .F.
Local cImpres	:= ""
Local cPorta	:= ""

LjGrvLog( "TROCA_DEVOLUCAO", "Efetuando impressao do comprovante")

If LjAnalisaLeg(22)[1]
	For nI := 1 To Len( aDocDev )
		Do Case
			Case nI == 1
				cTickForm += CHR(13) + CHR(10)
				cTickForm += PadR( STR0081 + aDocDev[nI], 40 ) + CHR(13) + CHR(10) // "Serie....: "
				cTickForm += CHR(13) + CHR(10)
			Case nI == 2
				cTickForm += PadR( STR0082 + aDocDev[nI], 40 ) + CHR(13) + CHR(10) // "Documento: "
				cTickForm += CHR(13) + CHR(10)
			Case nI == 3
				cTickForm += PadR( STR0083 + aDocDev[nI], 40 ) + CHR(13) + CHR(10) // "Cliente..: "
				cTickForm += CHR(13) + CHR(10)
			Case nI == 4
				cTickForm += PadR( STR0084 + aDocDev[nI], 40 ) + CHR(13) + CHR(10) // "Loja.....: "
				cTickForm += CHR(13) + CHR(10)
			Case nI == 5		   
				If aDocDev[nI] == 1
					cTickForm += PadR( STR0085 + Transform(nVlrTotal, "99,999.99" ), 40 ) + CHR(13) + CHR(10) // "Valor Total da Troca.....: R$ "
				Else
					cTickForm += PadR( STR0086 + Transform(nVlrTotal, "99,999.99" ), 40 ) + CHR(13) + CHR(10) // "Valor Total da Devolucao.: R$ "
				EndIf
				cTickForm += CHR(13) + CHR(10)
		EndCase
	Next nI

	While lImprime
		nRet 	:= -1
		
		//Só mando conectar se for Faturamento pois no Loja 
		//a impressora ja teria que estar conectada
		If (nModulo == 5 .And. nHdlECF == -1)

			If lLjxImpRede
				lIsRede := LjxImpRede( .F. ,.F. )
				lIsRede := IIf(lIsRede == NIL, .F. , lIsRede)
			EndIf		
			
			cPorta := LJGetStation("PORTIF")
			cImpres := LJGetStation("IMPFISC")
			
			If lIsRede //Quando em rede conecta dentro da INFTEXTO
				lImprime := .T.
			ElseIf !Empty(AllTrim(cImpres)) .And. !Empty(AllTrim(cPorta))
				LjMsgRun(STR0233 ,,{ || nHdlECF := INFAbrir(cImpres,cPorta)}) //"Aguarde. Abrindo a Impressora Não Fiscal..."
				lImprime	:= nHdlECF == 0
				lFechImpNF	:= nHdlECF == 0
			Else
				lImprime := .F.
			EndIf
		EndIf
		
		If lImprime
			nRet	 := IFRelGer( nHdlECF, cTickForm, 1 , "", nModulo == 5)
			lRetAskImp:= LjTEFAskImp(1, @nRet)
			lImprime := lRetAskImp //quando der erro com ECF retorna .F. e deve tentar novamente
		EndIf
		
		//Fecha a porta somente se for Faturamento 
		If !lImprime .And. lFechImpNF
			INFFechar(cPorta)
			nHdlECF := -1
		EndIf
	End
EndIf

LjGrvLog( "TROCA_DEVOLUCAO", "Fim da impressao do comprovante")

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjLogDevol ³ Autor ³ Vendas Cliente        ³ Data ³ 05.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Registro de devolucao de cupom fiscal / item                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjLogDevol()                                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjLogDevol(nRecnoTRB)
Local lRet      := .T.
Local aArea     := GetArea()
Local cPDV      := ""
Local cCaixa    := ""
Local lGeraOP	:= .F.
Local lHasOTC	:= .F.

cPdv   := LjGetStation( "PDV" )
cCaixa := xNumCaixa()
     
If !Empty(nRecnoTRB)
	
	lGeraOP := SuperGetMV("MV_GROPOTC ",.F.,.F.) //Parâmetro para verificar a necessidade de criar ou não Ordem de Produção para o template Otica
	lHasOTC := Hastemplate("OTC")
	
	DbSelectArea( "TRB" )
	DbGoTo(nRecnoTRB)	
		
	While !Eof()
		DbSelectArea( "SLX" )
		RecLock( "SLX", .T. )
		REPLACE SLX->LX_FILIAL  WITH xFilial( "SLX" )
		REPLACE SLX->LX_PDV     WITH cPDV
		REPLACE SLX->LX_OPERADO WITH cCaixa 
		REPLACE SLX->LX_DTMOVTO WITH dDatabase
		REPLACE SLX->LX_HORA    WITH Time()
		REPLACE SLX->LX_CUPOM   WITH TRB->TRB_NFORI
		SerieNfId("SLX",1,"LX_SERIE",dDataBase,LjEspecieNF(),TRB->TRB_SERORI)
		REPLACE SLX->LX_ITEM    WITH TRB->TRB_ITEM
		REPLACE SLX->LX_VALOR   WITH TRB->TRB_VLRTOT
		REPLACE SLX->LX_PRODUTO WITH TRB->TRB_CODPRO
		REPLACE SLX->LX_QTDE    WITH TRB->TRB_QUANT
		REPLACE SLX->LX_SITUACA WITH "00"
		REPLACE SLX->LX_TPCANC  WITH "D"
	
		SLX->(MsUnlock())
		If lHasOTC
			If lGeraOP 
				If StatusDoc(TRB->TRB_NFORI,TRB->TRB_SERORI,SD2->D2_CLIENTE,SD2->D2_LOJA,TRB->TRB_CODPRO)
					EstOPOtc(TRB->TRB_CODPRO,TRB->TRB_NFORI,TRB->TRB_SERORI,TRB->TRB_ITEM,SD2->D2_CLIENTE,SD2->D2_LOJA,3)	
				Endif
			Endif
		Endif
	
		DbSelectArea( "TRB" )
		DbSkip()
	End
Endif

RestArea( aArea )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³Lj720AltMd³ Autor ³ Vendas Cliente        ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita ou Desabilita o combo Devolucao em Outro Moeda    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj720AltMd(ExpN1,ExpO2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 := Forma de devolucao                                ³±±
±±³          ³ ExpO2 := Objeto a ser atualizado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Se permite a edicao ou nao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA720 - Localizacoes       				              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj720AltMd( nFormaDev , oDevMoeda )
Local lRet	:= .T.                                // Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente para localizacoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA" 

	If nFormaDev == 1
		oDevMoeda:Enable()
	Else
		oDevMoeda:Refresh()
		oDevMoeda:Disable()
	Endif	
	
	oDevMoeda:Refresh()          

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj720VldDev   ³ Autor ³ Vendas Cliente   ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia o aCols para as Notas de Devolucao, baseando-se em  ³±±
±±³			 ³ SL1 e SL2 (com Nota de Entrada) ou dados digitados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj720VldDev(ExpN1,ExpA2,ExpN3,ExpN4,ExpN5)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj720VldDev(nRecno)    						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 := Valor total envolvido na operacao                 ³±±
±±³          ³ ExpA2 := Array com os dados da devolucao                   ³±±
±±³          ³ ExpN3 := Moeda                                             ³±±
±±³          ³ ExpN4 := Taxa da moeda                                     ³±±
±±³          ³ ExpN5 := Se eh com ou sem Nota de Entrada                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Retorno da funcao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA720 - Localizacoes 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720VldDev( nVlrTotal , aDevol , nMoedaCorT , nTxMoedaTr ,;
					  nNfOrig )

Local lRet       := .F.										//Retorno da funcao
Local nOpcDev    := 2										//Opcao escolhida
Local nDecs1	 := MsDecimais(1)							//Decimais
Local nX		 := 0										//Contador de For		
Local nTam       := TamSx3("L1_VLRTOT")[1]					//Tamanho do campo L1_VLRTOT
Local cTitulo    := ""										//Titulo do objeto
Local cDescMoeda := ""										//Descricao da moeda
Local aArea      := GetArea()								//Guarda area
Local aCabGrid   := {STR0093,STR0094,STR0095}				//"Moeda"###"Saldo"###"Valor da Devolucao"
Local aTamGrid   := {}										//Tamanho do Grid
Local aDevolBck  := Array(9)								//Bkp do array

Local oButton												//Botao de confirmacao
Local oButton2												//Botao de cancelamento
Local oDlgDev												//Objeto de devolucao
Local oValorDev												//Valor da devolucao

Default nVlrTotal := 0										//Valor total
Default aDevol 	  := {}										//Dados da devolucao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as moedas cadastradas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
For nX := 1 To MoedFin()
	If RecMoeda(dDataBase,nX) > 0
		If !Empty(SuperGetMv("MV_MOEDA"+AllTrim(Str(nX))))
			AAdd(aDevol, { SuperGetMv("MV_MOEDA"+AllTrim(STR(nX))),	0,	0,	0,;
							0,	nX	})
		Endif
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for devolucao com Nota de Entrada, trabalha com o ³
//³valor total de produtos devolvidos. Caso contrario   ³
//³com o total digitado                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNfOrig == 1
	aDevol[1][_SALDO]  := nVlrTotal		
Else
	nVlrTotal := Round(xMoeda( 	nVlrTotal , nMoedaCorT , 1 , NIL ,;
								nDecs1+1  , nTxMoedaTr), nDecs1 )
EndIf

If nVlrTotal > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenche itens com zero ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AFill(aDevolBck,0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descricao da moeda corrente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDescMoeda  := SuperGetMv("MV_MOEDA"+AllTrim(Str(nMoedaCorT)))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula a devolucao inicial³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj720CDeIn(nVlrTotal,@aDevol,nMoedaCorT,nTxMoedaTr)

	If !IsBlind()
		// Devolu‡„o (Forma de pagamento)
		DEFINE MSDIALOG oDlgDev TITLE STR0096 ;
		From 10,30 To 30,82 OF GetWndDefault()
		
		@ 0,1 TO 22,200 OF oDlgDev PIXEL
		
		@ 8.5,  3 Say STR0097 OF oDlgDev PIXEL SIZE 25,8  	// Forma:
		@ 8.5, 22 Say STR0098 OF oDlgDev PIXEL SIZE 25,8  	// DINHEIRO
		@ 8.5, 55 Say STR0099 OF oDlgDev PIXEL SIZE 50,8	// Valor a devolver
		
		@ 6, 100 MSGET oValorDev VAR nVlrTotal PICTURE PesqPict("SL1","L1_VLRTOT");
		SIZE 55,6 OF oDlgDev  PIXEL  RIGHT WHEN .F.
		
		@ 8.5, 160 Say cDescMoeda of oDlgDev PIXEL SIZE 50,8
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tamanho da primeira linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo := aCabGrid[1]
		AAdd(aTamGrid,If(nTam > Len(Trim(cTitulo)),nTam*3,Len(Trim(cTitulo))*3))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tamanho da segunda linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo := aCabGrid[2]
		AAdd(aTamGrid,If(nTam > Len(Trim(cTitulo)),nTam*4.1,Len(Trim(cTitulo))*4.1))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tamanho da terceira linha³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo := aCabGrid[3]
		AAdd(aTamGrid,If(nTam > Len(Trim(cTitulo)),nTam*4.1,Len(Trim(cTitulo))*4.1))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o Browser³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oLBBaixa := TwBrowse():New(		025,	001,	000,	000,	;
										NIL,aCabGrid,aTamGrid,oDlgDev,	;
										NIL,	NIL,	NIL,	NIL,	;
										NIL,	NIL,	NIL,	NIL,	;
										NIL,	NIL,	NIL,	.F.,	;
										NIL,	.T.,	NIL,	.F.,	;
										NIL,	NIL,	NIL		)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define tamanho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oLBBaixa:lHScroll := .T.
		oLBBaixa:lVScroll := .T.
		oLBBaixa:nHeight  := 200
		oLBBaixa:nWidth   := 400
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define as acoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oLBBaixa:SetArray(aDevol)
		oLBBaixa:bLine      := {|| {aDevol[oLBBaixa:nAT][_DESCMOEDA],Transform(aDevol[oLBBaixa:nAT][_SALDO],PesqPict("SL1","L1_VLRTOT",18,;
									oLBBaixa:nAT)) ,Transform(aDevol[oLBBaixa:nAT][_VALORDEV],PesqPict("SL1","L1_VLRTOT",18,oLBBaixa:nAT)) }}
		oLBBaixa:bLDblClick := {|| Lj720DblDe( nVlrTotal , @aDevolBck , @aDevol , nMoedaCorT ,;
		 									    nTxMoedaTr )}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa botao de confirmacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE SBUTTON oButton FROM 130,140 TYPE 1 ACTION (If(Lj720VldPgto(nVlrTotal,@aDevol,nMoedaCorT,nTxMoedaTr)  ,;
		(nOpcDev := 1,oDlgDev:End()),nOpcDev := 0)) ENABLE OF oDlgDev
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa botao de cancelamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE SBUTTON oButton2 FROM 130,170 TYPE 2 ACTION (nOpcDev := 2,oDlgDev:End());
		ENABLE OF oDlgDev
		
		ACTIVATE MSDIALOG oDlgDev VALID Lj720Valid(nOpcDev) CENTERED
	Else
		nOpcDev := 1
	EndIf
	
	If nOpcDev <> 1
		RestArea( aArea )
		//"Atencao"###"Transacion no efectuada!"###"OK"
		MsgAlert(STR0100,STR0091)  
		lRet := .F.
	Else
		lRet := .T.
	EndIf
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720CDeIn³ Autor ³ Vendas Cliente        ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula os valores iniciais da devolucao nas moedas cadas- ³±±
±±³          ³ tradas                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj720DblDe(ExpN1,ExpA2,ExpN3,ExpN4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 := Valor total envolvido na operacao                 ³±±
±±³          ³ ExpA2 := Array com os dados da devolucao                   ³±±
±±³          ³ ExpN3 := Moeda                                             ³±±
±±³          ³ ExpN4 := Taxa da moeda                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Retorno da funcao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA720 - Localizacoes       				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720CDeIn( nVlrTotal , aDevol , nMoedaCorT , nTxMoedaTr )
Local nX 			:= 0								//Contador do For
Local nDecs  		:= 2								//Decimais
Local lMoedaUnica  	:= .F.  							//Ha apenas uma moeda ativa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a devolucao eh em apenas uma moeda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aDevol) == 1
	lMoedaUnica := .T.
EndIf

For nX := 1 to Len(aDevol)
	nDecs  := MsDecimais(nX)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o saldo para cada moeda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDevol[nX][_SALDO] := Round( xMoeda(  nVlrTotal  ,nMoedaCorT  ,nX  ,dDatabase  ,;
	 									   nDecs+1)  ,  nDecs  )
	aDevol[nX][_VLRORIG] := aDevol[nX][_SALDO]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sendo moeda unica, o saldo eh todo calculado para ela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMoedaUnica
		aDevol[nX][_VALORDEV] := aDevol[nX][_SALDO]
		aDevol[nX][_SALDO]    := 0
	EndIf
Next nX

Return .T.

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720DblDe³ Autor ³ Vendas Cliente        ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite a edicao dos valores da devolucao atraves do duplo ³±±
±±³          ³ clique                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj720DblDe(ExpN1,ExpA2,ExpA3,ExpN4,ExpN5)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 := Valor total envolvido na operacao                 ³±±
±±³          ³ ExpA2 := Bkp de Array para devolucao                       ³±±
±±³          ³ ExpA3 := Array com os dados da devolucao                   ³±±
±±³          ³ ExpN4 := Moeda                                             ³±±
±±³          ³ ExpN5 := Taxa da moeda                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Retorno do duplo-clique                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA720 - Localizacoes       				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720DblDe(nVlrTotal,aDevolBck,aDevol,nMoedaCorT,nTxMoedaTr)
Local nPosOri := oLBBaixa:ColPos			//Linha atual

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coluna a ser editada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLBBaixa:ColPos := 3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Edita a celula da terceira coluna das moedas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lEditCell(  aDevol  ,  oLBBaixa  ,PesqPict("SL1","L1_VLRTOT",TamSx3("L1_VLRTOT")[1],oLBBaixa:nAT)  ,  3  )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a coluna³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLBBaixa:ColPos := nPosOri
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua os recalculos necessarios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Lj720RecDev(nVlrTotal	,oLBBaixa:nAT	,@aDevolBck		,@aDevol,;
			nMoedaCorT	,nTxMoedaTr	)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjRecalcDe³ Autor ³ Vendas Cliente        ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula os valores da devolucao nas moedas cadastradas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj720VldPgto(ExpN1,ExpN2,ExpA3,ExpA4,ExpN5,ExpN6) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 := Valor total envolvido na operacao                 ³±±
±±³          ³ ExpN2 := Linha atual do objeto                             ³±±
±±³          ³ ExpA3 := Bkp Array com os dados                            ³±±
±±³          ³ ExpA4 := Array com os dados da devolucao                   ³±±
±±³          ³ ExpN5 := Moeda para devolucao                              ³±±
±±³          ³ ExpN6 := Taxa da moeda                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Permite ou nao efetuar a devolucao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA720 - Localizacoes       				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720RecDev( nVlrTotal , nLinha , aDevolBck , aDevol , ;
							nMoedaCorT ,nTxMoedaTr )

Local nX								//Contador de For
Local nDif      := 0					//Valor de diferenca
Local nVlrDigit := 0					//Valor digitado
Local nDecs     := 2					//Decimais
Local nDecs1    := MsDecimais(1)		//Decimais 2
Local lZeraTudo := .F.					//Se zera tudo
Local nSoma     := 0					//Soma dos valores

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a diferenca de valores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDif  := aDevol[nLinha][_VALORDEV] - aDevolBck[nLinha]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma a diferenca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDevol[nLinha][_SOMADEV] += nDif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena o valor digitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrDigit := aDevol[nLinha][_SOMADEV]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha necessidade de zerar todos os valores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lZeraTudo  := aDevol[nLinha][_SOMADEV] == aDevol[nLinha][_VLRORIG]

For nX:= 1 To Len(aDevol)

	nDecs := MsDecimais(nX)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Converte o somatorio da devolucao digitado pelo usuario da moeda escolhida para a moeda correspondente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDevol[nX][_SOMADEV] := Round( xMoeda( nVlrDigit , nLinha , nX , dDataBase ,;
											nDecs+1)  ,nDecs)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor digitado e maior que o valor original³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lZeraTudo .AND. aDevol[nX][_VLRORIG] - aDevol[nX][_SOMADEV] < 0  

		If aDevol[nX][_SOMADEV] - aDevol[nX][_VLRORIG] >= 1/(10**nDecs)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³1/(10**nDecs) -> Tolerancia de arredondamento                                     ³
			//³Se a diferenca entre o digitado e o saldo for maior que a tolerancia 1/(10**nDecs)³
			//³entao exibe mensagem que valor digitado e maior                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//"Atencao"###"O valor digitado e maior que o saldo da devolucao."###"OK"
			MsgAlert(STR0101,STR0091)  
			If nLinha > nX
				aDevol[nX][_SOMADEV] -= Round(xMoeda(nDif,nLinha,nX,dDataBase,nDecs+1),nDecs)
			EndIf

			aDevol[nLinha][_SOMADEV] -= nDif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Volta o valor que estava no grid (backup)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aDevol[nLinha][_VALORDEV]:= aDevolBck[nLinha] 

			Return NIL

		Endif

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula o saldo ( Valor original - Somatorio do valor informado )³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDevol[nX][_SALDO] := aDevol[nX][_VLRORIG] - aDevol[nX][_SOMADEV]   

		If aDevol[nX][_SALDO] > 0
			If aDevol[nX][_SALDO] < 1/( 10 ** nDecs )
				lZeraTudo := .T.
			Endif
		Endif

	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda o valor da devolucao digitado pelo usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDevolBck[nX]:= aDevol[nX][_VALORDEV] 

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o saldo de qualquer moeda estiver menor que            ³
//³a tolerancia de decimais, entao atribui .T. para lZeraTudo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lZeraTudo
	For nX:= 1 To Len(aDevol)
		nDecs  := MsDecimais(nX)                
		If aDevol[nX][_SALDO] < 1/(10**nDecs)  
			lZeraTudo := .T.                   
			Exit
		Endif
	Next nX
EndIf

If lZeraTudo
	For nX :=1 To Len(aDevol)
		nSoma  += Round( xMoeda( aDevol[nX][_VALORDEV] , nX , 1 , dDatabase,;
								  nDecs1+1)	, nDecs1 )
	Next nX

	nSoma := Round( xMoeda(	nVlrTotal , nMoedaCorT , 1 , dDatabase,;
							nDecs1+1) , nDecs1 ) - nSoma

	If Abs(nSoma) >= (1/10**nDecs1)
		aDevol[1][_VALORDEV]  += nSoma
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Vai zerar a coluna de saldos do grid³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX :=1 To Len(aDevol)
		aDevol[nX][_SALDO]  := 0
	Next nX
Endif

oLBBaixa:Refresh()

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj720VldPgto  ³ Autor ³ Vendas Cliente   ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada das 2 rotinas de validacao para efetuar a devolucao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj720VldPgto(ExpN1,ExpA2,ExpN3,ExpN4)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 := Valor total envolvido na operacao                 ³±±
±±³          ³ ExpA2 := Array com os dados da devolucao                   ³±±
±±³          ³ ExpN3 := Moeda atual                                       ³±±
±±³          ³ ExpN4 := Taxa da moeda                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Permite ou nao efetuar a devolucao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA720 - Localizacoes       				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720VldPgto( nVlrTotal , aDevol , nMoedaCorT , nTxMoedaTr )
Local lRet    := .T.		//Retorno da uncao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o saldo do Caixa na forma de pagto. Dinheiro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJVLDEV",,.F.)
	lRet := Lj720VerSaldo(@aDevol)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o total digitado pelo usuario corresponde ao total da devolucao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := Lj720CalcMoed(nVlrTotal,@aDevol,nMoedaCorT,nTxMoedaTr)
EndIf

Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj720VerSaldo ³ Autor ³ Vendas Cliente   ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar se existe saldo na moeda desejada para devolucao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj720VerSaldo(ExpA1)             	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpA1 := Array com os valores a devolver em n moedas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Permite ou nao fetuar a devolucao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA720 - Localizacoes          				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720VerSaldo(aDevol)
Local lRet      := .T.			//Retorno da funcao
Local nX		:= 0			//Contador de For

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o saldo eh devido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aDevol)
	If aDevol[nX][_VALORDEV] > 0
		If !LjVSaldo(aDevol[nX][_VALORDEV],SuperGetMv("MV_SIMB"+Str(nX,1)))
			lRet  := .F.
			Exit
		End
	EndIf
Next nX

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  ³Lj720CalcMoeº Autor ³ Vendas Cliente  º Data ³  21/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Calcula soma das moedas no valor da moeda 1               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   ³ ExpL1 := Lj720CalcMoed(ExpN1,ExpA2,ExpN3,ExpN4)           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametro ³ ExpN1 - Valor total da devolucao na moeda 1               º±±
±±º           ³ ExpA2 - Array com os dados da devolucao                   º±±
±±º           ³ ExpN3 - Moeda utilizada                                   º±±
±±º           ³ ExpN4 - Taxa da moeda utilizada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   ³ ExpL1 - Verdadeiro ou Falso                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ LOJA720 - Localizacoes                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720CalcMoed( nVlrTotal , aDevol , nMoedaCorT , nTxMoedaTr )
Local nSoma     := 0						//Valor total de devolucao
Local lRet 		:= .T.						//Retorno da funcao
Local nDecs1	:= MsDecimais(1)			//Decimais
Local nX		:= 0						//Contador de For
Local cMoeda1   := SuperGetMV("MV_MOEDA1")	//Moeda 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma o valor a ser devolvido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aDevol)
	nSoma  += Round( 	xMoeda(aDevol[nX][_VALORDEV],	nX	,	1	,	dDatabase,;
						nDecs1+1	)	,	nDecs1)
Next nX

nSoma := Round( xMoeda(	nVlrTotal, nMoedaCorT, 1, dDatabase, ;
						nDecs1+1), nDecs1) - nSoma

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o valor digitado corresponde com o saldo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nSoma >= ( 1/10 ** nDecs1 )

	//"A diferen‡a acima ser  acertada na Moeda "###". Deseja Continuar ? "
	If MsgNoYes( ( '$ ' + Transform( nSoma, PesqPict("SL1","L1_VLRLIQ",15,nMoedaCorT) ) + CRLF + STR0102 + cMoeda1 + STR0103 ) ) 
		aDevol[1][_VALORDEV] += nSoma
	Else
		lRet := .F.
	EndIf

ElseIf nSoma < 0

	//"Devolucao MAIOR que o valor original ! Favor corrigir valores !!"   "Aten‡„o"
	MsgAlert( ( '$ ' + Transform( nSoma, PesqPict("SL1","L1_VLRLIQ",15,nMoedaCorT) ) + CRLF + STR0104 ), STR0091 )  
	lRet := .F.

EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj720Valid³ Autor ³ Vendas Cliente        ³ Data ³ 21/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostrar as opcoes de devolucao ou troca                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±º Sintaxe  ³ ExpL1 := Lj720Valid(ExpN1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao escolhida                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 = Verdadeiro ou falso                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA720 - Localizacoes                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj720Valid(nOpcDev)
Local lRet  := .F.			//Retorno da funcao

If nOpcDev == 1
	lRet := .T.
EndIf

If !lRet
	//"Para confirmar ou anular a transação, use os botões abaixo."
	MsgAlert(STR0105)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Lj720TrcMoeda³Autor  ³ Vendas Cliente    ³ Data ³ 21/05/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Recalcula todo aCols, quando a alteracao na moeda corrente ³±±
±±³          ³ da venda.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±º Sintaxe  ³ Lj720TrcMoeda(ExpN1,ExpL2,ExpN3,ExpN4,ExpC5,ExpO6)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Moeda anteriormente utilizada                      ³±±
±±³          ³ ExpL2 = Se atualiza a moeda                                ³±±
±±³          ³ ExpN3 = Moeda atual                                        ³±±
±±³          ³ ExpN4 = Taxa da moeda atual                                ³±±
±±³          ³ ExpC5 = Arquivo temporario                                 ³±±
±±³          ³ ExpO6 = Objeto a ser atualizado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA720 - Localizacoes                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720TrcMoed(	nMoedaAnt	,	lMoeda	,	nMoedaCorT	,	nTxMoedaTr,	;
							 	cAliasTRB,	oGetdTRC	)

Local nX     	:= 0									//Contador de For
Local nTxPad   	:= RecMoeda(dDatabase,nMoedaCorT)		//Taxa padrao
Local nDecimais := MsDecimais(nMoedaCorT)				//Decimais
Local aRegsTemp := {}									//Registros temporarios

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o temporario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAliasTRB)
DbGoTo(1)
While TRB->(!Eof())
	If !(cAliasTRB)->TRB_FLAG
		Aadd(aRegsTemp,{	(cAliasTRB)->TRB_ITEM	,	(cAliasTRB)->TRB_CODPRO	,	(cAliasTRB)->TRB_DESPRO	,	(cAliasTRB)->TRB_QUANT	,;
							(cAliasTRB)->TRB_PRCVEN	,	(cAliasTRB)->TRB_VLRTOT	,	(cAliasTRB)->TRB_UM 	,	(cAliasTRB)->TRB_TES	,;
							 RecNo() })
	EndIf
	TRB->(DbSkip())
End

If Len(aRegsTemp) > 0
	If If(lMoeda,nMoedaAnt <> nMoedaCorT, nTxMoedaTr <> nTxPad)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso a taxa da moeda nao tenha sido informada os calculos nao poderao ser ³
		//³realizados, pois ocorrera erro na execucao dos gatilhos.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTxMoedaTr <= 0
			//Nao ha cotacao para a moeda escolhida. A conversao da venda nao sera feita.
			MsgAlert(STR0106)
			Return Nil
		EndIf
					
		For nX := 1 To Len(aRegsTemp)	
			If !Empty(aRegsTemp[nX][2])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valoria a variavel n com a posicao do aRegsTemp que esta sendo lida, para que ³
				//³a funcao RunTrigger funcione corretamente                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If (nMoedaCorT <> nMoedaAnt) .AND. (nTxMoedaTr > 0)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula o novo valor unitario³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRegsTemp[nX][5] := Round(	xMoeda(	aRegsTemp[nX][5]	,  nMoedaAnt	,  nMoedaCorT  ,  dDataBase ,;
														nDecimais + 1		,  NIL 			,	nTxMoedaTr			)	,;
														nDecimais)
				EndIf
	        
	        EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicia gravacao do temporario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea(cAliasTRB)
			DbGoTo(aRegsTemp[nX][9])
			RecLock(cAliasTRB,.F.)

			REPLACE	TRB->TRB_PRCVEN	WITH aRegsTemp[nX][5]

			MsUnlock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa gatilho para quantidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj720Trigger('TRB_QUANT',TRB->TRB_QUANT)				

		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza objeto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetdTRC:oBrowse:Refresh()
		oGetdTRC:ForceRefresh()

	EndIf
EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720Lote ºAutor  ³ Vendas Cliente     º Data ³  29/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F4 que consulta o lote do produto, caso habilitado o        º±±
±±º          ³MV_Rastro                                                   º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³F4 que consulta o lote do produto, caso habilitado o        º±±
±±º          ³MV_Rastro                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720Lote( )
Local aArrayF4		:={}			// Armazena as linhas do DbSeek do Lote
Local cVar			:= ""			// Conteudo da list-box 					
Local cPict			:= ""			// Picture de exibicao do saldo
Local nOpca 		:= 0			// Opcao na selecao do objeto
Local nList 		:= 0			// Linha selecionada do objeto
Local nOrd 			:= IndexOrd()	// Guarda a ordem corrente
Local cProduto		:= TRB->TRB_CODPRO	// Codigo do Produto	
Local cLoteCt		:= ""			// Armazena o sub-lote selecionado
Local nSaldoLt 		:= 0			// Saldo acumulado do produto selecionado
Local cAlias		:= ""			// Armazena a Area corrente
Local cDtValid		:= ""			// Armaneza a data de validade do lote
Local cLote			:= ""			// Armaneza o lote
Local cProdutoLt	:= ""			// Aramzena o produto do lote

Local oDlg							// Obejto da montagem da tela de selecao
Local oQual							// Objeto da linha selecionada

If (ReadVar() $ "M->TRB_NUMLOT/M->TRB_LOTECT" .AND. Rastro(TRB->TRB_CODPRO)) .OR. ;
		"M->TRB_QUANT" $ ReadVar()

	cPict:=PesqPictQt("B8_SALDO",14)
	If Rastro( TRB->TRB_CODPRO )
		cAlias:=Alias()
		DbSelectArea("SB8")
		DbSetOrder(1)
		DbSeek(xFilial()+cProduto)

		While !EOF() .AND. xFilial( "SB8" ) + cProduto == SB8->B8_FILIAL + SB8->B8_PRODUTO
			If Rastro( cProduto )
				If B8_SALDO > 0
					AADD(aArrayF4, {	SB8->B8_LOTECTL, 		SB8->B8_NUMLOTE,	SB8->B8_PRODUTO,	Dtoc(SB8->B8_DATA),; 
										Dtoc(SB8->B8_DTVALID), Transform(SB8->B8_SALDO, cPict)})
					nSaldoLt += SB8->B8_SALDO
				EndIf	
			EndIf 
			DbSkip()				
		End

		If Len(aArrayF4) > 0
			nOpcA := 0
			DEFINE MSDIALOG oDlg TITLE STR0110 + STR0107 From 09,0 To 20,50 OF oMainWnd		//"Saldos por " + "Lote"
			@ 0.5,	0.0		TO	6, 20.0 OF oDlg
			@ 1.0,	0.7		Say STR0111		//"Saldo Dispon¡vel  "
			@ 2.0,	3.7		Say Transform( nSaldoLt, cPict )
   			@ 2.4,	0.7		LISTBOX oQual VAR cVar Fields HEADER STR0107,	STR0108, 	STR0019,;	// "Lote" # "Sub-Lote" # "Produto"
															STR0112 + STR0107, 		STR0109,	STR0094;	// "Data do" + "Lote" # "Validade do Lote" # "Saldo"
															SIZE 150,42 ON DBLCLICK (nList:= oQual:nAt, nOpca := 1,oDlg:End())	
			oQual:SetArray( aArrayF4 )
			oQual:bLine := { ||{aArrayF4[oQual:nAT,1],	aArrayF4[oQual:nAT,2],	aArrayF4[oQual:nAT,3],;
								aArrayF4[oQual:nAT,4],	aArrayF4[oQual:nAT,5],	aArrayF4[oQual:nAT,6]}}

			DEFINE SBUTTON FROM 10  ,166  TYPE 1 ACTION (nList:= oQual:nAt, nOpca := 1,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 22.5,166  TYPE 2 ACTION (nList:= oQual:nAt, oDlg:End()) ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg  
			
			If nOpca == 1

				cLote		:= aArrayF4[nList][1]		// Lote
				cProdutoLt	:= aArrayF4[nList][3]		// Produto
				cLoteCt 	:= aArrayF4[nList][2]		// Sub-lote
				cDtValid	:= aArrayF4[nList][5]		// Validade do lote

				If Rastro( cProdutoLt, "S" )
					If "M->TRB_LOTECT" $ ReadVar()
					    RecLock("TRB",.F.)
						REPLACE TRB_LOTECT WITH cLote
						REPLACE TRB_NUMLOT WITH cLoteCt 
						REPLACE TRB_DTVALI WITH CToD( cDtValid )  
						MsUnlock()
					EndIf      
				ElseIf Rastro( cProdutoLt, "L" )
					If "M->TRB_LOTECT" $ ReadVar()
					    RecLock("TRB",.F.)
						REPLACE TRB_LOTECT WITH cLote     
						REPLACE TRB_DTVALI WITH CToD( cDtValid )  
						MsUnlock()
					EndIf 		
				EndIf                  

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Restaura area anterior.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea( cAlias )
			EndIf
		Else
			Help(" ",1,"A440NAOLOTE")
		Endif    
	Else
		Help(" ",1,"A440NAOLOTE")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Devolve areas , indices e posicoes anteriores                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAlias)
	DbSetOrder(nOrd)
EndIf
oGetdTRC:oBrowse:Refresh()
oGetdTRC:ForceRefresh()
Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720ValCliºAutor  ³Vendas Clientes     º Data ³ 31/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o cliente informado pelo usuario                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja720                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720ValCli(cCliente,cLoja)
Local aArea		:= GetArea()						// Salva posicionamento atual
Local aAreaSA1	:= SA1->(GetArea())				// Salva posicionamento do SA1
Local lRet		:= .T.								// Retorno da funcao
Local cCliPad	:= SuperGetMV("MV_CLIPAD")			// Cliente padrao
Local cLojaPad	:= SuperGetMV("MV_LOJAPAD")			// Loja do cliente padrao

DbSelectArea("SA1")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o codigo informado pelo usuario existe³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := DbSeek(xFilial("SA1")+cCliente+cLoja)

If !lRet         
	MsgStop(STR0056,STR0033)//"O cliente selecionado não está cadastrado!"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o cliente a receber o credito eh diferente do cliente³
//³padrao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. !Empty(cLoja)
	lRet := (AllTrim(cCliente) <> AllTrim(cCliPad)) .OR. (AllTrim(cLoja) <> AllTrim(cLojaPad))
	If !lRet
		MsgStop(STR0115,STR0033)//"Não é permitida a troca/devolução de mercadorias para o cliente padrão" ### "Atencao"
	EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720ValDiaºAutor  ³Vendas Clientes     º Data ³ 19/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o diario contabil - Portugal                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja720                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720ValDia( cCodDia, lAliasCVL )
Local aArea		:= GetArea()						// Salva posicionamento atual
Local lRet		:= .F.								// Retorno da funcao

If cPaisLoc == "PTG" .AND. lAliasCVL
	DbSelectArea( "CVL" )
	DbSetOrder( 1 )
	If !DbSeek( xFilial( "CVL" ) + cCodDia )
		MsgStop( STR0117, STR0033 )               // "O diario informado nao esta cadastrado"
	Else
	   lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720DescrDiaºAutor  ³Vendas Clientes     º Data ³ 19/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o diario contabil - Portugal                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja720                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720DescrDia( cCodDia, lAliasCVL )
Local aArea		:= GetArea()						// Salva posicionamento atual
Local cReturn := "" 									// Retorno da funcao

If lAliasCVL
	DbSelectArea( "CVL" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "CVL" ) + cCodDia )
		cReturn := CVL->CVL_DESCR
	EndIf
EndIf

RestArea(aArea)

Return (cReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720ResidºAutor  ³Vendas CRM          º Data ³  10/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Elimina possiveis residuos referentes a pagamentos efetuadosº±±
±±º          ³utilizando adm. financeira com taxa de cobranca.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Lista com codigo e quantidade dos produtos da venda º±±
±±º          ³ExpC2 - Numero do titulo original                           º±±
±±º          ³ExpC3 - Serie do titulo original                            º±±
±±º          ³ExpN4 - Moeda corrente                                      º±±
±±º          ³ExpN5 - Valor total da venda a ser devolvida                º±±
±±º          ³ExpC6 - Codigo do cliente                                   º±±
±±º          ³ExpC7 - Loja do cliente           						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA720                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720Resid(	aSldItens	, cNumTit	, cPrefixo	, cPrefixoSaida	,;
							nMoedaCorT	, nVlrTotal	, cCliente	, cLoja		   	,;
							cCodFil )

Local aArea	   			:= GetArea()				// Armazena o posicionamento atual
Local aAreaTRB 			:= TRB->(GetArea())		// Armazena o posicionamento atual da tabela TRB
Local aAreaSE1 			:= SE1->(GetArea())		// Armazena o posicionamento atual da tabela SE1
Local aAreaSL1 			:= SL1->(GetArea())		// Armazena o posicionamento atual da tabela SE1
Local aAreaSAE			:= SAE->(GetArea())		// Armazena o posicionamento atual da tabela SAE
Local nPos				:= 0				   		// Indice do produto no array aSldItens
Local nSldProd			:= 0						// Saldo de produtos a serem devolvidos apos o processo
Local nSaldoTit			:= 0				   		// Saldo dos titulos gerados para a venda
Local cFilSE1			:= xFilial("SE1")	   		// Filial da tabela SE1
Local cFilSE1Ori		:= FWxFilial("SE1",cCodFil)	// Filial da tabela SE1 de origem da venda (onde foi realizada a venda)
Local nResiduo			:= 0						// Valor residual a ser abatido
Local cParcela			:= ""						// Parcela do titulo gerado
Local nTamE1_PARCELA	:= TamSX3("E1_PARCELA")[1]	// Tamanho do campo E1_PARCELA
Local cPrefTit			:= ""						// Prefixo a ser gravado no titulo
Local cNumE1			:= ""						// Numero do Titulo a ser gravado
Local cNatureza			:= ""						// Natureza a ser gravada no titulo
Local aVetMsExAut		:= {}						// Campos do titulo a ser gerado pela MsExecAuto
Local cPortador			:= ""						// Portador do titulo
Local lTemResid			:= .F.						// Indica de tem residuo ( CR )


Private lMsErroAuto		:= .F.						// Controle para execucao da execauto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Subtrai os produtos devolvidos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TRB")
DbGoTop()

While !TRB->(Eof())

	If  TRB->TRB_NFORI == cNumTit .AND. TRB->TRB_SERORI == cPrefixo
		If (nPos := aScan( aSldItens, {|x| x[1] == TRB->TRB_CODPRO  .AND. TRB->TRB_NFORI == x[3]   .AND. TRB->TRB_SERORI == x[4] })) > 0
			aSldItens[nPos][2] -= TRB->TRB_QUANT
		Else
			AAdd(aSldItens,{ TRB->TRB_CODPRO, TRB->TRB_QUANT, TRB->TRB_NFORI, TRB->TRB_SERORI })
		EndIf
	EndIf
	TRB->(DbSkip())
End

aSort(aSldItens, , , { |x,y| x[4] <  y[4].and. x[3] < y[3]})
//soma os itens da nota
aEval(aSldItens,{|x| IIF ( x[3] == cNumTit .AND. x[4] == cPrefixo  , nSldProd += x[2], )})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a devolucao nao for total, nao ira remover residuos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nSldProd <> 0
	RestArea(aAreaTRB)
	RestArea(aAreaSE1)
	RestArea(aArea)
	Return Nil
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma o total das parcelas pagas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SAE")
DbSetOrder(1) //AE_FILIAL+AE_COD

DbSelectArea("SE1")
DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
If SE1->(DbSeek( cFilSE1Ori + cPrefixoSaida + cNumTit ))
	If Empty(SE1->E1_BAIXA)
		While !SE1->(Eof()) 					.AND.;
			SE1->E1_FILIAL	== cFilSE1Ori		.AND.;
			SE1->E1_PREFIXO	== cPrefixoSaida	.AND.;
			SE1->E1_NUM		== cNumTit
			
			If SE1->E1_VlrReal > 0
				If SE1->E1_VLRREAL > 	SE1->E1_VALOR
					lTemResid	:= .T.
				EndIf
				nSaldotit	+=	 SE1->E1_VALOR
			Else
				nSaldotit	+=	 SE1->E1_VALOR 
			EndIf
				
			SE1->(DbSkip())
		
				
		End	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o valor a ser abatido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nResiduo := nVlrTotal - nSaldoTit
		
		If (nResiduo > 0) .AND. lTemResid   
		   	DbSelectArea( "SL1" )
		   	DbSetOrder( 2 ) //L1_FILIAL + L1_SERIE + L1_DOC
			DbSeek( FWxFilial("SL1",cCodFil) + cPrefixo + cNumTit)
		
			cParcela := PadR(SuperGetMV("MV_1DUP"), nTamE1_PARCELA) // Ajusta de acordo com o tamanho do E1_PARCELA
			cPrefTit := &(SuperGetMV("MV_LJPREF")) 
			If ExistFunc("LJ7NumTit")
				cNumE1 := LJ7NumTit()
			Else
				cNumE1	:= SL1->L1_DOC
			EndIf
		
			SX5->(DbSeek(xFilial("SX5")+"24"+PADR("CR",6)))
			cNatureza := If(Empty(SX5->X5_DESCRI),"CREDITO",SX5->X5_DESCRI)
		
			DbSelectArea("SE1")
			DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO	
		
			While SE1->(DbSeek(cFilSE1 + cPrefTit + cNumE1 + cParcela + 'CR '))
				cParcela := CHR(ASC(cParcela)+1)
			End
			
			cPortador	:= xNumCaixa()
		
			// Monta o array com as informacoes para a gravacao do titulo
			aVetMsExAut  := {	{"E1_PREFIXO"	,cPrefTit					,Nil},;
								{"E1_NUM"	  	,cNumE1						,Nil},;
								{"E1_PARCELA" 	,cParcela					,Nil},;
								{"E1_TIPO"	 	,'CR '						,Nil},;
								{"E1_NATUREZ" 	,cNatureza					,Nil},;
								{"E1_PORTADO" 	,cPortador					,Nil},;
					          	{"E1_CLIENTE" 	,cCliente					,Nil},;
				             	{"E1_LOJA"	  	,cLoja						,Nil},;
					          	{"E1_EMISSAO" 	,dDataBase 					,Nil},;
						       	{"E1_VENCTO"  	,dDataBase 					,Nil},;
						       	{"E1_VENCREA" 	,DataValida(dDataBase)		,Nil},;
						       	{"E1_MOEDA" 	,nMoedaCorT					,Nil},;
								{"E1_ORIGEM"	,"LOJA701"					,Nil},;
								{"E1_FLUXO"		,"S"						,Nil},;
							   	{"E1_VALOR"	  	,nResiduo					,Nil }}
			
			// Se a moeda for diferente de um adiciona o valor em moeda 1 para ter a taxa da inclusao do titulo
			If nMoedaCorT <> 1
				aAdd(aVetor,{"E1_VLCRUZ",Round(xMoeda(nResiduo, nMoedaCorT, 1, dDataBase),MsDecimais(1)) ,Nil })
			EndIf
		
			MSExecAuto({|x,y| Fina040(x,y)},aVetMsExAut, 3) //Inclusao
			
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			EndIf
		
		EndIf
	EndIf

EndIf
RestArea(aAreaTRB)
RestArea(aAreaSE1)
RestArea(aAreaSL1)
RestArea(aAreaSAE)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720RecD2ºAutor  ³Vendas CRM          º Data ³  23/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a variavel estatica aRecnoSD2, contendo dados dos   º±±
±±º          ³registros do SD2 relacionados a devolucao.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA720                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720RecD2()

Return aRecnoSD2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720VldMoºAutor  ³Microsiga           º Data ³  02/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao Utilizada para Retornar a Descricao do Motivo       º±±
±±º          ³ Caastrada na Tabela SX5                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Lj720VldMot(cMotivo, cDescMot)

Local lRet	:= .T.         

If Empty(cMotivo)
	cDescMot	:= Space(40)
Else
	DbSelectArea("SX5")
	DbSeek(xFilial("SX5")+"O1"+cMotivo)
	If Eof()
		HELP(" ",1,"ERROMOTIVO")
		cDescMot	:= Space(40)
		lRet := .F.
	Else                                                         
		cDescMot	:= Alltrim( X5Descri() )
	Endif
Endif
			
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7AtuInteºAutor  ³Vendas Clientes     º Data ³  02/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Leva os dados da devolucao para integracao                 º±±
±±º          ³ (Processo OffLine)  F1,D1, e E1							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Assistida                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj720AtInt()
	
	Local oProcessOff 	:= Nil							//Objeto do tipo LJCProcessoOffLine
	Local cChave 		:= ""							//Chave da tabela
	Local aAreaAtual	:= ""   						//Array que ira guardar os dados do alias atual
	Local aArea         := ""							//Array que ira guardar os dados do alias utilizado
	Local cAuxChave		:= ""							//Guarda a chave do SB2
		
	//Guarda a posicao do arquivo atual
	aAreaAtual := GetArea()
	
	//Estancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New("008")
	
	//Insere os dados do processo (registro da tabela) SF1---------------------------------------------
	DbSelectArea("SF1")

	cChave := xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_TIPO
	
	oProcessOff:Inserir("SF1", cChave, 1, "INSERT")
	//-------------------------------------------------------------------------------------------------

	//Insere os dados do processo (registro da tabela) SD1 e SB2---------------------------------------	
	aArea := SD1->(GetArea())

	DbSelectArea("SD1")
	
	DbSetOrder(1)
	
	If (SD1->(DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)))

		While !SD1->(EOF()) .AND. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

			cChave := SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEM
			oProcessOff:Inserir("SD1", cChave, 1, "INSERT")	

			If cAuxChave != SD1->D1_FILIAL + SD1->D1_COD + SD1->D1_LOCAL 
				cAuxChave := SD1->D1_FILIAL + SD1->D1_COD + SD1->D1_LOCAL 
				oProcessOff:Inserir("SB2", cAuxChave, 1, "UPDATE")						
			EndIf
			
			SD1->(DbSkip())
		End	

	EndIf
	
	RestArea(aArea)	
	//-------------------------------------------------------------------------------------------------
	
	//Insere os dados do processo (registro da tabela) SE1---------------------------------------------	
	aArea := SE1->(GetArea())
	
	DbSelectArea("SE1")
	
	DbSetOrder(1)
	
	If DbSeek(xFilial("SE1") + SF1->F1_PREFIXO + SF1->F1_DOC)  
	
		While !SE1->(EOF()) .AND. SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM  == xFilial("SE1") + SF1->F1_PREFIXO + SF1->F1_DOC

			If SE1->E1_TIPO == "NCC"
				cChave := xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
	         	oProcessOff:Inserir("SE1", cChave, 1, "INSERT")
				
				cChave := xFilial("SE5") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA
				oProcessOff:Inserir("SE5", cChave, 7, "INSERT")
			EndIf
				
			SE1->(DbSkip())

		End

	EndIf
	
	RestArea(aArea)
	//-------------------------------------------------------------------------------------------------------
	
	//Insere os dados do processo (registro da tabela) SE5---------------------------------------------------	
	aArea := SE5->(GetArea())
	
	DbSelectArea("SE5")
	
	DbSetOrder(7)
	
	If DbSeek(xFilial("SE5") + SF1->F1_PREFIXO + SF1->F1_DOC)  
	
		While !SE5->(EOF()) .AND. SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO  == xFilial("SE5") + SF1->F1_PREFIXO + SF1->F1_DOC

			If SE5->E5_RECPAG == "P"
				cChave := xFilial("SE5") + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA
				oProcessOff:Inserir("SE5", cChave, 7, "INSERT")
			EndIf
				
			SE5->(DbSkip())

		End

	EndIf
	
	RestArea(aArea)
	//-------------------------------------------------------------------------------------------------------
			
	//Processa os dados 
	oProcessOff:Processar()
	
	//Restaura a area atual
	RestArea(aAreaAtual)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720Sini   ºAutor  ³ Vendas Cliente     º Data ³  08/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alimentar a tabela "Sinistro x Seguradora" com os itens 	  º±±
±±º          ³devolvidos que contem Garantia estendida              	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 - Tipo documento			  						  º±±
±±º          ³ ExpC2 - Filial 											  º±±
±±º          ³ ExpN3 - Valor Total dos Sinistros						  º±±
±±º          ³ ExpN4 - Valor Unitario dos Itens 						  º±±
±±º          ³ ExpC5 - Codigo do Produto								  º±±
±±º          ³ ExpC6 - Numero da Nota Fiscal 							  º±±
±±º          ³ ExpC7 - Serie Nota Fiscal								  º±±
±±º          ³ ExpC8 - Numero do Item 									  º±±
±±º          ³ ExpC9 - Numero do PDV									  º±±
±±º          ³ ExpC10- Prefixo											  º±±
±±º          ³ ExpC11- Moeda											  º±±
±±º          ³ ExpC12- Documento Gerado									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - Garantia Estendida                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function Lj720Sini (	nTpProc,cLojaCli  ,nVlrTotal,nPreco	,;
					cCodigo,cDocumento,cSerie   ,cItem 	,;
					cPdv   ,cPrefixo  ,nMoeda   ,cNDoc	,;
					cPedido,cCodFil, nTotalGar  )


Local cNum  				:= ""               //Recebe numero do orçamento da tabela SL1
Local aAreaSL1	  			:= {}				// Guardar e restaurar Area 
Local aAreaSL2      		:= {}				// Guardar e restaurar Area 
Local aAreaSB1      		:= {}				// Guardar e restaurar Area 
Local cMItem				:= "0"				// Item a ser gravado na tabela MBJ
Local lGE					:= ExistFunc("LjUP104OK") .AND. LjUP104OK() 		// Valida a implementação da Garantia Estendida por faixa de Preço
Local lAchouPed				:= .F.				// Achou pedido
Local cPicture      		:= PesqPict("SLR","LR_VLRITEM")   		// Picture    
Local cTipGar				:= SuperGetMV("MV_LJTISE1",,"DP")      
Local cNatDevGe 			:= AllTrim(SuperGetMV("MV_NATGE",,"DEV/GE"))	// Natureza da devolucao da Garantia   
Local ljImpGf				:= SuperGetMv("MV_LJIMPGF",,.F.)

Default nTpProc				:= 0         	    // Define tipo do processo
Default cLojaCli			:= ""       		// Filial
Default nVlrTotal			:= 0            	// Valor total do cupom fiscal em que foi comprado o item
Default nPreco				:= 0             	// Valor Unitario
Default cCodigo				:= "" 	         	// Codigo do Produto
Default cDocumento			:= ""         		// Numero do cupom fiscal
Default cSerie				:= ""           	// Serie Cupom Fiscal
Default cItem				:= ""            	// Item tabela SL2
Default cPdv				:= ""            	// PDV
Default cPedido				:= ""               // 
Default cCodFil 			:= cFilAnt
Default nTotalGar			:= 0

If !lGE
	Return Nil
EndIf

aAreaSL2 := GetArea()
aAreaSL1 := GetArea()

If !Empty(cPedido)
	aSc5 := GetArea("SC5")
	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek(FWxFilial("SC5",cCodFil)+cPedido)
		DbSelectArea("SL1")
		DbSetOrder(1)
		lAchouPed := DbSeek(FWxFilial("SL1",cCodFil)+SC5->C5_ORCRES)   

	EndIf
	RestArea(aSc5)
Else
	DbSelectArea("SL1")
	DbSetOrder(2) //L1_FILIAL+L1_PDV+L1_DOC      
	lAchouPed := DbSeek(FWxFilial("SL1",cCodFil) + cSerie + cDocumento + cPdv )
EndIf
If lAchouPed	
	cNum  := SL1->L1_NUM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega Tabela MBJ com informacoes para para gerar titulo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL2")
	DbSetOrder(1) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	If DbSeek(FWxFilial("SL2",cCodFil) + cNum + cItem ) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o item tem garantia estendida e se a mesma esta no periodo de validade ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SL2->L2_GARANT) .AND. !Lj720VldGA() .AND. ljImpGf    
			DbSelectArea("MBJ") // MBJ_FILIAL+MBJ_DOC+MBJ_PROD+DTOS (MBJ_DATA)  
			DbSetOrder(4)  
			If DbSeek(xFilial("MBJ",cCodFil)+ cDocumento + SL2->L2_PRODUTO + DTOS(dDataBase))
                While MBJ->MBJ_DOC == cDocumento
	                cMItem := MBJ->MBJ_ITEM                                                                
   			        MBJ->(dbSkip())                            
                End        
			EndIf                     
			MBJ->(dbCloseArea())
			cMItem := SomaIt( cMItem )
                              

			RecLock("MBJ",.T.)

			REPLACE MBJ->MBJ_ITEM  	WITH cMItem
			REPLACE MBJ->MBJ_FILIAL	WITH xFilial("MBJ")
			REPLACE MBJ->MBJ_DOC	WITH cDocumento
			REPLACE MBJ->MBJ_SERIE	WITH cSerie
			REPLACE MBJ->MBJ_PROD	WITH SL2->L2_PRODUTO
			REPLACE MBJ->MBJ_DATA	WITH dDataBase
			REPLACE MBJ->MBJ_TIPO	WITH Str(nTpProc,0,0)
			REPLACE MBJ->MBJ_VALUNI	WITH nPreco
			REPLACE MBJ->MBJ_VALTOT	WITH nVlrTotal
			REPLACE MBJ->MBJ_GARANT	WITH SL2->L2_GARANT  
			REPLACE MBJ->MBJ_NUMTIT	WITH SL1->L1_DOC
			REPLACE MBJ->MBJ_SERTIT	WITH cPrefixo
			REPLACE MBJ->MBJ_NSERIE	WITH SL2->L2_NSERIE

			aAreaSB1 := GetArea()

			DbSelectArea("SB1")
			DbSetOrder(1)                  						//Filial + Produto
			If DbSeek(xFilial("SB1",cCodFil) + SL2->L2_GARANT)
				REPLACE MBJ->MBJ_ADMIN	WITH SB1->B1_ADMIN	
			EndIf

			MsUnlock()                                                                    
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chama a funcao que cadastra na SE1 Geração de titulo								                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SL1")
				DbSetOrder(8)           						//Filial + Numero do PDV + Nota fiscal 
				If DbSeek(FWxFilial("SL1",cCodFil) + cPdv +cDocumento)
					
					If	CriaTit(	SL1->L1_DOC	, SL1->L1_SERIE	,SL1->L1_OPERADO	,SL1->L1_EMISNF,;
								nTotalGar 	, SB1->B1_ADMIN  	,SL1->L1_LOJA	,cPrefixo ,;
								SL1->L1_EMISNF,  cTipGar, cNatDevGE ,nTotalGar  ,"Lj720Sini")        
							 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Cria Msg com os dados do Documento criado³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistFunc("LA590Msg")
							DbSelectArea("SAE")
							DbSetOrder(1) 														 //Filial + Administradora 
							If DbSeek(xFilial("SAE",cCodFil) + Alltrim(SB1->B1_ADMIN))
								LA590Msg(STR0001,;                            					 //Troca e Devolução de Mercadorias
										 STR0124+AllTrim(SL2->L2_DESCRI)+STR0125+Chr(10)+Chr(13);
										 + STR0126 + SAE->AE_DESC + Chr(10) + Chr(13)+ STR0127	;// "Foi gerado um documento de contas a receber para a Administradora Financeira: ""No Valor de: "
										 + TransForm(nTotalGar,cPicture) + Chr(10) + Chr(13)	;	 
										 + STR0128 + cDocumento +" - "+cPrefixo+ Chr(10) + Chr(13))
							EndIf	
						EndIf 
					EndIf
								
				EndIf
			RestArea(aAreaSB1)
		EndIf
	EndIf
EndIf


RestArea(aAreaSL1)
RestArea(aAreaSL2)

Return Nil

/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720VldGAºAutor  ³  Vendas Clientes   º Data ³  01/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o produto devolvido com garantia estendida esta  º±± 
±±º          ³ no intervalo valido para realizar o sinistro               º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpA1 - Array com produtos a fazer solicitacao de compras  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet - Retorna se a garantia esta valida sim ou nao        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 		

Static Function Lj720VldGA(cOrc,cCodFil)

Local lRet 			:= .F.					// Retorno da funcao		
Local nVldProd    	:= 0       				// Dias de garantia do produto  
Local nVldPGar    	:= 0       				// Dias de garantia do produto garantia estendida  
 
LOCAL dDataVenda	:= CtoD("  /  /  ")    	// Data da Venda
Local aAreaSL2      := {}					// Guardar e restaurar Area 
Local cMvLjTGar	    := SuperGetMV("MV_LJTPGAR",,"GE")     			// Garantia Estendida

DEFAULT cOrc		:= ""					// Orçamento
DEFAULT cCodFil 	:= cFilAnt

If Empty(cOrc)
	cOrc := SL1->L1_NUM    //Busca o Orçamento da Reserva para imprimir // Guardar e restaurar Area 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o valor de validade do produto³   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SL2->(ColumnPos("L2_VLGAPRO")) > 0 
	
	aAreaSL2 	:= GetArea()			// Guarda area    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura o item de garantia para verificar sua data		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL2")
	DbSetOrder(1) //L2_FILIAL+L2_NUM
	DbGoTop()
	If DbSeek(FWxFilial("SL2",cCodFil) + cOrc) 	
	
		While !Eof()  .AND. cOrc==SL2->L2_NUM
			// Busca tipo de produto para garantia
			dbSelectArea("SB1")
			SB1->(MsSeek( xFilial("SB1",cCodFil) + SL2->L2_PRODUTO ))
		
	    	
			If Alltrim(cMvLjTGar) == Alltrim(SB1->B1_TIPO)// eh um produto garantia 
				// recebe valor da validade do produto garantia 
				nVldPGar := SL2->L2_VLGAPRO
				Exit
			Else
				// no caso de Garantia , sempre vaipassar aqui primeiro
				// pois a sequancia sempre eh um produto e depois sua garantia.
				nVldProd 	:= SL2->L2_VLGAPRO		// Recebe valor da validade do produto	
				dDataVenda 	:= SL2->L2_EMISSAO 		// Recebe data da venda
			EndIf
			SL2->(DbSkip())  
		End
	Endif   
                     
	//Restaura Area
	RestArea(aAreaSL2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a data atual for maior que a data limite da garantia de fabrica      ³
	//³e a data atual for menor ou igual a data limite da garantia estendida   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( (dDataBase > (dDataVenda+nVldProd)) .OR. nVldProd == 0)  .AND. (dDataBase <= (dDataVenda+nVldProd+nVldPGar))  	
		lRet := .T.  // Retorna True pois este produto esta no periodo de garantia estendida
	Endif
		
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaTit    ³ Autor ³ Vendas Cliente       ³ Data ³ 03/01/11 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Titulo de contas a receber										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= CriaTit()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Documento														  ³±±
±±³          ³ExpC2 - Serie do documento											  ³±±
±±³          ³ExpC3 - Operador														  ³±±
±±³          ³ExpD4 - Data															  ³±±
±±³          ³ExpN5 - Valor do Titulo      											  ³±±
±±³		     ³ExpC6 - Cliente Administradora										  ³±±
±±³          ³ExpC7 - Loja	 														  ³±±
±±³          ³ExpC8 - Prefixo 														  ³±±
±±³          ³ExpD9 - Data de emissão		           								  ³±±
±±³          ³ExpD10 - Produto				           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpL1 =.T.            									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA720													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     


Static Function CriaTit(	cNumDoc		,cL1Serie	,cL1Oper	,dDatValid	,;
							nValorTit 	,cL1Cliente	,cL1Loja	,cSerEst	,;
							dL1EmisNf	, cTipGar   ,cNaturez   ,nBaseCom ,cRotina)

Local cParcela 		:= SuperGetMV("MV_1DUP")				// Parcela a gerar
Local aVetor        := {}                   				// Array com dados para gerar.
Local lRet 			:= .T.                  				// Retorno
Local lContinua 	:= .T.
Local lUsaSPB		:= SpbInUse() .AND. (SE1->(ColumnPos("E1_MODSPB")) > 0)	// Controle para uso do SPB
Local aDadosBanc	:= {} 									//array com dados de ag e conta CADASTRADOS NA SA6
Local cMvLjTGar		:= SuperGetMV("MV_LJTPGAR",,"GE")
Local nTamPref 		:= SE1->(TamSx3("E1_PREFIXO")[1]) //Prefixo
Local nTamNum		:= SE1->(TamSx3("E1_NUM")[1]) //Numero
Local nTamPar		:= SE1->(TamSx3("E1_PARCELA")[1]) //Parcela
Local nTamTipo		:= SE1->(TamSx3("E1_TIPO")[1]) //TIPO


Private lMsErroAuto := .F.									// Tratamento de erro de rotina automatica
Private lMsHelpAuto := .T.									// Tratamento de erro de rotina automatica

Default cNumDoc		:= ""
Default cL1Serie	:= ""
Default cL1Oper		:= ""
Default dDatValid	:= cTod("  /  /  ")
Default nValorTit	:= 0
Default cL1Cliente	:= ""
Default cL1Loja		:= ""
Default cSerEst		:= ""
Default dL1EmisNf	:= cTod("  /  /  ")
Default cRotina		:= ""     
Default cNaturez	:= ""
Default nBaseCom	:= 0 
Default cTipGar		:= ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona na SX5 para verificar se existe o Tipo de Titulo "SE1" informado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SX5")
If !DbSeek(xFilial("SX5") + "05" + cTipGar)
	MsgStop(STR0130)             		//Tipo nao encotrado. Favor cadastrar na tabela 05 o conteudo do parametro MV_LJTISE1.
	lContinua := .F.
EndIf

If lContinua

	DbSelectArea("SE1")
	DbSetOrder(1)
	While SE1->(DbSeek(xFilial("SE1") + PadR( cSerEst, nTamPref) + PadR( cNumDoc, nTamNum) + PadR( cParcela, nTamPar) + PadR( cTipGar, nTamTipo)))
		cParcela := CHR(ASC(cParcela)+1)
	End
	
	aAdd(aVetor,{"E1_PREFIXO"	,cSerEst											,Nil}) 	// L1_SERIE ou L1_SERPED
	aAdd(aVetor,{"E1_NUM"	  	,cNumDoc 											,Nil}) 	// L1_DOC ou L1_DOCPED
	aAdd(aVetor,{"E1_PARCELA" 	,cParcela											,Nil})
	aAdd(aVetor,{"E1_NATUREZ" 	,cNaturez	                                        ,Nil}) 	// OK
	aAdd(aVetor,{"E1_TIPO" 		,cTipGar											,Nil}) 	// OK
	aAdd(aVetor,{"E1_EMISSAO"	,dDatabase											,Nil}) 	// DATA DA EMISSAO DDATABASE
	aAdd(aVetor,{"E1_VALOR"		,nValorTit											,Nil}) 	//  VALOR QUE VC QUER GERAR
	aAdd(aVetor,{"E1_VENCTO"	,dDatabase											,Nil}) 	// L1_EMISNF
	aAdd(aVetor,{"E1_VENCREA"	,dDatabase					   						,Nil}) 	// L1_EMISNF IGUAL COM DATAVALIDA()
	aAdd(aVetor,{"E1_VENCORI"	,dDatabase											,Nil}) 	// L1_EMISNF
	aAdd(aVetor,{"E1_SALDO"		,nValorTit											,Nil}) 	// VALOR QUE VC QUER GERAR
	aAdd(aVetor,{"E1_VLCRUZ"	,xMoeda(nValorTit,1,1,nValorTit)	            	,Nil}) 	// VALOR QUE VC QUER GERAR COM O TRATAMENTO DO XMOEDA
	aAdd(aVetor,{"E1_CLIENTE"	,PADR(cL1Cliente,tamsX3("A1_COD")[1]) 				,Nil}) 	// B1_ADMIN
	aAdd(aVetor,{"E1_LOJA"		,Alltrim(cL1Loja)									,Nil}) 	// L1_LOJA
	aAdd(aVetor,{"E1_MOEDA"		,1													,Nil }) // MESMA
	aAdd(aVetor,{"E1_STATUS"	,IIf(nValorTit > 0.01,"A","B")						,Nil }) // OK
	aAdd(aVetor,{"E1_SITUACA"	,IIf(ExistFunc("LjCartTit"),;   
									LjCartTit(cNumDoc,cTipGar,cL1Oper),"0")  		,Nil }) // MESMA						
	aAdd(aVetor,{"E1_ORIGEM"	,cRotina									 		,Nil }) // TROCA GARANTIA ESTENDIDA
	aAdd(aVetor,{"E1_MULTNAT"	,"2"												,Nil }) // OK
	aAdd(aVetor,{"E1_FLUXO"		,"N"												,Nil }) // OK
	aAdd(aVetor,{"E1_BASCOM1"	,xMoeda(nBaseCom,1,1,nBaseCom)				 		,Nil }) // VALOR QUE VC QUER GERAR COM O TRATAMENTO DO XMOEDA     
	If lUsaSPB
		aAdd(aVetor,{"E1_MODSPB"   		,1				   						,Nil })  
	EndIf   
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui via rotina automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMsErroAuto := .F.
	MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)  
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Apresenta mensagem de erro caso a rotina automatica nao seja executada.³
	³Desfaz a transacao                                                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If  lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lRet 	   := .F.
		aLogRotAut := GetAutoGrLog()
	EndIf
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2)) 						//E1+FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(DbSeek(xFilial("SE1") + cL1Cliente + cL1Loja + PadR( cSerEst, nTamPref) +;
			  PadR( cNumDoc, nTamNum)		 + PadR( cParcela, nTamPar)   + PadR( cTipGar, nTamTipo)))     .AND.  lRet
		
		RecLock("SE1",.F.)
		REPLACE SE1->E1_HIST 	With xFilial("SE1")+ ;
		PadR( cSerEst, nTamPref) 	+ ;
		PadR( cNumDoc, nTamNum) 	+ ;
		PadR( cParcela, nTamPar) 	+ ;
		cMvLjTGar

		RecLock('SE1',.F.)
		aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cL1Oper, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
		SE1->E1_PORTADO 	:= cL1Oper
		SE1->E1_AGEDEP 		:= aDadosBanc[1]
		SE1->(MsUnlock())
		MsUnLock()
		
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³LJ720aNCC  ³ Autor ³ Vendas Cliente       ³ Data ³ 24/07/2012 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega um array com as NCCs que foram geradas para a devolucao	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= LjLoadNCC()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Cliente													³±±
±±³          ³ExpC2 - Loja														³±±
±±³          ³ExpC3 - Prefixo da Nota de Entrada								³±±
±±³          ³ExpC4 - Numero do Documento										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 = {}            									        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lj720Concluir											        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJ720aNCC(cCliente, cLoja, cPrefixoEnt, cTitEnt)

Local aRet := {}		// array com os R_E_C_N_O_ das NCCs geradas na devolucao

DbSelectArea("SE1")
SE1->( DbSetOrder(2) )	//E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
                                     
If SE1->( DbSeek(xFilial("SE1") + cCliente + cLoja + cPrefixoEnt + cTitEnt) )

	While SE1->( !Eof() ) .AND. xFilial("SE1")		== SE1->E1_FILIAL 	.AND. ;
								SE1->E1_CLIENTE		== cCliente 		.AND. ;
								SE1->E1_LOJA		== cLoja 			.AND. ;
								SE1->E1_PREFIXO		== cPrefixoEnt 		.AND. ;
								SE1->E1_NUM			== cTitEnt
									
	   	If !( SE1->E1_SITUACA $ "27" .OR. SE1->E1_SALDO == 0 )
		
     		If ( SE1->E1_TIPO $ MV_CRNEG )
     			Aadd( aRet, SE1->(Recno()) )
     		Endif	

		Endif
	    
		SE1->( DbSkip() )
	End

EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    EstOPOtc 	 ³ Autor ³ Totvs Fábrica        ³ Data ³ 15/01/2013 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a Inclusão/Exxclusão de OPs e empenhos para o template 	³±±
±±³Otica                                                                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= EstOPOtc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Produto													³±±
±±³          ³ExpC2 - Documento													³±±
±±³          ³ExpC3 - Serie                     								³±±
±±³          ³ExpC4 - Item na tabela SL2 										³±±
±±³          ³ExpC5 - Código do Cliente  										³±±
±±³          ³ExpC6 - Código da Loja       										³±±
±±³          ³ExpN7 - Opção de operação, sendo :								³±±
³±±												3 - Incluir						³±±
³±±												5 - Excluir						³±±
³±±												6 - Valida Exclusão				³±±																				
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 = Nil           									        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lj720Concluir,Lj720DevSD2,LjLogDevol						        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function EstOPOtc(cProd,cDoc,cSerie,cItemL2,cCliente,cLoja,nOpc,cCodFil) 
Local cQuery
Local aRetDados	:= {}
Local cOP
Local cFilSL2 	:= ""
Local cFilSD4 	:= ""

Default cCodFil := cFilAnt

cFilSL2 := FWxFilial("SL2",cCodFil)
cFilSD4 := FWxFilial("SD4",cCodFil)

If nOpc == 5 .Or. nOpc == 6
	cQuery := " Select L2_PRODUTO,L2_LOCAL,D4_OP,L2_QUANT,L2_LOTECTL,L2_DTVALID,L2_LOCALIZ,D4_TRT From "+RetSqlName("SL2")+" SL2 "
	cQuery += " Inner Join "+RetSqlName("SL1")+" SL1 ON SL1.L1_NUM = SL2.L2_NUM "
	If Upper(TcGetDb()) $ "MSSQL / SYBASE" //Validacao caso utilize banco de dados DB2 
		cQuery += " Inner Join "+RetSqlName("SC2")+" SC2 ON SubString(SC2.C2_OSLOJA,1,6) = SubString(SL1.L1_NROPCLI,1,6) "
	Else
		cQuery += " Inner Join "+RetSqlName("SC2")+" SC2 ON SubStr(SC2.C2_OSLOJA,1,6) = SubStr(SL1.L1_NROPCLI,1,6) "	
	Endif
	If Upper(TcGetDb()) $ "MSSQL / SYBASE" //Validacao caso utilize banco de dados DB2 
		cQuery += " Inner Join "+RetSqlName("SD4")+" SD4 ON SD4.D4_OP = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AND SD4.D4_COD = SL2.L2_PRODUTO "
	Else
		cQuery += " Inner Join SD4T10 SD4 ON SD4.D4_OP = SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN AND SD4.D4_COD = SL2.L2_PRODUTO "
	Endif
	cQuery += " where  "
	cQuery += " L2_FILIAL ='"+cFilSL2+"'  "
	cQuery += " AND L2_DOC ='"+cDoc+"'  "
	cQuery += " AND L2_SERIE = '"+cSerie+"'  "
	cQuery += " AND SL2.D_E_L_E_T_ =''  "
	cQuery += " AND SD4.D_E_L_E_T_ =''  "
	cQuery += " AND L2_PRODUTO ='"+cProd+"'  "
	cQuery += " AND L2_ITEM ='"+cItemL2+"' "
	cQuery += " AND L2_ORCRES ='' "
	cQuery += " AND SC2.C2_OSLOJA <>'' "
	If Upper(TcGetDb()) $ "MSSQL / SYBASE" //Validacao caso utilize banco de dados DB2 
 		cQuery += " AND L2_CONJUNT = Cast(SUBSTRING(SC2.C2_OSLOJA,7,2)as INT) "
	Else
		cQuery += " AND L2_CONJUNT = Cast(SUBSTR(SC2.C2_OSLOJA,7,2)as INT) "
	EndIf 
	cQuery += " And L1_CLIENTE ='"+cCliente+"' "
	cQuery += " AND L1_LOJA ='"+cLoja+"' "
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),"EstSD4",.T.,.T.)
	
	cOP	:= EstSD4->D4_OP
Else
	cQuery := " Select L2_PRODUTO,L2_LOCAL,C2_NUM,C2_ITEM,C2_SEQUEN,L2_QUANT,L2_LOTECTL,L2_DTVALID,L2_LOCALIZ From "+RetSqlName("SL2")+" SL2 "
	cQuery += " Inner Join "+RetSqlName("SL1")+" SL1 ON SL1.L1_NUM = SL2.L2_NUM "
	If Upper(TcGetDb()) $ "MSSQL / SYBASE" //Validacao caso utilize banco de dados DB2 
		cQuery += " Inner Join "+RetSqlName("SC2")+" SC2 ON SubString(SC2.C2_OSLOJA,1,6) = SubString(SL1.L1_NROPCLI,1,6) "
	Else
		cQuery += " Inner Join "+RetSqlName("SC2")+" SC2 ON SubStr(SC2.C2_OSLOJA,1,6) = SubStr(SL1.L1_NROPCLI,1,6) "	
	Endif
	cQuery += " where  "
	cQuery += " L2_FILIAL ='"+xFilial("SL2")+"'  "
	cQuery += " AND L2_DOC ='"+cDoc+"'  "
	cQuery += " AND L2_SERIE = '"+cSerie+"'  "
	cQuery += " AND SL2.D_E_L_E_T_ =''  "
	cQuery += " AND L2_PRODUTO ='"+cProd+"'  "
	cQuery += " AND L2_ITEM ='"+cItemL2+"' "
	cQuery += " AND L2_ORCRES <>'' "
	If Upper(TcGetDb()) $ "MSSQL / SYBASE" //Validacao caso utilize banco de dados DB2 
 		cQuery += " AND L2_CONJUNT = Cast(SUBSTRING(SC2.C2_OSLOJA,7,2)as INT) "
	Else
		cQuery += " AND L2_CONJUNT = Cast(SUBSTR(SC2.C2_OSLOJA,7,2)as INT) "
	EndIf 
	cQuery += " And L1_CLIENTE ='"+cCliente+"' "
	cQuery += " AND L1_LOJA ='"+cLoja+"' "
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),"EstSC2",.T.,.T.)
	cOP	:= EstSC2->C2_NUM+EstSC2->C2_ITEM+EstSC2->C2_SEQUEN
Endif
If nOpc == 6
	If SD3->(DbSeek(xFilial("SD3")+EstSD4->D4_OP))
		Aadd(aRetDados,{.T.,EstSD4->D4_OP})	
		EstSD4 -> (DbCloseArea())
		Return aRetDados
	Else
		Aadd(aRetDados,{.F.,EstSD4->D4_OP})
		EstSD4 -> (DbCloseArea())
		Return	aRetDados
	Endif	
ElseIf nOpc == 5
	SD4->(DbSetOrder(1))
	If EstSD4->(!EOF()) .And. SD4->(DbSeek(cFilSD4+EstSD4->L2_PRODUTO+EstSD4->D4_OP+EstSD4->D4_TRT+EstSD4->L2_LOTECTL))
		While EstSD4->(!EOF())
			EmpOtc(EstSD4->L2_PRODUTO,EstSD4->L2_LOCAL,EstSD4->D4_OP,EstSD4->L2_QUANT,EstSD4->L2_LOTECTL,EstSD4->L2_DTVALID,EstSD4->L2_LOCALIZ,nOpc) 
			EstSD4->(DbSkip())
		Enddo
		SD4->(DbSetOrder(2))
        If !SD4->(DbSeek(cFilSD4+cOP))
			GerOPOtc(,,,5)
		Endif
		EstSD4 -> (DbCloseArea())
	Else
		EstSD4 -> (DbCloseArea())
	Endif
Elseif nOpc == 3
	If EstSC2->(!EOF())
		While EstSC2->(!EOF())
			EmpOtc(EstSC2->L2_PRODUTO,EstSC2->L2_LOCAL,cOP,EstSC2->L2_QUANT,EstSC2->L2_LOTECTL,EstSC2->L2_DTVALID,EstSC2->L2_LOCALIZ,nOpc) 
			EstSC2->(DbSkip())
		Enddo
		EstSC2 -> (DbCloseArea())
	Else
		EstSC2 -> (DbCloseArea())
	Endif
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    EmpOtc 	 ³ Autor ³ Totvs Fábrica        ³ Data ³ 15/01/2013 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla o empenho dos materiais Quando utilizado o template   	³±±
±±³Otica                                                                      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= EmpOtc() 	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Produto													³±±
±±³          ³ExpC2 - Local     												³±±
±±³          ³ExpC3 - Ordem de Produção         								³±±
±±³          ³ExpN4 - Quantidade         										³±±
±±³          ³ExpC5 - Lote               										³±±
±±³          ³ExpC6 - Data de Validade											³±±
±±³          ³ExpC7 - Endereço             										³±±
±±³          ³ExpN8 - Opção de operação, sendo :								³±±
³±±												3 - Incluir						³±±
³±±												5 - Excluir						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 = Nil           									        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ EstOPOtc															³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function EmpOtc(cProduto,cLocal,cOP,nQtde,cLote,dValid,cLocaliz,nOpc) 
Local aMata380 := {}
Local aEmp380  := {}
Local nModuloOld

Private lMSErroAuto := .f.  

aadd(aMata380,{"D4_COD"    ,PADR(cProduto,tamsX3("B1_COD")[1])     			,NIL})
aadd(aMata380,{"D4_LOCAL"  ,cLocal       			,NIL})
aadd(aMata380,{"D4_OP"     ,cOP         			,NIL})
aadd(aMata380,{"D4_DATA"   ,dDataBase 				,NIL})
aadd(aMata380,{"D4_QTDEORI",nQtde					,NIL}) 
aadd(aMata380,{"D4_QUANT"  ,nQtde	 				,NIL}) 
aadd(aMata380,{"D4_LOTECTL",If(!Empty(cLote),cLote,CriaVar("D4_LOTECTL"))		,NIL})
aadd(aMata380,{"D4_NUMLOTE",CriaVar("D4_NUMLOTE")	,NIL})                       
aadd(aMata380,{"D4_DTVALID",If(!Empty(dValid),dValid,CTOD("//"))				,NIL})
aadd(aMata380,{"D4_QTSEGUM",0						,NIL})
aadd(aMata380,{"D4_POTENCI",CriaVar("D4_POTENCI")	,NIL})

If !Empty(cLocaliz)
	aadd(aEmp380,{nQtde,cLocaliz,CriaVar("DC_NUMSERI"),0,.F.})
Endif

If nOpc <> 4
	nModuloOld  := nModulo
	nModulo     := 4
	lMSErroAuto := .F.
	lMSHelpAuto := .F.
	msExecAuto({|x,y,z|MATA380(x,y,z)},aMata380,nOpc,aEmp380)
	nModulo     := nModuloOld
	lMsHelpAuto:=.F.
	If lMSErroAuto
		Conout(STR0136) //"Ocorreu algum erro no Processo."
		MostraErro()
		lErroReq := .t.
		DisarmTransaction()
		Break
	Else
		Conout(STR0135)//Processo realizado com Sucesso.
	EndIf
Endif

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    StatusDoc 	 ³ Autor ³ Totvs Fábrica        ³ Data ³ 15/01/2013 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica o Status do Documento de Entrada Quando utilizado o   	³±±
±±³Template Otica                                                             	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:= StatusDoc() 	                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Documento Original										³±±
±±³          ³ExpC2 - Serie Original											³±±
±±³          ³ExpC3 - Cliente                   								³±±
±±³          ³ExpC4 - Loja               										³±±
±±³          ³ExpC5 - Código Produto     										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 = .T. ou .F.    									        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LjLogDevol														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function StatusDoc(cDocOri,cSerieOri,cCliente,cLoja,cCod)
Local lRet	:= .F.
Local cQuery

cQuery	:= " Select * From "+RetSqlName ("SD1")+"  "
cQuery	+= " where  "
cQuery	+= " D1_NFORI ='"+cDocOri+"'  "
cQuery	+= " AND D1_SERIORI ='"+cSerieOri+"' "
cQuery	+= " AND D1_FORNECE ='"+cCliente+"' "
cQuery	+= " AND D1_LOJA ='"+cLoja+"' "
cQuery	+= " AND D_E_L_E_T_ = '' "
DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),"STSDOC",.T.,.T.) 

If STSDOC -> (EOF())
	lRet	:= .T.
Endif
STSDOC -> (DbCloseArea())
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | LJESPECOK ³ Autor ³ Vendas/CRM	        ³ Data ³ 18/04/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a especie eh valida								 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjEspecOk(cTpEspecie)										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - especie a ser validada								 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpL1 = valida se a especie eh validada						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA720														 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjEspecOk(cTpEspecie)

Local aArea := GetArea()		//armazena a area
Local lRet	:= .T.				//valida se a especie eh valida

Default cTpEspecie	:= ""

If !Empty(cTpEspecie)
	DbSelectArea("SX5")
	If !SX5->( DbSeek(xFilial("SX5") + "42" + cTpEspecie) )
		LjGrvLog( "TROCA_DEVOLUCAO", "Especie não existe na tabela 42 da SX5 - cTpEspecie", cTpEspecie)
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | LJESPECIE ³ Autor ³ Vendas/CRM	        ³ Data ³ 18/04/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a especie cadastrada para a serie, baseada no 		 ³±±
±±³			 | parametro MV_ESPECIE.										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjEspecie(cSerieDoc)											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - serie utilizada na devolucao							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ ExpC1 = especie cadastrada para a serie. Se a especie nao	 ³±±
±±³			 | existir, retornamos 'NF'					     				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Lj720DevSD2 / Lj720DevTRB / LjSerieEOK						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjEspecie(cSerieDoc)

Local cMvEspecie	:= SuperGetMV("MV_ESPECIE",,"")		//pares de SERIE=ESPECIE
LOcal cSerieEspe	:= "" 								//par de SERIE=ESPECIE 
Local cSerie		:= ""								//serie do par
Local cEspecie		:= ""								//retorno do funcao - especie cadastrada para a serie
Local nI			:= 0								//contador
Local nPosSign		:= 0								//posicao do sinal '='

Default cSerieDoc	:= ""

cSerieDoc := AllTrim(cSerieDoc)

If Empty(cMvEspecie) .OR. cPaisLoc <> "BRA"
	//inializa F1_ESPECIE com o conteudo do inicializador padrao
	cEspecie  := CriaVar("F1_ESPECIE",.T.)
Else
	//substituimos ';' por quebra de linha
	cMvEspecie := StrTran( cMvEspecie, ";", Chr(13) + Chr(10) )

	//verificamos cada par 'serie = especie'
	For nI := 1 TO MLCount( cMvEspecie )

		//retorna o conteudo de cada linha		
		cSerieEspe := AllTrim( StrTran(MemoLine(cMvEspecie,, nI), CHR(13), CHR(10)) )

		//retorna a posicao do '='
		nPosSign := At( "=", cSerieEspe )

		If nPosSign > 0
			//retorna a serie do parametro (antes '=')
			cSerie := SubStr( cSerieEspe, 1, (nPosSign-1) )

			//se a serie do documento for igual a serie do parametro
			If cSerieDoc  == cSerie
				//retorna a especie (apos '=')
				cEspecie := SubStr( cSerieEspe, (nPosSign+1) )
				cEspecie := PadR( cEspecie, TamSX3("X5_CHAVE")[1] )
				
				//verifica se a especie eh valida
				If LjEspecOk(cEspecie)
					Exit
				Else
					cEspecie := ""
				EndIf
			EndIf
		EndIf
	Next
EndIf

If Empty(cEspecie)
   cEspecie := PadR( "NF", TamSX3("F1_ESPECIE")[1] )
EndIf

Return cEspecie


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |LJSERIEOK	 ³ Autor ³ Vendas/CRM	        ³ Data ³ 18/04/2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o campo Serie esta preenchido. Tambem retorna a	 ³±±
±±³			 |especie cadastrada para a serie (MV_ESPECIE).					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjSerieoK(cSerieDoc, @cTpEspecie)							 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - serie utilizada na devolucao							 ³±±
±±³          ³ExpC2 - especie cadastrada para a serie (MV_ESPECIE)			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpL1 = indica se a serie eh valida						     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA720														 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjSerieOk(cSerieDoc, cTpEspecie)

Local lRet			:= .T.	//valida se a serie eh valida

Default cSerieDoc	:= ""
Default cTpEspecie	:= ""

If !Empty(cSerieDoc)
	//retorna a especie cadastrada para a serie
	cTpEspecie := LjEspecie(cSerieDoc)
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720SeekCl ºAutor  ³ Vendas Cliente     º Data ³14/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o cliente existe.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo da Filial                                    º±±
±±º          ³ExpC2 - Codigo do Cliente                                   º±±
±±º          ³ExpC3 - Loja do Cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720SeekCl(cFilCli, cCodCli, cCodLoja)
Local lRet := .F.

cFilCli := FWxFilial("SA1",cFilCli)

DbSelectArea("SA1")
If MsSeek(cFilCli+cCodCli+cCodLoja)
	lRet := .T.
Else
	HELP(" ",1,"REGNOIS")
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720NomFi ºAutor  ³ Vendas Cliente     º Data ³14/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o nome da filial.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo da Filial                                    º±±
±±º          ³ExpC2 - Variavel passada por referencia para atualizar a    º±±
±±º          ³ 		  descricao da filial.                                º±±
±±º          ³ExpL3 - Indica se deve validar o codigo da Filial informada.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720NomFi( cCodFil, cDescrFil, lVldCodFil )
Local lRet 		:= .T.
Local cRetNomFil:= ""
Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())

cRetNomFil := Posicione("SM0",1,cEmpAnt+cCodFil,"M0_FILIAL")

If lVldCodFil
	If Empty(cRetNomFil) .And. SM0->(EOF())
		MsgAlert(STR0200)	//"O código da filial informada não é válido."
		lRet := .F.
	EndIf
EndIf

If lRet
	cDescrFil := cRetNomFil
	If cCodFil <> cFilAnt		//Verifico se a filial selecionada é diferente da filial que entrou no Protheus.
		DbSelectArea("SX3")
		DbSetOrder(2)					//X3_CAMPO
		IF SX3->(DbSeek("D1_FILORI"))
			If !X3Uso(SX3->X3_USADO)	//Verifico se o campo é usado. .F. se não for.	
				MsgAlert(STR0202+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0203)	//"O campo da filial de origem da nota (D1_FILORI) não está marcado como usado."###"Favor entrar em contato com o Suporte Protheus." 
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSM0)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720ChgPrc ºAutor  ³ Vendas Cliente     º Data ³12/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao executada na mudanca do Radio Button de Processo.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L720ChgPrc( cAliasTRB  	, aRecSD2  	, oGetdTRC  , lFormul 	,;
							lCompCR   	, nRecnoTRB	, nTpProc	, nNfOrig 	,;
							nPanel )

Lj720AltProc( cAliasTRB, @aRecSD2 ,oGetdTRC, @lFormul, @lCompCR, @nRecnoTRB, nTpProc )

Lj720CfgDb( nNfOrig, oGetdTRC, nPanel, aRecSd2 )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720ChgOri ºAutor  ³ Vendas Cliente     º Data ³12/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Habilita / Desabilita a edicao de campos e objetos quando  º±±
±±º          ³ alterado o Radio Button "Origem".                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L720ChgOri( nNfOrig		, oDataIni	, oDataFim		, dDataIni	,;
							dDataFim	, oCodFil	, cCodFil		, oDescrFil	,;
							cDescrFil 	, oFiltroPor, oBotaoPesq	, cAliasTRB ,;
							aRecSD2  	, oGetdTRC  , lFormul		, lCompCR   ,;
							nRecnoTRB	, nTpProc	, nPanel		, nFiltroPor,;
							oSayClient	, oCodCli	, oLojaCli		, oNomeCli	,;
							oSayDtIni 	, oSayDtFim	, oSayNumNF		, oCodNumNF	,;
							oSaySerie	, oSerieNF  , oLblValTroca  , oValTroca ,;
							oSayFil		)


If nNfOrig==2
	nFiltroPor:=1 //1=Filtro por Cliente e Data
	oFiltroPor:Refresh()
	
	L720ChgFil(	nFiltroPor	, @oSayClient	, @oCodCli		, @oLojaCli		,;
				@oNomeCli	, @oSayDtIni	, @oDataIni		, @oSayDtFim	,;
    			@oDataFim	, @oSayNumNF	, @oCodNumNF	, @oSaySerie	,;
        		@oSerieNF 	, cAliasTRB		, @aRecSD2		, oGetdTRC		,;
        		@lFormul	, @lCompCR		, @nRecnoTRB	, nTpProc 		,;
        		nNfOrig		, nPanel		, oLblValTroca  , oValTroca		,;
				@oSayFil 	, @oCodFil 		, @oDescrFil)
EndIf

If nNfOrig == 2 //Sem NF de entrada
	oFiltroPor:Disable()
	oFiltroPor:Refresh()
	dDataIni:= Ctod("  /  /  ")  
	dDataFim:= Ctod("  /  /  ")
	oDataIni:Refresh()
	oDataFim:Refresh()
	oDataIni:Disable()
	oDataFim:Disable()
	cCodFil   := cFilAnt //Seta a filial corrente
	Lj720NomFi( cCodFil, @cDescrFil, .F. ) //Atualiza a descricao da filial
	oCodFil:Disable()
	oBotaoPesq:Disable()
Else  //Com NF de entrada
	oFiltroPor:Enable()
	oDataIni:Enable()
	oDataFim:Enable()
	oCodFil:Enable()
	oBotaoPesq:Enable()
Endif

oDataIni:Refresh()
oDataFim:Refresh()
oCodFil:Refresh()
oDescrFil:Refresh()

Lj720AltProc( cAliasTRB, @aRecSD2, oGetdTRC, @lFormul, @lCompCR, @nRecnoTRB, nTpProc )

Lj720CfgDb( nNfOrig, oGetdTRC, nPanel, aRecSd2 ) 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720ChgFil ºAutor  ³ Vendas Cliente     º Data ³12/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Habilita / Desabilita os campos de filtro de dados da venda.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L720ChgFil( nFiltroPor	, oSayClient, oCodCli		, oLojaCli	,;
							oNomeCli	, oSayDtIni	, oDataIni		, oSayDtFim	,;
							oDataFim	, oSayNumNF	, oCodNumNF		, oSaySerie	,;
							oSerieNF	, cAliasTRB	, aRecSD2		, oGetdTRC	,;
							lFormul		, lCompCR	, nRecnoTRB		, nTpProc 	,;
							nNfOrig 	, nPanel    , oLblValTroca	, oValTroca,;
							oSayFil		, oCodFil	, oDescrFil	)

DEFAULT oLblValTroca := Nil 
DEFAULT oValTroca    := nIL

If nFiltroPor == 1 //Filtro por "Cliente e Data"
	oSayClient:Show()
	oCodCli:Show()
	oLojaCli:Show()
	oNomeCli:Show()
	oSayClient:Enable()
	oCodCli:Enable()
	oLojaCli:Enable()
	oNomeCli:Enable()
	oSayDtIni:Show()
	oDataIni:Show()
	oSayDtFim:Show()
	oDataFim:Show()
	oSayNumNF:Hide()
	oCodNumNF:Hide()
	oSaySerie:Hide()
	oSerieNF:Hide()
	oLblValTroca:Hide()
	oValTroca:Hide()
	oSayFil:Show()
	oCodFil:Show()
	oDescrFil:Show()
ElseIf nFiltroPor == 2  //Filtro por "No. Cupom / Nota"
	oSayClient:Show()
	oCodCli:Show()
	oLojaCli:Show()
	oNomeCli:Show()
	oSayClient:Disable()
	oCodCli:Disable()
	oLojaCli:Disable()
	oNomeCli:Disable()
	oSayDtIni:Hide()
	oDataIni:Hide()
	oSayDtFim:Hide()
	oDataFim:Hide()
	oSayNumNF:Show()
	oCodNumNF:Show()
	oSaySerie:Show()
	oSerieNF:Show()
	oLblValTroca:Hide()
	oValTroca:Hide()
	oSayFil:Show()
	oCodFil:Show()
	oDescrFil:Show()
ElseIf nFiltroPor == 3
	oSayClient:Hide()
	oCodCli:Hide()
	oLojaCli:Hide()
	oNomeCli:Hide()
	oSayDtIni:Hide()
	oDataIni:Hide()
	oSayDtFim:Hide()
	oDataFim:Hide()
	oSayNumNF:Hide()
	oCodNumNF:Hide()
	oSaySerie:Hide()
	oSerieNF:Hide()
	oLblValTroca:Show()
	oValTroca:Show()
	oSayFil:Hide()
	oCodFil:Hide()
	oDescrFil:Hide()
EndIf

Lj720AltProc( cAliasTRB, @aRecSD2, oGetdTRC, @lFormul, @lCompCR, @nRecnoTRB, nTpProc )

Lj720CfgDb( nNfOrig, oGetdTRC, nPanel, aRecSd2 ) 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720ChgCli ºAutor  ³ Vendas Cliente     º Data ³12/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao executada na mudanca do Cliente / Loja.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L720ChgCli( cField		, cAliasTRB , aRecSD2  	, oGetdTRC  , ;
							lFormul  	, lCompCR   , nRecnoTRB	, nTpProc	, ;
							nNfOrig 	, nPanel	, cCodCli 	, cLojaCli	, ;
							cCodFil		, oLojaCli	, oNomeCli 	, cNomeCli)

Local lRet := .T.

If cField == "CODCLI" //Chamada atraves do valid do campo Codigo do Cliente

	If !EMPTY(cCodCli) .AND. EMPTY(cLojaCli)
		cLojaCli := Posicione("SA1",1,FWxFilial("SA1",cCodFil)+cCodCli,"A1_LOJA")
		lRet := Lj720SeekCl(cCodFil, cCodCli, cLojaCli)
	else
		lRet := .T.
	EndIf
	
	cNomeCli := Lj720VldCli(cCodCli,cLojaCli,cCodFil)
	oLojaCli:Refresh()
	oNomeCli:Refresh()

ElseIf cField == "CODLOJA" //Chamada atraves do valid do campo Loja do Cliente

	If !EMPTY(cLojaCli)
		lRet := Lj720SeekCl(cCodFil, cCodCli, cLojaCli)
	else
		lRet := .T.
	EndIf
	
	cNomeCli := Lj720VldCli(cCodCli,cLojaCli,cCodFil)
	oNomeCli:Refresh()
	
EndIf

Lj720AltProc( cAliasTRB, @aRecSD2 ,oGetdTRC, @lFormul, @lCompCR, @nRecnoTRB, nTpProc )

Lj720CfgDb( nNfOrig, oGetdTRC, nPanel, aRecSd2 )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ L720SelIte ºAutor  ³ Vendas Cliente     º Data ³16/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela para selecao dos itens da venda a serem         º±±
±±º          ³ trocados / devolvidos.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                  	                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function L720SelIte( cCodFil		, aRecSd2	, nNfOrig	, nFiltroPor, ;
							cCodCli		, cLojaCli	, cNomeCli	, oNomeCli	, ;
							dDataIni  	, dDataFim	, cAliasTRB , nRecnoTRB , ;
							cNumNF 		, cSerieNF 	, nVlrTotal , cValTroca , ;
							lLegMotDev	, nTpProc	)
Local oDlgSelIte
Local aCpoBrw 		:= {}       											// Campos da tabela SD2 que serao exibidos na MsSelect
Local lMv_Rastro	:= (SuperGetMv( "MV_RASTRO", Nil, "N" ) == "S")			// Flag de verificacao do rastro
Local oMark
Local cMarca  		:= GetMark()	                                         	// Marca da MsSelect
Local nX			:= 0
Local nCount        := 0                                                // Contador
Local lConsPadr     := .F.                                              // Verifica se possui consulta padrao
Local lContinua		:= .T.
Local cCodFilCli 	:= FWxFilial("SA1",cCodFil)
Local lAchouSD2		:= .F.
Local lConfirma 	:= .F.
Local cDescPrd		:= "" 
Local cCodBar       := ""
Local oSayDesc		
Local oSayCodBar
Local cProd			:= Space(TamSx3("D2_COD")[1])						//Campo do Codigo do produto ou Codigo de barras
Local oFnt         	:= Nil 												//Fonte
Local aPos         	:= {}												//Posicao Dialog
Local oPanVA1      	:= Nil												//Painel
Local oBotaoPesq   	:= Nil												//Botao de pesquisa
Local oTGetProd    	:= Nil												//Campo do get do conteudo a ser pesquisado
Local bOkButton    	:= Nil												//Botao para confirmar a selecao dos produtos
Local bCancelButton	:= Nil												//Botao de cancelar
Local lNfsf			:= SuperGetMV("MV_LJVFNFS",,.F.)  					//Verifica se utiliza nota simples faturamento
Local cTesNfsF		:= SuperGetMV("MV_LJVFTEE",,"") 					//TES utilizada para a geracao da nota fiscal de simples faturamento
Local cTesNfsR		:= SuperGetMV("MV_LJTESPE",,"") 					//TES utilizada para a geracao da nota fiscal de simples Remesa
Local cTES			:= '' 												// TES utilizada na venda

Default lLegMotDev	:= .F.

// Valida se os campos obrigatorios foram informados
If nFiltroPor == 1 //Filtro por Cliente e data
	If Empty(cCodCli)
		Alert(STR0027) //"O código do cliente deve ser informado."
		lContinua:= .F.
	ElseIf Empty(cLojaCli)
		Alert(STR0122) //"O código da loja deve ser informado."
		lContinua:= .F.
	EndIf
	If lContinua
	   DbSelectArea("SA1")
	   DbSetOrder(1)
	   If !DbSeek(cCodFilCli+cCodCli+cLojaCli)
	      //"O cliente selecionado não está cadastrado!"
	      Alert(STR0056)
	      lContinua  := .F.
	   Endif
	Endif
ElseIf nFiltroPor == 2  //Filtro por No. Nota e serie
	If Empty(cNumNF)
		Alert(STR0146) //"O número do cupom ou nota deve ser informado"
		lContinua:= .F.
	ElseIf Empty(cSerieNF)
		Alert(STR0147) //"A série deve ser informada"
		lContinua:= .F.
	EndIf
ElseIf nFiltroPor == 3  //Filtro por Vale-Troca
	
	If L720ValeTroca( cValTroca,@cCodFil )
		// Caso o codigo do cupom de troca seja informado, é chamada a funcao de atualizacao da tela, que somente sera atualizada se o codigo for valido.
		Lj720GetDB( aRecValTroca, cAliasTRB, oGetdTRC, @nRecnoTRB, cCodFil, @nVlrTotal, .T. )
		aRecSd2 := aRecValTroca
	EndIf
EndIf

If lContinua .AND. nFiltroPor <> 3
	//Definicao dos campos
	aAdd(aCpoBrw,{"D2_OK"		,," "	 ," "})
	aAdd(aCpoBrw,{"D2_DOC" 		,,STR0016," "})  								//"Documento de Saida"
	aAdd(aCpoBrw,{"D2_SERIE"	,,STR0017," "})									//"Série"
	aAdd(aCpoBrw,{"D2_ITEM	"	,,STR0041," "})									//"Item"		
	aAdd(aCpoBrw,{"D2_EMISSAO"	,,STR0018," "})									//"Emissão"
	aAdd(aCpoBrw,{"D2_COD"      ,,STR0019," "})									//"Produto"  
	aAdd(aCpoBrw,{"D2_QUANT"	,,STR0042,PesqPict("SD2","D2_QUANT")})			//"Qtde. Vendida" 
	aAdd(aCpoBrw,{"D2_QTDEDEV"	,,STR0043,PesqPict("SD2","D2_QTDEDEV")})		//"Qtde. Devolvida" 
	aAdd(aCpoBrw,{"D2_PRUNIT"	,,STR0021,PesqPict("SD2","D2_PRUNIT")})			//"Preco Unitário"
	aAdd(aCpoBrw,{"D2_TOTAL"	,,STR0022,PesqPict("SD2","D2_TOTAL")}	)		//"Valor do Item"
	aAdd(aCpoBrw,{"D2_VALIPI"	,,STR0212,PesqPict("SD2","D2_VALIPI")}	)		//"Valor do IPI"
	aAdd(aCpoBrw,{"D2_UM"		,,STR0023," "})									//"Unidade"
	aAdd(aCpoBrw,{"D2_TES"		,,STR0044," "})									//"TES"

	If lMv_Rastro
		Aadd(aCpoBrw,{"D2_LOTECTL"	,,STR0107,PesqPict("SD2","D2_LOTECTL")}	)	// Lote
		Aadd(aCpoBrw,{"D2_NUMLOTE"	,,STR0108,PesqPict("SD2","D2_NUMLOTE")}	)	// Sub Lote
		Aadd(aCpoBrw,{"D2_DTVALID"	,,STR0109,PesqPict("SD2","D2_DTVALID")}	)	// Validade do Lote
	EndIf
	If HasTemplate("OTC")
		Aadd(aCpoBrw,{"D2_CODGENE"	,,STR0119,PesqPict("SD2","D2_LOTECTL")}	)	// CODIGO GENERICO
		Aadd(aCpoBrw,{"D2_RECEITA"	,,STR0120,PesqPict("SD2","D2_LOTECTL")}	)	// RECEITA
	EndIf
	LjGrvLog( "TROCA_DEVOLUCAO", "Campos da tabela SD2 que serao exibidos na MsSelect - aCpoBrw", aCpoBrw)
	Do Case
	
		Case nNfOrig == 1    //Com NF de Origem
			oGetdTRC:lNewLine 		:= .F.
			oGetdTRC:lDeleta  		:= .F.
			oGetdTRC:nMax     		:= 999
			oGetdTRC:aAlter			:= {"TRB_QUANT","TRB_TES"}   //Campos que podem ser alterados
			oGetdTRC:oBrowse:aAlter	:= {"TRB_QUANT","TRB_TES"}  
		Case nNfOrig == 2  	  // Sem NF de Origem		
			oGetdTRC:lNewLine 		:= .F.
			oGetdTRC:lDeleta  		:= .T.
			oGetdTRC:nMax     		:= 999
			oGetdTRC:aAlter			:= {"TRB_CODPRO","TRB_QUANT","TRB_PRCVEN","TRB_TES"} //Campos que podem ser alterados
			oGetdTRC:oBrowse:aAlter	:= {"TRB_CODPRO","TRB_QUANT","TRB_PRCVEN","TRB_TES"} //Campos que podem ser alterados
		   
			If lMv_Rastro 
				aAdd( oGetdTRC:aAlter, "TRB_LOTECT")
				aAdd( oGetdTRC:oBrowse:aAlter, "TRB_LOTECT") 
			Endif			
	Endcase
	
	//|Ponto de Entrada para permitir edicao de colunas|
	If ExistFunc("U_LJ720ALT")
		LjGrvLog( "TROCA_DEVOLUCAO", "Existe Ponto de Entrada para permitir edicao de colunas U_LJ720ALT")
		xRet  := U_LJ720ALT(@lConsPadr)
		LjGrvLog( "TROCA_DEVOLUCAO", "Retorno do Ponto de Entrada U_LJ720ALT", xRet)
	    If ValType(xRet) == "A" .AND. Len(xRet) == 2 .AND. ValType(xRet[1]) == "A" .AND. ValType(xRet[2]) == "A" .AND. !lConsPadr
		  	For nX := 1 To Len(xRet[1])
		  		If ValType(xRet[1, nX]) == "C"
					aAdd(oGetdTRC:aAlter, xRet[1, nX])
		   		EndIf	  
			Next
		   	For nX := 1 To Len(xRet[2])
		   		If ValType(xRet[2, nX]) == "C"
					aAdd(oGetdTRC:oBrowse:aAlter, xRet[2, nX])
				EndIf
			Next  
		ElseIf ValType(xRet) == "A" .AND. lConsPadr    // Caso possua consulta padrao F3
			For  nCount := 1 To Len(xRet)
		  		aAdd(oGetdTRC:aAlter, xRet[nCount,1][1])
				aAdd(oGetdTRC:oBrowse:aAlter, xRet[nCount,2][1])
				oGetdTRC:aInfo[xRet[nCount,3,1]][1] := xRet[nCount,4][1]
			Next nCount
		EndIf			  
	EndIf
	
	oGetdTRC:oBrowse:Refresh()
	oGetdTRC:ForceRefresh()
	
	//³Desmarca todos os produtos que foram marcados no panel de selecao de produtos³
	If Len(aRecSD2) > 0
		For nX:= 1 to Len(aRecSD2)
			DbSelectArea("SD2")
			DbGoTo(aRecSD2[nX][2])
			RecLock("SD2",.F.)
			REPLACE	SD2->D2_OK WITH Space(Len(SD2->D2_OK))
			MsUnlock()                                                             
		Next nX
		aRecSD2:= {}
	Endif
	
	// Filtra registros da tabela SD2
	MsgRun(STR0055,,{ || Lj720FilSD2( 	@cCodCli 	, @cLojaCli , dDataIni  , dDataFim 	,;
										Nil     	, cAliasTRB , @cNomeCli , oNomeCli  ,;
										cCodFil 	, nFiltroPor, cNumNF 	, cSerieNF	,;
										nNfOrig ) })  //"Aguarde..."
	
	lAchouSD2 := SD2->( !EOF() ) //Verifica se foi encontrado registro na SD2
	
	If lAchouSD2
	
		DEFINE FONT oFnt	SIZE 7,19
		DEFINE MSDIALOG oDlgSelIte TITLE STR0148 From 0,0 To 450,750 PIXEL //"Itens para troca ou devolução"
		
		aPos := PosDlg(oDlgSelIte)
		oPanVA1  := TPanel():New(0, 0, "", oDlgSelIte, NIL, .T., .F.,;
								 NIL, NIL, aPos[4], aPos[3], .T., .F. )
									
		@ 035,005 SAY STR0149 OF oPanVA1 COLOR CLR_HBLUE  PIXEL FONT oFnt SIZE 250,9 //"Selecione os produtos que serão trocados ou devolvidos"

		@ 047,005 SAY STR0210 OF oPanVA1 COLOR CLR_HBLUE  PIXEL FONT oFnt SIZE 250,9 //"Produto: "
		oTGetProd := TGet():New( 047,033,{|x| If(PCount() > 0,cProd := x,cProd)},oPanVA1,096,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| },.F.,.F.,,"cProd",,,, )
		oTGetProd:SetFocus()
		
		@ 047,130 BUTTON oBotaoPesq PROMPT STR0209 SIZE 030,010 OF oDlgSelIte PIXEL ;
			ACTION ( LJ720Pesq(cProd,@cDescPrd,@cCodBar,oSayDesc,oSayCodBar) ) //"Buscar"
				
		@ 190,010 SAY STR0189 OF oPanVA1 COLOR CLR_HBLUE  PIXEL FONT oFnt SIZE 250,9 //"Descricao Produto : " 
		cDescPrd := Alltrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"))
		oSayDesc := TSay():New(190,080 ,{||cDescPrd},oPanVA1,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		
		If !Empty(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CODBAR")) //Busca Codigo de Barras na SB1 					
			cCodBar := AllTrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CODBAR"))
		ElseIf !Empty(Posicione("SLK", 2, xFilial("SLK") + Padr(SD2->D2_COD, TamSx3("LK_CODIGO")[1]), "LK_CODBAR")) //Busca Codigo de Barras na SLK 							
			cCodBar := AllTrim(Posicione("SLK", 2, xFilial("SLK") + Padr(SD2->D2_COD, TamSx3("LK_CODIGO")[1]), "LK_CODBAR"))			
		Else
			cCodBar := STR0190 //"NAO CADASTRADO"
		EndIf
	
		@ 200,010 SAY STR0191 OF oPanVA1 COLOR CLR_HBLUE  PIXEL FONT oFnt SIZE 250,9 //"Codigo de Barras: "
		oSayCodBar := TSay():New(200,080 ,{||cCodBar},oPanVA1,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		
		DbSelectArea("SD2")
		oMark := MsSelect():New("SD2","D2_OK",,aCpoBrw,.F.,@cMarca,{065,002,175,oPanVA1:nClientWidth/2},"SD2->(DbGotop())","SD2->(DbGoBottom())",oPanVA1)
		oMark:oBrowse:bDrawSelect := {||Lj720Com(@cDescPrd,@cCodBar, @oPanVA1, oSayDesc, oSayCodBar )}
 		oMark:oBrowse:bChange := {||Lj720Com(@cDescPrd,@cCodBar, @oPanVA1, oSayDesc, oSayCodBar )}
		oMark:oBrowse:lhasMark    := .T.
		oMark:oBrowse:lCanAllmark := .T.						//Indica se pode marcar todos de uma vez
		oMark:bAval := {||Lj720Mark(@cMarca,@aRecSD2,@oMark,cCodFil)}		//Funcao de execucao quando marca ou desmarca
 		oMark:oBrowse:bAllMark := {||Lj720AllMark(@cMarca,@aRecSD2,@oMark,cCodFil)}
		
		SD2->(DbGotop())

		bOkButton 		:= {|| (If(Lj720MsSelOk(aRecSd2,@lLegMotDev, nTpProc , cCodFil),(lConfirma:=.T.,oDlgSelIte:End()),Nil)) }
		bCancelButton	:= {|| (oDlgSelIte:End()) }
		
		ACTIVATE MSDIALOG oDlgSelIte CENTERED ON INIT EnchoiceBar( oDlgSelIte, bOkButton, bCancelButton, .F., Nil, Nil,Nil,.F.,.F.,.F.,.T.,.F. )
		
		If lConfirma
			//Atualiza conteudo dos campos Codigo do Cliente, Loja, Nome do Cliente
			cCodCli 	:= SD2->D2_CLIENTE
			cLojaCli	:= SD2->D2_LOJA
			cNomeCli 	:= Posicione("SA1",1,cCodFilCli+cCodCli+cLojaCli,"A1_NOME") 
			cTES		:= SD2->D2_TES 

			// Verifica se é NF de Simples Remessa ou Simples Faturamento
			If lNfsf .AND. ( cTES == cTesNfsf .OR. cTES == cTesNfsR )
				LJ720NfsFt( cTesNfsf, cTesNfsR, cTES )
			EndIF

			//Atualiza GetDados com os itens selecionados
			Lj720GetDB(@aRecSd2, cAliasTRB, oGetdTRC, @nRecnoTRB, cCodFil, @nVlrTotal, , cTesNfsR)
		Else
			nVlrTotal := 0
			
			//Limpa conteudo dos campos Codigo do Cliente, Loja, Nome do Cliente
			cCodCli 	:= Space(TamSX3("D2_CLIENTE")[1])
			cLojaCli	:= Space(TamSX3("D2_LOJA")[1])
			cNomeCli 	:= Space(TamSX3("A1_NOME")[1])
		EndIf		
	Else 
	    If Lj720VerSFT(	cCodCli 	, @cLojaCli , dDataIni  , dDataFim 	,;
					    cCodFil 	, cNumNF 	, cSerieNF  , nFiltroPor )
	    	MsgAlert(STR0193 + CHR(13) + CHR(10) + STR0235 )//"Devolução ou Troca Já foi Efetuada para esta venda"	+ "Caso seja um item tipo Venda de serviço, o tipo de origem deve ser Sem Domumento de Entrada."
		Else
			MsgAlert(STR0194) //"Nenhuma venda foi encontrada, Verifique os dados informados." 
		EndIf	
	EndIf

EndIf
 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720ValeTroca  ºAutor  ³ Vendas Cliente    º Data ³16/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz validacao na troca para o proximo painel do Wizard.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	L720ValeTroca( cValTroca,cCodFil )
Local aArea    		:= GetArea()        // Pega a area corrente
Local cDoc     		:= ""               // F2_DOC da compra do item que sera trocado
Local cItem    		:= ""               // Pega o numero do item, que esta inserido no codigo
Local cSerie   		:= ""               // Recebe a serie do documento apos a trativa
Local lRet     		:= .F.              // Retorna se o codigo do cupom de troca foi informado
Local cCliente 		:= ""               // Codigo do cliente
Local cLoja    		:= ""               // Loja do cliente
Local aClientes		:= {}               // Array com as informações de cliente. Pode encontrar mais de um cliente.
Local cAliasTrb		:= GetNextAlias()	// Pega proximo alias
Local cFilSD2		:= ""				// Filial da tabela SD2
Local cFilSF2		:= ""				// Filial da tabela SF2			
Local aDados		:= {}				// Dados do codigo de barras
Local aPergs		:= {}				// Array utilizado para ParamBox
Local nTentativa	:= 0				// Numero de tentativas de busca
Local lTentativa 	:= .T.				// Se tentará novamente
Local aRet			:={}				// Retorno do ParamBox

If !Empty(cValTroca)

	aDados 	:= Lj720CdBar(,,,Alltrim(cValTroca))
	cCodFil := aDados[1]
	cDoc	:= aDados[2]
	cSerie	:= aDados[3]
	cItem	:= aDados[4]
	cFilSD2 := xFilial("SD2", cCodFil)
	cFilSF2	:= xFilial("SF2", cCodFil)

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
	While nTentativa <= 2 .AND. lTentativa
		nTentativa ++
		If nTentativa > 1
			aAdd(aPergs, {1, STR0142,  Space(TamSx3("F2_FILIAL")[1]),  "", ".T.", "DLB", ".T.", 50,  .T.}) //Filial:
			If ParamBox(aPergs, STR0234, @aRet) //"Informe a filial em que a venda foi feita."
				cFilSD2 := xFilial("SD2", aRet[1])
				cFilSF2 := xFilial("SF2", aRet[1])
				cCodFil := aRet[1]
				lTentativa := .F.
			Else 
				lTentativa := .F.
			EndIf
		EndIf 
		If DbSeek(cFilSF2 + PADR(cDoc,TamSx3("F2_DOC")[1])+ PADR(cSerie,TamSx3("F2_SERIE")[1]))
			
			lTentativa := .F.

			While AllTrim(cFilSF2) + AllTrim(cDoc) + AllTrim(cSerie) == AllTrim(SF2->F2_FILIAL) + AllTrim(SF2->F2_DOC) + AllTrim(SF2->F2_SERIE) .AND. !EOF()
				aAdd(aClientes,{F2_CLIENTE,F2_LOJA,Posicione("SA1",1,xFilial("SA1")+F2_CLIENTE+F2_LOJA,"A1_NOME"),.F.})
				SF2->(DbSkip())
			End
			
			If !Empty(aClientes) .AND. Len(aClientes) > 1
			
				aClientes := L720CVTSelCli( aClientes )
				If !Empty(aClientes)
					cCliente  := aClientes[1]
					cLoja     := aClientes[2]
				EndIf
				
			ElseIf !Empty(aClientes)
			
				cCliente := aClientes[1,1]
				cLoja    := aClientes[1,2]
				
			EndIf
			
			BeginSQL Alias cAliasTrb
				SELECT D2_QUANT, D2_QTDEDEV, R_E_C_N_O_ RECNOSD2
				FROM %Table:SD2%
				WHERE   D2_FILIAL  = %Exp:cFilSD2%	    AND
						D2_DOC     = %Exp:cDoc%    	    AND
						D2_SERIE   = %Exp:cSerie%    	AND
						D2_CLIENTE = %Exp:cCliente%    	AND
						D2_LOJA    = %Exp:cLoja%    	AND
						D2_ITEM    = %Exp:cItem%    	AND
						%NotDel%
			EndSQL
			
			If (cAliasTrb)->(!Eof())
				If Max((cAliasTrb)->D2_QUANT - (cAliasTrb)->D2_QTDEDEV, 0) > 0
					If aScan( aRecValTroca, {|x| x[2] == RECNOSD2} ) == 0
						aAdd( aRecValTroca, {1,RECNOSD2,.F.,0 , 0 })
					Else
						Alert( STR0159+CRLF+STR0160 ) // "Este vale-troca já foi utilizado nesta venda." ### "Caso queira devolver mais de uma unidade do produto, altere a quantidade!"
						lRet := .F.
					EndIf
				Else
					Alert( STR0161 ) // "A troca já foi efetuada e não poderá ser realizada novamente."
					lRet := .F.
				EndIf
			Else
				Alert( STR0162 ) // "O código informado é inválido!"
			EndIf
			lRet := .T.
		EndIf
	End
Else
	Alert( STR0163 ) // "O codigo do vale-troca deve ser informado!"
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720CVTSelCli  ºAutor  ³ Vendas Cliente º Data ³24/Set/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria tela de selecao de cliente pro cupom de vale troca.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L720CVTSelCli( aClientes )
Local oDlg        := Nil
Local oPanel      := Nil
Local oBtnOk      := Nil
Local oBtnCancel  := Nil
Local oGet        := Nil
Local lRet        := .T.
Local aHeaderGet  := L720HeadCVT()
Local aRet        := {}

DEFAULT aClientes := {}

DEFINE DIALOG oDlg TITLE STR0164 FROM 0,0 TO 300,500 PIXEL // "Seleção de cliente"
	
oPanel:= TPanel():New(0,0,"",oDlg,,,,,,0,0)
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

TSay():New(05,05,{|| STR0165 },oPanel,,,,,,.T.,,) // "Selecione o cliente desejado:"
oGet       := MsNewGetDados():New( 20, 05, 105 , 250 , 0,"AllwaysTrue","AllwaysTrue","",,,,,,,oPanel,aHeaderGet,aClientes,, )
oBtnOk     := TButton():New( 120, 160,"OK",oPanel,{||lRet:=.T.,oDlg:End()},30,11,,,.F.,.T.,.F.,,.F.,,,.F. )
oBtnCancel := TButton():New( 120, 200,STR0150,oPanel,{||lRet:=.F.,oDlg:End()},30,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

ACTIVATE DIALOG oDlg CENTER

If lRet
	
	aRet := aClientes[oGet:nAt]
	
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720HeadCVT  ºAutor  ³ Vendas Cliente º Data ³24/Set/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aHeader para a funcao L720CVTSelCli                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function L720HeadCVT()

Local aHeader	:= {}
Local aCpos	  	:= {}
Local nX		  	:= 0
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local nTamCpo	:= SX3->(Len(X3_CAMPO))

aAdd(aCpos,'F2_CLIENTE')
aAdd(aCpos,'F2_LOJA')
aAdd(aCpos,'A1_NOME')

SX3->(dbSetOrder(2)) //X3_CAMPO
For nX := 1 to Len(aCpos)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If SX3->(MsSeek( Padr(aCpos[nX],nTamCpo )))
		IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
			aAdd( aHeader ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
			,SX3->X3_PICTURE ,SX3->X3_TAMANHO ;
			,SX3->X3_DECIMAL ,Nil ;
			,SX3->X3_USADO ,SX3->X3_TIPO ;
			,Nil ,SX3->X3_CONTEXT ;
			,"" ,SX3->X3_RELACAO})
		EndIf
	EndIf
Next

RestArea( aAreaSX3 )
RestArea( aArea )

Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720NextPn  ºAutor  ³ Vendas Cliente    º Data ³16/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz validacao na troca para o proximo painel do Wizard.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L720NextPn(	nPanel 		, nNfOrig 		, cCodCli	, cLojaCli	,;
							oWizard		, nTpProc 		, cCodDia	, lAliasCVL	,;
							cCodFilCli	, nFiltroPor  	, aRecSD2	, lDevFrete)

Local lRet          :=  .T.     	                  // Retorno da Funcao
Local lLJ720Next    := ExistBlock("LJ720NEXT")       // Controla se o PE LJ720NEXT existe
Local lLJ720Prox    := ExistBlock("LJ720PROX")       // Controla se o PE LJ720PROX existe

Default cCodDia     := ""
Default lAliasCVL   := .F.

cCodFilCli := FWxFilial("SA1",cCodFilCli)

lTroca  := nTpProc == 1

If nPanel == 1
	If nFiltroPor == 1
		If Empty(cCodCli)
			Alert(STR0027) //"O código do cliente deve ser informado."
			lRet:= .F.
		ElseIf Empty(cLojaCli)
			Alert(STR0122) //"O código da loja deve ser informado."
			lRet:= .F.
		EndIf
		If lRet
			If nNfOrig == 2 //Sem documento de entrada
				lRet := Lj720ValCli(cCodCli,cLojaCli)
			EndIf
		EndIf
		If lRet
		   DbSelectArea("SA1")
		   DbSetOrder(1)
		   If !DbSeek(cCodFilCli+cCodCli+cLojaCli)
		      //"O cliente selecionado não está cadastrado!"
		      Alert(STR0056)
		      lRet  := .F.
		   Endif
		Endif
	EndIf
	
	If lRet .And. nNfOrig == 1 .And. Len(aRecSd2) == 0
		MsgAlert(STR0152) //"Não existem produtos para troca ou devolução."
		lRet:= .F.
	EndIf
	
	If lRet .And. nNfOrig == 2
		lRet := Lj720ValCli(cCodCli,cLojaCli)
	EndIf
	
    If lRet
		If lLJ720Next
			LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:LJ720NEXT",{nTpProc, nPanel, nNfOrig, cCodCli, cLojaCli })
			lRet  := ExecBlock("LJ720NEXT",.F.,.F.,{nTpProc, nPanel, nNfOrig, cCodCli, cLojaCli })
			LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:LJ720NEXT - lRet", lRet)
		Endif
    Endif
ElseIf nPanel == 2
	If Empty(cCodCli) 
		Alert(STR0027)//"O código do cliente deve ser informado."
		lRet:= .F.
	EndIf
	lRet := lRet .And. Lj720ValCli(cCodCli,cLojaCli)
	lRet := lRet .And. Lj720ValDia( cCodDia, lAliasCVL )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada valido para todas as mudancas de panel. ³
//³Controlar dentro do ponto de entrada. Nao foi possivel   ³
//³utilizar o LJ720NEXT porque ja estava publicado		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
   If lLJ720Prox
		LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:LJ720PROX",{nTpProc, nPanel, nNfOrig, cCodCli, cLojaCli,lDevFrete })
		lRet  := ExecBlock("LJ720PROX",.F.,.F.,{nTpProc, nPanel, nNfOrig, cCodCli, cLojaCli,lDevFrete })
		LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:LJ720PROX - lRet", lRet)
   Endif         
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ L720VldDel  ºAutor  ³ Vendas Cliente    º Data ³17/Jun/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao no momento da delecao do item.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L720VldDel()

If TRB->TRB_FLAG
	nVlrTotal += TRB->TRB_VLRTOT
Else
	nVlrTotal -= TRB->TRB_VLRTOT
EndIf
oVlrTotal:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720NccIcmJr ºAutor ³ Vendas Cliente   º Data ³10/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de atualização de saldos para titulos/NCC com valor º±±
±±º			 ³ de juros separados do valor total - MV_LJICMJR			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720NccIcmJr(aNcc, cChaveSl1, nVlTotDev, lCompCR, cCodFil)
Local aOrd		:= GetArea()
Local nValAcres	:= 0
Local nI		:= 0

If Len(aNcc) > 0 .And. nVlTotDev > 0

	nValAcres := LJ720VlAcresc(cChaveSl1, nVlTotDev, cCodFil)
	If nValAcres > 0
		For nI := 1 To Len(aNcc)
			SE1->(DbGoTo(aNcc[nI]))
			If SE1->(RecLock("SE1", .F.))
				If lCompCR
					SE1->E1_ACRESC	:= nValAcres
				Else
					SE1->E1_VALOR += nValAcres
					SE1->E1_SALDO += nValAcres
				EndIf

				SE1->(MSunlock())
			EndIf
		Next 
	EndIf
EndIf
RestArea(aOrd)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LJ720VlAcresc ºAutor ³ Vendas Cliente   º Data ³10/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de calculo do valor de juros de um item de uma vendaº±±
±±º			 ³ onde o juros esta separados do valor total - MV_LJICMJR	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function LJ720VlAcresc(cChaveSl1, nVlTotDev, cCodFil)
Local nItAcres	:= 0
Local nValAcres := 0
Local aOrd		:= GetArea()

Default cCodFil := cFilAnt

Lj7Arred(1)
SL1->(DbSetOrder(2))
If SL1->(DbSeek(xFilial("SL1",cCodFil)+cChaveSl1))
	SL4->(DbSetOrder(1))
	If SL4->(DBSeek(xFilial("SL4",cCodFil)+SL1->L1_NUM))
		While SL4->(!EOF()) .And. SL4->(L4_FILIAL+L4_NUM) == SL1->(L1_FILIAL+L1_NUM)
			nValAcres += SL4->L4_ACRSFIN
			SL4->(DBSkip())
		EndDo
	EndIf
	nItAcres := (nVlTotDev/SL1->L1_VLRTOT)
	nItAcres := Lj7Arred(2,3,nItAcres*nValAcres)
EndIf
RestArea(aOrd)
Return nItAcres

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720VPDev	 ºAutor ³ Vendas Cliente   º Data ³14/11/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para estorno do status do item do tipo Vale Presenteº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720VPDev(aRecSD2, cCodFil)
Local lRet		:= .T.
Local nI		:= 0
Local aOrdSD2	:= SD2->(GetArea())

LjGrvLog( "TROCA_DEVOLUCAO", "Executando processo de status para o estorno de Vale Presente")

For nI := 1 To Len(aRecSD2)

	SD2->(DBGoTo(aRecSD2[nI][2]))

	lRet := PosValePre(cCodFil)
	
	If lRet
		If RecLock("MDD", .F.)
			REPLACE MDD->MDD_STATUS	WITH "1"
			REPLACE MDD->MDD_DOCV	WITH ""
			REPLACE MDD->MDD_PDVV	WITH ""
			REPLACE MDD->MDD_SERIV	WITH ""
			REPLACE MDD->MDD_ESTV	WITH ""
			REPLACE MDD->MDD_DATAV	WITH CTOD("  /  /  ")
			REPLACE MDD->MDD_HORAV	WITH ""
			REPLACE MDD->MDD_CLIV	WITH ""
			REPLACE MDD->MDD_LJCLIV	WITH ""
			REPLACE MDD->MDD_VEND	WITH ""
			MDD->(MsUnlock())
		EndIf		
	EndIf

Next nI

RestArea(aOrdSD2)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PosValePre	 ºAutor ³ Vendas Cliente   º Data ³14/11/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para posicionar no registro de vale presente de 	  º±±
±±º		     ³ acordo com o posicionamento da tabela SD2.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³ É necessário que a tabela SD2 esteja posicionada correta-  º±±
±±º			 ³ mente.													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PosValePre(cCodFil)
Local lRet		:= .F.
Local aOrdSB1	:= SB1->(GetArea())
Local aOrdSL2	:= SL2->(GetArea())
Local nTamCod	:= TamSX3("MDD_CODIGO")[1] 

SB1->(DBSetOrder(1))
SL2->(DbSetOrder(3))
MDD->(DbSetOrder(1))
If SB1->(DBSeek(xFilial("SB1",cCodFil)+SD2->D2_COD))

	If AllTrim(SB1->B1_VALEPRE) == "1" //1=Sim (Vale Presente)

		If SL2->(DbSeek(xFilial("SL2",cCodFil)+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_COD))

			While SL2->(!EOF()) .And. xFilial("SL2",cCodFil)+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_COD == SL2->(L2_FILIAL+L2_SERIE+L2_DOC+L2_PRODUTO)

				If SD2->D2_ITEM == SL2->L2_ITEM .And. !Empty(SL2->L2_VALEPRE)

					If MDD->(DbSeek( xFilial("MDD",cCodFil)+ PadR(SL2->L2_VALEPRE,nTamCod)))
						lRet := .T.
						Exit
					EndIf
				EndIf
				SL2->(DBSkip())
			End
		EndIf
	EndIf
EndIf

RestArea(aOrdSB1)
RestArea(aOrdSL2)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ720LinOKºAutor  ³Vendas Clientes     º Data ³  05/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a linha do Grid de Produtos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌSintaxe   ³ ExpL1:= LJ720LinOK()                                		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Informacoes da SD2  								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ ExpL1 =.T.            									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ720LinOK()
Local nPos := 0				// Recebe a Posicao do item no Array
Local nRecnoAtu := 0 		// Recebe o Recno anterior
Local lRet := .T.			// Recebe o Retorno
Local lSFinanc := AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local cMvLjTSF := SuperGetMV("MV_LJTPSF",,"SF") 						// Define se é tipo SF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao para nao permitir devolver o produto sem devolver a garantia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TRB->TRB_FLAG 
	nPos := Ascan( aRecSD2, {|x| x[2] == TRB->TRB_RECPAI } )
	nRecnoAtu := TRB->(RECNO())
  	If nPos > 0 
	
		If	!aRecSD2[nPos][3] 
		    TRB->(dbSetOrder(1))
		    If TRB->( dbSeek( aRecSD2[nPos][2] ) ) .AND. !TRB->TRB_FLAG
				MsgStop(STR0176,STR0033)  // "O Produto não pode ser devolvido sem a Garantia Estendida." ### "Atencao" 
			   
				TRB->(DBGOTO(nRecnoAtu))
				RecLock("TRB",.F.)
				TRB->TRB_FLAG := .F.
				MsUnlock()
				lRet := .F.     
		   	   
		   		oGetdTRC:oBrowse:Refresh()
		    EndIf  
		    
	    EndIf
	EndIf
EndIf

//Validacao de Troca para Servicos Financeiros
If lRet .And. lTroca .And. lSFinanc
	While TRB->(!Eof()) .And. lRet  
		If Posicione("SB1", 1, xFilial("SB1") + TRB->TRB_CODPRO, "B1_TIPO") == cMvLjTSF			
			MsgStop(STR0187) //"Rotina de Troca não é permitida para Serviços Financeiros, utilize a opção de Devolução"
			lRet := .F.
		EndIf
		
		TRB->(dbSkip())
	EndDo	
EndIf

Return  lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ lj720CheckFat ºAutor ³ Vendas Cliente   º Data ³23/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para verificar se na venda futura devera ser uti-	  º±±
±±º		     ³ lizado o modelo de emissao de documento fiscal no momento  º±±
±±º		     ³ da venda, ou se somente emite a nota no momento da entrega º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³                                                            º±±
±±º			 ³               											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lj720CheckFat( lVFComNF, lPrimeira, lSegunda, nRecSD2, aNotas, aDocPed, cCodFil )
Local aAreaSav	:= GetArea()
Local aAreaSC6	:= SC6->(GetArea())
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSL1	:= SL1->(GetArea())
Local aAreaSL2	:= SL2->(GetArea())
Local cOrcPai	:= ""
Local cOrcfilho	:= ""
Local nPos		:= 0
Local nC        := 0

lVFComNF 	:= .F.
lPrimeira	:= .F.
lSegunda	:= .F.

For nC := 1 to Len(aDocPed)
	IF !Empty( aDocPed[nC, 01] ) .and. !Empty(  aDocPed[nC, 02])
		dbSelectArea("SC6")
		dbSetOrder(1)
		if dbSeek( aDocPed[nC, 03] + aDocPed[nC, 01] + aDocPed[nC, 02])
			dbSelectArea("SC5")
			dbSetOrder(1)
			If dbSeek( SC6->C6_FILIAL + SC6->C6_NUM )
				If !Empty( SC5->C5_ORCRES )
					dbSelectArea("SL1")
					dbSetOrder(1)
					IF dbSeek( xFilial("SL1",cCodFil) + SC5->C5_ORCRES )
						While .T.
							cOrcPai		:= SL1->L1_NUM
							cOrcfilho	:= SL1->L1_ORCRES
							if Empty(cOrcFilho)
								exit
							Else
								If !dbSeek( xFilial("SL1",cCodFil) + cOrcFilho )
									Exit
								Endif
							Endif										
						End
						if dbSeek( xFilial("SL1",cCodFil) + cOrcPai )
							If SL1->L1_DOC == SL1->L1_DOCPED .and. SL1->L1_SERIE == SL1->L1_SERPED
								aNotas := getNotas( cOrcPai, SL1->L1_FILIAL )
									nPos := ascan( aNotas, {|X| X[1] == aDocPed[nC, 04]} )
								If nPos == 1
									lVFComNF := .T.
									lPrimeira := .T.
								ElseIf nPos == 2
									lVFComNF := .T.
									lSegunda := .T.
								Endif
							Endif
						Endif
					Endif
				Endif
	    	Endif
    	Endif
	Endif
Next nC

RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaSL1)
RestArea(aAreaSL2)
RestArea(aAreaSav)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ getNotas  	 ºAutor ³ Vendas Cliente   º Data ³23/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar os numeros de notas fiscais de uma	  º±±
±±º		     ³ venda futura, pode retornar apenas uma, no caso da VF      º±±
±±º		     ³ normal (sem NF de faturamento) ou duas com o modelo de     º±±
±±º		     ³ emissao de documento fiscal no faturamento	              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³                                                            º±±
±±º			 ³               											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function getNotas( cOrcPai, cFilSL1 )
Local aRet	:= {}
Local aAreaSL1	:= SL1->(GetArea())
dbSelectArea("SL1")
dbSetOrder(1)
if dbSeek( cFilSL1 + cOrcPai )
	if SL1->L1_DOC == SL1->L1_DOCPED .and. SL1->L1_SERIE == SL1->L1_SERPED
		aadd(aRet, { SL1->L1_DOC , SL1->L1_SERIE } )
	Endif
	dbSetOrder(14)
	If dbSeek( cFilSL1 + cOrcpai )
		if !Empty( SL1->L1_DOC ) .and. !Empty( SL1->L1_SERIE )
			aadd(aRet, { SL1->L1_DOC , SL1->L1_SERIE } )
		Endif
	Endif
Endif
RestArea(aAreaSL1)
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ720GtD1  	 ºAutor ³ Vendas Cliente   º Data ³23/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para retornar os itens de uma nota de devolução	  º±±
±±º		     ³ É chamada a partir da LJ720DEVSD2 para preencher o vetor   º±±
±±º		     ³ aItens (conteudo dos itens da nota fiscal de devolução     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³ é necessário que a tabela SD2 esteja previamente posicio-  º±±
±±º			 ³ nada no item antes de chamar a função					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ720GtD1(	aRecSD2  		, aPosSd2   	, lDevolucao 	, lPoder3   	, ;
                          	cTipoNF  		, aRecAltSD2 	, aItens     	, cFilDocOri	, ;
                          	nPOs     		, aRecnoSD2 	, cNotaOri  	, cSerieOri  	, ;
                          	cCodFil  		, lQuebra   	, nFrete    	, nSeguro   	, ;
                          	nDespesa 		, lDevFrete		, nNFOrig		, aNotasOri		,;
                          	aItensOri		, nRetIcms		)
							
Local aAreaSF4								  						// Area do arquivo SF4
Local cTesDev   	:= SuperGetMv("MV_TESTROC",.F.)		    	  	// TES padrao para troca/devolucao
Local cCfOpF4		:= ""					  						// Codigo Fiscal do SF4
Local nSldDev   	:= 0                		                  	// Saldo a devolver   
Local nCntSD2   	:= 0                        		          	// Contador de numero de itens
Local lRet			:= .T.
Local aAreaSav		:= GetArea()
Local aLinha    	:= {}                               		  	// Contem os itens do documento de entrada utilizado para a rotina automatica
Local cMV_LJDVACR	:= AllTrim(SuperGetMV("MV_LJDVACR",,""))// Define se considera acrescimo financeiro na devolucao       
Local cRetTesDev    := ""                                           // Retorno do Ponto de Entrada LJ720TES 
Local lWmsNew   	:= SuperGetMV("MV_WMSNEW",.F.,.F.)				// Parâmetro para Integração novo WMS

Default nRetIcms	:= 0											//Retorno de ICMS - Substituição Tributária

LjGrvLog( "TROCA_DEVOLUCAO", "TES padrao para troca/devolucao - MV_TESTROC", cTesDev)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda a posicao do SD2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aPosSd2) == 0
	Aadd(aPosSd2,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe saldo em aberto para devolver³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SD2->D2_QTDEDEV < SD2->D2_QUANT

	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))

		aAreaSF4 := SF4->(GetArea())

		If !Empty(SF4->F4_TESDV)
			cTesDev := SF4->F4_TESDV

			SF4->(DbSeek(xFilial("SF4") + cTesDev))
			cCfOpF4 := SF4->F4_CF

		ElseIf !Empty(cTesDev)

			If !SF4->(DbSeek(xFilial("SF4") + cTesDev))
				lDevolucao := .F.
			Else
				cCfOpF4 := SF4->F4_CF
				If SF4->F4_PODER3<>"D"
					lPoder3 := .F.
				Endif
			Endif
		Else

			Help(" ",1,"DSNOTESDEV")
			lDevolucao := .F.
			lQuebra := .T.
		Endif

		If SF4->F4_PODER3<>"D"
			lPoder3 := .F.
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para trocar a TES se necessario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("LJ720TES")
		LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:LJ720TES",{lTroca, nNFOrig})
		cRetTesDev := ExecBlock( "LJ720TES",.F.,.F., {lTroca, nNFOrig} )
		If ValType(cRetTesDev) == "C" .And. !Empty(cRetTesDev)
            LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:LJ720TES - cTesDev", cRetTesDev)
		    cTesDev := cRetTesDev  
			aAreaSF4 := SF4->(GetArea())

			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))
			If SF4->(DbSeek(xFilial("SF4") + cTesDev))
				cCfOpF4 := SF4->F4_CF
			Endif

			SF4->(RestArea(aAreaSF4))
		Endif
	Endif

	cTipoNF := SD2->D2_TIPO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o saldo a devolver tanto normal como poder de terceiros           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSldDev := aRecSD2[nPos][1] //SD2->D2_QUANT-SD2->D2_QTDEDEV

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o saldo a devolver eh maior que zero para realizar a devolucao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nSldDev > 0

		nCntSD2++
		If nCntSD2 > 900  // No. maximo de Itens
			lQuebra := .T.
		Endif

		Aadd(aRecAltSD2,{aRecSD2[nPos][2],aRecSD2[nPos][1],SD2->D2_CLIENTE,SD2->D2_LOJA})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a linha de devolucao que sera gerado o SD1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aLinha := {}
		AAdd( aLinha, { "D1_COD"    , SD2->D2_COD    , Nil } )
		AAdd( aLinha, { "D1_QUANT"  , nSldDev, Nil } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametro indica se retira o acrescimo (quando for 1)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMV_LJDVACR == "1"
            AAdd( aLinha, { "D1_VUNIT"  , SD2->D2_PRCVEN + ( ( (SD2->D2_DESCON+SD2->D2_DESCZFR) - SD2->D2_VALACRS ) / SD2->D2_QUANT ), Nil })
		Else
            AAdd( aLinha, { "D1_VUNIT"  , SD2->D2_PRCVEN + ( (SD2->D2_DESCON+SD2->D2_DESCZFR) / SD2->D2_QUANT ), Nil })
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for devolucao total nao calcula totais e descontos proporcionais³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD2->D2_QUANT==nSldDev

			If cMV_LJDVACR == "1"
				AAdd( aLinha, { "D1_TOTAL"  , SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR - (SD2->D2_VALACRS),Nil } )
			Else
				AAdd( aLinha, { "D1_TOTAL"  , SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR,Nil } )
			EndIf

			AAdd( aLinha, { "D1_VALDESC", SD2->D2_DESCON + SD2->D2_DESCZFR , Nil } )
			AAdd( aLinha, { "D1_ICMSRET", SD2->D2_ICMSRET, Nil } )
		Else

            //Caso for devolver a quantidade de saldo, faz a conta levando em consideração o valor já devolvido
            //Para não ter problemas de arredondamento quando utilizado mais de 2 casas decimais
            If SD2->D2_QUANT - SD2->D2_QTDEDEV == nSldDev
			    AAdd( aLinha, { "D1_TOTAL"  , SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR - SD2->D2_VALDEV, Nil } )
            Else
			    AAdd( aLinha, { "D1_TOTAL"  , A410Arred(nSldDev*aLinha[3][2],"D1_TOTAL"), Nil } )
            EndIf

			AAdd( aLinha, { "D1_VALDESC", A410Arred(SD2->D2_DESCON/SD2->D2_QUANT*nSldDev,"D1_VALDESC"),Nil } )
			AAdd( aLinha, { "D1_ICMSRET", A410Arred(SD2->D2_ICMSRET/SD2->D2_QUANT*nSldDev,"D1_ICMSRET"),Nil } )
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a linha de devolucao que sera gerado o SD1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aLinha, { "D1_IPI"    , SD2->D2_IPI    , Nil } )
		AAdd( aLinha, { "D1_LOCAL"  , SD2->D2_LOCAL  , Nil } )
		AAdd( aLinha, { "D1_TES" 	, cTesDev , Nil } )
		AAdd( aLinha, { "D1_CF" 	, cCfOpF4 , Nil } )
		AAdd( aLinha, { "D1_UM"     , SD2->D2_UM , Nil } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe rastreabilidade              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Rastro(SD2->D2_COD)
		    AAdd( aLinha, { "D1_LOTECTL", SD2->D2_LOTECTL	, ".T." } )
		    AAdd( aLinha, { "D1_NUMLOTE", SD2->D2_NUMLOTE	, ".T." } )
		    AAdd( aLinha, { "D1_DTVALID", SD2->D2_DTVALID	, ".T." } )
		    AAdd( aLinha, { "D1_POTENCI", SD2->D2_POTENCI	, ".T." } )
		Else
		    AAdd( aLinha, { "", NIL	,  } )
		    AAdd( aLinha, { "", NIL	,  } )
		    AAdd( aLinha, { "", NIL	,  } )
		    AAdd( aLinha, { "", NIL	,  } )
		Endif
		
		If lWmsNew .AND. !Empty(SD2->D2_LOCALIZ)	//Somente se novo WMS para evitar errorlog, indepente se houver endereço ou não
		    AAdd( aLinha, { "D1_ENDER", SD2->D2_LOCALIZ	, Nil } )
		Else
		    AAdd( aLinha, { "", NIL	,  } )
		EndIf
		
		cFilDocOri := SD2->D2_FILIAL
		
		AAdd( aLinha, { "D1_FILORI",  cFilDocOri , Nil } )		
		AAdd( aLinha, { "D1_NFORI"  , SD2->D2_DOC    , Nil } )
		AAdd( aLinha, { "D1_SERIORI", SD2->D2_SERIE  , Nil } )
		AAdd( aLinha, { "D1_ITEMORI", SD2->D2_ITEM   , Nil } )		
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o TES eh de poder de terceiro       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF4->F4_PODER3=="D"
			AAdd( aLinha, { "D1_IDENTB6", SD2->D2_NUMSEQ, Nil } )
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para incluir campos adicionais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("LJ720LDV")
			LjGrvLog("TROCA_DEVOLUCAO","Antes da Chamada do Ponto de Entrada:LJ720LDV",{aLinha})
			aLinha := ExecBlock("LJ720LDV",.F.,.F.,{aLinha})
			LjGrvLog("TROCA_DEVOLUCAO","Apos a Chamada do Ponto de Entrada:LJ720LDV - aLinha",aLinha)
		Endif

		AAdd( aLinha, { "D1RECNO", SD2->(RECNO()), Nil } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona o item no array principal que sera levado para o Documento de entrada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aItens, aClone(aLinha) )
		
		aAdd( aLinha, { "DOCUMENTO", SD2->D2_DOC, NIL } )
		aAdd( aLinha, { "SERIE", SD2->D2_SERIE, NIL })
		
		aAdd(aItensOri, aClone(aLinha))
		
		AAdd( aRecnoSD2, { 	SD2->D2_DOC		,; //01 - D2_DOC
							SD2->D2_SERIE	,; //02 - D2_SERIE
							SD2->D2_ITEM	,; //03 - D2_ITEM
							aRecSD2[nPos][2],; //04 - Recno SD2
							cCodFil			,; //05 - Filial de Origem da venda
							SD2->D2_QTDEDEV	,; //06 - D2_QTDEDEV
							SD2->D2_VALDEV } ) //07 - D2_VALDEV

		cNotaOri  := SD2->D2_DOC
		cSerieOri := SD2->D2_SERIE

		If aScan( aNotasOri, { |d| d[1] == cNotaOri .AND. d[2] == cSerieOri} ) = 0
			aAdd(aNotasOri, { cNotaOri, cSerieOri})
		EndIf

		//---------------------------------------------------------------------------------------------
		// Acumula os valores de Frete, Seguro e Despesa proporcionalizada à quantidade a ser devolvida
		//---------------------------------------------------------------------------------------------
		If lDevFrete
			nFrete  	+= (SD2->D2_VALFRE  / SD2->D2_QUANT) * nSldDev
			nSeguro 	+= (SD2->D2_SEGURO  / SD2->D2_QUANT) * nSldDev
			nDespesa	+= (SD2->D2_DESPESA / SD2->D2_QUANT) * nSldDev
		EndIf
		nRetIcms		+= (SD2->D2_ICMSRET / SD2->D2_QUANT) * nSldDev
	Endif                          
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao ha saldo para devolucao nao pode continuar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	MsgInfo(STR0052 + SD2->D2_COD)//"Nao há saldo suficiente para realizar a devolução do produto:  "
	lRet:= .F.
EndIf

RestArea(aAreaSav)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720PedEc  ºAutor  ³ Vendas Cliente    º Data ³21/jan/2014º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de verificação de item de venda e-commerce          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static  Function Lj720PedEc(cPedOri, cOrcRes, cCodFil, lECCia)
Local aArea := GetArea()
Local lPedEC	:= .F. //Pedido e-commerce? 
Local cFilSL1	:= "" //Filial SL1
Local cFiltro	:= "" //Filtro L1_PEDRES
Local lEComm	:= SuperGetMV("MV_LJECOMM",,.F.) .AND. SL1->(ColumnPos("L1_ECFLAG") > 0)//e-commerce habilitado?
Local lCia	:=  SuperGetMV("MV_LJECOMO",,.F.) .AND. SC5->(ColumnPos("C5_PEDECOM")) > 0 
Local cNumOrc	:= "" 
Local aAreaSC5	:= {}

Default cPedOri := ""
Default cOrcRes := "" 
Default cCodFil 	:= cFilAnt													// Codigo da Filial
Default lECCia	:= .F. //e-commerce ciaShop

cFilSL1	:= FWxFilial("SL1",cCodFil) 
If lEComm

	If !Empty(cPedOri) //Devolução gerada por pedido de venda
		//Verifica se existe orçamento amarrado ao pedido
		// - filtra pelo pedido 
	        aAreaSL1	:= SL1->(GetArea())
	          	
		cFiltro :=  "L1_FILIAL =  '" + cFilSL1 + "' .AND. "+;
					"L1_PEDRES = '" + cPedOri   + "'  "
			
		SL1->(dbSetFilter({|| &cFiltro},cFiltro)) 
		SL1->(dbGoTop()) 
	
	   	If SL1->(!Eof()) 
	   		cOrcRes := SL1->L1_ORCRES
	   		cNumOrc := SL1->L1_NUM
	   	EndIf  
	   
	   	SL1->(dbClearFilter())   
	   	   
	   	If !Empty(cOrcRes) // Sem Pedido de Reserva
			RestArea(aAreaSL1) //ordem 1  
			SL1->(DbSetOrder(1)) 			
	    	lPedEC := SL1->(DbSeek(cFilSL1 + cOrcRes)) .AND. SL1->L1_ECFLAG == '1'
	    EndIf  
	    
	    If !lPedEC  .And. lCia .AND. !Empty(cNumOrc)
	    	//Verifica e-commerce ciaShop       
	    	aAreaSC5	:= SC5->(GetArea())
	    	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
	    	If SC5->(DbSeek(FWxFilial("SC5",cCodFil) + cPedOri))
	    		lECCia :=  !Empty(Val(SC5->C5_PEDECOM))
	    		lPedEC := lECCia
	    	EndIf
	    	RestArea(aAreaSC5)
	    EndIf
	
		RestArea(aAreaSL1)

	EndIf

EndIf 

RestArea(aArea)   

Return lPedEC

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720PosL2	 ºAutor ³ Varejo           º Data ³22/05/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para posicionar no registro da tabela SL2.      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720PosL2(cFil, cDoc, cSerie, cProd, cItem)
Local lRet		:= .F.

SL2->(DbSetOrder(3))

If SL2->(DbSeek(FWxFilial("SL2",cFil)+cSerie+cDoc+cProd))
	
	While SL2->(!EOF()) .And. FWxFilial("SL2",cFil)+cSerie+cDoc+cProd == SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC+SL2->L2_PRODUTO
	
		If SL2->L2_ITEM == cItem
			lRet := .T.
			Exit
		EndIf
		
		SL2->(DBSkip())
	End
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720GetQt  ºAutor  ³ Varejo            º Data ³07/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para atualizar a quantidade da garantia estendida   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720GetQt()
      
If ValType(lQtDeDev) == "U"
	lQtDeDev := SL2->(ColumnPos("L2_QTDEDEV")) > 0 .AND. SuperGetMv("MV_LJLIBGE",, .F.)
EndIf

Return lQtDeDev

//--------------------------------------------------------------------
/*/{Protheus.doc} Lj720IsFac
Função que verifica se existe um Factura Gerada para essa devolução

@cCodFil: código da Filial 
@cNota  : número da nota de origem da SF2
@cSerie : série da nota de origem da SF2
/*/
//--------------------------------------------------------------------
Static Function Lj720IsFac(cCodFil , cNota , cSerie )
Local lRet		:= .F.
Local cAliasSF2	:= "SF2TMP"
Local cFilSF2	:= FWxFilial("SF2",cCodFil)
Local cQuery	:= ""
Local aAreaSF2	:= SF2->(GetArea())

If Select(cAliasSF2) > 0
	(cAliasSF2)->(DbCloseArea())
EndIf

cQuery	:= " Select * "	
cQuery	+= " From " + RetSqlName("SF2")
cQuery	+= " Where "           
cQuery  += " D_E_L_E_T_ = '' and F2_FILIAL = '" + cFilSF2 + "' "
cQuery  += " and F2_NFORI = '" + cNota + "' and F2_SERIORI = '" + cSerie + "'"
cQuery  := ChangeQuery( cQuery )
DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSF2, .F., .T.)
DbGoTop()

While	!(cAliasSF2)->(Eof()) .And. !lRet
	If ((cAliasSF2)->(F2_FILIAL+F2_NFORI+F2_SERIORI) == (cFilSF2 + cNota + cSerie))
		lRet := .T.
	EndIf
	(cAliasSF2)->(DbSkip())
End
	
(cAliasSF2)->(DbCloseArea())

RestArea(aAreaSF2)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720SrvFin ºAutor  ³ Varejo            º Data ³22/04/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe Servico Financeiro Vinculado ao Produto º±±
±±           ³ vendido.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj720SrvFin(cCodFil)

Local aServFin	:= {}
Local cAliasSL2	:= GetNextAlias()
Local cQuery		:= ""

If Select(cAliasSL2) > 0
	(cAliasSL2)->(dbCloseArea())
EndIf

//Query para buscar servicos vinculados
cQuery	:= " SELECT L2_NUM, L2_ITEM, L2_PRODUTO "	
cQuery	+= " FROM " + RetSqlName("SL2") + " SL2"
cQuery	+= " INNER JOIN " + RetSqlName("MFI") + " MFI"
cQuery	+= " ON MFI_FILIAL =  '" + xFilial("MFI",cCodFil) + "'" 
cQuery	+= " AND MFI_FILORI = L2_FILIAL AND MFI_NUM = L2_NUM AND MFI_PRODUT = L2_PRODUTO AND MFI_ITEM = L2_ITEM"
cQuery	+= " WHERE L2_FILIAL = '" + xFilial("SL2",cCodFil) + "'"
cQuery += " AND L2_DOC = '" + SD2->D2_DOC + "'"
cQuery += " AND L2_SERIE = '" + SD2->D2_SERIE + "'"
cQuery += " AND L2_PDV = '" + SD2->D2_PDV + "'"	
cQuery += " AND L2_ITEMCOB = '" + SD2->D2_ITEMPV + "'"
cQuery += " AND L2_PRDCOBE = '" + SD2->D2_COD + "'"
cQuery += " AND MFI_SITGAR IN ('00', '01', '02', '03', '04')"
cQuery += " AND SL2.D_E_L_E_T_ = '' "
cQuery += " AND MFI.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSL2, .F., .T.)

(cAliasSL2)->(dbGoTop())

//Caso encontre servico vinculado, retorna .T.
While (cAliasSL2)->(!EOF())
	aAdd(aServFin, {(cAliasSL2)->L2_NUM,;
						(cAliasSL2)->L2_ITEM,;
						(cAliasSL2)->L2_PRODUTO})
	
	(cAliasSL2)->(dbSkip())	
EndDo

Return(aServFin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Lj720DevSF  ºAutor  ³ Varejo            º Data ³28/04/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera titulo financeiro contra Seguradora ou deleta registroº±±
±±           ³ Servico Financeiro na tabela MFI e estorna NCC do Servico  º±±
±±           ³ Financeiro se usuario cancelou a troca.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA720.PRW (SIGALOJA)                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj720DevSF(aServFin, aSE1Serv, cCodFil)

Local aArea 		:= GetArea() 			//Area atual para restaurar no final da funcao
Local aAreaSL1 	:= SL1->(GetArea())  //Armazena area SL1
Local aAreaMFI 	:= MFI->(GetArea())  //Armazena area MFI
Local aAreaSE1 	:= SE1->(GetArea())  //Armazena area SE1
Local aAreaSE2 	:= SE2->(GetArea())  //Armazena area SE2
Local nI 			:= 0
Local aE2Garant	:= {}					//Array Titulos a Pagar
Local lAltFil   := !(cCodFil == cFilAnt) //Alterou a Filial?
Local cFilBkp	:= cFilAnt		//Filial original
Local aAreaSM0  := {}			//WorkAreaSM0
Local aArea2		:= {}

PRIVATE lMsErroAuto := .F. 

SL1->(dbSetOrder(2))
MFI->(dbSetOrder(1)) //MFI_FILIAL+MFI_FILORI+MFI_NUM+MFI_PRODUT+MFI_ITEM
SE1->(	dbSetOrder(2)) 

//Varre array gerando titulos ou deletando MFI
For nI := 1 To Len(aServFin)
	If SL1->(dbSeek(xFilial("SL1",cCodFil) + aServFin[nI][2] + aServFin[nI][3]))
		If MFI->(dbSeek(xFilial("MFI", cCodFil) + aServFin[nI][1] + SL1->L1_NUM + aServFin[nI][4] + aServFin[nI][5]))
			/* Verifica se MFI ja enviado a Seguradora */
			
			//Se ainda nao enviou Servico Financeiro a Seguradora, apenas deleta
			If MFI->MFI_SITGAR == "04"
				MFI->(RecLock("MFI", .F.))
					MFI->(dbDelete())
				MFI->(MsUnlock())	
				
				//Deleta Titulo a Pagar Provisorio a Seguradora
				aE2Garant := {{"E2_PREFIXO"	, MFI->MFI_PREFIX	, Nil},;
				              {"E2_NUM"    	, MFI->MFI_TITULO	, Nil},;
				              {"E2_PARCELA"	, MFI->MFI_PARCEL	, Nil},;
				              {"E2_TIPO"	  	, MFI->MFI_TIPO	, Nil},;
				              {"E2_FORNECE"	, MFI->MFI_FORNEC	, Nil},;
				              {"E2_LOJA"   	, MFI->MFI_LJFORN	, Nil}}
				
				If lAltFil
					aAreaSM0 := SM0->(GetArea())
					aArea2 := GetArea()
					cFilBkp	:= cFilAnt
					cFilAnt := cCodFil
				EndIf
				//Efetua a delecao do Titulo a Receber 
				MsExecAuto({|x,y,z| FINA050(x,y,z)}, aE2Garant,, 5)  //3-Inclusao, 4-Alteracao, 5-Exclusao
				
				If lAltFil
					cFilAnt := cFilBkp
					RestArea(aAreaSM0)
					RestArea(aArea2)
				EndIf
			Else									   
			   //Gera NCP para a Loja contra a Seguradora
			   CriaTit(MFI->MFI_NUM, MFI->MFI_PREFIX,, SL1->L1_EMISNF,;
							aServFin[nI][6], MFI->MFI_ADMIN, MFI->MFI_LOJA, "UNI",,;
							"NCP", "NOTA DE CR", 0, "Lj720Devo")
				//Verifica se houveram erros
				If lMsErroAuto
				    MostraErro()
				Else
					MFI->(RecLock("MFI", .F.))
						MFI->MFI_SITGAR := "05"
					MFI->(MsUnlock())	
				EndIf   					    		   		   			
			EndIf
		EndIf
	EndIf
Next nI

//Restaura areas
RestArea(aAreaSL1)
RestArea(aAreaMFI)
RestArea(aAreaSE1)
RestArea(aAreaSE2)
RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LJModNFis ³ Autor ³ Venda Clientes        ³ Data ³22/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica recebimento por Modulo sem ECF					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Logico (.T. se modulo sem uso de ECF    		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja / SIGALOJA										  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJModNFis( )
Local lRet := (nModulo == 5 .OR. nModulo == 6) .OR.;	//Recebimento pelo Venda Direta
			 ((nModulo == 12 .OR. nModulo == 23) .AND. ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe())	//Recebimento pelo Loja/Front com NFC-e

Return lRet

//------------------------
/*/{Protheus.doc} LjNFeEntOk
Se a nota fiscal de entrada vai ser transmitida (formulário próprio e espécie SPED), 
validamos se ela possui uma nota fiscal de saída vinculada,
pois na NF-e v3.10, se a NF tem a finalidade de Devolução de Mercadoria, 
é obrigatório referenciar o documento de saída.
@type Static Function
@param cSerie , caracter , série da nota fiscal de entrada
@param lFormul , lógico ,  indica se é formulário próprio   
@param nNfOrig , numérico , indica a origem da nota de entrada (1-com documeto / 2-sem documento)
@author  Varejo
@version P11
@since   08/06/2015
@return  lRet - indica se a nota pode ser usada
/*/
//------------------------
Static Function LjNFeEntOk(cSerie, lFormul, nNfOrig , aLstTES)

Local cEspecie 	:= ""	//espécie da nota fiscal de entrada
Local lRet		:= .T.

Default cSerie  := ""	//série do documento de entrada
Default lFormul	:= .T.	//indica uso de Formulario Proprio
Default nNfOrig	:= 1	//indica origem 1-com documento / 2-sem documento
Default aLstTES := {}

If lFormul .AND. nNFOrig == 2
	
	cEspecie := AllTrim( LjEspecie(cSerie) )

	If cEspecie == 'SPED' .And. !Lj720VldCFOP(aLstTES)
		lRet := .F.
		Help( ,, "LJ720NFEDV",, STR0188, 1, 0 )	
		//"Na NF-e v3.10, uma nota fiscal com finalidade de devolução, deve ser vinculada a um documento de saída."		
	EndIf
	
EndIf

Return lRet

//------------------------
/*/{Protheus.doc} Lj720Com
Exibe a descricao e o codigo de barras do produto na tela de selecao dos
produtos a devolver

@param cDescPrd , caracter , Descricao do produto
@param cCodBar , caracter , codigo de barras do produto 
@param oDlgSelIte , objeto , objeto tela selecao produtos
@param oSayDesc , objeto , objeto descricao produto
@param oSayCodBar , objeto , objeto codigo de barras do produto 
@author  Gorgulho
@version P11
@since   18/08/2015
 
/*/
//------------------------
Static Function Lj720Com(cDescPrd, cCodBar, oDlgSelIte, oSayDesc, oSayCodBar )

cDescPrd := Alltrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"))

If !Empty(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CODBAR")) //Busca Codigo de Barras na SB1 					
	cCodBar := AllTrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CODBAR"))
ElseIf !Empty(Posicione("SLK", 2, xFilial("SLK") + Padr(SD2->D2_COD, TamSx3("LK_CODIGO")[1]), "LK_CODBAR")) //Busca Codigo de Barras na SLK 							
	cCodBar := AllTrim(Posicione("SLK", 2, xFilial("SLK") + Padr(SD2->D2_COD, TamSx3("LK_CODIGO")[1]), "LK_CODBAR"))			
Else
	cCodBar := "NAO CADASTRADO"
EndIf

oSayDesc:SetText(cDescPrd)      
oSayDesc:Refresh() 	
	     
oSayCodBar:SetText(cCodBar)                                                                                       
oSayCodBar:Refresh() 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720VerSFT
Rotina para Validacao de documento de saida para correta exibição da 
mensagem, caso o documento ja esteja cancelado ou nao foi encontrado.

@author Rene julian
@since 13/04/2016
@version P11
/*/
//-------------------------------------------------------------------

Static Function Lj720VerSFT( cCodCli  , cLojaCli , dDataDe   , dDataAte ,;
							 cCodFil  , cNumNF 	 , cSerieNF  , nFiltroPor ) 
							 
Local lRet := .F.  
Local aAreaSFT := SFT->(GetArea())
Local cTipoMov := PadR("S", TamSx3("FT_TIPOMOV")[1]) 
Local cChavSFT := ""

Default cCodCli := ""
Default cLojaCli := ""
Default dDataDe := dDataBase
Default dDataAte := dDataBase
Default cCodFil := xFilial("SFT")
Default cNumNF  := ""
Default cSerieNF := ""
Default nFiltroPor := 0

cCodFil := If(Empty(cCodFil), xFilial("SFT") , cCodFil )

DbSelectArea("SFT")
If !Empty(cNumNF) .And. !Empty(	cSerieNF) .And. nFiltroPor == 2 
	DbSetorder(6) //FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE
	If DbSeek(cCodFil+ cTipoMov + cNumNF + cSerieNF)
		lRet := .T.
	EndIf
Else
	DbSetorder(3) //FT_FILIAL+FT_TIPOMOV+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3
	If DbSeek(cCodFil+ cTipoMov + cCodCli + cLojaCli)
    	cChavSFT := cCodFil+ cTipoMov + cCodCli + cLojaCli
    	While !EOF() .And. cChavSFT == FT_FILIAL + FT_TIPOMOV + FT_CLIEFOR + FT_LOJA
    		If FT_EMISSAO >= dDataDe .And. FT_EMISSAO <= dDataAte
    			lRet := .T.
    			Exit
    		EndIf    	
    		DbSkip()
    	End
    EndIf	
EndIf						 

RestArea(aAreaSFT)							 
Return(lRet)							 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ Lj720L1Sit  ºAutor  ³ Vendas Cliente    º Data ³19/mai/2016º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de verificação se permite cancelar documento fiscal º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function Lj720L1Sit(cDocOri,cSerOri,cCodFil)

Local aArea 	:= GetArea()	//Área corrente
Local lNotaOk	:= .T. 			//Permite Cancelamento 
Local cFilSL1	:= "" 			//Filial SL1
Local aAreaSL1 	:= {}			//Área SL1
Local cAliasSL1	:= ""

Default cDocOri := ""			//Código do Orçamento
Default cSerOri := ""			//Série do Orçamento 
Default cCodFil	:= cFilAnt		//Codigo da Filial

cFilSL1	:= FWxFilial("SL1",cCodFil) 

If !Empty(cDocOri) //Devolução gerada por pedido de venda
	//Verifica se existe documento amarrado ao pedido
	// - filtra pelo documento
	aAreaSL1	:= SL1->(GetArea())
	          	
	cAliasSL1:= GetNextAlias()
	
	BeginSQL Alias cAliasSL1
		SELECT L1_SITUA, L1_STORC
		FROM %Table:SL1%
		WHERE	L1_FILIAL	= %Exp:cFilSL1%		AND
				L1_SERIE	= %Exp:cSerOri%		AND
				L1_DOC		= %Exp:cDocOri%		AND
				%NotDel%
	EndSQL

	//Valida se eh nota cancelada ja rejeitada e se pode cancelar
	If ( UPPER((cAliasSL1)->L1_SITUA) == "X3" .AND. Empty((cAliasSL1)->L1_STORC) )  
	
		lNotaOk := MsgNoYes( 	STR0198  + CRLF + CRLF + ; 	//"Houve uma tentativa de cancelamento deste documento, porém o mesmo não foi autorizado pela SEFAZ."
								STR0199 )    				//"Gostaria de prosseguir com a troca ou devolução?"
	
	//Se marcado como X0,X1,X2,X3 não efetuo o cancelamento no LOJA720
	ElseIf Left((cAliasSL1)->L1_SITUA,1) = "X"
		MsgStop(STR0196 + cDocOri + "/" + cSerOri + STR0197, STR0001)
				//"..." "Este documento "##" não pode ser devolvido/trocado, pois o mesmo foi solicitado para cancelamento no SEFAZ."##"Atenção!"
		lNotaOk := .F.
	EndIf
	
	RestArea(aAreaSL1)
EndIf

RestArea(aArea)   
Return lNotaOk

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720VldCFOP
Criada para validar se o CFOP da operação vai permitir operação 
de devolução sem documento de entrada baseado na Lei

" Se NF-e de devolução de mercadoria (tag:finNFe=4): – Não informado documento fiscal
  referenciado (NF-e, NFC-e, NF modelo 1, NF Produtor, ECF) Observação: não aplicar esta
  regra para os CFOP 1.201, 1.202, 1.410, 1.411, 5,921 e 6,921 (NT 2013/005 v 1.20) "

@type Function
@param aLstTES , array , lista de TES
@author Varejo
@since 12/08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function Lj720VldCFOP(aLstTES)
Local lRet		:= .F. //começo com Falso para não afetar a validação da especie
Local lContinua	:= .T.
Local nX		:= 0
Local aLstCFOP	:= {"1201","1202","1410","1411","5921","6921"}
Local aArea		:= {}

Default aLstTES := {}

If Len(aLstTES) > 0
	aArea := SF4->(GetArea())
	SF4->(DbSetOrder(1))
	
	For nX := 1 to Len(aLstTES)
		If lContinua .And. SF4->(DbSeek(xFilial("SF4")+aLstTES[nX]))		
			lContinua := Ascan(aLstCFOP , {|x| x == AllTrim(SF4->F4_CF) }) > 0 
		
			If !lContinua
				Loop
			EndIf
		EndIf
	Next nX
	
	lRet := lContinua
	RestArea(aArea)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720AllMark   ºAutor  ³ Vendas Cliente     º Data ³  16/08/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os dados do acols de acordo com os produtos       º±±
±±º          ³ selecionados na NF de origem.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Marca todos os produto ......                       º±±
±±º          ³ExpA2 - Array com os Recnos da tabela SD2                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA - VENDA ASSISTIDA                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj720AllMark( cMarca  ,aRecSd2, oMark, cCodFil )

While !("SD2")->(Eof())
	Lj720Mark(@cMarca,@aRecSD2,@oMark,cCodFil) 
	("SD2")->(DbSkip())
Enddo

("SD2")->(dbgotop())
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ720Pesq
Função responsável por filtrar produtos na tela de seleção de itens 
da venda para efetuar a troca ou devolução

@type Function
@param1	cProd		- informado pelo usuario codigo do produto / codigo de barras
@param2	cDescPrd	- descricao do produto
@param3	cCodBar		- codigo de barras
@param4	oSayDesc	- objeto que atualiza descricao do produto na tela
@param5 oSayCodBar	- objeto que atualiza o codigo de barras na tela
@author bruno.inoue
@since 14/02/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function LJ720Pesq(cProd,cDescPrd,cCodBar,oSayDesc,oSayCodBar)

Local lResult		:= .T. //Se encontrou algum registro

Default cProd		:= ""
Default cDescPrd	:= ""
Default cCodBar		:= ""
Default oSayDesc	:= Nil
Default oSayCodBar	:= Nil

SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
If !Empty(AllTrim(cProd))
	If !SD2->(DbSeek(xFilial("SD2") + cProd))
	
		lResult := .F.
		DbSelectArea("SB1")
		SB1->(DbSetOrder(5)) //B1_FILIAL+B1_CODBAR
		//Verifica se existe o registro na SB1
		If SB1->(DbSeek(xFilial("SB1") + cProd))
			If SD2->(DbSeek(xFilial("SD2") + SB1->B1_COD))
				lResult := .T.
			EndIf
		Else
			DbSelectArea("SLK")
			SLK->(DbSetOrder(1)) //LK_FILIAL+LK_CODBAR
			//Verifica se existe o registro na SLK
			If SLK->(DbSeek(xFilial("SLK") + cProd))
				If SD2->(DbSeek(xFilial("SD2") + SLK->LK_CODIGO))
					lResult := .T.	
				EndIf
			EndIf
		EndIf
		
		If !lResult
			/*Nenhum resultado encontrado.
			Verifique se a informação foi inserida corretamente e pesquise novamente.*/
			MsgAlert(STR0204 + CRLF + STR0205)
			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(DbGoTop())
		EndIf	
	EndIf	
	//Carrega exibição da descrição do produto e o código de barras no rodapé da tela 
	Lj720Com(@cDescPrd,@cCodBar, Nil, oSayDesc, oSayCodBar )
Else
	/*Informe alguma das informações abaixo para consulta:
	 - Código do Produto; 
	 - Código de Barras;*/ 
	MsgAlert(STR0206 + CRLF + STR0207 + CRLF + STR0208 )
	SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	SD2->(DbGoTop())				
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720Back
Função responsável para ajuste da variavel nVlrTotal quando se retorna para tela anterior,
quando existe acrescimo financeiro que esta sendo mostrado junto ao total.

@type Function
@param1	cAliasTRB	- Alias Temporario que os registros de troca/Devolução
@param2	nRecnoTRB	- Recno que esta posicionado para a tabela temporaria  
@param3	nVlrTotal	- Variavel de controle que possui o valor total da troca/devolução 

@author Rene Julian
@since 06/09/2018
@version P12117
/*/
//-------------------------------------------------------------------

Static Function Lj720Back(cAliasTRB,nRecnoTRB,nVlrTotal)
Local lRet 		  := .T.	// Variavel de retorno da função
Local lMVLJICMJR  :=SuperGetMv("MV_LJICMJR",,.F.) // parametro que verificar como vai incidir o acrescimo financeiro
Local aAreaTRB	  := (cAliasTRB)->(GetArea())	//Array para restauração da area   	

Default cAliasTRB := "" 
Default nVlrTotal := 0

LjGrvLog( "TROCA_DEVOLUCAO", "Lj720Back - Inicio da função" )

If lMVLJICMJR
	DbSelectArea(cAliasTRB)
	DbGoTo(nRecnoTRB)

	While !Eof()	
		nVlrTotal += TRB->TRB_VALACR 
		DbSkip()
	End 

	RestArea(aAreaTRB)
EndIf

LjGrvLog( "TROCA_DEVOLUCAO", "Lj720Back - fim da função" )

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720MultN
Função responsável para verificar se no orçamento foi utilizado pagamento com 
Multi Negociação. Necessario para ajuste das compesensações.
financeiro calcula o Desconto e acrescimo com isso sobra valores na baixa.

@type Function
@param1	cCodFil	  - Filial de origem do documento de devolução
@param2	cPrefixo  - Serie da nota de venda   
@param3	cNumTit	  - Numero do documento da venda
@param4	aNCC	  - Array com os Recnos dos registros de NCC do financeiro

@author Rene Julian
@since 08/09/2018
@version P12117
/*/
//-------------------------------------------------------------------

Static Function Lj720MultN (cCodFil ,cPrefixo , cNumTit , aNCC )
Local lRet 		:= .F.	// Variavel de controle de retorno da função
Local cFilSE1 	:= FWxFilial("SE1",cCodFil)
Local cFilOri	:= ""	//Filial de origem do documento de devolução
Local aAreaSL1	:= SL1->( GetArea() )	// Guarda area de origem do SL1 
Local aAreaSE1	:= SL1->( GetArea() )	// Guarda area de origem do SE1  
Local nValDev	:= 0	//variavel de controle do valor das devoluções
Local nX		:= 0	//variavel de controle do For

Default cPrefixo	:= ""	//Serie da nota de venda
Default cNumTit		:= ""	//Numero do documento da venda
Default aNCC		:= {}	// Array com os Titulos de ncc

LjGrvLog( "TROCA_DEVOLUCAO", "Lj720MultN - Inicio da função.")

If !Empty(cPrefixo) .And. !Empty(cNumTit)
	
	SE1->( DbSetOrder(1) ) //E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	If SE1->( DbSeek(cFilSE1 + cPrefixo + cNumTit) )	
				
		cFilOri := SE1->E1_FILORIG  // pego o E1_FILORIG pois a SE1 pode estar compartilhada
		
		SL1->(DbSetorder(2)) // Vejo se na venda foi utilizado Multi Negociação
		If SL1->(DbSeek(cFilOri + cPrefixo + cNumTit ))  // L1_FILIAL + L1_SERIE + L1_DOC
			If !Empty(SL1->L1_CODMNEG)
				lRet := .T.
			EndIf
		EndIf		
		
		LjGrvLog( "TROCA_DEVOLUCAO", "Lj720MultN - Valor do lRet: ", lRet )
						
		If lRet
			// Saldo Total das NCCs usadas
			For nX := 1 to Len(aNCC)
				SE1->(DbGoTo(aNCC[nX]))
				nValDev += SE1->E1_SALDO
			Next nX
			
			LjGrvLog( "TROCA_DEVOLUCAO", "Lj720MultN - Valor do nValDev: ", nValDev )
			
			SE1->( DbSeek(cFilSE1 + cPrefixo + cNumTit) ) //posiciono novmante nos titulos  
			While SE1->(!Eof()) .AND. SE1->E1_FILIAL	== cFilSE1 		.AND.;
									  SE1->E1_PREFIXO	== cPrefixo 	.AND.;
									  SE1->E1_NUM		== cNumTit
				
				If SE1->E1_SALDO > 0 .And. (nValDev >= SE1->E1_VLRREAL  .Or.   ;	// verifico o valor real pois esse esta sem o desconto de taxa 
					 ((SE1->E1_VLRREAL - nValDev) / SE1->E1_VLRREAL) * 100 < 50 )  // Se oabatimento for maior que 50% zero tambem.
					
					RecLock( "SE1", .F. )					
					Replace SE1->E1_ACRESC With 0    
					Replace SE1->E1_SDACRES With 0
					Replace SE1->E1_DESCONT With 0
					Replace SE1->E1_DESCFIN With 0
					MsUnLock()
					
					nValDev := nValDev - SE1->E1_VLRREAL				
				EndIf	
				SE1->(DbSkip())						
			End
			LjGrvLog( "TROCA_DEVOLUCAO", "Lj720MultN - Apos while Valor do nValDev: ", nValDev )						
		EndIf
		RestArea(aAreaSL1)
		RestArea(aAreaSE1)
	EndIf	
EndIf

LjGrvLog( "TROCA_DEVOLUCAO", "Lj720MultN - Fim da função " )
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ720CBNCC
Gera o codigo de barras da NCC

@type 		Function
@author 	Alberto Deviciente
@since 		12/12/2018
@version 	P12.1.17

@param		nRecnoSE1, Numérico, Recno da tabela do titulo na tabela SE1

@return  	Caracter, código de barras da NCC
/*/
//-------------------------------------------------------------------
Function LJ720CBNCC(nRecnoSE1)

Local aArea    		:= GetArea()
Local aAreaSE1    	:= SE1->(GetArea())
Local nX	 		:= 0
Local cCaracter 	:= ""
Local cPrefixo 		:= ""
Local cNumero 		:= ""
Local cCodBar		:= ""				// Codigo de barras a ser impresso
Local cCodASC		:= "" 				// Codigo da tabela ASCII correspondente ao digito do prefixo

If !Empty(nRecnoSE1)

	//Posiciona do Recno caso ainda nao esteja posicionado
	If nRecnoSE1 <> SE1->(Recno())
		SE1->(DbGoTo(nRecnoSE1))
	EndIf

	If !SE1->(EoF()) //Verifica se posicionou em um registro valido
		
		// Converte os caracteres do PREFIXO para código da tabela ASCII, pois neste codigo de barras deve ter apenas numeros
		For nX:=1 To Len(SE1->E1_PREFIXO)
			cCaracter 	:= SubStr(SE1->E1_PREFIXO,nX,1)
			cCodASC		:= AllTrim(Str(Asc(cCaracter))) //Converte cada digito em código da tabela ASCII
			cCodASC		:= PadL(cCodASC,2,"0")
			cPrefixo  	+= cCodASC
		Next nX
		
		cNumero += AllTrim(SE1->E1_NUM)

		cCodBar := cPrefixo + cNumero

		//Precisou embaralhar para evitar fraudes
		cCodBar := Embaralha( cCodBar,0 )

	EndIf

EndIf

RestArea(aAreaSE1)
RestArea(aArea)

Return cCodBar

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ720GetPd
Retorna o valor das variaveis cCdFl, cCdCli e cCdLj

@type 		Function
@author 	Bruno Almeida
@since 		03/06/2019
@version 	P12
@param		
@return  	cCdFl, codigo da filial
@return  	cCdCli, codigo do cliente
@return  	cCdLj, codigo da loja
/*/
//-------------------------------------------------------------------
Function LJ720GetPd()
Return {cCdFl,cCdCli,cCdLj}

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ720NfsFt
Exibe mensagem para devolução da nota de Simples Faturamento ou Simples Remesa

@type 		Function
@author 	João Marcos Martins
@since 		10/07/2019
@version 	P12
@param	cTesNfsF,	TES de Simpres Faturamento
		cTesNfsR,	TES de Simples Remesa
		TES,		TES utilizado na venda	
/*/
//-------------------------------------------------------------------
Function LJ720NfsFt( cTesNfsF, cTesNfsR, cTES )

If cTES == cTesNfsF
	MsgInfo( STR0229 + CTRL + STR0230 ) //"Devolução de nota de Simples Faturamento"###"Posteriormente efetuar a devolução da nota de Simples Remessa referente a esta venda."
ElseIf cTES == cTesNfsR
	MsgInfo( STR0231 + CTRL + STR0232 ) // "Devolução de nota de Simples Remessa"###"Posteriormente efetuar a devolução da nota de Simples Faturamento referente a esta venda."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720CdBar
Função responsavel pela geração / separação do codigo de barras do vale troca. 

@author  	Lucas Novais
@version 	P12.1.25
@since   	24/03/2020
@param   	cDoc, Caracter, Documento utilizada na montagem do codigo de barras
@param   	cSerie, Caracter, Serie utilizada na montagem do codigo de barras
@param   	cItem, Caracter, Item utilizada na montagem do codigo de barras
@param   	cCodeBar, Caracter, Codigo de barras a ser "separado" (Caso esse parametro esteja alimentado é feita apenas a separação do codigo de barras)
@return		Array, Retorna os dados para busca ou o codigo de barras (o Retorno depende parametro cCodeBar)		  
/*/
//-------------------------------------------------------------------

Function Lj720CdBar(cDoc, cSerie, cItem, cCodeBar)
Local cFil			:= cFilAnt	// -- Filial para geração do Codigo de Barras
Local nLenFil		:= 0		// -- Quantidade de caracter da filial
Local cCodBFil		:= ""		// -- Variavel Auxiliar para Gravar o filial
Local nLenDoc		:= 0		// -- Quantidade de caracter do Doc
Local cCodBDoc		:= ""		// -- Variavel Auxiliar para Gravar o Doc
Local nLenSerie		:= 0		// -- Quantidade de caracter da Serie
Local cCodBSerie	:= ""		// -- Variavel Auxiliar para Gravar a Serie
Local nLenItem		:= 4		// -- Quantidade de caracter do Item
Local cCodBItem		:= ""		// -- Variavel Auxiliar para Gravar a Item	
Local nPonteiro		:= 0		// -- Variavel que indica o ponto inicial(Atual) da leito
Local aDados		:= {}		// -- Array utilizado na converção de Caracter para ASC / ASC para Caracter 	
Local cCaracter		:= ""		// -- Variavel utilizado na converção de Caracter para ASC / ASC para Caracter	
Local cCodAscChr	:= ""		// -- Variavel utilizado na converção de Caracter para ASC / ASC para Caracter
Local nX			:= 0		// -- Variavel de controle para For
Local nY			:= 0		// -- Variavel de controle para For

Default cDoc		:= ""	// -- Doc para geração do Codigo de Barras
Default cSerie		:= ""	// -- Serie para geração do Codigo de Barras
Default cItem		:= ""	// -- Item para geração do Codigo de Barras
Default cCodeBar	:= ""	// -- Codigo de barras

If !Empty(cCodeBar) 
	
	// -- Indica que é necessario desfazer o codigo
	nLenFil 	:= Val(SubSTR(cCodeBar,1,1))
	nPonteiro	:= 1 + 1 // -- 1 é o Salto Inicial, 1 Representa o separador
	cCodBFil	:= SubSTR(cCodeBar,nPonteiro,nLenFil)
	nPonteiro	+= nLenFil 

	nLenDoc		:= Val(SubSTR(cCodeBar,nPonteiro,1))
	nPonteiro 	+= 1 // -- 1 representa um salto da posição que indica a quantidade de  posições que tera o doc
	cCodBDoc	:= RIGHT(SubSTR(cCodeBar,nPonteiro,9),nLenDoc) // -- 9 é o tamanho fixo do DOC
	nPonteiro 	+= 9 // -- Acrescento as posições que representam o DOC	

	nLenSerie	:= Val(SubSTR(cCodeBar,nPonteiro,1))
	nPonteiro 	+= 1 // -- 1 representa um salto da posição que indica a quantidade de  posições que tera o Serie
	cCodBSerie	:= RIGHT(SubSTR(cCodeBar,nPonteiro,6),nLenSerie) // -- 3 é o tamanho fixo da Serie
	nPonteiro 	+= 6 // -- Acrescento as posições que representam o Serie		

	cCodBItem	:= SubSTR(cCodeBar,nPonteiro,nLenItem)
	
	aDados := {{"Filial","",cCodBFil},{"Serie","",cCodBSerie},{"Item","",cCodBItem}}
	
	For nX  := 1 To Len(aDados)
		For  nY := 1  To Len(aDados[nX][3]) STEP 2 // -- os caracter de 2 em dois para transformar em CHR (Caracter)
			cCaracter 		:= SubStr(aDados[nX][3],nY,2)
			cCodAscChr		:= CHR(Val(cCaracter)) // -- Converte o conjunto de 2 digito em código da tabela Char
			aDados[nX][2]	+= cCodAscChr
		Next
	Next

	cFil 		:= aDados[1][2]
	cSerie		:= aDados[2][2]
	cItem		:= aDados[3][2]
	cDoc		:= cCodBDoc

Else 
	If Len(cFil) > 0 .AND. Len(cDoc) > 0 .AND. Len(cSerie) > 0 .AND. Len(cItem) > 0
		
		cDoc 	:= AllTrim(cDoc)
		cSerie 	:= AllTrim(cSerie)
		cItem 	:= AllTrim(cItem)
	
		
		aDados := {{"Filial",cFil,""},{"Serie",cSerie,""},{"Item",cItem,""}}

		For nX  := 1 To Len(aDados)
			For  nY := 1  To Len(aDados[nX][2])
				cCaracter 		:= SubStr(aDados[nX][2],nY,1)
				cCodAscChr		:= AllTrim(Str(ASC(cCaracter))) //Converte cada digito em código da tabela ASCII
				aDados[nX][3]	+= cCodAscChr
			Next
		Next 

		// -- Limite maximo da filial é 6(12 Posições com o ASCII)
		If Len(aDados[1][3]) > 8
			cFil 	:= SubSTR(aDados[1][3],1,8)
		Else
			cFil 	:= aDados[1][3]	
		EndIf 

		cSerie	:= aDados[2][3]
		cItem	:= aDados[3][3]

		cCodeBar 	:= AllTrim(STR(Len(cFil))) + cFil + AllTrim(STR(Len(cDoc))) + PadL(cDoc,9,"0") + AllTrim(STR(Len(cSerie))) + PadL(cSerie,6,"0") + SubSTR(cItem,1,4)

	EndIf
Endif 

Return {cFil, cDoc, cSerie, cItem, cCodeBar}




//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720AtrCm
Função responsavel pelo armazenamento do array aComissoes, 
somando sua base de comissão para cada vendedor

@author  	marisa.cruz
@version 	P12.1.27
@since   	30/10/2020
@param   	aComissoes, Array, Conteúdo integral de Comissões (Parâmetro de Referência)
@param   	cVendedor, Caracter, Código do Vendedor
@param   	nBaseComis, Numérico, Total da Base de Comissão por Vendedor
@return		nil
/*/
//-------------------------------------------------------------------
Static Function Lj720AtrCm(aComissoes,cVendedor,nBaseComis)

Local nPos  := 0

Default aComissoes := {}
Default nBaseComis := 0
Default cVendedor  := ""

nPos := aScan( aComissoes, { |x| x[1] == cVendedor } )

If nPos > 0
	aComissoes[nPos][2] += nBaseComis
Else
	aAdd( aComissoes, { cVendedor	,; 	//01-Codigo do Vendedor
						nBaseComis	,; 	//02-Valor Base para Calculo da Comissao
						0			,; 	//03-Qtd. Parcelas geradas na Comissao
						{} 			} ) //04-Recnos da tabela SE3
EndIf

LjGrvLog( "TROCA_DEVOLUCAO", "Comissao - aComissoes", aComissoes)

Return nil



//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720Sc6
Função responsavel pela soma dos totais dos pedidos da tabela SC6.
Se utilizou Venda Assistida com entrega futura, somar os valores na tabela SC6.
Caso for realizado eliminação de resíduo, teremos a visão pela tabela SC6.

@author  	marisa.cruz
@version 	P12.1.27
@since   	04/11/2020
@param   	cTpComiss, Caracter, Tipo de Comissão. 1=por total, 2=por item
@param   	cVendedor, Caracter, Código do Vendedor
@param   	cFilPed, Caracter, Filial do Número do Pedido
@param   	cNumPed, Caracter, Número do Pedido
@param   	cItemPed, Caracter, Número do Item Pedido (para Doc. Fiscal SD2 encontrado e nTpComiss = "2")
@param   	cProduto, Caracter, Código do Produto (para Doc. Fiscal SD2 encontrado e nTpComiss = "2")
@param   	cOrcNum, Caracter, Número do Orçamento do Venda Assistida (para Doc. Fiscal SD2 encontrado e nTpComiss = "2")
@return		aRet, Array,  {cVendItem, Caracter, Código do Vendedor},;
                          {nValTotPed, Numérico, o valor total do pedido}
                         
/*/
//-------------------------------------------------------------------
Static Function Lj720Sc6(cTpComiss, cVendedor, cFilPed, cNumPed,;
							 cItemPed, cProduto, cOrcNum)

Local nPos       := 0
Local nValItPed  := 0
Local cVendItem	 := ""
Local cArea      := GetArea()
Local aRet       := {}

Default cTpComiss 	:= 1
Default cVendedor   := ""
Default cFilPed 	:= xFilial("SC6")
Default cNumPed 	:= ""
Default cItemPed	:= ""
Default cProduto	:= ""			//Se cItemPed e cProduto preenchidos, pesquisa somente por aquele item em vez de varrer todos os itens SC6 de uma SC5
Default cOrcNum		:= ""

DbSelectArea("SL2")
SL2->(DbSetOrder(1)) 	//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO

DbSelectArea("SC6")
SC6->(DbSetOrder(1))	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO


If SC6->(DbSeek(FWxFilial("SC6",cFilPed)+cNumPed + Iif(!Empty(cItemPed+cProduto),cItemPed+cProduto,"")))
	While !(SC6->(Eof())) .AND.;
		SC6->C6_FILIAL == FWxFilial("SC6",cFilPed) .AND.;
		SC6->C6_NUM == cNumPed .AND.;
		 Iif(!Empty(cItemPed+cProduto),;
		 SC6->C6_ITEM == cItemPed .AND. SC6->C6_PRODUTO == cProduto, .T.)	//Este IIF é para quem veio do SD2 encontrado junto com cTpComiss = "2"

		nValItPed := 0

		If cTpComiss == "2"
			//Localizo o vendedor correspondente. Tanto que a ordem de items da SL2 é o mesmo que da SC6
			If SL2->(DbSeek(FWxFilial("SL2",cFilPed)+cOrcNum+cItemPed))
				If !Empty(SL2->L2_VEND)		
					cVendItem := SL2->L2_VEND
				Else
					cVendItem := cVendedor
				EndIf
			EndIf
		EndIf
		If Empty(cVendItem)
			cVendItem := cVendedor
		EndIf

		//Desconto, Desc ZF e Acréscimo já inclusos nos preços da C6 e D2
		IF SC6->C6_BLQ = "R"		//Se feito a Eliminação de Resíduo, é feito pelo total entregue
			nValItPed += (SC6->C6_QTDENT * SC6->C6_PRCVEN)
		Else
			nValItPed += SC6->C6_VALOR
		EndIf

		nPos := Ascan(aRet, { |x| x[1] == cVendItem } )
		If nPos = 0					
			aAdd( aRet, {cVendItem, nValItPed})
		Else
			aRet[nPos,2] += nValItPed
		EndIf

		SC6->(DbSkip())
	EndDo
EndIf

RestArea(cArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSldDev
Retorna o saldo a devolver por item a patir da SD2 posicionada.

@author  Rafael Tenorio da Costa
@since 	 11/12/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSldDev()

    Local nSaldoDev := 0
    Local nDesconto := ( ( SD2->D2_QTDEDEV * (SD2->D2_DESCON / SD2->D2_QUANT) ) + ( SD2->D2_QTDEDEV * (SD2->D2_DESCZFR / SD2->D2_QUANT) ) )

    //Tira o desconto do saldo a devolver, porque ele não é considerado quando é salvo o campo D2_VALDEV
    nSaldoDev := SD2->D2_VALDEV - A410Arred(nDesconto, "D2_DESCON")

Return nSaldoDev

//-------------------------------------------------------------------
/*/{Protheus.doc} CancFideli
Efetua o cancelamento da fidelização (TOTVS Fidelity Core), quando a nota de saida for totalmente devolvida.

@param  cFilSD2, Caractere, Filial da SD2
@param  aDocOri, Array, Com os dados das notas de saída devolvidas

@author  Rafael Tenorio da Costa
@since 	 11/12/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CancFideli(cFilSD2, aDocOri)

    Local aArea      := GetArea()
    Local aAreaSL1   := SL1->( GetArea() )
    Local nCont      := 0
    Local aAuxDocOri := aClone(aDocOri)

    //Ordernar do maior para o menor valor 
    Asort(aAuxDocOri, , , { | x,y | x[6] > y[6] } )

    For nCont:=1 To Len(aAuxDocOri)

		SL1->( dbSetOrder(2) )  //L1_FILIAL + L1_SERIE + L1_DOC + L1_PDV 
		If SL1->( dbSeek(cFilSD2 + aAuxDocOri[nCont][2] + aAuxDocOri[nCont][1]) ) .And. SL1->L1_FIDCORE
			Lj7FidCanc(SL1->L1_FILIAL + SL1->L1_NUM, SL1->L1_ESTACAO)
		EndIf

    Next nCont

    RestArea(aAreaSL1)
    RestArea(aArea)

Return Nil
