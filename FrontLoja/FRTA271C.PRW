#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FRTA271C.CH"

#DEFINE LOG_IMP		FR271HLogImp()
#DEFINE NPOSSL1		1
#DEFINE NPOSSL2		2
#DEFINE NPOSSL4		3  

#DEFINE 	_L1_IFSANST_APROVADO 	"1"
#DEFINE 	_L1_IFSANST_REPROVADO 	"0"
#DEFINE 	_L1_IFSANST_MESA 		"2"   
#DEFINE 	_L1_IFSANST_OFFLINE 	"9"

Static oRPCServer := Nil
Static lUsaIntFS	:= SuperGetMV("MV_LJINTFS",,.F.) .And. LjUpd90Ok(.t.)   //Verifica se a analise de credito esta habilitada e implementada no ambiente

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271CLoad³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
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

Function FR271CLoadOrc(	oTimer		, cCodProd		, cHora			, oDoc			,;
						cDoc		, oPDV			, cPDV			, nLastTotal	,;
						nVlrTotal	, nLastItem	 	, nTotItens	 	, nVlrBruto 	,;
						oVlrTotal	, oCupom		, oTotItens 	, oOnOffLine	,; 
						nTmpQuant	, nVlrItem 		, nValIPIIT		, nValIPI		,;
						oFotoProd	, oProduto		, oQuant		, oVlrUnit		,; 
						oVlrItem	, oDesconto		, cSimbCor		, cOrcam 		,; 
						cProduto	, nQuant 		, cUnidade		, nVlrUnit 		,;
						oUnidade 	, lF7			, oHora			, lOcioso		,;
						lRecebe		, lLocked		, lCXAberto		, lDescIT		,;
						nVlrDescTot	, aItens		, aICMS			, nVlrMerc		,;
						_aMult		, _aMultCanc	, lOrc			, aParcOrc 		,;
						cItemCOrc	, aParcOrcOld	, lAltVend		, lImpNewIT		,;
						lFechaCup	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd		, aTEFPend		, aBckTEFMult	, cCodConv		,; 
						cLojConv	, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal	, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
						nVidaLink	, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,; 
						nValTCof	, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
						nTotDedIcms	, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,; 
						nVlrAcreTot	, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,; 
						nNumParcs	, aMoeda		, aSimbs		, nMoedaCor		,; 
						nDecimais	, aImpsSL1		, aImpsSL2		, aImpsProd		,; 
						aImpVarDup	, aTotVen		, aCols			, nVlrPercIT	,;
						cEstacao	, lTouch		, cVendLoja		, aParcOrcOld	,;
						oMensagem	, oFntMoeda		, cMensagem		, cEntrega		,;
						aReserva	, lReserva		, lAbreCup		, nValor		,;
						cCliente	, cLojaCli		, cCupom		, cTipoCli		,;
						lDescITReg	, cNumDAV		, cDocFo			, oTemp3		,;
						oTemp4		, oTemp5		, nTaxaMoeda		, oTaxaMoeda	,;
						cMoeda		, oMoedaCor	, nVlrFSD			, aMostruario			) 

Local oDlg
Local aArray
Local oNumOrc
Local oNumDAV
Local oSim
Local oNao
Local oBtnPesq
Local oBtnOK
Local lUsaDAV  	:= (SL1->(FieldPos("L1_NUMORC")) > 0)
Local cNumOrc  	:= Space(TamSX3("L1_NUM")[1])
Local nTamDoc		:= TamSX3("L1_NUM")[1]
Local nTamDAV		:= If(lUsaDAV,TamSX3("L1_NUMORC")[1],0)
Local aKey
Local aRetOrcs 	:= {}
Local i
Local lPreVend	:= SuperGetMv("MV_LJPRVEN",,.T.)
Local aOrcDAV		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay 	:= !Empty(LjGetStation("DISPLAY"))


DEFAULT cTipoCli 	:= ""						// Tipo do Cliente 
DEFAULT lDescITReg  := .F.                     // Desconto   
DEFAULT cNumDAV 	:= Space(nTamDAV)			// Documento auxiliar de venda
DEFAULT cDocFo		:= ""						// Release 11.5 - Controle de Formularios - Numero do documento informado pelo usuário no incio da venda
DEFAULT oTemp3		:= cSimbCor
DEFAULT oTemp4		:= cSimbCor		
DEFAULT oTemp5		:= cSimbCor
DEFAULT nTaxaMoeda	:= 	1
DEFAULT oTaxaMoeda	:= nTaxaMoeda
DEFAULT cMoeda		:= ""
DEFAULT oMoedaCor	:= cMoeda
DEFAULT nVlrFSD		:= 0
DEFAULT aMostruario	:= {"N",""}

If Len(cNumDAV) == 0
	cNumDAV := Space(nTamDAV)
EndIf

If lUsaDisplay
	DisplayEnv(StatDisplay(), "1C" + STR0003 )        //"Carregamento de Orçamentos"
	DisplayEnv(StatDisplay(), "2C" + Substr(STR0035, 1, 22 ))        //"Utilize o Monitor para esta operacao"
	DisplayEnv(StatDisplay(), "3C" + Substr(STR0035, 24 ))        //"Utilize o Monitor para esta operacao"
	DisplayEnv(StatDisplay(), "***")	// Desabilitar o echo das digitacoes do teclado
Endif

If ! CheckCaixa(@lCXAberto, @lUsaDisplay )		// Verifica se o Caixa Esta Aberto
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1E" + STR0036 + "|" )        //"Codigo do produto: "
		DisplayEnv(StatDisplay(), "*")	// Habilitar o echo das digitacoes do teclado
	Endif
	Return NIL									// E exibe Mensagem Caso Esteja Fechado
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

If ExistBlock("FRTIMPORCA")
	aOrcDAV := ExecBlock("FRTIMPORCA")
	If !Empty(aOrcDAV[1]) .AND. !Empty(aOrcDAV[2])

		cNumOrc := aOrcDAV[1]
		cNumDAV := aOrcDAV[2]

		FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd	, @oTimer			,;
							@oHora			, @cHora		, @oDoc		, @cDoc			,; 			
							@oPDV			, @cPDV		, @nLastTotal	, @nVlrTotal		,; 	
							@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal		,; 	
							@oCupom		, @oTotItens	, @oOnOffLine	, @nTmpQuant		,;		
							@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd		,;		
							@oProduto		, @oQuant		, @oVlrUnit	, @oVlrItem		,;		
							@oDesconto		, @cSimbCor	, @cOrcam		, @cProduto		,;		
							@nQuant		, @cUnidade	, @nVlrUnit	, @oUnidade 		,;
							@lF7			, @lOcioso		, @lRecebe		, @lLocked			,;
							@lCXAberto		, @lDescIT		, @nVlrDescTot, @aItens			,;
							@aICMS			, @nVlrMerc	, @_aMult		, @_aMultCanc		,;
							@lOrc			, @aParcOrc	, @cItemCOrc	, @aParcOrcOld	,;
							@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato		,; 
							@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
							@aBckTEFMult	, @cCodConv	, @cLojConv	, @cNumCartConv	,; 
							@uCliTPL		, @uProdTPL	, @lDescTotal	, @lDescSE4		,;
							@aVidaLinkD	, @aVidaLinkc , @nVidaLink	, @cCdPgtoOrc		,; 
							@cCdDescOrc	, @nValTPis	, @nValTCof	, @nValTCsl		,;
							@lOrigOrcam	, @lVerTEFPend, @nTotDedIcms, @lImpOrc			,;
							@nVlrPercTot	, @nVlrPercAcr, @nVlrAcreTot, @nVlrDescCPg	,;
							@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda			,; 
							@aSimbs		, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
							@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen			,;
							@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
							@oMensagem		, oFntMoeda	, @cMensagem	, @cEntrega		,;
							@aReserva		, @lReserva	, @lAbreCup	, @oNumOrc			,;
							@nValor		, @cCliente	, @cLojaCli	, Nil				,;
							@cCupom		, @cTipoCli	, @lDescITReg	, @cNumDAV			,;							
							Nil				, Nil			, Nil			, Nil				,;
							Nil				, Nil			, Nil			, Nil				,;
							Nil				, Nil			, @aMostruario) 
							 
	EndIf  
Else 
	If LjNfPafEcf(SM0->M0_CGC) .Or. SuperGetMV("MV_LJTPIMO",,0) == 1  
		If !lTouch // Caso NAO seja interface Touch Screen
			If !(lUsaDAV)
				aArray := {{.F.,"",""}}
			Else
				aArray := {{.F.,"","",""}}	
			EndIf
			
			oSim   := LoadBitmap(GetResources(), "BR_VERDE")
			oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")
			
			DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 260,353 PIXEL	// "Carregamento de Orçamentos"
			
			@00,02 To 21,44 Label STR0007 Pixel of oDlg //"Orçamento"
			@00,47 To 21,95 Label If(lPreVend, STR0022, STR0023) Pixel of oDlg //"Pre-Venda" //"DAV"
			
			//Limpa conteudo do campo DAV
			cNumDAV:= Space(nTamDAV)
			@ 08,04 GET oNumOrc VAR cNumOrc SIZE 36,7 PIXEL PICTURE PesqPict("SL1","L1_NUM") ;
				ON CHANGE If(!Empty(cNumOrc),;
				(cNumOrc := StrZero(Val(cNumOrc),nTamDoc),oNumOrc:Refresh(),;
				 cNumDAV:= Space(nTamDAV),oNumDAV:Refresh(),;
				 oBtnOK:lReadOnly:=.T.,;
				 FR271HCarrega(	@oDlg			, @cNumOrc			, @cCodProd		, @oTimer			,;
									@oHora			, @cHora			, @oDoc			, @cDoc			,; 			
									@oPDV			, @cPDV			, @nLastTotal		, @nVlrTotal		,; 	
									@nLastItem		, @nTotItens		, @nVlrBruto		, @oVlrTotal		,; 	
									@oCupom		, @oTotItens		, @oOnOffLine		, @nTmpQuant		,;		
									@nVlrItem		, @nValIPIIT		, @nValIPI			, @oFotoProd		,;		
									@oProduto		, @oQuant			, @oVlrUnit		, @oVlrItem		,;		
									@oDesconto		, @cSimbCor		, @cOrcam			, @cProduto		,;		
									@nQuant		, @cUnidade		, @nVlrUnit		, @oUnidade 		,;
									@lF7			, @lOcioso			, @lRecebe			, @lLocked			,;
									@lCXAberto		, @lDescIT			, @nVlrDescTot	, @aItens			,;
									@aICMS			, @nVlrMerc		, @_aMult			, @_aMultCanc		,;
									@lOrc			, @aParcOrc		, @cItemCOrc		, @aParcOrcOld	,;
									@lAltVend		, @lImpNewIT		, @lFechaCup		, @cContrato		,; 
									@aCrdCliente	, @aContratos		, @aRecCrd			, @aTEFPend		,; 
									@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
									@uCliTPL		, @uProdTPL		, @lDescTotal		, @lDescSE4		,;
									@aVidaLinkD	, @aVidaLinkc 	, @nVidaLink		, @cCdPgtoOrc		,; 
									@cCdDescOrc	, @nValTPis		, @nValTCof		, @nValTCsl		,;
									@lOrigOrcam	, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc			,;
									@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
									@nVlrPercOri	, @nQtdeItOri		, @nNumParcs		, @aMoeda			,; 
									@aSimbs		, @nMoedaCor		, @nDecimais		, @aImpsSL1		,; 
									@aImpsSL2		, @aImpsProd		, @aImpVarDup		, @aTotVen			,;
									@aCols			, @nVlrPercIT		, @cVendLoja		, @aParcOrcOld	,;
									@oMensagem		, oFntMoeda		, @cMensagem		, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc			,;
									@nValor		, @cCliente		, @cLojaCli		, /*cNumOrig*/	,;
									@cCupom		, @cTipoCli		, @lDescITReg		, @cNumDAV			,;
									@oTemp3,		, @oTemp4			, @oTemp5			, @nTaxaMoeda		,; 
									@oTaxaMoeda		, @cMoeda		, @oMoedaCor		, @nVlrFSD	,;
									@aMostruario	),oBtnOK:lReadOnly:=.F.),.F.) 
			
			@ 08,49 GET oNumDAV VAR cNumDAV SIZE 44,7 PIXEL PICTURE PesqPict("SL1","L1_NUMORC");
			ON CHANGE If(!Empty(cNumDAV),;
				(cNumDAV := StrZero(Val(cNumDAV),nTamDAV),oNumDAV:Refresh(),;
				cNumOrc:= Space(nTamDoc),oNumOrc:Refresh(),;
				oBtnOK:lReadOnly:=.T.,;
			 	FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
								@oHora			, @cHora		, @oDoc			, @cDoc			,; 			
								@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,; 	
								@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,; 	
								@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;		
								@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;		
								@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;		
								@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;		
								@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
								@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
								@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
								@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
								@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
								@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
								@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
								@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
								@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
								@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,; 
								@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
								@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
								@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
								@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,; 
								@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
								@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
								@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
								@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
								@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
								@nValor		, @cCliente		, @cLojaCli		, /*cNumOrig*/	,;
								@cCupom		, @cTipoCli		, @lDescITReg	, @cNumDAV,;
								Nil				, Nil				, Nil			, Nil				,;
								Nil				, Nil				, Nil			, Nil				,;
								@aMostruario	),oBtnOK:lReadOnly:=.F.),.F.)  
			
				If !lUsaDAV
					oNumDAV:Disable()
				Else
					oNumOrc:Disable()
				EndIf	
			
			DEFINE SBUTTON oBtnPesq FROM 06,105 PIXEL TYPE 14 ENABLE ONSTOP STR0005 ;	// "Pesquisar..."
			ACTION FR271CPesqOrc(@oOrcamentos, @aArray, @oNumOrc, @cNumOrc,"",cVendLoja)
		
			@ 20,02 TO 128,176 LABEL STR0006 PIXEL	// "Resultado da Pesquisa"    
			
			@ 27,04 LISTBOX oOrcamentos FIELDS HEADER "", If(lPreVend,"Pre-Venda","DAV") ,STR0008,STR0007 FIELDSIZES 7,30,70 SIZE 169,87.5 PIXEL	// "Orçamento","Cliente"
	
			oOrcamentos:SetArray(aArray)
			oOrcamentos:bLine := {|| {If(aArray[oOrcamentos:nAt,1],oSim,oNao),aArray[oOrcamentos:nAt,4],aArray[oOrcamentos:nAt,3],aArray[oOrcamentos:nAt,2]} }
			oOrcamentos:bLDblClick := {|| FR271CNumClik(@oOrcamentos,@aArray,@oNumOrc,@cNumOrc,@oNumDAV,@cNumDAV)}		
			oOrcamentos:Disable()
			oNumOrc:bLostFocus := {|| If(!Empty(cNumOrc),oBtnOK:SetFocus(),NIL) }	  
	
			DEFINE SBUTTON oBtnOK FROM 115,141 PIXEL TYPE 1 ENABLE ACTION If(!Empty(cNumOrc),;
				FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
								@oHora			, @cHora		, @oDoc			, @cDoc			,; 			
								@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,; 	
								@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,; 	
								@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;		
								@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;		
								@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;		
								@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;		
								@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
								@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
								@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
								@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
								@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
								@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
								@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
								@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
								@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
								@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,; 
								@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
								@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
								@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
								@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,; 
								@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
								@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
								@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
								@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
								@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
								@nValor			, @cCliente		, @cLojaCli	    , /*cNumOrig*/	,;
								@cCupom			, @cTipoCli		, @lDescITReg	, @cNumDAV		,;
								Nil				, Nil					, Nil			, Nil		,;
								Nil				, Nil					, Nil			, Nil		,;
								Nil				, Nil					, @aMostruario),)

			
			DEFINE SBUTTON FROM 115,111 PIXEL TYPE 2 ENABLE ACTION {|| cNumDAV := "", oDlg:End() }	   
			
			ACTIVATE DIALOG oDlg CENTERED
			
		Else
			
			// Carrega as perguntas selecionadas
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ mv_par01 - Num. Orcamento     ?                              ³
			//³ mv_par02 - Orcamentos         ? (1-Data Atual 2-Todos)       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Pergunte("FRT271",.T.)
				If lUsaDisplay
					DisplayEnv(StatDisplay(), "1E" + STR0036 + "|" )        //"Codigo do produto: "
					DisplayEnv(StatDisplay(), "*")	// Habilitar o echo das digitacoes do teclado
				Endif
				Return(NIL)
			EndIf
			
			cNumOrc := MV_PAR01
			cSegPar := MV_PAR02
			
			// Caso o numero do Orcamento esteja em Branco iremos procurar pelos Orcamentos disponiveis
			// conforme o segundo parametro do PERGUNTE acima
			If !Empty(cNumOrc)
				// Carrega para o aArray ja criado para a estrutura sem Touch Screen
				aRetOrcs := FR271COrcsTo(@cNumOrc,@cSegPar)
				If !Empty(aRetOrcs)
					
					FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
									@oHora			, @cHora		, @oDoc			, @cDoc			,;
									@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,;
									@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,;
									@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;
									@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;
									@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;
									@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;
									@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
									@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
									@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
									@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
									@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
									@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
									@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
									@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
									@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
									@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,;
									@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
									@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
									@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
									@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,;
									@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
									@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
									@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
									@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc	,;
									@nValor			, @cCliente		, @cLojaCli		, /*cNumOrig*/	,;
									@cCupom			, @cTipoCli		, @lDescITReg	, @cNumDAV		,;
									Nil				, Nil					, Nil			, Nil		,;
									Nil				, Nil					, Nil			, Nil		,;
									Nil				, Nil					, @aMostruario)	
	
				EndIf
		
			Else // Aqui neste ELSE  montaremos uma tela contendo os orcamentos a serem escolhidos
				
				aRetOrcs := FR271COrcsTo(@cNumOrc)
				
				// Verificando se usuario marcou algum(s) Orcamento(s) (ARetOrcs contem os Itens Selecionados)
				If !Empty(aRetOrcs)
					
					cNumOrc := aRetOrcs[1,1]
					
					FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
									@oHora			, @cHora		, @oDoc			, @cDoc			,;
									@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,;
									@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,;
									@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;
									@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;
									@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;
									@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;
									@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
									@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
									@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
									@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
									@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
									@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
									@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
									@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
									@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
									@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,; 
									@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
									@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
									@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
									@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,; 
									@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
									@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
									@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld  ,;
									@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
									@nValor			, @cCliente		, @cLojaCli		, /*cNumOrig*/	,;
									@cCupom 		, @cTipoCli		, @lDescITReg	, @cNumDAV		)
				EndIf
			EndIF
		EndIf
	
	Else
	
		If !lTouch // Caso NAO seja interface Touch Screen
			
			aArray := {{.F.,"",""}}
			oSim   := LoadBitmap(GetResources(), "BR_VERDE")
			oNao   := LoadBitmap(GetResources(), "BR_VERMELHO")
			
			DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 255,353 PIXEL	// "Carregamento de Orçamentos"
			
			@ 06,02 SAY STR0004 PIXEL	// "Orçamento:"
			@ 05,40 GET oNumOrc VAR cNumOrc SIZE 15,7 PIXEL PICTURE PesqPict("SL1","L1_NUM") ;
						ON CHANGE If(!Empty(cNumOrc),(oBtnOK:lReadOnly:=.T.,;
				FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
								@oHora			, @cHora		, @oDoc			, @cDoc			,; 			
								@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,; 	
								@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,; 	
								@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;		
								@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;		
								@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;		
								@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;		
								@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
								@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
								@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
								@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
								@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
								@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
								@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
								@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
								@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
								@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,; 
								@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
								@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
								@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
								@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,; 
								@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
								@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
								@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
								@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
								@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
								@nValor		, @cCliente		, @cLojaCli		, NIL			,;
								@cCupom      	, @cTipoCli		, Nil				, Nil		,;
								Nil				, Nil				, Nil				, Nil		,;
								Nil				, Nil				, Nil				, Nil		,;
								Nil				, Nil				, @aMostruario),oBtnOK:lReadOnly:=.F.),) 

								
			DEFINE SBUTTON oBtnPesq FROM 03,78 PIXEL TYPE 14 ENABLE ONSTOP STR0005 ;	// "Pesquisar..."
			ACTION FR271CPesqOrc(@oOrcamentos, @aArray, @oNumOrc, @cNumOrc,"",cVendLoja)
		
			@ 18,02 TO 125,175.5 LABEL STR0006 PIXEL	// "Resultado da Pesquisa"
			@ 25,04 LISTBOX oOrcamentos FIELDS HEADER "",STR0007,STR0008 FIELDSIZES 7,30,70 SIZE 169,87.5 PIXEL	// "Orçamento","Cliente"
			oOrcamentos:SetArray(aArray)
			oOrcamentos:bLine := {|| {If(aArray[oOrcamentos:nAt,1],oSim,oNao),aArray[oOrcamentos:nAt,2],aArray[oOrcamentos:nAt,3]} }
			oOrcamentos:bLDblClick := {|| FR271CNumClik(@oOrcamentos,@aArray,@oNumOrc,@cNumOrc)}
			oOrcamentos:Disable()
			oNumOrc:bLostFocus := {|| If(!Empty(cNumOrc),oBtnOK:SetFocus(),NIL) }				
			DEFINE SBUTTON oBtnOK FROM 113,141 PIXEL TYPE 1 ENABLE ACTION If(!Empty(cNumOrc),;
				FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
								@oHora			, @cHora		, @oDoc			, @cDoc			,; 			
								@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,; 	
								@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,; 	
								@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;		
								@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;		
								@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;		
								@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;		
								@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
								@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
								@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
								@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
								@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
								@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
								@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
								@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
								@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
								@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,; 
								@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
								@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
								@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
								@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,; 
								@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
								@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
								@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
								@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
								@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
								@nValor			, @cCliente		, @cLojaCli	    , NIL			,;
								@cCupom       	, @cTipoCli		, NIL			, NIL			,;
								NIL				, @cDocFo),)
								
		
			DEFINE SBUTTON FROM 113,111 PIXEL TYPE 2 ENABLE ACTION oDlg:End()
			
			ACTIVATE DIALOG oDlg CENTERED
			
		Else
			
			// Carrega as perguntas selecionadas
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ mv_par01 - Num. Orcamento     ?                              ³
			//³ mv_par02 - Orcamentos         ? (1-Data Atual 2-Todos)       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Pergunte("FRT271",.T.)
				If lUsaDisplay
					DisplayEnv(StatDisplay(), "1E" + STR0036 + "|" )        //"Carregamento de Orçamentos"
					DisplayEnv(StatDisplay(), "*")	// Habilitar o echo das digitacoes do teclado
				Endif
				Return(NIL)
			EndIf
			
			cNumOrc := MV_PAR01
			cSegPar := MV_PAR02
			
			// Caso o numero do Orcamento esteja em Branco iremos procurar pelos Orcamentos disponiveis
			// conforme o segundo parametro do PERGUNTE acima
			If !Empty(cNumOrc)
				// Carrega para o aArray ja criado para a estrutura sem Touch Screen
				aRetOrcs := FR271COrcsTo(@cNumOrc,@cSegPar)
				If !Empty(aRetOrcs)
					
					FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
									@oHora			, @cHora		, @oDoc			, @cDoc			,;
									@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,;
									@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,;
									@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;
									@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;
									@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;
									@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;
									@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
									@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
									@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
									@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
									@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
									@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
									@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
									@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
									@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
									@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,;
									@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
									@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
									@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
									@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,;
									@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
									@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
									@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
									@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
									@nValor		, @cCliente		, @cLojaCli	    , NIL			,;
									@cCupom       , @cTipoCli		, Nil				, Nil		,;
									Nil				, Nil				, Nil				, Nil		,;
									Nil				, Nil				, Nil				, Nil		,;
									Nil				, Nil				, @aMostruario)
				EndIf
		
			Else // Aqui neste ELSE  montaremos uma tela contendo os orcamentos a serem escolhidos
				
				aRetOrcs := FR271COrcsTo(@cNumOrc)
				
				// Verificando se usuario marcou algum(s) Orcamento(s) (ARetOrcs contem os Itens Selecionados)
				If !Empty(aRetOrcs)
					
					cNumOrc := aRetOrcs[1,1]
					
					FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
									@oHora			, @cHora		, @oDoc			, @cDoc			,;
									@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,;
									@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,;
									@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;
									@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;
									@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;
									@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;
									@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
									@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
									@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
									@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
									@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
									@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
									@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
									@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
									@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
									@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,; 
									@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
									@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
									@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
									@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,; 
									@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
									@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
									@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld  ,;
									@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
									@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
									@nValor			, @cCliente		, @cLojaCli	    , NIL			,;
									@cCupom       	, @cTipoCli		)
				EndIf
			EndIF
		EndIf
	EndIf	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

If lUsaDisplay
	DisplayEnv(StatDisplay(), "1E" + STR0036 + "|" )        //"Codigo do produto: "
	DisplayEnv(StatDisplay(), "*")	// Habilitar o echo das digitacoes do teclado
Endif

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271CPesq³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisar os Orcamentos em Aberto no Server da Retaguarda  ³±±
±±³          ³ e Exibi-los Para a Selecao.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FR271CPesqOrc(oOrcamentos, aArray, oNumOrc, cNumOrc, cOrigem,cVendLoja)
Local cNumero  := ""
Local cCliente := ""
Local cOrc			:= ""
Local aRet			
Local nMvFrLmOrc	:= SuperGetMV("MV_FRLMORC",,300)	// Parametrização para controle do Limite de Orçamentos a serem carregados
Local nL1NUM   		:= TamSX3("L1_NUM")[1]				// Tamanho do campo B1_COD
Local nA1NOME  		:= TamSX3("A1_NOME")[1]				// Tamanho do campo B1_COD
Local lL1_NumOrc	:= (SL1->(FieldPos("L1_NUMORC")) > 0)
Local lRet 			:= .T.
Local nL1NumOrc 	:= 0
Local cNumDavOrc	:= ""
Local lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC)
Local nTpImpOrc		:= IIf(lLjNfPafEcf , 1, SuperGetMV("MV_LJTPIMO",,0)) //Parametro para definição de como deve ser a importação do orçamento: 0-Normal,1-Padrão PAF
Local lImpOrcPaf	:= .F. 

DEFAULT cOrigem		:= ""
Default cVendLoja	:= ""

lImpOrcPaf := (nTpImpOrc == 1) //Tipo de Importação de acordo com PAF (independente do PDV)

If lL1_NumOrc
	nL1NumOrc := TamSX3("L1_NUMORC")[1]
EndIf   

If Empty(cNumOrc) .AND. cOrigem <> "LOJA160"
	// "Pesquisar os Orçamentos em aberto poderá levar alguns segundos."+Chr(13)+;
	// "Caso você já saiba o Número do Orçamento, digite-o e clique em Ok. Prosseguir com a pesquisa?"+Chr(13)+;
	// "Prosseguir com a pesquisa?", "Pesquisar Orçamentos em Aberto"
 	If !MsgYesNo(STR0009+Chr(13)+STR0010+Chr(13)+STR0011, STR0012)
		Return NIL
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Orcamentos         ? (1-Data Atual 2-Todos)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cOrigem == "LOJA160"
	LJMsgRun(STR0013,,{|| aRet := FR271CMyCall("FR271CRPCOrc", {"SL1","SL2","SL4","SA1"}, 2, nMvFrLmOrc, cOrigem,SM0->M0_CGC,cVendLoja, nTpImpOrc)})	// "Aguarde. Pesquisando os orçamentos em aberto..."	
Else	
	//Esta sendo passado o parametro 9 como falso pois ao exibir a tela de pegunte com o help, quando o help recebia foco esse não prosseguia com a tecla enter.
	If !Pergunte("FRT10C",.T.,nil,nil,nil,nil,nil,nil,.F.) 
		Return NIL
	EndIf

	LJMsgRun(STR0013,,{|| aRet := FR271CMyCall("FR271CRPCOrc", {"SL1","SL2","SL4","SA1"}, MV_PAR01, nMvFrLmOrc,"LOJA701", SM0->M0_CGC,cVendLoja, nTpImpOrc)})	// "Aguarde. Pesquisando os orçamentos em aberto..."	
EndIf

cOrc := aRet[2]
If Empty(cOrc)
	// "Não foi encontrado nenhum Orçamento em aberto para ser carregado!", "Atenção"
	MsgStop(STR0015, STR0002)
	lRet := .F.
ElseIf Left(cOrc,4)=="ERRO"
	// "Erro ao pesquisar os Orçamentos em aberto. Tente novamente.", "Atenção"
	MsgStop(STR0016, STR0002)
Else
	aArray := {}												// Carrega os Orcamentos
	SA1->(DbSetOrder(1))
	While !Empty(cOrc)
		cNumero  := Left(cOrc, nL1NUM )
		cOrc     := Substr(cOrc, nL1NUM + 1)
		
		cCliente := Left(cOrc, nA1NOME )
		cOrc     := Substr(cOrc, nA1NOME + 1)
		
		If lLjNfPafEcf .Or. lImpOrcPaf
			If !lL1_NumOrc
				AAdd(aArray, {(cOrigem == "LOJA160"), 	cNumero, cCliente, ""})
			Else
				cNumDavOrc := Left(cOrc, nL1NumOrc )
				cOrc     := Substr(cOrc, nL1NumOrc + 1)
				AAdd(aArray, {(cOrigem == "LOJA160"),  cNumero, cCliente, cNumDavOrc})
			EndIf		
		Else
			AAdd(aArray, {.F., cNumero, cCliente})
		EndIf	
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza as Informacoes na Tela... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumOrc := Space(nL1NUM)
	If cOrigem <> "LOJA160"
		oNumOrc:Refresh()
		oOrcamentos:aArray := aArray
		oOrcamentos:Refresh()
		oOrcamentos:Enable()
		oOrcamentos:SetFocus()
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271CNumC³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marcar o Orcamento a Ser Finalizado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FR271CNumClik(oOrcamentos	, aArray, oNumOrc, cNumOrc,;
							  oNumDAV		, cNumDAV)                  
							  
DEFAULT oOrcamentos := Nil
DEFAULT aArray		:= {}
DEFAULT oNumOrc		:= Nil
DEFAULT cNumOrc		:= ""
DEFAULT oNumDAV		:= Nil
DEFAULT cNumDAV		:= ""

If aArray[oOrcamentos:nAt,1]
	cNumOrc := Space(TamSX3("L1_NUM")[1])   
	cNumDAV := IIF(SL1->(FieldPos("L1_NUMORC")) > 0, Space(TamSX3("L1_NUMORC")[1]), 10)
	aArray[oOrcamentos:nAt,1] := .F.
Else
	AEval(aArray, {|x| x[1]:=.F.})
	aArray[oOrcamentos:nAt,1] := .T.
	cNumOrc := aArray[oOrcamentos:nAt,2]
	If oNumDAV <> Nil	//Possui DAV/Pre venda somente quando recebe oNumDAV(PAFECF habilitado)
		cNumDAV := aArray[oOrcamentos:nAt,4] 	
	EndIf
	oOrcamentos:Refresh()
EndIf
oNumOrc:Refresh()

If oNumDAV <> Nil	
	oNumDAV:Refresh() 
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271CRPCO³ Autor ³ Vendas Clientes       ³ Data ³30/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisar os Orcamentos em Aberto no Server da Retaguarda  ³±±
±±³          ³ Via RPC Pelo FRTA020.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ FRTA020                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271CRPCOrc(nTipo, nMvFrLmOrc, cOrigem, cCnpj,cVendLoja, nTpImpOrc)
Local cRet		:= ""						// Parte do retorno da funcao
Local lFRTL1RPC := ExistBlock( "FRTL1RPC" )	// Ponto de entrada para filtrar o SL1 na consulta dos orcamentos
Local lUsaSL1	:= .T.						// Retorno do ponto de entrada FRTL1RPC
Local cSL1TEMP	:= GetNextAlias()			// Pega o proximo Alias Disponivel
Local cPart  	:= ""						// Dependendo do escolha filtra pelo dia							
Local cOrderBy	:= ""  						// Ordem da Query
Local lQuery	:= .F.                      // Verifica a possibilidade  da utilizacao da query
Local lL1_NumOrc:= (SL1->(ColumnPos("L1_NUMORC")) > 0)
Local lLjNfPafEcf:= LjNfPafEcf(cCnpj)
Local lPreVenda	:= SuperGetMV("MV_LJPRVEN",,.T.)
Local lLjPdvPaf	:= .F.
Local aCancOlds	:= {}
Local nX		:= 0

DEFAULT nMvFrLmOrc	:= 300					//Limite de orcamentos a serem importados 
DEFAULT cOrigem		:= ""
DEFAULT cCnpj		:= "99.999.999/9999-99"  //Valida PAF-ECF
Default cVendLoja	:= ""
Default nTpImpOrc	:= 0

lLjPdvPaf := (nTpImpOrc	== 1) //Tipo de Importação de acordo com PAF (independente do PDV)

#IFDEF TOP  
	If TcSrvType() <> "AS/400"				
		lQuery := .T.	
	EndIf	
#ENDIF

If lQuery
  	If nTipo == 1
		cPart := "%L1_EMISSAO	= '"+ DTOS(dDataBase)+"'	 AND%"
	Else
		cPart := "%%" 
	EndIf 	
	
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Integracao Financial Services: somente orcamentos³
	//³sem analise e/ou analise aprovada                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	If lUsaIntFS
		cPart := Left(cPart, Len(cPart)-1) + "(L1_IFSANST = ' ' OR L1_IFSANST = '1') AND%
	EndIf
	
	cOrderBy := "%L1_NUM , A1_NOME%"        

	If lLjNfPafEcf .AND. lLjPdvPaf .And. lL1_NumOrc		
		cOrderBy := "%L1_NUM , A1_NOME, L1_NUMORC%"
	EndIf
	
	/* Query utilizada para filtrar todos os dados necessarios */
	If lLjNfPafEcf .And. lLjPdvPaf
		If lPreVenda
			cPart := Left(cPart, Len(cPart)-1) + "(L1_TPORC = 'P') AND%"
		Else
			cPart := left(cPart, Len(cPart)-1) + "(L1_TPORC = 'D') AND%"
		EndIf
		
		If cOrigem == "LOJA701" 
			BeginSql alias cSL1TEMP
				SELECT	L1_NUM ,A1_NOME, L1_NUMORC
			
				FROM %table:SL1% SL1 ,%table:SA1% SA1 
				WHERE	L1_FILIAL	=	%xfilial:SL1%			AND	
						A1_FILIAL	=	%xfilial:SA1%			AND	
						L1_DTLIM 	>= 	%exp:DTOS(dDataBase)%	AND
						L1_CLIENTE  =  A1_COD					AND
						L1_LOJA  	=  A1_LOJA                  AND
					   	L1_PEDRES	=  " "						AND
						L1_SITUA	<> "FR"						AND	
						((L1_SERIE  =  " "						AND
						L1_DOC      =  " "   	                AND
						L1_PDV      =  " "       	           	AND
						L1_STORC 	<> "C"						AND
						%exp:cPart%
						SL1.%notDel%							AND
						SA1.%notDel%)                           OR 
				    	(L1_DOC		=  " "						AND
						L1_RESERVA	<> " "						AND
						L1_DOCPED	=  " "						AND
						L1_STATUS 	<> "D"						AND
						L1_PEDRES	=  " "))
									
				ORDER BY %exp:cOrderBy%
			EndSql        		
		ElseIf !cOrigem == "LOJA160" 
			BeginSql alias cSL1TEMP
			SELECT	L1_NUM ,A1_NOME, L1_NUMORC

				FROM %table:SL1% SL1 ,%table:SA1% SA1 
				WHERE	L1_FILIAL	=	%xfilial:SL1%			AND	
						A1_FILIAL	=	%xfilial:SA1%			AND	
						L1_DTLIM 	>= 	%exp:DTOS(dDataBase)%	AND
						L1_SERIE    =  " "						AND
						L1_DOC      =  " "   	                AND
						L1_PDV      =  " "       	           	AND
						L1_ORCRES	=  " "						AND
						L1_STORC 	<> "C"						AND
						L1_CLIENTE  =  A1_COD					AND
						L1_LOJA  	=  A1_LOJA                  AND
						L1_SITUA	<> "FR"						AND											
						%exp:cPart%
						SL1.%notDel%							AND
						SA1.%notDel%
				ORDER BY %exp:cOrderBy%
			EndSql        
		Else
			BeginSql alias cSL1TEMP
				SELECT	L1_NUM , A1_NOME, L1_NUMORC
				FROM %table:SL1% SL1 ,%table:SA1% SA1
				WHERE	L1_FILIAL	=	%xfilial:SL1%			AND	
						A1_FILIAL	=	%xfilial:SA1%			AND	
						L1_EMISSAO 	<= 	%exp:DTOS(dDataBase - 1)% AND						 
						L1_SERIE    =  " "						AND
						L1_DOC      =  " "   	                AND
						L1_PDV      =  " "       	           	AND
						L1_STORC 	<> "C"						AND
						L1_ORCRES	=  " "						AND
						L1_CLIENTE  =  A1_COD					AND
						L1_LOJA  	=  A1_LOJA                  AND
						L1_SITUA	<>  "FR"					AND
						%exp:cPart%
						SL1.%notDel%							AND
						SA1.%notDel%                            
				ORDER BY %exp:cOrderBy%
			EndSql
		EndIf	
	Else	
		BeginSql alias cSL1TEMP
			SELECT	L1_NUM ,A1_NOME
		
			FROM %table:SL1% SL1 ,%table:SA1% SA1 
			WHERE	L1_FILIAL	=	%xfilial:SL1%			AND	
					A1_FILIAL	=	%xfilial:SA1%			AND	
					L1_DTLIM 	>= 	%exp:DTOS(dDataBase)%	AND
					L1_DOC      =   " "   	                AND
					L1_CLIENTE  =   A1_COD					AND
					L1_LOJA  	=   A1_LOJA                 AND
					L1_PEDRES	=   " "						AND
					L1_SITUA	<>  "FR"					AND
					%exp:cPart%
					SL1.%notDel%							AND
					SA1.%notDel%							AND
					(
					 	(
					 		L1_SERIE    =	" "				AND	
					 		L1_PDV		=	" "				AND
							L1_STORC	<>	"C"
						) OR
						(
							L1_RESERVA	<>	" " 			AND
							L1_STATUS	<>	"D"				AND
							L1_DOCPED	=	" "
						)
					)
			ORDER BY %exp:cOrderBy%
		EndSql        
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Forma a String de retorno concatenado o resultado da query ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cSL1TEMP)->(Eof())
		/* Ponto de entrada para fazer o filtro no SL1 
		se entra ou nao na consulta do caixa.  */
		If lFRTL1RPC
			LjGrvLog( NIL, "Antes da execução do P.E. FRTL1RPC", {cSL1TEMP,cVendLoja})
			lUsaSL1 := ExecBlock( "FRTL1RPC", .F.,.F.,{cSL1TEMP,cVendLoja} )
			LjGrvLog( NIL, "Retorno da execução do P.E. FRTL1RPC", lUsaSL1)
			If ValType( lUsaSL1 ) == "L"
				If !lUsaSL1
					(cSL1TEMP)->(dbSkip())
					Loop
				Endif
			Endif
  		Endif                      

  		If lLjNfPafEcf .And. lLjPdvPaf
			If lL1_NumOrc
				If Empty(AllTrim((cSL1TEMP)->L1_NUMORC)) .And. (AllTrim(cOrigem) == "LOJA160")
					aAdd( aCancOlds , xFilial("SL1")+(cSL1TEMP)->L1_NUM )
				Else 
					cRet	+= (cSL1TEMP)->L1_NUM + (cSL1TEMP)->A1_NOME + (cSL1TEMP)->L1_NUMORC
				EndIf
			Else
				cRet += (cSL1TEMP)->L1_NUM + (cSL1TEMP)->A1_NOME + " "
			EndIf
		Else
			cRet  += (cSL1TEMP)->L1_NUM + (cSL1TEMP)->A1_NOME + Iif(lLjPdvPaf, Space(TamSX3("L1_NUMORC")[1]),'')
		EndIf
		
		(cSL1TEMP)->(dbSkip())
	End
	
	//Efetua a limpeza dos orçamentos que foram gerados antes do paf para cancelamento e "limpeza" do SQL 
	If Len(aCancOlds) > 0
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
			
		For nX := 1 to Len(aCancOlds)
			If SL1->(DbSeek(aCancOlds[nX]))
				RecLock("SL1",.F.)
				REPLACE SL1->L1_STORC WITH "C"
				SL1->(MsUnlock())
			EndIf
		Next nX
	EndIf
Else   
	DbSelectArea("SL1")
	SL1->(DbSetOrder(2))
	SL1->(MsSeek(xFilial("SL1")))
	While (Empty(SL1->L1_SERIE + SL1->L1_DOC + SL1->L1_PDV) .AND. !SL1->(EOF()) .AND.;
			   (Len(cRet) + Len(SL1->L1_NUM) + Len(SL1->L1_CLIENTE) <= nMvFrLmOrc)) .OR.;
		  (Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND.;
		  (SL1->L1_STATUS <> "D") .AND. Empty(SL1->L1_PEDRES) .AND. lLjNfPafEcf)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Orcamentos(nTipo): ³
		//³ 1 - Data Atual     ³
		//³ 2 - Todos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipo=1 .AND. L1_EMISSAO!=dDataBase
			SL1->(dbSkip())
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contemplar Somente Orcamentos Nao Expirados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL1->L1_DTLIM < dDataBase
			SL1->(dbSkip())
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Os registros cancelados nao devem ser considerados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(SL1->L1_STORC) == "C"
			SL1->(dbSkip())
			Loop
		EndIf		
		
		/*BEGINDOC
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Integracao Financial Services: somente orcamentos³
		//³sem analise e/ou analise aprovada                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ENDDOC*/
		If lUsaIntFS .and. !Empty(SL1->L1_IFSANST) .AND. SL1->L1_IFSANST <> _L1_IFSANST_APROVADO   //1
			SL1->(dbSkip())
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
					SL1->(dbSkip())
					Loop
				Endif
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a busca do nome do cliente no SA1  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA ))
            
			If LjNfPafEcf(cCnpj) 
				If !lL1_NumOrc
					cRet += SL1->L1_NUM + SA1->A1_NOME + " "
				Else
					If Empty(AllTrim(SL1->L1_NUMORC)) .And. (AllTrim(cOrigem) == "LOJA160")
						aAdd( aCancOlds , xFilial("SL1") + SL1->L1_NUM )
					Else					
						cRet += SL1->L1_NUM + SA1->A1_NOME + SL1->L1_NUMORC
					EndIf
				EndIf
			Else
				cRet += SL1->L1_NUM + SA1->A1_NOME			
			EndIf
			
		EndIf
			
		SL1->(dbSkip())
	End
	
	//Efetua a limpeza dos orçamentos que foram gerados antes do paf para cancelamento e "limpeza" do SQL 
	If Len(aCancOlds) > 0
		
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1))
			
		For nX := 1 to Len(aCancOlds)
			If SL1->(DbSeek(aCancOlds[nX]))
				RecLock("SL1",.F.)
				REPLACE SL1->L1_STORC WITH "C"
				SL1->(MsUnlock())
			EndIf
		Next nX
	EndIf
	  
EndIf

Return ({"OK", cRet})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271CRPCL³ Autor ³ Vendas Clientes       ³ Data ³31/10/2001³±±
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

Function FR271CRPCLoad(	cNumOrc ,	lDAV ,	cOrigem ,	lOrigPAF, lImpIntFs, lImpGE, cPdv )
Local i
Local aRet		  := {"",""}
Local cSL1		  := ""
Local cSL2		  := ""
Local cSL4		  := ""
Local aSA1		  := {}
Local aSL1		  := {}
Local aSL2		  := {}
Local aSL4		  := {}
Local aSLXAux	  := {}
Local cItRetira	  := ""			//Item marcado como RETIRA
Local cItOutros	  := ""			//Item marcado diferente de RETIRA	
Local nMvFrtImp	  := SuperGetMV("MV_FRTIMP",,1)
Local aMsgOrc	  := {}        	// Menssagem de orcamento
Local nW		  := 0          	// numero de W
Local lJaExiste   := .F. 		// Verifica se já existe produto no aProdEst
Local aAreaAtual  := {}			// Backup do array
Local aProdEst	  := {}			// Array com produtos importados
Local nY		  := 0  		// cintador
Local nTotalCF 	  := 0			// Total do Cupom Fiscal (Verifica se a ENTREGA eh posterior)
Local lRetira     := .F.		// Se o item eh Retira (L2_Entrega == 2 ou " ")
Local lExTpRetira := ExistFunc("LJXTpRetira")		// Verifica a existencia da funcao que verifica se o tipo de entrega do item eh "2" ou " " - Retira
Local lVerOSOtc	  := HasTemplate("OTC") .AND. ExistTemplate("LjVerOSBx")
Local lUsaRegL2	  := .T.								//Se irá considerar registro do L2, quando PAF-ECF, necessário considerar registros excluídos
Local lNfPafEcf	  := LjNfPafEcf(SM0->M0_CGC)			//Se habilitado modo PAF-ECF  
Local lGar		  := .F.								//PDV sem garantia        
Local aAreaSL2	  := {} 								//Area do SL2
Local lGE		  := LjUP104OK() // Validação do Conceito Garantia Estendida 
Local lPafMD5	  := SL2->(ColumnPos("L2_PAFMD5")) > 0	//verifica se o campo L2_PAFMD5 existe

Default lImpIntFs := .F. //Não integrado com o financial services (parametro MV_LJINTFS .T. ou inexistencia do campo LQ_IFSANST) 
Default lImpGE	 := .F. //Retaguarda não usa garantia estendida 
Default lDAV	 := .F.   
Default cOrigem  := ""
Default lOrigPAF := .F.   
Default lImpIntFs := .F. //Não integrado com o financial services (parametro MV_LJINTFS .T. ou inexistencia do campo LQ_IFSANST)
Default cPdv     := ""

DbSelectArea("SL1")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca orcamento a partir do DAV informado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("U_FRTNUMORC")
	LjGrvLog( NIL , "Antes da execução do P.E. FRTNUMORC", cNumOrc)
	cNumOrc := U_FRTNUMORC(cNumOrc)
	LjGrvLog( NIL , "Retorno da execução do P.E. FRTNUMORC", cNumOrc)
	
	If valtype(cNumOrc) <> "C"
		cNumOrc := ""
	EndIf
ElseIf lDAV
	cNumOrc := LjRetOrDAV(cNumOrc)
EndIf

If Empty(cNumOrc)
	aRet := {"NOTFOUND", ""}
ElseIf SL1->(DbSeek(xFilial()+cNumOrc))

    If lGE .AND. !lImpGE 
	    //Verifica se Existe algum item no orcamento com G.E., caso exista não permite a importacao do orçamento
	   	aAreaSL2 := SL2->(GetArea())     
	   	SL2->(DbSetOrder(1)) //Filial + orcamento
		SL2->(DbSeek(xFilial()+SL1->L1_NUM) )
		While !lGar .And. SL2->(!Eof()) .AND. SL2->(L2_FILIAL+L2_NUM) == SL2->(xFilial())+SL1->L1_NUM   
			lGar := !Empty(SL2->L2_GARANT)  
			SL2->(DbSkip(1))  
		End		         		
	    RestArea(aAreaSL2)
	EndIf	

	If !Empty(SL1->L1_DOC) .OR. !Empty(SL1->L1_DOCPED)
		aRet := {"VENDIDO",""}
	Else
		If (SL1->L1_DTLIM < dDataBase .AND. cOrigem <> "LOJA160")
			aRet := {"EXPIRADO",""}
		ElseIf !FR271CVldImp(cNumOrc,Nil ,cPdv) .Or. !Empty(SL1->L1_SITUA) 	   
			aRet := {"JAIMPORTADO" , cNumOrc}		
		ElseIf lOrigPAF .AND. Empty(SL1->L1_NUMORC)
			aRet := {"SEMDAV/PRE" , cNumOrc}
 		ElseIf !Empty(SL1->L1_PEDRES)
			aRet := {"NOTFOUND", ""}	
		ElseIf lGE .AND. !lImpGE .AND. lGar
			aRet := {"NOGEPDV", cNumOrc}
			ConOut(STR0034 + " [" + cEmpAnt + "] "+STR0030 +" [" + cFilAnt + "] "+STR0031 + " [" + cNumOrc + "] " + "] " + STR0032 + IIF(Empty(cOrigem), STR0033, cOrigem ))   //"PDV nao configurado para Garantia Estendida. Verifique as configuracoes do PDV da Empresa " + ## + "Filial [" + ## + "] Orcamento [" + ##### + "] Origem da chamada:" + ##### + " nao definida"   
		ElseIf lUsaIntFS .AND. (!Empty(SL1->L1_IFSANST) .AND. !lImpIntFs )  //So valida o campo se houve analise de crediro 
			aRet := {"NOINTFSPDV", cNumOrc}
			ConOut(STR0029 + " [" + cEmpAnt + "] "+STR0030 +" [" + cFilAnt + "] "+STR0031 + " [" + cNumOrc + "] " + STR0032 + IIF(Empty(cOrigem), STR0033, cOrigem ))   //"PDV nao configurado para integracao com o financial services. Verifique as configuracoes do PDV da Empresa [" + ## + "Filial [" + ## + "] Orcamento [" + ##### + "] Origem da chamada:" + ##### + " nao definida"   
		ElseIf lUsaIntFS .and. !Empty(SL1->L1_IFSANST) .AND. SL1->L1_IFSANST <> _L1_IFSANST_APROVADO //1
			aRet := {"INTFSANCRDNAP", cNumOrc}
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a String do SL1 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEstru := SL1->(dbStruct()) 
			If nMvFrtImp == 1
				cSL1 := FR271CDBF2Str(aEstru,"SL1")
			Else
				aSLXAux := FR271CDBF2Str(aEstru,"SL1")
				AAdd(aSL1, aSLXAux)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a String do SL2 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL2")
			SL2->(DbSetOrder(1))
			aEstru := SL2->(dbStruct())
			  
			//Para o PAF-ECF, considera os registros deletados que possuem MD5, permitindo que itens cancelados sejam exportados para o PDV
			If lNfPafEcf
				SET DELETED OFF
			EndIf
			
			i := 0
			SL2->(MsSeek(xFilial()+SL1->L1_NUM))
			While SL2->L2_FILIAL+L2_NUM == xFilial()+SL1->L1_NUM
				
				//Verifica se registro deletado será considerado
				If lNfPafEcf
					//Quando for orcamento com Reserva (1-Retira Posterior ou 3-Entrega), o item nao devera ser cancelado na impressora,
					// pois se ele nao estivesse deletado, ele nao seria impresso no Cupom Fiscal, e sim no Cupom Nao-Fiscal
					lUsaRegL2 := !SL2->(Deleted()) .OR. ( SL2->(Deleted()) .AND. lPafMD5 .AND. !Empty(SL2->L2_PAFMD5) ;
								  .AND. !(SL2->L2_ENTREGA $ "1|3") )
				EndIf	
					
				If lUsaRegL2						
			
					i++
	
					If lVerOSOtc // Verifica se existe OS baixada para o produto que está sendo exportado.
						T_LjVerOSBx(xFilial(),"F")
					EndIf
					
					If nMvFrtImp == 1
						If lExTpRetira
							lRetira := LJXTpRetira(SL2->L2_ENTREGA)
						Else
							lRetira := (SL2->L2_ENTREGA == "2")
						EndIf
						If lRetira
							cItRetira += FR271CDBF2Str(aEstru,"SL2")
							nTotalCF  += SL2->L2_VLRITEM
						Else
							cItOutros += FR271CDBF2Str(aEstru,"SL2")
						Endif
					Else
						aSLXAux := FR271CDBF2Str(aEstru,"SL2")
						AAdd(aSL2, aSLXAux)
					EndIf
					
					If !SL2->(Deleted()) .AND. Empty(SL2->L2_RESERVA) .AND. (SuperGetMV("MV_ESTNEG",,"S") == "N" ).AND. SuperGetMV("MV_LJESTOR",,.F.)
	
						If Len(aProdEst) > 0
							For nY := 1 To Len(aProdEst)
								If (Alltrim(aProdEst[nY][1]) == Alltrim(SL2->L2_PRODUTO)) .AND. (Alltrim(aProdEst[nY][2]) == Alltrim(SL2->L2_LOCAL))
									aProdEst[nY][4] += SL2->L2_QUANT
									lJaExiste := .T.
								EndIf
						    Next nY
							If !(lJaExiste)
								Aadd(aProdEst,{SL2->L2_PRODUTO,SL2->L2_LOCAL,SL2->L2_TES,SL2->L2_QUANT})
							EndIf
						Else
							Aadd(aProdEst,{SL2->L2_PRODUTO,SL2->L2_LOCAL,SL2->L2_TES,SL2->L2_QUANT})
						EndIf
					EndIf
				EndIf	

				SL2->( DbSkip() )
			End
			
			//Desliga deletados, para o PAF-ECF considera os registros deletados que possuem MD5.
			If lNfPafEcf
				SET DELETED ON
			EndIf

			If Len(aProdEst) > 0
			    lJaExiste := .F.
				aAreaAtual := GetArea()
				
				For nY := 1 To Len(aProdEst)

					DBSelectArea("SF4")
					DBSetOrder(1)
					If DbSeek(xFilial("SF4")+aProdEst[nY][3])

						If SF4->F4_ESTOQUE == "S"
							DbSelectArea("SB2")
							DbSetOrder(1)

							If DbSeek(xFilial("SB2") + aProdEst[nY][1] + aProdEst[nY][2])

								If ((SB2->B2_QATU - SB2->B2_RESERVA) <= 0) .OR. ((SB2->B2_QATU - SB2->B2_RESERVA) < aProdEst[nY][4])   
									For nW := 1 To Len(aMsgOrc)
										If (Alltrim(aProdEst[nY][1]) == Alltrim(aMsgOrc[nW][1])) .AND. (Alltrim(aProdEst[nY][2]) == AllTrim(aMsgOrc[nW][2]))
											lJaExiste := .T.
										EndIf
									Next nW
									If !(lJaExiste)
										Aadd(aMsgOrc,{aProdEst[nY][1],aProdEst[nY][2]})
									EndIf

	                        	EndIf
	                        EndIf
	                    EndIf
					EndIf
				Next nY
				RestArea(aAreaAtual)
            EndIf

			cSL2 := cItRetira + cItOutros
			cSL2 := I2Bin(i)+cSL2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a String do SL4 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL4")
			SL4->(DbSetOrder(1))
			aEstru := SL4->(dbStruct())
			i := 0
			SL4->(DbSeek(xFilial()+SL1->L1_NUM))
			While SL4->L4_FILIAL+L4_NUM == xFilial()+SL1->L1_NUM
				i++
				If nMvFrtImp == 1
					cSL4 += FR271CDBF2Str(aEstru,"SL4")
				Else
					aSLXAux := FR271CDBF2Str(aEstru,"SL4")
					AAdd(aSL4, aSLXAux)
				EndIf
				SL4->( dbSkip() )
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
			aRet := {"OK", cSL1+cSL2+cSL4, aSA1, aSL1, aSL2, aSL4, nTotalCF,Len(cSL1+cSL2+cSL4)}
			If Len(aMsgOrc) > 0
				aRet := {"SEMESTOQUE" ,cNumOrc,aMsgOrc}		
			EndIf
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
±±³Fun‡„o	 ³FR271CDBF2³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pega Conteudo do Registro e Gera uma String com Chr(1)     ³±±
±±³          ³ Separando os Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FR271CDBF2Str(aEstru, cAlias)
Local i			:= 0
Local xRet
Local nMvFrtImp	:= SuperGetMV("MV_FRTIMP",,1)
Local xField

DEFAULT cAlias 	:= Alias()	//Recebe Alias para evitar erro quando area selecionada diferente da area desejada
            
If nMvFrtImp == 1
	xRet := ""
	For i := 1 To Len(aEstru)
		xField := (cAlias)->(FieldGet(i))

		If aEstru[i][2]="N"
			If xField==0
				xRet += Chr(1)
			Else
				xRet += Chr(1)+LTrim(Str(xField,aEstru[i][3],aEstru[i][4]))
			EndIf
		ElseIf aEstru[i][2]="D"
			xRet += Chr(1)+RTrim(DToS(xField))
		ElseIf aEstru[i][2]="L"
			xRet += Chr(1)+If(xField,"T","F")
		Else
			xRet += Chr(1)+RTrim(xField)
		EndIf
	Next i
	xRet := I2Bin(Len(xRet)-1)+Substr(xRet,2)
Else
	xRet := {}
	For i := 1 To Len(aEstru)
		AAdd(xRet, { (cAlias)->(FieldName(i)), (cAlias)->(FieldGet(i)) })
	Next i
EndIf

Return(xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271CAFie³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extrai o Conteudo do Campo na String.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271CAField(xString, cField, nNumItem)
Local xRet
Local i				:= 0
Local nField		:= 0
Local nTamHeader	:= 0
Local nStart		:= 0
Local nLen 			:= 0
Local nTamSL2		:= 0
local nTamSL4  		:= 0
Local nPos			:= 0
Local nX			:= 0
Local nMvFrtImp		:= SuperGetMV("MV_FRTIMP",,1)
Local aAreaSX3		:= {}

DEFAULT nNumItem := 0

If nMvFrtImp == 1
	nTamHeader := Bin2I(Left(xString,2))
	If Left(cField,2)=="L1"
		nField := SL1->(FieldPos(cField))
		cType  := ValType(SL1->(FieldGet(nField)))
		If cType == "C"
			nLen := Len(SL1->(FieldGet(nField)))
		EndIf
		xRet   := FR271CPegaField(xString, 3, nTamHeader, nField, cType, nLen)
	ElseIf Left(cField,2)=="L2"
		nField := SL2->(FieldPos(cField))
		cType  := ValType(SL2->(FieldGet(nField)))
		If cType == "C"
			nLen := Len(SL2->(FieldGet(nField)))
		EndIf
		nItems := Bin2I(Substr(xString, nTamHeader+3, 2))
		nStart := nTamHeader+5
		For i := 1 To nNumItem
			nTamSL2 := Bin2I(Substr(xString, nStart, 2))
			If i == nNumItem
				xRet := FR271CPegaField(xString, nStart+2, nTamSL2, nField, cType, nLen)
			EndIf
			nStart += nTamSL2 + 2
		Next i
	ElseIf Left(cField,2)=="L4"
		nField := SL4->(FieldPos(cField))
		cType  := ValType(SL4->(FieldGet(nField)))
		If cType == "C"
			nLen := Len(SL4->(FieldGet(nField)))
		EndIf
		nItems := Bin2I(Substr(xString, nTamHeader+3, 2))
		nStart := nTamHeader+5
		For i := 1 To nItems
			nTamSL2 := Bin2I(Substr(xString, nStart, 2))
			nStart += nTamSL2 + 2
		Next i
		nItems := Bin2I(Substr(xString, nStart, 2))
		nStart := nStart+2
		For i := 1 To nNumItem
			nTamSL4 := Bin2I(Substr(xString, nStart, 2))
			If i == nNumItem
				xRet := FR271CPegaField(xString, nStart+2, nTamSL4, nField, cType, nLen)
			EndIf
			nStart += nTamSL4 + 2
		Next i
	EndIf
Else
	If Left(cField,2)=="L1"
		If nNumItem == 0
			nNumItem := 1
		EndIf
		For nX := 1 To Len(xString[NPOSSL1][nNumItem])
			If xString[NPOSSL1][nNumItem][nX][1] == Alltrim(cField)
				nPos := nX
				Exit
			EndIf
		Next nX
		If nPos <> 0
			xRet := xString[NPOSSL1][nNumItem][nPos][2]
		EndIf
	ElseIf Left(cField,2)=="L2"
		For nX := 1 To Len(xString[NPOSSL2][nNumItem])
			If xString[NPOSSL2][nNumItem][nX][1] == Alltrim(cField)
				nPos := nX
				Exit
			EndIf
		Next nX
		If nPos <> 0
			xRet := xString[NPOSSL2][nNumItem][nPos][2]
		EndIf
	ElseIf Left(cField,2)=="L4"
		For nX := 1 To Len(xString[NPOSSL4][nNumItem])
			If xString[NPOSSL4][nNumItem][nX][1] == Alltrim(cField)
				nPos := nX
				Exit
			EndIf
		Next nX
		If nPos <> 0
			xRet := xString[NPOSSL4][nNumItem][nPos][2]
		EndIf
	EndIf
EndIf

If nPos == 0 .AND. nMvFrtImp == 2
	aAreaSX3 := SX3->(GetArea())
	SX3->(DBSetOrder(2))
	If !(Sx3->(DBSeek(cField)))
		MsgAlert(STR0024 + CHR(10) + CHR(13) + STR0025 + cField + STR0028 )		//"Existem diferencas entre as tabelas da retaguarda e do FrontLoja."
																					//"O campo " + cField + " nao existe na base do front."
		Do Case
			Case SX3->X3_TIPO == "C"
				xRet := ""
			Case SX3->X3_TIPO == "N"
				xRet := 0
			Case SX3->X3_TIPO == "L"
				xRet := .T.
			Case SX3->X3_TIPO == "D"
				xRet := dDataBase
		EndCase
	Else
		Conout(STR0027 + cField + STR0028)	//"FRTA271C - FR271CAField - O campo " + cField + " não existe na base do front."
	EndIf
	RestArea(aAreaSX3)
EndIf

Return(xRet)

Static Function FR271CPegaField(cString, nPos, nTam, nField, cType, nLen)
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
±±³Fun‡„o	 ³FR271CQtdS³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Quantos Items Existem no Orcamento.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271CQtdSL2(xString)
Local nTamHeader
Local nItems
Local nMvFrtImp	:= SuperGetMV("MV_FRTIMP",,1)

If nMvFrtImp == 1
	nTamHeader := Bin2I(Left(xString,2))
	nItems     := Bin2I(Substr(xString, nTamHeader+3, 2))
Else
	nItems := Len(xString[NPOSSL2])
EndIf

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
Function FR271CSL4Qtd(xString)
Local i
Local nTamHeader	:= 0
Local nItems		:= 0
Local nTamSL2		:= 0
Local nMvFrtImp		:= SuperGetMV("MV_FRTIMP",,1)

If nMvFrtImp == 1
	nTamHeader := Bin2I(Left(xString,2))
	nItems     := Bin2I(Substr(xString, nTamHeader+3, 2))
	nStart     := nTamHeader+5
	For i := 1 To nItems
		nTamSL2 := Bin2I(Substr(xString, nStart, 2))
		nStart += nTamSL2 + 2
	Next i
	
	nItems := Bin2I(Substr(xString, nStart, 2))
Else
	nItems := Len(xString[NPOSSL4])
EndIf

Return(nItems)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271CMyCa³ Autor ³ Vendas Clientes       ³ Data ³02/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza RPC para retornar o Orcamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271CMyCall(	cFuncao	, aFiles	, uParm1	, uParm2	,; 
						uParm3	, uParm4	, uParm5	, uParm6	,; 
						uParm7	, uParm8	, uParm9	, uParm10	,; 
						uParm11	, uParm12	, uParm13	, uParm14	,; 
						uParm15)
Local cRPCServer	:= ""
Local nRPCPort      := 0
Local cRPCEnv       := ""
Local cRPCEmp       := ""
Local cRPCFilial    := ""
Local aAux          := {"","","","",""}
Local aRet          := {}
Local lRet          := .F.
Local nX			:= 0
Local lConnect 		:= .F.  
Local lNewConnect	:= .F.
Local nFor			:= 0
Local aAuxSer		:= {}
Local aServers		:= {}
Local lFRTCALLRPC 	:= ExistBlock( "FRTCALLRPC" )	// Ponto de entrada para manipular a conexão RPC
Local xRet
Local bError
Local bErrorBlock
Local oError
Local cError  
Local cErrorE




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao que controla o balanceamento do RPC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux		:= FrtDadoRpc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PE para manipular a conexão RPC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRTCALLRPC
	xRet := ExecBlock( "FRTCALLRPC", .F.,.F.,{cFuncao})
	If ValType(xRet) == "A"
		aAux		:= xRet
		
		//Reinicia objeto para realizar nova conexao		
		If Len(aAux) > 5 .AND. aAux[6]
			oRPCServer := Nil
		EndIf
	EndIf
EndIf

cRPCServer	:= aAux[1]
nRPCPort	:= Val(aAux[2])
cRPCEnv		:= aAux[3]
cRPCEmp		:= aAux[4]
cRPCFilial	:= aAux[5]

nFor := FrtServRpc()		// Carrega o numero de servidores disponiveis 
	
For nX := 1 To nFor         //  Carrega os dados do server
	aAuxSer	:= FrtDadoRpc() 
	If ( !Empty(aAuxSer[1]) .AND. !Empty(aAuxSer[2]) .AND. !Empty(aAuxSer[3])) 		
		Aadd(aServers,{aAuxSer[1],Val(aAuxSer[2]),aAuxSer[3]})
	EndIf
	aAuxSer := {}
Next nX 

lNewConnect		:= .F.
bOldError := ErrorBlock( {|x| LjVerIfErro(x) } ) // muda code-block de erro

BEGIN SEQUENCE
	If oRPCServer == Nil
		oRPCServer:=FwRpc():New( cRPCServer, nRPCPort , cRpcEnv )	// Instancia o objeto de oServer	
		oRPCServer:SetRetryConnect(1)								// Tentativas de Conexoes
		
		For nX := 1 To Len(aServers)                            	// Metodo para adicionar os Servers 
			oRPCServer:AddServer( aServers[nX][1], aServers[nX][2], aServers[nX][3] )
		Next nX
		
		lConnect := oRPCServer:Connect()							// Tenta efetuar conexao
		lNewConnect := .T.
	Else
		lConnect 	:= .T.
		lNewConnect := .F.
	EndIf
	
RECOVER
	lConnect 		:= .F.
END SEQUENCE

ErrorBlock( bOldError ) // Restaura rotina de erro anterior
	
If lConnect
	If lNewConnect
		oRPCServer:SetEnv(cRPCEmp,cRPCFilial,"FRT")                 // Prepara o ambiente no servidor alvo
	EndIf	

	If cFuncao == "GeraA1"
		aRet := oRPCServer:CallProc("GeraA1", uParm1)
		If ValType(aRet)=="A"
			If Left(aRet[1],2)=="OK"
				lRet := oRPCServer:CallProc("ConfA1", aRet[2])
				If ValType(lRet)=="L"
					cCod  := uParm1[AScan(uParm1,{|x|x[1]=="A1_COD"})][2]
					cLoja := uParm1[AScan(uParm1,{|x|x[1]=="A1_LOJA"})][2]
					// Se o Codigo gravado na Retaguarda foi diferente da base local, faz a correcao.
					If aRet[3] <> cCod
						FR271BGeraSL("SA1", {{"A1_COD", aRet[3]}}, .F.)
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
		// Funcao Generica para execucao dos comandos via RPC
		aRet := oRPCServer:CallProc( cFuncao	, uParm1	, uParm2	, uParm3	,; 
								 	uParm4		, uParm5	, uParm6	, uParm7	,; 
									uParm8		, uParm9	, uParm10	, uParm11	,; 
									uParm12		, uParm13	, uParm14	, uParm15   )
	
	EndIf									

	//Formata retorno diferente de Array
	If ValType(aRet) <> "A"
		If cFuncao == "LjConPrEst"
			aRet := {StrZero(Val("0"),10,2)} 	// caso não existi Conexão retorna zero
		ElseIf cFuncao == "GetSrvProfString" 	// Rotina retorna String, converte para array
			aRet := {aRet}
		ElseIf cFuncao == "SuperGetMV"			// retorna o valor de um para parametro
			aRet := {aRet}
		Else
			aRet := {"ERRO", ""}
		EndIf	
	EndIf
Else
	If cFuncao == "LjConPrEst"
		aRet := {StrZero(Val("0"),10,2)} // caso não existi Conexão retorna zero
	Else
		aRet := {"ERRO", ""}
	EndIf	
EndIf

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271CRPC ³ Autor ³ Vendas Clientes       ³ Data ³02/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza RPC para retornar o Orcamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271CRPC(	cFuncao	, aFiles	, cCodEmp	,; 
					cCodFil	, uParm1	, uParm2	,; 
					uParm3	, uParm4	, uParm5	,; 
					uParm6	, uParm7	, uParm8	,; 
					uParm9	, uParm10	, uParm11	,; 
					uParm12	, uParm13	, uParm14	,; 
					uParm15	, cCnpj		)
					
Local cDrvX2  := "DBFCDX"
Local cArqX2  := "SX2" + cCodEmp + "0"
Local cArqX6  := "SX6" + cCodEmp + "0"
Local cDriver := "DBFCDX"
Local i
Local aRet
Local cArqIX 
Local cArqInd
Local lUsaSIX := File("SIX" + cCodEmp + "0.dbf") .OR. File("SIX" + cCodEmp + "0.dtc")
Local lUsaSIND:= File("SINDEX.DBF") .OR. ("SINDEX.DTC")
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
Local cSecaoDB := ""
Local cTipSecao:= ""
#ENDIF 

DEFAULT	cArqInd:= "SIX"
DEFAULT cArqIX := "SIX" + cCodEmp + "0"
DEFAULT cCnpj  := "99.999.999/9999-99"  //Valida PAF-ECF 

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

USE &("SIGAMAT.EMP") ALIAS "SM0" SHARED NEW VIA cDrvX2
If NetErr()
	UserException("SM0 Open Failed")
EndIf
     
If lUsaSIX
	cArqIX := "SIX" + cCodEmp + "0"
	cArqInd:= "SIX" 
ElseIf lUsaSIND
	cArqIX := "SINDEX"
	cArqInd:= "SINDEX" 
EndIf

USE &(cArqIX) ALIAS &(cArqInd) SHARED NEW VIA cDrvX2

If NetErr()
	UserException("SIX Open Failed")
EndIf
DbSetOrder(1)
If Empty(IndexKey())
	UserException("SIX Open Index Failed")
EndIf


USE &(cArqX2) ALIAS "SX2" SHARED NEW VIA cDrvX2
If NetErr()
	UserException("SX2 Open Failed")
EndIf
DbSetOrder(1)
If Empty(IndexKey())
	UserException("SX2 Open Index Failed")
EndIf

USE &(cArqX6) ALIAS "SX6" SHARED NEW VIA cDrvX2
If NetErr()
	UserException("SX6 Open Failed")
EndIf
DbSetOrder(1)
If Empty(IndexKey())
	UserException("SX6 Open Index Failed")
EndIf

#IFDEF TOP
	xConnect := GetGlbValue("MYTOPCONNECT")
	
	If Empty(xConnect) .OR. xConnect$"ERROR"
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o tipo de secao configurada para conexao com ³ 
		//³o banco de dados no arquivo server.ini da Retaguarda  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTipSecao := GetPvProfString( "TopConnect","Alias","ERROR",cInIfile )
		If !(cTipSecao$"ERROR") 
			cSecaoDB := "TopConnect"
		EndIf
		cTipSecao := GetPvProfString( "TotvsDBAccess","Alias","ERROR",cInIfile ) 
		If !(cTipSecao$"ERROR") 
			cSecaoDB := "TotvsDBAccess"
		EndIf
		cTipSecao := GetPvProfString( "DBAccess","Alias","ERROR",cInIfile ) 
		If !(cTipSecao$"ERROR") 
			cSecaoDB := "DBAccess"
		EndIf
	
		cDataBase := GetPvProfString( cSecaoDB,"DataBase","ERROR",cInIfile )
		cAlias	  := GetPvProfString( cSecaoDB,"Alias","ERROR",cInIfile )
		cServer	  := GetPvProfString( cSecaoDB,"Server","ERROR",cInIfile )
		
		cConType  := Upper(GetPvProfString(cSecaoDB,"Contype","TCPIP",cInIfile ))
		cHasMapper:= Upper(GetPvProfString(cSecaoDB,"Mapper","ON",cInIfile ))
		cProtect  := GetPvProfString(cSecaoDB,"ProtheusOnly","0",cInIfile )
		nPort     := Val(GetPvProfString(cSecaoDB,"Port","0",cInIfile ))
		
		// Ajuste pelo Environment do Server (modelo TotvsDBAccess)
		cDataBase := GetSrvProfString("DBDataBase",cDataBase)
		cAlias	  := GetSrvProfString("DBAlias",cAlias)
		cServer	  := GetSrvProfString("DBServer",cServer)
		// Ajuste pelo Environment do Server(modelo TopConnect) 
		cDataBase := GetSrvProfString("TopDataBase",cDataBase)
		cAlias	  := GetSrvProfString("TopAlias",cAlias)
		cServer	  := GetSrvProfString("TopServer",cServer)
		
		cConType  := Upper(GetSrvProfString("TopContype",cConType))
		cHasMapper:= Upper(GetSrvProfString("TopMapper",cHasMapper))
		cProtect  := GetSrvProfString("TopProtheusOnly",cProtect)
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chave de conexao com BD DB2 informacao da Porta.       ³
		//³Abaixo da Versao 10 e utilizada a chave [TopPort]      ³
		//³Para utilizar na versao 11 foi modificada a chave para:³
		//³[DbPort]. Variavel "nPort"                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPort     := Val(GetSrvProfString("DbPort",StrZero(nPort,4,0)))   //Soh Para Conexao TCPIP
		
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
	FRT271COpenFile(aFiles[i], cDriver, cCnpj)
Next i

#ifdef TOP
	TcSetDummy(.F.)
#endif      

aRet := &cFuncao.(	uParm1	, uParm2	, uParm3	, uParm4	,; 
					uParm5	, uParm6	, uParm7	, uParm8	,; 
					uParm9	, uParm10	, uParm11	, uParm12	,; 
					uParm13	, uParm14	, uParm15	)

SET DELETED OFF

dbCloseAll()
#IFDEF TOP
	TCQUIT()
#ENDIF

Return aRet

Static Function FRT271COpenFile(cAlias, cDriver, cCnpj) 

Local cArquivo   
Local cArqInd 
Local lUsaSIX := File("SIX" + cEmpAnt + "0.dbf") .OR. File("SIX" + cEmpAnt + "0.dtc")
Local lUsaSIND:= File("SINDEX.DBF") .OR. ("SINDEX.DTC")
  
DEFAULT	cArqInd:= "SIX"
DEFAULT cCnpj  := "99.999.999/9999-99"  //Valida PAF-ECF 

If lUsaSIX
	cArqInd:= "SIX" 
ElseIf lUsaSIND
	cArqInd:= "SINDEX" 
EndIf

DbSelectArea(cArqInd)
DbSetOrder(1)
DbSeek(cAlias)

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
		If LjNfPafEcf(cCnpj) 	
			While !(cArqInd)->(EOF()) .AND. (cArqInd)->INDICE == cAlias
				DbSetIndex(cArquivo+(cArqInd)->ORDEM)
				(cArqInd)->(DbSkip())
			End
		Else
			DbSetIndex(cArquivo + "1")
			If cAlias == "SL1"
				DbSetIndex(cArquivo + "2")
			EndIf
			If cAlias == "SD2"
				DbSetIndex(cArquivo + "2")
				DbSetIndex(cArquivo + "3")
			EndIf		
		EndIf
	#endif
	DbSetOrder(1)
	If Empty(IndexKey())
		UserException(cAlias + " Open Index Failed")
	EndIf
Else
	UserException(cAlias + " Not Found in SX2")
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FR271CClie³ Autor ³ Vendas Clientes       ³ Data ³ 04/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastramento de Clientes diretamente no Check-Out         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271CCliente
Local i
Local nGravado
Local aSA1 := {}

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
	dbSkip()
End

If ExistBlock("FRTCPSA1")
	aCamposInc := ExecBlock("FRTCPSA1", .F., .F., aCamposInc)
EndIf

DbSelectArea("SA1")
nGravado := AXInclui("SA1", Recno(), 3, aCamposInc,,,"FR271CCliOk()")
If nGravado == 1
	If ExistBlock("FRTGRSA1")
		aSA1 := ExecBlock("FRTGRSA1", .F., .F., aSA1)
	EndIf
	// Grava o A1_SITUA local como "00" - Gravado com Sucesso
	AAdd(aSA1, {"A1_SITUA", "00"})
	FR271BGeraSL("SA1", aSA1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o SA1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSA1 := Array(FCount())
	For i := 1 To FCount()
		aSA1[i] := {FieldName(i), FieldGet(i)}
	Next i
	LJMsgRun(STR0017,, {|| FR271CProcSA1(aSA1)})	// "Aguarde. Atualizando o Cliente na Retaguarda..."
EndIf
Return(NIL)

Function FR271CProcSA1(aSA1)
// Se estiver conectado a Retaguarda
If FR271BStatSema("CON", cEstacao)
	// Se gravou na Retaguarda
	If FR271CMyCall("GeraA1", {"SA1"}, aSA1)[2] == "T"
		// Grava o A1_SITUA local com "TX" - Enviado
		aSA1 := {{"A1_SITUA", "TX"}}
		FR271BGeraSL("SA1", aSA1)
	Else
		// Informar ao FRTA020 que tem SA1 para ser gravado na Retaguarda
		FR271BGerSLI("    ", "SA1", Str(Recno(),17,0), "NOVO")
		// "Inclusão de Clientes" ### "Não foi possível atualizar este Cliente na Retaguarda. Ele será atualizado posteriormente."
		Aviso(STR0018, STR0019, {"Ok"})
	EndIf
Else
	// Informar ao FRTA020 que tem SA1 para ser gravado na Retaguarda
	FR271BGerSLI("    ", "SA1", Str(Recno(),17,0), "NOVO")
	// "Inclusão de Clientes" ### "Não foi possível atualizar este Cliente na Retaguarda. Ele será atualizado posteriormente."
	Aviso(STR0018, STR0019, {"Ok"})
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FR271CCliO³ Autor ³ Vendas Clientes       ³ Data ³ 04/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Cliente Via RPC na Retaguarda                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271CCliOk
Local lExistSA1 := .F.

If FR271BStatSema("CON", cEstacao)
	lExistSA1 := (FR271CMyCall("FR271CRPCCLOk", {"SA1"}, M->A1_COD+M->A1_LOJA)[2] == "T")
	If lExistSA1
		// "Inclusão de Clientes" ### "Este código de cliente já foi utilizado na Retaguarda. Por favor, informe um outro código válido."
		Aviso(STR0018, STR0020, {"Ok"})
	EndIf
Else
	// "Inclusão de Clientes" ### "Não é possível validar este código de cliente, pois não há conexão com a Retaguarda. Este código será validado posteriormente."
	Aviso(STR0018, STR0021, {"Ok"})
EndIf
Return(!lExistSA1)

Function FR271CRPCCLOk(cChave)
If SA1->(DbSeek(xFilial()+cChave))
	Return({"OK", "T"})
EndIf

Return({"OK", "F"})
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FR271CPGlo³ Autor ³ Vendas Clientes       ³ Data ³ 20/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica o cupom a ser deletado pertence a uma factura     ³±±
±±³          ³ global.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271CPGlobal(cNumNota, cSerNota, cCliente, cLoja)  

Local cMsg    	 := ""							// Mensagem de retorno
Local lRet    	 := ""							// Retorno da funcao
Local cNfOri  	 := ""					   		// NfOrigem
Local cSerOri 	 := ""							// Serie Origem
Local aRet            							// Array com retorno
Local nTamF2_DOC := Len(cNumNota)     			// Tamanho do campo F2_DOC
Local cFilE1     := SE1->(xFilial("SE1"))       // Armazena a filial utilizada na SE1
Local lUtzNCC    := .F.                         // Verifica se utilizou NCC como pagamento

cNumNota := PadR(cNumNota,nTamF2_DOC)                                 

DbSelectArea("SF2")
DbSetOrder(1)
If DbSeek(xFilial("SF2")+cNumNota+cSerNota)
	If Empty(SF2->F2_NFORI)
		cMsg := "OK"
		lRet := .T.
	Else
		cNfOri := SF2->F2_NFORI
		cSerOri:= SF2->F2_SERIORI
		DbSeek(xFilial("SF2")+cNfOri+cSerOri)
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
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o campo NFCUPOM estah preenchido  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMsg == "OK"
		If DbSeek( xFilial( "SF2" ) + cNumNota + cSerNota )
			If SF2->(FieldPos("F2_NFCUPOM")) > 0
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
    EndIf
Else
	cMsg := "OK"
	lRet := .T.	
EndIf

// Verifica se no pagamento foi utilizado NCC 
If lRet
	DbSelectArea("SL1")
	DbSetOrder(2) 
	If DbSeek( xFilial("SL1")+ cSerNota + cNumNota ) .AND. SL1->L1_CREDITO > 0 
		lUtzNCC := .T.
	EndIf 
EndIf	
	 
// Verifica se ja foi realizada a baixa do titulo
If lRet
	DbSelectArea("SE1")
	DbSetOrder(1)
  	If DbSeek( xFilial("SE1")+ cSerNota + cNumNota ) 
		While !Eof() .AND. SE1->E1_FILIAL == cFilE1 .AND. SE1->E1_PREFIXO == cSerNota .AND.;
			SE1->E1_NUM == cNumNota .AND. lRet
			If IsMoney(SE1->E1_TIPO)
				DbSkip()
				Loop
			EndIf
			If Round(NoRound(SE1->E1_VALOR,3),2) <> Round(NoRound(SE1->E1_SALDO,3),2)
				If !(lUtzNCC .AND. Alltrim(SE1->E1_TIPO) == "CR")
					cMsg := "BAIXADO"
					lRet := .F.
				EndIf	
			EndIf	
			SE1->(DbSkip())
		End	
	Else 
		cMsg := "OK"
		lRet := .T.	
	EndIf	
EndIf	

aRet := {cMsg,lRet}

Return(aRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271COrcs³ Autor ³ Vendas Clientes       ³ Data ³24/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisar os Orcamento(s) para serem mostrados para o      ³±±
±±³          ³ usuario selecionar. Somente para Touch Screen              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FR271COrcsTo(cNumOrc,cSegPar)
Local cNumero 	:= ""
Local cCliente	:= ""
Local cOrc		:= ""
Local aRet
Local lRet      := .T.
Local oGrid
Local aHeader   := { "Código", "Nome" }
Local aSizes    := { 10, 160 }
Local aData     := { }
Local aRetItems := { }
Local aRetData  := { }

If Empty(cNumOrc)
	// "Pesquisar os Orçamentos em aberto poderá levar alguns segundos."+Chr(13)+;
	// "Caso você já saiba o Número do Orçamento, digite-o e clique em Ok. Prosseguir com a pesquisa?"+Chr(13)+;
	// "Prosseguir com a pesquisa?", "Pesquisar Orçamentos em Aberto"
	If !MsgYesNo(STR0009+Chr(13)+STR0010+Chr(13)+STR0011, STR0012)
		Return(.F.)
	EndIf
EndIf

LJMsgRun(STR0013,,{|| aRet := FR271CMyCall("FR271CRPCOrc", {"SL1"}, cSegPar)})	// "Aguarde. Pesquisando os orçamentos em aberto..."
cOrc := aRet[2]
If Empty(cOrc)
	// "Não foi encontrado nenhum Orçamento em aberto para ser carregado!", "Atenção"
	MsgStop(STR0015, STR0002)
ElseIf Left(cOrc,4)=="ERRO"
	// "Erro ao pesquisar os Orçamentos em aberto. Tente novamente.", "Atenção"
	MsgStop(STR0016, STR0002)
Else
	aArray := {}												// Carrega os Orcamentos
	// Procurando pelos Orcamentos
	SA1->(DbSetOrder(1))
	While !Empty(cOrc)
		cNumero  := Left(cOrc, Len(SL1->L1_NUM))
		cOrc     := Substr(cOrc, Len(SL1->L1_NUM)+1)
		cCliente := Left(cOrc, Len(SL1->L1_CLIENTE))
		SA1->(DbSeek(xFilial("SA1")+cCliente))
		cOrc     := Substr(cOrc, Len(SL1->L1_CLIENTE)+1)
		If Empty(cNumOrc)
			AAdd(aData, {cNumero, SA1->A1_NOME})
		Else
			If cNumero == cNumOrc
				AAdd(aData, {cNumero, SA1->A1_NOME})
			EndIf
		EndIf
	End
EndIf
// Não encontrou nada
If Empty(aData)
	Aviso("Aviso","Nao existem Orçamentos a serem apresentados, verifique !",{"OK"})
Else
	//                          y1   x1   h    w                                                    
	oGrid := TchGridObj():New( nil, nil, 300, 500, "Touch Grid Object", "Escolha o Orçamento", nil, aHeader, aSizes, aData, .F. , nil, nil  )
	
	If oGrid:Activate()
	
		aRetItems := oGrid:GetSelItems()
		aRetData  := oGrid:GetSelData()
		
	EndIf
	
EndIf

Return aRetData

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³FR271CPrin³ Autor ³ Vendas Clientes       ³ Data ³ 15/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Leitura X                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271CPrintLeitX()
Local lConsulta    := .T.
Local lMenFisOnLog := IsInCallStack("LjMenFiLog") //Valida se foi chamado Menu Fiscal da Tela de Login
Local oHora
Local cHora := ""
Local oDoc
Local cDoc  := ""

If lMenFisOnLog .OR. LjProfile( 21 )
	IFLeituraX(nHdlECF)	
	FR271Hora(.T., lConsulta, @oHora, @cHora, @oDoc, @cDoc)								// Atualiza a Hora e o Numero do Cupom
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FRT271CRed³ Autor ³ Vendas Clientes       ³ Data ³ 09/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Reducao Z                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRT271CRedZPrint()
Local lConsulta    := .T.
Local oHora
Local cHora := ""
Local oDoc
Local cDoc  := ""

If LjProfile( 6 )
	IFReducaoZ(nHdlECF,"")
	FR271Hora(.T., lConsulta, @oHora, @cHora, @oDoc, @cDoc)								// Atualiza a Hora e o Numero do Cupom
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FR271CVldImp³ Autor ³ Vendas CRM            ³ Data ³ 06/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se o arquivo referente ao orcamento importado ja existe³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFRT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271CVldImp(cNumOrc, lValidRet, cPdv)	   
Local lRet      := .T.                            //Retorno da funcao. Se .T. nao foi importado ainda
Local cPatchOrc := ""                             //Arquivo do orcamento importado 
Local cArqTemp  := LOG_IMP + "TEMP.TMP"           //Arquivo para testar se existe a pasta "\AUTOCOM\IMP" + cEmpAnt + cFilAnt
Local nHandle                                     //Handle do arquivo
Local cExt      := ".TXT"                         //Extensao do arquivo importado
Local cArqPdv   := ""

DEFAULT lValidRet := .F. //Validar arquivo .RET na Retaguarda
Default cPdv      := ""

cExt := IIF(lValidRet, ".RET", ".TXT")

If !File( cArqTemp )
	MakeDir( "\AUTOCOM" )
	MakeDir( "\AUTOCOM\IMP" + cEmpAnt + cFilAnt )
	nHandle := FCreate( cArqTemp )
	FClose( nHandle )	
Endif
cPatchOrc := LOG_IMP + cNumOrc + cExt  //Arquivo do orcamento importado 

If File( cPatchOrc )
	If !Empty(cPdv)
		FT_FUSE( cPatchOrc ) // abro o arquivo
		FT_FGOTOP()           
		cArqPdv := FT_FREADLN() //Leitura da linha
		FT_FUSE()  // fecha o arquivo
		If AllTrim(cArqPdv) == AllTrim(cPdv)
			lRet := .T.
		Else
			lRet := .F.
		EndIf
    Else
    	lRet  := .F.
    EndIf	
EndIf	

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRetOrDAVºAutor  ³Vendas CRM          º Data ³  22/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o numero do orcamento a partir do numero do Documen-º±±
±±º          ³to auxiliar de venda (DAV).                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Numero do DAV                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA271C                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRetOrDAV(cNumDAV)
Local cNumOrc 	:= ""
Local aArea		:= GetArea()
Local aAreaSL1	:= SL1->(GetArea())
Local lPreVenda	:= SuperGetMv("MV_LJPRVEN",,.T.)
Local cTipoVen	:= ""

If lPreVenda
	cTipoVen	:= "P"
Else
	cTipoVen	:= "D"
EndIf

DbSelectArea("SL1")
DbSetOrder(13)//L1_FILIAL+L1_TPORC+L1_NUMORC

If DbSeek(xFilial("SL1")+cTipoVen+cNumDAV)
	cNumOrc := SL1->L1_NUM
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return cNumOrc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271CCan ³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega um orcamento aberto na retaguarda para finalizacao ³±±
±±³          ³ no FrontLoja. E solicitado que digite o Numero do Orcamento³±±
±±³          ³ ou pesquise os abertos. Esta solicitacao sera recebida e   ³±±
±±³          ³ processada pelo FRTA020 (Atraves do SLI Tipo "FV ") e      ³±±
±±³          ³ gravada no arquivo "LOADORC.FRT" para a sua leitura.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT(Rotina foi substituida pela LjCancOrc(Loja160)     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271CCanDav(	oTimer		, cCodProd		, cHora			, oDoc			,;
						cDoc		, oPDV			, cPDV			, nLastTotal	,;
						nVlrTotal	, nLastItem	 	, nTotItens	 	, nVlrBruto 	,;
						oVlrTotal	, oCupom		, oTotItens 	, oOnOffLine	,; 
						nTmpQuant	, nVlrItem 		, nValIPIIT		, nValIPI		,;
						oFotoProd	, oProduto		, oQuant		, oVlrUnit		,; 
						oVlrItem	, oDesconto		, cSimbCor		, cOrcam 		,; 
						cProduto	, nQuant 		, cUnidade		, nVlrUnit 		,;
						oUnidade 	, lF7			, oHora			, lOcioso		,;
						lRecebe		, lLocked		, lCXAberto		, lDescIT		,;
						nVlrDescTot	, aItens		, aICMS			, nVlrMerc		,;
						_aMult		, _aMultCanc	, lOrc			, aParcOrc 		,;
						cItemCOrc	, aParcOrcOld	, lAltVend		, lImpNewIT		,;
						lFechaCup	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd		, aTEFPend		, aBckTEFMult	, cCodConv		,; 
						cLojConv	, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal	, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
						nVidaLink	, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,; 
						nValTCof	, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
						nTotDedIcms	, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,; 
						nVlrAcreTot	, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,; 
						nNumParcs	, aMoeda		, aSimbs		, nMoedaCor		,; 
						nDecimais	, aImpsSL1		, aImpsSL2		, aImpsProd		,; 
						aImpVarDup	, aTotVen		, aCols			, nVlrPercIT	,;
						cEstacao	, lTouch		, cVendLoja		, aParcOrcOld	,;
						oMensagem	, oFntMoeda		, cMensagem		, cEntrega		,;
						aReserva	, lReserva		, lAbreCup		, nValor		,;
						cCliente	, cLojaCli		, cCupom		, cTipoCli		,;
						lDescITReg	, cNumDAV		, oDlg			, oTemp3        ,;						
						oTemp4		, oTemp5		, nTaxaMoeda	, oTaxaMoeda 	,; 
  						cMoeda		, oMoedaCor		, nVlrFSD		, cUsrSessionID ,;
  						aHeader		, aDadosJur		, aCProva 		, nTotalAcrs	,; 
  						oFntGet		, cMensagem		);
				
Local aArray
Local oNumOrc
Local lUsaDAV  	:= (SL1->(FieldPos("L1_NUMORC")) > 0)
Local nTamDoc	:= TamSX3("L1_NUM")[1]
Local nTamDAV	:= If(lUsaDAV,TamSX3("L1_NUMORC")[1],0)
Local cNumOrc  	:= Space(nTamDoc)
Local aKey
Local lPreVend	:= SuperGetMv("MV_LJPRVEN",,.T.)
Local aRegTEF		:= {}
Local lRecarEfet	:= .F.
Local nx 

DEFAULT cTipoCli 		:= ""						// Tipo do Cliente 
DEFAULT cNumDAV 		:= Space(nTamDAV)			// Documento auxiliar de venda

DEFAULT nVlrTotal	    := 0
DEFAULT nLastItem	 	:= 0
DEFAULT nTotItens	 	:= 0
DEFAULT nVlrBruto 		:= 0
DEFAULT nTmpQuant		:= 0
DEFAULT nVlrItem 		:= 0
DEFAULT nValIPIIT		:= 0
DEFAULT nValIPI			:= 0
DEFAULT cSimbCor		:= 0
DEFAULT nQuant			:= 0
DEFAULT cUnidade		:= 0
DEFAULT nVlrUnit		:= 0
DEFAULT nValTPis		:= 0
DEFAULT nValTCof		:= 0
DEFAULT nValTCsl		:= 0
DEFAULT nTotDedIcms		:= 0
DEFAULT nVlrPercTot		:= 0
DEFAULT nVlrPercAcr		:= 0
DEFAULT nVlrAcreTot		:= 0
DEFAULT nVlrDescCPg		:= 0
DEFAULT nVlrPercOri		:= 0
DEFAULT nQtdeItOri		:= 0
DEFAULT nNumParcs		:= 0
DEFAULT nValor			:= 0
DEFAULT cMensagem		:= ""

//Essa rotina era chamada pela function FR271FReducao(FRTA271F) para cancelamento de Pré Venda, foi substituida pela function LjCancOrc(Loja160)
If lPreVend 

	If Len(cNumDav) == 0
		cNumDav := Space(nTamDAV)
	EndIf
	
	aICMS := LJSetAliq()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	
	If FR271CPesqOrc(	, @aArray, , @cNumOrc, "LOJA160")
		For nx := 1 To Len(aArray)
		    conout("Entrou no for")
			cNumOrc := aArray[nx, 2]
			cNumDAV := Space(nTamDAV)			// Documento auxiliar de venda
			nValor	:= 0  
			lAbreCup:= .F.	//A variável tem que estar .F. para que abra o cupom relativo a pré-venda, anteriormente só abria o primeiro cupom para cancelar
				
			FR271HCarrega(	@oDlg			, @cNumOrc		, @cCodProd		, @oTimer		,;
							@oHora			, @cHora		, @oDoc			, @cDoc			,; 			
							@oPDV			, @cPDV			, @nLastTotal	, @nVlrTotal	,; 	
							@nLastItem		, @nTotItens	, @nVlrBruto	, @oVlrTotal	,; 	
							@oCupom			, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;		
							@nVlrItem		, @nValIPIIT	, @nValIPI		, @oFotoProd	,;		
							@oProduto		, @oQuant		, @oVlrUnit		, @oVlrItem		,;		
							@oDesconto		, @cSimbCor		, @cOrcam		, @cProduto		,;		
							@nQuant			, @cUnidade		, @nVlrUnit		, @oUnidade 	,;
							@lF7			, @lOcioso		, @lRecebe		, @lLocked		,;
							@lCXAberto		, @lDescIT		, @nVlrDescTot	, @aItens		,;
							@aICMS			, @nVlrMerc		, @_aMult		, @_aMultCanc	,;
							@lOrc			, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
							@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	,; 
							@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		,; 
							@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	,; 
							@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		,;
							@aVidaLinkD		, @aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	,; 
							@cCdDescOrc		, @nValTPis		, @nValTCof		, @nValTCsl		,;
							@lOrigOrcam		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
							@nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
							@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aMoeda		,; 
							@aSimbs			, @nMoedaCor	, @nDecimais	, @aImpsSL1		,; 
							@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
							@aCols			, @nVlrPercIT	, @cVendLoja	, @aParcOrcOld	,;
							@oMensagem		, oFntMoeda		, @cMensagem	, @cEntrega		,;
							@aReserva		, @lReserva		, @lAbreCup		, @oNumOrc		,;
							@nValor			, @cCliente		, @cLojaCli	    , /*cNumOrig*/	,;
							@cCupom			, @cTipoCli		, @lDescITReg	, @cNumDAV, "LOJA160")
		
			FR271CMyCall( "FR271CSTORC", { "SL1"} , aArray[nx, 2])
				
			FR271FCancCup(	.F.				, @oHora		, @cHora		, @oDoc			,;
							@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,;
							@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,;
							@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,;
							@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3  		,;
							@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,;
							@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,;
							@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
							@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
							@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,;
							@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,;
							@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,;
							@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
							@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
							@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
							@aVidaLinkD		, @aVidaLinkc	, @nVidaLink	, @lVerTEFPend	,;
							@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;
							@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,;
							@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,;
							@nTotalAcrs		, @aCols		, @aHeader		, @aDadosJur	,;
							@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,;
							Nil				, Nil			, Nil			, Nil			,;
							Nil				, @aRegTEF		, @lRecarEfet	, "LOJA160"		,;
							Nil				, @cMensagem)
			FRTSetKey(aKey)
		
		Next nx
	EndIf	

EndIf	

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271CRPCCAN  ³ Autor ³ Vendas Clientes       ³ Data ³29/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega um orcamento aberto na retaguarda para finalizacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271CSTORC(cNumOrc)

Default cNumOrc := Space(TamSX3("L1_NUM")[1])

DbSelectArea("SL1")
SL1->(DbSetOrder(1))

If SL1->(DbSeek(xFilial()+cNumOrc))
	If SL1->(ColumnPos("L1_STORC")) > 0
		// Altera regiro para cancelado
		RecLock("SL1", .F.)  
 		REPLACE SL1->L1_STORC WITH "C"
		SL1->(MsUnlock())
	EndIf
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271GetRpc³ Autor ³ Vendas Clientes       ³ Data ³19/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recupera objeto "oServer" com as informacoes da conecxao RPC.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³                                                             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271GetRpc()
Return oRPCServer