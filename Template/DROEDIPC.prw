#include "protheus.ch"
 
//Extras
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

//Getdados
#Define GD_INSERT	1
#Define GD_UPDATE	2
#Define GD_DELETE	4

//Pula Linha
#Define CTRL Chr(10)+Chr(13)

//Tamanho dos campos do aCols
#Define __TAMTITULO        15
#Define __TAMLINHA         2
#Define __TAMCOLINI        3
#Define __TAMANHO          3
#Define __TAMCOLFIM        3
#Define __TAMTIPO          1
#Define __TAMCONT          100
#Define __TAMPICTURE       20
#Define __TAMZEROS         1

/*���������������������������������������������������������������������������������������
���Programa   �DROEDIPC    �Autor  �Carlos A. Gomes Jr.          � Data �  07/05/04   ���
�������������������������������������������������������������������������������������͹��
���Desc.      � Configura��o dos arquivos EDI de Pedido de Compras (Somente Envio)    ���
�������������������������������������������������������������������������������������͹��
���Uso        � Template Drogaria                                                     ���
���������������������������������������������������������������������������������������*/

Template Function DROEDIPC
Local oDlg,oRad,oBmt1,oBmt2,oBmt3,oBmt4
Local nVar  := 1
Local aFld  := {'Cabe�alho','�tens','Rodap�'}
Local cStartPath := GetSrvProfString("STARTPATH","")
Local cArq  := cStartPath+Space(23)
Local nGetd := GD_INSERT+GD_UPDATE+GD_DELETE

Local cHelp1 := ""
Local cHelp2 := ""
Local cHelp3 := ""

Local cHelp  := ""

Private oFld, oRadTipoEDI
Private aHeader := {}
Private aItens  := {{},{},{}}
Private aColsIni:= {}
Private nTipoEDI := 1  //1=Cabecalho;2=Itens;3=Total

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

cHelp1 := "Help Cabe�alho"+CTRL+CTRL+"Preencher os dados do cabe�alho a serem gravados no arquivo de envio."+CTRL
cHelp1 += "Os campos devem, obrigatoriamente, apresentar o alias do arquivo. Ex: SC7->C7_NUM"
cHelp2 := "Help �tens"+CTRL+CTRL+"Preencher os detalhes a serem exportados pelo processo EDI de "+CTRL
cHelp2 += "compras. Os campos devem, obrigatoriamente, apresentar o alias do arquivo. Ex: SC7->C7_ITEM"
cHelp3 := "Help Rodap�"+CTRL+CTRL+"Preencher os dados do rodap� a serem gravados no arquivo de envio."+CTRL
cHelp3 += "Os campos devem, obrigatoriamente, apresentar o alias do arquivo. Ex: SC7->C7_TOTAL"

cHelp  := cHelp1

//Formato aHeader
Aadd(aHeader,{"Titulo"          ,"TMP_TITULO" ,"@!" ,__TAMTITULO ,0,"!Empty(M->TMP_TITULO)",,"C",,"V"})   //1
Aadd(aHeader,{"Linha"           ,"TMP_LINHA"  ,"999",__TAMLINHA  ,0,,,"N",,"V",,,"oFld:nOption != 2"})    //2
Aadd(aHeader,{"Col.Inicio"      ,"TMP_COLINI" ,"999",__TAMCOLINI ,0,"M->TMP_COLINI > 0 .And. T_AtuTamPC(M->TMP_COLINI,.T.)",,"N",,"V",,})  //3
Aadd(aHeader,{"Tamanho"         ,"TMP_TAM"    ,"999",__TAMANHO   ,0,"M->TMP_TAM >= 0 .And. T_AtuTamPC(M->TMP_TAM,.F.)",,"N",,"V"})  //4
Aadd(aHeader,{"Col.Final"       ,"TMP_COLFIM" ,"999",__TAMCOLFIM ,0,,,"N",,"V",,,".F."})  //5
Aadd(aHeader,{"Tipo"            ,"TMP_TIPO"   ,"@!" ,__TAMTIPO   ,0,,,"C",,"V","1=Caracter;2=Num�rico;3=Data;4=Logico","1"})  //6
Aadd(aHeader,{"Conte�do"        ,"TMP_CONTE"  ,"@!" ,__TAMCONT   ,0,,,"C",,"V"})  //7
Aadd(aHeader,{"Picture"         ,"TMP_PICTURE","@!" ,__TAMPICTURE,0,,,"C",,"V"})  //8
Aadd(aHeader,{"Zeros � esquerda","TMP_ZEROS"  ,"@!" ,__TAMZEROS  ,0,,,"C",,"V","1=Sim;2=N�o","2"})  //9-Indica se deve gerar o registro com zeros a esquerda 
                                             
DEFINE MSDIALOG oDlg FROM  1,1 TO 480,640 TITLE "Configurador de Layout para Exporta��o de Pedidos de Compras" Pixel

oRad  := TRadMenu():New(10,5,{"Arquivo de Envio"},bSETGET(nVar),oDlg,,{|| cArq := Substr(cArq,1,At(".",cArq))+"ENV",oGet:Refresh()},,,,,,60,10,,,,.T.)
oGet  := IW_Edit(10,70,cArq,"@!",105,10,,,,,,{|x| Iif(PCount()>0,cArq := x,cArq)} )
oGet:lReadOnly:=.T.
oBmt1 := SButton():New(5,290, 1, {|| EDIGravaC(oGd1,oGd2,oGd3,cArq,@oDlg,nVar) },,)
oBmt2 := SButton():New(19,290, 2, {|| oDlg:End() },,)
oBmt3 := SButton():New(5,260,14, {|| EDIRestorC(@oGd1,@oGd2,@oGd3,@cArq,nVar,@oGet) },,)
oBmt4 := SButton():New(19,260,15, {|| DROConCpoC() },,)
oGrp  := TGroup():New(34,2,239,319,"Estrutura do Arquivo",oDlg,,,.T.)
oFld  := TFolder():New(40,5,aFld,{''},oGrp,1,,,.T.,,311,153,)
oGrpOp:= TGroup():New(4,185,25,252,"Tipo de Exporta��o",oDlg,,,.T.)
oRadTipoEDI  := TRadMenu():New(11,190,{"Pedido de Compras"},bSETGET(nTipoEDI),oDlg,,,,,,,,60,10,,,,.T.)
oFld:bChange:={|| If(oFld:nOpTion==1,cHelp  := cHelp1,If(oFld:nOption==2,cHelp  := cHelp2,cHelp  := cHelp3)) , oHelp:Refresh() }            

oGD1  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[1],aHeader)
oGD1:bLinhaOk := {|| T_VlLinEDPC() }
oGD2  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[2],aHeader)
oGD2:bLinhaOk := {|| T_VlLinEDPC() }
oGD3  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[3],aHeader)
oGD3:bLinhaOk := {|| T_VlLinEDPC() }

oHelp := TMultiGet():New(194,8, bSETGET(cHelp),oGrp,304,40,,.T.,,,,.T.,,,,,,)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (aColsIni:=AClone(oGd1:aCols))

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldArqPC  �Autor  �Carlos A. Gomes Jr. � Data �  07/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o do nome do arquivos.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function VldArqPC(cArq,nVar,oGet)
Local cExt := ".env"

cArq := AllTrim(cArq)

If AT(".",cArq) == 0
	cArq := cArq+cExt
EndIf

If Substr(cArq,AT(".",cArq)) != cExt
	//MsgAlert("O nome do arquivo est� inv�lido e ser� corrigido!")
	cArq := Substr(cArq,1,AT(".",cArq)-1)+cExt
EndIf

cArq := cArq + Space(40-Len(cArq))
oGet:Refresh()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuTamPC  �Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calculo da coluna Final                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function AtuTamPC(nVal,lIni)
If lIni
   aCols[n][5] := aCols[n][4] + nVal - 1
Else
   aCols[n][5] := aCols[n][3] + nVal - 1
EndIf
Return .T.

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VlLinEDPC �Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida Linha da GetDados                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function VlLinEDPC
Local lRet := .T.
Do Case
Case Empty(aCols[n][1])
	MsgAlert("T�tulo do campo n�o preenchido!")
	lRet := .F.
Case aCols[n][3] <= 0
	MsgAlert("Coluna inicial n�o definida!")
	lRet := .F.
Case aCols[n][4] < 0
	MsgAlert("Tamanho do campo inv�lido!")
	lRet := .F.
EndCase
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIGravaC �Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava vetor com configuracao do arquivo.                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIGravaC(oGd1,oGd2,oGd3,cArq,oDlg,nVar)
Local lGrava  := .T.
Local lTemPedido := .T.  // Com .T. nao eh obrigatorio o numero do pedido nos Itens no retorno
Local aSalvar := {AClone(oGd1:aCols),AClone(oGd2:aCols),AClone(oGd3:aCols)}
Local nX

//������������������������Ŀ
//�Validacao do cabecalho  �
//��������������������������
For nX := 1 to Len(oGd1:aCols)
   If oGd1:aCols[nX][Len(oGd1:aCols[nX])]
      Loop
   EndIf
   //Valida se a linha do layout eh maior que zero
   If !Empty(oGd1:aCols[nX][1]) .And. oGd1:aCols[nX][2] <= 0
	  MsgAlert("Linha inv�lida para o item "+AllTrim(Str(nX))+" do cabe�alho. O valor deve ser maior que zero.")
	  lGrava := .F.
   EndIf	                                               
   //Validacao de data
   If lGrava 
      If oGd1:aCols[nX][6] == "2" //Tipo de dado: Numero
         If Empty(oGd1:aCols[nX][8])  
            MsgAlert("Informar a picture de formata��o do n�mero para o item "+AllTrim(Str(nX))+" do cabe�alho. Ex: @E 999,999,999.99")      
            lGrava  := .F.   
         EndIf   
      ElseIf oGd1:aCols[nX][6] == "3" //Tipo de dado: Data
         If Empty(oGd1:aCols[nX][8])  
            MsgAlert("Informar a picture de formata��o da data para o item "+AllTrim(Str(nX))+" do cabe�alho. Ex: AAAAMMDD")      
            lGrava  := .F.
         Else
            //Verifica se a picture da data esta configurada corretamente
            lGrava  := CfgVldPicC(oGd1:aCols[nX][8],oGd1:aCols[nX][4])
         EndIf   
         If lGrava .And. oGd1:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Cabe�alho: A propriedade Zeros a Esquerda n�o � v�lida para o tipo Data")         
            lGrava  := .F.
         EndIf
      ElseIf oGd1:aCols[nX][6] == "4" //Tipo de dado: Logico         
         If oGd1:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Cabe�alho: A propriedade Zeros a Esquerda n�o � v�lida para o tipo L�gico")         
            lGrava  := .F.
         EndIf      
      EndIf   
      //Verifica se o alias eh valido no SX2      
      If lGrava .And. Substr(oGd1:aCols[nX][7],4,2) == "->"  
         SX2->(DbSetOrder(1))   
         If !SX2->(DbSeek(Substr(oGd1:aCols[nX][7],1,3),.F.))
            MsgAlert("Cabe�alho: O alias "+Substr(oGd1:aCols[nX][7],1,3)+" n�o existe no dicion�rio de dados(SX2).")         
            lGrava  := .F.            
         EndIf
      EndIf      
      //Verifica se o campo eh valido no SX3. Deve indicar o alias do campo.
      If lGrava .And. Substr(oGd1:aCols[nX][7],4,2) == "->"  
         SX3->(DbSetOrder(2))   
         If !SX3->(DbSeek(Substr(oGd1:aCols[nX][7],6,10),.F.))
            MsgAlert("Cabe�alho: O campo "+Substr(oGd1:aCols[nX][7],6)+" n�o existe no dicion�rio de dados(SX3).")         
            lGrava  := .F.            
         EndIf
      EndIf
   EndIf
   If !lGrava
      Exit
   EndIf
Next nX

//������������������������Ŀ
//�Validacao dos itens     �
//��������������������������
If lGrava
   For nX := 1 to Len(oGd2:aCols)
      If oGd2:aCols[nX][Len(oGd2:aCols[nX])]
         Loop
      EndIf              
      If oGd2:aCols[nX][6] == "2" //Tipo de dado: Numero
         If Empty(oGd2:aCols[nX][8])  //Picture
            MsgAlert("Informar a picture de formata��o do n�mero para o item "+AllTrim(Str(nX))+" da pasta Itens. Ex: @E 999,999,999.99")      
            lGrava  := .F.      
         EndIf   
      //Validacao de data
      ElseIf oGd2:aCols[nX][6] == "3" //Tipo de dado: Data
         If Empty(oGd2:aCols[nX][8])  //Picture
            MsgAlert("Informar a picture de formata��o da data para o item "+AllTrim(Str(nX))+" da pasta Itens. Ex: AAAAMMDD")      
            lGrava  := .F.
         Else
            //Verifica se a picture da data esta configurada corretamente
            lGrava  := CfgVldPicC(oGd2:aCols[nX][8],oGd2:aCols[nX][4])
         EndIf         
         If lGrava .And. oGd2:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Itens: A propriedade Zeros a Esquerda n�o � v�lida para o tipo Data")         
            lGrava  := .F.
         EndIf
      ElseIf oGd2:aCols[nX][6] == "4" //Tipo de dado: Logico         
         If oGd2:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Itens: A propriedade Zeros a Esquerda n�o � v�lida para o tipo L�gico")         
            lGrava  := .F.
         EndIf               
      EndIf   
      //Verifica se o alias eh valido no SX2      
      If lGrava .And. Substr(oGd2:aCols[nX][7],4,2) == "->"  
         SX2->(DbSetOrder(1))   
         If !SX2->(DbSeek(Substr(oGd2:aCols[nX][7],1,3),.F.))
            MsgAlert("Itens: O alias "+Substr(oGd2:aCols[nX][7],1,3)+" n�o existe no dicion�rio de dados(SX2).")         
            lGrava  := .F.            
         EndIf
      EndIf            
      //Verifica se o campo eh valido no SX3
      If lGrava .And. Substr(oGd2:aCols[nX][7],4,2) == "->"  
         If Len(AllTrim(Substr(oGd2:aCols[nX][7],6))) > 10
            MsgAlert("Itens: O campo "+AllTrim(Substr(oGd2:aCols[nX][7],6))+" n�o existe no dicion�rio de dados(SX3)."+CTRL+;
                     "O tamanho do campo � maior que o permitido.")         
            lGrava  := .F.                     
         EndIf         
         SX3->(DbSetOrder(2))   
         If lGrava .And. !SX3->(DbSeek(Substr(oGd2:aCols[nX][7],6,10),.F.))
            MsgAlert("Itens: O campo "+Substr(oGd2:aCols[nX][7],6)+" n�o existe no dicion�rio de dados(SX3).")         
            lGrava  := .F.            
         EndIf
      EndIf      
      //Layout de importacao
      If lGrava .And. nVar == 2
         //Para o layout de importacao o numero do pedido de compras eh obrigatorio
         If "C7_NUM"$oGd2:aCols[nX][7]
            lTemPedido  := .T.
         EndIf
         //Validacao da picture para numero
         If lGrava .And. oGd2:aCols[nX][6] == "2" //Tipo de dado: Numero
            If !Empty(oGd2:aCols[nX][8])   //Picture
               If AT(",",oGd2:aCols[nX][8]) == 0 .And. AT(".",oGd2:aCols[nX][8]) == 0
                  MsgAlert("Itens: Informar o separador de decimais na picture, ex: @E 999,999,999.99")      
                  lGrava  := .F.                                 
               EndIf
            EndIf
         EndIf
      EndIf
      If !lGrava
         Exit
      EndIf      
   Next nX
EndIf   
//������������������������Ŀ
//�Validacao do rodape     �
//��������������������������
If lGrava
   For nX := 1 to Len(oGd3:aCols)
      If oGd3:aCols[nX][Len(oGd3:aCols[nX])]
         Loop
      EndIf
      //Valida se a linha do layout eh maior que zero
      If !Empty(oGd3:aCols[nX][1]) .And. oGd3:aCols[nX][2] <= 0
	     MsgAlert("Linha inv�lida para o item "+AllTrim(Str(nX))+" do rodap�. O valor deve ser maior que zero.")
	     lGrava := .F.
      EndIf	                                                    
      //Validacao de data      
      If lGrava 
         If oGd3:aCols[nX][6] == "2" //Tipo de dado: Numero
            If Empty(oGd3:aCols[nX][8])  
               MsgAlert("Informar a picture de formata��o do n�mero para o item "+AllTrim(Str(nX))+" do rodap�. Ex: @E 999,999,999.99")      
               lGrava  := .F.      
            EndIf   
         ElseIf oGd3:aCols[nX][6] == "3" //Tipo de dado: Data
            If Empty(oGd3:aCols[nX][8])  
               MsgAlert("Informar a picture de formata��o da data para o item "+AllTrim(Str(nX))+" do rodap�. Ex: AAAAMMDD")      
               lGrava  := .F.
            Else 
               //Verifica se a picture da data esta configurada corretamente
               lGrava  := CfgVldPicC(oGd3:aCols[nX][8],oGd3:aCols[nX][4])
            EndIf   
            If lGrava .And. oGd3:aCols[nX][9] == "1"  //Zeros a esquerda
               MsgAlert("Rodap�: A propriedade Zeros a Esquerda n�o � v�lida para o tipo Data")         
               lGrava  := .F.
            EndIf
         ElseIf oGd3:aCols[nX][6] == "4" //Tipo de dado: Logico         
            If oGd3:aCols[nX][9] == "1"  //Zeros a esquerda
               MsgAlert("Rodap�: A propriedade Zeros a Esquerda n�o � v�lida para o tipo L�gico")         
               lGrava  := .F.
            EndIf                           
         EndIf   
      EndIf
      //Verifica se o alias eh valido no SX2      
      If lGrava .And. Substr(oGd3:aCols[nX][7],4,2) == "->"  
         SX2->(DbSetOrder(1))   
         If !SX2->(DbSeek(Substr(oGd3:aCols[nX][7],1,3),.F.))
            MsgAlert("Rodap�: O alias "+Substr(oGd3:aCols[nX][7],1,3)+" n�o existe no dicion�rio de dados(SX2).")         
            lGrava  := .F.            
         EndIf
      EndIf            
      //Verifica se o campo eh valido no SX3
      If lGrava .And. Substr(oGd3:aCols[nX][7],4,2) == "->"  
         SX3->(DbSetOrder(2))   
         If !SX3->(DbSeek(Substr(oGd3:aCols[nX][7],6,10),.F.))
            MsgAlert("Rodap�: O campo "+Substr(oGd3:aCols[nX][7],6)+" n�o existe no dicion�rio de dados(SX3).")         
            lGrava  := .F.            
         EndIf
      EndIf            
      If !lGrava
         Exit
      EndIf      
   Next nX
EndIf   

//����������������������������������������������
//�Criacao de uma janela para informar         �
//�para qual fornecedor serah gerado os LAYOUTS�
//����������������������������������������������

//nVar = 1 --> Arquivo de Envio
//nVar = 2 --> Arquivo de Recebimento
If ((Len(oGd1:aCols) >= 1 .And. !Empty(oGd1:aCols[1,1])) .And. ;
      (Len(oGd2:aCols) >= 1 .And. !Empty(oGd2:aCols[1,1])) .And. ;
      (Len(oGd3:aCols) >= 1 .And. !Empty(oGd3:aCols[1,1])))
   If lGrava
      T_DroCriarTe(nVar,@cArq,"C")
   EndIf
Else
   lGrava := .F.   
EndIf

If File(cArq) .And. lGrava
	lGrava := MsgYesNo("Arquivo j� existe. Deseja Sobreescrever?")
EndIf

//Salva o arquivo de configuracao
If lGrava
    Aadd(aSalvar,nTipoEDI)
	__VSave(aSalvar,cArq)
	oDlg:End()
EndIf

Return (lGrava)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIRestorC�Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava vetor com configuracao do arquivo.                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIRestorC(oGd1,oGd2,oGd3,cArq,nVar,oGet)
Local aRestore := {}
Local cExt    := "Arquivos de Envio |*.env|"
Local cTmp    := ""
Local nX
Local nRegExcl := 0

cTmp := cGetFile(cExt,"Escolha o arquivo a ser configurado.",0,"SERVIDOR"+cArq,.T.,GETF_ONLYSERVER)
If !Empty(cTmp)
	cArq := cTmp
	T_VldArqPC(@cArq,nVar,@oGet)
	If File(cArq)
		aRestore   := __VRestore(cArq)
		If Len(aRestore) == 4
			oGd1:aCols := AClone(aRestore[1])
			oGd2:aCols := AClone(aRestore[2])
			oGd3:aCols := AClone(aRestore[3])
			//Se alguma linha tinha sido excluida, nao mostra no aCols
			nRegExcl := 0
			nX       := 1
			While nX <= Len(oGd1:aCols)
			   If nX == 0 
			      nX++
			      Loop
			   EndIf			
			   If oGd1:aCols[nX] <> Nil .And. oGd1:aCols[nX][Len(oGd1:aCols[nX])]
		          Adel( oGd1:aCols, nX )
		          nRegExcl++
		          nX--
		       Else
		          nX++   
			   EndIf
			End
						
			//Se todas as linhas foram excluidas gerar uma linha em branco			
			If nRegExcl > 0
		       Asize( oGd1:aCols, Len(oGd1:aCols)-nRegExcl )			   
		       If Len(oGd1:aCols) == 0
		          Aadd(oGd1:aCols,{Space(__TAMTITULO),0,0,0,0,"1",Space(__TAMCONT),Space(__TAMPICTURE),"2",.F.})   
		       EndIf
			EndIf
			nRegExcl  := 0
			nX        := 1
			While nX <= Len(oGd2:aCols)
			   If nX == 0 
			      nX++
			      Loop
			   EndIf			
			   If oGd2:aCols[nX] <> Nil .And. oGd2:aCols[nX][Len(oGd2:aCols[nX])]
		          Adel( oGd2:aCols, nX )
		          nRegExcl++
		          nX--
		       Else
		          nX++   
			   EndIf
			End
			If nRegExcl > 0
		       Asize( oGd2:aCols, Len(oGd2:aCols)-nRegExcl )			   
		       If Len(oGd2:aCols) == 0
		          Aadd(oGd2:aCols,{Space(__TAMTITULO),0,0,0,0,"1",Space(__TAMCONT),Space(__TAMPICTURE),"2",.F.})   
		       EndIf		       
			EndIf			              
			nRegExcl  := 0
			nX        := 1
			While nX <= Len(oGd3:aCols)
			   If nX == 0 
			      nX++
			      Loop
			   EndIf
			   If oGd3:aCols[nX] <> Nil .And. oGd3:aCols[nX][Len(oGd3:aCols[nX])]
		          Adel( oGd3:aCols, nX )
		          nRegExcl++
		          nX--
		       Else
		          nX++   
			   EndIf
			End
			If nRegExcl > 0
            Asize( oGd3:aCols, Len(oGd3:aCols)-nRegExcl )			   		       
            If Len(oGd3:aCols) == 0
               Aadd(oGd3:aCols,{Space(__TAMTITULO),0,0,0,0,"1",Space(__TAMCONT),Space(__TAMPICTURE),"2",.F.})   
            EndIf		       
			EndIf			              			
			nTipoEDI   := aRestore[4]
         //������������������������������������������������������Ŀ
         //�Setar lNewLine para .F. porque excluia a ultima linha �
         //�ao clicar na Getdados                                 � 	        
         //��������������������������������������������������������			
         oGD1:lNewLine  := .F.			
         oGD2:lNewLine  := .F.			            
         oGD3:lNewLine  := .F.
         //Verifico se possui apenas uma linha em branco
         If ((Len(oGd1:aCols) == 1 .And. Empty(oGd1:aCols[1,1])) .And. ;
               (Len(oGd2:aCols) == 1 .And. Empty(oGd2:aCols[1,1])) .And.; 
               (Len(oGd3:aCols) == 1 .And. Empty(oGd3:aCols[1,1])) )
               MsgInfo("N�o foi poss�vel realizar a importa��o, pois n�o possui layout v�lido no arquivo!!!","Importa��o de Layout")
         EndIf
         
			oGd1:Refresh()
         oGd2:Refresh()
         oGd3:Refresh()
			oRadTipoEDI:Refresh()
   
		Else
			MsgAlert("Arquivo inv�lido.")
		EndIf
	Else
		MsgInfo("Arquivo n�o encontrado. Ser� criado um novo.")
		oGd1:aCols := AClone(aColsIni)
		oGd2:aCols := AClone(aColsIni)
		oGd3:aCols := AClone(aColsIni)
		oGd1:Refresh()
		oGd2:Refresh()
		oGd3:Refresh()
		nTipoEDI   := 1
	EndIf
EndIf
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CfgVldPicC�Autor  �Fernando Machima    � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a picture da data                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CfgVldPicC(cPicture,nTamanho)

Local nPosDia  := 0
Local nPosMes  := 0
Local nPosAno  := 0
Local lRet     := .T. 

cPicture  := UPPER(cPicture)
nPosDia  := AT("DD",cPicture)
nPosMes  := AT("MM",cPicture)
nPosAno  := AT("AA",cPicture)      

lRet     := nPosDia > 0 .And. nPosMes > 0 .And. nPosAno > 0

//Valida se o tamanho da string a ser gravada no arquivo de exportacao eh maior ou igual a picture de data
If lRet
   If nTamanho < Len(AllTrim(cPicture))     
      MsgAlert("A coluna Tamanho(para datas) deve ser maior ou igual ao tamanho da picture.")       
      lRet  := .F.
   EndIf
Else
   MsgAlert("A picture de formata��o da data deve ter, pelo menos, 2 digitos para o dia, para o m�s e para o ano. Ex: AAAAMMDD, DDMMAA")         
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DROConCpoC�Autor  �Fernando Machima    � Data �  09/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Efetua a consulta do dicionario de campos de um alias      ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DROConCpoC()
Local oDlgCons           //Dialog da Listbox
Local oListBox           //Objeto da listbox
Local oDlgAlias           
Local oGetAlias
Local cAliasSX3  := Space(3)
Local cNomeArq   := ""
Local aList      := {}
Local lContinua  := .T.

DEFINE MSDIALOG oDlgAlias TITLE "Selecione o Alias" FROM 9,0 TO 15,22 OF oMainWnd

@ .1,.3 TO 3,10.5

@ .5,1 GET oGetAlias VAR cAliasSX3 OF oDlgAlias SIZE 25,10 

//�������������������������������������������������������������������������Ŀ
//� Botoes                                                                  �
//���������������������������������������������������������������������������
DEFINE SBUTTON FROM 007,45 TYPE 1 ACTION (Iif(VldAliasC(@cAliasSX3,@cNomeArq),oDlgAlias:End(),NIL)) ENABLE OF oDlgAlias
DEFINE SBUTTON FROM 023,45 TYPE 2 ACTION (lContinua:=.F.,oDlgAlias:End()) ENABLE OF oDlgAlias

ACTIVATE MSDIALOG oDlgAlias CENTERED

If !lContinua
   Return .F.
EndIf

dbSelectArea( "SX3" )
dbSetOrder( 1 )
dbSeek( cAliasSX3 )
	
//�������������������������������������������������������������������������Ŀ
//� Faz a montagem da estrutura do alias selcionado                         �
//���������������������������������������������������������������������������
While !Eof() .AND. X3_ARQUIVO == cAliasSX3
   AAdd( aList,{X3_TITULO,X3_CAMPO,X3_TAMANHO,X3_DECIMAL} )
   dbSkip()
End

If Len(aList) == 0
   MsgAlert("N�o foi encontrado nenhum campo habilitado para uso do alias "+cAliasSX3)
   Return .F.
EndIf
	
//�������������������������������������������������������������������������Ŀ
//� Montagem da Tela.                                                       �
//���������������������������������������������������������������������������
DEFINE MSDIALOG oDlgCons TITLE "Estrutura do arquivo "+cNomeArq FROM 9,0 TO 30,52 OF oMainWnd

//�������������������������������������������������������������������������Ŀ
//� Botao de saida.                                                         �
//���������������������������������������������������������������������������
DEFINE SBUTTON FROM 004,170 TYPE 2 ACTION (oDlgCons:End()) ENABLE OF oDlgCons

//�������������������������������������������������������������������������Ŀ
//� Listbox.                                                                �
//���������������������������������������������������������������������������
@ .5,.7 LISTBOX oListBox VAR cListBox Fields HEADER "Nome","T�tulo","Tamanho","Decimais" SIZE 155,145

//�������������������������������������������������������������������������Ŀ
//� Faz a configuracao da ListBox.                                          �
//���������������������������������������������������������������������������
oListBox:SetArray(aList)
oListBox:bLine := { || { aList[oListBox:nAt,1],aList[oListBox:nAt,2],aList[oListBox:nAt,3],aList[oListBox:nAt,4]} }

ACTIVATE MSDIALOG oDlgCons CENTERED

Return

/*���������������������������������������������������������������������������
���Programa  �VldAliasC �Autor  �Fernando Machima    � Data �  09/11/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao do alias digitado para consulta dos campos       ���
�������������������������������������������������������������������������͹��
���Uso       � Template Drogaria                                          ���
���������������������������������������������������������������������������*/
Static Function VldAliasC(cAliasSX3,cNomeArq)
Local lRet  := .T.

If Empty(cAliasSX3)
   MsgAlert("Selecione um alias!")
   lRet  := .F.
Else
   cAliasSX3  := UPPER(cAliasSX3)
   DbSelectArea( "SX2" )
   DbSetOrder( 1 )
   If DbSeek( cAliasSX3 )
      cNomeArq  := AllTrim(Capital(SX2->X2_NOME))
   Else
      MsgAlert("Alias n�o encontrado no dicion�rio de dados!")
      lRet  := .F.
   EndIf   
EndIf

Return lRet