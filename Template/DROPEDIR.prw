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
#Define __ZEROS     9
#Define __TPREG     10
#DEFINE __DELETADO  11

//DEFINE's do array aDadosPedi
#DEFINE __PEDIDO     1
#DEFINE __PRODUTO    2
#DEFINE __NOMEPROD   3
#DEFINE __QTDATEND   4
#DEFINE __QTDNATEND  5
#DEFINE __CODBARRA   6
#DEFINE __CODPRODFOR 7


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DRORETAU  ºAutor  ³Geronimo B. Alves           º Data ³  08/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento AUTOMATICO do EDI - Receb. dados Pedidos de compras   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DRORETAU(aParam)
Local nContaForn := 0  // Conta os fornecedores processados
Local QtdNAtend  := .F. // Verifica se a quantidade no pedido foi enviado como falta.

Private lTela := .F.    // Não mostra mensagens na tela
Private cArqLogRet		:= "pcretornoedi.log"
Private cArqLogEnv	:= "pcenvioedi.log"  //Grava o arquivo de log de erro no mesmo diretorio do arquivo de envio

Private cNomeForn    := ""
Private aDadosPedi	:= {}  //Dados dos Pedidos de Compra mostrados no panel 4
Private aCampos		:= {}  //Dados dos Pedidos de Compra a serem processados
Private cNumDoc		:= " " //Numero do Pedido de compra

Private cGrupoForn		:= aParam[1]
Private cEMP				:= aParam[2]
Private cFil 				:= aParam[3]

Private cPcsRet 		:= ""  //P.Cs. Lidos no arquivo EDI de retorno
Private cPcsAtu	 		:= ""  //P.Cs. atualizados na importacao
Private cPcsEnv 		:= ""  //P.Cs. Criados para atender saldos dos pedidos
Private lAglutina			:= .T. 
Private aResult        := {}  // Resultado do processamento do EDI
Private cFornSaldo 		:= Padl( GETMV("MV_DROFORN") , TamSX3("A2_COD" )[1] )		// Cod. Fornecedor que receberá o saldo dos itens não atendidos
Private cLojaSaldo		:= Padl( GETMV("MV_DROLOJA" ) , TamSX3("A2_LOJA")[1] )		// Loja. Fornecedor que receberá o saldo dos itens não atendidos

wfprepenv(aParam[1],aParam[2])

T_EDIGrvLog( REPLICATE("*" ,60 ), cArqLogRet )
T_EDIGrvLog( "INICIO DO PROCESSAMENTO DO RETORNO AUTOMATICO DE P.C. DO GRUPO " + cGrupoForn , cArqLogRet )
T_EDIGrvLog( "Grupo Forecedor = " + cGrupoForn + "Empresa filial =" + cEMP +"-"+ cFilial , cArqLogRet )

dbselectarea("SA2")
dBsetOrder(1)
If !dbseek( xfilial("SA2") + cFornSaldo + cLojaSaldo )
	T_EDIGrvLog(  "Cadastrar os parametros MV_DROFORN e MV_DROLOJA com o codigo e a loja do fornecedor que conterá os saldos dos pedidos não atendidos"  , cArqLogRet )
	return
Endif

dbselectarea("LHV")
dBsetOrder(1)
if dbseek( xfilial("LHV") + cGrupoForn )
	While ! LHV->( Eof() )
		cCodFornecedor := LHV->LHV_FORNEC
		cLojFornecedor := LHV->LHV_LOJA
		dbselectarea("SA2")
		dBsetOrder(1)
		if dbseek( xfilial("LHV") + cCodFornecedor + cLojFornecedor )
			nContaForn++
			cArqRecebe	:= alltrim(SA2->A2_DIREDIR) + alltrim(SA2->A2_ARQEDIR)
			cDirLayout		:= alltrim(SA2->A2_DIRLAYR)
			cArqLay		:= alltrim(cDirLayout) + Alltrim(SA2->A2_LAYOUTR)
			If PediEDIVld(lTela, cArqRecebe,@QtdNAtend)
				ConfProc(@QtdNAtend)
			endif
		Else
			T_EDIGrvLog( "Não cadastrado o Fornecedor " +cCodFornecedor +cLojFornecedor , cArqLogRet )
		Endif
		
		T_EDIGrvLog( "Fornecedor             :  " + cCodFornecedor + " " + cLojFornecedor + " " + SA2->A2_NOME  , cArqLogRet )
		T_EDIGrvLog( "Pedidos Lidos          :  " + cPcsRet , cArqLogRet )
		T_EDIGrvLog( "Pedidos Atualizados    :  " + cPcsAtu , cArqLogRet )
		T_EDIGrvLog( "Pedidos Criados        :  " + cPcsEnv , cArqLogRet )
		LHV->( DbSkip() )

	End
Else
	T_EDIGrvLog( "Grupo de fornecedor Não cadastrado " +cGrupoForn , cArqLogRet )
Endif

T_EDIGrvLog( "  " , cArqLogRet )
T_EDIGrvLog( "FIM DO RETORNO AUTOMATICO DE P.C. DO GRUPO " + cGrupoForn + ". CONTENDO " +alltrim(STR(nContaForn)) + " FORNECEDORES" , cArqLogRet )
T_EDIGrvLog( REPLICATE("*" ,60 ) , cArqLogRet )

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROPEDIR  ºAutor  ³Geronimo B. Alves           º Data ³  17/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento do EDI - Retorno dos dados dos Pedidos de compras     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function DROPEDIR()

Local oWizard, oPanel
Local oGrp1,oRad1,oGet1
Local oGrp2,oGet2
Local oGetCodFornecedor, oGetLojEmpresa
Local oGetRegProc
Local oGetEmp
Local oGetArqEDI
Local oLBBx
Local oResult
Local nArq    := 0
Local aDir    := {}
Local aCabBx  := {}
Local aTamBx  := {}
Local aCabRet := {}
Local aTamRet := {}
Local cTxt1   := ""
Local cTxt2   := ""
Local cExt    := "REC"  //Extensao do arquivo de configuracao para importacao dos dados dos pedidos de compras
Local bValid
Local cText :=	'Este programa irá processar o arquivo de retorno do EDI de Pedidos de Compras, ' + ;
'contendo os dados dos pedidos de compras atendidos. A leitura do arquivo ocorre de acordo ' + ;
'com a configuração pré-definida no configurador do EDI.' + CTRL + ;
'Os itens não atendidos ou atendidos parcialmente gerarão um novo pedido para ' + CTRL + ;
'o próximo fornecedor segundo o criterio de prioridade definido no sistema.   ' + CTRL + CTRL + ;
'Para continuar clique em Avançar.'

Local QtdNAtend := .F.
lTela := .T.    // mostra mensagens na tela
Private cCodFornecedor := Space(TamSX3("A2_COD")[1])
Private cLojFornecedor := Space(TamSX3("A1_LOJA")[1])

Private cArqRecebe := "\system\"
Private cDirLayout	:= alltrim(SA2->A2_DIRLAYR)		//cDirLayout  := Upper(GetSrvProfString("STARTPATH",""))
Private cArqLay		:= alltrim(cDirLayout) + Alltrim(SA2->A2_LAYOUTR)
Private cArqLogRet	:= "pcretornoedi.log"			 //Grava o arquivo de log de erro no diretorio startpath
Private cArqLogEnv	:= "pcenvioedi.log"			 //Grava o arquivo de log de erro no diretorio startpath

//Registros processados na geracao do arquivo de envio. Mostrado no resultado do processamento(quinto panel)
Private cPcsRet 		:= ""  //P.Cs. Lidos no arquivo EDI de retorno
Private cPcsAtu			:= ""  //P.Cs. atualizados com a importacao
Private cPcsEnv			:= ""  //P.Cs. Criados para atender saldos dos pedidos
Private aResult        := {}  // Resultado do processamento do EDI
Private cNomeForn		:= ""
Private aDadosPedi	:= {}  //Dados dos Pedidos de Compra mostrados no panel 4
Private aCampos		:= {}  //Dados dos Pedidos de Compra a serem processados
Private cNumDoc		:= " " //Numero do Pedido de compra
Private lAglutina			:= .T. 
Private cFornSaldo 	:= Padl( GETMV("MV_DROFORN") , TamSX3("A2_COD" )[1] )		// Cod. Fornecedor que receberá o saldo dos itens não atendidos
Private cLojaSaldo		:= Padl( GETMV("MV_DROLOJA" ) , TamSX3("A2_LOJA")[1] )		// Loja. Fornecedor que receberá o saldo dos itens não atendidos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do array aDadosPedi       ³
//³------------------------------      ³
//³1-Numero do Pedido                  ³
//³2-Codigo do produto                 ³
//³3-Nome   do produto                 ³
//³4-Quantidade Atendida               ³
//³5-Quantidade Nao Atendida           ³
//³6-Codigo de Barra                   ³
//³7-Codigo do Produto no Fornecedor   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao da estrutura do array aCampos:                ³
//³                                                      ³
//³1,1 - Numero do Pedido                                ³
//³1,2 - Data da emissao do Pedido                       ³
//³1,3,1  - Codigo Produto                               ³
//³1,3,2  - Quantidade atendida                          ³
//³1,3,3  - Preco unitario produto                       ³
//³1,3,4  - Cod. Barra do Produto                        ³
//³1,3,5  - Cod. Produto no Fornecedor                   ³
//³1,3,6  - Cod. Tabela Preço                            ³
//³1,3,7  - TES                                          ³
//³1,3,8  - Desconto financeiro                          ³
//³1,3,9  - Local                                        ³
//³1,3,10 - Filial da necessidade                        ³
//³1,4 - Condicao Pagamento                              ³
//³1,5 - Desconto 1                                      ³
//³1,6 - Desconto 2                                      ³
//³1,7 - Filial de entrega                               ³ 
//³1,8 - Numero do Pedio OK?  Se .T. processar o retorno ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

DbSelectArea("SA2")
DbSetOrder(1)
If !dbseek( xfilial("SA2") + cFornSaldo + cLojaSaldo )
	msgstop( "Cadastrar os parametros MV_DROFORN e MV_DROLOJA com o codigo e a loja do fornecedor que conterá os saldos dos pedidos não atendidos"  , "Atenção"  )
	return
Endif

PediEDIDir(cDirLayout,cExt,@aDir)

T_EDIGrvLog( REPLICATE("*" ,60 ), cArqLogRet )
T_EDIGrvLog( "INICIO DO PROCESSAMENTO DO RETORNO MANUAL DE P.C.  " , cArqLogRet )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard TITLE 'Processamento do arquivo de retorno para atualização dos dados dos Pedidos de Compras' ;
HEADER 'Wizard do processamento do arquivo de retorno do pedidos de compras:' ;
MESSAGE 'Processamento automático.' TEXT cText NEXT {|| .T.} FINISH {|| .T.} PANEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Segundo Panel - Pergunte do fechamento     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Dados para processamento de pedidos de compras ' ;
MESSAGE 'Informe o Fornecedor a ser processado.' ;
BACK {|| .T. } NEXT {|| pediEDIValid() } FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(2)

bValid   := {|| ExistCpo("SA2",cCodFornecedor) , cLojFornecedor := SA2->A2_LOJA }
TSay():New(15,05,{|| "Fornecedor"},oPanel,,,,,,.T.)
oGetCodFornecedor := TGet():New(14,70,bSETGET(cCodFornecedor),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA2",)

bValid   := {|| ExistCpo("SA2",cCodFornecedor+cLojFornecedor)}
TSay():New(35,05,{|| "Loja do Fornecedor"},oPanel,,,,,,.T.)
oGetLojEmpresa := TGet():New(34,70,bSETGET(cLojFornecedor),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Terceiro Panel - Arquivo de Retorno                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Arquivos de layout e de retorno do Fornecedor ';
MESSAGE 'Informe a pasta onde está o arquivo de layout do retorno do Fornecedor e o caminho e o nome do arquivo de retorno do Fornecedor.' ;
BACK {|| .T. } NEXT {|| IIf(EDIVldDir(cArqRecebe), PediEDIVld(lTela, cArqRecebe,@QtdNAtend),.F.)} FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(3)

TSay():New(25,08,{|| "Escolha o arquivo de retorno do Fornecedor:"},oPanel,,,,,,.T.)
oGet2 := TGet():New(35,08, bSETGET(cArqRecebe),oPanel,145,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(35,155,14, {|| cArqRecebe := cGetFile("Todos Arquivos |*.ret|","Escolha o arquivo de retorno do Fornecedor.",0,,.T.,GETF_ONLYSERVER), VldArqReceb(@cArqRecebe) },oPanel,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quarto Panel - Visualizacao dos registros a serem atualizados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo os Pedidos que serão processados. Para efetuar as modIficações na base de dados, clique em Avançar.' ;
BACK {|| .T. } NEXT {|| ConfProc(@QtdNAtend)} FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(4)

aTamBx	:= {30,70,100,35,70,100}
aCabBx	:= {"Pedido", "Produto", "Nome do Produto", "Qtd. Atend","Qtd. Nao Atend", "Codigo de Barra" , "Cod. Produto no Fornecedor" }
aAdd(aDadosPedi,{"","","","","","",""})
oLBBx		:=TwBrowse():New(000,003,000,000,,aCabBx,aTamBx,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBBx:SetArray(aDadosPedi)
oLBBx:bLine 	:= { ||{aDadosPedi[oLBBx:nAT][__PEDIDO], aDadosPedi[oLBBx:nAT][__PRODUTO], ;
aDadosPedi[oLBBx:nAT][__NOMEPROD], aDadosPedi[oLBBx:nAT][__QTDATEND], ;
aDadosPedi[oLBBx:nAT][__QTDNATEND],aDadosPedi[oLBBx:nAT][__CODBARRA],  ;
aDadosPedi[oLBBx:nAT][__CODPRODFOR]}}
oLBBx:lHScroll  :=.T.
oLBBx:nHeight	:=270
oLBBx:nWidth	:=550

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quinto Panel - Status do Processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo o resultado do Processamento' ;
BACK {|| .F. } NEXT {|| .T. } FINISH {|| .T. } PANEL
oPanel := oWizard:GetPanel(5)

aTamRet := { 60, 60, 60, 60, 60 }
aCabRet := { "Pedido Lido", "Produto", "Qtde Atendida", "Pedido Criado", "Qtde Pendente" }
aAdd( aResult, { "", "", "", "", "" } )

oResult				:=TwBrowse():New(000,003,000,000,,aCabRet,aTamRet, oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oResult:SetArray( aResult )
oResult:bLine		:= { ||{ aResult[oResult:nAT][1], aResult[oResult:nAT][2], aResult[oResult:nAT][3], aResult[oResult:nAT][4], aResult[oResult:nAT][5] } }
oResult:lHScroll	:= .T.
oResult:nHeight		:= 270
oResult:nWidth		:= 550

ACTIVATE WIZARD oWizard CENTER

T_EDIGrvLog( "Fornecedor             :  " + cCodFornecedor + " " + cLojFornecedor + " " + cNomeForn  , cArqLogRet )
T_EDIGrvLog( "Pedidos Lidos          :  " + cPcsAtu , cArqLogRet )
T_EDIGrvLog( "Pedidos Atualizados    :  " + cPcsRet , cArqLogRet )
T_EDIGrvLog( "Pedidos Criados        :  " + cPcsEnv , cArqLogRet )
T_EDIGrvLog( "FIM DO RETORNO MANUAL DE P.C. " , cArqLogRet )
T_EDIGrvLog( REPLICATE("*" ,60 ) , cArqLogRet )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PediEDIDirºAutor  ³Geronimo B. Alves   º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica validade do Path e refaz vetor aDir.              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PediEDIDir(cDirLayout,cExt,aDir)
Local   aTMP := {}

aDir := {}
If Empty(cDirLayout) .AND.   .F.
	MsgAlert("Caminho inválido!")
	T_EDIGrvLog( "Caminho inválido!" , cArqLogRet )
	Return .F.
EndIf
aTMP := Directory(cDirLayout+"*."+cExt)
AEval(aTMP,{|x,y| AAdd(aDir, x[1]) })

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PediEDIVld ºAutor  ³Geronimo B. ALves   º      ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos dados e chamada do processamento de º±±
±±º          ³ importacao dos dados dos Pedidos                            º±±
±±º          ³ Parametros:                                                 º±±
±±º          ³ lTela = Exibir mensagens em tela .T. no server .F.          º±±
±±º          ³ cArqLayout = Pasta  + arquivo de configuracao do layout     º±±
±±º          ³ ArqRecebe = Pasta + arquivo de retorno do Fornecedor        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PediEDIVld( lTela, cArqRecebe,QtdNAtend )
Local lRet      := .T.

DEFAULT lTela      := .F.   
DEFAULT QtdNAtend  := .F.

If Empty(cArqRecebe)
	If lTela
		MsgAlert("Selecione o arquivo de retorno do Fornecedor.")
	Else
		T_EDIGrvLog( "Arquivo de retorno do Fornecedor Nâo cadastrado no fornecedor "  +cCodFornecedor  +"-"+cLojFornecedor  , cArqLogRet )
	EndIf
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTela
	Processa( { |Lend| lRet  := PediEDIPro(cArqRecebe,@QtdNAtend) }, "Processando...",, .F.)
Else
	PediEDIPro(cArqRecebe,@QtdNAtend)
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PediEDIProºAutor  ³Geronimo B. Alves   º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa o EDI-Atualizacao dos dados dos Pedidos Compras   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PediEDIPro(cArqRecebe,QtdNAtend)

Local nHandle
Local nRecno	:= 0
Local lRet      := .T.
Local lGeraLog  := .F.
Local cArqLay   := ""
Local cTxtLog   := ""
Local cLinha    := ""
Local aLayOut   := {}
Local uConteudo
Local _ni , _nj
DEFAULT QtdNAtend := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento no fornecedor           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA2")
DbSetOrder(1)
If !DbSeek(xFilial("SA2")+cCodFornecedor+cLojFornecedor)
	if lTela
		MsgAlert("Fornecedor não encontrado no cadastro de Fornecedores.")
	Endif
	T_EDIGrvLog( "Fornecedor não encontrado no cadastro de Fornecedores." , cArqLogRet )
	Return .F.
EndIf

If Empty(SA2->A2_LAYOUTR)
	If lTela
		MsgAlert("Campo arquivo de configuração do layout do retorno do fornecedor não preenchido! Verificar o campo Layout  do cadastro de fornecedores.")
	Endif
	T_EDIGrvLog( "Campo arquivo de configuração do layout do retorno do fornecedor não preenchido! Verificar o campo Layout  do cadastro de fornecedores)" , cArqLogRet )
	Return .F.
EndIf
cArqLay     := AllTrim( SA2->A2_DIRLAYR ) + AllTrim( SA2->A2_LAYOUTR )
cNomeForn	:= SA2->A2_NOME

If !File(cArqLay)
	If lTela
		MsgAlert("Arquivo de configuracao de layout não encontrado! Verificar o diretorio e o nome do arquivo no cadastro do fornecedor.")
	EndIf
	T_EDIGrvLog( "Arquivo de configuracao de layout não encontrado! Verificar o diretorio e o nome do arquivo no cadastro do fornecedor." , cArqLogRet )
	Return .F.
EndIf

aLayOut := __VRestore(cArqLay)
If Len(aLayOut) != 4
	If lTela
		MsgAlert("Arquivo de configuração de layout inválido! VerIficar a estrutura do arquivo através do configurador EDI.")
	EndIf
	T_EDIGrvLog( "Arquivo de configuração de layout inválido! VerIficar a estrutura do arquivo através do configurador EDI." , cArqLogRet )
	Return .F.
EndIf

If File(cArqRecebe)
	nHandle := FOpen(cArqRecebe,1)
	FSeek(nHandle,0,2)
	If nHandle = -1
		If lTela
			MsgAlert("Erro na abertura do arquivo de retorno de pedido de compras do Fornecedor "+cArqRecebe)
		EndIf
		T_EDIGrvLog( "Erro na abertura do arquivo de retorno de pedido de compras do Fornecedor "+cArqRecebe , cArqLogRet )
		Return .F.
	EndIf
EndIf

aCampos    := {}

//Exclui a linha em branco
If Len(aDadosPedi) == 1 .AND. Empty(aDadosPedi[1][1])
	ADel(aDadosPedi,1)
	ASize(aDadosPedi, Len(aDadosPedi)-1 )
Else
	aDadosPedi  := {}
EndIf

DbSelectArea("SC7")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ler o arquivo de retorno do Fornecedor     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FT_FUSE(cArqRecebe)
FT_FGOTOP()

nCabDetRod	:= 2   //Devo pesquisar campo somente no detalhe de aLayout: 	// 1=Cabecalho  2=Detalhe  3=Rodape
aItemSC7:={	"SC7->C7_PRODUTO","SB1->B1_CODBAR","SA5->A5_CODPRF","SC7->C7_QUANT","SC7->C7_PRCVEN","SC7->C7_CODTAB","SC7->C7_TES","SC7->C7_DESCFIN","SC7->C7_LOCAL" }
nLenTpReg := Len(aLayout[nCabDetRod][1][__TPREG])
LastNumPed := ""

While !FT_FEOF()
	cLinha:= FT_FREADLN()
	
	++nRecno
	If Empty(cLinha)
		FT_FSKIP()
		Loop
	EndIf
	
	cTpRegistr  := ""
	T_EDILeReceb(cLinha,aLayout,"TIPOREG",@cTpRegistr,NIL,@QtdNAtend)
	
	cNumped     := ""
	T_EDILeReceb(cLinha,aLayout,"SC7->C7_NUM",@cNumped,NIL,@QtdNAtend)
	cNumped    := AllTrim(cNumped)
	LastNumPed := RIGHT(If( !Empty(cNumped) , cNumped , LastNumPed ), TamSx3("C7_NUM")[1]) 
	
	If !Empty(LastNumPed)
		nPosPed   := Ascan(aCampos,{|x| x[1] == LastNumPed })
		If nPosPed == 0
			SC7->(DbSetOrder(1))
			SC7->(DbSeek(xFilial("SC7")+LastNumPed))
			//Atualiza array com os dados do cabecalho do pedido de compras
			aAdd(aCampos,{LastNumPed,dDatabase, {}, SC7->C7_COND,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_FILenT, .T. })
			nPosPed := Len(aCampos)
		EndIf
		
		aCamposItens :=  {"", "", "", "", "", "", "", "", "", "" }
		For _ni := 1 to 4 // Procura no arquivo C7_PRODUTO, B1_CODBAR, A5_CODPRF, C7_QUANT e QUANT_NEW
			T_EDILeReceb(cLinha,aLayout, aItemSC7[_nI], @aCamposItens[_nI],NIL,@QtdNAtend  )
		Next
		
		If (!Empty( aCamposItens[1]) .OR. !Empty( aCamposItens[2]) .OR. !Empty( aCamposItens[3]) ) .AND. val(aCamposItens[4]) > 0
			aAdd( aCampos[ nPosPed ,3 ] , aCamposItens )
		EndIf
		
	EndIf
	
	FT_FSKIP()
End

FT_FUSE()
//Fecha o arquivo de retorno do Fornecedor
FClose(nHandle)

If lRet
	For _ni := 1 to len(acampos)
		cPCsRet := acampos[_ni,1] + " ,  "
		For _nj := 1 to len(acampos[_ni,3])
			
			if !empty( acampos[_ni,3,_nj,1] )  // Se tem Cod. Prod.
				dbselectArea("SB1")
				DbSetOrder(1)
				DbSeek(XFILIAL("SB1")+ acampos[_ni,3,_nj,1])
			Endif
			
			If Empty( acampos[_ni,3,_nj,1] ) .OR. SB1->( EOF() )  // Se Cod. Prod. Vazio ou invalido
				DbSelectArea("SB1")
				DbSetOrder(5)
				If DbSeek(xFilial("SB1")+ LEFT( acampos[_ni,3,_nj,2]+ space(TamSx3("B1_CODBAR")[1]) ,TamSx3("B1_CODBAR")[1])  )  // posiciona SB1 pelo Cod. de Barra
					If !Empty( acampos[_ni,3,_nj,2] )
						acampos[_ni,3,_nj,1] := SB1->B1_COD
					EndIf
				Else
					DbSelectArea("SA5")
					DbSetOrder(5)
					If DbSeek(xFilial("SA5")+ acampos[_ni,3,_nj,3])  // posiciona SB1 pelo Cod. do Prod. no Fornecedor
						If !Empty( acampos[_ni,3,_nj,3] )
							acampos[_ni,3,_nj,1] := SA5->A5_PRODUTO
							DbSelectArea("SB1")
							DbSetOrder(5)
							DbSeek(xFilial("SB1")+ acampos[_ni,3,_nj,1] )
						EndIf
					EndIf
				EndIf
			EndIf
			
			If Empty( acampos[_ni,3,_nj,2] )
				acampos[_ni,3,_nj,2] := SB1->B1_CODBAR
			EndIf
			
			If Empty( acampos[_ni,3,_nj,3] )
				DbSelectArea("SA5")
				DbSetOrder(1)
				If DbSeek(xFilial("SA5")+ cCodFornecedor+  cLojFornecedor+ acampos[_ni,3,_nj,1])
					If !Empty( acampos[_ni,3,_nj,1] )
						acampos[_ni,3,_nj,3] := SA5->A5_CODPRF
					EndIf
				EndIf
			EndIf
			If !QtdNAtend 
			    //                  1 PEDIDO     - 2 PRODUTO             -3 NOMEPROD   -    4 QTDATEND            - 5 QTDNATEND               - 6 CODBARRA          - 7 CODPRODFOR
		   		aAdd(aDadosPedi, { acampos[_ni,1], acampos[_ni,3,_nj,1], SB1->B1_DESC, Val(acampos[_ni,3,_nj,4]), 0                        , acampos[_ni,3,_nj,2], acampos[_ni,3,_nj,3]  } )
		   	Else
		   		aAdd(aDadosPedi, { acampos[_ni,1], acampos[_ni,3,_nj,1], SB1->B1_DESC, 0                         ,Val(acampos[_ni,3,_nj,4]), acampos[_ni,3,_nj,2], acampos[_ni,3,_nj,3]  } )
		   	Endif	
		Next
	Next
	
	If Len(aDadosPedi) > 0
	   aSort(aDadosPedi,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
	Else
		
		_cMSG := "Não foi processado nenhum registro do arquivo "+cArqRecebe+" (retorno do Pedido de Compras do Fornecedor) "+;
		AllTrim(cNomeForn)+"."+CTRL+" VerIfique o conteúdo do arquivo e o layout de configuração."
		If lTela
			MsgAlert(_cMSG)
		EndIf
		T_EDIGrvLog( _cMSG, cArqLogRet )
		lRet  := .F.
	EndIf
EndIf

If lGeraLog
	lRet  := .F.
	
	_cMSG := "PROCESSAMENTO NÃO EFETUADO. Foram encontradas algumas inconsistências no processamento."+;
	"VerIfique o arquivo de LOG gerado em "+ GetSrvProfString("STARTPATH","")+"Retornoedipc.log no servidor."
	If lTela
		MsgAlert(_cMSG)
	EndIf
	T_EDIGrvLog( _cMSG , cArqLogRet )
	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PediEDIValºAutor  ³Geronimo B. Alves   º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao dos campos codigo e loja do fornecedor           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PediEDIValid()

Local lRet  := .T.

If Empty(cCodFornecedor)
	MsgAlert("Preencher o codigo do fornecedor.")
	T_EDIGrvLog( "Preencher o codigo do fornecedor." , cArqLogRet )
	lRet  := .F.
EndIf

If lRet .And. Empty(cLojFornecedor)
	MsgAlert("Preencher a loja do fornecedor.")
	T_EDIGrvLog( "Preencher a loja do fornecedor." , cArqLogRet )
	lRet  := .F.
EndIf

cArqRecebe := alltrim(SA2->A2_DIREDIR) + alltrim(SA2->A2_ARQEDIR)		// Caminho completo do arquivo de retorno de Edi a ser processado
cDirLayout	:= alltrim(SA2->A2_DIRLAYR)		//Path do arquivo de configuracao de lay-out de importacao
cArqLay		:= alltrim(cDirLayout) + Alltrim(SA2->A2_LAYOUTR)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDIVldDir ºAutor  ³Fernando Machima    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da selecao do caminho dos arquivos de layout e   º±±
±±º          ³ de retorno do Fornecedor                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EDIVldDir(cArqRecebe)
Local lRet  := .T.

If Empty(cArqRecebe)
	MsgAlert("Selecionar o arquivo de retorno do Fornecedor.")
	T_EDIGrvLog( "Selecionar o arquivo de retorno do Fornecedor." , cArqLogRet )
	lRet  := .F.
EndIf

If lRet
	If !File(cArqRecebe)
		T_EDIGrvLog( "O arquivo de retorno do Fornecedor selecionado não existe." , cArqLogRet )
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
±±ºDesc.     ³ Geracao do arquivo de log para ocorrencias no envio e retorno do  º±±
±±º          ³ EDI do pedidos de compras.                          		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function EDIGrvLog(cTexto,cArqLog )

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDILeRecebºAutor  ³Fernando Machima    º Data ³  17/11/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Le o arquivo de retorno do Fornecedor : cabecalho, itens e rodape     º±±
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
Template Function EDILeReceb(cLinha,aLayout,cCampo,uConteudo,cArqLay,QtdNAtend)

Local nX
Local nColInicial := 0
Local nTamanho    := 0
Local nValorExp   := 0
Local lRet        := .T.
Local lDataOK     := .T.
Local lGeraLog    := .F.
Local cNomeCampo  := ""
Local cTitulo     := ""
Local cTipo       := ""
Local cPicture    := ""
Local cTxtLog     := ""
Local dData

DEFAULT QtdNAtend := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao da estrutura de layout do arquivo(aLayout):              ³
//³                                                                 ³
//³__TITULO     1 - Titulo do campo                                 ³
//³__LINHA      2 - Linha de impressao                              ³
//³__COLINI     3 - Coluna inicial                                  ³
//³__TAMANHO    4 - Tamanho                                         ³
//³__COLFIM     5 - Coluna final                                    ³
//³__TIPO       6 - Tipo(1=Caracter;2=Numerico;3=Data;4=Logico)     ³
//³__CONTEUDO   7 - Conteudo do campo                               ³
//³__PICTURE    8 - Picture                                         ³
//³__ZEROS	    9 - Alinha zeros ?                                  ³
//³__TPREG     10 - Tipo do Registro                                ³
//³__DELETADO  11 - Deletado?                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aLayout[nCabDetRod])
	//Ignorar os deletados no layout
	If aLayout[nCabDetRod][nX][Len(aLayout[nCabDetRod][nX])]
		Loop
	EndIf
	
	nColInicial := aLayout[nCabDetRod][nX][__COLINI]
	nTamanho    := aLayout[nCabDetRod][nX][__TAMANHO]
	If !Empty(cCampo)
		//Deve retornar o conteudo de um campo com base no arquivo de configuracao
		If AllTrim(aLayout[nCabDetRod][nX][__CONTEUDO]) $ cCampo
		    If AllTrim(aLayout[nCabDetRod][nX][__TITULO]) $ "QTD. NAO ATEND."
		    	QtdNAtend := .T.
		    EndIf
			if alltrim(cCampo) == "TIPOREG" //para identificar o tipo de registro não confiro o cTpRegistr ,pois, devo ler todos os registros
				uConteudo   := AllTrim(Substr(cLinha,nColInicial,nTamanho))
				uConteudo   := PADR(uConteudo,nTamanho)  //Alinha a esquerda(espacos em branco a direita)
				Exit
			else
				if strzero(val(cTpRegistr), nLenTpReg) == strzero(val(aLayout[nCabDetRod][nX][__TPREG]) , nLenTpReg)
					uConteudo   := AllTrim(Substr(cLinha,nColInicial,nTamanho))
					uConteudo   := PADR(uConteudo,nTamanho)  //Alinha a esquerda(espacos em branco a direita)
					Exit
				endif
			endif
		EndIf
	Else
		//Le o conteudo de um campo com base no arquivo de configuracao
		//Campo para gravacao         //Conteudo do arquivo texto
		uConteudo  := AllTrim(Substr(cLinha,nColInicial,nTamanho))
		uConteudo  := PADR(uConteudo,nTamanho)
		cNomeCampo := aLayout[nCabDetRod][nX][__CONTEUDO]
		cTitulo    := AllTrim(aLayout[nCabDetRod][nX][__TITULO])
		cTipo      := aLayout[nCabDetRod][nX][__TIPO]
		cPicture   := AllTrim(aLayout[nCabDetRod][nX][__PICTURE])
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
				T_EDIGrvLog(cTxtLog, cArqLogRet)
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
				T_EDIGrvLog(cTxtLog, cArqLogRet)
				lGeraLog  := .T.
				Return(.F.)
			Else
				lDataOK    := FormatData(uConteudo,cPicture,@dData)
			EndIf
			If lDataOK
				uConteudo  := dData
			Else
				cTxtLog  := "Erro na formatação da data do registro "+cLinha
				T_EDIGrvLog(cTxtLog, cArqLogRet)
				Return(.F.)
			EndIf
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
±±ºDesc.     ³ Valida o arquivo de retorno do Fornecedor                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - path e nome do arquivo de de retorno do Fornecedor  selecionado   º±±
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
	T_EDIGrvLog( "Arquivo não encontrado!" , cArqLogRet )
	lRet  := .F.
Else
	//Verifica se não foi selecionada uma pasta
	nHandle := FOpen(cArqRecebe,1)
	FSeek(nHandle,0,2)
	If nHandle == -1
		MsgAlert("Arquivo inválido.")
		T_EDIGrvLog( "Arquivo inválido." , cArqLogRet )
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
±±ºDesc.     ³ Confirma o processamento de atualizacao dos Pedidos Comprasº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConfProc(QtdNAtend)
Local lRet        := .T.
DEFAULT QtdNAtend := .F.
MsgRun("Aguarde. Processando arquivo de retorno do fornecedor " ,,{|| lRet := ProcArqRet(@QtdNAtend)  })
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcArqRet ºAutor  ³Venda Clinetes      º Data ³  22/07/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua o processamento de leitura do arquivo de retorno e   º±±
±±º          ³ geração de novos P.C.s                                      º±±
±±º          ³ Para os fornecedores dos proximos niveis de prioridade      º±±
±±º          ³ quando o item não for   									   º±±
±±º          ³ totalmente atendido                                         º±±                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcArqRet(QtdNAtend )
Local nInc        	:= 0                  // Contador
Local nItem       	:= 0                  
Local nCampos     	:= 0
Local nQtdAte		:= 0
Local nQtdAlt		:= 0
Local nQtdPend		:= 0
Local nRes         := 0
Local cItem       	:= ""                 // Item do SC7
Local cOldForn    	:= ""                 // Fornecedor antigo --> Que gerou o PC anterior
Local cOldLoja    	:= ""                 // Loja         "         "    "     "      "
Local cTxtLog     	:= ""                 // Variavel para gravar o log
Local cPedOrig    	:= ""                 // Nro do Pedido original onde foi criada a lista de prioridades
Local cFornece    	:= ""                 // Fornecedor
Local cLojaForn   	:= ""                 // Loja
Local lRet        	:= .T.                // Retorno
Local lerro			:= .F.                // Se devera gerar log
Local lProxNivel  	:= .F.                // Proximo nivel na tabela
Local lGravaPed   	:= .F.                // Se grava o PC 
Local lRelat       := .F.                // Se deseja emitir relatorio se algum produto nao foi atendido pelos fornecedores da lista de prioridades
Local aCampos3Aux 	:= {}                 // Armazena os campos de forma sintetica para facilitar o processamento
Local aNxtFor     	:= {}                 // Proximo fornecedor para geracao do PC conforme a prioridade
Local aSC7        	:= {}                 // Array com os campos a serem gravados no SC7
Local aCamposC7   	:= {}                 // Campos do SC7 para gravacao dinamica
Local aCab        	:= {}                 // Cabecalho do SC7
Local aItens      	:= {}                 // Itens do SC7
Local aCabAlt     	:= {}                 // Cabecalho do SC7 que tera sua quantidade ajustada
Local aItensAlt   	:= {}                 // Itens do SC7 que tera sua quantidade ajustada
Local aAux        	:= {}
Local aRelat		:= {}				  // Itens nao atendidos pelos fornecedores
Local nQtdeAt		:= 0				  // Quantidade atendida pelo forncedor	 
Local aQtdAtFor     := {}            	  // Quantidade atendida pelo forncedor   
Local lContinua     := .F.               // Controla se houve erro no Execauto     
Local lC7Bonus   := SC7->(ColumnPos("C7_BONUS")) > 0       //Verifica se o campo existe no dicionário de dados


DEFAULT QtdNAtend   := .F.  

Private lMsErroAuto := .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui a linha em branco                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aResult ) == 1 .AND. Empty( aResult[1][1] )
	aDel( aResult, 1 )
	aSize( aResult, Len( aResult ) - 1 )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao da estrutura do array aCampos:              ³
//³                                                    ³
//³1,1 - Numero do Pedido                              ³
//³1,2 - Data da emissao do Pedido                     ³
//³1,3,n,1  - Codigo Produto                           ³
//³1,3,n,2  - Quantidade atendida                      ³
//³1,3,n,3  - Preco unitario produto                   ³
//³1,3,n,4  - Cod. Barra do Produto                    ³
//³1,3,n,5  - Cod. Produto no Fornecedor               ³
//³1,3,n,6  - Cod. Tabela Preço                        ³
//³1,3,n,7  - TES                                      ³
//³1,3,n,8  - Desconto financeiro                      ³
//³1,3,n,9  - Local                                    ³
//³1,3,n,10 - Filial da necessidade                    ³
//³1,4 - Condicao Pagamento                            ³
//³1,5 - Desconto 1                                    ³
//³1,6 - Desconto 2                                    ³
//³1,7 - Filial de entrega                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInc := 1 To Len( aCampos )
	For nCampos := 1 to Len( aCampos[nInc, 3] )
		If Empty( aCampos[nInc,3,nCampos,1] ) .AND. !Empty(aCampos[nInc,3,nCampos,2] )  //Sem cod. Prod. e com Quantidade
			If ltela
				MsgStop("No retorno do pedido "+ aCampos[nInc,1]+ " Não encontrado codigo de produto em alguns itens (eles não serão processados).  Codigo de Barra = "+ aCampos[nInc,3,nCampos,2] +" . Codigo do Produto no fornecedor = "+ aCampos[nInc,3,nCampos,3], "Atencao" )
			EndIf

			T_EDIGrvLog( "No retorno do pedido "+ aCampos[nInc,1]+ " Não encontrado codigo de produto em alguns itens (eles não serão processados).  Codigo de Barra = "+ aCampos[nInc,3,nCampos,2] +" . Codigo do Produto no fornecedor = "+ aCampos[nInc,3,nCampos,3], cArqLogRet )
			lerro := .T.
		EndIf
	Next
Next
If !lRet
	Return lRet
Endif

If ltela
	lRet := MsgYesNo(	"Confirma o processamento do arquivo de retorno de pedido de compras do Fornecedor, para a atualização do cadastro " +;
						"de pedido de compras e geração de novos pedidos para o proximo fornecedor caso existam itens não atendidos ou " +;
						"atendidos parcialmente ?")
EndIf

If lRet
	If ltela
		ProcRegua( Len( aCampos ) )
	EndIf
	Begin Transaction

	DbSelectArea("SC7")
	DbSetOrder(4)

	For nItem := 1 to Len(aCampos)  //Qtde de Pedidos de compras a processar.
		If ltela
			IncProc()
		EndIf

		cNumPed    := aCampos[nItem][1]
		lRetornoOK := .T.
		
		If ! aCampos[nItem][8]   // Numero de pedido invalido ou ja processado o seu retorno
			cTxtLog := "Numero de pedido " + cNumPed +" invalido ou o seu retorno ja foi processado anteriormente "
			T_EDIGrvLog(cTxtLog, cArqLogRet)	

			lerro := .T.

			Loop
		EndIf
		
		// Na rotina abaixo consolido itens de pedido com o mesmo Cod. Prod. para facilitar processamento
		aCampos3Aux := {}
		For nInc := 1 to Len(aCampos[nItem][3])
			nPosProd   := Ascan(aCampos3Aux,{|x| x[1] == aCampos[nItem][3][nInc][1] .AND. x[10] == aCampos[nItem][3][nInc][10] })
			If nPosProd == 0
				aAdd( aCampos3Aux, aCampos[nItem][3][nInc] )
				aCampos3Aux [ Len(aCampos3Aux) ][4]  := Val( aCampos3Aux [ Len(aCampos3Aux) ][4] )
			Else
				aCampos3Aux [nPosProd][4] += Val(aCampos[nItem][3][nInc ][4] )
			EndIf
		Next
		
		aCampos[nItem][3] := aCampos3Aux
		
		cNumDoc := ""
		For nInc := 1 to Len(aCampos[nItem][3])
			DbSelectArea("SC7")
			DbSetOrder(4)
			If DbSeek( xFilial("SC7") + aCampos[nItem][3][nInc][1] + aCampos[nItem][1]  )
				cOldForn := SC7->C7_FORNECE
				cOldLoja := SC7->C7_LOJA
				While SC7->C7_PRODUTO+SC7->C7_NUM == aCampos[nItem][3][nInc][1] + aCampos[nItem][1]
					If !QtdNAtend
						nQtdeAt += aCampos[nItem][3][nInc][4]   						 
					Else 
						nQtdeAt += SC7->C7_QUANT - aCampos[nItem][3][nInc][4]
					EndIf	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para casos em que o arquivo enviado pelo Fornecedor³
					//³contem a quantidade maior que a quantidade contida no         ³
					//³pedido de compra                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aCampos[nItem][3][nInc][4] > SC7->C7_QUANT
						aCampos[nItem][3][nInc][4] := SC7->C7_QUANT
					Endif 
					If !QtdNAtend  //Calculo quantidade ainda a atender
						aCampos[nItem][3][nInc][4] -= SC7->C7_QUANT     
					EndIf
					DbSkip()
				End
				If !QtdNAtend // Passo para positivo p/ facilitar manipulacao
					aCampos[nItem][3][nInc][4] :=aCampos[nItem][3][nInc][4]* -1  
				EndIf 
			    //Nova quantidade para o documento original
				aCampos[nItem][3][nInc][5] := nQtdeAt 
				nQtdeAt := 0
				If aCampos[nItem][3][nInc][4] > 0  // Existe qtd de produto que não foi atendida
					DbSeek( xFilial("SC7") + aCampos[nItem][3][nInc][1] + aCampos[nItem][1] )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Determina o  PC original onde foi criada a  lista ³
					//³ de prioridades.                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cPedOrig := SC7->C7_ORIGPED
					If Empty( cPedOrig )
						cPedOrig := SC7->C7_NUM
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza a lista de prioridade e retorna o proximo³
					//³ fornecedor.                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aNxtFor := GetNxtFor( cPedOrig, SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_PRODUTO )
					If Len( aNxtFor ) > 0
						cFornece 	:= aNxtFor[1]
						cLojaForn	:= aNxtFor[2]
						lProxNivel  := .T.
						_lAchouAIA  := .F.

						If AIA->(DbSeek(xFilial("AIA") +cFornece +cLojaForn ))
							// Para processar somente quando tab. Preço estiver dentro da data de
							// validade, mover esta linha para dentro do while.
							While cFornece +cLojaForn = AIA->AIA_CODFOR +AIA->AIA_LOJFOR
								_dAiaDatATe := If( Empty(AIA->AIA_DATATE) , ctod("31/12/2020") , AIA->AIA_DATATE)
								If AIA->AIA_DATDE <= ddatabase .AND. _dAiaDatATe >= ddatabase
									_lAchouAIA  := .T.  // Existe Tab. Preço dentro do periodo de validade neste fornec.
									Exit
								EndIf
	
								AIA->( DbSkip() )
							End
						EndIf
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Tem fornecedor  no proximo  nivel porem nao tem tabela  de ³
						//³ preco                                                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !_lAchouAIA .AND. lProxNivel
							cTxtLog := "Nao encontrada Tab. Preco para o fornecedor " + cFornece + "-" + cLojaForn
							T_EDIGrvLog( cTxtLog, cArqLogRet )
	
							lerro := .T.
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza a variavel com o numero do proximo PC e saldo qtd ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cItem     := StrZero( nInc, TamSX3( "C7_ITEM" )[1] )
						nContaQtd := aCampos[nItem][3][nInc][4]
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Alimenta o array para gravacao do SC7                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea( "SC7" )
						While SC7->C7_PRODUTO + SC7->C7_NUM == aCampos[nItem][3][nInc][1] + aCampos[nItem][1]
							DbSelectArea("AIB")
							DbSetOrder(2)
	
							If AIB->( DbSeek( xFilial( "AIB" ) + cFornece + cLojaForn + AIA->AIA_CODTAB + SC7->C7_PRODUTO ) ) .AND. AIB->AIB_PRCCOM > 0
								nNovoPreco := AIB->AIB_PRCCOM
							Else
								nNovoPreco := SC7->C7_PRECO
							EndIf
	
							If Empty( cNumDoc )
								cNumDoc := CriaVar( "C7_NUM" )
							EndIf
							
							aAdd( aSC7,	{	{ "C7_FORNECE"  , cFornece			, Nil },;  // 01-Codigo do Fornecedor
											{ "C7_LOJA"		, cLojaForn	 		, Nil },;  // 02-Loja do Fornecedor
											{ "C7_FILIAL"	, xFilial( "SC7" )	, Nil },;  // 03-Filial
											{ "C7_NUM"		, cNumDoc			, Nil },;  // 04-Numero do Pedido
											{ "C7_PRODUTO"	, SC7->C7_PRODUTO	, Nil },;  // 05-Codigo do Produto
											{ "C7_ITEM"		, cItem				, Nil },;  // 06-Numero do Item
											{ "C7_UM"		, SC7->C7_UM		, Nil },;  // 07-Unidade de Medida
											{ "C7_QUANT"	, nContaQtd			, Nil },;  // 08-Quantidade
											{ "C7_CODTAB"	, AIA->AIA_CODTAB	, Nil },;  // 09-Tab. de Preco (com .T. para não validar pois na troca de fornecedor o codigo da tabela fica invalido)
											{ "C7_TES"		, SC7->C7_TES		, Nil },;  // 10-TES
											{ "C7_EMISSAO"	, dDataBase			, Nil },;  // 11-Data De Entrega
											{ "C7_DATPRF"	, dDataBase			, Nil },;  // 12-Data De Entrega
											{ "C7_FLUXO"	, SC7->C7_FLUXO		, Nil },;  // 13-Fluxo de Caixa (S/N)
											{ "C7_OBS"		, SC7->C7_OBS		, Nil },;  // 14-Obse
											{ "C7_TIPO"		, SC7->C7_TIPO		, Nil },;  // 15-Tipo
											{ "C7_PRECO"	, nNovoPreco		, Nil },;  // 16-Preco
											{ "C7_ORIGEM"	, "DROPEDIR"		, Nil },;  // 17-Origem
											{ "C7_LOCAL"	, SC7->C7_LOCAL		, Nil },;  // 18-Localizacao
											{ "C7_ORIGPED"	, cPedOrig			, Nil },;  // 19-Pedido Original
											{ "C7_FILENT"	, SC7->C7_FILENT 	, Nil },;  // 20-Filial de Entrega
											{ "C7_BONUS"	, IIF(lC7Bonus, SC7->C7_BONUS,"")		, Nil },;  // 21-Bonificacao?       
											{ "C7_COND"	    , SC7->C7_COND 		, Nil }} ) // 22-Condicao de pagamento
	
							If !lProxNivel
								cTxtLog := "No pedido "+ AllTrim( aCampos[nItem][1] ) + ", enviado originalmente para "+ cOldForn + "-" + cOldLoja + " nao foi encontrado para o produto "+ AllTrim( aCampos[nItem][3][nInc][1] ) + ". O pedido de compra com o saldo deste produto foi gerado para o fornecedor conforme prioridade. "
								T_EDIGrvLog(cTxtLog , cArqLogRet )
	
								lerro := .T.
							EndIf
	
							SC7->( DbSkip() )
						End
					Else
						aAdd( aRelat, { SC7->C7_NUM, SC7->C7_PRODUTO, aCampos[nItem][3][nInc][4] } )
						nQtdPend++
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Determina o  PC original onde foi criada a  lista ³
					//³ de prioridades.                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSeek( xFilial("SC7") + aCampos[nItem][3][nInc][1] + aCampos[nItem][1] )
					cPedOrig := SC7->C7_ORIGPED
					If Empty( cPedOrig )
						cPedOrig := SC7->C7_NUM
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o  status do fornecedor  que atendeu  ao  PC  na ³
					//³ tabela de prioridades.                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea( "LKC" )
					DbSetOrder( 2 )  // Pedido+Fornecedor+Loja+Produto
					If LKC->( DbSeek( xFilial( "LKC" ) + cPedOrig + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_PRODUTO ) )
						RecLock( "LKC" )
						REPLACE LKC->LKC_STATUS WITH "A"      // "A"=Atendido;"R"=Remanejado
						MsUnLock( "LKC" )
					EndIf
				EndIf
			Else
				If ltela
					MsgStop("Produto "+ aCampos[nItem][3][nInc][1]+ "Nao foi encontrado no pedido "+ aCampos[nItem][1]  ,"ATENCAO" )
				EndIf

				T_EDIGrvLog( "Produto "+ aCampos[nItem][3][nInc][1]+ "Nao foi encontrado no pedido "+ aCampos[nItem][1] , cArqLogRet )
				aCampos[nItem][3][nInc][4] := 0
				
				lerro := .T.
			EndIf
		Next

		If !lerro
			aCab   := {}
			aItens := {}
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza a gravacao do pedido de compras                   ³
			//³ 1- Monta o cabecalho e itens para gravacao do novo PC     ³
			//³ 2- Monta o cabecalho e itens para ajustes do PC anterior  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "SC7" )
			For nInc := 1 To Len( aSC7 )
				aCamposC7 := aSC7[ nInc ] 
				aQtdAtFor := aCampos[1][3][nInc]
				
				If nInc == 1
					aAdd( aCab, { "C7_FORNECE", aCamposC7[01][2],	Nil } )  // 01-Codigo do Fornecedor
					aAdd( aCab, { "C7_LOJA", 	aCamposC7[02][2],	Nil } )  // 02-Loja do Fornecedor  
					aAdd( aCab, { "C7_NUM", 	aCamposC7[04][2],	Nil } )  // 03-Numero do Pedido    
					aAdd( aCab, { "C7_EMISSAO", dDataBase, 			Nil } )  // 04-Data De Entrega     
					aAdd( aCab, { "C7_DATPRF", 	dDataBase, 			Nil } )  // 05-Data De Entrega     
					aAdd( aCab, { "C7_FILENT", aCamposC7[20][2], 	Nil } )  // 06-Filial de Entrega
					aAdd( aCab, { "C7_COND",	aCamposC7[22][2], 	Nil } )  // 07-Condicao de Pagamento
					aAdd( aCab, { "C7_CONTATO", SC7->C7_CONTATO, 	Nil } )  // 08-Contato
					aAdd( aCab, { "C7_DESC1", 	SC7->C7_DESC1,		Nil } )  // 09-Desconto 1
					aAdd( aCab, { "C7_DESC2", 	SC7->C7_DESC2,		Nil } )  // 10-Desconto 2
				EndIf

				aAux := {}
                aAdd( aAux, { "C7_NUM"      , aCamposC7[04][2]   		            , Nil } )  // 01-Numero do Pedido
                aAdd( aAux, { "C7_PRODUTO"  , aCamposC7[05][2]     	            , Nil } )  // 02-Codigo do Produto
                aAdd( aAux, { "C7_UM"       , aCamposC7[07][2]  		            , Nil } )  // 03-Unidade de Medida
                aAdd( aAux, { "C7_QUANT"    , aCamposC7[08][2]   		            , Nil } )  // 04-Quantidade
                aAdd( aAux, { "C7_CODTAB"   , aCamposC7[09][2]    		            , Nil } )  // 05-Tab. de Preco (com .T. para não validar pois na troca de fornecedor o codigo da tabela fica invalido)
                aAdd( aAux, { "C7_TES"      , aCamposC7[10][2]       		        , Nil } )  // 06-TES
                aAdd( aAux, { "C7_EMISSAO"  , aCamposC7[11][2]      		        , Nil } )  // 07-Data De Entrega
                aAdd( aAux, { "C7_DATPRF"   , aCamposC7[12][2]  		            , Nil } )  // 08-Data De Entrega
                aAdd( aAux, { "C7_FLUXO"    , aCamposC7[13][2]      		        , Nil } )  // 09-Fluxo de Caixa (S/N)
                aAdd( aAux, { "C7_OBS"      , aCamposC7[14][2]   			        , Nil } )  // 10-Obse
                aAdd( aAux, { "C7_TIPO"     , aCamposC7[05][2]         		    , Nil } )  // 11-Tipo
                aAdd( aAux, { "C7_PRECO"    , aCamposC7[16][2]     		        , Nil } )  // 12-Preco
                aAdd( aAux, { "C7_VLTOTAL"  , aCamposC7[08][2] * aCamposC7[16][2] , Nil } )  // 13-Valor total do Item
                aAdd( aAux, { "C7_ORIGEM"   , "DROPEDIR"              		        , Nil } )  // 14-Origem
                aAdd( aAux, { "C7_LOCAL"    , aCamposC7[18][2]    			        , Nil } )  // 15-Localizacao
                aAdd( aAux, { "C7_ORIGPED"  , aCamposC7[19][2]   		            , Nil } )  // 16-Pedido Original
                aAdd( aAux, { "C7_FILENT"   , aCamposC7[20][2]      		        , Nil } )  // 17-Filial de Entrega
                If lC7Bonus  
                	aAdd( aAux, { "C7_BONUS"    , SC7->C7_BONUS       		            , Nil } )  // 18-Bonificacao?  
                EndIf
				aAdd( aItens, aClone( aAux ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Altera a quantidade do pc conforme disponibilidade do     ³
				//³ fornecedor.                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC7->( DbSetOrder( 4 ) )
				If SC7->( DbSeek( xFilial( "SC7" ) + aCamposC7[05][2] + aCamposC7[19][2] ) )
					aCabAlt   := {}
                    aAdd( aCabAlt, { "C7_FORNECE", SC7->C7_FORNECE,		Nil } )  // 01-Codigo do Fornecedor
                    aAdd( aCabAlt, { "C7_LOJA", 	SC7->C7_LOJA,		Nil } )  // 02-Loja do Fornecedor  
                    aAdd( aCabAlt, { "C7_NUM", 		SC7->C7_NUM,		Nil } )  // 03-Numero do Pedido    
					aAdd( aCabAlt, { "C7_EMISSAO", SC7->C7_EMISSAO,		Nil } )  // 04-Data De Entrega     
					aAdd( aCabAlt, { "C7_DATPRF", 	SC7->C7_EMISSAO,	Nil } )  // 05-Data De Entrega     
					aAdd( aCabAlt, { "C7_FILENT", 	SC7->C7_FILENT, 	Nil } )  // 06-Filial de Entrega
					aAdd( aCabAlt, { "C7_COND",		SC7->C7_COND,		Nil } )  // 07-Condicao de Pgto  
					aAdd( aCabAlt, { "C7_CONTATO", 	SC7->C7_CONTATO, 	Nil } )  // 08-Contato
					aAdd( aCabAlt, { "C7_DESC1", 	SC7->C7_DESC1,		Nil } )  // 09-Desconto 1
					aAdd( aCabAlt, { "C7_DESC2", 	SC7->C7_DESC2,		Nil } )  // 10-Desconto 2

					aAux := {}
					aAdd( aAux, { "C7_PRODUTO", aCamposC7[05][2]  ,	Nil } )  // 01-Codigo do Produto
					aAdd( aAux, { "C7_QUANT", 	aQtdAtFor[5]	   ,	Nil } )  // 02-Quantidade
					If lC7Bonus
						aAdd( aAux, { "C7_BONUS", 	SC7->C7_BONUS      ,	Nil } )  // 03-Bonificacao?   
					EndIf
					aAdd( aItensAlt, aClone( aAux ) )
				EndIf
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inclui o novo pedido de compra.                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( aCab ) .AND. !Empty( aItens )  
                SB1->(DbSetOrder(1))
                SB1->(DbSeek(xFilial("SB1") ))  //posiciona no primeiro registro do SB1 pois nao esta encontrando o produto no execauto
				MSExecAuto( {|v,x,y,z| MATA120(v,x,y,z) }, 1, aCab, aItens, 3 )
				cPcsEnv += aCab[03][2] + ", "
			EndIf
			If lMsErroAuto
				RollBackSX8() 
				DisarmTransaction() 
				Exit
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera a qtde do pedido de compra antigo e o encerra      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If !Empty( aCabAlt ) .AND. !Empty( aItensAlt )    
			    SB1->(DbSetOrder(1))
                SB1->(DbSeek(xFilial("SB1") )) //posiciona no primeiro registro do SB1 pois nao esta encontrando o produto no execauto
				MSExecAuto( {|v,x,y,z| MATA120(v,x,y,z) }, 1, aCabAlt, aItensAlt, 4 )
				cPcsAtu += aCabAlt[03][2] + ", "
			EndIf
            
			If lMsErroAuto 
				RollBackSX8()
				DisarmTransaction() 
				Exit
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o array do resultado do processamento.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nRes := 1 To Len( aItensAlt ) 
				nQtdAte := aItens[nRes][04][02]
				nQtdAlt := aItensAlt[nRes][02][02]

				aAdd( aResult, { aCabAlt[03][2], aItensAlt[nRes][01][02], Transform( nQtdAlt, "@e 9,999.99" ), aCab[03][2], Transform( nQtdAte, "@e 9,999.99" ) } )
			Next nRes
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Confirma numero utilizado para criacao do PC nesta rotina ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lErro
			ConfirmSX8( .T. )
		Else
			RollBackSX8()
		EndIf
	Next  
	
	End Transaction   //Fim da Transacao
    
    If lMsErroAuto 
	    Mostraerro()
	endif	   
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunta se deseja emitir relatorio se  algum produto nao ³
//³ tenha  sido  atendido  pelos  fornecedores  da  lista  de ³
//³ prioridade.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nQtdPend > 0
	If MsgYesNo( "Foi detectado que algum produto nao foi atendido. Deseja emitir um relatorio?" )
		T_DroRel01( aRelat )
	EndIf
EndIf

If lerro
	_cMSG	:= "Foram encontradas algumas inconsistências no processamento."+;
	"VerIfique o arquivo de LOG gerado em "+GetSrvProfString("STARTPATH","")+"RetornoEDIPC.log no servidor."
	If ltela
		MsgAlert( _cMSG )
	EndIf
	T_EDIGrvLog( _cMSG , cArqLogRet )
EndIf

Return( lRet )


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
	cTxtLog  += "ou o valor do arquivo do retorno do fornecedor deve indicar as casas decimais."
	T_EDIGrvLog(cTxtLog, cArqLogRet)
	lRet  := .F.
Else
	//Acrescenta ponto(".") como separador de decimais
	cTemp      := Stuff(PADL(AllTrim(cTemp),Len(cValor)),Len(cValor)-nQtdDecimais+1,0,".")
	nValorExp  := Val(cTemp)
EndIf
Return (lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³AjustLHU ³ Autor ³Geronimo B. Alves      ³ Data ³ 30/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua tratamento para que campo LHU_SALPED reflita as alterações do PC correspondente  ³±±
±±³          ³ pois suas informações são necessarias para o calculo da necessidade de cada filial  ³±±
±±³          ³ na central de compra    ³±±
±±³          ³ Obs. Como para os itens não atendidos será gerado um novo   ³±±
±±³          ³ PC estes itens devem ser excluidos ou ajustados e os seus     ³±±
±±³          ³ respectivos LHU_SALPED tambem                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Recebe parametro _nQtdDelet que indica a quantidade retornada como atendida e que deve ser      ³±±  
±±³          ³   atualizada no LHU_SALPED                                                                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function AjustLHU( _nQtdDelet )

Local nRecSC7	:= recno()
Local aArea		:= GetArea()

dbselectarea("LHU")
DBSETORDER(1)

// Registro da Filial -> Decremento LHU_SALPED 
dbselectarea("LHU")
If DbSeek( xFilial("LHU") + xFilial("SC7") + SC7->C7_NUM+ SC7->C7_ITEM+ SC7->C7_SEQUEN )

	lAglutina := ( LHU->LHU_AGLUTI == "S" )
	cChaveLhu := XFILIAL("LHU")  + XFILIAL("SC7") + SC7->C7_NUM+ SC7->C7_ITEM+ SC7->C7_SEQUEN
	while ! eof() .and. cChaveLhu == XFILIAL("LHU") + XFILIAL("SC7") + LHU->LHU_NUM+ LHU->LHU_ITEM+ LHU->LHU_SEQUEN
		if LHU->LHU_AGLUTI = "S" .AND. 	LHU->LHU_SALPED > 0
			_nQtdDelAux := if( LHU->LHU_SALPED < _nQtdDelet  ,  LHU->LHU_SALPED , _nQtdDelet )			// Para nao abater qtd maior que existente no campo
			_nQtdDelet -= _nQtdDelAux

			RecLock("LHU",.F.)
			LHU->LHU_SALPED -= _nQtdDelAux					// Ajusto campo para corresponder ao seu novo valor de C7_QUANT
			MsUnLock()
		endif
		Dbskip()
	End

endif

RestArea(aArea)
dbgoto(nRecSC7)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³AltPcAtual ³ Autor ³Geronimo B. Alves      ³ Data ³ 30/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Recebo numero do pedido e executo uma alteração pela rotina ³±±
±±³          ³automatica e pelos gatilhos disparados forcar a atualizacão ³±±
±±³          ³dos campos de totais e de impostos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Recebe parametro cNumDoc. Numero do PC  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function AltPcAtual( cNumDoc )		// Gero pela rotina automatica do mata120 a alteração do PC atual para ajustar seus valores e impostos

Local nRecSC7		:= recno()
Local aArea			:= GetArea()
Local aCab			:= {}
Local aItens			:= {}
Local cChaveSC7	:= ""
Local nTotPedido	:= 0
Local nComDesconto := 0
Local nPcComDesconto := 0
Local nAIADESC1 := 0
Local nAIADESC2 := 0
Local nAIADESCFI := 0
Local nDescMercadoria := 0
Local nDescFinPC := 0
Local nLeAitem		:= 1
Local cMsgObs		:= ""
Local nC7ComDesc	:= 0
Local nC7_VLDESC	:= 0
Local nRecAIA := AIA->( recno() )
				
SC7->(DbSetOrder(1))
if SC7->(DbSeek(xFilial("SC7")+ cNumDoc ))
	aCab		:=	{{"C7_NUM" , cNumDoc  						,Nil},; // Numero do Pedido
						{ "C7_EMISSAO" , SC7->C7_EMISSAO			,Nil},; // Data de Emissao
						{ "C7_FORNECE" , SC7->C7_FORNECE		,Nil},; // Fornecedor
						{ "C7_LOJA"    , SC7->C7_LOJA		,Nil},; // Loja do Fornecedor
						{ "C7_COND"    , SC7->C7_COND					,Nil},; // Condicao de pagamento
						{ "C7_CONTATO" , SC7->C7_CONTATO			,Nil},; // Contato
						{ "C7_DESC1"   , SC7->C7_DESC1				,Nil},; //*** Desconto 1 da Tabela de Preços
						{ "C7_DESC2"   , SC7->C7_DESC2				,Nil},; //*** Desconto 2 da Tabela de Preços
						{ "C7_FILENT"  , SC7->C7_FILENT					,Nil}}  // Filial Entrega
    
	nAIADESC1			:= SC7->C7_DESC1
	nAIADESC2			:= SC7->C7_DESC2
	nAIADESCFI			:= SC7->C7_DESCFIN
	cChaveSC7 := xFilial("SC7")+ cNumDoc
	While ! Eof() .and. cChaveSC7 == xFilial("SC7")+ cNumDoc

		nC7ComDesc		:= SC7->C7_QUANT * SC7->C7_PRECO
		nC7_VLDESC		:= 0
		If nAIADESC1 > 0  .and. nC7ComDesc > 0
			nC7_VLDESC	+= nC7ComDesc / 100 * nAIADESC1
			nC7ComDesc	-= nC7ComDesc / 100 * nAIADESC1
		Endif

		If nAIADESC2 > 0 .and. nC7ComDesc > 0
			nC7_VLDESC	+= nC7ComDesc / 100 * nAIADESC2
			nC7ComDesc	-= nC7ComDesc / 100 * nAIADESC2
		Endif			
	
		aadd(aItens ,	{{"C7_FORNECE"  , SC7->C7_FORNECE		,Nil},; //Numero do Item
					{ "C7_LOJA"	  , SC7->C7_LOJA	 				,Nil},; //Codigo do Produto
					{ "C7_PRODUTO", SC7->C7_PRODUTO		,Nil},; //Codigo do Produto
					{ "C7_UM"     , SC7->C7_UM						,Nil},; // Após criar e utilizar ponteiros para esta array, excluir este elemento (desnecessario) sem desposicionar os demais elementos 
					{ "C7_UM"     , SC7->C7_UM						,Nil},; //Unidade de Medida
					{ "C7_QUANT"  , SC7->C7_QUANT				,Nil},; //Quantidade
					{ "C7_CODTAB" , SC7->C7_CODTAB			,Nil},; //Tab. de Preco (com .T. para não validar pois na troca de fornecedor o codigo da tabela fica invalido)
					{ "C7_TES"    , SC7->C7_TES					,Nil},; //TES
					{ "C7_DATPRF" , SC7->C7_DATPRF			,Nil},; //Data De Entrega
					{ "C7_DESCFIN", SC7->C7_DESCFIN			,Nil},; //*** Desconto Financeiro
					{ "C7_FLUXO"  , SC7->C7_FLUXO				,Nil},; //Fluxo de Caixa (S/N)
					{ "C7_OBS"	  , SC7->C7_OBS					,Nil},;
					{ "C7_TIPO"   , SC7->C7_TIPO					,Nil},; //PC
					{ "C7_PRECO"  , SC7->C7_PRECO			,Nil},; //Preco
					{ "C7_ORIGEM" , SC7->C7_ORIGEM			,Nil},;
					{ "C7_LOCAL"  , SC7->C7_LOCAL				,Nil},; //Localizacao
					{ "C7_NUM"    , SC7->C7_NUM 					,Nil},; //Numero do pedido
					{ "C7_VLRDFIN"    , SC7->C7_VLRDFIN		,Nil},; // Valor total do desconto financeiro no pedido
					{ "C7_VLTOTAL"    , SC7->C7_QUANT * SC7->C7_PRECO		,Nil},; // Valor total do Item
					{ "C7_ENVIAR"    , SC7->C7_ENVIAR				,Nil},; // Valor desconto do Item
					{ "C7_FORNEDI"    , SC7->C7_FORNEDI		,Nil},; // Valor desconto do Item
					{ "C7_LOJAEDI"    , SC7->C7_LOJAEDI			,Nil},; // Valor desconto do Item
					{ "C7_VLDESC"    , nC7_VLDESC				,Nil}}) // Valor desconto do Item
					
		nComDesconto		+= nC7ComDesc
		nDescMercadoria	+= nC7_VLDESC

		dbskip()
	Enddo

	if ! empty( aItens )

		// nas linhas abaixo calculo e gravo nos itens o desconto da mercadoria e financeiro do PC atual.
		If nAIADESCFI > 0 .and. nComDesconto > 0
			nDescFinPC :=  nComDesconto  / 100 * nAIADESCFI
		Endif

		cMsgObs	:=  if(nDescFinPC			> 0 , "Desconto Financeiro de R$ " +alltrim( transform( nDescFinPC , '@E 999,999,999.99' ) )  , "Sem Desconto Financeiro" )
		cMsgObs	+= "."+ space(4)+  if(nDescMercadoria	> 0 , 	"Desconto na Mercadoria de R$ " + alltrim( transform( nDescMercadoria , '@E 999,999,999.99' ) ) , "Sem Desconto na Mercadoria" )
				
		// Nas linhas abaixo gravo nos itens os descontos e a observação
		For nLeAitem = 1 to len(aItens)
			if nLeAitem == 1
				aItens [ 1] [12] [2] := cMsgObs
			endif
			aItens [nLeAitem] [18] [2] := nDescFinPC
		Next

		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItens , 4)
	endif
endif

AIA->( dbgoto(nRecAIA) )
RestArea(aArea)
dbgoto(nRecSC7)

Return

 */
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Alim_Afili³ Autor ³Geronimo B. Alves      ³ Data ³ 08/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devo alimentar a array aFilialpro para ajustar corretamente³±±
±±³          ³ o rateio do lhu (necessidades das filiais)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array aFilialpro preenchida                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Recebe parametros aItem array com os itens do novo PC criado³±±
±±³          ³ e cNumDoc. Numero do PC retornado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function Alim_Afili( aItem , cNumDoc )
Local _nItensPC
Local nRecSC7	:= recno()
Local aArea		:= GetArea()
Local nPosProduto

dbselectarea("LHU")
DbSetOrder(1)
dbselectarea("SB1")
DbSetOrder(1)
dbselectarea("SC7")
DbSetOrder(4)
For _nItensPC = 1 to len(aItem)
	if SC7->( DbSeek( xfilial("SC7") + aItem[ _nItensPC, 3 ,2] + cNumDoc + aItem[ _nItensPC, 1 ,2] ) )

		dbselectarea("LHU")
		cChaveLHU := XFILIAL("LHU") + XFILIAL("SC7") + SC7->C7_NUM+ SC7->C7_ITEM+ SC7->C7_SEQUEN
		LHU-> ( MsSeek( cChaveLHU ) )		
		SB1-> ( MsSeek( XFILIAL("SB1") +  SC7->C7_PRODUTO) )

		While ! eof() .and.  xfilial("LHU") + LHU->LHU_FILPED + LHU->LHU_NUM + LHU->LHU_ITEM + LHU->LHU_SEQUEN ==  cChaveLHU
			                      
			nPosProduto := len(aFilialpro) + 1
			if lAglutina
				For nPosProduto = 1 to len(aFilialpro)
					if aFilialpro [nPosProduto] [ 2 ] == LHU->LHU_PRODUT
						exit
					endif
				Next
			endif
				
			if lAglutina .and. nPosProduto <= len(aFilialpro)
				aFilialpro[ nPosProduto ] [ 5 ]  += LHU->LHU_QTDPEDI- LHU->LHU_SALPEDI
				aadd(aFilialpro[ nPosProduto ] [ 13 ]  , {  LHU->LHU_FILNEC , LHU->LHU_QTDPEDI- LHU->LHU_SALPEDI  } )
			else
						//                     Cod. Filial,         	Cod. Produto,     			Local,                     Descricao Produto,    Quantidade
				aadd( aFilialpro, { LHU->LHU_FILIAL , LHU->LHU_PRODUT,  LHU->LHU_LOCAL, LHU->LHU_DESCRI,  LHU->LHU_QTDPEDI- LHU->LHU_SALPEDI , ;
				SB1->B1_UM,  SB1->B1_SEGUM , ConvUm(LHU->LHU_PRODUT, LHU->LHU_SALPEDI ) ,  SC7->C7_QUANT ,  SC7->C7_PRECO  ,;
				SC7->C7_TES , SB1->B1_CODFAB+SB1->B1_LOJA ,  {  { LHU->LHU_FILNEC , LHU->LHU_QTDPEDI- LHU->LHU_SALPEDI }  }  } )
			endif
			DbSkip()
		Enddo		
	Endif
Next

RestArea(aArea)
dbgoto(nRecSC7)

Return aFilialpro

 */
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CalcDescon ³ Autor ³Geronimo B. Alves      ³ Data ³ 14/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo desconto da mercadoria e financeiro, alem de montar a mesagem para o campo C7_OBS.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array aFilialpro preenchida                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Recebe parametros aItem array com os itens do novo PC criado e cNumDoc. Numero do PC retornado  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function CalcDescon( nTotPedido, nDesc1, nDesc2, nDescFIN )
Local nTotDescFin := 0
Local nDescMercadoria		:= 0
Local nC7ComDesc		:= nTotPedido

aObsDescont := {}

If nDesc1 > 0  .and. nC7ComDesc > 0
	nDescMercadoria	:= nC7ComDesc / 100 * nDesc1
	nC7ComDesc	-= nC7ComDesc / 100 * nDesc1
Endif

If nDesc2 > 0 .and. nC7ComDesc > 0
	nDescMercadoria	+= nC7ComDesc / 100 * nDesc2
	nC7ComDesc	-= nC7ComDesc / 100 * nDesc2
Endif			

If nDescFIN > 0 .and. nC7ComDesc > 0
	nTotDescFin :=  nC7ComDesc  / 100 * nDescFIN
Endif

cMsgObs	:=  if(nTotDescFin			> 0 , "Desconto Financeiro de R$ " +alltrim( transform( nTotDescFin , '@E 999,999,999.99' ) )  , "Sem Desconto Financeiro" )
cMsgObs	+= "."+ space(4)+  if(nDescMercadoria	> 0 , 	"Desconto na Mercadoria de R$ " + alltrim( transform( nDescMercadoria , '@E 999,999,999.99' ) ) , "Sem Desconto na Mercadoria" )
				
aObsDescont := { cMsgObs, nTotPedido, nC7ComDesc, nDesc1, nDesc2, nDescFIN, nTotDescFin }
Return
*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Program   ³LblPCAtu ³ Autor ³Geronimo B. Alves      ³ Data ³ 21/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta label com os numeros dos PCs que					  ³±±
 				foram alterados pelo retorno do EDI  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Label atualizadas com os PCs atualizados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Recebe parametro numero do pedido atualizado  			  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function LblPCAtu( cNumped )

if ! ( cNumped $ cPCsAtu )
	cPCsAtu += cNumped + " ,  "
endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ GetNxtFor ³ Autor ³ Totvs                ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para retornar o fornecedor conforme a lista de      ³±±
±±³          ³ prioridades onde o sistema deve gerar um novo Pedido de    ³±±
±±³          ³ Compra com o saldo dos produtos nao atendidos no Pedido    ³±±
±±³          ³ de Compra anterior.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetNxtFor( cPedOrig, cForn, cLoja )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do PC original                              ³±±
±±³          ³ ExpC2 = Codigo do Fornecedor do PC anterior                ³±±
±±³          ³ ExpC3 = Loja do Fornecedor do PC anterior                  ³±±
±±³          ³ ExpC4 = Codigo do Produto com saldo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³                      									  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetNxtFor( cPedOrig, cForn, cLoja, cProduto )
Local aReturn := {}		//Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizar o status do fornecedor cujo pedido foi  ³
//³ gerado  anteriormente mas  nao  foi atendido  ou  ³
//³ parcialmente atendido.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "LKC" )
DbSetOrder( 2 )  // Pedido+Fornecedor+Loja+Produto
If LKC->( DbSeek( xFilial( "LKC" ) + cPedOrig + cForn + cLoja + cProduto ) )
	RecLock( "LKC" )
	REPLACE LKC->LKC_STATUS WITH "R"      // "A"=Atendido;"R"=Remanejado
	MsUnLock( "LKC" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza  o  proximo  fornecedor  da  lista  de   ³
//³ prioridade.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSetOrder( 1 )  // Pedido+Produto+Sequencia
If  LKC->( DbSeek( xFilial( "LKC" ) + cPedOrig + cProduto ) )
	While LKC->( !Eof() ) .AND. LKC->LKC_FILIAL == xFilial( "LKC" ) .AND. LKC->LKC_PEDIDO == cPedOrig .AND. LKC->LKC_PRODUT == cProduto
		If Empty( LKC->LKC_STATUS )
			aAdd( aReturn, LKC->LKC_FORNEC )        // 01-Codigo do Fornecedor
			aAdd( aReturn, LKC->LKC_LOJA   )        // 02-Loja
		EndIf
		
		LKC->( DbSkip() )
	End
Endif
Return aReturn