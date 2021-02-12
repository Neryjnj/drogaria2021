#include "APWizard.ch"
#include "protheus.ch" 
 
//Extras
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
#xcommand DEFAULT <uVar1> := <uVal1> ;
      [, <uVarN> := <uValN> ] => ;
    <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]

//Pula Linha
#Define CTRL Chr(13)+Chr(10)

//DEFINE's do array aLayout
#DEFINE __TITULO    1
#DEFINE __LINHA     2
#DEFINE __COLINI    3
#DEFINE __TAMANHO   4
#DEFINE __COLFIM    5
#DEFINE __TIPO      6
#DEFINE __CONTEUDO  7
#DEFINE __PICTURE   8
#DEFINE __DELETADO  9

//DEFINE's do array aDadosConv
#DEFINE __CODCONV   1        
#DEFINE __LOJCONV   2        
#DEFINE __NOMECONV  3        
#DEFINE __MATRICULA 4        
#DEFINE __OPERACAO  5        

//DEFINE's do array aDadosPrec
#DEFINE __CODPROD   1        
#DEFINE __DESCPRO   2        
#DEFINE __VLRPRO    3        
#DEFINE __DATA      4        
#DEFINE __OPERACAO  5        


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DROIMPPRE ºAutor  ³Thiago Honorato	 º Data ³  11/03/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento do EDI - Recebimento de lista de Precos dos   º±±
±±º		     ³Produtos					   								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROIMPPRE
Local oWizard, oPanel
Local oGrp1,oRad1,oGet1
Local oGrp2,oGet2
//Local oGetCodEmpresa, oGetLojEmpresa
Local oGetCodFor, oGetLojFor, oGetNomFor
Local oGetRegProc
Local oGetEmp
Local oGetArqEDI
Local oLBBx
Local nArq   := 0
Local aDir   := {}
Local aCabBx := {}
Local aTamBx := {}
Local cTxt1  := ""
Local cTxt2  := ""
Local cExt   := "REC"  //Extensao do arquivo de configuracao para importacao dos dados do produto
Local cArqRecebe  := Space(80)
Local cText :=	'Este programa irá processar o arquivo de recebimento contendo os ' + ; 
                'dados dos produtos de acordo com a configuração pré-definida  ' + ; 
	  			'no configurador do EDI.' + CTRL + CTRL + CTRL + ;
	  			'Para continuar clique em Avançar.'
Local cStartPath := Upper(GetSrvProfString("STARTPATH",""))
Local bValid

// variaveis que serao utilizadas para a criacao do primeiro Panel

Local cSeekSA2   := '"' + xFilial("SA2") + '"'
Local cWhileSA2  := "!EOF() .And. A2_FILIAL == " + cSeekSA2

Local cSeekAIA  := '"' + xFilial("AIA") + '"'
Local cWhileAIA := "!EOF() .And. AIA_FILIAL == " + cSeekAIA 

Local aRet1 := LocxGrid("SA2",cWhileSA2,'A2_FABRICA=="S"',.T.,".F.",cSeekSA2,2,{"A2_COD","A2_LOJA","A2_NOME"},)  //Forncedores
Local aCab1 := AClone(aRet1[3])
Local aLin1 := AClone(aRet1[5])
Local aTam1 := AClone(aRet1[4])
Local aCpo1 := AClone(aRet1[1])

Local aRet5 := LocxGrid("AIA",cWhileAIA,,.T.,".F.",cSeekAIA,1,{"AIA_CODTAB","AIA_DESCRI"},)  //Tabela de Precos
Local aCab5 := AClone(aRet5[3])
Local aLin5 := AClone(aRet5[5])
Local aTam5 := AClone(aRet5[4])
Local aCpo5 := AClone(aRet5[1])         

Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)

Private cCodFor  := Space(TamSX3("A2_COD")[1])
Private cLojFor  := Space(TamSX3("A2_LOJA")[1])
Private cNomeFor := Space(TamSX3("A2_NOME")[1])
//Path do arquivo de configuracao de lay-out de importacao
Private cDirLayout  := cStartPath
//Registros processados na geracao do arquivo de envio. Mostrado no resultado do processamento(quinto panel)
Private nQtdeRegs   := 0   //Quantidade de conveniados atualizados com a importacao
Private cNomeEmp    := ""
//Private aDadosConv  := {}  //Dados dos conveniados a serem atualizados, mostrado no panel 4
Private aDadosPrec  := {}  //Dados dos produtos a serem atualizados, mostrado no panel 4
Private aCampos     := {}
Private lNovoConv   := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aDadosConv       ³
//³------------------------------      ³
//³1-Codigo do conveniado              ³
//³2-Loja do conveniado                ³
//³3-Nome do conveniado                ³
//³4-Matricula do conveniado           ³
//³5-Tipo de operacao:(A)lteracao,(B)lo³
//³queio,(D)esligamento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aDadosPrec       ³
//³------------------------------      ³
//³1-Codigo do produto                 ³
//³2-Descricao do produto			   ³
//³3-Valor do Produto	               ³
//³4-Data							   ³
//³5-Tipo de operacao:(A)lteracao,(B)lo³
//³queio,(D)esligamento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

PrecEDIDir(cDirLayout,cExt,@aDir)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard TITLE 'EDI Drogaria - Processamento do arquivo para atualização dos dados dos produtos' ;
HEADER 'Wizard do processamento do arquivo de produtos:' ; 
MESSAGE 'Processamento automático.' TEXT cText ;
NEXT {|| .T.} FINISH {|| .T.} PANEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Segundo Panel - Pergunte do fechamento     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Dados para processamento de produtos' ;
MESSAGE 'Informe o Fornecedor e a sua Tabela de Preços a ser processada.' ;
BACK {|| .T. } NEXT {|| ValidDados() .And. DROSelTabP(aLin5)} FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(2)

TGroup():New(040,005,070,190," Fornecedor ",,,,.T.)
TGroup():New(075,005,160,190," Tabela de Precos ",,,,.T.)

//Box Fornecedor
oGet3 := TGet():New(15,08, bSETGET(cCodFor),oPanel,25,10,"@!",,,,,,,.T.,,,,,.T.,,,,"L51",)
oGet4 := TGet():New(15,040, bSETGET(cLojFor),oPanel,05,10,"@!",{|| cNomeFor:=Posicione("SA2",1,xFilial("SA2")+cCodFor+cLojFor,"A2_NOME"),oGet5:Refresh(),DRORunLbx5(@oLbx05,cCodFor+cLojFor,@aLin5)},,,,,,.T.,,,,,.T.,,,,,)
oGet5 := TGet():New(15,056, bSETGET(cNomeFor),oPanel,122,10,"@!",,,,,,,.T.,,,,,.T.,,.T.,,) 

//Box - Tabela de Precos
oLbx05:= TwBrowse():New(050,08,170,065,,aCab5,aTam5,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //a. 60 l. 170
oLbx05:lColDrag	:= .T.
oLbx05:nFreeze	:= 1
oLbx05:SetArray(aLin5)
oLbx05:bLine		:= LocxBLin('oLbx05',aCpo5,.T.)
oLbx05:bLDblClick	:={ || ChgMarkLb(oLbx05,aLin5,{|| .T. },.T.),DRODesmarcAll(@aLin5) }



/*
bValid   := {|| ExistCpo("SA2",cCodFor) .And. A2_FABRICA != "S"}
TSay():New(15,05,{|| "Cod. Fornecedor"},oPanel,,,,,,.T.)
oGetCodFor := TGet():New(15,47,bSETGET(cCodFor),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L51",)

bValid   := {|| ExistCpo("SA2",cCodFor+cLojFor) .And. A2_FABRICA != "S"}
TSay():New(15,100,{|| "Loja Fornecedor"},oPanel,,,,,,.T.)
oGetLojFor := TGet():New(15,140,bSETGET(cLojFor),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

cNomeFor := Posicione("SA2",1,xFilial("SA2")+cCodFor+cLojFor,"A2_NOME")
TSay():New(30,05,{|| "Nome do fornecedor"},oPanel,,,,,,.T.)
oGetNomFor := TGet():New(30,70,bSETGET(cNomeFor),oPanel,60,10,,,,,,,,.T.,,,,,,,.F.,,,)
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Terceiro Panel - Arquivo de recebimento            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Arquivos de layout e de recebimento';
MESSAGE 'Informe a pasta onde está o arquivo de layout de importação e o caminho e o nome do arquivo de recebimento.' ;
BACK {|| .T. } NEXT {|| IIf(ValidDir(cDirLayout,cArqRecebe),PrecEDIVld(.T.,cDirLayout,cArqRecebe),.F.)} FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(3)

TSay():New(25,08,{|| "Escolha o caminho do arquivo de lay-out:"},oPanel,,,,,,.T.)
oGet1 := TGet():New(35,08, bSETGET(cDirLayout),oPanel,110,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(35,120,14,{|| cDirLayout := cGetFile("Escolha o diretorio|*.*|","Escolha o caminho do arquivo de configuração.",0,"SERVIDOR"+cDirLayout,.T.,GETF_ONLYSERVER+GETF_RETDIRECTORY), PrecEDIDir(cDirLayout,cExt,@aDir)},oPanel,)

TSay():New(55,08,{|| "Escolha o arquivo de recebimento:"},oPanel,,,,,,.T.)
oGet2 := TGet():New(65,08, bSETGET(cArqRecebe),oPanel,145,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(65,155,14, {|| cArqRecebe := cGetFile("Todos Arquivos |*.*|","Escolha o arquivo de recebimento.",0,,.T.,GETF_ONLYSERVER), VldArqReceb(@cArqRecebe) },oPanel,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quarto Panel - Visualizacao dos registros a serem atualizados³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo os conveniados que serão atualizados. Para efetuar as modificações na base de dados, clique em Avançar.' ;
BACK {|| .T. } NEXT {|| ConfProc()} FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(4)

aCabBx	:= {"Cód. Produto", "Desc. Produto", "Vlr. Produto", "Data", "Operação" }
aTamBx	:= {30,20,80,35,20}
AAdd(aDadosPrec,{"","","","",""})
oLBBx		:=TwBrowse():New(000,003,000,000,,aCabBx,aTamBx,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBBx:SetArray(aDadosPrec)
oLBBx:bLine 	:= { ||{aDadosPrec[oLBBx:nAT][__CODPROD], aDadosPrec[oLBBx:nAT][__DESCPRO], ;
                        aDadosPrec[oLBBx:nAT][__VLRPRO], aDadosPrec[oLBBx:nAT][__DATA], ;
                        aDadosPrec[oLBBx:nAT][__OPERACAO]}}
                        
oLBBx:lHScroll  :=.T.
oLBBx:nHeight	:=270
oLBBx:nWidth	:=550
                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quinto Panel - Status do Processamento ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo o resultado do Processamento' ;
BACK {|| .T. } NEXT {|| .T. } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(5)

TSay():New(15,05,{|| "Fornecedores:" },oPanel,,,,,,.T.)
oGetEmp := TGet():New(15,70, bSETGET(cNomeEmp),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)

TSay():New(35,05,{|| "Produtos atualizados atualizados:" },oPanel,,,,,,.T.)
oGetRegProc := TGet():New(35,70, bSETGET(nQtdeRegs),oPanel,60,10,,,,,,,,.T.,,,,,,,.T.,,,)

ACTIVATE WIZARD oWizard CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrecEDIDirºAutor  ³Carlos A. Gomes Jr. º Data ³  11/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica validade do Path e refaz vetor aDir.              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrecEDIDir(cDirLayout,cExt,aDir)
Local   aTMP := {}

aDir := {}
If Empty(cDirLayout)
	MsgAlert("Caminho inválido!")
	Return .F.
EndIf
aTMP := Directory(cDirLayout+"*."+cExt)
AEval(aTMP,{|x,y| AAdd(aDir, x[1]) })

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrecEDIVld ºAutor  ³Carlos A. Gomes Jr. º Data ³  14/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos dados e chamada do processamento de º±±
±±º          ³ importacao dos dados dos precos		                       º±±
±±º          ³ Parametros:                                                 º±±
±±º          ³ lTela = Exibir mensagens em tela .T. no server .F.          º±±
±±º          ³ cDirLayout = Pasta do arquivo de configuracao do layout     º±±
±±º          ³ ArqRecebe = Nome do arquivo de recebimento                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrecEDIVld(lTela,cDirLayout,cArqRecebe)

Local lRet      := .T.

DEFAULT lTela      := .F.
DEFAULT cDirLayout := ""
DEFAULT cArqRecebe := ""

If Empty(cDirLayout)
    If lTela
    	MsgAlert("Digite o caminho do arquivo de Lay-Out de importação.")
    	Return .F.
    Else
    	QOut("Digite o caminho do arquivo de Lay-Out de importação.")
    	Return .F.
    EndIf
EndIF

If Empty(cArqRecebe)
    If lTela
    	MsgAlert("Selecione o arquivo de recebimento.")
    	Return .F.
    Else
    	QOut("Selecione o arquivo de recebimento.")
    	Return .F.
    EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MsgYesNo("Confirma o processamento do arquivo de recebimento para a atualização da Tabela de Preços do "+;
            "Fornecedor "+CTRL+AllTrim(cNomeFor)+"?")
   Processa( { |lEnd| lRet  := PrecEDIProc(cDirLayout,cArqRecebe) }, "Processando...",, .F.)  
Else
   Return .F.   
EndIf   

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrecEDIProcºAutor  ³Fernando Machima    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processamento do EDI-Atualizacao dos dados dos produtos	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrecEDIProc(cDirLayout,cArqRecebe)

Local nHandle   
Local nRecno	:= 0
Local lRet      := .T.
Local lGeraLog  := .F.
Local cArqLay   := ""
Local cStartPath := Upper(GetSrvProfString("STARTPATH",""))
Local cArqLog   := cStartPath+"LogIMPORT.log"
Local cTxtLog   := ""
Local cLinha    := ""
//Local cMatricula:= ""
Local cCodPro:= ""
Local cNomeConv := ""
Local cStatus   := ""
Local cOperacao := ""
Local aLayOut   := {}
Local uConteudo 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento da empresa de convenio  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA2")
DbSetOrder(1)
If !DbSeek(xFilial("SA2")+cCodFor+cLojFor)
   MsgAlert("Fornecedor não encontrado.")
   Return .F.   
EndIf

If Empty(SA1->A1_LAYIMP)
   MsgAlert("Arquivo de configuração do layout de importação não preenchido! Verificar o campo Layout  .")
   Return .F.
EndIf

cArqLay := cDirLayout+SA1->A1_LAYIMP

If !File(cArqLay)
   MsgAlert("Arquivo de configuração de layout não encontrado! Verificar o caminho selecionado e o nome do arquivo.")
   Return .F.
EndIf

aLayOut := __VRestore(cArqLay)
If Len(aLayOut) != 4
   MsgAlert("Arquivo de configuração de layout inválido! Verificar a estrutura do arquivo através do configurador EDI.")
   Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir, excluir o arquivo de log para nova geracao caso haja erros de configuracao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cArqLog)
	FErase(cArqLog)
EndIf
                          	
If File(cArqRecebe)
   nHandle := FOpen(cArqRecebe,1)
   FSeek(nHandle,0,2)
   If nHandle = -1
      MsgAlert("Erro na abertura do arquivo de recebimento "+cArqRecebe)   
      Return .F.
   EndIf
EndIf

lNovoConv  := .F.
aCampos    := {}
//Exclui a linha em branco 
If Len(aDadosConv) == 1 .And. Empty(aDadosConv[1][1])
   ADel(aDadosConv,1)
   ASize(aDadosConv, Len(aDadosConv)-1 )
Else
   aDadosConv  := {}      
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ler o arquivo de recebimento     ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FUSE(cArqRecebe)
FT_FGOTOP()

While !FT_FEOF()
	cLinha:= FT_FREADLN()

	++nRecno	
	
	If Empty(cLinha)
		FT_FSKIP()
		Loop
	EndIf
	
	//cMatricula  := ""
	cCodPro := ""
    //EDILeReceb(cLinha,aLayout,"SA1->A1_MATRICU",@cMatricula)
    EDILeReceb(cLinha,aLayout,"SB1->B1_COD",@cCodPro)
    //If Empty(cMatricula)
    If Empty(cCodPro)
       cTxtLog  := "O arquivo de configuração do layout não possui o campo de Codigo do Produto ou o nome "
       cTxtLog  += "do campo está incorreto(SB1->B1_COD) no layout. Este campo é obrigatório para a identificação "
       cTxtLog  += "do produto!"+CTRL
       EDIGrvLog(cTxtLog)              
       lGeraLog  := .T.               
       lRet      := .F.                
	   FT_FSKIP()
	   Loop       
    EndIf
    
	cStatus  := ""
    EDILeReceb(cLinha,aLayout,"STATUS",@cStatus)
    If Len(cStatus) == 0
       cStatus  := "A"  //Valor padrao caso nao haja a coluna de Status no arquivo de recebimento
    ElseIf !(cStatus $ "ABD")
       cTxtLog  := "O conteúdo Status do conveniado de matrícula "+AllTrim(cMatricula)+" está incorreto. Este campo é utilizado para "
       cTxtLog  += "a identificação da operação com o registro do conveniado (A-Ativo;B-Bloqueado;D-Desligamento da empresa)!"+CTRL       
       EDIGrvLog(cTxtLog)                     
       lRet      := .F.         
       lGeraLog  := .T.
	   FT_FSKIP()
	   Loop              
    EndIf
    
    cNomeConv := ""
    EDILeReceb(cLinha,aLayout,"SA1->A1_NOME|SA1->A1_NREDUZ",@cNomeConv)
	
	//Posiciona no conveniado
	DbSelectArea("SA1")
	//DbSetOrder(9)
	DbOrderNickName("SA1DRO2")//indice criado p/ o Template de Drogaria
	If DbSeek(xFilial("SA1")+cCodEmpresa+cLojEmpresa+cMatricula)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Posicionar nos registros dos arquivos do CRD(M*) do conveniado corrente³ 
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
       //Cartao
	   MA6->(DbSetOrder(2))
	   MA6->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   
       //Complemento       
	   MA7->(DbSetOrder(1))
	   MA7->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   
       //Referencia de trabalho
	   MA8->(DbSetOrder(1))
	   MA8->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   
       //Referencia de cartoes
	   MA9->(DbSetOrder(1))
	   MA9->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   
       //Referencia bancaria
	   MAA->(DbSetOrder(1))
	   MAA->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   
       //Referencia pessoal
	   MAB->(DbSetOrder(1))
	   MAB->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   
       //Dependentes
	   MAC->(DbSetOrder(1))
	   MAC->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   
       //Documentos entregues
	   MAE->(DbSetOrder(1))
	   MAE->(DbSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA))	   	   
		
	   //Atualiza os dados do conveniado
	   uConteudo    := NIL
       AAdd(aCampos,{SA1->A1_COD,SA1->A1_LOJA,{},SA1->A1_MATRICU,SA1->A1_NOME,cStatus})
       cOperacao  := IIf(cStatus=="B","Bloqueio",IIf(cStatus=="D","Desligamento","Alteração"))
       AAdd(aDadosConv,{SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,SA1->A1_MATRICU,cOperacao})       

       If !EDILeReceb(cLinha,aLayout,"",uConteudo,cArqLay)   	   
          lGeraLog  := .T.          
          lRet      := .F.          
          Exit       
       EndIf
	Else
	   If cStatus == "A"  //Conveniado novo                                                
	      lNovoConv  := .T.
          AAdd(aCampos,{"xxxxxx","xx",{},cMatricula,cNomeConv,cStatus})
	      AAdd(aDadosConv,{"xxxxxx","xx",cNomeConv,cMatricula,"Inclusão"})          
          If !EDILeReceb(cLinha,aLayout,"",uConteudo,cArqLay)   	   
             lGeraLog  := .T.          
             lRet      := .F.             
             Exit       
          EndIf	   
       Else  //Bloqueio ou Desligamento
          cOperacao  := IIf(cStatus=="D","Desligamento","Bloqueio")
          cTxtLog    := "O conveniado de matrícula "+AllTrim(cMatricula)+" não foi encontrado na base de dados para "
          cTxtLog    += "efetuar o "+cOperacao+CTRL
          EDIGrvLog(cTxtLog)
          lGeraLog   := .T.                    
          lRet       := .F.
       EndIf   
	EndIf
	
	FT_FSKIP()
End 

FT_FUSE()
//Fecha o arquivo de recebimento
FClose(nHandle)   

If lRet
   If Len(aDadosConv) > 0
      aSort(aDadosConv,,,{|x,y| x[4]<y[4]})
   Else
      MsgAlert("Não foi processado nenhum registro do arquivo de recebimento "+cArqRecebe+" da empresa de convênio "+;
                AllTrim(cNomeEmp)+"."+CTRL+" Verifique o conteúdo do arquivo e o layout de configuração.")
      lRet  := .F.   
   EndIf
EndIf   

If lGeraLog
   lRet  := .F.
   MsgAlert("Foram encontradas algumas inconsistências no processamento."+;
            "Verifique o arquivo de LOG gerado em "+cStartPath+"LogIMPORT.log no servidor.")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidDadosºAutor  ³Thiago Honorato     º Data ³  14/03/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao dos dados                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidDados()

Local lRet  := .T.

If Empty(cCodFor)
   MsgAlert("Preencher o codigo do Fornecedor.")
   lRet  := .F.
EndIf

If lRet .And. Empty(cLojFor)
   MsgAlert("Preencher a Loja do Fornecedor.")
   lRet  := .F.
EndIf  

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidDir  ºAutor  ³Fernando Machima    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da selecao do caminho dos arquivos de layout e   º±±
±±º          ³ recebimento                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidDir(cDirLayout,cArqRecebe)

Local lRet  := .T.

If Empty(cDirLayout)
   MsgAlert("Selecionar o caminho do arquivo de configuração do layout de importação.")
   lRet  := .F.
EndIf
If lRet .And. Empty(cArqRecebe)
   MsgAlert("Selecionar o arquivo de recebimento.")     
   lRet  := .F.   
EndIf

If lRet
   If !File(cArqRecebe)
      MsgAlert("O arquivo de recebimento selecionado não existe.")
      lRet  := .F.
   EndIf
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDIGrvLog ºAutor  ³Fernando Machima    º Data ³  17/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao do arquivo de log para erros de configuracao para  º±±
±±º          ³ atualizacao de produtos                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EDIGrvLog(cTexto)

Local cStartPath := Upper(GetSrvProfString("STARTPATH",""))
Local cArqLog  := cStartPath+"LogIMPORT.log"
Local nHandle 

If !File(cArqLog)                     
   nHandle := FCreate(cArqLog)
Else
	nHandle := FOpen(cArqLog,1)
	FSeek(nHandle,0,2)
EndIf

fWrite(nHandle,cTexto,Len(cTexto))          
FClose(nHandle)    

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDILeRecebºAutor  ³Fernando Machima    º Data ³  17/11/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Le o arquivo de recebimento: cabecalho, itens e rodape     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - linha do arquivo texto                              º±±
±±º          ³ExpA1 - array com os dados do layout de configuracao        º±±
±±º          ³ExpC2 - campo onde deve ser gravado ou campo que deseja sa- º±±
±±º          ³ber o conteudo                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates de Drogaria                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EDILeReceb(cLinha,aLayout,cCampo,uConteudo,cArqLay)

Local nX
Local nColInicial := 0
Local nTamanho    := 0
Local nPosAlias   := 0
Local nTamExpr    := 0 
Local nValorExp   := 0
Local lRet        := .T.
Local lDataOK     := .T.
Local lGeraLog    := .F.
Local cNomeCampo  := ""
Local cAliasCpo   := ""
Local cTitulo     := ""
Local cTipo       := ""
Local cPicture    := ""
Local cTxtLog     := "" 
Local cTemp       := ""
Local dData       

DEFAULT cArqLay   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao da estrutura de layout do arquivo(aLayout): ³
//³                                                    ³
//³1 - Titulo do campo                                 ³
//³2 - Linha de impressao                              ³
//³3 - Coluna inicial                                  ³
//³4 - Tamanho                                         ³
//³5 - Coluna final                                    ³
//³6 - Tipo(1=Caracter;2=Numerico;3=Data;4=Logico)     ³
//³7 - Conteudo do campo                               ³
//³8 - Picture                                         ³
//³9 - Deletado?                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aLayout[2])
   //Ignorar os deletados no layout
   If aLayout[2][nX][Len(aLayout[2][nX])]
      Loop
   EndIf
   
   nColInicial := aLayout[2][nX][__COLINI]
   nTamanho    := aLayout[2][nX][__TAMANHO]                     
   If !Empty(cCampo)                                         
      //Deve retornar o conteudo de um campo com base no arquivo de configuracao   
      If AllTrim(aLayout[2][nX][__CONTEUDO]) $ cCampo 
        uConteudo   := AllTrim(Substr(cLinha,nColInicial,nTamanho))
        uConteudo   := PADR(uConteudo,nTamanho)  //Alinha a esquerda(espacos em branco a direita)
        Exit
      EndIf  
   Else
      //Le o conteudo de um campo com base no arquivo de configuracao      
                       //Campo para gravacao         //Conteudo do arquivo texto
      uConteudo  := AllTrim(Substr(cLinha,nColInicial,nTamanho))
      uConteudo  := PADR(uConteudo,nTamanho)  
      cNomeCampo := aLayout[2][nX][__CONTEUDO]
      cTitulo    := AllTrim(aLayout[2][nX][__TITULO])
      cTipo      := aLayout[2][nX][__TIPO]      
      cPicture   := AllTrim(aLayout[2][nX][__PICTURE])
      //Delimitador na coluna Titulo eh uma palavra reservada       
      If AllTrim(Upper(cTitulo)) == "DELIMITADOR"
         Loop
      EndIf                     
      //Status na coluna Conteudo eh uma palavra reservada 
      If AllTrim(Upper(cNomeCampo)) == "STATUS"  
         Loop
      EndIf            
      If cTipo == "2"  //Numero
         If Empty(cPicture)
            cTxtLog  := "Preencher a picture de formatação de Valor no layout de configuração "+cArqLay
            cTxtLog  += CTRL
            EDIGrvLog(cTxtLog)              
            Return(.F.)         
         Else      
            lValorOK    := FormatValor(uConteudo,cPicture,@nValorExp)
            If lValorOK
               uConteudo  := nValorExp
            Else 
               Return(.F.)
            EndIf         
         EndIf
      ElseIf cTipo == "3"  //Data
         dData      := Ctod("  /  /    ")
         If Empty(cPicture)
            cTxtLog  := "Preencher a picture de formatação de Data para o layout de configuração "+cArqLay
            cTxtLog  += CTRL
            EDIGrvLog(cTxtLog)              
            lGeraLog  := .T.
            Return(.F.)         
         Else
            lDataOK    := FormatData(uConteudo,cPicture,@dData)
         EndIf   
         If lDataOK
            uConteudo  := dData
         Else 
            cTxtLog  := "Erro na formatação da data do registro "+cLinha
            cTxtLog  += CTRL
            EDIGrvLog(cTxtLog)              
            Return(.F.)
         EndIf
      EndIf
      cAliasCpo  := Substr(cNomeCampo,1,3)
      nPosAlias  := aScan(aCampos[Len(aCampos)][3],{|x| x[1]==cAliasCpo})
      //Armazena o nome do campo e o conteudo que deve gravar por alias      
      If nPosAlias == 0
         If aCampos[Len(aCampos)][1] == "xxxxxx"  //Novo conveniado
            AAdd(aCampos[Len(aCampos)][3],{cAliasCpo,0})         
         Else
            AAdd(aCampos[Len(aCampos)][3],{cAliasCpo,(cAliasCpo)->(Recno())})
         EndIf   
         AAdd(aCampos[Len(aCampos)][3][Len(aCampos[Len(aCampos)][3])],{cNomeCampo,uConteudo})               
      Else
         AAdd(aCampos[Len(aCampos)][3][nPosAlias],{cNomeCampo,uConteudo})               
      EndIf   
   EndIf   
Next nX

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldArqReceºAutor  ³Fernando Machima    º Data ³  26/11/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o arquivo de recebimento                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - path e nome do arquivo de recebimento selecionado   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldArqReceb(cArqRecebe)

Local lRet  := .T.
Local nHandle

If !File(cArqRecebe)                     
   MsgAlert("Arquivo não encontrado!")
   lRet  := .F.
Else
   //Verifica se não foi selecionada uma pasta
   nHandle := FOpen(cArqRecebe,1)
   FSeek(nHandle,0,2)
   If nHandle == -1
      MsgAlert("Arquivo inválido.")
      lRet  := .F.
      cArqRecebe  := Space(80)
   EndIf
   FClose(nHandle)   
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConfProc  ºAutor  ³Fernando Machima    º Data ³  29/11/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma o processamento de atualizacao dos precos dos     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConfProc()

Local lRet      := .T.
Local lIncluir  := .F.
Local lFirst    := .T.
Local lCriaConv := .F.  //Controla se deve criar um novo conveniado no SA1 e nos demais arquivos relacionados
Local lFound    := .F.
Local lBloqueado:= .F.
Local lTemCartao:= .F.
Local lGeraLog  := .F.
Local lUsaCodCli:= .F.  //Controla se inseriu novo cliente no SA1 para incrementar o sequencial
Local nX, nY, nZ
Local nRecnoRec
Local nTamCliente:= TamSX3("A1_COD")[1]   
Local nNovoCodigo
Local cAliasGrv := ""
Local cCampoGrv := ""
Local cCodConv  := ""
Local cLojConv  := ""
Local cPrefixo  := ""
Local cProxNumSA1:= Space(nTamCliente)
Local cMatricula:= ""
Local cNomeConv := ""
Local cStatus   := ""
Local cTxtLog   := ""
Local cUltCodigo:= ""
Local cStartPath := Upper(GetSrvProfString("STARTPATH",""))
Local uContCpo  
Local aAreaSA1  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao da estrutura do array aCampos:              ³
//³                                                    ³
//³1,1 - Cod. cliente                                  ³
//³1,2 - Loja cliente                                  ³
//³1,3,1,1 - Alias                                     ³
//³1,3,1,2 - Alias                                     ³
//³1,3,1,3,1 - Campo a modificar                       ³
//³1,3,1,3,2 - Conteudo do campo a modificar           ³
//³1,4 - Matricula do conveniado                       ³
//³1,5 - Nome do conveniado                            ³
//³1,6 - Status da operacao com o conveniado(A,B,D)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nQtdeRegs  := 0      
If lRet  := MsgYesNo("Confirma a atualização na base de dados dos conveniados selecionados?")
   //Indica que um novo conveniado sera incluido no cadastro
   If lNovoConv  
      //Busca o codigo do ultimo cliente cadastrado
      lRet  := DroCodSB1(@cProxNumSA1)      
      If !lRet
         Return .F.
      EndIf   
   EndIf         
   
   ProcRegua(Len(aCampos))                                         
   BEGIN TRANSACTION 
   For nX := 1 to Len(aCampos)  //Qtde de conveniados a atualizar
      IncProc()
      
      cCodConv   := aCampos[nX][1]
      cLojConv   := aCampos[nX][2]
      cMatricula := aCampos[nX][4]
      cNomeConv  := aCampos[nX][5]      
      cStatus    := aCampos[nX][6]            
      lUsaCodCli := .F.
      nQtdeRegs++      
      If cStatus $ "BD"  //Bloqueio ou Desligamento
         //Clientes
         DbSelectArea("SA1")         
         DbSetOrder(1)
         If DbSeek(xFilial("SA1")+cCodConv+cLojConv)            
            Reclock("SA1",.F.)   
            SA1->A1_RISCO   := "E"  //Bloqueia o credito para nao permitir vender por CPF
            MsUnlock()            
         EndIf
         //Cartoes
         DbSelectArea("MA6")         
         DbSetOrder(2)
         If DbSeek(xFilial("MA6")+cCodConv+cLojConv)            
            lFound   := .F.
            While !Eof() .And. xFilial("MA6")+cCodConv+cLojConv == MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA .And.;
               !lFound
               //Se nao estiver vazio, o cartao pertence a algum dependente
               If !Empty(MA6->MA6_CODDEP)   
                  DbSkip()
                  Loop   
               EndIf
               
               lFound  := .T.
            End
            If lFound
               Reclock("MA6",.F.)   
               MA6->MA6_SITUA   := "2"  //Bloqueado
               If cStatus == "D"
                  MA6->MA6_MOTIVO  := "4"  //Desligamento
               EndIf   
               MsUnlock()            
            EndIf   
         EndIf             
         //Dependentes. Atualiza status de dependente(conveniado) da empresa de convenio
         DbSelectArea("MAC")         
         //DbSetOrder(1)
         DbOrderNickName("MACDRO1")      
         If DbSeek(xFilial("MAC")+cCodEmpresa+cLojEmpresa+cMatricula)            
            Reclock("MAC",.F.)   
            MAC->MAC_CARTAO     := "3"  //Inativo
            MsUnlock()            
         EndIf                  
         //Ref. trabalho
         If cStatus == "D"
            DbSelectArea("MA8")         
            DbSetOrder(1)
            If DbSeek(xFilial("MA8")+cCodConv+cLojConv)            
               lFound    := .F.
               While !Eof() .And. xFilial("MA8")+cCodConv+cLojConv == MA8->MA8_FILIAL+MA8->MA8_CODCLI+MA8->MA8_LOJA .And.;
                  !lFound
               
                  If cCodEmpresa != MA8->MA8_CODEMP
                     DbSkip()
                     Loop
                  EndIf   
               
                  lFound  := .T.
               End
               If lFound
                  Reclock("MA8",.F.)   
                  MA8->MA8_TIPO     := "2"  //Emprego anterior
                  MsUnlock()            
               EndIf   
            EndIf   
         EndIf                           
      Else  //Atualizacao
         For nY := 1 to Len(aCampos[nX][3])  //Qtde de alias por conveniado a atualizar       
            cAliasGrv  := aCampos[nX][3][nY][1]                          
            nRecnoRec  := aCampos[nX][3][nY][2]                          
            lIncluir   := .F.
            lFirst     := .T.
            lCriaConv  := .F.
            For nZ := 3 to Len(aCampos[nX][3][nY])  //Qtde de campos por alias a atualizar
               cCampoGrv  := aCampos[nX][3][nY][nZ][1]                   
               uContCpo   := aCampos[nX][3][nY][nZ][2]                   
               //Nao permitir modificar o codigo do cliente
               If "A1_COD " $ cCampoGrv
                  Loop
               EndIf
               If lFirst .And. cCodConv == "xxxxxx"  //Novo conveniado. Para cada novo alias, lIncluir := .T.
                  lIncluir  := .T.
               EndIf
            
               If lFirst
                  If lIncluir
                     If Substr(cAliasGrv,1,1) == "S"                  
                        cPrefixo     := Substr(cAliasGrv,2,2)
                     Else                                    
                        cPrefixo     := cAliasGrv                  
                     EndIf   
                     Reclock(cAliasGrv,.T.)
                     Replace (cPrefixo+"_FILIAL") With xFilial(cAliasGrv)                  
                     If cAliasGrv == "SA1"
                        SA1->A1_COD     := cProxNumSA1
                        SA1->A1_LOJA    := "01"
                        SA1->A1_EMPCONV := cCodEmpresa
                        SA1->A1_LOJCONV := cLojEmpresa                     
                        SA1->A1_TPCONVE := "3"  //Conveniado
                        lCriaConv        := .T.
                        lUsaCodCli       := .T.
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criacao das amarracoes do cliente³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            

                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar o cartão                   ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                                             
                     ElseIf cAliasGrv == "MA6"                                             
                        MA6->MA6_CODCLI  := cProxNumSA1
                        MA6->MA6_LOJA    := "01"                        
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar o complemento do cliente   ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                
                     ElseIf cAliasGrv == "MA7"
                        MA7->MA7_CODCLI  := cProxNumSA1
                        MA7->MA7_LOJA    := "01"
                        MA7->MA7_DATA    := dDatabase
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar a referencia de trabalho   ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                
                     ElseIf cAliasGrv == "MA8"                        
                        MA8->MA8_CODCLI  := cProxNumSA1
                        MA8->MA8_LOJA    := "01"
                        MA8->MA8_TIPO    := "1"  //Empresa atual
                        MA8->MA8_CODEMP  := cCodEmpresa
                        MA8->MA8_EMPRES  := cNomeEmp                               
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar a referencia de cartoes    ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                
                     ElseIf cAliasGrv == "MA9"                                                
                        MA9->MA9_CODCLI  := cProxNumSA1
                        MA9->MA9_LOJA    := "01"                                             
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar a referencia de bancos     ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                
                     ElseIf cAliasGrv == "MAA"                                                                        
                        MAA->MAA_CODCLI  := cProxNumSA1                                                              
                        MAA->MAA_LOJA    := "01"                        
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar a referencia pessoal       ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                
                     ElseIf cAliasGrv == "MAB"                                                
                        MAB->MAB_CODCLI  := cProxNumSA1
                        MAB->MAB_LOJA    := "01"
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar o dependente do cliente    ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                
                     ElseIf cAliasGrv == "MAC"                                                                        
                        MAC->MAC_CODCLI  := cProxNumSA1
                        MAC->MAC_LOJA    := "01"                        
                     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     //³Criar o documento entregue       ³ 
                     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                
                     ElseIf cAliasGrv == "MAE"                                                                        
                        MAE->MAE_CODCLI  := cProxNumSA1
                        MAE->MAE_LOJA    := "01"                     
                     EndIf   
                  Else
                     (cAliasGrv)->(DbGoto(nRecnoRec))     
                     Reclock(cAliasGrv,.F.)                                           
                  EndIf   
               Else
                  Reclock(cAliasGrv,.F.)                  
               EndIf   
               //Se o primeiro campo do arquivo de importacao nao for do SA1 deve ser gravado apos as amarracoes abaixo(SA1 x M*)
               Replace &cCampoGrv. With uContCpo
               MsUnlock()            

               If lCriaConv   
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³Relacionar o conveniado com a empresa de convenio atraves do cadastro de dependentes³ 
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                       
                  RecLock("MAC",.T.)               
                  MAC->MAC_FILIAL  := xFilial("MAC")
                  MAC->MAC_CODCLI  := cCodEmpresa
                  MAC->MAC_LOJA    := cLojEmpresa
                  MAC->MAC_CODDEP  := cMatricula
                  MAC->MAC_DEPNOM  := cNomeConv
                  MAC->MAC_CARTAO  := "2"                           
                  MsUnlock()                                 
               EndIf
               lIncluir  := .F.            
               lFirst    := .F.            
               lCriaConv := .F.
            Next nZ                     
         Next nY
         //O sequencial do codigo foi utilizado na criacao de um novo cliente, por isso, deve ser incrementado
         If lUsaCodCli
            cUltCodigo   := cProxNumSA1
            nNovoCodigo  := Val(cUltCodigo)+1
            FormatCod(cUltCodigo,nNovoCodigo,@cProxNumSA1)
            aAreaSA1     := SA1->(GetArea())
            SA1->(DbSetOrder(1))
            While SA1->(DbSeek(xFilial("SA1")+cProxNumSA1))
               cUltCodigo   := cProxNumSA1
               nNovoCodigo  := Val(cUltCodigo)+1
               FormatCod(cUltCodigo,nNovoCodigo,@cProxNumSA1)
            End
            SA1->(RestArea(aAreaSA1))                  
         EndIf   
         
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Efetua o desbloqueio caso o conveniado esteja bloqueado                             ³ 
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                       
         //Clientes
         lBloqueado  := .F.
         DbSelectArea("SA1")         
         DbSetOrder(1)
         If DbSeek(xFilial("SA1")+cCodConv+cLojConv)            
            lBloqueado  := (SA1->A1_RISCO == "E")         
         EndIf
         
         If lBloqueado
            //Cartoes
            lTemCartao  := .F.
            DbSelectArea("MA6")         
            DbSetOrder(2)
            If DbSeek(xFilial("MA6")+cCodConv+cLojConv)            
               lFound   := .F.
               While !Eof() .And. xFilial("MA6")+cCodConv+cLojConv == MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA .And.;
                  !lFound
                  //Se nao estiver vazio, o cartao pertence a algum dependente
                  If !Empty(MA6->MA6_CODDEP)   
                     DbSkip()
                     Loop   
                  EndIf
               
                  lFound  := .T.
               End
               If lFound            
                  If MA6->MA6_MOTIVO == "4"
                     cTxtLog  := "Conveniado de matrícula "+AllTrim(cMatricula)+" está bloqueado por motivo de desligamento da empresa."
                     cTxtLog  += "Não é possível atualizar seu status para Ativo."+CTRL               
                     EDIGrvLog(cTxtLog)
                     lGeraLog  := .T.
                     Loop   
                  Else
                     lTemCartao  := .T.                  
                     Reclock("MA6",.F.)   
                     MA6->MA6_SITUA   := "1"  //Ativo
                     MsUnlock()            
                  EndIf   
               EndIf   
            EndIf                      
            //Clientes
            Reclock("SA1",.F.)   
            SA1->A1_RISCO   := "B"  
            MsUnlock()            
         
            //Dependentes
            DbSelectArea("MAC")         
            //DbSetOrder(1)
            DbOrderNickName("MACDRO1")      
            If DbSeek(xFilial("MAC")+cCodEmpresa+cLojEmpresa+cMatricula)            
               Reclock("MAC",.F.)   
               MAC->MAC_CARTAO     := IIf(lTemCartao,"1","2")  //Sim ou Nao
               MsUnlock()            
            EndIf                           
         EndIf   
      EndIf
   Next nX   
   END TRANSACTION 
EndIf   

If lGeraLog
   MsgAlert("Foram encontradas algumas inconsistências no processamento."+;
            "Verifique o arquivo de LOG gerado em "+cStartPath+"LogIMPORT.log no servidor.")
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DroCodSB1 ºAutor  ³Fernando Machima    º Data ³  30/11/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o ultimo codigo de produto para inclusao de um novo  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DroCodSB1(cNovoCodigo)

Local aArea       := GetArea()
Local oDlgConv 
Local oGetCodUlt
Local oSayCod
Local lRet        := .T.
Local cSayCod     := ""
Local cUltCodigo  := ""
Local nTamCodPro  := TamSX3("B1_COD")[1]
Local nNovoCodigo

cSayCod  := "Confirma a geração do(s) conveniado(s)   "+CTRL
cSayCod  += "a partir do código identificado abaixo?  "+CTRL
cSayCod  += "Modifique o código, caso seja necessário."+CTRL

DbSelectArea("SB1")
DbSetOrder(1)  
//Se o arquivo estiver vazio, assume "000001" como codigo do cliente
If RecCount() == 0
   cNovoCodigo  := StrZero(1,nTamCodPro)
//Se o arquivo tiver um registro, assume "000001" , caso contrario, assume "000002"
ElseIf RecCount() == 1
   DbSeek(xFilial("SB1"))
   cNovoCodigo  := StrZero(1,nTamCodPro)   
   If cNovoCodigo == GetMV("000001")
      nNovoCodigo  := Val(cNovoCodigo)+1         
      cNovoCodigo  := StrZero(nNovoCodigo,nTamCodCli)         
   EndIf            
//Busca o codigo do ultimo produto e soma 1        
Else   
   DbSeek(xFilial("SB1")+Replicate("Z",nTamCodPro),.T.)
   DbSkip(-1)
   If SB1->B1_COD == "000001"
      DbSkip(-1)
   EndIf   
   cUltCodigo   := SB1->B1_COD
   nNovoCodigo  := Val(cUltCodigo)+1
   FormatCod(cUltCodigo,nNovoCodigo,@cNovoCodigo)      
   //Verifica se o codigo ja existe
   SB1->(DbSetOrder(1))
   While SB1->(DbSeek(xFilial("SB1")+cNovoCodigo))
      cUltCodigo   := cNovoCodigo
      nNovoCodigo  := Val(cUltCodigo)+1
      FormatCod(cUltCodigo,nNovoCodigo,@cNovoCodigo)
   End
EndIf   

//Mostra o codigo pesquisado e confirma com o usuario
DEFINE MSDIALOG oDlgProd TITLE "Código do produto" FROM 9,0 TO 20,28.5 OF oMainWnd

@ .1,.3 TO 4.8,13.9

@ .7,.8 SAY oSayCod VAR cSayCod OF oDlgProd SIZE 50,10 

@ 3.9,4.2 GET oGetCodUlt VAR cNovoCodigo OF oDlgProd SIZE 40,10 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes                                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 069,23 TYPE 1 ACTION (Iif(VldCodPro(cNovoCodigo),(lRet:=.T.,oDlgConv:End()),NIL)) ENABLE OF oDlgProd
DEFINE SBUTTON FROM 069,63 TYPE 2 ACTION (lRet:=.F.,oDlgProd:End()) ENABLE OF oDlgProd

ACTIVATE MSDIALOG oDlgProd CENTERED

RestArea(aArea)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FormatDataºAutor  ³Fernando Machima    º Data ³  06/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Converte a data em formato caracter para tipo data conside-º±±
±±º          ³ rando a picture                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FormatData(cData,cPicture,dData)
	
Local cDia   := ""
Local cMes   := ""
Local cAno   := ""     
Local cTemp  := ""
Local nX
Local nPosDia  := 0
Local nPosMes  := 0
Local nPosAno  := 0
Local nDigiAno := 0
Local nPosTemp := 0
Local lRet     := .T.

cData    := AllTrim(cData)
cTemp    := AllTrim(Upper(cPicture))
nPosDia  := AT("DD",cTemp)
nPosMes  := AT("MM",cTemp)
nPosAno  := AT("AA",cTemp)
nDigiAno := 0
nPosTemp := nPosAno
//Verifica a quantidade de digitos para o ano, 2 ou 4
For nX := 1 to Len(cTemp)
	If nPosTemp > 0
		cTemp  := Stuff(cTemp,nPosTemp,2,"  ")
		nDigiAno += 2
	Else
		Exit
	EndIf
	nPosTemp  := AT("AA",cTemp)
Next nX

If nPosDia > 0
	cDia  := Substr(cData,nPosDia,2)
EndIf
If nPosMes > 0
	cMes  := Substr(cData,nPosMes,2)
EndIf
If nPosAno > 0
	If nDigiAno == 2
		cAno  := Substr(cData,nPosAno,2)
	ElseIf nDigiAno == 4
		cAno  := Substr(cData,nPosAno,4)
	EndIf
EndIf
//Montagem da data de acordo com a picture
If !Empty(cDia) .And. !Empty(cMes) .And. !Empty(cAno)
	dData  := CToD(PadL(cDia,2,"0")+"/"+PadL(cMes,2,"0")+"/"+cAno)
Else
	lRet  := .F.
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldCodPro ºAutor  ³Fernando Machima    º Data ³  06/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o codigo do produtoi verificando se jah existe na   º±±
±±º          ³ base.		                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodPro(cCodigo)	

Local lRet  := .T.

cCodigo  := PadR(AllTrim(cCodigo),TamSX3("B1_COD")[1])
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1")+cCodigo))
   MsgAlert("Código de produto já cadastrado! Selecione outro código.")
   lRet  := .F.   
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FormatValoºAutor  ³Fernando Machima    º Data ³  09/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formata valores de acordo com a picture do layout          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FormatValor(cValor,cPicture,nValorExp)

Local lRet          := .T.
Local nPosDec                 //Posicao do separador de decimais
Local nQtdDecimais  := 0
Local cTxtLog       := ""
Local cTemp         := ""

//Verifica pela picture quantos decimais tem o valor a ser importado
If AT(",",cPicture) > 0 .Or. AT(".",cPicture) > 0
	For nPosDec := Len(cPicture) to 1 STEP -1
		If Substr(cPicture,nPosDec,1) == "." .Or. Substr(cPicture,nPosDec,1) == ","
			Exit
		Else
			nQtdDecimais++
		EndIf
	Next nPosDec
EndIf

//Tira pontos e virgulas do valor
cTemp := StrTran(cValor,",","")
cTemp := StrTran(cTemp,".","")

//Nao tem separador de decimais na picture do valor
If nQtdDecimais == 0
   cTxtLog  := "A picture para valor(numérico) no layout de configuração deve indicar a quantidade de casas decimais, ex: @E 999,999,999.99 "
   cTxtLog  += "ou o valor do arquivo de importação deve indicar as casas decimais."    
   cTxtLog  += CTRL
   EDIGrvLog(cTxtLog)                    
   lRet  := .F.
Else
   //Acrescenta ponto(".") como separador de decimais
   cTemp      := Stuff(PADL(AllTrim(cTemp),Len(cValor)),Len(cValor)-nQtdDecimais+1,0,".")      
   nValorExp  := Val(cTemp)
EndIf   

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FormatCod ºAutor  ³Fernando Machima    º Data ³  07/01/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Formata o novo codigo do cliente de acordo com o ultimo    º±±
±±º          ³ codigo                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FormatCod(cUltCodigo,nNovoCodigo,cNovoCodigo)

Local cTemp      := ""
Local lTemZero   := .F. 
Local nTamUltCod := 0

//Verifica se o ultimo codigo do cliente tem zeros a esquerda
cTemp     := AllTrim(cUltCodigo)
lTemZero  := Substr(cTemp,1,1) == "0" 
If lTemZero
   //Deve inserir a quantidade de zeros respeitando o tamanho do ultimo codigo de cliente. Por exemplo, se o ultimo codigo 
   //for 0100, deve gerar o novo codigo como 0101 e nao 000101
   nTamUltCod   := Len(AllTrim(cUltCodigo))
   cNovoCodigo  := PadR(StrZero(nNovoCodigo,nTamUltCod),Len(cUltCodigo))
Else 
   cNovoCodigo  := PadR(AllTrim(Str(nNovoCodigo)),Len(cUltCodigo))
EndIf

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
±±ºPrograma  ³DROSelTabPºAutor  ³Thiago Honorato	 º Data ³  15/03/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar a selecao da tabela de precos                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DROSelTabP(aLin5)

Local lRet  := .F.
Local nX
  
For nX := 1 to Len(aLin5)
   If aLin5[nX][1] == 1   
      lRet  := .T.
   EndIf
Next nX

If !lRet
   MsgAlert("Favor selecionar uma tabela de preços.")
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DRORunLbx5ºAutor  ³Thiago Honorato	 º Data ³ 22/02/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o BOX Regra de Compras de acordo com o Fornecedor  º±±
±±º		     ³escolhido.												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE - DROGARIA                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DRORunLbx5(oLbx05,cChave,aLin5)

Local cSeekAIA  := ""
Local cWhileAIA := ""
Local aRet5   := {}
Local aCpo5   := {}

If Empty(cChave)// se o Codigo do Fornecedor + Codigo da Loja estiverem vazios, traz todas as Tabelas de Precos
	cSeekAIA  := '"' + xFilial("AIA") + '"'
	cWhileAIA := "!EOF() .And. AIA_FILIAL == " + cSeekAIA 
Else//caso contrario, traz as Tabelas de Precos relacionadas ao Fornecedor indicado
	If DROVldFor(cChave)
		cSeekAIA  := '"' + xFilial("AIA") + cChave + '"'
		cWhileAIA := "!EOF() .And. AIA_FILIAL + AIA_CODFOR + AIA_LOJFOR == " + cSeekAIA 
	Endif
EndIf
aRet5   := LocxGrid("AIA",cWhileAIA,,.T.,".F.",cSeekAIA,1,{"AIA_CODTAB","AIA_DESCRI"},)
aCpo5   := AClone(aRet5[1])

aLin5 := AClone(aRet5[5])
oLbx05:SetArray(aLin5)
oLbx05:bLine := LocxBLin('oLbx05',aCpo5,.T.)

oLbx05:Refresh()

Return                       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DROVldFor ºAutor  ³Thiago P.Honorato   º Data ³  22/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o Codigo + Loja digitados existe na tabela SA2 º±±
±±º		     ³ Caso exista, verifca se eh um Fornecedor ou Fabricante     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DROVldFor(cChave)// cChave = cFornece + cLoja
Local lRet     := .T.    
Local lFornec  := .T.
Local cText1   :=	'Fornecedor não existe.                               '+; 
                	'Verifique o Código do Fornecedor e/ou Codigo da  Loja. '  
Local cText2    :=  'O Código do Fornecedor e Código da Loja  colocados são referentes a um Fabricante.                            '+;
					'Favor corrigi-los.'                	
Local aAreaSa2 := {} 
            
lFornec   := !Empty(cChave)// verifica se o Codigo + Loja estao vazios

If lFornec // se nao estiverem vazios  
	aAreaSA2 := SA2->(GetArea())//coloca SA2 como area atual
	If SA2->(!DbSeek(xFilial("SA2")+cChave))// verifica se o codigo do fornecedor + codigo da loja existem em SA2
		MsgAlert(cText1)
		lRet := .F.
	Else
		If SA2->A2_FABRICA = "S"//caso codigo do fornecedor + codigo da loja existam,verifica se a opcao A2_FABRICA = "S", ou seja, se eh um Codigo de Fabricante 
			MsgAlert(cText2)
			lRet := .F.
		Endif
	Endif
Endif

//Restaurando as Areas
If !Empty(aAreaSA2)
	SA2->(RestArea(aAreaSA2))
EndIf     

Return lRet