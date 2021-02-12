#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA271H.CH"
#INCLUDE "AUTODEF.CH"
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
#DEFINE AIT_DEDICMS   			13          // Deducao de ICMS
#DEFINE AIT_ITIMP   			14          		// Numero do item na Impressora
#DEFINE AIT_PBM		   			15          		// Define se o produto e PBM

#DEFINE _FORMATEF				"CC;CD"     // Formas de pagamento que utilizam operação TEF para validação
#DEFINE CRLF                   Chr(13)+Chr(10)  //Pula linha


#DEFINE LOG_IMP FR271HLogImp()             	// Pasta para a gravacao dos arquivos importados

Static lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .AND. RGVldTable()		//Validacao da Nova Regra de Desconto Ativa
Static cGetCliDir
Static nVlrNCCOrc	:= 0 //Valor da NCC do Orcamento

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HRoll³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Roll-Back para a Situacao 04                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271HRollB04
FR271BCancela(.F., .F., .T.)					// Deleta Somente o SL4
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Como nao conseguiu gerar o SL4, Volta a Situacao "04" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSL1 := {	{"L1_VEND"		, ""	}, ;
		 	{"L1_COMIS"		, 0		}, ;
		 	{"L1_VEND2"		, ""	}, ;
		 	{"L1_VEND3"		, ""	}, ;
		 	{"L1_CLIENTE"	, ""	}, ;
		 	{"L1_TIPOCLI"	, ""	}, ;
		 	{"L1_LOJA"		, ""	}, ;
		 	{"L1_TIPO"		, ""	}, ;
		 	{"L1_VLRTOT"	, 0		}, ;
		 	{"L1_DESCONT"	, 0 	}, ;
		 	{"L1_VLRLIQ"	, 0		}, ;
		 	{"L1_VALBRUT"	, 0		}, ;
		 	{"L1_VALMERC"	, 0		}, ;
		 	{"L1_DESCNF"	, 0		}, ;
		 	{"L1_DINHEIR"	, 0		}, ;
		 	{"L1_CHEQUES"	, 0		}, ;
		 	{"L1_CARTAO"	, 0		}, ;
		 	{"L1_CONVENI"	, 0		}, ;
		 	{"L1_VALES"		, 0		}, ;
		 	{"L1_FINANC"	, 0		}, ;
		 	{"L1_VLRDEBI"	, 0		}, ;
		 	{"L1_OUTROS"	, 0		}, ;
		 	{"L1_ENTRADA"	, 0		}, ;
		 	{"L1_JUROS"		, 0		}, ;
		 	{"L1_PARCELA"	, 0		}, ;
		 	{"L1_TXDESC"	, 0		}, ;
		 	{"L1_CONDPG"	, ""	}, ;
		 	{"L1_FORMPG"	, ""	}, ;
		 	{"L1_CREDITO"	, 0		}, ;
		 	{"L1_SITUA"		, "04"	} }					// "04" - Impresso o Item
FR271BGeraSL("SL1", aSL1, .F.)
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HImpC³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o Roll-Back para a Situacao 04                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271HImpCH(aParcelas)
Local nI      		:= 0
Local lTemCH  		:=.F.
Local cObs    		:= ""
Local cVerso  		:= ""
Local cSimbCheq   	:= AllTrim(MVCHEQUE)

If ( ValType(aParcelas) <> "U" .AND. Len(aParcelas) > 0)

	For nI := 1 To Len(aParcelas)
		If AllTrim(aParcelas[nI][3]) == cSimbCheq
			lTemCH := .T.
			Exit
		EndIf
	Next nI

	If lTemCH
		For nI := 1 To Len(aParcelas)
			If AllTrim(aParcelas[nI][3]) == cSimbCheq
				cBanco   := Substr(aParcelas[nI][4],1,3)
				cFavorec := SM0->M0_NOME
				cCidade  := Left(SM0->M0_CIDCOB,15)
				cCidade  := If(Empty(cCidade), "Sao Paulo", cCidade)
				nValor   := aParcelas[nI][2]
				IF SuperGetMV("MV_DATCHE") == "E"
					dEmissao := dDataBase
				Else
					dEmissao := aParcelas[nI][1]
				EndIf
				cCheque  := aParcelas[nI][5]
				cAgencia := aParcelas[nI][6]
				cConta   := aParcelas[nI][7]
				LjImpCheque(cBanco, cAgencia, cConta, cCheque, @nValor, @cFavorec, @cCidade, @dEmissao, @cObs, @cVerso, .F.)
			Endif
		Next nI
	EndIf
Endif

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HTime³ Autor ³  Vendas Clientes      ³ Data ³25/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Evento de Timer para atualizar a Hora e verificar SLI.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271HTimer(	oTimer		, oHora		, cHora		, oDoc			,;
			 			cDoc		, oPDV		, cPDV		, nLastTotal	,;
			 			nVlrTotal	, nLastItem	, nTotItens	, nVlrBruto		,;
						oVlrTotal	, oCupom	, oTotItens	, oOnOffLine	,;
						lOcioso		, lLocked	, aItens	, aMoeda		,;
						aSimbs		, nMoedaCor	, aTotVen	, oMensagem		,;
	              		oFntMoeda   , cMensagem )
Local aKey
Local nHdlERR
Local nCancelar
Local nItem
Local cVlrItem
Local aCancelar
Local cLidos
Local nI // variavel do loop
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )


FR271Hora(Nil, Nil, oHora, cHora, oDoc, cDoc)

//Atualiza na tela o valor da venda nas diversas moedas do sistema...
If cPaisLoc <> "BRA"
	FR271HExibTotVen( @aMoeda	, @aSimbs, @aTotVen, @oMensagem,;
					  oFntMoeda	, @cMensagem )
EndIf

IpcGo(WAITID)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando Estiver Conectado, Informar o Status Atual. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FR271BGerSLI(cEstacao, "CON", If(lOcioso," ","V")+"|"+;
							Alltrim(cPDV)+"|"+;
							AllTrim(cDoc)+"|"+;
							AllTrim(Str(If(lOcioso,nLastTotal,nVlrTotal),14,2))+"|"+;
							AllTrim(Str(If(lOcioso, nLastItem, nTotItens))), "SOBREPOE")

If SLI->(DbSeek(xFilial("SLI")+"    LCK")) .AND. Left(SLI->LI_MSG,3) == "END"
	lLocked := .T.
	If lOcioso
		oTimer:Deactivate()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aKey := FRTSetKey()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aguardando a Thread Processar Atualizacao da Base de Dados. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FR271HLocked()
		lLocked := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		oTimer:Activate()
	EndIf
Else
	If SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"MSG")) .AND. !Empty(SLI->LI_MSG)
		// "Mensagem do FRTMonitor"
		MsgInfo(AllTrim(SLI->LI_MSG), STR0003)
		FR271BGerSLI(cEstacao, "MSG", "", "SOBREPOE")
	EndIf
	If lOcioso
		If SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"COM")) .AND. Left(SLI->LI_MSG,11)=="CLOSE FILES"
			oTimer:Deactivate()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aKey := FRTSetKey()
			LjMsgRun(STR0004,, {|| FR271HAtua()})	// "Aguarde. Inciando processo de atualização de todas as tabelas no Check-Out..."
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura os SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTSetKey(aKey)
			oTimer:Activate()
		ElseIf SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"PSS")) .AND. Left(SLI->LI_MSG,9)=="CLOSE SPF"
			oTimer:Deactivate()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aKey := FRTSetKey()
			LjMsgRun(STR0005,, {|| FR271HAtuSPF()})	// "Aguarde. Atualizando senhas de usuário..."
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura os SetKey's do Fechamento da Venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FRTSetKey(aKey)
			oTimer:Activate()
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checar se a Thread Esta Conectada ao Server ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTouch
		If FR271BOnOfBmp("CON", cEstacao)
			oOnOffLine:SetBMP("FRTONLINE")
		Else
			oOnOffLine:SetBMP("FRTOFFLINE")
		EndIf
	Endif
EndIf
If cGetCliDir == NIL
   cGetCliDir := GetClientDir()
EndIf
If File(cGetCliDir+"DREGIS.ERR")
	nHdlERR := -1
	aCancelar := {}
	While nHdlERR == -1
		nHdlERR := FOpen(cGetCliDir+"DREGIS.ERR", 0+16)	// Read + Exclusive
	End
	nCancelar := (FSeek(nHdlERR, 0, 2) / 11)
    FSeek(nHdlERR, 0)
	For nI := 1 To nCancelar
		cLidos := FReadStr(nHdlERR, 11)
		AAdd(aCancelar, {Left(cLidos,6), FR271BPegaIT(Val(Substr(cLidos,7,3)))})
	Next nI
	FClose(nHdlERR)
	FErase(cGetCliDir+"DREGIS.ERR")

	For nI := 1 To nCancelar
		DbSelectArea("SL1")
		DbSetOrder(8)
		If DbSeek(xFilial()+cPDV+aCancelar[nI][1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancelar o Item ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SL2")
			DbSetOrder(1)
			If DbSeek(xFilial()+SL1->L1_NUM+aCancelar[nI][2])
				RecLock("SL2", .F.)
				SL2->L2_VENDIDO := "N"	//Sinaliza item cancelado, quando PAF-ECF considera registro deletado na subida da Venda
				dbDelete()
				MsUnLock()

				// AIT_ITEM Esta no CodeBlock Abaixo...
				nItem := AScan(aItens, {|x| x[1] == Val(aCancelar[nI][2])})
				aItens[nItem][AIT_CANCELADO] := .T.								// Marca Como Cancelado
				nVlrTotal-= aItens[nItem][AIT_VLRITEM]
				nVlrBruto-= aItens[nItem][AIT_VLRITEM]
				If !lTouch
					oVlrTotal:Refresh()
				Endif

				cVlrItem := Trans(aItens[nItem][AIT_VLRITEM], PesqPict("SL2","L2_VLRITEM",13,nMoedaCor))
				oCupom:SetupdatesEnable(.F.)
				oCupom:AppendText(( "ITEM "+StrZero(nItem,3)+" NAO REGISTRADO") + chr(10) + chr(13))	// "ITEM " " NAO REGISTRADO"
				oCupom:AppendText(( Space(19)+aItens[nItem][AIT_ALIQUOTA]+"%"+cVlrItem ) + chr(10) + chr(13) )
				oCupom:SetupdatesEnable(.T.)
				oCupom:GoEnd()

				nTotItens--
				oTotItens:Refresh()

			EndIf
		EndIf
	Next nI
EndIf
If cPaisLoc <> "BRA" .AND. SLI->(DbSeek(xFilial("SLI")+"    SM2")) .AND. Left(SLI->LI_MSG,8) == "ATUALIZA"
	lLocked := .T.
	If lOcioso
		oTimer:Deactivate()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aKey := FRTSetKey()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aguardando a Thread Processar Atualizacao da Base de Dados. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FrtSetMoeda()
        FR271BGerSLI("    ", "SM2", "", "SOBREPOE")
		lLocked := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os SetKey's do Fechamento da Venda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FRTSetKey(aKey)
		oTimer:Activate()
	EndIf
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HLock³ Autor ³  Vendas Clientes      ³ Data ³24/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Destravar Usuario Para Atualizacao da Base de Dados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FR271HLocked

Conout(STR0006) // "Aguarde. Atualizando a base de dados..."

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HAtua³ Autor ³  Vendas Clientes      ³ Data ³05/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fecha as tabelas para o FRTA020 atualizar as tabelas.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR271HAtua
Local aFiles := FRTArquivos()
Local nI	 := 0 				// variavel do loop

For nI := 1 To Len(aFiles)										// Fecha as tabelas
	&(aFiles[nI]+"->(dbCloseArea())")
Next nI
FR271BGerSLI(cEstacao, "COM", "CLOSE OK", "SOBREPOE")				// Envia ao FRTA020 que fechou as tabelas
While .T.
	SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"COM"))		// Aguarda o FRTA020 atualizar a tabela
	If Left(SLI->LI_MSG,10)=="OPEN FILES"
		Exit
	EndIf
	Sleep(1000)
End
For nI := 1 To Len(aFiles)										// Reabre as tabelas
	ChkFile(aFiles[nI])
Next nI
FR271BGerSLI(cEstacao, "COM", "", "SOBREPOE")						// Finaliza o processo
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HAtuS³ Autor ³  Vendas Clientes      ³ Data ³23/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza as senhas do usuario (SIGAPSS.SPF)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR271HAtuSPF
Local aArea	:= ""
Local cLIMsg:= ""

aArea := GetArea()

DbSelectArea("SLI")
SLI->( DbSetOrder(1) ) //LI_FILIAL + LI_ESTACAO + LI_TIPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aguardamos a solicitacao de fechamento do SIGAPSS.SPF         |
//|(LI_MSG = "CLOSE SPF"),que eh realizada pelo pelo job FRTA020.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While .T.
	// posicionamos novamente no registro, para garantir a integridade da informacao
	If SLI->( DbSeek(xFilial("SLI") + PadR(cEstacao,4) + "PSS") )		// Aguarda o FRTA020 atualizar a tabela
		If AllTrim(SLI->LI_MSG)  == "CLOSE SPF"
			SPF_Close("SIGAPSS.SPF")
			Exit
		EndIf
	EndIf
	Sleep(500)	// 0,5 segundo
EndDo

// indica que o arquivo SIGAPSS.SPF foi fechado, portanto o FRTA020 podera prosseguir seu processamento
FR271BGerSLI(cEstacao, "PSS", "SPF CLOSED", "SOBREPOE")

// Apos o FRTA020 ter sincronizado o SIGAPSS.SPF, ele indica que o arquivo esta ok (LI_MSG = "SPF OK")
While .T.
	If SLI->( DbSeek(xFilial("SLI") + PadR(cEstacao,4) + "PSS") )
		cLIMsg := AllTrim(SLI->LI_MSG)
		// Aguarda o FRTA020 atualizar a tabela
		If cLIMsg == "SPF OK" .OR. cLIMsg == "SPF NOK"
			Exit
		EndIf
	EndIf
	Sleep(1000)	// 1 segundo
End

FR271BGerSLI(cEstacao, "PSS", "", "SOBREPOE")

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271HPar ºAutor  ³ Vendas Clientes    º Data ³  26/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua alteração no valor e data das parcelas               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HPar(	nVlrTotal	, oPgtos		, aPgtos	, nTaxaMoeda,;
					oPgtosSint	, aPgtosSint	, lRecebe	, aMoeda	,;
					aSimbs		, nMoedaCor		, nDecimais , aCProva	,;
					aFormCtrl   , oPgtosAna)

Local lVisuSint  	:= If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local nLinha		:= If(lVisuSint .AND. ValType(oPgtosAna)=="O", oPgtosAna:nAt, oPgtos:nAt)
Local cForma
Local cDesc
Local dDataParc
Local nValParc
Local cMoedaVen

Local aKey
Local nOpc			:= 0

Local nI 			:= 0	//variavel de loop
Local nValMax		:= 0
Local nNumParc		:= 0
Local nPosMoeda
Local nTamParc1 	:= 0
Local nTamParc2 	:= 0
Local nValParcAux 	:= 0
Local lTefMult 		:= SuperGetMV("MV_TEFMULT", ,.F.)				// Identifica se o cliente utiliza múltiplas transações TEF
Local cDigCart 		:= "" , oDigCart							// Dígitos do Cartão


Local nValAux  		:= 0
Local aSE4 	   		:= {}										// Array com os dados para simular o SE4 na funcao condicoes
Local aDatas    	:= {}                                    	// Array com próximas condições de pagamento
Local cFormAtu  	:= ""										// Guarda a forma de pagamento para recalculo das datas
Local cDigAtu   	:= ""										// Guarda o digito para recalculo das datas
Local nDias			:= 0										// Controle de dias para montar a string de cond.pgto
Local nIntervalo	:= 0										// Calculo do intervalo das parcelas
Local cE4Cond		:= ""										// String para armazenar o Cond.Pagto
Local dDataAnt		:= aPgtos[nLinha][1]						// Guardo a última data para recalculo das proximas
Local nFor			:= 0
Local cSimbCheq   := AllTrim(MVCHEQUE)

dDataParc	:= aPgtos[nLinha][1]
nValParc	:= aPgtos[nLinha][2]
cForma		:= aPgtos[nLinha][3]
cDesc		:= Right(aPgtos[nLinha][4],30)

If !lVisuSint	//Confere os 4 últimos dígitos
	cDigCart 	:= If(lUsaTef .AND. lTefMult, Alltrim(aPgtos[nLinha][12]), Space(04))
Else			//Confere o ID do cartão
	cDigCart 	:= If(lUsaTef .AND. lTefMult, Alltrim(aPgtos[nLinha][12]), Space(TamSX3("L4_FORMAID")[1]) )
EndIf

If cPaisLoc <> "BRA"
	cMoedaVen := &("MV_MOEDA"+STR(aPgtos[nLinha][11],1))
	nPosMoeda := aPgtos[nLinha][11]
EndIf

If IsMoney(cForma) .OR. cForma=="VA"
	// "Para alterar a Forma " ### ", pressione a tecla correspondente."
	MsgStop(STR0007+AllTrim(If(Empty(cDesc),cForma,cDesc))+STR0008, STR0001)
	Return(NIL)
EndIf

For nI := nLinha To Len(aPgtos)
	If lVisuSint	//Considerar tbm o ID do Cartão qdo Multi-TEF
		If ( ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
			 (aPgtos[nI][3] == cForma .AND. !cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) )    .OR.  ;
		     (aPgtos[nI][3] == cForma .AND.  cForma$_FORMATEF) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == Alltrim(cDesc) ) .AND. AllTrim(aPgtos[nI][12]) == Alltrim(cDigCart) )
			nNumParc++
			nValMax +=  Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],nMoedaCor,dDataBase,;
		                nDecimais+1,,nTaxaMoeda),nDecimais)
			If nNumParc == 2
			   nDias := aPgtos[nI][1] - dDataParc
			EndIf
        EndIf
	Else			//Mantém a verificação padrão
		If ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (aPgtos[nI][3] == cForma)) .OR. ;
		   ((aPgtos[nI][3] == cForma) .AND. (AllTrim(Right(aPgtos[nI][4],30)) == AllTrim(cDesc)))
			nNumParc++
			nValMax +=  Round(xMoeda(aPgtos[nI][2],aPgtos[nI][11],nMoedaCor,dDataBase,;
		                nDecimais+1,,nTaxaMoeda),nDecimais)
			If nNumParc == 2
			   nDias := aPgtos[nI][1] - dDataParc
			EndIf
		EndIf
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desativa as teclas de funcoes                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta tela de dialogo para pegar o valor da parcela     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua alteração no valor e data das parcelas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Frtx272T04(	@aMoeda		, @lUsaTef	, @lTefMult		, @aPgtos		,;
			@nLinha		, @lRecebe	, @cSimbCheq	, @dDataParc	,;
			@cForma		, @nValParc	, @nNumParc 	, @nValMax		,;
			@cMoedaVen 	, @cDigCart	, @nOpc		)


If nOpc == 1
	aPgtos[nLinha][1] := dDataParc
	aPgtos[nLinha][2] := nValParc
	If cPaisLoc <> "BRA"
		aPgtos[nLinha][11] := nPosMoeda
	EndIf
	If lUsaTef .AND. lTefMult .AND. !Empty(cDigCart)
		aPgtos[nLinha][12] := cDigCart
	EndIf
	If cPaisLoc == "BRA"
		If nNumParc > 1
			nValParcela	:= NoRound((nValMax-nValParc)/(nNumParc-1), 2)
			nDif		:= (nValMax-nValParc) - (nValParcela * (nNumParc-1))
			For nI := nLinha+1 To nLinha+(nNumParc-1)
				aPgtos[nI][2] := nValParcela
			Next nI
			aPgtos[nLinha+(nNumParc-1)][2] += nDif
		EndIf
	Else
		If nNumParc > 1
			//Converte o valor da parcela para a moeda corrente.
			nValParcAux := Round(xMoeda(nValParc,nPosMoeda,nMoedaCor,dDataBase,;
			                     nDecimais+1,,nTaxaMoeda),nDecimais)

			//Realiza o calculo de qual vai ser o valor das parcelas.
			nValParcela	:= Round((nValMax-nValParcAux)/(nNumParc-1), MsDecimais(nPosMoeda))
			nDif		:= (nValMax-nValParcAux) - (nValParcela * (nNumParc-1))

			//Converte o valor da diferenca para a moeda da parcela a
			//qual ela sera somada.
			nDif        := Round(xMoeda(nDif,nMoedaCor,aPgtos[nLinha+(nNumParc-1)][11],dDataBase,;
			                     MsDecimais(aPgtos[nLinha+(nNumParc-1)][11])+1,nTaxaMoeda),;
			                     MsDecimais(aPgtos[nLinha+(nNumParc-1)][11]))

			For nI := nLinha+1 To nLinha+(nNumParc-1)
				aPgtos[nI][2] := nValParcela
			Next nI
			aPgtos[nLinha+(nNumParc-1)][2] += nDif
		EndIf
		nCtrl   := AScan(aFormCtrl, {|x| ((IsMoney(cForma) .OR. cForma == cSimbCheq) .AND. (x[1] == cForma)) .OR. ((x[1] == cForma) .AND. (x[2] == AllTrim(cDesc))) })
		nValAux	:= nVlrTotal
		For nI := 1 To Len(aFormCtrl)
			If nI <> nCtrl
				nValAux -= Round(xMoeda(aFormCtrl[nI][7],aFormCtrl[nI][8],nMoedaCor,dDataBase,nDecimais+1,,nTaxaMoeda),nDecimais)
			EndIf
		Next nI
		nValAux := Round(xMoeda(nValAux,nMoedaCor,nPosMoeda,dDataBase,MsDecimais(nPosMoeda)+1),MsDecimais(nPosMoeda))
		If Len(aCProva) == Len(aFormCtrl)
		    //Acerta os dados do array aCProva...
			aCProva[nCtrl][1] := nValParc
			aCProva[nCtrl][2] := nPosMoeda
			aCProva[nCtrl][3] := nValAux
			aCProva[nCtrl][4] := aMoeda[nPosMoeda]
			aCProva[nCtrl][5] := (aCProva[nCtrl][1] < aCProva[nCtrl][3])
		Else
			AAdd(aCProva,{nValParc,nPosMoeda,nValAux,aMoeda[nPosMoeda],(nValParc < nValAux)})
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcular datas de Vencimento para as próximas parcelas se houve alteração   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nNumParc > 1 .AND. nDias > 0
		For nI := 1 To nNumParc
			If nI == 1
			   nIntervalo := 0
			Else
				nIntervalo += nDias
			EndIf
			cE4Cond := cE4Cond + StrTran(Str(nIntervalo,3)," ","0") + Iif( nI == nNumParc, "" , "," )
		Next nI
	EndIf

   	If  Len(aPgtos) > 0	.AND. !Empty(cE4Cond) .AND. aPgtos[nLinha][3] $ _FORMATEF .AND. ;
   	    aPgtos[nLinha][1] <> dDataAnt
		aSE4  	:= { 	"CN "	, cE4Cond, "1", "D ", ;
						" "		, " " }
   	    aDatas  := Condicao(nVlrTotal, NIL, NIL, dDataParc, ;
   	    					NIL, NIL, aSE4, NIL )
		cFormAtu:= aPgtos[nLinha][3]
		cDigAtu := aPgtos[nLinha][12]
   		For nFor:= nLinha To Len(aPgtos)
			If (cFormAtu <> aPgtos[nFor][3]) .OR. (Alltrim(cDigAtu)<>Alltrim(aPgtos[nFor][12]))
				Exit
			Else
				aPgtos[nFor][1]    := aDatas[nFor][1]
			EndIf
   		Next nFor
   	EndIf

	oPgtos:SetArray(aPgtos)
	oPgtos:Refresh()

	If lVisuSint
		aPgtosSint:=Fr271IMontPgt(@aPgtos, @nMoedaCor)
		oPgtosSint:SetArray( aPgtosSint )
		oPgtosSint:Refresh()
	EndIf

EndIf
FRTSetKey(aKey)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271HVlParºAutor ³ Vendas Clientes    º Data ³  26/09/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a validacao dos valores (formas de pagamento) antes     º±±
±±º          ³de fechar a venda.                                          º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HVlPar(	nVlrTotal	, aPgtos	, nMoedaCor	,;
						nDecimais	, nTaxaMoeda )
Local nValAux := 0
Local nI	  := 0		//variavel do loop
Local lRet    := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
Local nVlTotNCC := nVlrTotal + Abs(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA"))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o valor total no aPgtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aPgtos)
	If cPaisLoc == "BRA"
		nValAux += aPgtos[nI][2]
	Else
		nValAux += Round(xMoeda(aPgtos[nI][2],Int(aPgtos[nI][11]),nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),nDecimais)
	EndIf
Next nI

nValAux += Abs(Frt060Ret("NCC_USADA") - Frt060Ret("NCC_GERADA"))

If cPaisLoc == "BRA"
	If Round(nValAux, nDecimais) < Round(nVlTotNCC,nDecimais)
  		If lUsaDisplay
  			DisplayEnv(StatDisplay(), "1E"  + STR0018 + Str(nVlrTotal,8,2) + " " + STR0019 + Str(nVlrTotal - nValAux,8,2) )         //"Total: "    ""Saldo: ""
		EndIf
		lRet := .F.
	Else
  		If lUsaDisplay
  			DisplayEnv(StatDisplay(), "1E"  + STR0018 + Str(nVlrTotal,8,2) + " " + STR0019 + Str(nVlrTotal - nValAux,8,2) )         //"Total: "    ""Saldo: ""
			DisplayEnv(StatDisplay(), "2C"  + Substr(STR0020,1, 17) )         //"PRESSIONE <F9> P/ FECHAR A VENDA"
			DisplayEnv(StatDisplay(), "3C"  + Substr(STR0020,19 ) )         //"PRESSIONE <F9> P/ FECHAR A VENDA"
		EndIf
	Endif
Else
	If (nValAux < Round(nVlTotNCC,nDecimais)) .AND. (Round(nVlTotNCC-nValAux,nDecimais) > (1/(10**nDecimais)))
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271HProdºAutor  ³ Vendas Clientes    º Data ³  06/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Caso o produto tenha multiplos. Será Efetuado um calculo   º±±
±±º          ³ para obtenção de um novo preco unitario de venda.          º±±
±±º          ³ Exemplo: Se o produto foi configurado com BI_MULT igual a 3º±±
±±º          ³ e o seu preço unitário eh: 10,00. O preço "rateado" será:  º±±
±±º          ³ 1o. Item custara: 3,34                                     º±±
±±º          ³ 2o. Item custara: 3,33                                     º±±
±±º          ³ 3o. Item custara: 3,33                                     º±±
±±º          ³ Observe que o resto foi adicionado ao 1o. Item...          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HProdMult(	_nVlrUnit	, _nItem		, _nMaxElem	, cCodProd	,;
								_aMult		, _aMultCanc 	)


Local _nId
Local _nTotQtde := 0

Local _nMod
Local _nPos
Local _aRetorno
Local _lContinua
Local _nTmpQuant := 1
Local lItem

cCodProd   := SBI->BI_COD
_lContinua := .T.
lItem := If(_nItem =1,.T.,.F.)
If lItem
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for o 1o.Item... Zera a Quantidade.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _nId = Nil
	   _nId := 1
	EndIf
    If Len(_aMult)>0
       _aMult := {}
    EndIf
    If Len(_aMultCanc)>0
       _aMultCanc := {}
    EndIf
EndIf

If _lContinua
	If _nVlrUnit > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto jah existe no array (aMult)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nPos := 0
		If Len(_aMult) > 0
			_nPos := Ascan(_aMult,{ |x| x[1] == SBI->BI_COD .AND. x[3] = _nId })
		Else
			_nId := 1
		EndIf

		If _nPos == 0
			aadd(_aMult,{ SBI->BI_COD , 0 , _nId })
			_nPos	:= Len(_aMult)
		EndIf
		AAdd(_aMultCanc,{ SBI->BI_COD , 0 , _nId, _nItem })

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua o cálculo para os Itens múltiplos...                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		_aMult[_nPos][2] += _nTmpQuant
		_nTotQtde        += _nTmpQuant
		_nVlr2           := (_nVlrUnit * _nTmpQuant)
		_nMod            := Mod(_nVlr2, SBI->BI_MULT)

		If Mod(_nvlr2*100,SBI->BI_MULT) >= _aMult[_nPos][2]
			_nVlrUnit := NoRound(_nVlr2/SBI->BI_MULT) + 0.01
		Else
			_nVlrUnit := NoRound(_nVlr2/SBI->BI_MULT)
        EndIf

		If _aMult[_nPos][2] = SBI->BI_MULT
			_aMult[_nPos][2] := 0
			_nId++
		EndIf

		_aRetorno := {1,_nVlrUnit,cCodProd}
		SBI->(DbSeek(XFilial("SBI")+cCodProd))

		If (_nTotQtde == _nMaxElem)
			_nTotQtde := 0
			If (_aMult[_nPos][2] <> SBI->BI_MULT)
				_nId++
			EndIf
		EndIf
	Else
		_aRetorno := {}
	Endif
Else
	_aRetorno := {}
Endif
Return(_aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271HCanPºAutor  ³ Vendas Clientes    º Data ³  06/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Caso o produto tenha multiplos. Será adicionado ao array   º±±
±±º          ³ _aMultCanc os dados do Item vendido com um Identificador.  º±±
±±º          ³ Pois bem, esta função, tem como objetivo, localizar os     º±±
±±º          ³ Itens que possuam o mesmo identificador.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HCanP( aCancItens	, _aMultCanc )
Local _nPos    := 0
Local _nId     := 0
Local aRetorno := {}
Local ny			//variavel do loop

If Len(_aMultCanc) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza os Itens Múltiplos com o mesmo Identificador...    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 To Len(aCancItens)
		_nPos := Ascan(_aMultCanc,{ |x| x[4] = aCancItens[nY] })
		If _nPos <> 0
	 		_nId := _aMultCanc[_nPos][3]
			aEval(_aMultCanc,{|x,y| if(_aMultCanc[y][3] = _nId,aAdd(aRetorno,_aMultCanc[y][4]),'')})
		EndIf
	Next nY
EndIf
Return(aRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HLast³ Autor ³  Vendas Clientes      ³ Data ³06/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar o Numero do Ultimo Item do Cupom.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271HLastIT(aItens)

Local nRet:=0
If Len(aItens)>0
	nRet := ATail(aItens)[AIT_ITEM]
EndIf
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271HGeraºAutor  ³ Vendas Clientes    º Data ³  01/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o array com os dados dos impostos incidentes em um    º±±
±±º          ³ determinado produto                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HGeraImp( aImposto	, aInfo		, nValImp	, nQuant, ;
					 	nVlrUnit	, nX   		, cIndImp	, nDecimais )

Local cCpoVlrItem := ""
Local cCpoBaseIte := ""
Local cCpoVlrCab  := ""
Local cCpoBaseCab := ""
Local cCpoBas     := "IT_BASEIV"+cIndImp
Local nValBas     := Round(MaFisRet(nX,cCpoBas),nDecimais)

cCpoVlrItem := "L2_"+Subs(aInfo[2],4,7)   //Campo de gravacao do valor do imposto no item
cCpoBaseIte := "L2_"+Subs(aInfo[7],4,7)   //Campo de gravacao da base do imposto no item
cCpoVlrCab  := "L1_"+Subs(aInfo[6],4,7)   //Campo de gravacao do valor do imposto no cabecalho
cCpoBaseCab := "L1_"+Subs(aInfo[8],4,7)   //Campo de gravacao da base do imposto no cabecalho

aImposto := {}                   //Limpa o array para que armazene somente os
							      //dados do imposto que está sendo calculado

AAdd( aImposto, aInfo[1] )       //Codigo do imposto
AAdd( aImposto, aInfo[9] )       //Aliquota do imposto
AAdd( aImposto, nValBas )        //Base do Imposto
AAdd( aImposto, nValImp  )                         //Valor do imposto
AAdd( aImposto, aInfo[4] + aInfo[3] + aInfo[5] )   //FC_INCDUPL/FC_INCNOTA/FC_CREDITA
AAdd( aImposto, cCpoVlrItem )
AAdd( aImposto, cCpoBaseIte )
AAdd( aImposto, cCpoVlrCab )
AAdd( aImposto, cCpoBaseCab )
AAdd( aImposto, {1,-1,0} )
AAdd( aImposto, nQuant )
AAdd( aImposto, nVlrUnit )

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HCalc³ Autor ³ Vendas Clientes       ³ Data ³23/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe o total da venda em todas as moedas do sistema.      ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271HCalcVen( nVlrTotal	, nMoedaCor	, nTaxaMoeda)

Local aPreco    := {}
Local aLabel    := {}
Local nValMoeda := 0
Local nX        := 0
Local nDecs	    := 0

For nX	:=	1 To MoedFin()
	If(!(Empty(&("MV_MOEDA"+STR(nX,1)))))
		AAdd(aLabel,STR0009+AllTrim(&("MV_MOEDA"+STR(nX,1)))+":")  //"Total em "
	Endif
Next nX

For nX := 1 To Len(aLabel)
	nDecs := MsDecimais(nX)
	nValMoeda  := Round(xMoeda(nVlrTotal,nMoedaCor,nX,dDatabase,nDecs+1,nTaxaMoeda),nDecs)
   	AADD(aPreco,nValMoeda)
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Frtx272T05( @aLabel	, @aPreco )

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HTRCM³ Autor ³ Vendas Clientes       ³ Data ³23/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite ao usuario trocar a moeda padrao da venda.         ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271HTRCMoeda( nMoedaCor	, cMoeda	, oMoedaCor	, nDecimais	,;
				  			oTaxaMoeda	, cSimbCor	, oTemp3	, oTemp4  	,;
				  			oTemp5		, aItens	, aMoeda	, aSimbs )

Local nOpc      := 0
Local cMoedaVen
Local nPosMoeda := 1

Local nTaxaVen  := 1

If !Empty(aItens)
	HELP(' ',1,'FRT044') // "A moeda não pode ser alterada, pois ja foi realizada venda."
	Return
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄZZ¿
	//³Faz a chamada da tela que permite ao usuario trocar a moeda padrao da venda       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Frtx272T06(	@cMoedaVen	, @aMoeda	,  @nTaxaVen	, @nPosMoeda	,;
				@nOpc )

	If nOpc == 1
		nMoedaCor := nPosMoeda
		cMoeda    := cMoedaVen
		oMoedaCor:Refresh()

		nDecimais := MsDecimais(nMoedaCor)

		If nPosMoeda == 1
			nTaxaMoeda := 1
		Else
			nTaxaMoeda := nTaxaVen
		EndIf
		oTaxaMoeda:Refresh()

		cSimbCor  := AllTrim(SuperGetMV("MV_SIMB"+Str(nPosMoeda,1)))
		oTemp3:Refresh()
		oTemp4:Refresh()
		oTemp5:Refresh()
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HSL2GRV ³ Autor ³ Vendas Clientes       ³ Data ³23/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o arquivo SL2 quando eh atribuido um                 ´±±
±±³          ³ desconto no total da venda.                                   ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FR271HSL2GRV( aSL2, cOrcam )

Local nI		:= 0													// Contador de For
Local nX		:= 0													// Contador de For
Local nIndSL2   := 0													// Indice SL2
Local nRegSL2	:= 0													// Registro SL2
Local nPosItem  := aScan(aSL2[Len(aSL2)],{|x| Trim(x[1])=="L2_ITEM"})	// Posicao Item

DbSelectArea("SL2")
nIndSL2 := IndexOrd()
nRegSL2 := RecNo()
dbSetOrder(1)
For nI := 1 To Len(aSL2)
	DbSeek(xFilial("SL2")+cOrcam+aSL2[nI][nPosItem][2])
	RecLock("SL2",.F.)
	For nX := 1 To Len(aSL2[nI])
		FieldPut(ColumnPos(aSL2[nI][nX][1]), aSL2[nI][nX][2])
    Next nX
	dbCommit()
	MsUnLock()
Next nI
DbSetOrder(nIndSL2)
dbGoTo(nRegSL2)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FR271HCarrºAutor  ³Vendas Clientes      º Data ³  31/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar e carregar o orcamento selecionado.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpO1: Objeto DIALOG                                        º±±
±±º          ³ ExpC2: Numero do Orcamento                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Front Loja                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271HCarrega(	oDlg		, cNumOrc		, cCodProd		, oTimer		,;
						oHora		, cHora			, oDoc			, cDoc			,;
						oPDV		, cPDV			, nLastTotal	, nVlrTotal		,;
						nLastItem	, nTotItens		, nVlrBruto		, oVlrTotal		,;
						oCupom		, oTotItens		, oOnOffLine	, nTmpQuant		,;
						nVlrItem	, nValIPIIT		, nValIPI		, oFotoProd		,;
						oProduto	, oQuant		, oVlrUnit		, oVlrItem		,;
						oDesconto	, cSimbCor		, cOrcam		, cProduto		,;
						nQuant		, cUnidade		, nVlrUnit		, oUnidade 		,;
						lF7			, lOcioso		, lRecebe		, lLocked		,;
						lCXAberto	, lDescIT		, nVlrDescTot	, aItens		,;
						aICMS		, nVlrMerc		, _aMult		, _aMultCanc	,;
						lOrc		, aParcOrc		, cItemCOrc		, aParcOrcOld	,;
						lAltVend	, lImpNewIT		, lFechaCup		, cContrato		,;
						aCrdCliente	, aContratos	, aRecCrd		, aTEFPend		,;
						aBckTEFMult	, cCodConv		, cLojConv		, cNumCartConv	,;
						uCliTPL		, uProdTPL		, lDescTotal	, lDescSE4		,;
						aVidaLinkD	, aVidaLinkc 	, nVidaLink		, cCdPgtoOrc	,;
						cCdDescOrc	, nValTPis		, nValTCof		, nValTCsl		,;
						lOrigOrcam	, lVerTEFPend	, nTotDedIcms 	, lImpOrc		,;
						nVlrPercTot	, nVlrPercAcr	, nVlrAcreTot	, nVlrDescCPg	,;
						nVlrPercOri	, nQtdeItOri	, nNumParcs		, aMoeda		,;
						aSimbs		, nMoedaCor		, nDecimais	 	, aImpsSL1		,;
						aImpsSL2	, aImpsProd		, aImpVarDup	, aTotVen		,;
						aCols		, nVlrPercIT	, cVendLoja		, aParcOrcOld	,;
						oMensagem	, oFntMoeda		, cMensagem		, cEntrega		,;
						aReserva	, lReserva		, lAbreCup		, oNumOrc		,;
						nValor		, cCliente		, cLojaCli		, cNumOrig		,;
						cCupom		, cTipoCli		, lDescITReg	, cNumDAV		,;
						cOrigem		, cDocFo		, oTemp3		, oTemp4		,;
						oTemp5		, nTaxaMoeda	, oTaxaMoeda	, cMoeda		,;
						oMoedaCor	, nVlrFSD		, aMostruario	)

Local cRet			:= ""												// Retorno de String
Local xOrc																// Orcamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O parametro MV_LJDTORC definira o ajuste das datas do orcamento, sendo:    ³
//³ "N" - Nunca Ajusta as datas, ou seja, sempre a que foi gravada             ³
//³ "S" - Sempre Ajusta as datas, ou seja, Atualiza a data baseado no dia atual³
//³ "P" - Pergunta, ou seja, fara uma pergunta se deseja ajustar as datas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cLJDTORC		:= SuperGetMV( "MV_LJDTORC" )						// Conteudo do parametro MV_LJDTORC
Local nI			:= ""												// Variavel do loop	//Variavel de apoio
Local aRet			:= {}												// Array de retorno
Local lLJDTORC		:= .F.												// Logico do Mv_LjdTorc
Local dDataParc															// Data de parcelamento
Local cCondPgto		:= ""												// Codigo da condicao de pagamento gravada no orcamento
Local lRet			:= .F.												// Controla o retorno da pergunta de confirmacao da importacao do orcamento
Local lVerEmpres	:= Lj950Acres(SM0->M0_CGC)							// Verifica as filiais da trabalharam com acrescimento separado
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local lFRTMLTOC		:= FindFunction("U_FRTMLTOC")						// Ponto de entrada para validar a importação do orçamento da retaguarda
Local lFRTORCRT		:= FindFunction("U_FRTORCRT")						// Ponto de entrada para manipular os dados importados do orçamento da retaguarda
Local lRetMltorc	:= .F.												// Controla o retorno do P.E. para validar a importação do orçamento da retaguarda
Local lFRMULTORC	:= SuperGetMV("MV_LJMLTOC", ,.F.)					// Identifica se deve fechar automaticamente a tela de "Carregamento de Orçamentos"
Local lMultOrc		:= .F.												// Verifica se e' multiplos orcamentos
Local nL1NUM		:= TamSX3("L1_NUM")[1]								// L1_NUM
Local aRetOrcRt		:= {}												// Retorno de ponto de entrada
Local aBnt			:= {}												// Array de botoes
Local nSelected		:= 0												// Botao selecionado
Local lL1_NumOrc	:= (SL1->(FieldPos("L1_NUMORC")) > 0)
Local lPreVend		:= SuperGetMv("MV_LJPRVEN",,.T.)
Local nTamB1_COD	:= TamSX3("B1_COD")[1]								// Tamanho do campo B1_COD
Local lDav			:= .F.												// Indica se e DAV
Local nMvFrtImp		:= SuperGetMV("MV_FRTIMP",,1)
Local nTotalCF		:= 0												// Total do cupom fiscal (diferente do total da NF)
Local lLegOK		:= .F.												// Legislacao esta OK ?
Local lExLegSP10	:= FindFunction("Lj950SP10OK")						// Verifica a existencia da funcao que valida a legislacao paulista que limita o cupom fiscal em 10.000,00
Local nDescOrc		:= 0												// Desconto no total do orçamento
Local lImpDesc	 	:= SuperGetMv("MV_LJIPDES",,.F.)					//Define o tratamento para desconto na importacao do orçamento
Local cVendido		:= ""												// Sinaliza se item deve ser cancelado logo apos impressao, regra do PAF-ECF
Local lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC)							// Sinaliza que Ambiente PAF-ECF
Local lGE 		    :=  FindFunction("LjUP104OK") .AND. LjUP104OK(.T.)  // Validação do Conceito Garantia Estendida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Cartao Fidelidade³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cNumCFid		:=	""												//Numero do cartao fidelidade utilizado como forma de pagamento da venda.
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()	//Indica se a recarga de cartao fidelidade esta ativa
Local lMultiOrc    	:= SuperGetMv("MV_LJMLTOR", ,.T.)					// verifica a configuração para importação de mais de um orçamento no Front Loja
Local lCmpSL1		:= ExistFunc("LjUpd90Ok") .AND. LjUpd90Ok(.T.)
Local lImpIntFs     := SuperGetMV("MV_LJINTFS",.F.,.F.) .AND. lCmpSL1 //Integracao com o financial services esta habilitadal service
Local cOrcRes		:= "" 												// Codigo do orcamento da reserva
Local cPedRes		:= "" 												// Codigo do pedido da reserva
Local lCFRetPos 	:= .F.												// Indica se faz somente a impressao do Cupom Fiscal devido ser uma finalizacao de venda com itens de "RETIRA POSTERIOR"
Local cDAVPV  		:= ""												// Numero do DAV ou Pre Venda
Local lItemImp		:= .T.												// Indica se o item pertence a um orcamento importado
Local lLjNCCOr		:= SuperGetMv("MV_LJNCCOR", Nil, .F.)  //verifica se a NCC sera mantida no orcamento (F4)
Local lItemRegEcf	:= .F.												// Controle de registro de item no ECF
Local lCompleto		:= .F.
Local nProtec		:= 1
Local lErRegItem	:= .F.
Local lMultNeg		:= cPaisLoc == "BRA" .And. SuperGetMV("MV_LJMULTN",,.F.) //.And. SuperGetMV("MV_LJICMJR",,.F.) //Juros de acrescimo fin. separado da parcela
Local lNewImpOrc	:= .F.	//Se foi realizado mais de uma importação
Local nNewAcres		:= 0	//Acrescimo (frete) do novo orçamento.
Local lEmitNFCe		:= ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe()	//Indica a utilizacao da NFC-e
Local lCancCupAll	:= .F.
Local aItensInvalid := {} 
Local cMsg := '' 
Local nCont := 0 
Local nTroco			:= 0

DEFAULT lF7			:= .F.
DEFAULT cTipoCli	:= ""
DEFAULT cNumDAV		:= ""
DEFAULT cCodProd	:= Space(nTamB1_COD)
DEFAULT lCXAberto	:= .T.
DEFAULT aParcOrc	:= {}
DEFAULT cOrigem		:= ""
DEFAULT cDocFo		:= ""												//Numero do documento fiscal informado no inicio da venda - Release 11.5 - Controle de Formularios
DEFAULT nVlrTotal	:= 0												// Total da venda
DEFAULT oTemp3		:= cSimbCor
DEFAULT oTemp4		:= cSimbCor
DEFAULT oTemp5		:= cSimbCor
DEFAULT nTaxaMoeda	:= 	1
DEFAULT oTaxaMoeda	:= nTaxaMoeda
DEFAULT cMoeda		:= ""
DEFAULT oMoedaCor		:= cMoeda
DEFAULT nVlrFSD		:= 0
DEFAULT aMostruario	:= {"N",""}

//Zera o Valor da NCC Importada no orçamento
Fr271SNCCO(0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Limpa array de impressao da Garantia antes de um novo carregamento
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGE .AND. Len(LjGetGarant()) > 0
	// Zera garantia
	If ExistFunc("LjZGarant")
		LjZGarant()
	Else
		Conout("Versão do programa Frta271a não atualizada - LjZGarant()")
	EndIf
EndIf

//------------------------------------------------------------------
//Limpa as variaveis de controle referente a venda de Vale Presente
//------------------------------------------------------------------
If ExistFunc("Lj7VPNew") .And. Lj7VPNew()
	Lj7VPVdaVP(0)
	FrtSetItVP()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver na rotina de recebimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRecebe
	Return NIL
EndIf

//Valida quando PDV(PAF-ECF) se orçamento foi gerado em retaguarda PAF-ECF
If nVidaLink == 0 .And. LjNfPafEcf(SM0->M0_CGC) .AND. Empty(cNumDAV)
	MsgStop(STR0047 + cNumOrc + STR0048 ) //"Orçamento: " ### " não possui número de DAV ou Pré-Venda. Em ambiente PAF-ECF não é permitido importar Orçamento que não seja proveniente de um DAV ou Pré-Venda! Verifique se o ambiente que gerou o Orçamento esta habilitado para operar em modo PAF-ECF com DAV ou Pre-Venda."
	Return NIL
EndIf

If nVidaLink == 1  // Gravando VidaLink
	cRet := "OK"
	aRet := {"OK", "", { {"A1_COD", aVidaLinkC[VL_C_CODCL] }, {"A1_LOJA", aVidaLinkC[VL_C_LOJA] } } }		//No orcamento eh retornado algo como:  aRet := {"OK", cSL1+cSL2+cSL4, aSA1}
	lCompleto := .T.
Else
	While !lCompleto .AND. nProtec < 3
		nProtec++
		lCompleto := .T.
		//"Aguarde. Carregando o orcamento "
		If LjNfPafEcf(SM0->M0_CGC)
			If Empty(cNumDAV)
				xOrc := cNumOrc
			Else
				lDav := .T.
				xOrc := cNumDAV
			EndIf
			LJMsgRun( STR0010 + cNumOrc + "...", NIL, { || aRet := FR271CMyCall( "FR271CRPCLoad", { "SA1", "SL1", "SL2", "SL4" }, xOrc		, lDav	, cOrigem, Nil,  lImpIntFs, lGE, cPdv) } )
		Else
			LJMsgRun( STR0010 + cNumOrc + "...", NIL, { || aRet := FR271CMyCall( "FR271CRPCLoad", { "SA1", "SL1", "SL2", "SL4" }, cNumOrc	, Nil	, Nil, Nil, lImpIntFs, lGE, cPdv ) } )
		EndIf

		If Len(aRet) > 6
			nTotalCF := nVlrTotal + aRet[7]
		EndIf

		cRet := aRet[1]
		If nMvFrtImp == 1 .OR. (Left( cRet, 2 ) <> "OK")
			xOrc := aRet[2]
			If len(aRet) > 7			// Se possui a 8 posicao , confere se trouxe a string completa
				If Len(xOrc) <> aRet[8]
					lCompleto := .F.	// Nao trouxe todos os caracteres, vai tentar novamente
				EndIf
			EndIf
		Else
			xOrc := {aRet[4], aRet[5], aRet[6]}
		EndIf
		
		If lCompleto .AND. (Len(aRet) >= 4 .And. ((nMvFrtImp == 1 .AND. Len(aRet[4]) > 0) .OR. (nMvFrtImp == 2  .AND. Len(aRet[4]) == 0)))
			MsgStop(STR0063+CRLF+STR0064)				//"Formato dos dados de orçamento não estão de acordo com o esperado pelo parâmetro: MV_FRTIMP." ### ""(Verifique se os ambientes de PDV e Retaguarda possuem a mesma configuração)"
			cRet := "NOK"			 	
		EndIf 
		
		cRet := Trim( cRet )
	End
Endif

If !lCompleto	// Se nao importou corretamente, marca como nao OK
	cRet := "NOK"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validar a importação do orçamento da retaguarda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRTMLTOC
	lRetMltorc := U_FRTMLTOC(cNumOrc, aRet)
	If ValType( lRetMltorc ) == "L"
		If !lRetMltorc
			Return(NIL)
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para manipular o orçamento carregado da retaguarda  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFRTORCRT
	aRetOrcRt := U_FRTORCRT(aRet)
	If ValType( aRetOrcRt ) == "A"
		If Len(aRetOrcRt) == Len(aRet)
			cRet := aRetOrcRt[1]
			xOrc := aRetOrcRt[2]
			cRet := Trim( cRet )
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limitacao de 10.000,00 - Legislacao Paulista 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExLegSP10
	lLegOK := Lj950SP10OK(nTotalCF, 2, cCliente, cLojaCli)
Else
	lLegOK := .T.
EndIf

If lLegOK .AND. (Left( cRet, 2 ) == "OK" .OR. (LjNfPafEcf(SM0->M0_CGC) .AND. Left( cRet, 8 ) == "EXPIRADO" .AND. cOrigem == "LOJA160"))

	If (nVidaLink == 1) .OR. (nValor == 0)
		If Len(aVidaLinkD) == 0
			If cOrigem == "LOJA160"
				lRet := .T.
			Else
				If !(lL1_NumOrc)
					lRet := MsgYesNo(STR0011+cNumOrc+"?", STR0001) // "Confirma o carregamento do Orçamento " ### "?", "Atenção"
				Else
					cOrcRes	:= FR271CAField( xOrc, "L1_ORCRES" )	// Codigo do orcamento da reserva
					cPedRes	:= FR271CAField( xOrc, "L1_PEDRES" )	// Codigo do pedido da reserva
					lCFRetPos := Empty(cPedRes) .And. !Empty(cOrcRes) .And. FindFunction("Lj140ImpOrc") //Verifica se eh orcamento (com itens de RETIRA POSTERIOR) apenas para finalizacao (impressao do Cupom Fiscal)

					If lCFRetPos //Verifica se eh orcamento (com itens de RETIRA POSTERIOR) apenas para finalizacao (impressao do Cupom Fiscal)
						lRet := MsgYesNo(STR0052, STR0001) //"Confirma a impressão do cupom fiscal?"
					Else
						If !LjNfPafEcf(SM0->M0_CGC)
							lRet := MsgYesNo(STR0011 + cNumOrc + "?", STR0001) // "Confirma o carregamento do Orçamento " ### "?", "Atenção"
						Else
							lRet := MsgYesNo(STR0039+ If(lPreVend,STR0040,STR0041)+"?", STR0001) // "Confirma o carregamento " ### "?", "da Pre-Venda" "do DAV" "Atenção"
						EndIf
					Endif
				EndIf
	 	    EndIF
		Else
			If Len(aVidaLinkD) > 0
				lRet := MsgYesNo(STR0043, STR0001) // "Confirma a pré-venda Vidalink?"
				//Inicializa as variaveis PBM caso nao continue a operacao
				If !lRet
					aVidaLinkD := {}
					aVidaLinkc := {}
					nVidaLink  := 0
				Endif
		 	EndIf
		EndIf

		nSelected := 1
	Else
		//# "Somar na 1ª" # "Zerar" # "Canc.Import."
		aBtn := {STR0028,STR0029,STR0030}

		//# "Orçamento com Negociação." # "Foram registrados Itens antes da importação do orçamento."
		//# "Selecione uma das opções a seguir: Somar o total dos itens na primeira parcela, Zerar negociação ou Cancelar importação."
		If  !lMultiOrc
			// Colocado como opcao 3 para nao emitir cupom de mais de 1 prcamento
			MsgAlert(STR0038) //"Nao é permitido importacao de mais de 1 orçamento"
			nSelected := 3 //
		Else
			nSelected := Aviso(STR0025,STR0026 + CRLF + STR0027,aBtn,2)
			If nSelected == 1
				lNewImpOrc := .T.
			EndIf
		EndIf
		lRet := .T.
	Endif
	If lRet	.AND. (nSelected == 1 .OR. nSelected == 2 )

		//Faz apenas a impressao do cupom fiscal, pois se trata apenas de uma finalizacao de venda com itens de "RETIRA POSTERIOR"
		If lCFRetPos
			cDAVPV := FR271CAField(xOrc,"L1_NUMORC") // Numero do DAV ou Pre Venda
			//Executa procedimentos para realizar a impressao do Cupom Fiscal referente a venda com itens de "RETIRA POSTERIOR"
			LjMsgRun( STR0053,, { || Fr271PtOrc(cNumOrc,cDAVPV,lCFRetPos) } ) 	//"Aguarde ... imprimindo o cupom fiscal ...."
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a gravacao do SA1 caso nao exista ou algum campo foi alterado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aRet[3] ) > 0
				If ( nI := AScan( aRet[3], { |x| x[1] == "A1_COD" } ) ) > 0
					cCliente 	:= aRet[3][nI][2]
					nI			:= AScan( aRet[3], { |x| x[1] == "A1_LOJA" } )
					cLojaCli	:= IIF( nI == 0, Space( Len( SA1->A1_LOJA ) ), aRet[3][nI][2] )
					nI			:= AScan( aRet[3], { |x| x[1] == "A1_TIPO" } )
					cTipoCli	:= IIF( nI == 0, Space( Len( SA1->A1_TIPO ) ), aRet[3][nI][2] )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se Registro do SA1 no front nao existir ou conteudo de algum campo for diferente da retaguarda atualiza registro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lNovoCliente := IIF( SA1->( DbSeek( xFilial( "SA1" ) + cCliente + cLojaCli ) ), .F. , .T. )

					If CrdSa1Alte( aRet[3] )
						FR271BGeraSL( "SA1", aRet[3], lNovoCliente )
					EndIf
				EndIf
			EndIf

			//Se tem midia no orcamento carrega midia para variavel de memoria
			If AllTrim(Str(SuperGetMv("MV_LJRGMID",,0))) $ "1|2"
				If !Empty(FR271CAField( xOrc, "L1_MIDIA" ))
					M->L1_MIDIA := FR271CAField( xOrc, "L1_MIDIA" ) //SL1->L1_MIDIA
				Endif
			Endif

			//Recupera o numero do DAV, se ainda nao foi informado
			If nVidaLink == 0 .And. Len(aVidaLinkD) == 0 .And. LjNfPafEcf(SM0->M0_CGC) .AND. Empty(cNumDAV) 
				cNumDAV := FR271CAField( xOrc, "L1_NUMORC" )
			EndIf

			nDescOrc := 0

	        LjLogFront("FRTA271E - IMPORTACAO DE ORCAMENTO")
	        LjLogFront("FRTA271E - ORC IMPORTADO",xOrc)
			If nVidaLink <> 1
				nLastItem := FR271CQtdSL2(xOrc)
				For nI := 1 To nLastItem
					If nI <> 1 .And. lNewImpOrc
						lNewImpOrc := .F. //Para nao somar mais de uma vez
					EndIf
					lItemRegEcf := .F.
					lErRegItem := .F.

					//Verifica se o tipo de Peça (NORMAL, MOSTRUARIO, SALDÃO)
					if ValType(aMostruario) == "A" .And. Len(aRet) > 5 .And. Len(aRet[5]) > 0
						If Ascan(aRet[5][nI],{|x| Alltrim(Upper(x[1])) == "L2_VDMOST"}) > 0
							aMostruario[1] := aRet[5][nI][Ascan(aRet[5][nI],{|x| Alltrim(Upper(x[1])) == "L2_VDMOST"})][2]
						EndIf

						If Ascan(aRet[5][nI],{|x| Alltrim(Upper(x[1])) == "L2_VDOBS"}) > 0
							aMostruario[2] := aRet[5][nI][Ascan(aRet[5][nI],{|x| Alltrim(Upper(x[1])) == "L2_VDOBS"})][2]
						EndIf
					EndIf	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Registra Todos os Items³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FR271AProdOK( 	xOrc		, nI			, NIL			, .F.			,;
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
								@aTotVen		, @aCols		, @nVlrPercIT	, NIL			,;
								NIL				, NIL			, oMensagem		, oFntMoeda		,;
								@cMensagem		, @cTipoCli 	, NIL			, NIL			,;
								@cEntrega		, @aReserva 	, @lReserva		, @lAbreCup		,;
								/*nValor*/		, @cCupom		, /*cVndLjAlt*/	, /*cCliCGC */	,;
								/*aRegTEF*/		, /*lRecarEfet*/, @lDescITReg	, /*cGarant*/	,;
								/*cNSerie*/		, @cDocFo		,aMostruario, @lLegOk		,;
								@nDescOrc		, @cVendido		, lItemImp		, NIL			,;
								NIL				, NIL			, @lItemRegEcf 	, @lErRegItem	,;
								lNewImpOrc, @aItensInvalid	) // Registra todos os itens do VidaLink não passo xOrc

								//PAFECF: Verifica se Item foi cancelado enquanto orcamento e realiza o cancelamento
								If lLjNfPafEcf .AND. cVendido == "N" .And. lItemRegEcf

									FR271ECancIT( 	@oCupom		, @oVlrTotal	, @nVlrTotal		, @nVlrBruto		,;
													@nMoedaCor	, @nTotItens	, @oTotItens		, /*@oTmpQuant*/	,;
									 	 	 		@nTmpQuant	, /*@oCodProd*/	, /*@cCodProd*/		, /*@nTaxaMoeda*/	,;
									 	 			@cOrcam		, @lRecebe		, @aItens			, @_aMultCanc		,;
									 	  			@uCliTPL	, @uProdTPL		, @nTotDedIcms		, @aMoeda			,;
									 	  			@aImpsSL1	, @aImpsSL2		, @aImpsProd		, @aImpVarDup		,;
									 	  			@aTotVen	, @aCols		, /*@aHeader*/		, @lCXAberto		,;
									 	  			/*@nValor*/	, /*@aRegTEF*/	, /*@lRecarEfet*/	, /*@lCancItRec*/	,;
									 	  			@nVlrMerc	, nI			, .T. )
								EndIf

								If lErRegItem	.Or.( (nI == nLastItem) .and. (len(aItensInvalid)>0) )
								
									IF (nI == nLastItem)
										
										cMsg := ''
										  
										For nCont := 1 To Len(aItensInvalid)
											cMsg +=  AllTrim(aItensInvalid[nCont][2]) + ' - '+  AllTrim(aItensInvalid[nCont][3]) + chr(13)
										Next nCont	
										
										If len(cMsg)>0
											MsgStop( STR0061 +chr(13) +chr(13) +cMsg, STR0001) //TES de saída invalida, verifique o(s) produto(s) :
										EndIf
																				
									EndIf
										
									if lAbreCup
										lCancCupAll := .T.														
										While lCancCupAll
											FR271FCancCup(	.F.				, @oHora			, @cHora			, @oDoc				,;
															@cDoc			, @oCupom			, @cCupom			, @nVlrPercIT		,;
															@nLastTotal		, @nVlrTotal		,@nLastItem		, @nTotItens		,;
															@nVlrBruto		, @oDesconto		, @oTotItens		, @oVlrTotal		,;
															@oFotoProd		, @nMoedaCor		, @cSimbCor			, @oTemp3			,;
															@oTemp4			, @oTemp5			, @nTaxaMoeda		, @oTaxaMoeda		,;
															@nMoedaCor		, @cMoeda			, @oMoedaCor		, @cCodProd			,;
															@cProduto		, @nTmpQuant		, @nQuant			, @cUnidade			,;
															@nVlrUnit		, @nVlrItem			, @oProduto			, @oQuant			,;
															@oUnidade		, @oVlrUnit			, @oVlrItem			, @lF7				,;
															@cCliente		, @cLojaCli			, @lOcioso			, /*		*/		,;
															@nVlrDescTot	, @aItens			, @nVlrMerc			, @lFechaCup		,;
															/*			*/	, @cContrato		, @aCrdCliente		, @aContratos		,;
															@aRecCrd		, @aTEFPend			, @aBckTEFMult		, @cCodConv			,;
															@cLojConv		, @cNumCartConv		, @uCliTPL			, @uProdTPL			,;
															@aVidaLinkD		, @aVidaLinkc 		, @nVidaLink		, @lVerTEFPend		,;
															@nTotDedIcms	, @lImpOrc			, @nVlrPercTot		, @nVlrPercAcr		,;
															@nVlrPercOri	, @nQtdeItOri		, @nNumParcs		, @aImpsSL1			,;
															@aImpsSL2		, @aImpsProd		, @aImpVarDup		, @aTotVen			,;
															/*		*/		, @aCols			, /*		*/		, /*		*/		,;
															/*		*/		, @lCXAberto		, @oMensagem		, /*		*/		,;
															NIL				, NIL				, NIL				, NIL				,;
															NIL				, 					,			 		, NIL				,;
															NIL 			, @cMensagem		)
											If 	lEmitNfce
										
												If GetAPOInfo("FRTA271F.PRW")[4] >= Ctod("31/10/2016") 									
													lCancCupAll := FRTAFNfceAberta()
												Else
													lCancCupAll := .F.
												EndIf	
												
											Else	
												lCancCupAll := IFStatus(nHdlECF, '5', ) == 7
											EndIf	
																									
										End	
									EndIf
									lOrc 		:= .F.
									lImpOrc	:= .F.									
									lAbreCup  	:= .F.
									lErRegItem := .T.																		
									cCodProd := ''																	
									Exit
								EndIf
					nQtdeItOri++
				Next  nI
			Else
				For nI := 1 To LEN(aVidaLinkD[VL_DETALHE])
					cCodProd := aVidaLinkD[ VL_DETALHE, nI, VL_EAN ]
					FR271AProdOK( 	NIL				, nI			, NIL			, .F.			,;
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
									@nVidaLink 		, @nValTPis		, @nValTCof		, @nValTCsl		,;
									@lVerTEFPend	, @nTotDedIcms	, @lImpOrc		, @nVlrPercTot	,;
									@nVlrPercAcr	, @nVlrAcreTot	, @nVlrDescCPg	, @nQtdeItOri	,;
									@aMoeda			, @aSimbs		, @nMoedaCor	, @nDecimais	,;
									@aImpsSL1		, @aImpsSL2		, @aImpsProd	, @aImpVarDup	,;
									@aTotVen		, @aCols		, @nVlrPercIT	, NIL			,;
									NIL				, NIL			, oMensagem		, oFntMoeda		,;
									@cMensagem		, @cTipoCli		, NIL			, NIL			,;
									@cEntrega		, @aReserva 	, @lReserva		, @lAbreCup		,;
									/*nValor*/		, @cCupom		, /*cVndLjAlt*/	, /*cCliCGC */	,;
									/*aRegTEF*/		, /*lRecarEfet*/, @lDescITReg	, /*cGarant*/	,;
									/*cNSerie*/		, /*cDocFo*/	,aMostruario	, @lLegOk		,;
									@nDescOrc		, /*cVendido*/	, lItemImp		, NIL			,;
									NIL				, NIL			, @lItemRegEcf	, @lErRegItem	) // Registra todos os itens do VidaLink não passo xOrc)

					If lErRegItem .Or. ( (nI == nLastItem) .and. (len(aItensInvalid)>0) )
								
						IF (nI == nLastItem)
							
							cMsg := ''
							  
							For nCont := 1 To Len(aItensInvalid)
								cMsg +=  AllTrim(aItensInvalid[nCont][2]) + ' - '+  AllTrim(aItensInvalid[nCont][3]) + chr(13)
							Next nCont	
							
							If len(cMsg)>0
								MsgStop( STR0061 +chr(13) +chr(13) +cMsg, STR0001) //TES de saída invalida, verifique o(s) produto(s) :
							EndIf
																	
						EndIf
							
						if lAbreCup
							lCancCupAll := .T.														
							While lCancCupAll
								FR271FCancCup(	.F.				, @oHora			, @cHora			, @oDoc				,;
												@cDoc			, @oCupom			, @cCupom			, @nVlrPercIT		,;
												@nLastTotal		, @nVlrTotal		,@nLastItem		, @nTotItens		,;
												@nVlrBruto		, @oDesconto		, @oTotItens		, @oVlrTotal		,;
												@oFotoProd		, @nMoedaCor		, @cSimbCor			, @oTemp3			,;
												@oTemp4			, @oTemp5			, @nTaxaMoeda		, @oTaxaMoeda		,;
												@nMoedaCor		, @cMoeda			, @oMoedaCor		, @cCodProd			,;
												@cProduto		, @nTmpQuant		, @nQuant			, @cUnidade			,;
												@nVlrUnit		, @nVlrItem			, @oProduto			, @oQuant			,;
												@oUnidade		, @oVlrUnit			, @oVlrItem			, @lF7				,;
												@cCliente		, @cLojaCli			, @lOcioso			, /*		*/		,;
												@nVlrDescTot	, @aItens			, @nVlrMerc			, @lFechaCup		,;
												/*			*/	, @cContrato		, @aCrdCliente		, @aContratos		,;
												@aRecCrd		, @aTEFPend			, @aBckTEFMult		, @cCodConv			,;
												@cLojConv		, @cNumCartConv		, @uCliTPL			, @uProdTPL			,;
												@aVidaLinkD		, @aVidaLinkc 		, @nVidaLink		, @lVerTEFPend		,;
												@nTotDedIcms	, @lImpOrc			, @nVlrPercTot		, @nVlrPercAcr		,;
												@nVlrPercOri	, @nQtdeItOri		, @nNumParcs		, @aImpsSL1			,;
												@aImpsSL2		, @aImpsProd		, @aImpVarDup		, @aTotVen			,;
												/*		*/		, @aCols			, /*		*/		, /*		*/		,;
												/*		*/		, @lCXAberto		, @oMensagem		, /*		*/		,;
												NIL				, NIL				, NIL				, NIL				,;
												NIL				, 					,			 		, NIL				,;
												NIL 			, @cMensagem		)

								If 	lEmitNfce								
									If (GetAPOInfo("FRTA271F.PRW")[4] > Ctod("28/10/2016")) .Or.;
									 	(GetAPOInfo("FRTA271F.PRW")[4] == Ctod("28/10/2016") .And. GetAPOInfo("FRTA271F.PRW")[5] > "15:00:00") 									
										lCancCupAll := FRTAFNfceAberta()
									Else
										lCancCupAll := .F.
									EndIf									
								Else	
									lCancCupAll := IFStatus(nHdlECF, '5', ) == 7
								EndIf
							End
						EndIf

						lOrc 		:= .F.
						lImpOrc		:= .F.
						lAbreCup  	:= .F.
						lErRegItem	:= .T.	
						cCodProd	:= ''
						Exit
					EndIf
					nQtdeItOri++
				Next nI
			Endif

			If !lErRegItem

				nVlrPercIt 	:= 0
				_lOk 		:= .F.
				lOrc 		:= .F.
				If ValType(xOrc) == "C"
					cCondPgto	:= FR271CAField( xOrc, "L1_CONDPG" )
				EndIf
				If lLjNCCOr
					Fr271SNCCO(FR271CAField( xOrc, "L1_CREDITO" ))
				EndIf

				If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica existe a condicao de pagamento com ³
					//³acrescimo financeiro separado.              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SE4")
					DbSetOrder(1)
					If DbSeek(xFilial("SE4") + cCondPgto)
						If (SE4->E4_ACRSFIN > 0) .AND. (AllTrim(SE4->E4_FORMA) == "FI")
							If 	(ColumnPos("E4_AGRACRS") > 0 .AND. SE4->E4_AGRACRS == "2") .AND. ;
								(ColumnPos("E4_LIMACRS") > 0 .AND. SE4->E4_LIMACRS > 0)
								lOrigOrcam := .T.
								cCdPgtoOrc := cCondPgto
								cCdDescOrc := SE4->E4_DESCRI
						  		//"Este orçamento possui condição de pagamento com acréscimo financeiro, porém, não calculado. Carregue novamente o orçamento : "
						  		MsgAlert(STR0023 + AllTrim(cCdPgtoOrc) + " (" + Alltrim(cCdDescOrc) + ")")
						    EndIf
						EndIf
				    EndIf
				EndIf
				FR271AInitIT( .T.			, @lF7		, @cCodProd		, @cProduto,;
								@nTmpQuant	, @nQuant	, @cUnidade		, @nVlrUnit,;
								@nVlrItem	, @oProduto	, @oQuant		, @oUnidade,;
								@oVlrUnit	, @oVlrItem	, @oDesconto	, @cCliente,;
								@cLojaCli	 )

				FErase( Substr( cRet, 3, 8 ) )

				If nVidaLink <> 1
					If ( FR271CAField( xOrc, "L1_CONDPG" ) == "CN " ) .OR. ( SE4->( DbSeek( xFilial( "SE4" ) + FR271CAField( xOrc, "L1_CONDPG" ) ) ) )
						cLJDTORC := IIF( FR271CAField( xOrc, "L1_EMISSAO" ) == dDataBase, "N", cLJDTORC )

						If cCondPgto <> "CN" .AND. cLJDTORC $ "SP" //SL1->L1_CONDPG <> "CN" .AND. cLJDTORC $ "SP"
							lLJDTORC := .T.

							If cLJDTORC == "P"
								lLJDTORC := MsgYesNo( STR0012, STR0001 )  // "Deseja ajustar as datas das parcelas do orcamento, com base na data de hoje?", "Atenção"
							EndIf
						EndIf
						If Len(aParcOrc) == 0
							lMultOrc := .F.
						Else
							lMultOrc := .T.
						EndIf

						For nI := 1 To FR271CSL4Qtd( xOrc )
							If lLJDTORC
								dDataParc := dDataBase + ( FR271CAField( xOrc, "L4_DATA", nI ) - FR271CAFieldZ( xOrc, "L1_EMISSAO" ) )
							Else
								dDataParc := FR271CAField( xOrc, "L4_DATA", nI )
							EndIf


			                If (nSelected == 1)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Soma todas as parcelas para identificar Acrescimo³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								nValor += FR271CAField( xOrc, "L4_VALOR", nI )

					    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Relase 11.5                ³
								//³Venda com Cartao Fidelidade³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lLjcFid
									If AllTrim(FR271CAField( xOrc, "L4_FORMA", nI )) =="FID"
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
											MsgStop (STR0044)//"Cartao Fidelidade Invalido ! Altere a forma de pagamento ou informe outro cartao após a importação do orçamennto."
										Else
											Fa271FsFid(cNumCFid)
										Endif
									EndIf
								EndIf

		            	        If !lMultOrc
		            	        	If !Empty(AllTrim( FR271CAField( xOrc, "L4_FORMA", nI ) ))
										AAdd( aParcOrc, { 	dDataParc									,;
														IIf (nI == 1, nValor ,FR271CAField( xOrc, "L4_VALOR", nI ))		,;
														AllTrim( FR271CAField( xOrc, "L4_FORMA", nI ) )	,;
														FR271CAField( xOrc, "L4_ADMINIS", nI )			,;
														FR271CAField( xOrc, "L4_NUMCART", nI )			,;
														FR271CAField( xOrc, "L4_AGENCIA", nI )			,;
														FR271CAField( xOrc, "L4_CONTA", nI )			,;
														FR271CAField( xOrc, "L4_RG", nI )				,;
														FR271CAField( xOrc, "L4_TELEFON", nI )			,;
														FR271CAField( xOrc, "L4_TERCEIR", nI )			,;
														IIF( cPaisLoc <> "BRA", FR271CAField( xOrc, "L4_MOEDA", nI ), 1 ),;
														FR271CAField( xOrc, "L4_FORMAID", nI ),;
														IIF((lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")),IIF(SL4->(FieldPos("L4_ACRSFIN")) > 0,;
														FR271CAField( xOrc, "L4_ACRSFIN", nI),0),0) , "",;
														IIf(lMultNeg .And. SL4->(ColumnPos("L4_DESCMN")) > 0 ,FR271CAField( xOrc, "L4_DESCMN", nI),0) })
									EndIf
								Else
									aParcOrc	:= {}
								EndIf
							Else
								aParcOrc := {}
							EndIf


						Next nI

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³		Deduz valor do troco para vendas importadas	³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			          	nTroco := FR271CAField( xOrc, "L1_TROCO1" )
						If 	nTroco > 0 .And. nValor >= nTroco
				        	nValor -= nTroco
				       End  

						cItemCOrc   := FR271CAField( xOrc, "L1_CONDPG" )					// CONDICAO DE PAGAMENTO
						If !lImpDesc
							nVlrDescTot	+= FR271CAField( xOrc, "L1_DESCONT" )					// VALOR DO DESCONTO
							nVlrPercTot	+= FR271CAField( xOrc, "L1_DESCNF" )					// PERCENTUAL DE DESCONTO
						EndIf
						nVlrPercAcr += FR271CAField( xOrc, "L1_JUROS" )					// PERCENTUAL DE ACRESCIMO
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Somente se tiver escolhido para considerar a Condicao,caso contrario zera o desc e o acres da cond de pag³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						LjLogFront("FRTA271H - nSelected",nSelected)
						LjLogFront("FRTA271H - nValor",nValor)
						LjLogFront("FRTA271H - nVlrDescTot",nVlrDescTot)
						LjLogFront("FRTA271H - nTotDedIcms",nTotDedIcms)
						LjLogFront("FRTA271H - nVlrBruto",nVlrBruto)
						LjLogFront("FRTA271H - cItemCOrc",cItemCOrc)
						LjLogFront("FRTA271H - nVlrPercAcr",nVlrPercAcr)

						If nValor == 0 // Proteção para caso as parcelas nao serem importadas corretamente
							nValor :=  nVlrBruto  - nVlrDescTot - nTotDedIcms
						EndIf
											
		              	If (nSelected == 1)	
							If nValor + nVlrDescTot + nTotDedIcms > nVlrBruto
								//Pego o valor anterior para tirar a diferença do acrescimo para saber o acrescimo somente deste orçamento
								//Para casos de mais de uma importação com acrescimo (frete)
								nNewAcres := nValor + nVlrDescTot + nTotDedIcms - nVlrBruto				// VALOR DO ACRESCIMO
								
								//Acrescimo somente deste orçamento
								nVlrAcreTot := nVlrAcreTot + nNewAcres
								
							ElseIf nValor + nVlrDescTot + nTotDedIcms < nVlrBruto
								nVlrDescCPg := nVlrBruto - nValor - nVlrDescTot - nTotDedIcms				// VALOR DO DESCONTO FINANCEIRO
								// Caso esteja usando orcamento como NCC na Importacao, subtrai o valor da NCC para nao
								// haver erro de calculo e desconto.
								If lLjNCCOr
									nVlrDescCPg -= FR271CAField( xOrc, "L1_CREDITO" )
								EndIf
							EndIf
						Else	
							nVlrAcreTot := 0	
							nVlrDescCPg := 0
						EndIf	
				
						nNumParcs   := FR271CAField( xOrc, "L1_PARCELA" )					// NUMERO DE PARCELAS
						nVlrPercOri := nVlrPercTot                                      // PERCENTUAL DE DESCONTO ORIGINAL
						lImpNewIT   := .F.												// Indica se foi adicionado um novo item ao orcamento
						
						//Tratamento para incluir valor do frete na importacao do Orcamento
						nVlrTotal += nNewAcres
						nVlrBruto += nNewAcres 
						lCFrete   := .T. //Alterada flag de controle de frete para que nao inclua novamente
						
						If (lMultNeg .And. SL1->( FieldPos( "L1_CODMNEG" ) ) > 0 .and. !Empty(SL1->L1_CODMNEG) .and. aScan(aParcOrc ,{ |x| AllTrim(UPPER(x[3])) == "CC"}) > 0 )						
							oCupom:AppendText(("ACRES. MULTINEG : "+ Transform(nVlrAcreTot,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))+ chr(10) + chr(13)))    
						ElseIf nVlrAcreTot > 0 .And. nNewAcres > 0  
							oCupom:AppendText(("ACRESCIMO (FRETE) : "+ Transform(nVlrAcreTot,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))+ chr(10) + chr(13)))
						EndIf
							oCupom:Refresh()					
					Else                
						Help( " ", 1, "EF_CARGA" )
					EndIf
				Else
					aParcOrc := {}
					cLJDTORC := dDataBase
					lLJDTORC := .T.

					nValTot		:= aVidaLinkD[VL_TOTVEND]
					cCond		:= SPACE(3)
					nValIpi		:= 0
					dData0		:= ddatabase
					nValSolid	:= 0
					aImpVar		:= {}
					aE4			:= {"", "", "", "", "", ""  }
					nAcrescimo	:= 0

					DbSelectArea("SE4")
					DbSetOrder(1)
					DbSeek(xFilial("SE4")+cCond)

					aE4[1]	:= SE4->E4_CODIGO
					aE4[2]	:= SE4->E4_COND
					aE4[3]	:= SE4->E4_TIPO
					aE4[4]	:= SE4->E4_DDD
					aE4[5]	:= SE4->E4_IPI
					aE4[6]	:= SE4->E4_SOLID

					aVdLnkPar	:= Condicao( aVidaLinkD[VL_TOTVEND] , SE4->E4_COND, nValIpi, dData0, nValSolid,,,nAcrescimo)

					For nI := 1 To LEN(aVdLnkPar)
						dDataParc := aVdLnkPar[nI,1]
						nValor += aVdLnkPar[nI,2]			// Soma todas as parcelas para identificar Acrescimo

						// Elementos do array aParcOrc  Data da Parcela, L4_VALOR, L4_FORMA, L4_ADMINIS,L4_NUMCART, L4_AGENCIA, L4_CONTA, L4_RG, L4_TELEFON, L4_TERCEIR, L4_MOEDA, " "
						cFormaPagto := If( !Empty(SuperGetMV("MV_FORMPAD")),SuperGetMV("MV_FORMPAD"),SuperGetMV("MV_SIMB1"))
						AAdd(aParcOrc, {dDataParc,;				// Data
										aVdLnkPar[nI,2],;		// Valor
										"cFormaPagto" ,;		// Forma
										" ",;					// Administradora
										" ",;					// Num Cartao
										" ",;					// Agencia
										" ",;					// Conta
										" ",;					// RG
										" ",;					// Telefone
										"F",;					// Terceiro
										1  ,;					// Moeda
										" ",;					// Digitos do cartao para TEFMULT
										0  ,;					// Conceito de acrescimo financeiro separado
										"" } )                  // CPF\CNPG do Cheque
					Next nI
					cItemCOrc   := SE4->E4_CODIGO
					nVlrDescTot	:= 0					// VALOR DO DESCONTO
					nVlrPercTot	:= 0 					// PERCENTUAL DE DESCONTO
					nVlrPercAcr := 0 					// PERCENTUAL DE ACRESCIMO
					nVlrAcreTot := 0					// VALOR DO ACRESCIMO
					nVlrDescCPg := 0 					// VALOR DO DESCONTO FINANCEIRO
					nNumParcs   := len(aVdLnkPar)		// NUMERO DE PARCELAS
					nVlrPercOri := 0					// PERCENTUAL DE DESCONTO ORIGINAL
					lImpNewIT   := .F.					// Indica se foi adicionado um novo item ao orcamento
				EndIf
			EndIf
		EndIf
	EndIf

	If LjNfPafEcf(SM0->M0_CGC) .AND. cOrigem == "LOJA160"
		lFRMULTORC := .T.
	EndIF

	If !lTouch
	  If !lFRMULTORC
	  	oDlg:End()
	  Else
		  cNumOrc := Space(nL1NUM)
	  EndIf
 	EndIf

	If nVidaLink <> 1
	  If !lTouch
		  If !lFRMULTORC
		  	oDlg:End()  // Fecha janela orcamento
   		  EndIf
	  EndIf
	Else
  		nVidaLink := 2 // Jah Gravado VidaLink
 	Endif

ElseIf Left( cRet, 8 ) == "EXPIRADO"
	Help( " ", 1, "DTVALIDADE" )
ElseIf Left( cRet, 7 ) == "VENDIDO"
	Help( " ", 1, "VENDIDO" )
ElseIf Left( cRet, 8 ) == "NOTFOUND"
	// "O Orçamento " ### " não foi encontrado na Retaguarda.", "Atenção"
	MsgStop( IIF(lDav,STR0055 + cNumDAV,STR0013 + cNumOrc) + STR0014, STR0001 )
ElseIf Left( cRet, 11 ) == "JAIMPORTADO"
	// "O Orçamento "###" já foi importado da Retaguarda."
	MsgStop( STR0013+ xOrc + STR0037 , STR0001 )
ElseIf Left( cRet, 10 ) == "NOGEPDV"
	MsgStop( STR0051 , STR0001 ) //"PDV não implementado para Garantia Estendida"
ElseIf Left( cRet, 10 ) == "NOINTFSPDV"
	MsgStop( STR0049  , STR0001 ) //"PDV não implementado pára analise de credito do Financial Service"
ElseIf Left( cRet, 13 ) == "INTFSANCRDNAP"
	MsgStop( STR0050  , STR0001 )
ElseIf lLegOK
	// "Erro ao carregar o Orçamento " ### ". Tente novamente.", "Atenção"
	MsgStop(IIF(lDav,STR0055 + cNumDAV,STR0015 + cNumOrc) + STR0016, STR0001 )
Else
	MsgStop(STR0056) // "Não foi possivel importar o orçamento, por favor tente novamente."
EndIf

If Left( cRet, 2 ) <> "OK"
	If lFRMULTORC
		cNumOrc := Space(nL1NUM)
	EndIf
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FR271HCond³ Autor ³ Vendas Clientes       ³ Data ³15/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alteracao da Condicao de Pagamento (F5)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FR271HCondPag(	aCondicoes	, cItemForma	, nTmpJuros	, aPgtos	,;
						oPgtos		, nTmpDesc		, oCupom	, nMoedaCor		,;
						oVlrTotal	, nVlrBruto		, nVlrTotal	, nVlrDescTot	,;
						oPgtosSint	, aPgtosSint	, nEntrada 	, nTaxaMoeda	,;
						lRecebe		, dDataCN		, lEsc		, uCliTPL		,;
						uProdTPL	, lDescTotal	, lDescSE4	, nTotDedIcms	,;
						nVlrAcreTot	, nVlrDescCPg	, aFormCtrl	, cItemCond  	,;
						lCondNegF5	, nTxJuros		, nValorBase, lDiaFixo      ,;
						cCupom      , aItens		, lTefPendCS, aTefBkpCS		,;
						aVidaLinkD	, lImpOrc		, cOrcam    , _cCliente     ,;
						_cLojaCli, nValIpi)
Local cLine
Local nOldLen 		 := 0
Local nLen
Local nI 			:= 0 														// variavel do loop
Local nMidItem 		:= Round(Len(aCondicoes)/2,0)								// Item
Local cTmpCondPag	:= Space(TamSX3("E4_CODIGO")[1])							// Armazena temporario
Local aKey         	:= {}
Local aRet 			:= {}
Local nPerDescFi   	:= 0
Local nPerAcreFi	:= 0														//Percentual do acrescimo e desconto financeiro
Local cCondPag 		:= ""
Local lFrtCondPag 	:= ExistBlock( "FRTCONDPAG" ) 								// Se existe Ponto de Entrada
Local lTFrtCondPag  := ExistTemplate("FRTCONDPAG")  							// Verifica se existe o PONTO DE ENTRADA FRTCONDPAG
Local lTefMult	  	:= SuperGetMV("MV_TEFMULT", ,.F.)							// Identifica se o cliente utiliza múltiplas transações TEF
Local lVisuSint  	:= If(SL4->(ColumnPos("L4_FORMAID"))>0,.T.,.F.) 			// Indica se a interface utilizará a forma de visualização sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local cFormaId	  	:= If(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))	// Espaco do L4_FORMAID
Local nNumLinesCup 	:= 0
Local nTotGeral    	:= 0                            							// Total geral usado para calcular o valor do acrescimo financeiro
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local nDecimais  	:= MsDecimais(nMoedaCor)
Local aRetNeg		:= {}
Local lFRTACRES		:= ExistFunc("U_FRTACRES")								// Ponto de entrada adicionar valores para acrescimo financeiro
Local xRet	   		    														// Retorno do ponto de entrada FRTACRES
Local lAtuPgtos		:= .T.														// Indica se o retorno do ponto de entrada FRTPGTODP esta de acordo com a estrutura do array aPgtos
Local nX			:= 0														// variavel de loop
Local nAux          := 0                                                        // variavel auxiliar
Local oMultNegoc	:= Nil														// Variavel  de Multi Negociação
Local nFor			:= 0														// Contador
Local aRetPgto		:= {}                                                      	// Amazena informações de pagamento
Local cFrmMNeg		:= ""														// Forma de pagamento da multinegociacao
Local lMultNeg 		:= .F.														// Infor que encontrou Multi Neg
Local lVerVP       	:= .F.	                                                    // Verifica se é vale-presente
Local cFormaVP		:= ""														// Guarda a forma de pagamento para verificar se é Vale-Presente
Local lArray			:= .F.													//Verifica se a posição é um array

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a estacao possui Display ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))
Local cPicCondP     := "@!"					     								// Picture da condicao de pagamento.
Local lFrontNCC		:= ExistFunc("FRT060NCC")   								// Verifica se as funcoes de NCC para o Front estao compiladas
Local lFrtNCCMaior	:= .F.														// NCC maior
Local nPerDesc		:= 0
Local nValDesc 		:= 0
Local lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .And. RGVldTable()		//Validacao da Nova Regra de Desconto Ativa
Local nVlrFrtReta	:= 0														// Variavel que ira receber os Valores de Frete do Orcamento feito no Retaguarda
Local nDescMult		:= 0 								                        // Desconto concedido na Multinegociacao
Local nPosMoeda		:= 0                                                        // Posição moeda.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Localizacoes	   	³
//³Paises: Chile/Colombia  - F1CHI 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLocR5        := cPaisLoc$"CHI|COL"
Local nNCCUsada		:= 0			// Valor da Ncc Usada
Local nVlrParcelas	:= 0			// Valor das Parcelas
Local nAcreMn		:= 0			// Acres Multi Negociação

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis de verificacao de Limite Inferior e Superior da Condicao de Pagamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 			:= .T.			// Retorno da verificacao de limites
Local nLimSuper		:= 0			// Armazena Limite Superior da Condicao de Pagamento
Local nLimInfer		:= 0			// Armazena Limite Inferior da Condicao de Pagamento
Local lVerEmpres    := Lj950Acres(SM0->M0_CGC)													// Verifica as filiais que trabalham com acréscimo separados
Local nxValEnt 		:= 0 																		// Valor de entrada Multinegociação
Local nxValTot 		:= 0 																		// Valor total Multinegociação
Local nxQtdParc 	:= 0     																	// Quantidade de Parcelas Multinegociação
Local nxValParc		:= 0  																		// Valor das parcelas Multinegociação
Local nxDiff		:= 0                                                                        // Diferença Multinegociação
Local cBkCupom		:= cCupom		// Backup do cupom virtual antes das condicoes de pagamento
Default lTefPendCS	:= .F.
Default aTefBkpCS	:= {}
Default aVidaLinkD 	:= {}
Default lImpOrc		:= .F.
Default cOrcam      := ""
Default _cCliente	:= ""			// Cliente
Default _cLojaCli	:= ""			// Loja do Cliente
Default nValIpi		:= 0

//Se tiver subisidio na venda pbm, não deixa acionar o tecla F5
If lRecebe .OR. LjTemSubsi() .OR. Len(aVidaLinkD) > 0
	Return(NIL)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Caso seja Venda com Multinegociacao  nao permite acionar o F5 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lMultNeg .And. SL1->(ColumnPos("L1_CODMNEG")) > 0 .And. !Empty(SL1->L1_CODMNEG)) .And. !lrecebe
	Return(NIL)
EndIf

//Se tiver TEF pendente, não deixar acionar a tecla F5
If lTefPendCS .AND. Len(aTefBKPCS) > 0 .AND. SuperGetMV("MV_TEFPEND",,"0") <> "1"
	MsgAlert(STR0042) //"Não é possível informar novas condições de pagamento porque existe um cartão pendente. Por favor, informe a forma de pagamento do cartão inválido e finalize a venda."
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracao especifica para atender a legislacao do SEFAZ ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjAnalisaLeg(13)[1] .AND. Len(aFormCtrl) > 0
	// Nestes estados a legislacao nao permite este procedimento.
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao deste recurso.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTFrtCondPag
	cCondPag := ExecTemplate( "FRTCONDPAG", .F., .F.,{ uCliTPL,_cCliente,_cLojaCli } )
	IF cCondPag  = Nil
       	Return Nil
	Endif
    If Empty(cCondPag) // Se não colocarmos este bloco não irá solicitar a condição de pagamento
       lTFrtCondPag := .F.
    Endif
EndIf

If lFrtCondPag
	cCondPag := ExecBlock( "FRTCONDPAG", .F., .F. )
	IF cCondPag  = Nil
		Return Nil
	Endif
    If Empty(cCondPag) // Se não colocarmos este bloco não irá solicitar a condição de pagamento
       lFrtCondPag := .F.
    Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aKey := FRTSetKey()

If lFrontNCC
	If Frt060Ret("NCC_USADA") >= (Frt060Ret("NCC_USADA") + nVlrTotal)
		lFrtNCCMaior := .T.
		//"Não é possível escolhar a condição de pagamento, pois o total de NCC selecionada é maior que o total da venda. Finalize a venda via F9."
		MsgAlert(STR0024)
	EndIf
EndIf

// Para zerar os acrescimos financeiros
If nVlrAcreTot > 0 .Or. Frt060Ret("NCC_USADA") > 0  .OR. nVlrBruto >= nVlrTotal
	nVlrBruto := 0
	For nx:=1 to Len(aItens)
		IF !aItens[nx][AIT_CANCELADO]
		   nVlrBruto += aItens[nx][AIT_VLRITEM]
        EndIf
    Next
	nVlrBruto := (nVlrBruto + nValIpi) - IIf(Frt060Ret("NCC_USADA") > 0 ,Frt060Ret("NCC_USADA") ,0)
	nVlrTotal := nVlrBruto
EndIf

If !lFrtNCCMaior

	If !lFrtCondPag .AND. !lTFrtCondPag

		FR271IAddLine(	FRT_SEPARATOR	, @nNumLinesCup	, cPicCondP	, oCupom	,;
					@lEsc,@cCupom )
		FR271IAddLine( ""				, @nNumLinesCup	, cPicCondP	, oCupom	,;
					@lEsc,@cCupom )
		FR271IAddLine( STR0002			, @nNumLinesCup	, cPicCondP , oCupom	,;
					@lEsc,@cCupom )	// "         CONDIÇÕES DE PAGAMENTO         "
		FR271IAddLine( ""				, @nNumLinesCup	, cPicCondP	, oCupom	,;
					@lEsc,@cCupom )

		For nI := 1 To nMidItem
			cLine := Left(aCondicoes[nI],19)+"  "
			If nMidItem + nI <= Len(aCondicoes)
				cLine += Left(aCondicoes[nMidItem + nI],19)
			EndIf
			cTmpCondPag := FR271IAddLine( 	cLine, @nNumLinesCup, cPicCondP, oCupom	,;
										@lEsc,@cCupom )

			If !Empty(cTmpCondPag) .OR. lEsc
				Exit
			EndIf
		Next nI

		If Empty(cTmpCondPag) .AND. ! lEsc
			FrtGet(@cTmpCondPag, cPicCondP, @lEsc)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for Vale-Presente, não será tratado como opção válida, por não³
		//³se tratar de Condição de Pagamento e sim de Forma de Pagamento.	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+cTmpCondPag))
		cFormaVP := If(!Empty(SE4->E4_FORMA),SubStr(SE4->E4_FORMA,1,2),;
					If(!Empty(SuperGetMV("MV_FORMPAD")),;
						SuperGetMV("MV_FORMPAD"),;
						SuperGetMV("MV_SIMB1")))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os limites Inferiores e Superiores para             |
		//³ esta Condicao, e verifica se o valorbase esta entre os dois ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If SE4->E4_SUPER > 0 .Or. SE4->E4_INFER > 0
			nLimSuper:= SE4->E4_SUPER
			nLimInfer:= SE4->E4_INFER
			If nVlrTotal > nLimSuper .AND. nLimSuper <> 0
				Help(" ","1","LJLIMSUPER")
				lRet := .F.
			ElseIf nVlrTotal < nLimInfer .AND. nLimInfer <> 0
				Help(" ","1","LJLIMINFER")
				lRet := .F.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao estiver entre os limites Inferior e Superior retorna |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lRet
				Return(Nil)
			Endif
		Endif

		If Alltrim(cFormaVP) == "VP"
			lVerVP := .T.
			FR271IAddLine(FRT_SEPARATOR	, @nNumLinesCup, cPicCondP, oCupom, @lEsc, @cCupom )
			FR271IAddLine( ""			, @nNumLinesCup, cPicCondP, oCupom, @lEsc, @cCupom )
		 	FR271IAddLine( STR0045		, @nNumLinesCup, cPicCondP, oCupom, @lEsc, @cCupom ) //"Para o caso de Vale-Presente, utilize Forma de Pagamento ao invés de Cond. Pagamento."
		 	FR271IAddLine( ""			, @nNumLinesCup, cPicCondP, oCupom, @lEsc, @cCupom )
		EndIf

		lEsc := .F.
		If lUsaDisplay
			DisplayEnv(StatDisplay(), "2C" + Upper(STR0021)	)   //"Escolha a condicao de pagamento"
		EndIf

	Else
		cTmpCondPag := cCondPag
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada apos a seleção da condição de pagamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistFunc("U_FRTPAGTO")
		U_FRTPAGTO(@nVlrTotal,@cTmpCondPag,@nVlrDescTot,aPgtos)
	EndIf

	// Soma os valores do Frete ao Valor Bruto e retorna no aRet já com Valor do Frete
	nVlrFrtReta := 0
	nVlrFrtReta	:= SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA

	nVlrBruto += nVlrFrtReta

	If cPaisLoc == "MEX" .And. SuperGetMv("MV_DESCSAI", Nil, "1") == "2"
		nVlrBruto -= nVlrDescTot
	EndIf


	If (nI := AScan(aCondicoes,{|x| cTmpCondPag == Left(x,3)})) > 0 .AND. !lVerVP
		// Condicao Negociada
		If cTmpCondPag == "999"
			lCondNegF5 := .T.

			FR271HNegCond (	@nValorBase	, @nVlrBruto	, @nEntrada	,	@aPgtos		,;
							@nMoedaCor	, @nTaxaMoeda	, @aRetNeg 	,	@nTxJuros	,;
							@dDataCN	, @nTotDedIcms	, @lDiaFixo	)

			If Len(aRetNeg)>0
				cItemCond := "CN"
				nTXJuros   := aRetNeg[6][1]
				aRet := AClone(LJ7CalcPgt(nVlrBruto - If(cPaisLoc=="BRA",	nVlrDescTot + nTotDedIcms,0),;
																			cItemCond		,;
																			{aRetNeg[1][1]	,;
																			 aRetNeg[4][1]	,;
																			 aRetNeg[5][1]	,;
																			 aRetNeg[6][1]	,;
																			 aRetNeg[7][1]	,;
																			 aRetNeg[8][1]	,;
																			 .F.}			,;
																			Nil				,;
																			@nTmpJuros		,;
																			@nTmpDesc		,;
																			@nMoedaCor		,;
																			Nil				,;
																			@lDiaFixo		,;
																			@nMoedaCor		,;
																			@nDecimais		,;
																			Nil				,;
																			Nil				,;
																			Nil				,;
																			Nil				,;
																			Nil				,;
																			Nil				,;
																			nValIpi))
			EndIf
			If !Empty( aRetNeg )
				nPerAcreFi := aRetNeg[6][1]		// Percentual de acrescimo financeiro
				nPerDescFi := 0					// Percentual de desconto financeiro
			Else
				nPerAcreFi := 0
				nPerDescFi := 0
			EndIf

		ElseIf cTmpCondPag == "998"
			lCondNegF5 := .T.
			oMultNegoc := LJCMultNeg():New()
			oMultNegoc:GetMultNeg(aItens)
			If oMultNegoc:oDadosCab:Count() > 0
				oMultNegoc:SetValor(nVlrTotal - nVlrDescTot)
				nNCCUsada := Frt060Ret("NCC_USADA")
				oMultNegoc:SetValNCC(nNCCUsada)
				aPgtos := {}

				aRetPgto := Lj76TelNeg(@oMultNegoc, nMoedaCor)

				If Len(aRetPgto) > 0
					lMultNeg 	:= .T.
					For nFor := 1 to Len(aRetPgto)
						lArray := If(ValTyPe( aRetPgto[nFor][4] ) == "A" , .T. , .F. ) .AND. (Len(aRetPgto[nFor][4]) > 0)

						If lArray
							If aRetPgto[nFor][3] == MVCHEQUE
								cFrmMNeg := aRetPgto[nFor][4][4]

							ElseIf !IsMoney(aRetPgto[nFor][3])
								cFrmMNeg := aRetPgto[nFor][4][5]

							Else
								cFrmMNeg := ""
							EndIf
						EndIf

						aAdd( aPgtos, {;
										aRetPgto[nFor][1],;
										aRetPgto[nFor][2],;
				  						aRetPgto[nFor][3],;
										cFrmMNeg,;
										"",		;
										"", 	;
										"",  	;
										"",   	;
										"",    	;
										.T.,  	;
										nMoedaCor,;
										aRetPgto[nFor][8],;		// Id do Cartão (FormaId) 
										0,;
										"";
										})

						nVlrParcelas += aRetPgto[nFor][2]

					Next nFor

					If lVerEmpres .OR. (SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")
						nVlrParcelas := 0
					    nxValEnt 	:= 0
					    nxValTot 	:= nVlrTotal
					    nxQtdParc 	:= 0
					    nxValParc	:= 0
						For nFor := 1 to Len(aPgtos)

							If Alltrim(Upper(aPgtos[nFor][3])) == "FI"
								nxQtdParc ++
							Else
							    nxValEnt += aPgtos[nFor][02]
							    nxValTot -= aPgtos[nFor][02]
							Endif

						Next nFor
						nxValParc := Round( (nxValTot / nxQtdParc ) , MsDecimais(nPosMoeda) )
						For nFor := 1 to Len(aPgtos)
							If Alltrim(Upper(aPgtos[nFor][3])) == "FI"
								aPgtos[nFor][13] := aPgtos[nFor][2] - nxValParc
								aPgtos[nFor][2] := nxValParc
							Endif
							nVlrParcelas += aPgtos[nFor][2]
						Next nFor

			            If  nVlrParcelas <> ( nxValTot + nxValEnt ) .AND. Alltrim(Upper(aPgtos[1][3])) == "FI"
			            	nxDiff := (nxValTot + nxValEnt - nVlrParcelas)
			            	aPgtos[nxQtdParc][2] += nxDiff
			            Endif

					Endif

					If nVlrParcelas - nVlrTotal > 0
					 	nAcreMn :=  nVlrParcelas - nVlrTotal
				   	Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calcula Desconto nas Parcelas de Multinegociação³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				 		nDescMult := nVlrTotal - nVlrParcelas
				 		nAcreMn   := 0
				 	EndIf
				EndIf

			Else
				oMultNegoc := Nil
			EndIf
		Else
			lCondNegF5 := .F.
			cItemCond  := cTmpCondPag
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+cItemCond))
			cItemForma := If(!Empty(SE4->E4_FORMA),SubStr(SE4->E4_FORMA,1,2),;
								If(!Empty(SuperGetMV("MV_FORMPAD")),;
									SuperGetMV("MV_FORMPAD"),;
									SuperGetMV("MV_SIMB1")))

			If lFrontNCC
				If Frt060Ret("NCC_USADA") > 0 .AND. Frt060Ret("060_VLRDESC") == 0
					nVlrBruto := nvlrtotal

					// Soma os valores do Frete ao Valor Bruto e retorna no aRet já com Valor do Frete
					nVlrFrtReta := 0
					nVlrFrtReta	:= SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA

					nVlrBruto += nVlrFrtReta

				Endif
			EndIf
			nTmpDesc   := SE4->E4_DESCFIN


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Localizacoes                ³
			//³Calcular pagamento com base no valor bruto.³
			//³Paises: Chile/Colombia - F1CHI             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLocR5
				aRet := AClone(LJ7CalcPgt(nVlrBruto 	,;
											cItemCond	,;
											NIL			,;
											NIL			,;
											@nTmpJuros	,;
											@nTmpDesc	,;
											@nMoedaCor	,;
											NIL			,;
											NIL			,;
											@nMoedaCor	,;
											@nDecimais 	,;
											NIL			,;
											NIL			,;
											NIL			,;
											NIL			,;
											NIL			,;
											NIL			,;
											nValIpi))
			Else
				// Se usa nova regra de desconto zera o valor do desconto anterior
				If lNovRegDesc .AND. Len(aPgtos) > 0 .AND. lMultNeg
					nVlrDescTot := 0
				EndIf
				
				aRet := AClone(LJ7CalcPgt(nVlrBruto - If( cPaisLoc$"ARG|MEX" .AND. cItemCond <> "CN" , nAux,;
				 														(nVlrDescTot + nTotDedIcms)),;
																		cItemCond	,;
																		NIL			,;
																		NIL			,;
																		@nTmpJuros	,;
																		@nTmpDesc	,;
																		@nMoedaCor	,;
																		NIL			,;
																		NIL			,;
																		@nMoedaCor	,;
																		@nDecimais  ,;
																		NIL			,;
																		NIL			,;
																		NIL			,;
																		NIL			,;
																		NIL			,;
																		NIL			,;
																		nValIpi))
			EndIf

			nTXJuros   := nTmpJuros
			nPerAcreFi := SE4->E4_ACRSFIN		// Percentual de acrescimo financeiro
			nPerDescFi := SE4->E4_DESCFIN		// Percentual de desconto financeiro

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para entrar na rotina:                                                                    ³
		//³- Valida se existe elementos no array                                                     ³
		//³- Valida se o estado do M0_ESTCOB está dentro da lei, se existe desconto no total da venda³
		//³e a condição de pagamento não trata juros nem desconto                                    ³
		//³- Valida se o estado do M0_ESTCOB nao estah dentro da lei                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	Len( aRet ) > 0		.AND.;			//Valida se tem dados no array
			( ( LjAnalisaLeg( 14 )[1] .AND. lDescTotal .AND. ( nPerAcreFi == 0 .AND. nPerDescFi == 0 ) ) ) .OR.;
			( ( LjAnalisaLeg( 14 )[1] .AND. !lDescTotal ) ) .OR.;
			! ( LjAnalisaLeg( 14 )[1] )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se tem desconto ou juros³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPerAcreFi > 0 .OR. nPerDescFi > 0
				lDescSE4	:= .T.
			Else
				lDescSE4	:= .F.
	        Endif

	        If !(cTmpCondPag == "998")
				aPgtos := {} 			//Zera o array aPgtos para gravar o novo calculo
				nVlrTotal := 0
				For nI := 1 to Len(aRet)
					nVlrTotal += aRet[nI][2]
					cFormaID := If(AllTrim(aRet[nI][3])$_FORMATEF,"1",cFormaId)
			        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Exibir o valor do acrescimo separado da parcela³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AAdd( aPgtos, { aRet[nI][1]	, NoRound(aRet[nI][2],nDecimais), AllTrim(aRet[nI][3])	, "", "", "", "", "", "", .F., nMoedaCor, If(lVisuSint,cFormaID,Space(04)), aRet[nI][8],""})
				Next nI
			EndIf
			nVlrTotal := NoRound(nVlrTotal,nDecimais)
			nTotGeral := nVlrTotal + nTotDedIcms
			// Como neste ponto Zera a variavel "nVlrAcreTot", verifica novamente os valores de Fretes e soma novamente
			// Lembrando que o Valor do Frete é tratado como Acrescimo na Totalizacao/Formas de Pagamento do Cupom Fiscal
			nVlrAcreTot := 0
			If nPerAcreFi > 0  		//Valor do acrescimo financeiro
				nVlrAcreTot	:= ((nTotGeral - nVlrBruto + nVlrDescTot) + nVlrFrtReta)
				nVlrBruto += nVlrAcreTot
			ElseIf nVlrFrtReta > 0
				nVlrAcreTot	:= ((nTotGeral - nVlrBruto + nVlrDescTot) + nVlrFrtReta)
			EndIf
			If lFRTACRES
				xRet := U_FRTACRES(aItens, aPgtos	, 1 			,@nVlrDescTot	,;
					   				 0	 , @nVlrTotal, nVlrBruto 	)
				If ValType( xRet ) == "N"
					nVlrAcreTot += xRet
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se teve acrescimo Multi Negociação, inclui acrescimo por ultimo para não afetar demais valores como frete³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nAcreMn > 0
				nVlrAcreTot += nAcreMn
				nVlrTotal	+= nAcreMn
			EndIf

			nVlrDescCPg := 0
			If nPerDescFi > 0		//Valor do desconto financeiro
				nVlrDescCPg := nVlrBruto - (nVlrTotal + nVlrDescTot + nTotDedIcms)
			Endif

			If ExistBlock("FRTPGTODP")
				xRet  := ExecBlock("FRTPGTODP", .F., .F., { cTmpCondPag, aPgtos })
				If ValType(xRet) == "A"
					For nX := 1 to Len(xRet)
						If Len(xRet[nX]) < 13
							lAtuPgtos := .F.
						EndIf
					Next nX
					If lAtuPgtos
						aPgtos  := AClone(xRet)
					EndIf
				EndIf
			EndIf

			If !lTouch

				oPgtos:SetArray(aPgtos)
				oPgtos:Refresh()
				oVlrTotal:Refresh()

				If lVisuSint
					aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
					oPgtosSint:SetArray( aPgtosSint )
					oPgtosSint:Refresh()
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Zera o aPgtos, pois o total de NCC e maior que o total da venda³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFrontNCC
					If Len(aRet) <= 0 .AND. Frt060Ret("NCC_USADA") > 0
						AAdd( aPgtos, { Ctod("  /  /  "), 0 , "" , "", "", "", "", "", "", .F., nMoedaCor, If(lVisuSint,cFormaID,Space(04)), 0,"" })
					EndIf
				EndIf

			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controla e Informa desconto concedido na Multinegociação.       ³
			//³Utiliza Function FR271FDesctot para informar o desconto no Total³
			//³e atualizar o total da venda.                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMultNeg .AND. (nDescMult > 0)

				FR271FDescTot(	@nTmpJuros		, @nTmpDesc	  	, Nil				, @oPgtosSint	,;
		 						@aPgtosSint 	, @oPgtos		, @aPgtos			, @oCupom		,;
								@nVlrTotal 		, @nVlrBruto	, @nVlrDescTot		, @oVlrTotal	,;
								@nEntrada		, @nTaxaMoeda	, @lRecebe			, @dDataCN		,;
								@aItens			, 0				, @lDescTotal		, @lDescSE4		,;
								@nTotDedIcms	, 0				, @nMoedaCor		, @nDecimais	,;
								{}				, {}			, {}				, {}			,;
								@aFormCtrl		, @cItemCond	, @lCondNegF5		, .F.			,;
								@nTxJuros		, @nValorBase	, @lDiaFixo			, lImpOrc		,;
								.F.			    , {}		   	, {}				, cOrcam		,;
								/*nPerDesc*/	, nDescMult     , 0             	, .F.          	,;
								Nil				, Nil			, _cCliente     	, _cLojaCli		,;
								lMultNeg  )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Regra de desconto:                                          ³
			//³Funcao que vai calcular o desconto de acordo com a condicao ³
			//³ escolhida. A tela de desconto nao sera carregada de acordo ³
			//³ com as duas ultima variaveis.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lNovRegDesc .And. Len(aPgtos) > 0

				If FindFunction("RGDesTol") //Loja 3025
					nPerDesc := RGDesTol( .T.			, nVlrTotal	, cItemCond, aRet	,;
										   _cCliente	, _cLojaCli	)
				Endif

				If nPerDesc > 0
					nVlrDescTot := nValDesc
				EndIf
				nValDesc := ((nVlrTotal / 100)  * nPerDesc)
				If (nPerDesc > 0) .And. (nValDesc > 0)
					FR271FDescTot(	@nTmpJuros		, @nTmpDesc		, Nil			, @oPgtosSint	,;
		 							@aPgtosSint 	, @oPgtos		, @aPgtos		, @oCupom		,;
									@nVlrTotal 		, @nVlrBruto	, @nVlrDescTot	, @oVlrTotal	,;
									@nEntrada		, @nTaxaMoeda	, @lRecebe		, @dDataCN		,;
									@aItens			, 0				, @lDescTotal	, @lDescSE4		,;
									@nTotDedIcms	, 0				, @nMoedaCor	, @nDecimais	,;
									{}				, {}			, {}			, {}			,;
									@aFormCtrl		, @cItemCond	, @lCondNegF5	, .F.			,;
									@nTxJuros		, @nValorBase	, @lDiaFixo		, lImpOrc		,;
									.F.			    , {}		   	, {}			, cOrcam		,;
									nPerDesc		, nValDesc      , 0             , .F.          	,;
									Nil				, Nil			, _cCliente     , _cLojaCli  )
				EndIf
			EndIf
		Else
			MsgAlert(STR0022,STR0001) //"Escolha uma condição de pagamento que não tenha desconto ou acréscimo, pois já foi dado desconto no total da venda","Atenção"
		EndIf
	EndIf

EndIf

If !lFrtCondPag
	nLen := 0
	For nI := nLen To nOldLen+1 Step -1
		cCupom := SubString(cCupom,1,Len(cCupom) - 40)
	Next nI
EndIf

If lUsaDisplay
	DisplayEnv(StatDisplay(), "1E"  + STR0018 + Str(nVlrTotal,8,2) + " " + STR0019 +" 0,00"  )         //"Total: "    ""Saldo: ""
 	DisplayEnv(StatDisplay(), "2C"  + STR0020 )         //"
EndIf
oCupom:GoEnd()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso tenha utilizado Desconto na NCC o sistema irá efetuar o      ³
//³ tratamento do desconto e refazer os valores em tela.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lFrontNCC
	If  Frt060Ret("060_VLRDESC") > 0 .AND. !lFrtNCCMaior
		FR060CalcDesc(	@nTmpJuros		, @nTmpDesc			, NIL						, @oPgtosSint	,;
						@aPgtosSint 	, @oPgtos			, @aPgtos		    		, @oCupom		,;
						@nVlrTotal 		, @nVlrBruto		, Frt060Ret("060_VLRDESC")	, @oVlrTotal	,;
						@nEntrada		, @nTaxaMoeda		, @lRecebe		    		, @dDataCN		,;
						NIL				, NIL				, .T.			   			, @lDescSE4		,;
						@nTotDedIcms	, NIL				, @nMoedaCor	    		, @nDecimais	,;
						NIL				, NIL				, NIL			   			, NIL			,;
						@aFormCtrl		, @cItemCond		, @lCondNegF5	   			, NIL			,;
						@nTxJuros		, @nValorBase		, @lDiaFixo)

		oPgtos:SetArray(aPgtos)
		oPgtos:Refresh()
		oVlrTotal:Refresh()

		If lVisuSint
		   aPgtosSint:=Fr271IMontPgt(@aPgtos	, @nMoedaCor)
		   oPgtosSint:SetArray( aPgtosSint )
		   oPgtosSint:Refresh()
		EndIf
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura os SetKey's do Fechamento da Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTSetKey(aKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o array aPgtos esteja valorizado permite que o objeto oPgtos seja³
//³ editado pelo usuario, caso contrario desabilita o objeto...			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lFrtNCCMaior
    oPgtos:Disable()
	If lVisuSint
		oPgtosSint:Disable()
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o array aPgtos esteja valorizado permite que o objeto oPgtos seja³
	//³ editado pelo usuario, caso contrario desabilita o objeto...			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aPgtos)
		oPgtos:Enable()
		If lVisuSint
			oPgtosSint:Enable()
			If !lFrtCondPag
				oPgtosSint:SetFocus()
			EndIf
		EndIf
	Else
		oPgtos:Disable()
		If lVisuSint
			oPgtosSint:Disable()
		EndIf
	EndIf
Endif
cCupom := cBkCupom
Return(NIL)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR271HNegC³ Autor ³ Vendas Clientes       ³ Data ³22/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo da Condicao Negociada "CN"                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FR271HNegCond (nValorBase	, nVlrBruto		, nEntrada	, aPgtos	,;
 						nMoedaCor	, nTaxaMoeda	, aRetNeg 	, nTxJuros	,;
 						dDataCN		, nTotDedIcms	, lDiaFixo	)

Local nI := 0 //variavel do loop
Local lOk
Local lUsaAdmFin
Local cComboAdm
Local nTipoJur
Local nEntNeg
Local nTxJNeg
Local nParNeg
Local nIntNeg
Local aComboAdm  := ljxDLerCarta("FI",.T.)
Local aLbxFator  := {}
Local cCondicao	 := ""

If lDiaFixo == NIL
	lDiaFixo := .F.
EndIf

nValorBase := nVlrBruto - nTotDedIcms

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Administradora padr„o ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cComboAdm := aComboAdm[1]
Aadd(aLbxFator, { "  /  /  " , "" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Valor da Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nEntrada := 0
For nI := 1 To Len(aPgtos)
	If aPgtos[nI][1] == dDatabase .AND. !(aPgtos[nI][3] $ SuperGetMV("MV_ENTEXCE"))
		nEntrada += xMoeda(aPgtos[nI][2],aPgtos[nI][11],nMoedaCor,dDatabase,,,nTaxaMoeda)
	EndIf
Next nI

aRetNeg := {{1, "1100"},;
			{.F., "1"},;
			{cComboAdm, "1"},;
			{If(Len(aPgtos)>0,aPgtos[1][1],dDataBase), "1"},;
			{nEntrada, "1"},;
			{nTxJuros, "1"},;
			{Len(aPgtos), "1"},;
			{If(Len(aPgtos)>1,aPgtos[2][1]-aPgtos[1][1],1), "1"}}

If ExistBlock("L10RETNG")
	aRetNeg := ExecBlock("L10RETNG",.F.,.F.,{aRetNeg})
EndIf

nTipoJur   := aRetNeg[1][1]
lUsaAdmFin := aRetNeg[2][1]
cComboAdm  := aRetNeg[3][1]
dDataCN    := aRetNeg[4][1]
nEntNeg    := aRetNeg[5][1]
nTxJNeg    := aRetNeg[6][1]
nParNeg    := aRetNeg[7][1]
nIntNeg    := aRetNeg[8][1]

nParNeg := If( nEntNeg < nValorBase .AND. nParNeg == 0, 1, nParNeg )

If (ExistBlock("L10NEGOC"))
	ExecBlock("L10NEGOC",.F.,.F.)
EndIf

If Len(aRetNeg) <= 8 .OR. aRetNeg[09][01]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a Tela de Calculo da Condicao Negociada "CN"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Frtx272T07(	@lUsaAdmFin	, @cComboAdm	, @cCondicao	, @nTipoJur	,;
				@nValorBase	, @dDataCN		, @aRetNeg		, @nEntNeg	,;
				@nParNeg	, @nTxJNeg		, @lDiaFixo		, @nIntNeg	,;
				@aComboAdm 	, @lOk			, @aLbxFator	   )
Else

	// Se não entrou no IF, então o PE esta configurado para não mostrar a janela de Cond. Negociada
	// a variavel lOK fica como .T.
	lOk := .T.

EndIf

If lOk
	aRetNeg[1][1] := nTipoJur
	aRetNeg[2][1] := lUsaAdmFin
	aRetNeg[3][1] := cComboAdm
	aRetNeg[4][1] := dDataCN
	aRetNeg[5][1] := nEntNeg
	aRetNeg[6][1] := nTxJNeg
	aRetNeg[7][1] := nParNeg
	aRetNeg[8][1] := nIntNeg
Else
	aRetNeg := {}
EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr271HSoma³ Autor ³ Vendas Clientes       ³ Data ³08/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a qtde. informada para cancelamento eh valida  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FrtSomaIt(ExpC1,ExpN2,ExpA3,ExpN4)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 => Codigo do Produto a ser cancelado                 ³±±
±±³          ³ ExpN2 => Qtde. informada para cancelamento                 ³±±
±±³          ³ ExpA3 => Array que contem os itens que serao cancelados    ³±±
±±³          ³ ExpN4 => Qtde. do novo item que sera registrado na venda   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fr271HSomaIt( cCancProd, nCancQtde, aCancItens, nQtdeNova )

Local lRet      := .F.
Local aItensAux := aClone(aItens)
Local nPos      := 0
Local nColuna   := AIT_COD
Local nI        := 0
Local nQtdeAux  := 0

//Ordena o array pelo codigo do produto  e item
Asort(aItensAux,,,{ |x,y| UPPER(x[AIT_COD])+StrZero(x[AIT_ITEM],3) < UPPER(y[AIT_COD])+StrZero(y[AIT_ITEM],3)})

//Verifica se o produto informado esta presente na venda
nPos := aScan(aItensAux,{ |x| Trim(x[AIT_COD])=Trim(cCancProd)})
If nPos == 0
	nPos    := aScan(aItensAux,{ |x| Trim(x[AIT_CODBAR])=Trim(cCancProd)})
	nColuna := AIT_CODBAR
EndIf

If nPos <> 0
	aCancItens := {}
	For nI := nPos To Len(aItensAux)
		If !aItensAux[nI][AIT_CANCELADO]
			If (AllTrim(aItensAux[nI][nColuna]) == AllTrim(cCancProd))
				nQtdeAux += aItensAux[nI][AIT_QUANT]
				AAdd(aCancItens,(aItensAux[nI][AIT_ITEM]))
				If nQtdeAux >= nCancQtde
					Exit
				EndIf
			Else
				Exit
			EndIf
		EndIf
	Next nI
	//Verifica se a qtde a cancelar eh valida, caso seja calcula a quantidade do novo
	//item a ser informado na venda.
	lRet := Iif(nQtdeAux<nCancQtde .OR. nCancQtde==0,.F.,.T.)
	If !lRet
		aCancItens := {}
		Help("",1,"QTDEINV","",STR0017,1) //"A qtde. informada para cancelamento e invalida"
	Else
		nQtdeNova := nQtdeAux - nCancQtde
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr271CPesqMu³ Autor ³ Vendas Clientes       ³ Data ³08/04/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o produto eh um produto com multiplos. Caso seja ³±±
±±³          ³ determina quais itens da venda sao multiplos e tambem nao    ³±±
±±³          ³ nao permite que o usuario informe a qtde de itens que serao  ³±±
±±³          ³ cancelados.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FrtPesqMult(ExpC1,ExpA2,ExpN3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 => Codigo do Produto a ser cancelado                   ³±±
±±³          ³ ExpA2 => Array que contem os itens que serao cancelados      ³±±
±±³          ³ ExpN3 => Qtde. informada para cancelamento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Fr271CPesqMult( cCancProd, aCancItens, nCancQtde )
Local nI
Local lRet      := .F.
Local aItensAux := aClone(aItens)
Local nPos      := 0
Local cCodProd  := ""
Local nColuna   := AIT_COD
Local aAreaSBI  := SBI->(GetArea())
Local aAreaAtu  := GetArea()

If !Empty(cCancProd)
	//Ordena o array pelo codigo do produto e item
	Asort(aItensAux,,,{ |x,y| UPPER(x[AIT_COD])+StrZero(x[AIT_ITEM],3) < UPPER(y[AIT_COD])+StrZero(y[AIT_ITEM],3)})

	//Verifica se o produto informado esta presente na venda
	nPos := aScan(aItensAux,{ |x| Trim(x[nColuna])=Trim(cCancProd)})
	If nPos == 0
		nColuna := AIT_CODBAR
		nPos    := aScan(aItensAux,{ |x| Trim(x[nColuna])=Trim(cCancProd)})
		cCodProd:= Iif(nPos>0,aItensAux[nPos][AIT_COD],cCodProd)
	Else
		cCodProd:= cCancProd
	EndIf

	//Verifica se o produto eh um produto multiplo...
	DbSelectArea("SBI")
	DbSetOrder(1)
	DbSeek(xFilial("SBI")+cCodProd)
	If BI_MULT > 1
		lRet := .T.
	EndIf
	RestArea(aAreaSBI)
	RestArea(aAreaAtu)

	//Caso seja um produto multiplo verifica quais os itens
	//que devem ser cancelados...
	If (nPos > 0) .AND. lRet
		aCancItens := {}
		nCancQtde  := 0
		For nI := nPos To Len(aItensAux)
			If !aItensAux[nI][AIT_CANCELADO]
				If (AllTrim(aItensAux[nI][nColuna]) == AllTrim(cCancProd))
					nCancQtde += aItensAux[nI][AIT_QUANT]
					AAdd(aCancItens,(aItensAux[nI][AIT_ITEM]))
				Else
					Exit
				EndIf
			EndIf
		Next nI
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FR271HLogImºAutor ³ Vendas Clientes    º Data ³  05/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pasta de gravacao dos arquivos com orcamentos importados 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HLogImp()

Local cDirLog  := ""				// Diretorio para o LOG

cDirLog  := "\AUTOCOM\IMP" + StrTran(cEmpAnt + cFilAnt ," ","")+ "\"

Return (cDirLog)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FR271HRPCImºAutor ³ Vendas Clientes    º Data ³  05/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava na RET via RPC um arquivo texto com o numero dos orca-º±±
±±º			 ³mentos importados. O objetivo e nao permitir importar mais  º±±
±±º			 ³de uma vez												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HRPCImpOrc(cOrcamento, lVerifica,lCanCup,lLoja)

Local aRet      	:= {}                //Retorna numero dos orcamentos que nao gravaram o arquivo (erro)
Local aOrcsImp  	:= {}     			 //Array com os orcamentos importados
Local nPosOrcam 	:= 0      			 //Posicao do numero dos orcamentos importados
Local nX        	:= 0                 //Controle de loop
Local aArea     	:= GetArea()         //Area atual
Local aAreaSL2  	:= SL2->(GetArea())  //Area do SL2
Local cCRLF	    	:= Chr(13) + Chr(10) //Controle de linha
Local cMsg      	:= ""                //Mensagem dos orcamentos com erro na criacao do arquivo na RET
Local lRet  		:= .T.

DEFAULT cOrcamento  := ""
DEFAULT lVerifica := .F. 				 //Controla se faz apenas a verificacao da existencia do arquivo na Retaguarda
DEFAULT lCanCup		:= .F.
DEFAULT lLoja        := .F.  //Para nao realizar chamada da funcao FR271BStatSema quando venda assistida

If lLoja .OR. FR271BStatSema("CON", cEstacao)	//Verifica se tem conexão com a retaguarda
	DbSelectArea("SL2")
	DbSetOrder(1)
	If DbSeek(xFilial("SL2") + cOrcamento)
   		While !Eof() .AND. xFilial("SL2") + cOrcamento == SL2->L2_FILIAL + SL2->L2_NUM

      		If !Empty(SL2->L2_NUMORIG)
	      		nPosOrcam := Ascan( aOrcsImp , { |x| Alltrim( x[1] ) == Alltrim( SL2->L2_NUMORIG ) } )

	     		If nPosOrcam == 0
	         		AADD(aOrcsImp , { SL2->L2_NUMORIG , SL2->L2_PDV } )
	      		EndIf
	  		EndIf

     		DbSkip()
  		End
	EndIf

	If Len(aOrcsImp) > 0
   		LJMsgRun( STR0031 + cOrcamento + "...", NIL, ; //"Aguarde, atualizando status do orcamento "
         		    { || aRet := FR271CMyCall( "FR271HArq", { "SL1", "SL2", "SL4" }, aOrcsImp, lVerifica,lCanCup) } )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta mensagem se houve erro na criacao do arquivo de algum orcamento importado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRet) > 0
    	For nX := 1 to Len(aRet)
       	cMsg += aRet[nX] + "\"
    	Next nX
    	cMsg  := Substr(cMsg, 1, Len(cMsg) - 1)

    	lRet := .F.

    	If lVerifica
	    	MsgAlert(STR0046) //"Não é possível finalizar a venda, este orçamento já foi finalizado por outro PDV."
    	Else
	    	MsgAlert(STR0032 + cCRLF + ;//"Nao foi possivel criar um ou mais arquivos referentes a importacao do orcamento."
	       	      STR0033 + cMsg )   //"Orcamentos: "
    	EndIf
	EndIf

	RestArea(aAreaSL2)
	RestArea(aArea)
Else
	LjLogFront("FRT271H - "+STR0057 )//"Perca de conexão com a Retaguarda, porem a venda será finalizada sem criar o arquivo de semáforo da importação do orçamento"
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FR271HArq  ºAutor ³ Vendas Clientes    º Data ³  05/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava na RET via RPC um arquivo texto com o numero dos orca-º±±
±±º			 ³mentos importados. O objetivo e nao permitir importar mais  º±±
±±º			 ³de uma vez												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HArq( aOrcsImp, lVerifica , lCanCup, lTotvsPdv, lValidRet )

Local nHandle   := 0                        //Controle do arquivo
Local nX        := 1                        //Controle de loop
Local cArq      := ""                       //Nome do arquivo a ser gravado
Local cArqTemp  := LOG_IMP + "TEMP.TMP"     //Arquivo para testar se existe a pasta "\AUTOCOM\IMP" + cEmpAnt + cFilAnt
Local lCriouArq := .F.                      //Controla se criou arquivo do orcamento
Local aOrcsErro := {}                       //Orcamentos com erro na criacao do arquivo
Local cPDV      := Space(TamSX3("L1_PDV")[1]) 	 //Numero do PDV atual. 
Local cOrigPDV  := Space(TamSX3("L1_PDV")[1]) 	 //PDV que originalmente importou o orcamento.
Local cNumOrig  := Space(TamSX3("L1_NUMORIG")[1])//Numero do orcamento importado. 
Local aOrcsAux	:= {}
Local lMultDav	:= .F. 
Local lRet		:= .T.
Local cExt      := ".TXT"

DEFAULT aOrcsImp  := {}
DEFAULT lVerifica := .F. 					//Controla se faz apenas a verificacao da existencia do arquivo na Retaguarda
DEFAULT lCanCup   := .F.                    //Indica se e cancelamento do cupom fiscal.
DEFAULT lTotvsPdv := .F.					//E totvs pdv? 
DEFAULT lValidRet := .F.                    //Validar arquivo .RET na Retaguarda

cExt := IIF(lValidRet, ".RET", ".TXT")

If !File( cArqTemp )
	MakeDir( "\AUTOCOM" )
	MakeDir( "\AUTOCOM\IMP" + StrTran( cEmpAnt + cFilAnt ," " ,"") )
	nHandle := FCreate( cArqTemp )
	FClose( nHandle )
Endif

LjGrvLog("", "Array - Num.Orc.| Num. PDV", aOrcsImp)

If Len(aOrcsImp) > 1 
	aOrcsAux := {{aOrcsImp[1], aOrcsImp[2]}}
	aOrcsImp := aClone(aOrcsAux)
	lMultDav := .T.
	LjGrvLog("","Alterou array aOrcsImp",nil)
	LjGrvLog("", "Array - Num.Orc.| Num. PDV", aOrcsImp)
ElseIf Len(aOrcsImp) == 0
	lRet := .F.
EndIf


If lTotvsPdv .AND. lRet
	cArq := LOG_IMP + aOrcsImp[1][1] + cExt
	If File( cArq )
		AADD(aOrcsErro, .T.)
	Else
		AADD(aOrcsErro, .F.)
	EndIf
	lRet := .F. 
EndIf

If lCanCup .AND. lRet      						//Trata a exclusao do arquivo no caso de cancelamento do cupom fiscal ja importado. 
	cNumOrig := Alltrim(aOrcsImp[1][1])
	cArq 	 := LOG_IMP + cNumOrig + cExt
	cPDV 	 := Alltrim(aOrcsImp[1][2])

	If File( cArq ) 
 		nHandle := FOpen( cArq , 2 ) 	//Abre o arquivo para checar o PDV.
  		If nHandle == -1   				//Testa a abertura do arquivo.
			Conout('> Erro ao ABRIR o arquivo '+ cArq + '. Ferror = '+ Str(ferror(),4),'Erro')
  		Else
			cOrigPDV := FReadStr( nHandle, Len(cOrigPDV) ) //Le o arquivo de origem. 
			FClose( nHandle )
   			If cOrigPDV == cPDV         //Verifica se eh o mesmo PDV que importou o orcamento, caso contrario nao permite excluir.  
				FErase(cArq)		
				Conout("Arquivo deletado FR271HArq")	 
			EndIf  
		EndIf
	 EndIf 
ElseIf lRet
	While nX <= Len(aOrcsImp) 
	    If lMultDav
		    cArq := LOG_IMP + aOrcsImp[1][nX][1] + cExt
		    cPDV := Alltrim(aOrcsImp[1][nX][2])
		Else
		    cArq := LOG_IMP + aOrcsImp[nX][1] + cExt
		    cPDV := Alltrim(aOrcsImp[nX][2])
	    EndIf

	    If lVerifica .AND. File( cArq )  	//Apenas verifica se o arquivo existe para saber se ja foi importado o orcamento.
	    	nHandle := FOpen( cArq , 2 ) 	//Abre o arquivo para checar o PDV.
	  		If nHandle == -1   				//Testa a abertura do arquivo.
				Conout('> Erro ao ABRIR o arquivo '+ cArq + '. Ferror = '+ Str(ferror(),4),'Erro')
	  		Else
				cOrigPDV := FReadStr( nHandle, Len(cPDV) ) //Le o arquivo de origem.
	        	If !( cOrigPDV == cPDV )                   //Verifica se outro PDV esta tentando finalizar o mesmo orcamento.
					AADD(aOrcsErro, aOrcsImp[nX][1])
		    	EndIf
		    	FClose( nHandle )
		    EndIf
	    Else
		    lCriouArq  := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o arquivo nao existir, cria para indicar que ja foi importado.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !File( cArq )
				nHandle := FCreate( cArq )  		//Cria o arquivo.
				If nHandle == -1   					//Testa a criacao do arquivo.
					Conout('> Erro ao CRIAR o arquivo '+ cArq + '. Ferror = '+ Str(ferror(),4),'Erro')
	  			Else
	  				FClose( nHandle )
	  			EndIf
	  			nHandle := FOpen( cArq , 2 ) 		//Abre o arquivo criado para gravar o numero do PDV.
	  			If nHandle == -1   					//Testa a abertura do arquivo.
					Conout('> Erro ao ABRIR o arquivo '+ cArq + '. Ferror = '+ Str(ferror(),4),'Erro')
	  			EndIf
				FSeek(nHandle,0)		   			//Move o ponteiro para o inicio do arquivo.
				FWrite( nHandle , cPDV , Len(cPDV) )//Grava o numero do PDV no arquivo.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava no array os orcamentos que nao conseguiu criar o arquivo     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If FError() <> 0
			       AADD(aOrcsErro, aOrcsImp[nX])
				Else
				   FClose( nHandle )
				   lCriouArq  := .T.
				EndIf
			EndIf
		EndIf
		nX++
	End
EndIf

Return (aOrcsErro)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FR271HDArq ºAutor ³ Vendas Clientes    º Data ³  16/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Remove via RPC um arquivo texto com o numero do orcamento   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cNumOrc													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FR271HDArq( cNumOrc )

Local cArq      := LOG_IMP + cNumOrc + ".TXT"	//Nome do arquivo a ser removido
Local cArqTemp  := LOG_IMP + "TEMP.TMP"			//Arquivo para testar se existe a pasta "\AUTOCOM\IMP" + cEmpAnt + cFilAnt

If !File( cArqTemp )
	MakeDir( "\AUTOCOM" )
	MakeDir( "\AUTOCOM\IMP" + StrTran( cEmpAnt + cFilAnt ," " ,""))
	nHandle := FCreate( cArqTemp )
	FClose( nHandle )
Endif

If File( cArq )
	FErase( cArq )
Endif

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fr271PtOrc ºAutor ³ Vendas Clientes    º Data ³ 15/Out/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento para importacao e impressao de orcamento c/itens º±±
±±ºDesc.     ³ de RETIRA POSTERIOR.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cNumOrc													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fr271PtOrc(cNumOrc,cDAVPV,lRetPost)
Local lRet 		:= .T.
Local aSL1 		:= {}
Local cCliCGC 	:= ""

//Carrega orcamento da retaguarda para o PDV
LJ7VldCarrega(Nil, cNumOrc, cDAVPV, "LOJA160")

//Verifica se L1_NUMORC == cDAVPV para confirmar se o orcamento foi devidamente importado para o PDV
If SL1->L1_NUMORC == cDAVPV

	//Executa a impressao
	lRet := Lj140ImpOrc( Nil, SL1->L1_CLIENTE, SL1->L1_LOJA, @cCliCGC, lRetPost )

	If lRet

		MsgAlert(STR0054) //"Impressão do cupom concluída!"

		aAdd(aSL1, {"L1_SITUA"	, "00"} ) 		// "00" - Venda Efetuada Com Sucesso

		FR271BGeraSL("SL1", aSL1, .F.) //Atualiza SL1

	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fr271SNCCO ºAutor ³ Vendas Clientes    º Data ³ 07/Fev/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Configura o valor do Credito gerado no orçamento            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³nValue													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr271SNCCO(nValue)

nVlrNCCOrc	:= nValue//Valor da NCC do Orcamento

Return nVlrNCCOrc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Fr271GNCCO ºAutor ³ Vendas Clientes    º Data ³ 07/Fev/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor do Credito gerado no orçamento             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fr271GNCCO()

Return nVlrNCCOrc
