#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"   

/////////////////////////////////////////////////////////////////////////////
// Rotina: RelEtq                                                          //
// Rotina para geração de etiquetas de produtos                            //
//-------------------------------------------------------------------------//
// Parametros:                                                             //
//		aLstPrd -> aCols de Pedidos de Compra e/ou Nota Fiscal de Entrada  //
/////////////////////////////////////////////////////////////////////////////
Template Function RelEtq(aLstPrd)
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := ""
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd := {}

Private nMargSup     // Margem superior
Private nMargInf     // Margem inferior
Private nDistVert    // Distancia vertical
Private nLargEtiq    // Largura da etiqueta
Private nEtiqLin     // Etiquetas por linha
Private nLinPag      // Linha por pagina
Private nAltPag      // Altura da página em linhas
Private nLargPag     // Largura da pagina em linhas
Private nMargLat     // Margem lateral

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "RelEtq" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
//Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RelEtq" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 	 := ""
Private	aCabec
Private	aDetail
Private	aTrail
Private	aImpr
Private aLstPrdN   := {}
Private aLstCab // Cabecalho dos campos disponiveis para a etiqueta

	// Confirma a escolha do arquivo de layout??
	If !SelArq()
		Return
	Else
		CriaCabec()
		CriaLstPrd(aLstPrd)  // Lista de produtos criada
		nMargSup  := Val(aImpr[1][4])
		nMargInf  := Val(aImpr[2][4])
		nMargLat  := Val(aImpr[3][4])
		nDistVert := Val(aImpr[4][4])
		nLargEtiq := Val(aImpr[5][4])
		nEtiqLin  := Val(aImpr[6][4])
		nLinPag   := Val(aImpr[7][4])
		nAltPag   := Val(aImpr[8][4])
		limite    := Val(aImpr[9][4])
		nLargPag  := Val(aImpr[9][4]) 
		If Val(aImpr[10][4])==0
	    	tamanho := "P"
	 	ElseIf Val(aImpr[10][4])==1
	 		tamanho := "M"
	 	Else
	 		tamanho := "G"
	 	EndIf
	EndIf
	
	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


/////////////////////////////////////////////////////
// Rotina: RunReport                               //
/////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nI,nX,nY,nJ
Local cConteudo
Local aEtqVal

	SetRegua(Len(aLstPrdN))

	Cabec("","","",NomeProg,Tamanho,nTipo)
	
	@ 0,0 PSAY " "

	nJ := 1
	
	While (nJ <= Len(aLstPrdN))
	
		   aEtqVal := Array(nAltPag,nLargPag)

		   nLin := nMargSup
		   nCol := nMargLat

		   If nLin > ((nDistVert*nLinPag)+nMargSup) // Salto de Página.
	   	      aEtqVal := Array(nAltPag,nLargPag)
		      nLin := (nMargSup + nMargInf)
		   Endif
		   
	   	   Begin Sequence

			   For nY := 1 To nLinPag
				   For nX := 1 To nEtiqLin
	
					   // Escreve o cabecalho
					   For nI := 1 To Len(aCabec)
					   	   cConteudo := FormatVal(aCabec[nI],nJ)
					   	   If (nLin+Val(aCabec[nI][2]) < nAltPag) .And. (nCol+Val(aCabec[nI][3]) < nLargPag)
						   	   aEtqVal[nLin+Val(aCabec[nI][2]),nCol+Val(aCabec[nI][3])] := cConteudo
						   EndIf
					   Next
	
					   // Escreve o detalhe
					   For nI := 1 To Len(aDetail)
					   	   cConteudo := FormatVal(aDetail[nI],nJ)
					   	   If (nLin+Val(aDetail[nI][2]) < nAltPag) .And. (nCol+Val(aDetail[nI][3]) < nLargPag)
					   	   	   aEtqVal[nLin+Val(aDetail[nI][2]),nCol+Val(aDetail[nI][3])] := cConteudo
					   	   EndIf
					   Next
	
					   // Escreve o rodape
					   For nI := 1 To Len(aTrail)
					   	   cConteudo := FormatVal(aTrail[nI],nJ)
					   	   If (nLin+Val(aTrail[nI][2]) < nAltPag) .And. (nCol+Val(aTrail[nI][3]) < nLargPag)
					   	       aEtqVal[nLin+Val(aTrail[nI][2]),nCol+Val(aTrail[nI][3])] := cConteudo
					   	   EndIf
					   Next
	
				   	   If lAbortPrint
					      @ nLin,00 PSAY ">>> Cancelado pelo operador <<<"
			    		  Exit
					   Endif
					   
					   IncRegua()
					          
					   // Posiciona no proximo produto
					   nJ++
						   
					   // Se ultrapassou o ultimo produto termina
	    			   If (nJ > Len(aLstPrdN))
							Break
					   EndIf
	
					   // Pula uma coluna
					   nCol += nLargEtiq
					Next
					
					// Volta pra coluna inicial
					nCol := nMargLat
	
					// Pula linha
					nLin += nDistVert
			   Next
			   
		   End Sequence
		   
		   // Faz a impressão de toda a página		   
	   	   For nY := 1 To nAltPag
				For nX := 1 To nLargPag
					If aEtqVal[nY][nX] != Nil
						@ nY,nX PSAY aEtqVal[nY][nX]
					Else
						@ nY,nX PSAY " "
					EndIf
				Next
		   Next

		   // Pula uma página
		   @ 0,0 PSAY " "
		   
	EndDo
	
	IncRegua()

	If aReturn[5]==1
	   dbCommitAll()
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

                                                 
/////////////////////////////////////////////////////////////////
// Rotina: SelArq                                              //
// Rotina para selecionar o arquivo de layout para emissao     //
// das etiquetas de produtos.                                  //
//-------------------------------------------------------------//
// Retorno:                                                    //
//		lProcessa -> indica se processa ou não o relatorio     //
/////////////////////////////////////////////////////////////////
Static Function SelArq()
Local oDlg
Local oGrp1
Local cArqLay   := GetMV("MV_RETQLAY")
Local oBmt1
Local lProcessa := .F.

	Define MSDialog oDlg Title "Selecionar arquivo de layout" From 0,0 To 90,305 Pixel

	oGrp1 := TGroup():New(05,04,30,150," Nome do arquivo: "	,oDlg,,,.T.)

	@ 13,10 MsGet cArqLay Picture "@!" Size 105,10 Of oDlg Pixel
	oBmt1 := SButton():New(13,120,14, {|| cArqLay := cGetFile("Arquivos Layout |*.ETQ|","Escolha o arquivo Layout.")},,)

	@ 33,094 BmpButton Type 1 Action RestFile(oDlg,cArqLay,@lProcessa)
	@ 33,124 BmpButton Type 2 Action Close(oDlg)

	Activate Dialog oDlg Centered

Return (lProcessa)


/////////////////////////////////////////////////////////////////
// Rotina: RestFile                                            //
// Rotina para leitura do arquivo de layout para emissão de    //
// etiquetas                                                   //
//-------------------------------------------------------------//
// Parametros:                                                 //
//		oDlg      -> objeto dialogo                            //
//		cNomeArq  -> nome do arquivo de layout                 //
//		lProcessa -> indica se a emissao do relatorio será     //
//					 processada                                //
/////////////////////////////////////////////////////////////////
Static Function RestFile(oDlg,cNomeArq,lProcessa)
Local nTamArq
Local nBytes := 0
Local xBuffer
Local nArq
Local aLinha

	If !File(cNomeArq)
		cNomeArq := ""
		MsgAlert("O arquivo não existe!")
		Return (.F.)
	EndIf

	nArq    := FOpen(cNomeArq,2+64)
	nTamArq := FSeek(nArq,0,2)
	FSeek(nArq,0,0)

	aCabec  := {}
	aDetail := {}
	aTrail  := {}
	aImpr   := {}

	// Preenche os arrays de acordo com a Identificador
	While nBytes < nTamArq
		xBuffer := Space(257)
		FRead(nArq,@xBuffer,257)
		aLinha := {SubStr(xBuffer,02,025),SubStr(xBuffer,027,03),;
		  		   SubStr(xBuffer,30,003),SubStr(xBuffer,033,03),;
				   SubStr(xBuffer,36,200),SubStr(xBuffer,236,20)}
		If SubStr(xBuffer,1,1) == CHR(1)			//Preenche o Cabecalho
			Aadd(aCabec,aLinha)
		ElseIf SubStr(xBuffer,1,1) == CHR(2)		//Preenche o Detalhe
			Aadd(aDetail,aLinha)							
		ElseIf SubStr(xBuffer,1,1) == CHR(3)		//Preenche o Rodape
			Aadd(aTrail,aLinha)														
		ElseIf SubStr(xBuffer,1,1) == CHR(5)		//Preenche os Parametros para Impressao
			Aadd(aImpr,aLinha)
		EndIf
		nBytes += 257
	EndDo

	If (Len(aCabec)==0 .And. Len(aImpr) == 0 .And. Len(aDetail) == 0 .And. Len(aTrail) == 0)
		MsgAlert("O arquivo de layout não possui nenhuma informação de configuração!")
		Return (.F.)
	EndIf

	SetMV("MV_RETQLAY",cNomeArq)
	
	aLinha := {{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
	
	If Empty(aCabec)
		aCabec  := aLinha
	EndIf
	
	If Empty(aDetail)
		aDetail := aLinha
	EndIf

	If Empty(aTrail)
		aTrail  := aLinha
	EndIf

	If Empty(aImpr)
		aImpr   := aLinha
	EndIf

	FClose(nArq)
	
	Close(oDlg)
	
	lProcessa := .T.
	
Return


//////////////////////////////////////////////////////////////
// Rotina: FormatVal                                        //
// Rotina para retornar o valor em caractere do Cabecalho,  //
// Detalhe e Rodape formatado c/ picture ou nao             //
//----------------------------------------------------------//
// Parametros:                                              //
//		aParte -> array com o Cabecalho/Detalhe/Rodape      //
//		nItem  -> posicao do produto atual                  //
// Retorno:                                                 //
//		cConteudo -> retorna o canteudo formatado (dado)    //
//////////////////////////////////////////////////////////////
Static Function FormatVal(aParte, nItem)
Local cConteudo := ""
Local cNomeCmp  := RTrim(aParte[5])
Local cPicture  := RTrim(aParte[6])
Local nPos

nPos := AScan(aLstCab, cNomeCmp)

If nPos <> 0
	If (AllTrim(cPicture) == "")
		cConteudo := aLstPrdN[nItem][nPos]
	Else
		cConteudo := Transform(aLstPrdN[nItem][nPos],cPicture)
	EndIf
EndIf

cConteudo := RTrim(cConteudo) 
		
Return cConteudo


//////////////////////////////////////////////////////////////////////////////
// Rotina: CriaLstPrd                                                       //
// Rotina para geração lista de produtos desmembrada por unidade de medida  //
//--------------------------------------------------------------------------//
// Parametros:                                                              //
//		aLstPrd -> aCols com os produtos a serem desmembrados               //
//////////////////////////////////////////////////////////////////////////////
Static Function CriaLstPrd(aLstPrd)
Local aArea  := GetArea()
Local nI
Local nJ
Local nH
Local nTotal // Total de etiquetas
Local aLinha
Local lSB5,lSB0,lProcessa

// Analisa cada produto da NF de Entrada ou do Ped. de Compras
For nI := 1 To Len(aLstPrd)
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aLstPrd[nI][2]))
	// Verifica se possui a 2ªUM para converter as quantidades
	If AllTrim(aLstPrd[nI][4]) != ""
		If (SB1->B1_TIPCONV == "M")
			nTotal := Round(aLstPrd[nI][5] * SB1->B1_CONV,0)  // (Quant na 2ªUM) * (Fator Conv.)
		Else
			nTotal := Round(aLstPrd[nI][5] / SB1->B1_CONV,0)  // (Quant na 2ªUM) / (Fator Conv.)
		EndIf
	Else
		nTotal := aLstPrd[nI][5] // Não possui 2ªUM
	EndIf

	// Posiciona na tabela de Preços um Vigencia
	DbSelectArea("SB0")
	DbSetOrder(1)
	lSB0 := DbSeek(xFilial("SB0")+SB1->B1_COD)

	// Posiciona na tabela de Complemento de Produtos
	DbSelectArea("SB5")
	DbSetOrder(1)
	lSB5 := DbSeek(xFilial("SB5")+SB1->B1_COD)

	// Ponto de Entrada para selecao de outras tabelas
	If ExistTemplate("RETQST01")
		ExecTemplate("RETQST01",.F.,.F.)
	EndIf

	DbSelectArea("SB1")

	// Cria todas as etiquetas
	aLinha := {}
	For nJ := 1 To nTotal
		aLinha := Array(Len(aLstCab))
		For nH := 1 To Len(aLstCab)
			If (At("SB0->", aLstCab[nH]) != 0)
				lProcessa := lSB0
			ElseIf (At("SB5->", aLstCab[nH]) != 0)
				lProcessa := lSB5
			Else
				lProcessa := .T.
			EndIf
			If lProcessa
				aLinha[nH] := &(aLstCab[nH])
			EndIf
		Next
		Aadd(aLstPrdN, aLinha)
	Next
Next

RestArea(aArea)

Return

////////////////////////////////////////////////////////////////
// Rotina: CriaCabec                                          //
// Rotina para criacao do cabecalho de itens da etiqueta      //
////////////////////////////////////////////////////////////////
Static Function CriaCabec
Local nI := 0
Local nJ := 0
Local aArrays := {aCabec,aDetail,aTrail}
                
aLstCab := {}

For nJ := 1 To 3
	For nI := 1 To Len(aArrays[nJ])
		Aadd(aLstCab,aArrays[nJ][nI][5])
	Next nI
Next nJ

Return