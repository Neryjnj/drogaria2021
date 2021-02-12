#INCLUDE "FRTA272C.ch"
#INCLUDE "Protheus.ch"

#DEFINE CLRTEXT		0
#DEFINE CLRBACK		16777215
#DEFINE CLRBACKCTR		16777215
#DEFINE TAMTOT			0
#DEFINE POS_VAR		1	//Variavel
#DEFINE POS_NOM		2	//Nome do campo
#DEFINE POS_TIT		3	//Titulo
#DEFINE POS_PIC		4	//Picture
#DEFINE POS_OBR		5	//Obrigatorio?
#DEFINE POS_VLP		6	//Valor padrao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณFRTA272C   บAutor  ณVendas Clientes       บ Data ณ28/11/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para executar a transferencia de titulos vinculados a movi-บฑฑ
ฑฑบ          ณmentos de caixa, transferencia de portador e carteira.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA / SIGAFAT                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FRTA272C()

Local aArea				:= GetArea()										//Workarea
Local cF3SLW			:= "SLWLJ"											//Consulta padrao SLW
Local cF3SA6			:= "SA6"											//Consulta padrao SA6
Local aLstCMP			:= Array(10)										//Lista de controle de campos utilizados : [1] Variavel [2] Nome [3] Titulo [4] Picture
Local lUsaFecha			:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utilizar conf. de fechamento
Local lTrans			:= SuperGetMV("MV_LJTRANS",.F.,.F.)				//Transferencia
Local cTransNat			:= SuperGetMV("MV_LJTRNAT",.F.,"")					//Natureza da transferencia de portador

Local cChave			:= ""												//Chave de pesquisa
Local aLstCart			:= {}												//Lista de carteiras para o combobox
Local nOpca				:= 0												//Opcao de retornado da interface
Local cPTM				:= "@!"												//Picture maiuscula
Local cPTN01			:= "@E 99,999,999.99"								//Picture numerica
Local cPTD				:= "@D"												//Picture data

Local nLin01			:= 012
Local nLin02			:= 027
Local nLin03			:= 063
Local nLin04			:= 078

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis de objetos de tela  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static oTela
Static oGrp01
Static oGrp02
Static oBot01
Static oBot02
Static oSay01
Static oGet01
Static oSay02
Static oGet02
Static oSay03
Static oGet03
Static oSay04
Static oGet04
Static oSay05
Static oGet05
Static oSay06
Static oGet06
Static oSay07
Static oGet07
Static oSay08
Static oGet08
Static oSay09
Static oGet09
Static oSay10
Static oGet10
Static nLargS			:= 033
Static nLargG			:= 045
Static nLargC			:= 065
Static nLargB			:= 030
Static nAltura			:= 010
Static nAltBot			:= 015
Static nLargTela		:= 500
Static nAltTela			:= IIf(Upper(AllTrim(PtGetTheme())) $ "MDI|TEMAP10",245,240)

Private dMovEm			:= Nil												//Data de abertura do movimento
Private cNumMov		:= ""												//Numero do movimento
Private cOperado		:= ""												//Operador do movimento
Private cEstacao		:= ""												//Estacao do movimento
Private cSerie			:= ""												//Serie do movimento
Private cPDV			:= ""												//PDV do movimento
Private cOperDest		:= ""												//Operador
Private cAgenDest		:= ""												//Estacao
Private cCCDest		:= ""												//CC de destino
Private cCartDest		:= ""												//Carteira de destino
Private cNomeUs		:= AllTrim(UsrRetName(__cUserID))					//Nome do usuario padrao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRotina para execucao exclusiva no SIGALOJA  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !(nModulo == 12 .OR. nModulo == 5) // SIGALOJA OU SIGAFAT
	MsgAlert(cNomeUs + STR0001) //", esta rotina deve ser executada no m๓dulo SIGALOJA!"
	Return Nil
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao de parametros  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lUsaFecha 
	MsgAlert(cNomeUs + STR0002) //", para utilizar esta rotina, ้ necessแrio que a confer๊ncia de caixa esteja ativa."
	Return Nil
Else
	If !lTrans .OR. Empty(cTransNat)
		MsgAlert(cNomeUs + STR0003) //", para utilizar esta rotina, ้ necessแrio que a transfer๊ncia de caixa e potador esteja ativa."
		Return Nil
	Endif
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar a lista de carteiras permitidas  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cChave := "07"
dbSelectArea("SX5")
SX5->(dbSetOrder(1))
SX5->(dbSeek(xFilial("SX5") + cChave))
SX5->(dbEval({|| aAdd(aLstCart,Substr(SX5->X5_CHAVE,1,1) + "=" + Upper(X5Descri()))},{|| Upper(AllTrim(SX5->X5_CHAVE)) $ "0|I|J"},{|| RTrim(X5_TABELA) == cChave}))
If Len(aLstCart) == 0
	MsgAlert(cNomeUs + STR0004) //", as carteiras de transfer๊ncia de caixa nใo puderam ser encontradas!"
	Return Nil
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializacao de variaveis  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aLstCMP[1] 	:= {"dMovEm"	,"LW_DTABERT"	, "",	cPTD	,.F.	,Date()}
aLstCMP[2] 	:= {"cNumMov"	,"LW_NUMMOV"	, "",	cPTM	,.F.	,""}
aLstCMP[3] 	:= {"cOperado"	,"LW_OPERADO"	, "",	cPTM	,.F.	,""}
aLstCMP[4] 	:= {"cEstacao"	,"LW_ESTACAO"	, "",	cPTM	,.F.	,""}
aLstCMP[5] 	:= {"cSerie"	,"LW_SERIE"		, "",	cPTM	,.F.	,""}
aLstCMP[6] 	:= {"cPDV"		,"LW_PDV"		, "",	cPTM	,.F.	,""}
aLstCMP[7] 	:= {"cOperDest"	,"A6_COD"		, "",	cPTM	,.F.	,""}
aLstCMP[8] 	:= {"cAgenDest"	,"A6_AGENCIA"	, "",	cPTM	,.F.	,""}
aLstCMP[9] 	:= {"cCCDest"	,"A6_NUMCON"	, "",	cPTM	,.F.	,""}
aLstCMP[10]	:= {"cCartDest"	,"E1_SITUACA"	, "",	cPTM	,.F.	,"0"}
IniciaVar(aLstCMP)
//ฺฤฤฤฤฤฤฟ
//ณTela  ณ
//ภฤฤฤฤฤฤู
DEFINE MSDIALOG oTela TITLE STR0005 FROM 000, 000  TO nAltTela,nLargTela COLORS CLRTEXT,CLRBACK PIXEL //"Transfer๊ncia de carteira de movimentos"
//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณGRUPOS    ณ
//ภฤฤฤฤฤฤฤฤฤฤู
oGrp01 	:= tGroup():New(002,003,050,248,STR0006,oTela,CLRTEXT,CLRBACK,.T.) //"Dados da esta็ใo" //"Informa็๕es do movimento "
oGrp02 	:= tGroup():New(052,003,104,248,STR0007,oTela,CLRTEXT,CLRBACK,.T.) //"Dados da esta็ใo" //"Transferir para "
//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณ1o GRUPO  ณ
//ภฤฤฤฤฤฤฤฤฤฤู
//1a Linha
oSay01 	:= tSay():New(nLin01,006,{||aLstCMP[1][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet01 	:= tGet():New(nLin01,042,&(BlGet(aLstCMP[1][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[1][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,cF3SLW,aLstCMP[1][POS_VAR])
oSay02 	:= tSay():New(nLin01,092,{||aLstCMP[2][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet02 	:= tGet():New(nLin01,122,&(BlGet(aLstCMP[2][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[2][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,,aLstCMP[2][POS_VAR])
oSay03 	:= tSay():New(nLin01,170,{||aLstCMP[3][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet03 	:= tGet():New(nLin01,200,&(BlGet(aLstCMP[3][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[3][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,,aLstCMP[3][POS_VAR])
//2a Linha
oSay04 	:= tSay():New(nLin02,006,{||aLstCMP[4][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet04 	:= tGet():New(nLin02,042,&(BlGet(aLstCMP[4][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[4][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,,aLstCMP[4][POS_VAR])
If nModulo <> 5 //Para SIGAFAT nao apresentar SERIE E PDV
	oSay05 	:= tSay():New(nLin02,092,{||aLstCMP[5][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
	oGet05 	:= tGet():New(nLin02,122,&(BlGet(aLstCMP[5][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[5][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,,aLstCMP[5][POS_VAR])
	oSay06 	:= tSay():New(nLin02,170,{||aLstCMP[6][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
	oGet06 	:= tGet():New(nLin02,200,&(BlGet(aLstCMP[6][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[6][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,,aLstCMP[6][POS_VAR])
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณ2o GRUPO  ณ
//ภฤฤฤฤฤฤฤฤฤฤู
//1a Linha
oSay07 	:= tSay():New(nLin03,006,{||aLstCMP[7][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet07 	:= tGet():New(nLin03,042,&(BlGet(aLstCMP[7][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[7][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,cF3SA6,aLstCMP[7][POS_VAR])
oSay08 	:= tSay():New(nLin03,092,{||aLstCMP[8][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet08 	:= tGet():New(nLin03,122,&(BlGet(aLstCMP[8][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[8][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,,aLstCMP[8][POS_VAR])
oSay09 	:= tSay():New(nLin03,170,{||aLstCMP[9][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet09 	:= tGet():New(nLin03,200,&(BlGet(aLstCMP[9][POS_VAR])),oTela,nLargG,nAltura,aLstCMP[9][POS_PIC],/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.F.,.F.,,aLstCMP[10][POS_VAR])
//2a Linha
oSay10 	:= tSay():New(nLin04,006,{||aLstCMP[10][POS_TIT]},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura)
oGet10	:= tComboBox():New(nLin04,042,&(BlGet(aLstCMP[10][POS_VAR])),aLstCart,nLargG * 2,nAltura,oTela,,/*change*/,/*valid*/,CLRTEXT,CLRBACKCTR,.T.,,,,/*when*/,,,,,aLstCMP[10][POS_VAR])
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotoes de funcao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBot01	:= tButton():New(106,185,STR0008,oTela,{|| OpcOk(oTela,@nOpca,aLstCmp)},nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Confirmar"
oBot02	:= tButton():New(106,218,STR0009,oTela,{|| oTela:End()},nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Fechar"

ACTIVATE MSDIALOG oTela CENTERED

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณBlGet      บAutor  ณVendas Clientes       บ Data ณ29/11/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar um bloco de codigo de controle de atualizacaoบฑฑ
ฑฑบ          ณda variavel manipulada por objetos tGet e tComboBox               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome da variavel                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcBlGet[C] : Retorna uma string em formatao de bloco de codigo     บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRTA272C                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             

Static Function BlGet(cCmp,aLstCmp)

Local cBlGet           := ""

cBlGet := "{|x| If(PCount() > 0," + cCmp + " := x," + cCmp + ")}"

Return cBlGet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณOpcOk      บAutor  ณVendas Clientes       บ Data ณ29/11/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de validacao dos dados digitados para a execucao da transf.บฑฑ
ฑฑบ          ณdos titulos de um dado movimento de caixa.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Objeto de tela                                         บฑฑ
ฑฑบ          ณExp02[N] : Variavel de controle de opcao de operacao              บฑฑ
ฑฑบ          ณExp03[N] : Lista de variaveis de tela                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRTA272C                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             

Static Function OpcOk(oTela,nOpca,aLstCMP)

Local aArea				:= GetArea()										//Workarea
Local cPerg				:= STR0010											//Pergunta  //", confirma a execu็ใo desta transfer๊ncia?"
Local ni				:= 0												//Contador
Local cChave			:= ""												//Chave de pesquisa
Local lOk				:= .T.												//Controle de fluxo
Local cLock				:= ""												//Controle de semaforo
Local lReproc			:= .F.												//Reprocessar movimento?
Local aID				:= Array(4)										//Identificao completa do caixa
Local nREGSLW			:= 0												//Registro

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar campos obrigatorios  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aLstCMP)
	If aLstCMP[ni][POS_OBR]
		If Empty(&(aLstCMP[ni][POS_VAR]))
			MsgAlert(STR0011 + AllTrim(aLstCMP[ni][POS_TIT]) + STR0012) //"O campo "###" ้ obrigat๓rio e estแ vazio!"
			&("oGet" + StrZero(ni,2) + ":SetFocus()")
			Return .T.
		Endif
	Endif
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar os dados do movimento  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SLW")
SLW->(dbSetOrder(5))	//LW_FILIAL+LW_PDV+LW_OPERADO+LW_ESTACAO+DTOS(LW_DTABERT)+LW_NUMMOV
If !SLW->(dbSeek(xFilial("SLW") + cPDV + cOperado + cEstacao + DtoS(dMovEm) + cNumMov))
	MsgAlert(cNomeUs + STR0013) //", este movimento ้ invแlido!"
	RestArea(aArea)
	Return .T.
Endif
If !(SLW->LW_ORIGEM $ "FRT|LOJ|FAT")
	MsgAlert(cNomeUs + STR0014) //", apenas movimentos com origem no SIGAFRT, SIGALOJA OU SIGAFAT podem ser transferidos!"
	RestArea(aArea)
	Return .T.
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLW_TIPFECH - Status                ณ
//ณ1 - Pendente de conferencia        ณ
//ณ2 - Conferido                      ณ
//ณ3 - Transferido                    ณ
//ณ4 - Pend.transf.subida incompleta  ณ
//ณ5 - Pend.transf.explosao incompletaณ
//ณ6 - Pend.transf.problema na transf.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SLW->LW_TIPFECH # "3"
	Do Case
		Case SLW->LW_TIPFECH == "1"
			MsgAlert(cNomeUs + STR0015)  //", este movimento nao pode ser transferido pois esta pendente de conferencia."
			lOk := .F.
		Case SLW->LW_TIPFECH == "2"
			MsgAlert(cNomeUs + STR0016) //", este movimento nao pode ser transferido pois esta conferido e aguardando a transfer๊ncia automatica."
			lOk := .F.
		Case SLW->LW_TIPFECH == "4"
			MsgAlert(cNomeUs + STR0017) //", este movimento nao pode ser transferido pois esta pendente de transfer๊ncia automแtica por subida incompleta."
			lOk := .F.
		Case SLW->LW_TIPFECH == "5"
			MsgAlert(cNomeUs + STR0018) //", este movimento nao pode ser transferido pois esta pendente de transfer๊ncia automแtica por explosใo incompleta."
			lOk := .F.
		Case SLW->LW_TIPFECH == "6"
			MsgAlert(cNomeUs + STR0019) //", este movimento nao pode ser transferido pois esta pendente de transfer๊ncia automแtica por problemas na transa็ใo."
			lOk := .F.
		Otherwise
			MsgAlert(cNomeUs + STR0020) //", este movimento nao pode ser transferido por motivo indeterminado."
			lOk := .F.		
	EndCase
Endif
If !lOk
	RestArea(aArea)
	Return .T.
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar os dados do portador de destino ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !LjVldBco(cOperDest,cAgenDest,cCCDest,.T.,.T.,.T.)
	RestArea(aArea)
	Return .T.
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar se a carteira de destino eh viavel de utilizacao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cChave := xFilial("FRA") + SLW->(LW_OPERADO + LW_ESTACAO + LW_PDV + LW_NUMMOV) + DtoS(SLW->LW_DTFECHA)
dbSelectArea("FRA")
FRA->(dbSetOrder(6))	//FRA_FILIAL+FRA_LJCXOR+FRA_LJESTA+FRA_LJPDV+FRA_LJMOV+FRA_LJDTFE+FRA_CRDEST
Do Case
	Case AllTrim(cCartDest) == "I"
		//Verificar se o movimento jah nao havia sido transferido para o caixa geral (J)
		If FRA->(dbSeek(cChave + "J"))
			MsgAlert(STR0021) //"Este movimento jแ foi transferido para o caixa geral e nao pode retornar a carteira do caixa da loja!"
			RestArea(aArea)
			Return .T.
		Endif
		//Verificar se o movimento jah nao havia sido transferido para a carteira (0)
		If FRA->(dbSeek(cChave + "0"))
			MsgAlert(STR0022) //"Este movimento jแ foi transferido para a carteira simples e nao pode retornar a carteira do caixa da loja!"
			RestArea(aArea)
			Return .T.
		Endif		
	Case AllTrim(cCartDest) == "J"
		//Verificar se o movimento jah nao havia sido transferido para a carteira simples, caso tenha sido, indica um reprocessamento
		If FRA->(dbSeek(cChave + "J"))
			If !ApMsgYesNo(cNomeUs + STR0023) //", este movimento jแ foi transferido para o caixa geral, deseja reprocessar esta transfer๊ncia?"
				RestArea(aArea)
				Return .T.
			Endif
			lReproc := .T.
		Else
			//Verificar se o movimento jah nao havia sido transferido para a carteira (0)
			If FRA->(dbSeek(cChave + "0"))
				MsgAlert(STR0024) //"Este movimento jแ foi transferido para a carteira simples e nao pode retornar a carteira do caixa geral!"
				RestArea(aArea)
				Return .T.				
			Endif
		Endif
	Case AllTrim(cCartDest) == "0"
		//Verificar se o movimento jah nao havia sido transferido para a carteira simples, caso tenha sido, indica um reprocessamento
		If FRA->(dbSeek(cChave + "0"))
			If !ApMsgYesNo(cNomeUs + STR0025) //", este movimento jแ foi transferido para a carteira (0), deseja reprocessar esta transfer๊ncia?"
				RestArea(aArea)
				Return .T.
			Endif
			lReproc := .T.
		Endif
End Case
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIdentificacao completa do caixa  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aID[1] := SLW->LW_OPERADO
aID[2] := SLW->LW_ESTACAO
aID[3] := SLW->LW_SERIE
aID[4] := SLW->LW_PDV
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConfirmar acao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lReproc .OR. ApMsgYesNo(cNomeUs + cPerg)
	nOpca := 1
	nREGSLW := SLW->(Recno())
	cLock := "SLW" + SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + LW_ESTACAO) + DtoS(SLW->LW_DTABERT) + SLW->LW_NUMMOV		//Alias + Chave(05)
	If FRT272CGrv(aID,cLock,lReproc,nREGSLW)
		//Limpar campos
		IniciaVar(aLstCMP)
		MsgAlert(cNomeUs + STR0026) //", transfer๊ncia realizada com sucesso!"
	Endif
Endif
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณFRT272CGrv บAutor  ณVendas Clientes       บ Data ณ30/11/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de gravacao do processo de transferencia de movimento      บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Referencia completa do caixa                           บฑฑ
ฑฑบ          ณExp02[C] : Controle de semaforo                                   บฑฑ
ฑฑบ          ณExp03[L] : Indica se trata-se de um reprocessamento de transf.    บฑฑ
ฑฑบ          ณExp04[N] : Registro da SLW que esta sendo processado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L] : Retornar se o processo de gravacao foi bem sucedido     บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRTA272C                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FRT272CGrv(aID,cLock,lReproc,nREGSLW)

Local lRet				:= .T.												//Retorno
Local aArea				:= GetArea()										//WorkArea
Local lUsaMVD			:= SuperGetMV("MV_LJTRMVD",.F.,.F.)				//Utiliza detalhamento de movimento bancario da transferencia de caixas?
Local cMens				:= ""												//Mensagem de retorno da funcao LjExecTrans
Local aLstOrc			:= {}												//Lista de orcamentos do movimento
Local ni				:= 0												//Contador

Default aID			:= {}
Default cLock			:= ""
Default lReproc		:= .F.
Default nREGSLW		:= 0

If Len(aID) == 0 .OR. ValType(aID) # "A" .OR. Empty(cLock) .OR. Empty(nREGSLW) .OR. ValType(nREGSLW) # "N"
	Return !lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTrazer lista de orcamentos do movimento correspondente ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aLstOrc := LjExOrc(aID,dMovEm,cNumMov,.F. /*nao cons. cancelados*/,.T./*cons. incompletos*/,.T./*retornar lista*/)
If Len(aLstOrc) == 0
	MsgAlert(STR0027) //"Nenhum or็amento foi encontrado relacionado com este movimento!"
	RestArea(aArea)
	Return !lRet	
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso seja um reprocessamento, desmarcar os orcamentos como            ณ
//ณjah transferidos para forcar um novo processamento de transferencia.  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lReproc
	For ni := 1 to Len(aLstOrc)
		dbSelectArea("SL1")
		SL1->(dbSetOrder(1))
		If SL1->(dbSeek(aLstOrc[ni][1] + aLstOrc[ni][2]))
			If SL1->L1_TREFETI     
				Reclock("SL1",.F.)
				SL1->L1_TREFETI := .F.
				MsUnlock()
			Endif
		Endif
	Next ni
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณControle de semaforo  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !MayIUseCode(cLock)
	MsgAlert(cNomeUs + STR0028) //", este movimento estแ sendo processado no momento, por favor, tente mais tarde."
	RestArea(aArea)
	Return !lRet
Endif
Begin Transaction
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualizar SL1,SE1,SE5 e FRAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Parametros : Carteira,Portador,Agencia,Conta,ID Caixa,Data Mov.,Mov.,Pesq.Orc?,Lista orc.,Mens Erro,Int.proc.orc.s/titulo?
If !LjExecTrans(cCartDest,cOperDest,cAgenDest,cCCDest,aID,dMovEm,cNumMov,.F.,aLstOrc,@cMens,.F.,lUsaMVD)
	DisarmTransaction()
	lRet := !lRet
Endif
End Transaction	
Leave1Code(cLock)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณIniciaVar  บAutor  ณVendas Clientes       บ Data ณ30/11/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para inicializacao das variaveis de tela                   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Lista de campos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRTA272C                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IniciaVar(aLstCMP)

Local ni               := 0		//Contador

Default aLstCMP		:= {}

If Len(aLstCMP) == 0
	Return Nil
Endif
For ni := 1 to Len(aLstCMP)
	//Inicializacao de variavel
	&(aLstCMP[ni][POS_VAR]) := CriaVar(aLstCMP[ni][POS_NOM])
	//Valor padrao
	If !Empty(aLstCMP[ni][POS_VLP])
		&(aLstCMP[ni][POS_VAR]) := aLstCMP[ni][POS_VLP]
	Endif
	//Obrigatoriedade
	aLstCMP[ni][POS_OBR] := CampoOb(aLstCMP[ni][POS_NOM])
	//Titulo	
	aLstCMP[ni][POS_TIT] := RetTitle(aLstCMP[ni][POS_NOM])
Next ni

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณCampoOb    บAutor  ณVendas Clientes       บ Data ณ01/12/10        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que determina se um determinado campo do dicionario eh     บฑฑ
ฑฑบ          ณobrigatorio                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome do campo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L] : Retorna se o campo eh obrigatorio                       บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRTA272C                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CampoOb(cCampo)

Local lRet				:= .F.					//Retorno
Local aAreaSX3         := SX3->(GetArea())		//WorkArea

Default cCampo			:= ""

If !(nModulo == 5)
	If !Empty(cCampo)
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek(Upper(AllTrim(cCampo))))
			If X3Uso(SX3->X3_USADO) .AND. ((SubStr(Bin2Str(SX3->X3_OBRIGAT),1,1) == "x") .OR. VerByte(SX3->X3_RESERV,7))
				lRet := !lRet
			Endif
		Endif
	Endif
	RestArea(aAreaSX3)
ElseIf (nModulo == 5)
	If !(cCampo == "LW_SERIE" .OR. cCampo == "LW_PDV")  
		If !Empty(cCampo)
			dbSelectArea("SX3")
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(Upper(AllTrim(cCampo))))
				If X3Uso(SX3->X3_USADO) .AND. ((SubStr(Bin2Str(SX3->X3_OBRIGAT),1,1) == "x") .OR. VerByte(SX3->X3_RESERV,7))
					lRet := !lRet
				Endif
			Endif
		Endif
		RestArea(aAreaSX3)    
	EndIf
EndIf

Return lRet

