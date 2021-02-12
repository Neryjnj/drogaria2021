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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DROCARTDEPºAutor  ³Fernando Machima    º Data ³  04/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de numero de plasticos(cartoes) para dependente    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template Drogaria                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Template Function DROCARTDEP()
Local oWizard
Local oPanel
Local cText :=	'Este programa irá gerar e atribuir os números dos cartões aos dependentes.' + CTRL + CTRL + CTRL + ;
	  			'Para continuar clique em Avançar.'
Local bValid
Local nTamCod   := TamSX3("A1_COD")[1]
Local nTamLoja  := TamSX3("A1_LOJA")[1]

Private cBLinFil    := ""
Private oOk		    := LoadBitMap(GetResources(), "LBOK")
Private oNo		    := LoadBitMap(GetResources(), "LBNO")
Private oNever	    := LoadBitMap(GetResources(), "DISABLE")
Private cCodCliIni := Space(nTamCod)
Private cLojCliIni := Space(nTamLoja)
Private cCodCliFim := Space(nTamCod)
Private cLojCliFim := Space(nTamLoja)
Private cCodFilIni := Space(2) 
Private cCodFilFim := Space(2) 
Private nContador  := 0    //Contador de registros processados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard TITLE 'Drogaria - Geração automática do número de cartões para dependentes' ;
HEADER 'Wizard de geração de número de cartões para dependentes:' ; 
MESSAGE 'Processamento automático.' TEXT cText ;
NEXT {|| .T.} FINISH {|| .T.} PANEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Segundo Panel - Intervalo de clientes      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Dados para geração e atribuição do número de cartões para dependentes' ;
MESSAGE 'Selecionar o intervalo de clientes para executar o processamento de atribuição de número de cartões.' ;
BACK {|| .T. } NEXT {|| DroGrvCart() } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(2)

bValid   := {|| ExistCpo("SM0",cEmpAnt+cCodFilIni)}
TSay():New(05,05,{|| "Filial Inicial"},oPanel,,,,,,.T.)
oGetLojaIni := TGet():New(04,70,bSETGET(cCodFilIni),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L53",)

bValid   := {|| ExistCpo("SM0",cEmpAnt+cCodFilFim) .And. cCodFilFim >= cCodFilIni}
TSay():New(25,05,{|| "Filial Final"},oPanel,,,,,,.T.)
oGetLojaFim := TGet():New(24,70,bSETGET(cCodFilFim),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L53",)

bValid   := {|| ExistCpo("SA1",cCodCliIni)}
TSay():New(45,05,{|| "Cliente Inicial"},oPanel,,,,,,.T.)
oGetCodClIni := TGet():New(44,70,bSETGET(cCodCliIni),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)

bValid   := {|| ExistCpo("SA1",cCodCliIni+cLojCliIni)}
TSay():New(65,05,{|| "Loja Cliente Inicial"},oPanel,,,,,,.T.)
oGetLojClIni := TGet():New(64,70,bSETGET(cLojCliIni),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

bValid   := {|| ExistCpo("SA1",cCodCliFim) .And. cCodCliFim >= cCodCliIni}
TSay():New(85,05,{|| "Cliente Final"},oPanel,,,,,,.T.)
oGetCodClFim := TGet():New(84,70,bSETGET(cCodCliFim),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"SA1",)

bValid   := {|| ExistCpo("SA1",cCodCliFim+cLojCliFim)}
TSay():New(105,05,{|| "Loja Cliente Final"},oPanel,,,,,,.T.)
oGetLojClFim := TGet():New(104,70,bSETGET(cLojCliFim),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

TSay():New(125,05,{|| "Clique em Avançar para realizar o processamento." },oPanel,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Terceiro Panel-Status do Processamento ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo o resultado do Processamento' ;
BACK {|| .F. } NEXT {|| .T. } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(3)

TSay():New(35,05,{|| "Registros processados:" },oPanel,,,,,,.T.)
oGetCont := TGet():New(34,70, bSETGET(nContador),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)

ACTIVATE WIZARD oWizard CENTER 

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DroGrvCartºAutor  ³Fernando Machima    º Data ³  04/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera os numeros dos cartoes e grava no arquivo LIO para os  º±±
±±º          ³dependentes                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function DroGrvCart()
Local lRet        := .T.  
Local lTemCartao  := .T.  //Indica se o dependente tem cartao cadastrado no MA6
Local lCartaoNum  := .T.  //Indica se o cartao do dependente cadastrado no MA6 esta preenchido
Local nTamNumCart := TamSX3("MA6_NUM")[1]
Local nRecnoMA6   := ""  //Recno do registro do MA6 do dependente
Local nX          := 0   //Controla o sequencial do cartao impresso na conta
Local cCartaoTit  := Space(nTamNumCart)  //Numero do cartao do titular
Local cCartaoDep  := Space(nTamNumCart)
Local cACFarma    := GetMV("MV_ACFARMA",,"017")  //Codigo da ACFarma
Local cAleatorio  := ""
Local cFilDrog    := "" 
Local cFilSiga    := "" 
Local cSeqConta   := ""
Local cProxSeqCart:= ""
Local cUltSeq     := ""  //Sequencia do ultimo cartao, considerando titular e dependente 

//Dependentes
DbSelectArea("MAC")
DbSetOrder(2)
//DbOrderNickName("MACDRO1")

If lRet  := MsgYesNo("Confirma a geração e atribuição dos números dos cartões para os dependentes?")
   BEGIN TRANSACTION
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1")+cCodCliIni+cLojCliIni,.T.)
   nContador  := 0
   //Percorre os clientes considerando o intervalo selecionado
   While !Eof() .And. xFilial("SA1")+cCodCliFim+cLojCliFim >= SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA
      
      //Ignorar cliente padrao
      If SA1->A1_COD+SA1->A1_LOJA == GetMV("MV_CLIPAD")+GetMV("MV_LOJAPAD")
         DbSkip()
         Loop
      EndIf
      // Verifica se o cliente eh do tipo Empresa ou se eh um cliente garado a partir do cadastro de Plano de Fidelidade
      If SA1->A1_TPCONVE == "4" .Or. SA1->A1_TPCONVE == ""
         DbSkip()
         Loop
      EndIf
         
      
      DbSelectArea("MAC")
      DbSetOrder(2)
	  //DbOrderNickName("MACDRO1")      
      cCartaoTit  := Space(nTamNumCart)
      nX          := 1
      cUltSeq     := "01"
      //Verificar se existem dependentes do cliente corrente sem cartao
      If DbSeek(xFilial("MAC")+SA1->A1_COD+SA1->A1_LOJA)    
         While !Eof() .And. xFilial("MAC")+SA1->A1_COD+SA1->A1_LOJA == MAC->MAC_FILIAL+MAC->MAC_CODCLI+MAC->MAC_LOJA
            
            lTemCartao  := .T.
            lCartaoNum  := .T.
            
            If Empty(MAC->MAC_CODDEP) .Or. MAC->MAC_CARTAO != "1"
               DbSkip()
               Loop
            EndIf
            
            //Verifica se o dependente tem cartao cadastrado no MA6. Deve gerar cartao se nao encontrar cartao
            //para o dependente no MA6 ou se o numero do cartao estiver vazio
            DbSelectArea("MA6")
            //DbSetOrder(3) 
            DbOrderNickName("MA6DRO1")//indice criado p/ o Template de Drogaria
            If lTemCartao := DbSeek(xFilial("MA6")+MAC->MAC_CODCLI+MAC->MAC_LOJA+MAC->MAC_CODDEP)
               lCartaoNum  := !Empty(MA6->MA6_NUM)   //Verifica se o numero do cartao esta preenchido
               nRecnoMA6   := Recno()
            EndIf
            
            //Gerar o cartao se o dependente nao tiver cartao ou se o mesmo nao estiver preenchido no MA6
            If !lTemCartao .Or. !lCartaoNum 
               //Buscar o numero do cartao titular do cliente corrente para o primeiro dependente 
               If Empty(cCartaoTit)            
                  cCartaoTit   := DROSeekTit(@cFilDrog,@cFilSiga,@cUltSeq)
               EndIf   
               //Verifica se o cartao do titular foi encontrado
               If !Empty(cCartaoTit)
                  cSeqConta   := Substr(cCartaoTit,7,6)      //Sequencia da conta cadastrada na loja
                  cAleatorio  := StrZero(Randomize(1,98),2)      
                  cProxSeqCart:= StrZero(Val(cUltSeq)+nX,2)  //Proxima sequencia dentro da conta                
                  cCartaoDep  := cACFarma+cFilDrog+cSeqConta+cProxSeqCart+cAleatorio
                  //Gerar o cartao no arquivo de Cartoes Disponiveis
			      RecLock("LIO",.T.)
			      LIO->LIO_FILIAL := xFilial("LIO")
			      LIO->LIO_CARTAO := cCartaoDep
			      LIO->LIO_CODCLI := MAC->MAC_CODCLI
			      LIO->LIO_LOJCLI := MAC->MAC_LOJA
			      LIO->LIO_CODDEP := MAC->MAC_CODDEP
			      LIO->LIO_STATUS := "2"
			      MsUnLock()               
			      nX++
			      
			      //Atualiza/Gera o cartao do dependente no MA6(Cartoes)
			      //Dependente nao tem cartao no MA6
			      If !lTemCartao
			         RecLock("MA6",.T.)
			         MA6->MA6_FILIAL := xFilial("MA6")
			         MA6->MA6_CODCLI := MAC->MAC_CODCLI
			         MA6->MA6_LOJA   := MAC->MAC_LOJA
			         MA6->MA6_CODDEP := MAC->MAC_CODDEP
			         MA6->MA6_SITUA  := "2"             //Bloqueado
			         MA6->MA6_MOTIVO := "1"             //Cartao novo
			         MA6->MA6_NUM    := cCartaoDep			         
			         MA6->MA6_DTEVE  := dDatabase
			         MsUnLock()               			      
			      //Dependente tem cartao sem um numero atribuido no MA6			            
			      ElseIf !lCartaoNum 
			         MA6->(DbGoto(nRecnoMA6))   
			         RecLock("MA6",.F.)			   
			         MA6->MA6_NUM  := cCartaoDep
			         MsUnlock()
			      EndIf   
			      			   
			      nContador++                  
               Else
                  //Se nao encontrar o cartao do titular, vai para o proximo cliente 
                  Exit      
               EndIf
            EndIf
            DbSelectArea("MAC")
            DbSetOrder(2)            
            //DbOrderNickName("MACDRO1")      
            DbSkip()
         End    
      EndIf
      DbSelectArea("SA1")
      DbSetOrder(1)      
      
      DbSkip()
   End
   END TRANSACTION
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DRORetFil ºAutor  ³Fernando Machima    º Data ³  04/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o codigo da filial Microsiga correspondente ao codigo º±±
±±º          ³da Drogaria. Busca na tabela IL do SX5                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DRORetFil(cFilDrog)

Local cCodFil     := ""
Local cTabSX5	  := "IL"  //Tabela referente a Filiais Microsiga x Drogaria	
Local aArea       := GetArea()

DbSelectArea("SX5")
DbSeek(xFilial("SX5")+cTabSX5)
While !Eof() .And. xFilial("SX5")+cTabSX5 == SX5->X5_FILIAL+SX5->X5_TABELA
   
   If AllTrim(X5Descri()) == cFilDrog
      cCodFil  := SX5->X5_CHAVE
      Exit
   EndIf
      
   DbSkip()
End

RestArea(aArea)

Return cCodFil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROSeekTitºAutor  ³Fernando Machima    º Data ³  04/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o numero do cartao do titular e a sequencia do ultimo º±±
±±º          ³cartao para buscar o proximo                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Templates Drogaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DROSeekTit(cFilDrog, cFilSiga, cUltSeq)   

Local cMatriz      := GetMV("MV_MATRIZ",,"01")  //Codigo da matriz, que pode gerar cartoes para qq. filial
Local cCartaoTit   := ""
Local lMatriz      := cMatriz == cFilAnt  //Verifica se estah gerando da matriz
Local aArea        := GetArea()
Local nTamNumCart  := TamSX3("MA6_NUM")[1]

DbSeek(xFilial("MA6")+MAC->MAC_CODCLI+MAC->MAC_LOJA)
While !Eof() .And. xFilial("MA6")+MAC->MAC_CODCLI+MAC->MAC_LOJA == MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA ;
   .And. Empty(cCartaoTit)
   
   //Ignorar os cartoes dos dependentes, deve considerar apenas o titular
   If !Empty(MA6->MA6_CODDEP) 
      DbSkip()
      Loop     
   EndIf
   
   //O cartao do titular deve estar ativo ou bloqueado
   If MA6->MA6_SITUA == "3"
      DbSkip()
      Loop
   EndIf
   
   cCartaoTit  := MA6->MA6_NUM      
   
   DbSkip()
End

If !Empty(cCartaoTit)
   cFilDrog  := Substr(cCartaoTit,4,3)                              
   //Buscar o codigo da filial da Microsiga correspondente ao codigo da Drogaria
   cFilSiga  := DRORetFil(cFilDrog)
               
   //Se nao encontrar o codigo da filial Siga correspondente, vai para o proximo cliente
   If Empty(cFilSiga)               
      cCartaoTit  := ""
   Else
      //Se estiver gerando da matriz, respeitar o intervalo de filiais
      If lMatriz
         If cFilSiga < cCodFilIni .Or. cFilSiga > cCodFilFim   
            cCartaoTit  := ""
         EndIf   
      //Se estiver gerando de uma filial, soh permitir gerar cartoes da filial corrente
      Else 
         If cFilSiga != cFilAnt
            cCartaoTit  := ""
         EndIf     
      EndIf   
   EndIf               
   //Se o cartao do titular foi encontrado, busca a sequencia do ultimo cartao da conta do cliente corrente
   If !Empty(cCartaoTit)
      DbSelectArea("MA6")
      DbSetOrder(2)
      DbSeek(xFilial("MA6")+MAC->MAC_CODCLI+MAC->MAC_LOJA+Replicate("Z",nTamNumCart),.T.)
      DbSkip(-1)
      If MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA == xFilial("MA6")+MAC->MAC_CODCLI+MAC->MAC_LOJA
         cUltSeq  := Substr(MA6->MA6_NUM,13,2)
      EndIf
   EndIf
EndIf

RestArea(aArea)

Return cCartaoTit