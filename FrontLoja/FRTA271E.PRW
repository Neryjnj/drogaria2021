#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA271E.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "ADVCTRLS.CH"
#INCLUDE "FRTDEF.CH"

#DEFINE	 FRT_SEPARATOR		"---------------------------------------"

// Indices do Array aItens
// Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
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
#DEFINE AIT_DEDICMS   			13          		// Deducao de ICMS
#DEFINE AIT_ITIMP   			14          		// Numero do item na Impressora
#DEFINE AIT_PBM		   			15          		// Define se o produto e PBM

#DEFINE _FORMATEF				"CC;CD"     // Formas de pagamento que utilizam operação TEF para validação
#DEFINE CRLF                   Chr(13)+Chr(10)  //Pula linha

Static lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .AND. RGVldTable()		//Validacao da Nova Regra de Desconto Ativa
Static lEmitNFCe	:= LjEmitNFCe()	//Indica a utilizacao da NFC-e

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271EFech³ Autor ³ Cesar Eduardo Valadao ³ Data ³19/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento do Caixa (F5)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data   ³ Bops ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Erik.W.B  ³19/04/07³124560³Alterada a utilização da chamada            ³±±
±±³          ³        ³      ³SubStr(cUsuario,7,15) por cUserName         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271EFechaCX(oCupom,cCupom,CPDV,lOcioso,	lRecebe,lCXAberto,nHdlOPE,oHora,cHora,oDoc,cDoc)

Local aKey
Local cSupervisor:=Space(15)
Local lAutoriza
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
Default oHora			:= Nil
Default cHora			:= ""
Default oDoc			:= Nil
Default cDoc			:= ""

If lCXAberto .AND. (lOcioso .OR. !lRecebe)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Permissao "Supervisao Caixa" - #4 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C"+ STR0065)  //"FECHAMENTO DO CAIXA"
	End
	lAutoriza := LJProFile(4,@cSupervisor)
	If lAutoriza
		If lUsaDisplay
  			DisplayEnv(StatDisplay(), "2C"+ STR0066 )  //"Confirma Fechamento deste Caixa?"
			DisplayEnv(StatDisplay(), "3C"+ "  " )
 		End
		If MsgYesNo(STR0003, STR0001)	// "Confirma o Fechamento deste Caixa?", "Atenção"

			// Apresentar instrucoes no display sobre o fechamento de caixa
			FRT271EDpF(1)

			If !Cx_Abre_Fecha(SA6->A6_COD,"F",oHora,cHora,oDoc,cDoc)

				// Apresentar no display que o fechamento de caixa nao ocorreu com sucesso
				FRT271EDpF(3, aKey)

				DisplayEnv(StatDisplay(), "1E"+ STR0017)	// "Codigo do Produto: "

				If !lUsaDisplay
					MsgAlert(STR0042)	//"Operação de fechamento de caixa cancelada."
					FRTSetKey(aKey)
					DisplayEnv(StatDisplay(), "1E"+ STR0017)	// "Codigo do Produto: "
				Endif

				Return Nil
			Endif

			// Apresentar no display que o fechamento de caixa nao ocorreu com sucesso
			FRT271EDpF(2)

			oCupom:SetupdatesEnable(.F.)
			oCupom:AppendText((chr(10) + chr(13)))
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			oCupom:AppendText((STR0067) + chr(10) + chr(13))	// " F E C H A M E N T O   D O   C A I X A  "
			oCupom:AppendText( chr(10) + chr(13))
			oCupom:AppendText((STR0004+cUserName+STR0005+xNumCaixa()) + chr(10) + chr(13))	// "Usuário: " " Caixa: "
			oCupom:AppendText((DToC(dDatabase)+" "+Time()+Space(13)+STR0006+PadR(cPDV,4)) + chr(10) + chr(13))
			oCupom:AppendText((FRT_SEPARATOR) + chr(10) + chr(13))
		    oCupom:SetupdatesEnable(.T.)
		    oCupom:GoEnd()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Informar que Houve Troca de Operador ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FR271BGerSLI(cEstacao, "OPE", "", "SOBREPOE")
			FClose(nHdlOPE)
			lCXAberto := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibir Mensagem de Caixa Fechado no Display ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgDisplay(4)
		Else
			If lUsaDisplay
				DisplayEnv(StatDisplay(), "1E"+ STR0017)	// "Codigo do Produto: "
	   		End
		EndIf
	Else
		If lUsaDisplay
  			DisplayEnv(StatDisplay(), "2C"+ STR0018)  //"Usuário sem permissão para fechar caixa"
 		End

		HELP(' ',1,'FRT022')	// "Usuário sem permissão para fechar o caixa.", "Atenção"

		If lUsaDisplay
			DisplayEnv(StatDisplay(), "1E"+ STR0017)	// "Codigo do Produto: "
	   	End
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271EDesc³ Autor ³ Cesar Eduardo Valadao ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Desconto no Total do Item (F6)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Valor Percentual do desconto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºHanna C.  ³12/05/06³097873³Inclusao da funcao FrtVldDes(), no valid no º±±
±±º          ³        ³      ³momento de digitar o desconto. Retirada a   º±±
±±º          ³        ³      ³validacao do supervisor antes de entrar na  º±±
±±º          ³        ³      ³de desconto                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271EDescIT( 	oCupom  	, oDesconto		, nVlrPercIT	, nVlrTotal	,;
						lRecebe 	, lDescIT		, lDescITReg	, nVlrBruto	,;
						aItens   	, nMoedaCor		, nDecimais		, lCXAberto ,;
						nVlrDescIT	, lExibeTela	, nPerRegra		, aImpsSL1	,;
						aImpsSL2	, aImpsProd)

Local nPercDesc		:= 0					// Conteudo do percentual de desconto
Local aKey			:= {}					// Array com as setkeys definidas
Local lConfDesc		:= .F.					// Valida se o desconto foi confirmado pelo botao OK
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay 	:= !Empty(LjGetStation("DISPLAY"))
Local nValorDesc	:= 0					// Variavel que contem o valor do desconto
Local lCenVenda		:= SuperGetMv("MV_LJCNVDA",,.F.)	// Indica a integracao com o cenario de vendas

//³Release 11.5 - Localizacoes³
Local lLocR5        := cPaisLoc$"CHI|COL" 				//Release - 11.5
Local aImps			:= {} 								//Array de impostos da TES
Local nI			:= 0								//Contador Auxiliar
Local nE			:= 0								//Contador Auxiliar
Local nY			:= 0								//Contador Auxiliar
Local cCampoVal		:= ""                               //Nome do campo com valor do imposto
Local cCampoAlq		:= "" 								//Nome do campo com aliquota do imposto
Local nValImp		:= 0								//Valor do imposto
Local nTotImp		:= 0								//Soma de todos os impostos
Local aImposto		:={}								//Array auxiliar de impostos
Local cBI_TS		:= ""								//Numero da TES no cadastro de produtos
Local cTesInt		:= ""								//Numero da TES
Local nValMercAx	:= 0								//Valor auxiliar da mercadoria
Local cMvDescSai	:= SuperGetMV("MV_DESCSAI",,"1")	//Tratamento de desconto para localizacoes (1=UTIILIZA VALOR DO ITEM SEM DESCONTO, 2=UTILIZA VALOR DO ITEM COM DESCONTO)
Local cSupervisor	:= Space(25)

DEFAULT nVlrDescIT  := 0
DEFAULT	lExibeTela	:= .T.
DEFAULT	nPerRegra	:= 0
DEFAULT aImpsSL1	:= {}
DEFAULT aImpsSL2	:= {}
DEFAULT aImpsProd	:= {}

If lRecebe
	Return NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o caixa pode executar descontos quando a integracao³
//³com o cenario de vendas esta ativa                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExibeTela .AND. lCenVenda .AND. !LjOpcDesc()
	MsgStop(STR0037) //"A configuração do caixa atual não permite fornecer descontos, pois prioriza o desconto proveniente das regras de desconto do cenário de vendas"
	Return NIL
EndIf

If CheckCaixa(@lCXAberto, @lUsaDisplay)

	If !LJProfile(11,@cSupervisor)
		MsgStop("Usuário não tem permissão para descontos")
		Return NIL
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica se o item atual JA TEVE DESCONTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDescIT .OR. ( lDescIT .AND. !lDescITReg )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Permissao "Efetuar Descontos" - #11 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExibeTela
			FRTX272Desc(@nPercDesc	,@lConfDesc,@nValorDesc,lDescITReg,SL2->L2_VLRITEM)
		Else
			nPercDesc	:= nPerRegra
			lConfDesc	:= .T.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Confirmou desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lConfDesc .AND. (nPercDesc > 0 .OR. nValorDesc > 0) .AND. lDescITReg
			If nPercDesc == 0
				nPercDesc := (nValorDesc/SL2->L2_VLRITEM) * 100
			EndIf
			nVlrPercIT	:= nPercDesc
			nVlrDescIT	:= Round( SL2->L2_VLRITEM * ( nVlrPercIT / 100 ), nDecimais )
			nRet		:= IFRegItem( nHdlECF, "", "", "", "", AllTrim( Str( nVlrDescIT,14,TamSX3("BI_PRV")[2] ) ), "", "" )

			If nRet <> 0
				HELP(' ',1,'FRT024')	//"Não foi possível registrar o desconto no item. Operação não efetuada.", "Atenção"
				nVlrPercIT	:= 0
				nVlrDescIT	:= 0
			Else
				oCupom :AppendText(( STR0007 + Trans( nVlrPercIT,"@R 99.99%" ) ) + chr(10) + chr(13)) // "Desconto de :  "


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Release 11.5 - Localizacoes                                  ³
				//³Apos confirmar o desconto do item,o valor base do calculo de ³
				//³imposto deve ser alterado considerando o desconto.Em seguida ³
				//³o imposto recalculado e os valores BRUTO e TOTAL corrigidos. ³
				//³                                                             ³
				//³Paises:Chile/Colombia  - F1CHI                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLocR5
					nVlrTotal -= aItens[Len(aItens)][7]
					nVlrBruto -= aItens[Len(aItens)][7]

					aItens[Len(aItens)][6]	:= ( SL2->L2_VLRITEM-nVlrDescIT ) / SL2->L2_QUANT
					aItens[Len(aItens)][7]	:= ( SL2->L2_VLRITEM-nVlrDescIT )
					aItens[Len(aItens)][8]	:= nVlrDescIT

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inicializar dados fiscais³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaFisIni(	SL1->L1_CLIENTE,	SL1->L1_LOJA, "C"	,	"S",;
								SL1->L1_TIPOCLI	,	NIL		, NIL	,	.F.,;
								"SBI"			,	NIL		, "01"	,	NIL,;
								NIL				,	NIL		, NIL	,	NIL,;
								NIL				,	NIL		, .F.	)

					cTesInt := MaTesInt( 2	,"01"		,SL1->L1_CLIENTE, SL1->L1_LOJA,;
								 "C",SBI->BI_COD,NIL)


					If !Empty(cTesInt)
						cBI_TS := cTesInt
					Else
						cBI_TS := If(Empty(SBI->BI_TS), SuperGetMV("MV_TESSAI"), SBI->BI_TS)
					Endif

					If cMvDescSai == "1"
						nValMercAx := SL2->L2_VLRITEM - nVlrDescIT
					Else
						nValMercAx := SL2->L2_VLRITEM
					EndIf

					MaFisAdd(SBI->BI_COD	,cBI_TS	, SL2->L2_QUANT	, SL2->L2_VRUNIT,;
							 nVlrDescIT		,""		, ""			,				,;
							 0				, 0		, 0				, 0				,;
							 nValMercAx		, 0)

					aImps    := TesImpInf(MaFisRet(1,"IT_TES"))
				    For nI := 1 to Len(aImps)
				    	If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
				          	nE := Len(aImpsSL1)
				       	EndIf

				       	cIndImp  := Substr(aImps[nI][2],10,1)
				       	cCampoVal   := "IT_VALIV"+Substr(aImps[nI][2],10,1)
				       	cCampoAlq   := "IT_ALIQIV"+Substr(aImps[nI][2],10,1)

			    		nValImp := Round(MaFisRet(1,cCampoVal),nDecimais)

				   		FR271HGeraImp(@aImposto					,aImps[nI]	,nValImp,aItens[Len(aItens)][5],;
				   						aItens[Len(aItens)][6]	,1			,cIndImp,nDecimais)

				   		nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])

				   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Ajustar valor e base do imposto no item (aImpSL2)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				   		aImpsSL2[len(aImpsSL2)][3][nI][3]:= aItens[Len(aItens)][6]		//Base
				   		aImpsSL2[len(aImpsSL2)][3][nI][4]:= nValImp 				   		//Valor

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Zerar valor e base do imposto no cabecalho (aImpSL1)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				   		aImpsSL1[ nE,3 ] := 0 //Valor
				   		aImpsSL1[ nE,5 ] := 0 //Base

				   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Ajustar valor e base do imposto no cabecalho (aImpSL1)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				   		For nY:= 1 To Len (aImpsSL2)
							If !aImpsSL2[nY][5]
								aImpsSL1[ nE,3 ] += aImpsSL2[nY][3][nI][4]	//Valor do imposto no cabecalho
				   				aImpsSL1[ nE,5 ] += aImpsSL2[nY][3][nI][3]	//Base do imposto no cabecalho
				   			EndIf
				   		Next nY

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualizar dados do imposto na SL2³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		  			FR271BGeraSL("SL2", {{"L2_VALIMP"+Substr(aImps[nI][2],10,1) ,	nValImp },;
				  							{"L2_BASIMP"+Substr(aImps[nI][2],10,1),aItens[Len(aItens)][6] }})

				    Next nI

				    nVlrTotal += (aItens[Len(aItens)][7]+nTotImp)
					nVlrBruto += (aItens[Len(aItens)][7]+nTotImp)

					FR271BGeraSL("SL2", {{"L2_DESC",		nVlrPercIT },;
								  {"L2_VALDESC",	nVlrDescIT },;
								  {"L2_VLRITEM",	( SL2->L2_VLRITEM - nVlrDescIT ) },;
								  {"L2_VRUNIT",		( SL2->L2_VLRITEM - nVlrDescIT ) / SL2->L2_QUANT } })

					MaFisEnd()
				Else
					aItens[Len(aItens)][6]	:= ( SL2->L2_VLRITEM-nVlrDescIT ) / SL2->L2_QUANT
					aItens[Len(aItens)][7]	:= ( SL2->L2_VLRITEM-nVlrDescIT )
					aItens[Len(aItens)][8]	:= nVlrDescIT

					FR271BGeraSL("SL2", {{"L2_DESC",		nVlrPercIT },;
								  {"L2_VALDESC",	nVlrDescIT },;
								  {"L2_VLRITEM",	( SL2->L2_VLRITEM - nVlrDescIT ) },;
								  {"L2_VRUNIT",		( SL2->L2_VLRITEM - nVlrDescIT ) / SL2->L2_QUANT } } )

					nVlrTotal -= nVlrDescIT
					nVlrBruto -= nVlrDescIT
				EndIf

				lDescIT := .T.

				nVlrDescIT := 0
				nVlrPercIT := 0

			EndIf

		ElseIf lConfDesc .AND. !lDescITReg
			nVlrPercIT 	:= nPercDesc
	   		nVlrDescIT	:= nValorDesc
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)

	If !lTouch
		oDesconto:Refresh()
	Endif
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271EEdit³ Autor ³ Cesar Eduardo Valadao ³ Data ³15/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera a Quantidade do Item (F7)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271EEditQtd( oTmpQuant, lRecebe	, lCXAberto )

Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

If lRecebe
	Return(NIL)
EndIf

If ! CheckCaixa(@lCXAberto, @lUsaDisplay)								// Verifica se o Caixa Esta Aberto
	Return(NIL)									// E exibe Mensagem Caso Esteja Fechado
Else
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1E" + STR0063 )         //"Quantidade do produto: "
	EndIf
	If !lTouch
		oTmpQuant:Enable()
		oTmpQuant:nTop  := 230
		oTmpQuant:nLeft := 10
		oTmpQuant:Refresh()
		oTmpQuant:SetFocus()
	Endif
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271ECanc³ Autor ³ Cesar Eduardo Valadao ³ Data ³05/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o Cancelamento de um Item (F8)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Alteracao ³ Adequacao Para Touch Screen                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³20/10/2006³ Marcio Silva												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			 ³ A Rotina de Montagem da Tela Para Selecao do Item a Ser    ³±±
±±³			 ³ Cancelado Foi Separado (Funcao FrtSelItem), assim como o   ³±±
±±³			 ³ Efetivo Cancelamento do Item (Funcao FrtEfCanc)            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271ECancIT(	oCupom		, oVlrTotal	, nVlrTotal		, nVlrBruto		,;
						nMoedaCor	, nTotItens	, oTotItens		, oTmpQuant		,;
						nTmpQuant	, oCodProd	, cCodProd		, nTaxaMoeda	,;
						cOrcam		, lRecebe	, aItens		, _aMultCanc	,;
						uCliTPL		, uProdTPL	, nTotDedIcms	, aMoeda		,;
						aImpsSL1	, aImpsSL2	, aImpsProd		, aImpVarDup	,;
						aTotVen		, aCols		, aHeader		, lCXAberto		,;
						nValor		, aRegTEF	, lRecarEfet	, lCancItRec	,;
						nVlrMerc	, nRecItem 	, lCanOrcPaf	,nValIPI)


Local aKey
Local cCancProd    := Space(TamSX3("BI_DESC")[1])
Local aCancItens   := {}
Local nCancQtde    := 0
Local nQtdeNova    := 0
Local cSupervisor  := Space(15)
Local cQualItem    := Space(10)
Local nCancItem    := 0
Local lContinua    := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
Local cMVLJPREC	  := SuperGetMv("MV_LJPREC", ,"" )  	// Parametro com o codigo do produto tipo recarga.
Local nI		  := 0									// Contador

Default nValor		:= 0
Default aRegTEF		:= {}
Default lRecarEfet	:= .F.
Default lCancItRec	:= .F.
Default nVlrMerc	:= 0
Default nRecItem	:= 0
Default lCanOrcPaf	:= .F.	// Indica que veio de uma importacao de orcamento no PAF e nao deve pedi superior
Default nValIPI	:= 0

If lRecebe
	Return(NIL)
EndIf

If ! CheckCaixa(@lCXAberto, @lUsaDisplay) .OR. Len(aItens)=0			// Verifica se o Caixa Esta Aberto
	Return(NIL)									// E exibe Mensagem Caso Esteja Fechado
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aKey := FRTSetKey()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Permissao "Cancelamento Item" - #7 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCanOrcPaf .OR. LJProfile(7, @cSupervisor)						// Verifica Permissao

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se é possivel cancelar todos ou o ultimo item            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := IfStatus(nHdlECF, "4", @cQualItem)

		If nRecItem == 0

			nCancItem := FR271HLastIT(@aItens)
			If Upper(AllTrim(cQualItem))=="TODOS" .Or. lEmitNfce
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Selecao do Item Para Cancelamento                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lUsaDisplay
					DisplayEnv(StatDisplay(), "1E" + STR0027 )//cancelamento de item
					DisplayEnv(StatDisplay(), "2E" + STR0051 )//informe o numero do item
					DisplayEnv(StatDisplay(), "3E" + "|")
				EndIf
				Fr271ISelItem(	@aItens		, @lContinua	, @nCancItem	, @cCancProd,;
							@nCancQtde	, @aCancItens	, @nQtdeNova	  )
				nI := nCancItem
			Else
				If nCancItem>0 .AND. !aItens[nCancItem][AIT_CANCELADO]
					If lUsaDisplay
						DisplayEnv(StatDisplay(), "1C" + STR0027 )//cancelamento de item
						DisplayEnv(StatDisplay(), "2C" + Substr(STR0026, 9, 34 ))//poderá ser cancelado o último item
					EndIf
					lContinua := MsgYesNo(STR0026,STR0027) // "Somente poderá ser cancelado o último item. Confirma o cancelamento ?"|"Cancelamento de Item"
					nI := nCancItem
				EndIf
			Endif
		Else
			nCancItem	:= nRecItem
			nI			:= nRecItem
			lContinua	:= .T.
		EndIf

		//Se algum item foi cancelado em venda recuperada, o item cancelado nao esta contido no array aItens
		//Assim, o item a ser cancelado (nCancItem) fica com valor maior que a quantidade de itens em tela
		If lContinua
			If nCancItem > Len(aItens)
				nCancItem 	:= Ascan(aItens, {|x| x[AIT_ITEM] == nCancItem})
				nI			:= nCancItem
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o item é de orcamento importado do Venda Assistida   ³
		//³não permitindo o seu cancelamento, exceto quando cancelado     ³
		//³no orcamento, regra PAF-ECF								      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRecItem == 0
			If nCancItem >= 0 .AND. nCancItem <= Len(aItens)
				If Fr271ICancIT(  lContinua , nCancItem  )
					lContinua := .F.
				EndIf
			Else
				lContinua := .F.
		    EndIf
		EndIf

		Fr271IEfCanc(	@oCupom   		, @oVlrTotal	, @nVlrTotal	, @nVlrBruto	,;
						@nMoedaCor		, @nTotItens	, @oTotItens	, @oTmpQuant	,;
						@nTmpQuant		, @oCodProd		, @cCodProd		, @nTaxaMoeda	,;
						@cOrcam			, @lContinua	, @nI			, @cSupervisor	,;
						@aItens			, @_aMultCanc	, @uCliTPL		, @uProdTPL		,;
						@nTotDedIcms	, @aMoeda		, @aImpsSL1		, @aImpsSL2		,;
						@aImpsProd		, @aImpVarDup	, @aTotVen		, @aCols		,;
						@aHeader		, @nValor 		, @cMVLJPREC	, @aRegTEF		,;
						@lRecarEfet		, @lCancItRec	, @nVlrMerc, @nValIPI		)

	Else
		If lUsaDisplay
			DisplayEnv(StatDisplay(), "1C" + STR0052 )	// "Usuário sem permissão para cancelar itens."
		EndIf
		HELP(' ',1,'FRT026')	// "Usuário sem permissão para cancelar itens.", "Atenção"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura os SetKey's do Fechamento da Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTSetKey(aKey)
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271EFimV³ Autor ³ Cesar Eduardo Valadao ³ Data ³10/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finalizacao da Venda (F9) (Sub-Total)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controla se tem transacao TEF realizada mas penden-³±±
±±³			 ³ te no servidor SiTEF que precisa ser confirmada, utilizado ³±±
±±³			 ³ no recebimento de titulos								  ³±±
±±³			 ³ ExpA2 - Array que recupera os dados de TEF multiplas tran- ³±±
±±³			 ³ sacoes no recebimento de titulos							  ³±±
±±³			 ³ ExpC3 - Numeracao do cartao fidelidade 					  ³±±
±±³          ³ ExpL2 - Controle de multiplas transacoes TEF       	      ³±±
±±³          ³ ExpA3 - Guarda a ultima transacao TEF					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Progr.   ³ Data     BOPS   Descricao								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos R. ³25/08/05³002694³- Correcao no calculo do desconto financeiro³±±
±±³Andrea F. ³20/02/06³094117³- Nao permitir que seja teclado F9 (Finaliza³±±
±±³          ³        ³      ³Venda) sem ter aberto o caixa, ou ter lan-  ³±±
±±³          ³        ³      ³cado itens (produtos).                      ³±±
±±³Andrea F. ³22/03/06³093006³Permitir via parametrizacao, que o acrescimo³±±
±±³          ³        ³      ³seja exibido separado da parcela. Criado    ³±±
±±³          ³        ³      ³nova coluna para exibi-lo.                  ³±±
±±³Mauro S.  ³04/05/07³123238³Feita insercao de um botao para contornar   ³±±
±±³          ³        ³      ³temporariamente a perda do foco no final da ³±±
±±³          ³        ³      ³venda.                                      ³±±
±±³Conrado Q.³01/10/07³133788³Retirado o uso da variável ltTefAberto      ³±±
±±³          ³        ³      ³como local.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271EFimVend( 	lTEFPendRec	, aRecTEFMult	, cNCartao		, oHora			,;
							cHora		, oDoc			, cDoc			, oCupom		,;
							cCupom		, nVlrPercIT	, nLastTotal	, nVlrTotal		,;
							nLastItem	, nTotItens		, nVlrBruto		, oDesconto		,;
							oTotItens	, oVlrTotal		, oFotoProd		, nMoedaCor		,;
							cSimbCor	, oTemp3		, oTemp4		, oTemp5		,;
							nTaxaMoeda	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;
							oMoedaCor	, cCodProd		, cProduto		, nTmpQuant		,;
							nQuant		, cUnidade		, nVlrUnit		, nVlrItem		,;
							oProduto	, oQuant		, oUnidade		, oVlrUnit		,;
							oVlrItem	, lF7			, oPgtos		, oPgtosSint	,;
							aPgtos		, aPgtosSint	, cOrcam		, cPDV			,;
							lTefPendCS	, aTefBkpCS		, oDlgFrt		, cCliente		,;
							cLojaCli	, cVendLoja		, lOcioso		, lRecebe		,;
							lLocked		, lCXAberto		, aTefDados		, dDataCN		,;
							nVlrFSD		, lDescIT		, nVlrDescTot	, nValIPI		,;
							aItens		, nVlrMerc		, lEsc			, aParcOrc		,;
							cItemCOrc	, aParcOrcOld	, aKeyFimVenda	, lAltVend		,;
							lImpNewIT	, lFechaCup		, aTpAdmsTmp	, cUsrSessionID	,;
							cContrato	, aCrdCliente	, aContratos	, aRecCrd		,;
							aTEFPend	, aBckTEFMult	, cCodConv		, cLojConv		,;
							cNumCartConv, uCliTPL		, uProdTPL		, lDescTotal	,;
							lDescSE4	, aVidaLinkD	, aVidaLinkc 	, nVidaLink		,;
							cCdPgtoOrc	, cCdDescOrc	, nValTPis		, nValTCof		,;
							nValTCsl	, lOrigOrcam	, lVerTEFPend	, nTotDedIcms	,;
							lImpOrc		, nVlrPercTot	, nVlrPercAcr	, nVlrAcreTot	,;
							nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	, nNumParcs		,;
							aMoeda		, aSimbs		, cRecCart		, cRecCPF		,;
							cRecCont	, aImpsSL1		, aImpsSL2		, aImpsProd		,;
							aImpVarDup	, aTotVen		, nTotalAcrs	, lRecalImp 	,;
							aCols		, aHeader 		, aDadosJur		, aCProva		,;
							aFormCtrl	, nTroco		, nTroco2 		, lDescCond		,;
							nDesconto	, aDadosCH		, cItemCond		, lCondNegF5	,;
							nTxJuros	, nValorBase	, lDiaFixo		, aTefMult 		,;
							aTitulo		, lConfLJRec	, aTitImp		, aParcelas		,;
							oCodProd	, oMensagem		, oFntGet		, cCodDep		,;
							cNomeDEP	, cTipoCli		, cEntrega		, aReserva		,;
							lReserva	, lAbreCup 		, nValor		, oTimer		,;
							lResume		, aValePre		, aRegTEF		, lRecarEfet	,;
							lCancItRec	, oOnOffLine	, nValIPIIT		, _aMult		,;
							_aMultCanc	, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
							oPDV		, aICMS			, lDescITReg	, cNumDAV		,;
							cCliCGC		, cMensagem		, cDocFo		, aNccRecSel	,;
							lSelTefManu)

Local nX
Local nK
Local nI
Local nZ
Local oFimVenda
Local aKey
Local aSetKey
Local bKey
Local aSL1Datas 	 := {}
Local cRet			 := ""
Local nPosSimb       :=0
Local nTotImp        := 0
Local aSL2           := {}
Local aCondicoes	 := ljxDCondP(AllTrim(cCliente)+AllTrim(cLojaCli))
Local cItemForma
Local aFormPag
Local aFormPagF5
Local nTmpJuros		 := 0							     //Juros
Local nAux           := 0                        	     //Var Auxiliar do sistema
Local lAltParc		 := .T.
Local lEncerra       := .F.
Local nVlrTotBkp     := nVlrTotal
Local nVlrBrutoBkp   := nVlrBruto
Local nVlrMercBkp    := nVlrMerc
Local nTmpDesc       := 0                        	     //Desconto Financeiro - Localizacoes
Local aCondRecalc    := {} 							     //Var utilizada para recalculo das condicoes de pagamento
Local aAreaSFB       := {}
Local lFrtAltPg 	 :=	ExistBlock("FRTALTPG")
Local lTFrtAltPg 	 := ExistTemplate("FRTALTPG")
Local cMVLJTPPAG	 := SuperGetMV("MV_LJTPPAG", ,"") 	//Controle dos tipos de formas de pagto possiveis para recebimento dos titulos
Local lTefMult		 := SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza múltiplas transações TEF
Local lVisuSint  	 := If(SL4->(ColumnPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local cFormaId		 := If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))
Local lHomol		 := .F.                              //Uso interno da Microsiga
Local aBotoes		 := {}
Local aBonus		 := {}
Local nCtrlO		 := 13							//posicao do array aFormPag que representa o setkey O
Local nCtrlX		 := 21							//posicao do array aFormPag que representa o setkey X
Local nSum			 := 0							//valor que sera somado a nCtrlO e nCtrlX para definir os SetKeys O e X
												    //Ponto de entrada exclusivo para o processo de homologação
Local bPgtosDblClick
Local lKey			:= .F.							//define se chma a funcao FR271FFormPag ou nao
Local oPgtosAna
Local nEntrada		:= 0
Local lVerEmpres     := Lj950Acres(SM0->M0_CGC)		// Verifica as filiais da trabalharam com acrescimento separado
Local lTouch		 := If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local oFonte
Local oSay
Local oOrigBtns     := Nil
Local cUsaTe		:= SuperGetMV( "MV_LJUSATL", .T., "D" ) // Define o LayOut da Tela - [C]anhoto ou [D]estro
Local cSimbCheq   	:= AllTrim(MVCHEQUE)
Local nDecimais  	:= MsDecimais(nMoedaCor)
Local lVendaRapida 	:= .T.
Local bPesqSimb    	:= {|| }
Local bSmbMoeda    	:= {|| }
Local bDscMoeda		:= {|| }
Local lCenVenda		:= SuperGetMv("MV_LJCNVDA",,.F.)	//Indica se usa integracao com cenario de vendas
Local lDescEspec	:= .F.						//Desconto Especial e o "Chorinho" No final da compra.
												//Indica que o desconto deve ser rateado nas parcelas, pois o
												//valor final foi "descoberto" apos selecionar a Condicao de Pagto.
Local oButtonz
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay 		:= !Empty(LjGetStation("DISPLAY"))
Local lBscCliON			:= SuperGetMV("MV_LJCLION", ,.F.)	// Identifica se o Front ira' se conectar com a Retaguarda
Local nConTcLnk         := 0
Local lFRTACRES			:= ExistFunc("U_FRTACRES")		// Ponto de entrada adicionar valores para acrescimo financeiro
Local xRet				    								// Retorno do ponto de entrada FRTACRES
Local aPremio			:= {}
Local aLibera			:= {}
Local nTotPontos		:= 0
Local nTotPremio		:= 0
Local cQtd				:= 1
Local lOrc 				:= .F.
Local cMsgCupom			:= ""
Local nDescItem			:= 0
Local oSWB
Local nPontos			:= 0
Local cMotivo			:= ""
Local aColsMAV			:= {}
Local lUsafd      	    := SuperGetMV("MV_FRTCRD",,.F.)
Local nImpSegVia	    := SuperGetMV("MV_FRTQTTK", ,0)	    // Identifica a quantidade de Copias do Ticket (Mexico)
Local nPosicao          := 0                                // Numero da posicao
Local lCtrlOX           := .F.                              // Verifica se utilizou tecla (CTRL + O) ou (CTRL + X)
Local lAnalLeg14		:= LJAnalisaLeg(14)[1]              // Verifica se a impressao concomitante de desconto no cupom
Local lAtivaMn			:= SuperGetMV("MV_LJMULTN", , .F.) // Ativa cenario de Vendas
Local nValDescPa		:= 0								// Valor de Desconto
Local aTxJurAdm			:= {0,0,0}							// Recebe o valor da taxa de juros e o valor do juros sobre o total da venda
Local nFrete			:=(SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA)

//³Release 11.5 - Cartao Fidelidade³
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()			  	//Indica se a recarga de cartao fidelidade esta ativa

//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI		  ³
Local lCFolLocR5	:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL" .AND. !lFiscal

Local aArea       	:= {} 									// Utilizado para GetArea
Local bFuncDesc		:= {|| }								// Funcao de armazenamento da chamada de desconto
Local lRemontaPgtos	:= .F.									// Controla se o array aPagtos foi forcado a manter as formas de pagamento TEF pendentes

Local lMV_LJSLFin  	:= SuperGetMV("MV_LJSLFIN", ,.T.)       // Mostra a tela de selecao da Administradora quando utiliza TEF com IPdv
Local lUsaAdm		:= .F.
Local nMvFrtDesc 	:= SuperGetMV("MV_FRTDESC")	   						// 1=Considera desconto; 2=Desconsidera o desconto; 3=Pergunta
Local lLjNCCOr		:= SuperGetMv("MV_LJNCCOR", Nil, .F.)	//verifica se a NCC sera mantida no orcamento (F4)
Local nArredondar	:= 0								//doação para o Instituto Arredondar
Local cTickForm		:= ""								//Texto para cupom não-fiscal para Instituto Arredondar
Local cFormaPgto 	:= GetPvProfString("Instituto Arredondar", "FormaPgto", " ", GetClientDir() + "SIGALOJA.INI" )	// Ler qual cond. pagto. no Sigaloja.ini
Local cTotalizNFis	:= GetPvProfString("Instituto Arredondar", "Totalizador", "01", GetClientDir() + "SIGALOJA.INI" )  // Ler qual totalizador no Sigaloja.ini
Local lIcmjr		:= cPaisLoc == "BRA" .And. SuperGetMV("MV_LJMULTN",,.F.) .And. !SuperGetMV("MV_LJICMJR",,.F.) //Juros de acrescimo fin. separado da parcela
Local nVlAcrMultNeg	:= 0
Local nVlrAcresBak  := 0
Local lLimpaDesImp	:= .F.									// Utilizada para limpar o valor de desconto informado no front para orçamentos importados.
Local nDescItens	:= 0
Local lFrtDescTot	:= ExistBlock("FRTDESCVEN")		// Verifica se o PE FRTDESCTOT existe (PE para desconto no total)

/*Posições array aDescTot:
  [1] - Exibe Tela de Desconto
  [2] - Valor de Desconto	*/
Local aDescTot := {}								// Array retorno com o desconto no total do PE 
Local lTela    := .T.							// Variavel para validar se mostra a tela de desconto
Local nDescToP	:= 0
Local nPosCondPg:= 0

DEFAULT lTEFPendRec  	:= .F.
DEFAULT aRecTEFMult 	:= {}
DEFAULT cNCartao		:= "" 							//Numeracao do cartao fidelidade
DEFAULT lF7				:= .F.
DEFAULT	cCodDep			:= ""
DEFAULT	cNomeDEP		:= ""
DEFAULT	cTipoCli		:= ""
DEFAULT	cEntrega    	:= ""
DEFAULT	aReserva    	:= {}
DEFAULT	lReserva    	:= .F.
DEFAULT	lAbreCup		:= .F.
DEFAULT	nValor			:= 0
DEFAULT	aValePre		:= {}
DEFAULT	aRegTEF			:= {}
DEFAULT	lRecarEfet		:= .F.
DEFAULT lCancItRec		:= .F.
DEFAULT oOnOffLine      := Nil
DEFAULT nValIPIIT		:= 0
DEFAULT _aMult		    := {}
DEFAULT _aMultCanc		:= {}
DEFAULT nVlrDescIT		:= 0
DEFAULT oFntMoeda       := Nil
DEFAULT lBscPrdON       := .F.
DEFAULT oPDV            := Nil
DEFAULT aICMS           := {}
DEFAULT lDescITReg   	:= .F.
DEFAULT cNumDAV			:= ""
DEFAULT cCliCGC			:= ""
DEFAULT cMensagem		:= ""
DEFAULT cDocFo			:= ""
DEFAULT aParcOrcOld		:= {}
Default lSelTefManu		:= .F.
DEFAULT aItens		:= {}

aParcOrcOld	:=	aParcOrc					//Realiza backup das formas de pagto para restaurar caso nao conclua o processo de alteracao(pressione ESC ou cancelar tela de alteracao de forma)

aFormCtrl	:= {}							//Controle das Formas de Pagamento Solicitadas
cItemCond	:= "CN"
lCondNegF5	:= .F.
													//Indica que o desconto deve ser rateado nas parcelas, pois o
													//valor final foi "descoberto" apos selecionar a Condicao de Pagto.
nTxJuros	:= 0
nValorBase	:= 0
nTroco		:= 0							//Valor do Troco. Caso seja colocado um valor a maior em dinheiro,													//O restante sera repassado ao nTroco, pulando a GetTroco().
nTroco2		:= 0							//Armazena o valor do troco que devera ser gravado em L1_TROCO1,													//Para geracao de movimentacao bancaria local e na retaguarda
lDescCond	:= .F.
nDesconto	:= 0
aDadosCH	:= {}
aParcelas	:= {}
aPgtos 		:= {}
aPgtosSint 	:= {}

//Atualiza valor de desconto no item
aEval(aItens, {|x| IIF(!x[AIT_CANCELADO], nDescItens += x[AIT_VALDESC], Nil)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Reinicializa as variaveis estaticas p/ rotina de recebimento de NCC	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Frt060End(oVlrTotal,nVlrTotal)

If ExistFunc("U_LJHOMTEF") .AND. LjMSSM0(SM0->M0_CGC)
   lHomol := .T.
Endif

If ltouch
	FR271BBGrp( @oOrigBtns ) // Botoes do Menu Principal
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o caixa nao estiver aberto nao permite utilizar tecla de funcao F9³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCxAberto
	HELP("",1,'FRT029')
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C" + SubStr(STR0016,1,23) )         //"O Caixa não está aberto.
		DisplayEnv(StatDisplay(), "2C" + SubStr(STR0016,26,35) )         //"Não é possível usar tecla F9"
	EndIf
	DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
	Return(aPgtos)
Endif

If Len(aItens) == 0 .AND. !lRecebe
	DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
	Return(aPgtos)
Endif

//Funcao que faz a atualizacao do database.
If !lEmitNFCe .AND. !LjECFxData()
	DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
	Return(aPgtos)
EndIf

If !lRecebe
	aSL1Datas := {{"L1_EMISSAO", dDataBase},;
			      {"L1_DTLIM",	 dDataBase},;
			      {"L1_EMISNF",	 dDataBase}}

	FR271BGeraSL("SL1", aSL1Datas, .F.)
	nTmpJuros := SL1->L1_JUROS											// Juros
Endif

If !CheckCaixa(@lCXAberto, @lUsaDisplay)								// Verifica se o Caixa Esta Aberto
	DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
	Return(aPgtos)								// E exibe Mensagem Caso Esteja Fechado
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao informou midia e for obrigatorio chama funcao para informar   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMv("MV_LJRGMID",,0) == 2 .AND. ExistFunc("LjxValMid") .AND. LjxValMid()
	While Empty(M->L1_MIDIA)
		M->L1_MIDIA:= LjxGetMid(M->L1_MIDIA)  // Midia
	End
EndIf

LjLogFront("")
LjLogFront(FRT_SEPARATOR)
LjLogFront("")
LjLogFront("FRTA271E - INICIO DA FINALIZ DA VENDA (PRIMEIRO F9)")
LjLogFront("FRTA271E - 1-DOCUMENTO",cDoc)
LjLogFront("FRTA271E - 2-CUPOM",cCupom)
LjLogFront("FRTA271E - 3-VALOR TOTAL",nVlrTotal)
LjLogFront("FRTA271E - 4-VALOR BRUTO",nVlrBruto)
LjLogFront("FRTA271E - 5-TOTAL DE MERCADORIAS",nVlrMerc)
LjLogFront("FRTA271E - 6-PERCENTUAL DO ITEM",nVlrPercIT)
LjLogFront("FRTA271E - 7-nVlrDescTot",nVlrDescTot)
LjLogFront("FRTA271E - 8-nVlrDescIT",nVlrDescIT)
LjLogFront("FRTA271E - 9-nDesconto",nDesconto)
LjLogFront("FRTA271E - 10-nVlrDescCPg",nVlrDescCPg)
LjLogFront("FRTA271E - 11-nVlrPercTot",nVlrPercTot)
LjLogFront("FRTA271E - 12-ACRESCIMO NO TOTAL",nVlrAcreTot)



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//						Soma o Frete								//
// O FRETE DEVE SER ADICIONADO A VENDA ANTES DE PAGAR A NCC//
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 // NÂO tem acrescimo mas tem valor de frete
 // Caso tenha utilizado Ncc ou desconto, o valor de frete já foi incluido.
If !lDescSE4 .AND. nVlrAcreTot > 0 .And. nVlrMerc == (nVlrTotal + nDescItens)
	nVlrTotal += nVlrAcreTot
	oVlrTotal:Refresh()
EndIf
// Tem acrescimo mas tem valor de frete
// o Sistema junta acrescimo de cond Pgto mais o Frete, mas para recalculo deve ser somado o frete ao valor total
// se lDescSE4 estiver .T. é porque houve acrescimo
If lDescSE4 .AND. (lImpOrc .AND. nfrete > 0 )
	nVlrTotal += nFrete
	oVlrTotal:Refresh()
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Realiza pesquisa de NCCs em aberto (WebService)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Frt060NCC( 	cCliente		, 	cLojaCli	, 	@nVlrTotal	, 	@oVlrTotal	,;
			@aPgtos			,	@nVlrBruto	, 	@aParcOrc	, 	@aParcOrcOld,;
			nVlrDescTot 		,	Nil			, lImpOrc		,	nVlrMerc	  ,;
			aItens				,	nFrete)

LjLogFront("APOS A ESCOLHA DA NCC",nVlrTotal)
LjLogFront("VAL BRUT",nVlrBruto)


//Atualizacao do valor total
If !lTouch
	oVlrTotal:Refresh()
Endif

If lUsafd

	aPremio := AClone(Frt271ECrd(cCliente,cLojaCli, nTotPontos, @aLibera, @nVlrTotal))


	For nX := 1 to Len(aPremio)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for Self-Liquidate soma o valor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aPremio[nX][2] == "2" .OR. aPremio[nX][2]=="3"
			If(aPremio[nX][5]<> 0)
				nTotPremio += aPremio[nX][5]
			Else
				nTotPremio += 0.01
				aPremio[nX][5] = 0.01
			EndIf
		EndIf
	Next nX


	For nX := 1 to Len(aPremio)
		If aPremio[nX][2] == "2"
			cCodProd := aPremio[1][3]
			FR271AProdOK(				,				,				, .T.			,;
			 			 @cCodProd		, @oTimer		, @oHora		, @cHora		,;
						 @oDoc			, @cDoc			, @oPDV			, @cPDV			,;
			 			 @nLastTotal	, @nVlrTotal	, @nLastItem	, @nTotItens	,;
			 			 @nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
						 @oOnOffLine	, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
						 @nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
						 @oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
						 @cOrcam		, @cProduto		, @nQuant		, @cUnidade		,;
						 @nVlrUnit		, @oUnidade		, @lF7   		, @cQtd			,;
						 @cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
						 @lRecebe		, @lLocked		, @lCXAberto	, @lDescIT 		,;
						 @nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,;
						 @_aMult		, @_aMultCanc	, @lOrc			, @aParcOrc		,;
						 @cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
						 @lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
						 @aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
						 @cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
						 @lDescTotal	, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,;
						 @nVidaLink		, @nValTPis		, @nValTCof		, @nValTCsl		,;
						 @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
						 @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
						 @aMoeda		, @aSimbs		, @nMoedaCor	, @nDecimais	,;
						 @aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
						 @aTotVen		, @aCols		, Nil	        , Nil			,;
						 Nil			, Nil			, Nil			, Nil 			,;
						 				, 				, 				,				,;
						 				, 				, 				,			.T. ,;
						 				, 				, 				,				,;
										, 				, 				, 			.T.	)
		ElseIf aPremio[nX][2] == "3"
			cCodProd 	:= aPremio[nX][3]
			nDescItem 	:= aPremio[nX][6]
			FR271AProdOK(				,				,				, .T.			,;
			 			 @cCodProd		, @oTimer		, @oHora		, @cHora		,;
						 @oDoc			, @cDoc			, @oPDV			, @cPDV			,;
			 			 @nLastTotal	, @nVlrTotal	, @nLastItem	, @nTotItens	,;
			 			 @nVlrBruto		, @oVlrTotal	, @oCupom		, @oTotItens	,;
						 @oOnOffLine	, @nTmpQuant	, @nVlrItem		, @nValIPIIT	,;
						 @nValIPI		, @oFotoProd	, @oProduto		, @oQuant		,;
						 @oVlrUnit		, @oVlrItem		, @oDesconto	, @cSimbCor		,;
						 @cOrcam		, @cProduto		, @nQuant		, @cUnidade		,;
						 @nVlrUnit		, @oUnidade		, @lF7   		, @cQtd			,;
						 @cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
						 @lRecebe		, @lLocked		, @lCXAberto	, @lDescIT 		,;
						 @nVlrDescTot	, @aItens		, @aICMS		, @nVlrMerc		,;
						 @_aMult		, @_aMultCanc	, @lOrc			, @aParcOrc		,;
						 @cItemCOrc		, @aParcOrcOld	, @lAltVend		, @lImpNewIT	,;
						 @lFechaCup		, @cContrato	, @aCrdCliente	, @aContratos	,;
						 @aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
						 @cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
						 @lDescTotal	, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,;
						 @nVidaLink		, @nValTPis		, @nValTCof		, @nValTCsl		,;
						 @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
						 @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
						 @aMoeda		, @aSimbs		, @nMoedaCor	, @nDecimais	,;
						 @aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
						 @aTotVen		, @aCols		, @nDescItem		, Nil		,;
						 Nil			, Nil			, Nil			, Nil 			,;
						 				, 				, 				,				,;
						 				, 				, 				,			.T. ,;
						 				, 				, 				,				,;
										, 				, 				, 				)
		EndIf

	Next nX
EndIf

If Frt060Ret("060_VLRDESC") > 0
	nVlrDescTot := Frt060Ret("060_VLRDESC")
	nVlrPercTot := Frt060Ret("060_PERDESC")
	lDescTotal := .T.
	LjLogFront("VALOR DESC COM NCC",nVlrDescTot)
	LjLogFront("PERCENTUAL DESC COM NCC",nVlrPercTot)
EndIf


If lRecebe
	aKey := FrtSetKey()
Else
	If Len(aItens)==0 .OR. (Len(aItens)==1 .AND. aItens[1][AIT_CANCELADO])
		DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
		Return(aPgtos)
	EndIf

	If IFStatus(nHdlECF, "10", @cRet) <> 0		// Verifica se todos os itens foram impressos.
		DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
		Return(aPgtos)
	EndIf

	aKey := FrtSetKey()
	If !lEmitNFCe
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IFStatus(nHdlECF, "12", @cRet) == 0
			IFNumItem(nHdlECF, @cRet)
			If Val(cRet) == nTotItens
				IFSubTotal(nHdlECF, @cRet)

				If Val(cRet)/100 <> nVlrTotal
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, ³
					//³cancele o Cupom Fiscal.", "Atenção"                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					HELP(' ',1,'FRT027')
					FrtSetKey(aKey)
					DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
					Return(aPgtos)
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³"Existe diferenças entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.", "Atenção"³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				HELP(' ',1,'FRT027')
				FrtSetKey(aKey)
				DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
				Return(aPgtos)
			EndIf
		EndIf
    EndIf
	If cPaisLoc == "BRA"
		If  Frt060Ret("NCC_USADA")> 0
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			oCupom:AppendText(("     C R E D I T O        "+Trans(Frt060Ret("NCC_USADA"),PesqPict("SL1", "L1_VLRTOT", 13,nMoedaCor)))+ chr(10) + chr(13))
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
		EndIf
		//oCupom:AppendText((STR0008+Trans(nVlrTotal,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor)))+ chr(10) + chr(13))  //"     S U B T O T A L      "// IMPRIMIR apenas no momento da finalização da venda

		//Tratamento para impressão de acrescimo quando não incide juros sobre ICMS na multinegociação no cupom virtual
		If lIcmjr .And. Len(aParcOrc) > 0 .And. ValType(aParcOrc[1,13]) == "N"
			nVlAcrMultNeg := 0
			aEval(aParcOrc,{|x| nVlAcrMultNeg += x[13]})
			If nVlAcrMultNeg > 0
				oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
				oCupom:AppendText(("     ACRES. MULTINEG     "+Trans(nVlAcrMultNeg,PesqPict("SL1", "L1_VLRTOT", 13,nMoedaCor)))+ chr(10) + chr(13))
				oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³So aplica o desconto ou o acrescimo caso a quantidade itens da venda³
		//³seja igual a quantidade de itens do orcamento original.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nQtdeItOri == Len(aItens)

			If (nVlrPercOri > 0) .AND. (nVlrPercOri == nVlrPercTot)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso exista desconto no total da venda e desconto financeiro eh ³
				//³necessario informar apenas o desconto do total da venda, pois o ³
				//³desconto financeiro sera calculado no calculo da condicao de    ³
				//³pagamento.                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+cItemCOrc))
				If !Empty(SE4->E4_DESCFIN)
					nVlrPercTot -= SE4->E4_DESCFIN
					nAux        := (nVlrMerc * nVlrPercTot) / 100
				Else
					nAux        :=	nVlrDescTot
				EndIf

				aDadosJur[9]  := nVlrDescTot

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama a funcao para o calculo do desconto no total da venda - Localizacoes³
				//³"Fazendo o calculo do desconto e o recalculo dos impostos..."             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LJMsgRun(STR0028,,{|| FR271ICDescLoc(	nAux		, nVlrPercTot	, nVlrPercAcr	, 0				,;
													@nVlrBruto	, @nVlrMerc		, @ nMoedaCor	, @nDecimais	,;
													@aImpsSL1	, @aImpsSL2		, @aImpsProd	, @lRecalImp 	,;
													@aCols		, @aHeader		, @aDadosJur	, @cItemCond	,;
													@lCondNegF5	, cOrcam		, @oVlrTotal	, @nVlrTotal	)})
				nAux := 0

				oCupom:SetupdatesEnable(.F.)
				oCupom:AppendText(PadL((FRT_SEPARATOR),39))
				oCupom:AppendText(PadR(STR0009,39))	// "Desconto no total do cupom"
				oCupom:AppendText(PadR(STR0010,39))	// "Valor / Percentual"
				oCupom:AppendText((PadR(Trans(nVlrDescTot,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nVlrPercTot,"@E 99.99")+"%",39)) + chr(10) + chr(13))
				oCupom:AppendText(PadL((FRT_SEPARATOR),39))
			EndIf
		EndIf
		AEval(aImpsSL1,{|x,y| nTotImp += aImpsSL1[y][3]})
		oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
		oCupom:AppendText((STR0008+Trans(nVlrTotal-nTotImp,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))) + chr(10) + chr(13))  //"     S U B T O T A L      "
		aAreaSFB := SFB->(GetArea())
		SFB->(DbSetOrder(1))
		For nI := 1 To Len(aImpsSL1)  //Impressao dos impostos no cupom
			SFB->(DbSeek(xFilial("SFB")+aImpsSL1[nI][1]))
			oCupom:AppendText((Space(05)+SubStr(SFB->FB_DESCR,1,10)+Space(11)+Trans(aImpsSL1[nI][3],PesqPict("SL1",aImpsSL1[nI][2],13,nMoedaCor))) + chr(10) + chr(13))
		Next nI
		RestArea(aAreaSFB)
		nTotImp := 0
	EndIf
	oCupom:SetupdatesEnable(.T.)
	oCupom:GoEnd()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibir Mensagem de Sub-Total no Display ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgDisplay(6, {nVlrTotal})
	If lUsaDisplay
		FR271HVlPar(	@nVlrTotal	, @aPgtos	, @nMoedaCor	,;
					   	@nDecimais	, nTaxaMoeda )

		DisplayEnv(StatDisplay(), "2C" + Upper(Substr(STR0020, 1, 21 )) )         //"Escolha a(s) forma(s) de pagamento"
		DisplayEnv(StatDisplay(), "3C" + Upper(Substr(STR0020, 23)) )         //"Escolha a(s) forma(s) de pagamento"
		DisplayEnv(StatDisplay(), "***")	// Inibir a apresentacao das digitacoes no display
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar se o usuario possuir permissao de "Acesso Condicao Negociada". ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Substr(cAcesso,35,1) == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando for Localizacao, nao adicionamos a opcao 999 - Condicao Negociada,|
		//|pois a funcao LjxDRecVB(LOJXFUND.PRW) nao esta preparada para o FrontLoja³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Permitir Condicao Negociada Igual a Venda Balcao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd(aCondicoes, "999 - " + STR0029) //"Condição Negoc."
		EndIf

		If lAtivaMn
			AAdd(aCondicoes, STR0043) //"Multi Negociação"
		EndIf
	EndIf
EndIf

/*remoção da condição FINANCIADO para o Cliente Padrão*/
nPosCondPg := Ascan(aCondicoes , {|x| AllTrim(SubStr(Upper(x),TamSX3("E4_CODIGO")[1]+3,Len(x))) == "FINANCIADO" } )

While nPosCondPg > 0 .And. (AllTrim(cCliente)+AllTrim(cLojaCli) == AllTrim(SuperGetMV("MV_CLIPAD"))+AllTrim(SuperGetMV("MV_LOJAPAD")))

	aDel(aCondicoes,nPosCondPg)
	aSize(aCondicoes,Len(aCondicoes)-1) 	
	Conout("Cliente padrão não pode efetuar venda financiada, não será permitido inclusão da forma ")
	LjGrvLog( NIL, "Cliente padrão não pode efetuar venda financiada, não será permitido inclusão da forma ")
	
	nPosCondPg := Ascan(aCondicoes , {|x| AllTrim(SubStr(Upper(x),TamSX3("E4_CODIGO")[1]+3,Len(x))) == "FINANCIADO" } )
End

//Formas de Pagamento Disponiveis (R$, CH , SAE's cadastrados e Cartao Fidelidade)
MonFormPag( @aFormPag )

/*remoção da condição FINANCIADO para o Cliente Padrão*/
nPosCondPg := Ascan(aFormPag , {|x| AllTrim(Upper(x[2])) == "FI" } )
While nPosCondPg > 0 .And. (AllTrim(cCliente)+AllTrim(cLojaCli) == AllTrim(SuperGetMV("MV_CLIPAD"))+AllTrim(SuperGetMV("MV_LOJAPAD")))
	aDel(aFormPag,nPosCondPg)
	aSize(aFormPag,Len(aFormPag)-1) 	
	Conout("Cliente padrão não pode efetuar venda financiada, não será permitido inclusão da forma ")
	LjGrvLog( NIL, "Cliente padrão não pode efetuar venda financiada, não será permitido inclusão da forma ")
	
	nPosCondPg := Ascan(aFormPag , {|x| AllTrim(Upper(x[2])) == "FI" } )
End

// Formas de Pagamento Para o F5 (Selecionando Condicao de Pagamento)
aFormPagF5 := {}
DbSelectArea( "SX5" )
SX5->(DbSeek( cFilial+"24" ))
While !SX5->(Eof()) .AND. cFilial==SX5->X5_FILIAL .AND. SX5->X5_TABELA = "24"
	DbSelectArea("SAE")
	SAE->(DbSetOrder(1))
	SAE->(DbSeek(xFilial("SAE")))

	If Alltrim(SX5->X5_CHAVE) == SuperGetMV("MV_SIMB1") .OR. Alltrim(SX5->X5_CHAVE) == cSimbCheq
		Aadd(aFormPagF5,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
	Else
		While xFilial("SAE") == SAE->AE_FILIAL .AND. !SAE->(Eof())
			If Alltrim(SX5->X5_CHAVE) == AllTrim(SAE->AE_TIPO)
				If AllTrim(SAE->AE_TIPO) == "FI" .And. (AllTrim(cCliente)+AllTrim(cLojaCli) == AllTrim(SuperGetMV("MV_CLIPAD"))+AllTrim(SuperGetMV("MV_LOJAPAD")))
					Conout("Cliente padrão não pode efetuar venda financiada, não será  permitido inclusão da forma ")
					LjGrvLog( NIL, "Cliente padrão não pode efetuar venda financiada, não  serápermitido inclusão da forma ")
				Else
					Aadd(aFormPagF5,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
				EndIf
				Exit
			EndIf
			SAE->(dbSkip())
		End
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Cartao Fidelidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(SX5->X5_CHAVE) == "FID"
		Aadd(aFormPagF5,{Capital(Alltrim(X5Descri())),Alltrim(SX5->X5_CHAVE)})
	EndIf

	DbSelectArea("SX5")
	SX5->(dbSkip())
End

//Caso o pais seja diferente de Brasil é necessário incluir todas as moedas
If cPaisLoc <> "BRA"
	For nI := 2 To MoedFin()
		SX5->(DbSeek(xFilial()+"24"+SuperGetMV("MV_SIMB"+Str(nI,1))))
		AAdd(aFormPag, {AllTrim(X5Descri()), SuperGetMV("MV_SIMB"+Str(nI,1)), AllTrim(X5Descri()),"   "})
	Next nI
EndIf

If !lRecebe
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando for importado um orcamento, caso tenha desconto no total    ³
	//³ do cupom, este desconto e considerado quando vai finalizar a venda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVlrDescTot > 0 .OR. nTotDedIcms > 0
		If Len(aParcOrc) >= 0
			If nVlrTotal >= nVlrDescTot
				nVlrTotal := nVlrBruto - nVlrDescTot - nTotDedIcms
			EndIf
		ElseIf Len(aParcOrc) <= 0
			If nVlrTotal >= nVlrDescTot
				nVlrTotal := nVlrBruto - nVlrDescTot - nTotDedIcms + iif(lImpOrc ,SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA,0)
			EndIf
		EndIf
		If !lTouch
			oVlrTotal:Refresh()
		Endif

		LjLogFront("CONCEDE O  DESCONTO DO ORCAMENTO")
		LjLogFront("DESCONTO NO TOTAL",nVlrDescTot)
		LjLogFront("VALOR BRUTO",nVlrBruto)
		LjLogFront("DEDUCAO DE ICMS",nTotDedIcms)

		oCupom:AppendText(PadL((FRT_SEPARATOR),39))
		oCupom:AppendText(CHR(13)+CHR(10))
		oCupom:AppendText(PadR(STR0009,39) )	// "Desconto no total do cupom"
		oCupom:AppendText(CHR(13)+CHR(10))
		oCupom:AppendText(PadR(STR0010,39) )	// "Valor / Percentual"
		oCupom:AppendText((PadR(Trans(nVlrDescTot + nTotDedIcms,PesqPict("SL1","L1_VLRTOT",10,nMoedaCor))+" / "+Trans(nVlrPercTot,"@E 99.99")+"%",39)) + chr(10) + chr(13))
		oCupom:AppendText(PadL((FRT_SEPARATOR),39))
	EndIf

	If cPaisLoc <> "BRA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³So aplica o acrescimo caso a quantidade itens da venda ³
		//³seja igual a quantidade de itens do orcamento original.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nQtdeItOri == Len(aItens)

			If nVlrPercAcr > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama a funcao para o calculo do acrescimo no total da venda - Localizacoes³
				//³"Fazendo o calculo do acrescimo/desconto e o recalculo dos impostos..."    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LJMsgRun(STR0030,,{|| nVlrTotal += LjxDRecVB(	@nVlrTotal ,;
																nVlrPercAcr,;
																0          ,;
																nVlrPercTot,;
																@nVlrTotal ,;
																0          ,;
																1          ,;
																nNumParcs  ,;
																0)})
				nTmpJuros := nVlrPercAcr
				nVlrTotal += aDadosJur[1]

				If !lTouch
					oVlrTotal:Refresh()
				Endif
			EndIf
		EndIf
	EndIf

	If Len(aParcOrc) > 0
		cItemCond := cItemCOrc

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Sempre recalcula o valor total para embutir o acrescimo/desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrTotal := 0
		//Tratamento para impressão de acrescimo quando não incide juros sobre ICMS na multinegociação no cupom virtual
		If lIcmjr .And. Len(aParcOrc) > 0 .And. ValType(aParcOrc[1,13]) == "N"
			aEval(aParcOrc,{|x| nVlrTotal += x[2]+x[13] })
		Else
			aEval(aParcOrc,{|x| nVlrTotal += x[2] })
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso for inserido mais um produto para um orcamento     ³
		//³carregado no Front, utilizar a seguinte regra:          ³
		//³                                                        ³
		//³- Se for outra condicao qualquer, refazer as parcelas do³
		//³orcamento.                                              ³
		//³- Condicao de pagamento negociada processa normalmente, ³
		//³pois sua validacao esta na funcao FR271AProdOK          ³
		//³                                                        ³
		//³16/09/2002 - Fernando Salvatori                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cItemCOrc <> "CN " .AND. lImpNewIT
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+cItemCond))

			// não tem acrescimo mas tem valor de frete
			nVlrAcresBak := 0
			If !lDescSE4 .AND. nVlrAcreTot > 0
				nVlrBruto		+= nVlrAcreTot - nFrete
				nVlrAcresBak	:= nFrete
			EndIf
			If !lCFrete
				nVlrBruto	+= nFrete
				lCFrete	:= .T.
			EndIf

			aCondRecalc := AClone(LJ7CalcPgt( 	nVlrBruto - nVlrDescTot - nTotDedIcms	,;
												cItemCond  								,;
												NIL      								,;
												NIL  									,;
			                                   	@nTmpJuros                            	,;
			                                   	@nTmpDesc 								,;
			                                   	nMoedaCor								,;
			                                   	NIL										,;
			                                   	NIL										,;
			                                   	@nMoedaCor								,;
			                                   	@nDecimais ))
			nVlrTotal   := 0
			aEval(aParcOrc,{|ExpA1| ExpA1[2] := aCondRecalc[nAux+=1][2] })
			aEval(aCondRecalc,{|x| nVlrTotal += x[2]})

			nVlrAcreTot := 0
			If SE4->E4_ACRSFIN > 0		// Valor do acrescimo financeiro
				nVlrAcreTot	:= nVlrTotal - nVlrBruto + nVlrDescTot
				LjLogFront("CONDPG-ACRESCIMO NO TOTAL",nVlrAcreTot)
			Endif

			//Devolve o valor do frete à variável de acréscimo
			nVlrAcreTot += nVlrAcresBak

			nVlrDescCPg := 0
			If SE4->E4_DESCFIN > 0		// Valor do desconto financeiro
				nVlrDescCPg := nVlrBruto - (nVlrTotal + nVlrDescTot + nTotDedIcms)
				LjLogFront("CONDPG-DESCONTO NO TOTAL",nVlrDescCPg)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A 12º posição do cartão poderá conter os 4 últimos dígitos ou o ID do cartão para as múltiplas transações TEF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lVisuSint
		   aEval(aParcOrc,{|x| Aadd(x,cFormaID)})
		Else
		   aEval(aParcOrc,{|x| Aadd(x,Space(04))})
		EndIf

		aPgtos := aClone( aParcOrc )

		If !lTouch
			//Atualizacao do valor total
			oVlrTotal:Refresh()
		Endif
	EndIf
	If lFRTACRES
		// PE na escolha de uma condicao de pagamento
		xRet := U_FRTACRES(aItens	 , aPgtos	 , 2 	   , @nVlrDescTot, @nVlrPercTot,;
		    			   @nVlrTotal, nVlrBruto , @oCupom , nMoedaCor   , nTotDedIcms)

		If ValType( xRet ) == "N"
			nVlrAcreTot += xRet
		Endif

		If !lTouch
			//Atualizacao do valor total
			oVlrTotal:Refresh()
		Endif
	Endif
EndIf

//Tratamento para impressão de acrescimo quando não incide juros sobre ICMS na multinegociação no cupom virtual
If lIcmjr .And. Len(aParcOrc) > 0 .And. ValType(aParcOrc[1,13]) == "N"
	nVlrTotal := 0
	aEval(aParcOrc,{|x| nVlrTotal += x[2]})
EndIf

LjLogFront("CONDPG-nVlrTotal",nVlrTotal)
LjLogFront("CONDPG-nVlrBruto",nVlrBruto)
LjLogFront("CONDPG-ACRESCIMO NO TOTAL",nVlrAcreTot)
LjLogFront("CONDPG-DESCONTO NO TOTAL",nVlrDescCPg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  aSetKey := { {|| If(ExistBlock("FRTF4ENC"),ExecBlock('FRTF4ENC ',.F.,.F.,{aFormPag}),)},;					// F4
			{|| lAltParc:=.F., FR271HCondPag(	@aCondicoes		, @cItemForma	, @nTmpJuros	, @aPgtos		,;
										   		@oPgtos			, @nTmpDesc		, @oCupom		, @nMoedaCor	,;
												@oVlrTotal		, @nVlrBruto	, @nVlrTotal	, @nVlrDescTot	,;
												@oPgtosSint 	, @aPgtosSint	, @nEntrada 	, @nTaxaMoeda	,;
												@lRecebe		, @dDataCN		, @lEsc			, @uCliTPL		,;
												@uProdTPL		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	,;
												@nVlrAcreTot	, @nVlrDescCPg	, @aFormCtrl	, @cItemCond	,;
												@lCondNegF5		, @nTxJuros		, @nValorBase	, @lDiaFixo     ,;
												@cCupom 		, @aItens		, lTefPendCS	, aTefBkpCS		,;
												@aVidaLinkD		, lImpOrc		, cOrcam        , cCliente      ,;
												cLojaCli, nValIpi)	,;
				lAltParc :=.T.},;													// F5  - Alterar Condicao de Pagamento
			{|| lAltParc:=.F., FR271FDescTot(	@nTmpJuros		, @nTmpDesc		, Nil			, @oPgtosSint	,;
		 										@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		,;
												@nVlrTotal 		, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	,;
												@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		,;
												@aItens			, @nVlrMerc		, @lDescTotal	, @lDescSE4		,;
												@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	,;
												@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	,;
												@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	,;
												@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc		,;
												@lRecalImp	    , @aCols	   	, @aHeader		, cOrcam		,;
												Nil             , Nil       , Nil           , Nil  	        ,;
												Nil				, Nil 			, cCliente      , cLojaCli 	,;
												Nil				, aParcOrc    , nVlrAcreTot   , nVlrPercAcr   ,;
												nVlrDescCPg 	, lTela		, aReserva		, @nDescToP) ,;
												@lAltParc:=.T.},;				// F6  - Desconto no Total da Venda
			,;
			,;																	// F8
			{|| lAltParc:=.F., aKeyFimVenda := FrtSetKey(),;
			    If(FR271GEncerra(	aFormPag  		, cItemForma 	, nTmpJuros    	, @lEncerra    		,;
			                  		nTmpDesc		, @oFimVenda  	, @lTEFPendRec 	, @aRecTEFMult 		,;
			                  		@cNCartao		, @oHora		, @cHora		, @oDoc				,;
							  		@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT		,;
							  		@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens		,;
							  		@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal		,;
									@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3			,;
							 		@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda		,;
									@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd			,;
									@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade			,;
									@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant			,;
									@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7				,;
									@oPgtos			, @oPgtosSint	, @cOrcam		, @aPgtos			,;
									@cPDV			, @aPgtosSint	, @lTefPendCS 	, @aTefBKPCS		,;
									@nEntrada		, @cCliente		, @cLojaCli		, @cVendLoja		,;
									@lOcioso 		, @lRecebe		, @lLocked		, @lCXAberto		,;
									@aTefDados		, @nVlrFSD		, @lDescIT		, @nVlrDescTot		,;
									@nValIPI		, @aItens		, @nVlrMerc		, @aParcOrc			,;
									@lAltVend		, @lFechaCup	, @aTpAdmsTmp	, @cUsrSessionID	,;
									@cContrato		, @aCrdCliente	, @aContratos	, @aRecCrd			,;
									@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv			,;
									@cNumCartConv	, @uCliTPL		, @uProdTPL		, @aVidaLinkD		,;
									@aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	, @cCdDescOrc		,;
									@nValTPis		, @nValTCof		, @nValTCsl		, @lOrigOrcam		,;
									@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot		,;
									@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri		,;
									@nQtdeItOri		, @nNumParcs	, @aMoeda		, @aSimbs			,;
									@cRecCart		, @cRecCPF		, @cRecCont		, @aImpsSL1			,;
									@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen			,;
									@nTotalAcrs 	, @aCols		, @aHeader		, @aDadosJur		,;
									@aCProva		, @aFormCtrl	, @nTroco		, @nTroco2			,;
									@lDescCond		, @nDesconto	, @aDadosCH		, @cItemCond		,;
									@lCondNegF5		, @aTefMult		, @aTitulo		, @lConfLJRec		,;
									@aTitImp		, @aParcelas	, @oPgtosAna	, @nTxJuros			,;
									@lVendaRapida	, @nValorBase 	, @oMensagem	, @oFntGet			,;
									NIL				, NIL			, @cTipoCli		, @cEntrega			,;
									@aReserva		, @lReserva		, @lAbreCup		, @nValor		    ,;
									@oTimer   		, @lResume		, @aValePre		, @aRegTEF			,;
									@lRecarEfet		, @lCancItRec	, @cNumDAV		, @cCliCGC			,;
									@cMensagem		, @nVlrDescIT	, @aTxJurAdm		, @cDocFo         ,;
									@nArredondar	, @lSelTefManu, nDescItens		, @nDescToP),;									
				   (IIf(LEN(aRecTEFMult) > 0, aTEFMult := AClone(aRecTEFMult),NIL),;
				    lAltParc:=.T.,oFimVenda:End()),),;
				FrtSetKey(aKeyFimVenda), lAltParc:=.T.},;					        // F9  - Encerra a Venda
			{|| lAltParc:=.F., FR271EAltCli(	@cNCartao	, @cCliente		, @cLojaCli		, @lOcioso,;
												@lRecebe	, @lCXAberto	, @aCrdCliente	, @cCodConv	,;
												@cLojConv	, @cNumCartConv	, @uCliTPL		, @uProdTPL ,;
												@aItens		, @cCodDep		, @cNomeDEP		, @cTipoCli	,;
												@lBscCliON	, @nConTcLnk	, NIL           , @cMsgCupom ), lAltParc:=.T.},; // F10 - Alteracao de Clientes
			{|| lAltParc:=.F., FR271FAltVend(	@cVendLoja	, @lOcioso		, @lRecebe		, @lCXAberto	,;
												@lAltVend )	, lAltParc:=.T.},;						// F11 - Alteracao de Vendedores
			{|| lAltParc:=.F., If(FR271FFuncoes(	@oHora			, @cHora		, @oDoc			, @cDoc			,;
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
													@cPDV			, @lTefPendCS 	, @aTefBKPCS	, @oDlgFrt 		,;
													@cCliente		, @cLojaCli		, @cVendLoja	, @lOcioso		,;
													@lRecebe		, @lLocked		, @lCXAberto	, @aTefDados	,;
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
													@nTxJuros		, @nValorBase	, @oMensagem	, @oFntGet	    ,;
													@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva		,;
													@oTimer 		, @lResume		, @nValor		, @aRegTEF		,;
													@lRecarEfet		, @oOnOffLine	, @nValIPIIT	, @_aMult		,;
													@_aMultCanc		, @nVlrDescIT	, @oFntMoeda	, @lBscPrdON	,;
													@oPDV			, @aICMS		, @lDescITReg	, @cMensagem		,;
													@nDescItens    ),;
													(lAltParc:=.T.,oFimVenda:End()),),;
													lAltParc:=.T.} }					// F12 - Funcoes Diversas (Funcao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Tecla CTRL+A Sempre Sera Dinheiro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	If LjGetOPBM() <> Nil
		If LjSubsidio(@aFormCtrl, @aPgtos, @nMoedaCor, @aPgtosSint, @nVidaLink, @aVidaLinkD)
			//Se tiver subsidio, seta a variavel de template igual a falso para carrega as teclas de atalho
			//das formas de pagamento
			lTFrtAltPg := .F.
		EndIf
	EndIf

	If (nVidalink <> 0 .AND. Len(aVidaLinkD) > 0 )
		LjSubsidio(@aFormCtrl, @aPgtos, @nMoedaCor, @aPgtosSint, @nVidaLink, @aVidaLinkD)
		lTFrtAltPg := .F.
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³FRTALTPG - Utilizado para omitir as formas de pagamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)][1], aFormPag[Len(aFormPag)][2],lRecebe,cMVLJTPPAG}),.T.) .AND.;
		   Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)][1], aFormPag[Len(aFormPag)][2],lRecebe}),.T.) )
			lKey := .T.
		Else
			lKey := .F.
		EndIf
  	Else
		// Validar as formas de pagamentos validas atraves do parametro MV_LJTPPAG
		If lRecebe
			IF aFormPag[Len(aFormPag)][2] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)
				lKey := .T.
			Else
				lKey := .F.
			Endif
		Else
			lKey := .T.
		EndIf
	EndIf

	If nVlrTotal == 0 .And. Frt060Ret("NCC_USADA") > 0
		lKey := .F.
	EndIf

	If lKey

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega na variavel a mesma posicao do array aFormPag,    ³
		//³ para identificacao da Forma de pagmento, dentro da funcao³
		//³ de desconto                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	bFuncDesc := (" FR271FDescTot(	0		, 0	   			, .F.			, @oPgtosSint  	, " + ;
		 						"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " + ;
								"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " + ;
								"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " + ;
								"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " + ;
								"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais   	, " + ;
								"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " + ;
								"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " + ;
								"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc		, " + ;
								"@lRecalImp	    , @aCols	   	, @aHeader		, cOrcam 		, " + ;
								"Nil            , Nil           , Nil           , Nil           , " + ;
								"Nil			, Nil			, cCliente      , cLojaCli    	),"	+ ;
				"FR271FDescTot(	@nTmpJuros		, @nTmpDesc		, .T.			, @oPgtosSint  	, " + ;
		 						"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " + ;
								"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " + ;
								"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " + ;
								"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " + ;
								"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais   	, " + ;
								"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " + ;
								"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " + ;
								"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc		, " + ;
								"@lRecalImp	    , @aCols	   	, @aHeader		, cOrcam		, " + ;
								"Nil			, Nil			, Nil			, Nil			, " + ;
								" aFormPag		, Len(aFormPag)	, cCliente      , cLojaCli    	)")

		bKey := (" FR271FFormPag(	aFormPag," + "'"+aFormPag[Len(aFormPag)][1]+"', '" + aFormPag[Len(aFormPag)][2]+"', Nil, "+;
									"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
									"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
									"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
									"@aPgtosSint	, @lRecebe		, @aParcOrc		, @aParcOrcOld	, " +;
									"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg  , @aMoeda		, " +;
									"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
									"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
									"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
									"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
									"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
									"@nValDescPa	, @aTxJurAdm	,				,				, " +;
									"NIL			, @nEntrada		, @dDataCN		, @aItens		, " +;
									"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
									"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
									"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
									"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
									"@nArredondar ) 		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa   , .T.        	 )")
	Else
		bKey := Nil
	Endif
Else
  	bPesqSimb := {|| nPosSimb := Iif(!Empty(aPgtos) .AND. oPgtos <> Nil .AND. IsMoney(aPgtos[oPgtos:nAt][3]), ;
  		Ascan( aFormPag,{|x| Trim(x[2]) == aPgtos[oPgtos:nAt][3]}), ;
  		Ascan( aFormPag,{|x| Trim(x[2]) == cSimbCor}))}
	bDscMoeda := {|| aFormPag[Eval(bPesqSimb)][1]}
	bSmbMoeda := {|| aFormPag[Eval(bPesqSimb)][2]}
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{Eval(bDscMoeda), Eval(bSmbMoeda),lRecebe,cMVLJTPPAG}),.T.) .AND.;
		    Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{Eval(bDscMoeda), Eval(bSmbMoeda),lRecebe}),.T.))
			lKey := .T.
		Else
			lKey := .F.
		EndIf
	Else
		lKey :=	.T.
	EndIf

	If lKey
		bKey := (" FR271FFormPag(	aFormPag		, Eval(bDscMoeda)	, Eval(bSmbMoeda)	, Nil			, " +;
									"@cDoc			, @oCupom			, @cCupom			, @nVlrTotal 	, " +;
									"@nVlrBruto		, @oVlrTotal		, @nMoedaCor		, @cSimbCor		, "	+;
									"@nTaxaMoeda	, @oPgtos			, @oPgtosSint		, @aPgtos		, " +;
									"@aPgtosSint	, @lRecebe			, @aParcOrc			, @aParcOrcOld 	, " +;
									"@nVlrPercAcr	, @nVlrAcreTot		, @nVlrDescCPg 		, @aMoeda		, " +;
									"@aSimbs		, @aCols			, @aCProva			, @aFormCtrl	, " +;
									"@nTroco		, @nTroco2 			, @lDescCond		, @nDesconto	, " +;
									"@aDadosCH		, @cItemCond		, @lCondNegF5		, @aParcelas	, " +;
									"@cCliente 		, @cLojaCli         , @nVlrDescTot      , @aValePre 	, " +;
									"@aRegTEF		, @lRecarEfet		, @aColsMAV			, aTefBkpCS		, " +;
									"@nValDescPa	, @aTxJurAdm		,					,				, " +;
									"NIL			, @nEntrada			, @dDataCN 			, @aItens 		, " +;
									"@nVlrMerc		, @lDescTotal		, @lDescSE4			, @nTotDedIcms	, " +;
									"@nVlrPercTot	, @aImpsSL1			, @aImpsSL2			, @aImpsProd	, " +;
									"@aDadosJur		, @lDescEspec		, @nValorBase		, @lDiaFixo		, " +;
									"@lImpOrc		, @lRecalImp		, @aHeader			, @cOrcam            , " +;
									"@nArredondar) 		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa	,  .T.			) ")
	Else
		bKey := Nil
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for regra de desconto, vai carregar no bKey o desconto e a ³
//³ chamada da funcao de forma de pagto em bloco de codigo, se   ³
//³ nao for, so deixa a funcao de forma de pagto em bloco.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(bKey)
	If lNovRegDesc .And. (cPaisLoc == "BRA")
		bKey := &("{|| " + bFuncDesc + " , " + bKey + " } ")
	Else
		bKey := &("{|| " + bKey + " } ")
	EndIf
	AAdd(aSetKey, bKey)
EndIf
lKey := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A Tecla CTRL+B Sempre Sera Cheque   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)-1][1], aFormPag[Len(aFormPag)-1][2],lRecebe,cMVLJTPPAG}),.T.) .AND.;
		    Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[Len(aFormPag)-1][1], aFormPag[Len(aFormPag)-1][2],lRecebe}),.T.))
			lKey := .T.
		EndIf
	Else
		// Validar as formas de pagamentos validas atraves do parametro MV_LJTPPAG
		If lRecebe
			If  aFormPag[Len(aFormPag)-1][2] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)
				lKey := .T.
			EndIf
		Else
			lKey := .T.
		EndIf
	EndIf



	If lKey
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega na variavel a mesma posicao do array aFormPag,    ³
		//³ para identificacao da Forma de pagmento, dentro da funcao³
		//³ de desconto                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bFuncDesc := ( "	FR271FDescTot(	0		, 0	   			, .F.			, @oPgtosSint  	, " + ;
		 						"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " + ;
								"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " + ;
								"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " + ;
								"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " + ;
								"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais   	, " + ;
								"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " + ;
								"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " + ;
								"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc		, " + ;
								"@lRecalImp	    , @aCols	   	, @aHeader		, cOrcam        , " + ;
								"               ,               ,               , 		        , " + ;
								" 				, 				, cCliente     , cLojaCli      ), "	+ ;
				"FR271FDescTot(	@nTmpJuros		, @nTmpDesc		, .T.			, @oPgtosSint  	, " + ;
		 						"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " + ;
								"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " + ;
								"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " + ;
								"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " + ;
								"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais   	, " + ;
								"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " + ;
								"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " + ;
								"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc		, " + ;
								"@lRecalImp	    , @aCols	   	, @aHeader		, cOrcam		, " + ;
								"				,				, 				, 				, " + ;
								" aFormPag		, Len(aFormPag)-1, cCliente     ,cLojaCli 		)" )

		bKey := (" FR271FFormPag(aFormPag, '"+aFormPag[Len(aFormPag)-1][1]+"', '"+aFormPag[Len(aFormPag)-1][2]+"', Nil, " +;
									"@cDoc			, @oCupom			, @cCupom			, @nVlrTotal 	, " +;
									"@nVlrBruto		, @oVlrTotal		, @nMoedaCor		, @cSimbCor		, "	+;
									"@nTaxaMoeda	, @oPgtos			, @oPgtosSint		, @aPgtos		, " +;
									"@aPgtosSint	, @lRecebe			, @aParcOrc			, @aParcOrcOld	, " +;
									"@nVlrPercAcr	, @nVlrAcreTot		, @nVlrDescCPg  	, @aMoeda		, " +;
									"@aSimbs		, @aCols			, @aCProva			, @aFormCtrl	, " +;
									"@nTroco		, @nTroco2 			, @lDescCond		, @nDesconto	, " +;
									"@aDadosCH		, @cItemCond		, @lCondNegF5		, @aParcelas	, " +;
									"@cCliente 		, @cLojaCli         , @nVlrDescTot      , @aValePre 	, " +;
									"@aRegTEF		, @lRecarEfet 		, @aColsMAV			, aTefBkpCS		, " +;
									"@nValDescPa	, @aTxJurAdm		,					,				, " +;
									"NIL			, @nEntrada			, @dDataCN 			, @aItens 		, " +;
									"@nVlrMerc		, @lDescTotal		, @lDescSE4			, @nTotDedIcms	, " +;
									"@nVlrPercTot	, @aImpsSL1			, @aImpsSL2			, @aImpsProd	, " +;
									"@aDadosJur		, @lDescEspec		, @nValorBase		, @lDiaFixo		, " +;
									"@lImpOrc		, @lRecalImp		, @aHeader			, @cOrcam            , " +;
									"@nArredondar) 		, " +;
					"FR271FDescTot(	 @nTmpJuros		, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa	,  .T.) ")
	Else
		bKey := Nil
	Endif

Else
	nPosSimb := Ascan( aFormPag,{|x| Trim(x[2]) == cSimbCheq})
	If lFrtAltPg .OR. lTFrtAltPg
		If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[nPosSimb][1], aFormPag[nPosSimb][2],lRecebe,cMVLJTPPAG}),.T.) .AND.;
		    Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[nPosSimb][1], aFormPag[nPosSimb][2],lRecebe}),.T.))
			lKey := .T.
		EndIf
	Else
			lKey := .T.
	EndIf

	If lKey
		bKey := (" FR271FFormPag(aFormPag, '"+aFormPag[nPosSimb][1]+"', '"+aFormPag[nPosSimb][2]+"', Nil,	" +;
									"@cDoc			, @oCupom			, @cCupom			, @nVlrTotal 	, 	" +;
									"@nVlrBruto		, @oVlrTotal		, @nMoedaCor		, @cSimbCor		, 	" +;
									"@nTaxaMoeda	, @oPgtos			, @oPgtosSint		, @aPgtos		, 	" +;
									"@aPgtosSint 	, @lRecebe 			, @aParcOrc			, @aParcOrcOld	, 	" +;
									"@nVlrPercAcr	, @nVlrAcreTot		, @nVlrDescCPg		, @aMoeda		, 	" +;
									"@aSimbs		, @aCols			, @aCProva			, @aFormCtrl	, 	" +;
									"@nTroco		, @nTroco2 			, @lDescCond		, @nDesconto	, 	" +;
									"@aDadosCH		, @cItemCond		, @lCondNegF5		, @aParcelas	, 	" +;
									"@cCliente 		, @cLojaCli         , @nVlrDescTot      , @aValePre		,	" +;
									"@aRegTEF		, @lRecarEfet 		, @aColsMAV			, aTefBkpCS		,	" +;
									"@nValDescPa	, @aTxJurAdm		,					,				,	" +;
									"NIL			, @nEntrada			, @dDataCN 			, @aItens 		, 	" +;
									"@nVlrMerc		, @lDescTotal		, @lDescSE4			, @nTotDedIcms	,	" +;
									"@nVlrPercTot	, @aImpsSL1			, @aImpsSL2			, @aImpsProd	,	" +;
									"@aDadosJur		, @lDescEspec		, @nValorBase		, @lDiaFixo		,	" +;
									"@lImpOrc		, @lRecalImp		, @aHeader			, @cOrcam            ,   " +;
									"@nArredondar) 		, 	" +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.) ")
	Else
		bKey := Nil
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for regra de desconto, vai carregar no bKey o desconto e a ³
//³ chamada da funcao de forma de pagto em bloco de codigo, se   ³
//³ nao for, so deixa a funcao de forma de pagto em bloco.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(bKey)
	If lNovRegDesc .And. (cPaisLoc == "BRA")
		bKey := &("{|| " + bFuncDesc + " , " + bKey + " } ")
	Else
		bKey := &("{|| " + bKey + " } ")
	EndIf
	AAdd(aSetKey, bKey)
Endif

For nZ := Asc("C") To Asc("Y")
   For nI := 1 To Len(aFormPag)-2
      If Left(aFormPag[nI][4],1) == Chr(nZ)
		If lFrtAltPg .OR. lTFrtAltPg
			If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],lRecebe,cMVLJTPPAG}),.T.) .AND.;
				Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{"",Chr(nZ),lRecebe}),.T.))
				bKey := &("{|| FR271FFormPag(aFormPag		,				,				, '"+Chr(nZ) +"', " +;
											"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
											"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
											"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
											"@aPgtosSint	, @lRecebe 		, @aParcOrc		, @aParcOrcOld 	, " +;
											"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		, " +;
											"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
											"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
											"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
											"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
											"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
											"@nValDescPa	, @aTxJurAdm	,				,				, " +;
											"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
											"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
											"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
											"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
											"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
											"@nArredondar) 		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")
			 	AAdd(aSetKey, bKey)
			 	Exit
			EndIf
		Else
			If lRecebe
				If aFormPag[nI][2] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)
		    		bKey := &("{|| FR271FFormPag(	aFormPag		,				,				,'"+Chr(nZ) + "', " +;
												"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
												"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
												"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
												"@aPgtosSint	, @lRecebe		, @aParcOrc		, @aParcOrcOld	, " +;
												"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg 	, @aMoeda		, " +;
												"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
												"nTroco			, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
												"aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
												"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
												"@aRegTEF		, @lRecarEfet   , @aColsMAV		, aTefBkpCS		, " +;
												"@nValDescPa	, @aTxJurAdm	,				,				, " +;
												"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
												"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
												"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
												"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
												"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
												"@nArredondar) 		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")
					AAdd(aSetKey, bKey)
				EndIF
			Else
				bKey := &("{|| FR271FFormPag(	aFormPag		,				,				,'"+Chr(nZ)  +"', " +;
											"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
											"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
											"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
											"@aPgtosSint	, @lRecebe  	, @aParcOrc		, @aParcOrcOld	, " +;
											"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		, " +;
											"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
											"nTroco			, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
											"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
											"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
											"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
											"@nValDescPa	, @aTxJurAdm	,				,				, " +;
											"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
											"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
											"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
											"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
											"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
											"@nArredondar) 		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")
				AAdd(aSetKey, bKey)
			EndIF
			Exit
		EndIf
      EndIf
   Next nI
Next nZ
If cPaisLoc == "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ha algum grupo de Administracao do FrontLoja, pois se houver sera necessario tratar os SetKeys³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aSetKey) > 11	//11 eh o tamanho padrao de um aSetKey sem Administradoras do FrontLoja cadastrados
		For nI := 1 To Len(aFormPag)
			If !Empty(aFormPag[nI][4])
				nSum++
			EndIf
		Next nI
		nSum -= (Len(aSetKey) - 11)		//o resultado de (Len(aSetKey) - 11) eh a quantidade de Grupos de Administradoras do FrontLoja
	EndIf
	nCtrlO += nSum
	nCtrlX += nSum

    // Parte do principio que o cliente configurou todos os registros da SAE
	nI := 1
	If Empty(aFormPag[nI][4])
		For nI := 1 To Len(aFormPag)-2
			If (nI == nCtrlO) .OR. (nI == nCtrlX)	// Verifica se as posicoes sao referentes as teclas (CTRL + O) ou (CTRL + X)
				bKey := Nil
			   	AAdd(aSetKey, bKey)
				nPosicao++
				lCtrlOX := .T.
				Loop
			EndIf

			If lFrtAltPg .OR. lTFrtAltPg
				If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],lRecebe,cMVLJTPPAG}),.T.) .AND.;
				   Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],lRecebe}),.T.))
					bKey := &("{|| FR271FFormPag(	aFormPag, '"+aFormPag[nI][1]+"', '"+aFormPag[nI][2]+"', Nil, " +;
												"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
												"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
												"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
												"@aPgtosSint 	, @lRecebe	 	, @aParcOrc		, @aParcOrcOld	, " +;
												"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		, " +;
												"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
												"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
												"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
												"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
												"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
												"				,				,				,				, " +;
												"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
												"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
												"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
												"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
												"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
												"@nArredondar )}")
					AAdd(aSetKey, bKey)
				EndIf
			Else
				If lRecebe
					If  aFormPag[nI][2] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)
						bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2]+"', Nil,  " +;
													"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
													"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
													"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
													"@aPgtosSint 	, @lRecebe		, @aParcOrc		, @aParcOrcOld 	, " +;
													"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		, " +;
													"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
													"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
													"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
												   	"@cCliente 		, @cLojaCli	    , @nVlrDescTot  , @aValePre 	, " +;
												   	"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
													"@nValDescPa	, @aTxJurAdm	,				,				, " +;
													"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
													"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
													"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
													"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
													"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
													"@nArredondar), " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")
						AAdd(aSetKey, bKey)
					EndIf
				Else
					bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2]+"', Nil, " +;
											"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
											"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
											"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
											"@aPgtosSint	, @lRecebe 		, @aParcOrc		, @aParcOrcOld	, " +;
											"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg 	, @aMoeda		, " +;
											"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
											"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
											"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
											"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
											"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
											"@nValDescPa	, @aTxJurAdm	,				,				, " +;
											"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
											"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
											"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
											"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
											"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
											"@nArredondar), " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")
					AAdd(aSetKey, bKey)
				EndIf
				If nI == Len(aFormPag)-2 .AND. lCtrlOX
					nI+=nPosicao
					bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2]+"', Nil, " +;
											"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
											"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
											"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
											"@aPgtosSint	, @lRecebe 		, @aParcOrc		, @aParcOrcOld	, " +;
											"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg 	, @aMoeda		, " +;
											"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
											"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
											"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
											"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
											"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
											"@nValDescPa	, @aTxJurAdm	,				,				, " +;
											"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
											"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
											"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
											"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
											"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
											"@nArredondar), " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")
					AAdd(aSetKey, bKey)
				EndIf
			EndIF
		Next
	Else
		For nZ := Asc("C") To Asc("Y")
			For nI := 1 To Len(aFormPag)-2
				If Left(aFormPag[nI][4],1) == Chr(nZ)
					If (nI == nCtrlO) .OR. (nI == nCtrlX)	// Verifica se as posicoes sao referentes as teclas (CTRL + O) ou (CTRL + X)
						bKey := Nil
					   	AAdd(aSetKey, bKey)
						nPosicao++
						lCtrlOX := .T.
						Loop
					EndIf

					If lRecebe
						If aFormPag[nI][2] $ cMVLJTPPAG .OR. Empty(cMVLJTPPAG)

							lUsaAdm := Iif( lMV_LJSLFin, .T., .F. )

							// Na funcao FR271FFormPag e verificada a forma e atribuido novo valor a variavel cGrupo
							bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2] + Iif(lUsaAdm, "', '" + Left(aFormPag[nI,04], 1) + "', " , "', Nil,  ") +;
														"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
														"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
														"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
														"@aPgtosSint 	, @lRecebe		, @aParcOrc		, @aParcOrcOld 	, " +;
														"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		, " +;
														"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
														"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
														"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
													   	"@cCliente 		, @cLojaCli	    , @nVlrDescTot  , @aValePre 	, " +;
													   	"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
														"@nValDescPa	, @aTxJurAdm	,				,				, " +;
														"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
														"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
														"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
														"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
														"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
														"@nArredondar) 		, " +;
							"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
										"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
										"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
										"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
										"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
										"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
										"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
										"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
										"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
										"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
										"Nil			, Nil			, @nValDescPa,  .T.)} ")
							AAdd(aSetKey, bKey)
							Exit
						EndIf
					Else
						bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2]+"', Nil, " +;
												"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
												"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
												"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
												"@aPgtosSint	, @lRecebe 		, @aParcOrc		, @aParcOrcOld	, " +;
												"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg 	, @aMoeda		, " +;
												"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
												"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
												"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
												"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
												"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
												"@nValDescPa	, @aTxJurAdm	,				,				, " +;
												"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
												"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
												"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
												"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
												"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
												"@nArredondar) 		, " +;
							"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
										"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
										"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
										"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
										"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
										"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
										"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
										"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
										"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
										"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
										"Nil			, Nil			, @nValDescPa,  .T.)} ")
						AAdd(aSetKey, bKey)
						Exit
					EndIf
				Endif
			Next nI
		Next nZ
	Endif
Else
	nPosSimb := (Ascan( aFormPag,{|x| Trim(x[2]) == SuperGetMV("MV_SIMB1")})-2)
	For nI := 1 To nPosSimb
		If (nI == nCtrlO) .OR. (nI == nCtrlX)	// Verifica se as posicoes sao referentes as teclas (CTRL + O) ou (CTRL + X)
			bKey := Nil
		  	AAdd(aSetKey, bKey)
		  	nPosicao++
			lCtrlOX := .T.
			Loop
		EndIf
		If Empty(aFormPag[nI][4])
			If lFrtAltPg .OR. lTFrtAltPg
				If (Iif(lTFrtAltPg,ExecTemplate("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],lRecebe,cMVLJTPPAG}),.T.) .AND.;
				   Iif(lFrtAltPg,ExecBlock("FRTALTPG",.F.,.F.,{aFormPag[nI][1],aFormPag[nI][2],lRecebe}),.T.))
				   bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2]+"', Nil, " +;
											"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
											"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
											"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
											"@aPgtosSint	, @lRecebe  	, @aParcOrc		, @aParcOrcOld	, " +;
											"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		, " +;
											"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
											"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
											"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
											"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
											"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
											"@nValDescPa	, @aTxJurAdm	,				,				, " +;
											"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
											"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
											"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
											"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
											"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
											"@nArredondar )		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam  		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")

				   AAdd(aSetKey, bKey)
				EndIf
			Else
			   bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2]+"', Nil, " +;
											"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
											"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
											"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
											"@aPgtosSint	, @lRecebe		, @aParcOrc 	, @aParcOrcOld	, " +;
											"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @aMoeda		, " +;
											"@aSimbs		, @aCols		, @aCProva 		, @aFormCtrl	, " +;
											"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
											"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
											"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
											"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
											"@nValDescPa	, @aTxJurAdm	,				,				, " +;
											"NIL			, @nEntrada		, @dDataCN 		, @aItens 		, " +;
											"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
											"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
											"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
											"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
											"@nArredondar )		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")

			   AAdd(aSetKey, bKey)
			EndIf
			If nI == nPosSimb .AND. lCtrlOX
				nI+=nPosicao
				bKey := &("{|| FR271FFormPag(aFormPag, '"+aFormPag[nI-nPosicao][1]+"', '"+aFormPag[nI-nPosicao][2]+"', Nil, " +;
											"@cDoc			, @oCupom		, @cCupom		, @nVlrTotal 	, " +;
											"@nVlrBruto		, @oVlrTotal	, @nMoedaCor	, @cSimbCor		, "	+;
											"@nTaxaMoeda	, @oPgtos		, @oPgtosSint	, @aPgtos		, " +;
											"@aPgtosSint	, @lRecebe 		, @aParcOrc		, @aParcOrcOld	, " +;
											"@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg 	, @aMoeda		, " +;
											"@aSimbs		, @aCols		, @aCProva		, @aFormCtrl	, " +;
											"@nTroco		, @nTroco2 		, @lDescCond	, @nDesconto	, " +;
											"@aDadosCH		, @cItemCond	, @lCondNegF5	, @aParcelas	, " +;
											"@cCliente 		, @cLojaCli     , @nVlrDescTot  , @aValePre 	, " +;
											"@aRegTEF		, @lRecarEfet	, @aColsMAV		, aTefBkpCS		, " +;
											"@nValDescPa	, @aTxJurAdm	,				,				, " +;
											"NIL		, @nEntrada		, @dDataCN 		, @aItens 		, " +;
											"@nVlrMerc		, @lDescTotal	, @lDescSE4		, @nTotDedIcms	, " +;
											"@nVlrPercTot	, @aImpsSL1		, @aImpsSL2		, @aImpsProd	, " +;
											"@aDadosJur		, @lDescEspec	, @nValorBase	, @lDiaFixo		, " +;
											"@lImpOrc		, @lRecalImp	, @aHeader		, @cOrcam            , " +;
											"@nArredondar)		, " +;
						"FR271FDescTot(	@nTmpJuros	, @nTmpDesc		, .F.			, @oPgtosSint	, " +;
									"@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		, " +;
									"@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	, " +;
									"@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		, " +;
									"@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		, " +;
									"@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	, " +;
									"@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	, " +;
									"@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	, " +;
									"@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		, " +;
									"@lRecalImp		, @aCols		, @aHeader		, cOrcam		, " +;
									"Nil			, Nil			, @nValDescPa,  .T.)} ")

				AAdd(aSetKey, bKey)
			EndIf
		EndIf
	Next nI
EndIf

FRTSetKey(aSetKey)

If lTouch
	DEFINE MSDIALOG oFimVenda FROM C(000), C(000) TO C(520), C(850) ;
		PIXEL STYLE nOr(WS_VISIBLE, WS_POPUP)
	DEFINE FONT oFonte	NAME "TIMES NEW ROMAN" SIZE 12.5,20 Bold
	// Quadrante Principal
	@ C(000),C(010) MSPANEL oPrincipal SIZE C(420),C(275) OF oFimVenda
	@ C(000),C(001) TO C(274),C(419) PIXEL OF oPrincipal

	If cUsaTe == "D"
		// Quadrante 1
		@ C(004),C(003) MSPANEL oQdt1 SIZE C(165),C(140) OF oPrincipal

		// Quadrante 2
		@ C(130),C(003) MSPANEL oQdt2 SIZE C(165),C(140) OF oPrincipal
		@ C(000),C(001) TO C(139),C(164) PIXEL OF oQdt2

		// Quadrante 3
		@ C(004),C(170) MSPANEL oQdt3 SIZE C(196),C(267) OF oPrincipal
		@ C(001),C(001) TO C(266),C(195)PIXEL OF oQdt3

	    // Quadrante 4
		@ C(004),C(370) MSPANEL oQdt4 SIZE C(044),C(267) OF oPrincipal
		@ C(001),C(001) TO C(266),C(043)PIXEL OF oQdt4
	Else
	    // Quadrante 4
		@ C(004),C(004) MSPANEL oQdt4 SIZE C(044),C(267) OF oPrincipal
		@ C(001),C(001) TO C(266),C(043) PIXEL OF oQdt4

	    // Quadrante 3
	    @ C(004),C(048) MSPANEL oQdt3 SIZE C(200),C(267) OF oPrincipal
  		@ C(000),C(000) TO C(266),C(199)PIXEL OF oQdt3

	    // Quadrante 1
		@ C(004),C(250) MSPANEL oQdt1 SIZE C(166),C(145) OF oPrincipal
		@ C(000),C(001) TO C(142),C(165) PIXEL OF oQdt1

	   	// Quadrante 2
	   	@ C(145),C(250) MSPANEL oQdt2 SIZE C(166),C(126) OF oPrincipal
	 	@ C(001),C(001) TO C(126),C(165) PIXEL OF oQdt2

	Endif
EndIf

// Ponto de Entrada para desconto no Total
If lFrtDescTot
	aDescTot := ExecBlock("FRTDESCVEN")
	
	If Len(aDescTot) > 0
		lTela := aDescTot[1]
		
		If aDescTot[2] >= nVlrTotal
			MsgAlert(STR0068) //"Valor do desconto maior que valor total. Desconto não concedido."
		Else
			If aDescTot[2] > 0
				nVlrDescTot := aDescTot[2]
			EndIf
		EndIf
	EndIf 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica as regras de desconto sobre o total da venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCenVenda .OR. lFrtDescTot
	If Frt060Ret("060_VLRDESC") = 0
		LJMsgRun( STR0039 , , 																 ; //"Executando processos do cenário de vendas"
			{||	Frt271ERegDsc(	@nTmpJuros	, @nTmpDesc		, @aPgtosSint 	, @aPgtos		,;
								@nVlrTotal 	, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	,;
								@nEntrada	, @nTaxaMoeda	, @lRecebe		, @dDataCN 		,;
								@aItens		, @nVlrMerc		, @lDescTotal	, @lDescSE4		,;
								@nTotDedIcms, @nVlrPercTot	, @nMoedaCor	, @nDecimais	,;
								@aImpsSL1	, @aImpsSL2		, @aImpsProd	, @aDadosJur	,;
								@aFormCtrl	, @cItemCond	, @lCondNegF5	, @lDescEspec	,;
								@nTxJuros	, @nValorBase	, @lDiaFixo		, @lImpOrc 		,;
								@oCupom		, @cCliente		, @cLojaCli		, @oTimer   	,;
								@oHora		, @cHora		, @oDoc			, @cDoc	   		,;
								@oPDV		, @cPDV			, @nLastTotal	, @nLastItem	,;
								@nTotItens	, @oTotItens	, @oOnOffLine	, @nTmpQuant	,;
								@nVlrItem	, @nValIPIIT	, @nValIPI		, @oFotoProd	,;
								@oProduto	, @oQuant		, @oVlrUnit		, @oVlrItem 	,;
								@oDesconto	, @cSimbCor		, @cOrcam		, @cUnidade 	,;
								@nVlrUnit	, @oUnidade		, @lF7   		, @cCliente		,;
								@cLojaCli	, @cVendLoja	, @lOcioso		, @lLocked		,;
								@lCXAberto	, @lDescIT		, @aICMS		, @_aMult		,;
								@_aMultCanc	, @aParcOrc		, @cItemCOrc	, @aParcOrcOld	,;
								@lAltVend	, @lImpNewIT	, @lFechaCup	, @cContrato	,;
								@aCrdCliente, @aContratos	, @aRecCrd		, @aTEFPend		,;
								@aBckTEFMult, @cCodConv		, @cLojConv		, @cNumCartConv	,;
								@uCliTPL	, @uProdTPL		, @aVidaLinkD	, @aVidaLinkc 	,;
								@nVidaLink	, @nValTPis		, @nValTCof		, @nValTCsl		,;
								@lVerTEFPend, @nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	,;
								@nQtdeItOri	, @aMoeda		, @aSimbs		, @aImpVarDup	,;
								@aTotVen	, @aCols		, @nVlrPercIT	, @aHeader  	,;
								@nVlrDescIT	, @oMensagem	, @oFntMoeda	, @cTipoCli		,;
								@lBscPrdON	, @nConTcLnk	, @cEntrega  	, @aReserva		,;
								@lReserva	, @lAbreCup		, @nValor		, @oPgtosSint	,;
								@oPgtos		, @aBonus		, lTela   , lFrtDescTot   )})
	EndIf
EndIf

If nTotPremio > 0
	nVlrDescTot := nVlrDescTot + nTotPremio
	LjLogFront("nVlrDescTot",nVlrDescTot)
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os comandos abaixo foram colocados devido a um erro no ADVPL.          ³
	//³ "Preprocessor Table Overflow". Foi suprimido o Include do TCBROWSE.CH. ³
	//³ Os comandos originais devem ser mantidos para manutencao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTouch
	oPgtos:=TCBrowse():New(C(003), C(003), C(160),C(120) ,,,,oQdt1,,,,,{|nRow,nCol,nFlags|If(lAltParc,;
			(If((cItemCond=="CN" .AND. !lCondNegF5 .AND.;
			 Len(aParcOrc)==0),;
			 FR271HPar(	@nVlrTotal	, @oPgtos		, @aPgtos	, @nTaxaMoeda	,;
			 			@oPgtosSint	, @aPgtosSint	, @lRecebe	, @aMoeda		,;
			 			@aSimbs		, @nMoedaCor	, @nDecimais, @aCProva		,;
			 			@aFormCtrl  , @oPgtosAna),;
			 LojxDin(	aFormPagF5	, nVlrTotal		, Nil			, 0				,;
						0			, @oFimVenda	, .F.			, nVlrTotal		,;
						Nil			, Nil			, Nil			, Nil			,;
						Nil			, @oPgtos		, @aPgtos		, @oPgtosAna	,;
						@nTxJuros	, @aMoeda		, @nMoedaCor	, @lVendaRapida	,;
					   	@cSimbCheq	, @nValorBase	, @nTaxaMoeda)),;
			 oPgtos:Refresh()),)},,,,,,, .F.,, .T.,, .F., )
	AAdd(aPgtos, {dDatabase, nVlrTotal,"R$","", "", "", "", "", "", .F., 0 ,1, 0,""})
	aPgtosSint:= Fr271IMontPgt(@aPgtos	, @nMoedaCor)
	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(005),;
		C(034),;
		C(025),;
		"Cancela",;
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ || oFimVenda:End(),FrtMenuPrincipal(	@cCliente		, @cLojaCli	, @cVendLoja	, @lOcioso		,;
												@lRecebe		, @lLocked	, @lCXAberto	, @lDescIT		,;
												@nVlrDescTot	, @aMoeda	, @aSimbs		, @lDescITReg	)},;
		nil )
	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(033),;
		C(034),;
		C(025),;
		"Finaliza",;
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ || IIf(FR271GEncerra(	aFormPag  		, cItemForma 	, nTmpJuros    	, @lEncerra    		,;
								nTmpDesc		, @oFimVenda  	, @lTEFPendRec 	, @aRecTEFMult 		,;
								@cNCartao		, @oHora		, @cHora		, @oDoc				,;
								@cDoc			, @oCupom		, @cCupom		, @nVlrPercIT		,;
								@nLastTotal		, @nVlrTotal	, @nLastItem	, @nTotItens		,;
								@nVlrBruto		, @oDesconto	, @oTotItens	, @oVlrTotal		,;
								@oFotoProd		, @nMoedaCor	, @cSimbCor		, @oTemp3			,;
								@oTemp4			, @oTemp5		, @nTaxaMoeda	, @oTaxaMoeda		,;
								@nMoedaCor		, @cMoeda		, @oMoedaCor	, @cCodProd			,;
								@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade			,;
								@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant			,;
								@oUnidade		, @oVlrUnit		, @oVlrItem		, @lF7				,;
								@oPgtos			, @oPgtosSint	, @cOrcam		, @aPgtos			,;
								@cPDV			, @aPgtosSint	, @lTefPendCS 	, @aTefBKPCS		,;
								@nEntrada  		, @cCliente		, @cLojaCli		, @cVendLoja		,;
								@lOcioso		, @lRecebe		, @lLocked		, @lCXAberto		,;
								@aTefDados		, @nVlrFSD		, @lDescIT		, @nVlrDescTot		,;
								@nValIPI		, @aItens		, @nVlrMerc		, @aParcOrc			,;
								@lAltVend		, @lFechaCup	, @aTpAdmsTmp	, @cUsrSessionID	,;
								@cContrato		, @aCrdCliente	, @aContratos	, @aRecCrd			,;
								@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv			,;
								@cNumCartConv	, @uCliTPL		, @uProdTPL		, @aVidaLinkD		,;
								@aVidaLinkc 	, @nVidaLink	, @cCdPgtoOrc	, @cCdDescOrc		,;
								@nValTPis		, @nValTCof		, @nValTCsl		, @lOrigOrcam		,;
								@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot		,;
								@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri		,;
								@nQtdeItOri		, @nNumParcs	, @aMoeda		, @aSimbs			,;
								@cRecCart		, @cRecCPF		, @cRecCont		, @aImpsSL1			,;
								@aImpsSL2		, @aImpsProd	, @aImpVarDup	, @aTotVen			,;
							   	@nTotalAcrs 	, @aCols		, @aHeader		, @aDadosJur		,;
								@aCProva		, @aFormCtrl	, @nTroco		, @nTroco2			,;
								@lDescCond		, @nDesconto	, @aDadosCH		, @cItemCond		,;
								@lCondNegF5		, @aTefMult		, @aTitulo		, @lConfLJRec		,;
								@aTitImp		, @aParcelas	, @oPgtosAna	, @nTxJuros			,;
								@lVendaRapida	, @nValorBase	, @oMensagem	, @oFntGet			,;
								NIL				, NIL			, @cTipoCli		, @cEntrega			,;
								@aReserva		, @lReserva		, @lAbreCup		, @nValor		    ,;
								@oTimer   		, @lResume		, @aValePre		, @aRegTEF			,;
								@lRecarEfet		, @lCancItRec	, @cNumDAV		, @cCliCGC			,;
								@cMensagem		,				,				,						,;
								@nArredondar	, @lSelTefManu, nDescItens		, @nDescToP),;
								oFimVenda:End(),.T.) }, NIL )
	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(061),;
		C(034),;
		C(025),;
		"Zera" + Chr(10) + "Pagtos",;
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ || nValor := nVlrTotal,aPgtosSint:={},aFormCtrl:= {},oPgtosSint:Refresh(),aPgtos:={},oPgtos:SetArray( aPgtos ),oPgtos:Refresh()},;
		nil )
	TAdvButton():New(;
		oQdt4,;
		C(005),;
		C(088),;
		C(034),;
		C(025),;
		"Desconto" + Chr(10) + "Cupom",;
		TAdvColor():NewValue( CLR_MSFACE ),;
		TAdvFont():New( "Arial", 6, 19, TAdvColor():NewValue( CLR_BLACK ), .F., .F., .F. ),;
		1,;
		TAdvColor():NewValue( CLR_BLACK ),;
		{ || FR271FDescTot(	@nTmpJuros		, @nTmpDesc		, Nil			, @oPgtosSint	,;
							@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		,;
							@nVlrTotal 		, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	,;
							@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		,;
							@aItens			, @nVlrMerc		, @lDescTotal	, @lDescSE4		,;
							@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	,;
							@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	,;
							@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	,;
							@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc 		,;
							@lRecalImp		, @aCols		, @aHeader		, cOrcam	 ) },;
		nil )

	@ c(010),  c(03) TO c(035), c(160) LABEL STR0031 Of oQdt2 PIXEL	// TOTAL
	@ c(050),  c(03) TO c(075), c(160) LABEL STR0032 Of oQdt2 PIXEL	// VALOR RECEBIDO
	@ c(090),  c(03) TO c(115), c(160) LABEL STR0034 Of oQdt2 PIXEL	// A Receber
	@ c(020),  c(15) SAY oSay PROMPT nVlrTotal  PICTURE "@E 9,999,999.99" PIXEL OF oQdt2 SIZE 120,14 COLOR CLR_HBLUE FONT oFonte Right // VALOR TOTAL DA VENDA
	@ c(060),  c(15) SAY oSay PROMPT {||FR271ITotPag(aPgtos)}  PICTURE "@E 9,999,999.99" PIXEL OF oQdt2 SIZE 120,14 COLOR CLR_HBLUE FONT oFonte Right // VALOR PAGO
	@ c(100),  c(15) SAY oSay PROMPT {||nVlrTotal - FR271ITotPag(aPgtos)}  PICTURE "@E 9,999,999.99" PIXEL OF oQdt2 SIZE 120,14 COLOR CLR_HBLUE FONT oFonte Right // VALOR PAGO

	aBotoes := 	FR271BBSLD()
	FRT273ABot( aBotoes		, .F.			, oQdt3		, .T.			,;
				Nil			, @cCliente		, @cLojaCli	, @cVendLoja	,;
				@lOcioso	, @lRecebe		, @lLocked	, @lCXAberto	,;
				@lDescIT	, @nVlrDescTot	, @aMoeda	, @aSimbs 		,;
				@lDescITReg	)

Else
 	DEFINE MSDIALOG oFimVenda FROM 160,0 TO 305,320 PIXEL OF GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP) COLOR CLR_WHITE,CLR_GRAY

  	oPgtos:=TCBrowse():New(3, 3, 157, 82,,,,,,,,,{|nRow,nCol,nFlags|If(lAltParc,;
			(If((cItemCond=="CN" .AND. !lCondNegF5 .AND.;
			 Len(aParcOrc)==0),;
			 FR271HPar(	@nVlrTotal	, @oPgtos		, @aPgtos	, @nTaxaMoeda	,;
			 			@oPgtosSint	, @aPgtosSint	, @lRecebe	, @aMoeda		,;
			 			@aSimbs		, @nMoedaCor	, @nDecimais, @aCProva		,;
			 			@aFormCtrl  , @oPgtosAna),;
			 LojxDin(	aFormPagF5	, nVlrTotal		, Nil			, 0				,;
						0			, @oFimVenda	, .F.			, nVlrTotal		,;
						Nil			, Nil			, Nil			, Nil			,;
						Nil			, @oPgtos		, @aPgtos		, @oPgtosAna	,;
						@nTxJuros	, @aMoeda		, @nMoedaCor	, @lVendaRapida	,;
					   	@cSimbCheq	, @nValorBase	, @nTaxaMoeda	, NIL			,;
					   	NIL			, NIL			, oDlgFrt		, aTefBkpCS		)),;
			 oPgtos:Refresh()),)},,,,,,, .F.,, .T.,, .F., )


Endif

	oPgtos:SetArray( aPgtos )
	oPgtos:AddColumn(TCColumn():New(STR0011, {|| If(Len(aPgtos)>=oPgtos:nAt,aPgtos[oPgtos:nAt,1],'')},,,, "LEFT", 35, .F., .F.,,,, .F., ) )  //"Data"
	oPgtos:AddColumn(TCColumn():New(STR0012, {|| If(Len(aPgtos)>=oPgtos:nAt,Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",15)),'')},,,, "RIGHT", 60, .F., .F.,,,, .F., ) )  	//"Valor"
	oPgtos:AddColumn(TCColumn():New(STR0036, {|| If(Len(aPgtos)>=oPgtos:nAt,aPgtos[oPgtos:nAt,3]+IIf(ValType(aPgtos[oPgtos:nAt,4])=="C",Substr(aPgtos[oPgtos:nAt,4],4),''),'')},,,, "LEFT", 60, .F., .F.,,,, .F., ) )  				//"Forma de Pagamento"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibir o valor do acrescimo separado da parcela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
		//"Acrs.Fin"
		oPgtos:AddColumn(TCColumn():New(STR0035,{|| If(Len(aPgtos)>=oPgtos:nAt,Transform(aPgtos[oPgtos:nAt,13],PesqPict("SL1","L1_VLRTOT",15)),'')},,,, "RIGHT", 60, .F., .F.,,,, .F., ) )  //"Acrescimo"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao da 12 posicao para a digitacao dos digitos do cartao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaTef .AND. lTefMult .AND. Len(aPgtos) > 0
	   oPgtos:AddColumn(TCColumn():New(STR0021, {|| aPgtos[oPgtos:nAt,12] },,,, "LEFT", 60, .F., .F.,,,, .F., ) ) //"Dígitos Cartão"
	EndIf
	If cPaisLoc <> "BRA" .AND. Len(aPgtos) > 0
		oPgtos:AddColumn(TCColumn():New(STR0033, {|| Transform(aPgtos[oPgtos:nAt,11],PesqPict("SL1","L1_MOEDA",02))},,,, "LEFT", 35, .F., .F.,,,, .F., ) )  //"Moeda"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Evita erro ao pressionar a tecla <Enter> e o array aPgtos estiver com conteúdo nulo...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aPgtos)
		If Empty(aPgtos)
			oPgtos:Disable()
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utiliza o novo tipo de visualização de parcelas sintetizado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVisuSint

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se ao carregar o orcamento estiver utilizando a forma de visualizacao sintetizada   ³
		//³atualiza com o array aPgtos que ja foi atualizado ao carregar o orcamento c/ F12-21 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lRemontaPgtos .OR. Len(aParcOrc) > 0) .AND. Len(aPgtos) > 0 .AND. Len(aPgtosSint) == 0
			aPgtosSint:= Fr271IMontPgt(@aPgtos	, @nMoedaCor)
		Endif

		If lTouch
			oPgtosSint:= TCBrowse():New(C(003), C(003), C(160),C(120) ,,,,oQdt1,,,,,bPgtosDblClick,,,,,,, .F.,, .T.,, .F., )
		Else
			oPgtosSint:= TCBrowse():New(3, 3, 157, 82,,,,,,,,,bPgtosDblClick,,,,,,, .F.,, .T.,, .F., )
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura do array aPgtosSint                                ³
		//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
		//³ [1] - Forma de Pagamento                                     ³
		//³ [2] - Qtde de Parcelas da forma de pagto                     ³
		//³ [3] - Valor total desta forma de pagamento                   ³
		//| [4] - Sequencia para controle de múltiplas transaçõies		 |
		//³ [5] - Data da primeira parcela                               ³
		//³ [6] - Codigo da Administradora financeira                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPgtosSint:SetArray(aPgtosSint)

		oPgtosSint:AddColumn(TCColumn():New(STR0011, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,5],'')} ,,,, "LEFT" , 25, .F., .F.,,,, .F., ) )  //"Data"
		oPgtosSint:AddColumn(TCColumn():New(STR0022, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,1],'')} ,,,, "LEFT" , 20, .F., .F.,,,, .F., ) )  //"Forma"
		oPgtosSint:AddColumn(TCColumn():New(STR0012, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,3],'')} ,,,, "RIGHT", 50, .F., .F.,,,, .F., ) )  //"Valor"
		oPgtosSint:AddColumn(TCColumn():New(STR0023, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,2],'')} ,,,, "RIGHT", If(lUsaTef .AND. lTefMult,25,55) , .F., .F.,,,, .F., ) )  //"Parcelas"
		//Só inserir a coluna ID Cartão quando o cliente trabalhar com múltiplas transações TEF
		If lUsaTef .AND. lTefMult
			oPgtosSint:AddColumn(TCColumn():New(STR0024, {|| If(Len(aPgtosSint)>=oPgtosSint:nAt,aPgtosSint[oPgtosSint:nAt,4],'')},,,,  "RIGHT", 30, .F., .F.,,,, .F., ) ) //"ID Cartão"
		EndIf

		//Durante a homologação o sistema não deve permitir entrar na tela de detalhe da forma de pagamento devido a exibição do parcelamento
		If !lHomol .AND. ! lTouch
			oPgtosSint:bLDblClick := {|| Fr272AAltPgSi(	@oPgtosSint:nAt	, @lAltParc		, @aFormPagF5	, @oFimVenda	,;
														@aParcOrc		, @nVlrTotal	, @oPgtos		, @aPgtos		,;
														@oPgtosAna		, @oDlgFrt		, @aPgtosSint	, @oPgtosSint	,;
														@nTaxaMoeda		, @lRecebe		, @aMoeda		, @aSimbs		,;
														@aFormCtrl		, @cSimbCheq	, @cItemCond	, @nTxJuros		,;
														@nMoedaCor		, @lVendaRapida	, @lCondNegF5	, @nValorBase   ,;
														@cCliente       , @cLojaCli     , @aTefBKPCS	, @aTxJurAdm	,;
														@oVlrTotal		) }
		EndIf


		// Evita erro ao pressionar a tecla <Enter> e o array aPgtos estiver com conteúdo nulo...
		If Empty(aPgtosSint)
			oPgtosSint:Disable()
		Else
			oPgtosSint:SetFocus()
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Feita a insercao de um objeto habilitado para permitir os Ctrl's³
	//³no final da venda. Solucao temporaria para P10 deve ser         ³
	//³tratada a causa pela Tecnologia.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE SBUTTON FROM 1000, 1000 oButtonz TYPE 1 ENABLE OF oFimVenda

	If lTouch
		ACTIVATE MSDIALOG oFimVenda CENTERED VALID FR271EVldFimV(	lAltParc		, lEncerra		, @nVlrDescTot	, @oHora		,;
															   		@cHora			, @oDoc			, @cDoc			, @cCodProd		,;
															   		@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
															  		@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
															 		@oUnidade		, @oVlrUnit		, @oVlrItem		, @oDesconto	,;
															 		@lF7			, @aPgtos		, @lTefPendCS	, @aTefBKPCS	,;
															 		@oPgtosSint		, @aPgtosSint	, @oPgtos		, @oCupom		,;
															 		@nVlrTotal		, @oVlrTotal	, @cCliente		, @cLojaCli		,;
																	@lOcioso		, @lRecebe		, @dDataCN		, @nLastItem	,;
																	@nLastTotal		, @nVlrBruto	, @aItens		, @nVlrMerc		,;
																	@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv		,;
																	@cNumCartConv	, @uCliTPL		, @uProdTPL		, @lDescTotal	,;
																	@lDescSE4		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
																	@nVlrPercTot	, @nMoedaCor	, @nDecimais	, @aImpsSL1		,;
																	@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	,;
																	@nTxJuros		, @nValorBase	, @lDiaFixo		, @nTotItens	,;
																	@oTotItens		, @oFotoProd	, @lRecalImp	, @aCols		,;
																	@aHeader		, @aDadosJur	, cOrcam		, @aRegTEF		,;
																	@lRecarEfet		, @lCancItRec	, NIL	 		, aParcOrcOld 	,;
																	lConfLJRec		)
	Else
		ACTIVATE MSDIALOG oFimVenda VALID FR271EVldFimV(	lAltParc		, lEncerra		, @nVlrDescTot	, @oHora		,;
													   		@cHora			, @oDoc			, @cDoc			, @cCodProd		,;
													   		@cProduto		, @nTmpQuant	, @nQuant		, @cUnidade		,;
													  		@nVlrUnit		, @nVlrItem		, @oProduto		, @oQuant		,;
													 		@oUnidade		, @oVlrUnit		, @oVlrItem		, @oDesconto	,;
													 		@lF7			, @aPgtos		, @lTefPendCS	, @aTefBKPCS	,;
													 		@oPgtosSint		, @aPgtosSint	, @oPgtos		, @oCupom		,;
													 		@nVlrTotal		, @oVlrTotal	, @cCliente		, @cLojaCli		,;
															@lOcioso		, @lRecebe		, @dDataCN		, @nLastItem	,;
															@nLastTotal		, @nVlrBruto	, @aItens		, @nVlrMerc		,;
															@aTEFPend		, @aBckTEFMult	, @cCodConv		, @cLojConv		,;
															@cNumCartConv	, @uCliTPL		, @uProdTPL		, @lDescTotal	,;
															@lDescSE4		, @lVerTEFPend	, @nTotDedIcms	, @lImpOrc		,;
															@nVlrPercTot	, @nMoedaCor	, @nDecimais	, @aImpsSL1		,;
															@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	,;
															@nTxJuros		, @nValorBase	, @lDiaFixo		, @nTotItens	,;
															@oTotItens		, @oFotoProd	, @lRecalImp	, @aCols		,;
															@aHeader		, @aDadosJur	, cOrcam		, @aRegTEF		,;
															@lRecarEfet		, @lCancItRec	, @aParcOrc     , @nVlrAcreTot  ,;
															@nVlrPercAcr    , @nVlrDescCPg  , NIL			, aParcOrcOld 	,;
															lConfLJRec		)
	EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o acerto dos arquivos, caso o usuario nao confirme o ³
//³encerramento da venda...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lEncerra .AND. (cPaisLoc <> "BRA")
	If lRecalImp
		aCols    := {}
		aImpsSL1 := {}
		For nI := 1 to Len(aImpsProd)
			If !aImpsProd[nI][5]
		 		aProdSL2 := {}
				For nX := 1 To Len(aImpsProd[nI][03])
			    	If (nE := Ascan(aImpsSL1,{|x| x[1] == aImpsProd[nI][3][nX][1]})) == 0

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valorizo o array aImpsSL1 com base no array aImpsProd que³
						//³possui os dados originais da venda...                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			        	AAdd(aImpsSL1,{aImpsProd[nI][3][nX][1],aImpsProd[nI][3][nX][8],0,;
			        	               aImpsProd[nI][3][nX][9],0,SubStr(aImpsProd[nI][3][nX][5],2,1),;
			        	               aImpsProd[nI][3][nX][4]})
			     		nE := Len(aImpsSL1)
			       	EndIf
				   	aImpsSL1[ nE,3 ] += aImpsProd[nI][3][nX][4]	//Valor do imposto no cabecalho
				   	aImpsSL1[ nE,5 ] += aImpsProd[nI][3][nX][3]	//Base do imposto no cabecalho
			       	nValImp  := aImpsProd[nI][3][nX][4]
				   	aImposto := aClone(aImpsProd[nI][03][nX])
					nTotImp  += (nValImp * aImposto[10][Val(Subs(aImposto[5],2,1))])
		    	Next nX
		    	aImpsSL2[nI] := aClone(aImpsProd[nI])

				aProdSL2 := {{"L2_VRUNIT" , aImpsProd[nI][7]},;
				             {"L2_VLRITEM", aImpsProd[nI][6]*aImpsProd[nI][7]},;
				             {"L2_DESCPRO", 0},;
				             {"L2_ITEM"   , aImpsProd[nI][4]}}

		  		For nK := 1 to Len(aImpsSL2[nI][3])
		       		Aadd(aProdSL2,{aImpsSL2[nI][3][nK][6],aImpsSL2[nI][3][nK][4]})   //Valor do imposto
		       		Aadd(aProdSL2,{aImpsSL2[nI][3][nK][7],aImpsSL2[nI][3][nK][3]})   //Base do imposto
		       		Aadd(aProdSL2,{"L2_ALQIMP"+Substr(aImpsSL2[nI][3][nK][7],10,1),aImpsSL2[nI][3][nK][2]})   //Aliquota do imposto
		   		Next nK
				AAdd(aSL2,aClone(aProdSL2))
		   		FR271ISimACols(aImpsProd[nI][1]	, aImpsProd[nI][6]	, aImpsProd[nI][7]	, aImpsProd[nI][2]	,;
		   					""					, aImpsProd[nI][4]			, Nil						, @aCols			,;
							@aHeader			)
		   	Else
		   		FR271ISimACols(aImpsProd[nI][1]	, aImpsProd[nI][6]	, aImpsProd[nI][7]	, aImpsProd[nI][2]	,;
		   					""					, aImpsProd[nI][4]			, .T.						, @aCols			,;
							@aHeader			)
		   	EndIf
	    Next nI

		//Funcao para atulizar o arquivo SL2 -  Localizacoes
	    If Len(aSL2)  >  0
	    	FR271HSL2GRV(aSL2,	cOrcam)
	    EndIf

		//Retorna os totais originais...
		nVlrTotal 	:= nVlrTotBkp
		nVlrBruto 	:= nVlrBrutoBkp
		nVlrMerc  	:= nVlrMercBkp
		lRecalImp := .F.

		//Zera o array aDadosJur
		AEval(aDadosJur,{|x,y| aDadosJur[y]:=0 })
	EndIf
	aCProva := {}
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento realizado para TEF pendente, utilizando a CLISITEF.³
	//³Caso o usuario abandone a tela de forma de pagamento e exista ³
	//³uma transacao TEF Pendente, mando uma nao confirmacao.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTefPendCS
		lTefPendCS := .F.
		aTefBKPCS  := {}
		oTEF:FinalTrn(0)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Cartao Fidelidade³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjcFid .AND. Fa271aGpfw ()
		If Fa271aGrcf()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclusao do saldo do cartao fidelidade - Recarga ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			aArea := GetArea()
			//Obter dados da SL2
			DbSelectArea("SL2")
			DbSetOrder(1)
			DbSeek(xFilial("SL2") + SL1->L1_NUM)

			While !SL2->(EOF()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM .AND. LaFunhProd (SL2->L2_PRODUTO)

				If !Empty(SL2->L2_NUMCFID) .AND. !Empty(SL2->L2_DTSDFID) .AND. (SL2->L2_VLRCFID > 0)
					Ca280Exec("CA280ISLD",	SL2->L2_NUMCFID,SL2->L2_DTSDFID,SL2->L2_VLRCFID,;
							SL1->L1_DOC,	SL1->L1_SERIE,	SL1->L1_LOJA)
					RestArea(aArea)
					Exit
				EndIf
				SL2->(DbSkip())
			End
			RestArea(aArea)

		ElseIf !Empty(Fa271FgFid())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizacao do saldo do cartao fidelidade - Venda³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aArea := GetArea()
			DbSelectArea("SL4")
			DbSetOrder(1)
			If DbSeek( xFilial( "SL4" ) + SL1->L1_NUM )
				While !SL4->(Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial( "SL4" ) + SL1->L1_NUM
					If AllTrim(SL4->L4_FORMA) == "FID"
						Ca280Exec("Ca280ASld",SL4->L4_NUMCFID,,,SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_LOJA,,	SL4->L4_VALOR)
						RestArea(aArea)
						Exit
					EndIf

					SL4->(DbSkip())
				End
			EndIf
			RestArea(aArea)
		EndIf
	EndIf

EndIf

// Condição inserida pois com lAnalLeg14 == .T., se houver desconto e se utilizada a tecla ESC
// o desconto não pode ser removido do cupom então as variáveis não devem ser atualizadas porém
// quando a venda é finalizada passa por aqui novamente e as variáveis devem ser zeradas

LjLogFront("55-nVlrTotal",nVlrTotal)
LjLogFront("55-nVlrBruto",nVlrBruto)
LjLogFront("55-nVlrDescTot",nVlrDescTot)


If !lEncerra
    // Incluido esse trecho nesse momento, pois se ele atualizar o valor bruto aqui nao precisa voltar
    // o valor do frete , pois ja tera o mesmo incluido pela funcao de ncc
    If !lConfLJRec .AND. Frt060Ret("NCC_USADA") > 0
    	nVlrBruto := Frt060end(@oVlrTotal, @nVlrTotal) //Zera valor de NCC para permitir selecionar novamente
    EndIf
EndIf


If lAnalLeg14 .AND. lDescTotal .AND. nVlrBruto > 0
	nVlrBruto	-=	nVlrDescTot
	nVlrTotal 	:= nVlrBruto
	LjLogFront("VAL BRUT",nVlrBruto)
Else
	//Volta as variaveis
	nVlrTotal		:=	nVlrBruto
	nValor			:=	nVlrBruto  
	//Volta o valor do IPI
	nValIPI			:=  0  
	
	lLimpaDesImp	:=	lImpOrc .And. nVlrDescTot > 0 .And. nVlrPercTot == 0 // Utilizada para limpar o valor de desconto informado no front para orçamentos importados.

	If Len(aParcOrcOld) == 0 .Or. lLimpaDesImp //Quando nao foi forma definida no orcamento, deve atualizar valores e desconsiderar o desconto

		If lLimpaDesImp .Or. nVlrBruto > 0 .AND. nVlrDescTot > 0 .AND. !lImpOrc   // Checa se considera ou não o desconto

			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))
			oCupom:AppendText((STR0047)+ chr(10) + chr(13))	// "Desconto no total do cupom : CANCELADO"
			oCupom:AppendText((FRT_SEPARATOR)+ chr(10) + chr(13))

			nVlrDescTot	:= 0
			lDescTotal	:= .F.
			LjLogFront("ZERA O DESCONTO NO TOTAL")

			If lLimpaDesImp
				aParcOrc := aParcOrcOld
				aParcOrcOld := {}
			EndIf

		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se foi alterado a forma de pagamento de um orcamento importado da Venda Balcao, ³
		//³ ao abandonar a finalizacao da venda, recupera os valores.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParcOrc := aParcOrcOld
		aParcOrcOld := {}
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Reinicializa as variaveis estaticas p/ rotina de recebimento de NCC	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRecebe .And. Frt060Ret("NCC_USADA") == 0
	Frt060end(@oVlrTotal, @nVlrTotal)
EndIf
LjLogFront("66-VALOR TOTAL",nVlrTotal)

//Armazena na variavel "aNccRecSel" as NCCs do cliente apresentadas na tela para selecao que poderao ser utilizadas como pagamento
//no recebimento de titulos, pois essas informacoes serao usadas mais adiante na funcao _LJGrvRec (fonte LOJXREC.PRW)
aNccRecSel := Frt060Ret("NCC_ITENS")

If !lTouch
	oVlrTotal:Refresh()
Endif

If lCenVenda .AND. Len(aBonus) > 0
	LjTelaBon(aBonus)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
//³ Reinicializa a variavel de controle de recarga de pre pago|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
If lEncerra
	lRecarEfet	:= .F.
	lCancItRec  := .F.
Endif



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÄ¿
//³ Release 11.5 - Cartao Fidelidade 			  |
//³ Reinicializa variaveis de cartao fidelidade	  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ----ÄÙ
If lLjcFid .AND. Fa271aGrcf ()
	LaFunhDelS ()
	Fa271aSrcf (.F.)
	Fa271aSpfw (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Zerar RECNO da especie de documento    ³
//³fiscal escolhida no inicio da venda.   ³
//³Paises:Chile/Colombia  - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCFolLocR5
	FaZerRecFo()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)
If lUsaDisplay
	DisplayEnv(StatDisplay(), "1E"+ STR0017)	// // "Codigo do Produto: "
	DisplayEnv(StatDisplay(), "*")	// Habilita echo do teclado para msg e telas das form.pgto
End
aPgtosSint := {}

If (len(aPgtos) > 0) .AND. (len(aPremio) > 0) .AND. lUsafd

	oSWB := WSFRTCRDBX():New()
	oSWB :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/FRTCRDBX.apw"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o array dentro do metodo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSWB:oWSACRDVALEC:oWSVERARRBX 						:= FRTCRDBX_ARRAYOFWSCRDVABX():New()
	oSWB:oWSACRDVALEC:OWSVerArrBX:oWSWSCRDVABX 			:= Array( Len(aPremio) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Antes de chamar o metodo, atribui os valores ³
	//³as propriedades (passagem de parametros)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aPremio)

		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX] := FRTCRDBX_WSCRDVABX():New()

		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:NCRDPRE1			:=	aPremio[nX][1]
		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:cCRDPRE2			:=	aPremio[nX][2]
		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:cCRDPRE3			:=	aPremio[nX][3]
		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:cCRDPRE4			:=	aPremio[nX][4]
		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:nCRDPRE5			:=	aPremio[nX][5]
		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:nCRDPRE6			:=	aPremio[nX][6]
		oSWB:oWSACRDVALEC:OWSVerArrBX:OWSWSCRDVABX[nX]:nCRDPRE7			:=	aPremio[nX][7]
		nPontos += aPremio[nX][1]
	Next nX

	If len(aLibera) > 0
		cMotivo := aLibera[nX][3]
	EndIf

	oSWB:FRTCRD02( , cCliente, cLojaCli , nPontos, cDoc, "", cMotivo)

EndIf

If ( nImpSegVia > 0 ) .AND. ( cPaisLoc <> "BRA" )
	LjMsgRun( STR0041,, {|| Frt271EImpV2(nImpSegVia, cCupom)})    // "Aguarde... Gerando copia do comprovante"
EndIf

Return(aPgtos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271EVldF³ Autor ³                       ³ Data ³06/06/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                     					        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA010()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Progr.   ³ Data     BOPS   Descricao								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Adrianne  ³06/12/05³002694³- Incluidos parametros para informar se hou-³±±
±±³          ³        ³      ³ve desconto no total e se a venda está sendo³±±
±±³          ³        ³      ³finalizada. Dessa forma a tela de finaliza- ³±±
±±³          ³        ³      ³do Front, fara o zeramento do desconto.     ³±±
±±³          ³        ³      ³Esse processo será disparado caso	o operador³±±
±±³          ³        ³      ³tecle ESC.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271EVldFimV(	lAltParc	, lEncerra		, nVlrDescTot	, oHora			,;
						cHora		, oDoc			, cDoc			, cCodProd		,;
						cProduto	, nTmpQuant		, nQuant		, cUnidade		,;
						nVlrUnit	, nVlrItem		, oProduto		, oQuant		,;
						oUnidade	, oVlrUnit		, oVlrItem		, oDesconto		,;
						lF7			, aPgtos		, lTefPendCS	, aTefBKPCS		,;
						oPgtosSint	, aPgtosSint 	, oPgtos		, oCupom		,;
						nVlrTotal	, oVlrTotal		, cCliente		, cLojaCli		,;
						lOcioso		, lRecebe		, dDataCN		, nLastItem		,;
						nLastTotal	, nVlrBruto		, aItens		, nVlrMerc		,;
						aTEFPend	, aBckTEFMult	, cCodConv		, cLojConv		,;
						cNumCartConv, uCliTPL		, uProdTPL		, lDescTotal	,;
						lDescSE4	, lVerTEFPend 	, nTotDedIcms	, lImpOrc		,;
						nVlrPercTot	, nMoedaCor		, nDecimais		, aImpsSL1		,;
						aFormCtrl	, cItemCond		, lCondNegF5	, lDescEspec	,;
						nTxJuros	, nValorBase	, lDiaFixo 		, nTotItens		,;
						oTotItens	, oFotoProd		, lRecalImp		, aCols			,;
						aHeader		, aDadosJur		, cOrcam		, aRegTEF		,;
						lRecarEfet	, lCancItRec    , aParcOrc      , nVlrAcreTot   ,;
						nVlrPercAcr , nVlrDescCPg   , lVoid			, aParcOrcOld	,;
						lConfLJRec	)

Local 	lRet
Local 	lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local   lAnalLeg14	:= LjAnalisaLeg( 14 )[1]											// Verifica se desconto é concomitante
Local 	nTamSXG		:= 0
Local 	cFotoProd	:= "LOJAWIN"														// Foto do produto
Local   lVisuSint  	:= If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 						//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
DEFAULT aDadosJur	:= {}																// Dados Juros
DEFAULT	lF7		:= .F.

DEFAULT	aRegTEF		:= {}
DEFAULT	lRecarEfet	:= .F.
DEFAULT	lCancItRec 	:= .F.
DEFAULT	aParcOrc	:= {}
DEFAULT	nVlrAcreTot := 0
DEFAULT	nVlrPercAcr := 0
DEFAULT	nVlrDescCPg := 0
DEFAULT aParcOrcOld := {}
DEFAULT lConfLJRec	:= .T.

LjLogFront("PRESSINOU ESC")

//Se pressionar o botão ESC zera as variavéis de desconto, para nao haver problema nos calculos do novo desconto
nVlrTotal		:= nVlrTotal + nVlrDescTot
nVlrDescTot	:= 0
nVlrPercTot	:= 0
lDescTotal		:= .F.

//Nao permite que retorne para a tela de itens quando existir recarga de celular na venda.
//So permiti se a transacao for cancelada.
lCancItRec := FrtRetStc()
If FrtRecVend(aRegTEF) .AND. !lCancItRec
	MsgAlert(STR0038) //"Não é possível retornar para tela de venda de itens porque existe uma recarga de celular pendente. Por favor, finalizar a venda."
	Return .F.
EndIf

If lTefPendCS .AND. Len(aTefBKPCS) > 0 .AND. SuperGetMV("MV_TEFPEND",,"0") <> "1"
	MsgAlert(STR0040) //"Não é possível retornar para tela de venda de itens porque existe um cartão pendente. Por favor, finalizar a venda."
	Return .F.
EndIf

//Valida Resgate Dotz Pendente com venda aberta
If nVlrTotal > 0 .AND. Len(aPgtos) > 0 .AND. aScan(aPgtos, {|x| x[3] == "DT" }) > 0
	MsgAlert(STR0069) //"Não é possível retornar para tela de venda de itens porque existe um Resgate Dotz pendente. Por favor, finalizar ou Cancelar a venda."
	Return .F.
EndIf

If lRecebe
	// "Confirma o cancelamento do(s) recebimento(s) em andamento?", "Atenção"
	If MsgYesNo( STR0025 , STR0001)
		nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
		cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
		nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
		cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)

		//Apagar arquivos de controle de semaforo de recebimento de titutlos
		If FindFunction("LjRecUnChk") //LOJXREC
			LjRecUnChk()
		EndIf

		lRecebe := .F.
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
		lImpOrc   := .F.
		oDesconto:Refresh()
		oTotItens:Refresh()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Reinicializa as variaveis estaticas p/ rotina de recebimento de NCC	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Frt060end(oVlrTotal,nVlrTotal)

		If !lTouch
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
		FR271AInitIT(	.T.,		@lF7,		@cCodProd, 	@cProduto,;
						@nTmpQuant,	@nQuant,	@cUnidade,	@nVlrUnit,;
						@nVlrItem,	@oProduto,	@oQuant,	@oUnidade,;
						@oVlrUnit,	@oVlrItem,	@oDesconto, @cCliente,;
						@cLojaCli)

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
		lRet := .T.
	Else
		lRet := .F.
	EndIf
Else

    If lDescSE4 .AND. nVlrMerc <> nVlrBruto ;
    		.OR. ( !lEncerra .AND. nVlrDescTot > 0 )	// mesma regra da retirada do desconto abaixo

		//se a tecla ESC foi utilizada, porem na venda houve desconto no item, nao podemos restaurar o valor de mercadoria,
		//pois esse valor nao considera os descontos aplicados nos itens
		If nVlrPercTot > 0
			nVlrPercTot := 0	//zeramos o percentual de desconto aplicado no total da venda
		EndIf
		LjLogFront("PARA ZERAR ACRES",nVlrBruto)
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao especifica para atender a legislacao do SEFAZ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If LjAnalisaLeg(4)[1]
		If lOcioso
			lRet := .T.
		Else
			If nVlrDescTot > 0 .OR. Len(aPgtos) > 0
				lRet := .F.
			Else
				lRet := lAltParc
			EndIf
		EndIf
	Else
		lRet := lAltParc

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄL¿
		//³Caso a impressão do desconto seja concomitante, não será zerado.³
		//³Por isso a chamada da LJAnalisaLeg(14)                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄLÙ
		If (!lEncerra) .AND. (!lAnalLeg14)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso o operador volte para a tela de lançamento de itens (tecle ESC), ³
			//³o desconto na condicao será zerado. 									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lDescSE4

				nVlrDescCPg := 0

			Else // se o orçamento importado não tiver desconto , limpa as variaveis e condições da importação
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

					nVlrAcreTot := SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA	// Deixa somentes as despesas


					If !lTouch
						oVlrTotal :Refresh()
					Endif

				EndIf
			EndIf

		ElseIf (!lEncerra) .AND. (nVlrDescTot > 0) .AND. (lAnalLeg14) .And. SL1->L1_SITUA <> "07"
			//==========================================================================
			// Caso tecla ESC acionada quando utilizado desconto e venda concomitante  |
			// será emitida mensagem informando que o sistema não permite mais nenhuma |
			// inclusão ou desconto pois quando dado o desconto o fechamento do cupom  |
			// é iniciado.                                                             |
			//==========================================================================
			MsgAlert( STR0044 + CHR(13) + ; //"A operação não pode ser cancelada pois "
					  STR0045 + CHR(13) + ; //"o processo de fechamento do cupom já foi "
					  STR0046 , STR0001 ) 	//"iniciado pelo ECF, devido ao lançamento do desconto.", "Atencao"

			lRet := .F.
		EndIf


	EndIf
EndIf


Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271EAltC³ Autor ³ Cesar Eduardo Valadao ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao do Cliente	(F10)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numeracao do cartao fidelidade 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Thiago    ³20/01/06³- Feita passagem do parametro aVarTemplate		  ³±±
±±³          ³        ³  na funcao CRDIDENTCLI                  		  ³±±
±±³Andrea F. ³22/02/06³- BOPS 94117 Passagem do ultimo parametro da       ³±±
±±³          ³        ³funcao CRDIDENTCLI para identificar se foi feita   ³±±
±±³          ³        ³conexao com o WS .                                 ³±±
±±³A.Veiga   ³09/03/06³- Drogaria Moderna - Alteracao da chamada do clien-³±±
±±³          ³        ³te. Faz sempre a pesquisa na retaguarda pq pode ser³±±
±±³          ³        ³que o cliente tenha acabado de se cadastrar e ainda³±±
±±³          ³        ³nao tenha sido feita a carga.                      ³±±
±±³          ³        ³                                                   ³±±
±±³Thiago H. |09/08/06|BOPS 102866 - Tratamento para vendas interestaduais³±±
±±³          ³102866  ³vendas dentro de Sao Paulo so' podem ser      	  ³±±
±±³          ³        ³realizadas para cliente cujo campo A1_EST="SP"	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271EAltCli( cNCartao	, cCliente		, cLojaCli		, lOcioso	,;
					lRecebe		, lCXAberto		, aCrdCliente 	, cCodConv	,;
					cLojConv	, cNumCartConv	, uCliTPL		, uProdTPL	,;
					aItens		, cCodDep		, cNomeDEP		, cTipoCli	,;
					lBscCliON	, nConTcLnk		, cCliCGC		, cMensagem ,;
					cGrpTrib )

Local cCliFrt 		:= cCliente
Local cLojFrt 		:= cLojaCli
Local cTribFrt 		:= cGrpTrib
Local cNomeCli 		:= Subst(Posicione("SA1",1,xFilial("SA1")+cCliente+cLojaCli,"A1_NOME"),1,30)
Local aRetCart      := {}                       // Contem o tipo e numero do documento do cliente da venda
Local lCliente 		:= .T.                      // Indica se o cliente foi encontrado na base
Local aCliente      := {}                       // Dados do cliente, utilizado para comparacao com a base local do PDV
Local nPosCli		:= 0	                    // Posicao do campo A1_COD no array a clientes
Local nPosLoja		:= 0	                    // Posicao do campo A1_LOJA no array a clientes
Local lNovoCliente 	:= .T.	                    // Variavel que indica se cria ou nao um novo registro no SA1
Local nX			:= 0 						// Variavel para controle de looping
Local aRegsSA1		:= {}						// Utilizada no WSCrdConscli para trazer o cliente para o PDV
Local aDadosCli     := {}						// Contem numero do cartao, CNPJ/CPF, codigo e loja do cliente selecionado
Local lRet          := .T.						// Define se prossegue a operacao
//³Variaveis do Template de Drogaria³
Local cCodMA6		:= ""   					// codigo do cliente no cadastro de cartoes
Local cLojaMA6 		:= ""   					// loja do cliente no cadastro de cartoes
Local lHasTplDro	:= (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
Local aVarTemplate  := {}						// Array que contera valores de Variaveis do tipo 'STATIC'
Local lFRT010CLt    := ExistTemplate("FRT010CL")// verifica se existe o PONTO DE ENTRADA FRT010CL
Local lFRT010BL		:= ExistBlock("FRT010BL")
Local lAlteraCli    := .T.                      //Controla se pode alterar cliente
//³Verifica se a estacao possui Display³
Local lUsaDisplay 	:= !Empty(LjGetStation("DISPLAY"))	// Controla se utiliza Display
Local lFRT271ALTC	:= ExistFunc("U_FRT271ALTC")		// P.E. para FRT Substitui a tela se seleção do cliente
Local aKey 			:= {}								//Guarda as teclas de atalho programada
Local cCliPad 		:= SuperGetMV( "MV_CLIPAD" )        //Cliente Padrão
Local cLjCliPad 	:= SuperGetMV( "MV_LOJAPAD" )	 	//Loja Padrão
Local aRetCli		:= {}

DEFAULT cNCartao	:= ""						// Numeracao do Cartao do cliente
DEFAULT cCodDep		:= ""						// Codigo do departamento
DEFAULT cNomeDEP	:= ""						// Nome do departamento
DEFAULT cTipoCli	:= ""						// Tipo do Cliente A1_TIPO
DEFAULT lBscCliON	:= .F.                      // Ativa o Cliente ON-LINE
DEFAULT nConTcLnk	:= 0 						// Variavel de controle do TCLINK
DEFAULT cCliCGC		:= ""						// Cnpj / CGC do cliente
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aVarTemplate  - Template Drogaria                 ³
//³---------------------------------------------------------------------³
//³-    aVarTemplate[1]  =  codigo do cliente                           ³
//³-    aVarTemplate[2]  =  loja                                        ³
//³-    aVarTemplate[3]  =  numero do cartao                            ³
//| 																	|
//|- Eh passado como referencia na funcao  CrdIdentCli 				    |
//³---------------------------------------------------------------------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRecebe
	Return NIL
EndIf

If lUsaDisplay
	// Limpar as mensagens do display
	LjLimpDisp()
	DisplayEnv(StatDisplay(), "1C" + STR0013 )		// ### "Alteração de Cliente"
	DisplayEnv(StatDisplay(), "2E" + STR0053 )		// ### "Utilize o monitor para visualizar"
	DisplayEnv(StatDisplay(), "3C" + STR0013 )		// ### "Alteração de Cliente"
	DisplayEnv(StatDisplay(), "***")	// Ocultar echo no Display
Endif

aKey := FRTSetKey()
If lCxAberto
    //Verifica se ja foram registrados itens na venda, mesmo que estejam cancelados nao permite alterar o cliente
	If lOcioso .AND. LEN(aItens) == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o Front tem integracao com o Sistema de Credito³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CrdxInt()
            aDadosCli     := {Space(TamSX3("MA6_NUM")[1]),;    //Numero do cartao
                  			   Space(TamSX3("A1_CGC")[1]),;     //CNPJ/CPF do cliente
                  			   Space(TamSX3("A1_COD")[1]),;     //Codigo do cliente
                  			   Space(TamSX3("A1_LOJA")[1])}     //Loja do cliente

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carregando o array que sera utilizado em outras funcoes³
			//³do Template Drogaria                                   ³
			//³11/01/2006.                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aVarTemplate := {cCodConv,cLojconv,cNumCartConv}

			 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			 //³Identificacao do cliente pelo cartao ou CNPJ/CPF           ³
			 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet  := CrdIdentCli(  @aRetCart  	,@aDadosCli  	,@lCliente  ,.T.  ,;
			                       @aCliente	,@aVarTemplate	,Nil)	//adicionado o ultimo parametro
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valorizando as variaveis do tipo "STATIC" criadas pela equipe³
			//³de Templates.                                                ³
			//³Template Drogaria                                            ³
			//³11/01/2006.                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodConv 	 := aVarTemplate[1]
			cLojconv 	 := aVarTemplate[2]
			cNumCArtConv := aVarTemplate[3]

            If lRet
				aCrdCliente[1] 	:= aDadosCli[2]  //CNPJ/CPF
				aCrdCliente[2] 	:= aDadosCli[1]  //Numero do cartao
				cNCartao		:= aCrdCliente[2] //Numero do cartao


				If !lCliente
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Assume o cliente que foi pesquisado na retaguarda pela funcao        ³
					//³ CrdIdentCli()                                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCliente := aDadosCli[3]
					cLojaCli := aDadosCli[4]
				Else
					cCliente := cCliPad
					cLojaCli := cLjCliPad
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando nao foi possivel identificar o cliente, assume o cliente padrao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCliente := cCliPad
				cLojaCli := cLjCliPad
			EndIf
		EndIf

		If lCliente .AND. lRet
			If lBscCliON
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o Front irá se conectar com a retaguarda       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !FRTAABRCON(@nConTcLnk)
					FRTSetKey(aKey)
					If lUsaDisplay
						// Limpar as mensagens do display
						LjLimpDisp()
						DisplayEnv(StatDisplay(), "1E"+ STR0017)	// "Codigo do Produto: "
						DisplayEnv(StatDisplay(), "*")	// Voltar a liberar echo no Display
					Endif
					Return(NIL)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seleciona/prepara a area da retaguarda para ser utilizada no Check-Out  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTADEFTAB(Posicione("SX2", 1, "SA1", "AllTrim(X2_ARQUIVO)"), "SA1", nConTcLnk)
				cNomeCli := Subst(Posicione("SA1",1,xFilial("SA1")+cCliFrt+cLojFrt,"A1_NOME"),1,30)
			EndIf
			
			/* A tela do TPL Drogaria posiciona o registro da SA1 conforme selecionado*/
			If lHasTplDro .And. ExistTemplate("TELACART") .And. T_TELACART()
				cCliente:= SA1->A1_COD
				cLojaCli:= SA1->A1_LOJA
				cNomeCli:= SA1->A1_NOME
				cTribFrt:= SA1->A1_GRPTRIB
				LjGrvLog( Nil, " Retorno dos dados do cliente - Template de Drogaria ",{cCliente,cLojaCli,cNomeCli})
			EndIf
			
			If lFRT271ALTC
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³P.E. para substituir a tela de seleção do Cadastro de Clientes - FRT271AltCli³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjGrvLog( NIL, " Antes da execução do PE FRT271AltC")
				U_FRT271ALTC( @cCliFrt,	@cLojFrt, @cNomeCli, @cCliente,;
							  @cLojaCli, @cMensagem	)
				LjGrvLog( NIL, " Depois da execução do PE FRT271AltC")
			ElseIf !lHasTplDro
				DEFINE FONT oFnt2 NAME "Arial" SIZE 11.5,22 BOLD
				DEFINE MSDIALOG oDlgAltCli FROM  47,130 TO 200,550 TITLE STR0013 PIXEL	// "Alteração de Cliente"
				@ 04, 05 TO 28, 85 LABEL STR0014 OF oDlgAltCli	PIXEL	// "Cod.Cliente / Loja"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³P.E. para nao permitir a escolha de um cliente de acordo com a regra de negocio do cliente - FRT010BL³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ 13, 15 MSGET oCliFrt VAR cCliFrt SIZE 40, 10 OF oDlgAltCli F3 "FCL" PIXEL VALID ( ExistCpo("SA1",cCliFrt+cLojFrt), IIF( lFRT010BL, ExecBlock( "FRT010BL", .F., .F., { cCliFrt + cLojFrt } ), NIL ) )
				oCliFrt:cSx1Hlp:="A1_COD"
	 			@ 13, 60 MSGET oLojFrt VAR cLojFrt SIZE 15, 10 OF oDlgAltCli PIXEL	VALID ( ExistCpo("SA1",cCliFrt+cLojFrt), IIF( lFRT010BL, ExecBlock( "FRT010BL", .F., .F., { cCliFrt + cLojFrt } ), NIL ) )
				oLojFrt:cSx1Hlp:="A1_LOJA"

				@ 30, 05 TO 54, 210 LABEL STR0015 OF oDlgAltCli PIXEL	// "Nome do Cliente"
				@ 39, 15 MSGET oNomeCli VAR cNomeCli WHEN .F. PIXEL

				oCliFrt:bLostFocus  := { || cNomeCli := Subst(Posicione("SA1",1,xFilial("SA1")+cCliFrt+cLojFrt,"A1_NOME"),1,30),cTribFrt:= SA1->A1_GRPTRIB , oNomeCli:Refresh() }
				oLojFrt:bLostFocus  := { || cNomeCli := Subst(Posicione("SA1",1,xFilial("SA1")+cCliFrt+cLojFrt,"A1_NOME"),1,30),cTribFrt:= SA1->A1_GRPTRIB , oLojFrt:Refresh() }
			
				DEFINE SBUTTON FROM 60, 135 oButton2 TYPE 1 ENABLE OF oDlgAltCli ;
				ACTION  IIf((IIF( lFRT010BL, ExecBlock( "FRT010BL", .F., .F., { cCliFrt + cLojFrt } ), .T. ),ExistCpo("SA1",cCliFrt+cLojFrt)), ;
				(cCliente := cCliFrt, cLojaCli := cLojFrt,  cGrpTrib := cTribFrt, oDlgAltCli:End()), .f.) PIXEL
					
				DEFINE SBUTTON FROM 60, 170 oButton3 TYPE 2 ENABLE OF oDlgAltCli ;
				ACTION (oDlgAltCli:End()) PIXEL

				ACTIVATE MSDIALOG oDlgAltCli CENTERED
			Endif
		Endif
	Else
	    lAlteraCli  := .F.
	   If lUsaDisplay
			DisplayEnv(StatDisplay(), "1C" + OemToAnsi(STR0001) )         //"Atenção
			DisplayEnv(StatDisplay(), "2C" + SubStr(STR0016,26,35) )         //"Não será possível alterar o cliente""
			DisplayEnv(StatDisplay(), "*")	// Voltar a liberar echo no Display
		EndIf
		HELP(' ',1,'FRT028')	// "Não é possível alterar o Cliente durante a venda.", "Atenção"
	EndIf
Else
	HELP(' ',1,'FRT029')	// "O Caixa não está aberto. Não será possível alterar o cliente.", "Atenção"
	If lUsaDisplay
		DisplayEnv(StatDisplay(), "1C" + SubStr(STR0016,1,23) )         //"O Caixa não está aberto.
		DisplayEnv(StatDisplay(), "2C" + SubStr(STR0016,26,35) )         //"Não será possível alterar o cliente"
		DisplayEnv(StatDisplay(), "*")	// Voltar a liberar echo no Display
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o cadastro de clientes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SA1" )
SA1->(DbSetOrder( 1 ))
SA1->(MsSeek( xFilial( "SA1" ) + cCliente + cLojaCli ))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do ponto de entrada "FRT010CL" para templates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRT010CLt .AND. lRet .AND. lAlteraCli
	LjGrvLog( Nil, "Antes da execução do T.F. FRT010CL")
	// O template poderá retornar qualquer tipo de váriavel...
	aRetCli := ExecTemplate( "FRT010CL", .F., .F., { aRetCart, uCliTpl, cCodConv, cLojConv, cNumCartConv,lCxAberto,lOcioso} )
	LjGrvLog( Nil, "Depois da execução do T.F. FRT010CL",aRetCli)
	If ValType( aRetCli ) == "A" .AND. Len( aRetCli ) <> 2
	// Se nao satisfazer a condicao sai da tela.
		If !aRetCli[1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se voltar com a matriz vazia foi o cancelamento da tela de planos de fidelizacao ³
			//³ posiciona no cliente e loja padrao                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "SA1" )
			SA1->(DbSetOrder( 1 ))
			If ((!cCliente == cCliPad ) .OR. (!cLojaCli == cLjCliPad)) .AND. ;
				!MsgYesNo( STR0048 + cCliente + STR0049 + cLojaCli ; // "Pesquisa cancelada. Deseja manter o Cliente :" + #### + "| Loja :" + ####
						 + STR0050	)    					  		 // " atual da venda?  Em caso negativo, será alterado para o cliente padrão."

				cCliente := cCliPad
				cLojaCli := cLjCliPad
			EndIf
		Else
			uCliTpl  	 := aRetCli[2]
		    cCodConv 	 := aRetCli[3]
	 		cLojConv 	 := aRetCli[4]
	 		cNumCartConv := aRetCli[5]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso a numeracao do cartão esteja em branco,  alimenta com o         ³
			//³conteudo do posicao 5 do array aRetCli.                              ³
			//³Isso ira acontecer caso a escolha do cliente seja diferente da opcao ³
			//³"Nao Magnetico".                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 		If Empty(cNCartao)
		 		cNCartao	 := aRetCli[5]
	 		Endif
		EndIf

	EndIf
Endif

If lBscCliON
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena informações do Cliente                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTipoCli	:=	SA1->A1_TIPO
	cCliCGC		:=  SA1->A1_CGC
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do ponto de entrada "FRT010CL"                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRT010CL")
	LjGrvLog( Nil, "Antes da execução do PE FRT010CL")
	ExecBlock("FRT010CL")
	LjGrvLog( Nil, "Depois da execução do PE FRT010CL")
Endif

If lBscCliON
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a conexão com a retaguarda.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTAFCHCON(nConTcLnk)
EndIf

FRTSetKey(aKey)

If lUsaDisplay
	// Limpar as mensagens do display
	LjLimpDisp()
	DisplayEnv(StatDisplay(), "1E"+ STR0017)	// "Codigo do Produto: "
	DisplayEnv(StatDisplay(), "*")	// Voltar a liberar echo no Display
Endif

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frt271ERegDscºAutor  ³Vendas CRM       º Data ³  11/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aplica as regras de desconto sobre o total da venda atual   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt271ERegDsc(	nTmpJuros	, nTmpDesc 		, aPgtosSint 	, aPgtos		,;
								nVlrTotal 	, nVlrBruto		, nVlrDescTot	, oVlrTotal		,;
								nEntrada	, nTaxaMoeda	, lRecebe		, dDataCN 		,;
								aItens		, nVlrMerc		, lDescTotal	, lDescSE4		,;
								nTotDedIcms	, nVlrPercTot	, nMoedaCor		, nDecimais		,;
								aImpsSL1	, aImpsSL2 		, aImpsProd		, aDadosJur		,;
								aFormCtrl	, cItemCond		, lCondNegF5	, lDescEspec	,;
								nTxJuros	, nValorBase	, lDiaFixo		, lImpOrc 		,;
								oCupom		, cCliente		, cLojaCli		, oTimer   		,;
								oHora		, cHora			, oDoc			, cDoc	   		,;
								oPDV		, cPDV			, nLastTotal	, nLastItem		,;
								nTotItens	, oTotItens		, oOnOffLine	, nTmpQuant		,;
								nVlrItem	, nValIPIIT		, nValIPI		, oFotoProd		,;
								oProduto	, oQuant		, oVlrUnit		, oVlrItem 		,;
								oDesconto	, cSimbCor		, cOrcam		, cUnidade 		,;
								nVlrUnit	, oUnidade		, lF7   		, cCliente		,;
								cLojaCli	, cVendLoja		, lOcioso		, lLocked		,;
								lCXAberto	, lDescIT		, aICMS			, _aMult		,;
								_aMultCanc	, aParcOrc		, cItemCOrc		, aParcOrcOld	,;
								lAltVend	, lImpNewIT		, lFechaCup		, cContrato		,;
								aCrdCliente	, aContratos	, aRecCrd		, aTEFPend		,;
								aBckTEFMult	, cCodConv		, cLojConv		, cNumCartConv	,;
								uCliTPL		, uProdTPL		, aVidaLinkD	, aVidaLinkc 	,;
								nVidaLink	, nValTPis		, nValTCof		, nValTCsl		,;
								lVerTEFPend	, nVlrPercAcr	, nVlrAcreTot	, nVlrDescCPg	,;
								nQtdeItOri	, aMoeda		, aSimbs		, aImpVarDup	,;
								aTotVen		, aCols			, nVlrPercIT	, aHeader  		,;
								nVlrDescIT	, oMensagem		, oFntMoeda		, cTipoCli		,;
								lBscPrdON	, nConTcLnk		, cEntrega  	, aReserva		,;
								lReserva	, lAbreCup		, nValor		, oPgtosSint	,;
								oPgtos		, aBonus    , lTela		, lFrtDescTot		)


Local aArea		:= GetArea()		  				// Salva o posicionamento da area atual
Local aAreaSBI	:= SBI->(GetArea())  				// Salva o posicionamento da tabela SBI
Local nX   		:= 0				  				// Auxiliar de loop
Local aProds	:= {}				   				// Resumo dos itens vendidos
Local nPerDscRgr:= 0
Local nVlrTotAcu:= 0
Local aPosCpos	:= {1,2,3}							// Posicao dos campos codigo, quant. e TES no aColsBon
Local aColsBon	:= {}								// aCols montado para bonificacao
Local nDescBon	:= 0								// Valor de desconto a ser concedido pelo bonus
Local nValDscRgr:= 0								// Total de desconto a ser concedido na venda
Local nItem		:= 0								// Posicao do item atual
Local aPgtSintBk:= aClone(aPgtosSint)				// Armazena vetor de pagamentos sintetico
Local aPgtosBk	:= aClone(aPgtos)					// Armazena vetor de pagamentos
Local cTabPreco	:= SuperGetMv("MV_TABPAD")			// Tabela de preco padrao

Static cUltDocBon	:= ""  							// Guarda o ultimo cupom processado na bonificacao

Default lTela       := .T.
Default lFrtDescTot := .F.

For nX := 1 to Len(aItens)
	If !aItens[nX][AIT_CANCELADO]

		//Acumula o valor total (inclusive o valor descontado)
		nVlrTotAcu += aItens[nX][AIT_VLRITEM] + aItens[nX][AIT_VALDESC]

		//Monta a lista de produtos vendidos
		AAdd(aProds,{aItens[nX][AIT_COD],;
					GetAdvFVal("SB1","B1_GRUPO",xFilial("SB1")+aItens[nX][AIT_COD],1,""),;
					aItens[nX][AIT_QUANT]})
	EndIf
Next nX

If Len(aProds) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desconto no Total FrontLoja:                        ³
	//³  Se for configurado para a nova regra, chama funcao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNovRegDesc
		If FindFunction("RGDesTol") //Loja 3025
			nPerDscRgr := RGDesTol(.F., nVlrTotAcu,,,cCliente,cLojaCli)
  		Endif
	Else
		nPerDscRgr 	:= LjRgrDesc(/*cProduto*/,cCliente,cLojaCli,cTabPreco,nVlrTotAcu,2,aProds,/*aExc*/)
	EndIf
	
	//se o desconto tota ja tiver sido atribuido, nao o recalculamos
	If  nVlrDescTot <= 0
		nVlrDescTot := (nPerDscRgr / 100) * nVlrTotal
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controla a rotina para ser executada apenas uma vez por venda.³
//³Caso a rotina seja acioada pelo PE FRTDESCVEN permite executar³
//³mais de uma vez.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFrtDescTot .AND. cUltDocBon == cDoc
	Return .F.
Else
	cUltDocBon := cDoc
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sintetiza os produtos validos em um acols simplificado para a³
//³rotina de regra de bonificacao                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SBI")
DbSetOrder(1) //BI_FILIAL+BI_COD

For nX := 1 to Len(aItens)
	If !aItens[nX][AIT_CANCELADO]
		If (nPos:= aScan(aColsBon,{|x|x[1] == aItens[nX][AIT_COD] })) == 0
			SBI->(DbSeek(xFilial("SBI")+aItens[nX][AIT_COD]))
			AAdd(aColsBon,{aItens[nX][AIT_COD],aItens[nX][AIT_QUANT],SBI->BI_TS,.F.})
		Else
			aColsBon[nPos][2] += aItens[nX][AIT_QUANT]
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa a regra de bonificacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsBon) > 0
	aBonus	:= LjxeRBonus(aColsBon,aPosCpos,cCliente,cLojaCli,cTabPreco,/*cCondPg*/)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere os produtos de bonificacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aBonus)

	FR271AProdOK(	/* cOrc */		, /*nNumItem*/	, /*cChkProduto*/	, .F.			,;
					aBonus[nX][1]	, @oTimer		, @oHora			, @cHora		,;
					@oDoc			, @cDoc			, @oPDV				, @cPDV			,;
					@nLastTotal		, @nVlrTotal	, @nLastItem		, @nTotItens	,;
					@nVlrBruto		, @oVlrTotal	, @oCupom			, @oTotItens	,;
					@oOnOffLine		, aBonus[nX][2]	, @nVlrItem			, @nValIPIIT	,;
					@nValIPI		, @oFotoProd	, @oProduto			, @oQuant		,;
					@oVlrUnit		, @oVlrItem		, @oDesconto		, @cSimbCor		,;
					@cOrcam			, aBonus[nX][1]	, aBonus[nX][2]		, @cUnidade		,;
					@nVlrUnit		, @oUnidade		, @lF7   			, Nil			,;
					@cCliente		, @cLojaCli		, @cVendLoja		, @lOcioso		,;
					@lRecebe		, @lLocked		, @lCXAberto		, @lDescIT		,;
					@nVlrDescTot	, @aItens		, @aICMS			, @nVlrMerc		,;
					@_aMult			, @_aMultCanc	, .F.				, @aParcOrc		,;
					@cItemCOrc		, @aParcOrcOld	, @lAltVend			, @lImpNewIT	,;
					@lFechaCup		, @cContrato	, @aCrdCliente		, @aContratos	,;
					@aRecCrd		, @aTEFPend	   	, @aBckTEFMult		, @cCodConv		,;
					@cLojConv		, @cNumCartConv	, @uCliTPL			, @uProdTPL		,;
					@lDescTotal		, @lDescSE4		, @aVidaLinkD		, @aVidaLinkc 	,;
					@nVidaLink		, @nValTPis		, @nValTCof			, @nValTCsl		,;
					@lVerTEFPend	, @nTotDedIcms	, @lImpOrc 			, @nVlrPercTot	,;
					@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg		, @nQtdeItOri	,;
					@aMoeda			, @aSimbs		, @nMoedaCor	 	, @nDecimais	,;
					@aImpsSL1		, @aImpsSL2		, @aImpsProd		, @aImpVarDup	,;
					@aTotVen		, @aCols		, @nVlrPercIT		, @nTaxaMoeda  	,;
					@aHeader  		, nVlrDescIT	, @oMensagem		, oFntMoeda		,;
					""				, @cTipoCli		, lBscPrdON			, @nConTcLnk	,;
					@cEntrega  		, @aReserva		, @lReserva			, @lAbreCup		,;
					@nValor			)

	nItem		:= Len(aItens)
	nDescBon	+= aItens[nItem][AIT_VLRITEM]

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica o desconto referente ao valor dos produtos bonificados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nDescBon > 0) .OR. (nVlrDescTot > 0)

	nValDscRgr := nDescBon + nVlrDescTot

	FR271FDescTot(	@nTmpJuros		, @nTmpDesc		, .T.			, @oPgtosSint	,;
					@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		,;
					@nVlrTotal 		, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	,;
					@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN 		,;
					@aItens			, @nVlrMerc		, @lDescTotal	, @lDescSE4		,;
					@nTotDedIcms	, @nVlrPercTot	, @nMoedaCor	, @nDecimais	,;
					@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aDadosJur	,;
					@aFormCtrl		, @cItemCond	, @lCondNegF5	, @lDescEspec	,;
					@nTxJuros		, @nValorBase	, @lDiaFixo		, @lImpOrc 		,;
					Nil				, Nil			, Nil			, Nil			,;
					Nil				, @nValDscRgr	, Nil           , Nil           ,;
					Nil				, Nil			, cCliente      , cLojaCli  , lTela )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura detalhes do pagamento apos o desconto, pois a        ³
	//³rotina FR271DescTot reaplica o desconto que ja foi considerado³
	//³no total da venda                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPgtosSint	:=  aClone(aPgtSintBk)
	aPgtos 		:=  aClone(aPgtosBk)

EndIf

RestArea(aAreaSBI)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frt271ECrd   ºAutor  ³Vendas CRM       º Data ³  11/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fidelização de cliente									  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA271                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Frt271ECrd(cCliente,cLojaCli, nTotPontos, aLibera, nVlrTotal)

Local aRet 					// retorono
Local oWs		:= 	Nil		// WebService
Local cWSServer := AllTrim(LJGetStation("WSSRV"))

oWS := WsFRTCRD():New()
oWs:_URL := "http://"+cWSServer+"/FRTCRD.apw"

aRet := AClone(Crd240Resgate( "", cCliente, 	cLojaCli, Nil, nTotPontos, Nil, nVlrTotal, oWs ))

Return (aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Frt271EImpV2³ Autor ³ Venda Clientes      ³ Data ³03/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressão da Segunda Via do Ticket de Venda				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Frt271EImpV2(ExpN1 , ExpN2 , ExpN3              		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Quantidade de Copias                               ³±±
±±³          ³ ExpN2 - Copia do Cupom                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt271EImpV2( nQtd, cCupom )

Local lFrtSegVia  := ExistBlock("FRTSegVia")	        // Verifica se o ponto de entrada FrtSegVia existe
Local aSegVia2    := {}                           		// Array para acumular as linhas do Ticket
Local cSegVia     := ""									// Variavel para acumular os dados do Ticket
Local xRet     	  := {}									// Variavel para controle do Ponto de Entrada
Local nX		  := 0                                  // Variavel para o FOR

aAdd(aSegVia2, Alltrim(cCupom))

If lFrtSegVia
	xRet := U_FRTSegVia(aSegVia2)
	If ValType(xRet) == "A"
	   aSegVia2  := AClone(xRet)
	EndIf
EndIf

For nX := 1 to Len(aSegVia2)
	cSegVia += aSegVia2[nx] + chr(10)
Next nX

IfTxtNFis( nHdlECF, cSegVia, nQtd )


Return ( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Frt271EPgPen³ Autor ³ Venda Clientes      ³ Data ³20/03/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Insere cartoes pendentes do MultiTEF Discado no aPgtos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array de formas de pagamento (aPgtos)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet	- .T. Se houver pagamento inserido / .F. caso nao	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt271EPgPend(aPgtos)
Local aCartoes		:= {}			// Array de cartoes pendentes
Local nI 			:= 0			// Codigo da bandeira utilizada
Local nParc 		:= 0			// Contador de parcela
Local nID 			:= 0			// ID do cartao
Local nValorParcela := 0			// Valor da parcela
Local cOperadora	:= ""			// Operadora do cartao utilizada no meio de pagamento
Local lRet			:= .F.			// Retorno da funcao - Se houver forma de pagamento inserida do aPgtos

DEFAULT aPgtos 		:= {}

If FindFunction("LJLoadDTEF")
	aCartoes := LJLoadDTEF()
EndIf

For nI := 1 To Len(aCartoes)
	If aCartoes[nI][8] == "PENDENTE"  //Ignora a Transacao Recarga de Celular
		nID++
		lRet := .T.
		nValorParcela := aCartoes[nI][2] / aCartoes[nI][1]
		cOperadora := GetOperadora(aCartoes[nI][6])

		For nParc := 1 To aCartoes[nI][1]
			AAdd(aPgtos, {dDatabase	, nValorParcela					, aCartoes[nI][3]		, cOperadora	,;
				 		  ""		, ""							, ""					, ""			,;
				 		  ""		, .F.							, 1						, Str(nID)		,;
				 		  0			, ""							, 0						, .F.			,;
				 		  ""})
		Next nParc
	EndIf
Next nI

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetOperadora³ Autor ³ Venda Clientes      ³ Data ³20/03/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Codigo - Operadora da tabela SAE.  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome da operadora de cartao 	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Codigo - Nome da operadora                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetOperadora(cOperadora)
Local cRet := ""  // Retorno da funcao

DEFAULT cOperadora := ""

DbSelectArea("SAE")
DbSetOrder(1)
If DbSeek(xFilial("SAE"))
	While xFilial("SAE") == SAE->AE_FILIAL .AND. !(SAE->(EOF()))
		If Upper(AllTrim(cOperadora)) == Upper(AllTrim(SAE->AE_DESC))
			cRet := SAE->AE_COD + " - " + SAE->AE_DESC
			Exit
		EndIf
		DbSkip()
	End
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FRT271EDpF
Funcao para apresentar em displays as mensagens referentes ao fechamento de caixa
@author	Vendas Cliente
@param     nOpc Opcao que indica qual mensagem do fechamento de caixa deve ser apresentada onde 1: Inicio; 2: Fechamento com sucesso; 3: Fechamento nao realizado
@param     aKey Array com as opcoes de teclas da rotina no caso do fechamento nao concluido com sucesso
@version	P10
@since	07/01/2015
/*/
//--------------------------------------------------------------------------------------------------------------------------------------------------------------
Function FRT271EDpF(nOpc, aKey)

Local lUsaDisplay 		:= !Empty(LjGetStation("DISPLAY"))		// Verifica se a estacao possui Display

DEFAULT nOpc := 0
DEFAULT aKey := {}

If !lUsaDisplay
	Return Nil
Endif

DO CASE

	// Iniciar o fechamento do caixa
	CASE nOpc == 1

		// Limpar o display
		LjLimpDisp()

		DisplayEnv(StatDisplay(), "1C" + STR0065 )		// ### "FECHAMENTO DO CAIXA"
		DisplayEnv(StatDisplay(), "2E" + STR0053 )		// ### "Utilize o monitor para visualizar"
		DisplayEnv(StatDisplay(), "3C" + STR0054 )		// ### "as mensagens de fechamento."

	// Fechamento realizado com sucesso
	CASE nOpc == 2

		// Limpar o display
		LjLimpDisp()

		DisplayEnv(StatDisplay(), "1C" + STR0065 )  		// ### "FECHAMENTO DO CAIXA"
		DisplayEnv(StatDisplay(), "2E" + STR0057 )		// ### "Fechamento de caixa concluido."
		DisplayEnv(StatDisplay(), "3C" + STR0055 )		// ### "Tecle <ENTER> para continuar"

		MsgInfo(	STR0058 + CRLF + ;		// ### "Fechamento de caixa concluído."
					STR0055, STR0056)			// ### "Tecle <ENTER> para continuar" ### "Fechamento de Caixa"

		// Limpar o display
		LjLimpDisp()

	// Fechamento de caixa não realizado
	CASE nOpc == 3

		// Limpar o display
		LjLimpDisp()

		DisplayEnv(StatDisplay(), "1C" + STR0065 )  		// ### "FECHAMENTO DO CAIXA"
		DisplayEnv(StatDisplay(), "2E" + STR0059 )		// ### "Operação de fechamento de caixa"
		DisplayEnv(StatDisplay(), "3E" + STR0060 )		// ### "cancelada."
		DisplayEnv(StatDisplay(), "4E" + STR0055 )		// ### "Tecle <ENTER> para continuar"

		If !Empty(aKey)	// Na saida do sistema

			MsgAlert(STR0042)	// ### "Operação de fechamento de caixa cancelada."
			FRTSetKey(aKey)

			// Limpar o display
			LjLimpDisp()

		Endif

END CASE

Return Nil

