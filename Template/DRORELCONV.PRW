#INCLUDE "PROTHEUS.CH"

Static oTblTmp := NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³DRORELCONVº Autor ³ Fernando Machima   º Data ³  14/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de fechamento de convenio                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºFernando M.   ³14/12/04³xxxxxx³Inicio do desenvolvimento               º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DRORELCONV
Local cDesc1         := "Este programa tem como objetivo imprimir o relatorio "
Local cDesc2         := "de Fechamento de Convênio de acordo com os parametros " 
Local cDesc3         := "informados pelo usuario."
Local titulo         := "Fechamento de Convênio"
Local aOrd           := ""
Local Cabec1         := ""
Local Cabec2         := ""
Local cPerg          := "DROREL"
Local lUsaQuery      := .F.  //Verifica se o sistema esta trabalhando com Query

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "DRORELCONV" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "DRORELCONV" // Coloque aqui o nome do arquivo usado para impressao em disco

/*
//³Parametros do relatorio: DROREL ³
//³                                ³
//³MV_PAR01 -> Filial de          ?³
//³MV_PAR02 -> Filial ate         ?³
//³MV_PAR03 -> Emp. Convenio de   ?³
//³MV_PAR04 -> Loja Convenio de   ?³
//³MV_PAR05 -> Emp. Convenio ate  ?³
//³MV_PAR06 -> Loja Convenio ate  ?³
//³MV_PAR07 -> Dt. Emissao de     ?³
//³MV_PAR08 -> Dt. Emissao ate    ?³
//³MV_PAR09 -> Dt. Vencto de      ?³
//³MV_PAR10 -> Dt. Vencto ate     ?³
//³MV_PAR11 -> Documento de       ?³
//³MV_PAR12 -> Documento ate      ?³
//³MV_PAR13 -> Visualizacao       ?³
*/
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint("SD2",NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,"SD2")

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

#IFDEF TOP
	If TcSrvType() != "AS/400"
		lUsaQuery := .T.
	EndIf
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao dos dados para impressao.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Processa({|| DroRelGeraTmp(lUsaQuery)}, "Aguarde" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do relatorio.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| DroRelImprime(Cabec1,Cabec2,Titulo,lUsaQuery) },Titulo)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³DroRelGeraº Autor ³ Fernando Machima   º Data ³  14/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Gera filtro/arquivo temporario para uso do relatorio.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DroRelGeraTmp(lUsaQuery)

Local cQuery     := ""	 //Query para montagem do filtro
Local cIndice    := ""							
Local cNomeEmp   := ""
Local cChave     := ""
Local cLojConv   := "" 		   
Local cCodFilial := ""
Local aCampos    := {}	 //Campos da estrutura DBF
Local aTam       := {}   //Retorno da funcao TamSX3 para campos DBF
Local aStruTRB   := {}   //Array com os campos do TRB do tipo Data e Numerico para o comando TCSetField
Local aAreaSA1   := {} 
Local nX
Local nVlrTotNF  := 0
Local nVlrTotConv:= 0    //Valor total por conveniado 
Local nIndice    
 
If lUsaQuery
	ProcRegua( 4 )
	
	IncProc("Selecionando registros para impressão...")
	
	DroRelaStru(@aStruTRB)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cabecalho   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If mv_par13 == 1  
	   cQuery := "SELECT "	
	   cQuery += "SF2.F2_FILIAL   FILIAL     ,"
	   cQuery += "SF2.F2_EMISSAO  EMISSAO    ,"
	   cQuery += "SF2.F2_DOC      NFISCAL    ,"
	   cQuery += "SF2.F2_SERIE    SERIE      ,"
	   cQuery += "SF2.F2_VALBRUT  VLRTOTNF   ,"
	   cQuery += "SA1.A1_COD      CODCONV    ,"	  //Codigo do conveniado   
	   cQuery += "SA1.A1_LOJA     LOJCONV    ,"	  //Loja do conveniado 	   
	   cQuery += "SA1.A1_NOME     CONVENIADO ,"   //Nome do conveniado
	   cQuery += "SA1.A1_MATRICU  MATRICULA  ,"	   	   	
	   cQuery += "SA1.A1_EMPCONV  EMPCONVENI ,"	  //Codigo da empresa de convenio
	   cQuery += "SA1.A1_LOJCONV  LOJCONVENI ,"	  //Loja da empresa de convenio  	   		   	   
	   cQuery += "SA1EMP.A1_NOME  NOMEEMP     "	  //Nome da empresa de convenio  	   		   	   	   
		
	   cQuery += " FROM "+RetSQLName("SF2")+" SF2, "
	   cQuery += RetSQLName("SA1")+" SA1, "
	   cQuery += RetSQLName("SA1")+" SA1EMP, "	   //SA1 da empresa de convenio
	   cQuery += RetSQLName("SE1")+" SE1 "

	   cQuery += "WHERE "
	   
	   //SA1      
	   cQuery += "SA1.A1_FILIAL = '"+ xFilial( "SA1" ) +"' "	   
	   cQuery += "AND SA1.A1_TPCONVE = '3' "	   	   //Conveniado
	   cQuery += "AND SA1.A1_EMPCONV BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "	   

	   //SA1 Conveniado x SA1 Empresa de convenio      
	   cQuery += "AND SA1EMP.A1_FILIAL = '"+ xFilial( "SA1" ) +"' "	   
	   cQuery += "AND SA1.A1_EMPCONV = SA1EMP.A1_COD  "
	   cQuery += "AND SA1.A1_LOJCONV = SA1EMP.A1_LOJA "
	   
	   //SF2 x SA1
	   cQuery += "AND SA1.A1_COD = SF2.F2_CLIENTE "
	   cQuery += "AND SA1.A1_LOJA = SF2.F2_LOJA "
	  
	   //SF2
	   cQuery += "AND SF2.F2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	   cQuery += "AND SF2.F2_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	   cQuery += "AND SF2.F2_DOC BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "	   
	   
	   //SF2 x SE1	   	   
	   cQuery += "AND SF2.F2_SERIE = SE1.E1_PREFIXO "
	   cQuery += "AND SF2.F2_DOC = SE1.E1_NUM "
	   cQuery += "AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "
	   cQuery += "AND SF2.F2_LOJA = SE1.E1_LOJA "

	   //SE1	   		
	   cQuery += "AND SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	   cQuery += "AND SE1.E1_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	   cQuery += "AND SE1.E1_VENCTO BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"' "	   
	   cQuery += "AND SE1.E1_NUM BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "	   
	   cQuery += "AND SE1.E1_TIPO = 'FI ' "	   

	   //SE1 x SA1
	   cQuery += "AND SA1.A1_COD = SE1.E1_CLIENTE "
	   cQuery += "AND SA1.A1_LOJA = SE1.E1_LOJA "
	   	
	   cQuery += "AND SF2.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SE1.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SA1.D_E_L_E_T_ <> '*' "
			
       cQuery += "ORDER BY EMPCONVENI, LOJCONVENI, CODCONV, LOJCONV, EMISSAO, SERIE, NFISCAL "

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Itens       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	ElseIf mv_par13 == 2  
	   cQuery := "SELECT "	
	   cQuery += "SF2.F2_FILIAL   FILIAL     ,"
	   cQuery += "SF2.F2_EMISSAO  EMISSAO    ,"
	   cQuery += "SF2.F2_DOC      NFISCAL    ,"
	   cQuery += "SF2.F2_SERIE    SERIE      ,"
	   cQuery += "SF2.F2_VALBRUT  VLRTOTNF   ,"
	   cQuery += "SA1.A1_COD      CODCONV    ,"	  //Codigo do conveniado   
	   cQuery += "SA1.A1_LOJA     LOJCONV    ,"	  //Loja do conveniado 	   
	   cQuery += "SA1.A1_NOME     CONVENIADO ,"   //Nome do conveniado
	   cQuery += "SA1.A1_MATRICU  MATRICULA  ,"	   	   	
	   cQuery += "SA1.A1_EMPCONV  EMPCONVENI ,"	  //Codigo da empresa de convenio
	   cQuery += "SA1.A1_LOJCONV  LOJCONVENI ,"	  //Loja da empresa de convenio  	   		   	   
	   cQuery += "SA1EMP.A1_NOME  NOMEEMP    ,"	  //Nome da empresa de convenio  	   		   	   	   
	   cQuery += "SD2.D2_COD      CODPROD    ,"	   	   		   
	   cQuery += "SD2.D2_ITEM     ITEM       ,"	   	   		   	   	   
	   cQuery += "SD2.D2_QUANT    QUANTIDADE ,"	   	   		   	   
	   cQuery += "SD2.D2_PRCVEN   VLRUNIT    ,"	   	   		   	   
	   cQuery += "SD2.D2_TOTAL    VLRTOTIT   ,"	   	   		   	   
	   cQuery += "SB1.B1_DESC     DESCPROD   "	   	   		   	   
		
	   cQuery += " FROM "+RetSQLName("SF2")+" SF2, "
	   cQuery += RetSQLName("SA1")+" SA1   , "
	   cQuery += RetSQLName("SA1")+" SA1EMP, "	   //SA1 da empresa de convenio
	   cQuery += RetSQLName("SE1")+" SE1   ,"
	   cQuery += RetSQLName("SD2")+" SD2   ,"
	   cQuery += RetSQLName("SB1")+" SB1    "	   	   

	   cQuery += "WHERE "
	   
	   //SA1      
	   cQuery += "SA1.A1_FILIAL = '"+ xFilial( "SA1" ) +"' "	   
	   cQuery += "AND SA1.A1_TPCONVE = '3' "	   	   //Conveniado
	   cQuery += "AND SA1.A1_EMPCONV BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "	   

	   //SA1 Conveniado x SA1 Empresa de convenio      
	   cQuery += "AND SA1EMP.A1_FILIAL = '"+ xFilial( "SA1" ) +"' "	   
	   cQuery += "AND SA1.A1_EMPCONV = SA1EMP.A1_COD  "
	   cQuery += "AND SA1.A1_LOJCONV = SA1EMP.A1_LOJA "
	   
	   //SF2 x SA1
	   cQuery += "AND SA1.A1_COD = SF2.F2_CLIENTE "
	   cQuery += "AND SA1.A1_LOJA = SF2.F2_LOJA "
	  
	   //SF2
	   cQuery += "AND SF2.F2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	   cQuery += "AND SF2.F2_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	   cQuery += "AND SF2.F2_DOC BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "	   
	   
	   //SF2 x SE1	   	   
	   cQuery += "AND SF2.F2_SERIE = SE1.E1_PREFIXO "
	   cQuery += "AND SF2.F2_DOC = SE1.E1_NUM "
	   cQuery += "AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "
	   cQuery += "AND SF2.F2_LOJA = SE1.E1_LOJA "

	   //SE1	   		
	   cQuery += "AND SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	   cQuery += "AND SE1.E1_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	   cQuery += "AND SE1.E1_VENCTO BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"' "	   
	   cQuery += "AND SE1.E1_NUM BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "	   
	   cQuery += "AND SE1.E1_TIPO = 'FI ' "	   

	   //SE1 x SA1
	   cQuery += "AND SA1.A1_COD = SE1.E1_CLIENTE "
	   cQuery += "AND SA1.A1_LOJA = SE1.E1_LOJA "
       
       //SF2 x SD2
	   cQuery += "AND SF2.F2_DOC = SD2.D2_DOC "
	   cQuery += "AND SF2.F2_SERIE = SD2.D2_SERIE "

       //SD2 x SB1
	   cQuery += "AND SD2.D2_COD = SB1.B1_COD "	   	
	   
	   cQuery += "AND SF2.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SE1.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SA1.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SD2.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
		
	   cQuery += "ORDER BY EMPCONVENI, LOJCONVENI, CODCONV, LOJCONV, EMISSAO, SERIE, NFISCAL "
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Total       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	ElseIf mv_par13 == 3  
	   cQuery := "SELECT "	
	   cQuery += "SF2.F2_FILIAL   FILIAL     ,"
	   cQuery += "SUM(SE1.E1_VALOR)  VLRTOT  ,"   //Considera do SE1 para os casos em que uma NF gera mais de um titulo
	   cQuery += "SA1.A1_COD      CODCONV    ,"	  //Codigo do conveniado   
	   cQuery += "SA1.A1_LOJA     LOJCONV    ,"	  //Loja do conveniado 	   
	   cQuery += "SA1.A1_NOME     CONVENIADO ,"   //Nome do conveniado
	   cQuery += "SA1.A1_MATRICU  MATRICULA  ,"	   	   	
	   cQuery += "SA1.A1_EMPCONV  EMPCONVENI ,"	  //Codigo da empresa de convenio
	   cQuery += "SA1.A1_LOJCONV  LOJCONVENI ,"	  //Loja da empresa de convenio  	   		   	   
	   cQuery += "SA1EMP.A1_NOME  NOMEEMP     "	  //Nome da empresa de convenio  	   		   	   	   
	   
		
	   cQuery += " FROM "+RetSQLName("SF2")+" SF2, "
	   cQuery += RetSQLName("SA1")+" SA1, "
	   cQuery += RetSQLName("SA1")+" SA1EMP, "	   //SA1 da empresa de convenio
	   cQuery += RetSQLName("SE1")+" SE1 "

	   cQuery += "WHERE "
	   
	   //SA1      
	   cQuery += "SA1.A1_FILIAL = '"+ xFilial( "SA1" ) +"' "	   
	   cQuery += "AND SA1.A1_TPCONVE = '3' "	   	   //Conveniado
	   cQuery += "AND SA1.A1_EMPCONV BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "	   

	   //SA1 Conveniado x SA1 Empresa de convenio      
	   cQuery += "AND SA1EMP.A1_FILIAL = '"+ xFilial( "SA1" ) +"' "	   
	   cQuery += "AND SA1.A1_EMPCONV = SA1EMP.A1_COD  "
	   cQuery += "AND SA1.A1_LOJCONV = SA1EMP.A1_LOJA "
	   
	   //SF2 x SA1
	   cQuery += "AND SA1.A1_COD = SF2.F2_CLIENTE "
	   cQuery += "AND SA1.A1_LOJA = SF2.F2_LOJA "
	  
	   //SF2
	   cQuery += "AND SF2.F2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	   cQuery += "AND SF2.F2_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	   cQuery += "AND SF2.F2_DOC BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "	   
	   
	   //SF2 x SE1	   	   
	   cQuery += "AND SF2.F2_SERIE = SE1.E1_PREFIXO "
	   cQuery += "AND SF2.F2_DOC = SE1.E1_NUM "
	   cQuery += "AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "
	   cQuery += "AND SF2.F2_LOJA = SE1.E1_LOJA "

	   //SE1	   		
	   cQuery += "AND SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	   cQuery += "AND SE1.E1_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	   cQuery += "AND SE1.E1_VENCTO BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"' "	   
	   cQuery += "AND SE1.E1_NUM BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "	   
	   cQuery += "AND SE1.E1_TIPO = 'FI ' "	   

	   //SE1 x SA1
	   cQuery += "AND SA1.A1_COD = SE1.E1_CLIENTE "
	   cQuery += "AND SA1.A1_LOJA = SE1.E1_LOJA "
	   	
	   cQuery += "AND SF2.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SE1.D_E_L_E_T_ <> '*' "
	   cQuery += "AND SA1.D_E_L_E_T_ <> '*' "

	   cQuery += "GROUP BY "           //Agrupamento por conveniado
	   cQuery += "SA1.A1_COD,     " 
	   cQuery += "SA1.A1_LOJA,    "
	   cQuery += "SF2.F2_FILIAL,  " 
	   cQuery += "SA1.A1_NOME,    "
	   cQuery += "SA1.A1_MATRICU, "	   
	   cQuery += "SA1.A1_EMPCONV, "	   	   	   
	   cQuery += "SA1.A1_LOJCONV, "
	   cQuery += "SA1EMP.A1_NOME  "
	   
	   cQuery += "ORDER BY EMPCONVENI, LOJCONVENI, CODCONV, LOJCONV"		
	EndIf   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o tratamento/compatibilidade com o Top Connect    		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cQuery := ChangeQuery(cQuery)
		    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o ALIAS do arquivo temporario                     		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
	
	For nX := 1 To Len(aStruTRB)
		TcSetField("TRB",aStruTRB[nX,1],aStruTRB[nX,2],aStruTRB[nX,3],aStruTRB[nX,4])
	Next nX	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando Array aCampos com a estrutura do DBF         		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam := TamSX3("F2_FILIAL")
	AAdd( aCampos, {"FILIAL","C",aTam[1],aTam[2]} )

	aTam := TamSX3("F2_EMISSAO")
	AAdd( aCampos, {"EMISSAO","D",aTam[1],aTam[2]} )

	aTam := TamSX3("F2_DOC")
	AAdd( aCampos, {"NFISCAL","C",aTam[1],aTam[2]} )

	aTam := TamSX3("F2_SERIE")
	AAdd( aCampos, {"SERIE","C",aTam[1],aTam[2]} )

	aTam := TamSX3("F2_VALBRUT")
	AAdd( aCampos, {"VLRTOTNF","N",aTam[1],aTam[2]} )
	AAdd( aCampos, {"VLRTOT"  ,"N",aTam[1],aTam[2]} )	
	
	aTam := TamSX3("A1_COD")
	AAdd( aCampos, {"CODCONV","C",aTam[1],aTam[2]} )

	aTam := TamSX3("A1_LOJA")
	AAdd( aCampos, {"LOJCONV","C",aTam[1],aTam[2]} )

	aTam := TamSX3("A1_NOME")
	AAdd( aCampos, {"CONVENIADO","C",aTam[1],aTam[2]} )

	aTam := TamSX3("A1_MATRICU")
	AAdd( aCampos, {"MATRICULA","C",aTam[1],aTam[2]} )

	aTam := TamSX3("A1_EMPCONV")
	AAdd( aCampos, {"EMPCONVENI","C",aTam[1],aTam[2]} )

	aTam := TamSX3("A1_LOJCONV")
	AAdd( aCampos, {"LOJCONVENI","C",aTam[1],aTam[2]} )

	aTam := TamSX3("A1_NOME")
	AAdd( aCampos, {"NOMEEMP","C",aTam[1],aTam[2]} )

	aTam := TamSX3("D2_COD")
	AAdd( aCampos, {"CODPROD","C",aTam[1],aTam[2]} )
	
	aTam := TamSX3("D2_ITEM")
	AAdd( aCampos, {"ITEM","C",aTam[1],aTam[2]} )
	
	aTam := TamSX3("D2_QUANT")
	AAdd( aCampos, {"QUANTIDADE","N",aTam[1],aTam[2]} )

	aTam := TamSX3("D2_PRCVEN")
	AAdd( aCampos, {"VLRUNIT","N",aTam[1],aTam[2]} )

	aTam := TamSX3("D2_TOTAL")
	AAdd( aCampos, {"VLRTOTIT","N",aTam[1],aTam[2]} )

	aTam := TamSX3("B1_DESC")
	AAdd( aCampos, {"DESCPROD","C",aTam[1],aTam[2]} )	
	
	//³ Criando estrutura Temporaria³
	oTblTmp := LjCrTmpTbl("TRB", aCampos, {"FILIAL+EMPCONVENI+LOJCONVENI+CODCONV+CODCONV+EMISSAO"})
	dbSelectArea( "TRB" )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indexando arquivos.                                   		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	dbSelectArea( "SA1" )
	dbSetOrder( 1 )
	
	dbSelectArea( "SF2" )
	dbSetOrder( 1 )
		
	dbSelectArea( "SE1" )
	dbSetOrder( 1 )

	dbSelectArea( "SB1" )
	dbSetOrder( 1 )

	dbSelectArea( "SD2" )
	dbSetOrder( 3 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecionando os registros para filtro no arquivo.     		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SD2->D2_FILIAL >= '"+MV_PAR01+"' .And. SD2->D2_FILIAL <= '"+MV_PAR02+"' .And. "
	cQuery += "DtoS(SD2->D2_EMISSAO)  >= '"+DtoS(MV_PAR07)+"' .And. DtoS(SD2->D2_EMISSAO) <= '"+DtoS(MV_PAR08)+"' .And. "
	cQuery += "SD2->D2_DOC >= '"+MV_PAR11+"' .And. SD2->D2_DOC <= '"+MV_PAR12+"'"
	
	cIndice := CriaTrab( NIL, .F. )
	cChave  := "D2_FILIAL+D2_CLIENTE+D2_LOJA"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtrando orcamento conforme informacoes do parametro.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IndRegua("SD2",cIndice,cChave,,cQuery)
	nIndice := RetIndex("SD2")
	dbSetIndex(cIndice+OrdBagExT())
	dbSetOrder(nIndice+1)	
	dbGotop()
	
	ProcRegua( Reccount() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gerando arquivo temporario.                           		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !Eof()
		
		IncProc("Selecionando registros para impressão...")
		
		If !SA1->( MsSeek( xFilial( "SA1" ) + SD2->D2_CLIENTE + SD2->D2_LOJA ) )
			dbSkip()
			Loop
		EndIf
						
		If !SF2->( MsSeek( xFilial( "SF2" ) + SD2->D2_DOC + SD2->D2_SERIE ) )
			dbSkip()
			Loop
		EndIf

		If !SE1->( MsSeek( xFilial( "SE1" ) + SD2->D2_SERIE + SD2->D2_DOC ) )
			dbSkip()
			Loop
		EndIf

		If !SB1->( MsSeek( xFilial( "SB1" ) + SD2->D2_COD ) )
			dbSkip()
			Loop
		EndIf
		
		If SA1->A1_TPCONVE != "3"
		   DbSkip()
		   Loop 		
		EndIf   
		
		If Empty(SA1->A1_EMPCONV) .Or. Empty(+SA1->A1_LOJCONV)
		   DbSkip()
		   Loop 
		EndIf  
		
		//Filtro para verificar se a empresa de convenio esta no intervalo
		If SA1->A1_EMPCONV+SA1->A1_LOJCONV  < mv_par03+mv_par04 .Or. ;
		   SA1->A1_EMPCONV+SA1->A1_LOJCONV  > mv_par05+mv_par06
		   DbSkip()
		   Loop
		EndIf   
		
		If Dtos(SE1->E1_VENCTO) < Dtos(mv_par09) .Or. Dtos(SE1->E1_VENCTO) > Dtos(mv_par10)
		   DbSkip()
		   Loop
		EndIf   

		aAreaSA1  := SA1->(GetArea())				
		If SA1->(DbSeek(xFilial("SA1")+SA1->A1_EMPCONV+SA1->A1_LOJCONV))
		   cNomeEmp  := SA1->A1_NOME
		EndIf   
		SA1->(RestArea(aAreaSA1))
		
		//Utilizado para impressao do cabecalho
		nVlrTotNF   := SF2->F2_VALBRUT
		cCodFilial  := SD2->D2_FILIAL
		
		If mv_par13 == 3  //Total
		   cConveniado  := SD2->D2_CLIENTE
		   cLojConv     := SD2->D2_LOJA		   
		   cCodFilial   := SD2->D2_FILIAL
		   nVlrTotConv  := 0
		   While !Eof() .And. cCodFilial == SD2->D2_FILIAL .And. cConveniado+cLojConv == ;
		      SD2->D2_CLIENTE+SD2->D2_LOJA
		   
		      nVlrTotConv  += SD2->D2_TOTAL		      
		      
		      DbSkip()
		   End
		   //Retorna uma posicao porque o skip e executado abaixo
		   DbSkip(-1)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravando Arquivo Temporario.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		dbSelectArea( "TRB" )
		RecLock( "TRB", .T. )		
		Replace FILIAL         With cCodFilial
		Replace CODCONV        With SA1->A1_COD
		Replace LOJCONV        With SA1->A1_LOJA
		Replace CONVENIADO     With SA1->A1_NOME
		Replace MATRICULA      With SA1->A1_MATRICU		
		Replace EMPCONVENI     With SA1->A1_EMPCONV
		Replace LOJCONVENI     With SA1->A1_LOJCONV		
		Replace NOMEEMP        With cNomeEmp
		Replace VLRTOT         With nVlrTotConv
		If mv_par13 == 1 .Or. mv_par13 == 2
		   Replace EMISSAO        With SD2->D2_EMISSAO
		   Replace NFISCAL        With SD2->D2_DOC
		   Replace SERIE          With SD2->D2_SERIE
		   Replace VLRTOTNF       With nVlrTotNF		
		   Replace CODPROD        With SD2->D2_COD
		   Replace ITEM           With SD2->D2_ITEM
		   Replace QUANTIDADE     With SD2->D2_QUANT
		   Replace VLRUNIT        With SD2->D2_PRCVEN
		   Replace VLRTOTIT       With SD2->D2_TOTAL
		   Replace DESCPROD       With SB1->B1_DESC
		EndIf   
		MsUnlock()
		
		dbSelectArea( "SD2" )
		dbSkip()
	EndDo
	
	//³Apagando indice temporario
	FErase( cIndice + OrdBagExt() )
	RetIndex( "SD2" )
		
	dbSelectArea( "TRB" )
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³DroRelImprº Autor ³ Fernando Machima   º Data ³  14/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Montagem e impressao do relatorio.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DroRelImprime(Cabec1,Cabec2,Titulo,lUsaQuery)
Local cEmpConvAtu := ""
Local cLojConvAtu := ""
Local cCodConv    := ""   //Codigo do conveniado
Local cLojConv    := ""   //Loja do conveniado
Local cNumDoc     := ""
Local cSerDoc     := ""
Local cNomeEmp    := ""
Local lFirst      := .T.  //Controla a primeira ocorrencia do conveniado	         
Local lFirstEmp   := .T.  //Controla a primeira ocorrencia da empresa de convenio
Local nLin        := 80
Local nVlrTotEmp  := 0    //Totalizador por empresa de convenio
Local nVlrTotConv := 0    //Totalizador por conveniado
Local aNotasImp   := {}  //Array com as notas jah impressas
Local aItemNotasImp := {}  //Array com os itens das NFs jah impressos

If mv_par13 == 1                                         
         //             1         2         3         4         5         6         7         8         9         100       110       120       130
         //   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
   Cabec1  := " Matricula         Conveniado                                           "
   Cabec2  := "    Loja   Num.Doc./Serie    Emissao                     Valor da NF    "
ElseIf mv_par13 == 2
   Cabec1  := "    Loja   Num.Doc./Serie    Emissao                     Valor da NF    "
   Cabec2  := "       Cod. Produto       Descricao                  Quantidade    Vlr Unitario         Vlr Total"   
ElseIf mv_par13 == 3
   Cabec1  := " Matricula         Conveniado                                    Valor Total"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "TRB" )
dbGotop()
SetRegua(RecCount())

Do While !Eof()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf

    //Filtra as lojas das empresas de convenio. Nao foi colocado na query, porque deve considerar os casos em que
    //o codigo inicial do filtro eh, por exemplo: 001/02 e o final: 005/01. Nesta situacao, a query nao selecionaria 
    //as empresas de loja 01.    
    If TRB->EMPCONVENI+TRB->LOJCONVENI < MV_PAR03+MV_PAR04 .Or. ;
       TRB->EMPCONVENI+TRB->LOJCONVENI > MV_PAR05+MV_PAR06 
       DbSkip()
       Loop
    EndIf
    
    cEmpConvAtu   := TRB->EMPCONVENI   //Quebra por empresa de convenio
    cLojConvAtu   := TRB->LOJCONVENI   
    lFirstEmp     := .T.
    nVlrTotEmp    := 0  
	While !Eof() .And. cEmpConvAtu+cLojConvAtu == TRB->EMPCONVENI+TRB->LOJCONVENI
	    cCodConv := TRB->CODCONV	    //Quebra por conveniado
	    cLojConv := TRB->LOJCONV
	    lFirst   := .T.
	    nVlrTotConv := 0   //Valor total por conveniado
  	    While !Eof() .And. cCodConv+cLojConv == TRB->CODCONV+TRB->LOJCONV	       
	       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Impressao do cabecalho.                                             ³
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
	       If nLin > 58	       
		      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		      nLin  := 9
		   EndIf
           
           //Impressao da empresa de convenio
           If lFirstEmp
              cNomeEmp  := AllTrim(TRB->NOMEEMP)
              nLin++
              @nLin, 00 PSAY Replicate(" ",132)                            
              nLin++              
              @nLin,01 PSAY "Empresa: "+TRB->NOMEEMP
              nLin++           
              @ nLin, 00 PSAY Replicate("-",132)              
              nLin++                         
           EndIf 

           //Impressao do conveniado
           If lFirst
              If mv_par13 != 3
                 nLin++
                 @nLin, 00 PSAY Replicate(" ",132)                            
              EndIf   
              nLin++              
              @nLin,01 PSAY TRB->MATRICULA
              @nLin,18 PSAY TRB->CONVENIADO
              If mv_par13 == 3  //Total              
                 @nLin,60 PSAY TRB->VLRTOT    Picture PesqPict("SF2","F2_VALBRUT")    //Total gasto por conveniado       
                 nVlrTotEmp   +=  TRB->VLRTOT
              Else
                 nLin++                                                        
                 @ nLin, 00 PSAY Replicate("-",132)              
                 nLin++                                          
              EndIf
              nLin++
           EndIf

           If mv_par13 == 1 .Or. mv_par13 == 2 // Cabecalho ou Itens
           
              //Tratamento para 2 ou mais parcelas, verifica se a NF ja foi impressa
              If Ascan(aNotasImp,{|x| x[1] == TRB->NFISCAL+TRB->SERIE}) > 0
                 DbSkip()
                 Loop     
              Else
                 Aadd(aNotasImp,{TRB->NFISCAL+TRB->SERIE})      
              EndIf
              @nLin,04 PSAY TRB->FILIAL
              @nLin,11 PSAY TRB->NFISCAL
              @nLin,19 PSAY TRB->SERIE
              @nLin,27 PSAY TRB->EMISSAO
              @nLin,54 PSAY TRB->VLRTOTNF  Picture PesqPict("SF2","F2_VALBRUT")           
	       
	          nVlrTotConv  += TRB->VLRTOTNF	          
              nVlrTotEmp   += TRB->VLRTOTNF	          
	          If mv_par13 == 2	   //Itens
	             nLin++
	             cNumDoc := TRB->NFISCAL  //Quebra por itens
	             cSerDoc := TRB->SERIE
                 While !Eof() .And. cNumDoc+cSerDoc == TRB->NFISCAL+TRB->SERIE
                     
                     //Tratamento para 2 ou mais parcelas, verifica se o item da NF ja foi impresso
                     If Ascan(aItemNotasImp,{|x| x[1] == TRB->NFISCAL+TRB->SERIE+TRB->ITEM}) > 0
                        DbSkip()
                        Loop     
                     Else
                        Aadd(aItemNotasImp,{TRB->NFISCAL+TRB->SERIE+TRB->ITEM})      
                     EndIf

	                 If nLin > 58	       
		                Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		                nLin  := 9
		             EndIf

                     @nLin,07 PSAY TRB->CODPROD
                     @nLin,25 PSAY TRB->DESCPROD
                     @nLin,49 PSAY TRB->QUANTIDADE  Picture PesqPict("SD2","D2_QUANT")                                
                     @nLin,64 PSAY TRB->VLRUNIT     Picture PesqPict("SD2","D2_PRCVEN")                                
                     @nLin,83 PSAY TRB->VLRTOTIT    Picture PesqPict("SD2","D2_TOTAL")                                
                     
                     nLin++
                     
                     DbSkip()
                 End
	          EndIf
	       EndIf   
	       nLin++
	       lFirst       := .F.	       	        		
	       lFirstEmp    := .F.
	       
	       If mv_par13 != 2 //Para os itens o proximo registro ja se encontra posicionado
              DbSkip()
           EndIf   
        End
        If mv_par13 == 1 .Or. mv_par13 == 2 //Cabecalho
           @nLin,04 PSAY "Total...: "           
           @nLin,54 PSAY nVlrTotConv   Picture PesqPict("SF2","F2_VALBRUT")                   
           nLin++
        EndIf   
    End
    nLin++
    @nLin, 00 PSAY Replicate(" ",132)                            
    nLin++    
    @nLin,04 PSAY "TOTAL da empresa "+Substr(cNomeEmp,1,25)+" ...: "           
    If mv_par13 == 3
       @nLin,60 PSAY nVlrTotEmp  Picture PesqPict("SF2","F2_VALBRUT")                       
    Else
       @nLin,54 PSAY nVlrTotEmp  Picture PesqPict("SF2","F2_VALBRUT")                   
    EndIf   
    nLin++    
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Descarrega o Cache armazenado na memoria para a impressora.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MS_FLUSH()

DbSelectArea("TRB")
TRB->(DbCloseArea())

//Restaurar as tabelas utilizadas e limpar os arquivos temporarios
If lUsaQuery
   dbSelectArea("SF2")
   RetIndex("SF2")
		
   dbSelectArea("SA1")
   RetIndex("SA1")
		
   dbSelectArea("SE1")
   RetIndex("SE1")
		
   dbSelectArea("SD2")
   RetIndex("SD2")
		
   dbSelectArea("SB1")
   RetIndex("SB1")
EndIf

If oTblTmp <> NIL
	//Encerra arquivo temporario
	oTblTmp:Delete()
	oTblTmp := NIL
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFuncao    ³DroRelaStrºAutor  ³Fernando Machima    º Data ³  14/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria o array com os campos Data e Numero para a execucao doº±±
±±º          ³ comando TCSetField                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DroRelaStru(aStruTRB)
LOCAL aTam  := {}

If mv_par13 == 1 //Cabecalho
   aTam := TamSX3("F2_EMISSAO")
   AAdd( aStruTRB, {"EMISSAO","D",aTam[1],aTam[2]} )

   aTam := TamSX3("F2_VALBRUT")
   AAdd( aStruTRB, {"VLRTOTNF","N",aTam[1],aTam[2]} )
   
ElseIf mv_par13 == 2 //Itens
   aTam := TamSX3("D2_EMISSAO")
   AAdd( aStruTRB, {"EMISSAO","D",aTam[1],aTam[2]} )

   aTam := TamSX3("D2_QUANT")
   AAdd( aStruTRB, {"QUANTIDADE","N",aTam[1],aTam[2]} )

   aTam := TamSX3("D2_PRCVEN")
   AAdd( aStruTRB, {"VLRUNIT","N",aTam[1],aTam[2]} )

   aTam := TamSX3("D2_TOTAL")
   AAdd( aStruTRB, {"VLRTOTIT","N",aTam[1],aTam[2]} )

ElseIf mv_par13 == 3 //Total
   aTam := TamSX3("F2_VALBRUT")
   AAdd( aStruTRB, {"VLRTOT","N",aTam[1],aTam[2]} )
EndIf

Return .T.