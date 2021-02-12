#INCLUDE "DROAXLEU.ch"
#DEFINE GPI_GRAUS 9999 

Static lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DroAxMHG  ºAutor  ³ANDRE MELO          º Data ³  AGO/04     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PLANOS DE FIDELIDADE E CONDICOES DE PAGAMENTO              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DroAxMHG()
Private bRefresh:= {|| GPI020TOT() }
Private aRotina := MenuDef()

dbSelectArea("MHG")
MHG->(dbSetOrder(1))
mBrowse( 6,1,22,75,"MHG")

Return 

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 11.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template Drograria		                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Local aRot := {	{"Pesquisar"	,"AxPesqui"		,0	,1	,0	,.F.	}	,;
				{"Visualizar"	,"GPI020TELA"	,0	,2	,0	,.T.	}	,;
				{"Incluir"		,"GPI020TELA"	,0	,3	,0	,.T.	}	,;
				{"Alterar"		,"GPI020TELA"	,0	,4	,0	,.T.	}	,;
				{"Excluir"		,"GPI020TELA"	,0	,5	,0	,.T.	}	}
Return aRot

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GPIA020TELAºAutor ³Carlos A. Gomes Jr. º Data ³  01/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao / Alteracao / Exclusao.                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPI020TELA(cAlias,nReg,nOpcx)
Local cSeek     := NIL
Local cWhile    := NIL

Private lInclui := (nOpcx == 3)
Private nSaveSx8 := GetSx8Len()

If nOpcx <> 3	//se nao for inclusao
	MHG->(DbSetOrder(1))
	cSeek     := "'" + xFilial("LHF") + MHG->MHG_CODIGO + "'"
	cWhile    := "!EOF() .And. LHF_FILIAL + LHF_CODIGO == " + cSeek
EndIf

// DEFINES REFERENTES AOS PARAMETROS QUE SERAO PASSADOS PARA A LOCXGRID
//   1         2       3        4        5       6      7       8    9   10    11     12      13     14     15        16        17      18     19      20     21         22       23      24      25       26       27    28     29
//LocxMod(aParHead,aCposCab,aParRod,aCposRod,aParGrid,aCpos,cTitulo,aCordW,lGD,aCGD,aCSbx,nOpcx,cFldOK,cLineOk,cAllOk,__cFunOk,__cFunCanc,cIniLin,aGetsGD,nMax,lDelGetD,__aBotoes,__aTeclas,aObjs,__cDelOk,cOnInit,lEnchBar,lEndWnd,aOrditem)
LocxMod({"MHG"}					,	{}			,	/**/		,	/**/					,;
		{"LHF",cWhile,,,,cSeek}	,	/**/		,	/**/		,	/**/	,;
		/**/					,	/**/		,	/**/		,	nOpcx					,;
		/**/					,"T_TPLLinok()"	,"T_PFAllOk()"	,"GPIUFOK(__nOpcx,aRecnos)"	,;
		"GPIUFCANC(__nOpcx)"	,	/**/		,	/**/		,	GPI_GRAUS				,;
		.T.						,	/**/		,	/**/		,		/**/				,;
		"T_VldDelMHG()"			,	/**/		,	.T.			,	.T.						,;
		{} /*aOrdItem*/)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao³ GPIINIUF     ³ Por: Andre Melo				      ³ Data ³ 16/08/04 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPIINIUF(oGetDados,nOpc)
Local nI := 0
Local lContinua := .T. 

If nOpc <> 3
	lContinua := .F.
EndIf

If lContinua
	For nI :=  1 to GPI_GRAUS
		oGetDados:AddLine()
	Next nI
	n := 1
	oGetDados:oBrowse:nAt := 1
	oGetDados:oBrowse:Refresh()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao³ GPIUFOK      ³ Por: Andre Melo				      ³ Data ³ 16/08/04 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPIUFOK(nOpcx,aRecnos)
Local lRet    := .T.
Local aCpos   := {}
Local nI      := 0
Local nPosCod := AScan(aHeader,{|x| x[2] == "LHF_CONDIC" })   
Local lAchou  	:= .F.		//variavel que indica se ACHOU ou nao um Plano de Fideldade amarrado a um Cliente
Local cTipoProc := ""		//Identifica o tipo de processo off-line: INSERT,UPDATE OU DELETE

If nOpcx <= 2
	lRet := .T.
ElseIf nOpcx == 3
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Inclui Plano de Fidelidade	    	    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cTipoProc := "INSERT"	
	
	Reclock("MHG",.T.)
	aCpos := GeraCampos("MHG")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	MHG_FILIAL := xFilial("MHG")
	MHG->(MsUnlock())

	T_DroAxFidel("029","MHG",MHG->MHG_CODIGO + MHG->MHG_NOME,1, cTipoProc)	

	For nI := 1 To Len(aCols)
		If !(aCols[nI][Len(aCols[nI])])
			If RecLock("LHF",.T.)
				LHF->LHF_FILIAL := xFilial("LHF")
				LHF->LHF_CODIGO := MHG->MHG_CODIGO
				AEval(aHeader,{|x,y| If( ColumnPos(x[2])> 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
				LHF->(MsUnlock())
			
				T_DroAxFidel("029","LHF",LHF->LHF_CODIGO + LHF->LHF_CONDIC,1, cTipoProc)					
			EndIf
		EndIf
	Next nI
	                
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Grava os Dados do Plano de Fidelidade no Cadastro de Clientes SA1 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If !SA1->(dbSeek(xFilial("SA1")+PadR(MHG->MHG_CODIGO,TamSX3("A1_COD")[1]," ")+"01"))
		RecLock("SA1", .T.)
		SA1->A1_FILIAL  := xFilial("SA1")
		SA1->A1_COD 	:= MHG->MHG_CODIGO
		SA1->A1_LOJA	:= "01"
		SA1->A1_NOME	:= MHG->MHG_NOME
		SA1->A1_NREDUZ  := MHG->MHG_NOME
	    SA1->A1_TIPO	:= "F"	
	    SA1->A1_END	    := "."
	    SA1->A1_MUN  	:= "."
	    SA1->A1_EST 	:= AllTrim(Upper(SM0->M0_ESTCOB))
		SA1->(MsUnlock())
		
		cTipoProc := "INSERT"	
		T_DroAxFidel("007","SA1",xFilial("SA1") + SA1->A1_COD + SA1->A1_LOJA,1, cTipoProc)
	Endif
	
	If __lSX8
		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End
	EndIf
	
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Altera Plano de Fidelidade	    	    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
ElseIf nOpcx == 4
	cTipoProc := "UPDATE"
	
	Reclock("MHG",.F.)
	aCpos      := GeraCampos("MHG")
	AEval(aCpos,{|x,y| FieldPut(ColumnPos(x[1]),x[2]) })
	MsUnlock()

	T_DroAxFidel("029","MHG",MHG->MHG_CODIGO + MHG->MHG_NOME,1, cTipoProc)	

	Do While LHF->(DbSeek(xFilial("LHF")+M->MHG_CODIGO))
		RecLock("LHF",.F.)
		DbDelete()
		MsUnLock()
		                 
		cTipoProc := "DELETE"
		T_DroAxFidel("029","LHF",LHF->LHF_CODIGO + LHF->LHF_CONDIC,1, cTipoProc)										
	EndDo
	
	For nI := 1 To Len(aCols)

		If !aCols[nI][Len(aHeader)+1]
			RecLock("LHF",.T.)
			LHF->LHF_FILIAL := xFilial("LHF")
			LHF->LHF_CODIGO := M->MHG_CODIGO
			AEval(aHeader,{|x,y| If( ColumnPos(x[2]) > 0 ,FieldPut(ColumnPos(x[2]),aCols[nI][y]),) })
			MsUnlock()
			                 
			cTipoProc := "INSERT"	
			T_DroAxFidel("029","LHF",LHF->LHF_CODIGO + LHF->LHF_CONDIC,1, cTipoProc)								
		EndIf

	Next nI  
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Atualiza os Dados do Plano de Fidelidade no Cadastro de Clientes SA1 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+PadR(MHG->MHG_CODIGO,TamSX3("A1_COD")[1]," ")+"01")
		RecLock("SA1", .F.)
		SA1->A1_FILIAL  := xFilial("SA1")
		SA1->A1_COD 	:= MHG->MHG_CODIGO
		SA1->A1_NOME	:= MHG->MHG_NOME
		SA1->A1_NREDUZ  := MHG->MHG_NOME
		MsUnlock()
		
		cTipoProc := "UPDATE"	
		T_DroAxFidel("007","SA1",xFilial("SA1") + SA1->A1_COD + SA1->A1_LOJA,1, cTipoProc)									
	Endif
    If __lSX8
       While (GetSX8Len() > nSaveSx8)
	      ConfirmSX8()
	   End
    EndIf

/*
Exclui Plano de Fidelidade
*/
ElseIf nOpcx == 5
	//LOOP para verificar se o Plano de Fidelidade que esta sendo EXCLUIDO tem amarracao com algum Cliente.
	//Caso tenha amarracao, nao sera possivel EXCLUIR o Plano de Fidelidade
	DbSelectArea("SA1")
	DbGoTop()
	While !SA1->(Eof())
		If ((SA1->A1_CODPLF1 = MHG->MHG_CODIGO .And. SA1->A1_SITUAP1 = 'A') .Or. (SA1->A1_CODPLF2 = MHG->MHG_CODIGO .And. SA1->A1_SITUAP2 = 'A') ;
  		 .Or. (SA1->A1_CODPLF3 = MHG->MHG_CODIGO .And. SA1->A1_SITUAP3 = 'A').Or. (SA1->A1_CODPLF4 = MHG->MHG_CODIGO .And. SA1->A1_SITUAP4 = 'A');
	     .Or. (SA1->A1_CODPLF5 = MHG->MHG_CODIGO .And. SA1->A1_SITUAP5 = 'A'))
	    	MsgAlert(STR0001) //"Existem um ou mais clientes utilizando este Plano de Fidelidade."
	    	lAchou := .T.
	    	Exit  
    	Endif
    	SA1->(DbSkip())
    End
    
    If !lAchou
		Reclock("MHG",.F.)
		DbDelete()
		MsUnlock()
		
		cTipoProc := "DELETE"		
		T_DroAxFidel("029","MHG",MHG->MHG_CODIGO + MHG->MHG_NOME,1, cTipoProc)			
		
		For nI := 1 To Len(aRecnos)
			LHF->(DbGoto(aRecnos[nI]))
			RecLock("LHF",.F.)
			DbDelete()
			MsUnlock()
			T_DroAxFideli("029","LHF",LHF->LHF_CODIGO + LHF->LHF_CONDIC,1, cTipoProc)													
		Next nI
		DbSelectArea("SA1")
		dbSetOrder(1)
		If DbSeek(xFilial("SA1")+PadR(MHG->MHG_CODIGO,TamSX3("A1_COD")[1]," ")+"01")
			Reclock("SA1",.F.)
			DbDelete()
			MsUnlock()   
			T_DroAxFidel("007","SA1",xFilial("SA1") + SA1->A1_COD + SA1->A1_LOJA,1, cTipoProc)												
		Endif	
	Endif
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao³ TPLLinok     ³ Por: Andre Melo				      ³ Data ³ 16/08/04 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function TPLLinok()
Local lRet := .T.
Local nPosCod  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="LHF_CONDIC" })

If Empty(aCols[n,nPosCod]) .and. !aCols[n,Len(aHeader)+1]
	Help("",1,"OBRIGAT")
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³PFAllOk   ºAutor  ³Thiago P.Honorato   º Data ³  28/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe pelo menos uma  "Condicao de Pagamento" º±±
±±º          ³ no momento de cofirmar alguma alteracao					  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function PFAllOk()
LOCAL nDel := Len(aHeader)+1
Local lRet := .T.

IF AScan(aCols,{|x| x[nDel] == .F. }) == 0 
	//Help("",1,"OBRIGAT")
	MsgAlert(STR0002) //"Deve existir pelo menos um registro para Condição de Pagamento"
	lRet := .F.
ENDIF

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³VldAcols  ºAutor  ³Thiago P.Honorato   º Data ³  24/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o valor digitado no campo "Condicao" 		  º±±
±±º          ³ (LHF_CONDIC) ja existe									  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function VldAcols(cCod) //pega o valor que o usuário ira digitar no campo(LHF_CONDIC)
LOCAL lRet	:= .T.
LOCAL  nDel	:= Len(aHeader)+1
LOCAL  nPos	:= aScan(aCols,{|x,y| AllTrim(Upper(x[1])) == AllTrim(Upper(cCod)) .AND. !x[nDel]})

IF nPos > 0
	MsgAlert(STR0003) //"Já existe um registro relacionado a este código!"
	lRet := .F.
ENDIF

Return lRet                

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GPIUFCANC ºAutor  ³Fernando Machima    º Data ³  15/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o valor digitado no campo "Condicao" 		  º±±
±±º          ³ (LHF_CONDIC) ja existe									  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPIUFCANC(nOpcx)

If nOpcx == 3  //Incluir
   If __lSX8
		While (GetSX8Len() > nSaveSx8)   	
			RollbackSX8()
		End
   EndIf        
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³DroAxFidel³ Autor ³ IP-Vendas 			³ Data ³ 04/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Define a operacao que sera realizada na tabela de 	      ³±±
±±³			 ³ integracao de acordo com o processo de replicacao executado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Registros utilizados na integracao Off-line                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DroAxFidel( cProcess, cTabela, cChave, nOrdem, cTipo)
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
	
//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New(cProcess)
	
	//Determina o tipo de operacao 
	If Empty(cTipo)
		If INCLUI
			cTipo := "INSERT"
		ElseIf ALTERA
			cTipo := "UPDATE"
		Else
			cTipo := "DELETE"				
		EndIf
	Endif                                   	
	
	If cTipo = "DELETE"
		//Considera os registros deletados
		SET DELETED OFF	
	EndIf		
		    
	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir(cTabela, xFilial(cTabela) + cChave, nOrdem, cTipo)	
			
		//Processa os dados 
		oProcessOff:Processar()	
	EndIf
	
	//Desconsidera os registros deletados
	SET DELETED ON
EndIf
	
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³VldDelMHG ³ Autor ³ IP-Vendas 			³ Data ³ 04/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla a delecao do item, verificando que ao habilitar	  ³±±
±±³			 ³ novamente o item deletado, este ja nao foi inserido 	      ³±±
±±³			 ³ posteriormente	  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Registros utilizados na integracao Off-line                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Template Function VldDelMHG()         
LOCAL  lRet  := .T.
LOCAL  nDel  := Len(aHeader)+1
LOCAL  nPos  := aScan(aCols,{|x,y| AllTrim(Upper(x[1])) == AllTrim(Upper(aCols[n][1])) .AND. !x[nDel]})
Static lDisparou := .F. 

If lDisparou
	lDisparou := .F.
Else
	IF nPos > 0 .And. nPos <> n
		MsgAlert(STR0003) //"Já existe um registro relacionado a este código!"
		lDisparou := .T.
		lRet := .F.
	ENDIF
EndIf

Return lRet
