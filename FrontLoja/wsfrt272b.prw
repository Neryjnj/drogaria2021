#INCLUDE "Protheus.ch"
#INCLUDE "ApWebSrv.ch"
#INCLUDE "WSFRT272B.ch"


Function WSFRT272B ; Return  // "dummy" function - Internal Use 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebService³WSFRT272B  ºAutor  ³Vendas Clientes       º Data ³  21/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Webservice para consulta de fechamentos de caixa que nao sofre-º±±
±±º          ³ram conferencias.                                              º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSSTRUCT RetSLW
	WSDATA cChave	AS String
	WSDATA lRet		AS Boolean
ENDWSSTRUCT

WSSERVICE WSFRT272B

	WSDATA aRetorno		AS Array OF RetSLW
	WSDATA nOpc			AS Integer
	WSDATA cOper		AS String
	WSDATA cPDV			AS String
	WSDATA cEstacao		AS String
	WSDATA cNumMov		AS String
	WSDATA cEmpC		AS String 	OPTIONAL
	WSDATA cFilC		AS String	OPTIONAL
	WSDATA cChave		AS String
	WSDATA cRet			AS String
	
	WSMETHOD ExConfAbLW 	DESCRIPTION STR0001 //"Conferencia de fechamento - Verifica se existe conferência em aberto"
	WSMETHOD RetSitLW		DESCRIPTION	STR0002 //"Conferencia de fechamento - Verifica a situacao de um movimento local na retaguarda"
	WSMETHOD RetParSrv		DESCRIPTION STR0003 //"Conferencia de fechamento - Retorno de conteudo de parametros do servidor"

ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ExConfAbLW ºAutor  ³Vendas Clientes       º Data ³  21/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para pesquisar se existem movimentos em aberto (sem con-º±±
±±º          ³ferencia de movimento - SLW) na retaguarda.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[N] : 1.Pesq. completa 2. Pesq. parcial (por operador)    º±±
±±º          ³Exp02[C] : Operador (caixa)                                    º±±
±±º          ³Exp03[C] : Codigo da impressora ECF (opcional)                 º±±
±±º          ³Exp04[C] : Codigo da estacao de trabalho (opcional)            º±±
±±º          ³Exp05[C] : Numero do movimento ativo (opcional)                º±±
±±º          ³Exp06[C] : Empresa a ser conectada                             º±±
±±º          ³Exp07[C] : Filial a ser conectada                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aRetorno : Retorna se existe o mov. e a chave de pesquisa      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD ExConfAbLW WSRECEIVE nOpc,cOper,cPDV,cEstacao,cNumMov,cEmpC,cFilC WSSEND aRetorno WSSERVICE WSFRT272B

Local cRotina		:= "[WSFRT272B:ExConfAbLW]" + Space(1)
Local lOk			:= .T.

//Inicializando variavel
aAdd(Self:aRetorno,WSClassNew("RetSLW"))
If Empty(Self:cEmpC) .OR. Empty(Self:cFilC) .OR. !FindFunction("EnvWSOk")
	lOk := !lOk
Else
	//Prepara a configuracao de ambiente
	lOk := EnvWSOk(.T.,Self:cEmpC,Self:cFilC)
Endif
If !lOk
	Self:aRetorno[1]:cChave 	:= ""
	Self:aRetorno[1]:lRet		:= .F.
	ConOut(cRotina + STR0004 + ::cEmpC + STR0005 + ::cFilC + STR0006) //"Não foi possível conectar o ambiente na empresa : "###" filial : "###". Execução do WS cancelada!"
	Return .T.
Endif
//Obter se existe algum movimento de abertura de caixa em aberto ou pendente de conferencia
Self:aRetorno[1]:cChave := LjUltMovAb(nOpc,cOper,cPDV,cEstacao,cNumMov,.T.)
If !Empty(Self:aRetorno[1]:cChave)
	Self:aRetorno[1]:lRet := .T.
Else
	Self:aRetorno[1]:lRet := .F.
Endif
ConOut(cRotina + STR0007 + cValToChar(Self:aRetorno[1]:lRet) + " " + IIf(Self:aRetorno[1]:lRet,Self:aRetorno[1]:cChave,""))  //"Existe movimento? "

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³RetSitLW   ºAutor  ³Vendas Clientes       º Data ³  13/10/10      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para pesquisar qual a situacao de um movimento em aberto   º±±
±±º          ³encontrado localmente, na retaguarda.                             º±±
±±º          ³Ordem de pesquisa : 03                                            º±±
±±º          ³LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Empresa a ser conectada                                º±±
±±º          ³Exp02[C] : Filial a ser conectada                                 º±±
±±º          ³Exp03[C] : Chave de pesquisa                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet - 00 - Nao esta na retaguarda ou houve erro de comunicacao   º±±
±±º          ³       01 - Esta na retaguarda e a conferencia esta em aberto     º±±
±±º          ³       02 - Esta na retaguarda e a conferencia esta feita         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD RetSitLW WSRECEIVE cEmpC,cFilC,cChave WSSEND cRet WSSERVICE WSFRT272B

Local cRotina		:= "[WSFRT272B:RetSitLW]" + Space(1)
Local lOk			:= .T.
Local aAreaSLW		:= {}

If Empty(Self:cEmpC) .OR. Empty(Self:cFilC) .OR. Empty(cChave) .OR. !FindFunction("EnvWSOk")
	lOk := !lOk
Else
	//Prepara a configuracao de ambiente
	lOk := EnvWSOk(.T.,Self:cEmpC,Self:cFilC)
Endif
If !lOk
	Self:cRet := "00"
	ConOut(cRotina + STR0004 + ::cEmpC + STR0005 + ::cFilC + STR0006) //"Não foi possível conectar o ambiente na empresa : "###" filial : "###". Execução do WS cancelada!"
	Return .T.
Endif
aAreaSLW := GetArea("SLW")
dbSelectArea("SLW")
SLW->(dbSetOrder(3))	//LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
If SLW->(dbSeek(cChave))
	If AllTrim(SLW->LW_TIPFECH) $ "2|3|4|5|6"
		//Fechamento completo
		Self:cRet := "02"
	Else
		//Fechamento simplificado
		Self:cRet := "01"
	Endif
Else
	Self:cRet := "00"
Endif
RestArea(aAreaSLW)
ConOut(cRotina + STR0008 + Self:cRet + Self:cChave) //"Retorno : "

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³RetParSrv  ºAutor  ³Vendas Clientes       º Data ³ 11/11/10       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar o conteudo de um parametro no servidor.      º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[C] : Empresa a conectar                                     º±±
±±º          ³Exp02[C] : Filial a conectar                                      º±±
±±º          ³Exp03[C] : Nome do parametro a retornar                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³cRet [C] : Retorno do conteudo do parametro                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD RetParSrv WSRECEIVE cEmpC,cFilC,cChave WSSEND cRet WSSERVICE WSFRT272B

Local cRotina		:= "[WSFRT272B:RetParSrv]" + Space(1)
Local lOk			:= .T.
Local aAreaSX6		:= {}
Local lEnc			:= .F.
Local cTipo			:= ""

ConOut(cRotina + STR0009) //"Conectando ao servidor"
If Empty(Self:cEmpC) .OR. Empty(Self:cFilC) .OR. Empty(cChave) .OR. !FindFunction("EnvWSOk")
	ConOut(cRotina + STR0010) //"Finalizando por falta de parametros"
	lOk := !lOk
Else
	//Prepara a configuracao de ambiente
	lOk := EnvWSOk(.T.,Self:cEmpC,Self:cFilC)
Endif
If !lOk
	Self:cRet := ""
	ConOut(cRotina + STR0004 + ::cEmpC + STR0005 + ::cFilC + STR0006) //"Não foi possível conectar o ambiente na empresa : "###" filial : "###". Execução do WS cancelada!"
	Return .T.
Endif
aAreaSX6 := SX6->(GetArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar a existência do parametro  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
SX6->(dbSetOrder(1))
//Procurar parametro na filial definida
SX6->(dbSeek(PadR(AllTrim(Self:cFilC),Len(SX6->X6_FIL)) + RTrim(cChave)))
If !SX6->(Found())
	//Procurar o parametro sem filial definida
	If SX6->(dbSeek(Space(Len(SX6->X6_FIL)) + RTrim(cChave)))	
		lEnc := !lEnc
		cTipo := SX6->X6_TIPO
	Endif
Else
	lEnc := !lEnc
	cTipo := SX6->X6_TIPO
Endif
If lEnc
	//Por conta das localizadas, retornar o conteudo do parametro atraves da funcao GetMV, que jah possui todos os tratamentos envolvidos necessarios e nao gera cache
	Self:cRet := AllToChar(GetMV(AllTrim(SX6->X6_VAR)))
	ConOut(cRotina + STR0008 + AllTrim(::cChave) + " - " + IIf(::cRet == Nil,"",::cRet)) //"Retorno : "
Else
	//O retorno da variavel com NULO indica que o parametro solicitado nao pode ser encontrado
	Self:cRet := Nil
	ConOut(cRotina + STR0011 + AllTrim(::cChave) + STR0012) //"O parametro : "###" não existe no servidor."
Endif
RestArea(aAreaSX6)

Return .T.