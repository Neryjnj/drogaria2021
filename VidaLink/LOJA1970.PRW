#INCLUDE "MSOBJECT.CH"

User Function LOJA1970 ; Return  	// "dummy" function - Internal Use

/*--------------------------------------------------------------------------------
|Classe    |LJCVDLINK       |Autor  |Julio Nery     | Data |  15/03/21           |
|--------------------------------------------------------------------------------|
|Desc.     |Classe responsavel por tratar o processo PBM VidaLink.				 |
|--------------------------------------------------------------------------------|
|Uso       |TotvsPDV                                                    		 |
--------------------------------------------------------------------------------*/
Class LJCVDLINK From LJCSitefDireto
	
	DATA cCodAut
	DATA cCodProd
	DATA cCupom
	DATA cData
	DATA cHora
	DATA cOperador
	DATA aVDLink
	DATA lCancTotal

	Method PVidaLink()						//Metodo construtor
    Method VDLinkCons(cCodAut,cCodProd,cCupom,dData,cHora,cOperador,aVDLink)
	Method VDLinkProd(aVDLink)
	Method VDLinkVenda(cCodAut,nCupom,dData,cHora,cOperador,aVDLink)
	Method VDLinkCanc(lCancTotal,nCupom,dData,cHora,cOperador,aVDLink)
	Method ConfVend(lConfirma)
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} PVidaLink
Inicia PBM Vidalink

@param		oCLisitef, objeto do CLisitef
@author		Julio.Nery
@version	12
@since		16/03/2021
@return		Self - Objeto
/*/
//-------------------------------------------------------------------
Method PVidaLink(oClisitef) Class LJCVDLINK

::SitefDireto(oClisitef)

::cCodAut		:= ""
::cCodProd		:= ""
::cCupom		:= ""
::cData			:= ""
::cHora			:= ""
::cOperador		:= ""
::aVDLink		:= {}
::lCancTotal	:= .T.

Return Self

/*/{Protheus.doc} VDLinkCons
	Classe de consulta de dados VidaLINK
	@type  Class
	@author Julio.Nery
	@since 16/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkCons(cCodAut,cCodProd,nCupom,dData,cHora,cOperador,aVDLink) Class LJCVDLINK
Local lRet := .T.

::cCodAut	:= cCodAut
::cCodProd	:= cCodProd
::cCupom	:= cValToChar(nCupom)
If ValType(dData) == "C"
	::cData := dData
Else
	::cData	:= DToS(dData)
EndIf
::cHora		:= StrTran(cHora,":")
::cOperador	:= cOperador
::aVDLink	:= aVDLink

lRet := ::ConsVDLink()

Return lRet

/*/{Protheus.doc} VDLinkProd
	Consulta de Produtos Vidalink
	@type  Class
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkProd(aVDLink) Class LJCVDLINK
Local lRet := .F.

::aVDLink := aVDLink

lRet := ::ProdVDLink()

Return lRet

/*/{Protheus.doc} VDLinkVenda
	Venda de Produtos Vidalink
	@type  Class
	@author Julio.Nery
	@since 31/03/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkVenda(cCodAut,nCupom,dData,cHora,cOperador,aVDLink) Class LJCVDLINK
Local lRet := .F.

::cCodAut	:= cCodAut
::cCupom	:= cValToChar(nCupom)
If ValType(dData) == "C"
	::cData := dData
Else
	::cData	:= DToS(dData)
EndIf
::cHora		:= StrTran(cHora,":")
::cOperador	:= cOperador
::aVDLink	:= aVDLink

lRet := ::VendaVDLink()
Return lRet

/*/{Protheus.doc} VDLinkCanc
	Cancelamento de Venda Vidalink
	@type  Class
	@author Julio.Nery
	@since 29/04/2021
	@version 12
	@param param, param_type, param_descr
	@return return, return_type, return_description
/*/
Method VDLinkCanc(lCancTotal,nCupom,dData,cHora,cOperador,aVDLink) Class LJCVDLINK
Local lRet := .F.

::lCancTotal:= lCancTotal
::cCupom	:= cValToChar(nCupom)
If ValType(dData) == "C"
	::cData := dData
Else
	::cData	:= DToS(dData)
EndIf
::cHora		:= StrTran(cHora,":")
::cOperador	:= cOperador
::aVDLink	:= aVDLink

lRet := ::CancVDLink()
Return lRet

/*/{Protheus.doc} ConfVend
	Confirma ou n�o a transa��o TEF
	@type  Class
	@author Julio.Nery
	@since 28/04/2021
	@version 12
	@param lConfirma, l�gico, confirma ou n�o a transa��o ?
	@return NIL
/*/
Method ConfVend(lConfirma) Class LJCVDLINK

::FimTrans(lConfirma)

Return Nil