#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXFUND.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "DIRECTRY.CH"
#INCLUDE "PARMTYPE.CH"
 
#DEFINE _PICTURE	16
#DEFINE _FORMATEF	"CC;CD"								//Formas de pagamento que utilizam operação TEF para validação
#DEFINE F_NAME		1

STATIC lFiltSer					               			// Define se filtra as series de documento por ponto de entrada
//ÚÄÄÄÄÄÄÄÄ¿
//³SigaLoja³
//ÀÄÄÄÄÄÄÄÄÙ
Static aImpsTmp    
Static aImpSF2Tmp                       
Static aImpDupTmp 
Static nTmpLiq         
Static nValTotTmp
Static nValBaseTmp
Static lCenVenda 		:= SuperGetMv("MV_LJCNVDA",,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Front Office³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static aImpTmpSL1 
Static aImpTmpSL2 
Static cNomeCli		:= ""						// Nome do Cliente para Emissao no Cupom Fiscal - PAC ECF
Static cEndCli		:= ""						// Endereco do cliente para Emissao no Cupom Fiscal - PAC ECF
Static cSenha		:= "******"					//Variavel apagada pelo Framework
Static cPlaca		:= ""  						//Placa do veiculo abastecido para Emissao no Cupom Fiscal - PAC ECF/Bloco II - REQUISITO XXXIV - Template de Posto
Static cKm			:= ""  						//Quilometragem do hodometro do veiculo abastecido para Emissao no Cupom Fiscal - PAC ECF/Bloco II - REQUISITO XXXIV - Template de Posto
Static aArqLstPaf	:= {}						//Armazena Relacao de Arquivos do PAF-ECF com o MD5
Static lMvLjPdvPa	:= LjxBGetPaf()[2] //Indica se é pdv Paf-Ecf
Static lHomolPaf	:= LjHomolPaf()
Static lCgcCancel	:= .F.						//Variavel que indica se abortara a finalização da venda no tela de CPF/CNPJ				

#DEFINE LOG_TEF LjLogTef()		// Log do TEF

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LojxFund ³ Autor ³ Vendas Clientes       ³ Data ³15/08/06   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contem fun‡”es genericas de vendas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja e FrontLoja                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o	 ³ljxDCondP ³ Autor ³ Vendas Clientes       ³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Array com as condi‡”es de pagamento. 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpA1:=ljxDCondP( )										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Retorna array com as condi‡”es cadastradas.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA010												      ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function ljxDCondP( cCodLojCli )
Local aCondicoes	:= {}
Local lLj010Cond	:= ExistBlock("LJ010CON")
Local lFTVD010Cond 	:= ExistBlock("FTVD010CON")
Local lFtvdVer12	:= LjFTVD() 	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lFieldMsBlqL	:= SE4->(ColumnPos("E4_MSBLQL")) > 0			// Verifica a existencia do campo SE4->E4_MSBLQL	
Local lFieldMsBlqD	:= SE4->(ColumnPos("E4_MSBLQD")) > 0			// Verifica a existencia do campo SE4->E4_MSBLQD	

Default cCodLojCli	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega com as condições gravadas no SE4 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLayAway
	If (!lLj010Cond .AND. !lFtvdVer12) .Or. (!lFTVD010Cond .AND. lFtvdVer12)
		DbSelectArea("SE4")
		SE4->(MsSeek(xFilial("SE4")))
		While !Eof() .AND. SE4->E4_FILIAL == xFilial("SE4")
		
			If (lFieldMsBlqL .AND. SE4->E4_MSBLQL=="1" .AND. !lFieldMsBlqD) .OR. ;
			 	(lFieldMsBlqL .AND. SE4->E4_MSBLQL=="1" .AND. (lFieldMsBlqD .AND. (Empty(SE4->E4_MSBLQD) .OR. SE4->E4_MSBLQD < dDataBase )))
				SE4->(DbSkip())
	          	Loop
	       	EndIf			
	       	
		    If cPaisLoc $ "EUA|POR"
		       If SE4->E4_CODIGO == "LAY"
		          SE4->(DbSkip())
		          Loop
		       EndIf
		    EndIf
		    
		    If 	!Empty(cCodLojCli) .And.;
		    	(AllTrim(cCodLojCli) == AllTrim(SuperGetMV("MV_CLIPAD"))+AllTrim(SuperGetMV("MV_LOJAPAD"))) .And.;
		     	AllTrim(SE4->E4_FORMA) == "FI"
		    	
		    	Conout("Cliente padrão não pode efetuar venda financiada, sera bloqueada da tela")
		    	LjGrvLog( NIL, "Cliente padrão não pode efetuar venda financiada, sera bloqueada da tela")
		    	SE4->(dbSkip())
		    	Loop
		    EndIf
		    
			If SE4->E4_TIPO <> "9"
				Aadd(aCondicoes ,SE4->E4_CODIGO + " - " + SubStr( SE4->E4_DESCRI, 1, 20 ))
			EndIf
		
			SE4->(dbSkip())
		End
	Else
		/*Ponto de Entrada para condições de pagamento*/
		If lFtvdVer12
			aCondicoes:= ExecBlock("FTVD010CON",.F.,.F.)
		Else
			aCondicoes:= ExecBlock("LJ010CON",.F.,.F.)  
		EndIf
	EndIf
													  
Else
	Aadd(aCondicoes,"LAY - "+ STR0040 )  //"Lay-Away"
EndIf

Return aCondicoes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDFill  ºAutor  ³Vendas Clientes      º Data ³  21/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche matriz de pagamentos com a forma escolhida.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDFill(	oComboPag	, cComboPag		, aItens		, dDataForm	,;
					lCheckPag	, nValor		, nEntrada		, oEntrada	,;
					nFinanciado	, oFinanciado	, cNomeMoeda	, aTmpPgtos	,;
					nTipoJur	, nValFat		, nMoedaCor		, oPgtosAna	,;
					oPgtos		, aPgtos 		, lVendaRapida	, nTxJuros	,;
					nValorBase	, nTaxaMoeda  	, nLinha 		, lMvJurCc	,;
					cForma		, cComboAdm		, nQtParc		, aTxJurAdm	)

Local cSimb		:= ""											// Simbolo da moeda utilizada na venda

Local nEl 		:= AScan( aItens, { |x| x[1] = cComboPag } )	// Posicao do conteudo cComboPag no aItens
Local nI		:= 0											// Variavel utilizada no For... Next
Local nZ		:= 0											// Variavel utilizada no For... Next
Local nValTot	:= 0											// Valor total
Local nValDif	:= 0											// Valor da diferenca
Local nValPar	:= 0											// Valor da parcela
Local nValTPed	:= 0											// Valor total do pedido
Local nPosMoeda := 0											// Posicao do campo moeda no aPgtos
Local nTmpEntr  := 0											// Valor de entrada
Local nTmpFinan := 0											// Valor do financiamento
Local nValTaxa	:= 0											// Valor da taxa
Local nDivisor1	:= 0											// Divisor
Local nParcelas	:= 0											// Quantidade de parcelas
Local nTmpJuros	:= 0											// Valor de Juros
Local nMoedaParc:= 0											// Moeda da parcela
Local nDecs     := MsDecimais(nMoedaCor)						// Casas decimais
Local nValParc  := 0											// Valor da parcela
Local nValNCC   := 0											// Valor da NCC
Local nTrocoTot := 0											// Valor total do troco

Local lSintVisu := IIF(SL4->( FieldPos( "L4_FORMAID" ) ) > 0, .T., .F. )	// Verifica se a visualizacao sintetica esta ativa
Local nPosObj	:= IIF( lSintVisu .AND. ValType(oPgtosAna) == "O", oPgtosAna:nAt, oPgtos:nAt )								// Linha que esta pintada

Local lRecalc   := .T.											// Verifica se deve recalcular os valores
Local lUsaTroco := ( SuperGetMV( "MV_LJTROCO",, .F. ) .AND. SL1->( FieldPos( "L1_TROCO1" ) ) > 0 .AND. cPaisLoc == "BRA" )  // Determina se usa troco para diversas formas de pagamento
Local lLjtrcloc := ( cPaisLoc <> "BRA" .AND. SuperGetMV("MV_LJTRLOC",, .F.)  .AND. SL1->( FieldPos( "L1_TROCO1" ) ) > 0 )   // Determina se usa troco localizado para diversas formas de pagamento
Local lAltera   := .F.
Local nTxJurAdm	:= 0 		//Taxa de Juros Adm Financeira
Local nVrJuros	:= 0

Default nLinha   	:= 0
Default lMvJurCc 	:= .F.
Default cForma   	:= ""
Default cComboAdm	:= ""
Default nQtParc  	:= 0
Default aTxJurAdm	:= {0,0,0}

If lVendaRapida
	nPosMoeda := 11
Else
	nPosMoeda := 4
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Calcula o Total do Pedido  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValTPed := 0
For nI := 1 To Len(aPgtos)
	If cPaisLoc == "BRA"
		nValTPed := nValTPed + aPgtos[nI][2]
	Else
		nValTPed := nValTPed + xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
	EndIf
Next nI

If cPaisLoc <> "BRA"
	For nI := 1 To MoedFin()
		If(!(Empty(SuperGetMv("MV_MOEDA"+Ltrim(STR(nI))))))
			If SuperGetMv("MV_MOEDA"+Ltrim(STR(nI))) == cNomeMoeda
				aPgtos[nPosObj][nPosMoeda] := nI
				Exit
			EndIf
		Else
			Exit
		EndIf
	Next nI
EndIf

aPgtos[nPosObj][1]	:= dDataForm

If cPaisLoc <> "BRA"
	If lLjtrcloc .AND. aPgtos[nPosObj][2] <> nValor
		aPgtos[nPosObj][2] := nValor	
		lAltera := .T.
	Else
		If (nPosObj <> Len( aPgtos ) .OR. Len( aPgtos ) == 1) .AND. aPgtos[nPosObj][2] <> nValor
			aPgtos[nPosObj][2] := nValor	
			lAltera := .T.
		EndIf
	EndIf	
Else
	If lUsaTroco .AND. aPgtos[nPosObj][2] <> nValor
		aPgtos[nPosObj][2] := nValor	
		lAltera := .T.
	Else
		If (nPosObj <> Len( aPgtos ) .OR. Len( aPgtos ) == 1) .AND. aPgtos[nPosObj][2] <> nValor
			aPgtos[nPosObj][2] := nValor	
			lAltera := .T.
		EndIf
	EndIf
EndIf

aPgtos[nPosObj][3]	:= aItens[nEl][2]
nMoedaParc 			:= aPgtos[nPosObj][nPosMoeda]

If lAltera
	LjxDReFill( nPosObj, nValTPed, aPgtos	, nMoedaCor )
EndIf

If cPaisLoc <> "BRA" .AND. nMoedaParc > 1  //Mostra o simbolo da moeda correspondente para a parcela
	If IsMoney(aPgtos[nPosObj,3])
		cSimb := "MV_SIMB"+AllTrim(Str(nMoedaParc))
		aPgtos[nPosObj,3] := SuperGetMv(cSimb)
	EndIf
EndIf

nTmpEntr    := nEntrada
nTmpFinan   := nFinanciado

If cPaisLoc == "BRA"
	nEntrada := A410Arred( aPgtos[1][2], "L4_VALOR", nMoedaCor )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Caso utilize troco, nao retirar a entrada, caso contrario ficara com financiamento negativo   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTroco .AND. lVendaRapida .AND. FunName() <> "LOJA220"
		nFinanciado := 0
		aEval( aPgtos, { |ExpA1,nCnt| nFinanciado += IIF(nCnt == 1,0,ExpA1[2]) })
	Else                                        
		nFinanciado := Round(nValTPed - nEntrada, 2)
	EndIf                                       
	
	If nFinanciado < 0
		nFinanciado := 0
	EndIf

	If !lVendaRapida
		oEntrada:Refresh()
		oFinanciado:Refresh()
	EndIf

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Calcular a entrada e o valor financiado considerando multi-moeda                    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nEntrada    := 0
	nFinanciado := 0
	For nI := 1 To Len(aPgtos)
		If aPgtos[nI,1] == dDataBase
			nEntrada    += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
		EndIf
		nValParc += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
	Next nI
	nFinanciado := Max(Round(nValParc - nEntrada, nDecs),0)
	If !lVendaRapida
		oEntrada:Refresh()
		oFinanciado:Refresh()
	EndIf
EndIf

If Len(aPgtos) > nPosObj .AND. !(lUsaTroco .AND. lVendaRapida .AND. FunName() <> "LOJA220")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Calcula quanto ‚ o Valor Total at‚ a parcela alterada.                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValTot := 0
	For nI := 1 To nPosObj
		If cPaisLoc == "BRA"
			nValTot := nValTot + aPgtos[nI][2]
		Else
			nValTot := nValTot + xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
		EndIf
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Calcula a diferen‡a    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValDif := Max(nValTPed - nValTot,0)     //Localizacoes - permite valores das parcelas maior que valor da fatura
	nParcelas := (Len(aPgtos) - nPosObj) // Parcelas Restantes

	If nTxJuros == 0 .AND. nValorBase < nValTPed
		nTmpJuros := SE4->E4_ACRSFIN
	Else
		nTmpJuros := nTxJuros
	EndIf
	
	If !SuperGetMv("MV_TXVISTA") == "S" .AND. !nTmpEntr == nEntrada .AND. nTmpJuros > 0
		nValDif := nValorBase - nEntrada
		nValTaxa := nTmpJuros / 100
		If SuperGetMv("MV_PRICE")   == "S"
			nDivisor1 := (1 + nValTaxa) ^ nParcelas
			nValDif := (nValDif * ((nDivisor1 * nValTaxa) / (nDivisor1 -1))) * nParcelas
		Else
			nValDif := nValorBase - nEntrada
			If nTipoJur = 1
				nValDif  := Round(nValDif + (nValDif * nValTaxa),2)
			ElseIf nTipoJur = 2
				nValDif  := Round(nValDif * (( 1 + nValTaxa ) ^ nParcelas) ,2)
			EndIf
		EndIf
		nFinanciado := nValDif
		nValTPed := nEntrada + nFinanciado
		nVlrAcrs := nValTPed - nValorBase
	EndIf
	
	If Type("nParcAtual") == "N" 
		If nParcAtual == nValor
			lRecalc := .F.
		EndIf
	EndIf
	
	If lRecalc
		nValPar := NoRound(nValDif / nParcelas,nDecs)
		
		For nI := nPosObj+1 To Len(aPgtos)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Atualiza o valor da parcela considerando a moeda correspondente                     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aPgtos[nI][2] := xMoeda(nValPar,nMoedaCor,aPgtos[nI][nPosMoeda],dDatabase,,nTaxaMoeda)
		Next nI
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Calcula o Valor Total atual    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValTot := 0
		For nI := 1 To Len(aPgtos)
			If cPaisLoc == "BRA"
				nValTot := nValTot + NoRound(aPgtos[nI][2])
			Else
				nValTot := nValTot + xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
			EndIf
		Next nI
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  Soma a diferen‡a na £ltima parcela   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			aPgtos[Len(aPgtos)][2] := aPgtos[Len(aPgtos)][2] + (nValTPed - nValTot)
		Else
			nValNCC := IIF(Type("nNccUsada") <> "N",0,nNccUsada)
			aPgtos[Len(aPgtos)][2] += xMoeda((nValTPed - nValNCC - nValTot),nMoedaCor,aPgtos[Len(aPgtos)][nPosMoeda],dDatabase,,nTaxaMoeda)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Apos o ajuste dos valores de acordo com a fatura atualizar os valores de entrada e financiado   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEntrada    := 0
			nFinanciado := 0
			nValParc    := 0
			For nI := 1 To Len(aPgtos)
				If aPgtos[nI,1] == dDataBase
					nEntrada    += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
				EndIf
				nValParc += xMoeda(aPgtos[nI][2],aPgtos[nI][nPosMoeda],nMoedaCor,dDatabase,,,nTaxaMoeda)
			Next nI
			nFinanciado := Max(Round(nValParc - nEntrada, nDecs),0)
		EndIf
	EndIf
ElseIf lUsaTroco .AND. lVendaRapida .AND. FunName() <> "LOJA220" //Alimento a variavel nTroco, pois no front loja, eh responsavel pela impressao do troco.
	aEval(aPgtos,{|x| nTrocoTot += x[2]} )
	If Type("nTroco") == "N" .AND. Type("nTroco2") == "N"
		nTroco := nTroco2 := Abs( nTrocoTot - nValFat )
	EndIf
EndIf

If lCheckPag
	For nI := nPosObj To Len(aPgtos)
		aPgtos[nI][3] := aItens[nEl][2]
	Next nI
EndIf

If cPaisLoc <> "BRA"
	For nI := 1 to Len(aPgtos)
		If aPgtos[nI][2] <= 0
			MsgStop( STR0041 )  //"Nenhuma parcela pode ser menor ou igual a zero."
			For nZ:= nPosObj to Len(aPgtos)
				aPgtos[nZ][1] := aTmpPgtos[nZ][1]
				aPgtos[nZ][2] := aTmpPgtos[nZ][2]
				aPgtos[nZ][3] := aTmpPgtos[nZ][3]
				aPgtos[nZ][nPosMoeda] := aTmpPgtos[nZ][nPosMoeda]
			Next nZ
			nEntrada    := nTmpEntr
			nFinanciado := nTmpFinan
			If !lVendaRapida
				oEntrada:Refresh()
				oFinanciado:Refresh()
			EndIf
			Exit
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Se o parametro de juros da adm estiver ativo... |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMvJurCc .AND. Len(aPgtos) > 0 .AND. nLinha > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se a forma de pagamento for CC ou CD... |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("Fr272ATxAd") .AND. (cForma $ _FORMATEF)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Pesquisando a taxa de juros cobrada pela adm financeira |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Fr272ATxAd( SubStr(cComboAdm,1,3), nQtParc, @nTxJurAdm, cForma,;
			 	 	lMvJurCc)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Se a funcao retornou uma taxa maior que zero |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTxJurAdm > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Caso nao esteja marcado para utilizar nas proximas parcelas, entao |
			//| atualiza o valor somente na linha que o usuario selecionou         |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				             
			aTxJurAdm[2] += nTxJurAdm
			If !lCheckPag
				nVrJuros 			:= A410Arred(aPgtos[nLinha][2] * nTxJurAdm / 100, "L2_VRUNIT")
				aTxJurAdm[3]		+= nVrJuros
				aPgtos[nLinha][2] 	+= nVrJuros
			Else 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Atualizando todas as parcelas abaixo da que o usuario selecionou |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				For nI := nLinha to Len(aPgtos)
					aTxJurAdm[3]	+= A410Arred(aPgtos[nI][2] * nTxJurAdm / 100, "L2_VRUNIT")	
					aPgtos[nI][2] 	+= A410Arred(aPgtos[nI][2] * nTxJurAdm / 100, "L2_VRUNIT")	
				Next nI
			EndIf				
		EndIf
	EndIf	
EndIf


oPgtos:Refresh()
aParcTef := aClone(aPgtos)

If ValType(oPgtosAna) == "O"
	oPgtosAna:Refresh()
EndIf

Return .T.
                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxDReFillºAutor  ³Vendas Clientes      º Data ³  21/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera os valores das parcelas para que nao haja inconsis-  º±±
±±º          ³ tencia nessas parcelas.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1: Parcela Alterada                                     º±±
±±º          ³ ExpN2: Total das parcelas                                   º±±
±±º          ³ ExpA3: Array de parcelas                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDReFill( nParcAlt, nTotParc, aParcelas	, nMoedaCor )

Local nI		:= 0											//Variavel de apoio
Local nTotTemp 	:= 0											//Total das parcelas menos o valor da parcela alterada e das anteriores
Local nVlrTemp	:= 0											//Valor das parcelas que nao foram alteradas
Local nNumParc	:= Len( aParcelas ) - nParcAlt					//Numero de parcelas que serao alteradas (Somente a partir da parcela atual)
Local lLenaPgots:= If(Type("aPgtos")=="A" ,Len(aPgtos)==1 ,.F.)	//Verifica se o tamanho do aPgtos e igual a 1

If nParcAlt <> Len( aParcelas ) .OR. lLenaPgots
	nTotTemp := nTotParc
	For nI := 1 To nParcAlt
	
		nTotTemp -= aParcelas[nI][2]					//Soma o valor das parcelas que nao sofrerao alteracao
	Next nI
	
	nVlrTemp	:= nTotTemp / nNumParc					//Calcula o novo valor das parcelas
	
	For nI := nParcAlt+1 To Len( aParcelas )
	
		aParcelas[nI][2] 	:= A410Arred( nVlrTemp, "L4_VALOR", nMoedaCor )
		nTotTemp 			-= A410Arred( nVlrTemp, "L4_VALOR", nMoedaCor )
	Next nI
EndIf
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDRecVB     ³ Autor ³Vendas Clientes        ³ Data ³ 23/04/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz o recalculo do valor base da venda para que o                ³±± 
±±³          ³ acrescimo seja aplicado corretamente. Especifico para            ³±± 
±±³          ³ localizacoes.                                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³  LjxDRecVB(Expn1,Expn2,Expn3,Expn4,Expn5,Expn6,Expn7,Expn8,Expn9)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expn1 = Valor base da venda               				        ³±± 
±±³          ³ Expn2 = Taxa de juros               				                ³±±
±±³          ³ Expn3 = Desconto atribuido no total da venda                     ³±±
±±³          ³ Expn4 = Taxa de desconto            				                ³±±
±±³          ³ Expn5 = Valor liquido da venda                                   ³±±
±±³          ³ Expn6 = Percentual de desconto      				                ³±±
±±³          ³ Expn7 = Tipo de juros (1=>Simples / 2=>Composto)                 ³±±
±±³          ³ Expn8 = Numero de parcelas do orcamento/venda                    ³±±
±±³          ³ Expn9 = Valor recebido na entrada                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjxDRecVB(nValorBase,nTxJuros,nTxDesc,nDescLoj,nLiq,nDescPer,nTipoJur,;
                    nNumParcelas,nEntrada,lJurEntrada)

Local lExpress    := .F.
Local lCalcFin    := Iif(SuperGETMV("MV_TXVISTA") == "S",.F.,.T.)
Local nI:=0,nX:=0,nK:=0,nA:=0,nY:=0,nC:=0
Local nAcresItem:=0,nDescItem:=0
Local nValImps:=0
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") //Nome da Rotina
Local cProg       := FunName()
Local nPosDescPro 	:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_DESCPRO"}),aPosCpoDet[10][2]) 
Local nPosValItem 	:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_VLRITEM"}),aPosCpo[6][2])
Local nPosValUnit 	:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_VRUNIT"}),aPosCpo[5][2])
Local nPosQtdItem 	:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_QUANT"}),aPosCpo[4][2])
Local nPosTes     		:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_TES"}),aPosCpoDet[03][2])
Local nPosProd    		:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_PRODUTO"}),aPosCpo[2][2]) 
Local nPosItem    		:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_ITEM"}),aPosCpo[1][2]) 
Local nDecs       := MsDecimais(nMoedaCor)
Local nArredIt	  := If(nDecs==0,nDecs,TAMSX3("L2_VRUNIT")[2])
Local nValIT      := 0
Local nDifIT      := 0
Local aTmpAcols   := aClone(aCols)
Local aImposto    := {}
Local aProdSL2    := {}
Local aSL2        := {}
Local aInfImp     := {}
Local cCodProd    := ""
Local lItem		  := (nArredIt > TAMSX3("L2_VLRITEM")[2])
Local nValJurOri  := aDadosJur[1]
Local nValDescOri := aDadosJur[9]
Local nValTaxa    := 0
Local nDivisor    := 0
Local nAcresTot   := 0
Local nPerAcrs    := 0
Local nValImp     := 0
Local cIndImp     := ""
Local cCampoVal   := ""
Local cCampoAlq   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes        ³
//³Paises:CHILE, COLOMBIA - F1CHI     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5		:=	GetRpoRelease() >= "R5" .AND. 	cPaisLoc$"CHI|COL" 
Local cMvDescSai	:= SuperGetMV("MV_DESCSAI",,"1")		// Desconto tratamento localizacoes

Default lJurEntrada 	:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes        ³
//³Posicao do desconto no array eh 9  ³
//³Paises:CHILE, COLOMBIA - F1CHI     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLocR5
	nPosDescPro:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_DESCPRO"}),aPosCpoDet[9][2])	
Else
	nPosDescPro:= Iif(cProg<>cNomeProg,Ascan(aHeader,{|x|Trim(x[2])=="L2_DESCPRO"}),aPosCpoDet[10][2])
EndIf

If Type("nDecimais")=="U"
   nDecimais  := 2
EndIf
nDecs		:= If(lItem,nArredIt,nDecimais)
nArredImp   := nDecs

If cPaisLoc == "ARG" .AND. !(SA1->A1_TIPO $ "NI")
	nArredImp	:=	nDecs
EndIf

If ((aImpsTmp   == Nil) .OR. (aImpTmpSL1 == Nil) .OR. (aImpTmpSL2 == Nil) .OR.;
	(aImpSF2Tmp == Nil) .OR. (aImpDupTmp == Nil))
   
	aImpsTmp   := {}
   	aImpSF2Tmp := {}                            
 	aImpDupTmp := {}
   	aImpTmpSL1 := {}
   	aImpTmpSL2 := {}
	nValTotTmp := 0
	nValBaseTmp:= 0
EndIf

If (nTmpLiq == Nil)
	nTmpLiq := 0
EndIf

//Zera o array aDadosJur
AEval(aDadosJur,{|x,y| aDadosJur[y]:=0 })

//Caso a taxa de juros seja igual a Zero a rotina nao eh executada.
If ((nTxjuros == 0) .AND. (nTxDesc == 0)) .AND. ((cProg <> "LOJA010") .AND. (cProg <> "FRTA010"))
	Return(0)
EndIf
                                          
//Variavel que determina a formula para calculo dos juros
If cProg <> "FRTA010" .OR. cProg <> cNomeProg
	nTipoJur := Iif(nTipoJur==Nil,1,nTipoJur)
	If nTipoJur == 2                                             
		nNumParcelas := Iif(lCalcFin,nNumParcelas-1,nNumParcelas)
	EndIf
Else 
	nNumParcelas -= If(nEntrada == 0,0,1)
EndIf

If (cProg <> "FRTA010" .AND. cProg <> cNomeProg) .AND. (Empty(aImpsTmp) .OR. (nLiq <> nTmpLiq))
	aImpsTmp := {}
	aImpsTmp := aClone(aImps)
	aImps    := {}
	                              
	aImpSF2Tmp:= {} 
	aImpSF2Tmp:= aClone(aImpVarSF2)
	aImpVarSF2:= {}
	                              
	aImpDupTmp:= {} 
	aImpDupTmp:= aClone(aImpVarDup)
	aImpVarDup:= {}
	
	nValTotTmp:= 0
	nValTotTmp:= nValTotIV 
	nValTotIV := 0
	              
	nValBaseTmp:= 0
	nValBaseTmp:= nValBaseIV 
	nValBaseIV := 0
ElseIf (cProg == "FRTA010" .OR. cProg == cNomeProg) .AND. ((Empty(aImpTmpSL1) .AND. Empty(aImpTmpSL2)) .OR. (nLiq <> nTmpLiq))
	aImpTmpSL1 := aClone(aImpsSL1) 
	aImpTmpSL2 := aClone(aImpsSL2)
EndIf

//Armazena o valor Liquido Original da Venda
aDadosJur[2] := nLiq
nTmpLiq      := nLiq

//Verfica se o imposto eh incluido ou descriminado e calcula o novo
//valor base.
If (cProg <> "FRTA010") .AND. (cProg <> cNomeProg)
	For nI := 1 To Len(aImpsTmp)
		For nX := 1 To Len(aImpsTmp[nI][06])
			If Substr(aImpsTmp[nI,6,nX,5],2,1) == "1"
				nValorBase   -= aImpsTmp[nI,6,nX,4]
				aDadosJur[6] += aImpsTmp[nI,6,nX,4]
			EndIf
		Next nX
	Next nI                          
Else
	If cProg == "FRTA010"
		For nI := 1 To Len(aImpTmpSL1)
			If aImpTmpSL1[nI,6] == "1"
				nValorBase  -= aImpTmpSL1[nI,3]
				aDadosJur[6]+= aImpTmpSL1[nI,3]
			EndIf
		Next nI
	Else 
		nValorBase  := (nValorBase - Lj7T_ImpsV("1",2)) - nValJurOri + nValDescOri
		aDadosJur[6]+= Lj7T_ImpsV("1",2)
	EndIf	       
EndIf

aDadosJur[3] := nValorBase

//Aqui sera realizado o calculo do acrescimo e tb do desconto, caso o mesmo 
//exista.         
If (nTxJuros == 0) .AND. (nTxDesc == 0)          
	If (cProg <> "FRTA010") .AND. (cProg <> cNomeProg)
		aImps     := aClone(aImpsTmp)
		aImpVarSF2:= aClone(aImpSF2Tmp)
		aImpVarDup:= aClone(aImpDupTmp)
		nValTotIV := nValTotTmp
		nValBaseIV:= nValBaseTmp
	Else        
		aImpsSL1 := aClone(aImpTmpSL1)	 
		aImpsSL2 := aClone(aImpTmpSL2)	
	EndIf
Else
	If cProg == "FRTA010" .OR. cProg == cNomeProg
	    aImpsSL1 := {}
	    aImpsSL2 := {}
	Else
		aImps     := {}
		aImpVarSF2:= {}
		aImpVarDup:= {}        
		nValTotIV := 0
		nValBaseIV:= 0
	EndIf       
	
	For nI := 1 To Len(aTmpAcols)
		lExpress := IIf(cProg=="LOJA010",!aTmpAcols[nI][Len(aHeader)+1],.T.)
		If lExpress
			//Calcula o novo valor do item - Desconto no Total
			If (nDescPer > 0) .AND. (cProg <> "FRTA010") .AND. (cProg <> cNomeProg)      
				nDescItem    := Round((aTmpAcols[nI][nPosValItem] * nDescPer)/100,nDecimais)
				aDadosJur[5] += nDescItem
				aTmpAcols[nI][nPosValItem] := aTmpAcols[nI][nPosValItem]-nDescItem
			Else
				nDescItem := 0		
			EndIf 
			
			//Calcula o novo valor do item - Desconto na condicao de pagamento
			If nTxDesc > 0 
				nDescItem    := Round((aTmpAcols[nI][nPosValItem] * nTxDesc)/100,nDecimais)
				aDadosJur[9] += nDescItem
				aTmpAcols[nI][nPosValItem] := aTmpAcols[nI][nPosValItem]-nDescItem
				//A posicao so existe qdo a venda esta sendo realizada no 
				//modulo Front Office.
				If nPosDescPro > 0
					If cProg $ "FRTA010|LOJA010"
						aTmpAcols[nI][nPosDescPro] := nDescItem	
					Else
						aColsDet[nI][nPosDescPro] := nDescItem	
					EndIf
				EndIf		
			Else
				nDescItem := 0		
			EndIf
			
			//Verificacao do tipo de juros aplicado.
			//Tipo 1 => Juros Simples
			//Tipo 2 => Juros Composto	
			//Tipo 3 => Tabela Price				
			If nTipoJur == 1
				If cProg <> "FRTA010" .AND. cProg <> cNomeProg
					If lJurEntrada
						nAcresItem := Round((aTmpAcols[nI][nPosValItem] * nTxJuros)/100,nDecimais)
					Else
						If aTmpAcols[nI][nPosValItem] < nEntrada
							nValIT   := 0
							nEntrada -=	aTmpAcols[nI][nPosValItem]
						Else
							nValIT   := aTmpAcols[nI][nPosValItem] - nEntrada
							nEntrada := 0
						EndIf							
							
						If nValIT > 0 
							nAcresItem := Round((nValIT * nTxJuros)/100,nDecimais)
						EndIf
					EndIf
				Else
					//So calcula acrescimo para itens que nao foram excluidos da venda...
					If !aTmpAcols[nI][Len(aHeader)+1]
						If lJurEntrada
							nAcresItem := NoRound((MaFisRet(nI,"IT_TOTAL") * nTxJuros)/100,nDecimais)
						Else
							If aTmpAcols[nI][nPosValItem] < nEntrada
								nValIT   := 0
								nEntrada -=	aTmpAcols[nI][nPosValItem]
							Else
								nValIT   := aTmpAcols[nI][nPosValItem] - nEntrada
								nEntrada := 0
							EndIf							
								
							If nValIT > 0 
								nAcresItem := NoRound((nValIT * nTxJuros)/100,nDecimais)
							EndIf								
						EndIf
			   		EndIf
				EndIf
			ElseIf nTipoJur == 2
				If lJurEntrada				             
					nAcresItem := Round((aTmpAcols[nI][nPosValItem] * (( 1 + (nTxJuros/100)) ^ nNumParcelas)) - aTmpAcols[nI][nPosValItem],nDecimais)
				Else 
					If aTmpAcols[nI][nPosValItem] < nEntrada
						nValIT   := 0
						nEntrada -=	aTmpAcols[nI][nPosValItem]
					Else
						nValIT   := aTmpAcols[nI][nPosValItem] - nEntrada
						nEntrada := 0
					EndIf							
								
					If nValIT > 0 
						nAcresItem := Round((nValIT * (( 1 + (nTxJuros/100)) ^ nNumParcelas)) - nValIT,nDecimais)
					EndIf								
				EndIf				
			ElseIf nTipoJur == 3
				If nI == 1
					nValTaxa   := nTxJuros / 100
					nDivisor   := (1 + nValTaxa) ^ nNumParcelas
					nPrestacao := Round((nValorBase-nEntrada) * ((nDivisor * nValTaxa) / (nDivisor -1)),nDecimais)
					nAcresTot  := (nPrestacao * nNumParcelas) - nValorBase
					nDifer     := nAcresTot
				EndIf	
				
				nPerAcrs   := Round((aTmpAcols[nI][nPosValItem] * 100) / nValorBase,2)
				nAcresItem := Round((nAcresTot * nPerAcrs) / 100,nDecimais)
				nDifer     -= nAcresItem
				If (nI == Len(aTmpAcols)) .AND. (nDifer <> 0)
					nAcresItem += nDifer
				EndIf
			EndIf

			aDadosJur[1] += nAcresItem
	        aDadosJur[7] := nTxJuros
			aTmpAcols[nI][nPosValItem] := Round(MaFisRet(nI,"IT_TOTAL"),nDecimais)	
	
			//Calcula o novo valor unitario considerando o acrescimo proporcional
			aTmpAcols[nI][nPosValUnit] := Round(MaFisRet(nI,"IT_PRCUNI"),If(cProg=="FRTA010".OR.cProg==cNomeProg,nDecimais+1,nDecimais))
	        
			If cProg <> "FRTA010" .AND. cProg <> cNomeProg
				SF4->( DbSetOrder(1) )
				SF4->( MsSeek( xFilial("SF4")+aTmpAcols[nI][nPosTes]) )
			
				aImpVarSD2[1] := aTmpAcols[nI][nPosQtdItem]
				aImpVarSD2[2] := aTmpAcols[nI][nPosValUnit]
				aImpVarSD2[3] := aTmpAcols[nI][nPosValItem]
				If (cProg == "LOJA010") .AND. (M->L1_FRETE > 0 .OR. M->L1_SEGURO > 0 .OR. M->L1_DESPESA > 0) .AND. lVlrFSD
					aImpVarSD2[4] := LjRatFrete(If(nI==1,.T.,.F.),nI)
				Else
					aImpVarSD2[4] := 0.00			
				EndIf
				aImpVarSD2[5] := 0.00
				aImpVarSD2[6] := {}
				If cPaisLoc == "COL"
					aImpVarSD2[7] := SA1->A1_CGC // NIT Terceros
				EndIf
				cCodProd := aTmpAcols[nI][nPosProd]
				CalcTesxIp( "S", (aTmpAcols[nI][nPosValItem]-nAcresItem)+nDescItem, aTmpAcols[nI][nPosValItem],cCodProd,0,nI,"BALCAO",0)
				AADD(aImps,aClone(aImpVarSD2))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava Base de c lculo e Valor do impostos obtidos atrav‚s do ³
				//³ Roteiro da Amarra‡„o Tes X Impostos no array aCols...        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nC := 1 To Len( aImps[nI,6] )
					If aImps[nI,6,nC,4] <> 0.00 .AND. !Empty( aImps[nI,6,nC,6] )
						If ( nE := ASCAN( aImpVarSF2,{ |x| x[1] == aImps[ nI ][6][ nC ][8] } ) ) == 0
							AADD( aImpVarSF2, { aImps[ nI ][6][ nC ][8], 0.00 , aImps[ nI ][6][ nC ][2]  } )
							nE := Len( aImpVarSF2 )
						EndIf

						aImpVarSF2[ nE ][2] += Round( NoRound( aImps[ nI ][6][ nC ][4], nDecs+1), nDecs)

						If ( nE := ASCAN( aImpVarSF2,{ |x| x[1] == aImps[ nI ][6][ nC ][9]  } ) ) == 0
							AADD( aImpVarSF2, { aImps[ nI ][6][ nC ][9], 0.00 , aImps[ nI ][6][ nC ][2]  } )
							nE := Len( aImpVarSF2 )
						EndIf

						aImpVarSF2[ nE,2 ] += Round(NoRound(aImps[nI,6,nC,3],nDecs+1),nDecs)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Acumula em "aImpVarDup" os Impostos que Incidem no Valor  ³
						//³ Total Base da Duplicata...                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SubStr( aImps[nI,6,nC,5],1,1 ) == "1"
							AAdd(aImpVarDup,{aImps[nI,6,nC,1],aImps[nI,6,nC,4]})
						EndIf
					EndIf
				Next nC
				
				//Acertar arredondamentos se calculou algum imposto
				If Len(aImpVarSF2) > 0
					aRedo := {}
					For nX	:=	1	To Len(aImps)
						For nY	:=	1	To Len(aImps[ nX ][6])
							If aImps[ nX ][6][ nY ][4] <> 0
								aImps[ nX ][6][ nY ][4] := Round( NoRound( aImps[ nX ][6][ nY ][4], nDecs+1),nDecs)
								aImps[ nX ][6][ nY ][3] := Round( NoRound( aImps[ nX ][6][ nY ][3], nDecs+1),nDecs)
								If ( nPosImp := ASCAN( aRedo,{ |x| x[1]== aImps[ nX ][6][ nY ][8] .AND. x[2]== aImps[ nX ][6][ nY ][9] } ) ) == 0
									AADD( aRedo,{ aImps[ nX ][6][ nY ][8], aImps[ nX ][6][ nY ][9], aImps[ nX ][6][ nY ][4],aImps[ nX ][6][ nY ][3]})
								Else
									aRedo[ nPosImp ][3] += aImps[ nX ][6][ nY ][4]
									aRedo[ nPosImp ][4] += aImps[ nX ][6][ nY ][3]
								EndIf
							EndIf
						Next nY
					Next nX
				   
					For nX	:=	1	To Len(aRedo)
						//Acertar el redondeo en la base del impuesto
						nPosImp	:=	Ascan( aImpVarSF2,{ |x| x[1] == aRedo[ nX ][1]})
						aImpVarSF2[ nPosImp ][2] := Round( NoRound( aImpVarSF2[ nPosImp ][2], nDecs+1), nDecs)
						nDif	:=	aImpVarSF2[ nPosImp ][2] - aRedo[ nX ][3]
						lAchou	:=	.F.
						While !lAchou
							For nY	:=	1	To Len(aImps)
								If ( nPosIt := ASCAN( aImps[ nY ][6],{ |X| x[8] == aRedo[ nX ][1] } ) ) > 0
									aImps[ nY ][6][ nPosIt ][4] += nDif
									lAchou	:=	.T.
									nY	:=	Len(aImps)+1
								EndIf
							Next nY
						End
						//Acertar el redondeo en el valor del impuesto
						nPosImp	:=	Ascan(aImpVarSF2,{|x| x[1]==aRedo[nX][2]})
						aImpVarSF2[ nPosImp ][2] := Round( NoRound( aImpVarSF2[ nPosImp ][2], nDecs+1), nDecs)
						nDif	:=	aImpVarSF2[ nPosImp ][2] - aRedo[ nX ][4]
						lAchou	:=	.F.
						While !lAchou
							For nY	:=	1	To Len(aImps)
								If ( nPosIt := ASCAN( aImps[ nY ][6],{|X| x[9] == aRedo[ nX ][2] } ) ) > 0
									aImps[ nY ][6][ nPosIt ][3] += nDif
									lAchou	:=	.T.
									nY	:=	Len(aImps)+1
								EndIf
							Next nY
						End
					Next nX
				EndIf
			Else                         
				If cProg == "FRTA010"
					If !aTmpAcols[nI][Len(aHeader)+1]
						lRecalImp := .T. //Determina que ocorreu um calculo de acrescimo...
						//Calcula o novo valor do item
						nValIT    := (aTmpAcols[nI][nPosQtdItem] * aTmpAcols[nI][nPosValUnit])
						nDifIT    += nValIT - NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)              
						nVlrTotIT := NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)
						If nI == Len(aTmpAcols)
							nVlrTotIT += nDifIT				
							aTmpAcols[nI][nPosValItem] := nVlrTotIT
						EndIf
						nTotImp   := 0
					    aInfImp   := TesImpInf(aTmpAcols[nI][nPosTes])
						MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", SA1->A1_TIPO,,, .F., "SBI")
						MaFisAdd(aTmpAcols[nI][nPosProd],aTmpAcols[nI][nPosTes],aTmpAcols[nI][nPosQtdItem],aTmpAcols[nI][nPosValUnit], 0, "", "",, 0, 0, 0, 0, nVlrTotIT, 0)
					    Aadd(aImpsSL2,{aTmpAcols[nI][nPosProd],aTmpAcols[nI][nPosTes],{}})
					    For nA := 1 to Len(aInfImp)
					       	If ( nE := ASCAN( aImpsSL1,{ |x| x[1] == aInfImp[ nA ][1] } ) ) == 0
					        	Aadd( aImpsSL1,{ aInfImp[ nA ][1], "L1_" + SUBSTR( aInfImp[ nA ][6], 4, 7), 0, "L1_" + SUBSTR( aInfImp[ nA ][8], 4, 7), 0, aInfImp[ nA ][3], aInfImp[ nA ][9] } )
					        	nE := Len(aImpsSL1)
					       	EndIf   
					       	cIndImp   := SUBSTR( aInfImp[ nA ][2], 10, 1)               
					       	cCampoVal := "IT_VALIV"  + cIndImp		    
					       	cCampoAlq := "IT_ALIQIV" + cIndImp
					       	nValImp   := Round(MaFisRet(nI,cCampoVal),nDecimais) 
					       	FRTGeraImp(@aImposto,aInfImp[nA],nValImp,aTmpAcols[nI][nPosQtdItem],aTmpAcols[nI][nPosValUnit],nI,cIndImp)			   
						   	AAdd(aImpsSL2[nI][3],aClone(aImposto))
						   	nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
						   	aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nA][4]	//Valor do imposto no cabecalho		   			   
						   	aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nA][3]	//Base do imposto no cabecalho		   			   		   
					    Next nA      
					    AAdd(aImpsSL2[nI],aTmpAcols[nI][nPosItem])
					    AAdd(aImpsSL2[nI],.F.)
					                         
						aTmpAcols[nI][nPosValUnit] := Round(aTmpAcols[nI][nPosValUnit],nDecimais)			    
						aProdSL2 := {	{"L2_VRUNIT" , aTmpAcols[nI][nPosValUnit]},;
						             	{"L2_VLRITEM", nVlrTotIT},;
									    {"L2_ITEM"   , aTmpAcols[nI][nPosItem]},;
	   								    {"L2_DESCPRO", aTmpAcols[nI][nPosDescPro]}}
					
						For nK := 1 to Len(aImpsSL2[nI][3])
					    	Aadd(aProdSL2,{aImpsSL2[nI][3][nK][6],aImpsSL2[nI][3][nK][4]})   //Valor do imposto
				            Aadd(aProdSL2,{aImpsSL2[nI][3][nK][7],aImpsSL2[nI][3][nK][3]})   //Base do imposto         
				            Aadd(aProdSL2,{"L2_ALQIMP"+Substr(aImpsSL2[nI][3][nK][7],10,1),aImpsSL2[nI][3][nK][2]})   //Aliquota do imposto                           
				        Next nK   
						AAdd(aSL2,aClone(aProdSL2))
						nValImps += Round(nTotImp,nDecimais) 
					Else                                     
						//Insere linha original no aImpsSL2 para que ele permaneca
						//com o mesmo tamanho...
					    AAdd(aImpsSL2,aClone(aImpTmpSL2[nI]))
					EndIf
				Else
					nValIT    := (aTmpAcols[nI][nPosQtdItem] * aTmpAcols[nI][nPosValUnit])
					nDifIT    += nValIT - NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)              
					nVlrTotIT := NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)
					If nI == Len(aTmpAcols)
						nVlrTotIT += nDifIT				
						aTmpAcols[nI][nPosValItem] := nVlrTotIT
					EndIf
					aTmpAcols[nI][nPosValUnit] := Round(aTmpAcols[nI][nPosValUnit],nDecimais)			    

					// Acerta o valor unitario nas funcoes fiscais...
					MaFisAlt("IT_PRCUNI",aTmpAcols[nI][nPosValUnit],nI)
					
					aCols[nI][nPosValUnit] := aTmpAcols[nI][nPosValUnit]
					aCols[nI][nPosValItem] := aTmpAcols[nI][nPosValUnit]*aTmpAcols[nI][nPosQtdItem]
					
					// Executa o recalculo dos impostos variaveis...					
            		If lLocR5 .AND. cMvDescSai == "1"  
            			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Release 11.5 - Localizacoes                             ³
						//³Executa o recalculo dos impostos variaveis              ³
						//³Necessario verificar o parametro MV_DESCSAI.Se estiver  ³
						//³igual a 1,sera utilizado o valor do item sem o desconto ³
						//³para os calculos da MATXFIS 							   ³
						//³Paises: Chile/Colombia - F1CHI                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Lj7RecalImp(nI,6,"IT_VALMERC",(aTmpAcols[nI][nPosValUnit]*aTmpAcols[nI][nPosQtdItem])+aTmpAcols[nI][nPosDescPro])            		
            		Else
            			Lj7RecalImp(nI,6,"IT_VALMERC",aTmpAcols[nI][nPosValUnit]*aTmpAcols[nI][nPosQtdItem])
            		EndIf
									                       
					If nI == Len(aTmpAcols)						
						nValImps := Lj7T_ImpsV("1",2)           

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ajusta os valores de desconto (valor e percentual)           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aDadosJur[9] <> 0
						    Lj7T_DescV( 2, aDadosJur[9] )
						    LJ7T_DescP( 2, nTxDesc )
						    aDesconto[1] := 2
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next nI      
	       
	If cProg <> "FRTA010" .AND. cProg <> cNomeProg
		//Verifica se o imposto eh incluido ou descriminado
		For nI := 1 To Len(aImps)
			For nX := 1 To Len(aImps[nI][06])
				If Substr(aImps[nI,6,nX,5],2,1) == "1"
					nValImps += Round(aImps[nI,6,nX,4],nDecimais)
				EndIf
			Next nX
		Next nI
		
		For nX	:= 1 To Len(aImps)
			aInfImp	:=	TesImpInf(aTmpAcols[nX][nPosTes])
			For nY	:=	1	To Len(aImps[nX][6])
				If ( aInfImp[nY][3]=="1" )
					nValTotIV	+= aImps[nX][6][nY][4]
				EndIf
			Next nY
		Next nX
		nValTotIV  := Round(NoRound(nValTotIV,nArredImp+1),nArredImp )
		nValBaseIV := Round(NoRound(nValTotIV,nArredImp+1),nArredImp )	
	Else 
		If cProg == "FRTA010"
			MaFisEnd()
			FRTGravaSL2(aSL2) //Função para atulizar o arquivo SL2 -  Localizações			   
		EndIf
	EndIf
	aDadosJur[4] := nValImps
	aDadosJur[7] := nTxJuros  
	aDadosJur[8] := nDescLoj
EndIf

If nValImps == 0
	nValImps := aDadosJur[6]
	If cProg == "FRTA010"
		For nI := 1 To Len(aTmpAcols)
			If !aTmpAcols[nI][Len(aHeader)+1]
	   			aProdSL2  := {}
				nVlrTotIT := aTmpAcols[nI][nPosQtdItem] * aTmpAcols[nI][nPosValUnit]
				aProdSL2 := {	{"L2_VRUNIT" , aTmpAcols[nI][nPosValUnit]},;
				             	{"L2_VLRITEM", nVlrTotIT},;
							    {"L2_ITEM"   , aTmpAcols[nI][nPosItem]}}	
				
				For nK := 1 to Len(aImpTmpSL2[nI][03])
		    		Aadd(aProdSL2,{aImpTmpSL2[nI][03][nK][6],aImpTmpSL2[nI][03][nK][4]})   //Valor do imposto
	            	Aadd(aProdSL2,{aImpTmpSL2[nI][03][nK][7],aImpTmpSL2[nI][03][nK][3]})   //Base do imposto         
	            	Aadd(aProdSL2,{"L2_ALQIMP"+Substr(aImpTmpSL2[nI][03][nK][7],10,1),aImpTmpSL2[nI][03][nK][2]})   //Aliquota do imposto                           
		        Next nK   
	   			AAdd(aSL2,aClone(aProdSL2))
	   		EndIf						    
		Next nI
		FRTGravaSL2(aSL2)
		
		//Zera o array aDadosJur
		If (nTxjuros == 0) .AND. (nTxDesc == 0)
			AEval(aDadosJur,{|x,y| aDadosJur[y]:=0 })
		EndIf 
	EndIf
EndIf

Return(nValImps)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ljxDLerCar³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Le os cartoes de credito                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ljxDLerCarta(aReceb[nPos,3])                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³1 - Tipo de Administrador - Ex: CC, CO, VA                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljxDLerCarta(cTipo, lFator)
Local aCartoes  := {}

Default lFator  := .F.

DbSelectArea("SAE")
MsSeek(xFilial("SAE"))

While !Eof() .AND. xFilial("SAE") == SAE->AE_FILIAL
	If Alltrim(SAE->AE_TIPO) == AllTrim(cTipo)
		If lFator
			If Alltrim(Upper(SAE->AE_USAFATO)) == "S"
				Aadd(aCartoes , SAE->AE_COD + " - " + Capital(SubStr(SAE->AE_DESC,1,25)))
			EndIf
		Else
			Aadd(aCartoes , SAE->AE_COD + " - " + Capital(SubStr(SAE->AE_DESC,1,25)))
		EndIf
	EndIf
	dbSkip()
End

If Empty(aCartoes) //.AND. !lFator
	// Admin. n„o Cadastrada
	Aadd(aCartoes, Capital( STR0042 ))
EndIf

Return aCartoes
                           
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDRetVConv ³ Autor ³Vendas Clientes        ³Data  ³29/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar o valor da parcela convertido para a moeda           ³±±
±±³          ³ selecionada.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LjxDRetVConv(ExpC1,ExpO1,ExpN1,ExpO2,ExpA1,ExpA2)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Moeda da parcela     				                 ³±±
±±³          ³ ExpO1 := Objeto referente ao combo da moeda da parcela        ³±±
±±³          ³ ExpN1 := Valor da parcela				                     ³±±
±±³          ³ ExpO2 := Objeto do get do valor da parcela                    ³±±
±±³          ³ ExpA1 := Matriz utilizada no combo da moeda da parcela        ³±±
±±³          ³ ExpA2 := Matriz com o valor da parcela em diversas moedas     ³±±
±±³          ³ ExpC2 := origem da chamada da rotina("BALCAO" ou "FRONT")     ³±±
±±³          ³ ExpC3 := tipo da venda("0"-Balcao, "1"-Front, "2"-Rapida)     ³±±
±±³          ³ ExpC4 := Forma de pagamento ($, US$, R$...)                   ³±±
±±³          ³ ExpO5 := Objeto para exibir o oComboMoeda (FRTA271)			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjxDRetVConv( cMoedaTit	,	oComboMoeda	,nValor	,		oValor,;
						aCbxMoeda	,	aVal		,cOrigem,	cTipoVenda,;
						cSimbMoeda 	,	oDlgFRT)
Local oDlgConv
Local oLbx
Local oOk  	  := LoadBitMap(GetResources(), "LBOK")
Local oNo	  := LoadBitMap(GetResources(), "LBNO")
Local aSizes  := {05,40,25}
Local aFields := {" ", STR0043, STR0044 }  //Valor###Moeda
Local nI      := 0
Local nOpc    := 0  
Local nValParc:= 0
Local lIgual  := .F.

Default cOrigem  	:= "BALCAO"

If Empty(aVal)
	For nI := 1 To Len(aCbxMoeda)
		nValParc := Round(xMoeda(nValor,oComboMoeda:nAt,nI,dDataBase,MsDecimais(nI)+1),MsDecimais(nI))
		AAdd(aVal,{-1,nValParc,aCbxMoeda[nI],MsDecimais(nI),nValParc,SuperGetMV("MV_SIMB"+AllTrim(Str(nI)))})
	Next nI
Else
	If aVal[ AScan( aVal, { |x| TRIM(x[3]) == TRIM(cMoedaTit)})][5] == nValor
		lIgual := .T.
	EndIf

	For nI := 1 To Len(aCbxMoeda)
		If lIgual
			aVal[nI,1] := -1
			aVal[nI,2] := aVal[nI,5]
		Else                             
			nValParc := Round(xMoeda(nValor,oComboMoeda:nAt,nI,dDataBase,MsDecimais(nI)+1),MsDecimais(nI))
			aVal[nI,1] := -1
			aVal[nI,2] := nValParc
			aVal[nI,5] := nValParc
		EndIf
	Next nI
EndIf

If cOrigem == "BALCAO"
   DEFINE MSDIALOG oDlgConv FROM 12,65 TO 25,95 TITLE STR0045 ;  //"Selecao do Valor e da Moeda" 
   STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
ElseIf cTipoVenda == "1"  //Front
   DEFINE MSDIALOG oDlgConv FROM 12,65 TO 25,95 TITLE STR0045 ;  //"Selecao do Valor e da Moeda" 
   STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgFRT
ElseIf cTipoVenda == "2"  //Rapida
   DEFINE MSDIALOG oDlgConv FROM 12,65 TO 25,95 TITLE STR0045 ;  //"Selecao do Valor e da Moeda" 
   STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgRapid
EndIf
//                      LS  CE  CD  LI
oLBx := TWBrowse():New(010,004,110,060,,aFields,aSizes,oDlgConv,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBx:SetArray(aVal)       
oLBx:bLDblClick	:= {|| LjxDMkBrw(@aVal,@oLbx)}
oLBx:bLine := {|| {IIF(aVal[oLBx:nAt,1]==-1,oNo,oOk),TransForm(aVal[oLBx:nAt,2],Tm(aVal[oLBx:nAt,2],16,aVal[oLBx:nAt,4])),aVal[oLBx:nAt,3]}}

DEFINE SBUTTON FROM 075,058 TYPE 1 ACTION (nOpc:=1,oDlgConv:End()) ENABLE OF oDlgConv
DEFINE SBUTTON FROM 075,088 TYPE 2 ACTION (nOpc:=2,oDlgConv:End()) ENABLE OF oDlgConv

ACTIVATE MSDIALOG oDlgConv

If nOpc == 1
	If ( nI := AScan( aVal, { |x| x[1] == 1 } ) ) > 0
		nValor := aVal[nI,2]
		oValor:Refresh()
			
		cMoedaTit  := aVal[nI,3]
		oComboMoeda:nAt := AScan( oComboMoeda:aItems, { |x| TRIM(x) == TRIM(cMoedaTit) } )
		oComboMoeda:Refresh()
		
		cSimbMoeda := aVal[nI,6]
	EndIf
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ljxDFirst ³ Autor ³ Vendas Clientes       ³ Data ³    07/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a Entrada na condicao negociada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ljxDFirst( )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljxDFirst(	nValorBase	, nEntNeg	, nFinanciado	, nParcelas,;
					nParNeg		, oParNeg	, oEntNeg	)

Local lRet := .T.

If nEntNeg > nValorBase
	Help( " ", 0, "ENTRADA" )
	lRet := .F.
EndIf
If lRet
	If nEntNeg <> 0 .AND. nParcelas==1 .AND. nEntNeg < nValorBase .AND.;
		nEntNeg > 0
		nParcelas++
	EndIf
	If nEntNeg == nValorBase
		nParcelas := 1
	EndIf
	
	nFinanciado := nValorBase - nEntNeg
	
	If nEntNeg == nValorBase
		nParNeg := 1
		oParNeg:Refresh()
	ElseIf nEntNeg < nValorBase .AND. nParNeg < 2
		nParNeg := 2
		oParNeg:Refresh()
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDCbFor ³ Autor ³ Vendas Clientes       ³ Data ³ 31.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida forma do ComboBox 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDCbFor(	oCheckPag	, lCheckPag	, aMatriz	, cComboPag	,;
					aItens		, aPgtos)

Local cEspecie := "DINHEIRO"

If cPaisLoc <> "BRA" .AND. SX5->(MsSeek( cFilial+"24"+Alltrim(SuperGetMV("MV_SIMB1"))))
	cEspecie := AllTrim(X5Descri())
EndIf
If Len(aPgtos) > 1
	
	If Upper(cComboPag) == cEspecie
		lCheckPag := .F.
		oCheckPag:Disable()
		oCheckPag:Refresh()
	Else
		// Verifica se o CheckBox "Utiliza nas próximas parcelas" vira marcado ou desmarcado
		lCheckPag := (AllTrim(aItens[Ascan( aItens, { |x| x[1] = cComboPag } )][2]) $ SuperGetMV("MV_PRXPARC"))
		oCheckPag:Enable()
		oCheckPag:Refresh()
	EndIf
Else
	lCheckPag := .F.
	oCheckPag:Disable()
	oCheckPag:Refresh()
EndIf

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDDtVcto ³ Autor ³Vendas Clientes        ³Data  ³12/11/02   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da data de vencimento do cheque.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj010Imps(ExpD1,ExpD2,ExpC1,ExpO1,ExpA1)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 := Data de Vencimento  				               ³±±
±±³          ³ ExpD1 := Data              				                   ³±±
±±³          ³ ExpC1 := Combo de pagamento				                   ³±±
±±³          ³ ExpO1 := Tela de pagamentos				                   ³±±
±±³          ³ ExpA1 := Matriz contendo as datas e valores para pagamentos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  											   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjxDDtVcto(	dDataEmis,		dDataForm,		cComboPag,		oPgtos,;
						aPgtos	)
Local lRet := .T.
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

If FunName() == "LOJA220" .AND.  ExistBlock("LJ220DATE") .AND. !lFtvdVer12
	lRet := ExecBlock("LJ220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oListForma,aFormas})
ElseIf FunName() == "LOJA010" .AND. ExistBlock("Lj010DATE") .AND. !lFtvdVer12
	lRet := ExecBlock("Lj010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAFORM",oPgtos,aPgtos})
ElseIf FunName() == "LOJA220" .AND.  ExistBlock("FTVD220DATE") .AND. lFtvdVer12
	lRet := ExecBlock("FTVD220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oListForma,aFormas})
ElseIf FunName() == "LOJA010" .AND. ExistBlock("FTVD010DATE") .AND. lFtvdVer12
	lRet := ExecBlock("FTVD010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAFORM",oPgtos,aPgtos})
Else
	If dDataBase <= dDataForm .AND. dDataForm >= dDataEmis
		lRet := .T.
	Else
		MsgStop(STR0046)
		lRet := .F.
	EndIf
EndIf			  

Return( lRet )	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDMkBrw    ³ Autor ³Vendas Clientes        ³Data  ³29/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controla a marca/desmarca realizada na selecao do valor da    ³±±
±±³          ³ parcela convertido.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LjxDMkBrw(ExpA1,ExpO1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := Matriz com o valor da parcela em diversas moedas     ³±±
±±³          ³ ExpO1 := Objeto referente ao TWBrowse                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjxDMkBrw(aVal,oLbx)
Local nPosCol := oLBx:ColPos 
Local nValParc:= aVal[oLBx:nAt,1]
                                    
If nPosCol == 1
	aEval(aVal,{|x,y| x[1]:=IIF(y <> oLBx:nAt,-1,1)})
ElseIf aVal[oLBx:nAt,1] == 1
	oLBx:ColPos := 2
	MaFisEditCell(@nValParc,oLBx,PesqPict("SL4","L4_VALOR",_PICTURE,oLBx:nAt),2,'LjxDVldGet()') 
EndIf

oLBx:ColPos := 1
SysRefresh()
oLBx:Refresh()

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDGetCh ³ Autor ³ Vendas Clientes       ³ Data ³ 25/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Solicita os dados do Cheque.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Loja220                                                     ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDGetCh(	oDlgRapid	, cOrcam	, aCheques		, cCliente	,; 
					cLojaCli	, aParcelas	, lUsaDisplay )

Local oDlgTel
Local lCheckTe  	:=.F.
Local nVlrCheq  	:= aCheques[1][2]
Local dDtVenc   	:= aCheques[1][1]
Local nParc     	:= 1 
Local nTamBanco     := TamSX3("EF_BANCO")[1]
Local nTamAgencia	:= TamSX3("EF_AGENCIA")[1]
Local nTamConta		:= TamSX3("EF_CONTA")[1]
Local nTamCheque	:= TamSX3("EF_NUM")[1]
Local nTamComp		:= TamSX3("EF_COMP")[1] 
Local nTamRg		:= TamSX3("EF_RG")[1] 
Local nTamTel		:= TamSX3("EF_TEL")[1] 
Local nTamCpfCnpj	:= TamSX3("EF_CPFCNPJ")[1] 
Local cBanco    	:= Space(nTamBanco)
Local cAgencia  	:= Space(nTamAgencia)
Local cConta    	:= Space(nTamConta)
Local cCheque   	:= Space(nTamCheque)
Local cComp     	:= Space(nTamComp)
Local cRg       	:= Space(nTamRg)
Local cCpfCnpj		:= Space(nTamCpfCnpj)
Local cTelefone		:= Space(nTamTel)
Local lCheckCh 	  	:= .F.
Local nI        	:= 1
Local nVezes   	 	:= Len(aCheques)
Local aArea     	:= GetArea()
Local lLeuCmc7 		:= .F.
Local lRet      	:= .F.  // Verifica se o Usuario voltou para as formas de pgto.
Local lVolta    	:= .F.  // Verica se precionou o botao para voltar // &Confirma / &Avan‡ar >
Local cCapBut2 		:= If(nParc == nVezes, STR0047, STR0048 )
Local aCmc7     	:= {}
Local lPrimeiro		:= .T.
// Utiliza a Razao Social (M0_NOMECOM) como Nome do Favorecido, se estiver em branco utiliza o nome fantasia (M0_NOME)
Local cFavorec  	:= If(Empty(SM0->M0_NOMECOM),SM0->M0_NOME,SM0->M0_NOMECOM)
Local cCidade   	:= If(Empty(Substr(SM0->M0_CIDCOB,1,15)),"Sao Paulo",Substr(SM0->M0_CIDCOB,1,15))
Local nValor    	:= 0
Local dEmissao  	:= dDataBase
Local nCMC7CHQ 		:= If(!lUsaCmc7,1,SUPERGETMV("MV_CMC7CHQ"))
Local cObs      	:= ''
Local cVerso    	:= ''
Local cLabelDoc 	:= ""
Local xRetChq		// Variavel que recebe o retorno do ponto de entrada LJIMPCHQ
Local lGCpfCnpj     := .F. //Retorna se o CPF/CNPJ do cliente informado na tela de cheque será gravado.
Local nTamTerc		:= TamSX3("EF_EMITENT")[1]
Local cNomeTerc		:= Space(nTamTerc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel que verifica se o sistema está configurado para trabalhar com Comunicacao direta no CMC7³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lComCMC7Dir	:= IIF(FindFunction("LJCOMCMC7D"),LjComCMC7D(),.F.) //Caso a funcao LjComCMC7D() existe verifico ela, caso contrario retorno .F.

Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

Static aDadosCheq := {}
Static cUltOrcam  := ""

If Empty(cUltOrcam) .OR. cUltOrcam <> cOrcam
	aDadosCheq := {}
	cUltOrcam  := cOrcam
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no cliente para buscar o Telefone e o RG ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSetOrder(1)
If MsSeek( xFilial("SA1") + cCliente + cLojaCli )
	cTelefone := SA1->A1_TEL
	cRg       := SA1->A1_RG
	cCpfCnpj  := SA1->A1_CGC	
EndIf

If (lUsaCmc7 .OR. lComCMC7Dir)
	aDadosCheq := {}
	For nParc := 1 to Len(aCheques)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao para ler o Cmc7 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCmc7 := LjLeCmc7(nParc)
		If Len(aCmc7) > 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o cheque j  foi digitado ou gravado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aDadosCheq ) > 0
				If !LjxDVerChDig(	aCmc7[1]	, aCmc7[3]	, aCmc7[4]	, aCmc7[2]	,;
									aDadosCheq	, nParc)
					nParc --
					Loop
				EndIf
			EndIf
			
			Aadd( 	aDadosCheq	, {.T.		,aCmc7[1]	, aCmc7[2]	, ;
					aCmc7[3]	, aCmc7[4]	,cRg	 	, cTelefone	, ;
					.F. 		, aCmc7[5]	,cCpfCnpj } )
			
			lLeuCmc7 := .T.
			lRet		:= .T.
			If nCMC7CHQ == 2
				nValor	 := aParcelas[nParc][2]
				If(lUsaCH,LjImpCheque( aCmc7[1], aCmc7[3], aCmc7[4], aCmc7[2], @nValor, @cFavorec,;
				@cCidade, @dEmissao, @cObs, @cVerso ),.T.)
			EndIF
		Else
			// Erro ao tentar ler o cheque , Tentar novamente ou cancelar e informar manualmente?
			// Aten‡„o
			lRet := MsgYesNo( STR0049, STR0050 )
			If lRet
				nParc --
				Loop
			Else
				lLeuCmc7 := .F.
				lRet		:= .F.
				If nCMC7CHQ == 1
					Exit
				EndIF
			EndIf
		EndIf
		If nCMC7CHQ == 2
			While !lVolta
				If (ExistBlock("LJ020CHQ") .AND. !lFtvdVer12) .OR. (ExistBlock("FTVD020CHQ") .AND. lFtvdVer12)
					If !lFtvdVer12
						aDadosCheq := AClone(Execblock("LJ020CHQ",.F.,.F.,aDadosCheq))
					ElseIf lFtvdVer12
						aDadosCheq := AClone(Execblock("FTVD020CHQ",.F.,.F.,aDadosCheq))
					EndIf	
				Else
					
					LjxDCheq(	@oDlgRapid	, @nVlrCheq		, @dDtVenc		, @nParc	,;
								@nVezes		, @cBanco		, @cAgencia		, @cConta	,;
								@cCheque	, @cRg			, @cTelefone	, @lCheckTe	,;
								@lVolta		, @cCapBut2		, @lPrimeiro	, @lRet		,;
								@aDadosCheq	, @lCheckCh		, @aCheques		, nCMC7CHQ	,;
								@cComp		, @aParcelas	, @lUsaDisplay	, @cCpfCnpj ,;
								@cCliente	, @cLojaCli		, @lGCpfCnpj	, @cNomeTerc)
				EndIf
				If lVolta == .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se os campos obrigatorios foram digitados ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If LjxDValCampCh(	cBanco		, cAgencia	, cConta	, cCheque	,;
										aDadosCheq	, nParc)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica quando a duplicidade de cheques na base e na venda atual. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If LjxDVerChDig(	cBanco		, cAgencia	, cConta	, cCheque	,;
											aDadosCheq	, nParc)
							lRet		:= .T.
							Aadd( 	aDadosCheq	, 	{ lRet	,cBanco	,cCheque	,;
									cAgencia	,	cConta	,cRg	,cTelefone 	,;
									.F.			,	NIL		,cCpfCnpj })
							nValor	 := aParcelas[nParc][2]
							If(lUsaCH,LjImpCheque( cBanco, cAgencia, cConta, cCheque, @nValor, @cFavorec,;
							@cCidade, @dEmissao, @cObs, @cVerso ),.T.)
							lVolta := .T.
						EndIf
					EndIf
				EndIf
			End
		EndIf
		lVolta := .F.
	Next nParc
	
	If (Empty( cTelefone ) .OR. Empty( cRg )) .AND. lLeuCmc7
		// Dados do Cliente
		DEFINE MSDIALOG oDlgTel FROM	69,140 TO 243,313 TITLE STR0051 PIXEL;
		STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgRapid
		
		DEFINE FONT oFont NAME "TIMES NEW ROMAN" SIZE 6,16 BOLD
		// &Telefone/Rg
		If cPaisLoc == "BRA"		
		   @	5,  6 TO 60, 77 LABEL STR0052 OF oDlgTel	PIXEL
		Else    
		   cLabelDoc  := STR0053+AllTrim(RetTitle("A1_RG"))  //"&Telefone/"	   	
		   @	5,  6 TO 60, 77 LABEL cLabelDoc OF oDlgTel	PIXEL		
		EndIf   		   
		@ 17, 15 MSGET oTelefone VAR cTelefone SIZE 54, 10 OF oDlgTel PIXEL;
		PICTURE PesqPict("SA1","A1_TEL",15)
		@ 33, 15 MSGET oRg		 VAR cRG 		SIZE 54, 10 OF oDlgTel PIXEL;
		PICTURE PesqPict("SA1","A1_RG",15)
		
		@ 50,8 CHECKBOX oCheckTe VAR lCheckTe PROMPT STR0054 SIZE 66,8	OF oDlgtel FONT oFont PIXEL
		
		DEFINE SBUTTON FROM 64, 30 TYPE 1 ENABLE OF oDlgTel;
		ACTION (oDlgTel:End()) PIXEL
		
		ACTIVATE MSDIALOG oDlgTel CENTERED
		For nI := 1 to Len(aDadosCheq)
			aDadosCheq[nI][6] := cRg
			aDadosCheq[nI][7] := cTelefone
			aDadosCheq[nI][8] := lCheckTe
		Next nI
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicita a digita‡Æo manual do cheque caso o operador nao utilize ³
//³ o leitor Cmc7 ou se ocorreu algum error na leitura.					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lLeuCmc7 .AND. nCMC7CHQ == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Permitir a utilizacao de leitores de CMC7 conectados diretamente no teclado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If ExistBlock("LJCMC7TC") .AND. !lFtvdVer12
    	aCMC7 := Execblock("LJCMC7TC", .T., .T.)
		aAdd( 	aDadosCheq	, {.T.		,aCmc7[1]	,aCmc7[2]	,;
				aCmc7[3]	,aCmc7[4]	, cRg		, cTelefone	,;
				.F. 		,aCmc7[5]	,cCpfCnpj } )
    EndIf

	 If ExistBlock("FTVDCMC7TC") .AND. lFtvdVer12
    	aCMC7 := Execblock("FTVDCMC7TC", .T., .T.)
		aAdd( 	aDadosCheq	, {.T.		,aCmc7[1]	,aCmc7[2]	,;
				aCmc7[3]	,aCmc7[4]	, cRg		, cTelefone	,;
				.F. 		,aCmc7[5]	,cCpfCnpj } )
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se mudou a condicao zera array ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aDadosCheq ) <> nVezes
		aDadosCheq := {}
		cBanco	   := Space(nTamBanco)
		cAgencia   := Space(nTamAgencia)
		cConta	   := Space(nTamConta)
		cCheque	   := Space(nTamCheque)
		cRG        := IIf( Empty(cRG)      , Space(nTamRg), cRG       )
		cTelefone  := IIF( Empty(cTelefone), Space(nTamTel), cTelefone )
		cComp 	   := Space(nTamComp)
		lCheckTe   := .F.
		For nParc := 1 to nVezes
			Aadd( aDadosCheq , { lRet,cBanco, cCheque, cAgencia, cConta,;
			cRg, cTelefone, lCheckTe ,cComp} )
		Next nParc
		nParc := 1
	Else
		cBanco	  := aDadosCheq[nParc,2]
		cCheque	  := aDadosCheq[nParc,3]
		cAgencia  := aDadosCheq[nParc,4]
		cConta	  := aDadosCheq[nParc,5]
		cRG		  := aDadosCheq[nParc,6]
		cTelefone := aDadosCheq[nParc,7]
		lCheckTe  := aDadosCheq[nParc,8]
		cComp 	  := aDadosCheq[nParc,9]
		If Len(aDadosCheq[nParc]) >= 10 
			cCpfCnpj  := aDadosCheq[nParc,10] 
		EndIf
	EndIf

	If ExistBlock("LJ020CHQ") .AND. !lFtvdVer12
		aDadosCheq := AClone(Execblock("LJ020CHQ",.F.,.F.,aDadosCheq))
	ElseIf !lFtvdVer12
		LjxDCheq(	@oDlgRapid	, @nVlrCheq		, @dDtVenc		, @nParc	,;
					@nVezes		, @cBanco		, @cAgencia		, @cConta	,;
					@cCheque	, @cRg			, @cTelefone	, @lCheckTe	,;
					@lVolta		, @cCapBut2		, @lPrimeiro	, @lRet		,;
					@aDadosCheq	, @lCheckCh		, @aCheques		, nCMC7CHQ	,;
					@cComp		, @aParcelas	, @lUsaDisplay	, @cCpfCnpj ,;
					@cCliente	, @cLojaCli		, @lGCpfCnpj	, @cNomeTerc )                
	EndIf
	
	If ExistBlock("FTVD020CHQ") .AND. lFtvdVer12
		aDadosCheq := AClone(Execblock("FTVD020CHQ",.F.,.F.,aDadosCheq))
	ElseIf lFtvdVer12
		LjxDCheq(	@oDlgRapid	, @nVlrCheq		, @dDtVenc		, @nParc	,;
					@nVezes		, @cBanco		, @cAgencia		, @cConta	,;
					@cCheque	, @cRg			, @cTelefone	, @lCheckTe	,;
					@lVolta		, @cCapBut2		, @lPrimeiro	, @lRet		,;
					@aDadosCheq	, @lCheckCh		, @aCheques		, nCMC7CHQ	,;
					@cComp		, @aParcelas	, @lUsaDisplay	, @cCpfCnpj ,;
					@cCliente	, @cLojaCli		, @lGCpfCnpj	, @cNomeTerc)                
	EndIf
	
EndIf

If lRet
	aDadosCheq[1][1] := .T.  // Tudo OK com os dados do cheque.
	
	// Pode ser utilizado para impressao de cheque e/ou consulta ao Serasa
	LJDadosCh( cBanco,cAgencia,cConta,cCheque )
	If ExistBlock("LJIMPCHQ") .AND. !lFtvdVer12
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia os dados do cheque para o ponto de entrada e recebe ³
		//³os dados novamente.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xRetChq := ExecBlock("LJIMPCHQ",.F.,.F.,{aDadosCheq})
		
		If Valtype(xRetChq) == "A"
			aDadosCheq := AClone(xRetChq)
		EndIf		
	EndIf	
	
	If ExistBlock("FTVDIMPCHQ") .AND. lFtvdVer12
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia os dados do cheque para o ponto de entrada e recebe ³
		//³os dados novamente.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xRetChq := ExecBlock("FTVDIMPCHQ",.F.,.F.,{aDadosCheq})
		
		If Valtype(xRetChq) == "A"
			aDadosCheq := AClone(xRetChq)
		EndIf		
	EndIf
		
EndIf

RestArea( aArea )

Return aDadosCheq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDChkVenda³ Autor ³ Vendas Clientes     ³ Data ³ 09/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica diversas atributos para liberar o acesso a venda   ³±±
±±³          ³para o caixa que esta tentando entrar na rotina de venda	  ³±±
±±³          ³R pida.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Exl1 - True ou False                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³loja220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDChkVenda(lChkCXAber,lFrontExe)
Local lRet 			:= .T.
Local lAchouSX5  	:= .F.
Local lAchouSA6  	:= .T.

Default lChkCXAber 	:= .T.			// Usado pelo Front Loja (Nao checar o CX, pois eh feito posteriormente)
Default lFrontExe		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for administrador nao deixa fazer a venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __cUserID == "000000"
	
	// O administrador n„o poder  efetuar vendas. Utilize a op‡„o"
	// Senhas/Caixas no Menu Miscelƒnea para incluir um Caixa. Caso"
	// j  exista um cadastrado, re-entre no sistema com a senha de Caixa
	MsgInfo( STR0055 + STR0056 + STR0057 )
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A ocorrencia 25 (ACS), verifica se o usu rio ³
//³ poder  ou n„o efetuar um Atendimento.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If !ChkPsw(25)
		lRet := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usuario esta cadastrado como caixa. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(lFrontExe)
	If lRet
		DbSelectArea( "SX5" )
		SX5->(MsSeek( xFilial("SX5") + "23" ))
		While SX5->(!Eof()) .AND. xFilial("SX5") == SX5->X5_FILIAL .AND.;
			SX5->X5_TABELA == "23"
			If Upper(Trim(X5Descri())) == AllTrim(Upper(cUserName))
				lAchouSx5 := .T.
				Exit
			EndIf
			SX5->( DBSkip() )
		End
	EndIf
	If lAchouSx5 .AND. lRet
		DbSelectArea( "SA6" )
		If !(SA6->(MsSeek( xFilial("SA6") + SubStr( SX5->X5_CHAVE, 1, 3 ) ) ) )
			lAchouSa6 := .F.
		EndIf
	EndIf
	If !lAchouSx5 .AND. lRet
		Help( " ", 1, "NOCAIXASX5" )
		lRet := .F.
	EndIf
	If !lAchouSA6 .AND. lRet
		Help( " ", 1, "NOCAIXASA6" )
		lRet := .F.
	EndIf
Else
	If Empty(xNumCaixa())
		lRet := .F.
	EndIf
EndIf

If lChkCXAber.AND. lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Caixa esta Aberto. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ljCxAberto() .AND. lRet
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDChoicA³ Autor ³ Vendas Clientes       ³ Data ³ 28/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Solicita a escolha da Administradora da forma de pagto.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 - Forma de pagamento. Ex: CC                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Loja220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDChoicAdm( aAdm, cAdm, oComboAdm, cComboAdm, oCheckPag )
Local lRet  := .F.
Local aArea := GetArea()

DbSelectArea("SAE")
DbSetOrder(1)
MsSeek( xfilial("SAE") )

aAdm := {}
While !Eof() .AND. xFilial("SAE") == SAE->AE_FILIAL
	If AllTrim(SAE->AE_TIPO) == AllTrim(cAdm)
		Aadd( aAdm, SAE->AE_COD + " - " + SAE->AE_DESC )
	EndIf
	dbSkip()
End

If Len(aAdm) > 0
	lRet := .T.
	oComboAdm:SetITems( aAdm )
	oComboAdm:Enable()
	cComboAdm := aAdm[1]
Else
	aAdm := {}
	oComboAdm:SetITems( aAdm )
	oComboAdm:Disable()
	cComboAdm := ""
EndIf
If IsMoney(cAdm)
	oComboAdm:Disable()
	oCheckPag:Disable()
	oCheckPag:Refresh()
EndIf

oComboAdm:Refresh()

RestArea( aArea )

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDDtPag ³ Autor ³ Vendas Clientes       ³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se parcelas correspondem ao tipo de pagamento 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LjxDDtPag( cComboPag  , nParcela  , aItens   , dDataForm   ,;
                     lCheckPag , lValidParc, cCliente , cLojaCli  )

Local lRet 			:= .T.													//Retorno da funcao
Local cForma		:= ""													//Forma de pagamento
Local nEl 			:= Ascan( aItens, { |x| x[1] = cComboPag } )
Local cMV_FORMCRD	:= SuperGetMV("MV_FORMCRD")								// Conteudo do parametro "MV_FORMCRD"

Default lValidParc  	:= .T.
Default cComboPag		:= ""        
Default nParcela		:= 0
Default aItens			:= {}
Default dDataForm		:= CTOD("") 
Default lCheckPag		:= .F.
Default cCliente		:= ""
Default cLojaCli		:= ""

cForma := aItens[nEl][2]

If lValidParc
   If (IsMoney(cForma) .AND. nParcela <> 1 .AND. IIf(cPaisLoc == "BRA",.T.,dDataForm > dDataBase)) .OR.;
	  (IsMoney(cForma) .AND. dDataForm > dDataBase .AND. nParcela == 1)
	  Help( " ", 1, "LJNODINHEI" )
	  lRet := .F.
   EndIf	  
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Validacao acionada quando muda a forma de pagamento de uma parcela ³
   //³quando uma das transacoes TEF eh rejeitada. Nao valida se a parcela³
   //³em Dinheiro eh a primeira porque, neste momento, ainda nao re-orde-³   
   //³nou  as parcelas													 ³      
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (IsMoney(cForma) .AND. dDataForm > dDataBase)   
	  Help( " ", 1, "LJNODINHEI" )
	  lRet := .F.      
   EndIf
EndIf 

If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
	If lRet
		If (cCliente+cLojaCli == SuperGetmv("MV_CLIPAD")+SuperGetmv("MV_LOJAPAD"))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o cliente seja cliente padrao, não sera permitido ³
			//³alterar a forma de pagamento contida no parametro      ³
			//³MV_FORCRD                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cForma $ cMV_FORMCRD
				MsgStop(STR0140)	//"Forma de pagamento não permitida para o cliente padrão"
				lRet := .F.
			EndIf	
		EndIf
    EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDDinV  ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se a tela pode ou nÆo ser fechada                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDDinV(	nValor,		lOk,	oDlgLojaPag,	cComboPag,;
					dDataForm )
Local lLj010Val  := ExistBlock("Lj010Val")			// verifica a existencia do PE LJ010Val
Local lFTVD010Val := ExistBlock("FTVD010Val")			// verifica a existencia do PE FTVD010Val
Local lRet:=.T.										// retorno da funcao
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

If lLj010Val .AND. !lFtvdVer12
	lRet := ExecBlock("Lj010Val",.F.,.F.,{nValor,cComboPag,dDataForm})
EndIf

If lFTVD010Val .AND. lFtvdVer12
	lRet := ExecBlock("FTVD010Val",.F.,.F.,{nValor,cComboPag,dDataForm})
EndIf

If lRet
	lOk:=.T.
	oDlgLojaPag:End()
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDCheq  ³ Autor ³ Vendas Clientes       ³ Data ³ 22/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Entrada de Informacoes do Cheque                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³loja220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDCheq(	oDlgRapid	, nVlrCheq	, dDtVenc		, nParc		,;
					nVezes		, cBanco	, cAgencia		, cConta	,;
					cCheque		, cRg		, cTelefone		, lCheckTe	,;
					lVolta		, cCapBut2	, lPrimeiro		, lRet		,;
					aDadosCheq	, lCheckCh	, aCheques		, nCMC7CHQ	,;
					cComp		, aParcelas	, lUsaDisplay	, cCpfCnpj  ,;
					cCliente	, cLojaCli	, lGCpfCnpj 	, cNomeTerc)

Local oDlgGetCh
Local oFont
Local oFont1
Local oFont2
Local oVlrCheq
Local oDtVenc
Local oParc
Local oBanco
Local oAgencia
Local oConta
Local oCheque
Local oRg  
Local oCpfCnpj
Local oTelefone
Local oCheckCh
Local oCheckTe
Local oButton1
Local oButton2
Local nMoedaParc := aParcelas[1][11]
Local cLabelDoc  := ""
Local oKeyb											// Objeto Teclado para Touch Screen
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local oNomeTerc
Local lLJXVlDCheq := ExistBlock("LJXVlDCheq") //Ponto de Entrada para validar a confirmação dos dados do cheque

Default cCpfCnpj := ""
Default cCliente := ""
Default cLojaCli := ""
Default lGCpfCnpj := .F.
Default cNomeTerc := ""


   DEFINE FONT oFont NAME "Arial"  SIZE 6,16 BOLD
   DEFINE FONT oFont1 NAME "Arial"  SIZE 5,15 BOLD
   DEFINE FONT oFont2 NAME "Arial"  SIZE 10,15 BOLD

If lUsaDisplay
	DisplayEnv(StatDisplay(), "1C" + Upper(STR0058))  
	DisplayEnv(StatDisplay(), "2E"+ STR0059) 	 
EndIf

// Dados do Cheque
If lTouch
	DEFINE MSDIALOG oDlgGetCh FROM 12,13 TO 520,510 TITLE STR0058 OF oDlgRapid PIXEL
Else
	DEFINE MSDIALOG oDlgGetCh FROM 12, 13 TO 400,510 TITLE STR0058 OF oDlgRapid PIXEL
EndIf
         
// Definindo o Objeto Teclado
If lTouch
	oKeyb := TKeyboard():New( 150, 10, 2, oDlgGetCh )     
EndIf
@ 2,15 TO 41,240 OF oDlgGetCh PIXEL 

// Valor do Cheque:
@ 10,40 SAY STR0060 of oDlgGetCh SIZE 50,9 PIXEL
@ 10,90 SAY oVlrCheq VAR Transform(nVlrCheq,PesqPict("SL1","L1_VLRTOT",14,nMoedaParc)) of oDlgGetCh FONT oFont COLOR CLR_HBLUE SIZE 55,8 PIXEL

// Data do Vencimento:
@ 23,40 SAY STR0061 OF oDlgGetCh SIZE 55,9 PIXEL
@ 23,95 SAY oDtVenc VAR dDtVenc OF oDlgGetCh FONT oFont COLOR CLR_HRED SIZE 55,8 PIXEL

// Cheque:
@ 23,130 SAY STR0062 OF oDlgGetCh SIZE 25,9 PIXEL
@ 23,155 SAY oParc VAR StrZero(nParc,3) OF oDlgGetCh FONT oFont COLOR CLR_HRED SIZE 25,9 PIXEL PICTURE "999"

// "de"
@ 23,170 SAY STR0063           OF oDlgGetCh FONT oFont COLOR CLR_HRED SIZE 10,9 PIXEL
@ 23,190 SAY StrZero(nVezes,3) OF oDlgGetCh FONT oFont COLOR CLR_HRED SIZE 25,9 PIXEL PICTURE "999"

@ 43,15  TO 170,240 OF oDlgGetCh PIXEL

// Banco:
@ 49,40 Say STR0064 OF oDlgGetCh SIZE 20,9 PIXEL
@ 48,75 MSGET oBanco VAR cBanco OF oDlgGetCh Picture PesqPict("SEF","EF_BANCO",3) SIZE 25,9 PIXEL
If lTouch
	oBanco:bGotFocus  := {|| If(lUsaDisplay, (DisplayEnv(StatDisplay(), "2E"+ STR0064)) ,),oKeyb:SetVars(oBanco,TamSX3("EF_BANCO")[1])}  
Else
	oBanco:bGotFocus  := {|| If(lUsaDisplay, (DisplayEnv(StatDisplay(), "2E"+ STR0064)) ,)}  
EndIf
oBanco:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0064 + " " + cBanco ),)}

// Agencia:
@ 49,105 Say STR0065 OF oDlgGetCh SIZE 30,9 PIXEL
@ 48,130 MSGET oAgencia VAR cAgencia OF oDlgGetCh Picture PesqPict("SEF","EF_AGENCIA",5) SIZE 18, 9 PIXEL
If lTouch
	oAgencia:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0065),),oKeyb:SetVars(oAgencia,TamSX3("EF_AGENCIA")[1])}  
Else
	oAgencia:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0065),)}  
EndIf
oAgencia:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0065 + " " + cAgencia ),)}

// Conta:
@ 49,165 Say STR0066 OF oDlgGetCh SIZE 25,7 PIXEL
@ 48,185 MSGET oConta VAR cConta OF oDlgGetCh Picture PesqPict("SEF","EF_CONTA",10) SIZE 35,7 PIXEL
If lTouch
	oConta:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0066),),oKeyb:SetVars(oConta,TamSX3("EF_CONTA")[1])}  
Else
	oConta:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0066),)}  
EndIf
oConta:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0066 + " " + cConta ),)}

// Num Cheque:
@ 66,40 Say STR0067 OF oDlgGetCh SIZE 40,9 PIXEL
@ 65,75 MSGET oCheque VAR cCheque OF oDlgGetCh Picture PesqPict("SEF","EF_NUM",15) SIZE 50, 9 PIXEL  
If lTouch
	oCheque:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0067),),oKeyb:SetVars(oCheque,TamSX3("EF_NUM")[1])}  
Else
	oCheque:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0067),)}  
EndIf
oCheque:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0067 + " " + cCheque ),)}

// Compensacao
@ 66,143 Say STR0068 OF oDlgGetCh SIZE 40,9 PIXEL
@ 65,185 MSGET oComp VAR cComp OF oDlgGetCh Picture PesqPict("SEF","EF_COMP",3) SIZE 25,9 PIXEL 
If lTouch
	oComp:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0068),),oKeyb:SetVars(oComp,TamSX3("EF_COMP")[1])}  
Else
	oComp:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0068),)}  
EndIf
oComp:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0068 + " " + cComp ),)}

// Telefone:
@ 81,40 Say STR0070 OF oDlgGetch SIZE 40,9 PIXEL
@ 80,75 MSGET oTelefone VAR cTelefone OF oDlgGetCh Picture PesqPict("SEF","EF_TEL",15) SIZE 40,9 PIXEL
If lTouch
	oTelefone:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0070),),oKeyb:SetVars(oTelefone,TamSX3("EF_TEL")[1])}  
Else
	oTelefone:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0070),)}  
EndIf
oTelefone:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0070 + " " + cTelefone ),)}

// RG:
If cPaisLoc == "BRA"
	@ 81,145 Say STR0069 OF oDlgGetCh SIZE 10,9 PIXEL   
Else
    cLabelDoc  := AllTrim(RetTitle("A1_RG"))+":"  
	@ 81,145 Say cLabelDoc OF oDlgGetCh SIZE 10,9 PIXEL	
EndIf
@ 80,160 MSGET oRg VAR cRg OF oDlgGetCh Picture PesqPict("SEF","EF_RG",15) SIZE 50,9 PIXEL
If lTouch
	oRg:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0069),),oKeyb:SetVars(oRg,TamSX3("EF_RG")[1])}  
Else
	oRg:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0069),)}  
EndIf
oRg:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0069 + " " + cRg ),)}

// CPF                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SERA EXIBIDO O CAMPO PARA DIGITACAO DO CPF/CNPJ QUANDO O PARAMETRO MV_LJCPFCH FOR VERDADEIRO³
//³SOMENTE CLIENTE PADRAO DEVERA INFORMAR O CPF/CNPJ OU PARA OUTROS CLIENTES 				   ³
//³QUE NAO TENHAM O CPF/CNPJ CADASTRADO DE CLIENTE     						                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If SuperGetmv("MV_LJCPFCH",,.F.)
	
	If (SuperGetmv("MV_CLIPAD",,"") + SuperGetmv("MV_LOJAPAD",,"")) = (cCliente + cLojaCli) .OR. ;
		 (((SuperGetmv("MV_CLIPAD",,"") + SuperGetmv("MV_LOJAPAD",,"")) <> (cCliente + cLojaCli)) .AND. AllTrim(cCpfCnpj) = "") 			
		 	
		lGCpfCnpj     := .T.
		
		If cPaisLoc == "BRA"
			@ 96,40 Say STR0200 OF oDlgGetCh SIZE 25,15 PIXEL   
		Else
		    cLabelDoc  := AllTrim(RetTitle("EF_CGCCPF"))+":"  
			@ 96,40 Say cLabelDoc OF oDlgGetCh SIZE 25,15 PIXEL	
		EndIf
		
		@ 95,75 MSGET oCpfCnpj VAR cCpfCnpj OF oDlgGetCh Picture PesqPict("SEF","EF_CPFCNPJ",15) SIZE 60,9 PIXEL
		
		If lTouch
			oCpfCnpj:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0200),),oKeyb:SetVars(oCpfCnpj,TamSX3("EF_CPFCNPJ")[1])}  
		Else
			oCpfCnpj:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0200),)}  
		EndIf
		
		oCpfCnpj:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0200 + " " + cCpfCnpj ),)}	
		
	EndIf
Else
	lGCpfCnpj     := .F.	
EndIf

// Numero de Cheque Sequencial
@ 110,145 CHECKBOX oCheckCh VAR lCheckCh PROMPT STR0071 SIZE 90,8 PIXEL ;
When Len(aCheques) > 1 OF oDlgGetCh ON CHANGE (If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0071 + ": " + (If(lCheckCh,"<SIM>","<NAO>")) ),),; 
If(lCheckCh .AND.;
nVezes <> nParc,(cCapBut2 := STR0072,;     //"&Confirma"
oButton2:cTitle := cCapBut2),(If(nParc <> nVezes,;
(cCapBut2 := STR0073, oButton2:cTitle := cCapBut2),))),;  //"&Avan‡ar >"
oButton2:Refresh()) FONT oFont1
oCheckCh:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0071  + ": " + (If(lCheckCh,"<SIM>","<NAO>")) ),)}  
                         
//Cheque de Terceiros                                                                                        //If(lCheckTe,oNomeTerc:Enable(),oNomeTerc:Disable())
@ 110,40 CHECKBOX oCheckTe VAR lCheckTe PROMPT STR0074 SIZE 90,8 PIXEL FONT oFont OF oDlgGetCh;
ON CHANGE (If(lUsaDisplay, (DisplayEnv(StatDisplay(), "2E"+ STR0074 + ": " + (If(lCheckTe,"<SIM>","<NAO>"))) , If(lCheckTe,oNomeTerc:Enable(),oNomeTerc:Disable())), If(lCheckTe,oNomeTerc:Enable(),oNomeTerc:Disable()) ) )
oCheckTe:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0074 + ": " + (If(lCheckTe,"<SIM>","<NAO>"))),)}
// Compensacao
@ 66,143 Say STR0068 OF oDlgGetCh SIZE 40,9 PIXEL
@ 65,185 MSGET oComp VAR cComp OF oDlgGetCh Picture PesqPict("SEF","EF_COMP",3) SIZE 25,9 PIXEL 
If lTouch
	oComp:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0068),),oKeyb:SetVars(oComp,TamSX3("EF_COMP")[1])}  
Else
	oComp:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0068),)}  
EndIf
oComp:bLostFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E"+ STR0068 + " " + cComp ),)}

// Nome do Emitente                                                                                                                                                                                                                                                       
@ 125,40 Say "Emitente:" OF oDlgGetCh SIZE 20,9 PIXEL                      
@ 122,65 MSGET oNomeTerc VAR cNomeTerc OF oDlgGetCh Picture PesqPict("SEF","EF_EMITENT",15) SIZE 130,1 PIXEL 
If lTouch
	oNomeTerc:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E" + "Emitente:"),),oKeyb:SetVars(oNomeTerc,TamSX3("EF_EMITENT")[1])}  
Else
	oNomeTerc:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E" + "Emitente:" + cNomeTerc),)}  
EndIf
oNomeTerc:bGotFocus  := {|| If(lUsaDisplay, DisplayEnv(StatDisplay(), "2E" + "Emitente:" + cNomeTerc),)}  
                   
If(lCheckTe,oNomeTerc:Enable(),oNomeTerc:Disable())
oNomeTerc:Refresh() 
oDlgGetCh:Refresh() 

If nCMC7CHQ == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bot„o para retornar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@ 145,160 BUTTON oButton1 PROMPT STR0075 SIZE 40,13 PIXEL ACTION (lVolta := .T. ,;
	If(	LjxDNextCheq(	oCheckCh	, @nParc		, @lVolta	, @cBanco		,;
						@cCheque	, @cAgencia		, @cConta	, @cRG			,;
						@cTelefone	, @aDadosCheq	, @cCapBut2	, @lCheckCh		,;
						@nVezes		, oParc			, oBanco	, oAgencia		,;
						@oConta		, oCheque		, oRg		, oTelefone		,;
						oButton1	, oButton2		, @lRet		, @lPrimeiro	,;
						@lCheckTe	, oCheckTe		, cComp		, oVlrCheq		,;
		    			@nVlrCheq	, oDtVenc		, @dDtVenc	, @nMoedaParc	,;
		    			@aCheques	, @aParcelas	, lGCpfCnpj, oCpfCnpj		,;
		    			@cCpfCnpj, oNomeTerc, @cNomeTerc ),,),If(nParc == 1 .AND. lPrimeiro,;
						(lRet := .F.,oDlgGetch:End()),)) OF oDlgGetCh
						
	oButton1:bGotFocus :={|| If (lUsaDisplay,(If(!lCheckCh .AND. nVezes <> nParc     ;
							,(DisplayEnv(StatDisplay(), "1C" + Upper(STR0076) ),DisplayEnv(StatDisplay(), "2C" + Upper(STR0077) )  );  //"Pressione a tecla <AVANCA> e preencha""os dados do proximo cheque" 
							,(DisplayEnv(StatDisplay(), "1C" + Upper(STR0075) ),DisplayEnv(StatDisplay(), "2C" + Upper(STR0079) )  );  //"Pressione a tecla <CONFIRMA> para""finalizar os dados do cheque"
							)),)  } 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bot„o para Avan‡ar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Ponto de Entrada para validar a confirmação dos dados do cheque
	If lLJXVlDCheq
		@ 145,200 BUTTON oButton2 PROMPT cCapBut2 SIZE 40,13 PIXEL ACTION Iif(ExecBlock("LJXVlDCheq",.F.,.F.,{nVlrCheq,dDtVenc,nParc,nVezes,;
																											  cBanco,cAgencia,cConta,cCheque,;
																											  cComp,cTelefone,cRg,cCpfCnpj,;
																											  lCheckCh,lCheckTe,cComp,cNomeTerc}),;
																			 ( lVolta := .F., LjxDGo_Button(	@cBanco		, @cAgencia		, @cConta		, @cCheque		,;
																												@aDadosCheq	, @nParc		, oCheckCh		, @lVolta		,;
																												@cRG		, @cTelefone	, @cCapBut2		, @lCheckCh		,;
																												@nVezes		, oParc			, oBanco		, oAgencia		,;
																												oConta		, oCheque		, oRg			, oTelefone		,;
																												oButton1	, oButton2		, @lRet			, @lPrimeiro	,;
																												oDlgGetCh	, @lCheckTe		, oCheckTe		, cComp		   	,;
																												oVlrCheq	, @nVlrCheq		, oDtVenc		, @dDtVenc		,;
																												@nMoedaParc	, @aCheques		, @aParcelas	, oCpfCnpj		,;
																									   			@cCpfCnpj	, lGCpfCnpj, oNomeTerc, @cNomeTerc )),;
																			 Nil) OF oDlgGetCh
	Else
		@ 145,200 BUTTON oButton2 PROMPT cCapBut2 SIZE 40,13 PIXEL ACTION ( lVolta := .F.,;
		LjxDGo_Button(	@cBanco		, @cAgencia		, @cConta		, @cCheque		,;
						@aDadosCheq	, @nParc		, oCheckCh		, @lVolta		,;
						@cRG		, @cTelefone	, @cCapBut2		, @lCheckCh		,;
						@nVezes		, oParc			, oBanco		, oAgencia		,;
						oConta		, oCheque		, oRg			, oTelefone		,;
						oButton1	, oButton2		, @lRet			, @lPrimeiro	,;
						oDlgGetCh	, @lCheckTe		, oCheckTe		, cComp		   	,;
						oVlrCheq	, @nVlrCheq		, oDtVenc		, @dDtVenc		,;
						@nMoedaParc	, @aCheques		, @aParcelas	, oCpfCnpj		,;
			   			@cCpfCnpj	, lGCpfCnpj, oNomeTerc, @cNomeTerc )) OF oDlgGetCh		
	EndIf


	// Definindo a Acao da tecla ENTER do Teclado oKeyb
	// Definindo onde o Foco deve iniciar na Dialog
	If lTouch
		oKeyb:bEsc:={|| oDlgGetCh:End()}
		oKeyb:SetEnter({|| ( lVolta := .F.,;
		LjxDGo_Button(@cBanco,@cAgencia,@cConta,@cCheque,@aDadosCheq,@nParc,;
		oCheckCh,@lVolta,@cRG,@cTelefone,@cCapBut2,@lCheckCh,@nVezes,;
		oParc,oBanco,oAgencia,oConta,oCheque,oRg,oTelefone,oButton1,;
		oButton2,@lRet,@lPrimeiro,oDlgGetCh,@lCheckTe,oCheckTe,cComp,;
		oVlrCheq,@nVlrCheq,oDtVenc,@dDtVenc,@nMoedaParc,aCheques,;
		oCpfCnpj,@cCpfCnpj,lGCpfCnpj))})	
		oBanco:SetFocus()
    EndIf
					
	ACTIVATE MSDIALOG oDlgGetCh CENTERED
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bot„o para retornar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 150,100 BUTTON oButton1 PROMPT STR0075 SIZE 40,13 PIXEL ACTION (If(nParc > 1,lVolta := .T.,lVolta := .F.),;
	lRet := .F.,oDlgGetch:End()) OF oDlgGetCh
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bot„o para Avan‡ar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Ponto de Entrada para validar a confirmação dos dados do cheque
	If lLJXVlDCheq
		@ 150,150 BUTTON oButton2 PROMPT cCapBut2 SIZE 40,13 PIXEL ACTION Iif(ExecBlock("LJXVlDCheq",.F.,.F.,{nVlrCheq,dDtVenc,nParc,nVezes,;
																											  cBanco,cAgencia,cConta,cCheque,;
																											  cComp,cTelefone,cRg,cCpfCnpj,;
																											  lCheckCh,lCheckTe,cComp,cNomeTerc}),;
																			 (lVolta:=.F.,oDlgGetCh:End()),;
																			  Nil) OF oDlgGetCh
	Else
		@ 150,150 BUTTON oButton2 PROMPT cCapBut2 SIZE 40,13 PIXEL ACTION (lVolta:=.F.,oDlgGetCh:End()) OF oDlgGetCh		
	EndIf

	
	// Definindo a Acao da tecla ENTER do Teclado oKeyb
	// Definindo onde o Foco deve iniciar na Dialog
	If lTouch
		oKeyb:bEsc:={|| oDlgGetCh:End()}
		oKeyb:SetEnter({|| (lVolta:=.F.,oDlgGetCh:End()) })
		oPercDesc:SetFocus()
    EndIf

	
	ACTIVATE MSDIALOG oDlgGetCh CENTERED
	
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDGo_But³ Autor ³ Vendas Clientes       ³ Data ³ 11/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Botao de Avan‡ar.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjxDGo_Button                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDGo_Button(	cBanco		, cAgencia	, cConta	, cCheque	,;
						aDadosCheq	, nParc		, oCheckCh	, lVolta	,;
						cRG			, cTelefone	, cCapBut2	, lCheckCh	,;
						nVezes		, oParc		, oBanco	, oAgencia	,;
						oConta		, oCheque	, oRg		, oTelefone	,;
						oButton1	, oButton2	, lRet		, lPrimeiro	,;
						oDlgGetCh	, lCheckTe	, oCheckTe	, cComp		,;
						oVlrCheq	, nVlrCheq	, oDtVenc	, dDtVenc	,;
						nMoedaParc	, aCheques	, aParcelas	, oCpfCnpj	,;
						cCpfCnpj	, lGCpfCnpj, oNomeTerc, cNomeTerc)
						
Default oCpfCnpj  := Nil
Default cCpfCnpj  := ""
Default lGCpfCnpj := .F.
Default oNomeTerc := Nil
Default cNomeTerc := ""



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os campos obrigatorios foram digitados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjxDValCampCh(	cBanco		, cAgencia	, cConta	, cCheque	,;
					aDadosCheq	, nParc		, cCpfCnpj	, lGCpfCnpj)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica quando a duplicidade de cheques na base e na venda atual. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjxDVerChDig(cBanco,cAgencia,cConta,cCheque,aDadosCheq,nParc)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a tela para a pr¢xima parcela ou para o encerramento da mesma  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LjxDNextCheq(oCheckCh	, @nParc		, @lVolta	, @cBanco		,;
						@cCheque	, @cAgencia		, @cConta	, @cRG			,;
						@cTelefone	, @aDadosCheq	, @cCapBut2	, @lCheckCh		,;
						@nVezes		, oParc			, oBanco	, oAgencia		,;
						oConta		, oCheque		, oRg		, oTelefone		,;
						oButton1	, oButton2		, @lRet		, @lPrimeiro	,;
						@lCheckTe	, oCheckTe		, cComp		, oVlrCheq		,;
				       	@nVlrCheq	, oDtVenc		, @dDtVenc	, @nMoedaParc	,;
				        @aCheques	, @aParcelas	, lGCpfCnpj , oCpfCnpj		,;
				        @cCpfCnpj, oNomeTerc, cNomeTerc)
			oDlgGetCh:End()
		EndIf
	EndIf
EndIf

Return Nil

/*

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDNextCh³ Autor ³ Vendas Clientes       ³ Data ³ 28/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Avan‡a ou retrocede um Cheque.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Loja220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDNextCheq(	oCheckCh	, nParc			, lVolta	, cBanco		,;
						cCheque		, cAgencia		, cConta	, cRG			,;
						cTelefone	, aDadosCheq	, cCapBut2	, lCheckCh		,;
						nVezes		, oParc			, oBanco	, oAgencia		,;
						oConta		, oCheque		, oRg		, oTelefone		,;
						oButton1	, oButton2		, lRet		, lPrimeiro		,;
						lCheckTe	, oCheckTe		, cComp		, oVlrCheq		,;
						nVlrCheq	, oDtVenc		, dDtVenc	, nMoedaParc	,;
						aCheques	, aParcelas		, lGCpfCnpj , oCpfCnpj  	,;
						cCpfCnpj, oNomeTerc, cNomeTerc )
Local nI
Local lConfirma := .F.
Local cDadoAtu  := ""
Local cDadoProx := ""
Local nParProx  := 0  


Default lGCpfCnpj := .F.
Default oCpfCnpj  := Nil
Default cCpfCnpj  := ""

Default oNomeTerc  := Nil
Default cNomeTerc  := ""

If lVolta
	If nParc == 1
		lPrimeiro := .T.
	Else
		lPrimeiro := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda os dados atuais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDadosCheq[nParc] := { lRet			,cBanco		,cCheque	,cAgencia	,;
							cConta		,cRg		,cTelefone	,lCheckTe	,;
							cComp		,cCpfCnpj, cNomeTerc}
	
	If nParc > 1
		nParc --
		cBanco		:= aDadosCheq[nParc,2]
		cCheque		:= aDadosCheq[nParc,3]
		cAgencia 	:= aDadosCheq[nParc,4]
		cConta		:= aDadosCheq[nParc,5]
		cRG			:= aDadosCheq[nParc,6]
		cTelefone	:= aDadosCheq[nParc,7]
		lCheckTe 	:= aDadosCheq[nParc,8]
		cComp 		:= aDadosCheq[nParc,9]
		If Len(aDadosCheq[nParc]) >= 10 
			cCpfCnpj	:= aDadosCheq[nParc,10]
		Endif
		nVlrCheq   	:= aCheques[nParc,2]
		dDtVenc    	:= aCheques[nParc,1]
		nMoedaParc 	:= aParcelas[nParc,11]
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso confirme todos os dados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCheckCh
		For nI := 1 to Len(aDadosCheq)
			aDadosCheq[nI] := { lRet,cBanco,cCheque,cAgencia,cConta,cRg,;
			cTelefone,lCheckTe ,cComp,cCpfCnpj, cNomeTerc}
			cCheque := Soma1(AllTrim(cCheque), Len(AllTrim(cCheque)))
		Next nI
		lConfirma := .T.
		lPrimeiro := .T.
		lRet		 := .T. // Operacao Ok
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados da parcela atual ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDadoAtu  := cBanco + cCheque + cAgencia + cConta + cRg + cTelefone + cCpfCnpj
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pr¢xima parcela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nParProx := nParc + 1
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se est  na £ltima parcela. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nParProx > Len( aDadosCheq )
			nParProx := Len( aDadosCheq )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados da pr¢xima parcela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDadoProx := aDadosCheq[nParProx,2] + aDadosCheq[nParProx,3] +;
		aDadosCheq[nParProx,4] + aDadosCheq[nParProx,5] +;
		aDadosCheq[nParProx,6] + aDadosCheq[nParProx,7]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atribui ao Array os dados atuais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosCheq[nParc] := { lRet,cBanco,cCheque,cAgencia,cConta,cRg,;
								cTelefone,lCheckTe ,cComp,cCpfCnpj,cNomeTerc}
		
		If Empty(cDadoProx)
			aDadosCheq[nParc] := { lRet,cBanco,cCheque,cAgencia,cConta,cRg,;
									cTelefone,lCheckTe,cComp,cCpfCnpj,cNomeTerc } 
			cCheque := Soma1(AllTrim(cCheque), Len(AllTrim(cCheque)))
		Else
			cBanco		:= aDadosCheq[nParProx,2]
			cCheque		:= aDadosCheq[nParProx,3]
			cAgencia 	:= aDadosCheq[nParProx,4]
			cConta		:= aDadosCheq[nParProx,5]
			cRG			:= aDadosCheq[nParProx,6]
			cTelefone	:= aDadosCheq[nParProx,7]
			lCheckTe 	:= aDadosCheq[nParProx,8]
			cComp 		:= aDadosCheq[nParProx,9]
			If Len(aDadosCheq[nParProx]) >= 10
				cCpfCnpj    := aDadosCheq[nParProx,10]   
			EndIf
		EndIf
		nVlrCheq   := aCheques[nParProx,2]
		dDtVenc    := aCheques[nParProx,1]
		nMoedaParc := aParcelas[nParProx,11]
	EndIf
	nParc ++
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Muda o caption dependendo da parcela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nParc == nVezes
	cCapBut2   := STR0072					// &Confirma
	oButton2:cTitle := cCapBut2
Else
	cCapBut2   := STR0073 	// "&Avan‡ar >"
	oButton2:cTitle := cCapBut2
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso clicar no botao na ultima parcela, confirma... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nParc > nVezes
	lRet		 := .T.
	lConfirma := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refresh dos dados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oParc:Refresh()
oBanco:Refresh()
oAgencia:Refresh()
oConta:Refresh()
oCheque:Refresh()
oRg:Refresh()
oTelefone:Refresh()
oButton1:Refresh()
oButton2:Refresh()
oCheckTe:Refresh()
oVlrCheq:Refresh()
oDtVenc:Refresh()

If lGCpfCnpj 
	oCpfCnpj:Refresh()
EndIf
         
If oNomeTerc <> Nil
	oNomeTerc:Refresh()
Endif	

Return lConfirma


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDVerChD³ Autor ³ Vendas Clientes       ³ Data ³ 18/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o cheque ja esta cadastrado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjxDVerChDig                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDVerChDig(cBanco,cAgencia,cConta,cCheque,aDadosCheq,nParc)
Local cCheqCad := ""
Local nI       := 1
Local lRet     := .T.
Local aArea    := GetArea()
Local cCheqSEF := cBanco + cAgencia + cConta + cCheque
Local cCheqDig := Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta) +;
Alltrim(cCheque)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa se o cheque ja existe. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SEF")
DbSetOrder(1)
If MsSeek( xFilial("SEF") + cCheqSEF )
	Tone(3000,1)
	// Este cheque j  se encontra no Sistema, verifique e informe novamente.
	// Aten‡Æo
	MsgStop( STR0080, STR0002 )
	lRet := .F.
Else
	For nI := 1 to Len(aDadosCheq)
		cCheqCad := Alltrim(aDadosCheq[nI][2]) + Alltrim(aDadosCheq[nI][4]) +;
		Alltrim(aDadosCheq[nI][5]) + Alltrim(aDadosCheq[nI][3])
		If cCheqDig == cCheqCad .AND. nParc <> nI
			Tone(3000,1)
			// Este cheque j  foi informado nesta venda, verifique e informe novamente.
			// Aten‡„o
			MsgStop(STR0081 ,STR0002 )
			lRet := .F.
			Exit
		EndIf
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄ Array aDadosCheq ÄÄÄÄÄÄÄÄ¿
//³ aDadosCheq[nI][2]  // Banco     ³
//³ aDadosCheq[nI][3]  // Cheque    ³
//³ aDadosCheq[nI][4]  // Agencia   ³
//³ aDadosCheq[nI][5]  // cConta    ³
//³ aDadosCheq[nI][6]  // cRg       ³
//³ aDadosCheq[nI][7]  // cTelefone ³
//³ aDadosCheq[nI][9]  // cComp     ³ 
//³ aDadosCheq[nI][10]  //cCpfCnpj  ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a Area anterior ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aArea )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDValCam³ Autor ³ Vendas Clientes       ³ Data ³ 11/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os campos obrigat¢rios foram digitados.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjxDValCampCh                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDValCampCh(	cBanco		,cAgencia	,cConta		,cCheque	,;
						aDadosCheq	,nParc		,cCpfCnpj	,lGCpfCnpj)
Local lRet		:= .T.
Local aArea 	:= GetArea()


Default cCpfCnpj := ""
Default lGCpfCnpj := .F.


If Empty(cBanco)
	Tone(3000,1)
	// O Banco do cheque n„o foi informado. Informe-o / Aten‡Æo
	MsgStop(STR0082, STR0002 )
	lRet := .F.
ElseIf Empty(cAgencia)
	Tone(3000,1)
	// A Agˆncia do cheque n„o foi informada. Informe-a / Aten‡Æo
	MsgStop(STR0083, STR0002 )
	lRet := .F.                                                                             
ElseIf Empty(cConta)
	Tone(3000,1)
	// A Conta do cheque n„o foi informada. Informe-a
	MsgStop( STR0084, STR0002 )
	lRet := .F.
ElseIf Empty(cCheque)
	Tone(3000,1)
	// O N£mero do cheque n„o foi informado. Informe-o
	MsgStop(STR0085, STR0002 )
	lRet := .F.
ElseIf lGCpfCnpj
	If Empty(cCpfCnpj)
		Tone(3000,1)
		//"O CPF/CNPJ do cliente não foi informado. Informe-o"
		MsgStop(STR0234, STR0002 )
		lRet := .F.
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a Area anterior ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aArea )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDGetTro³ Autor ³ Vendas Clientes       ³ Data ³ 05/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita a digita‡Æo do troco por parte do operador        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExN1 - LjxDGetTroco()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Se Confirmar   -> ExpN1 - Valor do troco                   ³±±
±±³          ³ Caso Contr rio -> ExpL1 - .F. Volta para a janela anterior ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDGetTroco(	oDlgRapid	, lDinheiro	, nDinMoedaCor	, nDinheiro	,;
						nVales		, nTroco, lUsaDisplay, nArredondar )
Local nValor := 0.00
Local nPagar := 0.00
Local lRet := .F.
Local nVlrPag := 0
Local oFonte
Local oDlgTroco
Local oButton2
Local oButton1
Local oPago
Local oSay
Local oSay_2
Local uRet
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. ) 
Local nMoedaCor	:= 1 														//Moeda Corrente
Local lFtvdVer12		:= LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lArredondar		:= SuperGetMv("MV_LJINSAR",,.F.)		//Parâmetro para ativar doação para o Instituto Arredondar
Local lSoVisual			:= (nModulo = 23 .AND. nTroco > 0 )

Default lUsaDisplay	:= .F.
Default nArredondar	:= 0
Default nTroco		:= 0

If cPaisLoc <> "BRA" .AND. Type("nDinMoedaCor") == "N"
   nDinheiro  := nDinMoedaCor 
EndIf

//Verifico se ‚ dinheiro ou vale
If lDinheiro
	nPagar		:= nDinheiro
Else
	nPagar		:= nVales
EndIf

If lSoVisual
//  Valores somente para exibição
//  Não alterar essas variaveis, pois os mesmos já estão salvos nos arrays de pagamento do front
	nVlrPag 	:= nDinheiro
	nValor 		:= nTroco
	If nDinheiro >= nTroco // Protecao para nao dar negativo
		nPagar		:= nDinheiro - nTroco
	Else
		nPagar		:= nDinheiro
	EndIf
EndIf


If lUsaDisplay                   
	DisplayEnv(StatDisplay(), "1C"  + Upper( STR0086 ) )         //"Confira o valor pago e"	
	DisplayEnv(StatDisplay(), "2C"  + Upper( Substr(STR0087, 1, 28 ) ))  //"PRESSIONE <ENTER>  P/ FECHAR A VENDA"
	DisplayEnv(StatDisplay(), "3C"  + Upper( Substr(STR0087, 30 ) ))  //"PRESSIONE <ENTER>  P/ FECHAR A VENDA"	
	DisplayEnv(StatDisplay(), "4E" + "|")	
EndIf  

// Troco ao Consumidor
If lTouch
	DEFINE MSDIALOG oDlgTroco FROM  47,130 TO 500,450 TITLE STR0088 PIXEL OF oDlgRapid

// Definindo o Objeto Teclado
	oKeyb   := TKeyboard():New( 130, 10, 1, oDlgTroco ) // Definindo o Objeto Teclado
	nVlrPag := nPagar + nTroco  // Valor Pago Pelo Cliente
	nValor  := nTroco // Valor do Troco

Else
	DEFINE MSDIALOG oDlgTroco FROM  47,130 TO 300,400 TITLE STR0088 PIXEL OF oDlgRapid
EndIf
           
If lTouch
	DEFINE FONT oFonte NAME "Arial" BOLD     
Else
   DEFINE FONT oFonte	NAME "TIMES NEW ROMAN" SIZE 12.5,20 Bold
EndIf   

@ 05, 04 TO 31,130 LABEL STR0089 OF oDlgTroco	PIXEL //"Valor pago pelo cliente" 
If lSoVisual  // Somente Exibe a tela
	@ 13, 07 SAY oSay PROMPT nVlrPag PICTURE PesqPict("SL1","L1_VLRTOT",,nMoedaCor)PIXEL OF oDlgTroco SIZE 120,14;
	COLOR CLR_HBLUE FONT oFonte RIGHT	
Else //Permite editar
	@ 13, 07 MSGET oPago VAR nVlrPag PICTURE PesqPict("SL1","L1_VLRTOT",,nMoedaCor) SIZE 120,14 FONT oFonte PIXEL;
	OF oDlgTroco  VALID LjxDAtuTroco(	@nVlrPag	, @nValor	, oSay	, lDinheiro	,;
										@nDinheiro	, @nVales)
EndIf

// Valor a Pagar
@ 43, 04 TO 69,130 LABEL STR0090 OF oDlgTroco PIXEL
@ 52, 07 SAY oSay_2 PROMPT nPagar PICTURE PesqPict("SL1","L1_VLRTOT",,nMoedaCor) PIXEL OF oDlgTroco SIZE 120,14;
COLOR CLR_HBLUE FONT oFonte RIGHT

// Troco ao Consumidor
@ 81, 04 TO 107,130 LABEL STR0088 OF oDlgTroco PIXEL
@ 90, 07 SAY oSay PROMPT nValor PICTURE PesqPict("SL1","L1_VLRTOT",,nMoedaCor)PIXEL OF oDlgTroco SIZE 120,14;
COLOR CLR_HRED FONT oFonte RIGHT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes para confirmacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTouch                                    
	// Definindo a Acao do teclado quando o foco for para o Troco
	// Definindo a Acao da tecla ENTER do Teclado oKeyb
	// Definindo onde o Foco deve iniciar na Dialog
	oPago:bGotFocus  := {|| If(lUsaDisplay, (DisplayEnv(StatDisplay(), "2E"+ STR0091), DisplayEnv(StatDisplay(), "1C" + Upper(STR0058))) ,),oKeyb:SetVars(oPago,TamSX3("L1_VLRTOT")[1])}  
	oKeyb:SetEnter({|| (lRet := .T.,oDlgTroco:End())})
	oKeyb:bEsc:={|| oDlgTroco:End()}
	oPago:SetFocus()	
Else
	DEFINE SBUTTON FROM 112, 65 oButton2 TYPE 1 ENABLE OF oDlgTroco ;
	ACTION (lRet := .T.,oDlgTroco:End()) PIXEL
	
	DEFINE SBUTTON FROM 112, 101 oButton1 TYPE 2 ENABLE OF oDlgTroco ;
	ACTION (lRet := .F.,oDlgTroco:End()) PIXEL	
EndIf

ACTIVATE MSDIALOG oDlgTroco CENTERED

// Instituto Arredondar
If (cPaisLoc == "BRA") .AND. lArredondar .AND. lDinheiro
	nArredondar := LjxDDoeArredondar( nVlrPag - nPagar )
EndIf

If nValor >= 0 .AND. lRet
	If ExistBlock("LJGetTrc") .AND. !lFtvdVer12
		nValor := ExecBlock("LJGetTrc",.F.,.F.,{nValor,lDinheiro})
	EndIf
	If ExistBlock("FTVDGetTrc") .AND. lFtvdVer12
		nValor := ExecBlock("FTVDGetTrc",.F.,.F.,{nValor,lDinheiro})
	EndIf
	lRet := LjEnvSup(nValor,nDinheiro)
	If nVlrPag > 0
		nPago := nVlrPag					// Carrega a Var nPago com o valor pago
	Else
		nPago := 0							// Carrega a Var nPago com o valor pago
	EndIf
	uRet := nValor
Else
	uRet := .F.
EndIf

If lUsaDisplay                   
	DisplayEnv(StatDisplay(), "1E"  + Upper( STR0089 )+ " : " + Alltrim(Str(nVlrPag,,2))  )         //"Valor pago pelo cliente : "	
	DisplayEnv(StatDisplay(), "2E"  + Upper( STR0088 )+ " : " + Alltrim(Str(nValor ,,2))  )  // Troco ao Consumidor
EndIf  
Return uRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDCalcF³ Autor ³ Vendas Clientes        ³ Data ³ 08/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Array com Parcelas de acordo com o digitado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Calcula e mostra as parcelas com fator financeiro. 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDCalcFator(	oDlgLojaJur	, aLbxFator	, oLbxFator	, lUsaAdmFin	,;
						cComboAdm	, cCondicao)
/*
Local aCoors
Local aArea   := GetArea( )
Local lRet	  := .T.
Local cCodFin := Substr( cComboAdm, 1,3 )
Static nDlgHeight
Static nVezes := 1

oDlgLojaJur:CoorsUpdate( ) 	// Atualiza as coordenadas da janela
aCoors:= GetClientRect( oDlgLojaJur:hWnd )	// Pega as coordenadas

If nVezes == 1
nDlgHeight := oDlgLojaJur:nHeight	// pega a altura da janela
Endif

nVezes ++

If lUsaAdmFin
oDlgLojaJur:nHeight := nDlgHeight + 100
oLbxFator:Enable( )
WndCenter( oDlgLojaJur:hWnd ) // Centraliza a janela

nFAtorCond := 0.36035
nTotalFat  := 100
nParceFat  := 3
nUnitFat   := 0
nParc 	  := 3
nEnt		  := 0
aParcel	  := { "   ","1121"}

//lRet := RetFator( cCodFin, @nFatorCond, cCondicao )

If lRet
aParFator := l010CalcFat(@nFatorCond,@nTotalFat,@nParceFat, @nUnitFat,;
aParcel,nParc,nEnt)
Endif
Else
oDlgLojaJur:nHeight := nDlgHeight
oLbxFator:Disable( )
WndCenter( oDlgLojaJur:hWnd ) // Centraliza a janela
Endif

RestArea( aArea )
*/
Return .T.
            


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjAtuTroco³ Autor ³ Vendas Clientes       ³ Data ³ 20/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o valor do troco ao consumidor                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjatuTroco                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - Opera‡Æo OK ou Nao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDAtuTroco(	nVlrPag 	, nValor ,	oSay	, lDinheiro	,;
						nDinheiro	, nVales	)
Local lRet	:= .T.
Local nPagar:= 0.00
Local lFtvdVer12		:= LjFTVD() 	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

If lDinheiro
	nPagar:= nDinheiro
Else
	nPagar:= nVales
EndIf

If (Val(Str(nVlrPag)) < Val(Str(nPagar))) .AND. (nVlrPag <> 0)
	Tone(3000,1)
	// Valor menor que o da compra. Informe um valor maior ou igual.
	MsgStop(STR0102, STR0002 )
	lRet := .F.
EndIf

If lRet .AND. ExistBlock("LJ220TRC") .AND. !lFtvdVer12
   lRet:=ExecBlock("Lj220TRC",.F.,.F.,{nVlrPag,nPagar,lDinheiro})
EndIf

If lRet .AND. ExistBlock("FTVD220TRC") .AND. lFtvdVer12
   lRet:=ExecBlock("FTVD220TRC",.F.,.F.,{nVlrPag,nPagar,lDinheiro})
EndIf

If lRet
	If nVlrPag == 0
		nVlrPag := nPagar
	EndIf
	nValor := nVlrPag - nPagar
	oSay:Refresh()
EndIf

If lUsaDisplay                   
	DisplayEnv(StatDisplay(), "1E"  + Upper( STR0103 + Str(nVlrPag,8,2)) )      	//"VALOR RECEBIDO: "	
	DisplayEnv(StatDisplay(), "2E"  + Upper( STR0104 + ': ' + Str(nValor,8,2)))  	//"Troco ao Consumidor"	
EndIf  

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDVerCx ³ Autor ³ Vendas Clientes       ³ Data ³ 23/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se caixa existe(tratamento multi-moeda).O portador³±±
±±³          ³do titulo(caixa) e definido pela moeda                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := LjxDVerCx (ExpN1,ExpC2,ExpC3,ExpC4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Moeda do titulo                                    ³±±
±±³          ³ ExpC2 - Codigo do Caixa logado                             ³±±
±±³          ³ ExpC3 - Codigo da agencia do Caixa                         ³±±
±±³          ³ ExpC4 - Codigo da conta do Caixa                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjxDVerCx(nMoeda,cCodigo,cAgencia,cConta)
Local cNome
Local cNReduz
Local cAlias 	:= Alias()
Local nOrd   	:= IndexOrd()
Local nRec   	:= Recno()
Local cHorario	:= ""

Default cAgencia 	:= "."
Default cConta   	:= "."

cNome   := SA6->A6_NOME
cNReduz := SA6->A6_NREDUZ

DbSelectArea("SA6")
SA6->( DbSetOrder(1) )
//Se banco nao encontrado, cria um novo caixa para a moeda do titulo
//O codigo desta caixa sera igual ao corrente com a diferenca de que
//sua agencia eh o MV_SIMB da moeda
If !SA6->( DbSeek(xFilial("SA6") + cCodigo + GetMV("MV_SIMB"+cValToChar(nMoeda))) )
	cHorario := SubStr( IIf(isBlind(),Time(),GetRmtTime()), 1, 5 )
	
	Reclock( "SA6", .T. )
	Replace A6_FILIAL  with xFilial("SA6")
	Replace A6_COD 	  with cCodigo
	Replace A6_AGENCIA with GetMV("MV_SIMB"+cValToChar(nMoeda))
	Replace A6_NUMCON  with cConta
	Replace A6_NOME	   with cNome
	Replace A6_NREDUZ  with cNReduz
	Replace A6_MOEDA   with nMoeda
	Replace A6_DATAABR With dDatabase
	Replace A6_HORAABR With cHorario 
	Replace A6_DATAFCH With CtoD("  /  /  ")
	Replace A6_HORAFCH With "  :  "
	MsUnlock()
EndIf

DbSelectArea(cAlias)
DbSetOrder(nOrd)
DbGoto(nRec)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ljxDProd  ³ Autor ³ Vendas Clientes       ³ Data ³ 13.11.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta ao Produto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ljxDProd(cProduto,cLocal)
Local oEstoque
Local nPreco	:= 0

If Empty( cProduto )
	Return .T.
EndIf

DbSelectArea( "SB1" )
DbSeek( xFilial() + cProduto )

DbSelectArea( "SB2" )
DbSeek( xFilial() + cProduto + cLocal )

DbSelectArea( "SB0" )
DbSeek( xFilial() + cProduto )

DbSelectArea( "SB9" )
DbSeek( xFilial() + cProduto + cLocal )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oEstoque FROM 10, 16 TO 29, 73.5 TITLE STR0092;  // Consulta Estoque
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja

//ÚÄÄÄÄÄÄÄÄ¿
//³ Dados  ³
//ÀÄÄÄÄÄÄÄÄÙ
@ 11, 2 TO	43, 187 OF oEstoque PIXEL
@ 53, 2 TO	70, 187 OF oEstoque PIXEL
@ 78, 2 TO 135, 187 OF oEstoque PIXEL

@ 4,    2 SAY STR0093 SIZE	80, 7 OF oEstoque PIXEL  // Dados do Produto:
@ 16,   4 SAY STR0094 SIZE	21, 7 OF oEstoque PIXEL  // C¢digo
@ 15,  26 MSGET SB1->B1_COD      SIZE	49, 9 OF oEstoque PIXEL When .F.
@ 16,  83 SAY STR0095 SIZE	25, 7 OF oEstoque PIXEL  // Unidade
@ 15, 110 MSGET SB1->B1_UM       SIZE	14, 9 OF oEstoque PIXEL When .F.
@ 16, 137 SAY STR0096 SIZE	18, 7 OF oEstoque PIXEL  // Grupo
@ 15, 158 MSGET SB1->B1_GRUPO    SIZE	14, 9 OF oEstoque PIXEL When .F.
@ 30,   4 SAY STR0097 SIZE	35, 7 OF oEstoque PIXEL // Descri‡Æo
@ 29,  40 MSGET SB1->B1_DESC     SIZE  130, 9 OF oEstoque PIXEL When .F.
@ 40, 335 TO 40, 335 OF oEstoque PIXEL
@ 46,   3 SAY STR0098 SIZE	28, 7 OF oEstoque PIXEL // Estoque:

//ÚÄÄÄÄÄÄÄÄ¿
//³ Saldo  ³
//ÀÄÄÄÄÄÄÄÄÙ

@ 57,   4 SAY STR0099 SIZE 21, 7 OF oEstoque PIXEL  // Inicial
@ 56,  25 MSGET SB9->B9_QINI Picture PesqPict("SB9","B9_QINI") SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 57,  82 SAY STR0100 SIZE 21, 7 OF oEstoque PIXEL  // Atual
@ 56, 107 MSGET SaldoSB2() Picture PesqPict("SB2","B2_QATU") SIZE 49, 9 OF oEstoque PIXEL When .F.

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³ Precos	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÙ

@ 71,  3 SAY STR0101 SIZE 53, 7 OF oEstoque PIXEL // Pre‡os de Venda:
@ 82,  6 SAY "1 -"   SIZE 11, 7 OF oEstoque PIXEL

If SuperGetMv("MV_LJCNVDA",,.F.)
	LjxeValPre(@nPreco, cProduto, M->LM_CLIENTE, M->LM_LOJA)
	@ 82,  18 MSGET nPreco Picture PesqPict("SB0","B0_PRV1",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
Else
	@ 93,  6 SAY "2 -"   SIZE 11, 7 OF oEstoque PIXEL
	@ 103, 6 SAY "3 -"   SIZE 11, 7 OF oEstoque PIXEL
	@ 122, 6 SAY "5 -"   SIZE 11, 7 OF oEstoque PIXEL
	@ 83, 93 SAY "6 -"   SIZE 11, 7 OF oEstoque PIXEL
	@ 103,93 SAY "8 -"   SIZE 11, 7 OF oEstoque PIXEL
	@ 93, 93 SAY "7 -"   SIZE 11, 7 OF oEstoque PIXEL
	@ 112,93 SAY "9 -"   SIZE 11, 7 OF oEstoque PIXEL
	@ 112, 6 SAY "4 -"   SIZE 11, 7 OF oEstoque PIXEL
	
	@ 82,  18 MSGET SB0->B0_PRV1 Picture PesqPict("SB0","B0_PRV1",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 91,  18 MSGET SB0->B0_PRV2 Picture PesqPict("SB0","B0_PRV2",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 101, 18 MSGET SB0->B0_PRV3 Picture PesqPict("SB0","B0_PRV3",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 111, 18 MSGET SB0->B0_PRV4 Picture PesqPict("SB0","B0_PRV4",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 121, 18 MSGET SB0->B0_PRV5 Picture PesqPict("SB0","B0_PRV5",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 82, 106 MSGET SB0->B0_PRV6 Picture PesqPict("SB0","B0_PRV6",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 91, 106 MSGET SB0->B0_PRV7 Picture PesqPict("SB0","B0_PRV7",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 101,106 MSGET SB0->B0_PRV8 Picture PesqPict("SB0","B0_PRV8",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
	@ 111,106 MSGET SB0->B0_PRV9 Picture PesqPict("SB0","B0_PRV9",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
EndIf                  

DEFINE SBUTTON FROM 010,192 TYPE 1 ACTION oEstoque:End() ENABLE OF oEstoque

ACTIVATE MSDIALOG oEstoque

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ljxDIcms  ³ Autor ³ Vendas Clientes       ³ Data ³ 09/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Verifica‡„o da Porcentagem de ICM                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Sigaloja                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³21/07/06  ³103030³Cleber M³Implementacao do calculo do ICMS Diferido.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljxDIcms( nEl,		nDif,		nBase,	cOrigem,;
				   nVlrIpi,	aDespFrete	)
Local nI										//Usada em lacos For...Next
Local aArea 		:= GetArea()				//Guarda a area atual
Local nPosTes		:= aPosicoes[5][2]			//Posicao do campo TES
Local nPosTotal		:= aPosicoes[2][2]			//Posicao do campo Total
Local nPosBsIcms	:= aPosicoes[12][2]			//Posicao do campo Base Icms
Local nPosValIpi	:= aPosicoes[7][2]			//Posicao do campo Valor IPI
Local nPosProd   	:= aPosicoes[9][2]			//Posicao do campo Produto
Local nPosValFre	:= aScan( aHeader, { |x| Alltrim(Upper(x[2]))=="L2_VALFRE" } )		//Posicao do campo Frete
Local nPosSeguro 	:= aScan( aHeader, { |x| Alltrim(Upper(x[2]))=="L2_SEGURO" } )		//Posicao do campo Seguro
Local nPosDespesa	:= aScan( aHeader, { |x| Alltrim(Upper(x[2]))=="L2_DESPESA" } )	//Posicao do campo Despesa
Local nValIcms 		:= 0						//Valor final do Icms
Local nElemFiscal 	:= 0						//Indica se encontrou o elemento fiscal
Local nPerRet									//Percentual de Icms
Local nGrade	  	:= Ascan(aCampos,"L2_GRADE")//Posicao do campo Grade
Local cGrade                                    //Conteudo do campo Grade no aCols
Local nValDiferido	:= 0						//Valor do Diferimento de ICMS

Default nEl         	:= n
Default nDif        	:= 0
Default cOrigem     	:= ""
Default aDespFrete  	:= {}

If cPaisLoc <> "BRA"
	Return( 0.00 )
EndIf

SF4->(DbSeek(xFilial("SF4")+aCols[nEl][nPosTes]))

If !__lPyme
	cGrade	:= aCols[nEl][nGrade]
EndIf

DbSelectArea( "SB0" )
DbSeek( cFilial+aCols[nEl][nPosProd])
If nBase == NIl
	DbSelectArea( "SF4" )
	DbSeek( cFilial+aCols[nEl][nPosTes])
	
	// Faz esse controle para quando carregar um orcamento na "Finaliza Venda"
	If nPosValFre > 0 .AND. nPosSeguro > 0 .AND. nPosDespesa > 0 .AND. ;
		aCols[nEl][nPosValFre] <> Nil .AND. aCols[nEl][nPosSeguro] <> Nil .AND. aCols[nEl][nPosDespesa] <> Nil .AND. ;
		( lVlrFSD )

		nBase := aCols[nEl][nPosTotal] + aCols[nEl][nPosValFre] + aCols[nEl][nPosSeguro] + aCols[nEl][nPosDespesa]

	ElseIf !Empty( aDespFrete ) .AND. ( lVlrFSD )

		nBase := aCols[nEl][nPosTotal] + aDespFrete[nEl][1] + aDespFrete[nEl][2] + aDespFrete[nEl][3]

	Else

		nBase := aCols[nEl][nPosTotal]

	EndIf
	
	If SF4->F4_INCIDE == "S"
		nBase += Iif(nPosValIpi >0,aCOLS[nEl][nPosValIpi],0)
	EndIf
	nBase *= Iif(SF4->F4_BASEICM>0,SF4->F4_BASEICM/100,1)
	aCOLS[nEl][nPosBsIcms] := nBase
	nPerRet := LjxDVerIcm( nEl )
ElseIf Upper(cOrigem) == "CONDPAG"
	If SF4->F4_INCIDE == "S"
		nBase += nVlrIpi
	EndIf
	nBase *= Iif(SF4->F4_BASEICM>0,SF4->F4_BASEICM/100,1)
	nPerRet := LjxDVerIcm( nEl,nBase,SF4->F4_CODIGO )
Else
	nBase *= Iif(SF4->F4_BASEICM>0,SF4->F4_BASEICM/100,1)
	nPerRet := LjxDVerIcm( nEl,nBase,SF4->F4_CODIGO )
EndIf

If lFiscal
	// Verifica se a aliquota esta no array aIcms previamente carregado
	// com as aliquotas de Icms
	For nI := 1 to Len(aIcms)
		If nPerRet = aIcms[nI][1]
			nElemFiscal := 1
			Exit
		EndIf
	Next nI
	If cGrade <> "S"
		If SB0->B0_ALIQRED > 0	  //Aliquota de Reducao de Icms
			nElemFiscal := 0
			For nI := 1 to Len(aIcms)
				If SB0->B0_ALIQRED = aIcms[nI][1]
					nElemFiscal := 1
					Exit
				EndIf
			Next nI
		EndIf
	EndIf
	If nElemFiscal == 0 .AND. SF4->F4_ICM == "S"
		
		// A al¡quota de Icms utilizada neste produto n„o est 
		// cadastrada na Impressora fiscal. utilize a op‡„o adiciona Aliquota
		// no menu Miscelƒnea, M¢dulo fiscal, para cadastr -la na Impressora.
		// a al¡quota n„o cadastrada ‚ :
		// Aten‡„o
		
		MsgStop(STR0105	+;
				STR0106	+;
				STR0107 +;
				STR0108 + Transform(If(SB0->B0_ALIQRED>0,SB0->B0_ALIQRED,nPerRet),"@E 99.99") + "%",;
				STR0109 )
		nPerRet := 0
	EndIf
EndIf
If SF4->F4_ICM <> "S" .AND. SF4->F4_ISS <> "S"
	nBase := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a Base do ICMS com o valor correto ou com zero, conforme condicoes acima. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nEl ] [nPosBsIcms ] := nBase

If nPerRet > 0
	nValIcms := NoRound(nBase * nPerRet / 100,2,@nDif)
	If Abs(nDif) >= 0.01
		nValIcms += NoRound(nDif)
		nDif		-= NoRound(nDif)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula ICMS Diferido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_ICMSDIF == "3" .AND. SF4->F4_PICMDIF > 0
		nValDiferido := NoRound(nValIcms * SF4->F4_PICMDIF / 100,2,@nDif)
		nValIcms 	 := nValIcms - nValDiferido
		If Abs(nDif) >= 0.01
			nValIcms += NoRound(nDif)
			nDif -= NoRound(nDif)
		EndIf
	EndIf
	
Else
	nValIcms := 0
EndIf

RestArea( aArea )

Return nValIcms           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDVerIcm³ Autor ³ Vendas Clientes       ³ Data ³ 09/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Verifica‡„o da Porcentagem de ICM                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Sigaloja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDVerIcm( nEl,	nBase,	cTes,	cProduto )
Local nPerRet      	:= 0						// Percentual de retorno
Local nPosProd     	:= aPosicoes[9][2]
Local nPosTes      	:= aPosicoes[5][2]
Local cAlias       	:= Alias( )
Local nRecnoA1     	:= 0

//ÚÄÄÄÄÄÄÄ¿
//| Grade |
//ÀÄÄÄÄÄÄÄÙ
Local nGrade
Local cGrade

Default cTes 			:= SL2->L2_TES
Default cProduto 		:= SL2->L2_PRODUTO

If cAlias == "SD1" .OR. __lPyme
	nGrade := 0
Else
	nGrade := AScan(aCampos,"L2_GRADE")
EndIf
If nGrade <> 0
	cGrade := aCols[n][nGrade]
Else
	cGrade := ""
EndIf
If cPaisLoc <> "BRA"
	Return( 0 )
Endif
If nEl == Nil
	nE1 := n
EndIf
If nBase == NIl
	If cGrade == "S"
		SB4->(DbSeek(xFilial("SB4")+aCols[nEl][nPosProd]))
	Else
		SB1->(DbSeek(xFilial("SB1")+aCols[nEl][nPosProd]))
	Endif
	DbSelectArea( "SF4" )
	DbSeek( cFilial+aCols[nEl][nPosTes])
	DbSelectArea( cAlias )
Else
	If cGrade == "S"
		SB4->(DbSeek(xFilial("SB4") + cProduto ))
	Else
		SB1->(DbSeek(xFilial("SB1") + cProduto ))
	Endif
	DbSelectArea( "SF4" )
	DbSeek( cFilial + cTes )
	DbSelectArea( cAlias )
Endif

If !Empty( cCliEntrega ) .AND. !Empty( cLojEntrega )
	nRecnoA1 := SA1->( RecNo() )
	SA1->( DbSetOrder( 1 ) )
	SA1->( DbSeek( xFilial( "SA1" ) + cCliEntrega + cLojEntrega ) )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso Calcule Icms  Chama a Fun‡„o do FISXFUN.PRX para retornar ³
//³ a Aliquota correta para c lculo do Icms                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SF4->F4_ICM == "S"
	nPerRet := AliqIcms("N","S",SA1->A1_TIPO,"I")
Endif

If !Empty( cCliEntrega ) .AND. !Empty( cLojEntrega )
	SA1->( DbGoto( nRecnoA1 ) )
Endif

Return(nPerRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDNota  ³ Autor ³ Vendas Clientes       ³ Data ³ 11.02.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Achoice para numero e serie da nota fiscal                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡Æo³ Incluido o controle de TTS solicitado pelo Wilson 14/01/98 ³±±
±±³          ³ para tratamento do SQL. (Aline)                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDNota(	cMvSerie	, nCheck		, lImpCupFis	, nQtdNotas		,;
					aNotas		, cNumFiscal	, lCriaSerie	, nItensVenda	,;
     				nMaxItens	, lTicket		, cDocSerie		, lVendaCup		,;
     				nTamDoc 	, lDavPre		, cDocFo		, cParamSeri 	,;
     				cNumOrc	)

Local aArea 	:= GetArea()
Local aSerNf	:= {}
Local oDlgLojaNota
Local lTudo 	:= .T.
Local nContErr 	:= 0
Local oQual
Local cVarQ 	:= "  "
Local nOpcA 	:= 0
Local lRetorno  := .F.
Local aRecnos	:= {}
Local cFiltSer  :=      ""
Local oTimer
Local nTimeout	:=	SuperGetMV("MV_NOTAOUT")
Local lTimeOut	:=	.F.
Local lLojaNum  := SuperGetMV("MV_LOJANUM")
Local nI, nX    := 0
Local cProg     := AllTrim(FunName())
Local lLimMax   := .F.
Local lQtdeNotas:= ValType(nItensVenda)=="N"
Local cTipoDoc  := ""
Local cSerAtu   := ""
Local nRegSX5   := 0
Local nTamSerie := TamSx3("L1_SERIE")[1]	// Tamanho do campo L1_SERIE - melhorar performance
Local cMV_TPNRNFS	:= LjTpNrNFS()	 		// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local cFilSx5		:= If(ExistFunc("LjFilSX5"),LjFilSX5(),xFilial("SX5")) // Retorna Filial SX5
Local lContrFol		:= .F.					// Controle de Folios 
Local lLJXNUMDOC 	:= ExistBlock("LJXNUMDOC")	//Controla se o ponto de entrada LJXNUMDOC existe (Loc. PAR)
Local lSelNumPadrao := .T.                    	//Controla se a selecao do numero do documento e pela forma padrao(.T.) ou pelo PE LJXNUMDOC  
Local xRet		 								//Retorno do PE LJXNUMDOC
Local lMVLjNfSXE   	:= SuperGetMV("MV_LJNFSXE") //Define se ativa a codificacao do numero da nota pelo SX5 (default) = .F. ou SXE\SXF = .T.
//³Release 11.5 - Controle de Formularios ³
//³Localizacoes: Chile,Colombia  - F1CHI  ³
Local lCFolLocR5:= 	SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
                    cPaisLoc$"CHI|COL" .AND.;                                                                       
                    !lFiscal

Local lFtvdVer12	:= LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cNomeProg		:= Iif(lFtvdVer12,"FATA701","LOJA701") //Nome da Rotina
Local aAreaSL1 		:= SL1->(GetArea())
Local lAtuDocSL1	:= .F. //Indica se atualiza o campo L1_DOC logo apos pegar o nmumero de DOC a ser utilizado
Local lEmitNfce		:= LjEmitNFCe()	// Sinaliza se utiliza NFC-e
Local lUseSAT 		:= LjUseSat()

Default nTamDoc		:= TamSx3("L1_DOC")[1]		// Tamanho do campo L1_DOC - melhorar performance
Default lTicket    	:= .F.
Default lVendaCup	:= .T.
Default lDavPre		:= .F.							// Informa se foi chamada de uma Pre Venda ou Dav                             
Default cNumFiscal  := Space( TamSX3("L1_DOC")[1] )
Default lCriaSerie  := .F.
DEFAULT cDocFo		:= ""						//Numero de Nota definida pelo usuário no inicio da venda - Release 11.5 - Chile - F1CHI 
DEFAULT cParamSeri  := "" 						//Nome do parametro relacionado a serie que foi configurada
Default cNumOrc	 	:= ""

If lFiltSer == Nil
	If !lFtvdVer12
		lFiltSer	:=	ExistBlock("LJ010FILT")
	ElseIf lFtvdVer12
		lFiltSer	:=	ExistBlock("FTVD010FILT")
	EndIf	
Endif

lContrFol	:= 	!IsInCallStack("LJ7PREPORC") .AND. SF1->(FieldPos("F1_NUMAUT")) > 0 .And.;
				SF1->(FieldPos("F1_CODCTR")) > 0 .And.	SF2->(FieldPos("F2_NUMAUT")) > 0 .And.;
				SF2->(FieldPos("F2_CODCTR")) > 0 .And. SF2->(FieldPos("F2_LIMEMIS")) > 0 .And.;
				SF3->(FieldPos("F3_NUMAUT")) > 0 .And. SF3->(FieldPos("F3_CODCTR")) > 0 .And.;
				GetNewPar("MV_CTRLFOL",.F.)

cNumNota  := IIf(Type("cNumNota")#"U",cNumNota,cNumFiscal)

If lEmitNFCe .And. !lUseSAT .And. nModulo == 12 .And. !Empty(cNumOrc)
	SL1->(DbSetOrder(1)) //L1_FILIAL+L1_NUM
	If SL1->(MsSeek(xFilial("SL1")+cNumOrc))
		lAtuDocSL1 := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for impr. fiscal utiliza o parametro MV_FISNOTA para verificar se per-³
//³ gunta ou nao se imprime Cupom Fiscal									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal .AND. nCheck == 1
	lImpCupFis := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para DAV e PRE exclusivo por filial							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDavPre	
	cFilSx5 := LjAjusFiX5(cFilSx5, cMvSerie) // Exclusivo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o tratamento de pegar o numero da nota fiscal via semaforo ou via    ³
//³ SX5 (tabela 1)                                                           ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Foi feito dessa forma devido as alteracoes feitas para o cliente Cepar   ³
//³ de Joinville e para nao alterar o que ja temos em campo ja que estamos   ³
//³ terminando o desenvolvimento da versao 7.10                              ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Foi incluido o tratamento do parametro MV_TPNRNFS para fazer o controle  ³
//³ da numeracao da NF por SD9                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMVLjNfSXE .AND. !lDavPre 
	
	// Se a serie estiver em branco abre a tela para a escolha do usuario
	If Empty(cMvSerie)
		If !Sx5NumNota(,SuperGetMv("MV_LJNRNFS",.F.,cMV_TPNRNFS))

			// Volta o padrão da variavel, pois o SX5NUMNOTA ao ser cancelado colocar NIL na variavel
			// cSerie.
			cSerie 		:= Space(nTamSerie)
			lVendaCup   := .F.
			Return .F.

		Endif
		cMvSerie := cSerie
	ElseIf Type("cSerie") == "U"
		cSerie := cMvSerie		// Caso esteja nula recebe o conteudo do parametro	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o MV_TPNRNFS for igual a "3" nao pega o numero da NF aqui e deixa  ³
	//³ para fazer o controle do numero dentro da transacao pelo SD9          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(nModulo == 12  .AND. cMV_TPNRNFS == "3") 
		//Quebra de Notas
		For nX := 1 to nQtdNotas                  
			If cMV_TPNRNFS == "3" .And. nModulo == 5
				cNumNota := MA461NumNf( .T., cSerie )
	    	Else		
				cNumNota := NxtSX5Nota( cMvSerie,, SuperGetMV("MV_LJNRNFS",.F.,"2"))
	        Endif
	        				
            cNumNota := PadR( cNumNota , nTamDoc )           							// --> Incluso  LAVOR  (Tratamento tamanho Nota Fiscal)
			If LjValNota(cSerie,cNumNota) // Validar as Bases
				cNumNota := PadR( cNumNota, nTamDoc )       							// --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
				aAdd(aNotas,{cMvSerie,cNumNota})
			EndIf
		Next nX 
	Elseif lFtvdVer12 .AND. IsInCallStack("Lj7ImpCNF") .And. cMV_TPNRNFS == "3" 
			aAdd( aNotas, { cSerie,  MA461NumNf( .T., cSerie ) } )	 
	Else
		For nX := 1 to nQtdNotas 
            cNumNota := PadR( MA461NumNf( .T., cMvSerie ) , nTamDoc )           							// --> Incluso  LAVOR  (Tratamento tamanho Nota Fiscal)
			aAdd(aNotas,{cMvSerie,cNumNota})
		Next nX
	Endif
	
	If lMVLjNfSXE .AND. cMV_TPNRNFS == "2"  // Confirma o numero sugerido pelo semaforo. 
		While __lSx8   
			ConfirmSx8()
		EndDo
	EndIf
	
	// Controle de Folios
	If lContrFol
		lRetorno := ChkFolURU(	cFilAnt	, cSerie	, cNumNota, 	Nil,;
								.F.		, Nil		 )
	Else
		lRetorno := .T.
	EndIf
	
ElseIf cPaisLoc == "BRA" .OR. !SuperGetMV("MV_SEQESPE",,.F.)	
	
	If Type("cSerie") == "U"
		cSerie := cMvSerie		// Caso esteja nula recebe o conteudo do parametro	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para Decreto 8345 - Localizacao Paraguai			  ³
	//³ IMPORTANTE: Nao habilitar para outros paises 						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If cPaisLoc == "PAR" .AND. lLJXNUMDOC
	    xRet  := ExecBlock("LJXNUMDOC",.F.,.F., {cMvSerie})
	    If ValType(xRet) == "A" .AND. Len(xRet) > 0 .AND. Len(xRet[1]) == 2   
	       aNotas  := AClone(xRet)
	       
		   cSerie 	:= aNotas[1,1]
		   cNumNota := aNotas[1,2]
			
		   lRetorno := LjValNota(cSerie,cNumNota)	   	       
		   
		   lSelNumPadrao  := .F.
	    Else
	       lSelNumPadrao  := .T.
	    EndIf
	EndIf
	
	If lSelNumPadrao	
		If Empty(cMvSerie)
			If lFiltSer
				If !lFtvdVer12
					cFiltSer :=	ExecBlock("LJ010FILT",.F.,.F.)
				ElseIf lFtvdVer12	
					cFiltSer :=	ExecBlock("FTVD010FILT",.F.,.F.)
				EndIf
			Endif  
			
			While .T.
				DbSelectArea("SX5")
				DbSeek( cFilSx5+"01" )
				aSerNf	:= {}
				lTudo := .T.
				While cFilSx5+"01" == X5_FILIAL+X5_TABELA
					If !Empty(cFiltSer) .AND. !(Alltrim(X5_CHAVE) $ cFiltSer)
						dbSkip()
						Loop
					Endif
					IF !MSRLock() .OR. SubStr(X5Descri(),1,1) = "*"
						lTudo := .F.
						Exit
					Endif
					
					Aadd(aRecnos,Recno())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se a S‚rie for CPF, n„o mostra no aChoice, pois ‚ utilizada ³
					//³ internamente para emissao de Cupom Fiscal.					³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Alltrim(SX5->X5_TABELA) == "01" .AND. Alltrim(SX5->X5_CHAVE) == "CPF"
						dbSkip()
						Loop
					ElseIf nCheck == 2 .AND. Alltrim(SX5->X5_TABELA) == "01" .AND. Alltrim(SX5->X5_CHAVE) == "CP"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso seja Nota fiscal n„o exibe a s‚rie CP ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSkip()
						Loop
					EndIf
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso seja Nota fiscal n„o exibe a s‚rie CP ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nCheck == 3 .AND. Alltrim(SX5->X5_TABELA) == "01" .AND. Alltrim(SX5->X5_CHAVE) == "CP"
						aSerNF := {}
						Aadd(aSerNF,{Padr(X5_CHAVE,nTamSerie),Trim(X5Descri())})
						Exit
					EndIf
					
					Aadd(aSerNF,{Padr(X5_CHAVE,nTamSerie),Trim(X5Descri())})
					dbSkip()
				End
			
				If !lTudo
					nContErr ++
					If nContErr > 10
						DbSeek( cFilSx5+"01" )
						While cFilSx5+"01" == X5_FILIAL+X5_TABELA
							MsUnLock()
							dbSkip()
						End
						Help(" ",1,"NOTAPRESA")
						nCOntErr := 0
					EndIf
					Inkey(1)
					Loop
				EndIf
				Exit
			End
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trata s‚rie e numero da nota fiscal  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// S‚rie/NF
			If cPaisLoc == "BRA"
				DEFINE MSDIALOG oDlgLojaNota TITLE STR0110 From 10,30 To 19.7,68;
				STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDEFAULT()
				// S‚rie / N£mero /
				@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER STR0111,;
				STR0112 SIZE 130,42 NOSCROLL
				If lLojaNum
					oQual:bLDblClick := {|| aSerNF:=LjxDx5Troca(oQual:nAt,@aSerNF),oQual:Refresh() }
				EndIf
				oQual:SetArray(aSerNF)
				oQual:bLine := { || {aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2]}}
				DEFINE SBUTTON FROM 51,78 TYPE 1 ACTION (lRetorno := LjValNota(aSerNf[oQual:nAt,1],aSerNf[oQual:nAt,2]),nOpca := 1,;
				Iif(iif(lRetorno,ljxDANf(oQual,aSernf),Iif(SuperGetMV("MV_LJSGNUM"),LjxDSugNum(@aSerNF,oQual:nAt,oQual),.F.)),;
				oDlgLojaNota:End(),nOpca:=0)) ENABLE OF oDlgLojaNota
				DEFINE SBUTTON FROM 51,107 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota
				ACTIVATE MSDIALOG oDlgLojaNota CENTERED
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cancelada a escolha da Serie³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lRetorno
					lVendaCup := .F.
				EndIf
			Else
				If !Empty(cFiltSer)
					SX5->(DbSetFilter({|| Trim(X5_CHAVE)$cFiltSer },"Trim(X5_CHAVE)$'"+cFiltSer+"'"))
				Endif
				DEFINE MSDIALOG oDlgLojaNota TITLE STR0113 From 10,30 To 17,58; // Numeracao N.Fiscal
				STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF If(cProg == cNomeProg ,oDlgVA,oDlgLojaNota)
				
				DEFINE TIMER oTimer INTERVAL nTimeOut*1000 ACTION (lTimeOut:=.T.,oTimer:End(),oDlgLojaNota:End())  OF oDlgLojaNota
				@ 1, 2 TO 30, 108 OF oDlgLojaNota PIXEL
				
				@ 7, 5 SAY STR0114 SIZE 22, 7 OF oDlgLojaNota PIXEL //N.Fiscal
			
				@ 6, 25 MSGET cSerie  PICTURE "!!!";
				VALID IIf(lTimeout,.T.,LjxDVlSer(cSerie,@cNumNota)) F3 "01";
				SIZE 15, 10 OF oDlgLojaNota PIXEL
			
				@ 6, 55 MSGET oNFClie VAR cNumNota PICTURE PesqPict("SF2","F2_DOC");
				VALID LjxDZera(@cNumNota) ;
				SIZE 47, 10 OF oDlgLojaNota PIXEL
			
				DEFINE SBUTTON FROM 31,42 TYPE 1 ACTION If(LjxDNFisca(@cNumNota,,,@cSerie).AND. LjValNota(cSerie,cNumNota),;
				(lRetorno := .T.,nOpca := 1, oDlgLojaNota:End()),;
				nOpca:=0);
				ENABLE OF oDlgLojaNota
				DEFINE SBUTTON FROM 31,73 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota
			
				ACTIVATE TIMER oTimer
				ACTIVATE MSDIALOG oDlgLojaNota CENTERED
				If !Empty(cFiltSer)
					SX5->(DbClearFilter())
				Endif
			EndIf
			If lRetorno .AND. ExistBlock("LJ010SNF") .AND. !lFtvdVer12
				lRetorno := ExecBlock("LJ010SNF",.F.,.F.)
			EndIf
		
			If lRetorno .AND. ExistBlock("FVD10SNF") .AND. lFtvdVer12
				lRetorno := ExecBlock("FVD10SNF",.F.,.F.)
			EndIf
			
		Else
			If lCFolLocR5 .AND. !Empty(cDocFo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Release 11.5 - Controle de Formularios ³
				//³Se o numero da nota foi definida		  ³
				//³pelo usuario no inicio da venda 		  ³
				//³via controle de formularios .   		  ³
				//³Paises:Chile/Colombia  - F1CHI 		  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumNota:=cDocFo
			Else
				DbSelectArea("SX5")
				DbSeek(cFilSx5+"01"+cMVSerie)
				IF Eof()					
					If !Empty(cParamSeri)
						Help( " ", 1, "Help",, STR0272 + cParamSeri + STR0273, 1, 0 ) //"Ocorreu um erro ao recuperar a série da Nota Fiscal na Tabela 01 do SX5, verificar o parâmetro da série (" ### "). Informe esta ocorrencia ao Administrador do Sistema."
						ConOut(STR0272 + cParamSeri + STR0273) //"Ocorreu um erro ao recuperar a série da Nota Fiscal na Tabela 01 do SX5, verificar o parâmetro da série (" ### "). Informe esta ocorrencia ao Administrador do Sistema."
					Else
						Help(" ",1,"ERROSERIE")
						Help( " ", 1, "Help",, STR0274 + cMVSerie + STR0275, 1, 0 ) //"Serie [" ### "] inexistente na Tabela 01 do SX5. Informe esta ocorrencia ao Administrador do Sistema."
						ConOut(STR0274 + cMVSerie + STR0275) //"Serie [" ### "] inexistente na Tabela 01 do SX5. Informe esta ocorrencia ao Administrador do Sistema."
					EndIf
					
					Return .F.
				EndIf

				While !MsrLock()
					InKey(1)
					nContErr++
					IF nContErr > 10
						Help(" ",1,"NOTAPRESA")
						nCOntErr := 0
					End
				End
				aAdd(aRecnos,Recno())
				
				// -- Remover proteção no futuro
				If __FWLibVersion() >= "20190820"
					cNumNota := Substr(X5Descri(,,,.F.,.F.),1,nTamDoc)
				Else
					cNumNota := Substr(X5Descri(),1,nTamDoc)
				EndIf 
			EndIf			
			cSerie := cMvSerie
			lRetorno := LjValNota(cSerie,cNumNota,lDavPre)
		EndIf
	EndIf
	//Caso o numero maximo de itens seja determinado pelo parametro MV_SER+<serie>
	//calcular novamente a quantidade de notas a serem emitidas apos a selecao da serie
	//do documento
	If cPaisLoc <> "BRA" .AND. lRetorno .AND. lQtdeNotas
	   nMaxItens := LjGetMaxIt(cSerie) 
	   If nItensVenda > nMaxItens
	      nQtdNotas := Int(nItensVenda/nMaxItens) + Iif(Mod(nItensVenda,nMaxItens)>0,1,0)
	   Else
	      nQtdNotas := 1
	   Endif					   
	   //A impressao de ticket nao tem limitacao de itens - Loc. Guatemala	   
	   If lTicket 
	      nMaxItens := 999
	      nQtdNotas := 1  	      
	   EndIf	   
	EndIf
	
	nX := 1
	While nX <= nQtdNotas
		aAdd(aNotas,{cSerie,cNumNota})
		If nX < nQtdNotas
            cNumNota := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )         // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
		Endif
		nX ++
	End
	
	//Acertando o numero da nota no Sx5
	DbSelectArea("SX5")
	
	// Controle de Folios
	If lRetorno .AND. lContrFol 
		lRetorno := ChkFolURU(	cFilAnt	, cSerie	, cNumNota, 	Nil,;
								.F.		, Nil	)
	EndIf
	
	IF lRetorno
		DbSeek( cFilSx5+"01"+cSerie )
		If cPaisLoc == "SAL"
		   //Verifica se atingiu numeracao maxima
		   lLimMax  := AllTrim(X5Descri()) == Repl("9",nTamDoc)
		   nRegSX5  := Recno()
		EndIf		
		RecLock("SX5")
        SX5->X5_DESCRI  := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )      // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)   
		SX5->X5_DESCSPA := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )      // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
		SX5->X5_DESCENG := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )      // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
		MsUnlock()
		
		If lAtuDocSL1
			//Persiste o DOC na SL1 para garantir a integridade
			RecLock("SL1", .F.)
			Replace SL1->L1_DOC with cNumNota
			Replace SL1->L1_SERIE with cMVSerie
			Replace SL1->L1_SITUA with "T2" //T2=Consumiu numero de Doc e Serie e atualizou os campos L1_DOC e L1_SERIE
			SL1->( MsUnlock() )
		EndIf

		DbSelectArea("SX5")
		SX5->( MsUnlock() )

	Else
		//Caso utilize DAV, e a numeração do DAV  já exista na SL1,
		//procura pelo próximo número
		If lDavPre					
			If LjNextNumNt(cSerie,@cNumNota,nTamDoc)
			
				For nX := 1 To Len(aNotas)
					If (nX > 1)
						cNumNota := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )
					EndIf				
					aNotas[ nX, 02 ] := cNumNota					            
				Next
				
				SX5->(DbSeek( cFilSx5+"01"+cSerie ))
				If cPaisLoc == "SAL"
				   //Verifica se atingiu numeracao maxima
				   lLimMax  := AllTrim(X5Descri()) == Repl("9",nTamDoc)
				   nRegSX5  := Recno()
				EndIf		
				RecLock("SX5")
		        SX5->X5_DESCRI  := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )      // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)   
				SX5->X5_DESCSPA := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )      // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
				SX5->X5_DESCENG := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )      // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
				SX5->(MsUnlock())
			
			EndIf
		EndIf
	Endif
	
	//Liberando registros locados
	For nI := 1 to Len(aRecnos)
		dbGoto(aRecnos[nI])
		MsUnLock()
	Next nI
	
	If cPaisLoc == "SAL" .AND. lLimMax
	   //Tipo do documento: 0=Credito Fiscal;1=Fatura;2=Nota de Remissao		      
	   DbGoto(nRegSX5)
	   cTipoDoc := Substr(SX5->X5_CHAVE,1,1)		      
	   cSerAtu  := Substr(SX5->X5_CHAVE,2,2)		      		      
	   lCriaSerie  := LjCriaSerie(cSerAtu,cTipoDoc)	
	EndIf	
//Controle da numeracao por especie de documento. Cada tipo de documento(NF, NCC, NDC, etc.)
//tera uma numeracao independente mesmo que utilizem a mesma serie
Else
	If Empty(cMvSerie)
		If lFiltSer
			If !lFtvdVer12
				cFiltSer :=	ExecBlock("LJ010FILT",.F.,.F.)
			ElseIf lFtvdVer12
				cFiltSer :=	ExecBlock("FTVD010FILT",.F.,.F.)
			EndIf	
		Endif  
		If !lNFManual		
		   While .T.
			  DbSelectArea("SX5")
			  DbSeek( xFilial("SX5")+"AC"+"NF " )
			  aSerNf	:= {}
			  lTudo   := .T.
			  While xFilial("SX5")+"AC" == X5_FILIAL+X5_TABELA			
				 If !Empty(cFiltSer) .AND. !(Alltrim(X5_CHAVE) $ cFiltSer)
					dbSkip()
					Loop
				 EndIf
				 If Substr(X5_CHAVE,1,3) <> "NF "
				    DbSkip()
				    Loop
				 EndIf				
				 If !MSRLock()
				  	lTudo := .F.
					Exit
				 EndIf
				
				 Aadd(aRecnos,Recno())				
				 Aadd(aSerNF,{Substr(X5_CHAVE,4,nTamSerie),Trim(X5Descri())})
				 dbSkip()
			  End
			
			  If !lTudo
				 nContErr++
				 If nContErr > 10
					DbSeek( xFilial("SX5")+"AC"+"NF " )
					While xFilial("SX5")+"AC"+"NF " == X5_FILIAL+X5_TABELA+Substr(X5_CHAVE,1,3)
						MsUnLock()
						dbSkip()
					End
					Help(" ",1,"NOTAPRESA")
					nContErr := 0
				 EndIf
				 Inkey(1)
				 Loop
			  EndIf
			  Exit
		   End
		EndIf   
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trata s‚rie e numero da nota fiscal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// S‚rie/NF
        DEFINE MSDIALOG oDlgLojaNota TITLE STR0113 From 10,30 To 17,58; // Numeracao N.Fiscal
        STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDEFAULT()
			
		DEFINE TIMER oTimer INTERVAL nTimeOut*1000 ACTION (lTimeOut:=.T.,oTimer:End(),oDlgLojaNota:End())  OF oDlgLojaNota
		@ 1, 2 TO 30, 108 OF oDlgLojaNota PIXEL
			
		@ 7, 5 SAY STR0114 SIZE 22, 7 OF oDlgLojaNota PIXEL //N.Fiscal
		
		If lNFManual	
		   @ 6, 25 MSGET cSerie  PICTURE "!!!";
		   VALID   If(lTimeout,.T.,LjxDVlSer(cSerie,@cNumNota, .T.));
		   SIZE 15, 10 OF oDlgLojaNota PIXEL		
		Else		   
		   @ 6, 25 MSGET cSerie  PICTURE "!!!";
		   VALID   If(lTimeout,.T.,LjxDVlSer(cSerie,@cNumNota, .T.)) F3 "CHA";
		   SIZE 15, 10 OF oDlgLojaNota PIXEL
		EndIf
			
		@ 6, 55 MSGET oNFClie VAR cNumNota	 PICTURE PesqPict("SF2","F2_DOC");
		VALID LjxDZera(@cNumNota) ;
		SIZE 47, 10 OF oDlgLojaNota PIXEL
			
		DEFINE SBUTTON FROM 31,42 TYPE 1 ACTION If(LjxDNFisca(@cNumNota,,,@cSerie).AND. LjValNota(cSerie,cNumNota),;
		(lRetorno := .T.,nOpca := 1, cDocSerie := "NF "+ cSerie,oDlgLojaNota:End()),;
		nOpca:=0);
		ENABLE OF oDlgLojaNota
		
		DEFINE SBUTTON FROM 31,73 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota
			
		ACTIVATE TIMER oTimer
		ACTIVATE MSDIALOG oDlgLojaNota CENTERED
				
		If lRetorno .AND. ExistBlock("LJ010SNF") .AND. !lFtvdVer12
			lRetorno := ExecBlock("LJ010SNF",.F.,.F.)
		EndIf
		
		If lRetorno .AND. ExistBlock("FVD10SNF") .AND. lFtvdVer12
			lRetorno := ExecBlock("FVD10SNF",.F.,.F.)
		EndIf
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o tamanho da serie for menor ou igual a 3, assume-se que nao foi  ³
		//³ gravado o tipo do documento(NF ,NFO, NFR, etc).Assumir NF como padrao³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	    cDocSerie  := "NF " + Padr(cMVSerie,nTamSerie)   
		DbSelectArea("SX5")
		DbSeek(xFilial()+"AC"+cDocSerie)
		IF Eof()
			HELP(" ",1,"ERROSERIE")
			Return .F.
		EndIf
		
		While !MsrLock()
			InKey(1)
			nContErr++
			IF nContErr > 10
				Help(" ",1,"NOTAPRESA")
				nContErr := 0
			EndIf
		End
		aAdd(aRecnos,Recno())
		cNumNota := Substr(X5Descri(),1,nTamDoc)
		cSerie   := cMvSerie
		
		lRetorno := LjValNota(cSerie,cNumNota)
	EndIf
	//Caso o numero maximo de itens seja determinado pelo parametro MV_SER+<serie>
	//calcular novamente a quantidade de notas a serem emitidas apos a selecao da serie
	//do documento
	If lRetorno .AND. lQtdeNotas
	   nMaxItens := LjGetMaxIt(cSerie) 
	   If nItensVenda > nMaxItens
	      nQtdNotas := Int(nItensVenda/nMaxItens) + Iif(Mod(nItensVenda,nMaxItens)>0,1,0)
	   Else
	      nQtdNotas := 1
	   Endif					   
	   //A impressao de ticket nao tem limitacao de itens - Loc. Guatemala	   
	   If lTicket 
	      nMaxItens := 999
	      nQtdNotas := 1  	      
	   EndIf
	EndIf
	nX := 1
	While nX <= nQtdNotas
		aAdd(aNotas,{cSerie,cNumNota})
		If nX < nQtdNotas
            cNumNota := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )         // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
		Endif
		nX ++
	End
	
	//Acertando o numero da nota no Sx5
	DbSelectArea("SX5")
	
	// Controle de Folios
	If lRetorno .AND. lContrFol
		lRetorno := ChkFolURU(	cFilAnt	, cSerie	, cNumNota, 	Nil,;
								.F.		, Nil		 )
	EndIf

	IF lRetorno
		If DbSeek( xFilial("SX5")+"AC"+cDocSerie )
		   RecLock("SX5",.F.)
           SX5->X5_DESCRI  := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )   // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
		   SX5->X5_DESCSPA := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )   // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
		   SX5->X5_DESCENG := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )   // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)
		   MsUnlock()
		EndIf   
	EndIf
	
	//Liberando registros locados
	For nI := 1 to Len(aRecnos)
		dbGoto(aRecnos[nI])
		MsUnLock()
	Next nI	
Endif

If lAtuDocSL1 .And. Empty(SL1->L1_DOC) .And. Len(aNotas) > 0
	//Persiste o DOC na SL1 para garantir a integridade
	RecLock("SL1", .F.)
	Replace SL1->L1_DOC with aNotas[1,2]
	Replace SL1->L1_SERIE with aNotas[1,1]
	Replace SL1->L1_SITUA with "T2"	//T2=Consumiu numero de Doc e Serie e atualizou os campos L1_DOC e L1_SERIE
	SL1->( MsUnlock() )
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    LjxDX5Troca³ Autor ³Vendas Clientes        ³ Data ³26/03/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Da get no numero da nota fiscal e na serie                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaloja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDX5Troca(nIt,aSerNF)
Local oDlgLojaNf
Local oBtn
Local cSerie	:= aSerNf[nIt,1]
Local cNumero	:= aSerNf[nIt,2]

// S‚rie/NF
DEFINE MSDIALOG oDlgLojaNf TITLE STR0110 From 13,50 To 18,65 ;
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDEFAULT()
@ .8,.8 MSGET cNumero Picture "@!" Font oDlgLojaNf:oFont Valid oDlgLojaNf:End()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao invisivel para poder exibir help na validacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Sair
@ 2000, 2000 BUTTON oBtn Prompt STR0115 SIZE 44, 11 ACTION oDlgLojaNf:End() OF oDlgLojaNf PIXEL

ACTIVATE MSDIALOG oDlgLojaNf
aSerNf[nIt,2] := cNumero
cSerie :=aSerNf[nIt,1]

Return aSerNf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ljxDSugNum³ Autor ³ Vendas Clientes       ³ Data ³ 12/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Sugere proximo numero de nota corretamente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ljxDSugNum                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Array com numero e serie                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Sigaloja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljxDSugNum(aSerNf,nItem,oQual)
Local nTamL1_DOC	:= TamSx3("L1_DOC")[1]		// Tamanho do campo L1_DOC
Local cNota 		:= STRZERO(0,nTamL1_DOC)	// Inicializacao do numero da nota
Local cFilSx5		:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5
Local cNumSx5									// Numero no SX5

DbSelectArea("SX5")
DbSeek( cFilSx5+"01" )
While !Eof() .AND. x5_Tabela == "01"
	If Alltrim(X5_Chave) == Alltrim(aSerNf[nItem,1])
		cNumSx5 := X5Descri()
		Exit
	Endif
	dbSkip()
End
If Val(aSerNf[nItem,2]) >= Val(cNumSx5)
	aSerNf[nItem,2]:= StrZero(Val(cNumSx5),nTamL1_DOC)
	oQual:Refresh()
	Return .F.
Endif
DbSelectArea("SF2")
DbSetOrder(4)
DbSeek(xFilial()+aSerNf[nItem,1],.T.)
IF Eof()
	cNota := STRZERO(0,nTamL1_DOC)
Else
	While F2_Filial+F2_Serie == xFilial()+aSernF[nItem,1] .AND. !Eof()
		cNota:=SF2->F2_Doc
		dbSkip()
	End
Endif
aSerNf[nItem,2] := PadR( strzero(val(cNota)+1,len(AllTrim(cNota))) , nTamL1_DOC )       // --> Alterado LAVOR  (Tratamento tamanho Nota Fiscal)   Era: aSerNf[nItem,2]:=      StrZero(Val(cNota)+1,nTamL1_DOC)
oQual:Refresh()
DbSelectArea("SF2")
DbSetOrder(1)

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³LjxDVlSer ³ Autor ³ Vendas Clientes       ³ Data ³ 11.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validar a serie da Fatura                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaloja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjxDVlSer( cSerie, cNumNota, lSeqEspecie )
Local lRet := .T.													//Retorno da funcao
Local aArea:=   GetArea()											//Area 
Local lNotaManual  := IIf(Type("lNFManual")#"U",lNFManual,.F.)		//Nota manual
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() 			//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

Default lSeqEspecie  	:= .F.

If !lNotaManual
   DbSelectArea("SX5")
   DbSetOrder(1)
	If lSeqEspecie
	   DbSeek(xFilial()+"AC"+"NF "+cSerie)
	Else   
       DbSeek(xFilial()+"01"+cSerie)
    EndIf   
    If ! Found()
	   If !lFtvdVer12
	   	Help(" ",1,"LJ010SERIE")
	   ElseIf lFtvdVer12
	   	 Help(" ",1,"FTVD010SERIE")
	   EndIf	
	   lRet:=.F.
	EndIf   
    cNumNota := AllTrim(X5Descri())
    RestArea(aArea)	
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LjxDZera    ³ Autor ³ Vendas Clientes    ³ Data ³ 12/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agrega ceros a la izquierda de la variable que se ingresa  ³±±
±±³          ³ como parametro. Para ser usada en las entradas de ciertos  ³±±
±±³          ³ campos                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  LjxDZera ( @cCaptura )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaloja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDZera(cCaptura)

If !Empty(cCaptura)
	cCaptura:=StrZero(val(cCaptura),LEN(cCaptura))
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ LjxDNFisca  ³ Autor ³ Vendas Clientes    ³ Data ³ 11.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validar o n£mero da Fatura                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaloja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjxDNFisca(cNFiscal,cPreNF,cSecNF,cSerie)
Local lRet 			:= .T.        															//Retorno da funcao
Local lReutiliza    := SuperGetMV("MV_USAMNUM",,.T.)										//Conteudo do parametro MV_USAMNUM
Local cTipContNF	:= Iif(lFiscal,SuperGetMV("MV_CONTNFI",,"I"),SuperGetMV("MV_CONTNF"))	//Tipo de controlo NFiscal
Local aArea			:= GetArea()															//Area local
Local nTamL1_SERIE	:= TamSx3("L1_SERIE")[1]												//Tamanho do campo L1_SERIE
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

cNFiscal := PadR( cNFiscal , TamSx3("F2_DOC")[1] )           								// --> Incluso  LAVOR  (Tratamento tamanho Nota Fiscal)

cNFiscal := IIf(cNFiscal==Nil ,"",cNFiscal)
cPreNF := IIf(cPreNF==Nil ,"",cPreNF)
cSecNF := IIf(cSecNF==Nil ,"",cSecNF)
cSerie := IIf(cSerie==Nil ,Space(nTamL1_SERIE),cSerie)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste duplicidade de digitacao de Nota Fiscal.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF2")
DbSetOrder(1)

If Empty( cNFiscal)
	Help(" ",1,"A467VAZIO")
	lRet := .F.
Else
	DbSeek(xFilial("SF2")+cNFiscal+cSerie)
	If Found()
		Help(" ",1,"A467EXIST")
		lRet := .F.
	EndIf
EndIf

If lRet
   DbSelectArea("SF3")
   DbSetOrder(5)
   If DbSeek( xFilial("SF3")+cSerie+cNFiscal)
	  While !Eof() .AND. (xFilial("SF3")+cSerie+cNFiscal) == (SF3->F3_FILIAL+SF3->F3_SERIE+SF3->F3_NFISCAL)
		If IIf(cTipContNF=="I",Alltrim(SF3->F3_ESPECIE)$"NF|FT",.T.)
		   If !Empty(SF3->F3_DTCANC) .AND. !lReutiliza
		      Help(" ",1,"EXISTSF3")  //Ja existe um registro no Livro Fiscal com
		      lRet  := .F.            //mesmo numero e serie. Pelo parametro MV_USAMNUM
		   EndIf                      //nao eh possivel reutilizar este mesmo numero.
		Endif
		dbSkip()
	  End
   EndIf
EndIf

If lRet
	If (ExistBlock("LJ010SER")) .AND. !lFtvdVer12
		lRet := ExecBlock("LJ010SER",.F.,.F.,{cSerie,cNFiscal})
	EndIf
	
	If (ExistBlock("FTVD010SER")) .AND. lFtvdVer12
		lRet := ExecBlock("FTVD010SER",.F.,.F.,{cSerie,cNFiscal})
	EndIf
Endif

RestArea(aArea)

Return( lRet )     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ljxDANf   ³ Autor ³ Vendas Clientes       ³ Data ³ 18/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Atualiza numero de nota e serie                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ljxDANf                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Sigaloja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljxDANf(oQual,aSerNf,cSer,cNot)
Local lRet := .F.											//Retorno da funcao

If LjValNota(aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2])
	If cSer == Nil .AND. cNot == Nil
		cSerie := aSerNf[oQual:nAT,1]
		cNumNota := aSerNf[oQual:nAT,2]
	Else
		cSer := aSerNf[oQual:nAT,1]
		cNot := aSerNf[oQual:nAT,2]
	Endif
	lRet := .T.
Endif

Return lRet  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³LJxDImpCli  ³ Autor ³Vendas Clientes        ³ Data ³ 12/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprimir o codigo, descricao e status da analise de credito  ³±±
±±³          ³ do cliente no rodape da tela da Venda Balcao.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJxDImpCli(ExpC1,ExpC2,ExpN3,ExpC4,ExpL5)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente para busca/exibicao no rodape      ³±±
±±³          ³ ExpC2 = Codigo da loja para buscar no cadastro de cliente    ³±±
±±³          ³ ExpN3 = Numero do folder que a funcao esta sendo chamada     ³±±
±±³          ³ ExpC4 = Descricao da analise de credito do cliente           ³±±
±±³          ³ ExpL5 = Indica se eh um novo orcamento para buscar a status  ³±±
±±³          ³         de analise de credito do cliente padrao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaloja                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJxDImpCli( cCodCli, cCodLoj, nFolder, cMotivo )
Local oFonte											//Fonte

SA1->( DbSetOrder(1) )
SA1->( DbSeek( xFilial( "SA1" ) + cCodCli + cCodLoj ) )

DEFINE FONT oFonte NAME "Arial" BOLD

If oNomeCli # NIL
	oNomeCli:Hide()
EndIf

// Se o motivo nao esta preenchido, chama a funcao de analise
// de credito para preenchelo.
// Caso o motivo esteja preenchido, quer dizer que esta funcao jah esta
// sendo chamada da funcao LjCreCli, e nao chama a mesma novamente.
@ 136,02 SAY oNomeCli VAR SA1->( RTrim( A1_COD ) + ' - ' + RTrim( A1_NOME ) ) + ' - ' +;
 		IIf( cMotivo == NIL, SA1->( LJxDImpStatus( A1_COD, A1_LOJA ) ), cMotivo )  ;
 		SIZE 290,08 OF oFolder:aDialogs[nFolder] PIXEL FONT oFonte COLOR CLR_HBLUE

oNomeCli:Show()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³LJxDImpStatus  ³ Autor ³Vendas Clientes     ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Buscar o status da analise de credito do cliente.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJxDImpStatus(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente para criterio da analise de credito³±±
±±³          ³ ExpC2 = Codigo da loja do cliente para analise de credito    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaloja                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJxDImpStatus( cCliente, cLoja )
Local cStatus												//Status

cStatus := ""

LjCreCli( cCliente, cLoja, , , , @cStatus )

Return cStatus

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ljxDIss	³ Autor ³ Vendas Clientes       ³ Data ³ 06/05/9  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula valor do ISS										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Valor total do item 									  ³±±
±±³			 ³ 2 - Recalcula ou Nao o ISS 								  ³±±
±±³			 ³ 3 - Taxa de Desconto para o Iss							  ³±±
±±³			 ³ 4 - Taxa de Juros para o Iss								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja  												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ljxDIss(nVlrTot,lRecalcula,nTxDescIss,nTxJurIss,lDifer)
Local aArea		:= {}										//Area corrente
Local nValIss	:= 0										//Valor Iss
Local nPosTes	:= aPosicoes[5][2]						//Posicao TES
Local nPosValIss:= aPosicoes[8][2]						//Posicao Valor Iss
Local nPosTotal	:= aPosicoes[2][2]						//Posicao Total
Local nGrade	:= Ascan(aCampos,"L2_GRADE")				//Campo L2_GRADE
Local cGrade	:= If(!__lPyme,aCols[n][nGrade],"N")		//Grade
Local lISSIsen	:= .F.

If cPaisLoc <> "BRA"
	nValIss := 0.00
Else
	aArea := GetArea()
	
	//-- Utilizando o mesmo conceito do MATXFIS (funções fiscais).
	If Lj7recIss() .OR. ( SA1->A1_RECISS <> "1" )
		//--- Verifica se os parametros existem ---
		nVlrTot	   := Iif(nVlrTot    == NIL, 0   , nVlrTot	  )
		lRecalcula := Iif(lRecalcula == NIL, .F. , lRecalcula )
		nTxDescIss := Iif(nTxDescIss == NIL, 0   , nTxDescIss )
		nTxJurIss  := Iif(nTxJurIss  == NIL, 0   , nTxJurIss  )
		lDifer     := Iif(lDifer     == NIL, .F. , lDifer     )
		
		nValIss := 0
		DbSelectArea("SF4")
		
		If lRecalcula
			MsSeek( xFilial("SF4")+SL2->L2_TES)
			
			If SF4->F4_ICM == "N" .And. SF4->F4_ISS == "N" .And.;
				((SF4->F4_LFISS == "I" .And. ((ALLTRIM(SF4->F4_CSTISS) $ "07|06") .Or. (Empty(ALLTRIM(SF4->F4_CSTISS))))) .Or.;
						SF4->F4_LFISS == "N" .OR.; //Não sujeito a ISS
						SF4->F4_LFISS == "O")	//  Outros
					
				nValIss := 0
				lISSIsen:= .T.
			EndIf

			If !lISSIsen .And. SF4->F4_ISS == "S"
				If nTxJurIss > 0
					If !lDifer
						nVlrTot += (nVlrTot * nTxJurIss) /100
					Endif
					
					If cGrade == "S"
						nValIss := nVlrTot * Iif(SB4->B4_ALIQISS > 0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Else
						nValIss := nVlrTot * Iif(SB1->B1_ALIQISS > 0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Endif
					
				ElseIf nTxDescIss > 0
					nVlrTot -= (nVlrTot * nTxDescIss) /100
					If cGrade  == "S"
						nValIss := nVlrTot * Iif(SB4->B4_ALIQISS > 0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Else
						nValIss := nVlrTot * Iif(SB1->B1_ALIQISS > 0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Endif
				Else
					If cGrade  == "S"
						nValIss := nVlrTot * Iif(SB4->B4_ALIQISS > 0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Else
						nValIss := nVlrTot * Iif(SB1->B1_ALIQISS > 0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Endif
				EndIf
			Endif
		Else
			MsSeek( xFilial("SF4")+aCols[n][nPosTes])
			If SF4->F4_ICM == "N" .And. SF4->F4_ISS == "N" .And.;
				( ( SF4->F4_LFISS == "I" .And. ((ALLTRIM(SF4->F4_CSTISS) $ "07|06") .Or. (Empty(ALLTRIM(SF4->F4_CSTISS))))) .Or.;
					SF4->F4_LFISS == "N" .OR.; //Não sujeito a ISS
					SF4->F4_LFISS == "O")	//  Outros
				
				nValIss := 0
				lISSIsen:= .T.
			EndIf
			
			If !lISSIsen
				If SF4->F4_ISS == "S"
					If cGrade == "S"
						nValIss := aCols[n][nPosTotal] * Iif(SB4->B4_ALIQISS>0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Else
						nValIss := aCols[n][nPosTotal] * Iif(SB1->B1_ALIQISS>0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
					Endif
				EndIf
			Endif
			
			If nPosValIss > 0
				aCols[n][nPosValIss] := nValIss
			Endif
		Endif
	Endif
	
	RestArea( aArea )
EndIf

Return nValIss

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDIPI   ºAutor  ³ Vendas Clientes     º Data ³  11/04/97   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de verificacao e calculo de IPI.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EnxpN1: Valor do Preco de Tabela                            º±±
±±º          ³ EnxpN2: Quantidade                                          º±±
±±º          ³ EnxpN3: Desconto                                            º±±
±±º          ³ EnxpN4: Valor de Acresicmo ou Decrescimo                    º±±
±±º          ³ EnxpC5: Tipo de Entrada e Saida                             º±±
±±º          ³ EnxpN6: Linha                                               º±±
±±º          ³ EnxpC7: Produto                                             º±±
±±º          ³ EnxpC8: Tipo de Retorno a ser utilizado                     º±±
±±º          ³ EnxpN9: Valor do Frete                                      º±±
±±º          ³ EnxpN10: Valor do Seguro                                    º±±
±±º          ³ EnxpN11: Valor do Desconto                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDIPI(	nPrcTab		, nQuant	, nDesc		, nDescNF	,;
					cTes		, nLinha	, cProduto	, cRet		,;
					nValFrete	, nValSeg	, nValDes )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No microterminal nao exites aCampos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTipoCalc   := SuperGetMv( "MV_IPIBRUT" )																					//Captura o parametro MV_IPIBRUT
Local cGrade																													//Grade
Local cTabela																													//Tabela
Local nGrade      := IIF( Alias() == "SD1" .OR. ! Type( "aCampos" ) == "A" .OR. __lPyme, 0, AScan( aCampos, "L2_GRADE" ) )	//Grade
Local nAliq																														//Aliquota
Local nBasIpiUni																												//Base IPI
Local nValDesc																													//Valor desconto
Local nValIpi     := 0																											//Valor IPI
Local nPPrcTab																													//Preco trabalhado
Local nPQuant																													//Quantidade
Local nPDesc																													//Desconto
Local nPTes																														//Tes
Local nPProduto																													//Produto
Local nPValIpi																													//Valor Ipi
Local nPValDesc																													//Valor desconto
Local nPTabela																													//Tabela
Local nPValFrete																												//Valor Frete
Local nPValSeg																													//Valor seguro
Local nPValDes																													//Valor despesa
Local lLinha      := ( nLinha == NIL )																							//Linha
Local nTamL2_PRC  := TamSX3( "L2_PRCTAB" )[2]	// Tamanho do campo L2_PRCTAB													//Tamanho campo L2_PRCTAB
Local nTamL2_VAL  := TamSX3( "L2_VALIPI" )[2]	// Tamanho do campo L2_VALIPI													//Tamanho campo L2_VALIPI

Default cRet      		:= "V" 																										//Parametro utilizado para retornar "V"ALOR ou "B"ASE do IPI
Default nValFrete 	:= 0																											//Valor frete
Default nValSeg   	:= 0																											//Valor seguro
Default nValDes   	:= 0																											//Valor desconto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fora do Brasil nao possui IPI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aPosicoes nao existe no Microterminal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TYPE( "aPosicoes" ) == "A"
		nPPrcTab   	:= aPosicoes[13][2]
		nPQuant    	:= aPosicoes[11][2]
		nPDesc		:= aPosicoes[4][2]
		nPTes    	:= aPosicoes[5][2]
		nPProduto   := aPosicoes[9][2]
		nPValIpi	:= aPosicoes[7][2]
		nPValDesc 	:= aPosicoes[3][2]
		nPTabela    := aPosicoes[10][2]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o campo do IPI nao eh usado entao nao calcula³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPValIpi == 0
			Return ( 0 )
		Endif
	Endif
	
	If VALTYPE( nLinha ) == "U" .OR. VALTYPE( nLinha ) <> "N"
		nLinha := n
	Endif
	
	If TYPE( "aCampos" ) == "A" .AND. ( nPValFrete := AScan( aCampos, "L2_VALFRE" ) ) > 0
		nValFrete := IIF( ValType( aCols[nLinha][nPValFrete] ) <> "N", nValFrete, aCols[nLinha][nPValFrete] )
	Endif
	
	If TYPE( "aCampos" ) == "A" .AND. ( nPValSeg := AScan( aCampos, "L2_SEGURO" ) ) > 0
		nValSeg := IIF( ValType( aCols[nLinha][nPValSeg] ) <> "N", nValFrete, aCols[nLinha][nPValSeg] )
	Endif
	
	If TYPE( "aCampos" ) == "A" .AND. ( nPValDes := AScan( aCampos, "L2_DESPESA" ) ) > 0
		nValDes := IIF( ValType( aCols[nLinha][nPValDes] ) <> "N", nValFrete, aCols[nLinha][nPValDes] )
	Endif
	
	If VALTYPE( nQuant ) == "U" .OR. VALTYPE( nQuant ) <> "N"
		nQuant := aCols[nLinha][nPQuant]
	Endif
	
	If VALTYPE( nDesc ) == "U" .OR. VALTYPE( nDesc ) <> "N"
		nDesc := aCols[nLinha][nPDesc]
	Endif
	
	If VALTYPE( nDescNF ) == "U" .OR. VALTYPE( nDescNF ) <> "N"
		nDescNF := 0
	Endif
	
	If VALTYPE( cTes ) == "U" .OR. VALTYPE( cTES ) <> "C" .OR. VAL( cTES ) == 0
		cTes := aCols[nLinha][nPTES]
	Endif
	
	If VALTYPE( cProduto ) == "U" .OR. VALTYPE( cProduto ) <> "C"
		cProduto := aCols[nLinha][nPProduto]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No Microterminal nao possui aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Type( "aCols" ) == "A" .OR. VALTYPE( aCols[nLinha][nPTabela] ) == "U" .OR. EMPTY( aCols[nLinha][nPTabela] )
		cTabela := "1"
	Else
		cTabela := aCols[nLinha][nPTabela]
	Endif
	
	If VALTYPE( nPrcTab ) == "U" .OR. VALTYPE( nPrcTab ) <> "N"
		If lLinha
			If ( "L2_VRUNIT" $ ReadVar() )
				nPrcTab := Eval( MemVarBlock( ReadVar() ) )
			Else
				If aCols[nLinha][nPPrcTab] == 0
					If LjNfPafEcf(SM0->M0_CGC) 
						LjxeValPre(@nPrcTab, cProduto, /*cCliente*/, /*cLoja*/)
	                Else
						SB0->( DbSetOrder( 1 ) )
						SB0->( DbSeek( xFilial( "SB0" ) + cProduto ) )
						nPrcTab := Eval( FieldBlock( "SB0->B0_PRV" + cTabela ) )
					EndIf	
				Else
					nPrcTab := aCols[nLinha][nPPrcTab]
				Endif
			Endif
		Else
			nPrcTab := aCols[nLinha][nPPrcTab]
		Endif
	Endif
	
	If ! nGrade == 0
		cGrade := aCols[nLinha][nGrade]
	Else
		cGrade := "N"
	Endif

	If Empty(cTipoCalc)
		cTipoCalc := "S"
	EndIf

	SF4->( DbSetOrder( 1 ) )

	If SF4->( DbSeek( xFilial( "SF4" ) + cTes ) ) .AND. SF4->F4_IPI == "S"
		If !Empty(SF4->F4_TPIPI)
			cTipoCalc := SF4->F4_TPIPI
		EndIf
		
		If cGrade == "S"
			SB4->( DbSetOrder( 1 ) )
			SB4->( DbSeek( xFilial( "SB4" ) + cProduto ) )

			nAliq := SB4->B4_IPI
		Else
			SB1->( DbSetOrder( 1 ) )
			SB1->( DbSeek( xFilial( "SB1" ) + cProduto ) )

			nAliq	:= SB1->B1_IPI
			nValIPI	:= SB1->B1_VLR_IPI * nQuant
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se é IPI de Pauta³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nAliq <> 0 .OR. nValIPI > 0
			nBasIpiUni := Round( ( nPrcTab * nQuant ) * IIF( SF4->F4_BASEIPI > 0, SF4->F4_BASEIPI / 100, 1 ), nTamL2_PRC )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O Frete, o seguro e o desconto deve ser somado ao valor da base do IPI, e não ao preço de venda e ³
			//³depois multiplicado a qtde.                                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_IPIFRET == "S"
				nBasIPIUni += ( nValFrete + nValSeg + nValDes )
			Endif
			
			If !( cTipoCalc $ "SB" )
				If nDesc > 0 .AND. nDesc < 100
					nBasIpiUni *= ( 1 - ( nDesc / 100 ) )
				Endif
				If nDescNF > 0 .AND. nDescNF < 100
					nBasIpiUni *= ( 1 - ( nDescNF / 100 ) )
				Endif
				nBasIpiUni := NoRound( nBasIpiUni, nDecimais )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³No Microterminal nao possui aCols³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TYPE( "aCols" ) == "A"
				nValDesc := aCols[nLinha][nPValDesc]
			Else
				nValDesc := 0
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao for IPI de Pauta, faz o calculo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nValIPI == 0	
				nValIPI := NoRound( ( nBasIpiUni * nAliq ) / 100, nTamL2_VAL )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o valor do IPI do produto no aCols se o mesmo estiver diferente do valor atual calculado.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If 	TYPE( "aCols" ) == "A" .AND. TYPE( "aPosicoes" ) == "A" .AND.;
				VALTYPE( aCols[nLinha][nPValIPI] ) <> "U" .AND. aCols[nLinha][nPValIPI] <> nValIPI
				
				aCols[nLinha][nPValIPI] := nValIPI

				oGet:oBrowse:Refresh()
			Endif
		Else
			Return ( 0 )
		Endif
	Else
		Return ( 0 )
	Endif
Else
	Return ( 0 )
Endif

Return IIF( cRet == "V", nValIPI, nBasIpiUni )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDPreco ³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega preco de venda de acordo com tabela.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDPreco(cOrigem)
Local cAlias      := Alias()
Local nPosValDesc := aPosicoes[3][2]			// Armazena o valor do desconto
Local nPosDesc    := aPosicoes[4][2]			// Armazena o desconto do item
Local nPosProd    := aPosicoes[9][2]			// Armazena o codigo do produto
Local nPosTabela  := aPosicoes[10][2]			// Armazana a tabela de preco
Local nPosQuant   := aPosicoes[11][2]			// Armazena a qtde vendida
Local nPosPreco   := aPosicoes[1][2]			// Armazena valor unitario
Local nPosTotal   := aPosicoes[2][2]			// Armazena valor do item
Local nPosTES     := aPosicoes[5][2]			// Armazema o tipo de entrada e saida
Local nPosPrTab   := aPosicoes[13][2]			// Armazena o preco da tabela de produtp
Local lTrcMoeda   := SuperGetMv("MV_TRCMOED")	// Armazena o conteudo do parametro MV_TRCMOED 
Local lCalcImp    := .T.						// Calcula imposto
Local nMoedaPrv   := 0							// Moeda privada
Local nPreco									// Preco
Local aTesImpInf  := {}							// TES
Local nAliqImp    := 0							// Aliquota
Local cProc       := " "						// Processamento
Local nX          := 0							// Contador de For

//Grade

If !lGradProd
	DbSelectArea( "SB1" )
	DbSetOrder( 1 )
	DbSeek( cFilial + m->l2_produto )
	
	DbSelectArea( "SB0" )
	DbSetOrder( 1 )
	
	If !(DbSeek( cFilial + m->l2_produto ) )
		Help( " ", 1, "NOPRECO" )
		DbSelectArea( cAlias )
		Return 0
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a rotina esta sendo chamada da Lj010FRETE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nX    := 0
	cProc := Upper(AllTrim(ProcName(nX)))
	While ! ( cProc == "" ) .AND. !("Lj010FRETE" $ cProc)
		nX++
		cProc := Upper(AllTrim(ProcName(nX)))
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a chamada veio da rotina de frete então pega a tabela ³
	//³ de precos da aCols                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "Lj010FRETE" $ cProc
		cTabela := If(ValType(aCols[n][nPosTabela])=="N",Str(aCols[n][nPosTabela]),aCols[n][nPosTabela])
	Else
		cTabela := Str(nTabela,1)
	Endif
	
	If Empty(&("SB0->B0_DATA" + cTabela)) .OR. dDatabase <= &("SB0->B0_DATA" + cTabela)
		aCols[n][nPosTabela] := cTabela
		If lTrcMoeda
			If SB0->&("B0_MOEDA" + cTabela)==0
				nMoedaPrv := 1
			Else
				nMoedaPrv := SB0->&("B0_MOEDA" + cTabela)
			EndIf
			If lTroca                                                                         
			   nPreco := Round(xMoeda(&("SB0->B0_PRV" + cTabela),nMoedaPrv,nMoedaTr,dDataBase,nDecimais+1,,If(cPaisLoc<>"BRA",nTxMoedaTr,0)),nDecimais)			
			Else			
			   nPreco := Round(xMoeda(&("SB0->B0_PRV" + cTabela),nMoedaPrv,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
			Endif   
		Else
			nPreco := &("SB0->B0_PRV" + cTabela)
		Endif
        If cPaisLoc == "SAL"
           lCalcImp    := SA1->A1_TIPO $ "1|2"
           aTesImpInf  := TesImpInf(aCols[n][nPosTES])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //| TES isento de imposto ou IVA 0%  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           If (Len(aTesImpInf) == 0 .OR. !lCalcImp .OR. LjxDImpZero(aTesImpInf)) .AND.;
              aCols[n][nPosPrTab] > 0 
              
              SFB->(DbSetOrder(1))
              If SFB->(DbSeek(xFilial("SFB")+"IVA"))
                 nAliqImp  := SFB->FB_ALIQ
              Endif
              aCols[n][nPosPreco]  := Round((nPreco/(1+(nAliqImp/100))),nDecimais)
              aCols[n][nPosTotal]  := aCols[n][nPosPreco] * aCols[n][nPosQuant]
           Endif   
        Endif				
	Else
		nPreco := 0
	Endif
Else
	IF cOrigem == Nil
		DbSelectArea( "SB4" )
		DbSetOrder( 1 )
		If !(DbSeek( cFilial + m->l2_produto ) )
			Help( " ", 1, "NOPRECO" )
			DbSelectArea( cAlias )
			Return 0
		Endif
	Else
		DbSelectArea( "SB4" )
		DbSetOrder( 1 )
		If !(DbSeek( cFilial + aCols[n][nPosProd] ) )
			Help( " ", 1, "NOPRECO" )
			DbSelectArea( cAlias )
			Return 0
		End
	Endif
	
	cTabela := Str(nTabela,1)
	aCols[n][nPosTabela] := cTabela
	If lTrcMoeda
		nMoedaPrv := IIF(SB4->&("B4_MOEDA" + cTabela)==0,1,SB4->&("B4_MOEDA" + cTabela))
		If lTroca                                                                         
		   nPreco := Round(xMoeda(&("SB4->B4_PRV" + cTabela),nMoedaPrv,nMoedaTr,dDataBase,nDecimais+1,,If(cPaisLoc<>"BRA",nTxMoedaTr,0)),nDecimais)
		Else					
		   nPreco := Round(xMoeda(&("SB4->B4_PRV" + cTabela),nMoedaPrv,nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
		Endif   
	Else
		nPreco := &("SB4->B4_PRV" + cTabela)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|  Se a balanca trabalha por preco  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPrecoBal
	M->L2_QUANT := NoRound(Val(cInfProBal) / 100 / nPreco, 3)
	aCols[n][nPosQuant]:= M->L2_QUANT
Endif

If lUsaDisplay
	MsgDisplay(5, {SB1->B1_COD, SB1->B1_CODBAR, SB1->B1_DESC, 1, nPreco, 0, ""})
Endif

DbSelectArea( cAlias )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Só podemos zerar o desconto se a Venda Balcão não trabalhar com concomitância³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .AND. !lVendConc
	IF aCols[n][nPosDesc] > 0 .OR. aCols[n][nPosValDesc] > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| O desconto desse produto foi zerado.   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsgStop(STR0060)
		aCols[n][nPosDesc] := 0
		aCols[n][nPosValDesc] := 0
	Endif
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a chamada veio da rotina de frete então pega a tabela ³
//³ de precos da aCols                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPreco == 0 .AND. aCols[n,nPosPreco] <> 0 .AND. "Lj010FRETE" $ cProc 
	nPreco 	:= aCols[n,nPosPreco]
Endif   
                
Return nPreco

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjxDCbPag ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Combo-Box com as opcoes de pagamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LjxDCbPag()                               	          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Array com as condicoes cadastradas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Sigaloja                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDCbPag(aCondicoes)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a condicao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCondicoes := LjxDCondP()

If !(cPaisLoc $ "EUA|POR") .OR. !lLayAway
	AAdd(aCondicoes, ("CN " + " - " + STR0116 ))  //"Condicao Negociada"
Endif
Return aCondicoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDValP  ³ Autor ³ Vendas Clientes       ³ Data ³ 16.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a parcela digitada considerando multi-moeda          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDValP(nValor,nValAteP,nValTot,cMoedaTit)
Local lRet       := .F.							// Retorno da funcao
Local lAchou     := .F.							// Se achou a busca
Local nI         := 0							// Contador de For
Local nMoedaOrig := 1							// Moeda Origem
Local nNumMoeda  := MoedFin()					// Numero da Moeda
Local nDif       := 0							// Diferenca
Local nValorDig  := 0							// Valor digitado
Local nDifValor  := 0							// Diferenca de valor

nI++
While !lAchou .AND. nI <= nNumMoeda
	If cMoedaTit == SuperGetMV("MV_MOEDA"+LTrim(Str(nI)))
		nMoedaOrig  := nI
		lAchou := .T.
	Endif
	nI++
End

nValorDig := Round(xMoeda(nValor,nMoedaOrig,nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)

nDif := (1/(10**nDecimais))   //Intervalo de tolerancia para diferencas de arredondamento na conversao de valores
nDifValor := Abs(nValorDig+nValAteP - nValTot)
If nDifValor <= nDif  .AND. nDifValor > 0
	nValTot := nValorDig+nValAteP             //Ha uma diferenca de arredondamento
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Compara o valor digitado e as demais parcelas com o total da fatura, considerando multimoeda  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (nValorDig+nValAteP) <= nValTot

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDCbFrm ³ Autor ³Vendas Clientes        ³Data  ³ 12.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida forma do ComboBox 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 := Data de Emissao     				              ³±±
±±³          ³ ExpD1 := Data              				                  ³±±
±±³          ³ ExpC1 := Combo de pagamento				                  ³±±
±±³          ³ ExpO1 := Tela de pagamentos				                  ³±±
±±³          ³ ExpA1 := Matriz contendo as datas e valores para pagamentos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDCbFrm(cComboPag,		oPgtos,		aPgtos,		dDataEmis,;
					dDataForm,		aTmpPgtos)

Local lRet     := .T.					// Retorno da funcao
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() 	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

If !lFtvdVer12
	If FunName() == "LOJA220" .AND. ExistBlock("LJ220DATE")
		lRet := ExecBlock("LJ220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"COMBOPAG",oListForma,aFormas})
		If lRet
			aFormas[oListForma:nAT][01] := dDataForm	 
			aFormas[oListForma:nAT][12] := dDataEmis
		Else
			aFormas[oListForma:nAT][01] := aTmpFormas[oListForma:nAT][01]
			aFormas[oListForma:nAT][12] := aTmpFormas[oListForma:nAT][12]
			dDataForm := aTmpFormas[oListForma:nAT][01]
			dDataEmis := aTmpFormas[oListForma:nAT][12]
		Endif
	ElseIf FunName() == "LOJA010" .AND. ExistBlock("Lj010DATE")
		lRet := ExecBlock("Lj010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"COMBOPAG",oPgtos,aPgtos})
		If lRet
			aPgtos[oPgtos:nAT][1] := dDataForm	 
			aPgtos[oPgtos:nAT][5] := dDataEmis
		Else	
			aPgtos[oPgtos:nAT][1] := aTmpPgtos[oPgtos:nAT][1]
			aPgtos[oPgtos:nAT][5] := aTmpPgtos[oPgtos:nAT][5]
			dDataForm := aTmpPgtos[oPgtos:nAT][1]
			dDataEmis := aTmpPgtos[oPgtos:nAT][5]
		Endif
	Endif
ElseIf lFtvdVer12
	If FunName() == "LOJA220" .AND. ExistBlock("FTVD220DATE")
		lRet := ExecBlock("FTVD220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"COMBOPAG",oListForma,aFormas})
		If lRet
			aFormas[oListForma:nAT][01] := dDataForm	 
			aFormas[oListForma:nAT][12] := dDataEmis
		Else
			aFormas[oListForma:nAT][01] := aTmpFormas[oListForma:nAT][01]
			aFormas[oListForma:nAT][12] := aTmpFormas[oListForma:nAT][12]
			dDataForm := aTmpFormas[oListForma:nAT][01]
			dDataEmis := aTmpFormas[oListForma:nAT][12]
		Endif
	ElseIf FunName() == "LOJA010" .AND. ExistBlock("FTVD010DATE")
		lRet := ExecBlock("FTVD010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"COMBOPAG",oPgtos,aPgtos})
		If lRet
			aPgtos[oPgtos:nAT][1] := dDataForm	 
			aPgtos[oPgtos:nAT][5] := dDataEmis
		Else	
			aPgtos[oPgtos:nAT][1] := aTmpPgtos[oPgtos:nAT][1]
			aPgtos[oPgtos:nAT][5] := aTmpPgtos[oPgtos:nAT][5]
			dDataForm := aTmpPgtos[oPgtos:nAT][1]
			dDataEmis := aTmpPgtos[oPgtos:nAT][5]
		Endif
	Endif	
EndIf

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDDtEmis ³ Autor ³Vendas Clientes        ³Data  ³12/11/02   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da data de emissao do cheque                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := LjxDDtEmis(ExpD1,ExpD2,ExpC1,ExpO1,ExpA1)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 := Data de Emissao     				               ³±±
±±³          ³ ExpD1 := Data              				                   ³±±
±±³          ³ ExpC1 := Combo de pagamento				                   ³±±
±±³          ³ ExpO1 := Tela de pagamentos				                   ³±±
±±³          ³ ExpA1 := Matriz contendo as datas e valores para pagamentos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja      											   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjxDDtEmis(	dDataEmis,		dDataForm,		cComboPag,		oPgtos,;
						aPgtos	)

Local lRet := .T.						// Retorno da funcao
Local lFtvdVer12		:= FindFunction("LjFTvd") .AND. LjFTVD() 	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

If !lFtvdVer12
	If FunName() == "LOJA220" .AND.  ExistBlock("LJ220DATE")
		lRet := ExecBlock("LJ220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oListForma,aFormas})
	ElseIf FunName() == "LOJA010" .AND. ExistBlock("Lj010DATE")
		lRet := ExecBlock("Lj010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oPgtos,aPgtos})
	Else
		If dDataBase <= dDataEmis .AND. dDataForm >= dDataEmis
			lRet := .T.
		Else
			MsgStop(STR0117) //"A data de emissao nao pode ser menor do que a data do sistema!"
			lRet := .F.
		Endif
	Endif			  
Elseif lFtvdVer12
	If FunName() == "LOJA220" .AND.  ExistBlock("FTVD220DATE")
		lRet := ExecBlock("FTVD220DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oListForma,aFormas})
	ElseIf FunName() == "LOJA010" .AND. ExistBlock("FTVD010DATE")
		lRet := ExecBlock("FTVD010DATE",.F.,.F.,{dDataEmis,dDataForm,cComboPag,"DDATAEMIS",oPgtos,aPgtos})
	Else
		If dDataBase <= dDataEmis .AND. dDataForm >= dDataEmis
			lRet := .T.
		Else
			MsgStop(STR0117) //"A data de emissao nao pode ser menor do que a data do sistema!"
			lRet := .F.
		Endif
	Endif	
EndIf

Return( lRet )	          

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDVldGet   ³ Autor ³Vendas Clientes        ³Data  ³29/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do valor informado pelo usuario no        ³±±
±±³          ³ TWBrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := LjxDVldGet()                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := .T. para o dado valido e .F. para o dado invalido    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja      	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function LjxDVldGet()
Local lRet := .T.						// Retorno da funcao

If M->CELL <= 0
	lRet := .F.
EndIf
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxDSerArg   ³ Autor ³Vendas Clientes        ³Data  ³03/02/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica a serie da fatura/cupom fiscal dependendo do tipo de   ³±±
±±³          ³ cliente(Loc. Argentina)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := LjxDSerArg()                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1 := Serie                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja      	     									     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjxDSerArg()
Local cTipoCli   := ""					// Tipo cliente
Local cSerieDoc  						// Serie do cliente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relacao Tipo de Cliente x Serie  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Tipo Cliente      ³ Serie        ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³E(Exportacao)   	 ³ E		    ³
//³F(Cons. Final)    ³ B            ³
//³M(Monotrib.)      ³ B            ³
//³N(Resp.Nao Insc.) ³ B            ³
//³S(Nap Sujeito)    ³ B            ³
//³X(Isento) 	     ³ B            ³
//³I(Inscrito)       ³ A            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipoCli  := SA1->A1_TIPO 
If cTipoCli == "E"	        
   cSerieDoc := "E"	   
ElseIf cTipoCli $ "F|M|N|S|X"
   cSerieDoc := "B"	   
Else
   cSerieDoc := "A"	   	      
Endif   

Return (cSerieDoc)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função    ³ LjxDAbISS   ³ Autor ³ Vendas Clientes    ³ Data ³ 09/12/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³ Faz a verificação se o valor do ISS deve ser abatido no      ³±±
±±³           ³ valor total da venda.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDAbISS(cCondPgto, cFormaPg, nVlrTotISS)

Local cBCliente 	:= ""
Local cBLoja    	:= ""         
Local lRet		 	:= .T.
Local nMinRetISS  	:= SuperGetMv("MV_VRETISS",.F.,0) //Valor minimo para dispensa de retencao de ISS

Default cCondPgto   := ""
Default cFormaPg	:= ""
Default nVlrTotISS  := 0

If cPaisLoc == "BRA"
	
	If FunName() == "LOJA220"
		cBCliente := cCliente
		cBLoja    := cLojaCli
	ElseIf FunName() $ "LOJA701|FATA701" .AND. Type("M->LQ_CLIENTE") <> "U"
		cBCliente := M->LQ_CLIENTE 
		cBLoja    := M->LQ_LOJA
		If Empty(cCondPgto) .And. Type("M->LQ_CONDPG") <> "U"
			cCondPgto  := M->LQ_CONDPG //Condicao de Pagamento informada na tela de Venda
		EndIf
	ElseIf FunName() == "LOJA020"
		cBCliente := SL1->L1_CLIENTE
		cBLoja    := SL1->L1_LOJA
	Else
		Return .F.
	EndIf
	
	SA1->(DBSetOrder(1))                             
	If xFilial("SA1")+cBCliente+cBLoja <> SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA //Apenas executa o Seek caso ainda nao estiver posicionado no Cliente na tabela SA1
		SA1->(DbSeek(xFilial("SA1") + cBCliente + cBLoja) )
	EndIf
	
	If SA1->A1_FRETISS == "1" //Forma de retencao de ISS (1=Cons Vlr Minimo; 2=Sempre Retem) 
		//Verifica se o valor total do ISS eh maior que o valor minimo para dispensa de retencao de ISS
		If nMinRetISS > 0 .And. nVlrTotISS > 0
			lRet := nVlrTotISS > nMinRetISS
		EndIf
	EndIf
	
	If lRet
		lRet := Iif(FindFunction('lj7RecISS'),Lj7recIss(),SA1->A1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.))
	EndIf 
Else
	lRet := .F.
EndIf 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LjxDImpZero    ³ Autor ³Vendas Clientes     ³ Data ³ 02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o TES possui imposto com aliquota 0%             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjxDImpZero (aTesImpInf)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJXFUND                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDImpZero(aTesImpInf)
Local lRet  := .F.					// Retorno da funcao
Local nX	:= 0					// Contador							

For nX := 1 to Len(aTesImpInf)
   SFB->(DbSetOrder(1))
   If SFB->(DbSeek(xFilial("SFB")+aTesImpInf[nX][1]))
      If lRet := SFB->FB_ALIQ == 0
         Exit
      EndIf   
   EndIf
Next nX

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjxDSer   ³ Autor ³ Vendas Clientes       ³ Data ³ 25.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia de Localizacao / Numero de Serial              ³±±
±±³          ³utilizado na consistencia do L2_Nserie                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±                                     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDSer()
Local cProduto   := ""
Local cTes       := ""
Local nQtdVen    := 0
Local cLocal     := ""
Local cLoteCtl   := ""
Local cNlote     := ""
Local cLocaliza  := ""
Local nPosSerial := 0
Local ii         := 0
Local cProcName  := UPPER(ALLTRIM(ProcName(ii)))
Local cNSerie    := M->L2_NSERIE
Local ny, w1
Local lRet       := .T.
Local nX					//Controle de Loop
Local lDeletados			//Verifica se item esta deletado no aCols.

For ny := 1 to Len(aHeader)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta chave do registro. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Trim(aHeader[ny][2]) == "L2_PRODUTO"
		cProduto := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_QUANT"
		nQtdVen  := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_TES"
		cTES  := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_LOCAL"
		cLocal   := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_LOTECTL"
		cLoteCtl := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_NLOTE"
		cNLote   := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_LOCALIZ"
		cLocaliza := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_NSERIE"
		nPosSerial:=ny
	EndIf
Next nY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A rotina abaixo apenas verifica na pilha de chamda se estamos          ³
//³ utilizando o "LJ010ATE" pois esta rotina e chamada em todos os momemtos³
//³ da venda e devolucao. A nao ser no caso em que a serial devolvida      ³
//³ venha a perterncer a outra loja, neste caso pode ser qualquer numero de³
//³ serie e localizacao existente.                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Empty(cProcName)
	If cProcName $ "LJ010ATE"
		Exit
	Else
		ii++
		cProcName := UPPER(AllTrim(ProcName(ii)))
	Endif
End

do case
	case acols[n][(len(aHeader)+1)]
		lRet = .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Caso o parametro MV_LOCALIZ (localiza) estiver Sim |
	//³	entende-se que trabalha com o conceito			   ³
	//³	de Localizacao.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Case !localiza(cProduto)                        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Legislacao El Salvador:                     ³
		//³Na mesma venda, nao repete o numero de serie³
		//³ja registrado no aCols                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If cPaisLoc == "SAL" .AND. SB1->(FieldPos("B1_CONTSER")) > 0
			If !Empty(cNSerie) 
				If SB1->B1_CONTSER == "1"
					For nX := 1 TO Len(aCols)    // Serial ja utilizaca
						lDeletados := aCols[nX][(Len(aHeader)+1)]
						If !(lDeletados) .AND. (nX <> n)
							If aCols[nX][nPosSerial] == cNSerie   
								//Numero de Serie ja utilizada nesta venda
								MsgAlert(STR0118)
								lRet := .F.
							EndIf                               
						EndIf
					Next nX
	            Else
					M->L2_NSERIE:=space(20)
	            EndIf
	        EndIf		
		Else    		
			M->L2_NSERIE:=space(20)           
   		EndIf

	case Empty(cLocal)                                 // Não Esta preenchido
		// "Digitaçäo do Almoxarifado e Obrigatória..."
		MsgAlert(STR0119)
		lRet = .F.
	case !Lj7ValTES(cTes)                            // Tes incorreto
		//A funcao Acima ja traz a mensagem
		//MsgAlert("TES nao permite baixa do estoque...",)
		lRet = .F.
	case ! Empty(cNSerie) .AND. nQtdVen <> 1       // Quantidade = 1
		// "A Quantidade por serial deve ser igual a 1..."
		MsgAlert(STR0120)
		lRet = .F.
	case ! Empty(cNSerie)
		for w1 = 1 to len(aCols)    // Serial ja utilizaca
			lDeletados := acols[w1][(len(aHeader)+1)]
			If !(lDeletados) .AND. (w1 <> n)
				If aCols[w1][nPosSerial] == cNSerie   // Deve validar com relacao aos outros campos
					// esta validacao sobre o mesmo campo causa erro pois o vesmo somente e atualizado apos o valid
					// "Numero de Serial já foi utilizada...em outro item deste mesmo Pedido..."
					MsgAlert(STR0121)
					lRet = .F.
				endif
			endif
		next w1
		
		// Se for Troca de Outra Loja
		If cProcName # "LJ010ATE"
			
			DbSelectArea("SBF")
			DbSetOrder(3)
			If DbSeek(xFilial()+cNSerie)
				// "Serial Pertence a outro Produto da Loja..."
				MsgAlert(STR0122)
				lRet = .F.
			endif
			
		Else	// Caso contrario
			
			DbSelectArea("SBF")
			DbSetOrder(3)
			// Serial esta Disponivel
			If DbSeek(xFilial()+cNSerie)
				do case
					case SBF->BF_PRODUTO  <> cProduto
						// "N£mero de s‚rie pertence a outro produto... Produto: "
						MsgAlert(STR0123+SBF->BF_PRODUTO)
					case SBF->BF_LOCAL    <> cLocal
						// "Rever Localizaçäo do Produto... Local: "
						MsgAlert(STR0124+SBF->BF_LOCAL)
					case SBF->BF_LOCALIZ  <> clocaliza
						// str0103 "Rever Localizaçäo do Produto... Localizaçäo: "
						MsgAlert(STR0125+SBF->BF_LOCALIZ)
					case SBF->BF_NUMLOTE  <> cNLote .AND. Rastro(cProduto, 'S')
						// str0104 "Rever Localizaçäo do Produto... Lote: "
						MsgAlert(STR0126+SBF->BF_NUMLOTE)
					case SBF->BF_LOTECTL  <> cLotectl
						// str0105 "Rever Localizaçäo do Produto... Sub-Lote: "
						MsgAlert(STR0127+SBF->BF_LOTECTL)
				endcase
			Else
				// str0106 "Näo existe este Numero de Serial disponivel p/ uso..."
				MsgAlert(STR0128)
				lRet = .F.
			endif
		EndIf
Endcase

Return (lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjSenSupTEFºAutor  ³Vendas Clientes     º Data ³  27/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se solcita senha para cancelamento TEF, no meio da  º±±
±±º          ³impressao do comprovante TEF.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjSenSupTEF()
Local lSenhaSup := SuperGetMV("MV_LJCSETE",,.F.)			// Defise se solcita senha para cancelar TEF
Local lRet		:= .T.										// Retorno da Funcao
Local cSenhaSup	:= Space(20)								// Senha digitada do supervisor
Local cBitMap	  := "LOGIN"								// Bitmap utilizado na caixa de dialogo
Local oDlgSenha												// Objeto de tela
Local oBmp1													// Objedo de imagem
Local cCaixaAtu	:= cUserName								// Caixa Atual
Local aArea		:= GetArea()								// Guarda a area
Local cCaixaSup	:= ""										// Caixa superior
Local cUserIDOld:= ""

If lSenhaSup

	LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "Parametro MV_LJCSETEF esta habilitado. Usuario: " + cUserName )

	If GetRpoRelease() >= "R5"

		cUserIDOld := __cUserID

		If FWAuthSuper(@cCaixaSup)

			LJSenhaSup( 	cSenhaSup, Nil, @cCaixaSup, Nil, ;
							Nil		 , Nil, .T.	,		.T. )
		Else
			lRet := .F.
		EndIf
                                                                                    
		__cUserID := cUserIDOld
		PswOrder( 2 )
		PswSeek( __cUserID )

	Else

		cCaixaSup := PadR( cCaixaSup, 15, " " )
	                                                                                                
		cTitle := STR0129 		// Autorizacao: Cancelamento TEF
	
		DEFINE DIALOG oDlgSenha TITLE cTitle FROM 20, 20 TO 225,310 PIXEL 
	
			@ 0, 0 BITMAP oBmp1 RESNAME cBitMap oF oDlgSenha SIZE 50,140 NOBORDER WHEN .F. PIXEL
			
			@ 05,55 SAY STR0130	PIXEL						                   // Caixa Atual
			@ 15,55 MSGET cCaixaAtu WHEN .F. PIXEL SIZE 80,08
			
			@ 30,55 SAY STR0131 PIXEL							               // Caixa Superior
			@ 40,55 MSGET oGetSup VAR cCaixaSup WHEN .T. PIXEL SIZE 80,08
			
			@ 55,55 SAY STR0132 PIXEL                                          // Senha Superior
			@ 65,55 MSGET oGetSenha VAR cSenhaSup PASSWORD PIXEL SIZE 40,08 Valid LJSenhaSup( 	cSenhaSup, Nil, @cCaixaSup, Nil, ;
																								Nil		 , Nil, .T. ) .AND. LjConfSup( cCaixaSup, cCaixaAtu )
																								
			
			DEFINE SBUTTON FROM 85,75  TYPE 1 ACTION ( IIF( !lRet .OR. Empty(cSenhaSup), lRet := LJSenhaSup( 	cSenhaSup, Nil, @cCaixaSup, Nil, ;
																												Nil		 , Nil, .T. ), .T. ), ;
																												oDlgSenha:End() ) ENABLE OF oDlgSenha
			DEFINE SBUTTON FROM 85,105 TYPE 2 ACTION { || lRet := .F., oDlgSenha:End() } ENABLE OF oDlgSenha
		
		ACTIVATE MSDIALOG oDlgSenha CENTERED ON INIT ( IIf( Type( "lUsaLeitor" ) == "L" .AND. lUsaLeitor, LeitorFoco( nHdlLeitor, .T. ), NIL ) )
	
		cUserName := cCaixaAtu
	EndIf
Else
	LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', "Parametro MV_LJCSETEF NAO esta habilitado. Usuario: " + cUserName )
EndIf
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjConfSup ºAutor  ³Vendas Clientes     º Data ³  30/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o supperior informado eh o superior do caixa.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 - Indica qual o caixa a ser pesquisado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjConfSup( cCaixaSup, cCaixaAtu )
Local lRet 		:= .F.				// Retorno da funcao
Local nPos1		:= 0				// Posicao do array
Local nPos2 	:= 0				// Posicao da array
Local aUsers    := NIL				// Retorna todos os usuarios   
Local cCodCxSup := ""		        // Codigo do caixa superior informado no parametro cCaixaSup
Local cCodCxSpA := ""               // Codigo do superior do caixa atual (parametro cCaixaAtu)

If GetRpoRelease() >= "R5"
	aUsers := NIL   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³OBTER CODIGO DO USUARIO CAIXA SUPERIOR³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	PswOrder(2)
	If PswSeek (cCaixaSup,.T.)
		cCodCxSup := PswId () 
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³OBTER CODIGO DE CAIXA SUPERIOR DO USUARIO CAIXA ATUAL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	PswOrder(1)   		
	If PswSeek (cCaixaAtu,.T.)
		cCodCxSpA := StrToKArr(PswRet(1)[1][11],"|")[1]
		If cCodCxSup == cCodCxSpA .OR. cCodCxSup == "000000"		
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + ".TXT", "Usuario: " + cCaixaAtu + " Cancelou a transacao TEF. Autorizado por: " + cCaixaSup)
			EndIf
			lRet := .T.			
		Endif			
	EndIf	
	
Else
    aUsers:= AllUsers()			
	nPos1 := aScan(aUsers, { |X|  X[1,2] = cCaixaSup  } )
	nPos2 := aScan(aUsers, { |X|  X[1,2] = cCaixaAtu  } )

	If nPos1 > 0 .AND. nPos2 > 0
		If aUsers[nPos1, 1, 1] $ aUsers[nPos2, 1, 11] .OR. aUsers[nPos1, 1, 1] == "000000"
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + ".TXT", "Usuario: " + cCaixaAtu + " Cancelou a transacao TEF. Autorizado por: " + cCaixaSup)
			EndIf
			lRet := .T.
		EndIf
	EndIf

Endif

Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjxDCGC
Função que valida o retorno do param MV_LJDCCLI, sobre em 
que momento pede o documento

@author  Varejo
@version P11
@since   07/04/2016
@return  aRet - 1=CPF/CNPJ;2=Nome Cliente;3=Endereco		
/*/
//----------------------------------------------------------------
Function LjxDCGC(	cCliente,	cLojaCli,	lDadosInf,	cMensagem,;
 					nValor )
Local aRet			:= {"","",""}
Local cMsgAux		:= ""
Local lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC)
Local cImpFisc		:= ""
Local lMsgFimCup	:= .F. 

Default cMensagem	:= ""
Default lDadosInf	:= .F.
Default nValor		:= 0

If !lDadosInf
	cImpFisc := LjGetStation("IMPFISC")
	
	/*Esses modelos não permitem imprimir no final, 
	via comando do ECF dai mando o CPF nas mensagens*/
	If ("BEMATECH" $ cImpFisc) .Or. ("EPSON" $ cImpFisc)
		lMsgFimCup := .T.
	EndIf
	
	aRet[1]	:= AllTrim(LjxDInfCGC(cCliente, cLojaCli, @lDadosInf,@nValor))
	
	If lMsgFimCup .And. !Empty(aRet[1])
		cMsgAux += STR0405 + aRet[1] + CHR(10) //'CPF/CNPJ:'
	EndIf
	
	If lLjNfPafEcf .Or. LJAnalisaLEG(58)[1] // Lei do RS que obriga a impressao CPF/CNPJ e nome do cliente
		aRet[2]	:= AllTrim(LjRetNomeC())
		aRet[3]	:= AllTrim(LjRetEndCli())
		
		If lMsgFimCup 
			If !Empty(aRet[2])
				cMsgAux += STR0406 + aRet[2] + CHR(10) //'Nome:'
			EndIf
	
			If !Empty(aRet[3])
				cMsgAux += STR0407 + aRet[3] + CHR(10) //'Endereco:'
			EndIf
		EndIf	
	EndIf
	
	If !Empty(cMsgAux)
		cMensagem := cMsgAux + cMensagem
	EndIf
EndIf

Return aRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjxDInfCGC
Tela para informar o CGC do cliente no momento da venda de
acordo com as CATs 52 e 85 do estado de Sao Paulo

@author  Varejo
@version P11
@since   26/10/2007
@return  ExpC1 - CGC do cliente		
/*/
//----------------------------------------------------------------
Function LjxDInfCGC(cCliente, cLojaCli,	lDadosInf, nValor)
Local cRet 			:= ""					// String de Retorno da funcao
Local aRetCli 		:= {}					// Codigo e Loja do cliente
Local cParCgc		:= ""					// Variavel criada para enviar cgc
Local aPlacaCli 	:= {}					// array contendo dados da tabela LEH, utilizado no TPL PCL
Local cPlacaCli		:= ""					// Placa do cliente da venda, utilizado no TPL PCL
Local lContinua		:= .T.					//valida se prossegue na rotina
Local lAchouCli		:= .F.					//Valida se encontrou o cliente
Local lFrtCliON		:= IsInCallStack("FRTA271") .AND. SuperGetMV("MV_LJCLION",,.F.)	//Valida se Usa o Cliente OnLine
Local nConTcLnk		:= 0					//valor da conexão
Local lPeRetCli 	:= .F.
Local aCPFCli		:= {.F.,""}				// Array com o retorno da digitação do CPF

Default lDadosInf	:= .F.
Default cCliente  	:= SuperGetMV("MV_CLIPAD")
Default cLojaCli  	:= SuperGetMV("MV_LOJAPAD")
Default nValor		:= 0

aRetCli := LjxDCliente(cCliente, cLojaCli ,@cRet,@lPeRetCli)

/*
Atenção : ao ter o PE LjRetCli, temos 7 posições:
[1] - Código do cliente 
[2] - Loja do cliente
[3] - CPF/CNPJ 
[4] - Nome do cliente
[5] - Endereco do cliente
[6] - Se usar Template de Combustiveis deve mostrar a placa do carro
[7] - Se usar Template de Combustiveis deve mostrar a kilometragem do carro
*/
If lPeRetCli  //Caso tenha a tela customizada nao solicita mais nada
	lDadosInf := .T.
	lPeRetCli := LjVlPERetC(@aRetCli)
EndIf

//O cliente tem que vir informado - Premissa
If !Empty(aRetCli[1]) .AND. !Empty(aRetCli[2]) .AND. Empty(cRet) .AND. !lPeRetCli
	
	//³Se for cliente padrao³	
	If Alltrim(aRetCli[1]) == Alltrim(SuperGetMV("MV_CLIPAD")) .AND. Alltrim(aRetCli[2]) == Alltrim(SuperGetMV("MV_LOJAPAD"))
		
		//³Executa a tela para perguntar o CGC³		
		cNomeCli := SPACE(TamSX3("A1_NOME")[1])
		cEndCli  := SPACE(TamSX3("A1_END")[1])
		aCPFCli := LjxDTelaCGC(,,,,@nValor )

		If aCPFCli[01]
			cRet := aCPFCli[02]		
		Endif		
		lDadosInf	:= .T.
	Else
		
		//³Caso tenha cliente cadastrado, pega o CGC do cadastro³
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		lAchouCli := SA1->(DbSeek( xFilial("SA1") + aRetCli[1] + aRetCli[2] ))
		
		If lAchouCli .OR. ( !lAchouCli .AND. lFrtCliON )  
		
			//Verifica se está no FRT e se usa cliente on-line para capturar o cliente da mesma forma que acontece no Front sem PAF-ECF
			If	!lAchouCli .AND. lFrtCliON
				If !FRTAABRCON(@nConTcLnk)
					lContinua := .F.
				EndIf
				
				If lContinua
					FRTADEFTAB(Posicione("SX2", 1, "SA1", "AllTrim(X2_ARQUIVO)"), "SA1", nConTcLnk)
					If !SA1->(DbSeek( xFilial("SA1") + aRetCli[1] + aRetCli[2] ))
						lContinua := .F.
					EndIf
				EndIf
			EndIf
			
			If lContinua				
				//³Executa a tela para perguntar o CGC				
				cNomeCli 	:= IF(Empty(SA1->A1_NOME)  	,SPACE(TamSX3("A1_NOME")[1])   ,AllTrim(SA1->A1_NOME))
				cEndCli  	:= IF(Empty(SA1->A1_END)	,;
									IIf(Empty(SA1->A1_ENDENT),SPACE(TamSX3("A1_END")[1]) , AllTrim(SA1->A1_ENDENT)),;
									AllTrim(SA1->A1_END))
	
				cEndCli += IIf(!Empty(cEndCli), IIf(!Empty(AllTrim(SA1->A1_BAIRRO)), " - " + SA1->A1_BAIRRO,""), "" )
	
				cParCgc		:= IF(Empty(SA1->A1_CGC)	,SPACE(TamSX3("A1_CGC")[1])    ,SA1->A1_CGC )
				
				If HasTemplate("PCL") .AND. ExistFunc("T_TpPclPqLEH")	//Função criada pelo UPDPCL04
					aPlacaCli := T_TpPclPqLEH(aRetCli[1] + aRetCli[2])
					If Len(aPlacaCli) > 0
						cPlacaCli := aPlacaCli[2]	//Posicao 2- Placa do veiculo da tabela LEH - Amarracao Placa X Cliente
					EndIf	
				EndIf
					
				aCPFCli := LjxDTelaCGC(cParCgc,cNomeCli,cEndCli,cPlacaCli,@nValor)
				cRet	:= aCPFCli[02]

				lDadosInf	:= .T.
				
				If !lAchouCli .AND. lFrtCliON
					//Finaliza a conexão com a retaguarda
					FRTAFCHCON(nConTcLnk)
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf !Empty(cRet) .And. lPeRetCli		//Se veio do Ponto de Entrada informado
	/* Caso seja Venda Assistida, alimenta variavel de memoria */
	If Type("M->LQ_CGCCLI") <> "U"  
		M->LQ_CGCCLI := cRet
	EndIf
	lDadosInf	:= .T.			//Mudo o status como se tivesse aparecido a tela do CNPJ
EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjRetNomeCºAutor  ³  Vendas Clientes   º Data ³  26/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o retorno do nome do cliente onde a mesma é        º±±
±±º          ³ alimentada em uma variavel estatica.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - Nome do Cliente                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONTLOJA                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjRetNomeC()
Return cNomeCli

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjRetEndCliº Autor³  Vendas Clientes   º Data ³  17/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o retorno do endereco do cliente onde a mesma é    º±±
±±º          ³ alimentada em uma variavel estatica.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - Endereco do Cliente                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONTLOJA                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjRetEndCli()
Return cEndCli

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDTelaCGºAutor  ³  Vendas Clientes   º Data ³  26/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apresenta tela para digitar CGC do cliente                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - CGC do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDTelaCGC( cCgcCli, cNome, cEnd , cPlacaCli , nValor)
Local lCont			:= .F.				// Continua apos digitar CGC
Local oDlg								// Objeto da Tela
Local oCgc								// Objeto para digitar o CGC
Local oNome								// Objeto para digitar o Nome do Cliente
Local oEnd								// Objeto para digitar o Endereço do Cliente
Local oTPanel                           // Cria o Panel para digitacao dos dados
Local oFontText							// Fonte do texto
Local oPlaca							// Objeto para digitar a Placa
Local oKm								// Objeto para digitar a Quilometragem

Local nTamTela		:= 420							// Tamanho padrão da tela
Local nAltBotao		:= 35							// Altura padrão do botão
Local nTamButton	:= {/*Largura*/25,/*Altura*/11}	// Altura e Largura dos botões
Local oTBtOk		:= Nil							// Botao para confirmação
Local oTBtCancel	:= Nil							// Botao para cancelar
local oTBtPinPad	:= Nil							// Botao para chamar o PinPad

Local lUsaPaf		:= LjNfPafEcf(SM0->M0_CGC)		//sinaliza se utiliza PAF-ECF 
Local lAnalLeg58	:= LJAnalisaLEG(58)[1]
Local lLj950ImpCpf	:= ExistFunc("Lj950ImpCpf")
Local lUsaDisplay	:= .F.
Local aCPFCli		:= {.F.,""}	 					// Array com o retorno da digitação do CPF
Local nOpcDigCPF	:= SuperGetMV("MV_LJDGCPF",,1)	// Forma de difitação do CPF - 1 - Pela pela, 2 - Opção Pelo PinPad

Default cCgcCli  	:= SPACE(TamSX3("A1_CGC")[1])
Default cNome    	:= SPACE(TamSX3("A1_NOME")[1])
Default cEnd     	:= SPACE(TamSX3("A1_END")[1])
Default cPlacaCli	:= SPACE(7)						//Nao pega o TamSx3 pois eh um campo do TPL PCL
Default nValor		:= 0

lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

// Verifica se pode habilitar botão para PinPad
If Type("oTef") == "U" .OR. !(oTef:lAtivo) .OR. AllTrim( oAutocom:SIT_VERDLL() ) < "3.4.1.6"
	nOpcDigCPF := 1	
EndIf

aCPFCli[02]	:= cCgcCli

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre tela para digitar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oBold	BOLD
DEFINE FONT oFontText NAME "Courier New" SIZE 09,20

If lLj950ImpCpf
	lLj950ImpCpf := Lj950ImpCpf(nValor)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta Tamanho da Tela e posicao do botao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lUsaPaf .OR.	lAnalLeg58
	nTamTela 	:= 540
	nAltBotao	:= 97
EndIf

If lUsaDisplay
	DisplayEnv(StatDisplay(), "1E" + Substr(Upper(STR0136),1,26))	// "INFORME O CPF / CNPJ PARA IMPRESSÃO"
	DisplayEnv(StatDisplay(), "2E" + Substr(Upper(STR0136),27)+":")	// "INFORME O CPF / CNPJ PARA IMPRESSÃO"
	DisplayEnv(StatDisplay(), "3E" + "|" )     						// Habilitar para digitacao
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"INFORME O CPF / CNPJ PARA IMPRESSÃO"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0136 FROM 323,412 TO nTamTela,738 PIXEL STYLE DS_MODALFRAME STATUS

oTPanel := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,170,060,.T.,.F.)
oTPanel:Align := CONTROL_ALIGN_ALLCLIENT

aCPFCli[01] := .T.
//"Digite abaixo:"
@ 003,007 SAY   STR0200           	SIZE 050, 007 OF oTPanel PIXEL //"CPF/CNPJ"            
@ 010,007 MSGET oCgc  VAR cCgcCli	SIZE 150,10 FONT oFontText OF oTPanel PIXEL
			
If lUsaPaf .OR.	lAnalLeg58
	@ 023,007 SAY   STR0201            SIZE 050, 007 OF oTPanel PIXEL //"Cliente"
	@ 030,007 MSGET oNome VAR cNome    SIZE 150,10 FONT oFontText OF oTPanel PIXEL
	
	@ 043,007 SAY   STR0202            SIZE 050, 007 OF oTPanel PIXEL //"Endereco" 	
	@ 051,007 MSGET oEnd  VAR cEnd     SIZE 150,10 FONT oFontText OF oTPanel PIXEL
	
	//PAF-ECF: Quando template de Posto deve imprimir Placa/Km no Cupom Fiscal 
	If HasTemplate("PCL")
		If Empty(AllTrim(cPlacaCli))
			cPlacaCli := Space(7)
		EndIf
		cPlaca   := cPlacaCli
		cKm	     := SPACE(15) 

		@ 063,007 SAY   STR0247            	SIZE 050, 007 OF oTPanel PIXEL //"Placa:" 	
		@ 071,007 MSGET oPlaca  VAR cPlaca 	SIZE 050,10 FONT oFontText OF oTPanel PIXEL			
		
		@ 063,077 SAY   STR0248            	SIZE 050, 007 OF oTPanel PIXEL //"Quilometragem(KM):" 	
		@ 071,077 MSGET oKm  	VAR cKm		SIZE 050,10 FONT oFontText OF oTPanel PIXEL				
	EndIf				
	
	@ 085,007 SAY   STR0238  SIZE 150, 007 COLOR CLR_RED FONT oBold OF oTPanel PIXEL //"Imprime dados no cupom fiscal?"			
EndIf

oTBtOk := TButton():New( nAltBotao, 104, STR0416,OTPANEL,;
		{|| LCONT := .T. ,IIF(LJXDVALCGC(@CCGCCLI, @oCgc ) .AND. LJXDVACAMP(CCGCCLI, CNOME, CEND, @nValor,.F.),ODLG:END(),NIL) },;
		nTamButton[01], nTamButton[02],,,.F.,.T.,.F.,,.F.,,,.F. ) // "Ok"

If nOpcDigCPF <> 1
	oTBtPinPad := TButton():New( nAltBotao, 074, STR0415,OTPANEL,{|| oTBtPinPad:Disable(), cCgcCli :=  LjDigCPF(@aCPFCli) ,oTBtPinPad:Enable() ,oDlg:Refresh()  }, nTamButton[01], nTamButton[02],,,.F.,.T.,.F.,,.F.,,,.F. ) // "PinPad"
EndIf

If !lLj950ImpCpf
	oTBtCancel := TButton():New( nAltBotao, 134, STR0417,OTPANEL,{|| LCONT := .F. , ODLG:END() }, nTamButton[01], nTamButton[02],,,.F.,.T.,.F.,,.F.,,,.F. ) // "Cancela"
Else
	oTBtCancel := TButton():New( nAltBotao, 134, STR0417,OTPANEL,; 
					{|| LCONT := .T. ,	IIF(LJXDVALCGC(@CCGCCLI, @oCgc ) .AND. LJXDVACAMP(CCGCCLI, CNOME, CEND, @nValor,.T.),ODLG:END(),NIL) },;
			nTamButton[01], nTamButton[02],,,.F.,.T.,.F.,,.F.,,,.F. ) // "Cancela"

	oDlg:LESCCLOSE := !Lj950ImpCpf(nValor)
EndIf						

ACTIVATE MSDIALOG oDlg CENTERED

If lCont
	cCgcCli  := Alltrim(cCgcCli)
	cNomeCli := Alltrim(cNome)
	cEndCli  := Alltrim(cEnd)
Else
	cCgcCli  := ""
	cNomeCli := ""
	cEndCli  := ""
EndIf

/*Caso seja Venda Assistida, alimenta variavel de memoria*/
If Type("M->LQ_CGCCLI") <> "U"
	M->LQ_CGCCLI := cCgcCli
EndIf

aCPFCli[02] := cCgcCli

Return aCPFCli

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDValCGCºAutor  ³  Vendas Clientes   º Data ³  26/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o CGC digitado se existe.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 - CGC do cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 - Retorno da funcao T ou F                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDValCGC(cCgc, oCgc , nValor)
Local lRet 		:= .F.									// Retorno da funcao
Local cVerCgc 	:= cCgc									// CGC do cliente
Local cNumCNPJ  := Space(TamSX3("A1_CGC")[1]) 			//varivel para armazenar o retorno da funcao CGC

Default cCgc 		:= ""

If !Empty(cVerCgc)
	//³Retira caracteres que nao sao usados³
	cVerCgc := StrTran(cVerCgc,".","")
	cVerCgc := StrTran(cVerCgc,"-","")
	cVerCgc := StrTran(cVerCgc,"/","")
	cVerCgc := Alltrim(cVerCgc)
	
	If (Len(cVerCgc) == 11 .OR. Len(cVerCgc) == 14 ) .AND. !LjVldNumRep(cVerCgc)		
		//³Valida se o CGC digitado eh valido³
		If CGC(cVerCgc, @cNumCNPJ)
			lRet := .T.
			cCgc := cVerCgc
		Else
			lRet := .F.
			cCgc := Space(18)
		EndIf
	Else
		If Empty(LjGetStation("DISPLAY"))
			MsgStop( STR0139 + " - " + cVerCgc ) 		// "CPF/CNPJ inválido!"
		Endif
		cCgc := Space(18)
	EndIf	
Else
	//³Se estiver em branco, valida a insercao³	
	lRet := .T.
EndIf

If !Empty(LjGetStation("DISPLAY"))

	If !lRet
	
		DisplayEnv(StatDisplay(), "1C" + Upper(STR0139) )	// "CPF/CNPJ inválido!"
		DisplayEnv(StatDisplay(), "2C" + STR0395 )     //
		
		MsgInfo(STR0139 + CRLF + STR0395, STR0200 )		// "CPF/CNPJ inválido!" ### "<ENTER> para continuar" ### "CPF/CNPJ" 
	
		DisplayEnv(StatDisplay(), "1E" + Substr(Upper(STR0136),1,26))	// "INFORME O CPF / CNPJ PARA IMPRESSÃO"
		DisplayEnv(StatDisplay(), "2E" + Substr(Upper(STR0136),27)+":")	// "INFORME O CPF / CNPJ PARA IMPRESSÃO"
		DisplayEnv(StatDisplay(), "3E" + "|" )     						// Habilitar para digitacao
		
		// Deixar o campo com foco para o usuario digitar novamente no teclado com display
		oCgc:SetFocus()

	EndIf

EndIf

Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDClientºAutor  ³  Vendas Clientes   º Data ³  26/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alimenta variaveis de Cliente e Loja, dependendo da interf.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpA1 - Array com [1] Codigo do Cliente - [2] Loja         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjxDCliente(cCliente, cLojaCli,cRet,lPeRetCli)
Local aRet 		:= {"","",""}		// Array com o retorno do cliente e loja
Local aRetPE 	:= {}				// Retorno do ponto de entrada
Local lFtvdVer12:= ExistFunc("LjFTvd") .AND. LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local cProg		:= Iif(lFtvdVer12,"FATA701|FATA720","LOJA701|LOJA720") //Verifica nome da rotina

//³Sendo Venda Assistida, alimenta as variaveis³
If	Alltrim(FunName()) $ cProg 
	// Quando Orcamento com "RETIRA POSTERIOR", neste ponto ainda nao carregou as variaveis de memoria
	If Type("M->LQ_CLIENTE") <> "U"
		aRet[1] := M->LQ_CLIENTE
		aRet[2] := M->LQ_LOJA
	Else
		aRet[1] := cCliente
		aRet[2] := cLojaCli		
	Endif	
//³Sendo Front Loja, verifica o posicionado do SL1³
ElseIf 	AllTrim(FunName()) == "FRTA010" 
	aRet[1] := SL1->L1_CLIENTE
	aRet[2] := SL1->L1_LOJA
ElseIf	AllTrim(FunName()) == "FRTA271" 
	aRet[1] := cCliente
	aRet[2] := cLojaCli
EndIf

//Caso exista customizacao utilizando alguma internace de Venda,
//necessario que retorne o cliente e loja pelo Ponto de Entrada LJRETCLI.
If ExistBlock( "LJRETCLI" ) .AND. !lFtvdVer12
	aRetPE := ExecBlock( "LJRETCLI",.F.,.F. )
	If ValType(aRetPE) == "A"
		aRet[1] := aRetPE[1]
		aRet[2] := aRetPE[2]
		If Len(aRetPE) > 2
			cRet 		:= aRetPE[3]
			lPeRetCli 	:= aRetPE[4]
		EndIf

		If Len(aRetPE) > 4
			Aadd(aRet,aRetPE[5])
			Aadd(aRet,aRetPE[6])
			Aadd(aRet,aRetPE[7])
			Aadd(aRet,aRetPE[8])
		EndIf		
	EndIf
EndIf

If ExistBlock( "FTVDRETCLI" ) .AND. lFtvdVer12
	aRetPE := ExecBlock( "FTVDRETCLI",.F.,.F. )
	If ValType(aRetPE) == "A"
		If Len(aRetPE) == 2
			If ValType(aRet[1])== "C" .AND. ValType(aRet[2])== "C"
				aRet[1] := aRetPE[1]
				aRet[2] := aRetPE[2]
			EndIf
		EndIf
	EndIf
EndIf

Return aRet

//----------------------------------------------------------------
/*/{Protheus.doc} LjVlPERetC
Validação do PE LjRetCli
@param	 aRetCli , array , contem as informações retornadas do PE LjRetCli
@return	 lRet, lógico , retorno das validações
@author  Varejo
@version P11.8
@since   25/10/2016
/*/
//------------------------------------------------------------------
Static Function LjVlPERetC(aRetCli)
Local lRet := .T.

If Len(aRetCli) > 3
	cNomeCli:= aRetCli[4]
	cEndCli	:= aRetCli[5]

	If HasTemplate("PCL") .AND. ExistTemplate("TpPclPqLEH")
		cPlaca := aRetCli[6]
		cKm	   := aRetCli[7]
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³LjInfoKit ³ Autor ³ Vendas Clientes       ³ Data ³ 26/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o produto informado e' um KIT, em caso         ³±± 
±±³          ³ afirmativo, registras os itens atrelados ao KIT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjInfoKit(cCodProd, lItemImp)
Local aItensKit  := {}										//Array com os produtos do kit (acessorios)
Local nPProd     := 0 										//Posicao do Codigo do produto                        
Local lExecuta	 := .F.										//Indica se sera' ou nao realizado o processamento		
Local xRet		 											//Retorno da funcao		
Local lParm		 := .F.										//Parametro a ser utilizado na funcao LjSB1SLK()
Local lMV_LOJKIT := SuperGetMV("MV_LOJKIT", ,.F.)			//Para,etro que indica se ira' utilizar ou nao o Kit de produtos

Local lL2IGarItem	:= .F.			
Local nItGar		:= 0
Local nGar			:= 0
Local nItem			:= 0 // item da acols que sera usado para busca do kit..nao pode ser o item garantia, geralmente é item que esta sendo inserido 
Local lItGarantia	:= .F.
Local nPosItem		:= 0
  
Default lItemImp := .F.										//Indica se o item pertence a um orcamento importado

If nModulo == 12 .OR. nModulo == 5
	lL2IGarItem := SLR->(ColumnPos("LR_ITEMGAR")) > 0
	nItGar := iIf(lL2IGarItem, aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_ITEMGAR"}) ,0)
	nGar	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_GARANT"})
	nItem	:= Len(aCols)
	lItGarantia := (nItem > 1 .AND. nItGar > 0 .AND. nGar > 0 ) .AND. ( Alltrim(aCols[nItem][nItGar]) <> ""  .AND. Alltrim(aCols[nItem][nGar]) == "" )
	nPosItem := iIf(lL2IGarItem, aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_ITEM"}) ,0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializando as variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Tratamento para Garantia + acessorio
	If lItGarantia 	// este produto eh garantia
		If nItem > 99 
			nItem := Ascan(acols,{|X| x[nPosItem] == aCols[nItem][nItGar] })  // pega o item que eh garantia, e nao o item garantia , valor de item = 9A ou >
		Else
			nItem := Val(aCols[nItem][nItGar])   // pega o item que eh garantia, e nao o item garantia 
		EndIf			
	EndIf
	
	xRet    := .T.
	nPProd  := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_PRODUTO"})	//Posicao do Codigo do produto                        
	lParm   := .F. 

	If "LR_PRODUTO" $ ReadVar()
		If lItGarantia
			cProduto := aCols[nItem][nPProd]  // pega o item que a garantia e nao o item garantia
		Else
			cProduto := &(ReadVar())
		EndIf	
	Else
		cProduto := aCols[nItem][nPProd] 
	Endif

Else                                                   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializando as variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet	 := {} 
	nPProd   := 0
	cProduto := cCodProd
	lParm    := .T.
Endif

If lMV_LOJKIT
	lExecuta := LjSB1SLK( @cProduto, NIL, lParm )
	If lExecuta
	
		//verifica o produto pai
		DbSelectArea("SUG")
		SUG->( DbSetOrder(2) )	//UG_FILIAL+UG_PRODUTO
		If SUG->( DbSeek(xFilial("SUG") + cProduto) )
			If nModulo == 23
				Aadd(xRet,{	cProduto,;	//Codigo do Acessorio
							1		})	//Quantidade
			Endif

			//verifica os produtos filhos
			DbSelectArea("SU1")
			SU1->( DbSetOrder(1) )	//U1_FILIAL+U1_CODACE+U1_ACESSOR
			If SU1->( DbSeek(xFilial("SU1") + SUG->UG_CODACE) )
				While SU1->( !Eof() ) .AND. SU1->U1_FILIAL == xFilial("SU1") .AND. SU1->U1_CODACE == SUG->UG_CODACE
					Aadd(aItensKit,{	SU1->U1_ACESSOR	,;	//Codigo do Acessorio
										SU1->U1_QTD		})	//Quantidade
					
					//quando for um item de um orcamento importado, nao carregamos os itens do kit
					If !lItemImp .AND. nModulo == 23
						Aadd(xRet,{	SU1->U1_ACESSOR,;		//Codigo do Acessorio
									SU1->U1_QTD})			//Quantidade
					Endif
					SU1->( DbSkip() )
				End
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para a Venda Assistida, atualiza o aCols³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nModulo == 12 .OR. nModulo == 5
			If Len(aItensKit) > 0
				LjAtuAcols(aItensKit)	
			Endif
		Endif	
	Endif
Endif
Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³LjAtuAcols³ Autor ³ Vendas Clientes       ³ Data ³ 26/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua as atualizacoes no aCols                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Funcao: LjInfoKit()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjAtuAcols (aItensKit,lGarant)
Local nLinha  		:= 0																		// Utilizada como auxiliar no For
Local nColuna 		:= 0 																		// Utilizada como auxiliar no For
Local nAtual  		:= 0																		// Linha atual do aCols
Local cItem   		:= "00"																		// Contem o item que eh mostrado no aCols
Local nPItem  		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_ITEM"})                 // Posição item 
Local nPProd  		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_PRODUTO"})              // Posição Produto
Local nPQtd   		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_QUANT"})                // Posição Quantidade
Local lProdOk 		:= .T.																		// Flag que verifica se o item foi deletado	
Local lVAssConc	 	:= If( !lFiscal,.F.,SuperGetMV("MV_LJVACC",,.F.) )							// Indica se o cliente utiliza a Vda Assistida Concomitante
Local lGE			:= LjUP104ok(nModulo <> 12) 	// Validação do Conceito Garantia Estendida 
Local lSugVen		:= .F.                 														// Utilizada para abrir o form de sugestao de venda
Local lAbaste		:= .F. 						  // Indica que rotina de importação de abastecimento chamou a function
Local lSomaIt		:= .T.						  // Indica se ira somar o item                                         
Local nPVlUnit		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_VRUNIT"})		// Posicao do Valor unitario do item
Local nPVlrItem		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_VLRITEM"}) 	// Posicao do valor do item
Local nPBico		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_BICO"})		// Posicao do Bico de Abastecimanto, mantendo compatibilidade com processo padrão do Bomba20
Local nPLegCod		:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_LEGCOD"})		// Posicao do Codigo(FK) Tabela LEG(Abastecimento)
Local nPLocal  		:= ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOCAL" })	// Posicao do local (armazem)	          
Local nGarant       := 0                                                            // Garantia Estendida
Local lL2IGarItem	:= SLR->(ColumnPos("LR_ITEMGAR")) > 0			// Verifica a existencia do campo L2_VLGAPRO dias de garantia 
Local nPGarItem		:= iIf(lL2IGarItem, aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_ITEMGAR"}) ,0) 
Local lL2ICobItem	:= SLR->(ColumnPos("LR_ITEMCOB")) > 0
Local lL2ICobertu	:= SLR->(ColumnPos("LR_PRDCOBE")) > 0
Local nItCob		:= IIf(lL2ICobItem, aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_ITEMCOB"}) ,0)
Local nCober		:= IIf(lL2ICobertu, aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_PRDCOBE"}) ,0)
Local lSFinanc    	:= SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
Local nItemCob		:= Len(aCols)
Local cMvLjTGar		:= SuperGetMV("MV_LJTPGAR",,"GE")											// Se trabalha com GE
Local cMvLjTSf   	:= SuperGetMV("MV_LJTPSF",,"SF")											// Define se é tipo SF
Local aAreaSA1 := SA1->(GetArea())

Default lGarant     := .F.

If lGE
	If aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_GARANT"}) > 0  				            // Posição Garantia > 0
		nGarant	:= aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LR_GARANT"})
	EndIf
EndIf

nAtual := Len( aCols )

If HasTemplate("PCL") .AND. IsInCallStack("TpPclVaLeg")
	lAbaste	:= .T.
EndIf

//Verifica se aCols atual foi alimentado
If lAbaste .AND. (nAtual == 1) .AND. Empty(aCols[nAtual][nPProd])
	lSomaIt := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o conteudo o ultimo item (Valor)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSomaIt
	cItem := aCols[nAtual][nPItem]
EndIf

For nLinha := 1 to Len( aItensKit )
	DbSelectArea( "SB1" )
	SB1->(DbSetOrder( 1 ))
	If SB1->(DbSeek( xFilial( "SB1" ) + aItensKit[nLinha][1] ))
		If lProdOk 		
    	    
    	    //Não adiciona quando item atual em branco, Rotina de Kit obriga que o item seja preenchido
			If lSomaIt
				nAtual ++
				AADD(aCols,Array( Len( aHeader ) + 1 ) )              
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³x3_titulo   1³
			//³x3_campo    2³
			//³x3_picture  3³
			//³x3_tamanho  4³
			//³x3_decimal  5³
			//³x3_valid    6³
			//³x3_usado    7³
			//³x3_tipo     8³
			//³x3_arquivo  9³
			//³x3_context 10³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³Inicializa as variaveis da aCols (tratamento para    ³
		    //³campos criados pelo usu rio)							³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        For nColuna := 1 TO Len( aHeader )
	        
		       If aHeader[nColuna][8]		== "C"
	 	 	      aCols[nAtual][nColuna]	:= SPACE(aHeader[nColuna][4])
	
	 		   ElseIf aHeader[nColuna][8]	== "D" 
			      aCols[nAtual][nColuna]	:= dDataBase
	
			   ElseIf aHeader[nColuna][8]	== "M"
			      aCols[nAtual][nColuna]	:= ""
	
			   ElseIf aHeader[nColuna][8]	== "N"
			  	   aCols[nAtual][nColuna]	:= 0
	
			   Else
			      aCols[nAtual][nColuna]	:= .F.	  
			   Endif
			   
		  	Next nColuna
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza a variavel Item do aCols³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cItem					:= Soma1( cItem )
			aCols[nAtual][nPItem]	:= cItem
        Endif
		
		aCols[nAtual][Len( aHeader )+1] := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o aCols com o codigo do acessorio e a quantidade inicial para os calculos fiscais         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->LR_PRODUTO			:= aItensKit[nLinha][1]
		aCols[nAtual][nPProd]	:= aItensKit[nLinha][1]

		M->LR_QUANT				:= aItensKit[nLinha][2]
		aCols[nAtual][nPQtd]	:= aItensKit[nLinha][2]
		
		//Para manter o padrao da rotina Bomba20, alimenta valores da mesma forma que eh realizado quando geral SL1/Sl2 no Bomba20 Local
		If lAbaste		           
			M->LR_VRUNIT			:= aItensKit[nLinha][3]
			aCols[nAtual][nPVlUnit]	:= aItensKit[nLinha][3]
		
			M->LR_VLRITEM			:= aItensKit[nLinha][4]
			aCols[nAtual][nPVlrItem]:= aItensKit[nLinha][4]		
			//Armazena Bico mantendo compatibilidade do Job Bomba20
			M->LR_BICO				:= aItensKit[nLinha][5]
			aCols[nAtual][nPBico]	:= aItensKit[nLinha][5]		
            //Armazena Bico na L1
			M->LQ_BICO 				:= aItensKit[nLinha][5]			
			
			M->LR_LEGCOD			:= aItensKit[nLinha][6]
			aCols[nAtual][nPLegCod]	:= aItensKit[nLinha][6]
			
			M->LR_LOCAL				:= aItensKit[nLinha][7]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for Garantia Estendida Insere dados da Garantia Estendida no Acols    ³                       
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lGE .AND. (nGarant > 0) .AND. lGarant .AND. Posicione("SB1", 1, xFilial("SB1") + aCols[nAtual][nPProd], "B1_TIPO") == cMvLjTGar
			aCols[nAtual][nGarant]	:= Nil
			aCols[nItemCob][nGarant]:= aCols[nAtual][nPProd]

			If nPGarItem > 0 
				aCols[nAtual][nPGarItem]	:= aCols[nItemCob][nPItem]  // Relaciona item garantia com Item produto
				aCols[nItemCob][nPGarItem]	:= aCols[nAtual][nPItem]  // Relaciona item Produto  com Item Garantia
			EndIf	
        EndIf
        
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for Servico Financeiro Insere dados no Acols³                       
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSFinanc
			If Posicione("SB1", 1, xFilial("SB1") + aCols[n][nPProd], "B1_TIPO") <> cMvLjTSf
				nItemCob := n
			EndIf
		 	
		 	If Posicione("SB1", 1, xFilial("SB1") + aCols[nAtual][nPProd], "B1_TIPO") == cMvLjTSf
				aCols[nAtual][nItCob] 	:= aCols[nItemCob][nPItem]
				aCols[nAtual][nCober]	:= aCols[nItemCob][nPProd]
			EndIf										
		EndIf			                                                            
 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizar a variavel n, pois as funcoes fiscais usam ela como referencia                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		n := nAtual
        lSugVen             := IIF(Len(aItensKit) > 0,.F.,.T.)
		
		RestArea(aAreaSA1)
		// Executa funcao padrao para incluir ou alterar o produto
		If !Lj7Prod( .T.,,,,lSugVen,,,,.T. )
			If ValType(lVAssConc)=="L" .AND. lVAssConc 
				aCols[nAtual][nPProd] := aItensKit[nLinha][1]
				aCols[nAtual][nPQtd]  := aItensKit[nLinha][2]
			EndIf		 
			If Lj7ValDel()
				lProdOk := .F.
				aCols[nAtual][Len( aHeader )+1]	:= .T.
			EndIf
		Else
			lProdOk := .T.
			//Atualiza Local/Armazém
			If lAbaste
				aColsDet[nAtual][aPosCpoDet[nPLocal][2]] := aItensKit[nLinha][7]
			EndIf
		EndIf			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizar a variavel n, pois a funcao LJ7Prod() e' chamada automaticamente como sendo a ultima     ³
		//³validacao a ser realizada no produto digitado                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		n := nAtual
	Endif
		
Next nLinha

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LjVldKIT  ³ Autor ³ Vendas Clientes       ³ Data ³ 26/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida se o produto digitado e' um KIT                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Funcao: Lj7MontaGD)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVldKIT()
Local cProduto := ""	//Codigo do produto
Local lRet     := .T.	//Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializando as variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "LR_PRODUTO" $ ReadVar()
	cProduto := &(ReadVar())
Else
	cProduto := aCols[n][nPosProd]
Endif

lRet := LjSB1SLK( @cProduto, NIL, .F. )

If lRet
	DbSelectArea("SUG")
	DbSetOrder(2)
	If DbSeek(xFilial("SUG")+cProduto)
		If Len(aCols) > n 
			MsgInfo(STR0138)//"O Produto informado é um Kit. Para incluir um Kit, inclua uma linha em branco e posteriormente informe o código do produto"
			lRet := .F.
		EndIf      
	Endif	
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDSelNCCºAutor  ³Venda Clientes      º Data ³  03/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se no determinado endereco possui diversas se'ries º±±
±±º          ³para montar uma tela de escolha, existindo apenas um        º±±
±±º          ³faz o preenchimento do campo se'rie automata'co.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Serie do produto                                   º±±
±±º          ³ ExpC2 - Armazem (Local) em que o produto foi vendido       º±±
±±º          ³ ExpC3 - Endereço selecionado		                          º±±
±±º          ³ ExpN4 - Produto Selecionado                                º±±
±±º          ³ aInutil - Mantido apenas por compatibilização              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºRetorno   ³ Nulo                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDSelNCC( aNCCItens	,	cModCall,	nVTotFrt,	nNCCSel ,;
					 aInutil	,	nOpc	,	lMdjMdk )
Local oNCCWindow:= NIL								// Objetos de telas
Local oFntNCC										// Objetos de telas
Local oFntNCCL										// Objetos de telas
Local oNCCUsada										// Objeto da NCC Usada
Local oNCC											// Objeto da NCC
Local oOk       := LoadBitmap( GetResources(), "LBOK" )		// Objeto do botao OK
Local oNo       := LoadBitmap( GetResources(), "LBNO" )		// Objeto do botao cancela
Local nVlrParc	:= 0 								// Valor das parcelas
Local lLJ7038   := ExistBlock("LJ7038")							// Ponto de entrada para validar a tela de selecao de NCC
Local lFtvd7038 := ExistBlock("FTVD7038")						// Ponto de entrada para validar a tela de selecao de NCC
Local lAddNCC	:= SuperGetMv("MV_LJLOCNC",,.F.)   // Indica se utiliza funcionalidade para adicionar NCC no momento da Venda
Local oPrefixo										// Objetos de telas
Local oNumero										// Objetos de telas
Local cPrefixo 	:= Space(TamSx3("E1_PREFIXO")[1])  //Prefixo do Título de Crédito 
Local cNumero 	:= Space(TamSx3("E1_NUM")[1])      //Nıunero do Tìtulo de Crèdito
Local aNCCUse	:= {}                              // Array utilizado para montar a tela de Créditos 
Local nX		:= 0                               // Variavél utilizado para montagem dos Arrays
Local oBtn		:= Nil 								// Objetos de telas
Local nAction	:= 0 								// Variavel utilizada para definir validação e 
Local nPos		:= 0								// Variavel utilizada para identificar posicao do Array
Local lFtvdVer12:= LjFTVD() 						//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local lFTVD7026 := ExistBlock("FTVD7026")				// Ponto de entrada para selecao de NCC
Local lLj7026	:= ExistBlock("LJ7026")					// Ponto de entrada para selecao de NCC
Local aKey		:= {}
Local lLjNCCOr	:= SuperGetMv("MV_LJNCCOR", Nil, .F.)  //verifica se a NCC sera mantida no orcamento (F4)
Local aPgtoEx	:= {}
Local aNCCItAux := aNCCItens
Local nNCCSelAux:= 0
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)  
Local lPBMDesc	:= ExistTemplate("DroPbmDe") .AND. T_DroPbmDe()
Local nMV_LJMTSN:= SuperGetMV("MV_LJMTSN",NIL,1) 	//Valida se a tela de seleção de NCC será apresentada  

Default cModCall 	:= "LOJ"
Default aNCCItens 	:= {}
Default nVTotFrt 	:= 0 
Default nNCCSel  	:= 0    
Default nOpc 		:= 0
Default lMdjMdk		:= .F. //Seleciona NCC de acordo com o parametro lLjNCCOr advindo do LOJA701B

//Desabilita as teclas de atalho
If nModulo ==  12 .or. nModulo ==  5
	Lj7SetKeys(.F.)
Else 
	aKey := FRTSetKey()
EndIf

If cModCall == "FRT"
	nVlrTotal := nVTotFrt
Else
	nVlrTotal := Lj7T_Total(2)
EndIf

If Len(aNCCItens) > 0 
	Aadd(aNCCUse, Array(Len(aNCCItens[1])))
	For nX:=1 to Len(aNCCItens[1])
	
		If ValType(aNCCItens[1][nX]) == "L"
			aNCCUse[1][nX] := .F. 			
		Elseif ValType(aNCCItens[1][nX]) == "N"	
			aNCCUse[1][nX] := 	0				
		Elseif ValType(aNCCItens[1][nX]) == "C"			
			aNCCUse[1][nX] := 	""				
		Elseif ValType(aNCCItens[1][nX]) == "D"			
			aNCCUse[1][nX] := CTOD("")							     
        Endif
	Next nX 

	//Tratamento necessário pois a variavel não é private no FronLoja neste momento de seleção de NCC
	If nModulo == 23 .And. Type("aPgtos") <> "A"
		aPgtos := {{ Ctod("  /  /  "), 0 , "" , "", "", "", "", "", "", .F., 1, Space(04), 0 ,"" }}
	EndIf

	// Verifica o valor das parcelas que ja foram informadas. Nao permite
	// selecionar uma NCC que somando com as parcelas exceda o valor da venda
	nVlrParc := 0
	If cPaisLoc == "BRA"
	   aEval( aPgtos, {|x| nVlrParc += x[2] } )
    Else 
		aEval( aPgtos, {|x| nVlrParc += Round(xMoeda(x[2],x[6],nMoedaCor,dDatabase,nDecimais+1,,nTxMoeda),nDecimais)})
    EndIf
   
    LjGrvLog( NIL, "Parâmetro MV_LJLOCNC ", lAddNCC)
    LjGrvLog( NIL, "Parâmetro MV_LJNCCOR ", lLjNCCOr)
    LjGrvLog( NIL, "Parâmetro MV_LJMTSN ", nMV_LJMTSN)
    LjGrvLog( NIL, "Valor da NCC setada no Orçamento ?", lMdjMdk)
    LjGrvLog( NIL, " Ponto de Entrada Compilado ? (FTVD7026 ou LJ7026)", {lFTVD7026,lLj7026})
        
    //Neste caso, nao abre a tela para selecionar as NCCs
    If 	lAutomato .Or. ;
    	(lLjNCCOr .And. !lAddNCC .And. (nOpc == 4) .And. (cModCall == "LOJ") .And. (nMV_LJMTSN == 0) .AND. ( !Empty(aPgtos[1][3]) .Or. lFTVD7026 .Or. lLj7026 ) )
		
		// Somente seta o array inteiro quando existir o P.E. ou Teste Automatizado
		// pois no padrão se já existir NCC selecionada, a NCC correta do cliente 
		// já vem setada corretamente nas que foram selecionadas no orçamento
		If lAutomato .Or. lFTVD7026 .Or. lLj7026
			For nX := 1 To Len(aNCCItens)
				aNCCItens[nX][1] := .T.
				If lAutomato .Or. !lMdjMdk
					nNCCSel += aNCCItens[nX][2]
				EndIf
			Next nX
		EndIf
			
		If !lAutomato .And. (lMdjMdk .Or. lFTVD7026 .Or. lLj7026)
		
			aEval(aNCCItens,{|x| nNCCSel    += If(x[1],x[2],0)})
	   		aEval(aNCCItAux,{|x| nNCCSelAux += If(x[1],x[2],0)})
	   		
            IF nNCCSel == 0 .Or. ((nNCCSel > 0) .And. (nNCCSelAux <> nNCCSel))
             	LjLimpaMDJ(nNCCSelAux)
            EndIf
		EndIf
		
		LjGrvLog ( NIL, " Valor setado das NCCs selecionadas ",nNCCSel)
		
		If !lAutomato
			LjGrvLog( NIL, " Valor de NCC pré-selecionada no orçamento descontado automaticamente "+;
							"para a venda e a tela não será exibida. ", aNCCItens)
		EndIf
	Else
		If lAddNCC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a tela para selecao das notas de credito                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oNCCWindow TITLE STR0141 FROM 10,15 TO 350,580 OF GetWndDEFAULT() PIXEL //"Créditos em aberto"
		
				DEFINE FONT oFntNCC  NAME "Ms Sans Serif" BOLD
				DEFINE FONT oFntNCCL NAME "Arial" SIZE 15,20 BOLD
				
				@ 10,02 Say RetTitle("E1_PREFIXO")	OF oNCCWindow SIZE 40,9 PIXEL
				@ 10,40 Say RetTitle("E1_NUM") 		OF oNCCWindow SIZE 40,9 PIXEL			
				@ 20,02 MSGET oPrefixo VAR cPrefixo OF oNCCWindow  SIZE 25,9 PIXEL
				@ 20,40 MSGET oNumero  VAR cNumero  VALID ( If( LjAddNcc(@cPrefixo,@cNumero,@aNCCUse,aNCCItens,@nNCCSel),;
															(oNCC:Refresh(),oNCCUsada:Refresh()),Nil)) OF oNCCWindow  	SIZE 50,9 PIXEL			
				
				oBtn := TBtnBmp2():New( 35,200,26,26,'pmssetabot',,,,{||},oNCCWindow,STR0261,,.T. )  //Informe o Prefixo e Número do título de crédito para utiliza-lo na venda.
		
				@ 138,02 TO 159,132 LABEL STR0142 OF oNCCWindow PIXEL //"Total selecionado"
				@ 146,30 SAY oNCCUsada VAR nNCCSel   SIZE 99,10 PIXEL OF oNCCWindow PICTURE PesqPict("SE1","E1_SALDO") RIGHT COLOR CLR_HRED Font oFntNCCL
		
		        If cPaisLoc == "BRA"
				   @ 40,2 LISTBOX oNCC FIELDS HEADER "",STR0143,RetTitle("E1_PREFIXO"),STR0144,STR0145 FIELDSIZES 14, 40,20, 30, 40 SIZE 280,90  PIXEL OF oNCCWindow //"Valor"###"Número"###"Emissão"
		 		Else
				   @ 40,2 LISTBOX oNCC FIELDS HEADER "",STR0146,RetTitle("E1_PREFIXO"),STR0144,STR0145,STR0147,RetTitle("E1_MOEDA") ;
				   FIELDSIZES 14, 45, 20,30, 30, 40, 40 SIZE 280,90  PIXEL OF oNCCWindow //"Vlr. Moeda Venda"###"Valor"###"Número"###"Valor Orig."###"Emissão"###"Moeda Orig."    			
				EndIf   
				
				oNCC:SetArray(aNCCUse)
				
				oNCC:bLDblClick := { || If((!aNCCUse[oNCC:nAt,1].AND.nVlrParc<=nVlrTotal).OR.aNCCUse[oNCC:nAt,1],(aNCCUse[oNCC:nAt,1] := ! aNCCUse[oNCC:nAt,1]),),;
										nNCCSel   := 0,;
										If(nVlrParc <= nVlrTotal, aEval(aNCCUse,{|x| nNCCSel   += If(x[1],x[2],0)}), MsgStop(STR0148)) ,; //"Essa NCC não poderá ser selecionada pois a somatória das parcelas já atingiu o valor da venda, verifique as parcelas de pagamento" 
										oNCCUsada:Refresh() }
			    If cPaisLoc == "BRA"									
					oNCC:bLine := { || {If(aNCCUse[oNCC:nAt,1],oOk,oNo),;
										   Transform(aNCCUse[oNCC:nAt,2],PesqPict("SE1","E1_SALDO")),;
										   aNCCUse[oNCC:nAt,9],;
										   aNCCUse[oNCC:nAt,3],;
										   aNCCUse[oNCC:nAt,4]}}
	
		   		Else
					oNCC:bLine := { || {If(aNCCUse[oNCC:nAt,1],oOk,oNo),;
										   Transform(aNCCUse[oNCC:nAt,2],PesqPict("SE1","E1_SALDO")),;
										   aNCCUse[oNCC:nAt,9],;
										   aNCCUse[oNCC:nAt,3],;               
										   aNCCUse[oNCC:nAt,4],;
										   Transform(aNCCUse[oNCC:nAt,6],PesqPict("SE1","E1_SALDO")),;								               
							               aNCCUse[ oNcc:nAt ][7]}}                                                                               
		   		EndIf								   
		   	
        	DEFINE SBUTTON FROM 145,195 TYPE 1 ACTION ( nAction:=1,oNCCWindow:End()) ENABLE PIXEL OF oNCCWindow
		
			ACTIVATE DIALOG oNCCWindow CENTERED VALID IIf(!lFtvdVer12 .AND. lLJ7038,U_LJ7038(),Iif(lFtvdVer12 .AND. lFtvd7038,U_FTVD7038(),.T.))	
			                                               
			If nAction == 1	
				For nX:=1 to Len(aNCCUse)				
					If ( nPos := aScan( aNccItens, { |x| x[9]+x[3] == aNCCUse[nX][9]+ aNCCUse[nX][3] })) > 0							
						aNccItens[nPos][1]:= aNCCUse[nX][1]
					Endif
				Next nX
			Endif
			
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta a tela para selecao das notas de credito                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oNCCWindow TITLE STR0141 FROM 10,15 TO 270,280 OF GetWndDEFAULT() PIXEL //"Créditos em aberto"
			DEFINE FONT oFntNCC  NAME "Ms Sans Serif" BOLD
			DEFINE FONT oFntNCCL NAME "Arial" SIZE 15,20 BOLD
		
			@ 90,02 TO 111,132 LABEL STR0142 OF oNCCWindow PIXEL //"Total selecionado"
			@ 98,30 SAY oNCCUsada VAR nNCCSel   SIZE 99,10 PIXEL OF oNCCWindow PICTURE PesqPict("SE1","E1_SALDO") RIGHT COLOR CLR_HRED Font oFntNCCL
		    If cPaisLoc == "BRA"
			   @ 2,2 LISTBOX oNCC FIELDS HEADER "",STR0143,STR0144,STR0145 FIELDSIZES 14, 40, 30, 30 SIZE 130,83  PIXEL OF oNCCWindow //"Valor"###"Número"###"Emissão"
		 	Else
				If cPaisLoc$"CHI|COL"
					//³Release 11.5 - Localizacoes ³
					//³Paises:Chile/Colombia-F1CHI ³
					@ 2,2 LISTBOX oNCC FIELDS HEADER "",STR0147,STR0144,STR0145,STR0143,STR0010 ;
					FIELDSIZES 14, 40, 55, 30, 40, 25 SIZE 130,83  PIXEL OF oNCCWindow //"Vlr. Moeda Venda"###"Valor"###"Número"###"Valor Orig."###"Emissão"###"Moeda Orig."    					   
				Else
					@ 2,2 LISTBOX oNCC FIELDS HEADER "",STR0147,STR0143,STR0145,STR0147,STR0010 ;
					FIELDSIZES 14, 40, 55, 30, 40, 25 SIZE 130,83  PIXEL OF oNCCWindow //"Vlr. Moeda Venda"###"Valor"###"Número"###"Valor Orig."###"Emissão"###"Moeda Orig."    			
				EndIf	  
			EndIf   
				
			oNCC:SetArray(aNCCItens)
			oNCC:bLDblClick := { || If((!aNCCItens[oNCC:nAt,1].AND.nVlrParc<=nVlrTotal).OR.aNCCItens[oNCC:nAt,1],(aNCCItens[oNCC:nAt,1] := ! aNCCItens[oNCC:nAt,1]),),;
										nNCCSel   := 0,;
										If(nVlrParc <= nVlrTotal, aEval(aNCCItens,{|x| nNCCSel   += If(x[1],x[2],0)}), MsgStop(STR0148)) ,; //"Essa NCC não poderá ser selecionada pois a somatória das parcelas já atingiu o valor da venda, verifique as parcelas de pagamento" 
										oNCCUsada:Refresh() }
	        If cPaisLoc == "BRA"									
				oNCC:bLine := { || {If(aNCCItens[oNCC:nAt,1],oOk,oNo),;
									   Transform(aNCCItens[oNCC:nAt,2],PesqPict("SE1","E1_SALDO")),;
									   aNCCItens[oNCC:nAt,3],;
									   aNCCItens[oNCC:nAt,4]}}
	   		Else
				oNCC:bLine := { || {If(aNCCItens[oNCC:nAt,1],oOk,oNo),;
									   Transform(aNCCItens[oNCC:nAt,2],PesqPict("SE1","E1_SALDO")),;
									   aNCCItens[oNCC:nAt,3],;
									   aNCCItens[oNCC:nAt,4],;
									   Transform(aNCCItens[oNCC:nAt,6],PesqPict("SE1","E1_SALDO")),;								               
						               aNccItens[ oNcc:nAt ][7]}}
	   		EndIf
		
	   		If lMdjMdk .And. (cModCall == "LOJ")
	   			aEval(aNCCItens,{|x| nNCCSel    += If(x[1],x[2],0)})
	   			aEval(aNCCItAux,{|x| nNCCSelAux += If(x[1],x[2],0)})
	   			DEFINE SBUTTON FROM 115,105 TYPE 1 ACTION (IIF(nNCCSel == 0 .Or. (nNCCSel > 0 .And. nNCCSelAux <> nNCCSel),;
	   														LjLimpaMDJ(nNCCSelAux), .T.), oNCCWindow:End()) ENABLE PIXEL OF oNCCWindow
	   		Else	   		
	   			DEFINE SBUTTON FROM 115,105 TYPE 1 ACTION oNCCWindow:End() ENABLE PIXEL OF oNCCWindow
	   		EndIf
			
			ACTIVATE DIALOG oNCCWindow CENTERED VALID IIf(!lFtvdVer12 .AND. lLJ7038,U_LJ7038(),Iif(lFtvdVer12 .AND. lFtvd7038,U_FTVD7038(),.T.))
			
		Endif 
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                            
	//³tratamento para finalizacao da venda quando selecionado³
	//³a partir de um orcamento, para recuperar a negociação  ³
	//³que foi previamente definida                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModCall == "LOJ"
		If (nNCCSel > 0) .AND. ((nVlrParc + nNCCSel) <> nVlrTotal)
			
			//Valida se foi utilizado PBM
			If !lPBMDesc .AND. ExistFunc("LjVldPbm") .And. LjVldPbm()
				aPgtoEx := {"CO"}
				Lj7ZeraPgtos(,,,aPgtoEx)
			ElseIf (nNCCSel >= nVlrTotal) .Or. (!(nNCCSel >= nVlrTotal) .And.;
			 		nOpc == 4 .And. Empty(M->LQ_CONDPG)) .Or. (nNCCSel >= Lj7T_SubTotal(2))

				Lj7ZeraPgtos()
			EndIf	
			
			If !isBlind()
				oPgtos:SetArray( aPgtos )
				oPgtos:Refresh()
			EndIf
		EndIf
		nNCCUsada := nNCCSel
	EndIf	
EndIf

//Habilita as teclas de atalho , no Front não ha necessidade
If nModulo ==  12 .or. nModulo ==  5
	Lj7SetKeys(.T.)
Else	
	FRTSetKey(aKey)
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjLimpaMDJºVenda  ³ Clientes              º Data ³  05/09/17º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Caso cancelada seleção da NCC é necessario a desamarracao   º±±
±±º          ³das tabelas MDJ e MDK.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºRetorno   ³ Logico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjLimpaMDJ(nNCCSelAux)
Local aAreaMDJ := MDJ->(GetArea())
Local aAreaMDK := MDK->(GetArea())
Local lRet     := .F.
Local lNCCSele := .T.

Default nNCCSelAux := 0

lNCCSele := IIF(nNCCSelAux > 0,(lRet := MsgYesNo( STR0410 + Alltrim(M->LQ_NUM) + STR0411, STR0412 )),.T.) //Deleta os Itens - Ncc Pendente

DbSelectArea("MDJ")
MDJ->(DbSetOrder(3))//MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC

If MDJ->(DbSeek(xFIlial("MDJ") + M->LQ_NUM)) .And. lNCCSele
    DbSelectArea("MDK")
    MDK->( DbSetOrder(2) )  //MDK_FILIAL + MDK_NUMORC
    While MDK->(DbSeek(MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC))
        RecLock("MDK",.F.)
        MDK->( dbDelete() )
        MDK->( MsUnlock() )
    EndDo
                
    RecLock("MDJ",.F.)//Deleta Cabecalho - Ncc Pendente
    MDJ->(dbDelete())
    MDJ->(MsUnlock())
EndIf
    
RestArea(aAreaMDJ)
RestArea(aAreaMDK)
    
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LJTemGeraNOrc ³ Autor ³ Vendas Clientes    ³ Data ³ 24.01.08³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna se a funcao de geração de numero de orcamento e    ´±±
±±³          ³ diferenciada                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aExp1 = Array com os CNPJs autorizados.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGALOJA                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJTemGeraNOrc()
Local lRet     := .F.		//Variavel de Retorno na Funcao
Local cFuncX3  := ""

dbSelectArea("SX3") 
dbSetOrder(2)
If dbSeek("LQ_NUM")
   cFuncX3 := SX3->X3_RELACAO
EndIf

If !Empty(cFuncX3) .AND. "GERANUMORC()" $ UPPER(cFuncX3)
	lRet := .T.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³GeraNumOrc  ³ Autor ³ Vendas Clientes     ³ Data ³ 24.01.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Numero do Orcamento para os Estados que tem      ´±±
±±³          ³ exigencia legal                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aExp1 = Array com os CNPJs autorizados.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraNumOrc()
Local cNumOrc	:= Space(TamSX3("L1_NUM")[1])			//Numero do Orcamento
Local lPegaOrc  := LJAnalisaLeg(37)[1]                //Se existe a legislacao para o Estado

If LjNfPafEcf(SM0->M0_CGC)           
   cNumOrc := GetSxENum("SL1","L1_NUM")
Else   
	If !lPegaOrc
	   cNumOrc := GetSxENum("SL1","L1_NUM")
	EndIf
EndIf

Return cNumOrc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxExcecao  ³ Autor ³ Vendas Clientes     ³ Data ³ 16.12.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna array com as exececoes fiscais cadastradas para o  ´±±
±±³          ³ produto                                                    ³±±
±±³        ³ ATENÇÃO: Essa função é baseada na função MaEXCECAO da Matxfis³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lCancel   - Indica se e uma devolucao                      ³±±
±±³          ³ cAliasTRB - Alias para busca de informacoes sobre a NF     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aExcecao = Array com as excecoes fiscais.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxExcecao(lCancel, cAliasTRB)
Local aArea		:= GetArea()
Local aAreaSF7	:= {}
Local aExcecao	:= {}
Local cGRTrib	:= ""
Local cOrigem	:= ""
Local lClasFis	:= .F.

Default lCancel		:= .F.
Default cAliasTRB	:= "SD2"

// Estrutura do Array aExcecao
// [01] - Aliq. de ICMS Interna
// [02] - Aliq. de ICMS Externa
// [03] - Margem de Lucro Presumida
// [04] - Grupo de Tributacao
// [05] - "S"
// [06] - Aliq. de ICMS Destino
// [07] - Refere-se ao ISS "S/N"
// [08] - Valor do Solidario de Pauta
// [09] - Valor do IPI de Pauta
// [10] - Valor do PIS
// [11] - Valor Cofins
// [12] - Aliquota do PIS
// [13] - Aliquota do Cofins                           
// [14] - Reducao da base de calculo do ICMS 
// [15] - Reducao da base de calculo do IPI 
// [16] - Icms Pauta
// [17] - Aliquota de IPI
// [18] - Reducao da base de calculo do PIS
// [19] - Reducao da base de calculo da COFINS
// [20] - Pauta Produto "S/N"
// [21] - Tab. Natureza da Receita
// [22] - Codigo Natureza da Receita
// [23] - Grupo Natureza da Receita
// [24] - Data Final Nat. Receita
// [25] - Preço Unitário de Cigarro para cálculo da Substituição tributária de Cigarros para PIS e COFINS
// [26] - Reducao da base de calculo do ICMS ST
// [27] - ID do Historico das alteracoes
// [28] - Codigo de Origem
// [29] - Codigo de Situacao Tributaria
// [30] - MVA operação de frete

cGrTrib := SB1->B1_GRTRIB

If !Empty(cGRTrib)
	
	DbSelectArea("SF7")
	aAreaSF7 := SF7->(GetArea())
	
	SF7->(dbSetOrder(1))
	SF7->(DbSeek(xFilial()+cGRTrib+SA1->A1_GRPTRIB))
	
	While ( !SF7->(Eof()) .AND. SF7->F7_FILIAL == xFilial("SF7") .AND.;
		SF7->F7_GRTRIB == cGRTrib .AND. ;
		SF7->F7_GRPCLI == SA1->A1_GRPTRIB )

		lClasFis := Len( Alltrim( (cAliasTRB)->D2_CLASFIS ) ) == 3
		cOrigem  := Iif( lClasFis , SubStr( (cAliasTRB)->D2_CLASFIS,1,1) , SF7->F7_ORIGEM )
		cSitTrib := Iif( lClasFis , SubStr( (cAliasTRB)->D2_CLASFIS,2,2) , SF7->F7_SITTRIB )
		
		If !lCancel .AND. (cAliasTRB)->D2_TIPO == "D" .AND.;
			( SA1->A1_EST == SF7->F7_EST .OR. SF7->F7_EST == "**") .AND. ;
			( SA1->A1_TIPO == SF7->F7_TIPOCLI .OR. SF7->F7_TIPOCLI == "*")
			aadd(aExcecao,SF7->F7_ALIQINT)
			aadd(aExcecao,SF7->F7_ALIQEXT)
			aadd(aExcecao,SF7->F7_MARGEM)
			aadd(aExcecao,SF7->F7_GRTRIB)
			aadd(aExcecao,"S")
			aadd(aExcecao,SF7->F7_ALIQDST)
			aadd(aExcecao,SF7->F7_ISS)
			If cPaisLoc == "BRA"
				aadd(aExcecao,SF7->F7_VLR_ICM)
				aadd(aExcecao,SF7->F7_VLR_IPI)
				aadd(aExcecao,SF7->F7_VLR_PIS)
				aadd(aExcecao,SF7->F7_VLR_COF)				
				aadd(aExcecao,SF7->F7_ALIQPIS)
				aadd(aExcecao,SF7->F7_ALIQCOF)				
				aadd(aExcecao,SF7->F7_BASEICM)
				aadd(aExcecao,SF7->F7_BASEIPI)
				aadd(aExcecao,SF7->F7_VLRICMP)						
				aadd(aExcecao,SF7->F7_ALIQIPI)
				aadd(aExcecao,SF7->F7_REDPIS)
				aadd(aExcecao,SF7->F7_REDCOF)
				aadd(aExcecao,SF7->F7_ICMPAUT)
				aadd(aExcecao,SF7->F7_TNATREC)
				aadd(aExcecao,SF7->F7_CNATREC)
				aadd(aExcecao,SF7->F7_GRUPONC)
				aadd(aExcecao,SF7->F7_DTFIMNT)
				aadd(aExcecao,SF7->F7_PRCUNIC)
				aadd(aExcecao,SF7->F7_BSICMST)
				aadd(aExcecao,SF7->F7_IDHIST)
				aadd(aExcecao,cOrigem )
				aadd(aExcecao,cSitTrib)
				If SF7->(ColumnPos("F7_MVAFRE")) > 0
					aadd(aExcecao,SF7->F7_MVAFRE)
				Else
					aadd(aExcecao,SuperGetMV("MV_MVAFRE",,0))
				EndIf
				aadd(aExcecao,SF7->F7_UFBUSCA)
				aadd(aExcecao,SF7->F7_PAUTFOB)
			Else
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,"")
				aadd(aExcecao,"")
				aadd(aExcecao,"")
				aadd(aExcecao,CToD(""))
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,"")
				aadd(aExcecao,"")
				aadd(aExcecao,"")
				aadd(aExcecao,0)
				aadd(aExcecao,0)
				aadd(aExcecao,0)					
	   		EndIf
		Else
			If (cAliasTRB)->D2_TIPO != "D" .And.;
				( SA1->A1_EST == SF7->F7_EST .OR. SF7->F7_EST == "**") .AND. ;
				( SA1->A1_TIPO == SF7->F7_TIPOCLI .OR. SF7->F7_TIPOCLI == "*")
				aadd(aExcecao,SF7->F7_ALIQINT)
				aadd(aExcecao,SF7->F7_ALIQEXT)
				aadd(aExcecao,SF7->F7_MARGEM)
				aadd(aExcecao,SF7->F7_GRTRIB)
				aadd(aExcecao,"S")
				aadd(aExcecao,SF7->F7_ALIQDST)
				aadd(aExcecao,SF7->F7_ISS)
				If cPaisLoc == "BRA"
					aadd(aExcecao,SF7->F7_VLR_ICM)
					aadd(aExcecao,SF7->F7_VLR_IPI)
					aadd(aExcecao,SF7->F7_VLR_PIS)
					aadd(aExcecao,SF7->F7_VLR_COF)				
					aadd(aExcecao,SF7->F7_ALIQPIS)
					aadd(aExcecao,SF7->F7_ALIQCOF)				
					aadd(aExcecao,SF7->F7_BASEICM)
					aadd(aExcecao,SF7->F7_BASEIPI)
					aadd(aExcecao,SF7->F7_VLRICMP)						
					aadd(aExcecao,SF7->F7_ALIQIPI)
					aadd(aExcecao,SF7->F7_REDPIS)
					aadd(aExcecao,SF7->F7_REDCOF)
					aadd(aExcecao,SF7->F7_ICMPAUT)
					aadd(aExcecao,SF7->F7_TNATREC)
					aadd(aExcecao,SF7->F7_CNATREC)
					aadd(aExcecao,SF7->F7_GRUPONC)
					aadd(aExcecao,SF7->F7_DTFIMNT)
					aadd(aExcecao,SF7->F7_PRCUNIC)
					aadd(aExcecao,SF7->F7_BSICMST)
					aadd(aExcecao,SF7->F7_IDHIST)
					aadd(aExcecao,cOrigem )
					aadd(aExcecao,cSitTrib)
					If SF7->(ColumnPos("F7_MVAFRE")) > 0
						aadd(aExcecao,SF7->F7_MVAFRE)
					Else
						aadd(aExcecao,SuperGetMV("MV_MVAFRE",,0))
					EndIf
					aadd(aExcecao,SF7->F7_UFBUSCA)
					aadd(aExcecao,SF7->F7_PAUTFOB)
		   		Else
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,"")
					aadd(aExcecao,"")
					aadd(aExcecao,"")
					aadd(aExcecao,CToD(""))
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,"")
					aadd(aExcecao,"")
					aadd(aExcecao,"")
					aadd(aExcecao,0)
					aadd(aExcecao,0)
					aadd(aExcecao,0)
				EndIf
				Exit
			EndIf
		EndIf
		SF7->(dbSkip())
	End
EndIf

If Len(aAreaSF7) > 0
	RestArea(aAreaSF7)
EndIf

RestArea(aArea)

Return aExcecao

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxPesqDesc ³ Autor ³ Vendas Clientes     ³ Data ³ 29.01.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa o valor do desconto proporcional rateado aos itens´±±
±±³          ³ quando aplicado desconto no total                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nDesc = Valor do desconto proporcional rateado no item.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxPesqDesc(cAlias2)
Local nDesc := 0

dbSelectArea("SL2")
SL2->(dbSetOrder(3))
SL2->(dbSeek(xFilial()+(cAlias2)->D2_SERIE+(cAlias2)->D2_DOC+(cAlias2)->D2_COD))

While !SL2->(EOF())
	If (cAlias2)->D2_ITEMPV == SL2->L2_ITEM
		nDesc := SL2->L2_DESCPRO
		Exit
	EndIF
	SL2->(dbSkip())
End

Return nDesc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    | LjxPosSA1  ³ Autor ³ Vendas Clientes     ³ Data ³ 03.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Reposiciona a tabela SA1 de acordo com os dados em memoria.³±±
±±³          ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se conseguiu reposicionar.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxPosSA1()

Local lRet := .F.

lRet := SA1->(dbSeek(M->A1_FILIAL+M->A1_COD+M->A1_LOJA))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxMenAbrECF³ Autor ³ Vendas Clientes     ³ Data ³ 25/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre comunicao com a impressora qdo o menu fiscal for      ³±±
±±³          ³ executado pelo menu do protheus.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se conseguiu reposicionar.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxMenAbrECF(cPortaMenu)
Local nRet		:= 0				
Local cImpMenu	:= ""
Local lRet		:= .T.

If Empty(cEstacao)
	Help(" ",1,"NOESTACAO")
	cEstacao := "001"
EndIf

DbSelectArea("SLG")
If !SLG->(DbSeek(xFilial("SLG")+cEstacao))
	Help(" ",1,"NOESTACAO")
	lRet := .F.
EndIf

If lRet
	cImpMenu	:= LjGetStation("IMPFISC")
	cPortaMenu	:= LjGetStation("PORTIF")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abertura da Impressora Fiscal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHdlECF := IFAbrir(cImpMenu, cPortaMenu)
	If nHdlECF == -1
		// "Erro ao conectar com a Impressora Fiscal " ### " na porta ", "Atenção"
		//Mesmo com a mensagem deve permitir acessar sem conexão com o ECF - Exigência Ato Cotepe 01.13
		MsgStop(STR0177 + AllTrim(cImpMenu) + STR0178 +cPortaMenu+".", STR0179)
	EndIf
	
	If lRet
		nRet := IFAbrECF(nHdlECF)
		
		If nRet <> 0
			//no Ato Cotepe 01.13 deve permitir acesso ao sistema mesmo sem comunicação com o ECF
			MsgStop(STR0347,STR0179) //"Sem comunicação com o ECF! Vendas não estão acessíveis." , "Atenção"
			// "Não consegui abrir o ECF. É possível que esteja desligado. Erro: " ###, "Atenção"
			MsgStop(STR0180 +Str(nRet,2,0), STR0179) 
		
			If nHdlECF >= 0
				IFFechar( nHdlECF, cPortaMenu )
			EndIf
		EndIf
	EndIf
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LjxTelMenFis³ Autor ³ Vendas Clientes     ³ Data ³ 14/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a montagem da tela para que possa ser solicitado os³±±
±±³          ³ dados para o usuário.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Se for precionado o botao de Ok.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LjxTelMenFis(	cTitulo	, cOpcao	, dDataIni	, dDataFim	,;
						cContIni, cContFim	, cPDV		, lArqTxt	,;
						lAto1704)

Local oDlg
Local oDataIni                     // Objeto para a Data Inicial
Local oDataFim                     // Objeto para a Data Final
Local oContIni                     // Objeto para o Contador Inicial
Local oContFim                     // Objeto para o Contador Final
Local oPDV                         // Objeto para o PDV
Local oChkBox					   // Objeto para o Checkbox
Local oChkBoxAto				   // Objeto para o Checkbox
Local oWS						   // Objeto do WebService
Local lRetValue
Local cWsServer					   // Server do WS configurado 
Local lRet						   // Retorno no WS

Default dDataIni 	:= CTOD("")        	// Data Inicial da Memoria Fiscal
Default dDataFim 	:= CTOD("")        	// Data Final da Memoria Fiscal
Default cContIni 	:= SPACE(04)       	// Contador Inicial da Memoria Fiscal
Default cContFim 	:= SPACE(04)       	// Contador Final da Memoria Fiscal
Default cPDV     	:= SPACE(04)       	// Numero do PDV
Default lArqTxt	:= .F.             		// Indica se gera arquivo texto
Default lAto1704 	:= .F.					// Indica se gera Ato Cotepe 17/04 para LMFC

	DEFINE MSDIALOG oDlg FROM  15,6 TO 260,300 TITLE cTitulo PIXEL
	
	@ 013,008 SAY   STR0181			   			SIZE 035, 007 OF oDlg PIXEL //"Periodo De"
	@ 011,050 MSGET oDataIni VAR dDataIni       PICTURE "@E 99/99/99" SIZE 050, 10 OF oDlg PIXEL
	
	@ 033,008 SAY   STR0182			    		SIZE 035, 007 OF oDlg PIXEL //"Periodo Ate"
	@ 031,050 MSGET oDataFim VAR dDataFim       PICTURE "@E 99/99/99" SIZE 050, 10 OF oDlg PIXEL
	
	Do Case
		Case cOpcao == "02" .Or. cOpcao == "03"
			
			@ 053,008 SAY   STR0183		       			SIZE 035, 007 OF oDlg PIXEL //"Contador Ini"
			@ 051,050 MSGET oContIni VAR cContIni       PICTURE "@K 9999" SIZE 050, 10 OF oDlg PIXEL
			
			@ 073,008 SAY   STR0184		  				SIZE 035, 007 OF oDlg PIXEL //"Contador Final"
			@ 071,050 MSGET oContFim VAR cContFim       PICTURE "@K 9999" SIZE 050, 10 OF oDlg PIXEL
			
			@ 093,008 CheckBox oChkBox Var lArqTxt Prompt STR0187 Size 105,008 PIXEL OF oDlg //"Saida em disco"

			If cOpcao == "02"
				@ 105,008 CheckBox oChkBoxAto Var lAto1704 Prompt STR0243 Size 105,008 PIXEL OF oDlg //"Ato Cotepe 17/04" 
			EndIf			
			
		Case cOpcao == "04" .Or. cOpcao == "05"
			
			cContIni := space(6)
			cContFim := space(6)
			@ 053,008 SAY   STR0185		          		SIZE 035, 007 OF oDlg PIXEL //"COO Ini"
			@ 051,050 MSGET oContIni VAR cContIni       PICTURE "@K 999999" SIZE 050, 10 OF oDlg PIXEL
			
			@ 073,008 SAY   STR0186		            	SIZE 035, 007 OF oDlg PIXEL //"COO Final"
			@ 071,050 MSGET oContFim VAR cContFim       PICTURE "@K 999999" SIZE 050, 10 OF oDlg PIXEL
			
		Case cOpcao == "08"
			
			oWS 		:= WsFrtPafEcf():New()
			cWSServer	:= AllTrim(LJGetStation("WSSRV"))

			//Ajusta o caminho do servico
			oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa o web service³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LJMsgRun(STR0154,,{||lRet := oWs:LstPdvs(cEmpAnt, cFilAnt, ,lHomolPaf)}) //"Executando consulta na retaguarda"


			If !lRet 
				MsgStop(STR0193 + ":LstPdvs" ) //"Erro na execução do WebService"
				oWs := Nil  										
			Else							
				@ 053,008 SAY   STR0189		           		  SIZE 035, 007 OF oDlg PIXEL //"PDV"				
				@ 051,050 COMBOBOX oPDV VAR cPDV ITEMS oWS:oWsLstPdvsResult:cString  SIZE 50,10 OF oDlg PIXEL	
			EndIf		

		Case cOpcao == "10"
			
			@ 053,008 CheckBox oChkBox Var lArqTxt Prompt STR0188 Size 105,008 PIXEL OF oDlg //"Geração de arquivo texto"

	EndCase
				
	DEFINE 	SBUTTON   oBtnOk     ;
            FROM      100, 087   ;
            TYPE      1          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .T., oDlg:End() )
	
	DEFINE 	SBUTTON   oBtnCancel ;
            FROM      100, 115   ;
            TYPE      2          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .F., oDlg:End() )
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If !lRetValue
		dDataIni := CTOD("")
		dDataFim := CTOD("")
		cContIni := SPACE(04)
		cContFim := SPACE(04)
		cPDV     := SPACE(04)
	EndIf    
	
Return lRetValue

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    | LjxGerPath ³ Autor ³ Vendas Clientes     ³ Data ³ 09/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o retorno do caminho onde serão gerados os arquivos³±±
±±³          ³ para o PAF-ECF.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION LjxGerPath( cPath ) 

Local lRetValue := .T.
Local cSep := Iif( GetRemoteType() <> REMOTE_LINUX, "\", "/" )
Local cPathDefault := Iif( GetRemoteType() <> REMOTE_LINUX, "C:\TOTVS PAF-ECF", "/totvs paf-ecf" )

Default cPath 			:= ""        	// Define o Caminho onde serao gravados os arquivos do PAF-ECF

// Monta o path do arquivo de acordo com o SIGALOJA.INI
cPath := GetPvProfString("paf-ecf", "patharquivo", cPathDefault, GetClientDir() + "sigaloja.ini") 
cPath := AllTrim(cPath)  

If cPath == ""
	lRetValue := .F. 
Else
    If SubStr(cPath, Len(cPath), 1) <> cSep
    	cPath += cSep
    EndIf   

	/*Cria pasta para salvar arquivos Paf-Ecf*/
    If !ExistDir(cPath)
    	lRetValue := (MakeDir(cPath) == 0)
    EndIf
EndIf

Return lRetValue

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxGerFile  ³ Autor ³ Vendas Clientes     ³ Data ³ 09/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a montagem do nome do arquivo que sera gerado para ³±±
±±³          ³ o PAF-ECF.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION LjxGerFile( cTipo )
Local cRet := ""
Local cPDV := ""           // Armazena o numero do PDV

Default cTipo 	:= ""        // Define a posicao inicial na geração do nome do arquivo

IFPegPDV(nHdlECF, @cPDV)
cRet := cTipo + Dtos( dDataBase ) + Right( cPDV, 2 ) + SM0->M0_CODIGO + SM0->M0_CODFIL + ".TXT" 

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    | LjxMeiPgto ³ Autor ³ Vendas Clientes     ³ Data ³ 27/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a impressao de um relatorio gerencial onde passa a ³±±
±±³          ³ ser Movimento por ECF para o PAF-ECF.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                           							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION LjxMeiPgto( dDataIni, dDataFim )
STBFMMeiPgto(dDataIni, dDataFim, .F.)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJTELACHEQºAutor  ³Vendas Clientes     º Data ³  16/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de dados do cheque                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTelaCheq(	oDlgChq	, cTitulo	, oDlgVA	, aDadosChq	, ;
						aFontes, lBotaoOK	, lCancela 	, nVezes 	, ;
						nCont )


	DEFINE MSDIALOG oDlgChq FROM 12, 13 TO 32, 66 TITLE cTitulo OF oDlgVA //"Dados do Cheque"
		
	@ .3,1 TO 2.9,25.2 OF oDlgChq
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor do título:³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 01.0, 02.0 SAY aDadosChq[4][1] SIZE 17,1 FONT aFontes[1] OF oDlgChq 
	@ 01.0, 12.0 SAY aDadosChq[2][1] VAR aDadosChq[1][1] SIZE 10,1 PICTURE PesqPict("SL1","L1_VLRTOT") RIGHT COLOR CLR_HRED FONT aFontes[1] OF oDlgChq
	If cPaisLoc <> "BRA"
	   @ 01.0, 22.0 SAY "("+aDadosChq[1][13]+")" SIZE 06,1 COLOR CLR_HRED FONT aFontes[1] OF oDlgChq 					
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Data do Vencimento:³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
	@ 02.0, 02.0 SAY aDadosChq[4][2] SIZE 17,1 FONT aFontes[1] OF oDlgChq
	@ 02.0, 10.0 SAY aDadosChq[2][2] VAR aDadosChq[1][2] SIZE 8,1 COLOR CLR_HRED FONT aFontes[1] OF oDlgChq
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³ Parcela:³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	@ 02.0, 15.0 SAY aDadosChq[4][3] SIZE 8,1 FONT aFontes[1] OF oDlgChq
	@ 02.0, 20.0 SAY aDadosChq[2][3] VAR aDadosChq[1][3] SIZE 5,1 RIGHT COLOR CLR_HRED FONT aFontes[1] OF oDlgChq
			
	@ 3,1 TO 9.3,25.2 OF oDlgChq
	//ÚÄÄÄÄÄÄÄ¿
	//³ Banco:³
	//ÀÄÄÄÄÄÄÄÙ
	@ 4.0,02 Say aDadosChq[4][4] SIZE 10,1 OF oDlgChq
	@ 4.0,05 MSGET aDadosChq[2][4] VAR aDadosChq[1][4] Picture PesqPict("SEF","EF_BANCO",3) SIZE 15, 1 OF oDlgChq
	aDadosChq[2][4]:cSx1Hlp:="EF_BANCO"					
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³ Agência:³
	//ÀÄÄÄÄÄÄÄÄÄÙ
			
	@ 4.0,08 Say aDadosChq[4][5] SIZE 10,1 OF oDlgChq
	@ 4.0,11 MSGET aDadosChq[2][5] VAR aDadosChq[1][5] Picture PesqPict("SEF","EF_AGENCIA",5) SIZE 18, 1 OF oDlgChq
	aDadosChq[2][5]:cSx1Hlp:="EF_AGENCIA"
	//ÚÄÄÄÄÄÄÄ¿
	//³ Conta:³
	//ÀÄÄÄÄÄÄÄÙ
	@ 4.0,16 Say aDadosChq[4][6] SIZE 5,1
	@ 4.0,18 MSGET aDadosChq[2][6] VAR aDadosChq[1][6] Picture PesqPict("SEF","EF_CONTA",10) SIZE 36, 1 OF oDlgChq
	aDadosChq[2][6]:cSx1Hlp:="EF_CONTA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Num Cheque:³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
	@ 5.0,02 Say aDadosChq[4][7] SIZE 15,1 OF oDlgChq
	@ 5.0,07 MSGET aDadosChq[2][7] VAR aDadosChq[1][7] Picture PesqPict("SEF","EF_NUM",15) SIZE 51, 1 OF oDlgChq
	aDadosChq[2][7]:cSx1Hlp:="EF_NUM"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compensação:³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
	@ 5.0,14 Say aDadosChq[4][8] SIZE 10,1 OF oDlgChq
	@ 5.0,19 MSGET aDadosChq[2][8] VAR aDadosChq[1][8] Picture PesqPict("SL4","L4_COMP",3) SIZE 10,1 OF oDlgChq
	aDadosChq[2][8]:cSx1Hlp:="L4_COMP"
	//ÚÄÄÄÄ¿
	//³ RG:³
	//ÀÄÄÄÄÙ
			
	@ 6.0,02 Say aDadosChq[4][9] SIZE 10,1 OF oDlgChq
	@ 6.0,04 MSGET aDadosChq[2][9] VAR aDadosChq[1][9] Picture PesqPict("SEF","EF_RG",15) SIZE 51, 1 OF oDlgChq
	aDadosChq[2][9]:cSx1Hlp:="EF_RG"
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³ Telefone:³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
			
	@ 6.0,11 Say aDadosChq[4][10] SIZE 10,1 OF oDlgChq
	@ 6.0,14 MSGET aDadosChq[2][10] VAR aDadosChq[1][10] Picture PesqPict("SEF","EF_TEL",15) SIZE 51,1 OF oDlgChq
	aDadosChq[2][10]:cSx1Hlp:="EF_TEL"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cheque de Terceiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
	@ 95,17 CHECKBOX aDadosChq[2][12] VAR aDadosChq[1][12] PROMPT aDadosChq[4][12] ON CHANGE Lj7EmitTer(@aDadosChq, @oDlgChq) SIZE 70,7 OF oDlgChq
	//ÚÄÄÄÄÄÄÄÄ¿
	//³Emitente³
	//ÀÄÄÄÄÄÄÄÄÙ
	@ 8,2 Say aDadosChq[4][14] SIZE 10,1 OF oDlgChq 
	@ 8,5 MSGET aDadosChq[2][14] VAR aDadosChq[1][14] Picture PesqPict("SEF","EF_EMITENT",15) SIZE 130,1 OF oDlgChq
	aDadosChq[2][14]:cSx1Hlp:="EF_EMITENT"                                                         
			  
	aDadosChq[2][14]:Disable()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utiliza nas próximas parcelas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 120,17 CHECKBOX aDadosChq[2][11] VAR aDadosChq[1][11] PROMPT aDadosChq[4][11] SIZE 90,7 WHEN (nVezes>1.AND.nVezes>nCont) OF oDlgChq
			
	
	DEFINE SBUTTON FROM 132,137 TYPE 1 ACTION (lBotaoOk := .T.,oDlgChq:End()) ENABLE OF oDlgChq
		
	DEFINE SBUTTON FROM 132,171.1 TYPE 2 ACTION (lCancela:=.T.,oDlgChq:End()) ENABLE OF oDlgChq
	
	ACTIVATE MSDIALOG oDlgChq CENTERED
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxDavEmt ºAutor  ³Vendas Clientes     º Data ³  24/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a lista de DAV's emitidos para a data selecionada   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDavEmt(dDataIni, dDataFim, lArqTxt, cFile)

Local cLista	:= ""
Local cWSServer	:= AllTrim(LJGetStation("WSSRV"))   
Local cECF		:= LJGetStation("IMPFISC")
Local cPictTot	:= "@E 99,999,999.99"  
Local cMarca	:= ""
Local cModelo	:= ""          
Local cModeloAux:= "" 
Local cTipoEcf	:= "ECF-IF" 
Local cCabec	:= "" 
Local cPath		:= ""
Local cConteudo	:= ""
Local cNumSerie	:= "" 
Local cTotalDAV	:= ""      
Local cCOO		:= ""       
Local cCOODAV	:= "" 
Local nTotDAV	:= 0
Local nNumDav	:= 0
Local nVias		:= 1 
Local nX		:= 0         
Local nY		:= 0  
Local oWs 		:= WsFrtPafEcf():New() 
Local lRet		:= .F.    
Local nHandle   := 0   
Local cRet		:= ""
Local nTotItDAV	:= 0
Local nTamL2Qtd	:= TamSX3("L2_QUANT")[2]
Local nTamL2Vlt	:= TamSX3("L2_VRUNIT")[2]
Local lMvLjDAVOS:= SuperGetMv("MV_LJDAVOS",,.F.)
Local lCooDav	:= .F.
Local cRazaoSoc	:= ""
Local aDatVendas:= {}
Local nI		:= 0


Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase
Default cFile		:= ""

//PAF-ECF: Remove a versão e envia apenas o modelo
nX := At(" ",cECF)            
nY := At("-",cECF) 
cMarca := SubStr(cECF,1,nX-1)
cModelo:= SubStr(cECF,nX+1,nY-nX-2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o servidor de WS esta configurado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cWSServer)
	MsgStop(STR0149) //"O servidor de Web Services não está configurado nesta estação"
	Return .F.
EndIf

aDatVendas := LjPerVendas(dDataIni, dDataFim)          

For nI := 1 to Len(aDatVendas)

	//Ajusta o caminho do servico
	oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o web service³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LJMsgRun(STR0154,,{||lRet := oWs:LstDavEmit(aDatVendas[nI][1], aDatVendas[nI][2], cEmpAnt, cFilAnt, lHomolPaf)}) // "Executando consulta na retaguarda"
	
	
	If !lRet
		Alert(STR0150 + GetWSCError()) //"Falha no Web Service: "
		Return .F.
	EndIf
	
	If !lArqTxt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara o texto a ser impresso³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList)	           
		
			cCOO	  := AllTrim(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOO)
			cCOODAV  := SubStr(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOODAV,1,6) 
	
			cLista += PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCodigo,15) + "  "
			cLista += oWs:oWsLstDavEmitResult:oWsDavList[nX]:cTitulo + "  "
			cLista += PADR( If(Empty(cCOODAV),"000000",cCOODAV), 13) 
			cLista += CRLF //PulaLinha
			                                                        		
			cLista += DtoC(oWs:oWsLstDavEmitResult:oWsDavList[nX]:dEmissao) + "  "
			cLista += PADR( AllTrim(Transform(oWs:oWsLstDavEmitResult:oWsDavList[nX]:nValor,cPictTot)), 16)
			cLista += PADR( If(Empty(cCOO),"000000",cCOO), 13) 
			cLista += CRLF //PulaLinha
			
			cLista += CRLF //PulaLinha - Insere uma linha em branco para separar os DAV
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o cabecalho e imprime, se houver itens. Caso contrario³
		//³notifica o usuario                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cLista)         
			If lMvLjDAVOS
				cCabec	:= PadC(STR0339,40) + CRLF //"D A V - O S   E M I T I D O S"
			Else
				cCabec	:= PadC(STR0151,40) + CRLF //"D A V   E M I T I D O S"
			EndIf
			
			cCabec += " " + CRLF
			cCabec	+= "Periodo Solicitado : " + Dtoc(dDataIni) + " a " + Dtoc(dDataFim) + CRLF
			cCabec += " " + CRLF
			  
			If lMvLjDAVOS
				cCabec 	+= "Numero DAV-OS     Titulo       COO RG"		+ CRLF
				cCabec 	+= "Data DAV-OS        Valor       COO Venda" 	+ CRLF
			Else
				cCabec 	+= "Numero DAV        Titulo       COO RG" 		+ CRLF
				cCabec 	+= "Data DAV           Valor       COO Venda" 	+ CRLF	
			EndIf
			
			lRet := .T.
			If LjxImpItMF( "LjxDavEmt" , cCabec+cLista , nVias ) <> 0
				MsgStop(STR0177) //"Erro ao conectar com a Impressora Fiscal "
				lRet := .F.
			EndIf		
		Else
			MsgInfo(STR0153) //"Não foram encontrados registros de DAV para o período solicitado"
		EndIf
	
	Else 
		
		If Len(oWs:oWsLstDavEmitResult:oWsDavList) == 0
			MsgInfo(STR0153) //"Não foram encontrados registros de DAV para o período solicitado"
			lRet := .F.
		EndIf                                          
		
		If lRet .AND. LjxGerPath(@cPath)
			
			cFile := LjxGerFile( "D" )
	
			nHandle := FCREATE( cPath + cFile, FC_NORMAL )
			
			If nHandle < 0
				MsgStop(STR0191 + cPath + cFile) //"Erro ao criar arquivo "
				Return .F.
			EndIf
			
			cRazaoSoc := PADR( SM0->M0_NOMECOM, 50 ) // Razao Social
			
			For nX := 1 to Len(oWs:owsLstDavEmitResult:oWsDavList)
				If oWs:oWsLstDavEmitResult:oWsDavList[nX]:lIncManual
					cRazaoSoc := StrTran( PADR( SM0->M0_NOMECOM, 50 ) , " " , "?" ) // Razao Social
				EndIf
			Next nX
			
			cConteudo := "D1"
			cConteudo += PADL( SM0->M0_CGC, 14 ) // CNPJ
			cConteudo += PADR( SM0->M0_INSC, 14 ) // Incricao Estadual
			cConteudo += PADR( SM0->M0_INSCM, 14 ) // Incricao Municipal		
			cConteudo += cRazaoSoc
			cConteudo += CHR(13) + CHR(10)
			
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
		
			//Recupera série do PDV sem conectar com o ECF - "VI  -  Consultas:  funções  do  PAF-ECF  que  não  necessitam  de  informações coletadas diretamente do ECF.". 
			LjDadosEcf()
			LjGetInfEcf("SERIE",@cNumSerie)		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ REGISTRO TIPO D2 - RELAÇÃO DOS DAV EMITIDOS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			For nX := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList)
				
				nTotDav++              
				cCOO		:= oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOO
				cCOODAV	:= oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCOODAV
				lCooDav	:= If(Empty(AllTrim(cCOODAV)) .OR. (cCOODAV == "000000   ") .OR. (Val(cCOODAV) == 0), .F., .T.)
	                                     
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Quando possui alteração na DAV, conforme legislação PAF,³
				//³ deverá ser evidenciada.                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lHomolPAF
					If oWs:oWsLstDavEmitResult:oWsDavList[nX]:LPAFMD5OK
						cModeloAux := PADR( If(!lCooDav ," ",cModelo), 20)			// Modelo do ECF			
					ElseIf lCooDav
						cModeloAux := StrTran(PADR(cModelo,20) , " ", "?") // Modelo do ECF quando ocorre modificação nos registros TESTE 103
					ElseIf !oWs:oWsLstDavEmitResult:oWsDavList[nX]:LPAFMD5OK .AND. !lCooDav
						cModeloAux := REPLICATE("?",20)
					Else	
						cModeloAux := REPLICATE(" ",20)   // Modelo do ECF quando ocorre modificação nos registros TESTE 103
					EndIf
				Else
					cModeloAux := PADR( cModelo, 20 )
				EndIf	
	
				cTotalDAV := StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:nValor,9,2)
				cTotalDAV := StrTran(cTotalDAV,".")
				cTotalDAV := StrTran(cTotalDAV,",")
				
				cConteudo := "D2"
				cConteudo += PADL( SM0->M0_CGC, 14 ) 						 					// CNPJ
				cConteudo += PADR( IIF(!lCooDav ,"",cNumSerie), 20 )						// Num. de fabricação do ECF  
				cConteudo += Space(1)								  							// Letra indicativa de MF adicional 
				cConteudo += PADR( IIF(!lCooDav ,"",cTipoEcf), 7)							// Tipo do ECF 								
				cConteudo += PADR( IIF(!lCooDav ,"",cMarca), 20)	  						// Marca do ECF		
				cConteudo += cModeloAux						// Modelo do ECF		
				cConteudo += PADR( If(Empty(cCOODAV),"000000",cCOODAV), 6)						// COO DA IMPRESSÃO DA DAV por ECF
				cConteudo += PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCodigo, 13)			// DAV
				cConteudo += PADR( DtoS(oWs:oWsLstDavEmitResult:oWsDavList[nX]:dEmissao),8)		// Data da operacao
				cConteudo += PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:cTitulo,30)			// Titulo atribuido ao DAV
				cConteudo += PADL( cTotalDAV,8)													// Valor total do DAV
				cConteudo += PADL( If(Empty(cCOO),"000000",cCOO), 6)							// COO DA IMPRESSÃO do Cupom Fiscal
				cConteudo += StrZero( Val(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cSerie), 3)	// Número sequencial do ECF emissor do documento fiscal vinculado
				cConteudo += PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:cNomeClient, 40)			// Nome do Cliente 
				cConteudo += StrZero( Val(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCnpjClient), 14)	// CPF ou CNPJ do adquirente			
				cConteudo += CHR(13) + CHR(10)
				
				FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
	
			Next nX
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ REGISTRO  TIPO  D3  -  DETALHE  DO  DOCUMENTO  AUXILIAR  DE VENDA - DAV  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList)
	
				For nY := 1 to Len(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList)
				                       
					nTotItDav++              
				   	//Busca o Codigo do Totalizador ICMS
				   	cRet := LjBuscaTot( oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cTotParc )
					cRet := SubStr(cRet,3,5)
					
					cConteudo := "D3"             																							// 01-Tipo
					
					nNumDav	:= Val(oWs:oWsLstDavEmitResult:oWsDavList[nX]:cCodigo)
					cConteudo += StrZero( nNumDav, 13)																							// 02-Número do DAV onde está contido este item
					cConteudo += PADR( DtoS(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:dEmissao),08)				// 03-Data de inclusão do item							                    
					cConteudo += StrZero( oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nNumItem, 03)				// 04-Número  sequencial  do  item  registrado no documento 																																	
					cConteudo += PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cCodProd, 14) 				 	// 05-Código  do  produto  ou  serviço registrado no documento.
					
					If lHomolPAF .AND. !oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:lPAFMD5OK
						cConteudo += StrTran(PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cDescricao, 100)," ","?") 				// 06-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
					Else
						cConteudo += PADR(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cDescricao, 100) 				// 06-Descrição  do  produto  ou  serviço constante no Cupom Fiscal
					EndIf	
						
					cConteudo += StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nQuantidade, 07)				// 07-Quantidade,  sem  a  separação  das casas decimais 
					cConteudo += PADR( oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cUnMedida	,03 )				// 08-Unidade de medida
					cConteudo += StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nVlrUnit	,08 )				// 09-Valor  unitário  do  produto  ou  serviço, sem a separação das casas decimais. 
					cConteudo += StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nDescItem,9,2),'.')	// 10-Valor  do  desconto  incidente  sobre  o valor  do  item,  com  duas  casas decimais.				
					cConteudo += StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nAcreItem,9,2),'.')	// 11-Valor  do  acréscimo  incidente  sobre  o valor  do  item,  com  duas  casas decimais. 		
					cConteudo += StrTran(StrZero(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:nVlrLiq,15,2),'.')	// 12-Valor  total  líquido  do  item,  com  duas casas decimais. 
					
					//Ajustar a formação dependendo do tipo de alíquota
					If ("S" $ cRet) .OR. ("T" $ cRet)
						cConteudo += PADR( cRet	,05 )		// 13 e 14-Código  do  totalizador  relativo  ao produto  ou  serviço  conforme  tabela abaixo.					 
					Else  
						cConteudo += oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:cTotParc + "0000"
					EndIf
					
					cConteudo += PADR(If(oWs:oWsLstDavEmitResult:oWsDavList[nX]:oWsLstItemDav:oWsItDavList[nY]:lItCancel,"S","N"), 01 )		// 15-Informar  "S"  ou  "N",  conforme  tenha ocorrido  ou  não,  a  marcação  do cancelamento  do  item  no  documento auxiliar de venda.  
					cConteudo += CVALTOCHAR(nTamL2Qtd)																						// 16-Casas decimais da qtde
					cConteudo += CVALTOCHAR(nTamL2Vlt)																						// 17-Casas decimais do valor unitario
					cConteudo += CHR(13) + CHR(10)			
					FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
	
		   		Next nY                                                                               
		
			Next nX        
	
			cConteudo := "D9"
			cConteudo += PADL( SM0->M0_CGC, 14 )  			// CNPJ
			cConteudo += PADR( SM0->M0_INSC, 14 ) 			// Incricao Estadual
			cConteudo += PADL( StrZero(nTotDAV,6,0), 6) 	// Total de Registros
			cConteudo += PADL( StrZero(nTotItDAV,6,0), 6) 	// Total de Registros
			cConteudo += CHR(13) + CHR(10)
			
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			FCLOSE( nHandle )
			lRet := .T.
		EndIf
	EndIf
Next nI

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxImpIdPEºAutor  ³Vendas CRM          º Data ³  25/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão do Relatório Gerencial (via ECF) "IDENTIFICACAO DOº±±
±±º          ³PAF-ECF", com informacoes do Laudo de Analise Funcional     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxImpIdPE()
STBFMImpIdPE( .F. )
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxTipoDocºAutor  ³Vendas CRM          º Data ³  29/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define i Tipo do Documento usado no registro R06           Oº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±   
±±ºUso       ³LOJXFUND                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjxTipoDoc( aRetWs, nX )
Local aRet := {}
//aRet[1] - Contador de Comprovante Nao Fiscal
//aRet[2] - Contador de Relatorio Gerencial
//aRet[3] - Contador de Comprovante de Credito ou Debito
//aRet[4] - Tipo de Documento
//aRet[5] - Data de Impressao 
//aRet[6] - Hora de Impressoao dDataEmiss
Local lFtvdVer12	:= LjFTVD() //Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
     
If !lFtvdVer12    
   If aRetWs[nX]:nNumContRg  > 0
     AADD( aRet, {0, aRetWs[nX]:nNumContRg, 0, "RG", aRetWs[nX]:cDataTef, aRetWs[nX]:cHoraTef} )  //Relatorio Gerencial RG
   EndIf  
             
   If aRetWs[nX]:nNumContCdc > 0
     AADD( aRet, {aRetWs[nX]:nNumContOnf, 0, aRetWs[nX]:nNumContCdc, "CC", aRetWs[nX]:cDataTef, aRetWs[nX]:cHoraTef} ) //Comprovante de Credito ou Debito CC
   EndIf
ElseIf lFtvdVer12
	If aRetWs[nX]:nNumContOnf > 0
     AADD( aRet, {aRetWs[nX]:nNumContOnf, 0, 0, "CN", aRetWs[nX]:cDataTef, aRetWs[nX]:cHoraTef} ) //Comprovante Nao-Fiscal CN
   EndIf  
     
   If aRetWs[nX]:nNumContRg  > 0
     AADD( aRet, {0, aRetWs[nX]:nNumContRg, 0, "RG", aRetWs[nX]:cDataTef, aRetWs[nX]:cHoraTef} )  //Relatorio Gerencial RG
   EndIf  
             
   If aRetWs[nX]:nNumContCdc > 0
     AADD( aRet, {0, 0, aRetWs[nX]:nNumContCdc, "CC", aRetWs[nX]:cDataTef, aRetWs[nX]:cHoraTef} ) //Comprovante de Credito ou Debito CC
   EndIf  
   
   If aRetWs[nX]:nNumContDoc > 0
	 AADD( aRet, {0, 0, 0, "RV", DtoS(aRetWs[nX]:dDataEmiss), aRetWs[nX]:cHoraEmiss} )                   //Registro de Venda RV  
   EndIf
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjHex2Asc ºAutor  ³Vendas CRM          º Data ³  22/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte um texto com caracteres HEXA em texto com carac-   º±±
±±º          ³teres HEXA.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjHex2Asc(cString)
Local nX     := 1 
Local cHex   := ""
Local nDec   := 0
Local cList  := "0123456789abcdef"
Local cResult:= ""

cString := Lower(cString)

For nX := 1 to Len(cString) Step 2
	cHex    := SubStr(cString,nX,1)
	nDec    := (At(cHex,cList)-1)*16
	cHex    := SubStr(cString,nX+1,1)
	nDec    := nDec+At(cHex,cList)-1
	cResult += Chr(nDec)
Next nX

Return cResult

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjAsc2Hex ºAutor  ³Vendas CRM          º Data ³  22/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte um texto com caracteres ASCII em texto com carac-  º±±
±±º          ³teres HEXA.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjAsc2Hex(cString)
Local nX     	:= 1 
Local cResult	:= ""
Local nVal		:= 0

For nX := 1 to Len(cString)
	nVal 	:= Asc(SubStr(cString,nX,1))
	If ExistFunc("Dec2Hex")
		cResult += Dec2Hex(nVal)
	Else
		cResult += STDDec2Hex(nVal)
	EndIf
Next nX     

cResult := Lower(cResult)

Return cResult

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjBuscaTotºAutor  ³Vendas CRM          º Data ³  22/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o codigo do Totalizador no ECF                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParm.     ³Codigo do Imposto                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjBuscaTot( cImposto )
Local cRet := ""
cRet := STBBuscaTotECF(@cImposto,.F.)
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjBuscaDadosºAutor  ³Vendas CRM          º Data ³  22/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca os Dados na ECF 									  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjBuscaDados(cMfAdic , cTipoEcf, cModelo, cVerSB, ;
                             cDtInsSB, cHrInsSB, cCodECF, nUsuEcf,;
                             cSeriePDV)
Local lRet		:= .T.
Local cMarcaEcf := ""
Local cIEECF	:= ""
Local cCnpjECF	:= ""

lRet := STBBuscaDados(@cMfAdic , @cTipoEcf, @cModelo, @cVerSB, ;
                     @cDtInsSB, @cHrInsSB, @cCodECF, @nUsuEcf,;
                     @cSeriePDV, @cMarcaEcf , @cIEECF, @cCnpjECF)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³LJVerHomolºAutor  ³Microsiga           º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao utilizada exclusivamente para homologacao           º±± 
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPn1 - Handle de uso da DLL                               º±± 
±±º          ³ EXPn2 - Comando para ser enviado para DLL                  º±± 
±±º          ³ EXPc1 - Texto para ser impresso                            º±± 
±±º          ³ EXPn3 - Tipo para realizar os testes                       º±± 
±±º          ³ EXPn4 - Numero de vias                                     º±± 
±±º          ³ EXPn5 - Retorno da DLL                                     º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPl1 - Retorna verdadeiro seu for homologacao			  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA / FRONTLOJA                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJVerHomol(nHnd, nComando, cBuffer, nTipo, nVias, nRet, nImpHnd)

Local lRet			:= .F.							// Retorno da função
Local cTipTef		:= LjGetStation("TIPTEF")		// Tipo de tef utilizado 
Local lUsaTef		:= LJProFile(2)            		// Configuracao do caixa
Local cSalvBuff		:= ""							// Salva o conteudo para nao perder depois que enviar para impressora
Local cTrataText	:= ""							// Variável para tratamento do texto para impressora, mandar de 3 em 3 linhas
Local cEnviaText	:= ""							// Variável para enviar o texto para impressora de 3 em 3 linhas
Local nRemp			:= 0                                    // Contador do cFim
Local cFim 			:= STR0235								// "ANOTE TELEFONE E ENDERECO NO VERSO"

Default nHnd		:= -1
Default nComando	:= 0
Default cBuffer		:= ""
Default nTipo		:= 0
Default nVias		:= 1
Default nRet		:= -1
Default nImpHnd 	:= 0

If cTipTef == TEF_CLISITEF .AND. lUsaTEF .AND. oTEF:lHomolog	
	lRet := .T.
	If nTipo == 1	// fechamento do cupom - Loop quando não existe comunicação do sistema com a impressora no momento
		cSalvBuff := cBuffer
		While nRet <> 0
			If MsgYesNo(STR0224, STR0050)		//"Deseja imprimir novamente?"#"Atenção"
				Sleep(4000) 
				nRet := ExecDLLRet( nHnd, nComando, cBuffer )
				If nRet <> 0
					cBuffer := cSalvBuff
				Endif
			Else
				oTEF:FinalTrn(0)
				Sleep(4000)
				MsgInfo(STR0225)				//"Transação TEF não foi efetuada. Favor reter o Cupom!"				
				exit
			EndIf
		End
	ElseIf nTipo == 2	// condicao de pagamento - Loop quando não existe comunicação do sistema com a impressora no momento
		While nRet <> 0

			If MsgYesNo(STR0224 , STR0050)		//"Deseja imprimir novamente?"#"Atenção"
				cSalvBuff := cBuffer 			
				Sleep(5000) 				
				nRet := ExeDLLRun2(nHnd, nComando, cBuffer)				
				If nRet <> 0					
					cBuffer := cSalvBuff
				Endif
			Else
				oTEF:FinalTrn(0)                                  								
				Sleep(4000)
				MsgInfo(STR0225)				//"Transação TEF não foi efetuada. Favor reter o Cupom!"				
				IFCancCup( nHdlECF )
				nRet := 1
				exit
			EndIf
		End
	ElseIf nTipo == 3	// comprovante vinculado - Loop de tratamento para enviar no maximo 3 linhas por vez para impressora		
		nRet := 0
		cTrataText := cBuffer
		While nRet == 0
			cEnviaText := ""
			cEnviaText := SUBSTR(cTrataText,1,30)
			cTrataText := SUBSTR(cTrataText,31)
			If Empty(cTrataText)
				nRet := ExeDLLRun2(nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')
				Exit
			EndIf
			nRet := ExeDLLRun2(nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')
			nRet := IFStatus(nHdlECF, "20", @cRet)			// Verifico o Status do ECF
		End
	ElseIf  nTipo == 4	// relatorio gerencial - Loop de tratamento para enviar no maximo 3 linhas por vez para impressora
		nRet := ExeDLLRun2(nHnd, nComando, Str(nImpHnd)+'|'+'FechaRelatorioGerencial|'+Str(nVias)+'|') 
		nRet := 0                       
		cTrataText := cBuffer
		While nRet == 0
			cEnviaText := ""
			cEnviaText := SUBSTR(cTrataText,1,60)
			cTrataText := SUBSTR(cTrataText,61)			
		
			If cFim $ cEnviaText  
				nRemp +=	1	
				cEnviaText := SubStr(cEnviaText, 1, RAT("O", cEnviaText))
			EndIf
			If nRemp == 1
				cTrataText := ""
			EndIf       
			
			If Empty(cTrataText)
				nRet := ExeDLLRun2(nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')
				nRet := ExeDLLRun2(nHnd, nComando, Str(nImpHnd)+'|'+'FechaRelatorioGerencial|'+Str(nVias)+'|')
				Exit
			EndIf
			nRet := ExeDLLRun2(nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')						
			nRet := IFStatus(nHdlECF, "20", @cRet)			// Verifico o Status do ECF
		End
	ElseIf nTipo == 5	// Envia Sleep para garantir que a impressora ja esta on-line
		Sleep(3000)
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LOJXGERCFDºAutor  ³Microsiga           º Data ³  05/13/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Nota fiscal eletronica Mexico                              º±±
±±º          ³ Exp1: Se é usuario fiscal, pois nao gera cfd para usuario  º±±
±±º		     |	fiscal no momento da venda.                               º±±
±±º		     | Exp2: Indica se deseja perguntar pela geração do CFD.      º±±
±±º		     | Exp3: Array que será alimentado com as informacoes dos     º±± 
±±º		     |  CFDs gerados                                 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOJXGERCFD(lFisc , lConf , aMsgCert)
Local aGerarCFD		:= {}									// Array com retorno da funcao CFDVerific ( MEXICO )
Local lGerarCFD		:= .F.									// Indica se gera CFD ( MEXICO )
Local aCFD			:= {"",""}							
Local cMsgCFD		:= ""
Local nX			:= 0   
Local cHora			:= ""

Default lFisc			:= .F.
Default lConf			:= .T.
Default aMsgCert		:= {}

If cPaisLoc == "MEX" .AND. !lFisc

	If FindFunction("CFDVerific")
		aGerarCFD := CFDVerific()
	Else
		aGerarCFD := {"0"}
	Endif
			
	If aGerarCFD[1] > "0" .And. Empty(aGerarCFD[2])
		lGerarCFD := (CFDChkFol(xFilial("SF2"),SF2->F2_SERIE,SF2->F2_DOC,@aCFD,.F.,.T.) == 0)
	Else
	    If !Empty(aGerarCFD[2])
    			lGerarCFD := .F.
			cMsgCFD := ""
			For nX := 1 To Len(aGerarCFD[2])
				cMsgCFD += aGerarCFD[2][nX][2] + CRLF
			Next nX
			MsgAlert(cMsgCFD,STR0228) 	// ## "Comprovantes Fiscais Digitais"
		EndIf
	EndIf						
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava campos referentes ao certificado e numero de aprovacao - comprovantes fiscais digitais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	If lGerarCFD
			cHora	:=	Time()
			RecLock("SF2" , .F.)
			REPLACE F2_APROFOL With aCFD[1]
			REPLACE F2_CERTFOL With aCFD[2]
			REPLACE F2_HORA	   With cHora
			SF2->(MsUnlock())
            
            DBSelectArea("SL1")
            DBSetOrder(2)
			If 	DbSeek(xFilial("SL1") + SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_PDV)
				RecLock("SL1" , .F.)			
				REPLACE L1_HORA	   With cHora
				SL1->(MsUnlock())			
            EndIf
            
            DBSelectArea("SF3")
            DBSetOrder(6)
            If	DbSeek(xFilial("SF3") + SF2->F2_DOC + SF2->F2_SERIE)
				RecLock("SF3" , .F.)			
				REPLACE F3_APROFOL With aCFD[1]
				REPLACE F3_CERTFOL With aCFD[2]
				REPLACE F3_HORA	   With cHora
				SF3->(MsUnlock())			
			EndIf
			
			AADD(aMsgCert , {aCFD[1] , aCFD[2] , SF2->F2_DOC})
			If !CFDGerXML(SF2->F2_ESPECIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_DOC,SF2->F2_SERIE,lConf,.T.)
				RecLock("SF2" , .F.)
				REPLACE F2_APROFOL With ""
				REPLACE F2_CERTFOL With ""
				SF2->(MsUnlock())
				ADel(aMsgCert , Len(aMsgCert))			
				ASize(aMsgCert , Len(aMsgCert) -1 )							
			EndIf
	Endif
EndIf
Return lGerarCFD

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  |LJXListFolºAutor  ³Microsiga           º Data ³  05/27/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela com dodos dos CFDs gerados                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja - Mexico                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJXListFol(aMsgCert)
Local oDlg
Local oBrowse

Default	aMsgCert := {}
                      
If Len(aMsgCert) > 0
	DEFINE MSDIALOG oDlg FROM 0,0 TO 230,410 PIXEL TITLE STR0229	// # "Foram gerados os seguintes CFDs"

	oBrowse := TSBrowse():New(03,03,200,90,oDlg,,16,,1)
	oBrowse:AddColumn( TcColumn():New(STR0230,,,,) )		// #"Aprovacao"
	oBrowse:AddColumn( TcColumn():New(STR0231,,,,) )   	// #"Certificado"
	oBrowse:AddColumn( TcColumn():New(STR0232,,,,) )	    // #"Folio"
	oBrowse:SetArray(aMsgCert)
	DEFINE SBUTTON FROM 95,155  TYPE 1 ACTION oDlg:End() ENABLE OF oDlg                             

	ACTIVATE MSDIALOG oDlg CENTERED
EndIf
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDVaCampºAutor  ³  Vendas Clientes   º Data ³  19/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida campos, obrigando CPF/CNPJ quando informa Nome/End  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 - CGC do cliente                                     º±±
±±º			 ³ ExpC2 - Nome do cliente                                    º±±
±±º 		 ³ ExpC2 - Endereco do cliente                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 - Retorno da funcao T ou F                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjxDVaCamp(cCgc, cNome, cEnd , nValor,lCancel)
Local lRet			:= .T. 							// Retorno da Função
Local lLj950ImpCpf	:= ExistFunc("Lj950ImpCpf")
Local lTemDisplay	:= !Empty(LjGetStation("DISPLAY"))
Local cMensagem		:= ""
Local lLJVldCpf		:= ExistBlock("LJVLDCPF") //Ponto de entrada Valida CPF/CNPJ

Default cCgc  	:= ""
Default cNome 	:= "" 
Default cEnd  	:= ""
Default nValor	:= 0
default lCancel := .F. 

//Quando PAF, verifica Nome e/ou Endereço infomado, obriga informar o CPF/CNPJ
If LjNfPafEcf(SM0->M0_CGC)
	lRet := !( Empty(cCgc) .AND. (!Empty(cNome) .OR. !Empty(cEnd)) )
	If !lRet 
		cMensagem :=  STR0139 // "CPF/CNPJ inválido!"
	EndIf
EndIf

If lRet .And. lLj950ImpCpf .And. (nValor > 0)
	If Lj950ImpCpf(nValor) .And. Empty(AllTrim(cCgc))
		If lCancel	
			
			If MsgNoYes(STR0413)//"Deseja abortar a finalização da venda?"
				//Indico que a finalização da venda será abortada
				lCgcCancel 	:= .T.
				lRet		:= .T.
			Else	
				lRet		:= .F.
			EndIf

		Else
			lRet		:= .F.
			cMensagem	:= STR0408 //"Segundo legislação ou conforme configuração no parâmetro MV_LJVLCID é obrigatório informar documento do cliente (CPF/CNPJ)"
		EndIf

	EndIf
EndIf

//Chama PE para validar dados informados na tela padrao, permite o cliente customizar para nao permitir CPF para determinados valores
If lLJVldCpf
	LjGrvLog( NIL, " Antes da execução do P.E. LJVLDCPF",{cCgc,cNome,cEnd,nValor})
	lRet := ExecBlock("LJVLDCPF",.F., .F., {cCgc,cNome,cEnd,nValor} )
	LjGrvLog( NIL, " Depois da execução do P.E. LJVLDCPF",lRet)
EndIf

If !lRet .AND. !lLJVldCpf
	
	If !Empty(cMensagem)
		MsgStop( cMensagem )
	EndIf

	If lTemDisplay
		DisplayEnv(StatDisplay(), "1E" + Substr(Upper(STR0136),1,26))	// "INFORME O CPF / CNPJ PARA IMPRESSÃO"
		DisplayEnv(StatDisplay(), "2E" + Substr(Upper(STR0136),27)+":")	// "INFORME O CPF / CNPJ PARA IMPRESSÃO"
		DisplayEnv(StatDisplay(), "3E" + "|" )     						// Habilitar para digitacao
	EndIf
EndIf
	
Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxDMoney ºAutor  ³  Vendas & CRM      º Data ³  11/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a forma passada e dinheiro utilizando o campo  º±±
±±º          ³ E5_FORMAPG caso exista na base.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/FrontLoja                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDMoney( cAlias, cE5Moeda, cE5FormaPg)
Local lRet			:= .F.
Local cForma		:= ""

If cE5FormaPg == NIL
	If (cAlias)->(ColumnPos("E5_FORMAPG")) > 0
		cForma := AllTrim((cAlias)->E5_FORMAPG)
	Else
		cForma := AllTrim(cE5Moeda)
	EndIf
Else
	cForma := AllTrim(cE5FormaPg)
EndIf

lRet := IsMoney( cForma )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjConPrEstºAutor  ³  Vendas & CRM      º Data ³  28/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - Modulo                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/FrontLoja                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjConPrEst(aSb)
Local aRet	:=	{} 		// Retorno
Local nSb 	:=	0		// Contador

If Len(aSb) > 0
	DBSelectArea("SB2")
	SB2->(DBSetOrder(1)) //B2_FILIAL + B2_COD + B2_LOCAL
EndIf

For nSb := 1 To Len(aSb)
	
	If SB2->(DbSeek( xFilial("SB2") + aSb[nSb][1] + aSb[nSb][2] ))
		aSb[nSb][3]	:= AllTrim(cValToChar(SB2->B2_QATU))
		aSb[nSb][4]	:= Dtos(SB2->B2_USAI)
	Else
		aSb[nSb][3]	:= "0"
		aSb[nSb][4]	:= ""
	EndIf

Next nSb

Aadd(aRet, aSb)

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxGetMid ºAutor  ³  Vendas Clientes   º Data ³  18/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Possibilita a consulta de Midias e retorna o codigo        º±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±³Sintaxe	 ³ LjxGetMid(ExpC1)                                     	  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametro ³ ExpC1 - Codigo da Midia                                    º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºRetorno   ³ ExpC1 - Retorno da funcao Codigo da Midia                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/FrontLoja                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 										         
Function LjxGetMid(cCodMidia)				    

Local oCodMidia			:= Nil								  // Objeto para digitar o codigo da midia
Local oDescMidia 	    := Nil 								  // Objeto para mostrar descrição da midia 
Local cDescMidia 		:= Subst(Posicione("SUH",1,xFilial("SUH")+cCodMidia,"UH_DESC"),1,30) // Descricao da midia
Local cCodMidIni		:= cCodMidia                      // Codigo inicial da Midia

Default cCodMidia  		:= Space(TamSX3("UH_MIDIA")[1])  	// Codigo da Midia 

//Desabilita as teclas de atalho , no Front não ha necessidade
If nModulo ==  12
	Lj7SetKeys(.F.)
EndIf
		
DEFINE MSDIALOG oWindMid FROM 47,130 TO 200,550 TITLE STR0244 PIXEL OF GetWndDefault() // Alteracao de Midia
     
	@ 04, 05 TO 28, 85 LABEL STR0245 OF oWindMid PIXEL   // Midia
	@ 13, 15 MSGET oCodMidia VAR cCodMidia F3 "SUH" SIZE 40,10  OF oWindMid PIXEL Valid !Empty(cCodMidia) .AND. ExistCpo("SUH",cCodMidia) .And. SUH->UH_VALIDO=="1"  	 	      	            
	oCodMidia:cSx1Hlp:="UH_MIDIA"	
	oCodMidia:bLostFocus := { || cDescMidia := Subst(Posicione("SUH",1,xFilial("SUH")+cCodMidia,"UH_DESC"),1,30), oCodMidia:Refresh() }
	
	@ 30, 05 TO 54, 210 LABEL STR0246 OF oWindMid PIXEL	  // " Descricao da Midia 		
   	@ 39, 15 MSGET oDescMidia VAR cDescMidia WHEN .F. PIXEL   
	 				  
	DEFINE SBUTTON FROM 060,007 TYPE 1 ACTION (oWindMid:End()) ENABLE OF oWindMid 	
	DEFINE SBUTTON FROM 060,037 TYPE 2 ACTION (oWindMid:End(),cCodMidia := cCodMidIni) ENABLE OF oWindMid

ACTIVATE MSDIALOG oWindMid CENTER

If nModulo ==  12
	Lj7SetKeys(.T.)
EndIf

Return cCodMidia  
     
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxValMid ºAutor  ³  Vendas Clientes   º Data ³  22/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida cadastro de Midia, verifica se conten registros     º±±
±±º          ³ e se estao validos    					        		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 - Retorno da validação funcao		                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/FrontLoja                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 										         
Function LjxValMid()							    

Local lRet := .F. // Retorno
  
DbSelectArea("SUH")
DbSetOrder(1)    

If DbSeek(xFilial("SUH"),.T.)  
	While !Eof()
    	If SUH->UH_VALIDO=="1"
			lRet := .T.
			Exit
		EndIf
		DbSkip()
	End	
Else
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxGetGar ºAutor  ³  Vendas Clientes   º Data ³  18/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Possibilita a consulta de Garantia e retorna o codigo      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - Retorno da funcao Codigo da Midia                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja/FrontLoja                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 										         
Function LjxGetGar(cCodProd)				    

Local oCodMidia			:= Nil								  // Objeto para digitar o codigo do produto
Local cCodMidIni		:= "X"                                // Inicial X
Local lGE				:= LjUP104ok(nModulo <> 12)

Default cCodProd  		:= Space(TamSX3("BF_NUMSERI")[1]) 	// Codigo Produto

If !lGE
	Return Nil 
EndIf          
			
DEFINE MSDIALOG oWindMid FROM 47,130 TO 150,550 TITLE STR0253 PIXEL OF GetWndDefault() // Alteracao
     
	@ 04, 05 TO 28, 180 LABEL STR0253 OF oWindMid PIXEL   // Produto
	@ 13, 15 MSGET oCodMidia VAR cCodProd F3 "SBF1" SIZE 150,10  OF oWindMid PIXEL Valid !Empty(cCodProd)
	oCodMidia:cSx1Hlp:="BF_NUMSERI"	
	 				  
	DEFINE SBUTTON FROM 030,007 TYPE 1 ACTION (oWindMid:End()) ENABLE OF oWindMid 	
	DEFINE SBUTTON FROM 030,037 TYPE 2 ACTION (oWindMid:End(),cCodProd := cCodMidIni) ENABLE OF oWindMid

ACTIVATE MSDIALOG oWindMid CENTER
Return(cCodProd)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ LjAddNcc    ³ Autor ³ Vendas Clientes    ³ Data ³ 11.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Adiciona a NCC no Array para ser utilizado na Venda        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Prefixo do Título                                  ³±±
±±³          ³ ExpC2 - Numero do Título                                   ³±±
±±³          ³ ExpA3 - Notas de Crédito Utilizadas                        ³±±
±±³          ³ ExpA4 - Notas de Crédito Disponiveis                       ³±±
±±³          ³ ExpN5 - Valor dos Creditos Utilizados                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExL1 - True ou False                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Sigaloja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/              
Static Function LjAddNcc(cPrefixo,cNumero,aNCCUse,aNCCItens,nNCCSel) 

Local lRet 		:= .T. 	// Retorno
Local nPosNCC   := 0    // Pos Ncc 
Local nX		:= 0 	// COntador
                                                                                                
Default cPrefixo	:= ""
Default cNumero	:= ""
Default aNCCUse 	:= {}
Default aNCCItens	:= {}
Default nNCCSel	:= 0

If Empty(cPrefixo) .AND. Empty(cNumero)

	MsgStop(STR0260)	//"Informe o Prefixo e Número correspondente ao título de crédito"
	lRet := .F. 

Else
	If ( nPosNCC := aScan( aNccItens, { |x| x[9]+x[3] == cPrefixo+cNumero })) > 0 		
	    If aScan( aNCCUse, {|x| x[9]+x[3] == cPrefixo+cNumero}) == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Será utilizada a primeira posição do Array.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aNCCUse[1][9]) .AND. Empty(aNCCUse[1][3]) .AND. Empty(aNCCUse[1][4]) .AND. aNCCUse[1][2] == 0
				For nX:= 1 To Len(aNCCItens[nPosNCC])
						aNCCUse[1][nX] := aNCCItens[nPosNCC][nX]						
				Next nX							
			Else
			    Aadd( aNCCUse, aNccItens[nPosNCC] )
			Endif 	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Marca titulo de crédito.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aNCCUse[Len(aNCCUse)][1]:= .T.	    			
		Else
			MsgStop(STR0258)	//"O título de crédito já foi adicionado a lista para seleção."
			lRet := .F. 						
		Endif 	    
	Else	
		MsgStop(STR0259)	//"Não foi encontrad0 o título de crédito connforme prefixo e número informado."
		lRet := .F. 
	Endif       
Endif 	
If lRet
	cPrefixo 	:= Space(TamSx3("E1_PREFIXO")[1])
	cNumero 	:= Space(TamSx3("E1_NUM")[1])	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza Valor ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nNCCSel := 0
	For nX:=1 To Len(aNCCUse)
		If aNCCUse[nX][1] 
			nNCCSel	+= aNCCUse[nX][2]
		Endif 			
	Next nX	
Endif
Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJXTotalCFºAutor  ³Vendas CRM          º Data ³  08/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula total liquido do Cupom Fiscal        	  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LJXTotalCF                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJXTotalCF(nItem, lDescAcr)
Local nCont			:= 0
Local nTotal		:= 0
Local nPosVlrItem	:= Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_VLRITEM"})				// Posicao do valor do item
Local nPosEntrega   := Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_ENTREGA"})				// Posicao da Entrega
Local nPosDelet		:= Len(aHeader)+1															// Posicao do controle de delecao de linha
Local cEntrega		:= ""																		// Tipo de Entrega do item

Default nItem 			:= -1							 										// Posicao do itens no aCols que nao sera totalizado
Default lDescAcr		:= .F.																	// Considerar desconto e acrescimo da nota

For nCont := 1 To Len(aCols)
	If !aCols[nCont][nPosDelet] .AND. !(nCont == nItem)
		cEntrega := ""
		If nPosEntrega > 0
			If ValType(aCols[nCont][nPosEntrega]) == "C"
				cEntrega := aCols[nCont][nPosEntrega]
			EndIf
		EndIf
		
		If LJXTpRetira(cEntrega)                        
			If ValType(aCols[nCont][nPosVlrItem]) == "N" .AND. nPosVlrItem > 0
				nTotal += aCols[nCont][nPosVlrItem]
			Endif	
		EndIf
	EndIf
Next

//Subtrai valor de desconto no total        
If lDescAcr
	nTotal -= Lj7T_DescV(2)		// Subtrai desconto total 
	nTotal += Lj7CalcFrete()	// Soma com o valor total de Frete
	nTotal += aAcrescimo[1]		// Calculo do valor de acrescimo total
EndIf

Return nTotal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJXTpRetira     ºAutor  ³Vendas Clientes º Data ³  08/07/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se o tipo de entrega eh retirada imediata			º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cEntrega : Tipo de entrega a ser analisado.    				º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Loja701                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/									
Function LJXTpRetira(cEntrega)     
Local lRet := .F.

Default	cEntrega	:= ""

cEntrega := AllTrim(cEntrega)

lRet :=	(	Empty(cEntrega)		) .OR.	;
		(	cEntrega == "2"		)
		
Return lRet               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjPclIdCar ºAutor  ³  Vendas & CRM      º Data ³  24/05/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Mensagem para Template de Posto de Combustivel     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - Mensagem: Placa/KM                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TPL - Postos de Combustiveis e Lubrificantes               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjPclIdCar()                 
Local cTexto := ""
                             
If !Empty(AllTrim(cPlaca))
	cTexto := STR0247 + AllTrim(cPlaca) + "  " //"Placa:" 
EndIf

If !Empty(AllTrim(cKm))
	cTexto += STR0254 + AllTrim(cKm) + "  " //" Km:"
EndIf

Return( cTexto )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LjxTipArq	  ³ Autor ³ Vendas Clientes     ³ Data ³ 14/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a montagem da tela para que possa ser informado	  ³±±
±±³          ³ o tipo de arquivo que sera gerado 1=Sintegra 2=Sped	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Se for precionado o botao de Ok.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT\SIGALOJA                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxTipArq(	cTitulo	, nOpcao )	

Local oDlg          := Nil
Local oTipoRel		:= Nil			   // Objeto para o tipo de arquivo a ser gerado
Local nTipoRel		:= 1			   // Variavel que tera o tipo de relatorio 1= Sintegra 2=Sped
Local lRetValue     := .F.

	DEFINE MSDIALOG oDlg FROM  15,6 TO 260,300 TITLE cTitulo PIXEL
	
	@ 013,008 Radio oTipoRel Var nTipoRel Items "CONVENIO 57/95", "ATO COTEPE 09/08" 3D Size 85,10 PIXEL OF oDlg 
	
	nOpcao := nTipoRel	
				
	DEFINE 	SBUTTON   oBtnOk     ;
            FROM      100, 087   ;
            TYPE      1          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .T., oDlg:End() )
	
	DEFINE 	SBUTTON   oBtnCancel ;
            FROM      100, 115   ;
            TYPE      2          ;
            ENABLE OF oDlg       ;
            ACTION    ( lRetValue := .F., oDlg:End() )
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
nOpcao := nTipoRel

Return( lRetValue )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxNomeArq  ³ Autor ³ Vendas Clientes     ³ Data ³ 14/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a montagem do nome do arquivo para opcao 12 no menu³±±
±±³          ³ fiscal													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cNomeArq - retorna o nome do arquivo					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT\SIGALOJA                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxNomeArq()	
Local cDiaMes   := SubStr(StrTran(DtoC(Date()), "/"), 1 , Len(StrTran(DtoC(Date()), "/")) - 2) 
Local cAno      := cValToChar(Year(Date())) 
Local cNomeArq  := ""
Local cNumLaudo	:= "POL1892015"

cNumLaudo:= STBVerPAFECF("NUMLAUDO")
cNomeArq := cNumLaudo + cDiaMes + cAno + StrTran( Time(), ":") + ".txt"

Return cNomeArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxArqIdPaf ³ Autor ³ Vendas Clientes     ³ Data ³ 30/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Arquivo PAFLISTA									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT\SIGALOJA                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxArqIdPaf(lContinua)
STxArqIdPaf()
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} LjxDMD5Arqs
Função para resgatar o MD-5 dos arquivos de acordo com a versão 
do Paf-ecf

@author Varejo
@since 29/04/2015
@version P11.80
@obs Excluir Futuramente e deixar somente a função do STBPAFECF
*/
//-------------------------------------------------------------------
Function LjxDMD5Arqs( lTotvsPDV , cLaudoPAF )
Local aArqPAFServer	:= {}
Local aArqPAFSmart	:= {}

Default lTotvsPDV := .F.
Default cLaudoPAF := STBVerPAFECF("NUMLAUDO")

STBMD5Arqs(lTotvsPDV , cLaudoPAF)

Return { aArqPAFSmart , aArqPAFServer }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxCooDav   ³ Autor ³ Vendas Clientes     ³ Data ³ 30/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza COO quando emite DAV por ECF					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT\SIGALOJA                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function LjxCooDav(cL1Num, cCoo)
Local cPafMd5 := ""
   
DbSelectArea("SL1")
SL1->(DbSetOrder(1))      // L1_FILIAL + L1_NUM
     
If SL1->(DbSeek(xFilial("SL1")+cL1Num))	
		
	Reclock("SL1",.F.)
	SL1->L1_COODAV	:= cCoo	
	SL1->(MsUnlock())
	
	//Gera chave MD5
	cPafMd5 := STxPafMd5("SL1")
	Reclock("SL1",.F.)
	SL1->L1_PAFMD5	:= cPafMd5
	SL1->(MsUnlock())
EndIf
   
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxGrvMdz	  ³ Autor ³ Vendas Clientes     ³ Data ³ 30/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava tabela de apoio MDZ								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFRT\SIGALOJA                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function LjxGrvMdz(	cSimbol, nValor, cTipo, cNomeCli,;
					cCgcCli)
/*
cSimbol =
"RP" -> Registro do PAF - para validar o E2 e P2
"R4" -> Venda cancelada
"NC" -> Operacao Nao Fiscal Cancelamento ( Registro R06 do Ato Cotepe )
"CN" -> Operacao Nao Fiscal ( Registro R06 do Ato Cotepe )
"RG" -> Relatorio Gerencial ( Registro R06 do Ato Cotepe )
"LX" -> Leitura X ( Registro R06 do Ato Cotepe )
"MF" -> Leitura Memoria Fiscal Completa e Simplificada ( Registro R06 do Ato Cotepe )
"RZ" -> Redução Z ( Registro R06 do Ato Cotepe )
"PV" -> Primeira Venda
"XM" -> XML do Estoque
"M5" -> MD5 do Arquivos Principais
*/
Local cCoo 		:= ""
Local cGnf 		:= "000000"
Local cGrg		:= "000000"
Local cCdc		:= "000000"
Local cCCF		:= "000000"
Local cSerPdv	:= ""
Local cPafMd5	:= ""
Local cPDV		:= ""
Local cMDZFil	:= ""
Local cMDZNum	:= ""
Local cSerie	:= ""
Local cHrRetEcf := ""
Local nRecno	:= 0
Local nRet		:= 0
Local lDavRet	:= (!SuperGetMV('MV_LJPRVEN',,.T.) .And. SuperGetMV('MV_LJDAVEC',,.F.)) //Impressao de DAV no ECF da Retaguarda
Local lGrava	:= .T.
Local lTotvsPDV	:= STFIsPOS()
Local aAreaMDZ	:= {}
Local lLjNfPafEcf:= LjNfPafEcf(SM0->M0_CGC)
Local aRet		:= {.F.} 

Default cSimbol := ""                   
Default cTipo	:= ""
Default nValor  := 0
Default cNomeCli:= ""
Default cCgcCli	:= ""

DbSelectArea("MDZ")
aAreaMDZ := MDZ->(GetArea())

If lLjNfPafEcf .And. (lMvLjPdvPa .Or. lDavRet .Or. lTotvsPDV)
	cSerPdv := If( lTotvsPDV , STFGetStat("SERPDV") ,  LjGetStation("SERPDV"))	
	
	//Só posso deixar gravar um registro "RP|PV" no dia
	//Tambem retorna .F. se estiver gravado o registro "M5"
	lGrava := LjxDGerMdz(cSimbol)
	
	If lGrava
		If !IsBlind()
			If lTotvsPDV
				STWGetReceipt( @cCoo )
				STWGetPDV(@cPDV)
				cSerie := PadR(STFGetStat("SERIE"), TamSx3("LG_SERIE")[1])
				
				If cSimbol == "R4"
					STWPrinterStatus("35", @cCCF)
				ElseIf cSimbol <> "NC"

					STWPrinterStatus( "36", @cGnf)
			
					If cSimbol == "RG"
						STWPrinterStatus("37", @cGrg)
					EndIf
				EndIf
			Else
				IfPegCupom( nHdlECF, @cCoo )
				IFPegPDV(nHdlECF, @cPDV)
				cSerie := PadR(LjGetStation("SERIE"), TamSx3("LG_SERIE")[1])
					 
				If cSimbol == "R4"
					IFStatus(nHdlECF, "35", @cCCF)
				ElseIf cSimbol <> "NC"
						
					IFStatus(nHdlECF, "36", @cGnf)		
					
					If cSimbol == "RG"
						IFStatus(nHdlECF, "37", @cGrg)		
					EndIf		
				EndIf
			EndIf
		EndIf	
		
		cMDZNum	:= ""		
		lGrava	:= LjxConfMDZ( @cMDZNum )
	EndIf

	If lGrava
		RecLock("MDZ" , .T.)
		nRecno := MDZ->(Recno())
		MDZ->MDZ_NUM	:= cMDZNum
		MDZ->MDZ_FILIAL	:= xFilial("MDZ")
		MDZ->MDZ_PDV	:= cPDV
		MDZ->MDZ_COO 	:= cCoo
		MDZ->MDZ_GNF 	:= cGnf
		MDZ->MDZ_GRG 	:= cGrg
		MDZ->MDZ_CDC	:= cCdc
		MDZ->MDZ_CCF	:= cCCF
		MDZ->MDZ_SIMBOL	:= cSimbol
		MDZ->MDZ_TIPO	:= cTipo
		MDZ->MDZ_VALOR	:= nValor
		MDZ->MDZ_SERPDV	:= cSerPdv
		MDZ->MDZ_SERIE 	:= cSerie
		MDZ->MDZ_DATA	:= dDataBase
		
		//Conforme legislação: Deve-se retornar a data do ECF
		If !IsBlind()
			If lTotvsPDV
				nRet := STWPrinterStatus( "1", @cHrRetEcf)
			Else
				nRet := IFStatus( nHdlECF, '1', @cHrRetEcf )
			EndIf
		Else
			nRet := -1
		EndIf
		
		If nRet == 0
			MDZ->MDZ_HORA	:= SubStr(cHrRetEcf,1,5)
		Else
			MDZ->MDZ_HORA	:= Left( Time() , 5)
		EndIf		 
		
		MDZ->MDZ_NOMCLI	:= cNomeCli
		MDZ->MDZ_CGCCLI	:= cCgcCli
		
		REPLACE MDZ->MDZ_XMLEPA WITH " "
		REPLACE MDZ->MDZ_XMLRPA WITH " "
		REPLACE MDZ->MDZ_XMLENV WITH " "
		
		MDZ->(MsUnlock())	
		
		MDZ->(dbGoTo(nRecno))
		cPafMd5	:= STxPafMd5("MDZ") //Chave MD5	
		RecLock("MDZ",.F.)
		MDZ->MDZ_PAFMD5	:= cPafMd5
		MDZ->MDZ_SITUA	:= "00"
		MDZ->(MsUnlock())
		aRet := { .T. }
	EndIf
EndIf

//Usado para preservar em banco os dados os dados de MD5 e comparar caso seja 
//alterado seja mostrado no registro do PAF e diferença entre Retaguarda e PDV
If cSimbol == "M5" 
	cMDZNum := ""
	nRet := 0
	MDZ->(DbSetOrder(1)) //MDZ_FILIAL + MDZ_DATA
	MDZ->(DbSeek(xFilial("MDZ")))
	cMDZFil := xFilial("MDZ")
	While !MDZ->(Eof()) .And. MDZ->MDZ_FILIAL == cMDZFil
		If MDZ->MDZ_SIMBOL $ cSimbol
			nRet := 3 //Altera
			cMDZNum := MDZ->MDZ_NUM
			Exit
		EndIf
		MDZ->(DbSkip())
	End
	
	If nRet == 0
		nRet := 2
		cMDZNum := ""
		LjxConfMDZ( @cMDZNum )
	EndIf
	
	If nRet > 0
		RecLock("MDZ", IIF(nRet==3,.F.,.T.))
		nRecno := MDZ->(Recno())
		REPLACE MDZ->MDZ_NUM	WITH cMDZNum
		REPLACE MDZ->MDZ_FILIAL	WITH xFilial("MDZ")
		REPLACE MDZ->MDZ_PDV	WITH ""
		REPLACE MDZ->MDZ_COO 	WITH ""
		REPLACE MDZ->MDZ_GNF 	WITH ""
		REPLACE MDZ->MDZ_GRG 	WITH ""
		REPLACE MDZ->MDZ_CDC	WITH ""
		REPLACE MDZ->MDZ_CCF	WITH ""
		REPLACE MDZ->MDZ_SIMBOL	WITH cSimbol
		REPLACE MDZ->MDZ_TIPO	WITH cTipo
		REPLACE MDZ->MDZ_VALOR	WITH 0
		REPLACE MDZ->MDZ_SERPDV	WITH ""
		REPLACE MDZ->MDZ_SERIE 	WITH ""
		REPLACE MDZ->MDZ_DATA	WITH dDataBase
		REPLACE MDZ->MDZ_HORA	WITH Left( Time() , 5)
		REPLACE MDZ->MDZ_NOMCLI	WITH ""
		REPLACE MDZ->MDZ_CGCCLI	WITH ""
		REPLACE MDZ->MDZ_XMLEPA WITH cNomeCli //contem os dados do PAF-ECF
		REPLACE MDZ->MDZ_XMLRPA WITH cNomeCli //contem os dados do PAF-ECF
		REPLACE MDZ->MDZ_XMLENV WITH "X"
		MDZ->(MsUnlock())	
		
		MDZ->(dbGoTo(nRecno))
		cPafMd5	:= STxPafMd5("MDZ") //Chave MD5	
		RecLock("MDZ",.F.)
		REPLACE MDZ->MDZ_PAFMD5	WITH cPafMd5
		REPLACE MDZ->MDZ_SITUA	WITH "OK"
		MDZ->(MsUnlock())
		aRet := { .T. }
	EndIf
EndIf

If Len(aAreaMDZ) > 0
	RestArea(aAreaMDZ)
EndIf
	
Return aRet

//---------------------------------------------------------------------------
/*/
{Protheus.Doc} LjxDGerMdz
Função para verificar se o registro do tipo "RP|PV" já foi gravado e caso sim, 
impedir que outro seja gravado.
Chamada pelo FRTA020 também

@param	cSimbol , String, Tipo de MDZ que será gerada 
@author Varejo
@version P12
@since   03/08/2017
@return  lRet , Boolean , Retorno
/*/
//---------------------------------------------------------------------------
Function LjxDGerMdz(cSimbol)
Local aArea	:= {}
Local lGera := .T.

If cSimbol $ "RP|PV|M5"
	DbSelectArea('MDZ')
	aArea := MDZ->(GetArea())	
	MDZ->(DbSetOrder(1)) //Filial + Data
	
	If cSimbol == "M5"
		
		MDZ->(DbGoTop())
		While !MDZ->(Eof()) 
			If MDZ->MDZ_SIMBOL == "M5"
				lGera := .F.
				Exit
			EndIf
			MDZ->(DbSkip())
		End
	
	Else
	
		If MDZ->(DbSeek(xFilial('MDZ')+Dtos(dDataBase)))
			While !MDZ->(Eof()) .And. MDZ->MDZ_DATA == dDataBase .And. lGera
				If AllTrim(MDZ->MDZ_SIMBOL) $ cSimbol
					lGera := .F.
					If cSimbol == "RP"
						Conout('LjxDGerMdz - Nao gera o registro, pois ECF já fez a Reducao Z')
						LjGrvLog( Nil, 'Aviso - Nao gera o registro, pois ECF já fez a Reducao Z' )
					ElseIf  cSimbol == "PV"
						Conout('LjxDGerMdz - Nao gera o registro, pois ECF já teve primeira venda')
						LjGrvLog( Nil, 'Aviso - Nao gera o registro, pois ECF já teve primeira venda')
					EndIf
				EndIf
				MDZ->(DbSkip())
			End
		Endif
		
	EndIf

	RestArea(aArea)
EndIf

Return lGera

//-------------------------------------------------------------------
/*/{Protheus.doc} LjxDDelMdz
Deleção de MDZ especifico
@param cSimbol , String , Tipo de MDZ que será apagada
@author  Varejo
@version 	P12
@since   	03/08/2017
@return  	lRet , Boolean , Retorno
/*/
//-------------------------------------------------------------------
Function LjxDDelMdz(cSimbol,dData)
Local aArea	:= {}
Local lRet 	:= .T.

If !Empty(cSimbol)
	If Select('MDZ') > 0
		aArea := MDZ->(GetArea())
	Else
		DbSelectArea('MDZ')
	EndIf
	MDZ->(DbSetOrder(1)) //Filial + Data
	If MDZ->(DbSeek(xFilial('MDZ')+Dtos(dData)))
		While !MDZ->(Eof()) .And. MDZ->MDZ_DATA == dData
			If AllTrim(MDZ->MDZ_SIMBOL) $ cSimbol
				RecLock("MDZ",.F.)
				MDZ->(DbDelete())
				MDZ->(MsUnlock())
			EndIf
			MDZ->(DbSkip())
		End
	Else
		If MDZ->(DbSeek(xFilial('MDZ')+Dtos(dDataBase)))
			While !MDZ->(Eof()) .And. MDZ->MDZ_DATA == dData
				If AllTrim(MDZ->MDZ_SIMBOL) $ cSimbol
					RecLock("MDZ",.F.)
					MDZ->(DbDelete())
					MDZ->(MsUnlock())
				EndIf
				MDZ->(DbSkip())
			End
		EndIf
	Endif	
	
	If Len(aArea) > 0
		RestArea(aArea)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} LjxConfMDZ
Confere se o numero gerado na inicializacao da cesta esta correto , 
pois pode haver casos do XE/XF ficar corrompidos e
retornavam a mesma numeracao , alterando o orçamento.

@param 	cNumOrc		- Numero do Orcamento
@author  Julio.Nery
@version P12
@since   30/04/2020
*/
//-------------------------------------------------------------------
Function LjxConfMDZ( cNumOrc )
Local cMDZNum	:= ""
Local lRet		:= .T.
Local aMDZArea	:= {}

Default cNumOrc		:= ""

DbSelectArea("MDZ")
aMDZArea := MDZ->(GetArea())

cMDZNum := GetSxeNum("MDZ","MDZ_NUM")
ConfirmSx8()

MDZ->( DbSetOrder( 5 ) ) //MDZ_FILIAL, MDZ_NUM, R_E_C_N_O_, D_E_L_E_T_
cNumOrc := cMDZNum
LjGrvLog( "LjxConfMDZ" , "Numero do orcamento MDZ_NUM", cNumOrc )

While MDZ->(DbSeek(xFilial("MDZ")+cNumOrc))
	cMDZNum := GetSxeNum("MDZ","MDZ_NUM")		
	ConfirmSx8()
	cNumOrc := cMDZNum
End
RestArea(aMDZArea)

LjGrvLog( "LjxConfMDZ" , "Final de função - MDZ_NUM", cNumOrc )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxMd5CF   ºAutor  ³  Vendas & CRM      º Data ³  30/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna MD5 da PAFLISTA.TXT para emissao de cupom fiscal   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Chave MD5                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFRT\SIGALOJA                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxMd5CF()
Local cRet		:= ""		//MD-5 gravado no arquivo criptografado

cRet := STBMd5CF()

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxPAFMD5  ºAutor  ³  Vendas & CRM      º Data ³  16/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PAF-ECF													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - valor(PAFMD5) para validacao do Registro(PAF-ECF)  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFRT\SIGALOJA                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxPAFMD5(cAlias , cDadoAdic , cTipo)    
Local cPafMd5 := ""

cPafMd5 := STxPafMd5(cAlias , cDadoAdic , cTipo)
	
Return cPafMd5       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxReadFileºAutor  ³  Vendas & CRM      º Data ³  04/08/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza leitura de arquivo texto e armazena em Array		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpA1 - Array com conteudo do arquivo texto limitado a 32Kbº±±
±±³          ³         Retorna Len() = 1 com mensagm de falha na leitura  º±±
±±³          ³         Retorna Recno da leitura na ultima posicao do Arrayº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Path do arquivo                                     º±±
±±º          ³ ExpC2: Nome do arquivo	                                  º±±
±±º          ³ ExpN3: Recno para leitura a partir de uma posicao          º±±
±±º          ³ ExpL3: Deleta arquivo apos leitura finalizada(nRecno==0)	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFRT\SIGALOJA                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxReadFile(	cPath		, cFile		, nRecNo	, lDelFile	,;
 						nFatorMax	)
Local aRet	 		:= {}		//array de retorno 
Local nHandle		:= 0		//handle do arquivo
Local cLine			:= ""		//conteudo a ser adicionado no array
Local nLength		:= 0        //bytes lidos
Local n32Kbts		:= 32768	//bytes(32kb)
Local nMaxLength	:= 0
Local nBytesCrLf	:= 2      	//bytes
Local lProcessa		:= .T.		//sinaliza erro na leitura
Local cMsg			:= ""
                        
Default cPath			:= "" 		//Path do arquivo
Default cFile			:= ""       //Nome do arquivo
Default nRecNo			:= 0		//Recno para leitura a partir de uma posicao, quando 0(zero) inicio do arquivo
Default lDelFile		:= .F.		//Delete arquivo apos leitura finalizada(nRecno==0)
Default nFatorMax		:= 0 

cMsg := "Inicio da Função LjxReadFile"
Conout(cMsg)
LjGrvLog(NIL,cMsg)

/*
Efetuo o calculo para transmissão do arquivo
e o maximo limitado sera 1 Mb por vez de transmissão pois o server emite mensagem de warning (qdo passa)
 -Sera usado como fator para transmitir por vez, no maximo, 1Mb ( a conta será: Fator * 32Kb )
 
 se Fator = 10
 
 10 * 32768 = 327680 Bytes ou 327,68 Kb
*/
If nFatorMax > 0
	If nFatorMax > 20
		nFatorMax := 10
	EndIf
	nMaxLength := n32Kbts * nFatorMax
Else
	nMaxLength := n32Kbts
EndIf

//Verifica se o arquivo existe
If !File(cPath + cFile)
	lProcessa := .F.                   
	cLine	:= STR0267 + cPath + cFile 											//"Arquivo não encontrado:"
	Aadd(aRet,cLine) 
EndIf
     
//Abre o arquivo
If lProcessa
	nHandle := FT_FUse(cPath + cFile)
	If nHandle = -1
		lProcessa 	:= .F.	
		cLine		:= STR0268 + cPath + cFile		//"Não foi possível abrir o arquivo:"
		Aadd(aRet,cLine) 
	EndIf
EndIf
  
//Realiza leitura do arquivo texto
If lProcessa
	//Posiciona o cursor no inicio ou no ponto onde parou
	If nRecNo == 0
		FT_FGoTop() 	
	Else
		FT_FGoto( nRecNo )
	EndIf
	
	While !FT_FEOF() //.OR. nLength < nMaxLength
		 
		cLine 	:= FT_FReadLn() // Retorna dados da linha corrente
		        
		nLength += Len(cLine) + nBytesCrLf //Soma 2 bytes da linha
		
		Aadd(aRet,cLine) //Inclui linha na Array
		
		//Proxima linha
		FT_FSKIP()
		
		nRecNo	:= FT_FRecno() // Retorna o ponteiro da linha atual
		
		cMsg := "Leitura da Linha - recno do arquivo :" + cValToChar(nRecno)
		Conout(cMsg)
		LjGrvLog(NIL,cMsg)
		
		If nFatorMax > 0 .AND. nLength >= nMaxLength
			cMsg := "Uso de Max selecionado"
			Conout(cMsg)
			LjGrvLog(NIL,cMsg)
			Exit
		EndIf
	End              
	
	//Se final de arquivo(EOF), sinaliza que terminou a leitura
	If FT_FEOF()                        
		nRecNo := 0
	EndIf
	
	//Sinaliza na ultima posicao do array se finalizou leitura do arquivo(nRecNo=0) ou (nRecNo=Recno onde parou)
	Aadd(aRet,Str(nRecNo))
	
	// Fecha o Arquivo
	FT_FUSE()
	
	//Remove arquivo lido
	If nRecNo == 0 .AND. lDelFile
		FErase(cPath + cFile)
	EndIf
EndIf	

cMsg := "Final da Função LjxReadFile"
Conout(cMsg)
LjGrvLog(NIL,cMsg,aRet)

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxGetFile ºAutor  ³  Vendas & CRM      º Data ³  16/12/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PAF-ECF													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpC1 - Path do arquivo no server que sera acessado via RPCº±±
±±º			   ExpC2 - Nome do arquivo no server que sera acessado via RPCº±±
±±º			   ExpC3 - Path local onde sera gerado o arquivo			  º±±
±±º			   ExpC4 - Nome do arquivo que ser gerado 					  º±±
±±º			   ExpL5 - Apos a leitura se deve excluir o arquivo origem	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFRT\SIGALOJA                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxGetFile(	cPathOri	,cFileOri	,cPathDest	,cFileDest	,;
 						lDelOri 	)
Local lRet 			:= .F.                      
Local aRet			:= {}
Local lContinua		:= .T.
Local oRPCServer
Local cRPCServer	:= ""
Local nRPCPort      := 0
Local cRPCEnv       := ""
Local nHandle		:= 0
Local cRPCEmp       := ""
Local cRPCFil       := ""
Local nSec1			:= 0
Local nSec2			:= 0
Local nHndRemoto	:= 0
Local nBkpTam		:= 0
Local cBuffer		:= ""
Local nTamFile		:= 0
Local nQtdeLida		:= 0
Local nReadTime		:= 0

Default cFileOri	:= ""		//Nome do arquivo no server que sera acessado via RPC
Default cPathOri	:= ""		//Path do arquivo no server que sera acessado via RPC
Default cFileDest	:= ""		//Nome do arquivo local que gerado
Default cPathDest	:= ""		//Path do arquivo local
Default lDelOri		:= .F.		//Sinaliza se apos a leitura devera excluir o arquivo no server

aRet := LjGetStation({"RPCSRV", "RPCPORT", "RPCENV", "RPCEMP","RPCFIL" })
                 
//Apaga destino caso já exista
If File(cFileDest)
	FErase(cFileDest)
EndIf                  

cRPCServer	:= aRet[1]
nRPCPort	:= Val(aRet[2])
cRPCEnv		:= aRet[3]	
cRPCEmp     := aRet[4]	
cRPCFil     := aRet[5]	

oRPCServer	:= FwRpc():New( cRPCServer, nRPCPort , cRpcEnv ) 
oRPCServer:SetRetryConnect(1)   

If !oRPCServer:Connect( cRPCServer, nRPCPort )
	lContinua := .F.
EndIf 

If lContinua
	oRPCServer:CallProc("RPCSetType", 3 )
	oRPCServer:SetEnv(cRPCEmp, cRPCFil)
	nBufferMaximo := 262144

	nHndRemoto := oRPCServer:CallProc("fOpen",cPathOri + cFileOri)
	nTamFile := oRPCServer:CallProc("fSeek",nHndRemoto,0,2)
	oRPCServer:CallProc("fSeek",nHndRemoto,0)
	nHandle := fCreate(cPathDest + cFileDest)
	nBkpTam := nTamFile

	While nTamFile > 0 
		nReadTime := Min(nTamFile,nBufferMaximo)
		cBuffer := Space(nReadTime)
		aRet := oRPCServer:CallProc("ljfRead",nHndRemoto, cBuffer , nReadTime)

		nQtdeLida := aRet[1]
		cBuffer := aRet[2]
		nTamFile -= nQtdeLida

		fWrite(nHandle,cBuffer)
		ConOut("Quantidade Lida: " - cValToChar(nQtdeLida) + " Quantidade Restante: " + cValToChar(nTamFile) + " Total: " + cValToChar(nBkpTam))
	End 

	nSec2 := Seconds()-nSec1

	LjGrvLog( Nil, "-------------------------------------------------------------------")
	LjGrvLog( Nil, "Tempo de espera na Copia de um arquivo: " + AllTrim(Str(nSec2)))
	LjGrvLog( Nil, "-------------------------------------------------------------------")

	fClose(nHandle)
	oRPCServer:CallProc("fClose",nHndRemoto)

	//Fecha arquivo 
	If nHandle > 0
		fClose(nHandle)   
		lRet := .T.
	EndIf
Else
	LjGrvLog( Nil, "Não foi possível obter conexão RPC!")
EndIf

Return lRet
                                                              
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxPathSrvº Autor  ³  Vendas & CRM      º Data ³  04/08/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna  StatrPath do Servidor RPC						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFRT\SIGALOJA                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxPathSrv()    
Local cRet	:= ""
Local aRet	:= {}
Local lTotvsPdv	:= STFIsPOS()

LjGrvLog( Nil, " Pesquisa do Caminho do Servidor")

//Tratamento para Linux onde a barra e invertida eh realizado na LjxGetPath
If lTotvsPdv
	STFMessage("LjxPathSrv", "RUN", "Pesquisando caminho do servidor",;
				{ || STBRemoteExecute("LjxGetPath", NIL, NIL, .F.,@aRet) }) //"Gerando Arquivo..."
	STFShowMessage("LjxPathSrv")
Else
	aRet :=	FR271CMyCall( "LjxGetPath",Nil,"","")
EndIf

LjGrvLog( Nil, " Retorno - Pesquisa do Caminho do Servidor", aRet)

If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. ValType(aRet[1]) == "C"
	cRet := aRet[1]
EndIf

LjGrvLog( Nil, "Caminho do Servidor", cRet)
                 
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjAjusFiX5³ Autor ³ Vendas Clientes       ³ Data ³ 28.03.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Filial do SX5     				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡ao³ Tratamento para DAV e PRE que devem passar a ser exclusivos³±±
±±³          ³ Rodar UpdLoj23 para ajustar DAV e PRE no SX5 como exclusivo³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjAjusFiX5(cFilX5, cSerie)    
Local aArea 	:= GetArea()
Local cFilExc	:= FWCodFil()

DEFAULT cFilX5	:= xFilial("SX5")
DEFAULT cSerie	:= IIF(SuperGetMv("MV_LJPRVEN",,.T.), SuperGetMv("MV_LJSERPRE",,"PRE"), SuperGetMv("MV_LJSERDAV",,"DAV"))

DbSelectarea("SX5")     
If SX5->(DbSeek(cFilExc + "01" + cSerie))
	cFilX5 := cFilExc
EndIf

RestArea(aArea)
Return cFilX5

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjLimpaChq³ Autor ³ Vendas Clientes       ³ Data ³ 16.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa os dados de cheque para a proxima venda              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjLimpaChq()    
       
If ValType(aDadosCheq) == "A"  
	aDadosCheq := {}
EndIf

Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LjRetForma³ Autor ³ Vendas Clientes       ³ Data ³05/06/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o codigo da NATUREZA de acordo com a Forma de Pagto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Descricao da forma de pagamento padrao			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjRetForma(cForma) 
Local cDescrForma := ""
Local cSimbMoeda  := Alltrim(SuperGetMv("MV_SIMB1"))

Do Case 
	Case AllTrim(cForma) == cSimbMoeda
		cDescrForma	:= 	&(SuperGetMV("MV_NATDINH"))
	Case AllTrim(cForma) == "VA"
		cDescrForma	:= &(SuperGetMV("MV_NATVALE"))
	Case AllTrim(cForma) == "CC"
		cDescrForma	:= &(SuperGetMV("MV_NATCART"))
	Case AllTrim(cForma) == "CH"
		cDescrForma	:= &(SuperGetMV("MV_NATCHEQ"))							
	Case AllTrim(cForma) == "CD"
		cDescrForma	:= SuperGetMV("MV_NATTEF")
	    If SubStr(cDescrForma,1,1) == "&"
	    	cDescrForma := SubStr(cDescrForma,2,Len(cDescrForma))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se MV_NATTEF Iniciar com & passo o conteudo apartir do segundo byte para ser expandido via macro,  ³
			//³ senao passo o label para na expansao pegar o conteudo                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						    	
	    	cDescrForma	:= &(cDescrForma)
	    ElseIf SubStr(cDescrForma, 1, 1) == "'"
    		cDescrForma	:= &(SuperGetMV("MV_NATTEF"))
	    EndIf											

	Case AllTrim(cForma) == "CO"
		cDescrForma	:= &(SuperGetMV("MV_NATCONV"))
	Case AllTrim(cForma) == "FI"
		cDescrForma := &(SuperGetMV("MV_NATFIN"))
	Otherwise
		cDescrForma := &(SuperGetMV("MV_NATOUTR"))
EndCase					   					
							
Return(cDescrForma)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LjNextNumNt³ Autor ³ Igor Franzoi          ³ Data ³05/06/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encontra o número de Nota, só em caso de conflitos p/ DAV   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna o número DAV a ser utilizado, e grava no SX5		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjNextNumNt(cSerie,cNumNota,nTamDoc)

Local aArea		:= GetArea()

Local lRet		:= .F.
Local cAuxPes	:= xFilial("SL1")+Padr(cSerie,TamSx3("L1_TPORC")[1])
Local cKeyPes	:= ""
Local nOrdSL1	:= RetOrdem("SL1","L1_FILIAL+L1_TPORC+L1_NUMORC")

cSerie	 := Padr(cSerie,TamSx3("L1_TPORC")[1])
cNumNota := Padr(cNumNota,TamSx3("L1_NUMORC")[1])

cKeyPes	 := xFilial("SL1")+cSerie+cNumNota

dbSelectArea("SL1")
SL1->(dbSetOrder(nOrdSL1))

If SL1->(dbSeek(cKeyPes))

	While SL1->(!Eof() .and. AllTrim(L1_FILIAL+L1_TPORC) == cAuxPes)
		If AllTrim(SL1->(L1_FILIAL+L1_TPORC+L1_NUMORC)) == cKeyPes
			cNumNota := PadR( strzero(val(cNumNota)+1,len(AllTrim(cNumNota))) , nTamDoc )
			cKeyPes  := xFilial("SL1")+cSerie+cNumNota
		EndIf
		SL1->(dbSkip())
	EndDo

	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxMd5File³ Autor ³ Vendas Clientes       ³ Data ³12/07/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recebe Arquivo com Path para calculo do codigo MD-5        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Codigo MD-5 do arquivo							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                                  
Function LjxMd5File( cFile )

Local cRet := Upper(STBMd5File( cFile ))

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxImpItMF³ Autor ³ Vendas Clientes       ³ Data ³29/08/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressão dos Itens do Menu Fiscal por Relatorio Gerencial  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³REQUISITO PAF-ECF 2012												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxImpItMF( cItem , cTexto , nVias )
Local nRet := 0

nRet := STBImpItMF(cItem , cTexto , nVias, .F.)

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjxLeRelGer³ Autor ³ Vendas Clientes      ³ Data ³31/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua a leitura dos Relatorios Gerenciais cadastrados no ECF±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³REQUISITO PAF-ECF 2012												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjxLeRelGer()
Local aTot		 := {} 
Local cDirClient := GetClientDir()
Local cMsg		 := ""
Local nI		 := 0
Local lTplAbPend := HasTemplate("PCL") .AND. ExistTemplate("TpPclAPend")   //Indica que esta utilizando o template de posto e a Rotina de Abastecimentos Pendentes 

If SuperGetMV("MV_LJDAVOS",,.F.)
	AAdd(aTot , {	"DAV-OS's Emitidos"			, GetPvProfString("PAF-ECF","OrdemServico"	, ""	, cDirClient+"SIGALOJA.INI") })
Else
	AAdd(aTot , {	"DAVs Emitidos"				, GetPvProfString("PAF-ECF","DAV"			, ""	, cDirClient+"SIGALOJA.INI") })
EndIf	
AAdd(aTot , {   "Meios de Pagamento"		, GetPvProfString("PAF-ECF","MeiosPagto"	, ""	, cDirClient+"SIGALOJA.INI") })
AAdd(aTot , {   "Parametros de Configuracao", GetPvProfString("PAF-ECF","ParamConfig"	, ""	, cDirClient+"SIGALOJA.INI") })
AAdd(aTot , {   "Identificação do PAF"		, GetPvProfString("PAF-ECF","IdPaf"			, ""	, cDirClient+"SIGALOJA.INI") })
AAdd(aTot , {"Documento Auxiliar de Venda - Orcamento", GetPvProfString("PAF-ECF","DAVECF", "", cDirClient+"SIGALOJA.INI") })
If lTplAbPend
	AAdd(aTot , {   "Abastecimentos Pendentes"	, GetPvProfString("PAF-ECF","AbastePendente"	, ""	, cDirClient+"SIGALOJA.INI") })
	AAdd(aTot , {   "Controle de Encerrantes"	, GetPvProfString("PAF-ECF","Encerrantes"		, "" 	, cDirClient+"SIGALOJA.INI") })
EndIf

For nI := 1 to Len(aTot)
	If AllTrim(aTot[nI][2]) == ""
		cMsg += " - " + aTot[nI][1] +CHR(13)
	EndIf
Next nI

If !(AllTrim(cMsg) == "")                                                     
	MsgAlert("Verifique se o Relatório(s) Gerencial(is) para impressão de: " +;
			 CHR(13) + cMsg +;
			 "Exigido(s) no Requisito VII do Ato Cotepe 06/08, está(ão) cadastrado(s) no arquivo SIGALOJA.INI e no ECF")				
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³LjxManBombºAutor  ³Vendas Clientes     º Data ³  27/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a lista de Substituicao da Bomba 				   	  º±±
±±º			 ³para a data selecionada									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxManBomb(dDataIni, dDataFim, lArqTxt, cFile)
Local cQuery		:= ""          
Local cAlias		:= "LEJ"
Local cFilial		:= ""
Local cPath		:= ""
Local cConteudo	:= ""
Local cCnpj		:= ""
Local cStrAux	:= "" //Variavel auxiliar para efetuar as conversões, remover caractres, etc.
Local lRet		:= .T.    
Local nHandle   := 0   
Local nTotReg	:= 0
Local cMotivo	:= ""
Local cIndex	:= ""		// cindice da tabela LEJ
Local nIndex	:= 0		// indice da tabela LEJ
Local cChave	:= ""		//Chave geral da pesquisa

Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase
Default cFile		:= ""

If dDataIni > dDataFim
	MsgStop("Data de início maior que a data final. Verifique")
	lRet := .F.
EndIf

//Deve efetuar a pesquisa no PDV

cFilial := xFilial("LEJ")

#IFDEF TOP
	cAlias := "LEJTMP"
	
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("LEJ") + " As LEJ "
	cQuery += " WHERE LEJ_FILIAL = " + cFilial + " AND LEJ.D_E_L_E_T_ = '' "
	cQuery += " AND ( LEJ_DTSUB >= " + Dtos(dDataIni) + " AND LEJ_DTSUB <= " + Dtos(dDataFim) + " ) "
	cQuery += " ORDER BY LEJ_DTSUB "
	cQuery := 	ChangeQuery( cQuery )
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
	TcSetField(cAlias,"LEJ_DTSUB","D")	

	(cAlias)->(DbGoTop())

#ELSE

	DbSelectArea("LEJ")
	cIndex	:= CriaTrab(Nil,.F.)
	cChave	:= "LEJ_FILIAL+DTOS(LEJ_DTSUB)"
	IndRegua("LEJ",cIndex,cChave,,,STR0009) //"Selecionando Registros..."
	DbSelectArea("LEJ")
	nIndex  := RetIndex("LEJ")
	LEJ->(DbSetIndex( cIndex + OrdBagExt() ))
	LEJ->(DbSetOrder( nIndex + 1 ))
	LEJ->(DbSeek(xFilial("LEJ")+ DtoS(dDataIni),.T.))
	
#ENDIF	

If lRet
	If lRet .AND. LjxGerPath(@cPath)
			
		cFile := LjxGerFile( "B" )
		nHandle := FCREATE( cPath + cFile, FC_NORMAL )
		
		If nHandle < 0
			MsgStop(STR0191 + cPath + cFile) //"Erro ao criar arquivo "
			lRet := .F.
		Else
			cCnpj := PADR( SM0->M0_CGC, 14 ) //CNPJ

			// REGISTRO TIPO B1 - Identificacao do Estabelecimento Usuário do PAF
			cConteudo := "B1"
			cConteudo += cCnpj
			cConteudo += PADL( SM0->M0_INSC, 14 ) // Incricao Estadual
			cConteudo += PADL( SM0->M0_INSCM, 14 ) // Incricao Municipal
			cConteudo += PADR( SM0->M0_NOMECOM, 50 ) // Razao Social				
			cConteudo += CHR(13) + CHR(10)
			
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
		
			// REGISTRO TIPO B2 - Registros da Susbstituição da Placa
			While !(cAlias)->(Eof()) .AND. ((cAlias)->LEJ_FILIAL == cFilial) .AND. ((cAlias)->LEJ_DTSUB <= dDataFim)
				nTotReg++
				cConteudo := "B2"
				cConteudo += cCnpj
				cConteudo += PADR((cAlias)->LEJ_BOMBA , 3)
				cConteudo += PADR((cAlias)->LEJ_BICO  , 3)
				cConteudo += Dtos((cAlias)->LEJ_DTSUB)					//formato aaaammdd
				cConteudo += StrTran((cAlias)->LEJ_HRSUB,":","") + "00"  	//Formato hhmmss
				
				//Retorna o conteudo do campo da tabela SYP para mostrar na tela	
				cMotivo := MSMM((cAlias)->LEJ_CODMOT)
				If Empty(AllTrim(cMotivo))
					cMotivo := " "
				EndIf
				
				cMotivo := strtran(cMotivo,CHR(9),"")
				cMotivo := strtran(cMotivo,CHR(10),"")
				cMotivo := strtran(cMotivo,CHR(13),"")
				cConteudo += PADR(Substr(AllTrim(cMotivo),1,50) , 50 )
				
				cStrAux := AllTrim((cAlias)->LEJ_CNPJEM)
				If !Empty(cStrAux)
					cStrAux := StrTran(cStrAux,".","")
					cStrAux := StrTran(cStrAux,"/","")
					cStrAux := StrTran(cStrAux,"-","")
					cStrAux := Replicate("0", 14-Len(cStrAux)) + cStrAux
				Else
				    cStrAux := StrZero(0,14,0)
				EndIf
				cConteudo += PADR( cStrAux , 14 )
				
				cStrAux := AllTrim((cAlias)->LEJ_CPFTEC)
				If !Empty(cStrAux)
					cStrAux := StrTran(cStrAux,".","")
					cStrAux := StrTran(cStrAux,"-","")
					cStrAux := Replicate("0", 11-Len(cStrAux)) + cStrAux
				Else
					cStrAux := StrZero(0,11,0)
				EndIf
				cConteudo += PADR( cStrAux , 11 )
				
				cConteudo += PADR(AllTrim(cValToChar(Transform((cAlias)->LEJ_LACREM, "@E 999999999999999"))),15)
				cConteudo += PADR(AllTrim(cValToChar(Transform((cAlias)->LEJ_LACAPL, "@E 999999999999999"))),15)
				
				If (cAlias)->LEJ_ENCINI > 0
					cStrAux	  := AllTrim(Transform((cAlias)->LEJ_ENCINI, "@E 99,999,999,999.9999"))
					cStrAux	  := StrTran(cStrAux,".","")
					cStrAux	  := StrTran(cStrAux,",","")
					While Len(cStrAux) < 15
						cStrAux := "0" + cStrAux
					EndDo
					cConteudo += PADR(cStrAux, 15)
				Else
				    cConteudo += PADR( StrZero( (cAlias)->LEJ_ENCINI , 15 , 0 ) , 15 )
				EndIf	
					
				If (cAlias)->LEJ_ENCFIM > 0
					cStrAux	  := AllTrim(Transform((cAlias)->LEJ_ENCFIM, "@E 99,999,999,999.9999"))
					cStrAux	  := StrTran(cStrAux,".","")
					cStrAux	  := StrTran(cStrAux,",","")
					While Len(cStrAux) < 15
						cStrAux := "0" + cStrAux
					EndDo
					cConteudo += PADR(cStrAux, 15)
				Else
					cConteudo += PADR( StrZero( (cAlias)->LEJ_ENCFIM , 15 , 0 ) , 15 )
				EndIf	
				
				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
				
				(cAlias)->(DbSkip())
			EndDo
			
			// REGISTRO TIPO B9 - Total de registros
			cConteudo := "B9"
			cConteudo += cCnpj                        
			cConteudo += PADL( SM0->M0_INSC, 14 ) // Incricao Estadual
			cConteudo += PADR( StrZero(nTotReg,6,0), 6) 	// Total de Registros
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			FCLOSE( nHandle )
			
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³LjxTrcCardºAutor  ³Vendas Clientes     º Data ³  27/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a lista de Troco em Cartão	 				   	  		º±±
±±º			 ³para a data selecionada									  		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJXFUND                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxTrcCard(dDataIni, dDataFim, cFile)
Local cWSServer	:= AllTrim(LJGetStation("WSSRV"))            
Local cPath		:= ""
Local cConteudo	:= ""
Local cCnpj		:= ""
Local cStrAux	:= "" //Variavel auxiliar para efetuar as conversões, remover caractres, etc.
Local cNumFabEcf:= ""
Local cMFAdic	:= ""
Local cTipoEcf	:= ""
Local cMarcaEcf := ""
Local cModelEcf := ""
Local nValor	:= 0  
Local nX		:= 0
Local oWs 		:= WsFrtPafEcf():New() 
Local lRet		:= .T.    
Local nHandle   := 0   
Local nTotReg	:= 0

Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase
Default cFile		:= ""

If dDataIni > dDataFim
	MsgStop("Data de início maior que a data final. Verifique")
	lRet := .F.
EndIf


If lRet
	//Verifica se o servidor de WS esta configurado
	If Empty(cWSServer)
		MsgStop(STR0149) //"O servidor de Web Services não está configurado nesta estação"
		lRet := .F.
	EndIf
	
	If lRet
		//Ajusta o caminho do servico
		oWs:_URL := "http://"+cWSServer+"/FRTPAFECF.apw"
	
		//Executa o web service
		LJMsgRun(STR0154,,{||lRet := oWs:LstTrcCard(dDataIni,dDataFim, cEmpAnt, cFilAnt, lHomolPaf)}) // "Executando consulta na retaguarda"
	EndIf

	If !lRet
		Alert(STR0150 + GetWSCError()) //"Falha no Web Service: "
	EndIf
EndIf

If lRet	 
	
	If Len(oWs:oWsLstTrcCardResult:oWsTrcCrdList) == 0
		MsgInfo("Não foram encontrados registros de Troco em Cartão para o período solicitado") //"Não foram encontrados registros de Troco em Cartão para o período solicitado"
		lRet := .F.
	ElseIf !oWs:oWsLstTrcCardResult:oWsTrcCrdList[1]:lUsaTroco
	    MsgInfo("Ative o troco em Cartão no ambiente da retaguarda: MV_LJTROCO com .T. e/ou crie o campo L1_TROCO1") //"Ative o troco em Cartão no ambiente da retaguarda: MV_LJTROCO com .T. e/ou crie o campo L1_TROCO1"
	    lRet := .F.
	EndIf
		
	If lRet .AND. LjxGerPath(@cPath)
			
		cFile := LjxGerFile( "H" )
		nHandle := FCREATE( cPath + cFile, FC_NORMAL )
		
		If nHandle < 0
			MsgStop(STR0191 + cPath + cFile) //"Erro ao criar arquivo "
			lRet := .F.
		Else
			cCnpj := PADR( SM0->M0_CGC, 14 ) //CNPJ

			// REGISTRO TIPO H1 - Identificacao do Estabelecimento Usuário do PAF
			cConteudo := "H1"
			cConteudo += cCnpj
			cConteudo += PADL( SM0->M0_INSC, 14 ) // Incricao Estadual
			cConteudo += PADL( SM0->M0_INSCM, 14 ) // Incricao Municipal
			cConteudo += PADR( SM0->M0_NOMECOM, 50 ) // Razao Social

			LjDadosEcf()
			LjGetInfEcf("SERIE",@cNumFabEcf)
			LjGetInfEcf("24",@cMFAdic)
			LjGetInfEcf("25",@cTipoEcf) 
			
			cMarcaEcf := LjGetStation("IMPFISC")
			nX := At(" ",cMarcaEcf)
			cMarcaEcf := SubStr(cMarcaEcf,1,nX-1)
			
			LjGetInfEcf("27",@cModelEcf)
							
			cConteudo += PADR( cNumFabEcf, 20 )	//Numero de fabricação do ECF
			cConteudo += PADR( cMFAdic , 1 )	//Letra indicativa de MF adicional
			cConteudo += PADR( cTipoEcf, 7 )	//Tipo de ECF
			cConteudo += PADR( cMarcaEcf, 20 )	//Marca do ECF
			cConteudo += PADR( cModelEcf, 20 )	//Modelo do ECF
			cConteudo += CHR(13) + CHR(10)
			
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
		
			// REGISTRO TIPO B2 - Identificação do Titulo, do adquirente e da credenciadora
			For nX := 1 to Len(oWs:oWsLstTrcCardResult:oWsTrcCrdList)
				nTotReg++
				cConteudo := "H2"
				cConteudo += cCnpj

				cStrAux := AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCnpjAdm)
				If !Empty(cStrAux)
					cStrAux := StrTran(cStrAux,".","")
					cStrAux := StrTran(cStrAux,"/","")
					cStrAux := StrTran(cStrAux,"-","")
					cStrAux := Replicate("0", 14-Len(cStrAux)) + cStrAux
				Else
				    cStrAux := StrZero(0,14,0)
				EndIf
				cConteudo += PADR( cStrAux , 14 )
				
				cConteudo += PADR(AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCOO),6)
				cConteudo += PADR(AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCCF),6)
				
				nValor := oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:nTroco
				cStrAux:= AllTrim(Str(nValor))
				cStrAux:= StrTran(cStrAux , "." , "")
				cStrAux:= StrTran(cStrAux , "," , "")
				cStrAux:= Replicate("0" , 13 - Len(cStrAux)) + cStrAux
				cConteudo += PADR(cStrAux,13)
				
				cConteudo += PADR(Dtos(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:dDtEmissao),8)		//formato aaaammdd
				
				cStrAux := AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cCpfCli)
				cStrAux:= StrTran(cStrAux , "." , "")
				cStrAux:= StrTran(cStrAux , "-" , "")
				cStrAux := Replicate("0", 14-Len(cStrAux)) + cStrAux
				cConteudo += PADR(cStrAux, 14)
				
				cConteudo += PADR(AllTrim(oWs:oWsLstTrcCardResult:oWsTrcCrdList[nX]:cTitulo), 7 )

				cConteudo += CHR(13) + CHR(10)
				FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			Next nX

			// REGISTRO TIPO H9 - Total de registros
			cConteudo := "H9"
			cConteudo += cCnpj                        
			cConteudo += PADL( SM0->M0_INSC, 14 ) // Incricao Estadual
			cConteudo += PADL( SM0->M0_INSCM, 14 ) // Incricao Municipal
			cConteudo += PADR( StrZero(nTotReg,6,0), 6) 	// Total de Registros
			cConteudo += CHR(13) + CHR(10)
			FWRITE( nHandle, cConteudo, LEN( cConteudo ) )
			FCLOSE( nHandle )
			
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjGetB0Prv³ Autor ³ Vendas Clientes      ³ Data ³31/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se o preco do produto na tabela SB1 for zerado, utilizamos³±±
±±³			 | o preco da tabela SB0.									|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Valor do produto, segundo a tabela de preco (MV_TABPAD)	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LjxImpTabProd / LjxeValPre(LOJXFUNE)						³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGetB0Prv(cCod, cTabPreco)

Local aArea			:= {}
Local nPreco		:= 0				 //preco do produto, conforme a tabela de preco
Local nX			:= 0
Local cComplMen 	:= ""  				 //Complemento do campo da tabela SB0              
Local lCpoSB0		:= .F.

Default cCod		:= ""
Default cTabPreco	:= SuperGetMV("MV_TABPAD",,"1")

aadd(aArea,GetArea())

cComplMen	:= cCod
cTabPreco 	:= Alltrim(Str(Val(cTabPreco)))
lCpoSB0		:= SB0->(ColumnPos("B0_PRV" + cTabPreco)) > 0 // Verifica se o campo existe na tabela SB0

If lCpoSB0 .And. !Empty(cTabPreco)
	DbSelectArea("SB0")
	aadd(aArea,SB0->(GetArea()))
	SB0->( DbSetOrder(1) )	
	If SB0->( DbSeek(xFilial("SB0") + cComplMen ))      
		nPreco := &("B0_PRV" + cTabPreco)
	EndIf
EndIf	

For nX := 1 to Len(aArea)
	RestArea( aArea[nX] )
Next nX

Return nPreco                                                               

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjPerVendas³ Autor ³ Vendas Clientes      ³ Data³24/06/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pega o intervalo de datas informado e retorna em array     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Retorna Array com intervalo informado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LjxImpECF (LOJXFUND)					                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjPerVendas(dDataIni, dDataFim)
Local aPeriodos := {}    
Local nX		:= 0
Local nDifDias  := ( dDataFim - dDataIni )  // Diferenca de dias
                  
	If nDifDias == 0
		Aadd( aPeriodos, { dDataIni, dDataFim })			
	Endif
	
	For nX = 1 to nDifDias Step 4
	    
		If ( nDifDias - nX) >= 5
			Aadd( aPeriodos, { dDataIni, dDataIni + 4 })
			dDataIni := dDataIni + 5   
		Else
			Aadd( aPeriodos, { dDataIni, dDataFim })		
		Endif						
		
		If dDataIni > dDataFim
			aPeriodos[Len(aPeriodos)][2]:=dDataFim   
			Exit
		Endif	

	Next nX
	
Return aPeriodos  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjxGetPathº Autor  ³  Vendas & CRM      º Data ³   01/07/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna  StatrPath do Servidor RPC com tratamento Linux	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFRT\SIGALOJA                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxGetPath()    
Local cRet	:= ""
Local aRet	:= {}
          
cRet := GetSrvProfString("StartPath","")

//Tratamento para Linux onde a barra eh invertida
If GetRemoteType() == 2 // REMOTE_LINUX  
	If (SubStr(cRet,1,1)<>"/")
		cRet	:=	"/"+cRet
	EndIf
	
	If (SubStr(cRet,Len(cRet),1)<>"/")
		cRet	+=	"/"
	EndIf
Else
	If (SubStr(cRet,1,1)<>"\")
		cRet	:=	"\"+cRet
	EndIf
	
	If (SubStr(cRet,Len(cRet),1)<>"\")
		cRet 	+=	"\"
	EndIf	
EndIf           

Aadd(aRet,cRet)

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LjVlNumRep³ Autor ³ Vendas Clientes      ³ Data³ 27/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validar se o usuario esta digitando os mesmos numeros na  ³±±
±±³			 |na informacao CPF ou CNPJ 								|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Valor Logico                                          	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA / FONTLOJA										³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjVldNumRep(cCNPJCPF)
Local lRet := .F.

// Se repetir todos os numeros informados o retorno sera invalido
If Repl(Substr(cCNPJCPF,1,1), If(Len(cCNPJCPF) == 11, 11, 14)) == cCNPJCPF
	lRet := .T.       
Endif

Return(lRet)			


/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjFunDRent   		 ³ Vendas Cliente    º Data ³  03/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta retabilidade do(s) item(s) do orcamento/venda     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjFunDRent(nOpc)

Local aArea    := GetArea() //salva area
Local oDlg     := Nil // objeto msdialog
Local oRentab  := Nil // objeto listbox
Local aRentabil:={} // Array que sera descarregado na tela
Local aRFHead  := { " ",RetTitle("L2_PRODUTO"),RetTitle("L2_VLRITEM"),"C.M.V",STR0372,STR0373,STR0374}//  Campos da consulta //"Vlr.Presente"###"Lucro Bruto"###"Margem de Contribuição(%)"
Default nOpc	:=0

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0375) FROM 09,00 TO 34,100 //"Consulta Rentabilidade"
    
    aRentabil:=Lj701Rent(aRFHead,nOpc)
       
	@ 005,001 LISTBOX oRentab FIELDS TITLE aRFHead[1],aRFHead[2],aRFHead[3],aRFHead[4],aRFHead[5],aRFHead[6],aRFHead[7] SIZE 395,160 	OF oDlg PIXEL
	@ 170,270 BUTTON OemToAnsi(STR0376)		SIZE 040,11 ACTION LjFunDLeg() OF oDlg PIXEL		//"Legenda"
	@ 170,340 BUTTON OemToAnsi(STR0377)			SIZE 040,11 ACTION oDlg:End() OF oDlg PIXEL		//"Sair"
  	@ 170,001 Say STR0409 Size 230,020 OF oDlg PIXEL //"Obs.: 'Margem de Contribuição(%)' refere-se ao percentual de lucro calculado com base no VIrPresente (Vlr do Item c/ Descontos aplicados) - C.M.V. / VlrItem (Vlr do Item original)."
  	If Empty(aRentabil)
  		aRentabil   := {{" ","","0,00","0,00","0,00","0,00","0,00"}}
	EndIf
	oRentab:SetArray(aRentabil)
	oRentab:blDblClick := {|| LjFunDLeg()}
	oRentab:bLine := {|| aRentabil[oRentab:nAt] }
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT CursorArrow()

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj701Rent   		 ³ Vendas Cliente    º Data ³  03/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta retabilidade do(s) item(s) do orcamento/venda     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj701Rent(aRFHead, nOpc)

Local aRet:= {}       // array de retorno
Local aRentab:= {}    //array de rentabilidade
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]// Posicao da codigo do produto
Local nPosValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]	// Posicao do valor de desconto
Local nPosVlrItem	:= aPosCpo[Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_VLRITEM"})][2]	// Posicao do valor do item
Local nR            := 1   // contador
Local cMascNum      := PesqPict("SLR","LR_VLRITEM") // Mascara para valor numerico
Local cMascPor      := PesqPict("DTV","DTV_RENTAB")//"@E 9999.99"                 // Mascara para porcentagem
Local aTotRent      := {0,0,0,0,0}                 // array para o total  
Local nMargemVenda :=0                              // Margem da venda calculada
Local oMed		:= LoadBitmap(GetResources(), "BR_AMARELO") // botao para legenda
Local oMim		:= LoadBitmap(GetResources(), "BR_VERMELHO")//botao para legenda
Local oAlt		:= LoadBitmap(GetResources(), "BR_VERDE")   //botao para legenda
Local nRet      := 0 // contador
Local nPosDscPro	:= Ascan( aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_DESCPRO"} )

For nR:= 1 To Len(aCols)	
    If !aCols[nR][Len(aCols[nR])] .AND. !Empty(aCols[nR][nPosProd])
    	Aadd(aRet,Array(Len(aRFHead))  )
		nRet:= Len(aRet)	            
		//Carrega Array aRentab dentro da Função
		aRentab := {}
		Lj701MgV(nR,@aRentab,,,,nOpc)         
		nMargemVenda := StrTran(aRentab[1][6],".","") //retira a mascara e converte para numerico
		nMargemVenda := Val(StrTran(nMargemVenda,",","."))		
		If nMargemVenda < aRentab[1][7] 		
			aRet[nRet][1]:= oMim 
		ElseIf nMargemVenda >= aRentab[1][7] .AND. nMargemVenda <= aRentab[1][8] 		 		
			aRet[nRet][1]:= oMed 
		Else
			aRet[nRet][1]:= oAlt 
		EndIf
		aRet[nRet][2]:= aRentab[1][1]
		aRet[nRet][3]:= TransForm( Round(aRentab[1][2],nDecimais),cMascNum )
		aRet[nRet][4]:= TransForm( Round(aRentab[1][3],nDecimais),cMascNum )
		aRet[nRet][5]:= TransForm( Round(aRentab[1][4],nDecimais),cMascNum )
		aRet[nRet][6]:= TransForm( Round(aRentab[1][5],nDecimais),cMascNum )
		aRet[nRet][7]:= TransForm( Round(nMargemVenda,nDecimais),cMascPor )
		
		aTotRent[1]+= aRentab[1][2]
		aTotRent[2]+= aRentab[1][3]
		aTotRent[3]+= aRentab[1][4]
		aTotRent[4]+= aRentab[1][5]
		aTotRent[5]+= aCols[nR][nPosVlrItem] + aColsDet[nR][nPosDscPro] + aCols[nR][nPosValDesc]
		aRentab:={}
	EndIf 	
Next nR     

If Len(aRet)>0
	aTotRent[5]:= (aTotRent[4]/aTotRent[3])*100
	//Adiciona a linha de total
	aAdd(aRet,{" "   ,;
	          STR0378,;//"Total"
	          TransForm( Round(aTotRent[1],nDecimais),cMascNum ),;
	          TransForm( Round(aTotRent[2],nDecimais),cMascNum ),;
	          TransForm( Round(aTotRent[3],nDecimais),cMascNum ),;
	          TransForm( Round(aTotRent[4],nDecimais),cMascNum ),;
	          TransForm( Round(aTotRent[5],nDecimais),cMascPor ) } )
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LjFunDLeg³ Autor ³    Varejo             ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Legenda.                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjFunDLeg()

Local  aLegenda := {}   //array da legenda

aAdd( aLegenda, { "BR_VERDE"	, STR0379  } )//"Acima da Margem Regular"
aAdd( aLegenda, { "BR_AMARELO" 	, STR0380  } )//"Entre Margem Minima e Regular"
aAdd( aLegenda, { "BR_VERMELHO"	, STR0381  } )//"Abaixo da Margem Minima"    

BrwLegenda(STR0382,STR0376 ,aLegenda)//"Consulta Margem Minima"###"Legenda"

Return .T.

/*          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj701MgV ³ Vendas Clientes    º Data ³  09/08/13          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o desconto na novas regra de Des. Varejo             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjVldNDesc()												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Lj701MgV(nM,aRentab,nValDesc,nTotMarg,nVlrDesc,nOpc)         
Local aArea 	:= GetArea()    		//salva area
Local aAreaAIH	:= {} 					//salva area
Local aAreaAII	:= {} 					//salva area
Local cSeek:= ''                   		//efetua seek pata consulta da margem
Local cEspaco:=''                  		//espaco para o seek da margem
Local cWhile:= ''                   	//efetua while pata consulta da margem
Local cGrupoCli:= ''                	//seek pesquisa regra por grupo de clientes
Local lBloqueia:= .F.              		//bloqueia ou não a margem
Local nCustoAux:= 0                 	//armazena o custo
Local nPrecoAux:= 0                 	//armazena o preco
Local cMargem  := ''                	//armazena a margem
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]// Posicao da codigo do produto
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]	// Posicao da Quantidade
Local nPosValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]	// Posicao do valor de desconto
Local nPosVlrItem	:= aPosCpo[Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_VLRITEM"})][2]	// Posicao do valor do item
Local nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOCAL"})				// Posicao do local (armazem)
Local nPosDtFilRes 	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_FILRES" })				// Posicao do codigo da filial da empresa da reserva
Local nVlItem 		:= 0 //valor do item com impostos
Local nVlRatDesc	:= 0 
Local nMargMin      := 0 // margem minima cadastrada
Local nMargMed      := 0 // Margem media cadastrada
Local nMoeda        := SuperGetMV("MV_LJMDORC",,1)  //define moeda 
Local nPosDescPro   := Ascan (aHeaderDet,{|x| x[2] == "LR_DESCPRO"}) 
Local cFilBkp		:= cFilAnt				//Guarda a Filial atual
Local aAreaSM0		:= SM0->(GetArea())

Default nTotMarg	:= 0
Default aRentab := {}
Default nValDesc:= 0
Default nVlrDesc:= Lj7T_Subtotal(2)-Lj7T_Total(2)
Default nOpc		:= 0

aRentab:={}
/*
aRentab
[n]    Item do pedido
[n][1] codigo do produto
[n][2] Valor Total (unit * qtde)
[n][3] C.M.V. (custo)
[n][4] Valor Presente
[n][5] Lucro Bruto (Valor presente - CMV)
[n][6] Margem de Contribuicao (%) Lucro/Valor Presente
*/ 

nVlItem := IIf( MaFisFound("IT",nM),MaFisRet(nM,"IT_BASEDUP"),aCols[nM][nPosVlrItem])

If nOpc == 2 //visualização
	nVlItem		:= nVlItem - aColsDet[nM][nPosDescPro]
Else
	nVlRatDesc	:= A410Arred(nVlItem * aDesconto[3]/Lj7T_Subtotal(2),"L2_DESCPRO")

	If nValDesc > 0
        nVlItem := nVlItem + nVlRatDesc + aCols[nM][nPosValDesc] //Restaura valor original do item na venda
        nVlItem := nVlItem - nVlRatDesc - nValDesc //Aplica descontos        
    Else
        nVlItem	-= nVlRatDesc
    EndIf
EndIf

If !Empty(aCols[nM][nPosProd])
	//subtotal não tem desconto durante a venda
	aVencto:= { { dDataBase , Lj7T_SubTotal(2)+nTotMarg } }
	If !Empty(aColsDet[nM][nPosDtFilRes])
		cFilAnt := aColsDet[nM][nPosDtFilRes]
	EndIf	
	aRet:= PegaCMAtu(aCols[nM][nPosProd],aColsDet[nM][nPosDtLocal]) 
	nCustoAux += round(aCols[nM][nPosQuant]*aRet[nMoeda],nDecimais)
	//Restaura a Filial de Origem e Retorna a área da SM0
	cFilAnt := cFilBkp
	RestArea(aAreaSM0)
	nPrecoAux := MaValPres(nVlItem,dDataBase,,,dDataBase)
	nVlItem := aCols[nM][nPosVlrItem] + aColsDet[nM][nPosDescPro] + aCols[nM][nPosValDesc]	
	cMargem   :=  TransForm( ( ( nPrecoAux-nCustoAux)/ nPrecoAux) * 100 ,"@e 999,999,999.999999")
	aAdd(aRentab,{aCols[nM][nPosProd],nVlItem,nCustoAux,nPrecoAux,( nPrecoAux-nCustoAux) , cMargem ,,})

	//--------------------------------------------
	//pesquisa regra por o cliente 
	//--------------------------------------------
	If ( AliasIndic("AIH") .And. AliasIndic("AII") )

		aAreaAIH := AIH->(GetArea())
		aAreaAII := AII->(GetArea())

		cSeek := "xFilial('AIH') + '" + M->LQ_CLIENTE + M->LQ_LOJA + "'"
		cWhile := "!AIH->(Eof()) .AND. xFilial('AIH') == AIH->AIH_FILIAL .AND. + '" + M->LQ_CLIENTE + "' == AIH->AIH_CODCLI .AND. + '" + M->LQ_LOJA + "' == AIH->AIH_LOJA"
		lBloqueia := PesqCliGru(2, cSeek, cWhile, aRentab,@nMargMin,@nMargMed)
		 
		If !lBloqueia 
			//--------------------------------------------
			//pesquisa regra por grupo de clientes
			//--------------------------------------------
			cGrupoCli := Posicione("SA1",1 , xFilial("SA1") + M->LQ_CLIENTE + M->LQ_LOJA , "A1_GRPVEN")
			If !Empty(cGrupoCli)
				cSeek := "xFilial('AIH') + '" + cGrupoCli + "'"
				cWhile := "!AIH->(Eof()) .AND. xFilial('AIH') == AIH->AIH_FILIAL .AND. + '" + cGrupoCli + "' == AIH->AIH_GRPVEN " 
				lBloqueia := PesqCliGru(3, cSeek, cWhile, aRentab,@nMargMin,@nMargMed)
			EndIf
		EndIf
		
		If !lBloqueia 
			//--------------------------------------------------------------------------------------
			//pesquisa regra que sirva para qualquer cliente (codcli branco e grupo cli branco)
			//--------------------------------------------------------------------------------------
			cEspaco := Space(TamSx3("AIH_GRPVEN")[1]) + Space(TamSx3("AIH_CODCLI")[1]) + Space(TamSx3("AIH_LOJA")[1]) 
			cSeek := "xFilial('AIH') + '" + cEspaco + "'"
			cWhile := "!AIH->(Eof()) .AND. xFilial('AIH') == AIH->AIH_FILIAL .AND. AIH->AIH_GRPVEN+AIH->AIH_CODCLI+AIH->AIH_LOJA == '" + cEspaco + "' " 
			lBloqueia := PesqCliGru(3, cSeek, cWhile, aRentab,@nMargMin,@nMargMed)	
		EndIf

		aRentab[1][7]:= nMargMin
		aRentab[1][8]:= nMargMed
		
		RestArea(aAreaAIH)
		RestArea(aAreaAII)

	Else

		//As margens medias e minimas ficam nas tabelas AIH e/ou AII (Release 11.8 em diante)
		//Na inexistencia destas tabelas, as margens serao zeradas, e nao havera bloqueio por regra
		aRentab[1][7]:= 0
		aRentab[1][8]:= 0

	EndIf

EndIf	
	
RestArea(aArea)

Return(lBloqueia)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |LjXDDoeArredondar³ Autor ³ Vendas Clientes³ Data³ 15/10/13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pergunta se o cliente deseja doar para                    ³±±
±±³			  |o Instituto Arredondar										|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Valor Numérico, se zero não haverá doação                 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA / FRONTLOJA											³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjxDDoeArredondar(nAux)

Local 		nRet := 0
Default 	nAux := 0

/*
Extraio os centavos
Aplico a pergunta
Se sim,
 Crio uma outra variável para doação => nRet
 
Exemplo: nPagar = 549.38, dinheiro nVlrPag = 549.50, nAux := nVlrPag - nPagar := 0.12 -> será o parâmetro de entrada nAux  
Exemplo: nPagar = 547.50, dinheiro nVlrPag = 550.00, nAux := nVlrPag - nPagar := 2.50 -> será o parâmetro de entrada nAux  
Continuando, 2.50-noround(2.50)=0.50 -> caso afirmativo, será o valor a ser doado 
 
== SOMENTE BRASIL E PAGAMENTO EM DINHEIRO ==
*/

	nAux := nAux - NoRound(nAux,0)
 
	If nAux > 0
		If MsgNoYes(STR0384 + Alltrim( Transform( nAux, "@E 999.99" ) ) ;
				+ STR0385, STR0050)		//"Deseja doar 999,99 para o Instituto Arredondar?"#"Atenção"
			nRet	:= nAux
		EndIf
	EndIf

Return(nRet)			


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjxDInsArrTax     ºAutor  ³Varejo      º Data ³  04/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Se houver taxa administrativa no SAE,						  º±±
±±º          ³descontar a taxa também na doação - Instituto Arredondar    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.:     ³O registro original deve estar posicionado.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRTA271G                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjxDInsArrTax(nArredondar,aParcelas, nTipo)

Local aArea			:= GetArea()					// Guardar area anterior
Local lArredondar 	:= SuperGetMV( "MV_LJINSAR",,.F. )	// Parâmetro para habilitar doação ao Inst. Arredondar
LOCAL lAplicaTaxa	:= SuperGetMv('MV_LJTEFIA',,2)==1  // Aplica desconto da taxa administrativa na doação
Local cFilSAE		:= xFilial("SAE")						// Filial da tabela SAE
Local nTamAE_COD  	:= TamSx3("AE_COD")[1]			// Tamanho do campo AE_COD
Local nPctTaxAdm	:= 0							// % da Taxa da Administradora Financeira
Local cForma		:= ""							// Forma de pagamento realizada
Local cAdmFin		:= ""							// Administradora financeira escolhida 
Local nResult		:= nArredondar					// Resultado da doação com desconto
Local nPosForma	:= ""							// Posição da Forma de Pagamento em aParcelas[1]
Local nPosAdmFin	:= ""							// Posição da Administradora Financeira em aParcelas[1]

Default nArredondar := 0
Default aParcelas 	:= {}
Default nTipo		:= 1		// 1-Venda Assistida, 2-Front Loja

If Len(aParcelas)>0
	If nTipo = 1	// Venda Assistida
		nPosForma := aScan(aParcelas[1], {|x| AllTrim(Upper(x[1])) == "L4_FORMA" })
		If nPosForma > 0
			cForma := aParcelas[1][nPosForma][2]			//L4_FORMA
			nPosAdmFin	:= aScan(aParcelas[1], {|x| AllTrim(Upper(x[1])) == "L4_ADMINIS" })
			//If Len(aParcelas[1])>=9
			If nPosAdmFin > 0
				cAdmFin := aParcelas[1][nPosAdmFin][2]		//L4_ADMINIS
			Else
				cAdmFin := ""
			EndIf
		EndIf
	Elseif nTipo = 2	// Front Loja
		cForma := aParcelas[1][3]
		If Len(aParcelas[1])>=4
			cAdmFin := aParcelas[1][4]
		Else
			cAdmFin := ""
		EndIf
	EndIf
EndIf	

If lArredondar .AND. lAplicaTaxa .AND. nArredondar > 0

	If Alltrim(cForma) $ "CC/CD"
		DbSelectArea("SAE")
		DbSetOrder(1)
		If SAE->(MsSeek(cFilSAE+Left(cAdmFin,nTamAE_COD))) .AND. AllTrim(cForma) $ "CC/CD"
			nPctTaxAdm := SAE->AE_TAXA
			nResult := (nArredondar-(nArredondar*(nPctTaxAdm/100)))  // Aplicar desconto
		Else
			nResult := nArredondar
		EndIf  
	Else
		nResult := nArredondar
	EndIf
	
EndIf

RestArea(aArea)

Return nResult


//----------------------------------------------------------------
/*/{Protheus.doc} LjDEstVinc
Efetua o cancelamento do cupom vinculado

@param1  lCupDifere : Os numeros de cupom são diferentes ?
@param2  cCOOCCD    : Numero do cCOO do cupom atual do ECF
@author  Varejo
@version P12
@since   23/03/2016
@return  lRet - .T. ou .F. (Cancelou ou não ?)	
/*/
//----------------------------------------------------------------
Function LjDEstVinc(lCupDifere,cCOOCCD)
Local nTamCup	:= 0
Local nTamDoc	:= 0
Local lRet		:= .T.

Default lCupDifere	:= .F.
Default cCOOCCD		:= ""

If lCupDifere .AND. !Empty(AllTrim(cCOOCCD))
	nRet := IFEstornVinc(	nHdlECF,Alltrim(SL1->L1_CGCCLI),"","",;
							"Cancelamento de Comprovante de Crédito e Débito",cCOOCCD)
	If nRet <> 0
		MsgAlert(	"Não foi possível efetuar o cancelamento do cupom vinculado. Verifique se o último " +;
					"impresso foi um relatório gerencial caso seja não é permitido o cancelamento " )
		lRet	:= .F.
	Else
		nTamCup	:= Len(cCOOCCD)
		nTamDoc	:= TamSX3("L1_DOC")[1]
		cCOOCCD	:= PADR(StrZero(Val(AllTrim(cCOOCCD))-1,nTamCup),nTamDoc)	
	EndIf
Else
	lRet	:= .F.
EndIf

Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} Lj7ValTES
Esta funca valida algumas informacoes pertinentes a TES

@param1  cTes : Codigo da TES
@author  Varejo
@version P12
@since   13/01/2017
@return  lRet - .T. ou .F. 
/*/
//----------------------------------------------------------------

Function Lj7ValTES(cTes)

Local aArea	 := GetArea()
Local aAreaF4	 := SF4->(GetArea())
Local lRetorno := .T.
Local nRecSF4	 :=	0

SF4->(dbSetOrder(1))

If SF4->(MsSeek(xFilial("SF4") + cTes, .F.))
	If (SF4->F4_TIPO == "S")				
		If cPaisLoc <> "BRA" .And. lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se usa entrega futura, o TES nao deve movimentar estoques³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  SF4->F4_ESTOQUE == 'S'	.And.(Type("M->C5_DOCGER") <> "U" .And. M->C5_DOCGER == '3')
				Help(" ",1,"A410RMFUT")
				lRetorno := .F.
			EndIf			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o pedido e de consignacao, deve estar preenchido o campo que³
			//³define o TES que deve ser usado no remito, e este TES deve con-³
			//³trolar poder de terceiros.                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRetorno .And. Type("M->C5_TIPOREM") <> 'U' .And. M->C5_TIPOREM == "A"
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar se esta vazio o campo que define o TES que deve ser usado³
				//³para envio para poder de 3ros e o campo para devolucao             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If M->C5_DOCGER <> "1" .And. Empty(SF4->F4_TESENV)
					Help(" ",1,"A410TES001")
					lRetorno := .F.
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar se os TES configurados para envios existem e sao corretos³
				//³(tipo "R" para a saida e "D" para a entrada).                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nRecSF4 :=	SF4->(Recno())
				If lRetorno .And. M->C5_DOCGER <> "1" .And. (!SF4->(MsSeek(xFilial("SF4") + SF4->F4_TESENV)) .Or. SF4->F4_PODER3 <> "R" )
					Help(" ",1,"A410TES003")
					lRetorno := .F.
				EndIf
				
				SF4->(MsGoTo(nRecSF4))							
			EndIf   	
		EndIf
	Else
		Help(" ", 1, "A410NAOTES")
		lRetorno := .F.
	EndIf
Else
	Help(" ", 1, "A410TE")
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a entrada da rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaF4)
RestArea(aArea)

Return lRetorno  

//----------------------------------------------------------------
/*/{Protheus.doc} LjxDRound
Arredonda ou trunca o valor de acordo com o campo e configuração
da Impressora ECF. Por padrão irá arredondar!

@author  eduardo.sales
@version P11
@since   25/08/2017
@return  nValor - Retorna um valor arredondando ou truncado
/*/
//----------------------------------------------------------------
Function LjxDRound(nValor, nDecimal)

Local cRound		:= "R"							// Armazena configuração se Arredonda ou Trunca valores
Local lImpRnd5		:= ExistFunc("STBImpRnd5")
Local lSTBRound5	:= ExistFunc("STBRound5") .And. lImpRnd5

Default nValor		:= 0							// Valor para arredondar
Default	nDecimal	:= 0							// Quantidade de casas decimais para arredondar

// Valida se a impressora irá tratar a regra
If lSTBRound5 .And. STBImpRnd5()
	cRound := STBRound5(nValor)
EndIf

// Efetua arredondamento ou truncamento de acordo com o numero 5
If cRound == "R"
	nValor := Round(nValor, nDecimal)
ElseIf cRound == "T"
	nValor := NoRound(nValor, nDecimal)
EndIf

Return nValor

//----------------------------------------------------------------
/*/{Protheus.doc} LjGetlCanc
Função de Get para variavel lCgcCancel

@author  Lucas Novais (lnovais)
@version P12.1.17
@since   16/10/2018
@return  lCgcCancel - indica de aborta a finalização da venda na tela de CPF/CNPJ
/*/
//----------------------------------------------------------------
Function LjGetlCanc()

Return lCgcCancel

//----------------------------------------------------------------
//----------------------------------------------------------------
/*/{Protheus.doc} LjReslCanc
Função de Resete para variavel lCgcCancel

@author  Lucas Novais (lnovais)
@version P12.1.17
@since   16/10/2018
/*/
//----------------------------------------------------------------
Function LjReslCanc()
lCgcCancel := .F.
Return 

//----------------------------------------------------------------
//----------------------------------------------------------------
/*/{Protheus.doc} LjDigCPF
Chama digitação do CPF pelo PinPad

@author		JMM
@version	V12.1.25
@since		22/08/2019
/*/
//----------------------------------------------------------------
Function LjDigCPF(aCPFCli)
Local cRet	:= ""
// Chama digitação do CPF pelo PinPad
oTEF:Operacoes("DIGITA_CPF",,,,,,,,,,,,@aCPFCli)

LjGrvLog( STR(ThreadId()), " LjDigCPF - Retorno 01 da DIGITA_CPF " , aCPFCli)

If aCPFCli[1]
	cRet := aCPFCli[02]
Else
	Help( "Help", 1, "Help",, STR0418 , 1, 0 , NIL, NIL, NIL, NIL, NIL, { STR0420 + CHR(13)+CHR(10) + STR0419  }) // "Falha de comunicação com o Sitef."  "Esta ação somente é possível com o Sitef ativo." "Verifique se o serviço do Sitef esta ativo e comunicando com a estação."
Endif

Return cRet

//----------------------------------------------------------------
/*/{Protheus.doc} ljfRead
Função responsavel pela chamada da fRead

@author  Eeduardo.sales
@version P12.1.27
@since   14/10/2020
/*/
//----------------------------------------------------------------
Function ljfRead(nHandleRemoto,cBuffer,nLeituraPorVez)
	
Return {fRead(nHandleRemoto,cBuffer,nLeituraPorVez) , cBuffer}
