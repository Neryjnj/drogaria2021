#Include "Protheus.ch"
#Include "Fina280.ch"
#Include "Rwmake.ch"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥FechaMes  ≥ Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao para realizar o fechamento das compras do cliente.   ≥±±
±±≥          ≥Esta funcao aglutina todas as compras em uma unica fatura.  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao Efetuada                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥          ≥               ≥                                            ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Template Function Fechames()
 
Private aRotina 	:= MenuDef()
Private cCadastro 	:= "Fechamento do Cart„o"
Private _nSldTit  	:= 0
Private aAreaE1		:= {}
Private aProxArea 	:= {}

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

DbSelectArea("SE1")
MBrowse(6,1,22,75,"SE1",,"!E1_SALDO")

Return

/*⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunÁ„o    ≥ MenuDef  ≥ Autor ≥ Conrado Q. Gomes      ≥ Data ≥ 11.12.06 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ DefiniÁ„o do aRotina (Menu funcional)                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ MenuDef()                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Template Drograria                                         ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function MenuDef()
Local aRotina := {	{ "Pesquisar"      ,"AxPesqui"      ,0	,1	,0	,.F.	}	,;
					{ "Visualizar"     ,"FA280Visua"    ,0	,2	,0	,.T.	}	,;
					{ "Fechar cart„o"  ,"T_Fechacart"   ,0	,3	,0	,.T.	}	,;
					{ "Cancela Fatura" ,"T_Cancelacart" ,0	,6	,0	,.T.	}	,;
					{ "Fatura Mensal"  ,"T_ImpFatura"   ,0	,2	,0	,.T.	}	,;
					{ "Extrato Compra" ,"T_ImpExtrato"  ,0	,2	,0	,.T.	}	,;
					{ "Legenda"        ,"T_Legenda"     ,0	,2	,0	,.T.	}	}
Return aRotina

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥FechaCart | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Esta funcao realiza a montagem da tela com o usuario        ≥±±
±±≥          ≥alem de preparar a base para o processamento do cartao      ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Template Function Fechacart()

Local cIndex		:= Space(0)
Local cChave    	:= Space(0)
Local nOpca 		:= 0
Private cCliAnt 	:= Space(0)
Private lRetCli     := .F.
Private lFimArq 	:= .F.
Private oDlg
Private cPrefix 	:= SuperGetMv("MV_PRFCART")
Private cNat    	:= SuperGetMv("MV_CARTNAT")
Private cTipo		:= "FI"
Private cAlias  	:= "SE1"
Private aTam    	:= {}
Private cFech   	:= Space(6)
Private cFechAnt	:= Space(6)
Private cCliDe  	:= Space(6)
Private cLojaDe 	:= Space(2)
Private cCLiAte 	:= Space(6)
Private cLojaAte	:= Space(2)
Private nValDup 	:= 0
Private nVARURV	 	:= 0
Private dDTFecDe 	:= ddatabase
Private dDTFecAt 	:= ddatabase
Private dDTVencDe 	:= Ctod("  /  /  ")
Private dDTVencAt 	:= Ctod("  /  /  ")
Private cCliFat   	:= Space(8)
Private nDiaAtras 	:= 0
Private aClits    	:= {}
Private lRegImp     := .F.
Private dPerfer     := Ctod("  /  /  ")
Private lQuery      := .F.
Private lProcessa   := .F.
Private cQuery      := ""

SomaAbat("","","","R")

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica se data do movimento nao e menor que data limite de ≥
//≥ movimentacao no financeiro    					             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !DtMovFin()
	Return
Endif

LoteCont("FIN")

DbSelectArea("SX3")
DbSetOrder(2)
DbGotop()
DbSeek("E1_PREFIXO")

cPictPref  := Alltrim(X3_PICTURE)

aTam     := TamSx3("E1_NUM")
cFech	 := Soma1(SuperGetMv("MV_CARTNUM"),aTam[1])
cFech	 += Space(aTam[1] - Len(cFech))

aTam	 := TamSX3("E1_CLIENTE")
cCliDe	 := Space(aTam[1])
cCliAte	 := Space(aTam[1])

aTam	 := TamSX3("E1_LOJA")
cLojaDe  := Space(aTam[1])
cLojaAte := Space(aTam[1])

cFechAnt := cFech

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta a tela para intracao do usuario                        ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

Define Msdialog oDlg From 22,9 To 330,540 Title "Fechamento Cart„o" Pixel

@ 020, 014 Msget cPrefix	Picture cPictPref							 						         Size 10, 11 Of oDlg Pixel
@ 020, 048 MsGet cFech 		Valid !Empty(cFech) .and. ValidaNum(@cFechAnt) 						         Size 50, 11 Of oDlg Pixel
@ 020, 100 MsGet cNat 		F3 "SED" Valid ValidaNat()											         Size 55, 11 Of oDlg Pixel
@ 054, 014 MsGet cCliDe		Picture "@!" F3 "SA1" Valid Empty(cCliDe)    .Or. ValidaCli(cCliDe)     	 Size 65, 11 Of oDlg Pixel
@ 054, 086 MsGet cLojaDe	Picture "@!"          Valid Empty(cLojaDe)   .Or. ValidaCli(cCliDe,cLojaDe)	 Size 21, 11 Of oDlg Pixel
@ 054, 120 MsGet cCliAte 	Picture "@!" F3 "SA1" Valid !Empty(cCLiAte)  .Or. ValidaCli(cCliAte)         Size 70, 11 Of oDlg Pixel
@ 054, 192 MsGet cLojaAte	Picture "@!"          Valid !Empty(cLojaAte) .Or. ValidaCli(cCliAte,cLojaAte)Size 10, 11 Of oDlg Pixel

@ 085, 014 MsGet dDTFecDe	Valid ValData()  Size 50, 11 Of oDlg Pixel
//@ 085, 086 MsGet dDTFecAt	Valid ValData() .And. ValMes(dDTFecDe,dDTFecAt) Size 50, 11 Of oDlg Pixel
@ 085, 086 MsGet dDTFecAt	Valid ValData()  Size 50, 11 Of oDlg Pixel

@ 119, 014 MsGet dDTVencDe	Valid ValData()	 Size 50, 11 Of oDlg Pixel
//@ 119, 086 MsGet dDTVencAt   Valid ValData() .And. ValMes(dDTVencDe,dDTVencAt)Size 50, 11 Of oDlg Pixel
@ 119, 086 MsGet dDTVencAt   Valid ValData()  Size 50, 11 Of oDlg Pixel

@ 010, 014 Say "Prefixo" 	 	Size 21, 7 Of oDlg Pixel
@ 010, 048 Say "Nr.Fatura" 	 	Size 49, 7 Of oDlg Pixel
@ 010, 100 Say "Natureza" 	 	Size 28, 7 Of oDlg Pixel

@ 044, 014 Say "Cliente de"  	Size 35, 7 Of oDlg Pixel
@ 044, 086 Say "Loja de" 	 	Size 30, 7 Of oDlg Pixel
@ 044, 120 Say "Cliente Ate" 	Size 45, 7 Of oDlg Pixel
@ 044, 192 Say "Loja Ate"    	Size 40, 7 Of oDlg Pixel

@ 075, 014 Say "Do Fechamento"  Size 50, 7 Of oDlg Pixel
@ 075, 086 Say "Ate Fechamento" Size 50, 7 Of oDlg Pixel
@ 109, 014 Say "Do Vencimento"  Size 50, 7 Of oDlg Pixel
@ 109, 086 Say "Ate Vencimento" Size 50, 7 Of oDlg Pixel

@ 004, 007 To 036, 225 Of oDlg Pixel
@ 038, 007 To 070, 225 Of oDlg Pixel
@ 072, 007 To 104, 225 Of oDlg Pixel
@ 105, 007 To 137, 225 Of oDlg Pixel

Define Sbutton From 07, 230 Type 1 Action (nOpca:=1,If(ValidaNum(@cFechAnt) .and. Fa280Ok(oDlg),oDlg:End(),nOpca:=0)) Enable Of oDlg
Define Sbutton From 25, 230 Type 2 Action oDlg:End() Enable Of oDlg

Activate Msdialog oDlg Centered

If nOpca == 1
	Processa( {|| RunProc()}, "Processando..." )
EndIf

Return()

Static Function RunProc()

Local _nLasRec := 0
Local cAlias
Local pX

#IFDEF TOP
	
	lQuery    := .T.
	cAlias    := "SE1QRY"
	cQuery    := "SELECT COUNT(*) CFIELD1"
	cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
	cQuery    += "SE1.E1_CLIENTE BETWEEN '"+cCLiDe+"' AND '"+cCliAte+"' AND "
	cQuery    += "SE1.E1_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"' AND "
	cQuery    += "SE1.E1_STATUS='A' AND "
	cQuery    += "SE1.D_E_L_E_T_=' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	_nLasRec := (cAlias)->CFIELD1
	
	DbCloseArea()
	
	// ALTERADO POR PEDRO TOSTES 10/06/05
	// SEPARAR A QUERY POR CLIENTE E N√O SELECIONAR TUDO DE UMA VEZ
	/*
	cQuery    := "SELECT E1_CLIENTE,E1_LOJA,E1_STATUS,R_E_C_N_O_ "
	cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
	cQuery    += "SE1.E1_CLIENTE BETWEEN '"+cCLiDe+"' AND '"+cCliAte+"' AND "
	cQuery    += "SE1.E1_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"' AND "
	cQuery    += "SE1.E1_STATUS='A' AND "
	cQuery    += "SE1.D_E_L_E_T_=' ' "
	cQuery    += "ORDER BY E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_VENCTO,E1_PARCELA,E1_EMISSAO"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	*/
	
#ELSE
	
	DbSelectArea("SE1")
	cIndex := CriaTrab(NIL,.F.)
	cChave := "E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_STATUS+DTOS(E1_VENCTO)+E1_PARCELA+DTOS(E1_EMISSAO)"
	IndRegua("SE1",cIndex,cChave,,T_FiltraTit(cCLiDe+cLojaDe,cCliAte+cLojaAte),"Selecionando registros...")
	nIndex := RetIndex(cAlias)
	//	dbSelectArea(cAlias)
	dbSelectArea("SE1")
	#IFDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex)
	DbGoTop()
	_nLasRec := RecCount()
	
	If BOF() .And. EOF()
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
	
#ENDIF

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorna todos os clientes a serem fechados de acordo com o periodo selecionado ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

If !Empty(dDTFecDe) .And. !Empty(dDTFecAt)
	aClits := BuscaClientes(dDTFecDe,dDTFecAt,.F.) //
Else
	aClits := BuscaClientes(dDTVencDe,dDTVencAt,.T.)
EndIf

aClits := aSort(aClits)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Ajusta regua de processamento ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

ProcRegua(Iif(lQuery,_nLasRec,Reccount()))

For pX:=1 To Len(aClits)
	
	nDiaAtras := 0
	cCliente  := Substr(aClits[pX],1,6)
	cLoja     := Substr(aClits[pX],7,2)
	
	If cCliente+cLoja >= cCliDe+cLojaDe .And. cCliente+cLoja <= cCliAte+cLojaAte
		
		If lQuery
			cAlias := RetornaTitulos(cCliente,cLoja,dDTFecDe,dDTFecAt)
		EndIf
		
		DbSelectArea(cAlias)
		While !EOF()
			
			IncProc("Processando cliente "+(cAlias)->E1_CLIENTE)
			lProcessa := .T.
			
			dPerfer := IIf(Empty(dDTFecAt),dDTVencDe,dDTFecAt)
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Se ja existe fechamento de fatura no mesmo mes para o cliente, ele move o registro ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			
			If !Empty((cAlias)->E1_MESFEC)
				
				If Month(Stod((cAlias)->E1_MESFEC)) = Month(ddatabase)
					cCliFat := (cAlias)->E1_CLIENTE+(cAlias)->E1_LOJA
				Else
					If ((cAlias)->E1_VALOR - (cAlias)->E1_SALDO) < (cAlias)->E1_PAGMIN
						If ddatabase > Stod((cAlias)->E1_VENCREA)
							nDiaAtras := (ddatabase - Iif(Empty((cAlias)->E1_BAIXA),Stod((cAlias)->E1_VENCREA),Stod((cAlias)->E1_BAIXA)))
						EndIf
					EndIf
				Endif
			EndIf
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Verifica se o proximo registro È do mesmo cliente. Caso seja, o sistema continua somando ≥
			//| os vaslores dos titulos e dando baixas, caso contrario, gera a fatua dos titulos.        |
			//| Verifica tambem se e final de arquivo ou se o titulo se refere a uma outra parcela       |
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			
			cNumero	 := (cAlias)->E1_NUM
			cPrefixo := (cAlias)->E1_PREFIXO
			cParcela := (cAlias)->E1_PARCELA
			nRegE1	 := R_E_C_N_O_
			
			ProcessaSE1(cFilial,cPrefixo,cNumero,cParcela,nRegE1,cFech,cPrefix,cTipo,nDiaAtras)
			
			nValDup   += (cAlias)->E1_SLDDUPL
			lRegImp   := .T.
			//nDiaAtras := 0
			
			dbSelectArea(cAlias)
			Dbskip()
			
		EndDo
		
		If lProcessa
			
			nValCruz := xMoeda(nValDup,1,1)
			nRegE1   := R_E_C_N_O_
			cCliFat  := Substr(aClits[pX],1,6)
			cLojaFat := Substr(aClits[pX],7,2)
			GravaFatura(cCliFat,cLojaFat,cFech,cPrefix,"A","FI",cNat,nValDup,nValCruz,nVARURV,1,nRegE1)
			
			nValDup := 0
			
			SuperGetMv("MV_CARTNUM")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD := cFech
			msUnlock()
			
			cFech := Soma1(cFech,2)
			
		EndIf
		
		DbSelectArea(cAlias)
		DbCloseArea()
		
	EndIf
	
Next pX

If lRegImp
	If Impressao() = 1
		//ExecBlock("T_IMPFATURA",.F.,.F.)
		T_ImpFatura()
	EndIf
Else
	Help(" ",1,"RECNO")
EndIf

#IFDEF TOP
	
	//dbSelectArea(cAlias)
	dbSelectArea("SE1")
	DbClearFilter()
	//RetIndex(cAlias)
	//If !Empty(cIndex)
	//	fErase(cIndex+OrdBagExt())
	//	cIndex := ""
	//Endif
	
	DbSelectArea("SE1")
	DbGoTop()
	dbSetOrder(1)
	dbSeek(xFilial())
	
#ELSE
	
	//dbSelectArea(_cAliasAnt)
	//dbCloseArea()
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbSeek(xFilial())
	
#ENDIF

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ProcessaSE1| Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Esta funcao prepara o registro posicionado para ser baixado  ≥±±
±±≥          ≥sem que haja movimantacao bancaria.                          ≥±±
±±≥          ≥Verifica tambem se o titulo tem juros.                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function ProcessaSE1(cFilSE1,cPrefSE1,cNumSE1,cParcSE1,nRegSE1,cNumFat,cPreFat,cTipoFat,nDiasAt,dDataBx)

Local nInd 		 := IndexOrd()
Private cJur280  := 0
Private cDesc280 := 0

Default dDataBx  := dDatabase

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Procura pelos Titulos de Abatimentos			≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DbSelectArea("SE1")
DbSetOrder(1)
DbSeek(cFilSE1+cPrefSE1+cNumSE1+cParcSE1)

While !EOF() .And. E1_FILIAL==cFilSE1 .And. E1_PREFIXO=cPrefSE1 .And. E1_NUM==cNumSE1 .And. E1_PARCELA==cParcSE1
	
	If E1_TIPO $ MVABATIM .And. E1_SALDO > 0
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Efetua a Baixa dos Titulos de Abatimento   ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		
		nJur280  := 0
		nDesc280 := 0
		BaixaTitulo(cNumFat,cPrefat,cTipofat,dDataBx,,nJur280,nDesc280,nDiasAt)
		
	Endif
	dbSkip()
Enddo

dbGoto(nRegSE1)
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Atualiza a Baixa do Titulo	   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !(E1_TIPO $ MVABATIM) .And. E1_SALDO > 0
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Efetua a Baixa do Titulo Principal         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nJur280  := SE1->E1_SDACRES
	nDesc280 := SE1->E1_SDDECRE
	BaixaTitulo(cNumFat,cPrefat,cTipoFat,dDataBx,,nJur280,nDesc280,nDiasAt)
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Gera movimento da Baixa do Titulo no SE5   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	GeraSE5(cFilSE1,cNumFat,dDataBx)
EndIf

SE1->(DbSetOrder(nInd))

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FiltraTit  | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Filtra os titulos de acordo com o parametro de               ≥±±
±±≥          ≥cliente de/ate											   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Template Function FiltraTit(cPar1,cPar2)

Local cFiltro   := ""
Local cCliDe    := Substr(cPar1,1,6)
Local cLojaDe   := Substr(cPar1,7,2)
Local cCliAt	:= Substr(cPar2,1,6)
Local cLojaAt   := Substr(cPar2,7,2)

cFiltro += 'E1_FILIAL="' + xFilial("SE1") + '".And.'
cFiltro += 'E1_CLIENTE>="' + cCliDe + '".And.'
cFiltro += 'E1_CLIENTE<="' + cCliAt + '".And.'
cFiltro += 'E1_LOJA>="' + cLojaDe +'".And.'
cFiltro += 'E1_LOJA<="' + cLojaAt +'".And.'
cFiltro += 'E1_STATUS="A"'

Return(cFiltro)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ValidaNum  | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Valida se o numero informado para geracao da fatura          ≥±±
±±≥          ≥ja existe no SE1											   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static FuncTion ValidaNum(cFatAnterior)

Local lRet      :=.T.
Local aArea 	:= GetArea()
Local aAreaSe1	:= SE1->(GetArea())

DbSelectArea("SE1")
DbSetOrder(1)
If dbSeek(xFilial("SE1")+cPrefix+cFech)
	While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. cPrefix+cFech == SE1->E1_PREFIXO+SE1->E1_NUM
		Help(" ",1,"A280EXIST")
		lRet:=.F.
		Exit
		dbSkip()
	Enddo
Else
	If cFech <> cFatAnterior
		FreeUsedCode()
	Endif
	If !MayIUseCode("SE1"+xFilial("SE1")+cFech)
		lRet:=.F.
	Endif
EndIf

SE1->(RestArea(aAreaSe1))
RestArea(aArea)

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥Validadata | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Retorna o periodo de compra do cliente, para gravacao no SE1 ≥±±
±±≥          ≥da fatura.												   ≥±±
±±≥          ≥Esta funcao baseia-se no arquivo de config. de cartao(LFX)   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Validadata(cConfig)

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
	
	If !Empty(dDTFecDe)
		//If Val(LFX->LFX_PAGTO) < Val(LFX->LFX_FECH) ( MUDAR NOME DE CAMPO DE: LFX_FECH | PARA: LFX_VENCTO )
		If Val(LFX->LFX_FECH) < Val(LFX->LFX_VENCTO)
			
			//ddatade  := ctod(LFX->LFX_PAGTO+Substr(dtoc(dDTFecDe+(32-Day(dDTFecDe))),3,6))
			//ddatade  := ctod(LFX->LFX_PAGTO+Substr(Dtoc(ddatabase+(32-Day(ddatabase))),3,6))
			ddatade  := ctod(LFX->LFX_FECH+Substr(Dtoc(ddatabase+(32-Day(ddatabase))),3,6))
			
		Else
			
			//ddatade  := ctod(LFX->LFX_PAGTO+substr(dtoc(dDTFecDe),3,6))
			//ddatade  := ctod(LFX->LFX_PAGTO+substr(Dtoc(ddatabase),3,6))
			ddatade  := ctod(LFX->LFX_FECH+substr(Dtoc(ddatabase),3,6))  // data de vencimento
			
		EndIf
		
		//ddataini := ctod(LFX->LFX_FECH+"/"+substr(dtoc(dDTFecDe),3,6))
		//ddataini := ctod(LFX->LFX_FECH+"/"+substr(dtoc(ddatabase),3,6))
		ddataini := ddatabase                                            // data de emissao
		
		If ddatade <= ddataini
			ddatade	:= ddatabase + 30
		EndIf
		
	Else
		
		//If Val(LFX->LFX_PAGTO) < Val(LFX->LFX_FECH)
		If Val(LFX->LFX_FECH) < Val(LFX->LFX_VENCTO)
			
			//ddatade  := ctod(LFX->LFX_PAGTO+Substr(dtoc(dDTFecDe+(32-Day(dDTVencDe))),3,6))
			//ddatade  := ctod(LFX->LFX_PAGTO+Substr(dtoc(ddatabase+(32-Day(ddatabase))),3,6))
			ddatade  := ctod(LFX->LFX_FECH+Substr(dtoc(ddatabase+(32-Day(ddatabase))),3,6))
			
		Else
			
			//ddatade  := ctod(LFX->LFX_PAGTO+substr(dtoc(dDTVencDe),3,6))
			//ddatade  := ctod(LFX->LFX_PAGTO+substr(dtoc(ddatabase),3,6))
			ddatade  := ctod(LFX->LFX_FECH+substr(dtoc(ddatabase),3,6))
			
		EndIf
		
		//ddataini := ctod(LFX->LFX_FECH+"/"+substr(dtoc(dDTVencDe),3,6))
		//ddataini := ctod(LFX->LFX_FECH+"/"+substr(dtoc(ddatabase),3,6))
		
		ddataini := ddatabase
	EndIf
	
	If Empty(ddatade)
		//cDia := LFX->LFX_PAGTO
		cDia := LFX->LFX_FECH
		For i:=1 to 10
			cDia := Alltrim(Str(Val(cDia) - 1))
			
			//ddatade := ctod(cDia+substr(dtoc(dDTFecDe),3,6))
			ddatade := ctod(cDia+substr(dtoc(ddatabase),3,6))
			
			If !Empty(ddatade)
				i:=10
			EndIf
		Next i
		ddatade++    //Proxima data valida
	EndIf
	
	ddataate := DataValida(ddatade,.T.)    // data real de vencimento
	
Endif

//Caso n„o ache nada, retorna vazio
Aadd(aDt,{IIf(ddatade=Nil,ctod("  /  /  "),ddatade),IIf(ddataate=Nil,ctod("  /  /  "),ddataate),IIf(ddataini=Nil,ctod("  /  /  "),ddataini)})

Return(aDt)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ValidaNat  | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Valida se a natureza informada pelo cliente È valida.        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function ValidaNat()

Local cAlias:=Alias(),lRet:=.T.

DbSelectArea("SED")
If !(dbSeek(cFilial+cNat))
	Help(" ",1,"A280NAT")
	lRet:=.F.
EndIf
dbSelectArea(cAlias)

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥Fa280Ok    | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Apresenta mensagem para confirmacao do usuario               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Fa280Ok(oDlg)

Local lRet := .T.
If ExistBlock("FA280OK")
	lRet := Execblock("FA280OK",.F.,.F.,oDlg)
Endif

Return (lRet .And. MsgYesNo("Confirma Dados?","AtenÁ„o"))

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥BaixaTitulo| Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Realiza a efetiva baixa do titulo no Financeiro              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function BaixaTitulo(cNumFat,cPrefat,cTipoFat,dDtbaixa,nCondLoja,nJur280,nDesc280,nDiasAt)

Local aAreaSa1   := SA1->(GetArea())
Local nAbatim    := 0
Local aArea      := {}
Local _nRecnoF2  := 0
Local lRecF2     := .F.

aArea 		     := GetArea()

Default dDtbaixa := dDatabase

/*
If SE1->E1_FATURA = "NOTFAT" .And. SE1->E1_SALDO > 0
lRecF2 := .T.
dbselectarea("SF2")
Reclock("SF2",.T.)
Replace SF2->F2_DOC      With SE1->E1_NUM
Replace SF2->F2_SERIE    With SE1->E1_PREFIXO
Replace SF2->F2_CLIENTE  With SE1->E1_CLIENTE
Replace SF2->F2_LOJA     With SE1->E1_LOJA
Replace SF2->F2_DUPL     With SE1->E1_NUM
Replace SF2->F2_EMISSAO  With ddatabase
Replace SF2->F2_EST      With SuperGetMv("MV_ESTADO")
Replace SF2->F2_TIPOCLI  With "F"
Replace SF2->F2_TIPO     With "N"
Replace SF2->F2_FILIAL   With xFilial("SF2")
Replace SF2->F2_ESPECIE  With "NF"
Replace SF2->F2_PREFIXO  With SE1->E1_PREFIXO
Replace SF2->F2_HORA     With Substr(time(),1,5)
msunlock("SF2")
_nRecnoF2 := Recno()
EndIf
*/
RestArea(aArea)
nCondLoja := Iif(nCondLoja==Nil,1,nCondLoja)

// Se a pergunta "Considera lojas" for igual a nao, deve-se atualizar o saldo das
// duplicadas das diferentes lojas
If nCondLoja == 2
	SA1->(DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
	SA1->(AtuSalDup("-",SE1->E1_SALDO,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO))
	SA1->(RestArea(aAreaSa1))
Endif

nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)

DbSelectArea("SA1")
DbSetOrder(1)
DbGoTop()
DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)

DbSelectArea("LFX")
DbSetOrder(1)
DbGoTop()
Dbseek(xFilial("LFX")+SA1->A1_CONFIG)

//Calculo do juros
//_nTxDia    := ((1 + LFX->LFX_JUROS / 100) ^ (1 / 30))
//_nTxPeri   := (_nTxDia ^ nDiasAt)
//_nJuros    := Iif(nDiasAt > 0,Round(SE1->E1_SALDO * (1 * _nTxPeri),2),0)

DbSelectArea("SE1")

RecLock("SE1",.F.)
SE1->E1_BAIXA	:= dDtbaixa
SE1->E1_VALLIQ	:= SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE - nAbatim
//SE1->E1_JUROS	:= _nJuros //Iif(nDiasAt>0,(((LFX->LFX_JUROS * SE1->E1_VALLIQ)/100) * nDiasAt),0)
//SE1->E1_VALLIQ  += _nJuros //SE1->E1_JUROS
//SE1->E1_VALMULT := Iif(nDiasAt > 0,Round(SE1->E1_VALLIQ*(LFX->LFX_MULTA/100),2),0)
//SE1->E1_VALLIQ  += SE1->E1_VALMULT
_nSldTit        := SE1->E1_SALDO
SE1->E1_SLDDUPL := SE1->E1_SALDO
SE1->E1_SALDO	:= 0
SE1->E1_MOVIMEN	:= dDtbaixa
If SE1->E1_FATURA = "NOTFAT"
	SE1->E1_FATUANT := SE1->E1_NUM
	SE1->E1_PREFANT := SE1->E1_PREFIXO
EndIf
SE1->E1_FATURA 	:= cNumFat
SE1->E1_FATPREF := cPrefat
SE1->E1_TIPOFAT := cTipofat
SE1->E1_DTFATUR := dDtbaixa
SE1->E1_STATUS 	:= Iif(SE1->E1_SALDO>0.01,"A","B")
SE1->E1_FLAGFAT := "S"
SE1->E1_SDDECRE	:= 0
SE1->E1_SDACRES	:= 0
SE1->E1_DESCONT	:= nDesc280
//SE1->E1_PORCJUR := Iif(SE1->E1_JUROS > 0,LFX->LFX_JUROS,0)
//SE1->E1_PERMULT := Iif(nDiasAt > 0,LFX->LFX_MULTA,0)
MsUnlock()

If lRecF2
	DbSelectArea("SF2")
	DbGoTo(_nRecnoF2)
	RecLock("SF2",.F.)
	Replace SF2->F2_VALBRUT  With SE1->E1_VALLIQ
	Replace SF2->F2_VALMERC  With SE1->E1_VALLIQ
	Replace SF2->F2_VALFAT   With SE1->E1_VALLIQ
	MsUnLock("SF2")
	
	DbSelectArea("SE2")
EndIf

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥GeraSE5    | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Movimenta o banco.							               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function GeraSE5(cFilSE5,cFatSE5,dDtMovSE5)

Local aTipoDoc	:= {}
Local nA, cSequencia
Local nX

Default dDtMovSE5 := dDatabase

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Localiza a sequencia da baixa ( CP,BA,VL,V2,LJ )			 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aTipoDoc   := {"CP","BA","VL","V2"}
cSequencia := "00"
SE5->(dbSetOrder(2))
nSequencia := 0
For nA:= 1 to len(aTipoDoc)
	SE5->(dbSeek(cFilSE5+aTipoDoc[nA]+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
	
	While !SE5->(Eof())						.And. ;
		SE5->E5_FILIAL	== cFilSE5			.And. ;
		SE5->E5_TIPODOC	== aTipoDoc[nA]    	.And. ;
		SE5->E5_PREFIXO	== SE1->E1_PREFIXO	.And. ;
		SE5->E5_NUMERO	== SE1->E1_NUM		.And. ;
		SE5->E5_PARCELA	== SE1->E1_PARCELA	.And. ;
		SE5->E5_TIPO	== SE1->E1_TIPO
		
		If (SE5->E5_CLIFOR+SE5->E5_LOJA == SE1->E1_CLIENTE+SE1->E1_LOJA .And. SE5->E5_RECPAG=="R")
			If cSequencia < SE5->E5_SEQ
				cSequencia := SE5->E5_SEQ
			Endif
		EndIf
		SE5->(dbSkip())
	EndDo
Next I

cSequencia := Soma1(cSequencia,2)

For nX := 1 To 3
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Atualiza a MovimentaáÑo Banc†ria							 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	
	If nX==1
		cCpoTp  := "SE1->E1_VALLIQ"
		cTpDoc  := "BA"
	Elseif nX==2
		cCpoTp  := "nJur280"
		cTpDoc  := "JR"
	Elseif nX==3
		cCpoTp  := "nDesc280"
		cTpDoc  := "DC"
	Endif
	
	If &cCpoTp <> 0 .or. nX == 1
		
		RecLock("SE5",.T.)
		SE5->E5_FILIAL	:= xFilial("SE5")
		SE5->E5_DATA	:= dDtMovSE5
		SE5->E5_VALOR	:= xMoeda(&cCpoTp,SE1->E1_MOEDA,1,dDtMovSE5,3)
		SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
		SE5->E5_RECPAG	:= "R"
		SE5->E5_TIPO	:= SE1->E1_TIPO
		SE5->E5_LA		:= "S"
		SE5->E5_TIPODOC	:= cTpDoc
		If !Empty(SE1->E1_FATUANT)
			SE5->E5_HISTOR	:= "Transferencia Saldo Proximo Mes"+Substr(Dtoc(ddatabase),4,5)
		Else
			SE5->E5_HISTOR	:= "Bx.p/Emiss.Fatura "+cFatSE5
		EndIf
		SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
		SE5->E5_NUMERO	:= SE1->E1_NUM
		SE5->E5_PARCELA	:= SE1->E1_PARCELA
		SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
		SE5->E5_LOJA	:= SE1->E1_LOJA
		SE5->E5_DTDIGIT	:= dDtMovSE5
		SE5->E5_MOTBX	:= "FAT"
		SE5->E5_VLMOED2	:= &cCpoTp
		SE5->E5_SEQ		:= StrZero(nSequencia,2,0)
		SE5->E5_DTDISPO	:= dDtMovSE5
		SE5->E5_BENEF	:= SE1->E1_NOMCLI
		If nx == 1 //Movimento principal
			SE5->E5_VLJUROS	:= nJur280
			SE5->E5_VLDESCO	:= nDesc280
		Endif
		MsUnlock()
	Endif
Next

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥Gravafatura| Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Apos movimentar todos os titulos de compra(SE1).             ≥±±
±±≥          ≥Esta funcao grava os dados da fatura a ser gerada            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Gravafatura(cCli,cLoja,cFatura,cPrefix,cParcela,cTipo,cNat,nValDup,nValCruz,nVARURV,nMoedFat,nRegE1)

Local _nTxDia  := 0
Local _nTxPeri := 0
Local _nJuros  := 0
Local aDatas   := {}
Local dDatEmis := dDataBase
Local cVencmto := dDataBase
Local i
Local aProdAdd := {}
Local nTotProd := 0
Local nValFatura

dbSelectArea("SA1")
DbSetOrder(1)
DbGoTop()
dbSeek(xFilial("SA1")+cCli+cLoja)

dbSelectArea("MA6")
dbsetOrder(2)
DbGoTop()
Dbseek(xFilial("MA6")+SA1->A1_COD+SA1->A1_LOJA)

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
		nTotProd += aProdAdd[i][2]
	EndIf
	
	dbGotop()
Next i

aDatas := ValidaData(SA1->A1_CONFIG)

//Calculo do juros
_nTxDia    := ((1 + LFX->LFX_JUROS / 100) ^ (1 / 30))
_nTxPeri   := (_nTxDia ^ nDiaAtras)
_nJuros    := Iif(nDiaAtras > 0,Round(_nSldTit * (1 * _nTxPeri),2),0)

RecLock("SE1",.T.)
Replace E1_FILIAL  With xFilial("SE1")
Replace E1_NUM 	   With cFatura
Replace E1_PARCELA With cParcela
Replace E1_PREFIXO With cPrefix
Replace E1_NATUREZ With cNat
Replace E1_SITUACA With "0"
Replace E1_VENCTO  With aDatas[1][1]
Replace E1_VENCREA With aDatas[1][2]
Replace E1_VENCORI With aDatas[1][2]
Replace E1_EMISSAO With aDatas[1][3]
Replace E1_EMIS1   With aDatas[1][3]
Replace E1_MESFEC  With aDatas[1][3]
If cPaisLoc<>"CHI"
	Replace E1_TIPO With cTipo
Else
	Replace E1_TIPO With "LT"
Endif
For i:=1 To Len(aProdAdd)
	Replace &("SE1->E1_PROD"+Alltrim(Str(i)))   With aProdAdd[1][1] // <= Criei
	Replace &("SE1->E1_VALPRO"+Alltrim(Str(i))) With aProdAdd[1][2]	// <= Criei
Next i

nValFatura := (nValDup+nTotProd+LFX->LFX_TXADM+_nJuros+SE1->E1_VALMULT)

Replace SE1->E1_JUROS   With _nJuros
Replace SE1->E1_VALMULT With Iif(nDiaAtras > 0,Round(nValFatura*(LFX->LFX_MULTA/100),2),0)
Replace SE1->E1_PORCJUR With Iif(SE1->E1_JUROS > 0,LFX->LFX_JUROS,0)
Replace SE1->E1_PERMULT With Iif(nDiaAtras > 0,LFX->LFX_MULTA,0)

Replace E1_CLIENTE With cCli
Replace E1_LOJA	   With cLoja
Replace E1_CC      With MA6->MA6_NUM
Replace E1_NOMCLI  With SA1->A1_NREDUZ
Replace E1_MOEDA   With nMoedFat
Replace E1_VALOR   With nValFatura
Replace E1_SALDO   With nValFatura
Replace E1_TXADM   With LFX->LFX_TXADM // <= Criei
Replace E1_FATURA  With "NOTFAT"
Replace E1_VLCRUZ  With xMoeda(nValFatura,nMoedFat,1)  // nValCruz
Replace E1_VARURV  With nVARURV
Replace E1_STATUS  With Iif(E1_SALDO>0.01,"A","B")
Replace E1_OCORREN With "01"
Replace E1_ORIGEM  With "FECHMES"
Replace E1_PAGMIN  With ((nValFatura)*LFX->LFX_PERC)/100 // <= Criei

MsUnlock()

If ExistBlock("FA280")
	ExecBlock("FA280",.f.,.f.,nRegE1)
Endif

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥Legenda    | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Apresenta a legenda ao usuario                               ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Template Function Legenda()

BrwLegenda(cCadastro,"Legenda",{{"ENABLE" ,"Titulos sem fatura gerada"},{"DISABLE","Titulos com fatura ja gerada"}})

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥ValidaCli  | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Valida se o cliente informado nos parametros e valido        ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function ValidaCli(cCli280,cLoja280)
Local cAlias :=Alias()
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
		/* Se nao encontrou o registro, retorna para o registro salvo pois, se a busca ≥
		estiver ocorrendo para o cliente a faturar e n∆o for encontrado, o SA1 fi - ≥
		 car† desposicionado.*/
		dbGoTo(nOldRec)
		Help(" ",1,"A280CLI")
		lRet := .F.
	EndIf
	
	If lRet
		dbSelectArea(cAlias)
	EndIf
EndIf

Return lRet

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥Cancelacart| Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cancela a baixa dos titulos dos titulos baixados e deleta    ≥±±
±±≥          ≥o titulo principal(Fatura)								   ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Template Function Cancelacart(cAlias,cCampo,nOpcE)
Local cArquivo
Local nTotal	:= 0
Local cFatDel   := Space(17)
Local nHdlPrv	:= 0
Local nTitulos	:= 0
Local nFaturas	:= 0
Local lPadrao
Local cPadrao 	:= "592"
Local oDlg
Local nOpca 	:= 0
Local nValor	:= 0
Local cNewFat	:= " "
Local aTam 		:= TamSx3("E1_NUM")
Local l280CalCn := .F.
Local cChaveSe1 := ""
Local lHead 	:= .F.
Local nValTotal := 0
Local nRecSe1	:= 0
Local aAreaSa1	:= SA1->(GetArea())
Local aAreaCan
Local lRet      := .T.
Local lCancelar := .T.
Local i

Private lQuery  := .F.
Private cCliCnDe  := Space(6)
Private cCliCnAt  := Space(6)
Private cLjCnDe   := Space(2)
Private cLjCnAt   := Space(2)
Private cAliasCn := "SE1QRYCAN"
Private dDataDe  := ddatabase
Private dDataAt  := ddatabase
Private cIndex	 := ""
Private cLote
Private xTotPro  := 0
Private oFont16b := TFont():New("Arial",,16,,.T.,,,,.F.,.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica se data do movimento nÑo Ç menor que data limite de ≥
//≥ movimentacao no financeiro    							     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

If !DtMovFin()
	Return
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica o numero do Lote 									 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
LoteCont("FIN")

dbSelectArea("SE1")

/*
DEFINE MSDIALOG oDlg FROM	22,9 TO 250,360 TITLE "Cancelamento de Fatura" PIXEL

//@ 06, 11 TO 100, 126 OF oDlg PIXEL

@ 21, 20   MSGet dDataDe Valid !Empty(dDataDe) SIZE 49, 08 OF oDlg PIXEL
@ 41, 20   MSGet dDataAt Valid !Empty(dDataAt) .And. dDataAt >= dDataDe SIZE 49, 08 OF oDlg PIXEL
@ 61, 20   MsGet cCliCnDe	Picture "@!" F3 "SA1" Valid Empty(cCliCnDe)  .Or. ValidaCli(cCliCnDe)   	  Size 49, 08 Of oDlg Pixel
@ 61, 70   MsGet cLjCnDe	Picture "@!"          Valid Empty(cLjCnDe)   .Or. ValidaCli(cCliCnDe,cLjCnDe) Size 19, 08 Of oDlg Pixel
@ 81, 20   MsGet cCliCnAt 	Picture "@!" F3 "SA1" Valid !Empty(cCliCnAt) .Or. ValidaCli(cCliCnAt)     	  Size 49, 08 Of oDlg Pixel
@ 81, 70   MsGet cLjCnAt	Picture "@!"          Valid !Empty(cLjCnAt)  .Or. ValidaCli(cCliCnAt,cLjCnAt) Size 19, 08 Of oDlg Pixel

@ 11, 20 SAY "Da GeraÁ„o "      SIZE 31, 37 OF oDlg PIXEL
@ 31, 20 SAY "AtÈ GeraÁ„o"      SIZE 31, 37 OF oDlg PIXEL
@ 51, 20 SAY "Do Cliente / Loja"  SIZE 51, 37 OF oDlg PIXEL
@ 71, 20 SAY "AtÈ Cliente / Loja" SIZE 51, 37 OF oDlg PIXEL

DEFINE SBUTTON FROM 10, 133 TYPE 1 ACTION (nOpca:=1,IF(.T.,oDlg:End(),nOpca:=0)) ENABLE OF oDlg
DEFINE SBUTTON FROM 23, 133 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED
*/

DEFINE MSDIALOG oDlg FROM	22,9 TO 250,360 TITLE "Cancelamento de Fatura" PIXEL

//@ 06, 11 TO 100, 126 OF oDlg PIXEL

@ 015, 014   MsGet cCliCnDe	Picture "@!" F3 "SA1" Valid Empty(cCliCnDe)  .Or. ValidaCli(cCliCnDe)   	  Size 49, 08 Of oDlg Pixel
@ 015, 076   MsGet cLjCnDe	Picture "@!"          Valid Empty(cLjCnDe)   .Or. ValidaCli(cCliCnDe,cLjCnDe) Size 19, 08 Of oDlg Pixel
@ 045, 014   MsGet cCliCnAt 	Picture "@!" F3 "SA1" Valid !Empty(cCliCnAt) .Or. ValidaCli(cCliCnAt)     	  Size 49, 08 Of oDlg Pixel
@ 045, 076   MsGet cLjCnAt	Picture "@!"          Valid !Empty(cLjCnAt)  .Or. ValidaCli(cCliCnAt,cLjCnAt) Size 19, 08 Of oDlg Pixel
@ 075, 014   MSGet dDataDe Valid !Empty(dDataDe) SIZE 49, 08 OF oDlg PIXEL
@ 075, 064   MSGet dDataAt Valid !Empty(dDataAt) .And. dDataAt >= dDataDe SIZE 49, 08 OF oDlg PIXEL

@ 005, 014 SAY "Do Cliente"  		SIZE 51, 37 Object oCliDe
oCliDe:oFont := oFont16b
@ 005, 076 SAY "Da Loja"  			Size 50, 11 Object oLojaDe
oLojaDe:oFont := oFont16b
@ 035, 014 SAY "AtÈ Cliente" 		SIZE 51, 37 Object oCliAte
oCliAte:oFont := oFont16b
@ 035, 076 SAY "Ate Loja"  	    	Size 50, 11 Object oLojaAte
oLojaAte:oFont := oFont16b
@ 065, 014 SAY "Da GeraÁ„o "      	SIZE 50, 37 Object oEmisDe
oEmisDe:oFont := oFont16b
@ 065, 064 SAY "AtÈ GeraÁ„o"      	SIZE 50, 37 Object oEmisAte
oEmisAte:oFont := oFont16b

DEFINE SBUTTON FROM 07, 125 TYPE 1 ACTION (nOpca:=1,IF(.T.,oDlg:End(),nOpca:=0)) ENABLE OF oDlg
DEFINE SBUTTON FROM 25, 125 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ PONTO DE ENTRADA F280PCAN                                     ≥
	//≥ Este PE serve para permitir ou n„o o cancelamento da fatura   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	
	If ExistBlock("F280PCAN")
		lRet := ExecBlock("F280PCAN",.F.,.F.)
	Endif
	
	If lRet
		
		nValTotal := 0
		Valor     := 0
		
		lAchou := FACalcula(dDataDe,dDataAt)
		
		If lAchou
			DbSelectArea(cAliasCn)
			DbGoTop()
			While !EOF()
				
				If !Empty((cAliasCn)->E1_BAIXA)
					lCancelar := .F.
					DbSkip()
					Loop
				EndIf
				
				If lQuery
					cChaveCn := (cAliasCn)->E1_FILIAL+(cAliasCn)->E1_CLIENTE+(cAliasCn)->E1_LOJA+(cAliasCn)->E1_PREFIXO+(cAliasCn)->E1_NUM
				Else
					aAreaCn  := GetArea()
					cChaveCn := xFilial("SE1")+(cAliasCn)->E1_CLIENTE+(cAliasCn)->E1_LOJA+(cAliasCn)->E1_PREFIXO+(cAliasCn)->E1_NUM
				EndIf
				
				DbSelectArea("SE1")
				DbSetOrder(10)
				DbGoTop()
				If DbSeek(cChaveCn)
					While !Eof() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_FATPREF+E1_FATURA = cChaveCn
						aAreaE1 := GetArea()
						DbSkip()
						aProxArea := GetArea()
						RestArea(aAreaE1)
						If SE1->E1_FATPREF+E1_FATURA = Substr(cChaveCn,11,9)
							cChaveSe1 := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
							dbSelectArea("SE5")
							dbSetOrder(7)
							If dbSeek(xFilial("SE5")+cChaveSE1)
								While !Eof() .and. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == cChaveSE1
									If SE5->E5_MOTBX== "FAT" .and. SE5->E5_RECPAG == "R"
										RecLock("SE5")
										dbDelete()
										MsUnlock()
									Endif
									dbSkip()
								Enddo
							Endif
							
							//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
							//≥ Se for um titulo que gerou a fatura, desfaz o processo	   ≥
							//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
							
							xTotPro := 0
							
							For i:=1 To 5
								xTotPro += &("SE1->E1_VALPRO"+Alltrim(Str(i)))
							Next i
							
							dbSelectArea("SE1")
							RecLock("SE1")
							//SE1->E1_SALDO	+= SE1->E1_VALLIQ - SE1->E1_JUROS - SE1->E1_TXADM - xTotPro - SE1->E1_VALMULT + SE1->E1_DESCONT
							SE1->E1_SALDO	+= SE1->E1_VALOR
							SE1->E1_MOVIMEN	:= dDataBase
							If Empty(SE1->E1_MESFEC)
								SE1->E1_FATURA 	:= " "
								SE1->E1_FATPREF	:= " "
							Else
								SE1->E1_FATURA 	:= "NOTFAT"
								SE1->E1_FATPREF	:= " "
								cFatDel := SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_NUM+SE1->E1_PREFIXO
								
								DbSelectArea("SF2")
								DbSetOrder(2)
								DbGoTop()
								If DbSeek(xFilial("SF2")+cFatDel)
									RecLock("SF2",.F.,.T.)
									dbDelete()
									MsUnlock()
								EndIf
								
							EndIf
							
							DbSelectArea("SE1")
							SE1->E1_TIPOFAT	:= " "
							SE1->E1_DTFATUR	:= CtoD("  /  /  ")
							SE1->E1_STATUS 	:= Iif(SE1->E1_SALDO>0.01,"A","B")
							SE1->E1_JUROS	:= 0
							SE1->E1_DESCONT	:= 0
							SE1->E1_VALLIQ	:= 0
							SE1->E1_BAIXA	:= CtoD("  /  /  ")
							If SE1->E1_SALDO == SE1->E1_VALOR
								SE1->E1_SDACRES	:= SE1->E1_ACRESC
								SE1->E1_SDDECRE	:= SE1->E1_DECRESC
							Endif
							SE1->E1_FLAGFAT   := Space(Len(SE1->E1_FLAGFAT))
							
							MsUnlock()
							//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
							//≥Integracao Modulo de Transporte (TMS).                                     ≥
							//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
							If IntTms()
								dbSelectArea("DT6")
								DT6->(dbSetOrder(1))
								If DbSeek(xFilial("DT6")+SE1->E1_MSFIL+SE1->E1_NUM+SE1->E1_SERIE)
									Reclock("DT6",.F.)
									DT6->DT6_FATURA	:=	Space(TamSx3("DT6_FATURA")[1])
									MsUnlock()
								EndIf
							EndIf
						Endif
						
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥ PONTO DE ENTRADA F280CAN                                      ≥
						//≥ Este PE serve para gravaá‰es complementares ap¢s cancelamento ≥
						//≥ do titulo na fatura.                                          ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
						IF ExistBlock("F280CAN")
							ExecBlock("F280CAN",.F.,.F.)
						Endif
						
						dbSelectArea("SE1")
						RestArea(aProxArea)
						
					Enddo
					
					If lQuery
						DbSelectArea("SE1")
						DbGoTo((cAliasCn)->R_E_C_N_O_)
					Else
						RestArea(aAreaCn)
					EndIf
					
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Se for uma parcela da fatura contabiliza o canceel. e deleta  ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					lPadrao:=VerPadrao(cPadrao)
					If lPadrao
						If !lHead
							nHdlPrv:=HeadProva(cLote,"FINA280",Substr(cUsuario,7,6),@cArquivo)
							lHead := .T.
						Endif
						nTotal+=DetProva(nHdlPrv,cPadrao,"FINA280",cLote)
					Endif
					dbSelectArea("SE1")
					
					nValTotal += SE1->E1_VLCRUZ
					
					//If lCancelar
					
					RecLock("SE1",.F.,.T.)
					dbDelete()
					MsUnlock()
					
					//EndIf
					
				EndIf
				
				DbSelectArea(cAliasCn)
				
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Volta Ultimo Numero do Parametro de Fatura           	≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				//If lCancelar
				cNewFat := SuperGetMv("MV_NUMFAT")
				If cNewFat == (cAliasCn)->E1_NUM
					RecLock("SX6",.F.)
					Replace X6_CONTEUD with Tira1((cAliasCn)->E1_NUM)
					MsUnlock()
				Endif
				//EndIf
				
				DbSkip()
			EndDo
			
			If nTotal > 0
				dbSelectArea("SE1")
				nRecSe1 := Recno()
				SE1->(DBGoBottom())
				SE1->(dbSkip())
				Valor := nValTotal
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA280",cLote)
				RodaProva(nHdlPrv,nTotal)
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Envia para Lancamento Contabil					    ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				cA100Incl(cArquivo,nHdlPrv,3,cLote,.T.,.F.)
				Valor := 0
				dbSelectArea("SE1")
				SE1->(DBGoTo(nRecSe1))
			Endif
		Endif
	Endif
	
	If lQuery
		DbSelectArea(cAliasCn)
		
		DbCloseArea()
	EndIf
	
Endif

If !lCancelar
	MsgAlert("Alguma fatura n„o foi cancelada pois j· existiam titulos baixados")
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Recupera a Integridade dos dados							 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea(cAlias)
DbClearFilter()
RetIndex(cAlias)
If !Empty(cIndex)
	fErase(cIndex+OrdBagExt())
	cIndex := ""
Endif
dbSetOrder(1)

dbSelectArea("SE1")
DbGoTop()
DbSeek(xFilial("SE1"))

Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FACalcula  | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Prepara os dados da fatura a ser cancelada                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FACalcula(dDtDe,dDtAt)

#IFDEF TOP
	
	lQuery    := .T.
	
	cQuery    := "SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_BAIXA,R_E_C_N_O_ "
	cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
	cQuery    += "SE1.E1_MESFEC BETWEEN '"+Dtos(dDtDe)+"' AND '"+Dtos(dDtAt)+"' AND "
	cQuery    += "SE1.E1_CLIENTE BETWEEN '"+cCliCnDe+"' AND '"+cCliCnAt+"' AND "
	cQuery    += "SE1.E1_LOJA BETWEEN '"+cLjCnDe+"' AND '"+cLjCnAt+"' AND "
	cQuery    += "SE1.E1_STATUS='A' AND "
	cQuery    += "SE1.D_E_L_E_T_=' ' ORDER BY E1_FILIAL,E1_PREFIXO,E1_NUM"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCn,.F.,.T.)
	
	If BOF() .and. EOF()
		Help(" ",1,"INDVAZIO")
		dbSelectArea("SE1")
		DbGoTop()
		dbSetOrder(1)
		Return .F.
	EndIf
	
#ELSE
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Cria indice condicional separando os titulos que deram origem a fatura ≥
	//≥ e as respectivas faturas que foram geradas							   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	
	cAliasCn := "SE1"
	cIndex := CriaTrab(nil,.F.)
	cChave := "E1_FILIAL+E1_PREFIXO+E1_NUM"
	IndRegua("SE1",cIndex,cChave,,T_FAFILCANC(dDtDe,dDtAt),"Selecionando Registros...")
	nIndex := RetIndex(cAliasCn)
	dbSelectArea(cAliasCn)
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbGoTop()
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Certifica se foram encontrados registros na condiáÑo selecionada 	   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If BOF() .and. EOF()
		Help(" ",1,"INDVAZIO")
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Restaura os indices do SE1 e deleta o arquivo de trabalho			≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		dbSelectArea("SE1")
		#IFDEF TOP
			Set Filter to
		#ELSE
			RetIndex(cAliasCn)
			fErase(cIndex+OrdBagExt())
			cIndex := ""
		#ENDIF
		dbSetOrder(1)
		Return .F.
	Endif
	
#ENDIF

Return .T.

Template Function Fafilcanc(dDtDe,dDtAt)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Devera selecionar todos os registros que atendam a seguinte condiáÑo : 	  ≥
//√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
//≥ 1. Prefixo e N£mero do Titulo iguais aos selecionados					  ≥
//≥ 2. Ou titulos que tenham originado a fatura selecionada 				  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Local cFiltro

cFiltro := 'E1_FILIAL="'+xFilial("SE1")+'".And.'
cFiltro += 'E1_CLIENTE>="'+cCliCnDe+'".And.'
cFiltro += 'E1_CLIENTE<="'+cCliCnAt+'".And.'
cFiltro += 'E1_LOJA>="'+cLjCnDe+'".And.'
cFiltro += 'E1_LOJA<="'+cLjCnAt+'".And.'
cFiltro += 'DTOS(E1_MESFEC)>="'+Dtos(dDtDe)+'".And.'
cFiltro += 'DTOS(E1_MESFEC)<="'+Dtos(dDtAt)+'".And.'
cFiltro += 'E1_STATUS="A"'

Return cFiltro

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥BuscaClientes | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥dPar1 - Data inicial a ser considerada para busca               ≥±±
±±≥          ≥dPar2 - Data final a ser considerada para busca                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥aPar1 - Clientes a serem processados                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Esta funcao busca todos os clientes a serem considerados no     ≥±±
±±≥          ≥fechamento. Ela se baseia no arquivo de configuracao de cartao  ≥±±
±±≥          ≥para saber o dia de fechamento de cada cliente.                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function BuscaClientes(dPar1,dPar2,lPar3)

Local xConfigs  := {}
Local xClientes := {}
Local i,j

DbSelectArea("LFX")

If lPar3
	DbSetOrder(3)
Else
	DbSetOrder(2)
EndIf

nDiasFec := Iif((dPar2 - dPar1)=0,1,(dPar2 - dPar1)+1)
nDiasFec := Iif(nDiasFec>31,31,nDiasFec)
dDataVal := dPar1
// Retorna quais configuracoes de cartao sao validas para o fechamento
For i:=1 To nDiasFec
	DbGoTop()
	If DbSeek(xFilial("LFX")+Strzero(Day(dDataVal),2))
		While !EOF() .And. LFX->LFX_FECH = Strzero(Day(dDataVal),2)
			//While !EOF() .And. LFX->LFX_VENCTO = Strzero(Day(dDataVal),2)
			If aScan(xConfigs,LFX->LFX_CODIGO)=0
				AAdd(xConfigs,LFX->LFX_CODIGO)
			EndIf
			DbSkip()
		EndDo
	EndIf
	dDataVal++
Next i
// Retorna todos os clientes que estao amarrados as configuracoes acima
DbSelectArea("SA1")
//DbSetOrder(10)
DbOrderNickName("SA1DRO3")
For j:=1 To Len(xConfigs)
	DbGoTop()
	If DbSeek(xFilial("SA1")+xConfigs[j])
		While !EOF() .And. SA1->A1_CONFIG = xConfigs[j]
			//DbSkip()
			//cRecn := Recno()
			//DbSkip(-1)
			AAdd(xClientes,SA1->A1_COD+SA1->A1_LOJA)
			DbSelectArea("SA1")
			//DbGoto(cRecn)
			DbSkip()
		EndDo
	EndIf
Next i

Return xClientes

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥ValData       | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Esta funcao valida se um dos parametros de data esta            ≥±±
±±≥          ≥preenchido. Caso este, nao deixa que o outro seja preenchido    ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function ValData()
Local lRet := .F.

If Empty(dDTVencDe) .And. Empty(dDTVencAt)
	lRet := .T.
EndIf

If Empty(dDTFecDe) .And. Empty(dDTFecAt)
	lRet := .T.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ValMes        | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Esta funcao valida se os parametro de data de/ate estao no      ≥±±
±±≥          ≥mesmo mes.                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
/*
Static Function ValMes(dPar1,dPar2)

Local lRet := .F.

If Month(dPar1) = Month(dPar2) .And. dPar2 >= dPar1
lRet := .T.
EndIf

Return lRet
*/
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥Impressao     | Autor ≥ Pedro Tostes          ≥ Data ≥ 08.10.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Esta funcao apresenta a tela para o usu·rio perguntando se      ≥±±
±±≥          ≥ele deseja imprimir a fatura logo apos o fim do processamento.  ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Impressao()

Local oDlga
Local nOpca

Define Msdialog oDlga From 22,9 To 130,340 Title "Impressao Fatura" Pixel

@ 010, 014 Say "Imprime ficha de compensaÁ„o?" Size 91, 7 Of oDlga Pixel

Define Sbutton From 05, 130 Type 1 Action (nOpca:=1,If(.T.,oDlga:End(),nOpca:=0)) Enable Of oDlga
Define Sbutton From 20, 130 Type 2 Action oDlga:End() Enable Of oDlga

Activate Msdialog oDlga Centered

Return nOpca

//------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaTitulos

@owner  	Varejo
@author  	Varejo
@version 	V12
@since   	 
/*/
//------------------------------------------------------------------------------
Static Function RetornaTitulos(cCliente,cLoja,dInicio,dFinal)

Local cE1Query
Local cAlias := "SE1QRY"

lProcessa := .F.
cE1Query := "SELECT *"
cE1Query += " FROM "+RetSqlName("SE1")+" SE1"
cE1Query += " WHERE (SE1.E1_FILIAL='"+xFilial("SE1")+"' AND"
cE1Query += " SE1.E1_CLIENTE = '"+cCliente+"' AND"
cE1Query += " SE1.E1_LOJA = '"+cLoja+"' AND"
cE1Query += " SE1.E1_VENCREA BETWEEN '"+Dtos(dInicio)+"' AND '"+Dtos(dFinal)+"' AND"
cE1Query += " SE1.E1_STATUS = 'A' AND"
cE1Query += " SE1.D_E_L_E_T_= ' ') OR"

cE1Query += " (SE1.E1_FILIAL='"+xFilial("SE1")+"' AND"
cE1Query += " SE1.E1_CLIENTE = '"+cCliente+"' AND"
cE1Query += " SE1.E1_LOJA = '"+cLoja+"' AND"
cE1Query += " SE1.E1_STATUS = 'A' AND"
cE1Query += " SE1.E1_FATURA = 'NOTFAT' AND"
cE1Query += " SE1.D_E_L_E_T_= ' ')"

cE1Query += " ORDER BY E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_VENCTO,E1_PARCELA,E1_EMISSAO"

cE1Query := ChangeQuery(cE1Query)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cE1Query),cAlias,.F.,.T.)

Return cAlias