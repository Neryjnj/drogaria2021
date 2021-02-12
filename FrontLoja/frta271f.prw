#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA271F.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FRTDEF.CH"

#DEFINE	 FRT_SEPARATOR		"---------------------------------------"

// Indices do Array aItens - Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
#DEFINE AIT_ITEM				1
#DEFINE AIT_COD			    	2
#DEFINE AIT_CODBAR				3
#DEFINE AIT_DESCRI				4
#DEFINE AIT_QUANT				5
#DEFINE AIT_VRUNIT				6
#DEFINE AIT_VLRITEM				7
#DEFINE AIT_VALDESC		   		8
#DEFINE AIT_ALIQUOTA			9
#DEFINE AIT_VALIPI				10
#DEFINE AIT_CANCELADO			11
#DEFINE AIT_VALSOL   			12
#DEFINE AIT_DEDICMS   			13          // Deducao de ICMS
#DEFINE AIT_ITIMP   			14          		// Numero do item na Impressora
#DEFINE AIT_PBM		   			15          		// Define se o produto e PBM
#DEFINE AIT_IMPINCL             16                  // Verifica se o imposto esta incluido no valor do item

#DEFINE _FORMATEF				"CC;CD"     // Formas de pagamento que utilizam operação TEF para validação
#DEFINE CRLF                   Chr(13)+Chr(10)  //Pula linha

//DIFINES criados pelo equipe de Templates Usado no Template de Drogaria.
#DEFINE VDLNK_CABEC_CODCLI	 1
#DEFINE VDLNK_CABEC_LOJA	 2
#DEFINE VDLNK_INDICEPRODU	 1
#DEFINE VDLNK_CODIGOEAN  	 2
#DEFINE VDLNK_QUANTIDADE 	 3
#DEFINE VDLNK_PRECO      	 4
#DEFINE VDLNK_AUTORIZACAO    1
#DEFINE VDLNK_DETALHE    	 2
#DEFINE VDLNK_TOTALVENDA   	 3

Static lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .AND. RGVldTable()		//Validacao da Nova Regra de Desconto Ativa
Static lEmitNFCe	:= LjEmitNFCe()				//Indica a utilizacao da NFC-e
Static lMFE			:= IIF( ExistFunc("LjUsaMfe"), LjUsaMfe(), .F. )			//Se utiliza MFE

/*Release 11.5 - Cartao Fidelidade*/
Static cNumCFid := ""				//Numero do cartao fidelidade utilizado como forma de pagamento da venda.
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado

//-------------------------------------------------------------------
/*/{Protheus.doc} FR271FAltVend
Alteração do Vendedor (F11)
@author  VendasCrm
@since   07/11/2000
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function FR271FAltVend(	cVendLoja	, lOcioso	, lRecebe	, lCXAberto,;
				   		lAltVend	, aItens	, cVndLjAlt	)
DEFAULT cVndLjAlt	:= ""

If lRecebe
	Return(NIL)
EndIf

If lCxAberto

    //Verifica se ja foram registrados itens na venda, mesmo que estejam cancelados nao permite alterar o vendedor
	If lOcioso .AND. LEN(aItens) == 0

		//Chama a tela de troca do vendedor
		Frtx272T10(@cVendLoja, @lAltVend, @cVndLjAlt)

	Else
		HELP(' ',1,'FRT030')	// "Não é possível alterar o Vendedor durante a venda.", "Atenção"
	EndIf
Else
	HELP(' ',1,'FRT031')	// "O Caixa não está aberto. Não será possível alterar o Vendedor.", "Atenção"
EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FR271FFuncoes
Execucao de Funcoes (F12)
@author  VendasCrm
@since   19/07/2000
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FR271FFuncoes(oHora		 	, cHora			, oDoc			, cDoc			,;
						oCupom		 	, cCupom		, nLastTotal	, nVlrTotal		,;
						nLastItem	 	, nTotItens		, nVlrBruto		, oDesconto		,;
						oTotItens	 	, oVlrTotal		, oFotoProd		, nMoedaCor		,;
						cSimbCor	 	, oTemp3		, oTemp4		, oTemp5		,;
						nTaxaMoeda	 	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;
						oMoedaCor	 	, nVlrPercIT	, cCodProd		, cProduto		,;
						nTmpQuant	 	, nQuant		, cUnidade		, nVlrUnit		,;
						nVlrItem		, oProduto		, oQuant		, oUnidade		,;
						oVlrUnit	 	, oVlrItem		, lF7			, oPgtos		,;
						oPgtosSint	 	, aPgtos		, aPgtosSint	, cOrcam		,;
						cPDV		 	, lTefPendCS 	, aTefBKPCS		, oDlgFrt		,;
						cCliente	 	, cLojaCli		, cVendLoja		, lOcioso		,;
						lRecebe		 	, lLocked		, lCXAberto		, aTefDados		,;
						dDataCN		 	, nVlrFSD		, lDescIT		, nVlrDescTot	,;
						nValIPI		 	, aItens 		, nVlrMerc		, lEsc			,;
						aParcOrc	 	, cItemCOrc		, aParcOrcOld	, aKeyFimVenda	,;
						lAltVend	 	, lImpNewIT		, lFechaCup		, aTpAdmsTmp	,;
						cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
						cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,;
						nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,;
						nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
						nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,;
						nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
						nNumParcs		, aMoeda		, aSimbs		, cRecCart		,;
						cRecCPF			, cRecCont		, aImpsSL1		, aImpsSL2		,;
						aImpsProd		, aImpVarDup	, aTotVen		, nTotalAcrs	,;
						lRecalImp		, aCols			, aHeader 		, aDadosJur		,;
						aCProva			, aFormCtrl		, nTroco		, nTroco2 		,;
						lDescCond		, nDesconto		, aDadosCH		, lDiaFixo		,;
						aTefMult		, aTitulo		, lConfLJRec	, aTitImp		,;
						aParcelas		, oCodProd		, cItemCond		, lCondNegF5	,;
						nTxJuros		, nValorBase	, oMensagem		, oFntGet		,;
						cTipoCli		, lAbreCup		, lReserva		, aReserva      ,;
						oTimer			, lResume		, nValor 		, aRegTEF		,;
						lRecarEfet		, oOnOffLine	, nValIPIIT		, _aMult		,;
						_aMultCanc		, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
						oPDV			, aICMS			, lDescITReg	, cMensagem		,;
						cDocFo			, aMostruario	)

Local nI
Local aFuncoes
Local nLen
Local nOldLen		:= 0
Local cOldcCupom	:= cCupom
Local cRet			:= Space(200)
Local aKey
Local uRet
Local lRet	 		:= .F.
Local cFuncao		:= "  "
Local nNumLinesCup 	:= 0
Local lFRTFUNCOESt := ExistTemplate("FRTFUNCOES")// verifica se existe o PONTO DE ENTRADA FRTFUNCOES
Local nDecimais := 0
Local cNumDav   := ""
Local lTouch    := .F.
Local cMsgCupom := ""
Local cEntrega  := ""
Local lExibeMsg     := .T.                                              // Exibe ou nao a mensagem de permissao do usuario.
Local lFuncF12      := .T.                                              // Se foi acionado pelas funcoes do Front Loja (F12)
//Verifica se a funcionalidade Lista de Presente esta ativa e aplicada
Local lUsaLstPre	:= .T.	//SuperGetMV("MV_LJLSPRE",,.F.) .And. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)
//Verifica se a estacao possui Display
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
// Template de Drogaria
Local aParamVL		:= {} // Utilizado para vendas PBM Vidalink - array com objetos da venda
Local lUseSAT		:= LjUseSat()
Local lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC)

DEFAULT lF7 		:= .F.
DEFAULT cTipoCli	:= ""
DEFAULT lAbreCup	:= .F.
DEFAULT lReserva	:= .F.
DEFAULT aReserva	:= {}
DEFAULT nValor		:= 0
DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.
DEFAULT cMensagem 	:= ""
DEFAULT cDocFo		:= ""	//Release 11.5 - Controle de Formulario - Numero do documento informado pelo usuario no inicio da venda - controle de formularios
DEFAULT aMostruario := {"",""}

// Numero / Nome / Execucao / Retorno
aFuncoes := {}

If lEmitnfce .And. ExistFunc("Fr271aVlDt") .And. !Fr271aVlDt() 
	MsgAlert(STR0162 + CRLF + STR0163)  // "A Data do dia é diferente da data do movimento" ... "Favor inicializar o sistema para atualizar com data atual."	
	Return NIL
EndIf

If !CheckCaixa(@lCXAberto, @lUsaDisplay , Nil , lFuncF12 )	// Verifica se o Caixa Esta Aberto
	If !lLjNfPafEcf								// Caso o caixa nao esteja aberto e seja PAF ECF permite acesso apenas ao menu fiscal.
		Return NIL											// E exibe Mensagem Caso Esteja Fechado.
	Else
		AAdd(aFuncoes,{"22", STR0085,"STBMenFis(.T.,.F.,.T.)", {|x| .F.}}) // "Menu Fiscal
		bCmd := &('{ |nHdlECF, cRet| ' + aFuncoes[Len(aFuncoes)][3] + ' }')
		uRet := Eval( bCmd, nHdlECF, @cRet )					   // Execucao
		lRet := Eval( aFuncoes[Len(aFuncoes)][4], uRet )		   // Retorno
		Return lRet
	EndIf
EndIf

If lLjNfPafEcf
	lExibeMsg := .F.
Else
	lExibeMsg := .T.
EndIf

// Validacao de permissao do caixa para as Funcoes FrontLoja
If LJProfile(12 , NIL, NIL, NIL,;
			 NIL, lExibeMsg, NIL)

	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C" + STR0047 )      	//"FUNCOES FRONT LOJA"
		DisplayEnv(StatDisplay(), "2C" + STR0129 )		// "Utilize o Monitor para Funcoes"
	EndIf

	
	// SetKey's do Fechamento da Venda	
	aKey := FRTSetKey()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PORTUGAL - Nao Utilizara ECF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LjNfPtgNEcf(SM0->M0_CGC) .And. !lEmitNFCe
		aadd(aFuncoes,{"01", STR0006,"If(lOcioso,IFAbrECF(nHdlECF),)",                      {|x| .F.}})	// "Abrir ECF"
		aadd(aFuncoes,{"02", STR0007,"If(lOcioso .AND. LJProfile(6),(FR271FReducao(  @oTimer		, @cCodProd		, @cHora		, @oDoc			,"+;
																					" @cDoc			, @oPDV			, @cPDV			, @nLastTotal	,"+;
																					" @nVlrTotal	, @nLastItem	, @nTotItens	, @nVlrBruto 	,"+;
																					" @oVlrTotal	, @oCupom		, @oTotItens 	, @oOnOffLine	,"+;
																					" @nTmpQuant	, @nVlrItem 	, @nValIPIIT	, @nValIPI		,"+;
																					" @oFotoProd	, @oProduto		, @oQuant		, @oVlrUnit		,"+;
																					" @oVlrItem		, @oDesconto	, @cSimbCor		, @cOrcam 		,"+;
																					" @cProduto		, @nQuant 		, @cUnidade		, @nVlrUnit 	,"+;
																					" @oUnidade 	, @lF7			, @oHora		, @lOcioso		,"+;
																					" @lRecebe		, @lLocked		, @lCXAberto	, @lDescIT		,"+;
																					" @nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,"+;
																					" @_aMult		, @_aMultCanc	, @lLocked		, @aParcOrc		,"+;
																					" @cItemCOrc	, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,"+;
																					" @lFechaCup	, @cContrato	, @aCrdCliente	, @aContratos	,"+;
																					" @aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,"+;
																					" @cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,"+;
																					" @lDescTotal	, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,"+;
																					" @nVidaLink	, @cCdPgtoOrc	, @cCdDescOrc	, @nValTPis		,"+;
																					" @nValTCof		, @nValTCsl		, @lOrigOrcam	, @lVerTEFPend	,"+;
																					" @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,"+;
																					" @nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	,"+;
																					" @nNumParcs	, @aMoeda		, @aSimbs		, @nMoedaCor	,"+;
																					" @nDecimais	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,"+;
																					" @aImpVarDup	, @aTotVen		, @aCols		, @nVlrPercIT	,"+;
																					" @cEstacao		, @lTouch		, @cVendLoja	, @aParcOrcOld	,"+;
																					" @oMensagem	, oFntMoeda		, @cMsgCupom	, @cEntrega		,"+;
																					" @aReserva		, @lReserva		, @lAbreCup		, @nValor		,"+;
																					" @cCliente		, @cLojaCli		, @cCupom		, @cTipoCli		,"+;
																					" @lDescITReg	, @cNumDav		, oDlgFrt		, @oTemp3		,"+;
																					" @oTemp4		, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda 	,"+;
		                                                                            " @cMoeda		, @oMoedaCor	, @nVlrFSD		, @cUsrSessionID,"+;
		                                                                            " @aHeader		, @aDadosJur	, @aCProva 		, @nTotalAcrs	,"+;
	  							                                                    " @oFntGet ),0),999)",	{|x| (x==999).OR.(x==0)}})	// "Fechar ECF (Redução Z)"
	EndIf


	aadd(aFuncoes,{"03", STR0008,"FR271FCancCup(	.F.				, @oHora		, @cHora		, @oDoc			,"+;
												"	@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,"+;
												"	@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens	,"+;
												"	@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal	,"+;
												"	@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3		,"+;
												"	@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,"+;
												"	@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd		,"+;
												"	@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,"+;
												"	@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,"+;
												"	@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,"+;
												"	@cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,"+;
												"	@nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,"+;
												"   @cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,"+;
												"	@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,"+;
												"	@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,"+;
												"   @aVidaLinkD		, @aVidaLinkc	, @nVidaLink	, @lVerTEFPend	,"+;
												" 	@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,"+;
												"	@nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,"+;
												"	@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,"+;
												"	@nTotalAcrs		, @aCols		, @aHeader		, @aDadosJur	,"+;
												"	@aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,"+;
												"	@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva		,"+;
												"   @nValor			, @aRegTEF		, @lRecarEfet	, Nil			,"+;
												"	@lRecalImp 		, @cMensagem	, @cDocFo		, @oDlgFrt 		,"+;
												"   @lTefPendCS 	, @aTefBKPCS 	, Nil           , @lResume	    )",;												
																						{|	a	, b		, c		, d	,;
																							e	, f		, g		, h	,;
																							i	, j		, k		, l ,;
																							m	, n		, o		, p	,;
																							q	, r		, s		, t	,;
																							u	, w		, y		, x	,;
																							z	, aa	, ab	, ac,;
																							ad	, ae	, af	, ag,;
																							ah	, ai	, aj	, ak,;
																							al 	, am	, an	, ao,;
																							ap	, aq	, ar	, ay,;
																							at	, au	, aw	, ay,;
																							ax	, az	, ba	, bb,;
																							bc	, bd	, be	, bf,;
																							bg	, bh	, bi	, bj,;
																							bk	, bl 	, bm	, bn,;
																							bo	, bp	, bq	, br,;
																							bs	, bt	, bu	, bw,;
																							by	, bx	, bz	, ca,;
																							cb	, cc	, cd	, ce,;
																							cf	, cg	, ch	, ci,;
																							cj  , ck	, cl	, cm,;
																							cn	, co	, cp	, cq,;
																							cr	, cs	, ct	, cu,;
																							cw	, cy	, cx	, cz ;
																							|  x }})	// "Cancelar Cupom"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PORTUGAL - Nao Utilizara ECF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LjNfPtgNEcf(SM0->M0_CGC) .OR. cPaisLoc $ "COL|CHI"
		If  !(cPaisLoc $ "COL|CHI") .And. !lEmitNFCe
			aadd(aFuncoes,{"--", "",     "",                                                    {|x| .F.}})
			aadd(aFuncoes,{"04", STR0009,"If(lOcioso .AND. LjProfile(21,Nil,Nil,Nil,Nil,.T.),(IFLeituraX(nHdlECF),FR271Hora(.T., Nil, oHora, cHora, oDoc, cDoc)),)",;
			     										{|a	, b	, c	, d	, e	, f| .F.}})	// "Leitura X"
		EndIf

		aadd(aFuncoes,{"05", If(cPaisLoc $ "POR|EUA",STR0022,STR0010),"Fr271D050(1)",  	{|x| .F.}}) // "Sangria"
		aadd(aFuncoes,{"06", STR0011,"Fr271D050(2)",                                       	{|x| .F.}}) // "Entrada de Troco"
	EndIf

	aadd(aFuncoes,{"--", "",     "",                                                  	{|x| .F.}})
	aadd(aFuncoes,{"07", STR0023,"LJ060VIS('SBI',0,2)", 							   	{|x| .F.}})	// "Consulta de Produto"

	If SL2->(ColumnPos("L2_VDMOST")) > 0
		aadd(aFuncoes,{"25", STR0094,"FR271Mostruario(@aMostruario)",   				   	{|x| .F.}})	// "Produto Mostruario/Saldão"
	EndIf

	If lUsaTef
		aadd(aFuncoes,{"--", "",     "",                       	{|x| .F.}})
		If cTipTef == TEF_CLISITEF
			aadd(aFuncoes,{"09",STR0039,"LJRotTEF()",          	{|x| .F.}})  	 //"TEF - Gerenciais"
		ElseIf cTipTef == TEF_CENTROPAG  .AND. cPaisLoc == "MEX"
			aadd(aFuncoes,{"11",STR0026,"Loj854Cam()",          	{|x| .F.}})  	//"Cancela Tr. TEF"
			aadd(aFuncoes,{"30",STR0040,"Loj854Ree()",          	{|x| .F.}})  	//"Reimpressão TEF (Visa)"
		Else
			aadd(aFuncoes,{"08",STR0024,"LOJA012T()",          	{|x| .F.}})  	 //"Consulta TEF"
			aadd(aFuncoes,{"09",STR0025,"LOJA019T()",          	{|x| .F.}})  	 //"Funções ADM"
			aadd(aFuncoes,{"11",STR0026,"LOJA011T()",          	{|x| .F.}})  	 //"Cancela Tr. TEF"
			aadd(aFuncoes,{"30",STR0040,"LOJA024T()",          	{|x| .F.}})  	 //"Reimpressão TEF (Visa)"
			aadd(aFuncoes,{"31",STR0041,"LOJA013S()",          	{|x| .F.}})  	 //"Reimpressão TEF (Outros)"

		EndIf
		aadd(aFuncoes,{"--", "",     "",                       	{|x| .F.}})
	EndIf

	If (nVlrTotal > 0) .AND. (AliasIndic("MDV")) .AND. (AliasIndic("MDX"))
		AAdd(aFuncoes,{"10", STR0086,"FRTA800( 	 @nValor		,@lUsaTef		,@aMoeda		,					"+;
																	"@lRecebe		,													"+;
												 					"@nTXJuros		,													"+;
												 					"@aPgtos       	,													"+;
												 					"@cDoc			,@oCupom		,@cCupom		,@nVlrTotal		,	"+;
																	"@nVlrBruto		,@oVlrTotal		,@nMoedaCor	  	,@cSimbCor		,	"+;
																	"@nTaxaMoeda	,oPgtos		 	,@oPgtosSint	,@aPgtosSint 	,	"+;
																	"@lRecebe		,@aParcOrc		,@aParcOrcOld 	,@nVlrPercAcr	,	"+;
																	"@nVlrAcreTot	,@nVlrDescCPg 	,@aMoeda		,@aSimbs	 	,	"+;
																	"@aCols			,@aCProva		,@aFormCtrl	  	,@nTroco 	 	,	"+;
																	"@nTroco2 		,@lDescCond		,@nDesconto	  	,@aDadosCH   	,	"+;
																	"@cItemCond		,@lCondNegF5	,@aParcelas	  	,@cCliente   	,	"+;
																	"@cLojaCli    	,@nVlrDescTot   ,@aRegTEF    	,"+;
																	"@lRecarEfet	 ,@aTefBkpCS	,@oPgtos			)",;
												 		          	 {|x| .F.}})
	EndIf

	AAdd(aFuncoes,{"12", STR0027,"If(LjProfile(13) .AND. !Empty(LJGetStation('GAVETA')),IFGaveta(nHdlECF),)",;
																{|x| .F.}})	// Abrir Gaveta
	If cPaisLoc <> "BRA"
		aadd(aFuncoes,{"--", "",     "",             			{|x| .F.}})
		aadd(aFuncoes,{"13", STR0028,"FR271HCalcVen(	@nVlrTotal	, @nMoedaCor	, @nTaxaMoeda)",;
																{|x,y,z| .F.}})	// "Totais da Venda - Diversas Moedas"
		If SuperGetMV("MV_TRCMOED")
			aadd(aFuncoes,{"14", STR0029,"FR271HTRCMoeda(	@nMoedaCor	, @cMoeda	, @oMoedaCor, @nDecimais,"	+;
											  			"	@oTaxaMoeda	, @cSimbCor	, @oTemp3	, @oTemp4  	,"	+;
											  			"	@oTemp5		, @aItens	, @aMoeda	, @aSimbs)	 "	,;
											  					{|	a	, b	, c	, d	,;
											  					   	e	, f	, g	, h	,;
											  						i	, j	, k	, l| .F.}})	// "Troca da Moeda da Venda"
			aadd(aFuncoes,{"--", "",     "",           			{|x| .F.}})
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PORTUGAL - Nao Utilizara ECF ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LjNfPtgNEcf(SM0->M0_CGC) .And. !lEmitNFCe
		AAdd(aFuncoes,{"15", STR0030,"If(lOcioso, LOJA180(),)",		{|x| .F.}})	// "Leitura da Memoria Fiscal"
		AAdd(aFuncoes,{"16", STR0042,"If(lOcioso, LJ200Inc(),)", 	{|x| .F.}})	// "Resumo da Redução Z"
	EndIf

	AAdd(aFuncoes,{"17", STR0043,"FR271IReceb(	@oHora			, @cHora		, @oDoc			, @cDoc			,"	+;
											"	@oCupom			, @cCupom		, @nVlrPercIT	, @nLastTotal	,"	+;
											"	@nVlrTotal		, @nLastItem	, @nTotItens	, @nVlrBruto	,"	+;
											"   @oDesconto		, @oTotItens	, @oVlrTotal	, @oFotoProd	,"	+;
											"   @nMoedaCor		, @cSimbCor		, @oTemp3		, @oTemp4		,"	+;
											"	@oTemp5			, @nTaxaMoeda	, @oTaxaMoeda	, @nMoedaCor	,"	+;
											"	@cMoeda			, @oMoedaCor	, @cCodProd		, @cProduto		,"	+;
											"	@nTmpQuant		, @nQuant		, @cUnidade		, @nVlrUnit		,"	+;
											"	@nVlrItem		, @oProduto		, @oQuant		, @oUnidade		,"	+;
											"	@oVlrUnit		, @oVlrItem		, @oPgtos		, @oPgtosSint	,"	+;
											"	@aPgtos			, @aPgtosSint	, @cOrcam		, @cPDV			,"  +;
											"	@lTefPendCS		, @aTefBKPCS	, @oDlgFrt		, @cCliente		,"	+;
											"	@cLojaCli		, @cVendLoja	, @lOcioso		, @lRecebe		,"  +;
											"   @lLocked		, @lCXAberto	, @aTefDados	, @dDataCN		,"	+;
											"   @nVlrFSD		, @lDescIT		, @nVlrDescTot	, @nValIPI		,"	+;
											"	@aItens			, @nVlrMerc		, @lEsc			, @aParcOrc		,"  +;
											"	@cItemCOrc		, @aParcOrcOld	, @aKeyFimVenda	, @lAltVend		,"  +;
											"   @lImpNewIT		, @lFechaCup	, @aTpAdmsTmp	, @cUsrSessionID,"  +;
											"   @cContrato		, @aCrdCliente	, @aContratos	, @aRecCrd		,"  +;
											"   @aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv		,"	+;
											"	@cNumCartConv	, @uCliTPL		, @uProdTPL		, @lDescTotal	,"  +;
											"	@lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	, @nVidaLink	,"  +;
											"   @cCdPgtoOrc		, @cCdDescOrc	, @nValTPis		, @nValTCof		,"	+;
											"	@nValTCsl		, @lOrigOrcam	, @lVerTEFPend	, @nTotDedIcms	,"  +;
											" 	@lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	,"	+;
											"	@nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	, @nNumParcs	,"  +;
											"	@aMoeda			, @aSimbs		, @cRecCart		, @cRecCPF		,"  +;
											"	@cRecCont		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	,"  +;
											"	@aImpVarDup		, @aTotVen		, @nTotalAcrs	, @lRecalImp	,"  +;
											"	@aCols			, @aHeader 		, @aDadosJur	, @aCProva		,"	+;
											"	@aFormCtrl		, @nTroco		, @nTroco2 		, @lDescCond	,"  +;
											"	@nDesconto		, @aDadosCH		, @lDiaFixo		, @aTefMult		," 	+;
											"	@aTitulo		, @lConfLJRec	, @aTitImp		, @aParcelas	,"	+;
											"   @oCodProd		, @cItemCond	, @lCondNegF5	, @nTxJuros		,"	+;
											"	@nValorBase		, @oTimer		, @lResume		, @oOnOffLine	,"	+;
											"	@nValIPIIT		, @_aMult		, @_aMultCanc	, @nVlrDescIT	,"	+;
											"	oFntMoeda		, @lBscPrdON	, @oPDV			, @aICMS		,"	+;
											"	@lDescITReg		, @cMensagem)",;
												{|	a	, b		, c		, d	,;
													e	, f		, g		, h	,;
													i	, j		, k		, l ,;
													m	, n		, o		, p	,;
													q	, r		, s		, t	,;
													u	, w		, y		, x	,;
													z	, aa	, ab	, ac,;
													ad	, ae	, af	, ag,;
													ah	, ai	, aj	, ak,;
													al 	, am	, an	, ao,;
													ap	, aq	, ar	, ay,;
													at	, au	, aw	, ay,;
													ax	, az	, ba	, bb,;
													bc	, bd	, be	, bf,;
													bg	, bh	, bi	, bj,;
													bk	, bl 	, bm	, bn,;
													bo	, bp	, bq	, br,;
													bs	, bt	, bu	, bw,;
													by	, bx	, bz	, ca,;
													cb	, cc	, cd	, ce,;
													cf	, cg	, ch	, ci,;
													cj	, ck	, cl 	, cm,;
													cn	, co	, cp	, cq,;
													cr	, cs	, ct	, cu,;
													cw	, cy	, cx	, cz,;
													da	, db	, dc	, dd,;
													de	, df	, dg	, dh,;
													di	, dj	, dk	, dl,;
													dm	, dn	, dyy	, dp,;
													dq	, dr	, ay	, dt,;
													du	, dw	, ey	, ex,;
													ez	, ea	, eb	, ec,;
													ed	, ee	, ef	, eg,;
													eh	, ei	, ej	, ek,;
													el	, em  	, en	, eo,;
													ep	, eq	, er	, es,;
													et	, eu	, ev	, ex,;
													ew	| .F.}})	// "Recebimentos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se estah integrado com o Sistema de credito³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CrdxInt()
		aadd(aFuncoes,{"--", "",     "",             				{|x| .F.}})
		AAdd(aFuncoes,{"18", STR0044,"CrdAExtrato( 1 )", 			{|x| .F.}})		//"Extrato das parcelas"
		AAdd(aFuncoes,{"19", STR0045,"CrdAExtrato( 2 )", 			{|x| .F.}})		//"Consulta limite de crédito"
		AAdd(aFuncoes,{"20", STR0046,"CrdxFila()",					{|x| .F.}})		//"Medir tempo de fila"
		AAdd(aFuncoes,{"21", STR0084,			"MontaOrcam(	  SL1->L1_NUM   , cCliente      , cLojaCli      , cVendLoja,  "+;
																" cItemCond		, aTefDados		, aPgtos		, lCondNegF5, "+;
											 					" @oHora		, @cHora		, @oDoc			,"+;
																" @cDoc			, @oCupom		, @cCupom		, @nVlrPercIT	,"+;
																" @nLastTotal	, @nVlrTotal	, @nLastItem	, @nTotItens	,"+;
																" @nVlrBruto	, @oDesconto	, @oTotItens	, @oVlrTotal	,"+;
																" @oFotoProd	, @nMoedaCor	, @cSimbCor		, @oTemp3		,"+;
																" @oTemp4		, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda	,"+;
																" @nMoedaCor	, @cMoeda		, @oMoedaCor	, @cCodProd		,"+;
																" @cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,"+;
																" @nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,"+;
																" @oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7			,"+;
																" @cCliente		, @cLojaCli		, @lOcioso		, @nVlrFSD		,"+;
																" @nVlrDescTot	, @aItens		, @nVlrMerc		, @lFechaCup	,"+;
																" @cUsrSessionID, @cContrato	, @aCrdCliente	, @aContratos	,"+;
																" @aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,"+;
																" @cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,"+;
																" @aVidaLinkD	, @aVidaLinkc	, @nVidaLink	, @lVerTEFPend	,"+;
																" @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,"+;
																" @nVlrPercOri	, @nQtdeItOri	, @nNumParcs	, @aImpsSL1		,"+;
																" @aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen		,"+;
																" @nTotalAcrs	, @aCols		, @aHeader		, @aDadosJur	,"+;
																" @aCProva		, @lCXAberto	, @oMensagem	, @oFntGet 		,"+;
																" @cTipoCli		, @lAbreCup		, @lReserva		, @aReserva		,"+;
																" @nValor		, @aRegTEF		, @lRecarEfet	, @nHdlECF      ,"+;
																" @aFormCtrl    )", {|x| x }})  //"Enviar para Crédito"
	Endif

	/* Adiciona o Menu Fiscal conforme requisito VII do PAF-ECF */
	If lLjNfPafEcf .And. !lEmitNFCe
		AAdd(aFuncoes,{"22", STR0085,"STBMenFis(.T.,.F.)", {|x| .F.}}) // "Menu Fiscal
    EndIf

	If cTipTef == TEF_CLISITEF .AND. lUsaTef
		If oTef:LjRecCel() .AND. !Empty(LjGetStation("WSSRV")) .AND. ( oTef:lTemPinPad .OR. ( FindFunction("LjTEFRCSPin") .AND. LjTEFRCSPin() ) )
	 		AADD(aFuncoes, {"26", STR0082, "oTef:RecargaNFiscal()", 					{|x| .F.}})// Recarga de celular
	  	EndIf
	EndIf

	If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		T_DROVLPSet (@oHora			, @cHora		, @oDoc			, @cDoc			,; 	//1
					 @oCupom		, @cCupom		, @nLastTotal	, @nVlrTotal	,;	//2
					 @nLastItem	 	, @nTotItens	, @nVlrBruto	, @oDesconto	,;	//3
					 @oTotItens	 	, @oVlrTotal	, @oFotoProd	, @nMoedaCor	,;	//4
					 @cSimbCor	 	, @oTemp3		, @oTemp4		, @oTemp5		,;	//5
					 @nTaxaMoeda	, @oTaxaMoeda	, @nMoedaCor	, @cMoeda		,;	//6
					 @oMoedaCor	 	, @nVlrPercIT	, @cCodProd		, @cProduto		,;	//7
					 @nTmpQuant	 	, @nQuant		, @cUnidade		, @nVlrUnit		,;	//8
					 @nVlrItem		, @oProduto		, @oQuant		, @oUnidade		,;	//9
					 @oVlrUnit	 	, @oVlrItem		, @lF7			, @oPgtos		,; 	//10
					 @oPgtosSint	, @aPgtos		, @aPgtosSint	, @cOrcam		,; 	//11
					 @cPDV		 	, @lTefPendCS 	, @aTefBKPCS	, @oDlgFrt		,; 	//12
					 @cCliente	 	, @cLojaCli		, @cVendLoja	, @lOcioso		,; 	//13
					 @lRecebe		, @lLocked		, @lCXAberto	, @aTefDados	,; 	//14
					 @dDataCN		, @nVlrFSD		, @lDescIT		, @nVlrDescTot	,; 	//15
					 @nValIPI		, @aItens 		, @nVlrMerc		, @lEsc			,; 	//16
					 @aParcOrc	 	, @cItemCOrc	, @aParcOrcOld	, @aKeyFimVenda	,; 	//17
					 @lAltVend	 	, @lImpNewIT	, @lFechaCup	, @aTpAdmsTmp	,; 	//18
					 @cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,; 	//19
					 @aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,; 	//20
					 @cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,; 	//21
					 @lDescTotal	, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,; 	//22
					 @nVidaLink		, @cCdPgtoOrc	, @cCdDescOrc	, @nValTPis		,; 	//23
					 @nValTCof		, @nValTCsl		, @lOrigOrcam	, @lVerTEFPend	,; 	//24
					 @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,;  //25
					 @nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	,; 	//26
					 @nNumParcs		, @aMoeda		, @aSimbs		, @cRecCart		,;  //27
					 @cRecCPF		, @cRecCont		, @aImpsSL1		, @aImpsSL2		,;  //28
					 @aImpsProd		, @aImpVarDup	, @aTotVen		, @nTotalAcrs	,; 	//29
					 @lRecalImp		, @aCols		, @aHeader 		, @aDadosJur	,; 	//30
					 @aCProva		, @aFormCtrl	, @nTroco		, @nTroco2 		,;  //31
					 @lDescCond		, @nDesconto	, @aDadosCH		, @lDiaFixo		,; 	//32
					 @aTefMult		, @aTitulo		, @lConfLJRec	, @aTitImp		,; 	//33
					 @aParcelas		, @oCodProd		, @cItemCond	, @lCondNegF5	,; 	//34
					 @nTxJuros		, @nValorBase	, @oMensagem	, @oFntGet		,; 	//35
					 @cTipoCli		, @lAbreCup		, @lReserva		, @aReserva     ,; 	//36
					 @oTimer		, @lResume		, @nValor 		, @aRegTEF		,; 	//37
					 @lRecarEfet	, @oOnOffLine	, @nValIPIIT	, @_aMult		,; 	//38
					 @_aMultCanc	, @nVlrDescIT	, @oFntMoeda	, @lBscPrdON	,; 	//39
					 @oPDV			, @aICMS		, @lDescITReg) 						//40
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o Menu Midia     			      				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistFunc("LjxGetMid") .AND. AllTrim(Str(SuperGetMv("MV_LJRGMID",,0))) $ "1|2"
		AADD(aFuncoes, {"27", STR0110,"M->L1_MIDIA:= LjxGetMid(M->L1_MIDIA)", {|x| .F.}}) // Midia
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se utilizar consulta de estoque por filial, adiciona o Menu Consulta de Estoque	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMV("MV_LJESTFL",,.F.) .AND. ExistFunc("LJXEstoque()")
   		AADD(aFuncoes, {"28", STR0112,"LJXEstoque()", {|x| .F.}}) // "Consulta Estoque"
	Endif

	If AliasIndic("SLZ") .AND. lUsaTef
	 	SLZ->(DbSeek(xFilial("SLZ"), .T.))
	 	If cTipTef == TEF_CLISITEF .AND. !(SLZ->(EOF()))
			AADD(aFuncoes,{"--", "",     "",					             				{|x| .F.}})
	 		AADD(aFuncoes, {"24", "PBM", "FR271MenuPbm(@oDlgFrt, @oFntGet)", 				{|a, b| .F.}})
	 	EndIf
	EndIf
	
	//Incluso o item 32 - Estorno de venda
	AADD(aFuncoes,{"--", "",     "",					             				{|x| .F.}})
	aadd(aFuncoes,{"32", STR0106,"If(lOcioso,FR271FEsVe(),)", {|x| .F.}})

	If lUsaLstPre
		aAdd(aFuncoes,{"--",""								,""				,{|x| .F.}})
		aAdd(aFuncoes,{"29",STR0114,"FR271Lista(@cCodProd		, @oTimer		, @oHora		, @cHora		," +;
																		"@oDoc			, @cDoc			, @oPDV			, @cPDV			," +;
																		"@nLastTotal	, @nVlrTotal	, @nLastItem	, @nTotItens	," +;
																		"@nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	," +;
																		"@oOnOffLine	, @nTmpQuant	, @nVlrItem		, @nValIPIIT	," +;
																		"@nValIPI		, @oFotoProd	, @oProduto		, @oQuant		," +;
																		"@oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		," +;
																		"@cOrcam		, @cProduto		, @nQuant		, @cUnidade		," +;
																		"@nVlrUnit		, @oUnidade		, @lF7   		, @cCliente		," +;
																		"@cLojaCli		, @cVendLoja	, @lOcioso		, @lRecebe		," +;
																		"@lLocked		, @lCXAberto	, @lDescIT		, @nVlrDescTot	," +;
																		"@aItens		, @aICMS		, @nVlrMerc		, @_aMult		," +;
																		"@_aMultCanc	, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	," +;
																		"@lAltVend		, @lImpNewIT	, @lFechaCup	, @cContrato	," +;
																		"@aCrdCliente	, @aContratos	, @aRecCrd		, @aTEFPend		," +;
																		"@aBckTEFMult	, @cCodConv		, @cLojConv		, @cNumCartConv	," +;
																		"@uCliTPL		, @uProdTPL		, @lDescTotal	, @lDescSE4		," +;
																		"@aVidaLinkD	, @aVidaLinkc 	, @nVidaLink	, @nValTPis		," +;
																		"@nValTCof		, @nValTCsl		, @lVerTEFPend	, @nTotDedIcms	," +;
																		"@lImpOrc 		, @nVlrPercTot	, @nVlrPercAcr	, @nVlrAcreTot	," +;
																		"@nVlrDescCPg	, @nQtdeItOri	, @aMoeda		, @aSimbs		," +;
																		"@nMoedaCor		, @aImpsSL1		, @aImpsSL2		, @aImpsProd	," +;
																		"@aImpVarDup	, @aTotVen		, @aCols		, @nVlrPercIT	," +;
																		"@nTaxaMoeda  	, @aHeader		, @nVlrDescIT	, @oMensagem	," +;
																		"@oFntMoeda		, @cMensagem	, @cTipoCli		, @lBscPrdON	," +;
																		"@aReserva 		, @lReserva		, @lAbreCup		, @nValor		," +;
																		"@cCupom		, @aRegTEF		, @lRecarEfet	, @lDescITReg	," +;
																		"@aMostruario	)" 	,{|x| .F.}})

	EndIf

	If lUseSAT
		aAdd(aFuncoes,{"34", IIF(lMFE, STR0161, STR0144), "FR271FImpSAT()"	, {|x| .F.}}) //"Reimprimir MF-e" #"Reimprimir SAT"
	ElseIf lEmitNFCe
   		aAdd(aFuncoes,{"34", STR0137, "ReImpNfce()"		, {|x| .F.}}) // "Reimprimir NFC-e"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para chamar a funcao do Corresp.Bancario e PBM no FrontLoja³
	//³Retona as posicoes 22 - Correspondente Bancario                    		   ³
	//³Retona as posicoes 23 - PBM - Vidalink                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFRTFUNCOESt
		aFuncoes := ExecTemplate("FRTFUNCOES",.F.,.F.,{aFuncoes})
	EndIf
	If ExistBlock("FRTFUNCOES")
		aFuncoes := ExecBlock("FRTFUNCOES",.F.,.F.,aFuncoes)
	EndIf

	If !Empty(aFuncoes)

		FR271IAddLine( FRT_SEPARATOR	, @nNumLinesCup	, "99"	, oCupom	,;
					@lEsc,@cCupom )
		FR271IAddLine( ""				, @nNumLinesCup	, "99"	, oCupom	,;
					@lEsc,@cCupom )
		FR271IAddLine( STR0012			, @nNumLinesCup	, "99"	, oCupom	,;
					@lEsc,@cCupom )	// "Entre com o código da rotina desejada:"
		FR271IAddLine( ""				, @nNumLinesCup	, "99"	, oCupom	,;
					@lEsc,@cCupom )

		For nI := 1 to Len( aFuncoes )
			If aFuncoes[nI][1] == "--"
				cFuncao := FR271IAddLine(	Replicate("-",38)	, @nNumLinesCup	, "99"	, oCupom	,;
										@lEsc,@cCupom )
			Else
				cFuncao := FR271IAddLine(	aFuncoes[nI][1]+" - "+aFuncoes[nI][2]	, @nNumLinesCup	, "99"	, oCupom	,;
										@lEsc,@cCupom )
			EndIf

			If !Empty( cFuncao ) .OR. lEsc
				Exit
			EndIf
		Next nI

		If Empty( cFuncao ) .AND. ! lEsc
			FrtGet(@cFuncao, "99", @lEsc)
		EndIf

		lEsc := .F.

		nLen := 0

		cCupom := cOldcCupom
	  	oCupom:Refresh()
		oCupom:AppendText("")
		oCupom:GoEnd()


		If (nI := AScan(aFuncoes, {|x| x[1]==AllTrim(cFuncao)})) > 0
			bCmd := &('{ |nHdlECF, cRet| ' + aFuncoes[nI][3] + ' }')

			If lUsaDisplay
				DisplayEnv(StatDisplay(), "1C" + STR0047 )         	//"FUNCOES FRONT LOJA"
				If AllTrim(cFuncao) == "02"
					DisplayEnv(StatDisplay(), "2C" + STR0130 )        //"Redução Z"
				ElseIf AllTrim(cFuncao) == "03"
					DisplayEnv(StatDisplay(), "2C" + STR0048 )        //"Cancelando Cupom"
				ElseIf AllTrim(cFuncao) == "04"
					DisplayEnv(StatDisplay(), "2C" + STR0049 )        //"Emitindo Leitura X"
				ElseIf AllTrim(cFuncao) == "05"
					DisplayEnv(StatDisplay(), "2C" + STR0131 )        //"Sangria"
				ElseIf AllTrim(cFuncao) == "06"
					DisplayEnv(StatDisplay(), "2C" + STR0132 )        //"Entrada de Troco"
				ElseIf AllTrim(cFuncao) == "07"
					DisplayEnv(StatDisplay(), "2C" + STR0050 )        //"Consulta Produto"
				ElseIf AllTrim(cFuncao) == "11"
					DisplayEnv(StatDisplay(), "2C" + STR0051 )     	//"Cancelamento Tr. TEF"
				ElseIf AllTrim(cFuncao) == "12"
					DisplayEnv(StatDisplay(), "2C" + STR0052 )        //"Abrir Gaveta"
				ElseIf AllTrim(cFuncao) == "15"
					DisplayEnv(StatDisplay(), "2C" + STR0053 )		//"Leitura da Memoria Fiscal"
				ElseIf AllTrim(cFuncao) == "22"
					DisplayEnv(StatDisplay(), "2C" + STR0085 )		//"Menu Fiscal"
				ElseIf AllTrim(cFuncao) == "32"
					DisplayEnv(StatDisplay(), "2C" + STR0106 )		//"Estorno da venda"
				EndIf
			EndIf
			uRet := Eval( bCmd, nHdlECF, @cRet )					// Execucao
			If AllTrim(cFuncao) == "03"								// Caso seja Canccelamento Cupom
				lRet := uRet
			Else
				lRet := Eval( aFuncoes[nI][4], uRet )				// Retorno
			EndIf
		EndIf
	    If ExistBlock("FRTFUNCSAI")
		   ExecBlock("FRTFUNCSAI",.F.,.F.)
	    EndIf
	EndIf

	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1E"+ STR0054)	// "Codigo do Produto: "
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TEMPLATE DROGARIA						    ³
	//³ Repassa valores do Vidalink para o FRTA271  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		aParamVL := T_DROVLPGet()			// não repassa caso tenha efetuado cancelamento
		If aParamVL[1][VLP_NVIDAL] == 2 .And. AllTrim(cFuncao) <> "03"	

			nVlrTotal  	:= aParamVL[1][VLP_NVLRTO]
			nTotItens	:= aParamVL[1][VLP_NTOTIT]
			nVlrBruto	:= aParamVL[1][VLP_NVLRBR]
			oDesconto	:= aParamVL[1][VLP_ODESCO]
			oTotItens	:= aParamVL[1][VLP_OTOTIT]
			oVlrTotal	:= aParamVL[1][VLP_OVLRTO]
			nVlrPercIT	:= aParamVL[1][VLP_NVLRPE]
			nQuant		:= aParamVL[1][VLP_NQUANT]
			cUnidade	:= aParamVL[1][VLP_CUNIDA]
			nVlrUnit	:= aParamVL[1][VLP_NVLRUN]
			nVlrItem	:= aParamVL[1][VLP_NVLRIT]
			oProduto	:= aParamVL[1][VLP_OPRODU]
			oQuant		:= aParamVL[1][VLP_OQUANT]
			oUnidade	:= aParamVL[1][VLP_OUNIDA]
			oVlrUnit	:= aParamVL[1][VLP_OVLRUN]
			oVlrItem	:= aParamVL[1][VLP_OVLRIT]
			oPgtos		:= aParamVL[1][VLP_OPGTOS]
			oPgtosSint	:= aParamVL[1][VLP_OPGTO2]
			aPgtos		:= aParamVL[1][VLP_APGTOS]
			aPgtosSint	:= aParamVL[1][VLP_APGTO2]
			aItens 		:= aParamVL[1][VLP_AITENS]
			nVlrMerc	:= aParamVL[1][VLP_NVLRME]
			lDescTotal	:= aParamVL[1][VLP_LDESCT]
			nDesconto	:= aParamVL[1][VLP_NDESCO]
			lAbreCup	:= aParamVL[1][VLP_LABREC]
		EndIf
    EndIf

ElseIf lLjNfPafEcf .And. !lEmitNFCe  // No caso do PAF ECF permite acessar apenas a opcao do menu fiscal.
    MsgStop(OemToAnsi(STR0159), OemToAnsi(STR0002)) //"Usuário sem permissão para acessar Funções Frontloja F12"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	MsgStop(OemToAnsi(STR0116), OemToAnsi(STR0002))            //"Conforme previsto no Requisito VII (Item 1) do Ato Cotepe 0608 (PAF-ECF), o Menu Fiscal não pode possuir restrição de acesso."
	AAdd(aFuncoes,{"22", STR0085,"STBMenFis(.T.,.F.)", {|x| .F.}}) // "Menu Fiscal
	bCmd := &('{ |nHdlECF, cRet| ' + aFuncoes[Len(aFuncoes)][3] + ' }')
	uRet := Eval( bCmd, nHdlECF, @cRet )					   // Execucao
	lRet := Eval( aFuncoes[Len(aFuncoes)][4], uRet )		   // Retorno
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271FForm³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao das Formas de Pagamento da Parcela Atual (CTRL)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271FFormPag(	aFormPag	, cDesc			, cForma		, cGrupo		,;
						cDoc		, oCupom		, cCupom		, nVlrTotal		,;
						nVlrBruto	, oVlrTotal		, nMoedaCor		, cSimbCor		,;
						nTaxaMoeda	, oPgtos		, oPgtosSint	, aPgtos		,;
						aPgtosSint	, lRecebe		, aParcOrc		, aParcOrcOld	,;
						nVlrPercAcr	, nVlrAcreTot	, nVlrDescCPg	, aMoeda		,;
						aSimbs		, aCols			, aCProva		, aFormCtrl		,;
						nTroco		, nTroco2 		, lDescCond		, nDesconto		,;
						aDadosCH	, cItemCond		, lCondNegF5	, aParcelas		,;
						cCliente 	, cLojaCli 	    , nVlrDescTot   , aValePre  	,;
						aRegTEF		, lRecarEfet	, aColsMAV		, aTefBkpCS		,;
						nValDescPa	, aTxJurAdm		, nPercDesc		, nValorDesc	,;
						lVoid		, nEntrada		, dDataCN		, aItens		,;
						nVlrMerc	, lDescTotal	, lDescSE4		, nTotDedIcms	,;
						nVlrPercTot	, aImpsSL1		, aImpsSL2		, aImpsProd		,;
						aDadosJur	, lDescEspec	, nValorBase	, lDiaFixo		,;
						lImpOrc		, lRecalImp		, aHeader		, cOrcam ,;
						nArredondar , nParcSel)

Local nOpc 			:= 2
Local nCtrl
Local nI
Local nValParc
Local nDif
Local nDel
Local cAdm
Local nValMax
Local aKey
Local dData
Local nNumParc
Local nTXJuros
Local nIntervalo
Local nValor
Local cMoedaVen
Local nPosMoeda		:= nMoedaCor
Local nTamMoed1 	:= 0
Local nTamMoed2 	:= 0
Local nPosDesc  	:= 0
Local nLen
Local nOldLen	    := 0
Local cFuncao		:= "  "
Local nNumLinesCup 	:= 0
Local cOldcCupom    := cCupom
Local cDescParcelas := ""
Local lEsc			:= .F.
Local aCheques
Local aMultMoeda 	:= {}
Local cSimbMoeda 	:= ""
Local aFormCtrlBkp 	:= {}
Local nValAux    	:= 0
Local nMvFrtDesc 	:= SuperGetMV("MV_FRTDESC")	   						// 1=Considera desconto; 2=Desconsidera o desconto; 3=Pergunta
Local nMvFrtAcre 	:= SuperGetMV("MV_FRTACRE",,2)						// 1=Considera acrescimo; 2=Desconsidera o acrescimo; 3=Pergunta
Local lFrtFormPag   := ExistBlock( "FRTFORMPAG" )
Local aRetFormPag   := {.T.,"","",CtoD(""),0,0,0,0}
Local nVlrAux       := 0
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.)			 // Identifica se o cliente utiliza múltiplas transações TEF
Local lDifCart      := .F. 			                           // Identifica se o cliente utiliza o mesmo carão para todas as parcelas de uma determinada ADM
Local nLinha		:= 35										// Controle de posicionamento dos objetos na tela
Local nColuna		:= If(lUsaTef .AND. lTefMult,20,0)			// Tamanho da Dialog
Local lUsaAdm       := .T.
Local cVinculado	:= "0"
Local lVisuSint  := If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local cFormaId		:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))	//Inicializa ID Cartao para multi-tef
Local cSimbCheq   	:= AllTrim(MVCHEQUE)
Local lMV_LJSLFin  	:= SuperGetMV("MV_LJSLFIN", ,.T.)
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local nDecimais  	:= MsDecimais(nMoedaCor)
Local nPreDes		:= 0 				// PercDescPa
Local lGerFin      	:= .F.				// Gera Fin de Desconto Patrocinado
Local nVrDesL4		:= 	0				// Gera valor de desconto sl4
Local lNovRegra 	:= SuperGetMv("MV_LJRGDES",,.F.)  							//Controle se trabalha com nova regra de desconto
Local aFPagtoRegra	:= {}														//Array com as forma pagto para regra de desconto
Local nPos			:= 0
Local lUseSAT 	:= IIF(ExistFunc("LjUseSat"),LjUseSat(),.F.)			//Estação com SAT?

Static lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .And. RGVldTable()		//Validacao da Nova Regra de Desconto Ativa
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

LOCAL lHomolog := FindFunction("LJHOMTEF") .AND. LjMSSM0(SM0->M0_CGC)		// Indica que esta sendo feita homologacao na Software Express
LOCAL nQtdCart := 0 														//Indica qtde de cartoes na homologacao
LOCAL nCont    := 0 														//Contador qtde de cartoes na homologacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLjcFid	 	:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()				//Indica se a recarga de cartao fidelidade esta ativa
Local cCliPatr		:= "" 									//Banco ou Adm patrocinadora
Local lMvLjJurcc	:= SuperGetMv("MV_LJJURCC",NIL,.F.)		//Parametro para verificar se a empresa utiliza ou nao juros na administradora
Local lMVTELAFIN	:= SuperGetMV("MV_TELAFIN",,.T.)      	// Define de onde pega a ADM financeira
Local cMV_LJPGTRO := AllTrim(SuperGetMV("MV_LJPGTRO",,""))
Local lMultNeg 		:= SuperGetMv("MV_LJMULTN",,.F.)
Local cSeqTrans		:= "" 									//Numero Sequencia transacao TEF

Default nPercDesc	:= 0									//Percentual de desconto da nova regra
Default nValorDesc	:= 0									//Valor de desconto da nova regra
DEFAULT cGrupo 		:= ""
DEFAULT nVlrDescTot	:= 0
DEFAULT aValePre	:= {}
DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.
DEFAULT aColsMAV    := {}
DEFAULT aTefBkpCS	:= {}
DEFAULT nValDescPa	:= 0
DEFAULT aTxJurAdm	:= {0,0,0}

DEFAULT nEntrada	:= 0
DEFAULT dDataCN 	:= CTOD("  /  /  ")
DEFAULT aItens		:= {}
DEFAULT nVlrMerc	:= 0
DEFAULT lDescTotal	:= .F.
DEFAULT lDescSE4    := .F.
DEFAULT nTotDedIcms := 0
DEFAULT nVlrPercTot := 0
DEFAULT aImpsSL1    := {}
DEFAULT aImpsSL2	:= {}
DEFAULT aImpsProd	:= {}
DEFAULT aDadosJur	:= {}
DEFAULT lDescEspec  := .F.
DEFAULT nValorBase  := 0
DEFAULT lDiaFixo    := .F.
DEFAULT lImpOrc     := .F.
DEFAULT lRecalImp   := .F.
DEFAULT aHeader		:= {}
DEFAULT cOrcam      := ""
DEFAULT nParcSel	:= 0


If (!lRecebe .AND. lMultNeg .And.  cPaisLoc == "BRA" .And. SL1->(ColumnPos( "L1_CODMNEG" ))> 0 .And. !Empty(SL1->L1_CODMNEG) )
	MsgAlert(STR0136)//"Não é permitido alterar a forma de pagamento para orçamentos de Multi Negociação"
	Return(.T.)  // nao deve aceitar alterar a forma de pagamento
EndIf

lVoid := .F.

If lVisuSint .AND. Len(aPgtos) == 0	.AND. lTefMult				// Caso seja a primeira parcela a ser lancada
	cFormaID := "1"												// Automaticamente atribui "1" como ID do cartao.
EndIf

If nVlrAcreTot > 0 .AND. ( nVlrAcreTot > ( SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA) ) .And. !lImpOrc  // tem acrescimo , então valor bruto tem que voltar ao valor original para ser utilizado
	nVlrBruto -= nVlrAcreTot + nVlrDescTot // Para zerar os acrescimos financeiros da condição de pagamento
Else
	// Isso sera verdade quando acionado esc na escolha da forma de pagamento(F5),
	//pois deve-se retornar ao valor original sem descontos
	//Quando localidade México, ao dar desconto total no total as variáveis nVlrBruto e nVlrTotal tem o mesmo valor
	If !cPaisLoc == "MEX" .AND. nVlrBruto == nVlrTotal
		nVlrDescTot := 0
	EndIf
	//tratamento para quando a venda for paga integralmente com Ncc e desconto
	If  nVlrBruto == nVlrTotal .And.  Frt060Ret("NCC_USADA") == 0
		nVlrDescTot := 0
	EndIf

	//Se nVlrBruto+L1_FRETE for igual ao nVlrTotal, eh porque falta ainda somar o frete na variavel nVlrBruto
	If nVlrBruto+SL1->L1_FRETE == nVlrTotal
		nVlrBruto += SL1->L1_FRETE
	EndIf
EndIF

If !lTouch
	//Atualizacao do valor total
	oVlrTotal:Refresh()
	oCupom:Refresh()
EndIF

If lFrtFormPag
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicoes da array aRetFormPag                                               ³
	//³                                                                            ³
	//³1 - Logico - Define se deve ou não, exibir a janela com os valores desejados³
	//³2 - Caracter - Forma de pagamento                                           ³
	//³3 - Caracter - Descricao da forma de pagamento                              ³
	//³4 - Date - Data do vencimento da parcela                                    ³
	//³5 - Numerio - Numero de parcelas                                            ³
	//³6 - Numerico - Taxa de juros                                                ³
	//³7 - Numerico - Numero de intervalos                                         ³
	//³8 - Numerico - Valor da parcela                                             ³
	//³9 - Caracter - ID Cartão			                                           ³
	//³10- Numerico - Valor do Desconto a ser aplicado no total do Cupom Fiscal    ³
	//³11- Numerico - Valor total do Cupom Fiscal    							   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetFormPag := ExecBlock( "FRTFORMPAG" , .F., .F., {aFormPag, cDesc, cForma, cGrupo, nVlrTotal, nVlrDescTot,aPgtos} )
	If !aRetFormPag[1]
		cForma     := aRetFormPag[2]
		cDesc      := aRetFormPag[3]
		dData      := aRetFormPag[4]
		nNumParc   := aRetFormPag[5]
		nTXJuros   := aRetFormPag[6]
		nIntervalo := aRetFormPag[7]
		nValor	   := aRetFormPag[8]
		cFormaId   := If(lVisuSint,If(Len(aRetFormPag)>8,aRetFormPag[9]," "),cFormaID)
		If Len(aRetFormPag) > 9
		    nVlrDescTot:= aRetFormPag[10]
		EndIf
		If Len(aRetFormPag) > 10
		   nVlrTotal  := aRetFormPag[11]
		   oVlrTotal:Refresh()
		EndIf

		If nValor > nVlrTotal
			If !( SL1->(FieldPos("L1_TROCO1")) > 0 .AND. SuperGetMV("MV_LJTROCO", ,.F.) .And. IIF (EMPTY(cMV_LJPGTRO) .Or. ( cForma   $ cMV_LJPGTRO ),.T. , .F.) )

				nValor := nVlrTotal
			Endif
		EndIf
		If cForma == SuperGetMV("MV_SIMB"+AllTrim(Str(Iif(nPosMoeda == 0, 1, nPosMoeda)))) .AND. dData > dDataBase
			dData := dDataBase
		EndIf
	Else
		lFrtFormPag := .F.
	Endif
EndIf

If ! (cItemCond=="CN" .AND. !lCondNegF5 .AND. Len(aParcOrc)==0) .AND. (Len(aTefBkpCS) == 0 .OR. (Len(aTefBkpCS) > 0 .AND. SuperGetMV("MV_TEFPEND",,"0") <> "1"))
	cItemCond  	:= "CN"
	lCondNegF5 	:= .F.
	aParcOrcOld := aParcOrc
	aParcOrc   	:= {}
	aPgtos     	:= {}

	oPgtos:SetArray(aPgtos)
	If lVisuSint
		aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
	EndIf

	//Não deve zerar quando definido no orcamento
	If !lImpOrc
		nVlrAcreTot := 0			// Zera o Acrescimo Financeiro
		nVlrPercAcr := 0			// Zera o percentual de Acrescimo Financeiro
	EndIf

	nVlrDescCPg := 0			// Zera o Desconto Financeiro

	If nVlrTotal < nVlrBruto	// Checa se considera ou não o desconto
		If nMvFrtDesc == 3
			nMvFrtDesc := If(MsgYesNo(STR0058),1,2) //"Foi informado um desconto no orçamento original. Continua considerando esse desconto ?"
		Endif
		If nMvFrtDesc == 2	// Desconsidera o desconto informado anteriormente
			nVlrTotal := nVlrBruto
		Endif
	ElseIf nVlrTotal > nVlrBruto	// Checa se considera ou não o acrescimo
		If nMvFrtAcre == 3
			nMvFrtAcre := If(MsgYesNo(STR0072),1,2) //"Foi informado um acrescimo no orçamento original. Continua considerando esse acrescimo ?"
		Endif
		If nMvFrtAcre == 2	// Desconsidera o desconto informado anteriormente
			nVlrTotal := nVlrBruto
		Endif
	Else
		nVlrTotal := nVlrBruto
	Endif
	If !lTouch
		oVlrTotal :Refresh()
	Endif
EndIf

// Se cGrupo diferente Nil, eh verificado a forma de pagamento e atribuido valor conforme a forma
If cGrupo <> Nil .And. !Empty(cGrupo)
	// Forma de pagamento igual a cartao de credito
	If cForma == "CC"
		cGrupo := "C"
	// Forma de pagamento igual a cartao de debito
	Elseif cForma == "CD"
		cGrupo := "D"
	Else
	// Nao e alterado o conteudo de cGrupo
		cGrupo := cGrupo
	Endif
Endif

If !Empty(cGrupo)
	// Verifica se o grupo escolhido pertence a forma de pagamento CC/CD,
	// se pertencer tem que verificar o parâmetro MV_LJSLFIN, caso contrário pede a tela para
	// escolha das financiadoras
	If ( nI := AScan(aFormPag, { |x| Left(x[4], 1) == cGrupo })) > 0
		lUsaAdm := Iif( aFormPag[nI,02] $ _FORMATEF , lMV_LJSLFin, .T. )
	EndIf
	If lUsaAdm
		oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
		oCupom:AppendText((chr(10) + chr(13)))
		oCupom:AppendText((STR0059)+ chr(10) + chr(13))	//"Selecione a Adm. Financeira:"
		oCupom:AppendText((chr(10) + chr(13)))

		If !Empty(aFormPag)

			For nI := 1 to Len( aFormPag )
				If Left(aFormPag[nI][4],1) == cGrupo
					cFuncao := FR271IAddLine(	aFormPag[nI][4] +" - "+ aFormPag[nI][1]	, @nNumLinesCup	, "99"	, oCupom	,;
												@lEsc,@cCupom )

					If !Empty( cFuncao ) .OR. lEsc
						Exit
					EndIf
				EndIf
			Next nI

			If Empty( cFuncao ) .AND. ! lEsc
				FrtGet(@cFuncao, "99", @lEsc)
			EndIf

			lEsc := .F.
		EndIf

		cFuncao := Alltrim(cFuncao)

	EndIf

	nLen := 0
	For nI := nLen To nOldLen+1 Step -1
	  cCupom := SubString(cCupom,1, len(cCupom) -40)
	Next nI

	cCupom := cOldcCupom
  	oCupom:Refresh()
	oCupom:AppendText("")
	oCupom:GoEnd()
	// O parâmetro de escolha de administradora esta como falso, pega qq função. Pois no
	// final da venda o sistema irá alterar para o cartão passado no TEF automaticamente.
	If ! lUsaAdm
		nI := AScan(aFormPag, { |x| Left(x[4], 1) == cGrupo })
	Else
	    nI := AScan(aFormPag, { |x| x[4] == ( cGrupo + cFuncao ) })
	EndIf

	If nI > 0
		cDesc  := Iif( ! lUsaAdm, " ", aFormPag[nI][1] )
		cForma := aFormPag[nI][2]
	Else
		Return(.T.)
	EndIf

EndIf

//"Quantidade de Vales"###"Parcelas"###"Cartoes"
nValMax := nVlrTotal

If cPaisLoc == "BRA"
   AEval(aFormCtrl, {|x| nValMax -= x[7]})
Else
   AEval(aFormCtrl, {|x| nValMax -= Round(xMoeda(x[7],x[8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)})
   aFormCtrlBkp := aClone(aFormCtrl)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for visualizaçao sintetizada utilizar o novo controle pelo ID do Cartão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisuSint .AND. lUsaTef .AND. lTefMult .AND. cForma$_FORMATEF
	nCtrl := AScan(aFormCtrl, {|x| x[1] == cForma .AND. x[9] == cFormaID} )
Else
	nCtrl := AScan(aFormCtrl, {|x| ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (x[1] == cForma)) .OR. ((x[1] == cForma) .AND. (x[2] == cDesc))})
EndIf

If (nCtrl > 0 .AND. !LjAnalisaLeg(13)[1])
	dData 		:= IIf(lFrtFormPag,dData,aFormCtrl[nCtrl][3])
	nNumParc	:= IIf(lFrtFormPag,nNumParc,aFormCtrl[nCtrl][4])
	nTXJuros	:= IIf(lFrtFormPag,nTXJuros,aFormCtrl[nCtrl][5])
	nIntervalo	:= IIf(lFrtFormPag,nIntervalo,aFormCtrl[nCtrl][6])
	nValor		:= IIf(lFrtFormPag,nValor,aFormCtrl[nCtrl][7])
	nValMax		:= nValor + nValMax
	If cPaisLoc <> "BRA"
	    nValMax		:= Iif(aFormCtrl[nCtrl][8]<>nMoedaCor,Round(xMoeda(nValor,aFormCtrl[nCtrl][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais),nValor) + nValMax
		nPosMoeda := aFormCtrl[nCtrl][8]
		cMoedaVen := aMoeda[nPosMoeda]
		cSimbMoeda:= SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda)))
		aCProva[nCtrl][1] := nValor
		aCProva[nCtrl][2] := nPosMoeda
		aCProva[nCtrl][3] := nValor
		aCProva[nCtrl][4] := cMoedaVen
		aCProva[nCtrl][5] := .F.
	EndIf
Else
	nCtrl 		:= 0
	If !lFrtFormPag .AND. lMVTELAFIN
		If cForma $ "CC|VA|CO|CD|FI|BO|BOL"
			aAreaSAE := GetArea("SAE")
			dbSelectArea("SAE")
			dbSetOrder(1)
			dbSeek(xFilial("SAE"))
			While !SAE->(EOF()) .AND. xFilial("SAE") == SAE->AE_FILIAL
				If AllTrim(SAE->AE_DESC) == cDesc
					dData	:= LJCalcVenc(.T., dDatabase)
					Exit
				EndIf
				SAE->(dbSkip())
			End
			If Empty(dData)
				dData := dDatabase
			EndIf
			RestArea(aAreaSAE)
		Else
			dData	:= dDataBase
		EndIf

		nNumParc	:= 1
		nTXJuros	:= 0
		nIntervalo	:= SuperGetMV("MV_LJINTER")  //Define o intervalo(em dias) DEFAULT entre as parcelas
		nValor		:= nValMax
	Else

		//Quando o PE FrtFormPag existe estas variaveis são atualizadas por ele.
		If !lFrtFormPag
			dData		:= dDataBase
			nNumParc	:= 1
			nTXJuros	:= 0
			nIntervalo	:= SuperGetMV("MV_LJINTER")  //Define o intervalo(em dias) DEFAULT entre as parcelas
			nValor		:= nValMax
		EndIf
	EndIf

	// se vier da opcao de simulacao de parcelamento
	If IsIncallStack("frta800") .AND. nParcSel > 0
		nNumParc	:= nParcSel
	EndIf

	If cPaisLoc <> "BRA"
		nPosMoeda := Int(nMoedaCor)
		cMoedaVen := aMoeda[nPosMoeda]
		cSimbMoeda:= SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda)))
		AAdd(aCProva,{nValor,nPosMoeda,nValor,cMoedaVen,.F.})
	EndIf
EndIf

If lFrtFormPag .AND. !Empty( aPgtos )
	nVlrAux := 0
	AEval( aPgtos,{|ExpA1| nVlrAux += ExpA1[2]} )
	If nVlrAux >= nVlrTotal
		// "Não é possível incluir mais Formas de Pagamento." ### "Atenção"
		HELP(' ',1,'FRT032')
		Return(.T.)
	EndIf
EndIf

If nValor <= 0
	// "Não é possível incluir mais Formas de Pagamento." ### "Atenção"
	HELP(' ',1,'FRT032')
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

If aRetFormPag[1]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a tela para alteracao das parcelas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Atualizacao do valor a Receber (nValor)
	nValor := nVlrTotal
	If len(aPgtos)>0
		aEval(aPgtos , {|x| nvalor -= x[2] } )
	Endif
	nValMax := nValor
	If nValor = 0
		HELP(' ',1,'FRT032') // "Não é possível incluir mais Formas de Pagamento." ### "Atenção"
		Return(.T.)
	Else
		// recupero as condições do orçamento
		If len(aPgtos)=0 .and. len(aParcOrcOld)>0
			For nCont:=1 to Len(aParcOrcOld)				
				nNumParc := Len(aParcOrcOld)
				Exit
			Next
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³HOMOLOGACAO - maximo de cartoes 3       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lHomolog
			For nCont:=1 to Len(aPgtos)
				If aPgtos[nCont][3] $ "CC|CD"
					nQtdCart++
			    EndIf
			Next nCont
			If nQtdCart == 3 .AND. cForma $ "CC|CD"
				MsgAlert(STR0088)//"Numero maxímo de cartões permitido."
				Return(.T.)
			EndIf
		EndIf

		Frtx272T03( 	@cForma		, @cSimbCheq	, @cDesc		, @dData	,;
						@nValor		, @nOpc			, @lUsaTef		, @lTefMult	,;
						@aMoeda		, @lUsaAdm		, @lRecebe		, @cFormaId	,;
						@nNumParc	, @nTXJuros		, @nIntervalo	, @nValMax	,;
						@cMoedaVen	, @nPosMoeda	, @cSimbMoeda	, @lDifCart	,;
						@aMultMoeda	, @aPgtos	    , @aValePre		, @aColsMAV ,;
 						@nPreDes	, @lGerFin		, @cCliPatr		, @aTxJurAdm ,;
 						@nArredondar )
	EndIf
Else
	nOpc := 1
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza valor com desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPreDes > 0
	If cPaisLoc == "BRA"
		nValDescPa 	:= NoRound((nPreDes * nValor / 100), 2)
		nValor 		-=  NoRound(nValDescPa, 2)
	Else
		nValDescPa 	:= Round((nPreDes * nValor / 100), MsDecimais(nPosMoeda))
		nValor 		-= Round(nValDescPa, MsDecimais(nPosMoeda))
	EndIf
EndIf

If nOpc == 1
	//Desconsidera desconto definido no orcamento, conforme regra nMvFrtDesc == 2
	If nVlrDescTot > 0 .AND. nMvFrtDesc == 2 .AND. Len(aParcOrcOld) > 0 ///Nao cancela desconto caso nao tenha alterado a forma de pagto (pressionou ESC), se alterar deve limpar aParcOrcOld(so deve guardar pagto do orc
		FR271FDescTot( 0				, 0				, .F.			, @oPgtosSint	,;
					@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		,;
					@nVlrTotal 		, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	,;
					@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		,;
					@aItens			, @nVlrMerc		, @lDescTotal	, @lDescSE4		,;
					@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	,;
					@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	,;
					@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	,;
					@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc  		,;
					@lRecalImp		, @aCols		, @aHeader		, cOrcam        ,;
					/*nPerDscRgr*/  , /*nValDscRgr*/, /*nValDescPa*/, /*lDesPatr*/	,;
					/*aTipoPagtoFor*/, /*nPosPagto*/, /*_cCliente*/	, /*_cLojaCli*/	,;
					/*lMultneg*/	, @aParcOrc     , @nVlrAcreTot  , @nVlrPercAcr  ,;
					@nVlrDescCPg    )
	EndIf

	//Apos confirmar alteracao na forma, limpa forma definida no orcamento nao permitindo mais restaurar
	aParcOrcOld := {}

	If cPaisLoc <> "BRA" .AND. IsMoney(cForma) .AND. cForma <> cSimbMoeda .AND. !Empty(aFormCtrl)
		If !MsgYesno(STR0060) //"E uma conversao para outra moeda?"
			nValAux	:= nVlrTotal
			AEval(aFormCtrl, {|x| nValAux -= Round(xMoeda(x[7],x[8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)})

			If nValAux <= 0
				// "Não é possível incluir mais Formas de Pagamento." ### "Atenção"
				HELP(' ',1,'FRT032')

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura os SetKey's do Fechamento da Venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTSetKey(aKey)
				Return(.T.)
			EndIf

			cForma := cSimbMoeda
			nCtrl  := 0
		EndIf
	ElseIf cPaisLoc <> "BRA" .AND. IsMoney(cForma) .AND. Empty(aFormCtrl)
		cForma := cSimbMoeda
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificando se o operador digitou o ID do cartão para processar a operação TEF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cPaisLoc == "BRA" .AND. Alltrim(cForma)$_FORMATEF .AND. lVisuSint .AND. lUsaTef .AND. lTefMult .AND. Empty(cFormaId)
		MsgAlert(STR0061,STR0002) //"Informe o ID do Cartão para a operação TEF.","Atenção"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		Return(.T.)
	EndIf

	If cPaisLoc == "BRA" .AND. IsMoney(cForma) .AND. nValor > nValMax
		If nCtrl > 0 .AND. IsMoney(aFormCtrl[nCtrl][1])
			// Vai somar o valor do dinheiro da outra parcela que ja foi concedido
			nValMax := nValMax + aFormCtrl[nCtrl][7]
		EndIf
		nTroco := nValor - nValMax
	EndIf

	If cPaisLoc == "BRA" .AND. !IsMoney(cForma) .AND. ((nValor > nValMax .AND. ExistBlock("FRTVMax")) .OR. ;
	                                                    (SL1->(FieldPos("L1_TROCO1")) > 0 .AND. ;
	                                                     (SuperGetMV("MV_LJTROCO", ,.F.) .And.;
	                                                     IIF (EMPTY(cMV_LJPGTRO) .Or. ( cForma   $ cMV_LJPGTRO ),.T. , .F.);
	                                                   )))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o calculo do Troco, se o o valor total da venda³
		//³for maior que o valor maximo permitido                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValor > nValMax
			nTroco := nTroco2 := nValor - nValMax
		EndIf
		If SL1->(FieldPos("L1_TROCO1")) <= 0 .OR. !SuperGetMV("MV_LJTROCO", ,.F.)
			nValor := nValMax
		EndIf
	EndIf

	If cForma == "DT" //Pagamento com Dotz 

		If 	aScan(aPgtos, {|x| x[3] == "DT" }) == 0
			
			cSeqTrans := StrZero(Val(FR271PegNuCup()), TamSx3("LG_COO") [1], 0) //Pega num cupom para iniciar a transacao de tef
	
			If ( Empty(cSeqTrans) .OR. Val(cSeqTrans) == 0 ) .And. FindFunction("F271TefNum")
				cSeqTrans := F271TefNum()
			EndIf
	
			oTEF:Operacoes("DOTZ_RESGATE",{{dDataBase,nValor}},,,cSeqTrans)	
	
			If oTEF:lTEFOk
				If oTef:aRetDotz[1]:nVlrResDotz > 0
					nValor := oTef:aRetDotz[1]:nVlrResDotz	//Altera para o valor recebido via Dotz
				EndIf	
			Else
				MsgStop(STR0154) //"Não foi possível realizar operação TEF Dotz."
				nValor := 0	
			EndIf
		Else
			MsgAlert(STR0155) //"Pagamento com Dotz já realizado."
			FRTSetKey(aKey)
			Return(.T.)
		EndIf	
	EndIf

	If cForma ="VA"
		If !( SL1->(FieldPos("L1_TROCO1")) > 0 .AND. (SuperGetMV("MV_LJTROCO", ,.F.) ) .And. IIF (EMPTY(cMV_LJPGTRO) .Or. ( cForma   $ cMV_LJPGTRO ),.T. , .F.) )
			nValor   := Min(nValor * nNumParc, nValMax)
			nNumParc := 1
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Cartao Fidelidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjcFid
		If AllTrim(cForma) =="FID"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cartao Fidelidade                                              ³
			//³Realiza Verificação do Cliente selecionado.                    ³
			//³Caso o Cliente tenha Cartao Fidelidade atrelado ao seu cadastro³
			//³exibe automaticamente o codigo na tela.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Ca280Exec("CA280CONCL" , Nil, 		Nil,Nil,;
								Nil, Nil, cLojaCli,Nil,;
 								Nil, cCliente)
			If Len(CA280GetAr()) > 0
				//Ler o Array com informacoes do Cartao Atrelado ao Cliente.
				cNumCFid := CA280GetAr()[1][1]
			EndIf
			If !(LaFunhPgto (,@cNumCFid,,nValor))
				Fa271FkFid ()
				Return (.F.)
			Endif
		EndIf
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O parametro MV_LJPAGTO retorna um valor inteiro. Pode ser      ³
		//³1 que irá indicar que a descrição da forma de pagto será a da  ³
		//³tabela 24 do SX5 ou 2, que será do cadastro de administradoras ³
		//³(SAE).                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (IsMoney(cForma) .OR. cForma == cSimbCheq) .OR. SuperGetMV("MV_LJPAGTO")==1
			nI := AScan(aFormPag, {|x| x[2]==cForma})
		Else
			nI := AScan(aFormPag, {|x| PadR(x[1],30)==PadR(cDesc,30)})
		EndIf
		If cPaisLoc == "BRA" .AND. IsMoney(cForma)
			cFormaPagto := aFormPag[nI][If(SuperGetMV("MV_LJPAGTO")==1,3,1)] + '|' + AllTrim(Str(nValor+nTroco,14,2))
		Else
			cFormaPagto := aFormPag[nI][If(SuperGetMV("MV_LJPAGTO")==1,3,1)] + '|' + AllTrim(Str(nValor,14,2))
		EndIf

		// Indica que sera emitido um cupom vinculado ao cupom fiscal emitido.
		// Especifico para impressora Urano versao 3.00
		If lUsaTef .AND. (cForma $ _FORMATEF+";"+cSimbCheq) .AND. (nValor > 0) .AND. ctipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_CLISITEF
			cVinculado := "1"
		EndIf

		If !lEmitNFCe .AND. !lUseSAT
			nRet := IFPagto(nHdlECF, cFormaPagto, cVinculado, nValor)
			If nRet <> 0
				// "Não foi possível registrar a forma de pagamento "###". Operação não efetuada.", "Atenção"
				MsgStop(STR0031+cDesc+STR0032, STR0002)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura os SetKey's do Fechamento da Venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTSetKey(aKey)
				Return(.T.)
			EndIf
		EndIf
	EndIf

	// Inicializando o aPgtos ou deletando a forma de pagamento já cadastrada
	If Len(aPgtos)=0
		aPgtos := {}
	Else
		nDel := 0
		For nI := 1 To Len(aPgtos)
			If ValType(aPgtos[nI]) == "A"
				If lVisuSint	//Considerar também o Id do Cartão qdo Multi-TEF
					If ( ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
						 (aPgtos[nI][3] == cForma .AND. !cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) )    .OR.  ;
					     (aPgtos[nI][3] == cForma .AND.  cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) ) .AND. AllTrim(aPgtos[nI][12]) == Alltrim(cFormaID) ) .AND. ;
					     !LjAnalisaLeg(13)[1]
						If SuperGetMV("MV_TEFPEND",,"0") == "1" //Se caso deletou alguma forma de pagamento por conta do cancelamento do TEF, deve somar o valor de dinheiro antes de ser deletado.
							nValor += aPgtos[nI][2]
						EndIf
						ADel(aPgtos, nI)
						nDel++
						nI--
					EndIf
				Else			//Mantém a verificação padrão
					If (((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
						(aPgtos[nI][3] == cForma) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) )) .AND. !LjAnalisaLeg(13)[1]
						ADel(aPgtos, nI)
						nDel++
						nI--
					EndIf
				EndIf
			EndIf
		Next nI
		If nDel > 0
			ASize(aPgtos, Len(aPgtos)-nDel)
		EndIf
	EndIf

	If nValor = 0
		If nCtrl > 0
			ADel(aFormCtrl, nCtrl)
			ASize(aFormCtrl, Len(aFormCtrl)-1)
		EndIf
	Else
		If nCtrl > 0
			aFormCtrl[nCtrl][3] := dData
			aFormCtrl[nCtrl][4] := nNumParc
			aFormCtrl[nCtrl][5] := nTXJuros
			aFormCtrl[nCtrl][6] := nIntervalo
			aFormCtrl[nCtrl][7] := nValor
			aFormCtrl[nCtrl][9] := cFormaID
			If cPaisLoc <> "BRA"
				aFormCtrl[nCtrl][8] := nPosMoeda
				If IsMoney(cForma)
					aFormCtrl[nCtrl][1] := aSimbs[nPosMoeda]
					nPosDesc := Ascan( aFormPag,{|x| Trim(x[2]) == aSimbs[nPosMoeda]})
					If nPosDesc > 0
			           aFormCtrl[nCtrl][2] := aFormPag[nPosDesc][1]
			        EndIf
				EndIf
				nValAux	:= nVlrTotal
				For nI := 1 To Len(aFormCtrl)
					If nI <> nCtrl
						nValAux -= Round(xMoeda(aFormCtrl[nI][7],aFormCtrl[nI][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
					EndIf
				Next nI
				nValAux := Round(xMoeda(nValAux,nMoedaCor,nPosMoeda,dDataBase,MsDecimais(nPosMoeda)+1),MsDecimais(nPosMoeda))

			    //Acerta os dados do array aCProva...
				aCProva[nCtrl][1] := nValor
				aCProva[nCtrl][2] := nPosMoeda
				aCProva[nCtrl][3] := nValAux
				aCProva[nCtrl][4] := aMoeda[nPosMoeda]
				aCProva[nCtrl][5] := (aCProva[nCtrl][1] < aCProva[nCtrl][3])
			EndIf
		Else
			If cPaisLoc == "BRA"
				AAdd(aFormCtrl, {cForma, cDesc, dData, nNumParc, nTXJuros, nIntervalo, nValor, NIL , cFormaID} )
			Else
				If IsMoney(cForma)
				    nPosDesc := Ascan( aFormPag,{|x| Trim(x[2]) == aSimbs[nPosMoeda]})
				ElseIf Trim(cForma) == "CH"
					nPosDesc := Ascan( aFormPag,{|x| Trim(x[2]) == cForma })
				Else
					//Qdo a forma de pgto eh diferente de cheque ou dinheiro eh necessario
					//pesquisar tambem o nome da administradora...
					nPosDesc := Ascan( aFormPag,{|x| Trim(x[1])==cDesc .AND. Trim(x[2])==cForma })
				EndIf
				If nPosDesc > 0
			       cDesc := aFormPag[nPosDesc][1]
			    EndIf
				If !(IsMoney(cForma))
					AAdd(aFormCtrl, {cForma, cDesc, dData, nNumParc, nTXJuros, nIntervalo, nValor, nPosMoeda, cFormaID} )
    			Else
					AAdd(aFormCtrl, {AllTrim(aSimbs[nPosMoeda]), cDesc, dData, nNumParc, nTXJuros, nIntervalo, nValor, nPosMoeda, cFormaID})
    			EndIf

				nValAux	:= nVlrTotal
				For nI := 1 To Len(aFormCtrl)-1
					nValAux -= Round(xMoeda(aFormCtrl[nI][7],aFormCtrl[nI][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
				Next nI

				nValAux := Round(xMoeda(nValAux,nMoedaCor,nPosMoeda,dDataBase,MsDecimais(nPosMoeda)+1),MsDecimais(nPosMoeda))
    			If Len(aCProva) == Len(aFormCtrl)
				    //Acerta os dados do array aCProva...
					aCProva[Len(aCProva)][1] := nValor
					aCProva[Len(aCProva)][2] := nPosMoeda
					aCProva[Len(aCProva)][3] := nValAux
					aCProva[Len(aCProva)][4] := aMoeda[nPosMoeda]
					aCProva[Len(aCProva)][5] := (aCProva[Len(aCProva)][1] < aCProva[Len(aCProva)][3])
				Else
					AAdd(aCProva,{nValor,nPosMoeda,nValAux,cMoedaVen,(nValor < nValAux)})
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracao do valor total da venda, acrescentando o valor do juros ao total ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aTxJurAdm) > 0
		   	If (lMvLjJurcc) .AND. (aTxJurAdm[1] > 0) .AND. (cForma $ _FORMATEF)
		   		nVlJurAdm		:= A410Arred(nValor * aTxJurAdm[1] / 100, "L2_VRUNIT")
				nValor			+= nVlJurAdm
				nVlrTotal 		+= nVlJurAdm
				aTxJurAdm[3]	+= nVlJurAdm
				oVlrTotal:Refresh()
			EndIf
		EndIf

		If cPaisLoc == "BRA"
			nValParc 	:= NoRound(nValor/nNumParc, 2)
			If nValDescPa > 0
				nVrDesL4	:= NoRound(nValDescPa/nNumParc, 2)
			EndIf
		Else
			If nNumParc > 1
				nValParc	:= Round(nValor/nNumParc		,MsDecimais(nPosMoeda))
				If nValDescPa > 0
					nVrDesL4	:= Round(nValDescPa/nNumParc	, MsDecimais(nPosMoeda))
				EndIf
			Else
				nValParc:= Round(nValor		,MsDecimais(nPosMoeda))
				If nValDescPa > 0
					nVrDesL4:= Round(nValDescPa, MsDecimais(nPosMoeda))
				EndIf
			EndIf
		EndIf
		nDif	:= Round(nValor - (nValParc * nNumParc),nDecimais)
		cAdm	:= ""
		If !(IsMoney(cForma) .OR. cForma == cSimbCheq)
			SAE->(dbGoTop())
			While ! SAE->(EOF()) .AND. xFilial("SAE") == SAE->AE_FILIAL
				If AllTrim(SAE->AE_DESC) == cDesc
					cAdm := SAE->AE_COD + " - " + SAE->AE_DESC
					Exit
				EndIf
				SAE->(dbSkip())
			End
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄD¿
		//³Incluida a 13 posicao como logica, para armazenar       ³
		//³o acrescimo financeiro separado, caso seja parametrizado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDÙ


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluida a 14 posicao para armazenar o Cpf/Cnpj do Cliente.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nI := 1 To nNumParc
			If cPaisLoc == "BRA"
				If !(IsMoney(cForma))
					AAdd(aPgtos, 		{dData + If(nI = 1,0,nIntervalo*(nI - 1)), nValParc, cForma, cAdm, "", "", "", "", "", .F., nPosMoeda , If(lVisuSint,cFormaID,Space(04)), 0,"",nVrDesL4, lGerFin, cCliPatr})
				Else
					//Se ja existir forma de pagamento dinheiro, soma valores
					If (nPos := AScan(aPgtos, {|x| x[3]==AllTrim(cForma)})) > 0
						aPgtos[nPos][2] += nValParc
					Else
						AAdd(aPgtos, 		{dData + If(nI = 1,0,nIntervalo*(nI - 1)), nValParc, cForma, cAdm, "", "", "", "", "", .F., nPosMoeda , If(lVisuSint,cFormaID,Space(04)), 0,"",nVrDesL4, lGerFin, cCliPatr})
					EndIf
				EndIf
			Else
				If !(IsMoney(cForma))
					AAdd(aPgtos, {dData + If(nI = 1,0,nIntervalo*(nI - 1)), nValParc, cForma, cAdm, "", "", "", "", "", .F., nPosMoeda , If(lVisuSint,cFormaID,Space(04)), 0,"",nVrDesL4, lGerFin, cCliPatr})
				Else
					AAdd(aPgtos, {dData + If(nI = 1,0,nIntervalo*(nI - 1)), nValParc, AllTrim(aSimbs[nPosMoeda]), cAdm, "", "", "", "", "", .F., nPosMoeda, If(lVisuSint,cFormaID,Space(04)), 0,"", nVrDesL4, lGerFin, cCliPatr })
				EndIf
			EndIf
		Next nI
		If cPaisLoc == "BRA" .OR. (cPaisLoc <> "BRA" .AND. Len(aPgtos) == 1)
			aPgtos[Len(aPgtos)][2] += nDif
		Else
			aPgtos[Len(aPgtos)][2] := Round(aPgtos[Len(aPgtos)][2]+nDif,nDecimais)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A Forma $ sempre sera a primeira!!!  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nCtrl:=AScan(aPgtos, {|x| x[3] == cSimbCor})) > 1
		AAdd(aPgtos, {})
		AIns(aPgtos, 1)
		nCtrl++
		aPgtos[1] := aPgtos[nCtrl]
		ADel(aPgtos, nCtrl)
		ASize(aPgtos, Len(aPgtos)-1)
	EndIf

	If nTroco > 0
		oCupom:AppendText((STR0033+Transform(nTroco,PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)))+ chr(10) + chr(13))	// "          TROCO          "
	EndIf

	If lUsaDisplay
		If !FR271HVlPar(	@nVlrTotal	, @aPgtos	, @nMoedaCor	,;
							@nDecimais	, nTaxaMoeda )
	   		DisplayEnv(StatDisplay(), "2E" + Upper(STR0062) + Upper(cDesc) + ": " + Str(nValor,8,2) )         //"Valor Em ###:"
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se utiliza múltiplas transações Tef e selecionou a opção de parcelar |
	//| em <>s cartoes solicitar os 4 ultimos de cada cartao                 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lVisuSint .AND. lUsaTef .AND. lTefMult .AND. lDifCart
	   FR271ITefDig(@aPgtos	, @aCols)
	EndIf

	oPgtos:SetArray(aPgtos)
	oPgtos:Refresh()

	If lVisuSint
		aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1]
		If cForma == cSimbCheq
			aCheques := {}
			aParcelas := AClone(aPgtos)
			For nI := 1 to Len(aParcelas)
				If AllTrim(aParcelas[nI][3]) == cSimbCheq
					AAdd(aCheques,{aParcelas[nI][1], aParcelas[nI][2], aParcelas[nI][3],;
								   aParcelas[nI][4], aParcelas[nI][5], aParcelas[nI][6],;
								   aParcelas[nI][7], aParcelas[nI][8], aParcelas[nI][9]})
				EndIf
			Next nI
			If SuperGetMV("MV_INFCHEQ")
				aDadosCh := LjxDGetCh(	GetWndDefault()	, @cDoc		 	, @aCheques		, @cCliente	,;
								  		@cLojaCli		, @aParcelas	, @lUsaDisplay)
			EndIf
		EndIf
	EndIf
Else
    //Quando importou o orcamento e cancelou a alteracao na forma de pagto, restaura valores
	If Len(aParcOrcOld) > 0
		aParcOrc := aParcOrcOld
		aParcOrcOld := {}
		nVlrTotal := (nVlrBruto - nVlrDescTot) //Restaura valor total com desconto
	EndIf

	//Caso o usuario nao confirme a parcela apaga os valores da tabela de
	//contra-prova...
	If cPaisLoc <> "BRA" .AND. Empty(aFormCtrl)
		ADel(aCProva, Len(aCProva))
		ASize(aCProva, Len(aCProva)-1)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)
// Caso o array aPgtos esteja valorizado permite que o objeto oPgtos seja
// editado pelo usuario, caso contrario desabilita o objeto...
If !Empty(aPgtos)
	oPgtos:Enable()
	If lVisuSint
		oPgtosSint:Enable()
		oPgtosSint:SetFocus()
	EndIf
Else
	oPgtos:Disable()
	If lVisuSint
		oPgtosSint:Disable()
		oPgtosSint:SetFocus()
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271FDescTot³ Autor ³ Vendas Clientes    ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Desconto no Total da Venda (F6)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271FDescTot(	nTmpJuros	, nTmpDesc		, lExTela		, oPgtosSint	,;
						aPgtosSint 	, oPgtos		, aPgtos		, oCupom		,;
						nVlrTotal 	, nVlrBruto		, nVlrDescTot	, oVlrTotal		,;
						nEntrada	, nTaxaMoeda	, lRecebe		, dDataCN 		,;
						aItens		, nVlrMerc		, lDescTotal	, lDescSE4		,;
						nTotDedIcms	, nVlrPercTot	, nMoedaCor		, nDecimais		,;
						aImpsSL1	, aImpsSL2		, aImpsProd		, aDadosJur		,;
						aFormCtrl	, cItemCond		, lCondNegF5	, lDescEspec	,;
						nTxJuros	, nValorBase	, lDiaFixo		, lImpOrc		,;
						lRecalImp	, aCols			, aHeader		, cOrcam		,;
						nPerDscRgr	, nValDscRgr	, nValDescPa	, lDesPatr		,;
						aTipoPagtoFor, nPosPagto   	, _cCliente		, _cLojaCli		,;
						lMultneg	, aParcOrc      , nVlrAcreTot   , nVlrPercAcr   ,;
						nVlrDescCPg , lTela		  , aReserva		, nDescToP)

Local nValorDesc	:= 0				// Variavel que contem o valor do desconto
Local nPercDesc		:= 0				// Variavel que contem o percentual do desconto
Local aKey			:= {}				// SetKey's do Fechamento da Venda
Local nOpc			:= 0				// Variavel que determina qual botao foi escolhido da dialog do desconto
Local nI			:= 0				// Utilizada em loop
Local nTotImp 		:= 0				// Total de impostos
Local lImpsDisc 	:= .F. 				// Determina se existe algum impostos discriminado na venda - Localizacoes
Local nVlrAux 		:= 0				// Localizacoes
Local nVlrMercAux	:= 0				// Localizacoes
Local aRet        	:= {}				// Utilizada para o recalculo das parcelas
Local cFormaId		:= " "				// Id utilizado como identificador das parcelas
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local lVisuSint  	:= If(SL4->(ColumnPos("L4_FORMAID"))>0,.T.,.F.) 	// Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local aRetNeg 		:= {} 												// Localizacoes
Local nDifOrc       := 0                // Valor de desconto ja aplicado no orcamento
Local lPermitDesc	:= IIf(SuperGetMV("MV_FRTDESC",,2) == 2, .F., .T.)	// Valida se permite desconto em um orçamento importado

//Realiza backup da valores de desconto ja concedido para validacoe
Local nPercBkp      := 0
Local nValBkp      	:= 0
Local nValRgrBkp	:= 0
Local nPerRgrBkp	:= 0

Local nParcDesc     := 0                // Desconto nas parcelas
Local nLastPDesc    := 0                // Desconto na ultima parcela
Local lDescRegra	:= .F.				// Indica se ha desconto por regra de negocio
Local lCenVenda		:= SuperGetMv("MV_LJCNVDA",,.F.)	// Indica a integracao com o cenario de vendas
Local nCont         := 0                // Variavel contador
Local aFPagtoRegra	:= {}				// aFPagtoRegra
Local nDescTotal	:= 0				// nDescTotal
Local nDescForm		:= 0				// nDescForm
Local nVlDesc		:= 0 				// nVlDesc
Local nVlrAPaga		:= 0				// Valor restante a pagar sera calculado com aPagtos        /
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacao                      ³
//³Paises: Chile/Colombia - F1CHI                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5 		:= cPaisLoc$"CHI|COL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

Local lAltDesc	  := !lNovRegDesc 		//Devido a nova regra de desconto, chama rotina de desconto antes definir o pagto (Ex.: CTRL+A), deve sinalizar se houve modificacao no valor do desconto para atualizacao
Local nValFret		:= ( SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA)
Local nValorD1		:= 0						// valor do frete proporcionado no cupom não fiscal
Local cSupervisor	:= Space(25)

/*Seta Multinegociação através do parametro informado
na chamada da Função.                           */
DEFAULT lMultneg 		:= .F.				//lMultneg

DEFAULT aTipoPagtoFor 	:= {}				// aTipoPagtoFor
DEFAULT lExTela			:= .T.  			// lExTela
DEFAULT nPerDscRgr  	:= 0		   		// nPerDscRgr
DEFAULT nValDscRgr 		:= 0				// nValDscRgr
DEFAULT nValDescPa		:= 0 		  		// nValDescPa
DEFAULT lDesPatr		:= .F.	 			// lDesPatr
DEFAULT _cCliente		:= ""		  		// _cCliente
DEFAULT _cLojaCli		:= ""		 		// _cLojaCli
DEFAULT aParcOrc 		:= {}
DEFAULT nVlrAcreTot     := 0
DEFAULT nVlrPercAcr		:= 0
DEFAULT nVlrDescCPg		:= 0
DEFAULT lTela			:= .T.
DEFAULT aReserva		:= {}
DEFAULT nDescToP		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for chamada da rotina de recebimento, retorna sem fazer nada      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe .OR. (lDesPatr .AND. nValDescPa == 0)
	Return NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializacao das variaveis                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFormaId	:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))

If lCenVenda
	lDescRegra	:= (nPerDscRgr <> 0 ) .OR. (nValDscRgr <> 0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o caixa pode executar descontos quando a integracao³
	//³com o cenario de vendas esta ativa                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !IsInCallStack("Frt271ERegDsc") .AND. lCenVenda .AND. !LjOpcDesc()
		MsgStop(STR0081) //"A configuração do caixa atual não permite fornecer descontos, pois prioriza o desconto proveniente das regras de desconto do cenário de vendas"
		Return NIL
	EndIf
EndIf

If !LJProfile(11,@cSupervisor)
	MsgStop("Usuário não tem permissão para descontos")
	Return NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum imposto discriminado na venda               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisloc <> "BRA"

	For nCont := 1 to Len(aItens)
		If !aItens[nCont][AIT_CANCELADO]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Localizacoes                                   ³
			//³Calcular desconto sobre o valor unitario do item,sem impostos.³
			//³Paises: Chile/Colombia  - F1CHI                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLocR5
				If  !aItens[nCont][AIT_IMPINCL]
					nVlrAux += Round(aItens[nCont][AIT_QUANT]*aItens[nCont][AIT_VRUNIT],nDecimais)
				Else
					nVlrAux += Round(aItens[nCont][AIT_QUANT]*aItens[nCont][AIT_VLRITEM],nDecimais)
				EndIf
			Else
				If  aItens[nCont][AIT_IMPINCL]
					nVlrAux += Round(aItens[nCont][AIT_QUANT]*aItens[nCont][AIT_VRUNIT],nDecimais)
				Else
					nVlrAux += Round(aItens[nCont][AIT_QUANT]*aItens[nCont][AIT_VLRITEM],nDecimais)
				EndIf
			EndIf
		EndIf
	Next nCont

	nVlrMercAux := If( cItemCond=="CN" .AND. !lCondNegF5,nVlrAux,nVlrMerc ) + aDadosJur[1]

	For nI := 1 To Len( aImpsSL1 )
		If aImpsSL1[nI][6] <> "3"
			lImpsDisc := .T.
			Exit
		EndIf
	Next nI

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Setkey's do fechamento da venda                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta mensagem so aparece na forma padrao de selecao de parcelas(CTRL+?)³
//³Caso seja selecionada Condicao de Pagamento ou Condicao Negociada,     ³
//³Aparece o "Chorinho", que eh rateado.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (( cItemCond=="CN" .AND. !lCondNegF5 .AND. Len( aPgtos ) > 0 ) .OR. ( lImpsDisc .AND. Len( aPgtos ) > 0 )) .AND. (!lDesPatr)  .AND. !lNovRegDesc .OR. (Len( aPgtos ) > 0 .AND. aPgtos[1][10])
	If lDescRegra .OR. MsgYesNo(STR0034, STR0002) // "Já foram definidas Formas de Pagamento para esta venda. Se optar pelo Desconto no Total do Cupom, será necessário definí-las novamente. Continua?"

		If !lMultNeg
			aPgtos		:= {}
			aFormCtrl	:= {}
		EndIf

		If oPgtos <> Nil
			oPgtos:SetArray( aPgtos )
			oPgtos:Refresh()
		EndIf

		If lVisuSint
			aPgtosSint:=Fr271IMontPgt( @aPgtos	, @nMoedaCor )
			If oPgtosSint <> Nil
				oPgtosSint:SetArray( aPgtosSint )
				oPgtosSint:Refresh()
			EndIf
		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey( aKey )
		Return( NIL )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PE para controlar o Desconto no Total. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRTDescTOT")
	If ! ExecBlock("FRTDescTOT",.F.,.F.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey( aKey )
		Return( NIL )
	EndIf
EndIf

//Realiza backup dos descontos
nPercBkp 	:= nVlrPercTot
nValBkp	:= nVlrDescTot
nPerRgrBkp	:= nPerDscRgr
nValRgrBkp	:= nValDscRgr

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o desconto no total do item pode ser concedido, de acordo com os estados que entram na Lei|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ( LjAnalisaLeg( 14 )[1] .AND. !lDescTotal .AND. !lDescSE4 ) .OR.;
   	   ! ( LjAnalisaLeg( 14 )[1] ) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando utilizado NCC, a tecla F6 será desabilitada, Esta sendo tratado no fonte FRTA060.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Frt060Ret("NCC_USADA") > 0
		//Quando utiliza nova regra de desconto, rotina eh chamada de forma automatica, realiza tratamento para nao apresentar mensagem, porem, mantendo o legado nao realiza o desconto da regra quando possui NCC
		If !lNovRegDesc
			MsgAlert(STR0071)    //"Nao será permitido utilizar F6 quando utilizada NCC."
		End
	Else
		If nValDescPa > 0

			Frtx272T09( @nValorDesc	, @nPercDesc	, @nOpc			, @nVlrMercAux	,;
						@nVlrTotal	, @nTotDedIcms	, @nVlrBruto	, @nMoedaCor	,;
						aItens		, nVlrDescTot	, nVlrPercTot	, nPerDscRgr	,;
						nVlrDescTot + nValDescPa, .T.)

			If lUsaDisplay
				FR271HVlPar(	@nVlrTotal	, @aPgtos	, @nMoedaCor	,;
								@nDecimais	,nTaxaMoeda )
				DisplayEnv(StatDisplay(), "2C" + Upper(Substr(STR0063, 1, 21 )) )         //"Escolha a(s) forma(s) de pagamento"
				DisplayEnv(StatDisplay(), "3C" + Upper(Substr(STR0063, 23)) )         //"Escolha a(s) forma(s) de pagamento"
				DisplayEnv(StatDisplay(), "***")
			EndIf

		ElseIf lExTela
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No caso de importação de Orcamento        ³
			//³faz o carregamento do desconto ja efetuado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lImpOrc .AND. (nVlrDescTot > 0 .AND. nVlrPercTot > 0)
				nValorDesc:= nVlrDescTot
				nPercDesc := nVlrPercTot
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aplica regra de desconto por forma de pagto.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (Len(aTipoPagtoFor) > 0) .And. (nPosPagto > 0) .And. lNovRegDesc

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula o valor restante para pagamento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   	If Len(aPgtos) > 0
	   				For nI := 1 to Len(aPgtos)
	   					If AllTrim(aTipoPagtoFor[nPosPagto][2]) <> AllTrim(aPgtos[nI][3])
							nVlrAPaga += aPgtos[nI][2]
						EndIf
					Next nI
					nVlrAPaga := nVlrTotal - nVlrAPaga
				Else
					nVlrAPaga := nVlrMerc
				EndIf

				aFPagtoRegra := {}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Esta chama valida a regra pelo total, pois  ³
				//³ os desconto sao zerados a cada troca de    ³
				//³ forma de pagto.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If FindFunction("RGDesTol") //Loja 3025
					nDescTotal := RGDesTol(	.F.			, nVlrAPaga ,			,		,;
											_cCliente	, _cLojaCli	, nVlrTotal)
				Endif

                If nDescTotal > 0
                	lAltDesc	:= .T.
                	nVlDesc	  	:= ((nDescTotal / 100) * nVlrAPaga)
                	nVlrTotal 	:= nVlrAPaga - ((nDescTotal / 100) * nVlrAPaga)
                	nPerDscRgr 	:= nDescTotal
                	nValDscRgr 	:= nVlDesc
                EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Esta chama valida a regra pela forma, pois  ³
				//³ os desconto sao zerados a cada troca de    ³
				//³ forma de pagto.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    aFPagtoRegra := {}
			    If Len(aPgtos) > 0
			    	For nI := 1 To Len(aPgtos)
			    		AADD(aFPagtoRegra,{CTOD(" "),	aPgtos[nI][2],aPgtos[nI][3]})
			    	Next nI
			    EndIf
				AADD(aFPagtoRegra	,{CTOD(" "),nVlrAPaga,aTipoPagtoFor[nPosPagto][2]})

				If FindFunction("RGDesTol") //Loja 3025
					nDescForm := RGDesTol( .T.			, nVlrAPaga  	, aTipoPagtoFor[nPosPagto][2], aFPagtoRegra ,;
					                        _cCliente	, _cLojaCli		, nVlrMerc, aTipoPagtoFor[nPosPagto][2] ) 
				Endif

				If (nDescTotal == 0)	.AND. (nDescTotal > 0 .OR. nDescForm > 0)
					nVlrTotal  	:= 	nVlrMerc
					nVlrBruto	:=  nVlrTotal
					nValDscRgr 	:= ((nDescForm / 100) * nVlrTotal)
					nPerDscRgr	:= 	nDescForm
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o desconto por gerado pelas duas opcoes  ³
				//³ vai carregar as variaveis com os valores   ³
				//³ corretos.                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nDescTotal > 0 .AND. nDescForm > 0)
					nValDscRgr	:= (nVlDesc + nValDscRgr)
			   		nPerDscRgr  := ((nValDscRgr * 100) /nVlrBruto)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama a tela de desconto, porem nao carrega a tela por ja  ³
				//³  ter o % e R$ de desconto a ser aplicado, entao aplicar o ³
				//³  desconto no total da venda.                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nValDscRgr > 0) .Or. (nPerDscRgr > 0)
					Frtx272T09( @nValorDesc	, @nPercDesc	, @nOpc			, @nVlrMercAux	,;
								@nVlrTotal	, @nTotDedIcms	, @nVlrBruto	, @nMoedaCor	,;
								@aItens		, @nVlrDescTot	, @nVlrPercTot	, @nPerDscRgr	,;
								@nValDscRgr	, lNovRegDesc)

					If lUsaDisplay
						FR271HVlPar(	@nVlrTotal	, @aPgtos	, @nMoedaCor	,;
										@nDecimais	,nTaxaMoeda )
						DisplayEnv(StatDisplay(), "2C" + Upper(Substr(STR0063, 1, 21 )) )         //"Escolha a(s) forma(s) de pagamento"
						DisplayEnv(StatDisplay(), "3C" + Upper(Substr(STR0063, 23)) )         //"Escolha a(s) forma(s) de pagamento"
						DisplayEnv(StatDisplay(), "***")
					EndIf
				EndIf

			Else

				// Para zerar os acrescimos financeiros e fretes
			   	IF lDescSE4 .AND. nVlrMerc <> nVlrBruto  // tem acrescimo Financeiro  e o valor bruto tem que voltar ao original
					nVlrBruto := nVlrMerc
			   	EndIf

			   	// Para o desconto não pode considerar o valor do frete , pois o desconto é somente em cima do total da venda
			   	// nao Necessario verificar se importacao, pois quando adicionado item retina no front, a variavel lImpOrc fica false
				// e frete nunca deve ser considerado no desconto total
			   	If nValFret > 0
					nVlrBruto -= nValFret
					nVlrTotal -= nValFret
				EndIf

				If !lPermitDesc .AND. lImpOrc
					MsgAlert(STR0133)		// Não é permitido conceder desconto para orçamento importado. (MV_FRTDESC)
				Else
					//Chama a tela de desconto
					Frtx272T09( 	@nValorDesc	, @nPercDesc		, @nOpc			, @nVlrMercAux	,;
									@nVlrTotal		, @nTotDedIcms	, @nVlrBruto		, @nMoedaCor		,;
									@aItens		, @nVlrDescTot	, @nVlrPercTot	, @nPerDscRgr		,;
									@nValDscRgr	, lTela)
				EndIf

				// Proporcionaliza o desconto entre os cupons
				If nValorDesc > 0 .And. Len(aReserva) > 0
					For nI := 1 to Len(aReserva)
						nValorD1 += aReserva[nI][8]
					Next nI
					nValorD1 := nValorDesc * (nValorD1 / nVlrTotal)
				EndIf
				nDescToP := nValorD1

				If lUsaDisplay
					FR271HVlPar(	@nVlrTotal	, @aPgtos	, @nMoedaCor	,;
									@nDecimais	,nTaxaMoeda )
					DisplayEnv(StatDisplay(), "2C" + Upper(Substr(STR0063, 1, 21 )) )         //"Escolha a(s) forma(s) de pagamento"
					DisplayEnv(StatDisplay(), "3C" + Upper(Substr(STR0063, 23)) )         //"Escolha a(s) forma(s) de pagamento"
					DisplayEnv(StatDisplay(), "***")
				EndIf
				
				// Volta o valor do frete nos valores de desconto
				If nValFret > 0
				   	nVlrBruto	+=	nValFret
				   	nVlrTotal	+=	nValFret
				EndIf
			EndIf

			//Devido a nova regra de desconto, chama rotina no momento de definir o pagto (Ex.: CTRL+A), deve sinalizar se houve modificacao no valor do desconto
			If !lAltDesc
				lAltDesc := IIF(lAltDesc .OR. (nPercBkp <> nPercDesc) .OR. (nValBkp <> nValorDesc),.T.,.F.)
			EndIf
		EndIf

		If lAltDesc .AND. (nOpc == 1 .OR. !lExTela)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alteracao especifica para atender a legislacao do SEFAZ              ³
			//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
			//³ Para o estado de MG nao eh necessario este passo, mas por impedimento³
			//³ tecnico este passo deverah ser realizado (Nao eh possivel registrar  ³
			//³ desconto depois da forma de pagamento)                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LjAnalisaLeg(14)[1]
				If nValorDesc > 0
					nRet := IFDescTot(nHdlECF, AllTrim(Str(( nValorDesc - nValorD1 ),14,2)))
					If nRet <> 0
						HELP(' ',1,'FRT033')	// "Não foi possível registrar o Desconto no Total do Cupom. Operação não efetuada.", "Atenção"
						nOpc := 0
					Else
						oCupom:AppendText(PadL((FRT_SEPARATOR),39))
						oCupom:AppendText((PadL(STR0013,39)))			// "Desconto no total do cupom"
						oCupom:AppendText((PadL(STR0014,39)))			// "Valor / Percentual"
						oCupom:AppendText((PadL(Trans(( nValorDesc - nValorD1 ),PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nPercDesc,"@E 99.99")+"%",50))+ chr(10) + chr(13))
						oCupom:AppendText(PadL((FRT_SEPARATOR),39))
						lDescTotal := .T.								// Seta que o desconto no total da venda foi concedido
					EndIf
				EndIf
			Else
				If nValorDesc == 0
					oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
					oCupom:AppendText((STR0015)+ chr(10) + chr(13))	// "Desconto no total do cupom : CANCELADO"
					oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
				Else
					oCupom:AppendText(PadL((FRT_SEPARATOR),39))
					oCupom:AppendText((PadL(STR0013,39)))			// "Desconto no total do cupom"
					oCupom:AppendText((PadL(STR0014,39)))			// "Valor / Percentual"
					oCupom:AppendText((PadL(Trans(nValorDesc,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nPercDesc,"@E 99.99")+"%",39))+ chr(10) + chr(13))
					oCupom:AppendText(PadL((FRT_SEPARATOR),39))
				EndIf
			EndIf

			If nOpc == 1 .OR. !lExTela
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja Desconto Especial ("Chorinho"), este sera rateado nas parcelas  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cItemCond=="CN" .AND. !lCondNegF5) .OR. lImpsDisc
					lDescEspec := .F.
					nVlrDescTot	:= nValorDesc
					nVlrPercTot	:= nPercDesc
					If lDesPatr
						If cPaisLoc == "BRA"
							nVlrTotal := (nVlrBruto - nTotDedIcms) - nVlrDescTot
						Else
							nVlrTotal := nVlrBruto- nVlrDescTot
						EndIf
					ElseIf cPaisLoc == "BRA"
						nVlrTotal := (nVlrBruto - nTotDedIcms) - nVlrDescTot
					Else
						//"Fazendo o calculo	 do desconto e o recalculo dos impostos..."
						LJMsgRun(STR0035,,{|| FR271ICDescLoc(	nValorDesc	, nPercDesc	, nTmpJuros		, nTmpDesc		,;
															@nVlrBruto	, @nVlrMerc	, @ nMoedaCor	, @nDecimais	,;
															@aImpsSL1	, @aImpsSL2	, @aImpsProd	, @lRecalImp 	,;
															@aCols		, @aHeader	, @aDadosJur	, @cItemCond	,;
															@lCondNegF5	, cOrcam	, oVlrTotal		, @nVlrTotal 	)})
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Realiza o recalculo das parcelas...                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lCondNegF5

							FR271HNegCond ( @nValorBase	, @nVlrBruto	, @nEntrada	, @aPgtos	,;
											@nMoedaCor	, @nTaxaMoeda	, @aRetNeg	, @nTxJuros	,;
											@dDataCN	, @nTotDedIcms	, @lDiaFixo	)

							If Len(aRetNeg)>0
								nTXJuros   := aRetNeg[6][1]
								aRet := AClone(LJ7CalcPgt(	nVlrTotal		,;
															cItemCond		,;
															{aRetNeg[1][1], aRetNeg[4][1], aRetNeg[5][1], aRetNeg[6][1], aRetNeg[7][1], aRetNeg[8][1], .F.},;
															Nil				,;
															@nTmpJuros		,;
															@nTmpDesc		,;
															nMoedaCor		,;
															Nil				,;
															Nil				,;
															@nMoedaCor		,;
															@nDecimais))
						  	EndIf
						ElseIf !(cItemCond $ "CN")
							aRet := AClone(LJ7CalcPgt(	nVlrTotal	,;
														cItemCond	,;
														Nil			,;
														Nil			,;
														@nTmpJuros	,;
														@nTmpDesc	,;
														nMoedaCor	,;
														Nil			,;
														Nil			,;
														@nMoedaCor	,;
														@nDecimais))
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso tenha acrescimo ou desconto financeiro eh necessario         ³
						//³ recalcular o valor total da venda...                              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aRet) > 0
							If (nTmpJuros > 0) .OR. (nTmpDesc > 0)
								nVlrTotal := ((nVlrTotal-aDadosJur[6]) + (aDadosJur[4]+aDadosJur[1]-aDadosJur[9]))
							EndIf
							For nI := 1 to Len(aRet)
								cFormaID := If(AllTrim(aRet[nI][3])$_FORMATEF,"1",cFormaId)
								AAdd( aPgtos, { aRet[nI][1], NoRound(aRet[nI][2],nDecimais), AllTrim(aRet[nI][3]), "", "", "", "", "", "", .F., nMoedaCor, If(lVisuSint,cFormaID,Space(04)),0,"" })
							Next nI
						EndIf
						oPgtos:SetArray(aPgtos)
						oPgtos:Refresh()

						If lVisuSint
							aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
							oPgtosSint:SetArray( aPgtosSint )
							oPgtosSint:Refresh()
						EndIf

					EndIf
				Else
					lDescEspec  := .T.
					nVlrDescTot	:= nValorDesc
					nVlrPercTot	:= nPercDesc
					If cPaisLoc == "BRA"
						nVlrTotal	:= (nVlrTotal - nTotDedIcms) - nVlrDescTot
					Else
						//"Fazendo o calculo do desconto e o recalculo dos impostos..."
						LJMsgRun(STR0035,,{|| FR271ICDescLoc(	nValorDesc	, nPercDesc	, nTmpJuros		, nTmpDesc		,;
															@nVlrBruto	, @nVlrMerc	, @nMoedaCor	, @nDecimais	,;
															@aImpsSL1	, @aImpsSL2	, @aImpsProd	, @lRecalImp	,;
															@aCols		, @aHeader	, @aDadosJur	, @cItemCond	,;
															@lCondNegF5 , cOrcam	, oVlrTotal		, @nVlrTotal	)})
					EndIf

					//Calcular a diferenca do desconto ja que e' permitido dar mais de
					//um desconto quando for um orcamento e nao for condicao negociada.
					If !lMultneg
						If lImpOrc
							nDifOrc	:= NoRound( nVlrBruto * nPercBkp / 100, nDecimais )
							nParcDesc	:= 0
							nLastPDesc	:= 0
							If nVlrPercTot <> nPercBkp
								nParcDesc   := NoRound(nValorDesc / Len(aPgtos), nDecimais)				// Desconto nas parcelas
								nLastPDesc  := nParcDesc + (nValorDesc - (nParcDesc * Len(aPgtos)))		// Desconto e Rateio na Ultima
								nParcDesc   := nParcDesc - nDifOrc
							EndIf
						Else
							nParcDesc   := NoRound(nValorDesc / Len(aPgtos), nDecimais)				// Desconto nas parcelas
							nLastPDesc  := nParcDesc + (nValorDesc - (nParcDesc * Len(aPgtos)))		// Desconto e Rateio na Ultima
						EndIf

						// se a divisao das parcela não tiver resto , divide em parcelas iguais
						If !Mod((nVlrTotal),Len(aPgtos)) == 0 .AND. Len(aPgtos) > 0

							For nI := 1 To Max(Len(aPgtos)-1, 1)
								aPgtos[nI][2] -= nParcDesc
							Next nI
							If Len( aPgtos ) > 1
								aPgtos[Len(aPgtos)][2] -= nLastPDesc
							EndIf

						Else

							For nI := 1 To Len(aPgtos)
								aPgtos[nI][2] := (nVlrTotal)/Len(aPgtos)
							Next nI

						EndIf

						//Atualiza os pagamentos na tela do Front
						If lVisuSint
							aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
							If !lDescRegra
								oPgtosSint:SetArray( aPgtosSint )
								oPgtosSint:Refresh()
							EndIf
						EndIf
						// se o orçamento importado , limpa as variaveis e condições da importação
	                 	// mas mantem o frete
						If lImpOrc .AND. Len(aParcOrc) > 0

							cItemCond  	:= "CN"
							lCondNegF5 	:= .F.
							aParcOrcOld := aParcOrc
							aParcOrc   	:= {}
							aPgtos     	:= {}

							oPgtos:SetArray(aPgtos)
							If lVisuSint
								aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
								oPgtosSint:SetArray( aPgtosSint )
								oPgtosSint:Refresh()
							EndIf

							nVlrAcreTot := nValFret	// Deixa somentes as despesas
							nVlrPercAcr := 0			// Zera o percentual de Acrescimo Financeiro
							nVlrDescCPg := 0			// Zera o Desconto Financeiro

							If !lTouch
								oVlrTotal :Refresh()
							Endif

						EndIf

				    EndIf

				EndIf
				If cPaisLoc <> "BRA"  //Reimprime os impostos devido ao desconto
					AEval(aImpsSL1,{|x,y| nTotImp += aImpsSL1[y][3]})
					oCupom:AppendText(( STR0005 + Trans( nVlrTotal - nTotImp, PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor ) ) )+ chr(10) + chr(13))  //"     S U B T O T A L      "

					SFB->( DbSetOrder(1) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Reimpressao dos impostos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nI := 1 To Len( aImpsSL1 )
						SFB->( DbSeek( xFilial( "SFB" ) + aImpsSL1[nI][1] ) )
						oCupom:AppendText(( Space(05) + SubStr( SFB->FB_DESCR,1,10 ) + Space(11) + Trans( aImpsSL1[nI][3],PesqPict("SL1",aImpsSL1[nI][2],13,nMoedaCor ) ) ) + chr(10) + chr(13))
					Next nI
				EndIf


				If lUsaDisplay
					FR271HVlPar(	@nVlrTotal	, @aPgtos	, @nMoedaCor	,;
									@nDecimais	,nTaxaMoeda )
					DisplayEnv(StatDisplay(), "2C" + Upper(Substr(STR0063, 1, 21 )) )         //"Escolha a(s) forma(s) de pagamento"
					DisplayEnv(StatDisplay(), "3C" + Upper(Substr(STR0063, 23)) )         //"Escolha a(s) forma(s) de pagamento"
					DisplayEnv(StatDisplay(), "***")
				EndIf
				If !lTouch
					oVlrTotal:Refresh()
				Endif
			EndIf
		EndIf
	Endif
Else
	MsgAlert(STR0064 ,STR0002) //""Já existe desconto na condição de pagamento, não será permitida inclusão de novo desconto no total da venda".","Atenção"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271FCanc³ Autor ³Vendas Clientes        ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelar o Cupom Fiscal (F8)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271FCancCup(	lCancTef		, oHora			, cHora			, oDoc			,;
						cDoc			, oCupom		, cCupom		, nVlrPercIT	,;
						nLastTotal		, nVlrTotal		, nLastItem		, nTotItens		,;
						nVlrBruto		, oDesconto		, oTotItens		, oVlrTotal		,;
						oFotoProd		, nMoedaCor		, cSimbCor		, oTemp3		,;
						oTemp4			, oTemp5		, nTaxaMoeda	, oTaxaMoeda	,;
						nMoedaCor		, cMoeda		, oMoedaCor		, cCodProd		,;
						cProduto		, nTmpQuant		, nQuant		, cUnidade		,;
						nVlrUnit		, nVlrItem		, oProduto		, oQuant		,;
						oUnidade		, oVlrUnit		, oVlrItem		, lF7			,;
						cCliente		, cLojaCli		, lOcioso		, nVlrFSD		,;
						nVlrDescTot		, aItens		, nVlrMerc		, lFechaCup		,;
						cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd			, aTEFPend		, aBckTEFMult 	, cCodConv		,;
						cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
						aVidaLinkD		, aVidaLinkc 	, nVidaLink		, lVerTEFPend	,;
						nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,;
						nVlrPercOri		, nQtdeItOri	, nNumParcs		, aImpsSL1		,;
						aImpsSL2		, aImpsProd		, aImpVarDup	, aTotVen		,;
			   			nTotalAcrs		, aCols			, aHeader 		, aDadosJur		,;
						aCProva			, lCXAberto		, oMensagem		, oFntGet		,;
						cTipoCli		, lAbreCup 		, lReserva		, aReserva		,;
						nValor			, aRegTEF		, lRecarEfet    , cOrigem		,;
						lRecalImp		, cMensagem		, cDocFo		, oDlgFrt		,;
						lTefPendCS		, aTefBKPCS		, lTefCanceled	, lResume		)
						


Local nRet    		:= 0
Local cRet			:= ""
Local nX			:= 0
Local nTamDoc       := TamSX3("L1_DOC")[1]
Local cNumCup		:= Space(nTamDoc)
Local cPDV  		:= Space(TamSX3("L1_PDV")[1])
Local aSL1
Local cLiMsg		:= ""
Local cSupervisor	:= Space(15)
Local lEstVend  	:= AliasInDic("MBZ")    ////  estorno de venda
Local aAreaMBZ 		:= Nil //WorkArea dos pagamentos estonados
Local oEstorno 		:= nil //Contera o objeto de estorno de venda

//Localizacoes
Local oDlgCancCup
Local oNumCup
Local lCancCup 		:= .F.
Local lInfCup  		:= .T.
Local nOrdSL1  		:= SL1->(IndexOrd())
Local aRet     		:= {}
Local lRet     		:= .T.   							// .T. - Erro no cancelamento do cupom, .F. - Cancelamento com sucesso
Local lReturn  		:= .F.
Local aDadosCrd		:= {}					 			// Dados do cliente para o web service

Local lFRTCancelat  := ExistTemplate("FRTCancela")		// verifica se existe o PONTO DE ENTRADA FRTCancela
Local xRet                                         		// Retorno do PE FRTCANCCF
Local lFrtCancCF    := ExistBlock("FRTCANCCF")     		// Verifica se existe o ponto de entrada FRTCancCF
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local cNumerCup     := Space(TamSX3("L1_DOC")[1])       // Obtem o numero do cupom
Local lExistCup     := .T.                              // Verifica se o cupom existe
Local cNumOrc       := Space(TamSX3("L1_NUM")[1])       // Numero do orcamento
Local cNumOrig      := Space(TamSX3("L1_NUMORIG")[1])   // Numero do orcamento original.
Local cPDVImp       := Space(TamSX3("L1_PDV")[1])       // PDV utilizado na importacao.
Local aOrcsImp  	:= {}     			 				// Array com o orcamentos importado.
Local lCanCup       := .T.                              // Indica que e cancelamento do cupom.
Local aRetArq       := {}                               // Array de retorno da funcao FR271HArq.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))	// Verifica se utiliza Display
Local cParmDoc 	  := ""									// Numero documento
Local cParmSer 	  := ""									// Numero serie
Local nTamSXG	  	:= 0								// Tamanho do Grupo
Local lTemImpressao	:= .F.								// Caso .T. a venda possui algum item da venda foi impresso
Local lTemRes		:= .F.								// Caso .T. possui algum item da venda com reserva
Local lSoTemRes		:= .F. 								// Somente Reserva
Local cMensCanc		:= ""								// Mensagem para a impressao
Local aValePre		:= {}								// Define se utilizou Vale Presente
Local cFotoProd		:= "LOJAWIN"						// Foto padrão do produto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLjcFid	 	:= SuperGetMv("MV_LJCFID",,.F.)	.AND. CrdxInt()		//Indica se a recarga de cartao fidelidade esta ativa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formulariio ³
//³Paises:Chile/Colombia  - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCFolLocR5	:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL" .AND. !lFiscal
Local lLocR5        :=  cPaisLoc$"CHI|COL
Local lCancCupAnt	:= Iif(lLocR5,.F.,.T.)				//Indica se podera cancelar cupom de venda anterior
Local aInfoWsEst    := GetAPOInfo("WSLOJ600.PRW")      	//Pega Info do Fonte para tratamento
Local nL1RecNo		:= 0
Local lVPNewRegra 	:= Lj7VPNew() 						//Verifica se utiliza as novas modificacoes da implementacao de Vale Presente, para imprimir o comprovante nao fiscal na venda de vale presente.
Local lIsVendaVP 	:= .F.									// Indica se eh venda de Vale Presente
Local lCancPenCup	:= .F.									//Verifica se cancela penultimo cupom
Local nTamCupEst	:= 0									//Tamanho do numero do documento para estorno do vinculado
Local cAntNumCup	:=	""									//Número do cupom anterior
Local lVendTef		:= .F.
Local lTefOk		:= .T.
Local lUseSAT		:= .F.  //Utiliza SAT
Local cNFisCanc		:= ""	//nota cancelamento SAT
Local nRecnoL1		:= 0	//Recno SL1
Local lEstTef		:= .T.
Local lIsDiscado	:= .F.
Local lInutSLX 		:= ExistFunc("Lj7SLXDocE") .And. SLX->(ColumnPos("LX_MODDOC")) > 0 //Verifica se esta implementado no ambiente o controle de inutilizacao de NFC-e pela tabela (SLX)

DEFAULT lCancTef	:= .F.
DEFAULT lF7			:= .F.
DEFAULT cTipoCli	:= ""
DEFAULT lAbreCup	:= .F.
DEFAULT lReserva	:= .F.
DEFAULT aReserva	:= {}
DEFAULT nValor 		:= 0
DEFAULT aRegTEF		:= {}
DEFAULT lRecarEfet	:= .F.
DEFAULT cOrigem     := ""
DEFAULT lRecalImp	:= .F.
DEFAULT cMensagem	:= ""
DEFAULT cDocFo		:= ""								//Release 11.5 - Controle de Formularios - Numero do formulario
DEFAULT oDlgFrt		:= Nil
DEFAULT lTefPendCS	:= .F.
DEFAULT aTefBKPCS	:= {}
DEFAULT lTefCanceled	:= .F.								//Tef ja cancelado anteriormente (sem confirmar a transação)


lUseSAT := IIF(ExistFunc("LjUseSat"),LjUseSat(),.F.)

If CheckCaixa(@lCXAberto, @lUsaDisplay)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Permissao "Cancelamento Cupom" - #8 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCancTef .OR. LJProfile(8,@cSupervisor)

		//posicionamento no ultimo recno caso o sistema seja fechado por queda ou fechamento e aberto do sistema
		nRecnoL1 := SL1->(LASTREC())
		SL1->(DbGoto(nRecnoL1))	

		LjRegRefsh("SL1") // Caso orcamento tenha subido e alterado L1_SITUA enquanto esta cancelando

		If lImpOrc        // No caso de importacao de orcamento exclui o arquivo de controle.
			cNumOrig := Alltrim(SL1->L1_NUMORIG)
			cPDVImp  := Alltrim(SL1->L1_PDV)
			aADD( aOrcsImp , { cNumOrig , cPDVImp } )

	    	LJMsgRun( STR0115 + cNumOrig + "...", NIL, ; //"Aguarde, atualizando status do orcamento "
             { || aRetArq := FR271CMyCall( "FR271HArq", { "SL1", "SL2", "SL4" }, aOrcsImp ,Nil ,lCanCup ) } )
        EndIf

        If !lEmitNfce
			nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Aberto
		Else
			nRet := iIf(FRTAFNfceAberta(),7 ,0 )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ verifica se possui um ou todos itens com Reserva  			³
		//³  lTemRes 	= .T. Possui algum item pedido 					³
		//³  lImpressao = .T. Possui algum item normal que foi impresso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTemRes 	:= FR271HRES(@lTemImpressao)
		lSoTemRes	:= !lTemImpressao .AND. lTemRes
		lIsVendaVP 	:= If( lVPNewRegra, Lj7VdaIsVP(SL1->L1_NUM), .F.)
		
		If !isBlind() .AND. SL1->L1_VENDTEF == "S" .AND. (SL1->L1_CARTAO > 0 .OR. SL1->L1_VLRDEBI > 0)
			lVendTef := IIf(lUsaTef , .T. , .F. )
		EndIf
		
		lIsDiscado := lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND.	(L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo()))
				
		If (lSoTemRes .Or. lIsVendaVP) .AND. (SL1->L1_SITUA == "00" .OR. SL1->L1_SITUA == "TX")
			If lIsVendaVP
				MsgStop(STR0119)	//"Não será possível cancelar a venda de Vale Presente, pois já foi finalizada."
			Else
				MsgStop(STR0079) 	//" Não será possível cancelar o pedido pois ja foi finalizado "
			EndIf
		ElseIf	nRet == 7 .OR.;
				 lCancTef .OR.;
				 (lSoTemRes .Or. lIsVendaVP) .OR.;
				 (nRet <> 7 .AND. lLocR5 .AND. LjNfPtgNEcf(SM0->M0_CGC) .AND. nTotItens > 0) //Release 11.5 - Chile - F2CHI - Permitido apenas o cancelamento da venda corrente com mais de um item lancado
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o cupom está aberto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lSoTemRes .And. !lIsVendaVP
				cMensCanc	:= STR0016 //"Venda em andamento. Realiza o CANCELAMENTO deste Cupom Fiscal?"
			Else
				cMensCanc	:= STR0080 //"Venda em andamento. Realiza o CANCELAMENTO deste Cupom Não Fiscal?"
				nRet := 0
			EndIf
			
			// "Venda em andamento. Realiza o CANCELAMENTO deste Cupom Fiscal?", "Atenção"
			If lCancTef .OR. (LjNfPafEcf(SM0->M0_CGC) .AND. cOrigem == "LOJA160") .OR. MsgYesNo(cMensCanc, STR0002)
				If !lSoTemRes .And. !lIsVendaVP
					nRet := IFStatus(nHdlECF, "9", @cRet)			// Verifico o Status do ECF
				EndIf
				If nRet <> 0
					If !lCancTef
						HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Restaura os SetKey's do Fechamento da Venda ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FRTSetKey(aKey)
					Else
						HELP(' ',1,'FRT034')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
																	// "É necessário efetuar Nota de Devolução."
					EndIf
					Return(lRet)
				EndIf

				If (lEmitNFCe .AND. !lUseSAT) .AND. !lInutSLX .AND. !FRTAFNFCeAberta()
					aSL1 := {{"L1_SITUA",	"00"}}	// "00" - Venda suba para a retaguarda e seja processada e cancelada pelo LjGrvBatch
				Else
					aSL1 := {{"L1_SITUA",	"07"}}	// "07" - Solicitado o Cancelamento do Cupom
				EndIf
				FR271BGeraSL("SL1", aSL1)
				
				If ExistFunc("Lj7AjstSLX")
					//Limpa o Array de registros, cujo DOC esta como "NFCe" (ainda nao esta definido)
					Lj7AjstSLX(SL1->L1_DOC)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Qdo o pais for igual a Mexico eh necessario informar ³
				//³ o numero do documento que esta sendo cancelado.      ³
				//³                                                      ³
				//³ BOPS: 141 597                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumerCup  := SL1->L1_DOC

				If (cPaisLoc == "MEX" .OR. LjNfPtgNEcf(SM0->M0_CGC)) .AND. (Alltrim(cNumerCup) == Alltrim(cDoc))
					cSupervisor := cSupervisor + "|" + cDoc
				Else
					cSupervisor := cSupervisor + "|" + cNumerCup
				EndIf

				If !lSoTemRes .And. !lIsVendaVP
					If !lEmitNFCe
						nRet := IFCancCup(nHdlECF, cSupervisor)
					EndIf

					If nRet == 0 .And. !lTefCanceled
						/* Envia o cancelamento das transacoes TEF
						quando cancela o cupom fiscal.  		*/
						If	lIsDiscado
							LOJA010T("X")
						ElseIf cTipTEF == TEF_CLISITEF .And. !IsInCallStack("FR271GENCERRA")
							Lj140CnAdm(.F., @lVendTef, @oTEF)
						EndIf
	   				EndIf

					If lCancTef .AND. nRet == 1
	   					lReturn := .T.
					EndIf
				EndIf

				If lRecarEfet
					oTef:FinalTrn(0)
					lRecarEfet	:= .F.
					aRegTEF := {}
					If Type("oTEF:aRetDotz") <> "U"  
						//Cancela o resgate do Dotz
						oTEF:aRetDotz := NIL
					EndIf
				EndIf

				If lUsaTef .AND. cTipTEF == TEF_CLISITEF .AND. ValType(oTef:lTefOk) == "L" .AND. oTef:lTefOk .And. oTef:nCodFuncao == 838
					oTef:FinalTrn(0) //Cancela resgate Dotz pendente
					oTEF:aRetDotz := NIL 	
				EndIf

				If nRet == 0
					lFechaCup := .T.
					If (oPbm := LjGetOPBM() ) <> Nil
						oPbm:ConfVend( .F. )
						oPbm := LjSetOPBM(NIL)
						LjMsgRodaP(@oDlgFrt, @oFntGet, STR0001) //"   Protheus Front Loja"
					EndIf
					If lTefPendCS
						oTef:FinalTrn(0)
						If Type("oTEF:aRetDotz") <> "U"  
							//Cancela o resgate do Dotz
							oTEF:aRetDotz := NIL							
						EndIf
					EndIf
				EndIf

				If lFechaCup
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso exista Integracao com o SIGACRD e houve analise de credito, cancela o contrato dependendo do   ³
					//³ status, desde que seja diferente de 4 - fila de crediario										    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If CrdXInt() .AND. !Empty(cContrato)

						If Empty(cUsrSessionID)
							LJMsgRun("Aguarde... Efetuando login no servidor ...",, {|| cUsrSessionID := WSCrdLogin( cUserName /*, cSenha*/ ) } )
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa um webservice para saber qual o status da analise de credito ³
						//³do cliente. Se for diferente de 4 (fila de crediario) pode cancelar  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oObj:=WSCRDSTATUS():New()
						oObj:_URL			:= "http://"+AllTrim(LJGetStation("WSSRV"))+"/CRDSTATUS.apw"
						oObj:cCodCli		:= cCliente
						oObj:cLoja			:= cLojaCli
						oObj:cUsrSessionID	:= cUsrSessionID

						If oObj:GetStatus()
							If oObj:OWSGETSTATUSRESULT:CSITUACAO <> "4"	// Fila de crediario
		                        aDadosCrd := {}
								aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
								aAdd( aDadosCrd, aCrdCliente[1] )		// CPF

								// Faz o desfazimento da transacao de credito
								aRetCrd := CrdxVenda( "3"   ,aDadosCrd   ,If(Empty(SL1->L1_CONTRA),cContrato,SL1->L1_CONTRA)  ,;
								                      .T.   ,NIL         ,NIL )
							Endif
						Else
							Conout(GetWSCError())
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Limpa as variaveis staticas de controle da analise de credito³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Fr271ICrdSet(@cContrato	, @aCrdCliente	,  @aContratos	, @aRecCrd)

					EndIf
				EndIf


				If nRet == 0 .OR. lCancTef

					FR271BCancela()
					IFPegPDV(nHdlECF, @cPDV)
					lOcioso := .T.
					oCupom:AppendText((chr(10) + chr(13)))
					oCupom:AppendText((chr(10) + chr(13)))
					If lSoTemRes .Or. lIsVendaVP .Or. lEmitNFCe
						oCupom:AppendText((STR0074) + chr(10) + chr(13))	// "     C U P O M   N Ã O   F I S C A L    "
						oCupom:AppendText((STR0078) + chr(10) + chr(13))	// "    		C A N C E L A D O           "
					Else
						oCupom:AppendText((STR0017)+ chr(10) + chr(13))	// "         CUPOM FISCAL CANCELADO         "
					Endif
					oCupom:AppendText((chr(10) + chr(13)))
					oCupom:AppendText((chr(10) + chr(13)))

					If (cPaisLoc == "MEX" .OR. LjNfPtgNEcf(SM0->M0_CGC)) .AND. (Alltrim(cNumerCup) == Alltrim(cDoc))
						oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0003+PadR(cPDV,4)+STR0004+cDoc) + chr(10) + chr(13)  ) // "  PDV:" "   COD:"
					Else
						oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0003+PadR(cPDV,4)+STR0004+cNumerCup) + chr(10) + chr(13)	) // "  PDV:" "   COD:"
					EndIf

					oCupom:AppendText((chr(10) + chr(13)))
					oCupom:AppendText((STR0077)+ chr(10) + chr(13))  //"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
					oCupom:GoEnd()

					aItens	:= {}
					aPgtos	:= {}
					aTEFPend:= {}
					aBckTEFMult := {}
					lTefPendCS	:= .F.
					aTefBKPCS	:= {}
					lOcioso	:= .T.
					lVerTEFPend  := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Zera o valor e o percentual de desconto do item       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVlrPercIT := 0
					nLastTotal:= nVlrTotal
					nLastItem := nTotItens
					nTotItens := 0
					nVlrTotal := 0
					nVlrBruto := 0
					nVlrMerc  := 0
					nTotDedIcms  := 0
					lImpOrc   := .F.
					lAbreCup := .F.
					nValor		:= 0
					lResume	 := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|Reinicializa as variaveis estaticas p/ rotina de recebimento de NCC	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Frt060End()
					If !lTouch
						oDesconto:Refresh()
						oTotItens:Refresh()
						oVlrTotal:Refresh()
					Endif
					If nVidaLink <> 99 .And. nVidaLink <> 0
						oTEF:aRetVidaLink := Nil
						aVidaLinkD := {}
						aVidaLinkc := {}
						nVidaLink  := 0
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reinicializa as variáveis de Templates                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					uCliTPL := Nil
					uProdTPL:= Nil
		            cCodConv:= ""
		            cLojConv:= ""
					cNumCartConv := ""

					//Inicializa a variavel de Controle de Frete utilizado na venda
					If ValType(lCFrete) == "L" .And. lCFrete
						lCFrete := .F.
					EndIf

					FR271AInitIT(	.T.,		@lF7,		@cCodProd, 	@cProduto,;
									@nTmpQuant,	@nQuant,	@cUnidade,	@nVlrUnit,;
									@nVlrItem,	@oProduto,	@oQuant,	@oUnidade,;
									@oVlrUnit,	@oVlrItem,	@oDesconto,	@cCliente,;
									@cLojaCli)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Limpa as variaveis staticas de controle da analise de credito³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Fr271ICrdSet(@cContrato	, @aCrdCliente	,  @aContratos	, @aRecCrd)

					//------------------------------------------------------------------
					//Limpa as variaveis de controle referente a venda de Vale Presente
					//------------------------------------------------------------------
					If lIsVendaVP .And. lVPNewRegra
						Lj7VPVdaVP(0)
						FrtSetItVP()
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Define cliente com o padrao do parametro ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
					cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
					nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
					cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
					FR271Hora(.T., Nil, @oHora, @cHora, @oDoc, @cDoc )

					If !lTouch
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existe a imagem FRTWIN , caso nao possua apresenta a LOJAWIN³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If oFotoProd:ExistBmp("FRTWIN")
							cFotoProd := "FRTWIN"
						EndIf
						If oFotoProd:cBMPFile <> cFotoProd
							ShowBitMap(oFotoProd,cFotoProd)
						EndIf
					Endif

					//Restaura as variaveis referentes a moeda para a moeda 1
					If cPaisLoc <> "BRA"
						If nMoedaCor <> 1
							cSimbCor  := AllTrim(SuperGetMV("MV_SIMB1"))
							oTemp3:Refresh()
							oTemp4:Refresh()
							oTemp5:Refresh()

							nTaxaMoeda := 1
							oTaxaMoeda:Refresh()

							nMoedaCor := 1
							cMoeda    := AllTrim(SuperGetMV("MV_MOEDA1"))
							oMoedaCor:Refresh()
						EndIf

						//Restaura a exibicao da mensagem padrao...
						AEval(aTotVen, {|x,y| (aTotVen[y][3]:=0,aTotVen[y][4]:=.F.)})
						If oMensagem <> NIL
							oMensagem:cCaption := STR0001  //"   Protheus Front Loja"
							oMensagem:cTitle   := STR0001  //"   Protheus Front Loja"
							oMensagem:oFont    := oFntGet
							oMensagem:Refresh()
						EndIf

						aImpsSL1    := {}
						aImpsSL2    := {}
						aImpVarDup  := {}
						aImpsProd   := {}
						aCols       := {}
						aHeader     := {}
						aCProva     := {}
						aDadosJur   := {  0, 0, 0, 0, ;
						 				  0, 0, 0, 0, ;
										  0 }
						nVlrFSD     := 0
						nTotalAcrs  := 0
						nVlrDescTot	:= 0
						nVlrPercTot	:= 0
						nVlrPercAcr	:= 0
						nNumParcs   := 0
						nVlrPercOri := 0
						nQtdeItOri  := 0
						lRecalImp	:= .F.
					EndIf

					cMensagem := STR0001 //"   Protheus Front Loja"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ P.E. Apos o Cancelamento        ³
					//³ Tipo      : 1 - Item            ³
					//³             2 - Cupom           ³
					//³ Supervisor: Senha que autorizou ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFRTCancelat
						uProdTPL := ExecTemplate("FRTCancela",.F.,.F.,{2,cSupervisor,,uProdTPL})
					EndIf
					If ExistBlock("FRTCancela")
						ExecBlock("FRTCancela",.F.,.F.,{2,cSupervisor,NIL,uProdTPL})
					EndIf

					FRTSetKey(aKey)
					aReserva	:= {}

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
					//³ Release 11.5 - Cartao Fidelidade 			  |
					//³ Reinicializa variaveIs de cartao fidelidade	  |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
					If lLjcFid
						If FA271aGrcf ()
							LaFunhDelS ()
							FA271aSrcf (.F.)
							Fa271aSpfw (.F.)
						EndIf
					Endif


					If lCFolLocR5
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Release 11.5 - Controle de Formulario  ³
						//³Zerar RECNO da especie de documento    ³
						//³fiscal escolhida no inicio da venda.   ³
						//³Paises:Chile/Colombia - F1CHI		  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FaZerRecFo()
					EndIf

					Return If(lCancTef, lReturn, .T.)
				Else
					HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura os SetKey's do Fechamento da Venda ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTSetKey(aKey)
					Return(lRet)
				EndIf
			EndIf
		Else

			 If lEmitNfce 
			 	If !PreparaCancNfce()
			 		Return .F.
			 	EndIf

			 	//Quando é NFCE tem um reposicionamento da SL1 na função PreparaCancNfce, portanto verifico novamente se venda tem TEF
			 	If !isBlind() .AND. lUsatef .AND. SL1->L1_VENDTEF == "S" .AND. (SL1->L1_CARTAO > 0 .OR. SL1->L1_VLRDEBI > 0)
					lVendTef := .T.
				EndIf
				
				//Se o cupom está fechado
				cNumCup	:= SL1->L1_DOC
				nRet	:= 0
			Else
				//Se o cupom está fechado
				nRet	:= IFPegCupom( nHdlECF,@cNumCup )
				/* Deve estar aqui pois após retornar do ECF podemos ter 6 caracteres, 
				   caso cancele cupom com TEF pode gerar problema em não achar o doc anterior.
				   Pois o tamanho do cupom no ECF pode ter 6 e o L1_DOC é de 9	*/
				nTamCupEst := Len(cNumCup)
			EndIf

			//Restaura o tamanho da variavel cNumcup para a comparação com L1_DOC
			cNumCup	:= PADR(cNumCup,nTamDoc)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a venda não foi estornada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEstVend .AND. Len(aInfoWsEst) > 0
				aAreaMBZ := MBZ->(GetArea())
				MBZ->(DbSetOrder(1))
				If MBZ->( DbSeek(xFilial("MBZ") + PadR(cNumCup,TamSX3("MBZ_CUPOM")[1]) + PadR(LJGetStation("SERIE"),TamSX3("MBZ_SERIE")[1])))
					MsgAlert( STR0111)//"Ja foi realizado o estorno  desse Cupom."
					lRet := .F.
				    RestArea(aAreaMBZ)

					Return(lRet)
				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Instancia o objeto estorno, a fim de verificar se a venda foi estornada por outro PDV³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oEstorno := LjClEstVen():New(nil,xNumCaixa(), nil, dDataBase,0, .F.)
					oEstorno:lJob := .T.
					oEstorno:BuscaOrcamento(cNumCup, LJGetStation("SERIE"))
					If !Empty(oEstorno:cOrc_StatuEs)
						MsgAlert( STR0111)//"Ja foi realizado o estorno  desse Cupom."
						lRet := .F.
						Return(lRet)
					Endif

				EndIf
				RestArea(aAreaMBZ)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Localizacoes                 ³
			//³Permissao negada para cancelamento de cupom ³
			//³de venda realizada anteriormente.           ³
			//³Paises: Chile / Colombia - F1CHI            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lCancCupAnt
				MsgAlert( STR0113 ) //"Comprovantes de vendas anteriores nao podem ser cancelados."
				lRet := .F.
			Else				
				If !lEmitNFCe .And. nRet <> 0
					HELP(' ',1,'FRT011')	      // "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura os SetKey's do Fechamento da Venda ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FRTSetKey(aKey)
					Return(lRet)
				Else
					If lFrtCancCF .And. !lEmitNFCe
						xRet := ExecBlock("FRTCANCCF",.F.,.F.,{cNumCup})
						If ValType(xRet) == "C"
						   cNumCup  := xRet
						Endif
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para o Mexico eh necessario um tratamento especial no cancelamento do cupom, ³
				//³pois pode ser que o cupom cancelado nao seja o ultimo emitido pelo ECF       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cPaisLoc == "MEX" .OR. LjNfPtgNEcf(SM0->M0_CGC))  .AND. lCancCupAnt
					IFPegPDV(nHdlECF, @cPDV)
					cPDV := PadR(AllTrim(cPDV),TamSx3("L1_PDV")[1]," ")

					SL1->(dbSetOrder(8))

					If Val(cNumCup) > 0 .AND. SL1->(DbSeek(xFilial("SL1")+cPDV+cNumCup))
						lInfCup := !MsgYesNo(STR0036+cNumCup+")") //"O cupom a ser cancelado e o ultimo cupom emitido (Numero: "
					EndIf

					If lInfCup
						cNumCup := Replicate("0",nTamDoc)

						DEFINE MSDIALOG oDlgCancCup FROM  47,130 TO 160,300 TITLE STR0037 PIXEL	//"Cancelamento de Cupom"
						@ 04, 02 TO 28, 80 LABEL STR0038 OF oDlgCancCup  PIXEL	//"Numero do Cupom"

						@ 13, 06 MSGET oNumCup VAR cNumCup SIZE 70, 10 OF oDlgCancCup PICTURE PesqPictQt("L1_DOC") RIGHT PIXEL ;
						VALID (!Empty(cNumCup) .AND. (Val(cNumCup) > 0))
						oNumCup:cSx1Hlp:="L1_DOC"

						DEFINE SBUTTON FROM 38, 15 TYPE 1 ENABLE OF oDlgCancCup ;
						ACTION (lCancCup := .T.,oDlgCancCup:End()) PIXEL

						DEFINE SBUTTON FROM 38, 50 TYPE 2 ENABLE OF oDlgCancCup ;
						ACTION (lCancCup := .F.,oDlgCancCup:End()) PIXEL

						ACTIVATE MSDIALOG oDlgCancCup CENTERED

						If lCancCup
							cNumCup := Padl(AllTrim(cNumCup),nTamDoc,"0")
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Restaura os SetKey's do Fechamento da Venda ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							FRTSetKey(aKey)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
							//³ Release 11.5 - Cartao Fideldiade 		      |
							//³ Reinicializa variaveIs de cartao fidelidade	  |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
							If lLjcFid
								If FA271aGrcf ()
									LaFunhDelS ()
									FA271aSrcf (.F.)
									Fa271aSpfw (.F.)
								EndIf
							EndIf

	                    	Return(lRet)
						EndIf
					EndIf
				EndIf

				lPermitEcf := !LjNfPtgNEcf(SM0->M0_CGC)
				
				DbSelectArea("SL1")
				SL1->(DbSetOrder(1))

				/*Posiciona o SL1 na ultima venda*/
				If (cPaisLoc <> "MEX" .AND. !LjNfPtgNEcf(SM0->M0_CGC))
					If Alltrim(SL1->L1_DOC) <> Alltrim(cNumCup)
						SL1->( DbSeek(xFilial("SL1")+"ZZZ",.T.) )
						SL1->( DbSkip(-1) )
					Endif
				Else
					SL1->(DbSetOrder(8))
					SL1->(DbSeek(xFilial("SL1")+cPDV+cNumCup))
					/* Verifica se ja foi feito solicitado o cancelamento desse cupom*/
					If !(SL1->(DbSeek(xFilial("SL1")+cPDV+cNumCup)))
						lRet := .F.
						MsgAlert( STR0091 + CHR(10) +;		// "Ja foi solicitado o cancelamento desse Cupom."
								  STR0092)					// "Nao sera feito o cancelamento."
					EndIf

				EndIf

				/*-Se o cupom da ultima venda não for o mesmo do ECF nao faz o cancelamento
				-Pode efetuar o cancelamento do penultimo cupom quando foi efetuada uma venda do
				tipo CC com impressão de comprovante de credito e debito, existe no ECF uma opção
				 de cancelar o cupom fiscal mesmo com esta impressão 							*/
				If !lEmitNFCe .AND. (Len(aReserva) == 0) .And.;
				 	Alltrim(cNumCup) <> Alltrim(SL1->L1_DOC) .AND. (cPaisLoc <> "MEX" .AND. !LjNfPtgNEcf(SM0->M0_CGC))

					cAntNumCup := AllTrim(cNumCup)
					cNumCup  := PADR(StrZero(Val(AllTrim(cNumCup))-1,nTamCupEst),nTamDoc)
					If Alltrim(cNumCup) <> Alltrim(SL1->L1_DOC)
						lExistCup	:= .F.
						lRet		:= .F.

						// "O último cupom do ECF não corresponde com a última venda. Não será feito o cancelamento do cupom.", "Atenção"
						HELP(' ',1,'FRT035')
					Else
						lCancPenCup := .T.
					EndIf
				Else
					//Verifica se o cupom existe ou se ja nao foi cancelado
	            	If cPaisLoc == "MEX"
		            	cNumOrc := SL1->L1_NUM
		            	SL1->(DbSetOrder(1))
		            	If !(SL1->(DbSeek(xFilial("SL1")+ cNumOrc)))
		            		lRet := .F.
		             		lExistCup := .F.
		             		MsgAlert( STR0020 + cNumCup + STR0093 ) //" O Cupom fiscal nº " + cNumCup + " já foi cancelado ou o orçamento não existe no PDV."
		             	EndIf
		        	EndIf
		       EndIf
								
				If lRet .AND. lExistCup
					// "Realiza o CANCELAMENTO do Cupom Fiscal nº " ### " ?", "Atenção"
					If lEmitNFCe

						If lUseSAT
							lRet := MsgYesNo(IIF(lMFE,STR0160,STR0128) + "'"+cNumCup+"'?", StrTran(STR0002,"SAT",cSiglaSat)) //"Deseja realizar o cancelamento do MF-e de numero "##"Deseja realizar o cancelamento do SAT de numero "

							If lRet .And. ExistFunc("LJSatxCanc")
								lRet := LJSatxCanc(.F.,@cNFisCanc)
							EndIf
						Else
							lRet := MsgYesNo(STR0121+cNumCup+"'?", STR0002) //"# ##Atenção"
						EndIf

					ElseIf Len(aReserva) == 0
						lRet := MsgYesNo(STR0018+cNumCup+STR0019, STR0002)
					Else
						lRet := MsgYesNo(STR0073+STR0019, STR0002) //"Realiza o CANCELAMENTO do Cupom não Fiscal. "
					EndIf
				EndIf

				//So permite a exclusao caso o cupom NAO PERTECENCA a uma factura global...
				If lRet .AND. cPaisLoc == "MEX"
					LJMsgRun(STR0065,,{|| aRet:=FR271CMyCall("FR271CPGlobal", {"SF2","SD2","SE1","SM2","SL1"}, SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_CLIENTE, SL1->L1_LOJA)}) //"Verificando se o cupom pertence a uma nota fiscal global..."
					If AllTrim(aRet[1]) <> "ERRO"
						If AllTrim(aRet[1]) == "EOF"
							MsgAlert( STR0066 ) //"O cupom nao podera ser cancelado porque nao foi encontrado no BackOffice"
						ElseIf AllTrim(aRet[1]) == "GLOBAL"
							MsgAlert( STR0067 ) //"O cupom nao podera ser cancelado porque pertence a uma Nota Fiscal Global"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida se a venda jah gerou uma NF s/ cupom fiscal³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf AllTrim(aRet[1]) == "NFCUPOM"
							MsgAlert( STR0069 ) //"O cupom nao podera ser cancelado porque foi gerada uma Nota Fiscal sobre cupom"

						ElseIf AllTrim(aRet[1]) == "QTDEDEV"
							MsgAlert( STR0070 ) //"Cupom não poderá ser cancelado, porque foi realizado devolução de um ou mais itens desta venda."
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida se o titulo ja foi baixado (Ex: Baixa Automatica) ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ElseIf AllTrim(aRet[1]) == "BAIXADO"
							MsgAlert( STR0087 ) // "O cupom nao podera ser cancelado porque ja foi gerada a baixa."
						EndIf

						lRet := aRet[2]
					Else
						lRet := MsgYesno(STR0068+SL1->L1_DOC+" ?") //"A conexao com o servidor de BackOffice por alguma razao se encontra interrompida. Esse cupom pode pertencer a uma Nota Fiscal. Assim mesmo deseja cancelar o cupom de numero "
					EndIf
				EndIf

				If lRet

			    	LjRegRefsh("SL1") // Caso orcamento tenha subido e alterado L1_SITUA enquanto esta cancelando

			    	cLiMsg := ""
			    	FrtFSLCanc("C",@cLiMsg)
			    	cLiMsg += IIf(!Empty(AllTrim(cLiMsg)) , cNfisCanc, "")

					//³Qdo o pais for igual a Mexico eh necessario informar o numero do cupom que esta   ³
					//³sendo cancelado, pois pode ser que nao se trate do ultimo cupom emitido pelo ECF. ³
					//³O tratamento da variavel cSupervisor sera realizado dentro da Dll fiscal.         ³
					If (cPaisLoc == "MEX" .OR.LjNfPtgNEcf(SM0->M0_CGC))
						cSupervisor := cSupervisor+"|"+cNumCup
					EndIf

					If Len(aReserva) == 0
						If !lEmitNFCe
							If lCancPenCup
								nRet := IFEstornVinc(	nHdlECF,If(SL1->(ColumnPos("L1_CGCCLI")) > 0 ,SL1->L1_CGCCLI, ""),"","",;
														"Cancelamento de Comprovante de Crédito e Débito",cAntNumCup)
								If nRet <> 0
									MsgAlert(	STR0156 + ;        //"Não foi possível efetuar o cancelamento do cupom vinculado. Verifique se o último "
												STR0157 + CRLF +;  //"impresso foi um relatório gerencial caso seja não é permitido o cancelamento."
												STR0158 )          //"Caso necessário realize a devolução da venda na Retaguarda e o cancelamento da transações TEF via rotina admnistrativa."
									
									FrtFSLCanc("R")

									// "O Cupom fiscal nº "+cNumCup+", não pode ser cancelado."
									MsgStop(STR0020+cNumCup+STR0021)

									//Restaura os SetKey's do Fechamento da Venda
									FRTSetKey(aKey)
									Return lRet
								EndIf
							EndIf
						EndIf
						
						nRet := IFCancCup(nHdlECF, cSupervisor)						

					EndIf

					If nRet == 0

						/* Envia o cancelamento das transacoes TEF ao cancelar os cupons */
						lEstTef := .F.
						lEstTef := FrtFCncTEF(@lEstTef,lIsDiscado,lTefOk,@cSupervisor,lCancTef,@lVendTef)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso exista Integracao com o SIGACRD, cancela o Credito em aberto     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If CrdXInt()
							aAdd( aDadosCrd, aCrdCliente[2] ) 		// Numero do cartao
							aAdd( aDadosCrd, aCrdCliente[1] )		// CNPJ/CPF
							// Faz o desfazimento da transacao de credito
							CrdxVenda( "3"   ,aDadosCrd  ,If(Empty(SL1->L1_CONTRA),cContrato,SL1->L1_CONTRA),.T.   ,;
							           NIL   ,NIL )

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Limpa as variaveis staticas de controle da analise de credito³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Fr271ICrdSet( @cContrato	, @aCrdCliente	,  @aContratos	, @aRecCrd)
						EndIf

						DbSelectArea("SL4")
						SL4->(DbSetOrder(1))
						If SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
							While !SL4->(Eof()) .AND. (SL4->L4_FILIAL+SL4->L4_NUM == xFilial("SL4")+SL1->L1_NUM)

								//³Verifica se foi utilizado VP na venda como forma de pagamento ³
								If AllTrim(SL4->L4_FORMA) == "VP"
						   			aAdd(aValePre,{AllTrim(SL4->L4_NUMCART),"2"})
								EndIf
								
								If LjNfPafEcf(SM0->M0_CGC)
									//caso haja cancelamento e permitir envio para retaguarda se a venda for cancelada
									//Cria um chave qualquer somente para preenchimento do campo
									RecLock("SL4",.F.)
									REPLACE SL4->L4_PAFMD5 WITH LjxPAFMD5("SL4",SL4->(L4_FILIAL+L4_NUM) + AllTrim(Str(SL4->L4_VALOR)) + AllTrim(Str(SL4->(Recno()))))
									SL4->(MsUnlock())
								EndIf

								SL4->(DbSkip())
							End
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se foi vendido algum VP na venda ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SL2")
						SL2->(DbSetOrder(1))
						If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
							While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM)
								If SL2->(FieldPos("L2_VALEPRE")) > 0 .AND. !Empty(SL2->L2_VALEPRE)
						   			aAdd(aValePre,{AllTrim(SL2->L2_VALEPRE),"1"})
								EndIf
								SL2->(DbSkip())
							End
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Release 11.5 - Cartão Fidelidade³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lLjcFid
							DbSelectArea("SL2")
							SL2->(DbSetOrder(1))
							If SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
								While !SL2->(Eof()) .AND. (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM)
									If LaFunhProd(SL2->L2_PRODUTO) .AND.	!Empty(SL2->L2_NUMCFID) .AND. !Empty(SL2->L2_DTSDFID) .AND. (SL2->L2_VLRCFID > 0)
							 	   		//Cancelamento de venda de recarga de cartao fidelidade
							 			If !Ca280Exec("CA280ESLD",SL2->L2_NUMCFID,,,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,"4")
	 										FrtFSLCanc("R")
											Return(lRet)
							 			EndIf
							 			Exit
							 		EndIf
							 		SL2->(DbSkip())
							 	End
							 EndIf

					 		//Cancelamento de venda com forma de pagamamento FID - Cartao fidelidade
							DbSelectArea("SL4")
							SL4->(DbSetOrder(1))
							If SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
								While SL4->(!Eof()) .AND. SL4->L4_NUM == SL1->L1_NUM
									If Alltrim(SL4->L4_FORMA) == "FID"
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Se a venda foi paga com cartao fidelidade, entao o ³
										//³movimento de saida sera estornado da tabela MBN    ³
										//³e o valor devolvido ao respectivo saldo.           ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If !(Ca280Exec("CA280ESLD",SL4->L4_NUMCFID,,,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,"3"))
											FrtFSLCanc("R")
											Return(lRet)
										Endif
					 					Exit
					 				EndIf
					 				SL4->(DbSkip())
								End
							EndIf

							//Limpa Variaveis
						 	If FA271aGrcf ()
								LaFunhDelS ()
								FA271aSrcf (.F.)
								Fa271aSpfw (.F.)
							EndIf

						EndIf

						FR271BCancela()
						
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Release 11.5 - Controle de Formularios ³
						//³Zerar RECNO da especie de documento    ³
						//³fiscal escolhida no inicio da venda.   ³
						//³Paises:Chile/Colombia - F1CHI		  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lCFolLocR5
							FaZerRecFo()
							cDoc := ""
						EndIf

						FR271Hora(.T., Nil, oHora, cHora, oDoc, cDoc)
						lFechaCup := .T.
						lOcioso   := .T.
						oCupom:SetupdatesEnable(.F.)
						oCupom:AppendText((chr(10) + chr(13)))
						oCupom:AppendText((chr(10) + chr(13)))
						If Len(aReserva) > 0 .Or. (lEmitNFCe .And. !lUseSat)  							
							oCupom:AppendText(("    C U P O M   N Ã O   F I S C A L    ") + chr(10) + chr(13))	// "     C U P O M   N Ã O   F I S C A L    "
							oCupom:AppendText(("           C A N C E L A D O           ") + chr(10) + chr(13))	// "    		C A N C E L A D O           "
						ElseIf lUseSat
							oCupom:AppendText(("    CUPOM FISCAL ELETRONICO - "+cSiglaSat+"      ") + chr(10) + chr(13))	// "    CUPOM FISCAL ELETRONICO - SAT      "
							oCupom:AppendText(("           C A N C E L A D O           ") + chr(10) + chr(13))	// "    		C A N C E L A D O           "														
						Else
							oCupom:AppendText((STR0017) + chr(10) + chr(13))	// "         CUPOM FISCAL CANCELADO         "
						Endif
						oCupom:AppendText((chr(10) + chr(13)))
						oCupom:AppendText((chr(10) + chr(13)))
						oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0003+PadR(SL1->L1_PDV,4)+STR0004+SL1->L1_DOC) + chr(10) + chr(13)) 	// "  PDV:" "   COD:"
						oCupom:AppendText((chr(10) + chr(13)))
						oCupom:AppendText(("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^") + chr(10) + chr(13))
						oCupom:SetupdatesEnable(.T.)
						oCupom:GoEnd()
					    oCupom:Refresh()

					    If lEmitNFCe 
					    	If  !lUseSAT .And. ExistFunc("LjNFCePrtC")
					    	//Imprime comprovante Nao-Fiscal referente a Solicitacao de Cancelamento de NFC-e
					    		LjNFCePrtC(SL1->L1_PDV, SL1->L1_DOC, SL1->L1_SERIE, dDatabase, Time())
					    	ElseIf lUseSAT .AND.  ExistFunc("LjSaCtrCnc")
					    		LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo sinal de recuperação de cancelamento
					    	EndIf
					    EndIf
					    
					    

						aItens	:= {}
						aPgtos	:= {}
						aTEFPend:= {}
						aBckTEFMult := {}
						lOcioso	:= .T.
						lVerTEFPend  := .F.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Zera o valor e o percentual de desconto do item       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nVlrPercIT := 0
						nLastTotal:= nVlrTotal
						nLastItem := nTotItens
						nTotItens := 0
						nVlrTotal := 0
						nVlrBruto := 0
						nVlrMerc  := 0
						nTotDedIcms  := 0
						lAbreCup := .F.
						nValor 		:= 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Rotina para Estornar os Vales Presentes caso possua  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aValePre) > 0
							LjEstVP(aValePre)
						EndIf

						If SL1->L1_CREDITO > 0
							If Empty(SL1->L1_DOC)
								cParmDoc := SL1->L1_DOCPED
							Else
								cParmDoc := SL1->L1_DOC
							Endif

							If Empty(SL1->L1_SERIE)
								cParmSer := SL1->L1_SERPED
							Else
								cParmSer := SL1->L1_SERIE
							Endif

	                        Frt060ExNCC(SL1->L1_FILIAL,cParmDoc	,cParmSer		,SL1->L1_CLIENTE,;
	                        			SL1->L1_LOJA  , .F.		, SL1->L1_NUM	,SL1->L1_OPERADO,;
	                        			SL1->L1_EMISNF,SL1->L1_CREDITO)
						EndIf

						If Len(aReserva) == 0
							If !Empty(cLiMsg)
								FR271BGerSLI("    ", "CAN", cLiMsg, "NOVO")
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|Reinicializa as variaveis estaticas p/ rotina de recebimento de NCC	³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Frt060End()

						If !lTouch
							oDesconto:Refresh()
							oTotItens:Refresh()
							oVlrTotal:Refresh()
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Reinicializa as variáveis de Templates                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						uCliTPL := Nil
						uProdTPL:= Nil
			            cCodConv:= ""
			            cLojConv:= ""
						cNumCartConv := ""

						//Inicializa a variavel de Controle de Frete utilizado na venda
						If Valtype(lCFrete) == "L" .And. lCFrete
							lCFrete := .F.
						EndIf

						FR271AInitIT(	.T.			, @lF7		, @cCodProd		, @cProduto,;
										@nTmpQuant	, @nQuant	, @cUnidade		, @nVlrUnit,;
										@nVlrItem	, @oProduto	, @oQuant		, @oUnidade,;
										@oVlrUnit	, @oVlrItem	, @oDesconto	, @cCliente,;
										@cLojaCli)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Define cliente com o padrao do parametro ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
						cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
						nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
						cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
						FR271Hora(.F., .T., @oHora, @cHora, @oDoc, @cDoc)
						If !lTouch
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se existe a imagem FRTWIN , caso nao possua apresenta a LOJAWIN³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If oFotoProd:ExistBmp("FRTWIN")
								cFotoProd := "FRTWIN"
							EndIf
							If oFotoProd:cBMPFile <> cFotoProd
								ShowBitMap(oFotoProd,cFotoProd)
							EndIf
						Endif

						//Restaura as variaveis referentes a moeda para a moeda 1
						If cPaisLoc <> "BRA"
							If nMoedaCor <> 1
								cSimbCor  := AllTrim(SuperGetMV("MV_SIMB1"))
								oTemp3:Refresh()
								oTemp4:Refresh()
								oTemp5:Refresh()

								nTaxaMoeda := 1
								oTaxaMoeda:Refresh()

								nMoedaCor := 1
								cMoeda    := AllTrim(SuperGetMV("MV_MOEDA1"))
								oMoedaCor:Refresh()
							EndIf

							//Restaura a exibicao da mensagem padrao...
							AEval(aTotVen, {|x,y| (aTotVen[y][3]:=0,aTotVen[y][4]:=.F.)})
							oMensagem:cCaption := STR0001  //"   Protheus Front Loja"
							oMensagem:cTitle   := STR0001  //"   Protheus Front Loja"
							oMensagem:oFont    := oFntGet
							oMensagem:Refresh()

							aImpsSL1    := {}
							aImpsSL2    := {}
							aImpVarDup  := {}
							aImpsProd   := {}
							aCols       := {}
							aHeader     := {}
							aCProva     := {}
							aDadosJur   := {0,0,0,0,0,0,0,0,0}
							nVlrFSD     := 0
							nTotalAcrs  := 0
							nVlrDescTot	:= 0
							nVlrPercTot	:= 0
							nVlrPercAcr	:= 0
							nNumParcs   := 0
							nVlrPercOri := 0
							nQtdeItOri  := 0
						EndIf

						lImpOrc   := .F.
						cMensagem := STR0001 //"   Protheus Front Loja"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ P.E. Apos o Cancelamento        ³
						//³ Tipo      : 1 - Item            ³
						//³             2 - Cupom           ³
						//³ Supervisor: Senha que autorizou ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFRTCancelat
							uProdTPL := ExecTemplate("FRTCancela",.F.,.F.,{2,cSupervisor,,uProdTPL})
						EndIf
						If ExistBlock("FRTCancela")
							ExecBlock("FRTCancela",.F.,.F.,{2,cSupervisor,NIL,uProdTPL})
						EndIf

					Else
						FrtFSLCanc("R")
						// "O Cupom fiscal nº "+cNumCup+", não pode ser cancelado."
						MsgStop(STR0020+cNumCup+STR0021)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Restaura os SetKey's do Fechamento da Venda ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FRTSetKey(aKey)
						Return(lRet)
					Endif
				EndIf
				SL1->(DbSetOrder(nOrdSL1))
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
		//³ Release 11.5 - Cartao Fideldiade 		      |
		//³ Reinicializa variaveIs de cartao fidelidade	  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
		If lLjcFid
			If FA271aGrcf ()
				LaFunhDelS ()
				FA271aSrcf (.F.)
				Fa271aSpfw (.F.)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpa a reserva para o proximo orçamento  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			aReserva	:= {}
		EndIf
	Else
		// "Usuário sem permissão para cancelar Cupom Fiscal.", "Atenção"
		HELP(' ',1,'FRT036')
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FR271FReducao³ Autor ³ Venda Clientes        ³ Data ³24/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressão da Reducao Z									     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL							                          	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                    	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja (F12 + 02)                                  	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271FReducao(	oTimer			, cCodProd		, cHora			, oDoc			,;
						cDoc			, oPDV			, cPDV			, nLastTotal	,;
						nVlrTotal		, nLastItem		, nTotItens		, nVlrBruto 	,;
						oVlrTotal		, oCupom		, oTotItens 	, oOnOffLine	,;
						nTmpQuant		, nVlrItem 		, nValIPIIT		, nValIPI		,;
						oFotoProd		, oProduto		, oQuant		, oVlrUnit		,;
						oVlrItem		, oDesconto		, cSimbCor		, cOrcam 		,;
						cProduto		, nQuant 		, cUnidade		, nVlrUnit 	,;
						oUnidade 		, lF7			, oHora			, lOcioso		,;
						lRecebe			, lLocked		, lCXAberto		, lDescIT		,;
						nVlrDescTot		, aItens		, aICMS			, nVlrMerc		,;
						_aMult			, _aMultCanc	, lOrc			, aParcOrc		,;
						cItemCOrc		, aParcOrcOld	, lAltVend		, lImpNewIT	,;
						lFechaCup		, cContrato		, aCrdCliente	, aContratos	,;
						aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
						cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
						lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,;
						nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,;
						nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
						nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,;
						nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
						nNumParcs		, aMoeda		, aSimbs		, nMoedaCor		,;
						nDecimais		, aImpsSL1		, aImpsSL2		, aImpsProd		,;
						aImpVarDup		, aTotVen		, aCols			, nVlrPercIT	,;
						cEstacao		, lTouch		, cVendLoja		, aParcOrcOld	,;
						oMensagem		, oFntMoeda		, cMsgCupom		, cEntrega		,;
						aReserva		, lReserva		, lAbreCup		, nValor		,;
						cCliente		, cLojaCli		, cCupom		, cTipoCli		,;
						lDescITReg		, cNumDAV		, oDlg	)

Local lRet 		:= .T.
Local lRedZPend	:= .F.							//Verifica se a redução Z está pendente no ECF
Local lCancDav	:= .T.    						//Verifica se as pre-vendas podem ser canceladas

Local cRet		:= ""
Local lUsaFecha		:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utilizar conf. de fechamento
Local lTemMov	:= .F.                          // Se existe movimento sem conferencia
Local nRecSLW	:= 0							// Guarda o registro da SWT para comparar com SL1

If FindFunction("FR271ChkOrcAb")
	lRet = FR271ChkOrcAb(cPdv, cEstacao, cOrcam)
EndIf

If lRet
	If MsgNoYes(STR0075)		//"Confirma REDUCAO Z ?"

		//+----------------------------------+
		//¦Verifica se o caixa ja esta aberto¦
		//+----------------------------------+
		FR271ICxFecha(@lCXAberto,@nRecSLW)

		//+------------------------------------+
		//¦Verifica se o caixa tem movimentacao¦
		//+------------------------------------+
		If lCXAberto
			FR271FMovAbr(@lTemMov, nRecSLW)
    	Endif

	 	If lCXAberto .AND. lUsaFecha .AND. lTemMov
			MsgStop(STR0120) //"O Caixa esta Aberto. Impossivel realizar esta Operacao."
			lRet 		:= .F.
	 	EndIf

		If lRet
			If LjNfPafEcf(SM0->M0_CGC)

				//Verifica se Redução Z esta pendente
				If IFStatus(nHdlECF, "8", @cRet) == 10
					lRedZPend	:=	.T.
				EndIf

				If !lRedZPend // Se lRedZPend == .T., ECF está com redução Z pendente  e não pode realizar os cancelamentos
					LjCancOrc()
					lCancDav	:=	.F.
				EndIf

				LJ160Leitura()

				If lCancDav // Se lCancDav == .T. é necessário cancelar as pré-vendas e a Redução Z estava pendente
					LjCancOrc()
				EndIf

			Else
				LJ160Leitura()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa o ponto de entrada LOJA160³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("LOJA160")
				ExecBlock("LOJA160",.F.,.F.)
			Endif

		EndIf

	Endif
EndIf
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa271FgFid  ³Autor³ Leandro Nogueira      ³ Data ³17/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o numero do cartao fidelidade informado como pagto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271FgFid()

Return cNumCFid

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa271FkFid  ³Autor³ Leandro Nogueira      ³ Data ³17/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa o numero do cartao fidelidade informado como pagto   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271FkFid()

cNumCFid := ""

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa271FsFid  ³Autor³ Leandro Nogueira      ³ Data ³17/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definir o numero do cartao fidelidade informado como pagto ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa271FsFid(cNumCar)

cNumCFid:= cNumCar

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FR271FEsVe()³ Autor ³Venda Clientes         ³ Data ³19/11/2010³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o processo de estorno do Front-Loja                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL					    	                          	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                    	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja (F12 + 27)                                  	       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271FEsVe()
Local oEstorno := Nil       //Objeto da classe de estorno
Local nPosL4Est     := SL4->(FieldPos("L4_ESTORN"))  //Posicao do campo L4_ESTORN
Local nPosL1Sta     := SL1->(FieldPos("L1_STATUES"))  //Posicao do campo L1_STATUES
Local cMvEst        := LjGetStation("WSSRV")  //Url do WebService de comunicacao com retaguarda

If nPosL4Est = 0 .Or. nPosL1Sta = 0 .and. !AliasInDic("MBZ")
	MsgStop(STR0107)//Para utilizacao da rotina de estorno; faz-se necessária a criacao dos campos: L4_ESTORN e L1_STATUES e tabela MBZ, conforme FNC 000000225902010
	Return Nil
EndIf

If Empty(cMvEst)
	MsgStop(STR0109)//"Para utilizacao a rotina de estorno, faz-se necessário o cadastro da URL do WebService de Estorno, no cadastro de estações."
	Return Nil
EndIf

oEstorno := LjClEstVen():New(LJGetStation("SERIE"),xNumCaixa(), LJGetStation("PDV"), dDataBase,0, .F.)
oEstorno:ExibeFrmCupom()
If oEstorno:ValidaOrcamento(4)
	If oEstorno:ConfirmaOrcamento(4)
		oEstorno:RealizaEstorno()
	EndIf
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FR271Mostruario³ Autor ³Venda Clientes         ³ Data ³10/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a tela para identificacao do item da venda como MOSTRUARIO³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL					    	                          	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                    	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja (F12 + 25)                                  	       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271Mostruario(aMostruario)

Local oDlgMostruario := Nil
Local oComboTipo     := Nil
Local nOpcClick      := 0
Local cOpcCombo      := ""
Local cObsMostruario := ""

//Zera os dados do Mostruario
aMostruario := {"",""}

While .T.
	oDlgMostruario  := TDialog():New(000,000,150,400,OemToAnsi(STR0095),,,,,,,,oMainWnd,.T.) //"Tipo de Peça: Mostruário ou Saldão"
		TGroup():New(003,003,oDlgMostruario:nClientHeight/2-15,oDlgMostruario:nClientWidth/2-5,"",oDlgMostruario,,,.T.,.F. )
			TSay():New(006,005,{|| STR0096 },oDlgMostruario,,,.F.,.F.,.F.,.T.,,,100,008) //"Tipo de Peça"
			@ 006,050 Combobox oComboTipo Var cOpcCombo Items {STR0101,STR0102,STR0103} Pixel Size oDlgMostruario:nClientWidth/2-60,009 Of oDlgMostruario //"N=Normal"#"M=Mostruário"#"S=Saldão"

			TSay():New(020,005,{|| STR0097 },oDlgMostruario,,,.F.,.F.,.F.,.T.,,,100,008) //"Observação"
			@ 020,050 Get cObsMostruario Memo Size oDlgMostruario:nClientWidth/2-60,oDlgMostruario:nClientHeight/2-37 Of oDlgMostruario Pixel

		TButton():New(oDlgMostruario:nClientHeight/2-12,003,OemToAnsi(STR0104),oDlgMostruario,{|| nOpcClick := 1, oDlgMostruario:End()},040,009,,,,.T.,,,,{|| })   //"Ok"
		TButton():New(oDlgMostruario:nClientHeight/2-12,047,OemToAnsi(STR0105),oDlgMostruario,{|| nOpcClick := 0, oDlgMostruario:End()},040,009,,,,.T.,,,,{|| })   //"Cancelar"
	oDlgMostruario:Activate(,,,.T.)

	//Valida dos dados
	If nOpcClick == 0
		Exit
	Else
		If Empty(cObsMostruario) .And. SubStr(cOpcCombo,1,1) <> "N"
			Aviso(STR0098,STR0099,{STR0100},,) //"Observação Não Informada"#"Para vendas de itens de Mostruário ou Saldão é obrigatório informar a observação"#"Voltar"
			Loop
		Else
			aMostruario[1] := SubStr(cOpcCombo,1,1)
			aMostruario[2] := cObsMostruario
			Exit
		EndIf
	EndIf
EndDo

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FR271Lista	 ³ Autor ³Venda Clientes         ³ Data ³16/03/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta a Lista de Presentes			                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL					    	                          	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                    	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja (F12 + 32)                                  	       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271Lista(cCodProd	, oTimer		, oHora			, cHora			,;
					oDoc		, cDoc			, oPDV			, cPDV			,;
					nLastTotal	, nVlrTotal		, nLastItem		, nTotItens		,;
					nVlrBruto	, oVlrTotal		, oCupom		, oTotItens		,;
					oOnOffLine	, nTmpQuant		, nVlrItem		, nValIPIIT		,;
					nValIPI		, oFotoProd		, oProduto		, oQuant		,;
					oVlrUnit	, oVlrItem		, oDesconto		, cSimbCor		,;
					cOrcam		, cProduto		, nQuant		, cUnidade		,;
					nVlrUnit	, oUnidade		, lF7   		, cCliente		,;
					cLojaCli	, cVendLoja		, lOcioso		, lRecebe		,;
					lLocked		, lCXAberto		, lDescIT		, nVlrDescTot	,;
					aItens		, aICMS			, nVlrMerc		, _aMult		,;
					_aMultCanc	, aParcOrc		, cItemCOrc		,aParcOrcOld	,;
					lAltVend	, lImpNewIT		, lFechaCup		,cContrato		,;
					aCrdCliente	, aContratos	, aRecCrd		,aTEFPend		,;
					aBckTEFMult	, cCodConv		, cLojConv		,cNumCartConv	,;
					uCliTPL		, uProdTPL		, lDescTotal	,lDescSE4		,;
					aVidaLinkD	, aVidaLinkc 	, nVidaLink		,nValTPis		,;
					nValTCof	, nValTCsl		, lVerTEFPend	,nTotDedIcms	,;
					lImpOrc 	, nVlrPercTot	, nVlrPercAcr	,nVlrAcreTot	,;
					nVlrDescCPg	, nQtdeItOri	, aMoeda		,aSimbs			,;
					nMoedaCor	, aImpsSL1		, aImpsSL2		,aImpsProd		,;
					aImpVarDup	, aTotVen		, aCols			,nVlrPercIT		,;
					nTaxaMoeda  , aHeader		, nVlrDescIT	,oMensagem		,;
					oFntMoeda	, cMensagem		, cTipoCli		,lBscPrdON		,;
					aReserva 	, lReserva		, lAbreCup		,nValor			,;
					cCupom		, aRegTEF		, lRecarEfet	,lDescITReg		,;
					aMostruario	)

Local aProdLista	:= {}					//Array contendo todos os produtos selecionados pelo usuario para compra da lista
Local aArea			:= GetArea()			//Salva a Area Atual
Local nItensSel		:= 0					//Variavel de controle do laco
Local cEntrega		:= ""					//Tipo de Entrega
Local lOrc			:= .F.					//Orcamento importado
Local nTamCod		:= Len(cCodProd)		//Salvo o tamanho da variavel de Codigo do Produto
Local aItemLst		:= {}					//Itens de Lista que ja constam no aCols
Local aAreaSL2		:= SL2->( GetArea() )	//Grava a Area SL2
Local lTemEntreg	:= .F.					//Determina se um dos itens possui o campo L2_ENTREGA igual a "3"


DbSelectArea("SL2")
DbSetOrder(1)
If SL2->( DbSeek( xFilial("SL2") + cOrcam ) )
	While !SL2->( Eof() ) .AND. xFilial("SL2") + cOrcam == SL2->L2_FILIAL + SL2->L2_NUM
		If !Empty(SL2->L2_CODLPRE)
			aAdd(aItemLst,{	SL2->L2_CODLPRE,;		//Codigo da Lista
							SL2->L2_ITLPRE,;		//Item do Codigo da Lista
							SL2->L2_QUANT})			//Quantidade do Item
		EndIf
		SL2->( DbSkip() )
	End
EndIf

RestArea(aAreaSL2)
/*
±±ºPrograma  ³Loja845   ºAutor  ³Vendas Cliente        º Data ³28/02/11         º±±
±±ºDesc.     ³Rotina para consulta de listas de presentes.                      º±±
±±ºParametros³Exp01[N] : Comportamento rotina 1.Busca + Edicao 2.Busca + Retornoº±±
±±º          ³Exp02[N] : Disp.modo 2 define estrutura retorno de dados :        º±±
±±º          ³           1.Cabecalho 2.Itens 3.Cabecalho + Itens                º±±
±±º          ³Exp03[C] : Determinar o tipo de lista sera pesquisado (ME1_TIPO)  º±±
±±º          ³Exp04[C] : Numero da lista                                        º±±
±±º          ³           Modo 2 + Retorno 1 : retorno dados cab. sem interface  º±±
±±º          ³           Modo 2 + Retorno 2|3 : abrir componente sel.produtos   º±±
±±º          ³Exp05[L] : Determina se a pesquisa eh online ou por webservice    º±±
±±º          ³Exp06[L] : Abrir interface de digitacao de nomes                  º±±
±±º          ³Exp07[L] : Enviar mensagem aos atores (protagonistas)             º±±
±±º          ³Exp08[L] : Listar apenas itens com quantidade em aberto           º±±
±±º          ³Exp09[C] : Origem a ser considerado para os itens                 º±±
±±º          ³Exp10[C] : Filtro ME2                                             º±±
±±º          ³Exp11[C] : Multi-selecao                                          º±±
±±º          ³Exp12[C] : Marcar todos                                           º±±
±±º          ³Exp13[C] : Quantidade utilizada                                   º±±
±±º          ³Exp14[C] : Permite alterar quantidade?                            º±±
±±º          ³Exp15[C] : Permite alterar modo de entrega?                       º±±
±±º          ³Exp16[C] : Tipo de evento que a rotina devera pesquisar           º±±
±±º          ³Exp17[C] : Status da lista 1.Ativa 2.Inativa                      º±±
*/

aProdLista	:= 	Loja845(2		,3			,NIL		,NIL		,;
						.F.		,.T.		,.T.		,.T.		,;
						NIL		,NIL		,.T.		,.T.		,;
						aItemLst,.T.		,.T.		,NIL		,;
						1		)



//----------------------------------------------------------------------------//
// Verifica se o cliente é o Dono do Envento  (criador da lista de presentes) //
//----------------------------------------------------------------------------//

If Alltrim(cCliente) == Alltrim(SL1->L1_CLIENTE)
	MsgAlert(STR0127)//Venda não permitida. O cliente é o Dono do Evento da Lista de Presentes.
Else

	If ValType(aProdLista) == "A"
		//Percorro todos os itens que foram selecionados pelo usuario
		For nItensSel	:= 1 to Len(aProdLista[2])
			cCodProd	:= aProdLista[2][nItensSel][2]	//Codigo do Produto
			cEntrega	:= IIF(aProdLista[2][nItensSel][5] == "2","2","3")	//1=Retira Posterior;2=Retira;3=Entrega
			nQuant		:= aProdLista[2][nItensSel][4]	//Codigo do Produto

			FR271AProdOK(	NIL			, NIL			, NIL			, .F.			,;
				@cCodProd	, @oTimer		, @oHora		, @cHora		,;
				@oDoc		, @cDoc			, @oPDV			, @cPDV			,;
				@nLastTotal	, @nVlrTotal	, @nLastItem	, @nTotItens	,;
				@nVlrBruto	, @oVlrTotal	, @oCupom		, @oTotItens	,;
				@oOnOffLine	, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
				@nValIPI	, @oFotoProd	, @oProduto		, @oQuant		,;
				@oVlrUnit	, @oVlrItem		, @oDesconto	, @cSimbCor		,;
				@cOrcam		, @cProduto		, @nQuant		, @cUnidade		,;
				@nVlrUnit	, @oUnidade		, @lF7   		, NIL			,;
				@cCliente	, @cLojaCli		, @cVendLoja	, @lOcioso		,;
				@lRecebe	, @lLocked		, @lCXAberto	, @lDescIT		,;
				@nVlrDescTot, @aItens		, @aICMS		, @nVlrMerc		,;
				@_aMult		, @_aMultCanc	, @lOrc			, @aParcOrc		,;
				@cItemCOrc	, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
				@lFechaCup	, @cContrato	, @aCrdCliente	, @aContratos	,;
				@aRecCrd	, @aTEFPend	   	, @aBckTEFMult	, @cCodConv		,;
				@cLojConv	, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
				@lDescTotal	, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,;
				@nVidaLink	, @nValTPis		, @nValTCof		, @nValTCsl		,;
				@lVerTEFPend, @nTotDedIcms	, @lImpOrc 		, @nVlrPercTot	,;
				@nVlrPercAcr, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
				@aMoeda		, @aSimbs		, @nMoedaCor	, NIL			,;
				@aImpsSL1	, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
				@aTotVen	, @aCols		, @nVlrPercIT	, @nTaxaMoeda  	,;
				@aHeader	, @nVlrDescIT	, @oMensagem	, @oFntMoeda	,;
				@cMensagem	, @cTipoCli		, @lBscPrdON	, NIL			,;
				cEntrega  	, @aReserva 	, @lReserva		, @lAbreCup		,;
				@nValor		, @cCupom		, NIL		 	, NIL			,;
				@aRegTEF	, @lRecarEfet	, @lDescITReg	, NIL			,;
				NIL			, NIL			, @aMostruario	, NIL			)

			RecLock("SL2",.F.)
			SL2->L2_CODLPRE	:= aProdLista[1][1]
			SL2->L2_ITLPRE	:= aProdLista[2][nItensSel][1]
			SL2->L2_ENTREGA	:= cEntrega
			SL2->L2_RESERVA	:= "S"
			SL2->L2_MSMLPRE	:= aProdLista[2][nItensSel][7]
			SL2->( MsUnLock() )

			//Caso um dos itens selecionados seja de entrega, tenho que alterar os campos do cabecalho do orcamento
			If !lTemEntreg .AND. cEntrega == "3"
				lTemEntreg	:= .T.
			EndIf
		Next nItensSel

		If lTemEntreg
			RecLock("SL1",.F.)
			SL1->L1_TIPO	:= "P"
			SL1->L1_OPERACA	:= "C"
			SL1->( MsUnLock() )
		EndIf
	EndIf
EndIf

RestArea(aArea)

cCodProd := Space(nTamCod)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LjRegRefsh³ Autor ³ Vendas Clientes       ³ Data ³27/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desposiciona e reposiciona no mesmo registro. Utilizado em ³±±
±±³			 | caso de registro alterado por outra thread				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjRegRefsh(cTab)

Local nRecno := 0

DEFAULT cTab := ""

If !Empty(cTab)
	nRecno := (cTab)->(RecNo())
	(cTab)->(DbSkip())
	(cTab)->(DbGoto(nRecno))
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FR271FMovAbr³ Autor ³ Vendas Clientes       ³ Data ³23/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar se existe movimento sem conferencia de caixa       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271FMovAbr(lTemMov, nRecSLW)
Local aAreaSL1	:= SL1->( GetArea() )	// Grava a Area SL1
Local nRecno	:= 0					// Registro da tabela SL1

// Registro da tabela SLW
SLW->(DbGoto(nRecSLW))

// Posiona na tabela SL1
DbSelectArea("SL1")
dbSetOrder(7)
nRecno := SL1->(LastRec())
SL1->(DbGoto(nRecno))

// Comparacao dos dados SL1 x SLW
If SL1->L1_EMISSAO >= SLW->LW_DTABERT
	lTemMov := Iif(SL1->L1_HORA >= SLW->LW_HRABERT,.T., .F.)
Endif

// Retorna SL1
RestArea(aAreaSL1)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PreparaCancNfce³ Autor ³ Vendas Clientes    ³ Data ³29/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta tela para informar o numero do doc a ser cancelado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PreparaCancNfce()

Local lRet			:= .F.
Local oDlgVen		:= Nil
Local oBtnConf		:= Nil
Local oBtnCanc		:= Nil
Local oSerie		:= Nil
Local oCupom		:= Nil
Local aOrdSl1		:= SL1->(GetArea())
Local cSerie		:= LjGetStation("LG_SERIE")
Local cPdv			:= LjGetStation("LG_PDV")
Local nTamL1DOC 	:= TamSX3("L1_DOC")[1]
Local nTamCup		:= nTamL1DOC
Local cCupom		:= Space(nTamL1DOC)
Local cPic			:= Replic("9", nTamL1DOC)
Local nSpedExc 		:= GetNewPar("MV_SPEDEXC",24)					// Indica a quantidade de horas q a NFe pode ser cancelada
Local nNfceExc      := GetNewPar("MV_NFCEEXC",0)   					// Indica a quantidade de horas q a NFCe pode ser cancelada
Local dDtdigit		:= SL1->L1_EMISNF								// Data da emissao da nota
Local nHoras 		:= 0											// Quantidade de horas da hora atual
Local lUseSAT 		:= LjUseSat()
Local cTitle		:= STR0135 										// "NFC-e"
Local cMsg			:= STR0126 										// "NFC-e não encontrada ou já estornada anteriormente."
Local nLastRecno 	:= 0											// R_E_C_N_O_ do ultimo registro inserido
Local lEndFis   	:= SuperGetMv("MV_SPEDEND",, .F.)				// Se estiver como F refere-se ao endereço de Cobrança se estiver T  ao  endereço de Entrega.
Local cEstSM0		:= IIf(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT)
Local cHoraUF 		:= FwTimeUF(cEstSM0)[2]

If Empty(cHoraUF)
	cHoraUF := Time()
EndIf

If lUseSAT
	cTitle	:= cSiglaSat //"SATCF-e"
	cMsg	:= StrTran(STR0153,"SAT",cSiglaSat) //"SAT não encontrado"
EndIf

/*
Faz a busca pela ultima venda com documento emitido (ultimo registro inserido), 
pois se usarmos DbGoBottom, passamos a depender da ordem do indice
*/
nLastRecno := SL1->( LastRec() )
SL1->( DbGoto(nLastRecno) )

While ( SL1->(!BoF()) .AND. SL1->(!EoF()) ) .AND. SL1->( Deleted() ) .OR. Empty(SL1->L1_DOC)
	SL1->( DbSkip(-1) )
End

cCupom := SL1->L1_DOC
nTamCup:= Len( AllTrim(SL1->L1_DOC) )

DEFINE MSDIALOG oDlgVen TITLE STR0134 + cTitle FROM 323,112 TO 440,398 PIXEL STYLE DS_MODALFRAME STATUS //"Estornar" "NFC-e"

	@ 005,007 SAY   STR0122 SIZE 100,10 OF oDlgVen PIXEL //"Digite os dados da venda"

	@ 020,007 SAY  cTitle	SIZE 40,08 OF oDlgVen PIXEL //"NFC-e" ou "SATCF-e"
	@ 020,045 MSGET oCupom  VAR cCupom  picture cPic SIZE 38,08  OF oDlgVen PIXEL

	@ 020,090 SAY   STR0123	SIZE 18,08  OF oDlgVen PIXEL  //"Série"
	@ 020,110 MSGET oSerie  VAR cSerie  picture "@!" SIZE 09,08 WHEN .F. OF oDlgVen PIXEL

	@ 040,030 BUTTON oBtnConf PROMPT STR0124 SIZE 40,10 OF oDlgVen PIXEL ACTION (lRet := .T., oDlgVen:End() ) //"&Continuar"
	@ 040,073 BUTTON oBtnCanc PROMPT STR0125 SIZE 40,10 OF oDlgVen PIXEL ACTION oDlgVen:End()  	// "&Cancela"

ACTIVATE MSDIALOG oDlgVen CENTERED

If lRet
	//Tratamos a informação digitada
	cSerie := PadR( cSerie, TamSX3("L1_SERIE")[1] )
	cCupom := PadR( STRZero(Val(cCupom),nTamCup), nTamL1DOC )

	SL1->( DBSetOrder(2) )	//L1_FILIAL + L1_SERIE + L1_DOC + L1_PDV
	lRet := SL1->( DBSeek(xFilial("SL1") + cSerie + cCupom + cPdv) )
	If !lRet 
		MsgInfo("'"+cCupom+"' " + cMsg,STR0002) //"NFC-e não encontrada ou já estornada anteriormente." ou "SAT não encontrado"
		RestArea(aOrdSL1)
	Endif
EndIf

If !lUseSAT
	// Verifica quando foi realizada a emissão da NFC-e e bloqueia caso for maior que o conteúdo do parâmetro MV_SPEDEXC
	nHoras := SubtHoras(IIF(!Empty(SL1->L1_EMISNF),SL1->L1_EMISNF,dDtdigit),IIF(!Empty(SL1->L1_HORA),SL1->L1_HORA,SL1->L1_HORA),dDataBase, substr(cHoraUF,1,2)+":"+substr(cHoraUF,4,2) )
	//Tratamento para manter o legado do parametro MV_SPEDEXC
	If nNfceExc <= 0
	   nNfceExc := nSpedExc
	EndIf
	
	If nHoras > nNfceExc
		If IsBlind()
			Conout("Não foi possivel excluir a nota, pois o prazo para o cancelamento da NFC-e é de " + Alltrim(STR(nNfceExc)) +" horas")
		Else
			MsgAlert("Não foi possivel excluir a nota, pois o prazo para o cancelamento da NFC-e é de " + Alltrim(STR(nNfceExc)) +" horas")
		EndIf
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FRTAFNfceAberta³ Autor ³ Vendas Clientes    ³ Data ³29/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a nfc-e esta em aberto ou não p/ o cancelamento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTAFNfceAberta()

Local lRet := !( SL1->L1_SITUA $ "TX|07|00|10" )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FR271FImpSAT
Reimprime a ultima venda SAT novamente.

@param		
@author	Varejo
@version	P11.8
@since		27/10/2016
@return	Nil
@obs		
@sample	
/*/
//-------------------------------------------------------------------
Function FR271FImpSAT()
Local aAreaSL1 := SL1->(GetArea())

//Posiciona na ultima venda
SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
SL1->(DBGoBottom())

If SL1->(!EOF()) .And. SL1->(!BOF())  .And. !Empty(SL1->L1_DOC) .And.;
	!Empty(SL1->L1_ESPECIE) .And. !Empty(SL1->L1_SERSAT) .And. !Empty(SL1->L1_KEYNFCE)
	
	MsgInfo(STR0141 + AllTrim(SL1->L1_DOC) + StrTran(STR0142,"SAT",cSiglaSat) ,STR0002) //#"Será impresso o Documento nº '"##"' referente a ultima venda SAT." ###"Atenção"
	LJSatReImp()
Else
	MsgInfo(StrTran(STR0143,"SAT",cSiglaSat),STR0002) //#"A ultima venda não corresponde a uma venda SAT." ##"Atenção"
EndIf

RestArea(aAreaSL1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FrtFSLCanc
Ajusta a venda caso haja algum problema no cancelamento

@param		cTipo , caracter , tipo do cancelamento
@param		cLiMsg, caracter , mensagem para a tabela SLI	
@author		Varejo
@version	P12
@since		13/01/2017
@return		lRet , logico , retorna se foi ok ou não
@obs		
@sample	
/*/
//-------------------------------------------------------------------
Static Function FrtFSLCanc(cTipo,cLiMsg)
Local lRet := .T.
Local aSL1 := {}

Default cTipo	:= ""
Default cLiMsg	:= "" 

If !Empty(AllTrim(cTipo))
	
	If cTipo == "C" 
		If SL1->L1_SITUA == "TX"
			aSL1	:= {{"L1_SITUA",	"07"}}								// "07" - Solicitado o Cancelamento do Cupom
			cLiMsg	:= SL1->L1_NUMORIG+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV+"|" 	// Monta mensagem para cancelamento na Retaguarda via SLI
		Else
			aSL1	:= {{"L1_STORC",	"C"}}	// "C" - Sinaliza Venda Cancelada, para gerar SLI apos subir a venda para retaguarda, nesse momento não possui L1_NUMORIG
		EndIf
	ElseIf cTipo == "R"
		aSL1 := {{"L1_SITUA",	"00"}}	// Retira a solicitação de cancelamento
		
		If AllTrim(SL1->L1_STORC) == "C" //Restaura a venda senão a venda "sobe" como venda cancelada
			Aadd(aSL1,{"L1_STORC",""})
		EndIf
	EndIf
	
	FR271BGeraSL("SL1", aSL1)
EndIf

Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} FrtFCncTEF
Faz o cancelamento da transação TEF

@author		Julio.Nery
@version	P11.8
@since		17/04/2017
@return		lRet , logico , retorna se foi ok ou não
/*/
//------------------------------------------------------------------------
Function FrtFCncTEF(lEstTef ,	lIsDiscado ,	lTefOk ,	cSupervisor ,;
 					lCancTef,	lVendTEF)
Local lRet	:= .F.

Default lEstTef		:= .F.
Default lIsDiscado	:= lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo()))
Default lTefOk		:= .F.
Default cSupervisor	:= Space(15)
Default lCancTef	:= .F.
Default lVendTEF	:= !isBlind() .AND. lUsatef .AND. SL1->L1_VENDTEF == "S" .AND. (SL1->L1_CARTAO > 0 .OR. SL1->L1_VLRDEBI > 0)

lRet := lEstTef

While !lRet
	/*Precisa verificar: (1-) pois em ambientes Pay&Go caso não haja TEF, o retorno da função 
	é falso e com isso emite mensagem " não é possível cancelar o TEF". 
	(2-) em vendas comuns , sem TEF também não precisa passar aqui*/
	If AllTrim(SL1->L1_VENDTEF) <> "S"
		lRet := .T.
		Exit
	EndIf
	
	LjLogFront("FRTA271F - cancelamento TEF" + IIf(lIsDiscado ," Discado", ""))
	If lIsDiscado
		lRet := LOJA010T("X")
	ElseIf cTipTEF == TEF_CLISITEF
		// Caso o SiTef esteje habilitado e a venda
		If Type("oTef") <> "U" .And. ValType(lTefOk) == "L"
			lRet := Lj140CnAdm(.F., @lVendTef, @oTEF , .F.)
		Else
			lRet := .T.
		EndIf
	Else
		lRet := .T.
	EndIf
	LjLogFront("FRTA271F - cancelamento TEF" + IIf(lIsDiscado ," Discado", "") + "- Retorno : " + IIf(lRet,"Sucesso","Falha"))

	If !lRet  // Caso de problemas verifica se tenta novamente
		If MsgYesNo(" Não foi possivel cancelar o TEF, deseja continuar mesmo assim ? "+;
				CRLF+CRLF+"Obs : O Tef poderá ser cancelado posteriormente pela Rotinas TEF - Rotinas Gerencias ")
			If lCancTef .Or. LJProfile(8,@cSupervisor)
				lRet := .T.
				LjLogFront("FRTA271F - ESCOLHEU CONTINUAR SEM CANCELAR O TEF " +; 
							"- Dados da Venda (Filial+Doc+Serie): " + SL1->L1_FILIAL + "-" + SL1->L1_DOC + "-" + SL1->L1_SERIE +;
							"- Usuário : " + cSupervisor)
			EndIf
		EndIf
	EndIf
End

lEstTef := lRet

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} ReImpNFCe
Reimpressao da NFC-e (replicado da versao 11.80 - chamado TVOMQP)
@author  michael.gabriel
@since   07/11/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ReImpNFCe()
Local lRet			:= .F.
Local oDlgVen		:= Nil
Local oBtnConf		:= Nil
Local oBtnCanc		:= Nil
Local oSerie		:= Nil
Local oCupom		:= Nil
Local aOrdSl1		:= SL1->(GetArea())
Local cSerie		:= LjGetStation("LG_SERIE")
Local cPdv			:= LjGetStation("LG_PDV")
Local nTamL1DOC 	:= TamSX3("L1_DOC")[1]
Local nTamCup		:= nTamL1DOC
Local cCupom		:= Space(nTamL1DOC)
Local cPic			:= Replic("9", nTamL1DOC)
Local nFatorP 		:= 1 // Fator de reserva para venda do tipo pedido
Local lReimpPed		:= .F.
Local aRetImp		:= {}

//Sugestao da ultima venda
/*Necessario alterar a ordem para L1_FILIAL + L1_EMISSAO pois quando posicionado no orçamento, nem sempre o último
registro lógico é o último registro físico da tabela. A numeracao do orçamento pode variar.*/
SL1->( DbSetOrder(4) ) //L1_FILIAL+L1_EMISSAO
SL1->( DBGoBottom() )
If SL1->(!EoF()) .AND. SL1->(!BoF()) .AND. !Empty(SL1->L1_DOC)
	cCupom := SL1->L1_DOC
	nTamCup:= Len(AllTrim(SL1->L1_DOC))
ElseIf Empty(SL1->L1_DOC) .And. !Empty(SL1->L1_DOCPED) // Venda tipo pedido
	lReimpPed := .T.
	MsgInfo(STR0141 + AllTrim(SL1->L1_DOCPED) + STR0145 ,STR0002) //#"Será impresso o Documento nº '"##"' "referente ao último pedido." ###"Atenção"
	// Reimpressão do cupom não fiscal (Pedido)
	/* Foi adicionado na reimpressão do cupom NFCE a reimpressão do cupom SCRPED em caso de venda Mista.
	Necessário pois caso haja perda de comunicação com a impressora será necessário imprimir os comprovantes.*/
	aRetImp := Lj7ImpCNF(,nFatorP,,,,,,,,,,,,,,lReimpPed)
	If aRetImp[1]
		MsgAlert(STR0146) //"Reimpressão do pedido executada com sucesso!"
	Else
		MsgAlert(STR0147) //"Problemas na reimpressão do pedido. Verifique!"
	EndIf	
EndIf

/*Somente mostra a tela de seleção de nota se a venda não for somente de pedido*/
If !lReimpPed
	DEFINE MSDIALOG oDlgVen TITLE STR0138 FROM 323,112 TO 440,398 PIXEL STYLE DS_MODALFRAME STATUS //"Reimpressão de NFC-e"
	
		@ 005,007 SAY STR0139 SIZE 100,10 OF oDlgVen PIXEL //"Informe o número e série da NFC-e."
	
		@ 020,007 SAY  STR0135	SIZE 40,08 OF oDlgVen PIXEL //"NFC-e"
		@ 020,045 MSGET oCupom  VAR cCupom  picture cPic SIZE 38,08  OF oDlgVen PIXEL
	
		@ 020,090 SAY   STR0123	SIZE 18,08  OF oDlgVen PIXEL  //"Série"
		@ 020,110 MSGET oSerie  VAR cSerie  picture "@!" SIZE 09,08  OF oDlgVen PIXEL
	
		@ 040,030 BUTTON oBtnConf PROMPT STR0124 SIZE 40,10 OF oDlgVen PIXEL ACTION (lRet := .T., oDlgVen:End() ) //"&Continuar"
		@ 040,073 BUTTON oBtnCanc PROMPT STR0125 SIZE 40,10 OF oDlgVen PIXEL ACTION oDlgVen:End()  	// "&Cancela"
	
	ACTIVATE MSDIALOG oDlgVen CENTERED
EndIf

If lRet
	//Tratamos a informação digitada
	cSerie := PadR( cSerie, TamSX3("L1_SERIE")[1] )
	cCupom := PadR( STRZero(Val(cCupom),nTamCup), nTamL1DOC )

	SL1->( DBSetOrder(2) )	//L1_FILIAL + L1_SERIE + L1_DOC + L1_PDV
	lRet := SL1->( DBSeek(xFilial("SL1") + cSerie + cCupom + cPdv) )
	If lRet
		CursorWait()
		LjNFCeImp(SL1->L1_FILIAL, SL1->L1_NUM)
		CursorArrow()
	Else
		MsgInfo("'"+cCupom+"' " + STR0140,STR0002) //"NFC-e não encontrada neste PDV. Verifique se esta NFC-e foi gerada em outro PDV."
		RestArea(aOrdSL1)
	Endif
EndIf

Return lRet
