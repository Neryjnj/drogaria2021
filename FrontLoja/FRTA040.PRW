#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA040.CH"                           

#DEFINE FRT_DBFCARGA	"CARGA"+cEmpAnt+"0.FRT"
#DEFINE FRT_CDXCARGA	"CARGA"+cEmpAnt+"0.FRX"
#DEFINE FRT_EMPFIL		If(lMultiFil .AND. FRTSX2Excl(cArquivo),ALLTRIM("CRG"+cEmpAnt+cFilAnt)+"\","")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
#DEFINE  CL_CONECTADO     0		//³ Azul		³
#DEFINE  CL_ONLINE        1		//³ Verde      	³
#DEFINE  CL_ATUALIZANDO   2		//³ Amarelo    	³
#DEFINE  CL_DESCONECTADO  3		//³ Vermelho  	³
#DEFINE  CL_LOCKED        4		//³ Preto     	³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)
Static lNovRegDesc	:= SuperGetMv("MV_LJRGDES",,.F.) .AND. RGVldTable()	//Validacao da Nova Regra de Desconto Ativa

Static cCargaSEQ								//Sequencia da carga anterior
Static cCargaNEW								//Sequencia da carga nova
Static cMV_DIRCFRT								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
Static aLogErros   :={}							//³ Caso exista erros entre o arquivo de carga e a tabela			³
												//³ adiciona neste array para exibir a mensagem somente uma vez.   	³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Variaveis convertidas de Private para Local|
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
|nEstacoes                    			    |
|aFiles                       		  	    |
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FRTA040	³ Autor ³ Vendas Clientes       ³ Data ³13/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carga nas Estacoes                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FRTA040()
Local oDlg	        		//Objeto para a criacao da tela da rotina de carga
Local oBtnLibera			//Objeto do botao Liberar
Local oBtnCarga				//Objeto do botao Gerar Carga...
Local cTitulo				//Titulo da tela
Local cText1				//Texto informativo
Local cText2				//Texto informativo
Local nI 					//Variavel de controle do laco
Local nHandle				//Variavel de controle
Local aConnected			//Array que armazena as estacoes conectadas
Local nEstacoes 	:= 0	//Numero de estacoes conectadas
Local aFiles		:= {}	//Array para armazenamento das tabelas
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina se utiliza Geração/Liberação de Carga MultiFilial, 0 = Não Utiliza, 1 = Utiliza  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nMV_LJCRGAU   := SuperGetMV("MV_LJCRGAU",.F.,0)    
Local lPOS			:= Iif(ExistFunc("STFIsPOS"), STFIsPOS(), .F.)	//indica se eh TOTVS PDV
Local lCenVda		:= SuperGetMv("MV_LJCNVDA",,.F.)
Local cPerg			:= "FRT040"

Private lMultiFil := .F.	//Verifica se eh multi-filiais         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se vai gerar carga nas estacoes com a opcao de ³
//³ cenario de vendas e regra de desconto ativa.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !VldRegDesc() .Or. lPOS
	If lPOS
		MsgAlert(STR0080) //"Função não disponível para TotvsPDV"
	EndIf
	
	Return NIL
EndIf      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o parametro MV_LJCRGAU esteja configurado para trabalhar com Multiplas Filiais  |
//|(paramentro igual a 1), e verificado se o usuario ou algum grupo a qual ele pertenca,|
//| tenha acesso a todas empresas / filiais. 			 								|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nMV_LJCRGAU == 1
	If !FRTVldUser()
		MsgStop(STR0069)//"É necessário que o usuário tenha acesso a todas as Empresas / Filiais."
		Return(NIL)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o modo de abertura das tabelas SB0, SB1, SBI e SLH. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTChkModo()

cMV_DIRCFRT := ALLTRIM(SuperGetMV("MV_DIRCFRT"))

nHandle := FCreate(cMV_DIRCFRT+"TEMP.TMP")
If nHandle == -1
	// "O diretório informado no parâmetro MV_DIRCFRT não é válido ou não existe.", "Atenção"
	MsgStop(STR0024+Chr(13)+cMV_DIRCFRT, STR0002)
	Return(NIL)
Else
	FClose(nHandle)
	FErase(cMV_DIRCFRT+"TEMP.TMP")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existência de diretórios de Carga de todas as Filiais da Empresa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nMV_LJCRGAU == 0  
	nHandle := FCreate(ALLTRIM(cMV_DIRCFRT+"CRG"+cEmpAnt+cFilAnt)+"\TEMP.TMP")
	If nHandle == -1
		// "Não existe o diretório " ### ". Verifique Help do Sistema sobre os procedimentos a serem efetuados.", "Atenção"
		MsgStop(STR0038+ALLTRIM(cMV_DIRCFRT+"CRG"+cEmpAnt+cFilAnt)+STR0056, STR0002)
		Return(NIL)		
	Else
		lMultiFil := .T.
		FClose(nHandle)
		FErase(ALLTRIM(cMV_DIRCFRT+"CRG"+cEmpAnt+cFilAnt)+"\TEMP.TMP")
	EndIf
Else
	SM0->(DbSeek(cEmpAnt))
	While SM0->M0_CODIGO == cEmpAnt .AND. !SM0->(Eof())
		nHandle := FCreate(ALLTRIM(cMV_DIRCFRT+"CRG"+SM0->M0_CODIGO+FWGETCODFILIAL)+"\TEMP.TMP")
		If nHandle == -1
			// "Não existe o diretório " ### ". Verifique Help do Sistema sobre os procedimentos a serem efetuados.", "Atenção"
			MsgStop(STR0038+ALLTRIM(cMV_DIRCFRT+"CRG"+SM0->M0_CODIGO+FWGETCODFILIAL)+STR0056, STR0002)
			Return(NIL)
		Else
			lMultiFil := .T.
			FClose(nHandle)
			FErase(ALLTRIM(cMV_DIRCFRT+"CRG"+SM0->M0_CODIGO+FWGETCODFILIAL)+"\TEMP.TMP")                      			
		EndIf      
		SM0->(DbSkip())
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reposiciona o arquivo SIGAMAT.EMP            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SM0->(DbSeek(cEmpAnt+cFilAnt))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Tabela de Preco    ?                              ³
//³ mv_par02 - Tipo de Carga      ? (1-Completa  2-Rapida        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCenVda
	cPerg := "FRT040A"
EndIf
Pergunte(cPerg, .F.)

nEstacoes := SuperGetMV("MV_NUMESTA")

If (nEstacoes <= 0) .OR. (nEstacoes > 99)
	// "O número de Check-Out's (Estações) permitidos é 1 à 99. Corrija o parâmetro MV_NUMESTA.", "Atenção"
	MsgStop(STR0001, STR0002)
	Return(NIL)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivos a Gerar Carga ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFiles := FRTArquivos()                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abrir Arquivo de Carga de Estacoes - CARGAxx0.FRT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                
nI := 0
While !OpenCarga() .AND. nI <= 150
	nI++
	Sleep(500)
End

If nI = 151
	// "Erro ao abrir arquivo de Carga das Estações", "Atenção"
	MsgStop(STR0003, STR0002)
	If Select("CARGA") > 0
		DbSelectArea("CARGA")
		DbCloseArea()
	EndIf
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo \SEMAFORO\SIGAFRT\CARGA.L<empresa> que BLOQUEIA ³
//³ TEMPORARIAMENTE as estacoes de receberem carga                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !FRTGeraSGC(.T.)
	MsgStop(STR0055, STR0002)	//"Atenção"//"Já existe uma outra estação efetuando a geração da carga."
	If Select("CARGA") > 0
		DbSelectArea("CARGA")
		DbCloseArea()
	EndIf
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar Estacoes Desconectadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aConnected := FRTRPCConn()
cDisconnec := ""
For nI := 1 To nEstacoes
	If aConnected[nI][1] = CL_DESCONECTADO
		cDisconnec += " " + StrZero(nI, 3, 0) + ","
	EndIf
Next nI
If !Empty(cDisconnec)
	// "Os Check-Out's" ### " não estão conectados.", "Atenção"
	MsgStop(STR0025 + cDisconnec + STR0026, STR0002)
EndIf

cTitulo := STR0004	// "Carga nas Estações"
cText1  := STR0005	// "Este programa processa a geração do arquivo de Carga das Estações."
cText2  := ""
DEFINE MSDIALOG oDlg TITLE cTitulo FROM  165,115 TO 315,525 PIXEL
	@ 03, 10 TO 43, 195 LABEL "" OF oDlg PIXEL
	@ 10, 15 SAY cText1   SIZE 175, 8 OF oDlg PIXEL
	@ 20, 15 SAY cText2   SIZE 175, 8 OF oDlg PIXEL
	
	DEFINE SBUTTON            FROM 50,  54 TYPE 5  ACTION (Pergunte(cPerg,.T.)) ENABLE OF oDlg
	DEFINE SBUTTON oBtnCarga  FROM 50,  83 TYPE 13 ACTION (FRTCarga( aFiles )) ENABLE OF oDlg	ONSTOP STR0029		//"Gerar Carga..."
	
	oBtnCarga:cCaption := Left(STR0029,11)
	
	DEFINE SBUTTON oBtnAtu    FROM 50, 112 TYPE 16 ACTION (FRTComp(aConnected)) ENABLE OF oDlg	ONSTOP STR0031+"..."	//"Atualização total no Check-Out"
	
	oBtnAtu:cCaption := Left(STR0031,11)
	
	DEFINE SBUTTON oBtnLibera FROM 50, 141 TYPE 1  ACTION (FRTLibera( aFiles )) ENABLE OF oDlg	ONSTOP STR0030		//"Liberar Carga..."
	
	oBtnLibera:cCaption := Left(STR0030,11)
	
	DEFINE SBUTTON            FROM 50, 170 TYPE 2  ACTION (oDlg:End()) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg

DbSelectArea("CARGA")
DbCloseArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Elimina o arquivo \SEMAFORO\SIGAFRT\CARGA.L<empresa> liberando ³
//³ as estacoes para realizar atualizacao da carga                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FRTGeraSGC()

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³ FRTComp  ³ Autor ³ Vendas Clientes       ³ Data ³04/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Atualizacao de todas as tabelas no Check-Out     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array que armazena os checkouts conectados         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTComp( aConnected )
Local oWndComp 												//Objeto para a criacao da tela de atualizacao total dos Check-Out
Local nSucess  := 0										    //Controla se foi pressionado o botao confirma	
Local aEstacao := {}										//Array que armazena informacoes das estacoes
Local oEstacao												//Objeto auxiliar
Local oOk      := LoadBitmap(GetResources(), "LBOK")		//Objeto de sinalizacao
Local oNo      := LoadBitmap(GetResources(), "LBNO")		//Objeto de sinalizacao
Local oNoc     := LoadBitmap(GetResources(), "BR_VERMELHO")	//Objeto de sinalizacao
Local nI       := 0											//Controle de loop		
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Permissao "Atualizacao Geral Check-Out" - #14 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LJProFile(14)
	DbSelectArea('SLG')
	DbSetOrder(1)		//LG_FILIAL+LG_CODIGO
	DbSeek(xFilial())
	While LG_FILIAL==xFilial() .AND. !Eof()
	   If Val(LG_CODIGO)<=Len(aConnected) .AND. Val(LG_CODIGO)>0
	      AAdd(aEstacao, {3, LG_NOME, LG_CODIGO})
	      If aConnected[Val(LG_CODIGO)][1] <> CL_DESCONECTADO 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	         aEstacao[Len(aEstacao),1] := 1 					//³ Conectado  ³
	      EndIf                                                	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   EndIf   
	   DbSkip()
	End    
	If Len(aEstacao)>0
		DEFINE MSDIALOG oWndComp TITLE STR0031 FROM 165,115 TO 545,525 OF GetWndDefault() PIXEL		//"Atualização total no Check-Out"
		
		@ 175,10 BITMAP NAME "BR_VERMELHO"	SIZE 7,7 OF oWndComp PIXEL NO BORDER
		@ 175,20 SAY STR0047 OF oWndComp PIXEL SIZE 100,7	               							// "Estações desconectadas"
		@ 03, 10 TO 45, 195 LABEL "" OF oWndComp PIXEL
		@ 10, 15 SAY STR0032 SIZE 175, 8 OF oWndComp PIXEL											//"Este processo irá atualizar TODAS as tabelas no Check-Out."
		@ 20, 15 SAY STR0033 SIZE 175, 8 OF oWndComp PIXEL											//"Certifique-se de que o Check-Out desejado está conectado."
		@ 30, 15 SAY STR0034 SIZE 175, 8 OF oWndComp PIXEL COLOR CLR_RED							//"Atenção!!! Este processo levará alguns minutos."
		
		@ 50,10 LISTBOX oEstacao FIELDS HEADER "",STR0048 SIZE 185,120 PIXEL OF oWndComp			// "Estação"
		oEstacao:SetArray(aEstacao)
		oEstacao:bLDblClick := {|| ( aEstacao[oEstacao:nAt,1] := If(aEstacao[oEstacao:nAt,1]=3,3,If(aEstacao[oEstacao:nAt,1]=1,2,1)))}
		oEstacao:bLine      := {|| { If(aEstacao[oEstacao:nAt,1]=3,oNoc,If(aEstacao[oEstacao:nAt,1]=1,oNo,oOk)),;
		aEstacao[oEstacao:nAt,2]}}
		
		DEFINE SBUTTON FROM 175,141 TYPE 1 ACTION (If(aScan( aEstacao, {| ExpA1 | ExpA1[1] == 2} ) == 0,MsgStop( STR0054, STR0002 ),nSucess:=1),If(nSucess==1,oWndComp:End(),NIL)) ENABLE PIXEL OF oWndComp//"Selecione pelo menos uma estação para efetuar a carga"
		DEFINE SBUTTON FROM 175,170 TYPE 2 ACTION (nSucess:=0,oWndComp:End()) ENABLE PIXEL OF oWndComp
		
		ACTIVATE DIALOG oWndComp CENTERED
		If nSucess == 1
			For nI := 1 To Len(aEstacao)
				If aEstacao[nI,1] == 2
					FRTGeraSLI(aEstacao[nI,3], "COM", "SEND", "SOBREPOE")
				EndIf
			Next nI
		EndIf
	EndIf
Else
   	MsgStop(STR0053, STR0002)	//"Usuario sem permissao para atualizacao total no check-out."###"Atencao" 						
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³ FRTCarga ³ Autor ³ Vendas Clientes       ³ Data ³13/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Carga nas Estacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array para armazenamento das tabelas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTCarga( aFiles )
Local oWndFiles											//Objeto para criacao da tela 'Atualizar arquivos nas estacoes'
Local oFilesSel											//Objeto auxiliar ao array aFilesSel
Local aFilesSel  := {}									//Array que contem os arquivos para a geracao da carga
Local oInverte											//Objeto que auxilia a variavel lInverte
Local lInverte   := .T.									//Inverte selecao dos arquivos?
Local oOk        := LoadBitmap(GetResources(), "LBOK")	//Objeto de sinalizacao
Local oNo        := LoadBitmap(GetResources(), "LBNO")	//Objeto de sinalizacao
Local nI     	 := 0									//Controle de loop
Local nJ         := 0									//Controle de loop
Local nK         := 0									//Controle de loop	
Local nField     := 0									//Armazenamento de posicoes 
Local nPos       := 0									//Armazenamento de posicoes 		
Local nSucess    := 1									//Controla o clique no botao	
Local cOrdem     := "000001"							//Ordem das cargas
Local cFilCarga  := ""									//Filial
Local lPriCarga  := .F.           						//Verifica se eh a primeira carga
Local aFiliais	 := {}									//Array que armazena as filiais do sistema
Local aFilesFil  := {}        							//Array que armazena FILIAIS + ARQUIVOS
Local lLiberado  := .F.									//Verifica se a carga esta liberada
Local lLiberult  := .F.									//Verifica o status da ultima sequencia de um arquivo
Local cFilAux    := Space(FWGETTAMFILIAL) 					//Variavel auxiliar para FILIAIS
Local lMostraMsg := .T.									//Conrtole para a visualizacao da mensagem de alerta
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina se utiliza Geração/Liberação de Carga MultiFilial, 0 = Não Utiliza, 1 = Utiliza  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nMV_LJCRGAU   	:= SuperGetMV("MV_LJCRGAU",.F.,0)
Local lFazProcessamento := .T.							//Controla somente uma geracao de cargas para arquivos compartilhados.
Local lFRTFILAT			:= ExistFunc("U_FRTFILAT()")	//Verifica se o ponto de entrada esta' compilado	
Local lFilAt	 		:= .T.							//Retorno do ponto de entrada
Local cTabPadrao		:= ""							//parametro da tabela de preco padrao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando Array com as Filiais                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFiliais  := {}
SM0->(DbSeek(cEmpAnt))
While SM0->M0_CODIGO == cEmpAnt .AND. !SM0->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. Para Verificar se a Filial esta ativa para geração de Carga.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lFRTFILAT
		LjGrvLog( NIL, "Antes da execução do P.E. FRTFILAT", FWGETCODFILIAL)
		lFilAt := U_FRTFILAT(FWGETCODFILIAL) //codigo da filial
		LjGrvLog( NIL, "Depois da execução do P.E. FRTFILAT", lFilAt)
		If ValType(lFilAt) == "L"
			If !lFilAt
				SM0->(DbSkip())
				Loop
			EndIf
		Endif
	Endif	
	
	AAdd(aFiliais, {FWGETCODFILIAL})	
	SM0->(DbSkip())
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reposiciona o arquivo SIGAMAT.EMP            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SM0->(DbSeek(cEmpAnt+cFilAnt))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando Array com Arquivo/Filial + SEQ      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFilesFil := {}
For nI := 1 To Len(aFiles) 			// Tabelas a serem enviadas para o PDV
	For nK := 1 To Len(aFiliais) 	// Filiais para qual vai fazer a Carga
		cArquivo 	:= aFiles[nI]
		CARGA->(DbSetOrder(3))
		If CARGA->(DbSeek(cArquivo+aFiliais[nK][1]))
			cSEQ        := " "
			lLiberult   := .F.
			lLiberado   := .F.
			
			cFilAux     := CARGA->FILIAL
			While CARGA->(!Eof()) .AND. CARGA->ARQUIVO == cArquivo  .AND. CARGA->FILIAL == cFilAux
				cDataSEQ    := DToC(CARGA->DATASEQ)
				cHORASEQ    := CARGA->HORASEQ
				If FRTSX2Excl(cArquivo) .AND. nMV_LJCRGAU == 0
					If CARGA->FILIAL <> cFilAnt
						CARGA->(DbSkip())
						Loop
					EndIf
				EndIf
				If CARGA->SEQ + DToC(CARGA->DATASEQ) + CARGA->HORASEQ > cSEQ + cDataSEQ + cHORASEQ
					cSEQ      := CARGA->SEQ
					cDataSEQ  := DToC(CARGA->DATASEQ)
					cHORASEQ  := CARGA->HORASEQ
				Endif
				lLiberult := CARGA->LIBERADO
				CARGA->(DbSkip())
			End
			If FRTSX2Excl(cArquivo)
				If nMV_LJCRGAU == 0
					If cFilAux == cFilAnt
						If lLiberult
							lLiberado := .T.
						Endif	
					EndIf
				Else
					If lLiberult
						lLiberado := .T.
					Endif	
				EndIf
			Else
				If lLiberult
					lLiberado := .T.
				Endif	
			EndIf
			AAdd(aFilesFil, {aFiles[nI], aFiliais[nK][1], cSEQ, lLiberado})
		Else
			AAdd(aFilesFil, {aFiles[nI], aFiliais[nK][1], "000000", .F.})
		EndIf
	Next nk
Next nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando Array com as Tabelas para Geração de Carga   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFilesSel := {}
For nI := 1 To Len(aFiles)
	SX2->(DbSeek(aFiles[nI]))
	AAdd(aFilesSel, {.T., aFiles[nI], AllTrim(X2Nome())})
Next nI

If Len(aFilesSel) == 0
	MsgStop(STR0006, STR0002) // "Nenhuma carga pode ser gerada, pois nem todas as estações foram atualizadas." ### "Atenção"  
	Return(.F.)
EndIf
                          
If CARGA->(LastRec()) <> 0
    If nMV_LJCRGAU == 0
    	cFilCarga := cFilAnt+"/  "
    Else
	   	cFilCarga := FRTOpcaoFil()
	    If cFilCarga == "-1"
		   	Return(.F.)
	    EndIf
	EndIf
Else
	lPriCarga := .T.
EndIf

If CARGA->(LastRec()) <> 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando Janela de Escolha de Filiais para Geração de Carga             ³
//³ A Janela só será ativada a partir da primeira Carga                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oWndFiles TITLE STR0007 FROM 10,15 TO 310,320 OF GetWndDefault() PIXEL	// "Atualizar arquivos nas estações"
			
		@ 2,2 LISTBOX oFilesSel FIELDS HEADER "",STR0008,STR0009 FIELDSIZES 14, 20, 40 SIZE 150,133 PIXEL OF oWndFiles	// "Arquivo" "Descrição"
		oFilesSel:SetArray(aFilesSel)
		oFilesSel:bLDblClick := {|| (aFilesSel[oFilesSel:nAt,1] := !aFilesSel[oFilesSel:nAt,1])}
		oFilesSel:bLine := {|| {If(aFilesSel[oFilesSel:nAt,1],oOk,oNo),;
								aFilesSel[oFilesSel:nAt,2],;
								aFilesSel[oFilesSel:nAt,3]}}

		@ 137,2 CHECKBOX oInverte VAR lInverte PROMPT STR0043 SIZE 60,8 PIXEL OF oWndFiles ON CHANGE {|| aEval(aFilesSel, {|x| x[1]:=!x[1]}), oFilesSel:Refresh() }	// "Inverte Seleção"

		DEFINE SBUTTON FROM 137, 95 TYPE 1 ACTION oWndFiles:End() ENABLE PIXEL OF oWndFiles
		DEFINE SBUTTON FROM 137,125 TYPE 2 ACTION (nSucess:=0,oWndFiles:End()) ENABLE PIXEL OF oWndFiles
			
	ACTIVATE DIALOG oWndFiles CENTERED
EndIf

If nSucess == 0
	Return(.F.)
EndIf

DbSelectArea("CARGA")
DbSetOrder(2)
DbGoBottom()
If !(BOF() .AND. Eof())
	cOrdem := StrZero(Val(CARGA->ORDEM)+1,6)
EndIf
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerando os Arquivos de Carga... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aFilesSel)
	lMostraMsg := .T.							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If aFilesSel[nI][1]                      	//³ aFilesSel, {.T. ### aFiles[nI] ### AllTrim(X2Nome()) } ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos := AScan(aFilesFil, {|x| x[1] == aFilesSel[nI][2]})) > 0
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			For nJ := nPos To Len(aFilesFil) 	//³ aFilesFil, {CARGA->ARQUIVO ### CARGA->FILIAL ### CARGA->SEQ ### CARGA->LIBERADO} ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aFilesFil[nJ][1] <> aFilesSel[nI][2]
					lFazProcessamento := .T.
					Exit
				EndIf

				If (nMV_LJCRGAU == 0 .AND. ((aFilesFil[nJ][2] <> cFilAnt) .AND. FRTSX2Excl(aFilesFil[nJ][1])))
					Loop
				EndIf
				
				If nMV_LJCRGAU == 1
					If !lPriCarga
						If FRTSX2Excl(aFilesFil[nJ][1])
							If !(aFilesFil[nJ][2] $ cFilCarga)
								Loop
							EndIf
						Endif
					EndIf
				EndIf
				
				cFilAux   := aFilesFil[nJ][2]
				cArquivo  := aFilesFil[nJ][1]
				cCargaSEQ := aFilesFil[nJ][3]
				cCargaNEW := StrZero(Val(cCargaSEQ)+1,6)
				
				lFim := .F.
				
				DbSelectArea("CARGA")
				DbSetOrder(1)
				If !DbSeek(cFilAux+cArquivo+cCargaSEQ)
					lFim := .T.
				EndIf
				
				If lPriCarga
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ "Aguarde. Gerando a carga " ### " do arquivo " ### " da Filial "  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFazProcessamento
						LjMsgRun(STR0010+cCargaNEW+STR0011+cArquivo+If(FRTSX2Excl(cArquivo),STR0057+cFilAux+"...",""),,{|| nSucess := GeraCarga(cArquivo, cFilAux)})
					Endif
					
					If !FRTSX2Excl(aFilesFil[nJ][1]) .AND. cArquivo == aFilesSel[nI][2]
						lFazProcessamento := .F.
					Endif
				Else
					If aFilesFil[nJ][4] .OR. (aFilesFil[nJ][3]=="000000" .AND. lFim)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ "Aguarde. Gerando a carga " ### " do arquivo "  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFazProcessamento
							LjMsgRun(STR0010+cCargaNEW+STR0011+cArquivo+If(FRTSX2Excl(cArquivo),STR0057+cFilAux+"...",""),,{|| nSucess := GeraCarga(cArquivo, cFilAux)})
						Endif
						
						If !FRTSX2Excl(aFilesFil[nJ][1]) .AND. cArquivo == aFilesSel[nI][2]
							lFazProcessamento := .F.
						Endif
					Else
						If !FRTSX2Excl(aFilesFil[nJ][1]) .AND. cArquivo == aFilesSel[nI][2]
							If lMostraMsg
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ "Para gerar uma nova Carga do Arquivo " ### ", primeiramente libere-o!", "Atenção" ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								MsgStop(STR0027+cArquivo+STR0028, STR0002)
								nSucess := 0
								lMostraMsg := .F.
							Endif
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ "Para gerar uma nova Carga do Arquivo " ### ", primeiramente libere-o!", "Atenção" ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							MsgStop(STR0027+cArquivo+STR0057+cFilAux+STR0028, STR0002)
							nSucess := 0
						Endif
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ 0 - Erro                     ³
				//³ 1 - OK                       ³
				//³ 2 - O Arquivo foi modificado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nSucess == 0
					If lPriCarga
						Exit
					Else
						Loop
					EndIf
				ElseIf nSucess == 1
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ "Excluindo os arquivos gerados que não tiveram atualização ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !FRTSX2Excl(cArquivo)
						cDireto := cMV_DIRCFRT+FRT_EMPFIL
					Else
						cDireto := cMV_DIRCFRT+ALLTRIM("CRG"+cEmpAnt+cFilAux) + "\"
					EndIf
					If File(cDireto+cCargaNEW+cArquivo+"."+cEmpAnt)
						FErase(cDireto+cCargaNEW+cArquivo+"."+cEmpAnt)
					EndIf
					If File(cDireto+cCargaNEW+cArquivo+"."+cEmpAnt+"X")
						FErase(cDireto+cCargaNEW+cArquivo+"."+cEmpAnt+"X")
					EndIf
				ElseIf nSucess == 2
					If lPriCarga
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Na primeira Carga, gera-se todos os registros das tabelas em \data\carga\carga990.frt ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("CARGA")
						DbAppend()
						CARGA->FILIAL     := cFilAux
						CARGA->ORDEM      := cOrdem
						CARGA->ARQUIVO    := cArquivo
						CARGA->SEQ        := cCargaNEW
						CARGA->DATASEQ    := dDataBase
						CARGA->HORASEQ    := Time()
						CARGA->LIBERADO   := .F.
						CARGA->BLOQUEADO  := .F.
						DbCommit()
					Else
						If FRTSx2Excl(cArquivo)
							If cFilAux $ cFilCarga
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Tabelas Exclusivas após a geração da Primeira Carga em carga990.frt tem de obedecer as Filiais escolhidas em FRTConsisVet() chamdo pela FRTOpcaoFil() ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ aFilesFil, {CARGA->ARQUIVO, CARGA->FILIAL, CARGA->SEQ, CARGA->LIBERADO} ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If (nField := AScan(aFilesFil, {|x| x[1]+x[2] == cArquivo+cFilAux})) > 0
									If aFilesFil[nField][4] .OR. (aFilesFil[nJ][3]=="000000" .AND. lFim)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Gera-se Tabelas Exclusiva em carga990.frt liberadas ou Tabelas que ainda não foram geradas em carga990.frt ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										DbAppend()
										CARGA->FILIAL     := cFilAux
										CARGA->ORDEM      := cOrdem
										CARGA->ARQUIVO    := cArquivo
										CARGA->SEQ        := cCargaNEW
										CARGA->DATASEQ    := dDataBase
										CARGA->HORASEQ    := Time()
										CARGA->LIBERADO   := .F.
										CARGA->BLOQUEADO  := .F.
										DbCommit()
									EndIf
								EndIf
							EndIf
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Gera-se Tabelas Compartilhadas em carga990.frt bastam estarem liberadas  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (nField := AScan(aFilesFil, {|x| x[1]+x[2] == cArquivo+cFilAux})) > 0
								If aFilesFil[nField][4]
									DbAppend()
									CARGA->FILIAL     := cFilAux
									CARGA->ORDEM      := cOrdem
									CARGA->ARQUIVO    := cArquivo
									CARGA->SEQ        := cCargaNEW
									CARGA->DATASEQ    := dDataBase
									CARGA->HORASEQ    := Time()
									CARGA->LIBERADO   := .F.
									CARGA->BLOQUEADO  := .F.
									DbCommit()
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nJ
		EndIf
	EndIf
Next nI

Return( nSucess <> 0 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FRTLibera ³ Autor ³ Vendas Clientes       ³ Data ³18/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a liberacao da Carga para as Estacoes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array para armazenamento das tabelas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTLibera( aFiles )
Local nI 		  := 0											//Controle de loop
Local oWndFiles													//Objeto para a criacao da tela de Liberacao de cargas		
Local oFilesSel													//Objeto auxiliar para a montagem do cabecalho da tela
Local aFilesSel	  := {}											//Array que armazena as informacoes dos arquivos para a liveracao/bloqueio das cargas
Local oOk		  := LoadBitmap(GetResources(), "BR_VERDE")		//Objeto de sinalizacao	- LIBERADO
Local oNo		  := LoadBitmap(GetResources(), "BR_VERMELHO")	//Objeto de sinalizacao - BLOQUEADO
Local oAm		  := LoadBitmap(GetResources(), "BR_AMARELO")	//Objeto de sinalizacao - PARCIALMENTE
Local cArquivo													//Arquivo que sera processado para a carga	
Local aFiliais    :=  {}										//Array que armazena as filiais do sistema	
Local nSoma       := 0											//Variavel auxilia a definicao do status do arquivo
Local nMulti      := 1											//Variavel auxilia a definicao do status do arquivo
Local nCor        := 0                 							//Variavel auxilia a definicao do status do arquivo
Local cFilAux     := "" 										//Variavel auxiliar para a filial
Local lLiberult   := .F.										//Verifica o status da ultima sequencia de um arquivo
Local lLiberado   := .F.										//Verifica o status do arquivo
Local nFil        := 0											//Variavel auxiliar
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina se utiliza Geração/Liberação de Carga MultiFilial, 0 = Não Utiliza, 1 = Utiliza  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nMV_LJCRGAU   := SuperGetMV("MV_LJCRGAU",.F.,0)    
Local lFRTFILAT		:= ExistFunc("U_FRTFILAT()")	//Verifica se o ponto de entrada esta' compilado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aFiliais - Filiais                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFiliais  := {}
SM0->(DbSeek(cEmpAnt))
While SM0->M0_CODIGO == cEmpAnt .AND. !SM0->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. Para Verificar se a Filial esta ativa para geração de Carga.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lFRTFILAT
		LjGrvLog( NIL, " Antes da execução do P.E. FRTFILAT", FWGETCODFILIAL)
		lFilAt := U_FRTFILAT(FWGETCODFILIAL) //codigo da filial
		LjGrvLog( NIL, " Depois da execução do P.E. FRTFILAT", lFilAt)
		If ValType(lFilAt) == "L"
			If !lFilAt
				SM0->(DbSkip())
				Loop
			EndIf
		Endif
	Endif	
	AAdd(aFiliais, {FWGETCODFILIAL})	
	SM0->(DbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reposiciona o arquivo SIGAMAT.EMP            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SM0->(DbSeek(cEmpAnt+cFilAnt))
CARGA->(DbSetOrder(1))
aFilesSel	:= {}
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preparando a Tela de Liberação                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aFiles)
	cArquivo := aFiles[nI]
	CARGA->(DbSetOrder(3))
	If CARGA->(DbSeek(cArquivo))
		cSEQ        := " "
		cDataSEQ    := DToC(CTOD("01/01/01"))
		cHORASEQ    := " "
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		nCor		:= 0   	//³ Verde +1 ### Amarelo 0 ### Vermelho -1			³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSoma       := 0
		nMulti      := 1
		lLiberult   := .F.
		lLiberado   := .F.   
		
		nFil        := 0
		While CARGA->(!Eof()) .AND. CARGA->ARQUIVO == cArquivo
			cFilAux     := CARGA->FILIAL   
			While CARGA->(!Eof()) .AND. CARGA->ARQUIVO == cArquivo  .AND. CARGA->FILIAL == cFilAux
				If !Empty(CARGA->ESTACAO)
		        	CARGA->(DbSkip())
					Loop
				EndIf
				If FRTSX2Excl(cArquivo) .AND. nMV_LJCRGAU == 0
					If CARGA->FILIAL <> cFilAnt
						CARGA->(DbSkip())
						Loop
					EndIf
				EndIf
				If CARGA->SEQ > cSEQ	
					nFil := 1
				Else
				    If !FRTSX2Excl(cArquivo) .AND. CARGA->SEQ == cSEQ
				    	nFil += 1
				    EndIf
				Endif
				If CARGA->SEQ + DToC(CARGA->DATASEQ) + CARGA->HORASEQ > cSEQ + cDataSEQ + cHORASEQ
					cSEQ     := CARGA->SEQ
					cDataSEQ := DToC(CARGA->DATASEQ)
					cHORASEQ := CARGA->HORASEQ
				EndIf
				
				lLiberult := CARGA->LIBERADO
				
				CARGA->(DbSkip())
			End
			If !Empty(cSEQ)
				If nMV_LJCRGAU == 0				
					If cFilAux == cFilAnt
	                    If lLiberult
							lLiberado := .T.
						Endif
					EndIf
				Else
					If lLiberult
						nSoma += 0
						nMulti *= 0
						lLiberado := .T.
					Else
						nSoma += 1
						nMulti*= 1
					Endif
				EndIf
			Endif
		End
		
		If !Empty(cSEQ)
			If FRTSX2Excl(cArquivo)
				If nMV_LJCRGAU == 0
					If lLiberado
						nCor := 1
					Else
						nCor := -1
					Endif					
				Else
					If lLiberado
						If nSoma == 0
							nCor := 1
						Else
							nCor := 0
						Endif
					Else
						If nMulti == 1
							nCor := -1
						Else
							nCor := 0
						Endif					
					Endif
				EndIf
				SX2->(DbSeek(cArquivo))
				AAdd(aFilesSel, {lLiberado, cArquivo, AllTrim(X2Nome()), cSEQ, cDATASEQ, cHORASEQ, nCor})
			Else
				If nFil == Len(aFiliais)
					If lLiberado      
						If nSoma == 0
							nCor := 1
						Else       
							nCor := 0
						Endif
					Else 
						If nMulti == 1
							nCor := -1
						Else
							nCor := 0
						Endif
					Endif
					SX2->(DbSeek(cArquivo))
					AAdd(aFilesSel, {lLiberado, cArquivo, AllTrim(X2Nome()), cSEQ, cDATASEQ, cHORASEQ, nCor})
	            EndIf
			EndIf
		EndIf
	EndIf
Next nI

If Len(aFilesSel) > 0
	DEFINE MSDIALOG oWndFiles TITLE STR0012 FROM 10,15 TO 310,320 OF GetWndDefault() PIXEL	// "Liberar Carga dos arquivos para as estações"
			
		@ 2,2 LISTBOX oFilesSel FIELDS HEADER "",STR0013,STR0014,STR0015,STR0016,STR0017 FIELDSIZES 14, 20, 80, 30, 35, 20 SIZE 150,133 PIXEL OF oWndFiles	// "","Arquivo","Descrição", "Seqüência", "Data", "Hora"
		oFilesSel:SetArray(aFilesSel)

		oFilesSel:bLDblClick := {|| LiberaClick(@oFilesSel, @aFilesSel )}

		oFilesSel:bLine := {|| {If(aFilesSel[oFilesSel:nAt,7]==0,oAm,If(aFilesSel[oFilesSel:nAt,7]==1,oOk,oNo)),;
								aFilesSel[oFilesSel:nAt,2],;
								aFilesSel[oFilesSel:nAt,3],;
								aFilesSel[oFilesSel:nAt,4],;
								aFilesSel[oFilesSel:nAt,5],;
								aFilesSel[oFilesSel:nAt,6]}}
        If nMV_LJCRGAU == 1
			@ 137,83 BUTTON STR0058 SIZE 40,13 OF oWndFiles PIXEL ACTION ( Frt040Legenda()) //"Legenda"
		EndIf
		
		DEFINE SBUTTON FROM 137,125 TYPE 1 ACTION oWndFiles:End() ENABLE PIXEL OF oWndFiles
		
			
	ACTIVATE DIALOG oWndFiles CENTERED
Else
	MsgStop(STR0059, STR0002) // "Não há Carga a ser liberada, favor gerar!"
EndIf    

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³LiberaClick³ Autor ³ Vendas Clientes       ³ Data ³14/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a Liberação de Carga de Estacoes                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Objeto auxiliar ao array aFilesSel                   ³±±
±±³          ³ExpA1 - Array que contem os arquivos para a geracao da carga ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FRTA040                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LiberaClick( oFilesSel, aFilesSel )
Local aFilCarga := {}														//Array que armazena informacoes dos arquivos para a geracao da carga
Local nI		:= 0														//Controle de loop
Local lExcOuCom := If(FRTSX2Excl(aFilesSel[oFilesSel:nAt,2]),.T.,.F.)  		//Verifica se o arquivo eh exclusivo ou compartilhado  
Local nSoma     := 0														//Variavel auxilia a definicao do status do arquivo
Local nMulti    := 1														//Variavel auxilia a definicao do status do arquivo
Local lFaz      															//controla a LIBERCAO/BLOQUEIO do arquivo para a carga                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina se utiliza Geração/Liberação de Carga MultiFilial, 0 = Não Utiliza, 1 = Utiliza  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nMV_LJCRGAU  := SuperGetMV("MV_LJCRGAU",.F.,0)

If lExcOuCom 				// Exclusivo
	If nMV_LJCRGAU == 0    // Não Multi-Filial
    	If aFilesSel[oFilesSel:nAt,1]
   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
			//³ "Deseja BLOQUEAR a carga para o arquivo " ### "?", "Atenção"  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lFaz := MsgYesNo(STR0018+aFilesSel[oFilesSel:nAt,2]+STR0019, STR0002)
        Else                                                                            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
			//³ "Deseja LIBERAR a carga para o arquivo " ### "?", "Atenção"   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lFaz := MsgYesNo(STR0020+aFilesSel[oFilesSel:nAt,2]+STR0019, STR0002)
        EndIf
        If lFaz
			aFilesSel[oFilesSel:nAt,1] := !aFilesSel[oFilesSel:nAt,1]

            If aFilesSel[oFilesSel:nAt,1]
				aFilesSel[oFilesSel:nAt,7] := 1
			Else
				aFilesSel[oFilesSel:nAt,7] := -1
			Endif	
			
			DbSelectArea("CARGA")
			DbSetOrder(3) 	//ARQUIVO+FILIAL+SEQ
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
			//³ aFilesSel[nAt][1] 	lLiberado 			³
			//³ aFilesSel[nAt][2] 	cArquivo           	³
			//³ aFilesSel[nAt][3]	AllTrim(X2Nome())	³
			//³ aFilesSel[nAt][4]	cSEQ			 	³
			//³ aFilesSel[nAt][5]	cDATASEQ		 	³
			//³ aFilesSel[nAt][6]	cHORASEQ         	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If DbSeek(aFilesSel[oFilesSel:nAt,2]+cFilAnt+aFilesSel[oFilesSel:nAt,4])
				RecLock("CARGA", .F.)
				CARGA->LIBERADO := !CARGA->LIBERADO
				DbCommit()
				MsUnLock()
			EndIf
		EndIf
    Else                                                                                              
	   	aFilCarga	:= FRTTelaBloqFil(oFilesSel, aFilesSel )
		If Len(aFilCarga) > 0
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
			//³ aFilCarga[nI][1]	CARGA->LIBERADO										³	
			//³ aFilCarga[nI][2]	CARGA->ARQUIVO                                   	³
			//³ aFilCarga[nI][3]	SM0->M0_CODIGO+" / "+FWGETCODFILIAL					³
			//³ aFilCarga[nI][4]	AllTrim(SM0->M0_NOME)+" / "+AllTrim(SM0->M0_FILIAL)	³
			//³ aFilCarga[nI][5]	FWGETCODFILIAL                                  	³
			//³ aFilCarga[nI][6]	CARGA->SEQ                                         	³
			//³ aFilCarga[nI][7]	CARGA->DATASEQ                                      ³
			//³ aFilCarga[nI][8]	CARGA->HORASEQ                                     	³
			//³ aFilCarga[nI][9]	CARGA->(RECNO())                                   	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aFilesSel[oFilesSel:nAt,1] := .F.
		    nSoma  := 0
		    nMulti := 1
			For nI := 1 to Len(aFilCarga)
				CARGA->(DbGoto(aFilCarga[nI][9]))
				CARGA->(RecLock("CARGA", .F.))

                If aFilCarga[nI][1]
					CARGA->LIBERADO := .T.
				Else
					CARGA->LIBERADO := .F.
				Endif

			    If aFilCarga[nI][1]
				    aFilesSel[oFilesSel:nAt,1] := .T.
			    Else
				    aFilesSel[oFilesSel:nAt,1] := aFilesSel[oFilesSel:nAt,1]
			    Endif
                
                If aFilCarga[nI][1] 
				    nSoma  += 0
				Else    
				    nSoma  += 1				    
				Endif
				If aFilCarga[nI][1]
				    nMulti *= 0
				Else 
				    nMulti *= 1				   
    			Endif
				CARGA->(DbCommit())
				CARGA->(MsUnLock())
			Next nI
			
			If aFilesSel[oFilesSel:nAt,1]
				If nSoma == 0
					aFilesSel[oFilesSel:nAt,7] := 1
				Else
					aFilesSel[oFilesSel:nAt,7] := 0
				Endif
			Else
				If nMulti == 1
					aFilesSel[oFilesSel:nAt,7] := -1
				Else
					aFilesSel[oFilesSel:nAt,7] := 0
				Endif			
			Endif            

		EndIf
	EndIf	                                                        
Else //Compartilhado
	If nMV_LJCRGAU == 0  
    	If aFilesSel[oFilesSel:nAt,1]       
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	    	
			//³ "Deseja BLOQUEAR a carga para o arquivo " ### "?", "Atenção"  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			lFaz := MsgYesNo(STR0018+aFilesSel[oFilesSel:nAt,2]+STR0019, STR0002)
        Else                                    
   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	    	
			//³ "Deseja LIBERAR a carga para o arquivo " ### "?", "Atenção"	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			lFaz := MsgYesNo(STR0020+aFilesSel[oFilesSel:nAt,2]+STR0019, STR0002)
        EndIf
    Else
       lFaz:= .T.
    EndIf   
       
    If lFaz
		aFilesSel[oFilesSel:nAt,1] := !aFilesSel[oFilesSel:nAt,1]

        If aFilesSel[oFilesSel:nAt,1]
			aFilesSel[oFilesSel:nAt,7] := 1
		Else
			aFilesSel[oFilesSel:nAt,7] := -1		
		Endif

		DbSelectArea("CARGA")
		DbSetOrder(3) 	//ARQUIVO+FILIAL+SEQ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
		//³ aFilesSel[nAt][1] 	lLiberado 			³
		//³ aFilesSel[nAt][2] 	cArquivo           	³
		//³ aFilesSel[nAt][3]	AllTrim(X2Nome())	³
		//³ aFilesSel[nAt][4]	cSEQ			 	³
		//³ aFilesSel[nAt][5]	cDATASEQ		 	³
		//³ aFilesSel[nAt][6]	cHORASEQ         	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DbSeek(aFilesSel[oFilesSel:nAt,2])
			While aFilesSel[oFilesSel:nAt,2]==CARGA->ARQUIVO .AND. !Eof()
				If CARGA->SEQ = aFilesSel[oFilesSel:nAt,4]
					RecLock("CARGA", .F.)
					CARGA->LIBERADO := !CARGA->LIBERADO
					DbCommit()
					MsUnLock()
				EndIf                           
				DbSkip()
			End
		EndIf
	EndIf
EndIf
		
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³OpenCARGA ³ Autor ³ Vendas Clientes       ³ Data ³14/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Abertura do Arquivo de Carga de Estacoes         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Indica se o arquivo CARGAXXYY.frt sera'            ³±±
±±³          ³         compartilhado ou nao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OpenCARGA( lShared )
Local lSucess	:= .T.	//Controle de erros
Local aArqCarga := {}	//Array que armazena a estrutura do arquivo de carga CARGAxxx.frt
Local nTamFil	:= 0

DEFAULT lShared := .F.		//Compartilhamento do arquivo CARGAxxx.frt

cMV_DIRCFRT := ALLTRIM(SuperGetMV("MV_DIRCFRT"))

If !Empty(cMV_DIRCFRT) .AND. !File(cMV_DIRCFRT+FRT_DBFCARGA)
	If FWGETTAMFILIAL <> Len(cFilAnt)
		nTamFil := Len(cFilAnt)
	Else
		nTamFil := FWGETTAMFILIAL
	EndIf
	
	aArqCarga := {	{	"FILIAL"	,  "C",  nTamFil, 0},;
				  	{	"ORDEM"		,  "C",  6, 0},;
				  	{	"ARQUIVO"	,  "C",  3, 0},;
				  	{	"SEQ"		,  "C",  6, 0},;
				  	{	"DATASEQ"	,  "D",  8, 0},;
				  	{	"HORASEQ"	,  "C",  8, 0},;
				  	{	"LIBERADO"	,  "L",  1, 0},;
				  	{	"BLOQUEADO"	,  "L",  1, 0},;
				  	{	"ESTACAO"	,  "C", 999, 0} }

	FrtCriaTrb(,,cMV_DIRCFRT+FRT_DBFCARGA,aArqCarga,"CARGA")
	If NetErr()
		lSucess := .F.
	Else
		INDEX ON FILIAL+ARQUIVO+SEQ 		TAG CARGA1 TO (cMV_DIRCFRT+FRT_CDXCARGA)
		INDEX ON FILIAL+ORDEM       		TAG CARGA2 TO (cMV_DIRCFRT+FRT_CDXCARGA)
		INDEX ON ARQUIVO+FILIAL+SEQ 		TAG CARGA3 TO (cMV_DIRCFRT+FRT_CDXCARGA)     
		DbSetOrder(1)
		DbCloseArea()
	EndIf
EndIf

If lSucess
	FrtCriaTrb(.F.,,cMV_DIRCFRT+FRT_DBFCARGA,,"CARGA",lShared)
	If NetErr()
		lSucess := .F.
	Else
		If !File(cMV_DIRCFRT+FRT_CDXCARGA)
			DbCloseArea()
			FrtCriaTrb(.F.,,cMV_DIRCFRT+FRT_DBFCARGA,,"CARGA")
			If NetErr()
				lSucess := .F.
			Else
				INDEX ON FILIAL+ARQUIVO+SEQ 		TAG CARGA1 TO (cMV_DIRCFRT+FRT_CDXCARGA)
				INDEX ON FILIAL+ORDEM     	  		TAG CARGA2 TO (cMV_DIRCFRT+FRT_CDXCARGA)
				INDEX ON ARQUIVO+FILIAL+SEQ 		TAG CARGA3 TO (cMV_DIRCFRT+FRT_CDXCARGA)     
				DbSetOrder(1)
				DbCloseArea()
				FrtCriaTrb(.F.,,cMV_DIRCFRT+FRT_DBFCARGA,,"CARGA",lShared)
				If NetErr()
					lSucess := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	If lSucess
		DbClearIndex()
		DbSetIndex(cMV_DIRCFRT+FRT_CDXCARGA)
		If Empty(IndexKey(3))
			DbCloseArea()
			FrtCriaTrb(.F.,,cMV_DIRCFRT+FRT_DBFCARGA,,"CARGA")
			If NetErr()
				lSucess := .F.
			Else
				INDEX ON ARQUIVO+FILIAL+SEQ   TAG CARGA3 TO (cMV_DIRCFRT+FRT_CDXCARGA)
				DbCloseArea()
				FrtCriaTrb(.F.,,cMV_DIRCFRT+FRT_DBFCARGA,,"CARGA")
				If NetErr()
					lSucess := .F.
				Else
					DbClearIndex()
					DbSetIndex(cMV_DIRCFRT+FRT_CDXCARGA)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lSucess

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³OpenSEQNEW³ Autor ³ Vendas Clientes       ³ Data ³19/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Abertura dos Arquivos com as Alteracoes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela                                             ³±±
±±³          ³ ExpC2 - Arquivo que cotem as tabelas para a geracao da carg³±±
±±³          ³ ExpC3 - Diretorio para a criacao do arquivo CARGAxx0.frt   ³±±
±±³          ³ ExpC4 - Indice do arquivo CARGAxx0.frt                     ³±±
±±³          ³ ExpL5 - Indica se o arquivo CARGAXXYY.frt sera'            ³±±
±±³          ³         compartilhado ou nao                               ³±±
±±³          ³ ExpC6 - Diretorio para a gravacao dos carquivos gerados    ³±±
±±³          ³         pela carga                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OpenSEQNEW(	cArquivo, cArq, cFileName, cIndex,;
						    lShared , cDiret )
Local lSucess	:= .T.							//Retorno da funcao
Local cDbf		:= ""							//Nome do arquivo de CARGAS

DEFAULT lShared := .F.							//Compartilhamento do arquivo CARGAxxx.frt
DEFAULT cDiret  := cMV_DIRCFRT + FRT_EMPFIL		//Diretorio para a gravacao dos arquivos gerada pela carga

cDbf := cDiret + cFileName + "." + cEmpAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna FALSE se o alias ja esta sendo utilizado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select( cArq ) > 0  .AND. !FRTSX2Excl(cArquivo)	                           
	Return(.F.)
EndIf

If MsOpenDbf(.T.,"DBFCDX",cDbf,cArq,lShared,.F.,.F.,.F.)
	If "CTREE" $ RealRDD()
		CTreeDelIdxs()
	EndIf

	INDEX ON &(cIndex) TAG &(cArq+"1") TO &(cDbf+"X")
	INDEX ON ALTERADO TAG &(cArq+"2") TO &(cDbf+"X")
Else
	lSucess := .F.
EndIf

Return lSucess

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³GeraCARGA ³ Autor ³ Vendas Clientes       ³ Data ³14/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Abertura do Arquivo de Carga de Estacoes         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela                                             ³±±
±±³          ³ ExpC2 - Filial                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±  
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraCARGA( cArquivo, cFilAux )
Local nI			:= 0	 		//Controle de loop
Local nSucess		:= 1			//Controla se houve alteracao na base de dados para a geracao da carga
Local lCargaFull	:= .F. 			//Indica se esta utilizando a primeira carga
Local lAchouSEQ		:= .F. 			//Controla a busca de um registro da base de dados para o arquivo de carga

//Controla alteracoes nos registros
Local lAlterado		:= .F.
Local lArqAltera	:= .F.
Local lRegAltera	:= .F.
Local lIgnoraReg	:= .F.

Local cProcesso		:=  " "			// Definicao de processos 0-Inclusao, 1-Alteracao, 2-Delecao
Local cSLHChave		:= ""			// Chave do arquivo SLH
Local cSLH			:= ""			// Arquivo temporario SLH
Local cBusca		:= ""			// Chave de busca
Local cChaveAnt		:= ""			// Chave de busca 
Local lDeleted		:= .F.			// Verifica se o arquivo esta deletado
Local lDelAnt		:= .F.			// Verifica se o arquivo esta deletado
Local lRegAt		:= .F.     		// Verifica se existe o Ponto de Entrada "FRTREGAT"
Local lTemSBZ       := .F.         	// Controla se SBZ esta criado
Local lAchouSBZ     := .F.		   	// Controla se encontrou registro no SBZ
Local aArea			:= GetArea()   	// Area atual
Local nMax			:= 0			// Valor do registro do inicio do intervalo de delecao
Local nMin			:= 0			// Valor do registro do final do intervalo de delecao
Local nX			:= 0			// Variavel de controle do looping de delecao
Local cQuery     	:= ""			// Variavel utilizada para montar a query
Local cBanco     	:= ""			// Variavel que guarda o banco utilizado
Local cMV_ARQPROD   := SuperGetMV("MV_ARQPROD",.F.,"SB1")    // Determina se utiliza SB1 ou SBZ para informacoes de estoque
Local cFilTmp       := Space(FWGETTAMFILIAL)			//Filial
Local cFilTmpSLH	:= Space(FWGETTAMFILIAL)			//Filial
Local cFilSB0 		:= cFilAux		//Filial SB0
Local cFilSLH 		:= cFilAux		//Filial SLH
Local cFilSBZ 		:= cFilAux		//Filial SBZ
Local nPosSBI  		:= 0			//Posição do SBI
Local lLjcnvB0		:= SuperGetMv("MV_LJCNVB0",,.F.)		// Retorna preço da SB0 na ausência do preço do Produto na DA0 e DA1
Local lGerBzFul 	:= SuperGetMv("MV_FRTBZFU",,.F.)		// Gera sbz full 
Local aAreaSFM		:= {}			//Guarda Area corrente
Local lExistSFM2	:= .F.			// Verifica existencia do indice 2 da SFM

Private aCampos						//Array que armazena a estrutura das tabelas
Private aCamposA					//Array que armazena campos da tabela SBI
Private aCamposB					//Array que armazena o retorno do Ponto de entrada "FRTGERACAR"
Private uCampo						//Campo das tabelas
Private uCampoB						//Campo das tabelas
Private cIndex						//Indice
Private cChave						//Chave

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ lCargaFull indica se esta sendo realizado a primeira carga. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lCargaFull := (cCargaSEQ == "000000")

If !CARGAFiles(cArquivo, cFilAux)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	    	
	//³"Não foi possível gerar os arquivos de Carga do Arquivo "+cArquivo+".", "Atenção" ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	MsgStop(STR0022+cArquivo+".", STR0002)
	Return(0)
EndIf

SX2->(DbSetOrder(1))
If SX2->(DbSeek("SBZ"))
   If cMV_ARQPROD == "SBZ"
      lTemSBZ  := .T.
   Endif
Endif

DbSelectArea(cArquivo)
aCampos := Array(FCount())

For nI := 1 To FCount()
	If Left(cArquivo,1) == "S"
		aCampos[nI] := {FieldName(nI), "OK_"+Substr(FieldName(nI),4)}
	Else
		aCampos[nI] := {FieldName(nI), "OK_"+Substr(FieldName(nI),5)}
	EndIf
Next nI

If lCenVenda
	If lLjcnvB0
		aCamposA := {{ "BI_PRV"	, "SB0->B0_PRV1" }}	
	Else
		aCamposA := {{ "BI_PRV"	, "SB1->B1_PRV1" }}
    EndIf
Else
	aCamposA := {{ "BI_PRV"		, "SB0->B0_PRV" + AllTrim(MV_PAR01)	}}
EndIf

AADD(aCamposA, { "BI_TABELA"	, "MV_PAR01"		})		//{ "BI_TABELA"	, "'001'"	}, ;		
AADD(aCamposA, { "BI_ALIQRED"	, "SB0->B0_ALIQRED" }) 

If SBI->(FieldPos("BI_POSIPI")) > 0 .AND. cArquivo == "SBI" 
	AADD(aCamposA, { "BI_POSIPI", "SB1->B1_POSIPI" } )
Endif
			 	
If SBI->(FieldPos("BI_IMPNCM")) > 0 .AND. cArquivo == "SBI"
	If SB1->(FieldPos("B1_IMPNCM")) > 0 .AND. cArquivo == "SBI"
		AADD(aCamposA, { "BI_IMPNCM", "SB1->B1_IMPNCM" } )		
	Else
		AADD(aCamposA, { "BI_IMPNCM", "0" } )	
	EndIf
Endif
			 	
If SBI->(FieldPos("BI_IMPORT")) > 0 .AND. cArquivo == "SBI" 
	AADD(aCamposA, { "BI_IMPORT", "SB1->B1_IMPORT" } )		
Endif

If SBI->(FieldPos("BI_ORIGEM")) > 0 .AND. cArquivo == "SBI"
	AADD(aCamposA, { "BI_ORIGEM", "SB1->B1_ORIGEM" } )
Endif

If SB1->(ColumnPos("B1_CEST")) > 0 .AND. SBI->(ColumnPos("BI_CEST")) > 0 .AND. cArquivo == "SBI"
	AADD( aCamposA, {"BI_CEST", "SB1->B1_CEST"} )
EndIf

If SB1->(ColumnPos("B1_CNAE")) > 0 .AND. SBI->(ColumnPos("BI_CNAE")) > 0 .AND. cArquivo == "SBI"
	AADD( aCamposA, {"BI_CNAE", "SB1->B1_CNAE"} )
EndIf

If UPPER(cArquivo) == "SBI"
	If !LjInfocar(.F.)
		nPosSBI := Ascan( aCampos, {|X| x[1] == "BI_DTINFO"} )
		If nPosSBI > 0
			aDel(aCampos, nPosSBI)
			aSize(aCampos, Len(aCampos)-1)
			nPosSBI := 0
		EndIf
		nPosSBI := Ascan( aCampos, {|X| x[1] == "BI_PRVINFO"} )
		If nPosSBI > 0
			aDel(aCampos, nPosSBI )
 			aSize(aCampos, Len(aCampos)-1 )
			nPosSBI := 0 
		EndIf

		// Campo BI_SITTRIB não existe no ambiente México
		nPosSBI := Ascan( aCampos, {|X| x[1] == "BI_SITTRIB"} )
		If nPosSBI > 0
			aDel(aCampos, nPosSBI )
 			aSize(aCampos, Len(aCampos)-1 )
			nPosSBI := 0 
		EndIf
	EndIf
	If (HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))            
	    dbSelectArea("SB1") // FieldPos funciona com a area aberta
		If SBI->(FieldPos("BI_PSICOTR")) > 0 .AND. SB1->(FieldPos("B1_PSICOTR")) > 0
			AADD(aCamposA, { "BI_PSICOTR"	, "SB1->B1_PSICOTR" } )		
		Endif
		If SBI->(FieldPos("BI_REGMS"  )) > 0 .AND. SB1->(FieldPos("B1_REGMS"  )) > 0
			AADD(aCamposA, { "BI_REGMS"		, "SB1->B1_REGMS" } )		
		Endif
		If SBI->(FieldPos("BI_DESCOBR")) > 0 .AND. SB1->(FieldPos("B1_DESCOBR")) > 0
			AADD(aCamposA, { "BI_DESCOBR"	, "SB1->B1_DESCOBR" } )		
	    Endif
		If SBI->(FieldPos("BI_MSBLQL")) > 0  .AND. SB1->(FieldPos("B1_SUSPVEN")) > 0
			AADD(aCamposA, { "BI_MSBLQL"	, "IIF(SB1->B1_SUSPVEN == .T.,'1', SB1->B1_MSBLQL)" } )
	    Endif
		If FieldPos("BI_CLASSTE") > 0 .AND. FieldPos("B1_CLASSTE") > 0
			AADD(aCamposA, { "BI_CLASSTE"	, "SB1->B1_CLASSTE" } )		
		Endif
		DbSelectArea(cArquivo)
	Endif	
EndIf
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificação do campo BI_DIASGAR.                         ³
//³Caso seja vazio não adiciona o valor no                  ³
//³array, pois gera erro de entrada de dados, tipo numerico.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SBI->(FieldPos("BI_DIASGAR")) > 0 .AND. SB0->(FieldPos("B0_DIASGAR")) > 0 .AND. cArquivo == "SBI"      
	AADD(aCamposA, { "BI_DIASGAR", "SB0->B0_DIASGAR" } )                      
Endif		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adicionado esse campo por Multi Negociação³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCamposA, { "BI_GRUPO"	, "SB1->B1_GRUPO" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificação do campo BI_DIASGAR.                         ³
//³Caso seja vazio não adiciona o valor no                  ³
//³array, pois gera erro de entrada de dados, tipo numerico.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SBI->(FieldPos("BI_DIASGAR")) > 0 .AND. cArquivo == "SBI"      
	AADD(aCamposA, { "BI_DIASGAR", "SB0->B0_DIASGAR" } )                      
Endif		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	    	
//³Campos que tem no arquivo SBZ e podem ser exclusivos por filial ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTemSBZ
	If lGerBzFul
		Frt040Sbz(aCampos, @aCamposA)
    Else
	   	AADD(aCamposA, {"BI_LOCPAD"	, "SBZ->BZ_LOCPAD"})
	    If !(HasTemplate("DRO") .Or. (ExistFunc("LjIsDro") .And. LjIsDro()))
		   AADD(aCamposA, {"BI_TS"	    , "SBZ->BZ_TS"})
	    Endif
	    AADD(aCamposA, {"BI_QE"	    , "SBZ->BZ_QE"})      
	EndIf
Endif



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	    	
//³Cria campo da moeda da tabela de preco para ser utilizado na troca da moeda corrente da venda. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If (cPaisLoc <> "BRA") 
	AAdd(aCamposA,{"BI_MOEDA","SB0->B0_MOEDA"+AllTrim(MV_PAR01)})
EndIf 			 
			 
aCamposB := {}
If ExistBlock("FRTGERACAR")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. Para Alterar o Conteudo dos Campos dos Arquivos a Serem Gerados. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjGrvLog( NIL, "Antes da execução do P.E. FRTGERACAR")
	aCamposB := ExecBlock("FRTGERACAR",.F.,.F.)
	LjGrvLog( NIL, "Depois da execução do P.E. FRTGERACAR",aCamposB)
	
	If ValType(aCamposB) <> "A"
		aCamposB := {}
	EndIf
EndIf

If cArquivo == "SBI"
	cArquivo := "SB1"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for CARGA RAPIDA, Processa-a.                          ³
//³ Para arquivos <> de "SB1", se nao houver registros no SLH ³
//³ para gerar o arquivo de carga processa a carga completa.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (MV_PAR02 == 2) .AND. !lCargaFull

	If !FRTSX2Excl(cArquivo)
		cFilAux := (cArquivo)->(xFilial())
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os campos OK_, ALTERADO e DELETADO com .F. para aplicar as alteracoes. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CARGANEW->(DbGoTop())
	While !(CARGANEW->(Eof()))
		If CARGANEW->ALTERADO
			CARGANEW->(Rlock())
			For nI := 1 To Len(aCampos)
				CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][2])),.F.))
			Next nI
			CARGANEW->ALTERADO := .F.
			CARGANEW->DELETADO := .F.
			CARGANEW->(DbCommit())
		Endif
		CARGANEW->(DbSkip())
	End

	lArqAltera := .F.

	#IFDEF TOP
	If FRTSX2Excl("SLH")
		cFilTmp := cFilSLH
	Else
		cFilTmp := FWxFilial("SLH")
	Endif
	
	cSLH := "SLHTMP"
	cQuery := "SELECT DISTINCT SLH.LH_CHAVE, '0' ACAO FROM "+RetSQLName("SLH")+" SLH"
	cQuery += "  WHERE SLH.LH_SITUA='I'"
    cQuery += "    AND SLH.LH_ALIAS='"+cArquivo+"'"
	cQuery += "    AND SLH.LH_FILIAL='"+cFilTmp+"'"
	cQuery += "    AND SLH.D_E_L_E_T_<>'*' "
	cQuery += "UNION "
	cQuery += "SELECT DISTINCT SLH.LH_CHAVE, '1' ACAO FROM "+RetSQLName("SLH")+" SLH"
	cQuery += "  WHERE SLH.LH_SITUA='A'"
    cQuery += "    AND SLH.LH_ALIAS='"+cArquivo+"'"
    cQuery += "    AND SLH.LH_FILIAL='"+cFilTmp+"'"
	cQuery += "    AND SLH.D_E_L_E_T_<>'*' "
	cQuery += "UNION "
	cQuery += "SELECT DISTINCT SLH.LH_CHAVE, '2' ACAO FROM "+RetSQLName("SLH")+" SLH"
	cQuery += "  WHERE SLH.LH_SITUA='D'"
    cQuery += "    AND SLH.LH_ALIAS='"+cArquivo+"'"
    cQuery += "    AND SLH.LH_FILIAL='"+cFilTmp+"'"    
	cQuery += "    AND SLH.D_E_L_E_T_<>'*' "
	cQuery += "ORDER BY LH_CHAVE, ACAO"
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SLHTMP', .F., .T.)

	While !Eof()
		cSLHChave := SLHTMP->LH_CHAVE
		cBusca    := RTrim(SLHTMP->LH_CHAVE)
		If cArquivo == "SB1"                   
            If FRTSX2Excl("SB1")
				cFilTmp := cFilAux
			Else
				cFilTmp := FWxFilial("SB1")
			Endif
			cBusca  := cFilTmp+Substr(cBusca,FWGETTAMFILIAL+1)
		EndIf
		lContinua := .T.				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		cProcesso := SLHTMP->ACAO		//³ Acao: 0-Inclusao, 1-Alteracao, 2-Delecao  ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso haja mais de uma chave no SLHTMP, a acao de INCLUSAO prevalece sobre a de ALTERACAO ³
		//³ Caso haja INCLUSAO e DELECAO ao mesmo tempo, o registro sera desconsiderado.     		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lIgnoraReg := .F.
		While !Eof() .AND. cSLHChave == SLHTMP->LH_CHAVE                             
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			If SLHTMP->ACAO=="0"						//³ INCLUSAO prevalece sobre ALTERACAO		 ³
				cProcesso := SLHTMP->ACAO				//³ Acao: 0-Inclusao, 1-Alteracao, 2-Delecao ³
			EndIf                           			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cProcesso=="I" .AND. SLHTMP->ACAO=="2"	// DELECAO
				lIgnoraReg := .T.
			EndIf
			lContinua := .T.
			DbSkip()
		End					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		If lIgnoraReg		//³ INCLUSAO e DELECAO ao mesmo tempo  ³
			DbSkip()		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Loop
		EndIf
        If cProcesso=="0"
        	cProcesso := "I"
        ElseIf cProcesso=="1"
        	cProcesso := "A"
        ElseIf cProcesso=="2"
        	cProcesso := "D"
        EndIf

    #ELSE
    If FRTSX2Excl("SLH")
		cFilTmpSLH := cFilSLH
	Else
		cFilTmpSLH := FWxFilial("SLH")
	Endif
    cSLH 	   := "SLH"
	DbSelectArea(cSLH)                            
	DbSeek(cFilTmpSLH+cArquivo)
	While !Eof() .AND. LH_FILIAL + LH_ALIAS == cFilTmpSLH + cArquivo
		cSLHChave := SLH->LH_FILIAL + SLH->LH_ALIAS + SLH->LH_CHAVE
		cBusca    := RTrim(SLH->LH_CHAVE)
		If cArquivo == "SB1"                                    
			If FRTSX2Excl("SB1")
				cFilTmp := cFilAux
			Else
				cFilTmp := FWxFilial("SB1")
			Endif
			cBusca  := cFilTmp+Substr(cBusca,FWGETTAMFILIAL+1)
		EndIf
		lContinua := .F.						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		cProcesso := SLH->LH_SITUA				//³ Acao: A-Alteracao, I-Inclusao, D-Delecao  ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿												
		//³ Caso haja mais de uma chave no SLH, a acao de INCLUSAO prevalece sobre a de ALTERACAO ³
		//³ Caso haja INCLUSAO e DELECAO ao mesmo tempo, o registro sera desconsiderado.          ³    
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lIgnoraReg := .F.
		While !Eof() .AND. cSLHChave == cFilTmpSLH+SLH->LH_ALIAS+SLH->LH_CHAVE
		                                        		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			If SLH->LH_SITUA=="I"						//³ INCLUSAO prevalece sobre ALTERACAO		  ³
				cProcesso := SLH->LH_SITUA				//³ Acao: A-Alteracao, I-Inclusao, D-Delecao  ³
			EndIf                                    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cProcesso=="I" .AND. SLH->LH_SITUA=="D"
				lIgnoraReg := .T.
			EndIf
			lContinua := .T.
			Reclock("SLH",.F.)
			dbDelete()
			MsUnlock()
			DbSkip()
		End 		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		If lIgnoraReg		//³ INCLUSAO e DELECAO ao mesmo tempo  ³
			DbSkip()		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Loop
		EndIf
	#ENDIF	
		If lContinua
			If cProcesso $ "AI"
				CARGANEW->(DbSetOrder(1))
				If !(CARGANEW->(DbSeek(cBusca)))
					CARGANEW->(DbAppend())
				Else
					CARGANEW->(RLock())
				Endif	
				CARGASEQ->(DbSetOrder(1))
				CARGASEQ->(DbSeek(cBusca))
				DbSelectArea(cArquivo)
				DbSetOrder(1)
				DbSeek(cBusca)
				lAchouSBZ  := .F.				
				If cArquivo == "SB1"              
			        If FRTSX2Excl("SB0")        		
				        cFilTmp := cFilSB0
			        Else 
				        cFilTmp := FWxFilial("SB0")
			        Endif
					SB0->(DbSetOrder(1))
					SB0->(DbSeek(cFilTmp+Substr(cBusca,FWGETTAMFILIAL+1)))					                                              
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no SBZ ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTemSBZ          
						If FRTSX2Excl("SB0")
							cFilTmp := cFilSB0
						Else
							cFilTmp := FWxFilial("SB0")
						Endif
					   	SBZ->(DbSetOrder(1))		//BZ_FILIAL+BZ_COD
					   	lAchouSBZ  := SBZ->(DbSeek(cFilTmp+Substr(cBusca,FWGETTAMFILIAL+1)))
					Endif   										
				EndIf

				lRegAltera := .F.
				For nI := 1 To Len(aCampos)
					If (nField := AScan(aCamposA, {|x| x[1] == aCampos[nI][1]})) > 0
						uCampoB := aCamposA[nField][2]
						If lTemSBZ .AND. Substr(uCampoB,1,3) == "SBZ"  
	  						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						   	//³ Se encontrar o registro no SBZ, grava o conteudo deste campo  ³
						   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						   	If lAchouSBZ
						      	uCampo  := &(uCampoB)                        
						   	Else                                                              
	  							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿						   	
						      	//³ Se nao encontrar no SBZ, grava o conteudo do campo do SB1    ³
						      	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							  	uCampo := FieldGet( FieldPos( If( Left(cArquivo,1)=="S", Right(cArquivo,2) , cArquivo ) + ;
												   Substr( aCampos[nI][1] , AT("_",aCampos[nI][1]) ) ) )						      
						  	Endif
						Else						
						   uCampo  := &(uCampoB)
						Endif   
					Else
						uCampo := FieldGet( FieldPos( If( Left(cArquivo,1)=="S", Right(cArquivo,2) , cArquivo ) + ;
											Substr( aCampos[nI][1] , AT("_",aCampos[nI][1]) ) ) )
					EndIf
					If Len(aCamposB) > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ P.E. Para Alterar o Conteudo dos Campos dos Arquivos a Serem Gerados. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (nField:=AScan(aCamposB, {|x| x[1] == aCampos[nI][1]})) > 0
							uCampoB := aCamposB[nField][2]
							uCampo  := &(uCampoB)
						EndIf
					EndIf
					If uCampo <> CARGASEQ->(FieldGet(CARGASEQ->(FieldPos(aCampos[nI][1]))))
						CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][1])),uCampo))
						CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][2])),.T.))
						lRegAltera := .T.
						lArqAltera := .T.
					EndIf
					If cProcesso == "I"
						CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][2])),.T.))
						lRegAltera := .T.
						lArqAltera := .T.
					EndIf
				Next nI
				If lRegAltera
					CARGANEW->ALTERADO := .T.
				EndIf
			ElseIf cProcesso == "D"

				CARGANEW->(DbSetOrder(1))
				
				If CARGANEW->(DbSeek(cBusca))
					CARGANEW->(RLock())
					CARGANEW->DELETADO := .T.
					CARGANEW->ALTERADO := .T.		
					lArqAltera := .T.
				EndIf
			EndIf
			CARGANEW->(DbCommit())	
		EndIf
		DbSelectArea(cSLH)
	End

	#IFDEF TOP                                    
	If FRTSX2Excl("SLH")
		cFilTmp := cFilSLH
	Else
		cFilTmp := FWxFilial("SLH")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o nome do banco que esta sendo utilizado, ³
	//³para ser utilizado no final da funcao.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBanco := Alltrim(Upper(TCGetDb()))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica qual eh o maior e o menor Recno que satisfaca a selecao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT 	MIN(R_E_C_N_O_) MINRECNO,"
	cQuery +=	 		"MAX(R_E_C_N_O_) MAXRECNO "
	cQuery += "FROM " 			+ RetSqlName("SLH")					
	cQuery += "  WHERE LH_ALIAS='"  + cArquivo       + "'"
    cQuery += "    AND LH_FILIAL='" + cFilTmp + "'"
	cQuery += "    AND D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SLHTRB', .F., .T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena o registro minimo e o maximo para executar a selecao correta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMax := SLHTRB->MAXRECNO
	nMin := SLHTRB->MINRECNO
	DbCloseArea()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o dbDelete() nos registros processados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SLHTMP")
	DbCloseArea()
	If lArqAltera
		cSQLExec := "DELETE FROM " + RetSqlName("SLH")
		cSQLExec += "  WHERE LH_ALIAS='"  + cArquivo       + "'"
		cSQLExec += "    AND LH_FILIAL='" + cFilTmp + "'"
		cSQLExec += "    AND D_E_L_E_T_<>'*'"  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := nMin To nMax STEP 1024
			IncProc()
			cChave := " AND R_E_C_N_O_>=" + Str(nX, 10, 0) + " AND R_E_C_N_O_<=" + Str(nX + 1023, 10, 0) + ""
			TcSqlExec(cSQLExec+cChave)
		Next nX		
		
		If Left(cBanco, 6) == "ORACLE"
			TcSqlExec("COMMIT")
		Endif
		
		TCRefresh(RetSqlName("SLH"))
	EndIf
	#ENDIF
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente realiza a Carga Completa se for a primeira carga (lCargaFull), ou ³
//³ se o arquivo a ser gerado a carga for <> de "SB1" e nao houve registros   ³
//³ na tabela SLH.                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCargaFull .OR. (!lCargaFull .AND. If(cArquivo=="SB1", MV_PAR02==1, !lArqAltera))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Uso o SET DELETE OFF, pois os registros que foram deletados na Retaguarda ³
	//³ tem que ser deletados no Check-Out                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SET DELETED OFF
 
    If !FRTSX2Excl(cArquivo)
		cFilAux :=  (cArquivo)->(xFilial())
    Endif 
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia do indice 2 da tabela SFM ³              
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	aAreaSFM := GetArea()
	DbSelectArea("SIX")
	DbSetOrder(1)		//INDICE+ORDEM
	If DbSeek("SFM" + "2")
		lExistSFM2 := .T.
	EndIf
	RestArea(aAreaSFM)
				
	DbSelectArea(cArquivo)
	//devido o indice 1 da tabela SFM nao ser UNQ, eh necessario ordena-la pelo indice 2, que contem mais distincoes
	If cArquivo <> "SFM"
		DbSetOrder(1)
	ElseIf lExistSFM2
		DbSetOrder(2)
	Else
		DbSetOrder(1)
	EndIf  
	
    DbSeek(cFilAux)
	cIndex := IndexKey()     
	aArea  := GetArea()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for a tabela de moedas, posiciona no início do arquivo, pois a tabela não tem o campo filial³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cArquivo == "SM2"
		DbGoTop()
	Else
        DbSeek(cFilAux)
	EndIf
	
	cIndex := IndexKey()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz o processamento de Carga Completa.                         ³ 
	//³Se for o Arquivo de moeda inicializa a variavel como data.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cArquivo == "SM2"
		cChave := Ctod("")
	Else
		cChave := ""
	EndIf

	lDeleted  := .F.
	
	While !Eof() .AND. If(cArquivo == "SM2", .T., cFilAux) == If(cArquivo == "SM2", .T., &(Right(cArquivo,If(Left(cArquivo,1)=="S",2,3))+"_FILIAL"))
		cChaveAnt := cChave
		cChave := &(cIndex)
		lAchouSBZ  := .F.		
		If cArquivo=="SB1"
			SET DELETED ON                           

	        If FRTSX2Excl("SB0")
				cFilTmp := cFilSB0
			Else
				cFilTmp := FWxFilial("SB0")
			Endif
			
			SB0->(DbSeek(cFilTmp+SB1->B1_COD))                       
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no SBZ  ³                                         
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTemSBZ
			   	SBZ->(DbSetOrder(1))		//BZ_FILIAL+BZ_COD                       
			    If FRTSX2Excl("SBZ")
					cFilTmp := cFilSBZ
				Else
					cFilTmp := FWxFilial("SBZ")
				Endif
			   	lAchouSBZ  := SBZ->(DbSeek(cFilTmp+SB1->B1_COD))
			Endif   			
			SET DELETED OFF
		EndIf
		If !lCargaFull
			CARGASEQ->(DbSetOrder(1))
			lAchouSEQ := CARGASEQ->(DbSeek(cChave))
			lDelAnt  := lDeleted
			lDeleted := Deleted()
			If lDeleted
				If lAchouSEQ
					If CARGASEQ->DELETADO
						DbSkip()
						Loop
					EndIf
				Else
					DbSkip()
					Loop
				EndIf
			EndIf
		EndIf

		If ExistBlock("FRTREGAT")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. Para Verificar se o registro esta ativo.						  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			LjGrvLog( NIL, " Antes da execução do P.E. FRTREGAT - cArquivo ", cArquivo)
			lRegAt := ExecBlock("FRTREGAT",.F.,.F., {cArquivo})
			LjGrvLog( NIL, " Depois da execução do P.E. FRTREGAT - Retorno ", lRegAt)
			If !lRegAt
				DbSkip()
				Loop
			EndIf
		EndIf
		
		If cCargaNEW > "000001" .AND. lAchouSEQ
			CARGANEW->(DbSetOrder(1))
			CARGANEW->(DbSeek(cChave))
			CARGANEW->(RLock())
		Else
			CARGANEW->(DbAppend())
		EndIf
		lAlterado := .F.
		For nI := 1 To Len(aCampos)
			If (nField := AScan(aCamposA, {|x| x[1] == aCampos[nI][1]})) > 0
				uCampoB := aCamposA[nField][2]
				If lTemSBZ .AND. Substr(uCampoB,1,3) == "SBZ"                     
				   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
				   //³ Se encontrar o registro no SBZ, grava o conteudo deste campo  ³
				   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				   If lAchouSBZ
				      uCampo  := &(uCampoB)                        
				   Else
				      //Se nao encontrar no SBZ, grava o conteudo do campo do SB1
				      uCampo := FieldGet( ColumnPos( If( Left(cArquivo,1)=="S", Right(cArquivo,2) , cArquivo ) + ;
							              Substr( aCampos[nI][1] , AT("_",aCampos[nI][1]) ) ) )				      
				   Endif
				Else
				   uCampo  := &(uCampoB)                                         
				Endif	   
			Else
				uCampo := FieldGet( ColumnPos( If( Left(cArquivo,1)=="S", Right(cArquivo,2) , cArquivo ) + ;
									Substr( aCampos[nI][1] , AT("_",aCampos[nI][1]) ) ) )
			EndIf
			If Len(aCamposB) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ P.E. Para Alterar o Conteudo dos Campos dos Arquivos a Serem Gerados. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nField:=AScan(aCamposB, {|x| x[1] == aCampos[nI][1]})) > 0
					uCampoB := aCamposB[nField][2]
					uCampo  := &(uCampoB)
				EndIf
			EndIf
			CARGANEW->(FieldPut(CARGANEW->(ColumnPos(aCampos[nI][2])),.F.))
			If !lCargaFull
				If !lAchouSEQ .OR. (uCampo <> CARGASEQ->(FieldGet(CARGASEQ->(FieldPos(aCampos[nI][1]))))) .OR. (cChaveAnt == cChave .AND. !Deleted())
					lAlterado := .T.
					CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][1])),uCampo))
					CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][2])),.T.))
				EndIf
			Else
				lAlterado := .T.
				CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][1])),uCampo))
				CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][2])),.T.))
			EndIf
			
			If lAlterado .OR. Deleted()
				lArqAltera := .T.
				lAlterado  := .T.
			EndIf
		Next nI
		CARGANEW->ALTERADO := lAlterado
		CARGANEW->DELETADO := Deleted() 
		                                                  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ O registro anterior da mesma chave esta deletado e o atual nao.	³
		//³ Acontece quando e inserido a mesma chave apos exclusao          ³      
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ValType(cChaveAnt) == ValType(cChave) .AND. cChaveAnt == cChave) .AND. !lDeleted .AND. lDelAnt
			For nI := 1 To Len(aCampos)
				// Marca todos os registros para serem enviados
				CARGANEW->(FieldPut(CARGANEW->(FieldPos(aCampos[nI][2])),.T.))
        	Next nI
			CARGANEW->ALTERADO := .T.
			CARGANEW->DELETADO := .F.
			lArqAltera := .T.
			lAlterado  := .T.
		EndIf		
		CARGANEW->(DbCommit())
		DbSkip()
	End
	SET DELETED ON
EndIf

If !lCargaFull
	DbSelectArea("CARGASEQ")
	DbCloseArea()
EndIf

If lArqAltera
	nSucess := 2
EndIf

DbSelectArea("CARGANEW")
DbCloseArea()
DbSelectArea("CARGA")

Return(nSucess)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CARGAFiles³ Autor ³ Vendas Clientes       ³ Data ³14/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Abertura do Arquivo Espelho Para a Carga.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros| ExpC1 - Tabela                                             ³±±
±±³          | ExpC2 - Filial                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CARGAFiles( cArquivo, cFilAux )
Local lSucess 	 :=.T.	//Retorno da funcao
Local aEstru	 := {}	//Estrutura do arquivo CARGA
Local cSEQFile	 := ""	//Sequencia da carga anterior
Local cNEWFile   := ""	//Sequencia da carga nova
Local cIndex   	 := "" 	//Indice
Local cDireto    := ""  //Diretorio	para a geracao do arquivo CARGAxxx.frt
Local cArqdbf	 := ""	//Tabela de cargas.
Local aAreaSFM	 := {} 	//Guanda area corrente.
Local lExistSFM2 := .F.	//Verifica existencia do indice 2 da SFM

cSEQFile := cCargaSEQ+cArquivo
cNEWFile := cCargaNEW+cArquivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia do indice 2 da tabela SFM ³              
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
aAreaSFM := GetArea()
DbSelectArea("SIX")
DbSetOrder(1)		//INDICE+ORDEM
If DbSeek("SFM" + "2")
	lExistSFM2 := .T.
EndIf
RestArea(aAreaSFM)
			
DbSelectArea(cArquivo)
//devido o indice 1 da tabela SFM nao ser UNQ, eh necessario ordena-la pelo indice 2, que contem mais distincoes
If cArquivo <> "SFM"
	DbSetOrder(1)
ElseIf lExistSFM2
	DbSetOrder(2)
Else
	DbSetOrder(1)
EndIf 	

cIndex := IndexKey()

If !FRTSX2Excl(cArquivo)      
   	cDireto := cMV_DIRCFRT+FRT_EMPFIL                         
Else   
    cDireto := cMV_DIRCFRT+ALLTRIM("CRG"+cEmpAnt+cFilAux) + "\"
EndIf

If cCargaNEW > "000001"               
	If !File(cDireto+cSEQFile+"."+cEmpAnt)                                    
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ "Modo de abertura dos arquivos de Carga"																  ³
		//³ "Se o arquivo for Compartilhado, deverá ser gerado no diretório "                                         ³
		//³ "Se o arquivo for Exclusivo, deverá ser gerado no diretório "                                             ³
		//³ "Apague todos os arquivos da Carga e gere uma nova. Este processo será necessário apenas uma única vez."  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aviso(STR0049,;
			  STR0050+cMV_DIRCFRT+". "+Chr(13)+;
			  STR0051+cMV_DIRCFRT+ALLTRIM("CRG"+cEmpAnt+cFilAux)+"\. "+Chr(13)+;
			  STR0052, {"Ok"})
		lSucess := .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criacao estrutura para o arquivo de carga|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEstru := FRTStruct(cArquivo)
		cArqdbf := cDireto + cNEWFile + "." + cEmpAnt 
		FrtCriaTrb(,,cArqdbf,aEstru,"TRB")
		APPEND FROM &(cDireto+cSEQFile+"."+cEmpAnt)
		TRB->(DbCLoseArea())
	EndIf
EndIf	

If lSucess .AND. cCargaSEQ <> "000000"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abertura do Arquivo CARGASEQ ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
	lSucess := OpenSEQNEW(	cArquivo, "CARGASEQ",  cSEQFile, cIndex,;
						  	NIL     , cDireto )              
EndIf
If lSucess .AND. cCargaNew == "000001"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao estrutura para o arquivo de carga|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEstru := FRTStruct(cArquivo) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criação dos Arquivos das Tabelas Compartilhadas ou Exclusivas em forma de 000001??.xx onde (?? Tabelas, xx Empresa, yy Filial)    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !FRTSX2Excl(cArquivo)                                                       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criação dos Arquivos de Carga das Tabelas Compartilhadas   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
       	//³ Tabela Compartilhada criação em \data\carga\                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	FrtCriaTrb(,.F.,cMV_DIRCFRT + FRT_EMPFIL + cNEWFile + "." + cEmpAnt,aEstru)
		If lSucess
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abertura do Arquivo CARGANEW ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IsSrvUnix()//Verifica se o Sistema Operacional eh diferente de WINDOWS
				If File(cMV_DIRCFRT + FRT_EMPFIL + cNEWFile + "." + cEmpAnt+'x')//se achar os indices
		  			FErase(cMV_DIRCFRT + FRT_EMPFIL + cNEWFile + "." + cEmpAnt+'x')//apaga os indices
		  			//Foi preciso fazer a delecao dos indices porque em Sistema Operacional LINUX o tratamento dos "INDICES"
		  			//dos arquivos eh diferente do tratamento dos "INDICES" do Sistema Operacional WINDOWS.
		 		Endif
		 	Endif   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
			//³ Tabela Compartilhada criação em \data\carga   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	        
			lSucess := OpenSEQNEW(	cArquivo, "CARGANEW",  cNEWFile, cIndex,;
								    NIL		, cMV_DIRCFRT + FRT_EMPFIL ) 
		EndIf
		If !lSucess
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao conseguiu abrir TODOS os arquivos, fecha todos que foram abertos. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Select("CARGASEQ")>0
				DbSelectArea("CARGASEQ")
				DbCloseArea()
			EndIf
			If Select("CARGANEW")>0
				DbSelectArea("CARGANEW")
				DbCloseArea()
			EndIf
		EndIf                    
    Else                
		FrtCriaTrb(,.F.,ALLTRIM(cMV_DIRCFRT + "CRG"+cEmpAnt+cFilAux) + "\" + cNEWFile + "." + cEmpAnt,aEstru)
		If lSucess                                         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abertura do Arquivo CARGANEW ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IsSrvUnix() // Verifica se o Sistema Operacional eh diferente de WINDOWS
				If File(ALLTRIM(cMV_DIRCFRT + "CRG"+cEmpAnt+cFilAux) + "\" + cNEWFile + "." + cEmpAnt+'x')//se achar os indices
		  			FErase(ALLTRIM(cMV_DIRCFRT + "CRG"+cEmpAnt+cFilAux) + "\" + cNEWFile + "." + cEmpAnt+'x')//apaga os indices
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  			//³ Foi preciso fazer a delecao dos indices porque em Sistema Operacional LINUX o tratamento dos "INDICES"  ³
		  			//³ dos arquivos eh diferente do tratamento dos "INDICES" do Sistema Operacional WINDOWS.					³
		  			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 		Endif
		 	Endif                                 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        	
   			//³  Tabela Exclusiva criação em \data\carga\crgxxyy onde (xx Empresa, yy Filial)   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lSucess := OpenSEQNEW(	cArquivo, "CARGANEW",  cNEWFile, cIndex,;
								    NIL		, cMV_DIRCFRT + ALLTRIM("CRG"+cEmpAnt+cFilAux) + "\")
		EndIf
		If !lSucess
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao conseguiu abrir TODOS os arquivos, fecha todos que foram abertos. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Select("CARGASEQ")>0
				DbSelectArea("CARGASEQ")
				DbCloseArea()
			EndIf
			If Select("CARGANEW")>0
				DbSelectArea("CARGANEW")
				DbCloseArea()
			EndIf
		EndIf                    
	EndIf
Else
	If lSucess
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abertura do Arquivo CARGANEW ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		If IsSrvUnix()	//³ Verifica se o Sistema Operacional é diferente de WINDOWS  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If File(cMV_DIRCFRT + FRT_EMPFIL + cNEWFile + "." + cEmpAnt+'x')//se achar os indices
	  			FErase(cMV_DIRCFRT + FRT_EMPFIL + cNEWFile + "." + cEmpAnt+'x')//apaga os indices
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  			//³ Foi preciso fazer a delecao dos indices porque em Sistema Operacional LINUX o tratamento dos "INDICES"  ³
	  			//³ dos arquivos eh diferente do tratamento dos "INDICES" do Sistema Operacional WINDOWS.                	³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 		Endif
	 	Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ OpenSEQNEW(cArquivo,       cArq, cFileName, cIndex, lShared, cDiret )  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lSucess := OpenSEQNEW(	cArquivo, "CARGANEW",  cNEWFile, cIndex,;
							    NIL		, cDireto ) 
	EndIf
	If !lSucess
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao conseguiu abrir TODOS os arquivos, fecha todos que foram abertos. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("CARGASEQ")>0
			DbSelectArea("CARGASEQ")
			DbCloseArea()
		EndIf
		If Select("CARGANEW")>0
			DbSelectArea("CARGANEW")
			DbCloseArea()
		EndIf
	EndIf
EndIf

Return lSucess
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ FRTArquivos  ³Autor ³ Vendas Clietes       ³Data³18/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array com os Arquivos a Gerar a Carga.          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTArquivos
Local aFiles 	 := {}									//Array com os arquivos a gerar a carga	       
Local lAuto  	 := SuperGetMV("MV_LJSRAUT", ,.F.)  	//Indica se utiliza incremento automatico da serie
Local lMV_LOJKIT := SuperGetMV("MV_LOJKIT",.F.,.F. )	//Indica se considera KIT ou nao
/*Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI		 */
Local lCFolLocR5 :=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL"
                            						
//³ Impostos Variaveis     ³
If cPaisLoc == "BRA"

	If lCenVenda 
		// Se usa nova regra de desconto add tabelas
		If lNovRegDesc
			aFiles := {	"SA1", "SA3", "SA6", "SAE", ;
						"SAF", "SBI", "SB2", "SE4", ;
						"SED", "SF4", "SF7", "SFC", ;
						"SLF", "SLG", "SLK", "SFM", ;
						"ACO", "ACP", "DA0", "DA1", ;
						"ACQ", "ACR", "MEI", "MEJ", ;
						"MB2", "MB3", "MB4", "MB5", ;
						"MB6", "MB7", "MB8", "ACV"} 
		Else
			aFiles := {	"SA1", "SA3", "SA6", "SAE", ;
						"SAF", "SBI", "SB2", "SE4", ;
						"SED", "SF4", "SF7", "SFC", ;
						"SLF", "SLG", "SLK", "SFM", ;
						"ACO", "ACP", "DA0", "DA1", ;
						"ACQ", "ACR"} 		
		EndIf						
	Else
		aFiles := {	"SA1", "SA3", "SA6", "SAE", ;
					"SAF", "SBI", "SE4", "SED", ;
					"SF4", "SF7", "SFC", "SLF", ;
					"SLG", "SLK", "SFM", "SEC" }
	EndIf				

	If lAuto .AND. SX2->( DbSeek("SL6") )
		Aadd(aFiles, "SL6")
	EndIf
	If AliasInDic("SL8")
	    Aadd(aFiles, "SL8")    
	EndIf
	If AliasInDic("SLD")	
	    Aadd(aFiles, "SLD")    			    
	EndIf
	If AliasInDic("SL7")	
	    Aadd(aFiles, "SL7")    			    
	EndIf
	If AliasInDic("SLZ")
	    Aadd(aFiles, "SLZ")    
	EndIf
	If lMV_LOJKIT
		If AliasInDic("SUG")
		    Aadd(aFiles, "SUG")
		EndIf
	
		If AliasInDic("SU1")
		    Aadd(aFiles, "SU1")
		EndIf	
	Endif

	If AliasInDic("MDE")
	    Aadd(aFiles, "MDE")
	EndIf    

    Aadd(aFiles, "MBS")    			    
    Aadd(aFiles, "MBT")    			    
	If AliasInDic("MEN") 
		Aadd(aFiles, "MEN") 
	EndIf
	If AliasInDic("MEK") 
		Aadd(aFiles, "MEK") 
	EndIf	

Else 
	If lCenVenda    	
		aFiles := {	"SA1", "SA3", "SA6", "SAE", ;
					"SAF", "SBI", "SE4", "SED", ;
					"SF4", "SF7", "SFB", "SFC", ;
					"SFF", "SLF", "SLG", "SLK", ;
					"SM2", "ACO", "ACP", "DA0", ;
					"DA1", "ACQ", "ACR"}    


	Else
		aFiles := {	"SA1", "SA3", "SA6", "SAE", ;
					"SAF", "SBI", "SE4", "SED", ;
					"SF4", "SF7", "SFB", "SFC", ;
					"SFF", "SLF", "SLG", "SLK", ;
					"SM2", "SEC" }
	EndIf				
	
    Aadd(aFiles, "MBS")    			    	
    Aadd(aFiles, "MBT")
    If AliasInDic("MEN") 
		Aadd(aFiles, "MEN") 
	EndIf
	If AliasInDic("MEK") 
		Aadd(aFiles, "MEK") 
	EndIf	
	
	/*Release 11.5 - Controle de Formularios
	Carga das Tabelas SL6,SFP			
	Paises:Chile/Colombia  - F1CHI		*/
	If lCFolLocR5
		Aadd(aFiles,"SL6")
		Aadd(aFiles,"SFP")
	EndIf

    If cPaisLoc $ "ARG|DOM|EUA|MEX|PAR|POR|URU"
       Aadd(aFiles,"SFE")                  
       Aadd(aFiles,"SFH")
       Aadd(aFiles,"SFZ")       
    ElseIf cPaisLoc == "COL"
       Aadd(aFiles,"SFE")                      
    EndIf        
	If AliasInDic("MDE")
	    Aadd(aFiles, "MDE")
	EndIf	
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui a opcao midia na carga						        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
If SuperGetMv("MV_LJRGMID",,0) == 1 .OR. SuperGetMv("MV_LJRGMID",,0) == 2    
	Aadd(aFiles, "SUH")
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivos a Gerar Carga ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("FRTCARGA")
	aFiles := ExecTemplate("FRTCARGA",.F.,.F.,{aFiles})
EndIf

If ExistBlock("FRTCARGA")
	LjGrvLog( NIL, " Antes da Execução do P.E. FRTCARGA",aFiles)
	aFiles := ExecBlock("FRTCARGA",.F.,.F.,{aFiles})
	LjGrvLog( NIL, " Depois da Execução do P.E. FRTCARGA",aFiles)
EndIf

Return aFiles

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ FRTChkCarga  ³Autor ³ Vendas Clientes      ³Data³18/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array com os campos atualizados.                ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numeracao do checkout                              ³±±
±±³          ³ ExpC2 - Sequencia da carga                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTChkCarga( nCheckOut, cCargaAtual )
Local nI          := 0		//Controle de loop
Local aFiles      := {} 	//Array que contem os arquivos a gerar a carga
Local aCargaAtual := {}		//Array que contem os arquivos a gerar a carga
Local aCargaOK    := {}		//Array de retorno da funcao
Local nAt		  := 0		//Posicionamento do arquivo	
Local nOldRecNo   := 0		//Recno
Local lTemLib     := .F.	//Verifica se tem liberado
Local nTries      := 0		//variavel de controle
Local lApagouArq  := .F.    //Variavel de controle para identificar se conseguiu apagar o arquivo de semaforo ou se o arquivo nao existe
Local lContinua	  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tenta apagar o arquivo \SEMAFORO\SIGAFRT\CARGA.L<empresa>.           ³
//³ Este arquivo BLOQUEIA TEMPORARIAMENTE as estacoes de receberem carga ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !lApagouArq .AND. nTries<=10										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If File("\SEMAFORO\SIGAFRT\CARGA.L"+cEmpAnt)						//³ Se nao conseguiu apagar o arquivo em 10 tentativas, eh  ³
		lApagouArq := FErase("\SEMAFORO\SIGAFRT\CARGA.L"+cEmpAnt) <> -1	//³ porque a carga esta TEMPORARIAMENTE BLOQUEADA			³
		Sleep(100)														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTries++
	Else
		lApagouArq := .T.
		Exit
	EndIf
End

If !lApagouArq
	lContinua := .F.
Endif        

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abrir Arquivo de Carga de Estacoes - CARGAxx0.FRT ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If OpenCarga(.T.)
		nRet := 0
	Else
		nRet := 2
	Endif
	
	If nRet == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Arquivos a Gerar Carga ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aFiles := FRTArquivos()
		aCargaAtual := Array(Len(aFiles))
		For nI := 1 To Len(aFiles)
			nAt := At(aFiles[nI], cCargaAtual)
			aCargaAtual[nI] := {aFiles[nI], If(nAt==0,Space(6),Substr(cCargaAtual,nAt+3,6))}
		Next nI
		For nI := 1 To Len(aCargaAtual)
			DbSelectArea("CARGA")
			DbSetOrder(1)
			
			If DbSeek(cFilAnt + aCargaAtual[nI][1])											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				If DbSeek(cFilAnt + aCargaAtual[nI][1] + aCargaAtual[nI][2])				//³ Se o Status de "Atualizado" para a   ³
					If Substr(CARGA->ESTACAO, nCheckOut,1) <> "0" .AND. CARGA->LIBERADO		//³ Carga Atual Estiver <> "0" e liberada³
						AAdd(aCargaOK, {aCargaAtual[nI][1], CARGA->SEQ})					//³ Enviar Carga.					     ³
					Else                                   									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿			        
						//³ Esse laço While irá verificar se existe alguma carga liberada   					³
						//³ se existir retorna e vai atualizando da atual para diante, até chegar na que esta	³
						//³ realmente liberada.																	³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nOldRecNo := RecNo()
						lTemLib   := .F.
						
						CARGA->(dbEval( { || lTemLib := ( LIBERADO .AND. SubStr(ESTACAO, nCheckOut, 1) <> "0" ) },, ;
						                { || ( FILIAL + ARQUIVO ) == ( cFilAnt + aCargaAtual[nI,01] ) .AND. ! Eof() .AND. ! lTemLib },,, .T.))
	
						If lTemLib
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿			        					
							GoTo(nOldRecNo)           	//³ Vai para o registro anterior a localização do liberado  ³
							DbSkip()					//³ Caso Contrario, Verifica se Existe						³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
																							 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿							
							If ! Eof() .AND. FILIAL+ARQUIVO == cFilAnt+aCargaAtual[nI][1]	 //³ Uma Nova Carga. ³
							                    											 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿						
								If Substr(CARGA->ESTACAO,nCheckOut,1) <> "0" .AND. CARGA->LIBERADO	//³ Se nao foi Atualizado.  ³
									AAdd(aCargaOK, {aCargaAtual[nI][1], CARGA->SEQ})				//³ Enviar Carga.			³
								EndIf																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							EndIf
						EndIf
					EndIf
		        Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se a primeira carga esta' liberada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        	If DbSeek(cFilAnt + aCargaAtual[nI][1])
					  	If CARGA->LIBERADO
							AAdd(aCargaOK, {aCargaAtual[nI][1], "000000"})
						Endif
					Endif		
				EndIf        
			EndIf
		Next nI
	EndIf
	
	If nRet <> 2
		DbSelectArea("CARGA")
		DbCloseArea()
	EndIf
EndIf

Return aCargaOK

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ FRTTXCarga   ³Autor ³ Vendas Clientes      ³Data³18/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array com os campos atualizados.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numeracao do checkout                              ³±±
±±³          ³ ExpC2 - Sequencia da carga                                 ³±±
±±³          ³ ExpC3 - Tabela                                             ³±±
±±³          ³ ExpN4 - Parametro de controle                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTTXCarga( nCheckOut, cCargaAtual, cArquivo, nContinue )
Local nJ 			:= 0		//Tamanho do array aArray
Local nZ			:= 0 		//Controle de loop
Local nRet	 		:= 0 		//Variavel de controle
Local aRet	 		:= {}		//Array para retorno da funcao
Local nCount 		:= 0		//Variavel de controle
Local nRecno 		:= 0		//Recno
Local aArray 		:= {}		//Array que contem as informacoes dos arquivos da tabela de carga
Local cFileName		:= ""		//Nome do diretorio para a criacao do arquivo CARGAxx0.frt
Local lCompleta		:=.F.		//verifica se eh geracao de carga de todos os arquivos, primeira carga
Local nHandle					//Variavel de controle
Local nPos			:= 0		//Posicao dos campos
Local nOldRecNo 	:= 0		//Recno
Local lTemLib    	:= .F.		//Verifica se tem liberado
Local cIndexSM2     := ""		//Indice da tabela SM2 
Local lCampo		:= ""		//Variavel para controle do campo lido  
Local nQtd			:= 0		//Controle de loop da SIX
/*Release 11.5 - Controle de Formularios
Paises:Chile/Colombia  - F1CHI		 */
Local lCFolLocR5	:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL"
                        
Private lMultiFil := .F.		//Verifica se eh multi-filiais

DEFAULT nCheckOut   := 0
DEFAULT cCargaAtual := ""
DEFAULT cArquivo	:= ""
DEFAULT nContinue	:= 0
	
If ValType(cEmpAnt) <> "C" .OR. ValType(cFilAnt) <> "C"
	conout("FRTTXCarga - Filial ou Empresa nao aberta, vai tentar novamente")
	Return(1)
EndIf

If ValType(cMV_DIRCFRT) <> "C"
	conout("FRTTXCarga - Inicializado parametro MV_DIRCFRT")
	cMV_DIRCFRT := ALLTRIM(SuperGetMV("MV_DIRCFRT"))
EndIf	  
      
nHandle := FCreate(cMV_DIRCFRT + "CRG" + cEmpAnt + AllTrim(cFilAnt)  + "\TEMP.TMP") 

If !(nHandle == -1)
	FClose(nHandle)
	FErase(cMV_DIRCFRT + "CRG" + cEmpAnt + AllTrim(cFilAnt) + "\TEMP.TMP")
	lMultiFil := .T.	
EndIf

If !File(cMV_DIRCFRT+FRT_DBFCARGA)                 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	Return(1)									   	//³  1 - Nao existe o arquivo CARGA.FRT   ³
EndIf												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abrir Arquivo de Carga de Estacoes - CARGAxx0.FRT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If OpenCarga(.T.)
	nRet := 0
Else
	nRet := 2
Endif

If nRet == 0
	If cCargaAtual == "000000"                     	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		lCompleta := .T.							//³ Base defasada, nao foi rodada a ultima atualizacao ³
		DbSelectArea("CARGA")						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSetOrder(1)
		
		DbSeek(cFilAnt + cArquivo)
		While !Eof() .AND. (FILIAL+ARQUIVO == cFilAnt+cArquivo)
			DbSkip()
		End
		DbSkip(-1)
		If FILIAL+ARQUIVO == cFilAnt+cArquivo		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			cCargaAtual := CARGA->SEQ				//³ Pegar a ultima carga gerada  ³
		EndIf										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndIf
EndIf

If nRet == 0 .AND. !lCompleta
	DbSelectArea("CARGA")
	DbSetOrder(1)
	
	DbSeek(cFilAnt + cArquivo + cCargaAtual)
	If LastRec() == 0                             	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		nRet := 5									//³ 5 - Nao existe campos a atualizar ³
	ElseIf !CARGA->LIBERADO							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Carga atual não liberada, verifico se tem alguma carga posterior a essa liberada,
		// se existir, libera a carga atual para atualização
		nOldRecNo := RecNo()
		lTemLib   := .F.
		CARGA->(dbEval( { || lTemLib := ( LIBERADO .AND. SubStr(ESTACAO, nCheckOut, 1) <> "0" ) },, ;
		                { || (( FILIAL + ARQUIVO ) == ( cFilAnt + cArquivo )) .AND. ( ! Eof() ) .AND. (! lTemLib) },,, .T.))
		// Volta para o registro que estava antes da pesquisa
		CARGA->(GoTo(nOldRecNo))
		
		If !lTemLib										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			nRet := 6									//³ 6 - Carga nao liberada        ³
		Else											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRet := 0
		Endif												
		
	ElseIf CARGA->BLOQUEADO                        	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		nRet := 7									    //³ 7 - Carga Bloqueada		  	  ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf Substr(CARGA->ESTACAO,nCheckOut,1) == "1" 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		nRet := 8										//³ 8 - Estacao ja foi atualizada ³
	EndIf												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIf

If nRet == 0
	DbSelectArea("CARGA")
	DbSetOrder(1)
	cFileName := cMV_DIRCFRT+FRT_EMPFIL+cCargaAtual+cArquivo+"."+cEmpAnt
	If File(cFileName)
		FrtCriaTrb(.F.,,cFileName,,"CARGANEW",.T.)
		If NetErr()										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			nRet := 11									//³ 11 - Nao foi possivel abrir o 99999XX.99  ³
		Else                                        	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !File(cFileName+"X")
				DbCloseArea()                          	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				nRet := 12								//³ 12 - Nao existe o indice 999999XX.99X  	  ³
			Else                                       	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbClearIndex()
				DbSetIndex(cFileName+"X")
			EndIf
		EndIf
	Else	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ "Modo de abertura dos arquivos de Carga"																	³
			//³ "Se o arquivo for Compartilhado, deverá ser gerado no diretório "                                        	³
			//³ "Se o arquivo for Exclusivo, deverá ser gerado no diretório "                                              	³
			//³ "Apague todos os arquivos da Carga e gere uma nova. Este processo será necessário apenas uma única vez."	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aviso(STR0049,;
			  STR0050 + cMV_DIRCFRT + ". "  + Chr(13) + ;
			  STR0051 + cMV_DIRCFRT + "CRG" + cEmpAnt + AllTrim(cFilAnt) + "\. " + Chr(13) + ;
			  STR0052, {"Ok"})                        	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		nRet := 11										//³ 11 - Nao foi possivel abrir o 99999XX.99  ³
	EndIf                                         		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIf
If nRet == 0
	AAdd(aArray, {cArquivo,,{}})
	nJ := Len(aArray)
	DbSelectArea(cArquivo)
	aCampos := Array(FCount())
	For nZ := 1 To FCount()
		aCampos[nZ] := {nZ, FieldName(nZ)}
	Next nZ
	aArray[nJ][2] := AClone(aCampos)
	DbSelectArea("CARGANEW")
	DbSetOrder(2)
	If nContinue == 0
		If lCompleta
			DbGoTop()
		Else
			DbSeek("T")
		EndIf
	Else
		DbGoTo(nContinue)
		DbSkip()
	EndIf
	While !Eof() .AND. If(lCompleta, .T., CARGANEW->ALTERADO) .AND. (nCount < 100)
		nRecno := Recno()
		If lCompleta .OR. CARGANEW->ALTERADO .OR. CARGANEW->DELETADO
			++nCount
			cIndex 	:= IndexKey(1)
			If cArquivo == "SF7"
				nQtd:=0
				SIX->(dbSetOrder(1))
				SIX->(dbSeek('SF7'))
				While SIX->(!Eof()) .And. SIX->INDICE == 'SF7' 
					nQtd++
					SIX->(dbSkip())
				EndDo				
				If nQtd >= 3
					cIndex	:= "F7_FILIAL+F7_GRTRIB+F7_SEQUEN"
				EndIf
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para a tabela SM2 = Moedas³
			//³Esta tabela nao possui o campo FILIAL³
			//³Quando o ambiente utiliza Ctree, a   ³
			//³funcao IndexKey() automaticamente    ³
			//³coloca DTOS() no retorno, logo:      ³
			//³Retorno em ambiente CTREE: 20070918  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cArquivo == "SM2"
				If ValType(&(cIndex)) == "C"     
					cIndexSM2 := STOD(&(cIndex))
					aAux := {CARGANEW->DELETADO, cIndexSM2}			
				Else
					aAux := {CARGANEW->DELETADO, &(cIndex)}	
				Endif
			Else
				aAux := {CARGANEW->DELETADO, &(cIndex)}
			Endif
			If !CARGANEW->DELETADO
				For nZ := 1 To Len(aCampos)
					nPos := FieldPos(aCampos[nZ][2])
					If nPos > 0
						If lCenVenda
							If Left(cArquivo,1) == "S"
								lCampo := FieldGet(FieldPos("OK_"+Substr(aCampos[nZ][2],4)))
							Else            
								lCampo := FieldGet(FieldPos("OK_"+Substr(aCampos[nZ][2],5)))
							EndIf
							If lCompleta .OR. lCampo
								AAdd(aAux, {nZ, FieldGet(nPos)})
							EndIf
	                    Else
							If lCompleta .OR. FieldGet(FieldPos("OK_"+Substr(aCampos[nZ][2],If(Left(cArquivo,1)=="S",4,5) )))
								AAdd(aAux, {nZ, FieldGet(nPos)})
							EndIf
						EndIf	
					Else
						If AScan(aLogErros, aCampos[nZ][2])==0
							AAdd(aLogErros, aCampos[nZ][2])									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							ConOut(STR0044 + cArquivo + ".")							    //³ "Front Loja: Erro ao enviar carga da tabela " ### "."     	³
							ConOut(STR0045 + aCampos[nZ][2] + STR0046 + cCargaAtual + ".")	//³ "            Nao existe o campo " ### " na carga " ### "."  ³
						EndIf                                                            	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					EndIf
				Next nZ
			EndIf
			AAdd(aArray[nJ][3], AClone(aAux))
		EndIf
		DbSkip()
	End
	If Eof() .OR. If(lCompleta,.F.,!CARGANEW->ALTERADO)
		nRecno := 0
	EndIf
	DbCloseArea()
EndIf
If nRet <> 2
	DbSelectArea("CARGA")
	DbSetOrder(1)
	DbCloseArea()
EndIf
If nRet == 0 .AND. Len(aArray) == 0						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	nRet := 5												//³ 5 - Nao existe campos a atualizar  ³
EndIf                                                   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet == 0
	aRet := {aArray,nRecno,cCargaAtual}
	If lCenVenda
		If cArquivo == "SA6" .AND. nRecno == 0
			AAdd(aRet, "CARREGAR")
		Else
			AAdd(aRet, " ")   	
		EndIf
		
		If cArquivo == "SBI"   
	    	AAdd(aRet, GetMV("MV_TABPAD"))                             
		Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Controle de Formularios ³
	//³Paises:Chile/Colombia  - F1CHI		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf lCFolLocR5
		If cArquivo == "SFP" .AND. nRecno == 0
			AAdd(aRet, "CARREGAR") 	//4  	
			AAdd(aRet, " ")   	    //5
			AAdd(aRet, "01")		//6		
		EndIf	
	Else
		If cArquivo == "SA6" .AND. nRecno == 0
			AAdd(aRet, "CARREGAR")
		EndIf
	EndIf
Else
	aRet := nRet
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ FRTCargaOK   ³Autor ³ Vendas Clientes      ³Data³19/09/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza CARGA.FRT com a estacao que concluiu a atualizacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Numeracao do checkout                              ³±±
±±³          ³ ExpC2 - Chave de busca                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTCargaOK( nCheckOut, cChave )
Local nRet		:= 0		//Retorno da funcao
Local cString	:= ""

If OpenCarga(.T.)
	nRet := 0
Else
	nRet := 2
Endif

If nRet == 0
	COnout( " FRTCargaOK - nCheckOut : " + cValToChar(nCheckOut))
	COnout( " FRTCargaOK - cChave : " + cChave)
	
	DbSelectArea("CARGA")
	DbSetOrder(1)
	
	If DbSeek(cFilAnt+cChave)
		COnout( " FRTCargaOK - Encontrou chave na tabela CARGA ")
		cString := CARGA->ESTACAO
		cString := Stuff(cString, nCheckOut, 1, "0")
		RecLock("CARGA", .F.)
		CARGA->ESTACAO := cString
		DbCommit()
		MsUnLock()
		COnout( " FRTCargaOK - Mudança do campo Estacao na tabela CARGA [" + cString + "]")
	EndIf
	dbCloseArea()
EndIf

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ FRTChkSLI    ³Autor ³ Vendas Clientes      ³Data³07/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia de SLIs do Servidor para o Check-Out ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da estacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTChkSLI( cEstacao )
Local aRet := {}	//Array de retorno da funcao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "MSG" - Protocolo de Exibicao de Mensagens no Check-Out. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"MSG")) .AND. !Empty(SLI->LI_MSG)
	AAdd(aRet, {"MSG", SLI->LI_MSG, SLI->LI_USUARIO, SLI->LI_DATA, SLI->LI_HORA})
	FRTGeraSLI(cEstacao, "MSG", "", "SOBREPOE")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "COM" - Protocolo para a Atualizacao de todas as tabelas no Check-Out. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"COM")) .AND. !Empty(SLI->LI_MSG)
	AAdd(aRet, {"COM", SLI->LI_MSG, SLI->LI_USUARIO, SLI->LI_DATA, SLI->LI_HORA})
	FRTGeraSLI(cEstacao, "COM", "", "SOBREPOE")
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ FRTTXSX5     ³Autor ³ Vendas Clientes      ³Data³28/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia o SX5 para o Check-Out.                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTTXSX5
Local aSX5 := {}	//Array de retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Uso o SET DELETE OFF, pois os registros que foram deletados na Retaguarda ³
//³ tem que ser deletados no Check-Out                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DELETED OFF
SX5->(DbSetOrder(1))
SX5->(DbSeek(xFilial("SX5")+"23"))
SX5->(dbEval({|| AAdd(aSX5, {SX5->X5_TABELA, SX5->X5_CHAVE, SX5->X5_DESCRI, SX5->X5_DESCSPA, SX5->X5_DESCENG, SX5->(Deleted())})},,;
			 {|| SX5->X5_FILIAL+SX5->X5_TABELA == xFilial("SX5")+"23"}))		 
SET DELETED ON

Return aSX5

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FRTTXSX5R5  ºAutor³Vendas CRM		     º Data ³ 05/04/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³Envia o SX5 para o Check-Out. - Release 11.5                ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ExpA1 := FRTTXSX5R5(ExpC1)   		                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Nome da Tabela do SX5					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpA1 - Array com os registros da tabela.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA040			                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Function FRTTXSX5R5( cTab )
Local aSX5 := {}	//Array de retorno da funcao

DEFAULT	cTab:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Uso o SET DELETE OFF, pois os registros que foram deletados na Retaguarda ³
//³ tem que ser deletados no Check-Out                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DELETED OFF
SX5->(DbSetOrder(1))
SX5->(DbSeek(xFilial("SX5")+cTab))
SX5->(dbEval({|| AAdd(aSX5, {SX5->X5_TABELA, SX5->X5_CHAVE, SX5->X5_DESCRI, SX5->X5_DESCSPA, SX5->X5_DESCENG, SX5->(Deleted())})},,;
			 {|| SX5->X5_FILIAL+SX5->X5_TABELA == xFilial("SX5")+cTab}))		 
SET DELETED ON

Return aSX5

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ FRTRXSX5     ³Autor ³ Vendas Clientes      ³Data³28/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o SX5 no Check-Out.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array com estrutura da tabela SX5                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTRXSX5( aSX5 )
Local nI := 0	//Controle de loop

SX5->(DbSetOrder(1))
For nI := 1 To Len(aSX5)				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If aSX5[nI][6]						//³ Foi Deletado na Retaguarda?	 ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SX5->(DbSeek(xFilial("SX5")+"23"+aSX5[nI][2]))
			RecLock("SX5", .F., .T.)	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			SX5->(dbDelete())			//³ Se Achou, Deleta!!!			 ³
			SX5->(MsUnLock())         	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End	

	Else
		FRTGeraSL("SX5", {{"X5_FILIAL",  xFilial("SX5")}, ;
						  {"X5_TABELA",  aSX5[nI][1]}   , ;
						  {"X5_CHAVE",   aSX5[nI][2]}   , ;
						  {"X5_DESCRI",  aSX5[nI][3]}   , ;
						  {"X5_DESCSPA", aSX5[nI][4]}   , ;
						  {"X5_DESCENG", aSX5[nI][5]}}  , ;
				  !SX5->(DbSeek(xFilial("SX5")+"23"+aSX5[nI][2])))		
		
	End
Next nI

Return NIL           

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³FRTRXSX5R5  ºAutor³Vendas CRM		     º Data ³ 05/04/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Atualiza o SX5 no Check-Out.  - Release 11.5               ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³FRTRXSX5(ExpA1)     	 			                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpA1 - Array com os registros da tabela do SX5             º±±
±±º			 ³ExpC2 - Nome da tabela do SX5					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL1 - Indica se o arquivo SX5 foi atualizado com sucesso. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FRTA040   		                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTRXSX5R5(aSX5,cTab)
Local nI := 0	//Controle de loop

DEFAULT aSX5:= {}
DEFAULT cTab:= ""

If Empty(cTab)
	Return NIL
EndIf

SX5->(DbSetOrder(1))
For nI := 1 To Len(aSX5)				
							
	If SX5->(DbSeek(xFilial("SX5")+cTab+aSX5[nI][2]))
		If aSX5[nI][6]	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se ja existe no PDV mas foi deletado da RETAGUARDA         ³
			//³o mesmo sera excluido, caso contrario a carga sera ignorada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			RecLock("SX5", .F., .T.)	
			SX5->(dbDelete())			
			SX5->(MsUnLock())         	                                       						
		EndIf		
	Else    
	
		FRTGeraSL("SX5", {{"X5_FILIAL",  xFilial("SX5")}, ;
						  {"X5_TABELA",  aSX5[nI][1]}   , ;
						  {"X5_CHAVE",   aSX5[nI][2]}   , ;
						  {"X5_DESCRI",  aSX5[nI][3]}   , ;
						  {"X5_DESCSPA", aSX5[nI][4]}   , ;
						  {"X5_DESCENG", aSX5[nI][5]}}  , ;
				  !SX5->(DbSeek(xFilial("SX5")+cTab+aSX5[nI][2])))		
	
	End
Next nI

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ FRTSX2Excl   ³Autor ³ Vendas Clientes      ³Data³27/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o Arquivo eh aberto Exclusivo ou Compartilhado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FRTSX2Excl( cArquivo )
Local lRet := .F.		//Retorno da funcao

SX2->(DbSeek(cArquivo))
lRet := FWModeAccess(FWX2Chave(),3) = "E"	//Modo
If cArquivo == "SBI" .AND. !lRet                                         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o SB1/SBI sejam Compartilhados, quem determina a criacao dos arquivos de carga eh o SB0.  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX2->(DbSeek("SB0"))
	lRet := FWModeAccess(FWX2Chave(),3) = "E"	//Modo
EndIf	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ FRTGeraSGC   ³Autor ³ Vendas Clientes      ³Data³18/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o registro para que os Check-Outs nao recebam a carga ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/     
Static Function FRTGeraSGC( lGera )
Static nHandle		//Variavel de controle

Local lRet := .T.	//Retorno da funcao

If lGera
	MakeDir("\SEMAFORO\SIGAFRT\")
	nHandle := MSFCreate("\SEMAFORO\SIGAFRT\CARGA.L"+cEmpAnt)
	If nHandle < 0
		lRet := .F.
	EndIf
Else
	FClose(nHandle)
	FErase("\SEMAFORO\SIGAFRT\CARGA.L"+cEmpAnt)
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³FRTTelaBloqFil³ Autor ³ Vendas Cliente        ³ Data ³13/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para escolha de filiais para liberar/bloquear carga   	  ³±±
±±³          ³ das tabelas	                                              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Objeto auxiliar do array aSel                       	  ³±±
±±³          ³ExpA1 - Array que contem os arquivos para a geracao da carga	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function FRTTelaBloqFil( oSel,aSel )
Local lInverte      := .T.                   				//Inverte selecao?
Local oOk           := LoadBitmap(GetResources(), "LBOK")	//Objeto de sinalizacao
Local oNo           := LoadBitmap(GetResources(), "LBNO")	//Objeto de sinalizacao
Local oWndFiliais											//Objeto para criacao da tela Escolha de Filiais para Liberação/Bloqueio
Local oFiliaisSel											//Objeto para a criacao do cabecalho da tela
Local aFiliaisSel   := {}									//Array que contem as filiais para LIBERAR/BLOQUEAR

DEFAULT oSel		:= NIL
DEFAULT aSel		:= NIL
                         
aFiliaisSel := {}
DbSelectArea("SM0")
DbSeek(cEmpAnt)
While !Eof() .AND. SM0->M0_CODIGO == cEmpAnt 
	cSEQ        := 	""
	cDATASEQ  	:= 	""
	cHORASEQ 	:=	""
	nRECNO		:= 	""
	DbSelectArea("CARGA")     
	DbSetOrder(1)
	If DbSeek(FWGETCODFILIAL+aSel[oSel:nAt,2])
		While !Eof() .AND. FILIAL == FWGETCODFILIAL .AND. ARQUIVO == aSel[oSel:nAt,2]                 
			If !Empty(CARGA->ESTACAO)    
	        	CARGA->(DbSkip())
				Loop
			EndIf
			lLiberado	:=	CARGA->LIBERADO
			cSEQ        := 	CARGA->SEQ
			cDATASEQ  	:= 	CARGA->DATASEQ
			cHORASEQ 	:=	CARGA->HORASEQ
			nRECNO		:= 	CARGA->(RECNO())
			DbSkip()
		End    		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       //³           1 "",      2 "Arquivo",                          3 "Código",                                    4 "Empresa/Filial",     5 "Filial", 6 "Seqüencia", 7 "Data",  8 "Hora, 9 "Registro",                          10 "Status"  ³
					   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
        If !Empty(cSEQ)
			AAdd(aFiliaisSel, {lLiberado, aSel[oSel:nAt,2], SM0->M0_CODIGO+" / "+FWGETCODFILIAL, AllTrim(SM0->M0_NOME)+" / "+AllTrim(SM0->M0_FILIAL), FWGETCODFILIAL,         cSEQ, cDATASEQ, cHORASEQ,       nRECNO,If(lLiberado,STR0071,STR0072) }) //"Liberado","Bloqueado"
        EndIf
	EndIf
	DbSelectArea("SM0")
	DbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reposiciona o arquivo SIGAMAT.EMP   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SM0->(DbSeek(cEmpAnt+cFilAnt))
lInverte := .F.
If Len(aFiliaisSel) > 0
	DEFINE MSDIALOG oWndFiliais TITLE STR0060 FROM 10,15 TO 310,320 OF GetWndDefault() PIXEL // "Escolha de Filiais para Liberação/Bloqueio"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ 1 "", 2 "Status", 3 "Arquivo", 4 "Código", 5 "Empresa/Filial", 6 "Seqüencia", 7 "Data", 8 "Hora   ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
	@ 2,2 LISTBOX oFiliaisSel FIELDS HEADER "",STR0061,STR0013,STR0062,STR0063,STR0015,STR0016,STR0017 FIELDSIZES 14, 20, 40 SIZE 150,133 PIXEL OF oWndFiliais
	oFiliaisSel:SetArray(aFiliaisSel)
	oFiliaisSel:bLDblClick := {|| FRTUpdStatus(@oFiliaisSel, aFiliaisSel)}
	oFiliaisSel:bLine := {|| {If(aFiliaisSel[oFiliaisSel:nAt,1],oOk,oNo),;
	aFiliaisSel[oFiliaisSel:nAt,10],;
	aFiliaisSel[oFiliaisSel:nAt, 2],;
	aFiliaisSel[oFiliaisSel:nAt, 3],;
	aFiliaisSel[oFiliaisSel:nAt, 4],;
	aFiliaisSel[oFiliaisSel:nAt, 6],;
	aFiliaisSel[oFiliaisSel:nAt, 7]}}

	@ 137,2 CHECKBOX oInverte VAR lInverte PROMPT STR0043 SIZE 60,8 PIXEL OF oWndFiliais ON CHANGE {|| aEval(aFiliaisSel, {|x,nAt| x[1]:=!x[1], FRTStatusInv(aFiliaisSel,nAt)}), oFiliaisSel:Refresh() }	// "Inverte Seleção"
	
	DEFINE SBUTTON FROM 137, 95 TYPE 1 ACTION (oWndFiliais:End()) ENABLE PIXEL OF oWndFiliais
	DEFINE SBUTTON FROM 137,125 TYPE 2 ACTION (aFiliaisSel:={},oWndFiliais:End()) ENABLE PIXEL OF oWndFiliais	

	ACTIVATE DIALOG oWndFiliais CENTERED
EndIf

Return(aFiliaisSel)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FRTUpdStatus³ Autor ³ Vendas Clientes       ³ Data ³13/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o status de cada linha  do array que armazena as    ³±±
±±³          ³ filias para a LIBERAR/BLOQUEAR carga		                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Objeto auxiliar do array aFiliaisSel                  ³±±
±±³          ³ExpA2 - Array que contem as filiais para liberacao/bloqueio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function FRTUpdStatus( oFiliaisSel, aFiliaisSel )

aFiliaisSel[oFiliaisSel:nAt, 1] := !aFiliaisSel[oFiliaisSel:nAt,1]

If aFiliaisSel[oFiliaisSel:nAt,1]
	aFiliaisSel[oFiliaisSel:nAt,10] := STR0071		//"Liberado"
Else
	aFiliaisSel[oFiliaisSel:nAt,10] := STR0072		//"Bloqueado"
Endif

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRTStatusInv ³Autor ³  Vendas Clientes     ³Data³13/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inverte Status de Liberacao/Bloqueio                       ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array que contem os arquivos para a geracao da carga³±±
±±³          ³ExpN2 - Numero da linha atual                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Chamada	 | FRTTelaBloqFil()                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FRTStatusInv( aFiliaisSel, nAt )
If aFiliaisSel[nAt,1]
	aFiliaisSel[nAt,10] := STR0071		//"Liberado"
Else
	aFiliaisSel[nAt,10] := STR0072		//"Bloqueado"
Endif

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ FRTOpcaoFil  ³Autor ³  Vendas Clientes     ³Data³13/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de Opcao de Filiais para Geracao de Carga             ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Chamada	 | FRTCarga()                                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTOpcaoFil()
Local lInverte      := .T.                   				//Inverte Selecao? 
Local oOk           := LoadBitmap(GetResources(), "LBOK")	//Objeto de sinalizacao
Local oNo           := LoadBitmap(GetResources(), "LBNO")	//Objeto de sinalizacao
Local oWndFiliais											//Objeto para a criacao da tela Escolha de filiais
Local oFiliaisSel											//Objeto para a criacao do cabecalho da tela
Local aFiliaisSel   := {}									//Array que contem as filiais para LIBERAR/BLOQUEAR
Local cFil          := ""	//Retorno da funcao

aFiliaisSel := {}                          	
DbSelectArea("SM0")
DbSeek(cEmpAnt)
While !Eof() .AND. SM0->M0_CODIGO == cEmpAnt
		AAdd(aFiliaisSel, {.T., SM0->M0_CODIGO+" / "+FWGETCODFILIAL, AllTrim(SM0->M0_NOME)+" / "+AllTrim(SM0->M0_FILIAL), FWGETCODFILIAL})
	DbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reposiciona o arquivo SIGAMAT.EMP   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SM0->(DbSeek(cEmpAnt+cFilAnt))

If Len(aFiliaisSel) > 0
	DEFINE MSDIALOG oWndFiliais TITLE STR0064+STR0070 FROM 10,15 TO 310,320 OF GetWndDefault() PIXEL // "Escolha de Filiais" ## " para Geraração de Cargas"
	
	@ 2,2 LISTBOX oFiliaisSel FIELDS HEADER "",STR0062,STR0063 FIELDSIZES 14, 20, 40 SIZE 150,133 PIXEL OF oWndFiliais // "Código","Empresa/Filial"
	oFiliaisSel:SetArray(aFiliaisSel)
	oFiliaisSel:bLDblClick := {|| (aFiliaisSel[oFiliaisSel:nAt,1] := !aFiliaisSel[oFiliaisSel:nAt,1])}
	oFiliaisSel:bLine := {|| {If(aFiliaisSel[oFiliaisSel:nAt,1],oOk,oNo),;
	aFiliaisSel[oFiliaisSel:nAt,2],;
	aFiliaisSel[oFiliaisSel:nAt,3]}}
	
	@ 137,2 CHECKBOX oInverte VAR lInverte PROMPT STR0043 SIZE 60,8 PIXEL OF oWndFiliais ON CHANGE {|| aEval(aFiliaisSel, {|x| x[1]:=!x[1]}), oFiliaisSel:Refresh() }	// "Inverte Seleção"
	
	DEFINE SBUTTON FROM 137, 95 TYPE 1 ACTION If(FRTConsisVet(aFiliaisSel,@cFil),oWndFiliais:End(),'') ENABLE PIXEL OF oWndFiliais
	DEFINE SBUTTON FROM 137,125 TYPE 2 ACTION (cFil:="-1",oWndFiliais:End()) ENABLE PIXEL OF oWndFiliais
	
	ACTIVATE DIALOG oWndFiliais CENTERED
EndIf

Return cFil 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ FRTConsisVet ³Autor ³  Vendas Clientes     ³Data³13/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que valida para que tenha pelo menos uma filial     ³±± 
±±³          ³ escolhida para a Geracao de Carga                          ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Array que contem as filiais a serem selecionadas    ³±±
±±³          ³        para a geracao da carga                             ³±±
±±³          ³ExpC2 - String que contem as filiais selecionadas para a    ³±±
±±³          ³        geracao de cargas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Chamada	 | FRTOpcaoFil()                                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTConsisVet( aVet, cFilCarga )
Local lRet := .F.	//Retorno da funcao
Local nI   := 0		//Controle de loop

For nI := 1 to Len(aVet)
    If aVet[nI,1]
      	lRet := .T.
      	cFilCarga += aVet[nI,4] + '/'
    EndIf
Next nI
If !lRet
	MsgStop( STR0065, STR0002) // "Favor escolher ao menos uma filial!"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Frt040Legenda ³Autor ³Vendas Clientes       ³Data³13/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Legenda com Status da Tabela com Carga a ser        ³±± 
±±³          ³ Liberada ou Bloqueada                                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040 / Chamado em FRTLibera                             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Frt040Legenda()
Local aLegenda := { {"BR_VERMELHO",	STR0066},; 		// "Totalmente Bloqueado"
					{"BR_AMARELO" ,	STR0067},;		// "Parcialmente Liberado/Bloqueado"
					{"BR_VERDE"   ,	STR0068}}		// "Totalmente Liberado"

BrwLegenda(STR0061,STR0058,aLegenda)// "Status","Legenda"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FRTStruct		³Autor ³Vendas Clientes       ³Data³02/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria estrutura para o arquivo de cargas                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040 / Chamado em CARGAFiles                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRTStruct(cArquivo)
Local nI	     := 0	//Controle de loop	
Local aEstru	 := {}	//Estrutura do arquivo CARGA
Local nNumCampos := 0	//Numero de campos existentes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da estrutura do arquivo|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cArquivo)
aEstru := DbStruct()
ASize(aEstru, Len(aEstru)*2)
nNumCampos := Len(aEstru)   

For nI := 1 To nNumCampos Step 2
	AIns(aEstru, nI)
	If Left(cArquivo,1) == "S"
		aEstru[nI] := {"OK_"+Substr(aEstru[nI+1][1],4), "L", 1, 0}
	Else
		aEstru[nI] := {"OK_"+Substr(aEstru[nI+1][1],5), "L", 1, 0}		
	EndIf
Next nI

ASize(aEstru, nNumCampos+2)
AIns(aEstru, 1)
AIns(aEstru, 1)
aEstru[1] := {"ALTERADO", "L", 1, 0}
aEstru[2] := {"DELETADO", "L", 1, 0}  

Return aEstru

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FRTA040   ºAutor  ³Microsiga           º Data ³  03/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta a resposta no SX1 ou resposta do usuario (SXK) para aº±±
±±º          ³pergunta FRT040                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt040VlX1(cTabPar) 

Local lRet		:= .T. 
Local cTabPadrao:= SuperGetMv("MV_TABPAD")

If AllTrim(cTabPar) <> AllTrim(cTabPadrao)
	lRet := .F.
	MsgInfo(STR0074) //"Devido à integração com o cenário de vendas, a tabela de preços deve ser alterada no parâmetro MV_TABPAD"
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Frt040Sbz ºAutor  ³Vendas CRM          º Data ³  27/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega campos do SBZ                                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³Frt040Sbz(aExpA1, aExpA2)									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³ aExpA1 - Array que armazena os checkouts conectados        ³±±
±±³          ³ aExpA2 - Array que armazena os checkouts conectados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Frt040Sbz(aCampos, aCamposA)

Local aAreaX3 := GetArea("SX3") // Backup da area
Local nCampos	:= 0			// Contador de campos
Local nCamposA	:= 0			// Contador de campos
Local cCamBi	:= 0			// Campo formatado

Default aCampos 	:= {}
Default aCamposA	:= {}

DbSelectArea("SX3")
DbSetOrder(1)

If DbSeek("SBZ")

	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SBZ"	
		cCamBi := "BI" + SubStr(SX3->X3_CAMPO,3,Len(SX3->X3_CAMPO))
		cCamBi := AllTrim(cCamBi)
		nCampos := Ascan( aCampos, {|X| x[1] == cCamBi} ) 		
		If nCampos > 0 .AND. !cCamBi$"BI_COD|BI_FILIAL"
			nCamposA := Ascan( aCamposA, {|X| x[1] == cCamBi} )
			If nCamposA > 0
				aDel(aCamposA, nCamposA )
				aSize(aCamposA, Len(aCamposA)-1 )
			EndIf
			AADD(aCamposA, {aCampos[nCampos][1]	, "SBZ->"+AllTrim(SX3->X3_CAMPO)})
		EndIf	
		nCampos := 0
		SX3->(DbSkip())
	End

EndIf

RestArea(aAreaX3)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³VldRegDescºAutor  ³Fabrica             º Data ³  13/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se vai gerar carga nas estacoes com a opcao de       º±±
±±º          ³ cenario de vendas e regra de desconto ativa.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldRegDesc()   
Local lRet			:= .F.
Local cCodTabPre	:= LjXETabPre("","")   	// Cod TabPre
Local cMsg			:= ""                  	// Mensagem
Local nRegDA1		:= 0                   	// RegDA1
Local nRegSB1		:= 0                    // RegSB1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se trabalha com cenario de vendas e regra de desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCenVenda .And. lNovRegDesc
	If !Empty(AllTrim(cCodTabPre))
		DbSelectArea("DA0")
		DbSetOrder(1) //DA0_FILIAL+DA0_CODTAB
		If DbSeek(xFilial("DA0") + cCodTabPre)  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Encontrado a tabela de preco informado no parametro MV_TABPAD³
			//³ verificar se o status esta como ativo.                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If (DA0->DA0_ATIVO == "2") 
				//STR0075 - 'Para regra de desconto constar nas cargas, ' 
				//STR0076 - 'verificar a tabela de preço esta ativa.'
				cMsg :=  STR0075 + CRLF + STR0076
			Else
				// ---
				// verifica se as TABELAS DE PREÇOS possuem todos os produtos cadastrados
				// ---

				DbSelectArea("SB1")
				DbEval( {||nRegSB1++},, {|| (SB1->B1_FILIAL == xFilial("SB1"))} )
				SB1->( DbCloseArea() )			
				
				DA0->( DbGoTop() )
	
				DbSelectArea("DA1")
				DA1->( DbSetOrder(1) )	//DA1_FILIAL + DA1_CODTAB + DA1_CODPRO + DA1_INDLOT + DA1_ITEM
				
				While DA0->(!Eof()) .AND. DA0->DA0_FILIAL == xFilial("DA0")
					If DA1->( DbSeek(DA0->DA0_FILIAL + DA0->DA0_CODTAB) )
						DbEval( {||nRegDA1++}, Nil, {|| (DA0->DA0_FILIAL + DA0->DA0_CODTAB) == (DA1->DA1_FILIAL + DA1->DA1_CODTAB)} )
					EndIf
	
					If nRegSB1 <> nRegDA1
						If Empty(cMsg)
							cMsg := STR0077	+ CRLF //"As tabelas de preço abaixo, não possuem todos os produtos cadastrados: "
							cMsg += DA0->DA0_CODTAB
						Else
							cMsg += " / " + DA0->DA0_CODTAB
						EndIf
					EndIf

					nRegDA1 := 0 //zeramos o contador de produtos de tabela de preço

					DA0->( DbSkip() )
				End

				//emitimos um alerta ao usuário, caso haja inconsistencia em alguma Tabela de Preço
				If !Empty(cMsg)
					cMsg += CRLF + STR0079	//"Recomendamos que revise a(s) tabela(s), para que não haja produtos sem preço."
					MsgAlert(cMsg, STR0002)
					cMsg := ""
				EndIf

				DA1->( DbCloseArea() )

			EndIf
		Else   
			//STR0075 - 'Para regra de desconto constar nas cargas, ' 
			//STR0078 - ' informar um código existente da tabela de preço no parâmetro MV_TABPAD.'  				
			cMsg :=  STR0075 + CRLF + STR0078		
		EndIf
	EndIf

	If !Empty(cMsg)
		ApMsgStop( cMsg , STR0002 ) //"Atencao"
	EndIf
EndIf
		
lRet := Empty(cMsg) 

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³FRTVldUser	³Autor ³ Vendas & CRM		  ³Data³26/07/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o usuario tem acesso a todas empresas/filiais  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 - Indica se usuario possui acesso a todas emp/fil	  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FRTA040													  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FRTVldUser()
Local lRet		:= .F.	//retorno da funcao
Local nI		:= 0	//contador
Local aInfUser	:= {}	//array com informacoes do usuario

PswOrder(2)	//o indice usado pela funcao PswSeek, sera NOME DE USUARIO/GRUPO

If PswSeek( SubStr(cUsuario,7,15) )	
	aInfUser := PswRet()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o usuario possui a opcao "Priorizacao do Grupo" habilitada, 	|
	//³ verificamos se o grupo possui acesso a todas empresas/filiais,	|
	//³ senao verificamos se o proprio usuario possui esse acesso		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	If aInfUser[02][11]	//priorizacao do grupo

		For nI := 1 to Len( aInfUser[1][10] ) //grupos que o usuario esta cadastrado
			
			//verifica se o grupo possui acesso a todas empresas/filiais
			If FWGrpEmp( aInfUser[1][10][nI] )[1] == "@@@@"
				lRet := .T.
				Exit
			EndIf

		Next nI

	Else
		//verifica se o usuario possui acesso a todas empresas/filiais
		If aInfUser[2][6][1] == "@@@@"
			lRet := .T.
		EndIf
	EndIf

EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} FrtCriaTrb
Rotina para criacao da tabela temporaria
	
@author  Vendas & CRM
@version P12.1.17
@since   07/12/2017
@return  n/a
/*/
//--------------------------------------------------------
Static Function FrtCriaTrb( lCreate	,	lUseArea,	cDirTrb,	aStruct,;
							cNameTrb,	lShared							)
Local cDriver := "" 

Default lCreate		:= .T.
Default lUseArea	:= .T.
Default cDirTrb		:= ""
Default aStruct 	:= {}
Default cNameTrb	:= ""
Default lShared 	:= .F.

cDriver := LJILRealDriver()

If lCreate
	DbCreate(cDirTrb,aStruct,cDriver)
EndIf

If lUseArea
	DbUseArea(.T.,cDriver,cDirTrb,cNameTrb,lShared,.F.)
EndIf

Return