#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA272A.CH"
#INCLUDE "AUTODEF.CH"			// AUTOCOM
#INCLUDE "FRTDEF.CH"


#DEFINE AIT_COD			     	2
#DEFINE AIT_CODBAR				3
#DEFINE AIT_CANCELADO			11
#DEFINE _FORMATEF				"CC;CD"     // Formas de pagamento que utilizam operação TEF para validação

STATIC nVlrDescBkp  := 0
STATIC lLjDesPa		:= SuperGetMv("MV_LJDESPA",,.F.)				// Habilita desconto por Adm e banco
STATIC cBkDesAdm	:= ""										    // Backup adm
STATIC cBkPar		:= ""											// Backup Pacela
STATIC cFormTroco   := ""											// Forma de Pagamento que será usada no Troco
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FRTA272A  ºAutor  ³Vendas Clientes     º Data ³  05/24/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface remote do Front-Loja                              º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRT272( 	nRPCInt		, cImpressora	, cCliente		, cLojaCli		,;
				 	cVendLoja	, lOcioso		, lRecebe		, lLocked 		,;
				 	lCXAberto	, lDescIT		, lDescITReg	, aTefDados		,;
				 	dDataCN		, nVlrFSD		, nVlrDescTot	, aMoeda		,;
					aSimbs		, cPorta		, cSimbCheq		, cEstacao		,;
					lTouch		, cTipoCli		, cVndLjAlt		, aRegTEF		,;
					lRecarEfet	, lCancItRec    , aVidaLinkD	, aVidaLinkC   	,;
					nVidalink	, lFRTAuto )

Local oDlgFRT
Local oDoc
Local oHora 						// Objeto com o relogio exibido na tela
Local oTimer						// Objeto de evento (de tempos em tempos o evento e ativado) do TIME do relogio.
Local oPDV
Local oOnOffLine
Local oMoedaCor
Local oTaxaMoeda
Local oTemp3
Local oTemp4
Local oTemp5
Local oQuant
Local oUnidade
Local oTmpQuant
Local oVlrUnit
Local oVlrItem
Local oTotItens
Local oVlrTotal
Local oFotoProd
Local oDesconto
Local oFntCupom
Local oFntInf
Local oFntGet
Local oFntQuant
Local oFntTotal
Local oFntLoc
Local oFntMoeda
Local oProduto
Local oCodProd
Local oCupom
Local oLogoEmp
Local oTemp1
Local oTemp2											// Variaveis Para Utilizar Fundo Sem Transparencia
Local oMensagem
Local oPgtos											// Objeto exibido de forma de oagamento analítica
Local oPgtosSint										// Objeto com exibicao da forma de pagamento sintetizada
Local cCodProd 		:= ""
Local cOrcam 		:= ""
Local cCaixa		:= ""
Local cProduto 		:= ""
Local cUnidade 		:= ""
Local cEntrega 		:= ""								//1=Retira Posterior; 2=Retira; 3=Entrega
Local aReserva		:= {}
Local lReserva		:= .F.
Local lAbreCup		:= .F.

Local nValor		:= 0
Local cCupom 		:= ""
Local cMoeda    	:= ""
Local cSimbCor  	:= AllTrim(SuperGetMV("MV_SIMB1"))
Local cPDV 			:= ""
Local cHora			:= ""					// Variavel com o conteudo do relogio
Local cDoc 			:= ""
Local cNumDAV		:= ""					// Numero do documento auxiliar de venda
Local nTaxaMoeda	:= 1
Local nQuant 		:= 0
Local nTmpQuant 	:= 0
Local nVlrUnit 		:= 0					// Variavel com o conteudo do valor unitario
Local nVlrItem 		:= 0					// Variavel com o conteudo do valor do item
Local nTotItens 	:= 0					// Variavel com o conteudo do total dos itens
Local nVlrTotal 	:= 0					// Variavel com o conteudo do valor total
Local nVlrPercIT 	:= 0					// Percentual de Desconto no item
Local nVlrDescIT    := 0					// Valor do Desconto no item
Local nValIPI 		:= 0					// Variavel com o conteudo do valor do IPI
Local nValIPIIT 	:= 0
Local cMensagem  	:= STR0001	// "   Protheus Front Loja"
Local aCupom		:= {"","","","","","","","","","","","","","","","","",""}
Local lF7			:= .F.
Local _lOK			:= .F.
Local bQtdLostFoc 	:= {|| Nil}
Local bCodLostFoc 	:= {|| Nil}
Local bCodGotFoc  	:= {|| Nil}
Local aKeyAux 		:= {}
Local lFrtGetPr		:= ExistBlock("FRTGETPR")			// Ponto de Entrada no bLostFocus do Get do Produto
Local aPgtos		:= {}								//Array do objeto oPgtos
Local aPgtosSint	:= {}								//Array do objeto oPgtosSint
Local lTefPendCS  	:= .F.								// Controla se existe TEF Pendente da CLISITEF
Local aTefBKPCS     := {}								// Guarda a transacao TEF Pendente da CLISITEF
Local cNCartao      := ""								// Numeracao do Cartao do cliente
Local cCodDEP 		:= ""								// Codigo do DPEPENDENTE
Local cNomeDEP		:= ""		   						// Nome de DEPENDENTE
Local nLastItem		:= 0
Local nLastTotal	:= 0
Local nVlrBruto		:= 0
Local aItens		:= {}
Local aICMS			:= {}
Local nVlrMerc 		:= 0
Local _aMult		:= {}
Local _aMultCanc	:= {}
Local lOrc			:= .F.
Local lEsc         	:= .F.
Local aParcOrc		:= {}
Local cItemCOrc		:= ""
Local aParcOrcOld  	:= {}
Local aKeyFimVenda 	:= {}
Local nHdlOPE
Local lExitNow		:= .F.								// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
Local lAltVend		:= .F.
Local lImpNewIT		:= .F.								// Indica se foi adicionado um novo item ao orcamento
Local lFechaCup 	:= .T.								// Indica se houve algum erro no fechamento do CF
Local aTpAdmsTmp   	:= {}
Local cUsrSessionID	:= ""								// Variavel para login na transacao Web Service
Local cContrato 	:= ""	           					// Numero do contrato da transacao de credito
Local aCrdCliente  	:= {"",""}     						// Informacao do cliente p/Private Label [1]-CNPJ/CPF [2]-Numero do Cartao Private Label
Local aContratos   	:= {}          						// Numero de contrato gerado pela venda. Utilizado nos casos em que deve cancelar o contrato pendente
Local aRecCrd		:= {}								// Guarda as parcelas de financiamento para impressao do comprovante de recebimento
Local aValePre		:= {}								// Array com os vale presentes que serão usados no recebimento da venda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aTEFPend          ³
//³[1] Forma de pagamento(CC, CD)       ³
//³[2] ID + Administradora              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTEFPend 		:= {}             					// Parcelas que estao pendentes no TEF multiplas transacoes. Esta situacao ocorre quando a segunda eh rejeitada, por ex.
Local aBckTEFMult  	:= {}
Local lVerTEFPend  	:= .F.         						// Controla se deve verificar se ha transacao TEF pendente ao final da venda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   83E83E¿
//³                                                                                                                 ³
//³                                                O B S E R V A C A O                                              ³
//³*****************************************************************************************************************³
//³ - A variável uCliTPL foi criada para ser utilizada pela equipe de Templates. Ela poderá receber, como retorno   ³
//³ da Template Function "FRT010CL", qualquer tipo de valor. O tratamento da variável deverá ser realizado          ³
//³ nas rotinas específicas do depto. de Templates.                                                                 ³
//³                                                                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   Ù

Local uCliTPL
Local uProdTPL	//armazena informacoes referente aos produtos que estao sendo vendidos.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Static de Templates. Codigo e loja do conveniado, utilizadas para implementacao de convenio    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCodConv     	:= ""	// codigo do cliente conveniado
Local cLojConv     	:= ""	// loja do conveniado
Local cNumCartConv 	:= ""	// numeracao do cartao do cliente conveniado

Local lDescTotal	:= .F.						// Valida de foi dado desconto no total do cupom, caso seja concomitante
Local lDescSE4		:= .F.						// Valida de foi dado desconto na condicao de pagamento
Local cCdPgtoOrc   	:= ""						// Condicao de pagamento
Local cCdDescOrc   	:= ""						// Descricao condicao de pagamento
Local nValTPis		:= 0						// Valor total do PIS
Local nValTCof		:= 0						// Valor total do COFINS
Local nValTCsl		:= 0						// Valor total do CSLL
Local lOrigOrcam	:= .F.						// Origem da Condicao de Pagamento
Local nTotDedIcms  	:= 0                     	// Total de deducao do ICMS
Local lImpOrc		:= .F.                    	// Controla se o orcamento foi importado da Retaguarda
Local lResume		:= .F.						// Retoma a Venda do Ponto em Que Parou


Local nVlrPercTot	:= 0						// PERCENTUAL DE DESCONTO
Local nVlrPercAcr	:= 0						// PERCENTUAL DE ACRESCIMO
Local nVlrAcreTot	:= 0						// VALOR DO ACRESCIMO
Local nVlrDescCPg	:= 0						// VALOR DO DESCONTO CONCEDIDO VIA CONDICAO DE PAGAMENTO (SE4)
Local nVlrPercOri 	:= 0                      	// PERCENTUAL DE DESCONTO ORIGINAL
Local nQtdeItOri  	:= 0						// QTDE ORIGINAL DE ITENS DA VENDA
Local nNumParcs   	:= 0                       	// NUMERO DE PARCELAS
Local nMoedaCor  	:= 1
Local nDecimais  	:= MsDecimais(nMoedaCor)

//Estas variaveis contem, respectivamente, o numero do cartao, cpf ou contrato, informados na tela de recebimentos
//no LOJXREC.
Local cRecCart   	:= ""
Local cRecCPF    	:= ""
Local cRecCont   	:= ""
Local aImpsSL1  	:= {}
Local aImpsSL2  	:= {}
Local aImpsProd	 	:= {}   //Array original com as mesmas informacoes do aImpsSL2. Usado para os recalculos.
Local aImpVarDup	:= {}
Local aTotVen   	:= {}
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis de Localizacoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCalcImpV		:= SuperGetMV("MV_GERIMPV")
Local nTotalAcrs 	:= 0
Local lTroca 	 	:= .F.
Local lValTot  		:= SuperGetMV("MV_VALTOTA")  	//Verifica se valida ou nao o total da fatura com o que foi pago
Local lRecalImp		:= .F.                  			//Verifica se foi recalculado os impostos devido
Local aCols     	:= {}
Local aHeader   	:= {}
Local aDadosJur 	:= {0,0,0,0,0,0,0,0,0}
Local aCProva   	:= {}
//a um desconto ou acrescimo

Local lBalanca
Local aNCCItens  	:= {}
Local aFormCtrl	 	:= {}						//Controle das Formas de Pagamento Solicitadas

Local nTroco2		:= 0							//Armazena o valor do troco que devera ser gravado em L1_TROCO1,													//Para geracao de movimentacao bancaria local e na retaguarda
Local nTroco		:= 0
Local lDescCond		:= .F.
Local nDesconto		:= 0
Local aDadosCH		:= {}
Local cItemCond	 	:= "CN"
Local lCondNegF5	:= .F.
//Indica que o desconto deve ser rateado nas parcelas, pois o
//valor final foi "descoberto" apos selecionar a Condicao de Pagto.
Local lDiaFixo		:= .F.
Local nTxJuros	 	:= 0
Local nValorBase	:= 0
Local aTefMult		:= {}
Local aTitulo		:= {}
Local lConfLJRec	:= .F.
Local aTitImp 		:= {}			// declaracao do array responsavel por armazenar as informacoes necessarias para a impressao do recebimento nao fiscal - LJGRVREC
Local aParcelas 	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o check-out irá usar TCLINK  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lBscCliON		:= SuperGetMV("MV_LJCLION", ,.F.)	//Identifica se o Front irá se conectar com a Retaguarda
Local lBscPrdON		:= SuperGetMV("MV_LJPRDON", ,.F.)	//Identifica se o Front irá se conectar com a Retaguarda
Local nConTcLnk     := -1                               // Variavel de controle do TCLink
Local cCliCGC		:= ""								// CGC do cliente
Local cGrpTrib 	    := ""                               // SitTrib
Local cDocFo 		:= ""								//Release 11.5- Controle de Formularios - Numero do documento de venda definido no inicio da venda atraves do lote/controle de formulario.
Local nAjustatl     := 0                                // Ajusta a dimensao da tela.

//Produto Mostruario - Indicador
//[1] = Tipo Mostruario (Normal, Mostruario, Saldao)
//[2] = Observacoes
Local aMostruario   := {"N",""}
Local cTema			:= GetRealTheme()        			//Obtem o tema utilizado
Local aRes			:= {} // Função de altura e largura para fullscreen

Private lCFrete := .F.											// indica se o Frete já foi cobrado na Venda

DEFAULT cTipoCli	:= ""
DEFAULT cVndLjAlt	:= ""

DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.
DEFAULT lCancItRec	:= .F.
DEFAULT lFRTAuto	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Balanca Serial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lBalanca := SLG->(FieldPos("LG_PORTBAL")) > 0 .AND. !Empty(LjGetStation('BALANCA')+LjGetStation('PORTBAL'))

cDoc		:= Space(TamSX3("L1_DOC")[1])
cHora		:= Left( Time(), TamSX3("L1_HORA")[1] )
cPDV		:= "    "
cProduto	:= Space(TamSX3("BI_DESC")[1])
nQuant		:= 1
nTmpQuant	:= 1
cUnidade	:= "UN"
nVlrUnit	:= 0
nVlrItem	:= 0
nTotItens	:= 0
nVlrTotal	:= 0
nValIPI		:= 0

If cPaisLoc <> "BRA"
	For nX := 1 To MoedFin()
		If(!(Empty(SuperGetMV("MV_MOEDA"+STR(nX,1),.F.,""))))
	    	LjCriaSimb(nX)
	     	AAdd(aMoeda,SuperGetMV("MV_MOEDA"+Ltrim(Str(nX))))
	     	AAdd(aSimbs,SuperGetMV("MV_SIMB"+Ltrim(Str(nX))))
	     	If (nX <> nMoedaCor) .AND. (RecMoeda(dDataBase,nX) > 0)
	     		AAdd(aTotVen,{nX,SuperGetMV("MV_MOEDA"+Ltrim(Str(nX))),0,.F.})
	     	EndIf
	  	EndIf
   	Next nX
Endif

If CrdxInt()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa as variaveis staticas que controlam a analise de credito feita pelo sigacrd³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fr271ICrdSet(@cContrato	, @aCrdCliente	,  @aContratos	, @aRecCrd)
EndIf


	DEFINE MSDIALOG oDlgFRT PIXEL OF GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP);
	COLOR CLR_RED,CLR_GRAY

	If lFRTAuto //ajusta a tela do atendimento para mostrar a barra de ferramentas
		aRes := MsAdvSize()
		aRes[5] := GetScreenRes()[1] 
		FWVldFullScreen()
		oDlgFRT:nWidth := aRes[5]
		oDlgFRT:nHeight := aRes[6]	
	Else
		aRes := GetScreenRes()
		oDlgFRT:nWidth := aRes[1]
		oDlgFRT:nHeight := aRes[2]	
		oDlgFRT:oWnd:SCROLLSTATUSBAR := .F.
	Endif
	


	oDlgFRT:bGotFocus := {|| oCodProd:SetFocus()}

	DEFINE TIMER oTimer INTERVAL nRPCInt * 1000 ACTION FR271HTimer(	@oTimer		, @oHora		, @cHora		, @oDoc			,;
															  		@cDoc		, @oPDV			, @cPDV			, @nLastTotal	,;
																	@nVlrTotal	, @nLastItem	, @nTotItens	, @nVlrBruto	,;
																	@oVlrTotal	, @oCupom		, @oTotItens	, @oOnOffLine	,;
																	@lOcioso	, @lLocked		, @aItens		, @aMoeda		,;
																	@aSimbs		, @nMoedaCor	, @aTotVen		, @oMensagem	,;
		 		                                                    oFntMoeda	, @cMensagem ) OF oDlgFRT

	If GetRemoteType() <> REMOTE_LINUX	   				// Caso a plataforma seja Windows mantem o tamanho da Fonte do Cupom da Tela.

		DEFINE FONT oFntCupom	NAME "Courier New"	   	SIZE 7,19 BOLD  	// Cupom Fiscal
		DEFINE FONT oFntMoeda 	NAME "Courier New"     	SIZE 8,16 BOLD      // Total da venda em varias moedas
		DEFINE FONT oFntInf		NAME "Arial" 			SIZE 8,16 BOLD		// Doc., Data, Hora, Loja, PDV
		DEFINE FONT oFntGet		NAME "Arial" 			SIZE 14,38			// Produto, Preco
		DEFINE FONT oFntQuant	NAME "Arial" 			SIZE 10,25			// Quant.
		DEFINE FONT oFntTotal	NAME "Arial" 			SIZE 19,60 BOLD		// Valor Total
		DEFINE FONT oFntLoc		NAME "Arial" 			SIZE 6,13           // Doc.(Localizacoes)

     Else                                                // Caso a plataforma seja Linux diminui o tamanho da Fonte do Cupom da Tela.

		DEFINE FONT oFntCupom	NAME "Courier New"	   	SIZE 6,21 			// Cupom Fiscal
		DEFINE FONT oFntMoeda   NAME "Courier New"     	SIZE 4,12 BOLD      // Total da venda em varias moedas
		DEFINE FONT oFntInf		NAME "Arial" 			SIZE 4,12 BOLD		// Doc., Data, Hora, Loja, PDV
		DEFINE FONT oFntGet		NAME "Arial" 			SIZE 10,34			// Produto, Preco
		DEFINE FONT oFntQuant	NAME "Arial" 			SIZE 6,21			// Quant.
		DEFINE FONT oFntTotal	NAME "Arial" 			SIZE 15,56 BOLD		// Valor Total
		DEFINE FONT oFntLoc		NAME "Arial" 			SIZE 2,9           // Doc.(Localizacoes)

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Espaco Reservado ao Logotipo da Empresa
	@ 0, 0 REPOSITORY oLogoEmp SIZE 160,80 PIXEL NO BORDER OF oDlgFRT
	ShowBitMap(oLogoEmp,"LOGOFRONT")

	// Quantidade x Preco
	@ 110,  3 TO 135, 160 LABEL STR0004 PIXEL	// "Quantidade x Preco"
	@ 115,  5 SAY oTemp1   VAR "" PIXEL SIZE 154,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp1:lTransparent := .F.
	@ 120,  5 SAY oQuant   VAR nQuant   FONT oFntQuant PIXEL RIGHT SIZE 49,13 COLOR CLR_WHITE,CLR_BLACK ;
				  PICTURE PesqPict("SL2","L2_QUANT")
	oQuant:lTransparent := .F.
	@ 115, 54 SAY oUnidade VAR cUnidade PIXEL SIZE 10,18 COLOR CLR_WHITE,CLR_BLACK
	oUnidade:lTransparent := .F.
	@ 115, 64 SAY oTemp2   VAR "x" FONT oFntGet PIXEL SIZE 10,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp2:lTransparent := .F.
	@ 115, 74 SAY oTemp3 VAR cSimbCor PIXEL SIZE 10,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp3:lTransparent := .F.
	@ 115, 84 SAY oVlrUnit VAR Transform(nVlrUnit,PesqPict("SBI", "BI_PRV",10,nMoedaCor));
	FONT oFntGet PIXEL RIGHT SIZE  75,18 COLOR CLR_WHITE,CLR_BLACK
	oVlrUnit:lTransparent := .F.

	// Get Quantidade
	@ 15,170 MSGET oTmpQuant VAR nTmpQuant FONT oFntQuant PIXEL SIZE  50,17 COLOR CLR_WHITE,CLR_BLACK ;
					PICTURE PesqPictQt("L2_QUANT") NOBORDER
					oTmpQuant:cSx1Hlp:="L2_QUANT"

	// "A quantidade deve ser um valor maior que 0." ### "Atenção"
	oTmpQuant:bLostFocus := {|| lF7:=.F., If(Frt272AQte(@nTmpQuant, @oTmpQuant) .AND. nTmpQuant>0 ,(nQuant:=nTmpQuant), ;
			 					(MsgStop(STR0072),nTmpQuant:=1, If (lUsaDisplay,;
			 					DisplayEnv(StatDisplay(), "1E" + STR0024 + Str(nTmpQuant,5,2) ), ))),;   //"Quantidade invalida!"
								oQuant:Refresh(), oTmpQuant:nTop:=30, oTmpQuant:nLeft:=340,;
								oTmpQuant:Disable(), oTmpQuant:Refresh()}
	If cPaisLoc == "POR"
		bQtdLostFoc := oTmpQuant:bLostFocus
	EndIf

	// Produto
	@  80,  3 TO 105, 160 LABEL STR0003 PIXEL	// "Produto"
	@  85,  5 SAY oProduto VAR cProduto FONT oFntGet PIXEL SIZE 154,18 COLOR CLR_WHITE,CLR_BLACK
	oProduto:lTransparent := .F.
	@ 221, 78 MSGET oCodProd VAR cCodProd FONT oFntGet PIXEL SIZE 84,17 COLOR CLR_WHITE,CLR_BLACK ;
					PICTURE PesqPict("SBI","BI_COD",15) F3 "FRT" NOBORDER
					oCodProd:cSx1Hlp:="L2_PRODUTO"

    If cPaisLoc == "BRA"
		oCodProd:bLostFocus := {|| If(!_lOK .AND. !Empty(cCodProd),(_lOK:=.T.,aKeyAux := FrtSetKey(),;
								 FR271AProdOK(					,				,				, .T.			,;
								 		  		@cCodProd		, @oTimer		, @oHora		, @cHora		,;
												@oDoc			, @cDoc			, @oPDV			, @cPDV			,;
												@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
												@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
												@oOnOffLine		, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
												@nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
												@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
												@cOrcam			, @cProduto		, @nQuant		, @cUnidade		,;
												@nVlrUnit		, @oUnidade		, @lF7			, Nil			,;
												@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
												@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
												@nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,;
												@_aMult			, @_aMultCanc	, @lOrc			, @aParcOrc		,;
												@cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
												@lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
												@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
												@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
												@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,;
												@nVidaLink		, @nValTPis		, @nValTCof		, @nValTCsl		,;
												@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
												@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
												@aMoeda			, @aSimbs		, @nMoedaCor	, @nDecimais	,;
												@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
												@aTotVen		, @aCols		, @nVlrPercIT	, @nTaxaMoeda   ,;
												@aHeader		, @nVlrDescIT	, @oMensagem	, oFntMoeda		,;
												@cMensagem		, @cTipoCli		, @lBscPrdON	, @nConTcLnk 	,;
												@cEntrega		, @aReserva		, @lReserva		, @lAbreCup		,;
												@nValor			, @cCupom 		, @cVndLjAlt	, @cCliCGC		,;
												@aRegTEF		, @lRecarEfet	, @lDescITReg	, NIL			,;
												NIL				, NIL			, @aMostruario  , NIL           ,;
												NIl             , NIL           , NIL           , NIL           ,;
												NIL             , NIL           , NIL           , NIL           ,;
												NIL             , NIL           , @cGrpTrib	),;
								 If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),;												
								 FR271AInitIT(	.F.			,	@lF7		, @cCodProd	, @cProduto	,;
												@nTmpQuant	,	@nQuant		, @cUnidade	, @nVlrUnit	,;
												@nVlrItem	,	@oProduto	, @oQuant	, @oUnidade	,;
												@oVlrUnit	,	@oVlrItem	, @oDesconto, @cCliente	,;
												@cLojaCli)	,;
								 FrtSetKey(aKeyAux),If (lUsaDisplay,(DisplayEnv(StatDisplay(), "1E"+ STR0046 + cCodProd),;
								 ),),_lOK:=.F.),), If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),), }					// "Codigo do Produto: "
	Else
        oCodProd:bLostFocus := {|| If(!_lOK .AND. !Empty(cCodProd),(_lOK:=.T.,aKeyAux := FrtSetKey(),If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),),;
        							FR271AProdOK(				,				,				, .T.			,;
	        									@cCodProd		, @oTimer		, @oHora		, @cHora		,;
												@oDoc			, @cDoc			, @oPDV			, @cPDV			,;
												@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
												@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
												@oOnOffLine		, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
												@nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
												@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
												@cOrcam			, @cProduto		, @nQuant		, @cUnidade		,;
												@nVlrUnit		, @oUnidade		, @lF7			, Nil			,;
												@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
												@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
												@nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,;
												@_aMult			, @_aMultCanc	, @lOrc			, @aParcOrc		,;
												@cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
												@lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
												@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
												@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
												@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,;
												@nVidaLink		, @nValTPis		, @nValTCof		, @nValTCsl		,;
												@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
												@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
												@aMoeda			, @aSimbs		, @nMoedaCor	, @nDecimais	,;
												@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
												@aTotVen		, @aCols		, @nVlrPercIT	, @nTaxaMoeda  	,;
												@aHeader		, @nVlrDescIT	, @oMensagem	, oFntMoeda		,;
												@cMensagem		, @cTipoCli		, @lBscPrdON	, @nConTcLnk 	,;
												@cEntrega		, @aReserva		, @lReserva		, @lAbreCup		,;
												@nValor			, @cCupom 		, @cVndLjAlt	, @cCliCGC		,;
												@aRegTEF		, @lRecarEfet	, @lDescITReg	, NIL			,;
												NIL				, @cDocFo		, @aMostruario	),;
        							If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),FrtSetKey(aKeyAux),_lOK:=.F.),)}
    EndIf
	oCodProd:bGotFocus  := {|| If(lUsaLeitor , LeitorFoco(nHdlLeitor,.T.), nil), ;
							   If(lUsaDisplay, ;
							      Eval( { || DisplayEnv(StatDisplay(), "1E"+ STR0046), ;
							                 If(lCXAberto .AND. !Empty(cCodProd),DisplayEnv(StatDisplay(), "2E" + Substr(cProduto,1,10) + " " + ;
								             Str(nQuant,5,2) + " " + Str(nVlrUnit,10,2) + " " + Str(nVlrItem,10,2) ), Nil) } ), nil ),;
							      FR271AInitIT(.F., 		@lF7, 		@cCodProd, 	@cProduto,;
												@nTmpQuant,	@nQuant,	@cUnidade,	@nVlrUnit,;
												@nVlrItem,	@oProduto,	@oQuant,	@oUnidade,;
												@oVlrUnit,	@oVlrItem,	@oDesconto,	@cCliente,;
												@cLojaCli) }

	If cPaisLoc == "POR"
		bCodLostFoc := oCodProd:bLostFocus
		bCodGotFoc  := oCodProd:bGotFocus
	EndIf

	// Total do Item
	@ 140,  3 TO 165, 160 LABEL STR0005 PIXEL	// "Total do Item"
	@ 145,  5 SAY oTemp4 VAR cSimbCor FONT oFntInf PIXEL SIZE 15,18 COLOR CLR_WHITE,CLR_BLACK
	oTemp4:lTransparent := .F.
	@ 145, 20 SAY oVlrItem VAR Transform(nVlrItem,PesqPict("SL2", "L2_VLRITEM",11,nMoedaCor));
	FONT oFntGet PIXEL RIGHT SIZE 139,18 COLOR CLR_WHITE,CLR_BLACK
	oVlrItem:lTransparent := .F.

	// Foto do Produto
	@ 169, 3 REPOSITORY oFotoProd SIZE 70,70 PIXEL NO BORDER OF oDlgFRT
	oFotoProd:SetColor(GetSysColor(15),GetSysColor(15))
	oFotoProd:lStretch := .T.
	oFotoProd:lVisible := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe a imagem FRTWIN , caso nao possua apresenta a LOJAWIN³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oFotoProd:ExistBmp("FRTWIN")
		ShowBitMap(oFotoProd, "FRTWIN")
	Else
		ShowBitMap(oFotoProd, "LOJAWIN")
	EndIf

	// Informacoes
	@ 168, 78 TO 215, 160 PIXEL
	@ 172, 151 BITMAP oOnOffLine RESOURCE IIf(!FR271BOnOfBmp(cEstacao),"FRTOFFLINE","FRTONLINE") ;
								 	PIXEL SIZE 16,16 NOBORDER OF oDlgFRT

	@ 173,  82 SAY STR0006			PIXEL SIZE 30,8		// "Documento:"
	@ 181,  82 SAY STR0007			PIXEL SIZE 18,8		// "Data:"
	@ 189,  82 SAY STR0008			PIXEL SIZE 15,8		// "Hora:"
	@ 197,  82 SAY STR0009			PIXEL SIZE 22,8		// "Filial:"
	@ 197, 130 SAY STR0010			PIXEL SIZE 13,8		// "PDV:"
	@ 205,  82 SAY STR0015			PIXEL SIZE 30,8		// "Usuário:"
	If cPaisLoc == "BRA"
	   @ 173, 115 SAY oDoc VAR cDoc	PIXEL SIZE 35,8 FONT oFntInf
	Else
	   @ 174, 112 SAY oDoc VAR cDoc	PIXEL SIZE 45,8 FONT oFntLoc  //Para suportar ate 12 caracteres na tela
	EndIf
	@ 181, 100 SAY DToC(dDataBase)	PIXEL SIZE 50,8 FONT oFntInf
	@ 189, 100 SAY oHora VAR cHora	PIXEL SIZE 50,8 FONT oFntInf
	@ 197, 100 SAY cFilAnt			PIXEL SIZE 52,8 FONT oFntInf
	@ 197, 143 SAY oPDV VAR cPDV	PIXEL SIZE 25,8 FONT oFntInf
	cCaixa := AllTrim(cUserName)+" - "+xNumCaixa()
	@ 205, 107 SAY cCaixa			PIXEL SIZE 52,8

    If LjNfPafEcf(SM0->M0_CGC)
		nAjustatl := 156
	ElseIf cPaisLoc == "BRA"
		nAjustatl := 164
	Else
   		nAjustatl := 134
 	EndIf

	// Cupom Fiscal
	oCupom := TMultiget():New(01,165,{|u|if(Pcount()>0,(cCupom:=u,oCupom:GoEnd()),cCupom)},oDlgFRT,;
								152	,nAjustatl, oFntCupom							 ,.F.	,;
								NIL	,NIL, NIL 								 ,.T.	,;
								NIL	,NIL, NIL								 ,NIL	,;
								NIL	,.T.,									 ,NIL	,;
								NIL	,.F., .T.								 )

 	oCupom:bGotFocus  := {|| oCodProd:SetFocus()}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Moeda/Taxa          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"
		@ 140, 165 TO 165, 318 LABEL STR0025 PIXEL  // Moeda da Venda

  		cMoeda := aMoeda[Int(nMoedaCor)]
		@ 145,169 SAY STR0026 SIZE 22, 07 OF oDlgFRT PIXEL         //"Moeda"
		@ 152,169 SAY oMoedaCor VAR cMoeda SIZE 50,07 FONT oFntInf OF oDlgFRT PIXEL

		@ 145,237 SAY STR0027 SIZE 22, 07 OF oDlgFRT PIXEL    //"Taxa"
		@ 152,237 SAY oTaxaMoeda VAR nTaxaMoeda Picture PesqPict("SL1","L1_TXMOEDA") SIZE 50,07 FONT oFntInf OF oDlgFRT PIXEL
	ElseIf LjNfPafEcf(SM0->M0_CGC) // Menu Fiscal
   		@ 158, 165 TO 167, 318 PIXEL
   		@ 159, 171 SAY STR0088 PIXEL //"Menu Fiscal : Pressione a tecla F12 e escolha a opção 22."
	EndIf

	// Total Parcial
	@ 168, 165 TO 215, 318 LABEL STR0011 PIXEL	// "Total Parcial"
	@ 173, 169 SAY STR0012 PIXEL SIZE 42,8		// "Numero de Itens:"
	@ 173, 215 SAY oTotItens VAR nTotItens FONT oFntInf   PIXEL SIZE 20,33
	@ 173, 258 SAY STR0013 PIXEL SIZE 32,8		// "Desconto:"
	@ 173, 285 SAY oDesconto VAR nVlrPercIT FONT oFntInf  PIXEL RIGHT SIZE 32,8 PICTURE "@R 99.99%"
	@ 180, 167 SAY oTemp5 VAR cSimbCor FONT oFntInf PIXEL SIZE 15,33 COLOR CLR_WHITE,CLR_BLACK
	oTemp5:lTransparent := .F.
	@ 180, 182 SAY oVlrTotal VAR Transform(nVlrTotal,PesqPict("SL1", "L1_VLRTOT",15,nMoedaCor));
	FONT oFntTotal PIXEL RIGHT SIZE 135,33 COLOR CLR_WHITE,CLR_BLACK
	oVlrTotal:lTransparent := .F.

	// Area de Mensagens
	@ 221, 166 SAY oMensagem VAR cMensagem FONT oFntGet PIXEL SIZE 152,18 COLOR CLR_WHITE,CLR_BLACK    
	oMensagem:lTransparent := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Teclas de Atalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FRTSetKey({	{|| FR271AAbreCX(	@oCupom		, @cCupom		, @CPDV	, @lCXAberto			,;
									@nHdlOPE)},;													// F4  - Abre Caixa
				{|| FR271EFechaCX(	@oCupom		, @cCupom		, @CPDV			, @lOcioso		,;
									@lRecebe	, @lCXAberto	, @nHdlOPE 		, @oHora		,;
									@cHora		, @oDoc			, @cDoc)},;							// F5  - Fecha Caixa
				{|| FR271EDescIT(	@oCupom		, @oDesconto	, @nVlrPercIT	, @nVlrTotal	,;
									@lRecebe	, @lDescIT		, @lDescITReg	, @nVlrBruto	,;
									@aItens		, @nMoedaCor	, @nDecimais	, @lCXAberto    ,;
									@nVlrDescIT , NIL			, NIL			, @aImpsSL1		,;
									@aImpsSL2 	, @aImpsProd)}	,;									// F6  - Desconto no Item
				{|| lF7:=.T., FR271AInitIT(	.F.			, @lF7		, @cCodProd	, @cProduto	,;
											@nTmpQuant	, @nQuant	, @cUnidade	, @nVlrUnit	,;
										  	@nVlrItem	, @oProduto	, @oQuant	, oUnidade	,;
											@oVlrUnit	, @oVlrItem	, @oDesconto,	@cCliente	,;
											@cLojaCli)	,;
						 FR271EEditQtd(	@oTmpQuant	, @lRecebe		, @lCXAberto )},;				// F7  - Altera Quantidade
					  {|| FR271ECancIT( @oCupom		, @oVlrTotal	, @nVlrTotal	, @nVlrBruto	,;
										@nMoedaCor	, @nTotItens	, @oTotItens	, @oTmpQuant	,;
							 	 	 	@nTmpQuant	, @oCodProd		, @cCodProd		, @nTaxaMoeda	,;
							 	 		@cOrcam		, @lRecebe		, @aItens		, @_aMultCanc	,;
							 	  		@uCliTPL	, @uProdTPL		, @nTotDedIcms	, @aMoeda		,;
							 	  		@aImpsSL1	, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
							 	  		@aTotVen	, @aCols		, @aHeader		, @lCXAberto	,;
							 	  		@nValor		, @aRegTEF		, @lRecarEfet	, @lCancItRec	,;
							 	  		@nVlrMerc	)}	,;	// F8  - Cancelamento do Item
				{|| FR271EFimVend(	.F.				, Nil			, @cNCartao		, @oHora		,;
									@cHora			, @oDoc			, @cDoc			, @oCupom		,;
									@cCupom			, @nVlrPercIT	, @nLastTotal	, @nVlrTotal	,;
									@nLastItem		, @nTotItens	, @nVlrBruto	, @oDesconto	,;
									@oTotItens		, @oVlrTotal	, @oFotoProd	, @nMoedaCor	,;
									@cSimbCor		, @oTemp3		, @oTemp4		, @oTemp5		,;
									@nTaxaMoeda		, @oTaxaMoeda	, @nMoedaCor	, @cMoeda		,;
									@oMoedaCor		, @cCodProd		, @cProduto		, @nTmpQuant	,;
									@nQuant			, @cUnidade		, @nVlrUnit		, @nVlrItem		,;
									@oProduto		, @oQuant		, @oUnidade		, @oVlrUnit		,;
									@oVlrItem		, @lF7			, @oPgtos		, @oPgtosSint	,;
									@aPgtos			, @aPgtosSint	, @cOrcam		, @cPDV			,;
									@lTefPendCS 	, @aTefBKPCS	, @oDlgFrt		, @cCliente		,;
									@cLojaCli		, @cVendLoja 	, @lOcioso		, @lRecebe		,;
									@lLocked		, @lCXAberto 	, @aTefDados	, @dDataCN		,;
									@nVlrFSD		, @lDescIT		, @nVlrDescTot	, @nValIPI		,;
									@aItens			, @nVlrMerc		, @lEsc			, @aParcOrc		,;
									@cItemCOrc		, @aParcOrcOld	, @aKeyFimVenda	, @lAltVend		,;
									@lImpNewIT		, @lFechaCup	, @aTpAdmsTmp	, @cUsrSessionID,;
									@cContrato		, @aCrdCliente	, @aContratos	, @aRecCrd		,;
									@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv		,;
									@cNumCartConv	, @uCliTPL		, @uProdTPL		, @lDescTotal	,;
									@lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	, @nVidaLink	,;
									@cCdPgtoOrc		, @cCdDescOrc	, @nValTPis		, @nValTCof		,;
									@nValTCsl		, @lOrigOrcam	, @lVerTEFPend	, @nTotDedIcms	,;
									@lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot 	,;
									@nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	, @nNumParcs	,;
									@aMoeda			, @aSimbs		, @cRecCart		, @cRecCPF		,;
									@cRecCont		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,;
									@aImpVarDup		, @aTotVen		, @nTotalAcrs	, @lRecalImp	,;
									@aCols			, @aHeader 		, @aDadosJur	, @aCProva		,;
									@aFormCtrl		, @nTroco		, @nTroco2 		, @lDescCond	,;
									@nDesconto		, @aDadosCH		, @cItemCond	, @lCondNegF5	,;
									@nTxJuros		, @nValorBase	, @lDiaFixo		, @aTefMult 	,;
									@aTitulo		, @lConfLJRec	, @aTitImp		, @aParcelas	,;
									@oCodProd		, @oMensagem 	, @oFntGet		, @cCodDep		,;
									@cNomeDEP		, @cTipoCli		, @cEntrega		, @aReserva		,;
									@lReserva		, @lAbreCup 	, @nValor		, @oTimer		,;
									@lResume		, @aValepre		, @aRegTEF		, @lRecarEfet	,;
									@lCancItRec		, @oOnOffLine	, @nValIPIIT	, @_aMult		,;
									@_aMultCanc		, @nVlrDescIT	, oFntMoeda		, @lBscPrdON	,;
									@oPDV			, @aICMS		, @lDescITReg	, @cNumDAV		,;
									@cCliCGC		, @cMensagem	, @cDocFo)},;	// F9  - Finaliza Venda (Sub-Total)
				{|| FR271EAltCli(	@cNCartao		, @cCliente		, @cLojaCli		, @lOcioso	,;
									@lRecebe		, @lCXAberto	, @aCrdCliente	, @cCodConv	,;
									@cLojConv		, @cNumCartConv, @uCliTPL		, @uProdTPL	,;
									@aItens		    , @cCodDep		, @cNomeDEP		, @cTipoCli	,;
									@lBscCliON		, @nConTcLnk	, @cCliCGC		, @cMensagem,;
									@cGrpTrib     )},;	// F10 - Alteracao de Clientes
				{|| FR271FAltVend(	@cVendLoja		, @lOcioso		, @lRecebe		, @lCXAberto	,;
									@lAltVend 		, @aItens		, @cVndLjAlt	)},;				// F11 - Alteracao de Vendedores
				{|| FR271FFuncoes(	@oHora			, @cHora		, @oDoc			, @cDoc			,;
			   						@oCupom			, @cCupom		, @nLastTotal	, @nVlrTotal	,;
									@nLastItem		, @nTotItens	, @nVlrBruto	, @oDesconto	,;
									@oTotItens		, @oVlrTotal	, @oFotoProd	, @nMoedaCor	,;
									@cSimbCor		, @oTemp3		, @oTemp4		, @oTemp5		,;
									@nTaxaMoeda		, @oTaxaMoeda	, @nMoedaCor	, @cMoeda		,;
									@oMoedaCor		, @nVlrPercIT	, @cCodProd		, @cProduto		,;
									@nTmpQuant		, @nQuant		, @cUnidade		, @nVlrUnit		,;
									@nVlrItem		, @oProduto		, @oQuant		, @oUnidade		,;
									@oVlrUnit		, @oVlrItem		, @lF7			, @oPgtos		,;
									@oPgtosSint		, @aPgtos		, @aPgtosSint	, @cOrcam		,;
									@cPDV			, @lTefPendCS 	, @aTefBKPCS	, @oDlgFrt		,;
									@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
									@lRecebe		, @lLocked		, @lCXAberto 	, @aTefDados	,;
									@dDataCN		, @nVlrFSD		, @lDescIT		, @nVlrDescTot	,;
									@nValIPI		, @aItens		, @nVlrMerc		, @lEsc			,;
									@aParcOrc		, @cItemCOrc	, @aParcOrcOld	, @aKeyFimVenda	,;
									@lAltVend		, @lImpNewIT	, @lFechaCup	, @aTpAdmsTmp	,;
									@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
									@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
									@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
									@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,;
									@nVidaLink		, @cCdPgtoOrc	, @cCdDescOrc	, @nValTPis		,;
									@nValTCof		, @nValTCsl		, @lOrigOrcam	, @lVerTEFPend	,;
									@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
									@nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	,;
									@nNumParcs		, @aMoeda		, @aSimbs		, @cRecCart		,;
									@cRecCPF		, @cRecCont		, @aImpsSL1		, @aImpsSL2		,;
									@aImpsProd		, @aImpVarDup	, @aTotVen		, @nTotalAcrs	,;
									@lRecalImp		, @aCols		, @aHeader 		, @aDadosJur	,;
									@aCProva		, @aFormCtrl	, @nTroco		, @nTroco2 		,;
									@lDescCond		, @nDesconto	, @aDadosCH		, @lDiaFixo		,;
									@aTefMult		, @aTitulo		, @lConfLJRec	, @aTitImp		,;
									@aParcelas		, @oCodProd		, @cItemCond	, @lCondNegF5	,;
									@nTxJuros		, @nValorBase	, @oMensagem	, @oFntGet		,;
									@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva     ,;
									@oTimer			, @lResume		, @nValor		, @aRegTEF		,;
									@lRecarEfet		, @oOnOffLine	, @nValIPIIT	, @_aMult		,;
									@_aMultCanc		, @nVlrDescIT	, @oFntMoeda	, @lBscPrdON	,;
									@oPDV			, @aICMS		, @lDescITReg	, @cMensagem	,;
									@cDocFo			, @aMostruario	)},;	// F12 - Funcoes Diversas (Funcao)
				,,,,,,,,,,,,,,,,,,,;
				{|| If(ExistBlock("FRTCTRLT"),ExecBlock("FRTCTRLT",.F.,.F.,{lOcioso, cCliente, cLojaCli}),)},;
				{|| If(ExistBlock("FRTCTRLU"),ExecBlock("FRTCTRLU",.F.,.F.,{lOcioso, cCliente, cLojaCli}),)},;
				{|| If(ExistBlock("FRTCTRLV"),ExecBlock("FRTCTRLV",.F.,.F.,{lOcioso, cCliente, cLojaCli}),)},;
				{|| If(ExistBlock("FRTCTRLW"),ExecBlock("FRTCTRLW",.F.,.F.,{lOcioso, cCliente, cLojaCli}),)},;
				,;
				,;
				{|| FR271CLoadOrc(	@oTimer			, @cCodProd		, @cHora		, @oDoc			,;
									@cDoc			, @oPDV			, @cPDV			, @nLastTotal	,;
									@nVlrTotal		, @nLastItem	, @nTotItens	, @nVlrBruto 	,;
									@oVlrTotal		, @oCupom		, @oTotItens 	, @oOnOffLine	,;
									@nTmpQuant		, @nVlrItem 	, @nValIPIIT	, @nValIPI		,;
									@oFotoProd		, @oProduto		, @oQuant		, @oVlrUnit		,;
									@oVlrItem		, @oDesconto	, @cSimbCor		, @cOrcam 		,;
									@cProduto		, @nQuant 		, @cUnidade		, @nVlrUnit 	,;
									@oUnidade 		, @lF7			, @oHora		, @lOcioso		,;
									@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
									@nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,;
									@_aMult			, @_aMultCanc	, @lOrc			, @aParcOrc		,;
									@cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
									@lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
									@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
									@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
									@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,;
									@nVidaLink		, @cCdPgtoOrc	, @cCdDescOrc	, @nValTPis		,;
									@nValTCof		, @nValTCsl		, @lOrigOrcam	, @lVerTEFPend	,;
									@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
									@nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	,;
									@nNumParcs		, @aMoeda		, @aSimbs		, @nMoedaCor	,;
									@nDecimais		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,;
									@aImpVarDup		, @aTotVen		, @aCols		, @nVlrPercIT	,;
									@cEstacao		, @lTouch		, @cVendLoja	, @aParcOrcOld	,;
									@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCliente		, @cLojaCli		, @cCupom		, @cTipoCli		,;
									@lDescITReg		, @cNumDAV		, @cDocFo		, @oTemp3		,;
									@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda 	,;
									@cMoeda			, @oMoedaCor	, @nVlrFSD		, @aMostruario	)}})	 // CTRL+Z - Carregamento de Orcamentos


LJMsgRun(STR0073) // "Aguarde... Inicializando Rotina."
oDlgFRT:bStart := 	{ || LJMsgRun(If(FindFunction("LjNfPtgNEcf") .AND. !LjNfPtgNEcf(SM0->M0_CGC), STR0016 + AllTrim(cImpressora) + "...",NIL), ,; // "Aguarde... Inicializando Rotina."  // "Aguarde. Abrindo a Impressora Fiscal " ### "..."
					{ || FR271AStart( 	@oTimer		,@oHora			, @cHora		, @oDoc			,;
										@cDoc		, @oPDV			, @cPDV			, @oMoedaCor	,;
										@nMoedaCor	, @cMoeda		, @oTaxaMoeda	, @nTaxaMoeda	,;
										@cSimbCor	, @oTemp3		, @cCodProd		, @oFotoProd	,;
										@oProduto	, @oUnidade		, @oQuant		, @oVlrUnit		,;
										@oVlrItem	, @oVlrTotal	, @oTotItens	, @oDesconto	,;
										@nVlrTotal	, @nVlrBruto	, @nTotItens	, @cProduto		,;
										@cUnidade	, @nQuant		, @nVlrUnit		, @oCupom		,;
										@cOrcam		, cImpressora	, @cCliente		, @cLojaCli		,;
										@lOcioso	, @lDescITReg	, @aItens		, @aICMS		,;
										@nVlrMerc	, @lExitNow		, @lFechaCup	, @aCrdCliente 	,;
										@uCliTPL	, @uProdTPL		, @nTotDedIcms	, @aMoeda		,;
										@aSimbs		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,;
										@aImpVarDup	, @aTotVen		, @aCols		, @aHeader		,;
										@lBalanca	, @cPorta		, @cVendLoja	, @cTipoCli		,;
										@aPgtos 	, @lResume		, @cCupom		, @lAbrecup		,;
										@cMensagem) }), ;
                       IIF( lUsaDisplay, ( DisplayEnv(StatDisplay(), "1E" + STR0046)  ), Nil ), ;
                       IIF( lExitNow, oDlgFRT:End(), NIL ) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Feita a validacao no on init para peder e ganhar o foco para  ³
//³permitir a selecao via F3 do produto na venda. Feito para P10 ³
//³deve ser tratada a causa pela Tecnologia.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgFRT ON INIT ( oCupom:SetFocus(), oDlgFRT:SetFocus() ) VALID FR271AConfExit(	@lOcioso	, @lRecebe	, @lCXAberto	, @nHdlOPE	,;
												@lExitNow)


Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr272AAltPºAutor  ³Vendas Clientes     º Data ³  10/18/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara a array apgtos para ser tratada a partir de uma novaº±±
±±º          ³tela, pois na principal será exibida a Sintetizada.         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr272AAltPgSi(	nLinha		, lAltParc		, aFormPagF5	, oFimVenda		,;
						aParcOrc	, nVlrTotal		, oPgtos		, aPgtos		,;
						oPgtosAna	, oDlgFrt		, aPgtosSint	, oPgtosSint	,;
						nTaxaMoeda	, lRecebe		, aMoeda		, aSimbs		,;
						aFormCtrl	, cSimbCheq		, cItemCond		, nTxJuros		,;
						nMoedaCor	, lVendaRapida	, lCondNegF5	, nValorBase	,;
						cCliente	, cLojaCli		, aTefBKPCS		, aTxJurAdm		,;
						oVlrTotal	)

Local lContinua   := .T.							//Laço para o controle da abertura de tela
Local lConfirma   := .F.							//Indica se o operador confirmou a alteração das parcelas
Local nPos        := 0								//Identifica a posição da informação na Array
Local lTefMult    := SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza múltiplas transações TEF
Local oDlgPgtoSin									//Objeto para tratamento da janela
Local aKey
Local nDecimais	  := MsDecimais(nMoedaCor)         	// Numero de casas decimais
Local aCProva     := {}                            	// Contabilizacao
Local aBckPgtos   := {}								// Backup do aPgtos
Local aCProvaBck  := {}								// Backup do cProva
Local xRet        := .T.                            // Retorno do Ponto de Entrada FRT272ATP
Local lRet        := .T.                            // Variavel logica que determina se exibira a tela
Local lMvJurCc	  := SuperGetMV("MV_LJJURCC",NIL,.F.) //Parametro para habilitar ou nao o juros por cartao de credito
Local lVerEmpres  := Lj950Acres(SM0->M0_CGC)		 // Verifica as filiais da trabalharam com acrescimento separado
Local lMult 	  := (FindFunction("Lj6GMulP")   .AND. Lj6GMulP())
Local lMultNeg		:=  cPaisLoc == "BRA" .And. SuperGetMV("MV_LJMULTN",,.F.)


DEFAULT nLinha  	:= 0
DEFAULT aTxJurAdm 	:= {0,0,0}
DEFAULT oVlrTotal	:= NIL

If lMult .Or. ((lMultNeg .And. !lRecebe) .And. SL1->(ColumnPos( "L1_CODMNEG" )) > 0 .and. !Empty(SL1->L1_CODMNEG)) // no caso de Multnegociacao nao permite alterar as formas de pagamento.
	Return()
EndIf

aKey := FRTSetKey()

// Ponto de Entrada criado para permitir que o usuario nao altere a forma de pagamento
If ExistBlock("FRT272ATP")
	xRet := ExecBlock( "FRT272ATP", .F., .F.,{nLinha ,aPgtos ,aPgtosSint ,nVlrTotal} )
	If ValType(xRet) == "L"
		lRet := xRet
	EndIf
EndIf

aBckPgtos       := AClone(aPgtos)
If cPaisLoc <> "BRA"
   aCProvaBck      := AClone(aCProva)
EndIf

lConfirma := .F.

If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria interface com o usuario                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPgtoSin TITLE STR0047 FROM 0,0 TO 16,52 OF oDlgFrt //"Detalhes da Forma de Pagamento"

	DEFINE SBUTTON FROM 107,175	TYPE 1 ACTION (lConfirma := .T. , oDlgPgtoSin:End()) ENABLE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os comandos abaixo foram colocados devido a um erro no ADVPL.          ³
	//³ "Preprocessor Table Overflow". Foi suprimido o Include do TCBROWSE.CH. ³
	//³ Os comandos originais devem ser mantidos para manutencao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPgtosAna:=TCBrowse():New(3, 3, 200, 100,,,,,,,,,;
				{|nRow,nCol,nFlags| IIf(lAltParc,(IIf((cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0),;
				FR271HPar(	@nVlrTotal	, @oPgtos		, @aPgtos	, @nTaxaMoeda	,;
							@oPgtosSint	, @aPgtosSint	, @lRecebe	, @aMoeda		,;
							@aSimbs		, @nMoedaCor	, @nDecimais, @aCProva		,;
							@aFormCtrl  , @oPgtosAna),;
				LojxDin(	aFormPagF5	, @nVlrTotal	, Nil			, 0		   		,;
							0			, @oFimVenda	, .F.			, @nVlrTotal	,;
							Nil			, Nil			, Nil			, Nil			,;
							Nil			, @oPgtos		, @aPgtos		, @oPgtosAna	,;
							@nTxJuros	, @aMoeda		, @nMoedaCor	, @lVendaRapida	,;
							@cSimbCheq	, @nValorBase	, @nTaxaMoeda	, cCliente		,;
							cLojaCli	, nDecimais		, oDlgFrt		, aTefBKPCS		,;
							@aTxJurAdm	)),;
				oPgtosAna:Refresh()),)},,,,,,, .F.,, .T.,, .F., )
	oPgtosAna:SetArray( aPgtos )

	nPos := Ascan(aPgtos, { |x| ( Alltrim(x[3]) == Alltrim(aPgtosSint[oPgtosSint:nAt][1]) .AND. Alltrim(x[12]) == Alltrim(aPgtosSint[oPgtosSint:nAt][4]) ) })
	oPgtosAna:nAt := Iif(nPos>0,nPos,1)
	oPgtosAna:Refresh()
	oPgtosAna:SetFocus()

	oPgtosAna:AddColumn(TCColumn():New(STR0019, {|| aPgtos[oPgtosAna:nAt,1]},,,,"LEFT",25,.F.,.F.,,,,.F.,) )  												//"Data"
	oPgtosAna:AddColumn(TCColumn():New(STR0020, {|| aPgtos[oPgtosAna:nAt,3]+IIf(ALLTRIM(aPgtos[oPgtosAna:nAt,3])<>cSimbCheq,Substr(aPgtos[oPgtosAna:nAt,4],4),'')},,,,"LEFT",60,.F.,.F.,,,, .F.,) )  			//"Forma de Pagamento"
	oPgtosAna:AddColumn(TCColumn():New(STR0021, {|| Transform(aPgtos[oPgtosAna:nAt,2],PesqPict("SL4","L4_VALOR",15))},,,,"RIGHT",50,.F., .F.,,,, .F., ) )  	//"Valor"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se trabalha com conceito de acrescimo separado,³
	//³Exibir o valor do acrescimo separado da parcela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
		//"Acrs.Fin"
		oPgtosAna:AddColumn(TCColumn():New(STR0087,{|| If(Len(aPgtos)>=oPgtosAna:nAt,Transform(aPgtos[oPgtosAna:nAt,13],PesqPict("SL1","L1_VLRTOT",15)),'')},,,, "RIGHT", 60, .F., .F.,,,, .F., ) )  //"Acrs.Fin"
	Endif

	//So exibir o ID para multiplas transacoes TEF
	If lUsaTef .AND. lTefMult
	   oPgtosAna:AddColumn(TCColumn():New(STR0048, {|| aPgtos[oPgtosAna:nAt,12]},,,,"RIGHT",30,.F.,.F.,,,,.F., ) ) //"ID Cartão"
	EndIf


	ACTIVATE MSDIALOG oDlgPgtoSin CENTERED

EndIf

If lConfirma
	aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
	oPgtosSint:SetArray( aPgtosSint )
	oPgtosSint:Refresh()
	lContinua := .F.
ElseIf lContinua
   		aPgtos    := AClone(aBckPgtos)
   		If cPaisLoc <> "BRA"
   		   aCProva  := AClone(aCProvaBck)
   		EndIf
	aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
	oPgtosSint:SetArray( aPgtosSint )
	oPgtosSint:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracao do valor total da venda, acrescentando o valor do juros ao total ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lMvJurCc) .AND. (Len(aTxJurAdm) > 0) .AND. (aTxJurAdm[3] > 0)
	nVlrTotal += aTxJurAdm[3]
	oVlrTotal:Refresh()
EndIf

FRTSetKey(aKey)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTA272XMsgºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe mensagem que o produto nao foi cadastrado            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT272XMsg(cCodProd)

Local oDlgErro
Local oFntErro

Tone(3000,1)
DEFINE FONT oFntErro NAME "Arial" SIZE 6,14 BOLD
DEFINE DIALOG oDlgErro FROM 0,0 TO 5, Len( STR0014 ) + 8 ;	// "Produto não cadastrado!!!"
	STYLE nOr( DS_MODALFRAME, WS_POPUP ) TITLE STR0002		// "Atenção"
	oDlgErro:SetFont(oFntErro)
	@  2,00 SAY xPadc(STR0014, oDlgErro:nRight - oDlgErro:nLeft) OF oDlgErro PIXEL
	@ 12,00 SAY xPadc(AllTrim(cCodProd), oDlgErro:nRight - oDlgErro:nLeft) OF oDlgErro PIXEL
	@ 24,45 BUTTON "OK" SIZE 40,12 ACTION (oDlgErro:End()) OF oDlgErro PIXEL
ACTIVATE MSDIALOG oDlgErro CENTERED

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT272xTDigºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define a tela dos dígitos                                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT272xTdig(aPgtos)
Local oFontMens		:= TFont():New( "Arial",06,14,,.T.)							// Fonte da mensagem de alerta
Local oDlgTefDig

DEFINE DIALOG oDlgTefDig TITLE STR0049 FROM 15,0 TO 26,76 STYLE DS_MODALFRAME 	//"Identifique os Cartões para a Múltipla-Transação TEF"
		oGet:=MsNewGetDados():New(001,001,065,300,GD_INSERT+GD_UPDATE,			/*[cLinhaOk]*/,/*[cTudoOk]*/,/*[cIniCpos]*/,aCampAlt,/*[lVazio]*/,Len(aColsDig),/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgTefDig,aHeadDig,aColsDig)
	@ 067,005 SAY STR0050 FONT oFontMens COLOR CLR_BLUE OF oDlgTefDig PIXEL 	//"Informe os 4 ultimos digitos de cada cartäo a ser diferenciado."
	@ 074,005 SAY STR0051 FONT oFontMens COLOR CLR_BLUE OF oDlgTefDig PIXEL 	//"Parcelas com dígitos em branco serão consideradas em um mesmo cartão!"
	oGet:oBrowse:nFreeze:=5

	DEFINE SBUTTON FROM 068,242 TYPE 1 ENABLE OF oDlgTefDig ACTION (Iif(FR271IDigConf(1, aPgtos),oDlgTefDig:End(),NIL)) PIXEL
	DEFINE SBUTTON FROM 068,272 TYPE 2 ENABLE OF oDlgTefDig ACTION (Iif(FR271IDigConf(2, aPgtos),oDlgTefDig:End(),NIL)) PIXEL

ACTIVATE DIALOG oDlgTefDig CENTERED

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTX272DescºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ ExpN1 - Vslor do Percentual de desconto 					  º±±
±±º          ³ ExpN2 - Valida se o desconto foi confirmado pelo botao OK  º±±
±±º          ³ ExpN3 - Valor do  Desconto				                  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º Retorno  ³ ExpN1 - Valor do Desconto                                  º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºDesc.     ³ Verifica Permissao "Efetuar Descontos"                     º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTX272Desc( nPercDesc, lConfDesc, nValorDesc,lDescITReg,nVlrMercAux )

Local oDlgDescItem										// Objeto da tela de desconto do item
Local oPercDesc											// Objeto de Get do desconto digitado pelo usuario
Local oKeyb												// Objeto
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local lRet
Local nMvLjTpDes:= SuperGetMv( "MV_LJTPDES", , 0 ) 		// Indica qual desconto sera' utilizado 0 - Antigo / 1 - Novo (objeto)
Local oValorDesc										// Objeto do get do valor do desconto
Local oBtn1		:= NIL									// Objeto do botao OK
Local oBtn2		:= NIL									// Objeto do botao Cancelar
Local lFRTDescITt := ExistBlock("FrtItDesc")            // Ponto de Entrada para validação do desconto no Produto de Garantia Estendida
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))	// Indica se estah utilizando os teclados
Local nFocoComp := 1									// Indica o campo que estah com o foco no momento - 1 - oPercDesc, 2 - oValorDesc, 3 - SBUTTON1, 4 - SBUTTON2
Local nHdlPerc := 0									// Handler do objeto do Get de Percentual
Local nHdlValor := 0									// Handler do objeto do Get do Valor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes 	   ³
//³Paises : Chile/Colombia - F1CHI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5	:= cPaisLoc$"CHI|COL"
Local nMoedaCor	:= 1  									//Moeda Corrente
Local nDecimais	:= MsDecimais(nMoedaCor)				//Numero de decimais da moeda corrente

DEFAULT nPercDesc 	:= 0
DEFAULT nValorDesc  := 0
DEFAULT lConfDesc   :=.F.
DEFAULT lDescITReg	:=.F.
DEFAULT nVlrMercAux	:= 0

If lFRTDescITt .AND. !ExecBlock("FrtItDesc")
	MsgStop(STR0089) //Item nao pode conter desconto. Produto Garantia Estendida.
	Return .T.
EndIf

If lTouch
	DEFINE MSDIALOG oDlgDescItem FROM 178,181 TO 450,410 TITLE STR0017 PIXEL	// "Desconto no total do item"
Else
	DEFINE MSDIALOG oDlgDescItem FROM  47,130 TO 160,390 TITLE STR0017 PIXEL	// "Desconto no total do item"
EndIf

@ 06, 04 BITMAP RESOURCE "DISCOUNT" OF oDlgDescItem PIXEL SIZE 32,32 ADJUST When .F. NOBORDER
@ 04, 40 TO 28, 125 LABEL STR0023 OF oDlgDescItem  PIXEL	// "Valor / Percentual"

@ 13, 90 MSGET oPercDesc VAR nPercDesc SIZE 16, 10 OF oDlgDescItem PICTURE "@E 99.99" PIXEL ;
		VALID	Iif(lUsaDisplay, Frt272VDPe(nHdlValor), .T.) .AND. ;
				Iif(Fr271IDesVld( @nPercDesc, 1 , @nValorDesc,lDescITReg ), ;
					.T.,;
					(Frt272MsgDsc("I", "P"), .F.) )

If cPaisLoc == "CHI"
	oPercDesc:bLostFocus := {|| nValorDesc := Round( nVlrMercAux * ( nPercDesc / 100 ), nDecimais ), oValorDesc:Refresh() }
EndIf

If lLocR5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Localizacoes                           ³
	//³Picture do campo de valor de desconto de acordo com a ³
	//³mascara do campo L1_DESCONT                           ³
	//³Paises : Chile / Colombia - F1CHI                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 13, 45 MSGET oValorDesc VAR nValorDesc SIZE 40, 10 OF oDlgDescItem PICTURE PesqPict("SL1","L1_DESCONT",7,nMoedaCor) RIGHT PIXEL ;
	VALID	Iif(lUsaDisplay, Frt272VDVa(nHdlPerc), .T.) .AND.;
			Iif(Fr271IDesVld( @nPercDesc, 2 , @nValorDesc,lDescITReg ),;
				.T.,;
				(Frt272MsgDsc("I", "V"), .F.) )
Else
	@ 13, 45 MSGET oValorDesc VAR nValorDesc SIZE 40, 10 OF oDlgDescItem PICTURE "@E 999,999.99" RIGHT PIXEL ;
		VALID	Iif(lUsaDisplay, Frt272VDVa(nHdlPerc), .T.) .AND.;
				Iif(Fr271IDesVld( @nPercDesc, 2 , @nValorDesc,lDescITReg ), ;
					.T.,;
					(Frt272MsgDsc("I", "V"), .F.) )
EndIf

If cPaisLoc == "CHI"
	oValorDesc:bLostFocus := {|| If( nPercDesc == 0, ( nPercDesc := Round( 100 - ( ( ( nVlrMercAux - nValorDesc ) / nVlrMercAux ) * 100 ),2 ), oPercDesc:Refresh(),;
									 If(!lTouch, oBtn1:SetFocus(),)) , NIL ) }
EndIf

If !lTouch
	DEFINE SBUTTON oBtn1 FROM 32, 50 TYPE 1 ENABLE OF oDlgDescItem ;
			ACTION ( lConfDesc := .T., oDlgDescItem:End() ) PIXEL

	DEFINE SBUTTON oBtn2 FROM 32, 85 TYPE 2 ENABLE OF oDlgDescItem ;
			ACTION ( lConfDesc := .F., oDlgDescItem:End() ) PIXEL
	// Para o caso do uso de displays a ordem de foco no incio eh diferente
	If lUsaDisplay
		// Capturar o handle do foco de cada item para utilizar na validacao quando utilizar o display
		oValorDesc:SetFocus()
		nHdlValor := GetFocus()

		oPercDesc:SetFocus()
		nHdlPerc := GetFocus()
	Endif

Else
// Definindo o Objeto Teclado
// Definindo a Acao da tecla ENTER do Teclado oKeyb
// Definindo o que fazer quando o Foco for obtido no Percentual de Desconto
// Definindo onde o Foco deve iniciar na Dialog
	oKeyb := TKeyboard():New( 50, 12, 1, oDlgDescItem )
	oKeyb:SetEnter({|| lConfDesc := .T., oDlgDescItem:End() })
	oKeyb:bEsc:={|| nPercDesc :=0, oDlgDescItem:End()}
	oPercDesc:bGotFocus		:= {|| oKeyb:SetVars(oPercDesc,TamSX3("L2_DESC")[1]) }
	oPercDesc:SetFocus()
EndIf

If lUsaDisplay
	// Limpar as mensagens do display
	LjLimpDisp()
	//Enviar as mensagens para o teclado
	Frt272MsgDsc("I", "P")
Endif

ACTIVATE MSDIALOG oDlgDescItem ON INIT  IIf(!lTouch,oPercDesc:SetFocus(),)CENTERED

If lUsaDisplay
	// Limpar as mensagens do display
	LjLimpDisp()
	DisplayEnv(StatDisplay(), "1E"+ STR0046)	// ### "Codigo do produto: "
Endif

If !lRet
	Return .F.
EndIf
Return( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T01 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Agrupa parcelas                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T01( cParcAgrup, aParcForma)

Local oDlgParc               	// Objeto do Dialog com as parcelas nas quais se pode agrupar a parcela modificada
Local oComboParc			 	// Objeto do combo box com as parcelas que pode agrupar
Local oButNaoAgrup			 	// Objeto do button para nao agrupar
Local oButAgrup              	// Objeto do button para agrupar
Local nOpca         := 2     	// Opcao selecionada na tela de agrupamento de parcelas

DEFINE MSDIALOG oDlgParc FROM  37,80 TO 190,393 TITLE STR0067 PIXEL	  //"Agrupamento de Parcelas"

	@ 04, 05 TO 55, 153 LABEL STR0052 OF oDlgParc	PIXEL	              //"Parcelas"
	@ 12, 10 SAY STR0068 SIZE 200, 10 OF oDlgParc 	PIXEL                  //"Existe mais de uma parcela com esta forma de pagamento."
	@ 20, 10 SAY STR0069 SIZE 250, 10 OF oDlgParc 	PIXEL  	              //"Se deseja agrupar, selecione em qual parcela e confirme."
	@ 28, 10 SAY STR0070 SIZE 250, 10 OF oDlgParc 	PIXEL  	  		      //"Caso contrario, selecione Cancelar."

	@ 40, 10 COMBOBOX oComboParc VAR cParcAgrup ITEMS aParcForma SIZE 25,07;
	OF oDlgParc PIXEL

	DEFINE SBUTTON FROM 57, 090 oButAgrup TYPE 1 ENABLE OF oDlgParc ;
	ACTION (nOpca := 1, oDlgParc:End()) PIXEL

	DEFINE SBUTTON FROM 57, 120 oButNaoAgrup TYPE 2 ENABLE OF oDlgParc ;
	ACTION (nOpca := 2, oDlgParc:End()) PIXEL

ACTIVATE DIALOG oDlgParc CENTERED

Return( nOpca )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T02 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela Itens                                              º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T02(	aItens		, lContinua		, nCancItem		, cCancProd	,;
						nCancQtde	, aCancItens	, nQtdeNova		, nI	  )


Local oCancItem
Local oCancQtde
Local oCancProd
Local oDlgCancela

If cPaisLoc <> "POR"
	If ExistBlock("FRTCODBR")
 		nI := ExecBlock("FRTCODBR",.F.,.F.,{aItens})
   		If nI <> 0
        	lContinua:=.T.
			nCancItem	:= nI
		EndIf
	Else
    	DEFINE MSDIALOG oDlgCancela FROM 0,0 TO 100,200 OF GetWndDefault() TITLE STR0028 PIXEL	//"Cancelamento de Item"
			@ 10,10 SAY STR0029 PIXEL	//"Nº do Item"
			// AIT_ITEM e AIT_CANCELADO Estao Dentro do CodeBlock Abaixo...
       		@ 10,50 MSGET oCancItem VAR nCancItem PIXEL SIZE 20,08 PICTURE "@E 99999" VALID ((nI := AScan(aItens, {|x| x[1]=nCancItem .AND. !x[11]}))>0)
       		oCancItem:cSx1Hlp:="L2_ITEM"

			DEFINE SBUTTON FROM 30, 30 TYPE 1 ACTION (lContinua:=.T.,oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
			DEFINE SBUTTON FROM 30, 60 TYPE 2 ACTION (oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
		ACTIVATE MSDIALOG oDlgCancela CENTERED

	EndIf
Else
	DEFINE MSDIALOG oDlgCancela FROM 0,0 TO 180,300 OF GetWndDefault() TITLE STR0028 PIXEL	//"Cancelamento de Item"
		@ 10,10 SAY STR0029 PIXEL	//"Nº do Item"
		@ 10,60 MSGET oCancItem VAR nCancItem PIXEL SIZE 20,08 PICTURE "@E 99999" ;
				VALID  (((nI := AScan(aItens, {|x| x[AIT_ITEM]=nCancItem .AND. !x[AIT_CANCELADO]})) >0) .OR. (nCancItem == 0))
				oCancItem:cSx1Hlp:="L2_ITEM"

		@ 30,10 SAY STR0003 PIXEL //"Produto"
		@ 30,60 MSGET oCancProd VAR cCancProd PIXEL SIZE 60,08 PICTURE PesqPict("SBI","BI_COD",15) F3 "FRT" ;
				VALID (((nI := AScan(aItens, {|x| Trim(x[AIT_COD])=Trim(cCancProd) .AND. !x[AIT_CANCELADO]})) > 0) .OR.;
		       		  ((nI := AScan(aItens, {|x| Trim(x[AIT_CODBAR])=Trim(cCancProd) .AND. !x[AIT_CANCELADO]})) > 0)) ;
				WHEN (nCancItem == 0)
				oCancProd:cSx1Hlp:="L2_PRODUTO"

		@ 50,10 SAY STR0030 PIXEL	//"Qtde. a Cancelar"
		@ 50,60 MSGET oCancQtde VAR nCancQtde PIXEL SIZE 20,08 PICTURE PesqPictQt("L2_QUANT") ;
				VALID Fr271HSomaIt(cCancProd,nCancQtde,@aCancItens,@nQtdeNova) ;
				WHEN (nCancItem == 0 .AND. !(Fr271CPesqMult(cCancProd,@aCancItens,@nCancQtde)))
			   	oCancQtde:cSx1Hlp:="L2_QUANT"

		DEFINE SBUTTON FROM 70, 30 TYPE 1 ACTION (lContinua:=.T.,oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
		DEFINE SBUTTON FROM 70, 60 TYPE 2 ACTION (oDlgCancela:End()) ENABLE PIXEL OF oDlgCancela
    ACTIVATE MSDIALOG oDlgCancela CENTERED
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T03 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera forma de pagamento da parcela atual                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T03( 	cForma		, cSimbCheq		, cDesc		, dData		,;
						nValor		, nOpc			, lUsaTef	, lTefMult	,;
						aMoeda		, lUsaAdm		, lRecebe	, cFormaId	,;
 						nNumParc	, nTXJuros		, nIntervalo, nValMax	,;
 						cMoedaVen	, nPosMoeda		, cSimbMoeda, lDifCart	,;
 						aMultMoeda	, aPgtos        , aValePre	, aColsMAV	,;
 						nPreDes		, lGerFin		, cCliPatr	, aTxJurAdm,;
 						nArredondar )

Local oFormPag
Local oData
Local oNumParc
Local oTXJuros
Local oIntervalo
Local oValor
Local oFont
Local oMoeda
Local oCart															//Objeto que armazena o ID cartao
Local oDifCart                           // Identifica se o cliente utiliza o mesmo carão para todas as parcelas de uma determinada ADM
Local nLinha		:= 35											// Controle de posicionamento dos objetos na tela
Local nColuna		:= 0
Local nTamMoed1 	:= 0
Local nTamMoed2 	:= 0
Local lVisuSint 	:= If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.)	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local cDescParcelas := ""
Local oKeyb											//Descricao das parcelas
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local nFormaId  	:= Val(cFormaID) // Convertido Para Suportar Teclado Numerico
Local oGetDad
Local lControlaVale := SuperGetMV("MV_LJUSAFD",,.F.)
Local lFRTCRD 		:= SuperGetMV("MV_FRTCRD",,.F.)
Local aHeaderMAV 	:= {}
Local nUsado 		:= 10
Local nCntFor		:= 0
Local cWs			:= "WS"
Local lInibeTela    := SuperGetMv("MV_LJADMFI",,.F.) //Parametro que seta o conteudo da variavel para inibir a tela de escolha das ADM. FINANCEIRAS
Local oComboForma   := Nil //Combobox para selecionar o tipo de cartao (DEBITO ou CREDITO) quando MV_LJADMFI estiver setado como TRUE
Local oBanco		:= Nil											// Banco Patrocinador
Local cBanco		:= Space(6)										// Banco Patrocinador
Local cDesconto		:= Space(5)										// Desconto
Local oDescBc		:= 	Nil											// Objeto de say
Local lMvJurCc		:= SuperGetMV("MV_LJJURCC",NIL,.F.)				// Parametro para habilitar ou nao o juros por cartao de credito
Local nVertTela		:= 0											// Para setar o tamanho da vertical da tela
Local nVertPanel	:= 0											// Para setar o tamanho da vertical do painel
Local lArredondar	:= SuperGetMv("MV_LJINSAR",,.F.)				// Parâmetro para ativar doação para o Instituto Arredondar
Local cMV_LJPGTRO	:= SuperGetMV("MV_LJPGTRO",,"")					// Contem as siglas das forma de pagamento que podem ser usadas para o troco.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes 		³
//³Paises : Chile/Colombia - F1CHI  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5   		:=	cPaisLoc$"CHI|COL"
Local nMoedaCor  	:= 1											// Moeda Corrente
Local cAuxPict		:= Iif(lLocR5,;
							PesqPicT("SL1","L1_VLRTOT",,nMoedaCor),;
							"999999999.99")     					// Picture para o valor total
Local nAux			:= 0											// Variável númerica auxiliar
Local lRetVp		:= .F.
Local lTroco1       := SL1->(ColumnPos("L1_TROCO1"))>0
Local lUsaTroco     := SuperGetMV("MV_LJTROCO", ,.F.)  // Habilita o uso do troco ou nao para gravacao
Local nValOri       := nValor    // guardo o valor oringinal para comparacao no valid do campo.

DEFAULT aColsMAV   	:= {}
DEFAULT aValePre	:= {}
DEFAULT nPreDes		:= 0
DEFAULT lGerFin		:= .F.
DEFAULT cCliPatr	:= ""
DEFAULT aTxJurAdm	:= {0,0,0}
DEFAULT nArredondar	:= 0

If(lUsaTef .AND. lTefMult)			// Tamanho da Dialog
	nColuna := 20
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o tamanho da tela de forma de pagamento³
//³conforme as condicoes atendidas.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lMvJurCc) .AND. (cForma $ _FORMATEF) .AND. (cPaisLoc == "BRA")
	nVertTela 	:= 287
	nVertPanel  := 138
	If (nNumParc > 1) .AND. !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA" .OR. Alltrim(cForma)$_FORMATEF)
		nVertTela 	+= 56
		nVertPanel	+= 30
	EndIf
ElseIf (lMvJurCc) .AND. (cForma $ _FORMATEF)
	nVertTela 	:= 310
	nVertPanel  := 162
Else
	nVertTela := 260
Endif

If Len(aMoeda) > 0
   nTamMoed1 := 20
   nTamMoed2 := 10
EndIf

cDescParcelas  	:= If(cForma="VA",STR0031,STR0052+IIf(cPaisLoc<>"BRA",If(cForma$_FORMATEF,STR0032,""),""))
// Seleção dos vales presentes que serão utilizados na venda
If Alltrim(cForma) == "VP"
   lRetVp := FR271GVlVP( nValMax, @aValePre, @nValor )
   If !lRetVp .or. Empty(aValePre) .or. nValor == 0
      Return (nil)
   Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega codigo adm³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjDesPa
	cBkDesAdm := cDesc
EndIf
If cPaisLoc $ "POR|EUA" .AND. cForma == cSimbCheq

	DEFINE MSDIALOG oFormPag FROM 1,1 TO 160,260 TITLE STR0020 PIXEL OF GetWndDefault()		// "Forma de Pagamento"

	DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -9 BOLD

	@ 10, 10 SAY cForma + " - " + cDesc SIZE 110,10 FONT oFont COLOR CLR_BLUE,CLR_WHITE OF oFormPag PIXEL

	@ 25, 10 SAY STR0019	SIZE 50,10 OF oFormPag PIXEL	// "Data"
	@ 25, 70 MSGET oData	VAR dData		SIZE 50,10 OF oFormPag PIXEL WHEN !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA")
	oData:cSx1Hlp:="L4_DATA"

    @ 40, 10 SAY STR0021	SIZE 50,10 OF oFormPag PIXEL	// "Valor"
    @ 40, 70 MSGET oValor	VAR nValor	   	PICTURE "999999999.99" SIZE 50,10 OF oFormPag PIXEL VALID (nValor >=0)
    oValor:cSx1Hlp:="L4_VALOR"

	DEFINE SBUTTON FROM 60,63 TYPE 1 ENABLE ACTION (nOpc:=1, oFormPag:End()) OF oFormPag
	DEFINE SBUTTON FROM 60,93 TYPE 2 ENABLE ACTION oFormPag:End() OF oFormPag

Else

	If lTouch
	   	DEFINE MSDIALOG oFormPag FROM 178,181 TO 520,440 TITLE STR0020 PIXEL OF GetWndDefault()	STYLE DS_MODALFRAME // "Forma de Pagamento"
	Else
		DEFINE MSDIALOG oFormPag FROM 1,1 TO nVertTela+nColuna+nTamMoed1,280 TITLE STR0020 PIXEL OF GetWndDefault()	// "Forma de Pagamento"
	EndIf

	DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -9 BOLD

	If !lInibeTela
		@ 07, 10 SAY cForma +  Iif( lUsaAdm, " - " + cDesc, " " ) SIZE 110,10 FONT oFont COLOR CLR_BLUE,CLR_WHITE OF oFormPag PIXEL
	Else
		If cForma $ "CC|CD"
			@ 07, 10 SAY STR0074 SIZE 110,10 FONT oFont COLOR CLR_BLUE,CLR_WHITE OF oFormPag PIXEL //"Tipo Cartão"
			@ 07, 70 COMBOBOX oComboForma VAR cForma Size 50,10 ITEMS {STR0075,STR0076} WHEN !(lInibeTela) PIXEL Of oFormPag //"CC=CRÉDITO"#"CD=DÉBITO"
		Else
			@ 07, 10 SAY cForma SIZE 110,10 FONT oFont COLOR CLR_BLUE,CLR_WHITE OF oFormPag PIXEL
		EndIf
	EndIf

	@ 20, 10 SAY STR0019	SIZE 50,10 OF oFormPag PIXEL	//"Data"

	If lRecebe .AND. cForma == cSimbCheq    				//Para ser ativado somente na Fidelizaçao e recebimento de Cheque
		@ 20, 70 MSGET oData VAR dData	SIZE 50,10 OF oFormPag PIXEL WHEN  iIf(lTouch,.F.,!(IsMoney(cForma) .OR. AllTrim(cForma) == "VA")) ;
		Valid FR271IVLDDTA(dData)
		oData:cSx1Hlp:="L4_DATA"
		If lTouch
			oData:bGotFocus		:= {|| oKeyb:SetVars(oData,TamSX3("L4_DATA")[1]) }
		EndIf
	Else
		@ 20, 70 MSGET oData VAR dData	SIZE 50,10 OF oFormPag PIXEL WHEN  iIf(lTouch,.F.,!(IsMoney(cForma) .OR. AllTrim(cForma) == "VA")) ;
		Valid dData >= dDataBase .AND. !Empty(dData)
		oData:cSx1Hlp:="L4_DATA"
		If lTouch
			oData:bGotFocus		:= {|| oKeyb:SetVars(oData,TamSX3("L4_DATA")[1]) }
		EndIf
  	Endif

  	If Alltrim(cForma)$_FORMATEF .AND. lVisuSint .AND. lUsaTef .AND. lTefMult
		@ nLinha, 10  Say STR0048 SIZE 55,15 OF oFormPag PIXEL	//"ID Cartão"
	 	If lTouch
			@ nLinha, 70  MSGET oCart VAR nFormaId RIGHT SIZE 15,10 PICTURE "@E 9" OF oFormPag PIXEL ;
		 					VALID Fr271IIDValid(cForma,@AllTrim(Str(nFormaId)), @aPgtos)
			oCart:bGotFocus	:= {|| oKeyb:SetVars(oCart,TamSX3("L4_FORMAID")[1]+1) }
	   	Else
 			@ nLinha, 70  MSGET oCart VAR cFormaId RIGHT SIZE 15,10 PICTURE PesqPict("SL4","L4_FORMAID") OF oFormPag PIXEL ;
		   		     		VALID Fr271IIDValid(cForma,@cFormaId, @aPgtos)
	  	Endif
		nLinha += 15
		oCart:cSx1Hlp:="L4_FORMAID"
		If lTouch
			oCart:bGotFocus		:= {|| oKeyb:SetVars(oCart,TamSX3("L4_FORMAID")[1]) }
		EndIf
	EndIf

	If !IsMoney(cForma) .AND. !cForma="VA"
		@ nLinha, 10 SAY cDescParcelas	SIZE 55,15 OF oFormPag PIXEL
		@ nLinha, 70 MSGET oNumParc		VAR nNumParc PICTURE PesqPict("SL1","L1_PARCELA") SIZE 50,10 OF oFormPag PIXEL VALID nNumParc > 0 ;
		.AND. FRtVldAdm('', cDesc, nNumParc, @nPreDes, @lGerFin, @cDesconto, cForma, @oDescBc, @oBanco) ;
		When If(Alltrim(cForma) == "VP", .F., .T.)	 .AND. Fr272ATxAd( SAE->AE_COD, nNumParc, @aTxJurAdm[1], cForma, lMvJurCc ) // Desabilita o campo para Vale Presente
		nLinha += 15
		oNumParc:cSx1Hlp:="L1_PARCELA"
		If lTouch
			oNumParc:bGotFocus	:= {|| oKeyb:SetVars(oNumParc,TamSX3("L1_PARCELA")[1]) }
		EndIf
	EndIf

	If nNumParc>1 .AND. !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA" .OR. Alltrim(cForma)$_FORMATEF)

		@ nLinha, 10 SAY STR0033	SIZE 50,10 OF oFormPag PIXEL	// "Taxa de Juros"
		@ nLinha, 70 MSGET oTXJuros	VAR nTXJuros PICTURE "@R 99.99%" SIZE 50,10 OF oFormPag PIXEL VALID ( If (nTxJuros >=0, .T. , (MsgStop(STR0053),.F.)))
		nLinha += 15
		oTXJuros:cSx1Hlp:="L1_JUROS"
		If lTouch
			oTxJuros:bGotFocus	:= {|| oKeyb:SetVars(oTxJuros,TamSX3("L1_JUROS")[1]) }
   		EndIf

		@ nLinha, 10 SAY STR0034	SIZE 50,10 OF oFormPag PIXEL	// "Intervalo"
		@ nLinha, 70 MSGET oIntervalo	VAR nIntervalo	PICTURE "@E 999" SIZE 50,10 OF oFormPag PIXEL
		nLinha += 15
		oIntervalo:cSx1Hlp:="L1_INTERV"
		If lTouch
			oIntervalo:bGotFocus	:= {|| oKeyb:SetVars(oIntervalo,TamSX3("L1_INTERV")[1]) }
   		EndIf
	EndIf

	@ nLinha, 10 SAY STR0021	SIZE 50,10 OF oFormPag PIXEL	// "Valor"
	@ nLinha, 70 MSGET oValor		VAR nValor	   	PICTURE cAuxPict SIZE 50,10 OF oFormPag PIXEL ;
			VALID {|| Fr272ATxAd( SAE->AE_COD, nNumParc, @aTxJurAdm[1], cForma, lMvJurCc )  .AND. ;
			      ( IIf (nValor >=0, (If(cPaisLoc == "BRA", ;
			      If(Frt272ATTroco(cForma,lTroco1,lUsaTroco,cMV_LJPGTRO,nValOri,nValor,nValMax),.T.,;
			      If(ExistBlock("FRTVMax"),ExecBlock("FRTVMax",.F.,.F.,{ cForma ,cDesc ,nValor ,nValMax }),nValor <= nValMax)),.T.)), ;
			(MsgStop(STR0053),.F.)))} ;  //"Näo e permitido valor negativo nesse campo."
			When If(Alltrim(cForma) == "VP", .F., .T.)

	nLinha += 15
	oValor:cSx1Hlp:="L4_VALOR"

	If  lLjDesPa .AND. cForma$ _FORMATEF

		cDesconto := "0"

		@ nLinha, 10 SAY oDescBc VAR STR0077 OF oFormPag PIXEL //"Banco Desconto:"
 		@ nLinha, 70 MSGET oBanco VAR cBanco F3 "FRT001" RIGHT VALID FR272VldBc(	@cBanco, 	cDesc,		nNumParc, @nPreDes,;
 																				 	@lGerFin, 	@cDesconto, @cCliPatr) ;
 																				 	SIZE 5,1 OF oFormPag PIXEL

		nLinha += 15


		@ nLinha, 10  	SAY STR0078 OF oFormPag PIXEL //"Desconto (%):"
		@ nLinha, 70 	SAY cDesconto OF oFormPag PIXEL //
		nLinha += 15

	EndIf

	// Se For Brasil e a forma For "R$" permite colocar um valor a maior,
	// e este valor excedente sera considerado como troco, pulando a funcao LjxDGetTroco().
	// Qualquer outra forma, segue a regra "nValor <= nValMax" ou o PE FRTVMax

	If cPaisLoc <> "BRA"
		@nLinha,010 SAY STR0026	SIZE 50,10 OF oFormPag PIXEL	// "Moeda"
		@nLinha,070 COMBOBOX oMoeda VAR cMoedaVen ITEMS aMoeda ON CHANGE (nPosMoeda:=oMoeda:nAt,cSimbMoeda:=SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda))));
		SIZE 50,10 PIXEL OF oFormPag
		nLinha += 15
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vale Compra - Se o cliente utiliza campanha de fidelizacao e a                   ³
	//³forma de pagamento for VA, o Sistem assume que o pagamento                        ³
	//³e vale compra e solicita o numero do vale compra                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lControlaVale .AND. cForma="VA" .AND. lFRTCRD
		aHeaderMAV := {}
		aColsMAV   := {}
		cWs := "WS"
		Aadd(aHeaderMAV,{RTrim(RetTitle("MAV_CODIGO")),"MAV_CODIGO","@!",;   //"Codigo"
		15,0,"Lj7PesqVale( )",Nil,"C","",,,,,".F.",,,,})

		Aadd(aHeaderMAV,{RTrim(RetTitle("MAV_VALOR")),"MAV_VALOR","@E 9,999,999.99",;   //"VALOR"
		15,0,"",Nil,"N","","V",,,,".F.",,,,})

		nUsado := Len(aHeaderMAV)
		aColsMAV := Array( 1 , (nUsado+1) )
		aColsMAV[1,nUsado+1] := .F.
		For nCntFor := 1 To nUsado
			aColsMAV[1,nCntFor] := CriaVar(aHeaderMAV[nCntFor,2],.T.)
		Next nCntFor



		oGetDad := MsNewGetDados():New(70,08,120,140,;
		GD_INSERT + GD_DELETE + GD_UPDATE,;
		"AllwaysTrue",;
		"AllwaysTrue"	,;
		Nil,;
		{"MAV_CODIGO"}  ,;
		NIL				,;
		999				,;
		NIL				,;
		NIL				,;
		NIL				,;
		oFormPag		,;
		aHeaderMAV		,;
		aColsMAV )

		oGetDad:oBrowse:lVisibleControl:= .T.
		oGetDad:Refresh()

	EndIf

	// Determina se irá ter que digitar os dígitos do cartão para múltiplas transações TEF
	If !lVisuSint .AND. lUsaTef .AND. lTefMult
		@ nLinha, 10 CHECKBOX oDifCart VAR lDifCart PROMPT STR0054 ; //"Parcelar com diferentes cartões da ADM"
						 SIZE 120,07 OF oDifCart PIXEL WHEN (nNumParc>1 .AND. cForma $ _FORMATEF )
		nLinha += 15
	EndIf

	If !lTouch
		DEFINE SBUTTON FROM nLinha+5+nTamMoed2,63 TYPE 1 ENABLE ACTION IIF(Frt010PgPE(	cForma	,	cDesc	, dData	 , nNumParc		,;
																							nTXJuros, nIntervalo, @nValor, cMoedaVen, 1, aPgtos),;
																							(nOpc := 1, aTxJurAdm[2] += aTxJurAdm[1], oFormPag:End()), .F.)  OF oFormPag


		DEFINE SBUTTON FROM nLinha+5+nTamMoed2,93 TYPE 2 ENABLE ACTION oFormPag:End() OF oFormPag
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria o groupbox para apresentar a taxa de juros e o valor³
	//³total com e sem juros, mais o botao para visualizacao das³
	//³parcelas.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If (lMvJurCc) .AND. (cForma $ _FORMATEF)
    	If lTefMult
			nVertPanel += 14
		EndIf
	    oGroup := tGroup():New(nLinha + 20 + nTamMoed2,10,nVertPanel,131,STR0085,oFormPag,CLR_HBLUE,,.T.) //"Juros Administradora"

		@ nLinha + 30 + nTamMoed2, 13 SAY STR0081 PIXEL OF oGroup 	//Taxa de Juros..:
		@ nLinha + 30 + nTamMoed2, 85 SAY aTxJurAdm[1] PICTURE "@E 99.99%" PIXEL RIGHT SIZE 28,0 OF oGroup

		@ nLinha + 41 + nTamMoed2, 13 SAY STR0082 PIXEL OF oGroup //Total sem Juros:
		@ nLinha + 41 + nTamMoed2, 85 SAY nValor PICTURE PesqPict("SL2","L2_VRUNIT") COLOR CLR_HBLUE PIXEL RIGHT SIZE 28,0 OF oGroup

		@ nLinha + 48 + nTamMoed2, 13 SAY STR0083 PIXEL OF oGroup //Total com Juros:
		@ nLinha + 48 + nTamMoed2, 85 SAY If(aTxJurAdm[1] > 0, A410Arred(nValor + (nValor * aTxJurAdm[1] / 100), "L2_VRUNIT"), nValor) PICTURE PesqPict("SL2","L2_VRUNIT") COLOR CLR_HRED PIXEL RIGHT SIZE 28,0 OF oGroup

		oButton := tButton():New(nLinha + 58 + nTamMoed2, 13, STR0084, oGroup, {|| Fr272AParc(aTxJurAdm, nNumParc, nValor, dData, nPosMoeda, nIntervalo) }, 40, 12,,,, .T.) //"Visualizar"
	EndIf

	//Foi criado depois dos botoes para que fique mais "funcional" para o usuario...
	If cPaisLoc <> "BRA" .AND. Len(aMoeda) > 1
		//Conversao de valores
		@ 03,70 BUTTON STR0055 SIZE 60,12 ACTION (LjxDRetVConv(@cMoedaVen,@oMoeda,@nValor,@oValor,aMoeda,@aMultMoeda,"FRONT","1",@cSimbMoeda)) OF oFormPag PIXEL //"Conversao de Valores"
	EndIf
EndIf

// Definindo o Objeto Teclado
// Definindo a Acao da tecla ENTER do Teclado oKeyb
// Definindo onde o Foco deve iniciar na Dialog
// Definindo eco do teclado quando o foco estiver em determinados objetos
If lTouch
	oKeyb := TKeyboard():New( 85, 20, 1, oFormPag )
	oKeyb:SetEnter({|| If(If(ExistBlock("FRTFPag"),ExecBlock("FRTFPag",.F.,.F.,{cForma,cDesc,dData,nNumParc,nTXJuros,nIntervalo,nValor}),.T.),(nOpc:=1, oFormPag:End()),)})
	oKeyb:bEsc:={|| ( cQtd := "1", oFormPag:End())}
	oValor:bGotFocus	:= {|| oKeyb:SetVars(oValor,TamSX3("L4_VALOR")[1]) }
	oValor:SetFocus()
EndIf

ACTIVATE MSDIALOG oFormPag CENTER

If (cPaisLoc == "BRA") .AND. lArredondar .AND. IsMoney(cForma)			// Pagto. em Dinheiro
	nArredondar := LjxDDoeArredondar( nValor - nValMax )
Elseif (cPaisLoc == "BRA") .AND. lArredondar .AND. cForma $ _FORMATEF		// Pagto. em Cartões Débito/Crédito
	nAux		:= nValMax-NoRound(nValMax,0)
	nArredondar := LjxDDoeArredondar( iif(nAux>0,1-nAux,nAux) )
Else
	nArredondar := 0
EndIf

If !oGetDad == nil
	If Len(oGetDad:ACOLS) > 0
		aColsMAV := Aclone(oGetDad:ACOLS)
    EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega patrocinio de desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cBanco) .AND. nPreDes > 0
	cCliPatr := Frta272ADM(cDesc)
ElseIf !Empty(cBanco) .AND. nPreDes > 0
	cCliPatr := cBanco
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T04 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua alteração no valor e data das parcelas              º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T04(	aMoeda		, lUsaTef	, lTefMult	, aPgtos	,;
						nLinha		, lRecebe	, cSimbCheq	, dDataParc	,;
						cForma		, nValParc	, nNumParc 	, nValMax	,;
						cMoedaVen 	, cDigCart	, nOpc		)



Local oDlgParcela
Local oDataParc
Local oValParc
Local oMoeda
Local oDigCart				//Digitos do cartao
Local cTitle		:= ""	//Titulo da janela
Local nTamParc1 	:= 0
Local nTamParc2 	:= 0
Local nJanDig  		:= 0	// Aumento o tamanho da Dialog se for utilizar o TEF
Local lVisuSint 	:= If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.)	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local nLinDig  		:= 0                   						// Linha onde se começa as mudanças de posição por parâmetros


If lUsaTef .AND. lTefMult
	nJanDig := 30
Endif

If Len(aMoeda) > 0
   nTamParc1  	:= 30
   nTamParc2 	:= 15
EndIf

cTitle := If(Empty(aPgtos[nLinha][4]), aPgtos[nLinha][3], aPgtos[nLinha][4])

DEFINE MSDIALOG oDlgParcela FROM 0,0 TO 110+nTamParc1+nJanDig,260 TITLE STR0035+cTitle PIXEL OF GetWndDefault()		//"Forma de Pagto "

@ 10,10 SAY STR0019 PIXEL	// "Data"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o tratamento do cheque a vista                                     ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Um cheque eh considerado a vista quando:                               ³
//³             Data do cheque < dDataBase + SuperGetMV("MV_LJCHVST)            ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Se o conteudo do parametro for -1, entao ele nao devera ser considerado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe .AND. cTitle = cSimbCheq
	@ 10,70 MSGET oDataParc VAR dDataParc SIZE 50,10 RIGHT ;
			VALID (dDataParc >= dDataBase .AND. FR271IVLDDTA(dDataParc)) OF oDlgParcela ;
			PIXEL WHEN !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA")
			oDataParc:cSx1Hlp:="L4_DATA"
Else
	@ 10,70 MSGET oDataParc VAR dDataParc SIZE 50,10 RIGHT ;
			VALID (dDataParc >= dDataBase) OF oDlgParcela ;
			PIXEL WHEN !(IsMoney(cForma) .OR. AllTrim(cForma) == "VA") ;
			Valid dDataParc >= dDataBase .AND. !Empty(dDataParc)
			oDataParc:cSx1Hlp:="L4_DATA"
Endif

@ 25,10 SAY STR0021 PIXEL	// "Valor"
@ 25,70 MSGET oValParc VAR nValParc SIZE 50,10 RIGHT PICTURE "999999999.99" VALID (nValParc>=(nNumParc*0.01) .AND. Iif(cPaisLoc=="BRA",nValParc<=(nValMax-(nNumParc*0.01)),.T.)) OF oDlgParcela PIXEL ;
WHEN Iif(cPaisLoc=="BRA",(nLinha <> nLinha+(nNumParc-1)),.T.)
cSx1Hlp:="L4_VALOR"

If cPaisLoc <> "BRA"
	@ 40,10 SAY STR0026 PIXEL	// "Moeda"
	@ 40,70 COMBOBOX oMoeda VAR cMoedaVen ITEMS aMoeda ON CHANGE (nPosMoeda:=oMoeda:nAt) SIZE 50,10 PIXEL OF oDlgParcela
EndIf

If lVisuSint
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o cliente utilizar multiplas transações TEF vou exibir o ID do cartão      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefMult .AND. cForma $ _FORMATEF
		@ 40+nLinDig,10 SAY STR0048 PIXEL //"ID do Cartão"
	    @ 40+nLinDig,70 MSGET oDigCart VAR cDigCart SIZE 10,10 RIGHT PICTURE PesqPict("SL4","L4_FORMAID") OF oDlgParcela PIXEL WHEN .F.
		nLinDig := nLinDig + 15
		oDigCart:cSx1Hlp:="L4_FORMAID"
	EndIf
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o cliente utilizar multiplas transações TEF vou exibir os dígitos do cartão³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefMult .AND. cForma $ _FORMATEF
		@ 40+nLinDig,10 SAY STR0056 PIXEL //"Dígitos Cartão"
	    @ 40+nLinDig,70 MSGET oDigCart VAR cDigCart SIZE 10,10 RIGHT PICTURE "9999" OF oDlgParcela PIXEL WHEN .F.
		nLinDig := nLinDig + 15
	EndIf
EndIf

DEFINE SBUTTON FROM 40+nLinDig+nTamParc2,63 TYPE 1 ENABLE ACTION ( IIF( Frt010PgPE(	cForma	,	""		, dDataParc , nNumParc	,;
																					 0		,  0		, nValParc  , cMoedaVen,;
																					 2		, aPgtos	, nLinha	),;
																	 	Eval({|| nOpc:=1, oDlgParcela:End()} ) , .F.  )  ) OF oDlgParcela
DEFINE SBUTTON FROM 40+nLinDig+nTamParc2,93 TYPE 2 ENABLE ACTION oDlgParcela:End() OF oDlgParcela

ACTIVATE DIALOG oDlgParcela CENTERED


Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T05 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe o total da venda em todas as moedas do sistema.      º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T05( aLabel	, aPreco )

Local oFnt
Local oFnt1
Local oDlg

DEFINE FONT oFnt  NAME "Arial" SIZE 15,15 BOLD
DEFINE FONT oFnt1 NAME "Arial" SIZE 11,13 BOLD ITALIC

DEFINE MSDIALOG oDlg FROM 190,420 TO 470,930 TITLE STR0036 PIXEL OF GetWndDefault();  //"Totais da Venda-Diversas Moedas"
		       STYLE nOr(WS_VISIBLE, WS_POPUP) COLOR CLR_WHITE,CLR_GRAY
	DEFINE SBUTTON FROM 135 , 225 TYPE 2 ENABLE ACTION oDlg:End()
	@ 000,001 TO 150,255 OF oDlg PIXEL

	@  010,05 Say aLabel[1] Size 140,15 OF oDlg Font oFnt Pixel
	If Len(aLabel) >= 2
	   @  040,05 Say aLabel[2] Size 140,15 OF oDlg Font oFnt Pixel
	EndIf
	If Len(aLabel) >= 3
	   @  070,05 Say aLabel[3] Size 140,15 OF oDlg Font oFnt Pixel
	EndIf
	If Len(aLabel) >= 4
	   @  100,05 Say aLabel[4] Size 140,15 OF oDlg Font oFnt Pixel
	EndIf
	If Len(aLabel) >= 5
	   @  130,05 Say aLabel[5] Size 140,15 OF oDlg Font oFnt Pixel
	EndIf

	@  010,170 Say aPreco[01] Picture PesqPict("SL1", "L1_VLRTOT",15,1) Size 70,15 OF oDlg Font oFnt1 Pixel
	If Len(aPreco) >= 2
	   @  040,170 Say aPreco[02] Picture PesqPict("SL1", "L1_VLRTOT",15,2) Size 70,15 OF oDlg Font oFnt1 Pixel
	EndIf
	If Len(aPreco) >= 3
	   @  070,170 Say aPreco[03] Picture PesqPict("SL1", "L1_VLRTOT",15,3) Size 70,15 OF oDlg Font oFnt1 Pixel
	EndIf
	If Len(aPreco) >= 4
	   @  100,170 Say aPreco[04] Picture PesqPict("SL1", "L1_VLRTOT",15,4) Size 70,15 OF oDlg Font oFnt1 Pixel
	EndIf
	If Len(aPreco) >= 5
	   @  130,170 Say aPreco[05] Picture PesqPict("SL1", "L1_VLRTOT",15,5) Size 70,15 OF oDlg Font oFnt1 Pixel
	EndIf

ACTIVATE DIALOG oDlg CENTERED

Return ( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T06 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite ao usuario trocar a moeda padrao da venda.         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T06(	cMoedaVen	, aMoeda	,  nTaxaVen	, nPosMoeda	,;
						nOpc )

Local oDlgTrcMoeda
Local oMoeda
Local oTaxaVen

DEFINE MSDIALOG oDlgTrcMoeda FROM 0,0 TO 120,260 TITLE STR0037 PIXEL OF GetWndDefault()	// "Forma de Pagto "

	@ 10,10 SAY STR0026 PIXEL	// "Moeda"
	@ 10,70 COMBOBOX oMoeda VAR cMoedaVen ITEMS aMoeda ;
	        ON CHANGE (nTaxaVen:=RecMoeda(dDataBase,oMoeda:nAt),nPosMoeda:=oMoeda:nAt,;
	        oTaxaVen:SetFocus()) Valid(nTaxaVen > 0) SIZE 50,10 OF oDlgTrcMoeda PIXEL

	@ 25,10 SAY STR0027 PIXEL	// "Taxa"
	@ 25,70 MSGET oTaxaVen VAR nTaxaVen SIZE 50,10 PICTURE  PesqPict("SL1","L1_TXMOEDA");
    OF oDlgTrcMoeda PIXEL

	DEFINE SBUTTON FROM 45,63 TYPE 1 ENABLE ACTION (nOpc:=1,oDlgTrcMoeda:End()) OF oDlgTrcMoeda
	DEFINE SBUTTON FROM 45,93 TYPE 2 ENABLE ACTION oDlgTrcMoeda:End() OF oDlgTrcMoeda

ACTIVATE DIALOG oDlgTrcMoeda CENTERED

Return ( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T07 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo da condicao negociada.                             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T07(	lUsaAdmFin	, cComboAdm	, cCondicao	, nTipoJur	,;
						nValorBase	, dDataCN	, aRetNeg	, nEntNeg	,;
						nParNeg		, nTxJNeg	, lDiaFixo	, nIntNeg	,;
						aComboAdm 	, lOk		, aLbxFator	   )

Local oUsaAdmFin
Local oComboAdm
Local oTipoJur
Local oVlrBase
Local oDataNeg
Local oEntNeg
Local oTxJNeg
Local oParNeg
Local oIntNeg
Local oChkDiaFixo
Local oIntDVenc
Local oDlgCN
Local oLbxFator

DEFAULT cCondicao := ""

DEFINE MSDIALOG oDlgCN FROM 33,33 TO 315,540 TITLE STR0038 PIXEL OF GetWndDefault() //"Condição Negociada"

		@ 01, 03 TO  55,120 LABEL STR0039 OF oDlgCN PIXEL //"Cálculo de Juros"
		@ 60, 03 TO 123,120 LABEL STR0040 OF oDlgCN PIXEL //"Administradora"
		@ 01,124 TO 123,250 LABEL STR0041 OF oDlgCN PIXEL //"Dados do Pagamento"

		// Utilizar Financiadora
		@ 70, 20 CHECKBOX oUsaAdmFin VAR lUsaAdmFin PROMPT STR0042 SIZE 60,07 OF oDlgCN PIXEL; //"Utilizar Financiadora"
			     ON CHANGE LjxDCalcFator(	oDlgCN		, @aLbxFator	, oLbxFator	, lUsaAdmFin	,;
			     							cComboAdm	, cCondicao) When .F.
		// Nome da administradora
		@ 80, 20 MSCOMBOBOX oComboAdm VAR cComboAdm ITEMS aComboAdm SIZE 75,07;
			     OF oDlgCN PIXEL When lUsaAdmFin

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Radio para a escolha do tipo de juros ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			@ 09, 07 RADIO oTipoJur VAR nTipoJur 3D SIZE 40,10 PROMPT;
				     STR0057, STR0058, STR0059, STR0060 OF oDlgCN PIXEL //"Simples"###"Série Pgtos."###"Price"###"SAC"
			oTipoJur:Enable(1)	// Simples
			oTipoJur:Enable(2)	// Serie Pgtos
			oTipoJur:Enable(3)	// Price
			oTipoJur:Disable(4)	// SAC
		Else
			@ 09, 07 RADIO oTipoJur VAR nTipoJur 3D SIZE 40,10 PROMPT;
			         STR0057, STR0058 OF oDlgCN PIXEL //"Simples"###"Série Pgtos."
			oTipoJur:Enable(1)	// Simples
			oTipoJur:Enable(2)	// Serie Pgtos
		EndIf

		@ 07,128 TO  27,246 OF oDlgCN PIXEL
		@ 15,131 SAY STR0061 SIZE 30,07 OF oDlgCN PIXEL //"Valor Base"
		@ 15,176 SAY oVlrBase VAR nValorBase SIZE 68,07 OF oDlgCN PIXEL PICTURE "@E 9,999,999.99" RIGHT COLOR CLR_HBLUE

		//Primeira Parcela
		If aRetNeg[4][2]<>'2'
		   @ 35,131 SAY STR0062 SIZE 50,07 OF oDlgCN PIXEL //"Primeira parcela"
		   @ 35,176 MSGET oDataNeg VAR dDataCN SIZE 40,07 OF oDlgCN PIXEL ;
				PICTURE "99/99/99" Valid !Empty(dDataCN) .AND. dDataCN >= dDataBase ;
				WHEN aRetNeg[4][2]<>'0'
				oDataNeg:cSx1Hlp:="DDATACN"
		EndIf

		//Entrada
		If aRetNeg[5][2]<>'2'
		   @ 50,131 SAY STR0063 SIZE 30,07 OF oDlgCN PIXEL //"Entrada"
		   @ 50,176 MSGET oEntNeg VAR nEntNeg SIZE 60,07 OF oDlgCN PIXEL PICTURE "@E 9,999,999.99" RIGHT;
				VALID (ljxDFirst(	nValorBase	, nEntNeg	, nEntNeg-nValorBase	, nParNeg	,;
									@nParNeg	, oParNeg	, oEntNeg),;
						(If (nEntNeg >=0,.T.,(MsgStop(STR0053),.F.))),(if(nEntNeg < nValorBase .AND. nParNeg == 0,(nParNeg := 1,.T.),.T.))) ; //"Näo e permitido valor negativo nesse campo."
				WHEN aRetNeg[5][2]<>'0'
				oEntNeg:cSx1Hlp:="L1_ENTRADA"
		EndIf

		// Taxa Juros
		If aRetNeg[6][2]<>'2'
		   @ 65,131 SAY STR0064 SIZE 30,07 OF oDlgCN PIXEL //"Taxa Juros"
		   @ 65,176 MSGET oTxJNeg VAR nTxJNeg SIZE 20,07 OF oDlgCN PIXEL PICTURE "@E 999.99" RIGHT ;
				VALID (If (nTxJNeg >=0,.T.,(MsgStop(STR0053),.F.))) ; //"Näo e permitido valor negativo nesse campo."
				WHEN !lUsaAdmFin .AND. aRetNeg[6][2]<>'0'
				oTxJNeg:cSx1Hlp:="L1_JUROS"
		EndIf

		// Parcelas
		If aRetNeg[7][2]<>'2'
		   @ 80,131 SAY STR0052 SIZE 30,07 OF oDlgCN PIXEL //"Parcelas"
		   @ 80,176 MSGET oParNeg VAR nParNeg SIZE 13,07 OF oDlgCN PIXEL PICTURE "@E 99" RIGHT ;
				VALID If(nEntNeg < nValorBase, nParNeg >= 1,.T.) ;
				WHEN (nEntNeg < nValorBase).AND.aRetNeg[7][2]<>'0'
				oParNeg:cSx1Hlp:="L1_PARCELA"
		EndIf

		// Intervalo  // Dia Vencimento
		If aRetNeg[8][2]<>'2'
		   @ 95,131 SAY oIntDVenc VAR OemToAnsi(If(lDiaFixo, STR0065,STR0034)) SIZE 40,07 OF oDlgCN PIXEL //"Intervalo"
		   @ 95,176 MSGET oIntNeg VAR nIntNeg SIZE 13,07 OF oDlgCN PIXEL PICTURE "999" ;
				VALID (nIntNeg > 0) WHEN aRetNeg[8][2]<>'0'
				oIntNeg:cSx1Hlp:="L1_INTERV"
		EndIf

		If SL1->(FieldPos("L1_DIAFIXO"))>0
			@ 110, 131 CHECKBOX oChkDiaFixo VAR lDiaFixo PROMPT STR0066 SIZE 30,07;   //"Dia Fixo"
			ON CHANGE (If (lDiaFixo,nIntNeg:=Day(dDataBase),nIntNeg := 1), oIntDVenc:Refresh(), oIntNeg:Refresh())
		EndIf

		DEFINE SBUTTON FROM 125,194 TYPE 1 ENABLE OF oDlgCN;
			ACTION (lOk:=.T., oDlgCN:End())

		DEFINE SBUTTON FROM 125,223 TYPE 2 ENABLE OF oDlgCN;
			ACTION (lOk:=.F., oDlgCN:End())

	ACTIVATE MSDIALOG oDlgCN CENTERED

Return ( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T08 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe uma tela para que o usuário digite os 4 ultimos      º±±
±±º          | digitos do cartao, pois nas multiplas transacoes Tef       º±±
±±º          | precisaremos diferenciá-los                                º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T08( aHeadDig	, aColsDig	,  aCampAlt	, oDlgTefDig,;
					 aPgtos )

Local oFontMens		:= TFont():New( "Arial",06,14,,.T.)						// Fonte da mensagem de alerta

DEFINE DIALOG oDlgTefDig TITLE STR0049 FROM 15,0 TO 26,76 STYLE DS_MODALFRAME 	//"Identifique os Cartões para a Múltipla-Transação TEF"
	oGet:=MsNewGetDados():New(001,001,065,300,GD_INSERT+GD_UPDATE,/*[cLinhaOk]*/,/*[cTudoOk]*/,/*[cIniCpos]*/,aCampAlt,/*[lVazio]*/,Len(aColsDig),/*[cCampoOk]*/,/*[cSuperApagar]*/,/*[cApagaOk]*/,oDlgTefDig,aHeadDig,aColsDig)
	@ 067,005 SAY STR0050 FONT oFontMens COLOR CLR_BLUE OF oDlgTefDig PIXEL 		//"Informe os 4 ultimos digitos de cada cartäo a ser diferenciado."
	@ 074,005 SAY STR0051 FONT oFontMens COLOR CLR_BLUE OF oDlgTefDig PIXEL 		//"Parcelas com dígitos em branco serão consideradas em um mesmo cartão!"
	oGet:oBrowse:nFreeze:=5

	DEFINE SBUTTON FROM 068,242 TYPE 1 ENABLE OF oDlgTefDig ACTION (Iif(FR271IDigConf(1, aPgtos),oDlgTefDig:End(),NIL)) PIXEL
	DEFINE SBUTTON FROM 068,272 TYPE 2 ENABLE OF oDlgTefDig ACTION (Iif(FR271IDigConf(2, aPgtos),oDlgTefDig:End(),NIL)) PIXEL

ACTIVATE DIALOG oDlgTefDig CENTERED

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T09 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza o Desconto no Total da Venda (F6)                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T09( nValorDesc	, nPercDesc		, nOpc		 , nVlrMercAux	,;
					 nVlrTotal	, nTotDedIcms	, nVlrBruto	 , nMoedaCor	,;
					 aItens		, nVlrDescTot	, nVlrPercTot, nPerDscRgr	,;
					 nVlrDscRgr , lDescPa 	)

Local oDlgDescTot						// Objeto da janela do desconto
Local oValorDesc						// Objeto do get do valor do desconto
Local oPercDesc							// Objeto do get do percentual do desconto
Local oBtn1								// Objeto do botao OK
Local oBtn2								// Objeto do botao Cancelar
Local nPerc			:= 0 				// Valor do Desconto sem a funcao Round()
Local oKeyb								// Objeto do Teclado Virtual
Local nOpcao		:= 1				// Opcao de tipo de desconto
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local nDecimais		:= MsDecimais(nMoedaCor)  				// Numero de casas decimais
Local cTipoDesc		:= SuperGetMV("MV_LJTIPOD",.F.,"1")    // Tipo do Desconto
Local nVlrPercBkp		:= 0 									// Valor Backup do desconto
Local lDescRegra		:= .F.									// Indica se ha desconto proveniente de regra de desconto
Local lFRTAtuDesc		:= FindFunction("U_FRTATUDESC")
Local nFocoComp		:= 1									// Indica o campo que estah com o foco no momento - 1 - oPercDesc, 2 - oValorDesc, 3 - SBUTTON1, 4 - SBUTTON2
Local nHdlPerc		:= 0									// Handler do objeto do Get de Percentual
Local nHdlValor		:= 0									// Handler do objeto do Get do Valor
Local lUsaDisplay		:= !Empty(LjGetStation("DISPLAY"))	//Verifica se a estacao possui Display

DEFAULT nOpc 		:= 1
DEFAULT aItens		:= {}									// Array com os Itens da Venda
DEFAULT nVlrDescTot	:= 0									// Valor do desconto que ja foi concedido
DEFAULT nVlrPercTot := 0									// Valor do percentual que ja foi concedido
DEFAULT nPerDscRgr  := 0
DEFAULT nVlrDscRgr  := 0
DEFAULT lDescPa		:= .F.

// Indica a integracao com o cenario de vendas
If SuperGetMv("MV_LJCNVDA",,.F.) .OR. lDescPa
	lDescRegra	:= (nPerDscRgr <> 0) .OR. (nVlrDscRgr <> 0)
EndIf

//Se chamar a tela novamente apos ja ter calculado o desconto no total, para nao haver problema nos calculos do novo desconto
nVlrTotal := nVlrTotal + nVlrDescTot

If !lDescRegra

	If lTouch
		DEFINE MSDIALOG oDlgDescTot FROM 178,181 TO 500,430 TITLE STR0022 PIXEL	// "Desconto no total do cupom"
	Else
		DEFINE MSDIALOG oDlgDescTot FROM  47,130 TO 160,390 TITLE STR0022 PIXEL	// "Desconto no total do cupom"
	EndIf

	@ 06, 04 BITMAP RESOURCE "DISCOUNT" OF oDlgDescTot PIXEL SIZE 32,32 ADJUST When .F. NOBORDER
	@ 04, 40 TO 28, 125 LABEL STR0023 OF oDlgDescTot PIXEL	// "Valor / Percentual"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o get do valor do desconto e define o valid para chamar a mesma³
	//³ funcao da venda assitida para verificar a permissao de desconto do   ³
	//³ usuario                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 13, 45 MSGET oValorDesc VAR nValorDesc SIZE 40, 10 OF oDlgDescTot Picture PesqPict("SL1","L1_VLRTOT",10,nMoedaCor) RIGHT PIXEL ;
                         VALID Iif(lUsaDisplay, Frt272VDVa(nHdlPerc), .T.) .AND.;
                         		(If(nValorDesc<0,HELP(' ',1,'FRT023'),),.T.) .AND.; 
                           		Iif((nValorDesc >= 0 .AND. nValorDesc < nVlrBruto), ;
										.T.,; 
										(Frt272MsgDsc("T", "V"), .F.) )


	oValorDesc:cSx1Hlp := "L1_DESCONT"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³So' recalcula caso o percentual do desconto for zerado. ³
	//³Evita que por problemas de arredondamento exiba valor   ³
	//³percentual incorreto.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		oValorDesc:bLostFocus := {|| If( nPercDesc == 0, (nVlrPercBkp := nPercDesc := Round( 100 - ( ( ( nVlrBruto - nValorDesc) / (nVlrBruto - nTotDedIcms) ) * 100 ),2 ), oPercDesc:Refresh(),;
										 nPerc 	:= 100 -   (( nVlrBruto - nValorDesc) / (nVlrBruto - nTotDedIcms)) * 100 ),NIL ) ,;
										 IIf(lFRTAtuDesc, U_FRTATUDESC(@nPercDesc, @nVlrPercBkp, nvlrtotal, @nPerc, @nValorDesc, @oPercDesc, @oValorDesc, 1), NIL) }
	Else
		oValorDesc:bLostFocus := {|| If( nPercDesc == 0, ( nPercDesc := Round( 100 - ( ( ( nVlrMercAux - nValorDesc ) / nVlrMercAux ) * 100 ),2 ), oPercDesc:Refresh(),;
									 If(!lTouch, oBtn1:SetFocus(),)) , NIL ) }
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o get do % do desconto e define o valid para chamar a mesma    ³
	//³ funcao da venda assitida para verificar a permissao de desconto do   ³
	//³ usuario                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 13, 90 MSGET oPercDesc  VAR nPercDesc  SIZE 16, 10 OF oDlgDescTot PICTURE "@E 99.99" PIXEL ;
                         VALID	Iif(lUsaDisplay, Frt272VDPe(nHdlValor), .T.) .AND. ;
                         		( If( nPercDesc < 0, HELP(' ',1,'FRT023'),),.T.) .AND.;
                           		Iif(( nPercDesc  >= 0 ), ;
										.T.,;
										(Frt272MsgDsc("T", "V"), .F.) )

	oPercDesc:cSx1Hlp:="NDESPERTOT"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o usuario altere o get , vai atualizar o nPerc para ³
	//³manda-lo atualizado para a FRT271IAtuValor  				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		oPercDesc:bLostFocus := {|| IIf( nVlrPercBkp <> nPercDesc , nPerc := nPercDesc,.T.),nValorDesc := Fr271IAtuValor( nPerc, nPercDesc, nVlrTotal, nValorDesc), oValorDesc:Refresh() ,;
										IIf(lFRTAtuDesc, U_FRTATUDESC(@nPercDesc, @nVlrPercBkp, nVlrTotal, @nPerc, @nValorDesc, @oPercDesc, @oValorDesc, 2), NIL) }
	Else
		oPercDesc:bLostFocus := {|| nValorDesc := Round( nVlrMercAux * ( nPercDesc / 100 ), nDecimais ), oValorDesc:Refresh() }
	EndIf

	If ! lTouch

		DEFINE SBUTTON oBtn1 FROM 32, 50 TYPE 1 ENABLE OF oDlgDescTot PIXEL ;
			ACTION ( nOpc := 1,oDlgDescTot:End() )

		DEFINE SBUTTON oBtn2 FROM 32, 85 TYPE 2 ENABLE OF oDlgDescTot PIXEL ;
			ACTION ( nOpc := 0,oDlgDescTot:End() )
		// Para o caso do uso de displays a ordem de foco no incio eh diferente
		If lUsaDisplay
			// Capturar o handle do foco de cada item para utilizar na validacao quando utilizar o display
			oValorDesc:SetFocus()
			nHdlValor := GetFocus()

			oPercDesc:SetFocus()
			nHdlPerc := GetFocus()
		Endif

	Else
		// Definindo o Objeto Teclado
		// Definindo a Acao da tecla ENTER do Teclado oKeyb
		// Definindo o que fazer quando o Foco for obtido no Valor e Percentual de Desconto
		// Definindo onde o Foco deve iniciar na Dialog
		oKeyb := TKeyboard():New( 70, 20, 1, oDlgDescTot )
		//oKeyb:SetEnter({|| nOpc := 1,oDlgDescTot:End() })
		oKeyb:SetEnter({|| IIf (nValorDesc = 0 .OR. (nVlrDescBkp <> nValorDesc) ,nVlrDescBkp := nValorDesc := Fr271IAtuValor( nPerc, nPercDesc, nVlrTotal, nValorDesc), .T.), nOpc := 1, oDlgDescTot:End()})
		oKeyb:bEsc:={|| oDlgDescTot:End()}
		oValorDesc:bGotFocus	:= {|| oKeyb:SetVars(oValorDesc,TamSX3("L1_DESCONT")[1]) }
		oPercDesc:bGotFocus		:= {|| oKeyb:SetVars(oPercDesc,TamSX3("L2_DESC")[1]) }
		oValorDesc:SetFocus()
	EndIf

	If lUsaDisplay
		// Limpar as mensagens do display
		LjLimpDisp()
		//Enviar as mensagens para o teclado
		Frt272MsgDsc("T", "P")
	Endif

	ACTIVATE MSDIALOG oDlgDescTot ;
	ON INIT  IIf(!lTouch,oPercDesc:SetFocus(),);
	VALID Fr271IValDesc(Val(cTipoDesc),(nPercDesc + nVlrPercTot),(nValorDesc + nVlrDescTot),aItens , nDecimais);
	CENTERED

Else

	If nVlrDscRgr <> Nil
		nValorDesc	:= nVlrDscRgr
		nOpc		:= 1

		If cPaisLoc == "BRA"
			If( nPercDesc == 0, (nVlrPercBkp := nPercDesc := Round( 100 - ( ( ( nVlrBruto - nValorDesc) / (nVlrBruto - nTotDedIcms) ) * 100 ),2 ),;
								 nPerc 	:= 100 -   (( nVlrBruto - nValorDesc) / (nVlrBruto - nTotDedIcms)) * 100),NIL )
		Else
			If( nPercDesc == 0, ( nPercDesc := Round( 100 - ( ( ( nVlrMercAux - nValorDesc ) / nVlrMercAux ) * 100 ),2 )) , NIL )
		EndIf
	Else
		nPercDesc 	:= nPerDscRgr
		nOpc 		:= 1

		If cPaisLoc == "BRA"
			IIf( nVlrPercBkp <> nPercDesc , nPerc := nPercDesc,.T.)
			nValorDesc := Fr271IAtuValor( nPerc, nPercDesc, nVlrTotal, nValorDesc)
		Else
			nValorDesc := Round( nVlrMercAux * ( nPercDesc / 100 ), nDecimais )
		EndIf
	EndIf

EndIf

If nOpc == 0 //Botão cancelar zera as variaveis para nao ter problema de calcular o desconto.
	nValorDesc	:= 0
	nPercDesc	:= 0 
EndIf

Return ( Nil )	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frtx272T10 ºAutor ³Vendas Clientes     º Data ³  24/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza a troca do vendedor                                º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frtx272T10(cVendLoja, lAltVend, cVndLjAlt)

Local oDlgVend
Local oVendedor
Local oNomeVend
Local cVendedor 	:= cVendLoja
Local cNomeVend 	:= Subst(Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_NOME"),1,30)

DEFAULT cVndLjAlt	:= ""

DEFINE FONT oFnt2 NAME "Arial" SIZE 11.5,22 BOLD

	DEFINE MSDIALOG oDlgVend FROM  47,130 TO 200,550 TITLE STR0043 PIXEL	// "Alteração de Vendedor"
	@ 04, 05 TO 28, 70 LABEL STR0044 OF oDlgVend	PIXEL	// "Código do Vendedor"
	@ 13, 15 MSGET oVendedor VAR cVendedor SIZE 40, 10 OF oDlgVend F3 "SA3" PIXEL VALID ExistCpo("SA3",cVendedor)
	oVendedor:cSx1Hlp:="A3_COD"

	@ 30, 05 TO 54, 210 LABEL STR0045 OF oDlgVend PIXEL	// "Nome do Vendedor"
	@ 39, 15 MSGET oNomeVend VAR cNomeVend WHEN .F. PIXEL

	oVendedor:bLostFocus := { || cNomeVend := Subst(Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_NOME"),1,30), oNomeVend:Refresh() }

	DEFINE SBUTTON FROM 60, 135 oButton2 TYPE 1 ENABLE OF oDlgVend ;
	ACTION (lAltVend:=.T., cVndLjAlt := cVendLoja := cVendedor, oDlgVend:End()) PIXEL

	DEFINE SBUTTON FROM 60, 170 oButton3 TYPE 2 ENABLE OF oDlgVend ;
	ACTION (oDlgVend:End()) PIXEL

ACTIVATE MSDIALOG oDlgVend CENTERED

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTAPGPE  ºAutor  ³Vendas Clientes     º Data ³  14/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe o ponto de entrada.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt010PgPE(	cForma	, cDesc		, dData		, nNumParc	,;
							nTXJuros, nIntervalo, nValor	, cMoedaVen ,;
							nCall	, aPgtos	, nLinha)

Local xRet						// Retorno do ponto de entrada
Local lRet 			:= .T.		// Retorno Logico

DEFAULT cMoedaVen	:= ""		// Moeda da venda
DEFAULT aPgtos		:= {}		// Formas de pagamentos
DEFAULT nLinha		:= 0		// Numero da linha
DEFAULT nCall		:= 0		// Indica a funcao chamada

If ExistBlock("FRTFPag")
	xRet := ExecBlock(	"FRTFPag"	, .F.	, .F.		, {cForma	, ;
						cDesc		, dData	, nNumParc	, nTXJuros	, ;
						nIntervalo	, nValor, cMoedaVen , nCall		,;
						aPgtos		, nLinha} )

	If ValType( xRet ) == "N"
		nValor := xRet
	ElseIf ValType( xRet ) == "L"
		lRet   := xRet
	EndIf
EndIf

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frt272AQteºAutor  ³Vendas Clientes     º Data ³  16/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a variavel nTmpQuant esta ok                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Frt272AQte(nTmpQuant, oTmpQuant)

Local lRet  := .T.

If ValType(nTmpQuant) <> "N" .OR. nTmpQuant >= 10000
   lRet       := .F.
   nTmpQuant  := 1
   oTmpQuant:Refresh()
EndIf

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR272VldBc    ºAutor  ³Vendas Clientes     º Data ³  20/03/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida Banco													 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp1 - Banco													 º±±
±±º          ³cExp2 - Administradora										 º±±
±±º          ³nExp3 - Parcela												 º±±
±±º          ³nExp4 - Desconto												 º±±
±±º          ³lExp4 - Gera fin												 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³NIL                      	                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR272VldBc(cBanco, cDesc, nNumParc, nPreDes, lGerFin, cDesconto)

Local lRet 			:= .F.						// Retorno da fução
Local aRet 			:= {} 			 			// retorno com desconto
Local nTamAE_COD    := TamSX3("AE_COD")[1]		// Tamanho do campo AE_COD
Local cAdm			:= Frta272ADM(cDesc)		// Codigo Adm Fin

Default cBanco  	:= ""
Default cDesc       := ""
Default nNumParc    := 0
Default nPreDes  	:= 0
Default lGerFin     := .F.
Default cDesconto   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso não for lr5 e marametro .F., NÃO FAZ NADA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLjDesPa
	Return(.T.)
EndIf


If Empty(cBanco)
	lRet := .T.
Else
	aRet := LJ803GetMen(Substr( cAdm, 1, nTamAE_COD), cBanco , nNumParc)
	If Len(aRet) > 0
		nPreDes 	:= aRet[1][1]
		lGerFin 	:= aRet[1][2]
		cDesconto	:= cValToChar(aRet[1][1])
		lRet := .T.
	Else
		nPreDes 	:= 0
		lGerFin 	:= .F.
		cDesconto	:= "0"
		lRet := .F.
		Alert(STR0079) //"Não exite banco cadastrado para essa Administradora"
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRtVldAdm     ºAutor  ³Vendas Clientes     º Data ³  20/03/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atribui o lote para o campo do aCols na Venda Assistida 		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Loja701                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExp1 - Banco													 º±±
±±º          ³cExp2 - Administradora										 º±±
±±º          ³nExp3 - Parcela												 º±±
±±º          ³nExp4 - Desconto												 º±±
±±º          ³lExp5 - Gera fin												 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³NIL                      	                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRtVldAdm(	cBanco, 	cDesc, 		nNumParc, 	nPreDes, ;
							lGerFin, 	cDesconto, 	cForma, 	oDescBc, ;
							oBanco)

Local aRet 			:= {}             		//  retorno com desconto
Local nTamAE_COD    := TamSX3("AE_COD")[1]	// Tamanho do campo AE_COD
Local cAdm			:= Frta272ADM(cDesc)	// Codigo Adm Fin

Default cBanco  	:= ""
Default cDesc       := ""
Default nNumParc    := 0
Default nPreDes  	:= 0
Default lGerFin     := .F.
Default cDesconto   := ""
Default cForma		:= ""
Default oDescBc		:= Nil
Default oBanco		:= Nil
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso não for lr5 e marametro .F., NÃO FAZ NADA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLjDesPa .OR. !(cForma$ _FORMATEF)
	Return(.T.)
EndIf

aRet := 	LJ803GetMen(Substr( cAdm, 1, nTamAE_COD), cBanco, nNumParc, .T.)

If Len(aRet) > 0
	oDescBc:lVisible	:= .T.
	oBanco:lVisible		:= .T.
Else
	oDescBc:lVisible	:= .F.
	oBanco:lVisible		:= .F.
EndIf

nPreDes 	:= 0
lGerFin		:= .F.
cDesconto	:= "0"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega valor da parcela para fera f3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBkPar := nNumParc

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Frta272ADM³ Autor ³ Vendas Clientes      ³ Data ³ 06/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pega cod adm                          					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Frta272ADM(cExp1)					              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Descricao Adm									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frta272ADM(cDesc)

Local aAreaSAE 	:= GetArea("SAE")	//Area
Local cAdm		:= ""			 	//Recebe o Cod da Administradora financeira

Default cDesc	:= ""

DbSelectArea("SAE")
DbSetOrder(1)
DbSeek(xFilial("SAE"))
While !SAE->(EOF()) .AND. xFilial("SAE") == SAE->AE_FILIAL
	If AllTrim(SAE->AE_DESC) == cDesc
		cAdm	:= SAE->AE_COD
		Exit
	EndIf
	SAE->(dbSkip())
End

RestArea(aAreaSAE)

Return(cAdm)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FR272F3Bc	 ³ Autor ³ Vendas Clientes      ³ Data ³ 16/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida banco F3                                     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FR272F3Bc()			 		              		  	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR272F3Bc()

Local aRet := {} 							// Retorno com desconto
Local nTamAE_COD    := TamSX3("AE_COD")[1]	// Tamanho do campo AE_COD
Local cCodAdm		:= ""					// Codigo Adm
Local cDesc			:= ""					// Num
Local nParc			:= ""					// numero de parcela
Local cBanco		:= ""					// nome do baco


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera valor da variavel statica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FR272GeAd(@cDesc, @nParc)


cCodAdm := Frta272ADM(cDesc)	// Codigo Adm

aRet := LJ803GetMen(Substr(cCodAdm, 1, nTamAE_COD), '' , nParc, .T.)

If Len(aRet) > 0

	cBanco := LJ803Tela(aRet)

	aRet := LJ803GetMen(Substr(cCodAdm, 1, nTamAE_COD), cBanco , nParc)

	DbSkip(-1)
Else
	Alert(STR0086) // "Não exite Banco cadastrado para essa Administradora Financeira"
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FR272GeAd	 ³ Autor ³ Vendas Clientes      ³ Data ³ 16/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera inf para f3  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FR272GeAd()			 		              		  	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Descricao Adm									  ³±±
±±³          ³ nExp2 - Parcela									  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ LOJA701 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR272GeAd(cDesc, nParc)

Default cDesc := ""
Default nParc := ""

cDesc := cBkDesAdm
nParc := cBkPar

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Fr272ATxAd ³ Autor ³ Vendas CRM          ³ Data ³ 23/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o valor do juros conforme a administradora 		  ³±±
±±³          ³ selecionada pelo usuario									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fr272ATxAd(ExpC1,ExpN2,ExpN3,ExpC4,ExpL5)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 - Codigo da administradora de cartao   		      ³±±
±±³          ³ ExpN2 - Numero de parcelas								  ³±±
±±³          ³ ExpN3 - Porcentagem de juros cobrado pela administradora	  ³±±
±±³          ³ ExpC4 - Forma de pagamento CC ou CD						  ³±±
±±³          ³ ExpL5 - Verificando se esta habilitado o MV_LJJURCC		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Sempre .T.								          	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ FRTA272A													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr272ATxAd( cCodAdmin, nParc, nJurosAdm, cForma,;
					 lMvJurCc )

Local   nTxAdm   	:= 0	//Taxa de Juros em CC
Local	lPesq		:= .T.	//Variavel para retorno da funcao

DEFAULT cCodAdmin	:= ""
DEFAULT nParc   	:= 0
DEFAULT nJurosAdm	:= 0
DEFAULT cForma		:= ""
DEFAULT lMvJurCc	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra a Administradora para calculo de Juros em Cartao de Credito   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lMvJurCc) .AND. (AllTrim(cForma) $ _FORMATEF)
	DbSelectArea("MEN")
	DbSetOrder(2) //MEN_FILIAL+MEN_CODADM+MEN_BANCO
	If DbSeek(xFilial("MEN") + cCodAdmin)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Enquanto nao for o fim do arquivo e o Cod da Adm 	³
		//³ for igual o informado pelo usuario...   			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !Eof() .AND. AllTrim(MEN->MEN_CODADM) == AllTrim(cCodAdmin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso existe um intervalo cadastro para o numero de parcelas  ³
			//³ informado, retorna o valor da porcentagem de juros			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	If (MEN->MEN_PARINI <= nParc) .AND. (MEN->MEN_PARFIN >= nParc) .AND. (lPesq)
	    		nTxAdm := MEN->MEN_TAXJUR
	    		lPesq  := .F.
	    	EndIf
	    	DbSkip()
		End
	EndIf
EndIf

nJurosAdm := nTxAdm

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fr272AParc  ³ Autor ³ Vendas CRM          ³ Data ³ 23/03/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela com simulacao das parcelas a serem alteradas apos a   ³±±
±±³          ³ confirmacao da forma de pagamento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fr272AParc(ExpA1,ExpN2,ExpN3,ExpD4,ExpN5,ExpN6)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpA1 - Objeto modelo de dados da tabela MEN   		      ³±±
±±³          ³ ExpN2 - Numero de parcelas								  ³±±
±±³          ³ ExpN3 - Valor a ser pago em cartao de credito			  ³±±
±±³          ³ ExpD4 - Data base para soma dos vencimentos				  ³±±
±±³          ³ ExpN5 - Quantidade de casas decimais						  ³±±
±±³          ³ ExpN6 - Intervalo em dias para calculo das parcelas		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL										          	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ FRTA272A													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr272AParc( aTxJurAdm, nNumParc	, nValor, dData,;
					 nPosMoeda, nIntervalo	)

Local aParTmp	:= {} 					//Array para gravar as parcelas
Local nVlrAux 	:= 0 					//Valor total com juros
Local nX		:= 0 					//Variavel para o laco FOR
Local aHeaders	:= {STR0019, STR0021} 	//Descricao das colunas do browser "Data", "Valor"
Local aTamHead  := {70,30} 				//Definicao e tamanho das colunas do browser
Local nValParc	:= 0 					//Valor de cada parcela
Local nDif		:= 0 					//Diferenca de valores das parcelas
Local nVrJuros	:= 0					//Valor do juros
Local nVrSJuros	:= 0					//Valor total sem juros

DEFAULT aTxJurAdm 	:= {0,0,0}
DEFAULT nNumParc	:= 0
DEFAULT nValor		:= 0
DEFAULT dData		:= cToD("  /  /  ")
DEFAULT nPosMoeda	:= 0
DEFAULT nIntervalo	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a administradora escolhida tenha juros, mostra a tela de simulacao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aTxJurAdm) > 0) .AND. (aTxJurAdm[1] > 0)

	nVrSJuros	:= nValor
	nVrJuros	:= A410Arred(nValor * aTxJurAdm[1] / 100, "L2_VRUNIT")
	nValor		+= nVrJuros

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Divide o valor pago em CC pela qtda de parcelas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		nValParc := A410Arred(nValor/nNumParc,"L2_VRUNIT")
	Else
		If nNumParc > 1
			nValParc := Round(nValor/nNumParc, MsDecimais(nPosMoeda))
		Else
			nValParc := Round(nValor, MsDecimais(nPosMoeda))
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Subtraindo para verificar a diferenca a ser   ³
	//³ calculada sempre na ultima parcela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDif := A410Arred(nValor - (nValParc * nNumParc), "L2_VRUNIT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria um array temporario para calculo das parcelas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To nNumParc
		AAdd(aParTmp, {dData + If(nX = 1, 0, nIntervalo * (nX - 1)), nValParc})
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma a diferenca sempre na ultima parcela   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(aParTmp) > 0) .AND. (nDif <> 0)
		aParTmp[Len(aParTmp)][2] += nDif
	EndIf

	DEFINE MSDIALOG oDlgTx FROM 0,0 TO 330,402 PIXEL TITLE STR0080 //"Simulação de Parcelas com Juros em Cartão de Credito"
	DEFINE SBUTTON FROM 145,173 TYPE 1 ACTION (oDlgTx:End()) ENABLE OF oDlgTx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criando um novo browser para simulacao das parcelas  ³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowseTx := TCBrowse():New( 5,5,194,130, ,aHeaders,aTamHead,;
	                oDlgTx,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Setando o conteudo do array temporario para o browser ³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowseTx:SetArray(aParTmp)
	oBrowseTx:bLine := {||{ aParTmp[oBrowseTx:nAt,1],TRANSFORM(aParTmp[oBrowseTx:nAt,2],PesqPict("SL2", "L2_VRUNIT")) } }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria label Taxa de Juros   ³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 138, 5 SAY STR0081 PIXEL OF oDlgTx 																//Taxa de Juros..:
	@ 138, 80 SAY aTxJurAdm[1] PICTURE "@E 99.99%" PIXEL RIGHT SIZE 28,0 OF oDlgTx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria label Total sem Juros ³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 148, 5 SAY STR0082 PIXEL OF oDlgTx 																//Total sem Juros:
	@ 148, 80 SAY nVrSJuros PICTURE PesqPict("SL2", "L2_VRUNIT") COLOR CLR_HBLUE PIXEL RIGHT SIZE 28,0 OF oDlgTx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria label Total com Juros ³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 156, 5 SAY STR0083 PIXEL OF oDlgTx 																//Total com Juros:
	@ 156, 80 SAY nValor PICTURE PesqPict("SL2", "L2_VRUNIT") COLOR CLR_HRED PIXEL RIGHT SIZE 28,0 OF oDlgTx

	ACTIVATE MSDIALOG oDlgTx CENTERED

	oDlgTx		:= NIL
	oBrowseTx	:= NIL

EndIf

Return NIL

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Frt272VDPe
Funcao para validar se o campo de percentual de desconto pode perder o foco ou nao.
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param     nHdlVal Identificador do objeto do Get referente ao valor de desconto
@param		cTipoDesc Tipo do Desconto onde "I"=Desconto por Item e "T"=Desconto no Total da Venda
@return    lRet .T.: Mudanca de foco autorizada; .F.: Mudanca de foco nao autorizada
@version	P11
@since	24/12/2014
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function Frt272VDPe(nHdlVal, cTipoDesc)

Local lRet := .F.					// Variavel de retorno da funcao
Local nHdlNext := GetFocus()	// Identificador do objeto do que vai ganhar o foco na sequencia

DEFAULT nHdlVal		:= 0
DEFAULT cTipoDesc		:= "I"

// O foco vai ser passado para o campo do valor
If !(nHdlNext == nHdlVal)
	lRet := .T.
	Return lRet
Endif

// Limpar as mensagens do display
LjLimpDisp()

//Enviar as mensagens para o teclado
DisplayEnv(StatDisplay(), "1E" + STR0090 )		// ### "Alterar o Desconto para R$?"
DisplayEnv(StatDisplay(), "2E" + STR0091 )		// ### "<ENTER> - Confirma"
DisplayEnv(StatDisplay(), "3E" + STR0092 )		// ### "<ESC>   - Cancela"

lRet := MsgYesNo(STR0090, STR0093)		// ### "Alterar o Desconto para R$?" ### "Desconto"

// Limpar as mensagens do display
LjLimpDisp()

// Apresentar a mensagem para o usuario digitar o Desconto
If lRet
	Frt272MsgDsc(cTipoDesc, "V")	// Solicitar digitar Desconto em R$
Else
	Frt272MsgDsc(cTipoDesc, "P")	// Solicitar digitar Desconto em %
Endif

Return lRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Frt272VDPe
Funcao para validar se o campo de valor de desconto pode perder o foco ou nao.
Eh utilizado somente para uso com teclados com display
@author	Vendas Cliente
@param     nHdlPerc Identificador do objeto do Get referente ao percentual de desconto
@param		cTipoDesc Tipo do Desconto onde "I"=Desconto por Item e "T"=Desconto no Total da Venda
@return    lRet .T.: Mudanca de foco autorizada; .F.: Mudanca de foco nao autorizada
@version	P11
@since	29/12/2014
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function Frt272VDVa(nHdlPerc, cTipoDesc)

Local lRet := .F.					// Variavel de retorno da funcao
Local nHdlNext := GetFocus()	// Identificador do objeto do que vai ganhar o foco na sequencia

DEFAULT nHdlPerc := 0
DEFAULT cTipoDesc		:= "I"

// O foco vai ser passado para o campo do percentual
If !(nHdlNext == nHdlPerc)
	lRet := .T.
	Return lRet
Endif

// Limpar as mensagens do display
LjLimpDisp()

//Enviar as mensagens para o teclado
DisplayEnv(StatDisplay(), "1E" + STR0094 )		// ### "Alterar o Desconto para % ?"
DisplayEnv(StatDisplay(), "2E" + STR0091 )		// ### "<ENTER> - Confirma"
DisplayEnv(StatDisplay(), "3E" + STR0092 )		// ### "<ESC>   - Cancela"

lRet := MsgYesNo(STR0094, STR0093)	// ### "Alterar o Desconto para % ?" ### "Desconto"

// Limpar as mensagens do display
LjLimpDisp()

// Apresentar a mensagem para o usuario digitar o Desconto
If lRet
	Frt272MsgDsc(cTipoDesc, "P")	// Solicitar digitar Desconto em %
Else
	Frt272MsgDsc(cTipoDesc, "V")	// Solicitar digitar Desconto em R$
Endif

Return lRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Frt272MsgDsc
Funcao para apresentar a mensagem no Display Gertec solicitando o usuario digitar o desconto
@author	Vendas Cliente
@param     cTipoDesc Tipo do Desconto onde "I"=Desconto por Item e "T"=Desconto no Total da Venda
@param     cFormaDesc Forma do Desconto onde "P"=Percentual e "V"=Valor
@return    Nil
@version	P11
@since	06/11/2015
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function Frt272MsgDsc(cTipoDesc, cFormaDesc)

Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))		//³ Verifica se a estacao possui Display ³

DEFAULT cTipoDesc		:= "I"		// Desconto por Item
DEFAULT cFormaDesc	:= "P"		// Desconto por Percentual

If !lUsaDisplay
	Return Nil
EndIf

If cTipoDesc == "I"
	DisplayEnv(StatDisplay(), "1E" + STR0017 + "|" )		// ### "Desconto no total do item"
ElseIf cTipoDesc == "T"
	DisplayEnv(StatDisplay(), "1E" + STR0022 + "|" )		// ### "Desconto no total do cupom
Endif

If cFormaDesc == "P"
	DisplayEnv(StatDisplay(), "2E" + STR0095 + "|" )		// ### "Digite o desconto em %:"
ElseIf cFormaDesc == "V"
	DisplayEnv(StatDisplay(), "2E" + STR0096 + "|" )		// ### "Digite o desconto em R$:"
Endif

Return Nil 

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Frt272aTTroco
Função de Validaçao do Get oValor , valor de pagamento, essa função realiza o tratamento para o troco. 
Realiza o tratamento do Troco, Quando o parametro MV_LJTROCO contiver mais de uma forma de pagamento 
para o troco o Sistema vai entender que a forma de pagamento que ultrapassar o valor total das mercadorias será a 
forma que concedeu o troco.
 
 Regra para a utilização do MV_LJPGTRO caso possua uma forma de pagamento diferente de dinheiro o Troco será atribuido
 para a forma que ultrapassar o valor da venda.
 Exemplificando o motivo: uma venda de 100,00 pago com 50 em dinheiro depois 100,00 em cheque.
 
@author	Vendas Cliente
@param     
@param     
@return    .T. ou .F.
@version	P11
@since	06/11/2015
/*/
//------------------------------------------------------------------------------------------------------------------

Static Function Frt272ATTroco(cForma,lTroco1,lUsaTroco,cMV_LJPGTRO,nValOri,nValor,nValMax)
Local lRet        := .F.

Default cForma  := ""
Default lTroco1 := .F.

If nValor > nValOri 
	// Se o parametro estiver desativado ou o campo de troco nao esteja  criado o sistema nao aceita valores para troco.
	If lUsaTroco .AND. lTroco1
		If ( cForma  $ cMV_LJPGTRO )			
			lRet := .T.	
			cFormTroco := cForma +"|" + AllTrim(Str(nValor)) 
		ElseIf cForma == "R$" // Se for Dinheiro aceita troco mesmo se nao estiver no parametro			
			lRet := .T.
			cFormTroco := cForma
		EndIf		 
	EndIf
Else	
	lRet := .T.
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Frt272Send
Função para Modificar o valor da variavel estatica cFormTroco para que nao fique sujeira 
 
@author	Vendas Cliente
@param     
@param     
@return    
@version	P11
@since	06/10/2016
/*/
//------------------------------------------------------------------------------------------------------------------

Function Frt272Send(cFormaPg)
Default cFormaPg := ""

	If Valtype(cFormaPg) <> "C"
		cFormTroco := ""	
	Else 	
		cFormTroco := cFormaPg
	EndIf	
Return()

//-----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Frt272Get
Função para que seja possivel o retorno do valor da variavel estatica cFormTroco 
@author	Vendas Cliente
@param     
@param     
@return    
@version	P11
@since	06/10/2016
/*/
//-----------------------------------------------------------------------------------------------------------------

Function Frt272Get()
	 
Return(cFormTroco)

