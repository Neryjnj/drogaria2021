#Include "Protheus.ch"
#Include "Rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ImpExtrato³ Autor ³ Pedro Tostes          ³ Data ³ 08.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para realizar o impressao do extrato para o cliente. ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function ImpExtrato()
Local cIndex      := ""
Local cChave      := ""

Private cAlias    := Alias()                     
Private xMesFecDe := Ctod("  /  /  ")
Private xMesFecAt := Ctod("  /  /  ")
Private xCliDe    := Space(6)
Private xLojaDe   := Space(2)
Private xCliAt    := Space(6)
Private xLojaAt   := Space(2)
Private xTotal    := 0
Private xParc     := {}
Private aProdAdd  := {}

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria os objetos de fontes que serao utilizadas na impressao do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFont08  := TFont():New("Arial",,08,,.F.,,,,.F.,.F.)
oFont09  := TFont():New("Arial",,09,,.F.,,,,.F.,.F.)
oFont09b := TFont():New("Arial",,09,,.T.,,,,.F.,.F.)
oFont09bi:= TFont():New("Arial",,09,,.T.,,,,.T.,.F.)
oFont10b := TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
oFont10  := TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
oFont12  := TFont():New("Arial",,12,,.F.,,,,.F.,.F.)
oFont14  := TFont():New("Arial",,14,,.F.,,,,.F.,.F.)
oFont14b := TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
oFont16b := TFont():New("Arial",,16,,.T.,,,,.F.,.F.)
oFont20b := TFont():New("Arial",,20,,.T.,,,,.F.,.F.)
  
Define Msdialog oDlg From 22,9 To 250,360 Title "Extrato do Cliente" Pixel

@ 015, 014 MsGet xCliDe		Picture "@!" F3 "SA1" 	Valid Empty(xCliDe) .Or. ValCli(xCliDe) 	 		 Size 50, 11 Of oDlg Pixel  
@ 015, 076 MsGet xLojaDe	Picture "@!" 			Valid Empty(xLojaDe).Or. ValCli(xCliDe,xLojaDe)   Size 21, 11 Of oDlg Pixel
@ 045, 014 MsGet xCliAt		Picture "@!" F3 "SA1" 	Valid !Empty(xCliAt) .Or. ValCli(xCliAt)			 Size 50, 11 Of oDlg Pixel  
@ 045, 076 MsGet xLojaAt	Picture "@!" 			Valid !Empty(xLojaAt) .Or. ValCli(xCliAt,xLojaAt) Size 21, 11 Of oDlg Pixel
@ 075, 014 Msget xMesFecDe Size 40, 11 Of oDlg Pixel
@ 075, 064 Msget xMesFecAt Size 40, 11 Of oDlg Pixel
                         	
@ 005, 014 Say "Do Cliente" 	Size 50, 11 Object oCliDe
oCliDe:oFont := oFont16b
@ 005, 076 Say "Da Loja"  		Size 50, 11 Object oLojaDe //Of oDlg Pixel
oLojaDe:oFont := oFont16b
@ 035, 014 Say "Ate Cliente"	Size 50, 11 Object oCliAte
oCliAte:oFont := oFont16b
@ 035, 076 Say "Ate Loja"  		Size 50, 11 Object oLojaAte
oLojaAte:oFont := oFont16b
@ 065, 014 Say "Da Emissao"		Size 50, 11 Object oEmisDe
oEmisDe:oFont := oFont16b
@ 065, 064 Say "Ate Emissao"	Size 50, 11 Object oEmisAte
oEmisAte:oFont := oFont16b

Define Sbutton From 07, 125 Type 1 Action ImpExt() Enable Of oDlg
Define Sbutton From 25, 125 Type 2 Action oDlg:End() Enable Of oDlg

Activate Msdialog oDlg Centered  
                                                 
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} ImpExt

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function ImpExt()                         

Local oPrint

oPrint	:= TMSPrinter():New() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objeto que controla o tipo de impressao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               
oPrint:SetPortrait()
oPrint:Setup()      

DbSelectArea("SE1")
cIndex := CriaTrab(NIL,.F.)
cChave := "E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PARCELA+E1_STATUS+DTOS(E1_EMISSAO)"
IndRegua("SE1",cIndex,cChave,,FiltraExt(),"Selecionando registros...")
nIndex := RetIndex(cAlias)
dbSelectArea(cAlias)
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
DbGoTop()

If BOF() .and. EOF()
	Help(" ",1,"RECNO")
	DbClearFilter()
	dbSetOrder(1)
	RetIndex("SE1")
	//Set Filter To
	dbGoTop()
	FErase(cIndex+OrdBagExt())     
	FreeUsedCode()
	Return()
EndIf                               

While !EOF()
    
	oPrint:StartPage()

	CabRelExt(oPrint)
	                
	DetRelExt(oPrint)
		
	oPrint:EndPage()
	
	DbSelectArea(cAlias)
	DbSkip()
	
EndDo

//Imprime em tela
oPrint:Preview()                     

oDlg:End()

//Spool de impressão
MS_FLUSH()
	
dbSelectArea(cAlias)
DbClearFiler()
RetIndex(cAlias)
If !Empty(cIndex)
	fErase(cIndex+OrdBagExt())
	cIndex := ""
Endif

DbSelectArea("SE1")
dbSetOrder(1)
dbSeek(xFilial())
	                                         
Return .T.      
      
//----------------------------------------------------------
/*/{Protheus.doc} CabRelExt

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function CabRelExt(oPrint)
Local aArea		:= GetArea()
Local i

oPrint:Say(180 ,900, "EXTRATO DE COMPRA"  , oFont20b, 100)

oPrint:Say(315 ,1230, "CLIENTE" , oFont10b , 100)
oPrint:Line(335,030,335,1210)  //Tracejado antes do cliente
oPrint:Line(335,030,375,030)    
SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
oPrint:Say(360 ,050, Alltrim(SA1->A1_NOME) , oFont14 , 100)
oPrint:Line(335,1400,335,2100)  //Tracejado depois do cliente  
oPrint:Line(335,2100,375,2100)  

xParc := Valdata(SA1->A1_CONFIG)

DbSelectArea("SA1")

For i:=1 To 5
	If !Empty(&("A1_PROD"+Alltrim(Str(i))))
		Aadd(aProdAdd,{&("A1_PROD"+Alltrim(Str(i))),0})
	EndIf
Next i

DbSelectArea("SB1")
DbSetOrder(1)
DbGoTop()
For i:=1 to len(aProdAdd)
	If DbSeek(xFilial("SB1")+aProdAdd[i][1])
		aProdAdd[i][2] := SB1->B1_PRV1
	EndIf
	dbGotop()
Next i

oPrint:Say(435 ,138, "Data" , oFont09b , 100)       
oPrint:Line(455,030,455,120)  //Tracejado antes 
oPrint:Line(455,030,495,030)  
oPrint:Line(455,215,455,430)  //Tracejado depois
oPrint:Line(455,430,495,430)                              

oPrint:Say(435 ,1230, "Descrição" , oFont09b , 100)       
oPrint:Line(455,520 ,455,1210)  //Tracejado antes 
oPrint:Line(455,520 ,495,520)  
oPrint:Line(455,1400,455,1850)  //Tracejado depois
oPrint:Line(455,1850,495,1850)  

oPrint:Say(435 ,2020, "Valor R$" , oFont09b , 100)       
oPrint:Line(455,1920,455,2000)  //Tracejado antes 
oPrint:Line(455,1920,495,1920)  
oPrint:Line(455,2220,455,2350)  //Tracejado depois
oPrint:Line(455,2350,495,2350)  

RestArea(aArea)

Return
       
//----------------------------------------------------------
/*/{Protheus.doc} DetRelExt

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function DetRelExt(oPrint)
Local xLin            := 505        
Local xMes            := Dtos(Ctod("01/"+Substr(Dtoc(Ctod("01/"+Substr(Dtoc(ddatabase),4,5))-1),4,5)))      
Local xCliente        := SE1->E1_CLIENTE        
Local xLoja           := SE1->E1_LOJA
Local ImpAnt          := .T.
Local i
Local aE1Area         := {}
Local cChave          := Space(0)

xTotal := 0

DbSelectArea("SE1") 
DbSetOrder(17)                            
DbGoTop()
DbSeek(xFilial("SE1")+xMes+xCliente+xLoja,.T.)
While !EOF() .And. ImpAnt    
	If SE1->E1_CLIENTE+SE1->E1_LOJA = xCliente+xLoja
		If !Empty(E1_MESFEC)               
			oPrint:Say(xLin ,800 , "SALDO ANTERIOR"    , oFont14 , 100)       				
			oPrint:Say(xLin ,1950, Transform(SE1->E1_VALOR+SE1->E1_JUROS+SE1->E1_VALMULT,"@E 999,999,999.99"), oFont14 , 100)       				
			xTotal += SE1->E1_VALOR+SE1->E1_JUROS+SE1->E1_VALMULT
			xLin   += 100        
			ImpAnt := .F. 
			
			xParc[1][2] := Proxdata(xParc[1][2])
			
		EndIf
	EndIf                   
	DbSkip()
EndDo

If ImpAnt                     
	oPrint:Say(xLin ,800 , "SALDO ANTERIOR" 	, oFont14 , 100)       		
	oPrint:Say(xLin ,1950, Transform(SE1->E1_VALOR+SE1->E1_JUROS+SE1->E1_VALMULT,"@E 999,999,999.99"), oFont14 , 100)       				
	xTotal += SE1->E1_VALOR+SE1->E1_JUROS+SE1->E1_VALMULT
	xLin   += 100  
EndIf      

DbSelectArea(cAlias)                
DbSetOrder(nIndex+1)
DbGoTop() 
aE1Area := GetArea()       
If !Empty(SE1->E1_MESFEC)                
	cChave  := E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
	
	DbSelectArea("SE1")
	DbSetOrder(10)
	DbGoTop()
	If DbSeek(xFilial("SE1")+cChave)
		While !EOF() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_FATPREF+E1_FATURA = cChave
			If Empty(SE1->E1_MESFEC)
				oPrint:Say(xLin ,110 , DTOC(E1_EMISSAO) 	, oFont14 , 100)       		
				oPrint:Say(xLin ,800 , "COMPRA NO ROTATIVO" , oFont14 , 100)       				
				oPrint:Say(xLin ,1950, Transform(SE1->E1_SALDO,"@E 999,999,999.99"), oFont14 , 100)       				
				xTotal += SE1->E1_SALDO
				xLin   += 50            
			EndIf                                                                                    
			DbSkip()
		EndDo
	EndIf                
	RestArea(aE1Area)
Else
	While !EOF()
		If Empty(SE1->E1_MESFEC)
			oPrint:Say(xLin ,110 , DTOC(E1_EMISSAO) 	, oFont14 , 100)       		
			oPrint:Say(xLin ,800 , "COMPRA NO ROTATIVO" , oFont14 , 100)       				
			oPrint:Say(xLin ,1950, Transform(SE1->E1_SALDO,"@E 999,999,999.99"), oFont14 , 100)       				
			xTotal += SE1->E1_SALDO
			xLin   += 50            
		EndIf                                                                                    
		DbSkip()
	EndDo
EndIf

If !Empty(SE1->E1_MESFEC)
	oPrint:Say(xLin ,110 , DTOC(E1_EMISSAO) 	, oFont14 , 100)       		
	oPrint:Say(xLin ,800 , "FATURA MENSAL" , oFont14 , 100)       				
	oPrint:Say(xLin ,1950, Transform(SE1->E1_SALDO,"@E 999,999,999.99"), oFont14 , 100)       				
	xTotal += SE1->E1_SALDO
	xLin   += 50            
EndIf   
       
For i:=1 To Len(aProdAdd)
	SB1->(DbSeek(xFilial("SB1")+aProdAdd[i][1]))   
	oPrint:Say(xLin ,800, Alltrim(SB1->B1_DESC) , oFont14 , 100)       						
	oPrint:Say(xLin ,1950, Transform(aProdAdd[i][2],"@E 999,999,999.99")+" +" , oFont14 , 100)       						
	xTotal   += aProdAdd[i][2]
	xLin     += 50
Next i
if xParc[1][4] > 0 
	oPrint:Say(xLin ,800, "TAXA ADMINISTRATIVA" , oFont14 , 100)       						
	oPrint:Say(xLin ,1950, Transform(xParc[1][4],"@E 999,999,999.99")+" +" , oFont14 , 100)       						
	xTotal += xParc[1][4]
	xLin   += 50
EndIf

xLin += 150 

oPrint:Say(xLin ,800 , "SALDO" , oFont14 , 100)       				
oPrint:Say(xLin ,1950, Transform(xTotal,"@E 999,999,999.99")+" +" , oFont14 , 100)       				
xLin += 100            
                                        
oPrint:Say(xLin ,800 , "A PAGAR "+DTOC(xParc[1][2]) , oFont14 , 100)       				
oPrint:Say(xLin ,1950, Transform(xTotal,"@E 999,999,999.99")+" +" , oFont14 , 100)       				
xLin += 100            

Return

//----------------------------------------------------------
/*/{Protheus.doc} FiltraExt

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function FiltraExt()
Local cFiltro := ""

cFiltro += 'E1_FILIAL="' + xFilial("SE1") + '".And.'
cFiltro += 'E1_CLIENTE>="' + xCLiDe + '".And.'
cFiltro += 'E1_CLIENTE<="' + xCliAt + '".And.'
cFiltro += 'E1_LOJA>="' + xLojaDe +'".And.'
cFiltro += 'E1_LOJA<="' + xLojaAt +'".And.'
cFiltro += 'E1_STATUS="A".And.'
cFiltro += 'E1_SITUACA="0".And.'
cFiltro += 'E1_SALDO > 0.And.'

IF cPaisLoc<>"CHI"
	cFiltro += '!(E1_TIPO$"'+MVRECANT+"/"+MVPROVIS+'").And.'
	cFiltro += 'DTOS(E1_EMISSAO)>="'+DTOS(xMesFecDe)+'".And. DTOS(E1_EMISSAO)<="'+DTOS(xMesFecAt)+'"'	
Else
	cFiltro += 'E1_TIPO$"'+MVRECANT+"/"+MVPROVIS+'")'
Endif

Return cFiltro

//----------------------------------------------------------
/*/{Protheus.doc} ValCli

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function ValCli(cCli280,cLoja280 )
Local cAlias := Alias()
Local nOldRec
Local lRet	 := .T.

cLoja280 := Iif(cLoja280 == Nil,"",cLoja280)
     
If Empty(cCli280)
	lRet := .F.
Endif

If lRet
	dbSelectArea("SA1")
	dbSetOrder(1)
	nOldRec := Recno()
	
	IF !(dbSeek(cFilial+cCli280+cLoja280))
		/* 
		Se não encontrou o registro, retorna para o registro salvo pois, se a busca
		estiver ocorrendo para o cliente a faturar e nÆo for encontrado, o SA1 fi - 
		car  desposicionado.														
		*/
		dbGoTo(nOldRec)
		Help(" ",1,"A280CLI")
		lRet := .F.   
	EndIf
	
	If lRet                                                             
		dbSelectArea(cAlias)
	EndIf
EndIf                                         

Return lRet  

//----------------------------------------------------------
/*/{Protheus.doc} ValData

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function Valdata(cConfig)
Local aDt       := {}
Local cDia
Local ddatade
Local ddataate
Local ddataini
Local i

dbselectarea("LFX")
dbsetorder(1)
dbgotop()
If dbseek(xFilial("LFX")+cConfig)   
	//ddatade  := ctod(LFX->LFX_PAGTO+substr(dtoc(xMesFecDe),3,6))
	ddatade  := ctod(LFX->LFX_FECH+substr(dtoc(xMesFecDe),3,6))
	
	//ddataini := ctod(LFX->LFX_VENCTO+"/"+substr(dtoc(xMesFecDe),3,6))
	ddataini := ctod(LFX->LFX_PAGTO+"/"+substr(dtoc(xMesFecDe),3,6))
	
	If Empty(ddatade)
		//cDia := LFX->LFX_PAGTO
		cDia := LFX->LFX_FECH
		For i:=1 to 10
			cDia := Alltrim(Str(Val(cDia) - 1))
			ddatade := ctod(cDia+substr(dtoc(xMesFecDe),3,6))
			If !Empty(ddatade)
				i:=10
			EndIf
		Next i
		ddatade++    //Proxima data valida
	EndIf
	ddataate := DataValida(ddatade,.T.)	
Endif

//Caso não ache nada, retorna vazio
Aadd(aDt,{IIf(ddatade=Nil,ctod("  /  /  "),ddatade),IIf(ddataate=Nil,ctod("  /  /  "),ddataate),IIf(ddataini=Nil,ctod("  /  /  "),ddataini),LFX->LFX_TXADM,LFX->LFX_JUROS,LFX->LFX_MULTA})

Return aDt

//----------------------------------------------------------
/*/{Protheus.doc} ProxData

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Static Function Proxdata(dPar1)
Local i
Local cDia
Local dMes	:= Substr(Dtoc(Ctod("25/"+Substr(Dtoc(dPar1),4,5))+10),4,5)
Local dData	:= Ctod(Strzero(Day(dPar1),2)+"/"+dMes)

If Empty(dData)
	cDia := Strzero(Day(dPar1),2)
	For i:=1 to 10
		cDia := Alltrim(Str(Val(cDia) - 1))
		dData := ctod(cDia+"/"+dMes)
		If !Empty(dData)
			i:=10
		EndIf
	Next i
	dData++    //Proxima data valida
Endif
		
Return dData