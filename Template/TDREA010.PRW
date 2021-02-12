#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³TDREA010  ºAutor  ³Andre Melo          º Data ³  OUT/2004   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FUNCAO DE BUSCA DA CONDICAO PAG.DO PLANO DE FIDELIDADE     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Template - DRO  - FIDELIZACAO				              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function TDREA010()
Local cRet    := "" 
Local lRet    := .F.
Local cSeek   := "" 
Local cWhile  := ""                                                      
Local aAreaAtu:= GetArea()                                               
Local cAlias  := ""
Local aCpos   := {}
Local  cCodPag   := ""
Local	nPosTip	:= 0	,;
		nPosOper:= 0	,;
		cAtual	:= ""	,;
		cOpera	:= ""

Private	oDlg, oLbx, oChk
Private	oOk     := LoadBitMap(GetResources(), "LBTIK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "BR_VERMELHO")	// Bitmap utilizado no Lisbox  (Desabilitado)
Private	lMark	:= .F.
Private lInclui := .F.
Private aCols   := {{"A"}}
                  
/*verificamos se o sistema possui a licenca de
 Integracao Protheus x SIAC ou de Template de Drogaria*/
T_DROLCS()

If !Empty(M->LQ_CPLFIDE)
	cSeek  := '"' + xFilial("LHF") + M->LQ_CPLFIDE + '"'
	cWhile := "!EOF() .And. LHF_FILIAL+LHF_CODIGO ==" + cSeek
	cAlias := "LHF"
	aCpos  := {"LHF_CONDIC","LHF_DESCRI"}
Else                                                          
	cSeek  := '"' + xFilial("SE4") + '"'
	cWhile := "!EOF() .And. E4_FILIAL ==" + cSeek
	cAlias := "SE4"
	aCpos  := {"E4_CODIGO","E4_DESCRI"}
EndIf

DEFINE MSDIALOG oDlg TITLE "Condicao de Pagamento" FROM 5,30 TO 25,80

aRet	:= LocxGrid(cAlias,cWhile,,.T.,".F.",cSeek,1,aCpos,)
aCab	:= AClone(aRet[3])
aLin	:= AClone(aRet[5])
aTam	:= AClone(aRet[4])
aCpo	:= AClone(aRet[1])

oLbx := TwBrowse():New(011,000,000,000,,aCab,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx:nHeight	:= (__DlgHeight(oDlg)*2) - 8
oLbx:nWidth		:= __DlgWidth(oDlg)*2
oLbx:lColDrag	:= .T.
oLbx:nFreeze	:= 1
oLbx:SetArray(aLin)
oLbx:bLine		:= LocxBLin('oLbx',aCpo,.T.)
oLbx:bLDblClick	:={ || ChgMarkLb(oLbx,aLin,{|| .T. },.F.) }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRet := .T.,oDlg:End()},{|| lRet := .F.,oDlg:End()},,)

If lRet
	aEval( aLin, { |x,y| If( aLin[y,1] == 1, cRet := Alltrim(aLin[y,2]), ) } )
	If !Empty(M->LQ_CPLFIDE)
		cCodPag := Posicione("LHF",1,xFilial("LHF")+M->LQ_CPLFIDE+cRet,"LHF_CONDIC")
	Else
		cCodPag := Posicione("SE4",1,xFilial("SE4")+cRet,"E4_CODIGO")
	EndIf
EndIf

Return cCodPag