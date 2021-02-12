#INCLUDE "FRTXFUN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRTSetKey³ Autor ³ Cesar Eduardo Valadao ³ Data ³10/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Setar as Teclas de Funcao. (SetGet)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTSetKey(abSetKey)
Local bRet:=Array(35)
Default abSetKey:={}
ASize(abSetKey, 35)
bRet[ 1] := SetKey(VK_F4,  abSetKey[ 1])
bRet[ 2] := SetKey(VK_F5,  abSetKey[ 2])
bRet[ 3] := SetKey(VK_F6,  abSetKey[ 3])
bRet[ 4] := SetKey(VK_F7,  abSetKey[ 4])
bRet[ 5] := SetKey(VK_F8,  abSetKey[ 5])
bRet[ 6] := SetKey(VK_F9,  abSetKey[ 6])
bRet[ 7] := SetKey(VK_F10, abSetKey[ 7])
bRet[ 8] := SetKey(VK_F11, abSetKey[ 8])
bRet[ 9] := SetKey(VK_F12, abSetKey[ 9])
bRet[10] := SetKey(1,      abSetKey[10])					// CTRL+A
bRet[11] := SetKey(2,      abSetKey[11])
bRet[12] := SetKey(3,      abSetKey[12])
bRet[13] := SetKey(4,      abSetKey[13])
bRet[14] := SetKey(5,      abSetKey[14])
bRet[15] := SetKey(6,      abSetKey[15])
bRet[16] := SetKey(7,      abSetKey[16])
bRet[17] := SetKey(8,      abSetKey[17])
bRet[18] := SetKey(9,      abSetKey[18])
bRet[19] := SetKey(10,     abSetKey[19])
bRet[20] := SetKey(11,     abSetKey[20])
bRet[21] := SetKey(12,     abSetKey[21])
bRet[22] := SetKey(13,     abSetKey[22])					// ...
bRet[23] := SetKey(14,     abSetKey[23])
bRet[24] := SetKey(15,     abSetKey[24])
bRet[25] := SetKey(16,     abSetKey[25])
bRet[26] := SetKey(17,     abSetKey[26])
bRet[27] := SetKey(18,     abSetKey[27])
bRet[28] := SetKey(19,     abSetKey[28])
bRet[29] := SetKey(20,     abSetKey[29])
bRet[30] := SetKey(21,     abSetKey[30])
bRet[31] := SetKey(22,     abSetKey[31])
bRet[32] := SetKey(23,     abSetKey[32])
bRet[33] := SetKey(24,     abSetKey[33])
bRet[34] := SetKey(25,     abSetKey[34])
bRet[35] := SetKey(26,     abSetKey[35])					// CTRL+Z
Return(bRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MonCondPag³ Autor ³ Cesar Eduardo Valadao ³ Data ³11/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montar o Array da Condicoes de Pagamento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// *** RETIRAR ESTE TRECHO DA DefinForma() NO LOJA220C.PRW E SUBSTITUIR PELA FUNCAO ***

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³StatusGet ³ Autor ³ Cesar Eduardo Valadao ³ Data ³17/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Entrada de Dados na Barra de Mensagens							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FrtGet(uVar, cPict, lEsc)
Local oDlg, oGet, oFont, lOk := .F.
DEFAULT cPict	:= ""
DEFAULT lEsc    := .F.
DEFINE FONT oFont NAME "Times New Roman" SIZE 14,40
DEFINE MSDIALOG oDlg FROM 442,156 TO 451,628 PIXEL OF GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP) ;
		COLOR CLR_WHITE,CLR_BLACK
	@ 0,0 MSGET oGet VAR uVar PIXEL FONT oFont SIZE 100,19 PICTURE cPict NO BORDER COLOR CLR_WHITE,CLR_BLACK
	oGet:bLostFocus	:= {|| (lOk := .T.,oDlg:End())}
	DEFINE SBUTTON FROM 100,100 ACTION (lOk := .T., oDlg:End()) ENABLE		// Meramente Ilustrativo!!!
ACTIVATE MSDIALOG oDlg

If !lOk
	lEsc := .T.
EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CheckCaixa³ Autor ³ Cesar Eduardo Valadao ³ Data ³20/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Caixa esta aberto									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CheckCaixa(lCXAberto, lUsaDisplay, lVAssist , lFuncF12, lHora)

Local lRet:=.T.

DEFAULT lVAssist := .F.
DEFAULT lFuncF12 := .F. 										   // Se foi acionado pelas funcoes do Front Loja (F12)
DEFAULT lHora	 := .T.

If !lVAssist      
	If !lCXAberto .AND. LjNfPafEcf(SM0->M0_CGC) .AND. lFuncF12     //Caso o caixa nao esteja aberto e seja PAF ECF permite acesso apenas ao menu fiscal.  
   		MsgStop(OemToAnsi(STR0007), OemToAnsi(STR0002))            //"Conforme previsto no Requisito VII (Item 1) do Ato Cotepe 0608 (PAF-ECF), o Menu Fiscal não pode possuir restrição de acesso."
		lRet := .F.	
	ElseIf !lCXAberto
			If lUsaDisplay               
                DisplayEnv(StatDisplay(), "1C" + STR0003 )         //"O Caixa não está aberto.
                DisplayEnv(StatDisplay(), "2C" + STR0004 )         //"Não será possível alterar o cliente" 
            EndIf    
		        MsgStop(OemToAnsi(STR0001), OemToAnsi(STR0002))
		lRet := .F.
	Else 
	
		If !lHora .and. !lFuncF12
			MsgStop(OemToAnsi(STR0008))//"A data do sistema esta diferente com a data do sistema operacional. Atenção! Favor efetuar o logoff do sistema"
			lRet := .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mesmo o caixa estando aberto verifica se nao houve          ³
		//³troca do operador , caso ocorra não prossegue com a operacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("cEstacao") <> "U" 
			DbSelectArea("SLI")
		 	DbSetOrder(1)		//LI_FILIAL+LI_ESTACAO+LI_TIPO+LI_SEQ
		 	If DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"OPE")
		 		If !Empty(SLI->LI_MSG) .AND. AllTrim(SLI->LI_USUARIO) <> AllTrim(cUserName)
					lCXAberto 	:= .F.				 	
					lRet 		:= .F.
					// "O Caixa nao esta Aberto. Impossivel realizar esta Operacao."
					MsgStop(STR0001)
		 		EndIf
		 	EndIf     	
		EndIf
	EndIf	
EndIf	
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTAABRCON³ Autor ³ Vendas Clientes       ³ Data ³18/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza conexão com Retaguarda através do TCLINK           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 -                                                    ³±±
±±³			 ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                          
Function FRTAABRCON(nConTcLnk,aConnTopRet)
Local cServer
Local cConType
Local cHasMapper
Local cProtect
Local nPort
Local __cLastConn
Local xConnect
Local cDataBase
Local cIniFile	:= GetAdv97()
Local lRet		:= .T.

Default aConnTopRet := {}

If Len(aConnTopRet) == 0
	xConnect := GetGlbValue("MYTOPCONNECT")
	
	If Empty(xConnect)
		cDataBase  := GetPvProfString("TopConnect","DataBase","ERROR",cInIfile )
		cAlias	   := GetPvProfString("TopConnect","Alias","ERROR",cInIfile )
		cServer	   := GetPvProfString("TopConnect","Server","ERROR",cInIfile )
		cConType   := Upper(GetPvProfString("TopConnect","Contype","TCPIP",cInIfile ))
		cHasMapper := Upper(GetPvProfString("TopConnect","Mapper","ON",cInIfile ))
		cProtect   := GetPvProfString("TopConnect","ProtheusOnly","0",cInIfile )
		nPort      := Val(GetPvProfString("TopConnect","Port","0",cInIfile ))
	
		// Ajuste pelo Environment do Server
		cDataBase  := GetSrvProfString("DBDataBase",cDataBase)
		cAlias	   := GetSrvProfString("DBAlias",cAlias)
		cServer	   := GetSrvProfString("DBServer",cServer)
	
		cConType   := Upper(GetSrvProfString("TopContype",cConType))
		cHasMapper := Upper(GetSrvProfString("TopMapper",cHasMapper))
		cProtect   := GetSrvProfString("TopProtheusOnly",cProtect)
		nPort      := Val(GetSrvProfString("TopPort",StrZero(nPort,4,0)))   //Soh Para Conexao TCPIP
	
		xConnect := AllTrim(cDataBase) + "#" + AllTrim(cAlias) + "#" + AllTrim(cServer) + "#" + ;
					AllTrim(cConType) + "#" + AllTrim(cHasMapper) + "#" + AllTrim(cProtect) + "#" + ;
					StrZero(nPort,4,0)
				
		PutGlbValue("MYTOPCONNECT",xConnect)
	Else
		xConnect  := StrTokArr(xConnect,"#")
		cDataBase := xConnect[1]
		cAlias	  := xConnect[2]
		cServer	  := xConnect[3]
		cConType  := xConnect[4]
		cHasMapper:= xConnect[5]
		cProtect  := xConnect[6]
		nPort     := Val(xConnect[7])
	EndIf
	
	If !(AllTrim(cContype)$"TCPIP/NPIPE")
		MsgAlert(STR0005)					//"A chave Contype da seção TopConnect deve ser ajustada para TCPIP no arquivo TotvsAppServer.ini"
		lRet := .F.
	EndIf
	
	If "ERROR" $ cDataBase+cAlias+cServer
		MsgAlert(STR0006)					//"E necessário configurar a seção TopConnect no arquivo TotvsAppServer.ini"
		lRet := .F.
	EndIf
Else
	cDataBase  := aConnTopRet[1]
	cAlias	   := aConnTopRet[2]
	cServer	   := aConnTopRet[3]
	cConType   := aConnTopRet[4]
	cProtect   := aConnTopRet[5]
	nPort      := aConnTopRet[6]
EndIf

If lRet
	IF cProtect == "1"
		cProtect := "@@__@@"    //Assinatura para o TOP
	Else
		cProtect := ""
	Endif

	__cLastConn := cDatabase+";"+cAlias+";"+cServer

	TCConType(cConType)

	If (("AS" $ cAlias) .AND. ("400" $ cAlias))
		nConTcLnk := TCLink(cDataBase,cServer,nPort)
	Else
		nConTcLnk := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias,cServer,nPort)  // Nao Comer Licenca do Top
		IF nConTcLnk < 0
			ConOut("FRTXFUN.PRW - TOPCONN Connection Failed - Error ("+Str(nConTcLnk,4,0)+") "+cDatabase+";"+cAlias+";"+cServer)
		Endif
	EndIf

	If (nConTcLnk < 0)
		// Alterna o TOP para o ambiente do arquivamento
		TCSetConn( nConTcLnk )
	EndIf
EndIf

Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTAFCHCON³ Autor ³ Vendas Clientes       ³ Data ³18/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finaliza conexão com Retaguarda estabelecida pelo TCLINK   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 -                                                    ³±±
±±³			 ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function FRTAFCHCON(nConTcLnk)
Local lRet	:=	.T.

If nConTcLnk >= 0
	TCQUIT()
EndIf

Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTADEFTAB³ Autor ³ Vendas Clientes       ³ Data ³18/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona e prepara do ambiente da Retaguarda para ser 	  ³±±
±±³			 ³ utilizada no Check-Out   								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela do Protheus                                 ³±±
±±³          ³ ExpC2 - Alias  do Protheus                                 ³±±
±±³          ³ ExpN1 - Numero da conexão estabelecida pelo TCLink         ³±±
±±³			 ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function FRTADEFTAB(cTabela, cAliasRet, nConTcLnk)
Local lRet		 :=	.F.
Local aStruct	 :=	{}
Local aIndex	 :=	{}
Local nI 		 := 0  
Local cDriver	 := "TOPCONN"
Local lIndexOpen := .T.     

If nConTcLnk >= 0
	(cAliasRet)->(dbCloseArea())
	dbUseArea(.T.,"TOPCONN",cTabela,cAliasRet,.T.)

	DbSelectArea(cAliasRet)	
	aStruct := TableStruct(cAliasRet)
 	aIndex  := TableIndex(cAliasRet)
                   
    If ( cDriver == 'TOPCONN' )
    	For nI := 1 To Len(aIndex)
			aIndex[nI][2]:= ClearKey(aIndex[nI][2])
		Next nI
	EndIf
  	If ( lIndexOpen )
		If ( cDriver == 'TOPCONN' )
			For nI := 1 To Len(aIndex)
    	        cIndice  := FileNoExt(cTabela)+aIndex[nI][1]
                DbSetIndex(cIndice)
                DbSetNickName(OrdName(nI), aIndex[nI][3])
            Next nI
		Else
			nI := 1
			While ( !Empty(OrdName(nI)) )          
				If ( nI > Len(aIndex) )
					Final("Index OF "+cAliasRet+" Corrupted")
				EndIf
				DbSetNickName(OrdName(nI),aIndex[nI][3])
				nI++
			End
		EndIf
		DbSetOrder(1)
	Else
		DbClearIndex()         
	EndIf
	lRet :=	.T.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FRTADNWCHK³ Autor ³ Vendas Clientes       ³ Data ³18/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza check-out caso necessário com os dados da         ³±±
±±³			 ³ retaguarda. Tabelas envolvidas:							  ³±±
±±³			 ³ SB1 - Cadastro de produto                                  ³±±
±±³			 ³ SBI - Cadastro de Produto x Preços                         ³±±
±±³			 ³ SLK - Cadastro de Codigo de Barras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numero da conexão estabelecida pelo TCLink         ³±±
±±³          ³ ExpC1 - Filial do Cadastro de Produto                      ³±±
±±³          ³ ExpC2 - Codifo do Produto                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTADNWCHK (nConTcLnk, cCodProd, lBscON, cCliente, cLojaCli)
Local aSaveArea			:=	GetArea()
Local aSaveAreaSB1		:=	GetArea("SB1")
Local aSaveAreaSB0		:=	GetArea("SB0")
Local aSaveAreaSLK		:=	GetArea("SLK")
Local aStructSB1		:=	{}
Local aStructSLK		:=	{}
Local nX				:=	0
Local aCampos			:= {}
Local nPreco			:=	0
Local lAppendLK			:= .F.
Local lAppendBI			:= .F.
Local nPosCpo			:= 0
Local oTmpSB1			:= NIL
Local oTmpSLK			:= NIL

Default cCliente 		:= AllTrim(SuperGetMv("MV_CLIPAD"))		// Cliente padrao
Default cLojaCli 		:= AllTrim(SuperGetMv("MV_LOJAPAD"))	// Loja padrao

If nModulo == 12 //12=SIGALOJA
	cCliente := M->LQ_CLIENTE
	cLojaCli := M->LQ_LOJA
EndIf

If nConTcLnk >= 0
	DbSelectArea("SB1")
	DbSetOrder(1)		//B1_FILIAL+B1_COD
	If DbSeek(xFilial("SB1")+cCodProd)        
		aStructSB1 := SB1->(DbStruct())

		If Select("TRBSB1") > 0 	//Fecha Area Se Estiver Aberta
			DbSelectArea("TRBSB1")
			TRBSB1->(DbCloseArea())
		EndIf
		
		oTmpSB1 := LjCrTmpTbl("TRBSB1", aStructSB1)
		LjGrvLog( NIL, " Criou tabela Temporaria SB1", oTmpSB1)
		RecLock("TRBSB1",.T.)
		For nX := 1 to Len(aStructSB1)
			nPosCpo	:= SB1->(ColumnPos(TRBSB1->(FieldName(nX))))
			TRBSB1->(FieldPut(nX,SB1->(FieldGet(nPosCpo))))
		Next nX                               
		TRBSB1->(MsUnlock())
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona/prepara a area da retaguarda para ser utilizada no Check-Out  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTADEFTAB(Posicione("SX2", 1, "SB0", "AllTrim(X2_ARQUIVO)"), "SB0", nConTcLnk)

	//Seleciona o preço cadastrado - Produto x Preço
	LjxeValPre(@nPreco, cCodProd, cCliente, cLojaCli, Nil, Nil, .T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona/prepara a area da retaguarda para ser utilizada no Check-Out  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FRTADEFTAB(Posicione("SX2", 1, "SLK", "AllTrim(X2_ARQUIVO)"), "SLK", nConTcLnk)
	DbSelectArea("SLK")
	DbSetOrder(2)		//LK_FILIAL+LK_CODIGO+LK_CODBAR
	If DbSeek(xFilial("SLK")+cCodProd)
		
		aStructSLK := SLK->(DbStruct())				
		If Select("TRBSLK") > 0 	// Fecha Area Se Estiver Aberta
			DbSelectArea("TRBSLK")
			TRBSLK->(DbCloseArea())
		EndIf

		oTmpSLK := LjCrTmpTbl("TRBSLK", aStructSLK)
		LjGrvLog( NIL, " Criou tabela Temporaria SLK", oTmpSLK)	
		
		While !SLK->(Eof()) .And. cCodProd == SLK->LK_CODIGO
			RecLock("TRBSLK",.T.)
			For nX := 1 to Len(aStructSLK)
				FieldPut(nX,SLK->(FieldGet(nX)))
			Next nX                               
			TRBSLK->(MsUnlock())			 
			SLK->(DbSkip())
		End
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a conexão com a retaguarda para subir o produto no check-out   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nConTcLnk >= 0
	FRTAFCHCON(nConTcLnk)
Endif

If Len(aStructSB1) > 0
	DbSelectArea("SBI")
	DbSetOrder(1)		//BI_FILIAL+BI_COD                                  
	lAppendBI := !DbSeek(xFilial("SLK")+cCodProd)
	
	DbSelectArea("SBI")
	aCampos := SBI->(Array(FCount()))
	For nX := 1 To SBI->(FCount())
		If SBI->(FieldName(nX)) == "BI_PRV"
			aCampos[nX] := {SBI->(FieldName(nX)), "B1_PRV"}
		Else
			aCampos[nX] := {SBI->(FieldName(nX)), "B1_"+Substr(SBI->(FieldName(nX)),4)}		
		EndIf
	Next nX

	DbSelectArea("TRBSB1")
	RecLock("SBI",lAppendBI)
	For nX := 1 To Len(aCampos)              
		If aCampos[nX][1] == "BI_PRV"
			FieldPut(SBI->(ColumnPos(aCampos[nX][1])),nPreco,.F.)
		ElseIf TRBSB1->(ColumnPos(aCampos[nX][2])) > 0
			FieldPut(SBI->(ColumnPos(aCampos[nX][1])),TRBSB1->(FieldGet(TRBSB1->(ColumnPos(aCampos[nX][2])))),.F.)
		EndIf
	Next nX
	SBI->(MsUnlock())	
EndIf

If Len(aStructSLK) > 0
	DbSelectArea("SLK")
	DbSetOrder(2)		//LK_FILIAL+LK_CODIGO+LK_CODBAR                      
	lAppendLK	:=	!DbSeek(xFilial("SLK")+cCodProd)
	
	aCampos := SLK->(Array(FCount()))
	For nX := 1 To SLK->(FCount())
		aCampos[nX] := {SLK->(FieldName(nX))}		
	Next nX

	DbSelectArea("TRBSLK")
	RecLock("SLK",lAppendLK)
	For nX := 1 To Len(aCampos)
		FieldPut(SLK->(ColumnPos(aCampos[nX][1])),TRBSLK->(FieldGet(TRBSLK->(ColumnPos(aCampos[nX][1])))),.F.)
	Next nX
	SLK->(MsUnlock())	
EndIf

If oTmpSB1 <> NIL 	// Fecha Area Se Estiver Aberta
	oTmpSB1:Delete()
	FreeObj(oTmpSB1)
	oTmpSB1 := NIL
EndIf

If oTmpSLK <> NIL 	// Fecha Area Se Estiver Aberta
	oTmpSLK:Delete()
	FreeObj(oTmpSLK)
	oTmpSLK := NIL
EndIf

RestArea(aSaveArea)
RestArea(aSaveAreaSB0)
RestArea(aSaveAreaSLK)
RestArea(aSaveAreaSB1)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FRTXGetTC ³ Autor ³ Vendas Clientes       ³ Data ³10/10/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pega as configuracoes do TopConnect da Retaguarda para que ³±±
±±³          ³ o PDV possa se conectar com a base de dados da Retaguarda.  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                                                                          
Function FRTXGetTC()
Local cDataBase := ""
Local cAlias 	:= ""
Local cServer 	:= ""
Local cConType 	:= ""
Local cProtect 	:= ""
Local nPort 	:= 0
Local cIniFile	:= GetAdv97()
Local lOK		:= .T.
Local aRet 		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca as Configuracoes de: Server, DataBase e Alias do TOP utilizado na Retaguarda.  ³
//³Considera tanto a chave prefixada com "TOP" como tambem prefixada com "DB", pois     ³
//³ambos podem ser utilizados.                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//1o. Busca na Secao [DBAccess]
cDataBase  := GetPvProfString("DBAccess","DataBase","ERROR",cInIfile )
cAlias	   := GetPvProfString("DBAccess","Alias","ERROR",cInIfile )
cServer	   := GetPvProfString("DBAccess","Server","ERROR",cInIfile )
cConType   := Upper(GetPvProfString("DBAccess","Contype","TCPIP",cInIfile ))
cProtect   := GetPvProfString("DBAccess","ProtheusOnly","0",cInIfile )
nPort      := Val(GetPvProfString("DBAccess","Port","0",cInIfile ))

//2o. Busca na Secao [TopConnect]
cDataBase  := GetPvProfString("TopConnect","DataBase",cDataBase,cInIfile )
cAlias	   := GetPvProfString("TopConnect","Alias",cAlias,cInIfile )
cServer	   := GetPvProfString("TopConnect","Server",cServer,cInIfile )
cConType   := Upper(GetPvProfString("TopConnect","Contype","TCPIP",cInIfile ))
cProtect   := GetPvProfString("TopConnect","ProtheusOnly","0",cInIfile )
nPort      := Val(GetPvProfString("TopConnect","Port","0",cInIfile ))

//3o. Busca na Secao do ENVIRONMENT considerando a chave prefixada com "DB"
cDataBase  := GetSrvProfString("DBDataBase",cDataBase)
cAlias	   := GetSrvProfString("DBAlias",cAlias)
cServer	   := GetSrvProfString("DBServer",cServer)
cConType   := Upper(GetSrvProfString("DBContype",cConType))
cProtect   := GetSrvProfString("DBProtheusOnly",cProtect)
nPort      := Val(GetSrvProfString("DBPort",StrZero(nPort,4,0)))   //Soh Para Conexao TCPIP

//4o. Busca na Secao do ENVIRONMENT considerando a chave prefixada com "Top"
cDataBase  := GetSrvProfString("TopDataBase",cDataBase)
cAlias	   := GetSrvProfString("TopAlias",cAlias)
cServer	   := GetSrvProfString("TopServer",cServer)
cConType   := Upper(GetSrvProfString("TopContype",cConType))
cProtect   := GetSrvProfString("TopProtheusOnly",cProtect)
nPort      := Val(GetSrvProfString("TopPort",StrZero(nPort,4,0)))   //Soh Para Conexao TCPIP

If !(AllTrim(cContype)$"TCPIP/NPIPE")
	lOK := .F.
EndIf

If cDataBase == "ERROR" .Or. cAlias == "ERROR" .Or. cServer == "ERROR"
	lOK := .F.
EndIf

If lOK
	aRet := { cDataBase, cAlias, cServer, cConType, cProtect, nPort }
EndIf

Return aRet