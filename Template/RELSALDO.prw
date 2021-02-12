#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ RELSALDO  ³ Autor ³ Rodrigo Dias Nunes	³ Data ³ 11/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Movimentação do Medicamento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function RELSALDO()
Local aOrdem 		:= {"Codigo Interno","Nome Comercial","Saldo"}
Local aDevice 		:= {}
Local bParam		:= {|| Pergunte("RELSALDO", .T.)}
Local cDevice   	:= ""
Local cPathDest 	:= GetSrvProfString("StartPath","\system\")
Local cRelName  	:= "RELSALDO"
Local cSession  	:= GetPrinterSession()
Local cSpool		:= ""
Local lProssegue	:= .T.
Local lAdjust   	:= .F.
Local nFlags    	:= PD_ISTOTVSPRINTER//+PD_DISABLEPAPERSIZE
Local nLocal    	:= 1
Local nOrdem 		:= 1
Local nOrient   	:= 1
Local nPrintType	:= 6
Local oPrinter 	:= Nil
Local oSetup    	:= Nil
Private aArray	:= {}
Private li			:= 15
Private nMaxLin	:= 0
Private nMaxCol	:= 0
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
	nOrient	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
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
		
		RptStatus({|lEnd| SaldoProc(@lEnd,nOrdem, @oPrinter)},"Imprimindo Relatorio...")
	Else 
		MsgInfo("Relatório cancelado pelo usuário.")//"Relatório cancelado pelo usuário." 
		oPrinter:Cancel()
	EndIf
	
	oSetup:= Nil
	oPrinter:= Nil
EndIf

Return lProssegue

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    | SaldoProc  ³ Autor ³ Rodrigo Dias Nunes	³ Data ³ 11/11/15 ³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o processamento do relatorio	                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELSALDO                                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SaldoProc(lEnd, nOrdem, oPrinter)
Local nBegin	:= 0
Local cQProd	:= ""
Local oFontT	:= TFont():New('Courier new',,8,.T.)
Local nPagina 	:= 1

Private ImpTer	:= .T.

Pergunte("RELSALDO",.F.)

SetRegua(100)	

cAliasProd := GetNextAlias()
cQProd := " SELECT B1_COD CODIGO_INTERNO,B1_DESC NOME_COMERCIAL,COALESCE(B2_QATU,0) SALDO , B2_LOCAL LOCAL"
cQProd += " FROM " + RetSQLName("SB1") + " SB1"
cQProd += " LEFT JOIN " + RetSQLName("SB2") + " SB2"
cQProd += " ON SB1.B1_COD = SB2.B2_COD AND SB1.D_E_L_E_T_ = SB2.D_E_L_E_T_"
cQProd += " WHERE  SB1.D_E_L_E_T_ <> '*'"
cQProd += " AND B1_COD BETWEEN '" +MV_PAR01+ "' AND '" +MV_PAR02+ "'"
If !Empty(MV_PAR03)
	cQProd += " AND B1_CODLIS = '" +MV_PAR03+ "' "
EndIf
If nOrdem == 1
	cQProd += " ORDER BY CODIGO_INTERNO "
ElseIf nOrdem == 2
	cQProd += " ORDER BY NOME_COMERCIAL "
ElseIf nOrdem == 3
	cQProd += " ORDER BY SALDO "
EndIf

cQProd := ChangeQuery(cQProd)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQProd),cAliasProd,.T.,.T.)

If (cAliasProd)->(EOF())
	Alert("Não a itens a serem impressos")
	Return(.T.)
EndIf

IncRegua()

If ImpTer
	ImpCapa(nPagina,oPrinter)	
	oPrinter:EndPage()
	Li := 15
EndIf
	
cabecCo(nPagina,oPrinter)

While (cAliasProd)->(!EOF())
	Li+=10
	oPrinter:Say(li,7,(cAliasProd)->CODIGO_INTERNO,oFontT)
	oPrinter:Say(li,120,(cAliasProd)->NOME_COMERCIAL,oFontT)
	oPrinter:Say(li,500,Alltrim(STR((cAliasProd)->SALDO)),oFontT)
	oPrinter:Say(li,600,(cAliasProd)->LOCAL,oFontT)
	Li+=10
	oPrinter:Line( li, 5, li, nMaxCol-10,, )
		
	IF li >= (nMaxLin-100)
		oPrinter:EndPage()
		Li := 15
		nPagina++
		CabecCo(nPagina,oPrinter)		// imprime cabecalho do Relatorio
	EndIF
	
	(cAliasProd)->(dbSkip())
EndDo

oPrinter:EndPage()

If Select((cAliasProd)) > 0
	(cAliasProd)->(dbCloseArea())
EndIf

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
±±³ Uso      ³ RELSALDO                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CabecCo(nPagMe,oPrinter,cCabec1)
Local cTitulo 	:= "TOTVS SA"
Local cTitulo2 	:= Alltrim(UPPER(SM0->M0_NOMECOM))
Local cTitulo3	:= "Relatório de Saldos"
Local nBegin       
Local nAltura  := 0
Local nLarg    := 0
Local nLinha   := 0
Local nPixel   := 0
Local nomeprog := "RELSALDO"

Private oFontC
Private oFontT

oFontT := TFont():New('Courier new',,8,.T.)
oFontN := TFont():New('Courier new',,8,.T.,.T.)
oFontC := TFont():New('Courier new',,12,.T.,.T.)
oPrinter:StartPage()
oPrinter:Line( li, 5, li, nMaxCol-10,, )
li+= 20
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)

oPrinter:SayAlign(li,7,cTitulo,oFontC,nMaxCol-10,200,,0)
Li+=13
oPrinter:SayAlign(li,7,cTitulo2,oFontC,nMaxCol-10,200,,0)
Li+=13
oPrinter:SayAlign(li,7,cTitulo3,oFontC,nMaxCol-10,200,,0) 
oPrinter:SayAlign(li,0,"Pag: " + Alltrim(STR(nPagMe)),oFontC,nMaxCol-10,200,,2) 
li+= 20
oPrinter:Line( li, 5, li, nMaxCol-10,, )
Li+=10

oPrinter:Say(li,7,"Codigo Interno",oFontN)
oPrinter:Say(li,120,"Nome Comercial",oFontN)
oPrinter:Say(li,500,"Saldo",oFontN)
oPrinter:Say(li,600,"Local",oFontN)


li+=10
oPrinter:Line( li, 5, li, nMaxCol-10,, )
Return 

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ ImpCapa  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o Termo de Abertura e Encerramento do Relatorio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ 	   		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELSALDO                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ImpCapa(nPagMe,oPrinter)
Local cTitulo := "Relatório de Saldos"
Local cCabec1 := ""
Local nBegin       
Local nAltura  := 0
Local nLarg    := 0
Local nLinha   := 0
Local nPixel   := 0
Local nomeprog := "RELSALDO"

Private oFontC
Private oFontT

oFontT := TFont():New('Courier new',,10,.T.,.T.)
oFontC := TFont():New('Courier new',,22,.T.,.T.)
oPrinter:StartPage()
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)
oPrinter:Box(20,20,nMaxLin-30,nMaxCol-15)
oPrinter:Box(25,25,nMaxLin-35,nMaxCol-20)
Li := 100
oPrinter:SayAlign(li,40,cTitulo,oFontC,nMaxCol-10,200,,0) 
If !Empty(MV_PAR03)
	Li += 125
	oPrinter:SayAlign(li,40,UPPER(Alltrim(POSICIONE("LX5",1,XFILIAL("LX5")+"T8"+MV_PAR03,"LX5_DESCRI"))),oFontC,500,200,,0)
	Li += 125
Else
	Li += 250
EndIf
oPrinter:SayAlign(li,40,Alltrim(UPPER(SM0->M0_NOME)),oFontC,600,200,,0) 
Li+=180
oPrinter:SayAlign(li,40,"Data de Emissão: "+ DTOC(dDataBase),oFontC,600,200,,0)
Li+=170
oPrinter:SayAlign(li,40,"TOTVS SA",oFontT,500,200,,0)

ImpTer := .F.

Return