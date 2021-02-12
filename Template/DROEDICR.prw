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
#Define __TAMTPREG         2
#DEFINE __TAMDELETADO      1

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma   ณDROEDICR    บAutor  ณGeronimo Benedito Alves      บ Data ณ  06/04/04   บฑฑ
ฑฑฬอออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.      ณ Configura็ใo dos arquivos EDI de Pedido de Compras (Somente Retorno)  บฑฑ
ฑฑฬอออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso        ณ Template Drogaria                                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Template Function DROEDICR

Local oDlg,oRad,oBmt1,oBmt2,oBmt3,oBmt4,oSay,oMtl1,oMtl2,oMtl3
Local nVar  := 1
Local nLin  := 1
Local nLin2 := 1
Local nLin3 := 1
Local aFld  := {'Cabe็alho','อtens','Rodap้'}
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

cHelp1 := "Help Cabe็alho"+CTRL+CTRL+"Para o EDI de recebimento de Pedidos de compras, nใo ้ aceito informa็๕es nas pastas Cabecalho e Rodap้."+CTRL
cHelp1 += "Digite as informa็๕es somente na pasta อtens "
cHelp2 := "Help อtens"+CTRL+"Campos a serem importados pelo EDI de compras. Eles devem apresentar o alias do arquivo. Ex: SC7->C7_ITEM"+CTRL
cHelp2 += "ศ obrigat๓rio indicar em qual tipo de registro o campo se encontra (coluna Tipo Registro) "+CTRL
cHelp2 += "ศ obrigat๓rio tambem a cria็ใo do campo TIPOREG indicando a posi็ใo dele no arquivo de retorno"
cHelp3 := cHelp1

cHelp  := cHelp2

//Formato aHeader
Aadd(aHeader,{"Titulo"          ,"TMP_TITULO" ,"@!" ,__TAMTITULO ,0,"!Empty(M->TMP_TITULO)",,"C",,"V",,,"oFld:nOption = 2"})   //1
Aadd(aHeader,{"Linha"           ,"TMP_LINHA"  ,"999",__TAMLINHA  ,0,,,"N",,"V",,,".F."})    //2
Aadd(aHeader,{"Col.Inicio"      ,"TMP_COLINI" ,"999",__TAMCOLINI ,0,"M->TMP_COLINI > 0 .And. T_AtTamPCR(M->TMP_COLINI,.T.)",,"N",,"V",,,"oFld:nOption = 2"})  //3
Aadd(aHeader,{"Tamanho"         ,"TMP_TAM"    ,"999",__TAMANHO   ,0,"M->TMP_TAM >= 0 .And. T_AtTamPCR(M->TMP_TAM,.F.)",,"N",,"V",,,"oFld:nOption = 2"})  //4
Aadd(aHeader,{"Col.Final"       ,"TMP_COLFIM" ,"999",__TAMCOLFIM ,0,,,"N",,"V",,,".F."})  //5
Aadd(aHeader,{"Tipo"            ,"TMP_TIPO"   ,"@!" ,__TAMTIPO   ,0,,,"C",,"V","1=Caracter;2=Num้rico;3=Data;4=Logico","1","oFld:nOption = 2"})  //6
Aadd(aHeader,{"Conte๚do"        ,"TMP_CONTE"  ,"@!" ,__TAMCONT   ,0,,,"C",,"V",,,"oFld:nOption = 2"})  //7
Aadd(aHeader,{"Picture"         ,"TMP_PICTURE","@!" ,__TAMPICTURE,0,,,"C",,"V",,,"oFld:nOption = 2"})  //8
Aadd(aHeader,{"Zeros เ esquerda","TMP_ZEROS"  ,"@!" ,__TAMZEROS  ,0,,,"C",,"V","1=Sim;2=Nใo","2","oFld:nOption = 2"})  //9-Indica se deve gerar o registro com zeros a esquerda 
Aadd(aHeader,{"Tipo Registro"   ,"TMP_TPREG"  ,"99" ,__TAMTPREG  ,0,"VAL(M->TMP_TPREG) > 0",,"C",,"V",,,"oFld:nOption = 2"})  //10-Tipo do registro no arquivo de retorno (cabecalho,item,obs,rodape,etc)
                                             
DEFINE MSDIALOG oDlg FROM  1,1 TO 480,640 TITLE "Configurador de Layout para Importa็ใo de Pedidos de Compras" Pixel

oRad  := TRadMenu():New(10,5,{"Arquivo de Receb."},bSETGET(nVar),oDlg,,{|| cArq := Substr(cArq,1,At(".",cArq))+"REC",oGet:Refresh()},,,,,,60,10,,,,.T.)
oGet  := IW_Edit(10,70,cArq,"@!",105,10,,,,,,{|x| Iif(PCount()>0,cArq := x,cArq)} )
oGet:lReadOnly:=.T.
nVar := 2
oBmt1 := SButton():New(5,290, 1, {|| EDIGravaC(oGd1,oGd2,oGd3,cArq,@oDlg,nVar) },,)
oBmt2 := SButton():New(19,290, 2, {|| oDlg:End() },,)
oBmt3 := SButton():New(5,260,14, {|| EDIRestorC(@oGd1,@oGd2,@oGd3,@cArq,nVar,@oGet) },,)
oBmt4 := SButton():New(19,260,15, {|| DROConCpoC() },,)
oGrp  := TGroup():New(34,2,239,319,"Estrutura do Arquivo",oDlg,,,.T.)
oFld  := TFolder():New(40,5,aFld,{''},oGrp,2,,,.T.,,311,153,)
oGrpOp:= TGroup():New(4,185,25,252,"Tipo de Exporta็ใo",oDlg,,,.T.)
oRadTipoEDI  := TRadMenu():New(11,190,{"Pedido de Compras"},bSETGET(nTipoEDI),oDlg,,,,,,,,60,10,,,,.T.)
oFld:bChange:={|| If(oFld:nOpTion==1,cHelp  := cHelp1,If(oFld:nOption==2,cHelp  := cHelp2,cHelp  := cHelp3)) , oHelp:Refresh() }            

oGD1  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[1],aHeader)
oGD1:bLinhaOk := {|| VlLinCabRodape() }
oGD2  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[2],aHeader)
oGD2:bLinhaOk := {|| VlLinEDIC() }
oGD3  := MsNewGetDados():New(1,1,139,308,nGetd,,,,,,9999,,,,oFld:aDialogs[3],aHeader)
oGD3:bLinhaOk := {|| VlLinCabRodape() }

oHelp := TMultiGet():New(194,8, bSETGET(cHelp),oGrp,304,40,,.T.,,,,.T.,,,,,,)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (aColsIni:=AClone(oGd1:aCols))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldArqPC  บAutor  ณCarlos A. Gomes Jr. บ Data ณ  07/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do nome do arquivos.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VldArqPC(cArq,nVar,oGet)
Local cExt := ".REC"

cArq := AllTrim(cArq)

If AT(".",cArq) == 0
	cArq := cArq+cExt
EndIf

If Upper(Substr(cArq,AT(".",cArq))) != cExt
	//MsgAlert("O nome do arquivo estแ invแlido e serแ corrigido!")
	cArq := Upper(Substr(cArq,1,AT(".",cArq)-1))+cExt
EndIf

cArq := cArq + Space(40-Len(cArq))
oGet:Refresh()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtTamPCR  บAutor  ณCarlos A. Gomes Jr. บ Data ณ  10/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo da coluna Final                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function AtTamPCR(nVal,lIni)
If lIni
   aCols[n][5] := aCols[n][4] + nVal - 1
Else
   aCols[n][5] := aCols[n][3] + nVal - 1
EndIf
Return .T.

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVlLinEDIC บAutor  ณCarlos A. Gomes Jr. บ Data ณ  10/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Linha da GetDados                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VlLinEDIC
Local lRet := .T.
Do Case
Case Empty(aCols[n][1])
	MsgAlert("Tํtulo do campo nใo preenchido!")
	lRet := .F.
Case aCols[n][3] <= 0
	MsgAlert("Coluna inicial nใo definida!")
	lRet := .F.
Case aCols[n][4] < 0
	MsgAlert("Tamanho do campo invแlido!")
	lRet := .F.
Case val(aCols[n][10]) <= 0
	MsgAlert("Tipo do registro Invalido."+CTRL +"Informe um tipo de registro entre 1 e 99")
	lRet := .F.
EndCase
Return lRet

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVlLinCabRodape    ณGeronimo B. Alves   บ Data ณ  07/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Linha da GetDados do Cabecalho e rodape             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VlLinCabRodape()
Local lRet := .F.
MsgAlert("Para o EDI de recebimento de Pedidos de compras, nใo ้ aceito informa็๕es nas pastas cabecalho e rodap้.  Digite as informa็๕es somente na pasta ์tens  ")
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEDIGravaC บAutor  ณCarlos A. Gomes Jr. บ Data ณ  10/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava vetor com configuracao do arquivo.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EDIGravaC(oGd1,oGd2,oGd3,cArq,oDlg,nVar)
Local lGrava  := .T.
Local lTemPedido := .T.  // Com .T. nao eh obrigatorio o numero do pedido nos Itens no retorno
Local aSalvar := {AClone(oGd1:aCols),AClone(oGd2:aCols),AClone(oGd3:aCols)}
Local nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao do cabecalho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX := 1 to Len(oGd1:aCols)
   If oGd1:aCols[nX][Len(oGd1:aCols[nX])]
      Loop
   EndIf
   //Valida se a linha do layout eh maior que zero
   If !Empty(oGd1:aCols[nX][1]) .And. oGd1:aCols[nX][2] <= 0
	  MsgAlert("Linha invแlida para o item "+AllTrim(Str(nX))+" do cabe็alho. O valor deve ser maior que zero.")
	  lGrava := .F.
   EndIf	                                               
   //Validacao de data
   If lGrava 
      If oGd1:aCols[nX][6] == "2" //Tipo de dado: Numero
         If Empty(oGd1:aCols[nX][8])  
            MsgAlert("Informar a picture de formata็ใo do n๚mero para o item "+AllTrim(Str(nX))+" do cabe็alho. Ex: @E 999,999,999.99")      
            lGrava  := .F.   
         EndIf   
      ElseIf oGd1:aCols[nX][6] == "3" //Tipo de dado: Data
         If Empty(oGd1:aCols[nX][8])  
            MsgAlert("Informar a picture de formata็ใo da data para o item "+AllTrim(Str(nX))+" do cabe็alho. Ex: AAAAMMDD")      
            lGrava  := .F.
         Else
            //Verifica se a picture da data esta configurada corretamente
            lGrava  := CfgVldPicC(oGd1:aCols[nX][8],oGd1:aCols[nX][4])
         EndIf   
         If lGrava .And. oGd1:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Cabe็alho: A propriedade Zeros a Esquerda nใo ้ vแlida para o tipo Data")         
            lGrava  := .F.
         EndIf
      ElseIf oGd1:aCols[nX][6] == "4" //Tipo de dado: Logico         
         If oGd1:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Cabe็alho: A propriedade Zeros a Esquerda nใo ้ vแlida para o tipo L๓gico")         
            lGrava  := .F.
         EndIf      
      EndIf   
      //Verifica se o alias eh valido no SX2      
      If lGrava .And. Substr(oGd1:aCols[nX][7],4,2) == "->"  
         SX2->(DbSetOrder(1))   
         If !SX2->(DbSeek(Substr(oGd1:aCols[nX][7],1,3),.F.))
            MsgAlert("Cabe็alho: O alias "+Substr(oGd1:aCols[nX][7],1,3)+" nใo existe no dicionแrio de dados(SX2).")         
            lGrava  := .F.            
         EndIf
      EndIf      
      //Verifica se o campo eh valido no SX3. Deve indicar o alias do campo.
      If lGrava .And. Substr(oGd1:aCols[nX][7],4,2) == "->"  
         SX3->(DbSetOrder(2))   
         If !SX3->(DbSeek(Substr(oGd1:aCols[nX][7],6,10),.F.))
            MsgAlert("Cabe็alho: O campo "+Substr(oGd1:aCols[nX][7],6)+" nใo existe no dicionแrio de dados(SX3).")         
            lGrava  := .F.            
         EndIf
      EndIf
   EndIf
   If !lGrava
      Exit
   EndIf
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao dos itens     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrava
   For nX := 1 to Len(oGd2:aCols)
      If oGd2:aCols[nX][Len(oGd2:aCols[nX])]
         Loop
      EndIf              
      If oGd2:aCols[nX][6] == "2" //Tipo de dado: Numero
         If Empty(oGd2:aCols[nX][8])  //Picture
            MsgAlert("Informar a picture de formata็ใo do n๚mero para o item "+AllTrim(Str(nX))+" da pasta Itens. Ex: @E 999,999,999.99")      
            lGrava  := .F.      
         EndIf   
      //Validacao de data
      ElseIf oGd2:aCols[nX][6] == "3" //Tipo de dado: Data
         If Empty(oGd2:aCols[nX][8])  //Picture
            MsgAlert("Informar a picture de formata็ใo da data para o item "+AllTrim(Str(nX))+" da pasta Itens. Ex: AAAAMMDD")      
            lGrava  := .F.
         Else
            //Verifica se a picture da data esta configurada corretamente
            lGrava  := CfgVldPicC(oGd2:aCols[nX][8],oGd2:aCols[nX][4])
         EndIf         
         If lGrava .And. oGd2:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Itens: A propriedade Zeros a Esquerda nใo ้ vแlida para o tipo Data")         
            lGrava  := .F.
         EndIf
      ElseIf oGd2:aCols[nX][6] == "4" //Tipo de dado: Logico         
         If oGd2:aCols[nX][9] == "1"  //Zeros a esquerda
            MsgAlert("Itens: A propriedade Zeros a Esquerda nใo ้ vแlida para o tipo L๓gico")         
            lGrava  := .F.
         EndIf               
      EndIf   
      //Verifica se o alias eh valido no SX2      
      If lGrava .And. Substr(oGd2:aCols[nX][7],4,2) == "->"  
         SX2->(DbSetOrder(1))   
         If !SX2->(DbSeek(Substr(oGd2:aCols[nX][7],1,3),.F.))
            MsgAlert("Itens: O alias "+Substr(oGd2:aCols[nX][7],1,3)+" nใo existe no dicionแrio de dados(SX2).")         
            lGrava  := .F.            
         EndIf
      EndIf            
      //Verifica se o campo eh valido no SX3
      If lGrava .And. Substr(oGd2:aCols[nX][7],4,2) == "->"  
         If Len(AllTrim(Substr(oGd2:aCols[nX][7],6))) > 10
            MsgAlert("Itens: O campo "+AllTrim(Substr(oGd2:aCols[nX][7],6))+" nใo existe no dicionแrio de dados(SX3)."+CTRL+;
                     "O tamanho do campo ้ maior que o permitido.")         
            lGrava  := .F.                     
         EndIf         
         SX3->(DbSetOrder(2))   
         If lGrava .And. !SX3->(DbSeek(Substr(oGd2:aCols[nX][7],6,10),.F.))
            MsgAlert("Itens: O campo "+Substr(oGd2:aCols[nX][7],6)+" nใo existe no dicionแrio de dados(SX3).")         
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
   If lGrava .And. !lTemPedido .And. nVar == 2
      MsgAlert("Informar o pedido de compras na pasta Itens para sua identifica็ใo na importa็ใo EDI.")         
      lGrava  := .F.
   EndIf   
EndIf   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao do rodape     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrava
   For nX := 1 to Len(oGd3:aCols)
      If oGd3:aCols[nX][Len(oGd3:aCols[nX])]
         Loop
      EndIf
      //Valida se a linha do layout eh maior que zero
      If !Empty(oGd3:aCols[nX][1]) .And. oGd3:aCols[nX][2] <= 0
	     MsgAlert("Linha invแlida para o item "+AllTrim(Str(nX))+" do rodap้. O valor deve ser maior que zero.")
	     lGrava := .F.
      EndIf	                                                    
      //Validacao de data      
      If lGrava 
         If oGd3:aCols[nX][6] == "2" //Tipo de dado: Numero
            If Empty(oGd3:aCols[nX][8])  
               MsgAlert("Informar a picture de formata็ใo do n๚mero para o item "+AllTrim(Str(nX))+" do rodap้. Ex: @E 999,999,999.99")      
               lGrava  := .F.      
            EndIf   
         ElseIf oGd3:aCols[nX][6] == "3" //Tipo de dado: Data
            If Empty(oGd3:aCols[nX][8])  
               MsgAlert("Informar a picture de formata็ใo da data para o item "+AllTrim(Str(nX))+" do rodap้. Ex: AAAAMMDD")      
               lGrava  := .F.
            Else 
               //Verifica se a picture da data esta configurada corretamente
               lGrava  := CfgVldPicC(oGd3:aCols[nX][8],oGd3:aCols[nX][4])
            EndIf   
            If lGrava .And. oGd3:aCols[nX][9] == "1"  //Zeros a esquerda
               MsgAlert("Rodap้: A propriedade Zeros a Esquerda nใo ้ vแlida para o tipo Data")         
               lGrava  := .F.
            EndIf
         ElseIf oGd3:aCols[nX][6] == "4" //Tipo de dado: Logico         
            If oGd3:aCols[nX][9] == "1"  //Zeros a esquerda
               MsgAlert("Rodap้: A propriedade Zeros a Esquerda nใo ้ vแlida para o tipo L๓gico")         
               lGrava  := .F.
            EndIf                           
         EndIf   
      EndIf
      //Verifica se o alias eh valido no SX2      
      If lGrava .And. Substr(oGd3:aCols[nX][7],4,2) == "->"  
         SX2->(DbSetOrder(1))   
         If !SX2->(DbSeek(Substr(oGd3:aCols[nX][7],1,3),.F.))
            MsgAlert("Rodap้: O alias "+Substr(oGd3:aCols[nX][7],1,3)+" nใo existe no dicionแrio de dados(SX2).")         
            lGrava  := .F.            
         EndIf
      EndIf            
      //Verifica se o campo eh valido no SX3
      If lGrava .And. Substr(oGd3:aCols[nX][7],4,2) == "->"  
         SX3->(DbSetOrder(2))   
         If !SX3->(DbSeek(Substr(oGd3:aCols[nX][7],6,10),.F.))
            MsgAlert("Rodap้: O campo "+Substr(oGd3:aCols[nX][7],6)+" nใo existe no dicionแrio de dados(SX3).")         
            lGrava  := .F.            
         EndIf
      EndIf            
      If !lGrava
         Exit
      EndIf      
   Next nX
EndIf   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ๖
//ณCriacao de uma janela para informar         ณ
//ณpara qual fornecedor serah gerado os LAYOUTSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ๖

//nVar = 1 --> Arquivo de Envio
//nVar = 2 --> Arquivo de Recebimento
If lGrava
	nVar := 2
	T_DroCriarTe(nVar,@cArq,"C")
Endif

If File(cArq) .And. lGrava
	lGrava := MsgYesNo("Arquivo jแ existe. Deseja Sobreescrever?")
EndIf

//Salva o arquivo de configuracao
If lGrava
    Aadd(aSalvar,nTipoEDI)
	__VSave(aSalvar,cArq)
	oDlg:End()
EndIf

Return (lGrava)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEDIRestorCบAutor  ณCarlos A. Gomes Jr. บ Data ณ  10/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava vetor com configuracao do arquivo.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EDIRestorC(oGd1,oGd2,oGd3,cArq,nVar,oGet)
Local aRestore := {}
Local cExt    := "Arquivos de Recebimento |*.REC|"
Local cTmp    := ""
Local nX
Local nRegExcl := 0

cTmp := cGetFile(cExt,"Escolha o arquivo a ser configurado.",0,"SERVIDOR"+cArq,.T.,GETF_ONLYSERVER)

If !Empty(cTmp)
	cArq := cTmp
	VldArqPC(@cArq,nVar,@oGet)
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
		          Aadd(oGd1:aCols,{Space(__TAMTITULO),0,0,0,0,"1",Space(__TAMCONT),Space(__TAMPICTURE),.F.})   
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
		          Aadd(oGd2:aCols,{Space(__TAMTITULO),0,0,0,0,"1",Space(__TAMCONT),Space(__TAMPICTURE),.F.})   
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
		          Aadd(oGd3:aCols,{Space(__TAMTITULO),0,0,0,0,"1",Space(__TAMCONT),Space(__TAMPICTURE),.F.})   
		       EndIf		       
			EndIf			              			
			nTipoEDI   := aRestore[4]
	        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 	        //ณSetar lNewLine para .F. porque excluia a ultima linha ณ
 	        //ณao clicar na Getdados                                 ณ 	        
        	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
            oGD1:lNewLine  := .F.			
            oGD2:lNewLine  := .F.			            
            oGD3:lNewLine  := .F.			            
			oGd1:Refresh()
			oGd2:Refresh()
			oGd3:Refresh()
			oRadTipoEDI:Refresh()
		Else
			MsgAlert("Arquivo invแlido.")
		EndIf
	Else
		MsgInfo("Arquivo nใo encontrado. Serแ criado um novo.")
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCfgVldPicCบAutor  ณFernando Machima    บ Data ณ  10/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a picture da data                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CfgVldPicC(cPicture,nTamanho)

Local nPosDia  := 0
Local nPosMes  := 0
Local nPosAno  := 0
Local lRet     := .T. 

cPicture  := Upper(cPicture)
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
   MsgAlert("A picture de formata็ใo da data deve ter, pelo menos, 2 digitos para o dia, para o m๊s e para o ano. Ex: AAAAMMDD, DDMMAA")         
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDROConCpoCบAutor  ณFernando Machima    บ Data ณ  09/11/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a consulta do dicionario de campos de um alias      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DROConCpoC()
Local nX         := 0    //Contador do sistema
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Botoes                                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE SBUTTON FROM 007,45 TYPE 1 ACTION (Iif(VldAliasC(@cAliasSX3,@cNomeArq),oDlgAlias:End(),NIL)) ENABLE OF oDlgAlias
DEFINE SBUTTON FROM 023,45 TYPE 2 ACTION (lContinua:=.F.,oDlgAlias:End()) ENABLE OF oDlgAlias

ACTIVATE MSDIALOG oDlgAlias CENTERED

If !lContinua
   Return .F.
EndIf

dbSelectArea( "SX3" )
dbSetOrder( 1 )
dbSeek( cAliasSX3 )
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz a montagem da estrutura do alias selcionado                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !Eof() .AND. X3_ARQUIVO == cAliasSX3
   AAdd( aList,{X3_TITULO,X3_CAMPO,X3_TAMANHO,X3_DECIMAL} )
   dbSkip()
End

If Len(aList) == 0
   MsgAlert("Nใo foi encontrado nenhum campo habilitado para uso do alias "+cAliasSX3)
   Return .F.
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da Tela.                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgCons TITLE "Estrutura do arquivo "+cNomeArq FROM 9,0 TO 30,52 OF oMainWnd

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Botao de saida.                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE SBUTTON FROM 004,170 TYPE 2 ACTION (oDlgCons:End()) ENABLE OF oDlgCons

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Listbox.                                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ .5,.7 LISTBOX oListBox VAR cListBox Fields HEADER "Nome","Tํtulo","Tamanho","Decimais" SIZE 155,145

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz a configuracao da ListBox.                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oListBox:SetArray(aList)
oListBox:bLine := { || { aList[oListBox:nAt,1],aList[oListBox:nAt,2],aList[oListBox:nAt,3],aList[oListBox:nAt,4]} }

ACTIVATE MSDIALOG oDlgCons CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณVldAliasC บAutor  ณFernando Machima    บ Data ณ  09/11/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do alias digitado para consulta dos campos       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template Drogaria                                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function VldAliasC(cAliasSX3,cNomeArq)

Local lRet  := .T.

If Empty(cAliasSX3)
   MsgAlert("Selecione um alias!")
   lRet  := .F.
Else
   cAliasSX3  := Upper(cAliasSX3)
   dbSelectArea( "SX2" )
   dbSetOrder( 1 )
   If dbSeek( cAliasSX3 )
      cNomeArq  := AllTrim(Capital(SX2->X2_NOME))
   Else
      MsgAlert("Alias nใo encontrado no dicionแrio de dados!")
      lRet  := .F.
   EndIf   
EndIf

Return lRet