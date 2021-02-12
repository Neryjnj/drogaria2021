#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_LOJA.CH"

#DEFINE _PLINHA    chr(13) + chr(10)

Static lTemFldTAF := NIL
Static cAbaDrogar := NIL
Static lIsTop	  := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_LOJA 
Finalidade dessa função é de realizar a mundanca de algumas tabelas do
Template de Drogaria:
LEK	- MHA - Genericos e Similares
LEL	- MHB - Apresentacao
LEM	- MHC - Similaridade
LEQ	- MHD - Cad. do Produto Kit
LER	- MHE - Cad. dos Itens do Kit
LES	- MHF - Cadastro de Convenio
LEU	- MHG - Planos de Fidelidade
A alteração dessa tabelas se faz necessario pois foram utilizadas pelo 
Produto TAF. 

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA  

@Author Rene Julian
@since 10/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function RBE_LOJA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aTables		:= LjSxTable("2")		//Retorna a array com as tabelas originais
Local nX			:= 0
Local cMensagem     := ""	

//-------------------------------------------------------------------
//Atualizações necessárias para o release V12.1.17
//-------------------------------------------------------------------
If cMode = "1" .AND. cRelStart >= "001"	
	
	#IFDEF TOP
		lIsTop := .T.
	#ENDIF
	
	If LJVLDDRO(@cMensagem)  //valida a utilização do template de Drogaria 
		For nX := 1 To Len(aTables) // realiza o Back-up Das tabelas
			LjBkpTable(aTables[nX],@cMensagem)	// Realiza o back-up das tabelas
		Next nX	
		LjDrAtuSX2(@cMensagem)  // Realiza a gravação do Sx2
		
		LjDrCriaTab(@cMensagem) //Realiza a gravação dos campos do SX3 das novas tabelas.
		
		/*---------------------------------------------------------
			*LjDrCriaInd*
		 - Criar por ultimo para atualizar todos os dados do banco
		 - Realiza a gravação do SIX
		---------------------------------------------------------*/
		LjDrCriaInd(@cMensagem) 
		
		LJDrAtuDados(@cMensagem) // Realiza a inclusão de dados nas novas tabelas / exclui dados do SX3 e base
		
		If !LjVlTAFDro()//Caso não tenha os dados do TAF, limpa todo o dicionário
			LJDrClDic(@cMensagem) //Faz a limpeza do dicionário antigo de Template
		EndIf
		
		/*---------------------------------------------------------
		Insere as alterações que eram criados pelos UPDDROXX, 
		que foram removidos e incorporados no Aplicador e aqui 
		no RBE, para atualizar igualmente o ambiente migrado
		sem usar o aplicador		
		---------------------------------------------------------*/
		LjDrFdUpd(@cMensagem) 
	Else
		cMensagem += "Não foi Validado o Template de Drogaria" + _PLINHA
	EndIf	
	
	ConOut("Final da Execução RBE_LOJA")
EndIf 
	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LJVLDDRO(cMensagem)
Função para valiar se o template esta sendo utilizado na base do cliente

@Param cMensagem - variavel para acumular as mensagens da funções

@Return lRet - Logico Verdadeiro caso utilize o template, Falso não utiliza

@author Rene Julian
@since 23/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LJVLDDRO(cMensagem) 
Local lRet		:= .F.
Local aArea		:= {}
Local nTamFld	:= 0
Local nX		:= 0
Local nY		:= 0

Aadd(aArea,GetArea())

cMensagem += "Inicio da Validação da função LJVLDDRO" + _PLINHA 

Conout("Validação - Template de Drogaria")
cMensagem += "Validação - Template de Drogaria" + _PLINHA
lRet := (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
Conout("Retorno Validação - Template de Drogaria [" + IIF(lRet,"SIM","NÃO") + "]")
cMensagem += "Retorno Validação - Template de Drogaria [" + IIF(lRet,"SIM","NÃO") + "]" + _PLINHA 

If TableInDic("LK9")
	DbSelectArea("LK9")
	Aadd(aArea,LK9->(GetArea()))
	LK9->(DbGoTop())
	If !LK9->(Eof()) // Possui Registro de medicamentos
		lRet := .T.
		Conout("Possui registros na LK9")
		cMensagem += "Possui registros na LK9" + _PLINHA 
	EndIf
	LK9->(DbCloseArea())
EndIf

//Valida se tem os campos do template
DbSelectArea("SX3")
DbSelectArea("SIX")
Aadd(aArea,SX3->(GetArea()))
Aadd(aArea,SIX->(GetArea()))

nTamFld := Len(SX3->X3_CAMPO)
SX3->(DbSetOrder(2)) //X3_CAMPO

LjVlTAFDro(,@cMensagem,nTamFld) //Deixar dentro dessa instrução pois não reposiciono

cMensagem += " Fim da função LJVLDDRO - Existem dados de Template de Drogarias ? " + IIF(lRet,"Sim","Não") + _PLINHA
Conout(" Fim da função LJVLDDRO - Existem dados de Template de Drogarias ? " + IIF(lRet,"Sim","Não")) 

For nTamFld := 1 to Len(aArea)
	RestArea(aArea[nTamFld])
next nTamFld 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjVlTAFDro(lValida,cMensagem,nTamFld)
Valida se o cliente tem campos do TAF 

@Param cMensagem - variavel para acumular as mensagens da funções
@Return lRet - Logico , tem campos do TAF ?

@author Julio.nery
@since 2/03/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjVlTAFDro(lValida,cMensagem,nTamFld) 
Local lRet := .F.

Default lValida  := .F.
Default cMensagem := ""
Default nTamFld	  := 10

//Valida se existem os campos do TAF
If lValida .Or. (lTemFldTAF == NIL)
	//Logs aqui dentro para somente disparar 1 vez a mensagem
	ConOut("Validação se possui campos do SIGATAF na base")
	cMensagem += "Validação se possui campos do SIGATAF na base" + _PLINHA

	lRet := SX3->(DbSeek(PadR("LEK_ID",nTamFld))) .And. SX3->(DbSeek(PadR("LEK_IDEVEN",nTamFld))) 
	lRet := lRet .And. SX3->(DbSeek(PadR("LEL_ID",nTamFld))) .And. SX3->(DbSeek(PadR("LEL_DTINI",nTamFld)))
	lRet := lRet .And. SX3->(DbSeek(PadR("LEM_ID",nTamFld))) .And. SX3->(DbSeek(PadR("LEM_NUMERO",nTamFld)))
	lRet := lRet .And. SX3->(DbSeek(PadR("LEQ_ID",nTamFld))) .And. SX3->(DbSeek(PadR("LEQ_CODAJU",nTamFld)))
	lRet := lRet .And. SX3->(DbSeek(PadR("LER_ID",nTamFld))) .And. SX3->(DbSeek(PadR("LER_DTINIO",nTamFld)))
	lRet := lRet .And. SX3->(DbSeek(PadR("LES_ID",nTamFld))) .And. SX3->(DbSeek(PadR("LES_CODOS",nTamFld)))
	lRet := lRet .And. SX3->(DbSeek(PadR("LEU_ID",nTamFld))) .And. SX3->(DbSeek(PadR("LEU_CODOSP",nTamFld)))

	lTemFldTAF := lRet
	
	Conout("Finalização - Campos do SIGATAF na base. Existem ? " + IIF(lRet,"[SIM]","[NÃO]"))
	cMensagem += "Finalização - Campos do SIGATAF na base. Existem ? " + IIF(lRet,"[SIM]","[NÃO]") + _PLINHA
Else
	lRet := lTemFldTAF
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJABORTA(cMensagem,oDlg,oSay3)
Tem a Função de finalizar a execução do migrador.

@Param cMensagem - variavel para acumular as mensagens da funções
@Param oDlg - objeto tela principal
@Param oSay3 - objeto de apresentação de mensagens

@author Rene Julian
@since 10/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LJABORTA(cMensagem,oDlg , oSay1 )

IF MsgYesNo("Deseja realmente abortar o MIGRADOR UPDDISTR?")	
	cMensagem := ""			 
	oDlg:Refresh()
	oSay1:Refresh()
	oDlg:End()
	Final()
EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjBkpTable(cTable,cMensagem)
Função Tem o objetivo de realizar a gravação da tabela que deverá ser modificada.

@Param cTable - alias da tabela para realizar o back-up
@Param cMensagem - variavel para acumular as mensagens da funções
@Return lRet - Logico caso ocorra problemas retorna Falso

@author Rene Julian
@since 10/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjBkpTable(cTable,cMensagem)
Local cStartPath := Upper(GetSrvProfString("STARTPATH","")) // /system/
Local cLocalF    := Upper(GetSrvProfString("LOCALFILES","")) // /LocalFiles
Local cDriver    := IIf(cLocalF == "CTREE","CTREECDX","DBFCDX")
Local cArqName   := "" 
Local cEmpAtu	 := cEmpAnt
Local cFilAtu	 := cFilAnt
Local aStruct    := {}
Local cTbDest	 := 'BKP'+cTable  // tabela destino para copia 
Local lRet       := .F.
Local lProssegue := .F.
Local nCout      := 0 
Local nX         := 0
Local lTopConn   := .F.
cMensagem += "Iniciando a Função de gravação em disco das tabela: "+ cTable + _PLINHA 

cArqName := cStartPath+"BKP_"+cTable+"_"+AllTrim(cEmpAtu)+AllTrim(cFilAtu)+"."+IIf(cLocalF == "CTREE","DTC","DBF")
#IFDEF TOP
	lTopConn := .T.
#ENDIF		
lProssegue := (!lIsTop .Or. ( lIsTop .And. IIf(lTopConn, TCCanOpen(RetSQLName(cTable)), .T.) ) )

If TableInDic(cTable) .And. lProssegue
	
	DbSelectArea( cTable )
	
	//Considera os registros deletados
	SET DELETED OFF	
	
	(cTable)->(DbGoTop()) // volto no inicio dos Registros
	
	nCout := IIf((cTable)->(Eof()),0,1)
	
	// A tabela existindo fazemos o back-up se a mesma nao  estiver vazia 
	If nCout > 0
		If !LjFlDelet(cArqName,@cMensagem)  // Caso nao seja possivel a excusão do arquivo altero o nome
			cArqName := cStartPath+"BKP_"+cTable+"_"+AllTrim(cEmpAtu)+AllTrim(cFilAtu)+"TOTVS"+"."+IIf(cLocalF == "CTREE","DTC","DBF")
		EndIf
		If LjFlDelet(cArqName,cMensagem)		
			aStruct := (cTable)->(DbStruct())
			DbCreate(cArqName, aStruct, cDriver)
			DBUseArea( .T., cDriver, cArqName, cTbDest , .F., .F. )
						
			While (cTable)->(!EoF())				
				nX := 0
				(cTbDest)->(DBAppend())
				For nX := 1 To Len(aStruct) 
					(cTbDest)->(FieldPut( ColumnPos(aStruct[nX][1]) , (cTable)->(FieldGet(ColumnPos(aStruct[nX][1])))  ))
				Next nX			
				(cTbDest)->( MsUnLock() )	
				 If (cTable)->(Deleted())
				 	(cTbDest)->(DbDelete())
				 EndIf
				(cTable)->(DbSkip())
			End
			nCout := 0
			DbSelectArea( cTbDest )
			(cTbDest)->(DbGoTop())
			nCout := IIf((cTbDest)->(Eof()),0,1)			
			(cTbDest)->(DBCloseArea())
			
			If  nCout > 0
				cMensagem += "Tabela "+cTable+ " criado como back-up Destino: "+ cArqName + _PLINHA   	
				lRet := .T.	 
			Else
		   		cMensagem += "Não foi possivel copiar a Tabela "+cTable+ " Como back-up Destino: "+ cArqName + _PLINHA
			EndIf
		Else
			cMensagem += "Não foi possivel a Exclusão do arquivo "+cArqName+ _PLINHA
			cMensagem += "Não foi possivel copiar a Tabela "+cTable+ " Como back-up Destino: "+ cArqName + _PLINHA
		EndIf	
	Else
		cMensagem += "Não foi possivel Realizar a copia da Tabela "+cTable+", Tabela esta vazia." + _PLINHA  
	EndIf
	
	SET DELETED ON
Else
	cMensagem += "Não foi possivel Realizar a copia da Tabela "+cTable+", Tabela não existe." + _PLINHA  	
EndIf

cMensagem += "Saindo da Função de gravação em disco das tabelas"+ _PLINHA

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjFlDelet(cArqName,cMensagem)
Função que verifica a existencia do arquivo caso sim irá excluir o mesmo

@Param cArquivo - Nome do arquivo e patch que deverá ser excluido     
@Param cMensagem - variavel para acumular as mensagens da funções   

@Return lRet - Caso o arquivo exista e nao seja possivel a exclusao retorna falso        

@author Rene Julian
@since 11/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjFlDelet(cArqName,cMensagem)
Local lRet := .T.

If File(cArqName)
	If FERASE(cArqName) == -1
		cMensagem += "Não foi possivel a Exclusão do arquivo "+cArqName+ _PLINHA
	Else
		cMensagem += "Arquivo "+cArqName+" Excluido com sucesso." + _PLINHA
	EndIf
EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSxTable(cTipo)
Função para retornar a estrutura de campos ou  tabelas que deverão 
usadas em formato de array

@Param cTipo - tipo de instrução que deverá ser retornado
           1 - Retorna um array com a estrutura do SX3
           2 - Retorna as Tabelas antigas do template de drogaria que serão substituidas
           3 - Retorna as Tabelas novas do template de drogaria que deverão ser criadas
           4 - Retorna uma matriz com as tabelas origem e a tabelas destino
           5 - Retorna uma Array com a Estrutura do SX2
           6 - Retorna um array com a estruruta da SIX

@Return aRet - Array que deverá conter o tipo de conteudo solicitado conforme parametro
        cTipo

@author Rene Julian
@since 10/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjSxTable(cTipo)
Local aRet := {}

Default cTipo := ""

If cTipo == "1" // estrutura da SX3
	aRet := { "X3_ARQUIVO"	,	"X3_ORDEM"		,	"X3_CAMPO"		,	"X3_TIPO"	,;
			  "X3_TAMANHO"	,	"X3_DECIMAL"	,	"X3_TITULO"		,	"X3_TITSPA"	,;
			  "X3_TITENG"	,	"X3_DESCRIC"	,	"X3_DESCSPA"	,	"X3_DESCENG",;
			  "X3_PICTURE"	,	"X3_VALID"		,	"X3_USADO"		,	"X3_RELACAO",;
			  "X3_F3"		,	"X3_NIVEL"		,	"X3_RESERV"		,	"X3_CHECK"	,;
			  "X3_TRIGGER"	,	"X3_PROPRI"		,	"X3_BROWSE"		,	"X3_VISUAL"	,;
			  "X3_CONTEXT"	,	"X3_OBRIGAT"	,	"X3_VLDUSER"	,	"X3_CBOX"	,;
			  "X3_CBOXSPA"	,	"X3_CBOXENG"	,	"X3_PICTVAR"	,	"X3_WHEN"	,;
			  "X3_INIBRW"	,	"X3_GRPSXG"		,	"X3_FOLDER"		,	"X3_PYME" 	}
ElseIf cTipo == "2"			 
	aRet := {"LEK","LEL","LEM","LEQ","LER","LES","LEU"}
	
ElseIf cTipo == "3"
	aRet := {"MHA","MHB","MHC","MHD","MHE","MHF","MHG"}
	
ElseIf cTipo == "4"
	aRet := { {"LEK" ,"MHA" },;
		      {"LEL" ,"MHB" },;
		      {"LEM" ,"MHC" },;
		      {"LEQ" ,"MHD" },;
		      {"LER" ,"MHE" },;
		      {"LES" ,"MHF" },;
		      {"LEU" ,"MHG" } }
		      
ElseIf cTipo == "5" // estrutura da SX2
	aRet := {"X2_CHAVE"		,	"X2_PATH"		,	"X2_ARQUIVO"	,	"X2_NOME"	, ;	
			 "X2_NOMESPA"	,	"X2_NOMEENG"	,	"X2_DELET"		,	"X2_MODO"	, ;
			 "X2_MODOUN"	,	"X2_MODOEMP"	,	"X2_TTS"		,	"X2_ROTINA"	, ;
			 "X2_PYME"		,	"X2_UNICO"		}	
			 	      
ElseIf cTipo == "6"  // estrutura da SIX
	aRet := {"INDICE"		,	"ORDEM"			, 	"CHAVE"			, 	"DESCRICAO"	, ;  			
			 "DESCSPA"		,	"DESCENG"		,	"PROPRI"		,	"F3"		, ;
			 "NICKNAME"		,   "SHOWPESQ"		}
			 	
ElseIf cTipo == "7"
	
	aRet := {"X7_CAMPO"		,	"X7_SEQUENC"	,	"X7_REGRA"		,	"X7_CDOMIN", ;
			 "X7_TIPO"		,	"X7_SEEK"		,	"X7_ALIAS"		,	"X7_ORDEM" , ;
			 "X7_CHAVE"		,	"X7_CONDIC"		,	"X7_PROPRI"		}

ElseIf cTipo == "8"
	aRet := {"XB_ALIAS"		,	"XB_TIPO"		,	"XB_SEQ"		,	"XB_COLUNA", ;
			 "XB_DESCRI"	,	"XB_DESCSPA"	,	"XB_DESCENG"	,	"XB_CONTEM", ;
			 "XB_WCONTEM"}

ElseIf cTipo == "9"
	aRet := { "X6_FIL"		,	"X6_VAR"		,	"X6_TIPO"		,	"X6_DESCRIC", ;
			  "X6_DSCSPA"	,	"X6_DSCENG"		,	"X6_DESC1"		,	"X6_DSCSPA1", ;
              "X6_DSCENG1"	,	"X6_DESC2"		,	"X6_DSCSPA2"	,	"X6_DSCENG2", ;
              "X6_CONTEUD"	,	"X6_CONTSPA"	,	"X6_CONTENG"	,	"X6_PROPRI" , ;
              "X6_PYME" 	,	"X6_VALID"		,	"X6_INIT"		,	"X6_DEFPOR"	, ;
              "X6_DEFSPA"	,	"X6_DEFENG"		}

ElseIf cTipo == "10"
	aRet := { "XA_ALIAS"	,	"XA_ORDEM"		,	"XA_DESCRIC"	,	"XA_DESCSPA", ;
			  "XA_DESCENG"	,	"XA_PROPRI" 	,	"XA_AGRUP"		,	"XA_TIPO"	}
EndIf
		
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaInd(cMensagem)
Função para aglutinar os idicies da base do cliente com os novos indices

@Param cMensagem - variavel para acumular as mensagens da funções

@Return 

@author Rene Julian
@since 22/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaInd(cMensagem)
Local cAliasOri := ""
Local cAliasDes := ""
Local cAlDes	:= ""
Local cOldAls	:= ""
Local nX        := 0
Local nI		:= 0
Local nPos		:= 0
Local aTables   := LjSxTable("4") //retorna uma matriz com a tabela original e a nova tabela
Local aSIXOri   := {}  // Array que deve contrer os indices da base do cliente.
Local aEstrut   := LjSxTable("6") // Retorna a estrutura dos Indices 
Local aSIXDes   := {}
Local aTbDes    := LjSxTable("3") // Retorna um array com as novas tabelas
Local aArea		:= {} 
Local cOrder    := "0"
Local lLjVlTAFDro := LjVlTAFDro()  

cMensagem += "Inicio da função LjDrCriaInd, vai iniciar a comparação das tabelas." + _PLINHA
For nX := 1 To Len(aTables)
	cAliasOri 	:= aTables[nX][1] 
	cAliasDes 	:= aTables[nX][2]
	LJSIXORI(aTables[nX], @cMensagem,@aSIXOri )
	LjAtuSXI(cAliasDes,@cMensagem,@aSIXDes,@cOrder)
	For nI := 1 To Len(aSIXOri)
		nPos 	:= Ascan(aSIXDes,{|x| Alltrim(Upper(x[3])) == Alltrim(Upper(aSIXOri[nI][3]))})
		If nPos == 0 // caso o campo nao exista no array deve adicionar
			cOrder := Soma1(cOrder)
			aSIXOri[nI][2] := cOrder 
			AAdd(aSIXDes , aSIXOri[nI] ) // Adiciono a estrutura do campo que nao esta no array que vai gerar o SX3			
		EndIf
	next nI	
	aSIXOri := {}
Next nX

// Faco a reordenação dos indices
ASort(aSIXDes,,,{|x,y| x[1]+x[2]< y[1]+y[2]})

DbSelectArea("SIX")
Aadd(aArea,SIX->(GetArea()))
SIX->(DbSetOrder(1))

For nX := 1 To Len(aSIXDes)
	//Ajusta os novos índices
	If !SIX->(DbSeek(aSIXDes[nX][1] + aSIXDes[nX][2]))
		RecLock("SIX",.T.)
		For nI:=1 To Len(aSIXDes[nX])
			If ColumnPos(aEstrut[nI])>0
				FieldPut(ColumnPos(aEstrut[nI]),aSIXDes[nX,nI])
			EndIf
		Next nI
		SIX->(DbCommit())
		SIX->(MsUnLock())
	EndIf
	
	/*
		1- Faço a busca do antigo campo para deletar do SX3, somente quando tem TAF envolvido
		2- Quando não possui TAF, deleto toda a tabela antiga do SX3 direto			
	*/
	If lLjVlTAFDro
		nI := Ascan(aTables, {|x| x[2] == aSIXDes[nX,1]})
		If nI > 0
			cOldAls := aTables[nI][1]
			
			If SIX->((dbSeek(cOldAls)))
				While !SIX->(Eof()) .And. (AllTrim(SIX->INDICE) == cOldAls)
					If SIX->PROPRI == "T" //Apaga os índices do Template

						If lIsTop
							TcInternal(60,RetSqlName(SIX->INDICE) + "|" + RetSqlName(SIX->INDICE) + SIX->ORDEM) //Exclui sem precisar baixar o TOP
						Endif
											
						RecLock("SIX",.F.)
						SIX->(DbDelete())
						SIX->(DbCommit())
						SIX->(MsUnLock())
						cMensagem += " - Exclusão do indice antigo: " + cOldAls + _PLINHA
					EndIf
					
					SIX->(DbSkip())
				End				
			EndIf
		EndIf
	EndIf
Next nX

For nX := 1 To Len(aTbDes) 
	cAlDes := aTbDes[nX]
	
	//Bloqueia alterações no Dicionário
	__SetX31Mode(.F.)
	
	//Atualiza o Dicionário
	X31updtable(cAlDes)
	
	//Se a tabela tiver aberta nessa seção, fecha
	If Select(cAlDes) > 0
		(cAlDes)->(DbCloseArea())
	EndIf 
	
	//Se houve Erro na Rotina
	If __GetX31Error()
		cMensagem +=  " Houveram erros na atualização da tabela "+cAlDes +"."+_PLINHA
		cMensagem += __GetX31Trace() +_PLINHA	
	Else
		//Abrindo a tabela para criar dados no sql
		DbSelectArea(cAlDes)
		cMensagem +=  " Realizado geração da tabela "+cAlDes +"."+_PLINHA
		(cAlDes)->(DbCloseArea())
	EndIf           
	
	//Desbloqueando alterações no dicionário
	__SetX31Mode(.T.)
Next nX

For nX:=1 to Len(aArea)
	RestArea(aArea[nX])
Next nX

Return

//-------------------------------------------------------------------
/*{Protheus.doc} LjDrCriaTab(cMensagem)
Função para clonar os campo de uma tabela para alterar para outra tabela 

@Param cMensagem - variavel para acumular as mensagens da funções

@Return 

@author Rene Julian
@since 10/01/2018
@version P12.1.17
*/
//-------------------------------------------------------------------
Static Function LjDrCriaTab(cMensagem)
Local cAliasOri := ""
Local cAliasDes := ""
Local cOldField	:= ""
Local cAux		:= ""
Local nZ		:= 0
Local nX        := 0
Local nI		:= 0
Local nPos      := 0
Local nTamFld	:= 0
Local aTables   := LjSxTable("4")	// Retorna uma matriz com as tabelas origem e a tabelas destino
Local aEstru   	:= LjSxTable("1")	//Retorna um array com a estrutura do SX3
Local aSX3Ori   := {}
Local aSX3Des   := {}
Local aArea		:= {}
Local lLjVlTAFDro := LjVlTAFDro() 
Local lFldInclui:= .F. 

cMensagem += "Inicio da função LjDrCriaTab, vai iniciar a comparação das tabelas." + _PLINHA
Conout("Inicio da função LjDrCriaTab, vai iniciar a comparação das tabelas.")

//Insere os campos novos do Template
For nX := 1 To Len(aTables)
	cAliasOri 	:= aTables[nX][1] 
	cAliasDes 	:= aTables[nX][2]
	aSX3Des		:= LjRetCPSX3(cAliasDes,@cMensagem) //retorna o array com os campos para inclusão no SX3	
	LjClTable(aTables[nX],@cMensagem,@aSX3Ori) 		// retorna os campos das tabelas em uso no cliente já com o alias alterado
	
	For nI := 1 To Len(aSX3Des)
		nPos 	:= Ascan(aSX3Ori,{|x| Alltrim(Upper(x[3])) == Alltrim(Upper(aSX3Des[nI][3]))})
		If nPos == 0 // caso o campo nao exista no array deve adicionar
			AAdd(aSX3Ori , aSX3Des[nI] ) // Adiciono a estrutura do campo que nao esta no array que vai gerar o SX3
		Else
			If !Empty(aSX3Des[nI][14]) .Or. !Empty(aSX3Des[nI][32]) // se tiver conteudo na base padrao substitui X3_VALID ou X3_WHEN			
				aSX3Ori[nPos][14] := IIf(!Empty(aSX3Des[nI][14]), aSX3Des[nI][14], aSX3Ori[nPos][14] )
				aSX3Ori[nPos][32] := IIf(!Empty(aSX3Des[nI][32]), aSX3Des[nI][32], aSX3Ori[nPos][14] )
			EndIf
			
			//Efetuo o ajuste em todos os campos conforme padrão do novo dicionário
			For nZ := 1 to Len(aSX3Des[nI])
				/*
				14 - X3_VALID
				32 - X3_WHEN
				27 - X3_VLDUSER
				*/
				If nZ == 14 .Or. nZ == 32 .Or. nZ == 27
					Loop
				Else
					aSX3Ori[nPos][nZ] := aSX3Des[nI][nZ]
				EndIf
			Next nZ 
		EndIf
	Next nI
Next nX

If Len(aSX3Des) > 0 // refaço a ordenação pelo Alias 
	ASort(aSX3Ori,,,{|x,y| x[1]+x[2]< y[1]+y[2]})
EndIf

//Processamento dos campos no SX3
dbSelectArea("SX3")
Aadd(aArea, SX3->(GetArea()))
SX3->(dbSetOrder(2))

nTamFld := Len(SX3->X3_CAMPO)

For nI := 1 To Len(aSX3Ori)
	
	lFldInclui := SX3->(dbSeek(PadR(aSX3Ori[nI,3],nTamFld))) 
	
	If lFldInclui
		cMensagem += " Alteração de campo [" + aSX3Ori[nI][3] + "]" + _PLINHA
		Conout(" Alteração do campo ["+ aSX3Ori[nI][3] + "]")
	Else
		cMensagem += " Inclusão do campo ["+ aSX3Ori[nI][3] + "]" + _PLINHA
		Conout(" Inclusão do campo ["+ aSX3Ori[nI][3] + "]")
	EndIf
		
	RecLock("SX3",!lFldInclui)
	For nX := 1 To Len(aSX3Ori[nI])
		If AllTrim(aEstru[nX]) <> "X3_ORDEM"
			FieldPut(ColumnPos(aEstru[nX]),aSX3Ori[nI,nX])
		EndIf
	Next nX
	
	SX3->(DbCommit())
	SX3->(MsUnLock())		
Next nI


cMensagem += "Função LjDrCriaTab - Atualização dos campos novos no Banco " + _PLINHA
Conout("Função LjDrCriaTab - Atualização dos campos novos no Banco ")

cAux := ""
For nX := 1 To Len(aSX3Ori)
	If !(aSX3Ori[nX][1] $ cAux)
		//Bloqueia alterações no Dicionário
		__SetX31Mode(.F.)
		
		//Atualiza o Dicionário
		X31updtable(aSX3Ori[nX][1])
		
		//Se a tabela tiver aberta nessa seção, fecha
		If Select(aSX3Ori[nX][1]) > 0
			(aSX3Ori[nX][1])->(DbCloseArea())
		EndIf 
		
		//Se houve Erro na Rotina
		If __GetX31Error()
			cMensagem +=  " LjDrCriaTab - Houveram erros na atualização da tabela "+aSX3Ori[nX][1] +"."+_PLINHA
			COnout(" LjDrCriaTab - Houveram erros na atualização da tabela "+aSX3Ori[nX][1] +".")
			cMensagem += __GetX31Trace() +_PLINHA	
		Else
			//Abrindo a tabela para criar dados no sql
			DbSelectArea(aSX3Ori[nX][1])
			cMensagem +=  " LjDrCriaTab - Realizada geração da tabela "+aSX3Ori[nX][1] +"."+_PLINHA
			COnout(" LjDrCriaTab - Realizada geração da tabela "+aSX3Ori[nX][1]+".")
			(aSX3Ori[nX][1])->(DbCloseArea())
		EndIf           
		
		//Desbloqueando alterações no dicionário
		__SetX31Mode(.T.)
		
		cAux += aSX3Ori[nX][1] + "|"
	EndIf
Next nX

cMensagem += "Função LjDrCriaTab - Fim da Atualização dos campos novos no Banco " + _PLINHA
Conout("Função LjDrCriaTab - Fim da Atualização dos campos novos no Banco ")

//Alteração de campos que já existem no dicionário e tiveram suas consultas,etc mudados
cMensagem += "Adaptação de consultas padrões/Valids/Relacao de campos que chamam as tabelas novas" + _PLINHA
ConOut("Adaptação de consultas padrões/Valids/Relacao de campos que chamam as tabelas novas")

If SX3->(DbSeek(Padr("AIB_CODAPR",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_VALID WITH 'Vazio() .Or. ExistCpo("MHB",M->AIB_CODAPR)'
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

For nX := 1 to 5
	If SX3->(DbSeek(Padr("A1_CODPLF" + cValToChar(nX),nTamFld)))
		RecLock("SX3",.F.)
		REPLACE SX3->X3_VALID WITH 'ExistCpo("MHG",M->A1_CODPLF' + AllTrim(cValToChar(nX)) + ')'
		REPLACE SX3->X3_F3	  WITH 'MHG'
		SX3->(DbCommit())
		SX3->(MsUnLock())
	EndIf
	
	If SX3->(DbSeek(Padr("A1_PLANOF" + cValToChar(nX),nTamFld)))
		RecLock("SX3",.F.)
		REPLACE SX3->X3_RELACAO WITH 'IIF(!inclui, Posicione("MHG",1,xFilial("MHG")+SA1->A1_CODPLF' + AllTrim(cValToChar(nX)) + ',"MHG_NOME"),"" )'
		SX3->(DbCommit())
		SX3->(MsUnLock())
	EndIf
Next nX

If SX3->(DbSeek(Padr("B1_CODPRIN",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_VALID WITH 'ExistCpo("MHA",M->B1_CODPRIN)'
	REPLACE SX3->X3_F3	  WITH 'MHA'
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

If SX3->(DbSeek(Padr("B1_PRINATV",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_RELACAO WITH 'IIF(!inclui, Posicione("MHA",1,xFilial("MHA")+SB1->B1_CODPRIN,"MHA_PATIVO"),"")'
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

If SX3->(DbSeek(Padr("B1_CODAPRE",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_F3	  WITH 'MHB'
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

If SX3->(DbSeek(Padr("B1_APRESEN",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_RELACAO WITH 'IIF(!inclui, Posicione("MHB",1,xFilial("MHB")+SB1->B1_CODAPRE,"MHB_APRESE"),"")'
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

If SX3->(DbSeek(Padr("B1_CODSMPR",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_VALID WITH 'ExistCpo("MHC",M->B1_CODSMPR)'
	REPLACE SX3->X3_F3	  WITH 'MHC'
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

If SX3->(DbSeek(Padr("B1_SIMILPR",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_RELACAO WITH "IIF(!inclui, Posicione('MHC',1,xFilial('MHC')+SB1->B1_CODSMPR,'MHC_DESIMI'),'')"
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

If SX3->(DbSeek(Padr("LQ_PLDESC",nTamFld)))
	RecLock("SX3",.F.)
	REPLACE SX3->X3_RELACAO WITH 'IIF(!Empty(M->LQ_CPLFIDE),Posicione("MHG",1,xFilial("MHG")+M->LQ_CPLFIDE,"MHG_NOME"),"")'
	SX3->(DbCommit())
	SX3->(MsUnLock())
EndIf

cMensagem += "Final da Validação/Alteração de consultas padrões/Valids de campos que chamam as tabelas novas" + _PLINHA
Conout("Final da Validação/Alteração de consultas padrões/Valids de campos que chamam as tabelas novas")
For nI := 1 to Len(aArea)
	RestArea(aArea[nI])
Next nI

cMensagem += "Fim da função LjDrCriaTab, Finalizando a criação dos campos SX3" + _PLINHA
Conout("Fim da função LjDrCriaTab, Finalizando a criação dos campos SX3")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjClTable(cTable,cMensagem)
Função para clonar os campo de uma tabela para alterar para outra tabela 

@Param aTables 		- Array contendo a tabela origem e a tabela destino 
@Param cMensagem 	- Variavel para acumular as mensagens da funções
@Param aSX3Ori		- Array que deverá conter as informações do campo 
					  origem já para criar o campo destino

@Return 			-        

@author Rene Julian
@since 10/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjClTable(aTables,cMensagem,aSX3Ori)
Local cAliasOri 	:= aTables[1]
Local cAliasDes 	:= aTables[2]
Local cX3_campo 	:= ""
Local cX3_VldUser 	:= ""
Local aArea			:= {}
Local nX			:= 0
Local lLjVlTAFDro	:= LjVlTAFDro() 

DbSelectArea("SX3")
Aadd(aArea,SX3->(GetArea()))
SX3->(DbSetOrder(1)) 
SX3->(DbSeek(cAliasOri))
While !SX3->(Eof()) .AND. (SX3->X3_ARQUIVO == cAliasOri)
	If !lLjVlTAFDro .Or. (lLjVlTAFDro .And. (SX3->X3_PROPRI $ "T|U"))
		cX3_campo	:= cAliasDes +SubSTR(X3_CAMPO ,AT("_",X3_CAMPO),Len(X3_CAMPO))
		cX3_VldUser	:= LJAtuSX3(cAliasOri,cAliasDes,X3_VLDUSER, @cMensagem) 
		AAdd( aSX3Ori, { 															  ; //
			 cAliasDes																, ; //X3_ARQUIVO
			 X3_ORDEM																, ; //X3_ORDEM
			 cX3_campo																, ; //X3_CAMPO
			 X3_TIPO																, ; //X3_TIPO
			 X3_TAMANHO																, ; //X3_TAMANHO
			 X3_DECIMAL																, ; //X3_DECIMAL
			 X3_TITULO																, ; //X3_TITULO
			 IIf(Empty(AllTrim(X3_TITSPA)),X3_TITULO,X3_TITSPA)						, ; //X3_TITSPA
			 IIf(Empty(AllTrim(X3_TITENG)),X3_TITULO,X3_TITENG)						, ; //X3_TITENG
			 X3_DESCRIC																, ; //X3_DESCRIC
			 X3_DESCSPA																, ; //X3_DESCSPA
			 X3_DESCENG																, ; //X3_DESCENG
			 X3_PICTURE																, ; //X3_PICTURE
			 X3_VALID																, ; //X3_VALID
			 Replicate(Chr(128),15)													, ; //X3_USADO
			 X3_RELACAO																, ; //X3_RELACAO
			 X3_F3																	, ; //X3_F3
			 X3_NIVEL																, ; //X3_NIVEL
			 X3_RESERV																, ; //X3_RESERV
			 X3_CHECK																, ; //X3_CHECK
			 X3_TRIGGER																, ; //X3_TRIGGER
			 X3_PROPRI																, ; //X3_PROPRI
			 X3_BROWSE																, ; //X3_BROWSE
			 IIf(Empty(AllTrim(X3_VISUAL)),"A",X3_VISUAL)							, ; //X3_VISUAL
			 IIf(Empty(AllTrim(X3_CONTEXT)),"R",X3_CONTEXT)							, ; //X3_CONTEXT
			 X3_OBRIGAT																, ; //X3_OBRIGAT
			 cX3_VldUser															, ; //X3_VLDUSER
			 X3_CBOX																, ; //X3_CBOX
			 X3_CBOXSPA																, ; //X3_CBOXSPA
			 X3_CBOXENG																, ; //X3_CBOXENG
			 X3_PICTVAR																, ; //X3_PICTVAR
			 X3_WHEN																, ; //X3_WHEN
			 X3_INIBRW																, ; //X3_INIBRW
			 X3_GRPSXG																, ; //X3_GRPSXG
			 X3_FOLDER																, ; //X3_FOLDER
			 X3_PYME																} ) //X3_PYME
	EndIf
	SX3->(DbSkip())
End
cMensagem += "Gerando campos tabela origem "+ aTables[1] + " Tabela Destino " + aTables[2] + _PLINHA
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrAtuSX2(cMensagem)
Função para criar um aray com os novos campos padroes de tabelas 

@Param cMensagem - variavel para acumular as mensagens da funções


@Return aRet - Array que deverá conter a estrutura dos novos campos para 
        atualizar o SX2.
	
@author Rene Julian
@since 12/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjDrAtuSX2(cMensagem)
Local aRet 		:= {}
Local aArea		:= {}
Local aEstru    := {}
Local aDePara	:= {}
Local cPath     := ""
Local nI        := 0
Local nX        := 0
Local cAlias    := ""
Local cEmp      := ""

cMensagem += "Iniciando a função para incluir as novas tabela na SX2." + _PLINHA

aEstru := LjSxTable("5") // PEGA A ESTRUTURA DO SX2
aDePara:= LjSxTable("4")

DbSelectArea("SX2")
Aadd(aArea,SX2->(GetArea()))
SX2->(DbSetOrder(1))
SX2->(DbSeek("SL1"))
cPath := SX2->X2_PATH
cEmp  := Substr(SX2->X2_ARQUIVO,4,3)

For nX := 1 to Len(aDePara)
	Aadd(aDePara[nX],{"","",""})
	
	If SX2->(DbSeek(aDePara[nX][1]))
		aDePara[nX][3][1] := SX2->X2_MODO
		aDePara[nX][3][2] := SX2->X2_MODOUN
		aDePara[nX][3][3] := SX2->X2_MODOEMP
	EndIf
Next nX

//Criação da Tabela MHA
nX := Ascan(aDePara, {|x| x[2] == "MHA"}) 
If nX > 0
	aAdd(aRet,{	"MHA"		 					,; // X2_CHAVE
				cPath		 					,; // X2_PATH
				"MHA"+cEmp						,; // X2_ARQUIVO
				"Genericos e Similares"			,; // X2_NOME 
				"Genericos e Similares"			,; // X2_NOMESPA
				"Genericos e Similares"			,; // X2_NOMEENG
				0								,; // X2_DELET
				aDePara[nX][3][1]				,; // X2_MODO
				aDePara[nX][3][2]				,; // X2_MODOUN
				aDePara[nX][3][3]				,; // X2_MODOEMP
				""								,; // X2_TTS
				""								,; // X2_ROTINA
				"S"								,; // X2_PYME
				"MHA_FILIAL+MHA_CODIGO"			}) // "X2_UNICO"	
EndIf

//Criação da Tabela MHB
nX := Ascan(aDePara, {|x| x[2] == "MHB"})
If nX > 0
	aAdd(aRet,{	"MHB"		 					,; // X2_CHAVE
				cPath		 					,; // X2_PATH
				"MHB"+cEmp						,; // X2_ARQUIVO
				"Apresentacao"					,; // X2_NOME 
				"Apresentacao"					,; // X2_NOMESPA
				""								,; // X2_NOMEENG
				0								,; // X2_DELET
				aDePara[nX][3][1]				,; // X2_MODO
				aDePara[nX][3][2]				,; // X2_MODOUN
				aDePara[nX][3][3]				,; // X2_MODOEMP
				""								,; // X2_TTS
				""								,; // X2_ROTINA
				"S"								,; // X2_PYME
				"MHB_FILIAL+MHB_CODAPR+MHB_APRESE"}) // "X2_UNICO"	
EndIf
			
//Criação da Tabela MHC
nX := Ascan(aDePara, {|x| x[2] == "MHC"})
If nX > 0
	aAdd(aRet,{	"MHC"		 					,; // X2_CHAVE
				cPath		 					,; // X2_PATH
				"MHC"+cEmp						,; // X2_ARQUIVO
				"Similaridade"					,; // X2_NOME 
				"Similaridade"					,; // X2_NOMESPA
				""								,; // X2_NOMEENG
				0								,; // X2_DELET
				aDePara[nX][3][1]				,; // X2_MODO
				aDePara[nX][3][2]				,; // X2_MODOUN
				aDePara[nX][3][3]				,; // X2_MODOEMP
				""								,; // X2_TTS
				""								,; // X2_ROTINA
				"S"								,; // X2_PYME
				"MHC_FILIAL+MHC_CODSIM+MHC_DESIMI"}) // "X2_UNICO"	
EndIf
			
//Criação da Tabela MHD
nX := Ascan(aDePara, {|x| x[2] == "MHD"})
If nX > 0
	aAdd(aRet,{	"MHD"		 					,; // X2_CHAVE
				cPath		 					,; // X2_PATH
				"MHD"+cEmp						,; // X2_ARQUIVO
				"Cad. do Produto Kit"			,; // X2_NOME 
				"Cad. do Produto Kit"			,; // X2_NOMESPA
				""								,; // X2_NOMEENG
				0								,; // X2_DELET
				aDePara[nX][3][1]				,; // X2_MODO
				aDePara[nX][3][2]				,; // X2_MODOUN
				aDePara[nX][3][3]				,; // X2_MODOEMP
				""								,; // X2_TTS
				""								,; // X2_ROTINA
				"S"								,; // X2_PYME
				"MHD_FILIAL+MHD_PRODUT"			}) // "X2_UNICO"		
EndIf

//Criação da Tabela MHE
nX := Ascan(aDePara, {|x| x[2] == "MHE"})
If nX > 0
	aAdd(aRet,{	"MHE"		 					,; // X2_CHAVE
				cPath		 					,; // X2_PATH
				"MHE"+cEmp						,; // X2_ARQUIVO
				"Cad. dos Itens do Kit"			,; // X2_NOME 
				"Cad. dos Itens do Kit"			,; // X2_NOMESPA
				""								,; // X2_NOMEENG
				0								,; // X2_DELET
				aDePara[nX][3][1]				,; // X2_MODO
				aDePara[nX][3][2]				,; // X2_MODOUN
				aDePara[nX][3][3]				,; // X2_MODOEMP
				""								,; // X2_TTS
				""								,; // X2_ROTINA
				"S"								,; // X2_PYME
				"MHE_FILIAL+MHE_PRODUT+MHE_CODCOM+MHE_SEQUEN"}) // "X2_UNICO"	
EndIf

//Criação da Tabela MHF
nX := Ascan(aDePara, {|x| x[2] == "MHF"})
If nX > 0
	aAdd(aRet,{	"MHF"		 					,; // X2_CHAVE
				cPath		 					,; // X2_PATH
				"MHF"+cEmp						,; // X2_ARQUIVO
				"Cadastro de Convenio"			,; // X2_NOME 
				"Cadastro de Convenio"			,; // X2_NOMESPA
				"Cadastro de Convenio"			,; // X2_NOMEENG
				0								,; // X2_DELET
				aDePara[nX][3][1]				,; // X2_MODO
				aDePara[nX][3][2]				,; // X2_MODOUN
				aDePara[nX][3][3]				,; // X2_MODOEMP
				""								,; // X2_TTS
				""								,; // X2_ROTINA
				"S"								,; // X2_PYME
				"MHF_FILIAL+MHF_CODIGO"			}) // "X2_UNICO"		
EndIf

//Criação da Tabela MHG
nX := Ascan(aDePara, {|x| x[2] == "MHG"})
If nX > 0
	aAdd(aRet,{	"MHG"		 					,; // X2_CHAVE
				cPath		 					,; // X2_PATH
				"MHG"+cEmp						,; // X2_ARQUIVO
				"Planos de Fidelidade"			,; // X2_NOME 
				"Planos de Fidelidade"			,; // X2_NOMESPA
				"Planos de Fidelidade"			,; // X2_NOMEENG
				0								,; // X2_DELET
				aDePara[nX][3][1]				,; // X2_MODO
				aDePara[nX][3][2]				,; // X2_MODOUN
				aDePara[nX][3][3]				,; // X2_MODOEMP
				""								,; // X2_TTS
				""								,; // X2_ROTINA
				"S"								,; // X2_PYME
				"MHG_FILIAL+MHG_CODIGO+MHG_NOME"}) // "X2_UNICO"		
EndIf

For nI := 1 To Len(aRet)
	If !Empty(aRet[nI][1])
		If !SX2->(dbSeek(aRet[nI,1]))
						
			If !aRet[nI,1] $ cAlias
				cAlias += aRet[nI,1] + "/"
			EndIf
								 
			RecLock("SX2",.T.)
				
			For nX := 1 To Len(aRet[nI])
				If ColumnPos(aEstru[nX]) > 0						
					FieldPut(ColumnPos(aEstru[nX]),aRet[nI,nX])
				EndIf
			Next nX
				
			SX2->(DbCommit())
			SX2->(MsUnLock())
			
			#IFDEF TOP
				If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aRet[nI][14]  ) ), " ", "" ) )
					If MSFILE( RetSqlName( aRet[nI][1] ),RetSqlName( aRet[nI][1] ) + "_UNQ"  )
						TcInternal( 60, RetSqlName( aRet[nI][1] ) + "|" + RetSqlName( aRet[nI][1] ) + "_UNQ" )
						cMensagem += "Foi alterada a chave única da tabela " + aRet[nI][1] + _PLINHA
					Else
						cMensagem += "Foi criada a chave única da tabela " + aRet[nI][1] + _PLINHA
					EndIf
				EndIf
			#ENDIF
			
		EndIf
	EndIf
Next nI

If !Empty(cAlias)
	cMensagem += " Adição das novas tabelas [" + cAlias + "]" + _PLINHA
EndIf

cMensagem += "Finalização do processo da inclusão das nova tabelas no SX2 " + _PLINHA 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSIXORI(aTables,cMensagem)
Função para criar um aray com os novos campos padroes do AtuSX 

@Param aTables	 - array contendo os alias para modificação
@Param cMensagem - variavel para acumular as mensagens da funções

@Return aRet - Array que deverá conter a estrutura dos novos campos para 
        atualizar o SX3.
	
@author Rene Julian
@since 19/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LJSIXORI(aTables,cMensagem,aSixOri)
Local cAliasOri 	:= aTables[1]
Local cAliasDes 	:= aTables[2]
Local cIX_Chave 	:= ""
Local aArea			:= {}
Local lIndOKTpl		:= .T.
Local lLjVlTAFDro	:= LjVlTAFDro()

DbSelectArea("SIX")

Aadd(aArea,SIX->(GetArea()))

SIX->(DbSetOrder(1))
SIX->(DbSeek(cAliasOri))

While !SIX->(Eof()) .AND. (SIX->INDICE == cAliasOri)
	lIndOKTpl	 := .T.
	cIX_Chave:= Upper(AllTrim(LJAtuSX3(cAliasOri,cAliasDes,SIX->CHAVE, @cMensagem)))
	
	//Para garantir que só vai converter dados do Template de Drogaria
	If lLjVlTAFDro
		//Indica um índice que pertence ao Template de Drogaria
		lIndOKTpl := (AllTrim(SIX->PROPRI) $ "T|U") 
	EndIf
	
	//Indices que não são do template padrão, serão desconsiderados, caso haja TAF envolvido
	If lIndOKTpl
		AAdd(aSixOri,{	cAliasDes,;												//INDICE
						SIX->ORDEM,;											//ORDEM 
						cIX_Chave,;												//CHAVE
						SIX->DESCRICAO,;										//DESCRICAO
						SIX->DESCSPA,;											//DESCSPA
						SIX->DESCENG,;											//DESCENG
						SIX->PROPRI,;  											//PROPRI
						SIX->F3,;												//F3
						SIX->NICKNAME,;											//NICKNAME
						SIX->SHOWPESQ})											//SHOWPESQ
	EndIf
	SIX->(DbSkip())
End	

RestArea(aArea[1])
				
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAtuSXI(cMensagem)
Função para criar um aray com os novos campos padroes do AtuSX 

@Param cTable 		- Alias da tabela para retorno dos Indices 
@Param cMensagem 	- variavel para acumular as mensagens da funções
@Param aSIXDes 		- Array com os indices que serão criados
@Param cOrder		- ultimo order usado da tabela

@Return 
	
@author Rene Julian
@since 12/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjAtuSXI(cTable,cMensagem,aSIXDes,cOrder)
Local aRet := {}
Local nX   := 0
Local nY   := 0

cMensagem += "Iniciando a função para incluir os indices na tabela SIX." + _PLINHA

If cTable == "MHA"
	cOrder := "2"  //ultimo order 
	AAdd(aSIXDes,{	"MHA",; 													//INDICE
				"1",;															//ORDEM 
				"MHA_FILIAL+MHA_CODIGO+MHA_PATIVO",;							//CHAVE
				"Filial + Codigo + Princ Ativo.",;								//DESCRICAO
				"Filial + Codigo + Princ Ativo.",;								//DESCSPA
				"Filial + Codigo + Princ Ativo.",;								//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ
	
	AAdd(aSIXDes,{	"MHA",; 													//INDICE
				"2",;															//ORDEM 
				"MHA_FILIAL+MHA_PATIVO+MHA_CODIGO",;							//CHAVE
				"Filial  + Princ Ativo + Codigo.",;								//DESCRICAO
				"Filial  + Princ Ativo + Codigo.",;								//DESCSPA
				"Filial  + Princ Ativo + Codigo.",;								//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ
EndIf

If cTable == "MHB"
	cOrder := "2"  //ultimo order 
	AAdd(aSIXDes,{	"MHB",; 													//INDICE
				"1",;															//ORDEM 
				"MHB_FILIAL+MHB_CODAPR+MHB_APRESE",;							//CHAVE
				"Filial  + Cod. Apres + Apresent.",;							//DESCRICAO
				"Filial  + Cod. Apres + Apresent.",;							//DESCSPA
				"Filial  + Cod. Apres + Apresent.",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ	
	
	AAdd(aSIXDes,{	"MHB",; 													//INDICE
				"2",;															//ORDEM 
				"MHB_FILIAL+MHB_APRESE+MHB_CODAPR",;							//CHAVE
				"Filial  + Apresent + Cod. Apres.",;							//DESCRICAO
				"Filial  + Apresent + Cod. Apres.",;							//DESCSPA
				"Filial  + Apresent + Cod. Apres.",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ
EndIf					

If cTable == "MHC"
	cOrder := "2"  //ultimo order 
	AAdd(aSIXDes,{	"MHC",; 													//INDICE
				"1",;															//ORDEM 
				"MHC_FILIAL+MHC_CODSIM+MHC_DESIMI",;							//CHAVE
				"Filial  + Cod Simil + Similarid.",;							//DESCRICAO
				"Filial  + Cod Simil + Similarid.",;							//DESCSPA
				"Filial  + Cod Simil + Similarid.",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ				
	
	AAdd(aSIXDes,{	"MHC",; 													//INDICE
				"2",;															//ORDEM 
				"MHC_FILIAL+MHC_DESIMI+MHC_CODSIM",;							//CHAVE
				"Filial  + Similarid. + Cod Simil",;							//DESCRICAO
				"Filial  + Similarid. + Cod Simil",;							//DESCSPA
				"Filial  + Similarid. + Cod Simil",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ 
EndIf						

If cTable == "MHD"
	cOrder := "1"  //ultimo order 
	AAdd(aSIXDes,{	"MHD",; 													//INDICE
				"1",;															//ORDEM 
				"MHD_FILIAL+MHD_PRODUT",;										//CHAVE
				"Filial  + Codigo Produto Kit",;								//DESCRICAO
				"Filial  + Codigo Produto Kit",;								//DESCSPA
				"Filial  + Codigo Produto Kit",;								//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ	
EndIf

If cTable == "MHE"
	cOrder := "1"  //ultimo order 
	AAdd(aSIXDes,{	"MHE",; 													//INDICE
				"1",;															//ORDEM 
				"MHE_FILIAL+MHE_PRODUT+MHE_CODCOM+MHE_SEQUEN",;					//CHAVE
				"Filial+CodProd+CodCompon+SeqComp",;							//DESCRICAO
				"Filial+CodProd+CodCompon+SeqComp",;							//DESCSPA
				"Filial+CodProd+CodCompon+SeqComp",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ	
EndIf				

If cTable == "MHF"	
	cOrder := "1"  //ultimo order 		
	AAdd(aSIXDes,{	"MHF",; 													//INDICE
				"1",;															//ORDEM 
				"MHF_FILIAL+MHF_CODIGO",;										//CHAVE
				"Filial + Codigo Convenio.",;									//DESCRICAO
				"Filial + Codigo Convenio.",;									//DESCSPA
				"Filial + Codigo Convenio.",;									//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ
EndIf			
				
If cTable == "MHG"	
	cOrder := "3"  //ultimo order 		
	AAdd(aSIXDes,{	"MHG",; 													//INDICE
				"1",;															//ORDEM 
				"MHG_FILIAL+MHG_CODIGO+MHG_NOME",;								//CHAVE
				"Filial + Cod. Plano + Nome Plano",;							//DESCRICAO
				"Filial + Cod. Plano + Nome Plano",;							//DESCSPA
				"Filial + Cod. Plano + Nome Plano",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ	
	
	AAdd(aSIXDes,{	"MHG",; 													//INDICE
				"2",;															//ORDEM 
				"MHG_FILIAL+MHG_TIPO+MHG_CODIGO+MHG_NOME",;						//CHAVE
				"Filial+T.Plano+CodPlano+N.Plano ",;							//DESCRICAO
				"Filial+T.Plano+CodPlano+N.Plano ",;							//DESCSPA
				"Filial+T.Plano+CodPlano+N.Plano ",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ	
	
	AAdd(aSIXDes,{	"MHG",; 													//INDICE
				"3",;															//ORDEM 
				"MHG_FILIAL+MHG_CODREG+MHG_CODIGO+MHG_TIPO",;						//CHAVE
				"Filial+CodRegra+CodPlano+T.Plano ",;							//DESCRICAO
				"Filial+CodRegra+CodPlano+T.Plano ",;							//DESCSPA
				"Filial+CodRegra+CodPlano+T.Plano ",;							//DESCENG
				"S",;  															//PROPRI
				"",;															//F3
				"",;															//NICKNAME
				"S"})															//SHOWPESQ
EndIf																
			
cMensagem += "Inclusão dos indices na SIX realizado." + _PLINHA
 			
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRetCPSX3(ctable,cMensagem)
Função para retornar a estrutura dos campo que deverão ser criados

@Param cTable	 - Tabela que deverá ser retornado os campos 
@Param cMensagem - variavel para acumular as mensagens da funções


@Return aRet - Array que deverá conter a estrutura dos novos campos para 
        atualizar o SX3.
	
@author Rene Julian
@since 12/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjRetCPSX3(cTable,cMensagem)
Local aSX3 	 		:= {}
Local aArea			:= {}
Local cOrdem 		:= "00"
Local cUsadoKey 	:= ""
Local cReservKey	:= ""
Local cUsadoObr		:= "" 
Local cReservObr	:= ""
Local cUsadoOpc		:= ""
Local cReservOpc	:= ""
Local cUsadoNao		:= ""
Local cReservNao	:= ""
Local nI            := 0
Local nTamSX3		:= 0

DbSelectArea("SX3")

nTamSX3 := Len(SX3->X3_CAMPO)

Aadd(aArea,SX3->(GetArea()))

cMensagem += "Inicio da função LjRetCPSX3 para a criação da estrutura dos campos de conversão." + _PLINHA

cOrdem  := Soma1(cOrdem)

/* Obtendo valores para USADO e RESERV */
cUsadoKey	:= "€€€€€€€€€€€€€€°"
cReservKey	:= "ƒ€"

cUsadoObr	:= "€€€€€€€€€€€€€€ "
cReservObr	:= "“€"

cUsadoOpc	:= "€€€€€€€€€€€€€€ "
cReservOpc	:= "’À"

cUsadoNao	:= "€€€€€€€€€€€€€€€"
cReservNao	:= "€€"

//
// Campos Tabela MHA
//
If cTable == 'MHA'
	aAdd( aSX3, { ;
	    'MHA'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHA_FILIAL'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Filial"	                                                             	, ; //X3_TITULO
	    "Filial" 		                                                          	, ; //X3_TITSPA 
	    "Filial"		                                                           	, ; //X3_TITENG
	    "Filial do Sistema"        					                                , ; //X3_DESCRIC
	    "Filial do Sistema"					                                        , ; //X3_DESCSPA
	    "Filial do Sistema"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoNao  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservNao 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '033'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHA'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHA_CODIGO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    6				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Cod.Princ."                                                             	, ; //X3_TITULO
	    "Cod.Princ."	                                                          	, ; //X3_TITSPA 
	    "Cod.Princ."	                                                           	, ; //X3_TITENG
	    "Código do Principio Ativo"  				                                , ; //X3_DESCRIC
	    "Código do Principio Ativo"			                                        , ; //X3_DESCSPA
	    "Código do Principio Ativo"	                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    'ExistChav("MHA",M->MHA_CODIGO)'	                                       	, ; //X3_VALID
		cUsadoKey  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservKey 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME    
	    
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHA'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHA_PATIVO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    25				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Princ.Ativo"                                                             	, ; //X3_TITULO
	    "Princ.Ativo"	                                                          	, ; //X3_TITSPA 
	    "Princ.Ativo"	                                                           	, ; //X3_TITENG
	    "Principio Ativo"			  				                                , ; //X3_DESCRIC
	    "Principio Ativo"					                                        , ; //X3_DESCSPA
	    "Principio Ativo"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''									                                       	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME        
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHA'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHA_OBSALT'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    150				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Obs Inc/Alt"                                                             	, ; //X3_TITULO
	    "Obs Inc/Alt"	                                                          	, ; //X3_TITSPA 
	    "Obs Inc/Alt"	                                                           	, ; //X3_TITENG
	    "Obs de Inclusao/Alteracao"  				                                , ; //X3_DESCRIC
	    "Obs de Inclusao/Alteracao"			                                        , ; //X3_DESCSPA
	    "Obs de Inclusao/Alteracao"	                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''									                                       	, ; //X3_VALID
		cUsadoKey  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservKey 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME  
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHA'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHA_USVEND'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    25				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Alterado por"                                                             	, ; //X3_TITULO
	    "Alterado por"	                                                          	, ; //X3_TITSPA 
	    "Alterado por"	                                                           	, ; //X3_TITENG
	    "Alterado pelo usuario"		  				                                , ; //X3_DESCRIC
	    "Alterado pelo usuario"				                                        , ; //X3_DESCSPA
	    "Alterado pelo usuario"	 	                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''									                                       	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME   
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHA'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHA_USAPRO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    25				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Aprovado por"                                                             	, ; //X3_TITULO
	    "Aprovado por"	                                                          	, ; //X3_TITSPA 
	    "Aprovado por"	                                                           	, ; //X3_TITENG
	    "Aprovado por Usuario"		  				                                , ; //X3_DESCRIC
	    "Aprovado por Usuario"				                                        , ; //X3_DESCSPA
	    "Aprovado por Usuario"	 	                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''									                                       	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME            
EndIf

If cTable ==  'MHB'
	cOrdem  := "00"
	cOrdem  := Soma1(cOrdem)
	//
	// Campos Tabela MHB
	//
	aAdd( aSX3, { ;
	    'MHB'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHB_FILIAL'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Filial"	                                                             	, ; //X3_TITULO
	    "Filial" 		                                                          	, ; //X3_TITSPA 
	    "Filial"		                                                           	, ; //X3_TITENG
	    "Filial do Sistema"        					                                , ; //X3_DESCRIC
	    "Filial do Sistema"					                                        , ; //X3_DESCSPA
	    "Filial do Sistema"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoNao  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservNao 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '033'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHB'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHB_CODAPRE'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    6				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Cod.Apresent"                                                             	, ; //X3_TITULO
	    "Cod.Apresent"	                                                          	, ; //X3_TITSPA 
	    "Cod.Apresent"	                                                           	, ; //X3_TITENG
	    "Cód. Apresentação"        					                                , ; //X3_DESCRIC
	    "Cód. Apresentação"					                                        , ; //X3_DESCSPA
	    "Cód. Apresentação"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoKey  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservKey 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME          
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHB'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHB_APRESE'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    20				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Apresentação"                                                             	, ; //X3_TITULO
	    "Apresentação"	                                                          	, ; //X3_TITSPA 
	    "Apresentação"	                                                           	, ; //X3_TITENG
	    "Apresentação"	        					                                , ; //X3_DESCRIC
	    "Apresentação"						                                        , ; //X3_DESCSPA
	    "Apresentação"				                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME   
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHB'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHB_GRUPO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    4				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Grupo"		                                                             	, ; //X3_TITULO
	    "Grupo"	    		                                                      	, ; //X3_TITSPA 
	    "Grupo"	            		                                               	, ; //X3_TITENG
	    "Grupo Apresentação"	    				                                , ; //X3_DESCRIC
	    "Grupo Apresentação"				                                        , ; //X3_DESCSPA
	    "Grupo Apresentação"			                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    0                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	    
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHB'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHB_OBSALT'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    150				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Grupo" 	                                                            	, ; //X3_TITULO
	    "Obs Alt/Inc"  		                                                      	, ; //X3_TITSPA 
	    "Obs Alt/Inc"          		                                               	, ; //X3_TITENG
	    "Obs. Alteração/Inclusão"    				                                , ; //X3_DESCRIC
	    "Obs. Alteração/Inclusão"			                                        , ; //X3_DESCSPA
	    "Obs. Alteração/Inclusão"		                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoKey  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservKey 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHB'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHB_USVEND'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    25				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Aprovado por"                                                             	, ; //X3_TITULO
	    "Aprovado por"  		                                                   	, ; //X3_TITSPA 
	    "Aprovado por"          		                                           	, ; //X3_TITENG
	    "Alterado pelo usuario"	    				                                , ; //X3_DESCRIC
	    "Alterado pelo usuario"				                                        , ; //X3_DESCSPA
	    "Alterado pelo usuario"			                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHB'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHB_USAPRO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    25				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Aprovado por"                                                             	, ; //X3_TITULO
	    "Aprovado por"  		                                                   	, ; //X3_TITSPA 
	    "Aprovado por"          		                                           	, ; //X3_TITENG
	    "Alterado pelo usuario"	    				                                , ; //X3_DESCRIC
	    "Alterado pelo usuario"				                                        , ; //X3_DESCSPA
	    "Alterado pelo usuario"			                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
EndIf

If cTable == 'MHC'	    
	cOrdem  := "00"
	cOrdem  := Soma1(cOrdem)
	//
	// Campos Tabela MHC
	//
	aAdd( aSX3, { ;
	    'MHC'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHC_FILIAL'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Filial"	                                                             	, ; //X3_TITULO
	    "Filial" 		                                                          	, ; //X3_TITSPA 
	    "Filial"		                                                           	, ; //X3_TITENG
	    "Filial do Sistema"        					                                , ; //X3_DESCRIC
	    "Filial do Sistema"					                                        , ; //X3_DESCSPA
	    "Filial do Sistema"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoNao  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservNao 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '033'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME   
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHC'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHC_CODSIM'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    6				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Cod.Similiar"                                                             	, ; //X3_TITULO
	    "Cod.Similiar"	                                                          	, ; //X3_TITSPA 
	    "Cod.Similiar"	                                                           	, ; //X3_TITENG
	    "Codigo de Similiaridade"  					                                , ; //X3_DESCRIC
	    "Codigo de Similiaridade"			                                        , ; //X3_DESCSPA
	    "Codigo de Similiaridade"	                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    'ExistChav("MHC",M->MHC_CODSIM)'                                           	, ; //X3_VALID
		cUsadoKey  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservKey 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	    
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHC'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHC_DESIMI'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    20				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Desc.Similar"                                                             	, ; //X3_TITULO
	    "Desc.Similar"	                                                          	, ; //X3_TITSPA 
	    "Desc.Similar"	                                                           	, ; //X3_TITENG
	    "Descricao do Similar"  					                                , ; //X3_DESCRIC
	    "Descricao do Similar"				                                        , ; //X3_DESCSPA
	    "Descricao do Similar"	    	                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME     
	    
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHC'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHC_DESIMI'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    20				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Desc.Similar"                                                             	, ; //X3_TITULO
	    "Desc.Similar"	                                                          	, ; //X3_TITSPA 
	    "Desc.Similar"	                                                           	, ; //X3_TITENG
	    "Descricao do Similar"  					                                , ; //X3_DESCRIC
	    "Descricao do Similar"				                                        , ; //X3_DESCSPA
	    "Descricao do Similar"	    	                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME  
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHC'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHC_OBSALT'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    150				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Obs Inc/Alt"                                                             	, ; //X3_TITULO
	    "Obs Inc/Alt"	                                                          	, ; //X3_TITSPA 
	    "Obs Inc/Alt"	                                                           	, ; //X3_TITENG
	    "Obs de Inclusao/Alteracao"					                                , ; //X3_DESCRIC
	    "Obs de Inclusao/Alteracao"			                                        , ; //X3_DESCSPA
	    "Obs de Inclusao/Alteracao"    	                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoKey  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservKey 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	    
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHC'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHC_USVEND'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    25				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Alterado por"                                                             	, ; //X3_TITULO
	    "Alterado por"	                                                          	, ; //X3_TITSPA 
	    "Alterado por"	                                                           	, ; //X3_TITENG
	    "Alterado pelo usuario"						                                , ; //X3_DESCRIC
	    "Alterado pelo usuario"				                                        , ; //X3_DESCSPA
	    "Alterado pelo usuario"    	                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoKey  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservKey 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME  
	    
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHC'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHC_USAPRO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    25				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Aprovado por"                                                             	, ; //X3_TITULO
	    "Aprovado por"	                                                          	, ; //X3_TITSPA 
	    "Aprovado por"	                                                           	, ; //X3_TITENG
	    "Aprovado pelo Usuario"						                                , ; //X3_DESCRIC
	    "Aprovado pelo Usuario"				                                        , ; //X3_DESCSPA
	    "Aprovado pelo Usuario"    	                                            	, ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME      
EndIf
	    
If ctable == 'MHD'    
	cOrdem  := "00"
	cOrdem  := Soma1(cOrdem)
	//
	// Campos Tabela MHD
	//
	aAdd( aSX3, { ;
	    'MHD'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHD_FILIAL'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Filial"	                                                             	, ; //X3_TITULO
	    "Filial" 		                                                          	, ; //X3_TITSPA 
	    "Filial"		                                                           	, ; //X3_TITENG
	    "Filial do Sistema"        					                                , ; //X3_DESCRIC
	    "Filial do Sistema"					                                        , ; //X3_DESCSPA
	    "Filial do Sistema"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoNao  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservNao 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '033'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	
	cOrdem  := Soma1(cOrdem)
	    
	aAdd( aSX3, { ;
	    'MHD'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHD_PRODUT'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Produto"	                                                             	, ; //X3_TITULO
	    "Produto" 		                                                          	, ; //X3_TITSPA 
	    "Produto"		                                                           	, ; //X3_TITENG
	    "Código do Produto"        					                                , ; //X3_DESCRIC
	    "Código do Produto"					                                        , ; //X3_DESCSPA
	    "Código do Produto"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoObr  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservObr 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME  
	
	cOrdem  := Soma1(cOrdem)
	aAdd( aSX3, { ;
	    'MHD'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHD_DESCRI'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    30				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Descrição"	                                                             	, ; //X3_TITULO
	    "Descrição"		                                                          	, ; //X3_TITSPA 
	    "Descrição"		                                                           	, ; //X3_TITENG
	    "Descrição do Produto"     					                                , ; //X3_DESCRIC
	    "Descrição do Produto"				                                        , ; //X3_DESCSPA
	    "Descrição do Produto"		                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                         								                   	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    'T_A004DESCRI("MHD_DESCRI")'                                               	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    'Texto()'                                                                  	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME  
EndIf

If cTable == 'MHE'
	cOrdem  := "00"
	cOrdem  := Soma1(cOrdem)
	//
	// Campos Tabela MHE
	//
	aAdd( aSX3, { ;
	    'MHE'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHE_FILIAL'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Filial"	                                                             	, ; //X3_TITULO
	    "Filial" 		                                                          	, ; //X3_TITSPA 
	    "Filial"		                                                           	, ; //X3_TITENG
	    "Filial do Sistema"        					                                , ; //X3_DESCRIC
	    "Filial do Sistema"					                                        , ; //X3_DESCSPA
	    "Filial do Sistema"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoNao  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservNao 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '033'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME   
	
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHE'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHE_PRODUT'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    30				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Produto"	                                                             	, ; //X3_TITULO
	    "Produto" 		                                                          	, ; //X3_TITSPA 
	    "Produto"		                                                           	, ; //X3_TITENG
	    "Código do Produto"        					                                , ; //X3_DESCRIC
	    "Código do Produto"					                                        , ; //X3_DESCSPA
	    "Código do Produto"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''              			                                            	, ; //X3_VALID
		cUsadoObr  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservObr 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    'ExistCpo("SB1")'                                                          	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME         
	    
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHE'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHE_CODCOM'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    30				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Componente"	                                                           	, ; //X3_TITULO
	    "Componente" 		                                                       	, ; //X3_TITSPA 
	    "Componente"		                                                       	, ; //X3_TITENG
	    "Codigo do Componente"     					                                , ; //X3_DESCRIC
	    "Codigo do Componente"				                                        , ; //X3_DESCSPA
	    "Codigo do Componente"		                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''              			                                            	, ; //X3_VALID
		cUsadoObr  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservObr 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    'ExistCpo("SB1",M->MHE_CODCOM) .And. T_A004Comp()'                         	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '030'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME                                                                                    
	        
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHE'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHE_SEQUEN'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Sequencia"		                                                           	, ; //X3_TITULO
	    "Sequencia" 		                                                       	, ; //X3_TITSPA 
	    "Sequencia"			                                                       	, ; //X3_TITENG
	    "Sequencia do Componente"  					                                , ; //X3_DESCRIC
	    "Sequencia do Componente"			                                        , ; //X3_DESCSPA
	    "Sequencia do Componente"	                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''              			                                            	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''												                         	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME                                                                                    
	                
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHE'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHE_DESCRI'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    30				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Descrição"		                                                           	, ; //X3_TITULO
	    "Descrição" 		                                                       	, ; //X3_TITSPA 
	    "Descrição"			                                                       	, ; //X3_TITENG
	    "Descrição do Componente"  					                                , ; //X3_DESCRIC
	    "Descrição do Componente"			                                        , ; //X3_DESCSPA
	    "Descrição do Componente"	                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''              			                                            	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''												                         	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME          
	        
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHE'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHE_QUANT'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    9				                                                       		, ; //X3_TAMANHO
	    2         	                                                             	, ; //X3_DECIMAL
	    "Quantidade"	                                                           	, ; //X3_TITULO
	    "Quantidade"		                                                       	, ; //X3_TITSPA 
	    "Quantidade"		                                                       	, ; //X3_TITENG
	    "Quantidade Utilizada"  					                                , ; //X3_DESCRIC
	    "Quantidade Utilizada"				                                        , ; //X3_DESCSPA
	    "Quantidade Utilizada"		                                                , ; //X3_DESCENG
	    '@E 999,999.99'                                                            	, ; //X3_PICTURE
	    ''              			                                            	, ; //X3_VALID
		cUsadoObr  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservObr 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'N'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''												                         	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME      
EndIf

If ctable == 'MHF' 	    
	cOrdem  := "00"
	cOrdem  := Soma1(cOrdem)
	//
	// Campos Tabela MHF
	//
	aAdd( aSX3, { ;
	    'MHF'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHF_FILIAL'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Filial"	                                                             	, ; //X3_TITULO
	    "Filial" 		                                                          	, ; //X3_TITSPA 
	    "Filial"		                                                           	, ; //X3_TITENG
	    "Filial do Sistema"        					                                , ; //X3_DESCRIC
	    "Filial do Sistema"					                                        , ; //X3_DESCSPA
	    "Filial do Sistema"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoNao  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservNao 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '033'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	    
	cOrdem  := Soma1(cOrdem)	
	aAdd( aSX3, { ;
	    'MHF'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHF_CODIGO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    6				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Código"	                                                             	, ; //X3_TITULO
	    "Código" 		                                                          	, ; //X3_TITSPA 
	    "Código"		                                                           	, ; //X3_TITENG
	    "Código"    		    					                                , ; //X3_DESCRIC
	    "Código"							                                        , ; //X3_DESCSPA
	    "Código"			        		                                        , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    'ExistChav("MHF",M->MHF_CODIGO)'                                           	, ; //X3_VALID
		cUsadoObr  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservObr 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME              
	
	cOrdem  := Soma1(cOrdem)
	aAdd( aSX3, { ;
	    'MHF'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHF_NOME' 	                                                        		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    20				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Nome"		                                                             	, ; //X3_TITULO
	    "Nome" 			                                                          	, ; //X3_TITSPA 
	    "Nome"		    	                                                       	, ; //X3_TITENG
	    "Nome"    		    						                                , ; //X3_DESCRIC
	    "Nome"								                                        , ; //X3_DESCSPA
	    "Nome"			        			                                        , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    'ExistChav("MHF",M->MHF_CODIGO)'                                           	, ; //X3_VALID
		cUsadoObr  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservObr 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME              
EndIf

If cTable == 'MHG' 
	cOrdem  := "00"
	cOrdem  := Soma1(cOrdem)
	//
	// Campos Tabela MHG
	//
	aAdd( aSX3, { ;
	    'MHG'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHG_FILIAL'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    2				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Filial"	                                                             	, ; //X3_TITULO
	    "Filial" 		                                                          	, ; //X3_TITSPA 
	    "Filial"		                                                           	, ; //X3_TITENG
	    "Filial do Sistema"        					                                , ; //X3_DESCRIC
	    "Filial do Sistema"					                                        , ; //X3_DESCSPA
	    "Filial do Sistema"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''                                                                      	, ; //X3_VALID
		cUsadoNao  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservNao 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    '033'                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	                
	cOrdem  := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	    'MHG'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHG_CODIGO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    6				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Código Plano"	                                                           	, ; //X3_TITULO
	    "Código Plano" 	                                                          	, ; //X3_TITSPA 
	    "Código Plano"		                                                       	, ; //X3_TITENG
	    "Codigo do Plano"        					                                , ; //X3_DESCRIC
	    "Codigo do Plano"					                                        , ; //X3_DESCSPA
	    "Codigo do Plano"			                                                , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    'ExistChav("SA1",M->MHG_CODIGO)'                                           	, ; //X3_VALID
		cUsadoObr  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cUsadoObr 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	
	cOrdem  := Soma1(cOrdem)
	                                
	aAdd( aSX3, { ;
	    'MHG'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHG_CODIGO'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    6				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Nome Plano"	                                                           	, ; //X3_TITULO
	    "Nome Plano" 	                                                          	, ; //X3_TITSPA 
	    "Nome Plano"		                                                       	, ; //X3_TITENG
	    "Nome do Plano"        						                                , ; //X3_DESCRIC
	    "Nome do Plano"					    	                                    , ; //X3_DESCSPA
	    "Nome do Plano"			        	                                        , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME 
	                                                                
	cOrdem  := Soma1(cOrdem)
	                                
	aAdd( aSX3, { ;
	    'MHG'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHG_CODREG'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    6				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Cod.Regra"	     	                                                      	, ; //X3_TITULO
	    "Cod.Regra" 	                                                          	, ; //X3_TITSPA 
	    "Cod.Regra"		         	                                              	, ; //X3_TITENG
	    "Codigo da Regra"      						                                , ; //X3_DESCRIC
	    "Codigo da Regra"				    	                                    , ; //X3_DESCSPA
	    "Codigo da Regra"			       	                                        , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME                                 
	                
	cOrdem  := Soma1(cOrdem)
	                                
	aAdd( aSX3, { ;
	    'MHG'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHG_REGRA'                                                         		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    30				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Regra"	     	   		                                                   	, ; //X3_TITULO
	    "Regra" 	            	                                              	, ; //X3_TITSPA 
	    "Regra"		         	    	                                          	, ; //X3_TITENG
	    "Descrição da Regra"      					                                , ; //X3_DESCRIC
	    "Descrição da Regra"				   	                                    , ; //X3_DESCSPA
	    "Descrição da Regra"			                                            , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    ''								                                           	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'V'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME                   
	                
	cOrdem  := Soma1(cOrdem)
	                                
	aAdd( aSX3, { ;
	    'MHG'                                                                   	, ; //X3_ARQUIVO
	    cOrdem                                                                   	, ; //X3_ORDEM
	    'MHG_TIPO'        	                                                 		, ; //X3_CAMPO
	    'C'                                                                     	, ; //X3_TIPO
	    1				                                                       		, ; //X3_TAMANHO
	    0                                                                       	, ; //X3_DECIMAL
	    "Tipo Plano"	   		                                                   	, ; //X3_TITULO
	    "Tipo Plano" 	           	                                              	, ; //X3_TITSPA 
	    "Tipo Plano"		   	    	                                          	, ; //X3_TITENG
	    "Tipo de Plano"     	 					                                , ; //X3_DESCRIC
	    "Tipo de Plano"						   	                                    , ; //X3_DESCSPA
	    "Tipo de Plano"			        		                                    , ; //X3_DESCENG
	    ''     	                                                                	, ; //X3_PICTURE
	    'Pertence("1234")'				                                           	, ; //X3_VALID
		cUsadoOpc  																	, ;	//X3_USADO
	    ''                                                                      	, ; //X3_RELACAO
	    ''                                                                      	, ; //X3_F3
	    1                                                                       	, ; //X3_NIVEL
	    cReservOpc 			                                                		, ; //X3_RESERV
	    ''                                                                      	, ; //X3_CHECK
	    ''                                                                      	, ; //X3_TRIGGER
	    'S'	                                                                     	, ; //X3_PROPRI
	    'S'                                                                     	, ; //X3_BROWSE
	    'A'                                                                     	, ; //X3_VISUAL
	    'R'                                                                     	, ; //X3_CONTEXT
	    ''                                                                      	, ; //X3_OBRIGAT
	    ''                                                                      	, ; //X3_VLDUSER
	    ''                                                                      	, ; //X3_CBOX
	    ''                                                                      	, ; //X3_CBOXSPA
	    ''                                                                      	, ; //X3_CBOXENG
	    ''                                                                      	, ; //X3_PICTVAR
	    ''                                                                      	, ; //X3_WHEN
	    ''                                                                      	, ; //X3_INIBRW
	    ''                                                                      	, ; //X3_GRPSXG
	    ''                                                                      	, ; //X3_FOLDER
	    'S'                                                                      	} ) //X3_PYME
EndIf
	    
cMensagem += "Fim da função LjRetCPSX3, estrutura dos campos de conversão realizado." + _PLINHA

RestArea(aArea[1])

Return aSX3

//-------------------------------------------------------------------
/*/{Protheus.doc} LjMensagem()
Função Tem o objetivo de montar um texto explicando essa funcionalidade e 
para quem deve ser atendido com essa modificação.

@Return cRet - Retorna o texto a ser apresentado na parte de baixo explicando
               a finalidade desse fonte. 

@author Rene Julian
@since 17/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LjMensagem()
Local cRet := ""

cRet := "         IMPORTATE - LEIA ANTES DE CONFIRMA OU CANCELAR." + _PLINHA + _PLINHA
cRet += "Foi encontrado a utilização do template de Drogaria, " +_PLINHA
cRet += "deverá ser realizado a conversão de algumas tabelas para que " + _PLINHA
cRet += "o Template funcione na versão P12.1.17." + _PLINHA 
cRet += "Essa funcionalidade tem como objetivo realizar a troca dessas " + _PLINHA
cRet += "tabelas pois essas não serão mais utlizadas pelo template, " + _PLINHA
cRet += "e serão utilizadas pelo TAF(Totvs Automação Fiscal)." + _PLINHA 
cRet += "As seguintes tabelas deverão de ser utilizadas e ao lado é " + _PLINHA
cRet += "apresentado as novas tabelas:" + _PLINHA
cRet += "LEK	- MHA - Genericos e Similares" + _PLINHA
cRet += "LEL	- MHB - Apresentacao" + _PLINHA
cRet += "LEM	- MHC - Similaridade" + _PLINHA
cRet += "LEQ	- MHD - Cad. do Produto Kit" + _PLINHA
cRet += "LER	- MHE - Cad. dos Itens do Kit" + _PLINHA
cRet += "LES	- MHF - Cadastro de Convenio" + _PLINHA
cRet += "LEU	- MHG - Planos de Fidelidade" + _PLINHA
cRet += "Ao final da rotina serão criadas as novas tabelas e realizaremos " +  _PLINHA
cRet += "a exclusão da tabelas anteriores." +  _PLINHA
cRet += "Qualquer duvida entre em contato com o Help Desk do Varejo." +  _PLINHA

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJAtuSX3(cAliasOri,cAliasDes,X3_VLDUSER, cMensagem)
Função Tem o objetivo retornar o conteudo do campo X3_VLDUSER com a  
modificação de Alias caso possua. 

@Param cAliasOri 	 - Alias original da Tabela que será substituido
@Param cAliasDes 	 - Alias novo que deverá substituir o alias
@Param X3_VLDUSER 	 - Array com a estrutura e contudo dos campos
@Param cMensagem	 - variavel para acumular as mensagens da funções

@Return cRet - Retorna o conteudo do campo X3_VLDUSER com a modificação
               do alias.
             

@author Rene Julian
@since 17/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LJAtuSX3(cAliasOri,cAliasDes,cVLDUSER,cMensagem)
Local cRet 		:= cVLDUSER
Local cBusca	:= ""

cMensagem += "Iniciou a função LJAtuSX3 para acerto do X3_VLDUSER" + _PLINHA

// inicia a procura do alias
cBusca := cAliasOri + "->"
If AT(cBusca,cRet)  > 0
	cRet := STRTRAN(cRet,cBusca,cAliasDes+ "->")
EndIf 
cBusca := "'"+cAliasOri+"'"
If AT(cBusca,cRet)  > 0
	cRet := STRTRAN(cRet,cBusca,"'"+cAliasDes+"'")
EndIf 
cBusca := '"'+cAliasOri+'"'
If AT(cBusca,cRet)  > 0
	cRet := STRTRAN(cRet,cBusca,'"'+cAliasDes+'"')
EndIf    
cBusca := cAliasOri+'_'
If AT(cBusca,cRet)  > 0
	cRet := STRTRAN(cRet,cBusca,cAliasDes+'_')
EndIf

cMensagem += "Finalizou a função LJAtuSX3 para acerto do X3_VLDUSER - [" + cRet + "]"+ _PLINHA

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJDrAtuDados(cMensagem)
Função Tem o objetivo inclui os registros nas tabelas novas.

@Param cMensagem	 - variavel para acumular as mensagens da funções

@Return              

@author Rene Julian
@since 23/01/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function LJDrAtuDados(cMensagem)
Local aTables 	:= LjSxTable("4") // Retorna um array com as novas tabelas
Local cAliasDes := ""
Local cAliasOri	:= ""
Local nX  	  	:= 0
Local nI        := 0
Local nCout   	:= 0
Local nTamFld	:= 0
Local aCampOri  := {}
Local lIsDelet	:= .F.
Local lLjVlTAFDro:= LjVlTAFDro()
Local aArea		:= {}
Local lTopConn   := .F.

cMensagem += "Inicio da Validação da função LJDrAtuDados" + _PLINHA 

#IFDEF TOP
	lTopConn := .T.
#ENDIF

DbSelectArea( "SX3" )
AAdd(aArea, SX3->(GetArea()))
nTamFld := Len(SX3->X3_CAMPO)

For nX := 1 to Len(aTables)
	cAliasOri := aTables[nX][1]	
	cAliasDes := aTables[nX][2]
	nCout := 0
	
	SX3->(DbSetOrder(1)) //X3_ARQUIVO
	If SX3->(DbSeek(cAliasOri))
		While !SX3->(Eof()) .AND. (AllTrim(SX3->X3_ARQUIVO) == cAliasOri)
			If SX3->X3_PROPRI $ "T|U"
				AADD(aCampOri, SubStr(SX3->X3_CAMPO , 4, Len(SX3->X3_CAMPO)))
			EndIf
			SX3->(DbSkip())
		End
	Else
		Loop
	EndIf	
	
	/*
	Dá problema caso a tabela já tenha sido deletada do banco
	portanto elimino valido a existência da mesma
	*/
	If lIsTop .And. IIf(lTopConn, !TCCanOpen(RetSqlName(cAliasOri)), .T. )
		Loop
	Else
		DbSelectArea( cAliasOri )
		(cAliasOri)->(DbSetOrder(1))
		(cAliasOri)->(DbGotop())
	EndIf
		
	nCout := IIf( (cAliasOri)->(Eof()) , 0 , 1 )
	
	If TableInDic(cAliasDes) .And. nCout > 0  // Se a tabela existir e a tabela origem contiver registros
		
		nCout := 0
		DbSelectArea( cAliasDes )
		(cAliasDes)->(DbSetOrder(1))
		(cAliasDes)->(DbGotop())
		nCout := IIf( (cAliasDes)->(Eof()) , 0 , 1 )
		
		If nCout > 0 // Caso a tabela possua registros esses devem ser excluidos
			While (cAliasDes)->(!EOF())
				cMensagem += " A tabela de destino (" + cAliasDes +") possui dados e estes serão excluídos para evitar problemas de duplicidade de registros " + _PLINHA
				Conout(" A tabela de destino (" + cAliasDes +") possui dados e estes serão excluídos para evitar problemas de duplicidade de registros ")
				RecLock(cAliasDes , .F.)
				(cAliasDes)->(DbDelete())
				(cAliasDes)->(DbCommit())
				(cAliasDes)->(MsUnLock())
				(cAliasDes)->(DbSkip())
			End
		EndIf

		(cAliasOri)->(DbGotop())
		While !(cAliasOri)->(Eof()) 
			cMensagem += " Populando a Tabela (" + cAliasDes +") " + _PLINHA
			Conout(" Populando a Tabela (" + cAliasDes +") ")
			
			RecLock(cAliasDes , .T.)
			For nI := 1 to Len(aCampOri)
				If (cAliasDes)->(ColumnPos(cAliasDes+aCampOri[nI])) > 0
					REPLACE (cAliasDes)->&(cAliasDes+aCampOri[nI]) WITH (cAliasOri)->&(cAliasOri+aCampOri[nI])
					
					If lLjVlTAFDro //Caso haja campos do TAF, devo "zerar" os campos que eram do Template
						RecLock(cAliasOri,.F.)
						If ValType((cAliasOri)->&(cAliasOri+aCampOri[nI])) $ "C|M"
							REPLACE (cAliasOri)->&(cAliasOri+aCampOri[nI]) WITH ""
						ElseIf ValType((cAliasOri)->&(cAliasOri+aCampOri[nI])) == "N"
							REPLACE (cAliasOri)->&(cAliasOri+aCampOri[nI]) WITH 0
						ElseIf ValType((cAliasOri)->&(cAliasOri+aCampOri[nI])) == "D"
							REPLACE (cAliasOri)->&(cAliasOri+aCampOri[nI]) WITH cToD("")
						ElseIf ValType((cAliasOri)->&(cAliasOri+aCampOri[nI])) == "L"
							REPLACE (cAliasOri)->&(cAliasOri+aCampOri[nI]) WITH .F.
						EndIf
						(cAliasOri)->(MsUnlock())
					EndIf
				EndIf
			Next nI	
			(cAliasDes)->(MsUnlock())
			
			/*	1- Faço a busca do antigo campo para deletar do SX3, somente quando tem TAF envolvido
				2- Quando não possui TAF, deleto toda a tabela antiga do SX3 direto	*/
			If !lLjVlTAFDro
				//Deleto o registro somente se não tiver o TAF envolvido
				cMensagem += " Deletando dado da Tabela (" + cAliasOri +") " + _PLINHA
				Conout(" Deletando dado da Tabela (" + cAliasOri +") ")
				RecLock(cAliasOri , .F.)
				(cAliasOri)->(DbDelete())
				(cAliasOri)->(DbCommit())
				(cAliasOri)->(MsUnLock())
			EndIf
			
			(cAliasOri)->(DbSkip())
		End
		
		(cAliasDes)->(DbCloseArea())
	Else
		If nCout == 0
			cMensagem += "Tabela :"+cAliasOri + " não possui informação"   + _PLINHA
		Else
			cMensagem += "Tabela :"+cAliasDes + " não pode ser criada"   + _PLINHA
		EndIf
	EndIf
	
	(cAliasOri)->(DbCloseArea())

	IF lLjVlTAFDro
		SX3->(DbSetOrder(2)) //X3_CAMPO
		For nI := 1 to Len(aCampOri)
			If SX3->((dbSeek(PadR(cAliasOri + aCampOri[nI],nTamFld)))) .And. SX3->X3_PROPRI == "T"
				RecLock("SX3",.F.)
				SX3->(DbDelete())
				SX3->(DbCommit())
				SX3->(MsUnLock())
				cMensagem += " Exclusão do campo no alias antigo [" + cOldField + "]" + _PLINHA
			EndIf
		Next nI
	Else
		If lIsTop
			//Apaga a tabela antiga do banco pois deve ser criada conforme a estrutura de tabela do TAF
			Conout(" Antes da Deleção da Tabela [" + cAliasOri + "] para o Template de Drogaria")
			cMensagem += " Antes da Deleção da Tabela [" + cAliasOri + "] para o Template de Drogaria" + _PLINHA
			
			lIsDelet := .F.
			If TcCanOpen(cAliasOri)
				lIsDelet := TCDelFile(RetSQLName(cAliasOri)) .Or. TCDelFile(cAliasOri)
				cMensagem += "Aplicação do comando TCDelFile - tabela [" + cAliasOri + "] - Sucesso : " + IIF(lIsDelet,"SIM","NÃO")
				Conout("Aplicação do comando TCDelFile - tabela [" + cAliasOri + "] - Sucesso : " + IIF(lIsDelet,"SIM","NÃO"))
			EndIf
			
			cMensagem += " Depois da Deleção no banco da Tabela [" + cAliasOri + "] para o Template de Drogaria - Retorno : " + IIF(lIsDelet,"SIM","NÃO" + _PLINHA + TcSqlError()) + _PLINHA
			Conout(" Depois da Deleção no banco da Tabela [" + cAliasOri + "] para o Template de Drogaria - Retorno : " + IIF(lIsDelet,"SIM","NÃO" + _PLINHA + TcSqlError() ))
		Else
			//Verificar com excluir os arquivos CTREE e DBF da pasta
		EndIf
	EndIf
Next nX	

cMensagem += "Fim da Validação da função LJDrAtuDados" + _PLINHA 

For nX := 1 to Len(aArea)
	RestArea(aArea[nX])
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaX2(cMensagem)

Inserção dos SX2 e SIX (e alteração tbm) dos quais eram criados
pelos UPDDROXXX's

@Param cMensagem - variavel para acumular as mensagens da funções
@author Julio.nery
@since 12/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaX2(cMensagem)
Local aSIX		:= {}
Local aSX2		:= {}
Local aEstruSIX	:= LjSxTable("6")	//Retorna um array com a estrutura do SIX
Local aEstruSX2	:= LjSxTable("5")	//Retorna um array com a estrutura do SIX
Local cPath		:= ""
Local cEmp		:= ""
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nTamFld	:= 0

cMensagem += " Início da função LjDrCriaX2 para inclusão/ajuste de SX2 e SIX" + _PLINHA
ConOut(" Início da função LjDrCriaX2 para inclusão/ajuste de SX2 e SIX ")

SX2->(DbSetOrder(1))
SX2->(DbSeek("SL1"))
cPath := SX2->X2_PATH

/*-------------------------------------
		GRAVAÇÃO DO SX2
-------------------------------------*/
/*
{"X2_CHAVE"		,	"X2_PATH"		,	"X2_ARQUIVO"	,	"X2_NOME"	, ;	
 "X2_NOMESPA"	,	"X2_NOMEENG"	,	"X2_DELET"		,	"X2_MODO"	, ;
 "X2_MODOUN"	,	"X2_MODOEMP"	,	"X2_TTS"		,	"X2_ROTINA"	, ;
 "X2_PYME"		,	"X2_UNICO"		}
*/
aAdd( aSX2, { ;
		'LKD'																		, ; //X2_CHAVE
		cPath																		, ; //X2_PATH
		'LKD'																		, ; //X2_ARQUIVO
		"Denominação Comum Brasileira"												, ; //X2_NOME
		"Denominação Comum Brasileira"												, ; //X2_NOMESPA
		"Denominação Comum Brasileira"												, ; //X2_NOMEENG
		0																			, ; //X2_DELET
		'C'																			, ; //X2_MODO
		'C'																			, ; //X2_MODOUN
		'C'																			, ; //X2_MODOEMP		
		''																			, ; //X2_TTS
		''																			, ; //X2_ROTINA
		'S'																			, ; //X2_PYME
		'LKD_FILIAL+LKD_CODDCB'														} ) //X2_UNICO

For nX := 1 To Len( aSX2 )
	If !SX2->(DbSeek(aSX2[nX,1])) //SX2 - só permito incluir
		
		cMensagem += " Função LjDrCriaX2 - Inclusão da Tabela " + aSX2[nX,1] + _PLINHA
		Conout(" Função LjDrCriaX2 - Inclusão da Tabela " + aSX2[nX,1] )  
		
		RecLock( "SX2", .T. )
		
		For nY := 1 To Len( aSX2[nX] )
			nPos := SX2->( ColumnPos( aEstruSX2[nY] ))
			If nPos > 0
				If aEstruSX2[nY] == "X2_ARQUIVO"
					FieldPut( nPos, aSX2[nX][nY] + cEmpAnt +  "0" )
				Else
					FieldPut( nPos, aSX2[nX][nY] )
				EndIf
			EndIf
		Next nY
		
		SX2->( dbCommit() )
		SX2->( MsUnLock() )		
	EndIf
Next nX

/*-------------------------------------
		GRAVAÇÃO DO SIX
-------------------------------------*/
aAdd( aSIX ,{"LKB" ,"2" ,"LKB_FILIAL+LKB_CRF"	,"Numero CRF"	, "Numero CRF"	, "Numero CRF"	, "T", "S", "", ""} )
aAdd( aSIX ,{"LKB" ,"3" ,"LKB_FILIAL+LKB_CUSERI","Cod. Usuario"	, "Cod. Usuario", "Cod. Usuario", "T", "S", "", ""} )
aAdd( aSIX ,{"LKD" ,"1" ,"LKD_FILIAL+LKD_CODDCB","Codigo DCB"	, "Codigo DCB"	, "Codigo DCB"	, "T", "S", "", ""} )
aAdd( aSIX ,{"LK9" ,"6" ,"LK9_FILIAL+LK9_NUMORC","Núm. Orcamento", "Núm. Orcamento", "Núm. Orcamento", "T", "S", "", ""} )

nTamFld := Len(SIX->INDICE)
SIX->( dbSetOrder(1) )	//"INDICE+ORDEM"

For nX := 1 To Len(aSIX)
	lNewReg := !SIX->( dbSeek(PadR(aSIX[nX][1],nTamFld) + aSIX[nX][2]) )

	RecLock("SIX",lNewReg)
	For nY := 1 To Len(aSIX[nX])
		nPos := SIX->(ColumnPos(aEstruSIX[nY]))
		If nPos > 0
			FieldPut(nPos,aSIX[nX,nY])
		EndIf
	Next nY
	SIX->( dbCommit() )
	SIX->( MsUnLock() )
	
	Conout("Criado/Alterado o indice [" + aSIX[nX][2] + "] da tabela " + aSIX[nX][1])
	cMensagem += "Criado/Alterado o indice [" + aSIX[nX][2] + "] da tabela " + aSIX[nX][1] + _PLINHA
Next nX

cMensagem += " Fim da função LjDrCriaX2 de inclusão/ajuste de SX2 e SIX"
ConOut(" Fim da função LjDrCriaX2 para inclusão/ajuste de SX2 e SIX ")

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaX7(cMensagem)
Ajuste de SX7 tem os campos do SX7 do aplicador ( que contem 
os SX7's dos UPDDRO's também)

@Param cMensagem - variavel para acumular as mensagens da funções
@author Julio.nery
@since 01/03/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaX7(cMensagem)
Local aEstruSX7	:= LjSxTable('7')
Local aSX7		:= {}
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nTamFld	:= 0
Local lNewField	:= .F.

nTamFld := Len(SX7->X7_CAMPO)

cMensagem += "Inicio da função LjDrCriaX7 - ajuste da SX7" + _PLINHA
ConOut("Inicio da função LjDrCriaX7 - ajuste da SX7")

/*
{"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC","X7_PROPRI"}
*/
For nX := 1 To 5
	aAdd(aSX7,{"A1_CODPLF" + AllTrim(cValToChar(nX)),"001","MHG->MHG_NOME",;
		"A1_CODPLF" + AllTrim(cValToChar(nX)),"P","S","MHG",1,'xFilial("MHG")+M->A1_CODPLF' + AllTrim(cValToChar(nX)),"","T"} )
Next nX

aAdd(aSX7,{"B1_CODAPRE","001","MHB->MHB_APRESE","B1_APRESEN","P","S","MHB",1,'xFilial("MHB")+M->B1_CODAPRE', "", "T"} )
aAdd(aSX7,{"B1_CODCOTL","001","LEO->LEO_CONDES","B1_CONTROL","P","S","LEO",1,'xFilial("LEO")+M->B1_CODCOTL', "", "T"} )
aAdd(aSX7,{"B1_CODFAB" ,"001","Posicione('SA2',1,xFilial('SA2')+M->B1_CODFAB+M->B1_LOJA,'A2_NOME')","B1_FABRIC","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"B1_CODPATO","001","LIP->LIP_DESC","B1_PATOLOG","P","S","LIP",1,'xFilial("LIP")+M->B1_CODPATO', "", "T"} )
aAdd(aSX7,{"B1_CODPRIN","001","MHA->MHA_PATIVO","B1_PRINATV","P","S","MHA",1,'xFilial("MHA")+M->B1_CODPRIN', "", "T"} )
aAdd(aSX7,{"B1_CODSMPR","001","MHC->MHC_DESIMI","B1_SIMILPR","P","S","MHC",1,'xFilial("MHC")+M->B1_CODSMPR', "", "T"} )
aAdd(aSX7,{"B1_LOJA"   ,"001","Posicione('SA2',1,xFilial('SA2')+M->B1_CODFAB+M->B1_LOJA,'A2_NOME')","B1_FABRIC","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"L2_PRODUTO","020","IIF(LA5->(DbSeek(xFilial('MHD')+M->L2_PRODUTO)),T_TDRG001,M->L2_PRODUTO)","L2_PRODUTO","P","N","MHD",0,'', "", "T"} )
aAdd(aSX7,{"LHF_CONDIC","001","SE4->E4_DESCRI","LHF_DESCRI","P","S","SE4",1,'xFilial("SE4")+M->LHF_CONDIC', "", "T"} )
aAdd(aSX7,{"LHG_CODIGO","001","Posicione('SA1',1,xFilial('SA1')+M->LHG_CODIGO+M->LHG_LOJA,'A1_NOME')","LHG_NOME","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"LHG_LOJA"  ,"001","Posicione('SA1',1,xFilial('SA1')+M->LHG_CODIGO+M->LHG_LOJA,'A1_NOME')","LHG_NOME","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"LHH_BRINDE","001","SB1->B1_DESC","LHH_DESCBR","P","S","SB1",1,'xFilial("SB1")+M->LHH_BRINDE', "", "T"} )
aAdd(aSX7,{"LK9_CODPRO","001","SB1->B1_DESC","LK9_DESCRI","P","S","SB1",1,'xFilial("SB1")+M->LK9_CODPRO', "", "T"} )
aAdd(aSX7,{"LK9_CODPRO","002","SB1->B1_CLASSTE","LK9_CLASST","P","S","SB1",1,"xFilial('SB1')+M->LK9_CODPRO","","T"} )
aAdd(aSX7,{"LQ_CPLFIDE","001","MHG->MHG_NOME","LQ_PLDESC","P","S","MHG",1,'xFilial("SB1")+M->LQ_CPLFIDE', "", "T"} )
aAdd(aSX7,{"LR_PRODUTO","001","T_TDREG001()","","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"LHU_CODFOR","001","SA2->A2_NOME","LHU_FORNEC","P","S","SA2",1,'xFilial("SA2")+M->LHU_CODFOR+M->LHU_LOJAF', "", "T"} )
aAdd(aSX7,{"LHU_CODPAG","001","SE4->E4_DESCRI","LHU_DESCPG","P","S","SE4",1,'xFilial("SE4")+M->LHU_CODPAG', "", "T"} )
aAdd(aSX7,{"LHU_LOJAF","001","SA2->A2_NOME","LHU_FORNEC","P","S","SA2",1,'xFilial("SA2")+M->LHU_CODFOR+M->LHU_LOJAF', "", "T"} )
aAdd(aSX7,{"LFU_CODFIL","001","SM0->M0_NOME","LFU_NOME","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"LJG_FORNEC","001","Posicione('SA2',1,xFilial('SA2')+M->LJG_FORNEC+SA2->A2_LOJA,'A2_NOME')","LJG_NOMFOR","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"LJG_FORNEC","002","SA2->A2_LOJA","LJG_LOJA","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"LHV_FORNEC","001","SA2->A2_NREDUZ","LHV_NOMFOR","P","N","",0,'', "", "T"} )
aAdd(aSX7,{"LHV_FORNEC","002","SA2->A2_LOJA","LHV_LOJA","P","N","",0,'', "", "T"} )

For nX := 1 to Len(aSX7)
 	lNewField := !SX7->( DbSeek( PadR(aSX7[nX][1],nTamFld) + aSX7[nX][2] ) )
 	
 	cMensagem += "Função LjDrCriaX7 - inclusão/alteração de SX7 - [" + aSX7[nX][1] + "-" + aSX7[nX][2] + "]" + _PLINHA
 	ConOut(" função LjDrCriaX7 - inclusão/alteração de SX7 - [" + aSX7[nX][1] + "-" + aSX7[nX][2] + "]")
 	
 	If aSX7[nX][1] == "L2_PRODUTO"
 		While !SX7->(Eof()) .And. AllTrim(SX7->X7_CAMPO) == aSX7[nX][1]
		
			If AllTrim(SX7->X7_PROPRI) == "T"
				Exit
			EndIf
			
			SX7->(DbSkip())
		End
 	EndIf
	
	RecLock("SX7",lNewField)
	For nY:=1 To Len(aSX7[nX])
		nPos := ColumnPos(aEstruSX7[nY])
		If nPos > 0
			FieldPut(nPos,aSX7[nX,nY])
		EndIf
	Next nY
	SX7->(DbCommit())
	SX7->(MsUnLock())
Next nX

cMensagem += "Término da função LjDrCriaX7 - ajuste da SX7" + _PLINHA
ConOut("Término da função LjDrCriaX7 - ajuste da SX7")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJDrClDic(cMensagem)
Limpa dicionários para permitir que o TAF crie sem interferência 
do TPL de Drogaria

@Param cMensagem - variavel para acumular as mensagens da funções
@author Julio.nery
@since 01/03/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LJDrClDic(cMensagem)
Local aOldAls	:= LjSxTable("2")
Local aArea		:= {}
Local nX		:= 0

cMensagem += " Inicio da função LJDrClDic - para limpeza de dicionário sem informações do TAF"
Conout(" Inicio da função LJDrClDic - para limpeza de dicionário sem informações do TAF")

DbSelectArea("SIX")
DbSelectArea("SX2")
DbSelectArea("SX3")

Aadd(aArea,SIX->(GetArea()))
Aadd(aArea,SX2->(GetArea()))
Aadd(aArea,SX3->(GetArea()))

SX2->(DbSetOrder(1)) //X2_ALIAS
SX3->(DbSetOrder(1)) //X3_ARQUIVO

For nX := 1 to Len(aOldAls)
	SIX->(DbSeek(aOldAls[nX]))
	While !SIX->(Eof()) .And.;
	 	SIX->INDICE == aOldAls[nX] .And. SIX->PROPRI == "T"
	 	
	 	If lIsTop
			TcInternal(60,RetSqlName(SIX->INDICE) + "|" + RetSqlName(SIX->INDICE) + SIX->ORDEM) //Exclui sem precisar baixar o TOP
		Endif
		RecLock("SIX",.F.)
		SIX->(DbDelete())
		SIX->(DbCommit())
		SIX->(MsUnlock())
		
		SIX->(DbSkip())
	End	
	
	SX3->(DbSeek(aOldAls[nX]))
	While !SX3->(Eof()) .And.;
	 	SX3->X3_ARQUIVO == aOldAls[nX] .And. SX3->X3_PROPRI == "T"
	 	
		RecLock("SX3",.F.)
		SX3->(DbDelete())
		SX3->(DbCommit())
		SX3->(MsUnlock())
		
		SX3->(DbSkip())
	End	
	
	If SX2->(DbSeek(aOldAls[nX]))
		RecLock("SX2",.F.)
		SX2->(DbDelete())
		SX2->(DbCommit())
		SX2->(MsUnlock())
	EndIf
Next nX

cMensagem += " Fim da função LJDrClDic - para limpeza de dicionário sem informações do TAF"
Conout(" Fim da função LJDrClDic - para limpeza de dicionário sem informações do TAF")

For nX:=1 to Len(aArea)
	RestArea(aArea[nX])
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaXB(cMensagem)
Ajuste de SXB

@Param cMensagem - variavel para acumular as mensagens da funções
@author Julio.nery
@since 06/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaXB(cMensagem)

Local aDados	:= {}
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nTamFld	:= 0
Local lNewReg	:= .F.
Local aEstrut	:= LjSxTable("8")

nTamFld := Len(SXB->XB_ALIAS)
SXB->(DbSetOrder(1))

cMensagem += "Inicio da função LjDrCriaXB, criação da SXB" + _PLINHA
ConOut("Inicio da função LjDrCriaXB, criação da SXB")

//MHA
Aadd(aDados,{"MHA","1","01","DB","Principio Ativo","Principio Ativo","Principio Ativo","MHA",""})
Aadd(aDados,{"MHA","2","01","01","Codigo","Codigo","Codigo","",""})
Aadd(aDados,{"MHA","3","01","01","Cadastra Novo","Cadastra Novo","Cadastra Novo","01",""})
Aadd(aDados,{"MHA","4","01","01","Cod.Princ.","Cod.Princ.","Cod.Princ.","MHA_CODIGO",""})
Aadd(aDados,{"MHA","4","01","02","Princ.Ativo","Princ.Ativo","Princ.Ativo","MHA_PATIVO",""})
Aadd(aDados,{"MHA","5","01","","","","","MHA->MHA_CODIGO",""})

//MHB
Aadd(aDados,{"MHB","1","01","DB","Apresentacao","Apresentacao","Apresentacao","MHB",""})
Aadd(aDados,{"MHB","2","01","02","Apresentacao","Apresentacao","Apresentacao","",""})
Aadd(aDados,{"MHB","2","02","01","Codigo","Codigo","Codigo","",""})
Aadd(aDados,{"MHB","4","01","01","Apresentacao","Apresentacao","Apresentacao","MHB_APRESE",""})
Aadd(aDados,{"MHB","4","01","02","Codigo","Codigo","Codigo","MHB_CODAPR",""})
Aadd(aDados,{"MHB","4","02","01","Codigo","Codigo","Codigo","MHB_CODAPR",""})
Aadd(aDados,{"MHB","4","02","02","Apresentacao","Apresentacao","Apresentacao","MHB_APRESE",""})
Aadd(aDados,{"MHB","5","01","","","","","MHB->MHB_CODAPR",""})
Aadd(aDados,{"MHB","6","01","","","","","SUBSTR(M->B1_GRUPO,1,1)==SUBSTR(MHB->MHB_GRUPO,1,1)",""})

//MHC
Aadd(aDados,{"MHC","1","01","DB","Similaridade","Similaridade","Similaridade","MHC",""})
Aadd(aDados,{"MHC","2","01","02","Similaridade","Similaridade","Similaridade","",""})
Aadd(aDados,{"MHC","2","02","01","Codigo","Codigo","Codigo","",""})
Aadd(aDados,{"MHC","4","01","01","Similaridade","Similaridade","Similaridade","MHC_DESIMI",""})
Aadd(aDados,{"MHC","4","01","02","Codigo","Codigo","Codigo","MHC_CODSIM",""})
Aadd(aDados,{"MHC","4","02","01","Codigo","Codigo","Codigo","MHC_CODSIM",""})
Aadd(aDados,{"MHC","4","02","02","Similaridade","Similaridade","Similaridade","MHC_DESIMI",""})
Aadd(aDados,{"MHC","5","01","","","","","MHC->MHC_CODSIM",""})

//MHF
Aadd(aDados,{"MHF","1","01","DB","Convenio","Convenio","Convenio","MHF",""})
Aadd(aDados,{"MHF","2","01","01","Codigo","Codigo","Codigo","",""})
Aadd(aDados,{"MHF","4","01","01","Codigo","Codigo","Codigo","MHF_CODIGO",""})
Aadd(aDados,{"MHF","4","01","02","Nome","Nome","Nome","MHF_NOME",""})
Aadd(aDados,{"MHF","5","01","","","","","MHF->MHF_CODIGO",""})
Aadd(aDados,{"MHF","5","02","","","","","Posicione('MHF',1,xFilial('MHF')+M->A1_CODCONV,'MHF_NOME')",""})

//MHG
Aadd(aDados,{"MHG","1","01","DB","Planos de Fidelidade","Planos de Fidelidade","Planos de Fidelidade","MHG",""})
Aadd(aDados,{"MHG","2","01","01","Codigo","Codigo","Codigo","",""})
Aadd(aDados,{"MHG","2","02","02","Nome","Nome","Nome","",""})
Aadd(aDados,{"MHG","2","03","03","Tipo","Tipo","Tipo","",""})
Aadd(aDados,{"MHG","3","01","01","Cadastra Novo","Cadastra Novo","Cadastra Novo","01",""})
Aadd(aDados,{"MHG","4","01","01","Codigo","Codigo","Codigo","MHG_CODIGO",""})
Aadd(aDados,{"MHG","4","01","02","Nome","Nome","Nome","SubStr(MHG_NOME,1,30)",""})
Aadd(aDados,{"MHG","4","02","01","Nome","Nome","Nome","SubStr(MHG_NOME,1,30)",""})
Aadd(aDados,{"MHG","4","02","02","Codigo","Codigo","Codigo","MHG_CODIGO",""})
Aadd(aDados,{"MHG","4","03","01","Tipo","Tipo","Tipo","MHG_TIPO",""})
Aadd(aDados,{"MHG","5","01","","","","","MHG->MHG_CODIGO",""})

//L52
Aadd(aDados,{"L52","1","01","DB","Apresentacao","Apresentacao","Apresentacao","MHB",""})
Aadd(aDados,{"L52","2","01","02","Apresentacao","Apresentacao","Apresentacao","",""})
Aadd(aDados,{"L52","2","02","01","Codigo","Codigo","Codigo","",""})
Aadd(aDados,{"L52","4","01","01","Apresentacao","Apresentacao","Apresentacao","MHB_APRESE",""})
Aadd(aDados,{"L52","4","01","02","Codigo","Codigo","Codigo","MHB_CODAPR",""})
Aadd(aDados,{"L52","4","02","01","Codigo","Codigo","Codigo","MHB_CODAPR",""})
Aadd(aDados,{"L52","4","02","02","Apresentacao","Apresentacao","Apresentacao","MHB_APRESE",""})
Aadd(aDados,{"L52","5","01","","","","","MHB->MHB_CODAPR",""})
Aadd(aDados,{"L52","5","02","","","","","MHB->MHB_APRESE",""})

//LX5T7
Aadd(aDados,{"LX5T7","1","01","DB","Tipo de Medicamento","Tipo de Medicamento","Tipo de Medicamento","LX5",""})
Aadd(aDados,{"LX5T7","2","01","01","Tabela+Chave","Tabela+Chave","Tabela+Chave","",""})
Aadd(aDados,{"LX5T7","4","01","01","Chave","Chave","Chave","LX5_CHAVE",""})
Aadd(aDados,{"LX5T7","4","01","02","Descrição","Descrição","Descrição","LX5_DESCRI",""})
Aadd(aDados,{"LX5T7","5","01","","","","","LX5->LX5_CHAVE",""})
Aadd(aDados,{"LX5T7","5","02","","","","","LX5->LX5_DESCRI",""})
Aadd(aDados,{"LX5T7","6","01","","","","","LX5->LX5_TABELA == 'T7'",""})

//LX5T8D
Aadd(aDados,{"LX5T8D","1","01","DB","Lista de Medicamento","Lista de Medicamento","Lista de Medicamento","LX5",""})
Aadd(aDados,{"LX5T8D","2","01","01","Tabela+Chave","Tabela+Chave","Tabela+Chave","",""})
Aadd(aDados,{"LX5T8D","4","01","01","Chave","Chave","Chave","LX5_CHAVE",""})
Aadd(aDados,{"LX5T8D","4","01","02","Descrição","Descrição","Descrição","LX5_DESCRI",""})
Aadd(aDados,{"LX5T8D","5","01","","","","","LX5->LX5_CHAVE",""})
Aadd(aDados,{"LX5T8D","5","02","","","","","LX5->LX5_DESCRI",""})
Aadd(aDados,{"LX5T8D","6","01","","","","","LX5->LX5_TABELA == 'T8'",""})

//LKB2
Aadd(aDados,{"LKB2","1","01","DB","Farmacêutico Resp.","Farmacêutico Resp.","Farmacêutico Resp.","LKB",""})
Aadd(aDados,{"LKB2","2","01","01","CPF","CPF","CPF","",""})
Aadd(aDados,{"LKB2","4","01","01","CPF","CPF","CPF","LKB_CPF",""})
Aadd(aDados,{"LKB2","4","01","02","Nome","Nome","Nome","LKB_NOME",""})
Aadd(aDados,{"LKB2","4","01","03","Responsável","Responsável","Responsável","LKB_RESPON",""})
Aadd(aDados,{"LKB2","5","01","","","","","LKB->LKB_CPF",""})
Aadd(aDados,{"LKB2","6","01","","","","","DRORESPON()",""})

//LKDDCB
Aadd(aDados,{"LKDDCB","1","01","DB","Código DCB","Código DCB","Código DCB","LKD",""})
Aadd(aDados,{"LKDDCB","2","01","01","Código DCB","Código DCB","Código DCB","",""})
Aadd(aDados,{"LKDDCB","4","01","01","Código DCB","Código DCB","Código DCB","LKD_CODDCB",""})
Aadd(aDados,{"LKDDCB","4","01","02","Desc. DCB","Desc. DCB","Desc. DCB","LKD_DSCDCB",""})
Aadd(aDados,{"LKDDCB","5","01","","","","","LKD->LKD_CODDCB",""})

//LX5T6
Aadd(aDados,{"LX5T6","1","01","RE","Motivo de Perda","Motivo de Perda","Motivo de Perda","LKD",""})
Aadd(aDados,{"LX5T6","2","01","01","","","",".T.",""})
Aadd(aDados,{"LX5T6","5","01","","","","","T_TPLCONPAD('LK9_MTVPER')",""})

//SB8
Aadd(aDados,{"SB8","6",NIL,NIL,NIL,NIL,NIL,"T_DroSB8()",NIL}) //Esse índice deve ser somente alterado

For nX := 1 to Len(aDados)
	Conout(" Criando/Alterando o Gatilho - [" + aDados[nX,1] + aDados[nX,2] + "]")
	cMensagem += " Criando/Alterando o Gatilho - [" + aDados[nX,1] + aDados[nX,2] + "]"
	
	If aDados[nX,3] == NIL .Or. aDados[nX,4] == NIL
		lNewReg := !SXB->(DbSeek(Padr(aDados[nX,1],nTamFld)+aDados[nX,2]))
	Else	
		lNewReg := !SXB->(DbSeek(Padr(aDados[nX,1],nTamFld)+aDados[nX,2]+aDados[nX,3]+aDados[nX,4]))
	EndIf
	
	RecLock("SXB",lNewReg)
    For nY:= 1 To Len(aDados[nX])
    	nPos := SXB->(ColumnPos(aEstrut[nY]))
        If nPos > 0 .And. aDados[nX,nY] <> NIL
            FieldPut(nPos,aDados[nX,nY])
        EndIf
    Next nY
    SXB->(dbCommit())
    SXB->(MsUnLock())
Next nX

/***************************
Exclusão de Consulta Padrão
****************************/
If SXB->(DbSeek(PadR("SB8",nTamFld) +"5" + "02"))	// Alias SB8 - Tipo 5 - Sequência 02
	RecLock("SXB",.F.)
	SXB->(DbDelete())
	SXB->(MsUnLock()) 
EndIf

cMensagem += "Término da função LjDrCriaXB, ajuste da SXB" + _PLINHA
ConOut("Término da função LjDrCriaXB, ajuste da SXB")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaX6(cMensagem)
Ajuste de SX6

@Param cMensagem - variavel para acumular as mensagens da funções
@author Julio.nery
@since 11/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaX6(cMensagem)
Local aDados	:= {}
Local aEstrut	:= LjSxTable("9")
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local lNewReg	:= .F.
Local nTamFil   := 0
Local nTamVar   := 0
Local cTamFil	:= ""
Local cLegenda1	:= ""
Local cLegenda2	:= ""
Local cLegenda3	:= ""
Local cSX6Cont	:= ""
Local cCpoNaoAlt:= "X6_CONTEUD|X6_CONTSPA|X6_CONTENG"

nTamFil	:= Len( SX6->X6_FIL )
nTamVar	:= Len( SX6->X6_VAR )
cTamFil	:= Space(nTamFil)

SX6->(DbSetOrder(1))

cMensagem += "Inicio da função LjDrCriaX6 - criação da SX6" + _PLINHA
ConOut("Inicio da função LjDrCriaX6 - criação da SX6")

cLegenda1	:= "Determina o número de dias que uma receita pode "
cLegenda2	:= "ser aceita na venda."
cLegenda3	:= ""
cSX6Cont	:= "30"
Aadd(aDados,{cTamFil,"MV_DROVLRC","N",cLegenda1,cLegenda1,cLegenda1,;
			cLegenda2,cLegenda2,cLegenda2,cLegenda3,cLegenda3,cLegenda3,;
			"30","30","30","T","S","M->X6_CONTEUD > 0","","30","30","30"})

cLegenda1	:= "Determina o número de dias que uma receita tipo"
cLegenda2	:= "C pode ser aceita na venda."
cLegenda3	:= ""
cSX6Cont	:= "7"
Aadd(aDados,{cTamFil,"MV_DROVLTC","N",cLegenda1,cLegenda1,cLegenda1,;
			cLegenda2,cLegenda2,cLegenda2,cLegenda3,cLegenda3,cLegenda3,;
			cSX6Cont,cSX6Cont,cSX6Cont,"T","S","M->X6_CONTEUD > 0","",cSX6Cont,cSX6Cont,cSX6Cont})

cLegenda1	:= "Determina o número de dias que será possível"
cLegenda2	:= "realizar ajuste no livro"
cLegenda3	:= ""
cSX6Cont	:= "7"
Aadd(aDados,{cTamFil,"MV_DROREV","N",cLegenda1,cLegenda1,cLegenda1,;
			cLegenda2,cLegenda2,cLegenda2,cLegenda3,cLegenda3,cLegenda3,;
			cSX6Cont,cSX6Cont,cSX6Cont,"T","S","M->X6_CONTEUD > 0","",cSX6Cont,cSX6Cont,cSX6Cont})

cLegenda1	:= "Determina a URL de acesso ao site da ANVISA,"
cLegenda2	:= "para transmissão do XML"
cLegenda3	:= ""
cSX6Cont	:= 'https://sngpc.anvisa.gov.br/webservice/sngpc_consulta/upload.aspx'
Aadd(aDados,{cTamFil,"MV_URLANVI","C",cLegenda1,cLegenda1,cLegenda1,;
			cLegenda2,cLegenda2,cLegenda2,cLegenda3,cLegenda3,cLegenda3,;
			cSX6Cont,cSX6Cont,cSX6Cont,"T","S","","",cSX6Cont,cSX6Cont,cSX6Cont})

cLegenda1	:= "Número da Licença(s) de Funcionamento"
cLegenda2	:= "Usado no Template de Drogaria"
cLegenda3	:= ""
cSX6Cont	:= ''
Aadd(aDados,{cTamFil,"MV_LJDROLF","C",cLegenda1,cLegenda1,cLegenda1,;
			cLegenda2,cLegenda2,cLegenda2,cLegenda3,cLegenda3,cLegenda3,;
			cSX6Cont,cSX6Cont,cSX6Cont,"T","S","","",cSX6Cont,cSX6Cont,cSX6Cont})

For nX := 1 to Len(aDados)	
	Conout(" Criando/Alterando o Parâmetro - [" + aDados[nX,2] + "]")
	cMensagem += " Criando/Alterando o Parâmetro - [" + aDados[nX,2] + "]" + _PLINHA
		
	lNewReg := !SX6->( dbSeek( PadR( aDados[nX][1], nTamFil ) + PadR( aDados[nX][2], nTamVar ) ) )
	RecLock("SX6",lNewReg)
    For nY:= 1 To Len(aDados[nX])
    	nPos := SX6->(ColumnPos(aEstrut[nY]))
        If nPos > 0 
        	If lNewReg .Or. ( !lNewReg .And. !(aEstrut[nY] $ cCpoNaoAlt))
        		FieldPut(nPos,aDados[nX,nY])
        	EndIf
        EndIf
    Next nY
    SX6->(dbCommit())
    SX6->(MsUnLock())
Next nX

cMensagem += "Término da função LjDrCriaX6 - ajuste da SX6" + _PLINHA
ConOut("Término da função LjDrCriaX6 - ajuste da SX6")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaX1(cMensagem)
Insere as perguntas que anteriormente eram criados via UPDDRO

@param cMensagem - mensagem de log do processo
@author Julio.nery
@since 12/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaX1(cMensagem)
Local lLjDrCriaX1:= ExistTemplate("LjDrCriaX1")

IF lLjDrCriaX1
	ConOut("Antes da função LjDrCriaX1")
	T_LjDrCriaX1(@cMensagem,.F.,.T.)
	ConOut("Depois da função LjDrCriaX1")
Else
	cMensagem += "função LjDrCriaX1 - atualize o fonte DroVldFuncs" + _PLINHA
	ConOut("função LjDrCriaX1 - atualize o fonte DroVldFuncs")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaX3(cMensagem)
Insere os campos que anteriormente eram criados via UPDDRO

@param cMensagem - mensagem de log do processo
@author Julio.nery
@since 12/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaX3(cMensagem)
Local aEstruSX3	:= LjSxTable("1")	//Retorna um array com a estrutura do SX3
Local aSX3		:= {}
Local cTabAtu	:= ""
Local cOrdem	:= ""
Local cUsadoOpc	:= ""		//Valor para o X3_USADO de campos opcionais
Local cReservOpc:= ""		//Valor para o X3_RESERV de campos opcionais
Local cObrigat	:= ""
Local cDescFld	:= ""
Local cTitFld	:= ""
Local nTamFld	:= 0
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local lNewReg	:= .F.

cMensagem += "Inicio da função LjDrCriaX3 - Inserção dos campos dos UPDDROXX's " + _PLINHA
ConOut("Inicio da função LjDrCriaX3 - Inserção dos campos dos UPDDROXX's ")

SX3->(DbSetOrder(2)) //Posiciono para todos os registros 
nTamFld := Len(SX3->X3_CAMPO)

//Usado para todas as tabelas - até o próximo posicionamento
SX3->( dbSeek( PadR("A1_INSCRM",nTamFld) ) )
cUsadoOpc	:= SX3->X3_USADO
cReservOpc	:= SX3->X3_RESERV

/**************************************  AIE ***************************************************/
cTitFld	 := "Descrição"
cDescFld := "Descrição"
Aadd(aSX3,;
 	{"AIE","","AIE_DESPRO","C",;
 	 30,0,cTitFld,cTitFld,;
 	 cTitFld,cDescFld,cDescFld,cDescFld,;
 	 "@!","",cUsadoOpc,"",;
 	 "",1,cReservOpc,"",;
 	 "","T","N","V",;
 	 "R","","","",;
 	 "","","","",;
 	 "","","","N"})    

cTitFld	 := "Necess. Calc"
cDescFld := "Necessidade Calculada"
Aadd(aSX3,;
	{"AIE","","AIE_NECESC","N",;
	 12,2,cTitFld,cTitFld,;
	 cTitFld,cDescFld,cDescFld,cDescFld,;
	 "@E 999,999,999.99","",cUsadoOpc,"",;
	 "",1,cReservOpc,"",;
	 "","T","N","V",;
	 "R","","","",;
	 "","","","",;
	 "","","","N"})
	 
cTitFld	 := "Necess. Digi"
cDescFld := "Necessidade Calculada"
Aadd(aSX3,;
	{"AIE","","AIE_NECESD","N",;
	12,2,cTitFld,cTitFld,;
	cTitFld,cDescFld,cDescFld,cDescFld,;
	"@E 999,999,999.99","",cUsadoOpc,"",;
	"",1,cReservOpc,"",;
	"","T","N","V",;
	"R","","","",;
	"","","","",;
	"","","","N" })
	
cTitFld	 := "Dt. Proc."
cDescFld := "Data do Processamento"
Aadd(aSX3,;
 	{"AIE","","AIE_DTPROC","D",;
 	 8,0,cTitFld,cTitFld,;
 	 cTitFld,cDescFld,cDescFld,cDescFld,; 	 
 	 "","",cUsadoOpc,"",;
 	 "",1,cReservOpc,"",;
 	 "","T","N","V",;
 	 "R","","","",;
 	 "","","","",;
 	 "","","","N"})
 	 
cTitFld	 := "Entrega"
cDescFld := "Prazo de Entrega"     
Aadd(aSX3,;
	{"AIE","","AIE_PE","N",;
	5,0,cTitFld,cTitFld,;
	cTitFld,cDescFld,cDescFld,cDescFld,;
	Tm(0,5,0),"",cUsadoOpc,"",;
	"",1,cReservOpc,"",;
	"","T","N","V",;
	"R","","","",;
	"","","","",;
	"","","","N"})

cTitFld	 := "Armazem Pad."
cDescFld := "Armazem Padrão p/ Requis."
Aadd(aSX3,;
	{"AIE","","AIE_LOCPAD","C",;
	2,0,cTitFld,cTitFld,;
	cTitFld,cDescFld,cDescFld,cDescFld,;
	"@99","",cUsadoOpc,"",;
	"",1,cReservOpc,"",;
	"","T","N","V",;
	"R","","","",;
	"","","","",;
	"","","","N"})

cTitFld	 := "TE Padrao"
cDescFld := "Código de Entrada Padrão"
Aadd(aSX3,;
 	{"AIE","","AIE_TE","C",;
 	3,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@!","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})
 	
cTitFld	 := "TS Padrao"
cDescFld := "Código de Saída Padrão"
Aadd(aSX3,;
 	{"AIE","","AIE_TS","C",;
 	3,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@!","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})
 	
cTitFld	 := "Qtd.Embalag."
cDescFld := "Qtde por Embalagem"
Aadd(aSX3,;
 	{"AIE","","AIE_QE","C",;
 	9,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	Tm(0,9,0),"",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})

cTitFld	 := "Ponto Pedido"
cDescFld := "Ponto Pedido"
Aadd(aSX3,;
 	{"AIE","","AIE_EMIN","N",;
 	12,2,cTitFld,cTitFld,cTitFld,;
 	cDescFld,cDescFld,cDescFld,;
 	Tm(0,12,2),"",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})

cTitFld := "Custo Stand."
cDescFld := "Custo Standard"
Aadd(aSX3,;
 	{"AIE","","AIE_CUSTD","N",;
 	12,2,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	Tm(0,12,2),"",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})

cTitFld := "Ult. Calculo" 
cDescFld := "Dta Ult Calc do Custo Std"
Aadd(aSX3,;
 	{"AIE","","AIE_UCALST","D",;
 	8,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","1=Moeda1;2=Moeda2;3=Moeda3;4=Moeda4;5=Moeda5",;
 	"1=Moneda1;2=Moneda2;3=Moneda3;4=Moneda4;5=Moneda5","1=Currency1;2=Currency2;3=Currency3;4=Currency4;5=Currency5","" ,"" ,;
 	"","","","N"})     

cTitFld := "Moeda C.Std" 
cDescFld := "Moeda do Custo Standard"
Aadd(aSX3,;
 	{"AIE","","AIE_MCUSTD","C",;
 	1,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@!","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})

cTitFld := "Ult. Compra" 
cDescFld := "Data da Última Compra"
Aadd(aSX3,;
 	{"AIE","","AIE_UCOM","D",;
 	8,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})   

cTitFld := "Form.Est.Seg" 
cDescFld := "Estoque de Segurança"
Aadd(aSX3,;
 	{"AIE","","AIE_ESTSEG","N",;
 	12,2,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@E 999,999,999","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})  

cTitFld := "Form.Est.Seg."
cDescFld := "Formula Estoque Segurança"  
Aadd(aSX3,;
 	{"AIE","","AIE_ESTFOR","C",;
 	3,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@!","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})
 	
cTitFld := "Form. Prazo"
cDescFld := "Fórmula Cálculo do Prazo"  
Aadd(aSX3,;
 	{"AIE","","AIE_FORPRZ","C",;
 	3,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@!","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})
 	   
cTitFld := "Tipo Prazo"
cDescFld := "Tipo Prazo de Entrega"  
Aadd(aSX3,;
 	{"AIE","","AIE_TIPE","C",;
 	1,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})
 	  
cTitFld := "Lote Econom."
cDescFld := "Lote Econômico"
Aadd(aSX3,;
 	{"AIE","","AIE_LE","N",;
 	12,2,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@E 999,999,999.99","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})

cTitFld := "Lote Minimo"
cDescFld := "Lote Minimo"
Aadd(aSX3,;
	{"AIE","","AIE_LM","N",;
	12,2,cTitFld,cTitFld,;
	cTitFld,cDescFld,cDescFld,cDescFld,;
	"@E 999,999,999.99","",cUsadoOpc,"",;
	"",1,cReservOpc,"",;
	"","T","N","V",;
	"R","","","",;
	"","","","",;
	"","","","N"})

cTitFld := "Tolerância"
cDescFld := "Tolerância"  
Aadd(aSX3,;
 	{"AIE","","AIE_TOLER","N",;
 	3,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@E 999","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})        

cTitFld := "Cons.Inicial"
cDescFld := "Data do Consumo Inicial"
Aadd(aSX3,;
 	{"AIE",cOrdem,"AIE_CONINI","D",;
 	8,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})

cTitFld := "Dt. Referenc"
cDescFld := "Data referência do Custo"  
Aadd(aSX3,;
 	{"AIE",cOrdem,"AIE_DATREF","D",;
 	8,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"","",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","V",;
 	"R","","","",;
 	"","","","",;
 	"","","","N"})
 	
/**************************************** SA5 ************************************************/
cTitFld := "Prior. Forn."
cDescFld := "Prioridade do fornecedor"  
Aadd(aSX3,;
 	{"SA5",cOrdem,"A5_PRIOFOR","N",;
 	1,0,cTitFld,cTitFld,;
 	cTitFld,cDescFld,cDescFld,cDescFld,;
 	"@!","T_DROVLPRI()",cUsadoOpc,"",;
 	"",1,cReservOpc,"",;
 	"","T","N","A",;
 	"R","","","",;
 	"","","","",;
 	"","","4","S"})

/****************************************  SBI  **********************************************/

If !SX3->(DbSeek(PadR("BI_DESCOBR",nTamFld))) .And. SX3->(DbSeek(PadR("BI_REDIRRF",nTamFld))) //Deixar o SEEK do BI_REDIRRF por ultimo, pois pega as mesmas propriedades   
	aAdd( aSX3, { ;
		    'SBI'                                                                   	, ; //X3_ARQUIVO
		    cOrdem                                                                   	, ; //X3_ORDEM
		    'BI_DESCOBR'                                                         		, ; //X3_CAMPO
		    SX3->X3_TIPO                                                               	, ; //X3_TIPO
		    SX3->X3_TAMANHO                                                       		, ; //X3_TAMANHO
		    SX3->X3_DECIMAL                                                            	, ; //X3_DECIMAL
		    "% Desconto"	                                                           	, ; //X3_TITULO
		    "% Desconto" 	                                                          	, ; //X3_TITSPA 
		    "% Desconto"	                                                           	, ; //X3_TITENG
		    "% Desconto"        						                                , ; //X3_DESCRIC
		    "% Desconto"						                                        , ; //X3_DESCSPA
		    "% Desconto"				                                                , ; //X3_DESCENG
		    SX3->X3_PICTURE                                                            	, ; //X3_PICTURE
		    SX3->X3_VALID                                                              	, ; //X3_VALID
			SX3->X3_USADO																, ;	//X3_USADO
		    SX3->X3_RELACAO                                                            	, ; //X3_RELACAO
		    SX3->X3_F3                                                                 	, ; //X3_F3
		    1                                                                       	, ; //X3_NIVEL
		    SX3->X3_RESERV		                                                		, ; //X3_RESERV
		    SX3->X3_CHECK                                                              	, ; //X3_CHECK
		    SX3->X3_TRIGGER                                                            	, ; //X3_TRIGGER
		    'T'	                                                                     	, ; //X3_PROPRI
		    SX3->X3_BROWSE                                                             	, ; //X3_BROWSE
		    SX3->X3_VISUAL                                                             	, ; //X3_VISUAL
		    SX3->X3_CONTEXT                                                            	, ; //X3_CONTEXT
		    SX3->X3_OBRIGAT                                                            	, ; //X3_OBRIGAT
		    SX3->X3_VLDUSER                                                            	, ; //X3_VLDUSER
		    SX3->X3_CBOX                                                               	, ; //X3_CBOX
		    SX3->X3_CBOXSPA                                                            	, ; //X3_CBOXSPA
		    SX3->X3_CBOXENG                                                            	, ; //X3_CBOXENG
		    SX3->X3_PICTVAR                                                            	, ; //X3_PICTVAR
		    SX3->X3_WHEN                                                               	, ; //X3_WHEN
		    SX3->X3_INIBRW                                                             	, ; //X3_INIBRW
		    SX3->X3_GRPSXG                                                             	, ; //X3_GRPSXG
		    SX3->X3_FOLDER                                                             	, ; //X3_FOLDER
		    SX3->X3_PYME                                                               	} ) //X3_PYME
EndIf

/*************************************************************
  Usado para todas as tabelas - até o próximo posicionamento
  ************************************************************/
SX3->( dbSeek( PadR("LK9_CODPRO",nTamFld) ) )
cUsadoOpc	:= SX3->X3_USADO
cReservOpc	:= SX3->X3_RESERV
cObrigat	:= SX3->X3_OBRIGAT

aAdd( aSX3, { ;
    'SBI'                                                                   	, ; //X3_ARQUIVO
    '' 		                                                                  	, ; //X3_ORDEM
    'BI_CLASSTE'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Classe Terap"	                                                         	, ; //X3_TITULO
    "Classe Terap" 	                		                                   	, ; //X3_TITSPA 
    "Classe Terap"	            	                                           	, ; //X3_TITENG
    "Classe Terapêutica"					              	    	            , ; //X3_DESCRIC
    "Classe Terapêutica"			                         	    			, ; //X3_DESCSPA
    "Classe Terapêutica"		                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""  						                                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SBI'                                                                   	, ; //X3_ARQUIVO
    ''       	                                                            	, ; //X3_ORDEM
    'BI_VDFORAU'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Venda Fora UF"	                                                         	, ; //X3_TITULO
    "Venda Fora UF"                 		                                   	, ; //X3_TITSPA 
    "Venda Fora UF"	            	                                           	, ; //X3_TITENG
    "Venda Fora do Estado"					              	    	            , ; //X3_DESCRIC
    "Venda Fora do Estado"			                         	    			, ; //X3_DESCSPA
    "Venda Fora do Estado"		                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    "Vazio() .OR. Pertence('12')"                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=Sim;2=Não' 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SBI'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'BI_CODLIS'			                   	                	           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    2				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Cod.Lista"	                                        	                 	, ; //X3_TITULO
    "Cod.Lista"                 			                                   	, ; //X3_TITSPA 
    "Cod.Lista"	            	                    	                       	, ; //X3_TITENG
    "Codigo da Lista"						              	    	            , ; //X3_DESCRIC
    "Codigo da Lista"		                		         	    			, ; //X3_DESCSPA
    "Codigo da Lista"      			                  		               		, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""                  						                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    'LX5T8D'                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''			 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/**************************************** SB1 ****************************************/

If !SX3->(DbSeek(PadR("B1_DESCOBR",nTamFld))) .And. SX3->(DbSeek(PadR("B1_COMIS",nTamFld))) //Deixar o SEEK do B1_COMIS por ultimo, pois pega as mesmas propriedades   
	aAdd( aSX3, { ;
		    'SB1'                                                                   	, ; //X3_ARQUIVO
		    ''                                                                   	, ; //X3_ORDEM
		    'B1_DESCOBR'                                                         		, ; //X3_CAMPO
		    SX3->X3_TIPO                                                               	, ; //X3_TIPO
		    SX3->X3_TAMANHO                                                       		, ; //X3_TAMANHO
		    SX3->X3_DECIMAL                                                            	, ; //X3_DECIMAL
		    "% Desconto"	                                                           	, ; //X3_TITULO
		    "% Desconto" 	                                                          	, ; //X3_TITSPA 
		    "% Desconto"	                                                           	, ; //X3_TITENG
		    "% Desconto"        						                                , ; //X3_DESCRIC
		    "% Desconto"						                                        , ; //X3_DESCSPA
		    "% Desconto"				                                                , ; //X3_DESCENG
		    SX3->X3_PICTURE                                                            	, ; //X3_PICTURE
		    SX3->X3_VALID                                                              	, ; //X3_VALID
			SX3->X3_USADO																, ;	//X3_USADO
		    SX3->X3_RELACAO                                                            	, ; //X3_RELACAO
		    SX3->X3_F3                                                                 	, ; //X3_F3
		    1                                                                       	, ; //X3_NIVEL
		    SX3->X3_RESERV		                                                		, ; //X3_RESERV
		    SX3->X3_CHECK                                                              	, ; //X3_CHECK
		    SX3->X3_TRIGGER                                                            	, ; //X3_TRIGGER
		    'T'	                                                                     	, ; //X3_PROPRI
		    SX3->X3_BROWSE                                                             	, ; //X3_BROWSE
		    SX3->X3_VISUAL                                                             	, ; //X3_VISUAL
		    SX3->X3_CONTEXT                                                            	, ; //X3_CONTEXT
		    SX3->X3_OBRIGAT                                                            	, ; //X3_OBRIGAT
		    SX3->X3_VLDUSER                                                            	, ; //X3_VLDUSER
		    SX3->X3_CBOX                                                               	, ; //X3_CBOX
		    SX3->X3_CBOXSPA                                                            	, ; //X3_CBOXSPA
		    SX3->X3_CBOXENG                                                            	, ; //X3_CBOXENG
		    SX3->X3_PICTVAR                                                            	, ; //X3_PICTVAR
		    SX3->X3_WHEN                                                               	, ; //X3_WHEN
		    SX3->X3_INIBRW                                                             	, ; //X3_INIBRW
		    SX3->X3_GRPSXG                                                             	, ; //X3_GRPSXG
		    '8'                                                                      	, ; //X3_FOLDER
		    SX3->X3_PYME                                                               	} ) //X3_PYME	
EndIf

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_CLASSTE'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Classe Terap"	                                                         	, ; //X3_TITULO
    "Classe Terap" 	                		                                   	, ; //X3_TITSPA 
    "Classe Terap"	            	                                           	, ; //X3_TITENG
    "Classe Terapêutica"					              	    	            , ; //X3_DESCRIC
    "Classe Terapêutica"			                         	    			, ; //X3_DESCSPA
    "Classe Terapêutica"		                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    "Vazio() .OR. Pertence('12')"                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=AntiMicrobiano;2=Sujeito a Controle Especial'                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_VDFORAU'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Venda Fora UF"	                                                         	, ; //X3_TITULO
    "Venda Fora UF"                 		                                   	, ; //X3_TITSPA 
    "Venda Fora UF"	            	                                           	, ; //X3_TITENG
    "Venda Fora do Estado"					              	    	            , ; //X3_DESCRIC
    "Venda Fora do Estado"			                         	    			, ; //X3_DESCSPA
    "Venda Fora do Estado"		                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    "Vazio() .OR. Pertence('12')"                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=Sim;2=Não' 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_TIPMED'			                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    6				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Tipo Medic."	                                                         	, ; //X3_TITULO
    "Tipo Medic."                 			                                   	, ; //X3_TITSPA 
    "Tipo Medic."	            	                                           	, ; //X3_TITENG
    "Tipo Medicamento"						              	    	            , ; //X3_DESCRIC
    "Tipo Medicamento"				                         	    			, ; //X3_DESCSPA
    "Tipo Medicamento"		                          		               		, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""                  						                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    'LX5T7'	                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''			 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_DESCTPM'			                   	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    60				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Desc.Tp.Med."	                                                         	, ; //X3_TITULO
    "Desc.Tp.Med."                 			                                   	, ; //X3_TITSPA 
    "Desc.Tp.Med."	            	                                           	, ; //X3_TITENG
    "Desc. Tipo de Medicamento"				              	    	            , ; //X3_DESCRIC
    "Desc. Tipo de Medicamento"		                         	    			, ; //X3_DESCSPA
    "Desc. Tipo de Medicamento"                        		               		, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""                  						                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''			 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_CODLIS'			                   	                	           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    2				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Cod.Lista"	                                        	                 	, ; //X3_TITULO
    "Cod.Lista"                 			                                   	, ; //X3_TITSPA 
    "Cod.Lista"	            	                    	                       	, ; //X3_TITENG
    "Codigo da Lista"						              	    	            , ; //X3_DESCRIC
    "Codigo da Lista"		                		         	    			, ; //X3_DESCSPA
    "Codigo da Lista"      			                  		               		, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""                  						                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    'LX5T8D'                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''			 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_DESCLIS'			                   	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    60				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Desc.Lista"	                                        	                , ; //X3_TITULO
    "Desc.Lista"                 			                                   	, ; //X3_TITSPA 
    "Desc.Lista"	            	                    	                    , ; //X3_TITENG
    "Descrição da Lista"						              	    	        , ; //X3_DESCRIC
    "Descrição da Lista"		                		         	    		, ; //X3_DESCSPA
    "Descrição da Lista"      			                  		               	, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""                  						                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''			 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_CONCENT'			                   	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    15				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Concentracao"	                                        	                , ; //X3_TITULO
    "Concentracao"                 			                                   	, ; //X3_TITSPA 
    "Concentracao"	            	                    	                    , ; //X3_TITENG
    "Concentração do Ativo"						              	    	        , ; //X3_DESCRIC
    "Concentração do Ativo"		                		         	    		, ; //X3_DESCSPA
    "Concentração do Ativo"      			                  		               	, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""                  						                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''			 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_QTDEMBA'			                   	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    6				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Unidades"	                        	                	                , ; //X3_TITULO
    "Unidades"                 				                                   	, ; //X3_TITSPA 
    "Unidades"	            		                    	                    , ; //X3_TITENG
    "Qtd. conteudo Embalagem"					              	    	        , ; //X3_DESCRIC
    "Qtd. conteudo Embalagem"	                		         	    		, ; //X3_DESCSPA
    "Qtd. conteudo Embalagem"  			                  		               	, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""                  						                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''			 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_CONSIST'			                   	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Consistente"	                                        	                , ; //X3_TITULO
    "Consistente"                 			                                   	, ; //X3_TITSPA 
    "Consistente"	            		                  	                    , ; //X3_TITENG
    "Info Consistente"							              	    	        , ; //X3_DESCRIC
    "Info Consistente"	    		            		         	    		, ; //X3_DESCSPA
    "Info Consistente"		  			                  		               	, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    "Vazio() .OR. Pertence('12')"				                            	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    "'1'"                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=Sim;2=Não' 									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_OBSALTE'			                   	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                        	                , ; //X3_TITULO
    "Obs Inc/Alt"                 			                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            		                  	                    , ; //X3_TITENG
    "Obs de Inclusão/Alteração"					              	    	        , ; //X3_DESCRIC
    "Obs de Inclusão/Alteração"		            		         	    		, ; //X3_DESCSPA
    "Obs de Inclusão/Alteração"			                  		               	, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""				                            								, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_USVENDA'			                   	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"					              	    	      		, ; //X3_DESCRIC
    "Alterado pelo usuário"		            		         	    			, ; //X3_DESCSPA
    "Alterado pelo usuário"			                  		              	 	, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""				                            								, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_USAPRO'			                   	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"					              	    	      		, ; //X3_DESCRIC
    "Aprovado pelo usuário"		            		         	    			, ; //X3_DESCSPA
    "Aprovado pelo usuário"			                  		              	 	, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""				                            								, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_LIVRO'			     	              	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Livro Origem"	                                        	                , ; //X3_TITULO
    "Livro Origem"                 			                                   	, ; //X3_TITSPA 
    "Livro Origem"	            		                  	                    , ; //X3_TITENG
    "Livro Origem do Produto"				              	    	      		, ; //X3_DESCRIC
    "Livro Origem do Produto"	            		         	    			, ; //X3_DESCSPA
    "Livro Origem do Produto"		                  		              	 	, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""				                            								, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_PAGINA'			     	              	                	         	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    5				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Num. Pagina"	                                        	                , ; //X3_TITULO
    "Num. Pagina"                 			                                   	, ; //X3_TITSPA 
    "Num. Pagina"	            		                  	                    , ; //X3_TITENG
    "Página do Livro de Origem"				              	    	      		, ; //X3_DESCRIC
    "Página do Livro de Origem"	            		         	    			, ; //X3_DESCSPA
    "Página do Livro de Origem"		                  		              	 	, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""				                            								, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_SUBATIV'			     	              	                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    60				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Subs. Ativa"	                                        	                , ; //X3_TITULO
    "Subs. Ativa"                 			                                   	, ; //X3_TITSPA 
    "Subs. Ativa"	            		                  	                    , ; //X3_TITENG
    "Substância Ativa"				              	    	      				, ; //X3_DESCRIC
    "Substância Ativa"	            		         	    					, ; //X3_DESCSPA
    "Substância Ativa"		                  		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""				                            								, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                  		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'B1_CODDCB'			     	              		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    9				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Codigo DCB"	                                        	                , ; //X3_TITULO
    "Codigo DCB"                 			                                   	, ; //X3_TITSPA 
    "Codigo DCB"	            		                  	                    , ; //X3_TITENG
    "Codigo da DCB"				            	  	    	      				, ; //X3_DESCRIC
    "Codigo da DCB"	            			         	    					, ; //X3_DESCSPA
    "Codigo da DCB"		            	      		              	 			, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    "ExistCpo('LKD',M->B1_CODDCB)"	               								, ; //X3_VALID
	'€€€€€€€€€€€€€€ '															, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    'LKDDCB'                                                               		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/*******************************  LK9  **********************************************/
aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_END'  		                                                       		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    40				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "End. Cliente"	                                                          	, ; //X3_TITULO
    "End. Cliente" 	                                                         	, ; //X3_TITSPA 
    "End. Cliente"	                                                           	, ; //X3_TITENG
    "Endereço do Cliente"      					                                , ; //X3_DESCRIC
    "Endereço do Cliente"				                                        , ; //X3_DESCSPA
    "Endereço do Cliente"		                                                , ; //X3_DESCENG
    ''     	                                                                	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '4'                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_NOMEP'		                                                       		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    30				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Nome pcte."	                                                          	, ; //X3_TITULO
    "Nome pcte." 	                                                         	, ; //X3_TITSPA 
    "Nome pcte."	                                                           	, ; //X3_TITENG
    "Nome do Paciente"      					                                , ; //X3_DESCRIC
    "Nome do Paciente"					                                        , ; //X3_DESCSPA
    "Nome do Paciente"			                                                , ; //X3_DESCENG
    ''     	                                                                	, ; //X3_PICTURE
    ''                                                                      	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''                                                                      	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    '4'                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_CLASST'		                                                   		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Classe Terap"	                                                          	, ; //X3_TITULO
    "Classe Terap" 	                                                         	, ; //X3_TITSPA 
    "Classe Terap"	                                                           	, ; //X3_TITENG
    "Classe Terapeutica"      					                                , ; //X3_DESCRIC
    "Classe Terapeutica"				                                        , ; //X3_DESCSPA
    "Classe Terapeutica"		                                                , ; //X3_DESCENG
    ''     	                                                                	, ; //X3_PICTURE
    "Vazio() .OR. Pertence('12')"                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=AntiMicrobiano;2=Sujeito a Controle Especial'                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_USOPRO'		                                                   		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Uso Prolong."	                                                          	, ; //X3_TITULO
    "Uso Prolong." 	                                                         	, ; //X3_TITSPA 
    "Uso Prolong."	                                                           	, ; //X3_TITENG
    "Uso Prolongado"	      					                                , ; //X3_DESCRIC
    "Uso Prolongado"					                                        , ; //X3_DESCSPA
    "Uso Prolongado"			                                                , ; //X3_DESCENG
    ''     	                                                                	, ; //X3_PICTURE
    "Vazio() .OR. Pertence('SN')"                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    'S=Sim;N=Nao'									                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME
    
aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_CIDPA'		                        	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    4				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "CID Paciente"	                                                          	, ; //X3_TITULO
    "CID Paciente" 	                                                         	, ; //X3_TITSPA 
    "CID Paciente"	                                                           	, ; //X3_TITENG
    "CID Paciente"	      						                                , ; //X3_DESCRIC
    "CID Paciente"						                                        , ; //X3_DESCSPA
    "CID Paciente"			    	                                            , ; //X3_DESCENG
    ''     	                                                                	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ''                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_UNIDAP'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Idade em"	                        	                                  	, ; //X3_TITULO
    "Idade em" 	                		                                       	, ; //X3_TITSPA 
    "Idade em"	            	                                               	, ; //X3_TITENG
    "Idade em Meses ou Anos"					                                , ; //X3_DESCRIC
    "Idade em Meses ou Anos"			                                        , ; //X3_DESCSPA
    "Idade em Meses ou Anos"    	                                            , ; //X3_DESCENG
    ''     	                                                                	, ; //X3_PICTURE
    "Pertence('12')"			                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    "'1'"                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=Anos;2=Meses'								                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''              	                                                     	, ; //X3_ORDEM
    'LK9_IDADEP'		                       	                           		, ; //X3_CAMPO
    'N'                                                                     	, ; //X3_TIPO
    3				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Idade pcte."	                                                         	, ; //X3_TITULO
    "Idade pcte." 	                		                                   	, ; //X3_TITSPA 
    "Idade pcte."	            	                                           	, ; //X3_TITENG
    "Idade do Paciente"							                                , ; //X3_DESCRIC
    "Idade do Paciente"					                                        , ; //X3_DESCSPA
    "Idade do Paciente"		    	                                            , ; //X3_DESCENG
    '@E 999'                                                                	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   		, ; //X3_ORDEM
    'LK9_QUANTP'		                       	                           		, ; //X3_CAMPO
    'N'                                                                     	, ; //X3_TIPO
    11				                                                       		, ; //X3_TAMANHO
    2                                                                       	, ; //X3_DECIMAL
    "Qtd. Presc."	                                                         	, ; //X3_TITULO
    "Qtd. Presc." 	                		                                   	, ; //X3_TITSPA 
    "Qtd. Presc."	            	                                           	, ; //X3_TITENG
    "Quantidade Prescrita"						                                , ; //X3_DESCRIC
    "Quantidade Prescrita"				                                        , ; //X3_DESCSPA
    "Quantidade Prescrita"	    	                                            , ; //X3_DESCENG
    '@E 99999999.99'                                                           	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_SEXOPA'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Sexo pcte."	                                                         	, ; //X3_TITULO
    "Sexo pcte." 	                		                                   	, ; //X3_TITSPA 
    "Sexo pcte."	            	                                           	, ; //X3_TITENG
    "Sexo do Paciente"						              	    	            , ; //X3_DESCRIC
    "Sexo do Paciente"				                         	    			, ; //X3_DESCSPA
    "Sexo do Paciente"	    	                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=Masculino;2=Feminino'						                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_TPCAD'			                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Tp. Cadastro"	                                                         	, ; //X3_TITULO
    "Tp. Cadastro" 	                		                                   	, ; //X3_TITSPA 
    "Tp. Cadastro"	            	                                           	, ; //X3_TITENG
    "Tipo de Cadastro"						              	    	            , ; //X3_DESCRIC
    "Tipo de Cadastro"				                         	    			, ; //X3_DESCSPA
    "Tipo de Cadastro"	    	                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    "'1'"                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_OBSPER'		                       	                           		, ; //X3_CAMPO
    'M'                                                                     	, ; //X3_TIPO
    10				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs. Perda"	                                                         	, ; //X3_TITULO
    "Obs. Perda" 	                		                                   	, ; //X3_TITSPA 
    "Obs. Perda"	            	                                           	, ; //X3_TITENG
    "Observação da Perda"					              	    	            , ; //X3_DESCRIC
    "Observação da Perda"			                         	    			, ; //X3_DESCSPA
    "Observação da Perda"    	                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                      	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_CODLIS'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    2				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Codigo Lista"	                                                         	, ; //X3_TITULO
    "Codigo Lista" 	                		                                   	, ; //X3_TITSPA 
    "Codigo Lista"	            	                                           	, ; //X3_TITENG
    "Codigo da Lista"						              	    	            , ; //X3_DESCRIC
    "Codigo da Lista"				                         	    			, ; //X3_DESCSPA
    "Codigo da Lista"	    	                          		                , ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    'LX5T8D'                                                                   	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_LIVRO'			                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Livro Origem"	                                                         	, ; //X3_TITULO
    "Livro Origem" 	                		                                   	, ; //X3_TITSPA 
    "Livro Origem"	            	                                           	, ; //X3_TITENG
    "Livro de Origem do Prod."				              	    	            , ; //X3_DESCRIC
    "Livro de Origem do Prod."		                         	    			, ; //X3_DESCSPA
    "Livro de Origem do Prod." 	                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                   		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_PAGINA'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    5				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Pag. Origem"	                                                         	, ; //X3_TITULO
    "Pag. Origem" 	                		                                   	, ; //X3_TITSPA 
    "Pag. Origem"	            	                                           	, ; //X3_TITENG
    "Pagina do Livro de Origem"				              	    	            , ; //X3_DESCRIC
    "Pagina do Livro de Origem"		                         	    			, ; //X3_DESCSPA
    "Pagina do Livro de Origem"	                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''                                                                   		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''                                                                      	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_OBSALT'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                                         	, ; //X3_TITULO
    "Obs Inc/Alt" 	                		                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            	                                           	, ; //X3_TITENG
    "Obs de Inclusao/Alteracao"				              	    	            , ; //X3_DESCRIC
    "Obs de Inclusao/Alteracao"		                         	    			, ; //X3_DESCSPA
    "Obs de Inclusao/Alteracao"	                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_USVENDA'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                                         	, ; //X3_TITULO
    "Alterado por" 	                		                                   	, ; //X3_TITSPA 
    "Alterado por"	            	                                           	, ; //X3_TITENG
    "Alterado pelo usuario"					              	    	            , ; //X3_DESCRIC
    "Alterado pelo usuario"			                         	    			, ; //X3_DESCSPA
    "Alterado pelo usuario"		                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LK9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   	, ; //X3_ORDEM
    'LK9_USAPRO'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                                         	, ; //X3_TITULO
    "Aprovado por" 	                		                                   	, ; //X3_TITSPA 
    "Aprovado por"	            	                                           	, ; //X3_TITENG
    "Aprovado pelo usuario"					              	    	            , ; //X3_DESCRIC
    "Aprovado pelo usuario"			                         	    			, ; //X3_DESCSPA
    "Aprovado pelo usuario"		                          		                , ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME
    
/********************************************** LX5 **************************************/

aAdd( aSX3, { ;
    'LX5'                                                                   	, ; //X3_ARQUIVO
    ''                                                                   		, ; //X3_ORDEM
    'LX5_COMPLE'		                       	                           		, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    15				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Complemento"	                                                         	, ; //X3_TITULO
    "Complemento" 	                		                                   	, ; //X3_TITSPA 
    "Complemento"	            	                                           	, ; //X3_TITENG
    "Complemento"							              	    	            , ; //X3_DESCRIC
    "Complemento"					                         	    			, ; //X3_DESCSPA
    "Complemento"				                          		                , ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""							                                              	, ; //X3_VALID
	cUsadoOpc  																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    '' 		                                                                  	, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ""		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                           	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/******************************* LEO ***************************************************/

aAdd( aSX3, { ;
    'LEO'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'LEO_OBSALT'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                        	                , ; //X3_TITULO
    "Obs Inc/Alt"                 			                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            		                  	                    , ; //X3_TITENG
    "Obs de Inclusão/Alteração"	            	  	    	      				, ; //X3_DESCRIC
    "Obs de Inclusão/Alteração"    			         	    					, ; //X3_DESCSPA
    "Obs de Inclusão/Alteração"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LEO'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'LEO_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LEO'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'LEO_USAPRO'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LEO'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LEO_USAPRO'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/***************************************** LIP ******************************************/
aAdd( aSX3, { ;
    'LIP'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LIP_OBSALT'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                        	                , ; //X3_TITULO
    "Obs Inc/Alt"                 			                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            		                  	                    , ; //X3_TITENG
    "Obs de Inclusão/Alteração"	            	  	    	      				, ; //X3_DESCRIC
    "Obs de Inclusão/Alteração"    			         	    					, ; //X3_DESCSPA
    "Obs de Inclusão/Alteração"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME 

aAdd( aSX3, { ;
    'LIP'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'LIP_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LIP'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LIP_USAPRO'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME
    
/******************************* LKA *************************************************/
aAdd( aSX3, { ;
    'LKA'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKA_OBSALT'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                        	                , ; //X3_TITULO
    "Obs Inc/Alt"                 			                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            		                  	                    , ; //X3_TITENG
    "Obs de Inclusão/Alteração"	            	  	    	      				, ; //X3_DESCRIC
    "Obs de Inclusão/Alteração"    			         	    					, ; //X3_DESCSPA
    "Obs de Inclusão/Alteração"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME 

aAdd( aSX3, { ;
    'LKA'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'LKA_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LKA'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKA_USAPRO'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/********************************* LKB ******************************************/

aAdd( aSX3, { ;
    'LKB'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKB_CRF'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    5				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Numero CRF"	                                        	                , ; //X3_TITULO
    "Numero CRF"                 			                                   	, ; //X3_TITSPA 
    "Numero CRF"	            		                  	                    , ; //X3_TITENG
    "Número de Inscrição CRF"            	  	    	 	     				, ; //X3_DESCRIC
    "Número de Inscrição CRF"  			         	    						, ; //X3_DESCSPA
    "Número de Inscrição CRF"      	      		         	     	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    "T_DroCRF(M->LKB_CRF)"			               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LKB'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKB_RESPON'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    1				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Farm. Resp."	                                        	                , ; //X3_TITULO
    "Farm. Resp."                 			                                   	, ; //X3_TITSPA 
    "Farm. Resp."	            		                  	                    , ; //X3_TITENG
    "Farmacêutico Responsável"            	  	    	 	     				, ; //X3_DESCRIC
    "Farmacêutico Responsável" 			         	    						, ; //X3_DESCSPA
    "Farmacêutico Responsável"     	      		         	     	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    "Vazio() .OR. Pertence('12')"	               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    "'2'"                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '1=Sim;2=Não'									                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LKB'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKB_CUSERI'				               		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    6				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Cod. Usuário"	                                        	                , ; //X3_TITULO
    "Cod. Usuário"                 			                                   	, ; //X3_TITSPA 
    "Cod. Usuário"	            		                  	                    , ; //X3_TITENG
    "Código do Usuário Protheus"           	  	    	 	     				, ; //X3_DESCRIC
    "Código do Usuário Protheus"		         	    						, ; //X3_DESCSPA
    "Código do Usuário Protheus"   	      		         	     	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    "RetCodUsr()"                                                              	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    ''												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LKB'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKB_OBSALT'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                        	                , ; //X3_TITULO
    "Obs Inc/Alt"                 			                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            		                  	                    , ; //X3_TITENG
    "Obs de Inclusão/Alteração"	            	  	    	      				, ; //X3_DESCRIC
    "Obs de Inclusão/Alteração"    			         	    					, ; //X3_DESCSPA
    "Obs de Inclusão/Alteração"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME 

aAdd( aSX3, { ;
    'LKB'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'LKB_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LKB'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKB_USAPRO'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/******************************* SLQ *********************************************************/
SX3->( dbSetOrder(2) )
SX3->( dbSeek( PadR("A1_BAIRRO",nTamFld) ))
cUsadoOpc	:= SX3->X3_USADO
cReservOpc	:= SX3->X3_RESERV

aAdd( aSX3, { ;
    'SLQ'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'LQ_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SLQ'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LQ_USAPROV'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/**************************************** SL1 *********************************************/
aAdd( aSX3, { ;
    'SL1'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'L1_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SL1'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'L1_USAPROV'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

SX3->( dbSeek( PadR("LK9_CODPRO",nTamFld) ) )
cUsadoOpc	:= SX3->X3_USADO
cReservOpc	:= SX3->X3_RESERV
cObrigat	:= SX3->X3_OBRIGAT

/**********************************  SB7 *********************************************/
aAdd( aSX3, { ;
    'SB7'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B7_LIVRO'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Livro Espec."	                                        	                , ; //X3_TITULO
    "Livro Espec."                 			                                   	, ; //X3_TITSPA 
    "Livro Espec."	            		                  	                    , ; //X3_TITENG
    "Livro na mudanca de Clas"	            	  	    	      				, ; //X3_DESCRIC
    "Livro na mudanca de Clas"    			         	    					, ; //X3_DESCSPA
    "Livro na mudanca de Clas"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB7'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B7_PAGINA'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    5				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Num. Pagina"	                                        	                , ; //X3_TITULO
    "Num. Pagina"                 			                                   	, ; //X3_TITSPA 
    "Num. Pagina"	            		                  	                    , ; //X3_TITENG
    "Num. Pagina Alt. Class"	            	  	    	      				, ; //X3_DESCRIC
    "Num. Pagina Alt. Class"    			         	    					, ; //X3_DESCSPA
    "Num. Pagina Alt. Class"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB7'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B7_OBSALTE'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                        	                , ; //X3_TITULO
    "Obs Inc/Alt"                 			                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            		                  	                    , ; //X3_TITENG
    "Obs de Inclusão/Alteração"	            	  	    	      				, ; //X3_DESCRIC
    "Obs de Inclusão/Alteração"    			         	    					, ; //X3_DESCSPA
    "Obs de Inclusão/Alteração"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME 

aAdd( aSX3, { ;
    'SB7'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'B7_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB7'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B7_USAPRO'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME
    
/************************************************ SB9 **************************************/

aAdd( aSX3, { ;
    'SB9'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B9_OBSALTE'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    150				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Obs Inc/Alt"	                                        	                , ; //X3_TITULO
    "Obs Inc/Alt"                 			                                   	, ; //X3_TITSPA 
    "Obs Inc/Alt"	            		                  	                    , ; //X3_TITENG
    "Obs de Inclusão/Alteração"	            	  	    	      				, ; //X3_DESCRIC
    "Obs de Inclusão/Alteração"    			         	    					, ; //X3_DESCSPA
    "Obs de Inclusão/Alteração"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    cObrigat                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME 

aAdd( aSX3, { ;
    'SB9'                                                                   	, ; //X3_ARQUIVO
    ''                                                                  	, ; //X3_ORDEM
    'B9_USVENDA'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Alterado por"	                                        	                , ; //X3_TITULO
    "Alterado por"                 			                                   	, ; //X3_TITSPA 
    "Alterado por"	            		                  	                    , ; //X3_TITENG
    "Alterado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Alterado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Alterado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB9'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B9_USAPRO'			                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Aprovado por"	                                        	                , ; //X3_TITULO
    "Aprovado por"                 			                                   	, ; //X3_TITSPA 
    "Aprovado por"	            		                  	                    , ; //X3_TITENG
    "Aprovado pelo usuário"	            	  	    	      				, ; //X3_DESCRIC
    "Aprovado pelo usuário"    			         	    					, ; //X3_DESCSPA
    "Aprovado pelo usuário"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'V'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB9'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B9_LIVRO'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    25				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Livro Espec."	                                        	                , ; //X3_TITULO
    "Livro Espec."                 			                                   	, ; //X3_TITSPA 
    "Livro Espec."	            		                  	                    , ; //X3_TITENG
    "Livro na mudanca de Clas"	            	  	    	      				, ; //X3_DESCRIC
    "Livro na mudanca de Clas"    			         	    					, ; //X3_DESCSPA
    "Livro na mudanca de Clas"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'SB9'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'B9_PAGINA'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    5				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Num. Pagina"	                                        	                , ; //X3_TITULO
    "Num. Pagina"                 			                                   	, ; //X3_TITSPA 
    "Num. Pagina"	            		                  	                    , ; //X3_TITENG
    "Num. Pagina Alt. Class"	            	  	    	      				, ; //X3_DESCRIC
    "Num. Pagina Alt. Class"    			         	    					, ; //X3_DESCSPA
    "Num. Pagina Alt. Class"        	      		              	 			, ; //X3_DESCENG
    ''  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																	, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc 			                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME
    
/********************************** LKD ***************************************/
SX3->( dbSeek( PadR("A1_FILIAL",nTamFld) ) )

aAdd( aSX3, { ;
    'LKD'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKD_FILIAL'			                  		                	       	, ; //X3_CAMPO
    SX3->X3_TIPO                                                            	, ; //X3_TIPO
    SX3->X3_TAMANHO	                                                       		, ; //X3_TAMANHO
    SX3->X3_DECIMAL                                                             , ; //X3_DECIMAL
    SX3->X3_TITULO	                                        	                , ; //X3_TITULO
    SX3->X3_TITSPA                			                                   	, ; //X3_TITSPA 
    SX3->X3_TITENG	            		                  	                    , ; //X3_TITENG
    SX3->X3_DESCRIC	            	  	    				      				, ; //X3_DESCRIC
    SX3->X3_DESCSPA    						         	    					, ; //X3_DESCSPA
    SX3->X3_DESCENG				        	   		              	 			, ; //X3_DESCENG
    SX3->X3_PICTURE	                              	                         	, ; //X3_PICTURE
    SX3->X3_VALID						           								, ; //X3_VALID
	SX3->X3_USADO																, ;	//X3_USADO
    SX3->X3_RELACAO                                                             , ; //X3_RELACAO
    SX3->X3_F3      	                                                  		, ; //X3_F3
    SX3->X3_NIVEL                                                               , ; //X3_NIVEL
    SX3->X3_RESERV 			                                              		, ; //X3_RESERV
    SX3->X3_CHECK               		                                        , ; //X3_CHECK
    SX3->X3_TRIGGER     		                                                , ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    SX3->X3_BROWSE                                                             	, ; //X3_BROWSE
    SX3->X3_VISUAL                                                             	, ; //X3_VISUAL
    SX3->X3_CONTEXT                                                            	, ; //X3_CONTEXT
    SX3->X3_OBRIGAT                                                            	, ; //X3_OBRIGAT
    SX3->X3_VLDUSER                                                            	, ; //X3_VLDUSER
    SX3->X3_CBOX									                          	, ; //X3_CBOX
    SX3->X3_CBOXSPA                                                            	, ; //X3_CBOXSPA
    SX3->X3_CBOXENG                                                            	, ; //X3_CBOXENG
    SX3->X3_PICTVAR                                                            	, ; //X3_PICTVAR
    SX3->X3_WHEN                                                               	, ; //X3_WHEN
    SX3->X3_INIBRW                                                             	, ; //X3_INIBRW
    SX3->X3_GRPSXG                                                             	, ; //X3_GRPSXG
    SX3->X3_FOLDER                                                             	, ; //X3_FOLDER
    SX3->X3_PYME                                                               	} ) //X3_PYME

SX3->( dbSeek( PadR("A1_BAIRRO",nTamFld) ) )
cUsadoOpc	:= SX3->X3_USADO
cReservOpc	:= SX3->X3_RESERV
cObrigat	:= SX3->X3_OBRIGAT

aAdd( aSX3, { ;
    'LKD'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKD_CODDCB'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    9				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Codigo DCB"	                                        	                , ; //X3_TITULO
    "Codigo DCB"                 			                                   	, ; //X3_TITSPA 
    "Codigo DCB"	            		                  	                    , ; //X3_TITENG
    "Codigo da DCB"	            	  	    	      				, ; //X3_DESCRIC
    "Codigo da DCB"    			         	    					, ; //X3_DESCSPA
    "Codigo da DCB"        	      		              	 			, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc		                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'N'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LKD'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKD_DSCDCB'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    50				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Desc. DCB"	                                        	                , ; //X3_TITULO
    "Desc. DCB"                 			                                   	, ; //X3_TITSPA 
    "Desc. DCB"	            		                  	                    , ; //X3_TITENG
    "Descrição da DCB"	            	  	    	      				, ; //X3_DESCRIC
    "Descrição da DCB"    			         	    					, ; //X3_DESCSPA
    "Descrição da DCB"        	      		              	 			, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc		                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'S'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'N'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    'LKD'                                                                   	, ; //X3_ARQUIVO
    ''			                                                               	, ; //X3_ORDEM
    'LKD_NUMCAS'				                  		                	       	, ; //X3_CAMPO
    'C'                                                                     	, ; //X3_TIPO
    13				                                                       		, ; //X3_TAMANHO
    0                                                                       	, ; //X3_DECIMAL
    "Numero CAS"	                                        	                , ; //X3_TITULO
    "Numero CAS"                 			                                   	, ; //X3_TITSPA 
    "Numero CAS"	            		                  	                    , ; //X3_TITENG
    "Numero do CAS"	            	  	    	      				, ; //X3_DESCRIC
    "Numero do CAS"    			         	    					, ; //X3_DESCSPA
    "Numero do CAS"        	      		              	 			, ; //X3_DESCENG
    '@!'  		                                	                         	, ; //X3_PICTURE
    ""								               								, ; //X3_VALID
	cUsadoOpc																, ;	//X3_USADO
    ""                                                                      	, ; //X3_RELACAO
    ''      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    cReservOpc		                                                		, ; //X3_RESERV
    ''                                                                      	, ; //X3_CHECK
    ''                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    'N'                                                                     	, ; //X3_BROWSE
    'A'                                                                     	, ; //X3_VISUAL
    'R'                                                                     	, ; //X3_CONTEXT
    ''		                                                                   	, ; //X3_OBRIGAT
    ''                                                                      	, ; //X3_VLDUSER
    '' 												                          	, ; //X3_CBOX
    ''                                                                      	, ; //X3_CBOXSPA
    ''                                                                      	, ; //X3_CBOXENG
    ''                                                                      	, ; //X3_PICTVAR
    ''                                                                      	, ; //X3_WHEN
    ''                                                                      	, ; //X3_INIBRW
    ''                                                                      	, ; //X3_GRPSXG
    ''                                                                      	, ; //X3_FOLDER
    'N'                                                                      	} ) //X3_PYME

/********************************************************
---------------------------------------------------------
Alterações em alguns campos que já existiam no dicionário
e eram alterados pelos UPD's

-- os campos que não forem atualizados devem ser passados 
	com NIL
---------------------------------------------------------
********************************************************/
aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LK9_CONPRO'			                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    5				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        	                			, ; //X3_TITULO
    NIL                 			                                   			, ; //X3_TITSPA 
    NIL	            		                  	                    			, ; //X3_TITENG
    NIL	            	  	    	      										, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        	      		              	 									, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL								               								, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL                                                                      	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                               				 		, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL 												                       	, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

SX3->(DbSeek(PadR("L1_DOC",nTamFld)))

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LK9_DOC'			                  		                	       		, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    SX3->X3_TAMANHO	                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        	                			, ; //X3_TITULO
    NIL                 			                                   			, ; //X3_TITSPA 
    NIL	            		                  	                   				, ; //X3_TITENG
    NIL	            	  	    	      										, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        	      		              	 									, ; //X3_DESCENG
    SX3->X3_PICTURE                                	                         	, ; //X3_PICTURE
    NIL								               								, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL                                                                      	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL 												                        , ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    SX3->X3_GRPSXG                                                             	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LK9_TIPMOV'			                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    "Pertence('1234567')"								               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL                                                                      	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    "1=Compra;2=Venda;3=Transferencia;4=Perda;5=XML ANVISA;6=Inventario ANVISA;7=Estorno Compra", ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LK9_LOTE'			                  		                	       		, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL													               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL			                                                            	, ; //X3_RELACAO
    "SB8"      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

SX3->(DbSeek(PadR("D1_QUANT",nTamFld)))

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LK9_QUANT'				                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    SX3->X3_TAMANHO	                                                       		, ; //X3_TAMANHO
    SX3->X3_DECIMAL                                                            	, ; //X3_DECIMAL
    NIL	                                        	                			, ; //X3_TITULO
    NIL                 			                                   			, ; //X3_TITSPA 
    NIL	            		                  	                    			, ; //X3_TITENG
    NIL	            	  	    	      										, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        	      		              	 									, ; //X3_DESCENG
    SX3->X3_PICTURE                                	                         	, ; //X3_PICTURE
    NIL								               								, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL                                                                      	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                               				 		, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL 												                       	, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LKB_NOME'				                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL													               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    "UsrFullName()"                                                            	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    "V"                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LKB_CPF'				                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    "T_DroCPF(M->LKB_CPF)"								               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL			                                                            	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'B1_FABRIC'				                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL													               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    "Iif(!inclui,Posicione('SA2',1,xFilial('SA2')+M->B1_CODFAB+M->B1_LOJA,'A2_NOME'),'')", ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    cAbaDrogar                                                                 	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LX5_DESCRI'			                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    60				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL													               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL			                                                            	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'F1_DESCFIN'			                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL													               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL			                                                            	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'T'	                                                                     	, ; //X3_PROPRI
    "N"                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME
    
aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LR_PRODUTO'			                  		                	       	, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL													               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL			                                                            	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'S'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

aAdd( aSX3, { ;
    NIL                                                                   		, ; //X3_ARQUIVO
    NIL			                                                               	, ; //X3_ORDEM
    'LR_QUANT'			                  		                	       		, ; //X3_CAMPO
    NIL                                                                     	, ; //X3_TIPO
    NIL				                                                       		, ; //X3_TAMANHO
    NIL                                                                       	, ; //X3_DECIMAL
    NIL	                                        								, ; //X3_TITULO
    NIL                 			        		                           	, ; //X3_TITSPA 
    NIL	            		    			              	                    , ; //X3_TITENG
    NIL							            	  	    	      				, ; //X3_DESCRIC
    NIL    			         	    											, ; //X3_DESCSPA
    NIL        							      		              	 			, ; //X3_DESCENG
    NIL  		                                	                         	, ; //X3_PICTURE
    NIL													               			, ; //X3_VALID
	NIL																			, ;	//X3_USADO
    NIL			                                                            	, ; //X3_RELACAO
    NIL      	                                                         		, ; //X3_F3
    1                                                                       	, ; //X3_NIVEL
    NIL		                                                					, ; //X3_RESERV
    NIL                                                                      	, ; //X3_CHECK
    NIL                                                                      	, ; //X3_TRIGGER
    'S'	                                                                     	, ; //X3_PROPRI
    NIL                                                                     	, ; //X3_BROWSE
    NIL                                                                     	, ; //X3_VISUAL
    NIL                                                                     	, ; //X3_CONTEXT
    NIL		                                                                   	, ; //X3_OBRIGAT
    NIL                                                                      	, ; //X3_VLDUSER
    NIL																			, ; //X3_CBOX
    NIL                                                                      	, ; //X3_CBOXSPA
    NIL                                                                      	, ; //X3_CBOXENG
    NIL                                                                      	, ; //X3_PICTVAR
    NIL                                                                      	, ; //X3_WHEN
    NIL                                                                      	, ; //X3_INIBRW
    NIL                                                                      	, ; //X3_GRPSXG
    NIL                                                                      	, ; //X3_FOLDER
    'S'                                                                      	} ) //X3_PYME

/*--------------------------------
 	Gravação do SX3
--------------------------------*/
cTabAtu := ""
cOrdem	:= "01"
SX3->(dbSetOrder(2))

For nX := 1 to Len(aSX3)
	
	lNewReg	:= !SX3->( dbSeek( PadR(aSX3[nX,3],nTamFld) ) )
	
	Conout(" Criando/Alterando Campos de Template DRO - [" + aSX3[nX,3] + "]")	
	cMensagem += " Criando/Alterando Campos de Template DRO - [" + aSX3[nX,3] + "]" + _PLINHA
		
	//Inserção da ordem dos campos
	If lNewReg .And. (aSX3[nX][1] <> NIL) 
		If aSX3[nX][1] <> cTabAtu
		 	cTabAtu := aSX3[nX][1]
			
			SX3->( DbSetOrder(1) )
			SX3->( DbSeek(aSX3[nX][1]+"Z",.T.) )
			SX3->( DbSkip(-1) )
			
			If SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cTabAtu
				cOrdem := Soma1(SX3->X3_ORDEM)
			EndIf
			
			SX3->( DbSetOrder(2) ) //Deve retornar ao indice anterior
		Else
			cOrdem := Soma1(cOrdem)
		EndIf
		
		aSX3[nX,2] := cOrdem

	ElseIf !lNewReg
		aSX3[nX][2]	:= AllTrim(SX3->X3_ORDEM)
	EndIf
	
	RecLock("SX3",lNewReg)
    
    For nY:= 1 To Len(aSX3[nX])    	
    	nPos := SX3->(ColumnPos(aEstruSX3[nY]))
        If nPos > 0 .And. (aSX3[nX,nY] <> NIL)
            FieldPut(nPos,aSX3[nX,nY])
        EndIf
    Next nY
    
    SX3->(dbCommit())
    SX3->(MsUnLock())
Next nX

cOrdem := ""
For nX := 1 To Len(aSX3)
	If (aSX3[nX][1] <> NIL) .And. !(aSX3[nX][1] $ cOrdem)
		//Bloqueia alterações no Dicionário
		__SetX31Mode(.F.)
		
		//Atualiza o Dicionário
		X31updtable(aSX3[nX][1])
		
		//Se a tabela tiver aberta nessa seção, fecha
		If Select(aSX3[nX][1]) > 0
			(aSX3[nX][1])->(DbCloseArea())
		EndIf 
		
		//Se houve Erro na Rotina
		If __GetX31Error()
			cMensagem +=  " Houveram erros na atualização da tabela "+aSX3[nX][1] +"."+_PLINHA
			COnout(" Houveram erros na atualização da tabela "+aSX3[nX][1] +".")
			cMensagem += __GetX31Trace() +_PLINHA	
		Else
			//Abrindo a tabela para criar dados no sql
			DbSelectArea(aSX3[nX][1])
			cMensagem +=  " Realizada geração da tabela "+aSX3[nX][1] +"."+_PLINHA
			COnout(" Realizada geração da tabela "+aSX3[nX][1]+".")
			(aSX3[nX][1])->(DbCloseArea())
		EndIf           
		
		//Desbloqueando alterações no dicionário
		__SetX31Mode(.T.)
		
		cOrdem += aSX3[nX][1] + "|"
	EndIf
Next nX

/**************************************
CAMPOS DA SB1 que foram enviados para 
a aba de 'Drogaria'
**************************************/
SX3->( DbSetOrder(2) )

ASize(aSX3,0)
aSX3 := {}
aAdd(aSx3,{"B1_CODFAB"})
aAdd(aSx3,{"B1_LOJA"})   
aAdd(aSx3,{"B1_GENERIC"})
aAdd(aSx3,{"B1_CODPRIN"})
aAdd(aSx3,{"B1_PRINATV"})
aAdd(aSx3,{"B1_CODAPRE"})
aAdd(aSx3,{"B1_APRESEN"})
aAdd(aSx3,{"B1_CODPATO"})
aAdd(aSx3,{"B1_PATOLOG"})
aAdd(aSx3,{"B1_CODCOTL"})
aAdd(aSx3,{"B1_CONTROL"})
aAdd(aSx3,{"B1_CODSMPR"})
aAdd(aSx3,{"B1_SIMILPR"})
aAdd(aSx3,{"B1_SUSPENC"})
aAdd(aSx3,{"B1_SUSPVEN"})
aAdd(aSx3,{"B1_ETIQUET"})
aAdd(aSx3,{"B1_REFEREN"})
aAdd(aSx3,{"B1_CONTPRE"})
aAdd(aSx3,{"B1_MINCUS"})
aAdd(aSx3,{"B1_DMINCUS"})
aAdd(aSx3,{"B1_MAXCUS"}) 
aAdd(aSx3,{"B1_DMAXCUS"})
aAdd(aSx3,{"B1_MARKUP"})
aAdd(aSx3,{"B1_REGMS"})
aAdd(aSx3,{"B1_PSICOTR"})

For nX := 1 to Len(aSX3)
	Conout(" Alterando Campos de Template DRO - [" + aSX3[nX,1] + "]")	
	cMensagem += " Alterando Campos de Template DRO - [" + aSX3[nX,1] + "]" + _PLINHA
	
	If SX3->( dbSeek( PadR(aSX3[nX,1],nTamFld) ) )
		RecLock("SX3",.F.)
	    REPLACE SX3->X3_FOLDER WITH cAbaDrogar	    
	    SX3->(dbCommit())
	    SX3->(MsUnLock())
	EndIf
Next nX

cMensagem += " Final da função LjDrCriaX3 - Criação/Alteração de Campos" + _PLINHA
Conout(" Final da função LjDrCriaX3 - Criação/Alteração de Campos ")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrCriaXA(cMensagem)
Ajuste de SXA que era feito pelo UPDDROXXX

@Param cMensagem - variavel para acumular as mensagens da funções
@author Julio.nery
@since 13/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrCriaXA(cMensagem)
Local aDados	:= {}
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nTamFld	:= 0
Local lNewReg	:= .F.
Local cOrdem	:= ""
Local cDescr	:= ""
Local aEstrut	:= LjSxTable("10")

SXA->(DbSetOrder(1))
nTamFld := Len(SXA->XA_ALIAS)

cMensagem += "Inicio da função LjDrCriaXA - criação/alteração da SXA" + _PLINHA
ConOut("Inicio da função LjDrCriaXA - criação/alteração da SXA")

//SB1
cDescr := "Drogaria" 
Aadd(aDados,{"SB1","9",cDescr,cDescr,cDescr,"T","",""})

For nX := 1 to Len(aDados)
	
	Conout(" Criando/Alterando o SXA - [" + aDados[nX,1] + aDados[nX,2] + "]")
	cMensagem += " Criando/Alterando o SXA - [" + aDados[nX,1] + aDados[nX,2] + "]"
	
	cOrdem	:= ""

	If SXA->( dbSeek(Padr(aDados[nX,1],nTamFld)+"Z",.T.) )
		SXA->( dbSkip(-1) )
		If SXA->( !Eof() ) .AND. SXA->XA_ALIAS == "SB1"
			cOrdem := Soma1(SXA->XA_ORDEM)
		EndIf
	Endif
	
	lNewReg	:= !SXA->(DbSeek(Padr(aDados[nX,1],nTamFld)+aDados[nX,2]))
	
	If !lNewReg .And. !(Upper(AllTrim(SXA->XA_DESCRIC)) == Upper(aDados[nX,3]))
		SXA->(DbSeek(aDados[nX,1] + "1"))
		While !SXA->(Eof()) .AND. ( AllTrim(SXA->XA_ALIAS) == aDados[nX][1] )
    		
    		If Upper(AllTrim(SXA->XA_DESCRIC)) == Upper(AllTrim( aDados[nX][3]))
    			cOrdem := AllTrim(SXA->XA_ORDEM)
    			Exit
    		Else
    			cOrdem := Soma1(SXA->XA_ORDEM)    			
    		EndIf
    		
    		SXA->(DbSkip())
    	End
	EndIf

	If ! Empty(cOrdem) 	
		aDados[nX][2] := cOrdem //Ajusta a ordem
	EndIf
	
	/* Precisa pegar a aba aonde será inserida Drogaria
	para atualizar os campos da SB1 */
	If (aDados[nX,1] == "SB1") .And. (aDados[nX,3] == "Drogaria") .And. (cAbaDrogar <> aDados[nX,2])
		cAbaDrogar := aDados[nX,2]
	EndIf
	
	RecLock("SXA",lNewReg)
    For nY:= 1 To Len(aDados[nX])
    	nPos := SXA->(ColumnPos(aEstrut[nY]))
        If nPos > 0 .And. aDados[nX,nY] <> NIL
            FieldPut(nPos,aDados[nX,nY])
        EndIf
    Next nY
    SXA->(dbCommit())
    SXA->(MsUnLock())
Next nX

cMensagem += "Término da função LjDrCriaXA - criação/alteração da SXA" + _PLINHA
ConOut("Término da função LjDrCriaXA - criação/alteração da SXA")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjDrFdUpd(cMensagem,aSX3Ori)
Insere os campos que anteriormente eram criados via UPDDRO
@param cMensagem - mensagem de log do processo
@Param aCampos - campos para criação
@author Julio.nery
@since 07/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function LjDrFdUpd(cMensagem)
Local aArea := {}
Local aTabs	:= {"SX1","SX2","SX3","SX6","SX7","SIX","SXA","SXB"}
Local nX	:= 0

For nX := 1 to Len(aTabs)
	DbSelectArea(aTabs[nX])
	Aadd(aArea,(aTabs[nX])->(GetArea()))
Next nX

cMensagem += " Inicio da função LjDrFdUpd - Aplicação dos UPDDROXX's " + _PLINHA
ConOut(" Inicio da função LjDrFdUpd - Aplicação dos UPDDROXX's ")

/*------------------------------------------------------
	Gravação/Alteração de SXA - Abas 
Preenche a variável estática cAbaDrogar, deixar no começo 
-------------------------------------------------------*/
LjDrCriaXA(@cMensagem)

/*------------------------------------------------------
	Gravação/Alteração de SX1 - Perguntas
-------------------------------------------------------*/
LjDrCriaX1(@cMensagem)

/*------------------------------------------------------
	Gravação/Alteração de SX2 e SIX - Tabelas e Indices
-------------------------------------------------------*/
LjDrCriaX2(@cMensagem)

/*------------------------------------------------------
	Gravação/Alteração de SX3
-------------------------------------------------------*/
LjDrCriaX3(@cMensagem)

/*-----------------------------------------
	Gravação/Alteração de SX7 - Gatilhos
------------------------------------------*/
LjDrCriaX7(@cMensagem)

/*----------------------------------------------
	Gravação/Alteração de SXB - Consulta Padrão
------------------------------------------------*/
LjDrCriaXB(@cMensagem)

/*-----------------------------------------
	Gravação/Alteração de SX6 - Parametros
------------------------------------------*/
LjDrCriaX6(@cMensagem)

cMensagem += "Final da função LjDrFdUpd - Aplicação dos UPDDROXX's " + _PLINHA
ConOut("Final da função LjDrFdUpd - Aplicação dos UPDDROXX's ")

For nX := 1 to Len(aArea)
	RestArea(aArea[nX])
Next nX

Return 