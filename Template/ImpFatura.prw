#Include "Protheus.ch"
#Include "Rwmake.ch"  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ImpFatura ³ Autor ³ Pedro Tostes          ³ Data ³ 08.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para realizar o impressao da fatura para o cliente.  ³±±     
±±³          ³Esta e a fatura a ser paga nas lojas(Ficha de compensacao). ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function ImpFatura()
Local   cIndex    := ""
Local   cChave    := ""
Private cAlias    := "SE1"                     
Private xMesFecDe := ddatabase //Ctod("  /  /  ")
Private xMesFecAt := ddatabase //Ctod("  /  /  ")
Private xCliDe    := Space(6)
Private xLojaDe   := Space(2)
Private xCliAt    := "ZZZZZZ"  //Space(6)
Private xLojaAt   := "ZZ"      //Space(2)
Private xTotal    := 0
Private xEncargo  := 0
Private xParcelado:= 0
Private xParc     := 0
Private nJuros    := 0
Private nEncargo  := 0
Private lRot      := IIf(Upper(Substr(Procname(2),15,13)) = "FATURA MENSAL",.T.,.F.)

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
  
Define Msdialog oDlg From 22,9 To 250,360 Title "Impressão da Fatura" Pixel

@ 015, 014 MsGet xCliDe		Picture "@!" F3 "SA1" 	Valid Empty(xCliDe)   .Or. T_ValidaCli(xCliDe) 	 	     Size 50, 11 Of oDlg Pixel  
@ 015, 076 MsGet xLojaDe	Picture "@!" 			Valid Empty(xLojaDe)  .Or. T_ValidaCli(xCliDe,xLojaDe)    Size 21, 11 Of oDlg Pixel
@ 045, 014 MsGet xCliAt		Picture "@!" F3 "SA1" 	Valid !Empty(xCliAt)  .Or. T_ValidaCli(xCliAt)			 Size 50, 11 Of oDlg Pixel  
@ 045, 076 MsGet xLojaAt	Picture "@!" 			Valid !Empty(xLojaAt) .Or. T_ValidaCli(xCliAt,xLojaAt)    Size 21, 11 Of oDlg Pixel
@ 075, 014 Msget xMesFecDe  Size 40, 11 Of oDlg Pixel
@ 075, 064 Msget xMesFecAt  Valid (xMesFecAt >= xMesFecDe) Size 40, 11 Of oDlg Pixel
                         	
@ 005, 014 SAY "Do Cliente" 	Size 50, 11 Object oCliDe  
oCliDe:oFont := oFont16b
@ 005, 076 SAY "Da Loja"  		Size 50, 11 Object oLojaDe
oLojaDe:oFont := oFont16b                                            
@ 035, 014 SAY "Ate Cliente"	Size 50, 11 Object oCliAte
oCliAte:oFont := oFont16b
@ 035, 076 SAY "Ate Loja"  	    Size 50, 11 Object oLojaAte
oLojaAte:oFont := oFont16b
@ 065, 014 SAY "Da Emissao"	    Size 50, 11 Object oEmisDe
oEmisDe:oFont := oFont16b
@ 065, 064 SAY "Ate Emissao"	Size 50, 11 Object oEmisAte
oEmisAte:oFont := oFont16b

Define Sbutton From 07, 125 Type 1 Action T_ImpFat() Enable Of oDlg
Define Sbutton From 25, 125 Type 2 Action oDlg:End() Enable Of oDlg

Activate Msdialog oDlg Centered  
                                                 
Return(.T.)
                      
//----------------------------------------------------------
/*/{Protheus.doc} ImpFat

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function ImpFat()
Local oPrint

oPrint := TMSPrinter():New() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objeto que controla o tipo de impressao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:SetPortrait()
oPrint:Setup()                 

DbSelectArea("SE1")
cIndex := CriaTrab(NIL,.F.)
cChave := "E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PARCELA+E1_STATUS+DTOS(E1_EMISSAO)"
IndRegua("SE1",cIndex,cChave,,T_Filtra(),"Selecionando registros...")
nIndex := RetIndex()
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
	Set Filter To
	dbGoTop()
	FErase(cIndex+OrdBagExt())     
	FreeUsedCode()
	Return()
EndIf                               

While !EOF()
    
	oPrint:StartPage()

	T_CabRelFat(oPrint)
	                
	T_DetRelFat(oPrint)
	
	T_RodRelFat(oPrint)    
	
	oPrint:EndPage()  
	
	DbSelectArea(cAlias)
	DbCloseArea()
	
	DbSelectArea("SE1")
	DbSkip()
	
EndDo

//Imprime em tela   
oPrint:Preview()                     

oDlg:End() 

//Spool de impressão
MS_FLUSH()
	 
//If lRot
	//dbSelectArea(cAlias)
	dbSelectArea("SE1")
	DbClearFilter()
	RetIndex(cAlias)
	If !Empty(cIndex)
		fErase(cIndex+OrdBagExt())
		cIndex := ""
	Endif
	DbSelectArea("SE1")
	dbSetOrder(1)
	dbSeek(xFilial())
//EndIf

	                                         
Return .T.      
      
//----------------------------------------------------------
/*/{Protheus.doc} CabRelFat

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function CabRelFat(oPrint) 
Local aArea	:= GetArea()

If File("\system\logo.BMP")
	oPrint:SayBitMap(180,090,"\system\logo.BMP",200,95)
Endif

oPrint:Say(180 ,900, "FATURA MENSAL"  , oFont20b, 100)

oPrint:Say(315 ,460, "CLIENTE" , oFont10b , 100)
oPrint:Line(335,030,335,440)  //Tracejado antes do cliente
oPrint:Line(335,030,375,030)    
SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
oPrint:Say(360 ,050, Alltrim(SA1->A1_NOME) , oFont14 , 100)
oPrint:Line(335,640,335,960)  //Tracejado depois do cliente  
oPrint:Line(335,960,375,960)  
       
oPrint:Say(315 ,1200, "NUMERO DO CARTÃO" , oFont10b , 100)       
oPrint:Line(335,1000,335,1180)  //Tracejado antes do cartao               
oPrint:Line(335,1000,375,1000)                        
oPrint:Say(360 ,1080, T_GetCartao(SE1->E1_CLIENTE,SE1->E1_LOJA) , oFont14 , 100)       
oPrint:Line(335,1615,335,1780)  //Tracejado depois do cartao
oPrint:Line(335,1780,375,1780) 
     
oPrint:Say(315 ,1978, "VENCIMENTO" , oFont10b , 100)       
oPrint:Line(335,1830,335,1960)  //Tracejado antes do vencimento
oPrint:Line(335,1830,375,1830)
oPrint:Say(360 ,1980, DTOC(SE1->E1_VENCREA) , oFont14 , 100)        
oPrint:Line(335,2225,335,2350)  //Tracejado depois do vencimento
oPrint:Line(335,2350,375,2350)     

oPrint:Say(435 ,138, "Data" , oFont09b , 100)       
oPrint:Line(455,030,455,120)  //Tracejado antes 
oPrint:Line(455,030,495,030)  
oPrint:Line(455,215,455,280)  //Tracejado depois
oPrint:Line(455,280,495,280)  

oPrint:Say(435 ,368, "Loja" , oFont09b , 100)       
oPrint:Line(455,320,455,350)  //Tracejado antes 
oPrint:Line(455,320,495,320)  
oPrint:Line(455,445,455,480)  //Tracejado depois
oPrint:Line(455,480,495,480)  

oPrint:Say(435 ,560, "Portador" , oFont09b , 100)       
oPrint:Line(455,520,455,550)  //Tracejado antes 
oPrint:Line(455,520,495,520)  
oPrint:Line(455,700,455,730)  //Tracejado depois
oPrint:Line(455,730,495,730)  

oPrint:Say(435 ,820, "Nº Operação" , oFont09b , 100)       
oPrint:Line(455,770, 455,800)  //Tracejado antes 
oPrint:Line(455,770, 495,770)  
oPrint:Line(455,1020,455,1050)  //Tracejado depois
oPrint:Line(455,1050,495,1050)  

oPrint:Say(435 ,1137, "Caixa" , oFont09b , 100)       
oPrint:Line(455,1090,455,1120)  //Tracejado antes 
oPrint:Line(455,1090,495,1090)  
oPrint:Line(455,1230,455,1260)  //Tracejado depois
oPrint:Line(455,1260,495,1260)  

oPrint:Say(435 ,1530, "Descrição" , oFont09b , 100)       
oPrint:Line(455,1300,455,1510)  //Tracejado antes 
oPrint:Line(455,1300,495,1300)  
oPrint:Line(455,1710,455,1890)  //Tracejado depois
oPrint:Line(455,1890,495,1890)                          

oPrint:Say(435 ,2080, "Valor R$" , oFont09b , 100)       
oPrint:Line(455,1920,455,2060)  //Tracejado antes 
oPrint:Line(455,1920,495,1920)  
oPrint:Line(455,2220,455,2350)  //Tracejado depois
oPrint:Line(455,2350,495,2350)  

RestArea(aArea)

Return

//----------------------------------------------------------
/*/{Protheus.doc} RodRelFat

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function RodRelFat(oPrint)
Local aArea		:= GetArea()                        
Local i

//1ª Linha
oPrint:Say(1400 ,140, "Encargos do Mês" , oFont09b , 100)       
oPrint:Line(1420,030,1420,120)  //Tracejado antes 
oPrint:Line(1420,030,1450,030)
oPrint:Say(1440 ,180, Transform(xEncargo,"@E 999,999,999.99") 		, oFont10 , 100)       
oPrint:Line(1420,420,1420,580)  //Tracejado depois

oPrint:Say(1400 ,600, "Encargos Máximos do Próximo Mês" , oFont09b , 100)       
oPrint:Line(1420,1170,1420,1200)  //Tracejado depois                                      
oPrint:Line(1420,1200,1450,1200)                                                          
oPrint:Say(1440 ,690, Transform(nJuros,"@E 999,999,999.99")			, oFont10 , 100)       
oPrint:Say(1400 ,1550, "TOTAL DA FATURA MENSAL" 					, oFont10b , 100)       
oPrint:Say(1400 ,2000, Transform(xTotal,"@E 999,999,999.99")	 	, oFont16b , 100)              

//2ª Linha

oPrint:Say(1500 ,200, "Pagamento Mínimo Rotativo" , oFont09b , 100)       
oPrint:Line(1520,030,1520,180)  //Tracejado antes 
oPrint:Line(1520,030,1550,030)                                                                   
oPrint:Say(1540 ,230, Transform(SE1->E1_PAGMIN,"@E 999,999,999.99")+" +" , oFont10 , 100)              
oPrint:Line(1520,645,1520,850)  //Tracejado depois                        
oPrint:Say(1535 ,720, "(+)" , oFont09b , 100)       
                                                    
oPrint:Say(1500 ,870, "Prestações Parcelado" , oFont09b , 100)       
oPrint:Line(1520,1210,1520,1455)  //Tracejado depois                                      
oPrint:Say(1540 ,890, Transform(xParc,"@E 999,999,999.99")+" +" , oFont10 , 100)              
oPrint:Say(1535 ,1300, "(=)" , oFont09b , 100) 

oPrint:Say(1500 ,1500, "Valor Mínimo a Pagar" , oFont09b , 100)       
oPrint:Line(1520,1885,1520,2350)  //Tracejado depois
oPrint:Line(1520,2350,1550,2350)                    
oPrint:Say(1540 ,1520, Transform(SE1->E1_PAGMIN+xParc,"@E 999,999,999.99")+" +" , oFont10 , 100)              
      
//3ª Linha

oPrint:Say(1600 ,140, "Limite de crédito" , oFont09b , 100)       
oPrint:Line(1620,030,1620,120)  //Tracejado antes 
oPrint:Line(1620,030,1650,030)                 
oPrint:Say(1640 ,150, Transform(SA1->A1_LC,"@E 999,999,999.99")+" +" , oFont10 , 100)              
oPrint:Line(1620,405,1620,600)  //Tracejado depois                        
oPrint:Say(1635 ,490, "(+)" , oFont09b , 100)       

oPrint:Say(1600 ,620, "Total desta Fatura" , oFont09b , 100)              
oPrint:Line(1620,895,1620,1000)  //Tracejado depois                        
oPrint:Say(1640 ,630, Transform(xTotal,"@E 999,999,999.99")+" +" , oFont10 , 100)              
oPrint:Say(1635 ,930, "(-)" , oFont09b , 100)       

oPrint:Say(1600 ,1020, "A Vencer Parcelado" , oFont09b , 100)              
oPrint:Line(1620,1325,1620,1770)  //Tracejado depois                        
oPrint:Say(1640 ,1030, Transform(xParcelado,"@E 999,999,999.99")+" +" , oFont10 , 100)              

oPrint:Say(1600 ,1790, "Disponível para compras em" , oFont09b , 100)                      
oPrint:Say(1640 ,1830, Transform(((SA1->A1_LC-xTotal)-xParcelado),"@E 999,999,999.99")+" +" , oFont10 , 100)              
oPrint:Line(1620,2230,1620,2350)  //Tracejado depois                                       
oPrint:Line(1620,2350,1650,2350)       

//4ª Linha

oPrint:Say(1700 ,140 , "Mensagens" , oFont09b , 100)       
oPrint:Line(1720,030 ,1720, 120)  //Tracejado antes
oPrint:Line(1720,030 ,2100, 030)
oPrint:Say(1800 ,050 , "SRS CLIENTES, EM CASO DE DÚVIDAS, SUGESTÕES OU RECLAMAÇÕES," , oFont12 , 100)       
oPrint:Say(1850 ,050 , "LIGUEM PARA: 0800 - 7022525 OU (0XX24) 3348 - 0214." 		 , oFont12 , 100)       
oPrint:Say(2010 ,050 , "SERVIÇO DE ATENDIMENTO AO CLIENTE   0800 - 702 2525"		 , oFont12 , 100)       
oPrint:Line(1720,360 ,1720,2350)  //Tracejado depois 
oPrint:Line(1720,2350,2100,2350) 
oPrint:Line(2100,030 ,2100,2350)     

oPrint:Say(2120 ,2030, "FICHA DO CLIENTE" 	, oFont10b , 100)                                                                 
oPrint:Say(2130 ,030, Replicate(".",235) 	, oFont10b , 100)  

oPrint:Say(2195 ,1270, Alltrim(SE1->E1_CC) 	, oFont16b , 100)       
oPrint:Say(2195 ,2000, T_Mudavalor(xTotal) , oFont16b 	, 100)       

If File("\SIGAADV\MODERNA.BMP")
	oPrint:SayBitMap(2180,050,"\SYSTEM\MODERNA.BMP",120,90)
Endif

For i:= 2275 To 2280
	oPrint:Line(i,030,i,2350)
Next i

oPrint:Say(2287 ,030 , "Local de Pagamento" , oFont08 , 100)                                                                      
oPrint:Say(2287 ,1870, "VENCIMENTO" 		, oFont08 , 100)                                                                             
oPrint:Say(2330 ,030 , "DROGARIA MODERNA"	, oFont10 , 100)                                                                      
oPrint:Say(2317 ,2090, Dtoc(SE1->E1_VENCREA), oFont10 , 100)        

oPrint:Line(2280,1850,3190,1850)  //PARALELO

oPrint:Line(2390,030 ,2390,2350)                                                                   
oPrint:Say(2397 ,030 , "Cedente" 													, oFont08 , 100)                                                                      
oPrint:Say(2447 ,030 , SM0->M0_NOMECOM + Space(10) + "CNPJ" + Space(5) + SM0->M0_CGC, oFont10 , 100)                                                                      
oPrint:Say(2397 ,1870, "Agência/Código Cedente" 									, oFont08 , 100)                                                                                                                                                                                            

oPrint:Line(2490,030 ,2490,2350)     
oPrint:Say(2497 ,030 , "Data Documento" 	, oFont08 , 100)
oPrint:Say(2537 ,060, Dtoc(ddatabase-1)		, oFont10 , 100)                                                                      
oPrint:Say(2497 ,400 , "Numero do Cartão" 	, oFont08 , 100)
oPrint:Say(2537 ,500 , Alltrim(SE1->E1_CC) 	, oFont10 , 100)       
oPrint:Say(2497 ,1470, "Data Processamento" , oFont08 , 100)
oPrint:Say(2537 ,1500, Dtoc(ddatabase) 		, oFont10 , 100)
oPrint:Say(2497 ,1870, "Nosso Numero" 		, oFont08 , 100)
oPrint:Line(2490,380 ,2590,380)   //PARALELO
oPrint:Line(2490,1450,2590,1450)  //PARALELO
oPrint:Line(2590,030 ,2590,2350)                                  
        
oPrint:Say(2620 ,050, "PREENCHA O CAMPO 'VALOR A PAGAR' COM O VALOR A SER PAGO." 	, oFont12 , 100)       
oPrint:Say(2670 ,050, "EVENTUAIS ENCARGOS/MULTAS POR ATRASO NO PAGAMENTO SERÃO" 	, oFont12 , 100)       
oPrint:Say(2720 ,050, "COBRADOS NO PRÓXIMO EXTRATO." 								, oFont12 , 100)       

oPrint:Line(2690,1850 ,2690,2350)                     
oPrint:Say(2597 ,1870, "Valor do Documento" , oFont08 , 100)
oPrint:Say(2637 ,2100, Transform(xTotal,"@E 999,999,999.99") , oFont10 , 100)

oPrint:Line(2790,1850 ,2790,2350)                           
oPrint:Say(2697 ,1870, "(-) Abatimento" , oFont08 , 100)

oPrint:Line(2890,1850 ,2890,2350)
oPrint:Say(2797 ,1870, "(-) Outras Deduções" , oFont08 , 100)

oPrint:Line(2990,1850 ,2990,2350)                            
oPrint:Say(2897 ,1870, "(+) Mora/Multa" , oFont08 , 100)
oPrint:Say(2937 ,2100, Transform(nJuros,"@E 999,999,999.99") , oFont10 , 100)

oPrint:Line(3090,1850 ,3090,2350)  
oPrint:Say(2997 ,1870, "(+) Outros Acréscimos" , oFont08 , 100)
                                                                
oPrint:Line(3190,030 ,3190,2350)             
oPrint:Say(3097 ,1870, "(=) VALOR A PAGAR" , oFont08 , 100)                                                      
oPrint:Say(3137 ,2100, Transform(xTotal,"@E 999,999,999.99") , oFont10 , 100)

oPrint:Say(3200 ,030 , "Cedente" , oFont08 , 100)                                                      
oPrint:Say(3230 ,030 , Alltrim(SA1->A1_NOME) , oFont10 , 100)                                                      
                                                                                                
RestArea(aArea)

Return
       
//----------------------------------------------------------
/*/{Protheus.doc} DetRelFat

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function DetRelFat(oPrint)
Local xLin            := 475        
Local xMes            := Dtos(Ctod("01/"+Substr(Dtoc(Ctod("01/"+Substr(Dtoc(xMesFecDe),4,5))-1),4,5)))      
Local xProd
Local xValProd        := 0 
Local aArea			  := GetArea()  
Local xFatura         := SE1->E1_NUM
Local xPrefixo        := SE1->E1_PREFIXO
Local xCliente        := SE1->E1_CLIENTE        
Local xLoja           := SE1->E1_LOJA
Local xMesAnt         := Ctod("01/"+Substr(Dtoc(xMesFecDe),4,5))
Local xFatAnt		  := {}
Local aDependente     := {}
Local nPosDep         := 0
Local ImpAnt          := .T.
Local i
Local nX 
Local nY

xTotal := 0

#IFDEF TOP
	cAlias := T_TitulosFatura(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_CLIENTE,SE1->E1_LOJA)
	DbSelectArea(cAlias)
#ELSE
	DbSelectArea("SE1") 
	DbSetOrder(17)                            
	DbGoTop()
	DbSeek(xFilial("SE1")+xMes+xCliente+xLoja,.T.)
#ENDIF

While !EOF()  
	If (cAlias)->E1_PREFIXO = GetMv("MV_PRFCART") //E1_FATURA = "NOTFAT"
		oPrint:Say(xLin ,110 , DtoC(StoD((cAlias)->E1_EMISSAO)) 	, oFont10 , 100)       		
		oPrint:Say(xLin ,375 , (cAlias)->E1_FILIAL  	   		 	, oFont10 , 100)       		
		oPrint:Say(xLin ,840 , (cAlias)->E1_NUM    	   		 		, oFont10 , 100)       				
		oPrint:Say(xLin ,1130, (cAlias)->E1_PORTADO 	   		 	, oFont10 , 100)       				
		oPrint:Say(xLin ,1330, "FATURA MES ANTERIOR" 				, oFont10 , 100)       				
		//oPrint:Say(xLin ,2120, Transform(SE1->E1_SLDDUPL+SE1->E1_JUROS+SE1->E1_VALMULT,"@E 999,999,999.99")+" +" , oFont10 , 100)       				
		nEncargo := (cAlias)->E1_JUROS
		
		oPrint:Say(xLin ,2120, Transform((cAlias)->E1_VALOR+(cAlias)->E1_JUROS+(cAlias)->E1_VALMULT,"@E 999,999,999.99") , oFont10 , 100)       				
		oPrint:Say(xLin ,2290, "+", oFont10 , 100)       				
		
		//xTotal += SE1->E1_SLDDUPL+SE1->E1_JUROS+SE1->E1_VALMULT
		xTotal += (cAlias)->E1_VALOR+(cAlias)->E1_JUROS+(cAlias)->E1_VALMULT
		xLin   += 80        
		ImpAnt := .F. 
		DbSkip()
	EndIf
    
    If !EOF()       
   	    If !Empty((cAlias)->E1_CODDEP)
	   	    nPosDep := Ascan(aDependente, {|x| x[1] = (cAlias)->E1_CODDEP })
	   	    If nPosDep = 0
	   	    	Aadd(aDependente,{(cAlias)->E1_CODDEP})
	   	    	nPosDep := Ascan(aDependente, {|x| x[1] = (cAlias)->E1_CODDEP })
	   	    	Aadd(aDependente[nPosDep],{DtoC(StoD((cAlias)->E1_EMISSAO)),(cAlias)->E1_FILIAL,(cAlias)->E1_NUM,(cAlias)->E1_PORTADO,(cAlias)->E1_VALOR })
	   	    Else
	   	    	Aadd(aDependente[nPosDep],{DtoC(StoD((cAlias)->E1_EMISSAO)),(cAlias)->E1_FILIAL,(cAlias)->E1_NUM,(cAlias)->E1_PORTADO,(cAlias)->E1_VALOR })	
	   	    EndIf
   	    Else
			oPrint:Say(xLin ,110 , DtoC(StoD((cAlias)->E1_EMISSAO)) , oFont10 , 100)       		
			oPrint:Say(xLin ,375 , (cAlias)->E1_FILIAL  	   		, oFont10 , 100)       		
			oPrint:Say(xLin ,590 , "POR"    	   					, oFont10 , 100)       		
			oPrint:Say(xLin ,840 , (cAlias)->E1_NUM    	   			, oFont10 , 100)       				
			oPrint:Say(xLin ,1130, (cAlias)->E1_PORTADO 	   		, oFont10 , 100)       				
			oPrint:Say(xLin ,1330, "COMPRA NO ROTATIVO" 			, oFont10 , 100)       				
			oPrint:Say(xLin ,2120, Transform((cAlias)->E1_VALOR,"@E 999,999,999.99") , oFont10 , 100)       				
			oPrint:Say(xLin ,2290, "+", oFont10 , 100)       				
			xTotal += (cAlias)->E1_VALOR
			//xParcelado += BuscaParcelas(SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_PREFIXO,SE1->E1_NUM)
			xLin+=40            
	    EndIf
		DbSkip()
	EndIf
EndDo                           

For nX:=1 To Len(aDependente)  

	For nY:=1 To Len(aDependente[nX])
	    
		If nY = 1
			xLin+=40                  
			//oPrint:Say(xLin ,110 ,"DEPENDENTE:"+Space(10)+Posicione("MAC",1,xFilial("MAC")+SE1->E1_CLIENTE+SE1->E1_LOJA+aDependente[nX][nY],"	MAC_DEPNOM")	, oFont10 , 100)       		
			oPrint:Say(xLin ,110 ,"DEPENDENTE:"+Space(10)+Posicione("MAC",,xFilial("MAC")+SE1->E1_CLIENTE+SE1->E1_LOJA+aDependente[nX][nY],"	MAC_DEPNOM","MACDRO1")	, oFont10 , 100)       					
			xLin+=40 
	  	Else
			oPrint:Say(xLin ,110 , aDependente[nX][nY][1]	, oFont10 , 100)       		
			oPrint:Say(xLin ,375 , aDependente[nX][nY][2]	, oFont10 , 100)       		
			oPrint:Say(xLin ,590 , "POR"    	   			, oFont10 , 100)       		
			oPrint:Say(xLin ,840 , aDependente[nX][nY][3]	, oFont10 , 100)       				
			oPrint:Say(xLin ,1130, aDependente[nX][nY][4]	, oFont10 , 100)       				
			oPrint:Say(xLin ,1330, "COMPRA NO ROTATIVO" 	, oFont10 , 100)       				
			oPrint:Say(xLin ,2120, Transform(aDependente[nX][nY][5],"@E 999,999,999.99") 	, oFont10 , 100)       				
			oPrint:Say(xLin ,2290, "+", oFont10 , 100)       				
			xTotal += aDependente[nX][nY][5]
			xLin+=40            		
		EndIf
	Next nY
Next nX

RestArea(aArea)                     

xLin+=40            		
        
For i:=1 To 100 
	
	xProd    := &("SE1->E1_PROD"+Alltrim(Str(i)))        
	xValProd := &("SE1->E1_VALPRO"+Alltrim(Str(i)))
	i := Iif(Empty(xProd),100,i)
	If !Empty(xProd)
		SB1->(DbSeek(xFilial("SB1")+xProd))   
		oPrint:Say(xLin ,1330, Alltrim(SB1->B1_DESC) , oFont10 , 100)       						
		oPrint:Say(xLin ,2120, Transform(xValProd,"@E 999,999,999.99"), oFont10 , 100)       						
		oPrint:Say(xLin ,2290, "+", oFont10 , 100)       				
		xTotal += xValProd
		xLin+=40
		xProd    := Space(1)
		xValProd := 0
	Endif
	
Next i

If !Empty(SE1->E1_TXADM)                                                  
	oPrint:Say(xLin ,1330, "TAXA ADMINISTRATIVA" , oFont10 , 100)       						
	oPrint:Say(xLin ,2120, Transform(SE1->E1_TXADM,"@E 999,999,999.99"), oFont10 , 100)       						
	oPrint:Say(xLin ,2290, "+", oFont10 , 100)       				
	xTotal += SE1->E1_TXADM
	xLin+=40
EndIf   

If !Empty(SE1->E1_JUROS)
	oPrint:Say(xLin ,1330, "JUROS FATURA" , oFont10 , 100)       						
	oPrint:Say(xLin ,2120, Transform(SE1->E1_JUROS,"@E 999,999,999.99"), oFont10 , 100)       						
	oPrint:Say(xLin ,2290, "+", oFont10 , 100)       				
	xTotal += SE1->E1_JUROS
	nJuros := SE1->E1_JUROS
	xLin+=40	
EndIf

DbSelectArea("LFX")
DbSetOrder(1)
DbGoTop()
If DbSeek(xFilial("LFX")+SA1->A1_CONFIG)
	xEncargo := LFX->LFX_MULTA + LFX->LFX_JUROS
EndIf                    

Return 

//----------------------------------------------------------
/*/{Protheus.doc} Filtra

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function Filtra()
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ValidaCli  | Autor ³ Pedro Tostes          ³ Data ³ 08.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se o cliente informado nos parametros e valido        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function ValidaCli(cCli280,cLoja280)                                                                       
Local cAlias := Alias()
Local nOldRec
Local lRet	 := .T.

cLoja280:=Iif(cLoja280 == Nil,"",cLoja280)

If Empty(cCli280)
	lRet := .F.
Endif

If lRet
	dbSelectArea("SA1")
	dbSetOrder(1)
	nOldRec := Recno()
	
	IF !(dbSeek(cFilial+cCli280+cLoja280))
		/* Se nÆo encontrou o registro, retorna para o registro salvo pois, se a busca 
		estiver ocorrendo para o cliente a faturar e nÆo for encontrado, o SA1 fi - 
		car  desposicionado.														*/
		dbGoTo(nOldRec)
		Help(" ",1,"A280CLI")
		lRet := .F.
	EndIf
	
	If lRet
		dbSelectArea(cAlias)
	EndIf
EndIf

Return lRet

/*
Static Function BuscaParcelas(cPar1,cPar2,cPar3,cPar4)
           
Local aArea    := GetArea()  
Local aE1Area  := SE1->(GetArea())
Local nTotParc := 0

DbSelectArea("SE1")
DbSetOrder(2)
DbGoTop()
DbSeek(xFilial("SE1")+cPar1+cPar2+cPar3+cPar4)
While !EOF() .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM = xFilial("SE1")+cPar1+cPar2+cPar3+cPar4
	If SE1->E1_STATUS = "A"
		nTotParc += SE1->E1_VALOR
	EndIf
	DbSkip()
EndDo
             
RestArea(aE1Area)
RestArea(aArea)

Return(nTotParc)
*/
//----------------------------------------------------------
/*/{Protheus.doc} TitulosFatura

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function TitulosFatura(cPrefixo,cFatura,cCliente,cLoja)

Local cE1Query   
Local cAlias := "SE1QRY"
              
cE1Query := "SELECT *"
cE1Query += " FROM "+RetSqlName("SE1")+" SE1"
cE1Query += " WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND"
cE1Query += " SE1.E1_CLIENTE = '"+cCliente+"' AND"
cE1Query += " SE1.E1_LOJA = '"+cLoja+"' AND"      
cE1Query += " SE1.E1_FATPREF = '"+cPrefixo+"' AND"      
cE1Query += " SE1.E1_FATURA = '"+cFatura+"' AND"      
cE1Query += " SE1.D_E_L_E_T_= ' ' "
cE1Query += " ORDER BY E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_VENCTO,E1_PARCELA,E1_EMISSAO"

cE1Query := ChangeQuery(cE1Query)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cE1Query),cAlias,.F.,.T.)

Return cAlias             

//----------------------------------------------------------
/*/{Protheus.doc} GetCartao

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function GetCartao(cCliente,cLoja)
       
Local cCartao  := Space(0)                  
Local aArea    := GetArea()
Local aMA6Area := MA6->(GetArea())       

DbSelectArea("MA6")
DbSetOrder(2)
DbGoTop()                                
If DbSeek(xFilial("MA6")+cCliente+cLoja)
	cCartao := MA6_NUM
EndIf

RestArea(aMA6Area)
RestArea(aArea)   

Return cCartao

//----------------------------------------------------------
/*/{Protheus.doc} MudaValor

@owner  	Varejo
@version 	V12
/*/
//----------------------------------------------------------
Template Function Mudavalor(xTotal)
Local nValor := 0   
Local nInt   := 0
Local nDec   := 0

nInt := Int(xTotal)
nDec := ((xTotal - nInt) * 100)
nValor := Alltrim(Str(nInt))+Alltrim(StrZero(nDec,2))

Return nValor