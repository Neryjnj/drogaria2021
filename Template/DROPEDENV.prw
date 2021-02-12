
#include "APWizard.ch"
#include "PROTHEUS.CH"
 
//Extras
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#xcommand DEFAULT <uVar1> := <uVal1> ;
[, <uVarN> := <uValN> ] => ;
<uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
[ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

//Pula Linha
#Define CTRL Chr(13)+Chr(10)

/*���������������������������������������������������������������������������
���Programa  �DROPEDENV�Autor  �Thiago Honorato	 � Data �  09/03/05       ���
�������������������������������������������������������������������������͹��
���Desc.     � Processamento do EDI - Geracao do arquivo de envio de      ���
���          � Pedidos de compras para os Fornecedores     	              ��� 
���          �(antigo DROPEDEDIE.prw 									  ��� 
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/
Template Function DROPEDENV
Local oWizard, oPanel
Local oGrp1,oRad1,oGet1
Local oGrp2,oGet2
Local oGetCodEmpresa, oGetLojEmpresa
Local oGetRegProc
Local oGetEmp
Local oGetArqEDI
Local nArq  := 0
Local nI
Local aDir  := {}
Local aCpos := {}
//Recupera a propriedade StartPath do Server.Ini
Local cStartPath := GetSrvProfString("STARTPATH","")
Local cTxt1 := ""
Local cTxt2 := ""
Local cDir			:= cStartPath
Local cDirEDI		:= cStartPath
Local cExt  := "env"   //Extensao do arquivo de configuracao para envio ao cliente
Local cPicture := ""

Local cText :=	'Este programa ir� gerar o arquivo de envio contendo os ' + ;
'dados do pedido de compra de acordo com a configura��o ' + ;
'pr�-definida no configurador do EDI.' + CTRL + CTRL + ;
'Para continuar clique em Avan�ar.'

Local bValid

//Private cCodEmpresa := Space(TamSX3("A1_COD")[1])
//Private cLojEmpresa := Space(TamSX3("A1_LOJA")[1])

// Variaveis da Pergunte no Segundo Panel
Private cCodFilIni := Space(2)
Private cCodFilFim := Space(2)
Private dDtEmssIni := cTOD("  /  /    ")
Private dDtEmssFim := cTOD("  /  /    ")
Private cCodForIni := Space(TamSX3("C7_FORNECE")[1])
Private cLojForIni := Space(TamSX3("C7_LOJA")[1])
Private cCodForFim := Space(TamSX3("C7_FORNECE")[1])
Private cLojForFim := Space(TamSX3("C7_LOJA")[1])
Private cCodPedIni := Space(TamSX3("C7_NUM")[1])
Private cCodPedFim := Space(TamSX3("C7_NUM")[1])
Private cArq        := GetSrvProfString("STARTPATH","")      //Path onde serah gravado o arquivo de envio
Private cArqLogEnv	:= cArq+"pcenvioedi.log"  //Grava o arquivo de log de erro no mesmo diretorio do arquivo de envio
Private cArqLogRet	:= cArq+"pcretornoedi.log"
Private lReenvio	:= .F.  //

Private nRegProc    := 0   //Registros processados na geracao do arquivo de envio. Mostrado no resultado do processamento(quinto panel)
Private cArqEDI     := ""  //Nome e patch do arquivo de envio gerado
Private cNomeFor    := ""
Private cBLinSC7    := ""
Private oOk		    := LoadBitMap(GetResources(), "LBOK")
Private oNo		    := LoadBitMap(GetResources(), "LBNO")
Private oNever	    := LoadBitMap(GetResources(), "DISABLE")
Private oLBPedComp
Private lTela		:= .T.   // Mostra informa��es na Tela (Quando execudada atravez de JOB eh .F.
Private cNumPed		:= ""	 // Quando executado via JOB eh sobre este numero de PC que sera alimentado o array aDadosPed e gerado o arquivo texto
Private lRotinaAut  := .T.
Private lFile_Skip	:= .T.  //  Variavel p/ nao validar existencia de arquivo por problema da func. File() no linux.

//������������������������������Ŀ
//�Estrutura do array aDadosPed  �
//�------------------------------�
//�1-Marca de selecao            �
//�2-Cod. Fornecedor             �
//�3-Loja Fornecedor             �
//�4-Nome Fornecedor             �
//�5-Numero do Pedido de Compras �
//�6-Valor do Pedido de Compras  �
//�7-Data emissao                �
//�8-Cond. Pagamento do PC       �
//�9-Deletado 					 �
//��������������������������������
Private aDadosPedC  := {}

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

PedCEDIDir(cDir,cExt,@aDir)

DbSelectArea("SC7")
DbSetOrder(1)
//�����������������������Ŀ
//�Inicializacao do Wizard�
//�������������������������
DEFINE WIZARD oWizard TITLE 'Gera��o do arquivo de envio do Pedido de Compra' ;
HEADER 'Wizard gera��o do arquivo de envio:' ;
MESSAGE 'Processamento autom�tico.' TEXT cText NEXT {|| .T.} FINISH {|| .T.} PANEL


//�������������������������������������������Ŀ
//�Segundo Panel - Pergunte do fechamento     �
//���������������������������������������������

CREATE PANEL oWizard HEADER 'Dados para gera��o do arquivo' ;
MESSAGE 'Informe os dados abaixo para a gera��o do arquivo de envio.' ;
BACK {|| .T. } NEXT {|| PedCEDIFech() } FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(2)
 /*
cCodFilIni		:= SPACE(2)
cCodFilFim	:= "99"		// SPACE(2)  //
dDtEmssIni	:= CTOD("01/07/05")
dDtEmssFim	:= CTOD("31/12/09")
cCodForIni		:= SPACE(6)
cLojForIni		:= SPACE(2)
cCodForFim	:= "ZZZZZZ"	// SPACE(6)  //
cLojForFim	:= "ZZ"			// SPACE(2)  //
cCodPedIni	:= SPACE(6)
cCodPedFim	:= "ZZZZZZ"	// SPACE(6)   //
*/

TSay():New(03,05,{|| "Filial Inicial"},oPanel,,,,,,.T.)
oGetLojaIni := TGet():New(02,70,bSETGET(cCodFilIni),oPanel,45,10,,,,,,,,.T.,,,,,,,.F.,,"L53",)

bValid   := {|| !EMPTY(cCodFilFim) .and. cCodFilFim >= cCodFilIni}
TSay():New(03,145,{|| "Filial Final"},oPanel,,,,,,.T.)
oGetLojaFim := TGet():New(02,210,bSETGET(cCodFilFim),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L53",)

TSay():New(20,05,{|| "Data de emiss�o inicial"},oPanel,,,,,,.T.)
oGetDtEmss := TGet():New(19,70,bSETGET(dDtEmssIni),oPanel,50,10,,,,,,,,.T.,,,,,,,.F.,,,)

bValid   := {|| IIf(!Empty(dDtEmssFim),(Dtos(dDtEmssFim) >= Dtos(dDtEmssIni)),.T.)}
TSay():New(20,145,{|| "Data de emiss�o final"},oPanel,,,,,,.T.)
oGetDtEmss := TGet():New(19,210,bSETGET(dDtEmssFim),oPanel,50,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

TSay():New(37,05,{|| "Fornecedor Inicial"},oPanel,,,,,,.T.)
oGetCodFrIni := TGet():New(36,70,bSETGET(cCodForIni),oPanel,45,10,,,,,,,,.T.,,,,,,,.F.,,"L51",)

TSay():New(37,145,{|| "Loja Fornecedor Inicial"},oPanel,,,,,,.T.)
oGetLojFrIni := TGet():New(36,210,bSETGET(cLojForIni),oPanel,20,10,,,,,,,,.T.,,,,,,,.F.,,,)

bValid   := {|| !empty(cCodForFim)  .and. cCodForFim >= cCodForIni}
TSay():New(54,05,{|| "Fornecedor Final"},oPanel,,,,,,.T.)
oGetCodFrFim := TGet():New(53,70,bSETGET(cCodForFim),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L51",)

bValid   := {|| !empty(cLojForFim)  }
TSay():New(54,145,{|| "Loja Fornecedor Final"},oPanel,,,,,,.T.)
oGetLojFrFim := TGet():New(54,210,bSETGET(cLojForFim),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

TSay():New(71,05,{|| "Pedido de Compra Inicial"},oPanel,,,,,,.T.)
oGetCodFrFim := TGet():New(70,70,bSETGET(cCodPedIni),oPanel,45,10,,,,,,,,.T.,,,,,,,.F.,,"SC7",)

bValid   := {|| !empty(cCodPedFim) .And. cCodPedFim >= cCodPedIni}
TSay():New(71,145,{|| "Pedido de Compras Final"},oPanel,,,,,,.T.)
oGetLojFrFim := TGet():New(70,210,bSETGET(cCodPedFim),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SC7",)

//���������������������������������������������������Ŀ
//�Terceiro Panel-Arquivo Lay Out e de envio para EDI �
//�����������������������������������������������������

CREATE PANEL oWizard HEADER 'Sele��o do arquivo de configura��o do lay-out e do arquivo de envio para EDI.' ;
MESSAGE 'Informe os caminhos dos arquivo de layout e de envio. ATEN��O! Se j� houver um arquivo de envio de mesmo nome neste diret�rio, este ser� sobrescrito!';
BACK {|| .T. } NEXT {|| IIf(EDIVldDirC(cDir),(cDirEDI := cArq,.T.),.F.) } FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(3)

oGrp1 := TGroup():New(5,2,135,280," Sele��o dos caminhos dos arquivos: ",oPanel,,,.T.)
TSay():New(25,08,{|| "Escolha o caminho do arquivo de lay-out:"},oPanel,,,,,,.T.)
oGet1 := TGet():New(35,08, bSETGET(cDir),oPanel,110,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(35,120,14, {|| cDir := cGetFile("Escolha o diretorio|*.*|","Escolha o caminho do arquivo de configura��o."             ,0,"SERVIDOR"+cDir,.T.,GETF_ONLYSERVER+GETF_RETDIRECTORY), PedCEDIDir(cDir,cExt,@aDir)},oPanel,)

TSay():New(65,08,{|| "Escolha o caminho do arquivo de envio:"},oPanel,,,,,,.T.)
oGet2 := TGet():New(75,08,bSETGET(cArq),oPanel,110,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(75,120,14, {|| cArq := cGetFile("Escolha o diretorio|*.*|","Escolha o caminho onde ser� criado o arquivo de envio.",0,"SERVIDOR"+cDir,.T.,GETF_ONLYSERVER+GETF_RETDIRECTORY) },oPanel,)

//����������������������������������������������������������Ŀ
//�Quarto Panel - Confirmacao final / chamada processamento. �
//������������������������������������������������������������
CREATE PANEL oWizard HEADER 'Confirma��o dos dados e processamento:' ;
MESSAGE 'Confirme os dados abaixo.' ;
BACK {|| .T. } NEXT {|| PedEDIVld(.T.,cDir,cDirEDI) } FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(4)

TSay():New(05,05,{|| "Gera��o do arquivo de envio do pedido de compras para EDI."},oPanel,,,,,,.T.)
TSay():New(35,05,{|| "Caminho do arquivo de Lay-Out:" },oPanel,,,,,,.T.)
TSay():New(65,05,{|| "Caminho do Arquivo para EDI:" },oPanel,,,,,,.T.)
oGet3 := TGet():New(35,100, bSETGET(cDir),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)
oGet4 := TGet():New(65,100, bSETGET(cDirEDI),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)
TSay():New(95,05,{|| "Clique em Avan�ar para selecionar o Pedido de Compra." },oPanel,,,,,,.T.)

//��������������������������������������������Ŀ
//�Quinto Panel - Confirmar o Pedido de Compra �
//����������������������������������������������
CREATE PANEL oWizard HEADER 'Confirma��o do Pedido de Compra:' ;
MESSAGE 'Selecione para qual Pedido de Compra deve ser gerado o arquivo de envio.' ;
BACK {|| .T. } NEXT {|| T_PedEDIPr(cDir,cDirEDI,lTela,cNumPed,.f.) } FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(5)

aCabec  := {"","Cod. Fornecedor","Loja Fornecedor","Nome Fornecedor","N�. Pedido","Valor do Pedido","Data Emiss�o","Cond. Pgto"}
aTam    := {5,25,30,25,15,50,50,32}
Aadd(aCpos  ,"nSel")
Aadd(aCpos  ,"C7_FORNECE")
Aadd(aCpos  ,"C7_LOJA")
Aadd(aCpos  ,"Posicione('SA2',1,xFilial('SA2')+C7_FORNECE+C7_LOJA,'A2_NOME')")
Aadd(aCpos  ,"C7_NUM")
Aadd(aCpos  ,"C7_TOTAL")
Aadd(aCpos  ,"C7_EMISSAO")
Aadd(aCpos  ,"Posicione('SE4',1,xFilial('SE4')+C7_COND,'E4_DESCRI')")

//Inicializa array dos Pedidos de Compras
aDadosPedC  := MontArrayP(aCpos)

oLBPedComp	:= TwBrowse():New(000,000,000,000,,aCabec,aTam,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBPedComp:nHeight	:=200
oLBPedComp:nWidth	:=565
oLBPedComp:lColDrag	:= .T.
oLBPedComp:nFreeze	:= 1
oLBPedComp:SetArray(aDadosPedC)
cBLinSC7:= "{If(aDadosPedC[oLBPedComp:nAt,1]>0,oOk,If(aDadosPedC[oLBPedComp:nAt,1]<0,oNo,oNever))"
oLBPedComp:bLDblClick :={ || SelecPedC()}

For nI:= 2 to Len(aCpos)
	cPicture := Alltrim(Posicione("SX3",2,aCpos[nI],"X3_PICTURE"))
	cBLinSC7 := cBLinSC7 + ", Transform(aDadosPedC[oLBPedComp:nAT][" + alltrim(Str(nI))+ "], '" + cPicture + "')"
Next nI

oLBPedComp:bLine:= {|| &(cBLinSC7 + "}") }

TSay():New(105,05,{|| "Clique em Avan�ar para realizar o processamento." },oPanel,,,,,,.T.)

//���������������������������������������Ŀ
//�Sexto Panel - Status do Processamento  �
//�����������������������������������������
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo o resultado do Processamento' ;
BACK {|| .F. } NEXT {|| .T. } FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(6)

TSay():New(15,05,{|| "Fornecedor:" },oPanel,,,,,,.T.)
oGetEmp := TGet():New(15,70, bSETGET(cNomeFor),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)

TSay():New(35,05,{|| "Arquivo de envio gerado:" },oPanel,,,,,,.T.)
oGetArqEDI := TGet():New(35,70, bSETGET(cArqEDI),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)

TSay():New(55,05,{|| "Registros processados:" },oPanel,,,,,,.T.)
oGetRegProc := TGet():New(55,70, bSETGET(nRegProc),oPanel,60,10,,,,,,,,.T.,,,,,,,.T.,,,)

ACTIVATE WIZARD oWizard CENTER
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PedCEDIDir�Autor  �Carlos A. Gomes Jr. � Data �  11/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica validade do Path e refaz vetor aDir.              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PedCEDIDir(cDir,cExt,aDir)
Local   aTMP := {}

aDir := {}
If Empty(cDir)
	MsgAlert("Caminho inv�lido!")
	Return .F.
EndIf
aTMP := Directory(cDir+"*."+cExt)
AEval(aTMP,{|x,y| AAdd(aDir, x[1]) })

Return .T.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PedEDIVld  �Autor  �Carlos A. Gomes Jr. � Data �  14/05/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Funcao de processamento do EDI compras de Drogaria.         ���
���          �                                                             ���
���          � Parametros:                                                 ���
���          � lTela = Exibir mensagens em tela .T. no server .F.          ���
���          � cTxt1 = Nome e caminho do arquivo de Lay-Out                ���
���          � cTxt2 = Nome e caminho do arquivo que sera tratado          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function PedEDIVld(lTela,cDir,cDirEDI)

Local lRet      := .T.

DEFAULT lTela   := .F.
DEFAULT cDir    := ""
DEFAULT cDirEDI := ""

If Empty(cDir)
	If lTela
		MsgAlert("Digite o caminho do arquivo de Lay-Out.")
	Else
		T_EDIGrvLog("Digite o caminho do arquivo de Lay-Out.",cArqLogEnv)
	EndIf
	Return .F.
EndIF

If Empty(cDirEDI)
	If lTela
		MsgAlert("Selecione o caminho do arquivo de envio.")
	Else
		T_EDIGrvLog("Selecione o caminho do arquivo de envio.",cArqLogEnv)
	EndIf
	Return .F.
Endif

//�������������Ŀ
//�Processamento�
//���������������
Processa( { |lEnd| lRet  := BuscaPedC(cDir,cDirEDI) }, "Processando...",, .F.)

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BuscaPedC �Autor  �Thiago Honorato     � Data �  07/03/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca o(s) Pedido(s) de Compra(s)             		      ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function BuscaPedC(cDir,cDirEDI)

Local lRet 		:= .T.
Local nHandle
Local aLayOut   := {}
Local cIndex    := ""
Local cKey	    := ""
Local cFiltro   := ""
Local nPosPed   := 0
LOCAL lEncontrou := .f.
Local _nI
Local lViaQuery := .f.    // Indica se selecao dos pedidos ser� feita via Query no Banco de dados
Local cArqTrb := "SC7"
DbSelectArea("SC7")
DbSetorder(5)
aDadosPedC := {}

ProcRegua(SC7->(RecCount() ))

#IFDEF TOP
	If ( TcSrvType()!="AS/400" ) .and. lViaQuery  // Aqui apos instalar um SGBD na Maquina tirar a parte da linha apos o .and. e debugar linhas abaixo
		
		cArqTrb:= "TRBSB1"
		cQuery := "SELECT SC7.* FROM " + RetSqlName("SC7")+" SC7 "
		cQuery += "WHERE SC7.C7_ENVIAR	<> '1'  And "
		cQuery += "SC7.C7_NUM	 >= '"+(cCodPedIni) +"'    And "
		cQuery += "SC7.C7_NUM	 <= '"+(cCodPedFim) +"'  And "
		cQuery += "SC7.C7_FILIAL >= '" +(cCodFilIni)+ "'  And "
		cQuery += "SC7.C7_FILIAL <= '" +(cCodFilFim)+ "'  And "
		cQuery += "SC7.C7_EMISSAO  >= '"+ DTOS(dDtEmssIni) +"' And "
		cQuery += "SC7.C7_EMISSAO  <= '"+ DTOS(dDtEmssFim) +"' And "
		cQuery += "SC7.C7_FORNECE >= '"+(cCodForIni) +"'  And "
		cQuery += "SC7.C7_FORNECE <= '"+(cCodForFim) +"'   And "
		cQuery += "SC7.D_E_L_E_T_<>'*'  "
		cQuery += "ORDER BY "+SqlOrder(SC7->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cArqTrb)
		lViaQuery := .T.
		dbGoTop()
		
		While (cArqTrb)->(!Eof())
			IncProc()
			nPosPed := AScan(aDadosPedC,{|x| x[5] == SC7->C7_NUM})
			If nPosPed = 0// verifica se um Pedido de Compras ja existe
				AAdd(aDadosPedC,{-1,SC7->C7_FORNECE,SC7->C7_LOJA,Posicione("SA2",1,xFilial("SA2")+C7_FORNECE+C7_LOJA,"A2_NOME"),SC7->C7_NUM,SC7->C7_TOTAL,SC7->C7_EMISSAO,Posicione("SE4",1,xFilial("SE4")+C7_COND,"E4_DESCRI")})
				lEncontrou := .T.
			Else// se existir, so faz a totalizacao do valor do pedido
				aDadosPedC[nPosPed][6] += SC7->C7_TOTAL
			Endif
			dbskip()
		End

	Else
		DbSeek( cCodFilIni , .T. )
	EndIf
#ELSE
	DbSeek( cCodFilIni , .T. )
#ENDIF

if !lViaQuery
	cCodFilFim := if(val(cCodFilFim) <= 0 , "99" , cCodFilFim )
	if val(cCodFilIni) <= val(cCodFilFim)
		For _nI := val(cCodFilIni) to val(cCodFilFim)
			DbSeek( strzero(_nI,2)  , .T. )
			if eof() .or. C7_FILIAL <> strzero(_nI,2)
				loop
			endif
			while !eof() .and. C7_FILIAL == strzero(_nI,2)
				if DTOS(C7_EMISSAO) >= DTOS(dDtEmssIni) .And. DTOS(C7_EMISSAO) <= DTOS(dDtEmssFim) .And. C7_FORNECE >= cCodForIni .And. ;
					C7_FORNECE <= cCodForFim .and. C7_NUM	 >= cCodPedIni .And. C7_NUM <= cCodPedFim .And. C7_ENVIAR	== ' '

					nPosPed := AScan(aDadosPedC,{|x| x[5] == SC7->C7_NUM})
					If nPosPed = 0// verifica se um Pedido de Compras ja existe
						AAdd(aDadosPedC,{-1,SC7->C7_FORNECE,SC7->C7_LOJA,Posicione("SA2",1,xFilial("SA2")+C7_FORNECE+C7_LOJA,"A2_NOME"),SC7->C7_NUM,SC7->C7_TOTAL,SC7->C7_EMISSAO,Posicione("SE4",1,xFilial("SE4")+C7_COND,"E4_DESCRI")})
						lEncontrou := .T.
					Else// se existir, so faz a totalizacao do valor do pedido
						aDadosPedC[nPosPed][6] += SC7->C7_TOTAL
					Endif
				endif
				dbskip()
				if C7_FILIAL <> strzero(_nI,2)
					exit
				endif
			End
		Next
	endif
endif


If ! lEncontrou
	MsgAlert("N�o foi selecionado nenhum Pedido de Compras com os par�metros informados.")
	lRet := .F.
Endif
If lRet
	oLBPedComp:SetArray(aDadosPedC)
	oLBPedComp:bLine:= {|| &(cBLinSC7 + "}") }
EndIf


***********************************************************************************
//// Versao anterior com erro na abertura de indice temporario em linux ( comando dbSetIndex(cIndex+OrdBagExt())  ) devido provavelmente aos arquivos de indices ficarem em diret�rio diferente do arquivo de dados no Linux .
//// Seleciona os Pedido de Compras de Acordo com o Filtro especificado.
//DbSelectArea("SC7")
//DbSetorder(3)
//aDadosPedC := {}
////���������������������������������������������������Ŀ
////�Filtrando o SC7 com base nos parametros informados �
////�����������������������������������������������������
//cIndex    := CriaTrab(Nil,.F.)
//cKey      := "C7_FILIAL + DTOS(C7_EMISSAO)+C7_FORNECE+C7_LOJA+C7_NUM"
//cFiltro   := "C7_FILIAL >= '" +(cCodFilIni)+ "'  .And. "
//cFiltro   += "C7_FILIAL <= '" +(cCodFilFim)+ "'  .And. "
//cFiltro   += "DTOS(C7_EMISSAO)  >= '"+ DTOS(dDtEmssIni) +"' .And. "
//cFiltro   += "DTOS(C7_EMISSAO)  <= '"+ DTOS(dDtEmssFim) +"' .And. "
//cFiltro   += "C7_FORNECE >= '"+(cCodForIni) +"'  .And. "
//cFiltro   += "C7_FORNECE <= '"+(cCodForFim) +"'   .And. "
//cFiltro   += "C7_NUM	 >= '"+(cCodPedIni) +"'   .And. "
//cFiltro   += "C7_ENVIAR	 == ' '  .And. "
//cFiltro   += "C7_NUM	 <= '"+(cCodPedFim) +"'            "
//
//IndRegua("SC7",cIndex,cKey,,cFiltro,"Filtrando Registros...")
//nIndAtu := RetIndex("SC7") + 1
//dbSelectArea("SC7")
//dbSetIndex(cIndex+OrdBagExt())
//dbSetOrder(nIndAtu)
//dbGoTop()

//If Eof()
//	MsgAlert("N�o foi selecionado nenhum Pedido de Compras com os par�metros informados.")
//	lRet := .F.
//Else
//	While !Eof()
//		nPosPed := AScan(aDadosPedC,{|x| x[5] == SC7->C7_NUM})
//		If nPosPed = 0// verifica se um Pedido de Compras ja existe
//			AAdd(aDadosPedC,{-1,SC7->C7_FORNECE,SC7->C7_LOJA,Posicione("SA2",1,xFilial("SA2")+C7_FORNECE+C7_LOJA,"A2_NOME"),SC7->C7_NUM,SC7->C7_TOTAL,SC7->C7_EMISSAO,Posicione("SE4",1,xFilial("SE4")+C7_COND,"E4_DESCRI")})
//  		Else// se existir, so faz a totalizacao do valor do pedido
//			aDadosPedC[nPosPed][6] += SC7->C7_TOTAL
//		Endif
//		DbSkip()
//	End
//	lRet := .T.
//Endif
//If lRet
//	oLBPedComp:SetArray(aDadosPedC)
//	oLBPedComp:bLine:= {|| &(cBLinSC7 + "}") }
//EndIf

//RetIndex("SC7")// retorna para o primeiro indice
//dbClearFilter()//limpa o filtro
//FErase(cIndex+OrdBagExt())//apaga o cIndex

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PedEDIPr  �Autor  �Thiago Honorato	 � Data �  10/03/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera o arquivo de envio com base no arquivo de configuracao ���
���          �de lay-out                                                  ���
�������������������������������������������������������������������������͹��
���Parametros�cDir         diretorio do arquivo do Lay-out de Envio       ���
���          �cDirEDI      diretorio do arquivo do Envio                  ���
���          �lTela        .T. tem Tela  .F. Execus�o em JOB              ���
���          �cNumPed      Numero do P.C. criado                          ���
���          �lReenvio     Quando .T. Dropedir.prw leu arquivo de retorno ���
���          �             e gerou este P.C. com os Saldos                ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function PedEDIPr(cDir,cDirEDI,lTela,cNumPed,lReenvio)

Local lErroDet  := .F.
Local lFirst    := .T.
Local lRet      := .T.
Local lSelec    := .F.
Local cCodFor	:= "" // codigo do fornecedor
Local cLojFor	:= "" // loja do fornecedor
Local cArqLay   := ""
Local lGeraLog  := .F.
Local aLayOut   := {}
Local nX
Local cMsg		:= ""		//Mensagem informativa

DbSelectArea("SC7")
DbSetOrder(1)

if !lTela .or. lReenvio  //Se for execus�o em Job e/ou Reenvio devo preencher array aDadosPedC pois estah vazia
	aDadosPedC := {}
	IF DBSEEK( XFilial("SC7") + cNumPed )
		While !Eof() .and. SC7->C7_NUM == cNumPed
			nPosPed := AScan(aDadosPedC,{|x| x[5] == cNumPed })
			If nPosPed = 0	// verifica se um Pedido de Compras ja existe
				AAdd(aDadosPedC,{1,SC7->C7_FORNECE,SC7->C7_LOJA,Posicione("SA2",1,xFilial("SA2")+C7_FORNECE+C7_LOJA,"A2_NOME"),SC7->C7_NUM,SC7->C7_TOTAL,SC7->C7_EMISSAO,Posicione("SE4",1,xFilial("SE4")+C7_COND,"E4_DESCRI")})
			Else// se existir, so faz a totalizacao do valor do pedido
				aDadosPedC[nPosPed][6] += SC7->C7_TOTAL
			Endif
			DbSkip()
		End
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSelectArea("SC7")
	Else
		T_EDIGrvLog("Pedido numero " + cNumPed + " N�o encontrado na filial " + XFilial("SC7") ,cArqLogEnv)
	Endif
endif

//����������������������������������������������������������������Ŀ
//�Verifica qual pedido de compras foi selecionado                 �
//������������������������������������������������������������������
For nX := 1 to Len(aDadosPedC)
	If aDadosPedC[nX][1] == 1
		lSelec     := .T.
		cCodFor  := aDadosPedC[nX][2]
		cLojFor  := aDadosPedC[nX][3]
		cNumPed  := aDadosPedC[nX][5]
		Exit
	EndIf
Next nX

If !lSelec
	If ltela
		MsgAlert("Selecione um Pedido de Compra para a gera��o do arquivo de envio.")
	Endif
	T_EDIGrvLog("Selecione um Pedido de Compra para a gera��o do arquivo de envio." ,cArqLogEnv)
	Return .F.
EndIf

//���������������������������������������Ŀ
//�Posicionamento do Fornecedor			  �
//�����������������������������������������
DbSelectArea("SA2")
DbSetOrder(1)
If DbSeek(xFilial("SA2")+cCodFor+cLojFor)
	If SA2->A2_FTPEDI == "0"
		cMsg := "Fornecedor configurado para n�o gerar arquivo de EDI de pedido de compra. "
	Endif
Else
	cMsg := "Fornecedor n�o encontrado na base de dados"
Endif

If !Empty(cMsg)
	If ltela
		MsgAlert(cMsg)
		T_EDIGrvLog(cMsg ,cArqLogEnv)
		Return .F.	
	Endif
Endif

//Nome do arquivo de configuracao de lay-out do arquivo de envio
If Empty(SA2->A2_LAYOUTE)
	If ltela
		MsgAlert("Arquivo de configura��o de layout n�o preenchido! Verificar o campo Layout Ped. no cadastro do fornecedor.")
	Endif
	T_EDIGrvLog("Arquivo de configura��o de layout n�o preenchido! Verificar o campo Layout Ped. no cadastro do fornecedor." ,cArqLogEnv)
	Return .F.
EndIf

//Nome do arquivo de envio a ser gerado para o fornecedor
If Empty(SA2->A2_ARQEDI)
	If ltela
		MsgAlert("Nome do Arquivo de envio n�o preenchido! Verificar o campo Arquivo Envio do cadastro de fornecedores.")
	Endif
	T_EDIGrvLog("Nome do Arquivo de envio n�o preenchido! Verificar o campo Arquivo Envio do cadastro de fornecedores." ,cArqLogEnv)
	Return .F.
EndIf

if !lTela .or. lReenvio //Se for execusao em Job e/ou Reenvio devo preencher array cDir e cDirEDI pois estao vazias
	//cDir	:= alltrim(SA2->A2_DIRLAYE)
	//cDirEDI := alltrim(SA2->A2_DIREDIE)
	cDir		:= GetSrvProfString("STARTPATH","")
	cDirEDI	:= GetSrvProfString("STARTPATH","")
Endif

cArqLay		:= alltrim(SA2->A2_LAYOUTE)		//cArqLay	:= cDir+SA2->A2_LAYOUTE
cArqEDI		:= alltrim(SA2->A2_ARQEDI)		//cArqEDI		:= cDirEDI+SA2->A2_ARQEDI
cNomeFor	:= SA2->A2_NOME

_cServ		:= alltrim(SA2->A2_FTPSERV)
_nPort		:= VAL(SA2->A2_FTPPORT)
_cUser		:= alltrim(SA2->A2_FTPUSER)
_cPass		:= alltrim(SA2->A2_FTPPASS)
_cDirOri	:= cDirEDI
_cArqOri	:= alltrim(SA2->A2_ARQEDI)
_cDirDst	:= alltrim(SA2->A2_FTPDIRD)
_cArqDst	:= alltrim(SA2->A2_FTPARQD)
_cEmlDst	:= ""
_cEmlTit	:= ""
_cEmlArq	:= ""
_cQuote		:= ""

If !File(cArqLay)
	If ltela
		MsgAlert("Arquivo de configura��o de layout n�o encontrado! Verificar o caminho selecionado e o nome do arquivo.")
	Endif
	T_EDIGrvLog("Arquivo de configura��o de layout n�o encontrado! Verificar o caminho selecionado e o nome do arquivo." ,cArqLogEnv)
	lRet := .F.
EndIf

If lRet
	//Recupera em um array os campos e posicoes do arquivo de configuracao de lay-out
	aLayOut := __VRestore(cArqLay)
	If Len(aLayOut) != 4
		If lTela
			MsgAlert("Arquivo de configura��o de layout inv�lido! Verificar a estrutura do arquivo atrav�s do configurador EDI.")
		Endif
		T_EDIGrvLog("Arquivo de configura��o de layout inv�lido! Verificar a estrutura do arquivo atrav�s do configurador EDI." ,cArqLogEnv)
		lRet := .F.
	EndIf
	
	//����������������������������������������������������������������������������������������Ŀ
	//�Se existir, excluir o arquivo de envio para sobrepor                                    �
	//������������������������������������������������������������������������������������������
	
	//Cria o arquivo de envio
	nHandle := FCreate(cArqEDI)
	If nHandle == -1
		If lTela
			MsgAlert("N�o foi poss�vel criar o arquivo de envio "+cArqEDI+ " .")
			lRet := .F.
		Endif
		T_EDIGrvLog("N�o foi poss�vel criar o arquivo de envio "+cArqEDI+" ." ,cArqLogEnv)
		lRet := .F.
	Else
		FClose(nHandle)
	EndIf
	
	lFirst    := .T.
	nRegProc  := 0
	cArqLay   := SA2->A2_LAYOUTE	//cDir+SA2->A2_LAYOUTE
	cArqEDI   := SA2->A2_ARQEDI		//cDirEDI+SA2->A2_ARQEDI
	aLayOut   := __VRestore(cArqLay)
	
	DbSelectArea("SC7")
	DbSetOrder(3)
	If DbSeek(xFilial("SC7")+cCodFor+cLojFor+cNumPed)
		//�������������������������������������Ŀ
		//�Gravacao do cabecalho do layout      �
		//���������������������������������������
		If !EDIGeraEnv(cArqEDI,aLayout,1,cArqLay)
			lGeraLog  := .T.
		EndIf
		
		While !Eof() .And. xFilial("SC7")+cCodFor+cLojFor+cNumPed == SC7->C7_FILIAL+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM
			If lFirst
				If aLayout[4] == 1  //Cabecalho
					If !EDIGeraEnv(cArqEDI,aLayout,2,cArqLay)
						lGeraLog  := .T.
						Exit
					EndIf
				ElseIf aLayout[4] == 2  //Itens
					If !EDIGeraEnv(cArqEDI,aLayout,2,cArqLay)
						lGeraLog  := .T.
						lErroDet  := .T.
						Exit
					EndIf
					If lErroDet
						Exit
					EndIf
				Endif
			EndIf
			DbSkip()
		End
		//�������������������������������������Ŀ
		//�Gravacao do rodape do layout         �
		//���������������������������������������
		If !lGeraLog
			lGeraLog := !EDIGeraEnv(cArqEDI,aLayout,3,cArqLay)
		endif
		
		If !lGeraLog
			Dbsetorder(1)
			IF DBSEEK( XFilial("SC7") + cNumPed )
				While !Eof() .and. SC7->C7_NUM == cNumPed
					reclock("SC7",.F.)
					SC7->C7_ENVIAR	:= "1"
					SC7->C7_FORNEDI	:= if( empty( SC7->C7_FORNEDI )  , SC7->C7_FORNECE , SC7->C7_FORNEDI )
					SC7->C7_LOJAEDI	:= if( empty( SC7->C7_LOJAEDI )   , SC7->C7_LOJA , SC7->C7_LOJAEDI )
					MsUnlock()
					DbSkip()
				End
			ENDIF
			DbSeek( XFilial("SC7") + cNumPed )

			cMsg := if( VAL(SA2->A2_FTPEDI) = 2 , "Arquivo EDI de envio de P.C. criado com sucesso. Ser� enviado para o fornecedor via FTP " , "Arquivo EDI de envio de P.C. criado com sucesso. " )
			T_EDIGrvLog( cMsg  ,cArqLogEnv )
			
			if( VAL(SA2->A2_FTPEDI) >= 2 )		//Se consigo Gerar o arquivo de EDI de PC e A2_FTPEDI >= 2, envio-o para o fornecedor via FTP
				T_EDIGrvLog( "Parametros do FTP = " + _cServ +"."+ STR(_nPort, 4) +"."+ _cUser +"."+ _cPass +"."+ _cDirOri +"."+ _cArqOri +"."+ _cDirDst +"."+ _cArqDst +"."+ _cEmlDst +"."+ _cEmlTit +"."+ _cEmlArq +"."+ _cQuote +"."+ IF(lTela,"S","N") , cArqLogEnv )
				T_DroFtpEnv(_cServ,_nPort,_cUser,_cPass,_cDirOri,_cArqOri,_cDirDst,_cArqDst,_cEmlDst,_cEmlTit,_cEmlArq, _cQuote, lTela )
			Endif
		EndIf
	EndIf
	
	If lGeraLog
		If lTela
			MsgAlert("Foram encontradas algumas inconsist�ncias no processamento."+;
			"Verifique o arquivo de LOG gerado em " + cArqLogEnv+ " no servidor.")
		EnDIF
		T_EDIGrvLog("Foram encontradas algumas inconsist�ncias no processamento."+ "Verifique o arquivo de LOG gerado em "+cArqLogEnv+" no servidor.",cArqLogEnv)
		lRet := .F.
	Endif
Endif
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PedCEDIFec�Autor  �THIAGO HONORATO     � Data �  03/03/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao dos dados de fechamento de Pedido de Compras     ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PedCEDIFech()

Local lRet  := .T.


if  EMPTY(cCodFilFim) .or. cCodFilFim < cCodFilIni
	MsgAlert("O codigo da Filial Final n�o pode ser vazia e deve ser maior que a Filial Inicial.")
	lRet  := .F.
EndIf

If Empty(dDtEmssFim) .or. Dtos(dDtEmssFim) < Dtos(dDtEmssIni)
	MsgAlert("A Data Final n�o pode ser vazia e nem menor que a Data Inicial.")
	lRet  := .F.
EndIf

If lRet .And. Empty(cCodFilFim)
	MsgAlert("Preencher o codigo da Filial Final.")
	lRet  := .F.
EndIf

If lRet .And. Empty(dDtEmssIni)
	MsgAlert("Preencher a Data de Emiss�o Inicial.")
	lRet  := .F.
EndIf

If lRet .And. Empty(dDtEmssFim)
	MsgAlert("Preencher a Data de Emiss�o Final.")
	lRet  := .F.
EndIf

If lRet .And. Empty(cCodForFim)
	MsgAlert("Preencher o c�digo do Fonecedor Final.")
	lRet  := .F.
EndIf

If lRet .And. Empty(cLojForFim)
	MsgAlert("Preencher a loja do Fonecedor Final.")
	lRet  := .F.
EndIf

If lRet .And. Empty(cCodPedFim)
	MsgAlert("Preencher o c�digo do Pedido de Compras Final.")
	lRet  := .F.
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIVldDirC�Autor  �Fernando Machima    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao da selecao do caminho dos arquivos de layout e   ���
���          � envio                                                      ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIVldDirC(cDir)

Local lRet  := .T.

If Empty(cDir)
	MsgAlert("Preencher o caminho do arquivo de configura��o do layout de Pedido de Compras.")
	lRet  := .F.
EndIf
If Empty(cArq)
	MsgAlert("Preencher o caminho do arquivo de envio.")
	lRet  := .F.
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EdiEnvLg �Autor  �Fernando Machima    � Data �  17/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Geracao do arquivo de log para erros na gera��o do arquivo ���
���          � de envioPedidos de compras                                 ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function EdiEnvLg(cTexto,cArqLog)

Local nHandle

If !File(cArqLog)
	nHandle := FCreate(cArqLog)
Else
	nHandle := FOpen(cArqLog,1)
	FSeek(nHandle,0,2)
EndIf

cTexto := dtoc(ddatabase) +" "+ time() +" "+ cTexto + CTRL
fWrite(nHandle,cTexto,Len(cTexto))
FClose(nHandle)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIGeraEnv�Autor  �Fernando Machima    � Data �  17/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera o arquivo para envio: cabecalho, itens e rodape       ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - path e nome do arquivo de envio                     ���
���          �ExpA2 - array com os dados do layout                        ���
���          �ExpN3 - 1=Cabecalho;2=Itens;3=Rodape(generalizacao da funcao���
���          �ExpC4 - path e nome do arquivo de Layout  ���
�������������������������������������������������������������������������͹��
���Uso       � Templates de Drogaria                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIGeraEnv(cArqEDI,aLayout,nIndice,cArqLay)
Local nT, nX     := 0  //Contador do sistema
Local nLinAtu    := 1
Local nLinAnterior  := 0
Local nPosPonto  := 0
Local nTamString := 0
Local nQtdeDecimal := 0
Local nTamExpr   := 0
Local nTamTexto  := 0
Local uConteudo  := ""							   //Conteudo da macro
Local cLinha     := ""							   //Var utilizada para gravar uma linha no TXT
Local cAux       := ""							   //Var auxiliar
Local cValorMacro:= ""							   //Valor da Macro com tratamento de Erro
Local cTxtLog    := ""                             //Texto do log de erro
Local cEspaco    := Chr(13)+Chr(10)
Local cTemp      := ""
Local cTipo      := ""
Local cTipoItem  := IIf(nIndice==1,"Cabe�alho",(IIf(nIndice==2,"Item","Rodap�")))
Local cPicture   := ""
Local lGravaLin  := .F.
Local lCabRod    := nIndice == 1 .Or. nIndice == 3
Local lDataOK    := .T.

If File(cArqEDI)
	nHandle := FOpen(cArqEDI,1)
	FSeek(nHandle,0,2)
EndIf

//����������������������������������������������������Ŀ
//�Posicao da estrutura de layout do arquivo:          �
//�                                                    �
//�1 - Titulo do campo                                 �
//�2 - Linha de impressao                              �
//�3 - Coluna inicial                                  �
//�4 - Tamanho                                         �
//�5 - Coluna final                                    �
//�6 - Tipo(1=Caracter;2=Numerico;3=Data;4=Logico)     �
//�7 - Conteudo do campo                               �
//�8 - Picture                                         �
//�9 - Preenche zeros a esquerda?                      �
//�10 - Deletado?                                      �
//������������������������������������������������������
For nT := 1 to Len(aLayout[nIndice])
	//Ignorar os deletados no layout
	If aLayout[nIndice][nT][Len(aLayout[nIndice][nT])]
		Loop
	EndIf
	
	//�����������������������������������������������������������������������������������������������Ŀ
	//�Tratar pulo de linha para a impressao do cabecalho e do rodape, conforme configuracao do layout�
	//�������������������������������������������������������������������������������������������������
	If nLinAnterior == 0 //Primeira iteracao
		nLinAtu  := 1
	Else
		nLinAtu  := nLinAnterior
	EndIf
	If lCabRod  //Cabecalho ou rodape
		lGravaLin  := .F.
		While aLayout[nIndice][nT][2] > nLinAtu
			nLinAtu++
			If nLinAnterior == 0
				FWrite(nHandle,cEspaco,Len(cEspaco))
			Else
				cLinha  += cEspaco
				lGravaLin  := .T.
			EndIf
		End
		If lGravaLin
			//�����������������������������������������������������������������������������������������������Ŀ
			//�Escreve no arquivo porque o proximo item deve sev impresso em outra linha                      �
			//�������������������������������������������������������������������������������������������������
			FWrite(nHandle,cLinha,Len(cLinha))
			cLinha  := ""
		EndIf
		nLinAnterior  := aLayout[nIndice][nT][2]
	EndIf
	//Executa a macro configurada
	cValorMacro := ExecMacroInServer(aLayout[nIndice][nT][7])
	cTipo       := SubStr(cValorMacro,1,1)
	cValorMacro := SubStr(cValorMacro,2)
	If !EDIVldMacro(cValorMacro,aLayout,nT,nIndice,cArqLay)
		FClose(nHandle)
		Return .F.
	EndIf
	
	//��������������������������������������������������������������������������Ŀ
	//� Tratamento para os casos em que executa uma customizacao e nao grava nada�
	//� no arquivo de envio. ex: soma as NFs para mostrar o total no rodape      �
	//����������������������������������������������������������������������������
	nTamExpr  := aLayout[nIndice][nT][4]  //Tamanho da data informada no layout de configuracao e que deve ir gravada no arquivo de exportacao
	If nTamExpr == 0
		Loop
	EndIf
	//�������������������������������������������������������������������������Ŀ
	//� Guardo seu conteudo para gravacao no arquivo de envio.                  �
	//���������������������������������������������������������������������������
	uConteudo := cValorMacro
	
	//�������������������������������������������������������������������������Ŀ
	//� Gerar a linha considerando o tamanho e a coluna inicial                 �
	//���������������������������������������������������������������������������
	If cTipo == "D"
		//A execucao da macro retorna 8 digitos para a data. Se o layout estiver configurado para 6 deve tratar dois digitos para o ano
		nTamTexto  := Len(AllTrim(uConteudo))  //Tamanho da data retornada pelo comando ExecMacro
		If nTamExpr < nTamTexto
			cAux   := PadR(Substr(uConteudo,1,nTamTexto),nTamTexto)
		Else
			cAux   := PadR(Substr(uConteudo,1,nTamExpr),nTamExpr)
		EndIf
	Else
		cAux   := PadR(Substr(uConteudo,1,nTamExpr),nTamExpr)  //Tratamento para tamanho
	EndIf
	//Tratamento de picture
	If !Empty(aLayout[nIndice][nT][8])
		If cTipo == "N"  //Numero
			If AT(",",aLayout[nIndice][nT][8]) > 0 .Or. AT(".",aLayout[nIndice][nT][8]) > 0
				cTemp := AllTrim(Transform(Val(cAux),aLayout[nIndice][nT][8]))
				cAux  := PADL(cTemp,Len(cAux))
			Else
				//Nao imprime ponto nem virgula para decimais
				If (nPosPonto := AT(".",cAux)) > 0  //Tem decimais
					nTamString   := Len(AllTrim(cAux))
					nQtdeDecimal := nTamString - nPosPonto  //Quantidade de decimais do retorno da macro-execucao
				Else
					nQtdeDecimal := 2
				EndIf
				cTemp  := AllTrim(StrTran(cAux,",",""))
				cTemp  := AllTrim(StrTran(cTemp,".",""))
				cTemp  := PADR(cTemp,Len(cTemp)+nQtdeDecimal,"0")
				cAux   := PADL(cTemp,Len(cAux))
			EndIf
		ElseIf cTipo == "D"  //Data
			cPicture   := aLayout[nIndice][nT][8]
			lDataOK    := FormatDatC(@cAux,cPicture,nTamExpr,nTamTexto)
			If !lDataOK
				cTxtLog  := "Erro na formata��o da data do registro: "
				cTxtLog  += CTRL
				//Mostra todos os itens do registro com erro para facilitar a busca
				For nX := 1 to Len(aLayOut[nIndice])
					//Executar a macro ateh onde ocorreu o erro
					If nX >= nT
						Exit
					EndIf
					cTxtLog  += aLayOut[nIndice][nX][1]  //Descricao no layout
					//Executa a macro para saber que registro ocorreu o erro
					cTxtLog  += Substr(ExecMacroInServer(aLayout[nIndice][nX][7]),2)
					cTxtLog  += CTRL
				Next nX
				cTxtLog  += CTRL
				T_EDIGrvLog(cTxtLog,cArqLogEnv)
				Return(.F.)
			EndIf
		EndIf
	EndIf
	//Se estiver configurado, preenche zeros a esquerda
	If cTipo $ "C|N" .And. aLayout[nIndice][nT][9] == "1"  //Preenche zeros a esquerda = Sim
		cAux   := PadL(AllTrim(cAux),Len(cAux),"0")
	EndIf
	//Tratamento para coluna inicial
	If aLayout[nIndice][nT][3] > 1
		cAux   := PadL(cAux,Len(cAux)+aLayout[nIndice][nT][3]-(Len(cLinha)+1))
	EndIf
	cLinha := Stuff(cLinha,aLayout[nIndice][nT][3],0,cAux)
Next nT

cLinha += Chr(13)+Chr(10)
//�������������������������������������������������������������������������Ŀ
//� Gravo a linha no arquivo de envio.                                      �
//���������������������������������������������������������������������������
If fWrite(nHandle,cLinha,Len(cLinha)) != Len(cLinha)
	cTxtLog  := "Ocorreu um erro na grava��o do arquivo de envio "
	cTxtLog  += Chr(13)+Chr(10)
	cTxtLog  += "Conte�do da linha de erro: "+cLinha
	cTxtLog  += Chr(13)+Chr(10)
	cTxtLog  += "Erro na impress�o do "+cTipoItem
	cTxtLog  += Chr(13)+Chr(10)
	T_EDIGrvLog(cTxtLog,cArqLogEnv)
	FClose(nHandle)
	Return .F.
Endif

If nIndice == 2
	nRegProc++
EndIf

FClose(nHandle)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIVldMacr�Autor  �Fernando Salvatori  � Data �  25/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Processo de validacao da macro-execucao                    ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - retorno da macro-execucao                           ���
���          �ExpA1 - array com os dados do layout                        ���
���          �ExpN1 - iteracao, indica que coluna do layout estah sendo   ���
���          �processada                                                  ���
���          �ExpA2 - array com os dados selecionados para fechamento     ���
���          �ExpN2 - iteracao, indica que empresa de convenio estah sen- ���
���          �do processada                                               ���
���          �ExpN3 - 1=Cabecalho;2=Itens;3=Rodape(generalizacao da funcao���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIVldMacrC(cValorMacro,aLayOut,nT,nIndice,cArqLay)

Local nX
Local lRet    := .T.
Local cMacro  := aLayOut[nIndice][nT][7]
Local cMsg    := ""
Local cTipoItem   := ""

If Lower(SubStr(cValorMacro,1,5)) == "error"
	cTipoItem   := IIf(nIndice==1,"Cabe�alho",(IIf(nIndice==2,"Itens","Rodap�")))
	cMsg := "Existe um problema com a macro configurada na pasta "+cTipoItem+" do arquivo de layout "+cArqLay
	cMsg += Chr(13)+Chr(10)
	cMsg += "Segue descri��o do erro:"
	cMsg += Chr(13)+Chr(10)
	cMsg += SubStr(cValorMacro,10)
	cMsg += Chr(13)+Chr(10)
	cMsg += "Conte�do da macro com problemas no arquivo de layout: "
	cMsg += Chr(13)+Chr(10)
	cMsg += cMacro
	cMsg += Chr(13)+Chr(10)
	cMsg += "Fa�a a corre��o atrav�s do configurador de layout."
	cMsg += Chr(13)+Chr(10)
	cMsg += Chr(13)+Chr(10)
	If nIndice == 1 .Or. nIndice == 3  //Cabecalho e Rodape
		cMsg += "O processo de gera��o do arquivo de envio foi abortado!"
		cMsg += Chr(13)+Chr(10)
	Else   //Itens
		cMsg += "Registro com n�o-conformidade: "
		cMsg += Chr(13)+Chr(10)
		//Mostra todos os itens do registro com erro para facilitar a busca
		For nX := 1 to Len(aLayOut[nIndice])
			//Executar a macro ateh onde ocorreu o erro
			If nX >= nT
				Exit
			EndIf
			cMsg += aLayOut[nIndice][nX][1]  //Descricao no layout
			//Executa a macro para saber que registro ocorreu o erro
			cMsg += Substr(ExecMacroInServer(aLayout[nIndice][nX][7]),2)
			cMsg += Chr(13)+Chr(10)
		Next nX
		cMsg += Chr(13)+Chr(10)
	EndIf
	cMsg += Chr(13)+Chr(10)
	T_EDIGrvLog(cMsg,cArqLogEnv)
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FormatDatC�Autor  �Fernando Machima    � Data �  06/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Converte a data gravada no arquivo em formato caracter con-���
���          � rando a picture do layout de configuracao                  ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FormatDatC(cData,cPicture,nTamExpr,nTamTexto)

Local cDia   := ""
Local cMes   := ""
Local cAno   := ""
Local cTemp  := ""
Local cTempPict := ""
Local nX
Local nPosDia  := 0
Local nPosMes  := 0
Local nPosAno  := 0
Local nDigiAno := 0
Local nPosTemp := 0
Local nPosSeparador  := 0
Local lRet     := .T.
Local lTemSeparador  := .T.
Local aSeparador := {}

//Assumindo que o comando ExecMacro sempre retorna a data no formato AAAAMMDD
cTemp  := AllTrim(cData)
cDia   := Substr(cData,Len(cTemp)-1,2)
cMes   := Substr(cData,Len(cTemp)-3,2)

cTempPict := AllTrim(UPPER(cPicture))
nPosDia  := AT("DD",cTempPict)
nPosMes  := AT("MM",cTempPict)
nPosAno  := AT("AA",cTempPict)
nDigiAno := 0
nPosTemp := nPosAno
//Verifica se o ano estah configurado para 2 ou 4 digitos no layout de configuracao
For nX := 1 to Len(cTempPict)
	If nPosTemp > 0
		cTempPict  := Stuff(cTempPict,nPosTemp,2,"  ")
		nDigiAno += 2
	Else
		Exit
	EndIf
	nPosTemp  := AT("AA",cTempPict)
Next nX
//Verifica a posicao dos provaveis separadores("/",".","-","|") de datas para inserir posteriormente na string da data
//O array aSeparador armazena o separador e a posicao deste na picture
cTempPict := AllTrim(UPPER(cPicture))
lTemSeparador  := .T.
While lTemSeparador
	lTemSeparador  := .F.
	nPosSeparador  := AT("/",cTempPict)
	If nPosSeparador > 0
		Aadd(aSeparador,{"/",nPosSeparador})
		cTempPict  := Stuff(cTempPict,nPosSeparador,1," ")
		lTemSeparador  := .T.
	EndIf
	nPosSeparador  := AT("-",cTempPict)
	If nPosSeparador > 0
		Aadd(aSeparador,{"-",nPosSeparador})
		cTempPict  := Stuff(cTempPict,nPosSeparador,1," ")
		lTemSeparador  := .T.
	EndIf
	nPosSeparador  := AT(".",cTempPict)
	If nPosSeparador > 0
		Aadd(aSeparador,{".",nPosSeparador})
		cTempPict  := Stuff(cTempPict,nPosSeparador,1," ")
		lTemSeparador  := .T.
	EndIf
	nPosSeparador  := AT("|",cTempPict)
	If nPosSeparador > 0
		Aadd(aSeparador,{"|",nPosSeparador})
		cTempPict  := Stuff(cTempPict,nPosSeparador,1," ")
		lTemSeparador  := .T.
	EndIf
End
//Monta a string da data conforme a configuracao do layout
If nPosDia > 0 .And. nPosMes > 0 .And. nPosAno > 0
	If nDigiAno == 2
		cAno  := Substr(cData,Len(cTemp)-5,nDigiAno)
	ElseIf nDigiAno == 4
		cAno  := Substr(cData,1,nDigiAno)
	EndIf
	cData  := Space(nTamExpr)
	cData  := Stuff(cData,nPosDia,2,cDia)
	cData  := Stuff(cData,nPosMes,2,cMes)
	cData  := Stuff(cData,nPosAno,nDigiAno,cAno)
	//Insere os separadores na string conforme a picture
	For nX := 1 to Len(aSeparador)
		cData  := Stuff(cData,aSeparador[nX][2],1,aSeparador[nX][1])
	Next nX
Else
	lRet  := .F.
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MontArrayP�Autor  �Fernando Machima    � Data �  13/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicializa o array aDadosPedC                              ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontArrayP(aCpos)

Local aC   := {}
Local nX

aC := Array(1,Len(aCpos)+1)
aC[1][1] := -1
SX3->(DBSetOrder(2))
For nX := 2 to Len(aCpos)
	If SX3->(DbSeek(aCpos[nX]))
		aC[Len(aC)][nX]   := CriaVar(aCpos[nX])
	Else
		aC[Len(aC)][nX]   := &(aCpos[nX])
	Endif
Next nX
aC[Len(aC)][Len(aC[1])]:=.F.

Return aC

/*���������������������������������������������������������������������������
���Programa  �SelecPedC �Autor  �Fernando Machima    � Data �  13/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento de selecao dos Pedidos de Compras				  ���
���          � Ao marcar um Pedido de Compras, deve desmarcar os demais.  ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
���������������������������������������������������������������������������*/
Static Function SelecPedC()
Local nX

aDadosPedC[oLBPedComp:nAt,1] := aDadosPedC[oLBPedComp:nAT,1] * -1
If aDadosPedC[oLBPedComp:nAt,1] == 1  //Marcado
	For nX := 1 to Len(aDadosPedC)
		If nX != oLBPedComp:nAt
			aDadosPedC[nX,1] := -1  //Desmarcar
		EndIf
	Next nX
	oLBPedComp:Refresh()
EndIf

Return .T.

/*���������������������������������������������������������������������������
���Programa  �DROENVAU  �Autor  �Geronimo B. Alves   � Data �  11/04/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processamento AUTOMATICO do EDI - Geracao do arquivo de    ���
���          � envio do pc para os Fornecedores                           ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/
Template Function DROENVAU(aParam)

Private lTela		:= .f.		// Mostra informa��es na Tela (Quando execudada atravez de JOB eh .F.
Private aDadosPedC  := {}
Private cArq        := ""
//Private cArq        := GetSrvProfString("STARTPATH","")      //Path onde serah gravado o arquivo de envio
Private cArqLogEnv	:= cArq+"pcenvioedi.log"  //Grava o arquivo de log de erro no mesmo diretorio do arquivo de envio
Private cArqLogRet	:= cArq+"pcretornoedi.log"
Private cDir		:= ""
Private cDirEDI		:= ""

Private cNumPed := aParam[1]   // Quando executado via JOB eh sobre este numero de PC que sera alimentado o array aDadosPed e gerado o arquivo texto
Private cEMP := aParam[2]
Private cFil := aParam[3]
wfprepenv(aParam[2],aParam[3])

T_PedEDIPr(cDir,cDirEDI,lTela,cNumPed,.f.)

Return