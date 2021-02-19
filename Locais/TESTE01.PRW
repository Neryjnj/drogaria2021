#include "TOTVS.CH"

User Function STMenEdt()
Local _aFuncoes := ParamIxb[1]

AAdd( _aFuncoes, {"80", "VidaLink Teste","U_MeuVidaLK(1,.T.)", "" , "30" } ) //"PBM VIDA LINK"
// AAdd( _aFuncoes, {"81", "PharmaSystem Teste","T_DroVLGet(541,.T.)", "" , "31" } ) //"PBM VIDA LINK"
// AAdd( _aFuncoes, {"82", "Funcional Card Teste","T_DroVLGet(560,.T.)", "" , "32" } ) //"PBM VIDA LINK"

Return _aFuncoes

//***********************************/
User Function MeuVidaLK(nTipo,lTotvsPDV)
Local lRet := .T.
Local oPBM := NIL
Local oRetTran:= NIL
Local oTEF20 := NIL
Local oDados := NIL
Local cNumCup:= ""

cNumCup := STDCSLastSale("L1_DOC")
cNumCup := Soma1(cNumCup)

oTEF20 := STBGetTEF()

//Method New(nValor, nCupom, dData, cHora, lUltimaTrn, cRede)
oDados := LJCDadosTransacaoPBM():New(0,cNumCup,Date(),Time())

If oTEF20:Pbm():SelecPBM()
    oTEF20:Pbm():IniciaVend(oDados)
EndIf

Return lRet