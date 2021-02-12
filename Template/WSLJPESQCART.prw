#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost/ws/LJPESQCART.apw?WSDL
Gerado em        03/03/06 16:02:15
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.050921
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */
User Function _TQJGQSH
Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLJPESQCART
------------------------------------------------------------------------------- */

WSCLIENT WSLJPESQCART

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD PESQCARTAO
 
	WSDATA   _URL                      AS String
	WSDATA   cUSRSESSIONID             AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   cCODCLI                   AS string
	WSDATA   cLOJACLI                  AS string
	WSDATA   oWSPESQCARTAORESULT       AS LJPESQCART_ARRAYOFWSPESQCART

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJPESQCART
::Init()
If !ExistFunc("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.051130P] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJPESQCART
	::oWSPESQCARTAORESULT := LJPESQCART_ARRAYOFWSPESQCART():New()
Return

WSMETHOD RESET WSCLIENT WSLJPESQCART
	::cUSRSESSIONID      := NIL 
	::cFILIAL            := NIL 
	::cCODCLI            := NIL 
	::cLOJACLI           := NIL 
	::oWSPESQCARTAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJPESQCART
Local oClone := WSLJPESQCART():New()
	oClone:_URL          := ::_URL 
	oClone:cUSRSESSIONID := ::cUSRSESSIONID
	oClone:cFILIAL       := ::cFILIAL
	oClone:cCODCLI       := ::cCODCLI
	oClone:cLOJACLI      := ::cLOJACLI
	oClone:oWSPESQCARTAORESULT :=  IIF(::oWSPESQCARTAORESULT = NIL , NIL ,::oWSPESQCARTAORESULT:Clone() )
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method PESQCARTAO of Service WSLJPESQCART
------------------------------------------------------------------------------- */

WSMETHOD PESQCARTAO WSSEND cUSRSESSIONID,cFILIAL,cCODCLI,cLOJACLI WSRECEIVE oWSPESQCARTAORESULT WSCLIENT WSLJPESQCART
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PESQCARTAO xmlns="http://localhost/">'
cSoap += WSSoapValue("USRSESSIONID", ::cUSRSESSIONID, cUSRSESSIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CODCLI", ::cCODCLI, cCODCLI , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("LOJACLI", ::cLOJACLI, cLOJACLI , "string", .T. , .F., 0 ) 
cSoap += "</PESQCARTAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost/PESQCARTAO",; 
	"DOCUMENT","http://localhost/",,"1.031217",; 
	"http://localhost/ws/LJPESQCART.apw")

::Init()
::oWSPESQCARTAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PESQCARTAORESPONSE:_PESQCARTAORESULT","ARRAYOFWSPESQCART",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSPESQCART
------------------------------------------------------------------------------- */

WSSTRUCT LJPESQCART_ARRAYOFWSPESQCART
	WSDATA   oWSWSPESQCART             AS LJPESQCART_WSPESQCART OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJPESQCART_ARRAYOFWSPESQCART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJPESQCART_ARRAYOFWSPESQCART
	::oWSWSPESQCART        := {} // Array Of  LJPESQCART_WSPESQCART():New()
Return

WSMETHOD CLONE WSCLIENT LJPESQCART_ARRAYOFWSPESQCART
	Local oClone := LJPESQCART_ARRAYOFWSPESQCART():NEW()
	oClone:oWSWSPESQCART := NIL
	If ::oWSWSPESQCART <> NIL 
		oClone:oWSWSPESQCART := {}
		aEval( ::oWSWSPESQCART , { |x| aadd( oClone:oWSWSPESQCART , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJPESQCART_ARRAYOFWSPESQCART
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSPESQCART","WSPESQCART",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSPESQCART , LJPESQCART_WSPESQCART():New() )
			::oWSWSPESQCART[len(::oWSWSPESQCART)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSPESQCART
------------------------------------------------------------------------------- */

WSSTRUCT LJPESQCART_WSPESQCART
	WSDATA   cCARTAO                   AS string
	WSDATA   cMENSAGEM                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJPESQCART_WSPESQCART
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJPESQCART_WSPESQCART
Return

WSMETHOD CLONE WSCLIENT LJPESQCART_WSPESQCART
	Local oClone := LJPESQCART_WSPESQCART():NEW()
	oClone:cCARTAO              := ::cCARTAO
	oClone:cMENSAGEM            := ::cMENSAGEM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJPESQCART_WSPESQCART
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCARTAO            :=  WSAdvValue( oResponse,"_CARTAO","string",NIL,"Property cCARTAO as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cMENSAGEM          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,"Property cMENSAGEM as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return


