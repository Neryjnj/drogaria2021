#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:8015/LJFINACEL.apw?WSDL
Gerado em        06/18/19 14:42:13
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

//"dummy" function - Internal Use 
Function WSC_LOJ010
Return Nil

/* -------------------------------------------------------------------------------
WSDL Service WSLJFINACEL
------------------------------------------------------------------------------- */
WSCLIENT WSLJFINACEL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONECTA
	WSMETHOD INCLUITIT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCVALOR                   AS string
	WSDATA   lCONECTARESULT            AS boolean
	WSDATA   cCPREF                    AS string
	WSDATA   cCNUMTIT                  AS string
	WSDATA   cCPARCELA                 AS string
	WSDATA   cCTIPO                    AS string
	WSDATA   cCNATUREZA                AS string
	WSDATA   cCCLIENTE                 AS string
	WSDATA   cCLOJA                    AS string
	WSDATA   dDEMISS                   AS date
	WSDATA   dDVENCTO                  AS date
	WSDATA   cCHIST                    AS string
	WSDATA   nNMOEDA                   AS float
	WSDATA   cCROTINA                  AS string
	WSDATA   nNVALTIT                  AS float
	WSDATA   cCPORTADO                 AS string
	WSDATA   cCBANCO                   AS string
	WSDATA   cCAGENCIA                 AS string
	WSDATA   cCCONTA                   AS string
	WSDATA   cCNUMCHQ                  AS string
	WSDATA   cCCOMPENSA                AS string
	WSDATA   cCRG                      AS string
	WSDATA   cCTEL                     AS string
	WSDATA   lLTERCEIRO                AS boolean
	WSDATA   cEMPPDV                   AS string
	WSDATA   cFILPDV                   AS string
	WSDATA   lMVLJPDVPA                AS boolean
	WSDATA   cCNSUSITEF                AS string
	WSDATA   cCNSUCART                 AS string
	WSDATA   cCCODADM                  AS string
	WSDATA   lLISCARTAO                AS boolean
	WSDATA   lINCLUITITRESULT          AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJFINACEL
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.131227A-20190114 NG] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJFINACEL
Return

WSMETHOD RESET WSCLIENT WSLJFINACEL
	::cCVALOR            := NIL 
	::lCONECTARESULT     := NIL 
	::cCPREF             := NIL 
	::cCNUMTIT           := NIL 
	::cCPARCELA          := NIL 
	::cCTIPO             := NIL 
	::cCNATUREZA         := NIL 
	::cCCLIENTE          := NIL 
	::cCLOJA             := NIL 
	::dDEMISS            := NIL 
	::dDVENCTO           := NIL 
	::cCHIST             := NIL 
	::nNMOEDA            := NIL 
	::cCROTINA           := NIL 
	::nNVALTIT           := NIL 
	::cCPORTADO          := NIL 
	::cCBANCO            := NIL 
	::cCAGENCIA          := NIL 
	::cCCONTA            := NIL 
	::cCNUMCHQ           := NIL 
	::cCCOMPENSA         := NIL 
	::cCRG               := NIL 
	::cCTEL              := NIL 
	::lLTERCEIRO         := NIL 
	::cEMPPDV            := NIL 
	::cFILPDV            := NIL 
	::lMVLJPDVPA         := NIL 
	::cCNSUSITEF         := NIL 
	::cCNSUCART          := NIL 
	::cCCODADM           := NIL 
	::lLISCARTAO         := NIL 
	::lINCLUITITRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJFINACEL
Local oClone := WSLJFINACEL():New()
	oClone:_URL          := ::_URL 
	oClone:cCVALOR       := ::cCVALOR
	oClone:lCONECTARESULT := ::lCONECTARESULT
	oClone:cCPREF        := ::cCPREF
	oClone:cCNUMTIT      := ::cCNUMTIT
	oClone:cCPARCELA     := ::cCPARCELA
	oClone:cCTIPO        := ::cCTIPO
	oClone:cCNATUREZA    := ::cCNATUREZA
	oClone:cCCLIENTE     := ::cCCLIENTE
	oClone:cCLOJA        := ::cCLOJA
	oClone:dDEMISS       := ::dDEMISS
	oClone:dDVENCTO      := ::dDVENCTO
	oClone:cCHIST        := ::cCHIST
	oClone:nNMOEDA       := ::nNMOEDA
	oClone:cCROTINA      := ::cCROTINA
	oClone:nNVALTIT      := ::nNVALTIT
	oClone:cCPORTADO     := ::cCPORTADO
	oClone:cCBANCO       := ::cCBANCO
	oClone:cCAGENCIA     := ::cCAGENCIA
	oClone:cCCONTA       := ::cCCONTA
	oClone:cCNUMCHQ      := ::cCNUMCHQ
	oClone:cCCOMPENSA    := ::cCCOMPENSA
	oClone:cCRG          := ::cCRG
	oClone:cCTEL         := ::cCTEL
	oClone:lLTERCEIRO    := ::lLTERCEIRO
	oClone:cEMPPDV       := ::cEMPPDV
	oClone:cFILPDV       := ::cFILPDV
	oClone:lMVLJPDVPA    := ::lMVLJPDVPA
	oClone:cCNSUSITEF    := ::cCNSUSITEF
	oClone:cCNSUCART     := ::cCNSUCART
	oClone:cCCODADM      := ::cCCODADM
	oClone:lLISCARTAO    := ::lLISCARTAO
	oClone:lINCLUITITRESULT := ::lINCLUITITRESULT
Return oClone

// WSDL Method CONECTA of Service WSLJFINACEL

WSMETHOD CONECTA WSSEND cCVALOR WSRECEIVE lCONECTARESULT WSCLIENT WSLJFINACEL
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONECTA xmlns="http://127.0.0.1:8015/">'
cSoap += WSSoapValue("CVALOR", ::cCVALOR, cCVALOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONECTA>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:8015/CONECTA",; 
	"DOCUMENT","http://127.0.0.1:8015/",,"1.031217",; 
	"http://127.0.0.1:8015/LJFINACEL.apw")

::Init()
::lCONECTARESULT     :=  WSAdvValue( oXmlRet,"_CONECTARESPONSE:_CONECTARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUITIT of Service WSLJFINACEL

WSMETHOD INCLUITIT WSSEND cCPREF,cCNUMTIT,cCPARCELA,cCTIPO,cCNATUREZA,cCCLIENTE,cCLOJA,dDEMISS,dDVENCTO,cCHIST,nNMOEDA,cCROTINA,nNVALTIT,cCPORTADO,cCBANCO,cCAGENCIA,cCCONTA,cCNUMCHQ,cCCOMPENSA,cCRG,cCTEL,lLTERCEIRO,cEMPPDV,cFILPDV,lMVLJPDVPA,cCNSUSITEF,cCNSUCART,cCCODADM,lLISCARTAO WSRECEIVE lINCLUITITRESULT WSCLIENT WSLJFINACEL
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INCLUITIT xmlns="http://127.0.0.1:8015/">'
cSoap += WSSoapValue("CPREF", ::cCPREF, cCPREF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMTIT", ::cCNUMTIT, cCNUMTIT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPARCELA", ::cCPARCELA, cCPARCELA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CTIPO", ::cCTIPO, cCTIPO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNATUREZA", ::cCNATUREZA, cCNATUREZA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCLIENTE", ::cCCLIENTE, cCCLIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLOJA", ::cCLOJA, cCLOJA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DEMISS", ::dDEMISS, dDEMISS , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("DVENCTO", ::dDVENCTO, dDVENCTO , "date", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CHIST", ::cCHIST, cCHIST , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NMOEDA", ::nNMOEDA, nNMOEDA , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CROTINA", ::cCROTINA, cCROTINA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NVALTIT", ::nNVALTIT, nNVALTIT , "float", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CPORTADO", ::cCPORTADO, cCPORTADO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CBANCO", ::cCBANCO, cCBANCO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAGENCIA", ::cCAGENCIA, cCAGENCIA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCONTA", ::cCCONTA, cCCONTA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMCHQ", ::cCNUMCHQ, cCNUMCHQ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCOMPENSA", ::cCCOMPENSA, cCCOMPENSA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CRG", ::cCRG, cCRG , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CTEL", ::cCTEL, cCTEL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LTERCEIRO", ::lLTERCEIRO, lLTERCEIRO , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMPPDV", ::cEMPPDV, cEMPPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILPDV", ::cFILPDV, cFILPDV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MVLJPDVPA", ::lMVLJPDVPA, lMVLJPDVPA , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNSUSITEF", ::cCNSUSITEF, cCNSUSITEF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNSUCART", ::cCNSUCART, cCNSUCART , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCODADM", ::cCCODADM, cCCODADM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LISCARTAO", ::lLISCARTAO, lLISCARTAO , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INCLUITIT>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:8015/INCLUITIT",; 
	"DOCUMENT","http://127.0.0.1:8015/",,"1.031217",; 
	"http://127.0.0.1:8015/LJFINACEL.apw")

::Init()
::lINCLUITITRESULT   :=  WSAdvValue( oXmlRet,"_INCLUITITRESPONSE:_INCLUITITRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.