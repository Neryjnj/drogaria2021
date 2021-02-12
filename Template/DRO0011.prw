#INCLUDE 'TOTVS.CH'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicao de variavel em objetoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
 
#XTRANSLATE bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

Static lUsaBaseTop := UsaBaseTop()

//ฺฤฤฤฤฤฤฤฟ
//ณDEFINESณ
//ภฤฤฤฤฤฤฤู
//OPERADORES
#DEFINE OPE_AND 	If(lUsaBaseTop, " AND "," .AND. ")
#DEFINE OPE_OR  	If(lUsaBaseTop, " OR " ," .OR. ")
#DEFINE OPE_IGUAL	If(lUsaBaseTop, " = "  ," == ")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNumero de caracteres dos operadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE TAM_AND  	Len(OPE_AND)
#DEFINE TAM_OR  	Len(OPE_OR)
#DEFINE TAM_IGUAL	Len(OPE_IGUAL)

//ฺฤฤฤฤฤฤฟ
//ณCamposณ
//ภฤฤฤฤฤฤู
#DEFINE	 CAMPO_B1_CODFAB  If(lUsaBaseTop,"SB1.B1_CODFAB" ,"B1_CODFAB") 
#DEFINE	 CAMPO_B1_LOJA    If(lUsaBaseTop,"SB1.B1_LOJA"   ,"B1_LOJA")
#DEFINE	 CAMPO_B1_CODAPRE If(lUsaBaseTop,"SB1.B1_CODAPRE","B1_CODAPRE")
#DEFINE	 CAMPO_B1_CODCOTL If(lUsaBaseTop,"SB1.B1_CODCOTL","B1_CODCOTL")
#DEFINE CAMPO_B1_CODPRIN If(lUsaBaseTop,"SB1.B1_CODPRIN","B1_CODPRIN")
#DEFINE CAMPO_B1_GENERIC If(lUsaBaseTop,"SB1.B1_GENERIC","B1_GENERIC")
#DEFINE CAMPO_B1_ALTERNA If(lUsaBaseTop,"SB1.B1_ALTERNA","B1_ALTERNA")

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณDROCENTRALบAutor  ณVendas Clientes     บ Data ณ 23/01/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de filtro para a CENTRLA DE COMPRAS                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function DRO0011()
//ณObjeto para a criacao da tela principal
Local oDlg

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametros Devolvidos pela funcao  LocxGrid()         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ1. aRet	-	Array contendo 6 arrays como descrito abaixo:												ณ
//ณ				[1] = Array com o aHeader                                                                   ณ
//ณ				[2] = Array contendo somente campos validos dos que foram passados                          ณ
//ณ				[3] = Array contendo Titulo dos campos validos                                              ณ
//ณ				[4] = Array contendo Tamanho dos campos validos												ณ
//ณ				[5] = Array co o conteudo das linhas (aCols)                                                ณ
//ณ				[6] = Array contendo os Recnos referentes a cada linha                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPrincipio ativoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cSeekMHA    := '"' + xFilial("MHA") + '"'
Local cWhileMHA   := "!EOF() .AND. MHA_FILIAL == " + cSeekMHA
Local aPAtivo     := LocxGrid("MHA",cWhileMHA,,.T.,".F.",cSeekMHA,1,{"MHA_CODIGO","MHA_PATIVO"},)  
Local aTitPAtivo  := AClone(aPAtivo[3])
Local aContPAtivo := AClone(aPAtivo[5])
Local aTamCPAtivo := AClone(aPAtivo[4])
Local aHdrPAtivo  := AClone(aPAtivo[1]) 
Local oMarkPAtivo
Local lMarkPAtivo := .F.  
Local oPAtTWBrose   := NIL
Local oPAtTCheckBox := NIL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApresentacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู
Local cSeekMHB  := '"' + xFilial("MHB") + '"'
Local cWhiMHBEL := "!EOF() .AND. MHB_FILIAL == " + cSeekMHB
Local aApre     := LocxGrid("MHB",cWhiMHBEL,,.T.,".F.",cSeekMHB,1,{"MHB_CODAPR","MHB_APRESE"},)  
Local aTitApre  := AClone(aApre[3])
Local aContApre := AClone(aApre[5])
Local aTamCApre := AClone(aApre[4])
Local aHdrApre  := AClone(aApre[1])  
Local oMarkApre
Local lMarkApre := .F.  
Local oAprTWBrose   := NIL
Local oAprTCheckBox := NIL      


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFabricante  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู
Local cSeekSA2    := '"' + xFilial("SA2") + '"'
Local cWhileSA2   := "!EOF() .And. A2_FILIAL == " + cSeekSA2
Local aFabric     := LocxGrid("SA2",cWhileSA2,'A2_FABRICA=="S"',.T.,".F.",cSeekSA2,2,{"A2_COD","A2_LOJA","A2_NOME"},)  //Fabricantes
Local aTitFabric  := AClone(aFabric[3])
Local aContFabric := AClone(aFabric[5])
Local aTamCFabric := AClone(aFabric[4])
Local aHdrFabric  := AClone(aFabric[1])
Local oMarkFabric
Local lMarkFabric := .F. 
Local oFabTWBrose   := NIL
Local oFabTCheckBox := NIL      


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณControle    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู
Local cSeekLEO      := '"' + xFilial("LEO") + '"'
Local cWhiMHBEO     := "!EOF() .And. LEO_FILIAL == " + cSeekLEO
Local aControle     := LocxGrid("LEO",cWhiMHBEO,,.T.,".F.",cSeekLEO,2,{"LEO_CODCON","LEO_CONDES"},)  //Controles
Local aTitControle  := AClone(aControle[3])
Local aContControle := AClone(aControle[5])
Local aTamCControle := AClone(aControle[4])
Local aHdrControle  := AClone(aControle[1])
Local oMarkControle
Local lMarkControle := .F.  
Local oContTWBrose   := NIL
Local oContTCheckBox := NIL      


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTexto para os CheckBoxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cTexto1		:= "Marcar Todos"						//Texto para check BOX

Local aRadOpcGen 	:= {}	//Array contendo tipo para o objeto radio para medicamento generico		
Local oGenTRadMenu	:= NIL
Local oGenRMenu  	:= NIL

Local aRadOpcAlt 	:=	{}	//Array contendo tipo para o objeto radio para medicamento alternativo
Local oAltTRadMenu	:= NIL
Local oAltRMenu		:= NIL

Local oCompTela	    := DroCCompTela():CompTela()		//Localizado no fonte DRO005	
Local oParTGroup    := NIL

Local lRet		 	 := .F.  
Local cWhereFab  	 := ""	//Clausula WHERE criada a partir da selecao dos fabricantes
Local cWhereApre     := ""	//Clausula WHERE criada a partir da selecao das apresentacoes
Local cWhereControle := ""	//Clausula WHERE criada a partir da selecao dos controles
Local cWherePAtivo 	 := ""	//Clausula WHERE criada a partir da selecao dos princios ativo
Local cWhereGen 	 := "" 	//Clausula WHERE criada a partir da selecao do Medicamento Generico
Local cWhereAlt 	 := ""	//Clausula WHERE criada a partir da selecao do Medicamento Altenativo
Local cWhere	 	 := ""	//Clausula WHERE criada a partir da selecao dos registro	

Private oListPAtivo
Private oListApre
Private oListFabric
Private oListControle

Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tela da Central de Compras                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg TITLE "Central de Compras" FROM 1,1 TO 35,100

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBox - Fabricante  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oParTGroup := DROCParTGroup():ParTGroup( 005				, 005 , 089, 190,;
									     " Fabricantes     ", oDlg)	//Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)


oFabTWBrose := DROCParTWBrowse():ParTWBrose(	014        , 010          , 170       , 60			,;
							   			    	oDlg       , 'oListFabric', aHdrFabric, aTitFabric	,;
										   		aTamCFabric, aContFabric ) //Metodo CONSTRUTOR - DRO007.prw
oListFabric := oCompTela:CompTWBrose(oFabTWBrose)									     											


oFabTCheckBox := DROCParTCheckBox():ParTCheckBox( 076	  , 135 , oDlg, @lMarkFabric,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw

oMarkFabric := oCompTela:CompTCheckBox(oFabTCheckBox)	

oMarkFabric:bLClicked := {|| aEval( oFabTWBrose:aConteudo , { |x,y| oFabTWBrose:aConteudo[y,1] := If(oFabTCheckBox:lMarcado ,1,-1)}) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBox - Apresentacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oParTGroup := DROCParTGroup():ParTGroup( 092				, 005 , 176, 190,;
									     " Apresenta็ใo    ", oDlg) //Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)									     


oAprTWBrose := DROCParTWBrowse():ParTWBrose(	101        , 010          , 170     , 60		,;
							   			    oDlg       , 'oListApre'  , aHdrApre, aTitApre	,;
											aTamCApre  , aContApre ) //Metodo CONSTRUTOR - DRO007.prw 
oListApre := oCompTela:CompTWBrose(oAprTWBrose)									     											


oAprTCheckBox := DROCParTCheckBox():ParTCheckBox( 163	  , 135 , oDlg, @lMarkApre,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw

oMarkApre := oCompTela:CompTCheckBox(oAprTCheckBox)	
oMarkApre:bLClicked := {|| aEval( oAprTWBrose:aConteudo , { |x,y| oAprTWBrose:aConteudo[y,1] := If(oAprTCheckBox:lMarcado ,1,-1)}) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBox - Controle    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oParTGroup := DROCParTGroup():ParTGroup( 005				, 200 , 089, 385,;
									     " Controles       ", oDlg) //Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)									     


oContTWBrose := DROCParTWBrowse():ParTWBrose(	014        , 205          , 170     , 60		,;
							   			    oDlg       , 'oListControle'  , aHdrControle, aTitControle	,;
											aTamCControle  , aContControle ) //Metodo CONSTRUTOR - DRO007.prw  
oListControle := oCompTela:CompTWBrose(oContTWBrose)									     											


oContTCheckBox := DROCParTCheckBox():ParTCheckBox( 76	  , 330 , oDlg, @lMarkControle,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw

oMarkApre := oCompTela:CompTCheckBox(oContTCheckBox)	
oMarkApre:bLClicked := {|| aEval( oContTWBrose:aConteudo , { |x,y| oContTWBrose:aConteudo[y,1] := If(oContTCheckBox:lMarcado ,1,-1)}) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBox - Principio Ativoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oParTGroup := DROCParTGroup():ParTGroup( 092				, 200 , 176, 385,;
									     " Princํpio Ativo ", oDlg) //Metodo CONSTRUTOR - DRO006.prw
oCompTela:CompTGroup(oParTGroup)									     


oPAtTWBrose := DROCParTWBrowse():ParTWBrose(	101        , 205          , 170     , 60		,;
							   			    oDlg       , 'oListPAtivo'  , aHdrPAtivo, aTitPAtivo	,;
											aTamCPAtivo  , aContPAtivo ) //Metodo CONSTRUTOR - DRO007.prw   
oListPAtivo := oCompTela:CompTWBrose(oPAtTWBrose)									     											


oPAtTCheckBox := DROCParTCheckBox():ParTCheckBox( 163	  , 330 , oDlg, lMarkPAtivo,;
												   cTexto1, 50) //Metodo CONSTRUTOR - DRO008.prw  

oMarkPAtivo := oCompTela:CompTCheckBox(oPAtTCheckBox)	
oMarkPAtivo:bLClicked := {|| aEval( oPAtTWBrose:aConteudo , { |x,y| oPAtTWBrose:aConteudo[y,1] := If(oPAtTCheckBox:lMarcado ,1,-1)}) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRadio - Medicamento Genericoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oParTGroup := DROCParTGroup():ParTGroup( 180					 , 005 , 220, 190,;
								   		  " Medicamento Gen้rico", oDlg) //Metodo CONSTRUTOR - DRO006.prw  
oCompTela:CompTGroup(oParTGroup)

aRadOpcGen 	 := {"Sim", "Nใo", "Todos"}
oGenTRadMenu := DROCParTRadMenu():ParTRadMenu(188    , 010, oDlg, aRadOpcGen,;
							   			      1) //Metodo CONSTRUTOR - DRO009.prw  
						   			      
oCompTela:CompTRadMenu(oGenTRadMenu)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRadio - Medicamento Alternativoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
oParTGroup := DROCParTGroup():ParTGroup( 180						, 200 , 220, 385,;
								   		  " Medicamento Alternativo", oDlg) //Metodo CONSTRUTOR - DRO006.prw  
oCompTela:CompTGroup(oParTGroup)


aRadOpcAlt := {"Sim", "Nใo", "Todos"}
oAltTRadMenu := DROCParTRadMenu():ParTRadMenu(188    , 205, oDlg, aRadOpcAlt,;
                                              1) //Metodo CONSTRUTOR - DRO009.prw  
oCompTela:CompTRadMenu(oAltTRadMenu)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotoes de Confirma / Cancelaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE SBUTTON FROM 233,325 TYPE 1 ACTION (lRet := .T., oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 233,355 TYPE 2 ACTION (lRet := .F., oDlg:End()) ENABLE OF oDlg


ACTIVATE MSDIALOG oDlg CENTER

If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฟ
	//ณFabricanteณ
	//ภฤฤฤฤฤฤฤฤฤฤู
	cWhereFab := CompWhere(oFabTWBrose:aConteudo, 1)	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApresentacaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤู
	cWhereApre := CompWhere(oAprTWBrose:aConteudo, 2)	
	
	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณControlesณ
	//ภฤฤฤฤฤฤฤฤฤู
	cWhereControle := CompWhere(oContTWBrose:aConteudo, 3)	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPrincipio Ativoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cWherePAtivo := CompWhere(oPAtTWBrose:aConteudo, 4) 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMedicamento Genericoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cWhereGen := CompWhere(NIL, 5, oGenTRadMenu:nOpcoes) 		   
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMedicamento Alternativoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cWhereAlt := CompWhere(NIL, 6, oAltTRadMenu:nOpcoes) 		   
		
	cWhere := If(cWhereFab 		<> "()", cWhereFab		+ OPE_AND,"")+;
	          If(cWhereApre 	<> "()", cWhereApre	  	+ OPE_AND,"")+;
	          If(cWhereControle <> "()", cWhereControle	+ OPE_AND,"")+;
	          If(cWherePAtivo 	<> "()", cWherePAtivo	+ OPE_AND,"")+;
	          If(cWhereGen 		<> "()", cWhereGen		+ OPE_AND,"")+;
	          If(cWhereAlt 		<> "()", cWhereAlt		+ OPE_AND,"")

	If cWhere <> ""
		cWhere := Left(cWhere, Len(cWhere) - TAM_AND)
	Else
		cWhere := "()"
	Endif
Else
	cWhere := "()"
Endif 

Return (cWhere)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCompWhere บAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Criacao da clausula WHERE baseado nas opcoes marcadas na   บฑฑ
ฑฑบ          ณ tela de parametros da Central de Compras                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1 - Array contendo informacoes de filtro               บฑฑ
ฑฑบ          ณ ExpN2 - Tipo de filtro a ser trabalhado                    บฑฑ
ฑฑบ          ณ         nTipo = 1 (Fabricante)                             บฑฑ
ฑฑบ          ณ         nTipo = 2 (Apresentacao)                           บฑฑ
ฑฑบ          ณ         nTipo = 3 (Controles)                              บฑฑ
ฑฑบ          ณ         nTipo = 4 (Principio Ativo)                        บฑฑ
ฑฑบ          ณ         nTipo = 5 (Medicamento Generico)                   บฑฑ
ฑฑบ          ณ         nTipo = 6 (Medicamento Alternativo)                บฑฑ
ฑฑบ          ณ ExpN3 - Opcao escolhida para Medicamento Generico e        บฑฑ
ฑฑบ          ณ         Medicamento Alternativo                            บฑฑ
ฑฑบ          ณ         nOpcRadio = 1 (Filtrar Medicamentos Generico/Alter บฑฑ
ฑฑบ          ณ         nOpcRadio = 2 (Nao Filtrar Medicamento Genric/Alterบฑฑ
ฑฑบ          ณ         nOpcRadio = 3 Desconsiderar filtro para este campo บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpC1 - Clausula WHERE montadacoes de filtro               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CompWhere(aArray, nTipo, nOpcRadio)
Local cWhere 		:= ""		// Clausula WHERE a ser montada de acordo com o preenchimento da tela Central de Compras 
Local aContAux  	:= {}		// Array auxiliar para armazenar os registros marcados
Local nTamAContAux	:= 0		// Tamanho do array aContAux	
Local nFor      	:= 0		// Controle de loop	

DEFAULT aArray 		:= {} 
DEFAULT nTipo  		:= 0  
DEFAULT nOpcRadio  	:= 0  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a funcao esta sendo chamada a partir de     ณ
//ณMedicamento Generico (5) ou Medicamento Alternartivo (6)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nTipo <> 5 .AND. nTipo <> 6)
	AEval(aArray, {|x| If(x[1]==1,AtuArray(nTipo, @aContAux, x[2], x[3]),NIL)})
	nTamAContAux := Len(aContAux)
    cWhere := "("
	If nTamAContAux > 0
		For nFor := 1 to nTamAContAux
			If nTipo == 1		//Fabricante
				cWhere += CAMPO_B1_CODFAB + OPE_IGUAL + "'" + aContAux[nFor][1] + "'" + OPE_AND
				cWhere += CAMPO_B1_LOJA   + OPE_IGUAL + "'" + aContAux[nFor][2] + "'" 
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif	
			ElseIf nTipo == 2	//Apresentacao
				cWhere += CAMPO_B1_CODAPRE + OPE_IGUAL + "'" + aContAux[nFor][1] + "'"
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif					
			ElseIf nTipo == 3	//Controles
				cWhere += CAMPO_B1_CODCOTL + OPE_IGUAL + "'" + aContAux[nFor][1] + "'"
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif					
			ElseIf nTipo == 4	//Principio Ativo
				cWhere += CAMPO_B1_CODPRIN +  OPE_IGUAL + "'" + aContAux[nFor][1] + "'"
				If(nFor <> nTamAContAux) 
					cWhere += OPE_OR
				Endif					
			Endif
		Next nFor
	Endif	
	cWhere += ")" 	
Else
	cWhere := "("
	If nTipo == 5	//Medicamento Generico
		If nOpcRadio == 1 	//Opcao SIM selecionada  
			cWhere += CAMPO_B1_GENERIC + OPE_IGUAL + "'S'" 
		ElseIf nOpcRadio == 2 //Opcao NAO selecionada
			cWhere += CAMPO_B1_GENERIC + OPE_IGUAL + "'N'" 
		Endif
	ElseIf nTipo == 6	//Medicamento Alternativo
		If nOpcRadio == 1 	//Opcao SIM selecionada  
			cWhere += CAMPO_B1_ALTERNA + OPE_IGUAL + "'1'" 
		ElseIf nOpcRadio == 2 //Opcao NAO selecionada
			cWhere += CAMPO_B1_ALTERNA + OPE_IGUAL + "'2'" 
		Endif	
	Endif
	cWhere += ")"	
EndIf

Return (cWhere)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuArray  บAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche o array com os registros selecionados             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - Tipo de filtro a ser trabalhado                    บฑฑ
ฑฑบ          ณ         nTipo = 1 (Fabricante)                             บฑฑ
ฑฑบ          ณ         nTipo = 2 (Apresentacao)                           บฑฑ
ฑฑบ          ณ         nTipo = 3 (Controles)                              บฑฑ
ฑฑบ          ณ         nTipo = 4 (Principio Ativo)                        บฑฑ
ฑฑบ          ณ ExpA2 - Array que ira' armazenar os registros selecionados บฑฑ
ฑฑบ          ณ ExpC3 - Codigo                                             บฑฑ
ฑฑบ          ณ ExpC4 - Loja (somente p/ filtro dos Fabricantes)           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TEMPLATE - DROGARIA                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuArray(nTipo, aContAux, cCod, cLoj )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณnTipo = 1 (Fabricante), significa que devera armazenarณ
//ณCODIGO DO FABRICANTE + LOJA                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo == 1 
	aAdd(aContAux,{cCod,cLoj})
Else
	aAdd(aContAux,{cCod})
Endif

Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUsaBaseTopบAutor  ณVendas Clientes     บ Data ณ 21/01/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica qual a base de dados e' utilizada, TOP ou DBF      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL1  - Usa ou nao a base TOP                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTEMPLATE - DROGARIA (Central de Compras)                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function UsaBaseTop()
Local lUsaTOP := .F.		//Verifica se utiliza TOP

#IFDEF TOP 
	If TcSrvType() <> "AS/400"
		lUsaTOP := .T.
	EndIf
#ENDIF	

Return (lUsaTOP)