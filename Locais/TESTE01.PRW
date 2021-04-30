#include "TOTVS.CH"

// User Function STMenEdt()
// Local _aFuncoes := ParamIxb[1]

// AAdd( _aFuncoes, {"80", "VidaLink Teste","U_MeuVidaLK(1,.T.)", "" , "30" } ) //"PBM VIDA LINK"
// // AAdd( _aFuncoes, {"81", "PharmaSystem Teste","T_DroVLGet(541,.T.)", "" , "31" } ) //"PBM VIDA LINK"
// // AAdd( _aFuncoes, {"82", "Funcional Card Teste","T_DroVLGet(560,.T.)", "" , "32" } ) //"PBM VIDA LINK"

// Return _aFuncoes

//***********************************/
User Function MeuVidaLK(nTipo,lTotvsPDV)
Local lRet := .T.
Local oPBM := NIL
Local oRetTran:= NIL
Local oTEF20 := NIL
Local oPBM   := NIL
Local oDados := NIL
Local cNumCup:= ""
Local cTpDoc := "1"
Local cOperador := STFGetStation("PDV")

cNumCup := Substr(STDCSLastSale("L1_DOC"),1,6)
cNumCup := Soma1(cNumCup)

oTEF20 := STBGetTEF()
oPBM := oTEF20:Pbm()
//Method New(nValor, nCupom, dData, cHora, lUltimaTrn, cRede)
oDados := LJCDadosTransacaoPBM():New(0,cNumCup,Date(),Time(),,,cTpDoc,cOperador)

If oPBM:SelecPBM()
    oPBM:IniciaVend(oDados)
EndIf

Return lRet