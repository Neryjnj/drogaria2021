#Include "Protheus.ch"
#Include "Rwmake.ch"  

#Define LK_CODBAR  "SLK->LK_CODBAR"
#Define A5_CODPRF  "SA5->A5_CODPRF"
#Define B1_CODP    "SB1->B1_COD"
#Define TOT_CONS  2

//----------------------------------------------------------
/*/{Protheus.doc} ImpTPreco

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
User Function ImpTPreco()
Local oDlg
Local oBmt1
Local oBmt2
Local oBmt3
Local oBmt4
Private cArqFonte  := Space(100)
Private cArqLayout := Space(100)
Private cCodForn   := Space(6)
Private cCodLoja   := Space(2)
Private cNomeForn  := Space(40)
Private cDataIni   := DDatabase 
Private cDataFim   := CTOD("  /  /  ")
Private cHoraIni   := "00:00"
Private cHoraFim   := "23:59"
Private cCodTab
Private cCodItem

	DEFINE MSDIALOG oDlg FROM 1,1 TO 325,385 TITLE "Importação de Tabela de Preços" PIXEL
	
	@ 012,20 SAY "Cód. Fornec.:"
	@ 012,59 SAY "Loja:"
	@ 012,80 SAY "Descricao Tabela:"
	@ 042,20 SAY "Data inicial:"
	@ 072,20 SAY "Data final:"
	@ 042,90 SAY "Hora inicial:"
	@ 072,90 SAY "Hora final:"
	@ 102,20 SAY "Arquivo Fonte:"
	@ 132,20 SAY "Arquivo de Retorno:"
	
	@ 020,20 MSGET cCodForn F3 "SA21" PICTURE "999999" VALID !Empty(cCodForn) .And. ValFornec(.T.) SIZE 30,10 OF oDlg PIXEL
	@ 020,59 MSGET cCodLoja PICTURE "!!" VALID !Empty(cCodLoja) .And. ValFornec(.F.) SIZE 15,10 OF oDlg PIXEL
	@ 020,80 MSGET cNomeForn PICTURE "@!" VALID !Empty(cNomeForn) SIZE 60,10 OF oDlg PIXEL
	
	@ 050,20 MSGET cDataIni VALID !Empty(cDataIni) .And. Iif(!Empty(cDataFim), cDataFim >= cDataIni, .T.) SIZE 50,10 OF oDlg PIXEL
	@ 080,20 MSGET cDataFim VALID Iif(!Empty(cDataFim), cDataFim >= cDataIni, .T.) SIZE 50,10 OF oDlg PIXEL
	
	@ 050,90 MSGET cHoraIni PICTURE "99:99" VALID !Empty(cHoraIni) .And. (cHoraFim >= cHoraIni) SIZE 50,10 OF oDlg PIXEL
	@ 080,90 MSGET cHoraFim PICTURE "99:99" VALID !Empty(cHoraFim) .And. (cHoraFim >= cHoraIni) SIZE 50,10 OF oDlg PIXEL
	
	@ 110,20 MSGET cArqFonte PICTURE "@!" SIZE 120,10 OF oDlg PIXEL
	oBmt3 := SButton():New(110,140,14, {|| cArqFonte := cGetFile("Arquivos Fonte |*.TXT|","Escolha o arquivo Fonte.",0,"SERVIDOR",.T.) },,)
	@ 140,20 MSGET cArqLayout PICTURE "@!" SIZE 120,10 OF oDlg PIXEL
	oBmt4 := SButton():New(140,140,14, {|| cArqLayout := cGetFile("Arquivos de Retorno |*.RET|","Escolha o arquivo de Retorno.",0,"SERVIDOR",.T.) },,)

	oBmt1 := SButton():New(12,155,01, {|| ValEntrada() },,)
	oBmt2 := SButton():New(32,155,02, {|| oDlg:End() },,)
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return (.T.)


//***********************************************************//
// Rotina: ValEntrada()     					             //
//-----------------------------------------------------------//
// Rotina para validar os campos de entrada.		         //
//***********************************************************//
Static Function ValEntrada()
	
	If !ValFornec(.F.)
		MsgAlert("O Fornecedor com o código [" + cCodForn + "] e a loja [" + cCodLoja + "] não existe!")
	Else
		If RTrim(cNomeForn) == ""
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

Return (.T.)


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

	DbSelectArea("DA0")
	DbSetOrder(1)
	
	RecLock("DA0", .T.)
	
	DA0->DA0_CODTAB := cCodTab
	DA0->DA0_FILIAL := xFilial("DA0")
	DA0->DA0_DESCRI := cNomeForn
	DA0->DA0_DATDE  := cDataIni
	DA0->DA0_DATATE := cDataFim
	DA0->DA0_HORADE := cHoraIni
	DA0->DA0_HORATE := cHoraFim
	DA0->DA0_TPHORA := "1"
	DA0->DA0_ATIVO  := "1"
	
	For nI := 1 To Len(aRegistro)
		cCampo := AllTrim(aRegistro[nI][3])
		If cCampo != "" .And. ColumnPos(SubStr(cCampo, 6, Len(cCampo) - 5)) != 0
			&(cCampo) := FormCampo(aRegistros[nI][1], aRegistros[nI][2], RTrim(aRegistros[nI][4]))
		EndIf
	Next nI
	
	DA0->DA0_DESCRI := cNomeForn
	
	MsUnLock("DA0")
	
	RestArea(aArea)
	
Return (.T.)


//****************************************************//
// Rotina: ProcItemTab                                //
//----------------------------------------------------//
// Rotina para o precessamento dos itens da Tabela de //
// Preços  											  //
// 													  //
// Parâmetros: 										  //
//		aRegistros -> Os dados e campos da tabela de  //
//					  itens (DA1) 					  //
//****************************************************//
Static Function ProcItemTab(aRegistros)
Local aArea    := GetArea()
Local nPosC
Local cCodProd := ""
Local cCampo   := ""         
Local nI	   := 0


	// Verifica a existência do campo A5_CODPRF - Código do Produto no Fornecedor
	nPosC := AScan(aRegistros, {|x| AllTrim(x[3]) == A5_CODPRF})
		
	If nPosC != 0
		
		DbSelectArea("SA5")
		DbSetOrder(8)
		DbGoTop()
			
		If AllTrim(aRegistros[nPosC][1]) != ""
			If DbSeek(xFilial("SA5") + cCodForn + cCodLoja + aRegistros[nPosC][1])
			
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
		nPosC := AScan(aRegistros, {|x| AllTrim(x[3]) == LK_CODBAR})
		
		If nPosC != 0
		
			DbSelectArea("SLK")
			DbSetOrder(1)
			DbGoTop()
			
			If AllTrim(aRegistros[nPosC][1]) != ""
				If DbSeek(xFilial("SLK") + aRegistros[nPosC][1])
			
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
	If cCodProd != ""
	
		lProcTab := .T.
	
		DbSelectArea("DA1")
		DbSetOrder(1)
		
		RecLock("DA1", .T.)
		
		cCodItem := Soma1(cCodItem, Len(DA1->DA1_ITEM))
	         
	    DA1->DA1_ITEM   := cCodItem
		DA1->DA1_FILIAL := xFilial("DA1")	
		DA1->DA1_CODTAB := cCodTab
		DA1->DA1_CODPRO := cCodProd
		DA1->DA1_ATIVO  := "1"
		DA1->DA1_TPOPER := "4"
		DA1->DA1_MOEDA  := 1
		DA1->DA1_DATVIG := DDatabase
		DA1->DA1_QTDLOT := 999999.99
		
		For nI := 1 To Len(aRegistros)
			cCampo := AllTrim(aRegistros[nI][3])
			If cCampo != "" .And. cCampo != B1_CODP .And. ColumnPos(SubStr(cCampo, 6, Len(cCampo) - 5)) != 0
			   &(cCampo) := FormCampo(aRegistros[nI][1], aRegistros[nI][2], RTrim(aRegistros[nI][4]))
			EndIf
		Next nI
		
		MsUnLock("DA1")
		
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
Public lProcTab  := .F.

	aRest := EDIRestArq(cArqLayout)
	If Len(aRest) > 0
		cArqHdl := FOpen(cArqFonte, 0)
		If cArqHdl != 1
			FSeek(cArqHdl, 0, 0)
			
			aRegistro := {}

			// Processa ao cabecalho			
			If Len(aRest[1]) == 0
					
			    For nI := 1 To Len(aRest[1])
			    	If AllTrim(aRest[1][nI][1]) != ""
			    		cConteudo := FReadStr(cArqHdl, aRest[1][nI][4])
			    		Aadd(aRegistro, { cConteudo, aRest[1][nI][6], aRest[1][nI][7], aRest[1][nI][8] })
			    	EndIf
			    Next nI
	  				    
			    cConteudo := FReadStr(cArqHdl, 2)
			  
			EndIf
			
			Begin Transaction
			
				DbSelectArea("DA0")
				cCodTab  := GETSXENUM("DA0", "DA0_CODTAB")
				cCodItem := Repl("0", Len(DA1->DA1_ITEM))
				aRegTab  := AClone(aRegistro)

				// Processa todos os itens (preços)
			    While cConteudo != ""

			    	aRegistro := {}

				    For nI := 1 To Len(aRest[2])
			    		cConteudo := FReadStr(cArqHdl, aRest[2][nI][4])
			    		Aadd(aRegistro, { cConteudo, aRest[2][nI][6], aRest[2][nI][7], aRest[2][nI][8] })
				    Next nI

				    ProcItemTab(aRegistro)

				    cConteudo := FReadStr(cArqHdl, 2)
	
				EndDo
				           
				// Processa a inclusão da tabela caso tenha incluído algum preço
				If lProcTab
					ProcTab(aRegTab)
				EndIf
				
			End Transaction
	  				    
			FClose(cArqHdl)

			If lProcTab			
				MsgAlert("Importação realizada com sucesso!")
			Else
				MsgAlert("Não haviam dados a serem importados!")
			EndIf
		Else
			MsgAlert("Erro ao abrir o arquivo fonte [" + cArqFonte + "]!")
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
	If Len(aRest) != 3
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
	
	RestArea(aArea)
	
Return lRet

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
 		Case cTipoDado == "1"
			uRet := TransForm(aRegistros[nI][1], aRegistros[nI][3])
			
		Case cTipoDado == "2"
		    nPos   := At(".", cPicture)
			cPart1 := TransForm(SubStr(cValor, 1, nPos-1), SubStr(cPicture, 1, nPos-1))
			cPart2 := TransForm(SubStr(cValor, nPos+1, Len(cPicture)-nPos), SubStr(cPicture, nPos+1, Len(cPicture)-nPos))
			uRet   := Val(cPart1+"."+cPart2)
			
		Case cTipoDado == "3"
			nPos   := At("D", Upper(cPicture))
			cPart1 := SubStr(cValor, nPos, 2)
			nPos   := At("M", Upper(cPicture))
			cPart2 := SubStr(cValor, nPos, 2)
			nPos   := At("A", Upper(cPicture))
			cPart3 := SubStr(cValor, nPos, (Len(cPicture)-nPos)+1)
			uRet   := CTOD(cPart1+"/"+cPart2+"/"+cPart3)
			
		Case cTipoDado == "4"
			uRet := TransForm(aRegistros[nI][1], aRegistros[nI][3])
	End Case

Return uRet