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
#DEFINE __CARTAO    4        
#DEFINE __OPERACAO  5        

//DEFINE's do array aConvCart
#DEFINE __CODCONV   1        
#DEFINE __LOJCONV   2        
#DEFINE __NOMECONV  3        
#DEFINE __CARTAO    4        
#DEFINE __OPERACAO  5        

/*���������������������������������������������������������������������������
���Programa  �DROCLIEDI �Autor  �Fernando Machima    � Data �  26/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processamento do EDI - Recebimento dos dados dos conveniados���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/

Template Function DROCLIEDI
Local oWizard
Local oPanel
Local oGrp1
Local oRad1
Local oGet1
Local oGrp2
Local oGet2
Local oGetCodEmpresa
Local oGetLojEmpresa
Local oGetRegProc
Local oGetEmp
Local oGetArqEDI
Local nArq   		:= 0
Local aDir   		:= {}
Local oLBBx
Local aCabBx 		:= {}
Local aTamBx 		:= {}
Local oLBBx1
Local aCabBx1 		:= {}
Local aTamBx1 		:= {}
Local cTxt1  		:= ""
Local cTxt2  		:= ""
Local cExt   		:= "CLR"  //Extensao do arquivo de configuracao para importacao dos dados do cliente
Local cArqRecebe  	:= Space(80)
Local cText 		:=	'Este programa ir� processar o arquivo de recebimento contendo os ' + ; 
                		'dados dos conveniados de acordo com a configura��o pr�-definida  ' + ; 
			  			'no configurador do EDI.' + CTRL + CTRL + CTRL + ;
			  			'Para continuar clique em Avan�ar.'
Local cStartPath 	:= GetSrvProfString("STARTPATH","")
Local bValid
//Path do arquivo de configuracao de lay-out de importacao
Local cDirLayout  := cStartPath
Local cCodEmpresa := Space(TamSX3("A1_COD")[1])
Local cLojEmpresa := Space(TamSX3("A1_LOJA")[1])
Local cNomeEmp    := ""
Local oProcCart 
Local lProcCart	  := .F. //Indica se ira' ou nao gerar cartoes para os conveniados importados para a base. 
Local nQtdeINC	  := 0   //Total de conveniados incluidos na base	
Local nQtdeALT	  := 0   //Total de conveniados alterados na base
Local nQtdeRegs   := 0   //Quantidade total de conveniados atualizados com a importacao
Local lNovoConv   := .F.
Local aCampos     := {}
Local aConvCart   := {}	 //Dados dos conveniados maais a numeracao de cartao gerada para cada um.
//������������������������������������Ŀ
//�Estrutura do array aConvCart	       �
//�------------------------------      �
//�1-Codigo do conveniado              �
//�2-Loja do conveniado                �
//�3-Nome do conveniado                �
//�4-Numeracao do cartao	           �
//��������������������������������������      

Local aDadosConv  := {}	 //Dados dos conveniados a serem atualizados, mostrado no panel 4
//������������������������������������Ŀ
//�Estrutura do array aDadosConv       �
//�------------------------------      �
//�1-Codigo do conveniado              �
//�2-Loja do conveniado                �
//�3-Nome do conveniado                �
//�4-Matricula do conveniado           �
//�5-Tipo de operacao:(A)lteracao,(B)lo�
//�queio,(D)esligamento                �
//��������������������������������������

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

ConvEDIDir(cDirLayout,cExt,@aDir)

//�����������������������Ŀ
//�Inicializacao do Wizard�
//�������������������������
DEFINE WIZARD oWizard ;
TITLE 'EDI Drogaria - Processamento do arquivo para atualiza��o dos dados dos conveniados' ;
HEADER 'Wizard do processamento do arquivo de conveniados:' ; 
MESSAGE 'Processamento autom�tico.' TEXT cText ;
NEXT {|| .T.} FINISH {|| .T.} PANEL


//�������������������������������������������Ŀ
//�Segundo Panel - Pergunte do fechamento     �
//���������������������������������������������
CREATE PANEL oWizard ;
HEADER 'Dados para processamento de conveniados' ;
MESSAGE 'Informe a empresa de conv�nio a ser processada.' ;
BACK {|| .T. };
NEXT {|| ConvEDIValid( cCodEmpresa, cLojEmpresa, @cNomeEmp ) } ;
FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(2)

bValid   := {|| ExistCpo("SA1",cCodEmpresa)}
TSay():New(15,05,{|| "Empresa de conv�nio"},oPanel,,,,,,.T.)
oGetCodEmpresa := TGet():New(14,70,bSETGET(cCodEmpresa),oPanel,45,10,,bValid,,,,,,.T.,,,,,,,.F.,,"L54",)

bValid   := {|| ExistCpo("SA1",cCodEmpresa+cLojEmpresa)}
TSay():New(35,05,{|| "Loja da empresa"},oPanel,,,,,,.T.)
oGetLojEmpresa := TGet():New(34,70,bSETGET(cLojEmpresa),oPanel,20,10,,bValid,,,,,,.T.,,,,,,,.F.,,,)

//���������������������������������������������������Ŀ
//�Terceiro Panel - Arquivo de recebimento            �
//�����������������������������������������������������
CREATE PANEL oWizard ;
HEADER 'Arquivos de layout e de recebimento';
MESSAGE 'Informe a pasta onde est� o arquivo de layout de importa��o e o caminho e o nome do arquivo de recebimento.' ;
BACK {|| .T. } ;
NEXT {|| IIf(EDIVldDir(cDirLayout,cArqRecebe),ConvEDIVld( .T., cDirLayout, cArqRecebe, cCodEmpresa, cLojEmpresa, cNomeEmp, @lNovoConv, @aCampos, @aDadosConv ),.F.)} ;
FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(3)

TSay():New(25,08,{|| "Escolha o caminho do arquivo de lay-out:"},oPanel,,,,,,.T.)
oGet1 := TGet():New(35,08, bSETGET(cDirLayout),oPanel,110,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(35,120,14,{|| cDirLayout := cGetFile("Escolha o diretorio|*.*|","Escolha o caminho do arquivo de configura��o.",0,"SERVIDOR"+cDirLayout,.T.,GETF_ONLYSERVER+GETF_RETDIRECTORY), ConvEDIDir(cDirLayout,cExt,@aDir)},oPanel,)

TSay():New(55,08,{|| "Escolha o arquivo de recebimento:"},oPanel,,,,,,.T.)
oGet2 := TGet():New(65,08, bSETGET(cArqRecebe),oPanel,145,10,,,,,,,,.T.,,,,,,,.T.,,,)
SButton():New(65,155,14, {|| cArqRecebe := cGetFile("Todos Arquivos |*.*|","Escolha o arquivo de recebimento.",0,,.T.,GETF_ONLYSERVER), VldArqReceb(@cArqRecebe) },oPanel,)

//�������������������������������������������������������������Ŀ
//�Quarto Panel - Visualizacao dos registros a serem atualizados� 
//���������������������������������������������������������������
CREATE PANEL oWizard ;
HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo os conveniados que ser�o atualizados. Para efetuar as modifica��es na base de dados, clique em Avan�ar.' ;
BACK {|| .T. };
NEXT {|| ConfProc( cCodEmpresa, cLojEmpresa, cNomeEmp, @nQtdeRegs, @aConvCart, lProcCart, @lNovoConv, @nQtdeINC, @nQtdeALT, @aCampos ),;
         Iif(Len(aConvCart) = 0 ,oWizard:nPanel += 1, ), , .T.  } ;
FINISH {|| .T. } PANEL         

oPanel := oWizard:GetPanel(4)

aCabBx	:= {"C�digo", "Loja", "Nome do conveniado", "Matr�cula", "Opera��o" }
aTamBx	:= {30,20,80,35,20}
AAdd(aDadosConv,{"","","","",""})
oLBBx		:= TwBrowse():New(000,003,000,000,,aCabBx,aTamBx,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBBx:SetArray(aDadosConv)
oLBBx:bLine 	:= { ||{aDadosConv[oLBBx:nAT][__CODCONV], aDadosConv[oLBBx:nAT][__LOJCONV], ;
                        aDadosConv[oLBBx:nAT][__NOMECONV], aDadosConv[oLBBx:nAT][__MATRICULA], ;
                        aDadosConv[oLBBx:nAT][__OPERACAO]}}
                        
oLBBx:lHScroll  := .T.
oLBBx:nHeight	:= 200
oLBBx:nWidth	:= 550                                       

@ 100,05 CHECKBOX oProcCart VAR lProcCart PROMPT "Gera Cart�o? (S� ser� v�lido para INCLUSAO de clientes)" SIZE 200,35 OF oPanel PIXEL	//"Controla o status da gaveta ?"
                                    
//���������������������������������������Ŀ
//�Quinto Panel - Status do Processamento � 
//�����������������������������������������
CREATE PANEL oWizard ;
HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo o resultado do Processamento (Somente cliente INCLU�DOS)' ;
BACK {|| .F. } ;
NEXT {|| .F. } ;
EXEC {|| oWizard:oNext:Hide(), oWizard:oBack:Hide(),oWizard:oCancel:Hide(), oWizard:oFinish:Show()};
FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(5)

aCabBx1	:= {"C�digo", "Loja", "Nome do conveniado", "Cart�o", "Opera��o"}
aTamBx1	:= {30,20,80,35,20}
AAdd(aConvCart,{"","","","",""})
oLBBx1		:=TwBrowse():New(000,003,000,000,,aCabBx1,aTamBx1,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLBBx1:SetArray(aConvCart)
oLBBx1:bLine 	:= { ||{aConvCart[oLBBx1:nAT][__CODCONV], aConvCart[oLBBx1:nAT][__LOJCONV], ;
                        aConvCart[oLBBx1:nAT][__NOMECONV], aConvCart[oLBBx1:nAT][__CARTAO] , ;
                        aConvCart[oLBBx1:nAT][__OPERACAO]}}
                        
                        
oLBBx1:lHScroll  := .T.
oLBBx1:nHeight	:= 200
oLBBx1:nWidth	:= 550
//Numero de clientes INCLUIDOS                      
TSay():New(115,05,{|| "N�mero de conveniados inclu�dos:" },oPanel,,,,,,.T.)
oGetRegProc := TGet():New(112,95, bSETGET(nQtdeINC),oPanel,30,5,,,,,,,,.T.,,,,,,,.T.,,,)

//Numero de clientes ALTERADOS
TSay():New(130,05,{|| "N�mero de conveniados alterados:" },oPanel,,,,,,.T.)
oGetRegProc := TGet():New(127,95, bSETGET(nQtdeALT),oPanel,30,5,,,,,,,,.T.,,,,,,,.T.,,,)

// quantidade total de conveniados atualizados na base.
nQtdeRegs := (nQtdeINC + nQtdeALT)                    

//Total de conveniados atualizados
TSay():New(130,145,{|| "Total de Conveniados:" },oPanel,,,,,,.T.)
oGetRegProc := TGet():New(127,205, bSETGET(nQtdeRegs),oPanel,30,5,,,,,,,,.T.,,,,,,,.T.,,,)

//���������������������������������������Ŀ
//�Sexto Panel - Status do Processamento  � 
//�����������������������������������������
CREATE PANEL oWizard ;
HEADER 'Resultado do processamento:' ;
MESSAGE 'Veja abaixo o resultado do Processamento' ;
BACK {|| .F. } ;
NEXT {|| .F. } ;
EXEC {|| oWizard:oNext:Hide(), oWizard:oBack:Hide(),oWizard:oCancel:Hide(), oWizard:oFinish:Show()};
FINISH {|| .T. } PANEL         
oPanel := oWizard:GetPanel(6)

TSay():New(20,15,{|| "Empresa de Conv�nio:" },oPanel,,,,,,.T.)
oGetEmp := TGet():New(15,100, bSETGET(cNomeEmp),oPanel,80,10,,,,,,,,.T.,,,,,,,.T.,,,)

TSay():New(40,15,{|| "Total de conveniados atualizados:" },oPanel,,,,,,.T.)
oGetRegProc := TGet():New(35,120, bSETGET(nQtdeRegs),oPanel,60,10,,,,,,,,.T.,,,,,,,.T.,,,)


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

Static Function ConvEDIDir(cDirLayout,cExt,aDir)
Local   aTMP := {}

aDir := {}
If Empty(cDirLayout)
	MsgAlert("Caminho inv�lido!")
	Return .F.
EndIf
aTMP := Directory(cDirLayout+"*."+cExt)
AEval(aTMP,{|x,y| AAdd(aDir, x[1]) })

Return .T.
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ConvEDIVld �Autor  �Carlos A. Gomes Jr. � Data �  14/05/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos dados e chamada do processamento de ���
���          � importacao dos dados dos conveniados                        ���
���          � Parametros:                                                 ���
���          � lTela = Exibir mensagens em tela .T. no server .F.          ���
���          � cDirLayout = Pasta do arquivo de configuracao do layout     ���
���          � ArqRecebe = Nome do arquivo de recebimento                  ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function ConvEDIVld( lTela      , cDirLayout, cArqRecebe, cCodEmpresa,;
							cLojEmpresa, cNomeEmp  , lNovoConv , aCampos    ,;
							aDadosConv )

Local lRet      := .T.

DEFAULT lTela      := .F.
DEFAULT cDirLayout := ""
DEFAULT cArqRecebe := ""

If Empty(cDirLayout)
    If lTela
    	MsgAlert("Digite o caminho do arquivo de Lay-Out de importa��o.")
    	Return .F.
    Else
    	QOut("Digite o caminho do arquivo de Lay-Out de importa��o.")
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

//�������������Ŀ
//�Processamento�
//���������������
If MsgYesNo("Confirma o processamento do arquivo de recebimento para a atualiza��o do cadastro de conveniados da "+;
            "empresa de conv�nio "+CTRL+AllTrim(cNomeEmp)+"?")
   Processa( { |lEnd| lRet  := ConvEDIProc( cDirLayout, cArqRecebe, cCodEmpresa, cLojEmpresa, cNomeEmp, @lNovoConv , @aCampos, @aDadosConv ) }, "Processando...",, .F.)  
Else
   Return .F.   
EndIf   

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConvEDIPro�Autor  �Fernando Machima    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processamento do EDI-Atualizacao dos dados dos conveniados ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ConvEDIProc( cDirLayout, cArqRecebe, cCodEmpresa, cLojEmpresa,;
							 cNomeEmp  , lNovoConv , aCampos    , aDadosConv )

Local nHandle   
Local nRecno	:= 0
Local lRet      := .T.
Local lGeraLog  := .F.
Local cArqLay   := ""
Local cStartPath := GetSrvProfString("STARTPATH","")
Local cArqLog   := cStartPath+"LogIMPORT.log"
Local cTxtLog   := ""
Local cLinha    := ""
Local cMatricula:= ""
Local cNomeConv := ""
Local cStatus   := ""
Local cOperacao := ""
Local aLayOut   := {}
Local uConteudo 

//���������������������������������������Ŀ
//�Posicionamento da empresa de convenio  �
//�����������������������������������������
DbSelectArea("SA1")
DbSetOrder(1)
If !DbSeek(xFilial("SA1")+cCodEmpresa+cLojEmpresa)
   MsgAlert("Empresa de conv�nio n�o encontrada no cadastro de clientes.")
   Return .F.   
EndIf

If Empty(SA1->A1_LAYIMP)
   MsgAlert("Arquivo de configura��o do layout de importa��o n�o preenchido! Verificar o campo Layout  do cadastro de clientes.")
   Return .F.
EndIf

cArqLay     := cDirLayout+SA1->A1_LAYIMP

If !File(cArqLay)
   MsgAlert("Arquivo de configura��o de layout n�o encontrado! Verificar o caminho selecionado e o nome do arquivo.")
   Return .F.
EndIf

aLayOut := __VRestore(cArqLay)
If Len(aLayOut) != 4
   MsgAlert("Arquivo de configura��o de layout inv�lido! Verificar a estrutura do arquivo atrav�s do configurador EDI.")
   Return .F.
EndIf

//����������������������������������������������������������������������������������������Ŀ
//�Se existir, excluir o arquivo de log para nova geracao caso haja erros de configuracao  �
//������������������������������������������������������������������������������������������
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
If Len(aDadosConv) == 1 .AND. Empty(aDadosConv[1][1])
   ADel(aDadosConv,1)
   ASize(aDadosConv, Len(aDadosConv)-1 )
Else
   aDadosConv  := {}      
EndIf

DbSelectArea("SA1")
DbSetOrder(1)


//���������������������������������Ŀ
//�Ler o arquivo de recebimento     � 
//�����������������������������������
FT_FUSE(cArqRecebe)
FT_FGOTOP()

While !FT_FEOF()
	cLinha:= FT_FREADLN()

	++nRecno	
	
	If Empty(cLinha)
		FT_FSKIP()
		Loop
	EndIf
	
	cMatricula  := ""
    EDILeReceb( cLinha, aLayout, "SA1->A1_MATRICU", @cMatricula, , @aCampos)
    If Empty(cMatricula)
       cTxtLog  := "O arquivo de configura��o do layout n�o possui o campo de matricula do conveniado ou o nome "
       cTxtLog  += "do campo est� incorreto(SA1->A1_MATRICU) no layout. Este campo � obrigat�rio para a identifica��o "
       cTxtLog  += "do conveniado!"+CTRL
       EDIGrvLog(cTxtLog)              
       lGeraLog  := .T.               
       lRet      := .F.                
	   FT_FSKIP()
	   Loop       
    EndIf
    
	cStatus  := ""
    EDILeReceb( cLinha, aLayout, "STATUS", @cStatus, , @aCampos)
    If Len(cStatus) == 0
       cStatus  := "A"  //Valor padrao caso nao haja a coluna de Status no arquivo de recebimento
    ElseIf !(cStatus $ "ABD")
       cTxtLog  := "O conte�do Status do conveniado de matr�cula "+AllTrim(cMatricula)+" est� incorreto. Este campo � utilizado para "
       cTxtLog  += "a identifica��o da opera��o com o registro do conveniado (A-Ativo;B-Bloqueado;D-Desligamento da empresa)!"+CTRL       
       EDIGrvLog(cTxtLog)                     
       lRet      := .F.         
       lGeraLog  := .T.
	   FT_FSKIP()
	   Loop              
    EndIf
    
    cNomeConv := ""
    EDILeReceb( cLinha, aLayout, "SA1->A1_NOME || SA1->A1_NREDUZ", @cNomeConv, , @aCampos )
	
	//Posiciona no conveniado
	DbSelectArea("SA1")
	DbOrderNickName("SA1DRO2")//indice criado p/ o Template de Drogaria
	If DbSeek(xFilial("SA1")+cCodEmpresa+cLojEmpresa+cMatricula)

       //�����������������������������������������������������������������������Ŀ
       //�Posicionar nos registros dos arquivos do CRD(M*) do conveniado corrente� 
       //�������������������������������������������������������������������������	
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
       cOperacao  := IIf(cStatus=="B","Bloqueio",IIf(cStatus=="D","Desligamento","Altera��o"))
       AAdd(aDadosConv,{SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,SA1->A1_MATRICU,cOperacao})       

       If !EDILeReceb( cLinha, aLayout, "", uConteudo, cArqLay, @aCampos )
          lGeraLog  := .T.          
          lRet      := .F.          
          Exit       
       EndIf
	Else
	   If cStatus == "A"  //Conveniado novo                                                
	      lNovoConv  := .T.
          AAdd(aCampos,{"xxxxxx","xx",{},cMatricula,cNomeConv,cStatus})
	      AAdd(aDadosConv,{"xxxxxx","xx",cNomeConv,cMatricula,"Inclus�o"})          
          If !EDILeReceb( cLinha, aLayout, "", uConteudo, cArqLay, @aCampos )
             lGeraLog  := .T.          
             lRet      := .F.             
             Exit       
          EndIf	   
       Else  //Bloqueio ou Desligamento
          cOperacao  := IIf(cStatus=="D","Desligamento","Bloqueio")
          cTxtLog    := "O conveniado de matr�cula "+AllTrim(cMatricula)+" n�o foi encontrado na base de dados para "
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
      aSort(aDadosConv,,,{|x,y| x[1]<y[1]})
   Else
      MsgAlert("N�o foi processado nenhum registro do arquivo de recebimento "+cArqRecebe+" da empresa de conv�nio "+;
                AllTrim(cNomeEmp)+"."+CTRL+" Verifique o conte�do do arquivo e o layout de configura��o.")
      lRet  := .F.
   EndIf
EndIf   

If lGeraLog
   lRet  := .F.
   MsgAlert("Foram encontradas algumas inconsist�ncias no processamento."+;
            "Verifique o arquivo de LOG gerado em "+cStartPath+"LogIMPORT.log no servidor.")
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConvEDIVal�Autor  �Fernando Machima    � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao dos dados                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ConvEDIValid( cCodEmpresa, cLojEmpresa, cNomeEmp )

Local lRet  := .T.

If Empty(cCodEmpresa)
   MsgAlert("Preencher o codigo da empresa de conv�nio.")
   lRet  := .F.
EndIf

If lRet .AND. Empty(cLojEmpresa)
   MsgAlert("Preencher a loja da empresa de conv�nio.")
   lRet  := .F.
EndIf

SA1->(DbSetOrder(1))
If lRet .AND. SA1->(DbSeek(xFilial("SA1")+cCodEmpresa+cLojEmpresa))
   If !(lRet  := SA1->A1_TPCONVE == "4")
      MsgAlert("O cliente selecionado n�o � uma empresa de conv�nio. Verificar o campo Tipo de Conv�nio no cadastro de clientes.")
   Else
      cNomeEmp  := SA1->A1_NOME   
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
���          � recebimento                                                ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIVldDir(cDirLayout,cArqRecebe)

Local lRet  := .T.

If Empty(cDirLayout)
   MsgAlert("Selecionar o caminho do arquivo de configura��o do layout de importa��o.")
   lRet  := .F.
EndIf
If lRet .AND. Empty(cArqRecebe)
   MsgAlert("Selecionar o arquivo de recebimento.")     
   lRet  := .F.   
EndIf

If lRet

   If !File(cArqRecebe)
      MsgAlert("O arquivo de recebimento selecionado n�o existe.")
      lRet  := .F.
   EndIf
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIGrvLog �Autor  �Fernando Machima    � Data �  17/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Geracao do arquivo de log para erros de configuracao para  ���
���          � atualizacao de conveniados                                 ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIGrvLog(cTexto)

Local cStartPath := GetSrvProfString("STARTPATH","")
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDILeReceb�Autor  �Fernando Machima    � Data �  17/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Le o arquivo de recebimento: cabecalho, itens e rodape     ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - linha do arquivo texto                              ���
���          �ExpA1 - array com os dados do layout de configuracao        ���
���          �ExpC2 - campo onde deve ser gravado ou campo que deseja sa- ���
���          �ber o conteudo                                              ���
�������������������������������������������������������������������������͹��
���Uso       � Templates de Drogaria                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDILeReceb( cLinha , aLayout, cCampo, uConteudo,;
							cArqLay, aCampos )

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
//����������������������������������������������������Ŀ
//�Posicao da estrutura de layout do arquivo(aLayout):�
//�                                                    �
//�1 - Titulo do campo                                 �
//�2 - Linha de impressao                              �
//�3 - Coluna inicial                                  �
//�4 - Tamanho                                         �
//�5 - Coluna final                                    �
//�6 - Tipo(1=Caracter;2=Numerico;3=Data;4=Logico)     �
//�7 - Conteudo do campo                               �
//�8 - Picture                                         �
//�9 - Deletado?                                       �
//������������������������������������������������������
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
            cTxtLog  := "Preencher a picture de formata��o de Valor no layout de configura��o "+cArqLay
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
            cTxtLog  := "Preencher a picture de formata��o de Data para o layout de configura��o "+cArqLay
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
            cTxtLog  := "Erro na formata��o da data do registro "+cLinha
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldArqRece�Autor  �Fernando Machima    � Data �  26/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o arquivo de recebimento                            ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - path e nome do arquivo de recebimento selecionado   ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldArqReceb(cArqRecebe)

Local lRet    := .T.
Local nHandle
   
If !File(cArqRecebe)                     
   MsgAlert("Arquivo n�o encontrado!")
   lRet  := .F.
Else
   //Verifica se n�o foi selecionada uma pasta
   nHandle := FOpen(cArqRecebe,1)
   FSeek(nHandle,0,2)
   If nHandle == -1
      MsgAlert("Arquivo inv�lido.")
      lRet  := .F.
      cArqRecebe  := Space(80)
   EndIf
   FClose(nHandle)   
EndIf

Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfProc  �Autor  �Fernando Machima    � Data �  29/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Confirma o processamento de atualizacao dos conveniados    ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������͹��
���Parametros� 															  ���
�������������������������������������������������������������������������͹��
���Retorno   � ExpL1 - Retorna Verdadeiro ou Falso para a continuacao do  ���
���          �         processamento.                                     ���
�������������������������������������������������������������������������͹��
���Analista  � Data   �Bops  �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Thiago H. �01/12/06�114116�Chamada da funcao DroGerTit() para   		  ���
���          �        �      �ralizar a geracao da numeracao dos cartoes  ���
���          �        �      �para os conveniados importados na Base      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ConfProc( cCodEmpresa, cLojEmpresa, cNomeEmp , nQtdeRegs,;
						  aConvCart  , lProcCart  , lNovoConv, nQtdeINC ,;
						  nQtdeALT   , aCampos )

Local lRet        := .T.
Local lIncluir    := .F.
Local lFirst      := .T.
Local lCriaConv   := .F.  //Controla se deve criar um novo conveniado no SA1 e nos demais arquivos relacionados
Local lFound      := .F.
Local lBloqueado  := .F.
Local lTemCartao  := .F.
Local lGeraLog    := .F.
Local lUsaCodCli  := .F.  //Controla se inseriu novo cliente no SA1 para incrementar o sequencial
Local nX		  := 0
Local nY		  := 0
Local nZ		  := 0
Local nRecnoRec
Local nTamCliente := TamSX3("A1_COD")[1]   
Local nNovoCodigo
Local cAliasGrv   := ""
Local cCampoGrv   := ""
Local cCodConv    := ""
Local cLojConv    := ""
Local cPrefixo    := ""
Local cProxNumSA1 := Space(nTamCliente)    
Local cNewCod	  := Space(nTamCliente)
Local cMatricula  := ""
Local cNomeConv   := ""
Local cStatus     := ""
Local cTxtLog     := ""
Local cUltCodigo  := ""
Local cStartPath  := GetSrvProfString("STARTPATH","")
Local uContCpo  
Local aAreaSA1    := {}                        
Local lWizard	  := .T.
Local lMA6		  := .F.

//����������������������������������������������������Ŀ
//�Posicao da estrutura do array aCampos:              �
//�                                                    �
//�1,1 - Cod. cliente                                  �
//�1,2 - Loja cliente                                  �
//�1,3,1,1 - Alias                                     �
//�1,3,1,2 - Alias                                     �
//�1,3,1,3,1 - Campo a modificar                       �
//�1,3,1,3,2 - Conteudo do campo a modificar           �
//�1,4 - Matricula do conveniado                       �
//�1,5 - Nome do conveniado                            �
//�1,6 - Status da operacao com o conveniado(A,B,D)    �
//������������������������������������������������������
nQtdeRegs  := 0      
If lRet  := MsgYesNo("Confirma a atualiza��o na base de dados dos conveniados selecionados?")
   //Indica que um novo conveniado sera incluido no cadastro
   If lNovoConv  
      //Busca o codigo do ultimo cliente cadastrado
      lRet  := DroCodSA1(@cProxNumSA1)      
      If !lRet
         Return .F.
      EndIf   
   EndIf         
   
   ProcRegua(Len(aCampos))                                         
   BEGIN TRANSACTION 
   
   //Exclui a linha em branco 
   If Len(aConvCart) == 1 .AND. Empty(aConvCart[1][1])
      ADel(aConvCart,1)
      ASize(aConvCart, Len(aConvCart)-1 )
   Else
      aConvCart  := {}      
   EndIf   
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
            While !Eof() .AND. xFilial("MA6")+cCodConv+cLojConv == MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA .AND.;
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
               While !Eof() .AND. xFilial("MA8")+cCodConv+cLojConv == MA8->MA8_FILIAL+MA8->MA8_CODCLI+MA8->MA8_LOJA .AND.;
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
               If "A1_COD" $ cCampoGrv
                  Loop
               EndIf
               If lFirst .AND. cCodConv == "xxxxxx"  //Novo conveniado. Para cada novo alias, lIncluir := .T.
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
                        lCriaConv       := .T.
                        lUsaCodCli      := .T.
                        cNewCod 		:= cProxNumSA1
                     //���������������������������������Ŀ
                     //�Criar o cart�o                   � 
                     //�����������������������������������                                                                                             
                     ElseIf cAliasGrv == "MA6"                                             
                        MA6->MA6_CODCLI  := cProxNumSA1
                        MA6->MA6_LOJA    := "01"                        
                        lMA6 := .T.
                     //���������������������������������Ŀ
                     //�Criar o complemento do cliente   � 
                     //�����������������������������������                                                
                     ElseIf cAliasGrv == "MA7"
                        MA7->MA7_CODCLI  := cProxNumSA1
                        MA7->MA7_LOJA    := "01"
                        MA7->MA7_DATA    := dDatabase
                     //���������������������������������Ŀ
                     //�Criar a referencia de trabalho   � 
                     //�����������������������������������                                                
                     ElseIf cAliasGrv == "MA8"                        
                        MA8->MA8_CODCLI  := cProxNumSA1
                        MA8->MA8_LOJA    := "01"
                        MA8->MA8_TIPO    := "1"  //Empresa atual
                        MA8->MA8_CODEMP  := cCodEmpresa
                        MA8->MA8_EMPRES  := cNomeEmp                               
                     //���������������������������������Ŀ
                     //�Criar a referencia de cartoes    � 
                     //�����������������������������������                                                
                     ElseIf cAliasGrv == "MA9"                                                
                        MA9->MA9_CODCLI  := cProxNumSA1
                        MA9->MA9_LOJA    := "01"                                             
                     //���������������������������������Ŀ
                     //�Criar a referencia de bancos     � 
                     //�����������������������������������                                                
                     ElseIf cAliasGrv == "MAA"                                                                        
                        MAA->MAA_CODCLI  := cProxNumSA1                                                              
                        MAA->MAA_LOJA    := "01"                        
                     //���������������������������������Ŀ
                     //�Criar a referencia pessoal       � 
                     //�����������������������������������                                                
                     ElseIf cAliasGrv == "MAB"                                                
                        MAB->MAB_CODCLI  := cProxNumSA1
                        MAB->MAB_LOJA    := "01"
                     //���������������������������������Ŀ
                     //�Criar o dependente do cliente    � 
                     //�����������������������������������                                                
                     ElseIf cAliasGrv == "MAC"                                                                        
                        MAC->MAC_CODCLI  := cProxNumSA1
                        MAC->MAC_LOJA    := "01"                        
                     //���������������������������������Ŀ
                     //�Criar o documento entregue       � 
                     //�����������������������������������                                                
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
                  //������������������������������������������������������������������������������������Ŀ
                  //�Relacionar o conveniado com a empresa de convenio atraves do cadastro de dependentes� 
                  //��������������������������������������������������������������������������������������                                       
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
         
         //������������������������������������������������������������������������������������Ŀ
         //�Efetua o desloqueio caso o conveniado esteja bloqueado                              � 
         //��������������������������������������������������������������������������������������                                       
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
               While !Eof() .AND. xFilial("MA6")+cCodConv+cLojConv == MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA .AND.;
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
                     cTxtLog  := "Conveniado de matr�cula "+AllTrim(cMatricula)+" est� bloqueado por motivo de desligamento da empresa."
                     cTxtLog  += "N�o � poss�vel atualizar seu status para Ativo."+CTRL               
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
	  //�������������������������������������������������������������Ŀ
	  //�Chama a funcao que realiza a geracao da numeracao dos cartoes�
	  //�importados na base de dados Atraves da rotina de             �
	  //�Importacao de Conveniados                                    �
	  //���������������������������������������������������������������
	  If !Empty(cNewCod)
		  aConvCart := T_DroGerTit( cNewCod	   , "01"     , lWizard  , lMA6      	,;
		   							@aConvCart , lProcCart, lNovoConv, @nQtdeINC )
	  Else
      	  nQtdeALT ++
	  Endif 							
	  //Atualiza o conteudo da variavel cNewCod
	  cNewCod := ""
   Next nX 
   END TRANSACTION 
EndIf   

//Ordena o array aConvCart pelo campo codigo
If Len(aConvCart) > 0
	aSort(aConvCart,,,{|x,y| x[1]<y[1]})
Endif

If lGeraLog
   MsgAlert("Foram encontradas algumas inconsist�ncias no processamento."+;
            "Verifique o arquivo de LOG gerado em "+cStartPath+"LogIMPORT.log no servidor.")
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DroCodSA1 �Autor  �Fernando Machima    � Data �  30/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca o ultimo codigo de cliente para inclusao de um novo  ���
���          � conveniado                                                 ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DroCodSA1(cNovoCodigo)

Local aArea       := GetArea()
Local oDlgConv 
Local oGetCodUlt
Local oSayCod
Local lRet        := .T.
Local cSayCod     := ""
Local cUltCodigo  := ""
Local nTamCodCli  := TamSX3("A1_COD")[1]
Local nNovoCodigo

cSayCod  := "Confirma a gera��o do(s) conveniado(s)   "+CTRL
cSayCod  += "a partir do c�digo identificado abaixo?  "+CTRL
cSayCod  += "Modifique o c�digo, caso seja necess�rio."+CTRL

DbSelectArea("SA1")
DbSetOrder(1)  
//Se o arquivo estiver vazio, assume "000001" como codigo do cliente
If RecCount() == 0
   cNovoCodigo  := StrZero(1,nTamCodCli)
//Se o arquivo tiver um registro(cliente padrao), assume "000001" se MV_CLIPAD <> "000001", caso contrario, assume "000002"
ElseIf RecCount() == 1
   DbSeek(xFilial("SA1"))
   cNovoCodigo  := StrZero(1,nTamCodCli)   
   If cNovoCodigo == GetMV("MV_CLIPAD")
      nNovoCodigo  := Val(cNovoCodigo)+1         
      cNovoCodigo  := StrZero(nNovoCodigo,nTamCodCli)         
   EndIf            
//Busca o codigo do ultimo cliente e soma 1        
Else   
   DbSeek(xFilial("SA1")+Replicate("Z",nTamCodCli),.T.)
   DbSkip(-1)
   If SA1->A1_COD == GetMV("MV_CLIPAD")
      DbSkip(-1)
   EndIf   
   cUltCodigo   := SA1->A1_COD   
   nNovoCodigo  := Val(cUltCodigo)+1
   FormatCod(cUltCodigo,nNovoCodigo,@cNovoCodigo)      
   //Verifica se o codigo ja existe
   SA1->(DbSetOrder(1))
   While SA1->(DbSeek(xFilial("SA1")+cNovoCodigo))
      cUltCodigo   := cNovoCodigo
      nNovoCodigo  := Val(cUltCodigo)+1
      FormatCod(cUltCodigo,nNovoCodigo,@cNovoCodigo)
   End
EndIf   

//Mostra o codigo pesquisado e confirma com o usuario
DEFINE MSDIALOG oDlgConv TITLE "C�digo do conveniado" FROM 9,0 TO 20,28.5 OF oMainWnd

@ .1,.3 TO 4.8,13.9

@ .7,.8 SAY oSayCod VAR cSayCod OF oDlgConv SIZE 50,10 

@ 3.9,4.2 GET oGetCodUlt VAR cNovoCodigo OF oDlgConv SIZE 40,10 

//�������������������������������������������������������������������������Ŀ
//� Botoes                                                                  �
//���������������������������������������������������������������������������
DEFINE SBUTTON FROM 069,23 TYPE 1 ACTION (Iif(VldCodConv(cNovoCodigo),(lRet:=.T.,oDlgConv:End()),NIL)) ENABLE OF oDlgConv
DEFINE SBUTTON FROM 069,63 TYPE 2 ACTION (lRet:=.F.,oDlgConv:End()) ENABLE OF oDlgConv

ACTIVATE MSDIALOG oDlgConv CENTERED

RestArea(aArea)

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FormatData�Autor  �Fernando Machima    � Data �  06/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Converte a data em formato caracter para tipo data conside-���
���          � rando a picture                                            ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
If !Empty(cDia) .AND. !Empty(cMes) .AND. !Empty(cAno)
	dData  := CToD(PadL(cDia,2,"0")+"/"+PadL(cMes,2,"0")+"/"+cAno)
Else
	lRet  := .F.
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldCodConv�Autor  �Fernando Machima    � Data �  06/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o codigo do conveniado verificando se jah existe na ���
���          � base de clientes                                           ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldCodConv(cCodigo)	

Local lRet  := .T.

cCodigo  := PadR(AllTrim(cCodigo),TamSX3("A1_COD")[1])
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+cCodigo))
   MsgAlert("C�digo de cliente j� cadastrado! Selecione outro c�digo.")
   lRet  := .F.   
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FormatValo�Autor  �Fernando Machima    � Data �  09/12/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Formata valores de acordo com a picture do layout          ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FormatValor(cValor,cPicture,nValorExp)

Local lRet          := .T.
Local nPosDec                 //Posicao do separador de decimais
Local nQtdDecimais  := 0
Local cTxtLog       := ""
Local cTemp         := ""

//Verifica pela picture quantos decimais tem o valor a ser importado
If AT(",",cPicture) > 0 .OR. AT(".",cPicture) > 0
	For nPosDec := Len(cPicture) to 1 STEP -1
		If Substr(cPicture,nPosDec,1) == "." .OR. Substr(cPicture,nPosDec,1) == ","
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
   cTxtLog  := "A picture para valor(num�rico) no layout de configura��o deve indicar a quantidade de casas decimais, ex: @E 999,999,999.99 "
   cTxtLog  += "ou o valor do arquivo de importa��o deve indicar as casas decimais."    
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FormatCod �Autor  �Fernando Machima    � Data �  07/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Formata o novo codigo do cliente de acordo com o ultimo    ���
���          � codigo                                                     ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Templates Drogaria                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
