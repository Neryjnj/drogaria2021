#INCLUDE "TOTVS.CH"
#include "Rwmake.ch"    
#include "TDREA009.ch"    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³TDREA009  ºAutor  ³Andre Melo          º Data ³  OUT/2004   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FUNCAO DE BUSCA DO PLANO DE FIDELIDADE - LOJA              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template - DRO  - FIDELIZACAO				              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function TDREA009()
Local cRet    := "" 
Local lRet    := .F.
Local cSeek   := '"' + xFilial("MHG") + '"'
Local cWhile  := "!EOF() .And. MHG_FILIAL==" + cSeek             
Local cFilter := '((MHG_CODIGO == SA1->A1_CODPLF1 .And. SA1->A1_SITUAP1 == "A") .Or. (MHG_CODIGO == SA1->A1_CODPLF2 .And. SA1->A1_SITUAP2 == "A") .Or. ' +;
				'(MHG_CODIGO == SA1->A1_CODPLF3 .And. SA1->A1_SITUAP3 == "A") .Or. (MHG_CODIGO == SA1->A1_CODPLF4 .And. SA1->A1_SITUAP4 == "A").Or. ' +;
				'(MHG_CODIGO == SA1->A1_CODPLF5 .And. SA1->A1_SITUAP5 == "A"))'
Local cCodPlano := ""
Local	nPosTip	:= 0	,;
		nPosOper:= 0	,;
		cAtual	:= ""	,;
		cOpera	:= ""
Local aAreaSA1  := {}

aAreaSA1  := SA1->(GetArea())                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para conveniados mostrar os planos de fidelidade da empresa de con-³
//³venio                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SA1->A1_TPCONVE == "3"  //Conveniado
   SA1->(DbSetOrder(1))
   //Busca os planos de fidelidade da empresa de convenio
   SA1->(DbSeek(xFilial("SA1")+SA1->A1_EMPCONV+SA1->A1_LOJCONV))
EndIf
    
IF Empty(SA1->A1_CODPLF1) .And. Empty(SA1->A1_CODPLF2) .And. Empty(SA1->A1_CODPLF3) .And. ;
	Empty(SA1->A1_CODPLF4) .And. Empty(SA1->A1_CODPLF5)
	cFilter:='MHG_TIPO=="2" .OR. MHG_TIPO=="3" '
EndIf

Private	oDlg, oLbx, oChk
Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private	lMark	:= .F.

DEFINE MSDIALOG oDlg TITLE "Plano de Fidelizacao" FROM 5,30 TO 25,80

aRet	:= LocxGrid("MHG",cWhile,cFilter,.T.,".F.",cSeek,1,{"MHG_NOME","MHG_CODIGO"},)
aCab	:= AClone(aRet[3])
aLin	:= AClone(aRet[5])
aTam	:= AClone(aRet[4])
aCpo	:= AClone(aRet[1])

If !Empty(aLin[1][3]) //Se houver ao menos uma linha preenchida no List de busca
	oLbx := TwBrowse():New(035,000,000,000,,aCab,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx:nHeight	:= (__DlgHeight(oDlg)*2) - 8
	oLbx:nWidth		:= __DlgWidth(oDlg)*2
	oLbx:lColDrag	:= .T.
	oLbx:nFreeze	:= 1
	oLbx:SetArray(aLin)
	oLbx:bLine		:= LocxBLin('oLbx',aCpo,.T.)
	oLbx:bLDblClick	:={ || ChgMarkLb(oLbx,aLin,{|| .T. },.F.) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRet := .T.,oDlg:End()},{|| lRet := .F.,oDlg:End()},,)
	
	//Retornar a area porque para conveniado estava posicionado na empresa de convenio
	SA1->(RestArea(aAreaSA1))
	
	If lRet
		aEval( aLin, { |x,y| If( aLin[y,1] == 1, cRet := Alltrim(aLin[y,3]), ) } )
		cCodPlano := Posicione("MHG",1,xFilial("MHG")+cRet,"MHG_CODIGO")
	EndIf
Else
	MsgAlert(STR0001) //"Nenhum plano de fidelidade disponível para este cliente."
EndIf
	
Return cCodPlano