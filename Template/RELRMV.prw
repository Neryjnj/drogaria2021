#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ RELRMV   ³ Autor    ³ fabiana.silva     ³ Data ³ 04/07/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Mensal de Vendas de Medicamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function RELRMV()
Local aOrdem 		:= {"Descriminação"}
Local aDevice 		:= { "DISCO", "SPOOL", "EMAIL", "EXCEL", "HTML", "PDF"}
Local cRelName  	:= "RELRMV"
Local bParam		:= {|| Pergunte(cRelName, .T.)}
Local cDevice   	:= ""
Local cSpool		:= ""
Local cPathDest 	:= GetSrvProfString("StartPath","\system\")
Local cSession  	:= GetPrinterSession()
Local lAdjust   	:= .F.
Local nFlags    	:= PD_ISTOTVSPRINTER//+PD_DISABLEPAPERSIZE
Local nLocal    	:= 1
Local nOrdem 		:= 1
Local nOrient   	:= 1
Local nPrintType	:= 6
Local oPrinter 		:= Nil
Local oSetup    	:= Nil
Local lProssegue	:= .T.

cSpool := SuperGetMV("MV_REST",,"\SPOOL\")
cSpool := GetSrvProfString("RootPath","") + "\" + cSpool + "\"
If !ExistDir(cSpool) .And. (MakeDir(cSpool) <> 0)
	lProssegue := .F.
	MsgAlert(	"Verifique!" + CHR(10) + CHR(13) +;
			 	"Atenção não foi possível criar o diretório [" + cSpool + "]" + CHR(10) + CHR(13) +;
			 	"Crie o diretório [" + cSpool + "] manualmente")
EndIf

/* Verifica se usuario tem permissao 
 de farmaceuto para incluir registros */
If lProssegue .And. !T_DroVERPerm()
	lProssegue := .F.
EndIf

If lProssegue
	cSession		:= GetPrinterSession()
	// Obtem ultima configuracao de tipo de impressão (spool ou pdf) gravada no arquivo de configuracao
	cDevice			:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	// Obtem ultima configuracao de orientacao de papel (retrato ou paisagem) gravada no arquivo de configuracao
	nOrient			:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	// Obtem ultima configuracao de destino (cliente ou servidor) gravada no arquivo de configuracao
	nLocal			:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nPrintType  	:= aScan(aDevice,{|x| x == cDevice })     
	
	oPrinter := FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T.)
	
	// Cria e exibe tela de Setup Customizavel - Utilizar include "FWPrintSetup.ch"
	oSetup := FWPrintSetup():New (nFlags,cRelName)
	
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrient)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	oSetup:SetOrderParms(aOrdem,@nOrdem)
	oSetup:SetUserParms(bParam)
	
	If oSetup:Activate() == PD_OK 
		// Grava ultima configuracao de destino (cliente ou servidor) no arquivo de configuracao
		fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
		// Grava ultima configuracao de tipo e impressao (spool ou pdf) no arquivo de configuracao
		fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
		// Grava ultima configuracao de orientacao de papel (retrato ou paisagem) no arquivo de configuracao
		fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
		// Atribui configuracao de destino (cliente ou servidor) ao objeto FwMsPrinter
		oPrinter:lServer := oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER
		// Atribui configuracao de tipo de impressao (spool ou pdf) ao objeto FwMsPrinter
		oPrinter:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
		// Atribui configuracao de orientacao de papel (retrato ou paisagem) ao objeto FwMsPrinter
		If oSetup:GetProperty(PD_ORIENTATION) == 1
			oPrinter:SetPortrait()
		Else 
			oPrinter:SetLandscape()
		EndIf
		// Atribui configuracao de tamanho de papel ao objeto FwMsPrinter
		oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
		oPrinter:setCopies(Val(oSetup:cQtdCopia))
		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oPrinter:nDevice := IMP_SPOOL
			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]
		Else 
			oPrinter:nDevice := IMP_PDF
			oPrinter:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			oPrinter:SetViewPDF(.T.)
		Endif
		
		RptStatus({|lEnd| RMVProc(@lEnd,nOrdem, @oPrinter, cRelName)},"Imprimindo Relatório...")
		MsgInfo("Relatório gerado com sucesso")
	Else 
		MsgInfo("Relatório cancelado pelo usuário.")//"Relatório cancelado pelo usuário." 
		oPrinter:Cancel()
	EndIf

	oSetup  := Nil
	oPrinter:= Nil
EndIf

Return lProssegue

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    | RMVProc  ³ Autor    ³ fabiana.silva     ³ Data ³ 04/07/17   ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o processamento do relatorio	                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMV                                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RMVProc(lEnd, nOrdem, oPrinter, cRelName)
Local nPagina 	:= 1 //Contador de Páginas
Local nAturaCab := 45 //Altura do Cabeçalho
Local oFontN 	:= TFont():New('Arial',,6,.T.,.T.) //Fonte
Local oFontR 	:= TFont():New('Arial',,8,.T.,.T.) //Fonte
Local nLinIni 	:= 0 //Linha Inicial
Local nLinFin 	:= 0 //Linha Final
Local nI 		:= 0 //Contador I
Local nC 		:= 0 //Contador 2
Local aCab		:= Array(12)  //colunas do relatorio
Local nTotCol 	:= 0 //total de colunas
Local nTamEnd 	:= 35 //Tamanho do endereco
Local cEndereco := "" //Dados do Endereço
Local nLinEnd 	:= 10 //Linha do Endereço
Local cWhereSB1 := "" //Query do SB1
Local nMaxLin	:= 0 //Maximo de Linhas
Local nMaxCol	:= 0 //Maxmo de Colunas
Local li		:= 15 //Linhas

Private aEndereco := {} //Dados do Endereco

nMaxLin	:= Int(oPrinter:nPageHeight/oPrinter:nFactorVert) 
nMaxCol	:= Int(oPrinter:nPageWidth/oPrinter:nFactorHor)-20

nI ++
aCab[nI] := 	 					{  10,  12, "N° do Código da D.C.B", oFontN,30,nAturaCab, 2, 0, "AllTrim((cAliasProd)->B1_CODPRIN)", SB1->(TamSx3("B1_CODPRIN")[1])+10 }
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0, "Descrição da D.C.B", oFontN,0,nAturaCab,0,0, "AllTrim((cAliasProd)->MHA_PATIVO)", MHA->(TamSx3("MHA_PATIVO")[1])+20}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0, "Nome do Medicamento", oFontN,0,nAturaCab,0,0,"AllTrim((cAliasProd)->LK9_DESCRI)", LK9->(TamSx3("LK9_DESCRI")[1])+20}
nTotCol += aCab[nI, 10]+2					 
nI ++
aCab[nI] := 						 {0, 0,"Apresentação, Concentração",oFontN,45,nAturaCab,2,0,"AllTrim((cAliasProd)->MHB_APRESE)+','+AllTrim((cAliasProd)->B1_CONCENT)", SB1->(TamSx3("B1_CONCENT")[1]) + MHB->(TamSx3("MHB_APRESE")[1])}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0,"Qtde Vend.",oFontN,0,nAturaCab,0,0,"Alltrim(cValtoChar((cAliasProd)->LK9_QUANT))", LK9->(TamSx3("LK9_QUANT")[1])+5}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0,"Nº Lote Medicamento",oFontN,35,nAturaCab,2,0,"AllTrim((cAliasProd)->LK9_LOTE)", LK9->(TamSx3("LK9_LOTE")[1])+10}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0,"Nº NF ou Fatura",oFontN,35,nAturaCab,2,0,"AllTrim((cAliasProd)->LK9_DOC)",LK9->(TamSx3("LK9_DOC")[1])+10}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0,"Data NF ou Fatura",oFontN,25,nAturaCab,2,0,"DtoC(StoD((cAliasProd)->LK9_DATA))", 10+5}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0,0,"Data e nº do Visto",oFontN,30,nAturaCab,2,0,"space(20)", 10+5}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0,"Comprador End Completo",oFontN,0,nAturaCab,0,0,"aEndereco[01]", LK9->(TamSx3("LK9_END")[1])*2}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 { 0, 0,"CNPJ",oFontN,0,nAturaCab,0,0,"AllTrim((cAliasProd)->A1_CGC)", SA1->(TamSx3("A1_CGC")[1])+10}
nTotCol += aCab[nI, 10]+2
nI ++
aCab[nI] := 						 {0 , 0,"UF",oFontN,0,nAturaCab,0,0,"(cAliasProd)->A1_EST", SA1->(TamSx3("A1_EST")[1]+5)}
nTotCol += aCab[nI, 10]+2				 

Pergunte(cRelName,.F.)

For nI := 1 to Len(aCab)
	nC := aCab[nI, 10]/nTotCol //Percentual da coluna
	If aCab[nI, 05] == 0
		aCab[nI, 05] :=  ( nC *  oPrinter:nPageWidth  ) //Largura da Coluna (Pixel)
	EndIf

	If aCab[nI, 01] == 0
		aCab[nI, 01] := aCab[nI-1][01] + aCab[nI-1, 10]
		aCab[nI, 02] := aCab[nI, 01]+2
	EndIf
	aCab[nI, 10] := Int(nC  * (nMaxCol-20)) //Tamanho da coluna inicial	
Next nI

SetRegua(100)	

cAliasProd := GetNextAlias()

cQProd := " SELECT B1_CODPRIN, MHA_PATIVO, LK9_DESCRI, MHB_APRESE, B1_CONCENT, LK9_QUANT, LK9_LOTE, LK9_DOC, LK9_DATA , LK9_NOME, LK9_END, A1_COMPLEM, A1_BAIRRO, A1_MUN, A1_CEP,  A1_CGC, A1_EST " 
cQProd += " FROM  " + RetSqlName("LK9") + " LK9 "
cQProd += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
cQProd += " ON SB1.B1_COD = LK9.LK9_CODPRO "
cQProd += " INNER JOIN " + RetSqlName("SL1") + " SL1 "
cQProd += " ON SL1.L1_NUM = LK9.LK9_NUMORC "
cQProd += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQProd += " ON SL1.L1_CLIENTE = SA1.A1_COD  AND SL1.L1_LOJA  = SA1.A1_LOJA "
cQProd += " INNER JOIN " + RetSqlName("MHA") + " MHA "
cQProd += " ON SB1.B1_CODPRIN = MHA.MHA_CODIGO "
cQProd += " INNER JOIN " + RetSqlName("MHB") + " MHB "
cQProd += " ON SB1.B1_CODAPRE = MHB.MHB_CODAPR "
cQProd += " WHERE LK9.D_E_L_E_T_ <> '*' "
cQProd += " AND LK9.LK9_FILIAL = '" + xFilial("LK9") + "'"
cQProd += " AND LK9_DATA BETWEEN '" + DTOS(FirstDay(MV_PAR01)) + "' AND '" + DTOS(LastDay(MV_PAR01)) + "'"
cQProd += " AND SL1.D_E_L_E_T_ <> '*' "
cQProd += " AND SL1.L1_FILIAL = '" + xFilial("SL1") + "'"
cQProd += " AND SB1.D_E_L_E_T_ <> '*' "
cQProd += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
cQProd += " AND (B1_PSICOTR = '1' OR (B1_CLASSTE BETWEEN '1' AND '2' )) "
cQProd += " AND MHA.D_E_L_E_T_ <> '*' "
cQProd += " AND MHA.MHA_FILIAL = '" + xFilial("MHA") + "'"
cQProd += " AND MHB.D_E_L_E_T_ <> '*' "
cQProd += " AND MHB.MHB_FILIAL = '" + xFilial("MHB") + "'"
cQProd += " AND SA1.D_E_L_E_T_ <> '*' "
cQProd += " AND SA1.A1_FILIAL = '" + xFilial("SA1")+ "'"
cQProd += " AND LK9_TIPMOV = '2' AND LK9_DOC <> ' ' ORDER BY SB1.B1_CODPRIN, LK9.LK9_DOC, LK9.LK9_DATA"

cQProd := ChangeQuery(cQProd)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQProd),cAliasProd,.T.,.T.)

If (cAliasProd)->(EOF())
	Alert("Não há itens a serem impressos")
	Return(.T.)
EndIf

IncRegua()

cabecCo(nPagina,oPrinter, aCab, oFontR, @li, @nMaxCol, @nMaxCol)

While (cAliasProd)->(!EOF())
	Li+=5
	aEndereco := {}
	//Imprime a Linha 
	 nTamEnd := 48
	cEndereco := (cAliasProd)->( AllTrim(LK9_NOME) + ' - ' + Alltrim( AllTrim(LK9_END)+ " " + AllTrim(A1_COMPLEM) + " " + AllTrim(A1_BAIRRO)) )+;
				 (cAliasProd)->( "-"+AllTrim(A1_MUN)+"/"+AllTrim(A1_EST) + " " +  AllTrim(Transform( A1_CEP, "@R 99999-999")))
 
	Do While !Empty(cEndereco)
		aAdd ( aEndereco , PADR(cEndereco, nTamEnd ))
		cEndereco := Substr(cEndereco,  nTamEnd+1)
	EndDo
	
	If Len(aEndereco) = 0
		aAdd ( aEndereco , "")
	EndIf
	
	For nI := 1 to Len(aCab) 
		oPrinter:Say(li+2,aCab[nI, 02],&(aCab[nI, 09]), aCab[nI, 04])
	Next
	
	For nI := 2 to Len(aEndereco)
		oPrinter:Say(li+ ( (nI-1)* 8 ) ,aCab[nLinEnd, 02],aEndereco[nI], aCab[nLinEnd, 04])
	Next
	
	nLinIni := li-5
	nLinFin := li+5 +  ( (Len(aEndereco)-1)*8 )
	
	For nI := 1 to Len(aCab)  
		oPrinter:Line( nLinIni,aCab[nI, 01], nLinFin, aCab[nI, 01])
	Next

	oPrinter:Line( nLinIni, nMaxCol-20, nLinFin, nMaxCol-20) // DIREITA DA QUANTIDADE DISPENSADA
	Li+= ( 5 + ( (Len(aEndereco)-1)*8 )) 
	oPrinter:Line( li, aCab[01, 01], li, nMaxCol-20)
					
	IF li >= (nMaxLin-60)
		ImpRodape(oPrinter,nPagina, oFontR, @li, @nMaxCol, @nMaxCol)
		oPrinter:EndPage()
		Li := 15
		nPagina++
		CabecCo(nPagina,oPrinter,aCab, oFontN, @li, @nMaxCol, @nMaxCol)		// imprime cabecalho do Relatorio
	EndIF
	
	(cAliasProd)->(dbSkip())
EndDo

ImpRodape(oPrinter, nPagina, oFontR, @li, @nMaxCol, @nMaxCol)

oPrinter:EndPage()

If Select((cAliasProd)) > 0
	(cAliasProd)->(dbCloseArea())
EndIf

oPrinter:Print()

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ Fun‡…o   ³ CabecCo  ³ Autor ³ fabiana.silva       ³ Data ³ 04/07/17   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho do Medicamento		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CabecCo()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMV                                                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CabecCo(nPagMe,oPrinter,aCab, oFontN, li, nMaxCol, nMaxCol)
Local cTitulo2 	:= Alltrim(UPPER(SM0->M0_NOMECOM))
Local cCNPJCM	:= Alltrim(SM0->M0_CGC)    
Local nAltura	:= 0 //Altura
Local nLarg		:= 0 //Largura
Local nLinha	:= 0 //Linha
Local nPixel	:= 0 //Pixel
Local aMeses	:= {'JANEIRO'	,'FEVEREIRO','MARÇO'	,;
					'ABRIL'		,'MAIO'     ,'JUNHO'	,;
					'JULHO'		,'AGOSTO'   ,'SETEMBRO'	,;
					'OUTUBRO'	,'NOVEMBRO' ,'DEZEMBRO'	}
Local nI 		:= 0 //Contador de Cabeçalho
Local nLinIni 	:= 0 //Linha Inicial
Local nLinFin 	:= 0 //Linha Finaç
Local nColIni 	:= 0 //Coluna Inicial
Local nColCar 	:= aCab[ Len(aCab)-2, 01]
Local oFontCr	:= TFont():New('Courier new',,6,.T.)
Local nLarQrd1  := 10 //Largura do Quadrado1
Local nAltQrd1  := 40 //Altura do Quadrado1
Local nColFQrd  := 0 //Coluna final do Quadrado
Local nLargFig 	:= 30 //Largura da Figura
Local nColFin	:= 0//Coluna Final
Local nColS2 	:= 0 //Coluna da Seção 2
Local oFontC 	:= NIL //Fonte 
Local oFontT 	:= NIL //Fonte
Local cMvLjDroLF:= SuperGetMV("MV_LJDROLF",,"")	//Número da Licença de Funcionamento

If Len(cCNPJCM) == 14
	cCNPJCM := Transform( cCNPJCM, "@R 99.999.999/9999-99") 
EndIf

oFontT := TFont():New('Courier new',,8,.T.)

oFontC := TFont():New('Courier new',,12,.T.,.T.)
oFontC2 := TFont():New('Courier new',,10,.T.)
oPrinter:StartPage()
li+= 20
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)


nColCar := (nMaxCol-20) - 120
nColFin := nColCar-10

oPrinter:Line( li, nColCar+50, li, nColCar+50+nLarQrd1)
oPrinter:Line( li, nColCar+50, li+nLarQrd1, nColCar+50)

oPrinter:Line( li, nMaxCol-20-nLarQrd1, li, nMaxCol-20)
oPrinter:Line( li, nMaxCol-20, li+nLarQrd1, nMaxCol-20)
oPrinter:SayAlign(li+15,nColCar+50,"CARIMBO DA VISA",oFontCr, (nMaxCol-20)-(nColCar+50),,,2,2)

oPrinter:Line( li+nAltQrd1, nColCar+50, li+nAltQrd1, nColCar+50+nLarQrd1)
oPrinter:Line( li+nAltQrd1-nLarQrd1, nColCar+50, li+nAltQrd1, nColCar+50)
oPrinter:Line(  li+nAltQrd1, nMaxCol-20-nLarQrd1,  li+nAltQrd1, nMaxCol-20)
oPrinter:Line(  li+nAltQrd1-nLarQrd1, nMaxCol-20, li+nAltQrd1, nMaxCol-20)

nColIni := aCab[01,01]
	

nLarQrd1  := 30 //Largura do Quadrado1
nAltQrd1  := 120//Altura do Quadrado1
nColFQrd := 250

oPrinter:Line( li, nColIni, li			, nColFQrd+nLarQrd1)
oPrinter:Line( li, nColIni, li+nAltQrd1	, nColIni)

oPrinter:SayAlign(li+15,nColIni,cCNPJCM,oFontC,280,,,2)
oPrinter:SayAlign(li+30,nColIni,Alltrim(UPPER(SM0->M0_NOME)),oFontC,280,,,2)
oPrinter:SayAlign(li+45,nColIni,Alltrim(UPPER(SM0->M0_ENDCOB)),oFontC,280,,,2)
oPrinter:SayAlign(li+60,nColIni,Alltrim(UPPER(SM0->M0_CIDCOB))+ " - " + Alltrim(UPPER(SM0->M0_ESTCOB)),oFontC,280,,,2)

oPrinter:Line( li, nColFQrd+nLarQrd1, li+nAltQrd1, nColFQrd+nLarQrd1)
oPrinter:Line( li+nAltQrd1, nColIni, li+nAltQrd1, nColFQrd+nLarQrd1)

nColIni := nLarQrd1+nColFQrd+10

oPrinter:SayBitmap(li, nColIni, GetSrvProfString ("ROOTPATH","") + "\System\" + "brasao.jpg", nLargFig,  nLargFig)
Li+=15

oPrinter:Say(li,nColIni+nLargFig+5,"SECRETARIA DE SAÚDE: DO ESTADO DE SÃO PAULO",oFontT)
Li+=10
oPrinter:Say(li,nColIni+nLargFig+5,"AUTORIDADE SANITÁRIA: COVISA",oFontT)
Li+=15

oPrinter:SayAlign(li,nColIni,"RELAÇÃO MENSAL DE VENDAS DE ",oFontC,nColFin-nColIni,,,2,0)
Li+=15
oPrinter:SayAlign(li,nColIni,"MEDICAMENTOS SUJEITOS A CONTROLE ESPECIAL",oFontC,nColFin-nColIni,,,2,0)
Li+=15
oPrinter:SayAlign(li,nColIni,"(RMV)",oFontC,nColFin-nColIni,,,2,0)
Li+=15

Li+=5
oPrinter:Line( li, nColIni+60, li, nColFin-80)
oPrinter:Line( li, nColIni+60, li+12, nColIni+60)
oPrinter:Line( li, nColFin-80, li+12, nColFin-80)
//LINHA
oPrinter:SayAlign(li,nColIni,"INDÚSTRIA DISTRIBUIDORA",oFontC2,nColFin-nColIni,,,2,0)
Li+=12
oPrinter:Line( li, nColIni+60, li, nColFin-80)


oPrinter:Say(li,nColCar,"Mês/Ano:",oFontC)
oPrinter:Say(li,nColCar+50, aMeses[Month(MV_PAR01)]+"/"+STR(Year(MV_PAR01),4),oFontC2)
Li+=15

nColS2 := nColIni +  Int( ( (nMaxCol-20) - nColIni) / 2 ) + 5

oPrinter:Say(li,nColIni,cTitulo2,oFontC)
oPrinter:Say(li,nColS2,"AUT. DE FUNCIONAMENTO N.º: ",oFontC)
oPrinter:Say(li,nColCar+30,MV_PAR02,oFontC2)
Li+=15

oPrinter:Say(li,nColIni,Alltrim(UPPER(SM0->M0_ENDCOB))  ,oFontC)
oPrinter:Say(li,nColS2,"LICENÇA DE FUNCIONAMENTO N.º:",oFontC)
oPrinter:Say(li,nColCar+50,cMvLjDroLF,oFontC2)
Li+=15

oPrinter:Say(li,nColIni, AllTrim(Alltrim(UPPER(SM0->M0_BAIRCOB)) + " " ) + Alltrim(UPPER(SM0->M0_CIDCOB))+ "/" + Alltrim(UPPER(SM0->M0_ESTCOB))+ " " + Alltrim(UPPER(SM0->M0_TEL)),oFontC)
oPrinter:Say(li,nColS2,"AUTORIZAÇÃO ESPECIAL N.º:",oFontC)
oPrinter:Say(li,nColCar+30,MV_PAR03,oFontC2)
Li+=30

oPrinter:Line(li,aCab[01,01],li, nColIni-10)
oPrinter:Line(li,nColIni,li, nColS2-40)
Li+=10

LKB->(DbSetOrder(3)) //Filial+LKB_CUSERI
LKB->(DbSeek(xFilial("LKB")+__cUserID))
oPrinter:Say(li,aCab[01,01],Alltrim(UPPER(MV_PAR04)),oFontC)
oPrinter:Say(li,nColIni ,Alltrim(UPPER(LKB->LKB_NOME)),oFontC)
oPrinter:Say(li,nColIni + (nColS2-40 - (nColIni))," CRF  Nº:"+LKB->LKB_CRF,oFontC)


Li+=10
oPrinter:Say(li,aCab[01,01],"Nome e Ass. do Representante Legal",oFontT)
oPrinter:Say(li,nColIni,"Nome e Ass. do Responsável Técnico",oFontT)

Li+=15

//Inicio do quadro dos medicamentos
oPrinter:Line( li, aCab[01, 01], li, nMaxCol-20)
Li+=5

nLinIni := li-5
nLinFin :=  li+45

For nI := 1 to len(aCab)
	oPrinter:Line( nLinIni, aCab[nI, 01], nLinFin, aCab[nI, 01])
	oPrinter:SayAlign(li,aCab[nI, 02],aCab[nI, 03],aCab[nI, 04],aCab[nI, 05],aCab[nI, 06],2, aCab[nI, 07], aCab[nI, 08])
Next nI

oPrinter:Line( nLinIni, nMaxCol-20, nLinFin, nMaxCol-20)
Li+=45
oPrinter:Line( li, 5, li, nMaxCol-20)

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ Fun‡…o   ³ ImpRodape  ³ Autor ³ fabiana.silva     ³ Data ³ 04/07/17   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho do Medicamento		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ ImpRodape()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMV                                                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpRodape(oPrinter,nPagMe, oFontC, li,;
 							nMaxCol, nMaxCol)
Li+=15
oPrinter:SayAlign(li,0,"Pág: " + Alltrim(STR(nPagMe)),oFontC,nMaxCol-20,200,,1) 

Return