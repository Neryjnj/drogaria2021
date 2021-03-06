#INCLUDE "PROTHEUS.CH"
#INCLUDE "FRTA030.CH"


#DEFINE  CL_CONECTADO     0		// Azul
#DEFINE  CL_ONLINE        1		// Verde
#DEFINE  CL_ATUALIZANDO   2		// Amarelo
#DEFINE  CL_DESCONECTADO  3		// Vermelho
#DEFINE  CL_LOCKED        4		// Preto

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FRTA030	� Autor � Cesar Eduardo Valadao � Data �03/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monitoramento das Estacoes                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FRTA030()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAFRT e FRTMonitor                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTA030
Local cFile := GetClientDir()+"FRTMONIT.EXE"
If File(cFile)
	WinExec(cFile)
Else
	// "N�o foi poss�vel localizar o Monitor do FrontLoja.", "Aten��o"
	MsgStop(STR0001, STR0002)
EndIf
Return(NIL)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTRPCConn� Autor � Cesar Eduardo Valadao � Data �05/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com o status dos Check-Out's.             ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT e FRTMonitor                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTRPCConn
Local i, aRet:={}, aVendas:={}, nEstacao
Local nNumEsta := GetMV("MV_NUMESTA")
For i := 1 To nNumEsta
	AAdd(aRet, {CL_DESCONECTADO, {}})
	AAdd(aVendas, {})
Next i
dbSelectArea("SLI")
DbSeek(xFilial())
While LI_FILIAL == xFilial() .AND. !EOF()
	nEstacao := Val(Left(LI_ESTACAO,3))
	If nEstacao==0 .OR. nEstacao > nNumEsta
		dbSkip()
		Loop
	EndIf
	If !Empty(LI_ESTACAO) .AND. LI_TIPO=="CON"
		//�����������������������������������������
		//� Verificar se a Estacao Esta Conectada �
		//�����������������������������������������
		If FRTSemaStat("CON", LI_ESTACAO)
			MontaArray(aVendas[nEstacao], LI_MSG)
			aRet[nEstacao][1] := CL_CONECTADO
			aRet[nEstacao][2] := aVendas[nEstacao]
		EndIf
	ElseIf !Empty(LI_ESTACAO) .AND. LI_TIPO=="CRG"
		//�������������������������������������������������������������
		//� Verificar se a Estacao Esta Recebendo Carga (Atualizando) �
		//�������������������������������������������������������������
		If Left(LI_MSG,9)=="RECEBENDO"
			aRet[nEstacao][1] := CL_ATUALIZANDO
		EndIf
	ElseIf !Empty(LI_ESTACAO) .AND. LI_TIPO=="LCK" .AND. (aRet[nEstacao][1]=CL_CONECTADO)
		//�������������������������������������������������������
		//� Verificar se a Estacao Esta Travada Pelo FRTMonitor �
		//�������������������������������������������������������
		If MsRLock(Recno())
			MsRUnLock(Recno())
		Else
			aRet[nEstacao][1] := CL_LOCKED
		EndIf
	ElseIf !Empty(LI_ESTACAO) .AND. LI_TIPO=="OPE" .AND. (aRet[nEstacao][1]=CL_CONECTADO)
		//������������������������������������
		//� Verificar se o Caixa Esta Aberto �
		//������������������������������������
		If !Empty(LI_DATA) .AND. !Empty(LI_HORA)
			aRet[nEstacao][1] := CL_ONLINE
			AAdd(aRet[nEstacao], {AllTrim(LI_USUARIO), LI_DATA, LI_HORA, AllTrim(LI_MSG)})
		EndIf
	EndIf
	dbSkip()
End
Return(aRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �MontaArray� Autor � Cesar Eduardo Valadao � Data �20/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o array com as dimensoes.                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Informacoes da Matriz.                             ���
���          � ExpC2 - Caracter utilizado para While                      ���
���          � ExpN3 - Numero de dimensoes para montar.                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT e FRTMonitor                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MontaArray(aArray, cArray, nDimensao)
Local i:=1, nAt, nIndice:=1
Default nDimensao := 1
aArray := {}
cArray := AllTrim(cArray)
While i <= Len(cArray)
	cArray := Substr(cArray,i,Len(cArray))
	If (nAt:=At("|", cArray)) > 0
		If nDimensao>1
			If nIndice==1
				AAdd(aArray, {Substr(cArray, 1, nAt-1)})
				nIndice++
			Else
				AAdd(aArray[Len(aArray)], Substr(cArray, 1, nAt-1))
				If nIndice==nDimensao
					nIndice := 1
				Else
					nIndice++
				EndIf
			EndIf
		Else
			AAdd(aArray, Substr(cArray, 1, nAt-1))
		End
		i := nAt+1
	Else
		If nDimensao>1
			AAdd(aArray[Len(aArray)], cArray)
		Else
			AAdd(aArray, cArray)
		EndIf
		i := Len(cArray)+1
	EndIf
End
Return(NIL)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTResCX  � Autor � Cesar Eduardo Valadao � Data �20/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Resumo de Caixa Para o FRTMonitor.                         ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT e FRTMonitor                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTResCX(cCaixa)
Local aRet			:= {}
Local cCodCaixa		:= Nil
Local nOrder		:= Nil
Local aCaixa   		:= {}
Local aDadosVen		:= {}
Local aDadosSan		:= {}
Local aDDown   		:= Array(9)
Local aSinal   		:= { "+", "+", "+", "+", "+", "", "+", "+", "+" }	// Array com as sinais realizados
Local nVlrCred  	:= 0                         					// Valor do credito utilizado na compensacao da NCC
Local nTroco      	:= 0
Local nTotCredito	:= 0
Local nTotDebito	:= 0
Local nSaldFinal	:= 0
Local aContFina		:= {0 , 0 , 0 , 0 , ;
						0 , 0 , 0 , 0 , ;
						0 } 										// Contadores utilizados nos tipos de finaliza��es 
Local lUsaNMov  	:= .F.											// Verifica se foi criado MV_PAR09

nOrder := SA6->(IndexOrd())
SA6->(dbSetOrder(2))
If SA6->(DbSeek(xFilial("SA6")+Upper(cCaixa)))
	SA6->(dbSetOrder(nOrder))
	cCodCaixa := SA6->A6_COD
Else
	SA6->(dbSetOrder(nOrder))
	Return(aRet)
EndIf

//���������������������������������������������������������������Ŀ
//�Carrega array com valores totais do caixa em uma data          �
//�����������������������������������������������������������������
aCaixa := MovimCaixa(@cCodCaixa	,Nil		,Nil	,@aDDown	,;
					 @aContFina	,@nVlrCred	,Nil	,lUsaNMov	)

Lj030Dados(@aCaixa	,Nil			,Nil			,Nil			,;
			@nTroco	,@nTotCredito	,@nTotDebito	,@nSaldFinal	,;
			Nil		,Nil			,@aDadosVen		,@aSinal		,;
			@aDDown	,@aContFina		,@aDadosSan		,@nVlrCred		)

// Primeira Linha do aRet - Valores Finais
AAdd(aRet, {nTroco, nTotCredito, nTotDebito, nSaldFinal})
// Segunda Linha do aRet  - Creditos/Vendas
AAdd(aRet, AClone(aDadosVen))
// Terceira Linha do aRet - Debitos/Sangrias
AAdd(aRet, AClone(aDadosSan))
// Quarta Linha do aRet - ADDown
AAdd(aRet, AClone(aDDown))
Return(aRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTGrvRX  � Autor � Cesar Eduardo Valadao � Data �31/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava no SLI do Servidor a Informacao que o Pacote Subiu.  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT e FRTMonitor                                       ���
�������������������������������������������������������������������������Ĵ��
���Analista	 � Bops 	� DataSIG �			     Alteracao     			  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT e FRTMonitor                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTGrvRX(cNum, cPDV, cCOO)
Local i:=1, aRet:={}, cLI_MSG:=""
If SLI->(DbSeek(xFilial("SLI")+"    RX "))
	MontaArray(aRet, AllTrim(SLI->LI_MSG), 3)
EndIf
ASize(aRet, Len(aRet)+1)
AIns(aRet, 1)
aRet[1] := {AllTrim(cNum), AllTrim(cPDV), AllTrim(cCOO)}
// Na Tela do FRTMonitor eh Exibido Somente 7 Pacotes Por Vez...
// Lista FIFO
While (i<=7) .AND. (i<=Len(aRet)) .AND. Len(aRet[i]) >= 3
	cLI_MSG += aRet[i][1]+"|"+aRet[i][2]+"|"+aRet[i][3]+"|"
	i++
End
cLI_MSG := Left(cLI_MSG, Len(cLI_MSG)-1)
FRTGeraSLI("    ", "RX ", cLI_MSG, "SOBREPOE")
Return(NIL)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTGrvOK  � Autor � Cesar Eduardo Valadao � Data �31/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava no SLI do Servidor a Informacao que o Pacote         ���
���    	     � Foi Processado. (Integracao ERP)                           ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT e FRTMonitor                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTGrvOK(cNum)
Local i:=1, aRet:={}, cLI_MSG:=""
If SLI->(DbSeek(xFilial("SLI")+"    OK "))
	MontaArray(aRet, AllTrim(SLI->LI_MSG))
EndIf
ASize(aRet, Len(aRet)+1)
AIns(aRet, 1)
aRet[1] := AllTrim(cNum)
// Na Tela do FRTMonitor eh Exibido Somente 7 Pacotes Por Vez...
// Lista FIFO
While (i<=7) .AND. (i<=Len(aRet))
	cLI_MSG += aRet[i]+"|"
	i++
End
cLI_MSG := Left(cLI_MSG, Len(cLI_MSG)-1)
FRTGeraSLI("    ", "OK ", cLI_MSG, "SOBREPOE", .T.)
Return(NIL)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTSrvCon � Autor � Cesar Eduardo Valadao � Data �31/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Para o FRTMonitor um Array Com a Situacao da Tela  ���
���    	     � do Console do Server. Verificacao On-Line dos Pacotes.     ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT e FRTMonitor                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTSrvCon
Local aAuxRX:={}, aAuxOK:={}
// Situacao dos Pacotes Enviados
If SLI->(DbSeek(xFilial("SLI")+"    RX "))
	MontaArray(aAuxRX, SLI->LI_MSG, 3)
EndIf
// Situacao dos Pacotes Recebidos
If SLI->(DbSeek(xFilial("SLI")+"    OK "))
	MontaArray(aAuxOK, SLI->LI_MSG)
EndIf
Return({{Len(aAuxRX),AClone(aAuxRX)},{Len(aAuxOK),AClone(aAuxOK)}})
