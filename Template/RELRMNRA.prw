#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ RELRMNRA  ³ Autor ³ Rodrigo Dias Nunes	³ Data ³ 11/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Movimentação do Medicamento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function RELRMNRA()
Local aOrdem 		:= {"Descriminação"}
Local aDevice 		:= {}
Local bParam		:= {|| Pergunte("RELRMNR", .T.)}
Local cDevice   	:= ""
Local cPathDest 	:= GetSrvProfString("StartPath","\system\")
Local cRelName  	:= "RELRMNR"
Local cSession  	:= GetPrinterSession()
Local cSpool		:= ""
Local lAdjust   	:= .F.
Local nFlags    	:= PD_ISTOTVSPRINTER//+PD_DISABLEPAPERSIZE
Local nLocal    	:= 1
Local nOrdem 		:= 1
Local nOrient   	:= 1
Local nPrintType	:= 6
Local oPrinter 		:= Nil
Local oSetup    	:= Nil
Local lProssegue	:= .T.

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

/*Verifica se usuario tem permissao de 
farmacêutico para incluir registros*/
If lProssegue .And. T_DroVERPerm()
	//se tiver, Verifica se ele está no cadastro
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
	
	cSession	:= GetPrinterSession()
	// Obtem ultima configuracao de tipo de impressão (spool ou pdf) gravada no arquivo de configuracao
	cDevice		:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	// Obtem ultima configuracao de orientacao de papel (retrato ou paisagem) gravada no arquivo de configuracao
	nOrient		:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)

	// Obtem ultima configuracao de destino (cliente ou servidor) gravada no arquivo de configuracao
	nLocal		:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nPrintType  := aScan(aDevice,{|x| x == cDevice })     
	
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
		
		If oSetup:GetProperty(PD_ORIENTATION) <> 2
		   MsgAlert("Este relatório só pode ser emitido no modo PAISAGEM (LANDSCAPE)")
		   lProssegue := .F.
		EndIf
		
		If lProssegue
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
			
			RptStatus({|lEnd| RMNRAProc(@lEnd,nOrdem, @oPrinter)},"Imprimindo Relatorio...")
		EndIf
	Else
		MsgInfo("Relatório cancelado pelo usuário.")//"Relatório cancelado pelo usuário." 
		oPrinter:Cancel()
	EndIf
	
	oSetup	:= Nil
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
Local oFontT	:= TFont():New('Arial',,6,.T.)
Local nPagina 	:= 1
Local cCodMes	:= ""

Private ImpTer	:= .T.

Pergunte("RELRMNR",.F.)

//converte o numero do mes em caractere
If MV_PAR02 < 10
	cCodMes := '0' + cValToChar(MV_PAR02)
Else
	cCodMes := cValToChar(MV_PAR02)
EndIf

SetRegua(100)

cAliasProd := GetNextAlias()
cQProd := " SELECT B1_CODDCB,LKD_DSCDCB,LK9_DESCRI,MHB_APRESE,B1_CONCENT CONCENTRACAO,LK9_NUMREC,LK9_DATARE,LK9_NOMMED,LK9_NUMPRO,LK9_QUANT "
cQProd += " FROM  " + RetSqlName("LK9") + " LK9 "
cQProd += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
cQProd += " ON SB1.B1_COD = LK9.LK9_CODPRO "
cQProd += " INNER JOIN " + RetSqlName("LKD") + " LKD "
cQProd += " ON SB1.B1_CODDCB = LKD.LKD_CODDCB "
cQProd += " INNER JOIN " + RetSqlName("MHB") + " MHB "
cQProd += " ON SB1.B1_CODAPRE = MHB.MHB_CODAPR "

cQProd += " WHERE LK9.D_E_L_E_T_ <> '*' "
cQProd += " AND LK9_DATA BETWEEN '" + MV_PAR01+cCodMes+"01' AND '" + MV_PAR01+cCodMes+"31' "
 
If MV_PAR03 == 1	// Tipo A
	cQProd += " AND LK9_CODLIS in ('A1','A2','A3') "
Else	// Tipo B2
	cQProd += " AND LK9_CODLIS in ('B2','C4') "
EndIf

cQProd += " AND LK9_TIPMOV in ('2') ORDER BY LKD_CODDCB "

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
	Li+=5	
	oPrinter:Say(li+2,7,	AllTrim((cAliasProd)->B1_CODDCB),oFontT)
	oPrinter:Say(li+2,42,	AllTrim((cAliasProd)->LKD_DSCDCB),oFontT)
	oPrinter:Say(li+2,202,	AllTrim((cAliasProd)->LK9_DESCRI),oFontT)
	oPrinter:Say(li+2,352,	AllTrim((cAliasProd)->MHB_APRESE),oFontT)
	oPrinter:Say(li+2,422,	AllTrim((cAliasProd)->CONCENTRACAO),oFontT)
	oPrinter:Say(li+2,472,	(cAliasProd)->LK9_NUMREC,oFontT)
	oPrinter:Say(li+2,502,	DTOC(STOD((cAliasProd)->LK9_DATARE)),oFontT)
	oPrinter:Say(li+2,542,	AllTrim((cAliasProd)->LK9_NOMMED),oFontT)
	oPrinter:Say(li+2,660,	(cAliasProd)->LK9_NUMPRO,oFontT)
	oPrinter:Say(li+2,692,	cValToChar((cAliasProd)->LK9_QUANT),oFontT)
	oPrinter:Say(li+2,732,	cValToChar((cAliasProd)->LK9_QUANT),oFontT)
	
	oPrinter:Line( li-5, 005, li+5, 005) //LINHA DA ESQUERDA 
	oPrinter:Line( li-5, 040, li+5, 040) // DIREITA DO NUMERO DO CODIGO DA DCB
	oPrinter:Line( li-5, 200, li+5, 200) // DIREITA DO DESCRIMINACAO DA DCB
	oPrinter:Line( li-5, 350, li+5, 350) // DIREITA DO NOME DO MEDICAMENTO	//changed
	oPrinter:Line( li-5, 420, li+5, 420) // DIREITA DA APRESENTACAO
	oPrinter:Line( li-5, 470, li+5, 470) // DIREITA DA CONCENTRACAO
	oPrinter:Line( li-5, 500, li+5, 500) // DIREITA DO NUMERO DA RNA
	oPrinter:Line( li-5, 540, li+5, 540) // DIREITA DA DATA DA RNA
	oPrinter:Line( li-5, 658, li+5, 658) // DIREITA DO NOME DO MEDICO
	oPrinter:Line( li-5, 690, li+5, 690) // DIREITA DO NUMERO DO MEDICO
	oPrinter:Line( li-5, 730, li+5, 730) // DIREITA DA QUANTIDADE PRESCRITA
	oPrinter:Line( li-5, nMaxCol-20, li+5, nMaxCol-20) // DIREITA DA QUANTIDADE DISPENSADA
	Li+=5
	oPrinter:Line( li, 5, li, nMaxCol-20,, )
	
	If Li >= 480
		ImpRodape(oPrinter,"F")
	EndIf
			
	IF li >= (nMaxLin-100)
		oPrinter:EndPage()
		Li := 15
		nPagina++
		CabecCo(nPagina,oPrinter)		// imprime cabecalho do Relatorio
	EndIF
	
	(cAliasProd)->(dbSkip())
EndDo

ImpRodape(oPrinter,"M")

oPrinter:EndPage()

If Select((cAliasProd)) > 0
	(cAliasProd)->(dbCloseArea())
EndIf

oPrinter:Print()

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³ Fun‡…o   ³ CabecCo  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho do Medicamento		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CabecCo()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CabecCo(nPagMe,oPrinter,cCabec1)
Local cCNPJCM	:= ""
Local nBegin
Local nAltura	:= 0
Local nLarg		:= 0
Local nLinha	:= 0
Local nPixel	:= 0
Local nomeprog	:= "RELRMNRA"
Local aMeses	:= {'JANEIRO'	, 'FEVEREIRO'	, 'MARÇO'	,;
					'ABRIL'		, 'MAIO'     	, 'JUNHO'	,;
               		'JULHO'		, 'AGOSTO'   	, 'SETEMBRO',;
					'OUTUBRO'	, 'NOVEMBRO'	, 'DEZEMBRO' }
Local cMvLjDroLF:= SuperGetMV("MV_LJDROLF",,"")	//Número da Licença de Funcionamento
Local lMvSpedEnd:= SuperGetMv("MV_SPEDEND",,.F.)
Local nPosIni	:= 0
Local nPosText	:= 0

Private oFontC
Private oFontT

If lMvSpedEnd	
	cEndereco := AllTrim(SM0->M0_ENDENT) + " " + AllTrim(SM0->M0_BAIRENT)
	cCidEst := AllTrim(SM0->M0_CIDENT) + " - " + AllTrim(SM0->M0_ESTENT)
	
Else
	cEndereco := AllTrim(SM0->M0_ENDCOB) + " " + AllTrim(SM0->M0_BAIRCOB)
	cCidEst := AllTrim(SM0->M0_CIDCOB) + " - " + AllTrim(SM0->M0_ESTCOB)
EndIf


oFontT := TFont():New('Courier new',,8,.T.)
oFontN := TFont():New('Arial',,6,.T.,.T.)
oFontC := TFont():New('Courier new',,12,.T.,.T.)
oFontC2 := TFont():New('Courier new',,10,.T.)
oPrinter:StartPage()
li+= 20
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)

oPrinter:Line( li, 5, li, 35)
oPrinter:Line( li, 5, li+30, 5)
oPrinter:Line( li, 250, li, 280)
oPrinter:Line( li, 280, li+30, 280)
oPrinter:SayAlign(li+15,5,AllTrim(Transform(SM0->M0_CGC, '@R 99.999.999/9999-99')),oFontC,280,,,2)
oPrinter:SayAlign(li+30,5,Alltrim(UPPER(SM0->M0_NOMECOM)),oFontC,280,,,2)
oPrinter:SayAlign(li+45,5,cEndereco,oFontC,280,,,2)
oPrinter:SayAlign(li+60,5,cCidEst,oFontC,280,,,2)
oPrinter:Line( li+90, 5, li+90, 35)
oPrinter:Line( li+60, 5, li+90, 5)
oPrinter:Line( li+90, 250, li+90, 280)
oPrinter:Line( li+60, 280, li+90, 280)
oPrinter:SayBitmap(li+15, 290, GetSrvProfString ("ROOTPATH","") + "\System\" + "brasao.jpg", 64,  64)
Li+=5
oPrinter:SayAlign(li,360,"SECRETARIA DE SAÚDE: ESTADO DE SÃO PAULO",oFontC,nMaxCol-10,,,0)
oPrinter:SayAlign(li,0,"Pág: " + Alltrim(STR(nPagMe)),oFontC,nMaxCol-20,200,,1) 
Li+=15
oPrinter:SayAlign(li,360,"AUTORIDADE SANITÁRIA: COVISA",oFontC,nMaxCol-10,,,0)
Li+=15
/*
If MV_PAR02 == 1
	oPrinter:SayAlign(li,360,"RELAÇÃO MENSAL DE NOTIFICAÇÕES DE RECEITA 'A' (RMNRA)",oFontC,nMaxCol-10,,,0)
ElseIf MV_PAR02 == 2
 	oPrinter:SayAlign(li,360,"RELAÇÃO MENSAL DE NOTIFICAÇÕES DE RECEITA 'B2' (RMNRB2)",oFontC,nMaxCol-10,,,0)
EndIf
*/

If MV_PAR03 == 1	// Tipo A
	oPrinter:SayAlign(li,360,"RELAÇÃO MENSAL DE NOTIFICAÇÕES DE RECEITA 'A' (RMNRA)",oFontC,nMaxCol-10,,,0)
Else	// Tipo B2
 	oPrinter:SayAlign(li,360,"RELAÇÃO MENSAL DE NOTIFICAÇÕES DE RECEITA 'B2' (RMNRB2)",oFontC,nMaxCol-10,,,0)
EndIf

Li+=15
oPrinter:SayAlign(li,360,"NÚMERO DA LICENÇA DE FUNCIONAMENTO:" + cMvLjDroLF, oFontC, nMaxCol-10,,,0)
Li+=15
oPrinter:SayAlign(li,360,"CNPJ:" + AllTrim(Transform(SM0->M0_CGC, '@R 99.999.999/9999-99')) ,oFontC,nMaxCol-10,,,0)
Li+=30
oPrinter:SayAlign(li,007,"NOME DA EMPRESA E/OU DO ESTABELECIMENTO:",oFontC,nMaxCol-10,200,,0)

If oPrinter:nDevice == IMP_PDF
	oPrinter:SayAlign(li,230,"___________________________________ EXERCÍCIO:_______ MÊS:____________",oFontC,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,232,AllTrim(SM0->M0_NOMECOM),oFontC2,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,501,MV_PAR01,oFontC2,nMaxCol-20,200,,0)			//EXERCICIO
	oPrinter:SayAlign(li,558,aMeses[MV_PAR02],oFontC2,nMaxCol-20,200,,0)	//MES
	
	Li+=20
	oPrinter:SayAlign(li,007,"ENDEREÇO COMPLETO E TELEFONE DA EMPRESA:",oFontC,nMaxCol-10,200,,0)
	oPrinter:SayAlign(li,230,"______________________________________________________________________",oFontC,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,232, cEndereco + " " + cCidEst,oFontC2,nMaxCol-20,200,,0)
	
	Li+=20	
	oPrinter:SayAlign(li,007,"NOME DO FARMACÊUTICO RESPONSÁVEL E CRF:",oFontC,nMaxCol-10,200,,0)
	oPrinter:SayAlign(li,230,"______________________________________________________________________",oFontC,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,232,AllTrim(LKB->LKB_NOME) + " - " + AllTrim(LKB->LKB_CRF), oFontC2, nMaxCol-20,200,,0)
	
	Li+=20
Else
	oPrinter:SayAlign(li,284,"___________________________________ EXERCÍCIO:_______ MÊS:____________",oFontC,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,286,AllTrim(SM0->M0_NOMECOM),oFontC2,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,612,MV_PAR01,oFontC2,nMaxCol-20,200,,0)			//EXERCICIO
	oPrinter:SayAlign(li,700,aMeses[MV_PAR02],oFontC2,nMaxCol-20,200,,0)	//MES
	
	Li+=20
	oPrinter:SayAlign(li,007,"ENDEREÇO COMPLETO E TELEFONE DA EMPRESA:",oFontC,nMaxCol-10,200,,0)
	oPrinter:SayAlign(li,284,"______________________________________________________________________",oFontC,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,286, cEndereco + " " + cCidEst,oFontC2,nMaxCol-20,200,,0)
	Li+=20
	oPrinter:SayAlign(li,007,"NOME DO FARMACÊUTICO RESPONSÁVEL E CRF:",oFontC,nMaxCol-10,200,,0)
	oPrinter:SayAlign(li,284,"______________________________________________________________________",oFontC,nMaxCol-20,200,,0)
	oPrinter:SayAlign(li,286,AllTrim(LKB->LKB_NOME) + " - " + AllTrim(LKB->LKB_CRF), oFontC2, nMaxCol-20,200,,0)
	Li+=20
EndIf

oPrinter:Line( li, 5, li, nMaxCol-20)

Li+=5

oPrinter:Line( li-5, 5, li+30, 5) //LINHA DA ESQUERDA 
oPrinter:SayAlign(li,7,"N° do",oFontN,30,45,2)
oPrinter:SayAlign(li+6,7,"Código",oFontN,30,45,2)
oPrinter:SayAlign(li+13,7,"da D.C.B",oFontN,30,45,2)

oPrinter:Line( li-5, 40, li+30, 40) // DIREITA DO NUMERO DO CODIGO DA DCB

oPrinter:SayAlign(li+10,80,"Descriminação da D.C.B",oFontN,230,45,2,0)
oPrinter:Line( li-5, 200, li+30, 200) // DIREITA DO DESCRIMINACAO DA DCB

oPrinter:SayAlign(li+10,240,"Nome do Medicamento",oFontN,230,45,2,0)
oPrinter:Line( li-5, 350, li+30, 350) // DIREITA DO NOME DO MEDICAMENTO

oPrinter:SayAlign(li+10,352,"Apresentação",oFontN,60,45,2,0)
oPrinter:Line( li-5, 420, li+30, 420) // DIREITA DA APRESENTACAO

oPrinter:SayAlign(li+10,422,"Concentração",oFontN,60,45,2,0)
oPrinter:Line( li-5, 470, li+30, 470) // DIREITA DA CONCENTRACAO

If MV_PAR03 == 1	//Tipo A
	//oPrinter:SayAlign(li+10,462,"Número da RNA",oFontN,40,45,2,0)	
	oPrinter:SayAlign(li+07,472,"Número",oFontN,30,45,2)
	oPrinter:SayAlign(li+13,472,"da RNA",oFontN,30,45,2)

	oPrinter:Line( li-5, 500, li+30, 500) // DIREITA DO NUMERO DA RNA

	oPrinter:SayAlign(li+10,502,"Data da RNA",oFontN,40,45,2,0)
	oPrinter:Line( li-5, 540, li+30, 540) // DIREITA DA DATA DA RNA
Else //Tipo B2
	oPrinter:SayAlign(li+07,472,"Número" ,oFontN,30,45,2)
	oPrinter:SayAlign(li+13,472,"da RNB2",oFontN,30,45,2)	
	oPrinter:Line( li-5, 500, li+30, 500) // DIREITA DO NUMERO DA RNB2

	oPrinter:SayAlign(li+10,502,"Data da RNB2",oFontN,40,45,2,0)
	oPrinter:Line( li-5, 540, li+30, 540) // DIREITA DA DATA DA RNB2
EndIf

oPrinter:SayAlign(li+10,570,"Nome do Médico",oFontN,230,45,2,0)
oPrinter:Line( li-5, 658, li+30, 658) // DIREITA DO NOME DO MEDICO

//oPrinter:SayAlign(li+10,660,"N° do Medico",oFontN,35,45,2,0)
oPrinter:SayAlign(li+7,660,"N° do",oFontN,30,45,2)
oPrinter:SayAlign(li+13,660,"Médico",oFontN,30,45,2)
oPrinter:Line( li-5, 690, li+30, 690) // DIREITA DO NUMERO DO MEDICO

//oPrinter:SayAlign(li+10,692,"Quantidade Prescrita",oFontN,40,45,2,0)
oPrinter:SayAlign(li+7,692,"Quantidade",oFontN,30,45,2)
oPrinter:SayAlign(li+13,692,"Prescrita",oFontN,30,45,2)
oPrinter:Line( li-5, 730, li+30, 730) // DIREITA DA QUANTIDADE PRESCRITA

//Printer:SayAlign(li+10,740,"Quantidade Dispensada",oFontN,40,45,2,0)
oPrinter:SayAlign(li+7	,735, "Quantidade",oFontN,40,45,2)
oPrinter:SayAlign(li+13	,735, "Dispensada",oFontN,40,45,2)
oPrinter:Line( li-5, nMaxCol-20, li+30, nMaxCol-20) // DIREITA DA QUANTIDADE DISPENSADA
Li+=30
oPrinter:Line( li, 5, li, nMaxCol-20)
//li+=5

Return NIL
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ ImpCapa  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o Termo de Abertura e Encerramento do Relatorio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ 	   		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function ImpCapa(nPagMe,oPrinter)

Local cTitulo	:= "" //"RMNRA"
Local cCabec1 	:= ""	
Local nBegin       
Local nAltura	:= 0
Local nLarg		:= 0
Local nLinha	:= 0
Local nPixel	:= 0
Local nomeprog 	:= "RELRMNRA"
Local aMeses	:= {'JANEIRO'	, 'FEVEREIRO', 'MARÇO'		,; 
					'ABRIL' 	, 'MAIO'     , 'JUNHO'		,; 
					'JULHO'		, 'AGOSTO'   , 'SETEMBRO'	,; 
					'OUTUBRO'	, 'NOVEMBRO' , 'DEZEMBRO'	}

Private oFontC
Private oFontT

If MV_PAR03 == 1	//Tipo A
	cTitulo := "RMNRA"
Else	// Tipo B2
	cTitulo := "RMNRB2"
EndIf

oFontT  := TFont():New('Courier new',,15,.T.,.T.)
oFontC  := TFont():New('Courier new',,22,.T.,.T.)
oFontCT := TFont():New('Courier new',,30,.T.,.T.)
oPrinter:StartPage()
nAltura := 10//oPrinter:nPageHeight
nLargura:= 10//oPrinter:nPageWidth
oPrinter:Cmtr2Pix(nAltura,nLargura)
oPrinter:Box(20,20,nMaxLin-30,nMaxCol-20)
oPrinter:Box(25,25,nMaxLin-35,nMaxCol-25)
Li := 100
oPrinter:SayAlign(li,0,cTitulo,oFontCT,nMaxCol-10,200,,2) 
Li += 100
oPrinter:SayAlign(li,40,Alltrim(UPPER(SM0->M0_NOMECOM)),oFontC,600,200,,0) 
Li += 110
oPrinter:SayAlign(li,40,"Período de: " + aMeses[MV_PAR02] + "/" + MV_PAR01, oFontC, 500, 200,,0)
Li+=110
oPrinter:SayAlign(li,40,"Data de Emissão: "+ DTOC(dDataBase),oFontC,600,200,,0)
Li+=110
oPrinter:SayAlign(li,40,"TOTVS SA",oFontT,500,200,,0)

ImpTer := .F.

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ ImpRodape  ³ Autor ³ Rodrigo Dias Nunes³ Data ³ 11/11/15 ³    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho do Medicamento		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ ImpRodape()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RELRMNRA                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
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

Return NIL