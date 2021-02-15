#INCLUDE "PROTHEUS.CH"            
#INCLUDE "FRTA800.CH"
#INCLUDE "AUTODEF.CH"

Static nParMax := 0 // NUMERO MAXIMO DE PARCELA

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FRTA800   ³ Autor ³ Vendas CRM            ³ Data ³03/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Simulador de Formas de Pagamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  FrontLoja                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function FRTA800( 	nValor		,lUsaTef 	,aMoeda		, lRecebe 		,; 
 					nTXJuros	,aPgtos 	,cDoc		, oCupom	 	,;
 					cCupom		,nVlrTotal	,nVlrBruto	, oVlrTotal		,;
					nMoedaCor	,cSimbCor	,nTaxaMoeda	,oPgtos		 	,;
					oPgtosSint	,aPgtosSint ,lRecebe	,aParcOrc		,;
					aParcOrcOld ,nVlrPercAcr,nVlrAcreTot,nVlrDescCPg 	,;
					aMoeda		,aSimbs	 	,aCols		,aCProva		,;	
					aFormCtrl	,nTroco 	,nTroco2 	,lDescCond		,;
					nDesconto	,aDadosCH   ,cItemCond	,lCondNegF5		,;
					aParcelas	,cCliente   ,cLojaCli  	,nVlrDescTot   	,;
					aRegTEF    ,lRecarEfet	,aTefBkpCS	, oteste	)

// Variaveis Locais da Funcao
Local aSavArea	 	:= GetArea() 				// salva area
Local cFormPgto	 	:= Space(25) 				// forma de pagamento
Local cAdmCartao 	:= Space(25)				// Administradora do cartao
Local nNrParc	 	:= 0 						// numero de cartao
Local nParcSel		:= 999						// numro de pac selecionado
Local dData 		:= DtoC(dDataBase)			// Data
Local cDesc			:= ""						// Descricao
Local cDescFPgto 	:= Space(25)				// descricao fm pagamento
Local cDescACartao	:= Space(25)				// descricao Adm Cartao
Local oFormPgto		:= Nil						// Ob Tela
Local oAdmCartao	:= Nil                   	// Ob Tela
Local oNrParc		:= Nil						// Ob Tela
Local oDescFPgto	:= Nil						// Ob Tela
Local oDescACartao	:= Nil						// Ob Tela
Local nValorSL2		:= 0						// Valor do SL2
Local nDescTot		:= 0                      	// Valor do desconto
Local oListBox      := Nil      				// Ob Tela
Local oValorSL2   	:= Nil						// Ob Tela
Local oLogoAdm      := Nil						// Ob Tela
Local aListBox 		:= {}         				// Arrray para list Box datela 
Local aRetnParc		:= {}						// Arrray para list Box datela 	
Local aAux			:= {}						// Arrray para list Box datela 
Local  oDlg		:= Nil						// Ob Tela	
Local aFormPag  	:= {}						// Inbforma pagamentp
Local cSimbCheq 	:= AllTrim(MVCHEQUE)		// Simbolo de cheque	
Local nOpc			:= 2        				// Opcao
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.)  // Se tem tef
Local cFormaId		:= Space(TamSX3("L4_FORMAID")[1])	//Inicializa ID Cartao para multi-tef
Local nIntervalo	:= SuperGetMV("MV_LJINTER", ,30)  	//Define o intervalo(em dias) DEFAULT entre as parcelas
Local nValMax 		:= nValor							// Valor Max
Local cMoedaVen     := '' 								// Moeda de venda
Local nPosMoeda 	:= nMoedaCor						// Numero da Moeda
Local cSimbMoeda	:= SuperGetMV("MV_SIMB"+AllTrim(Str(nPosMoeda))) 	// Simbolo da Moeda
Local lDifCart      := .F. 												// se diferencia cartao
Local aValePre		:= {}												// Vale presente
Local aColsMAV    	:= {}        										// referencia de função
Local lUsaAdm       := .T.												// se usa Adm
Local cDesconto		:= "00,00"											// valor do desconto
Local cDesAdm		:= ''												// desconto da adm
Local cValorSL2		:= "00,00"

DbSelectArea('MDV')
DBSetOrder(1)

aFormPag  := MonFormPag( @aFormPag )   

// Adiciona o Valor da Venda corrente
nValorSL2 := 	nVlrTotal
cValorSL2 :=  	cSimbMoeda+ ' ' + TRANSFORM(nValorSL2,  '@E 99,999,999.99')
cDesconto :=  	cSimbMoeda+ ' ' + TRANSFORM(nVlrDescTot,'@E 99,999,999.99')   //cValToChar(nVlrDescTot)

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0001) FROM C(190),C(183) TO C(650),C(460) PIXEL // "Simulador para Forma de Pagto"
                          
	@ C(001),C(002) TO C(100),C(134) LABEL  STR0002 PIXEL OF oDlg //"Dados do Simulador"

	@ C(016),C(003) Say STR0003 Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg // "Valor da Venda :"
	@ C(014),C(060) Say "" Var cValorSL2 Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg

	@ C(029),C(003) Say STR0004 Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg		//"Desconto no Total: "
	@ C(029),C(060) Say "00,00" Var cDesconto Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg	

	@ C(042),C(003) Say  STR0005 Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg		// "Forma de Pagamento : "
	@ C(040),C(054) MsGet oFormPgto Var cFormPgto F3 "24" Size C(025),C(009) Valid VldFormPg(@cFormPgto,@cDescFPgto,@oDescFPgto,oListBox,;
																								@aListBox,nValorSL2,@nNrParc,@oNrParc,@oValorSL2,@oAdmCartao,@cAdmCartao,@cDescACartao,@oLogoAdm, @nParcSel, @oAdmCartao) COLOR CLR_BLACK PIXEL OF oDlg	
	@ C(042),C(080) Say "" Var cDescFPgto Size C(058),C(016) COLOR CLR_BLACK PIXEL OF oDlg		

	
	
	@ C(054),C(003) Say STR0006  Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg		//"Administradora : "
	@ C(052),C(054) MsGet oAdmCartao Var cAdmCartao F3 "SAE" Size C(025),C(009) Valid VldAdmCartao(cAdmCartao,@cDescACartao,@cFormPgto,@oDescACartao,oListBox,@oLogoAdm,;
							@aListBox,nValorSL2,@nNrParc,@oNrParc,@oValorSL2, @cDesAdm) COLOR CLR_BLACK PIXEL OF oDlg 		
	@ C(054),C(080) Say "" Var cDesAdm Size C(058),C(016) COLOR CLR_BLACK PIXEL OF oDlg		
	
	
	@ C(066),C(003) Say STR0007 	Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg	    // "Nro de Parcelas: " 
	@ C(064),C(054) MsGet oNrParc Var nParcSel Size C(025),C(009) Valid VldNrParc(nParcSel) COLOR CLR_BLACK PIXEL OF oDlg
	
 	@ C(013),C(110) Button OemtoAnsi("&Ok") Size C(020),C(010) PIXEL OF oDlg ; 
	Action(FR271FFormPag(			@aFormPag	, @cDesAdm 			, @cFormPgto		,				,;
									@cDoc		, @oCupom			, @cCupom			, @nVlrTotal 	, ; 
									@nVlrBruto	, @oVlrTotal		, @nMoedaCor		, @cSimbCor		, ;
									@nTaxaMoeda	, oPgtos			, @oPgtosSint		, @aPgtos		, ;
									@aPgtosSint	, @lRecebe			, @aParcOrc			, @aParcOrcOld 	, ;
									@nVlrPercAcr, @nVlrAcreTot		, @nVlrDescCPg 		, @aMoeda		, ;	
									@aSimbs		, @aCols			, @aCProva			, @aFormCtrl	, ;
									@nTroco		, @nTroco2 			, @lDescCond		, @nDesconto	, ;
									@aDadosCH	, @cItemCond		, @lCondNegF5		, @aParcelas	, ;
									@cCliente 	, @cLojaCli         , @nVlrDescTot      , @aValePre 	, ;
									@aRegTEF	, @lRecarEfet		, @aColsMAV			, @aTefBkpCS	, ;
									Nil			, Nil				, Nil				, Nil			, ;
									Nil			, Nil				, Nil				, Nil			, ;
									Nil			, Nil				, Nil				, Nil			, ;
									Nil			, Nil				, Nil				, Nil			, ;
									Nil			, Nil				, Nil				, Nil			, ;
									Nil			, Nil				, Nil				, Nil			, ;
									Nil			, @nParcSel	  )  ,;					
									oDlg:End()   	, oDlg:End() )
	
	@ C(0100),C(002) ListBox oListBox Fields ;
		HEADER STR0008 , STR0009; // "Qtd de Parcela(s)" ## "Valor p/ Parcela(s)"
		Size C(134),C(136) Of oDlg Pixel; // 122 134 150
		ColSizes 50,50 ON CHANGE(nParcSel:= oListBox:nAt,oNrParc:Refresh()) 
		
		oListBox:SetArray(aListBox)
	
	
	Aadd(aListBox,{'1',TRANSFORM(Round(nValorSL2/1,2),'@E 99,999,999.99')})
	 
	oListBox:bLine := {|| {aListBox[oListBox:nAT,01],aListBox[oListBox:nAT,02]}}
	oListBox:Refresh()
                       
	SIMULAList(oListBox, @aListBox, nValorSL2, @nNrParc, cFormPgto, @oNrParc, @oValorSL2, cAdmCartao, .T.)	


ACTIVATE MSDIALOG oDlg CENTERED 

RestArea(aSavArea)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³SimulaList   ³ Autor ³ Vendas Crm           ³ Data ³03/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da ListBox                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³  FrontLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function SimulaList(	oListBox, 	aListBox	, nValorSL2, nNrParc,;
							cFormPgto, 	oNrParc		, oValorSL2, cAdm, ;
							lIni, lFrPag)
				
Local nX := 0	// Contador

Default lIni := .F.
     
aListBox:={}
oListBox:SetArray(aListBox)

If  lIni == .T.
	nNrParc := 1
Else
	IF lFrPag
		nNrParc := Frt8Pac(nValorSL2, cFormPgto)
	Else		
		nNrParc := Frt8Pac(nValorSL2, cFormPgto, cAdm) 
	EndIf

EndIf

nParMax := nNrParc

For nX :=1 To nNrParc
	If "R$" $ Alltrim(cFormPgto) .And. nX == 1
		Aadd(aListBox,{Str(nX),TRANSFORM(nValorSL2,'@E 99,999,999.99')})
		Exit
	Else
		Aadd(aListBox,{Str(nX),TRANSFORM(Round(nValorSL2/nX,2),'@E 99,999,999.99')})
	EndIf
Next

oListBox:bLine := {|| {aListBox[oListBox:nAT,01],aListBox[oListBox:nAT,02]}}
oListBox:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldFormPg ºAutor  ³VENDAS CRM          º Data ³  03/03/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a forma de pagamento selecionada                    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  FrontLoja                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function VldFormPg(	cFormPgto,	cDescFPgto,	oDescFPgto,	oListBox,		;
							aListBox,	nValorSL2,	nNrParc,	oNrParc,		;
							oValorSL2,	oAdmCartao,	cAdmCartao,	cDescACartao,	;
							oLogoAdm, 	nParcSel, 	oAdmCartao)

Local lRet 			:= .F.  					   	// Retorno 			da variavel
Local cMV_LJPGSAD 	:= SuperGetMv("MV_LJPGSAD",,'')	// Parametro

nNrParc 	:= 1

dbSelectArea("SX5")           
dbSetOrder(1)
If SX5->(DbSeek(xFilial("SX5")+"24"+cFormPgto)) 
	cDescFPgto	:=	AllTrim(X5Descri())                
	cFormPgto	:=  AllTrim(cFormPgto)
	
	If AllTrim(cFormPgto) $ cMV_LJPGSAD

		oAdmCartao:Disable()
		SIMULAList(oListBox, @aListBox, nValorSL2, @nNrParc, cFormPgto, @oNrParc, @oValorSL2, cAdmCartao, Nil, .T.)	
	Else
	
		oAdmCartao:Enable()

	EndIf
	
	lRet := .T.

Else
	lRet := .F.
EndIf                  

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldAdmCartaoºAutor  ³VENDAS CRM          º Data ³  03/03/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a administradora financeira selecionada             	º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  FrontLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function VldAdmCartao(	cAdmCartao,	cDescACartao,	cFormPgto,	oDescACartao,	;
								oListBox,	oLogoAdm,		aListBox,	nValorSL2,		;
								nNrParc,	oNrParc,		oValorSL2, 	cDesAdm)

Local lRet := .F. // Retorno

DbSelectArea("SAE")           
SAE->( DbSetOrder(1) )

If SAE->(DbSeek(xFilial("SAE")+cAdmCartao))

	cDesAdm  :=	 AllTrim(SAE->AE_DESC)                
	SIMULAList(oListBox, @aListBox, nValorSL2, @nNrParc, cFormPgto, @oNrParc, @oValorSL2, cAdmCartao)	
	lRet := .T.
Else
	Alert(STR0013) //"Adm.Financeira não cadastrada."
	lRet := .F.
EndIf                  
																			
Return lRet

/*                                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldNrParc ºAutor  ³VENDAS CRM          º Data ³  03/03/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o numero maximo de parcelas                         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  FrontLoja                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function VldNrParc(nNrParc)

Local lRet := .T. // Retorno
                     
If nNrParc > nParMax

    Alert(STR0010) // 'Numeros de parcelas invalido'
	lRet := .F.

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³   C()   ³ Autores ³ VENDAS CRM             ³ Data ³25/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³          ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  FrontLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function C(nTam)                                                         

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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Frt8Pac ³ Autores ³ VENDA CRM              ³ Data ³13/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ GERA NUMERO DE PARCELAS PERMITIDO PELA TABELA MDV            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  FrontLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Frt8Pac(nValorSL2, cFormPgto, cAdm) 
                         
Local nRet 	:= 1				// Retorno de numero de Parcela
Local aArea :=  GetArea()		// Area selecionada

Default cAdm := 'ZZZ'
Default nValorSL2 := 0
Default cFormPgto := ''

DbSelectArea('MDV')
MDV->( DbSetOrder(1) )

MDV->( DbSeek(xFilial("MDV") + cFormPgto) )

While (!Eof()) .AND. (Alltrim(xFilial("MDV") + cFormPgto) == AllTrim(MDV->MDV_FILIAL + MDV->MDV_FPG)) .AND.  (nRet == 1)

	If (nValorSL2 >= MDV->MDV_VALINI) .AND. (nValorSL2 <= MDV->MDV_VALFIM)
	
		If cAdm == 'ZZZ' //o valor a ser comparado deve ser igual ao valor default da variavel
			nRet := MDV->MDV_NPARC
		Else
			DbSelectArea('MDX')
			MDX->( DbSetOrder(1) ) //MDX_CODIGO + MDX_CODADM

			If MDX->( DbSeek(xFilial("MDX") + MDV->MDV_CODIGO + cAdm) )
				nRet := MDX->MDX_NPARC
			Else						
				MsgAlert(STR0012,STR0011)
				//"Adm.Financeira não cadastrada na Regra de Parcelamento, portanto será utilizado o número de parcelas do cabeçalho da Regra de Parcelamento."
				//"Atenção"
				nRet := MDV->MDV_NPARC
			EndIf
		EndIf

	EndIf

	dbSkip()
End

RestArea(aArea)

Return nRet
