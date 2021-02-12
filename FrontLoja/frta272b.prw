#INCLUDE "Protheus.ch"
#INCLUDE "FRTA272B.ch"

#DEFINE CLRTEXT		0
#DEFINE CLRBACK		12632256
#DEFINE CLRBACKCTR		16777215
#DEFINE TAMTOT			0

Static lFechConf 	:= SuperGetMV( "MV_LJCONFF",,.F. ) .AND. LjxBGetPaf()[2] //Verifica se e loja offline e se a conferencia de caixa esta ativa
Static lMvLjPdvPaf	:= LjxBGetPaf()[2] //Verifica se e loja offline

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFRTA272B   บAutor  ณVendas Clientes       บ Data ณ  27/08/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface para fechamento de caixa. Esta funcionalidade pode   บฑฑ
ฑฑบ          ณser utilizada a partir do SIGAFRT assim como do SIGALOJA.      บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Tipo de oper. do Cx_Abre_Fecha [A]bertura [F]echam. บฑฑ
ฑฑบ          ณExp02[L] : Parametro deve receber um valor por referencia para บฑฑ
ฑฑบ          ณ           que a rotina de chamada tenha como decidir se a     บฑฑ
ฑฑบ          ณExp03[O] : Objeto timer FRTA271 para imp. da leitura X         บฑฑ
ฑฑบ          ณExp04[C] : Hora do FRTA271 para imp. da leitura X              บฑฑ
ฑฑบ          ณExp05[O] : Objeto documento do FRTA271 para imp. da leitura X  บฑฑ
ฑฑบ          ณExp06[C] : Documento do FRTA271 para imp. da leitura X         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

RETORNOS PARA FUNCAO CX_ABRE_FECHA (LOJA260):
--------------------------------------------------------------------------------
	CHAMADA TIPO 1 - LOJA260 - SIGALOJA
		RETORNO	: .T.
			ABERTURA	: CONTINUAR PROCESSAMENTO?	[S] LRET 	:= .T.
						  GRAVAR SLW?				[S] LATUSLW	:= .T.
			FECHAMENTO	: CONTINUAR PROCESSAMENTO?	[S] LRET 	:= .T.
						  GRAVAR SLW?				[S] LATUSLW	:= .T.
		RETORNO	: .F.
			ABERTURA	: CONTINUAR PROCESSAMENTO?	[N] LRET 	:= .F.
						  GRAVAR SLW?				[N] LATUSLW	:= .F.
			FECHAMENTO	: CONTINUAR PROCESSAMENTO?	[N] LRET 	:= .F.
						  GRAVAR SLW?				[N] LATUSLW	:= .F.
--------------------------------------------------------------------------------
	CHAMADA TIPO 2 - FRTA271 - SIGAFRT
		RETORNO	: .T.
			ABERTURA	: CONTINUAR PROCESSAMENTO?	[S] LRET 	:= .T.
						  GRAVAR SLW?				[S] LATUSLW	:= .T.
			FECHAMENTO	: CONTINUAR PROCESSAMENTO?	[S] LRET 	:= .T.
						  GRAVAR SLW?				[N] LATUSLW	:= .F.
		RETORNO	: .F.
			ABERTURA	: CONTINUAR PROCESSAMENTO?	[N] LRET 	:= .F.
						  GRAVAR SLW?				[N] LATUSLW	:= .F.
			FECHAMENTO	: CONTINUAR PROCESSAMENTO?	[S] LRET 	:= .F.
						  GRAVAR SLW?				[N] LATUSLW	:= .F.
--------------------------------------------------------------------------------
*/

Function FRTA272B(cTipo,lAtuSLW,oHora,cHora,oDoc,cDoc, cOperAbrFEc)

Local lRet				:= .T.				//Retorno
Local aArea				:= GetArea()		//Retrato da workarea
Local cCaixa			:= ""				//Caixa (operador)
Local cEstacao			:= ""		   		//Estacao
Local cPDV				:= ""				//PDV
Local cCxGer			:= ""				//Codigo do caixa geral
Local dDataAb			:= ""				//Data de abertura
Local cHrAb				:= ""				//Hora de abertura
Local dDataF			:= ""				//Data de fechamento
Local cHrF				:= ""				//Hora de fechamento
Local lAcumDia			:= ""				//Imprimir acumulados diarios
Local lLeitX			:= ""				//Imprimir leitura X
Local lReduZ			:= ""				//Imprimir reducao Z
Local cMens1			:= STR0001 			//"Selecione para a impressใo "
Local cMens2			:= STR0002 			//" ap๓s confirma็ใo."
Local lHabRelFis		:= .F.				//Habilita as opcoes de impressoes da impressora fiscal
Local nOpca				:= 0				//Opcao de retornado da interface
Local ni				:= 0				//Contador
Local aLstTab			:= {"SL1","SL2","SL4","SLT","SLW","FRA"}	//Lista de tabelas essenciais
Local lUsaFecha			:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utilizar conf. de fechamento
Local bErro				:= {}				//Bloco de codigo para tratamento de erro
Local cErro				:= ""				//Mensagem de erro
Local lErro				:= .F.				//Aponta existencia de erro no processamento
Local aDtHrECF			:= {}				//Array para data e hora retornada da ECF
Local aRotEssen 		:= {"LOJA260","LOJA340","LOJA350","FRTA271","LOJA756"}	//Rotina essenciais 
Local lOk				:= .F.				//Determina se deve-se sair da rotina apos validacoes
Local cEmpFil			:= AllTrim(cEmpAnt) + " - " + AllTrim(cFilAnt)	//Empresa + Filial
Local lMntGDSLT			:= .F.				//Determina que o grid deve ser montado a partir da SLT ao inves da SL1 e SL4
Local aRegSLT			:= {}				//Lista de registros da conferencia a ser realizada na retaguarda
Local lObgCon			:= SuperGetMV("MV_LJOBGCF",,.T.) //indica se a Conferencia de Caixa eh obrigatoria
Local lLjExMov			:= FindFunction("LjExMov")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a estacao possui Display ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lUsaDisplay := !Empty(LjGetStation("DISPLAY"))

//Variaveis da interface e formatacoes
Static oTela
Static oGrp01
Static oGrp02
Static oGrp03
Static oGrp04
Static oCaixa
Static oEstacao
Static oPDV
Static oCxGer
Static oNumMov
Static oDataAb
Static oHrAb
Static oDataF
Static oHrF
Static oAcumDia
Static oLeitX
Static oReduZ
Static oLstAp
Static oGet01
Static oSay01
Static oSay02
Static oSay03
Static oSay04
Static oSay05
Static oSay06
Static oSay07
Static oSay08
Static oSay09
Static oSay13
Static oSay15
Static oSay16
Static oSay17
Static oSay18
Static oSay19
Static oSay20
Static oSay21
Static oBot01
Static oBot02
Static oBot03
Static oBot04
Static cPTM				:= "@!"
Static cPTN01			:= "@E 99,999,999.99"
Static cPTD				:= "@D"
Static cPTH				:= "99:99"
Static nLargS			:= 033
Static nLargS02			:= 050
Static nLargG			:= 090
Static nLargC			:= 065
Static nLargB			:= 040
Static nAltura			:= 010
Static nAltBot			:= 013
Static aTotal			:= {}
Static oFont01
Static oEmpFil

Private lConfCega		:= SuperGetMV("MV_LJEXAPU",.T.,.F.) == .F.	//Utiliza a conferencia cega?
Private lDetADMF		:= SuperGetMV("MV_LJDESM",.T.,.F.) .AND. SLT->(FieldPos("LT_ADMIFIN")) > 0	//Utiliza detalhamento por administradora financeira
Private cCxGeral		:= Substr(AllTrim(SuperGetMV("MV_CXLOJA",.F.,"")),1,TamSX3("A6_COD")[1])	//Caixa geral determinado
Private aID			:= {}	//Identificacao completa do caixa [1] - Operador [2] - Estacao [3] - Serie [4] - PDV
Private cNumMov        := AllTrim(LjNumMov())	//Retorno o numero do movimento atual
Private dDtMov			:= Nil	//Data do abertura do movimento
Private dDtFMov		:= Nil	//Data de fechamento do movimento
Private cChvFecha		:= ""	//Chave da SLW para fechamento
Private cNomeUs		:= AllTrim(UsrRetName(__cUserID))	//Nome do usuario padrao
Private lHabTroco     	:= SL1->(FieldPos("L1_TROCO1")) > 0 .AND. SuperGetMV("MV_LJTROCO",,.F.)	.AND. SuperGetMV("MV_LJTRDIN", ,0) == 1 //Habilita troco
Private aCmp			:= {}	//Campos da GetDados
Private aCmpAlter		:= {}	//Campos da GetDados habilitados para alterar
Private nModoChama		:= 0	//1. LOJA260 2. FRTA271
Private aNumerario		:= {}	//1. Forma de pagamento 2. Descricao da FP 3. Quantidade 4. Moeda 5. Valor a ser apontado 6. Valor apurado 7. Cod Adm Fin 8. Nome Adm Fin
Private lImpFiscal		:= IIf(Len(Alltrim(LjGetStation("IMPFISC"))) == 0,.F.,.T.) .AND. Type("nHdlECF") == "N" 	//Det. se a estacao utiliza impressora fiscal
Private nTamAgen		:= TamSX3("A6_AGENCIA")[1]	//Tamanho da agencia
Private nMoedaC		:= 1	// Localizadas : Moeda corrente
Private lOnline		:= .F.	//Acesso a base eh online
Private lPAF			:= .F.	//Acesso do PAF
//Posicionamento de colunas
Private POS_FP			:= 0
Private POS_DESCFP		:= 0
Private POS_QTDE		:= 0
Private POS_MOEDA		:= 0
Private POS_VALDIG		:= 0
Private POS_VALAPU		:= 0
Private POS_CODADM		:= 0
Private POS_DESADM		:= 0
//Totalizadores
Private oSay10
Private oSay11
Private oSay12
Private oSay14
Private cTot01			:= ""
Private cTot02			:= ""
Private cTot03			:= ""
Private cTot04			:= ""

Default cTipo			:= "F"
Default lAtuSLW		:= .F.
Default oHora			:= Nil
Default cHora			:= ""
Default oDoc			:= Nil
Default cDoc			:= ""
Default cOperAbrFEc		:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar se a confer๊ncia completa eh utilizada  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lUsaFecha
	lAtuSLW := .T.
	RestArea(aArea)
	Return lRet
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar se a rotina esta sendo executada dentro dos modulos permitidos  ณ
//ณ12 - SIGALOJA / 23 - SIGAFRT / 72 - PAF                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !AmIIn(12,23,72)
	lUsaSLW := .T.
	RestArea(aArea)
	Return lRet
EndIf

If nModulo = 5		//SIGAFAT
	lOnline := .T.
ElseIf lMvLjPdvPaf  //SIGALOJA OFFLINE
	lOnline := .F.
	lPAF	:= .T.
ElseIf nModulo = 12	//SIGALOJA ONLINE
	lOnline := .T.
ElseIf nModulo = 23	//SIGAFRT
	lOnline := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar as rotinas essenciais  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aRotEssen)
	If IsInCallStack(aRotEssen[ni])
		lOk := .T.
		Exit
	Endif
Next ni

If !lOk
	lAtuSLW := .F.
	RestArea(aArea)
	Return !lRet	
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar existencia de tabelas essenciais  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aLstTab)
	If !AliasInDic(aLstTab[ni])
		//Tabela essencial inexistente no dicionario, indica que o update do pacote nao foi aplicado, sair
		lAtuSLW := .T.
		RestArea(aArea)
		Return lRet
	Endif
Next ni

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinir array de identificacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aID := LjInfoCxAt(1,.F.,.T.)		//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV + TAMANHO DE CADA CAMPO CORRESPONDENTE

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializar variaveis  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Se chamada foi feita atraves da rotina abertura e fechamento do SIGALOJA (LOJA260) e eh uma conexao online ou offline PAF
If AllTrim(FunName()) $ aRotEssen[1] + "|" + aRotEssen[2] + "|" + aRotEssen[3] + "|" + aRotEssen[5] .AND. (lOnline .OR. lPAF) 
	If lOnline
		//No fechamento atraves da rotina de abertura e fechamento de caixa (retaguarda SIGALOJA), desconhece-se qual o PDV, estacao e movimento que esta em aberto, pois o usuario pode selecionar qualquer registro no Browse, e pode ser selecionado outro caixa.
		cChvFecha := LjUltMovAb(2,aID[1][1],aID[4][1],aID[2][1],,.F., cOperAbrFEc)
		nModoChama := 1		//SIGALOJA
	Else
		//Pesquisar se existe conferencia e/ou movimento em aberto na retaguarda
		cChvFecha := ExConfAbLW(2)
		//Caso nao tenha sido encontrada nada na retaguarda, pesquisar localmente
		If Empty(cChvFecha) .OR. ValType(cChvFecha) # "C"
			Do While .T.
				cChvFecha := LjUltMovAb(2,aID[1][1],,,,.T.)
				If Empty(cChvFecha)
					Exit
				Endif
				//Ao pesquisar localmente, verificar se a conferencia nao foi feita na retaguarda. Caso tenha sido feita, desconsiderar a chave
				If LjRetSitLW(cChvFecha,.T.) == "02"
					cChvFecha := ""
				Else
					Exit
				Endif
			EndDo
		Endif
		nModoChama := 2
	Endif
Else
	//Caso a chamada nao tenha sido feita pela funcao de abertura e fechamento de caixa no modulo SIGAFRT, sair
	If !IsInCallStack("CX_ABRE_FECHA") .OR. lOnline
		Alert(STR0065) //"Saiu na validacao do CX_Abre_FECHA - FRT"
		lAtuSLW := .F.
		RestArea(aArea)
		Return !lRet
	Endif
	//Pesquisar se existe conferencia e/ou movimento em aberto do operador na retaguarda
	cChvFecha := ExConfAbLW(2)
	//Caso nao tenha sido encontrada nada na retaguarda, pesquisar localmente	
    If Empty(cChvFecha) .OR. ValType(cChvFecha) # "C"
		//Caso nao exista numero de movimento
		Do While .T.
			If Empty(cNumMov)
				cChvFecha := LjUltMovAb(2,aID[1][1],,,,.T.)
			Else
				cChvFecha := LjUltMovAb(1,aID[1][1],aID[4][1],aID[2][1],cNumMov,.T.)
			Endif
			If Empty(cChvFecha)
				Exit
			Endif
			//Ao pesquisar localmente, verificar se a conferencia nao foi feita na retaguarda. Caso tenha sido feita, desconsiderar a chave
			If LjRetSitLW(cChvFecha,.T.) == "02"
				cChvFecha := ""
			Else
				Exit
			Endif
		EndDo		
	Endif
	nModoChama := 2		//SIGAFRT
EndIf

//Habilitar as impressoes no ECF?
lHabRelFis := lImpFiscal .AND. lFiscal
//Posicionar SLW caso exista chave
If !Empty(cChvFecha)
	DbSelectArea("SLW")
	SLW->(dbSetOrder(3))	//LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
	SLW->(dbSeek(cChvFecha))
	If !SLW->(Found())
		lAtuSLW := .T.
		RestArea(aArea)
		Return lRet
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso seja uma conferencia que sera feita a partir da retaguarda, trazer os dados de estacao, serie e PDV originais da SLW  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nModulo == 23 .OR. nModulo == 5 .OR. nModulo == 12 //23=SIGAFRT; //5=SIGAFAT; //12=SIGALOJA
		aID[1][1] := SLW->LW_OPERADOR
		aID[2][1] := SLW->LW_ESTACAO
		aID[3][1] := SLW->LW_SERIE
		aID[4][1] := SLW->LW_PDV
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso seja uma conferencia a ser realizada na retaguarda,       ณ
	//ณdefinir variavel que fara com que a rotina de montagem         ณ
	//ณda grid utilize os dados da SLT, que subiram a partir do PDV   ณ
	//ณao inv้s de recompor os valores a partir da SL1 e SL4.         ณ
	//ณJustificativa : Caso existiam vendas paradas no PDV deste mov. ณ
	//ณisso gerara divergencias nos valores da conferencia.           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If nModoChama == 1 .AND. AllTrim(SLW->LW_TIPFECH) == "1" .AND. Upper(AllTrim(SLW->LW_ORIGEM)) $ "FRT|FAT|LOJ"    
    	//Verificar se o movimento da SLT existe na retaguarda
    	If F272BExSLT(SLW->LW_OPERADO,SLW->LW_NUMMOV,SLW->LW_DTFECHA,SLW->LW_ESTACAO,SLW->LW_PDV)
	    	lMntGDSLT := .T.
	    Endif
    EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEm conferencias na retaguarda, ler o campo LW_OPCEXIB         ณ
	//ณpara definir a forma de como os dados devem ser apresentados  ณ
	//ณem tela (para conferencia na retaguarda),respeitando a config.ณ
	//ณde exibicao dos dados definidos na estacao de origem.         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMntGDSLT .AND. SLW->(FieldPos("LW_OPCEXIB")) > 0
		If SLW->LW_OPCEXIB $ "0|1|2|3"
			Do Case
				Case SLW->LW_OPCEXIB == "0"
					lDetADMF	:= .F.
					lConfCega	:= .T.
				Case SLW->LW_OPCEXIB == "1"
					lDetADMF	:= .F.
					lConfCega	:= .F.				
				Case SLW->LW_OPCEXIB == "2"
					lDetADMF	:= .T.
					lConfCega	:= .T.				
				Case SLW->LW_OPCEXIB == "3"
					lDetADMF	:= .T.
					lConfCega	:= .F.
			EndCase
		Endif
	EndIf	
EndIf

//Campos totalizadores
aAdd(aTotal,{"oSay10","cTot01"})
aAdd(aTotal,{"oSay11","cTot02"})
If !lConfCega
	aAdd(aTotal,{"oSay12","cTot03"})
	aAdd(aTotal,{"oSay14","cTot04"})
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInteracao com usuario quanto ao tipo de fechamento  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nModoChama == 1

	If cTipo == "F"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSem Pendencias de Caixaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Empty(cChvFecha)
			lAtuSLW := .T.
			RestArea(aArea)
			Return lRet
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCom Pendencias de Caixaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaixa Abertoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤู
			If Empty(SA6->A6_DATAFCH)
				If !LjExOrc() .And. iIf(lLjExMov, !LjExMov(), .T.)
					lAtuSLW := .T.
					RestArea(aArea)
					Return lRet
				EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCaixa Fechadoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Else

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSEM Movimentoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty(SLW->LW_DTFECHA) .AND. !LjExOrc({aID[1][1],aID[2][1],aID[3][1],aID[4][1]},SLW->LW_DTFECHA,SLW->LW_NUMMOV);
					.And. iIf(lLjExMov, !LjExMov(aID[1][1],SLW->LW_DTFECHA,SLW->LW_NUMMOV), .T.)
					If nModoChama == 1 .AND. AllTrim(Upper(SLW->LW_ORIGEM)) $ "FRT|FAT|LOJ"
						ApMsgInfo(STR0067) //Nenhuma das vendas feitas neste movimento nใo puderam ser encontradas na retaguarda!
					EndIf
					lAtuSLW := .T.
					RestArea(aArea)
					Return lRet

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCOM Movimentoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู					
				ElseIf !Empty(SLW->LW_DTFECHA)
					If !ApMsgYesNo(cNomeUs + STR0004) //", existe uma confer๊ncia de fechamento de caixa pendente, deseja realizar a confer๊ncia agora?"
						ApMsgAlert(STR0005) //"Opera็ใo de fechamento de caixa cancelado."
						lAtuSLW := .F.
						RestArea(aArea)
						Return !lRet
					EndIf
				EndIf

			EndIf
		EndIf

	//ฺฤฤฤฤฤฤฤฤฟ
	//ณAberturaณ
	//ภฤฤฤฤฤฤฤฤู
	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSEM Pendenciaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Em caso de chamada por abertura, apenas validar se existem movimentos sem conferencia, caso exista retornar variaveis para interrupcao da abertura
		If Empty(cChvFecha)
			lAtuSLW := .T.
			RestArea(aArea)
			Return lRet

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCom pendencia NAO obrigando conferenciaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//se houver conferencia pendentes, permite que o caixa seja aberto, criando um novo movimento(LW_NUMMOV)
		ElseIf !Empty(cChvFecha) .AND. !lObgCon
			lAtuSLW := .T.
			RestArea(aArea)
			Return lRet

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCom pendencia obrigando conferenciaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Else
			MsgAlert(cNomeUs + STR0006) //", existe(m) movimento(s) pendente(s) de confer๊ncia para este caixa, impossํvel fazer a abertura do caixa."
			lAtuSLW := .F.
			RestArea(aArea)
			Return !lRet
		Endif

	EndIf

Else

	If cTipo == "A" .OR. (cTipo == "F" .AND. Empty(cChvFecha))
		//Em caso de chamada por abertura, apenas validar se existem movimentos sem conferencia, caso exista retornar variaveis para 
		//interrupcao da abertura

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSem Pendenciaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Empty(cChvFecha)
			lAtuSLW := .T.
			RestArea(aArea)
			Return lRet

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCom pendencia NAO obrigando conferenciaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//se houver conferencia pendentes, permite que o caixa seja aberto, criando um novo movimento(LW_NUMMOV)
		ElseIf !Empty(cChvFecha) .AND. !lObgCon
			lAtuSLW := .T.
			RestArea(aArea)
			Return lRet			
		Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCom pendencia obrigando conferenciaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			MsgAlert(cNomeUs + STR0006) //", existe(m) movimento(s) pendente(s) de confer๊ncia para este caixa, impossํvel fazer a abertura do caixa."
			lAtuSLW := .F.
			RestArea(aArea)
			Return !lRet
		EndIf
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFechamento com Pendenciaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Caso nao exista orcamentos feitos na data, sair
		lLjExMov := lLjExMov .And. LjExMov()
		If !LjExOrc(Nil, SLW->LW_DTABERT) .And. !lLjExMov
			lAtuSLW := .T.
			RestArea(aArea)
			Return lRet		
		Endif
	Endif
	
EndIf

//Permissใo de caixa para efetuar a conferencia de fechamento de caixa:
If !F272BFecPermite()
	MsgAlert(STR0086 + cNomeUs + STR0087, STR0077) //#"O usuแrio caixa '" ##"' nใo possui permissใo para efetuar a confer๊ncia de caixa." ###"Aten็ใo"
	Return .F.
EndIf

If lUsaDisplay
	DisplayEnv(StatDisplay(),  "3E"+ " " )  
End  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTrazer data e hora da ECF  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aDtHrECF 	:= LjDtHrECF(.T.)
cCaixa		:= aID[1][1] + " - " + CxRetNome(aID[1][1])
cEstacao	:= aID[2][1]
cPDV		:= aID[4][1]
cCxGer		:= cCxGeral + " - " + CxRetNome(cCxGeral)
cNumMov		:= SLW->LW_NUMMOV
dDataAb		:= DtoC(SLW->LW_DTABERT)
cHrAb		:= SLW->LW_HRABERT
dDataF		:= DtoC(aDtHrECF[1])
cHrF		:= aDtHrECF[2]
lAcumDia	:= .F.
lLeitX		:= .F.
lReduZ		:= .F.
dDtMov		:= SLW->LW_DTABERT
dDtFMov		:= SLW->LW_DTFECHA

//Fontes
oFont01	:= TFont():New("Tahoma",,14,,.T.,,,,,.F.,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem da tela de conferencia de caixaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oTela TITLE STR0007 FROM 000, 000  TO 442,623 COLORS CLRTEXT,CLRBACK PIXEL STYLE 128 //"Confer๊ncia de caixa"
//Grupos de campos
oGrp01 	:= tGroup():New(004,004,088,148,STR0008,oTela,CLRTEXT,CLRBACK,.T.) //"Dados da esta็ใo"
oGrp02 	:= tGroup():New(004,153,088,309,STR0009,oTela,CLRTEXT,CLRBACK,.T.) //"Movimento"
oGrp03	:= tGroup():New(176,004,220,100,STR0010,oTela,CLRTEXT,CLRBACK,.T.) //"Opera็๕es"
oGrp04	:= tGroup():New(176,105,220,309,STR0011,oTela,CLRTEXT,CLRBACK,.T.) //"Totalizadores e comandos"

//Campos do grupo 01
oSay01 	:= tSay():New(015,008,{||STR0012},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Caixa"
oCaixa 	:= tGet():New(015,044,{|x| If(PCount() > 0,cCaixa := x,cCaixa)},oTela,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .T.}/*when*/,,,/*change*/,.T.,.F.,,"cCaixa")
oSay02 	:= tSay():New(029,008,{||STR0013},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Esta็ใo"
oEstacao:= tGet():New(029,044,{|x| If(PCount() > 0,cEstacao := x,cEstacao)},oTela,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cEstacao")
oSay03 	:= tSay():New(043,008,{||STR0014},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"PDV"
oPDV	:= tGet():New(043,044,{|x| If(PCount() > 0,cPDV := x,cPDV)},oTela,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cPDV")
oSay04 	:= tSay():New(057,008,{||STR0015},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Cx. geral"
oCxGer	:= tGet():New(057,044,{|x| If(PCount() > 0,cCxGer := x,cCxGer)},oTela,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cCxGer")
oSay21 	:= tSay():New(071,008,{||STR0064},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Empresa - Filial : "
oEmpFil	:= tGet():New(071,044,{|x| If(PCount() > 0,cEmpFil := x,cEmpFil)},oTela,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cEmpFil")

//Campos do grupo 02
oSay05 	:= tSay():New(015,159,{||STR0009},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Movimento"
oNumMov	:= tGet():New(015,205,{|x| If(PCount() > 0,cNumMov := x,cNumMov)},oTela,nLargG,nAltura,cPTM,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cNumMov")
oSay06 	:= tSay():New(029,159,{||STR0016},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Dt.abertura"
oDataAb	:= tGet():New(029,205,{|x| If(PCount() > 0,dDataAb := x,dDataAb)},oTela,nLargG,nAltura,cPTD,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"dDataAb")
oSay07 	:= tSay():New(043,159,{||STR0017},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Hr.abertura"
oHrAb	:= tGet():New(043,205,{|x| If(PCount() > 0,cHrAb := x,cHrAb)},oTela,nLargG,nAltura,cPTH,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cHrAb")
oSay08 	:= tSay():New(057,159,{||STR0018},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Dt.fechamen."
oDataF	:= tGet():New(057,205,{|x| If(PCount() > 0,dDataF := x,dDataF)},oTela,nLargG,nAltura,cPTD,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"dDataF")
oSay09 	:= tSay():New(071,159,{||STR0019},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,nLargS,nAltura) //"Hr.fechamen."
oHrF	:= tGet():New(071,205,{|x| If(PCount() > 0,cHrF := x,cHrF)},oTela,nLargG,nAltura,cPTH,/*valid*/,CLRTEXT,CLRBACKCTR,/*font*/,,,.T.,,,{|| .F.}/*when*/,,,/*change*/,.T.,.F.,,"cHrF")

//Grid de formas de pagamento
MontaGD(@oGet01,092,004,172,310,lMntGDSLT,@aRegSLT)

//Caixas de marcacao
oAcumDia:= tCheckBox():New(184,008,STR0020	,{|| lAcumDia}	,oTela,nLargC,nAltura,,{|| lAcumDia := !lAcumDia}		,,{|| .T.},CLRTEXT	,CLRBACKCTR,,.T.,cMens1 + STR0021 + cMens2	,,{|| lHabRelFis}) //"Acumulados diแrios"###"dos acumulados diแrios"

//Verifico se ้ NFC-e ou SAT, para nใo exibir a op็ใo de Redu็ใo Z
If !(LJGetStation("NFCE") .Or. LJGetStation("USESAT"))
	oLeitX	:= tCheckBox():New(194,008,STR0022	,{|| lLeitX}	,oTela,nLargC,nAltura,,{|| lLeitX := VldLeitX(lLeitX)}	,,{|| .T.},CLRTEXT	,CLRBACKCTR,,.T.,cMens1 + STR0023 + cMens2	,,{|| lHabRelFis}) //"Leitura X"###"da leitura X"
	oReduZ	:= tCheckBox():New(204,008,STR0024	,{|| lReduZ}	,oTela,nLargC,nAltura,,{|| lReduZ := VldRedZ(lReduZ)}	,,{|| .T.},CLRTEXT	,CLRBACKCTR,,.T.,cMens1 + STR0025 + cMens2	,,{|| lHabRelFis}) //"Redu็ใo Z"###"da redu็ใo Z"
EndIf

//Botoes de comando
oBot01	:= tButton():New(184,210,STR0026	,oTela	,{|| OpcOk(oTela,@nOpca)}										,nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Confirmar"
oBot03	:= tButton():New(203,210,STR0073	,oTela	,{|| OpcSimples(oTela,@nOpca,cTipo)}							,nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Simplificada"
oBot02	:= tButton():New(184,260,STR0027	,oTela	,{|| ImpConf(cCaixa,cEstacao,cPDV,dDataAb,cHrAb,dDataF,cHrF)}	,nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Imprimir"
oBot04	:= tButton():New(203,260,STR0028	,oTela	,{|| OpcCanc(oTela,@nOpca)}										,nLargB,nAltBot,,,,.T.,,,,{|| .T.}) //"Botใo Cancelar"

//Totalizadores
If lConfCega
	FR272BExTot({1,2})
Else
	FR272BExTot({1,2,3,4})
EndIf

oSay16 	:= tSay():New(185,110,{||STR0029},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)	//"Quantid."
oSay18 	:= tSay():New(185,140,{||":"},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
oSay10 	:= tSay():New(185,143,{||cTot01},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)
oSay17 	:= tSay():New(193,110,{||STR0030},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura) 	//"Digitado"
oSay19 	:= tSay():New(193,140,{||":"},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
oSay11 	:= tSay():New(193,143,{||cTot02},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)

If !lConfCega
	oSay15 	:= tSay():New(201,110,{||STR0031},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura) 	//"Apurado"
	oSay20 	:= tSay():New(201,140,{||":"},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
	oSay12 	:= tSay():New(201,143,{||cTot03},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)
	oSay13 	:= tSay():New(209,110,{||STR0032},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura) 	//"Saldo"
	oSay18 	:= tSay():New(209,140,{||":"},oTela,/*pict*/,/*fonte*/,,,,.T.,CLRTEXT,CLRBACK,02,nAltura)
	oSay14 	:= tSay():New(209,143,{||cTot04},oTela,/*pict*/,oFont01,,,,.T.,CLRTEXT,CLRBACK,nLargS02,nAltura)	
	//Formatar o saldo
	If LstCalc(3,,.T.) == 0
		oSay14:nClrText := CLR_BLUE
	Else
		oSay14:nClrText := CLR_RED
	Endif
Endif

ACTIVATE MSDIALOG oTela  ON INIT(oGet01:oBrowse:SetFocus()) CENTERED

//A partir deste ponto todos os retornos sao para chamadas do tipo FECHAMENTO
bErro := ErrorBlock({|e| VerErro(e,@lErro,@cErro)})

If nOpca == 1 		//Gravacao
	//Retorno apos processamento de gravacao
	Begin Sequence
		lRet := F272BGrv(cTipo,lMntGDSLT,aRegSLT)
		Recover
	End Sequence
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณProcessar a transferencia de caixa automatica, se necessario  ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If GetNewPar("MV_LJTRANS",.F.) .AND. (nModulo = 5 .Or. !lMvLjPdvPaf) 
 		If FindFunction("LjVerTrans")
 			LjVerTrans()
 		Endif
	Endif	
	
	If lErro
		If InTransact()
			DisarmTransaction()
		Endif
		Alert(cErro)
		lAtuSLW := .F.
		RestArea(aArea)
		Return !lRet
	Endif
	ErrorBlock(bErro)	
	If lRet
		//Caso o processo tenha sido finalizado com sucesso. Independentemente da rotina de chamada, o retorno sera o mesmo
		lAtuSLW := .F.
		ImpRelPad(lRet,lAcumDia,lLeitX,lReduZ,oHora,cHora,oDoc,cDoc)
		RestArea(aArea)
		Return lRet
	Else
		//Caso o processo tenha sofrido algum problema
		If nModoChama == 1
			lAtuSLW := .F.
			RestArea(aArea)
			Return !lRet
		Else
			//Tentar fazer o fechamento simplificado, senao cancelar operacao
			If LJProfile(25)
				Begin Sequence
					F272BGrvFS(lMntGDSLT,aRegSLT)
					Recover
				End Sequence
				If lErro
					If InTransact()
						DisarmTransaction()
					Endif				
					Alert(cErro)
					lAtuSLW := .F.
					RestArea(aArea)
					Return !lRet
				Endif
				ErrorBlock(bErro)				
				lAtuSLW := .F.
				RestArea(aArea)
				Return lRet	
			Else
				lAtuaSLW := .F.
				RestArea(aArea)
				Return !lRet
			Endif
		Endif	
	Endif
ElseIf nOpca == 2	//Cancelamento
	If nModoChama == 1 .AND. !lFechConf	//SIGALOJA
		//Cancelar operacao de fechamento de caixa
		lAtuaSLW := .F.
		RestArea(aArea)
		Return !lRet	
	ElseIf nModoChama == 2 .Or. lFechConf 	//SIGAFRT
		//Caso o usuario tenha permissao de fazer o fechamento simplificado, prosseguir.  Senao interromper a operacao de fechamento de caixa.
		If LJProfile(25)
			//Fechamento simplificado apenas para o fechamento a partir do SIGAFRT FRTA271, pois o SLW ainda nao foi fechado e deve ser controlado pela rotina
			Begin Sequence
				F272BGrvFS(lMntGDSLT,aRegSLT)
				Recover
			End Sequence
			If lErro
				If InTransact()
					DisarmTransaction()
				Endif				
				Alert(cErro)
				lAtuSLW := .F.
				RestArea(aArea)
				Return !lRet
			Endif
			ErrorBlock(bErro)			
			lAtuSLW := .F.
			RestArea(aArea)
			Return lRet
		Else
			//Cancelar operacao de fechamento de caixa
			lAtuaSLW := .F.
			RestArea(aArea)
			Return !lRet
		Endif
	Endif
Else
	RestArea(aArea)
	Return !lRet
Endif
RestArea(aArea)
//Ao retornar lAtuaSLW = .F., a rotina CX_ABRE_FECHA nao devera regravar o SLW, desenvolver tratamento para isso

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF272BGrv   บAutor  ณVendas Clientes       บ Data ณ  06/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gravar as conferencias efetuadas para um movimento บฑฑ
ฑฑบ          ณde fechamento de caixa.                                        บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F272BGrv(cTipo,lMntGDSLT,aRegSLT)

Local lRet				:= .T.								//Retorno da funcao
Local aDados			:= oGet01:aCols						//GetDados
Local cAgenC			:= PadR(".",nTamAgen)				//Codigo da agencia corrente
Local aDataHr			:= {}								//Array de data e hora da ECF
Local aAreaSLW			:= SLW->(GetArea())				//Area da SLW
Local dDataMov			:= Nil								//Data do movimento

Default lMntGDSLT		:= .F.
Default aRegSLT		:= {}

If cTipo # "F"
	Return !lRet
Endif 
//Caso exista, levantar data e hora da impressora ECF
aDataHr := LjDtHrECF(.T.)
CursorWait()
//Obter o cupom fiscal final do ECF
cCupomF := RetCupomF()
//Pesquisa caixa na moeda principal
dbSelectArea("SA6")
SA6->(dbSetOrder(1))
SA6->(dbSeek(xFilial("SA6") + PadR(aID[1][1],aID[1][2]) + cAgenC))
If !SA6->(Found())
	MsgAlert(cNomeUs + STR0034 + aID[1][1] + STR0035) //", o caixa "###" nใo pode ser encontrado, operacao de gravacao cancelada."
	Return !lRet
Endif
Begin Transaction
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicionar a SLW e gravar - Fechar movimento  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SLW")
SLW->(dbSetOrder(3))	//LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
SLW->(dbSeek(cChvFecha))
If !SLW->(Found())
	MsgAlert(cNomeUs + STR0036 + cNumMov + STR0037) //", o movimento "###" jแ foi fechado ou nใo pode ser encontrado!"
	Return !lRet
Endif
//Verificar se a estacao ja havia sido fechada anteriormente
If SLW->LW_TIPFECH == "1" .AND. nModoChama == 2
	lEstFechaAnt := .T.
Endif
dDataMov := SLW->LW_DTABERT
RecLock("SLW",.F.)
SLW->LW_TIPFECH		:= "2"	//Fechamento completo
SLW->LW_DTFECHA		:= aDataHr[1]
SLW->LW_HRFECHA		:= aDataHr[2]
//Voltar o campo de situacao de transmissao como pendente, para que os dados do fechamento completo sejam transmitidos a retaguarda, caso se esteja no FRT

If nModoChama == 1 .AND. !lFechConf 	//SIGALOJA
	SLW->LW_SITUA	:= "RX"
	//Se a gravacao for feita na retaguarda e o numero final do cupom fiscal jah estiver definido, nao regravar
	If Empty(SLW->LW_NUMFIM)
		SLW->LW_NUMFIM	:= cCupomF
	Endif
Else
	SLW->LW_SITUA	:= "00"
	SLW->LW_NUMFIM	:= cCupomF
Endif
//Caso o campo de controle de forma de exibicao esteja disponivel e a chamada tenha sido feita do front
If SLW->(FieldPos("LW_OPCEXIB")) > 0 .AND. nModoChama # 1
	If lDetADMF .AND. !lConfCega
		SLW->LW_OPCEXIB := "3"
	ElseIf !lConfCega
		SLW->LW_OPCEXIB := "1"
	ElseIf lDetADMF
		SLW->LW_OPCEXIB := "2"
	Else
		SLW->LW_OPCEXIB := "0"
	Endif
Endif
//Conferencia final
If SLW->(FieldPos("LW_CONFERE")) > 0
	Replace LW_CONFERE With "2"
Endif
MsUnlock()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravar a conferencia SLT  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !F272BGrvLT(aDados,dDataMov,.F.,aDataHr,aID,lMntGDSLT,aRegSLT)
	DisarmTransaction()
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso esteja no SIGAFRT, atualizar SLI para subida das ณ
//ณinformacoes a retaguarda.                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nModoChama == 2
	//Gravar na mensagem apenas a SLW, pois a SLT sera processada a partir dela
	/*
	Estrutura :
	[01] Tipo de gravacao - 1.SLW 2.SLW+SLT
	[02] Indice - Passar como caracter, tamanho 2 com zeros
	[03] Chave completa - LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
	*/
	//Usar a opcao ABANDONA, pois se o campo LI_MSG estiver preenchido, a chave que esta lah tem prioridade de subida
	FR271BGerSLI(aID[1][1],"FCH","2" + StrZero(SLW->(IndexOrd()),2) + cChvFecha,"ABANDONA",.T.,cNomeUs,aDataHr[1],aDataHr[2])
Endif
End Transaction
CursorArrow()
RestArea(aAreaSLW)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF272BGrvFS บAutor  ณVendas Clientes       บ Data ณ  08/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gravar o fechamento de caixa simplificado.         บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F272BGrvFS(lMntGDSLT,aRegSLT)

Local lRet				:= .T.					//Retorno
Local aAreaSLW			:= SLW->(GetArea())	//Area da SLW
Local aDataHr			:= {}					//Array com data e hora retornada da ECF
Local cCupomF			:= ""					//Numero final do cupom fiscal
Local aDados			:= oGet01:aCols			//GetDados
Local cAgenC			:= PadR(".",nTamAgen)	//Codigo da agencia corrente
Local dDataMov			:= Nil					//Data do movimento

Default lMntGDSLT		:= .F.
Default aRegSLT		:= {}

//Caso exista, levantar data e hora da impressora ECF
aDataHr := LjDtHrECF(.T.)
CursorWait()
//Obter o cupom fiscal final do ECF
cCupomF := RetCupomF()
//Pesquisa caixa na moeda principal
dbSelectArea("SA6")
SA6->(dbSetOrder(1))
SA6->(dbSeek(xFilial("SA6") + PadR(aID[1][1],aID[1][2]) + cAgenC))
If !SA6->(Found())
	MsgAlert(cNomeUs + STR0034 + aID[1][1] + STR0035) //", o caixa "###" nใo pode ser encontrado, operacao de gravacao cancelada."
	Return !lRet
Endif
//Gravar a SLW
dbSelectArea("SLW")
SLW->(dbSetOrder(3))	//LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
SLW->(dbSeek(cChvFecha))
If SLW->(Found())
	Begin Transaction
	//Verificar se este movimento jah nao foi fechado, caso nao tenha sido, fechar
	dDataMov := SLW->LW_DTABERT
	If Empty(SLW->LW_DTFECHA) .OR. SLW->LW_TIPFECH $ "1|2"
		RecLock("SLW",.F.)
		SLW->LW_TIPFECH		:= "1"	//Fechamento simplificado
		SLW->LW_DTFECHA		:= aDataHr[1]
		SLW->LW_HRFECHA		:= aDataHr[2]
		SLW->LW_NUMFIM		:= cCupomF
		//Voltar o campo de situacao de tranamissao como pendente, para que os dados do fechamento imcompleto sejam transmitidos a retaguarda, se no FRT
		If nModoChama == 1 .AND. !lFechConf
			SLW->LW_SITUA	:= "RX"
		Else
			SLW->LW_SITUA	:= "00"
		Endif
		If SLW->(FieldPos("LW_OPCEXIB")) > 0
			If lDetADMF .AND. !lConfCega
				SLW->LW_OPCEXIB := "3"
			ElseIf !lConfCega
				SLW->LW_OPCEXIB := "1"
			ElseIf lDetADMF
				SLW->LW_OPCEXIB := "2"
			Else
				SLW->LW_OPCEXIB := "0"
			Endif
		Endif		
		//Conferencia final
		If SLW->(FieldPos("LW_CONFERE")) > 0
			Replace LW_CONFERE With "2"
		Endif		
		MsUnlock()
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGravar a conferencia SLT mesmo sem conferencia ณ
	//ณpois sera com este espelho que a conferencia   ณ
	//ณsera feita na retaguarda. Isso servira para    ณ
	//ณapontar divergencias no momento da conferencia,ณ
	//ณevidenciando vendas pendentes de subida        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !F272BGrvLT(aDados,dDataMov,.T.,aDataHr,aID,lMntGDSLT,aRegSLT)
		DisarmTransaction()
	Endif
	//Gravar na mensagem apenas a SLW, pois a SLT sera processada a partir dela
	/*
	Estrutura :
	[01] Tipo de gravacao - 1.SLW 2.SLW+SLT
	[02] Indice - Passar como caracter, tamanho 2 com zeros
	[03] Chave completa - LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
	*/
	//Usar a opcao ABANDONA, pois se o campo LI_MSG estiver preenchido, a chave que esta lah tem prioridade de subida
	FR271BGerSLI(aID[1][1],"FCH","2" + StrZero(SLW->(IndexOrd()),2) + cChvFecha,"ABANDONA",.T.,cNomeUs,aDataHr[1],aDataHr[2])	
	End Transaction
Endif
CursorArrow()
RestArea(aAreaSLW)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaGD    บAutor  ณVendas Clientes       บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para preparar o grid de dados para lancamento das confe-บฑฑ
ฑฑบ          ณrencias de caixa.                                              บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoGD01 = Grid de dados                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaGD(oGD01,nTop,nLeft,nBottom,nRight,lMntGDSLT,aRegSLT)

Local lRet				:= .T.								//Retorno da funcao
Local aArea				:= GetArea()						//Retrato da workarea
Local aCab				:= {}								//Cabecalho
Local aDados			:= {}								//Dados
Local cLinOk			:= "AlwaysTrue()"					//Validacao de linha
Local cTudoOk			:= "AlwaysTrue()"					//Validacao de todas linhas
Local cFieldOk			:= "AlwaysTrue()"					//Validacao de campo
Local cDelOk			:= "AlwaysFalse()"					//Validacao de exclusao
Local cIniCpos			:= ""								//Inicializacao de campos
Local nLimLin			:= 100								//Limite de linhas para a GetDados
Local ni				:= 0								//Contador
Local nx				:= 0								//Contador
Local nCont				:= 0								//Contador
Local cChave			:= ""								//Chave de pesquisa
Local lQry				:= .F.								//Utilizar query
Local nValFP			:= 0								//Valor por forma de pagamento
Local nPos				:= 0								//Posicionador
Local nPos02			:= 0								//Posicionador
Local cQry				:= ""								//Instrucao SQL
Local cAlias			:= GetNextAlias()					//Alias para o resultado da consulta
Local cSimbC			:= SuperGetMV("MV_SIMB1",.F.,"")	//Moeda corrente
Local lMoedaEst			:= .F.								//Utiliza moeda estrangeira
Local aFPADM			:= {}								//Forma de pagamento das administradoras financeiras
Local aTMP				:= {}								//Array temporaria
Local lFiltraADMF		:= .F.								//Filtrar por administradora financeira
Local cTMP 				:= ""								//Temporaria
Local cValid			:= ""								//Validacao
Local cCodADM			:= ""								//Codigo administadora financeira
Local nTamCADM			:= TamSX3("AE_COD")[1]				//Tamanho do codigo da administradora financeira
Local aREG				:= {}								//Armazena a lista de registros da SLT que sao apresentadoa nas conf. feitas na retaguarda
Local aLstFPQ			:= {}								//Lista de controle de forma de pagto. + admin por orcamento, para evitar a soma de qtde. em venda parcelada
Local lSomaQtde			:= .T.								//Variavel de controle de soma das quantidades de vendas
Local cForma			:= ""								//Forma de Movimento (Sangria/Troco)
Local cDesForma			:= ""								//Descri็ใo da Forma de Movimento (Sangria/Troco)
Local cChaveSE5			:= ""								//Chave de compara็ใo do loop do SE5
Local nOpcConf			:= SuperGetmv("MV_LJOPCON",,2)		//1-Conferencia por forma e totalizador (Recebimentos/SANGRIA/SUPRIMENTEO); 2-Conferencia por forma de pagamento 
Local lFisNota			:= SuperGetMV("MV_FISNOTA",,.F.) .AND. !Empty(SuperGetMV("MV_LOJANF",,""))	//Verifica se esta configurado para emissao de NF
Local cSerNFis          := IIf(Len(aID) > 4,aID[5][1],aID[3] )
Local cNatTroc			:= LjMExeParam("MV_NATTROC")

Default lMntGDSLT		:= .F.
Default aRegSLT		:= {}

If !lDetADMF
	//Redefinir os posicionamentos
	POS_FP			:= 1
	POS_DESCFP		:= 2
	POS_QTDE		:= 3
	POS_MOEDA		:= 4
	POS_VALDIG		:= 5
	POS_VALAPU		:= 6
	POS_CODADM		:= 7
	POS_DESADM		:= 8
	//Definicao dos campos
	aCmp := {"LT_FORMPG","LT_DESFORM","LT_QTDE","LT_MOEDA","LT_VLRDIG"}
	If !lConfCega
		aAdd(aCmp,"LT_VLRAPU")
	Endif
Else
	//Redefinir os posicionamentos
	POS_FP			:= 1
	POS_DESCFP		:= 2
	POS_CODADM		:= 3
	POS_DESADM		:= 4
	POS_QTDE		:= 5
	POS_MOEDA		:= 6
	POS_VALDIG		:= 7
	POS_VALAPU		:= 8
    //Definicao dos campos
	aCmp := {"LT_FORMPG","LT_DESFORM","LT_ADMIFIN","AE_DESC","LT_QTDE","LT_MOEDA","LT_VLRDIG"}
	If !lConfCega
		aAdd(aCmp,"LT_VLRAPU")
	Endif    
Endif
aCmpAlter := {"LT_VLRDIG"}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinir uso de querys - somente para conexao online ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lOnline
	#IFDEF TOP
		lQry := .T.
	#ENDIF
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinir cabecalho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
For ni := 1 to Len(aCmp)
	SX3->(dbSeek(aCmp[ni]))
	If !SX3->(Found())
		MsgAlert(cNomeUs + STR0038 + AllTrim(aCmp[ni]) + STR0039) //", erro ao montar a lista de numerแrios! O campo "###" nao consta no dicionแrio de dados."
		RestArea(aArea)
		Return !lRet
	Endif
	//Personalizar a validacao dos campos de quantidade, valor digitado e valor apurado para atualizar o totalizador da tela
	Do Case
		Case aCmp[ni] == "LT_QTDE"
			cValid := "FR272BExTot({1})"	
		Case aCmp[ni] == "LT_VLRDIG"
			cValid := "FR272BExTot({2})"
		OtherWise
			cValid := SX3->X3_VALID
	EndCase
	aAdd(aCab,{SX3->X3_TITULO,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cValid,SX3->X3_USADO,IIf(ni == 4,"C",SX3->X3_TIPO),SX3->X3_F3,;
		SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	nCont++
Next ni
If !lMntGDSLT
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMontar array de formas de pagamento utilizadas pelas ณ
	//ณadministradoras financeiras                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lDetADMF
		dbSelectArea("SAE")
		SAE->(dbGoTop())
		Do While !SAE->(Eof())
			If aScan(aFPADM,{|x| x[1] == AllTrim(SAE->AE_TIPO) .AND. AllTrim(x[2]) == AllTrim(SAE->AE_COD)}) == 0
				aAdd(aFPADM,{AllTrim(SAE->AE_TIPO),SAE->AE_COD,SAE->AE_DESC})
			Endif
			SAE->(dbSkip())
		EndDo
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPesquisar formas de pagamento  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cChave := xFilial("SX5") + "24"
	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))
	SX5->(dbSeek(cChave))
	If SX5->(Found())
		Do While !SX5->(Eof()) .AND. RTrim(SX5->(X5_FILIAL + X5_TABELA)) == cChave
			aTMP := {}
			If !SX5->(Deleted())
				If !lDetADMF
					aAdd(aNumerario,{SX5->X5_CHAVE,SX5->X5_DESCRI,0,nMoedaC,0,0,"",""})
				Else
					//Levantar todos as adm financeiras associadas com esta forma de pagamento
					For ni := 1 to Len(aFPADM)
						If AllTrim(aFPADM[ni][1]) == AllTrim(SX5->X5_CHAVE)
							aAdd(aTMP,{aFPADM[ni][2],aFPADM[ni][3]})
						Endif
					Next ni
					//Listar todas as administradoras financeiras na lista de numerarios
					If Len(aTMP) == 0
						aAdd(aNumerario,{SX5->X5_CHAVE,SX5->X5_DESCRI,"","",0,nMoedaC,0,0})
					Else
						For ni := 1 to Len(aTMP)
							aAdd(aNumerario,{SX5->X5_CHAVE,SX5->X5_DESCRI,aTMP[ni][1],aTMP[ni][2],0,nMoedaC,0,0})
						Next ni
					Endif
				Endif
			Endif                                                         	
			SX5->(dbSkip())
		EndDo
	Else
		RestArea(aArea)
		Return !lRet
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso nao seja conferencia cega, levantar os valores apurados, senao apenas as quantidades  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lQry
		//VENDAS COM FORMA DE PAGAMENTO DEFINIDA
		cQry := "SELECT DISTINCT A.L1_FILIAL, A.L1_NUM, ('N') CANC, B.L4_FORMA, B.L4_ADMINIS, B.L4_MOEDA, "
		If lHabTroco
			cQry += "SUM(B.L4_VALOR) TOTAL "
		Else
			cQry += "SUM(B.L4_VALOR - B.L4_TROCO) TOTAL " 
		Endif
		cQry += "FROM " + RetSQLName("SL1") + " A INNER JOIN " + RetSQLName("SL4") + " B ON (A.L1_FILIAL = B.L4_FILIAL) AND (A.L1_NUM = B.L4_NUM) "
		cQry += "WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' "
		cQry += "AND A.L1_FILIAL = '" + xFilial("SL1") + "' "	
		cQry += "AND A.L1_EMISSAO = '" + DtoS(dDtMov) + "' "
		If SL1->(FieldPos("L1_STORC")) > 0
			cQry += "AND A.L1_STORC NOT IN ('C','E') "
		Endif
		cQry += "AND A.L1_SITUA <> '07' "
		cQry += "AND B.L4_ORIGEM = '' "
		cQry += "AND A.L1_OPERADO = '" + aID[1][1] + "' "
		
		If nModulo <> 5	 
			cQry += "AND ( A.L1_SERIE = '" + aID[3][1] + "' OR A.L1_SERPED = '" + cSerNFis + IIF(lFisNota, "' OR A.L1_SERIE = '" + SuperGetMV("MV_LOJANF",,"")  ,"") +  "' )"    
		EndIf
		
		cQry += "AND (A.L1_PDV = '" + aID[4][1] + IIF(lFisNota, "' OR A.L1_PDV = ' " ,"") + "' )"
		cQry += "AND A.L1_ESTACAO = '" + aID[2][1] + "' "
		cQry += "AND A.L1_NUMMOV = '" + AllTrim(cNumMov) + "' "
		cQry += "AND A.L1_ORCRES = '' "
		cQry += "GROUP BY A.L1_FILIAL, A.L1_NUM, B.L4_FORMA, B.L4_ADMINIS, B.L4_MOEDA "
		//VENDAS COM CREDITO
		cQry += "UNION ALL "
		cQry += "SELECT DISTINCT A.L1_FILIAL, A.L1_NUM, ('N') CANC, ('CR') L4_FORMA, ('') L4_ADMINIS, (" + RetMoeda(cSimbC,1,2,.F.) + ") L4_MOEDA, (A.L1_CREDITO) TOTAL  "
		cQry += "FROM " + RetSQLName("SL1") + " A "
		cQry += "WHERE A.D_E_L_E_T_ <> '*' "
		cQry += "AND A.L1_FILIAL = '" + xFilial("SL1") + "' "	
		cQry += "AND A.L1_EMISSAO = '" + DtoS(dDtMov) + "' "
		If SL1->(FieldPos("L1_STORC")) > 0
			cQry += "AND A.L1_STORC NOT IN ('C','E') "
		Endif
		cQry += "AND A.L1_SITUA <> '07' "
		cQry += "AND A.L1_OPERADO = '" + aID[1][1] + "' "
		
		If nModulo <> 5	 
			cQry += "AND A.L1_SERIE = '" + aID[3][1] + "' "
		EndIf
		
		cQry += "AND A.L1_PDV = '" + aID[4][1] + "' "
		cQry += "AND A.L1_ESTACAO = '" + aID[2][1] + "' "
		cQry += "AND A.L1_NUMMOV = '" + AllTrim(cNumMov) + "' "
		cQry += "AND A.L1_CREDITO > 0 "
		cQry += "AND A.L1_ORCRES = '' "
		cQry += "ORDER BY 1, 2 ASC" 
		dbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAlias,.T.,.F.)
		TcSetField(cAlias,"TOTAL","N",TamSX3("L4_VALOR")[1],TamSX3("L4_VALOR")[2])
		TcSetField(cAlias,"L4_MOEDA","N",TamSX3("L4_MOEDA")[1],0)
		(cAlias)->(dbGoTop())
		Do While !(cAlias)->(Eof())
			nValFP := (cAlias)->TOTAL
			cCodADM := Substr((cAlias)->L4_ADMINIS,1,nTamCADM)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerificar se a quantidade da venda jah nao foi registrada ณ
			//ณpela ORC + FP + ADM + MOEDA, se foi, nao somar.           ณ
			//ณIsso visa evitar que FP desdobradas aumentem a qtde. de   ณ
			//ณvenda por FP de acordo com o seu numero de parcelas.      ณ			
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If aScan(aLstFPQ,{|x| x[1] == AllTrim((cAlias)->L1_FILIAL) .AND. x[2] == AllTrim((cAlias)->L1_NUM) .AND. ;
				x[3] == AllTrim((cAlias)->L4_FORMA) .AND. x[4] == AllTrim(cCodADM) .AND. x[5] == AllTrim((cAlias)->L4_MOEDA)}) == 0
							
				aAdd(aLstFPQ,{AllTrim((cAlias)->L1_FILIAL),AllTrim((cAlias)->L1_NUM),AllTrim((cAlias)->L4_FORMA),AllTrim(cCodADM),AllTrim((cAlias)->L4_MOEDA)})
				lSomaQtde := .T.
			Else	
				lSomaQtde := .F.
			Endif
			//Verificar se o pagamento foi realizado em moeda estrangeira e necessita conversao
			If (cAlias)->L4_MOEDA > 1 .AND. cPaisLoc == "BRA"
				nValFP := xMoeda(nValFP,(cAlias)->L4_MOEDA,1,dDtMov)
			Endif
			lFiltraADMF := .F.
			cTMP := ""
			//Fazer o posicionamento na array
			If !lDetADMF
				nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim((cAlias)->L4_FORMA)})
			Else
				If !Empty(cCodADM)
					lFiltraADMF := .T.
					If (nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim((cAlias)->L4_FORMA) .AND. AllTrim(x[POS_CODADM]) == AllTrim(cCodADM)})) == 0 
						//Caso a administradora da forma de pagamento nao tenha sido encontrada, utilizar a pesquisa apenas por forma de pagamento
						nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim((cAlias)->L4_FORMA)})
					Endif
				Else
					nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim((cAlias)->L4_FORMA)})
				Endif
			Endif
			If nPos > 0
				If cPaisLoc <> "BRA"
					//Verificar se a moeda associada a forma de pagamento esta na array, caso nao esteja, incluir
					If (cAlias)->L4_MOEDA == 0 .OR. (cAlias)->L4_MOEDA == nMoedaC
						aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
						aNumerario[nPos][POS_VALAPU]	+= nValFP			
					Else
						//Aplicar um filtro para verificar a existencia da agencia (moeda) na forma de pagamento associada
						If lFiltraADMF
							//Filtro : Forma Pagto + Agencia + Adm Financeira
							If (nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim((cAlias)->L4_FORMA) .AND. x[POS_MOEDA] == ;
								(cAlias)->L4_MOEDA .AND. AllTrim(x[POS_CODADM]) == cCodADM})) == 0
								
								//Caso a administradora da forma de pagamento nao tenha sido encontrada, utilizar a pesquisa apenas por forma de pagamento e moeda
								nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim((cAlias)->L4_FORMA) .AND. x[POS_MOEDA] == (cAlias)->L4_MOEDA})
							Endif
						Else
							//Filtro : Forma Pagto + Agencia
							nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim((cAlias)->L4_FORMA) .AND. x[POS_MOEDA] == (cAlias)->L4_MOEDA})
						Endif
						If nPos02 == 0
							lMoedaEst := .T.
							If lDetADMF .AND. !Empty(cCodADM)
								cTMP := GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + RTrim(cCodADM),1)
							Endif
							If !lDetADMF
								aAdd(aNumerario,{(cAlias)->L4_FORMA,DescFP((cAlias)->L4_FORMA),0,(cAlias)->L4_MOEDA,0,0,cCodADM,cTMP})
							Else
								aAdd(aNumerario,{(cAlias)->L4_FORMA,DescFP((cAlias)->L4_FORMA),cCodADM,cTMP,0,(cAlias)->L4_MOEDA,0,0})
							Endif
							nPos := Len(aNumerario)
						Else
							nPos := nPos02
						Endif
						aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
						aNumerario[nPos][POS_VALAPU] 	+= nValFP				
					Endif
				Else
					aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
					aNumerario[nPos][POS_VALAPU] 	+= nValFP
				Endif
			Endif
			(cAlias)->(dbSkip())
		EndDo
	Else
		cChave := xFilial("SL1") + PadR(aID[1][1],aID[1][2]) + DtoS(dDtMov)
		dbSelectArea("SL1")
		SL1->(dbSetOrder(5))	//L1_FILIAL+L1_OPERADO+Dtos(L1_EMISSAO)
		SL1->(dbSeek(cChave))
		Do While !SL1->(Eof()) .AND. SL1->(L1_FILIAL + L1_OPERADO) + DtoS(L1_EMISSAO) == cChave
			If nModulo != 5 // Nao validar SERIE quando FAT  
				//Se o orcamento nao pertencer a SERIE em uso, saltar
				If !Empty(SL1->L1_SERIE) .And. AllTrim(SL1->L1_SERIE) # AllTrim(aID[3][1])
					SL1->(dbSkip())
					Loop				
				Endif  
			EndIf
			//Se o orcamento nao pertencer ao PDV e estacao em uso, saltar
			If AllTrim(SL1->L1_PDV) # AllTrim(aID[4][1]) .OR. AllTrim(SL1->L1_ESTACAO) # AllTrim(aID[2][1])
				SL1->(dbSkip())
				Loop				
			Endif
			//Se o orcamento estiver cancelado ou for de movimento diferente
			If SL1->L1_SITUA == "07" .OR. (!Empty(cNumMov) .AND. AllTrim(SL1->L1_NUMMOV) # AllTrim(cNumMov))
				SL1->(dbSkip())
				Loop			
			Endif
			If SL1->(ColumnPos("L1_STORC")) > 0
				If SL1->L1_STORC $ "C|E"
					SL1->(dbSkip())
					Loop			
				Endif
			Endif	

			If !Empty(SL1->L1_ORCRES) .And. SL1->L1_RESERVA == "S"
				SL1->(dbSkip())
				Loop
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe houver valor de credito (NCC), tratar  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SL1->L1_CREDITO > 0
				nValFP := SL1->L1_CREDITO
				If SL1->L1_MOEDA > 1 .AND. cPaisLoc == "BRA"
					nValFP := xMoeda(nValFP,SL1->L1_MOEDA,1,SL1->L1_EMISSAO)
				Endif
				If (nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == "CR"})) > 0
					If cPaisLoc # "BRA"
						//Caso o movimento esteja na moeda corrente, apenas totalizar
						If SL1->L1_MOEDA == 0 .OR. SL1->L1_MOEDA == nMoedaC
							aNumerario[nPos][POS_QTDE] 		+= 1
							aNumerario[nPos][POS_VALAPU] 	+= nValFP			
						Else
							//Verificar se a moeda associada a forma de pagamento esta na array, caso nao esteja, incluir
							//Aplicar um filtro para verificar a existencia da agencia (moeda) na forma de pagamento associada
							nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == "CR" .AND. x[POS_MOEDA] == SL1->L1_MOEDA})
							If nPos02 == 0						
								lMoedaEst := .T.
								aAdd(aNumerario,{"CR",DescFP("CR"),0,SL1->L1_MOEDA,0,0,cCodADM,cTMP})
								nPos := Len(aNumerario)
							Else
								nPos := nPos02
							Endif
							aNumerario[nPos][POS_QTDE] 		+= 1
							aNumerario[nPos][POS_VALAPU] 	+= nValFP
						Endif				
					Else
						aNumerario[nPos][POS_QTDE] 		+= 1
						aNumerario[nPos][POS_VALAPU] 	+= nValFP
					Endif
				Endif
			Endif
			//Procurar as formas de pagamento associadas
			nValFP := 0
			dbSelectArea("SL4")
			SL4->(dbSetOrder(1))
			SL4->(dbSeek(xFilial("SL4") + SL1->L1_NUM + Space(TamSX3("L4_ORIGEM")[1])))
			Do While !SL4->(Eof()) .AND. RTrim(SL4->(L4_FILIAL + L4_NUM)) == RTrim(xFilial("SL4") + SL1->L1_NUM) .AND. Empty(SL4->L4_ORIGEM)
				If lHabTroco
					nValFP := SL4->L4_VALOR
				Else
					nValFP := SL4->(L4_VALOR - L4_TROCO)
				Endif
				cCodADM := Substr(SL4->L4_ADMINIS,1,nTamCADM)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerificar se a quantidade da venda jah nao foi registrada ณ
				//ณpela ORC + FP + ADM + MOEDA, se foi, nao somar.           ณ
				//ณIsso visa evitar que FP desdobradas aumentem a qtde. de   ณ
				//ณvenda por FP de acordo com o seu numero de parcelas.      ณ				
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If aScan(aLstFPQ,{|x| x[1] == AllTrim(SL4->L4_FILIAL) .AND. x[2] == AllTrim(SL4->L4_NUM) .AND. ;
					x[3] == AllTrim(SL4->L4_FORMA) .AND. x[4] == AllTrim(cCodADM) .AND. x[5] == AllTrim(SL4->L4_MOEDA)}) == 0
								
					aAdd(aLstFPQ,{AllTrim(SL4->L4_FILIAL),AllTrim(SL4->L4_NUM),AllTrim(SL4->L4_FORMA),AllTrim(cCodADM),AllTrim(SL4->L4_MOEDA)})
					lSomaQtde := .T.
				Else
					lSomaQtde := .F.
				Endif
				//Verificar se o pagamento foi realizado em moeda estrangeira e necessita conversao
				If SL4->L4_MOEDA > 1 .AND. cPaisLoc == "BRA"
					nValFP := xMoeda(nValFP,SL4->L4_MOEDA,1,SL1->L1_EMISSAO)
				Endif
				lFiltraADMF := .F.
				cTMP := ""
				//Fazer o posicionamento na array
				If !lDetADMF
					nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA)})
				Else
					If !Empty(cCodADM)
						lFiltraADMF := .T.
						If (nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. AllTrim(x[POS_CODADM]) == AllTrim(cCodADM)})) == 0
							//Caso a adm financeira nao tenha sido encontrada, pesquisar apenas pela forma de pagamento
							nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA)})					
						Endif
					Else
						nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA)})
					Endif
				Endif
				If nPos > 0
					If cPaisLoc # "BRA"
						//Caso o movimento esteja na moeda corrente, apenas totalizar
						If SL4->L4_MOEDA == 0 .OR. SL4->L4_MOEDA == nMoedaC
							aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
							aNumerario[nPos][POS_VALAPU] 	+= nValFP			
						Else
							//Verificar se a moeda associada a forma de pagamento esta na array, caso nao esteja, incluir
							//Aplicar um filtro para verificar a existencia da agencia (moeda) na forma de pagamento associada
							If lFiltraADMF
								//Filtro : Forma Pagto + Agencia + Adm Financeira
								If (nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. x[POS_MOEDA] == SL4->L4_MOEDA .AND. ;
									AllTrim(x[POS_CODADM]) == AllTrim(cCodADM)})) == 0
									
									//Caso a adm financeira nao tenha sido encontrada, pesquisa apenas pela forma de pagamento e moeda
									nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. x[POS_MOEDA] == SL4->L4_MOEDA})
								Endif
							Else
								//Filtro : Forma Pagto + Agencia
								nPos02 := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(SL4->L4_FORMA) .AND. x[POS_MOEDA] == SL4->L4_MOEDA})
							Endif
							If nPos02 == 0						
								lMoedaEst := .T.
								If lDetADMF .AND. !Empty(cCodADM)
									cTMP := GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + RTrim(cCodADM),1)
								Endif
								If !lDetADMF
									aAdd(aNumerario,{SL4->L4_FORMA,DescFP(SL4->L4_FORMA),0,SL4->L4_MOEDA,0,0,cCodADM,cTMP})
								Else
									aAdd(aNumerario,{SL4->L4_FORMA,DescFP(SL4->L4_FORMA),cCodADM,cTMP,0,SL4->L4_MOEDA,0,0})
								Endif
								nPos := Len(aNumerario)
							Else
								nPos := nPos02
							Endif
							aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
							aNumerario[nPos][POS_VALAPU] 	+= nValFP
						Endif				
					Else
						aNumerario[nPos][POS_QTDE] 		+= IIf(lSomaQtde,1,0)
						aNumerario[nPos][POS_VALAPU] 	+= nValFP
					Endif
				Endif
				SL4->(dbSkip())
			EndDo
			SL1->(dbSkip())
		EndDo
	Endif
	
	//Registra os movimentos efetuados no caixa como Sangrias e entrada de troco:
	cChaveSE5 := xFilial("SE5")+DtoS(dDtMov)+aID[1][1]
	DbSelectArea("SE5")
	SE5->(DbSetOrder(1)) //E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
	If SE5->( DbSeek( cChaveSE5 ) )
		While !SE5->(EOF()) .And. cChaveSE5 == SE5->(E5_FILIAL+DTOS(E5_DATA)+E5_BANCO)

			If AllTrim(SE5->E5_NUMMOV) == AllTrim(cNumMov)
				cForma		:= ""
				cDesForma	:= ""
				nValFP		:= SE5->E5_VALOR

				If AllTrim(SE5->E5_TIPODOC) == "TR" .And. Upper(AllTrim(SE5->E5_MOEDA)) == "TC" .And. (Upper(AllTrim(SE5->E5_NATUREZ)) == "TROCO"  .Or. cNatTroc $ Upper(AllTrim(SE5->E5_NATUREZ)))  //Troco
					If nOpcConf == 2
						cForma		:= iIf(Empty(cSimbC),"R$",AllTrim(cSimbC))
						cDesForma	:= DescFP(AllTrim(cForma))
					Else
						cForma	  := "TC"
					EndIf
					cDesForma := iIf(!Empty(cDesForma), cDesForma, STR0068) //"ENTRADA DE TROCO"

				ElseIf AllTrim(SE5->E5_TIPODOC) == "TR" .And. Upper(AllTrim(SE5->E5_NATUREZ)) == "SANGRIA" //Sangria
					If nOpcConf == 2
						cForma		:= AllTrim(SE5->E5_MOEDA)
						cDesForma	:= DescFP(AllTrim(cForma))
						nValFP		:= nValFP * -1 	// Transforma o valor em negativo para subtrair o valor e a quantidade
					Else
						cForma	  := "SG"
					EndIf
					cDesForma := iIf(!Empty(cDesForma), cDesForma, STR0069) //"SANGRIA"

				ElseIf AllTrim(SE5->E5_TIPODOC) == "VL" .And. ( AllTrim(SE5->E5_TIPO) == "FI" .And. Upper(AllTrim(SE5->E5_NATUREZ)) $ LjMExeParam("MV_NATRECE",.F.,"RECEBIMENT") + "|" + SuperGetMv("MV_NATFIN",.F.,"FINAN")) 	//Recebimentos
					If nOpcConf == 2
						cForma		:= AllTrim(SE5->E5_MOEDA)
						cDesForma	:= DescFP(AllTrim(cForma))						
					Else
						cForma	  := "REC"
						cDesForma := STR0070 //"RECEBIMENTOS"
					EndIf
				ElseIf AllTrim(SE5->E5_TIPODOC) == "ES" .AND. ( AllTrim(SE5->E5_TIPO) == "FI" .AND. Upper(AllTrim(SE5->E5_NATUREZ)) $ LjMExeParam("MV_NATRECE",.F.,"RECEBIMENT") + "|" + SuperGetMv("MV_NATFIN",.F.,"FINAN")) 	//Estornos
					If nOpcConf == 2
						cForma		:= AllTrim(SE5->E5_MOEDA)
						cDesForma	:= DescFP(AllTrim(cForma))
					Else
						cForma	  	:= "REC"
						cDesForma 	:= STR0070 		//"RECEBIMENTOS"					
					EndIf
					nValFP		:= nValFP * -1 	// Transforma o valor em negativo para subtrair do valor do recebimento e da quantidade

				ElseIf Upper(AllTrim(SE5->E5_HISTOR)) == Upper(AllTrim("CORRESPONDENTE BANCARIO"))  .Or. (Upper(AllTrim(SE5->E5_NATUREZ)) == Upper(AllTrim(SuperGetMv("MV_NATCB",,""))) .Or. Upper(AllTrim(SE5->E5_NATUREZ)) == SuperGetMV("MV_NATTEF") )
					cForma	  := "CB"
					cDesForma := STR0071 //"CORRESPONDENTES BANCARIOS"

				ElseIf Upper(AllTrim(SE5->E5_HISTOR)) == Upper(AllTrim("RECARGA DE CELULAR"))
					cForma	  := "RCE"
					cDesForma := STR0072 //"RECARGA DE CELULAR"
				EndIf

				If !Empty(cForma) .And. !Empty(cDesForma)
					If (nPos := aScan(aNumerario,{|x| AllTrim(x[POS_FP]) == AllTrim(cForma)}) ) > 0
						aNumerario[nPos][POS_QTDE] 		+= IIf( lSomaQtde, IIf(nValFP < 0,-1,1), 0 )
						aNumerario[nPos][POS_VALAPU]	+= nValFP
					Else 
						If !lDetADMF
							aAdd(aNumerario,{cForma,cDesForma,0,1,0,0,"",""})
						Else
							aAdd(aNumerario,{cForma,cDesForma,"","",0,1,0,0})
						Endif
						aNumerario[Len(aNumerario)][POS_QTDE]	:= IIf(lSomaQtde,1,0)
						aNumerario[Len(aNumerario)][POS_VALAPU]	:= nValFP
					Endif
				Endif
			EndIf
			SE5->(DBSkip())
		EndDo
	EndIf
	RestArea(aArea)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณOrdenar a sequencia por forma de PG e moeda   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMoedaEst .AND. !lDetADMF
		aNumerario := aSort(aNumerario,,,{|x,y| (x[POS_FP] + x[POS_MOEDA]) < (y[POS_FP] + y[POS_MOEDA])})
	ElseIf !lMoedaEst .AND. lDetADMF
		aNumerario := aSort(aNumerario,,,{|x,y| (x[POS_FP] + x[POS_CODADM]) < (y[POS_FP] + y[POS_CODADM])})
	ElseIf lMoedaEst .AND. lDetADMF
		aNumerario := aSort(aNumerario,,,{|x,y| (x[POS_FP] + x[POS_MOEDA] + x[POS_CODADM]) < (y[POS_FP] + y[POS_MOEDA] + y[POS_CODADM])})
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializar os campos  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For ni := 1 to Len(aNumerario)
		aAdd(aDados,Array(Len(aCmp) + 1))
		nPos := Len(aDados)
		For nx := 1 to Len(aCmp)
			If nx == POS_MOEDA
				If aNumerario[nPos][nx] == 0 .OR. aNumerario[nPos][nx] == 1
					aDados[nPos][nx] := cSimbC
				Else
					aDados[nPos][nx] := SuperGetMV(AllTrim("MV_SIMB" + cValToChar(aNumerario[nPos][nx])),.F.,"")
				Endif
			Else
				aDados[nPos][nx] := aNumerario[ni][nx]
			Endif
		Next nx
		aDados[nPos][nx] := .F.
	Next ni
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLevantar registros do movimento + operador + estacao + PDV  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aREG := LjExConf({aID[1][1],aID[2][1],aID[3][1],aID[4][1]},dDtMov,dDtFMov,cNumMov,.T.,.T.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณClassificar por forma de pagamento para apresentar os dados ณ
	//ณutilizando os registros selecionados na pesquisa anterior   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If Len(aREG) > 0
		//Alimentar array com a lista de registros a ser apagado na confirmacao 
		aRegSLT := aClone(aREG)
		//Montar pesquisa		
		cChave := xFilial("SLT") + PadR(aID[1][1],aID[1][2]) + DtoS(dDtFMov)
		SLT->(dbSetOrder(1)) //LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG
		SLT->(dbSeek(cChave))
		Do While !SLT->(Eof()) .AND. (SLT->(LT_FILIAL + LT_OPERADO) + DtoS(LT_DTFECHA)) == cChave
			If aScan(aREG,{|x| x == SLT->(Recno())}) == 0
				SLT->(dbSkip())
				Loop
			Endif
			aAdd(aDados,Array(Len(aCmp) + 1))
			nPos := Len(aDados)
			For nx := 1 to Len(aCmp)
				If nx == POS_MOEDA
					If SLT->&(aCmp[nx]) == 1
						aDados[nPos][nx] := cSimbC
					Else
						aDados[nPos][nx] := SuperGetMV(AllTrim("MV_SIMB" + cValToChar(SLT->&(aCmp[nx]))),.F.,"")
					Endif
				ElseIf nx == POS_DESCFP
					If SLT->(FieldPos("LT_DESFORM")) == 0 .OR. X3NaoUsa("LT_DESFORM",.F.,.T.)
						aDados[nPos][nx] := DescFP(SLT->&(aCmp[POS_FP]))
					Else
						aDados[nPos][nx] := SLT->&(aCmp[nx])
					Endif
				ElseIf nx == POS_DESADM .AND. lDetADMF
					aDados[nPos][nx] := iIf(!Empty(SLT->&(aCmp[POS_CODADM])), GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + RTrim(SLT->&(aCmp[POS_CODADM])),1), "")
				Else
					aDados[nPos][nx] := SLT->&(aCmp[nx])
				Endif
			Next nx
			aDados[nPos][nx] := .F.
			SLT->(dbSkip())
		EndDo
	Endif
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar a GetDados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGD01 := MsNewGetDados():New(nTop,nLeft,nBottom,nRight,GD_UPDATE,cLinOk,cTudoOk,cIniCpos,aCmpAlter,1,nLimLin,cFieldOk,"",cDelOk,oTela,aCab,aDados)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcular os totalizadores em tela  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FR272BExTot(IIf(lConfCega,{1,2},{1,2,3}))
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLjUltMovAb บAutor  ณVendas Clientes       บ Data ณ  30/08/10      บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar a chave do primeiro movimento pend.fechamentoบฑฑ
ฑฑบ          ณencontrado no controle de movimento de abertura e fecha. de caixa.บฑฑ
ฑฑบ          ณOrdem de retorno : 03                                             บฑฑ
ฑฑบ          ณLW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] - 1. Pesq. da chave com informacao completa              บฑฑ
ฑฑบ          ณ           2. Pesq. da chave apenas com operador e os opcionais   บฑฑ
ฑฑบ          ณExp02[C] - Operador (caixa)                                       บฑฑ
ฑฑบ          ณExp03[C] - PDV                                                    บฑฑ
ฑฑบ          ณExp04[C] - Estacao                                                บฑฑ
ฑฑบ          ณExp05[C] - Numero do movimento (SLW)                              บฑฑ
ฑฑบ          ณExp06[L] - Considerar movimentos do loja?                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LjUltMovAb(nOpc,cOper,cPDV,cEstacao,cNumMov,lConsMLJ,cOperAbrFEc)

Local cChave		:= ""						//Chave
Local cQry			:= ""						//Instrucao SQL
Local aOk			:= {{3,.F.},{6,.F.}}		//Controle
Local cAlias		:= GetNextAlias()			//Alias temporario
Local cTab			:= "SLW"					//Tabela a ser processada
Local nPos			:= 0						//Posicionamento
Local aEstru		:= {}						//Estrutura de tabela
Local cArqInd		:= ""						//Arquivo para o indice temporario
Local cIndice		:= ""						//Campos do indice
Local cFiltro		:= ""						//Filtro do novo indice
Local nIndice		:= 0						//Sequencia dos indices
Local lJob			:= Select("SX6") == 0		//Execucao por job
Local aAreaSLW		:= IIf(!lJob,SLW->(GetArea()),GetArea())	//Area SLW
Local nIndAnt		:= IIf(!lJob,SLW->(IndexOrd()),1)			//Indice atual
#IFDEF TOP
Local cSGBD			:= Upper(AllTrim(TcGetDB()))		//Banco de dados utilizado
#ENDIF
Local lObgCon		:= SuperGetMV("MV_LJOBGCF",,.T.)	//indica se a Conferencia de Caixa eh obrigatoria

Default nOpc		:= 0
Default cOper		:= ""
Default cPDV		:= ""
Default cEstacao	:= ""
Default cNumMov	:= ""
Default lConsMLJ	:= .T.
Default cOperAbrFEc	:= ""

If lJob
	dbSelectArea("SLW")
	SLW->(dbSetOrder(1))
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao for para considerar os movimentos da SLW originados  ณ
//ณdo SIGALOJA, o campo LW_ORIGEM deve existir, pois           ณ
//ณsera utilizado na pesquisa.                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lConsMLJ
	If SLW->(FieldPos("LW_ORIGEM")) == 0
		lConsMLJ := !lConsMLJ
	Endif
Endif

//Validar se existe o indice 03 e 06, incluidos no pacote de atualizacao UpdLoja58
DbSelectArea("SIX")
SIX->( DbSetOrder(1) )
SIX->( DbSeek(cTab) )

If SIX->( Found() )
	Do While !SIX->(Eof()) .AND. SIX->INDICE == cTab
		If (nPos := aScan(aOk,{|x| x[1] == Val(SIX->ORDEM)})) > 0
			aOk[nPos][2] := .T.
		Endif
		SIX->( DbSkip() )
	EndDo
Else
	Return cChave
Endif

If !aOk[1][2] .OR. !aOk[2][2]
	Return cChave
Endif

//Determinando a estrutura
dbSelectArea(cTab)
aEstru := (cTab)->(dbStruct())

//Formatar variaveis
cOper 		:= PadR(cOper		,TamSX3("LW_OPERADO")[1])
cPDV		:= PadR(cPDV		,TamSX3("LW_PDV")[1])
cEstacao	:= PadR(cEstacao	,TamSX3("LW_ESTACAO")[1])
cNumMov		:= PadR(cNumMov		,TamSX3("LW_NUMMOV")[1])

Do Case

	//Pesquisa completa - busca dados da abertura vigente, em processo de fechamento
	Case nOpc == 1
		
		If Empty(cOper) .OR. Empty(cPDV) .OR. Empty(cEstacao) .OR. Empty(cNumMov)
			Return cChave
		Endif
		
		#IFDEF TOP
			cQry := "SELECT DISTINCT LW_FILIAL, LW_PDV, LW_OPERADO, LW_DTABERT, LW_NUMMOV, LW_ESTACAO, LW_DTFECHA, LW_TIPFECH "
			cQry += "FROM " + RetSQLName(cTab) + " "
			cQry += "WHERE D_E_L_E_T_ <> '*' "
			cQry += "AND LW_FILIAL = '" + xFilial(cTab) + "' "
			cQry += "AND LW_TIPFECH NOT IN ('2','3','4','5','6') " //Se o fechamento relizado nao for completo ou nao foi feito fechamento
			cQry += "AND LW_OPERADO = '" + RTrim(cOper) + "' "
			cQry += "AND LW_PDV = '" + RTrim(cPDV) + "' "
			cQry += "AND LW_ESTACAO = '" + RTrim(cEstacao) + "' "
			cQry += "AND LW_NUMMOV = '" + RTrim(cNumMov) + "' "

			If !lConsMLJ .AND. nModulo <> 12
				cQry += "AND LW_ORIGEM <> 'LOJ' "
			EndIf

			cQry += "ORDER BY LW_DTABERT ASC"
		#ELSE
			cArqInd := CriaTrab(,.F.)
			cIndice	:= "LW_FILIAL+DTOS(LW_DTFECHA)+LW_TIPFECH+LW_OPERADO+LW_PDV+LW_ESTACAO+LW_NUMMOV"
			cFiltro := "LW_FILIAL = '" + xFilial(cTab) + "' .AND. "
			cFiltro += "!LW_TIPFECH $ '2|3|4|5|6' .AND. "
			cFiltro	+= "LW_OPERADO = '" + RTrim(cOper) + "' .AND. "
			cFiltro	+= "LW_PDV = '" + RTrim(cPDV) + "' .AND. " 
			cFiltro	+= "LW_ESTACAO = '" + RTrim(cEstacao) + "' .AND. "
			cFiltro	+= "LW_NUMMOV = '" + RTrim(cNumMov) + "' "
			
			If !lConsMLJ .AND. nModulo <> 12
				cFiltro += ".AND. LW_ORIGEM <> 'LOJ' "
			EndIf
		#ENDIF

	//Pesquisa incompleta - busca movimentos jah fechados, por simplificados
	Case nOpc == 2

		If Empty(cOper)
			Return cChave
		EndIf

		#IFDEF TOP

			cQry := "SELECT DISTINCT LW_FILIAL, LW_PDV, LW_OPERADO, LW_DTABERT, LW_NUMMOV, LW_ESTACAO, LW_DTFECHA, LW_TIPFECH "
			cQry += "FROM " + RetSQLName(cTab) + " "
			cQry += "WHERE D_E_L_E_T_ <> '*' "
			cQry += "AND LW_FILIAL = '" + xFilial(cTab) + "' "
			cQry += "AND LW_TIPFECH NOT IN ('2','3','4','5','6') "  //Fechamento simplificado ou sem fechamento
			If !Empty(cOperAbrFec)
				cQry += "AND ( LW_OPERADO = '" + RTrim(cOper) + "' OR LW_OPERADO = '" + RTrim(cOperAbrFEc) + "' ) "
			Else
				cQry += "AND LW_OPERADO = '" + RTrim(cOper) + "' "
			EndIf

			If !Empty(cPDV)
				cQry += "AND LW_PDV = '" + RTrim(cPDV) + "' "
			Endif
			If !Empty(cEstacao)
				cQry += "AND LW_ESTACAO = '" + RTrim(cEstacao) + "' "
			Else
				//O campo LW_ESTACAO vazio caracteriza registros anteriores ao update, desconsiderar
				Do Case
					Case cSGBD $ "MSSQL|SYBASE"
						cQry += "AND (LEN(LW_ESTACAO) > 0) "
					Case cSGBD $ "ORACLE|MYSQL|POSTGRES|INFORMIX"
						cQry += "AND (LENGTH(LW_ESTACAO) > 0) "
					Case cSGBD $ "DB2|DB2/400"
						cQry += "AND (LENGTH(TRIM(LW_ESTACAO)) > 0) "
					OtherWise
						cQry += "AND (LEN(LW_ESTACAO) > 0) "
				EndCase			
			Endif
			
			//Se LW_TIPFECH = 1 E LW_DTFECHA vazio, significa que ha um movimento pendente
			If !lObgCon .AND. !((nModulo == 12 .AND. !lMvLjPdvPaf) .OR. ( nModulo == 05 .AND. !isBlind() ))
			//nao obriga conferencia E NAO SIGALOJA ONLINE OU SIGAFAT ONLINE
				Do Case
					Case cSGBD $ "MSSQL|SYBASE"
						cQry += "AND (LEN(LW_DTFECHA) = 0) "
					Case cSGBD $ "ORACLE|MYSQL|POSTGRES|INFORMIX"
						cQry += "AND (LENGTH(LW_DTFECHA) = 0) "
					Case cSGBD $ "DB2|DB2/400"
						cQry += "AND (LENGTH(TRIM(LW_DTFECHA)) = 0) "
					OtherWise
						cQry += "AND (LEN(LW_DTFECHA) = 0) "
				EndCase
			EndIf

			If !Empty(cNumMov)
				cQry += "AND LW_NUMMOV = '" + RTrim(cNumMov) + "' "
			Endif
			
			If !lConsMLJ .AND. nModulo <> 12			
				cQry += "AND LW_ORIGEM <> 'LOJ' "
			Endif
			
			cQry += "ORDER BY LW_DTABERT ASC"
		#ELSE

			cArqInd := CriaTrab(,.F.)
			cIndice	:= "LW_FILIAL+DTOS(LW_DTFECHA)+LW_TIPFECH+LW_OPERADO+LW_PDV+LW_ESTACAO+LW_NUMMOV"
			cFiltro := "LW_FILIAL = '" + xFilial(cTab) + "' "
			cFiltro += ".AND. !LW_TIPFECH $ '2|3|4|5|6' "
			cFiltro	+= ".AND. LW_OPERADO = '" + RTrim(cOper) + "' "
			If !Empty(cPDV)
				cFiltro	+= ".AND. LW_PDV = '" + RTrim(cPDV) + "' " 
			Endif
			
			If !Empty(cEstacao)
				cFiltro	+= ".AND. LW_ESTACAO = '" + RTrim(cEstacao) + "' "
			Else
				//O campo LW_ESTACAO vazio caracteriza registros anteriores ao update, desconsiderar
				cFiltro += ".AND. !Empty(LW_ESTACAO) "
			Endif
			
			//Se LW_TIPFECH = 1 E LW_DTFECHA vazio, significa que ha um movimento pendente
			If !lObgCon .AND. !((nModulo == 12 .AND. !lMvLjPdvPaf) .OR. ( nModulo == 05 .AND. !isBlind() ))
			//nao obriga conferencia E NAO SIGALOJA ONLINE OU SIGAFAT ONLINE
				cFiltro += ".AND. Empty(LW_DTFECHA) "
			EndIf

			If !Empty(cNumMov)
				cFiltro	+= ".AND. LW_NUMMOV = '" + RTrim(cNumMov) + "' "
			Endif

			If !lConsMLJ .AND. nModulo <> 12
				cFiltro += ".AND. LW_ORIGEM <> 'LOJ' "
			Endif
		#ENDIF

	OtherWise
		Return cChave
EndCase

#IFDEF TOP
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImportante : por utilizar fun็ใo build in de SGBD, nao aplicar o PARSER.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAlias,.T.,.F.)
	(cAlias)->(dbGoTop())
	
	If !(cAlias)->(Eof())
		AjustaTC(cAlias,aEstru)
		Do While !(cAlias)->(Eof())
			//Se o tipo de fechamento nao for simplificado ou completo, e a data de fechamento nao estiver em branco, desconsiderar
			If !(cAlias)->LW_TIPFECH $ "1|2" .AND. !Empty((cAlias)->LW_DTFECHA)
				(cAlias)->(dbSkip())
				Loop
			Endif
			//Indice SLW(03) = LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
			cChave := (cAlias)->(LW_FILIAL + LW_PDV + LW_OPERADO + DtoS(LW_DTABERT) + LW_ESTACAO + LW_NUMMOV)
			Exit
		EndDo
	EndIf
	FechaArqT(cAlias)
#ELSE
	IndRegua("SLW",cArqInd,cIndice,,cFiltro,"")
	dbSelectArea("SLW")
	nIndice := RetIndex("SLW")
	SLW->(dbSetIndex(cArqInd + OrdBagExt()))
	SLW->(dbSetOrder(nIndice + 1))
	SLW->(dbGoTop())
	Do While !SLW->(Eof())
		//Se o tipo de fechamento nao for simplificado ou completo, e a data de fechamento nao estiver em branco, desconsiderar
		If !SLW->LW_TIPFECH $ "1|2" .AND. !Empty(SLW->LW_DTFECHA)
			SLW->(dbSkip())
			Loop
		Endif
		//Indice SLW(03) = LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
		cChave := SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + DtoS(LW_DTABERT) + LW_ESTACAO + LW_NUMMOV)
		Exit
	EndDo
	//Retornar ao indice anterior e eliminar o arquivo de indice
	dbSelectArea("SLW")
	RetIndex("SLW")			
	SLW->(dbSetOrder(nIndAnt))
	If File(cArqInd + OrdBagExt())
		fErase(cArqInd + OrdBagExt())
	Endif		
#ENDIF

If !lJob
	RestArea(aAreaSLW)
Endif

Return cChave

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaTC  บAutor  ณVendas Clientes       บ Data ณ  22/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAlterar o tipo de dados de campos criados por querys de acordoบฑฑ
ฑฑบ          ณcom o seu tipo de dados declarado no dicionario.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#IFDEF TOP
Static Function AjustaTC(cAlias,aEstru)

Local ni		:= 0		//Contador
Local nPos		:= 0		//Posicionador

If Empty(cAlias) .OR. ValType(aEstru) # "A" .OR. Len(aEstru) == 0
	Return Nil
Endif
For ni := 1 to (cAlias)->(FCount())
	If (nPos := aScan(aEstru,{|x| AllTrim(x[1]) == AllTrim((cAlias)->(FieldName(ni)))})) # 0
		If aEstru[nPos][2] # "C"
			TcSetField(cAlias,aEstru[nPos][1],aEstru[nPos][2],aEstru[nPos][3],aEstru[nPos][4])
		Endif
	Endif
Next ni

Return Nil
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpConf 	บAutor  ณVendas Clientes       บ Data ณ  03/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao da conferencia                                      บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpConf(cCaixa,cEstacao,cPDV,dDataAb,cHrAb,dDataF,cHrF)

Local oFrm											//Objeto para classe FrmtLay
Local ni			:= 0							//Contador
Local nx			:= 0							//Contador
Local aTMP			:= {}							//Array temporario
Local aCab			:= oGet01:aHeader				//Header da GetDados
Local aDados		:= oGet01:aCols					//Dados da GetDados
Local lAjLarg		:= .F.							//Ajustar largura automaticamente
Local lImpECF		:= .F.							//Imprimir em ECF
Local aLstPNI		:= {"POS_CODADM","POS_DESADM"}	//Lista de posicoes que nao devem ser impressas caso esteja sendo utilizadas
Local aCols			:= {}							//Lista das colunas que devem ser impressas
Local aColsLarg		:= {}							//Largura das colunas para impressao em ECF
Local aAliDif		:= {{"POS_MOEDA","C"},{"POS_VALDIG","R"},{	"POS_VALAPU","R"}}	//Lista de posicoes que possuem alinhamento diferenciado
Local aAlinha		:= {}							//Controle de alinhamento
Local lOk			:= .T.							//Controle de processamento
Local nPos			:= 0							//Posicionador
Local nRet			:= 0							//Retorno
Local lCSV			:= .F.							//Gerar arquivo CSV
Local lFLDispo		:= FindFunction("LOJA0053")		//Classe FrmtLay disponivel?
Local nCols			:= IIf(!Empty(LJGetStation("LG_LARGCOL")),LJGetStation("LG_LARGCOL"),40)
Local aFrt272bAss	:= {}

If !lFLDispo
	Return .T.
Endif
If lFiscal .AND. lImpFiscal
	lImpECF := .T.
ElseIf cValToChar(nModoChama) $ "1|2"
	lImpECF := .F.
Else
	MsgAlert(cNomeUs + STR0066) //", op็ใo invแlida!"
	Return .T.
Endif
//Se o terminal possui impressora fiscal e a chamada foi feita a partir do LOJA
If lImpECF .AND. nModoChama == 1
	nRet := AbTelaOpc()
	Do Case
		Case nRet == 0
			//Cancelar
			Return .T.
		Case nRet == 2
			//Caso a impressora selecionada nao seja a ECF, negar a variavel de impressao em ECF para forcar a impressao do rel em R4
			lImpECF := !lImpECF
		Case nRet == 3
			lImpECF := !lImpECF
			lCSV	:= !lCSV
	EndCase
Endif
//Caso seja impressao em ECF e conferencia cega, marcar tambem o campo de valor apurado para nao ser impresso
If lConfCega
	aAdd(aLstPNI,"POS_VALAPU")
	If lImpECF
		//Definir largura das colunas para impressao ECF
		aColsLarg := {11,33,12,10,34}
	Endif
ElseIf lImpECF
	//Definir largura das colunas para impressao ECF
	aColsLarg := {10,24,10,08,24,24}	
Endif
//Caso o leiaute a ser utilizado nao seja para ECF, definir que todos os campos devem ser impressos
If !lImpECF
	aLstPNI := {}
Endif
//Varrer o cabecalho para determinar quais campos serao impressos, montar o cabecalho do relatorio e montar o alinhamento das colunas
For ni := 1 to Len(aCab)
	lOk := .T.
	If Len(aLstPNI) > 0
		//Verificando se a posicao atual devera ser impressa
		For nx := 1 to Len(aLstPNI)
			If ni == &(aLstPNI[nx])
				lOk := .F.
				Exit
			Endif
		Next nx
		If !lOk
			Loop
		Endif
	Endif
	//Definir a coluna como utilizada
	aAdd(aCols,ni)
	//Agregar ao cabecalho
	aAdd(aTMP,aCab[ni][1])
	//Verificando se a posicao possui um alinhamento diferenciado
	For nx := 1 to Len(aAliDif)
		If ni == &(aAliDif[nx][1])
			nPos := nx
			Exit
		Endif
	Next nx	
	If nPos > 0
		aAdd(aAlinha,aAliDif[nPos][2])
	Else
		aAdd(aAlinha,"L")
	Endif
Next ni
If !lImpECF .AND. !lCSV
	oFrm := LJCFrmtLay():New(2,,.F.,,,,,"L")		//R4
ElseIf lImpECF .AND. !lCSV
	oFrm := LJCFrmtLay():New(4,nCols,.T.)	//ECF
Else
	oFrm := LJCFrmtLay():New(3,,.T.)		//CSV
Endif
oFrm:AddStruct(2,Len(aCols),.T.,.T.,aColsLarg,aAlinha,aTMP)
//Imprimir dados do caixa e fechamento
oFrm:PrintText(STR0040 + cCaixa) //"Caixa : "
oFrm:PrintText(STR0041 + cEstacao) //"Esta็ใo : "
oFrm:PrintText(STR0042 + cPDV) //"PDV : "
oFrm:PrintText(STR0043 + dDataAb + " - " + cHrAb) //"Abertura : "
oFrm:PrintText(STR0044 + dDataF + " - " + cHrF) //"Fechamento : "
If !lImpECF
	oFrm:PrintBlank()
	oFrm:PrintLine()
Else
	oFrm:PrintLineWD()
Endif
//Imprimir formas de pagamento
For ni := 1 to Len(aDados)
	If aTail(aDados[ni])
		Loop
	Endif
	aTMP := {}
	For nx := 1 to Len(aCmp)
		//Caso a coluna de dados esteja dentro de lista de colunas permitidas
		If aScan(aCols,{|x| x == nx}) > 0
			If lImpECF
				//Verificar necessidade de ajustar a largura das colunas de valores
				If !lAjLarg .AND. AllTrim(aCmp[nx]) $ "LT_VLRDIG|LT_VLRAPU"
					If Len(cValToChar(aDados[ni][nx])) >= 10 //Atingiu a casa do milhao
						lAjLarg := .T.
					Endif
				Endif
			Endif
			aAdd(aTMP,IIf(!Empty(aCab[nx][3]),Transform(aDados[ni][nx],aCab[nx][3]),aDados[ni][nx]))
		Endif
	Next nx
	oFrm:Add(2,aTMP)
Next ni
If lImpECF
	oFrm:PrintLine(1)
	oFrm:PrintLineWD()

	oFrm:PrintLineWD() //Linha com tracejado
	If ExistBlock("Frt272bAss")
		aFrt272bAss := ExecBlock("Frt272bAss", .F., .F.)
		For nx :=1 To Len(aFrt272bAss)
			oFrm:PrintText(aFrt272bAss[nx])
		Next nx
	Else
		oFrm:PrintText(STR0083+" ________________________________") //#STR0083->"Ass. Caixa   :"
		oFrm:PrintBlaWD() // linha em branco
		oFrm:PrintText(STR0084+" ________________________________") //#->"Ass. Superior:"
	EndIf
	oFrm:PrintLineWD() //Linha com tracejado
	
	//Ajustar largura das colunas, se necessario
	If lAjLarg
		oFrm:SetColWidth(2,{10,14,10,8,29,29})
	Endif
	oFrm:Exec()
Else
	If !lCSV
		oFrm:SetTitle(STR0045) //"CONF.FECHAMENTO DE CAIXA"
		oFrm:Exec()
	Else
		If oFrm:FindFile()
			oFrm:Exec()
		Endif
	Endif
Endif
oFrm:Finish()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDescFP    บAutor  ณVendas Clientes       บ Data ณ  08/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a descricao da forma de pagamento.                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DescFP(cFM)

Local cChave			:= ""		//Chave de pesquisa
Local cRet				:= ""		//Retorno

Default cFM			:= ""

If Empty(cFM)
	Return cRet
Endif
cChave := xFilial("SX5") + "24" + AllTrim(cFM)
dbSelectArea("SX5")
SX5->(dbSetOrder(1))
SX5->(dbSeek(cChave))
If SX5->(Found())
	cRet := SX5->X5_DESCRI
Endif

If Empty(cRet)
	cFM := UPPER(AllTrim(cFM))

	Do Case
		Case cFM == "SG"
			 cRet := STR0078 //"SANGRIA"

		Case cFM == "TC"
			 cRet := STR0079 //"ENTRADA DE TROCO"

		Case cFM == "REC"
			 cRet := STR0080 //"RECEBIMENTOS"

		Case cFM == "CB"
			 cRet := STR0081 //"CORRESPONDENTES BANCARIOS"

		Case cFM == "RCE"
			 cRet := STR0082 //"RECARGA DE CELULAR"
	EndCase

EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOpcSimples   บAutor  ณVendas Clientes    บ Data ณ  09/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para opcao de cancelamento de conferencia.         บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function OpcSimples(oTela,nOpca,cTipo)

Local cPerg			:= ""		//Pergunta

If nModoChama == 1
	If cTipo == "A"
		cPerg := STR0046 //", deseja realmente cancelar a confer๊ncia e a abertura deste caixa?"
	Else
		cPerg := STR0047 //", deseja realmente cancelar a confer๊ncia e o fechamento deste caixa?"
	Endif
Else
	If LJProfile(25)
		cPerg := STR0074 //", deseja realmente efetuar o fechamento de caixa simplificado?"
	Else
		cPerg := STR0049 //", deseja realmente cancelar a confer๊ncia e a opera็ใo de fechamento de caixa?"
	Endif
Endif
If ApMsgYesNo(cNomeUs + cPerg)
	nOpca := 2
	oTela:End()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetCupomF บAutor  ณVendas Clientes       บ Data ณ  10/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de retorno do cupom fiscal final.                      บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetCupomF()

Local cCupomF			:= ""		//Numero do cupom fiscal final
Local nRet				:= 0		//Codigo de retorno
Local ni				:= 0		//Contador
Local nTenta			:= 5		//Tentativas

//Caso exista ECF e o caixa tenha permissao para usa-la
If lFiscal .AND. LjProfile(3)
	For ni := 1 to nTenta	
		If cPaisLoc == "ARG"
			nRet := IFPegCupom(nHdlECF,@cCupomF,"D|B")
		Else
			nRet := IFPegCupom(nHdlECF,@cCupomF)
		Endif
		If nRet == 0	//Ok
			Exit
		Endif
	Next ni
Endif

Return cCupomF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerErro    บAutor  ณVendas Clientes       บ Data ณ  28/07/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento de erro                                             บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VerErro(e,lErro,cErro)

Local lRet 		:= .F.		//Retorno

If e:Gencode > 0  
	If InTransaction()
		cErro := STR0051 + CRLF //"Houve um erro no processamento de gravacao : "
	Else
		cErro := STR0052 + CRLF //"Houve um erro no levantamento de registros : "
	Endif
    cErro += STR0053 + e:Description + CRLF //"Descri็ใo : "
    cErro += e:ErrorStack
    lErro := .T.
	lRet := .T.
	Break
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldRedZ    บAutor  ณVendas Clientes       บ Data ณ  14/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidador da opcao de processamento da reducao Z               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VldRedZ(lReduZ)

lReduz := !lReduz
If lReduZ
	If !ApMsgYesNo(cNomeUs + STR0054) .Or. !LJProfile(6) //", voc๊ confirma o processamento da redu็ใo Z?"
		lReduz := .F.
		oReduZ:Refresh()
	Endif
Endif

Return lReduz

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldLeitX   บAutor  ณVendas Clientes       บ Data ณ  13/09/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidador da opcao de processamento da leitura X               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VldLeitX(lLeitX)

lLeitX := !lLeitX
If lLeitX
	If !LJProfile(21)
		lLeitX := .F.
		oLeitX:Refresh()
	Endif
Endif

Return lLeitX

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpComp    บAutor  ณVendas Clientes       บ Data ณ  14/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprimir comprovantes solicitados                              บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpComp(lAcum,lLeitX,lRedZ,oHora,cHora,oDoc,cDoc)

Local lRet			:= .T.							//Retorno
Local cLock 		:= cUserName + aID[1][1]		//Trava
Local lEnd		 	:= .F.							//Variavel para a rotina de acumulado diario
Local lCancel	 	:= .F.							//Variavel para a rotina de acumulado diario

Default lAcum		:= .F.
Default lLeitX		:= .F.
Default lRedZ		:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprimir o relatorio gerencial com os dados de fechamento ณ
//ณde caixa completo                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Fr271CSan(.F.,,dDtMov,cNumMov,aID)

If lAcum .OR. lLeitX .OR. lRedZ
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o controle via LockByName para evitar que um usuario acesse  2 vezes uma rotina que use os perifericos de automacao ณ
	//ณ evitando assim a concorrencia dos mesmos                                            								    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If SetMDIChild(0) .AND. !LockByName(cLock)
		Return !lRet
	Endif
Else
	//Retornar verdadeiro, jah que nenhuma opcao foi marcado e nao houve nenhuma inconsistencia
	Return lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAcumulados diarios  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lAcum
	//dDtMov - Data real de abertura do movimento
	If lFiscal .AND. lImpFiscal
		LJ320Processa(dDtMov,@lEnd,@lCancel)
	Endif
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLeitura X  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤู
If lLeitX
	If lFiscal .AND. lImpFiscal .AND. LjVldSerie()
		IFLeituraX(nHdlECF)
		If nModoChama == 2	.AND. ValType(oHora) == "O" //FRT
			FR271Hora(.T.,Nil,oHora,cHora,oDoc,cDoc)
		Endif
	Endif
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณReducao Z  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤู
If lRedZ
	If lFiscal .AND. lImpFiscal .AND. LjVldSerie()	.AND. LjCancOrc()
		If ApMsgYesNo(cNomeUs + STR0055 + CRLF + STR0056 + ; //", deseja realmente processar a redu็ใo Z?"###"(Importante : Lembre-se de que o ECF somente poderแ ser utilizado novamente "
			STR0057) //"no dia seguinte!)"
		
			LJ160Leitura()
		Endif
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLstCalc    บAutor  ณVendas Clientes       บ Data ณ  15/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGerar totalizadores da lista de apontamentos.                  บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LstCalc(nOpc,nTam,lRetVal)

Local cRet		:= ""				//Retorno
Local aDados	:= oGet01:aCols		//Array com dados da GetDados
Local ni		:= 0				//Contador
Local nCol		:= 0				//Controle de coluna
Local nTotal	:= 0				//Totalizador
Local cCMP		:= ""				//Campo a calcular
Local cMasc		:= ""				//Picture
Local nSinal	:= 1				//define se o valor serแ somado ou subtraํdo na apura็ใo

Default nOpc	:= 1
Default nTam	:= 0
Default lRetVal	:= .F.

Do Case
	Case nOpc == 1		//Quantidade
		cCMP	:= "LT_QTDE"
		nCol 	:= POS_QTDE
	Case nOpc == 2		//Digitado
		cCMP	:= "LT_VLRDIG"
		nCol 	:= POS_VALDIG
		cMasc	:= PesqPict("SLT",cCMP)
	Case nOpc == 3		//Apurado
		cCMP	:= "LT_VLRAPU"
		nCol 	:= POS_VALAPU
		cMasc	:= PesqPict("SLT",cCMP)
	Otherwise
		Return cRet
EndCase

For ni := 1 to Len(aDados)
	//Se for SANGRIA, subtraimos o valor do total, pois ocorre a saํda do caixa
	If (nOpc==2 .OR. nOpc==3) .AND. aDados[nI][1] == "SG"
		nSinal := -1
	Else
		nSinal := 1
	EndIf
	//Caso seja a linha atual e o campo seja editavel, carregar a variavel de memoria correspondente ao campo
	If ni == IIf(Type("n") == "U",0,n) .AND. aScan(aCmpAlter,{|x| AllTrim(x) == cCMP}) > 0 .AND. Type(cCMP) <> "U"	
		nTotal += (M->&(cCMP) * nSinal)
	Else
		nTotal += (aDados[ni][nCol] * nSinal)
	Endif
Next ni

If !lRetVal
	If !Empty(cMasc)
		cRet += AllTrim(Transform(nTotal,cMasc))
	Else
		cRet += cValToChar(nTotal)
	Endif
	If !Empty(nTam)
		cRet := PadL(Right(cRet,nTam),nTam)	
	Endif
Endif

Return IIf(!lRetVal,cRet,nTotal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFR272BExTotบAutor  ณVendas Clientes       บ Data ณ  15/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizar uma determinada variavel totalizadora.               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FR272BExTot(aOpc)

Local cVarT			:= ""			//Variavel totalizadora a atualizar
Local nTotal		:= 0			//Totalizador
Local ni			:= 0			//Contador
Local aValores		:= Array(2)		//Array de valores
Local nSaldo		:= 0			//Saldo

Default aOpc		:= {1}

If ValType(aOpc) # "A" .OR. Len(aOpc) == 0
	Return Nil
Endif
nTotal := Len(aOpc)
For ni := 1 to nTotal
	//Atualizar variavel
	cVarT := aTotal[aOpc[ni]][2]
	If Type(cVarT) <> "U"
		&(cVarT) := LstCalc(aOpc[ni],TAMTOT)
	Endif
	//Atualizar objeto
	cVarT := aTotal[aOpc[ni]][1]
	If Type(cVarT) # "U"
		&(cVarT):Refresh()
	Endif
Next ni
//Se nao for conferencia cega, calcular o saldo
If !lConfCega
	aValores[1]	:= LstCalc(2,,.T.)
	aValores[2]	:= LstCalc(3,,.T.)
	If aValores[1] <> Nil .AND. aValores[2] <> Nil
		nSaldo := aValores[1] - aValores[2]
		//Atualizar variavel e campo
		cVarT := aTotal[Len(aTotal)][2]
		If Type(cVarT) <> "U"
			&(cVarT) := AllTrim(Transform(nSaldo,cPTN01))
		Endif
		//Atualizar objeto
		cVarT := aTotal[Len(aTotal)][1]
		If Type(cVarT) # "U"
			If nSaldo >= 0
				&(cVarT):nClrText := CLR_BLUE	
			Else
				&(cVarT):nClrText := CLR_RED
			Endif
			&(cVarT):Refresh()
		Endif
	Endif
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAbTelaOpc  บAutor  ณVendas Clientes       บ Data ณ  16/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAbre tela para selecao da forma de impressao a ser utilizada.  บฑฑ
ฑฑบ          ณAplicavel somente ao SIGALOJA e PAF                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AbTelaOpc()

Local nOpcR			:= 0	//Retorno
Local nRad01		:= 1	//Opcao de impressao escolhida na radio button
Local nOpca			:= 0	//Acao selecionada na interface
//Variaveis de interface
Local oTela
Local oFont01
Local oSay01
Local oRad01
Local oBot01
Local oBot02

DEFINE MSDIALOG oTela TITLE STR0058 FROM 000, 000  TO 196,293 COLORS CLRTEXT,CLRBACK PIXEL //"Impressใo"

oGrp01 	:= tGroup():New(004,004,096,144,STR0059,oTela,CLRTEXT,CLRBACK,.T.) //"Selecione a forma de impressใo"
oRad01 	:= tRadMenu():New(015,009,{STR0060,STR0061,STR0063},{|u|IIf(PCount() == 0,nRad01,nRad01 := u)},oTela,,,CLRTEXT,CLRBACK,,,,100,012,,,,.T.) //"IMPRESSรO NA ECF"###"IMPRESSรO NORMAL"
oBot01	:= tButton():New(080,075,STR0026	,oTela	,{|| nOpca := 1, oTela:End()},030,012,,,,.T.,,,,{|| .T.}) //"Confirmar"
oBot02	:= tButton():New(080,110,STR0028	,oTela	,{|| nOpca := 2, oTela:End()},030,012,,,,.T.,,,,{|| .T.}) //"Cancelar"

ACTIVATE MSDIALOG oTela CENTERED

If nOpca == 1
	nOpcR := nRad01
Endif

Return nOpcR

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCxRetNome  บAutor  ณVendas Clientes       บ Data ณ  17/09/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para retornar o nome de um determinado banco.           บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CxRetNome(cCod)

Local cRet 			:= ""					//Retorno
Local aAreaSA6		:= SA6->(GetArea())	//Area da SA6
#IFDEF TOP
Local cAlias		:= GetNextAlias()		//Alias temporario
#ENDIF

If Empty(cCod) .OR. ValType(cCod) # "C"
	Return cRet
Endif
#IFDEF TOP
	BeginSQL Alias cAlias
		SELECT DISTINCT A6_NOME 
		FROM %table:SA6% 
		WHERE %notDel% AND A6_FILIAL = %xFilial:SA6% AND A6_COD = %exp:cCod%
	EndSQL
	(cAlias)->(dbGoTop())
	If !(cAlias)->(Eof())
		cRet := (cAlias)->(FieldGet(1))
	Endif
	FechaArqT(cAlias)	
#ELSE
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))
	If SA6->(dbSeek(xFilial("SA6") + RTrim(cCod)))
		cRet := SA6->A6_NOME
	Endif
#ENDIF
RestArea(aAreaSA6)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOpcOk     บAutor  ณVendas Clientes       บ Data ณ  17/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para opcao de confirmacao da conferencia.          บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function OpcOk(oTela,nOpca)

Local cPerg			:= STR0062 //", confirma a grava็ใo desta confer๊ncia?"

If ApMsgYesNo(cNomeUs + cPerg)
	nOpca := 1
	oTela:End()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpRelPad บAutor  ณVendas Clientes       บ Data ณ  30/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao dos relatorios padrao de acumulados diarios, leituraบฑฑ
ฑฑบ          ณX, reducao Z e relatorio gerencial de sangria.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpRelPad(lRet,lAcumDia,lLeitX,lReduZ,oHora,cHora,oDoc,cDoc)

//Chamar a rotina de impressao de relatorios
If lRet .AND. lFiscal .AND. lImpFiscal
	ImpComp(lAcumDia,lLeitX,lReduZ,oHora,cHora,oDoc,cDoc)
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณF272BGrvLTบAutor  ณPablo Gollan Carreras บ Data ณ09/11/10         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gravacao da SLT                                       บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Array com os dados a gravar na SLT                     บฑฑ
ฑฑบ          ณExp02[D] : Data do movimento                                      บฑฑ
ฑฑบ          ณExp03[L] : Fechamento simplificado?                               บฑฑ
ฑฑบ          ณExp04[A] : Data e hora da ECF                                     บฑฑ
ฑฑบ          ณExp05[A] : Identificacao completa Operado+Estacao+PDV+Serie       บฑฑ
ฑฑบ          ณExp06[L] : Determina se a origem de dados da conf. eh a SLT       บฑฑ
ฑฑบ          ณExp07[A] : Posicao dos registros utilizados da SLT                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L] : Determina se o processo de gravao foi concluido com     บฑฑ
ฑฑบ          ณ          sucesso                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMAGNUM                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F272BGrvLT(aDados,dDataMov,lFechaSimp,aDataHr,aID,lMntGDSLT,aRegSLT)

Local lRet				:= .T.								//Retorno da funcao
Local lApaga			:= .F.								//Apagar
Local lMoedaC			:= .F.								//Moeda corrente
Local cFP				:= ""								//Forma de pagamento
Local cAgencia			:= ""								//Agencia
Local cChave			:= ""								//Chave
Local nTamFP			:= TamSX3("LT_FORMPG")[1]			//Tamanho do campo da forma de pagamento
Local nTamMV			:= TamSX3("LT_NUMMOV")[1]			//Tamanho do campo de movimento
Local cCampos			:= ""								//Campos do indice utilizado, para comparacoes
Local ni				:= 0
Local cSimbC			:= SuperGetMV("MV_SIMB1",.F.,"")	//Moeda corrente
Local lAbMultiMoed		:= .F.								//Multi-moeda
Local aLstCxAb			:= {}								//Lista de caixas abertos - Agencias (moedas)
Local cAgenC			:= PadR(".",nTamAgen)				//Codigo da agencia corrente
Local aCaixaC			:= Array(5)							//Caixa na moeda corrente - 1.Filial 2.Codigo 3.Agencia 4.Dt Abertura 5.Aberto?
Local lUsaFecha			:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Usa conferencia de cx
Local lNovo				:= .F.

Default aDados			:= {}
Default dDataMov		:= Nil
Default lFechaSimp		:= .F.
Default aDataHr		:= LjDtHrECF(.T.)
Default aID			:= {}
Default lMntGDSLT		:= .F.
Default aRegSLT		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidar parametros  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(aDados) # "A" .OR. Len(aDados) == 0 .OR. ValType(dDataMov) # "D" .OR. Empty(dDataMov) .OR. ;
	ValType(aDataHr) # "A" .OR. ValType(aID) # "A" .OR. Len(aID) == 0 .OR. !lUsaFecha

	Return !lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPesquisa caixa na moeda principal  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SA6")
SA6->(dbSetOrder(1))
SA6->(dbSeek(xFilial("SA6") + PadR(aID[1][1],aID[1][2]) + cAgenC))
If !SA6->(Found())
	
	Return !lRet
Endif
aCaixaC[1] := SA6->A6_FILIAL
aCaixaC[2] := SA6->A6_COD
aCaixaC[3] := SA6->A6_AGENCIA
aCaixaC[4] := SA6->A6_DATAABR
aCaixaC[5] := IIf(Empty(SA6->A6_DATAABR),.F.,.T.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤs ฟ
//ณPesquisar se o movimento do caixa foi aberto em mais de ณ
//ณuma moeda (localizadas). Para criar o array de moedas   ณ
//ณutilizadas no processo de abertura de caixa.            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤs ู
If cPaisLoc # "BRA"
	Do While !SA6->(Eof()) .AND. SA6->(A6_FILIAL + A6_COD) == (aCaixaC[1] + aCaixaC[2])
		//Se for a agencia principal, saltar
		If SA6->A6_AGENCIA == aCaixaC[3]
			SA6->(dbSkip())
			Loop
		Endif
		//Na chamada pelo SIGAFRT exigir que as datas de abertura sejam as mesmas para que as moedas nao correntes sejam consideradas (caso o caixa esteja aberto)
		If nModoChama == 2 .AND. aCaixaC[5]
			If SA6->A6_DATAABR == aCaixaC[4] .AND. IsMoney(SA6->A6_AGENCIA)
				aAdd(aLstCxAb,AllTrim(SA6->A6_AGENCIA))
			Endif
		Else
			If IsMoney(SA6->A6_AGENCIA)
				aAdd(aLstCxAb,SA6->A6_AGENCIA)
			Endif
		Endif
	EndDo
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravar a conferencia SLT  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SLT")
SLT->(dbSetOrder(4))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG+LT_PDV+LT_NUMMOV+LT_ADMIFIN
For ni := 1 to Len(aDados)
	//Se o registro estiver marcado como apagado, desconsiderar
	If aTail(aDados[ni])
		Loop
	Endif
	lApaga := .F.
	If cPaisLoc # "BRA"
		lMoedaC := IIf(aScan(aLstCxAb,{|x| AllTrim(x) == AllTrim(aDados[ni][POS_MOEDA])}) == 0,.T.,.F.)
		If lMoedaC
			cFP := aDados[ni][1]
			cAgencia := cAgenC
		Else
			cFP := aDados[ni][1] + cValToChar(RetMoeda(aDados[ni][POS_MOEDA]))
			cAgencia := PadR(AllTrim(aDados[ni][POS_MOEDA]),nTamAgen)
		Endif
	Else
		lMoedaC := .T.
		cFP := aDados[ni][1]
		cAgencia := cAgenC		
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerificar se a conferencia foi realizada baseando-se na SLT e alterar o modo de gravacao.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lMntGDSLT
		lNovo := .T.	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso exista o registro, apagar  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cChave := xFilial("SLT")
		cChave += PadR(aID[1][1],aID[1][2])			//OPERADOR
		cChave += DtoS(aDataHr[1])						//FECHAMENTO
		cChave += PadR(cFP,nTamFP)						//FORMA DE PAGAMENTO
		cChave += PadR(aID[4][1],aID[4][2])			//PDV
		cChave += PadR(cNumMov,nTamMV)					//MOVIMENTO
		If lDetADMF
			cChave += RTrim(aDados[ni][POS_CODADM])	//ADM FINANCEIRA	
		Else
			cChave += Space(TamSX3("LT_ADMIFIN")[1])
		Endif
		cChave += DtoS(dDataMov)						//DATA MOVIMENTO
		SLT->(dbSetOrder(4))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG+LT_PDV+LT_NUMMOV+LT_ADMIFIN+DTOS(LT_DTMOV)
		SLT->(dbSeek(cChave))
		If SLT->(Found())
			cCampos := SLT->(IndexKey())
	 		Do While !SLT->(Eof()) .AND. RTrim(SLT->&(cCampos)) == RTrim(cChave)
				RecLock("SLT",.F.)
				dbDelete()
				MsUnlock()
	 			SLT->(dbSkip())
	 		EndDo
		Endif
	Else
		lNovo := .F.
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณO array aDados eh o espelho da SLT (neste caso), sendo assim para ณ
		//ณevitar um volume desnecessario de registros apagados, apenas      ณ
		//ณposicionar em cada um dos registros (pela ordem) que compuseram a ณ
		//ณarray aDados, origem dos dados a serem gravados, p/ sobreescrever ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SLT->(dbGoto(aRegSLT[ni]))
	Endif
	RecLock("SLT",lNovo)
	SLT->LT_FILIAL		:= xFilial("SLT")
	SLT->LT_OPERADO		:= aID[1][1]
	SLT->LT_DTFECHA		:= aDataHr[1]
	SLT->LT_FORMPG		:= cFP
	If SLT->(FieldPos("LT_DESFORM")) > 0 .AND. !X3NaoUsa("LT_DESFORM",.F.,.T.)
		SLT->LT_DESFORM		:= aDados[ni][POS_DESCFP]
	Endif	
	If !lFechaSimp
		SLT->LT_VLRDIG		:= aDados[ni][POS_VALDIG]
	Else
		SLT->LT_VLRDIG		:= 0
	Endif
	SLT->LT_SANPAR		:= 0
	SLT->LT_AGENCIA		:= cAgencia
	SLT->LT_NUMMOV		:= cNumMov
	SLT->LT_DTMOV		:= dDataMov
	SLT->LT_MOEDA		:= RetMoeda(aDados[ni][POS_MOEDA],1,1)
	SLT->LT_ESTACAO		:= aID[2][1]
	SLT->LT_PDV			:= aID[4][1]
	//Campo de controle de conferencia dos apontamentos de fechamento de caixa
	If !lFechaSimp
		SLT->LT_CONFERE	:= "1"
	Else
		SLT->LT_CONFERE	:= "2"		
	Endif
	If lDetADMF
		SLT->LT_ADMIFIN	:= aDados[ni][POS_CODADM]
	Endif
	SLT->LT_QTDE		:= aDados[ni][POS_QTDE]
	If !lConfCega
		SLT->LT_VLRAPU	:= aDados[ni][POS_VALAPU]
	ElseIf Len(aNumerario) > 0
		SLT->LT_VLRAPU	:= aNumerario[ni][POS_VALAPU]
	Endif
	If nModoChama == 1 .AND. !lFechConf 	//SIGALOJA conectado a retaguarda
		SLT->LT_SITUA	:= "RX"			//Recebido
	Else								//SIGAFRT
		SLT->LT_SITUA	:= "00"			//Pendente de transmissao para retaguarda
	Endif
	MsUnlock()
Next ni

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณF272BExSLTบAutor  ณPablo Gollan Carreras บ Data ณ10/11/10         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que verifica a existencia de conferencia de um determinado บฑฑ
ฑฑบ          ณmovimento (SLW).                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Operador (caixa)                                       บฑฑ
ฑฑบ          ณExp02[C] : Numero do movimento alvo                               บฑฑ
ฑฑบ          ณExp03[D] : Data de fechamento                                     บฑฑ
ฑฑบ          ณExp04[C] : Estacao de origem do movimento                         บฑฑ
ฑฑบ          ณExp05[C] : PDV de origem do movimento                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L] : Determina se existe ou nao conferencia atrelada ao      บฑฑ
ฑฑบ          ณ          movimento                                               บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMAGNUM                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function F272BExSLT(cOper,cMov,dDataF,cEstacao,cPDV)

Local lRet				:= .F.				//Retorno
Local aAreaSLT			:= SLT->(GetArea())//Guarda area de trabalho da SLT
Local lUsaFecha			:= SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utilizar conf. de fechamento
Local aID 				:= IIf(FindFunction("LjInfoCxAt"),LjInfoCxAt(1),{})	//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
Local cAlias			:= GetNextAlias()	//Proximo alias disponivel
Local lQry				:= .F.
Local cChave			:= ""				//Chave de pesquisa

Default cOper			:= IIf(Len(aID) == 0,"",aID[1])
Default cMov			:= AllTrim(LjNumMov())
Default dDataF			:= Date()
Default cEstacao		:= IIf(Len(aID) == 0,"",aID[2])
Default cPDV			:= IIf(Len(aID) == 0,"",aID[4])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao de parametros  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cOper) .OR. Empty(cMov) .OR. ValType(dDataF) # "D" .OR. Empty(dDataF) .OR. Empty(cEstacao) .OR. Empty(cPDV)
	Return lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso a conf. de fecha. de cx. nao seja usado ou a SLT nao exista no dicionario  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lUsaFecha .OR. !AliasInDic("SLT")
	Return lRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento nas variaveis  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFDEF TOP
	lQry := .T.
	cOper		:= AllTrim(cOper)
	cMov		:= AllTrim(cMov)
	dDataF		:= DtoS(dDataF)
	cEstacao	:= AllTrim(cEstacao)
	cPDV		:= AllTrim(cPDV)	
#ELSE
	cOper 		:= PadR(AllTrim(cOper),TamSX3("LT_OPERADO")[1])
	cMov		:= PadR(AllTrim(cMov),TamSX3("LT_NUMMOV")[1])
	dDataF		:= DtoS(dDataF)
	cEstacao	:= PadR(AllTrim(cEstacao),TamSX3("LT_ESTACAO")[1])
	cPDV		:= AllTrim(cPDV)
#ENDIF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcurar pela conferencia do movimento respectivo  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lQry
	BeginSQL Alias cAlias
		Column LT_DTFECHA As Date
		%NoParser%
		SELECT DISTINCT LT_FILIAL, LT_OPERADO, LT_NUMMOV, LT_DTFECHA, LT_ESTACAO, LT_PDV, LT_FORMPG  
		FROM %table:SLT% 
		WHERE %NotDel% AND LT_FILIAL = %xFilial:SLT% AND LT_OPERADO = %exp:cOper% AND LT_NUMMOV = %exp:cMov% AND LT_DTFECHA = %exp:dDataF% AND 
		LT_ESTACAO = %exp:cEstacao% AND LT_PDV = %exp:cPDV% 
		ORDER BY %Order:SLT,1% 
	EndSQL
	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())
	If !(cAlias)->(Eof())
		lRet := .T.
	Endif
	FechaArqT(cAlias)
Else
	cChave := xFilial("SLT") + dDataF + cMov + cOper + cEstacao + cPDV
	dbSelectArea("SLT")
	SLT->(dbSetOrder(5))	//LT_FILIAL+LT_DTFECHA+LT_NUMMOV+LT_OPERADO+LT_ESTACAO+LT_PDV
	SLT->(dbSeek(cChave))
	If SLT->(Found())
		lRet := .T.
	Endif
Endif
RestArea(aAreaSLT)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOpcCanc   บAutor  ณVendas Clientes       บ Data ณ  09/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para opcao de cancelamento de conferencia.         บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OpcCanc(oTela,nOpca)
Local cAlerta	:= STR0075 //"Apos efetuar o cancelamento da confer๊ncia serแ necessแrio conferi-la posteriormente."
Local cPerg		:= STR0076 //", deseja realmente cancelar a confer๊ncia de caixa?"

If ApMsgYesNo(cAlerta + CHR(10)+CHR(13) +;
			  cNomeUs + cPerg, STR0077) //"Aten็ใo"
	nOpca := 0
	oTela:End()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF272BFecPermite บAutor  ณVendas Clientes บ Data ณ  07/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para verificar se esta habilitada a permissใo p/   บฑฑ
ฑฑบ          ณfechamento de caixa e se esta compilada (LOJA120),caso nใo    บฑฑ
ฑฑบ          ณseguir fluxo normalmente, caso esteja serแ necessแrio         บฑฑ
ฑฑบ          ณverificar permiss๕es do caixa                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณlRet[L]: .T.->Esta habilitado a efetuar a conferencia de caixaบฑฑ
ฑฑบ          ณ         .F.->Nใo esta habiliatado a efetuar a conferencia de บฑฑ
ฑฑบ          ณ         de caixa                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA272B                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F272BFecPermite()
Local lRet			:= .T.
Local nAcesso 		:= 37
Local aPermissao	:= LJ120Permi()

If aScan( aPermissao, { |x| x[1] == nAcesso } ) > 0
	lRet := LjProfile(nAcesso)
EndIf

Return lRet
