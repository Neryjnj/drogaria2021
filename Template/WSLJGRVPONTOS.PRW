#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://127.0.0.1/9901/LJGRVPONTOS.apw?WSDL
Gerado em        10/18/04 16:35:43
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.040504
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSLJGRVPONTOS
------------------------------------------------------------------------------- */
Function ___WSLJGRVPONTOS

Return Nil

WSCLIENT WSLJGRVPONTOS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GRVPONTOS 

	WSDATA   _URL                      AS String
	WSDATA   cUSRSESSIONID             AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   cCODCLI                   AS string
	WSDATA   cLOJACLI                  AS string
	WSDATA   cSINAL                    AS string
	WSDATA   nPONTOS                   AS integer
	WSDATA   lGRVPONTOSRESULT          AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJGRVPONTOS
::Init()
If !ExistFunc("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.040917A] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJGRVPONTOS
Return

WSMETHOD RESET WSCLIENT WSLJGRVPONTOS
	::cUSRSESSIONID      := NIL 
	::cFILIAL            := NIL 
	::cCODCLI            := NIL 
	::cLOJACLI           := NIL 
	::cSINAL             := NIL 
	::nPONTOS            := NIL 
	::lGRVPONTOSRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJGRVPONTOS
Local oClone := WSLJGRVPONTOS():New()
	oClone:_URL          := ::_URL 
	oClone:cUSRSESSIONID := ::cUSRSESSIONID
	oClone:cFILIAL       := ::cFILIAL
	oClone:cCODCLI       := ::cCODCLI
	oClone:cLOJACLI      := ::cLOJACLI
	oClone:cSINAL        := ::cSINAL
	oClone:nPONTOS       := ::nPONTOS
	oClone:lGRVPONTOSRESULT := ::lGRVPONTOSRESULT
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method GRVPONTOS of Service WSLJGRVPONTOS
------------------------------------------------------------------------------- */

WSMETHOD GRVPONTOS WSSEND cUSRSESSIONID,cFILIAL,cCODCLI,cLOJACLI,cSINAL,nPONTOS WSRECEIVE lGRVPONTOSRESULT WSCLIENT WSLJGRVPONTOS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRVPONTOS xmlns="http://127.0.0.1/9901/">'
cSoap += WSSoapValue("USRSESSIONID", ::cUSRSESSIONID, cUSRSESSIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("LOJACLI", ::cLOJACLI, cLOJACLI , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("SINAL", ::cSINAL, cSINAL , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PONTOS", ::nPONTOS, nPONTOS , "integer", .T. , .F., 0 ) 
cSoap += "</GRVPONTOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1/9901/GRVPONTOS",; 
	"DOCUMENT","http://127.0.0.1/9901/",,"1.031217",; 
	"http://127.0.0.1/9901/LJGRVPONTOS.apw")

::Init()
::lGRVPONTOSRESULT   :=  WSAdvValue( oXmlRet,"_GRVPONTOSRESPONSE:_GRVPONTOSRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.
