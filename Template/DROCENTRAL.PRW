//Definicao de variavel em objeto
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
//Pula Linha
#Define CTRL Chr(13)+Chr(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DROCENTRALºAutor  ³Andre Melo/Machima  º Data ³ 14/01/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Central de Compras                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Template Function DROCENTRAL
Local oDlg, oDlgGrupo
Local oChk01, oChk02, oChk03, oChk04, oChk06
Local lRet    := .F.
Local lUltimoFil  := .F.
Local nDesc01 := 0
Local nDesc02 := 0
Local nDescdp := 0
Local nX, nY, nZ
Local nPosGrupo := 0
Local nPosFabr  := 0
Local nPosCtrl  := 0
Local nQtdeMesAnt := 0
Local nQtdeMesAtu := 0
Local nQuant      := 0
Local nSaldo      := 0
Local nNeces      := 0
Local nSavSaldo   := 0
Local nSaldoMax   := 0
Local nEstSeg     := 0
Local nTamQCusto  := TamSX3("D1_QUANT")[1]
Local nUltPrVenda := 0
Local nGiroAll    := 0
Local nEstAtuAll  := 0  //Estoque atual de todas as filiais
Local nConsDiaAll := 0  //Consumo diario de todas as filiais
Local nPosProd    := 0
Local nMesAtu
Local nAnoAtu
Local nQtdDiasMes := 0
Local nMesAnt
Local nAnoAnt
Local dEntrega
Local dUltDtVenda := CtoD("  /  /    ")
Local dDataIniAtu
Local dDataFimAtu
Local dDataIniAnt
Local dDataFimAnt
Local nPC_PenFil
Local nPC_Penden
Local nFilial

Local cNome   := Space(40)
Local cNome2  := Space(40)
Local cNome3  := Space(40)
Local cPrazo  := 0
Local cSeek1  := '"' + xFilial("SA2") + '"'
Local cWhile1 := "!EOF() .And. A2_FILIAL == " + cSeek1
Local cSeek2  := '"' + xFilial("SBM") + '"'
Local cWhile2 := "!EOF() .And. BM_FILIAL == " + cSeek2
//Local cSeek3  := '"' + xFilial("LFA") + '"'
//Local cWhile3 := "!EOF() .And. LFA_FILIAL == " + cSeek3
Local cSeek4  := '"' + xFilial("LEO") + '"'
Local cWhile4 := "!EOF() .And. LEO_FILIAL == " + cSeek4
Local cSeek5  := '"' + xFilial("AIA") + '"'
Local cWhile5 := "!EOF() .And. AIA_FILIAL == " + cSeek5
Local cSeekGrCmp  := '"' + xFilial("LFA") + '"'
Local cWhileGrCmp := "!EOF() .And. LFA_FILIAL == " + cSeekGrCmp
Local cArqTrb := "SB1"
Local cCodFilial := ""
Local cNomeFilial:= ""
Local cCodProd   := ""
#IFDEF TOP
	Local cQuery    := ""
#ENDIF

Local aRet1 := LocxGrid("SA2",cWhile1,'A2_FABRICA=="S"',.T.,".F.",cSeek1,2,{"A2_COD","A2_LOJA","A2_NOME"},)  //Fabricantes
Local aCab1 := AClone(aRet1[3])
Local aLin1 := AClone(aRet1[5])
Local aTam1 := AClone(aRet1[4])
Local aCpo1 := AClone(aRet1[1])

Local aRet2 := LocxGrid("SBM",cWhile2,,.T.,".F.",cSeek2,2,{"BM_GRUPO","BM_DESC"},)  //Grupos de produtos
Local aCab2 := AClone(aRet2[3])
Local aLin2 := AClone(aRet2[5])
Local aTam2 := AClone(aRet2[4])
Local aCpo2 := AClone(aRet2[1])

Local aRet4 := LocxGrid("LEO",cWhile4,,.T.,".F.",cSeek4,2,{"LEO_CODCON","LEO_CONDES"},)  //Controles
Local aCab4 := AClone(aRet4[3])
Local aLin4 := AClone(aRet4[5])
Local aTam4 := AClone(aRet4[4])
Local aCpo4 := AClone(aRet4[1])

Local aRet5 := LocxGrid("AIA",cWhile5,,.T.,".F.",cSeek5,1,{"AIA_CODTAB","AIA_DESCRI","AIA_CONDPG"},)  //Tabela de Precos
Local aCab5 := AClone(aRet5[3])
Local aLin5 := AClone(aRet5[5])
Local aTam5 := AClone(aRet5[4])
Local aCpo5 := AClone(aRet5[1])

Local aRetGrCmp := LocxGrid("LFA",cWhileGrCmp,,.T.,".F.",cSeekGrCmp,1,{"LFA_CODCOM","LFA_NOME","LFA_AGFILI","LFA_FILENT"},)  //Grupos de compra
Local aCabGrCmp := AClone(aRetGrCmp[3])
Local aLinGrCmp := AClone(aRetGrCmp[5])
Local aTamGrCmp := AClone(aRetGrCmp[4])
Local aCpoGrCmp := AClone(aRetGrCmp[1])

Local aQtdes     := {}
Local aAreaSM0   := SM0->(GetArea())
Local aFiliais   := {}  //Contem as filiais do grupo de compras selecionado

Local lQuery    := .F.
Local cText01   :='Não existe nenhum Grupo de Compras cadastrado ' + CTRL + CTRL + ;
'Favor verificar.'
Local cText02   := 'Não existe nenhuma Tabela de Preços cadastrada ' + CTRL + CTRL + ;
'Favor verificar.'
Local nPrecoProd := 0
Local bOrdem
Local nRecoSb2
Local nPosProduto
Local nPosFilial
Local nAEntregar := 0

Private lMark01	:= .F.
Private lMark02	:= .F.
Private lMark03	:= .F.
Private lMark04	:= .F.
Private lMark06	:= .T.  //Quantidade pedida igual a quantidade sugerida?

Private cFornece     := Space(TamSX3("A2_COD")[1])
Private cLoja        := Space(TamSX3("A2_LOJA")[1])
Private cFornece2    := Space(TamSX3("A2_COD")[1])
Private cLoja2       := Space(TamSX3("A2_LOJA")[1])
Private cFornece3    := Space(TamSX3("A2_COD")[1])
Private cLoja3       := Space(TamSX3("A2_LOJA")[1])
Private lSemPreco	 := .f.  // Indica se ~á produtos sem preco
aFornec := {}
Private cCodGrupo    := ""
Private nTipoDoc     := 1
Private nTipoOrd     := 1
Private cFilEntreg   := "" //Filial de entrega do PC. Se grupo de compras aglutina, (LFA_AGFILI = "S") usar LFA_FILENT. Caso contrario xfilial() da necessidade.
Private lAglutina  := .f.
Private nAComprar    := 0  //Quantidade a comprar - tela do Pre-PC
Private nVlrAComprar := 0  //Valor total dos produtos a comprar - tela do Pre-PC
Private nAIADESC1 := 0
Private  nAIADESC2 := 0
Private  nAIADESCFI := 0
Private  oGetAIADESC1
Private  oGetAIADESC2
Private  oGetAIADESCFI
Private aDadosFiltro := {}	// Contem os dados selecionados na tela de Central de Compras, fabricantes, grupos, Tabela de Preços e controles
Private aProdsPP     := {}	// Contem os produtos selecionados pela rotina de analise por ponto de pedido
Private aProdFilial  := {}		// Contem giro,sugestao,qtd.pedida,loja, giro por produto e por filial.
Private aItensProd   := {}		// Contem os produtos selecionados como sugestao de compras
Private aItensPrePC  := {}	// Contem os produtos selecionados como sugestao de compras ja na Ordem correta de Visualizacao
Private aPc_Penden := {}	// Contem os totais por filial e produto dos PCs em aberto, (entregas ainda pendente)

Private cTabPreco	 := "  "
Private cCondPagto	 := "  "

Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  ****** Descric„o do array aProdsPP	 *******   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Dimensoes  ³ Descric„o						   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³    n,1	   ³ Codigo do produto                 ³
//³    n,2	   ³ Necessidade total(todas filiais)  ³
//³    n,3	   ³ Giro total                        ³
//³    n,4	   ³ Estoque Atual                      |
//³    n,5,1   ³ Cod. Filial                       ³
//³    n,5,2   ³ Fabricante+Loja                   ³
//³    n,5,3   ³ Grupo de produto                  ³
//³    n,5,4   ³ Controle                          ³
//³    n,5,5   ³ Necessidade da filial             ³
//³    n,5,6   ³ Giro da filial                    ³
//³    n,5,7   ³ Giro maximo da filial             ³  // sem uso 
//³    n,5,8   ³ Nome da filial                    ³
//³    n,5,9   ³ Quantidade Pendente (a entreguar) |
//³    n,6	   ³ Saldo total                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  ****** Descric„o do array aProdFilial  *****  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Dimensoes  ³ Descric„o						   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³    n,1	   ³ Codigo do produto                 ³
//³    n,2	   ³ Nome do produto                   ³
//³    n,3,z,1 ³ Mark                              ³
//³    n,3,z,2 ³ Giro da filial                    ³
//³    n,3,z,3 ³ Necessidade da filial             ³
//³    n,3,z,4 ³ Qtd. Pedida                       ³
//³    n,3,z,5 ³ Qtd. Pendente (a entreguar)       |
//³    n,3,z,6 ³ Nome da filial                    ³
//³    n,3,z,7 ³ Giro maximo da filial             ³  // Sem uso
//³    n,3,z,8 ³ Cod. Filial                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  ****** Descric„o do array aItensProd *******  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Dimensoes  ³ Descric„o						   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³    n,1	   ³ Codigo do produto                 ³
//³    n,2	   ³ Descricao do produto              ³
//³    n,3	   ³ Local padrao                      ³
//³    n,4     ³ Unidade de medida                 ³
//³    n,5     ³ Fabricante+Loja                   ³
//³    n,6     ³ Grupo de produto                  ³
//³    n,7     ³ Controle                          ³
//³    n,8     ³ Custo standard                    ³
//³    n,9     ³ Ultimo preco de compra            ³
//³    n,10    ³ Data da ultima compra             ³
//³    n,11    ³ Custo minimo                      ³
//³    n,12    ³ Data do custo minimo              ³
//³    n,13    ³ Custo maximo                      ³	 
//³    n,14    ³ Data do custo maximo              ³
//³    n,15    ³ Saldo atual                       ³
//³    n,16    ³ Quantidade vendida no mes atual   ³
//³    n,17    ³ Quantidade vendida no mes anterior³
//³    n,18    ³ Ultimo preco de venda             ³
//³    n,19    ³ Data da ultima venda              ³
//³    n,20    ³ Giro total                        ³
//³    n,21	   ³ Necessidade total(todas filiais)  ³
//³    n,22    ³ Quantidade pedida                 ³
//³    n,23    ³ Segunda unidade de medida         ³
//³    n,24,z,1³ Codigo da filial                  ³
//³    n,24,z,2³ Giro da filial                    ³
//³    n,24,z,3³ Necessidade da filial             ³
//³    n,24,z,4³ Qtd Pedida                        ³
//³    n,24,z,5³ Nome da filial                    ³
//³    n,24,z,6³ Giro maximo da filial             ³	// Sem uso
//³    n,24,z,7³ Qtde Pendente(a entreguar) filial |
//³    n,25    ³ Prazo Medio de Entrega            ³
//³    n,26    ³ Qtde Pendente do produto (Total)  |
//³    n,27    ³ TES do Produto                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  ****** Descric„o do array aDadosFiltro *******³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Dimensoes  ³ Descric„o						   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³    n,1	   ³ Alias                             ³
//³    n,2	   ³ Cod. fabricante,grupo prod/compra,³
//³     	   ³ controle ou Tabela de Preços      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP
	lQuery  := (TcSrvType() <> "AS/400")
#ENDIF

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//Verifica se existe algum Grupo de Comrpas cadastrada
LFA->(DbGoTop())// vai para o Topo do arquivo
If  LFA->(EOF())// verifica se o Topo do arquivo eh o final, se for final de arquivo, significa Arquivo vazio
	MsgAlert(cText01)
	Return .F.
Endif


AIA->(DbGoTop())
If  AIA->(EOF())// verifica se o Topo do arquivo eh o final, se for final de arquivo, significa Arquivo vazio
	MsgAlert(cText02)
	Return .F.
Endif
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecao do grupo de compras                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgGrupo TITLE "Grupos de Compra" FROM 15,40 TO 35,90

oLbxGrCmp := TwBrowse():New(011,000,000,000,,aCabGrCmp,aTamGrCmp,oDlgGrupo,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbxGrCmp:nHeight	:= (__DlgHeight(oDlgGrupo)*2) - 8
oLbxGrCmp:nWidth		:= __DlgWidth(oDlgGrupo)*2
oLbxGrCmp:lColDrag	:= .T.
oLbxGrCmp:nFreeze	:= 1
oLbxGrCmp:SetArray(aLinGrCmp)
oLbxGrCmp:bLine		:= LocxBLin('oLbxGrCmp',aCpoGrCmp,.T.)
oLbxGrCmp:bLDblClick	:={ || ChgMarkLb(oLbxGrCmp,aLinGrCmp,{|| .T. },.F.), DROShowGrp(aLinGrCmp) }

ACTIVATE MSDIALOG oDlgGrupo ON INIT EnchoiceBar(oDlgGrupo,{|| IIf(DROSelGrupo(@aFiliais,aLinGrCmp),(lRet := .T.,oDlgGrupo:End()),NIL)},{|| lRet := .F.,oDlgGrupo:End()},,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analise por ponto de pedido - extraido do MATA170         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas pela pergunta MTA170   ³
//³ mv_par01     // Produto de                  ³
//³ mv_par02     // Produto ate                 ³
//³ mv_par03     // Grupo de                    ³
//³ mv_par04     // Grupo ate                   ³
//³ mv_par05     // Tipo de                     ³
//³ mv_par06     // Tipo ate                    ³
//³ mv_par07     // Local de                    ³
//³ mv_par08     // Local ate                   ³
//³ mv_par09     // Considera Necess Bruta      ³1=Sim;2=Nao
//³ mv_par10     // Saldo Neg Considera         ³1=Saldo;2=Saldo+LE
//³ mv_par11     // Data limite p/ empenhos     ³
//³ mv_par12     // Cons.Qtd. De 3os.? Sim / Nao³
//³ mv_par13     // Cons.Qtd. Em 3os.? Sim / Nao³
//³ mv_par14     // Ao atingir Estoque Maximo ? ³1=Qtde. Original;2=Ajusta Est. Max
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet .Or. !Pergunte("MTA170",.T.)
	Return
EndIf
nAComprar    := 0
nVlrAComprar := 0
lRet         := .F.
//Preenche o array com as informacoes dos produtos para apresentar na tela de pre-pedido de compras
ProcRegua(SB1->(RecCount())*5)

dbSelectArea("SB1")
#IFDEF TOP
	If ( TcSrvType()!="AS/400" )
		cArqTrb:= "TRBSB1"
		cQuery := "SELECT SB1.*,SB1.R_E_C_N_O_ SB1RECNO FROM " + RetSqlName("SB1")+" SB1 "
		cQuery += "WHERE SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
		cQuery += "SB1.B1_COD >='" +Mv_Par01+"' AND SB1.B1_COD <='" +Mv_Par02+"' AND "
		cQuery += "SB1.B1_GRUPO>='"+Mv_Par03+"' AND SB1.B1_GRUPO<='"+Mv_Par04+"' AND "
		cQuery += "SB1.B1_TIPO>='" +Mv_Par05+"' AND SB1.B1_TIPO<='" +Mv_Par06+"' AND "
		cQuery += "SB1.B1_CONTRAT<>'S' AND B1_TIPO<>'BN' AND "
		cQuery += "SB1.B1_COD NOT LIKE 'MOD%' AND SB1.D_E_L_E_T_<>'*'"
		cQuery += "ORDER BY "+SqlOrder(SB1->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cArqTrb)
		dbGoTop()
	Else
		dbSeek( xFilial("SB1")+MV_PAR01,.T. )
	EndIf
#ELSE
	dbSeek( xFilial("SB1")+MV_PAR01,.T. )
#ENDIF

While (cArqTrb)->(!Eof()) .And. (cArqTrb)->B1_FILIAL+(cArqTrb)->B1_COD <= xFilial("SB1")+MV_PAR02
	
	IncProc()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra grupos e tipos nao selecionados e tambem se for MOD³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cArqTrb)->B1_GRUPO < mv_par03 .Or. (cArqTrb)->B1_GRUPO > mv_par04 .Or.;
		(cArqTrb)->B1_TIPO  < mv_par05 .Or. (cArqTrb)->B1_TIPO  > mv_par06 .Or.;
		SubStr((cArqTrb)->B1_COD,1,3) == "MOD" .Or. (cArqTrb)->B1_TIPO == "BN" .Or.;
		(cArqTrb)->B1_CONTRAT == "S" .Or. (cArqTrb)->B1_CONTRAT == "A"
		dbSelectArea(cArqTrb)
		dbSkip()
		Loop
	EndIf

	cCodProd  := (cArqTrb)->B1_COD
	nRecoSb2  := (cArqTrb)->( recno() )
	dbSelectArea("SC7")
	DBSETORDER(15)
	
	For nFilial = 1 to len(aFiliais)
		cCodFilial := 	aFiliais [ nFilial ]
		dbSeek( cCodFilial+ " " +cCodProd )
		While !eof() .and. cCodFilial+ " " +cCodProd = C7_FILIAL + C7_ENCER + C7_PRODUTO
			If SC7->C7_QUJE >=  SC7->C7_QUANT
				loop
			Endif

			dbselectarea("LHU")
			cChaveLHU := XFILIAL("LHU") + XFILIAL("SC7") + SC7->C7_NUM+ SC7->C7_ITEM+ SC7->C7_SEQUEN
			LHU-> ( MsSeek( cChaveLHU ) )		
			SB1-> ( MsSeek( XFILIAL("SB1") +  SC7->C7_PRODUTO) )

			While ! eof() .and.  xfilial("LHU") + LHU->LHU_FILPED + LHU->LHU_NUM + LHU->LHU_ITEM + LHU->LHU_SEQUEN ==  cChaveLHU
				nPosProduto := len( aPc_Penden ) + 1
				For nPosProduto = 1 to len(aPc_Penden)
					if aPc_Penden [nPosProduto] [ 1 ] == LHU->LHU_PRODUT
						exit
					endif
				Next
				
				if nPosProduto <= len(aPc_Penden)
					aPc_Penden[ nPosProduto ] [ 2 ]  += LHU->LHU_SALPEDI
					For nPosFilial = 1 to len(aPc_Penden[ nPosProduto ] [ 3 ] )
						if aPc_Penden[ nPosProduto ] [ 3 ][nPosFilial] [ 1 ] == LHU->LHU_FILNEC
							exit
						endif					
					Next
					if nPosFilial <= len(aPc_Penden[ nPosProduto ] [ 3 ] )
						aPc_Penden[ nPosProduto ] [ 3 ][nPosFilial] [ 2 ]  += LHU->LHU_SALPEDI 
					else
						aadd(aPc_Penden[ nPosProduto ] [ 3 ]  , {  LHU->LHU_FILNEC , LHU->LHU_SALPEDI  } )
					endif
				else
					aadd( aPc_Penden , { cCodProd, LHU->LHU_SALPEDI , { { LHU->LHU_FILNEC , LHU->LHU_SALPEDI } } }  )	
				endif
				DbSkip()
			Enddo		
			
			dbSelectArea("SC7")
			Dbskip()
		Enddo
	Next
	
	SM0->(DbSeek(cEmpAnt))
	While SM0->(!Eof()) .And. cEmpAnt == SM0->M0_CODIGO
		cCodFilial  := SM0->M0_CODFIL
		cNomeFilial := SM0->M0_FILIAL
		//Ignora se a filial nao estah incluida no grupo de compras selecionado
		If Ascan(aFiliais,{|x| Trim(x) == Trim(cCodFilial)}) == 0
			SM0->(DbSkip())
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posicionar no registro do produto da filial corrente(loop)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !dbSeek(cCodFilial+cCodProd)
			nQuant := 0
			nSaldo := 0
			SM0->(DbSkip())
			Loop
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o saldo atual de todos os almoxarifados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSaldo := 0
		nAEntregar := 0
		dbSelectArea("SB2")
		IF dbSeek( cCodFilial+cCodProd, .T. )
			If B2_LOCAL >= mv_par07 .and. B2_LOCAL <= mv_par08			 
				for nPC_Penden = 1 to len(aPc_Penden)
					if aPc_Penden [ nPC_Penden, 1 ] == cCodProd
						for nPC_PenFil = 1 to len( aPc_Penden[nPC_Penden, 3 ]  )
							if cCodFilial == aPc_Penden[nPC_Penden, 3, nPC_PenFil, 1 ]
								nAEntregar := aPc_Penden[nPC_Penden, 3, nPC_PenFil, 2 ]	//Pego somente o saldo no SC7/LHU (pedido-pendente) deste produto nesta filial
								// Na linha abaixo subistituí B2_SALPEDI por nAEntregar para conseguir tratar a aglutinacao do PCs (uso qtd pendente de entrega no SC7 desmembrado por filial no LHU)
								nSaldo += (DROSaldoSB2(.F.,.T.,If(Empty(mv_par11),dDataBase,mv_par11),mv_par12==1,mv_par13==1,"SB2",0,0,cCodFilial)+ nAEntregar +B2_QACLASS)-B2_QPEDVEN		
							endif
						Next
					endif
				Next
			EndIf
		EndIf

		nSaldoMax := SB1->B1_EMAX
		nSavSaldo := nSaldo
		nEstSeg   := CalcEstSeg( (cArqTrb)->B1_ESTFOR,cArqTrb )
		nSaldo -= nEstSeg
		
		If (Round(nSaldo,4) # 0) .Or. (mv_par09 == 1)
			Do Case
				Case ( (cArqTrb)->B1_EMIN != 0 .And. MV_PAR09 == 1 )
					If ( MV_PAR10 == 2 .And. nSaldo < 0 )
						nSaldo -= (cArqTrb)->B1_LE
					EndIf
					nNeces := If((nSaldo < 0),Abs(nSaldo)+(cArqTrb)->B1_EMIN,((cArqTrb)->B1_EMIN-nSaldo))
				Case ( (cArqTrb)->B1_EMIN != 0 .And. MV_PAR09 == 2 )
					If ( MV_PAR10 == 2 .And. nSaldo < 0 )
						nSaldo -= (cArqTrb)->B1_LE
					EndIf
					nNeces := If((nSaldo < 0),Abs(nSaldo),((cArqTrb)->B1_EMIN-nSaldo))
				Case ( (cArqTrb)->B1_LE != 0 .And. (nSaldo < 0  .or. mv_par09 == 2) )
					If ( MV_PAR10 == 2 .And. nSaldo < 0 )
						nNeces := Abs(nSaldo)+(cArqTrb)->B1_LE
					Else
						nNeces := If( Abs(nSaldo)<(cArqTrb)->B1_LE,(cArqTrb)->B1_LE,if(nSaldo<0,Abs(nSaldo),0))
					EndIf
				OtherWise
					nNeces := IF(MV_PAR09 == 1,IIf(nSaldo<0,Abs(nSaldo),0),0)
			EndCase
		Else
			If (cArqTrb)->B1_EMIN != 0
				nNeces := (cArqTrb)->B1_EMIN
			Else
				nNeces := 0
			Endif
		EndIf
		
		If nNeces > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se produto tem estrutura                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aQtdes := CalcLote(cCodProd,nNeces,"C")
			For nX := 1 to Len(aQtdes)
				nQuant += aQtdes[nX]
			Next nX
		EndIf
		
		If nSaldoMax # 0 .And. mv_par14 == 2
			nQuant := Min(nSaldoMax - nSavSaldo, nQuant)
		Endif
		
		dbSelectArea(cArqTrb)
		
		//Se nQuant = 0 nao ha necessidade de pedido/solicitacao
		If nQuant == 0
			nSaldo := 0
			SM0->(DbSkip())
			Loop
		EndIf
		
		dbSelectArea(cArqTrb)
		
		If (nPosProd := Ascan(aProdsPP,{|x| x[1] == cCodProd})) == 0
			//Produtos selecionados pela rotina de analise por ponto de pedido
			//AAdd(aProdsPP,{cCodProd,nQuant,0,nSaldo,{cCodFilial,(cArqTrb)->B1_CODFAB+(cArqTrb)->B1_LOJA,(cArqTrb)->B1_GRUPO,(cArqTrb)->B1_CODCOTL,;
			AAdd(aProdsPP,{cCodProd,nQuant,0,0,{cCodFilial,(cArqTrb)->B1_CODFAB+(cArqTrb)->B1_LOJA,(cArqTrb)->B1_GRUPO,(cArqTrb)->B1_CODCOTL,;
			nQuant,0,0,cNomeFilial, nAEntregar }})
		Else
			//Soma a necessidade por produto, total de todas as filiais do grupo de compras
			aProdsPP[nPosProd][2]  += nQuant
			//aProdsPP[nPosProd][4]  += nSaldo
			//Produtos selecionados pela rotina de analise por ponto de pedido
			AAdd(aProdsPP[nPosProd],{cCodFilial,(cArqTrb)->B1_CODFAB+(cArqTrb)->B1_LOJA,(cArqTrb)->B1_GRUPO,(cArqTrb)->B1_CODCOTL,;
			nQuant,0,0,cNomeFilial, nAEntregar })
		EndIf
		
		nQuant := 0
		nSaldo := 0
		
		SM0->(DbSkip())
	End
	dbSelectArea(cArqTrb)
	//DbSeek(xFilial("SB1")+cCodProd)    Por Problemas no ambiente TOP, substituido pela linha abaixo.
	dbgoto(nRecoSb2)
	dbSkip()
End

SM0->(RestArea(aAreaSM0))

If lQuery
	dbSelectArea(cArqTrb)
	dbCloseArea()
EndIf

DbSelectarea("SA2")
dbgotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela da Central de Compras                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE "Central de Compras" FROM 1,1 TO 35,100

TGroup():New(005,005,030,095," Tipo ",,,,.T.)
TGroup():New(005,100,030,190," Ordem ",,,,.T.)
TGroup():New(032,005,074,190," Fornecedor ",,,,.T.)
TGroup():New(076,005,160,190," Tabela de Preços ",,,,.T.)   //alt. 85 l. 185
TGroup():New(165,005,250,190," Fabricantes ",,,,.T.)        //alt. 85 l. 185
TGroup():New(005,200,105,385," Grupo de Produtos ",,,,.T.)  //alt. 100 l. 185
TGroup():New(115,200,215,385," 		Controles ",,,,.T.)  //alt. 100 l. 185
TGroup():New(220,200,250,300," Seleção ",,,,.T.)
TGroup():New(220,310,250,385," Confirma ",,,,.T.)//Botoes Ok e Cancela

//
TRadMenu():New( 008, 025, {"Pedido","Cotação"}    ,bSETGET(nTipoDoc),oDlg,, {|| oGet5:Refresh(),atualiVar(@cNome2,@cNome3)} ,,,,.T.,,35,10,,,,.T.)
//Ordem
TRadMenu():New( 008, 125, {"Produto","Fabricante"},bSETGET(nTipoOrd),oDlg,,,,,,.T.,,40,10,,,,.T.)

// Fornecedor
oGet3  := TGet():New(038,010, bSETGET(cFornece),oDlg,25,10,"@!",{|| atualiVar(@cNome2,@cNome3) },,,,,,.T.,,,,,.T.,,,,"FOR",)
oGet4  := TGet():New(038,042, bSETGET(cLoja),oDlg,05,10,"@!",{|| cNome:=Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NOME"),oGet5:Refresh(),atualiVar(@cNome2,@cNome3), DRORunLbx5(@oLbx05,cFornece+cLoja,@aLin5)},,,,,,.T.,,,,,.T.,,,,,)
oGet5  := TGet():New(038,058, bSETGET(cNome),oDlg,130,10,"@!",,,,,,,.T.,,,,,.T.,,.T.,,)
oGet6  := TGet():New(048,010, bSETGET(cFornece2),oDlg,25,10,"@!",,,,,,,.T.,,,{|| nTipoDoc == 2},,.T.,,,,"FOR",)
oGet7  := TGet():New(048,042, bSETGET(cLoja2),oDlg,05,10,"@!",{|| cNome2:=Posicione("SA2",1,xFilial("SA2")+cFornece2+cLoja2,"A2_NOME"),oGet8:Refresh(),DROVldFor(cFornece2+cLoja2)  },,,,,,.T.,,,{|| nTipoDoc == 2},,.T.,,,,,)
oGet8  := TGet():New(048,058, bSETGET(cNome2),oDlg,130,10,"@!",,,,,,,.T.,,,,,.T.,,.T.,,)
oGet9  := TGet():New(058,010, bSETGET(cFornece3),oDlg,25,10,"@!",,,,,,,.T.,,,{|| nTipoDoc == 2},,.T.,,,,"FOR",)
oGet10 := TGet():New(058,042, bSETGET(cLoja3),oDlg,05,10,"@!",{|| cNome3:=Posicione("SA2",1,xFilial("SA2")+cFornece3+cLoja3,"A2_NOME"),oGet11:Refresh(),DROVldFor(cFornece2+cLoja2) },,,,,,.T.,,,{|| nTipoDoc == 2},,.T.,,,,,)
oGet11 := TGet():New(058,058, bSETGET(cNome3),oDlg,130,10,"@!",,,,,,,.T.,,,,,.T.,,.T.,,)

//Box - Tabela de Preços
oLbx05:= TwBrowse():New(085,010,170,065,,aCab5,aTam5,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //a. 60 l. 170
oLbx05:lColDrag	:= .T.
oLbx05:nFreeze	:= 1
oLbx05:SetArray(aLin5)
oLbx05:bLine		:= LocxBLin('oLbx05',aCpo5,.T.)
oLbx05:bLDblClick	:={ || ChgMarkLb(oLbx05,aLin5,{|| .T. },.T.), DRODesmarcAll(@aLin5) }


//Box - Fabricante
oLbx01:= TwBrowse():New(175,010,170,60,,aCab1,aTam1,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //a. 60 l. 170
oLbx01:lColDrag	:= .T.
oLbx01:nFreeze	:= 1
oLbx01:SetArray(aLin1)
oLbx01:bLine		:= LocxBLin('oLbx01',aCpo1,.T.)
oLbx01:bLDblClick	:={ || ChgMarkLb(oLbx01,aLin1,{|| .T. },.T.), IIf(aLin1[oLbx01:nAt,1]==-1,(lMark01:=.F.,oChk01:Refresh()),NIL)}

//Box - Grupo de Produtos
oLbx02:= TwBrowse():New(015,205,170,70,,aCab2,aTam2,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //a. 70 l. 170
oLbx02:lColDrag	:= .T.
oLbx02:nFreeze	:= 1
oLbx02:SetArray(aLin2)
oLbx02:bLine		:= LocxBLin('oLbx02',aCpo2,.T.)
oLbx02:bLDblClick	:={ || ChgMarkLb(oLbx02,aLin2,{|| .T. },.T.), IIf(aLin2[oLbx02:nAt,1]==-1,(lMark02:=.F.,oChk02:Refresh()),NIL)}

//Box - Controles
oLbx04:= TwBrowse():New(125,205,170,70,,aCab4,aTam4,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //a. 70 l. 170
oLbx04:lColDrag	:= .T.
oLbx04:nFreeze	:= 1
oLbx04:SetArray(aLin4)
oLbx04:bLine		:= LocxBLin('oLbx04',aCpo4,.T.)
oLbx04:bLDblClick	:={ || ChgMarkLb(oLbx04,aLin4,{|| .T. },.T.), IIf(aLin4[oLbx04:nAt,1]==-1,(lMark04:=.F.,oChk04:Refresh()),NIL)}


//Marca todos Fabricantes
oChk01 := TCheckBox():New(237,135, "Marcar Todos", bSETGET(lMark01),oDlg,50,10,,,,,,,,.T.,,,)
oChk01:bLClicked := {|| T_MarcAll(@aLin1,lMark01) }

//Marca todos Grupo de Produtos
oChk02 := TCheckBox():New(090,330, "Marcar Todos", bSETGET(lMark02),oDlg,50,10,,,,,,,,.T.,,,)
oChk02:bLClicked := {|| T_MarcAll(@aLin2,lMark02) }

//Marca todos Controles
oChk04 := TCheckBox():New(200,330, "Marcar Todos", bSETGET(lMark04),oDlg,50,10,,,,,,,,.T.,,,)
oChk04:bLClicked := {|| T_MarcAll(@aLin4,lMark04) }

//Botoes de Confirma/Cancela
oBmt1 := SButton():New(230,320, 1, {|| IIf(VldSelecao(aLin1,aLin2,aLin4,aLin5),(lRet := .T., oDlg:End()),NIL) },,)
oBmt2 := SButton():New(230,350, 2, {|| oDlg:End() },,)

oChk06 := TCheckBox():New(228,210, "Preencher quantidade pedida?", bSETGET(lMark06),oDlg,85, 12,,,,,,,,.T.,,,)

ACTIVATE MSDIALOG oDlg CENTER

If lRet

	// Alimenta array aItensPrePC que eh a base para monta a tela pre-pedido de vendas	
	MsgRun("Aguarde. Selecionando registros para a tela de Pre-pedido" ,,{|| ItensPrePC()  })

	If Len(aItensPrePC) > 0
		ProdFili(aProdFilial,lMark06)		//Alimenta array aProdFilial (p/ digitar qtd. pedida por produto/filial)				
		T_DROPREPC()
	Else
		MsgAlert("Nenhum produto foi selecionado com o filtro utilizado!")
	EndIf	
Endif

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ItensPrePCºAutor  ³Geronimo B. Alves   º Data ³ 25/07/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alimenta a array aItensPrePC que serve de base para monta aº±±
±±ºDesc.     ³ tela pre-pedido de vendas. Apartir dos parametros e        º±±
±±º          ³ selecoes da tela de central de compras                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ItensPrePC()
Local nY, nX, nZ

	DbSelectArea("SB1")
	nPosFabr  := aScan(aDadosFiltro,{|x| x[1]=="SA2"})
	nPosGrupo := aScan(aDadosFiltro,{|x| x[1]=="SBM"})
	nPosCtrl  := aScan(aDadosFiltro,{|x| x[1]=="LEO"})
	If nPosFabr == 0 .Or. nPosGrupo == 0 .Or. nPosCtrl == 0
		MsgAlert("Erro no filtro!")
		Return .F.
	EndIf
	nAComprar    := 0
	nVlrAComprar := 0  
	aItensProd   := {}
	
	nMesAtu     := Month(dDatabase)
	nAnoAtu     := Year(dDatabase)
	dDataIniAtu := CTod("01/"+StrZero(nMesAtu,2)+"/"+AllTrim(Str(nAnoAtu)),"ddmmyyyy")
	dDataFimAtu := LastDay(dDataIniAtu)
	nQtdDiasMes := dDataFimAtu - dDataIniAtu + 1
	
	nMesAnt  := IIf(nMesAtu==1,12,nMesAtu - 1)
	nAnoAnt  := IIf(nMesAtu==1,nAnoAtu-1,nAnoAtu)
	dDataIniAnt := CTod("01/"+StrZero(nMesAnt,2)+"/"+AllTrim(Str(nAnoAnt)),"ddmmyyyy")
	dDataFimAnt := LastDay(dDataIniAnt)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra os produtos de acordo com o filtro da Central de Compras³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Loop para todos os produtos
	For nX := 1 to Len(aProdsPP)
		nQtdeMesAtu  := 0
		nQtdeMesAnt  := 0
		nEstAtuAll   := 0
		nConsDiaAll  := 0
		nUltPrVenda  := 0
		dUltDtVenda  := Ctod("  /  /    ")
		nQuant      := aProdsPP[nX][2]  //Total de necessidade do produto corrente de todas as filiais

		DBSELECTAREA("AIB")
		DBSETORDER(2)
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+aProdsPP[nX][1])
		
		//Loop para todas as filiais do produto corrente
		For nY := 5 to Len(aProdsPP[nX])
			
			//Verifica se selecionou algum fabricante
			If Len(aDadosFiltro[nPosFabr][2]) > 0 .and. !lMark01 // Se marquei todos não preciso da checagem abaixo. 
				//Se nao encontrar o fabricante do produto na relacao dos fabricantes selecionados, ignora o produto
				If Ascan(aDadosFiltro[nPosFabr][2],{|x| x[1] == aProdsPP[nX][nY][2]}) == 0
					Loop
				EndIf
			EndIf
			//Verifica se selecionou algum grupo de produto
			If Len(aDadosFiltro[nPosGrupo][2]) > 0 .and. !lMark02 // Se marquei todos não preciso da checagem abaixo. 
				//Se nao encontrar o grupo do produto na relacao dos grupos selecionados, ignora o produto
				If Ascan(aDadosFiltro[nPosGrupo][2],{|x| x[1] == aProdsPP[nX][nY][3]}) == 0
					Loop
				EndIf
			EndIf
			//Verifica se selecionou algum controle de produto
			If Len(aDadosFiltro[nPosCtrl][2]) > 0 .and. !lMark04 // Se marquei todos não preciso da checagem abaixo. 
				//Se nao encontrar o controle do produto na relacao dos controles selecionados, ignora o produto
				If Ascan(aDadosFiltro[nPosCtrl][2],{|x| x[1] == aProdsPP[nX][nY][4]}) == 0
					Loop
				EndIf
			EndIf
			
			lUltimoFil  := nY == Len(aProdsPP[nX])  //Determina se eh a ultima filial do produto corrente
			cCodFilial  := aProdsPP[nX][nY][1]
			//Armazena o giro por produto e filial
			DROCalcGiro(@aProdsPP,nX,nY,lUltimoFil,@nEstAtuAll,@nConsDiaAll,nMesAtu,nQtdDiasMes)
			
			//Fabricante
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+SB1->B1_CODFAB+SB1->B1_LOJA))
			
			//Estoque
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
			
			//Pesquisa a quantidade vendida no mes atual e anterior e ultimo preco e data de venda
			DROPesqQtd(SB1->B1_COD,SB1->B1_LOCPAD,@nQtdeMesAtu,@nQtdeMesAnt,@nUltPrVenda,@dUltDtVenda,cCodFilial,;
			dDataIniAtu,dDataFimAtu,dDataIniAnt,dDataFimAnt)
			
			//Array apresentado ao usuario para preenchimento dos itens a serem pedidos, corresponde ao primeiro grid da tela de Pre-PC
			//                       1	         2   	       3             4           5                            6
			//                        7	             8   	       9            10            11             12
			//                       13	             14   	         15           16          17          18         19
			//                        20	           21   	           22               23,1           23,2
			//                         23,3	       23,4       23,5   	           23,6
			If nPosProd  := Ascan(aItensProd,{|x| x[1] == SB1->B1_COD}) == 0
			
				if AIB->( MsSeek(XFILIAL("AIB")+ cFornece+ cLoja+ cTabPreco+ SB1->B1_COD ) )
					nPrecoProd := AIB->AIB_PRCCOM
				else
					nPrecoProd := 0
				Endif

				// Se não achar preco na Tab. preço e for PC seto lSemPreco como .T. e nao gero pc para este item
				IF nTipoDoc ==  1		//Verifica se tem algum produto sem preco  (Somente se for PC.  Cotação não precisa)
					if nPrecoProd <= 0
						lSemPreco	:= .T.
					Endif
				Endif
			
				AAdd(aItensProd,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_LOCPAD,SB1->B1_UM,SB1->B1_CODFAB+SB1->B1_LOJA,SB1->B1_GRUPO,;	//1 - 06
				SB1->B1_CODCOTL, nPrecoProd ,SB1->B1_UPRC,SB1->B1_UCOM,SB1->B1_MINCUS,SB1->B1_DMINCUS,;											// 7 -12
				SB1->B1_MAXCUS,SB1->B1_DMAXCUS,aProdsPP[nX][4],nQtdeMesAtu,nQtdeMesAnt,nUltPrVenda,dUltDtVenda,;										// 13-19
				aProdsPP[nX][3],aProdsPP[nX][2],If(lMark06,nQuant,0),SB1->B1_SEGUM, {} , Posicione("SA2",1,xFilial("SA2")+ SB1->B1_CODFAB+SB1->B1_LOJA ,"A2_METR") ,;  //20-25
				aProdsPP[nX][nY][9], SB1->B1_TE  })		//26-27
				// inclui no elemento 24 (array vazia na linha acima) sub-array com produtos por filial
				AAdd(aItensProd[nX][24],{cCodFilial,aProdsPP[nX][nY][6],aProdsPP[nX][nY][5],  If(lMark06,aProdsPP[nX][nY][5],0) ,aProdsPP[nX][nY][8],aProdsPP[nX][nY][7], aProdsPP[nX][nY][9] })
				
			Else
				aItensProd[nX][15] := aProdsPP[nX][4]		// Estoque Atual do produto
				aItensProd[nX][16] += nQtdeMesAtu
				aItensProd[nX][17] += nQtdeMesAnt
				aItensProd[nX][26] += aProdsPP[nX][nY][9]  //Entrega Pendente do Produto
				If nUltPrVenda != aItensProd[nX][18]
					aItensProd[nX][18] := nUltPrVenda
					aItensProd[nX][19] := dUltDtVenda
				EndIf
				aItensProd[nX][20] := aProdsPP[nX][3]  //Giro do produto corrente de todas as filiais
				Aadd(aItensProd[nX][24],{cCodFilial,aProdsPP[nX][nY][6],aProdsPP[nX][nY][5],IIf(lMark06,aProdsPP[nX][nY][5],0),;
				aProdsPP[nX][nY][8],aProdsPP[nX][nY][7],aProdsPP[nX][nY][9], SB1->B1_TE  })
			EndIf
		Next nY
		//Soma a quantidade sugerida e valor pela analise por ponto de pedido
		IF nPrecoProd > 0 .or. nTipoDoc = 2		// se tiver preco na tabela ou se for cotação
			nAComprar     += nQuant
			nVlrAComprar  += nQuant * nPrecoProd
		Else
			lSemPreco := .t.
		Endif

	Next nX

	// loop para a criacao do novo Array na ordem correta das informacoes dos Produtos na tela de Pre-Pedido de Compras
	For nZ := 1 to Len(aItensProd)
		
		//Cabecalho -> {Marcacao,"Giro","Sugestão","Pedido","Custo","Pendente","Descrição Produto"}
		
		AAdd(aItensPrePC,{-1,aItensProd[nZ][20],aItensProd[nZ][21],aItensProd[nZ][22],aItensProd[nZ][8],aItensProd[nZ][2],aItensProd[nZ][1],;			//  01 - 07
		aItensProd[nZ][3],aItensProd[nZ][4],aItensProd[nZ][23],aItensProd[nZ][9],aItensProd[nZ][10],aItensProd[nZ][11],;											//  08 - -13
		aItensProd[nZ][12],aItensProd[nZ][13],aItensProd[nZ][14],aItensProd[nZ][5],;																								//  14 - 17
		Posicione("SA2",1,xFilial("SA2")+aItensProd[nZ][5],"A2_NOME"),aItensProd[nZ][15],;																			  		//  18 - 19
		aItensProd[nZ][16],aItensProd[nZ][17],aItensProd[nZ][18],aItensProd[nZ][19], aItensProd[nZ][25], aItensProd[nZ][26], aItensProd[nZ][27] }) 		//  20 - 26
	Next nZ
	
	// Traz os produtos ordenados por Produto ou Fabricante
	If Len(aItensPrePC) > 0
		If nTipoOrd == 1  //Se o BOX ORDEM estiver marcado Produto
			bOrdem	:=  &("{ |x,y| x[7] < y[7]}")  // Ordenar por produto
			aSort(aItensPrePC,,,bOrdem) 
		Else              //Se o BOX ORDEM estiver marcado Fabricante
			bOrdem	:=  &("{ |x,y| x[17]+x[7] < y[17]+y[7]}")  // Ordenar por Fabrica+loja +produto
			aSort(aItensPrePC,,,bOrdem)
		EndIf
	EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarcAll   ºAutor  ³Andre Melo          º Data ³ 14/01/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Marcar todos                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function MarcAll(aLin,lMark)
aEval( aLin , { |x,y| aLin[y,1] := If(lMark,1,-1)})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldSelecaoºAutor  ³Fernando Machima    º Data ³ 14/01/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche o array com as opcoes selecionadas e valida       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldSelecao(aLin1,aLin2,aLin4,aLin5)

Local lRet  := .T.
Local nX
Local lFabrican  := .f.
Local lGrupoPro  := .f.
Local lControle  := .f.
Local lTabPreco  := .f.

aFornec := {}
aDadosFiltro  := {}

If Empty(cFornece) .Or. Empty(cLoja)
	MsgAlert("Selecione os dados de código e loja do fornecedor!")
	Return .F.
EndIf

If nTipoDoc == 1
	aadd(aFornec, { cFornece, cLoja } )
else
	aadd(aFornec, { cFornece, cLoja } )
	If !Empty(cFornece2) .and. !Empty(cLoja2) .and. ( cFornece2+cLoja2 <> cFornece+cLoja )
		aadd(aFornec, { cFornece2, cLoja2 } )
	endif
	
	If !Empty(cFornece3) .and. !Empty(cLoja3) .and. ( cFornece3+cLoja3 <> cFornece+cLoja .and. cFornece3+cLoja3 <> cFornece2+cLoja2 )
		aadd(aFornec, { cFornece3, cLoja3 } )
	endif
Endif

//Armazena os fabricantes selecionados
Aadd(aDadosFiltro,{"SA2",{}})
For nX := 1 to Len(aLin1)
	If aLin1[nX,1] == 1  //Marcado
		Aadd(aDadosFiltro[Len(aDadosFiltro)][2],{aLin1[nX,2]+aLin1[nX,3]})
		lFabrican  := .t.
	EndIf
Next nX
If !lFabrican
	MsgAlert("Obrigatorio selecionar Fabricantes !")
	Return .F.
endif


//Armazena os grupos de produtos selecionados
Aadd(aDadosFiltro,{"SBM",{}})
For nX := 1 to Len(aLin2)
	If aLin2[nX,1] == 1  //Marcado
		Aadd(aDadosFiltro[Len(aDadosFiltro)][2],{aLin2[nX,2]})
		lGrupoPro := .t.
	EndIf
Next nX
If !lGrupoPro
	MsgAlert("Obrigatorio selecionar Grupo de Produtos !")
	Return .F.
endif


//Armazena os grupos de compras selecionados
Aadd(aDadosFiltro,{"LFA",{}})
Aadd(aDadosFiltro[Len(aDadosFiltro)][2],{cCodGrupo})

//Armazena os controles selecionados
Aadd(aDadosFiltro,{"LEO",{}})
For nX := 1 to Len(aLin4)
	If aLin4[nX,1] == 1  //Marcado
		Aadd(aDadosFiltro[Len(aDadosFiltro)][2],{aLin4[nX,2]})
		lControle := .t.
	EndIf
Next nX
If !lControle
	MsgAlert("Obrigatorio selecionar Controles !")
	Return .F.
endif


//Armazena a Tabela de Preços selecionada
Aadd(aDadosFiltro,{"AIA",{}})
For nX := 1 to Len(aLin5)
	If aLin5[nX,1] == 1  //Marcado
		Aadd(aDadosFiltro[Len(aDadosFiltro)][2],{aLin5[nX,2]})
		cTabPreco	:= aLin5[nX,2]
		cCondPagto	:= aLin5[nX,4]

		AIA->( MsSeek(XFILIAL("AIA")+ cFornece+ cLoja+ cTabPreco ) )		
		nAIADESC1	:= AIA->AIA_DESC1
		nAIADESC2	:= AIA->AIA_DESC2
		nAIADESCFI	:= AIA->AIA_DESCFI

		lTabPreco	:= .t.
		exit
	EndIf
Next nX

If !lTabPreco
	MsgAlert("Selecione a Tabela de Preços !")
	Return .F.
endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROPesqQtdºAutor  ³Fernando Machima    º Data ³ 14/01/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa as quantidades dos meses anterior e atual          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DROPesqQtd(cCodProd,cLocPad,nQtdeMesAtu,nQtdeMesAnt,nUltPrVenda,dUltDtVenda,cCodFilial,;
dDataIniAtu,dDataFimAtu,dDataIniAnt,dDataFimAnt)

Local aArea   := GetArea()

nQtdeMesAtu  := 0
nQtdeMesAnt  := 0

//Busca a quantidade das vendas do mes atual
DbSelectArea("SD2")
DbSetOrder(6)   //Codigo+Local+Emissao
DbSeek(cCodFilial+cCodProd+cLocPad+DTOS(dDataIniAtu),.T.)
While !Eof() .And. cCodFilial+cCodProd+cLocPad == SD2->D2_FILIAL+SD2->D2_COD+SD2->D2_LOCAL .And. ;
	DTOS(dDataFimAtu) >= DTOS(SD2->D2_EMISSAO)
	
	If SD2->D2_TIPO != "N"
		DbSkip()
		Loop
	EndIf
	
	nQtdeMesAtu += SD2->D2_QUANT
	
	DbSkip()
End
//Busca preco e data da ultima venda
If nQtdeMesAtu > 0
	DbSkip(-1)
	//Busca pela data da ultima venda
	If IIf(!Empty(dUltDtVenda),DTOS(SD2->D2_EMISSAO) > DTOS(dUltDtVenda),.T.)
		nUltPrVenda  := SD2->D2_PRCVEN
		dUltDtVenda  := SD2->D2_EMISSAO
	EndIf
EndIf

//Busca a quantidade das vendas do mes anterior
DbSeek(cCodFilial+cCodProd+cLocPad+DTOS(dDataIniAnt),.T.)
While !Eof() .And. cCodFilial+cCodProd+cLocPad == SD2->D2_FILIAL+SD2->D2_COD+SD2->D2_LOCAL .And. ;
	DTOS(dDataFimAnt) >= DTOS(SD2->D2_EMISSAO)
	
	If SD2->D2_TIPO != "N"
		DbSkip()
		Loop
	EndIf
	
	nQtdeMesAnt += SD2->D2_QUANT
	
	DbSkip()
End
//Busca preco e data da ultima venda, caso nao tenha encontrado no mes atual
If nUltPrVenda == 0 .And. nQtdeMesAnt > 0
	DbSkip(-1)
	If IIf(!Empty(dUltDtVenda),DTOS(SD2->D2_EMISSAO) > DTOS(dUltDtVenda),.T.)
		nUltPrVenda  := SD2->D2_PRCVEN
		dUltDtVenda  := SD2->D2_EMISSAO
	EndIf
EndIf

//Caso tambem nao tenha encontrado o preco no mes anterior, continua a busca ate encontrar
If nUltPrVenda == 0 .Or. Empty(dUltDtVenda)
	DbSeek(cCodFilial+cCodProd+cLocPad+DTOS(dDatabase),.T.)
	DbSkip(-1)
	If SD2->D2_FILIAL+SD2->D2_COD == cCodFilial+cCodProd
		nUltPrVenda  := SD2->D2_PRCVEN
		dUltDtVenda  := SD2->D2_EMISSAO
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DRODesmarcºAutor  ³Fernando Machima    º Data ³  13/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Desmarca todas as opcoes                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DRODesmarcAll(aLin5)

Local nX

If aLin5[oLbx05:nAt,1] == 1  //Marcado
	For nX := 1 to Len(aLin5)
		If nX != oLbx05:nAt
			aLin5[nX,1] := -1  //Desmarcar
		EndIf
	Next nX
	oLbx05:Refresh()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROCalcGirºAutor  ³Fernando Machima    º Data ³  21/01/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o giro geral e por filial dos produtos em demanda   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DROCalcGiro(aProdsPP,nX,nY,lUltimoFil,nEstAtuAll,nConsDiaAll,nMesAtu,nQtdDiasMes)

Local cCodProd   := ""
Local cCodFilial := ""
Local cCampo     := ""
Local nEstAtuFil := 0  //Estoque atual por filial
Local nConsDiaFil:= 0  //Consumo diario por filial
Local nGiroFil   := 0
Local nGiroAll   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Giro eh a quantidade de dias que o produto vai durar no estoque³
//³Eh calculado pelo estoque atual/media diaria de consumo. A me- ³
//³dia diaria eh o consumo do arq. SB3 dividido pela qtde. de dias³
//³do mes                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SB2->(DbSetOrder(1))
SB3->(DbSetOrder(1))

cCodProd    := aProdsPP[nX][1]
cCodFilial  := aProdsPP[nX][nY][1]
nEstAtuFil  := 0
nConsDiaFil := 0

//Estoque atual de todos os almoxarifados
If SB2->(DbSeek(cCodFilial+cCodProd,.T.))
	While !SB2->(Eof()) .And. cCodFilial+cCodProd == SB2->B2_FILIAL+SB2->B2_COD
		nEstAtuFil += SB2->B2_QATU
		nEstAtuAll += SB2->B2_QATU
		
		SB2->(DbSkip())
	End
EndIf

//Calculo da media diaria de consumo(SB3)
If SB3->(DbSeek(cCodFilial+cCodProd))
	cCampo      := "SB3->B3_Q"+StrZero(nMesAtu,2)
	nConsDiaFil := &(cCampo)/nQtdDiasMes  //Media diaria de consumo
	nConsDiaAll += nConsDiaFil
EndIf

//Calculo do consumo medio diario da filial
nGiroFil       := 0
If nConsDiaFil > 0 .And. nEstAtuFil > 0
	nGiroFil       :=  Round(nEstAtuFil/nConsDiaFil,2)  //Giro da filial, quantidade de dias que o estoque atual suporta
EndIf

//Atualiza o giro da filial
aProdsPP[nX][nY][6] := nGiroFil

//Calculo do consumo medio diario de todas as filiais
If lUltimoFil
	If nConsDiaAll > 0 .And. nEstAtuAll > 0
		nGiroAll  := Round(nEstAtuAll/nConsDiaAll,2)
	EndIf
	aProdsPP[nX][3] := nGiroAll
	aProdsPP[nX][4] := nEstAtuAll	
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SaldoSB2 ³ Autor ³ Eveli Morasco         ³ Data ³ 15/04/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o saldo do arquivo SB2                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := SaldoSB2(ExpL1,ExpL2,ExpD1,ExpL3,ExpN1)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Saldo devolvido pela funcao                        ³±±
±±³          ³ ExpL1 = Flag que indica se chamada da funcao ‚ utilizada p/³±±
±±³          ³ calculo de necessidade. Caso .T. deve considerar quantidade³±±
±±³          ³ a distribuir, pois a mesma apenas nao pode ser utilizada,  ³±±
±±³          ³ porem ja esta em estoque.                                  ³±±
±±³          ³ ExpL2 = Flag que indica se deve substrair o empenho do     ³±±
±±³          ³ saldo a ser retornado.                                     ³±±
±±³          ³ ExpD1 = Data final para filtragem de empenhos. Empenhos ate³±±
±±³          ³ esta data serao considerados no caso de leitura do SD4.    ³±±
±±³          ³ ExpL3 = Flag que indica se deve considerar o saldo de terc ³±±
±±³          ³ eiros em nosso poder ou nao (B2_QTNP).                     ³±±
±±³          ³ ExpL4 = Flag que indica se deve considerar nosso saldo em  ³±±
±±³          ³ poder de terceiros ou nao (B2_QNPT).                       ³±±
±±³          ³ ExpN1 = Qtd empenhada para esse movimento que nao deve ser ³±±
±±³          ³ subtraida                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function DROSaldoSB2(lNecessidade,lEmpenho,dDataFim,lConsTerc,lConsNPT,cAliasSB2,nQtdEmp,nQtdPrj)
Local aAreaAnt   := GetArea()
Local aAreaSC2   := SC2->(GetArea())
Local aAreaSD4   := SD4->(GetArea())
Local aAreaSDC   := SDC->(GetArea())
Local cSeekSDC   := ""
Local cComparaSDC:= ""
Local nEmpenho   := 0
Local nEmpProj   := 0
Local nEmpenhoD4 := 0
Local nRet       := 0
Local lProcessD4 := .T.
Local lEmpPrj    := .F.

lEmpPrj := (nQtdPrj > 0)

If (cAliasSB2)->B2_STATUS <> "2"
	nEmpenho := (cAliasSB2)->(B2_QEMP)
	nEmpProj := (cAliasSB2)->(B2_QEMPPRJ)
	If ! lEmpPrj .And. lEmpenho .And. ValType(dDataFim) == "D" .And. (GetMV("MV_CONDEMP") == "S")
		// Varre empenhos ate a data estipulada
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSelectArea("SDC")
		dbSetOrder(2)
		dbSelectArea("SD4")
		dbSetOrder(3)
		dbSeek(cCodFilial+(cAliasSB2)->B2_COD+(cAliasSB2)->B2_LOCAL)
		nEmpenhoD4:=0
		While lProcessD4 .And. !Eof() .And. D4_FILIAL+D4_COD+D4_LOCAL == cCodFilial+(cAliasSB2)->B2_COD+(cAliasSB2)->B2_LOCAL
			// Se existe algum empenho com lote preenchido, assume empenho do SB2
			// pois os saldos dos lotes ja estao comprometidos com a colocacao
			// do empenho
			If Rastro(D4_COD) .And. !Empty(D4_LOTECTL+D4_NUMLOTE)
				lProcessD4:=.F.
			EndIf
			// Se existe algum empenho com localizacao, assume empenho do SB2
			// pois os saldos das localizacoes ja estao comprometidos com a colocacao
			// do empenho
			If lProcessD4 .And. Localiza(D4_COD)
				cSeekSDC:=cCodFilial+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT
				cComparaSDC:="DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT"
				dbSelectArea("SDC")
				dbSeek(cSeekSDC)
				While lProcessD4 .And. !Eof() .And. cSeekSDC == &(cComparaSDC)
					If QtdComp(DC_QUANT) > QtdComp(0)
						lProcessD4:=.F.
					EndIf
					dbSkip()
				End
			EndIf
			dbSelectArea("SD4")
			// Soma quantidade do empenho
			If QtdComp(D4_QUANT) > QtdComp(0) .And. D4_DATA <= dDataFim .And. ;
				SC2->(dbSeek(cCodFilial+SD4->D4_OP)) .And. SC2->C2_TPOP $ " F"
				nEmpenhoD4+=D4_QUANT
			EndIf
			dbSkip()
		End
		If lProcessD4
			nEmpenho:=nEmpenhoD4
		EndIf
		RestArea(aAreaSC2)
		RestArea(aAreaSD4)
		RestArea(aAreaSDC)
	EndIf
	// Caso baixe empenho nao subtrai a qtd empenhada para esse item
	If ! lEmpPrj
		nEmpenho-=nQtdEmp
		nEmpenho:=Max(nEmpenho,0)
	Else
		nEmpProj-=nQtdPrj
		nEmpProj:=Max(nEmpProj,0)
	EndIf
	// Calcula a qtd a ser retornada
	nRet:=QtdComp((cAliasSB2)->B2_QATU-(cAliasSB2)->B2_RESERVA-If(lEmpenho,nEmpenho,0)-IF(lNecessidade,0,(cAliasSB2)->B2_QACLASS)-(cAliasSB2)->B2_QEMPSA-If(lEmpenho,nEmpProj,0)-AvalQtdPre("SB2",1)-If(lConsTerc,0,(cAliasSB2)->B2_QTNP)+If(lConsNPT,(cAliasSB2)->B2_QNPT,0))
	RestArea(aAreaAnt)
EndIf
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROShowGrpºAutor  ³Fernando Machima    º Data ³  26/01/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra as filiais do grupo de compras                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DROShowGrp(aLinGrCmp)

Local cSeekFil  := '"' + xFilial("LFU") + aLinGrCmp[oLbxGrCmp:nAT][2]+'"'
Local cWhileFil := "!EOF() .And. LFU_FILIAL+LFU_CODCOM == " + cSeekFil
Local aRetFil   := LocxGrid("LFU",cWhileFil,,.T.,".F.",cSeekFil,1,{"LFU_CODFIL","LFU_NOME"},)  //Filiais do grupo de compras
Local aCabFil   := AClone(aRetFil[3])
Local aLinFil   := AClone(aRetFil[5])
Local aTamFil   := AClone(aRetFil[4])
Local aCpoFil   := AClone(aRetFil[1])
Local oDlgFil

DEFINE MSDIALOG oDlgFil TITLE "Filiais do Grupo "+aLinGrCmp[oLbxGrCmp:nAT][3] FROM 18,40 TO 30,90

oLbxFil := TwBrowse():New(011,000,000,000,,aCabFil,aTamFil,oDlgFil,,,,,,,,,,,,.F.,,.T.,,.T.,,,)
oLbxFil:nHeight	:= (__DlgHeight(oDlgFil)*2) - 8
oLbxFil:nWidth		:= __DlgWidth(oDlgFil)*2
oLbxFil:lColDrag	:= .T.
oLbxFil:nFreeze	:= 1
oLbxFil:SetArray(aLinFil)
oLbxFil:bLine		:= LocxBLin('oLbxFil',aCpoFil,.T.)

ACTIVATE MSDIALOG oDlgFil ON INIT EnchoiceBar(oDlgFil,{|| oDlgFil:End()},{|| oDlgFil:End()},,)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROSelGrupºAutor  ³Fernando Machima    º Data ³  26/01/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar a selecao do grupo de compras                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DROSelGrupo(aFiliais,aLinGrCmp)

Local lRet  := .F.
Local nX

LFU->(DbSetOrder(1))
For nX := 1 to Len(aLinGrCmp)
	If aLinGrCmp[nX][1] == 1
		
		lRet  := .T.
		cCodGrupo  := aLinGrCmp[nX][2]
		cFilEntreg := IF(aLinGrCmp[nX][4] == "S", aLinGrCmp[nX][5] , "")
		lAglutina  :=  IF(aLinGrCmp[nX][4] == "S",  .T.   ,  .F.  )
		
		LFU->(DbSeek(xFilial("LFU")+aLinGrCmp[nX][2]))
		While !LFU->(Eof()) .And. xFilial("LFU")+aLinGrCmp[nX][2] == LFU->LFU_FILIAL+LFU->LFU_CODCOM
			Aadd(aFiliais,LFU->LFU_CODFIL)
			LFU->(DbSkip())
		End
	EndIf
Next nX

If !lRet
	MsgAlert("Não foi selecionado nenhum grupo de compras!")
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³atualiVar ºAutor  ³Geronimo B. Alves   º Data ³ 06/03/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza variaveis do get de fornecedores                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function atualiVar(cNome2,cNome3)

If nTipoDoc == 1
	cFornece2    := Space(TamSX3("A2_COD")[1])
	cLoja2       := Space(TamSX3("A2_LOJA")[1])
	cNome2		 := Space(40)
	cFornece3    := Space(TamSX3("A2_COD")[1])
	cLoja3       := Space(TamSX3("A2_LOJA")[1])
	cNome3		 := Space(40)
endif

oGet5:Refresh()
oGet6:Refresh()
oGet7:Refresh()
oGet8:Refresh()
oGet9:Refresh()
oGet10:Refresh()
oGet11:Refresh()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DRORunLbx5ºAutor  ³Thiago Honorato	 º Data ³ 22/02/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o BOX Tabela de Preços de acordo com o Fornecedor  º±±
±±º		     ³escolhido.												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DRORunLbx5(oLbx05,cChave,aLin5)

Local cSeek5  := ""
Local cWhile5 := ""
Local aRet5   := {}
Local aCpo5   := {}
Local lRet		:= .T.

// Se o Codigo do Fornecedor + Codigo da Loja estiverem vazios, traz todas as Tabelas de Precos.
// Para cotacao necessito indicar a tabela de preço para obter a condição de pagamento e colocar valores na tela (embora os valores não sejam gravados) .
If Empty(cChave)	 
	cSeek5  := '"' + xFilial("AIA") + '"'
	cWhile5 := "!EOF() .And. AIA_FILIAL == " + cSeek5
Else//caso contrario, traz as Tabelas de Precos relacionadas ao Fornecedor indicado
	If DROVldFor(cChave)
		cSeek5  := '"' + xFilial("AIA") + cChave + '"'
		cWhile5 := "!EOF() .And. AIA_FILIAL + AIA_CODFOR + AIA_LOJFOR == " + cSeek5
	Endif
EndIf
aRet5   := LocxGrid("AIA",cWhile5,,.T.,".F.",cSeek5,1,{"AIA_CODTAB","AIA_DESCRI","AIA_CONDPG" },)
aCpo5   := AClone(aRet5[1])

aLin5 := AClone(aRet5[5])
oLbx05:SetArray(aLin5)
oLbx05:bLine := LocxBLin('oLbx05',aCpo5,.T.)

oLbx05:Refresh()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROVldFor ºAutor  ³Thiago P.Honorato   º Data ³  22/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o Codigo + Loja digitados existe na tabela SA2 º±±
±±º		     ³ Caso exista, verifca se eh um Fornecedor ou Fabricante     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DROVldFor(cChave)		// cChave = cFornece + cLoja
Local lRet     := .T.
Local lFornec  := .T.
Local cText1   :=	'Fornecedor não existe.                               '+ 'Verifique o Código do Fornecedor e/ou Codigo da  Loja. '
Local cText3    :=  'O Mesmo Código de Fornecedor e Código de Loja foi informado 2 vezes      '+'Favor corrigi-los.'
Local aAreaSa2 := {}

lFornec   := !Empty(cChave) // verifica se o Codigo + Loja estao vazios

If lFornec // se nao estiverem vazios
	aAreaSA2 := SA2->(GetArea())//coloca SA2 como area atual
	If SA2->(!DbSeek(xFilial("SA2")+cChave))// verifica se o codigo do fornecedor + codigo da loja existem em SA2
		MsgAlert(cText1)
		lRet := .F.
	Endif
Endif

If nTipoDoc == 2
	If !Empty(cFornece2) .and. !Empty(cLoja2) .and. ( cFornece2+cLoja2 == cFornece+cLoja  .or. cFornece2+cLoja2 == cFornece3+cLoja3)
		MsgAlert(cText3)
		lRet := .T.
	endif
	
	If !Empty(cFornece3) .and. !Empty(cLoja3) .and. ( cFornece3+cLoja3 == cFornece+cLoja )
		MsgAlert(cText3)
		lRet := .T.
	endif
endif

//Restaurando as Areas
If !Empty(aAreaSA2)
	SA2->(RestArea(aAreaSA2))
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ProdFilialºAutor  ³Geronimo B. Alves   º Data ³ 01/03/05    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Alimenta a array aProdFilial (para digitacao da qtd. pedida º±±
±±º          ³por produto/filial                                          º±±
±±º          ³Calcula/insere quantidade pendente (a entregar) nas arrays  º±±
±±º          ³aProdFilial e  aItensProd                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProdFili(aProdFilial,lMark06)
Local _nI, _nJ
Local _nMark

for _nI := 1 to len(aItensProd)
	aadd(aProdFilial,{ aItensProd[_nI,1], aItensProd[_nI,2], {} } )
	for _nJ = 1 to len(aItensProd[_nI,24])
		_nMark		:= if( aItensProd[_nI,24,_nJ, 4] > 0 , 1 , -1 )
		aadd(aProdFilial[_Ni,3],{ _nMark ,  aItensProd[_nI,24,_nJ, 2], aItensProd[_nI,24,_nJ, 3], aItensProd[_nI,24,_nJ, 4], aItensProd[_nI,24,_nJ, 7], aItensProd[_nI,24,_nJ, 5], aItensProd[_nI,24,_nJ, 6], aItensProd[_nI,24,_nJ, 1]   } )
		//                                  Marca     Giro Filial                          Necessidade Filial          Qtd Pedida                      Qtd. Pendente (a Entregar)   Nome Filial                  Giro Maximo Filial (sem uso)       Codigo Filial
	Next
Next

return .T.