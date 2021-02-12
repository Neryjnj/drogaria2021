#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA273A.CH"
#INCLUDE "ADVCTRLS.CH"

Static oFntMoeda                             //Fonte
Static oMensagem                             //Mensagem
Static cMensagem 	:= ""

Static oTimer
Static oHora
Static cHora		:= ""		       	
Static oDoc
Static cDoc			:= ""
Static oPDV
Static cPDV 		:= "    "
Static oMoedaCor
Static cMoeda		:= ""
Static oTaxaMoeda
Static nTaxaMoeda	:= 0
Static oTemp3
Static oTemp4
Static oTemp5
Static cCodProd		:= ""
Static oDesconto
Static nVlrBruto	:= 0
Static nQuant		:= 1
Static oCupom 
Static aFormas 	:= {}
Static lF7		:= .F.     
Static _lOK		:= .F.   
Static lFrtGetPr		:= ExistBlock("FRTGETPR")      
Static nLastTotal	:= 0
Static nVlrTotal		:= 0
Static nLastItem		:= 0
Static nTotItens		:= 0
Static oVlrTotal	
Static oTotItens
Static oOnOffLine
Static nTmpQuant	:= 1
Static nVlrItem		:= 0
Static nValIPIIT	:= 0
Static nValIPI		:= 0
Static oFotoProd
Static oProduto
Static oQuant
Static oVlrUnit
Static oVlrItem
Static cSimbCor		:= ""
Static cProduto		:= ""
Static nQuant		:= 0
Static cUnidade		:= ""
Static nVlrUnit		:= 0
Static oUnidade
Static cNCartao		:= ""
Static oPgtos	    
Static oPgtosSint
Static aPgtos		:= {}
Static aPgtosSint	:= {}
Static cOrcam		:= CriaVar("L1_NUM")
Static lTefPendCS	:= .F.
Static aTefBKPCS	:= {}  
Static oTmpQuant	
Static cTmpQuant	:= ""	
Static cQtd			:= "1"
Static oOrigBtns    := nil
Static nBtnWidth    := 34 * 2
Static nBtnHeight   := 25 * 2
Static nBtnSpace    := 2 * 2
Static nBtnPerLin   := 9
Static nBtnPerCol   := 6
Static aBtnObjects  := {}
Static aOpGer		:= {}		// Array com os botoes de operacoes gerenciais
Static aOpVen		:= {}		// Array com os botoes de operacoes de venda
Static aItens		:= {}
Static aICMS		:= {}
Static nVlrMerc 	:= 0  
Static _aMult		:= {}
Static _aMultCanc	:= {}
Static lOrc			:= .F.
Static lEsc			:= .F.
Static aParcOrc		:= {}
Static cItemCOrc	:="" 
Static aParcOrcOld  := {}
Static aKeyFimVenda := {}
Static nHdlOPE
Static lExitNow		:= .F.								// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
Static lAltVend		:= .F.
Static lImpNewIT	:= .F.								// Indica se foi adicionado um novo item ao orcamento
Static lFechaCup 	:= .T.								// Indica se houve algum erro no fechamento do CF
Static aTpAdmsTmp   := {}
Static cUsrSessionID:= ""								// Variavel para login na transacao Web Service
Static cContrato 	:= ""              					// Numero do contrato da transacao de credito
Static aCrdCliente  := {"",""}     						// Informacao do cliente p/Private Label [1]-CNPJ/CPF [2]-Numero do Cartao Private Label 
Static aContratos   := {}          						// Numero de contrato gerado pela venda. Utilizado nos casos em que deve cancelar o contrato pendente 
Static aRecCrd		:= {}								// Guarda as parcelas de financiamento para impressao do comprovante de recebimento	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aTEFPend          ³
//³[1] Forma de pagamento(CC, CD)       ³
//³[2] ID + Administradora              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static aTEFPend    	:= {}           					// Parcelas que estao pendentes no TEF multiplas transacoes. Esta situacao ocorre quando a segunda eh rejeitada, por ex.   
Static aBckTEFMult 	:= {}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                O B S E R V A C A O                                              //
//*****************************************************************************************************************//
// - A variável uCliTPL foi criada para ser utilizada pela equipe de Templates. Ela poderá receber, como retorno   //
// da Template Function "FRT010CL", qualquer tipo de valor. O tratamento da variável deverá ser realizado          //
// nas rotinas específicas do depto. de Templates.                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static uCliTPL      
Static uProdTPL	//armazena informacoes referente aos produtos que estao sendo vendidos.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Static de Templates. Codigo e loja do conveniado, utilizadas para implementacao de convenio    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static cCodConv     := ""	// codigo do cliente conveniado
Static cLojConv     := ""	// loja do conveniado
Static cNumCartConv := ""	// numeracao do cartao do cliente conveniado
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis Static de uso do Template Drogaria ³
//³Usada nas rotinas relacionadas a VIDALINK.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static aVidaLinkD	:= {}						//array de detalhe (produto,qtde,preco) com o orcamento gerado no PBM VidaLink
Static aVidaLinkc	:= {}						//array cabecalhoe (Cliente,loja,etc) do orcamento gerado no PBM VidaLink
Static nVidaLink	:= 0 						//Indica se Itens veio do VidaLink. 0=Nao usa VidalInk. 1=Gravando VidaLink. 2=Gravou VidaLink

Static lDescTotal	:= .F.						// Valida de foi dado desconto no total do cupom, caso seja concomitante
Static lDescSE4		:= .F.						// Valida de foi dado desconto na condicao de pagamento
Static cCdPgtoOrc   := ""						// Condicao de pagamento
Static cCdDescOrc   := ""						// Descricao condicao de pagamento
Static nValTPis		:= 0						// Valor total do PIS
Static nValTCof		:= 0						// Valor total do COFINS
Static nValTCsl		:= 0						// Valor total do CSLL
Static lOrigOrcam	:= .F.						// Origem da Condicao de Pagamento
Static lVerTEFPend 	:= .F.      				// Controla se deve verificar se ha transacao TEF pendente ao final da venda
Static nTotDedIcms  := 0                       	// Total de deducao do ICMS
Static lImpOrc		:= .F.                 		// Controla se o orcamento foi importado da Retaguarda
									
Static nVlrPercTot	:= 0						// PERCENTUAL DE DESCONTO
Static nVlrPercAcr	:= 0						// PERCENTUAL DE ACRESCIMO
Static nVlrAcreTot	:= 0						// VALOR DO ACRESCIMO
Static nVlrDescCPg	:= 0						// VALOR DO DESCONTO CONCEDIDO VIA CONDICAO DE PAGAMENTO (SE4)
Static nVlrPercOri 	:= 0                       	// PERCENTUAL DE DESCONTO ORIGINAL
Static nQtdeItOri  	:= 0						// QTDE ORIGINAL DE ITENS DA VENDA       
Static nNumParcs   	:= 0        				// NUMERO DE PARCELAS
Static nMoedaCor  	:= 1
Static nDecimais  	:= MsDecimais(nMoedaCor)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|¿
//³Estas variaveis contem, respectivamente, o numero do cartao, cpf ou contrato, informados na tela de recebimentos³
//³no LOJXREC.                                                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|Ù
Static cRecCart   	:= ""
Static cRecCPF    	:= ""
Static cRecCont   	:= ""

Static aImpsSL1  	:= {}
Static aImpsSL2  	:= {}
Static aImpsProd 	:= {}   //Array original com as mesmas informacoes do aImpsSL2. Usado para os recalculos. 
Static aImpVarDup	:= {}
Static aTotVen   	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis de Localizacoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static cCalcImpV	:= SuperGetMV("MV_GERIMPV")
Static nTotalAcrs 	:= 0	
Static lTroca 		:= .F.
Static lValTot  	:= SuperGetMV("MV_VALTOTA")  	//Verifica se valida ou nao o total da fatura com o que foi pago
Static lRecalImp	:= .F.                  			//Verifica se foi recalculado os impostos devido 
Static aCols     	:= {}
Static aHeader   	:= {}
Static aDadosJur 	:= {0,0,0,0,0,0,0,0,0}
Static aCProva   	:= {}                 	
                                         		//a um desconto ou acrescimo                                      		
Static lBalanca
Static aNCCItens  	:= {}
Static aFormCtrl	:= {}						//Controle das Formas de Pagamento Solicitadas
Static nTroco2		:= 0							//Armazena o valor do troco que devera ser gravado em L1_TROCO1,													//Para geracao de movimentacao bancaria local e na retaguarda
Static nTroco		:= 0							//Armazena o valor do troco que devera ser gravado em L1_TROCO1,													//Para geracao de movimentacao bancaria local e na retaguarda
Static lDescCond	:= .F.
Static nDesconto	:= 0
Static aDadosCH		:= {} 	

Static cItemCond	:= "CN"
Static lCondNegF5	:= .F.
Static lDiaFixo		:= .F.
Static nTxJuros	 	:= 0
Static nValorBase	:= 0
Static aTefMult		:= {}
Static aTitulo		:= {}
Static lConfLJRec	:= .F.
Static aTitImp 		:= {}		// declaracao do array responsavel por armazenar as informacoes necessarias para a impressao do recebimento nao fiscal - LJGRVREC
Static aParcelas 	:= {}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FRT273TS  ³ Autor ³ Mauro Sano            ³ Data ³11/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Interface Touch-Screen do Front-Loja                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos R.     ³05/04/07³123140|Verificacao se o tef esta aberto        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³Conrado Q.    ³01/10/07³133788³Retirado o uso da variável ltTefAberto  ³±±
±±³              ³        ³      ³como local.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRT273TS(	cImpressora	, cCliente		, cLojaCli		, cVendLoja		,;
					lOcioso		, lRecebe		, lLocked		, lCXAberto		,;
					lDescIT		, lDescITReg	, aTefDados		, dDataCN		,;
					nVlrFSD		, nVlrDescTot	, aMoeda		, aSimbs		,;
					cPorta		, cSimbCheq		, cEstacao		, lTouch 		,;
					aRegTEF		, lRecarEfet	, lCancItRec    , lUsaDisplay	,;
					nTaxaMoeda	, aHeader		, nVlrDescIT	, cTipoCli		,;
					lBscPrdON	, nConTcLnk		, cEntrega		, aReserva		,;  
					lReserva	, lAbreCup		, nValor		, cCupom		,;
					cVndLjAlt	, cCliCGC)

// Variaveis Locais da Funcao
Static oFntCupom			// Objeto com as caracteristicas da fonte da list do cupom fiscal              
Static oFntProd				// Objeto com as caracteristicas da fonte dos botoes de produto              
Static oFntNum				// Objeto com as caracteristicas da fonte do teclado numerico
Static oFntOutros			// Objeto com as caracteristicas das outras fontes 
Static oFntMsg				// Objeto com as caracteristicas da fonte do quadrante 2
Static oFntGet
Static oPrincipal			// Panel principal	
Static oQdt1				// Objeto do quadrante 1
Static oQdt2				// Objeto do quadrante 2
Static oQdt3				// Objeto do quadrante 3
Static oQdt4    			// Objeto do quadrante 4
Static oCodProd                                
Static cCodProd		:= ""
// Variaveis Private da Funcao
Static oDlg												// Dialog Principal   

Local oButtons      := nil        						// Objeto com estrutura de botoes e grupos
Local aBotoes		:= {}								// Array com os botoes de produtos  
Local aMenu			:= {}								// Recebe o aBotoes
Local cUsaTe		:= SuperGetMV( "MV_LJUSATL", .T., "D" ) 
Local aCupom		:= {"","","","","","","","","","","","","","","","","",""}  
Local lRetF3		:= .F.
Local oOpGer2											//Botoes de gerenciamento
Local oOpGer3											//Botoes de gerenciamento

Local lResume		:= .F.								// Retoma a Venda do Ponto em Que Parou

DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.
DEFAULT lCancItRec	:= .F.
DEFAULT cCupom	:= ""		// Memo do cupom fiscal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Balanca Serial       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lBalanca := SLG->(FieldPos("LG_PORTBAL")) > 0 .AND. !Empty(LjGetStation('BALANCA')+LjGetStation('PORTBAL'))

If CrdxInt()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa as variaveis staticas que controlam a analise de credito feita pelo sigacrd³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fr271ICrdSet(@cContrato	, @aCrdCliente	,  @aContratos	, @aRecCrd)
	
EndIf   

  
DEFINE MSDIALOG oDlg FROM C(000), C(000) TO C(520),C(850) PIXEL OF GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP)


    // Principal
	@ C(000),C(010) MSPANEL oPrincipal SIZE C(410),C(275) OF oDlg  
	@ C(000),C(002) TO C(274),C(409) PIXEL OF oPrincipal
	
	If cUsaTe == "D"  	

		// Quadrante 1  
		@ C(004),C(002) MSPANEL oQdt1 SIZE C(130),C(145) OF oPrincipal 
		@ C(001),C(001) TO C(143),C(128) PIXEL OF oQdt1      // alteracao tela

	    // Quadrante 3
	    @ C(005),C(133) MSPANEL oQdt3 SIZE C(228),C(266) OF oPrincipal
		@ C(000),C(000) TO C(263),C(226)PIXEL OF oQdt3  // alteracao tela

	   	// Quadrante 2
	   	@ C(145),C(002) MSPANEL oQdt2 SIZE C(130),C(126) OF oPrincipal 
	 	@ C(001),C(001) TO C(124),C(128) PIXEL OF oQdt2	

	    // Quadrante 4
		@ C(005),C(360) MSPANEL oQdt4 SIZE C(044),C(265) OF oPrincipal
		@ C(000),C(000) TO C(265),C(043) PIXEL OF oQdt4 

	Else	// Uso pelo canhoto

		// Quadrante 1  
		@ C(005),C(283) MSPANEL oQdt1 SIZE C(130),C(145) OF oPrincipal 
		@ C(000),C(001) TO C(143),C(128) PIXEL OF oQdt1      

	    // Quadrante 3
	    @ C(003),C(001) MSPANEL oQdt3 SIZE C(282),C(145) OF oPrincipal
		@ C(000),C(000) TO C(142),C(281)PIXEL OF oQdt3  
		
	   	// Quadrante 2
	   	@ C(145),C(283) MSPANEL oQdt2 SIZE C(130),C(126) OF oPrincipal 
	 	@ C(001),C(001) TO C(124),C(128) PIXEL OF oQdt2	
 	
	    // Quadrante 4
		@ C(145),C(001) MSPANEL oQdt4 SIZE C(282),C(126) OF oPrincipal
		@ C(000),C(000) TO C(124),C(280) PIXEL OF oQdt4

	Endif
			
    // Define as fontes dos botoes                             
    DEFINE FONT oFntCupom	NAME "Courier New"	SIZE C(6),C(14)			// Cupom Fiscal
    DEFINE FONT oFntProd	NAME "Arial"   		SIZE 7,19			// Botoes de Produto 
    DEFINE FONT oFntNum		NAME "Arial"		SIZE 12,19			// Teclado Numerico 
    DEFINE FONT oFntoutros	NAME "Arial"		SIZE 6,19			// Teclado Numerico     
    DEFINE FONT oFntMsg     NAME "Arial" 		SIZE 10,19			// Says do quadrante 2
    DEFINE FONT oFntGet		NAME "Arial" 		SIZE 14,38			// Produto, Preco       
    DEFINE FONT oFntTot		NAME "Arial" 		SIZE 14,28			// Produto, Preco       

   	If cPaisLoc == "BRA"
		oCupom := TMultiget():New(001,001,{|u|if(Pcount()>0,(cCupom:=u,oCupom:GoEnd()),cCupom)},oQdt1,;
			152	,164, oFntCupom							 ,.F.	,;
			NIL	,NIL, NIL 								 ,.T.	,;
			NIL	,NIL, NIL								 ,NIL	,;
			NIL	,.T.,									 ,NIL	,;
			NIL	,.F., .T.								 )

	Else
		oCupom := TMultiget():New(001,001,{|u|if(Pcount()>0,cCupom:=u,cCupom)},oQdt1,;
			152	,164, oFntCupom							 ,.F.	,;
			NIL	,NIL, NIL 								 ,.T.	,;
			NIL	,NIL, NIL								 ,NIL	,;
			NIL	,.T.,									 ,NIL	,;
			NIL	,.F., .T.								 )
                               
	EndIf   	

    // Get do quadrante 2 
    cCodProd := Space(TamSX3("BI_DESC")[1])
    @ C(095),C(003) MSGET oCodProd VAR cCodProd FONT oFntGet  PIXEL SIZE C(100),C(020) COLOR CLR_BLACK;
		             PICTURE "@R"  OF oQdt2 //F3 "FRT"      
	// Botao para F3 ao lado do GET do Produto no Quadrante 2
	TAdvButton():New(;
		oQdt2,;
		C(105),; //93
		C(095),; //100
		C(016),;
		C(023),;
		"?",;
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():New( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ || lRetF3 := ConPad1(, , , "FRT" , , , .F. ) , If(lRetF3,(cCodProd := SBI->BI_COD,oCodProd:Refresh()),(cCodProd := Space(TamSX3("BI_DESC")[1]),oCodProd:Refresh())) , (If(!_lOK.AND.!Empty(cCodProd),(_lOK:=.T.,aKeyAux := FrtSetKey(),;
						 FR271AProdOK(					,				,				, .T.			,; 
						 			@cCodProd		, @oTimer		, @oHora		, @cHora		,;
									@oDoc			, @cDoc			, @oPDV			, @cPDV			,; 		
									@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
									@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
									@oOnOffLine		, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
									@nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
									@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
									@cOrcam			, @cProduto		, @nQuant		, @cUnidade		,;	
									@nVlrUnit		, @oUnidade		, @lF7   		, @cQtd			,;
									@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
									@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
									@nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,;
									@_aMult			, @_aMultCanc	, @lOrc			, @aParcOrc		,;
									@cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
									@lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
									@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
									@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
									@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,; 
									@nVidaLink 		, @nValTPis		, @nValTCof		, @nValTCsl		,;
									@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
									@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
									@aMoeda			, @aSimbs		, @nMoedaCor	, @nDecimais	,;
									@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
									@aTotVen		, @aCols		, @nVlrPercIT	, @nTaxaMoeda	,;
									@aHeader		, @nVlrDescIT	, @oMensagem	, @oFntMoeda	,;
									@cMensagem		, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
									@cEntrega	  	, @aReserva		, @lReserva 	, @lAbreCup		,;
									@nValor			, @cCupom		, @cVndLjAlt	, @cCliCGC		,;
									@aRegTEF		, @lRecarEfet	, @lDescITReg	),;
						 FR271AInitIT(	.T.			,	@lF7		, @cCodProd		, @cProduto	,;
										@nTmpQuant	,	@nQuant		, @cUnidade		, @nVlrUnit	,;	
										@nVlrItem	,	@oProduto	, @oQuant		, @oUnidade	,;	
										@oVlrUnit	,	@oVlrItem	, @oDesconto	, @cCliente	,;	
										@cLojaCli)	,;
						 If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),;
						 FrtSetKey(aKeyAux),If (lUsaDisplay,(DisplayEnv(StatDisplay(), "2E"+ "STR0003" + cCodProd),;
						 DisplayEnv(StatDisplay(), "1E"+ " ")),),_lOK:=.F.),), If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),),),oCodProd:SetFocus()},;
						nil )

	cProduto	:= Space(TamSX3("BI_DESC")[1])	
		
	If cPaisLoc == "BRA"
		oCodProd:bLostFocus := {|| If(!_lOK.AND.!Empty(cCodProd),(_lOK:=.T.,aKeyAux := FrtSetKey(),;
							 FR271AProdOK(					,				,				, .T.			,; 
								 			@cCodProd		, @oTimer		, @oHora		, @cHora		,;
											@oDoc			, @cDoc			, @oPDV			, @cPDV			,; 		
											@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
											@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
											@oOnOffLine		, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
											@nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
											@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
											@cOrcam			, @cProduto		, @nQuant		, @cUnidade		,;	
											@nVlrUnit		, @oUnidade		, @lF7   		, @cQtd 		,;
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
											@aTotVen		, @aCols		, @nVlrPercIT	, @nTaxaMoeda	,;
											@aHeader		, @nVlrDescIT	, @oMensagem	, @oFntMoeda	,;
											@cMensagem		, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
											@cEntrega	  	, @aReserva		, @lReserva		, @lAbreCup		,;
											@nValor			, @cCupom		, @cVndLjAlt	, @cCliCGC		,;
											@aRegTEF		, @lRecarEfet	, @lDescITReg	),;
								 FR271AInitIT(.T.,			@lF7, 		@cCodProd, 	@cProduto	,;
												@nTmpQuant,	@nQuant,	@cUnidade, 	@nVlrUnit	,;	
												@nVlrItem,	@oProduto,	@oQuant,	@oUnidade	,;	
												@oVlrUnit,	@oVlrItem,	@oDesconto, @cCliente	,;
												@cLojaCli)	,;
								 If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),;
								 FrtSetKey(aKeyAux),If (lUsaDisplay,(DisplayEnv(StatDisplay(), "2E"+ "STR0003" + cCodProd),;
								 DisplayEnv(StatDisplay(), "1E"+ " ")),),_lOK:=.F.),), If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),), }					// "Codigo do Produto: "
	Else   
        oCodProd:bLostFocus := {|| If(!_lOK .AND. !Empty(cCodProd),(_lOK:=.T.,aKeyAux := FrtSetKey(),If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),),;
        							FR271AProdOK(					,				,				, .T.			,;
	        									@cCodProd		, @oTimer		, @oHora		, @cHora		,;
												@oDoc			, @cDoc			, @oPDV			, @cPDV			,; 		
												@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
												@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
												@oOnOffLine		, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
												@nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
												@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
												@cOrcam			, @cProduto		, @nQuant		, @cUnidade		,;	
												@nVlrUnit		, @oUnidade		, @lF7   		, @cQtd			,;
												@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
												@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
												@nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,;
												@_aMult			, @_aMultCanc	, @lOrc			, @aParcOrc		,;
												@cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
												@lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
												@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
												@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL 	,;
												@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,; 
												@nVidaLink		, @nValTPis		, @nValTCof		, @nValTCsl		,;
												@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
												@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
												@aMoeda			, @aSimbs		, @nMoedaCor	, @nDecimais	,;
												@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
												@aTotVen		, @aCols		, @nVlrPercIT	, @nTaxaMoeda	,;
												@aHeader		, @nVlrDescIT	, @oMensagem	, @oFntMoeda	,;
												@cMensagem		, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
												@cEntrega	  	, @aReserva		, @lReserva		, @lAbreCup		,;
												@nValor			, @cCupom		, @cVndLjAlt	, @cCliCGC		,;
												@aRegTEF		, @lRecarEfet	, @lDescITReg	),;
        							If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),FrtSetKey(aKeyAux),_lOK:=.F.),)}	
    EndIf
	oCodProd:bGotFocus  := {|| If(lUsaLeitor , LeitorFoco(nHdlLeitor,.T.), nil), ;
							   If(lUsaDisplay, ; 
							      Eval( { || DisplayEnv(StatDisplay(), "2E"+ "STR0003"), ;
							                 If(lCXAberto .AND. !Empty(cCodProd),DisplayEnv(StatDisplay(), "1E" + Substr(cProduto,1,10) + " " + ;
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Teclas de Atalho ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FRTSetKey({	{|| FR271AAbreCX(	@oCupom		, @cCupom		, @CPDV			, @lCXAberto	,;
									@nHdlOPE)},;										// F4  - Abre Caixa
				{|| FR271EFechaCX(	@oCupom		, @cCupom		, @CPDV			, @lOcioso		,; 
								@lRecebe		, @lCXAberto	, @nHdlOPE)},;										// F5  - Fecha Caixa
				{|| FR271EDescIT(	@oCupom		, @oDesconto	, @nVlrPercIT	, @nVlrTotal	,;
									@lRecebe	, @lDescIT		, @lDescITReg	, @nVlrBruto	,;
									@aItens		, @nMoedaCor	, @nDecimais	, @lCXAberto	)},;					// F6  - Desconto no Item
				{|| AtuQtd( "?" )},;	  														// F7  - Altera Quantidade
				{|| FR271ECancIT(@oCupom		, @oVlrTotal	, @nVlrTotal	, @nVlrBruto	,;
							  @nMoedaCor	, @nTotItens	, @oTotItens	, @oTmpQuant	,;
						 	  @nTmpQuant	, @oCodProd		, @cCodProd		, @nTaxaMoeda	,;
						 	  @cOrcam		, @lRecebe		, @aItens		, @_aMultCanc	,;
						 	  @uCliTPL		, @uProdTPL		, @nTotDedIcms	, @aMoeda		,;
						 	  @aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,; 
						 	  @aTotVen		, @aCols		, @aHeader		, @lCXAberto	,;
						 	  @aRegTEF		, @lRecarEfet	, @lCancItRec)},;					// F8  - Cancelamento do Item			
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
									@lTefPendCS 	, @aTefBKPCS	, @oDlg 		, @cCliente		,;	
									@cLojaCli		, @cVendLoja	, @lOcioso		, @lRecebe		,;
									@lLocked		, @lCXAberto	, @aTefDados	, @dDataCN		,;
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
									@lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	,;
									@nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	, @nNumParcs	,;
									@aMoeda			, @aSimbs		, @cRecCart		, @cRecCPF		,; 
									@cRecCont		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,; 
									@aImpVarDup		, @aTotVen		, @nTotalAcrs	, @lRecalImp	,;
									@aCols			, @aHeader 		, @aDadosJur	, @aCProva		,;
									@aFormCtrl		, @nTroco		, @nTroco2 		, @lDescCond	,; 
									@nDesconto		, @aDadosCH		, @cItemCond	, @lCondNegF5	,;
									@nTxJuros		, @nValorBase	, @lDiaFixo		, @aTefMult 	,;
									@aTitulo		, @lConfLJRec	, @aTitImp		, @aParcelas	,;
									@oCodProd		, oMensagem		, oFntGet		, cCodDep		,;
									/*cNomeDEP*/	, /*cTipoCli*/	, /*cEntrega*/	, /*aReserva*/	,;
									/*lReserva*/	, /*lAbreCup*/ 	, /*nValor*/	, /*oTimer*/	,;
									@lResume		, /*aValePre*/	, @aRegTEF		, @lRecarEfet	,;
									@lCancItRec		, @oOnOffLine	, @nValIPIIT	, @_aMult		,;
									@_aMultCanc		, /*nVlrDescIT*/, oFntMoeda		, /*lBscPrdON*/	,;
									@oPDV			, @aICMS		, @lDescITReg	)}	,;		// F9  - Finaliza Venda (Sub-Total)								
				{|| FR271EAltCli(	@cNCartao	, @cCliente		, @cLojaCli		, @lOcioso,;
									@lRecebe	, @lCXAberto	, @aCrdCliente	, @cCodConv	,;
									@cLojConv	, @cNumCartConv	, @uCliTPL		, @uProdTPL)},;													// F10 - Alteracao de Clientes
				{|| FR271FAltVend(	@cVendLoja	, @lOcioso		, @lRecebe		, @lCXAberto	,;
								@lAltVend	)},;															// F11 - Alteracao de Vendedores
				,,,,,,,,,,,,,,,,,,,,; // Retirado o F12 para o Touch 
				{|| If(ExistBlock("FRTCTRLT"),ExecBlock("FRTCTRLT",.F.,.F.),)},;
				{|| If(ExistBlock("FRTCTRLU"),ExecBlock("FRTCTRLU",.F.,.F.,{lOcioso}),)},;
				{|| If(ExistBlock("FRTCTRLV"),ExecBlock("FRTCTRLV",.F.,.F.,{lOcioso}),)},;
				{|| If(ExistBlock("FRTCTRLW"),ExecBlock("FRTCTRLW",.F.,.F.),)},;
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
									@oMensagem		, @oFntMoeda	, @cMensagem 	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCliente		, @cLojaCli		, @cCupom		, @cTipoCli		,;
									@lDescITReg	)} }) // CTRL+Z - Carregamento de Orcamentos
// "Aguarde. Abrindo a Impressora Fiscal " ### "..."

	oDlg:bStart := 	 { || LJMsgRun(STR0002 + AllTrim(cImpressora) + "...",,;
					 { || FR271AStart( 	@oTimer		, @oHora		, @cHora		, @oDoc			,;
										@cDoc		, @oPDV			, @cPDV			, @oMoedaCor	,;	
										@nMoedaCor	, @cMoeda		, @oTaxaMoeda	, @nTaxaMoeda	,;	
										@cSimbCor	, @oTemp3		, @cCodProd		, @oFotoProd	,;	
										@oProduto	, @oUnidade		, @oQuant		, @oVlrUnit		,;	
										@oVlrItem	, @oVlrTotal	, @oTotItens	, @oDesconto	,;
										@nVlrTotal	, @nVlrBruto	, @nTotItens	, @cProduto		,;
										@cUnidade	, @nQuant		, @nVlrUnit		, @oCupom		,;
										@cOrcam		, cImpressora	, @cCliente		, @cLojaCli 	,;
										@lOcioso	, @lDescITReg	, @aItens		, @aICMS		,;
										@nVlrMerc	, @lExitNow		, @lFechaCup	, @aCrdCliente	,;
										@uCliTPL	, @uProdTPL		, @nTotDedIcms	, @aMoeda		,;
										@aSimbs		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,; 
										@aImpVarDup	, @aTotVen		, @aCols		, @aHeader		,;
										@lBalanca	, @cPorta		, /*@cVendLoja*/, /*@cTipoCli*/	,;
										/*@aPgtos*/	, @lResume		, @cCupom		) }), ;
                       IIF( lUsaDisplay, ( DisplayEnv(StatDisplay(), "2E" + STR0003), DisplayEnv(StatDisplay(), "1E ") ), Nil ), ;
                       IIF( lExitNow, oDlg:End(), Nil ) } 

	//Gera a classe de botoes a partir das tabelas SL7 e SL8
	FR271BBGrp( @oOrigBtns )
	oButtons := oOrigBtns
	
	oOpGer := BtnGroup():New( "000", "Operações Gerenciais" )
	
	//Cria o grupo de caixa	
	oOpGer2 := BtnGroup():New( "000", "Caixa" )
	oOpGer2:Add( "O", btnItem():New( "001", "Abrir" + Chr(10) + "Caixa",;   
				{ || FR271AAbreCX( 	@oCupom			, @cCupom	, @cPDV			, @lCXAberto,;
									@nHdlOPE ), ;
				FrtMenuPrincipal(	@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
									@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
									@nVlrDescTot	, /*aMoeda*/	, /*aSimbs*/	, @lDescITReg	,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer2:Add( "O", btnItem():New( "002", "Fechar"  + Chr(10) + "Caixa",; 
				{ || FR271EFechaCX(	@oCupom		, @cCupom	, @CPDV		, @lOcioso,; 
									@lRecebe	, @lCXAberto, @nHdlOPE),;
	 			FrtMenuPrincipal(	@cCliente	, @cLojaCli	, @cVendLoja, @lOcioso		,;
	 			 					@lRecebe	, @lLocked	, @lCXAberto, @lDescIT		,;
	 			 					@nVlrDescTot, /*aMoeda*/, /*aSimbs*/, @lDescITReg	,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer2:Add( "O", btnItem():New( "003", "Sangria", { || Fr271D050(1),; 
				FrtMenuPrincipal(	@cCliente		, @cLojaCli	, @cVendLoja	, @lOcioso	,;
				 					@lRecebe		, @lLocked	, @lCXAberto	, @lDescIT	,;
				 					@nVlrDescTot	, @aMoeda	, @aSimbs		, @lDescITReg,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer2:Add( "O", btnItem():New( "004", "Suprimento",	{ || Fr271D050(2), ;
				FrtMenuPrincipal(	@cCliente		, @cLojaCli	, @cVendLoja	, @lOcioso	,; 
									@lRecebe   		, @lLocked	, @lCXAberto	, @lDescIT	,;
									@nVlrDescTot	, @aMoeda	, @aSimbs		, @lDescITReg,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer2:Add( "O", btnItem():New( "005", "Abrir" + CHR(10) + "Gaveta",	{ || ABREGAVETA(),; 
				FrtMenuPrincipal(	@cCliente		, @cLojaCli	, @cVendLoja	, @lOcioso	,;
									@lRecebe 		, @lLocked	, @lCXAberto	, @lDescIT	,;
									@nVlrDescTot	, @aMoeda	, @aSimbs		, @lDescITReg,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer:Add( "G", oOpGer2)
	
	//Cria o Grupo fiscal
	oOpGer3 := BtnGroup():New( "000", "Fiscais" )
	
	oOpGer3:Add( "O", btnItem():New( "006", "Leitura" + Chr(10) + "X", { || FR271CPrintLeitX(),;
	 			FrtMenuPrincipal(	@cCliente		, @cLojaCli	, @cVendLoja	, @lOcioso	,; 
	 								@lRecebe		, @lLocked	, @lCXAberto	, @lDescIT	,;
	 								@nVlrDescTot	, @aMoeda	, @aSimbs		, @lDescITReg,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer3:Add( "O", btnItem():New( "007", "Redução" + Chr(10) + "Z", { || FRT271CRedZPrint(),; 
				FrtMenuPrincipal(	@cCliente		, @cLojaCli	, @cVendLoja	, @lOcioso	,; 
									@lRecebe		, @lLocked	, @lCXAberto	, @lDescIT	,;
									@nVlrDescTot	, @aMoeda	, @aSimbs		, @lDescITReg,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer3:Add( "O", btnItem():New( "008", "Leitura" + Chr(10) + "Memoria" + Chr(10) + "Fiscal", { || LOJA180(),; 
				FrtMenuPrincipal(	@cCliente		, @cLojaCli	, @cVendLoja	, @lOcioso	,; 
									@lRecebe		, @lLocked	, @lCXAberto	, @lDescIT	,;
									@nVlrDescTot	, @aMoeda	, @aSimbs		, @lDescITReg,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer:Add( "G", oOpGer3)
	
	oOpGer:Add( "O", btnItem():New( "009", "TEF", { || LJRotTEF(),; 
				FrtMenuPrincipal(	@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso	,; 
									@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT	,;
									@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg,;
									@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
									@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
									@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpGer:Add( "O", btnItem():New( "010", "Importar" + chr(10) + "Orcamento",; 
											{ || FR271CLoadOrc(	@oTimer			, @cCodProd		, @cHora		, @oDoc			,;
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
																@nVlrAcreTot	, @nVlrDescCPg	, @	nVlrPercOri	, @nQtdeItOri	,; 
																@nNumParcs		, @aMoeda		, @aSimbs		, @nMoedaCor	,; 
																@nDecimais		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,; 
																@aImpVarDup		, @aTotVen		, @aCols		, @nVlrPercIT	,;
																@cEstacao		, @lTouch		, @cVendLoja	, @aParcOrcOld	,;
																@oMensagem		, @oFntMoeda	, @cMensagem 	, @cEntrega		,;
																@aReserva		, @lReserva		, @lAbreCup		, @nValor 		,;
																@cCliente		, @cLojaCli		, @cCupom		, @cTipoCli		,;
																@lDescITReg	),;
											FrtMenuPrincipal(	@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
																@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
																@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg	,;
																@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
																@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
																@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
																@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )

	oOpGer:Add( "O", btnItem():New( "011", "Sair", { || oDlg:End() } ) )

	If SuperGetMV( "MV_LJMNBOT", .T., 1 ) == "2"
		oOpGer:Add("O", btnItem():New( "012", SuperGetMV("MV_TITBOT",.F.,"Botao"), { || Execblock( "FRTFUNCCLI", .F., .F. ) } ) )
	Endif    
	oOpVen := btnGroup():New( "000", "Operações de Vendas" )
	oOpVen:Add( "O", btnItem():New( "001", "Desconto"  + Chr(10) + "Item",  ;
												{ || FR271EDescIT(	@oCupom	, @oDesconto	, @nVlrPercIT	, @nVlrTotal,;
																	@lRecebe, @lDescIT		, @lDescITReg	, @nVlrBruto,;
																	@aItens	, @nMoedaCor	, @nDecimais	, @lCXAberto),; 
												FrtMenuPrincipal(	@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,; 
																	@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
																	@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg	,;
																	@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
																	@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
																	@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
																	@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
	oOpVen:Add( "O", btnItem():New( "001", "Cancela" + Chr(10) + "Item",;	
										{ || FR271ECancIT( @oCupom		, @oVlrTotal	, @nVlrTotal	, @nVlrBruto	,;
														   @nMoedaCor	, @nTotItens	, @oTotItens	, @oTmpQuant	,; 
														   @nTmpQuant	, @oCodProd		, @cCodProd		, @nTaxaMoeda	,; 
														   @cOrcam		, @lRecebe		, @aItens		, @_aMultCanc 	,;
														   @uCliTPL		, @uProdTPL		, @nTotDedIcms	, @aMoeda		,;
														   @aImpsSL1	, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,; 
														   @aTotVen		, @aCols		, @aHeader		, @lCXAberto	,; 
														   @aRegTEF		, @lRecarEfet	, @lCancItRec)	,;
												FrtMenuPrincipal(	@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,; 
																	@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
																	@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg	,;
																	@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
																	@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
																	@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
																	@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )
		
	oOpVen:Add( "O", btnItem():New( "001", "Cancela" + Chr(10) + "Cupom",;
		 { || FR271FCancCup( 	.F.	   			, @oHora		, @cHora		, @oDoc			,;
		 					@cDoc  			, @oCupom		, @cCupom		, @nVlrPercIT	,; 
		 					@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,; 
		 					@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
							@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,; 
							@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,; 
							@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,; 
							@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,; 
							@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,; 
							@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
							@cCliente		, @cLojaCli 	, @lOcioso		, @nVlrFSD		,;
							@nVlrDescTot	, @aItens		, @nVlrMerc 	, @lFechaCup	,;
							@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
							@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
							@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
							@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @lVerTEFPend	,;
							@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
							@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
							@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
							@nTotalAcrs		, @aCols		, @aHeader 		, @aDadosJur	,;
							@aCProva		, @lCXAberto	, NIL			, NIL			,;
							NIL				, NIL			, NIL			, NIL			,;
							NIL				, @aRegTEF		, @lRecarEfet),; 
		FrtMenuPrincipal(	@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,; 
							@lRecebe 		, @lLocked		, @lCXAberto	, @lDescIT		,;
							@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg	,;
							@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
							@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
							@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
							@cCupom			, @cVndLjAlt	, @cCliCGC ) } ) )

	             
	If SuperGetMV( "MV_LJMNBOT", .T., 1 )  == "3"
		oOpVen:Add("O", btnItem():New( "001", SuperGetMV("MV_TITBOT",.F.,"Botao"), { || Execblock( "FRTFUNCCLI", .F., .F. ) } ) )
	Endif    
	//Atualiza (desenha) o painel com os botoes de produtos
	FRT273CBtn( @oButtons	, Nil			, Nil			, Nil			,;
				Nil			, Nil			, @cCliente		, @cLojaCli		,;
				@cVendLoja	, @lOcioso		, @lRecebe		, @lLocked 		,;
				@lCXAberto	, @lDescIT		, @nVlrDescTot	, @aMoeda		,; 
				@aSimbs		, @aRegTEF		, @lRecarEfet	, @lDescITReg	,;
				Nil			, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
				@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
				@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
				@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC	)
				
	
	aFormas := FR271BBSLD()
	
	// Demais Operacoes

	TAdvButton():New(;
		oQdt4,;
		C(005),; 
		C(064),; 
		C(034),;
		C(025),;
		STR0001,; //Produto
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ |a,b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r,s,t,u| FrtVbut(	"1"			, @cCliente		, @cLojaCli		, @cVendLoja	,;
																@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
										   						@aTefDados	, @dDataCN 		, @lDescIT		, @nVlrDescTot	,;
																@nVlrFSD	, @aMoeda		, @aSimbs 		, @oMensagem	,;
																oFntMoeda	, @aRegTEF		, @lRecarEfet	, @lCancItRec	,;
																@lDescITReg , @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
																@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
																@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
																@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC)},;
		nil )

	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(093),;
		C(034),;
		C(025),;
		STR0005,; //Finaliza
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ |a,b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r,s,t,u| FrtVbut(	"2"			, @cCliente		, @cLojaCli		, @cVendLoja	,;
											   					@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
											 					@aTefDados	, @dDataCN		, @lDescIT		, @nVlrDescTot	,;
																@nVlrFSD	, @aMoeda		, @aSimbs		, @oMensagem	,;
																oFntMoeda	, @aRegTEF		, @lRecarEfet	, @lCancItRec	,;
																@lDescITReg , @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
																@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
																@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
																@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC) },;
		nil )

	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(122),;
		C(034),;
		C(025),;
		STR0006 + Chr(10) + Chr(13) + STR0007,; //Operações de Venda
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ |a,b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r,s,t,u| FrtVbut("3"		, @cCliente		, @cLojaCli		, @cVendLoja	,;
							 				   				@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
								 				  			@aTefDados	, @dDataCN		, @lDescIT		, @nVlrDescTot	,;
															@nVlrFSD	, @aMoeda  		, @aSimbs  		, @oMensagem	,;
															oFntMoeda	, @aRegTEF		, @lRecarEfet	, @lCancItRec	,;
															@lDescITReg , @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
															@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
															@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
															@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC) },;
		nil )

	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(151),;
		C(034),;
		C(025),;
		STR0006 + Chr(10) + Chr(13) + STR0008,; //Operações Gerenciais
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ |a,b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r,s,t,u| FrtVbut( 	"4"			, @cCliente		, @cLojaCli		, @cVendLoja	,;
																@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
																@aTefDados	, @dDataCN		, @lDescIT		, @nVlrDescTot	,;
																@nVlrFSD	, @aMoeda		, @aSimbs		, @oMensagem	,;
																oFntMoeda	, @aRegTEF		, @lRecarEfet	, @lCancItRec	,;
																@lDescITReg , @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
																@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
																@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
																@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC) },;
		nil )

	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(180),;
		C(034),;
		C(025),;
		STR0009 + Chr(10) + Chr(13) + STR0010,;  //Menu Principal
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ |a,b,c,d,e,f,g,h,i,j,l,m,n,o,p,q,r,s,t,u| FrtVbut("5"			, @cCliente		, @cLojaCli		, @cVendLoja	,;
															@lOcioso   		, @lRecebe		, @lLocked		, @lCXAberto	,;
															@aTefDados		, @dDataCN		, @lDescIT		, @nVlrDescTot	,;
															@nVlrFSD		, @aMoeda		, @aSimbs		, @oMensagem	,;
															oFntMoeda		, @aRegTEF		, @lRecarEfet	, @lCancItRec	,;
															@lDescITReg 	, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
															@nVlrDescIT		, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
															@cEntrega		, @aReserva		, @lReserva		, @lAbreCup		,;
															@nValor			, @cCupom		, @cVndLjAlt	, @cCliCGC) },;
		nil )

	// Botao Para a Chamada do Ponto de Entrada FRTFUNCCLI
	If ExistBlock( "FRTFUNCCLI" ) .AND. SuperGetMV( "MV_LJMNBOT", .T., 1 )  == "1"

		oBtnFUNCCLI := TAdvButton():New(;
			oQdt4,;
			C(005),;
			C(209),;
			C(034),;
			C(025),;
			SuperGetMV("MV_TITBOT",.F.,"Botao"),;
			TAdvColor():NewValue( CLR_MSFACE ),;
			TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
			1,;
			TAdvColor():NewValue( CLR_BLACK ),;
			{ || Execblock( "FRTFUNCCLI", .F., .F. ) },;
			nil )

	Endif	
                                    
	// Cria objetos do Quadrante 2
	@ C(004),C(002) TO C(020),C(120) PIXEL OF oQdt2 COLOR CLR_BLUE
	@ C(018),C(002) TO C(063),C(120) PIXEL OF oQdt2 COLOR CLR_BLUE
	@ C(022),C(003) SAY STR0011 SIZE 240,200 PIXEL OF oQdt2 FONT oFntTot 		// Valor Total
	@ C(040),C(035) SAY oVlrTotal Var nVlrTotal SIZE 240,200 PICTURE "@E 9,999,999.99" PIXEL OF oQdt2 FONT oFntTot COLOR CLR_BLUE	

ACTIVATE MSDIALOG oDlg CENTERED VALID ( Frt273Sai(@oDlg) )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT273CBtnºAutor  ³Mauro Vajman        º Data ³  08/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria os botoes de produtos                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        
Function FRT273CBtn( 	oButtons	, cTipo			, lVezes		, oDlg		,;
						bPagto		, bFunc			, cCliente		, cLojaCli	,;
						cVendLoja	, lOcioso 		, lRecebe		, lLocked	,;
						lCXAberto	, lDescIT		, nVlrDescTot	, aMoeda	,; 
						aSimbs		, aRegTEF		, lRecarEfet	, lDescITReg,;
						oMensagem	, lUsaDisplay	, nTaxaMoeda	, aHeader	,;
						nVlrDescIT	, cTipoCli		, lBscPrdON		, nConTcLnk	,;
						cEntrega	, aReserva		, lReserva		, lAbreCup	,;
						nValor		, cCupom		, cVndLjAlt		, cCliCGC  )

	Local cDirBot	:= SuperGetMV( "MV_LJDIRBT", .T., "V" )		// Direcao da cricao do botao horizontal ou vertical   
	Local cUsaTe 	:= SuperGetMV( "MV_LJUSATL", .T., "D" )	// Indica se eh destro ou canhoto pela tela
	Local nLinha	:= nBtnSpace + 4							// Coordenada inicial da linha
	Local nColun	:= nBtnSpace  								// Coordenada inicial da coluna
	Local nButton	:= 1   										// Variavel de controle dos arrays dos botoes
	Local oGroup
	Local aItem
	Local aSub		:= {}             							// Recebe parcialmete o aBotoes
	
	Default lVezes 		:= .T. // Se .T. exibe os botoes de quantidade
	Default cTipo  		:= "C" // Tipo de atualizacao / criacao        
	Default bPagto 		:= .F.
	Default bFunc  		:= .F.
	Default aRegTEF		:= {}
	Default lRecarEfet	:= .F.
	
	Default lUsaDisplay	:= .F.
	Default nTaxaMoeda	:= 0
	Default aHeader		:= {}
	Default nVlrDescIT	:= 0
	Default cTipoCli	:= ""
	Default lBscPrdON	:= .F.
	Default nConTcLnk	:= 0
	Default cEntrega	:= ""
	Default aReserva	:= {}
	Default lReserva	:= .F.
	Default lAbreCup	:= .F.
	Default nValor		:= 0
	Default cCupom		:= ""
	Default cVndLjAlt	:= ""
	Default cCliCGC		:= ""
	
	If cTipo == "A"

		oQdt3:Hide()
		
		If oQdt3tmp <> Nil
			oQdt3tmp:Show()
		EndIf                  

	
		If ! bPagto

			If cUsaTe == "D"

				// Quadrante 3 Temporario
				@ C(005),C(133) MSPANEL Iif(oDlg == Nil, oQdt3tmp, oDlg) SIZE C(228),C(266) OF Iif(oDlg == Nil, oPrincipal, oDlg)
				@ C(000),C(000) TO C(264),C(226) PIXEL OF Iif(oDlg == Nil, oQdt3tmp, oDlg)

			Else

			    // Quadrante 3
			    @ C(003),C(001) MSPANEL Iif(oDlg == Nil, oQdt3tmp, oDlg) SIZE C(282),C(145) OF Iif(oDlg == Nil, oPrincipal, oDlg)
				@ C(000),C(000) TO C(143),C(280) PIXEL OF Iif(oDlg == Nil, oQdt3tmp, oDlg)
	
		    Endif
		Endif		

		nLinha := nBtnSpace + 4
		nColun := nBtnSpace
	
	Else

		oQdt3:Show()
		
		If oQdt3tmp <> Nil
			oQdt3tmp:Hide()
		EndIf                  
		

	Endif	

	If bPagto .OR. bFunc
	
		While nButton <= Len( oButtons )                                                                       
		    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o botao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    aSub := aClone( oButtons[nButton])
		    
		    If cTipo == "A" // Atualizacao - Monta sobre o Qtd3 
				If ValType( aSub ) == "A"  
					If bPagto
						If Vazio(oButtons[nButton][4]) // Formas de Pagamento
							cNome := LjMacroBotao(oButtons[nButton][2])
							cDesc := AllTrim( AllTrim(StrTran(oButtons[nButton][2],"+","")) )
							TAdvButton():New( ;
								Iif(oDlg == Nil, oQdt3tmp, oDlg),;
								C(nColun)/2,;
								C(nLinha)/2,;
								C(34),;
								C(25),;
								&cNome,;
								TAdvColor():NewValue( CLR_MSFACE ),;
								TAdvFont():New("Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
								1,;
								TAdvColor():NewValue( CLR_BLACK ),;
								{ |x,y| DisparaPagto( x, @lRecebe, @aRegTEF	, @lRecarEfet, @cCupom, @aMoeda, @aSimbs) },;
								{ cDesc, oButtons[nButton][3] } )
						Else // Condicoes de Pagamento
							TAdvButton():New( ;
								Iif(oDlg == Nil, oQdt3tmp, oDlg),;
								C(nColun)/2,;
								C(nLinha)/2,;
								C(34),;
								C(25),;
								oButtons[nButton][2],;
								TAdvColor():NewValue( CLR_MSFACE ),;
								TAdvFont():New("Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
								1,;
								TAdvColor():NewValue( CLR_BLACK ),;
								{ |x| DisparaCond( x ) },;
								{ oButtons[nButton][4], nVlrTotal } )
				Endif	                              
			Else	
						TAdvButton():New( ;
							Iif(oDlg == Nil, oQdt3tmp, oDlg),;
							C(nColun)/2,;
							C(nLinha)/2,;
							C(34),;
							C(25),;
							oButtons[nButton][2],;
							TAdvColor():NewValue( CLR_MSFACE ),;
							TAdvFont():New("Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
							1,;
							TAdvColor():NewValue( CLR_BLACK ),;
							{ |x| DisparaBotao( x ) },;
							oButtons[nButton][3] )
					Endif
				Endif	                              
			Else	
				TAdvButton():New( ;
					oQdt3,;
					C(nColun)/2,;
					C(nLinha)/2,;
					C(34),;
					C(25),;
					aBotoes[nButton][2],;
					TAdvColor():NewValue( CLR_MSFACE ),;
					TAdvFont():New("Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
					1,;
					TAdvColor():NewValue( CLR_BLACK ),;
					{ || FRT273ABot( 	aSub		, Nil			, Nil		, Nil			,;
										Nil			, @cCliente		, @cLojaCli	, @cVendLoja	,;
										@lOcioso	, @lRecebe		, @lLocked	, @lCXAberto	,;
										@lDescIT	, @nVlrDescTot	, @aMoeda	, @aSimbs 		,;
										@lDescITReg	, @nTaxaMoeda	, @aHeader	, @nVlrDescIT	,;
										@cTipoCli	, @lBscPrdON	, @nConTcLnk, @cEntrega		,;
										@aReserva	, @lReserva		, @lAbreCup	, @nValor		,;
										@cCupom		, @cVndLjAlt	, @cCliCGC)},;
					nil )
			Endif		
		           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a orientacao da tela para saber onde posicionara o ³
			//³proximo botao.                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cDirBot == 'V' 
				nLinha += nBtnHeight + nBtnSpace
			Else
	            nColun += nBtnWidth + nBtnSpace
			Endif

			If bPagto		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³"Conta" quantos botoes foram inseridos para verificar se precisar mudar de linha/coluna³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( cDirBot == 'V' ) .AND. ( nButton % nBtnPerLin == 0 )
					nColun += nBtnWidth + nBtnSpace
					nLinha := nBtnSpace + 4
				Endif	
				
				If ( cDirBot == 'H' ) .AND. ( nButton % nBtnPerCol == 0 )
					nLinha += nBtnHeight + nBtnSpace
				    nColun := nBtnSpace
				Endif	 
			else	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³"Conta" quantos botoes foram inseridos para verificar se precisar mudar de linha/coluna³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( cDirBot == 'V' ) .AND. ( nButton % nBtnPerLin == 0 )
					nColun += nBtnWidth + nBtnSpace
					nLinha := nBtnSpace + 4
				Endif	
				
				If ( cDirBot == 'H' ) .AND. ( nButton % nBtnPerCol == 0 )
					nLinha += nBtnHeight + nBtnSpace
				    nColun := nBtnSpace
				Endif	 
			endif				
			nButton += 1   
		End	
		
				
	Else
		aBtnObjects := {}

		For nButton := 1 To oButtons:GetItemsQty()
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o botao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aItem := oButtons:GetItemAt( nButton )
	
			If cTipo == "A" // Atualizacao - Monta sobre o Qtd3
				If aItem[1] == "I"
					TAdvButton():New(;
					  oQdt3tmp,;
					  C(nColun) / 2,;
					  C(nLinha) / 2,;
					  C(nBtnWidth) / 2,;
					  C(nBtnHeight) / 2,;
					  aItem[2]:GetDescription(),;
					  TAdvColor():NewValue( IIf( aItem[2]:GetBackColor() == nil, 14215660, aItem[2]:GetBackColor() ) ),; //oBClrTest,;
					  TAdvFont():New( "Arial", 6, IIf(oMainWnd:nClientWidth==798,14,19), TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ), .F., .F., .F. ),; //oFntTest,;
					  1,;
					  TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ),; //oFClrTest,;
					  { |x,y,z,a,b,c,d,e,f,g,h,i,j,k,l,m,n| BtnClick(	x			, @cCliente		, @cLojaCli		, @cVendLoja	,;
					  						  							@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
					  													@lDescIT	, @nVlrDescTot	, @aMoeda		, @aSimbs		,;
					  													@oMensagem	, @oFntMoeda	, @aRegTEF 		, @lRecarEfet	,;
																		@lDescITReg	, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
																		@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
																		@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
																		@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC   )},;
					  { aItem } )
				ElseIf aItem[1] == "G"
					TAdvButton():New(;
					  oQdt3tmp,;
					  C(nColun) / 2,;
					  C(nLinha) / 2,;
					  C(nBtnWidth) / 2,;
					  C(nBtnHeight) / 2,;
					  aItem[2]:GetDescription(),;
					  TAdvColor():NewValue( IIf( aItem[2]:GetBackColor() == nil, 14215660, aItem[2]:GetBackColor() ) ),; //oBClrTest,;
					  TAdvFont():New( "Arial", 6, IIf(oMainWnd:nClientWidth==798,14,19), TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ), .T., .F., .T. ),; //oFntTest,;
					  2,;
					  TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ),; //oFClrTest,;
					  { |x,y,z,a,b,c,d,e,f,g,h,i,j,k,l,m,n| BtnClick(	x			, @cCliente		, @cLojaCli		, @cVendLoja	,;
					  													@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
					  													@lDescIT	, @nVlrDescTot	, @aMoeda		, @aSimbs		,;
					  													@oMensagem	, @oFntMoeda	, @aRegTEF		, @lRecarEfet	,;
																		@lDescITReg	, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
																		@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
																		@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
																		@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC  )},;
					  { aItem, cTipo, lVezes, oDlg, bPagto, bFunc } )
				ElseIf aItem[1] == "O"
					TAdvButton():New(;
					  oQdt3tmp,;
					  C(nColun) / 2,;
					  C(nLinha) / 2,;
					  C(nBtnWidth) / 2,;
					  C(nBtnHeight) / 2,;
					  aItem[2]:GetDescription(),;
					  TAdvColor():NewValue( IIf( aItem[2]:GetBackColor() == nil, 14215660, aItem[2]:GetBackColor() ) ),; //oBClrTest,;
					  TAdvFont():New( "Arial", 6, IIf(oMainWnd:nClientWidth==798,14,19), TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ), .T., .F., .F. ),; //oFntTest,;
					  2,;
					  TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ),; //oFClrTest,;
					  aItem[2]:GetBlock(),;
					  nil )
				Endif
			Else
				If aItem[1] == "I"
					TAdvButton():New(;
					  oQdt3,;
					  C(nColun) / 2,;
					  C(nLinha) / 2,;
					  C(nBtnWidth) / 2,;
					  C(nBtnHeight) / 2,;
					  aItem[2]:GetDescription(),;
					  TAdvColor():NewValue( IIf( aItem[2]:GetBackColor() == nil, 14215660, aItem[2]:GetBackColor() ) ),; //oBClrTest,;
					  TAdvFont():New( "Arial", 6, IIf(oMainWnd:nClientWidth==798,14,19), TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ), .F., .F., .F. ),; //oFntTest,;
					  1,;
					  TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ),; //oFClrTest,;
					  { |x,y,z,a,b,c,d,e,f,g,h,i,j,k,l,m,n| BtnClick(	x			, @cCliente		, @cLojaCli		, @cVendLoja	,;
					  						 							@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
					  													@lDescIT	, @nVlrDescTot	, @aMoeda		, @aSimbs		,;
					  													@oMensagem	, @oFntMoeda	, @aRegTEF		, @lRecarEfet	,;
																		@lDescITReg , @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
																		@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
																		@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
																		@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC   )},;
					  { aItem } )
				ElseIf aItem[1] == "G"
					TAdvButton():New(;
					  oQdt3,;
					  C(nColun) / 2,;
					  C(nLinha) / 2,;
					  C(nBtnWidth) / 2,;
					  C(nBtnHeight) / 2,;
					  aItem[2]:GetDescription(),;
					  TAdvColor():NewValue( IIf( aItem[2]:GetBackColor() == nil, 14215660, aItem[2]:GetBackColor() ) ),; //oBClrTest,;
					  TAdvFont():New( "Arial", 6, IIf(oMainWnd:nClientWidth==798,14,19), TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ), .T., .F., .T. ),; //oFntTest,;
					  2,;
					  TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ),; //oFClrTest,;
    				  { |x,y,z,a,b,c,d,e,f,g,h,i,j,k,l,m,n| BtnClick(	x			, @cCliente		, @cLojaCli		, @cVendLoja	,;
					  													@lOcioso	, @lRecebe		, @lLocked		, @lCXAberto	,;
					  													@lDescIT	, @nVlrDescTot	, @aMoeda		, @aSimbs		,;
					  													@oMensagem	, oFntMoeda		, @aRegTEF		, @lRecarEfet	,;
																		@lDescITReg	, lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
																		@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
																		@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
																		@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC   )},;
					  { aItem, cTipo, lVezes, oDlg, bPagto, bFunc } )
				ElseIf aItem[1] == "O"
					TAdvButton():New(;
					  oQdt3,;
					  C(nColun) / 2,;
					  C(nLinha) / 2,;
					  C(nBtnWidth) / 2,;
					  C(nBtnHeight) / 2,;
					  aItem[2]:GetDescription(),;
					  TAdvColor():NewValue( IIf( aItem[2]:GetBackColor() == nil, 14215660, aItem[2]:GetBackColor() ) ),; //oBClrTest,;
					  TAdvFont():New( "Arial", 6, IIf(oMainWnd:nClientWidth==798,14,19), TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ), .T., .F., .F. ),; //oFntTest,;
					  2,;
					  TAdvColor():NewValue( IIf( aItem[2]:GetForeColor() == nil, CLR_BLACK , aItem[2]:GetForeColor() ) ),; //oFClrTest,;
					  aItem[2]:GetBlock(),;
					  nil )
				Endif
			Endif		
	           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a orientacao da tela para saber onde posicionara o ³
			//³proximo botao.                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cDirBot == 'V' 
				nLinha += nBtnHeight + nBtnSpace
			Else
				nColun += nBtnWidth + nBtnSpace
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³"Conta" quantos botoes foram inseridos para verificar se precisar mudar de linha/coluna³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( cDirBot == 'V' ) .AND. ( nButton % nBtnPerLin == 0 )
				nColun += nBtnWidth + nBtnSpace
				nLinha := nBtnSpace + 4
			Endif	
			
			If ( cDirBot == 'H' ) .AND. ( nButton % nBtnPerCol == 0 )
				nLinha += nBtnHeight + nBtnSpace
			    nColun := nBtnSpace
			Endif	 
		
		Next nButton

	EndIf
	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Botoes de Quantidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVezes

		TAdvButton():New(;
			oQdt4,;
			C(005),;
			C(006),;
			C(034),;
			C(025),;
			"2X",;
			TAdvColor():NewValue(CLR_MSFACE),;
			TAdvFont():New("Arial", 6, 19, TAdvColor():NewValue(CLR_BLACK), .F., .F., .F. ),;
			1,;
			TAdvColor():NewValue(CLR_BLACK),;
			{ || AtuQtd( "2" ) },;
			nil )

		TAdvButton():New(;
			oQdt4,;
			C(005),;
			C(035),;
			C(034),;
			C(025),;
			"?X",;
			TAdvColor():NewValue(CLR_MSFACE),;
			TAdvFont():New("Arial", 6, 19, TAdvColor():NewValue(CLR_BLACK), .F., .F., .F. ),;
			1,;
			TAdvColor():NewValue(CLR_BLACK),;
			{ || AtuQtd( "?" ) },;
			nil )

	Endif
	
Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BtnClick  ºAutor  ³Mauro Vajman        º Data ³  13/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Dispara o evento do botao selecionado                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        
Function BtnClick( 	aData	 	, cCliente		, cLojaCli		, cVendLoja		,;
					lOcioso		, lRecebe		, lLocked		, lCXAberto		,;
					lDescIT	 	, nVlrDescTot	, aMoeda		, aSimbs		,;
					oMensagem	, oFntMoeda 	, aRegTEF		, lRecarEfet	,;
					lDescITReg	, lUsaDisplay	, nTaxaMoeda	, aHeader		,;
					nVlrDescIT	, cTipoCli		, lBscPrdON		, nConTcLnk		,;
					cEntrega	, aReserva		, lReserva		, lAbreCup		,;
					nValor		, cCupom		, cVndLjAlt		, cCliCGC)

DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.

conout( "BtnClick()" )

	If aData[ 1, 1 ] == "I"
		DisparaProduto( aData[ 1, 2 ]	, @cCliente		, @cLojaCli		, @cVendLoja	,;
						@lOcioso		, @lRecebe		, @lLocked		, @lCXAberto	,;
						@lDescIT 		, @nVlrDescTot	, @aMoeda 		, @aSimbs		,;
						@oMensagem		, @oFntMoeda 	, @aRegTEF		, @lRecarEfet	,;
						@lDescITReg		, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
						@nVlrDescIT		, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
						@cEntrega		, @aReserva		, @lReserva		, @lAbreCup		,;
						@nValor			, @cCupom		, @cVndLjAlt	, @cCliCGC		)
	Else
		FRT273CBtn( aData[ 1, 2 ]	, aData[ 2 ]	, aData[ 3 ]	, aData[ 4 ]	,;
					aData[ 5 ]		, Nil			, @cCliente		, @cLojaCli		,;
					@cVendLoja		, @lOcioso		, @lRecebe		, @lLocked		,;
					@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aMoeda		,; 
					@aSimbs			, @aRegTEF		, @lRecarEfet	, @lDescITReg	,;
					Nil				, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
					@nVlrDescIT		, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
					@cEntrega		, @aReserva		, @lReserva		, @lAbreCup		,;
					@nValor			, @cCupom		, @cVndLjAlt	, @cCliCGC	)
	EndIf

Return( nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT273CBtnºAutor  ³Mauro Vajman        º Data ³  08/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Dispara o evento do botao do produto selecionado           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        

Function DisparaProduto(oItem		, cCliente		, cLojaCli		, cVendLoja	,;
						lOcioso		, lRecebe		, lLocked		, lCXAberto	,;
						lDescIT		, nVlrDescTot	, aMoeda		, aSimbs	,;
						oMensagem	, oFntMoeda		, aRegTEF		, lRecarEfet,;
						lDescITReg	, lUsaDisplay	, nTaxaMoeda	, aHeader	,;
						nVlrDescIT	, cTipoCli		, lBscPrdON		, nConTcLnk ,;
						cEntrega	, aReserva		, lReserva		, lAbreCup	,;
						nValor		, cCupom		, cVndLjAlt		, cCliCGC	)

	DEFAULT lUsaDisplay := .F.

	Eval( { || cCodProd := Space(TamSX3("BI_DESC")[1]),;
		cCodProd := oItem:GetCode(),;
		oCodProd:Refresh(),;
		(If(!_lOK.AND.!Empty(cCodProd),(_lOK:=.T.,aKeyAux := FrtSetKey(),;
		FR271AProdOK( 				,    			,    			, .T.   		,;
					@cCodProd		, @oTimer		, @oHora		, @cHora  		,;
					@oDoc			, @cDoc			, @oPDV			, @cPDV  		,;   
					@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens 	,;
					@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens 	,;
					@oOnOffLine		, @nTmpQuant	, @nVlrItem		, @nValIPIIT 	,;
					@nValIPI		, @oFotoProd	, @oProduto		, @oQuant  		,;
					@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor 	,;
					@cOrcam			, @cProduto		, @nQuant		, @cUnidade 	,; 
					@nVlrUnit		, @oUnidade		, @lF7   		, @cQtd			,;
					@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
					@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
					@nVlrDescTot	, @aItens 		, @aICMS		, @nVlrMerc		,;
					@_aMult			, @_aMultCanc	, @lOrc			, @aParcOrc		,;
					@cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
					@lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
					@aRecCrd 		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
					@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
					@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,; 
					@nVidaLink		, @nValTPis		, @nValTCof		, @nValTCsl		,;
					@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
					@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
					@aMoeda			, @aSimbs		, @nMoedaCor	, @nDecimais	,;
					@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
					@aTotVen		, @aCols		, @nVlrPercIT	, @nTaxaMoeda	,;
					@aHeader		, @nVlrDescIT	, @oMensagem	, @oFntMoeda	,;
					@cMensagem		, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
					@cEntrega	  	, @aReserva		, @lReserva		, @lAbreCup		,;
					@nValor			, @cCupom		, @cVndLjAlt	, @cCliCGC		,;
					@aRegTEF		, @lRecarEfet	, @lDescITReg	),;           
		FR271AInitIT(	.T.				, @lF7			, @cCodProd		, @cProduto ,;
						@nTmpQuant		, @nQuant		, @cUnidade		, @nVlrUnit ,; 
						@nVlrItem		, @oProduto		, @oQuant		, @oUnidade ,; 
						@oVlrUnit		, @oVlrItem		, @oDesconto	, @cCliente	,; 
						@cLojaCli) ,;
		If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),;
		FrtSetKey(aKeyAux),If (lUsaDisplay,(DisplayEnv(StatDisplay(), "2E"+ "STR0003" + cCodProd),;
		DisplayEnv(StatDisplay(), "1E"+ " ")),),_lOK:=.F.),), If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),),),oCodProd:SetFocus()} )

Return( nil )
        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT273CBtnºAutor  ³Mauro Vajman        º Data ³  08/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria os botoes do grupo selecionado                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        
                         

Function DisparaGrupo( 	oGrupo		, cTipo			, lVezes		, oDlg		,;
						bPagto		, cCliente		, cLojaCli		, cVendLoja	,;
						lOcioso		, lRecebe		, lLocked		, lCXAberto	,;
						lDescIT		, nVlrDescTot	, aMoeda		, aSimbs 	,;
						lDescITReg	, lUsaDisplay	, nTaxaMoeda	, aHeader	,;
						nVlrDescIT	, cTipoCli		, lBscPrdON		, nConTcLnk	,;
						cEntrega	, aReserva		, lReserva		, lAbreCup	,;	
						nValor		, cCupom		, cVndLjAlt		, cCliCGC )

	FRT273CBtn( oGrupo		, cTipo			, lVezes		, oDlg			,; 
				bPagto		, Nil			, @cCliente		, @cLojaCli		,;
				@cVendLoja	, @lOcioso		, @lRecebe		, @lLocked		,;
				@lCXAberto	, @lDescIT		, @nVlrDescTot	, @aMoeda		,; 
				@aSimbs		, /*aRegTEF*/	, /*lRecarEfet*/, @lDescITReg	,;
				Nil			, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
				@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
				@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
				@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC)

Return( nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT273ABotºAutor  ³Mauro Sano          º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os botoes                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT273ABot( 	aBotoes		, lVezes		, oDlg		, bPagto	,; 
						bFunc		, cCliente		, cLojaCli	, cVendLoja	,;
						lOcioso		, lRecebe		, lLocked	, lCXAberto	,;
						lDescIT		, nVlrDescTot	, aMoeda	, aSimbs 	,;
						lDescITReg	, lUsaDisplay	, nTaxaMoeda, aHeader	,;
						nVlrDescIT	, cTipoCli		, lBscPrdON	, nConTcLnk	,;
						cEntrega	, aReserva		, lReserva	, lAbreCup	,;
						nValor		, cCupom		, cVndLjAlt	, cCliCGC)
						  
Local cUsaTe := SuperGetMV( "MV_LJUSATL", .T., "D" )
Static oQdt3Tmp 

oQdt3:Hide()

If !Empty( aBotoes )                     
	If bPagto
		FRT273CBtn( aBotoes		, "A"			, lVezes		, oDlg			,; 
					bPagto		, Nil			, @cCliente		, @cLojaCli		,;
					@cVendLoja	, @lOcioso		, @lRecebe		, @lLocked		,;
					@lCXAberto	, @lDescIT		, @nVlrDescTot	, @aMoeda		,; 
					@aSimbs		, /*aRegTEF*/	, /*lRecarEfet*/, @lDescITReg	,;
					Nil			, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
					@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
					@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
					@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC)
	Else
		If cUsaTe == "D"
			@ C(005),C(133) MSPANEL oQdt3Tmp SIZE C(228),C(266) OF Iif (oDlg == Nil, oPrincipal, oDlg)
			@ C(000),C(000) TO C(264),C(226)PIXEL OF oQdt3Tmp

		Else //Canhoto
		    // Quadrante 3
			@ C(003),C(001) MSPANEL oQdt3Tmp SIZE C(282),C(145)  OF Iif (oDlg == Nil, oPrincipal, oDlg)
			@ C(000),C(000) TO C(143),C(280)PIXEL OF oQdt3Tmp
	    Endif
		FRT273CBtn(	aBotoes		, "A"			, lVezes		, oDlg			,; 
					bPagto		, bFunc			, @cCliente		, @cLojaCli		,;
					@cVendLoja 	, @lOcioso		, @lRecebe		, @lLocked		,;
					@lCXAberto	, @lDescIT		, @nVlrDescTot 	, @aMoeda		,; 
					@aSimbs		, /*aRegTEF*/	, /*lRecarEfet*/, @lDescITReg	,;
					Nil			, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
					@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
					@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
					@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC)
	Endif
Endif	

Return( Nil )         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT273ABtnºAutor  ³Mauro Vajman        º Data ³  09/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os botoes                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT273ABtn( 	oButtons	, lVezes		, oDlg			, bPagto		,;
						cCliente	, cLojaCli		, cVendLoja		, lOcioso		,;
						lRecebe		, lLocked 		, lCXAberto		, lDescIT		,;
						nVlrDescTot	, aMoeda		, aSimbs		, lDescITReg	,;
						lUsaDisplay	, nTaxaMoeda	, aHeader		, nVlrDescIT	,;
						cTipoCli	, lBscPrdON		, nConTcLnk		, cEntrega		,;
						aReserva	, lReserva		, lAbreCup		, nValor		,;
						cCupom		, cVndLjAlt		, cCliCGC)
						
Local cUsaTe := SuperGetMV( "MV_LJUSATL", .T., "D" )
Static oQdt3Tmp 

oQdt3:Hide()

If oButtons <> nil
	If bPagto
		@ C(000),C(190) MSPANEL oQdt3Tmp SIZE C(141),C(420) OF Iif (oDlg == Nil, oPrincipal, oDlg)
		FRT273CBtn( aButtons	, "A"			, lVezes		, oQdt3Tmp		,;
					bPagto		, Nil			, @cCliente		, @cLojaCli		,;
					@cVendLoja	, @lOcioso		, @lRecebe		, @lLocked		,;
					@lCXAberto	, @lDescIT		, @nVlrDescTot	, @aMoeda		,; 
					@aSimbs		, /*aRegTEF*/	, /*lRecarEfet*/, @lDescITReg	,;
					Nil			, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
					@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
					@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
					@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC)
	Else
		If cUsaTe == "D"                                                                 
			// Quadrante 3 Temporario
			@ C(005),C(133) MSPANEL Iif(oDlg == Nil, oQdt3tmp, oDlg) SIZE C(228),C(266) OF Iif(oDlg == Nil, oPrincipal, oDlg)
			@ C(000),C(000) TO C(264),C(226)PIXEL OF Iif(oDlg == Nil, oQdt3tmp, oDlg)
		Else // Canhoto
		    // Quadrante 3
		    @ C(003),C(001) MSPANEL Iif(oDlg == Nil, oQdt3tmp, oDlg) SIZE C(282),C(145) OF Iif(oDlg == Nil, oPrincipal, oDlg)
			@ C(000),C(000) TO C(143),C(280)PIXEL OF Iif(oDlg == Nil, oQdt3tmp, oDlg)
	    Endif
		FRT273CBtn( @oButtons	, "A"			, lVezes		, oDlg			,; 
					bPagto		, Nil			, @cCliente		, @cLojaCli		,;
					@cVendLoja	, @lOcioso		, @lRecebe		, @lLocked 		,;
					@lCXAberto	, @lDescIT		, @nVlrDescTot	, @aMoeda		,; 
					@aSimbs		, /*aRegTEF*/	, /*lRecarEfet*/, @lDescITReg	,;
					Nil			, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
					@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
					@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
					@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC)
	Endif
Endif	

Return( Nil )         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Atualiza  ºAutor  ³Mauro Sano          º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os botoes                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DisparaBotao( cBotao )  
&( cBotao )     
Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Atualiza  ºAutor  ³Mauro Sano          º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os botoes                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DisparaPagto( _aForma, lRecebe, aRegTEF, lRecarEfet, cCupom , aMoeda, aSimbs)

Local aFormPag    

Default aRegTEF		:= {}
Default lRecarEfet	:= .F.

MonFormPag(@aFormPag)
	
FR271FFormPag(	aFormPag		, _aForma[1] 	, _aForma[2]	, Nil, ;
				@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	,; 
				@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		,;
				@nTaxaMoeda		, @oPgtos	    , @oPgtosSint	, @aPgtos		,;
				@aPgtosSint		, @lRecebe		, @aParcOrc		, @aParcOrcOld	,;
				@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		,;
				@aSimbs			, @aCols		, @aCProva		, @aFormCtrl	,;
				@nTroco			, @nTroco2 		, @lDescCond	, @nDesconto	,;
				@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas  	,;
				@aRegTEF		, @lRecarEfet	)
								
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DisparaCondºAutor  ³Marcio Silva        º Data ³  06/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Identifica a Condicao de Pagamento Selecionada               º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaFrt                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function DisparaCond( _aCond )

Local nI
Local aRet := Lj7CalcPgt(_aCond[2], _aCond[1])
Local lVisuSint  := If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior

aPgtos := {}
aPgtosSint := {}

For nI := 1 to Len(aRet)               
 	aAdd( aPgtos, { aRet[nI][1], NoRound(aRet[nI][2],nDecimais), AllTrim(aRet[nI][3]), "", "", "", "", "", "", .F., nMoedaCor,"" ,0 })
	aAdd( aPgtosSint, {AllTrim(aRet[nI][3]),nI,NoRound(aRet[nI][2],nDecimais),Nil,aRet[nI][1]})
Next nI     

oPgtos:SetArray(aPgtos)

If lVisuSint
	oPgtosSint:SetArray( aPgtosSint )
	oPgtosSint:Refresh()
Else
	oPgtos:SetArray(aPgtos) 
	oPgtos:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRT273CBtnºAutor  ³Mauro Vajman        º Data ³  08/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria botoes                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        

Function BldTchBtn( nLeft, nTop, nWidth, nHeight, cName, cCaption, oFont, oOwner, cFunction, oData, cTipo, lVezes, oDlg, bPagto )

	Local oButton

	oButton := TchButton():Criar( nLeft, nTop, nWidth, nHeight, cName, cCaption, oFont, oOwner, cFunction, oData, cTipo, lVezes, oDlg, bPagto )

Return( oButton )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuQtd    ºAutor  ³Mauro Sano          º Data ³  14/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza as quantidades                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtuQtd( cQuant )

Local oDlgQuant						// Objeto da tela para se informar a Quantidade (?)
Local oQuant						// Objeto de Get da Quantidade
Local nQuant	:= 0				// Variavel de Get da Quantidade
Local oKeyb							// Objeto 
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )

cQtd := cQuant

// Caso a Quantidade seja a informar
If !Empty( cQtd ) .AND. cQtd == "?"

	If lTouch
		DEFINE MSDIALOG oDlgQuant FROM 178,181 TO 450,400 TITLE "Informe a Quantidade" PIXEL of oQdt3 STYLE DS_MODALFRAME 
	Else
		DEFINE MSDIALOG oDlgQuant FROM 1,1 TO 130,260 TITLE STR0004 PIXEL	// "Quantidade"
	EndIf

	@ 04, 20 TO 28, 90 LABEL STR0004 OF oDlgQuant  PIXEL	// "Quantidade"

	@ 13, 25 MSGET oQuant VAR nQuant SIZE 40, 10 OF oDlgQuant PICTURE "@E 999.99" RIGHT PIXEL VALID !Empty(nQuant)
	
	If !lTouch
		DEFINE SBUTTON FROM 38, 20 TYPE 1 ENABLE OF oDlgQuant ;
				ACTION ( cQtd := Str(nQuant), oDlgQuant:End() ) PIXEL
	
		DEFINE SBUTTON FROM 38, 65 TYPE 2 ENABLE OF oDlgQuant ;
				ACTION ( cQtd := "1", oDlgQuant:End() ) PIXEL
	Else
		// Definindo o Objeto Teclado
		// Definindo a Acao da tecla ENTER do Teclado oKeyb
		// Definindo o que fazer quando o Foco for obtido na Qauntidade
		// Definindo onde o Foco deve iniciar na Dialog
		oKeyb := TKeyboard():New( 40, 10, 1, oDlgQuant )     
		oKeyb:SetEnter({|| ( cQtd := Str(nQuant), oDlgQuant:End() ) })
		oKeyb:bEsc:={|| ( cQtd := "1",nQuant:=1, oDlgQuant:End())}
		oQuant:bGotFocus		:= {|| oKeyb:SetVars(oQuant,3) } 
		oQuant:SetFocus()
	EndIf
	
	ACTIVATE MSDIALOG oDlgQuant CENTERED

EndIf

If !Empty( cQtd ) .AND. cQtd <> "?" 
	nTmpQuant := Val( cQtd )   
	//limpa o label das quantidades evitando sobeposicao de caracteres.
	@ C(008),C(003) SAY STR0004 + "" SIZE 240,200 PIXEL OF oQdt2 FONT oFntMsg		// Quantidade 
	//atualiza o label quantidade com a quantidade escolhida.
	@ C(008),C(003) SAY STR0004 + IiF(Empty(cQtd), "1", AllTrim( cQtd ) ) SIZE 240,200 PIXEL OF oQdt2 FONT oFntMsg		// Quantidade 
Endif

Return( nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frt273Pro ºAutor  ³Anderson Kurtinaitisº Data ³  08/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre interface para procurar PRODUTO                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt273Pro()    

Local oDlgProd
Local oProduto
Local oKeyboard
Local cProduto	:= Space(TamSX3("BI_DESC")[1])
Local lRet 		:= .F.

DEFINE DIALOG oDlgProd TITLE STR0012 FROM 001, 001 TO 310,520 PIXEL STYLE DS_MODALFRAME // Escolha o Produto

@ 10,18 SAY STR0013 PIXEL // Informe o Código do Produto
@ 20,18 MSGET oProduto VAR cproduto PIXEL SIZE 70,08

DEFINE SBUTTON FROM 18,375 TYPE 1 ACTION { || oDlgProd:End() } ENABLE OF oDlgProd


oKeyboard := TKeyboard():New( 40, 15, 2, oDlgProd )
oKeyboard:SetVars( oProduto, 15 )
oKeyboard:SetEnter( { || oDlgProd:End() } )
oKeyboard:bEsc:={|| oDlgProd:End()}  
ACTIVATE MSDIALOG oDlgProd CENTERED

Return(cProduto)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frt273Sai ºAutor  ³Anderson Kurtinaitisº Data ³  09/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acionada quando usuário tenta sair do Front, via botão ou   º±±
±±º          ³ESC, onde iremos verificar se o mesmo deve fornecer senha   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt273Sai(oDlg)    

Local lSai := .F.

If nVlrTotal = 0
	lSai := LjProfile(10) // Validando se usuario pode sair do atendimento
EndIf

Return(lSai)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTAtuTot ³ Autor ³ Anderson              ³ Data ³13/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao resposavel em atualizar o valor do total na primeira³±±
±±³          ³ entrada da interface principal (No quadrante2) pois existem³±±
±±³Descri‡„o ³ ocasioes onde a venda eh interrompida e o valor deve voltar³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTAtuTot(nVlrTot)

nVlrTotal := nVlrTot
oVlrTotal:Refresh()

Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTVBut   ³ Autor ³ Anderson              ³ Data ³16/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel por habilitar ou nao os botos do quarto ³±±
±±³          ³ quadrante.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.    ³01/10/07³133788³Retirado o uso da variável ltTefAberto  ³±±
±±³              ³        ³      ³como local.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTVBut(	cQualBot	, cCliente		, cLojaCli	, cVendLoja		,;
					lOcioso		, lRecebe		, lLocked	, lCXAberto		,;
					aTefDados	, dDataCN		, lDescIT	, nVlrDescTot	,;
					nVlrFSD		, aMoeda		, aSimbs	, oMensagem		,;
					oFntMoeda	, aRegTEF		, lRecarEfet, lCancItRec	,;
					lDescITReg	, lUsaDisplay	, nTaxaMoeda, aHeader		,;
					nVlrDescIT	, cTipoCli		, lBscPrdON	, nConTcLnk	  	,;
					cEntrega	, aReserva		, lReserva	, lAbreCup		,;
					nValor		, cCupom		, cVndLjAlt	, cCliCGC)


If cQualBot == "1" // Produto

	cCodProd := Space(TamSX3("BI_DESC")[1])
	cCodProd := Frt273Pro()
	oCodProd:REfresh() 
	(If(!_lOK.AND.!Empty(cCodProd),(_lOK:=.T.,aKeyAux := FrtSetKey(),; //Produto
								 FR271AProdOK(					,				,				, .T.			,; 
									 			@cCodProd		, @oTimer		, @oHora		, @cHora		,;
												@oDoc			, @cDoc			, @oPDV			, @cPDV			,; 		
									 			@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
									 			@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
												@oOnOffLine		, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
												@nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
												@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
												@cOrcam			, @cProduto		, @nQuant		, @cUnidade		,;	
												@nVlrUnit		, @oUnidade		, @lF7   		, @cQtd			,;
												@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
												@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT 		,;
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
												@aTotVen		, @aCols		, @nVlrPercIT	, /*nTaxaMoeda*/,;
												/*aHeader*/		, /*nVlrDescIT*/, @oMensagem	, oFntMoeda		,;
												@cMensagem		, /*cTipoCli*/	, /*lBscPrdON*/	, /*nConTcLnk*/	,;
												/*cEntrega*/  	, /*aReserva*/	, /*lReserva*/	, /*lAbreCup*/	,;
												/*nValor*/		, /*cCupom*/	, /*cVndLjAlt*/	, /*cCliCGC*/	,;
												/*aRegTEF*/		, /*lRecarEfet*/, @lDescITReg	),;
									FR271AInitIT(	.T.			, @lF7		, @cCodProd		, @cProduto	,;
													@nTmpQuant	, @nQuant	, @cUnidade		, @nVlrUnit	,;	
													@nVlrItem	, @oProduto	, @oQuant		, @oUnidade	,;	
													@oVlrUnit	, @oVlrItem	, @oDesconto	, @cCliente	,;
													@cLojaCli	)	,;
												 If(lFrtGetPr,ExecBlock("FRTGETPR",.F.,.F.,{cCodProd}),),;
												 FrtSetKey(aKeyAux),If (lUsaDisplay,(DisplayEnv(StatDisplay(), "2E"+ "STR0003" + cCodProd),;
												 DisplayEnv(StatDisplay(), "1E"+ " ")),),_lOK:=.F.),), If(lUsaLeitor,LeitorFoco(nHdlLeitor,.F.),),)
												 
	oCodProd:SetFocus()
	
Elseif cQualBot == "2" // Finaliza

	If nVlrTotal > 0
		FR271EFimVend(	.F.				, Nil			, @cNCartao		, @oHora			,; 		
						@cHora			, @oDoc			, @cDoc			, @oCupom			,;		
						@cCupom			, @nVlrPercIT	, @nLastTotal	, @nVlrTotal		,;		
						@nLastItem		, @nTotItens	, @nVlrBruto	, @oDesconto		,;		
						@oTotItens		, @oVlrTotal	, @oFotoProd	, @nMoedaCor		,;		
						@cSimbCor		, @oTemp3		, @oTemp4		, @oTemp5			,;			
						@nTaxaMoeda		, @oTaxaMoeda	, @nMoedaCor	, @cMoeda			,;			
						@oMoedaCor		, @cCodProd		, @cProduto		, @nTmpQuant		,;		
						@nQuant			, @cUnidade		, @nVlrUnit		, @nVlrItem			,;		
						@oProduto		, @oQuant		, @oUnidade		, @oVlrUnit			,;		
						@oVlrItem		, @lF7			, @oPgtos		, @oPgtosSint		,;
						@aPgtos			, @aPgtosSint	, @cOrcam		, @cPDV				,;
						@lTefPendCS 	, @aTefBKPCS	, @oDlg			, @cCliente			,;	
						@cLojaCli		, @cVendLoja	, @lOcioso		, @lRecebe			,;
						@lLocked		, @lCXAberto	, @aTefDados	, @dDataCN			,;
						@nVlrFSD		, @lDescIT		, @nVlrDescTot	, @nValIPI			,;
						@aItens			, @nVlrMerc		, @lEsc			, @aParcOrc			,;
						@cItemCOrc		, @aParcOrcOld	, @aKeyFimVenda	, @lAltVend			,;
						@lImpNewIT		, @lFechaCup	, @aTpAdmsTmp	, @cUsrSessionID	,;
						@cContrato		, @aCrdCliente	, @aContratos	, @aRecCrd			,;
						@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv			,;
						@cNumCartConv	, @uCliTPL		, @uProdTPL		, @lDescTotal		,; 
						@lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	, @nVidaLink		,;
						@cCdPgtoOrc		, @cCdDescOrc	, @nValTPis		, @nValTCof			,; 
						@nValTCsl		, @lOrigOrcam	, @lVerTEFPend	, @nTotDedIcms		,;
						@lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot		,;
						@nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	, @nNumParcs		,;
						@aMoeda			, @aSimbs		, @cRecCart		, @cRecCPF			,; 
						@cRecCont		, @aImpsSL1		, @aImpsSL2		, @aImpsProd		,; 
						@aImpVarDup		, @aTotVen		, @nTotalAcrs	, @lRecalImp		,;
						@aCols			, @aHeader 		, @aDadosJur	, @aCProva			,;
						@aFormCtrl		, @nTroco		, @nTroco2 		, @lDescCond		,; 
						@nDesconto		, @aDadosCH		, @cItemCond	, @lCondNegF5		,;
						@nTxJuros		, @nValorBase	, @lDiaFixo		, @aTefMult 		,;
						@aTitulo		, @lConfLJRec	, @aTitImp		, @aParcelas		,;
						@oCodProd		, @oMensagem	, @oFntGet		, /*@cCodDep*/		,;
						/*@cNomeDEP*/	, /*@cTipoCli*/	, /*@cEntrega*/	, /*@aReserva*/		,;
						/*@lReserva*/	, /*@lAbreCup*/	, /*@nValor*/	, @oTimer			,;
						/*@lResume*/	, /*aValePre*/	, @aRegTEF		, @lRecarEfet		,;
						@lCancItRec		, @oOnOffLine	, @nValIPIIT	, @_aMult			,;
						@_aMultCanc		, /*nVlrDescIT*/, oFntMoeda		, /*lBscPrdON*/		,;
						@oPDV			, @aICMS		, @lDescITReg	)
	Else
		MsgAlert(STR0014) // Funçao NÃO disponível no momento
	EndIf

Elseif cQualBot == "3" // Operacoes de Venda

	FRT273ABtn( oOpVen			, .F.			, Nil			, .F.			,;
				@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
				@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
				@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg	,;
				@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
				@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
				@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
				@cCupom			, @cVndLjAlt	, @cCliCGC)


Elseif cQualBot == "4" // Operacoes Gerenciais
	
	If nVlrTotal > 0
		MsgAlert(STR0014) // Funçao NÃO disponível no momento
	Else
		FRT273ABtn( oOpGer			, .F.			, Nil			, .F.			,;
					@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
					@lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,;
					@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg	,;
					@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
					@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
					@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
					@cCupom			, @cVndLjAlt	, @cCliCGC)

    EndIf

Elseif cQualBot == "5" // Menu Principal

	FRT273ABtn( oOrigBtns		, .T.			, Nil			, Nil			,;
				@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
				@lRecebe		, @lLocked 		, @lCXAberto	, @lDescIT		,;
				@nVlrDescTot	, @aMoeda		, @aSimbs		, @lDescITReg	,;
				@lUsaDisplay	, @nTaxaMoeda	, @aHeader		, @nVlrDescIT	,;
				@cTipoCli		, @lBscPrdON	, @nConTcLnk	, @cEntrega		,;
				@aReserva		, @lReserva		, @lAbreCup		, @nValor		,;
				@cCupom			, @cVndLjAlt	, @cCliCGC)


EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtMenuPrincipal³ Autor ³ Anderson              ³ Data ³16/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel por habilitar ou nao os botos do quarto       ³±±
±±³          ³ quadrante.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FrtMenuPrincipal( 	cCliente	, cLojaCli		, cVendLoja		, lOcioso		,;
							lRecebe		, lLocked		, lCXAberto		, lDescIT		,; 
							nVlrDescTot	, aMoeda		, aSimbs		, lDescITReg	,;
							lUsaDisplay , nTaxaMoeda	, aHeader		, nVlrDescIT	,;
							cTipoCli	, lBscPrdON		, nConTcLnk		, cEntrega		,;
							aReserva	, lReserva		, lAbreCup		, nValor		,;
							cCupom		, cVndLjAlt		, cCliCGC )
							
			
FRT273CBtn( oOrigBtns	, "A"			, .T.			, Nil			,;
			Nil			, Nil			, @cCliente		, @cLojaCli		,;
			@cVendLoja	, @lOcioso		, @lRecebe 		, @lLocked		,;
			@lCXAberto	, @lDescIT		, @nVlrDescTot	, @aMoeda		,; 
			@aSimbs		, /*aRegTEF*/	, /*lRecarEfet*/, @lDescITReg	,;
			Nil			, @lUsaDisplay	, @nTaxaMoeda	, @aHeader		,;
			@nVlrDescIT	, @cTipoCli		, @lBscPrdON	, @nConTcLnk	,;
			@cEntrega	, @aReserva		, @lReserva		, @lAbreCup		,;
			@nValor		, @cCupom		, @cVndLjAlt	, @cCliCGC) // Retorno ao Menu Principal



Return
