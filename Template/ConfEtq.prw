#Include "Protheus.ch"
#Include "Folder.ch"
#Include "Confetq.ch"

//////////////////////////////////////////////////////////
// Rotina: ConfEtq                                      //
//------------------------------------------------------//
// Rotina para configurar etiquetas                     //
//////////////////////////////////////////////////////////    

Template Function ConfEtq()

// 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// � Define Variaveis                                            �
// 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local bExec
Local oDlg

Private nOpcf   :=1
Private aCabec  :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Private aDetail :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Private aTrail  :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Private aImpr   :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Private cFile   :=""
Private cType   :=""
Private nBcoHdl :=0
Private aI      := {}
 
/*
旼컴컴컴컴컴컴컴컴컴컴컴컴�
� Arquivo de Conf. Nota   �
�       Fiscal            �
�                         �
� Memoria de Calculo      �     
� Registro 1 - USUARIOS   �     
� - Identif    CHR(n)   1 �
� - Descricao do Campo 25 �     
� - Posicao Inical      3 �       
� - Posicao Final       3 �     
� - Tamanho             3 �     
� - Campo/Conteudo     80 �	  
읕컴컴컴컴컴컴컴컴컴컴컴컴�    

旼컴컴컴컴컴컴컴컴컴컴컴컴�     
쿔dentificadores          �     
� CHR(1)   - Cabecalho    �
� CHR(2)   - Detalhe      �
� CHR(3)   - Rodape       �
� CHR(5)   - Parametros   �     
읕컴컴컴컴컴컴컴컴컴컴컴컴�
*/

// 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// � Padrao para Parametros
// 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Aadd(aI,{"Margem superior          ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Margem inferior          ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Margem lateral           ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Distancia vertical       ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Largura da etiqueta      ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Etiquetas por linha      ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Linhas por p�gina        ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Altura da p�gina         ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Largura da p�gina        ",Space(03),Space(03),"0  ",Space(200),Space(20)})
Aadd(aI,{"Tamanho p�g.(P=0/M=1/G=2)",Space(03),Space(03),"0  ",Space(200),Space(20)})

// 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// � Recupera o desenho padrao de atualizacoes                   �
// 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
DEFINE MSDIALOG oDlg FROM 94,1 TO 243,293 TITLE OemToAnsi(STR0001) PIXEL //"Configurador de Nota Fiscal"
                                                                 	
@ 10,17 Say OemToAnsi(STR0002) SIZE 150,7 OF oDlg PIXEL  // "Estrutura뇙o dos arquivos de LayOut utilizados"
@ 18,40 Say OemToAnsi(STR0003) SIZE 100,7 OF oDlg PIXEL  // "na Emissao da Nota Fiscal"

@ 45, 007 Button OemToAnsi(STR0004) SIZE 33, 11 OF oDlg PIXEL   Action(nOpcf:=1,TypeFile(),ChangeFile()   ,If(!Empty(cFile),EditCNAB(oDlg),nOpcf:=0))        Font oDlg:oFont // "Novo"
@ 45, 040 Button OemToAnsi(STR0005) SIZE 33, 11 OF oDlg PIXEL   Action(nOpcf:=2,TypeFile(),ChangeFile()   ,If(!Empty(cFile),RestFile(oDlg),nOpcf:=0))        Font oDlg:oFont // "Restaura"
@ 45, 073 Button OemToAnsi(STR0006) SIZE 33, 11 OF oDlg PIXEL   Action(nOpcf:=3,TypeFile(),ChangeFile()   ,If(!Empty(cFile),RestFile(oDlg,.T.),nOpcf:=0))   Font oDlg:oFont // "Excluir"
@ 45, 106 Button OemToAnsi(STR0007) SIZE 33, 11 OF oDlg PIXEL   Action(nopcf:=4,oDlg:End())                                                                 		Font oDlg:oFont // "Cancelar"

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿎hangeFile� Autor � Marcos Patricio       � Data � 05.02.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Escolhe arquivo ou cria arquivo para padroniza눯o CNAB     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � ChangeFile()                                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATCONF                                                    낢�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�*/
Static Function ChangeFile()

Local cFileChg
//Local cCheck
//Local cBack     := cFile

If Empty(cType)
   cType    :=Iif(nOpcf==1,OemToAnsi(STR0008)+'*.ETQ',OemToAnsi(STR0008)+'SIGA.ETQ') // "Saida | "	### "Saida | "
Endif

cFileChg    :=cGetFile(cType, OemToAnsi(OemToAnsi(STR0009))) // "Selecione arquivo"

If  Empty(cFileChg)
	cFile:=""
	Return
Endif

If  "."$cFileChg
	cFileChg := Substr(cFileChg,1,rat(".", cFileChg)-1)
Endif

cFileChg    := alltrim(cFileChg)
cFile       := Alltrim(cFileChg+Right(cType,4))

If  nOpcf == 1
	If  File(cFile)
		cFile:=""
		Help(" ",1,"AX014EXIST")
		Return
	Endif
Else
	cType := OemToAnsi(STR0008)+cFile	// "Etiquetas | "
Endif

Return
/*
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿐ditCNAB  � Autor � Marcos Patricio       � Data � 05.02.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿐dita LayOut do arquivo CNAB                                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   쿐ditCnab(oDlg,cFile)                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿽Dlg     - Objeto pai da janela                             낢�
굇�          쿬File    - Arquivo a ser Criado/Editado                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATCONF                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Last change:  CIA   5 Feb 96    9:44 am
*/
Static Function EditCNAB(oDlg,lDele)

Local oDlgLayOut
local oGetH
Local oGetD
Local oGetT
Local oLbCabec
Local oLbDetail
Local oLbTrail
Local oLbImpr
Local oBarCabec
Local oBarDetail
Local oBarTrail
Local oBarImpr
Local nControl  := 0
Local aTitles   := {}
Local aPages    := {}
Local nCabec    := 0
Local nDetail   := 0
Local nTrail    := 0
Local nImpr     := 0
Local lConfigma := .T.
Local cTamCols	:= ""         
Local i			:= 0

lDele   :=IIF(lDele==NIL,.F.,lDele)

If nOpcf == 1 
   aImpr := Aclone(aI)
Endif

AADD(aTitles,OemToAnsi(STR0011))  // "Cabecalho"
AADD(aPages,"HEADER")
nControl++
nCabec := nControl

AADD(aTitles,OemToAnsi(STR0045))  // "Detelhe"
AADD(aPages,"DETAIL")
nControl++
nDetail := nControl

AADD(aTitles,OemToAnsi(STR0047))  // "Rodape"
AADD(aPages,"TRAIL")
nControl++
nTrail := nControl

AADD(aTitles,OemToAnsi(STR0042))  // "Parametros"
AADD(aPages,"IMPR")
nControl++
nImpr := nControl

SETAPILHA()

DEFINE MSDIALOG oDlgLayOut TITLE OemToAnsi(STR0012)+Space(05)+cFile ;  // "Layout da N.F."   ###  "Saida"   ### "Entrada"
FROM 8.0,0 to 34.5,81 OF oMainWnd

oFolder := TFolder():New(.5,.2,aTitles, aPages,oDlgLayOut,,,, .F., .F.,315,170,)

For i:= 1 to Len(oFolder:aDialogs)
	oFolder:aDialogs[i]:oFont := oDlgLayOut:oFont
Next

oFolder:aPrompts[1] := OemToAnsi(STR0013) // "&Cabecalho"
oFolder:aPrompts[2] := OemToAnsi(STR0046) // "&Detalhe"
oFolder:aPrompts[3] := OemToAnsi(STR0048) // "&Rodape"
oFolder:aPrompts[4] := OemToAnsi(STR0038) // "&Parametros"

PUBLIC nLastKey := 0

DEFINE SBUTTON FROM 180,255.5 TYPE 1 ENABLE OF oDlgLayOut ACTION (If(lConfirma:=If(lDele,DeleFile(),If(ValTudo(),SaveFile(),.f.)),oDlgLayout:End(),NIL))
DEFINE SBUTTON FROM 180,285.5 TYPE 2 ENABLE OF oDlgLayOut ACTION (oDlgLayOut:End())
             
// Header
#IFNDEF PROTHEUS
	@ 1,.2 LISTBOX oLbCabec FIELDS HEADER	 OemToAnsi(STR0014),; // "Descricao"
														OemToAnsi(STR0015),;	//"Linha"
														OemToAnsi(STR0016),;	//"Coluna"
														OemToAnsi(STR0017),;	//"Tamanho"
														OemToAnsi(STR0018),
														"Picture";  // "Conteudo"
	COLSIZES 90,60,60,60,60 ;
	SIZE 307,140 OF oFolder:aDialogs[nCabec]  ;
	ON DBLCLICK (LinOut(oLbCabec:nAt,"H",.F.),oLbCabec:Refresh()) // Edi눯o

#ELSE
	@ 1,.2 LISTBOX oLbCabec FIELDS HEADER	 OemToAnsi(STR0014),; // "Descricao"
														OemToAnsi(STR0015),;	//"Linha"
														OemToAnsi(STR0016),;	//"Coluna"
														OemToAnsi(STR0017),;	//"Tamanho"
														OemToAnsi(STR0018),;
														"Picture";  // "Conteudo"
	COLSIZES 50,30,30,30,30 ;
	SIZE 307,140 OF oFolder:aDialogs[nCabec]  ;
	ON DBLCLICK (LinOut(oLbCabec:nAt,"H",.F.),oLbCabec:Refresh()) // Edi눯o
#ENDIF


oLbCabec:SetArray(aCabec)
oLbCabec:bLine   := { || { aCabec[oLbCabec:nAt,1] ,;
								 	 aCabec[oLbCabec:nAt,2] ,;
									 aCabec[oLbCabec:nAt,3] ,;
									 aCabec[oLbCabec:nAt,4] ,;
									 aCabec[oLbCabec:nAt,5] ,;
									 aCabec[oLbCabec:nAt,6] } } 
									 
// Detalhe
#IFNDEF PROTHEUS
	@ 1,.2 LISTBOX oLbDetail FIELDS HEADER 	OemToAnsi(STR0014),; // "Descricao"
											OemToAnsi(STR0015),;	//"Linha"
											OemToAnsi(STR0016),;	//"Coluna"
											OemToAnsi(STR0017),;	//"Tamanho"
											OemToAnsi(STR0018),;
											"Picture";  // "Conteudo"
	COLSIZES 90,60,60,60,60;
	SIZE 307,140 OF oFolder:aDialogs[nDetail] ;
	ON DBLCLICK (LinOut(oLbDetail:nAt,"D",.F.),oLbDetail:Refresh()) // Edi눯o
#ELSE
	@ 1,.2 LISTBOX oLbDetail FIELDS HEADER 	OemToAnsi(STR0014),; // "Descricao"
														OemToAnsi(STR0015),;	//"Linha"
														OemToAnsi(STR0016),;	//"Coluna"
														OemToAnsi(STR0017),;	//"Tamanho"
														OemToAnsi(STR0018),;
														"Picture";  // "Conteudo"
	COLSIZES 50,30,30,30,30;
	SIZE 307,140 OF oFolder:aDialogs[nDetail] ;
	ON DBLCLICK (LinOut(oLbDetail:nAt,"D",.F.),oLbDetail:Refresh()) // Edi눯o
#ENDIF

oLbDetail:SetArray(aDetail)
oLbDetail:bLine   := { || {        aDetail[oLbDetail:nAt,1] ,;
            						aDetail[oLbDetail:nAt,2] ,;
									aDetail[oLbDetail:nAt,3] ,;
									aDetail[oLbDetail:nAt,4] ,;
									aDetail[oLbDetail:nAt,5] ,;
									aDetail[oLbDetail:nAt,6] } }

// Rodape
#IFNDEF PROTHEUS
	@ 1,.2 LISTBOX oLbTrail FIELDS HEADER 	OemToAnsi(STR0014),; // "Descricao"
											OemToAnsi(STR0015),;	//"Linha"
											OemToAnsi(STR0016),;	//"Coluna"
											OemToAnsi(STR0017),;	//"Tamanho"
											OemToAnsi(STR0018),;
											"Picture";  // "Conteudo"
	COLSIZES 90,60,60,60,60;
	SIZE 307,140 OF oFolder:aDialogs[nTrail] ;
	ON DBLCLICK (LinOut(oLbTrail:nAt,"R",.F.),oLbTrail:Refresh()) // Edi눯o
#ELSE
	@ 1,.2 LISTBOX oLbTrail FIELDS HEADER 	OemToAnsi(STR0014),; // "Descricao"
														OemToAnsi(STR0015),;	//"Linha"
														OemToAnsi(STR0016),;	//"Coluna"
														OemToAnsi(STR0017),;	//"Tamanho"
														OemToAnsi(STR0018),;
														"Picture";  // "Conteudo"
	COLSIZES 50,30,30,30,30;
	SIZE 307,140 OF oFolder:aDialogs[nTrail] ;
	ON DBLCLICK (LinOut(oLbTrail:nAt,"R",.F.),oLbTrail:Refresh()) // Edi눯o
#ENDIF

oLbTrail:SetArray(aTrail)
oLbTrail:bLine   := { || {         aTrail[oLbTrail:nAt,1] ,;
            					    aTrail[oLbTrail:nAt,2] ,;
									aTrail[oLbTrail:nAt,3] ,;
									aTrail[oLbTrail:nAt,4] ,;
									aTrail[oLbTrail:nAt,5] ,;
									aTrail[oLbTrail:nAt,6] } }


// Parametros
#IFNDEF PROTHEUS
	@ 1,.2 LISTBOX oLbImpr FIELDS HEADER	OemToAnsi(STR0014),; // "Descricao"
														OemToAnsi(STR0015),;	//"Linha"
														OemToAnsi(STR0016),;	//"Coluna"
														OemToAnsi(STR0017),;	//"Tamanho"
														OemToAnsi(STR0018);  // "Conteudo"
	COLSIZES 90,60,60,60,60;
	SIZE 307,140 OF oFolder:aDialogs[nImpr] ;
	ON DBLCLICK (LinOut(oLbImpr:nAt,"I",.F.),oLbImpr:Refresh()) // Edi눯o
#ELSE
	@ 1,.2 LISTBOX oLbImpr FIELDS HEADER 	OemToAnsi(STR0014),; // "Descricao"
														OemToAnsi(STR0015),;	//"Linha"
														OemToAnsi(STR0016),;	//"Coluna"
														OemToAnsi(STR0017),;	//"Tamanho"
														OemToAnsi(STR0018);  // "Conteudo"
	COLSIZES 50,30,30,30,30;
	SIZE 307,140 OF oFolder:aDialogs[nImpr] ;
	ON DBLCLICK (LinOut(oLbImpr:nAt,"I",.F.),oLbImpr:Refresh()) // Edi눯o
#ENDIF

oLbImpr:SetArray(aImpr)
oLbImpr:bLine   := { || { aImpr[oLbImpr:nAt,1] ,;
									aImpr[oLbImpr:nAt,2] ,;
									aImpr[oLbImpr:nAt,3] ,;
									aImpr[oLbImpr:nAt,4] ,;
									aImpr[oLbImpr:nAt,5] } }

ACTIVATE DIALOG oDlgLayOut ON INIT(FldTools(oFolder,oLbCabec,oLbDetail,oLbTrail,oLbImpr,nCabec,nDetail,nTrail,nImpr))

SETAPILHA()
aCabec  :={}
aDetail :={}
aTrail  :={}
aImpr   :={}

aCabec  :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
aDetail :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
aTrail  :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
aImpr   :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � RestFile � Autor � Wagner Xavier         � Data �          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Restaura arquivos de Comunicacao Bancaria ja Configurados  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   쿝estFile(cFile,lDele)                                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿬File    - Arquivo a ser deletado                           낢�
굇�          쿹Dele    -                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function RestFile(oDlg,lDele)

Local nTamArq
Local nBytes    :=0
Local xBuffer
//Local lSave

lDele   :=IIF(lDele==NIL,.F.,lDele)

If !File(cFile)
	cFile:=""
	Help(" ",1,"AX014BCO")
	Return
Endif

nBcoHdl :=FOPEN(cFile,2+64)
nTamArq :=FSEEK(nBcoHdl,0,2)
FSEEK(nBcoHdl,0,0)

aCabec  :={}
aDetail :={}
aTrail :={}
aImpr   :={}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Preenche os arrays de acordo com a Identificador             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
While nBytes < nTamArq
	xBuffer := Space(257)
	FREAD(nBcoHdl,@xBuffer,257)
	If SubStr(xBuffer,1,1) == CHR(1)			//Preenche o cabecalho
		AADD(aCabec,{	SubStr(xBuffer,02,25) ,SubStr(xBuffer,27,03),;
							SubStr(xBuffer,30,03) ,SubStr(xBuffer,33,03),;
							SubStr(xBuffer,36,200) ,SubStr(xBuffer,236,20) } )
	Elseif SubStr(xBuffer,1,1) == CHR(2)		//Preenche o Detalhe
		AADD(aDetail,{	SubStr(xBuffer,02,25) ,SubStr(xBuffer,27,03),;
							SubStr(xBuffer,30,03) ,SubStr(xBuffer,33,03),;
							SubStr(xBuffer,36,200) ,SubStr(xBuffer,236,20) } )
	Elseif SubStr(xBuffer,1,1) == CHR(3)		//Preenche o Rodape
		AADD(aTrail,{	SubStr(xBuffer,02,25) ,SubStr(xBuffer,27,03),;
							SubStr(xBuffer,30,03) ,SubStr(xBuffer,33,03),;
							SubStr(xBuffer,36,200) ,SubStr(xBuffer,236,20) } )
	Elseif SubStr(xBuffer,1,1) == CHR(5)		//Preenche os parametros para Impressao
		AADD(aImpr,{	SubStr(xBuffer,02,25) ,SubStr(xBuffer,27,03),;
							SubStr(xBuffer,30,03) ,SubStr(xBuffer,33,03),;
							SubStr(xBuffer,36,200) ,SubStr(xBuffer,236,20) } )
	Endif
	nBytes += 257
Enddo
IF  Len(aCabec)==0 .And. Len(aImpr) == 0 .and. Len(aDetail) == 0 .and. Len(aTrail) == 0 
	Help(" ",1,"AX014BCO")
	Return
ENDIF

If Empty(aCabec)
	aCabec  :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Endif

If Empty(aDetail)
	aDetail  :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Endif

If Empty(aTrail)
	aTrail  :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Endif

If Empty(aImpr)
	aImpr   :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
Endif

EditCNAB(oDlg,lDele)

FCLOSE(nBcoHdl)

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � SaveFile � Autor � Wagner Xavier         � Data �          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Salva arquivos de Comunicacao Bancaria ja Configurados     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   쿞aveFle(cFile)                                              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿬File    - Arquivo a ser Criado/Editado                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATCONF                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function SaveFile()

//LOCAL cReg1
//Local i
//Local lCreat    :=.F.
//Local cRegA
Local cFileback :=cFile

IF nOpcf == 2
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Escolhe o nome do Arquivo a ser salvo                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	ChangeFile() 
	If Empty(cFile)
		Return .F.
	Endif
	
	If cFile#cFileBack .AND. File(cFile)
		If !MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0010)) // "Arquivo LayOut j� existe grava por cima"   ###  "LayOut Nota Fiscal"
			cFile   :=""
			Return .F.
		Endif
	Endif
Else
	If !MsgYesNo(OemToAnsi(STR0020),OemToAnsi(STR0014)) // "Confirma Grava눯o do arquivo LayOut"   ###   "LayOut Nota Fiscal"
		Return .F.
	Endif
EndIF

fClose(nBcoHdl)
nBcoHdl:=MSFCREATE(cFile,0)

FSEEK(nBcoHdl,0,0)

//Grava conforme a ordem de chamada da funcao
x014Form(aImpr   ,5)		//Parametros
x014Form(aCabec  ,1)		//Cabecalho
x014Form(aDetail ,2)		//Detalhe
x014Form(aTrail  ,3)		//Detalhe

FCLOSE(nBcoHdl)

Return .T.
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � DeleFile � Autor � Wagner Xavier         � Data �          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Deleta   arquivos de Comunicacao Bancaria ja Configurados  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � DeleFile()                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function DeleFile()

If Len(aCabec) > 0
	If MsgYesNo(OemToAnsi(STR0021),OemToAnsi(STR0010)) // "Deleta arquivo LayOut"  ###  "LayOut Nota Fiscal"
		FCLOSE(nBcoHdl)
		FERASE(cFile)
	Endif
Endif

Return .T.
/*
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿗inOut    � Autor � Marcos Patricio       � Data � 05.02.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Acepta linha do LayOut                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � LiOut(nItem,Folder,lProcess)                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� nItem    - Item do array                                   낢�
굇�          � Folder   - Folder Focado                                   낢�
굇�          � lProcess - Processo Inclus�o ou Altera눯o                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATCONF                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Last change:  CIA   5 Feb 96    9:44 am
*/
Static Function  LinOut(nItem,Folder,lProcess)

Local nOpca     :=0
Local cPosBco   :=Space(25)
Local cPosIni   :=Space(03)
Local cPosFin   :=Space(03)
Local cLenDec   :=Space(03)
Local cConteudo :=Space(200)
Local cPicture  :=Space(20)
Local oDlg

If nOpcf==3		
	Return
Endif

If !lProcess
	If Folder=="H"			//Cabecalho
		IF Len(aCabec)==1 .AND. (Empty(aCabec[1,1]) .AND. Empty(aCabec[1,2]) .AND. Empty(aCabec[1,3]))
			MsgStop(OemToAnsi(STR0022),OemToAnsi(STR0010))  // "Nao h� dados para altera놹o"  ###  "LayOut Nota Fiscal"
			Return
		Else
			cPosBco    :=OemToAnsi(aCabec[nItem,1])
			cPosIni    :=aCabec[nItem,2]
			cPosFin    :=aCabec[nItem,3]
			cLenDec    :=aCabec[nItem,4]
			cConteudo  :=OemToAnsi(aCabec[nItem,5])
			cPicture   :=aCabec[nItem,6]
		Endif
	Elseif Folder =="D"			//Detalhe
		IF Len(aDetail)==1 .AND. (Empty(aDetail[1,1]) .AND. Empty(aDetail[1,2]) .AND. Empty(aDetail[1,3]) )
			MsgStop(OemToAnsi(STR0022),OemToAnsi(STR0010))  // "Nao h� dados para altera놹o"  ###  "LayOut Nota Fiscal"
			Return
		Else
			cPosBco    :=OemToAnsi(aDetail[nItem,1])
			cPosIni    :=aDetail[nItem,2]
			cPosFin    :=aDetail[nItem,3]
			cLenDec    :=aDetail[nItem,4]
			cConteudo  :=OemToAnsi(aDetail[nItem,5])
			cPicture   :=aDetail[nItem,6]
		Endif		
	Elseif Folder =="R"			//Rodape
		IF Len(aTrail)==1 .AND. (Empty(aTrail[1,1]) .AND. Empty(aTrail[1,2]) .AND. Empty(aTrail[1,3]) )
			MsgStop(OemToAnsi(STR0022),OemToAnsi(STR0010))  // "Nao h� dados para altera놹o"  ###  "LayOut Nota Fiscal"
			Return
		Else
			cPosBco    :=OemToAnsi(aTrail[nItem,1])
			cPosIni    :=aTrail[nItem,2]
			cPosFin    :=aTrail[nItem,3]
			cLenDec    :=aTrail[nItem,4]
			cConteudo  :=OemToAnsi(aTrail[nItem,5])
			cPicture   :=aTrail[nItem,6]
		Endif				
	ElseIf Folder == "I" 	//Parametros para Impressao
		IF Len(aImpr)==1 .AND. (Empty(aImpr[1,1]) .AND. Empty(aImpr[1,2]) .AND. Empty(aImpr[1,3]) )
			MsgStop(OemToAnsi(STR0022),OemToAnsi(STR0010))  // "Nao h� dados para altera놹o"  ###  "LayOut Nota Fiscal"
			Return
		Else
			cPosBco    :=OemToAnsi(aImpr[nItem,1])
			cPosIni    :=aImpr[nItem,2]
			cPosFin    :=aImpr[nItem,3]
			cLenDec    :=aImpr[nItem,4]
			cConteudo  :=OemToAnsi(aImpr[nItem,5])
		Endif
	Endif
Endif

DEFINE MSDIALOG oDlg FROM  15,6 TO 216,366 TITLE OemToAnsi(STR0010) PIXEL // "LayOut Nota Fiscal"

@ 2, 2 TO 88, 179 OF oDlg  PIXEL

@ 08,05 SAY     OemToAnsi(STR0014)      SIZE 31, 07 OF oDlg PIXEL // "Descricao"
@ 07,53 MSGET   cPosBco Picture "@X"    When IIF(Folder=="I",.F.,.T.) SIZE 70, 10 OF oDlg PIXEL

@ 21,05 SAY     OemToAnsi(STR0015) 	    SIZE 46, 07 OF oDlg PIXEL // "Linha"
@ 20,53 MSGET   cPosIni  Picture "999"  When IIF(Folder=="I",.F.,.T.) SIZE 21, 10 OF oDlg PIXEL	

@ 34,05 SAY     OemToAnsi(STR0016)   	SIZE 41, 07 OF oDlg PIXEL // "Coluna"
@ 33,53 MSGET   cPosFin  Picture "999"  When IIF(Folder=="I",.F.,.T.) Valid Val(cPosFin) >= 0  SIZE 21, 10 OF oDlg PIXEL		

@ 47,05 SAY     OemToAnsi(STR0017)   	SIZE 028,07 OF oDlg PIXEL // "Tamanho"
@ 46,53 MSGET   cLenDec  Picture "999"  When IIF(Folder=="I",.T.,.F.) Valid Val(cLenDec) >= 0 SIZE 011,10 OF oDlg PIXEL

@ 60,05 SAY     OemToAnsi(STR0018)   	SIZE 031,07 OF oDlg PIXEL // "Conte즔o"
@ 59,53 MSGET   cConteudo               When IIF(Folder=="I",.F.,.T.) SIZE 123,10 OF oDlg PIXEL		

If Folder != "I"
	@ 73,05 SAY     "Picture"           	SIZE 031,07 OF oDlg PIXEL // "Picture"
	@ 72,53 MSGET   cPicture                When IIF(Folder=="I",.F.,.T.) SIZE 123,10 OF oDlg PIXEL
EndIf

DEFINE SBUTTON FROM 89,124 TYPE 1 ENABLE OF oDlg ACTION ( TypeFile(),  nOpca:=1, if(ValTela(cPosBco,cPosIni,cPosFin,Folder),oDlg:End(),nOpca:= 0)  )
DEFINE SBUTTON FROM 89,152 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If  nOpca == 1
	If  lProcess		
		If Folder=="H"
			IF Len(aCabec)==1 .AND. ( Empty(aCabec[1,1]) .AND. Empty(aCabec[1,2]) .AND. Empty(aCabec[1,3]) )
				aCabec[1]   :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}
			Else
				Aadd(aCabec,{cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture} )
			Endif
		ElseIf Folder == "I"
			IF Len(aImpr)==1 .AND. ( Empty(aImpr[1,1]) .AND. Empty(aImpr[1,2]) .AND. Empty(aImpr[1,3]) )
				aImpr[1]   :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}
			Else
				Aadd(aImpr,{cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture} )
			Endif			
		ElseIf Folder == "D"
			IF Len(aDetail)==1 .AND. ( Empty(aDetail[1,1]) .AND. Empty(aDetail[1,2]) .AND. Empty(aDetail[1,3]) )
				aDetail[1]   :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}
			Else
				Aadd(aDetail,{cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture} )
			Endif		
		ElseIf Folder == "R"
			IF Len(aTrail)==1 .AND. ( Empty(aTrail[1,1]) .AND. Empty(aTrail[1,2]) .AND. Empty(aTrail[1,3]) )
				aTrail[1]   :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}
			Else
				Aadd(aTrail,{cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture} )
			Endif					
    	Endif
	Else
		If Folder=="H"
			aCabec[nItem]  :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}
		ElseIf Folder == "I"
			aImpr[nItem]   :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}
		ElseIf Folder == "D"
			aDetail[nItem] :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}			
		ElseIf Folder == "R"
			aTrail[nItem] :={cPosBco,cPosIni,cPosFin,cLenDec,cConteudo,cPicture}						
		Endif
	Endif

Endif

Return
/*
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � LinDel   � Autor � Marcos Patricio       � Data � 05.02.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Deleta linha do LayOut                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � LiDel(nItem,Folder,oLbCabec,oLbProd,oLbRodape)             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� nItem        - Item do array                               낢�
굇�          � Folder       - Pasta Focada                                낢�
굇�          � oLbCabec     - Objeto ListBox do Cabec                     낢�
굇�          � oLbProd      - Objeto ListBox do Prod                      낢�
굇�          � oLbRodape    - Objeto ListBox do Rodape                    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATCONF                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Last change:  CIA   5 Feb 96    9:44 am
*/
Static Function LinDel(nItem,Folder,oLbCabec,oLbDetail,oLbTrail,oLbImpr)

If  nOpcf==3
	Return
Endif

If  Folder=="H"
	IF  Len(aCabec)==1 .AND. (Empty(aCabec[1,1]) .AND. Empty(aCabec[1,2]) .AND. Empty(aCabec[1,3]))
		MsgStop(OemToAnsi(STR0023),OemToAnsi(STR0010)) // "Nao h� dados para dele놹o"  ### "LayOut Nota Fiscal"
		Return
	Else
		If  MsgYesNo(OemToAnsi(STR0024),OemToAnsi(STR0010)) // "Confirma dele놹o"  ###  "LayOut Nota Fiscal"
			ADEL(aCabec,nItem)
			ASIZE(aCabec,Len(aCabec)-1)
		Endif
	Endif
	If  Len(aCabec) == 0
		aCabec :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
	Endif
	oLbCabec:SetArray(aCabec)
	oLbCabec:bLine   := { || { aCabec[oLbCabec:nAt,1] ,;
	aCabec[oLbCabec:nAt,2] ,;
	aCabec[oLbCabec:nAt,3] ,;
	aCabec[oLbCabec:nAt,4] ,;
	aCabec[oLbCabec:nAt,5] ,;
	aCabec[oLbCabec:nAt,6]} }
	oLbCabec:Refresh(.f.)
	
ElseIf Folder == "I"
	IF  Len(aImpr)==1 .AND. (Empty(aImpr[1,1]) .AND.  Empty(aImpr[1,2])) 
		MsgStop(OemToAnsi(STR0023),OemToAnsi(STR0010)) // "Nao h� dados para dele놹o"  ###   "LayOut Nota Fiscal"
		Return
	Else
		If  MsgYesNo(OemToAnsi(STR0024),OemToAnsi(STR0010)) // "Confirma dele놹o"  ###  "LayOut Nota Fiscal"
			ADEL(aImpr,nItem)
			ASIZE(aImpr,Len(aImpr)-1)
		Endif
	Endif
	If  Len(aImpr) == 0
		aImpr :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
	Endif
	oLbImpr:SetArray(aImpr)
	oLbImpr:bLine   := { || { aImpr[oLbImpr:nAt,1] ,;
	aImpr[oLbImpr:nAt,2] ,;
	aImpr[oLbImpr:nAt,3] ,;
	aImpr[oLbImpr:nAt,4] ,;
	aImpr[oLbImpr:nAt,5] } }
	oLbImpr:Refresh(.f.)
	
ElseIf Folder == "D"
	IF  Len(aDetail)==1 .AND. (Empty(aDetail[1,1]) .AND.  Empty(aDetail[1,2])) //.AND. Empty(aDetail[1,3]) )
		MsgStop(OemToAnsi(STR0023),OemToAnsi(STR0010)) // "Nao h� dados para dele놹o"  ###   "LayOut Nota Fiscal"
		Return
	Else
		If  MsgYesNo(OemToAnsi(STR0024),OemToAnsi(STR0010)) // "Confirma dele놹o"  ###  "LayOut Nota Fiscal"
			ADEL(aDetail,nItem)
			ASIZE(aDetail,Len(aDetail)-1)
		Endif
	Endif
	If  Len(aDetail) == 0
		aDetail :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
	Endif
	oLbDetail:SetArray(aDetail)
	oLbDetail:bLine   := { || { aDetail[oLbDetail:nAt,1] ,;
	aDetail[oLbDetail:nAt,2] ,;
	aDetail[oLbDetail:nAt,3] ,;
	aDetail[oLbDetail:nAt,4] ,;
	aDetail[oLbDetail:nAt,5] ,;
	aDetail[oLbDetail:nAt,6] } }
	oLbDetail:Refresh(.f.)	
	
ElseIf Folder == "R"
	IF  Len(aTrail)==1 .AND. (Empty(aTrail[1,1]) .AND.  Empty(aTrail[1,2])) 
		MsgStop(OemToAnsi(STR0023),OemToAnsi(STR0010)) // "Nao h� dados para dele놹o"  ###   "LayOut Nota Fiscal"
		Return
	Else
		If  MsgYesNo(OemToAnsi(STR0024),OemToAnsi(STR0010)) // "Confirma dele놹o"  ###  "LayOut Nota Fiscal"
			ADEL(aTrail,nItem)
			ASIZE(aTrail,Len(aTrail)-1)
		Endif
	Endif
	If  Len(aTrail) == 0
		aTrail :={{Space(25),Space(03),Space(03),Space(03),Space(200),Space(20)}}
	Endif
	oLbTrail:SetArray(aTrail)
	oLbTrail:bLine   := { || { aTrail[oLbTrail:nAt,1] ,;
	aTrail[oLbTrail:nAt,2] ,;
	aTrail[oLbTrail:nAt,3] ,;
	aTrail[oLbTrail:nAt,4] ,;
	aTrail[oLbTrail:nAt,5] ,;
	aTrail[oLbTrail:nAt,6] } }
	oLbTrail:Refresh(.f.)	
	
Endif

Return
/*
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � TypeFile � Autor � Marcos Patricio       � Data � 05.02.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Seta o tipo de arqruivo em uso                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � TypeFile()                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATCONF                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
Last change:  CIA   5 Feb 96    9:44 am
*/
Static Function TypeFile()

cType    :=Iif(nOpcf==1,OemToAnsi(STR0008)+'SIGA.ETQ',OemToAnsi(STR0008)+'*.ETQ') // "Saida | "  ###   "Saida | "

Return Nil
/*
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � FldTools � Autor � Marcos Patricio                 � Data � 05.02.96 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Barra de bot�es das pastas                                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FldTools(oFld,oLbCabec,oLbProd,oLbRodape,nCabec)   		낢�                                       
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� oFld         - Objeto do Folder                                      낢�
굇�          � oLbCabec    - Objeto ListBox do Cabec                              	낢�
굇�          � oLbProd    - Objeto ListBox do Prod                              		낢�
굇�          � oLbRodape     - Objeto ListBox do Rodape                             낢�
굇�          � nCabec      - Referencia da pasta do Objeto Folder                  	낢�
굇�          � nProd      - Referencia da pasta do Objeto Folder                  	낢�
굇�          � nRodape       - Referencia da pasta do Objeto Folder                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATCONF                                                              낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
*/
Static FUNCTION FldTools(oFld,oLbCabec,oLbDetail,oLbTrail,oLbImpr,nCabec,nDetail,nTrail,nImpr)

// 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// � As barras de bot�es utilizados nos folders t늤 que ser dife-�
// � devido ao tratamento PIXEL feito no Protheus                �
// 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
#IFNDEF PROTHEUS
	@ .1,02 BUTTON OemToAnsi(STR0025) SIZE 50,20 OF oFld:aDialogs[nCabec] ACTION (LinOut(oLbCabec:nAt,"H",.T.),oLbCabec:Refresh())  //"Incluir"
	@ .1,15 BUTTON OemToAnsi(STR0026) SIZE 50,20 OF oFld:aDialogs[nCabec] ACTION (LinDel(oLbCabec:nAt,"H",oLbCabec),oLbCabec:Refresh())  //"Excluir"
	@ .1,28 BUTTON OemToAnsi(STR0027) SIZE 50,20 OF oFld:aDialogs[nCabec] ACTION (LinOut(oLbCabec:nAt,"H",.F.),oLbCabec:Refresh()) //"Editar"

	@ .1,02 BUTTON OemToAnsi(STR0025) SIZE 50,20 OF oFld:aDialogs[nDetail] ACTION (LinOut(oLbDetail:nAt,"D",.T.),oLbDetail:Refresh())  //"Incluir"
	@ .1,15 BUTTON OemToAnsi(STR0026) SIZE 50,20 OF oFld:aDialogs[nDetail] ACTION (LinDel(oLbDetail:nAt,"D",oLbCabec,oLbDetail),oLbDetail:Refresh())  //"Excluir"
	@ .1,28 BUTTON OemToAnsi(STR0027) SIZE 50,20 OF oFld:aDialogs[nDetail] ACTION (LinOut(oLbDetail:nAt,"D",.F.),oLbDetail:Refresh()) //"Editar"

	@ .1,02 BUTTON OemToAnsi(STR0025) SIZE 50,20 OF oFld:aDialogs[nTrail] ACTION (LinOut(oLbTrail:nAt,"R",.T.),oLbTrail:Refresh())  //"Incluir"
	@ .1,15 BUTTON OemToAnsi(STR0026) SIZE 50,20 OF oFld:aDialogs[nTrail] ACTION (LinDel(oLbTrail:nAt,"R",oLbTrail),oLbCabec,oLbDetail,oLbTrail:Refresh())  //"Excluir"
	@ .1,28 BUTTON OemToAnsi(STR0027) SIZE 50,20 OF oFld:aDialogs[nTrail] ACTION (LinOut(oLbTrail:nAt,"R",.F.),oLbTrail:Refresh()) //"Editar"

	@ .1,28 BUTTON OemToAnsi(STR0027) SIZE 50,20 OF oFld:aDialogs[nImpr] ACTION (LinOut(oLbImpr:nAt,"I",.F.),oLbImpr:Refresh()) //"Editar"
	
#ELSE
	@ .8,02 BUTTON OemToAnsi(STR0025) SIZE 25,10 PIXEL OF oFld:aDialogs[nCabec] ACTION (LinOut(oLbCabec:nAt,"H",.T.),oLbCabec:Refresh())  //"Incluir"
	@ .8,28 BUTTON OemToAnsi(STR0026) SIZE 25,10 PIXEL OF oFld:aDialogs[nCabec] ACTION (LinDel(oLbCabec:nAt,"H",oLbCabec),oLbCabec:Refresh())  //"Excluir"
	@ .8,54 BUTTON OemToAnsi(STR0027) SIZE 25,10 PIXEL OF oFld:aDialogs[nCabec] ACTION (LinOut(oLbCabec:nAt,"H",.F.),oLbCabec:Refresh()) //"Editar"

	@ .8,02 BUTTON OemToAnsi(STR0025) SIZE 25,10 PIXEL OF oFld:aDialogs[nDetail] ACTION (LinOut(oLbDetail:nAt,"D",.T.),oLbDetail:Refresh())  //"Incluir"
	@ .8,28 BUTTON OemToAnsi(STR0026) SIZE 25,10 PIXEL OF oFld:aDialogs[nDetail] ACTION (LinDel(oLbDetail:nAt,"D",oLbCabec,oLbDetail),oLbDetail:Refresh())  //"Excluir"
	@ .8,54 BUTTON OemToAnsi(STR0027) SIZE 25,10 PIXEL OF oFld:aDialogs[nDetail] ACTION (LinOut(oLbDetail:nAt,"D",.F.),oLbDetail:Refresh()) //"Editar"

	@ .8,02 BUTTON OemToAnsi(STR0025) SIZE 25,10 PIXEL OF oFld:aDialogs[nTrail] ACTION (LinOut(oLbTrail:nAt,"R",.T.),oLbTrail:Refresh())  //"Incluir"
	@ .8,28 BUTTON OemToAnsi(STR0026) SIZE 25,10 PIXEL OF oFld:aDialogs[nTrail] ACTION (LinDel(oLbTrail:nAt,"R",oLbCabec,oLbDetail,oLbTrail),oLbTrail:Refresh())  //"Excluir"
	@ .8,54 BUTTON OemToAnsi(STR0027) SIZE 25,10 PIXEL OF oFld:aDialogs[nTrail] ACTION (LinOut(oLbTrail:nAt,"R",.F.),oLbTrail:Refresh()) //"Editar"

	@ .8,54 BUTTON OemToAnsi(STR0027) SIZE 25,10 PIXEL OF oFld:aDialogs[nImpr] ACTION (LinOut(oLbImpr:nAt,"I",.F.),oLbImpr:Refresh()) //"Editar"

#ENDIF
    
RETURN NIL
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � X014Form � Autor � Wagner Xavier         � Data �          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Grava um Array no Novo Arquivo de Comunicao Bancaria       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static FuncTion x014Form(aComun,nIdent)

Local i
Local cReg1
Local cRegA

For i:=1 To Len(aComun)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica se a linha esta em branco                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cReg1:= aComun[i][1]+aComun[i][2]+;
		aComun[i][3]+aComun[i][4]+aComun[i][5]+aComun[i][6]
	IF !Empty(cReg1)
		cRegA:= CHR(nIdent)+cReg1
		FWRITE(nBcoHdl,cRegA+CHR(13)+CHR(10),257)   //grava nova linha
	EndIF
Next i

Return

///////////////////////////////////////////
// Rotina: ValTudo                       //
/////////////////////////////////////////// 
Static Function ValTudo()
//Local lValido
Local nX
Local nY
Local aArrays := { aCabec, aDetail, aTrail }

	For nX := 1 To Len(aArrays)
		For nY := 1 To Len(aArrays[nX])
			If ((Val(aArrays[nX][nY][2]) + Val(aImpr[1][4])) > ((Val(aImpr[1][4])) + Val(aImpr[4][4])))
				MsgStop("A posi豫o linha [" + RTrim(aArrays[nX][nY][2]) + "] para o campo [" + RTrim(aArrays[nX][nY][1]) + "] ultrapassa a Margem superior + a Dist�ncia vertical.")
				Return (.F.)
			EndIf
			If ((Val(aArrays[nX][nY][3]) + Val(aImpr[3][4])) > ((Val(aImpr[3][4])) + Val(aImpr[5][4])))
				MsgStop("A posi豫o coluna [" + RTrim(aArrays[nX][nY][3]) + "] para o campo [" + RTrim(aArrays[nX][nY][1]) + "] ultrapassa a Margem lateral + a Largura da etiqueta.")
				Return (.F.)
			EndIf
		Next
	Next
	
	If !((Val(aImpr[1][4]) + (Val(aImpr[7][4]) * Val(aImpr[4][4])) + Val(aImpr[2][4])) <= Val(aImpr[8][4]))
		MsgStop("As configura寤es de Margem superior/inferior, " +;
			    "Etiquetas por linha e Dist�ncia vertical ultrapassam a Altura da p�gina.")
		Return (.F.)
	EndIf

	If !((Val(aImpr[3][4]) + (Val(aImpr[6][4]) * Val(aImpr[5][4]))) <= Val(aImpr[9][4]))
		MsgStop("As configura寤es de Margem lateral, Etiquetas por linha e Largura da etiqueta " +;
				"ultrapassam a Largura da p�gina.")
		Return (.F.)
	EndIf
	
Return (.T.)


///////////////////////////////////////////////////
// Rotina: ValTela                               //
///////////////////////////////////////////////////
Static Function ValTela(cPosBco,cPosIni,cPosFin,Folder)

Local lRet := .T.

If Folder <> "I"
   If RTrim(cPosBco) == "" .Or. RTrim(cPosIni) == "" .Or. RTrim(cPosFin) == ""
      MsgStop(OemToAnsi(STR0043),OemToAnsi(STR0010))
      lRet := .F.	
   EndIf
Endif	

Return(lRet)