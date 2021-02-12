#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

Static cDescLista := ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ RELCOVISA  ³ Autor ³ Rodrigo Dias Nunes	³ Data ³ 11/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Movimentação do Medicamento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function RELCOVISA() 
Local aOrdem 		:= {"Data de Entrada/Saída/Perda"}
Local aDevice 		:= {}
Local bParam		:= {|| Pergunte("RELCOVISA", .T.)}
Local cAliasTop 	:= "LK9"
Local cDevice   	:= ""
Local cPathDest 	:= GetSrvProfString("StartPath","\system\")
Local cRelName  	:= "RELCOVISA"
Local cSession  	:= GetPrinterSession()
Local cSpool		:= ""
Local lAdjust   	:= .F.
Local lProssegue	:= .T.
Local nFlags    	:= PD_ISTOTVSPRINTER//+PD_DISABLEPAPERSIZE
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

//Verifica se usuario tem permissao de de farmaceuto para incluir registros
If lProssegue .And. !T_DroVERPerm()
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
		
		RptStatus({|lEnd| CovisaProc(@lEnd,nOrdem, @oPrinter)},"Imprimindo Relatório...")
	Else 
		MsgInfo("Relatório cancelado pelo usuário.")//"Relatório cancelado pelo usuário." 
		oPrinter:Cancel()
	EndIf
	
	oSetup:= Nil
	oPrinter:= Nil
EndIf

Return lProssegue

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    | CovisaProc  ³ Autor ³ Rodrigo Dias Nunes	³ Data ³ 11/11/15 ³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o processamento do relatorio	                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELCOVISA                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CovisaProc(lEnd, nOrdem, oPrinter)
Local nBegin	:= 0
Local cQuery	:= ""
Local cQProd	:= ""
Local cQMov		:= ""
Local nValEst	:= 0
Local nTotHist	:= 0
Local nlX		:= 0
Local cTextHist	:= ""
Local oFontT	:= TFont():New('Courier new',,8,.T.)
Local nPagina 	:= 1
Local llRet		:= .F.
Local cObservacao := ""
Local cLista	:= "" 

Private ImpTer	:= .T.

Pergunte("RELCOVISA",.F.)

//"MV_CHE","C",20,0,0,"C","","","","","mv_par14","A1 e A2",  ,  ,"               " ,"A3,B1 e B2", , ,"D1", ,"","C1,C2,C3,C4,C5", , ,"D2","","", aHelpPor,aHelpEng,aHelpSpa) 

Do Case
	Case mv_par13 ==1
		cLista := " LK9_CODLIS IN ('A1','A2') "
		cDescLista := " de Medicamentos Entorpecentes A1 e A2"
	Case mv_par13 ==2
		cLista := " LK9_CODLIS IN ('A3','B1','B2') "
		cDescLista := " de Substâncias e Medicamentos Psicotropicos A3,B1 e B2"
	Case mv_par13 ==3
		cLista := " LK9_CODLIS IN ('C3') "
		cDescLista := "de Substâncias e Medicamentos Imunosuporessores C3"
	Case mv_par13 ==4
		cLista := " LK9_CODLIS IN ('C1','C2','C4','C5') "
		cDescLista := "  de Substâncias e Medicamentos sujeitos a Controle Especial C1,C2,C3,C4 e C5"
	Case mv_par13 ==5
		cLista := " LK9_CODLIS IN ('D1','D2') "
		cDescLista := "D2"
End Case

SetRegua(100)	

	cAliasProd := GetNextAlias()
	cQProd := " SELECT DISTINCT(LK9_CODPRO) PRODUTO "
	cQProd += " ,B1_COD , B1_DESC , B1_CONCENT, B1_QTDEMBA , B1_SUBATIV , B1_CODDCB "
	cQProd += " FROM "
	cQProd += " ( "
	cQProd += " SELECT * FROM " + RetSqlName("LK9")
	cQProd += " WHERE D_E_L_E_T_ <> '*' "
	cQProd += " AND LK9_CODPRO <> '' "
	cQProd += " AND LK9_CODPRO BETWEEN '" +MV_PAR03+ "' AND '" +MV_PAR04+ "' "
	cQProd += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' AND"
	cQProd += cLista // " LK9_CODLIS = '" +MV_PAR13+ "' "
	cQProd += " ) LK9 "
	cQProd += " INNER JOIN " 
	cQProd += " ( "
	cQProd += " SELECT * FROM " + RetSqlName("SB1")
	cQProd += " WHERE D_E_L_E_T_ <> '*' "
	cQProd += " ) SB1 "
	cQProd += " ON SB1.B1_COD = LK9.LK9_CODPRO "
	
	cQProd := ChangeQuery(cQProd)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQProd),cAliasProd,.T.,.T.)

	While (cAliasProd)->(!EOF())
		cAliasTop := GetNextAlias()
		cQuery := " SELECT SUM(ENT.ENTRADA - (SAIDA + PERDA)) ESTOQUE FROM "
		cQuery += " ( "
		cQuery += " SELECT ISNULL(SUM(LK9_QUANT),0) ENTRADA FROM " + RetSqlName("LK9")
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND LK9_TIPMOV in ('1','9','A','B') "
		cQuery += " AND LK9_CODPRO = '" +(cAliasProd)->PRODUTO+ "' "
		cQuery += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' "
		cQuery += " AND LK9_DATA <= '" +DTOS(MV_PAR01-1)+ "' "
		cQuery += " AND LK9_LOTE BETWEEN '" +MV_PAR05+ "' AND '" +MV_PAR06+ "' "
		cQuery += " AND LK9_CNPJFO BETWEEN '" +MV_PAR07+ "' AND '" +MV_PAR08+ "' "
		cQuery += " AND LK9_NOMMED BETWEEN '" +MV_PAR09+ "' AND '" +MV_PAR10+ "' "
		cQuery += " AND LK9_NOME BETWEEN '" +MV_PAR11+ "' AND '" +MV_PAR12+ "' "
		cQuery += " ) ENT "
		cQuery += " LEFT JOIN "
		cQuery += " ( "
		cQuery += " SELECT ISNULL(SUM(LK9_QUANT),0) SAIDA FROM " + RetSqlName("LK9")
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND LK9_TIPMOV in('2','8','7') "
		cQuery += " AND LK9_CODPRO = '" +(cAliasProd)->PRODUTO+ "' "
		cQuery += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' "
		cQuery += " AND LK9_DATA <= '" +DTOS(MV_PAR01-1)+ "' "
		cQuery += " AND LK9_LOTE BETWEEN '" +MV_PAR05+ "' AND '" +MV_PAR06+ "' "
		cQuery += " AND LK9_CNPJFO BETWEEN '" +MV_PAR07+ "' AND '" +MV_PAR08+ "' "
		cQuery += " AND LK9_NOMMED BETWEEN '" +MV_PAR09+ "' AND '" +MV_PAR10+ "' "
		cQuery += " AND LK9_NOME BETWEEN '" +MV_PAR11+ "' AND '" +MV_PAR12+ "' "
		cQuery += " ) SAI "
		cQuery += " ON SAI.SAIDA >= 0 "
		cQuery += " LEFT JOIN "
		cQuery += " ( "
		cQuery += " SELECT  ISNULL(SUM(LK9_QUANT),0) PERDA  FROM " + RetSqlName("LK9")
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND LK9_TIPMOV = '4' "
		cQuery += " AND LK9_CODPRO = '" +(cAliasProd)->PRODUTO+ "' "
		cQuery += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' "
		cQuery += " AND LK9_DATA <= '" +DTOS(MV_PAR01-1)+ "' "
		cQuery += " AND LK9_LOTE BETWEEN '" +MV_PAR05+ "' AND '" +MV_PAR06+ "' "
		cQuery += " AND LK9_CNPJFO BETWEEN '" +MV_PAR07+ "' AND '" +MV_PAR08+ "' "
		cQuery += " AND LK9_NOMMED BETWEEN '" +MV_PAR09+ "' AND '" +MV_PAR10+ "' "
		cQuery += " AND LK9_NOME BETWEEN '" +MV_PAR11+ "' AND '" +MV_PAR12+ "' AND "
		cQuery += cLista //" AND LK9_CODLIS = '" +MV_PAR13+ "' "
		cQuery += " ) PER "
		cQuery += " ON PER.PERDA >= 0 "
		cQuery += " INNER JOIN " 
		cQuery += " ( "
		cQuery += " SELECT * FROM " + RetSqlName("SB1")
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " ) SB1
		cQuery += " ON SB1.B1_COD = '" +(cAliasProd)->PRODUTO+ "' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
		
		IF lEnd
			oPrinter:StartPage()
			oPrinter:Say(li,5,"Cancelado pelo operador")//"CANCELADO PELO OPERADOR"
			oPrinter:EndPage()
			oPrinter:Print()
			Exit
		EndIF
		
		cAliasMov := GetNextAlias()
		cQMov := " SELECT LK9_LIVRO,LK9_PAGINA,LK9_NUMREC , LK9_NOMEP , LK9_END , LK9_DOC , LK9_SERIE,LK9_FILIAL, LK9_DATA, " 
		cQMov += "LK9_TIPMOV, LK9_CODPRO,B1_DESC,B1_CONCENT, B1_QTDEMBA ,LK9_DESCRI, LK9_QUANT," 
		cQMov += "ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),LK9_OBSPER)),'') AS [HISTORICO] , "
		cQMov += "LK9_OBSALT   "
		cQMov += " FROM "
		cQMov += " ( "
		cQMov += " SELECT * FROM " + RetSqlName("LK9")
		cQMov += " LK9 WHERE D_E_L_E_T_ <> '*' "
		cQMov += " AND LK9_TIPMOV IN ('1','2','4','7','8','9','A','B','C','D') "    
		cQMov += " AND LK9_CODPRO = '" +(cAliasProd)->PRODUTO+ "' "
		cQMov += " AND LK9_FILIAL = '" +xFilial("LK9")+ "' "
		cQMov += " AND LK9_DATA BETWEEN '" +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' "
		cQMov += " AND LK9_LOTE BETWEEN '" +MV_PAR05+ "' AND '" +MV_PAR06+ "' "
		cQMov += " AND LK9_CNPJFO BETWEEN '" +MV_PAR07+ "' AND '" +MV_PAR08+ "' "
		cQMov += " AND LK9_NOMMED BETWEEN '" +MV_PAR09+ "' AND '" +MV_PAR10+ "' "
		cQMov += " AND LK9_NOME BETWEEN '" +MV_PAR11+ "' AND '" +MV_PAR12+ "' AND "
		cQMov += cLista //" LK9_CODLIS = '" +MV_PAR13+ "' "
		cQMov += " ) LK9 "
		cQMov += " INNER JOIN " 
		cQMov += " ( "
		cQMov += " SELECT * FROM " + RetSqlName("SB1")
		cQMov += " WHERE D_E_L_E_T_ <> '*' "
		cQMov += " ) SB1
		cQMov += " ON SB1.B1_COD = '" +(cAliasProd)->PRODUTO+ "' "
		cQMov += " ORDER BY LK9_DATA , lk9.R_E_C_N_O_ "
		
		cQMov := ChangeQuery(cQMov)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQMov),cAliasMov,.T.,.T.)
		
		nValEst := (cAliasTop)->ESTOQUE
		
		IncRegua()
		
		If ImpTer
			ImpTermo(nPagina,oPrinter,"A")	
			oPrinter:EndPage()
			Li := 15
			nPagina++	
		EndIf
		
		cabecCo(nPagina,oPrinter,Alltrim((cAliasProd)->B1_COD) + " - "+Alltrim((cAliasProd)->B1_DESC) +" "+ Alltrim((cAliasProd)->B1_CONCENT ) +" "+ Alltrim((cAliasProd)->B1_QTDEMBA) + "(" + Alltrim((cAliasProd)->B1_SUBATIV) + "-" +  Alltrim((cAliasProd)->B1_CODDCB) + ")") 
		
		oPrinter:Say(li-5,322,Alltrim(STR((cAliasTop)->ESTOQUE))) //ESTOQUE DO PRODUTO
		
		llRet := .T.
		
		If Select((cAliasTop)) > 0
			(cAliasTop)->(dbCloseArea())
		EndIf
		
		While (cAliasMov)->(!EOF())
			Li+=10
			
			cObservacao := " "
			
			//oPrinter:Say(li,322,Alltrim((cAliasMov)->LK9_DESCRI))
			oPrinter:Say(li,7,SubStr((cAliasMov)->LK9_DATA,7,2)) //dia
			oPrinter:Say(li,27,SubStr((cAliasMov)->LK9_DATA,5,2)) //mes
			oPrinter:Say(li,47,SubStr((cAliasMov)->LK9_DATA,1,4)) //ano
			
			If (cAliasMov)->(LK9_TIPMOV) $"19ACB"   // 1 Compras ; 9 Dev por Inventario ; A Inclusao lista; C Entrada troca de lista ; B Saldo Inicial
				nValEst += (cAliasMov)->LK9_QUANT
				oPrinter:Say(li,222,Alltrim(Str((cAliasMov)->LK9_QUANT))) //entrada
				oPrinter:Say(li,322,Alltrim(Str(nValEst))) //estoque
				
				If (cAliasMov)->(LK9_TIPMOV) == "A"
					cObservacao :=	"Livro de Origem :"+Alltrim((cAliasMov)->LK9_LIVRO) + '| Página:' + Alltrim((cAliasMov)->LK9_PAGINA)
				EndIf
				
								
			ElseIf (cAliasMov)->(LK9_TIPMOV) $"287D"   // 2 Vendas ; 8 Req por Inventario ; 7 Estorno de Entrada
				nValEst -= (cAliasMov)->LK9_QUANT
				oPrinter:Say(li,262,Alltrim(Str((cAliasMov)->LK9_QUANT))) //Saida
				oPrinter:Say(li,322,Alltrim(Str(nValEst))) //estoque

				If (cAliasMov)->(LK9_TIPMOV) == "2"
					cObservacao :=	"Rec.:"+Alltrim((cAliasMov)->LK9_NUMREC) + '|Nome:' + Alltrim((cAliasMov)->LK9_NOMEP) + '|End.:' +;
				 				Alltrim((cAliasMov)->LK9_END) + '|Doc.:' + ;
								Alltrim((cAliasMov)->LK9_DOC) + '|Serie.:' + Alltrim((cAliasMov)->LK9_SERIE)
				EndIf	
							

			ElseIf (cAliasMov)->(LK9_TIPMOV) == "4"	
				nValEst -= (cAliasMov)->LK9_QUANT
				oPrinter:Say(li,292,Alltrim(Str((cAliasMov)->LK9_QUANT))) //Perda
				oPrinter:Say(li,322,Alltrim(Str(nValEst))) //estoque
			EndIf
			
			If Alltrim((cAliasMov)->LK9_OBSALT) <> ""
				cObservacao += " |"  + Alltrim((cAliasMov)->LK9_OBSALT)
			EndIf	
			
			nLin := li 
			If Len(Alltrim((cAliasMov)->HISTORICO)) > 25
				nTotHist := Len(Alltrim((cAliasMov)->HISTORICO)) / 25
				//nTotHist := Len(Alltrim(cTxt)) / 25
				If "." $ Alltrim(STR(nTotHist))
					nTotHist := Int(nTotHist) + 1 
				EndIf
				
				cTextHist := Alltrim((cAliasMov)->HISTORICO)
				
				nPosIni := 1
				nPosFim := 25	
				For nlX := 1 to nTotHist
					oPrinter:Say(li,80,SubStr(cTextHist,nPosIni,nPosFim)) //Historico
					nPosIni+=nPosFim
					
					li+=10
					
					IF li >= (nMaxLin-100)
						oPrinter:EndPage()
						Li := 15
						nPagina++
						CabecCo(nPagina,oPrinter,Alltrim((cAliasProd)->B1_COD) + " - "+(cAliasProd)->B1_DESC  +" "+ Alltrim((cAliasProd)->B1_CONCENT ) +" "+ Alltrim((cAliasProd)->B1_QTDEMBA)	 + "(" + Alltrim((cAliasProd)->B1_SUBATIV) + "-" +  Alltrim((cAliasProd)->B1_CODDCB) + ")")	// imprime cabecalho do Relatorio
					EndIF
					
				Next
				//preenchimento de cada linha lateral quando historico maior que 25 caracteres
				oPrinter:Line( li-((nTotHist * 10)+10), 5			, li, 5			,, ) // LINHA DA ESQUERDA
				oPrinter:Line( li-((nTotHist * 10)+10), 25			, li, 25		,, ) //DIREITA DO DIA
				oPrinter:Line( li-((nTotHist * 10)+10), 45			, li, 45		,, ) //DIREITA DO MES
				oPrinter:Line( li-((nTotHist * 10)+10), 70			, li, 70		,, ) //DIREITA DO ANO
				oPrinter:Line( li-((nTotHist * 10)+10), 220			, li, 220		,, ) //DIREITA DO HISTORICO
				oPrinter:Line( li-((nTotHist * 10)+10), 260			, li, 260		,, ) //DIREITA DA ENTRADA
				oPrinter:Line( li-((nTotHist * 10)+10), 290			, li, 290		,, ) //DIREITA DA SAIDA
				oPrinter:Line( li-((nTotHist * 10)+10), 320			, li, 320		,, ) //DIREITA DA PERDA
				oPrinter:Line( li-((nTotHist * 10)+10), 360			, li, 360		,, ) //DIREITA DO ESTOQUE
				//oPrinter:Line( li-((nTotHist * 10)+10), 480			, li, 480		,, ) //DIREITA DA ASSINATURA
				oPrinter:Line( li-((nTotHist * 10)+10), nMaxCol-10	, li, nMaxCol-10,, ) //LINHA DA DIREITA
			Else
				oPrinter:Say(li,80,Alltrim((cAliasMov)->HISTORICO)) //historico
				li+=10
				
				//preenchimento de cada linha lateral quando historico menor que 25 caracteres
				oPrinter:Line( li-20, 5			, li, 5			,, ) // LINHA DA ESQUERDA
				oPrinter:Line( li-20, 25		, li, 25		,, ) //DIREITA DO DIA
				oPrinter:Line( li-20, 45		, li, 45		,, ) //DIREITA DO MES
				oPrinter:Line( li-20, 70		, li, 70		,, ) //DIREITA DO ANO
				oPrinter:Line( li-20, 220		, li, 220		,, ) //DIREITA DO HISTORICO
				oPrinter:Line( li-20, 260		, li, 260		,, ) //DIREITA DA ENTRADA
				oPrinter:Line( li-20, 290		, li, 290		,, ) //DIREITA DA SAIDA
				oPrinter:Line( li-20, 320		, li, 320		,, ) //DIREITA DA PERDA
				oPrinter:Line( li-20, 360		, li, 360		,, ) //DIREITA DO ESTOQUE
				//oPrinter:Line( li-20, 480		, li, 480		,, ) //DIREITA DA ASSINATURA
				oPrinter:Line( li-20, nMaxCol-10, li, nMaxCol-10,, ) //LINHA DA DIREITA
			EndIf
			
			If Len(cObservacao) > 50
				li := nLin
						
				nTotHist := Len(cObservacao) / 50
				If "." $ Alltrim(STR(nTotHist))
					nTotHist := Int(nTotHist) + 1 
				EndIf
				
				cTextHist := cObservacao
				
				nPosIni := 1
				nPosFim := 50	
				For nlX := 1 to nTotHist
					oPrinter:Say(li,370,SubStr(cTextHist,nPosIni,nPosFim)) //Historico
					nPosIni+=nPosFim
					li+=10
					
					IF li >= (nMaxLin-100)
						oPrinter:EndPage()
						Li := 15
						nPagina++
						CabecCo(nPagina,oPrinter,Alltrim((cAliasProd)->B1_COD) + " - "+(cAliasProd)->B1_DESC+" "+ Alltrim((cAliasProd)->B1_CONCENT ) +" "+ Alltrim((cAliasProd)->B1_QTDEMBA) + "(" + Alltrim((cAliasProd)->B1_SUBATIV) + "-" +  Alltrim((cAliasProd)->B1_CODDCB) + ")")		// imprime cabecalho do Relatorio
					EndIF
				Next
				oPrinter:Line( li-((nTotHist * 10)+10), nMaxCol-10	, li, nMaxCol-10,, ) //LINHA DA DIREITA
				
			ElseIf Len(Alltrim(cObservacao)) > 1
				oPrinter:Say(li-20,370,Alltrim(cObservacao)) //historico
				//li+=10

				oPrinter:Line( li-20, nMaxCol-10, li, nMaxCol-10,, ) //LINHA DA DIREITA
			EndIf
			
			oPrinter:Line( li, 5, li, nMaxCol-10,, )
			
			
			(cAliasMov)->(dbSkip())
			
			IF li >= (nMaxLin-100)
				li+=30
				oPrinter:Say(li,70,"______________________________________________" ,oFontT)
				Li+=10
				oPrinter:Say(li,70,"(Assinatura do Farmacêutico Responsável)" ,oFontT)

				oPrinter:EndPage()
				Li := 15
				nPagina++
				CabecCo(nPagina,oPrinter,Alltrim((cAliasProd)->B1_COD) + " - "+(cAliasProd)->B1_DESC+" "+ Alltrim((cAliasProd)->B1_CONCENT ) +" "+ Alltrim((cAliasProd)->B1_QTDEMBA) + "(" + Alltrim((cAliasProd)->B1_SUBATIV) + "-" +  Alltrim((cAliasProd)->B1_CODDCB) + ")")		// imprime cabecalho do Relatorio
			EndIF
			
			
		EndDo
		
		
		Li+=30
		oPrinter:Say(li,70,"______________________________________________" ,oFontT)
		Li+=10
		oPrinter:Say(li,70,"(Assinatura do Farmacêutico Responsável)" ,oFontT)
		
		oPrinter:EndPage()
		Li := 15
		
		nPagina++
		
		If Select((cAliasMov)) > 0
			(cAliasMov)->(dbCloseArea())
		EndIf	
						
		(cAliasProd)->(dbSkip())
	EndDo
	
	If llRet 
		ImpTermo(nPagina,oPrinter,"F")
	EndIf
	
	If Select((cAliasProd)) > 0
		(cAliasProd)->(dbCloseArea())
	EndIf
If llRet	
	oPrinter:Print()
Else
	Alert("Não a itens a serem impressos")
EndIf

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
±±³ Uso      ³ RELCOVISA                                                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CabecCo(nPagMe,oPrinter,cCabec1)
Local cTitulo := "Folha do Livro de Registro Específico"
Local cCabec2 := "" 
Local nBegin       
Local nAltura  := 0
Local nLarg    := 0
Local nLinha   := 0
Local nPixel   := 0
Local nomeprog := "RELCOVISA"

Private oFontC
Private oFontT

Default cCabec1 := "Produto da Página"

oFontT := TFont():New('Courier new',,8,.T.)
oFontC := TFont():New('Courier new',,12,.T.)
oPrinter:StartPage()
oPrinter:Line( li, 5, li, nMaxCol-10,, )
li+= 20
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)

oPrinter:SayAlign(li,0,cTitulo,oFontC,nMaxCol-10,200,,2) 
oPrinter:SayAlign(li,0,Alltrim(STR(nPagMe)),oFontC,nMaxCol-10,200,,1) 
li += 20
oPrinter:SayAlign(li,0,cCabec1,oFontT,600,200,,2) 
li+= 15
oPrinter:Line( li, 5, li, nMaxCol-10,, )
Li+=10

oPrinter:Say(li,24,"DATA",oFontT)
oPrinter:Say(li,120,"HISTÓRICO",oFontT)
oPrinter:Say(li,245,"MOVIMENTO",oFontT)
oPrinter:Say(li,322,"ESTOQUE",oFontT)
//oPrinter:Say(li,382,"ASS.RESP.TECNICO",oFontT)
//oPrinter:Say(li,500,"OBSERVACOES",oFontT)
oPrinter:Say(li,400,"OBSERVAÇÕES",oFontT)

li+=10
oPrinter:Line( li, 5, li, nMaxCol-10,, )

li+=15
oPrinter:Line( li-35, 5, li, 5,, ) // LINHA DA ESQUERDA
oPrinter:Say(li-5,7,"Dia",oFontT)	
oPrinter:Line( li-15, 25, li, 25,, ) //DIREITA DO DIA
oPrinter:Say(li-5,27,"Mês",oFontT)
oPrinter:Line( li-15,45, li, 45,, ) //DIREITA DO MES
oPrinter:Say(li-5,47,"Ano",oFontT)
oPrinter:Line( li-35, 70, li, 70,, ) //DIREITA DO ANO
oPrinter:Line(li-35, 220, li, 220,, ) //DIREITA DO HISTORICO


oPrinter:Say(li-5,222,"Entrada",oFontT)	
oPrinter:Line( li-15, 260, li, 260,, ) //DIREITA DA ENTRADA
oPrinter:Say(li-5,262,"Saída",oFontT)
oPrinter:Line( li-15,290, li, 290,, ) //DIREITA DA SAIDA
oPrinter:Say(li-5,292,"Perda",oFontT)
oPrinter:Line( li-35, 320, li, 320,, ) //DIREITA DA PERDA
oPrinter:Line( li-35, 360, li, 360,, ) //DIREITA DO ESTOQUE
oPrinter:Line( li-35, nMaxCol-10, li, nMaxCol-10,, ) //LINHA DA DIREITA
oPrinter:Line( li, 5, li, nMaxCol-10,, )

Return

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ ImpTermo  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o Termo de Abertura e Encerramento do Relatorio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ 	   		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELCOVISA                                                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpTermo(nPagMe,oPrinter,tpTermo)
Local cTitulo := "ANEXO XIX"
Local cCabec1 := ""
Local cCabec2 := "" 
Local nBegin       
Local nAltura  := 0
Local nLarg    := 0
Local nLinha   := 0
Local nPixel   := 0
Local nomeprog := "RELCOVISA"
Local aMeses:= {'Janeiro'	,'Fevereiro','Março'	,;
				'Abril'		,'Maio'     ,'Junho'	,;
				'Julho' 	,'Agosto'   ,'Setembro'	,;
				'Outubro'	,'Novembro' ,'Dezembro'	}

Private oFontC
Private oFontT

If tpTermo == "A"
	cCabec1 := "TERMO DE ABERTURA"
ElseIf tpTermo == "F"
	cCabec1 := "TERMO DE ENCERRAMENTO"
EndIf

oFontT := TFont():New('Courier new',,10,.T.)
oFontC := TFont():New('Courier new',,12,.T.,.T.)
oPrinter:StartPage()

li+= 20
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)
oPrinter:SayAlign(li,0,cTitulo,oFontC,nMaxCol-10,200,,2) 
li += 20
oPrinter:SayAlign(li,0,cCabec1,oFontC,600,200,,2) 
oPrinter:SayAlign(li,0,Alltrim(STR(nPagMe)),oFontT,600,200,,1) 
Li+=50

If tpTermo == "A"
	oPrinter:Say(li,70,"Este livro contém de 1 a folha(s) numeradas tipograficamente à máquina," ,oFontT)
ElseIf tpTermo == "F"
	oPrinter:Say(li,70,"Este livro contém de 1 a " + Alltrim(STR(nPagMe)) + " folha(s) numeradas tipograficamente à máquina," ,oFontT)
EndIf

Li+=20
oPrinter:Say(li,70,"servirá para o" ,oFontT)
Li+=20
oPrinter:Say(li,70,"Registro dos livro " + cDescLista ,oFontT)
Li+=20
oPrinter:Say(li,70,"da firma " + Alltrim(UPPER(SM0->M0_NOMECOM)), oFontT)
Li+=20
oPrinter:Say(li,70,"Farmácia " + Alltrim(UPPER(SM0->M0_NOME)) ,oFontT)
Li+=20
oPrinter:Say(li,70,"Farmacêutico(a) " + UPPER(Alltrim(cUserName)) ,oFontT)
Li+=20
oPrinter:Say(li,70,"Estabelecido à " + Alltrim(UPPER(SM0->M0_ENDCOB)),oFontT)
Li+=20
oPrinter:Say(li,70,"Na cidade de " + Alltrim(UPPER(SM0->M0_CIDCOB)) + " Estado de " + Alltrim(UPPER(SM0->M0_ESTCOB)) ,oFontT)
Li+=20
oPrinter:Say(li,70,"Inscrição Estadual N° " + Alltrim(UPPER(SM0->M0_INSC)) ,oFontT)
Li+=20
oPrinter:Say(li,70,"Inscrição no Cadastro Geral do Contribuinte do Ministério da Fazenda" ,oFontT)
Li+=20
oPrinter:Say(li,70,"N° " ,oFontT)
Li+=50
oPrinter:Say(li,70,"_______________________," + Alltrim(STR(day(dDataBase))) + " de " + aMeses[Month(Date())]  + " de " + Alltrim(STR(year(dDataBase))) ,oFontT)
Li+=70
oPrinter:Say(li,70,"______________________________________________" ,oFontT)
Li+=10
oPrinter:Say(li,70,"(Assinatura e carimbo da Autoridade Sanitária)" ,oFontT)

ImpTer := .F.

Return