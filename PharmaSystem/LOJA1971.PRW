#INCLUDE "MSOBJECT.CH"

User Function LOJA1971 ; Return  	// "dummy" function - Internal Use

/*--------------------------------------------------------------------------------
|Classe    |LJCPharmSys       |Autor  |Julio Nery     | Data |  26/03/21         |
|--------------------------------------------------------------------------------|
|Desc.     |Classe responsavel por tratar o processo PBM PharmaSystem.			 |
|--------------------------------------------------------------------------------|
|Uso       |TotvsPDV                                                    		 |
--------------------------------------------------------------------------------*/
Class LJCPharmSys From LJCSitefDireto
	
	DATA nFuncao
	DATA nValor
	DATA cCupom
	DATA cData
	DATA cHora
	DATA cOperador
	DATA cRestri
	DATA aVDLink

	Method PharmaSystem(oClisitef)						//Metodo construtor
    Method PharmSCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink)
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} PharmaSystem
Inicia PBM PharmaSystem

@param		oCLisitef, objeto do CLisitef
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		Self - Objeto
/*/
//-------------------------------------------------------------------
Method PharmaSystem(oClisitef) Class LJCPharmSys

::SitefDireto(oClisitef)

::nFuncao := 0
::nValor := 0
::cCupom := ""
::cData := ""
::cHora := ""
::cOperador:= ""
::cRestri := ""
::aVDLink := {}

Return Self

/*/{Protheus.doc} PharmSCons
	Classe de consulta de dados PharmaSystem
	@type  Class
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method PharmSCons(nFuncao,nValor,cCupom,cData,cHora,cOperador,cRestri,aVDLink) Class LJCPharmSys
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

lRet := ::ConsPharmS()

Return lRet