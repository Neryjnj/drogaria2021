#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://127.0.0.1/9901/LJPESQPONTOS.apw?WSDL
Gerado em        10/18/04 16:36:21
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.040504
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSLJPESQPONTOS
------------------------------------------------------------------------------- */
Function ___WSLJPESQPTOS

Return Nil

WSCLIENT WSLJPESQPONTOS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE 
	WSMETHOD GETPONTOS

	WSDATA   _URL                      AS String
	WSDATA   cUSRSESSIONID             AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   cCODCLI                   AS string
	WSDATA   cLOJACLI                  AS string
	WSDATA   nGETPONTOSRESULT          AS integer

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJPESQPONTOS
::Init()
If !ExistFunc("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.040917A] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJPESQPONTOS
Return

WSMETHOD RESET WSCLIENT WSLJPESQPONTOS
	::cUSRSESSIONID      := NIL 
	::cFILIAL            := NIL 
	::cCODCLI            := NIL 
	::cLOJACLI           := NIL 
	::nGETPONTOSRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJPESQPONTOS
Local oClone := WSLJPESQPONTOS():New()
	oClone:_URL          := ::_URL 
	oClone:cUSRSESSIONID := ::cUSRSESSIONID
	oClone:cFILIAL       := ::cFILIAL
	oClone:cCODCLI       := ::cCODCLI
	oClone:cLOJACLI      := ::cLOJACLI
	oClone:nGETPONTOSRESULT := ::nGETPONTOSRESULT
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method GETPONTOS of Service WSLJPESQPONTOS
------------------------------------------------------------------------------- */

WSMETHOD GETPONTOS WSSEND cUSRSESSIONID,cFILIAL,cCODCLI,cLOJACLI WSRECEIVE nGETPONTOSRESULT WSCLIENT WSLJPESQPONTOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPONTOS xmlns="http://127.0.0.1/9901/">'
cSoap += WSSoapValue("USRSESSIONID", ::cUSRSESSIONID, cUSRSESSIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("LOJACLI", ::cLOJACLI, cLOJACLI , "string", .T. , .F., 0 ) 
cSoap += "</GETPONTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1/9901/GETPONTOS",; 
	"DOCUMENT","http://127.0.0.1/9901/",,"1.031217",; 
	"http://127.0.0.1/9901/LJPESQPONTOS.apw")

::Init()
::nGETPONTOSRESULT   :=  WSAdvValue( oXmlRet,"_GETPONTOSRESPONSE:_GETPONTOSRESULT:TEXT","integer",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.
