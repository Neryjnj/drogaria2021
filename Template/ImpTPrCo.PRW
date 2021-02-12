#Include "Protheus.ch"
#Include "Rwmake.ch"

#Define LK_CODBAR  "SLK->LK_CODBAR"
#Define A5_CODPRF  "SA5->A5_CODPRF"
#Define B1_CODP    "SB1->B1_COD"
#Define TOT_CONS  2

//----------------------------------------------------------
/*/{Protheus.doc} ImpTPrCo

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function ImpTPrCo()
Local oDlg
Local oBmt1
Local oBmt2
Local oBmt3
Local oBmt4
Private cArqFonte  := Space(100)
Private cArqLayout := Space(100)
Private cCodForn   := Space(6)
Private cCodLoja   := Space(2)
Private cCondpagto := SPACE(3)
Private cCodPromo := SPACE(3)
Private cNomTabPre  := Space(40)
Private cDataIni   := DDatabase 
Private cDataFim   := CTOD("  /  /  ")
Private cHoraIni   := "00:00"
Private cHoraFim   := "23:59"
Private cCodTab
Private cCodItem

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

DEFINE MSDIALOG oDlg FROM 1,1 TO 425,385 TITLE "Importação de Tabela de Preços - Compras" PIXEL

@ 012,20 SAY "Cód. Fornec.:"
@ 012,59 SAY "Loja:"
@ 012,80 SAY "Nome Tabela Preco.:"
@ 042,20 SAY "Data inicial:"
@ 072,20 SAY "Data final:"
@ 042,90 SAY "Hora inicial:"
@ 072,90 SAY "Hora final:"
@ 102,20 SAY "Condicao Pagto"
@ 102,90 SAY "Codigo Promocao"
@ 132,20 SAY "Arquivos de Retorno:"
@ 162,20 SAY "Arquivos de Layout de Retorno:"

@ 020,20 MSGET cCodForn F3 "SA2" PICTURE "@!" VALID !Empty(cCodForn) .And. ValFornec(.T.) SIZE 30,10 OF oDlg PIXEL
@ 020,59 MSGET cCodLoja PICTURE "!!" VALID !Empty(cCodLoja) .And. ValFornec(.F.) SIZE 15,10 OF oDlg PIXEL
@ 020,80 MSGET cNomTabPre PICTURE "@!" VALID !Empty(cNomTabPre) SIZE 60,10 OF oDlg PIXEL

@ 050,20 MSGET cDataIni VALID !Empty(cDataIni) .And. Iif(!Empty(cDataFim), cDataFim >= cDataIni, .T.) SIZE 50,10 OF oDlg PIXEL
@ 050,90 MSGET cHoraIni PICTURE "99:99" VALID !Empty(cHoraIni) .And. (cHoraFim >= cHoraIni) SIZE 50,10 OF oDlg PIXEL

@ 080,20 MSGET cDataFim VALID Iif(!Empty(cDataFim), cDataFim >= cDataIni, .T.) SIZE 50,10 OF oDlg PIXEL
@ 080,90 MSGET cHoraFim PICTURE "99:99" VALID !Empty(cHoraFim) .And. (cHoraFim >= cHoraIni) SIZE 50,10 OF oDlg PIXEL

@ 110,20 MSGET cCondpagto F3 "SE4" PICTURE "!!!" VALID Empty(cHoraIni) .or. existcpo("SE4" ,  cCondpagto) SIZE 15,10 OF oDlg PIXEL
@ 110,90 MSGET cCodPromo PICTURE "!!!"  SIZE 15,10 OF oDlg PIXEL

@ 140,20 MSGET cArqFonte PICTURE "@!" SIZE 120,10 OF oDlg PIXEL
oBmt3 := SButton():New(140,140,14, {|| cArqFonte := cGetFile("Arquivos de Retorno |*.txt|","Escolha o arquivo Fonte.",0,"SERVIDOR",.T.) },,)
@ 170,20 MSGET cArqLayout PICTURE "@!" SIZE 120,10 OF oDlg PIXEL
oBmt4 := SButton():New(170,140,14, {|| cArqLayout := cGetFile("Arquivos de Layout de Retorno |*.ret|","Escolha o arquivo de Retorno.",0,"SERVIDOR",.T.) },,)

oBmt1 := SButton():New(12,155,01, {|| ValEntrada() },,)
oBmt2 := SButton():New(32,155,02, {|| oDlg:End() },,)

ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} ValEntrada

Para validar os campos de entrada

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function ValEntrada()

If !ValFornec(.F.)
	MsgAlert("O Fornecedor com o código [" + cCodForn + "] e a loja [" + cCodLoja + "] não existe!")
Else
	If RTrim(cNomTabPre) == ""
		MsgAlert("Uma descrição para a Tabela de Preços deve ser informada!")
	Else
		If !File(cArqFonte)
			MsgAlert("O arquivo fonte [" + RTrim(cArqFonte) + "] não existe!")
		Else
			If !File(cArqLayout)
				MsgAlert("O arquivo de retorno [" + RTrim(cArqLayout) + "] não existe!")
			Else
				LerArqEDI(RTrim(cArqFonte), RTrim(cArqLayout))
			EndIf
		EndIf
	EndIf
EndIf

Return .T.


//****************************************************//
// Rotina: ProcTab                                    //
//----------------------------------------------------//
// Rotina para o processamento da Tabela de Preços    //
//													  //
// Parâmetros:										  //
//		aRegistro -> Os dados e campos da Tabela de   //
//					 Preços 						  //
//****************************************************//
Static Function ProcTab(aRegistro)
Local aArea     := GetArea()
Local nI
Local cCampo    := ""

DbSelectArea("AIA")
DbSetOrder(1)

RecLock("AIA", .T.)

AIA->AIA_CODTAB := cCodTab
AIA->AIA_FILIAL := xFilial("AIA")
AIA->AIA_CODFOR := cCodForn
AIA->AIA_LOJFOR := cCodLoja
AIA->AIA_DESCRI := cNomTabPre
AIA->AIA_CONDPG := cCondpagto
AIA->AIA_PROMO  := cCodPromo
AIA->AIA_DATDE  := cDataIni
AIA->AIA_DATATE := cDataFim
AIA->AIA_HORADE := cHoraIni
AIA->AIA_HORATE := cHoraFim
AIA->AIA_TPHORA := "1"
AIA->AIA_ATIVO  := "1"

For nI := 1 To Len(aRegistro)
	cCampo := AllTrim(aRegistro[nI][3])
	If cCampo <> "" .And. ColumnPos(SubStr(cCampo, 6, Len(cCampo) - 5)) <> 0
		_cConteudo	:= FormCampo(aRegistro[nI][1], aRegistro[nI][2], RTrim(aRegistro[nI][4]))
		&(cCampo)	:= _cConteudo
		if AllTrim( cCampo)  == "AIA->AIA_DATDE"
			cDataIni := _cConteudo					// Se data inicial estiver inclusa no arquivo de dados considera-la para o cabeçalho e detalhe (AIB_DATVIG)
		endif		
	EndIf
Next nI

MsUnLock("AIA")
ConfirmSX8()

//If __lSX8
//	While (GetSX8Len() > nSaveSx8)
//		ConfirmSX8()
//	End
//EndIf


RestArea(aArea)

Return (.T.)


//****************************************************//
// Rotina: ProcItemTab                                //
//----------------------------------------------------//
// Rotina para o precessamento dos itens da Tabela de //
// Preços  											  //
// 													  //
// Parâmetros: 										  //
//		aRegistro -> Os dados e campos da tabela de  //
//					  itens (AIB) 					  //
//****************************************************//
Static Function ProcItemTab(aRegistro)
Local aArea    := GetArea()
Local nPosC
Local cCodProd := ""
Local cCampo   := ""
Local nI	   := 0


// Verifica a existência do campo A5_CODPRF - Código do Produto no Fornecedor
nPosC := AScan(aRegistro, {|x| AllTrim(x[3]) == A5_CODPRF})

If nPosC <> 0
	
	DbSelectArea("SA5")
	DbOrderNickName("SA5DRO1")//indice criado p/ o Template de Drogaria
	DbGoTop()
	
	If AllTrim(aRegistro[nPosC][1]) <> ""
		If DbSeek(xFilial("SA5") + cCodForn + cCodLoja + aRegistro[nPosC][1])
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbGoTop()
			
			If DbSeek(xFilial("SB1") + SA5->A5_PRODUTO)
				cCodProd := SB1->B1_COD
			EndIf
			
		EndIf
	EndIf
	
EndIf

If cCodProd == ""
	
	// Verifica a existência do campo LK_CODBAR - Código de Barras
	nPosC := AScan(aRegistro, {|x| AllTrim(x[3]) == LK_CODBAR})
	
	If nPosC <> 0
		
		DbSelectArea("SLK")
		DbSetOrder(1)
		DbGoTop()
		
		If AllTrim(aRegistro[nPosC][1]) <> ""
			If DbSeek(xFilial("SLK") + aRegistro[nPosC][1])
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbGoTop()
				
				If DbSeek(xFilial("SB1") + SLK->LK_CODIGO)
					cCodProd := SB1->B1_COD
				EndIf
				
			EndIf
		EndIf
	EndIf
EndIf

// Processa a inclusão do preço
If cCodProd <> ""
	
	lProcTab := .T.
	
	DbSelectArea("AIB")
	DbSetOrder(1)
	
	RecLock("AIB", .T.)
	
	cCodItem := Soma1(cCodItem, Len(AIB->AIB_ITEM))
	
	AIB->AIB_ITEM   := cCodItem
	AIB->AIB_FILIAL := xFilial("AIB")
	AIB->AIB_CODFOR := cCodForn
	AIB->AIB_LOJFOR  := cCodLoja
	
	AIB->AIB_CODTAB := cCodTab
	AIB->AIB_CODPRO := cCodProd
	//AIB->AIB_ATIVO  := "1"
	AIB->AIB_MOEDA  := 1
	AIB->AIB_DATVIG := cDataIni
	AIB->AIB_QTDLOT := 999999.99
	AIB->AIB_INDLOT := "000000000999999.99"
	
	For nI := 1 To Len(aRegistro)
		cCampo := AllTrim(aRegistro[nI][3])
		If cCampo <> "" .And. cCampo <> B1_CODP .And. ColumnPos(SubStr(cCampo, 6, Len(cCampo) - 5)) <> 0
			&(cCampo) := FormCampo(aRegistro[nI][1], aRegistro[nI][2], RTrim(aRegistro[nI][4]))
		EndIf
	Next nI
	
	MsUnLock("AIB")
	
EndIf

RestArea(aArea)

Return (.T.)


//******************************************************//
// Rotina: LerArqEDI								    //
//------------------------------------------------------//
// Rotina para ler os campos de um arquivo de layout    //
// junto com os dados de um arquivo fonte, sendo que    //
// arquivo de layout deve ser criado por um configura-  //
// dor de EDI.                                          //
//													    //
// Parâmetros:                                          //
//    cArqFonte -> nome do arquivo fonte (dados)        //
//    cArqLayou -> nome do arquivo de layout criado     //
//                 um configurador de EDI               //
//******************************************************//
Static Function LerArqEDI(cArqFonte, cArqLayout)
Local aRest
Local nI
Local cArqHdl
Local cConteudo := " "
Local aRegistro
Local aRegTab
Private lProcTab  := .F.
Private nSaveSx8
Private nRecno := 0

aRest := EDIRestArq(cArqLayout)
cArqHdl := FOpen(cArqFonte, 0)

If File(cArqFonte)
	cArqHdl := FOpen(cArqFonte,1)
	FSeek(cArqHdl,0,2)
	If cArqHdl = -1
		If lTela
			MsgAlert("Erro na abertura do arquivo com os dados da tabela de preco a ser importada  "+cArqFonte)
		Endif
		Return .F.
	EndIf
EndIf

If Len(aRest) > 0
	
	FT_FUSE(cArqFonte)
	FT_FGOTOP()
	
	While !FT_FEOF()
		cLinha:= FT_FREADLN()
		
		++nRecno
		If Empty(cLinha)
			FT_FSKIP()
			Loop
		EndIf
		
		aRegistro := {}
		nPosAtual := 1
		
		// Processa o cabecalho
		If Len(aRest[1]) <> 0
			
			For nI := 1 To Len(aRest[1])
				
				if aRest[ 1 ] [nI] [Len(aRest[ 1 ][Ni] ) ]
					loop
				endif
				
				If AllTrim(aRest[1][nI][1]) <> ""
					cConteudo := subs( cLinha , nPosAtual ,  aRest[1][nI][4] )
					nPosAtual := nPosAtual + aRest[1][nI][4]
					Aadd(aRegistro, { cConteudo, aRest[1][nI][6], aRest[1][nI][7], aRest[1][nI][8] })
				EndIf
			Next nI
			
			if nI <  Len(aRest[1])				// Se cabecalho maior que 1 linha
				FT_FSKIP()
				cLinha:= FT_FREADLN()		// Ler a proxima linha do EDI
			else
				exit
			Endif
			
		EndIf
	enddo
	
	Begin Transaction
	
	DbSelectArea("AIA")
	cCodTab  := GETSXENUM("AIA", "AIA_CODTAB")
	//nSaveSx8 := GetSx8Len()
	
	cCodItem := Repl("0", Len(AIB->AIB_ITEM))
	aRegTab  := AClone(aRegistro)	
	ProcTab(aRegTab)	
	
	aRegistro  := {}
	
	// Processa todos os itens (preços)
	While !FT_FEOF()
		cLinha:= FT_FREADLN()
		aRegItemAtu := {}
		
		nPosAtual := 1
		For nI := 1 To Len(aRest[2])
			cConteudo := subs( cLinha , nPosAtual ,  aRest[2][nI][4] )
			nPosAtual := nPosAtual + aRest[2][nI][4]
			Aadd(aRegistro      , { cConteudo, aRest[2][nI][6], aRest[2][nI][7], aRest[2][nI][8] } )
			Aadd(aRegItemAtu , { cConteudo, aRest[2][nI][6], aRest[2][nI][7], aRest[2][nI][8] } )
		Next nI
		
		ProcItemTab(aRegItemAtu)
		
		FT_FSKIP()
	EndDo
	
	End Transaction
	
	
	FT_FUSE()
	//Fecha o arquivo de retorno do Fornecedor
	FClose(cArqHdl)
	
	FClose(cArqHdl)
	
	If lProcTab
		MsgAlert("Importação realizada com sucesso!")
		cArqFonte  := Space(100)
		cArqLayout := Space(100)
		cCodForn   := Space(6)
		cCodLoja   := Space(2)
		cCondpagto := SPACE(3)
		cCodPromo := SPACE(3)
		cNomTabPre  := Space(40)
		cDataIni   := DDatabase
		cDataFim   := CTOD("  /  /  ")
		cHoraIni   := "00:00"
		cHoraFim   := "23:59"
		
	Else
		MsgAlert("Não haviam dados a serem importados!")
	EndIf
EndIf

Return (.T.)


//****************************************************//
// Rotina: EDIRestArq                                 //
//----------------------------------------------------//
// Rotina para recuperação de layouts de arquivos     //
//													  //
// Parâmetros:  									  //
//		cNomeArquivo -> nome do arquivo de layout     //
//****************************************************//
Static Function EDIRestArq(cNomeArquivo)
Local aRest := {}

aRest := __VRestore(cNomeArquivo)
If Len(aRest) <> 3
	MsgAlert("O arquivo de retorno [" + cNomeArquivo + "] é inválido!")
EndIf

Return (aRest)


//**********************************************//
// Rotina: ValFornec()                          //
//----------------------------------------------//
// Rotina para validação do código e loja do    //
// Fornecedor escolhido 						//
//												//
// Parâmetros 									//
//		lFornece -> Indica se a validação será  //
//					somente feita pelo código   //
//					do Fornecedor.				//
//**********************************************//
Static Function ValFornec(lFornece)
Local lRet   := .T.
Local aArea  := GetArea()

DbSelectArea("SA2")
DbSetOrder(1)
DbGoTop()

If lFornece .And. AllTrim(cCodLoja) == ""
	cRet := DbSeek(xFilial("SA2") + cCodForn)
Else
	cRet := DbSeek(xFilial("SA2") + cCodForn + cCodLoja)
EndIf

cCodLoja := SA2->A2_LOJA

RestArea(aArea)
Return (lRet)


//**************************************************//
// Rotina: FormCampo 								//
//--------------------------------------------------//
// Rotina para formatacao e conversao dos campos    //
// a partir dos seus Pictures  						//
// 													//
// Parâmetros:										//
//		-> cValor: valor do campo em caractere		//
//		-> cTipoDado: tipo de dado do campo			//
//		-> cPicture: picture de entrada				//
//**************************************************//
Static Function FormCampo(cValor, cTipoDado, cPicture)
Local uRet   := ""
Local cPart1 := ""
Local cPart2 := ""
Local cPart3 := ""
Local nPos   := 0

Do Case
	Case cTipoDado == "1"		//CARACTER
		uRet := TransForm(cValor , cPicture )
		//uRet := TransForm(aRegistro[nI][1], aRegistro[nI][3])
		
	Case cTipoDado == "2"		//nUMERICO
		//nPos   := At(".", cPicture)
		//cPart1 := TransForm(SubStr(cValor, 1, nPos-1), SubStr(cPicture, 1, nPos-1))
		//cPart2 := TransForm(SubStr(cValor, nPos+1, Len(cPicture)-nPos), SubStr(cPicture, nPos+1, Len(cPicture)-nPos))
		//uRet   := Val(cPart1+"."+cPart2)
		
		lValorOK    := FormatValor(cValor,cPicture,@cValor)
		//MSGSTOP( " VALOR -->  " + IF(VALTYPE( cValor ) == "C", cValor,  STR( cValor ) ) )
		If lValorOK
			uRet  := cValor
		Else
			Return(.F.)
		EndIf
		
		
		
	Case cTipoDado == "3"		//DATA
		nPos   := At("D", Upper(cPicture))
		cPart1 := SubStr(cValor, nPos, 2)
		nPos   := At("M", Upper(cPicture))
		cPart2 := SubStr(cValor, nPos, 2)
		nPos   := At("A", Upper(cPicture))
		cPart3 := SubStr(cValor, nPos, (Len(cPicture)-nPos)+1)
		uRet   := CTOD(cPart1+"/"+cPart2+"/"+cPart3)
		
	Case cTipoDado == "4"		//LOGICO
		uRet := IF(cValor $ sSyYtT  ,  .T.  ,  .f.   )
		//uRet := TransForm(aRegistro[nI][1], aRegistro[nI][3])
EndCase

Return uRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FormatValoºAutor  ³Fernando Machima    º Data ³  09/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formata valores de acordo com a picture do layout          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FormatValor(cValor,cPicture,nValorExp)

Local lRet          := .T.
Local nPosDec                 //Posicao do separador de decimais
Local nQtdDecimais  := 0
Local cTxtLog       := ""
Local cTemp         := ""

//Verifica pela picture quantos decimais tem o valor a ser importado
If AT(",",cPicture) > 0 .Or. AT(".",cPicture) > 0
	For nPosDec := Len(cPicture) to 1 STEP -1
		If Substr(cPicture,nPosDec,1) == "." .Or. Substr(cPicture,nPosDec,1) == ","
			Exit
		Else
			nQtdDecimais++
		EndIf
	Next nPosDec
EndIf

//Tira pontos e virgulas do valor
cTemp := StrTran(cValor,",","")
cTemp := StrTran(cTemp,".","")

//Nao tem separador de decimais na picture do valor
If nQtdDecimais == 0
	cTxtLog  := "A picture para valor(numérico) no layout de configuração deve indicar a quantidade de casas decimais, ex: @E 999,999,999.99 "
	cTxtLog  += "ou o valor do arquivo do retorno do fornecedor deve indicar as casas decimais."
	MSGSTOP(cTxtLog )
	//T_EDIGrvLog(cTxtLog, cArqLogRet)
	lRet  := .F.
Else
	//Acrescenta ponto(".") como separador de decimais
	cTemp      := Stuff(PADL(AllTrim(cTemp),Len(cValor)),Len(cValor)-nQtdDecimais+1,0,".")
	nValorExp  := Val(cTemp)
EndIf

Return lRet