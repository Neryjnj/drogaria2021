#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:8015/LJFINACB.apw?WSDL
Gerado em        06/18/19 14:51:32
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

//"dummy" function - Internal Use 
Function WSC_LOJ020
Return NIL

/* -------------------------------------------------------------------------------
WSDL Service WSLJFINACB
------------------------------------------------------------------------------- */
WSCLIENT WSLJFINACB

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONECTA
	WSMETHOD ESTORNATIT
	WSMETHOD INCLUITIT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCVALOR                   AS string
	WSDATA   lCONECTARESULT            AS boolean
	WSDATA   cCNSUSITEF                AS string
	WSDATA   lLDIRECAO                 AS boolean
	WSDATA   lESTORNATITRESULT         AS boolean
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
	WSDATA   cCNSUCART                 AS string
	WSDATA   cCCODADM                  AS string
	WSDATA   cCNUMMOV                  AS string
	WSDATA   lINCLUITITRESULT          AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJFINACB
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20190114 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJFINACB
Return

WSMETHOD RESET WSCLIENT WSLJFINACB
	::cCVALOR            := NIL 
	::lCONECTARESULT     := NIL 
	::cCNSUSITEF         := NIL 
	::lLDIRECAO          := NIL 
	::lESTORNATITRESULT  := NIL 
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
	::cCNSUCART          := NIL 
	::cCCODADM           := NIL 
	::cCNUMMOV           := NIL 
	::lINCLUITITRESULT   := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJFINACB
Local oClone := WSLJFINACB():New()
	oClone:_URL          := ::_URL 
	oClone:cCVALOR       := ::cCVALOR
	oClone:lCONECTARESULT := ::lCONECTARESULT
	oClone:cCNSUSITEF    := ::cCNSUSITEF
	oClone:lLDIRECAO     := ::lLDIRECAO
	oClone:lESTORNATITRESULT := ::lESTORNATITRESULT
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
	oClone:cCNSUCART     := ::cCNSUCART
	oClone:cCCODADM      := ::cCCODADM
	oClone:cCNUMMOV      := ::cCNUMMOV
	oClone:lINCLUITITRESULT := ::lINCLUITITRESULT
Return oClone

// WSDL Method CONECTA of Service WSLJFINACB

WSMETHOD CONECTA WSSEND cCVALOR WSRECEIVE lCONECTARESULT WSCLIENT WSLJFINACB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONECTA xmlns="http://127.0.0.1:8015/">'
cSoap += WSSoapValue("CVALOR", ::cCVALOR, cCVALOR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONECTA>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:8015/CONECTA",; 
	"DOCUMENT","http://127.0.0.1:8015/",,"1.031217",; 
	"http://127.0.0.1:8015/LJFINACB.apw")

::Init()
::lCONECTARESULT     :=  WSAdvValue( oXmlRet,"_CONECTARESPONSE:_CONECTARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ESTORNATIT of Service WSLJFINACB

WSMETHOD ESTORNATIT WSSEND cCNSUSITEF,lLDIRECAO WSRECEIVE lESTORNATITRESULT WSCLIENT WSLJFINACB
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ESTORNATIT xmlns="http://127.0.0.1:8015/">'
cSoap += WSSoapValue("CNSUSITEF", ::cCNSUSITEF, cCNSUSITEF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LDIRECAO", ::lLDIRECAO, lLDIRECAO , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ESTORNATIT>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:8015/ESTORNATIT",; 
	"DOCUMENT","http://127.0.0.1:8015/",,"1.031217",; 
	"http://127.0.0.1:8015/LJFINACB.apw")

::Init()
::lESTORNATITRESULT  :=  WSAdvValue( oXmlRet,"_ESTORNATITRESPONSE:_ESTORNATITRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method INCLUITIT of Service WSLJFINACB

WSMETHOD INCLUITIT WSSEND cCPREF,cCNUMTIT,cCPARCELA,cCTIPO,cCNATUREZA,cCCLIENTE,cCLOJA,dDEMISS,dDVENCTO,cCHIST,nNMOEDA,cCROTINA,nNVALTIT,cCPORTADO,cCBANCO,cCAGENCIA,cCCONTA,cCNUMCHQ,cCCOMPENSA,cCRG,cCTEL,lLTERCEIRO,cCNSUSITEF,cCNSUCART,cCCODADM,lLDIRECAO,cCNUMMOV WSRECEIVE lINCLUITITRESULT WSCLIENT WSLJFINACB
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
cSoap += WSSoapValue("CNSUSITEF", ::cCNSUSITEF, cCNSUSITEF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNSUCART", ::cCNSUCART, cCNSUCART , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCODADM", ::cCCODADM, cCCODADM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LDIRECAO", ::lLDIRECAO, lLDIRECAO , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNUMMOV", ::cCNUMMOV, cCNUMMOV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</INCLUITIT>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://127.0.0.1:8015/INCLUITIT",; 
	"DOCUMENT","http://127.0.0.1:8015/",,"1.031217",; 
	"http://127.0.0.1:8015/LJFINACB.apw")

::Init()
::lINCLUITITRESULT   :=  WSAdvValue( oXmlRet,"_INCLUITITRESPONSE:_INCLUITITRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.