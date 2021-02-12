#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "ERROR.CH"
#INCLUDE "FRTA020.CH"
#INCLUDE "FRTDEF.CH"
#DEFINE NTRIM(n)		( LTrim(Str(n)) )
                       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Defines utilizados para EventViewer  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE IDEVENT "051"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³ FRTA020  ³ Autor ³ Vendas e CRM			³ Data ³16/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Thread "OnStart" de Conexao RPC com o Server               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static oServer
Static lEndThread
Static aCargaOK    
Static lAltThread 	:= .T.   // Alterou a Thread
Static lConnect 	:= .F.   // Controla se esta conectado (FWRPC)
Static nContCon		:= 0
Static nTotCon		:= 0

Static cHrUpVenda	:= Time()	// Armzena horario da subida da ultima venda com sucesso (L1_SITUA=OK)

Function FRTA020(cLocalEmp, cLocalFil, _cEstacao, _cVendas, _cConexoes, _cTmEndJob)
Local nHdl
Local lWait			:= .F.
Local nTries		:= 0
Local nI			:= 0                                 
Local nVendas		:= 0	// Quantidade de vendas antes do reset do RPC, vindo do mp8srv.ini (Param4)
Local nConexoes		:= 0	// Quantidade de conexoes antes do reset do RPC, vindo do mp8srv.ini (Param5)
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deve possuir o nome do fonte + Ambiente do Server + ³
//³ID da Thread pois e' um por server, independente do ³
//³Environment que o acesse.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cResetRPC 	:= Upper( "FRTA020" + GetEnvServer() + "_" + StrZero(ThreadID(),10) )		// Nome da variavel global

Local nTmEndJob		:= 0	// Tempo em minutos para o job ser finalizado caso não ocorra subida de venda com sucesso (Deve-se configurar RefreshRate para reiniciar o servico)

DEFAULT _cVendas	:= 0	// Quantidade de vendas antes do reset do RPC, vindo do mp8srv.ini (Param4)
DEFAULT _cConexoes	:= 0	// Quantidade de conexoes antes do reset do RPC, vindo do mp8srv.ini (Param5)    
DEFAULT _cTmEndJob	:= 0	// Tempo em minutos para o job ser finalizado caso não ocorra subida de venda com sucesso (Deve-se configurar RefreshRate para reiniciar o servico)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se os novos parametros do mp8srv.ini estao preenchidas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType( _cVendas ) == "C" .AND. !Empty( Trim( _cVendas ) )
	nVendas	:= Val( _cVendas )
EndIf

If ValType( _cConexoes ) == "C" .AND. !Empty( Trim( _cConexoes ) )	
	nConexoes := Val( _cConexoes )
Endif	

If ValType( _cTmEndJob ) == "C" .AND. !Empty( Trim( _cTmEndJob ) )	
	nTmEndJob := Val( _cTmEndJob )
	ConOut(STR0126+cValToChar(nTmEndJob)+STR0127)	//"Front Loja: Job configurado para finalizar por inatividade de venda em " ## " minuto(s) e reiniciado no intervalo definido no RefreshRate."
Endif	

nHdl := MSFCreate("FRT020.LCK")
IF nHdl < 0                           
	ConOut("******************************************")
	ConOut("File system with problems, file FRT020.LCK")   
	ConOut("******************************************")
	UserException("Impossible create on FRT020.LCK")
Endif
FClose(nHdl)
                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apaga semaforos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FErase("STOPFRT.LCK")
FErase("FRT020.LCK")
FErase("FRTCS.LCK")

If File(GetPvProfString("FRONTLOJA_RPC","RootPath","",GetAdv97()) + "RPCFRONT.INI")
	WritePProString("RPC", "UltimoServer", "0", GetPvProfString("FRONTLOJA_RPC","RootPath","",GetAdv97()) + "RPCFRONT.INI")			
EndIf

While !KillApp() .AND. !File('STOPFRT.LCK')
	If lWait
		// "Front Loja: Aguardando 60 segundos para reestabelecer a conexao..."
		ConOut(STR0084+Chr(13)+Chr(10))
		
		If File("conexao.frt")   	        
   			FERASE("conexao.frt")
   	    EndIf	
   	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Espera aproximadamente 60  Segundos, contudo avaliando se foi solicitado ³
		//³a paralisação dos servicos (Jobs).                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		While !KillApp() .AND. !File('STOPFRT.LCK') .AND. nTries <= ( 60+Randomize(0,60) ) .AND. ( GetGlbValue( cResetRPC ) <> "S" ) 
			Sleep(1000)
			SysRefresh()
			nTries ++
		End
		If KillApp()
			Exit
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"Zera" a global antes de executar o job novamente.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PutGlbValue(cResetRPC,"N")
	ConOut(STR0036)	//"Front Loja: Subindo Thread de sincronizacao"
	StartJob("MyFrt020",GetEnvServer(),.f.,cLocalEmp,cLocalFil,_cEstacao, nVendas, nConexoes, cResetRPC, nTmEndJob )
	// Esperar 30 segundos
	// Se der CTRL+BREAK, sai imediatamente
	For nI := 1 to 30 
		If KillApp()
			Exit
		EndIf
		Sleep(1000)
	Next nI
	
	nHdl := MSFCreate("FRT020.LCK")
	
	While !KillApp() .AND. nHdl < 0  .AND. !File('STOPFRT.LCK')
		// Esperar 60 segundos
		// Se der CTRL+BREAK, sai imediatamente  
		For nI := 1 to 60
			If KillApp()
				Exit
			EndIf
			Sleep(1000)
		Next nI
		
	   nHdl := MSFCreate("FRT020.LCK")
	End 
	                               
	IF nHdl >= 0
	   FClose(nHdl)
	Endif
	lWait := .T.
End 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sinalize que todos os servicos (Jobs) foram baixados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSFCreate("FRTCS.LCK")  
PutGlbValue( cResetRPC, "" )
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ MyFrt020 ³ Autor ³ Microsiga             ³ Data ³08/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Job da subida das vendas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FuncTion MyFrt020(cLocalEmp, cLocalFil, _cEstacao, nVendas, nConexoes, cResetRPC, nTmEndJob )

Local bErro := {|x| FRTA020MyErro(x)}
Local nHdl  := MSFCreate("FRT020.LCK")                                
Local nX 

DEFAULT nVendas		:= 0	// Quantidade de vendas antes do reset do RPC, vindo do mp8srv.ini (Param4)
DEFAULT nConexoes	:= 0	// Quantidade de conexoes antes do reset do RPC, vindo do mp8srv.ini (Param5)
DEFAULT nTmEndJob	:= 0 	// Tempo em minutos configurado para derrubar o job por inatividade
	
If nHdl < 0
   ConOut("*******************************************")
   ConOut(STR0037)	//"Foi impossivel locar  o semaforo FRT020.LCK"
   ConOut(STR0038)	//"O PDV Esta sem sincronizacao "
   ConOut("*******************************************")
   UserException("Impossible lock in FRT020.LCK")
Endif

lEndThread := .F.

RpcMyErro()
ErrorBlock(bErro)

MakeDir("\SEMAFORO")

While !KillApp() .AND. !lEndThread .AND. !File('STOPFRT.LCK')
	BEGIN SEQUENCE
		nHdl := MSFCREATE("\SEMAFORO\F"+StrTran(cLocalEmp+cLocalFil+_cEstacao," ","")+".LCK") 
	   	IF nHdl >= 0                                    
	      	FClose(nHdl)                  
			MyFRTA020( cLocalEmp,cLocalFil,_cEstacao,nVendas,nConexoes,cResetRPC,nTmEndJob)
		EndIf
		
	END SEQUENCE
	oServer := NIL

    For nX := 1 to 5
       If KillApp()
	      Exit
	   EndIf
	   Sleep(1000)
    Next nX
End       

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FRTA020MyE³ Autor ³ Microsiga             ³ Data ³08/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Bloco de tratamento do erro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTA020MyErro(oErro)
Local cBuffer	:= ""

If KillApp() .OR. lEndThread
	Return
Endif

cBuffer := MemoRead("FRTA020.LOG")
MemoWrite("FRTA020.LOG", DToC(dDataBase)+"  "+Time()+Chr(10)+;
	ErrorMessage(oErro)+Chr(10)+Repl("*",40)+Chr(10)+Chr(10)+cBuffer)
If oErro:GenCode == EG_JOB
	If !("RpcSetEnv" $ ErrorMessage(oErro))
		ConOut(Chr(13)+Chr(10)+ErrorMessage(oErro)+Chr(13)+Chr(10))
	EndIf
	RESET ENVIRONMENT
Else
	ConOut(ErrorMessage(oErro))
	If ( oErro:GenCode == EG_ZERODIV )
		return (0)
	ElseIf (oErro:GenCode == EG_NOALIAS)
		If !Chkfile(oErro:Operation)
			ConOut("Alias Does Not Exist "+e:Operation)
		EndIf                                                                            
		Return
	EndIf
EndIf

__QUIT()             

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ErrorMessa³ Autor ³ Microsiga             ³ Data ³08/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Montagem da Mensagem de Erro                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ErrorMessage(e)

// start error message
Local cMessage := If( Empty( e:osCode ), If( e:severity > ES_WARNING, "Error ", "Warning " ),; 
						"(DOS Error " + NTRIM(e:osCode) + ") " )

// add subsystem name if available
cMessage += If( ValType( e:subsystem ) == "C", e:subsystem, "???" )

// add subsystem's error code if available
cMessage += If( ValType( e:subCode ) == "N", "/" + NTRIM( e:subCode ), "/???" )

// add error description if available
If ( ValType(e:description) == "C" )
	cMessage += "  " + e:description
Endif

// add either filename or operation
cMessage += If( !Empty( e:filename ), ": " + e:filename, If( !Empty( e:operation ), ": " + e:operation, "" ) )
Return( cMessage )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ MyFRTA020³ Autor ³ Cesar Eduardo Valadao ³ Data ³16/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Thread "OnStart" de Conexao RPC com o Server               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MyFRTA020(cLocalEmp, cLocalFil, _cEstacao, nVendas, nConexoes, cResetRPC, nTmEndJob)

Local cRPCServer	:= ""
Local nRPCPort		:= 0
Local cRPCEnv		:= ""
Local cRPCEmp		:= ""
Local cRPCFilial	:= ""
Local nRPCInterv	:= 0
Local aAux			:= {}
Local aRet			:= {}
Local lRet			
Local nRet
Local cRet			:= ""
Local nTempo := 0                                                             
Local nHdl  
Local i
Local lReset		:= .F.	// Valida se farah o reset do RPC
Local lRec			:= .T.	// Controle de semaforo para envio dos dados para a Retaguarda
Local bMTrans		:= ""	// Boloco de codigo para a transacao
Local xRet					// Retorno sem tipo definido
Local nHandle       := 0    // Pega o Retorno da criação do conexao.frt
Local aAuxSer 		:= {}   // Array auxiliar para armazenar os servers 
Local aServers		:= {}   // Array que guarda os servers disponiveis
Local nFor			:= 0	// Contador do For
Local nX			:= 0	// Contador do FOR
Local lFwRpc    	:= .F.	//Indica se utiliza controle de serie automatica
Local oLJCLocker 	:= Nil 
Local lFechaConf	:= .F.	//Determina se o tratamento de conferencia de fechamento de caixa esta ativo
Local aSLW			:= {}	//Valores de gravacao para a SLW
Local aSLT			:= {}	//Valores de gravacao para a SLT
Local aTMP			:= {}	//Array temporario
Local cChave		:= ""	//Chave de pesquisa
Local nI			:= 0	//Contador
Local aID			:= {}	//Identificao completa de caixa  
Local lCenVenda		:= .F. 	// Indica se a integracao com o cenario de vendas esta ativa 
Local aMensagem	:= "" //armazena valor do LI_MSG
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCFolLocR5	:=	.F. 

DEFAULT nVendas		:= 0	// Quantidade de vendas antes do reset do RPC, vindo do mp8srv.ini (Param4)
DEFAULT nConexoes	:= 0	// Quantidade de conexoes antes do reset do RPC, vindo do mp8srv.ini (Param5)
DEFAULT nTmEndJob	:= 0 	// Tempo em minutos configurado para derrubar o job por inatividade

If nVendas > 0 .AND. nConexoes > 0                          
	lReset := .T.
Endif


Private cEstacao	:=""
Private aFiles		:= {}

nHdl := MSFCREATE("\SEMAFORO\F"+StrTran(cLocalEmp+cLocalFil+_cEstacao," ","")+".LCK")

If nHdl < 0                       
	Return( .F. )
EndIf

aCargaOK := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exemplo do AP6SRV.INI        ³
//³                              ³
//³ [OnStart]                    ³
//³ Jobs=APFrontLoja             ³
//³                              ³
//³ [APFrontLoja]                ³
//³ Main=FRTA020                 ³
//³ Environment=<cAmbiente>      ³
//³ nParms=<nNumerodeParametros> ³
//³ Parm1=<cEmpresa>             ³
//³ Parm2=<cFilial>              ³
//³ Parm3=<cEstacao>             ³
//³ Parm4=<cVendas>              ³
//³ Parm5=<cConexoes>            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ValType(cLocalEmp) == "U" .OR. ValType(cLocalFil) == "U" .OR. ValType(_cEstacao) == "U"
	lEndThread := .T.
EndIf   

If !lEndThread .AND. (Empty(Left(cLocalEmp,2)) .OR. Empty(cLocalFil) .OR. Empty(Left(_cEstacao,3)))
	lEndThread := .T.
EndIf

If lEndThread
	// "Front Loja: Erro na inicializacao do Ambiente Local "
	// "            Verifique a secao [OnStart] do AP6SRV.INI."
	ConOut(STR0001+GetEnvServer()+".")
	ConOut(STR0002)
	FClose(nHdl)
	Return(NIL)
EndIf

cLocalEmp := AllTrim(cLocalEmp)
cLocalFil := AllTrim(cLocalFil)
cEstacao  := AllTrim(_cEstacao)

// "Front Loja: Thread (FRTA020) iniciada...")
// "            Empresa - " ### "  Filial - " ### "  Estacao - " ###
ConOut(STR0003)
ConOut(STR0004 + cLocalEmp + STR0005 + cLocalFil + STR0006 + cEstacao)

RPCSetType(3)  // Nao comer licenca
PREPARE ENVIRONMENT EMPRESA cLocalEmp FILIAL cLocalFil TABLES "SLI","SL1","SLG","SFI","SLW","SLT" MODULO "FRT"

lCenVenda := SuperGetMv("MV_LJCNVDA",,.F.)

//Release 11.5 - Controle de Formularios ³
//Paises: Chile/Colombia  - F1CHI		  
lCFolLocR5:= SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc $ "CHI|COL" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o lock da carga ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLJCLocker 	:= If( ExistFunc("LOJA0051") .And. GetMV( "MV_LJILJLO",,"2" ) == "1", LJCGlobalLocker():New(), )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivos a Gerar Carga ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFiles := FRTArquivos()
lFwRpc := SuperGetMV("MV_LJFWRPC",,.T.)	//Indica se utiliza o novo metodo do RPC

If !lFwRpc                                      // Para esse metodo nao deve Abrir as tabelas
	RPCOpenTables({"SLI", "SL1", "SL2", "SL4", "SE5", "SA1", "SLW" ,"SLT"})
	RPCOpenTables(aFiles)
EndIf	

//Verifica se a conferencia de fechamento de caixa esta sendo utilizado e se o ambiente esta preparado
lFechaConf	:= SuperGetMV("MV_LJCONFF",.F.,.F.) .AND. IIf(ExistFunc("LjUpd70Ok"),LjUpd70Ok(),.F.)
ConOut("[MyFRTA020] MV_LJCONFF - " + cValToChar(lFechaConf))

dbSelectArea("SLG")
If SLG->(dbSeek(xFilial("SLG") + cEstacao))

	aAux		:= FrtDadoRpc()
	cRPCServer	:= aAux[1]
	nRPCPort	:= Val(aAux[2])
	cRPCEnv		:= aAux[3]
	cRPCEmp		:= aAux[4]
	cRPCFilial	:= aAux[5]
	nRPCInterv	:= If(aAux[6]==0, 5000, aAux[6]*1000)   
	If lFwRpc
	
		nFor := FrtServRpc()		// Carrega o numero de servidores disponiveis 
		
		For nX := 1 To nFor         
   	
			aAuxSer	:= FrtDadoRpc() //  Carrega os dados do server
		
			If ( !Empty(aAuxSer[1]) .AND. !Empty(aAuxSer[2]) .AND. !Empty(aAuxSer[3])) .AND.;
			   ( Alltrim(aAuxSer[1]) + Alltrim(aAuxSer[2]) 	  + Alltrim(aAuxSer[3]) )   <> 	;
			   ( Alltrim(cRPCServer) + Alltrim(Str(nRPCPort)) + Alltrim(cRPCEnv) )
			
				Aadd(aServers,{aAuxSer[1],Val(aAuxSer[2]),aAuxSer[3]})
			EndIf
		
			aAuxSer := {}
		Next nX   
    EndIf
	
	If Empty(cRPCServer) .OR. Empty(nRPCPort) .OR. Empty(cRPCEnv) .OR. Empty(cRPCEmp) .OR. Empty(cRPCFilial)
		// "Front Loja: Erro na configuracao dos parametros de comunicacao RPC."
		// "            Verifique os parametros na configuracao da Estacao " ###
		ConOut(STR0007)
		ConOut(STR0008+cEstacao+".")
		lEndThread := .T.
	EndIf
Else
	// "Front Loja: Erro na localizacao da Estacao."
	// "            Verifique na configuracao da Estacao se existe a Estacao "
	ConOut(STR0009)
	ConOut(STR0010+cEstacao+".")
	lEndThread := .T.
EndIf

If !lEndThread
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Ultima Atualizacao da Carga. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTGeraSLI("    ", "CRG", "", "ABANDONA")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Arquivo Com Carga Esta Zerado.           ³
	//³ Caso Tenha Ocorrido Algum Problema Com o Arquivo Basta ³
	//³ Exclui-lo Que o Mesmo Identifica e Corrige o Problema. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTChkBase()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Elimina Travamento Durante Queda de Rede na Carga. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTGeraSLI("    ", "LCK", "", "SOBREPOE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Elimina a Finalizacao do TwoTier na Inicializacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTGeraSLI("    ", "END", "", "SOBREPOE")

LjGrvLog("FRTA020","INICIO DO PROCESSO DO JOB FRTA020")

If !lEndThread
	While !KillApp() .AND. !lEndThread .AND. !File('STOPFRT.LCK')
		
		LjGrvLog("FRTA020","INICIO DO LOOP DO PROCESSO")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se configurado, permite reiniciar o Job quando 'nTmEndJob' minutos   ³
		//³ sem subir uma venda com sucesso, o objetivo eh reiniciar a conexao   ³
		//³ houve casos onde o Job trava e o fato de reiniciar volta a funcionar ³
		//³ IMPORTANTE: Deve-se definir RefreshRate do Job FRTA020 para funcionar³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FrtEndJob(nTmEndJob)              
			Conout("Front Loja: Job FRTA020 será finalizado e reiniciado no intervalo definido no RefreshRate")
			lEndThread := .T.
		EndIf

		If (If( ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILJLO",,"2" ) == "1", oLJCLocker:GetLock( "FRTA020ILLock" ), .T. ))			
			If ValType(oServer) != "O" .OR. (lFwRpc .AND. !lConnect)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tenta Criar Conexao RPC ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// "Front Loja: Estabelecendo conexao RPC com o Servidor ("
				ConOut(STR0011+cRPCServer+")...")
				Conout(STR0069+cRPCEnv+STR0070+cRPCEmp+STR0071+cRPCFilial)	// "            Ambiente: " ### " Empresa: " ### " Filial: "
	
				LjGrvLog( "FRTA020","CONECTANDO - ESTABELECENDO CONEXAO COM O SERVIDOR: ", cRPCServer + ":" + cValToChar(nRPCPort) )
				LjGrvLog( "FRTA020","CONECTANDO - NO AMBIENTE: ", cRPCEnv )
				LjGrvLog( "FRTA020","CONECTANDO - NA [EMPRESA] - [FILIAL]: ", "["+cRPCEmp+"] - ["+cRPCFilial+"]" )

				If lFwRpc                     	
					oServer:=FwRpc():New( cRPCServer, nRPCPort , cRPCEnv )	// Instancia o objeto de oServer	
					oServer:SetRetryConnect(1)								// Tentativas de Conexoes
					
					For nX := 1 To Len(aServers)                            // Metodo para adicionar os Servers 
						oServer:AddServer( aServers[nX][1], aServers[nX][2], aServers[nX][3] )			
					Next nX 
							
					lConnect := oServer:Connect()							// Tenta efetuar conexao
					
					If lConnect
						oServer:SetEnv(cRPCEmp,cRPCFilial,"LOJA")                 // Prepara o ambiente no servidor alvo
						cRPCServer 	:= oServer:aConnect[oServer:nConnect][1]
						nRPCPort	:= oServer:aConnect[oServer:nConnect][2]
					EndIf
				Else
					oServer := FrRpc020Con(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
				EndIf	
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ A Clausula MODULO, e Para Indicar Que o RPC do Front eh ³
				//³ Equivalente a Uma Licenca do SIGALOJA.                  ³
				//³ Deu Erro na Compilacao? Fale Com o Ramalho!!!           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(oServer) == "O" .AND. (lConnect .OR. !lFwRpc)
					// "Front Loja: Conexao estabelecida com o Servidor ("
					ConOut(STR0014+cRPCServer + ":" + Alltrim(Str(nRPCPort)) + ").")
				   	If oServer <> Nil  .AND. !lFwRpc
					   	bMTrans := {|| oServer:CallProc("RPCOpenTables", aFiles) }
						FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Informar ao Servidor Que a Estacao Esta Conectada, Criando um Semaforo. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If oServer <> Nil
					   	bMTrans := {|| oServer:CallProc("FRTSemaforo", "CON", cEstacao) }
						FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
						lRet := .T.
	                EndIf
	                LjGrvLog("FRTA020","CONECTADO - CONEXAO ESTABELECIDA ")
	                
					If ValType(lRet) == "L"
						While !KillApp() .AND. !lEndThread .AND. !lRet
							// "Front Loja: Verifique se nao existe uma outra estacao "
							// "            conectada ou aguarde a reconexao..."
							ConOut(STR0034+AllTrim(cEstacao))
							ConOut(STR0047)
							Sleep(20000)
							// Nao Foi Possivel Travar o Registro. Tentar Novamente Depois de 20 Segundos...
							
							If oServer <> Nil
							   	bMTrans := {|| oServer:CallProc("FRTSemaforo", "CON", cEstacao) }
								FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                        EndIf
	                        
	                        // Caso tenha conseguido criar o arquivo mostra a mensagem de Conexao
	       					// "Front Loja: Conexao estabelecida com o Servidor ("
							ConOut(STR0014+cRPCServer+").")						
						End
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ O FRTA020 Cria Um Semaforo Local Sinalizando que Esta Conectado a Retaguarda. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !FRTSemaforo("CON", cEstacao)
							// "Front Loja: Ja existe um Job FRTA020 sendo executado nesta estacao..."
							ConOut(STR0048)
						Else
						   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
						    //³Front Loja: usado para controle do Bitmap de conexao  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
							If !File("conexao.frt")   
							   	nHandle := FCREATE("conexao.frt")						   
							EndIf						
						EndIf
					EndIf
				Else
					// "Front Loja: Nao foi possivel estabelecer conexao com o Servidor ("
					ConOut(STR0015+cRPCServer+")." )
					// "            Aguardando 60 segundos para tentar estabelecer uma nova conexao..."
					ConOut(STR0072)
					LjGrvLog("FRTA020","SEM CONEXAO COM O SERVIDOR ")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
				    //³Front Loja: usado para controle do Bitmap de conexao  ³
			    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					     					    
			   		If File("conexao.frt") 		   		
				   		FERASE("conexao.frt")
				   	EndIf			   		
					// Esperar 60 segundos
					// Se der CTRL+BREAK, sai imediatamente
					nTempo := ( 60+Randomize(0,120) )
					For i := 1 to nTempo
						If KillApp()
							Exit
						EndIf
					Next                                   
					
					aAux		:= FrtDadoRpc() 
					cRPCServer	:= aAux[1]
					nRPCPort	:= Val(aAux[2])
					cRPCEnv		:= aAux[3]
					cRPCEmp		:= aAux[4]
					cRPCFilial	:= aAux[5]
					nRPCInterv	:= If(aAux[6]==0, 5000, aAux[6]*1000)
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Nao Travar no Encerramento do Job ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SLI")
					DbSeek(xFilial())
					If KillApp() .OR. (!EOF() .AND. Empty(LI_ESTACAO) .AND. Empty(LI_TIPO) .AND. Upper(Left(LI_MSG,9)) = "ENDTHREAD")
						FRTGeraSL("SLI", {{"LI_MSG", ""}})
						lEndThread := .T.
					EndIf
				EndIf
			Else
				LjGrvLog("FRTA020","CONECTADO - INICIO DAS OPERACOES,PRIMEIRO VAI SUBIR AS VENDAS")
			  	If !lFwRpc .AND. oServer:CallProc("FrtKillApp")
					Exit
				EndIf  
				// Envia as vendas primeiro de tudo
				FRTEnviar(@nVendas,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

				
				DbSelectArea("SLI")
				DbSeek(xFilial())
				While SLI->LI_FILIAL == xFilial("SLI") .AND. !SLI->(EOF()) .AND. !KillApp()
					LjGrvLog("FRTA020","SLI LOOP")
					If Empty(LI_ESTACAO) .AND. Empty(LI_TIPO) .AND. Upper(Left(LI_MSG,9)) = "ENDTHREAD"
						LjGrvLog("FRTA020","SLI ENDTHREAD")
						FRTGeraSL("SLI", {{"LI_MSG", ""}})
						lEndThread := .T.
						Exit
					ElseIf  Empty(LI_ESTACAO) .AND. LI_TIPO == "LCK" .AND. Left(LI_MSG,3) == "END"
						LjGrvLog("FRTA020","SLI END CARGA")					
						If FRTLockOK()											// Lock
							If Len(aCargaOK) > 0
								// Atualiza o Status de Recebendo Carga no FRTMonitor
								
								If oServer <> Nil
								   	bMTrans := {|| oServer:CallProc("FRTGeraSLI", cEstacao, "CRG", "RECEBENDO", "SOBREPOE") }
									FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
								EndIf
								FRTBaixa(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
								If oServer <> Nil
								   	bMTrans := {|| oServer:CallProc("FRTGeraSLI", cEstacao, "CRG", "", "SOBREPOE") }
									FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
								EndIf
								FRTGeraSLI("    ", "LCK", "", "SOBREPOE")
							EndIf
						EndIf
						nVendas--     
					ElseIf  Empty(LI_ESTACAO) .AND. LI_TIPO == "CAN" .AND. !Empty(LI_MSG)
						LjGrvLog("FRTA020","SOBE CANCELAMENTO SLI")
						If oServer <> Nil .AND. !lFwRpc
						   	bMTrans := {|| oServer:CallProc("RPCOpenTables", {"SE1", "SE5", "SEF", "SE3", "SD2", "SF2", "SB2", "SF4", "SF1", "SD1", "SLX"}) }
							FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
						EndIf
						
						If oServer <> Nil
							LjGrvLog("FRTA020","REALIZA O CANCELAMENTO DO CUPOM ",Subst(LI_MSG,1,TamSX3("L1_NUMORIG")[1]))					
							aMensagem := StrTokArr(AllTrim(LI_MSG),"|")	
							If 	Len(aMensagem) > 3		
							   	bMTrans := {|| oServer:CallProc("FRTExclusa", Subst(LI_MSG,1,TamSX3("L1_NUMORIG")[1]), aMensagem[4] ) }
								nRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
							Else
							   	bMTrans := {|| oServer:CallProc("FRTExclusa", Subst(LI_MSG,1,TamSX3("L1_NUMORIG")[1])) }
								nRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
							EndIf	
						EndIf
						If ValType(nRet)=="N" .AND. (nRet == 0 .OR. nRet == 2)	// Se Cancelou ou Nao Existe...remove registro da SLI
							RecLock("SLI",.F.)
							SLI->(DbDelete())
							SLI->(MsUnlock())	       																					
						Endif
						nVendas--
					ElseIf  Empty(LI_ESTACAO) .AND. LI_TIPO == "050" .AND. !Empty(Left(LI_MSG,17))
						LjGrvLog("FRTA020","SOBE SANGRIA ")					
						DbSelectArea("SE5")
						DbGoto(Val(Left(SLI->LI_MSG,17)))
						If E5_SITUA == "00"                 
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Monta o SE5 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							aSE5 := Array(FCount())
							For i := 1 To FCount()
								aSE5[i] := {FieldName(i), FieldGet(i)}
							Next
							
							If oServer <> Nil
							   	bMTrans := {|| oServer:CallProc("GeraE5", aSE5) }
								aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                        EndIf
							If ValType(aRet)=="A"
								cOK  := aRet[1]
								If Left(cOK,2)=="OK"
									
									If oServer <> Nil
									   	bMTrans := {|| oServer:CallProc("ConfE5", aRet[2]) }
										lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                                EndIf
									If ValType(lRet)=="L"
										aSE5 := {{"E5_SITUA","OK"}}						// "TX" - Foi Processado no Server
										FRTGeraSL("SE5", aSE5, .F.)
										FRTGeraSL("SLI", {{"LI_MSG", ""}})
										RecLock("SLI",.F.)
										SLI->(DbDelete())
										SLI->(MsUnlock())
									EndIf
								EndIf
							EndIf
						EndIf
						nVendas--
					ElseIf  Empty(LI_ESTACAO) .AND. LI_TIPO == "050" .AND. Empty(Left(LI_MSG,17))
						RecLock("SLI",.F.)
						SLI->(DbDelete())
						SLI->(MsUnlock())
					ElseIf !Empty(LI_ESTACAO) .AND. LI_TIPO == "OPE"
						LjGrvLog("FRTA020","SOBE INFORMACOES SOBRE ABRE/FECHA CAIXA ")
						If FRTSemaStat("OPE", cEstacao)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Informar ao Servidor Que o Caixa Esta Aberto. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If oServer <> Nil
							   	bMTrans := {|| oServer:CallProc("FRTGeraSLI", cEstacao, "OPE", LI_MSG, "SOBREPOE", .T., LI_USUARIO, LI_DATA, LI_HORA) }
								FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                        EndIf
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Informar ao Servidor Que o Caixa Esta Fechado. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If oServer <> Nil
							   	bMTrans := {|| oServer:CallProc("FRTGeraSLI", cEstacao, "OPE", LI_MSG, "SOBREPOE", .T., LI_USUARIO, CToD(""), "") }
								FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                        EndIf
						EndIf
					ElseIf !Empty(LI_ESTACAO) .AND. LI_TIPO == "CON"
						LjGrvLog("FRTA020","SOBE INFORMACOES SOBRE CONECTIVIDADE")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Informar ao Servidor o Status desta Estacao. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If oServer <> Nil
						   	bMTrans := {|| oServer:CallProc("FRTGeraSLI", cEstacao, "CON", LI_MSG, "SOBREPOE") }
							FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                    EndIf
					ElseIf !Empty(LI_ESTACAO) .AND. LI_TIPO == "COM" .AND. Left(SLI->LI_MSG,4)=="SEND"
						LjGrvLog("FRTA020","SOBREPOE INFORMACOES CONEXAO")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualizacao total no Check-Out ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						// Atualiza o Status de Recebendo Carga no FRTMonitor
						If oServer <> Nil
						   	bMTrans := {|| oServer:CallProc("FRTGeraSLI", cEstacao, "CRG", "RECEBENDO", "SOBREPOE") }
							FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                    EndIf
	                    // "Front Loja: Iniciando processo de atualizacao das tabelas no Check-Out..."
						ConOut(STR0042)
						FRTAtuCRG(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
						// "Front Loja: Processo de atualizacao das tabelas no Check-Out finalizado."
						ConOut(STR0043)
						If oServer <> Nil
						   	bMTrans := {|| oServer:CallProc("FRTGeraSLI", cEstacao, "CRG", "", "SOBREPOE") }
							FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                    EndIf
						nVendas--
					ElseIf !Empty(LI_ESTACAO) .AND. LI_TIPO == "PSS" .AND. Left(SLI->LI_MSG,8)=="CARREGAR"
						LjGrvLog("FRTA020","ATUALIZA PSS")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualizar o SIGAPSS.SPF ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FRTGrvSPF(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
						nVendas--
					ElseIf  Empty(LI_ESTACAO) .AND. LI_TIPO == "SA1" .AND. !Empty(Left(LI_MSG,17))
						LjGrvLog("FRTA020","SOBE CLIENTE SA1")
						DbSelectArea("SA1")
						DbGoto(Val(Left(SLI->LI_MSG,17)))
						If A1_SITUA == "00"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Monta o SA1 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							aSA1 := Array(FCount())
							For i := 1 To FCount()
								aSA1[i] := {FieldName(i), FieldGet(i)}
							Next
							If oServer <> Nil
							   	bMTrans := {|| oServer:CallProc("GeraA1", aSA1) }
								aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                        EndIf
							If ValType(aRet)=="A"
								cOK  := aRet[1]
								If Left(cOK,2)=="OK"
									If oServer <> Nil
									   	bMTrans := {|| oServer:CallProc("ConfA1", aRet[2]) }
										lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                                EndIf
									If ValType(lRet)=="L"
										cCod  := aSA1[AScan(aSA1,{|x|x[1]=="A1_COD"})][2]
										cLoja := aSA1[AScan(aSA1,{|x|x[1]=="A1_LOJA"})][2]
										// Se o Codigo gravado na Retaguarda foi diferente da base local, faz a correcao.
										If aRet[3] <> cCod
											SL1->(DbSetOrder(6))	//L1_FILIAL+L1_CLIENTE+L1_LOJA
											While SL1->(DbSeek(xFilial("SL1")+cCod+cLoja))
												FRTGeraSL("SL1", {{"L1_CLIENTE", aRet[3]}}, .F.)
											End
										EndIf
										aSA1 := {{"A1_SITUA","OK"}}						// "TX" - Foi Processado no Server
										FRTGeraSL("SA1", aSA1, .F.)
										FRTGeraSL("SLI", {{"LI_MSG", ""}})
										RecLock("SLI",.F.)
										SLI->(DbDelete())
										SLI->(MsUnlock())
									EndIf
								EndIf
							EndIf
						EndIf
						nVendas--										
					ElseIf !Empty(LI_ESTACAO) .AND. AllTrim(LI_TIPO) == "LOG" .AND. !Empty(Left(LI_MSG,17))
						LjGrvLog("FRTA020","SOBE LOG SLX")						
						DbSelectArea("SLX")
						DbGoto(Val(Left(SLI->LI_MSG,17)))
						If AllTrim(SLX->LX_SITUACA) == "00"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Monta o SLX ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							aSLX := Array(FCount())
							For i := 1 To FCount()
								aSLX[i] := {FieldName(i), FieldGet(i)}
							Next          
							If oServer <> Nil
							   	bMTrans := {|| oServer:CallProc("GeraSLX", aSLX) }
								aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                        EndIf
							If ValType(aRet)=="A"
								cOK  := aRet[1]
								If Left(cOK,2)=="OK"
									
									If oServer <> Nil
									   	bMTrans := {|| oServer:CallProc("ConfSLX", aRet[2], aSLX) }
										lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                                EndIf
									If ValType(lRet)=="L"
										FRTGeraSL("SLX", {{"LX_SITUACA", "OK"}})	// "OK" - Foi Processado Pelo Server
										RecLock("SLI",.F.)
										SLI->(DbDelete())
										SLI->(MsUnlock())
									EndIf
								EndIf
							EndIf
						EndIf
						nVendas--
					ElseIf !Empty(SLI->LI_ESTACAO) .AND. AllTrim(SLI->LI_TIPO) == "LOG" .AND. Empty(SLI->LI_MSG)
						RecLock("SLI",.F.)
						SLI->(DbDelete())
						SLI->(MsUnlock())
					ElseIf !Empty(LI_ESTACAO) .AND. AllTrim(LI_TIPO) == "SLX" .AND. !Empty(LI_MSG)
						LjGrvLog("FRTA020","ATUALIZA SLX")
						If oServer <> Nil
						   	bMTrans := {|| oServer:CallProc("FRT20InSLX", AllTrim(LI_MSG))}
							lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
							
							If lRet
								FRTGeraSL("SLI", {{"LI_MSG", ""}})
								RecLock("SLI",.F.)
								SLI->(DbDelete())
								SLI->(MsUnlock())
							EndIf                             	
	       				EndIf
	       				
						nVendas--				
					
					ElseIf lFechaConf .AND. !Empty(SLI->LI_ESTACAO) .AND. AllTrim(SLI->LI_TIPO) == "FCH" .AND. !Empty(SLI->LI_MSG) .AND. AliasInDic("SLW")
						LjGrvLog("FRTA020","FECHAMENTO DE CAIXA SLW")
						If ValType(oServer) == "O" .OR. (lFwRpc .AND. !lConnect)
							ConOut("[MYFRT020 - FCH] " + SLI->LI_MSG)
							cChave := RTrim(SLI->LI_MSG)
							dbSelectArea("SLW")
							SLW->(dbSetOrder(Val(Substr(cChave,2,2))))
							If SLW->(dbSeek(Substr(cChave,4,Len(cChave))))
								aID := {SLW->LW_OPERADO,SLW->LW_ESTACAO,SLW->LW_SERIE,SLW->LW_PDV}

								// tem que atualizar o status da SLW com 00 porque quando esta sem comunicacao com 
								// a retaguarda e a SLI tem os registros de ABR e FCH transfere o reg. ABR 
								// e marca a SLW com TX. Quando entra no reg. de FCH para transmitir, como o registro SLW
								// não esta mais 00 nao sobe para a retaguarda a SLT correspondente
								// (formas de pagamento do fechamento). Por isso a linha abaxo, e este caso soh
								// ocorre quando a retaguarda fica on-line e o fechamento do caixa estava off-line.
								FRTGeraSL("SLW",{{"LW_SITUA","00"}}, .F.)

								If SLW->LW_SITUA == "00"		//Caso o registro ainda nao tenha sido transmitido a retaguarda
									ConOut("[MYFRT020 - FCH] " + STR0095 + " " + SLW->LW_SITUA)
									//Carregar campos
									aSLW := {}
									aSLT := {}
									For nI := 1 to SLW->(FCount())
										aAdd(aSLW,{SLW->(FieldName(nI)),SLW->(FieldGet(nI))})
									Next nI
									aAdd(aSLW,{"REC",SLW->(Recno())})
									//Se determinado para gravar SLW + SLT e o tipo de fechamento for o completo
									If Substr(cChave,1,1) == "2" .AND. AllTrim(SLW->LW_TIPFECH) $ "1|2" .AND. AliasInDic("SLT")
										ConOut("[MYFRT020 - FCH] " + STR0096)
										//Subir as conferencias associadas ao fechamento de caixa
										
										dbSelectArea("SLT")
										SLT->(dbSetOrder(1))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG
										If SLT->(dbSeek(xFilial("SLT") + SLW->LW_OPERADO + DtoS(SLW->LW_DTFECHA)))
											Do While !SLT->(Eof()) .AND. (SLT->LT_FILIAL + SLT->LT_OPERADO + DTOS(SLT->LT_DTFECHA)) == ;
												(xFilial("SLT") + SLW->LW_OPERADO + DtoS(SLW->LW_DTFECHA))
												
												//Se o movimento for diferente, saltar
												If AllTrim(SLT->LT_NUMMOV) # AllTrim(SLW->LW_NUMMOV)
													SLT->(dbSkip())
													Loop
												Endif
												If SLT->LT_SITUA == "00"
													aTMP := Array(SLT->(FCount()))
	
													For nI := 1 to Len(aTMP)
														aTMP[nI] := {SLT->(FieldName(nI)),SLT->(FieldGet(nI))}
													Next nI
													aAdd(aTMP,{"REC",SLT->(Recno())})
													aAdd(aSLT,aTMP)
												Endif
												SLT->(dbSkip())
											EndDo
										Endif
									Endif
									ConOut("[MYFRT020 - FCH] " + STR0097)	//"Executando no server FRT020FCH"
									bMTrans := {|| oServer:CallProc("FRT020FCH",aSLW,aSLT)}
									lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
									If lRet
										ConOut("[MYFRT020 - FCH] " + STR0098)	//"Gravacao na retaguarda OK"
										Begin Transaction
										ConOut("[MYFRT020 - FCH] " + STR0099)	//"Atualizar o status de envio da SLW"
										SLT->(dbGoto(aSLW[Len(aSLW)][2]))
										FRTGeraSL("SLW",{{"LW_SITUA","TX"}}, .F.)
										ConOut("[MYFRT020 - FCH] " + STR0100)	//"Atualizar o status de envio dos registros da SLT"
										If Len(aSLT) > 0
											For nI := 1 to Len(aSLT)
												SLT->(dbGoto(aTail(aSLT[nI])[2]))
												FRTGeraSL("SLT", {{"LT_SITUA","TX"}})
											Next nI
										Endif										
										//Atualizar a SLI, verificar se existe outro movimento de abertura a ser declarado na retaguarda, 
										//caso exista gravar na SLI para novo processamento
										FR271BGerSLI(AllTrim(SLW->LW_OPERADO),"FCH",LjLWPendSu("FCH",aID),"SOBREPOE",.T.,AllTrim(UsrRetName(__cUserID)),Date(),Time())
			   							End Transaction							
									Else
										ConOut("[MYFRT020 - FCH] " + STR0101)
									Endif
								Else
									ConOut("[MYFRT020 - FCH] " + STR0102)
									FR271BGerSLI(AllTrim(SLW->LW_OPERADO),"FCH",LjLWPendSu("FCH",aID),"SOBREPOE",.T.,AllTrim(UsrRetName(__cUserID)),Date(),Time())
								Endif
							Endif
						Else
							ConOut("[MYFRT020 - FCH] " + STR0103)
						Endif
						nVendas--

					ElseIf lFechaConf .AND. !Empty(SLI->LI_ESTACAO) .AND. AllTrim(SLI->LI_TIPO) == "ABR" .AND. !Empty(SLI->LI_MSG) .AND. AliasInDic("SLW")
						LjGrvLog("FRTA020","ABRIR DE CAIXA SLW")
						If ValType(oServer) == "O" .OR. (lFwRpc .AND. !lConnect)
							ConOut("[MYFRT020 - ABR] " + SLI->LI_MSG)
							cChave := RTrim(SLI->LI_MSG)
							dbSelectArea("SLW")
							SLW->(dbSetOrder(Val(Substr(cChave,1,2))))
							If SLW->(dbSeek(Substr(cChave,3,Len(cChave))))
								aID := {SLW->LW_OPERADO,SLW->LW_ESTACAO,SLW->LW_SERIE,SLW->LW_PDV}
								If SLW->LW_SITUA == "00"		//Caso o registro ainda nao tenha sido transmitido a retaguarda
									ConOut("[MYFRT020 - ABR] " + STR0104 + " " + SLW->LW_SITUA)
									//Carregar campos
									aSLW := {}
									For nI := 1 to SLW->(FCount())
										aAdd(aSLW,{SLW->(FieldName(nI)),SLW->(FieldGet(nI))})
									Next nI
									aAdd(aSLW,{"REC",SLW->(Recno())})
									ConOut("[MYFRT020 - ABR] " + STR0105)	//"Executando no server a rotina FRT020ABR"
									bMTrans := {|| oServer:CallProc("FRT020ABR",aSLW)}
									lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
									If lRet
										ConOut("[MYFRT020 - ABR] " + STR0098)
										Begin Transaction
										//Atualizar o status de envio da SLW
										SLT->(dbGoto(aTail(aSLW)[2]))
										FRTGeraSL("SLW",{{"LW_SITUA","TX"}}, .F.)
										//Atualizar a SLI, verificar se existe outro movimento de abertura a ser declarado na retaguarda, 
										//caso exista gravar na SLI para novo processamento
										FR271BGerSLI(AllTrim(SLW->LW_OPERADO),"ABR",LjLWPendSu("ABR",aID),"SOBREPOE",.T.,AllTrim(UsrRetName(__cUserID)),Date(),Time())
			   							End Transaction							
			   						Else
			   							ConOut("[MYFRT020 - ABR] " + STR0101)
									Endif
								Else
									ConOut("[MYFRT020 - ABR] " + STR0106)	//"O registro jah foi enviado a retaguarda, excluir registro"
									FR271BGerSLI(AllTrim(SLW->LW_OPERADO),"ABR",LjLWPendSu("ABR",aID),"SOBREPOE",.T.,AllTrim(UsrRetName(__cUserID)),Date(),Time())																			
								Endif
							Endif
						Else
							ConOut("[MYFRT020 - ABR] " + STR0103)
						Endif
						nVendas--
					
					//Release 11.5 - Controle de Formularios 
					//Carga da tabela 01 do SX5 
					//Paises:Chile/Colombia - F1CHI
					ElseIf lCFolLocR5 .AND. !Empty(LI_ESTACAO) .AND. AllTrim(LI_TIPO) == "01" .AND. Left(SLI->LI_MSG,8)=="CARREGAR"
						FRTGrvSx5(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial,"01")
						nVendas--
					/* Envia o cancelamento de venda TEF do PDV PAF para a Retaguarda */
					ElseIf Empty(AllTrim(LI_ESTACAO)) .And. AllTrim(LI_TIPO) == "TEF" .And. !Empty(AllTrim(LI_MSG))
						LjGrvLog("FRTA020","SOBE CANCELAMENTO TEF SLI")
						If oServer <> Nil
							aMensagem	:= StrTokArr(AllTrim(LI_MSG),"|")	
							bMTrans 	:= {|| oServer:CallProc("FrtTEFCanc",aMensagem) }
							nRet		:= FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
						EndIf

						If ValType(nRet) == "N" .AND. (nRet == 1)	//Se registrou o cancelamento do TEF...remove registro da SLI
							RecLock("SLI",.F.)
							SLI->(DbDelete())
							SLI->(MsUnlock())	       																					
						EndIf
						
						nVendas--
					EndIf
					
					dbSelectArea("SLI")
					SLI->(dbSkip())
	                
					If lReset
						If nVendas <= 0
						    PutGlbValue(cResetRPC,"S")
							Exit
						EndIf
					Endif	
				EndDo

				LjGrvLog("FRTA020","GRAVA A TABELA SFI NA RETAGUARDA")
				FRTGravaFI(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

				LjGrvLog("FRTA020","RESET DA VARIAVEL GLOBAL")
				If lReset
					If nVendas <= 0 .OR. KillApp() .OR. lEndThread                           
						PutGlbValue(cResetRPC,"S")
						Exit
					EndIf
				Endif
				
				LjGrvLog("FRTA020","VERIFICA SE TEM CARGA PARA RECEBER")
				FRTRecebe(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
				LjGrvLog("FRTA020","GRAVA OUSTRAS TABELAS SZ NA RETAGUARDA")
				FRTGravaSZ(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para efetuar a gravacao da tabela de ³
				//³monitoramento dos PDVs  "MDI"               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FRTPegaOrc(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	            LjGrvLog("FRTA020","ANTES DA CHAMADA DE SUBIDA DE NCC")
   				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificacao de Titulo via Rpc para utilizaçao com Cenario ³
				//³      de Vendas Ativo e funcionalidade de Desconto        ³
				//³               Atribuido na Proxima Venda.                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				FRTCheckNcc(oServer,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial) // Verifica se existe algum Titulo para Incluir na Retaguarda.
				LjGrvLog("FRTA020","ANTES DA SUBIDA DA MBZ ( ESTORNO DE VENDAS ) ")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para enviar para retaguarda os Dados ³
				//³de Orcamentos estornados                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AliasInDic("MBZ") //Implementado FNC de Estorno de Vendas
					FRTGravMBZ(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
				EndIf
				LjGrvLog("FRTA020","FINAL DO LOOP VAI DAR UM SLEEP E INICIAR O PROCESSO NOVAMENTE")
	        	If lReset
					If nVendas <= 0 .OR. KillApp() .OR. lEndThread                           
						PutGlbValue(cResetRPC,"S")
						Exit
					EndIf
				Endif	
				
				nConexoes--
				
				If lReset
					If nConexoes <= 0 .OR. KillApp() .OR. lEndThread                           
						PutGlbValue(cResetRPC,"S")
					   Exit
					EndIf					
				Endif	
			EndIf
			If( ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILJLO",,"2" ) == "1", oLJCLocker:ReleaseLock( "FRTA020ILLock" ),)
		EndIF	
		
		LjGrvLog("FRTA020","SLEEP PARA REINICIO DO PROCESSO")
		Sleep(nRPCInterv)
	End
EndIf        
If lAltThread .AND. lFwRpc				// Marca que a Thread foi finalizada
	lEndThread := .F.
	lAltThread := .F.
EndIf

LjGrvLog("FRTA020","FINALIZANDO O JOB FRTA020")
// Informando ao Remote que o Job Ja Terminou.
FRTGeraSLI(Space(4), Space(3), "OK", "SOBREPOE")
If ValType(oServer) == "O" .AND. ( lConnect .OR. !lFwRpc)
	// "Front Loja: Finalizando conexao com o Servidor ("
	ConOut(STR0017+cRPCServer+")...")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha Conexao RPC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lFwRpc
		RESET ENVIRONMENT IN SERVER oServer
		CLOSE RPCCONN oServer
    Else
		oServer:Disconnect()
		lConnect := .F. 
	EndIf	
EndIf
LjGrvLog("FRTA020","FINALIZANDO THREAD")
// "Front Loja: Finalizando Thread (FRTA020)..."
ConOut(STR0016)
RESET ENVIRONMENT
MS_QUIT()
FClose(nHdl)
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³FRTEnviar ³ Autor ³ Cesar Eduardo Valadao ³ Data ³16/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Enviar "pacote" de orcamento ao Server de Retaguarda		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Progr.   ³ Data     BOPS   Descricao								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos R. ³12/12/05³088093³- Altera a serie e o status da tabela SLG e ³±±
±±³          ³        ³      ³  SL6 da retaguarda.                        ³±±
±±³Marcos R. ³04/01/06³091100³- Alteracao na gravacao do status da tabela ³±±
±±³          ³        ³      ³  SL6 da retaguarda.                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTEnviar(nVendas,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
Local 	lLocalizado	:=.F.
Local 	aSL1		:= {} 
Local 	aSL2 		:= {}
Local 	aSL4 		:= {}
Local 	aAux		:= {}
Local 	aSE5		:= {}
Local 	cConf 		:= ""
Local 	cCOO 		:= ""
Local 	i                         
Local 	lMvLjSrAut	:= SuperGetMV("MV_LJSRAUT",,.F.)	//Indica se utiliza controle de serie automatica
Local 	bMTrans 	:= ""
Local 	cNum 		:= ""				
Local 	lFwRpc    	:= SuperGetMV("MV_LJFWRPC",,.T.)	//Indica se utiliza o novo metodo do RPC
Local 	cLiMsg		:= ""								//Menssagem para sinalizar Cancelamento da Venda
Local   lVendaER	:= .F. // Processa registro "ER"
Local   nRecER      := 0   // Recno do registo que teve situação alterada de "ER" para "00"                                                   
Local   lAchou      := .F. // Se encontrou resgistros nas pesquesas para processar
Local	cFilTbls	:= ""
Local 	nProtec 	:= 1
Local 	lEmitNfce	:= ExistFunc("LjEmitNFCe") .AND. LjEmitNFCe() // Sinaliza se utiliza NFC-e
Local	cAux		:= ""
Local	lL1_DOCCCF	:= SL1->(ColumnPos("L1_DOCCCF")) > 0	//Contem o DOC de cancelamento

Private x
DEFAULT nVendas    	:= 0 
Default cRPCServer	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
DEfault cRPCEmp		:= ""
Default cRPCFilial	:= ""


// Testar comunicação antes de montar orçamentos
bMTrans := {|| oServer:CallProc("FRTTestCom") }
cNum    := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

If cNum <> "OK"
	Conout(" FRTEnviar - Falha na comunicação com a retaguarda !")
	Return(NIL) 
Else	
 	cNum := ""				
EndIf 	

//Considera registros Deletados para subir cancelamentos
SET DELETED OFF

DbSelectArea("SL1")
SL1->( DbSetOrder(9) )	//L1_FILIAL + L1_SITUA + L1_PDV + L1_DOC
SL1->( DbGoTop() )
lVendaER := .F.
nRecER 	 := 0

// Busca por Registros tipo "ER" e "EP"
If SL1->(DbSeek(xFilial("SL1")+"ER")) .AND. !SL1->(Deleted())
	lVendaER := .T.
	nRecER 	 := SL1->(Recno()) 
	Conout(" **** FRTEnviar - Reg. tipo 'ER' será reprocessado, Recno = " + Alltrim(Str(nRecER)))
	Sleep(10000)
ElseIf SL1->(DbSeek(xFilial("SL1")+"EP"))
	lVendaER := .T.
	nRecER 	 := SL1->(Recno()) 
	Sleep(10000)
EndIf

// se encontrou , altera Reg para situação de "ER" para "00"
If lVendaER .AND. nRecER > 0 .AND. !SL1->(Deleted())

	SL1->(dbGoto(nRecER))

	If RecLock( "SL1", .F. )
		SL1->L1_SITUA := "00"
		SL1->(MsUnLock())
	Else	                  // se não conseguir travar, ignora e passa para o proximo, tenta mais tarde
		lVendaER := .F.
		nRecER 	 := 0
	EndIf
EndIF


lAchou := .F.
If	lVendaER .AND. nRecER > 0  // se encontrou, altera REg  situação "ER" para "00"
	SL1->(dbGoto(nRecER))      // Não é redundancia, é precaução contra desposicionamento de Base DBF
	lAchou := .T.
Else
	IF SL1->(DbSeek(xFilial("SL1")+"00"))
		lAchou := .T.
	EndIf
EndIf
  
If !lAchou 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Conforme orientacao do DBA Emerson Tobar, existem casos³
	//³que apos o DbSelectArea, DbSetOrder e DbSeek, o arquivo³
	//³DBF fica em EOF(). Desta forma, forcamos o DbGoTop().  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SL1->(DbSkip(-1))
	SL1->(DbGoTop())
	LjGrvLog("","FRTA020 - Nenhuma venda encontrada")
EndIf

  
While lAchou .AND. nProtec < 50
	nProtec++
    nVendas--    
	If SL1->(EOF()) .OR. SL1->L1_FILIAL <> xFilial("SL1")
		//Desconsidera registros Deletados para subir cancelamentos
		SET DELETED ON
		Return NIL
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o SL1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSL1 := Array(FCount())
	For i := 1 To FCount()
		aSL1[i] := {FieldName(i), FieldGet(i)}
	Next
	If L1_OPERACA != "C"
		aSL1[AScan(aSL1,{|x|x[1]=="L1_NUMORIG"})][2] := L1_NUM
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o SL2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL2")
	cFilTbls := xFilial()
	SL2->(DbSetOrder(1))	//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	SL2->(DbSeek(cFilTbls+SL1->L1_NUM))
	aSL2 := {Array(SL2->(FCount()))}
	For i := 1 To SL2->(FCount())
		aSL2[1][i] := SL2->(FieldName(i))
	Next
	
	While L2_FILIAL+L2_NUM == cFilTbls+SL1->L1_NUM .AND. !SL2->(EOF())
		If L2_VENDIDO == "S" .AND. L2_SITUA <> "05"  //  ignora Registros cancelados no orçamento
			AAdd(aSL2, Array(SL2->(FCount())))
			For i := 1 To SL2->(FCount())
				aSL2[Len(aSL2)][i] := SL2->(FieldGet(i))
			Next
		EndIf
		SL2->(DbSkip())
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o SL4 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SL4")
	cFilTbls := xFilial()
	SL4->(DbSetOrder(1))	//L4_FILIAL+L4_NUM+L4_ORIGEM
	SL4->(DbSeek(cFilTbls+SL1->L1_NUM))
	aSL4 := {Array(SL4->(FCount()))}
	For i := 1 To SL4->(FCount())
		aSL4[1][i] := SL4->(FieldName(i))
	Next

	While SL4->L4_FILIAL+SL4->L4_NUM == cFilTbls+SL1->L1_NUM .AND. !SL4->(EOF())
		//Deve enviar mesmo o deletado quando o PAFMD5 estiver preenchido
		If !SL4->( Deleted() ) .OR. ;
		( SL4->(Deleted()) .And. !Empty(AllTrim(SL4->L4_PAFMD5))) .OR. ;
		( SL4->(Deleted()) .AND. SL1->L1_TPORC == "E" .AND. !Empty(SL1->L1_KEYNFCE) .AND. Empty(SL1->L1_SERSAT) .AND. SL1->L1_SITUA == "07") .OR.;
		( SL4->(Deleted()) .AND. SL1->L1_STORC == "C" .AND.  SL1->L1_SITUA == "00" ) 

			AAdd(aSL4, Array(SL4->(FCount())))
			For i := 1 To SL4->(FCount())				
				aSL4[Len(aSL4)][i] := SL4->(FieldGet(i))		
			Next
		EndIf
		SL4->( DbSkip() )
	End

	If ExistBlock("FRTEnviar")
		aRet := { aSL1, aSL2, aSL4 }
		aRet := ExecBlock("FRTEnviar",.F.,.F.,aRet)
		aSL1 := aRet[1]
		aSL2 := aRet[2]
		aSL4 := aRet[3]
	Endif
    
	// "Front Loja: Gravando o Orcamento "
	ConOut( STR0020 + SL1->L1_NUM + "..." )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Foi adicionado este RecLock devido a um problema encontrado 			³
	//³ no cancelamento do cupom.												³
	//³ Quando esta sendo incluido uma venda, e assim que o pacote foi enviado,	³
	//³ nao tiver dado tempo para a gravacao na retaguarda, o cancelamento		³
	//³ nao e feito na retaguarda, causando problemas de sincronizacao de base.	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SL1" )

	If RecLock( "SL1", .F. )

		If oServer <> Nil .AND. ( lConnect .OR. !lFwRpc)
		   	bMTrans := {|| oServer:CallProc( "GeraL1L2L4", aSL1, aSL2, aSL4, cEstacao ) }
			cNum := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
        EndIf
		LjGrvLog(SL1->L1_NUM,"Retorno da GERALL1L2",cNum)
		If ValType( cNum ) == "C"   
			If Left( cNum, 2 ) == "OK"
				
				//Atualiza hora que subiu venda com sucesso, para controle do Timer que reinicia o Job FRTA020 por inatividade de subida de venda com sucesso
				cHrUpVenda	:= Time() 
				
				cConf := Substr( cNum, 4, 6 )

				If !Empty( cConf )
					If oServer <> Nil
					   	bMTrans := {|| oServer:CallProc( "ConfL1L2L4", Substr( cNum, 4, 6 ), cEstacao ) }
						cNum := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
                    EndIf
					
					LjGrvLog(SL1->L1_NUM,"Retorno cNUM CONFIRMA L1L2",cNum)
					LjGrvLog(SL1->L1_NUM,"Retorno cConf CONFIRMA L1L2",cConf)
					If ValType( cNum )=="C"
						If cConf <> cNum
							// "Front Loja: Erro ao confirmar a gravacao do Orcamento "
							ConOut( STR0053 + SL1->L1_NUM + "." )
						Else           

							//Verifica se houve o cancelamento da Venda antes de subir para a Retaguarda 
							If SL1->L1_STORC == "C"
								cAux := "07" // "07" - Mantem L1_SITUA padrao para Venda Cancelada
								If lL1_DOCCCF
									cLiMsg	:= cNum+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV+"|"+SL1->L1_DOCCCF 	// Monta mensagem para cancelamento na Retaguarda via SLI
								Else
								  cLiMsg  := cNum+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV 	// Monta mensagem para cancelamento na Retaguarda via SLI
								EndIf
								
							Else 
								LjGrvLog(SL1->L1_NUM,"GRAVA COMO TX")
								cAux := "TX" // "TX" - Foi Enviado ao Server 								
							EndIf

							aSL1 := { { "L1_NUMORIG", cNum }, ;
										{ "L1_SITUA", cAux } }
						
							aEval( aSL1, { |x| FieldPut( ColumnPos( x[1] ), x[2] ) } )

							// "Front Loja: Orcamento " ### " gravado com sucesso."
							ConOut( STR0021 + SL1->L1_NUM + STR0022 )
						EndIf
					EndIf
				EndIf
			Else 
				If Left( cNum, 2 ) == "BX"
					aSL1 := { { "L1_SITUA", "DU" } } // "DU" - Orcamento duplicado na Retaguarda
					aEval( aSL1, { |x| FieldPut( ColumnPos( x[1] ), x[2] ) } )

					// "Front Loja: O Orcamento " ### " ja foi gravado na Retaguarda."
					// "            Verifique o L1_SITUA='DU' na estacao."
					ConOut( STR0054 + SL1->L1_NUM + STR0055 )
					ConOut( STR0056 )
				EndIf
			EndIf
		Else
			// "Front Loja: Nao foi possivel gravar o Orcamento " ### " na Retaguarda."
			ConOut( STR0057 + SL1->L1_NUM + STR0058 )

			If lVendaER  // o Registro era situação "ER"
				aSL1 := { { "L1_SITUA", "RE" } } // "RE" - Orcamento Reprocessado Sem Sucesso
				Conout( " **** Essa venda sera gravada como 'RE'" )	
            Else
				aSL1 := { { "L1_SITUA", "ER" } } // "ER" - Orcamento duplicado na Retaguarda
				Conout(STR0082)	//"Essa venda sera gravada como 'ER'"
			EndIf
			
			aEval( aSL1, { |x| FieldPut( ColumnPos( x[1] ), x[2] ) } )

		EndIf
		
		DbCommit()
		MsUnLock()
			
		//Verifica se subindo venda cancelada e gera SLI
		If !Empty(cLiMsg)             
		   	FR271BGerSLI("    ", "CAN", cLiMsg, "NOVO")	
		EndIf
				
	Else
		// "Front Loja: Erro ao confirmar a gravacao do Orcamento "
		ConOut( STR0053 + SL1->L1_NUM + "." )
	EndIf
	
	// Verifica se existe mais alguma venda para enviar
	DbSelectArea("SL1")
	SL1->( DbSetOrder(9))	//L1_FILIAL + L1_SITUA + L1_PDV + L1_DOC
	If SL1->(DbSeek(xFilial("SL1")+"00"))
		lAchou := .T.
	Else
		lAchou := .F.
	EndIf
EndDo	

If !lEmitNfce
	cCOO := LjGetStation("COO")
	If !Empty(cCOO)
		If oServer <> Nil
		   	bMTrans := {|| oServer:CallProc("FRTGrvCOO", cEstacao, cCOO) }
			FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	    EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se utiliza controle automatico de serie onde quando       ³
//³o numero do ECF Zerar o sistema incrementa a serie automaticamente.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMvLjSrAut
	If Select("SL6") > 0
		DbSelectArea("SLG")
		SLG->(DbSetOrder(1))	//LG_FILIAL+LG_CODIGO
		If SLG->(MsSeek(xFilial()+cEstacao))
			If oServer <> Nil
			   	bMTrans := {|| oServer:CallProc("FRTGrvSR", cEstacao, SLG->LG_SERIE) }
				FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
			EndIf
		EndIf
		
	EndIf
	
EndIf

//Desconsidera registros Deletados para subir cancelamentos
SET DELETED ON

DbSelectArea("SLI")
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FRTGrvCOO ³ Autor ³ Cesar Eduardo Valadao ³ Data ³10/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravar o LG_COO no Servidor.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTGrvCOO(cEstacao, cNewCOO)
If !Empty(cNewCOO)
	If SLG->(DbSeek(xFilial("SLG")+cEstacao))
		If cNewCOO > SLG->LG_COO
			FRTGeraSL("SLG", {{"LG_COO", cNewCOO}})
		EndIf
	EndIf
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³FRTGrvSR  ³ Autor ³ Marcos Roberto Andrade³ Data ³09/12/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravar o LG_SERIE no Servidor.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTGrvSR(cExp1, cExp2 )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³cExp1 - Codigo da Estacao                                   ³±±
±±º          ³cExp2 - Nova serie que sera atualizada no cadastro da       ³±±
±±º          ³        estacao da retaguarda.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTGrvSR(cEstacao, cNewSr)

Local 	cStatus   	:="2"  		//Status do SL6(Tabela de Serie reservada para o caixa) 1)Pode utilizar 2) ja utilizado

If Select("SL6") > 0
	If !Empty(cNewSr)
		If SLG->(MsSeek(xFilial("SLG")+cEstacao))
			If cNewSr <> SLG->LG_SERIE  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando e` feito a troca de serie no cadastro de estacao, e`               ³
				//³preciso inativar a serie no tabela de reserva de serie, ou seja status ==2³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SL6->( MsSeek( xFilial("SL6")+SLG->LG_SERIE+cEstacao) )
					FRTGeraSL("SL6", {{"L6_STATUS", cStatus}})
				EndIf
			
				FRTGeraSL("SLG", {{"LG_SERIE", cNewSr}})
			EndIf
		EndIf
	EndIf           
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³FRTRecebe ³ Autor ³ Cesar Eduardo Valadao ³ Data ³19/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Receber "pacote" de base atualizada ("CARGA")              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTRecebe(	cRPCServer,	nRPCPort,	cRPCEnv,	cRPCEmp,;
							cRPCFilial)
Local i
Local aAux
Local bMTrans	:= ""
Local lRet		:= .T.
Local lContinua := .T. 

Default cRPCServer	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""

If ValType(aCargaOK) == "U"
   lContinua := .F.
Endif

//³ Se Ja Verificou a Carga, Esperar Baixar. ³
If lContinua .And. Len(aCargaOK) != 0
	lContinua := .F.
EndIf

If lContinua
	SLI->(DbSeek(xFilial()+"    CRG"))
	If oServer <> Nil
		bMTrans := {|| oServer:CallProc("FRTChkCarga", Val(cEstacao), SLI->LI_MSG) }
		aCargaOK := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	EndIf
	
	If ValType(aCargaOK)=="A" .AND. Len(aCargaOK) > 0
		// "Front Loja: Aguardando finalizacao da venda para atualizar a base..."
		ConOut(STR0023)
		FRTGeraSLI("    ", "LCK", "END", "ABANDONA")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar se existe SLIs para serem baixados pelo Check-Out. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oServer <> Nil
		bMTrans := {|| oServer:CallProc("FRTChkSLI", cEstacao) }
		aAux := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	EndIf
	
	If ValType(aAux)=="A" .AND. Len(aAux) > 0
		For i := 1 To Len(aAux)
			FRTGeraSLI(cEstacao, aAux[i][1], aAux[i][2], "SOBREPOE", .T., aAux[i][3], aAux[i][4], aAux[i][5])
		Next
	EndIf
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³ FRTBaixa ³ Autor ³ Cesar Eduardo Valadao ³ Data ³19/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza a base recebida.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTBaixa(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
Local i, z, j, cArquivo, aCarga, aCampos, aAlterados, cChave, cPSSSX5:=""
Local aAux, nContinue, nRetry, cCarga, nAt, cCargaAtual, nRet
Local lApend 	  := .F.		// Situacao para RecLock  		
Local lLock  	  := .F.		// Verifica se conseguiu alocar a tabela
Local nTentativas := 0			// Tentativas para alocar o registro
Local bMTrans := ""

//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI		  ³
Local lCFolLocR5:= SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL"
Local c01SX5	:= ""				//Acao para tabela 01 do SX5
Local nOrdem	:= 0
Local nQtd		:= 0
	
Default cRPCServer	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""

For i := 1 To Len(aCargaOK)
	nRetry      := 0
	nContinue   :=-1
	cArquivo    := aCargaOK[i][1]
	// "Front Loja: Iniciando Carga " ### " do arquivo " ### "..."
	ConOut(STR0039+aCargaOK[i][2]+STR0059+cArquivo+"...")
	While nContinue != 0
	    ConOut("1. FRTA020 - Chama FRTTXCarga " + cEstacao + " " + aCargaOK[i][2] + " " + aCargaOK[i][1] + " " + ;
	           Str(nContinue))
		If oServer <> Nil
			bMTrans := {|| oServer:CallProc("FRTTXCarga", Val(cEstacao), aCargaOK[i][2], aCargaOK[i][1], If(nContinue==-1,0,nContinue)) }
			aAux := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
        EndIf
		If ValType(aAux) == "A"
			nRetry      := 0		// como esta conseguindo , reinicia o processo de carga
			aCarga      := aAux[1][1]
			aCampos     := aCarga[2]
			aAlterados  := aCarga[3]
			nContinue   := aAux[2]
			cCargaAtual := aAux[3]
			If Len(aAux) == 4
				cPSSSX5 := aAux[4]
			EndIf

		    If Len(aAux) == 5 
		    	PutMV("MV_TABPAD",aAux[5])
    	    	//"Atualizado parâmetro de Tabela de Precços: "
    	    	ConOut (STR0083 + aAux[5])
		    EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Controle de Formularios ³ 
			//³Carga da tabela 01 do SX5              ³
			//³Paises:Chile/Colombia  - F1CHI		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		    If lCFolLocR5 .AND. Len(aAux) >= 6  .AND. !ValType(aAux[6]) == "U"
		    	If aAux[6] == "01"
		    		c01SX5 := aAux[4]
	    	    	ConOut (STR0115) //"Atualizando Tabela de Séries de Notas Fiscais"
	    	  	EndIf
		    EndIf
		    nOrdem := 1
		 	If cArquivo == "SF7" 
				nQtd:=0
				SIX->(dbSetOrder(1))	//INDICE+ORDEM
				SIX->(dbSeek('SF7'))
				While SIX->(!Eof()) .And. SIX->INDICE == 'SF7' 
					nQtd++
					SIX->(dbSkip())
				EndDo					  
				
				If nQtd >= 3	    
					nOrdem := 3
				Else 
					nOrdem := 1
				Endif	
			EndIf	
			DbSelectArea(cArquivo)
			If cArquivo == "CLK" .AND. !Empty(IndexKey(3))
				nOrdem = 3 //CLK_FILIAL+CLK_CODNCM+CLK_EX+CLK_CODNBS+CLK_UF+DTOS(CLK_DTINIV)+DTOS(CLK_DTFIMV)
			EndIf			
			DbSetOrder(nOrdem) //Indice 3 F7_FILIAL+F7_GRTRIB+F7_SEQUEN //Indice 1 F7_FILIAL+F7_GRTRIB++F7_GRPCLI+F7_SEQUEN
			
			For j := 1 To Len(aAlterados)
				cChave := aAlterados[j][2]
				If DbSeek(cChave)
					lApend := .F.
				Else
					lApend := .T.
				EndIf
				
				lLock 		:= .F.
				nTentativas := 0
				
				While !lLock .AND. nTentativas <= 10
					nTentativas ++
					If RecLock(cArquivo, lApend)
						lLock := .T.
						If aAlterados[j][1]
							dbDelete()
						Else
							For z := 3 To Len(aAlterados[j])
								nField := AScan(aCampos, {|x| x[1] == aAlterados[j][z][1]})
								If (aCampos[nField][2] == "LG_COO")
									If (aAlterados[j][z][2] > SLG->LG_COO)
										&(cArquivo+"->"+aCampos[nField][2]) := aAlterados[j][z][2]
									EndIf
								Else
									&(cArquivo+"->"+aCampos[nField][2]) := aAlterados[j][z][2]
								EndIf
							Next
						EndIf
						dbCommit()
						MsUnLock()
					Endif
				End
			Next
			If nContinue == 0
				lOk := .T.
				If cPSSSX5 == "CARREGAR"
					// Atualizar o SIGAADV.PSS em pacotes.
					FRTGeraSLI(cEstacao, "PSS", "CARREGAR", "SOBREPOE")
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Release 11.5 - Controle de Formularios ³ 
				//³Carga da tabela 01 do SX5              ³
				//³Paises:Chile/Colombia  - F1CHI		  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				If lCFolLocR5 .AND. c01SX5 == "CARREGAR"					
					FRTGeraSLI(cEstacao, "01", "CARREGAR", "SOBREPOE")
				EndIf				   
				
				If lOk
					DbSelectArea("SLI")
					DbSeek(xFilial("SLI")+"    CRG")
					cCarga := SLI->LI_MSG
					nAt := At(cArquivo,cCarga)
					If nAt > 0
						cCarga := Stuff(cCarga, nAt+3, 6, cCargaAtual)
					Else
						cCarga := AllTrim(cCarga)+cArquivo+cCargaAtual
					EndIf
					FRTGeraSLI("    ", "CRG", cCarga, "SOBREPOE")
					If cPaisLoc != "BRA" .AND. cArquivo == "SM2" 
					   FRTGeraSLI("    ", "SM2", "ATUALIZA", "SOBREPOE")
					EndIf
					If oServer <> Nil
						bMTrans := {|| oServer:CallProc("FRTCargaOK", Val(cEstacao), cArquivo+cCargaAtual) }
						nRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
                    EndIf
					If ValType(nRet) == "N" .AND. nRet == 0
						ConOut(STR0024+aCargaOK[i][2]+STR0059+cArquivo+STR0025)	//"Front Loja: Carga " ### " do arquivo " ### " atualizada."
					Else
						Conout(STR0134+"["+ValType(nRet)+"]") 					//"Front Loja: Retorno diferente do esperado em FRTCargaOK - codigo "
					EndIf
				EndIf
			EndIf
		Else
			If ValType(aAux) == "N"
				If (aAux >= 2 .AND. aAux <= 4) .OR. (aAux >= 11 .AND. aAux <= 13)
					// "Front Loja: Ocorreu algum problema na abertura dos arquivos de Carga das"
					// "            Estacoes no Servidor. Erro: "
					ConOut(STR0026)
					ConOut(STR0027+Str(aAux,2,0))
				EndIf
			EndIf		
			If nContinue != 0 .AND. ++nRetry > 10
				nContinue := 0
				// "Front Loja: Nao foi possivel efetuar a Carga " ### " do arquivo " ### "."
				ConOut(STR0028+aCargaOK[i][2]+STR0059+cArquivo+".")
				Exit
			EndIf
			Sleep(1000)
		EndIf
	End
Next
aCargaOK := {}
Return(NIL)
                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³VerErro   ³ Autor ³ Vendas CRM            ³ Data ³15/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para retornar a descricao de um erro generico       ³±±
±±³          ³ do sistema                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ VerErro(ExpA1,ExpL2,ExpC3)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpA1 - Para verificar se houve erro         		      ³±±
±±³          ³ ExpN2 - Retorno da funcao								  ³±±
±±³          ³ ExpN3 - Retorna a descricao do erro           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. or .F.								          	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerErro( e, lErro, cErro )

Local lRet		:= .F.  //Variael de retorno da funcao
Local lTrans	:= .F.	//indica se esta em um bloco de transacao

DEFAULT e		:= NIL
DEFAULT lErro	:= .F.
DEFAULT cErro	:= ""

If e:Gencode > 0
	If InTransaction()
		lTrans := .T.
    	cErro += STR0123 + CRLF //"Houve um erro no processamento de gravacao : "
	Else
    	cErro := STR0124 + CRLF //"Houve um erro no levantamento de registros : "
	EndIf

    cErro += STR0125 + e:Description + CRLF //"Descriçcao: "
    cErro += e:ErrorStack
    lErro := .T.
    lRet  := .T.
 
	//exibe a mensagem de erro no console
    conout(cErro)
    LjGrvLog("VerErro",cErro)
	//executa o bloco RECOVER do BEGIN/END SEQUENCE
	If lTrans
		BREAK
	EndIf

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³GeraL1L2L4³ Autor ³ Cesar Eduardo Valadao ³ Data ³22/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Recebe o "pacote" de orcamento do Server Local             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraL1L2L4(aSL1, aSL2, aSL4, cEstacao)
Local nI            := 0		//Controle de loop
Local nJ            := 0		//Controle de loop
Local aAux          := {}
Local cChave        := ""
Local nOrder		:= 0
Local cMay          := ""
Local nTent 		:= 0
Local nRecno		:= 0
Local lOrc 			:= .F.
Local cRet 			:= ""
Local cNumOrc		:= ""
Local lAppend		:= .F.
Local nSaveSx8 		:= 0
Local lMultOrc		:= .F.
Local lReserva		:= .F.
Local aMultOrc		:= {}
Local cL2NumOrig	:= ""
Local nPosNOrig		:= 0		//Posicao no array aSL2 do campo L2_NUMORIG 
Local nPosEntrega	:= 0		//Posicao no array aSL2 do campo L2_ENTREGA
Local nPosLegCod	:= 0					//Posicao do campo L2_LEGCOD, quando existir
Local aLegItem		:= {}					//Codigo itens Leg que devem ser baixados
Local cPafMD5		:= ""
Local cFilSL1		:= ""
Local nTamSer		:= 0
Local nTamDoc		:= 0
Local nTamFil		:= 0  
Local nTamDocPed    := 0
Local nTamSerped 	:= 0
Local cPDV			:= ""  
Local lDupl			:= .T. //Registro duplicado?
Local lSeekSl1		:= .F.	
Local lMayUseNum	:= .F.
Local lErro      	:= .F.
Local cErro         := ""  
Local bErro			:= {||}		//Bloco de codigo realizado quando erro
Local lVendLock		:= .F.		   // Venda ja travada por outro processo ou ja existe no momento da criacao
Local lRet			:= .T.		   // Controle de retornos da funcao
Local cChaveTrava	:= ""		//Chave para trava por DOC e SERIE
Local lTravaDoc		:= .F.		   // Variavel para controle de duplicidade do DOC
Local aAreaSL1 	    := {}		   // Area SL1 

DEFAULT aSL1		:= {}
DEFAULT aSL2		:= {}
DEFAULT aSL4		:= {}
DEFAULT cEstacao 	:= "" 

LjGrvLog("GravaVenda_GeraL1L2L4", "ID_INICIO")

//Caso tenha alguma transacao aberta Disarma a transação e finaliza a thread
If InTransaction()
	LjGrvLog("GravaVenda_GeraL1L2L4", "ATENCAO: Identificou transação aberta, irá finalizar e continuar com a gravação")
	DisarmTransaction()
EndIf

If Type("cFilAnt") == "U"
	lRet := .F.
	LjGrvLog("GravaVenda_GeraL1L2L4", "ID_ERRO - Ambiente nao esta preparado.")
Else
	LjGrvLog("GravaVenda_GeraL1L2L4", "Ambiente esta preparado.")	
EndIf

If lRet

	nSaveSx8 	:= GetSx8Len()
	nTamSer		:= TamSX3("L1_SERIE")[1]
	nTamDoc		:= TamSX3("L1_DOC")[1]
	nTamFil		:= TamSX3("L1_FILIAL")[1]  
	nTamDocPed  := TamSX3("L1_DOCPED")[1]
	nTamSerped 	:= TamSX3("L1_SERPED")[1] 
	lOrc	  	:= aSL1[AScan(aSL1,{|x|x[1]=="L1_OPERACA"})][2] == "C"
	nPosNOrig   := AScan(aSL2[1],{|x|Alltrim(x)=="L2_NUMORIG"})
	nPosEntrega	:= AScan(aSL2[1],{|x|Alltrim(x)=="L2_ENTREGA"})
	
	//Valida se utiliza template
	If HasTemplate("PCL")
		LjGrvLog("GravaVenda_GeraL1L2L4", "Template PCL(Posto de Combustiveis) habilitado")
		nPosLegCod	:= AScan(aSL2[1],{|x|Alltrim(x)=="L2_LEGCOD"})
	EndIf
	//Trata Recebimento de MultiOrçamentos
	If nPosNOrig > 0
		For nI := 2	To Len(aSL2)
			If !Empty(aSL2[nI][nPosNOrig])
				If !Empty(cL2NumOrig) .AND. cL2NumOrig != aSL2[nI][AScan(aSL2[1],{|x|Alltrim(x)=="L2_NUMORIG"})]
					lMultOrc	:= .T.    
				Else
					cL2NumOrig	:=	aSL2[nI][nPosNOrig]
				EndIf
			EndIf
			If !Empty(aSL2[nI][AScan(aSL2[1],{|x|Alltrim(x)=="L2_RESERVA"})]) .AND. aSL2[nI][nPosEntrega] <> "2"
				lReserva	:= .T.        
			EndIf
			
			aAdd(aMultOrc,aSL2[nI][nPosNOrig])
		Next nI
	Else
		LjGrvLog("GravaVenda_GeraL1L2L4", "Nao possui o campo para validar multiplos orçamentos: L2_NUMORIG")	
	Endif
	
	cFilSL1 := PadR(aSL1[AScan(aSL1,{|x|x[1]=="L1_FILIAL"})][2] ,nTamFil)
	
	If lOrc
		nOrder := 1
		cChave := cFilSL1 + aSL1[AScan(aSL1,{|x|x[1]=="L1_NUMORIG"})][2]
		
		LjGrvLog(cChave, "Chave de busca SL1(indice 1, quando L1_OPERACA = C) -> (L1_FILIAL+L1_NUMORIG):"+cChave)
	Else
		If !Empty(aSL1[AScan(aSL1,{|x|x[1]=="L1_DOC"})][2] ) 
			nOrder := 2
			cChave	:=	cFilSL1 + ;
						PadR(aSL1[AScan(aSL1,{|x|x[1]=="L1_SERIE"})][2],nTamSer)+;
				  		PadR(aSL1[AScan(aSL1,{|x|x[1]=="L1_DOC"})][2] ,nTamDoc )+;
				  		aSL1[AScan(aSL1,{|x|x[1]=="L1_PDV"})][2]
				  		
			LjGrvLog(cChave, "Chave de busca SL1(indice 2) -> (L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV):"+cChave)
			lTravaDoc := .T.
			cChaveTrava := cChave
		ElseIf !Empty(aSL1[AScan(aSL1,{|x|x[1]=="L1_DOCPED"})][2] )        
			nOrder := 11 // SERPED + L1_DOCPED		
			cChave	:=	cFilSL1 + ;
						PadR(aSL1[AScan(aSL1,{|x|x[1]=="L1_SERPED"})][2],nTamSerPed)+;
				  		PadR(aSL1[AScan(aSL1,{|x|x[1]=="L1_DOCPED"})][2] ,nTamDocPed )
			cPDV 	:= aSL1[AScan(aSL1,{|x|x[1]=="L1_PDV"}	)][2]
			
			LjGrvLog(cChave, "Chave de busca SL1(indice 11) -> (L1_FILIAL+L1_SERPED+L1_DOCPED+L1_PDV):"+cChave)		
		Else
			nOrder := 2
			cChave:=	cFilSL1 + ;
						PadR(aSL1[AScan(aSL1,{|x|x[1]=="L1_SERIE"})][2],nTamSer)+;
					  	PadR(aSL1[AScan(aSL1,{|x|x[1]=="L1_DOC"})][2] ,nTamDoc )+;
					  	aSL1[AScan(aSL1,{|x|x[1]=="L1_PDV"})][2]
					  	
			LjGrvLog(cChave, "Chave de busca SL1(indice 2 com L1_DOC Vazio) -> (L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV):"+cChave)		
		EndIf
	EndIf
	
	DbSelectArea("SL1")
	SL1->(DbSkip(-1))		// Mexe o cursor apenas para nao falhar o seek
	SL1->(DbGoTop())
	DbSetOrder(nOrder)
	If SL1->(DbSeek(cChave))
		LjGrvLog(cChave, "Encontrou registro na SL1")
	Else
		LjGrvLog(cChave, "Não encontrou registro na SL1. Venda será adicionada")	
	EndIf  
	
	//Valida se o número do PDV é igual para o mesmo Ll_FILIAL + L1_SERPED + L1_DOCPED
	If nOrder == 11 .AND. Found()
		LjGrvLog(cChave, "Valida se o número do PDV é igual para o mesmo Ll_FILIAL + L1_SERPED + L1_DOCPED")
		lDupl := .F.
		Do While !Eof() .AND. &(IndexKey()) == cChave
			If RTrim(L1_PDV) == RTrim(cPDV)
				lDupl := .T.
				Exit
			EndIf
			SL1->(dbSkip())
		EndDo
		LjGrvLog(cChave, "Retorno da Validação:",lDupl)
	EndIf
	
	//Validação pelo indice 11 pode ocorrer duplicidade pela chave do índice, pois o L1_PDV não é chave      
	If !lMultOrc .AND. Found()  .AND. lDupl
		LjGrvLog(cChave, "Encontrou o Orcamento na Retaguarda. L1_SITUA:"+SL1->L1_SITUA)
		
		// Se o Orcamento foi importado e nao foi processado
		// Ou Houve erros no processamento do Orcamento,
		// Ou o Orcamento caiu no meio
		// Refaz o orcamento
		If lReserva
			aSL1[AScan(aSL1,{|x|x[1]=="L1_STATUS"})][2] := "F"	
		EndIf
		If (L1_SITUA == "TX") .OR. (L1_SITUA == "  ") .OR. (L1_SITUA == "ER")
			LjGrvLog(cChave, "Entrou em condicao quando L1_SITUA = ('TX','','ER')")
			nI := AScan(aSL1,{|x|x[1]=="L1_NUM"})
			If lOrc
				aSL1[AScan(aSL1,{|x|x[1]=="L1_NUMORIG"})][2] := aSL1[nI][2]
			EndIf
			If nI > 0
				LjGrvLog(cChave, "Redimensionou Array aSL1")
				ADel(aSL1, nI)
				ASize(aSL1, Len(aSL1)-1)
			EndIf
			lAppend := .F.
		Else
			//Certifica se a venda já existe para retornar 'OK' e nao 'DU'(BX)
			//O 'DU'(BX) será usado apenas para erro de serie duplicada
			If 	AllTrim(aSL1[AScan(aSL1,{|x|x[1]=="L1_CLIENTE"})][2]) == AllTrim(SL1->L1_CLIENTE) 	.AND. ;
				aSL1[AScan(aSL1,{|x|x[1]=="L1_VLRLIQ" })][2] == SL1->L1_VLRLIQ
		
				LjGrvLog(cChave, "Venda (Doc/Serie) já existe na retaguarda para o mesmo cliente e valor. Ira retornar OK")	 				
				ConOut(STR0133 + SL1->L1_NUM+".") //"Front Loja: Vanda ja existe marcada como OK" 
				ConOut(STR0065+SL1->L1_FILIAL+STR0066+cEstacao+STR0067+cChave)// "Filial:" ### " Estacao:" ### " Serie/Doc/PDV:"
				cRet := "OK|"+SL1->L1_NUM
			Else
				LjGrvLog("GravaVenda_GeraL1L2L4", "ID_ALERT")
				LjGrvLog(cChave, "Venda (Doc/Serie) já existe na retaguarda para cliente e/ou valor diferentes.") 
				LjGrvLog(cChave, "Indica que existem estações distintas com mesma numeracao. VERIFIQUE os cadastros de estações(SLG). Ira gravar L1_SITUA= 'DU' na estação que tentou duplicar o documento.")
				// "Front Loja: Tentativa de duplicar o Orcamento " ### "."
				// "            Verifique o L1_SITUA='DU' na estacao."
				// "            Filial:" ### " Estacao:" ### " Serie/Doc/PDV:"
				ConOut(STR0060+SL1->L1_NUM+".")
				ConOut(STR0065+SL1->L1_FILIAL+STR0066+cEstacao+STR0067+cChave)
				ConOut(STR0061)
				cRet := "BX|"+SL1->L1_NUM
			EndIf	
		EndIf
	Else	
		
		LjGrvLog(cChave, "Inicia processo de inclusão de orçamento na retaguarda")	
		cNumOrc := CriaVar("L1_NUM")
			
		// Caso o SXE e o SXF estejam corrompidos cNumOrc estava se repetindo.
		cMay := Alltrim(xFilial("SL1"))+cNumOrc
		FreeUsedCode()
		SL1->(DbSetOrder(1))	//L1_FILIAL+L1_NUM
		
		lSeekSl1		:= SL1->(DbSeek(xFilial("SL1")+cNumOrc))	
		lMayUseNum		:= !MayIUseCode(cMay)
			
		// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
		While lSeekSl1 .OR. lMayUseNum 
		
			If nTent == 0 
				LjGrvLog(cChave, "Número de orçamento(L1_NUM) em uso. Registro Localizado SL1:"+IIF(lSeekSl1,"Sim","Nao")+".Conseguiu Reservar o Numero:"+IIF(lMayUseNum,"Sim","Nao"))
			EndIf
			
			If ++nTent > 20
				// "SXE e SXF corrompidos, impossivel gerar numero sequencial de orcamento correto."
				ConOut(STR0062)
				ConOut("Filial :"+xFilial("SL1")+ "Orcamento :"+cNumOrc )
				LjGrvLog(cChave,"SXE e SXF corrompidos",xFilial("SL1")+" | "+ cNumOrc + ". Irá retornar em branco para nova tentativa.")		
				cRet := ""
				lRet := .F.
				Exit
			Endif
			While (GetSX8Len() > nSaveSx8)
				ConfirmSx8()
			End
			cNumOrc    := CriaVar("L1_NUM")
			FreeUsedCode()
			cMay := Alltrim(xFilial("SL1"))+cNumOrc
			
			lSeekSl1		:= SL1->(DbSeek(xFilial("SL1")+cNumOrc))	
			lMayUseNum		:= !MayIUseCode(cMay)		
		End
		
		LjGrvLog(cChave, "Número do orçamento que será adicionado(L1_NUM ):"+cNumOrc)
		
		aSL1[AScan(aSL1,{|x|x[1]=="L1_NUM"})][2] := cNumOrc                                             
		If Len(aMultOrc) >= 2 .AND. lReserva
			aSL1[AScan(aSL1,{|x|x[1]=="L1_STATUS"})][2] := "F"
		EndIf
		lAppend := .T.
	EndIf
EndIf	

If lRet .AND. cRet == ""

	SetAbendlock(.T.)	//Retornar erro em caso de falha no RecLock 	
	
	bErro := ErrorBlock({|e| VerErro(e,@lErro,@cErro)})
	BEGIN TRANSACTION
		BEGIN SEQUENCE
		
			LjGrvLog(cChave, "Inicia Transação.")

			//Foi realizado tratamento para trava porque duas threads subiam ao mesmo tempo
			//para mesma venda, duplicando as vendas da retaguarda.
			If lTravaDoc .AND. lAppend
				
				LjGrvLog(cChave, "Trava Doc Ativa.")
				
				FreeUsedCode() //libera codigos de correlativos reservados pela MayIUseCode()
				cMay := Alltrim(cChaveTrava)
						
				aAreaSL1 	    := SL1->(GetArea())			
			   	//Pesquisa novamente venda com chave para garantir unico registro
				DbSelectArea("SL1")
				SL1->(DbSkip(-1))		// Mexe o cursor apenas para nao falhar o seek
				SL1->(DbGoTop())
				SL1->(DbSetOrder(2))	//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
				lSeekSl1 := SL1->(DbSeek(cChaveTrava))
	
				lMayUseNum		:= !MayIUseCode(cChaveTrava)
				
				RestArea(aAreaSL1) //Restaura area anterior
			EndIf	
				
			If (lTravaDoc .AND. !lSeekSl1 .AND. !lMayUseNum) .OR. !lTravaDoc
			
				//Gera o SL1
				LjGrvLog(cChave, "Inicia gravacao SL1. Venda esta disponivel para ser gravada lAppend: " + IIF(lAppend,".T.",".F.") )
				FRTGeraSL("SL1", aSL1, lAppend)
				
				LjGrvLog(cChave, "Antes confirme SX8")
				If lAppend
					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End
				EndIf
				
				LjGrvLog(cChave, "Limpa dados SL2,SL4")
				FRTCancela(.F., .T., .T.)					// Deleta o SL2 e o SL4
				
				//Gera o SL2
				LjGrvLog(cChave, "Inicia gravacao SL2")			
				DbSelectArea("SL2")
				SL2->( DbSetOrder(1) )	//L2_FILIAL + L2_NUM + L2_ITEM (X2_UNQ)
				For nI := 2 To Len(aSL2)
					aAux := Array(Len(aSL2[1]))
					For nJ := 1 To Len(aSL2[1])
						aAux[nJ] := {aSL2[1][nJ], aSL2[nI][nJ]}
					Next nJ
					If !SL2->( DbSeek(aAux[AScan(aAux,{|x|x[1]=="L2_FILIAL"})][2] + SL1->L1_NUM + aAux[AScan(aAux,{|x|x[1]=="L2_ITEM"})][2]) )
		
						aAux[AScan(aAux,{|x|x[1]=="L2_NUM"})][2] := SL1->L1_NUM
						aAux[AScan(aAux,{|x|x[1]=="L2_SITUA"})][2] := "TX"					// "TX" - Foi Transferido Para o Server
						FRTGeraSL("SL2", aAux, .T.)
		
						//Verifica se item de abastecimento, quando possui LEGCOD para sinalizar que o abastecimento(LEG) foi utilizado
						If (nPosLegCod > 0) .AND. !Empty(aAux[nPosLegCod][2])
							Aadd(aLegItem,aAux[nPosLegCod][2])				
						EndIf
					Else
						LjGrvLog(cChave, "Tentativa de duplicar SL2")
					EndIf				
				Next nI
				
				//Gera o SL4
				LjGrvLog(cChave, "Inicia gravacao SL4")
				For nI := 2 To Len(aSL4)
					aAux := Array(Len(aSL4[1]))
					For nJ := 1 To Len(aSL4[1])
						aAux[nJ] := {aSL4[1][nJ], aSL4[nI][nJ]}
					Next nJ
					aAux[AScan(aAux,{|x|x[1]=="L4_NUM"})][2]	:= SL1->L1_NUM
					aAux[AScan(aAux,{|x|x[1]=="L4_SITUA"})][2]	:= "TX"					// "TX" - Foi Transferido Para o Server
					FRTGeraSL("SL4", aAux, .T.)			
				Next nI
				//³ Atualiza Abastecimento(LEG) ³
				If Len(aLegItem) > 0
					LjGrvLog(cChave, "Inicia gravacao LEG")
					DbSelectArea("LEG")
					LEG->(DbSetOrder(1))	//LEG_FILIAL+LEG_ID+LEG_CODAJU
					For nI := 1 to Len(aLegItem)
						If LEG->(DbSeek( SL1->L1_FILIAL + aLegItem[nI] ))					
							RecLock("LEG",.F.)
							nRecno := LEG->(Recno())
							Replace LEG->LEG_NUM With SL1->L1_NUM
							LEG->(MsUnlock())
						
							If ExistTemplate("TpMD5LEG") .AND. (LEG->(ColumnPos("LEG_PAFMD5")) > 0)
								LEG->(DbGoto(nRecno))
								cPafMd5 := T_TpMD5LEG( .F. , "LEG", .F. )
							
								RecLock("LEG",.F.)
								Replace LEG->LEG_PAFMD5 With cPafMD5
								LEG->(MsUnlock())
							EndIf
						EndIf
					Next nI
				EndIf
				LjGrvLog("GeraL1","Finaliza a gravacao do orcamento")
			Else				
				LjGrvLog(cChave, "Venda encontada na base? ", lSeekSl1   )
				LjGrvLog(cChave, "Venda esta com Lock disponivel para ser gravada? ", lMayUseNum )
				lVendLock		:= .T.		   // Venda ja travada por outro processo ou ja existe no momento da criacao
			EndIf
			
		RECOVER
			LjGrvLog("GeraL1","Problemas na gravacao")
			DisarmTransaction() // EM CASOS DE ERRO, DESFAZ A TRANSACAO
			FreeUsedCode() //libera codigos de correlativos reservados pela MayIUseCode()
		END SEQUENCE
		
		If lVendLock
		   cRet := "" //Irá retornar em branco para nova tentativa.
		ElseIf !lErro 
			cRet := "OK|" + SL1->L1_NUM
		Else
			ErrorBlock(bErro)
			cRet := "ER|" + SL1->L1_NUM + "|" + AllTrim(cErro) 
			Conout("GeraL1","Problemas na gravacao da venda: " + SL1->L1_NUM + " Erro: " + AllTrim(cErro)   )
			LjGrvLog(cChave, "Problemas na gravacao da venda: " + SL1->L1_NUM + " Erro: " + AllTrim(cErro)   )
		EndIf
	END TRANSACTION
	
	SetAbendlock(.F.)
	//Atualiza status dos orçamento de origem            
	If lMultOrc
		If SL1->L1_SITUA <> "07"
			For nI := 1 To Len(aMultOrc)
				cChave	:=	aMultOrc[nI]
				DbSelectArea("SL1")
				DbSetOrder(1)	//L1_FILIAL+L1_NUM
				If !Empty(cChave) .AND. DbSeek(xFilial("SL1")+cChave)
					aSL1MultOrc := {{"L1_SERIE"		,	aSL1[AScan(aSL1,{|x|x[1]=="L1_SERIE"})][2]	}, ;
									 {"L1_SERPED"	,	aSL1[AScan(aSL1,{|x|x[1]=="L1_SERPED"})][2]	}, ;
									 {"L1_DOC"		,	aSL1[AScan(aSL1,{|x|x[1]=="L1_DOC"})][2]	}, ;
									 {"L1_DOCPED"	,	aSL1[AScan(aSL1,{|x|x[1]=="L1_DOCPED"})][2]	}, ;
									 {"L1_PDV"		,	aSL1[AScan(aSL1,{|x|x[1]=="L1_PDV"})][2]	}, ;
							         {"L1_CONFVEN"	,	"SSSSSSSSNSSS"	}, ;
							         {"L1_SITUA"	,	"FR"			}, ;
							         {"L1_STATUS"	,	"F"				}, ;
							         {"L1_EMISNF"	,	aSL1[AScan(aSL1,{|x|x[1]=="L1_EMISNF"})][2]	}, ;
							         {"L1_OPERADO"	,	aSL1[AScan(aSL1,{|x|x[1]=="L1_OPERADO"})][2]}, ;
							         {"L1_ESTACAO"	,	aSL1[AScan(aSL1,{|x|x[1]=="L1_ESTACAO"})][2]}, ;
							         {"L1_NUMFRT"	,	cNumOrc			}, ;
									 {"L1_IMPRIME"	,	"1S"			} }
					LjGrvLog(cChave, "Atualiza dados de orcamento origem")
					FRTGeraSL("SL1", aSL1MultOrc, .F.)                     
				Endif
			Next nI
		EndIf
	EndIf
EndIf

If InTransaction()
	LjGrvLog(cChave,"Possui uma transação aberta no final,disarmar a transação. Irá retornar em branco para nova tentativa.")
	DisarmTransaction()
	cRet := ""
EndIf

LjGrvLog(cChave,"Retorno da Funcao",cRet)
LjGrvLog("GravaVenda_GeraL1L2L4", "ID_FIM")

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ConfL1L2L4³ Autor ³ Cesar Eduardo Valadao ³ Data ³22/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma a Gravacao do L1 L2 e L4.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ConfL1L2L4(cNum, cEstacao, lGrvRet)
Local lOkL1 		:= .T.		// Controle se a SL1 esta OK
Local lOkL2 		:= .T.		// Controle se a SL2 esta OK
Local lOkL4 		:= .T.		// Controle se a SL4 esta OK
Local cSituaRec		:= "RX"
Local lCentPDV		:= .F. 		// Eh Central de PDV 
Local cSeek			:= ""
Local lErro      	:= .F.
Local cErro         := ""  
Local bErro			:= Nil		//Bloco de codigo realizado quando erro
Local cRet			:= ""	    //Retorna o numero do orcamento caso encontrado
Local lRet			:= .T.

DEFAULT cNum 		:= ""
DEFAULT cEstacao 	:= ""
DEFAULT lGrvRet		:= .F. //Informa que gravou a venda com sucesso na retaguarda quando venda online e central de PDVs


LjGrvLog("ConfirmaVenda_ConfL1L2L4", "ID_INICIO")
LjGrvLog("ConfirmaVenda_ConfL1L2L4","INICIO DA CONFIRMACAO DO ORCAMENTO(ConfL1L2L4)" + " - Estação: " + cEstacao + " NUM: " + cNum )

If Type("cFilAnt") == "U"
	lRet := .F.
	LjGrvLog("ConfirmaVenda_ConfL1L2L4", "ID_ERRO - Ambiente nao esta preparado.")
Else
	LjGrvLog("ConfirmaVenda_ConfL1L2L4", "Ambiente esta preparado.")	
EndIf

If lRet
	//===================================================
	// "RX" - Foi Recebido Pelo Server (Server)                 
	// "CP" - Recebido pela Central de PDV
	//===================================================
	
	//-- Se for Central de PDV campos _SITUA deve ter o conteúdo igual a "CP"
	lCentPDV	:= IIf( FindFunction("LjGetCPDV"), LjGetCPDV()[1] , .F. )
	If lCentPDV .AND. !lGrvRet 
		cSituaRec := "CP"
	//-- Se for Central de PDV e ja gravou a venda online na retaguarda campos _SITUA deve ter o conteúdo igual a "TX"
	ElseIf lCentPDV .AND. lGrvRet 
		cSituaRec := "TX"	
	EndIf
	
	DbSelectArea("SL1")
	DbSetOrder(1)	//L1_FILIAL+L1_NUM
	cSeek := xFilial("SL1")+cNum
	LjGrvLog("ConfirmaVenda_ConfL1L2L4","Procura Orcamento Chave: " + cSeek + " NUM: " + cNum)
	
	bErro := ErrorBlock({|e| VerErro(e,@lErro,@cErro)})
	BEGIN TRANSACTION
		BEGIN SEQUENCE	
	
			If DbSeek(xFilial("SL1")+cNum)
				LjGrvLog("ConfirmaVenda_ConfL1L2L4","ENCONTROU O ORCAMENTO NA RETAGUARDA : L1_SITUA: " + SL1->L1_SITUA + " NUM: " + cNum)
				
				If (SL1->L1_SITUA <> "FR") .AND. (SL1->L1_SITUA <> "OK") .AND. (SL1->L1_SITUA <> "RX")  // Se ja esta OK nao muda
					//³ Confirma o SL1 ³
					lOkL1 := FRTGeraSL("SL1", {{"L1_SITUA", cSituaRec}})								// "RX" - Foi Recebido Pelo Server
					//³ Confirma o SL2 ³
					DbSelectArea("SL2")
					DbSetOrder(1)            											//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
					If DbSeek(xFilial("SL2")+ cNum )
						While SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2")+cNum
							FRTGeraSL("SL2", {{"L2_SITUA", cSituaRec }})						// "RX" - Foi Recebido Pelo Server
							DbSkip()
						End
					Else
						lOkL2 := .F.														// Venda sem SL2	
						Conout(STR0029+SL1->L1_FILIAL+SL1->L1_NUM+" SL2-Not Found")
						LjGrvLog("ConfirmaVenda_ConfL1L2L4",STR0029+SL1->L1_FILIAL+SL1->L1_NUM+" SL2-Not Found")
						LjGrvLog("ConfirmaVenda_ConfL1L2L4","ID_ALERT")
					EndIf	
					//³ Confirma o SL4 ³
					DbSelectArea("SL4")
					DbSetOrder(1)            											// L4_FILIAL+L4_NUM+L4_ORIGEM
					If DbSeek(xFilial("SL4")+ cNum )	
						While SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4")+cNum
							FRTGeraSL("SL4", {{"L4_SITUA", cSituaRec }})						// "RX" - Foi Recebido Pelo Server
							DbSkip()
						End
					ElseIf SL1->L1_CREDITO == 0
						LjGrvLog("ConfirmaVenda_ConfL1L2L4","SL4-Nao Encontrada",SL1->L1_FILIAL+" "+cNum)
						Conout(STR0029+SL1->L1_FILIAL+SL1->L1_NUM+" SL4-Not Found")
						lOkL4 := .F.	
						LjGrvLog("ConfirmaVenda_ConfL1L2L4","ID_ALERT")
					EndIf	
				    
					If LOkL1 .AND. lOkL2
						// "Front Loja: Orcamento " ### " Gravado. Filial:" ### " Estacao:" ### " PDV/COO:"
						ConOut(STR0029+SL1->L1_NUM+STR0030+SL1->L1_FILIAL+STR0063+cEstacao+STR0064+AllTrim(SL1->L1_PDV)+"/"+SL1->L1_DOC+"/Data:"+Dtos(Date())+"/Hora:"+Time())
						LjGrvLog("ConfirmaVenda_ConfL1L2L4",STR0029+SL1->L1_NUM+STR0030+SL1->L1_FILIAL+STR0063+cEstacao+STR0064+AllTrim(SL1->L1_PDV)+"/"+SL1->L1_DOC+"/Data:"+Dtos(Date())+"/Hora:"+Time())
						cRet := AllTrim(SL1->L1_NUM) //Retona o numero da venda
						FRTGrvRX(SL1->L1_NUM, SL1->L1_PDV, SL1->L1_DOC)
					ElseIf !lOkL2				// Nesse primeiro momento somente vai excluir se nao tiver SL2 (SL4 pode ser colocado futuramente)	
						LjGrvLog("ConfirmaVenda_ConfL1L2L4","Orcamento com problemas na SL2",SL1->L1_FILIAL+" "+cNum)
						DbSelectArea("MDJ")     // Grava a MDJ para informar que existe uma venda parada no PDV
						DbSetOrder(1) 			//MDJ->MDJ_FILIAL + MDJ->MDJ_DOC + MDJ->MDJ_SERIE + MDJ->MDJ_CLIENT + MDJ->MDJ_LOJA
						If !DbSeek(xFilial("MDJ")+SL1->L1_DOC +SL1->L1_SERIE +SL1->L1_CLIENTE+SL1->L1_LOJA)
							RecLock("MDJ",.T.)
							REPLACE MDJ_FILIAL 	WITH SL1->L1_FILIAL
							REPLACE MDJ_DOC 	WITH SL1->L1_DOC
							REPLACE MDJ_SERIE 	WITH SL1->L1_SERIE
							REPLACE MDJ_CLIENT 	WITH SL1->L1_CLIENTE
							REPLACE MDJ_LOJA 	WITH SL1->L1_LOJA
							REPLACE MDJ_OPERAD 	WITH SL1->L1_OPERADO
							REPLACE MDJ_EMIS 	WITH SL1->L1_EMISNF
							REPLACE MDJ_NUMORC 	WITH SL1->L1_NUM
							REPLACE MDJ_OPER 	WITH "V"
							REPLACE MDJ_SITUA 	WITH "VD"
							MsUnlock()
						EndIf
						FRTCancela()			// Deleta o SL1
					EndIf
				Else
					LjGrvLog("ConfirmaVenda_ConfL1L2L4","Venda já foi confirmada no Server L1_SITUA IN (FR|OK|RX)." )
					cRet := AllTrim(SL1->L1_NUM) //Retona o numero da venda
				EndIf
			Else
				LjGrvLog("ConfirmaVenda_ConfL1L2L4","NAO ENCONTROU O ORCAMENTO NA RETAGUARDA: " + cSeek)
				cRet := ""
			EndIf
		RECOVER
			LjGrvLog("ConfirmaVenda_ConfL1L2L4","Problemas na gravacao")
			cRet := ""
			DisarmTransaction() // EM CASOS DE ERRO, DESFAZ A TRANSACAO
			LjGrvLog("ConfirmaVenda_ConfL1L2L4","ID_ERRO")
		END SEQUENCE
		
		If lErro 
			ErrorBlock(bErro)
			Conout("ConfL1L2L4"  ,"Problemas na confirmacao da venda: " + SL1->L1_NUM + " Erro: " + AllTrim(cErro)   )
			LjGrvLog("ConfirmaVenda_ConfL1L2L4","Problemas na confirmacao da venda: " + SL1->L1_NUM + " Erro: " + AllTrim(cErro)   )
			cRet := ""
			LjGrvLog("ConfirmaVenda_ConfL1L2L4","ID_ERRO")
		EndIf
		
	END TRANSACTION
EndIf

LjGrvLog("ConfirmaVenda_ConfL1L2L4","FIM DO PROCESSO DE CONFIRMACAO(ConfL1L2L4)L1_NUM: " + cNum +  " | Retorno: " + cRet )
LjGrvLog("ConfirmaVenda_ConfL1L2L4","ID_FIM")
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraE5    ºAutor  ³ Cesar E. Valadao    º Data ³  30/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recebe o "pacote" de orcamento do Server Local.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1: Array com os campo do SE5                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Front Loja                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLuiz Couto³07/09/05³8.11  ³- Implementacao continua: padronizacao de    º±±
±±º          ³        ³      ³fontes.                                      º±±
±±ºLuiz Couto³07/09/05³8.11  ³- BOPS 87087: Area SE5 selecionada para o    º±±
±±º          ³        ³      ³correto funcionamento do BEGIN TRANSACTION.  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraE5( aSE5, lDecode )

Local nReg						//Recno do SE5
Local oInt			:= Nil      
Local lGerInte	:= SuperGetMV("MV_LJGRINT",.F. ,.F.) 
Local cNatureza	:= ""
Local cSinal		:= ""		// Define se envia Atualizaçao de Banco negativo ou positivo
Local cRecPag		:= ""		// Recebimento ou pagamento
Local cTipoDoc	:= ""		// Tipo de documento
Local nPosFilOrig	:= .F.		// Posicao no array do campo E5_FILORIG
Local nPosLGI		:= 0		// Log de inclusao de usuario
Local nPosLGA		:= 0		// Log de alteração de usuario

Default lDecode	:= .F.		// Decodifica o conteudo do campo 

cNatureza	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_NATUREZ" } )][2]
cRecPag	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_RECPAG" } )][2]
cTipoDoc	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_TIPODOC" } )][2]

If lDecode
	If (nPosLGI := AScan( aSE5, { |x| x[1] == "E5_USERLGI" } )) > 0
		aSE5[nPosLGI][2] := Decode64(aSE5[nPosLGI][2])
	EndIf
	
	If (nPosLGA := AScan( aSE5, { |x| x[1] == "E5_USERLGA" } )) > 0
		aSE5[nPosLGA][2] := Decode64(aSE5[nPosLGA][2])
	EndIf
EndIf

aSE5[AScan( aSE5, { |x| x[1] == "E5_SITUA" } )][2]	 := "OK"		// "TX" - Foi Processado no Server
                                                          
// Verifica existencia do campo E5_FILORIG no array aSE5                        
nPosFilOrig := AScan( aSE5, { |x| x[1] == "E5_FILORIG" } )                                       
If nPosFilOrig > 0
	// Se estirver vazia a informacao do campo SE_FILORIG iguala com cFilAnt 
	If Empty( aSE5[nPosFilOrig][2])
		aSE5[nPosFilOrig][2] := cFilAnt
	Endif			
Endif

If VldIncSE5(aSE5)
	DbSelectArea( "SE5" )
	DbSetOrder( 1 )	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ

	BEGIN TRANSACTION

	FRTGeraSL( "SE5", aSE5, .T. )

	//Verifica se é sangria ou troco
	If Alltrim(cTipoDoc) == 'TR'
		If AllTrim(cRecPag) == "R"
			cSinal := "+"
		Else 
			cSinal := "-"
		EndIf
	    // Atualiza saldo bancario
		AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA,SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, cSinal)
	EndIf
	
	END TRANSACTION

	If lGerInte 

		If AllTrim(Upper(cNatureza)) == "TROCO"

			oInt := LJCAdapXMLEnvSuprimento():New()

		ElseIf AllTrim(Upper(cNatureza)) == "SANGRIA"

			oInt := LJCAdapXMLEnvSangria():New()	
		
		EndIf
		
		If oInt != Nil
			oInt:Inserir("SE5", xFilial("SE5") +  SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA) + SE5->E5_CLIFOR + SE5->E5_LOJA + SE5->E5_SEQ, "2", "3")
			oInt:Gerar()
			oInt:Finalizar()
		EndIf
	EndIf
	
	LJGRVLOG( Nil, "Registro incluido com sucesso!",SE5->(Recno()))
Else
	LJGRVLOG( Nil, "Registro nao incluido pois equivalente ja existente na tabela. Recno:",SE5->(Recno()))
EndIf	

nReg := SE5->( Recno() )

//O retorno é "OK" mesmo quando o registro ja existe para que 
//seja atualizado no PDV que o registro ja esta OK (cadastrado)
Return ( { "OK", nReg } )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ConfE5   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³30/10/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma a Gravacao do E5.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ConfE5(nRecno)
DbSelectArea("SE5")
DbGoto(nRecno)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Confirma o SE5 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTGeraSL("SE5", {{"E5_SITUA", "OK"}})										// "OK" - Foi Processado Pelo Server
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ GeraA1   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³06/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Recebe o "pacote" de SA1 do Server Local                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraA1(aSA1)
Local nReg
Local cCod, cLoja
aSA1[AScan(aSA1,{|x|x[1]=="A1_SITUA"})][2]	:= "TX"						// "TX" - Foi Processado no Server
cCod  := aSA1[AScan(aSA1,{|x|x[1]=="A1_COD"})][2]
cLoja := aSA1[AScan(aSA1,{|x|x[1]=="A1_LOJA"})][2]
// Procura um codigo nao utilizado
While SA1->(DbSeek(xFilial("SA1")+cCod+cLoja))
	cCod := Soma1(cCod)
End
aSA1[AScan(aSA1,{|x|x[1]=="A1_COD"})][2] := cCod
BEGIN TRANSACTION
FRTGeraSL("SA1", aSA1, .T.)
END TRANSACTION
nReg := SA1->(Recno())
Return({"OK",nReg,cCod})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ ConfA1   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³06/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma a Gravacao do A1.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ConfA1(nRecno)
DbSelectArea("SA1")
DbGoto(nRecno)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Confirma o SA1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTGeraSL("SA1", {{"A1_SITUA", "OK"}})										// "OK" - Foi Processado Pelo Server
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTExclusaºAutor  ³Andre Alves Veiga   º Data ³  13/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusao da venda (utilizando as funcoes do loja140)        º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTExclusa( cNumOrcamento, cNfisCanc )
Local nRecno		:= 0
Local nRet 		:= 0
Local nX			:= 0
Local lJob 		:= .T.
Local cPafMd5		:= ""
Local lCancAbast	:= .F.
Local lEmitNfce		:= LjEmitNFCe() // Sinaliza se utiliza NFC-e
Local lLstPre		:= .F.

Local aAbastes		:= {} 	//Guarda registro de abastecimento para cancelamento
Local aArea			:= {}
Local lExcluiNfce	:= .F. //Verifica se deve ser exlcuida a NFC-e

Default cNfisCanc := ""

Private lMsErroAuto := .F.	//status de execucao do ExecAuto

//Posiciona o SL1 e o SL2
DbSelectArea("SL1")
SL1->( DbSetOrder(1) )	//L1_NUM+L1_ITEM

If SL1->( DbSeek(xFilial("SL1") + cNumOrcamento) )

	//PAF-ECF: Verifica se explodiu a venda(GrvBatch) para realizar o cancelamento, sinaliza retornando 3( SigaLoja realiza cancelamento de diversos orcamentos de uma vez, o Front um orcamento por chamada
	//NFC-e: Retorna 3, grava STORC = C e apos o processamento do GrvBatch, se for o caso, chama rotina
	If (LjNfPafEcf(SM0->M0_CGC) .OR. lEmitNfce) .AND. (SL1->L1_SITUA == "RX" .OR. SL1->L1_SITUA == "ER") //ER está em processamento ou pode estar com erro, de todo caso não se pode cancelar.
		nRet := 3
	EndIf

	If nRet == 0

		DbSelectArea("SL2")
		SL2->( DbSetOrder(1) )	//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
		SL2->( DbSeek(xFilial("SL2") + SL1->L1_NUM) )
                            
		//Guarda abastecimentos utilizados para voltar status de pendente na tabela LEG (Regra de PAF-ECF)
		If HasTemplate("PCL") .AND. (SL1->(ColumnPos("L1_BICO") > 0)) .AND. !Empty(SL1->L1_BICO)
			lCancAbast := .T.
			aArea := SL2->(GetArea())
					
			While (SL2->L2_FILIAL + SL2->L2_NUM == SL1->L1_FILIAL + SL1->L1_NUM )
				If !Empty(SL2->L2_LEGCOD)
					Aadd(aAbastes,SL2->L2_FILIAL+SL2->L2_LEGCOD)
				EndIf
				SL2->( DbSkip() )
			End

			RestArea(aArea)
		Else
			If IsInCallStack("STDCancRec")
				aArea := SL2->(GetArea())
				While (SL2->L2_FILIAL + SL2->L2_NUM == SL1->L1_FILIAL + SL1->L1_NUM )
					If !Empty(SL2->L2_CODLPRE)
						lLstPre := .T.
						Exit
					EndIf
					SL2->( DbSkip() )
				End
				RestArea(aArea)
			EndIf
		EndIf

		//NOTA: Se FrtExclusao for chamada pela funcao GrvCancel, significa que a venda veio de um ambiente PDV PAF,
		//Como pode haver situacoes onde a venda pode possuir reservas, utilizamos o ExecAuto, pois ja existe todos os tratamentos para
		// reservas no LOJA140, caso contrario teriamos que replicar todas as funcoes do LOJA140 para o FRTA020
		lExcluiNfce := (!Empty(SL1->L1_KEYNFCE) .And. !Empty(SL1->L1_DOC))
		If lExcluiNfce .OR. IsInCallStack("GRVCANCEL") .Or. lLstPre

			If !Empty(cNfisCanc)
				MsExecAuto(	{|a,b,c,d,e,f,g,h| LJ140EXC(a,b,c,d,e,f,g,h)}, "SL1", /*nReg*/, 5, /*aReserv*/, .T., SL1->L1_FILIAL, SL1->L1_NUM,cNfisCanc )
			Else	
				MsExecAuto(	{|a,b,c,d,e,f,g| LJ140EXC(a,b,c,d,e,f,g)}, "SL1", /*nReg*/, 5, /*aReserv*/, .T., SL1->L1_FILIAL, SL1->L1_NUM )
			EndIf	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Os campos L1_DOC e L1_DOCPED são usados para verificar se o orcamento foi excluido.				³
			//³Nota: Sera necessario ajustar o ExecAuto da funcao LOJA140 para usarmos a variavel lMsErroAuto,	|
			//³pois quando ha um erro na execucao do execauto, o mesmo nao executa o help,                      |
			//|consequentemente nao seta a variavel lMsErroAuto para .T.										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Se atualizou o L1_SITUA para "X0" ou "X1", significa que eh NFC-e que devera ser cancelada, a partir deste ponto o PDV nao faz mais nada, fica o Job de cancelamento de NFC-e da Retaguarda encarregado de fazer o resto do processo de exclusao.
			If ( Empty(SL1->L1_DOC) .AND. Empty(SL1->L1_DOCPED) ) .Or. ( SL1->L1_SITUA == "X0" .Or. SL1->L1_SITUA == "X1" )
				nRet := 0
			Else
				nRet := 1
				If !Empty(SL1->L1_DOC)
					DbSelectArea("SLX")	// Verifica se a venda nao foi devolvida
					DbSetOrder(1)			// LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE
					If DbSeek(xFilial("SLX")+SL1->L1_PDV+SL1->L1_DOC+SL1->L1_SERIE) .AND. SLX->LX_TPCANC == 'D'
						nRet := 4	
					EndIf
				EndIf
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a exclusao da venda ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Lj140Grava(lJob  , NIL  , NIL  , NIL ,;
						  NIL  , NIL   , SL1->L1_NUM )
			   nRet := 0
			Else 
			   nRet  := 1
			EndIf

		EndIf  
		
		If nRet == 0 .And. !lExcluiNfce
			//So realiza a exclusao do orcamento caso o mesmo nao tenha sido importado
			//para o Front Office, ou seja, so exclui se for uma venda feita TOTALMENTE
			//pelo Front.
			//PAF-ECF: Não deve excluir L1,L2 e L4, devendo manter o registro sinalizando o cancelamento
			If AllTrim(SL1->L1_OPERACA) <> "C" .AND. !LjNfPafEcf(SM0->M0_CGC) 
				nRet := If(Lj140ExcOrc(), 0, 1)
			Else
				RecLock("SL1",.F.)
				
				//Se for orçamento importado apaga o valor do L1_STORC para que o mesmo
				//possa ser reutilizado - tratamento somente para SAT e CUPOM FISCAL.
				If !(AllTrim(SL1->L1_OPERACA) == "C") .And. (!Empty(cNfisCanc) .Or. !lExcluiNfce)
					Replace SL1->L1_STORC with "C" 
				EndIf
				Replace SL1->L1_OPERACA with ""
				Replace SL1->L1_SITUA with ""
				Replace SL1->L1_NUMORIG with ""
									
				//PAF-ECF: Gera/Atualiza chave MD5
				cPafMd5 := STxPafMd5("SL1")     
				Replace SL1->L1_PAFMD5 with cPafMD5
				
				//Limpa informação do abastecimento e volta abastecimento para pendente, conforme regra do PAF-ECF(Ato Cotepe 17/04:Abastecimento deve voltar para o status de pendente quando houver o cancelamento do item)
				If lCancAbast
					Replace SL1->L1_BICO with ""
				EndIf					
					
				SL1->( MsUnLock() )
				SL1->( dbCommit() )

				//Atualiza Status do Abastecimento para Pendente, pesquisa abastecimentos baseados no campo L2_LEGCOD 
				For nX := 1 To Len(aAbastes)
					DbSelectArea("LEG")
					LEG->(DbSetOrder(1)) //LEG_FILIAL + LEG_CODIGO
					If LEG->(DbSeek(aAbastes[nX]))
						RecLock("LEG",.F.)
							nRecno := LEG->(Recno())
							Replace LEG->LEG_NUM	With "P"
						LEG->(MsUnlock())
						
						If ExistTemplate("TpMD5LEG") .AND. (LEG->(ColumnPos("LEG_PAFMD5")) > 0)
							LEG->(DbGoto(nRecno))
							cPafMd5 := T_TpMD5LEG( .F. , "LEG" , .F. )							
							RecLock("LEG",.F.)									
								Replace LEG->LEG_PAFMD5 With cPafMd5
							LEG->(MsUnlock())
						EndIf
					EndIf
				Next nX
			EndIf
		Endif
	EndIf
Else
	nRet := 2
EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRTLockOK    ³Autor ³ Cesar Eduardo Valadao³Data³06/12/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se as estacoes jah estao esperando atualizacao    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTLockOK

Local nRecno:=Recno(), lRet:=.F.

If SLI->( DbSeek(xFilial("SLI") + cEstacao + " CON") )
	lRet := Left(SLI->LI_MSG,1) <> "V"
Else
	// Caso nao exista o registro, pode atualizar
	lRet := .T.
EndIf

DbGoto(nRecno)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTA020Sta³ Autor ³ Cesar Eduardo Valadao ³ Data ³05/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia a Thread FRTA020.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020Sta()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTA020Sta
// Function, Environment, Wait Thread, Par1, Par2, Parn, ...
// "Iniciada a Thread FRTA020.", "Atenção"
MsgStop(STR0031, STR0032)
StartJob("FRTA020", GetEnvServer(), .F., cEmpAnt, cFilAnt, cEstacao)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FRTA020End³ Autor ³ Cesar Eduardo Valadao ³ Data ³05/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicia a Thread FRTA020.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020End()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTA020End
// "Finalizada a Thread FRTA020.", "Atenção"
MsgStop(STR0033, STR0032)
FRTGeraSLI("    ", "   ", "ENDTHREAD", "SOBREPOE")
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FRTChkBase³ Autor ³ Cesar Eduardo Valadao ³ Data ³21/11/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o Arquivo Com Carga Esta Zerado.               ³±±
±±³          ³ Caso Tenha Ocorrido Algum Problema Com o Arquivo Basta     ³±±
±±³          ³ Exclui-lo Que o Mesmo Identifica e Corrige o Problema.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTChkBase()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTChkBase
Local cCRG:=RTrim(SLI->LI_MSG)
Local cNewCRG:=""
Local cArquivo, cCarga, nRecCount
Local i
For i := 1 To Len(cCRG)/9
	cArquivo := Substr(cCRG, (i-1)*9+1, 3)
	cCarga   := Substr(cCRG, (i-1)*9+4, 6)
	nRecCount := &(cArquivo+"->(RecCount())")
	If nRecCount!=0
		cNewCRG += cArquivo+cCarga
	EndIf
Next
If cCRG != cNewCRG
	FRTGeraSLI("    ", "CRG", cNewCRG, "SOBREPOE")
EndIf
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³FRTGravaSZ³ Autor ³ Cesar Eduardo Valadao ³ Data ³18/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os Campos do Server Local.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³07/03/06³8.11  ³BOPS 93480 - Compatibilizacao da funcionali-³±±
±±³          ³        ³      ³dade para enviar via carga arquivos com     ³±±
±±³          ³        ³      ³ALIAS que nao iniciam com a letra "S".      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTGravaSZ(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
Local aFiles:={}, cAlias, nOrder, aRet, lRet, i
Local z
Local aFilesTPL := {} // Variavel de templates
Local bMTrans := ""

Default cRPCServer 	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp     := ""
Default cRPCFilial	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Para Informar Quais Arquivos Devem Subir. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FRTGrvSZ")
	aFiles := ExecBlock("FRTGrvSZ",.F.,.F.,{oServer})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada de Templates para determinar se o Alias sera gravado na retarguada  ³
//³e posteriormente sera atualizado no BackOffice.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro())) .And. ExistTemplate("FRTGrvSZ")
	aFilesTPL := ExecTemplate("FRTGrvSZ",.F.,.F.,{oServer})
EndIf

If !Empty(aFilesTPL)
	For z := 1 To Len(aFilesTPL)
		If Empty(aFiles)
			AAdd(aFiles,{aFilesTPL[z][1], aFilesTPL[z][2]})
		ElseIf aScan(aFiles,{|x| Trim(x[1]) == Trim(aFilesTPL[z][1])}) == 0
			AAdd(aFiles,{aFilesTPL[z][1], aFilesTPL[z][2]})
		EndIf
	Next z
EndIf

If LjNfPafEcf(SM0->M0_CGC) .And. AliasInDic('MDZ') //Efetua o envio da tabela MDZ 
	If ! Select('MDZ') > 0
		DbSelectArea('MDZ')
	EndIf

	Aadd(aFiles,{"MDZ",2})
EndIf

For z := 1 To Len(aFiles)
	cAlias := aFiles[z][1]
	nOrder := aFiles[z][2]
	DbSelectArea(cAlias)
	DbSetOrder(nOrder)
	If DbSeek(xFilial(cAlias)+"00")
		aSZ := Array(FCount())
		For i := 1 To FCount()
			aSZ[i] := {FieldName(i), FieldGet(i)}
		Next
		
		If oServer <> Nil
			bMTrans := {|| oServer:CallProc("GeraSZ", cAlias, aSZ) }
			aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
        EndIf
        
		If ValType(aRet)=="A"
			If Left(aRet[1],2)=="OK"
			
				If cAlias == "MDZ" .And. aRet[2] < 1
					aSZ := {{cAlias+"_SITUA","TX"}} // "TX" - Foi Enviado ao Server
					FRTGeraSL(cAlias, aSZ, .F.)
					lRet := .T.
				Else				
					If oServer <> Nil
						bMTrans := {|| oServer:CallProc("ConfSZ", cAlias, aRet[2]) }
						lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	                EndIf
					
					If ValType(lRet)=="L"
						If Left(cAlias, 1) == "S"
							aSZ := {{Substr(cAlias,2,2)+"_SITUA","TX"}}					// "TX" - Foi Enviado ao Server
						Else
							aSZ := {{cAlias+"_SITUA","TX"}}					// "TX" - Foi Enviado ao Server
						EndIf
						FRTGeraSL(cAlias, aSZ, .F.)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³ GeraSZ   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³18/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Recebe o "pacote" de Campos do Server Local                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraSZ(cAlias, aSZ, lDecode)
Local aArea		:= GetArea()
Local nReg		:= 0
Local nSaveSx8	:= 0
Local nI		:= 0 
Local cIndex 	:= ""
Local nOrder	:= 1
Local nTent		:= 1
Local cMdzNum	:= ""
Local lGerMdz	:= .T.
Local lGerLog	:= ExistFunc("LjGrvLog")
Local cRet		:= "OK"
Local nPosLGI	:= 0		// Log de inclusao de usuario
Local nPosLGA	:= 0		// Log de alteração de usuario
Local nXMLEPAF	:= 0
Local nXMLRPAF	:= 0
Local cLogICpo:= ""
Local cLogACpo:= ""

Default lDecode	:= .F.

LjGrvLog("GeraSZ","Inicio - Gravacao da tabela:" , cAlias )

If Empty(aArea[1])
	DbSelectArea(cAlias)
EndIf

If lDecode
	//Formata campo NOMETABELA_USERLG?, Exemplo: Iniciando com "S": SLT->LT_USERLGI, caso contrário MDZ->MDZ_USERGI
	If Substr(Upper(cAlias), 1, 1) == "S"
		cLogICpo := Substr(cAlias, 2, 2) + "_USERLGI"
		cLogACpo := Substr(cAlias, 2, 2) + "_USERLGA"
	Else
		cLogICpo := cAlias + "_USERGI"
		cLogACpo := cAlias + "_USERGA"
	EndIf
	
	If (nPosLGI := AScan( aSZ, { |x| x[1] == cLogICpo  } )) > 0
		aSZ[nPosLGI][2] := Decode64(aSZ[nPosLGI][2])
	EndIf
	
	If (nPosLGA := AScan( aSZ, { |x| x[1] == cLogACpo } )) > 0
		aSZ[nPosLGA][2] := Decode64(aSZ[nPosLGA][2])
	EndIf
EndIf

//Protecao para nao gerar problema de chave duplicada
If AllTrim(cAlias) == "SLT" //LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG+LT_PDV+LT_NUMMOV
	cIndex := 	aSZ[AScan(aSZ,{|x|x[1]=="LT_FILIAL"})][2]			+;
				aSZ[AScan(aSZ,{|x|x[1]=="LT_OPERADO"})][2]			+;
				DTOS(aSZ[AScan(aSZ,{|x|x[1]=="LT_DTFECHA"})][2])	+;
				aSZ[AScan(aSZ,{|x|x[1]=="LT_FORMPG"})][2]			+;
				aSZ[AScan(aSZ,{|x|x[1]=="LT_PDV"})][2]				+;
				aSZ[AScan(aSZ,{|x|x[1]=="LT_NUMMOV"})][2]			+;
				aSZ[AScan(aSZ,{|x|x[1]=="LT_ADMIFIN"})][2]

	LjGrvLog("GeraSZ","Inicio - Gravacao da tabela SLT indice:" , cIndex )

	nOrder	:= 4
	cRet	:= "OK"

ElseIf AllTrim(cAlias) == "MDZ" 
	
	nXMLEPAF := AScan( aSZ, { |x| AllTrim(x[1]) == "MDZ_XMLEPA" } )
	nXMLRPAF := AScan( aSZ, { |x| AllTrim(x[1]) == "MDZ_XMLRPA" } )
	
	If nXMLEPAF  > 0
		aSZ[nXMLEPAF][2] := Decode64(aSZ[nXMLEPAF][2])
		If Empty(Alltrim(aSZ[nXMLEPAF][2]))
			aSZ[nXMLEPAF][2] := " "
		EndIf
	EndIf
	
	If nXMLRPAF > 0
		aSZ[nXMLRPAF][2] := Decode64(aSZ[nXMLRPAF][2])
		If Empty(Alltrim(aSZ[nXMLRPAF][2]))
			aSZ[nXMLRPAF][2] := " "
		EndIf
	EndIf

	//MDZ do Tipo "RP" não pode gravar mais de 1
	lGerMdz := LjxDGerMdz(aSZ[AScan(aSZ,{|x| x[1]=="MDZ_SIMBOL"})][2])
	If lGerMdz
		DbSelectArea("MDZ")
		nSaveSx8:= GetSx8Len()
		cMdzNum	:= GetSx8Num("MDZ","MDZ_NUM")
		While (GetSX8Len() > nSaveSx8)
			ConfirmSx8()
		End
		
		If Empty(Alltrim(cMdzNum))
			cRet := "ERRO"
		Else
			aSZ[AScan(aSZ,{|x| AllTrim(x[1])=="MDZ_NUM"})][2] := cMdzNum
			cIndex	:= 	aSZ[AScan(aSZ,{|x| AllTrim(x[1])=="MDZ_FILIAL"})][2]+;
						aSZ[AScan(aSZ,{|x| AllTrim(x[1])=="MDZ_NUM"})][2]
			nOrder	:= 5
			cRet	:= "OK"
			LjGrvLog(Nil,"MDZ_NUM = " + cMdzNum)
		EndIf
	Else
		cRet := ""
	EndIf

EndIf

If cRet == "" .And. !lGerMdz
	//Tabela MDZ - Retorno ok para remover o 00 do situa do pdv mas a tabela não foi gravada na ret
	nReg := -1
	cRet := "OK"
	
ElseIf cRet == "OK"
	DbSelectArea(cAlias)
	DbSetOrder(nOrder)	// Tratamento para verificar se o registro ja existe
	If Empty(cIndex) .OR. !DbSeek(cIndex)		
		BEGIN TRANSACTION
			FRTGeraSL(cAlias, aSZ, .T.)
		END TRANSACTION
		nReg := &(cAlias+"->(Recno())")
		
		If cAlias == "MDZ"
			nI := AScan( aSZ, { |x| AllTrim(x[1]) == "MDZ_PAFMD5" } )
			If nI > 0 .And. !Empty(AllTrim(aSZ[nI][2]))
				RecLock("MDZ",.F.)
				REPLACE MDZ->MDZ_PAFMD5 WITH STxPafMd5("MDZ")
				MDZ->(MsUnlock())
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Else	
	Iif(lGerLog,LjGrvLog("","Não Foi possível Incluir o registro  na Tabela " + cAlias),NIL)
	ConOut("Não Foi possível Incluir o registro  na Tabela " + cAlias)
EndIf

Return ({cRet,nReg})

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³ ConfSZ   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³18/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma a Gravacao dos Campos do Server Local.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andrea F. ³07/03/06³8.11  ³BOPS 93480 - Compatibilizacao da funcionali-³±±
±±³          ³        ³      ³dade para enviar via carga arquivos com     ³±±
±±³          ³        ³      ³ALIAS que nao iniciam com a letra "S".      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ConfSZ(cAlias, nRecno)
&(cAlias+"->(DbGoto("+AllTrim(Str(nRecno,10,0))+"))")

If Left(cAlias, 1) == "S"
	FRTGeraSL(cAlias, {{Substr(cAlias,2,2)+"_SITUA", "RX"}})				// "RX" - Foi Recebido Pelo Server
Else
	FRTGeraSL(cAlias, {{cAlias+"_SITUA", "RX"}})				// "RX" - Foi Recebido Pelo Server
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTGravaFIºAutor  ³ Cesar E. Valadao    º Data ³  16/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os campos do Server Local.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Front Loja                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLuiz Couto³07/09/05³8.11  ³- Implementacao continua: padronizacao de    º±±
±±º          ³        ³      ³fontes.                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTGravaFI(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

Local i		:= 0				//Variavel de apoio
Local nI	:= 0
Local aSFI	:= {}				//Array com os campos do SFI
Local aRet	:= {}				//Retorno do RPC GeraSFI
Local lRet	:= .T.				//Retorno do RPC ConfSFI
Local bMTrans := ""

Default cRPCServer 	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""

DbSelectArea( "SFI" )
DbSetOrder( 2 )		//FI_FILIAL+FI_SITUA

If MsSeek( xFilial() + "00" )
	nI := FCount()
	aSFI := Array( nI )

	For i := 1 To nI
		aSFI[i] := { FieldName( i ), FieldGet( i ) }
	Next
	If oServer <> Nil
		bMTrans := {|| oServer:CallProc( "GeraSFI", aSFI ) }
		aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
    EndIf

	If ValType( aRet ) == "A"
		If Left( aRet[1], 2 ) == "OK"
			If oServer <> Nil
				bMTrans := {|| oServer:CallProc( "ConfSFI", aRet[2] ) }
				lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
            EndIf

			If ValType( lRet ) == "L"
				aSFI := { { "FI_SITUA", "TX" } }					// "TX" - Foi Enviado ao Server
				FRTGeraSL( "SFI", aSFI, .F. )
			EndIf
		EndIf
	EndIf
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GeraSFI   ºAutor  ³ Cesar E. Valadao    º Data ³  16/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recebe o "pacote"de campos do Server Local.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1: Array com os campo do SFI                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Front Loja                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLuiz Couto³07/09/05³8.11  ³- Implementacao continua: padronizacao de    º±±
±±º          ³        ³      ³fontes.                                      º±±
±±ºLuiz Couto³07/09/05³8.11  ³- BOPS 86124: Area SFI selecionada para o    º±±
±±º          ³        ³      ³correto funcionamento do BEGIN TRANSACTION.  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraSFI( aSFI, lDecode )
Local dFI_DTMOVTO 	:= aSFI[AScan( aSFI, { |x| x[1] == "FI_DTMOVTO" } )][2]			//Data do Movimento
Local cFI_PDV     	:= aSFI[AScan( aSFI, { |x| x[1] == "FI_PDV" } )][2]				//Numero do PDV
Local nPosFINum    	:= AScan( aSFI, { |x| x[1] == "FI_NUMERO" } )						//Numero do PDV
Local nSaveSx8		:= 0																	//Ultimo numero do SX8
Local lAppend		:= .T.																	//Variavel de controle de inclusao ou alteracao
Local lGerInte 		:= SuperGetMV("MV_LJGRINT",.F. ,.F.)								//Verifica se a integracao esta habilitada
Local nPosLGI		:= 0																	//Log de inclusao de usuario
Local nPosLGA		:= 0																	//Log de alteração de usuario
Local nXMLEPAF		:= 0
Local nXMLRPAF		:= 0
Local nI			:= 0

Default lDecode		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o numero da reducao Z com a sequencia da retaguarda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPosFINum > 0
	nSaveSx8 :=	GetSX8Len() //Captura o Len para verificar se houve alteração do Número da Redução (FI_NUMERO)
	aSFI[nPosFINum][2]	:= LJ200NUM(dFI_DTMOVTO)

	If GetSX8Len() > nSaveSx8 //Caso seja uma redução nova, confirma o número da redução e evita que o número se repita.
		ConfirmSX8()
	EndIf
EndIf

If lDecode
	If (nPosLGI := AScan( aSFI, { |x| x[1] == "FI_USERLGI" } )) > 0
		aSFI[nPosLGI][2] := Decode64(aSFI[nPosLGI][2])
	EndIf
	
	If (nPosLGA := AScan( aSFI, { |x| x[1] == "FI_USERLGA" } )) > 0
		aSFI[nPosLGA][2] := Decode64(aSFI[nPosLGA][2])
	EndIf
EndIf

//Campos Memo
nXMLEPAF := AScan( aSFI, { |x| x[1] == "FI_XMLEPAF" } )
nXMLRPAF := AScan( aSFI, { |x| x[1] == "FI_XMLRPAF" } )

If nXMLEPAF > 0
	aSFI[nXMLEPAF][2] := Decode64(aSFI[nXMLEPAF][2])
	If Empty(AllTrim(aSFI[nXMLEPAF][2]))
		aSFI[nXMLEPAF][2] := " "
	EndIf	
EndIf

If nXMLRPAF > 0
	aSFI[nXMLRPAF][2] := Decode64(aSFI[nXMLRPAF][2])
	If Empty(AllTrim(aSFI[nXMLRPAF][2]))
		aSFI[nXMLRPAF][2] := " "
	EndIf
EndIf

/*Se nao existe o registro ADICIONA, caso contrario SOBREPOE a informacao gravada*/
DbSelectArea( "SFI" )
SFI->(DbSetOrder( 1 ))		//FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ

lAppend := !( MsSeek( xFilial( "SFI" ) + DToS( dFI_DTMOVTO ) + cFI_PDV ) )

BEGIN TRANSACTION

	FRTGeraSL( "SFI", aSFI, lAppend )

END TRANSACTION

nI := AScan( aSFI, { |x| AllTrim(x[1]) == "FI_PAFMD5" } )
If nI > 0 .And. !Empty(AllTrim(aSFI[nI][2]))
	RecLock("SFI",.F.)
	REPLACE SFI->FI_PAFMD5 WITH STxPafMd5("SFI")
	SFI->(MsUnlock())
EndIf

If lGerInte
	FRT20InSFI("SFI", xFilial( "SFI" ) + DToS( dFI_DTMOVTO ) + cFI_PDV)
EndIf

Return ( { "OK", SFI->( Recno() ) } )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³ ConfSFI  ³ Autor ³ Cesar Eduardo Valadao ³ Data ³16/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma a Gravacao dos Campos do Server Local.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ConfSFI(nRecno)
SFI->(DbGoto(nRecno))
FRTGeraSL("SFI", {{"FI_SITUA", "RX"}})				// "RX" - Foi Recebido Pelo Server
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ FRTCloseServices   ³ Autor ³ Fabio / Andre ³ Data ³18/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fecha todos os jobs para poder fechar o servidor.          ³±±
±±³          ³ (Controle criado para quando o TwoTier estiver habilitado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FrtCloseServices()                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTCloseServices()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente fecha os servicos (Jobs) se for TwoTier.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(GetPvProfString("Config", "TwoTier", "0", Left(GetAdv97(),3)+"RMT.INI")) == "1"
	LjMsgRun(STR0040,,{|| ProcCloseServices(),CLR_HRED } ) // Aguarde, fechando servicos de sincronizacao ...
EndIf
Final(STR0041)	//"T‚rmino Normal"

Return NIL
                          
Static Function ProcCloseServices()
MSFCreate( "STOPFRT.LCK" )
While !File("FRTCS.LCK")
	Sleep(3000)
	SysRefresh()
End
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ FRTAtuCRG³ Autor ³ Cesar Eduardo Valadao ³ Data ³05/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a atualizacao de todas as tabelas no Check-Out.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTAtuCRG(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
Local lLockOk := .F.
Local i, aFiles
Local bMTrans := ""

Default cRPCServer 	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Check-Out estiver no ar, aguarda ele fechar as tabelas... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FRTSemaStat("OPE", LI_ESTACAO)
	lLockOk := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enviar comando para o Check-Out Parar a operacao e fechar as tabelas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// "Front Loja: Enviando solicitacao para o Check-Out fechar as tabelas..."
	ConOut(STR0044)
	FRTGeraSLI(cEstacao, "COM", "CLOSE FILES", "SOBREPOE")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguardar o fechamento dos arquivos no Check-Out. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While .T.
		SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"COM"))
		If Left(SLI->LI_MSG,8)=="CLOSE OK"
			Exit
		EndIf
	End
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechar, Abrir Exclusivo, Zap, Fechar, Abrir Compartilhado... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFiles := FRTArquivos()
For i := 1 To Len(aFiles)
	#IFNDEF TOP
		&(aFiles[i]+"->(dbCloseArea())")						// Fecho
		If ChkFile(aFiles[i], .T.)								// Abro exclusivo
			DbSelectArea(aFiles[i])
			Zap													// Limpo
		Else
			// "Front Loja: Nao foi possivel a abertura exclusiva do arquivo "
			ConOut(STR0045+aFiles[i]+"...")
		EndIf
		&(aFiles[i]+"->(dbCloseArea())")						// Fecho
		If !ChkFile(aFiles[i])									// Abro compartilhado
			// "Front Loja: Nao foi possivel a reabertura do arquivo "
			ConOut(STR0046+aFiles[i]+"...")
		EndIf
	#ELSE
		TCSQLEXEC("DELETE FROM "+RetSqlName(aFiles[i]))
	#ENDIF
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zerar a Protocolo de Carga "CRG" e Recebe-las ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTGeraSLI("    ", "CRG", "", "SOBREPOE")
If oServer <> Nil
	bMTrans := {|| oServer:CallProc("FRTChkCarga", Val(cEstacao), SLI->LI_MSG) }
	aCargaOK := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
EndIf
If Len(aCargaOK) > 0
	FRTBaixa()
	FRTGeraSLI("    ", "LCK", "", "SOBREPOE")
EndIf
If lLockOk
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enviar comando para o Check-Out Retornar a operacao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTGeraSLI(cEstacao, "COM", "OPEN FILES", "SOBREPOE")
Else
	FRTGeraSLI(cEstacao, "COM", "", "SOBREPOE")
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ FRTGrvSPF³ Autor ³ Cesar Eduardo Valadao ³ Data ³23/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza as senhas do usuario (SIGAPSS.SPF)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTGrvSPF(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
Local lLockOk	:= .F.
Local bMTrans	:= ""
Local lSigaPssOk:= .F.	//Indica que o sigapss.spf foi atualizado com sucesso

Default cRPCServer	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""

conout(STR0049)		// "Front Loja: Iniciando a atualizacao das Senhas..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Check-Out estiver no ar, aguarda ele fechar o SIGAPSS.SPF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FRTSemaStat("OPE", LI_ESTACAO)
	lLockOk := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enviar comando para o Check-Out Parar a operacao e fechar as tabelas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	conout(STR0068)		// "Front Loja: Enviando solicitacao para o Check-Out fechar o arquivo de senhas..."

	// faz a solicitacao de fechamento do SIGAPSS.SPF, que eh realizado pela funcao FR271HAtuSPF
	FRTGeraSLI(cEstacao, "PSS", "CLOSE SPF", "SOBREPOE")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguardar o fechamento do SIGAPSS.SPF no Check-Out. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While .T.
		SLI->( DbSeek(xFilial("SLI") + PadR(cEstacao,4) + "PSS") )
		If AllTrim(SLI->LI_MSG) == "SPF CLOSED"
			Exit
		EndIf		
	End
EndIf

If PSWGetSinc(oServer)
	If oServer <> Nil
		bMTrans := {|| oServer:CallProc("FRTTXSX5") }
		aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
    EndIf

	If ValType(aRet) == "A"	
		FRTRXSX5(aRet)		
		FRTGeraSLI(cEstacao, "PSS", "", "SOBREPOE")		
		conout(STR0050)		// "Front Loja: Atualizacao das Senhas finalizada."
		lSigaPssOk := .T.
	Else
		conout(STR0052)		// "Front Loja: Erro ao finalizar a atualizacao do arquivo de Senhas."
		FRTGeraSLI(cEstacao, "PSS", "SPF NOK", "SOBREPOE")
	EndIf
Else
	conout(STR0052)	// "Front Loja: Erro ao finalizar a atualizacao do arquivo de Senhas."
	FRTGeraSLI(cEstacao, "PSS", "SPF NOK", "SOBREPOE")
EndIf

If lLockOk .AND. lSigaPssOk
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enviar comando para o Check-Out Retornar a operacao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//indica que o arquivo SIGAPSS.SPF foi sincronizado com sucesso
	FRTGeraSLI(cEstacao, "PSS", "SPF OK", "SOBREPOE")
Else
	FRTGeraSLI(cEstacao, "PSS", "", "SOBREPOE")
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FRTGrvSx5 ³ Autor ³ Vendas CRM		    ³ Data ³05/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza determinada tabeela do SX5 						  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FRTGrvSx5(cExp1,cExp2,cExp3,cExp4;	  					  ³±±
±±³			 ³					cExp5,cExp6,cExp7)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Servidor											  ³±±
±±³			 ³cExp2 - Porta						  						  ³±±
±±³			 ³cExp3 - Ambiente											  ³±±
±±³			 ³cExp4 - Valor da recarga									  ³±±
±±³			 ³cExp5 - Empresa                  							  ³±±
±±³			 ³cExp6 - Filial											  ³±±
±±³			 ³cExp7 - Tabela do SX5 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³FRTA020												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FRTGrvSx5(cRPCServer,	nRPCPort,cRPCEnv,cRPCEmp,;
							cRPCFilial,	cTabSx5)

Local lLockOk := .F.		//Informa se o arquivo esta em Lock 
Local bMTrans := ""			//Bloco que sera executado na transacao via RPC

Default cRPCServer	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""
Default cTabSx5		:= ""

If Empty(cTabSx5)
	Return Nil
EndIf

ConOut("Front Loja: " + STR0116 + " - " + STR0117 + " " + cTabSx5)//"Iniciando a atualizacao do arquivo SX5"#"Tabela"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Check-Out estiver no ar, aguarda ele fechar o SIGAPSS.SPF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FRTSemaStat("OPE", LI_ESTACAO)
	lLockOk := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enviar comando para o Check-Out Parar a operacao e fechar a tabela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// "Front Loja: Enviando solicitacao para o Check-Out fechar as tabelas..."
	ConOut(STR0044)
	FRTGeraSLI(cEstacao, cTabSx5, "CLOSE " + cTabSx5, "SOBREPOE")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguardar o fechamento do SIGAPSS.SPF no Check-Out. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While .T.
		SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+cTabSx5))
		If Left(SLI->LI_MSG,10)==cTabSx5 + " CLOSED"
			Exit
		EndIf
	End
EndIf
If PSWGetSinc(oServer)
	If oServer <> Nil
		bMTrans := {|| oServer:CallProc("FRTTXSX5R5",cTabSx5) }
		aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
    EndIf
	If ValType(aRet) == "A"		
		ConOut("Front Loja:" + STR0118 + " - " + STR0117 + " " + cTabSx5 + " ... ")//"Atualizando arquivo SX5"#"Tabela"		
		If FRTRXSX5R5(aRet,cTabSx5)					
			FRTGeraSLI(cEstacao, cTabSx5, "", "SOBREPOE")
			ConOut("Front Loja:" + STR0119 + " - " + STR0117 +  " - " + cTabSx5  + " " + STR0120 +  ".")//"Atualizacao do arquivo SX5"#"Tabela"#"concluida"			
		Else
			ConOut("Front Loja: " + STR0121 + " - " +  STR0117 + cTabSx5)//"Erro ao finalizar a atualizacao do arquivo SX5"#Tabela"
			Return(NIL)		
		EndIf
	Else
   		ConOut("Front Loja: " + STR0121 + " - " +  STR0117 + cTabSx5)//"Erro ao finalizar a atualizacao do arquivo SX5"#Tabela"
		Return(NIL)
	EndIf
Else
	ConOut("Front Loja: " + STR0121 + " - " +  STR0117 + cTabSx5)//"Erro ao finalizar a atualizacao do arquivo SX5"#Tabela"
	Return(NIL)
EndIf
If lLockOk
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enviar comando para o Check-Out Retornar a operacao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTGeraSLI(cEstacao, cTabSx5, "SX5 OK", "SOBREPOE")
Else
	FRTGeraSLI(cEstacao, cTabSx5, "", "SOBREPOE")
EndIf
Return(NIL)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTVerUserºAutor  ³Vendas Clientes     º Data ³  12/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe usuário logado no sistema				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTVerUser()
Local aUsers 	:= Getuserinfoarray()	//Informacoes do sistema
Local nLoop		:= 0					//Contador

For nLoop := 1 to Len(aUsers)
	If aUsers[nLoop][5] == "SIGAFRT"
		If At(aUsers[nLoop][11], "FRT010") > 0 .OR. At(aUsers[nLoop][11], "FRT271") > 0
			Return .T.
		Endif
	Endif
Next nLoop

Return .F.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GeraSLX   ºAutor  ³ Vendas Clientes     º Data ³  18/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recebe o "pacote" de log do Server Local.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpA1: Array com os campo do SLX                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Front Loja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GeraSLX( aSLX, lDecode )
Local nReg						//Recno do SLX
Local nPosPDV	:= AScan( aSLX, { |x| x[1] == "LX_PDV" 	} )
Local nPosCup	:= AScan( aSLX, { |x| x[1] == "LX_CUPOM" 	} )
Local nPosSer	:= AScan( aSLX, { |x| x[1] == "LX_SERIE" 	} )
Local nPosItem	:= AScan( aSLX, { |x| x[1] == "LX_ITEM" 	} )
Local nPosHora	:= AScan( aSLX, { |x| x[1] == "LX_HORA" 	} )
Local nPosFil  	:= AScan( aSLX, { |x| x[1] == "LX_FILIAL" } )
Local nPosLGI	:= 0
Local nPosLGA	:= 0
Local aRet		:= {}
Local lProssegue:= .T.

Default lDecode	:= .F.

aSLX[AScan( aSLX, { |x| x[1] == "LX_SITUACA" } )][2]	 := "OK"		// "TX" - Foi Processado no Server

DbSelectArea( "SLX" )
DbSetOrder( 1 ) // LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM
If DbSeek(aSLX[nPosFil][2]+aSLX[nPosPDV][2]+aSLX[nPosCup][2]+aSLX[nPosSer][2]+aSLX[nPosItem][2])
	While !Eof() .AND. (SLX->LX_FILIAL + SLX->LX_PDV+SLX->LX_CUPOM+SLX->LX_SERIE+SLX->LX_ITEM ==;
					    aSLX[nPosFil][2]+aSLX[nPosPDV][2]+aSLX[nPosCup][2]+aSLX[nPosSer][2]+aSLX[nPosItem][2]) 

	    If AllTrim(SLX->LX_HORA) == AllTrim(aSLX[nPosHora][2])
	    	aRet := { "OK", SLX->( Recno() ) }
			lProssegue := .F.
			Exit
		EndIf	
		SLX->(DbSkip())
	End
EndIf

If lProssegue
	If lDecode
		If (nPosLGI := AScan( aSLX, { |x| x[1] == "LX_USERLGI" } )) > 0
			aSLX[nPosLGI][2] := Decode64(aSLX[nPosLGI][2])
		EndIf

		If (nPosLGA := AScan( aSLX, { |x| x[1] == "LX_USERLGA" } )) > 0
			aSLX[nPosLGA][2] := Decode64(aSLX[nPosLGA][2])
		EndIf
	EndIf
	
	BEGIN TRANSACTION
	
	FRTGeraSL( "SLX", aSLX, .T. )
	
	END TRANSACTION
	
	nReg := SLX->( Recno() )
	
	aRet := { "OK", nReg }
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³ConfSLX   ³ Autor ³ Vendas Clientes       ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma a Gravacao do SLX.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ConfSLX()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
d±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ConfSLX(nRecno, aSLX)

Local nPosTpCan := 0
Local nPosSit	  := 0

Default aSLX := {}

DbSelectArea("SLX")
DbGoto(nRecno)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Confirma o SLX ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMv("MV_LJRMBAC", NIL, .F.) .And. Len(aSLX) > 0 //Esta ativa a integração com RM?
	nPosTpCan := aScan(aSLX, {|x| x[1] == "LX_TPCANC"})
	nPosSit   := aScan(aSLX, {|x| x[1] == "LX_SITUA"})

	FRTGeraSL("SLX", {{"LX_SITUACA"	, "OK"},;
						{"LX_TPCANC"	, aSLX[nPosTpCan][2]},;
					 	{"LX_SITUA"	, aSLX[nPosSit][2]}})
Else
	FRTGeraSL("SLX", {{"LX_SITUACA", "OK"}})	// "OK" - Foi Processado Pelo Server
EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtKillApp³ Autor ³ Vendas Clientes       ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna se a thread recebeu uma chamada para ser finalizada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtKillApp()

Local lRet := .F.

If KillApp()
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtDadoRpc³ Autor ³ Vendas Clientes       ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que controla o balanceamento do RPC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtDadoRpc(nTentativa)

Local aRet := {}
Local cFile := GetPvProfString("RPC","NumeroServers","","RPCFRONT.INI")
Local nNumServers := 0
Local nUltimoServ := 0

DEFAULT nTentativa:= 0

aRet := LjGetStation({"RPCSRV", "RPCPORT", "RPCENV", "RPCEMP", "RPCFIL", "RPCINT"})
	
If !Empty(cFile)

	nNumServers := Val(GetPvProfString("RPC", "NumeroServers", "1", "RPCFRONT.INI"))
	nUltimoServ := Val(GetPvProfString("RPC", "UltimoServer", "0", "RPCFRONT.INI"))  
	
	If nNumServers > 0
	    
		nTentativa:= nNumServers
		
		If nNumServers == nUltimoServ
			nUltimoServ := 1
		Else
			nUltimoServ++
		EndIf
	    
			aRet[1]	:= GetPvProfString("SERVER" + AllTrim(Str(nContCon+1)), "IP", aRet[1], "RPCFRONT.INI")
			aRet[2]	:= GetPvProfString("SERVER" + AllTrim(Str(nContCon+1)), "PORTA", aRet[2], "RPCFRONT.INI")
			WritePProString("RPC", "UltimoServer", AllTrim(Str(nContCon+1)), "RPCFRONT.INI")				
			nContCon++
			
			If nTotCon == nContCon
				nContCon := 0
			EndIf

	EndIf 
		
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrRpc020Con³ Autor ³ Vendas Clientes      ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma a Gravacao do SLX.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ConfSLX()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrRpc020Con(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

Default cRPCServer 	:= ""
Default nRPCPort   	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""

If ValType(oServer) != "O"
	CREATE RPCCONN oServer ON SERVER cRPCServer ;
		PORT nRPCPort ;
		ENVIRONMENT cRPCEnv ;
		EMPRESA cRPCEmp ;
		FILIAL cRPCFilial ;              
		TABLES "SLI", "SL1", "SL2", "SL4", "SE5", "SFI", "SLX";
		MODULO "LOJA"
EndIf

Return oServer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FrtExecCall ³ Autor ³ Vendas Clientes     ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ 								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FrtExecCall()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FrtExecCall(bExecCall,lReturnRPC,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

Local xValue								// Retorno da execucao da funcao
Local bOldError								// Bloco de execucao caso ocorra error
Local lErro  		:= .F.					// Controle de Erro
Local nRetry		:= 1					// Tentativas de Conexao
Local nRetryRPC		:= 1					// Tentativas de Conexao com o RPC
Local lProcessou 	:= oServer == Nil		// Verifica se o Objeto esta Instanciado
Local lSleep		:= .F.					// Executa a Funcao SLEEP
Local lFwRpc    	:= SuperGetMV("MV_LJFWRPC",,.T.)	//Indica se utiliza controle de serie automatica

Default bExecCall 	:= ""					// Bloco a ser executado
Default lReturnRPC 	:= .F.					// Retorno Logico do RPC
Default cRPCServer	:= ""					// Ip do Servidor
Default nRPCPort	:= 0					// Porta do Servidor
Default cRPCEnv		:= ""					// Ambiente de Conexao com a Retaguarda
Default cRPCEmp		:= ""   				// Empresa 
Default cRPCFilial	:= ""					// Filial da empresa 

If lFwRpc
	If !(lEndThread)
		If lConnect
			//"Executa o CallProc"
			xValue := Eval(bExecCall)
			If xValue == Nil
				lEndThread := .T.
				lAltThread := .T.
				lConnect := .F.
				Conout(STR0073)	//"**** ERRO NO PROCESSAMENTO DO RPC ****"
				Conout(STR0074)	//" Possiveis motivos: "
				Conout(STR0085)	//" A) Houve um erro no processamento do RPC (ex: registro), ocasionando a queda;"
				Conout(STR0076)	//" B) O Servidor da Retaguarda esta fora do ar."
				Conout(STR0077)	//" O RPC tentara se comunicar novamente!"
				Sleep(1000)
			EndIf   
		EndIf	
	EndIf	
Else
	While nRetry <= 2 .AND. !(lProcessou)
	
		bOldError := ErrorBlock( {|x| lErro := .T. , LjVerifErro(x) } ) // muda code-block de erro
		
		Begin Sequence                      
			lProcessou := .T.
	
			xValue := Eval(bExecCall)
	
			If lErro .OR. (lReturnRPC .AND. xValue == Nil )
				Break
			EndIf
		Recover
			Conout(STR0073)	//"**** ERRO NO PROCESSAMENTO DO RPC ****"
			Conout(STR0074)	//" Possiveis motivos: "
			Conout(STR0085)	//" A) Houve um erro no processamento do RPC (ex: registro), ocasionando a queda;"
			Conout(STR0076)	//" B) O Servidor da Retaguarda esta fora do ar."
			Conout(STR0077)	//" O RPC tentara se comunicar novamente!"
			oServer := Nil
		
			If !(lErro) .AND. xValue == Nil
	        
				lProcessou := .F.
				Conout(STR0078)				//"O RPC tentara se comunicar por tres vezes:"
				While oServer == Nil .AND. nRetryRPC <= 3
	
					Conout(STR0079 + Alltrim(Str(nRetryRPC))) //"Tentativa "
	
					oServer := FrRpc020Con(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
					nRetryRPC := nRetryRPC + 1
					lSleep := .T.
					
					If oServer <> Nil
						Conout(STR0080)//"Conexão realizada com sucesso"
						Conout(STR0081)//"Tentara executara o processo novamente..."
					EndIf
				EndDo                     			
			EndIf
			
			lErro := .F.
		End Sequence
		
		ErrorBlock(bOldError)
	
		If lSleep
			Sleep(3000)
			lSleep := .F.
		EndIf
		nRetry := nRetry + 1
	End
EndIf 

Return xValue

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTPegaOrc ³ Autor ³ Vendas Clientes      ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que localiza no PDV as vendas que ficaram    		  ³±±
±±³ 		 ³ como "ER" ou "EP"  , para mandalas para a retaguarda	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTPegaOrc(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

Local aArea   	:= GetArea()
Local nI	  	:= 0                                 
Local cTipo   	:= ""   
Local bMTrans 	:= ""
Local cNumOrc 	:= ""
	
DEFAULT cRPCServer 	:= ""
DEFAULT nRPCPort  	:= 0
DEFAULT cRPCEnv		:= ""
DEFAULT cRPCEmp		:= ""
DEFAULT cRPCFilial	:= ""

cTipo := "RE" // foi tentado processar duas vezes
	
DbSelectArea("SL1")
DbSetOrder(9) 			//L1_FILIAL+L1_SITUA+L1_PDV+L1_DOC -- Situacao + Numero PDV + Nota Fiscal
If DbSeek(xFilial("SL1")+cTipo)
	While !EOF() .AND. xFilial("SL1") == SL1->L1_FILIAL .AND. SL1->L1_SITUA == cTipo
		If SL1->L1_EMISNF >= dDatabase - 3
			If oServer <> Nil
				cTipo := "RR" // foi tentado processar duas vezes
				bMTrans := {|| oServer:CallProc("FRTGrvLOG", SL1->L1_ESTACAO, SL1->L1_NUM , SL1->L1_FILIAL,;
				cTipo          ,SL1->L1_EMISNF,SL1->L1_STATUS) }
				FrtExecCall(bMTrans,.F.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

				Conout( " **** Orçamento gravada como 'RR' na MDI-Retaguarda" )	
				RecLock("SL1",.F.)
				SL1->L1_SITUA := cTipo  // "RR" - Orcamento Gravado na MDI Retaguarda
				SL1->(MsUnlock())	       																					
				
			EndIf
		EndIf
		SL1->(DbSkip())
	End
EndIf

RestArea(aArea)	

Return NIL      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTGrvLOG	 ³ Autor ³ Vendas Clientes      ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao que efetua a gravacao das vendas que ficaram    	  ³±±
±±³ 		 ³ como "ER" ou "EP" no PDV , as mesmas serão gravadas   	  ³±±
±±³ 		 ³ em um novo ALIAS (MDI)                                	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTGrvLOG(cEstacao, cNumOrc, cRPCFil, cSituaca, dEmisNF, cStatus)

Local lExistMDI := AliasInDic("MDI")

DEFAULT cNumOrc		:= ""
DEFAULT cEstacao	:= ""
DEFAULT dEmisNF     := CTOD("  /  /  ")
DEFAULT cSituaca	:= ""
DEFAULT cStatus 	:= ""

If lExistMDI
	DbSelectArea("MDI")
	DbSetOrder(1)		//MDI_FILIAL+MDI_NUMORC+MDI_ESTACA+MDI_SITUA
	If !DbSeek(xFilial("MDI") + cNumOrc + cEstacao + cSituaca)
		Reclock("MDI", .T.)
		REPLACE MDI_FILIAL  	WITH xFilial("MDI")
		REPLACE MDI_NUMORC  	WITH cNumOrc
		REPLACE MDI_ESTACA 		WITH cEstacao
		REPLACE MDI_EMISS	  	WITH dEmisNF
		REPLACE MDI_SITUA 		WITH cSituaca
		REPLACE MDI_STATUS 		WITH cStatus
		MsUnlock()
	EndIf
EndIf
		
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTCheckNcc³ Autor ³ Vendas Clientes      ³ Data ³18/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se exite alguma NCC que nao pode				  ³±±
±±³ 		 ³ ser baixada/estornada no momento da venda e vai ser	 	  ³±±
±±³ 		 ³ baixada/estornada automaticamente                    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTCheckNcc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTCheckNcc(oServer,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

Local aArea   	 	:= GetArea()
Local cSitua   	 	:= "NP"   
Local aMDK	 	:= {}
Local lNccOff   := SuperGetMV("MV_LJNCCOF",,.T.)
Local bMTransTit:= "" 
Local lRet		:= .F.
Local aMDJ		:= {}
Local nRecMDJ	:= 0
Local cSerEst	:= LjGetStation("LG_SERIE")
Local nProtec	:= 1
Local cSituMDJ	:= "OK"

Default oServer		:= Nil
Default cRPCServer	:= ""	
Default nRPCPort	:= 0	
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""

If AliasIndic("MDJ") .AND. AliasIndic("MDK") .AND. lNccOff
	DbSelectArea("MDJ")
	DbSetOrder(2) 			//MDJ_FILIAL+MDJ_SITUA
	// Procura algum registro pendente
	If DbSeek(xFilial("MDJ")+cSitua) 
		LjGrvLog("FRTA020","ENCONTRO UM REGISTRO NA MDJ COMO NAO PROCESSADO")
		While !MDJ->(EOF()) .AND. (xFilial("MDJ") == MDJ->MDJ_FILIAL) .AND. (MDJ->MDJ_SITUA == cSitua) .AND. nProtec < 10
			nProtec++
			aMDK := {}	
			// Procura os itens da NCC
			FrtGerMDK(MDJ->MDJ_FILIAL + MDJ->MDJ_DOC + MDJ->MDJ_SERIE + MDJ->MDJ_CLIENT + MDJ->MDJ_LOJA,@aMDK)

	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Alimenta variaveis estaticas que seram utilizadas posteriormente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aMDK) > 0 .And. MDJ->MDJ_OPER <> "R"
				Frt060Alt("NCC_ITENS" ,aMDK )
				Frt060Alt("NCC_USADA" ,MDJ->MDJ_NCCUSA)   
				Frt060Alt("NCC_GERADA",MDJ->MDJ_NCCGER)
				//Verifica qual vai ser a operacao
				If MDJ->MDJ_OPER == "B"    

					// Chama a funcao para a baixa da NCC                   
					Frt060BxNCC(MDJ->MDJ_DOC	,MDJ->MDJ_SERIE	,MDJ->MDJ_OPERAD,MDJ->MDJ_EMIS,;
								MDJ->MDJ_CLIENT	,MDJ->MDJ_LOJA	,MDJ->MDJ_CREDIT, NIL		   ,;
								NIL				, .T.			,MDJ->MDJ_NUMORC)
				EndIf
			ElseIf MDJ->MDJ_OPER == "E"    	
				// Chama a funcao de estorno de NCC
				Frt060ExNCC(MDJ->MDJ_FILIAL,MDJ->MDJ_DOC,MDJ->MDJ_SERIE,MDJ->MDJ_CLIENT,;
							MDJ->MDJ_LOJA  , .T.		,MDJ->MDJ_NUMORC)
			ElseIf MDJ->MDJ_OPER == "I" .OR. MDJ->MDJ_OPER == "R"
				If oServer <> Nil
					If MDJ->MDJ_OPER == "R" .And. !Empty(LjGetStation("LG_SERNFIS"))
						cSerEst	:= LjGetStation("LG_SERNFIS")						
						LjGrvLog("Recarga Cel.","Valor da variavel  cSerEst :"+ cSerEst )
					EndIf
			   		bMTransTit := {|| oServer:CallProc("LJGerTitNV", 	MDJ->MDJ_DOC	,MDJ->MDJ_SERIE		,MDJ->MDJ_OPERAD	,MDJ->MDJ_DTVAL,;
			   															MDJ->MDJ_CREDIT	,MDJ->MDJ_CLIENT	,MDJ->MDJ_LOJA		,Iif(MDJ->MDJ_OPER == "I", NIL, cSerEst),;
			   															MDJ->MDJ_EMIS	,MDJ->MDJ_OPER		, aMDK)}
			   																				   															
					lRet := FrtExecCall(bMTransTit,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
					If lRet	<> NIL
						If !lRet 
							cSituMDJ := "ER"
						EndIf 
						RecLock("MDJ",.F.)
						REPLACE MDJ_SITUA WITH cSituMDJ
						MDJ->(MsUnlock())					
					EndIf                             	
	       		EndIf
			EndIf  
       		MDJ->(DbSkip())
			Sleep(300)	
	    End
	ElseIf DbSeek(xFilial("MDJ")+"ER") 
		LjGrvLog("FRTA020","GRAVOU A MDJ COMO ER")
		aMDJ		:= {}
		Aadd(aMDJ,{"MDJ_FILIAL"  	,MDJ->MDJ_FILIAL})
		Aadd(aMDJ,{"MDJ_DOC"  	 	,MDJ->MDJ_DOC	}) 				
		Aadd(aMDJ,{"MDJ_SERIE"   	,MDJ->MDJ_SERIE	})
		Aadd(aMDJ,{"MDJ_CLIENT" 	,MDJ->MDJ_CLIENT})
		Aadd(aMDJ,{"MDJ_LOJA"  	 	,MDJ->MDJ_LOJA	})
		Aadd(aMDJ,{"MDJ_OPERAD" 	,MDJ->MDJ_OPERAD})
		Aadd(aMDJ,{"MDJ_EMIS"   	,MDJ->MDJ_EMIS	})
		Aadd(aMDJ,{"MDJ_NCCUSA"  	,MDJ->MDJ_NCCUSA})
		Aadd(aMDJ,{"MDJ_NCCGER" 	,MDJ->MDJ_NCCGER})
		Aadd(aMDJ,{"MDJ_CREDIT"  	,MDJ->MDJ_CREDIT})
		Aadd(aMDJ,{"MDJ_NUMORC" 	,MDJ->MDJ_NUMORC})
		Aadd(aMDJ,{"MDJ_OPER"  		,MDJ->MDJ_OPER	})
		Aadd(aMDJ,{"MDJ_SITUA" 		,"RR"			})
		nRecMDJ	:= Recno()
		
		If oServer <> Nil
			bMTrans := {|| oServer:CallProc( "FrtGrNCCEr", aMDJ) }
			lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
	    EndIf
		If ValType(lRet) == "L" .AND. lRet	    
			DbSelectArea("MDJ")
			DbGoTo(nRecMDJ)
			RecLock("MDJ",.F.)
			REPLACE MDJ_SITUA WITH "RR"
			MsUnlock()		
		EndIf    
	EndIf
EndIf

RestArea(aArea)	               

Return Nil

//----------------------------------------------------------------
/*/{Protheus.doc} FrtGerMDK
Efetua a geração da tabela MDK 

@param  cIndice , string , Indice da tabela MDK e MDJ
@param  aMDK, array , retono que contem a tabela MDK
@author  Varejo
@version P11
@since   29/11/2016
@return  aMDK	
/*/
//----------------------------------------------------------------
Function FrtGerMDK(cIndice,aMDK)
Local lNewMDK:= .F.
Local lRet	 := .T.
Local nLinha := 0 

Default cIndice := ""
Default aMDK	:= {}

// Procura os itens da NCC
DbSelectArea("MDK")

lNewMDK := MDK->(ColumnPos("MDK_NSUTEF")) > 0 

MDK->(DbSetOrder(1))	//MDK_FILIAL + MDK_DOC + MDK_SERIE + MDK_CLIENTE + MDK_LOJA + MDK_SITUA
If MDK->(DbSeek(cIndice))
	While !MDK->(EOF()) .AND.(MDK->MDK_FILIAL+MDK->MDK_DOC+MDK->MDK_SERIE+MDK->MDK_CLIENTE+MDK->MDK_LOJA == cIndice)
		AAdd(aMDK ,{;
		 			.T.				, MDK->MDK_SALDO	, MDK->MDK_TITULO, 	MDK->MDK_DTNCC	,;
					MDK->MDK_NUMREC	, MDK->MDK_SALDO2	, MDK->MDK_MVMOED,	MDK->MDK_MOEDA	,;
					MDK->MDK_PREFIX	, MDK->MDK_PARCEL	, MDK->MDK_TIPO	 })
		
		If lNewMDK .And. (MDJ->MDJ_OPER == "R")
			nLinha := Len(aMDK)
			AAdd(aMDK[nLinha] , MDK->MDK_NATUREZ)
			AAdd(aMDK[nLinha] , MDK->MDK_NSUTEF )
		    AAdd(aMDK[nLinha] , MDK->MDK_DOCTEF )
			AAdd(aMDK[nLinha] , MDK->MDK_BCOCHQ )
			AAdd(aMDK[nLinha] , MDK->MDK_AGECHQ )
			AAdd(aMDK[nLinha] , MDK->MDK_CTACHQ )
		EndIf

    	MDK->(DbSkip())
    End 	
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FrtGrNCCEr³ Autor ³ Vendas CRM	        ³ Data ³15/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o numero de servers disponiveis no arquivo ini     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FrtGrNCCEr( aMDJ )

Local lRet := .F.
Default aMDJ := {}

If Len(aMDJ) > 0
	DbSelectArea("MDJ")
	MDJ->(DbSetOrder(1)) 			//MDJ_FILIAL + MDJ_DOC + MDJ_SERIE + MDJ_CLIENT + MDJ_LOJA 
	If !MDJ->(DbSeek(aMDJ[1][2]+aMDJ[2][2]+aMDJ[3][2]+aMDJ[4][2]+aMDJ[5][2]))
		// Grava o cabecalho da NCC que sera baixada automaticament
		FR271BGeraSL("MDJ", aMDJ, .T.)
		Conout(Chr(13)+Chr(10)+" -NCC PENDENTE NO PDV - Filial: "+aMDJ[1][2]+" Doc: "+aMDJ[2][2]+" Serie: "+aMDJ[3][2] +Chr(13)+Chr(10))
	EndIf	
	lRet := .T.
EndIf
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FrtServRpc³ Autor ³ Vendas Clientes       ³ Data ³21/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o numero de servers disponiveis no arquivo ini     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FrtServRpc()

	Local cFile := GetPvProfString("RPC","NumeroServers","","RPCFRONT.INI")
	Local nNumServers := 0

 	If !Empty(cFile)

		nNumServers := Val(GetPvProfString("RPC", "NumeroServers", "1", "RPCFRONT.INI"))
		
	EndIf

	nTotCon := nNumServers
	nContCon := 0
Return nNumServers


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FRT20InSFI³ Autor ³ Vendas		        ³ Data ³09-06-2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia dados para integracao      	    	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRT20InSFI(cTabela,cChave, cAlteracao)      				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
Function FRT20InSFI(cTabela,cChave, cAlteracao)

Local oInt 			:= Nil		//Recebe classe para integracao 

DEFAULT cTabela 	:= ""
DEFAULT cChave 		:= ""
DEFAULT cAlteracao 	:= "3"
	
oInt := LJCADAPXMLENVSFI():New()
oInt:Inserir(cTabela, cChave, "1", cAlteracao)
oInt:Gerar()
oInt:Finalizar()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FRT20InSLX³ Autor ³ Vendas		        ³ Data ³09-06-2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia dados para integracao      	    	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT20InSLX(cChave)
Local lRetorno		:= .F.								//Retorno da funcao
Local aArea			:= {}								//Guarda a area atual
Local aAreaSLX 		:= {}								//Guarda a area do SLX
Local aAreaSF2		:= {}								//Guarda a area do SF2
Local oIntegracao 	:= Nil								//Objeto do tipo LJCAdapXMLEnvItensCupomFiscalCancelado
Local lEncontrou	:= .F.								//Verifica se encontrou o registro
Local lIntegra		:= SuperGetMv("MV_LJGRINT",.F.,.F.)	 //Verfica se a integracao esta habilitada

If lIntegra
    
	Conout("FRTA020 - FRT20InSLX : integracao habilitada")   	
	
	//Instancia o objeto LJCAdapXMLEnvItensCupomFiscalCancelado 
	oIntegracao := LJCAdapXMLEnvItensCupomFiscalCancelado():New()
	
	aArea 		:= GetArea()
	aAreaSLX 	:= SLX->(GetArea())
	aAreaSF2 	:= SF2->(GetArea())

	DbSelectArea("SLX")    

	DbSetOrder(1)	//LX_FILIAL + LX_PDV + LX_CUPOM + LX_SERIE + LX_ITEM + LX_HORA
	
   	Conout("FRTA020 - FRT20InSLX : ChaveLX = " + cChave)
	
	//If DbSeek(cChaveLx)
	If DbSeek(cChave)
		
	   	Conout("FRTA020 - FRT20InSLX : Encontrou LX")
					
		//Considera os registros deletados
   		SET DELETED OFF
		
		//DbSelectArea("SL1")
		DbSelectArea("SF2")
		DbSetOrder(1)		//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		
		Conout("FRTA020 - FRT20InSLX : ChaveF2 = " + SLX->LX_FILIAL + SLX->LX_CUPOM + SLX->LX_SERIE)
		
		//Se a venda nao foi gravada na retaguarda, enviar a msg de itens do cupom fiscal cancelado
		If !DbSeek(SLX->LX_FILIAL + SLX->LX_CUPOM + SLX->LX_SERIE)
			
		   	//Conout("FRTA020 - FRT20InSLX : Nao encontrou L1")    
		   	Conout("FRTA020 - FRT20InSLX : Nao encontrou F2")    
		
			While !SLX->(Eof()) .AND. (cChave) == (SLX->LX_FILIAL + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE) .AND. !SLX->(Deleted())
				oIntegracao:Inserir("SLX", xFilial("SLX") + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE + SLX->LX_ITEM + SLX->LX_HORA, "1", "3")		
				lEncontrou := .T.
				SLX->(DbSkip())
			End
			
			If lEncontrou
				lRetorno := oIntegracao:Gerar()
				lRetorno := oIntegracao:Finalizar()
			EndIf
		
		Else
		   	Conout("FRTA020 - FRT20InSLX : Encontrou F2")
			lRetorno := .T.
		EndIf
		
		//Desconsidera os registros deletados
   		SET DELETED ON
	Else
		Conout("FRTA020 - FRT20InSLX : Nao encontrou LX")
		lRetorno := .T.			   	
	EndIf
	
	RestArea(aArea)	
	RestArea(aAreaSLX)
	RestArea(aAreaSF2)		
Else
	lRetorno := .T.
EndIf
	
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FRT020FCH  ºAutor  ³Vendas Clientes       º Data ³  20/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao reponsavel pela gravacao do movimento de caixa e confe- º±±
±±º          ³rencias de caixa na retaguarda. FECHAMENTO.                    º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aSLW - Array com os campos e valores a serem grav. na SLW      º±±
±±º          ³aSLT - Array com os campos e valores a serem grav. na SLT      º±±
±±º          ³       (Opcional)                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRT020FCH(aSLW,aSLT,lFunc,lDecode)

Local lRet			:= .T.								//Retorno
Local lAtua			:= .F.								//Controle de atualizacao
Local nPos			:= 0								//Posicionador
Local aAreaSLW		:= SLW->(GetArea())					//Area SLW
Local aAreaSLT		:= SLT->(GetArea())					//Area SLT
Local aTMP			:= {}								//Array temporaria
Local cChave		:= ""								//Chave de pesquisa
Local cCampos		:= ""								//Lista de campos
Local nI			:= 0								//Contador
Local lDetADMF		:= SuperGetMV("MV_LJDESM",.F.,.F.)	//Utiliza desmembramento por administradora financeira?
Local cNumMov		:= ""								//Numero do movimento
Local cRotina		:= "[FRT020FCH]" + Space(1)			//Nome da rotina para LOG
Local lFechaConf	:= SuperGetMV("MV_LJCONFF",.F.,.F.) .AND. IIf(ExistFunc("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utiliza conferencia fecha. de cx
Local dDataMov		:= Nil								//Data do movimento
Local cPDV			:= ""								//Codigo do PDV de origem
Local nPosLGI		:= 0
Local nPosLGA		:= 0

Default aSLW		:= {}
Default aSLT		:= {}
Default lFunc		:= .F.
Default lDecode	:= .F.

ConOut(cRotina + STR0107)	//"Processando"
If !lFechaConf .OR. !AliasInDic("SLW") .OR. !AliasInDic("SLT")
	ConOut(cRotina + STR0108)	//"Abortar. Dicionario incompleto ou conferencia nao esta em uso."
	Return lRet
Endif
ConOut(cRotina + STR0086)	//"Iniciando"
If Len(aSLW) == 0 .OR. ValType(aSLW) # "A" .OR. ValType(aSLT) # "A"
	ConOut(cRotina + STR0109)	//"Abortar. Array do movimento (SLW) ou conferencia (SLT) invalido."
	Return !lRet
Endif
Begin Transaction
//ÚÄÄÄÄÄ¿
//³SLW  ³
//ÀÄÄÄÄÄÙ
ConOut(cRotina + STR0087)	//"Verificar se o mov. jah existe na retaguarda"
//Verificar se o movimento jah existe na retaguarda
cChave := xFilial("SLW")																//FILIAL
If lFunc
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_PDV"})][2] + Space(TamSX3("LW_PDV")[1]),1,TamSX3("LW_PDV")[1])				//PDV
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_OPERADO"})][2] + Space(TamSX3("LW_OPERADO")[1]),1,TamSX3("LW_OPERADO")[1])	//OPERADO
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_ESTACAO"})][2] + Space(TamSX3("LW_ESTACAO")[1]),1,TamSX3("LW_ESTACAO")[1]) 	//ESTACAO
	cChave += DtoS(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_DTABERT"})][2])																//ABERTURA
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_NUMMOV"})][2] + Space(TamSX3("LW_NUMMOV")[1]),1,TamSX3("LW_NUMMOV")[1])		//MOVIMENTO
Else
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_PDV"})][2]			//PDV
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_OPERADO"})][2]		//OPERADO
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_ESTACAO"})][2]		//ESTACAO
	cChave += DtoS(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_DTABERT"})][2])	//ABERTURA
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_NUMMOV"})][2]			//MOVIMENTO
EndIf
ConOut(cRotina + STR0088)	//"Chave indice - LW_FILIAL+LW_PDV+LW_OPERADO+LW_ESTACAO+DTOS(LW_DTABERT)+LW_NUMMOV"
ConOut(cRotina + STR0089 + cChave)	//"Chave valor - "
dbSelectArea("SLW")
SLW->(dbSetOrder(5)) //LW_FILIAL+LW_PDV+LW_OPERADO+LW_ESTACAO+DTOS(LW_DTABERT)+LW_NUMMOV
SLW->(dbSeek(cChave))
If SLW->(Found())
	ConOut(cRotina + STR0090)	//"Encontrado - Alterar a situacao do campo para RX - Servidor [ALTERAR]"
	lAtua := .T.
Else
	ConOut(cRotina + STR0091)	//"Nao encontrado [INCLUIR]"
	lAtua := .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Determinar se a estacao em questao utiliza as adm.  ³
//³financeiras na conferência.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nPos := aScan(aSLW,{|x| AllTrim(x[1]) == "LW_OPCEXIB"})) > 0
	If AllTrim(aSLW[nPos][2]) $ "0|1|2|3"
		Do Case
			Case AllTrim(aSLW[nPos][2]) == "0"		//0 - Padrão
				lDetADMF	:= .F.
			Case AllTrim(aSLW[nPos][2]) == "1"		//1 - Exib. val. apurado
				lDetADMF	:= .F.
			Case AllTrim(aSLW[nPos][2]) == "2"		//2 - Exib. adm. financeira
				lDetADMF	:= .T.
			Case AllTrim(aSLW[nPos][2]) == "3"		//3 - Exib. val. apurado e adm. financeira
				lDetADMF	:= .T.
		EndCase
	Endif
Endif

If lDecode
	If (nPosLGI := AScan( aSLW, { |x| x[1] == "LW_USERLGI" } )) > 0
		aSLW[nPosLGI][2] := Decode64(aSLW[nPosLGI][2])
	EndIf
	
	If (nPosLGA := AScan( aSLW, { |x| x[1] == "LW_USERLGA" } )) > 0
		aSLW[nPosLGA][2] := Decode64(aSLW[nPosLGA][2])
	EndIf
EndIf
//Alterar a situacao do campo para "RX" - Servidor
aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_SITUA"})][2] := "RX"
//Remover o controle de registro (ultimo campo)
If !lFunc 
	aDel(aSLW,Len(aSLW))
	aSize(aSLW,Len(aSLW) - 1)
EndIf
//Gravar
FRTGeraSL("SLW",aSLW,!lAtua)
//ÚÄÄÄÄÄ¿
//³SLT  ³
//ÀÄÄÄÄÄÙ
If Len(aSLT) > 0
	//Armazenar o numero do movimento para apagar apenas os registros do movimento correto
	cNumMov := aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_NUMMOV"})][2]
	cPDV := aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_PDV"})][2]
	dDataMov := aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_DTABERT"})][2]
	//Tratar variavel de data de abertura do movimento
	If !Empty(dDataMov) .AND. ValType(dDataMov) == "D"
		dDataMov := DtoS(dDataMov)
	Endif

	ConOut(cRotina + STR0092 + cValToChar(Len(aSLT)))	//"Total de registros a gravar na SLT : "
	For nI := 1 to Len(aSLT)
		aTMP := aSLT[nI]
		lApaga := .F.
		cChave := xFilial("SLT")
		If lDetADMF
			cChave += aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_OPERADO"})][2]
			cChave += DtoS(aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_DTFECHA"})][2])
			cChave += aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_ADMIFIN"})][2]
			cChave += aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_FORMPG"})][2]
			SLT->(dbSetOrder(3))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_ADMIFIN+LT_FORMPG
		Else
			cChave += aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_OPERADO"})][2]
			cChave += DtoS(aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_DTFECHA"})][2])
			cChave += aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_FORMPG"})][2]
			SLT->(dbSetOrder(1))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG
		Endif

		cCampos := SLT->(IndexKey())
		SLT->(dbSeek(RTrim(cChave)))

		If SLT->(Found())

			Do While !SLT->(Eof()) .AND. RTrim(SLT->&(cCampos)) == RTrim(cChave)

        		//Conferir se trata-se do mesmo movimento
				If !Empty(cNumMov)
					If AllTrim(cNumMov) == AllTrim(SLT->LT_NUMMOV) .AND. dDataMov == DtoS(SLT->LT_DTMOV) .AND. AllTrim(cPDV) == AllTrim(SLT->LT_PDV)
						//Uma conferencia do mesmo movimento, da mesma emissao e o mesmo PDV foi encontrada, apagar
						lApaga := .T.
						Exit
					Else
						//Caso o registro nao seja do mesmo movimento, da mesma emissao e o mesmo PDV, saltar
						SLT->(dbSkip())
						Loop
					Endif
				Else
					//Conferencia nao possui movimento associado, apagar
					lApaga := .T.
					Exit
				Endif

				SLT->(dbSkip())
			EndDo
		Else
			LjGrvLog(Nil,"FRTA020 - SLT não encontrada")
		Endif
		
        //Se necessario, apagar
        If lApaga
        	RecLock("SLT",.F.)
        	dbDelete()
        	MsUnlock()
        Endif
        
        If lDecode
		 	If (nPosLGI := AScan( aTMP, { |x| x[1] == "LT_USERLGI" } )) > 0
		 		aTMP[nPosLGI][2] := Decode64(aTMP[nPosLGI][2])
		 	EndIf
			
		 	If (nPosLGA := AScan( aTMP, { |x| x[1] == "LT_USERLGA" } )) > 0
		 		aTMP[nPosLGA][2] := Decode64(aTMP[nPosLGA][2])
		 	EndIf
		 EndIf
        //Alterar situacao do registro para RX na retaguarda
        aTMP[aScan(aTMP,{|x| AllTrim(x[1]) == "LT_SITUA"})][2] := "RX"
        //Remover o controle de registro (ultimo campo)
        aSize(aTMP,Len(aTMP) - 1)
        FRTGeraSL("SLT",aTMP,.T.)
	Next nI
Endif
ConOut(cRotina + STR0093)	//"Fim da transacao"
End Transaction
RestArea(aAreaSLW)
RestArea(aAreaSLT)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FRT020ABR  ºAutor  ³Vendas Clientes       º Data ³  05/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao reponsavel pela gravacao do movimento de caixa e confe- º±±
±±º          ³rencias de caixa na retaguarda. ABERTURA.                      º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aSLW - Array com os campos e valores a serem grav. na SLW      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRT020ABR(aSLW,lFunc,lDecode)

Local lRet			:= .T.
Local lAtua		:= .F.
Local aAreaSLW	:= SLW->(GetArea())
Local cChave		:= ""
Local cRotina		:= "[FRT020ABR]" + Space(1)
Local lFechaConf	:= SuperGetMV("MV_LJCONFF",.F.,.F.) .AND. IIf(ExistFunc("LjUpd70Ok"),LjUpd70Ok(),.F.)
Local nPosLGI		:= 0
Local nPosLGA		:= 0

Default aSLW		:= {}
Default lFunc		:= .F.
Default lDecode	:= .F.

ConOut(cRotina + STR0107)	//"Processando"
If !lFechaConf .OR. !AliasInDic("SLW")
	ConOut(cRotina + STR0108)	//"Abortar. Dicionario incompleto ou conferencia nao esta em uso."
	Return lRet
Endif
ConOut(cRotina + STR0086)	//"Iniciando"
If Len(aSLW) == 0 .OR. ValType(aSLW) # "A"
	ConOut(cRotina + STR0110)	//"Abortar. Array do movimento (SLW) invalido."	
	Return !lRet
Endif
ConOut(cRotina + STR0087)	//"Verificar se o mov. jah existe na retaguarda"
//Verificar se o movimento jah existe na retaguarda
cChave := xFilial("SLW")													//FILIAL
If lFunc
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_PDV"})][2] + Space(TamSX3("LW_PDV")[1]),1,TamSX3("LW_PDV")[1])				//PDV
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_OPERADO"})][2] + Space(TamSX3("LW_OPERADO")[1]),1,TamSX3("LW_OPERADO")[1])	//OPERADO
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_ESTACAO"})][2] + Space(TamSX3("LW_ESTACAO")[1]),1,TamSX3("LW_ESTACAO")[1])	//ESTACAO
	cChave += DtoS(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_DTABERT"})][2])	//ABERTURA
	cChave += SubStr(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_NUMMOV"})][2] + Space(TamSX3("LW_NUMMOV")[1]),1,TamSX3("LW_NUMMOV")[1])		//MOVIMENTO
Else
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_PDV"})][2]			//PDV
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_OPERADO"})][2]		//OPERADO
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_ESTACAO"})][2]		//ESTACAO
	cChave += DtoS(aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_DTABERT"})][2])	//ABERTURA
	cChave += aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_NUMMOV"})][2]			//MOVIMENTO
EndIf
ConOut(cRotina + STR0088)	//"Chave indice - LW_FILIAL+LW_PDV+LW_OPERADO+LW_ESTACAO+DTOS(LW_DTABERT)+LW_NUMMOV"
ConOut(cRotina + STR0089 + cChave)	//"Chave valor - "
dbSelectArea("SLW")
SLW->(dbSetOrder(5)) //LW_FILIAL+LW_PDV+LW_OPERADO+LW_ESTACAO+DTOS(LW_DTABERT)+LW_NUMMOV
SLW->(dbSeek(cChave))
If SLW->(Found())
	ConOut(cRotina + STR0090)	//"Encontrado - Alterar a situacao do campo para RX - Servidor [ALTERAR]"
	lAtua := .T.
Else
	ConOut(cRotina + STR0094)	//"Nao encontrado [INCLUSAO]"
	lAtua := .F.
Endif

If lDecode
	If (nPosLGI := AScan( aSLW, { |x| x[1] == "LW_USERLGI" } )) > 0
		aSLW[nPosLGI][2] := Decode64(aSLW[nPosLGI][2])
	EndIf
	
	If (nPosLGA := AScan( aSLW, { |x| x[1] == "LW_USERLGA" } )) > 0
		aSLW[nPosLGA][2] := Decode64(aSLW[nPosLGA][2])
	EndIf
EndIf

//Alterar a situacao do campo para "RX" - Servidor
aSLW[aScan(aSLW,{|x| AllTrim(x[1]) == "LW_SITUA"})][2] := "RX"
//Remover o controle de registro (ultimo campo)
If !lFunc
	aDel(aSLW,Len(aSLW))
	aSize(aSLW,Len(aSLW) - 1)
EndIf
//Gravar
FRTGeraSL("SLW",aSLW,!lAtua)
ConOut(cRotina + STR0093)	//"Fim da transacao"
RestArea(aAreaSLW)

Return lRet
     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTGravMBZºAutor  ³ Cesar E. Valadao    º Data ³  28/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava os campos do Server Local.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Front Loja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTGravMBZ(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)

Local nI		:= 0				//Variavel de apoio
Local aMBZ	:= {}				//Array com os campos do MBZ
Local aRet	:= {}				//Retorno do RPC GeraMBZ
Local lRet	:= .T.				//Retorno do RPC ConfMBZ
Local bMTrans := ""             //Codeblock a ser executado
Local cOrcAnt := ""             //orcamento anterior
Local nPos    := 0              //Posição do array
Local aReg    := {}              //REgistros da tabela MBZ
Local nReg    := 0              //Registro anterior
Local cOrc    := ""             //Orcamento
Local cCup 	  := ""             //Cupom
Local cSerie  := ""             //Serie
Local nProte  := 1

Default cRPCServer 	:= ""
Default nRPCPort	:= 0
Default cRPCEnv		:= ""
Default cRPCEmp		:= ""
Default cRPCFilial	:= ""

DbSelectArea( "MBZ" )
DbSetOrder( 2 )    //FILIAL + CUPOM + SERIE
If DbSeek(xFilial("MBZ")+"00")

	Do While MBZ_FILIAL + MBZ_SITUA == xFilial("MBZ")+"00" .AND. nProte < 10
		nProte++

		If cOrcAnt <> (MBZ->MBZ_CUPOM + MBZ->MBZ_SERIE)
	   		ConOut(AnsiToOem(STR0111 + MBZ->MBZ_NUM + STR0114 +MBZ->MBZ_CUPOM + "/" + MBZ->MBZ_SERIE) )    //"MyFRTA020 - FRTGravMBZ: Enviando para retaguarda Estorno da Venda do Orçamento - "                                                                                                                                                                                                                                                                                                                                                                                                                                 
		    cOrcAnt := MBZ->MBZ_CUPOM + MBZ->MBZ_SERIE 
		    cOrc    := MBZ->MBZ_NUM
			cCup 	:= MBZ->MBZ_CUPOM
			cSerie  := MBZ->MBZ_SERIE
		EndIf 
		
		aMBZ := {} 
		aReg := {}
		nPos := 0
		
		Do While cOrcAnt ==  MBZ->MBZ_CUPOM + MBZ->MBZ_SERIE
			aAdd(aMBZ, Array( FCount() ) )
		    nPos := nPos + 1
			For nI := 1 To FCount()
				aMBZ[nPos, nI] := { FieldName( nI ), FieldGet( nI ) }
			Next
		    aAdd(aReg, Recno())
			DbSkip(1)
		EndDo  
		
		nReg := Recno()
		//Envia os Dados para WS   
		If oServer <> Nil
			bMTrans := {|| oServer:CallProc( "GeraMBZ", "MBZ", aMBZ ) }
			aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
		EndIf
		
		If ValType( aRet ) == "A"  
			ConOut( AnsiToOem(STR0112 + cOrc + STR0114 + cCup + "/" + cSerie + STR0113 + Left( aRet[1], 2 )) )	//"MyFRTA020 - FRTGravMBZ: Recebido retorno da retaguarda. Orcamento - " XXXXXXX " Cupom/Serie: XXXXXXXXX/XXX Status - " XX
			If Left( aRet[1], 2 ) == "OK"
				If oServer <> Nil
					bMTrans := {|| oServer:CallProc( "ConfMBZ", aRet[2] ) }
					lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
				EndIf
				If ValType( lRet ) == "L"
					aMBZ := { { "MBZ_SITUA", "TX" } }					// "TX" - Foi Enviado ao Server
					For nI := 1 to Len(aReg)
						MBZ->(DbGoTo(aReg[nI]))
						FRTGeraSL( "MBZ", aMBZ, .F. )
					Next
				EndIf
			Else
				aMBZ := { { "MBZ_SITUA", Left( aRet[1], 2 ) } }					// "Erro" - Chave duplicada
				For nI := 1 to Len(aReg)
					MBZ->(DbGoTo(aReg[nI]))
					FRTGeraSL( "MBZ", aMBZ, .F. )
				Next		
			EndIf
		Else
			Exit //Erro na execucao do Job de integracao
		EndIf 
		DbGoTo(nReg)
	EndDo
EndIf

Return ( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraMBZ   ºAutor  ³ Cesar E. Valadao    º Data ³  28/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recebe o "pacote"de campos do Server Local.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Alias do  MBZ                                        º±±   
±±º			 ³ ExpA2: Array com os campo do MBZ                            º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Front Loja                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraMBZ(cAlias, aMBZREg)

Local aArea := GetArea()  //Workareas ativas
Local nReg  := 0     //Registro gerado
Local cChave := ""   //Chave de busca
Local cRet := "OK"   //Retorno da execução da inserção
Local aRet := {}     // Retorno da função
Local aMBZ := {}     //Linha a ser inserida
Local nC := 0        //variável contadora de registro
Local aHeadMBZ	:= MBZ->(dbStruct())
Local nPosReg   := aScan( aHeadMBZ, { |x|  x[1] == "MBZ_REG"})
Local cMBZTipo  := aHeadMBZ [nPosReg][2] // tipo de dado na Base

Default cAlias := ""
Default aMBZREg := {}

DbSelectArea(cAlias)   //MBZ_FILIAL + MBZ_CUPOM + MBZ_SERIE  + MBZ_FORMA + MBZ_PARCELA
DbSetOrder(1) 

BeginTran()

	Do While (nC := nC + 1) <= Len(aMBZReg)
	    aMBZ := aClone(aMBZReg[nC])
	    
		cChave := xFilial("SLW")																//FILIAL
		cChave += aMBZ[aScan(aMBZ,{|x| AllTrim(x[1]) == "MBZ_CUPOM"})][2]		//CUPOM
		cChave += aMBZ[aScan(aMBZ,{|x| AllTrim(x[1]) == "MBZ_SERIE"})][2]		//SERIE  
		cChave += aMBZ[aScan(aMBZ,{|x| AllTrim(x[1]) == "MBZ_FORMA"})][2]		//FORMA
		cChave += aMBZ[aScan(aMBZ,{|x| AllTrim(x[1]) == "MBZ_PARCEL"})][2]	//PARCELA
		
		If !DbSeek(cChave) 
			
            // Bloco protege caso as Bases PDV e Retaguarda estejam com o campos MBZ_REG com Tipos diferentes
			IF cAlias == "MBZ" 
				nPosReg := aScan( aMBZ, { |x|  x[1] == "MBZ_REG"})
				If cMBZTipo == "C" .AND. ValType(aMBZ[nPosReg][2]) == "N"    // se a base for C 
					aMBZ[nPosReg][2] := Alltrim(Str(aMBZ[nPosReg][2]))
				ElseIF cMBZTipo == "N" .AND. ValType(aMBZ[nPosReg][2]) == "C"   // se a base for N 
					aMBZ[nPosReg][2] := Val(aMBZ[nPosReg][2])
				ENdIf
			EndIf
			//
			
			FRTGeraSL(cAlias, aMBZ, .T.)
						
		Else
			cRet := "DU" //orcamento ja foi estornado - chave duplicada 
			Exit
		EndIf
		
		
		nReg := &(cAlias+"->(Recno())")  
		aAdd(aRet, nReg) 
	EndDo


If cRet == "OK"
	EndTran()
Else
	DisarmTransaction()  
EndIf   

RestArea(aArea) 

Return({cRet,aRet})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ ConfMBZ  ³ Autor ³ Vendas Loja           ³ Data ³28/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma a Gravacao dos Campos do Server Local.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ConfMBZ(aReg)      
Local nC := 0 //Variavel contadora de registros

Default aReg := {}

For nC := 1 to Len(aReg)
	MBZ->(DbGoto(aReg[nC]))
	FRTGeraSL("MBZ", {{"MBZ_SITUA", "RX"}})				// "RX" - Foi Recebido Pelo Server
Next
Return .T. 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ FRTATESTCOM³ Autor ³ Vendas Loja         ³ Data ³04/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirma se a Retaguarda está comunicando     .            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRTTestCom()
Local cRet := "OK" 

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ FrtEndJob³ Autor ³ Vendas Loja           ³ Data ³11/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida tempo da ultima subida de venda					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FrtEndJob( nTmEndJob )
Local lRet 			:= .F.
Local nTimeAtivo 	:= 0	// Horario que o Job subiu a ultima venda

DEFAULT nTmEndJob	:= 0 	// Tempo em minutos configurado para derrubar o job por inatividade
           
If nTmEndJob > 0
	nTimeAtivo := Val(SubStr( ELAPTIME( cHrUpVenda, TIME() ),4,2))
	                                           
	//Return .T. quando tempo(minutos) da ultima venda maior que configurado no param6 do Job
 	lRet := IIF(nTimeAtivo > nTmEndJob,.T.,.F.)
EndIf
	
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao	 ³FRTGravaSZ³ 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os Campos do Server Local.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FRTA020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja                                                  ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³		³20/08/15³ 		 												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTGrvTbl(cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial, aFiles)
Local cAlias	:=	""	//tabela
Local nOrder	:= 0	//ordem
Local aRet		:= {}	//retorno da atualização
Local lRet		:= .F.	//retorno da atualização
Local i			:= 0	//contador
Local z			:= 0	//contador	
Local aFilesTPL := {} 	//variavel de templates
Local bMTrans 	:= ""	//bloco de transmição

Default cRPCServer 	:= ""
Default nRPCPort		:= 0
Default cRPCEnv		:= ""
Default cRPCEmp     	:= ""
Default cRPCFilial	:= ""
Default aFiles		:= {}

For z := 1 To Len(aFiles)
	cAlias := aFiles[z][1]
	nOrder := aFiles[z][2]
	DbSelectArea(cAlias)
	DbSetOrder(nOrder)
	If DbSeek(xFilial(cAlias)+"00")
		aSZ := Array(FCount())
		For i := 1 To FCount()
			aSZ[i] := {FieldName(i), FieldGet(i)}
		Next
		
		If oServer <> Nil
			bMTrans := {|| oServer:CallProc("GeraSZ", cAlias, aSZ) }
			aRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
        EndIf
        
		If ValType(aRet)=="A"
			If Left(aRet[1],2)=="OK"
				If oServer <> Nil
					//a MDZ para não gravar duplicado gera um retorno -1 e não precisa ser conferido
					If cAlias == "MDZ" .And. aRet[2] == -1
						lRet := .T.
					Else
						bMTrans := {|| oServer:CallProc("ConfSZ", cAlias, aRet[2]) }
						lRet := FrtExecCall(bMTrans,.T.,cRPCServer,nRPCPort,cRPCEnv,cRPCEmp,cRPCFilial)
					EndIf
                EndIf
                
				If ValType(lRet)=="L"
					If Left(cAlias, 1) == "S"
						aSZ := {{SubStr(cAlias,2,2)+"_SITUA","TX"}}					// "TX" - Foi Enviado ao Server
					Else
						aSZ := {{cAlias+"_SITUA","TX"}}					// "TX" - Foi Enviado ao Server
					EndIf
					FRTGeraSL(cAlias, aSZ, .F.)
				EndIf
			EndIf
		EndIf
	EndIf
Next
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FrtExcTEF
Preenche os campos do cancelamento do 
TEF quando cancelo venda pelo PDV PAF

@type Function
@param cNumOrcamento , caracter , numero do orçamento
@author  Varejo
@version P11.8
@since   25/07/2015
@return  nRet , numerico , retorno
@obs
@sample

aDados[1] = Chave da SL1
aDados[2] = Numero do Nsu do Cancelamento
aDados[3] = Data do cancelamento
aDados[4] = Hora do cancelamento
aDados[5] = Conteudo do campos L4_ESTORN sempre "S"
aDados[6] = Caixa que fez cancelamento
aDados[7] = Numero do Documento da venda TEF (L4_DOCTEF ou L4_NSUTEF)
aDados[8] = Data do TEF (L4_DATATEF)

/*/
//-------------------------------------------------------------------
Function FrtTEFCanc( aDados )
Local nRet 			:= 1
Local aAreaSL1		:= {}
Local aAreaSL4		:= {}
Local lEmitNfce		:= LjEmitNFCe() // Sinaliza se utiliza NFC-e

Default aDados		:= {}

If Select("SL1") > 0
	aAreaSL1 := SL1->(GetArea())
Else
	DbSelectArea("SL1")
EndIf

If Select("SL4") > 0
	aAreaSL4 := SL4->(GetArea())
Else
	DbSelectArea("SL4")
EndIf

SL1->( DbSetOrder(2) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
If (Len(aDados) > 0) .And. SL1->( DbSeek(aDados[1]) )
	
	//PAF-ECF: Verifica se explodiu a venda(GrvBatch) para realizar o cancelamento, sinaliza
	//retornando 3( SigaLoja realiza cancelamento de diversos orcamentos de uma vez,
	//o Front um orcamento por chamada NFC-e: Retorna 3,
	If (LjNfPafEcf(SM0->M0_CGC) .OR. lEmitNfce) .AND. SL1->L1_SITUA == "RX"
		nRet := 3
	EndIf

	If nRet == 1
		RecLock("SL1",.F.)
		Replace SL1->L1_DOCCANC with aDados[2]
		Replace SL1->L1_DATCANC with aDados[3]
		Replace SL1->L1_HORCANC with aDados[4]
		SL1->(MsUnlock())
		
		SL4->(DbSetOrder(1)) //L4_FILIAL + L4_NUM + L4_ORIGEM
		If SL4->( DbSeek(xFilial("SL4") + SL1->L1_NUM ) )
			While !SL4->(Eof()) .And. (SL4->L4_FILIAL+SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM)
				If AllTrim(aDados[8]) == SL4->L4_DATATEF .AND.;
					((Alltrim(aDados[7]) == AllTrim(SL4->L4_DOCTEF)) .Or. (Alltrim(aDados[7]) == AllTrim(SL4->L4_NSUTEF))) 
					RecLock("SL4",.F.)
					Replace SL4->L4_DOCCANC with aDados[2]
					Replace SL4->L4_DATCANC with aDados[3]
					Replace SL4->L4_HORCANC with aDados[4]		
					Replace SL4->L4_ESTORN  with aDados[5]
					Replace SL4->L4_OPERAES with aDados[6]
					SL4->(MsUnlock())
				EndIf
				SL4->(DbSkip())
			End
		EndIf
	EndIf
Else
	nRet := 0
EndIf

If Len(aAreaSL1) > 0
	RestArea(aAreaSL1)
EndIf

If Len(aAreaSL4) > 0
	RestArea(aAreaSL4)
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldIncSE5
Responável por verificar se o registro ja foi cadastrado anteriormente na base 
de dados da tabela SE5, evitando duplicidades na tabela.

@param aSE5, array, campos e informação do registro a ser validado/incluido
@author Varejo
@version P11.8
@since 17/08/2016
@return logico, Valido para inclusao (verdadeiro), ou invalido para inclusao
registro ja cadastrado (falso).
@obs Fez-se necessário a validação pois quando TOTVS PDV a comunicação não 
possui garantia de integridade, ou seja, mesma que solicite a geração do registros
as vezes por perda de conectividade é enviado novamente o registro para inclusao.
/*/
//-------------------------------------------------------------------
Static Function VldIncSE5(aSE5)
Local lRet			:= .T.
Local cE5Fil		:= aSE5[AScan( aSE5, { |x| x[1] == "E5_FILIAL"	} )][2]
Local cE5Banco	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_BANCO"		} )][2]
Local cE5Agen		:= aSE5[AScan( aSE5, { |x| x[1] == "E5_AGENCIA"	} )][2]
Local cE5Conta	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_CONTA"		} )][2]
Local cE5Pref		:= aSE5[AScan( aSE5, { |x| x[1] == "E5_PREFIXO"	} )][2]
Local cE5Num		:= aSE5[AScan( aSE5, { |x| x[1] == "E5_NUMERO"	} )][2]
Local cE5Parcela	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_PARCELA"	} )][2]
Local cE5Tipo		:= aSE5[AScan( aSE5, { |x| x[1] == "E5_TIPO"		} )][2]
Local dE5Data		:= aSE5[AScan( aSE5, { |x| x[1] == "E5_DATA"		} )][2]
Local cNatureza	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_NATUREZ"	} )][2]
Local cRecPag		:= aSE5[AScan( aSE5, { |x| x[1] == "E5_RECPAG"	} )][2]
Local cTipoDoc	:= aSE5[AScan( aSE5, { |x| x[1] == "E5_MOEDA"		} )][2]

DbSelectArea( "SE5" )
SE5->(DbSetOrder(3)) //E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DToS(E5_DATA)

//Verifica se campos da chave estao preenchidos, caso contrário não será possível validar a informação
//assim a mesma será incluida normalmente. 
If !Empty(cE5Pref) .And. !Empty(cE5Num) .And. !Empty(cE5Banco)

	If SE5->(DbSeek(cE5Fil+cE5Banco+cE5Agen+cE5Conta+cE5Pref+cE5Num+cE5Parcela+cE5Tipo+DToS(dE5Data)))
		While	SE5->(!EOF()) .And. ;
				SE5->(E5_FILIAL + E5_BANCO + E5_AGENCIA + E5_CONTA + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + DToS(E5_DATA)) == ;
				cE5Fil + cE5Banco + cE5Agen + cE5Conta + cE5Pref + cE5Num + cE5Parcela + cE5Tipo + DToS(dE5Data)

			If	AllTrim(cNatureza) == AllTrim(SE5->E5_NATUREZ) .And. AllTrim(cRecPag) == AllTrim(SE5->E5_RECPAG) .And. ;
				AllTrim(cTipoDoc) == AllTrim(SE5->E5_MOEDA)

				LjGrvLog(Nil, "Registro E5_PREFIXO:"+cE5Pref+" /E5_NUMERO:"+cE5Num+" /E5_BANCO:"+cE5Banco+" ja encontrada na tabela SE5")
				LjGrvLog(Nil, "Numero do recno equivalente:", SE5->(RECNO()))
				lRet := .F.
				Exit
			EndIf

			SE5->(DBSkip())
		End
	EndIf
Else
	LjGrvLog(Nil, "Campos em branco - E5_PREFIXO:"+cE5Pref+" /E5_NUMERO:"+cE5Num+" /E5_BANCO:"+cE5Banco)
EndIf

Return lRet
