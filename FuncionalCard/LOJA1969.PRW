#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1001.CH"

User Function LOJA1969 ; Return  			// "dummy" function - Internal Use

/*/{Protheus.doc} LJCFunCard
	Classe responsavel por tratar o processo PBM Funcional Card
	@type  Classe
	@author Julio.Nery
	@since 31/03/2021
	@version 12
/*/
Class LJCFunCard From LJCSitefDireto
	Data nFuncao
	Data nValor
	Data cCupom
	Data cData
	Data cHora
	Data cOperador
	Data cRestri
	Data aVDLink
	Data nCupom

	Method FuncCard(oClisitef)										//Metodo construtor
	Method FuncCrCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink)
	Method ConfVend(lConfirma)
EndClass

/*/{Protheus.doc} LJCFunCard
	Construtor da classe LJCFunCard
	@type  Metodo
	@author Julio.Nery
	@since 31/03/2021
	@version 12
/*/
Method FuncCard(oClisitef) Class LJCFunCard

::SitefDireto(oClisitef)

::nFuncao := 0
::nValor := 0
::cCupom := ""
::cData := ""
::cHora := ""
::cOperador:= ""
::cRestri := ""
::aVDLink := {}
::nCupom := 0
Return Self

/*/{Protheus.doc} FuncCrCons
	Classe de consulta de dados Funcional Card
	@type  Class
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method FuncCrCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink) Class LJCFunCard
Local lRet := .T.

::nFuncao := nFuncao
::nValor := nValor
::cCupom := cCupom
::cData := cData
::cHora := cHora
::cOperador:= cOperador
::cRestri := cRestri
::cNumCupom := cCupom
::aVDLink := aVDLink
::nCupom := Val(cCupom)

lRet := ::ConsFuncCr()

Return lRet

/*/{Protheus.doc} ConfVend
	Confirma ou não a transação TEF
	@type  Class
	@author Julio.Nery
	@since 28/04/2021
	@version 12
	@param lConfirma, lógico, confirma ou não a transação ?
	@return NIL
/*/
Method ConfVend(lConfirma) Class LJCFunCard

::FimTrans(lConfirma)

Return Nil