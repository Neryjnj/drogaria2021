//Extras
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

//Getdados
#Define GD_INSERT	1
#Define GD_UPDATE	2
#Define GD_DELETE	4

//Pula Linha
#Define CTRL Chr(10)+Chr(13)

////////////////////////////////////////////////////////////
// Rotina: ConfImpTab                                     //
//--------------------------------------------------------//
// Rotina de configura��o do arquivo layout de importacao //
// da tabela de precos                                    //
//////////////////////////////////////////////////////////// 
 
Template Function ConfImpTab()

Local oDlg,oRad,oBmt1,oBmt2,oBmt3,oBmt4,oSay,oMtl1,oMtl2,oMtl3
Local nVar  := 1
Local nLin  := 1
Local nLin2 := 1
Local nLin3 := 1
Local aFld  := {'Cabe�alho','�tens','Rodap�'}
Local cArq  := "/system/novo.ret"+Space(23)
Local nGetd := GD_INSERT+GD_UPDATE+GD_DELETE

Local cHelp1 := "Help Cabe�alho"+CTRL+CTRL+"Aqui est� o texto de Help dos campos para cabe�alho!"
Local cHelp2 := "Help �tens"+CTRL+CTRL+"Aqui est� o texto de Help dos campos para �tens!"
Local cHelp3 := "Help Rodap�"+CTRL+CTRL+"Aqui est� o texto de Help dos campos para rodap�!"

Local cHelp  := cHelp1

Private oFld
Private aHeader := {}
Private aItens  := {{},{},{}}
Private aColsIni:= {}

/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

//Formato aHeader
Aadd(aHeader,{"Titulo"          ,"TMP_TITULO" ,"@!",15,0,"!Empty(M->TMP_TITULO)",,"C",,"V"})
Aadd(aHeader,{"Linha"           ,"TMP_LINHA"  ,"9999", 2,0,,,"N",,"V",,,"oFld:nOption != 2"})
Aadd(aHeader,{"Col.Inicio"      ,"TMP_COLINI" ,"9999", 3,0,"M->TMP_COLINI > 0 .And. T_AtuTamTP(M->TMP_COLINI,.T.)",,"N",,"V",,})
Aadd(aHeader,{"Tamanho"         ,"TMP_TAM"    ,"9999", 3,0,"M->TMP_TAM > 0 .And. T_AtuTamTP(M->TMP_TAM,.F.)",,"N",,"V"})
Aadd(aHeader,{"Col.Final"       ,"TMP_COLFIM" ,"9999", 3,0,,,"N",,"V",,,".F."})
Aadd(aHeader,{"Tipo"            ,"TMP_TIPO"   ,"@!", 1,0,,,"C",,"V","1=Caracter;2=Num�rico;3=Data;4=Logico","1"})
Aadd(aHeader,{"Conte�do"        ,"TMP_CONTE"  ,"@!",50,0,,,"C",,"V"})
Aadd(aHeader,{"Picture"         ,"TMP_PICTURE","@!",20,0,,,"C",,"V"})

                                             
DEFINE MSDIALOG oDlg FROM  1,1 TO 480,640 TITLE "Configurador para Importa��o de Tabelas de Pre�os" Pixel

oSay  := tSay():New(10,10,{||"Arquivo de retorno:"},oDlg,,,,,,.T.,,,,)
oGet  := IW_Edit(10,60,cArq,"@!",140,10,,,,,,{|x| Iif(PCount()>0,cArq := x,cArq)} )
//oGet:lReadOnly:=.T.
oBmt1 := SButton():New(8,260, 1, {|| EDIGrava(oGd1,oGd2,oGd3,cArq,@oDlg) },,)
oBmt2 := SButton():New(8,290, 2, {|| oDlg:End() },,)
oBmt3 := SButton():New(8,230,14, {|| EDIRestore(@oGd1,@oGd2,@oGd3,@cArq,@oGet) },,)
oGrp  := TGroup():New(30,2,239,319,"Estrutura do Arquivo",oDlg,,,.T.)
oFld  := TFolder():New(38,5,aFld,{''},oGrp,1,,,.T.,,311,153,)
oFld:bChange:={|| If(oFld:nOpTion==1,cHelp  := cHelp1,If(oFld:nOption==2,cHelp  := cHelp2,cHelp  := cHelp3)) , oHelp:Refresh() }

oGD1  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[1],aHeader)
oGD1:bLinhaOk := {|| ValLinEDI() }
oGD2  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[2],aHeader)
oGD2:bLinhaOk := {|| ValLinEDI() }
oGD3  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[3],aHeader)
oGD3:bLinhaOk := {|| ValLinEDI() }

oHelp := TMultiGet():New(194,8, bSETGET(cHelp),oGrp,304,40,,.T.,,,,.T.,,,,,,)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (aColsIni:=AClone(oGd1:aCols))

Return

/*���������������������������������������������������������������������������
���Programa  �ValidArq  �Autor  �Carlos A. Gomes Jr. � Data �  07/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o do nome do arquivos.                             ���
���������������������������������������������������������������������������*/
Static Function ValidArq(cArq,oGet)
Local cExt := ".ret"

cArq := AllTrim(cArq)

If AT(".",cArq) == 0
	cArq := cArq+cExt
EndIf

If lower(Substr(cArq,AT(".",cArq))) != cExt
	MsgAlert("O nome do arquivo est� inv�lido e ser� corrigido!")
	cArq := Lower(Substr(cArq,1,AT(".",cArq)-1))+cExt
EndIf

cArq := cArq + Space(40-Len(cArq))
oGet:Refresh()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtuTamTP  �Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calculo da coluna Final                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function AtuTamTP(nVal,lIni)
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
���Programa  �ValLinEDI �Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida Linha da GetDados                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValLinEDI
Local lRet := .T.
Do Case
Case Empty(aCols[n][1])
	MsgAlert("T�tulo do campo n�o preenchido")
	lRet := .F.
Case aCols[n][3] <= 0
	MsgAlert("Coluna inicial n�o definida")
	lRet := .F.
Case aCols[n][4] <= 0
	MsgAlert("Tamanho do campo n�o definido")
	lRet := .F.
EndCase
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIGrava  �Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava vetor com configuracao do arquivo.                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIGrava(oGd1,oGd2,oGd3,cArq,oDlg)
Local lGrava  := .T.
Local aSalvar := {AClone(oGd1:aCols),AClone(oGd2:aCols),AClone(oGd3:aCols)}
Local nX

//����������������������������������������������Ŀ
//� Valida se a linha do layout eh maior que zero�
//������������������������������������������������
For nX := 1 to Len(oGd1:aCols)
   If oGd1:aCols[nX][Len(oGd1:aCols[nX])]
      Loop
   EndIf
   If !Empty(oGd1:aCols[nX][1]) .And. oGd1:aCols[nX][2] <= 0
	  MsgAlert("Linha inv�lida para o item "+AllTrim(Str(nX))+" do cabe�alho. O valor deve ser maior que zero.")
	  lGrava := .F.
   EndIf	  
Next nX

If lGrava
   For nX := 1 to Len(oGd3:aCols)
      If oGd3:aCols[nX][Len(oGd3:aCols[nX])]
         Loop
      EndIf
      If !Empty(oGd3:aCols[nX][1]) .And. oGd3:aCols[nX][2] <= 0
	     MsgAlert("Linha inv�lida para o item "+AllTrim(Str(nX))+" do rodap�. O valor deve ser maior que zero.")
	     lGrava := .F.
      EndIf	  
   Next nX
EndIf   

If File(cArq) .And. lGrava
	lGrava := MsgYesNo("Arquivo j� existe. Deseja Sobreescrever?")
EndIf

If lGrava
	__VSave(aSalvar,cArq)
	oDlg:End()
EndIf

Return (lGrava)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIRestore�Autor  �Carlos A. Gomes Jr. � Data �  10/05/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava vetor com configuracao do arquivo.                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EDIRestore(oGd1,oGd2,oGd3,cArq,oGet)
Local aRestore := {}
Local cTmp    := ""

cTmp := cGetFile("Arquivos de Retorno |*.ret|", "Escolha o arquivo a ser configurado.",0,"SERVIDOR"+cArq,.T.)

If !Empty(cTmp)
	cArq := cTmp
	ValidArq(@cArq,@oGet)
	If File(cArq)
		aRestore   := __VRestore(cArq)
		If Len(aRestore) == 3
			oGd1:aCols := AClone(aRestore[1])
			oGd2:aCols := AClone(aRestore[2])
			oGd3:aCols := AClone(aRestore[3])
	        //������������������������������������������������������Ŀ
 	        //�Setar lNewLine para .F. porque excluia a ultima linha �
 	        //�ao clicar na Getdados                                 � 	        
        	//��������������������������������������������������������			
            oGD1:lNewLine  := .F.			
            oGD2:lNewLine  := .F.			            
            oGD3:lNewLine  := .F.			            
			oGd1:Refresh()
			oGd2:Refresh()
			oGd3:Refresh()
		Else
			MsgAlert("Arquivo inv�lido.")
		EndIf
	Else
		MsgInfo("Arquivo n�o encontrado. Ser� criado um novo.")
		oGd1:aCols := AClone(aColsIni)
		oGd2:aCols := AClone(aColsIni)
		oGd3:aCols := AClone(aColsIni)
	EndIf
EndIf
	
Return