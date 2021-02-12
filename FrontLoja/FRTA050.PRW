#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FRTA050.CH"

#define _PICTURE 13

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Frta050  ³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Efetua Sangria/Entrada de Troco no Front Loja			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fron Loja			   								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Analista  ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Danilo Calil³27/03/07³105168³Substituidas as funcoes:                  ³±±
±±³            ³        |      ³ - VerifCaixa por LjxDVerCx				  ³±±
±±³Conrado Q.  ³05/04/07³122711³Alterada a utilização da chamada          ³±±
±±³            ³        ³      ³SubStr(cUsuario,7,15) por cUserName       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Frta050(nCheck)
Local oDlgSangr, oCheck, oBtnAct, oBtnEnd, oGroup1, oGroup2, oGroup3
Local oCodOrigem, oCodDestin
Local oMoeda
Local cCodOrigem := xNumCaixa()
Local cCodDestin := Space(Len(cCodOrigem))
Local cMoedaCorr := GetMv("MV_MOEDA1")
Local cCampo     := ""
Local oDinheir, oCheques, oCartao, oVlrDebi, oFinanc, oConveni, oVales, oOutros
Local nDinheir  := 0
Local nCheques  := 0
Local nCartao   := 0
Local nVlrDebi  := 0
Local nFinanc   := 0
Local nConveni  := 0
Local nVales    := 0
Local nOutros   := 0        
Local nAltura   := 0
Local nAltura2  := 0
Local nX
Local nPosCampo := 0
Local aRet      := {} // Retorno do Ponto de Entrada
Local aMoedas   := {}
Local aSimbs    := {}
Local lRet      := .F.
Local cCaixaSup := Space(15)

Private nMoedaCorr := 1   // Moeda Corrente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Permissao "Sangria/Entrada de Troco" - #5 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LjProfile(5, @cCaixaSup)
    //"Usuario sem permissao para realizar Sangria / Entrada de Troco. Atencao" 				
	MsgStop(STR0022 + AllTrim(cUserName) + STR0023, STR0024)
	Return(NIL)
EndIf

If cPaisLoc != "BRA"
   nAltura   := 40
   nAltura2  := 15   
   SM2->(DbSetOrder(1))
   SM2->(DbSeek(dDatabase))
   For nX := 1 To MoedFin()             
      If !Empty(&("MV_MOEDA"+LTrim(Str(nX))))                          
         cCampo  := "M2_MOEDA"+Str(nX,1)
         nPosCampo := SM2->(FieldPos(cCampo))
         If IIf(nX > 1,SM2->(Found()) .And. SM2->(FieldGet(nPosCampo)) > 0,.T.)
	        AAdd(aMoedas,GetMv("MV_MOEDA"+LTrim(Str(nX))))			   
	        AAdd(aSimbs,GetMv("MV_SIMB"+LTrim(Str(nX))))			   	     	     
	     Else
	        MsgAlert(STR0025,STR0024) //"Por favor, preencher as cotacoes do dia de todas as moedas que estao sendo usadas no sistema!"###"Atencao"
	        Return(Nil)
	     EndIf   
	  EndIf   
   Next nX   
EndIf

nCheck := if(nCheck ==NIl,0,nCheck)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Troco o caixa destino sempre eh o operador atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCheck = 2
	cCodDestin := xNumCaixa()
	cCodOrigem := Substr(GetMv("MV_CXLOJA"),1,3)
Else
	cCodDestin := Substr(GetMv("MV_CXLOJA"),1,3)
	cCodOrigem := xNumCaixa()
EndIf

If lGaveta
	If (!Empty(LJGetStation("PORTGAV"))) .And. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
		GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
	Else
		IFGaveta(nHdlECF)
	EndIf
EndIf

If ExistBlock("FRT050SA")
	aRet := ExecBlock("FRT050SA",.F.,.F.,{nCheck,cCodOrigem,cCodDestin})
	nCheck		:= aRet[1]
	cCodOrigem	:= aRet[2]
	cCodDestin	:= aRet[3]
	nDinheir	:= aRet[4]
	nCheques	:= aRet[5]
	nCartao		:= aRet[6]
	nVlrDebi	:= aRet[7]
	nFinanc		:= aRet[8]
	nConveni	:= aRet[9]
	nVales		:= aRet[10]
	nOutros		:= aRet[11]
EndIf

SX5->(dbSetOrder(1)) // Primeiro indice para validacao do caixa digitado
SA6->(dbSetOrder(1)) // Primeiro indice para obtencao da Agencia/Conta para geracao do SE5

DEFINE MSDIALOG ODlgSangr FROM 1,1 TO 388+nAltura,330 TITLE STR0001 PIXEL OF GetWndDefault()

@ 005,004 GROUP oGroup1 TO 043,057 LABEL STR0002 COLOR CLR_HBLUE OF oDlgSangr PIXEL

@ 013,007 RADIO oCheck VAR nCheck 3D SIZE 47,10 PROMPT STR0003,STR0004 ON CHANGE Frt050Enab(nCheck,@cCodOrigem,@cCodDestin,oCodOrigem,oCodDestin) OF ODlgSangr PIXEL

If ! nCheck == 0
	oCheck:Disable()
Else
	nCheck := 1
EndIf

@ 005,061 GROUP oGroup2 TO 043,162 LABEL STR0005 COLOR CLR_HBLUE OF oDlgSangr PIXEL

@ 012,065 SAY STR0006 SIZE 50,10 OF ODlgSangr PIXEL
@ 012,120 MSGET oCodOrigem VAR cCodOrigem F3 "23" WHEN nCheck == 2 SIZE 30,10 OF ODlgSangr PIXEL ;
VALID SX5->(dbSeek(xFilial("SX5")+"23"+cCodOrigem)) .and. SA6->(dbSeek(xFilial("SA6")+cCodOrigem) .And. cCodOrigem <> xNumCaixa())
oCodOrigem:cSx1Hlp:=""

@ 027,065 SAY STR0007 SIZE 50,10 OF ODlgSangr PIXEL
@ 027,120 MSGET oCodDestin VAR cCodDestin F3 "23" WHEN nCheck == 1 SIZE 30,10 OF ODlgSangr PIXEL ;
VALID SX5->(dbSeek(xFilial("SX5")+"23"+cCodDestin)) .and. SA6->(dbSeek(xFilial("SA6")+cCodDestin) .And. cCodDestin <> xNumCaixa())
oCodDestin:cSx1Hlp:=""

@ 046,004 GROUP oGroup3 TO 176+nAltura2,162 LABEL STR0008 COLOR CLR_HBLUE OF oDlgSangr PIXEL

@ 055,014 SAY STR0009 SIZE 60,10 OF ODlgSangr PIXEL
@ 055,074 MSGET oDinheir VAR nDinheir Picture PesqPict("SL1","L1_DINHEIR",_PICTURE,nMoedaCorr) SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oDinheir:cSx1Hlp:="L1_DINHEIR"

@ 070,014 SAY STR0010 SIZE 60,10 OF ODlgSangr PIXEL
@ 070,074 MSGET oCheques VAR nCheques Picture PesqPict("SL1","L1_CHEQUES",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oCheques:cSx1Hlp:="L1_CHEQUES"

@ 085,014 SAY STR0011 SIZE 60,10 OF ODlgSangr PIXEL
@ 085,074 MSGET oCartao VAR nCartao Picture PesqPict("SL1","L1_CARTAO",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oCartao:cSx1Hlp:="L1_CARTAO"

@ 100,014 SAY STR0012 SIZE 60,10 OF ODlgSangr PIXEL
@ 100,074 MSGET oVlrDebi VAR nVlrDebi Picture PesqPict("SL1","L1_VLRDEBI",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oVlrDebi:cSx1Hlp:="L1_VLRDEBI"

@ 115,014 SAY STR0013 SIZE 60,10 OF ODlgSangr PIXEL
@ 115,074 MSGET oFinanc VAR nFinanc Picture PesqPict("SL1","L1_FINANC",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oFinanc:cSx1Hlp:="L1_FINANC"

@ 130,014 SAY STR0014 SIZE 60,10 OF ODlgSangr PIXEL
@ 130,074 MSGET oConveni VAR nConveni Picture PesqPict("SL1","L1_CONVENI",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oConveni:cSx1Hlp:="L1_CONVENI"


@ 145,014 SAY STR0015 SIZE 60,10 OF ODlgSangr PIXEL
@ 145,074 MSGET oVales VAR nVales Picture PesqPict("SL1","L1_VALES",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oVales:cSx1Hlp:="L1_VALES"

@ 160,014 SAY STR0016 SIZE 60,10 OF ODlgSangr PIXEL
@ 160,074 MSGET oOutros VAR nOutros Picture PesqPict("SL1","L1_OUTROS",_PICTURE,nMoedaCorr) WHEN nCheck == 1 SIZE 70,10 OF ODlgSangr PIXEL RIGHT
oOutros:cSx1Hlp:="L1_OUTROS"

If cPaisLoc != "BRA"
   @ 175,014 SAY STR0026 SIZE 60,10 OF ODlgSangr PIXEL  //"Moeda: " 		
   @ 175,074 MSCOMBOBOX oMoeda VAR cMoedaCorr ITEMS aMoedas ON CHANGE (nMoedaCorr:=oMoeda:nAt);
             SIZE 70,10 OF ODlgSangr PIXEL 
EndIf   

DEFINE SBUTTON oBtnAct FROM 180+nAltura2,105 TYPE 1 ENABLE ACTION ;
					Frt050Conf(	nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
								nDinheir	,nCheques	,nCartao	,nVlrDebi,;
								nFinanc		,nConveni	,nVales		,nOutros,;
								aSimbs		,ODlgSangr) OF ODlgSangr

DEFINE SBUTTON oBtnEnd FROM 180+nAltura2,135 TYPE 2 ENABLE ACTION ODlgSangr:End() OF ODlgSangr

ACTIVATE MSDIALOG ODlgSangr CENTER

RETURN NIL
             
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Frt050Conf³ Autor ³ Cleber Martinez       ³ Data ³ 06/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Confirma a gravacao dos valores informados (Botao OK)   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Frt050Conf(ExpN1, ExpC2, ExpC3, ExpC4,            ³±±
±±³			 ³ 					  ExpN5, ExpN6, ExpN7, ExpN8,             ³±±
±±³			 ³ 					  ExpN9, ExpN10, ExpN11, ExpN12,          ³±±
±±³  		 ³ 					  ExpA13, ExpO14)			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Indica se eh Troco ou Sangria                      ³±±
±±³          ³ ExpC2 - Codigo do Caixa logado                             ³±±
±±³          ³ ExpC3 - Codigo do caixa (De)                               ³±±
±±³          ³ ExpC4 - Codigo do caixa (Ate)                              ³±±
±±³          ³ ExpN5 - Valor em dinheiro                                  ³±±
±±³          ³ ExpN6 - Valor em cheques                                   ³±±
±±³          ³ ExpN7 - Valor em cartao                                    ³±±
±±³          ³ ExpN8 - Valor em debitos 	                              ³±±
±±³          ³ ExpN9 - Valor financiado                                   ³±±
±±³          ³ ExpN10 - Valor em Convenios                                ³±±
±±³          ³ ExpN11 - Valor em Vales                                    ³±±
±±³          ³ ExpN12 - Outros valores                                    ³±±
±±³          ³ ExpA13 - array de Simbolos de Moeda                        ³±±
±±³          ³ ExpO14 - Objeto dialog                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Front Loja			   								  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Frt050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
					nDinheir	,nCheques	,nCartao	,nVlrDebi,;
					nFinanc		,nConveni	,nVales		,nOutros,;
					aSimbs		,ODlgSangr)

Local lFrt050SB := ExistBlock("FRT050SB") //indica se existe o PE
Local lVldPE	:= .T.	//retorno da validacao executada no PE
Local lRet		:= .F.	//retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada (antes da gravacao do SE5) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFrt050SB
	lVldPE := ExecBlock("FRT050SB",.F.,.F.,{nCheck,cCaixaSup,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,cCodOrigem,cCodDestin})
	If Valtype(lVldPE) != "L"
		lVldPE := .T.
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o PE retornar .T., continua a gravacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldPE                                                 
	LjMsgRun(STR0017,,{|| lRet := Frt050SE5(nCheck,cCodOrigem,cCodDestin,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,aSimbs)})
	
	If (lRet .And. LJProfile(3) .And. ExistBlock("Frt050ST"))
		ExecBlock("Frt050ST",.F.,.F.,{nCheck,cCaixaSup,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros})
	Endif
	
	ODlgSangr:End()	
Endif
                    
Return (lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Frt050Enab³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ativa/Desativa os campos conforme a escolha do Radio Btn	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Frta050				   								  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Frt050Enab(nCheck,cCodOrigem,cCodDestin,oCodOrigem,oCodDestin)
If nCheck == 1
	cCodOrigem := xNumCaixa()
	oCodOrigem:Refresh()
	oCodDestin:SetFocus()
Else
	cCodDestin := xNumCaixa()
	oCodDestin:Refresh()
	oCodOrigem:SetFocus()
EndIf
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Frt050SE5 ³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o SE5 Conforme os campos digitados na tela			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Frta050				   								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - (1 - nCheck)Indica se e troco ou sangria.          ³±±
±±³          ³ ExpC1 - (2 - cCodOrigem) Codigo do caixa origem.           ³±±
±±³          ³ ExpC2 - (3 - cCodDestin) Codigo do caixa destino.          ³±±
±±³          ³ ExpN1 - (4 - nDinheir) Valor em dinheiro.                  ³±±
±±³          ³ ExpN2 - (5 - cCheques) Valor em cheques.                   ³±±
±±³          ³ ExpN3 - (6 - nCartao) Valor em cartao.                     ³±±
±±³          ³ ExpN4 - (7 - nVlrDeb) Valor em debitos.                    ³±±
±±³          ³ ExpN5 - (8 - nFinanc) Valor financiado.                    ³±±
±±³          ³ ExpN6 - (9 - nConveni) Valor em convenios.                 ³±±
±±³          ³ ExpN7 - (10 - nVales) Valor em vales.                      ³±±
±±³          ³ ExpN8 - (11 - nOutros) Outros valores.                     ³±±
±±³          ³ ExpA1 - (12 - aSimbs) Array de simbolos de moeda.          ³±±
±±³          ³ ExpL1 - (13 - lMensa) Se ira exibir mensagem.              ³±±
±±³          ³ ExpL2 - (14 - lSigaLoja) Indica se a funcao esta sendo     ³±±
±±³          ³							chamada do siga loja.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      | Analista | Bops  | Descricao                               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³18/11/2005| Marcos R.|088079 | Detalhamento da Sangria no CUPOM        |±± 
±±³02/10/2007| Nunzio   |132489 | Criacao do parametro lSigaLoja          |±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Frt050SE5(nCheck	, cCodOrigem, cCodDestin, nDinheir	, ;
                   nCheques	,nCartao	,nVlrDebi	,nFinanc	, ;
                   nConveni	,nVales		,nOutros	,aSimbs		, ;
                   lMensa	,lSigaLoja)
                   
Local aNumerarios   := {}																	//Array com os valores
Local nX			:= 0																	//Variavel de controle contador
Local nTotal 		:= nDinheir+nCheques+nCartao+nVlrDebi+nFinanc+nConveni+nVales+nOutros 	//Valor total 
Local cSimb 		:= SuperGetMV("MV_SIMB"+LTrim(Str(nMoedaCorr)))                        //Simbolo da moeda
Local nRet			:= 0                                                                   	//Variavel de retorno da impressao do comprovante
Local lSup      	:= SuperGetMV("MV_FORMSUP", ,.F.)                                      //Indica se ira exibir formulario
Local cFormSup		:= '' 																	// Contem a descricao das formas de Suprimentos que saira no cupom
Local cCupom		:= ""																	//Numero do cupom

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estaremos utilizando esta função de outros programas             ³
//³portanto em determinadas ocasiões não deverei exibir mensagens   ³
//³parando o processo. Atualmente teremos no fonte LOJA340 e LOJA350³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lMensa 		:= .T.
Default lSigaLoja 	:= .F.

If nTotal == 0 .And. lMensa
	MsgStop(STR0018,STR0024)  //"Nenhum valor foi informado, nenhuma movimentação será gerada." ### "Atenção"
	Return (.F.)
EndIf

If lMensa
	//"Confirma gravação da(s) movimentação(ões) referente(s) a quantia de: "
	If !MsgYesNo(STR0019+cSimb+" "+Transform(nTotal,PesqPict("SL1","L1_DINHEIR",_PICTURE,nMoedaCorr)) )
		Return (.F.)
	EndIf
EndIf

aNumerarios := {{cSimb,nDinheir},;
				{"CH",nCheques},;
				{"CC",nCartao},;
				{"CD",nVlrDebi},;
				{"FI",nFinanc},;
				{"CO",nConveni},;
				{"VA",nVales},;
				{"OU",nOutros}}


If lSup 
	If nDinheir > 0
		cFormSup	:= STR0029 + "|" + STRZERO(nDinheir, 10,2)+"|" //DINHEIRO
	EndIf
	If nCheques > 0			     
		cFormSup = cFormSup + STR0030 + "|" + STRZERO(nCheques, 10,2)+"|" //CHEQUE
	EndIf	
	If nCartao > 0			     
		cFormSup = cFormSup + STR0031 + "|" + STRZERO(nCartao, 10,2)+"|" //CARTAO CREDITO
	EndIf	
	If nVlrDebi > 0			     
		cFormSup = cFormSup + STR0032 + "|" + STRZERO(nVlrDebi, 10,2)+"|" //CARTAO DEBITO
 	EndIf	
	If nFinanc > 0			     
		cFormSup = cFormSup + STR0033 + "|" + STRZERO(nFinanc, 10,2)+"|" //FINANCIADO
	EndIf	
	If nConveni > 0			     
		cFormSup = cFormSup + STR0034 + "|" + STRZERO(nConveni, 10,2)+"|" //CONVENIO
	EndIf
	If nVales > 0			     
		cFormSup = cFormSup + STR0035 + "|" + STRZERO(nVales, 10,2)+"|" //VALES
	EndIf
	If nOutros > 0			     
		cFormSup = cFormSup + STR0036 + "|" + STRZERO(nOutros, 10,2)+"|" //OUTROS
	EndIf
	
EndIf
                              
If lFiscal .And. nTotal > 0 .And. !ExistBlock("Frt050ST")
	nRet := IFSupr( nHdlECF, If(nCheck=1,3,nCheck), StrZero(nTotal,14,2), "","",, cFormSup )
	If nRet != 0
		// "Não foi possível registrar " ### "Sangria","Troco" ### " no ECF. Operação não efetuada." ### "Atenção"
		MsgStop(STR0027 + If(nCheck==1,STR0003,STR0004) + STR0028, STR0024)
		Return(.F.)
	Else
	   nRet := IfPegCupom( nHdlECF, @cCupom)
	   
	   If nRet != 0
			// "Não foi possível registrar " ### "Sangria","Troco" ### " no ECF. Operação não efetuada." ### "Atenção"
			MsgStop(STR0027 + If(nCheck==1,STR0003,STR0004) + STR0028, STR0024)
			Return(.F.)
		EndIf
		//--------------------------------------------------------
	EndIf
EndIf

For nX := 1 to If(nCheck==1,Len(aNumerarios),1)
	If !aNumerarios[nX][2] == 0
		FRT050GRV(cCodOrigem, nCheck, "P", aNumerarios[nX], ;
				  aSimbs	, lSigaLoja, cCupom)
		FRT050GRv(cCodDestin, nCheck, "R", aNumerarios[nX], ;
			      aSimbs, lSigaLoja, cCupom)
	EndIf
Next nX

Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Frt050GRV ³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o Registro no SE5 conforme os parametros recebidos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Frta050				 								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - (1 - cCodigo) Codigo do caixa.                     ³±±
±±³          ³ ExpN1 - (2 - nCheck) Indica se e troco ou sangria.         ³±±
±±³          ³ ExpC2 - (3 - nRecPag) Indica se e pagto ou recebimento.    ³±±
±±³          ³ ExpN2 - (4 - aNum) Valor a ser gravado.                    ³±±
±±³          ³ ExpA1 - (5 - aSimbs) Array de simbolos de moeda.           ³±±
±±³          ³ ExpL1 - (6 - lSigaLoja) Indica se a funcao esta sendo      ³±±
±±³          ³							chamada do siga loja.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      | Analista | Bops  | Descricao                               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/10/2007| Nunzio   |132489 | Criacao do parametro lSigaLoja          |±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRT050Grv (cCodigo	, nCheck, cRecPag, aNum, ;
					aSimbs	, lSigaLoja, cCupom, dDataMovto)

Local cCaixa 		:= xNumCaixa()										//Numero do caixa
Local cNatureza 	:= If(nCheck == 1,Upper(STR0003),Upper(STR0004))  	//"Sangria","Troco"
Local cHistor   	:= If(nCheck == 1,STR0020,STR0021)+cCaixa  		//"SANGRIA DO CAIXA ","TROCO PARA O CAIXA "
Local cAgencia  	:= ""                                       		//Numero da agencia
Local cConta    	:= ""                                       		//Numero da conta
Local nDecs1    	:= MsDecimais(1)                            		//Numero de casas decimais
Local cPrefixo      := LjGetStation("LG_SERIE")							//Numero de serie do PDV
Local nSequencia	:= 0												//Proxima sequecia a ser gravada
Local oInt			:= Nil                                              //Objeto da integracao
Local lGerInte		:= SuperGetMV("MV_LJGRINT",.F. ,.F.) 					//Verifica se a integracao esta habilitada
Local lMovBco       := .T.
Local lLj7050Grv	:= ExistBlock("LJ7050GRV")                          //Verifica se existe o ponto de entrada LJ7050GRV
Local nRecnoSE5     := 0                                                //Recno da tabela SE5
Local cNumMov		:= AllTrim(LjNumMov())								//Retorno o numero do movimento atual
Local nTamCod   	:= TamSX3("A6_COD")[1]								//Tamanho do campo A6_COD
Local nTamAg   		:= TamSX3("A6_AGENCIA")[1]							//Tamanho do campo A6_AGENCIA
Local nTamConta		:= TamSX3("A6_NUMCON")[1]							//Tamanho do campo A6_NUMCON
Local cCodBanco   	:= ""												//Codigo do banco		
Local cCodAgen   	:= ""												//Codigo do agencia
Local cNumCon       := "" 												//Numero do conta	
Local cSeek			:= ""												// Variavel para controle do SA6	
Local aCxLoja		:= Separa(SuperGetMV("MV_CXLOJA",.F.,""),"/")

DEFAULT lSigaLoja 	:= .F.
DEFAULT dDataMovto	:= dDataBase

If Len(aCxLoja) >= 3
	cCodBanco   	:= PADR(aCxLoja[1],nTamCod) //Codigo do banco		
	cCodAgen   		:= PADR(aCxLoja[2],nTamAg) //Codigo do agencia
	cNumCon       	:= PADR(aCxLoja[3],nTamConta) //Numero do conta	
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua apenas 1 lancamento pois somente baterah o  ³
//³ Resumo de Caixa qdo os dados subirem p/ o servidor.³
//³ Sangria de Cx para Cx jah possui 2 registros,      ³
//³ um R e um P.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cCodigo == cCaixa .Or. cCodigo == Substr(GetMv("MV_CXLOJA"),1,3) .OR. lSigaLoja

	DbSelectArea("SE5")

    DbSetOrder(2)

    If DbSeek(xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cCupom, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase))
       While !Eof() .AND. xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cCupom, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase) == SE5->E5_FILIAL + SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA)
           nSequencia  := Val(SE5->E5_SEQ)
           DbSkip()
       End 
    EndIf

	// Para caixa de destino (cCodDestin) trata Caixa/Agência/Conta que define o Caixa Geral no SIGALOJA.
	If cRecPag = "R" .and. AllTrim(cCodigo)== AllTrim(cCodBanco)
		cSeek := cCodBanco+cCodAgen+cNumCon
	Else
		cSeek := cCodigo
	EndIf
	
	// Posiciona no registro correto do SA6
	SA6->(dbSeek(xFilial("SA6")+cSeek))	

	//Busca o Caixa da moeda correspondente a sangria                          
	If cPaisLoc != "BRA" .And. nMoedaCorr > 1                      
       cConta	 := SA6->A6_NUMCON	      //Conta do Caixa na moeda 1                            
	   cAgencia  := aSimbs[nMoedaCorr]	  //Agencia do Caixa na moeda da sangria/troco     
	   LjxDVerCx(nMoedaCorr,cCodigo,cAgencia,cConta)   //Verifica se existe o Caixa na moeda da sangria/troco. Se nao existir,cria.           
	   SA6->(dbSeek(xFilial("SA6")+cCodigo+cAgencia))  //Posiciona no Caixa da moeda da sangria/troco                          
	EndIf	
	Reclock("SE5",.T.)
	SE5->E5_FILIAL	:= xFilial("SE5")              
	SE5->E5_DATA	:= dDataMovto
	SE5->E5_BANCO	:= SA6->A6_COD
	SE5->E5_AGENCIA	:= SA6->A6_AGENCIA
	SE5->E5_CONTA	:= SA6->A6_NUMCON
	SE5->E5_RECPAG	:= cRecPag
	SE5->E5_HISTOR	:= cHistor
	SE5->E5_TIPODOC	:= "TR"
	SE5->E5_MOEDA	:= If(nCheck=1, aNum[1], "TC")
	SE5->E5_VALOR	:= aNum[2]
	SE5->E5_DTDIGIT	:= dDataBase
	SE5->E5_BENEF	:= Space(15)
	SE5->E5_DTDISPO	:= SE5->E5_DATA
	SE5->E5_NATUREZ	:= cNatureza
	SE5->E5_PREFIXO := cPrefixo
	SE5->E5_NUMERO  := cCupom
	SE5->E5_SEQ     := strzero(nSequencia + 1, 2)
	SE5->E5_SITUA	:= "00" // Criar esse campo para instalacao do Front Loja
	If cPaisLoc != "BRA"  //Para compatibilizar com o Resumo de Caixa
	   SE5->E5_VLMOED2	:= Round(xMoeda(SE5->E5_VALOR,nMoedaCorr,1,dDataMovto,nDecs1+1),nDecs1)
	   SE5->E5_TIPO     := aNum[1]	   
	EndIf   
	If SE5->(FieldPos("E5_NUMMOV")) > 0
		SE5->E5_NUMMOV := cNumMov
	EndIf
	SE5->E5_FILORIG := cFilAnt
	SE5->(dbCommit())
	SE5->(MsUnLock())
	nRecnoSE5 := SE5->(Recno())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada que permite realizar alteracoes no movimento gerado na tabela SE5 ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLj7050Grv
		ExecBlock("LJ7050GRV",.F.,.F.,{nRecnoSE5})
	EndIf	
      
    If lSigaLoja
	   	If SE5->E5_MOEDA$"C1/C2/C3/C4/C5/CH".AND.;
			( (Empty(SE5->E5_NUMCHEQ) .OR. Substr(SE5->E5_NUMCHEQ,1,1)=="*") .AND. SE5->E5_NATUREZ <> Upper(STR0003) )			
			lMovbco := .F.
		Endif
	   	If SE5->E5_VENCTO <= SE5->E5_DATA .AND. lMovBco
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Saldo Bancario		              				     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,If(Upper(AllTrim(cRecPag)) == "P","-","+"))
		EndIf	                                  
	EndIf	
	If lGerInte .AND. nModulo == 12 .AND. (Alltrim(Upper(FunName())) $ "LOJA340|LOJA350")
		
		If AllTrim(Upper(cNatureza)) == "TROCO"
			
			oInt := LJCAdapXMLEnvSuprimento():New()
		
		ElseIf AllTrim(Upper(cNatureza)) == Upper(STR0003)
			
			oInt := LJCAdapXMLEnvSangria():New()	
		
		EndIf
		
		If oInt != Nil
			oInt:Inserir("SE5", xFilial("SE5") +  SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA) + SE5->E5_CLIFOR + SE5->E5_LOJA + SE5->E5_SEQ, "2", "3")
			oInt:Gerar() 
			oInt:Finalizar() 
		EndIf
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Esta geração deve ser efetuada somente qdo chamada do Front Loja             ³
	//³pois a tabela SLI tem como única função subir os movimentos para a retaguarda|
	//³                                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(Upper(FunName())) $ "FRTA010|FRTA271"
		FRTGeraSLI("    ", "050", Str(SE5->(Recno()),17,0), "NOVO")
	EndIf
			
EndIf

Return NIL
