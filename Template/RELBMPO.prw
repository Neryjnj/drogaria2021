#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ RELBMPO  ³ Autor ³ Rodrigo Dias Nunes	³ Data ³ 11/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio BMPO					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function RELBMPO()
Local aOrdem 		:= {"Descriminação"}
Local aDevice 		:= {}
Local bParam		:= {|| Pergunte("RELBMPO", .T.)}
Local cDevice   	:= ""
Local cPathDest 	:= GetSrvProfString("StartPath","\system\")
Local cRelName  	:= "RELBMPO"
Local cSpool		:= ""
Local cSession  	:= GetPrinterSession()
Local lAdjust   	:= .F.
Local lProssegue	:= .T.
Local nFlags    	:= PD_ISTOTVSPRINTER //+PD_DISABLEPAPERSIZE
Local nLocal    	:= 1
Local nOrdem 		:= 1
Local nOrient   	:= 1
Local nPrintType	:= 6
Local oPrinter 		:= Nil
Local oSetup    	:= Nil

Private aArray		:= {}
Private li			:= 15
Private nMaxLin		:= 0
Private nMaxCol		:= 0
Private lItemNeg 	:= .F.

cSpool := SuperGetMV("MV_REST",,"\SPOOL\")
cSpool := GetSrvProfString("RootPath","") + "\" + cSpool + "\"
If !ExistDir(cSpool) .And. (MakeDir(cSpool) <> 0)
	lProssegue := .F.
	MsgAlert("Verifique!" + CHR(10) + CHR(13) +;
	 	"Atenção não foi possível criar o diretório [" + cSpool + "]" + CHR(10) + CHR(13) +;
	 	"Crie o diretório [" + cSpool + "] manualmente")
EndIf

//Verifica se usuario tem permissao de farmacêutico para incluir registros
If lProssegue .And. T_DroVERPerm()
	// se tiver,verifica se ele está no cadastro
	If !T_DroIsFrm()
		lProssegue := .F.
	EndIf
Else
	lProssegue := .F.
EndIf

If lProssegue
	AADD(aDevice,"DISCO") // 1
	AADD(aDevice,"SPOOL") // 2
	AADD(aDevice,"EMAIL") // 3
	AADD(aDevice,"EXCEL") // 4
	AADD(aDevice,"HTML" ) // 5
	AADD(aDevice,"PDF"  ) // 6
	
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
	//oSetup:SetPropert(PD_PAPERSIZE   , 2)
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
			nMaxLin	:= 800
			nMaxCol	:= 600
		Else 
			oPrinter:SetLandscape()
			nMaxLin	:= 600
			nMaxCol	:= 800
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
		
		RptStatus({|lEnd| RMNRAProc(@lEnd,nOrdem, @oPrinter)},"Imprimindo Relatório...")
	Else 
		MsgInfo("Relatório cancelado pelo usuário.")//"Relatório cancelado pelo usuário." 
		oPrinter:Cancel()
	EndIf
	
	oSetup:= Nil
	oPrinter:= Nil
EndIf

Return lProssegue

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    | RMNRAProc  ³ Autor ³ Rodrigo Dias Nunes	³ Data ³ 11/11/15 ³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o processamento do relatorio	                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RMNRAProc(lEnd, nOrdem, oPrinter)
Local nBegin	:= 0
Local cQProd	:= ""
Local nlX		:= 0
Local oFontT	:= TFont():New('Arial',,6,.T.)
Local oFontT2	:= TFont():New('Courier new',,15,.T.)
Local nPagina 	:= 1
Local cExer		:= ""
Local cAnual	:= ""
Local cTrim		:= ""
Local cPerDe	:= ""
Local cPerAte	:= ""
Local aMedic	:= {}

Private ImpTer	:= .T.

Pergunte("RELBMPO",.F.)

VerifPeriodo(@cExer,@cAnual,@cTrim,@cPerDe,@cPerAte)

SetRegua(100)	

cAliasProd := GetNextAlias()

cQProd := " SELECT"
cQProd += " B1_COD,B1_CODDCB,B1_QTDEMBA,B1_CONCENT"
cQProd += ",LK9_CODPRO,LK9_DESCRI,LK9_TIPMOV,LK9_NUMREC,LK9_DATARE,LK9_NOMMED,LK9_NUMPRO,LK9_QUANT,LK9_DOC"
cQProd += ",MHB_APRESE"
cQProd += ",LKD_DSCDCB"
cQProd += ",F1_FORNECE"
cQProd += ",A2_NOME,A2_CGC "
cQProd += "FROM "
cQProd += RetSqlName("LK9") + " LK9 "
cQProd += "INNER JOIN "
cQProd += RetSqlName("SB1") + " SB1 "
cQProd += "ON SB1.B1_COD = LK9.LK9_CODPRO "
cQProd += "AND SB1.D_E_L_E_T_ = LK9.D_E_L_E_T_ "
cQProd += "INNER JOIN "
cQProd += RetSqlName("LKD") + " LKD "
cQProd += "ON SB1.B1_CODDCB = LKD.LKD_CODDCB "
cQProd += "AND LKD.D_E_L_E_T_ = LK9.D_E_L_E_T_ "
cQProd += "INNER JOIN "
cQProd += RetSqlName("MHB") + " MHB "
cQProd += "ON SB1.B1_CODAPRE = MHB.MHB_CODAPR "
cQProd += "AND MHB.D_E_L_E_T_ = LK9.D_E_L_E_T_ "
cQProd += "INNER JOIN "
cQProd += RetSqlName("SF1") + " SF1 "
cQProd += "ON SF1.F1_DOC = LK9.LK9_DOC "
cQProd += "AND SF1.F1_SERIE = LK9.LK9_SERIE "
cQProd += "AND SF1.D_E_L_E_T_ = LK9.D_E_L_E_T_ "
cQProd += "INNER JOIN "
cQProd += RetSqlName("SA2") + " SA2 "
cQProd += "ON SA2.A2_COD = SF1.F1_FORNECE "
cQProd += "AND SA2.A2_LOJA = SF1.F1_LOJA "
cQProd += "AND SA2.D_E_L_E_T_ = LK9.D_E_L_E_T_ "
cQProd += "WHERE LK9.D_E_L_E_T_ <> '*' "
cQProd += "AND LK9_DATA BETWEEN '" + DTOS(CTOD(cPerDe)) + "' AND '" +DTOS(CTOD(cPerAte))+ "' "
cQProd += "ORDER BY LKD_CODDCB

cQProd := ChangeQuery(cQProd)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQProd),cAliasProd,.T.,.T.)

If (cAliasProd)->(EOF())
	MsgInfo("Não a itens a serem impressos")
	Return (.T.)
EndIf

IncRegua()

//If ImpTer
	ImpCapa(nPagina,oPrinter)	
	oPrinter:EndPage()
	Li := 15
//EndIf

/** BALANCO COMPLETO DE MEDICAMENTOS */
cabecCo(nPagina,oPrinter)

While (cAliasProd)->(!EOF())
	If Empty(aMedic)
		If (cAliasProd)->LK9_TIPMOV == "1"
			AADD(aMedic,{Alltrim((cAliasProd)->B1_CODDCB),;						
						Alltrim((cAliasProd)->LKD_DSCDCB),;
						AllTrim((cAliasProd)->LK9_DESCRI),;
						AllTrim((cAliasProd)->MHB_APRESE),;
						Alltrim((cAliasProd)->B1_QTDEMBA),;
						AllTrim((cAliasProd)->B1_CONCENT),;
						0,; // estoque inicial
						(cAliasProd)->LK9_QUANT,; //saida 
						0,; //entrada
						0,; //perda
						0,;  //saldo final
						AllTrim((cAliasProd)->LK9_CODPRO),;
						AllTrim((cAliasProd)->F1_FORNECE),;
						AllTrim((cAliasProd)->A2_NOME),;
						AllTrim((cAliasProd)->A2_CGC),;
						AllTrim((cAliasProd)->LK9_DOC)})
		ElseIf (cAliasProd)->LK9_TIPMOV == "2"
			AADD(aMedic,{Alltrim((cAliasProd)->B1_CODDCB),;						
						Alltrim((cAliasProd)->LKD_DSCDCB),;
						AllTrim((cAliasProd)->LK9_DESCRI),;
						AllTrim((cAliasProd)->MHB_APRESE),;
						Alltrim((cAliasProd)->B1_QTDEMBA),;
						AllTrim((cAliasProd)->B1_CONCENT),;
						0,; //estoque inicial
						0,; //entrada
						(cAliasProd)->LK9_QUANT,; //saida
						0,; //perda	
						0,; //saldo final	
						AllTrim((cAliasProd)->LK9_CODPRO)})
		ElseIf (cAliasProd)->LK9_TIPMOV == "4"
			AADD(aMedic,{Alltrim((cAliasProd)->B1_CODDCB),;						
						Alltrim((cAliasProd)->LKD_DSCDCB),;
						AllTrim((cAliasProd)->LK9_DESCRI),;
						AllTrim((cAliasProd)->MHB_APRESE),;
						Alltrim((cAliasProd)->B1_QTDEMBA),;
						AllTrim((cAliasProd)->B1_CONCENT),;
						0,; //estoque inicial
						0,; //entrada
						0,; //saida
						(cAliasProd)->LK9_QUANT,; //perda	
						0,; //saldo final
						AllTrim((cAliasProd)->LK9_CODPRO)})
		EndIf					
	Else
		nPosMed := aScan(aMedic,{|x| Alltrim(x[1]) + Alltrim(x[2]) + Alltrim(x[3]) + Alltrim(x[4]) + Alltrim(x[5]) + Alltrim(x[6]) == Alltrim((cAliasProd)->B1_CODDCB) + Alltrim((cAliasProd)->LKD_DSCDCB) + AllTrim((cAliasProd)->LK9_DESCRI) + AllTrim((cAliasProd)->MHB_APRESE) + Alltrim((cAliasProd)->B1_QTDEMBA) + AllTrim((cAliasProd)->B1_CONCENT)})

		If nPosMed > 0
			If (cAliasProd)->LK9_TIPMOV == "1"
				aMedic[nPosMed][8] += (cAliasProd)->LK9_QUANT
			ElseIf (cAliasProd)->LK9_TIPMOV == "2"
				aMedic[nPosMed][9] += (cAliasProd)->LK9_QUANT
			ElseIf (cAliasProd)->LK9_TIPMOV == "4"
				aMedic[nPosMed][10] += (cAliasProd)->LK9_QUANT
			EndIf		
		Else
			If (cAliasProd)->LK9_TIPMOV == "1"
				AADD(aMedic,{Alltrim((cAliasProd)->B1_CODDCB),;							
							Alltrim((cAliasProd)->LKD_DSCDCB),;
							AllTrim((cAliasProd)->LK9_DESCRI),;
							AllTrim((cAliasProd)->MHB_APRESE),;
							Alltrim((cAliasProd)->B1_QTDEMBA),;
							AllTrim((cAliasProd)->B1_CONCENT),;
							0,; //estoque inicial
							(cAliasProd)->LK9_QUANT,; //entrada
							0,; //saida
							0,; //perda
							0,; //saldo final
							AllTrim((cAliasProd)->LK9_CODPRO),;
							AllTrim((cAliasProd)->F1_FORNECE),;
							AllTrim((cAliasProd)->A2_NOME),;
							AllTrim((cAliasProd)->A2_CGC),;
							AllTrim((cAliasProd)->LK9_DOC)})
			ElseIf (cAliasProd)->LK9_TIPMOV == "2"
				AADD(aMedic,{Alltrim((cAliasProd)->B1_CODDCB),;							
							Alltrim((cAliasProd)->LKD_DSCDCB),;
							AllTrim((cAliasProd)->LK9_DESCRI),;
							AllTrim((cAliasProd)->MHB_APRESE),;
							Alltrim((cAliasProd)->B1_QTDEMBA),;
							AllTrim((cAliasProd)->B1_CONCENT),;
							0,; //estoque inicial
							0,; //entrada
							(cAliasProd)->LK9_QUANT,; //saida
							0,; //perda
							0,; //saldo final
							AllTrim((cAliasProd)->LK9_CODPRO)})	
			ElseIf (cAliasProd)->LK9_TIPMOV == "4"
				AADD(aMedic,{Alltrim((cAliasProd)->B1_CODDCB),;							
							Alltrim((cAliasProd)->LKD_DSCDCB),;
							AllTrim((cAliasProd)->LK9_DESCRI),;
							AllTrim((cAliasProd)->MHB_APRESE),;
							Alltrim((cAliasProd)->B1_QTDEMBA),;
							AllTrim((cAliasProd)->B1_CONCENT),;
							0,; //estoque inicial
							0,; //entrada
							0,; //saida
							(cAliasProd)->LK9_QUANT,; //perda
							0,; //saldo final	
							AllTrim((cAliasProd)->LK9_CODPRO)})	
			EndIf			
		EndIf
	EndIf
	(cAliasProd)->(dbSkip())
EndDo

If !Empty(aMedic)
	For nlX := 1 to Len(aMedic)
		cAliasEst := GetNextAlias()
		cQuery2 := " SELECT SUM(ENT.ENTRADA - (SAIDA + PERDA)) ESTOQUE FROM "
		cQuery2 += " ( "
		cQuery2 += " SELECT ISNULL(SUM(LK9_QUANT),0) ENTRADA FROM " + RetSqlName("LK9")
		cQuery2 += " WHERE D_E_L_E_T_ <> '*' "
		cQuery2 += " AND LK9_TIPMOV = '1' "
		cQuery2 += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' " 
		cQuery2 += " AND LK9_DATA <= '" +DTOS(CTOD(cPerDe) -1)+ "' "
		cQuery2 += " AND LK9_CODPRO = '" +aMedic[nlX][12]+ "' " 
		cQuery2 += " AND LK9_DESCRI = '" +aMedic[nlX][3]+ "' "
		cQuery2 += " ) ENT "
		cQuery2 += " LEFT JOIN " 
		cQuery2 += " ( "
	 	cQuery2 += " SELECT ISNULL(SUM(LK9_QUANT),0) SAIDA FROM " + RetSqlName("LK9")
		cQuery2 += " WHERE D_E_L_E_T_ <> '*' "
		cQuery2 += " AND LK9_TIPMOV = '2' "
		cQuery2 += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' " 
		cQuery2 += " AND LK9_DATA <= '" +DTOS(CTOD(cPerDe) -1)+ "' "
		cQuery2 += " AND LK9_CODPRO = '" +aMedic[nlX][12]+ "' " 
		cQuery2 += " AND LK9_DESCRI = '" +aMedic[nlX][3]+ "' "
		cQuery2 += " ) SAI "
		cQuery2 += " ON SAI.SAIDA >= 0 " 
		cQuery2 += " LEFT JOIN "
		cQuery2 += " ( "
		cQuery2 += " SELECT  ISNULL(SUM(LK9_QUANT),0) PERDA FROM " + RetSqlName("LK9")
		cQuery2 += " WHERE D_E_L_E_T_ <> '*' "
		cQuery2 += " AND LK9_TIPMOV = '4' "
		cQuery2 += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' " 
		cQuery2 += " AND LK9_DATA <= '" +DTOS(CTOD(cPerDe) -1)+ "' "
		cQuery2 += " AND LK9_CODPRO = '" +aMedic[nlX][12]+ "' " 
		cQuery2 += " AND LK9_DESCRI = '" +aMedic[nlX][3]+ "' "
		cQuery2 += " ) PER "
		cQuery2 += " ON PER.PERDA >= 0 " 
		
		cQuery2 := ChangeQuery(cQuery2)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasEst,.T.,.T.)
		
		aMedic[nlX][7] += (cAliasEst)->ESTOQUE
		aMedic[nlX][11] += ((aMedic[nlX][7] + aMedic[nlX][8]) - (aMedic[nlX][9] + aMedic[nlX][10]))
							
		(cAliasEst)->(dbCloseArea())
	Next
EndIf		

For nlX := 1 to Len(aMedic)
	Li+=5
	oPrinter:Say(li+2,7	 ,aMedic[nlX][1],oFontT)
	oPrinter:Say(li+2,42 ,aMedic[nlX][2],oFontT)
	oPrinter:Say(li+2,202,aMedic[nlX][3],oFontT)
	oPrinter:Say(li+2,362,aMedic[nlX][4],oFontT)
	oPrinter:Say(li+2,432,aMedic[nlX][5],oFontT)
	oPrinter:Say(li+2,452,aMedic[nlX][6],oFontT)
	oPrinter:Say(li+2,497,Alltrim(STR(aMedic[nlX][7])),oFontT)
	oPrinter:Say(li+2,562,Alltrim(STR(aMedic[nlX][8])),oFontT)
	oPrinter:Say(li+2,617,Alltrim(STR(aMedic[nlX][9])),oFontT)
	oPrinter:Say(li+2,677,Alltrim(STR(aMedic[nlX][10])),oFontT)
	oPrinter:Say(li+2,737,Alltrim(STR(aMedic[nlX][11])),oFontT)
	
	oPrinter:Line( li-5, 5, li+5, 5) 	//LINHA DA ESQUERDA 
	oPrinter:Line( li-5, 40, li+5, 40) // DIREITA DO NUMERO DO CODIGO DA DCB
	oPrinter:Line( li-5, 200, li+5, 200) // DIREITA DO DESCRIMINACAO DA DCB
	oPrinter:Line( li-5, 360, li+5, 360) // DIREITA DO NOME DO MEDICAMENTO
	oPrinter:Line( li-5, 430, li+5, 430) // DIREITA DA APRESENTACAO
	oPrinter:Line( li-5, 450, li+5, 450) // DIREITA DA UNIDADE
	oPrinter:Line( li-5, 495, li+5, 495) // DIREITA DA APRESENTACAO, UNIDADE E CONCENTRACAO
	oPrinter:Line( li-5, 560, li+5, 560) // DIREITA DA DATA DA RNA
	oPrinter:Line( li-5, 615, li+5, 615) // DIREITA DO NOME DO MEDICO
	oPrinter:Line( li-5, 675, li+5, 675) // DIREITA DO NUMERO DO MEDICO
	oPrinter:Line( li-5, 735, li+5, 735) // DIREITA DA QUANTIDADE PRESCRITA
	oPrinter:Line( li-5, nMaxCol-20, li+5, nMaxCol-20) // DIREITA DA QUANTIDADE DISPENSADA
	Li+=5
	oPrinter:Line( li, 5, li, nMaxCol-20,, )
	
	//If Li >= 480
	//	ImpRodape(oPrinter,"F")
	//EndIf
			
	IF li >= (nMaxLin-100)
		oPrinter:EndPage()
		Li := 15
		nPagina++
		CabecCo(nPagina,oPrinter)		// imprime cabecalho do Relatorio
	EndIF
Next

oPrinter:SayAlign(li + 10,7,"ASSINATURA DO RESPONSÁVEL TÉCNICO " + Replicate("_",58),oFontT2,nMaxCol-20,200,,0)

/** BALANCO DAS AQUISICOES DE MEDICAMENTOS */
cabecCo2(nPagina,oPrinter)

For nlX := 1 to Len(aMedic)
	If Len(aMedic[nlX]) > 12
		Li+=5
		oPrinter:Say(li+2,7	 ,aMedic[nlX][1],oFontT)
		oPrinter:Say(li+2,42 ,aMedic[nlX][2],oFontT)
		oPrinter:Say(li+2,202,aMedic[nlX][3],oFontT)
		oPrinter:Say(li+2,362,aMedic[nlX][4],oFontT)
		oPrinter:Say(li+2,432,aMedic[nlX][5],oFontT)
		oPrinter:Say(li+2,452,aMedic[nlX][6],oFontT)
		oPrinter:Say(li+2,497,Alltrim(aMedic[nlX][14]),oFontT)
		oPrinter:Say(li+2,588,Transform(Alltrim(aMedic[nlX][15]),"@R 99.999.999/9999-99"),oFontT)
		oPrinter:Say(li+2,668,Alltrim(aMedic[nlX][16]),oFontT)
		oPrinter:Say(li+2,723,Alltrim(STR(aMedic[nlX][8])),oFontT)

		oPrinter:Line( li-5, 5, li+5, 5) //LINHA DA ESQUERDA 
		oPrinter:Line( li-5, 40, li+5, 40) // DIREITA DO NUMERO DO CODIGO DA DCB
		oPrinter:Line( li-5, 200, li+5, 200) // DIREITA DO DESCRIMINACAO DA DCB
		oPrinter:Line( li-5, 360, li+5, 360) // DIREITA DO NOME DO MEDICAMENTO
		oPrinter:Line( li-5, 430, li+5, 430) // DIREITA DA APRESENTACAO
		oPrinter:Line( li-5, 450, li+5, 450) // DIREITA DA UNIDADE
		oPrinter:Line( li-5, 495, li+5, 495) // DIREITA DA APRESENTACAO, UNIDADE E CONCENTRACAO
		oPrinter:Line( li-5, 585, li+5, 585) // DIREITA NOME DA EMPRESA
		oPrinter:Line( li-5, 665, li+5, 665) // DIREITA CNPJ
		oPrinter:Line( li-5, 720, li+5, 720) // DIREITA NOTA FISCAL
		oPrinter:Line( li-5, nMaxCol-20, li+5, nMaxCol-20) // DIREITA DA QUANTIDADE
		Li+=5
		oPrinter:Line( li, 5, li, nMaxCol-20,, )
		
		IF li >= (nMaxLin-100)
			oPrinter:EndPage()
			Li := 15
			nPagina++
			cabecCo2 (nPagina,oPrinter)		// imprime cabecalho do Relatorio
		EndIF
	EndIf	
Next

oPrinter:SayAlign(li + 10,7,"ASSINATURA DO RESPONSÁVEL TÉCNICO " + replicate("_",58),oFontT2,nMaxCol-20,200,,0)

//ImpRodape(oPrinter,"M")
oPrinter:EndPage()

//If Select((cAliasProd)) > 0
//	(cAliasProd)->(dbCloseArea())
//EndIf

oPrinter:Print()

Return

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CabecCo  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho do Medicamento		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CabecCo()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function CabecCo(nPagMe,oPrinter,cCabec1)

Local cTitulo 	:= "TOTVS SA"
Local cTitulo2 	:= Alltrim(UPPER(SM0->M0_NOME))
Local cCNPJSM	:= Alltrim(SM0->M0_CGC)
Local cCNPJCM	:= ""
Local nBegin
Local nAltura	:= 0
Local nLarg		:= 0
Local nLinha	:= 0
Local nPixel	:= 0
Local cExer		:= ""
Local cAnual	:= ""
Local cTrim		:= ""
Local cPerDe	:= ""
Local cPerAte	:= ""
Local nomeprog	:= "RELBMPO"
Local aMeses	:= {'JANEIRO'	, 'FEVEREIRO'	, 'MARÇO'	, 'ABRIL'	,;
					'MAIO'		, 'JUNHO'		, 'JULHO'	, 'AGOSTO'	,;
					'SETEMBRO'	, 'OUTUBRO'		, 'NOVEMBRO', 'DEZEMBRO' }
Local cMvLjDroLF:= AllTrim(SuperGetMV("MV_LJDROLF",,""))	//Número da Licença de Funcionamento

Private oFontC
Private oFontT

oFontT := TFont():New('Courier new',,8,.T.)
oFontN := TFont():New('Arial',,6,.T.,.T.)
oFontC := TFont():New('Courier new',,20,.T.,.T.)
oFontC2 := TFont():New('Courier new',,15,.T.)
oPrinter:StartPage()
li+= 20
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)

VerifPeriodo(@cExer,@cAnual,@cTrim,@cPerDe,@cPerAte)

oPrinter:SayAlign(30,0,"BALANÇO COMPLETO DE MEDICAMENTOS",oFontC,nMaxCol-10,200,,2)
oPrinter:SayAlign(60,7,"C.N.P.J. " + AllTrim(Transform(SM0->M0_CGC, '@R 99.999.999/9999-99')) + " Nº DA LICENÇA DE FUNCIONAMENTO: " + cMvLjDroLF,oFontC2,nMaxCol-20,200,,0)

If MV_PAR02 == 1
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º (X) 2º ( ) 3º ( ) 4º ( ) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
ElseIf MV_PAR02 == 2
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º (X) 3º ( ) 4º ( ) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
ElseIf MV_PAR02 == 3
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º ( ) 3º (X) 4º ( ) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
ElseIf MV_PAR02 == 4
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º ( ) 3º ( ) 4º (X) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
Else
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º ( ) 3º ( ) 4º ( ) - ANUAL (X)",oFontC2,nMaxCol-20,200,,0)
EndIf

oPrinter:Line( 125, 5, 125, nMaxCol-20)
Li:=130

oPrinter:Line( li-5, 5, li+30, 5) //LINHA DA ESQUERDA 
oPrinter:SayAlign(li,7,"N° do",oFontN,30,45,2)
oPrinter:SayAlign(li+6,7,"Código",oFontN,30,45,2)
oPrinter:SayAlign(li+13,7,"da D.C.B",oFontN,30,45,2)
oPrinter:Line( li-5, 40, li+30, 40) // DIREITA DO NUMERO DO CODIGO DA DCB

oPrinter:SayAlign(li+10,80,"Descriminação da D.C.B",oFontN,230,45,2,0)
oPrinter:Line( li-5, 200, li+30, 200) // DIREITA DO DESCRIMINACAO DA DCB

oPrinter:SayAlign(li+10,240,"Nome do Medicamento",oFontN,230,45,2,0)
oPrinter:Line( li-5, 360, li+30, 360) // DIREITA DO NOME DO MEDICAMENTO

oPrinter:SayAlign(li+10,380,"Apresentação e Concentração",oFontN,90,45,2,2)
oPrinter:Line( li-5, 495, li+30, 495) // DIREITA DA APRESENTACAO

oPrinter:SayAlign(li+10,510,"Estoque",oFontN,30,45,2,2)
oPrinter:SayAlign(li+16,510,"Inicial",oFontN,30,45,2,2)
oPrinter:Line( li-5, 560, li+30, 560) // DIREITA DA CONCENTRACAO

oPrinter:SayAlign(li+10,570,"Entrada",oFontN,40,45,2,2)
oPrinter:Line( li-5, 615, li+30, 615) // DIREITA DO NUMERO DA RNA

oPrinter:SayAlign(li+10,628,"Saída",oFontN,40,45,2,2)
oPrinter:Line( li-5, 675, li+30, 675) // DIREITA DA DATA DA RNA

oPrinter:SayAlign(li+10,682,"Perda",oFontN,40,45,2,2)\
oPrinter:Line( li-5, 735, li+30, 735) // DIREITA DA PERDA

oPrinter:SayAlign(li+10,745,"Estoque",oFontN,30,45,2,2)
oPrinter:SayAlign(li+16,745,"Final",oFontN,30,45,2,2)
oPrinter:Line( li-5, nMaxCol-20, li+30, nMaxCol-20) // DIREITA DO ESTOQUE FINAL
Li+=30
oPrinter:Line( li, 5, li, nMaxCol-20)

Return

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CabecCo2  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho do Medicamento		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CabecCo2()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CabecCo2(nPagMe,oPrinter,cCabec1)
Local cTitulo 	:= "TOTVS SA"
Local cTitulo2 	:= Alltrim(UPPER(SM0->M0_NOME))
Local cCNPJSM	:= Alltrim(SM0->M0_CGC)
Local cCNPJCM	:= ""
Local nBegin       
Local nAltura  	:= 0
Local nLarg    	:= 0
Local nLinha   	:= 0
Local nPixel   	:= 0
Local cExer		:= ""
Local cAnual	:= ""
Local cTrim		:= ""
Local cPerDe	:= ""
Local cPerAte	:= ""
Local nomeprog 	:= "RELBMPO"
Local aMeses	:= {'JANEIRO'	, 'FEVEREIRO'	, 'MARÇO'	, 'ABRIL'	,;
					'MAIO'		, 'JUNHO'		, 'JULHO'	, 'AGOSTO'	,;
					'SETEMBRO'	, 'OUTUBRO'		, 'NOVEMBRO', 'DEZEMBRO' }
Local cMvLjDroLF:= AllTrim(SuperGetMV("MV_LJDROLF",,""))	//Número da Licença de Funcionamento

Private oFontC
Private oFontT

oFontT := TFont():New('Courier new',,8,.T.)
oFontN := TFont():New('Arial',,6,.T.,.T.)
oFontC := TFont():New('Courier new',,20,.T.,.T.)
oFontC2 := TFont():New('Courier new',,15,.T.)
oPrinter:StartPage()
li+= 20
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)

VerifPeriodo(@cExer,@cAnual,@cTrim,@cPerDe,@cPerAte)

oPrinter:SayAlign(30,0,"BALANÇO DAS AQUISIÇÕES DE MEDICAMENTOS",oFontC,nMaxCol-10,200,,2)
oPrinter:SayAlign(60,7,"C.N.P.J. " + AllTrim(Transform(SM0->M0_CGC, '@R 99.999.999/9999-99')) + " Nº DA LICENÇA DE FUNCIONAMENTO: " + cMvLjDroLF,oFontC2,nMaxCol-20,200,,0)

If MV_PAR02 == 1
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º (X) 2º ( ) 3º ( ) 4º ( ) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
ElseIf MV_PAR02 == 2
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º (X) 3º ( ) 4º ( ) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
ElseIf MV_PAR02 == 3
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º ( ) 3º (X) 4º ( ) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
ElseIf MV_PAR02 == 4
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º ( ) 3º ( ) 4º (X) - ANUAL ( )",oFontC2,nMaxCol-20,200,,0)
Else
	oPrinter:SayAlign(90,7,"EXERCÍCIO:" +cExer+ " PERIODICIDADE: TRIMESTRAL: 1º ( ) 2º ( ) 3º ( ) 4º ( ) - ANUAL (X)",oFontC2,nMaxCol-20,200,,0)
EndIf

oPrinter:Line( 125, 5, 125, nMaxCol-20)
Li:=130

oPrinter:Line( li-5, 5, li+30, 5) //LINHA DA ESQUERDA 
oPrinter:SayAlign(li,7,"N° do",oFontN,30,45,2)
oPrinter:SayAlign(li+6,7,"Código",oFontN,30,45,2)
oPrinter:SayAlign(li+13,7,"da D.C.B",oFontN,30,45,2)
oPrinter:Line( li-5, 40, li+30, 40) // DIREITA DO NUMERO DO CODIGO DA DCB

oPrinter:SayAlign(li+10,80,"Descriminação da D.C.B",oFontN,230,45,2,0)
oPrinter:Line( li-5, 200, li+30, 200) // DIREITA DO DESCRIMINACAO DA DCB

oPrinter:SayAlign(li+10,240,"Nome do Medicamento",oFontN,230,45,2,0)
oPrinter:Line( li-5, 360, li+30, 360) // DIREITA DO NOME DO MEDICAMENTO

oPrinter:SayAlign(li+10,380,"Apresentação e Concentração",oFontN,90,45,2,2)
oPrinter:Line( li-5, 495, li+30, 495) // DIREITA DA APRESENTACAO

oPrinter:SayAlign(li+10,510,"Nome da Empresa",oFontN,60,45,2,2)
oPrinter:Line( li-5, 585, li+30, 585) // DIREITA DA CONCENTRACAO

oPrinter:SayAlign(li+10,605,"CNPJ",oFontN,40,45,2,2)
oPrinter:Line( li-5, 665, li+30, 665) // DIREITA DO NUMERO DA RNA

oPrinter:SayAlign(li+10,673,"Nota Fiscal",oFontN,40,45,2,2)
oPrinter:Line( li-5, 720, li+30, 720) // DIREITA DA DATA DA RNA

oPrinter:SayAlign(li+10,735,"Quantidade",oFontN,60,45,2,0)

oPrinter:Line( li-5, nMaxCol-20, li+30, nMaxCol-20) // DIREITA DO ESTOQUE FINAL
Li+=30
oPrinter:Line( li, 5, li, nMaxCol-20)
//li+=5

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ Fun‡…o   ³ ImpCapa  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o Termo de Abertura e Encerramento do Relatorio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ 	   		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpCapa(nPagMe,oPrinter)

Local cTitulo 	:= "BMPO" //"RMNRA"
Local cTitulo2 	:= "BMPO"
Local cCabec1 	:= ""	
Local nBegin       
Local nAltura  	:= 0
Local nLarg    	:= 0
Local nLinha   	:= 0
Local nPixel   	:= 0
Local cExer		:= ""
Local cAnual	:= ""
Local cTrim		:= ""
Local cPerDe	:= ""
Local cPerAte	:= ""
Local nomeprog	:= "RELRMNRA"
Local aMeses	:= {'JANEIRO'	, 'FEVEREIRO'	, 'MARÇO'	, 'ABRIL'	,;
					'MAIO'		, 'JUNHO'		, 'JULHO'	, 'AGOSTO'	,;
					'SETEMBRO'	, 'OUTUBRO'		, 'NOVEMBRO', 'DEZEMBRO' }
Local cMvLjDroLF:= AllTrim(SuperGetMV("MV_LJDROLF",,""))	//Número da Licença de Funcionamento
Local lMvSpedEnd:= SuperGetMv("MV_SPEDEND",,.F.)

Private oFontC
Private oFontT

If lMvSpedEnd
	cEndereco := AllTrim(SM0->M0_ESTENT) + " " + AllTrim(SM0->M0_BAIRENT) + " " + AllTrim(SM0->M0_CIDENT)
Else
	cEndereco := AllTrim(SM0->M0_ESTCOB) + " " + AllTrim(SM0->M0_BAIRCOB) + " " + AllTrim(SM0->M0_CIDCOB)
EndIf

oFontT := TFont():New('Courier new',,8,.T.)
oFontC := TFont():New('Courier new',,12,.T.,.T.)
oFontCT := TFont():New('Courier new',,30,.T.,.T.)
oFontN := TFont():New('Arial',,6,.T.,.T.)
oFontC2 := TFont():New('Courier new',,10,.T.)

oPrinter:StartPage()
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)

oPrinter:SayBitmap(li, 30, GetSrvProfString ("ROOTPATH","") + "\System\" + "brasao.jpg", 50, 50)
oPrinter:SayAlign(li,100,"SECRETARIA DE SAÚDE: ESTADO DE SÃO PAULO",oFontC,nMaxCol-10,,,0)		//oPrinter:SayAlign(li,100,"SECRETARIA DE SAÚDE..........................",oFontC,nMaxCol-10,,,0)	//MIKE
Li+=15
oPrinter:SayAlign(li,100,"AUTORIDADE SANITÁRIA: COVISA",oFontC,nMaxCol-10,,,0)					//oPrinter:SayAlign(li,100,"AUTORIDADE SANITÁRIA.........................",oFontC,nMaxCol-10,,,0)	//MIKE
Li+=15
oPrinter:SayAlign(li,100,"BALANÇO DE MEDICAMENTOS PSICOATIVOS E OUTROS SUJEITOS A CONTROLE ESPECIAL - BMPO",oFontC,nMaxCol-10,,,0)
Li+=15

//caixa PRINCIPAL
oPrinter:Box(80,25,540,nMaxCol-25)

//caixa IDENTIFICAÇÃO DO ESTABDELECIMENTO
oPrinter:SayAlign(90,35,"IDENTIFICAÇÃO DO ESTABELECIMENTO",oFontC,nMaxCol-10,,,0)
oPrinter:Box(110,35,270,nMaxCol-35)

li+=150
oPrinter:Line( 120, 45, 120, 75)
oPrinter:Line( 120, 45, 150, 45)
oPrinter:Line( 120, 250, 120, 280)
oPrinter:Line( 120, 280, 150, 280)

oPrinter:SayAlign(125,300,AllTrim(SM0->M0_NOMECOM),oFontC2,nMaxCol,,,0)
oPrinter:SayAlign(130,300,"___________________________________________________________________________________________",oFontT,nMaxCol,,,0)
oPrinter:SayAlign(140,300,"Razão Social",oFontT,280,,,0)

oPrinter:SayAlign(165,300,cEndereco, oFontC2, nMaxCol,,,0)
oPrinter:SayAlign(170,300,"___________________________________________________________________________________________",oFontT,nMaxCol,,,0)
oPrinter:SayAlign(180,300,"Endereço",oFontT,280,,,0)

oPrinter:SayAlign(210,300,"C.N.P.J. " + AllTrim(Transform(SM0->M0_CGC, '@R 99.999.999/9999-99')) + " N°Licença de Funcionamento: " + cMvLjDroLF, oFontT, nMaxCol,,,0)

oPrinter:SayAlign(240,300,"Telefone: " + AllTrim(SM0->M0_TEL) + " Fax: " + AllTrim(AllTrim(SM0->M0_FAX) ), oFontT, nMaxCol,,,0)

oPrinter:Line( 260, 45, 260, 75)
oPrinter:Line( 260, 45, 230, 45)
oPrinter:Line( 260, 250, 260, 280)
oPrinter:Line( 230, 280, 260, 280)

//caixa IDENTIFICAÇÃO DO FORMULARIO
oPrinter:SayAlign(280,35,"IDENTIFICAÇÃO DO FORMULÁRIO",oFontC,nMaxCol-10,,,0)
oPrinter:Box(300,35,330,nMaxCol-35)

VerifPeriodo(@cExer,@cAnual,@cTrim,@cPerDe,@cPerAte)

oPrinter:SayAlign(312,45,"Balanço: Exercício: " +cExer+ "  Anual( "+cAnual+" )  Trimestral ( "+cTrim+" )  Período "+cPerDe+" a "+cPerAte,oFontT,nMaxCol,,,0)


//caixa IDENTIFICAÇÃO DO RESPONSÁVEL PELA INFORMAÇÃO
oPrinter:SayAlign(340,35,"IDENTIFICAÇÃO DO RESPONSÁVEL PELA INFORMAÇÃO",oFontC,nMaxCol-10,,,0)
oPrinter:Box(360,35,420,nMaxCol-35)

oPrinter:SayAlign(372,45,"Preenchido por: " + AllTrim(LKB->LKB_NOME) + " C.R.F. " + AllTrim(LKB->LKB_CRF) + " Região____________________________ Data " + DtoC(Date()), oFontT, nMaxCol,,,0)
oPrinter:SayAlign(400,45,"Assinatura_______________________________________________________________",oFontT,nMaxCol,,,0)


//caixa IDENTIFICAÇÃO DO RESPONSÁVEL PELA INFORMAÇÃO
oPrinter:SayAlign(430,35,"IDENTIFICAÇÃO DO RESPONSÁVEL PELA INFORMAÇÃO",oFontC,nMaxCol-10,,,0)
oPrinter:Box(450,35,530,nMaxCol-35)

oPrinter:SayAlign(472,45,"Recebido por:  _____________________ RG:_____________________ Cargo:_____________________ Data:__/__/____",oFontT,nMaxCol,,,0)
oPrinter:SayAlign(510,45,"Conferido por: _____________________ RG:_____________________ Cargo:_____________________ Data:__/__/____",oFontT,nMaxCol,,,0)

ImpTer := .F.

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ Fun‡…o   ³ ImpRodape  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho do Medicamento		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ ImpRodape()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpRodape(oPrinter,cTipo)

Private oFontC

oFontC := TFont():New('Courier new',,12,.T.,.T.)
If cTipo == "F"
	Li:=500
Else
	If Li <= 460
		Li+=20
	EndIf
EndIf
oPrinter:SayAlign(li,7,"ASSINATURA DO RESPONSÁVEL TÉCNICO:_______________________________________________________",oFontC,nMaxCol-10,200,,0)
Li+=30
oPrinter:SayAlign(li,7,"Recebido por:  _____________________ RG:_____________________ Cargo:_____________________ Data:__/__/____",oFontC,nMaxCol-10,200,,0)
Li+=30
oPrinter:SayAlign(li,7,"Conferido por: _____________________ RG:_____________________ Cargo:_____________________ Data:__/__/____",oFontC,nMaxCol-10,200,,0)
Li+=30
oPrinter:SayAlign(li,7,"                                                                                  DEVOLVIDO EM:__/__/____",oFontC,nMaxCol-10,200,,0)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ          	
±±³Funcao    ³VerifPeriodo ³ Autor ³ Rodrigo Nunes	    ³ Data ³21/03/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica o Periodo	  				                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELBMPO                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VerifPeriodo(cExer,cAnual,cTrim,cPerDe,cPerAte)

cExer := MV_PAR01

If MV_PAR02 <> 5	//diferente de Anual
	cAnual := ""
	cTrim  := "X"
Else
	cAnual := "X"	//anual
	cTrim  := ""
EndIf

If MV_PAR02 == 1					// 1o Trimestre
	cPerDe	:= "01/01/" + cExer
	cPerAte	:= "31/03/" + cExer
ElseIf MV_PAR02 == 2				// 2o Trimestre
	cPerDe	:= "01/04/" + cExer
	cPerAte	:= "30/06/" + cExer
ElseIf MV_PAR02 == 3				// 3o Trimestre
	cPerDe	:= "01/07/" + cExer
	cPerAte	:= "30/09/" + cExer
ElseIf MV_PAR02 == 4				// 4o Trimestre
	cPerDe	:= "01/10/" + cExer
	cPerAte	:= "31/12/" + cExer
ElseIf MV_PAR02 == 5				// Anual
	cPerDe	:= "01/01/" + cExer
	cPerAte	:= "31/12/" + cExer
EndIf

Return