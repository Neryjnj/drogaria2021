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
���Programa  �DROCONVEDI�Autor  �Fernando Machima    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processamento do EDI - Geracao do arquivo de envio dos     ���
���          � dados de fechamento de convenio                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/
Template Function DROCONVEDI()
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
Local cStartPath := Upper(GetSrvProfString("STARTPATH",""))
Local cTxt1 := ""
Local cTxt2 := ""
Local cDir  := cStartPath
Local cDirEDI := Space(60)
Local cExt  := "ENV"   //Extensao do arquivo de configuracao para envio ao cliente
Local cPicture := ""
Local cText :=	'Este programa ir� gerar o arquivo de envio contendo os ' + ; 
                'dados do fechamento de conv�nio de acordo com a configura��o ' + ; 
	  			'pr�-definida no configurador do EDI.' + CTRL + CTRL + CTRL + ;
	  			'Para continuar clique em Avan�ar.'

Local bValid

Private cCodEmpresa := Space(TamSX3("A1_COD")[1])
Private cLojEmpresa := Space(TamSX3("A1_LOJA")[1])
Private cArq        := cStartPath      //Path onde serah gravado o arquivo de envio
//Variavel que deve ser utilizada na configuracao do layout por total
//Armazena o total gasto por conveniado
Private nTotConvenio:= 0         
//Registros processados na geracao do arquivo de envio. Mostrado no resultado do processamento(quinto panel)
Private nRegProc    := 0
Private cArqEDI     := ""  //Nome e patch do arquivo de envio gerado
Private cNomeReduz  := ""
Private cBLinSE1    := ""
Private oOk		    := LoadBitMap(GetResources(), "LBOK")
Private oNo		    := LoadBitMap(GetResources(), "LBNO")
Private oNever	    := LoadBitMap(GetResources(), "DISABLE")
Private oLBTitConv

//������������������������������Ŀ
//�Estrutura do array aDadosTitGl�
//�------------------------------�
//�1-Marca de selecao            �
//�2-Prefixo                     �
//�3-Numero                      �
//�4-Parcela                     �
//�5-Tipo                        �
//�6-Valor                       �
//�7-Saldo                       �
//�8-Data emissao                �
//�9-Data vencimento             �
//�10-Deletado                   �
//��������������������������������
Private aDadosTitGl  := {}

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

ConvEDIDir(cDir,cExt,@aDir)

DbSelectArea("SE1")
DbSetOrder(1)
//�����������������������Ŀ
//�Inicializacao do Wizard�
//�������������������������
DEFINE WIZARD oWizard TITLE 'EDI Drogaria - Gera��o do arquivo de envio do Fechamento de Conv�nio' ;
HEADER 'Wizard gera��o do arquivo de envio EDI:' ; 
MESSAGE 'Processamento autom�tico.' TEXT cText ;
NEXT {|| .T.} FINISH {|| .T.} PANEL


//�������������������������������������������Ŀ
//�Segundo Panel - Pergunte do fechamento     �
//���������������������������������������������
CREATE PANEL oWizard HEADER 'Dados para gera��o do arquivo' ;
MESSAGE 'Informe os dados abaixo para a gera��o do arquivo de envio.' ;
BACK {|| .T. } NEXT {|| ConvEDIFech() } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(2)

bValid   := {|| ExistCpo("SA1",cCodEmpresa)}
TSay():New(15,05,{|| "Empresa de conv�nio"},oPanel,,,,,,.T.)
oGetCodEmpresa := TGet():New(14,70,bSETGET(cCodEmpresa),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L54",)

bValid   := {|| ExistCpo("SA1",cCodEmpresa+cLojEmpresa)}
TSay():New(35,05,{|| "Loja da empresa"},oPanel,,,,,,.T.)
oGetLojEmpresa := TGet():New(34,70,bSETGET(cLojEmpresa),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

//���������������������������������������������������Ŀ
//�Terceiro Panel-Arquivo Lay Out e de envio para EDI �
//�����������������������������������������������������
CREATE PANEL oWizard HEADER 'Sele��o do arquivo de configura��o do lay-out e do arquivo de envio para EDI.' ;
MESSAGE 'Informe os caminhos dos arquivo de layout e de envio. ATEN��O! Se j� houver um arquivo de envio de mesmo nome neste diret�rio, este ser� sobrescrito!';
BACK {|| .T. } NEXT {|| IIf(EDIVldDir(cDir),(cDirEDI := cArq,.T.),.F.) } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(3)

oGrp1 := TGroup():New(5,2,135,280," Sele��o dos caminhos dos arquivos: ",oPanel,,,.T.)
TSay():New(25,08,{|| "Escolha o caminho do arquivo de lay-out:"},oPanel,,,,,,.T.)
oGet1 := TGet():New(35,08, bSETGET(cDir),oPanel,110,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(35,120,14,{|| cDir := cGetFile("Escolha o diretorio|*.*|","Escolha o caminho do arquivo de configura��o.",0,"SERVIDOR"+cDir,.T.,GETF_ONLYSERVER+GETF_RETDIRECTORY), ConvEDIDir(cDir,cExt,@aDir)},oPanel,)

TSay():New(65,08,{|| "Escolha o caminho do arquivo de envio:"},oPanel,,,,,,.T.)
oGet2 := TGet():New(75,08,bSETGET(cArq),oPanel,110,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(75,120,14, {|| cArq := cGetFile("Escolha o diretorio|*.*|","Escolha o caminho do arquivo de envio.",0,,.T.,GETF_ONLYSERVER+GETF_RETDIRECTORY) },oPanel,)
                                    
//����������������������������������������������������������Ŀ
//�Quarto Panel - Confirmacao final / chamada processamento. �
//������������������������������������������������������������
CREATE PANEL oWizard HEADER 'Confirma��o dos dados e processamento:' ;
MESSAGE 'Confirme os dados abaixo.' ;
BACK {|| .T. } NEXT {|| ConvEDIVld(.T.,cDir,cDirEDI) } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(4)

TSay():New(05,05,{|| "Gera��o do arquivo de envio do fechamento de conv�nio para EDI."},oPanel,,,,,,.T.)
TSay():New(35,05,{|| "Caminho do arquivo de Lay-Out:" },oPanel,,,,,,.T.)
TSay():New(65,05,{|| "Caminho do Arquivo para EDI:" },oPanel,,,,,,.T.)
oGet3 := TGet():New(35,100, bSETGET(cDir),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)
oGet4 := TGet():New(65,100, bSETGET(cDirEDI),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)
TSay():New(95,05,{|| "Clique em Avan�ar para selecionar o t�tulo aglutinado." },oPanel,,,,,,.T.)

//��������������������������������������������Ŀ
//�Quinto Panel - Confirmar o titulo aglutinado� 
//����������������������������������������������
CREATE PANEL oWizard HEADER 'Confirma��o do t�tulo aglutinado:' ;
MESSAGE 'Selecione para qual t�tulo aglutinado deve ser gerado o arquivo de envio.' ;
BACK {|| .T. } NEXT {|| ConvEDIProc(cDir,cDirEDI) } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(5)
      
aCabec  := {"","Prefixo","N�mero","Parcela","Tipo","Valor","Saldo","Emiss�o","Vencto."}
aTam    := {5,25,30,25,15,50,50,32,32}
Aadd(aCpos  ,"nSel")
Aadd(aCpos  ,"E1_PREFIXO")
Aadd(aCpos  ,"E1_NUM")
Aadd(aCpos  ,"E1_PARCELA")
Aadd(aCpos  ,"E1_TIPO")
Aadd(aCpos  ,"E1_VALOR")
Aadd(aCpos  ,"E1_SALDO")
Aadd(aCpos  ,"E1_EMISSAO")
Aadd(aCpos  ,"E1_VENCTO")

//Inicializa array dos titulos aglutinados do fechamento de convenio
aDadosTitGl  := MontaArray(aCpos) 
				
oLBTitConv	:= TwBrowse():New(000,000,000,000,,aCabec,aTam,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBTitConv:nHeight	:=200
oLBTitConv:nWidth	:=565
oLBTitConv:lColDrag	:= .T.
oLBTitConv:nFreeze	:= 1
oLBTitConv:SetArray(aDadosTitGl)
cBLinSE1:= "{If(aDadosTitGl[oLBTitConv:nAt,1]>0,oOk,If(aDadosTitGl[oLBTitConv:nAt,1]<0,oNo,oNever))"
oLBTitConv:bLDblClick :={ || SelecTitGl()}
For nI:= 2 to Len(aCpos)
	cPicture:= Alltrim(Posicione("SX3",2,aCpos[nI],"X3_PICTURE"))
	cBLinSE1 := cBLinSE1 + ", Transform(aDadosTitGl[oLBTitConv:nAT][" + alltrim(Str(nI))+ "], '" + cPicture + "')"
Next nI

oLBTitConv:bLine:= { || &(cBLinSE1 + "}") }

TSay():New(105,05,{|| "Clique em Avan�ar para realizar o processamento." },oPanel,,,,,,.T.)

//���������������������������������������Ŀ
//�Sexto Panel - Status do Processamento  � 
//�����������������������������������������
CREATE PANEL oWizard HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo o resultado do Processamento' ;
BACK {|| .F. } NEXT {|| .T. } FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(6)

TSay():New(15,05,{|| "Empresa de Conv�nio:" },oPanel,,,,,,.T.)
oGetEmp := TGet():New(15,70, bSETGET(cNomeReduz),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)

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
���Programa  �ConvEDIDir�Autor  �Carlos A. Gomes Jr. � Data �  11/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica validade do Path e refaz vetor aDir.              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ConvEDIDir(cDir,cExt,aDir)
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
���Programa  �ConvEDIVld �Autor  �Carlos A. Gomes Jr. � Data �  14/05/04   ���
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
Static Function ConvEDIVld(lTela,cDir,cDirEDI)

Local lRet      := .T.

DEFAULT lTela   := .F.
DEFAULT cDir    := ""
DEFAULT cDirEDI := ""

If Empty(cDir)
    If lTela
    	MsgAlert("Digite o caminho do arquivo de Lay-Out.")
    	Return .F.
    Else
    	QOut("Digite o caminho do arquivo de Lay-Out.")
    	Return .F.
    EndIf
EndIF

If Empty(cDirEDI)
    If lTela
    	MsgAlert("Selecione o caminho do arquivo de envio.")
    	Return .F.
    Else
    	QOut("Selecione o caminho do arquivo de envio.")
    	Return .F.
    EndIf
Endif

//�������������Ŀ
//�Processamento�
//���������������
Processa( { |lEnd| lRet  := BuscaTitGl(cDir,cDirEDI) }, "Processando...",, .F.)  

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BuscaTitGl�Autor  �Fernando Machima    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca o(s) titulo(s) de convenio aglutinado(s)             ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function BuscaTitGl(cDir,cDirEDI)

Local nHandle   
Local nQtdeTitGl:= 0  //Controla se houver mais de um titulo aglutinado
Local cArqLay   := ""
Local cPrefPad  := PadR(GetMV("MV_PRFCONV",,"CON"),3)  //Prefixo padrao do titulo de convenio aglutinado
Local cArqLog   := cArq+"logedi.log"  //Grava o arquivo de log de erro no mesmo diretorio do arquivo de envio
Local aLayOut   := {}

//���������������������������������������Ŀ
//�Posicionamento da empresa de convenio  �
//�����������������������������������������
DbSelectArea("SA1")
DbSetOrder(1)
If !DbSeek(xFilial("SA1")+cCodEmpresa+cLojEmpresa)
   MsgAlert("Empresa de conv�nio n�o encontrada no cadastro de clientes.")
   Return .F.   
EndIf

//Nome do arquivo de configuracao de lay-out do arquivo de envio
If Empty(SA1->A1_LAYOUTC)
   MsgAlert("Arquivo de configura��o de layout n�o preenchido! Verificar o campo Layout Conv�nio do cadastro de clientes.")
   Return .F.
EndIf

//Nome do arquivo de envio a ser gerado para o cliente
If Empty(SA1->A1_ARQEDI)
   MsgAlert("Arquivo de envio n�o preenchido! Verificar o campo Arquivo Envio do cadastro de clientes.")
   Return .F.
EndIf

cArqLay  := cDir+SA1->A1_LAYOUTC
cArqEDI  := cDirEDI+SA1->A1_ARQEDI 
cNomeReduz  := SA1->A1_NREDUZ

If !File(cArqLay)
   MsgAlert("Arquivo de configura��o de layout n�o encontrado! Verificar o caminho selecionado e o nome do arquivo.")
   Return .F.
EndIf

//Recupera em um array os campos e posicoes do arquivo de configuracao de lay-out
aLayOut := __VRestore(cArqLay)
If Len(aLayOut) != 4
   MsgAlert("Arquivo de configura��o de layout inv�lido! Verificar a estrutura do arquivo atrav�s do configurador EDI.")
   Return .F.
EndIf

//����������������������������������������������������������������������������������������Ŀ
//�Se existir, excluir o arquivo de envio para sobrepor                                    �
//������������������������������������������������������������������������������������������
If File(cArqEDI)
   FErase(cArqEDI)
EndIf

//����������������������������������������������������������������������������������������Ŀ
//�Se existir, excluir o arquivo de log para nova geracao caso haja erros de configuracao  �
//������������������������������������������������������������������������������������������
If File(cArqLog)
	FErase(cArqLog)
EndIf

//Cria o arquivo de envio
nHandle := FCreate(cArqEDI)
If nHandle == -1
   MsgAlert("N�o foi poss�vel criar o arquivo de envio "+cArqEDI+".")
   Return .F.
Else
   FClose(nHandle)             	
EndIf

//������������������������������������������������������������������������������������������������������������������Ŀ
//�Busca o titulo aglutinado de convenio. Pode haver mais de um nos casos em que o cliente nao efetua o pagamento no � 
//�mes anterior                                                                                                      �
//��������������������������������������������������������������������������������������������������������������������
DbSelectArea("SE1")
DbSetOrder(8)
nQtdeTitGl   := 0
aDadosTitGl  := {}
If DbSeek(xFilial("SE1")+cCodEmpresa+cLojEmpresa+"A")
   While !Eof() .And. xFilial("SE1")+cCodEmpresa+cLojEmpresa+"A" == SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+;
         SE1->E1_STATUS
      
      If AllTrim(SE1->E1_TIPO) != "FI"   
         DbSkip()
         Loop
      EndIf

      If AllTrim(SE1->E1_PREFIXO) != AllTrim(cPrefPad)   
         DbSkip()
         Loop
      EndIf
      
      nQtdeTitGl++
      Aadd(aDadosTitGl,{-1,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_VALOR,SE1->E1_SALDO,SE1->E1_EMISSAO,SE1->E1_VENCTO,.F.})
      
      DbSkip()
   End      
EndIf
   
If Len(aDadosTitGl) == 0
   MsgAlert("N�o foi encontrado nenhum t�tulo de fechamento de conv�nio em aberto para a empresa selecionada.")
   Return .F.
Else
   //Marca o ultimo titulo selecionado
   aDadosTitGl[Len(aDadosTitGl)][1]  := 1
   oLBTitConv:SetArray(aDadosTitGl)
   oLBTitConv:bLine:= { || &(cBLinSE1 + "}") }   
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConvEDIPro�Autor  �Fernando Machima    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera o arquivo de envio com base no arquivo de configuracao ���
���          �de lay-out                                                  ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ConvEDIProc(cDir,cDirEDI)

Local lGeraLog  := .F.
Local lErroDet  := .F.   
Local lFirst    := .T.
Local lRet      := .T.
Local lSelec    := .F.
Local cPrefConv := ""
Local cNumConv  := ""
Local cTxtLog   := ""
Local cArqLay   := ""
Local aTitConv  := {}
//Array que controla se outro conveniado quando layout por total
Local aCliConv  := {}
Local aLayOut   := {}
Local nX

//����������������������������������������������������������������Ŀ
//�Verifica qual titulo de fechamento foi selecionado              � 
//������������������������������������������������������������������
For nX := 1 to Len(aDadosTitGl)
   If aDadosTitGl[nX][1] == 1
      lSelec     := .T.   
      cPrefConv  := aDadosTitGl[nX][2]
      cNumConv   := aDadosTitGl[nX][3]
      Exit
   EndIf
Next nX

If !lSelec
   MsgAlert("Selecione um t�tulo de fechamento de conv�nio para a gera��o do arquivo de envio.")
   Return .F.     
EndIf

If !MsgYesNo("Confirma a gera��o do arquivo texto para o processo de EDI?")
   Return .F.
EndIf
      
//����������������������������������������������������������������Ŀ
//�Busca os titulos dos conveniados que geraram o titulo aglutinado� 
//������������������������������������������������������������������
aTitConv  := {}
aCliConv  := {}
lFirst    := .T.
nRegProc  := 0
cArqLay   := cDir+SA1->A1_LAYOUTC
cArqEDI   := cDirEDI+SA1->A1_ARQEDI 
aLayOut   := __VRestore(cArqLay)

DbSelectArea("SE1")
//DbSetOrder(19)
DbOrderNickName("SE1DRO1")
If DbSeek(xFilial("SE1")+cPrefConv+cNumConv)
   //�������������������������������������Ŀ
   //�Gravacao do cabecalho do layout      �
   //���������������������������������������		        
   If !EDIGeraEnv(cArqEDI,aLayout,1,cArqLay)   
      lGeraLog  := .T.
   EndIf

   While !Eof() .And. xFilial("SE1")+cPrefConv+cNumConv == SE1->E1_FILIAL+SE1->E1_CNVPREF+SE1->E1_CNVNUM
      
      If AllTrim(SE1->E1_TIPO) != "FI"          
         DbSkip()
         Loop
      EndIf
      
      //Se a venda tiver mais de um titulo, deve executar uma so vez      
      If aScan(aTitConv,SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_TIPO) == 0
         Aadd(aTitConv,SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_TIPO)
      Else
         DbSkip()
         Loop      
      EndIf
      
      //Para impressao dos Totais, imprime uma linha por conveniado
      If !lFirst 
         If aLayout[4] == 3 .And. aScan(aCliConv,SE1->E1_CLIENTE+SE1->E1_LOJA) == 0
            Aadd(aCliConv,SE1->E1_CLIENTE+SE1->E1_LOJA)
            If !EDIGeraEnv(cArqEDI,aLayout,2,cArqLay)   
               lGeraLog  := .T.   
               Exit
            EndIf   
            //Zera a variavel porque se trata de outro conveniado
            nTotConvenio  := 0
         EndIf               
      Else   
         Aadd(aCliConv,SE1->E1_CLIENTE+SE1->E1_LOJA)
      EndIf
      
      lFirst    := .F.
      //Posiciona no conveniado 
      SA1->(DbSetOrder(1))
      If !SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
         cTxtLog   := "Conveniado "+SE1->E1_CLIENTE+"/"+SE1->E1_LOJA+" n�o encontrado no arquivo de Clientes(SA1)."
         cTxtLog   += "Documento de refer�ncia: "+SE1->E1_PREFIXO+"/"+SE1->E1_NUM+" - "+SE1->E1_PARCELA+CTRL          
         EDIGrvLog(cTxtLog)                     
         lGeraLog  := .T.
         Exit
      EndIf
      
      //Posiciona na NF
      SF2->(DbSetOrder(2))
      If !SF2->(DbSeek(xFilial("SF2")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_NUM+SE1->E1_PREFIXO))
         cTxtLog   := "Documento "+SE1->E1_PREFIXO+"/"+SE1->E1_NUM+" n�o encontrado no arquivo de Notas Fiscais(SF2)."+CTRL
         EDIGrvLog(cTxtLog)                     
         lGeraLog  := .T.
         Exit
      EndIf
      
      If aLayout[4] == 1  //Cabecalho
         If !EDIGeraEnv(cArqEDI,aLayout,2,cArqLay)   
            lGeraLog  := .T.   
            Exit
         EndIf
      ElseIf aLayout[4] == 2  //Itens 
         lErroDet  := .F.   
         SD2->(DbSetOrder(3))
         If !SD2->(DbSeek(xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA))      
            cTxtLog   := "Nenhum item do Documento "+SE1->E1_PREFIXO+"/"+SE1->E1_NUM+" foi encontrado no arquivo de Itens de Notas Fiscais(SD2)."            
            cTxtLog   := "Conveniado de refer�ncia: "+SE1->E1_CLIENTE+"/"+SE1->E1_LOJA+CTRL            
            EDIGrvLog(cTxtLog)            
            lGeraLog  := .T.            
            Exit
         EndIf
         SB1->(DbSetOrder(1))         
         While !SD2->(Eof()) .And. xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA ==;
               SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
            
            If !SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
               cTxtLog   := "Produto "+SD2->D2_COD+" n�o encontrado no arquivo de Produtos(SB1)."
               cTxtLog   += "Documento de refer�ncia: Prefixo: "+SE1->E1_PREFIXO+"/N�mero: "+SE1->E1_NUM+"/Parcela: "+SE1->E1_PARCELA+CTRL          
               EDIGrvLog(cTxtLog)                     
               lGeraLog  := .T.
               lErroDet  := .T.                  
               Exit
            EndIf
                     
            If !EDIGeraEnv(cArqEDI,aLayout,2,cArqLay)   
               lGeraLog  := .T.
               lErroDet  := .T.   
               Exit
            EndIf
                  
            SD2->(DbSkip())
         End
         If lErroDet
            Exit
         EndIf   
      ElseIf aLayout[4] == 3  //Total
         SD2->(DbSetOrder(3))
         SD2->(DbSeek(xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA))      
         While !SD2->(Eof()) .And. xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA ==;
               SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
            
            //Variavel Private que pode ser utilizada na configuracao do lay-out para mostrar o total vendido
            //a cada conveniado
            nTotConvenio  += SD2->D2_TOTAL
                              
            SD2->(DbSkip())
         End            
      EndIf
      
      DbSkip()         
   End
   //Gravacao do ultimo conveniado para layout por total
   If !lGeraLog .And. aLayout[4] == 3
      If !EDIGeraEnv(cArqEDI,aLayout,2,cArqLay)   
         lGeraLog  := .T.   
      EndIf   
   EndIf               
   
   //�������������������������������������Ŀ
   //�Gravacao do rodape do layout         �
   //���������������������������������������		        
   If !lGeraLog .And. !EDIGeraEnv(cArqEDI,aLayout,3,cArqLay)   		
      lGeraLog  := .T.
   EndIf
Else
   MsgAlert("N�o foi encontrado nenhum t�tulo de conveniado da empresa de conv�nio selecionada.")   
   lRet  := .F.
EndIf

If lGeraLog
   MsgAlert("Foram encontradas algumas inconsist�ncias no processamento."+;
            "Verifique o arquivo de LOG gerado em "+cArq+"LogEDI.log no servidor.")
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConvEDIFec�Autor  �Fernando Machima    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao dos dados de fechamento de convenio              ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ConvEDIFech()

Local lRet  := .T.

If Empty(cCodEmpresa)
   MsgAlert("Preencher o codigo da empresa de conv�nio.")
   lRet  := .F.
EndIf

If lRet .And. Empty(cLojEmpresa)
   MsgAlert("Preencher a loja da empresa de conv�nio.")
   lRet  := .F.
EndIf

SA1->(DbSetOrder(1))
If lRet .And. SA1->(DbSeek(xFilial("SA1")+cCodEmpresa+cLojEmpresa))
   If !(lRet  := SA1->A1_TPCONVE == "4")
      MsgAlert("O cliente selecionado n�o � uma empresa de conv�nio. Verificar o campo Tipo de Conv�nio.")
   EndIf   
EndIf  

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIVldDir �Autor  �Fernando Machima    � Data �  12/11/04   ���
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
Static Function EDIVldDir(cDir)

Local lRet  := .T.

If Empty(cDir)
   MsgAlert("Preencher o caminho do arquivo de configura��o do layout de conv�nio.")
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
���Programa  �EDIGrvLog �Autor  �Fernando Machima    � Data �  17/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Geracao do arquivo de log para erros de configuracao para  ���
���          � fechamento de convenio                                     ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIGrvLog(cTexto)

Local cArqLog  := cArq+"logedi.log"
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIGeraEnv�Autor  �Fernando Machima    � Data �  17/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera o arquivo para envio: cabecalho, itens e rodape       ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - path e nome do arquivo de envio                     ���
���          �ExpA1 - array com os dados do layout                        ���
���          �ExpA2 - array com os dados selecionados para fechamento     ���
���          �ExpN1 - iteracao, indica que empresa de convenio estah sen- ���
���          �do processada                                               ���
���          �ExpN2 - 1=Cabecalho;2=Itens;3=Rodape(generalizacao da funcao���
���          �ExpN3 - Posicao do registro em caso de erro na gravacao do  ���
���          �arquivo de envio. Para cabecalho e rodape, nao eh utilizado ���
�������������������������������������������������������������������������͹��
���Uso       � Templates de Drogaria                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIGeraEnv(cArqEDI,aLayout,nIndice,cArqLay)
Local nT, nX     := 0							   //Contador do sistema
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
         lDataOK    := FormatData(@cAux,cPicture,nTamExpr,nTamTexto)
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
            EDIGrvLog(cTxtLog)              
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
   EDIGrvLog(cTxtLog)       
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
Static Function EDIVldMacro(cValorMacro,aLayOut,nT,nIndice,cArqLay)

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
   EDIGrvLog(cMsg)
   lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FormatData�Autor  �Fernando Machima    � Data �  06/12/2004 ���
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
Static Function FormatData(cData,cPicture,nTamExpr,nTamTexto)

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

cTempPict := AllTrim(Upper(cPicture))
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
cTempPict := AllTrim(Upper(cPicture))
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

Return lRet

/*���������������������������������������������������������������������������
���Programa  �MontaArray�Autor  �Fernando Machima    � Data �  13/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicializa o array aDadosTitGl                             ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
���������������������������������������������������������������������������*/
Static Function MontaArray(aCpos)
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

aC[Len(aC)][Len(aC[1])] := .F.

Return aC

/*���������������������������������������������������������������������������
���Programa  �SelecTitGl�Autor  �Fernando Machima    � Data �  13/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento de selecao dos titulos de fechamento aglutinados���
���          � Ao marcar um titulo, deve desmarcar os demais              ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
���������������������������������������������������������������������������*/
Static Function SelecTitGl()
Local nX

aDadosTitGl[oLBTitConv:nAt,1] := aDadosTitGl[oLBTitConv:nAT,1] * -1
If aDadosTitGl[oLBTitConv:nAt,1] == 1  //Marcado
   For nX := 1 to Len(aDadosTitGl)
      If nX != oLBTitConv:nAt
         aDadosTitGl[nX,1] := -1  //Desmarcar
      EndIf
   Next nX
   oLBTitConv:Refresh()
EndIf   

Return .T.